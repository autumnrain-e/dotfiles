tap "felixkratz/formulae"

brew "cmake"
brew "eza"
brew "fastfetch"
brew "fd"
# Both daemons come from the tap above and are launched by AeroSpace's
# after-startup-command, not by brew services.
brew "felixkratz/formulae/borders"
brew "felixkratz/formulae/sketchybar"
brew "ffmpeg"
brew "ffmpeg-full"
brew "fish"
brew "fnm"
brew "fzf"
brew "gh"
brew "ghostscript"
brew "git-filter-repo"
brew "git-lfs"
brew "go"
brew "imagemagick"
brew "jq"
brew "lazygit"
brew "libmagic"
brew "librsvg"
brew "media-control" # Now Playing for SketchyBar; media_change is dead on macOS 26
brew "luarocks"
brew "neovim"
brew "pngquant"
brew "poppler"
brew "resvg"
brew "ripgrep"
brew "sevenzip"
brew "starship"
brew "stow"
brew "yazi"
brew "zoxide"
cask "copilot-cli"
# Glyphs-only Nerd Font: supplies "Symbols Nerd Font Mono", used by SketchyBar's
# icons and by kitty.conf's symbol_map fallback, and by the ghostty config's
# font-codepoint-map.
cask "font-symbols-only-nerd-font"
# Bootstrap only: the cask is marked auto_updates because Ghostty updates itself,
# so `brew upgrade` skips it (unless --greedy) and the Caskroom version goes stale
# by design. Here so a fresh machine gets the terminal that `stow ghostty` configs
# — unlike kitty, which stays out of this file on purpose (curl installer, `ku`).
cask "ghostty"
