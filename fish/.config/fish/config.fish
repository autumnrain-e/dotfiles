# Disable fish greeting message
set fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
    sleep 0.1
    ~/.local/bin/fastfetch --logo-animate
end

# FNM
set -Ua fish_user_paths /Users/antonio/.local/state/fnm_multishells/33465_1748210470789/bin
fnm env --use-on-cd | source

# Aliases eza
alias ls='eza --long --colour=always --icons=always --group-directories-first'
alias la='eza --long --colour=always --icons=always --group-directories-first --all'
alias lt='eza --long --colour=always --icons=always --group-directories-first --all --tree'

# Aliases Git
alias gb='git branch'
alias gf='git fetch'
alias gcln='git config --local user.name "Antonio Felizzola"'
alias gcle='git config --local user.email "antonio.qfel@gmail.com"'
alias gclocal='gcln && gcle'
alias gc='git clone'
alias setkw='git config core.sshCommand "ssh -i ~/.ssh/id_ed25519" && git config commit.gpgsign true'
alias setkp='git config core.sshCommand "ssh -i ~/.ssh/gitkraken_rsa" && git config commit.gpgsign false'

# Aliases Mac
alias editfish='vim /Users/antonio/dotfiles/fish/.config/fish/config.fish'

# Aliases Node
alias npmi='npm install'
alias npmidev='npm install --save-dev'
alias npmiglobal='npm install -g'

# Aliases Synergy
alias gproxy='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games'
alias gproxy_local='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games --config ./gproxy.json'
alias gproxy_cw='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games --profile wrapper'
alias cps='gulp --gdm-gproxy'
alias gs='gulp --serve'
alias gdot='cd ~/.dotfiles'
alias gconf='cd ~/.config'

# Aliases Wrapper
alias slwrapper='ln -s /Users/antonio/LnW/gdm-frontend/release/temp/gdmwrapper/* /Users/antonio/LnW/games/gproxy/games'
alias cpw='mvn install -e'

# Aliases Docs Portal
alias bportal='docker build -t docs-portal .'
alias rportal='docker run -it --rm -p 8000:8000 -v .:/app docs-portal'
alias docs='bportal && rportal'

# Aliases Utils
alias aliases='bat ~/.config/fish/config.fish | grep alias'
alias myip='ifconfig | grep "inet " | grep -v 127.0.0.1'
alias vim='nvim'
alias obsidian='~/Documents/Antonio && nvim .'

# Yazi
set -gx EDITOR nvim

# Maven
set -gx M2_HOME "/Users/antonio/Maven/apache-maven-3.9.0"
set -gx PATH $M2_HOME/bin $PATH

# Secrets (tokens, keys, etc.)
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

# Yazi
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Starship
starship init fish | source

# Zoxide
zoxide init fish | source
export PATH="$HOME/.local/bin:$PATH"

# pnpm
set -gx PNPM_HOME /Users/antonio/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
