-- Create the global namespace for the addon
-- MuffinsSetRecipeTracker = MuffinsSetRecipeTracker or {}

-- Create a local shortcut for global
local MSRT = MuffinsSetRecipeTracker

-- Dependencies
local LAM = LibAddonMenu2

-- Holds our SavedVariable data
local function GetSettings()
    if MSRT.SavedVars.useGlobalSettings then
        return MSRT.GlobalSavedVars
    else
        return MSRT.SavedVars
    end
end

MSRT.GetSettings = GetSettings

function MSRT.CreateSettingsMenu(defaults)
    local panel = {
        type                = "panel",
        name                = MSRT.name,
        author              = MSRT.author,
        version             = "" .. MSRT.version,
        slashCommand        = "/msrt",
        website             = MSRT.website,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(MSRT.name, panel)

    -- Build character name list for the motif dropdown
    local charNames = {}
    for i = 1, GetNumCharacters() do
        local rawName = GetCharacterInfo(i)
        if rawName and rawName ~= "" then
            charNames[#charNames + 1] = zo_strformat("<<1>>", rawName)
        end
    end

    -- Build nickname edit boxes first so we can insert them into the submenu controls table
    local nicknameControls = {
        {
            type    = "checkbox",
            name    = GetString(MSRT_USENICKNAMES),
            getFunc = function() return GetSettings().useNicknames end,
            setFunc = function(value) GetSettings().useNicknames = value end,
            default = defaults.useNicknames,
            width   = "full",
        },
        {
            type  = "description",
            text  = GetString(MSRT_NICKNAMESTT),
            width = "full",
        },
    }
    for i = 1, GetNumCharacters() do
        local rawName = GetCharacterInfo(i)
        if rawName and rawName ~= "" then
            local cleanName = zo_strformat("<<1>>", rawName)
            table.insert(nicknameControls, {
                type     = "editbox",
                name     = cleanName,
                tooltip  = "Nickname shown in Known By list for " .. cleanName,
                getFunc  = function()
                    return (GetSettings().charNicknames or {})[cleanName] or ""
                end,
                setFunc  = function(value)
                    if not GetSettings().charNicknames then
                        GetSettings().charNicknames = {}
                    end
                    GetSettings().charNicknames[cleanName] = (value ~= "") and value or nil
                end,
                disabled = function() return not GetSettings().useNicknames end,
                default  = "",
                width    = "full",
            })
        end
    end

    ---------------------------------------------------------------------------------------------
    -- Recipe submenu
    ---------------------------------------------------------------------------------------------
    local RecipeSubmenu = {
        {
            type    = "checkbox",
            name    = GetString(MSRT_CHARMOTIF),
            tooltip = GetString(MSRT_CHARMOTIFTT),
            getFunc = function() return GetSettings().useSelectedMotif end,
            setFunc = function(value) GetSettings().useSelectedMotif = value end,
            default = defaults.useSelectedMotif,
            width   = "full",
        },
        {
            type     = "dropdown",
            name     = GetString(MSRT_SELCHARMOTIF),
            tooltip  = GetString(MSRT_SELCHARMOTIFTT),
            choices  = charNames,
            getFunc  = function() return GetSettings().selectedCharName end,
            setFunc  = function(name) GetSettings().selectedCharName = name end,
            disabled = function() return not GetSettings().useSelectedMotif end,
            default  = defaults.selectedCharName,
            width    = "full",
        },
        {
            type = "header",
            name = GetString(MSRT_NICKNAMES),
        },
    }
    -- nickname edit boxes
    for _, control in ipairs(nicknameControls) do
        table.insert(RecipeSubmenu, control)
    end

    ---------------------------------------------------------------------------------------------
    -- Set submenu
    ---------------------------------------------------------------------------------------------
    local SetSubmenu = {
        {
            type    = "checkbox",
            name    = GetString(MSRT_HideSP),
            tooltip = GetString(MSRT_HideSPtooltip),
            getFunc = function() return GetSettings().HideCompletedSetPage end,
            setFunc = function(value) GetSettings().HideCompletedSetPage = value end,
            default = defaults.HideCompletedSetPage,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(MSRT_HideS),
            tooltip = GetString(MSRT_HideStooltip),
            getFunc = function() return GetSettings().HideCompletedSetPieces end,
            setFunc = function(value) GetSettings().HideCompletedSetPieces = value end,
            default = defaults.HideCompletedSetPieces,
            width   = "full",
        },
        {
            type = "header",
            name = GetString(MSRT_ItemSetBook),
        },
        {
            type    = "checkbox",
            name    = GetString(MSRT_SetBook),
            tooltip = GetString(MSRT_SetBooktooltip),
            getFunc = function() return GetSettings().showSetBookPieces end,
            setFunc = function(value) GetSettings().showSetBookPieces = value end,
            default = defaults.showSetBookPieces,
            width   = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(MSRT_MythicBook),
            tooltip = GetString(MSRT_MythicBooktooltip),
            getFunc = function() return GetSettings().showSetBookFragments end,
            setFunc = function(value) GetSettings().showSetBookFragments = value end,
            default = defaults.showSetBookFragments,
            width   = "full",
        },
    }

    ---------------------------------------------------------------------------------------------
    -- Main options table
    ---------------------------------------------------------------------------------------------
    local options = {
        {
            type = "header",
            name = GetString(MSRT_Gen),
        },
        {
            type    = "checkbox",
            name    = GetString(MSRT_GLOBAL),
            warning = GetString(MSRT_WARNING),
            getFunc = function() return MSRT.SavedVars.useGlobalSettings end,
            setFunc = function(state)
                MSRT.SavedVars.useGlobalSettings = state
                if state then
                    MSRT.SavedVars = MSRT.GlobalSavedVars
                else
                    MSRT.SavedVars = ZO_SavedVars:NewCharacterIdSettings("MSRTSavedVars", 1, nil, defaults)
                end
                zo_callLater(function() ReloadUI() end)
            end,
            default = defaults.useGlobalSettings,
            width   = "full",
        },
        {
            type     = "submenu",
            name     = GetString(MSRT_Recipe),
            controls = RecipeSubmenu,
        },
        {
            type     = "submenu",
            name     = GetString(MSRT_Set),
            controls = SetSubmenu,
        },
    }

    LAM:RegisterOptionControls(MSRT.name, options)
end
