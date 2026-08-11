-- =================================================================================================
-- Title:   P11_SlashHotkeys
-- Name:    P11_SlashHotkeys
-- Author:  Phobus11
-- Version: 1.1.0
-- Date:    2026-08-05 00:00:00 [P11_SlashHotkeys.lua]
-- =================================================================================================

P11_SlashHotkeys = {}
local P11SH = P11_SlashHotkeys
local numMaxSlashCommands = 10

P11SH.addonName = "P11_SlashHotkeys"
P11SH.shortName = "P11SH"
P11SH.addonTitle = "P11's Slash Hotkeys"
P11SH.panelName = "|c8080FFSlash Hotkeys|r"
P11SH.version = "1.1.0"
P11SH.author = "Phobus11"

P11SH.Vars = {}
P11SH.settings = nil

local em = GetEventManager()

function P11SH.OnAddOnLoaded(event, addonName)
  if addonName == P11SH.addonName then
    em:UnregisterForEvent(P11SH.addonName, EVENT_ADD_ON_LOADED)
    P11SH.Initialize()
  end
end

function P11SH.MigrateLegacySettings(rawTable)
    local legacyRoot = _G[P11SH.Vars.savedVariablesName]
    local legacyNamespace = legacyRoot
        and legacyRoot["Default"]
        and legacyRoot["Default"][GetDisplayName()]
        and legacyRoot["Default"][GetDisplayName()]["$AccountWide"]
        and legacyRoot["Default"][GetDisplayName()]["$AccountWide"][P11SH.Vars.configNamespace]

    if not legacyNamespace then return end

    if legacyNamespace.chattxt then
        for i, value in ipairs(legacyNamespace.chattxt) do
            rawTable.chattxt[i] = value
        end
    end

    if legacyNamespace.debug ~= nil then
        rawTable.debug = legacyNamespace.debug
    end
end

function P11SH.Initialize()
    P11SH.Vars.savedVariablesName = 'P11_SlashHotkeys_SavedVars'
    P11SH.Vars.configVersion = 1
    P11SH.Vars.configNamespace = 'P11SH'
    P11SH.Vars.defaultScope = LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER
    P11SH.Vars.varsVersion = 1

    local chattxtDefaults = {}
    for i=1, numMaxSlashCommands do
        chattxtDefaults[i] = "/s testchat" .. tostring(i - 1)
    end

    P11SH.Vars.configDefaults = { ["configVersion"] = P11SH.Vars.configVersion, ["debug"] = false, ["chattxt"] = chattxtDefaults }

    P11SH.settings = LibExtendedSavedVars.NewTieredSavedVars(
        P11SH.Vars.savedVariablesName,
        P11SH.Vars.configVersion,
        P11SH.Vars.configNamespace,
        P11SH.Vars.configDefaults,
        P11SH.Vars.defaultScope
    )

    P11SH.settings:Version(P11SH.Vars.varsVersion, P11SH.MigrateLegacySettings)

    P11SH.CreateChatConfigMenu()
end

function P11SH.DoChatItem(index)
    local text = P11SH.settings.chattxt[index]
    if not text or text == "" then return end

    local command, args = text:match("^(/%S+)%s*(.-)$")
    command = command and command:lower()

    if command and SLASH_COMMANDS[command] then
        SLASH_COMMANDS[command](args)
    else
        CHAT_SYSTEM:StartTextEntry(text)
    end
end

function P11SH.CreateChatConfigMenu()
    local panelData = { type = "panel", name = P11SH.addonTitle, displayName = P11SH.panelName, author = P11SH.author, version = P11SH.version }

    local optionsData = {
        P11SH.settings:GetLibAddonMenuScopeDropdown(),
        { type = "header", name = "Chat Text Settings (i.e. /g hello.../z Join My Guild)" },
    }
    for i=1, numMaxSlashCommands do
        optionsData[#optionsData +1] = { type = "editbox", name = "Chat Text " ..tostring(i), getFunc = function() return P11SH.settings.chattxt[i] end, setFunc = function(value) P11SH.settings.chattxt[i] = value end }
    end

    local LAM2 = LibAddonMenu2
    LAM2:RegisterAddonPanel(P11SH.addonTitle, panelData)
    LAM2:RegisterOptionControls(P11SH.addonTitle, optionsData)
end

for i=1, numMaxSlashCommands do
    ZO_CreateStringId("SI_BINDING_NAME_SLASHHK_" .. tostring(i), "HotKey " .. tostring(i))
end

EVENT_MANAGER:RegisterForEvent(P11SH.addonName, EVENT_ADD_ON_LOADED, P11SH.OnAddOnLoaded)
