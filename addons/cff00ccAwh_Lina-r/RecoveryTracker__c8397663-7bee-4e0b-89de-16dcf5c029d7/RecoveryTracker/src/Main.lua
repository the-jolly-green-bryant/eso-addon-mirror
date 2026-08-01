RecoveryTracker = {}
RecoveryTracker.name = "RecoveryTracker"
RecoveryTracker.version = "1.0.0"
RecoveryTracker.author = "You"
RecoveryTracker.savedVars = nil
RecoveryTracker.defaults = {
    enabled = true,
    showHealth = true,
    showMagicka = true,
    showStamina = true,
    showUltimate = true,
    posX = 500,
    posY = 500,
    fontSize = 20,
    scale = 1,
}

local lastTicks = {}
lastTicks[COMBAT_MECHANIC_FLAGS_HEALTH] = {}
lastTicks[COMBAT_MECHANIC_FLAGS_STAMINA] = {}
lastTicks[COMBAT_MECHANIC_FLAGS_MAGICKA] = {}
lastTicks[COMBAT_MECHANIC_FLAGS_ULTIMATE] = {}
lastTicks[COMBAT_MECHANIC_FLAGS_HEALTH]['time'] = GetGameTimeMilliseconds()
lastTicks[COMBAT_MECHANIC_FLAGS_STAMINA]['time'] = GetGameTimeMilliseconds()
lastTicks[COMBAT_MECHANIC_FLAGS_MAGICKA]['time'] = GetGameTimeMilliseconds()
lastTicks[COMBAT_MECHANIC_FLAGS_ULTIMATE]['time'] = GetGameTimeMilliseconds()
lastTicks[COMBAT_MECHANIC_FLAGS_HEALTH]['active'] = false
lastTicks[COMBAT_MECHANIC_FLAGS_STAMINA]['active'] = false
lastTicks[COMBAT_MECHANIC_FLAGS_MAGICKA]['active'] = false
lastTicks["HP"] = 0
lastTicks["STAM"] = 0
lastTicks["MAG"] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_ULTIMATE]['active'] = false
lastTicks[COMBAT_MECHANIC_FLAGS_HEALTH]['value'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_ULTIMATE]['value'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_STAMINA]['value'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_HEALTH]['rps'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_STAMINA]['rps'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_MAGICKA]['rps'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_ULTIMATE]['rps'] = 0
lastTicks[COMBAT_MECHANIC_FLAGS_MAGICKA]['value'] = 0
local lastTickTime
local bars = {}
local startTime = nil
local EM = EVENT_MANAGER
local bars = {}
local labels = {}
local WM = WINDOW_MANAGER
local colors = {
    [COMBAT_MECHANIC_FLAGS_HEALTH] = "|cE57373",
    [COMBAT_MECHANIC_FLAGS_STAMINA] = "|c81C784",
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = "|c4FC3F7",
    [COMBAT_MECHANIC_FLAGS_ULTIMATE] = "|cFFD100"
}
function RecoveryTracker.CreateUI()
    local sv = RecoveryTracker.savedVars

    local control = WM:CreateTopLevelWindow("RecoveryTrackerUI")
    control:SetDimensions(320, 160)
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
    control:SetMovable(true)
    control:SetMouseEnabled(true)
    control:SetClampedToScreen(true)
    control:SetHidden(not sv.enabled)
    control:SetScale(sv.scale)
    control:SetHandler("OnMoveStop", function()
        sv.posX, sv.posY = control:GetLeft(), control:GetTop()
    end)

    local function CreateBar(name, color, offsetY)
        local bg = WM:CreateControl(name .. "BG", control, CT_BACKDROP)
        bg:SetAnchor(TOPLEFT, control, TOPLEFT, 0, offsetY)
        bg:SetDimensions(300, 30)
        bg:SetCenterColor(0, 0, 0, 0.6)
        bg:SetEdgeColor(1, 1, 1, 0.3)
        bg:SetEdgeTexture("", 1, 1, 1)

        local bar = WM:CreateControl(name .. "Bar", bg, CT_STATUSBAR)
        bar:SetAnchorFill()
        bar:SetColor(unpack(color))
        bar:SetMinMax(0, 2000)
        bar:SetValue(0)

        local label = WM:CreateControl(name .. "Label", bg, CT_LABEL)
        label:SetAnchor(CENTER, bg, CENTER, 0, 0)
        label:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", sv.fontSize))
        label:SetColor(1, 0.9, 0.2, 1)

        return bg, bar, label
    end

    -- Bars
    RecoveryTracker.healthBG, RecoveryTracker.healthBar, RecoveryTracker.healthLabel = CreateBar("RecoveryTrackerHealth", {1, 0, 0, 0.8}, 0)
    RecoveryTracker.magickaBG, RecoveryTracker.magickaBar, RecoveryTracker.magickaLabel = CreateBar("RecoveryTrackerMagicka", {0, 0.3, 1, 0.8}, 40)
    RecoveryTracker.staminaBG, RecoveryTracker.staminaBar, RecoveryTracker.staminaLabel = CreateBar("RecoveryTrackerStamina", {0, 0.7, 0, 0.8}, 80)
    RecoveryTracker.ultimateBG, RecoveryTracker.ultimateBar, RecoveryTracker.ultimateLabel = CreateBar("RecoveryTrackerUltimate", {0.5, 0, 0.7, 0.8}, 120)

    RecoveryTracker.UpdateVisibility()

    RecoveryTracker.control = control
end

-- Toggle bar visibility
function RecoveryTracker.UpdateVisibility()
    local sv = RecoveryTracker.savedVars
    if not RecoveryTracker.control then return end

    RecoveryTracker.control:SetHidden(not sv.enabled)
    RecoveryTracker.healthBG:SetHidden(not sv.showHealth)
    RecoveryTracker.magickaBG:SetHidden(not sv.showMagicka)
    RecoveryTracker.staminaBG:SetHidden(not sv.showStamina)
    RecoveryTracker.ultimateBG:SetHidden(not sv.showUltimate)
end
local function OnUpdate(bar, mechanic)
    local now = GetGameTimeMilliseconds()
    
    if mechanic == COMBAT_MECHANIC_FLAGS_HEALTH 
        or mechanic == COMBAT_MECHANIC_FLAGS_MAGICKA 
        or mechanic == COMBAT_MECHANIC_FLAGS_STAMINA or mechanic == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        local elapsed = now - (lastTicks[mechanic]['time'] or now)
        if elapsed > 2000 then 
            elapsed = 2000 
            bar:SetValue(0)
            lastTicks[mechanic]['active'] = false
            EVENT_MANAGER:UnregisterForUpdate("RecoveryBarsUpdate_" .. mechanic)
            return
        end
        bar:SetValue(elapsed)
        
        -- Update the last tick time
    end
end
-- Update on power tick
local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powermax)
    if unitTag ~= "player" then return end

    local bar, label
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        bar, label = RecoveryTracker.healthBar, RecoveryTracker.healthLabel
        local now = GetGameTimeMilliseconds()
        if lastTicks[powerType]['time'] then
            local deltaValue = powerValue - lastTicks[powerType]['value']
            local deltaTime = (now - lastTicks[powerType]['time']) / 1000
            if deltaTime > 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sHealing per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            elseif deltaTime < 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sHealing per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            end
        end
        lastTicks[powerType]['value'] = powerValue
        lastTicks[powerType]['time'] = now
        
    

    elseif powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
        bar, label = RecoveryTracker.magickaBar, RecoveryTracker.magickaLabel
        local now = GetGameTimeMilliseconds()
        if lastTicks[powerType]['time'] then
            local deltaValue = powerValue - lastTicks[powerType]['value']
            local deltaTime = (now - lastTicks[powerType]['time']) / 1000
            if deltaTime > 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sMagicka per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            elseif deltaTime < 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sMagicka per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            end
        end
        lastTicks[powerType]['value'] = powerValue
        lastTicks[powerType]['time'] = now
    elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
        bar, label = RecoveryTracker.staminaBar, RecoveryTracker.staminaLabel
        local now = GetGameTimeMilliseconds()
        if lastTicks[powerType]['time'] then
            local deltaValue = powerValue - lastTicks[powerType]['value']
            local deltaTime = (now - lastTicks[powerType]['time']) / 1000
            if deltaTime > 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sStam per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            elseif deltaTime < 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sStam per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            end
        end
        lastTicks[powerType]['value'] = powerValue
        lastTicks[powerType]['time'] = now
    elseif powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        bar, label = RecoveryTracker.ultimateBar, RecoveryTracker.ultimateLabel
        local now = GetGameTimeMilliseconds()
        if lastTicks[powerType]['time'] then
            local deltaValue = powerValue - lastTicks[powerType]['value']
            local deltaTime = (now - lastTicks[powerType]['time']) / 1000
            if deltaTime > 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sUltimate per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            elseif deltaTime < 0 then
                lastTicks[powerType]['rps'] = deltaValue / deltaTime
                label:SetText(string.format("%sUltimate per second: %d|r", colors[powerType], lastTicks[powerType]['rps']))
            end
        end
        lastTicks[powerType]['value'] = powerValue
        lastTicks[powerType]['time'] = now
    end
    if bar and label then
        EVENT_MANAGER:RegisterForUpdate("RecoveryBarsUpdate_"..powerType, 50, function()
        OnUpdate(bar, powerType)
    end)
    end
end
-- LAM2 settings menu
function RecoveryTracker.CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Recovery Tracker",
        displayName = "|c00FF88Recovery Tracker|r",
        author = RecoveryTracker.author,
        version = RecoveryTracker.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        { type = "checkbox", name = "Enabled",
          getFunc = function() return RecoveryTracker.savedVars.enabled end,
          setFunc = function(v) RecoveryTracker.savedVars.enabled = v; RecoveryTracker.UpdateVisibility() end },

        { type = "checkbox", name = "Show Health",
          getFunc = function() return RecoveryTracker.savedVars.showHealth end,
          setFunc = function(v) RecoveryTracker.savedVars.showHealth = v; RecoveryTracker.UpdateVisibility() end },

        { type = "checkbox", name = "Show Magicka",
          getFunc = function() return RecoveryTracker.savedVars.showMagicka end,
          setFunc = function(v) RecoveryTracker.savedVars.showMagicka = v; RecoveryTracker.UpdateVisibility() end },

        { type = "checkbox", name = "Show Stamina",
          getFunc = function() return RecoveryTracker.savedVars.showStamina end,
          setFunc = function(v) RecoveryTracker.savedVars.showStamina = v; RecoveryTracker.UpdateVisibility() end },

        { type = "checkbox", name = "Show Ultimate",
          getFunc = function() return RecoveryTracker.savedVars.showUltimate end,
          setFunc = function(v) RecoveryTracker.savedVars.showUltimate = v; RecoveryTracker.UpdateVisibility() end },
        { type = "slider", name = "UI Scale", min = 0, max = 10, step = 0.001,
        getFunc = function() return RecoveryTracker.savedVars.scale end,
        setFunc = function(v) RecoveryTracker.savedVars.scale = v
        RecoveryTracker.control:SetScale(v) end,
        },
        { type = "slider", name = "Font Size", min = 14, max = 36, step = 1,
          getFunc = function() return RecoveryTracker.savedVars.fontSize end,
          setFunc = function(v) 
              RecoveryTracker.savedVars.fontSize = v
              RecoveryTracker.healthLabel:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", v))
              RecoveryTracker.magickaLabel:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", v))
              RecoveryTracker.staminaLabel:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", v))
              RecoveryTracker.ultimateLabel:SetFont(string.format("ZoFontGameBold|%d|soft-shadow-thick", v))
          end },

        -- NEW: X position slider
        { type = "slider", name = "X Position", min = 0, max = 2200, step = 1,
          getFunc = function() return RecoveryTracker.savedVars.posX end,
          setFunc = function(v)
              RecoveryTracker.savedVars.posX = v
              RecoveryTracker.control:ClearAnchors()
              RecoveryTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, v, RecoveryTracker.savedVars.posY)
          end },

        -- NEW: Y position slider
        { type = "slider", name = "Y Position", min = 0, max = 1080, step = 1,
          getFunc = function() return RecoveryTracker.savedVars.posY end,
          setFunc = function(v)
              RecoveryTracker.savedVars.posY = v
              RecoveryTracker.control:ClearAnchors()
              RecoveryTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RecoveryTracker.savedVars.posX, v)
          end },

        { type = "button", name = "Reset Position",
          func = function()
              RecoveryTracker.savedVars.posX, RecoveryTracker.savedVars.posY = 500, 500
              RecoveryTracker.control:ClearAnchors()
              RecoveryTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 500, 500)
          end },
    }

    LAM2:RegisterAddonPanel("RecoveryTrackerOptions", panelData)
    LAM2:RegisterOptionControls("RecoveryTrackerOptions", optionsData)
end

-- Initialization
function RecoveryTracker.OnAddOnLoaded(_, addonName)
    if addonName ~= RecoveryTracker.name then return end
    EM:UnregisterForEvent(RecoveryTracker.name, EVENT_ADD_ON_LOADED)

    RecoveryTracker.savedVars = ZO_SavedVars:NewAccountWide("RecoveryTrackerSavedVars", 1, nil, RecoveryTracker.defaults)

    RecoveryTracker.CreateUI()
    RecoveryTracker.CreateSettingsMenu()
    d("RecoveryTracker: Addon Loaded")
    EM:RegisterForEvent(RecoveryTracker.name, EVENT_POWER_UPDATE, OnPowerUpdate)
end
d("Addon Starting")
EM:RegisterForEvent(RecoveryTracker.name, EVENT_ADD_ON_LOADED, RecoveryTracker.OnAddOnLoaded)