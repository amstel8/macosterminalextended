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

source "${${(%):-%N}:A:h}/extended-terminal-multiline.zsh"

function extended-terminal::beginning-of-input() { CURSOR=0; }
function extended-terminal::end-of-input() { CURSOR=${#BUFFER}; }
zle -N extended-terminal::beginning-of-input
zle -N extended-terminal::end-of-input
function extended-terminal::move-input() {
    extended-terminal::enabled shortcutsEnabled || return
    zle deactivate-region -w
    zle -K main
    zle "extended-terminal::${WIDGET#extended-terminal::move-}" -w
}
zle -N extended-terminal::move-beginning-of-input extended-terminal::move-input
zle -N extended-terminal::move-end-of-input extended-terminal::move-input

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
    local target=${WIDGET#extended-terminal::select-}
    case $target in
        beginning-of-input|end-of-input) target="extended-terminal::$target" ;;
    esac
    zle "$target" -w
    if extended-terminal::enabled copyEnabled; then
        local start=$(( MARK < CURSOR ? MARK : CURSOR ))
        local end=$(( MARK > CURSOR ? MARK : CURSOR ))
        if (( end > start )); then
            printf '%s' "${BUFFER[$((start + 1)),$end]}" | /usr/bin/pbcopy
        fi
    fi
}

for _et_widget in backward-word forward-word beginning-of-line end-of-line beginning-of-input end-of-input; do
    zle -N "extended-terminal::select-$_et_widget" extended-terminal::select
done
for _et_map in emacs viins shift-select; do
    bindkey -M "$_et_map" $'\e[1;4D' extended-terminal::select-backward-word
    bindkey -M "$_et_map" $'\e[1;4C' extended-terminal::select-forward-word
    bindkey -M "$_et_map" $'\e[1;6D' extended-terminal::select-beginning-of-line
    bindkey -M "$_et_map" $'\e[1;6C' extended-terminal::select-end-of-line
    bindkey -M "$_et_map" $'\e[1;5A' extended-terminal::move-beginning-of-input
    bindkey -M "$_et_map" $'\e[1;5B' extended-terminal::move-end-of-input
    bindkey -M "$_et_map" $'\e[1;5H' extended-terminal::move-beginning-of-input
    bindkey -M "$_et_map" $'\e[1;5F' extended-terminal::move-end-of-input
    bindkey -M "$_et_map" $'\e[1;6A' extended-terminal::select-beginning-of-input
    bindkey -M "$_et_map" $'\e[1;6B' extended-terminal::select-end-of-input
    bindkey -M "$_et_map" $'\e[1;6H' extended-terminal::select-beginning-of-input
    bindkey -M "$_et_map" $'\e[1;6F' extended-terminal::select-end-of-input
done
unset _et_widget _et_map
