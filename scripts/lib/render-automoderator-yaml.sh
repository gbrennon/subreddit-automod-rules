render_automoderator_yaml() {
    local input_path="$1"
    local output_path="$2"
    local renderer_path

    renderer_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/render-automoderator-yaml.py"
    python3 "$renderer_path" "$input_path" "$output_path"
}
