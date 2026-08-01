local ADDON_NAME = "SlashBindButtons"
local ADDON_VERSION = "1.4.2"
local SBB = {}
SlashBindButtons = SBB

local DEFAULT_ICON = "/esoui/art/icons/poi/poi_group_house_owned.dds"
local DEFAULT_SIZE = 42
local DEFAULT_SPACING = 4
local DEFAULT_ORIENTATION = "Horizontal"
local ICONS_PER_PAGE = 20

local accountDefaults = {
    x = 450,
    y = 350,
    locked = false,
    visible = true,
    buttonSize = DEFAULT_SIZE,
    buttonSpacing = DEFAULT_SPACING,
    orientation = DEFAULT_ORIENTATION,
    hideWhileMenusOpen = false,
    commands = {
        "",
        "",
        "",
        "",
        "",
    },
    icons = {
        "",
        "",
        "",
        "",
        "",
    },
    hidden = {
        false,
        false,
        false,
        false,
        false,
    },
}

local characterDefaults = {
    commands = {
        "",
        "",
        "",
        "",
        "",
    },
    icons = {
        "",
        "",
        "",
        "",
        "",
    },
    hidden = {
        false,
        false,
        false,
        false,
        false,
    },
}

local IconLibrary = {
    "/esoui/art/icons/poi/poi_group_house_owned.dds",
    "/esoui/art/icons/poi/poi_group_house_unowned.dds",
    "/esoui/art/icons/poi/poi_group_house_glow.dds",
    "/esoui/art/icons/poi/poi_wayshrine_complete.dds",
    "/esoui/art/icons/poi/poi_wayshrine_incomplete.dds",
    "/esoui/art/icons/poi/poi_group_dungeon_complete.dds",
    "/esoui/art/icons/poi/poi_group_dungeon_incomplete.dds",
    "/esoui/art/icons/poi/poi_groupinstance_complete.dds",
    "/esoui/art/icons/poi/poi_groupinstance_incomplete.dds",
    "/esoui/art/icons/poi/poi_groupboss_complete.dds",
    "/esoui/art/icons/poi/poi_groupboss_incomplete.dds",
    "/esoui/art/icons/poi/poi_delve_complete.dds",
    "/esoui/art/icons/poi/poi_delve_incomplete.dds",
    "/esoui/art/icons/poi/poi_town_complete.dds",
    "/esoui/art/icons/poi/poi_town_incomplete.dds",
    "/esoui/art/icons/poi/poi_portal_complete.dds",
    "/esoui/art/icons/poi/poi_portal_incomplete.dds",
    "/esoui/art/icons/poi/poi_door_complete.dds",
    "/esoui/art/icons/poi/poi_door_incomplete.dds",
    "/esoui/art/icons/poi/poi_bank_complete.dds",
    "/esoui/art/icons/poi/poi_bank_incomplete.dds",
    "/esoui/art/icons/poi/poi_stable_complete.dds",
    "/esoui/art/icons/poi/poi_stable_incomplete.dds",
    "/esoui/art/icons/poi/poi_theater_complete.dds",
    "/esoui/art/icons/poi/poi_theater_incomplete.dds",
    "/esoui/art/icons/poi/poi_underground_complete.dds",
    "/esoui/art/icons/poi/poi_underground_incomplete.dds",
    "/esoui/art/icons/poi/poi_guildtrader_complete.dds",
    "/esoui/art/icons/poi/poi_guildtrader_incomplete.dds",
    "/esoui/art/icons/poi/poi_fence_complete.dds",
    "/esoui/art/icons/poi/poi_fence_incomplete.dds",
    "/esoui/art/icons/poi/poi_house_owned.dds",
    "/esoui/art/icons/poi/poi_house_unowned.dds",
    "/esoui/art/icons/poi/poi_areaofinterest_complete.dds",
    "/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds",
    "/esoui/art/icons/poi/poi_sewer_complete.dds",
    "/esoui/art/icons/poi/poi_sewer_incomplete.dds",
    "/esoui/art/icons/poi/poi_objective_complete.dds",
    "/esoui/art/icons/poi/poi_objective_incomplete.dds",
    "/esoui/art/compass/quest_available_icon.dds",
    "/esoui/art/compass/quest_assisted_icon.dds",
    "/esoui/art/compass/quest_complete_icon.dds",
    "/esoui/art/compass/groupmember.dds",
    "/esoui/art/compass/group_areaofinterest.dds",
    "/esoui/art/compass/ava_largekeep_neutral.dds",
    "/esoui/art/compass/ava_largekeep_aldmeri.dds",
    "/esoui/art/compass/ava_largekeep_daggerfall.dds",
    "/esoui/art/compass/ava_largekeep_ebonheart.dds",
    "/esoui/art/compass/ava_outpost_neutral.dds",
    "/esoui/art/compass/ava_outpost_aldmeri.dds",
    "/esoui/art/compass/ava_outpost_daggerfall.dds",
    "/esoui/art/compass/ava_outpost_ebonheart.dds",
    "/esoui/art/compass/ava_town_neutral.dds",
    "/esoui/art/compass/ava_town_aldmeri.dds",
    "/esoui/art/compass/ava_town_daggerfall.dds",
    "/esoui/art/compass/ava_town_ebonheart.dds",
    "/esoui/art/compass/ava_mine_neutral.dds",
    "/esoui/art/compass/ava_mine_aldmeri.dds",
    "/esoui/art/compass/ava_mine_daggerfall.dds",
    "/esoui/art/compass/ava_mine_ebonheart.dds",
    "/esoui/art/compass/ava_farm_neutral.dds",
    "/esoui/art/compass/ava_farm_aldmeri.dds",
    "/esoui/art/compass/ava_farm_daggerfall.dds",
    "/esoui/art/compass/ava_farm_ebonheart.dds",
    "/esoui/art/compass/ava_lumbermill_neutral.dds",
    "/esoui/art/compass/ava_lumbermill_aldmeri.dds",
    "/esoui/art/compass/ava_lumbermill_daggerfall.dds",
    "/esoui/art/compass/ava_lumbermill_ebonheart.dds",
    "/esoui/art/compass/compass_groupboss.dds",
    "/esoui/art/compass/compass_door.dds",
    "/esoui/art/compass/compass_house.dds",
    "/esoui/art/compass/compass_quest.dds",
    "/esoui/art/compass/compass_wayshrine.dds",
    "/esoui/art/mappins/ava_largekeep_neutral.dds",
    "/esoui/art/mappins/ava_largekeep_aldmeri.dds",
    "/esoui/art/mappins/ava_largekeep_daggerfall.dds",
    "/esoui/art/mappins/ava_largekeep_ebonheart.dds",
    "/esoui/art/mappins/ava_outpost_neutral.dds",
    "/esoui/art/mappins/ava_outpost_aldmeri.dds",
    "/esoui/art/mappins/ava_outpost_daggerfall.dds",
    "/esoui/art/mappins/ava_outpost_ebonheart.dds",
    "/esoui/art/mappins/ava_town_neutral.dds",
    "/esoui/art/mappins/ava_town_aldmeri.dds",
    "/esoui/art/mappins/ava_town_daggerfall.dds",
    "/esoui/art/mappins/ava_town_ebonheart.dds",
    "/esoui/art/mappins/ava_mine_neutral.dds",
    "/esoui/art/mappins/ava_mine_aldmeri.dds",
    "/esoui/art/mappins/ava_mine_daggerfall.dds",
    "/esoui/art/mappins/ava_mine_ebonheart.dds",
    "/esoui/art/mappins/ava_farm_neutral.dds",
    "/esoui/art/mappins/ava_farm_aldmeri.dds",
    "/esoui/art/mappins/ava_farm_daggerfall.dds",
    "/esoui/art/mappins/ava_farm_ebonheart.dds",
    "/esoui/art/mappins/ava_lumbermill_neutral.dds",
    "/esoui/art/mappins/ava_lumbermill_aldmeri.dds",
    "/esoui/art/mappins/ava_lumbermill_daggerfall.dds",
    "/esoui/art/mappins/ava_lumbermill_ebonheart.dds",
    "/esoui/art/mappins/wayshrine_complete.dds",
    "/esoui/art/mappins/wayshrine_incomplete.dds",
    "/esoui/art/mappins/groupboss_complete.dds",
    "/esoui/art/mappins/groupboss_incomplete.dds",
    "/esoui/art/mappins/dungeon_complete.dds",
    "/esoui/art/mappins/dungeon_incomplete.dds",
    "/esoui/art/mappins/poi_complete.dds",
    "/esoui/art/mappins/poi_incomplete.dds",
    "/esoui/art/mappins/house_owned.dds",
    "/esoui/art/mappins/house_unowned.dds",
    "/esoui/art/mappins/portal_complete.dds",
    "/esoui/art/mappins/portal_incomplete.dds",
    "/esoui/art/mappins/door_complete.dds",
    "/esoui/art/mappins/door_incomplete.dds",
    "/esoui/art/mappins/delve_complete.dds",
    "/esoui/art/mappins/delve_incomplete.dds",
    "/esoui/art/mappins/town_complete.dds",
    "/esoui/art/mappins/town_incomplete.dds",
    "/esoui/art/mappins/underground_complete.dds",
    "/esoui/art/mappins/underground_incomplete.dds",
    "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_map.dds",
    "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_quest.dds",
    "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_social.dds",
}

local PANEL_SCENES = {
    "hud",
    "hudui",
}

local function Trim(value)
    if value == nil then
        return ""
    end
    return tostring(value):gsub("^%s+", ""):gsub("%s+$", "")
end

local function IsEmpty(value)
    return Trim(value) == ""
end

local function GetLAM()
    if LibAddonMenu2 then
        return LibAddonMenu2
    end
    if LibStub then
        return LibStub("LibAddonMenu-2.0", true)
    end
    return nil
end

local function EnsureArray(target, defaults)
    if type(target) ~= "table" then
        target = {}
    end
    for index = 1, #defaults do
        if target[index] == nil then
            target[index] = defaults[index]
        end
    end
    return target
end

local function MigrateSavedVariables()
    SBB.account.commands = EnsureArray(SBB.account.commands, accountDefaults.commands)
    SBB.account.icons = EnsureArray(SBB.account.icons, accountDefaults.icons)
    SBB.account.hidden = EnsureArray(SBB.account.hidden, accountDefaults.hidden)
    SBB.character.commands = EnsureArray(SBB.character.commands, characterDefaults.commands)
    SBB.character.icons = EnsureArray(SBB.character.icons, characterDefaults.icons)
    SBB.character.hidden = EnsureArray(SBB.character.hidden, characterDefaults.hidden)

    if SBB.account.buttonSize == nil then
        SBB.account.buttonSize = accountDefaults.buttonSize
    end
    if SBB.account.buttonSpacing == nil then
        SBB.account.buttonSpacing = accountDefaults.buttonSpacing
    end
    if SBB.account.orientation == nil or (SBB.account.orientation ~= "Horizontal" and SBB.account.orientation ~= "Vertical") then
        SBB.account.orientation = accountDefaults.orientation
    end
    if SBB.account.hideWhileMenusOpen == nil then
        SBB.account.hideWhileMenusOpen = accountDefaults.hideWhileMenusOpen
    end
    if SBB.account.visible == nil then
        SBB.account.visible = accountDefaults.visible
    end
    if SBB.account.locked == nil then
        SBB.account.locked = accountDefaults.locked
    end
    if SBB.account.x == nil then
        SBB.account.x = accountDefaults.x
    end
    if SBB.account.y == nil then
        SBB.account.y = accountDefaults.y
    end
end

local function GetScopeTable(scope)
    if scope == "global" then
        return SBB.account
    end
    return SBB.character
end

local function GetActionName(scope, index)
    if scope == "global" then
        return "SBB_GLOBAL_" .. index
    end
    return "SBB_CHAR_" .. index
end

local function GetSlotData(scope, index)
    local data = GetScopeTable(scope)
    return {
        command = Trim(data.commands[index]),
        icon = Trim(data.icons[index]),
        hidden = data.hidden[index] == true,
        actionName = GetActionName(scope, index),
    }
end

local function SafeSetTexture(control, texture)
    control:SetNormalTexture(texture)
    control:SetMouseOverTexture(texture)
    control:SetPressedTexture(texture)
end

local function SetSlotCommand(scope, index, value)
    GetScopeTable(scope).commands[index] = value or ""
end

local function SetSlotIcon(scope, index, value)
    GetScopeTable(scope).icons[index] = value or ""
end

local function SetSlotHidden(scope, index, value)
    GetScopeTable(scope).hidden[index] = value == true
end

function SBB.Execute(commandText)
    local command = Trim(commandText)
    if command == "" then
        d("|cFFAA33Slash Bind Buttons: empty command.|r")
        return
    end

    if command:sub(1, 1) == "/" then
        local slash, args = command:match("^(%S+)%s*(.*)$")
        local handler = slash and SLASH_COMMANDS and SLASH_COMMANDS[slash]
        if handler then
            handler(args or "")
        else
            StartChatInput(command)
            d("|cFFAA33Slash Bind Buttons: slash command is not registered by the UI. The text was placed into chat instead.|r")
        end
        return
    end

    StartChatInput(command)
end

function SBB.Use(scope, index)
    local data = GetSlotData(scope, index)
    SBB.Execute(data.command)
end

local function BindingLabel(actionName)
    if ZO_Keybindings_GetBindingStringFromAction then
        local ok, text = pcall(ZO_Keybindings_GetBindingStringFromAction, actionName, 0, 0, 1)
        if ok and text and text ~= "" then
            return text
        end
    end
    return ""
end

local function GetVisibleSlotDescriptors()
    local visibleSlots = {}
    local orderedScopes = {
        { scope = "global", count = 5 },
        { scope = "char", count = 5 },
    }

    for _, descriptor in ipairs(orderedScopes) do
        for index = 1, descriptor.count do
            local data = GetSlotData(descriptor.scope, index)
            local keybind = BindingLabel(data.actionName)
            if keybind ~= "" and not IsEmpty(data.command) and not IsEmpty(data.icon) and not data.hidden then
                visibleSlots[#visibleSlots + 1] = {
                    scope = descriptor.scope,
                    index = index,
                    actionName = data.actionName,
                    command = data.command,
                    icon = data.icon,
                    keybind = keybind,
                }
            end
        end
    end

    return visibleSlots
end

local function SetPanelAnchor()
    SBB.panel:ClearAnchors()
    SBB.panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SBB.account.x or accountDefaults.x, SBB.account.y or accountDefaults.y)
end

local function GetOrientation()
    if SBB.account.orientation == "Vertical" then
        return "Vertical"
    end
    return "Horizontal"
end

local function SafeGetSceneManager()
    if type(SCENE_MANAGER) == "table" then
        return SCENE_MANAGER
    end
    return nil
end

local function ShouldHideForMenu()
    if not SBB.account or not SBB.account.hideWhileMenusOpen then
        return false
    end

    local sceneManager = SafeGetSceneManager()
    if not sceneManager then
        return false
    end

    local currentScene = sceneManager.GetCurrentScene and sceneManager:GetCurrentScene()
    if currentScene and currentScene.GetName then
        local currentName = currentScene:GetName()
        for _, allowedScene in ipairs(PANEL_SCENES) do
            if currentName == allowedScene then
                return false
            end
        end
    end

    if sceneManager.IsShowingBaseScene and sceneManager:IsShowingBaseScene() then
        return false
    end

    if sceneManager.IsInUIMode and sceneManager:IsInUIMode() then
        return true
    end

    if currentScene ~= nil then
        return true
    end

    return false
end

function SBB.RefreshVisibility()
    if not SBB.panel then
        return
    end

    local shouldHide = (not SBB.account.visible) or ShouldHideForMenu() or (not SBB.visibleSlots) or (#SBB.visibleSlots == 0)
    SBB.panel:SetHidden(shouldHide)
end

local function StartPanelDrag()
    if not SBB.panel or not SBB.account or SBB.account.locked then
        return
    end
    SBB.panel:StartMoving()
end

local function StopPanelDrag()
    if not SBB.panel then
        return
    end

    SBB.panel:StopMovingOrResizing()
    if SBB.account then
        SBB.account.x = math.floor(SBB.panel:GetLeft())
        SBB.account.y = math.floor(SBB.panel:GetTop())
    end
    SBB.RefreshVisibility()
    SBB.RefreshSettings()
end

function SBB.RefreshButtons()
    if not SBB.panel then
        return
    end

    local size = tonumber(SBB.account.buttonSize) or DEFAULT_SIZE
    local spacing = tonumber(SBB.account.buttonSpacing) or DEFAULT_SPACING
    if spacing < 0 then
        spacing = 0
    end

    SetPanelAnchor()
    SBB.panel:SetMovable(not SBB.account.locked)
    SBB.panel:SetMouseEnabled(true)

    SBB.visibleSlots = GetVisibleSlotDescriptors()
    local count = #SBB.visibleSlots

    for slotIndex = 1, #SBB.buttons do
        local button = SBB.buttons[slotIndex]
        local keyLabel = SBB.labels[slotIndex]
        local slotData = SBB.visibleSlots[slotIndex]

        if slotData then
            button.scope = slotData.scope
            button.index = slotData.index
            button.commandText = slotData.command
            button:SetDimensions(size, size)
            button:ClearAnchors()

            if GetOrientation() == "Vertical" then
                button:SetAnchor(TOPLEFT, SBB.panel, TOPLEFT, 0, (slotIndex - 1) * (size + spacing))
            else
                button:SetAnchor(TOPLEFT, SBB.panel, TOPLEFT, (slotIndex - 1) * (size + spacing), 0)
            end

            SafeSetTexture(button, slotData.icon)
            keyLabel:SetText(slotData.keybind)
            button:SetHidden(false)
            keyLabel:SetHidden(false)
        else
            button.scope = nil
            button.index = nil
            button.commandText = ""
            button:SetHidden(true)
            keyLabel:SetHidden(true)
        end
    end

    local panelWidth = 1
    local panelHeight = 1
    if count > 0 then
        if GetOrientation() == "Vertical" then
            panelWidth = size
            panelHeight = size * count + spacing * (count - 1)
        else
            panelWidth = size * count + spacing * (count - 1)
            panelHeight = size
        end
    end

    SBB.panel:SetDimensions(panelWidth, panelHeight)
    SBB.RefreshVisibility()
end

local function CreateButton(slot)
    local button = WINDOW_MANAGER:CreateControl("SBB_Button_" .. slot, SBB.panel, CT_BUTTON)
    button:SetClickSound("Click")
    button:SetDrawLayer(DL_CONTROLS)
    button:SetHandler("OnMouseDown", function(_, buttonIndex)
        if buttonIndex == MOUSE_BUTTON_INDEX_LEFT and SBB.account and not SBB.account.locked then
            StartPanelDrag()
        end
    end)
    button:SetHandler("OnMouseUp", function(_, buttonIndex)
        if buttonIndex == MOUSE_BUTTON_INDEX_LEFT and SBB.account and not SBB.account.locked then
            StopPanelDrag()
        end
    end)
    button:SetHandler("OnClicked", function(control)
        if not SBB.account or not SBB.account.locked then
            return
        end
        if control.scope and control.index then
            SBB.Use(control.scope, control.index)
        end
    end)
    button:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, RIGHT, -5, 0)
        if SBB.account and not SBB.account.locked then
            SetTooltipText(InformationTooltip, "Panel unlocked. Drag any button to move the panel.")
            return
        end

        local scopeLabel = control.scope == "global" and "Account" or "Character"
        local command = Trim(control.commandText)
        SetTooltipText(InformationTooltip, scopeLabel .. " " .. tostring(control.index or "?") .. "\n" .. (command ~= "" and command or "<empty>"))
    end)
    button:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    local label = WINDOW_MANAGER:CreateControl("SBB_Button_" .. slot .. "_Key", button, CT_LABEL)
    label:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, -1)
    label:SetFont("ZoFontGameSmall")
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    label:SetColor(1, 1, 1, 1)
    label:SetDrawLayer(DL_OVERLAY)

    SBB.buttons[slot] = button
    SBB.labels[slot] = label
end

local function CloseIconPicker()
    if SBB.iconPicker then
        SBB.iconPicker:SetHidden(true)
    end
end

function ClearPickerIconControls()
    if not SBB.iconPicker or not SBB.iconPicker.iconButtons then
        return
    end

    for _, entry in ipairs(SBB.iconPicker.iconButtons) do
        entry.cell:SetHidden(true)
        entry.button.iconPath = nil
        entry.texture:SetTexture(nil)
    end
end

function RenderIconPickerPage()
    if not SBB.iconPicker then
        return
    end

    local picker = SBB.iconPicker
    local totalIcons = #IconLibrary
    local totalPages = math.max(1, math.ceil(totalIcons / ICONS_PER_PAGE))
    if picker.page < 1 then
        picker.page = 1
    end
    if picker.page > totalPages then
        picker.page = totalPages
    end

    ClearPickerIconControls()

    local pageStart = (picker.page - 1) * ICONS_PER_PAGE + 1
    local pageEnd = math.min(pageStart + ICONS_PER_PAGE - 1, totalIcons)

    for pageIndex = pageStart, pageEnd do
        local localIndex = pageIndex - pageStart + 1
        local entry = picker.iconButtons[localIndex]
        local iconPath = IconLibrary[pageIndex]
        entry.button.iconPath = iconPath
        entry.texture:SetTexture(iconPath)
        entry.cell:SetHidden(false)
    end

    picker.pageLabel:SetText(string.format("Page %d / %d", picker.page, totalPages))
    picker.previousButton:SetEnabled(picker.page > 1)
    picker.nextButton:SetEnabled(picker.page < totalPages)
    picker.previousButton:SetAlpha(picker.page > 1 and 1 or 0.45)
    picker.nextButton:SetAlpha(picker.page < totalPages and 1 or 0.45)
end

local function SelectPickerIcon(iconPath)
    if not SBB.iconPickerContext then
        return
    end

    SetSlotIcon(SBB.iconPickerContext.scope, SBB.iconPickerContext.index, iconPath)
    SBB.RefreshButtons()
    SBB.RefreshSettings()
    CloseIconPicker()
end

local function CreateTextButton(parent, name, width, height, text, anchorPoint, anchorTarget, anchorRelativePoint, offsetX, offsetY, onClick)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(width, height)
    button:SetAnchor(anchorPoint, anchorTarget, anchorRelativePoint, offsetX, offsetY)
    button:SetClickSound("Click")

    local backdrop = WINDOW_MANAGER:CreateControl(name .. "_Backdrop", button, CT_BACKDROP)
    backdrop:SetAnchorFill(button)
    backdrop:SetCenterColor(0.12, 0.12, 0.12, 0.95)
    backdrop:SetEdgeColor(0.7, 0.7, 0.7, 0.85)
    backdrop:SetInsets(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl(name .. "_Label", button, CT_LABEL)
    label:SetAnchor(CENTER, button, CENTER, 0, 0)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(text)

    button.label = label
    button.backdrop = backdrop
    button:SetHandler("OnClicked", onClick)

    return button
end

local function CreateIconPickerButton(parent, name, x, y)
    local cell = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    cell:SetDimensions(48, 48)
    cell:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    cell:SetMouseEnabled(true)

    local bg = WINDOW_MANAGER:CreateControl(name .. "_BG", cell, CT_BACKDROP)
    bg:SetAnchorFill(cell)
    bg:SetCenterColor(0.08, 0.08, 0.08, 0.85)
    bg:SetEdgeColor(0.4, 0.4, 0.4, 0.8)
    bg:SetInsets(0, 0, 0, 0)

    local texture = WINDOW_MANAGER:CreateControl(name .. "_Texture", cell, CT_TEXTURE)
    texture:SetAnchorFill(cell)
    texture:SetDrawLayer(DL_CONTROLS)
    texture:SetTexture(nil)

    local button = WINDOW_MANAGER:CreateControl(name .. "_Button", cell, CT_BUTTON)
    button:SetAnchorFill(cell)
    button:SetClickSound("Click")

    button:SetHandler("OnClicked", function(control)
        if control.iconPath then
            SelectPickerIcon(control.iconPath)
        end
    end)
    button:SetHandler("OnMouseEnter", function(control)
        if control.iconPath then
            InitializeTooltip(InformationTooltip, control, RIGHT, -5, 0)
            SetTooltipText(InformationTooltip, control.iconPath)
        end
    end)
    button:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    return {
        cell = cell,
        button = button,
        texture = texture,
    }
end

local function CreateIconPicker()
    if SBB.iconPicker then
        return
    end

    local picker = WINDOW_MANAGER:CreateTopLevelWindow("SBB_IconPicker")
    picker:SetDimensions(360, 360)
    picker:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    picker:SetClampedToScreen(true)
    picker:SetDrawLayer(DL_OVERLAY)
    picker:SetMouseEnabled(true)
    picker:SetMovable(true)
    picker:SetHidden(true)
    picker:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StartMoving()
        end
    end)
    picker:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
        end
    end)

    local backdrop = WINDOW_MANAGER:CreateControl("SBB_IconPicker_Backdrop", picker, CT_BACKDROP)
    backdrop:SetAnchorFill(picker)
    backdrop:SetCenterColor(0.05, 0.05, 0.05, 0.92)
    backdrop:SetEdgeColor(0.8, 0.8, 0.8, 0.75)
    backdrop:SetInsets(0, 0, 0, 0)

    local title = WINDOW_MANAGER:CreateControl("SBB_IconPicker_Title", picker, CT_LABEL)
    title:SetAnchor(TOPLEFT, picker, TOPLEFT, 16, 12)
    title:SetFont("ZoFontWinH2")
    title:SetText("Slash Bind Buttons: Icon Picker")

    local closeButton = WINDOW_MANAGER:CreateControl("SBB_IconPicker_Close", picker, CT_BUTTON)
    closeButton:SetDimensions(24, 24)
    closeButton:SetAnchor(TOPRIGHT, picker, TOPRIGHT, -10, 10)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetHandler("OnClicked", CloseIconPicker)

    local previousButton = CreateTextButton(picker, "SBB_IconPicker_Previous", 90, 28, "Previous", BOTTOMLEFT, picker, BOTTOMLEFT, 16, -16, function()
        picker.page = picker.page - 1
        RenderIconPickerPage()
    end)

    local nextButton = CreateTextButton(picker, "SBB_IconPicker_Next", 90, 28, "Next", BOTTOMRIGHT, picker, BOTTOMRIGHT, -16, -16, function()
        picker.page = picker.page + 1
        RenderIconPickerPage()
    end)

    local pageLabel = WINDOW_MANAGER:CreateControl("SBB_IconPicker_PageLabel", picker, CT_LABEL)
    pageLabel:SetAnchor(BOTTOM, picker, BOTTOM, 0, -20)
    pageLabel:SetFont("ZoFontGame")
    pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    picker.iconButtons = {}
    picker.page = 1
    picker.pageLabel = pageLabel
    picker.previousButton = previousButton
    picker.nextButton = nextButton

    local startX = 16
    local startY = 52
    local buttonSize = 48
    local gap = 16
    local columns = 5

    for iconIndex = 1, ICONS_PER_PAGE do
        local zeroBased = iconIndex - 1
        local row = math.floor(zeroBased / columns)
        local col = zeroBased % columns
        local x = startX + col * (buttonSize + gap)
        local y = startY + row * (buttonSize + gap)
        picker.iconButtons[iconIndex] = CreateIconPickerButton(picker, "SBB_IconPicker_Icon_" .. iconIndex, x, y)
    end

    SBB.iconPicker = picker
end

function SBB.OpenIconPicker(scope, index)
    CreateIconPicker()
    SBB.iconPickerContext = {
        scope = scope,
        index = index,
    }
    SBB.iconPicker.page = 1
    RenderIconPickerPage()
    SBB.iconPicker:SetHidden(false)
    SBB.iconPicker:BringWindowToTop()
end

local function CreatePanel()
    SBB.panel = WINDOW_MANAGER:CreateTopLevelWindow("SBB_Panel")
    SBB.panel:SetClampedToScreen(true)
    SBB.panel:SetDrawLayer(DL_OVERLAY)
    SBB.panel:SetMouseEnabled(false)
    SBB.panel:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not SBB.account.locked then
            control:StartMoving()
        end
    end)
    SBB.panel:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            control:StopMovingOrResizing()
        end
    end)
    SBB.panel:SetHandler("OnMoveStop", function(control)
        SBB.account.x = math.floor(control:GetLeft())
        SBB.account.y = math.floor(control:GetTop())
        SBB.RefreshSettings()
        SBB.RefreshButtons()
    end)

    SBB.buttons = {}
    SBB.labels = {}
    for slot = 1, 10 do
        CreateButton(slot)
    end

    SBB.RefreshButtons()
end

function SBB.RefreshSettings()
    local lam = GetLAM()
    if not (SBB.panelName and lam and lam.util and lam.util.RequestRefreshIfNeeded) then
        return
    end

    zo_callLater(function()
        local delayedLam = GetLAM()
        if not (SBB.panelName and delayedLam and delayedLam.util and delayedLam.util.RequestRefreshIfNeeded) then
            return
        end

        pcall(function()
            delayedLam.util.RequestRefreshIfNeeded(SBB.panelName)
        end)
    end, 50)
end

local function RefreshEverything()
    SBB.RefreshButtons()
    SBB.RefreshVisibility()
    SBB.RefreshSettings()
end

local function MakeCommandEditBox(scope, index)
    local scopeLabel = scope == "global" and "Account" or "Character"
    return {
        type = "editbox",
        name = string.format("%s command %d", scopeLabel, index),
        tooltip = "Examples: /script RequestJumpToHouse(95, true), /reloadui, /zone. If the text does not start with / it is placed into chat input.",
        width = "full",
        isMultiline = true,
        getFunc = function()
            return GetScopeTable(scope).commands[index]
        end,
        setFunc = function(value)
            SetSlotCommand(scope, index, value)
            RefreshEverything()
        end,
        default = "",
    }
end

local function MakeIconEditBox(scope, index)
    local scopeLabel = scope == "global" and "Account" or "Character"
    return {
        type = "editbox",
        name = string.format("%s icon path %d", scopeLabel, index),
        tooltip = "Game texture path, for example: /esoui/art/icons/poi/poi_group_house_owned.dds",
        width = "full",
        getFunc = function()
            return GetScopeTable(scope).icons[index]
        end,
        setFunc = function(value)
            SetSlotIcon(scope, index, Trim(value))
            RefreshEverything()
        end,
        default = "",
    }
end

local function MakeChooseIconButton(scope, index)
    local scopeLabel = scope == "global" and "Account" or "Character"
    return {
        type = "button",
        name = string.format("Choose %s icon %d", string.lower(scopeLabel), index),
        width = "full",
        func = function()
            SBB.OpenIconPicker(scope, index)
        end,
    }
end

local function MakeHideCheckbox(scope, index)
    local scopeLabel = scope == "global" and "Account" or "Character"
    return {
        type = "checkbox",
        name = string.format("%s hide this button %d", scopeLabel, index),
        tooltip = "Hide this slot from the on-screen panel even when command, icon, and keybind are set.",
        getFunc = function()
            return GetScopeTable(scope).hidden[index] == true
        end,
        setFunc = function(value)
            SetSlotHidden(scope, index, value)
            RefreshEverything()
        end,
        default = false,
    }
end

local function RegisterSettings()
    local lam = GetLAM()
    if not lam then
        d("|cFFAA33Slash Bind Buttons: LibAddonMenu-2.0 not found. Buttons and keybinds still work, but addon settings are unavailable.|r")
        return
    end

    SBB.panelName = "SlashBindButtons_Settings"

    lam:RegisterAddonPanel(SBB.panelName, {
        type = "panel",
        name = "Slash Bind Buttons",
        displayName = "|c4B8BFESlash Bind Buttons|r",
        author = "ChatGPT",
        version = ADDON_VERSION,
        slashCommand = "/sbb",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local options = {
        {
            type = "description",
            text = "Minimal custom slash-command buttons with 5 account-wide slots and 5 character-specific slots. Assign keybinds in Controls -> Addon Keybinds.",
        },
        {
            type = "header",
            name = "Panel / display settings",
        },
        {
            type = "checkbox",
            name = "Show button panel",
            getFunc = function()
                return SBB.account.visible
            end,
            setFunc = function(value)
                SBB.account.visible = value
                RefreshEverything()
            end,
            default = accountDefaults.visible,
        },
        {
            type = "dropdown",
            name = "Panel orientation",
            choices = { "Horizontal", "Vertical" },
            getFunc = function()
                return GetOrientation()
            end,
            setFunc = function(value)
                SBB.account.orientation = value
                RefreshEverything()
            end,
            default = accountDefaults.orientation,
        },
        {
            type = "slider",
            name = "X position",
            min = 0,
            max = 3000,
            step = 1,
            getFunc = function()
                return SBB.account.x
            end,
            setFunc = function(value)
                SBB.account.x = value
                RefreshEverything()
            end,
            default = accountDefaults.x,
        },
        {
            type = "slider",
            name = "Y position",
            min = 0,
            max = 2000,
            step = 1,
            getFunc = function()
                return SBB.account.y
            end,
            setFunc = function(value)
                SBB.account.y = value
                RefreshEverything()
            end,
            default = accountDefaults.y,
        },
        {
            type = "slider",
            name = "Button size",
            min = 28,
            max = 72,
            step = 1,
            getFunc = function()
                return SBB.account.buttonSize
            end,
            setFunc = function(value)
                SBB.account.buttonSize = value
                RefreshEverything()
            end,
            default = accountDefaults.buttonSize,
        },
        {
            type = "slider",
            name = "Button spacing",
            min = 0,
            max = 24,
            step = 1,
            getFunc = function()
                return SBB.account.buttonSpacing
            end,
            setFunc = function(value)
                SBB.account.buttonSpacing = value
                RefreshEverything()
            end,
            default = accountDefaults.buttonSpacing,
        },
        {
            type = "checkbox",
            name = "Lock panel",
            tooltip = "Unlock to drag the panel with the mouse. Position is saved account-wide on drag stop.",
            getFunc = function()
                return SBB.account.locked
            end,
            setFunc = function(value)
                SBB.account.locked = value
                RefreshEverything()
            end,
            default = accountDefaults.locked,
        },
        {
            type = "checkbox",
            name = "Hide panel while menus are open",
            tooltip = "Hide the panel when inventory, map, settings, dialogs, or other UI scenes are open.",
            getFunc = function()
                return SBB.account.hideWhileMenusOpen
            end,
            setFunc = function(value)
                SBB.account.hideWhileMenusOpen = value
                RefreshEverything()
            end,
            default = accountDefaults.hideWhileMenusOpen,
        },
        {
            type = "button",
            name = "Reset panel position",
            width = "full",
            func = function()
                SBB.account.x = accountDefaults.x
                SBB.account.y = accountDefaults.y
                RefreshEverything()
            end,
        },
        {
            type = "header",
            name = "Account-wide commands",
        },
    }

    for index = 1, 5 do
        options[#options + 1] = {
            type = "submenu",
            name = "Account slot " .. index,
            controls = {
                MakeCommandEditBox("global", index),
                MakeIconEditBox("global", index),
                MakeChooseIconButton("global", index),
                MakeHideCheckbox("global", index),
            },
        }
    end

    options[#options + 1] = {
        type = "header",
        name = "Character-specific commands",
    }

    for index = 1, 5 do
        options[#options + 1] = {
            type = "submenu",
            name = "Character slot " .. index,
            controls = {
                MakeCommandEditBox("char", index),
                MakeIconEditBox("char", index),
                MakeChooseIconButton("char", index),
                MakeHideCheckbox("char", index),
            },
        }
    end

    lam:RegisterOptionControls(SBB.panelName, options)
end

local function CreateBindingNames()
    for index = 1, 5 do
        ZO_CreateStringId("SI_BINDING_NAME_SBB_GLOBAL_" .. index, "SBB Account Command " .. index)
        ZO_CreateStringId("SI_BINDING_NAME_SBB_CHAR_" .. index, "SBB Character Command " .. index)
    end
end

local function RegisterSceneCallbacks()
    local sceneManager = SafeGetSceneManager()
    if not sceneManager then
        return
    end

    if sceneManager.RegisterCallback then
        sceneManager:RegisterCallback("SceneStateChanged", function()
            SBB.RefreshVisibility()
        end)
    end

    for _, sceneName in ipairs(PANEL_SCENES) do
        local scene = sceneManager.GetScene and sceneManager:GetScene(sceneName)
        if scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", function()
                SBB.RefreshVisibility()
            end)
        end
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SBB.account = ZO_SavedVars:NewAccountWide("SlashBindButtons_Account", 1, nil, accountDefaults)
    SBB.character = ZO_SavedVars:NewCharacterIdSettings("SlashBindButtons_Character", 1, nil, characterDefaults)
    MigrateSavedVariables()

    CreateBindingNames()
    CreatePanel()
    RegisterSettings()
    RegisterSceneCallbacks()

    SLASH_COMMANDS["/sbbreload"] = function()
        SBB.RefreshButtons()
        d("Slash Bind Buttons: panel refreshed.")
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Keybinds", EVENT_KEYBINDINGS_LOADED, function()
        zo_callLater(SBB.RefreshButtons, 250)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(SBB.RefreshButtons, 100)
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
