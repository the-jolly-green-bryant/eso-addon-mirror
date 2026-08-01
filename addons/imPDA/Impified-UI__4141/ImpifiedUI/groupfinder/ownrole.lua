local feature = {}

local MEMO_STATE = false

function feature.Setup(addon)
    if not addon.savedVariables.groupFinder.turnOffShowOwnRole then return end

    ZO_PreHook(GROUP_FINDER_SEARCH_MANAGER, 'ExecuteSearch', function()
        SetGroupFinderFilterEnforceRoles(MEMO_STATE)
    end)

    ZO_PostHook(_G, 'SetGroupFinderFilterEnforceRoles', function(checked)
        MEMO_STATE = checked
    end)
end

function feature.GetSettingsControl(addon)
    return {
        {
            type = 'checkbox',
            name = 'Show all roles groups by default',
            getFunc = function() return addon.savedVariables.groupFinder.turnOffShowOwnRole end,
            setFunc = function(value) addon.savedVariables.groupFinder.turnOffShowOwnRole = value end,
            tooltip = ('Keeps "%s" OFF by default if Group Finder filters'):format(GetString(SI_GROUP_FINDER_FILTERS_OWN_ROLE)),
            requiresReload = true,
        },
    }
end

assert(ImpifiedUI, 'ImpifiedUI not found')
ImpifiedUI:AddFeature(feature)
