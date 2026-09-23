local hyper = { "cmd", "ctrl", "alt", "shift" }
local root = os.getenv("HOME") .. "/.config/omarchy-mac"
local bin = root .. "/bin"
local state = root .. "/state"

require("hs.ipc")
hs.autoLaunch(true)
hs.dockIcon(false)
hs.window.animationDuration = 0

local function task(path, args, callback)
  hs.task.new(path, callback or function() end, args or {}):start()
end

local function aerospace(args)
  task("/opt/homebrew/bin/aerospace", args)
end

local function workspace(name)
  aerospace({ "workspace", name })
end

local function app(name)
  hs.application.launchOrFocus(name)
end

-- Workspaces come from ~/.config/omarchy-mac/workspaces.conf (bin/configure.sh).
local function readWorkspaces()
  local fallback = {
    { "web", "top", "w" }, { "code", "top", "c" }, { "term", "top", "t" },
    { "misc", "top", "m" }, { "chat", "bottom", "h" }, { "scratch", "bottom", "s" },
  }
  local file = io.open(root .. "/workspaces.conf", "r")
  if not file then return fallback end
  local content = file:read("*a")
  file:close()
  local spec = content:match('\nWORKSPACES="([^"]*)"') or content:match('^WORKSPACES="([^"]*)"')
  if not spec then return fallback end
  local list = {}
  for name, display, key in spec:gmatch("(%w+):(%w+):(%w)") do
    table.insert(list, { name, display, key })
  end
  return #list > 0 and list or fallback
end
local workspaces = readWorkspaces()

local workspaceBindings = {
  tab = { "last workspace", function() aerospace({ "workspace-back-and-forth" }) end },
}
local workspaceHints = {}
for _, ws in ipairs(workspaces) do
  local name, key = ws[1], ws[3]
  workspaceBindings[key] = { name, function() workspace(name) end }
  table.insert(workspaceHints, key .. " " .. name)
end

local appBindings = {
  w = { "Chrome", function() app("Google Chrome") end },
  c = { "T3 Code", function() app("T3 Code (Nightly)") end },
  t = { "Ghostty", function() app("Ghostty") end },
  h = { "Slack", function() app("Slack") end },
  f = { "Finder", function() app("Finder") end },
  d = { "Docker", function() app("Docker") end },
  m = { "Music", function() app("Music") end },
}

local function currentProject()
  local file = io.open(state .. "/current-project", "r")
  if not file then return nil end
  local path = file:read("*l")
  file:close()
  return path
end

local projectChooser = hs.chooser.new(function(choice)
  if choice and choice.path then
    task(bin .. "/start-coding", { choice.path })
  end
end)

local function projectChoices()
  local choices = {}
  local codeRoot = os.getenv("HOME") .. "/Code"
  for entry in hs.fs.dir(codeRoot) do
    if entry ~= "." and entry ~= ".." then
      local path = codeRoot .. "/" .. entry
      if hs.fs.attributes(path, "mode") == "directory" and hs.fs.attributes(path .. "/.git") then
        table.insert(choices, { text = entry, subText = path, path = path })
      end
    end
  end
  table.sort(choices, function(a, b) return a.text:lower() < b.text:lower() end)
  return choices
end

function omarchyProjectChooser()
  projectChooser:choices(projectChoices())
  projectChooser:placeholderText("Start coding…")
  projectChooser:searchSubText(true)
  projectChooser:show()
end

local function togglePomodoro()
  task(bin .. "/pomodoro", { "toggle" }, function(code)
    hs.alert.show(code == 0 and "Pomodoro toggled" or "Pomodoro failed")
  end)
end

local function runTests()
  task(bin .. "/project-test", {}, function(code)
    if code == 0 then hs.alert.show("Tests passed")
    elseif code == 64 then hs.alert.show("Choose a project first (Caps+P)")
    else hs.alert.show("Tests failed — click TST in the bar") end
  end)
end

local systemBindings = {
  l = { "lock", function() hs.caffeinate.lockScreen() end },
  s = { "sleep", function() hs.caffeinate.systemSleep() end },
  a = { "reload AeroSpace", function() aerospace({ "reload-config" }) end },
  b = { "reload SketchyBar", function() task("/opt/homebrew/bin/brew", { "services", "restart", "sketchybar" }) end },
  h = { "reload Hammerspoon", function() hs.reload() end },
  p = { "Pomodoro", togglePomodoro },
  t = { "run project tests", runTests },
}

local function musicTarget()
  if hs.application.get("com.spotify.client") then return "spotify" end
  return "music"
end

local mediaBindings = {
  p = { "play/pause", function()
    if musicTarget() == "spotify" then hs.spotify.playpause() else hs.itunes.playpause() end
  end },
  n = { "next", function()
    if musicTarget() == "spotify" then hs.spotify.next() else hs.itunes.next() end
  end },
  b = { "previous", function()
    if musicTarget() == "spotify" then hs.spotify.previous() else hs.itunes.previous() end
  end },
  u = { "volume up", function() hs.eventtap.event.newSystemKeyEvent("SOUND_UP", true):post() end },
  d = { "volume down", function() hs.eventtap.event.newSystemKeyEvent("SOUND_DOWN", true):post() end },
  m = { "open Music", function() app("Music") end },
}

local activeModal
local modalTimer
local function makeModal(title, bindings)
  local modal = hs.hotkey.modal.new()
  for key, value in pairs(bindings) do
    local function invoke()
      modal:exit()
      value[2]()
    end
    modal:bind({}, key, invoke)
    modal:bind(hyper, key, invoke)
  end
  modal:bind({}, "escape", function() modal:exit() end)
  modal:bind(hyper, "escape", function() modal:exit() end)
  function modal:entered()
    activeModal = modal
    local hints = {}
    for key, value in pairs(bindings) do table.insert(hints, key .. " " .. value[1]) end
    table.sort(hints)
    hs.alert.show(title .. "  ·  " .. table.concat(hints, "   "), 3)
    if modalTimer then modalTimer:stop() end
    modalTimer = hs.timer.doAfter(4, function() modal:exit() end)
  end
  function modal:exited()
    if activeModal == modal then activeModal = nil end
    if modalTimer then modalTimer:stop(); modalTimer = nil end
  end
  return modal
end

local workspaceModal = makeModal("WORKSPACES", workspaceBindings)
local appModal = makeModal("APPS", appBindings)
local systemModal = makeModal("SYSTEM", systemBindings)
local mediaModal = makeModal("MEDIA", mediaBindings)

hs.hotkey.bind(hyper, "w", function() workspaceModal:enter() end)
hs.hotkey.bind(hyper, "a", function() appModal:enter() end)
hs.hotkey.bind(hyper, "s", function() systemModal:enter() end)
hs.hotkey.bind(hyper, "m", function() mediaModal:enter() end)
hs.hotkey.bind(hyper, "p", omarchyProjectChooser)
hs.hotkey.bind(hyper, "return", function()
  local project = currentProject()
  if project then task(bin .. "/start-coding", { project }) else omarchyProjectChooser() end
end)

local cheatSheet = table.concat({
  "CAPS LEADER",
  "W  workspaces    A  apps    S  system    P  projects    M  media",
  "Space  quick terminal    Return  resume project    /  this help",
  "",
  "W → " .. table.concat(workspaceHints, " · "),
  "A → w Chrome · c T3 Code · t Ghostty · h Slack · f Finder · d Docker",
  "S → l lock · s sleep · a AeroSpace · b bar · h Hammerspoon · p timer · t tests",
  "M → p play/pause · n next · b previous · u/d volume",
}, "\n")
hs.hotkey.bind(hyper, "/", function() hs.alert.show(cheatSheet, { textSize = 16 }, 8) end)

local function writeIfChanged(path, value)
  local old
  local input = io.open(path, "r")
  if input then old = input:read("*a"); input:close() end
  if old == value then return false end
  local tmp = path .. ".tmp"
  local output = assert(io.open(tmp, "w"))
  output:write(value)
  output:close()
  os.rename(tmp, path)
  return true
end

local function safeText(value)
  return (value or ""):gsub("[|\n\r]", " ")
end

local function publishActivity()
  local mic = false
  local input = hs.audiodevice.defaultInputDevice()
  if input then mic = input:inUse() end
  local camera = false
  for _, device in ipairs(hs.camera.allCameras()) do
    if device:isInUse() then camera = true; break end
  end
  local changed = writeIfChanged(state .. "/privacy", (mic and "1" or "0") .. "|" .. (camera and "1" or "0") .. "\n")

  local player, playing, track, artist = "", false, "", ""
  if hs.application.get("com.spotify.client") then
    player = "Spotify"
    local ok, playback = pcall(hs.spotify.getPlaybackState)
    playing = ok and playback == hs.spotify.state_playing
    local trackOK, currentTrack = pcall(hs.spotify.getCurrentTrack)
    local artistOK, currentArtist = pcall(hs.spotify.getCurrentArtist)
    track, artist = trackOK and currentTrack or "", artistOK and currentArtist or ""
  elseif hs.application.get("com.apple.Music") then
    player = "Music"
    local ok, playback = pcall(hs.itunes.getPlaybackState)
    playing = ok and playback == hs.itunes.state_playing
    local trackOK, currentTrack = pcall(hs.itunes.getCurrentTrack)
    local artistOK, currentArtist = pcall(hs.itunes.getCurrentArtist)
    track, artist = trackOK and currentTrack or "", artistOK and currentArtist or ""
  end
  local media = table.concat({ player, playing and "1" or "0", safeText(track), safeText(artist) }, "|") .. "\n"
  changed = writeIfChanged(state .. "/media", media) or changed
  if changed then task("/opt/homebrew/bin/sketchybar", { "--trigger", "omarchy_activity_change" }) end
end

omarchyActivityTimer = hs.timer.doEvery(5, publishActivity)
publishActivity()

-- Hide SketchyBar while the auto-hidden macOS menu bar is revealed, so the two
-- bars never draw on top of each other. macOS reveals its bar when the pointer
-- touches a screen's top edge and hides it again once the pointer leaves that
-- strip, so mirror that with the pointer position.
local menuBarRevealed = false
local menuBarStrip = 44 -- px below the top edge that still counts as "in the menu bar"
local menuBarRevealCheck = nil

local function setSketchyBarHidden(hidden)
  if menuBarRevealed == hidden then return end
  menuBarRevealed = hidden
  task("/opt/homebrew/bin/sketchybar", { "--bar", "hidden=" .. (hidden and "on" or "off") })
end

local function pointerOffsetFromTop()
  local screen = hs.mouse.getCurrentScreen()
  if not screen then return nil end
  return hs.mouse.absolutePosition().y - screen:fullFrame().y
end

menuBarWatcher = hs.eventtap.new({
  hs.eventtap.event.types.mouseMoved,
  hs.eventtap.event.types.leftMouseDragged,
}, function()
  local offset = pointerOffsetFromTop()
  if not offset then return false end
  if not menuBarRevealed then
    -- Require the pointer to stay near the edge briefly so a quick flick past
    -- the top doesn't blink the bar.
    if offset <= 0 and not menuBarRevealCheck then
      menuBarRevealCheck = hs.timer.doAfter(0.15, function()
        menuBarRevealCheck = nil
        local now = pointerOffsetFromTop()
        if now and now <= menuBarStrip then setSketchyBarHidden(true) end
      end)
    end
  elseif offset > menuBarStrip then
    setSketchyBarHidden(false)
  end
  return false
end)
menuBarWatcher:start()

-- A reload while the bar was hidden must not leave it hidden.
task("/opt/homebrew/bin/sketchybar", { "--bar", "hidden=off" })

-- Unknown apps start floating at their natural size (the catch-all rule in
-- aerospace.toml). Anything large enough to be a real app window is promoted
-- to tiling a moment later; small or fixed-size windows such as installers,
-- DMG windows and preference panels keep their size and stay floating.
local tileMinWidth, tileMinHeight = 720, 520
-- Apps AeroSpace floats on purpose. Keep in sync with the floating rule in aerospace.toml.
local keepFloating = {
  ["com.apple.systempreferences"] = true,
  ["com.apple.calculator"] = true,
  ["com.1password.1password"] = true,
  ["com.apple.accessibility.universalAccessAuthWarn"] = true,
  ["com.apple.installer"] = true,
  ["com.apple.archiveutility"] = true,
  ["com.apple.DiskImageMounter"] = true,
}

local function isResizable(win)
  local ax = hs.axuielement.windowElement(win)
  if not ax then return true end
  local ok, settable = pcall(function() return ax:isAttributeSettable("AXSize") end)
  return not ok or settable ~= false
end

newWindowFilter = hs.window.filter.new()
newWindowFilter:subscribe(hs.window.filter.windowCreated, function(win)
  if not win or not win:isStandard() then return end
  local app = win:application()
  local bundle = app and app:bundleID() or ""
  if keepFloating[bundle] then return end
  local frame = win:frame()
  local small = frame.w <= tileMinWidth and frame.h <= tileMinHeight
  local resizable = isResizable(win)
  local verdict = (small or not resizable) and "keep floating" or "tile"
  print(string.format("new window: %s %dx%d resizable=%s -> %s", bundle, frame.w, frame.h, tostring(resizable), verdict))
  if verdict == "tile" then
    hs.task.new("/opt/homebrew/bin/aerospace", nil, { "layout", "tiling", "--window-id", tostring(win:id()) }):start()
  end
end)

-- SketchyBar's bars go stale when a display connects or disconnects: the bar
-- on one screen keeps drawing the other screen's items, dimmed, and stops
-- updating. A clean restart once the change has settled puts it right.
local sketchybarRestartTimer = nil
screenWatcher = hs.screen.watcher.new(function()
  if sketchybarRestartTimer then sketchybarRestartTimer:stop() end
  sketchybarRestartTimer = hs.timer.doAfter(3, function()
    sketchybarRestartTimer = nil
    task("/bin/zsh", { "-c", "launchctl kickstart -k gui/$UID/homebrew.mxcl.sketchybar" })
  end)
end)
screenWatcher:start()

hs.alert.show("Caps leader loaded  ·  Caps+/ for help", 3)
