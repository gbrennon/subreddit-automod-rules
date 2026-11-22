load_rule_definition() {
    local input_path="$1"

    if [[ ! -f "$input_path" ]]; then
        printf 'Input file not found: %s\n' "$input_path" >&2
        return 1
    fi

    if [[ ! -r "$input_path" ]]; then
        printf 'Input file is not readable: %s\n' "$input_path" >&2
        return 1
    fi
}
