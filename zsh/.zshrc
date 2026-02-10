# Plugins
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
zstyle ':antidote:bundle' use-friendly-names 'yes'
antidote load
autoload -Uz compinit && compinit

# Prompt
eval "$(starship init zsh)"

alias unstow="stow -D"

if [ -s ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# Added by dbt installer
export PATH="$PATH:/Users/rosslovelace/.local/bin"

# dbt aliases
alias dbtf=/Users/rosslovelace/.local/bin/dbt
