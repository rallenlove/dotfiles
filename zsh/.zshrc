# Pure prompt
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

autoload -Uz compinit && compinit
source $(which uv-virtualenvwrapper.sh)

export EDITOR=hx

if [ -s ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi
