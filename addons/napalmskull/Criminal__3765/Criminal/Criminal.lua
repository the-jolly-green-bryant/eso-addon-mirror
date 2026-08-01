local function setPreventAttackingInnocents(value)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, value)
end

local function setPreventStealing(preventStealingPlaced)
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_PREVENT_STEALING_PLACED, preventStealingPlaced)
end

local function setAutoLootStolen(autoLootStolen)
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, autoLootStolen)
end

local Criminal = {
    name = 'Criminal',
    variableVersion = 1,
    default = {
        toggling_PreventAttackingInnocents = false,
        toggling_PreventStealingPlaced = false,
        toggling_AutolootStolen = false,
    }
}

local UNIT_PLAYER = 'player'

local function applyStealthState(stealthState)
    local hidden = stealthState > STEALTH_STATE_HIDING

    if Criminal.current.toggling_PreventAttackingInnocents then
        if hidden then
            setPreventAttackingInnocents(0)
        else
            setPreventAttackingInnocents(1)
        end
    end

    if Criminal.current.toggling_PreventStealingPlaced then
        if hidden then
            setPreventStealing(0)
        else
            setPreventStealing(1)
        end
    end

    if Criminal.current.toggling_AutolootStolen then
        if hidden then
            setAutoLootStolen(1)
        else
            setAutoLootStolen(0)
        end
    end
end

local function OnAddonLoaded(event, name)
    if name ~= Criminal.name then return end

    EVENT_MANAGER:UnregisterForEvent(Criminal.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

    Criminal.current = ZO_SavedVars:NewAccountWide('saved'..Criminal.name, Criminal.variableVersion, nil, Criminal.default)

    EVENT_MANAGER:RegisterForEvent(Criminal.name, EVENT_STEALTH_STATE_CHANGED, function (eventCode, unitTag, stealthState)
        if unitTag == UNIT_PLAYER then
            applyStealthState(stealthState)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(Criminal.name, EVENT_PLAYER_ACTIVATED, function (eventCode, initial)
        applyStealthState(GetUnitStealthState(UNIT_PLAYER))
    end)

    LibAddonMenu2:RegisterAddonPanel(Criminal.name, {
        type = 'panel',
        name = 'Criminal',
        slashCommand = '/crimeoptions',
        registerForRefresh = true,
    })
    LibAddonMenu2:RegisterOptionControls(Criminal.name, {
        {
            type = 'checkbox',
            name = 'Toggle "' .. GetString(SI_INTERFACE_OPTIONS_COMBAT_PREVENT_ATTACKING_INNOCENTS) .. '"',
            tooltip = 'When you are hidden "' .. GetString(SI_INTERFACE_OPTIONS_COMBAT_PREVENT_ATTACKING_INNOCENTS) .. '" is turned off, otherwise it is on.',
            default = Criminal.default.toggling_PreventAttackingInnocents,
            registerForRefresh = true,
            getFunc = function()
                return Criminal.current.toggling_PreventAttackingInnocents
            end,
            setFunc = function(enabled)
                Criminal.current.toggling_PreventAttackingInnocents = enabled
            end,
        },
        {
            type = 'checkbox',
            name = 'Toggle "' .. GetString(SI_INTERFACE_OPTIONS_LOOT_PREVENT_STEALING_PLACED) .. '"',
            tooltip = 'When you are hidden "' .. GetString(SI_INTERFACE_OPTIONS_LOOT_PREVENT_STEALING_PLACED) .. '" is turned off, otherwise it is on.',
            default = Criminal.default.toggling_PreventStealingPlaced,
            registerForRefresh = true,
            getFunc = function()
                return Criminal.current.toggling_PreventStealingPlaced
            end,
            setFunc = function(enabled)
                Criminal.current.toggling_PreventStealingPlaced = enabled
            end,
        },
        {
            type = 'checkbox',
            name = 'Toggle "' .. GetString(SI_INTERFACE_OPTIONS_LOOT_USE_AUTOLOOT_STOLEN) .. '"',
            tooltip = 'When you are hidden "' .. GetString(SI_INTERFACE_OPTIONS_LOOT_USE_AUTOLOOT_STOLEN) .. '" is turned on, otherwise it is off.',
            default = Criminal.default.toggling_AutolootStolen,
            registerForRefresh = true,
            getFunc = function()
                return Criminal.current.toggling_AutolootStolen
            end,
            setFunc = function(enabled)
                Criminal.current.toggling_AutolootStolen = enabled
            end,
        },
    })
end

EVENT_MANAGER:RegisterForEvent(Criminal.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
