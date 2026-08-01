VoidsExecuteBlocker = {}

VoidsExecuteBlocker.name = "VoidsExecuteBlocker"
VoidsExecuteBlocker.Version = "1.1"

-- List of execute abilities grouped by type
local executeAbilities = {
    MagesWrath = {18718, 19123, 19109}, -- Sorcerer
    Impale = {33386, 34843, 34851}, -- Nightblade
    Executioner = {28302, 38823, 38819} -- Two-Handed (33% HP threshold)
}

local settings = {
    blockMagesWrath = true,
    blockImpale = true,
    blockExecutioner = true
}

function VoidsExecuteBlocker:GetTargetHealthPercent()
    local targetUnitTag = "reticleover"
    local currentHP, maxHP = GetUnitPower(targetUnitTag, POWERTYPE_HEALTH)

    if maxHP and maxHP > 0 then
        return (currentHP / maxHP) * 100
    end

    return 100 -- Default to 100% if no valid target
end

function VoidsExecuteBlocker:Initialize()
    -- Load saved settings
    settings = ZO_SavedVars:NewAccountWide("VoidsExecuteBlockerSettings", 1, nil, settings)

    -- Register settings menu
    VoidsExecuteBlocker:CreateSettingsMenu()

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        local slotNum = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
        local abilityId = GetSlotBoundId(slotNum)
        local targetHealthPercent = VoidsExecuteBlocker:GetTargetHealthPercent()

        -- Determine required HP threshold based on ability type
        local requiredHP = 25 -- Default threshold for normal executes

        if settings.blockExecutioner and VoidsExecuteBlocker:IsAbilityInList(abilityId, executeAbilities.Executioner) then
            requiredHP = 33
        elseif settings.blockMagesWrath and VoidsExecuteBlocker:IsAbilityInList(abilityId, executeAbilities.MagesWrath) then
            requiredHP = 25
        elseif settings.blockImpale and VoidsExecuteBlocker:IsAbilityInList(abilityId, executeAbilities.Impale) then
            requiredHP = 25
        else
            return false -- Allow casting since blocking is disabled for this ability
        end

        -- Block ability if target health is above threshold
        if targetHealthPercent > requiredHP then
            return true -- Silently blocks ability cast without error messages
        end
    end)
end

function VoidsExecuteBlocker:IsAbilityInList(abilityId, abilityList)
    for _, id in ipairs(abilityList) do
        if abilityId == id then
            return true
        end
    end
    return false
end

function VoidsExecuteBlocker:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Void's Execute Blocker", -- Updated name
        author = "Void",
        version = VoidsExecuteBlocker.Version,
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Block Mages' Wrath",
            tooltip = "Prevents casting Mages' Wrath unless target is below 25% HP",
            getFunc = function() return settings.blockMagesWrath end,
            setFunc = function(value) settings.blockMagesWrath = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Block Impale",
            tooltip = "Prevents casting Impale unless target is below 25% HP",
            getFunc = function() return settings.blockImpale end,
            setFunc = function(value) settings.blockImpale = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Block Executioner",
            tooltip = "Prevents casting Executioner unless target is below 33% HP",
            getFunc = function() return settings.blockExecutioner end,
            setFunc = function(value) settings.blockExecutioner = value end,
            default = true,
        }
    }

    LAM:RegisterAddonPanel("VoidsExecuteBlockerPanel", panelData)
    LAM:RegisterOptionControls("VoidsExecuteBlockerPanel", optionsData)
end

function VoidsExecuteBlocker.OnAddOnLoaded(event, addonName)
    if addonName == VoidsExecuteBlocker.name then
        VoidsExecuteBlocker:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(VoidsExecuteBlocker.name, EVENT_ADD_ON_LOADED, VoidsExecuteBlocker.OnAddOnLoaded)