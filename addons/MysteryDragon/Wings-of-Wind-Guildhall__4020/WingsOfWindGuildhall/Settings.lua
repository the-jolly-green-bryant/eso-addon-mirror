if not LibAddonMenu2 then
    return
end

local WindsGH = WingsOfWindGuildhall

local function initializeSettings()
    WindsGH.callbackManager:UnregisterCallback(WindsGH.EVENTS.INITIALIZED, initializeSettings)

    local variables = WindsGH.userSettings

    if not variables.useLibAddonMenu then
        return
    end

    local LAM = LibAddonMenu2
    local SETTINGS_NAME = WindsGH.NAME .. "Settings"

    local CHOICE_EMPTY = "--"

    local panelData = {
        type = "panel",
        name = WindsGH.DISPLAY_NAME,
        author = string.format("|c00BFFF%s|r", WindsGH.AUTHOR),
        version = WindsGH.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {}

    table.insert(optionsData, {
        type = "header",
        name = "General",
        width = "full",
    })

    table.insert(optionsData, {
        type = "checkbox",
        name = "Integrate into the guild leader context menu",
        getFunc = function()
            return variables.showInGuildLeaderMenu
        end,
        setFunc = function(value)
            variables.showInGuildLeaderMenu = value

            if value then
                WindsGH.UI.PlayerContextMenu.initGuildLeaderMenuEntries()
            end
        end,
        default = WindsGH.defaultSettings.showInGuildLeaderMenu,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "checkbox",
        name = "Show tooltip",
        getFunc = function()
            return variables.showTooltip
        end,
        setFunc = function(value)
            variables.showTooltip = value
        end,
        default = WindsGH.defaultSettings.showTooltip,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "checkbox",
        name = "Show icon in chat window",
        getFunc = function()
            return variables.showChatIcon
        end,
        setFunc = function(value)
            variables.showChatIcon = value
            WindsGH.UI.ChatButton:setVisibilityFromSettings()
        end,
        default = WindsGH.defaultSettings.showChatIcon,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "checkbox",
        name = "Show icon in minified chat window",
        getFunc = function()
            return variables.showMinifiedChatIcon
        end,
        setFunc = function(value)
            variables.showMinifiedChatIcon = value
            WindsGH.UI.MinifiedChatButton:setVisibilityFromSettings()
        end,
        default = WindsGH.defaultSettings.showMinifiedChatIcon,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    local actionChoices = {
        WindsGH.ACTION_TOOLTIPS[WindsGH.ACTIONS.DO_NOTHING],
        WindsGH.ACTION_TOOLTIPS[WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE],
        WindsGH.ACTION_TOOLTIPS[WindsGH.ACTIONS.TRAVEL_TO_GROUP_LEADER],
        WindsGH.ACTION_TOOLTIPS[WindsGH.ACTIONS.OPEN_TRAVEL_MENU],
    }

    local actionChoicesValues = {
        WindsGH.ACTIONS.DO_NOTHING,
        WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE,
        WindsGH.ACTIONS.TRAVEL_TO_GROUP_LEADER,
        WindsGH.ACTIONS.OPEN_TRAVEL_MENU,
    }

    table.insert(optionsData, {
        type = "dropdown",
        name = "Left mouse button action",
        choices = actionChoices,
        choicesValues = actionChoicesValues,
        getFunc = function()
            return variables.leftMouseButtonAction
        end,
        setFunc = function(action)
            variables.leftMouseButtonAction = action
        end,
        default = WindsGH.defaultSettings.leftMouseButtonAction,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "dropdown",
        name = "Right mouse button action",
        choices = actionChoices,
        choicesValues = actionChoicesValues,
        getFunc = function()
            return variables.rightMouseButtonAction
        end,
        setFunc = function(action)
            variables.rightMouseButtonAction = action
        end,
        default = WindsGH.defaultSettings.rightMouseButtonAction,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "checkbox",
        name = string.format('Show "%s" at icon menu', WindsGH.LABELS.JUMP_TO_GROUP_LEADER),
        getFunc = function()
            return variables.showTravelToGroupLeader
        end,
        setFunc = function(value)
            variables.showTravelToGroupLeader = value
        end,
        default = WindsGH.defaultSettings.showTravelToGroupLeader,
        disabled = function()
            return WindsGH.isDeactivated()
        end
    })

    table.insert(optionsData, {
        type = "header",
        name = "Quick travel menu",
        width = "full",
    })

    local ownHouseTravelChoices = WindsGH.Util.GetOwnedHouseNames()
    table.insert(ownHouseTravelChoices, 1, CHOICE_EMPTY)

    for i = 1, WindsGH.MAX_CUSTOM_POINTS do
        table.insert(optionsData, {
            type = "dropdown",
            name = "House name",
            choices = ownHouseTravelChoices,
            getFunc = function()
                local house = variables.ownHouseTravel[i]

                if house and house.houseId then
                    return WindsGH.Util.GetHouseNameById(house.houseId)
                end

                return CHOICE_EMPTY
            end,
            setFunc = function(name)
                if name ~= CHOICE_EMPTY then
                    if not variables.ownHouseTravel[i] then
                        variables.ownHouseTravel[i] = {}
                    end

                    variables.ownHouseTravel[i].houseId = WindsGH.Util.GetHouseIdByName(name)
                else
                    for j = i, WindsGH.MAX_CUSTOM_POINTS do
                        variables.ownHouseTravel[j] = nil
                    end
                end

                WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.TRAVEL_POINT_UPDATED)
            end,
            scrollable = true,
            default = CHOICE_EMPTY,
            disabled = function()
                return WindsGH.isDeactivated() or (i > 1 and variables.ownHouseTravel[i - 1] == nil)
            end
        })

        table.insert(optionsData, {
            type = "checkbox",
            name = "Travel outside?",
            getFunc = function()
                local house = variables.ownHouseTravel[i]

                return house and house.outside or false
            end,
            setFunc = function(value)
                if not variables.ownHouseTravel[i] then
                    variables.ownHouseTravel[i] = {}
                end

                variables.ownHouseTravel[i].outside = value

                WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.TRAVEL_POINT_UPDATED)
            end,
            default = false,
            disabled = function()
                return WindsGH.isDeactivated() or variables.ownHouseTravel[i] == nil
            end,
        })

        table.insert(optionsData, {
            type = "editbox",
            name = "Custom label for this point",
            maxChars = 64,
            getFunc = function()
                local house = variables.ownHouseTravel[i]

                return house and house.customName or ""
            end,
            setFunc = function(value)
                if not variables.ownHouseTravel[i] then
                    variables.ownHouseTravel[i] = {}
                end

                variables.ownHouseTravel[i].customName = value ~= "" and value:gsub("^%s*(.-)%s*$", "%1") or nil
            end,
            default = "",
            disabled = function()
                return WindsGH.isDeactivated() or variables.ownHouseTravel[i] == nil
            end,
        })

        if i ~= WindsGH.MAX_CUSTOM_POINTS then
            table.insert(optionsData, {
                type = "divider",
                height = 10,
                alpha = 0.25,
                width = "half"
            })
        end
    end

    LAM:RegisterAddonPanel(SETTINGS_NAME, panelData)
    LAM:RegisterOptionControls(SETTINGS_NAME, optionsData)
end

WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.INITIALIZED, initializeSettings)
