export EDITOR="hx"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export HOMEBREW_NO_ENV_HINTS=1

if [ -s ~/.zshenv.local ]; then
    source ~/.zshenv.local
fi
