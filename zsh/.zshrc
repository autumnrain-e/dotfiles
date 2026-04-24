# Custom Functions
gbuild() {
    gulp --gdm-package --VERSION="$1"
}


# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"


export PATH=$HOME/.local/bin:$PATH

# bun completions
[ -s "/Users/antonio/.bun/_bun" ] && source "/Users/antonio/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
