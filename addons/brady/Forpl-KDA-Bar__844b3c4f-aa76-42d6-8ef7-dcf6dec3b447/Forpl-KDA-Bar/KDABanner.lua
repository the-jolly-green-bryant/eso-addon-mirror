--[[ KDA Banner
     A movable on-screen Kill / Death / Assist counter for PvP.

     Kills   : your own PvP killing blows (ACTION_RESULT_KILLING_BLOW where you are
               the source). These are exactly the kills ESO prints to chat.
     Assists : any enemy you dealt damage to that then dies. We "tag" every enemy
               you hit, and when that tagged enemy gets a killing blow from someone
               other than you, it counts as an assist.
     Deaths  : your own deaths (EVENT_UNIT_DEATH_STATE_CHANGED on the player).

     NOTE on assists: when *someone else* lands the killing blow, ESO's API does not
     fire the event until the victim respawns, which can be many seconds later. The
     assist window below is how long after you damaged an enemy we will still credit
     you. Tune it with: /kda window <seconds>
--]]

KDABanner = {}
local KDA = KDABanner

-- IMPORTANT: must match the addon folder / manifest name (Forpl-KDA-Bar), because
-- EVENT_ADD_ON_LOADED reports that name. The global table stays KDABanner so the
-- keybinds in Bindings.xml (KDABanner.ToggleLock(), ...) keep working.
KDA.name    = "Forpl-KDA-Bar"
KDA.version = "1.0.0"

-- Use the accessor functions, not the WINDOW_MANAGER/EVENT_MANAGER globals:
-- the globals aren't reliably present on the console add-on system.
local EM = GetEventManager()
local WM = GetWindowManager()

-- runtime (session) counters -------------------------------------------------
KDA.kills   = 0
KDA.deaths  = 0
KDA.assists = 0

-- enemies you have damaged recently: [normalizedName] = expireTimeMs
KDA.tagged  = {}

local defaults = {
    posLeft   = nil,
    posTop    = nil,
    locked    = false,
    hidden    = false,
    scale     = 1.0,        -- banner size multiplier
    assistSec = 60,         -- assist credit window, in seconds
    colKill   = { 0.40, 1.00, 0.40 },   -- K text color (green)
    colDeath  = { 1.00, 0.33, 0.33 },   -- D text color (red)
    colAssist = { 1.00, 0.80, 0.27 },   -- A text color (yellow)
}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------
local function Normalize(name)
    if not name or name == "" then return "" end
    -- strip ESO name formatting and lowercase for reliable comparison
    return zo_strlower(zo_strformat("<<1>>", name))
end

local function Now()
    return GetGameTimeMilliseconds()
end

local function Print(msg)
    d("|cffcc44[KDA]|r " .. msg)
end

-- {r,g,b} (0-1) -> "rrggbb" hex for ESO inline color codes
local function Hex(c)
    local function ch(v)
        v = math.floor((v or 0) * 255 + 0.5)
        if v < 0 then v = 0 elseif v > 255 then v = 255 end
        return v
    end
    return string.format("%02x%02x%02x", ch(c[1]), ch(c[2]), ch(c[3]))
end

-- ---------------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------------
function KDA.UpdateLabel()
    if not KDA.label then return end
    local k, dd, a = KDA.sv.colKill, KDA.sv.colDeath, KDA.sv.colAssist
    KDA.label:SetText(string.format(
        "|c%sK|r %d   |c%sD|r %d   |c%sA|r %d",
        Hex(k), KDA.kills, Hex(dd), KDA.deaths, Hex(a), KDA.assists))
end

-- quick scale "pop" when a counter changes (cosmetic; guarded so it can never
-- break counting if zo_callLater is unavailable)
local function Pulse()
    local l = KDA.label
    if not l then return end
    if type(zo_callLater) ~= "function" then return end
    l:SetScale(1.30)
    zo_callLater(function() if KDA.label then KDA.label:SetScale(1.0) end end, 150)
end

function KDA.OnMoveStop()
    local w = KDA.window
    if not w then return end
    KDA.sv.posLeft = w:GetLeft()
    KDA.sv.posTop  = w:GetTop()
end

-- (re)anchor the banner from saved coordinates; used on load and by the
-- settings sliders (console has no drag, so position is set numerically)
function KDA.ApplyPosition()
    local w = KDA.window
    if not w then return end
    w:ClearAnchors()
    if KDA.sv.posLeft and KDA.sv.posTop then
        w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KDA.sv.posLeft, KDA.sv.posTop)
    else
        w:SetAnchor(TOP, GuiRoot, TOP, 0, 110)
    end
end

function KDA.ApplyScale()
    if KDA.window then KDA.window:SetScale(KDA.sv.scale or 1.0) end
end

-- live preview: while the settings panel is open, force the banner visible and
-- show the bright outline so it can be positioned (vital on console - no drag).
function KDA.SetPreview(active)
    local w = KDA.window
    if not w then return end
    if active then
        w:SetHidden(false)
        if KDA.outline then KDA.outline:SetHidden(false) end
    else
        if KDA.outline then KDA.outline:SetHidden(true) end
        w:SetHidden(KDA.sv.hidden)
    end
    KDA.UpdateLabel()
end

local function BuildUI()
    local w = WM:CreateTopLevelControl("KDABanner_Window")
    w:SetDimensions(230, 58)
    w:SetMouseEnabled(true)
    w:SetMovable(not KDA.sv.locked)
    w:SetClampedToScreen(true)
    w:SetHandler("OnMoveStop", KDA.OnMoveStop)

    -- bright outline shown only while the settings panel is open (live preview),
    -- sits behind the panel and pokes out a few px to form a ring
    local outline = WM:CreateControl("KDABanner_Window_Preview", w, CT_BACKDROP)
    outline:SetAnchor(TOPLEFT, w, TOPLEFT, -3, -3)
    outline:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, 3, 3)
    outline:SetCenterColor(1, 0.85, 0.2, 0.25)
    outline:SetEdgeColor(1, 0.85, 0.2, 0.9)
    outline:SetDrawLevel(0)
    outline:SetHidden(true)

    local bg = WM:CreateControl("KDABanner_Window_BG", w, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, w, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.55)
    bg:SetEdgeColor(0.35, 0.35, 0.35, 0.8)
    bg:SetDrawLevel(1)

    local label = WM:CreateControl("KDABanner_Window_Label", w, CT_LABEL)
    label:SetFont("ZoFontWinH1")
    label:SetAnchor(CENTER, w, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLevel(2)

    -- hint shown only when unlocked, so you know it's grab-able
    local hint = WM:CreateControl("KDABanner_Window_Hint", w, CT_LABEL)
    hint:SetFont("ZoFontGameSmall")
    hint:SetColor(1, 0.85, 0.4, 1)
    hint:SetText("KDA Bar - drag to move, then lock")
    hint:SetAnchor(BOTTOM, w, TOP, 0, -2)
    hint:SetHidden(true)

    KDA.window  = w
    KDA.label   = label
    KDA.outline = outline
    KDA.hint    = hint

    KDA.ApplyPosition()
    KDA.ApplyScale()
    w:SetHidden(KDA.sv.hidden)

    KDA.UpdateLabel()
end

-- ---------------------------------------------------------------------------
-- lock / show (used by keybinds and slash commands)
-- When unlocked the bar is mouse-grabbable (drag to move) and shows the outline
-- + hint; when locked it's click-through so it never interferes in combat.
-- ---------------------------------------------------------------------------
function KDA.SetLocked(locked)
    KDA.sv.locked = locked
    local w = KDA.window
    if not w then return end
    w:SetMovable(not locked)
    w:SetMouseEnabled(not locked)
    if KDA.outline then KDA.outline:SetHidden(locked) end
    if KDA.hint then KDA.hint:SetHidden(locked) end
    if not locked then
        Print("unlocked - drag to move. Lock again (keybind or /kda lock) when done.")
    end
end

function KDA.ToggleLock()
    KDA.SetLocked(not KDA.sv.locked)
end

function KDA.ToggleShown()
    KDA.sv.hidden = not KDA.sv.hidden
    if KDA.window then KDA.window:SetHidden(KDA.sv.hidden) end
end

-- ---------------------------------------------------------------------------
-- counters
-- ---------------------------------------------------------------------------
local function AddKill()   KDA.kills   = KDA.kills   + 1; KDA.UpdateLabel(); Pulse() end
local function AddDeath()  KDA.deaths  = KDA.deaths  + 1; KDA.UpdateLabel(); Pulse() end
local function AddAssist() KDA.assists = KDA.assists + 1; KDA.UpdateLabel(); Pulse() end

function KDA.Reset()
    KDA.kills, KDA.deaths, KDA.assists = 0, 0, 0
    KDA.tagged = {}
    KDA.UpdateLabel()
end

-- ---------------------------------------------------------------------------
-- combat handling
-- ---------------------------------------------------------------------------

-- Registration A: events where YOU are the source (filtered by source unit type).
-- Used to (1) record your own killing blows as kills and (2) tag every enemy you
-- damage so they can later become an assist.
function KDA.OnPlayerSourceCombat(_, result, isError, _, _, _, sourceName, sourceType,
                                  targetName, targetType, hitValue, _, _, _, _, _, _)
    if isError then return end
    if not targetName or targetName == "" then return end

    local tname = Normalize(targetName)

    if result == ACTION_RESULT_KILLING_BLOW then
        -- you landed the killing blow -> it's a kill, not an assist
        KDA.tagged[tname] = nil
        AddKill()
    elseif hitValue and hitValue > 0 then
        -- you dealt damage to this target -> tag it for the assist window
        KDA.tagged[tname] = Now() + (KDA.sv.assistSec * 1000)
    end
end

-- Registration B: every killing blow, from anyone (filtered by combat result).
-- If the victim is one you tagged and the killer was NOT you -> assist.
function KDA.OnAnyKillingBlow(_, result, isError, _, _, _, sourceName, _,
                              targetName, _, _, _, _, _, _, _, _)
    if isError then return end

    local sname = Normalize(sourceName)
    if sname == KDA.playerName then return end   -- your own KB handled in registration A

    local tname = Normalize(targetName)
    local expire = KDA.tagged[tname]
    if expire and Now() <= expire then
        KDA.tagged[tname] = nil
        AddAssist()
    end
end

-- your own death
function KDA.OnDeathStateChanged(_, unitTag, isDead)
    if unitTag == "player" and isDead then
        AddDeath()
    end
end

-- periodically drop expired tags so the table cannot grow unbounded
local function PruneTags()
    local now = Now()
    for name, expire in pairs(KDA.tagged) do
        if now > expire then KDA.tagged[name] = nil end
    end
end

-- ---------------------------------------------------------------------------
-- slash commands
-- ---------------------------------------------------------------------------
local function SlashHandler(args)
    args = zo_strlower(args or "")
    local cmd, rest = zo_strmatch(args, "^(%S*)%s*(.*)$")

    if cmd == "reset" then
        KDA.Reset()
        Print("counters reset.")
    elseif cmd == "lock" then
        KDA.SetLocked(true)
        Print("banner locked.")
    elseif cmd == "unlock" then
        KDA.SetLocked(false)
    elseif cmd == "show" then
        KDA.sv.hidden = false
        if KDA.window then KDA.window:SetHidden(false) end
    elseif cmd == "hide" then
        KDA.sv.hidden = true
        if KDA.window then KDA.window:SetHidden(true) end
    elseif cmd == "window" then
        local n = tonumber(rest)
        if n and n > 0 then
            KDA.sv.assistSec = n
            Print("assist window set to " .. n .. "s.")
        else
            Print("assist window is " .. KDA.sv.assistSec .. "s. Use: /kda window <seconds>")
        end
    else
        Print("commands: reset | lock | unlock | show | hide | window <seconds>")
    end
end

-- ---------------------------------------------------------------------------
-- init
-- ---------------------------------------------------------------------------
local function Initialize()
    KDA.sv = ZO_SavedVars:NewAccountWide("KDABannerSavedVars", 1, nil, defaults)
    KDA.playerName = Normalize(GetUnitName("player"))

    BuildUI()
    KDA.SetLocked(KDA.sv.locked)   -- apply movable/mouse/outline/hint state

    -- A: your outgoing combat (tag damage + your killing blows)
    EM:RegisterForEvent(KDA.name .. "_Src", EVENT_COMBAT_EVENT, KDA.OnPlayerSourceCombat)
    EM:AddFilterForEvent(KDA.name .. "_Src", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- B: all killing blows (for assist detection)
    EM:RegisterForEvent(KDA.name .. "_KB", EVENT_COMBAT_EVENT, KDA.OnAnyKillingBlow)
    EM:AddFilterForEvent(KDA.name .. "_KB", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)

    -- your deaths
    EM:RegisterForEvent(KDA.name .. "_Death", EVENT_UNIT_DEATH_STATE_CHANGED, KDA.OnDeathStateChanged)
    EM:AddFilterForEvent(KDA.name .. "_Death", EVENT_UNIT_DEATH_STATE_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    -- prune expired tags every 5s
    EM:RegisterForUpdate(KDA.name .. "_Prune", 5000, PruneTags)

    SLASH_COMMANDS["/kda"] = SlashHandler

    -- optional LibAddonMenu settings panel for PC users who have the library;
    -- console uses the keybinds below instead (no library needed).
    if KDA.SetupSettings then KDA.SetupSettings() end

    Print("v" .. KDA.version .. " loaded. Move it: bind keys in Settings > Controls" ..
          " > Keybindings > Forpl KDA Bar, or use /kda.")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= KDA.name then return end
    EM:UnregisterForEvent(KDA.name, EVENT_ADD_ON_LOADED)
    Initialize()
end

EM:RegisterForEvent(KDA.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Keybind display names, referenced by Bindings.xml (shown in the Keybindings menu)
ZO_CreateStringId("SI_BINDING_NAME_KDA_TOGGLE_LOCK", "Lock / Unlock bar (move)")
ZO_CreateStringId("SI_BINDING_NAME_KDA_TOGGLE_SHOW", "Show / Hide bar")
ZO_CreateStringId("SI_BINDING_NAME_KDA_RESET",       "Reset K / D / A")
