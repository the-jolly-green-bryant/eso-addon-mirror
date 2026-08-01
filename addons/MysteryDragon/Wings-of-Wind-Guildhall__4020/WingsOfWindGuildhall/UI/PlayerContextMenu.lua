local WindsGH = WingsOfWindGuildhall

WindsGH.UI = WindsGH.UI or {}

WindsGH.UI.PlayerContextMenu = {}

local PlayerContextMenu = WindsGH.UI.PlayerContextMenu

local settings

local isGuildLeaderMenuHooksInitialized = false

function PlayerContextMenu.initGuildLeaderMenuEntries()
    -- We don't want to apply multiple hooks
    if isGuildLeaderMenuHooksInitialized then
        return
    end

    if not settings.showInGuildLeaderMenu then
        return
    end

    local displayName

    local function retrieveDisplayName(control, button, upInside)
        -- Might looks like redundant but it's necessary since we can disable this feature without reloading UI
        if not settings.showInGuildLeaderMenu then
            return
        end

        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            local rowData = ZO_ScrollList_GetData(control)
            displayName = rowData.displayName
        end
    end

    ZO_PreHook("ZO_FriendsListRow_OnMouseUp", retrieveDisplayName)
    ZO_PreHook("ZO_GroupListRow_OnMouseUp", retrieveDisplayName)
    ZO_PreHook("ZO_KeyboardGuildRosterRow_OnMouseUp", retrieveDisplayName)

    SecurePostHook("AddMenuItem", function(mytext)
        -- Might looks like redundant but it's necessary since we can disable this feature without reloading UI
        if not settings.showInGuildLeaderMenu then
            return
        end

        if WindsGH.isDeactivated() then
            return
        end

        if displayName == "@Viralissa" and mytext == GetString(SI_SOCIAL_MENU_VISIT_HOUSE) then
            local guildHalls = WindsGH.guildHallList

            for i = 1, #guildHalls do
                if guildHalls[i].house ~= WindsGH.HOUSES.PRIMARY then
                    AddMenuItem(
                        guildHalls[i].playerMenuLabel or guildHalls[i].label,
                        function() WindsGH.travelToGuildHall(guildHalls[i].key) end
                    )
                end
            end
        end
    end)

    SecurePostHook(ZO_SortFilterList, "ShowMenu", function()
        displayName = nil
    end)

    isGuildLeaderMenuHooksInitialized = true
end

local function init()
    WindsGH.callbackManager:UnregisterCallback(WindsGH.EVENTS.INITIALIZED, init)

    settings = WindsGH.userSettings

    PlayerContextMenu.initGuildLeaderMenuEntries()
end

WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.INITIALIZED, init)
