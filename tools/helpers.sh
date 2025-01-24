function get_shell_type(){
    echo "$(basename $SHELL)"
}

function get_startup_file_path() {
    local shell_type
    shell_type="$(get_shell_type)"
    rc_file="${shell_type}rc"
    echo "$HOME/.$rc_file"
}