local WindsGH = WingsOfWindGuildhall

WindsGH.UI = WindsGH.UI or {}

WindsGH.UI.ChatButton = {}
WindsGH.UI.MinifiedChatButton = {}

local ChatButton = WindsGH.UI.ChatButton
local MinifiedChatButton = WindsGH.UI.MinifiedChatButton

local CONTROL_NAME_CHAT_BUTTON = WindsGH.NAME .. "ChatButton"
local CONTROL_NAME_MINIFIED_CHAT_BUTTON = WindsGH.NAME .. "MinifiedChatButton"

local TEXTURES = {
    LEFT_MOUSE_BUTTON = "esoui/art/miscellaneous/icon_lmb.dds",
    RIGHT_MOUSE_BUTTON = "esoui/art/miscellaneous/icon_rmb.dds",
    ICON = "esoui/art/collections/collections_tabicon_housing_up.dds",
    ICON_HOVERED = "esoui/art/collections/collections_tabicon_housing_down.dds",
    GUILD_LOGO = "WingsOfWindGuildhall/images/Wings_of_Wind_256x256.dds",
}

local settings

local function showContextMenu()
    local guildHalls = WindsGH.guildHallList

    ClearMenu()

    for i = 1, #guildHalls do
        AddCustomMenuItem(guildHalls[i].label, function()
            WindsGH.travelToGuildHall(guildHalls[i].key)
        end)
    end

    if WindsGH.userSettings.showTravelToGroupLeader and GetGroupSize() > 0 and not IsUnitGroupLeader("player") then
        AddCustomMenuItem("-")
        AddCustomMenuItem(WindsGH.LABELS.JUMP_TO_GROUP_LEADER, function()
            WindsGH.travelToGroupLeader()
        end)
    end

    if not WindsGH.Util.IsTableEmpty(settings.ownHouseTravel) then
        AddCustomMenuItem("-")

        for i, house in ipairs(settings.ownHouseTravel) do
            local label

            if house.customName and house.customName ~= "" then
                label = house.customName
            else
                label = WindsGH.Util.GetHouseNameById(house.houseId) .. (house.outside and " (outside)" or "")
            end

            AddCustomMenuItem(label, function()
                WindsGH.travelToCustomPoint(i)
            end)
        end
    end

    ShowMenu()
end

local function showTooltip(control)
    if not settings.showTooltip then
        return
    end

    InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)

    InformationTooltip:AddLine(
        string.format("|t25:25:%s|t", TEXTURES.GUILD_LOGO)
            .. " "
            .. WindsGH.FORMATTED_GUILD_NAME
    )

    local actionTooltips = ""

    if settings.leftMouseButtonAction ~= WindsGH.ACTIONS.DO_NOTHING then
        actionTooltips = actionTooltips
            .. string.format("|t25:25:%s|t", TEXTURES.LEFT_MOUSE_BUTTON)
            .. WindsGH.ACTION_TOOLTIPS[settings.leftMouseButtonAction]
    end

    if settings.rightMouseButtonAction ~= WindsGH.ACTIONS.DO_NOTHING then
        if actionTooltips ~= "" then
            actionTooltips = actionTooltips .. "\n"
        end

        actionTooltips = actionTooltips
            .. string.format("|t25:25:%s|t", TEXTURES.RIGHT_MOUSE_BUTTON)
            .. WindsGH.ACTION_TOOLTIPS[settings.rightMouseButtonAction]
    end

    if actionTooltips ~= "" then
        InformationTooltip:AddLine(actionTooltips)
    end
end

local function hideTooltip(control)
    ClearTooltip(InformationTooltip)
end

local function performAction(actionType)
    if actionType == WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE then
        WindsGH.travelToGuildHall("primaryResidence")
    elseif actionType == WindsGH.ACTIONS.TRAVEL_TO_GROUP_LEADER then
        WindsGH.travelToGroupLeader()
    elseif actionType == WindsGH.ACTIONS.OPEN_TRAVEL_MENU then
        showContextMenu()
    end
end

local function onButtonClicked(control, button)
    if button == MOUSE_BUTTON_INDEX_LEFT then
        performAction(settings.leftMouseButtonAction)
    elseif button == MOUSE_BUTTON_INDEX_RIGHT then
        performAction(settings.rightMouseButtonAction)
    end
end

local function setupButtonProperties(control)
    control:SetNormalTexture(TEXTURES.ICON)
    control:SetMouseOverTexture(TEXTURES.ICON_HOVERED)
    control:SetPressedTexture(TEXTURES.ICON_HOVERED)

    control:SetHandler("OnMouseUp", onButtonClicked)
    control:SetHandler("OnMouseEnter", showTooltip)
    control:SetHandler("OnMouseExit", hideTooltip)
end

local function drawChatButton()
    local control = WINDOW_MANAGER:CreateControl(CONTROL_NAME_CHAT_BUTTON, ZO_ChatWindow, CT_BUTTON)

    control:SetDimensions(32, 32)
    control:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 190, 7)

    -- it might be more wise to anchor it to notifications instead, but then proper handling for minimize chat needed
    -- points to link: LEFT, ZO_ChatWindowNotifications, RIGHT, x = 30, y = 0

    setupButtonProperties(control)

    ChatButton.control = control
end

function ChatButton:setVisibilityFromSettings()
    if WindsGH.isDeactivated() then
        return
    end

    self.control:SetHidden(not settings.showChatIcon)
end

local function drawMinifiedChatButton()
    local control = WINDOW_MANAGER:CreateControl(CONTROL_NAME_MINIFIED_CHAT_BUTTON, ZO_ChatWindowMinBar, CT_BUTTON)

    control:SetDimensions(25, 25)
    control:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, TOPLEFT, 0, 423)

    setupButtonProperties(control)

    MinifiedChatButton.control = control
end

function MinifiedChatButton:setVisibilityFromSettings()
    if WindsGH.isDeactivated() then
        return
    end

    self.control:SetHidden(not settings.showMinifiedChatIcon)
end

local function init()
    WindsGH.callbackManager:UnregisterCallback(WindsGH.EVENTS.INITIALIZED, init)

    settings = WindsGH.userSettings

    drawChatButton()
    drawMinifiedChatButton()

    WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.ACTIVATED, function()
        ChatButton:setVisibilityFromSettings()
        MinifiedChatButton:setVisibilityFromSettings()
    end)

    WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.DEACTIVATED, function()
        ChatButton.control:SetHidden(true)
        MinifiedChatButton.control:SetHidden(true)
    end)
end

WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.INITIALIZED, init)
