-- Settings.lua
-- Copyright (C) 2021 c0r73x <c0r73x@hades>
--
-- Distributed under terms of the MIT license.
--

local panelName = "ChatAlertAddon"
local TwinOptionsContainer_Index = 10000 -- Dont conflict with addonMenu

local function CreateOptionsControls(panel, optionsTable, LastAnchor)
    local function TwinOptionsContainer(parent, leftWidget, rightWidget)
        TwinOptionsContainer_Index = TwinOptionsContainer_Index + 1

        local cParent = parent.scroll or parent
        local panel = parent.panel or cParent

        local container = WINDOW_MANAGER:CreateControl(
            "$(parent)TwinContainer" .. tostring(TwinOptionsContainer_Index),
            cParent,
            CT_CONTROL
        )
        container:SetResizeToFitDescendents(true)
        container:SetAnchor(select(2, leftWidget:GetAnchor(0)))

        leftWidget:ClearAnchors()
        leftWidget:SetAnchor(TOPLEFT, container, TOPLEFT)
        rightWidget:SetAnchor(TOPLEFT, leftWidget, TOPRIGHT, 5, 0)

        leftWidget:SetWidth(leftWidget:GetWidth() - 2.5) -- fixes bad alignment with 'full' controls
        rightWidget:SetWidth(rightWidget:GetWidth() - 2.5)

        leftWidget:SetParent(container)
        rightWidget:SetParent(container)

        container.data = {type = "container"}
        container.panel = panel
        return container
    end

    local function CreateAndAnchorWidget(
        parent,
        widgetData,
        offsetX,
        offsetY,
        anchorTarget,
        wasHalf
    )
        local widget
        local status, err = pcall(function()
            widget = LAMCreateControl[widgetData.type](parent, widgetData)
        end)

        if not status then
            return err or true, offsetY, anchorTarget, wasHalf
        else
            local isHalf = (widgetData.width == "half")

            if not anchorTarget then -- the first widget in a panel is just placed in the top left corner
                widget:SetAnchor(TOPLEFT)
                anchorTarget = widget
            elseif wasHalf and isHalf then -- when the previous widget was only half width and this one is too, we place it on the right side
                widget.lineControl = anchorTarget
                isHalf = false
                offsetY = 0
                anchorTarget = TwinOptionsContainer(parent, anchorTarget, widget)
            else -- otherwise we just put it below the previous one normally
                widget:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, 15)
                offsetY = 0
                anchorTarget = widget
            end
            return false, offsetY, anchorTarget, isHalf
        end
    end

    -- local anchorOffset, lastAddedControl, wasHalf = 0, lastAnchor, false

    local function CreateWidgetsInPanel(
        parent,
        widgetDataTable,
        anchorOffset,
        lastAnchor,
        wasHalf
    )
        local lastAddedControl = lastAnchor
        local lastSubmenu = nil

        for i = 1, #widgetDataTable do
            local widgetData = widgetDataTable[i]

            if widgetData then
                local widgetType = widgetData.type
                local offsetX = 0
                local isSubmenu = (widgetType == "submenu")

                if isSubmenu then
                    offsetX = 5
                    wasHalf = false
                end

                _, anchorOffset, lastAddedControl, wasHalf = CreateAndAnchorWidget(
                    parent,
                    widgetData,
                    offsetX,
                    anchorOffset,
                    lastAddedControl,
                    wasHalf
                )

                if isSubmenu then
                    lastSubmenu = lastAddedControl
                    CreateWidgetsInPanel(
                        lastAddedControl,
                        widgetData.controls,
                        anchorOffset,
                        nil,
                        wasHalf
                    )
                end
            end
        end

        return lastSubmenu
    end

    return CreateWidgetsInPanel(panel, optionsTable, 0, LastAnchor, false)
end

local function LoadSettings()
    local panel
    local LAM = LibAddonMenu2

    local defaultData = {
        alerts = {},
    }

    local channelList = {
        999, -- All
        998, -- Guild + Officer
        997, -- Guilds
        CHAT_CHANNEL_GUILD_1,
        CHAT_CHANNEL_GUILD_2,
        CHAT_CHANNEL_GUILD_3,
        CHAT_CHANNEL_GUILD_4,
        CHAT_CHANNEL_GUILD_5,
        CHAT_CHANNEL_OFFICER_1,
        CHAT_CHANNEL_OFFICER_2,
        CHAT_CHANNEL_OFFICER_3,
        CHAT_CHANNEL_OFFICER_4,
        CHAT_CHANNEL_OFFICER_5,
        CHAT_CHANNEL_PARTY,
        CHAT_CHANNEL_SAY,
        CHAT_CHANNEL_YELL,
        CHAT_CHANNEL_ZONE,
        CHAT_CHANNEL_ZONE_LANGUAGE_1,
        CHAT_CHANNEL_ZONE_LANGUAGE_2,
        CHAT_CHANNEL_ZONE_LANGUAGE_3,
        CHAT_CHANNEL_ZONE_LANGUAGE_4,
    }

    local channels = {
        "All",
        "Guilds & Officer",
        "Guilds",
    }

    for _, id in ipairs(channelList) do
        local Officer = ""

        if id < 900 then
            if id > 16 and id < 22 then
                Officer = "Officer "
            end
            table.insert(channels, Officer .. ChatAlert.GetChannelName(id))
        end
    end

    local name = GetDisplayName()
    local world = GetWorldName()
    local key = world .. name

    ChatAlertSavedVariables = ChatAlertSavedVariables or {}
    local saveData = ChatAlertSavedVariables[key] or ZO_DeepTableCopy(defaultData)
    ChatAlertSavedVariables[key] = saveData

    local function RepairSaveData()
        for k, value in pairs(defaultData) do
            if(saveData[k] == nil) then
                saveData[k] = value
            end
        end
    end

    local function hex2rgb(hex)
        return string.format("%.2f", tonumber("0x"..hex:sub(1,2)) / 255),
            string.format("%.2f", tonumber("0x"..hex:sub(3,4)) / 255),
            string.format("%.2f", tonumber("0x"..hex:sub(5,6)) / 255)
    end

    local function checkSubmenu(index, hide)
        local submenu = _G["submenu" .. index]

        if submenu then
            if hide then
                submenu:SetHidden(true)
                return false
            else
                submenu:SetHidden(false)
                return true
            end
        end

        return false
    end

    local function GetSubControls(index)
        return {
            {
                type = "editbox",
                name = "Match string",
                tooltip = "Words to match, separated by space",
                getFunc = function()
                    return checkSubmenu(
                        index,
                        not saveData.alerts[index]
                    ) and saveData.alerts[index].filter or ""
                end,
                setFunc = function(text)
                    saveData.alerts[index].filter = text
                end,
                isMultiline = false,
                isExtraWide = true,
                width = "full",
                default = "",
            },
            {
                type = "editbox",
                name = "UserID Whitelist",
                tooltip = "Only recieve alerts from these users",
                getFunc = function()
                    return checkSubmenu(
                        index,
                        not saveData.alerts[index]
                    ) and saveData.alerts[index].whitelist or ""
                end,
                setFunc = function(text)
                    saveData.alerts[index].whitelist = text
                end,
                isMultiline = true,
                isExtraWide = true,
                width = "half",
                default = "",
            },
            {
                type = "editbox",
                name = "UserID Blacklist",
                tooltip = "Dont recieve alerts from these users",
                getFunc = function()
                    return checkSubmenu(
                        index,
                        not saveData.alerts[index]
                    ) and saveData.alerts[index].blacklist or ""
                end,
                setFunc = function(text)
                    saveData.alerts[index].blacklist = text
                end,
                isMultiline = true,
                isExtraWide = true,
                width = "half",
                default = "",
            },
            {
                type = "dropdown",
                name = "Channels",
                choices = channels,
                choicesValues = channelList,
                getFunc = function()
                    return checkSubmenu(
                        index,
                        not saveData.alerts[index]
                    ) and saveData.alerts[index].channels or 999
                end,
                setFunc = function(value)
                    saveData.alerts[index].channels = value
                end,
                width = "full",
                default = 999,
            },
            {
                type = "colorpicker",
                name = "Match color",
                tooltip = "Color of matched text",
                getFunc = function()
                    if not saveData.alerts[index] then
                        return 1, 0, 0
                    end

                    local r, g, b = hex2rgb(saveData.alerts[index].color)
                    return  r, g, b
                end,
                setFunc = function(r,g,b)
                    saveData.alerts[index].color = ("%02x%02x%02x"):format(
                        r * 255, g * 255, b * 255
                    )
                end,
                width = "full",
                default = "ff0000",
            },
            {
                type = "checkbox",
                name = "Enable",
                tooltip = "Toggle alert",
                disabled = function()
                    if not saveData.alerts[index] then
                        return true
                    end
                    return string.len(saveData.alerts[index].filter) == 0
                end,
                getFunc = function()
                    if not saveData.alerts[index] then
                        return false
                    end
                    if string.len(saveData.alerts[index].filter) == 0 then
                        return false
                    end

                    return checkSubmenu(
                        index,
                        not saveData.alerts[index]
                    ) and saveData.alerts[index].enabled or false
                end,
                setFunc = function(value)
                    saveData.alerts[index].enabled = value
                end,
                width = "full",
                default = true,
            },
            {
                type = "button",
                name = "Remove alert",
                tooltip = "Remove this alert",
                func = function()
                    table.remove(saveData.alerts, index)
                end,
                width = "full",
            },
        }
    end

    local function GetOptionsData()
        local optionsData = {}

        if not _G["addAlertButton"] then
            table.insert(optionsData, {
                    type = "button",
                    name = "Add alert",
                    reference = "addAlertButton",
                    tooltip = "Add new alert",
                    func = function()
                        table.insert(saveData.alerts, {
                                enabled = true,
                                filter = "",
                                type = "Word",
                                channels = 999,
                                color = "ff0000",
                                whitelist = "",
                                blacklist = "",
                            })
                        GetOptionsData()
                    end,
                    width = "full",
                })
        end

        for index, _ in ipairs(saveData.alerts) do
            if not _G["submenu" .. index] then
                table.insert(optionsData, {
                        type = "submenu",
                        name = "Alert " .. index,
                        reference = "submenu" .. index,
                        controls = GetSubControls(index),
                    })
            end
        end

        ChatAlert.LastAnchor = CreateOptionsControls(
            panel,
            optionsData,
            ChatAlert.LastAnchor
        )
    end

    local function CreateSettingsDialog()
        ChatAlert.LastAnchor = nil

        local panelData = {
            displayName = "Chat Alert Settings",
            type = "panel",
            name = "ChatAlert",
            author = "c0r73x",
            version = "0.3",
            slashCommand = "/chatalert",
            registerForRefresh = true,
            registerForDefaults = false,
        }

        panel = LAM:RegisterAddonPanel(panelName, panelData)
        local optionsTable = {  }
        LAM:RegisterOptionControls(panelName, optionsTable)
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", GetOptionsData)
        -- LAM:RegisterOptionControls(panelName, GetOptionsData())
    end

    RepairSaveData()
    CreateSettingsDialog()

    return saveData
end

ChatAlert.LoadSettings = LoadSettings
