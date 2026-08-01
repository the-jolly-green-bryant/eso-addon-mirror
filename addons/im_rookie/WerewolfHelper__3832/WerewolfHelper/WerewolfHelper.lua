WE = {}
WE.name = "WerewolfHelper"
WE.version = "1.0"
WE.variableVersion = 2

WE.inCombatNow = false
WE.hideOnPercentage = true
WE.percentage = 80
WE.hideOnCombat = true

WE.Default = {
    hideOnPercentage = true,
	percentage = 80,
    hideOnCombat = true
}

local LAM = LibAddonMenu2

local function OnCombatChanged(event, isCombat)
    WE.inCombatNow = isCombat
end

local function Initialize()
    EVENT_MANAGER:RegisterForEvent(WE.name, EVENT_PLAYER_COMBAT_STATE, OnCombatChanged)
    LAM:RegisterAddonPanel("WerewolfHelper", WE.panelData)
    LAM:RegisterOptionControls("WerewolfHelper", WE.optionsTable)

    WE.hideOnPercentage = WE.savedVariables.hideOnPercentage
    WE.percentage = WE.savedVariables.percentage
    WE.hideOnCombat = WE.savedVariables.hideOnCombat
end


local function HookSynergy()
    local hooked = SYNERGY.OnSynergyAbilityChanged
    SYNERGY.OnSynergyAbilityChanged = function()
        local synergyName, iconFilename, priority = GetSynergyInfo()
        if synergyName then
            if synergyName == "Devour" then
                if WE.hideOnPercentage or (WE.hideOnCombat and WE.inCombatNow) then
                    local current, max, effectiveMax = GetUnitPower('player', POWERTYPE_WEREWOLF)
                    local seventyPercentOfMax = max * (WE.percentage / 100)
                    local seventyPercentOfEffectiveMax = effectiveMax * (WE.percentage/100)
                    if current > seventyPercentOfMax or current > seventyPercentOfEffectiveMax then
                        priority = 10
                        return
                    end
                end
            end
        end
        hooked(SYNERGY)
    end
end


--------------------------------------
-- LibAddonMenu-2 Manager
--------------------------------------
WE.panelData = {
    type = "panel",
    name = WE.name,
    displayName = "WewewolfHelper options ;D",
    author = "@im_rookie",
    version = WE.version,
    registerForRefresh = true,
    registerForDefaults = true,
}

WE.optionsTable = {
    [1] = {
        type = "description",
        text = 'This addon allows you to hide the "Devour" depending on how much time your werewolf has left or if you are in combat.',
        width = "full",
    },
    [2] = {
        type = "divider",
        width = "full",
        alpha = 1,
    },
    [3] = {
        type = "checkbox",
        name = "Use Percentge",
        width = "full",
        tooltip = "Use the werewolf percentage to hide the synergy",
        default = 80,
        requiresReload = true,
        getFunc = function() return WE.savedVariables.hideOnPercentage end,
        setFunc = function(value)
            WE.savedVariables.hideOnPercentage = value
            WE.hideOnPercentage = value
        end,
    },
    [4] = {
        type = "slider",
        name = "Percentage:",
        width = "full",
        tooltip = "If the percentage is lower than this number the synergy will appear.",
        min = 0,
        max = 100,
        requiresReload = true,
        disabled = function() return not WE.hideOnPercentage end,
        getFunc = function() return WE.savedVariables.percentage end,
        setFunc = function(value)
            WE.savedVariables.percentage = value
            WE.percentage = value
        end,
    },
    [5] = {
        type = "checkbox",
        name = "Hide on combat",
        width = "full",
        tooltip = "this hide the synergy if you are in combat ;D",
        requiresReload = true,
        getFunc = function() return WE.savedVariables.hideOnCombat end,
        setFunc = function(value)
            WE.savedVariables.hideOnCombat = value
            WE.hideOnCombat = value
        end,
    },
}

local function OnAddOnLoaded(event, addonName)
    if addonName == WE.name then
        WE.savedVariables = ZO_SavedVars:NewAccountWide("WerewolfHelperVariables", WE.variableVersion, nil, WE.Default, GetWorldName())
        Initialize()
        HookSynergy()
        EVENT_MANAGER:UnregisterForEvent(WE.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(WE.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)