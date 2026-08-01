local AH = _G.ArchiveHelper

local function Initialise()
    -- saved variables
    AH.Vars =
        _G.LibSavedVars:NewAccountWide("ArchiveHelperSavedVars", "Account", AH.Defaults):AddCharacterSettingsToggle(
        "ArchiveHelperSavedVars",
        "Characters"
    ):EnableDefaultsTrimming()

    AH.RegisterSettings()

    local selector_short = "ZO_EndDunBuffSelector_%s"
    local selector = "ZO_EndlessDungeonBuffSelector_%s"
    local selectorObject = "ENDLESS_DUNGEON_BUFF_SELECTOR_%s"

    if (IsInGamepadPreferredMode()) then
        AH.SELECTOR_SHORT = string.format(selector_short, "Gamepad")
        AH.SELECTOR = string.format(selector, "Gamepad")
        AH.SELECTOR_OBJECT = string.format(selectorObject, "GAMEPAD")
    else
        AH.SELECTOR_SHORT = string.format(selector_short, "Keyboard")
        AH.SELECTOR = string.format(selector, "Keyboard")
        AH.SELECTOR_OBJECT = string.format(selectorObject, "KEYBOARD")
    end

    AH.CheckDataShareLib()
    AH.SetupHooks()
    AH.FindMissingAbilityIds()
    AH.SetupEvents()

    if (GetCVar("language.2") == "ru") then
        AH.IsRu = true
    end

    _G.SLASH_COMMANDS["/ah"] = function(...)
        AH.HandleSlashCommand(...)
    end
end

function AH.OnAddonLoaded(_, addonName)
    if (addonName ~= AH.Name) then
        return
    end

    if (_G.LibChatMessage ~= nil) then
        AH.Chat = _G.LibChatMessage(AH.Name, "AH")
    end

    EVENT_MANAGER:UnregisterForEvent(AH.Name, EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(AH.Name, EVENT_ADD_ON_LOADED, AH.OnAddonLoaded)
