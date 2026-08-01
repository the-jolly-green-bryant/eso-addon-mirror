--[[

Auto Handle Shared Quests
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

AutoHandleSharedQuests = AutoHandleSharedQuests or {}

function AutoHandleSharedQuests.buildAddonMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local AddonName = AutoHandleSharedQuests.name

    local panelData = {
        type = "panel",
        name = AddonName,
        displayName = "|c70C0DE" .. AddonName .. "|r",
        author = AutoHandleSharedQuests.author,
        version = AutoHandleSharedQuests.version,
        website = AutoHandleSharedQuests.website,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "dropdown",
            name = GetString(SI_AHSQ_DESC_AVA),
            tooltip = GetString(SI_AHSQ_TT_AVA),
            choices = {GetString(SI_AHSQ_ACTION_NONE), GetString(SI_AHSQ_ACTION_ACCEPT), GetString(SI_AHSQ_ACTION_DECLINE)},
            choicesValues = {0, 1, 2},
            getFunc = function() return AutoHandleSharedQuests.SavedVars.ActionAvA end,
            setFunc = function(value) AutoHandleSharedQuests.SavedVars.ActionAvA = value end,
            default = AutoHandleSharedQuests.SavedVarsDefault.ActionAvA,
        },
        {
            type = "dropdown",
            name = GetString(SI_AHSQ_DESC_PVE),
            tooltip = GetString(SI_AHSQ_TT_PVE),
            choices = {GetString(SI_AHSQ_ACTION_NONE), GetString(SI_AHSQ_ACTION_ACCEPT), GetString(SI_AHSQ_ACTION_DECLINE)},
            choicesValues = {0, 1, 2},
            getFunc = function() return AutoHandleSharedQuests.SavedVars.ActionPvE end,
            setFunc = function(value) AutoHandleSharedQuests.SavedVars.ActionPvE = value end,
            default = AutoHandleSharedQuests.SavedVarsDefault.ActionPvE,
        },
    }

    LAM:RegisterAddonPanel(AddonName.."_Options", panelData)
    LAM:RegisterOptionControls(AddonName.."_Options", optionsTable)
end