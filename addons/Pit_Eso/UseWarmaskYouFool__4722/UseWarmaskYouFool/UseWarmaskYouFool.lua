-- =====================================================================
--  Use Warmask you Fool
--  Tracks Huntsman's Warmask (Mark of Hircine) uptime in combat and
--  screams at you with a big, customizable warning when it drops.
-- =====================================================================

UseWarmaskYouFool = {}
local WYF   = UseWarmaskYouFool
WYF.name        = "UseWarmaskYouFool"
WYF.displayName = "Use Warmask you Fool"
WYF.version     = "1.4.1"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

-- ---------------------------------------------------------------------
--  Defaults
-- ---------------------------------------------------------------------
local defaults = {
    enabled       = true,
    warnOnStart   = true,     -- warn if it is NOT up when combat starts
    warnOnExpire  = true,     -- warn if it drops while in combat
    graceMs       = 1500,     -- grace period after combat start before the "missing" warning fires

    -- What counts as "Warmask". Name = case-insensitive substring match.
    -- Default catches "Mark of Hircine" (the tracked effect) and "Warmask".
    trackNames    = "Hircine,Warmask",
    trackIds      = "",       -- optional: comma separated ability IDs (locale-proof)
    learnMode     = false,    -- print every player-sourced effect to chat to find the right name/ID

    -- Only act while the Warmask set is actually worn (helm is only on for bosses)
    onlyWhenEquipped = true,
    helmSetName      = "Warmask",   -- set-name substring(s) used to detect the helm

    -- Tracker (small icon + timer)
    trackerEnabled = true,
    trackerSize    = 48,
    trackerPos     = { x = 0, y = -260 },

    -- Warning look
    warnText     = "REAPPLY NOW",
    warnFontSize = 64,
    warnColor    = { 1, 0.10, 0.10, 1 },
    warnSoundStart  = "ABILITY_ULTIMATE_READY",  -- sound when missing at combat start
    warnSoundExpire = "GENERAL_ALERT_ERROR",     -- sound when it drops during combat
    warnSoundRepeat   = false,   -- repeat the sound while the warning is showing?
    warnSoundInterval = 1.5,     -- seconds between repeats
    warnBlink    = true,
    warnAutoHide = 0,         -- seconds; 0 = stay until you reapply / leave combat

    -- Up to 4 warning locations
    warnEnabled = { true, false, false, false },
    warnPos = {
        { x = 0,    y = -150 },
        { x = 0,    y =  190 },
        { x = -430, y =   0  },
        { x = 430,  y =   0  },
    },
}

-- ---------------------------------------------------------------------
--  State
-- ---------------------------------------------------------------------
WYF.inCombat    = false
WYF.active      = {}          -- unitId -> endTime (seconds)
WYF.icon        = "/esoui/art/icons/u48_mythic_collect_1.dds"   -- Warmask mask fallback; replaced by the worn item's real icon in RefreshEquipped
WYF.trackBegin  = 0           -- beginTime (s) of the current proc
WYF.trackEnd    = 0           -- endTime (s) of the current proc
WYF.wasActive   = false
WYF.equipped    = false       -- is the Warmask set currently worn?
WYF.unlocked    = false
WYF.combatToken = 0
WYF.warnToken   = 0
WYF.expireToken = 0

local EXPIRE_DEBOUNCE_MS = 500   -- wait this long before the "expired" warning, so a boss dying (buff fades as the fight ends) does not flash a warning

-- ---------------------------------------------------------------------
--  Helpers
-- ---------------------------------------------------------------------
local function now()
    return GetGameTimeMilliseconds() / 1000
end

local nameMatchers    = {}
local idMatchers      = {}
local setNameMatchers = {}

local function buildMatchers()
    nameMatchers = {}
    for token in string.gmatch(WYF.sv.trackNames or "", "([^,]+)") do
        local name = zo_strlower(zo_strtrim(token))
        if name ~= "" then table.insert(nameMatchers, name) end
    end
    idMatchers = {}
    for token in string.gmatch(WYF.sv.trackIds or "", "([^,]+)") do
        local id = tonumber(zo_strtrim(token))
        if id then idMatchers[id] = true end
    end
    setNameMatchers = {}
    for token in string.gmatch(WYF.sv.helmSetName or "", "([^,]+)") do
        local name = zo_strlower(zo_strtrim(token))
        if name ~= "" then table.insert(setNameMatchers, name) end
    end
end

-- Gear slots to scan for the Warmask set (mythic mask is the head slot; the
-- rest are cheap insurance and only scanned on gear change / combat start).
local GEAR_SLOTS = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
}

-- returns: equipped(bool), maskIcon(string|nil) -- the icon of the worn Warmask item
local function scanWarmask()
    if #setNameMatchers == 0 then return true, nil end   -- misconfigured -> don't block
    for i = 1, #GEAR_SLOTS do
        local link = GetItemLink(BAG_WORN, GEAR_SLOTS[i])
        if link and link ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(link, false)
            if hasSet and setName and setName ~= "" then
                local lname = zo_strlower(setName)
                for j = 1, #setNameMatchers do
                    if string.find(lname, setNameMatchers[j], 1, true) then
                        return true, GetItemLinkIcon(link)
                    end
                end
            end
        end
    end
    return false, nil
end

function WYF.RefreshEquipped()
    local equipped, maskIcon = scanWarmask()
    WYF.equipped = equipped
    if maskIcon and maskIcon ~= "" then WYF.icon = maskIcon end   -- real mask/helm icon
    if WYF.RefreshTrackerDisplay then WYF.RefreshTrackerDisplay() end
end

local function isMatch(effectName, abilityId)
    if abilityId and idMatchers[abilityId] then return true end
    if effectName and effectName ~= "" then
        local lname = zo_strlower(effectName)
        for i = 1, #nameMatchers do
            if string.find(lname, nameMatchers[i], 1, true) then return true end
        end
    end
    return false
end

-- returns anyActive(bool), maxEndTime
local function computeActive()
    local t = now()
    local anyActive, maxEnd = false, 0
    for unitId, endTime in pairs(WYF.active) do
        if endTime and endTime > t then
            anyActive = true
            if endTime > maxEnd then maxEnd = endTime end
        else
            WYF.active[unitId] = nil
        end
    end
    return anyActive, maxEnd
end

-- ---------------------------------------------------------------------
--  Position save / apply (relative to screen centre)
-- ---------------------------------------------------------------------
function WYF.SavePos(control, saved)
    local cx, cy = control:GetCenter()
    local gx, gy = GuiRoot:GetCenter()
    saved.x = zo_round(cx - gx)
    saved.y = zo_round(cy - gy)
end

function WYF.ApplyPos(control, saved)
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, saved.x or 0, saved.y or 0)
end

-- ---------------------------------------------------------------------
--  Tracker UI  (framed mask + two-phase countdown, à la "Cooldowns")
--  Phase 1 = first 10s after (re)applying  -> bright mask, green 10..1
--  Phase 2 = remaining ~50s                -> desaturated mask, 50..1
-- ---------------------------------------------------------------------
local FIRST_PHASE_S    = 10
local TRACKER_FRAME_TEX = "/esoui/art/actionbar/abilityframe64_up.dds"

function WYF.ApplyTrackerSize()
    local s = WYF.sv.trackerSize
    WYF.trackerTLC:SetDimensions(s, s)
    WYF.trackerLabel:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline", math.max(14, math.floor(s * 0.46))))
end

function WYF.RefreshTrackerDisplay()
    if WYF.unlocked then return end
    local anyActive = computeActive()
    local equipOk = (not WYF.sv.onlyWhenEquipped) or WYF.equipped
    local show = WYF.sv.enabled and WYF.sv.trackerEnabled and WYF.inCombat and anyActive and equipOk
    if not show then
        WYF.trackerTLC:SetHidden(true)
        return
    end
    WYF.trackerTLC:SetHidden(false)
    WYF.trackerIcon:SetTexture(WYF.icon)

    local nowT      = now()
    local endT      = WYF.trackEnd or 0
    local beginT    = WYF.trackBegin or (endT - 60)
    local remaining = endT - nowT
    if remaining < 0 then remaining = 0 end
    local elapsed   = nowT - beginT

    if elapsed < FIRST_PHASE_S then
        -- fresh: bright mask, green number counting the first 10s down
        WYF.trackerIcon:SetDesaturation(0)
        WYF.trackerIcon:SetColor(1, 1, 1, 1)
        WYF.trackerLabel:SetColor(0.35, 1, 0.35, 1)
        WYF.trackerLabel:SetText(string.format("%d", math.max(1, math.ceil(FIRST_PHASE_S - elapsed))))
    else
        -- reapply window: desaturated mask, remaining seconds (red for the last 5s)
        WYF.trackerIcon:SetDesaturation(1)
        WYF.trackerIcon:SetColor(0.75, 0.75, 0.75, 1)
        if remaining <= 5 then
            WYF.trackerLabel:SetColor(1, 0.25, 0.25, 1)
        else
            WYF.trackerLabel:SetColor(1, 1, 1, 1)
        end
        WYF.trackerLabel:SetText(string.format("%d", math.ceil(remaining)))
    end
end

local function createTracker()
    local tlc = WM:CreateTopLevelWindow(WYF.name .. "Tracker")
    tlc:SetClampedToScreen(true)
    tlc:SetMovable(false)
    tlc:SetMouseEnabled(false)
    tlc:SetDrawLayer(DL_OVERLAY)
    tlc:SetDrawTier(DT_HIGH)
    tlc:SetHidden(true)

    -- dark box behind the mask
    local bg = WM:CreateControl(WYF.name .. "TrackerBg", tlc, CT_TEXTURE)
    bg:SetColor(0, 0, 0, 0.6)
    bg:SetAnchorFill(tlc)
    bg:SetDrawLevel(1)
    WYF.trackerBg = bg

    -- the mask
    local icon = WM:CreateControl(WYF.name .. "TrackerIcon", tlc, CT_TEXTURE)
    icon:SetAnchorFill(tlc)
    icon:SetTexture(WYF.icon)
    icon:SetDrawLevel(2)
    WYF.trackerIcon = icon

    -- the frame / "kasten" around it
    local frame = WM:CreateControl(WYF.name .. "TrackerFrame", tlc, CT_TEXTURE)
    frame:SetAnchorFill(tlc)
    frame:SetTexture(TRACKER_FRAME_TEX)
    frame:SetDrawLevel(3)
    WYF.trackerFrame = frame

    -- countdown number, centred on the mask
    local label = WM:CreateControl(WYF.name .. "TrackerLabel", tlc, CT_LABEL)
    label:SetColor(1, 1, 1, 1)
    label:SetAnchor(CENTER, tlc, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLevel(4)
    label:SetText("")
    WYF.trackerLabel = label

    tlc:SetHandler("OnMoveStop", function() WYF.SavePos(tlc, WYF.sv.trackerPos) end)
    tlc:SetHandler("OnUpdate", function()
        local t = GetGameTimeMilliseconds()
        if t - (WYF.trackerLastUpdate or 0) < 50 then return end
        WYF.trackerLastUpdate = t
        WYF.RefreshTrackerDisplay()
    end)

    WYF.trackerTLC = tlc
    WYF.ApplyTrackerSize()
    WYF.ApplyPos(tlc, WYF.sv.trackerPos)
end

-- ---------------------------------------------------------------------
--  Warning UI (up to 4 frames)
-- ---------------------------------------------------------------------
WYF.warnFrames = {}

function WYF.ApplyWarnStyle()
    local font = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", WYF.sv.warnFontSize)
    local c = WYF.sv.warnColor
    local w = math.max(300, WYF.sv.warnFontSize * 14)
    local h = math.max(60,  WYF.sv.warnFontSize * 2)
    for i = 1, 4 do
        local f = WYF.warnFrames[i]
        if f then
            f:SetDimensions(w, h)
            f.label:SetFont(font)
            f.label:SetColor(c[1], c[2], c[3], c[4] or 1)
            if not WYF.unlocked then f.label:SetText(WYF.sv.warnText) end
        end
    end
end

function WYF.StartBlink(f)
    if not f.blink then
        local anim, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, f.label)
        anim:SetAlphaValues(1, 0.15)
        anim:SetDuration(420)
        timeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
        f.blink = timeline
    end
    f.label:SetAlpha(1)
    f.blink:PlayFromStart()
end

function WYF.StopBlink(f)
    if f.blink then f.blink:Stop() end
    f.label:SetAlpha(1)
end

local function createWarnings()
    for i = 1, 4 do
        local f = WM:CreateTopLevelWindow(WYF.name .. "Warn" .. i)
        f:SetClampedToScreen(true)
        f:SetMovable(false)
        f:SetMouseEnabled(false)
        f:SetDrawLayer(DL_OVERLAY)
        f:SetDrawTier(DT_HIGH)
        f:SetHidden(true)

        local bg = WM:CreateControl(WYF.name .. "Warn" .. i .. "Bg", f, CT_TEXTURE)
        bg:SetColor(0, 0, 0, 0.4)
        bg:SetAnchorFill(f)
        bg:SetHidden(true)
        f.bg = bg

        local label = WM:CreateControl(WYF.name .. "Warn" .. i .. "Label", f, CT_LABEL)
        label:SetAnchorFill(f)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetText(WYF.sv.warnText)
        f.label = label

        f:SetHandler("OnMoveStop", function() WYF.SavePos(f, WYF.sv.warnPos[i]) end)

        WYF.warnFrames[i] = f
        WYF.ApplyPos(f, WYF.sv.warnPos[i])
    end
    WYF.ApplyWarnStyle()
end

local function playSoundKey(key)
    if key and key ~= "None" and SOUNDS[key] then
        PlaySound(SOUNDS[key])
    end
end

local function soundKeyFor(reason)
    if reason == "start" then return WYF.sv.warnSoundStart end
    return WYF.sv.warnSoundExpire
end

-- reason: "start" | "expire" | "test"
function WYF.PlayWarnSound(reason)
    playSoundKey(soundKeyFor(reason))
end

function WYF.StopSoundLoop()
    EM:UnregisterForUpdate(WYF.name .. "SoundLoop")
end

function WYF.StartSoundLoop(reason)
    WYF.StopSoundLoop()
    if not WYF.sv.warnSoundRepeat then return end
    local key = soundKeyFor(reason)
    if not key or key == "None" or not SOUNDS[key] then return end
    local intervalMs = math.max(500, math.floor((WYF.sv.warnSoundInterval or 1.5) * 1000))
    -- First tone already played by PlayWarnSound; RegisterForUpdate handles the repeats.
    EM:RegisterForUpdate(WYF.name .. "SoundLoop", intervalMs, function() playSoundKey(key) end)
end

-- reason: "start" | "expire" | "test"   (drives which sound plays)
-- force = ignore the master "enabled" toggle (used by the preview button)
function WYF.TriggerWarning(reason, force)
    if not force and not WYF.sv.enabled then return end
    local shown = false
    for i = 1, 4 do
        if WYF.sv.warnEnabled[i] then
            local f = WYF.warnFrames[i]
            f.label:SetText(WYF.sv.warnText)
            f:SetHidden(false)
            if WYF.sv.warnBlink then WYF.StartBlink(f) end
            shown = true
        end
    end
    if not shown then return end

    WYF.PlayWarnSound(reason)
    WYF.StartSoundLoop(reason)

    if WYF.sv.warnAutoHide and WYF.sv.warnAutoHide > 0 then
        WYF.warnToken = WYF.warnToken + 1
        local token = WYF.warnToken
        zo_callLater(function()
            if token == WYF.warnToken then WYF.HideWarnings() end
        end, WYF.sv.warnAutoHide * 1000)
    end
end

function WYF.HideWarnings()
    WYF.warnToken = WYF.warnToken + 1     -- invalidate any pending auto-hide
    WYF.StopSoundLoop()
    if WYF.unlocked then return end
    for i = 1, 4 do
        local f = WYF.warnFrames[i]
        if f then
            WYF.StopBlink(f)
            f:SetHidden(true)
        end
    end
end

-- ---------------------------------------------------------------------
--  Core logic
-- ---------------------------------------------------------------------
function WYF.Evaluate()
    local anyActive = computeActive()
    if anyActive then
        WYF.wasActive = true
        WYF.HideWarnings()
    else
        if WYF.wasActive and WYF.inCombat and WYF.sv.warnOnExpire then
            -- Debounce: only warn if we are STILL in combat and STILL missing it
            -- after a short delay. If the boss just died, the combat-end event
            -- arrives inside this window and cancels the warning.
            WYF.expireToken = WYF.expireToken + 1
            local token = WYF.expireToken
            zo_callLater(function()
                if token == WYF.expireToken and WYF.sv.enabled and WYF.inCombat
                   and WYF.sv.warnOnExpire and not computeActive()
                   and ((not WYF.sv.onlyWhenEquipped) or WYF.equipped) then
                    WYF.TriggerWarning("expire")
                end
            end, EXPIRE_DEBOUNCE_MS)
        end
        WYF.wasActive = false
    end
    WYF.RefreshTrackerDisplay()
end

function WYF.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag,
                             beginTime, endTime, stackCount, iconName, buffType,
                             effectType, abilityType, statusEffectType, unitName,
                             unitId, abilityId, sourceType)
    if WYF.sv.learnMode then
        d(string.format("|cFFD700[Warmask learn]|r %s  |cAAAAAAid|r %d  |cAAAAAAchange|r %d  |cAAAAAAunit|r %s",
            tostring(effectName), abilityId or 0, changeType, tostring(unitTag)))
    end

    if not isMatch(effectName, abilityId) then return end

    if changeType == EFFECT_RESULT_FADED then
        WYF.active[unitId] = nil
    else
        WYF.active[unitId] = endTime
        WYF.trackBegin = beginTime
        WYF.trackEnd   = endTime
        -- Note: we deliberately do NOT use the effect's iconName here (that is the
        -- Mark-of-Hircine "eye" symbol). The tracker shows the actual mask/helm
        -- icon, captured from the worn item in WYF.RefreshEquipped().
    end
    WYF.Evaluate()
end

function WYF.OnCombatState(_, inCombat)
    WYF.inCombat = inCombat
    if inCombat then
        WYF.RefreshEquipped()      -- make sure we know if the helm is on right now
        WYF.combatToken = WYF.combatToken + 1
        local token = WYF.combatToken
        if computeActive() then WYF.wasActive = true end
        if WYF.sv.enabled and WYF.sv.warnOnStart then
            zo_callLater(function()
                if WYF.inCombat and token == WYF.combatToken and not computeActive()
                   and ((not WYF.sv.onlyWhenEquipped) or WYF.equipped) then
                    WYF.TriggerWarning("start")
                end
            end, WYF.sv.graceMs)
        end
        WYF.RefreshTrackerDisplay()
    else
        -- Combat over (e.g. boss dead): cancel any pending expire warning and hide.
        WYF.expireToken = WYF.expireToken + 1
        WYF.HideWarnings()
        WYF.wasActive = false
        WYF.active = {}
        WYF.RefreshTrackerDisplay()
    end
end

-- ---------------------------------------------------------------------
--  Unlock / lock (drag frames to place them)
-- ---------------------------------------------------------------------
function WYF.SetUnlocked(state)
    WYF.unlocked = state

    local tlc = WYF.trackerTLC
    tlc:SetMovable(state)
    tlc:SetMouseEnabled(state)
    if state then
        tlc:SetHidden(false)
        WYF.trackerIcon:SetTexture(WYF.icon)
        WYF.trackerIcon:SetDesaturation(0)
        WYF.trackerIcon:SetColor(1, 1, 1, 1)
        WYF.trackerLabel:SetColor(0.35, 1, 0.35, 1)
        WYF.trackerLabel:SetText("10")
    end

    for i = 1, 4 do
        local f = WYF.warnFrames[i]
        f:SetMovable(state)
        f:SetMouseEnabled(state)
        f.bg:SetHidden(not state)
        WYF.StopBlink(f)
        if state then
            f.label:SetText(WYF.sv.warnText .. "  [" .. i .. "]")
            f:SetHidden(false)
        else
            f.label:SetText(WYF.sv.warnText)
            f:SetHidden(true)
        end
    end

    if not state then WYF.RefreshTrackerDisplay() end
    if LibAddonMenu2 and LibAddonMenu2.util and WYF.panel then
        -- keep the settings checkbox in sync if it is open
    end
end

function WYF.ResetPositions()
    WYF.sv.trackerPos = { x = defaults.trackerPos.x, y = defaults.trackerPos.y }
    WYF.ApplyPos(WYF.trackerTLC, WYF.sv.trackerPos)
    for i = 1, 4 do
        WYF.sv.warnPos[i] = { x = defaults.warnPos[i].x, y = defaults.warnPos[i].y }
        WYF.ApplyPos(WYF.warnFrames[i], WYF.sv.warnPos[i])
    end
    d("|cFF4444[Warmask]|r positions reset.")
end

-- ---------------------------------------------------------------------
--  Settings menu (LibAddonMenu-2.0, optional)
-- ---------------------------------------------------------------------
function WYF.BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type               = "panel",
        name               = WYF.displayName,
        displayName        = "|cFF4444Use Warmask you Fool|r",
        author             = "@petethepower",
        version            = WYF.version,
        slashCommand       = "/warmaskcfg",
        registerForRefresh = true,
        registerForDefaults= true,
    }
    WYF.panel = LAM:RegisterAddonPanel(WYF.name .. "Panel", panelData)

    local soundChoices = {
        "None", "ABILITY_ULTIMATE_READY", "GENERAL_ALERT_ERROR", "NEW_NOTIFICATION",
        "DUEL_INVITE_RECEIVED", "DUEL_START", "ACHIEVEMENT_AWARDED",
        "QUEST_COMPLETED", "GROUP_JOIN", "JUSTICE_NOW_KOS",
    }

    local options = {
        {
            type = "description",
            text = "Tracks your |cFFCC44Huntsman's Warmask|r effect (|cFFCC44Mark of Hircine|r, 60s) while you are in combat. " ..
                   "Shows a small icon + timer while it is up, and a big warning when it is missing at the start of a fight or runs out.",
        },
        { type = "header", name = "General" },
        {
            type = "checkbox", name = "Enabled",
            getFunc = function() return WYF.sv.enabled end,
            setFunc = function(v) WYF.sv.enabled = v; if not v then WYF.HideWarnings() end end,
            default = defaults.enabled,
        },
        {
            type = "checkbox", name = "Warn if missing at combat start",
            tooltip = "If Warmask is not up when a fight starts, warn (after the grace period below).",
            getFunc = function() return WYF.sv.warnOnStart end,
            setFunc = function(v) WYF.sv.warnOnStart = v end,
            default = defaults.warnOnStart,
        },
        {
            type = "checkbox", name = "Warn when it expires in combat",
            getFunc = function() return WYF.sv.warnOnExpire end,
            setFunc = function(v) WYF.sv.warnOnExpire = v end,
            default = defaults.warnOnExpire,
        },
        {
            type = "slider", name = "Combat-start grace period (ms)",
            tooltip = "How long after a fight starts to wait before the 'missing' warning fires (gives you time to bash on the pull).",
            min = 0, max = 4000, step = 100,
            getFunc = function() return WYF.sv.graceMs end,
            setFunc = function(v) WYF.sv.graceMs = v end,
            default = defaults.graceMs,
        },

        { type = "header", name = "What to track" },
        {
            type = "description",
            text = "Name match is a case-insensitive substring, comma separated. Default catches 'Mark of Hircine'. " ..
                   "If you play on a non-English client and it never triggers, turn on Learn mode, get into a fight, bash once, " ..
                   "and copy the name or id it prints into these boxes.",
        },
        {
            type = "editbox", name = "Tracked name(s)",
            getFunc = function() return WYF.sv.trackNames end,
            setFunc = function(v) WYF.sv.trackNames = v; buildMatchers() end,
            default = defaults.trackNames,
            isMultiline = false,
        },
        {
            type = "editbox", name = "Tracked ability ID(s)",
            tooltip = "Optional, comma separated. Locale-proof. Leave empty to match by name only.",
            getFunc = function() return WYF.sv.trackIds end,
            setFunc = function(v) WYF.sv.trackIds = v; buildMatchers() end,
            default = defaults.trackIds,
            isMultiline = false,
        },
        {
            type = "checkbox", name = "Learn mode (print effects to chat)",
            tooltip = "Prints every player-sourced effect that changes, with its name and id, so you can find the exact one to track.",
            getFunc = function() return WYF.sv.learnMode end,
            setFunc = function(v) WYF.sv.learnMode = v end,
            default = defaults.learnMode,
        },

        { type = "header", name = "Only when equipped" },
        {
            type = "description",
            text = "The Warmask helm is usually only worn for bosses. With this on, the addon stays completely silent " ..
                   "(no tracker, no warnings) whenever the set is not worn.",
        },
        {
            type = "checkbox", name = "Only act while the Warmask set is worn",
            getFunc = function() return WYF.sv.onlyWhenEquipped end,
            setFunc = function(v) WYF.sv.onlyWhenEquipped = v; WYF.RefreshEquipped() end,
            default = defaults.onlyWhenEquipped,
        },
        {
            type = "editbox", name = "Set name to detect",
            tooltip = "Case-insensitive substring of the SET name (not the buff). Default 'Warmask'. On a non-English client, " ..
                      "use /warmask gear to see your set names and put the matching word here. Empty = never block.",
            getFunc = function() return WYF.sv.helmSetName end,
            setFunc = function(v) WYF.sv.helmSetName = v; buildMatchers(); WYF.RefreshEquipped() end,
            default = defaults.helmSetName,
        },
        {
            type = "button", name = "Show my equipped sets (to chat)",
            func = function() SLASH_COMMANDS["/warmask"]("gear") end,
        },

        { type = "header", name = "Tracker (icon + timer)" },
        {
            type = "checkbox", name = "Show tracker",
            getFunc = function() return WYF.sv.trackerEnabled end,
            setFunc = function(v) WYF.sv.trackerEnabled = v; WYF.RefreshTrackerDisplay() end,
            default = defaults.trackerEnabled,
        },
        {
            type = "slider", name = "Tracker size",
            min = 24, max = 120, step = 2,
            getFunc = function() return WYF.sv.trackerSize end,
            setFunc = function(v) WYF.sv.trackerSize = v; WYF.ApplyTrackerSize() end,
            default = defaults.trackerSize,
        },

        { type = "header", name = "Warning look" },
        {
            type = "editbox", name = "Warning text",
            getFunc = function() return WYF.sv.warnText end,
            setFunc = function(v) if v == "" then v = "REAPPLY NOW" end WYF.sv.warnText = v; WYF.ApplyWarnStyle() end,
            default = defaults.warnText,
        },
        {
            type = "slider", name = "Font size",
            min = 20, max = 150, step = 2,
            getFunc = function() return WYF.sv.warnFontSize end,
            setFunc = function(v) WYF.sv.warnFontSize = v; WYF.ApplyWarnStyle() end,
            default = defaults.warnFontSize,
        },
        {
            type = "colorpicker", name = "Warning colour",
            getFunc = function()
                local c = WYF.sv.warnColor
                return c[1], c[2], c[3], c[4] or 1
            end,
            setFunc = function(r, g, b, a)
                WYF.sv.warnColor = { r, g, b, a }
                WYF.ApplyWarnStyle()
            end,
            default = { r = defaults.warnColor[1], g = defaults.warnColor[2], b = defaults.warnColor[3], a = defaults.warnColor[4] },
        },
        {
            type = "dropdown", name = "Sound — combat start (missing)",
            tooltip = "Played when Warmask is not up at the start of a fight. Selecting a value previews it.",
            choices = soundChoices,
            getFunc = function() return WYF.sv.warnSoundStart end,
            setFunc = function(v) WYF.sv.warnSoundStart = v; playSoundKey(v) end,
            default = defaults.warnSoundStart,
        },
        {
            type = "dropdown", name = "Sound — expired in combat",
            tooltip = "Played when Warmask drops during a fight. Selecting a value previews it.",
            choices = soundChoices,
            getFunc = function() return WYF.sv.warnSoundExpire end,
            setFunc = function(v) WYF.sv.warnSoundExpire = v; playSoundKey(v) end,
            default = defaults.warnSoundExpire,
        },
        {
            type = "checkbox", name = "Repeat sound while warning is up",
            tooltip = "Off = play the sound once. On = repeat it until you reapply Warmask or leave combat.",
            getFunc = function() return WYF.sv.warnSoundRepeat end,
            setFunc = function(v) WYF.sv.warnSoundRepeat = v; if not v then WYF.StopSoundLoop() end end,
            default = defaults.warnSoundRepeat,
        },
        {
            type = "slider", name = "Repeat every (seconds)",
            min = 0.5, max = 5, step = 0.5, decimals = 1,
            disabled = function() return not WYF.sv.warnSoundRepeat end,
            getFunc = function() return WYF.sv.warnSoundInterval end,
            setFunc = function(v) WYF.sv.warnSoundInterval = v end,
            default = defaults.warnSoundInterval,
        },
        {
            type = "checkbox", name = "Blink / flash",
            getFunc = function() return WYF.sv.warnBlink end,
            setFunc = function(v) WYF.sv.warnBlink = v end,
            default = defaults.warnBlink,
        },
        {
            type = "slider", name = "Auto-hide after (seconds)",
            tooltip = "0 = keep the warning up until you reapply Warmask or leave combat.",
            min = 0, max = 15, step = 1,
            getFunc = function() return WYF.sv.warnAutoHide end,
            setFunc = function(v) WYF.sv.warnAutoHide = v end,
            default = defaults.warnAutoHide,
        },

        { type = "header", name = "Warning positions (up to 4)" },
        {
            type = "description",
            text = "Enable up to four copies of the warning at different spots on your screen. " ..
                   "Turn on 'Move mode' below to drag them where you want, then turn it off to lock & save.",
        },
    }

    for i = 1, 4 do
        options[#options + 1] = {
            type = "checkbox", name = "Enable warning " .. i,
            getFunc = function() return WYF.sv.warnEnabled[i] end,
            setFunc = function(v) WYF.sv.warnEnabled[i] = v end,
            default = defaults.warnEnabled[i],
            width = "half",
        }
    end

    options[#options + 1] = {
        type = "checkbox", name = "|cFFCC44Move mode|r (unlock frames)",
        tooltip = "Shows the tracker and all four warnings so you can drag them. Turn off to lock & save.",
        getFunc = function() return WYF.unlocked end,
        setFunc = function(v) WYF.SetUnlocked(v) end,
        default = false,
    }
    options[#options + 1] = {
        type = "button", name = "Preview warning",
        func = function()
            WYF.TriggerWarning("expire", true)
            zo_callLater(function() if not WYF.inCombat then WYF.HideWarnings() end end, 3000)
        end,
    }
    options[#options + 1] = {
        type = "button", name = "Reset positions",
        func = function() WYF.ResetPositions() end,
        warning = "Moves the tracker and all warnings back to their default spots.",
    }

    LAM:RegisterOptionControls(WYF.name .. "Panel", options)
end

-- ---------------------------------------------------------------------
--  Slash commands (work with or without LibAddonMenu)
-- ---------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/warmask"] = function(arg)
        arg = zo_strlower(zo_strtrim(arg or ""))
        if arg == "unlock" then
            WYF.SetUnlocked(true)
            d("|cFF4444[Warmask]|r frames unlocked — drag them, then |cFFFFFF/warmask lock|r.")
        elseif arg == "lock" then
            WYF.SetUnlocked(false)
            d("|cFF4444[Warmask]|r frames locked & saved.")
        elseif arg == "test" then
            WYF.TriggerWarning("expire", true)
            zo_callLater(function() if not WYF.inCombat then WYF.HideWarnings() end end, 3000)
        elseif arg == "learn" then
            WYF.sv.learnMode = not WYF.sv.learnMode
            d("|cFF4444[Warmask]|r learn mode: " .. tostring(WYF.sv.learnMode))
        elseif arg == "gear" then
            d("|cFF4444[Warmask]|r equipped sets:")
            local seen = {}
            for i = 1, #GEAR_SLOTS do
                local link = GetItemLink(BAG_WORN, GEAR_SLOTS[i])
                if link and link ~= "" then
                    local hasSet, setName = GetItemLinkSetInfo(link, false)
                    if hasSet and setName and setName ~= "" and not seen[setName] then
                        seen[setName] = true
                        d("  • " .. setName)
                    end
                end
            end
            WYF.RefreshEquipped()
            d("Detected as Warmask (worn): |cFFFFFF" .. tostring(WYF.equipped) .. "|r")
        elseif arg == "on" then
            WYF.sv.enabled = true
            d("|cFF4444[Warmask]|r enabled.")
        elseif arg == "off" then
            WYF.sv.enabled = false
            WYF.HideWarnings()
            d("|cFF4444[Warmask]|r disabled.")
        elseif arg == "reset" then
            WYF.ResetPositions()
        else
            d("|cFF4444Use Warmask you Fool|r — commands:")
            d("  |cFFFFFF/warmask unlock|r / |cFFFFFFlock|r — move & save the frames")
            d("  |cFFFFFF/warmask test|r — preview the warning")
            d("  |cFFFFFF/warmask learn|r — print effects to chat to find the right name/id")
            d("  |cFFFFFF/warmask gear|r — list worn sets & whether Warmask is detected")
            d("  |cFFFFFF/warmask on|r / |cFFFFFFoff|r / |cFFFFFFreset|r")
            d("  Full settings: ESC > Settings > Addons (or |cFFFFFF/warmaskcfg|r).")
        end
    end
end

-- ---------------------------------------------------------------------
--  Init
-- ---------------------------------------------------------------------
function WYF.OnAddOnLoaded(_, addonName)
    if addonName ~= WYF.name then return end
    EM:UnregisterForEvent(WYF.name, EVENT_ADD_ON_LOADED)

    WYF.sv = ZO_SavedVars:NewAccountWide("UseWarmaskYouFoolSV", 1, nil, defaults)
    buildMatchers()

    createTracker()
    createWarnings()
    WYF.BuildMenu()
    RegisterSlash()

    EM:RegisterForEvent(WYF.name, EVENT_PLAYER_COMBAT_STATE, WYF.OnCombatState)
    EM:RegisterForEvent(WYF.name, EVENT_EFFECT_CHANGED, WYF.OnEffectChanged)
    EM:AddFilterForEvent(WYF.name, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- keep the "is the Warmask worn?" state fresh
    EM:RegisterForEvent(WYF.name, EVENT_PLAYER_ACTIVATED, function() WYF.RefreshEquipped() end)
    EM:RegisterForEvent(WYF.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function() WYF.RefreshEquipped() end)
    EM:AddFilterForEvent(WYF.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    WYF.RefreshEquipped()
end

EM:RegisterForEvent(WYF.name, EVENT_ADD_ON_LOADED, WYF.OnAddOnLoaded)
