#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/check-dependencies.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/load-rule-definition.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/render-automoderator-yaml.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lib/validate-output-path.sh"

resolve_output_path() {
    local input_path="$1"
    local project_root="$2"
    local output_path="${3:-}"
    local output_directory="${4:-}"

    if [[ -n "$output_path" && -n "$output_directory" ]]; then
        printf 'Choose either OUTPUT_FILE or --output-dir, not both\n' >&2
        return 2
    fi

    if [[ -n "$output_path" ]]; then
        printf '%s\n' "$output_path"
    elif [[ -n "$output_directory" ]]; then
        printf '%s/automoderator-rules.yaml\n' "$output_directory"
    else
        printf '%s/dist/automoderator-rules.yaml\n' "$project_root"
    fi
}

main() {
    local input_path="$1"
    local output_path=""
    local output_directory=""
    local project_root
    local source_rules_path
    local argument

    shift
    while [[ "$#" -gt 0 ]]; do
        argument="$1"
        shift
        case "$argument" in
            --output-dir|-d)
                if [[ "$#" -eq 0 ]]; then
                    printf '%s requires a directory\n' "$argument" >&2
                    return 2
                fi
                output_directory="$1"
                shift
                ;;
            --)
                if [[ "$#" -ne 1 || -n "$output_path" ]]; then
                    printf 'Only one OUTPUT_FILE is allowed\n' >&2
                    return 2
                fi
                output_path="$1"
                shift
                ;;
            -* )
                printf 'Unknown option: %s\n' "$argument" >&2
                return 2
                ;;
            *)
                if [[ -n "$output_path" ]]; then
                    printf 'Only one OUTPUT_FILE is allowed\n' >&2
                    return 2
                fi
                output_path="$argument"
                ;;
        esac
    done

    project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    source_rules_path="$project_root/automoderator-rules.yaml"
    output_path="$(resolve_output_path "$input_path" "$project_root" "$output_path" "$output_directory")"

    require_command python3
    require_python_module yaml
    load_rule_definition "$input_path"
    validate_output_path "$output_path" "$source_rules_path"
    output_path="$(find_available_output_path "$output_path")"
    render_automoderator_yaml "$input_path" "$output_path"
    printf '%s\n' "$output_path"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ "$#" -lt 1 ]]; then
        printf 'Usage: %s INPUT_FILE [OUTPUT_FILE|--output-dir DIRECTORY]\n' "$0" >&2
        exit 2
    fi

    main "$@"
fi
