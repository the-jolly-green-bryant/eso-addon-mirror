-- VaultTracker Addon
VaultTracker = {}
VaultTracker.name = "VaultTracker"
VaultTracker.version = "1.1.0"
VaultTracker.author = "Awh_Lina"
VaultTracker.settingsVersion = 1
VaultTracker.addonName = "VaultTracker"

-- Default settings
VaultTracker.defaultSettings = {
    showCost = true,
    showStacks = true,
    showAbility = true,
    showNotif = true,
    fontSize = 33,
    fontColor = "FFFFFF",
    posX = 500,
    posY = 520,
}

-- Current state
VaultTracker.db = nil
VaultTracker.currentCost = 0
VaultTracker.currentStacks = 0
VaultTracker.currentAbility = ""
VaultTracker.vaultType = ""
VaultTracker.notifTimer = 4000 -- ms
VaultTracker.notifActive = false
VaultTracker.notifStartTime = 0
VaultTracker.nextCost = 0
VaultTracker.activeVaultId = nil
VaultTracker.endTime = true
-- Vault Info
VaultTracker.VaultInfo = {
    [214996] = {abilityId = 214996,abilityName = "Vault", cost = GetAbilityCost(214996), texture = GetAbilityIcon(214996)},
    [214997] = {abilityId = 214997,abilityName = "Vault Fatigue", cost = GetAbilityCost(214996), texture = GetAbilityIcon(214997)},

}

---------------------------------
-- GUI Creation
---------------------------------
function VaultTrackerCreateGUI()
    -- Create main container
    VaultTracker.control = WINDOW_MANAGER:CreateControlFromVirtual("VaultTrackerContainer", GuiRoot, "VaultTrackerContainer")
    
    -- Labels
    VaultTracker.costLabel = VaultTracker.control:GetNamedChild("CostLabel")
    VaultTracker.stackLabel = VaultTracker.control:GetNamedChild("StackLabel")
    VaultTracker.abilityLabel = VaultTracker.control:GetNamedChild("AbilityLabel")
    VaultTracker.notifLabel = VaultTracker.control:GetNamedChild("NotifLabel")
    VaultTracker.timerLabel = VaultTracker.control:GetNamedChild("TimerLabel")
    -- Apply settings
    VaultTracker:ApplySettings()
    
    -- Position
    VaultTracker.control:ClearAnchors()
    VaultTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, VaultTracker.db.posX, VaultTracker.db.posY)
end

function VaultTracker:ApplySettings()
    local fontString = string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", VaultTracker.db.fontSize)
    local color = ZO_ColorDef:New(VaultTracker.db.fontColor):UnpackRGBA()
    
    if VaultTracker.costLabel then
        VaultTracker.costLabel:SetFont(fontString)
        VaultTracker.costLabel:SetColor(color)
        VaultTracker.costLabel:SetHidden(not VaultTracker.db.showCost)
    end
    if VaultTracker.stackLabel then
        VaultTracker.stackLabel:SetFont(fontString)
        VaultTracker.stackLabel:SetColor(color)
        VaultTracker.stackLabel:SetHidden(not VaultTracker.db.showStacks)
    end
    if VaultTracker.abilityLabel then
        VaultTracker.abilityLabel:SetFont(fontString)
        VaultTracker.abilityLabel:SetColor(color)
        VaultTracker.abilityLabel:SetHidden(not VaultTracker.db.showAbility)
    end
    if VaultTracker.notifLabel then
        VaultTracker.notifLabel:SetFont(fontString)
        VaultTracker.notifLabel:SetColor(color)
        VaultTracker.notifLabel:SetHidden(true)
    end
    if VaultTracker.timerLabel then
        VaultTracker.timerLabel:SetFont(fontString)
        VaultTracker.timerLabel:SetColor(color)
        VaultTracker.timerLabel:SetHidden(true)
    end
end

---------------------------------
-- Cost Calculation
---------------------------------
function VaultTrackerCalculateNextCost(currentCost, currentStacks)
    return math.ceil(currentCost * (1 + 0.33) ^ currentStacks)
end

function VaultTrackerUpdateLabels(endTime)
    if VaultTracker.costLabel then
        VaultTracker.costLabel:SetText(string.format("|c%sNext Cost: %d|r",VaultTracker.db.fontColor, VaultTracker.nextCost))
    end
    if VaultTracker.stackLabel then
        VaultTracker.stackLabel:SetText(string.format("|c%sStacks: %d|r",VaultTracker.db.fontColor, VaultTracker.currentStacks))
    end
    if VaultTracker.abilityLabel then
        VaultTracker.abilityLabel:SetText(string.format("|c%sAbility: %s|r",VaultTracker.db.fontColor, VaultTracker.currentAbility))
    end
    if VaultTracker.timerLabel then
        VaultTracker.timerLabel:SetHidden(false)
    end
end

---------------------------------
-- Notification Timer
---------------------------------
function VaultTrackerUpdateTimers()
    if VaultTracker.notifActive then
        local currentTime = GetGameTimeMilliseconds()
        local time = currentTime - VaultTracker.endTime
        VaultTracker.timerLabel:SetText(string.format("|c%sSeconds: %.2f|r", VaultTracker.db.fontColor, time))
        if currentTime - VaultTracker.notifStartTime >= VaultTracker.notifTimer then

            if VaultTracker.notifLabel then VaultTracker.notifLabel:SetHidden(true) end
            VaultTracker.notifActive = false
            VaultTracker.timerLabel:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("VaultTrackerNotifTimer")
        end
    end
end

---------------------------------
-- Combat Event Handling
---------------------------------
function VaultTrackerOnCombatEvent(eventCode, result, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, effectbuffType, effectBuffTypeUndep, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if unitName ~= GetUnitName("player") then
        return
    end
    if result == EFFECT_RESULT_FULL_REFRESH and abilityId == VaultTracker.VaultInfo[abilityId].abilityId or result == EFFECT_RESULT_GAINED and abilityId == VaultTracker.VaultInfo[abilityId].abilityId then
        VaultTracker.activeVaultId = abilityId
        VaultTracker.currentAbility = VaultTracker.VaultInfo[abilityId].abilityName
        if abilityId == 214997 then
            VaultTracker.vaultType = "Fatigue"
        end
        if abilityId == 214996 then
            VaultTracker.currentCost = VaultTracker.VaultInfo[abilityId].cost
        VaultTracker.currentStacks = stackCount
        VaultTracker.nextCost = VaultTrackerCalculateNextCost(VaultTracker.currentCost, VaultTracker.currentStacks)
        elseif result == ACTION_RESULT_EFFECT_GAINED and abilityId == 214997 then
            VaultTracker.currentCost = GetAbilityCost(214996)
        VaultTracker.currentStacks = 0
        VaultTracker.nextCost = VaultTracker.currentCost
        
        end
        VaultTrackerUpdateLabels()
        if VaultTracker.db.showNotif then
            VaultTracker.notifLabel:SetText(string.format("Activated %s", VaultTracker.currentAbility))
            VaultTracker.notifLabel:SetHidden(false)
            VaultTracker.notifActive = true
            VaultTracker.notifStartTime = GetGameTimeMilliseconds()
            VaultTracker.endTime = endTime
            EVENT_MANAGER:RegisterForUpdate("VaultTrackerNotifTimer", 100, function() VaultTrackerUpdateTimers() end)
        end
    elseif result == EFFECT_RESULT_FADED and abilityId == VaultTracker.activeVaultId then
        VaultTracker.activeVaultId = nil
        VaultTracker.currentAbility = ""

        if abilityId == 214997 then
            VaultTracker.currentCost = GetAbilityCost(214996)
        VaultTracker.nextCost = VaultTracker.currentCost
        VaultTracker.currentStacks = stackCount
        elseif abilityId == 214996 then
            VaultTracker.currentCost = GetAbilityCost(214996)
        VaultTracker.nextCost = VaultTracker.currentCost
        VaultTracker.currentStacks = 0
        
        end
        VaultTrackerUpdateLabels()
        
        if VaultTracker.db.showNotif then
            VaultTracker.notifLabel:SetText("Vault expired")
            VaultTracker.notifLabel:SetHidden(false)
            VaultTracker.nextCost = VaultTracker.currentCost
            VaultTracker.currentStacks = 0
            VaultTrackerUpdateLabels()
            VaultTracker.currentAbility = ""
            
            VaultTracker.notifActive = true
            VaultTracker.notifStartTime = GetGameTimeMilliseconds()
            EVENT_MANAGER:RegisterForUpdate("VaultTrackerNotifTimer", 100, function() VaultTrackerUpdateTimers() end)
        end
    end
end

---------------------------------
-- LibAddonMenu2 Setup
---------------------------------
local function VaultTrackerSetupAddonMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    
    local panelData = {
        type = "panel",
        name = VaultTracker.name,
        displayName = VaultTracker.name,
        author = VaultTracker.author,
        version = VaultTracker.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    LAM:RegisterAddonPanel("VaultTrackerSettingsPanel", panelData)
    
    local optionsData = {
        {
            type = "checkbox",
            name = "Show Cost",
            getFunc = function() return VaultTracker.db.showCost end,
            setFunc = function(value) VaultTracker.db.showCost = value; VaultTracker:ApplySettings() end,
            default = VaultTracker.defaultSettings.showCost,
        },
        {
            type = "checkbox",
            name = "Show Stacks",
            getFunc = function() return VaultTracker.db.showStacks end,
            setFunc = function(value) VaultTracker.db.showStacks = value; VaultTracker:ApplySettings() end,
            default = VaultTracker.defaultSettings.showStacks,
        },
        {
            type = "checkbox",
            name = "Show Ability",
            getFunc = function() return VaultTracker.db.showAbility end,
            setFunc = function(value) VaultTracker.db.showAbility = value; VaultTracker:ApplySettings() end,
            default = VaultTracker.defaultSettings.showAbility,
        },
        {
            type = "checkbox",
            name = "Show Notification",
            getFunc = function() return VaultTracker.db.showNotif end,
            setFunc = function(value) VaultTracker.db.showNotif = value end,
            default = VaultTracker.defaultSettings.showNotif,
        },
        {
            type = "slider",
            name = "Font Size",
            min = 1, max = 90, step = 1,
            getFunc = function() return VaultTracker.db.fontSize end,
            setFunc = function(value) VaultTracker.db.fontSize = value; VaultTracker:ApplySettings() end,
            default = VaultTracker.defaultSettings.fontSize,
        },
        {
            type = "editbox",
            name = "Font Color",
            getFunc = function() return VaultTracker.db.fontColor end,
            setFunc = function(value) VaultTracker.db.fontColor = value; VaultTracker:ApplySettings() end,
            default = VaultTracker.defaultSettings.fontColor,
        },
        {
            type = "slider",
            name = "Position X",
            min = 0, max = 1980, step = 10,
            getFunc = function() return VaultTracker.db.posX end,
            setFunc = function(value) VaultTracker.db.posX = value; VaultTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, value, VaultTracker.db.posY) end,
            default = VaultTracker.defaultSettings.posX,
        },
        {
            type = "slider",
            name = "Position Y",
            min = 0, max = 1080, step = 10,
            getFunc = function() return VaultTracker.db.posY end,
            setFunc = function(value) VaultTracker.db.posY = value; VaultTracker.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, VaultTracker.db.posX, value) end,
            default = VaultTracker.defaultSettings.posY,
        },
    }
    
    LAM:RegisterOptionControls("VaultTrackerSettingsPanel", optionsData)
end

---------------------------------
-- Addon Loaded Handler
---------------------------------
local function VaultTrackerInitialize(eventCode, addonName)
    if addonName ~= VaultTracker.addonName then return end

    -- Saved variables
    VaultTracker.db = ZO_SavedVars:NewAccountWide("VaultTrackerSettings", VaultTracker.settingsVersion, nil, VaultTracker.defaultSettings)

    -- Create GUI
    VaultTrackerCreateGUI()

    -- Register events
    EVENT_MANAGER:RegisterForEvent(VaultTracker.addonName, EVENT_EFFECT_CHANGED, VaultTrackerOnCombatEvent)

    -- Setup LAM
    VaultTrackerSetupAddonMenu()
end

EVENT_MANAGER:RegisterForEvent(VaultTracker.addonName, EVENT_ADD_ON_LOADED, VaultTrackerInitialize)