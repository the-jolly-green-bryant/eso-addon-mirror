local SIT = SkillIssueTracker
local menu = SIT.menu
local LAM = LibAddonMenu2

local MARK_SQUARE = TARGET_MARKER_TYPE_ONE
local MARK_STAR = TARGET_MARKER_TYPE_TWO
local MARK_CIRCLE = TARGET_MARKER_TYPE_THREE
local MARK_TRIANGLE = TARGET_MARKER_TYPE_FOUR
local MARK_MOON = TARGET_MARKER_TYPE_FIVE
local MARK_OBLIVION = TARGET_MARKER_TYPE_SIX
local MARK_SWORDS = TARGET_MARKER_TYPE_SEVEN
local MARK_SKULL = TARGET_MARKER_TYPE_EIGHT

local DEFAULT_PRESET_NAME = "default"

menu.panelControl = nil
menu.newPresetName = ""
menu.presetChoices = {
    DEFAULT_PRESET_NAME
}

menu.refreshPanel = function()
    if menu.panelControl then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", menu.panelControl)
    end
end

menu.getPresetChoices = function()
    local choices = {}
    for presetName, _ in pairs(SIT.savedVars.presets) do
        table.insert(choices, presetName)
    end
    table.sort(choices)
    return choices
end

menu.isDefaultLoaded = function()
    return SIT.savedVars.usingPreset == DEFAULT_PRESET_NAME
end

menu.makeWeightSlider = function(label, key, tooltip, max)
    return {
        type    = "slider",
        name    = label,
        tooltip = tooltip,
        min     = 0,
        max     = max,
        step    = 1,
        getFunc  = function()
            return SIT.savedVars.presets[SIT.savedVars.usingPreset][key]
        end,
        setFunc  = function(value)
            if SIT.savedVars.usingPreset == DEFAULT_PRESET_NAME then
                menu.refreshPanel()
                return
            end
            SIT.savedVars.presets[SIT.savedVars.usingPreset][key] = value
        end,
        disabled = menu.isDefaultLoaded,
        default  = SIT.defaultVars.presets[DEFAULT_PRESET_NAME][key],
    }
end

menu.initialize = function()

    ZO_Dialogs_RegisterCustomDialog("SIT_CONFIRM_RESET", {
        title = { text = "Reset Saved Variables" },
        mainText = { text = "Are you sure you want to reset all settings and presets to their defaults? This cannot be undone." },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function()
                    SIT.savedVars.presets = ZO_DeepTableCopy(SIT.defaultVars.presets)
                    SIT.savedVars.usingPreset = DEFAULT_PRESET_NAME
                    SIT.savedVars.enabled = SIT.defaultVars.enabled
                    SIT.savedVars.markerType = SIT.defaultVars.markerType
                    ReloadUI()
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    })

    menu.presetChoices = menu.getPresetChoices()

    local panelData = {
        type             = "panel",
        name             = SIT.menuName,
        displayName      = SIT.menuName,
        author           = SIT.author,
        version          = SIT.version,
        slashCommand     = SIT.command,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "description",
            text = "SkillIssueTracker is a simple addon that automatically marks enemies in battlegrounds.",
        },
        {
            type    = "checkbox",
            name    = "Enable Addon",
            tooltip = "Turn SkillIssueTracker on or off.",
            getFunc = function() return SIT.savedVars.enabled end,
            setFunc = function(value)
                SIT.savedVars.enabled = value
                SIT.events.OnPlayerActivated()
            end,
            default = function() return SIT.defaultVars.enabled end,
        },
        {
            type    = "dropdown",
            name    = "Target Marker Type",
            tooltip = "Select the target marker type to use for marking enemies.",
            choices = { "Square", "Star", "Circle", "Triangle", "Moon", "Oblivion", "Swords", "Skull" },
            getFunc = function()
                local markerType = SIT.savedVars.markerType
                if markerType == MARK_SQUARE   then return "Square"
                elseif markerType == MARK_STAR      then return "Star"
                elseif markerType == MARK_CIRCLE    then return "Circle"
                elseif markerType == MARK_TRIANGLE  then return "Triangle"
                elseif markerType == MARK_MOON      then return "Moon"
                elseif markerType == MARK_OBLIVION  then return "Oblivion"
                elseif markerType == MARK_SWORDS    then return "Swords"
                else return "Skull" end
            end,
            setFunc = function(value)
                if value == "Square"  then SIT.savedVars.markerType = MARK_SQUARE
                elseif value == "Star"     then SIT.savedVars.markerType = MARK_STAR
                elseif value == "Circle"   then SIT.savedVars.markerType = MARK_CIRCLE
                elseif value == "Triangle" then SIT.savedVars.markerType = MARK_TRIANGLE
                elseif value == "Moon"     then SIT.savedVars.markerType = MARK_MOON
                elseif value == "Oblivion" then SIT.savedVars.markerType = MARK_OBLIVION
                elseif value == "Swords"   then SIT.savedVars.markerType = MARK_SWORDS
                elseif value == "Skull"    then SIT.savedVars.markerType = MARK_SKULL end
            end,
            default = function() return SIT.defaultVars.markerType end,
        },
        { type = "header", name = "Scoring Presets" },
        {
            type    = "dropdown",
            name    = "Preset",
            tooltip = "Select a preset to use and edit. The 'default' preset cannot be deleted.",
            choices = menu.presetChoices,
            getFunc = function()
                return SIT.savedVars.usingPreset
            end,
            setFunc = function(value)
                SIT.savedVars.usingPreset = value
                menu.refreshPanel()
            end,
        },
        menu.makeWeightSlider("Low Level",        "lowLevel",             "Priority bonus for players below level 50.", 1000),
        menu.makeWeightSlider("Low CP",           "lowCP",                "Priority bonus for players below 160 CP.", 1000),
        menu.makeWeightSlider("Damage Done",      "damageDone",           "Priority weight for total damage dealt.", 1000),
        menu.makeWeightSlider("Healing Done",     "healingDone",          "Priority weight for total healing done.", 1000),
        menu.makeWeightSlider("Kills",            "kills",                "Priority weight per kill.", 1000),
        menu.makeWeightSlider("Assists",          "assists",              "Priority weight per assist.", 1000),
        menu.makeWeightSlider("Deaths",           "deaths",               "Priority weight per death (proven killable).", 1000),
        menu.makeWeightSlider("Close Call",       "almostDied",           "Priority bonus for players who nearly died this life.", 1000),
        menu.makeWeightSlider("Permablocker",     "permablockerPenalty",  "Penalty per blocked hit.", 1000),
        menu.makeWeightSlider("Shield Spammer",   "shieldSpammerPenalty", "Penalty per shielded hit.", 1000),
        menu.makeWeightSlider("Tanked Damage",    "tankedDamagePenalty",  "Penalty for absorbing a lot of damage without dying.", 1000),
        menu.makeWeightSlider("Max Health",       "maxHealthPenalty",     "Penalty for high max health.", 1000),
        menu.makeWeightSlider("Ignore after",     "ignoreIfUnseenFor",    "Ignore player if unseen alive for some seconds, or 0 to never ignore.", 180),
        {
            type    = "button",
            name    = "Delete",
            warning = "Requires a reload.",
            tooltip = "Delete the selected preset.",
            func    = function()
                if menu.isDefaultLoaded() then return end
                local deleted = SIT.savedVars.usingPreset
                SIT.savedVars.presets[deleted] = nil
                if SIT.savedVars.usingPreset == deleted then
                    SIT.savedVars.usingPreset = "default"
                end
                zo_callLater(function() ReloadUI() end, 500)
                
            end,
            disabled = menu.isDefaultLoaded,
        },
        { type = "header", name = "New Preset" },
        {
            type    = "editbox",
            name    = "Preset Name",
            tooltip = "Enter a name for the new preset.",
            getFunc = function() return menu.newPresetName end,
            setFunc = function(value)
                menu.newPresetName = value
            end,
        },
        {
            type    = "button",
            name    = "Create",
            warning = "Requires a reload.",
            tooltip = "Create a new preset with the specified name.",
            disabled = function() return menu.newPresetName == "" end,
            func    = function()
                local newName = menu.newPresetName
                if newName == "" then return end
                if SIT.savedVars.presets[newName] then
                    d("|c44ff44[SkillIssueTracker]|r Preset '" .. newName .. "' already exists.")
                    return
                end

                local defaultCopy = ZO_DeepTableCopy(SIT.defaultVars.presets[DEFAULT_PRESET_NAME])
                SIT.savedVars.presets[newName] = defaultCopy
                SIT.savedVars.usingPreset = newName
                menu.newPresetName = ""
                zo_callLater(function() ReloadUI() end, 500)
            end
        },
        { type = "header", name = "Warning Zone" },
        {
            type    = "button",
            name    = "Reset saved variables",
            warning = "This will wipe all presets and settings.",
            tooltip = "Reset all settings and presets to their default values.",
            func    = function()
                ZO_Dialogs_ShowDialog("SIT_CONFIRM_RESET")
            end,
        },
    }

    menu.panelControl = LAM:RegisterAddonPanel(SIT.name .. "_Menu", panelData)
    LAM:RegisterOptionControls(SIT.name .. "_Menu", optionsTable)
end