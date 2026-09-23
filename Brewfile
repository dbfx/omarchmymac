# Omarchy-style macOS desktop. Install with: brew bundle --file ~/omarchmymac/Brewfile

tap "felixkratz/formulae"
tap "nikitabobko/tap"

# Desktop shell
cask "nikitabobko/tap/aerospace"      # tiling window manager + workspaces
brew "felixkratz/formulae/sketchybar" # status bar
brew "felixkratz/formulae/borders"    # focused-window border
cask "hammerspoon"                    # Caps leader, modals, project chooser, menu-bar watcher
cask "karabiner-elements"             # Caps Lock -> Hyper (hold) / Escape (tap)
cask "ghostty"                        # terminal (quake-style quick terminal)
cask "raycast"                        # launcher; script commands live in config/raycast/scripts
cask "font-jetbrains-mono-nerd-font"

# Terminal toolchain used by the shell snippet and bar plugins
brew "starship"
brew "fzf"
brew "zoxide"
brew "eza"
brew "bat"
brew "btop"
brew "lazygit"
brew "jq"
brew "ripgrep"
brew "gh"
brew "git"

# Apps the workspaces and session restore expect. Comment out what you don't use.
cask "google-chrome"   # workspace: web
cask "zen"             # workspace: admin
cask "slack"           # workspace: admin
cask "docker-desktop"  # workspace: admin (start-coding also accepts OrbStack)
# T3 Code (Nightly) is not on Homebrew: https://t3.gg
