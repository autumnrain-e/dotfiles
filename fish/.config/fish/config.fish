# Disable fish greeting message
set fish_greeting ""

if status is-interactive
    # Commands to run in interactive sessions can go here
    sleep 0.1
    fastfetch
end

# FNM
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
alias setkp='git config core.sshCommand "ssh -i ~/.ssh/id_rsa" && git config commit.gpgsign false'

# Aliases Mac
alias gdots='cd /Users/antonio/dotfiles && nvim .'
alias gconf='cd ~/.config'

# Aliases NPM
alias npmi='npm install'
alias npmidev='npm install --save-dev'
alias npmiglobal='npm install -g'

# Aliases PNPM
alias pnpmi='pnpm install'
alias pnpmd='pnpm run dev'
# Aliases Synergy
alias gp='cd /Users/antonio/LnW/games && gproxy'
alias gproxy='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games'
alias gproxy_local='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games --config ./gproxy.json'
alias gproxy_cw='./gproxy_darwin_m1 --static /Users/antonio/LnW/games/gproxy/games --profile wrapper'
alias cps='gulp --gdm-gproxy'
alias gs='gulp --serve'
alias gc='gulp --clean'

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
alias obsidian='~/Documents/Antonio && nvim .'
alias lg='lazygit'
alias cl='claude'
alias ku='curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin'

# Aliases AeroSpace
# ascheck validates aerospace.toml without applying it — run it before asreload.
# asreload re-reads aerospace.toml only. It does NOT re-run after-startup-command,
# so it cannot relaunch sketchybar or borders.
alias ascheck='aerospace reload-config --dry-run'
alias asreload='aerospace reload-config'
# Full restart of the whole WM stack, and the only way to re-fire
# after-startup-command (which is what launches sketchybar and borders).
# All three processes must die first:
#   - AeroSpace, because `open -a` on a running app only activates it, so the
#     startup command never fires and the daemons would stay dead.
#   - borders and sketchybar, because borders does NOT exit with AeroSpace; a
#     surviving daemon makes the relaunch a silent no-op and leaves a stale process.
# Also re-tiles every open window.
alias asrestart='killall AeroSpace sketchybar borders 2>/dev/null; sleep 1; open -a AeroSpace'

# Aliases SketchyBar
# sbreload re-executes sketchybarrc, so it picks up edits to any file in the
# package — items, plugins, colors.sh, icons.sh. This is the one to use for config
# changes. Two caveats: it is asynchronous (a --set or --query on the next line can
# fail with "Item not found"), and it discards anything set ad-hoc with --set.
alias sbreload='sketchybar --reload'
# Only for a wedged process — sbreload covers every config change. AeroSpace owns
# the lifecycle, so asrestart is the cleaner route; this exists for when restarting
# the WM is too disruptive. nohup/disown because a bare `sketchybar &` is a child of
# the shell and takes SIGHUP when the terminal closes.
alias sbrestart='killall sketchybar 2>/dev/null; sleep 1; nohup sketchybar >/dev/null 2>&1 &; disown'

# Yazi
set -gx EDITOR nvim

# Maven
set -gx M2_HOME "/Users/antonio/Maven/apache-maven-3.9.0"
set -gx PATH $M2_HOME/bin $PATH

# Python — macOS has python3, not a `pip` command. User-level scripts
# (pytest, etc.) land in ~/Library/Python/<ver>/bin and are not on PATH.
alias pip3='python3 -m pip'
for pybin in $HOME/Library/Python/*/bin
    if test -d $pybin
        fish_add_path $pybin
    end
end

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

fish_add_path ~/.local/bin

# Starship
starship init fish | source

# Zoxide
zoxide init fish | source

# pnpm
set -gx PNPM_HOME /Users/antonio/Library/pnpm
if not string match -q -- "$PNPM_HOME/bin" $PATH
    set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end

# opencode
fish_add_path /Users/antonio/.opencode/bin
mise activate fish | source

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
