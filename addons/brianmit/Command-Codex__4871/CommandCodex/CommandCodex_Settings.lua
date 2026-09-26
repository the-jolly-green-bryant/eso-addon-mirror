-- CommandCodex_Settings.lua : page in Settings > Addons (LibAddonMenu-2.0).
-- Language (only changeable here) and favorite sets.

local S = CommandCodex
local L = S.L

local PANEL_NAME = "CommandCodexSettings"
local NO_SET = ""   -- dropdown value for "Don't switch" / nothing to delete

local newSetName = ""
local setToDelete = NO_SET

-- Set names with their readable labels, for the dropdowns.
local function SetChoices(withNoSwitch)
    local labels, values = {}, {}
    if withNoSwitch then
        labels[1], values[1] = L("SET_NO_SWITCH"), NO_SET
    end
    for _, name in ipairs(S.GetSetNames()) do
        labels[#labels + 1] = S.SetDisplayName(name)
        values[#values + 1] = name
    end
    return labels, values
end

-- Sets that can be deleted (all but Default).
local function DeletableChoices()
    local labels, values = {}, {}
    for _, name in ipairs(S.GetSetNames()) do
        if name ~= "Default" then
            labels[#labels + 1] = name
            values[#values + 1] = name
        end
    end
    if #values == 0 then
        labels[1], values[1] = L("NO_SETS_TO_DELETE"), NO_SET
    end
    return labels, values
end

-- After creating or deleting a set, refresh every dropdown's list.
local function UpdateSetDropdowns()
    local labels, values = SetChoices(false)
    if CommandCodex_CharSetDropdown then CommandCodex_CharSetDropdown:UpdateChoices(labels, values) end
    labels, values = SetChoices(true)
    if CommandCodex_PvPSetDropdown then CommandCodex_PvPSetDropdown:UpdateChoices(labels, values) end
    if CommandCodex_HouseSetDropdown then CommandCodex_HouseSetDropdown:UpdateChoices(labels, values) end
    labels, values = DeletableChoices()
    setToDelete = values[1]
    if CommandCodex_DeleteSetDropdown then CommandCodex_DeleteSetDropdown:UpdateChoices(labels, values) end
end

function S.InitSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panel = {
        type = "panel",
        name = "Command Codex",
        displayName = "Command Codex",
        author = "|c00C8FFbrianmit|r",   -- cyan
        version = "1.0.1",
        registerForRefresh = true,
    }
    S.settingsPanel = LAM:RegisterAddonPanel(PANEL_NAME, panel)

    local languageLabels, languageValues = { L("LANG_AUTO") }, { "auto" }
    for _, code in ipairs(S.LANGUAGES) do
        if code ~= "auto" then
            languageLabels[#languageLabels + 1] = S.LANGUAGE_NAMES[code]
            languageValues[#languageValues + 1] = code
        end
    end

    local charLabels, charValues = SetChoices(false)
    local zoneLabels, zoneValues = SetChoices(true)
    local deleteLabels, deleteValues = DeletableChoices()
    setToDelete = deleteValues[1]

    local options = {
        { type = "header", name = L("SETTINGS_LANGUAGE_HEADER") },
        {
            type = "dropdown",
            name = L("SETTINGS_LANGUAGE"),
            tooltip = L("SETTINGS_LANGUAGE_TT"),
            choices = languageLabels,
            choicesValues = languageValues,
            getFunc = function() return S.sv.language end,
            setFunc = function(value) S.sv.language = value end,
            requiresReload = true,
        },

        { type = "header", name = L("SETS_HEADER") },
        { type = "description", text = L("SETS_DESC") },
        {
            type = "dropdown",
            name = L("SET_THIS_CHAR"),
            tooltip = L("SET_THIS_CHAR_TT"),
            choices = charLabels,
            choicesValues = charValues,
            getFunc = function() return S.sv.characterSet[GetCurrentCharacterId()] or "Default" end,
            setFunc = function(value) S.UseSetForCharacter(value) end,
            reference = "CommandCodex_CharSetDropdown",
        },
        {
            type = "dropdown",
            name = L("SET_PVP"),
            tooltip = L("SET_PVP_TT"),
            choices = zoneLabels,
            choicesValues = zoneValues,
            getFunc = function() return S.sv.zoneSet.pvp or NO_SET end,
            setFunc = function(value)
                S.sv.zoneSet.pvp = value ~= NO_SET and value or nil
                S.UpdateActiveSet(true)
            end,
            reference = "CommandCodex_PvPSetDropdown",
        },
        {
            type = "dropdown",
            name = L("SET_HOUSE"),
            tooltip = L("SET_HOUSE_TT"),
            choices = zoneLabels,
            choicesValues = zoneValues,
            getFunc = function() return S.sv.zoneSet.house or NO_SET end,
            setFunc = function(value)
                S.sv.zoneSet.house = value ~= NO_SET and value or nil
                S.UpdateActiveSet(true)
            end,
            reference = "CommandCodex_HouseSetDropdown",
        },
        {
            type = "editbox",
            name = L("NEW_SET_NAME"),
            getFunc = function() return newSetName end,
            setFunc = function(value) newSetName = value or "" end,
            isMultiline = false,
            maxChars = 30,
        },
        {
            type = "button",
            name = L("CREATE_SET"),
            tooltip = L("CREATE_SET_TT"),
            func = function()
                local ok, reason = S.CreateSet(newSetName)
                if ok then
                    S.Print(L("SET_CREATED", zo_strtrim(newSetName)))
                    newSetName = ""
                    UpdateSetDropdowns()
                else
                    S.Print(reason)
                end
            end,
            width = "half",
        },
        {
            type = "dropdown",
            name = L("DELETE_SET_PICK"),
            choices = deleteLabels,
            choicesValues = deleteValues,
            getFunc = function() return setToDelete end,
            setFunc = function(value) setToDelete = value end,
            reference = "CommandCodex_DeleteSetDropdown",
        },
        {
            type = "button",
            name = L("DELETE_SET"),
            warning = L("DELETE_SET_WARN"),
            isDangerous = true,
            func = function()
                if setToDelete ~= NO_SET and S.DeleteSet(setToDelete) then
                    S.Print(L("SET_DELETED", setToDelete))
                    UpdateSetDropdowns()
                end
            end,
            width = "half",
        },
    }
    LAM:RegisterOptionControls(PANEL_NAME, options)

    -- Launcher right-click > Settings... (only offered when this page exists)
    function S.OpenSettings()
        LAM:OpenToPanel(S.settingsPanel)
    end
end
