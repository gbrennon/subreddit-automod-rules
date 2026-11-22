require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$command_name" >&2
        return 1
    fi
}

require_python_module() {
    local module_name="$1"

    if ! python3 -c "import $module_name" >/dev/null 2>&1; then
        printf 'Required Python module not found: %s\n' "$module_name" >&2
        return 1
    fi
}
