# Shift + Return inserts a literal newline without submitting the command.
[[ -o interactive && $TERM_PROGRAM == Apple_Terminal ]] || return 0
function extended-terminal::insert-newline() {
    if (( ${+functions[extended-terminal::enabled]} )) && ! extended-terminal::enabled shortcutsEnabled; then
        return
    fi
    if (( REGION_ACTIVE )); then
        zle .kill-region -w
        zle -K main
    fi
    LBUFFER+=$'\n'
}
zle -N extended-terminal::insert-newline
for _et_multiline_map in emacs viins shift-select; do
    if bindkey -l | /usr/bin/grep -qx "$_et_multiline_map"; then
        bindkey -M "$_et_multiline_map" $'\e[13;2u' extended-terminal::insert-newline
    fi
done
unset _et_multiline_map
