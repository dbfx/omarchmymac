# omarchmymac

An [Omarchy](https://omarchy.org)-style desktop for macOS: tiling windows, named
workspaces, a status bar, a Caps-Lock leader key, and one command that themes
everything. This repo holds every config plus the scripts to set it up on a
fresh Mac.

It is one person's daily setup, published in case it is useful. It is tuned
for an Apple Silicon Mac (Homebrew under `/opt/homebrew`) on a recent macOS,
with a MacBook and one external display. Read `install.sh` before running it:
it installs Homebrew packages, symlinks dotfiles into your home directory
(backing up what was there) and changes a few macOS defaults.

```sh
git clone https://github.com/dbfx/omarchmymac.git ~/omarchmymac
~/omarchmymac/install.sh
```

Then grant Accessibility to AeroSpace, Hammerspoon and Karabiner-Elements, add
`~/.config/raycast/scripts` under Raycast > Extensions > Script Commands, and log
out once. `bin/check.sh` reports anything still missing.

## What it involves

| Piece | Tool | Config in this repo |
|---|---|---|
| Tiling + workspaces | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `config/aerospace/aerospace.toml` |
| Status bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | `config/sketchybar/` |
| Focused-window border | [JankyBorders](https://github.com/FelixKratz/JankyBorders) | `config/borders/bordersrc` |
| Caps Lock leader, modals, project chooser | [Hammerspoon](https://www.hammerspoon.org) | `config/hammerspoon/init.lua` |
| Caps Lock → Hyper / Escape | [Karabiner-Elements](https://karabiner-elements.pqrs.org) | `config/karabiner/karabiner.json` |
| Terminal + quake terminal | [Ghostty](https://ghostty.org) | `config/ghostty/` |
| Themes, wallpapers, helper commands | shell scripts | `config/omarchy-mac/` |
| Prompt, fuzzy finder, ls/cat replacements | starship, fzf, zoxide, eza, bat, btop, lazygit | `config/*.toml`, `config/btop`, `config/lazygit`, `shell/omarchy.zsh` |
| Launcher commands | Raycast script commands | `config/raycast/scripts/` |

### Workspaces

`install.sh` asks which workspaces you want (or pass `--defaults`). The
answer lives in `config/omarchy-mac/workspaces.conf` as `name:display:key`
entries plus the two monitor names; re-run `bin/configure.sh` to change it, or
edit the file and run `bin/render.sh`. The bar and Hammerspoon read the file
directly and AeroSpace gets its three workspace blocks rendered into
`aerospace.toml` between `>>>`/`<<<` markers. App routing rules in
`aerospace.toml` and the session restore script still name workspaces, so
adjust those if you drop one they use.

The default set is six named workspaces, pinned to displays. On the desk the four work
workspaces live on the external monitor and the two utility ones on the
laptop panel; on the road everything lands on the one screen.

| Key | Workspace | Display | Apps routed there |
|---|---|---|---|
| Alt+1 | web | external | Chrome |
| Alt+2 | code | external | T3 Code |
| Alt+3 | term | external | Ghostty |
| Alt+4 | misc | external | anything unassigned |
| Alt+5 | chat | laptop | Zen, Slack, Docker |
| Alt+6 | scratch | laptop | |

Apps without a routing rule start floating at their natural size on `misc`.
Hammerspoon then tiles the window if it is a real, resizable app window
(wider than 720 px or taller than 520 px); installers, DMG windows and other
small or fixed-size windows stay floating instead of being stretched into a
tile. Each decision is logged in the Hammerspoon console. Add a rule in
`aerospace.toml` for any app you want tiled immediately, and Alt+T still
toggles floating by hand.

Alt+hjkl focuses, Alt+Shift+hjkl moves, Alt+F fullscreens, Alt+T toggles
floating, Alt+R enters resize mode, Alt+; opens the service/rescue mode.
Alt+Enter opens a terminal. The full list is in `aerospace.toml`.

### Caps Lock leader

Karabiner turns a held Caps Lock into Hyper (Cmd+Ctrl+Alt+Shift) and a tap into
Escape. Hammerspoon then builds a leader on top of it:

| Caps + | Does |
|---|---|
| W then w/c/t/m/h/s | jump to a workspace |
| A then w/c/t/h/f/d | focus Chrome / T3 Code / Ghostty / Slack / Finder / Docker |
| S then l/s/a/b/h/p/t | lock / sleep / reload AeroSpace / bar / Hammerspoon / pomodoro / tests |
| M then p/n/b/u/d | play-pause / next / previous / volume |
| P | project chooser (repos under `~/Code`) |
| Return | resume the last project |
| Space | Ghostty quick terminal |
| / | cheat sheet |

### Status bar

SketchyBar runs on every display with the macOS menu bar set to auto-hide.
Left: workspace pills for that display and the front app. Center: the active
project with git status. Right: pomodoro, now playing, mic/camera in use, last
test run, clock, focus mode, weather, CPU/memory, battery, volume. The
reactive items hide themselves when idle.

When a display connects or disconnects, Hammerspoon restarts SketchyBar a
few seconds later. Without that, the bar on one screen keeps drawing the other
screen's items, dimmed, and stops updating.

When the pointer touches the top edge and the real menu bar slides down,
Hammerspoon hides SketchyBar until the pointer leaves the menu bar area, so
the two never overlap.

### Themes

`theme tokyo-night|catppuccin|kanagawa|rose-pine` (also in Raycast) writes the
palette that SketchyBar, borders, Ghostty, bat and fzf read, and reloads them.
Wallpaper is deliberately separate: `bin/set-wallpaper.sh [file]`.

### Project workflow

`start-coding <repo>` records the current project, warms Docker/OrbStack, opens
Chrome on web, T3 Code on code, a Ghostty in the repo on term, then follows the
editor. `project-test` runs the repo's test command (artisan, pnpm, bun, yarn,
npm or make) and reports PASS/FAIL in the bar. `pomodoro` drives the timer
item. `restore-session` rebuilds the standard window layout after login.

## How the files are wired

`bin/link.sh` symlinks each directory or file under `config/` to the path the
tool reads (`~/.config/sketchybar`, `~/.aerospace.toml`, `~/.hammerspoon`, and
so on; the full map is in `bin/lib.sh`). Anything already there is moved to
`~/omarchmymac-backup/<timestamp>/`. Because they are links, editing the live
config edits this repo, so there is nothing to sync back.

`~/.zshrc` is itself a link to `shell/zshrc`. Tokens and org-specific
settings are not in the repo: `~/.zshrc` sources `~/.zshrc.private` (mode
600), which `install.sh` creates from `shell/zshrc.private.example` if it is
missing. `bin/check.sh` fails if a token ever ends up in a tracked shell file.

`shell/omarchy.zsh` is sourced from `~/.zshrc`. It puts
`~/.config/omarchy-mac/bin` on PATH, exports the theme colours to bat and
fzf, and sets up starship, fzf, zoxide and the eza/bat aliases.

`config/omarchy-mac/state/` is runtime state and is git-ignored.

## Machine-specific bits to edit on a new Mac

- Monitor names come from `workspaces.conf` (the installer detects attached
  ones). The outer gaps for the external display in `aerospace.toml` and the
  wait for it in `omarchy-mac/bin/restore-session` still name `Smart M80C`.
- The app modal, session restore and `start-coding` are built around the
  apps in the Brewfile (Chrome, Zen, Slack, Ghostty, T3 Code, Docker). Swap
  in your own in `config/hammerspoon/init.lua`, `omarchy-mac/bin/*` and the
  `on-window-detected` rules.
- The theme wallpapers are generated and included. Any other wallpaper you
  drop into `config/omarchy-mac/wallpapers/` is yours to add; `purple-*` is
  git-ignored for that reason.
- Session restore expects Chrome, T3 Code, Slack, Zen and Ghostty; trim the
  list in `restore-session` if you do not use them.

## Scripts

| Script | Purpose |
|---|---|
| `install.sh` | Everything below, in order. Flags: `--skip-brew`, `--skip-defaults`, `--skip-wallpaper`. |
| `bin/link.sh` | Symlink configs into place, backing up what was there. |
| `bin/configure.sh` | Ask for workspaces and monitor names, write `workspaces.conf`, render. `--defaults` skips the questions. |
| `bin/render.sh` | Rewrite the workspace blocks in `aerospace.toml` from `workspaces.conf`. |
| `bin/macos-defaults.sh` | Menu bar auto-hide, dark mode, dock hidden, spaces span displays, Stage Manager off. |
| `bin/services.sh` | Start SketchyBar and borders via `brew services`, launch AeroSpace, Hammerspoon, Karabiner. |
| `bin/set-wallpaper.sh` | Set the desktop picture on every display. |
| `bin/check.sh` | Doctor: binaries, apps, font, links, services, defaults. Exit 1 if something is off. |

## Credits and licence

Built on [AeroSpace](https://github.com/nikitabobko/AeroSpace),
[SketchyBar](https://github.com/FelixKratz/SketchyBar),
[JankyBorders](https://github.com/FelixKratz/JankyBorders),
[Hammerspoon](https://www.hammerspoon.org),
[Karabiner-Elements](https://karabiner-elements.pqrs.org) and
[Ghostty](https://ghostty.org), inspired by [Omarchy](https://omarchy.org).
MIT licence, see `LICENSE`.
