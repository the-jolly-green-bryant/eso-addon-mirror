local ADDON_NAME = "WifeyRyticMagmaTracker"
local VERSION = "1.2"

local savedVars

local MAGMA_ABILITIES = {
    [15957] = true, -- Magma Armor
    [17874] = true, -- Magma Shell
    [17878] = true, -- Corrosive Armor
}

local defaults = {
    enabled = true,
    barWidth = 350,
    barHeight = 32,
    barOffsetX = 0,
    barOffsetY = -150,
    countdownOffsetX = 0,
    countdownOffsetY = -60,
    countdownSize = 72,
    countdownColor = { r = 1, g = 0, b = 0, a = 1 },
    unlocked = false,
}

local magmaActive = false
local magmaBeginTime = 0
local magmaEndTime = 0
local magmaAbilityId = 0
local magmaName = "MAGMA SHELL"
local magmaIcon = ""

local tracker, icon, bar, barLabel
local countdownTracker, countdownLabel
local testMode = false
local testBeginTime = 0
local testEndTime = 0
local testAbilityId = 17874
local unlockPreview = false

local function IsMenuOpen()
    if not SCENE_MANAGER then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene then return false end
    local name = scene:GetName()
    return name ~= "hud" and name ~= "hudui"
end

local function HideAll()
    if tracker then tracker:SetHidden(true) end
    if countdownTracker then countdownTracker:SetHidden(true) end
end

local function SaveBarPosition()
    if not tracker then return end
    local centerX, centerY = tracker:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()
    savedVars.barOffsetX = centerX - rootX
    savedVars.barOffsetY = centerY - rootY
end

local function SaveCountdownPosition()
    if not countdownTracker then return end
    local centerX, centerY = countdownTracker:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()
    savedVars.countdownOffsetX = centerX - rootX
    savedVars.countdownOffsetY = centerY - rootY
end

local function ApplyCountdownSettings()
    if not countdownLabel then return end
    countdownLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", savedVars.countdownSize))
    local c = savedVars.countdownColor
    countdownLabel:SetColor(c.r, c.g, c.b, c.a)
end

local function SetUnlocked(unlocked)
    savedVars.unlocked = unlocked
    unlockPreview = unlocked
    tracker:SetMovable(unlocked)
    tracker:SetMouseEnabled(unlocked)
    bar:SetMouseEnabled(unlocked)
    barLabel:SetMouseEnabled(unlocked)
    icon:SetMouseEnabled(unlocked)
    countdownTracker:SetMovable(unlocked)
    countdownTracker:SetMouseEnabled(unlocked)
    countdownLabel:SetMouseEnabled(unlocked)

    if unlocked then
        if savedVars.enabled then
            d("WifeyRytic Magma Tracker unlocked. Close settings to move the tracker.")
            if not IsMenuOpen() then
                tracker:SetHidden(false)
                countdownTracker:SetHidden(false)
                icon:SetTexture(GetAbilityIcon(testAbilityId))
                barLabel:SetText("MAGMA SHELL  15.0")
                bar:SetValue(1)
                countdownLabel:SetText("5")
            end
        end
    else
        unlockPreview = false
        SaveBarPosition()
        SaveCountdownPosition()
        d("WifeyRytic Magma Tracker locked.")
        if not magmaActive and not testMode then HideAll() end
    end
end

local function ResetPositions()
    savedVars.barOffsetX, savedVars.barOffsetY = 0, -150
    savedVars.countdownOffsetX, savedVars.countdownOffsetY = 0, -60
    tracker:ClearAnchors()
    tracker:SetAnchor(CENTER, GuiRoot, CENTER, savedVars.barOffsetX, savedVars.barOffsetY)
    countdownTracker:ClearAnchors()
    countdownTracker:SetAnchor(CENTER, GuiRoot, CENTER, savedVars.countdownOffsetX, savedVars.countdownOffsetY)
end

local function CreateTracker()
    tracker = WINDOW_MANAGER:CreateTopLevelWindow("WifeyRyticMagmaTrackerWindow")
    tracker:SetDimensions(savedVars.barWidth + savedVars.barHeight + 6, savedVars.barHeight)
    tracker:SetAnchor(CENTER, GuiRoot, CENTER, savedVars.barOffsetX, savedVars.barOffsetY)
    tracker:SetMovable(false)
    tracker:SetMouseEnabled(false)
    tracker:SetClampedToScreen(true)
    tracker:SetHidden(true)

    icon = WINDOW_MANAGER:CreateControl("WifeyRyticMagmaTrackerIcon", tracker, CT_TEXTURE)
    icon:SetDimensions(savedVars.barHeight, savedVars.barHeight)
    icon:SetAnchor(LEFT, tracker, LEFT, 0, 0)
    icon:SetTexture(GetAbilityIcon(testAbilityId))

    bar = WINDOW_MANAGER:CreateControl("WifeyRyticMagmaTrackerBar", tracker, CT_STATUSBAR)
    bar:SetDimensions(savedVars.barWidth, savedVars.barHeight)
    bar:SetAnchor(LEFT, icon, RIGHT, 6, 0)
    bar:SetMinMax(0, 1)
    bar:SetValue(1)
    bar:SetColor(0.85, 0.35, 0.05, 0.95)

    barLabel = WINDOW_MANAGER:CreateControl("WifeyRyticMagmaTrackerBarLabel", bar, CT_LABEL)
    barLabel:SetAnchorFill(bar)
    barLabel:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
    barLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    barLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    barLabel:SetText("MAGMA SHELL")

    local function StartMove(button)
        if button == MOUSE_BUTTON_INDEX_LEFT and savedVars.unlocked then tracker:StartMoving() end
    end
    local function StopMove(button)
        if button == MOUSE_BUTTON_INDEX_LEFT and savedVars.unlocked then
            tracker:StopMovingOrResizing()
            SaveBarPosition()
        end
    end
    for _, control in ipairs({tracker, icon, bar, barLabel}) do
        control:SetHandler("OnMouseDown", function(_, button) StartMove(button) end)
        control:SetHandler("OnMouseUp", function(_, button) StopMove(button) end)
    end
end

local function CreateCountdown()
    countdownTracker = WINDOW_MANAGER:CreateTopLevelWindow("WifeyRyticMagmaCountdownWindow")
    countdownTracker:SetDimensions(400, 180)
    countdownTracker:SetAnchor(CENTER, GuiRoot, CENTER, savedVars.countdownOffsetX, savedVars.countdownOffsetY)
    countdownTracker:SetMovable(false)
    countdownTracker:SetMouseEnabled(false)
    countdownTracker:SetClampedToScreen(true)
    countdownTracker:SetHidden(true)

    countdownLabel = WINDOW_MANAGER:CreateControl("WifeyRyticMagmaCountdownLabel", countdownTracker, CT_LABEL)
    countdownLabel:SetAnchorFill(countdownTracker)
    countdownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countdownLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ApplyCountdownSettings()

    local function StartMove(button)
        if button == MOUSE_BUTTON_INDEX_LEFT and savedVars.unlocked then countdownTracker:StartMoving() end
    end
    local function StopMove(button)
        if button == MOUSE_BUTTON_INDEX_LEFT and savedVars.unlocked then
            countdownTracker:StopMovingOrResizing()
            SaveCountdownPosition()
        end
    end
    for _, control in ipairs({countdownTracker, countdownLabel}) do
        control:SetHandler("OnMouseDown", function(_, button) StartMove(button) end)
        control:SetHandler("OnMouseUp", function(_, button) StopMove(button) end)
    end
end

local function StartMagma(beginTime, endTime, abilityId, effectName, iconName)
    if not savedVars.enabled then return end
    magmaActive = true
    magmaBeginTime = beginTime or GetFrameTimeSeconds()
    magmaEndTime = endTime or magmaBeginTime
    magmaAbilityId = abilityId or 0
    magmaName = (effectName and effectName ~= "") and string.upper(effectName) or string.upper(GetAbilityName(magmaAbilityId) or "MAGMA")
    magmaIcon = (iconName and iconName ~= "") and iconName or GetAbilityIcon(magmaAbilityId)
    testMode = false
    unlockPreview = false
end

local function StopMagma(abilityId)
    if abilityId and magmaAbilityId ~= 0 and abilityId ~= magmaAbilityId then return end
    magmaActive = false
    magmaBeginTime, magmaEndTime, magmaAbilityId = 0, 0, 0
    if not unlockPreview then HideAll() end
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
    stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if not savedVars.enabled or not MAGMA_ABILITIES[abilityId] then return end
    if unitTag ~= "player" then return end

    -- Personal tracker: only the player's own Magma activation may start it.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        StartMagma(beginTime, endTime, abilityId, effectName, iconName)
    elseif changeType == EFFECT_RESULT_FADED then
        StopMagma(abilityId)
    end
end

local function UpdateTracker()
    if not savedVars.enabled or IsMenuOpen() then
        HideAll()
        return
    end

    local now = GetFrameTimeSeconds()
    local beginTime, endTime, abilityId, displayName, displayIcon

    if testMode then
        beginTime, endTime, abilityId = testBeginTime, testEndTime, testAbilityId
        displayName = string.upper(GetAbilityName(abilityId) or "MAGMA SHELL")
        displayIcon = GetAbilityIcon(abilityId)
    elseif magmaActive then
        beginTime, endTime, abilityId = magmaBeginTime, magmaEndTime, magmaAbilityId
        displayName, displayIcon = magmaName, magmaIcon
    elseif savedVars.unlocked and unlockPreview then
        tracker:SetHidden(false)
        countdownTracker:SetHidden(false)
        icon:SetTexture(GetAbilityIcon(testAbilityId))
        bar:SetValue(1)
        barLabel:SetText("MAGMA SHELL  15.0")
        countdownLabel:SetText("5")
        return
    else
        HideAll()
        return
    end

    local remaining = endTime - now
    if remaining <= 0 then
        if testMode then
            testMode = false
            unlockPreview = false
            HideAll()
        else
            StopMagma(abilityId)
        end
        return
    end

    local totalDuration = math.max(0.001, endTime - beginTime)
    local progress = zo_clamp(remaining / totalDuration, 0, 1)

    tracker:SetHidden(false)
    bar:SetValue(progress)
    barLabel:SetText(string.format("%s  %.1f", displayName, remaining))
    if displayIcon and displayIcon ~= "" then icon:SetTexture(displayIcon) end

    if remaining <= 5 then
        countdownTracker:SetHidden(false)
        countdownLabel:SetText(tostring(math.max(1, math.ceil(remaining))))
    elseif not savedVars.unlocked then
        countdownTracker:SetHidden(true)
    end
end

local function TestTracker()
    if not savedVars.enabled then
        d("WifeyRytic Magma Tracker is disabled.")
        return
    end
    testMode = true
    unlockPreview = false
    testBeginTime = GetFrameTimeSeconds()
    testEndTime = testBeginTime + 15
    testAbilityId = 17874
    d("Testing Magma Shell tracker.")
end

local function SetEnabled(value)
    savedVars.enabled = value
    if not value then
        testMode = false
        magmaActive = false
        unlockPreview = false
        HideAll()
    end
end

local function CreateSettings()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "WifeyRytic's Magma Tracker",
        displayName = "WifeyRytic's Magma Tracker",
        author = "WifeyRytic",
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("WifeyRyticMagmaTrackerOptions", panelData)

    local options = {
        { type = "description", text = "Tracks your own Magma Armor, Magma Shell, or Corrosive Armor using ESO's actual effect duration, with a large 5-4-3-2-1 final countdown." },
        { type = "header", name = "General" },
        {
            type = "checkbox", name = "Enable Magma Tracker",
            tooltip = "Master kill switch for the tracker.",
            getFunc = function() return savedVars.enabled end,
            setFunc = function(value) SetEnabled(value) end,
            default = defaults.enabled,
        },
        { type = "header", name = "Position" },
        { type = "button", name = "Unlock Tracker", func = function() SetUnlocked(true) end },
        { type = "button", name = "Lock Tracker", func = function() SetUnlocked(false) end },
        { type = "button", name = "Reset Positions", func = function() ResetPositions() end },
        { type = "header", name = "Countdown" },
        {
            type = "slider", name = "Countdown Size", min = 30, max = 150, step = 2,
            getFunc = function() return savedVars.countdownSize end,
            setFunc = function(value) savedVars.countdownSize = value; ApplyCountdownSettings() end,
            default = defaults.countdownSize,
        },
        {
            type = "colorpicker", name = "Countdown Color",
            getFunc = function() local c=savedVars.countdownColor; return c.r,c.g,c.b,c.a end,
            setFunc = function(r,g,b,a) savedVars.countdownColor={r=r,g=g,b=b,a=a}; ApplyCountdownSettings() end,
            default = {1,0,0,1},
        },
        { type = "header", name = "Testing" },
        { type = "button", name = "Test Magma Tracker", func = function() TestTracker() end },
    }
    LAM:RegisterOptionControls("WifeyRyticMagmaTrackerOptions", options)
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    savedVars = ZO_SavedVars:NewAccountWide("WifeyRyticMagmaTrackerSavedVariables", 1, nil, defaults)

    -- Migrate only the old v1.1 stock countdown color to the new red default.
    -- Any genuinely custom saved color is left untouched.
    local c = savedVars.countdownColor
    if c and math.abs((c.r or 0)-1) < 0.001 and math.abs((c.g or 0)-0.82) < 0.001 and math.abs(c.b or 0) < 0.001 then
        savedVars.countdownColor = {r=1,g=0,b=0,a=c.a or 1}
    end

    CreateTracker()
    CreateCountdown()
    CreateSettings()

    local eventName = ADDON_NAME .. "MagmaEffect"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Update", 50, UpdateTracker)

    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("CurrentSceneChanged", function() UpdateTracker() end)
    end

    SLASH_COMMANDS["/magmaunlock"] = function() SetUnlocked(true) end
    SLASH_COMMANDS["/magmalock"] = function() SetUnlocked(false) end
    SLASH_COMMANDS["/magmatest"] = function() TestTracker() end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
