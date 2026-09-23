# Shell side of the Omarchy-style desktop. Sourced from ~/.zshrc.
# Colours come from the active theme so the prompt, fzf and bat follow
# `theme <name>` without editing this file.

if [[ -r "$HOME/.config/omarchy-mac/current.sh" ]]; then
  source "$HOME/.config/omarchy-mac/current.sh"
fi
export PATH="$HOME/.config/omarchy-mac/bin:$PATH"

export BAT_THEME="${BAT_THEME_NAME:-TwoDark}"
export FZF_DEFAULT_OPTS="--height=42% --layout=reverse --border=rounded --info=inline --prompt='  ' --pointer='◆' --marker='✓' --color=bg+:${FZF_SURFACE:-#1b1e24},bg:${FZF_BG:-#0b0d10},spinner:${FZF_ACCENT:-#ffb86c},hl:${FZF_ACCENT:-#ffb86c},fg:${FZF_FG:-#e8e9ed},header:${FZF_ACCENT:-#ffb86c},info:${FZF_MUTED:-#858b98},pointer:${FZF_ACCENT:-#ffb86c},marker:${FZF_ACCENT:-#ffb86c},fg+:${FZF_FG:-#e8e9ed},prompt:${FZF_ACCENT:-#ffb86c},hl+:${FZF_ACCENT:-#ffb86c}"

if [[ -t 0 ]]; then
  command -v fzf >/dev/null && source <(fzf --zsh)
  command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
fi
command -v starship >/dev/null && eval "$(starship init zsh)"

alias ls='eza --icons=auto --group-directories-first'
alias ll='eza --icons=auto --group-directories-first --long --git'
alias la='eza --icons=auto --group-directories-first --long --git --all'
alias lt='eza --icons=auto --tree --level=2 --group-directories-first'
alias cat='bat --paging=never'
alias lg='lazygit'
alias top='btop'
alias c='z'
