# Pure prompt
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

export EDITOR=hx
export XDG_CONFIG_HOME="$HOME/.config"

if [ -s ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi
