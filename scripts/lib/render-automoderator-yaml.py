from __future__ import annotations

import pathlib
import sys
from collections.abc import Mapping

import yaml


class AutoModeratorYamlRenderer:
    def render(self, input_path: pathlib.Path) -> str:
        globals_definition, rules_definition = self._load_rule_definition(input_path)
        rule_documents = self._build_rule_documents(globals_definition, rules_definition)
        return self._serialize_rule_documents(rule_documents)

    def write(self, input_path: pathlib.Path, output_path: pathlib.Path) -> None:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(self.render(input_path))

    def _load_rule_definition(self, input_path: pathlib.Path) -> tuple[dict, list[dict]]:
        document = yaml.safe_load(input_path.read_text())
        if not isinstance(document, Mapping):
            raise ValueError("Input must contain a mapping")
        globals_definition = document.get("globals", {})
        rules_definition = document.get("rules", [])
        if not isinstance(globals_definition, Mapping):
            raise ValueError("globals must be a mapping")
        if not isinstance(rules_definition, list) or not all(isinstance(rule, Mapping) for rule in rules_definition):
            raise ValueError("rules must be a list of mappings")
        return dict(globals_definition), [dict(rule) for rule in rules_definition]

    def _build_rule_documents(self, globals_definition: dict, rules_definition: list[dict]) -> list[dict]:
        return [{**globals_definition, **rule} for rule in rules_definition]

    def _serialize_rule_documents(self, rule_documents: list[dict]) -> str:
        return yaml.safe_dump_all(
            rule_documents,
            explicit_start=True,
            sort_keys=False,
            default_flow_style=False,
            allow_unicode=True,
        )


def main() -> None:
    input_path = pathlib.Path(sys.argv[1])
    output_path = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else pathlib.Path(__file__).parents[2] / "dist" / "automoderator-rules.yaml"
    renderer = AutoModeratorYamlRenderer()
    renderer.write(input_path, output_path)


if __name__ == "__main__":
    main()
