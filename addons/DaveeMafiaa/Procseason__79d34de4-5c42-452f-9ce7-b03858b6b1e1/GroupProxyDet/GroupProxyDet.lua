-- Group Burst Timers v7.8.0
-- Created by Daveemafiaa
--
-- Compact PlayStation group timer HUD.
--
-- Ability colors:
--   Proxy Det       = Purple
--   Deep Fissure    = Blue
--   Soul of Flame   = Orange
--
-- Layout:
--   7.9  [████████ PlayerName █████░░░]
--   7.5  [████████ PlayerName ████░░░░]
--
-- Every player running this addon broadcasts their OWN casts through
-- LibGroupBroadcast, so all players running the addon can see the same
-- individual timer rows.
--
-- Dependencies:
--   LibAddonMenu-2.0
--   LibGroupBroadcast
--
-- Protocol ID 487 is provisional for testing. Reserve a unique ID before
-- public release to avoid collisions with another addon.

local ADDON_NAME = "GroupProxyDet"
local PROTOCOL_ID = 487
local PROTOCOL_NAME = "GroupBurstTimerState"

local ABILITY_PROXY = 1
local ABILITY_FISSURE = 2
local ABILITY_SOUL = 3

local ABILITY_NAMES = {
    [ABILITY_PROXY] = "PROXY DET",
    [ABILITY_FISSURE] = "DEEP FISSURE",
    [ABILITY_SOUL] = "SOUL OF FLAME",
}

local ABILITY_COLORS = {
    [ABILITY_PROXY] = {0.62, 0.18, 0.82},   -- purple
    [ABILITY_FISSURE] = {0.10, 0.36, 0.98}, -- blue
    [ABILITY_SOUL] = {1.00, 0.42, 0.05},    -- orange
}

local DEFAULT_DURATIONS = {
    [ABILITY_PROXY] = 8.0,
    [ABILITY_FISSURE] = 9.0,
    [ABILITY_SOUL] = 4.0,
}

local DEFAULTS = {
    enabled = true,
    hideWhenIdle = true,

    hudScale = 1.0,
    hudX = 120,
    hudY = 260,

    rowWidth = 430,
    rowHeight = 38,
    rowGap = 2,
    nameFontSize = 30,
    countdownFontSize = 30,
    timerWidth = 60,
    maxRows = 18,

    emptyOpacity = 0.58,
    rowBorderOpacity = 0.90,

    showAbilityLabel = false,

    proxyDuration = 8.0,
    fissureDuration = 9.0,
    soulDuration = 4.0,

    updateMs = 50,
}

-- Proxy IDs retained as a reliable fallback for effect detection.
local PROXY_IDS = {
    [61500] = true,
    [63296] = true,
    [63299] = true,
    [63302] = true,
}

-- Deep Fissure's commonly documented morph ID.
local FISSURE_IDS = {
    [93778] = true,
    [86015] = true, -- compatibility with other API references
}

local saved
local initialized = false
local settingsRegistered = false

local hud
local rows = {}
local timers = {}

local LGB
local lgbHandler
local timerProtocol
local lgbReady = false

local function Now()
    return GetFrameTimeSeconds()
end

local function GetDuration(abilityType)
    if abilityType == ABILITY_PROXY then
        return saved.proxyDuration
    elseif abilityType == ABILITY_FISSURE then
        return saved.fissureDuration
    elseif abilityType == ABILITY_SOUL then
        return saved.soulDuration
    end
    return 8.0
end

local function NormalizeName(name)
    return string.lower(name or "")
end

local function DetectAbilityTypeByName(name)
    local n = NormalizeName(name)

    if n == "deep fissure" then
        return ABILITY_FISSURE
    elseif n == "soul of flame" then
        return ABILITY_SOUL
    elseif string.find(n, "proximity detonation", 1, true)
        or string.find(n, "inevitable detonation", 1, true)
        or n == "proxy detonation"
        or n == "proxy det" then
        return ABILITY_PROXY
    end

    return nil
end

local function DetectAbilityType(abilityId, abilityName)
    if abilityId and PROXY_IDS[abilityId] then
        return ABILITY_PROXY
    end

    if abilityId and FISSURE_IDS[abilityId] then
        return ABILITY_FISSURE
    end

    return DetectAbilityTypeByName(abilityName)
end

local function Label(parent, name, font)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    c:SetFont(font)
    c:SetColor(1, 1, 1, 1)
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return c
end

local function ApplyHudPlacement()
    if not hud then
        return
    end

    hud:ClearAnchors()
    hud:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        saved.hudX,
        saved.hudY
    )
    hud:SetScale(saved.hudScale)
end

local function MakeTimerKey(unitTag, abilityType)
    return tostring(unitTag) .. ":" .. tostring(abilityType)
end

local function SetTimer(unitTag, abilityType, duration)
    if not unitTag or not abilityType then
        return
    end

    local now = Now()
    local d = duration or GetDuration(abilityType)
    local key = MakeTimerKey(unitTag, abilityType)

    timers[key] = {
        unitTag = unitTag,
        abilityType = abilityType,
        started = now,
        duration = d,
        ends = now + d,
    }
end

local function RemoveTimer(unitTag, abilityType)
    timers[MakeTimerKey(unitTag, abilityType)] = nil
end

local function UnitDisplayName(unitTag)
    if unitTag == "player" then
        local n = GetUnitName("player")
        return (n and n ~= "") and n or "YOU"
    end

    if DoesUnitExist and DoesUnitExist(unitTag) then
        local n = GetUnitName(unitTag)
        if n and n ~= "" then
            return n
        end
    end

    return string.upper(unitTag or "GROUP")
end

local function BuildRow(index)
    local row = WINDOW_MANAGER:CreateControl(
        "GroupBurstTimerRow" .. index,
        hud,
        CT_CONTROL
    )

    row:SetDimensions(saved.rowWidth, saved.rowHeight)
    row:SetAnchor(
        TOPLEFT,
        hud,
        TOPLEFT,
        0,
        (index - 1) * (saved.rowHeight + saved.rowGap)
    )

    local timerBg = WINDOW_MANAGER:CreateControl(
        "GroupBurstTimerTimerBG" .. index,
        row,
        CT_BACKDROP
    )
    timerBg:SetDimensions(saved.timerWidth, saved.rowHeight)
    timerBg:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    timerBg:SetCenterColor(0, 0, 0, 0)
    timerBg:SetEdgeColor(0, 0, 0, 0)

    local countdownFont = string.format(
        "$(BOLD_FONT)|%d|soft-shadow-thick",
        saved.countdownFontSize
    )

    local timerText = Label(
        timerBg,
        "GroupBurstTimerTimerText" .. index,
        countdownFont
    )
    timerText:SetAnchorFill(timerBg)
    timerText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local barBg = WINDOW_MANAGER:CreateControl(
        "GroupBurstTimerBarBG" .. index,
        row,
        CT_BACKDROP
    )
    barBg:SetDimensions(
        saved.rowWidth - saved.timerWidth - 4,
        saved.rowHeight
    )
    barBg:SetAnchor(TOPLEFT, timerBg, TOPRIGHT, 4, 0)
    barBg:SetCenterColor(0, 0, 0, 0)
    barBg:SetEdgeColor(0, 0, 0, 0)

    local fill = WINDOW_MANAGER:CreateControl(
        "GroupBurstTimerBarFill" .. index,
        barBg,
        CT_BACKDROP
    )
    fill:SetDimensions(0, saved.rowHeight - 4)
    fill:SetAnchor(LEFT, barBg, LEFT, 2, 0)
    fill:SetEdgeColor(0, 0, 0, 0)

    local nameFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", saved.nameFontSize)

    local nameShadow = Label(
        barBg,
        "GroupBurstTimerNameShadow" .. index,
        nameFont
    )
    nameShadow:SetDimensions(
        saved.rowWidth - saved.timerWidth - 8,
        saved.rowHeight
    )
    nameShadow:SetAnchor(
        CENTER,
        barBg,
        CENTER,
        1,
        1
    )
    nameShadow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameShadow:SetColor(0, 0, 0, 0.95)

    local nameText = Label(
        barBg,
        "GroupBurstTimerNameText" .. index,
        nameFont
    )
    nameText:SetAnchorFill(barBg)
    nameText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameText:SetColor(1, 1, 1, 1)
    nameText:SetColor(1, 1, 1, 1)

    local abilityText = Label(
        barBg,
        "GroupBurstTimerAbilityText" .. index,
        "ZoFontGame"
    )
    abilityText:SetDimensions(135, saved.rowHeight)
    abilityText:SetAnchor(RIGHT, barBg, RIGHT, -8, 0)
    abilityText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    rows[index] = {
        root = row,
        timerText = timerText,
        barBg = barBg,
        fill = fill,
        nameText = nameText,
        nameShadow = nameShadow,
        abilityText = abilityText,
    }
end

local function BuildHUD()
    local height =
        (saved.maxRows * saved.rowHeight)
        + ((saved.maxRows - 1) * saved.rowGap)

    hud = WINDOW_MANAGER:CreateTopLevelWindow("GroupBurstTimerRoot")
    hud:SetDimensions(saved.rowWidth, height)
    hud:SetMouseEnabled(false)
    hud:SetHidden(true)

    for i = 1, saved.maxRows do
        BuildRow(i)
    end

    ApplyHudPlacement()
end

local function ActiveTimers()
    local now = Now()
    local list = {}

    for key, timer in pairs(timers) do
        local remain = timer.ends - now

        if remain > 0 then
            timer.remain = remain
            table.insert(list, timer)
        else
            timers[key] = nil
        end
    end

    table.sort(
        list,
        function(a, b)
            if math.abs(a.remain - b.remain) > 0.01 then
                return a.remain < b.remain
            end

            local an = UnitDisplayName(a.unitTag)
            local bn = UnitDisplayName(b.unitTag)

            if an ~= bn then
                return an < bn
            end

            return a.abilityType < b.abilityType
        end
    )

    return list
end

local function UpdateRow(row, timer)
    if not timer then
        row.root:SetHidden(true)
        return
    end

    row.root:SetHidden(false)

    local remain = timer.remain
    local duration = math.max(0.1, timer.duration)
    local pct = math.max(0, math.min(1, remain / duration))

    local barArea =
        saved.rowWidth
        - saved.timerWidth
        - 8

    row.fill:SetWidth(
        math.floor(barArea * pct)
    )

    row.timerText:SetText(
        string.format("%.1f", remain)
    )

    local displayName = UnitDisplayName(timer.unitTag)
    row.nameText:SetText(displayName)
    if row.nameShadow then
        row.nameShadow:SetText(displayName)
    end

    if saved.showAbilityLabel then
        row.abilityText:SetText(
            ABILITY_NAMES[timer.abilityType] or ""
        )
        row.abilityText:SetHidden(false)
    else
        row.abilityText:SetText("")
        row.abilityText:SetHidden(true)
    end

    local color =
        ABILITY_COLORS[timer.abilityType]
        or {1, 1, 1}

    row.fill:SetCenterColor(
        color[1],
        color[2],
        color[3],
        0.94
    )

    row.timerText:SetColor(
        1,
        1,
        1,
        1
    )
end

local function UpdateHUD()
    if not initialized then
        return
    end

    if not saved.enabled then
        hud:SetHidden(true)
        return
    end

    local list = ActiveTimers()
    local count = math.min(#list, saved.maxRows)

    for i = 1, saved.maxRows do
        UpdateRow(rows[i], list[i])
    end

    if count == 0 and saved.hideWhenIdle then
        hud:SetHidden(true)
    else
        hud:SetHidden(false)
    end
end

local function BroadcastTimer(abilityType, duration)
    if not lgbReady or not timerProtocol then
        return
    end

    if timerProtocol.IsEnabled
        and not timerProtocol:IsEnabled() then
        return
    end

    local tenth = math.floor(
        (duration or GetDuration(abilityType))
        * 10
        + 0.5
    )

    tenth = math.max(10, math.min(150, tenth))

    timerProtocol:Send({
        abilityType = abilityType,
        durationTenth = tenth,
    })
end

local function SetupGroupBroadcast()
    LGB = LibGroupBroadcast

    if not LGB then
        d("|cFF4444Group Burst Timers: LibGroupBroadcast is required.|r")
        return
    end

    lgbHandler = LGB:RegisterHandler(
        ADDON_NAME,
        "BurstTimerSyncHandler"
    )

    if not lgbHandler then
        d("|cFF4444Group Burst Timers: broadcast handler registration failed.|r")
        return
    end

    lgbHandler:SetDisplayName("Group Burst Timers")
    lgbHandler:SetDescription(
        "Shares Proxy Det, Deep Fissure, and Soul of Flame timers."
    )

    timerProtocol = lgbHandler:DeclareProtocol(
        PROTOCOL_ID,
        PROTOCOL_NAME
    )

    timerProtocol:AddField(
        LGB.CreateNumericField(
            "abilityType",
            {
                minValue = 1,
                maxValue = 3,
            }
        )
    )

    timerProtocol:AddField(
        LGB.CreateNumericField(
            "durationTenth",
            {
                minValue = 10,
                maxValue = 150,
            }
        )
    )

    timerProtocol:OnData(
        function(unitTag, data)
            if not unitTag or not data then
                return
            end

            local abilityType = data.abilityType

            if abilityType ~= ABILITY_PROXY
                and abilityType ~= ABILITY_FISSURE
                and abilityType ~= ABILITY_SOUL then
                return
            end

            local duration =
                (data.durationTenth or 80)
                / 10

            SetTimer(
                unitTag,
                abilityType,
                duration
            )
        end
    )

    local ok = timerProtocol:Finalize({
        isRelevantInCombat = true,
        replaceQueuedMessages = false,
    })

    lgbReady = ok == true
end

local function StartAndBroadcast(abilityType, duration)
    local d = duration or GetDuration(abilityType)

    SetTimer(
        "player",
        abilityType,
        d
    )

    BroadcastTimer(
        abilityType,
        d
    )
end

-- Action-slot event catches locally cast skills immediately.
local function OnActionSlotAbilityUsed(_, slotNum)
    if not slotNum then
        return
    end

    local abilityId = GetSlotBoundId(slotNum)
    local abilityName = GetSlotName(slotNum)

    local abilityType =
        DetectAbilityType(
            abilityId,
            abilityName
        )

    if not abilityType then
        return
    end

    StartAndBroadcast(
        abilityType,
        GetDuration(abilityType)
    )
end

-- Effect event is a second line of detection, particularly useful for Proxy.
local function OnEffectChanged(
    eventCode,
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    iconName,
    buffType,
    effectType,
    abilityTypeArg,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType
)
    if unitTag ~= "player" then
        return
    end

    local abilityType =
        DetectAbilityType(
            abilityId,
            effectName
        )

    if not abilityType then
        return
    end

    if changeType == EFFECT_RESULT_GAINED
        or changeType == EFFECT_RESULT_UPDATED
        or changeType == EFFECT_RESULT_FULL_REFRESH then

        local duration = GetDuration(abilityType)

        if beginTime
            and endTime
            and endTime > beginTime then
            duration = endTime - beginTime
        end

        StartAndBroadcast(
            abilityType,
            duration
        )

    elseif changeType == EFFECT_RESULT_FADED then
        -- Only remove if the timer is effectively complete.
        -- Action-slot timers such as Deep Fissure may not map 1:1 to a buff fade.
        if abilityType == ABILITY_PROXY then
            RemoveTimer(
                "player",
                abilityType
            )
        end
    end
end

local function StartTest()
    SetTimer("player", ABILITY_PROXY, saved.proxyDuration)
    SetTimer("group1", ABILITY_FISSURE, saved.fissureDuration - 1.0)
    SetTimer("group2", ABILITY_SOUL, saved.soulDuration)
    SetTimer("group3", ABILITY_PROXY, saved.proxyDuration - 2.0)
    SetTimer("group4", ABILITY_FISSURE, saved.fissureDuration - 3.0)
    SetTimer("group5", ABILITY_SOUL, saved.soulDuration - 1.0)
    hud:SetHidden(false)
end

local function RegisterLAMSettings()
    if settingsRegistered then
        return
    end

    local LAM = LibAddonMenu2

    if not LAM then
        d("|cFF4444Group Burst Timers: LibAddonMenu-2.0 is required.|r")
        return
    end

    local panelData = {
        type = "panel",
        name = "Group Burst Timers",
        displayName = "Group Burst Timers",
        author = "Daveemafiaa",
        version = "7.8.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "Compact group-shared timers: Proxy Det = Purple, Deep Fissure = Blue, Soul of Flame = Orange.",
        },
        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Addon Enabled",
            getFunc = function()
                return saved.enabled
            end,
            setFunc = function(v)
                saved.enabled = v
            end,
            default = DEFAULTS.enabled,
        },
        {
            type = "checkbox",
            name = "Hide When Inactive",
            getFunc = function()
                return saved.hideWhenIdle
            end,
            setFunc = function(v)
                saved.hideWhenIdle = v
            end,
            default = DEFAULTS.hideWhenIdle,
        },
        {
            type = "checkbox",
            name = "Show Ability Label",
            tooltip = "Shows PROXY DET, DEEP FISSURE, or SOUL OF FLAME on the right side of each row.",
            getFunc = function()
                return saved.showAbilityLabel
            end,
            setFunc = function(v)
                saved.showAbilityLabel = v
            end,
            default = DEFAULTS.showAbilityLabel,
        },
        {
            type = "header",
            name = "HUD Layout",
        },
        {
            type = "slider",
            name = "HUD Scale",
            min = 0.75,
            max = 4.00,
            step = 0.05,
            decimals = 2,
            getFunc = function()
                return saved.hudScale
            end,
            setFunc = function(v)
                saved.hudScale = v
                ApplyHudPlacement()
            end,
            default = DEFAULTS.hudScale,
        },
        {
            type = "slider",
            name = "Horizontal Position",
            min = -1200,
            max = 1200,
            step = 10,
            getFunc = function()
                return saved.hudX
            end,
            setFunc = function(v)
                saved.hudX = math.floor(v)
                ApplyHudPlacement()
            end,
            default = DEFAULTS.hudX,
        },
        {
            type = "slider",
            name = "Vertical Position",
            min = -100,
            max = 1000,
            step = 10,
            getFunc = function()
                return saved.hudY
            end,
            setFunc = function(v)
                saved.hudY = math.floor(v)
                ApplyHudPlacement()
            end,
            default = DEFAULTS.hudY,
        },
        {
            type = "slider",
            name = "Row Width",
            min = 300,
            max = 700,
            step = 10,
            getFunc = function()
                return saved.rowWidth
            end,
            setFunc = function(v)
                saved.rowWidth = math.floor(v)
            end,
            default = DEFAULTS.rowWidth,
            requiresReload = true,
        },
        {
            type = "slider",
            name = "Player Name Font Size",
            tooltip = "Adjust the player-name text size without changing the entire HUD scale.",
            min = 18,
            max = 60,
            step = 1,
            getFunc = function()
                return saved.nameFontSize
            end,
            setFunc = function(v)
                saved.nameFontSize = math.floor(v)
            end,
            default = DEFAULTS.nameFontSize,
            requiresReload = true,
        },
        {
            type = "slider",
            name = "Countdown Font Size",
            tooltip = "Adjust the numeric countdown text size independently of the player names.",
            min = 18,
            max = 60,
            step = 1,
            getFunc = function()
                return saved.countdownFontSize
            end,
            setFunc = function(v)
                saved.countdownFontSize = math.floor(v)
            end,
            default = DEFAULTS.countdownFontSize,
            requiresReload = true,
        },
        {
            type = "slider",
            name = "Row Height",
            min = 30,
            max = 52,
            step = 2,
            getFunc = function()
                return saved.rowHeight
            end,
            setFunc = function(v)
                saved.rowHeight = math.floor(v)
            end,
            default = DEFAULTS.rowHeight,
            requiresReload = true,
        },
        {
            type = "header",
            name = "Timer Durations",
        },
        {
            type = "slider",
            name = "Proxy Det Duration",
            min = 5.0,
            max = 12.0,
            step = 0.1,
            decimals = 1,
            getFunc = function()
                return saved.proxyDuration
            end,
            setFunc = function(v)
                saved.proxyDuration = v
            end,
            default = DEFAULTS.proxyDuration,
        },
        {
            type = "slider",
            name = "Deep Fissure Duration",
            min = 3.0,
            max = 12.0,
            step = 0.1,
            decimals = 1,
            getFunc = function()
                return saved.fissureDuration
            end,
            setFunc = function(v)
                saved.fissureDuration = v
            end,
            default = DEFAULTS.fissureDuration,
        },
        {
            type = "slider",
            name = "Soul of Flame Duration",
            min = 2.0,
            max = 8.0,
            step = 0.1,
            decimals = 1,
            getFunc = function()
                return saved.soulDuration
            end,
            setFunc = function(v)
                saved.soulDuration = v
            end,
            default = DEFAULTS.soulDuration,
        },
        {
            type = "header",
            name = "Testing",
        },
        {
            type = "button",
            name = "Mixed Timer Test",
            func = StartTest,
            width = "full",
        },
    }

    LAM:RegisterAddonPanel(
        "GroupBurstTimerOptions",
        panelData
    )

    LAM:RegisterOptionControls(
        "GroupBurstTimerOptions",
        optionsData
    )

    settingsRegistered = true
end

local function OnPlayerActivated()
    RegisterLAMSettings()
end

local function SlashCommand(text)
    local command =
        string.lower(
            (text or "")
            :match("^%s*(.-)%s*$")
            or ""
        )

    if command == "test" then
        StartTest()
    else
        d("|cFFD43DGroup Burst Timers|r v7.8 - Created by Daveemafiaa")
        d("Purple = Proxy Det")
        d("Blue = Deep Fissure")
        d("Orange = Soul of Flame")
        d("/gpd test")
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    saved =
        ZO_SavedVars:NewAccountWide(
            "GroupProxyDetSaved",
            12,
            nil,
            DEFAULTS
        )

    for k, v in pairs(DEFAULTS) do
        if saved[k] == nil then
            saved[k] = v
        end
    end

    BuildHUD()
    SetupGroupBroadcast()

    SLASH_COMMANDS["/gpd"] =
        SlashCommand

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_ActionUsed",
        EVENT_ACTION_SLOT_ABILITY_USED,
        OnActionSlotAbilityUsed
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Effects",
        EVENT_EFFECT_CHANGED,
        OnEffectChanged
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_Update",
        saved.updateMs,
        UpdateHUD
    )

    initialized = true
    UpdateHUD()
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)
