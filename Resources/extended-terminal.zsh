# Extended Terminal keyboard selection for Apple's Terminal and interactive Zsh.
[[ -o interactive && $TERM_PROGRAM == Apple_Terminal ]] || return 0
(( ${+_ET_SELECTION_LOADED} )) && return 0
typeset -g _ET_SELECTION_LOADED=1
source "${${(%):-%N}:A:h}/vendor/zsh-shift-select.plugin.zsh"

function extended-terminal::enabled() {
    local value
    value=$(/usr/bin/defaults read dev.local.TerminalCopyOnSelect "$1" 2>/dev/null)
    [[ $value != 0 ]]
}

function extended-terminal::select() {
    if ! extended-terminal::enabled shortcutsEnabled; then
        zle deactivate-region
        zle -K main
        return
    fi
    if (( !REGION_ACTIVE )); then
        zle set-mark-command -w
        zle -K shift-select
    fi
    zle "${WIDGET#extended-terminal::select-}" -w
    if extended-terminal::enabled copyEnabled; then
        local start=$(( MARK < CURSOR ? MARK : CURSOR ))
        local end=$(( MARK > CURSOR ? MARK : CURSOR ))
        if (( end > start )); then
            printf '%s' "${BUFFER[$((start + 1)),$end]}" | /usr/bin/pbcopy
        fi
    fi
}

for _et_widget in backward-word forward-word beginning-of-line end-of-line; do
    zle -N "extended-terminal::select-$_et_widget" extended-terminal::select
done
for _et_map in emacs viins shift-select; do
    bindkey -M "$_et_map" $'\e[1;4D' extended-terminal::select-backward-word
    bindkey -M "$_et_map" $'\e[1;4C' extended-terminal::select-forward-word
    bindkey -M "$_et_map" $'\e[1;6D' extended-terminal::select-beginning-of-line
    bindkey -M "$_et_map" $'\e[1;6C' extended-terminal::select-end-of-line
done
unset _et_widget _et_map
