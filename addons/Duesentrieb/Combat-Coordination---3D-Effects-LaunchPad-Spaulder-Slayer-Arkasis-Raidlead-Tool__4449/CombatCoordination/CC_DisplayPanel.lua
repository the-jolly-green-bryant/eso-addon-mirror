local CC = CombatCoordination
local LUT = CC.LUT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayPanel",
    Parent = nil,
    Fragment = nil,

    AddonUserLabels = {},
    SlayerSetUserLabels = {},
    ArkasisUserLabels = {},
    SpaulderUserLabels = {},
    RegisteredButtons = {},
    SpaulderSortBuffer = {},
    AddonUserSortBuffer = {},
    SlayerSortBuffer = {},
    ArkasisSortBuffer = {},

    activeAddonUserLabels = 0,
    activeSlayerSetUserLabels = 0,
    activeArkasisUserLabels = 0,
    activeSpaulderUserLabels = 0,

    maxLengthDisplayName = 14,

    -------------------------------------------------------------------------------------------------
    -- COLORS
    -------------------------------------------------------------------------------------------------
    GN_NORMAL    = { 0, 1, 0, 1 },
    RD_NORMAL    = { 1, 0, 0, 1 },
    BL_NORMAL    = { 0, 0.5, 1, 1 },
    YL_NORMAL    = { 1, 1, 0, 1 },

    OG_HIGHLIGHT = { 1,    0.75,  0.5,  1 }, -- CONTAINER ON MOUSE CLICK
    OG_BRIGHT    = { 1,    0.625, 0.25, 1 }, -- CONTAINER TITLE; BREAK TIMER TITLE; PULL TIMER TITLE
    OG_NORMAL    = { 1,    0.5,   0,    1 }, -- TITLE COMBAT COORDINATION
    OG_MUTED     = { 0.75, 0.375, 0,    1 }, -- CONTAINER EDGE COLOR
    OG_DARK      = { 0.5,  0.25,  0,    1 }, -- PANEL EDGE COLOR

    ESO_HIGHLIGHT = { 1 / 255 * 239, 1 / 255 * 235, 1 / 255 * 190, 1 },
    ESO_NORMAL    = { 1 / 255 * 197, 1 / 255 * 194, 1 / 255 * 158, 1 },
    ESO_MUTED     = { 1 / 255 * 148, 1 / 255 * 143, 1 / 255 * 115, 1 },

    -------------------------------------------------------------------------------------------------
    -- LAYOUT
    -------------------------------------------------------------------------------------------------
    Layout = {
        margin           = 10,  -- DISTANCE TO EDGES AND FOOTER
        spacing          = 5,   -- DISTANCE BETWEEN ELEMENTS / CONTAINERS
        padding          = 5,   -- DISTANCE INSIDE CONTAINER (L / R / BOT)
        paddingTop       = 0,   -- TOP DISTANCE FOR TEXT
        heightHeader     = 24,  -- HEIGHT OF THE CONTAINR HEADER
        heightElement    = 24,  -- HEIGHT OF BUTTONS AND TEXT
    },

    FONT_SIZE_LARGE  = 18,
    FONT_SIZE_MEDIUM = 16,
    FONT_SIZE_SMALL  = 14,

    -------------------------------------------------------------------------------------------------
    -- SAVED VARS
    -------------------------------------------------------------------------------------------------
    Default = {
        offsetX = 0,
        offsetY = 0,
        panelWidth = 300,
        panelScale = 1,
        anchorMode = 1, -- 1 = TOP, 2 = MID, 3 = BOT
        colorA = 0.75,

        fontStyle = "$(BOLD_FONT)",
        fontWeight = "soft-shadow-thick",

        isVisible              = true,
        isMinimized            = false,
        isOpenAddonUsers       = false,
        isOpenArkasisAssistant = false,
        isOpenDrawShape        = false,
        isOpenLaunchPad        = false,
        isOpenPointer          = false,
        isOpenRaidleadTools    = false,
        isOpenSlayerAssistant  = false,
        isOpenSpaulderOfRuin   = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- FONT STRINGS
----------------------------------------------------------------------------------------------------
function Module:UpdateFonts()
    local style = self.SV.fontStyle or "$(BOLD_FONT)"
    local weight = self.SV.fontWeight or "soft-shadow-thick"

    self.Font = {
        Title    = string.format("%s|$(KB_%d)|%s", style, self.FONT_SIZE_LARGE, weight),
        SubTitle = string.format("%s|$(KB_%d)|%s", style, self.FONT_SIZE_LARGE, weight),
        Button   = string.format("%s|$(KB_%d)|%s", style, self.FONT_SIZE_MEDIUM, weight),
        Normal   = string.format("%s|$(KB_%d)|%s", style, self.FONT_SIZE_MEDIUM, weight),
        Small    = string.format("%s|$(KB_%d)|%s", style, self.FONT_SIZE_SMALL, weight),
    }
end

----------------------------------------------------------------------------------------------------
-- APPLY FONTS
----------------------------------------------------------------------------------------------------
function Module:ApplyFonts()
    self:UpdateFonts()
    if not self.Parent then return end

    self.MainTitle:SetFont(self.Font.Title)
    self.LabelAuthor:SetFont(self.Font.Small)

    -- CONTAINERS
    local Containers = {
        self.ContainerAddonUsers,
        self.ContainerArkasisAssistant,
        self.DrawShapeContainer,
        self.ContainerLaunchPad,
        self.PointerContainer,
        self.ContainerRaidleadTools,
        self.ContainerSlayerAssistant,
        self.ContainerSpaulderOfRuin
    }
    for _, Container in ipairs(Containers) do
        if Container and Container.Title then Container.Title:SetFont(self.Font.SubTitle) end
    end

    -- INFO LABELS
    local InfoLabels = {
        self.AddonUsersInfoLabel,
        self.DrawShapeInfoLabel,
        self.LaunchPadInfoLabel,
        self.PointerInfoLabel,
        self.RaidleadToolsInfoLabel,
        self.SpaulderInfoLabel
    }
    for _, Label in ipairs(InfoLabels) do
        if Label then Label:SetFont(self.Font.Small) end
    end

    -- LABEL POOLS
    local Pools = {
        self.AddonUserLabels, self.ArkasisUserLabels, self.SlayerSetUserLabels, self.SpaulderUserLabels
    }
    for _, Pool in ipairs(Pools) do
        for _, Label in pairs(Pool) do
            Label:SetFont(self.Font.Normal)
        end
    end

    -- NORMAL LABELS
    local NormalLabels = {
        self.ArkasisAssistantPositionLabel,
        self.DrawShapeLabelToggle,
        self.DrawShapeLabelValueX,
        self.DrawShapeLabelValueZ,
        self.LaunchPadCatLabelToggle,
        self.LaunchPadLabelToggle,
        self.SlayerAssistantPositionLabel
    }
    for _, Label in ipairs(NormalLabels) do
        if Label then Label:SetFont(self.Font.Normal) end
    end

    -- BUTTONS
    for _, Button in ipairs(self.RegisteredButtons) do
        if Button then Button:SetFont(self.Font.Button) end
    end

    self:UpdateDimensions()
end

----------------------------------------------------------------------------------------------------
-- ROLE ICON
----------------------------------------------------------------------------------------------------
function Module:GetPlayerIconByRole(selectedRole)
    local fontSize = self.FONT_SIZE_MEDIUM

    if selectedRole == LFG_ROLE_TANK then return string.format("|t%s:%s:/esoui/art/lfg/lfg_icon_tank.dds|t", fontSize, fontSize) end
    if selectedRole == LFG_ROLE_HEAL then return string.format("|t%s:%s:/esoui/art/lfg/lfg_icon_healer.dds|t", fontSize, fontSize) end
    if selectedRole == LFG_ROLE_DPS then return string.format("|t%s:%s:/esoui/art/lfg/lfg_icon_dps.dds|t", fontSize, fontSize) end

    return ""
end

----------------------------------------------------------------------------------------------------
-- SHORT(ER) DISPLAY NAME BECAUSE OF KENDRASMYNAMEISUNNECESSARYLONGKENPACHI
----------------------------------------------------------------------------------------------------
function Module:GetShortName(longName, maxLength)
    local limit = maxLength or self.maxLengthDisplayName
    local shortName = tostring(longName)

    if zo_strlen(shortName) > limit then
        shortName = zo_strsub(shortName, 1, limit):gsub("%s+$", "") .. ".."
    end

    return shortName
end

----------------------------------------------------------------------------------------------------
-- TITLE WITH AN ICON
----------------------------------------------------------------------------------------------------
function Module:GetTitleWithIcon(ModuleObject, titleText)
    if ModuleObject and ModuleObject.iconPath then
        local icon = string.format("|t%d:%d:%s|t ", CC.SIZE_ICON_DISPLAYPANEL, CC.SIZE_ICON_DISPLAYPANEL, ModuleObject.iconPath)
        return icon .. titleText
    end
    return titleText
end

----------------------------------------------------------------------------------------------------
-- CREATE PANEL
----------------------------------------------------------------------------------------------------
function Module:CreatePanel()
    if self.Parent then return end
    self:UpdateFonts()

    -- MAIN WINDOW
    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow("CC_DisplayPanel_Parent")
    self.Parent:SetDimensions(self.SV.panelWidth, 100)
    self.Parent:SetScale(self.SV.panelScale)

    self:ApplyAnchor()
    self.Parent:SetClampedToScreen(true)
    self.Parent:SetMouseEnabled(true)
    self.Parent:SetMovable(true)
    self.Parent:SetHidden(true)

    self.Parent:SetHandler("OnMoveStop", function(control)
        self.SV.offsetX = control:GetLeft()
        local anchorMode = self.SV.anchorMode or 1
        if anchorMode == 2 then
            self.SV.offsetY = control:GetTop() + (control:GetHeight() / 2)
        elseif anchorMode == 3 then
            self.SV.offsetY = control:GetBottom()
        else
            self.SV.offsetY = control:GetTop()
        end
        self:ApplyAnchor()
    end)

    -- BACKGROUND
    self.Background = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_Background", self.Parent, CT_BACKDROP)
    self.Background:SetAnchorFill()
    self.Background:SetPixelRoundingEnabled(true)
    local colorA = self.SV.colorA
    self.Background:SetCenterColor(0, 0, 0, colorA)
    self.Background:SetEdgeColor(unpack(self.OG_DARK))
    self.Background:SetEdgeTexture("", 1, 1, 2)

    -- MAIN TITLE
    self.MainTitle = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_Title", self.Parent, CT_LABEL)
    self.MainTitle:SetFont(self.Font.Title)
    self.MainTitle:SetColor(unpack(self.OG_NORMAL))
    self.MainTitle:SetText("|cFF7F00COMBAT|r |cFFFFFFCOORDINATION|r")
    self.MainTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.MainTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.MainTitle:SetMaxLineCount(1)
    self.MainTitle:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    -- MENU BUTTON (GEAR THINGITHING)
    local ButtonMenu = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_Menu", self.Parent, CT_BUTTON)
    ButtonMenu:SetDimensions(20, 20)
    ButtonMenu:SetState(BSTATE_NORMAL)
    ButtonMenu:SetClickSound("Click")

    local ButtonMenuIcon = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_MenuIcon", ButtonMenu, CT_TEXTURE)
    ButtonMenuIcon:SetAnchorFill()
    ButtonMenuIcon:SetTexture("CombatCoordination/icons/settings.dds")
    ButtonMenuIcon:SetColor(unpack(self.ESO_MUTED))

    ButtonMenu:SetHandler("OnMouseEnter", function(Control)
        ButtonMenuIcon:SetColor(unpack(self.ESO_HIGHLIGHT))
        InitializeTooltip(InformationTooltip, Control, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, "Open menu")
    end)
    ButtonMenu:SetHandler("OnMouseExit", function(Control)
        ButtonMenuIcon:SetColor(unpack(self.ESO_MUTED))
        ClearTooltip(InformationTooltip)
    end)
    ButtonMenu:SetHandler("OnMouseUp", function()
        if CC.Menu.PanelName and LibAddonMenu2 then
            if not CC.Menu.PanelName:IsHidden() then
                SCENE_MANAGER:ShowBaseScene()
            else
                LibAddonMenu2:OpenToPanel(CC.Menu.PanelName)
            end
        end
    end)
    self.ButtonMenu = ButtonMenu

    -- CLOSE BUTTON (X THINGITHING)
    local ButtonClose = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_Close", self.Parent, CT_BUTTON)
    ButtonClose:SetDimensions(20, 20)
    ButtonClose:SetState(BSTATE_NORMAL)
    ButtonClose:SetClickSound("Click")

    local ButtonCloseIcon = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_CloseIcon", ButtonClose, CT_TEXTURE)
    ButtonCloseIcon:SetAnchorFill()
    ButtonCloseIcon:SetTexture("CombatCoordination/icons/close.dds")
    ButtonCloseIcon:SetColor(unpack(self.ESO_MUTED))

    ButtonClose:SetHandler("OnMouseEnter", function(Control)
        ButtonCloseIcon:SetColor(unpack(self.ESO_HIGHLIGHT))
        InitializeTooltip(InformationTooltip, Control, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, "Close panel")
    end)
    ButtonClose:SetHandler("OnMouseExit", function(Control)
        ButtonCloseIcon:SetColor(unpack(self.ESO_MUTED))
        ClearTooltip(InformationTooltip)
    end)
    ButtonClose:SetHandler("OnMouseUp", function()
        self:Hide()
        SCENE_MANAGER:SetInUIMode(false)
    end)
    self.ButtonClose = ButtonClose

    -- MINIMIZE BUTTON (MINUS THINGITHING)
    local ButtonMinimize = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_Minimize", self.Parent, CT_BUTTON)
    ButtonMinimize:SetDimensions(20, 20)
    ButtonMinimize:SetState(BSTATE_NORMAL)
    ButtonMinimize:SetClickSound("Click")

    local ButtonMinimizeIcon = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_MinimizeIcon", ButtonMinimize, CT_TEXTURE)
    ButtonMinimizeIcon:SetAnchorFill()
    ButtonMinimizeIcon:SetTexture("CombatCoordination/icons/minus.dds")
    ButtonMinimizeIcon:SetColor(unpack(self.ESO_MUTED))

    ButtonMinimize:SetHandler("OnMouseEnter", function(Control)
        ButtonMinimizeIcon:SetColor(unpack(self.ESO_HIGHLIGHT))
        InitializeTooltip(InformationTooltip, Control, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, self.SV.isMinimized and "Maximize panel" or "Minimize panel")
    end)
    ButtonMinimize:SetHandler("OnMouseExit", function(Control)
        ButtonMinimizeIcon:SetColor(unpack(self.ESO_MUTED))
        ClearTooltip(InformationTooltip)
    end)
    ButtonMinimize:SetHandler("OnMouseUp", function()
        self:ToggleMinimize()
    end)
    self.ButtonMinimize = ButtonMinimize

    -- FOOTNOTE
    self.LabelAuthor = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_LabelAuthor", self.Parent, CT_LABEL)
    self.LabelAuthor:SetFont(self.Font.Small)
    self.LabelAuthor:SetColor(unpack(self.ESO_MUTED))
    self.LabelAuthor:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LabelAuthor:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.LabelAuthor:SetText(string.format("CC %s-%04d - @Duesentrieb [PC/EU]", CC.VERSION, CC.ADDONVERSION))

    -- BUILD CONTS
    self:BuildAddonUsersContainer()
    self:BuildArkasisAssistantContainer()
    self:BuildDrawShapeContainer()
    self:BuildLaunchPadContainer()
    self:BuildPointerContainer()
    self:BuildRaidleadToolsContainer()
    self:BuildSlayerAssistantContainer()
    self:BuildSpaulderOfRuinContainer()

    -- THX ExoY FOR TEACHING ME THIS
    self.Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
end

----------------------------------------------------------------------------------------------------
-- CREATE BUTTON
----------------------------------------------------------------------------------------------------
function Module:CreateButton(name, Parent, text, callback)
    local Button = WINDOW_MANAGER:CreateControl(name, Parent, CT_BUTTON)
    local Background = WINDOW_MANAGER:CreateControl(name .. "_Background", Button, CT_BACKDROP)

    local function SetEdge(thickness)
        Background:SetEdgeTexture("", 1, 1, thickness or 1)
    end

    Button:SetFont(self.Font.Button)
    Button:SetText(text)
    Button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    Button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    Button:SetMouseEnabled(true)
    Button:SetClickSound("Click")
    Button:SetHandler("OnClicked", callback)

    Button.SetCustomColors = function(Control, ColorNormal, ColorHighlight)
        if ColorNormal then
            Control.ColorNormal = CC.GetNormalColor(ColorNormal)
            Control.ColorHighlight = ColorHighlight or CC.GetHighlightColor(ColorNormal)
        else
            Control.ColorNormal = self.ESO_NORMAL
            Control.ColorHighlight = self.ESO_HIGHLIGHT
        end

        Control:SetNormalFontColor(unpack(Control.ColorNormal))
        Control:SetMouseOverFontColor(unpack(Control.ColorHighlight))
        Control:SetPressedFontColor(unpack(Control.ColorHighlight))
    end

    -- INITIALIZE DEFAULT
    Button:SetCustomColors(nil, nil)

    Background:SetAnchorFill()
    Background:SetPixelRoundingEnabled(true)
    Background:SetCenterColor(0, 0, 0, 0.5)
    Background:SetEdgeColor(unpack(self.ESO_MUTED))
    Background:SetEdgeTexture("", 1, 1, 1)
    Background:SetDrawTier(DT_LOW)

    Button:SetHandler("OnMouseEnter", function() SetEdge(2) Background:SetEdgeColor(unpack(self.ESO_NORMAL)) end)
    Button:SetHandler("OnMouseDown",  function() SetEdge(2) Background:SetEdgeColor(unpack(self.ESO_HIGHLIGHT)) end)
    Button:SetHandler("OnMouseUp",    function() SetEdge(2) Background:SetEdgeColor(unpack(self.ESO_NORMAL)) end)
    Button:SetHandler("OnMouseExit",  function() SetEdge(1) Background:SetEdgeColor(unpack(self.ESO_MUTED)) end)

    table.insert(self.RegisteredButtons, Button)
    return Button
end

----------------------------------------------------------------------------------------------------
-- CREATE CONTAINER
----------------------------------------------------------------------------------------------------
function Module:CreateContainer(name, SVKey)
    local Container = WINDOW_MANAGER:CreateControl(name, self.Parent, CT_BACKDROP)
    Container:SetPixelRoundingEnabled(true)
    Container:SetCenterColor(0, 0, 0, 0.5)
    Container:SetEdgeColor(unpack(self.OG_MUTED))
    Container:SetEdgeTexture("", 1, 1, 1)

    -- HEADER BUTTON
    local Header = WINDOW_MANAGER:CreateControl(name .. "_Header", Container, CT_BUTTON)
    Header:SetAnchor(TOPLEFT, Container, TOPLEFT, 0, 0)
    Header:SetAnchor(TOPRIGHT, Container, TOPRIGHT, 0, 0)
    Header:SetHeight(self.Layout.heightHeader)
    Header:SetMouseEnabled(true)
    Header:SetClickSound("Click")

    Header:SetHandler("OnClicked", function()
        self.SV[SVKey] = not self.SV[SVKey]
        self:UpdateDimensions()
    end)

    -- ARROW THINGITHING
    local Icon = WINDOW_MANAGER:CreateControl(name .. "_Icon", Header, CT_TEXTURE)
    Icon:SetDimensions(10, 10)
    Icon:SetTexture(self.SV[SVKey] and "CombatCoordination/icons/arrow_down.dds" or "CombatCoordination/icons/arrow_right.dds")
    Icon:SetColor(unpack(self.ESO_MUTED))
    Icon:SetAnchor(LEFT, Header, LEFT, self.Layout.padding, 0)
    Header.StateIcon = Icon

    -- HOVER
    Header:SetHandler("OnMouseEnter", function()
        Container:SetEdgeTexture("", 1, 1, 2)
        Container:SetEdgeColor(unpack(self.OG_NORMAL))
        Icon:SetColor(unpack(self.ESO_HIGHLIGHT))
    end)
    Header:SetHandler("OnMouseDown",  function()
        Container:SetEdgeTexture("", 1, 1, 2)
        Container:SetEdgeColor(unpack(self.OG_HIGHLIGHT))
        Icon:SetColor(unpack(self.ESO_HIGHLIGHT))
    end)
    Header:SetHandler("OnMouseUp",    function()
        Container:SetEdgeTexture("", 1, 1, 2)
        Container:SetEdgeColor(unpack(self.OG_NORMAL))
        Icon:SetColor(unpack(self.ESO_HIGHLIGHT))
    end)
    Header:SetHandler("OnMouseExit",  function()
        Container:SetEdgeTexture("", 1, 1, 1)
        Container:SetEdgeColor(unpack(self.OG_MUTED))
        Icon:SetColor(unpack(self.ESO_MUTED))
    end)

    -- HEADER TITLE
    local Title = WINDOW_MANAGER:CreateControl(name .. "_Title", Header, CT_LABEL)
    Title:SetFont(self.Font.SubTitle)
    Title:SetColor(unpack(self.OG_BRIGHT))
    Title:SetAnchor(LEFT, Icon, RIGHT, 5, 0)
    Title:SetAnchor(RIGHT, Header, RIGHT, -self.Layout.padding, 0)
    Title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    Title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- INNER STUFF
    local Content = WINDOW_MANAGER:CreateControl(name .. "_Content", Container, CT_CONTROL)
    Content:SetAnchor(TOPLEFT, Header, BOTTOMLEFT, 0, 0)
    Content:SetAnchor(TOPRIGHT, Header, BOTTOMRIGHT, 0, 0)

    return {
        Control = Container,
        Header = Header,
        Icon = Icon,
        Title = Title,
        Content = Content,
        SVKey = SVKey
    }
end

----------------------------------------------------------------------------------------------------
-- GET OR CREATE LABEL
----------------------------------------------------------------------------------------------------
function Module:GetOrCreateLabel(Pool, prefix, index, Parent, alignment)
    if not Pool[index] then
        local Label = WINDOW_MANAGER:CreateControl(self.Parent:GetName() .. "_" .. prefix .. "_" .. index, Parent, CT_LABEL)
        Label:SetFont(self.Font.Normal)
        Label:SetColor(unpack(self.ESO_NORMAL))
        Label:SetHorizontalAlignment(alignment or TEXT_ALIGN_CENTER)
        Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        Pool[index] = Label
    end
    Pool[index]:SetParent(Parent)
    Pool[index]:SetHidden(false)
    return Pool[index]
end

function Module:HideUnusedLabels(Pool, activeCount)
    for index = activeCount + 1, #Pool do
        Pool[index]:SetHidden(true)
    end
end

----------------------------------------------------------------------------------------------------
-- ANCHOR
----------------------------------------------------------------------------------------------------
function Module:ApplyAnchor()
    if not self.Parent then return end
    self.Parent:ClearAnchors()

    local anchorMode = self.SV.anchorMode or 1
    local offsetX = self.SV.offsetX or 0
    local offsetY = self.SV.offsetY or 0

    if anchorMode == 2 then
        self.Parent:SetAnchor(LEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
    elseif anchorMode == 3 then
        self.Parent:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
    else
        self.Parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
    end
end

----------------------------------------------------------------------------------------------------
-- ADDON USERS AND PING
----------------------------------------------------------------------------------------------------
function Module:BuildAddonUsersContainer()
    self.ContainerAddonUsers = self:CreateContainer("CC_DisplayPanel_ContainerAddonUsers", "isOpenAddonUsers")

    -- INFO LABEL
    self.AddonUsersInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_AddonUsersInfoLabel", self.ContainerAddonUsers.Content, CT_LABEL)
    self.AddonUsersInfoLabel:SetFont(self.Font.Small)
    self.AddonUsersInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.AddonUsersInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.AddonUsersInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.AddonUsersInfoLabel:SetText("Note: Assignments from others are only shown if they are in the same zone as you.")

    self.ButtonPingRequest = self:CreateButton("CC_DisplayPanel_ButtonPingRequest", self.ContainerAddonUsers.Content, "REFRESH PINGS", function()
        CC.Broadcast:SendSyncRequest(true, true)
    end)
end

----------------------------------------------------------------------------------------------------
-- ARKASIS ASSISTANT
----------------------------------------------------------------------------------------------------
function Module:BuildArkasisAssistantContainer()
    self.ContainerArkasisAssistant = self:CreateContainer("CC_DisplayPanel_ContainerArkasisAssistant", "isOpenArkasisAssistant")
    local Content = self.ContainerArkasisAssistant.Content

    self.ArkasisAssistantPositionLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_ArkasisAssistantPositionLabel", Content, CT_LABEL)
    self.ArkasisAssistantPositionLabel:SetFont(self.Font.Normal)
    self.ArkasisAssistantPositionLabel:SetColor(unpack(self.ESO_NORMAL))
    self.ArkasisAssistantPositionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.ArkasisAssistantPositionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ArkasisAssistantButtonAssign = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonAssign", Content, "REQ ASSIGN", function()
        CC.ArkasisAssistant:SendAssignmentRequest()
    end)

    self.ArkasisAssistantButtonStatus = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonStatus", Content, "REQ STATUS", function()
        CC.Broadcast:SendSyncRequest(true, true)
    end)

    self.ArkasisAssistantButtonSet1 = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonSet1", Content, "STACK 1", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_1)
    end)

    self.ArkasisAssistantButtonSet2 = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonSet2", Content, "STACK 2", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_2)
    end)

    self.ArkasisAssistantButtonSet3 = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonSet3", Content, "STACK 3", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_3)
    end)

    local function ChangeArkasisSeconds(amount)
        local currentSec = (CC.ArkasisAssistant.SV.durationMs / 1000) or 5
        local newSec = math.max(1, math.min(15, currentSec + amount))
        CC.ArkasisAssistant.SV.durationMs = newSec * 1000
        self:UpdateData()
    end

    self.ArkasisAssistantButtonToggle = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonToggle", Content, "START ARKASIS", function()
        if CC.DisplayNotification.arkasisEndTime > GetGameTimeSeconds() then
            CC.ArkasisAssistant:ArkasisTrigger(true, 0)
        else
            CC.ArkasisAssistant:ArkasisTrigger(true)
        end
    end)

    self.ArkasisAssistantButtonMinus5 = self:CreateButton("CC_DisplayPanel_ArkasisAssistantMinus5", Content, "<<", function() ChangeArkasisSeconds(-5) end)
    self.ArkasisAssistantButtonMinus1 = self:CreateButton("CC_DisplayPanel_ArkasisAssistantMinus1", Content, "<", function() ChangeArkasisSeconds(-1) end)
    self.ArkasisAssistantButtonPlus1  = self:CreateButton("CC_DisplayPanel_ArkasisAssistantPlus1", Content, ">", function() ChangeArkasisSeconds(1) end)
    self.ArkasisAssistantButtonPlus5  = self:CreateButton("CC_DisplayPanel_ArkasisAssistantPlus5", Content, ">>", function() ChangeArkasisSeconds(5) end)
end

----------------------------------------------------------------------------------------------------
-- DRAW SHAPE
----------------------------------------------------------------------------------------------------
function Module:BuildDrawShapeContainer()
    self.DrawShapeContainer = self:CreateContainer("CC_DisplayPanel_DrawShapeContainer", "isOpenDrawShape")
    local Content = self.DrawShapeContainer.Content

    -- INFO LABEL
    self.DrawShapeInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_DrawShapeInfoLabel", Content, CT_LABEL)
    self.DrawShapeInfoLabel:SetFont(self.Font.Small)
    self.DrawShapeInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.DrawShapeInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.DrawShapeInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.DrawShapeInfoLabel:SetText("Synchronized via LibGroupBroadcast.\nNote: Parameter specifies diameter.\nDuration: 10s (auto-hides).\n[Block]: Draw - [Menu/Key]: Cancel")

    -- SHAPE TOGGLE
    local function ChangeDrawShape(action)
        local Shapes = { LUT.DRAW_SHAPE.CIRCLE, LUT.DRAW_SHAPE.RECTANGLE }
        local currentIndex = 1
        for i, shape in ipairs(Shapes) do
            if CC.DrawShape.SV.shapeType == shape then
                currentIndex = i
                break
            end
        end

        if action == "FIRST" then
            CC.DrawShape.SV.shapeType = Shapes[1]
        elseif action == "LAST" then
            CC.DrawShape.SV.shapeType = Shapes[#Shapes]
        else
            local nextIndex = currentIndex + action
            if nextIndex > #Shapes then nextIndex = 1 end
            if nextIndex < 1 then nextIndex = #Shapes end
            CC.DrawShape.SV.shapeType = Shapes[nextIndex]
        end
        self:UpdateData()
    end

    -- SHAPE TOGGLE
    self.DrawShapeButtonFirst = self:CreateButton("CC_DisplayPanel_DrawShapeButtonFirst", Content, "||<", function() ChangeDrawShape("FIRST") end)
    self.DrawShapeButtonPrev  = self:CreateButton("CC_DisplayPanel_DrawShapeButtonPrev", Content, "<", function() ChangeDrawShape(-1) end)

    self.DrawShapeLabelToggle = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_DrawShapeLabelToggle", Content, CT_LABEL)
    self.DrawShapeLabelToggle:SetFont(self.Font.Normal)
    self.DrawShapeLabelToggle:SetColor(unpack(self.ESO_NORMAL))
    self.DrawShapeLabelToggle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.DrawShapeLabelToggle:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.DrawShapeButtonNext = self:CreateButton("CC_DisplayPanel_DrawShapeButtonNext", Content, ">", function() ChangeDrawShape(1) end)
    self.DrawShapeButtonLast = self:CreateButton("CC_DisplayPanel_DrawShapeButtonLast", Content, ">||", function() ChangeDrawShape("LAST") end)

    -- CHANGE THE SVS
    local function ChangeSize(dimension, amount)
        CC.DrawShape.SV[dimension] = math.max(1, math.min(5400, CC.DrawShape.SV[dimension] + (amount * 100)))
        self:UpdateData()
    end

    -- SIZE ROW X
    self.DrawShapeButtonMinus10X = self:CreateButton("CC_DisplayPanel_DrawShapeMinus10X", Content, "<<", function() ChangeSize("width", -10) end)
    self.DrawShapeButtonMinus1X  = self:CreateButton("CC_DisplayPanel_DrawShapeMinus1X", Content, "<", function() ChangeSize("width", -1) end)

    self.DrawShapeLabelValueX = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_DrawShapeLabelValueX", Content, CT_LABEL)
    self.DrawShapeLabelValueX:SetFont(self.Font.Normal)
    self.DrawShapeLabelValueX:SetColor(unpack(self.ESO_NORMAL))
    self.DrawShapeLabelValueX:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.DrawShapeLabelValueX:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.DrawShapeButtonPlus1X  = self:CreateButton("CC_DisplayPanel_DrawShapePlus1X", Content, ">", function() ChangeSize("width", 1) end)
    self.DrawShapeButtonPlus10X = self:CreateButton("CC_DisplayPanel_DrawShapePlus10X", Content, ">>", function() ChangeSize("width", 10) end)

    -- SIZE ROW Z
    self.DrawShapeButtonMinus10Z = self:CreateButton("CC_DisplayPanel_DrawShapeMinus10Z", Content, "<<", function() ChangeSize("height", -10) end)
    self.DrawShapeButtonMinus1Z  = self:CreateButton("CC_DisplayPanel_DrawShapeMinus1Z", Content, "<", function() ChangeSize("height", -1) end)

    self.DrawShapeLabelValueZ = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_DrawShapeLabelValueZ", Content, CT_LABEL)
    self.DrawShapeLabelValueZ:SetFont(self.Font.Normal)
    self.DrawShapeLabelValueZ:SetColor(unpack(self.ESO_NORMAL))
    self.DrawShapeLabelValueZ:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.DrawShapeLabelValueZ:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.DrawShapeButtonPlus1Z  = self:CreateButton("CC_DisplayPanel_DrawShapePlus1Z", Content, ">", function() ChangeSize("height", 1) end)
    self.DrawShapeButtonPlus10Z = self:CreateButton("CC_DisplayPanel_DrawShapePlus10Z", Content, ">>", function() ChangeSize("height", 10) end)

    -- BUTTONS
    self.DrawShapeButtonCursor = self:CreateButton("CC_DisplayPanel_DrawShapeButtonCursor", Content, "AT CURSOR", function()
        SCENE_MANAGER:SetInUIMode(false)
        CC.DrawShape:StartAiming()
    end)

    self.DrawShapeButtonSelf = self:CreateButton("CC_DisplayPanel_DrawShapeButtonSelf", Content, "ON SELF", function()
        CC.DrawShape:PlaceOnSelf()
    end)
end

----------------------------------------------------------------------------------------------------
-- LAUNCH PAD
----------------------------------------------------------------------------------------------------
function Module:BuildLaunchPadContainer()
    self.ContainerLaunchPad = self:CreateContainer("CC_DisplayPanel_LaunchPadContainer", "isOpenLaunchPad")
    local Content = self.ContainerLaunchPad.Content

    -- INFO LABEL
    self.LaunchPadInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_LaunchPadInfoLabel", Content, CT_LABEL)
    self.LaunchPadInfoLabel:SetFont(self.Font.Small)
    self.LaunchPadInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.LaunchPadInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.LaunchPadInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.LaunchPadInfoLabel:SetText("Place permanent trigger pads on the ground.\nPads trigger tools when stepped on.")

    -- CATEGORIES
    local function GetLaunchPadCategories()
        local CategoriesMap = {}
        local CategoryChoices = {}
        for id, Data in pairs(CC.LaunchPad.TriggerData) do
            local category = Data.category or "Other"
            if not CategoriesMap[category] then
                CategoriesMap[category] = {}
                table.insert(CategoryChoices, category)
            end
            table.insert(CategoriesMap[category], id)
        end
        table.sort(CategoryChoices)
        for _, Ids in pairs(CategoriesMap) do
            table.sort(Ids)
        end
        return CategoryChoices, CategoriesMap
    end

    -- CATEGORY TOGGLE
    local function ChangeLaunchPadCategory(action)
        local Choices, Maps = GetLaunchPadCategories()
        local currentCategory = CC.LaunchPad.menuSelectedCategory or Choices[1]
        local currentIndex = 1

        for i, category in ipairs(Choices) do
            if category == currentCategory then
                currentIndex = i
                break
            end
        end

        if action == "FIRST" then
            currentIndex = 1
        elseif action == "LAST" then
            currentIndex = #Choices
        else
            currentIndex = currentIndex + action
            if currentIndex > #Choices then currentIndex = 1 end
            if currentIndex < 1 then currentIndex = #Choices end
        end

        local newCategory = Choices[currentIndex]
        CC.LaunchPad.menuSelectedCategory = newCategory
        CC.LaunchPad.SV.activeTrigger = Maps[newCategory][1]
        self:UpdateData()

        if CC_LaunchPad_Dropdown_Trigger then
            CC_LaunchPad_Dropdown_Trigger:UpdateValue()
        end
    end

    -- TRIGGER TOGGLE
    local function ChangeLaunchPadTrigger(action)
        local Choices, Maps = GetLaunchPadCategories()
        local currentCategory = CC.LaunchPad.menuSelectedCategory

        if not currentCategory or not Maps[currentCategory] then
            local activeData = CC.LaunchPad.TriggerData[CC.LaunchPad.SV.activeTrigger]
            currentCategory = (activeData and activeData.category) or Choices[1]
            CC.LaunchPad.menuSelectedCategory = currentCategory
        end

        local SortedIds = Maps[currentCategory]
        local currentIndex = 1

        for i, id in ipairs(SortedIds) do
            if id == CC.LaunchPad.SV.activeTrigger then
                currentIndex = i
                break
            end
        end

        if action == "FIRST" then
            currentIndex = 1
        elseif action == "LAST" then
            currentIndex = #SortedIds
        else
            currentIndex = currentIndex + action
            if currentIndex > #SortedIds then currentIndex = 1 end
            if currentIndex < 1 then currentIndex = #SortedIds end
        end

        CC.LaunchPad.SV.activeTrigger = SortedIds[currentIndex]
        self:UpdateData()

        if CC_LaunchPad_Dropdown_Trigger then
            CC_LaunchPad_Dropdown_Trigger:UpdateValue()
        end
    end

    -- CATEGORY
    self.LaunchPadCatButtonFirst = self:CreateButton("CC_DisplayPanel_LaunchPadCatButtonFirst", Content, "||<", function() ChangeLaunchPadCategory("FIRST") end)
    self.LaunchPadCatButtonPrev  = self:CreateButton("CC_DisplayPanel_LaunchPadCatButtonPrev", Content, "<", function() ChangeLaunchPadCategory(-1) end)

    self.LaunchPadCatLabelToggle = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_LaunchPadCatLabelToggle", Content, CT_LABEL)
    self.LaunchPadCatLabelToggle:SetFont(self.Font.Normal)
    self.LaunchPadCatLabelToggle:SetColor(unpack(self.ESO_NORMAL))
    self.LaunchPadCatLabelToggle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LaunchPadCatLabelToggle:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.LaunchPadCatButtonNext = self:CreateButton("CC_DisplayPanel_LaunchPadCatButtonNext", Content, ">", function() ChangeLaunchPadCategory(1) end)
    self.LaunchPadCatButtonLast = self:CreateButton("CC_DisplayPanel_LaunchPadCatButtonLast", Content, ">||", function() ChangeLaunchPadCategory("LAST") end)

    -- TRIGGER
    self.LaunchPadButtonFirst = self:CreateButton("CC_DisplayPanel_LaunchPadButtonFirst", Content, "||<", function() ChangeLaunchPadTrigger("FIRST") end)
    self.LaunchPadButtonPrev  = self:CreateButton("CC_DisplayPanel_LaunchPadButtonPrev", Content, "<", function() ChangeLaunchPadTrigger(-1) end)

    self.LaunchPadLabelToggle = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_LaunchPadLabelToggle", Content, CT_LABEL)
    self.LaunchPadLabelToggle:SetFont(self.Font.Normal)
    self.LaunchPadLabelToggle:SetColor(unpack(self.ESO_NORMAL))
    self.LaunchPadLabelToggle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.LaunchPadLabelToggle:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.LaunchPadButtonNext = self:CreateButton("CC_DisplayPanel_LaunchPadButtonNext", Content, ">", function() ChangeLaunchPadTrigger(1) end)
    self.LaunchPadButtonLast = self:CreateButton("CC_DisplayPanel_LaunchPadButtonLast", Content, ">||", function() ChangeLaunchPadTrigger("LAST") end)

    -- BUTTONS
    self.LaunchPadButtonCursor = self:CreateButton("CC_DisplayPanel_LaunchPadButtonCursor", Content, "AT CURSOR", function()
        SCENE_MANAGER:SetInUIMode(false)
        CC.LaunchPad:StartAiming(false)
    end)

    self.LaunchPadButtonSelf = self:CreateButton("CC_DisplayPanel_LaunchPadButtonSelf", Content, "ON SELF", function()
        CC.LaunchPad:PlaceOnSelf()
    end)

    self.LaunchPadButtonDeleteClosest = self:CreateButton("CC_DisplayPanel_LaunchPadButtonDeleteClosest", Content, "DELETE CLOSEST", function()
        CC.LaunchPad:DeleteClosestPad()
    end)
end

----------------------------------------------------------------------------------------------------
-- POINTER
----------------------------------------------------------------------------------------------------
function Module:BuildPointerContainer()
    self.PointerContainer = self:CreateContainer("CC_DisplayPanel_PointerContainer", "isOpenPointer")
    local Content = self.PointerContainer.Content

    -- INFO
    self.PointerInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_PointerInfoLabel", Content, CT_LABEL)
    self.PointerInfoLabel:SetFont(self.Font.Small)
    self.PointerInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.PointerInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.PointerInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.PointerInfoLabel:SetText("Synchronized via LibGroupBroadcast.\nDuration: 10s (auto-hides).\n[Block]: Draw - [Menu/Key]: Cancel")

    -- BUTTONS
    self.PointerButtonCursor = self:CreateButton("CC_DisplayPanel_PointerButtonCursor", Content, "AT CURSOR", function()
        SCENE_MANAGER:SetInUIMode(false)
        CC.Pointer:StartAiming()
    end)

    self.PointerButtonSelf = self:CreateButton("CC_DisplayPanel_PointerButtonSelf", Content, "ON SELF", function()
        CC.Pointer:PlaceOnSelf()
    end)
end

----------------------------------------------------------------------------------------------------
-- RAIDLEAD TOOLS
----------------------------------------------------------------------------------------------------
function Module:BuildRaidleadToolsContainer()
    self.ContainerRaidleadTools = self:CreateContainer("CC_DisplayPanel_ContainerRaidleadTools", "isOpenRaidleadTools")
    local Content = self.ContainerRaidleadTools.Content

    -- INFO
    self.RaidleadToolsInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_RaidleadToolsInfoLabel", Content, CT_LABEL)
    self.RaidleadToolsInfoLabel:SetFont(self.Font.Small)
    self.RaidleadToolsInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.RaidleadToolsInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.RaidleadToolsInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.RaidleadToolsInfoLabel:SetText("Synchronized via LibGroupBroadcast.")

    -----------------------------------------------------
    -- WIPE AND PTE
    -----------------------------------------------------
    self.ButtonWipePlease = self:CreateButton("CC_DisplayPanel_ButtonWipePlease", Content, "WIPE PLS", function()
        CC.RaidleadTools:RequestWipe()
    end)
    self.ButtonWipePlease:SetCustomColors(self.RD_NORMAL)

    self.ButtonExitInstance = self:CreateButton("CC_DisplayPanel_ButtonExitInstance", Content, "GROUP P-T-E", function()
        CC.RaidleadTools:RequestExitInstance()
    end)
    self.ButtonExitInstance:SetCustomColors(self.RD_NORMAL)

    -----------------------------------------------------
    -- PORT IN AND PORT LEAD
    -----------------------------------------------------
    self.ButtonPortInPlease = self:CreateButton("CC_DisplayPanel_ButtonPortInPlease", Content, "PORT IN PLS", function()
        CC.RaidleadTools:RequestPortIn()
    end)
    self.ButtonPortInPlease:SetCustomColors(self.BL_NORMAL)

    self.ButtonPortToLeader = self:CreateButton("CC_DisplayPanel_ButtonPortToLeader", Content, "PORT TO LEAD", function()
        CC.RaidleadTools:RequestPortToLeader()
    end)
    self.ButtonPortToLeader:SetCustomColors(self.BL_NORMAL)

    -----------------------------------------------------
    -- READYCHECK AND VOTE
    -----------------------------------------------------
    self.ButtonReadyCheck = self:CreateButton("CC_DisplayPanel_ButtonReadyCheck", Content, "READYCHECK", function()
        SLASH_COMMANDS["/readycheck"]()
    end)

    self.ButtonVoteStart = self:CreateButton("CC_DisplayPanel_ButtonVoteStart", Content, "START VOTE", function()
        CC.RaidleadTools:SendVoteRequest()
    end)

    -----------------------------------------------------
    -- BREAK TIMER
    -----------------------------------------------------
    local function ChangeMinutes(amount)
        CC.RaidleadTools.SV.breakMinutes = math.max(1, math.min(30, CC.RaidleadTools.SV.breakMinutes + amount))
        self:UpdateData()
    end

    self.BreakTimerButtonToggle = self:CreateButton("CC_DisplayPanel_BreakTimerButtonToggle", Content, "START BREAK", function()
        if CC.DisplayNotification.breakEndTime > GetGameTimeSeconds() then
            CC.RaidleadTools:RequestBreak(0)
        else
            CC.RaidleadTools:RequestBreak(CC.RaidleadTools.SV.breakMinutes)
        end
    end)

    self.BreakTimerButtonMinus5 = self:CreateButton("CC_DisplayPanel_BreakTimerMinus5", Content, "<<", function() ChangeMinutes(-5) end)
    self.BreakTimerButtonMinus1 = self:CreateButton("CC_DisplayPanel_BreakTimerMinus1", Content, "<", function() ChangeMinutes(-1) end)
    self.BreakTimerButtonPlus1  = self:CreateButton("CC_DisplayPanel_BreakTimerPlus1", Content, ">", function() ChangeMinutes(1) end)
    self.BreakTimerButtonPlus5  = self:CreateButton("CC_DisplayPanel_BreakTimerPlus5", Content, ">>", function() ChangeMinutes(5) end)

    -----------------------------------------------------
    -- PULL TIMER
    -----------------------------------------------------
    local function ChangeSeconds(amount)
        CC.RaidleadTools.SV.pullSeconds = math.max(1, math.min(15, CC.RaidleadTools.SV.pullSeconds + amount))
        self:UpdateData()
    end

    self.PullTimerButtonToggle = self:CreateButton("CC_DisplayPanel_PullTimerButtonToggle", Content, "START PULL", function()
        if CC.DisplayNotification.pullEndTime > GetGameTimeSeconds() then
            CC.RaidleadTools:RequestPull(0)
        else
            CC.RaidleadTools:RequestPull(CC.RaidleadTools.SV.pullSeconds)
        end
    end)

    self.PullTimerButtonMinus5 = self:CreateButton("CC_DisplayPanel_PullTimerMinus5", Content, "<<", function() ChangeSeconds(-5) end)
    self.PullTimerButtonMinus1 = self:CreateButton("CC_DisplayPanel_PullTimerMinus1", Content, "<", function() ChangeSeconds(-1) end)
    self.PullTimerButtonPlus1  = self:CreateButton("CC_DisplayPanel_PullTimerPlus1", Content, ">", function() ChangeSeconds(1) end)
    self.PullTimerButtonPlus5  = self:CreateButton("CC_DisplayPanel_PullTimerPlus5", Content, ">>", function() ChangeSeconds(5) end)
end

----------------------------------------------------------------------------------------------------
-- SLAYER ASSISTANT
----------------------------------------------------------------------------------------------------
function Module:BuildSlayerAssistantContainer()
    self.ContainerSlayerAssistant = self:CreateContainer("CC_DisplayPanel_ContainerSlayerAssistant", "isOpenSlayerAssistant")
    local Content = self.ContainerSlayerAssistant.Content

    self.SlayerAssistantPositionLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_SlayerAssistantPositionLabel", Content, CT_LABEL)
    self.SlayerAssistantPositionLabel:SetFont(self.Font.Normal)
    self.SlayerAssistantPositionLabel:SetColor(unpack(self.ESO_NORMAL))
    self.SlayerAssistantPositionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.SlayerAssistantPositionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.SlayerAssistantButtonAssign = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonAssign", Content, "REQ ASSIGN", function()
        CC.SlayerAssistant:SendAssignmentRequest()
    end)

    self.SlayerAssistantButtonStatus = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonStatus", Content, "REQ STATUS", function()
        CC.Broadcast:SendSyncRequest(true, true)
    end)

    self.SlayerAssistantButtonSetLeft = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonSetLeft", Content, "SET LEFT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_LEFT)
    end)

    self.SlayerAssistantButtonSetRight = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonSetRight", Content, "SET RIGHT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_RIGHT)
    end)

    local function ChangeSlayerSeconds(amount)
        local currentSec = (CC.SlayerAssistant.SV.durationMs / 1000) or 5
        local newSec = math.max(1, math.min(15, currentSec + amount))
        CC.SlayerAssistant.SV.durationMs = newSec * 1000
        self:UpdateData()
    end

    self.SlayerAssistantButtonToggle = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonToggle", Content, "START SLAYER", function()
        if CC.DisplayNotification.slayerEndTime > GetGameTimeSeconds() then
            CC.SlayerAssistant:SlayerTrigger(true, 0)
        else
            CC.SlayerAssistant:SlayerTrigger(true)
        end
    end)

    self.SlayerAssistantButtonMinus5 = self:CreateButton("CC_DisplayPanel_SlayerAssistantMinus5", Content, "<<", function() ChangeSlayerSeconds(-5) end)
    self.SlayerAssistantButtonMinus1 = self:CreateButton("CC_DisplayPanel_SlayerAssistantMinus1", Content, "<", function() ChangeSlayerSeconds(-1) end)
    self.SlayerAssistantButtonPlus1  = self:CreateButton("CC_DisplayPanel_SlayerAssistantPlus1", Content, ">", function() ChangeSlayerSeconds(1) end)
    self.SlayerAssistantButtonPlus5  = self:CreateButton("CC_DisplayPanel_SlayerAssistantPlus5", Content, ">>", function() ChangeSlayerSeconds(5) end)
end

----------------------------------------------------------------------------------------------------
-- SPAULDER OF RUIN
----------------------------------------------------------------------------------------------------
function Module:BuildSpaulderOfRuinContainer()
    self.ContainerSpaulderOfRuin = self:CreateContainer("CC_DisplayPanel_ContainerSpaulderOfRuin", "isOpenSpaulderOfRuin")
    local Content = self.ContainerSpaulderOfRuin.Content

    -- INFO LABEL
    self.SpaulderInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_SpaulderInfoLabel", Content, CT_LABEL)
    self.SpaulderInfoLabel:SetFont(self.Font.Small)
    self.SpaulderInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.SpaulderInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.SpaulderInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.SpaulderInfoLabel:SetText("|c00FF00Green:|r Selected [SOR] and buffed.\n" ..
                                   "|cFFFF00Yellow:|r Buffed but not selected.\n" ..
                                   "|cFF0000Red:|r Missing buff despite selected!\n" ..
                                   "Click players below to toggle [SOR].")

    self.SpaulderButtonKick = self:CreateButton("CC_DisplayPanel_SpaulderButtonKick", Content, "KICK & INVITE", function()
        CC.SpaulderOfRuin:KickAndReinvite()
    end)
    self.SpaulderButtonKick:SetCustomColors(self.GN_NORMAL)

    self.SpaulderButtonReinvite = self:CreateButton("CC_DisplayPanel_SpaulderButtonReinvite", Content, "REINVITE", function()
        CC.SpaulderOfRuin:Reinvite()
    end)
end

----------------------------------------------------------------------------------------------------
-- UPDATE DATA (LABELS, STRINGS, COUNTERS)
----------------------------------------------------------------------------------------------------
function Module:UpdateData()
    if not self.Parent or self.Parent:IsHidden() then return end

    local currentTime = GetGameTimeSeconds()
    local currentZoneId = CC.GetCleanZoneId()

    ----------------------------------------------------------------------------------------------------
    -- INJECT LOCAL PLAYER TO ENSURE VISIBILITY IN LISTS
    ----------------------------------------------------------------------------------------------------
    local playerName = GetUnitDisplayName("player")
    if playerName and playerName ~= "" then
        CC.GroupData[playerName] = CC.GroupData[playerName] or {}
        local PlayerData = CC.GroupData[playerName]

        PlayerData.displayName = playerName
        PlayerData.unitTag = "player"
        PlayerData.isOnline = true
        PlayerData.selectedRole = GetSelectedLFGRole()
        PlayerData.isAddonUser = true
        PlayerData.pingMs = GetLatency()
        PlayerData.distance = 0
        PlayerData.isRaidlead = IsUnitGroupLeader("player")

        if CC.ArkasisAssistant and CC.ArkasisAssistant.SV then
            PlayerData.ArkasisAssistant = PlayerData.ArkasisAssistant or {}
            PlayerData.ArkasisAssistant.isEquipped = CC.GetPlayerSetStatus("ARKASIS") or 0
            PlayerData.ArkasisAssistant.zoneId = currentZoneId
            PlayerData.ArkasisAssistant.sideId = CC.ArkasisAssistant.SV.AssignmentByZone[currentZoneId] or 0
        end

        if CC.SlayerAssistant and CC.SlayerAssistant.SV then
            PlayerData.SlayerAssistant = PlayerData.SlayerAssistant or {}
            PlayerData.SlayerAssistant.isEquipped = CC.GetPlayerSetStatus("SLAYER") or 0
            PlayerData.SlayerAssistant.zoneId = currentZoneId
            PlayerData.SlayerAssistant.sideId = CC.SlayerAssistant.SV.AssignmentByZone[currentZoneId] or 0
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- ADDON USERS DATA
    ----------------------------------------------------------------------------------------------------
    local countAddonUsers = 0
    self.activeAddonUserLabels = 0

    if self.SV.isOpenAddonUsers then
        ZO_ClearTable(self.AddonUserSortBuffer)

        for displayName, GroupMember in pairs(CC.GroupData) do
            if GroupMember.isAddonUser then
                    table.insert(self.AddonUserSortBuffer, {
                        displayName = displayName,
                        GroupMember = GroupMember
                    })
                end
            end

            table.sort(self.AddonUserSortBuffer, function(A, B) return A.displayName < B.displayName end)

            for _, Data in ipairs(self.AddonUserSortBuffer) do
                local GroupMember = Data.GroupMember
                countAddonUsers = countAddonUsers + 1
                self.activeAddonUserLabels = self.activeAddonUserLabels + 1
                local Label = self:GetOrCreateLabel(self.AddonUserLabels, "AddonUserLabels", self.activeAddonUserLabels, self.ContainerAddonUsers.Content, TEXT_ALIGN_LEFT)

                local roleIcon = self:GetPlayerIconByRole(GroupMember.selectedRole)
                local pingMs = GroupMember.pingMs or 0
                local isRaidlead = GroupMember.isRaidlead and " |cFFDF00RL|r" or ""
                --local isRaidlead = GroupMember.isRaidlead and string.format(" |t%s:%s:/esoui/art/compass/groupleader.dds|t", self.FONT_SIZE_MEDIUM, self.FONT_SIZE_MEDIUM) or ""

                -- ZONE CHECK
                local arkasisZoneId = GroupMember.ArkasisAssistant and GroupMember.ArkasisAssistant.zoneId or 0
                local slayerZoneId = GroupMember.SlayerAssistant and GroupMember.SlayerAssistant.zoneId or 0

                local extraInfo = ""

                if arkasisZoneId == currentZoneId or slayerZoneId == currentZoneId then
                    -- ARKASIS SAME ZONE OR ?
                    local stringArkasis = "|c7F7F7F?|r"
                    if arkasisZoneId == currentZoneId then
                        local arkasisSideId = GroupMember.ArkasisAssistant and GroupMember.ArkasisAssistant.sideId or CC.ArkasisAssistant.SIDE_NONE
                        local arkasisLetter = "?"
                        local arkasisColorHex = CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.ColorNone) or "|cBFBFBF"

                        if arkasisSideId == CC.ArkasisAssistant.SIDE_1 then
                            arkasisLetter = "1"
                            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
                        elseif arkasisSideId == CC.ArkasisAssistant.SIDE_2 then
                            arkasisLetter = "2"
                            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
                        elseif arkasisSideId == CC.ArkasisAssistant.SIDE_3 then
                            arkasisLetter = "3"
                            arkasisColorHex = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor()) or CC.GetHexColorFromArray(CC.ArkasisAssistant.SV.Color)
                        end

                        -- local isArkasisEquipped = GroupMember.ArkasisAssistant.isEquipped or 0
                        -- if isArkasisEquipped ~= 0 then
                        --     arkasisLetter = arkasisLetter .. " [" .. CC.ArkasisAssistant:GetSetNameFromStatusId(isArkasisEquipped) .. "]"
                        -- end

                        stringArkasis = string.format("%s%s|r", arkasisColorHex, arkasisLetter)
                    end

                    -- SLAYER SAME ZONE OR ?
                    local stringSlayer = "|c7F7F7F?|r"
                    if slayerZoneId == currentZoneId then
                        local slayerSideId = GroupMember.SlayerAssistant and GroupMember.SlayerAssistant.sideId or CC.SlayerAssistant.SIDE_NONE
                        local slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorNone) or "|cBFBFBF"
                        local slayerLetter = "?"

                        if slayerSideId == CC.SlayerAssistant.SIDE_LEFT then
                            slayerLetter = "L"
                            slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorLeft)
                        elseif slayerSideId == CC.SlayerAssistant.SIDE_RIGHT then
                            slayerLetter = "R"
                            slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorRight)
                        end

                        -- local isSlayerEquipped = GroupMember.SlayerAssistant.isEquipped or 0
                        -- if isSlayerEquipped ~= 0 then
                        --     slayerLetter = slayerLetter .. " [" .. CC.SlayerAssistant:GetSetNameFromStatusId(isSlayerEquipped) .. "]"
                        -- end

                        stringSlayer = string.format("%s%s|r", slayerColorHex, slayerLetter)
                    end

                    extraInfo = string.format(" - %s / %s", stringSlayer, stringArkasis)
                end

            local shortName = self:GetShortName(Data.displayName, self.maxLengthDisplayName)
            Label:SetText(string.format("%s |cFFFFFF%s|r%s (%d ms)%s", roleIcon, shortName, isRaidlead, pingMs, extraInfo))
        end
    else
        for _, GroupMember in pairs(CC.GroupData) do
            if GroupMember.isAddonUser then
                countAddonUsers = countAddonUsers + 1
            end
        end
    end

    if self.SV.isOpenAddonUsers and countAddonUsers == 0 then
        self.activeAddonUserLabels = 1
        local Label = self:GetOrCreateLabel(self.AddonUserLabels, "AddonUserLabels", self.activeAddonUserLabels, self.ContainerAddonUsers.Content, TEXT_ALIGN_LEFT)
        Label:SetText("No addon users found.")
    end

    self:HideUnusedLabels(self.AddonUserLabels, self.activeAddonUserLabels)

    local AddonUsersIcon = { iconPath = CC.NAME .. "/icons/logo_cc.dds" }
    local expectedSize = math.max(1, GetGroupSize())
    self.ContainerAddonUsers.Title:SetText(self:GetTitleWithIcon(AddonUsersIcon, string.format("ADDON USERS: |cFFFFFF%d/%d|r", countAddonUsers, expectedSize)))

    ----------------------------------------------------------------------------------------------------
    -- ARKASIS ASSISTANT
    ----------------------------------------------------------------------------------------------------
    self.activeArkasisUserLabels = 0
    local arkasisZoneName = CC.ArkasisAssistant:GetZoneNameFromZoneId(currentZoneId)
    local arkasisSideId = CC.ArkasisAssistant:GetSideIdFromZoneId(currentZoneId)
    local arkasisSideName = CC.ArkasisAssistant:GetSideNameFromSideId(arkasisSideId)
    self.ArkasisAssistantPositionLabel:SetText(string.format("Current zone: |cFFFFFF[%s]|r\nYour saved stack: %s", arkasisZoneName, arkasisSideName))

    local ColorNormal = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or CC.ArkasisAssistant.SV.Color or {1, 0.875, 0, 1}
    self.ArkasisAssistantButtonSet1:SetCustomColors(ColorNormal)
    self.ArkasisAssistantButtonSet2:SetCustomColors(ColorNormal)
    self.ArkasisAssistantButtonSet3:SetCustomColors(ColorNormal)

    if self.SV.isOpenArkasisAssistant then
        ZO_ClearTable(self.ArkasisSortBuffer)

        for displayName, GroupMember in pairs(CC.GroupData) do
            if GroupMember.ArkasisAssistant and GroupMember.ArkasisAssistant.sideId == arkasisSideId and arkasisSideId ~= 0 and GroupMember.ArkasisAssistant.zoneId == currentZoneId then
                table.insert(self.ArkasisSortBuffer, {
                    displayName = displayName,
                    GroupMember = GroupMember
                })
            end
        end

        table.sort(self.ArkasisSortBuffer, function(A, B) return A.displayName < B.displayName end)

        for _, Data in ipairs(self.ArkasisSortBuffer) do
            self.activeArkasisUserLabels = self.activeArkasisUserLabels + 1
            local Label = self:GetOrCreateLabel(self.ArkasisUserLabels, "ArkasisUserLabels", self.activeArkasisUserLabels, self.ContainerArkasisAssistant.Content, TEXT_ALIGN_LEFT)

            local GroupMember = Data.GroupMember
            local roleIcon = self:GetPlayerIconByRole(GroupMember.selectedRole)
            local isEquipped = GroupMember.ArkasisAssistant.isEquipped or 0
            local shortName = self:GetShortName(Data.displayName, self.maxLengthDisplayName)
            local sideName = CC.ArkasisAssistant:GetSideNameFromSideId(GroupMember.ArkasisAssistant.sideId)

            local stringSet = ""
            if isEquipped ~= 0 then
                local setName = CC.ArkasisAssistant:GetSetNameFromStatusId(isEquipped)
                stringSet = string.format(" - |cFFFFFF[%s]|r", setName)
            end

            Label:SetText(string.format("%s %s - %s%s", roleIcon, shortName, sideName, stringSet))
        end

        -- IS EMPTY
        if self.activeArkasisUserLabels == 0 then
            self.activeArkasisUserLabels = 1
            local Label = self:GetOrCreateLabel(self.ArkasisUserLabels, "ArkasisUserLabels", self.activeArkasisUserLabels, self.ContainerArkasisAssistant.Content, TEXT_ALIGN_LEFT)
            if arkasisSideId == 0 then
                Label:SetText("You are unassigned.")
            else
                Label:SetText("No partners in your stack.")
            end
        end
    end

    self:HideUnusedLabels(self.ArkasisUserLabels, self.activeArkasisUserLabels)
    self.ContainerArkasisAssistant.Title:SetText(self:GetTitleWithIcon(CC.ArkasisAssistant, "ARKASIS ASSISTANT"))

    if CC.DisplayNotification.arkasisEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.arkasisEndTime - currentTime)
        self.ArkasisAssistantButtonToggle:SetText(string.format("ARKASIS %d Sec", remaining))
        self.ArkasisAssistantButtonToggle:SetCustomColors(self.RD_NORMAL)
    else
        local configuredSecs = (CC.ArkasisAssistant.SV.durationMs / 1000) or 5
        self.ArkasisAssistantButtonToggle:SetText(string.format("ARKASIS %d Sec", configuredSecs))
        self.ArkasisAssistantButtonToggle:SetCustomColors(self.YL_NORMAL)
    end

    ----------------------------------------------------------------------------------------------------
    -- DRAW SHAPE
    ----------------------------------------------------------------------------------------------------
    self.DrawShapeContainer.Title:SetText(self:GetTitleWithIcon(CC.DrawShape, "DRAW SHAPE"))

    local isRectangle = (CC.DrawShape.SV.shapeType == LUT.DRAW_SHAPE.RECTANGLE)
    self.DrawShapeLabelToggle:SetText(isRectangle and "Shape: Rectangle" or "Shape: Circle")

    local labelX = isRectangle and "Width" or "Diameter"
    self.DrawShapeLabelValueX:SetText(string.format("%s: %dm", labelX, CC.DrawShape.SV.width / 100))
    self.DrawShapeLabelValueZ:SetText(string.format("Height: %dm", CC.DrawShape.SV.height / 100))

    ----------------------------------------------------------------------------------------------------
    -- LAUNCH PAD
    ----------------------------------------------------------------------------------------------------
    self.ContainerLaunchPad.Title:SetText(self:GetTitleWithIcon(CC.LaunchPad, "LAUNCH PAD"))

    local activeTrigger = CC.LaunchPad.SV.activeTrigger
    local TriggerData = CC.LaunchPad.TriggerData[activeTrigger]
    local triggerName = TriggerData and TriggerData.name or "UNKNOWN"

    local triggerColor = TriggerData and TriggerData.Color or self.ESO_NORMAL
    local r, g, b = triggerColor[1], triggerColor[2], triggerColor[3]

    local currentCategory = CC.LaunchPad.menuSelectedCategory
    if not currentCategory or currentCategory == "" then
        currentCategory = TriggerData and TriggerData.category or "Other"
        CC.LaunchPad.menuSelectedCategory = currentCategory
    end

    self.LaunchPadCatLabelToggle:SetText(currentCategory)
    self.LaunchPadCatLabelToggle:SetColor(r, g, b, 1)

    self.LaunchPadLabelToggle:SetText(triggerName)
    self.LaunchPadLabelToggle:SetColor(r, g, b, 1)

    ----------------------------------------------------------------------------------------------------
    -- POINTER
    ----------------------------------------------------------------------------------------------------
    self.PointerContainer.Title:SetText(self:GetTitleWithIcon(CC.Pointer, "3D POINTER"))

    ----------------------------------------------------------------------------------------------------
    -- RAIDLEAD TOOLS
    ----------------------------------------------------------------------------------------------------
    self.ContainerRaidleadTools.Title:SetText(self:GetTitleWithIcon(CC.RaidleadTools, "RL TOOLS & TIMERS"))

    -- UPDATE BUTTON BREAK TIMER
    if CC.DisplayNotification.breakEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.breakEndTime - currentTime)
        local breakMins = math.floor(remaining / 60)
        local breakSecs = remaining % 60
        local timeStr = (breakMins > 0) and string.format("%d:%02d", breakMins, breakSecs) or string.format("%d Sec", breakSecs)
        self.BreakTimerButtonToggle:SetText(string.format("BREAK %s", timeStr))
        self.BreakTimerButtonToggle:SetCustomColors(self.RD_NORMAL)
    else
        local configuredMins = CC.RaidleadTools.SV.breakMinutes
        self.BreakTimerButtonToggle:SetText(string.format("BREAK %d Min", configuredMins))
        self.BreakTimerButtonToggle:SetCustomColors(self.BL_NORMAL)
    end

    -- UPDATE BUTTON PULL TIMER
    if CC.DisplayNotification.pullEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.pullEndTime - currentTime)
        self.PullTimerButtonToggle:SetText(string.format("PULL %d Sec", remaining))
        self.PullTimerButtonToggle:SetCustomColors(self.RD_NORMAL)
    else
        local configuredSecs = CC.RaidleadTools.SV.pullSeconds
        self.PullTimerButtonToggle:SetText(string.format("PULL %d Sec", configuredSecs))
        self.PullTimerButtonToggle:SetCustomColors(self.GN_NORMAL)
    end

    -- UPDATE BUTTON VOTE START
    local VoteData = CC.RaidleadTools.VoteData
    if VoteData and VoteData.endTime > currentTime then
        local stringYES = string.format("|c00FF00%d|r", VoteData.yes)
        local stringNO = string.format("|cFF0000%d|r", VoteData.no)
        local stringIDC = string.format("|cFFDF00%d|r", VoteData.idc)
        self.ButtonVoteStart:SetText(string.format("STOP %s - %s - %s", stringYES, stringNO, stringIDC))
        self.ButtonVoteStart:SetCustomColors(self.RD_NORMAL)
    else
        self.ButtonVoteStart:SetText("START VOTE")
        self.ButtonVoteStart:SetCustomColors(nil, nil)
    end

    ----------------------------------------------------------------------------------------------------
    -- SLAYER ASSISTANT
    ----------------------------------------------------------------------------------------------------
    local countSlayerSetUsers = 0
    self.activeSlayerSetUserLabels = 0

    local playerZoneName = CC.SlayerAssistant:GetZoneNameFromZoneId(currentZoneId)
    local playerSideId = CC.SlayerAssistant:GetSideIdFromZoneId(currentZoneId)
    local playerSideName = CC.SlayerAssistant:GetSideNameFromSideId(playerSideId)
    self.SlayerAssistantPositionLabel:SetText(string.format("Current zone: |cFFFFFF[%s]|r\nYour saved position: %s", playerZoneName, playerSideName))

    local ColorLeft = CC.SlayerAssistant.SV.ColorLeft or {1, 0, 0, 1}
    local ColorRight = CC.SlayerAssistant.SV.ColorRight or {0, 0.5, 1, 1}
    self.SlayerAssistantButtonSetLeft:SetCustomColors(ColorLeft)
    self.SlayerAssistantButtonSetRight:SetCustomColors(ColorRight)

    for displayName, GroupMember in pairs(CC.GroupData) do
        if GroupMember.SlayerAssistant and GroupMember.SlayerAssistant.isEquipped ~= CC.SlayerAssistant.SET_STATUS_NONE and GroupMember.SlayerAssistant.zoneId == currentZoneId then
            countSlayerSetUsers = countSlayerSetUsers + 1
        end
    end

    if self.SV.isOpenSlayerAssistant then
        ZO_ClearTable(self.SlayerSortBuffer)

        for displayName, GroupMember in pairs(CC.GroupData) do
            if GroupMember.SlayerAssistant and GroupMember.SlayerAssistant.isEquipped ~= CC.SlayerAssistant.SET_STATUS_NONE and GroupMember.SlayerAssistant.zoneId == currentZoneId then
                table.insert(self.SlayerSortBuffer, {
                    displayName = displayName,
                    GroupMember = GroupMember
                })
            end
        end

        table.sort(self.SlayerSortBuffer, function(A, B) return A.displayName < B.displayName end)

        for _, Data in ipairs(self.SlayerSortBuffer) do
            self.activeSlayerSetUserLabels = self.activeSlayerSetUserLabels + 1
            local Label = self:GetOrCreateLabel(self.SlayerSetUserLabels, "SlayerSetUserLabels", self.activeSlayerSetUserLabels, self.ContainerSlayerAssistant.Content, TEXT_ALIGN_LEFT)

            local GroupMember = Data.GroupMember
            local roleIcon = self:GetPlayerIconByRole(GroupMember.selectedRole)
            local isEquipped = GroupMember.SlayerAssistant.isEquipped or CC.SlayerAssistant.SET_STATUS_NONE
            local shortName = self:GetShortName(Data.displayName, self.maxLengthDisplayName)
            local sideName = CC.SlayerAssistant:GetSideNameFromSideId(GroupMember.SlayerAssistant.sideId)

            local stringSet = ""
            if isEquipped ~= CC.SlayerAssistant.SET_STATUS_NONE then
                local setName = CC.SlayerAssistant:GetSetNameFromStatusId(isEquipped)
                stringSet = string.format(" - |cFFFFFF[%s]|r", setName)
            end

            Label:SetText(string.format("%s %s - %s%s", roleIcon, shortName, sideName, stringSet))
        end
    end

    self:HideUnusedLabels(self.SlayerSetUserLabels, self.activeSlayerSetUserLabels)
    self.ContainerSlayerAssistant.Title:SetText(self:GetTitleWithIcon(CC.SlayerAssistant, "SLAYER ASSISTANT"))

    -- BUTTON TEXT
    if CC.DisplayNotification.slayerEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.slayerEndTime - currentTime)
        self.SlayerAssistantButtonToggle:SetText(string.format("SLAYER %d Sec", remaining))
        self.SlayerAssistantButtonToggle:SetCustomColors(self.RD_NORMAL)
    else
        local configuredSecs = (CC.SlayerAssistant.SV.durationMs / 1000) or 5
        self.SlayerAssistantButtonToggle:SetText(string.format("SLAYER %d Sec", configuredSecs))
        self.SlayerAssistantButtonToggle:SetCustomColors(self.GN_NORMAL)
    end

    ----------------------------------------------------------------------------------------------------
    -- SPAULDER OF RUIN
    ----------------------------------------------------------------------------------------------------
    self.activeSpaulderUserLabels = 0

    if self.SV.isOpenSpaulderOfRuin then
        ZO_ClearTable(self.SpaulderSortBuffer)

        for displayName, GroupMember in pairs(CC.GroupData) do
            if GroupMember.isOnline then
                table.insert(self.SpaulderSortBuffer, {
                    displayName = displayName,
                    unitTag = GroupMember.unitTag,
                    selectedRole = GroupMember.selectedRole,
                    distance = GroupMember.distance or 9999,
                })
            end
        end

        table.sort(self.SpaulderSortBuffer, function(A, B) return A.displayName < B.displayName end)

        for _, Player in ipairs(self.SpaulderSortBuffer) do
            self.activeSpaulderUserLabels = self.activeSpaulderUserLabels + 1
            local Label = self:GetOrCreateLabel(self.SpaulderUserLabels, "SpaulderUserLabels", self.activeSpaulderUserLabels, self.ContainerSpaulderOfRuin.Content, TEXT_ALIGN_LEFT)

            -- CLICK
            if not Label.isInteractive then
                Label:SetMouseEnabled(true)
                Label:SetHandler("OnMouseEnter", function(Control)
                    Control:SetColor(unpack(self.ESO_HIGHLIGHT))
                    InitializeTooltip(InformationTooltip, Control, BOTTOM, 0, 0)
                    SetTooltipText(InformationTooltip, "Click to toggle [SOR].")
                end)
                Label:SetHandler("OnMouseExit", function(Control)
                    Control:SetColor(unpack(self.ESO_NORMAL))
                    ClearTooltip(InformationTooltip)
                end)
                Label:SetHandler("OnMouseUp", function(Control, button, upInside)
                    if upInside and Control.targetName then
                        local SV = CC.SpaulderOfRuin.SV

                        if SV.SavedPlayers[Control.targetName] then
                            SV.SavedPlayers[Control.targetName] = nil
                        else
                            SV.SavedPlayers[Control.targetName] = true
                        end
                        CC.DisplayPanel:UpdateData()
                    end
                end)
                Label.isInteractive = true
            end

            Label.targetName = Player.displayName

            local hasBuff = CC.SpaulderOfRuin:HasAuraOfPride(Player.unitTag)
            local isSaved = CC.SpaulderOfRuin.SV.SavedPlayers[Player.displayName] and true or false

            local shortName = self:GetShortName(Player.displayName, self.maxLengthDisplayName)
            local roleIcon = self:GetPlayerIconByRole(Player.selectedRole)
            local savedStr = isSaved and " |cFF9F3F[SOR]|r" or ""
            local distanceStr = Player.distance == 9999 and "N/A" or string.format("%.1fm", Player.distance)

            if hasBuff and isSaved then
                shortName = CC.GetHexColorFromArray(self.GN_NORMAL) .. shortName .. "|r"
            elseif hasBuff and not isSaved then
                shortName = CC.GetHexColorFromArray(self.YL_NORMAL) .. shortName .. "|r"
            elseif not hasBuff and isSaved then
                shortName = CC.GetHexColorFromArray(self.RD_NORMAL) .. shortName .. "|r"
            end

            Label:SetText(string.format("%s %s%s - %s", roleIcon, shortName, savedStr, distanceStr))
        end

        if self.activeSpaulderUserLabels == 0 then
            self.activeSpaulderUserLabels = 1
            local Label = self:GetOrCreateLabel(self.SpaulderUserLabels, "SpaulderUserLabels", 1, self.ContainerSpaulderOfRuin.Content, TEXT_ALIGN_LEFT)
            Label.targetName = nil
            Label:SetMouseEnabled(false)
            Label:SetColor(unpack(self.ESO_MUTED))
            Label:SetText("No players found.")
        end
    end

    self:HideUnusedLabels(self.SpaulderUserLabels, self.activeSpaulderUserLabels)
    self.ContainerSpaulderOfRuin.Title:SetText(self:GetTitleWithIcon(CC.SpaulderOfRuin, "SPAULDER OF RUIN"))

    -- CALC DIMENSIONS
    self:UpdateDimensions()
end

----------------------------------------------------------------------------------------------------
-- LAYOUT / DIMENSIONS
----------------------------------------------------------------------------------------------------
function Module:UpdateDimensions()
    if not self.Parent or self.Parent:IsHidden() then return end

    local colorA = self.SV.colorA
    self.Background:SetCenterColor(0, 0, 0, colorA)

    local Layout = self.Layout
    local isRaidlead = CC.IsRaidlead()
    local contentWidth = self.SV.panelWidth - (Layout.margin * 2)

    local minimizedHeight = 30
    local headerCenterY = minimizedHeight / 2

    self.ButtonMenu:ClearAnchors()
    self.ButtonMenu:SetAnchor(LEFT, self.Parent, TOPLEFT, Layout.padding, headerCenterY)

    self.ButtonClose:ClearAnchors()
    self.ButtonClose:SetAnchor(RIGHT, self.Parent, TOPRIGHT, -Layout.padding, headerCenterY)

    self.ButtonMinimize:ClearAnchors()
    self.ButtonMinimize:SetAnchor(RIGHT, self.ButtonClose, LEFT, -Layout.padding, 0)

    self.MainTitle:ClearAnchors()
    self.MainTitle:SetAnchor(LEFT, self.ButtonMenu, RIGHT, Layout.padding, 0)
    self.MainTitle:SetAnchor(RIGHT, self.ButtonMinimize, LEFT, -Layout.padding, 0)

    self.MainTitle:SetFont(self.Font.Title)

    if self.SV.isMinimized then
        self.ContainerAddonUsers.Control:SetHidden(true)
        self.ContainerArkasisAssistant.Control:SetHidden(true)
        self.DrawShapeContainer.Control:SetHidden(true)
        self.ContainerLaunchPad.Control:SetHidden(true)
        self.PointerContainer.Control:SetHidden(true)
        if self.ContainerRaidleadTools then self.ContainerRaidleadTools.Control:SetHidden(true) end
        self.ContainerSlayerAssistant.Control:SetHidden(true)
        self.ContainerSpaulderOfRuin.Control:SetHidden(true)
        self.LabelAuthor:SetHidden(true)

        self.Parent:SetWidth(self.SV.panelWidth)
        self.Parent:SetHeight(minimizedHeight)
        return
    else
        self.ContainerAddonUsers.Control:SetHidden(false)
        self.ContainerArkasisAssistant.Control:SetHidden(false)
        self.DrawShapeContainer.Control:SetHidden(false)
        self.ContainerLaunchPad.Control:SetHidden(false)
        self.PointerContainer.Control:SetHidden(false)
        if self.ContainerRaidleadTools then self.ContainerRaidleadTools.Control:SetHidden(false) end
        self.ContainerSlayerAssistant.Control:SetHidden(false)
        self.ContainerSpaulderOfRuin.Control:SetHidden(false)
        self.LabelAuthor:SetHidden(false)
    end

    -- START CONTAINER
    local currentY = minimizedHeight + Layout.padding

    -- CONTAINER
    local function ProcessContainer(Container, LayoutContentFunc)
        Container.Control:SetAnchor(TOPLEFT, self.Parent, TOPLEFT, Layout.margin, currentY)
        Container.Control:SetAnchor(TOPRIGHT, self.Parent, TOPRIGHT, -Layout.margin, currentY)

        local isOpen = self.SV[Container.SVKey]
        Container.Icon:SetTexture(isOpen and "CombatCoordination/icons/arrow_down.dds" or "CombatCoordination/icons/arrow_right.dds")

        if isOpen then
            Container.Content:SetHidden(false)
            local contentHeight = LayoutContentFunc(Container.Content, contentWidth)
            local totalHeight = Layout.heightHeader + contentHeight + Layout.padding

            Container.Control:SetHeight(totalHeight)
            currentY = currentY + totalHeight + Layout.spacing
        else
            Container.Content:SetHidden(true)
            Container.Control:SetHeight(Layout.heightHeader)
            currentY = currentY + Layout.heightHeader + Layout.spacing
        end
    end

    -- ADDON USERS
    ProcessContainer(self.ContainerAddonUsers, function(Content, width)
        local innerY = Layout.paddingTop -- TEXT

        self.AddonUsersInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.AddonUsersInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.AddonUsersInfoLabel:GetTextHeight() + Layout.spacing

        for i = 1, self.activeAddonUserLabels do
            local Label = self.AddonUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end
        innerY = innerY + Layout.spacing
        self.ButtonPingRequest:SetDimensions(width - (2 * Layout.padding), Layout.heightElement)
        self.ButtonPingRequest:SetAnchor(TOP, Content, TOP, 0, innerY)
        return innerY + Layout.heightElement
    end)

    -- ARKASIS ASSISTANT
    ProcessContainer(self.ContainerArkasisAssistant, function(Content, width)
        local innerY = Layout.paddingTop
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2
        local buttonThird = (width - (2 * Layout.padding) - (2 * Layout.spacing)) / 3
        local buttonFull = width - (2 * Layout.padding)

        self.ArkasisAssistantPositionLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.ArkasisAssistantPositionLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.ArkasisAssistantPositionLabel:GetTextHeight() + Layout.spacing

        self.ArkasisAssistantButtonSet1:SetDimensions(buttonThird, Layout.heightElement)
        self.ArkasisAssistantButtonSet1:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        self.ArkasisAssistantButtonSet2:SetDimensions(buttonThird, Layout.heightElement)
        self.ArkasisAssistantButtonSet2:SetAnchor(TOPLEFT, self.ArkasisAssistantButtonSet1, TOPRIGHT, Layout.spacing, 0)
        self.ArkasisAssistantButtonSet3:SetDimensions(buttonThird, Layout.heightElement)
        self.ArkasisAssistantButtonSet3:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.heightElement + Layout.spacing

        if isRaidlead then
            self.ArkasisAssistantButtonAssign:SetHidden(false)
            self.ArkasisAssistantButtonStatus:SetHidden(false)
            self.ArkasisAssistantButtonAssign:SetDimensions(buttonHalf, Layout.heightElement)
            self.ArkasisAssistantButtonAssign:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ArkasisAssistantButtonStatus:SetDimensions(buttonHalf, Layout.heightElement)
            self.ArkasisAssistantButtonStatus:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + Layout.spacing

            local widthArrowSingle = Layout.heightElement * 1.0
            local widthArrowDouble = Layout.heightElement * 1.0
            local widthToggle = width - (2 * Layout.padding) - (4 * Layout.spacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

            self.ArkasisAssistantButtonMinus5:SetHidden(false)
            self.ArkasisAssistantButtonMinus1:SetHidden(false)
            self.ArkasisAssistantButtonToggle:SetHidden(false)
            self.ArkasisAssistantButtonPlus1:SetHidden(false)
            self.ArkasisAssistantButtonPlus5:SetHidden(false)

            self.ArkasisAssistantButtonMinus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.ArkasisAssistantButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.ArkasisAssistantButtonMinus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.ArkasisAssistantButtonMinus1:SetAnchor(TOPLEFT, self.ArkasisAssistantButtonMinus5, TOPRIGHT, Layout.spacing, 0)

            self.ArkasisAssistantButtonToggle:SetDimensions(widthToggle, Layout.heightElement)
            self.ArkasisAssistantButtonToggle:SetAnchor(TOPLEFT, self.ArkasisAssistantButtonMinus1, TOPRIGHT, Layout.spacing, 0)

            self.ArkasisAssistantButtonPlus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.ArkasisAssistantButtonPlus1:SetAnchor(TOPLEFT, self.ArkasisAssistantButtonToggle, TOPRIGHT, Layout.spacing, 0)

            self.ArkasisAssistantButtonPlus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.ArkasisAssistantButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.heightElement + Layout.spacing
        else
            self.ArkasisAssistantButtonAssign:SetHidden(true)
            self.ArkasisAssistantButtonStatus:SetHidden(true)

            self.ArkasisAssistantButtonMinus5:SetHidden(true)
            self.ArkasisAssistantButtonMinus1:SetHidden(true)
            self.ArkasisAssistantButtonToggle:SetHidden(true)
            self.ArkasisAssistantButtonPlus1:SetHidden(true)
            self.ArkasisAssistantButtonPlus5:SetHidden(true)
        end

        for i = 1, self.activeArkasisUserLabels do
            local Label = self.ArkasisUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end

        return innerY
    end)

    -- DRAW SHAPE
    ProcessContainer(self.DrawShapeContainer, function(Content, width)
        local innerY = Layout.paddingTop
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2

        local widthArrowSingle = Layout.heightElement * 1.0
        local widthArrowDouble = Layout.heightElement * 1.0
        local widthCenterLabel = width - (2 * Layout.padding) - (4 * Layout.spacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)
        local widthToggle = widthCenterLabel

        local isRectangle = (CC.DrawShape.SV.shapeType == LUT.DRAW_SHAPE.RECTANGLE)

        -- INFO
        self.DrawShapeInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.DrawShapeInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.DrawShapeInfoLabel:GetTextHeight() + Layout.spacing

        -- SHAPE TOGGLE
        self.DrawShapeButtonFirst:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.DrawShapeButtonFirst:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.DrawShapeButtonPrev:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.DrawShapeButtonPrev:SetAnchor(TOPLEFT, self.DrawShapeButtonFirst, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeLabelToggle:SetDimensions(widthToggle, Layout.heightElement)
        self.DrawShapeLabelToggle:SetAnchor(TOPLEFT, self.DrawShapeButtonPrev, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeButtonNext:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.DrawShapeButtonNext:SetAnchor(TOPLEFT, self.DrawShapeLabelToggle, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeButtonLast:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.DrawShapeButtonLast:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        innerY = innerY + Layout.heightElement + Layout.spacing

        -- ROW X (WIDTH / DIAMETER)
        self.DrawShapeButtonMinus10X:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.DrawShapeButtonMinus10X:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.DrawShapeButtonMinus1X:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.DrawShapeButtonMinus1X:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus10X, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeLabelValueX:SetDimensions(widthCenterLabel, Layout.heightElement)
        self.DrawShapeLabelValueX:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus1X, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeButtonPlus1X:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.DrawShapeButtonPlus1X:SetAnchor(TOPLEFT, self.DrawShapeLabelValueX, TOPRIGHT, Layout.spacing, 0)

        self.DrawShapeButtonPlus10X:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.DrawShapeButtonPlus10X:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        innerY = innerY + Layout.heightElement + Layout.spacing

        -- ROW Z (LENGTH) - RECTANGLE
        if isRectangle then
            self.DrawShapeButtonMinus10Z:SetHidden(false)
            self.DrawShapeButtonMinus1Z:SetHidden(false)
            self.DrawShapeLabelValueZ:SetHidden(false)
            self.DrawShapeButtonPlus1Z:SetHidden(false)
            self.DrawShapeButtonPlus10Z:SetHidden(false)

            self.DrawShapeButtonMinus10Z:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.DrawShapeButtonMinus10Z:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.DrawShapeButtonMinus1Z:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.DrawShapeButtonMinus1Z:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus10Z, TOPRIGHT, Layout.spacing, 0)

            self.DrawShapeLabelValueZ:SetDimensions(widthCenterLabel, Layout.heightElement)
            self.DrawShapeLabelValueZ:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus1Z, TOPRIGHT, Layout.spacing, 0)

            self.DrawShapeButtonPlus1Z:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.DrawShapeButtonPlus1Z:SetAnchor(TOPLEFT, self.DrawShapeLabelValueZ, TOPRIGHT, Layout.spacing, 0)

            self.DrawShapeButtonPlus10Z:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.DrawShapeButtonPlus10Z:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.heightElement + Layout.spacing
        else
            self.DrawShapeButtonMinus10Z:SetHidden(true)
            self.DrawShapeButtonMinus1Z:SetHidden(true)
            self.DrawShapeLabelValueZ:SetHidden(true)
            self.DrawShapeButtonPlus1Z:SetHidden(true)
            self.DrawShapeButtonPlus10Z:SetHidden(true)
        end

        -- PLACE BUTTONS
        self.DrawShapeButtonCursor:SetDimensions(buttonHalf, Layout.heightElement)
        self.DrawShapeButtonCursor:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.DrawShapeButtonSelf:SetDimensions(buttonHalf, Layout.heightElement)
        self.DrawShapeButtonSelf:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.heightElement
    end)

    -- LAUNCH PAD
    ProcessContainer(self.ContainerLaunchPad, function(Content, width)
        local innerY = Layout.paddingTop
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2
        local buttonFull = width - (2 * Layout.padding)

        local widthArrowSingle = Layout.heightElement * 1.0
        local widthArrowDouble = Layout.heightElement * 1.0
        local widthToggle = width - (2 * Layout.padding) - (4 * Layout.spacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

        -- INFO
        self.LaunchPadInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.LaunchPadInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.LaunchPadInfoLabel:GetTextHeight() + Layout.spacing

        -- CATEGORY TOGGLE
        self.LaunchPadCatButtonFirst:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.LaunchPadCatButtonFirst:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.LaunchPadCatButtonPrev:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.LaunchPadCatButtonPrev:SetAnchor(TOPLEFT, self.LaunchPadCatButtonFirst, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadCatLabelToggle:SetDimensions(widthToggle, Layout.heightElement)
        self.LaunchPadCatLabelToggle:SetAnchor(TOPLEFT, self.LaunchPadCatButtonPrev, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadCatButtonNext:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.LaunchPadCatButtonNext:SetAnchor(TOPLEFT, self.LaunchPadCatLabelToggle, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadCatButtonLast:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.LaunchPadCatButtonLast:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        innerY = innerY + Layout.heightElement + Layout.spacing

        -- TRIGGER TOGGLE
        self.LaunchPadButtonFirst:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.LaunchPadButtonFirst:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.LaunchPadButtonPrev:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.LaunchPadButtonPrev:SetAnchor(TOPLEFT, self.LaunchPadButtonFirst, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadLabelToggle:SetDimensions(widthToggle, Layout.heightElement)
        self.LaunchPadLabelToggle:SetAnchor(TOPLEFT, self.LaunchPadButtonPrev, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadButtonNext:SetDimensions(widthArrowSingle, Layout.heightElement)
        self.LaunchPadButtonNext:SetAnchor(TOPLEFT, self.LaunchPadLabelToggle, TOPRIGHT, Layout.spacing, 0)

        self.LaunchPadButtonLast:SetDimensions(widthArrowDouble, Layout.heightElement)
        self.LaunchPadButtonLast:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        innerY = innerY + Layout.heightElement + Layout.spacing

        -- AT CURSOR / ON SELF
        self.LaunchPadButtonCursor:SetDimensions(buttonHalf, Layout.heightElement)
        self.LaunchPadButtonCursor:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.LaunchPadButtonSelf:SetDimensions(buttonHalf, Layout.heightElement)
        self.LaunchPadButtonSelf:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.heightElement + Layout.spacing

        -- DELETE CLOSEST
        self.LaunchPadButtonDeleteClosest:SetDimensions(buttonFull, Layout.heightElement)
        self.LaunchPadButtonDeleteClosest:SetAnchor(TOP, Content, TOP, 0, innerY)

        return innerY + Layout.heightElement
    end)

    -- POINTER
    ProcessContainer(self.PointerContainer, function(Content, width)
        local innerY = Layout.paddingTop -- TEXT

        -- INFO
        self.PointerInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.PointerInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.PointerInfoLabel:GetTextHeight() + Layout.spacing

        -- BUTTONS
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2

        self.PointerButtonCursor:SetDimensions(buttonHalf, Layout.heightElement)
        self.PointerButtonCursor:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.PointerButtonSelf:SetDimensions(buttonHalf, Layout.heightElement)
        self.PointerButtonSelf:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.heightElement
    end)

    -- RAIDLEAD TOOLS
    if isRaidlead then
        self.ContainerRaidleadTools.Control:SetHidden(false)
        ProcessContainer(self.ContainerRaidleadTools, function(Content, width)
            local innerY = Layout.paddingTop
            local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2
            local widthArrowSingle = Layout.heightElement * 1.0
            local widthArrowDouble = Layout.heightElement * 1.0
            local widthToggle = width - (2 * Layout.padding) - (4 * Layout.spacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

            -- INFO
            self.RaidleadToolsInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
            self.RaidleadToolsInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + self.RaidleadToolsInfoLabel:GetTextHeight() + Layout.spacing

            -- WIPE AND PTE
            self.ButtonWipePlease:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonWipePlease:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonExitInstance:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonExitInstance:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + Layout.spacing

            -- PORT IN AND PORT LEAD
            self.ButtonPortInPlease:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonPortInPlease:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonPortToLeader:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonPortToLeader:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + Layout.spacing

            -- READYCHECK AND VOTE
            self.ButtonReadyCheck:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonReadyCheck:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonVoteStart:SetDimensions(buttonHalf, Layout.heightElement)
            self.ButtonVoteStart:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + (Layout.spacing * 2)

            -- BREAK
            self.BreakTimerButtonMinus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.BreakTimerButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.BreakTimerButtonMinus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.BreakTimerButtonMinus1:SetAnchor(TOPLEFT, self.BreakTimerButtonMinus5, TOPRIGHT, Layout.spacing, 0)
            self.BreakTimerButtonToggle:SetDimensions(widthToggle, Layout.heightElement)
            self.BreakTimerButtonToggle:SetAnchor(TOPLEFT, self.BreakTimerButtonMinus1, TOPRIGHT, Layout.spacing, 0)
            self.BreakTimerButtonPlus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.BreakTimerButtonPlus1:SetAnchor(TOPLEFT, self.BreakTimerButtonToggle, TOPRIGHT, Layout.spacing, 0)
            self.BreakTimerButtonPlus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.BreakTimerButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + (Layout.spacing * 2)

            -- PULL TOGGLE
            self.PullTimerButtonMinus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.PullTimerButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.PullTimerButtonMinus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.PullTimerButtonMinus1:SetAnchor(TOPLEFT, self.PullTimerButtonMinus5, TOPRIGHT, Layout.spacing, 0)
            self.PullTimerButtonToggle:SetDimensions(widthToggle, Layout.heightElement)
            self.PullTimerButtonToggle:SetAnchor(TOPLEFT, self.PullTimerButtonMinus1, TOPRIGHT, Layout.spacing, 0)
            self.PullTimerButtonPlus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.PullTimerButtonPlus1:SetAnchor(TOPLEFT, self.PullTimerButtonToggle, TOPRIGHT, Layout.spacing, 0)
            self.PullTimerButtonPlus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.PullTimerButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + Layout.spacing

            return innerY
        end)
    else
        if self.ContainerRaidleadTools then
            self.ContainerRaidleadTools.Control:SetHidden(true)
            self.ContainerRaidleadTools.Control:SetHeight(0)
        end
    end

    -- SLAYER ASSSISTANT
    ProcessContainer(self.ContainerSlayerAssistant, function(Content, width)
        local innerY = Layout.paddingTop
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2
        local buttonFull = width - (2 * Layout.padding)

        self.SlayerAssistantPositionLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.SlayerAssistantPositionLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.SlayerAssistantPositionLabel:GetTextHeight() + Layout.spacing

        self.SlayerAssistantButtonSetLeft:SetDimensions(buttonHalf, Layout.heightElement)
        self.SlayerAssistantButtonSetLeft:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        self.SlayerAssistantButtonSetRight:SetDimensions(buttonHalf, Layout.heightElement)
        self.SlayerAssistantButtonSetRight:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.heightElement + Layout.spacing

        if isRaidlead then
            self.SlayerAssistantButtonAssign:SetHidden(false)
            self.SlayerAssistantButtonStatus:SetHidden(false)
            self.SlayerAssistantButtonAssign:SetDimensions(buttonHalf, Layout.heightElement)
            self.SlayerAssistantButtonAssign:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.SlayerAssistantButtonStatus:SetDimensions(buttonHalf, Layout.heightElement)
            self.SlayerAssistantButtonStatus:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.heightElement + Layout.spacing

            local widthArrowSingle = Layout.heightElement * 1.0
            local widthArrowDouble = Layout.heightElement * 1.0
            local widthToggle = width - (2 * Layout.padding) - (4 * Layout.spacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

            self.SlayerAssistantButtonMinus5:SetHidden(false)
            self.SlayerAssistantButtonMinus1:SetHidden(false)
            self.SlayerAssistantButtonToggle:SetHidden(false)
            self.SlayerAssistantButtonPlus1:SetHidden(false)
            self.SlayerAssistantButtonPlus5:SetHidden(false)

            self.SlayerAssistantButtonMinus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.SlayerAssistantButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.SlayerAssistantButtonMinus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.SlayerAssistantButtonMinus1:SetAnchor(TOPLEFT, self.SlayerAssistantButtonMinus5, TOPRIGHT, Layout.spacing, 0)

            self.SlayerAssistantButtonToggle:SetDimensions(widthToggle, Layout.heightElement)
            self.SlayerAssistantButtonToggle:SetAnchor(TOPLEFT, self.SlayerAssistantButtonMinus1, TOPRIGHT, Layout.spacing, 0)

            self.SlayerAssistantButtonPlus1:SetDimensions(widthArrowSingle, Layout.heightElement)
            self.SlayerAssistantButtonPlus1:SetAnchor(TOPLEFT, self.SlayerAssistantButtonToggle, TOPRIGHT, Layout.spacing, 0)

            self.SlayerAssistantButtonPlus5:SetDimensions(widthArrowDouble, Layout.heightElement)
            self.SlayerAssistantButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.heightElement + Layout.spacing
        else
            self.SlayerAssistantButtonAssign:SetHidden(true)
            self.SlayerAssistantButtonStatus:SetHidden(true)

            self.SlayerAssistantButtonMinus5:SetHidden(true)
            self.SlayerAssistantButtonMinus1:SetHidden(true)
            self.SlayerAssistantButtonToggle:SetHidden(true)
            self.SlayerAssistantButtonPlus1:SetHidden(true)
            self.SlayerAssistantButtonPlus5:SetHidden(true)
        end

        for i = 1, self.activeSlayerSetUserLabels do
            local Label = self.SlayerSetUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end

        return innerY
    end)

    -- SPAULDER OF RUIN
    ProcessContainer(self.ContainerSpaulderOfRuin, function(Content, width)
        local innerY = Layout.paddingTop
        local buttonHalf = (width - (2 * Layout.padding) - Layout.spacing) / 2

        -- INFO
        self.SpaulderInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.SpaulderInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.SpaulderInfoLabel:GetTextHeight() + Layout.spacing

        -- LIST
        for i = 1, self.activeSpaulderUserLabels do
            local Label = self.SpaulderUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end
        innerY = innerY + Layout.spacing

        -- BUTTONS
        self.SpaulderButtonKick:SetDimensions(buttonHalf, Layout.heightElement)
        self.SpaulderButtonKick:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.SpaulderButtonReinvite:SetDimensions(buttonHalf, Layout.heightElement)
        self.SpaulderButtonReinvite:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.heightElement + Layout.spacing

        return innerY
    end)

    -- AUTHOR
    currentY = currentY - Layout.spacing + Layout.margin
    self.LabelAuthor:SetAnchor(TOP, self.Parent, TOP, 0, currentY - Layout.padding)
    currentY = currentY + self.LabelAuthor:GetTextHeight()

    -- UPDATE DIMENS
    self.Parent:SetWidth(self.SV.panelWidth)
    self.Parent:SetHeight(currentY)
end

----------------------------------------------------------------------------------------------------
-- SHOW, HIDE, TOGGLE? TODO: CHECK IF TOGGLE STILL NECC
----------------------------------------------------------------------------------------------------
function Module:Show(showCursor)
    if not self.Parent then self:CreatePanel() end

    self.SV.isVisible = true
    self.Parent:SetHidden(false)
    self:UpdateData()

    if not HUD_SCENE:HasFragment(self.Fragment) then
        HUD_SCENE:AddFragment(self.Fragment)
    end
    if not HUD_UI_SCENE:HasFragment(self.Fragment) then
        HUD_UI_SCENE:AddFragment(self.Fragment)
    end

    if showCursor then
        SCENE_MANAGER:SetInUIMode(true)
        --ShowMouse()
    end
end

function Module:Hide()
    if not self.Parent then return end

    self.SV.isVisible = false
    self.Parent:SetHidden(true)

    if HUD_SCENE:HasFragment(self.Fragment) then
        HUD_SCENE:RemoveFragment(self.Fragment)
    end
    if HUD_UI_SCENE:HasFragment(self.Fragment) then
        HUD_UI_SCENE:RemoveFragment(self.Fragment)
    end
end

function Module:Toggle()
    if not CC.SV.enableAddon then
        d(CC.CHAT .. " |cFF0000Addon is disabled.|r")
        return
    end

    if self.SV.isVisible then
        self:Hide()
        --SCENE_MANAGER:SetInUIMode(false)
    else
        self:Show(true)
    end
end

----------------------------------------------------------------------------------------------------
-- TOGGLE MINIMIZE
----------------------------------------------------------------------------------------------------
function Module:ToggleMinimize()
    self.SV.isMinimized = not self.SV.isMinimized
    self:UpdateDimensions()
end

function Module:CloseAll()
    self.SV.isOpenAddonUsers       = false
    self.SV.isOpenArkasisAssistant = false
    self.SV.isOpenDrawShape        = false
    self.SV.isOpenLaunchPad        = false
    self.SV.isOpenPointer          = false
    self.SV.isOpenRaidleadTools    = false
    self.SV.isOpenSlayerAssistant  = false
    self.SV.isOpenSpaulderOfRuin   = false
end

----------------------------------------------------------------------------------------------------
-- RESET POSITION
----------------------------------------------------------------------------------------------------
function Module:ResetPosition()
    self.SV.offsetX = self.Default.offsetX
    self.SV.offsetY = self.Default.offsetY

    local anchorMode = self.SV.anchorMode or 1
    if anchorMode == 2 then
        self.SV.offsetY = GuiRoot:GetHeight() / 2
    elseif anchorMode == 3 then
        self.SV.offsetY = GuiRoot:GetHeight()
    end

    if self.Parent then
        self:ApplyAnchor()
    end

    self:CloseAll()

    self:Show(true)
end

----------------------------------------------------------------------------------------------------
-- ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    if not self.Parent then self:CreatePanel() end

    if not CC.SV.enableAddon then
        self:Hide()
        return
    end

    if self.SV.isVisible then
        self:Show(false)
    else
        self:Hide()
    end

    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "DisplayPanel_UpdateData", 1000, function() self:UpdateData() end)
end

function Module:CustomDisable()
    self:Hide()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "DisplayPanel_UpdateData")
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE / SLASH COMMAND
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)

SLASH_COMMANDS["/cc_panel"] = function() CC.DisplayPanel:Toggle() end