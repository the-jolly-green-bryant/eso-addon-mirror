local LAM = LibAddonMenu2

RdKGroupToolPatcher = {
    name            = "RdKGroupTool Patcher",
    author          = "phuein",
    color           = "DDCCCC",
    menuName        = "RdK Group Tool Patcher",
}

local RdKGToolCrown
local RdKGToolChat
local RdKGToolUtil
local RdKGToolMenu

-- Default settings.
RdKGroupToolPatcher.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = true,                 -- Load settings from account savedVars, instead of character.
}

-- Wraps text with a color.
function RdKGroupToolPatcher.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = RdKGroupToolPatcher.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

function RdKGroupToolPatcher.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(RdKGroupToolPatcher.name, EVENT_PLAYER_ACTIVATED)

    if RdKGroupToolPatcher.savedVars.firstLoad then
        RdKGroupToolPatcher.savedVars.firstLoad = false

        -- Patch here.
        if RdKGTool and RdKGTool.group and RdKGTool.group.crown then
            -- Nothing.
            --d(RdKGroupToolPatcher.Colorize('RdKGroupToolPatcher: ', 'FFFFFF') .. 'RdK Group Tool patched!')
        else
            d(RdKGroupToolPatcher.Colorize('RdKGroupToolPatcher: ', 'FFFFFF') .. 'RdK Group Tool not found.')
        end
    end
end
-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(RdKGroupToolPatcher.name, EVENT_PLAYER_ACTIVATED, RdKGroupToolPatcher.Activated)

function RdKGroupToolPatcher.GetSecondaryCrowns()
	return RdKGToolCrown.crownVars.secondaries
end

function RdKGroupToolPatcher.SetSecondaryCrowns(value)
	RdKGToolCrown.crownVars.secondaries = value
end

function RdKGroupToolPatcher.OnAddOnLoaded(event, addonName)
    -- Patch.
    if RdKGTool and addonName == RdKGTool.addonName then
        if RdKGTool and RdKGTool.group and RdKGTool.group.crown and RdKGTool.util then
            RdKGToolCrown = RdKGTool.group.crown
            RdKGToolUtil = RdKGTool.util
            RdKGToolChat = RdKGToolUtil.chatSystem
            RdKGToolMenu = RdKGTool.menu

            -- Events.
            EVENT_MANAGER:RegisterForEvent(RdKGToolCrown.callbackName, EVENT_PLAYER_DEAD, function(...)
                if not IsUnitGroupLeader("player") then return end

                local secondaries = RdKGToolCrown.crownVars.secondaries

                if not secondaries or secondaries == '' then return end

                RdKGToolChat.SendChatMessage("You died. Attempting to pass crown...", RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)

                local res
                for n,v in secondaries:gmatch('([^,]+)') do
                    local name = string.gsub(n, '^%s*(.-)%s*$', '%1')
                    -- Try to pass crown, if it's a group member.
                    -- d(name)
                    -- d('IsCharacterInGroup(name) or IsPlayerInGroup(name)', IsCharacterInGroup(name) or IsPlayerInGroup(name))
                    if IsCharacterInGroup(name) or IsPlayerInGroup(name) then
                        -- Loop over group members. NOTE: This is how the game does it, sadly.
                        for i=1, GetGroupSize() do
                            local tag = GetGroupUnitTagByIndex(i)
                            -- d('ZO_GetPrimaryPlayerNameFromUnitTag(tag)', ZO_GetPrimaryPlayerNameFromUnitTag(tag))
                            -- d('ZO_GetSecondaryPlayerNameFromUnitTag(tag)', ZO_GetSecondaryPlayerNameFromUnitTag(tag))
                            if ZO_GetPrimaryPlayerNameFromUnitTag(tag) == name or ZO_GetSecondaryPlayerNameFromUnitTag(tag) == name then
                                GroupPromote(tag)
                                res = name
                                break
                            end
                        end
                    end

                    -- Success.
                    if res then break end
                end

                if res then
                    RdKGToolChat.SendChatMessage("Passed crown to " .. res .. ".", RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
                end
            end)

            -- RdKGroupToolPatcher.LoadSettings()

            -- Patch menu.
            -- local menu = RdKGToolCrown.GetMenu()

            local header = {
                type = "header",
                name = "|cFFA17C" .. "Patcher" .. "|r",
                width = "full",
            }

            local menu = {
                type = "submenu",
                name = "|c45C2FF" .. "Crown" .. "|r",
                --width = "full",
                --requiresReload = true
                controls = {
                    [1] = {
                        type = "editbox",
                        name = "Pass Crown on Death",
                        getFunc = RdKGroupToolPatcher.GetSecondaryCrowns,
                        setFunc = RdKGroupToolPatcher.SetSecondaryCrowns,
                        isMultiline = false,
                        width = "full",
                        default = "",
                        tooltip = "Pass group leadership on death, by order. Example: @bob, @mike, @jim",
                    }
                }
            }

            -- At the end of RdK settings.
            table.insert(RdKGToolMenu.lam.optionsData, header)
            table.insert(RdKGToolMenu.lam.optionsData, menu)

            LAM:RegisterOptionControls(RdKGToolMenu.name, RdKGToolMenu.lam.optionsData)
        end
    end

    if addonName ~= RdKGroupToolPatcher.name then return end

    EVENT_MANAGER:UnregisterForEvent(RdKGroupToolPatcher.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    -- RdKGroupToolPatcher.characterSavedVars = ZO_SavedVars:New("RdKGroupToolPatcherVars", 1, nil, RdKGroupToolPatcher.savedVars)
    -- RdKGroupToolPatcher.accountSavedVars = ZO_SavedVars:NewAccountWide("RdKGroupToolPatcherVars", 1, nil, RdKGroupToolPatcher.savedVars)

    -- if not RdKGroupToolPatcher.characterSavedVars.accountWide then
    --     RdKGroupToolPatcher.savedVars = RdKGroupToolPatcher.characterSavedVars
    -- else
    --     RdKGroupToolPatcher.savedVars = RdKGroupToolPatcher.accountSavedVars
    -- end

    -- Reset autocomplete cache to update it.
    -- SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache()
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(RdKGroupToolPatcher.name, EVENT_ADD_ON_LOADED, RdKGroupToolPatcher.OnAddOnLoaded)