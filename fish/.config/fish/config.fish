if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Starship
starship init fish | source

# Aliases eza
alias ls='eza --long --colour=always --icons=always --group-directories-first'
alias la='eza --long --colour=always --icons=always --group-directories-first --all'
alias lt='eza --long --colour=always --icons=always --group-directories-first --all --tree'

# Aliases Git
alias gb='git branch'
alias gf='git fetch'
alias gcln='git config --local user.name "Antonio Felizzola"'
alias gcle='git config --local user.email "antonio.qfel@gmail.com"'
alias rs='--recurse-submodules'

# Aliases Utils
alias myip='ifconfig | grep "inet " | grep -v 127.0.0.1'

# Aliases Config
alias gconf='cd ~/.config'
alias gdot='cd ~/.dotfiles'


# FNM
set -Ua fish_user_paths /Users/antonio/.local/state/fnm_multishells/33465_1748210470789/bin
fnm env --use-on-cd | source
