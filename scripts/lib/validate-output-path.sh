validate_output_path() {
    local output_path="$1"
    local source_rules_path="${2:-automoderator-rules.yaml}"

    if [[ "$(realpath -m "$output_path")" == "$(realpath -m "$source_rules_path")" ]]; then
        printf 'Refusing to overwrite source rules file: %s\n' "$source_rules_path" >&2
        return 1
    fi

    mkdir -p "$(dirname "$output_path")"
}

find_available_output_path() {
    local requested_path="$1"
    local output_directory
    local output_filename
    local output_stem
    local output_extension=""
    local candidate_path
    local increment=1

    if [[ ! -e "$requested_path" ]]; then
        printf '%s\n' "$requested_path"
        return 0
    fi

    output_directory="$(dirname "$requested_path")"
    output_filename="$(basename "$requested_path")"
    if [[ "$output_filename" == *.* && "$output_filename" != .* ]]; then
        output_stem="${output_filename%.*}"
        output_extension=".${output_filename##*.}"
    else
        output_stem="$output_filename"
    fi

    candidate_path="$output_directory/${output_stem}-${increment}${output_extension}"
    while [[ -e "$candidate_path" ]]; do
        increment=$((increment + 1))
        candidate_path="$output_directory/${output_stem}-${increment}${output_extension}"
    done

    printf '%s\n' "$candidate_path"
}
