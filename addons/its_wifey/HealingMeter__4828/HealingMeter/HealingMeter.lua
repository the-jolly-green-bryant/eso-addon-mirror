local ADDON_NAME = "HealingMeter"
local DISPLAY_NAME = "Healing Meter"
local VERSION = "1.1"

local HM = {}
local sv
local wm = WINDOW_MANAGER

local defaults = {
    enabled = true,
    showMeter = true,
    hideOutOfCombat = false,
    unlocked = false,
    scale = 1.00,
    backgroundAlpha = 0.58,
    textColor = {1, 1, 1, 1},
    font = "Bold",
    x = nil,
    y = nil,
}

local FONT_CHOICES = {
    ["Game"]    = "$(MEDIUM_FONT)",
    ["Bold"]    = "$(BOLD_FONT)",
    ["Chat"]    = "$(CHAT_FONT)",
    ["Antique"] = "$(ANTIQUE_FONT)",
}

local PRACTICE_IDLE_TIMEOUT = 3.0

local stats = {
    effective = 0,
    overheal = 0,
    raw = 0,
    startTime = 0,
    endTime = 0,
    lastHealTime = 0,
    active = false,
    practice = false,
    hasData = false,
}

local rows = {}

local TOOLTIP_TEXT = {
    effective = "Healing that actually restored missing Health.",
    overheal = "Healing that landed beyond the Health the target was missing.",
    raw = "All healing you produced. Effective Healing + Overhealing.",
    hps = "Effective Healing per second during the current fight.",
    rawhps = "Total Raw Healing per second, including overhealing.",
    overhealpct = "Percentage of your total healing that was overhealing.",
    time = "How long the current or most recent combat lasted.",
}

local function FormatNumber(n)
    n = math.floor((tonumber(n) or 0) + 0.5)
    local s = tostring(n)
    while true do
        local replaced, count = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        s = replaced
        if count == 0 then break end
    end
    return s
end

local function GetElapsed()
    if stats.startTime <= 0 then return 0 end

    local finish
    if stats.active then
        -- During out-of-combat practice, time advances only when healing is
        -- actually landing. This prevents the timer/HPS denominator from
        -- continuing to grow after the user's HoTs have finished.
        if stats.practice and stats.lastHealTime > 0 then
            finish = stats.lastHealTime
        else
            finish = GetFrameTimeSeconds()
        end
    else
        finish = stats.endTime
    end

    return math.max(0, finish - stats.startTime)
end

local function ResetStats(startNow)
    stats.effective = 0
    stats.overheal = 0
    stats.raw = 0
    stats.hasData = false
    stats.startTime = startNow and GetFrameTimeSeconds() or 0
    stats.endTime = 0
    stats.lastHealTime = 0
    stats.active = startNow and true or false
    stats.practice = false
end

local function GetFontDescriptor(size)
    local face = FONT_CHOICES[sv.font] or FONT_CHOICES["Bold"]
    return string.format("%s|%d|soft-shadow-thin", face, size)
end

local function ApplyAppearance()
    if not HM.window then return end

    HM.window:SetScale(sv.scale)
    HM.backdrop:SetCenterColor(0, 0, 0, sv.backgroundAlpha)
    HM.backdrop:SetEdgeColor(0.45, 0.45, 0.45, math.min(1, sv.backgroundAlpha + 0.18))

    local c = sv.textColor
    HM.title:SetColor(c[1], c[2], c[3], c[4])
    HM.status:SetColor(c[1], c[2], c[3], c[4])

    HM.title:SetFont(GetFontDescriptor(20))
    HM.status:SetFont(GetFontDescriptor(14))

    for _, row in pairs(rows) do
        row.name:SetColor(c[1], c[2], c[3], c[4])
        row.value:SetColor(c[1], c[2], c[3], c[4])
        row.name:SetFont(GetFontDescriptor(16))
        row.value:SetFont(GetFontDescriptor(16))
    end
end

local function IsMenuOpen()
    if not SCENE_MANAGER then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene then return false end
    local name = scene:GetName()
    return name ~= "hud" and name ~= "hudui"
end

local function ShouldShow()
    if not sv or not sv.enabled or not sv.showMeter then return false end
    if IsMenuOpen() then return false end
    if sv.unlocked then return true end
    if sv.hideOutOfCombat and not IsUnitInCombat("player") then return false end
    return true
end

local function RefreshVisibility()
    if HM.window then
        HM.window:SetHidden(not ShouldShow())
        HM.window:SetMouseEnabled(sv.unlocked)
        HM.dragHint:SetHidden(not sv.unlocked)
    end
end

local function UpdateDisplay()
    if not HM.window then return end

    local elapsed = GetElapsed()
    local hps = elapsed > 0 and (stats.effective / elapsed) or 0
    local rawHps = elapsed > 0 and (stats.raw / elapsed) or 0
    local overPct = stats.raw > 0 and ((stats.overheal / stats.raw) * 100) or 0

    rows.effective.value:SetText(FormatNumber(stats.effective))
    rows.overheal.value:SetText(FormatNumber(stats.overheal))
    rows.raw.value:SetText(FormatNumber(stats.raw))
    rows.hps.value:SetText(FormatNumber(hps))
    rows.rawhps.value:SetText(FormatNumber(rawHps))
    rows.overhealpct.value:SetText(string.format("%.1f%%", overPct))
    rows.time.value:SetText(string.format("%.1fs", elapsed))

    if sv.unlocked then
        HM.status:SetText("UNLOCKED")
    elseif stats.active then
        HM.status:SetText("LIVE")
    elseif stats.hasData then
        HM.status:SetText("LAST FIGHT")
    else
        HM.status:SetText("READY")
    end

    RefreshVisibility()
end

local function ShowRowTooltip(control, key)
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    SetTooltipText(InformationTooltip, TOOLTIP_TEXT[key] or "")
end

local function CreateRow(parent, key, labelText, y)
    local name = wm:CreateControl(nil, parent, CT_LABEL)
    name:SetAnchor(TOPLEFT, parent, TOPLEFT, 16, y)
    name:SetDimensions(145, 24)
    name:SetText(labelText)
    name:SetMouseEnabled(true)
    name:SetHandler("OnMouseEnter", function(self) ShowRowTooltip(self, key) end)
    name:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    local value = wm:CreateControl(nil, parent, CT_LABEL)
    value:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -16, y)
    value:SetDimensions(120, 24)
    value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    value:SetText("0")
    value:SetMouseEnabled(true)
    value:SetHandler("OnMouseEnter", function(self) ShowRowTooltip(self, key) end)
    value:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    rows[key] = {name = name, value = value}
end

local function SavePosition()
    if not HM.window then return end
    sv.x = HM.window:GetLeft()
    sv.y = HM.window:GetTop()
end

local function CreateUI()
    local win = wm:CreateTopLevelWindow("HealingMeterWindow")
    HM.window = win
    win:SetDimensions(310, 255)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:SetMouseEnabled(false)
    win:SetHandler("OnMoveStop", SavePosition)

    if sv.x and sv.y then
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y)
    else
        win:SetAnchor(CENTER, GuiRoot, CENTER, 360, 0)
    end

    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    HM.backdrop = bg
    bg:SetAnchorFill(win)
    bg:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    bg:SetInsets(16, 16, -16, -16)

    local title = wm:CreateControl(nil, win, CT_LABEL)
    HM.title = title
    title:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 12)
    title:SetDimensions(200, 28)
    title:SetText("HEALING METER")

    local status = wm:CreateControl(nil, win, CT_LABEL)
    HM.status = status
    status:SetAnchor(TOPRIGHT, win, TOPRIGHT, -16, 16)
    status:SetDimensions(100, 20)
    status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local divider = wm:CreateControl(nil, win, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 42)
    divider:SetDimensions(278, 1)
    divider:SetColor(0.55, 0.55, 0.55, 0.65)

    CreateRow(win, "effective",   "Effective Healing", 52)
    CreateRow(win, "overheal",    "Overhealing",       78)
    CreateRow(win, "raw",         "Total Raw Healing", 104)
    CreateRow(win, "hps",         "HPS",               130)
    CreateRow(win, "rawhps",      "Raw HPS",           156)
    CreateRow(win, "overhealpct", "Overheal %",        182)
    CreateRow(win, "time",        "Fight Time",        208)

    local dragHint = wm:CreateControl(nil, win, CT_LABEL)
    HM.dragHint = dragHint
    dragHint:SetAnchor(BOTTOM, win, BOTTOM, 0, -4)
    dragHint:SetFont("$(MEDIUM_FONT)|12|soft-shadow-thin")
    dragHint:SetText("Drag anywhere on the box")
    dragHint:SetColor(0.75, 0.75, 0.75, 1)
    dragHint:SetHidden(true)

    ApplyAppearance()
    UpdateDisplay()
end

local function IsHealingResult(result)
    return result == ACTION_RESULT_HEAL
        or result == ACTION_RESULT_CRITICAL_HEAL
        or result == ACTION_RESULT_HOT_TICK
        or result == ACTION_RESULT_HOT_TICK_CRITICAL
end

local function OnCombatEvent(
    eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName,
    targetType, hitValue, powerType, damageType, log,
    sourceUnitId, targetUnitId, abilityId, overflow
)
    if not sv.enabled then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if not IsHealingResult(result) then return end

    -- Healing Meter also supports out-of-combat practice. If healing starts
    -- while no combat session is active, begin a fresh practice session
    -- automatically. The Hide Out of Combat setting controls visibility only;
    -- it never disables healing collection.
    if not stats.active then
        ResetStats(true)
        stats.practice = not IsUnitInCombat("player")
    end

    stats.lastHealTime = GetFrameTimeSeconds()

    local effective = math.max(0, tonumber(hitValue) or 0)
    local over = math.max(0, tonumber(overflow) or 0)

    stats.effective = stats.effective + effective
    stats.overheal = stats.overheal + over
    stats.raw = stats.raw + effective + over
    stats.hasData = true
end

local function OnCombatState(eventCode, inCombat)
    if not sv.enabled then return end

    if inCombat then
        -- IMPORTANT: do not convert an already-running out-of-combat practice
        -- session into a combat session. Some healing casts can briefly make
        -- ESO report combat state even when the user is only practicing.
        -- Keeping practice=true means its clock remains tied to actual heal
        -- events and stops when the healing stops.
        if not (stats.active and stats.practice) then
            ResetStats(true)
            stats.practice = false
        end
    else
        -- Only real combat sessions end from EVENT_PLAYER_COMBAT_STATE.
        -- Practice sessions are ended by healing inactivity in OnUpdate.
        if stats.active and not stats.practice then
            stats.endTime = GetFrameTimeSeconds()
            stats.active = false
        end
    end
    UpdateDisplay()
end

local function OnUpdate()
    if not sv or not sv.enabled then return end

    if stats.active and stats.practice then
        local now = GetFrameTimeSeconds()
        if stats.lastHealTime > 0 and (now - stats.lastHealTime) >= PRACTICE_IDLE_TIMEOUT then
            -- No healing has landed for a few seconds, so the practice
            -- rotation is over. Freeze the result at the final heal tick,
            -- not several seconds later.
            stats.endTime = stats.lastHealTime
            stats.active = false
            stats.practice = false
        end
    end

    if stats.active then
        UpdateDisplay()
    elseif stats.hasData then
        -- Keep LAST FIGHT values and visibility current after practice/combat.
        UpdateDisplay()
    else
        -- Keep visibility synced while idle so the meter returns immediately
        -- after closing a game menu.
        RefreshVisibility()
    end
end

local function ResetCommand()
    ResetStats(IsUnitInCombat("player"))
    UpdateDisplay()
    d("|cFFFFFF[HEALING METER]|r Reset.")
end

local function ToggleUnlock()
    sv.unlocked = not sv.unlocked
    RefreshVisibility()
    UpdateDisplay()
end

local function CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panel = ADDON_NAME .. "Options"
    LAM:RegisterAddonPanel(panel, {
        type = "panel",
        name = DISPLAY_NAME .. " |t22:22:HealingMeter/heart.dds|t",
        displayName = DISPLAY_NAME .. " |t22:22:HealingMeter/heart.dds|t",
        author = "WifeyRytic",
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(panel, {
        {
            type = "checkbox",
            name = "Enable Healing Meter",
            tooltip = "Full kill switch. When off, Healing Meter stops tracking and hides the meter.",
            getFunc = function() return sv.enabled end,
            setFunc = function(v)
                sv.enabled = v
                if not v then
                    stats.active = false
                    HM.window:SetHidden(true)
                else
                    RefreshVisibility()
                end
            end,
            default = defaults.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Meter",
            tooltip = "Shows or hides the Healing Meter box without disabling the addon.",
            getFunc = function() return sv.showMeter end,
            setFunc = function(v) sv.showMeter = v RefreshVisibility() end,
            default = defaults.showMeter,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Unlock / Move Meter",
            tooltip = "Unlocks the box so you can drag it anywhere on screen.",
            getFunc = function() return sv.unlocked end,
            setFunc = function(v) sv.unlocked = v RefreshVisibility() UpdateDisplay() end,
            default = defaults.unlocked,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide Out of Combat",
            tooltip = "Hides the meter when you are not in combat. Healing is still tracked in the background for practice; turn this off to watch out-of-combat healing live.",
            getFunc = function() return sv.hideOutOfCombat end,
            setFunc = function(v) sv.hideOutOfCombat = v RefreshVisibility() end,
            default = defaults.hideOutOfCombat,
            width = "full",
        },
        {
            type = "slider",
            name = "Box Size",
            tooltip = "Changes the size of the entire Healing Meter box.",
            min = 70,
            max = 150,
            step = 5,
            getFunc = function() return math.floor(sv.scale * 100 + 0.5) end,
            setFunc = function(v) sv.scale = v / 100 ApplyAppearance() end,
            default = 100,
            width = "full",
        },
        {
            type = "slider",
            name = "Background Transparency",
            tooltip = "Controls how visible the semi-transparent black background is. 0 is invisible; 100 is solid.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return math.floor(sv.backgroundAlpha * 100 + 0.5) end,
            setFunc = function(v) sv.backgroundAlpha = v / 100 ApplyAppearance() end,
            default = 58,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Text Color",
            tooltip = "Changes the color of all Healing Meter text. Default is white.",
            getFunc = function()
                local c = sv.textColor
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                sv.textColor = {r, g, b, a or 1}
                ApplyAppearance()
            end,
            default = defaults.textColor,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Font",
            tooltip = "Choose the font used by the Healing Meter.",
            choices = {"Game", "Bold", "Chat", "Antique"},
            getFunc = function() return sv.font end,
            setFunc = function(v) sv.font = v ApplyAppearance() end,
            default = defaults.font,
            width = "full",
        },
        {
            type = "button",
            name = "Reset Current / Last Fight",
            tooltip = "Clears all Healing Meter totals.",
            func = ResetCommand,
            width = "full",
        },
    })
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide(
        "HealingMeterSavedVariables",
        1,
        nil,
        defaults
    )

    CreateUI()
    CreateSettings()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Combat",
        EVENT_COMBAT_EVENT,
        OnCombatEvent
    )

    EVENT_MANAGER:AddFilterForEvent(
        ADDON_NAME .. "_Combat",
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_CombatState",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatState
    )

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update",
        250,
        OnUpdate
    )

    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("CurrentSceneChanged", function()
            RefreshVisibility()
        end)
    end

    SLASH_COMMANDS["/hmreset"] = ResetCommand
    SLASH_COMMANDS["/hmunlock"] = ToggleUnlock

    if IsUnitInCombat("player") then
        ResetStats(true)
    end

    UpdateDisplay()
    d("|cFFFFFF[HEALING METER]|r " .. VERSION .. " loaded. /hmreset to reset, /hmunlock to move.")
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)
