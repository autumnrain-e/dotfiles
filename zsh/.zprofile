# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# FNM - Fast Node Manager
eval "$(fnm env --use-on-cd)"

# Zoxide - Better CD
eval "$(zoxide init zsh)"

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
alias rs='recurse-submodules'

# Aliases Mac
alias editzsh='vim /Users/antonio/.zprofile'
alias oc='code .'

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
alias aliases='bat ~/.zprofile | grep alias'
alias myip='ifconfig | grep "inet " | grep -v 127.0.0.1'
alias ff='fastfetch'

# Maven
export M2_HOME="/Users/antonio/Maven/apache-maven-3.9.0"
PATH="${M2_HOME}/bin:${PATH}"
export PATH
