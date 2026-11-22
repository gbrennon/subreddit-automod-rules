#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
explicit_artifact_directory="$(mktemp -d)"
explicit_artifact_path="$explicit_artifact_directory/automoderator-rules.yaml"
custom_artifact_directory="$(mktemp -d)"
custom_artifact_path="$custom_artifact_directory/automoderator-rules.yaml"
custom_incremented_path="$custom_artifact_directory/automoderator-rules-1.yaml"
source_checksum="$(sha256sum "$project_root/automoderator-rules.yaml")"
trap 'rm -rf "$explicit_artifact_directory" "$custom_artifact_directory"' EXIT

generated_path="$(bash "$project_root/scripts/generate-automoderator-rules.sh" \
    "$project_root/examples/basic-rules.yaml" \
    --output-dir "$custom_artifact_directory")"
[[ "$generated_path" == "$custom_artifact_path" ]]
[[ -f "$custom_artifact_path" ]]

incremented_path="$(bash "$project_root/scripts/generate-automoderator-rules.sh" \
    "$project_root/examples/basic-rules.yaml" \
    --output-dir "$custom_artifact_directory")"
[[ "$incremented_path" == "$custom_incremented_path" ]]
[[ -f "$custom_incremented_path" ]]

explicit_path="$(bash "$project_root/scripts/generate-automoderator-rules.sh" \
    "$project_root/examples/basic-rules.yaml" \
    "$explicit_artifact_path")"
[[ "$explicit_path" == "$explicit_artifact_path" ]]
explicit_incremented_path="$(bash "$project_root/scripts/generate-automoderator-rules.sh" \
    "$project_root/examples/basic-rules.yaml" \
    "$explicit_artifact_path")"
[[ "$explicit_incremented_path" == "$explicit_artifact_directory/automoderator-rules-1.yaml" ]]

python3 - "$project_root/scripts/lib/render-automoderator-yaml.py" "$project_root/examples/basic-rules.yaml" <<'PY'
import importlib.util
import pathlib
import sys

renderer_path = pathlib.Path(sys.argv[1])
input_path = pathlib.Path(sys.argv[2])
module_specification = importlib.util.spec_from_file_location("renderer", renderer_path)
renderer_module = importlib.util.module_from_spec(module_specification)
module_specification.loader.exec_module(renderer_module)
renderer = renderer_module.AutoModeratorYamlRenderer()
assert renderer.render(input_path).startswith("---\n")
PY

python3 - "$custom_artifact_path" <<'PY'
import pathlib
import sys
import yaml

output_documents = list(yaml.safe_load_all(pathlib.Path(sys.argv[1]).read_text()))
assert output_documents[0]["moderators_exempt"] is False
assert output_documents[0]["type"] == "submission"
assert output_documents[0]["action"] == "filter"
assert output_documents[0]["modmail"].startswith("Moderator u/")
assert output_documents[1]["type"] == "comment"
assert output_documents[1]["action"] == "spam"
assert len(output_documents) == 2
PY

[[ "$source_checksum" == "$(sha256sum "$project_root/automoderator-rules.yaml")" ]]

if bash "$project_root/scripts/generate-automoderator-rules.sh" \
    "$project_root/examples/basic-rules.yaml" \
    "$project_root/automoderator-rules.yaml" >/dev/null 2>&1; then
    exit 1
fi

printf 'generated paths: %s, %s, %s\n' \
    "$custom_artifact_path" \
    "$custom_incremented_path" \
    "$explicit_artifact_directory/automoderator-rules-1.yaml"
