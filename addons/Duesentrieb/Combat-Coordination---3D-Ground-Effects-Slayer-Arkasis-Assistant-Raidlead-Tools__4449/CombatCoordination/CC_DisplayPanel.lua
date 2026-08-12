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

    maxLenghtDisplayname = 14,

    -------------------------------------------------------------------------------------------------
    -- COLORS
    -------------------------------------------------------------------------------------------------
    GN_NORMAL    = { 0, 1, 0, 1 },
    RD_NORMAL    = { 1, 0, 0, 1 },
    BL_NORMAL    = { 0, 0.5, 1, 1 },
    YL_NORMAL    = { 1, 0.875, 0, 1 },

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
        margin           = 10,  -- DISTANCE TO EDGES AND BETWEEN CONTAINERS
        padding          = 5,   -- DISTANCE INSIDE CONTAINER (L / R / BOT)
        paddingTopButton = 5,   -- TOP DISTANCE IF FIRST ELMT IS BUTTON
        paddingTopText   = 0,   -- TOP DISTANCE IF FIRST ELMT IS TEXT
        headerHeight     = 24,  -- HEIGHT OF THE CONTAINR HEADER
        elementHeight    = 24,  -- HEIGHT OF BUTTONS
        elementSpacing   = 5,   -- DISTANCE BETWEEN ELMTS
    },

    Font = {
        Title         = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick",
        SubTitle      = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick",
        Button        = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick",
        Normal        = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick",
        Small         = "$(BOLD_FONT)|$(KB_14)|soft-shadow-thick",
    },

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

        isVisible = true,
        isMinimized = false,
        isOpenAddonUsers       = false,
        isOpenSlayerAssistant  = false,
        isOpenArkasisAssistant = false,
        isOpenPointer          = false,
        isOpenRaidleadTools    = false,
        isOpenDrawShape        = false,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CREATE PANEL
----------------------------------------------------------------------------------------------------
function Module:CreatePanel()
    if self.Parent then return end

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
        SetTooltipText(InformationTooltip, "Open Menu")
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
        SetTooltipText(InformationTooltip, "Close Panel")
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
        SetTooltipText(InformationTooltip, self.SV.isMinimized and "Maximize Panel" or "Minimize Panel")
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
    self.LabelAuthor:SetText("CC " .. tostring(CC.VERSION) .. " - @Duesentrieb [PC/EU]")

    -- BUILD CONTS
    self:BuildAddonUsersContainer()
    self:BuildDrawShapeContainer()
    self:BuildPointerContainer()
    self:BuildRaidleadToolsContainer()
    self:BuildSlayerAssistantContainer()
    self:BuildArkasisAssistantContainer()

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
    Header:SetHeight(self.Layout.headerHeight)
    Header:SetMouseEnabled(true)
    Header:SetClickSound("Click")

    Header:SetHandler("OnClicked", function()
        self.SV[SVKey] = not self.SV[SVKey]
        self:UpdateDimensions()
    end)

    -- ARROW THINGITHING
    local Icon = WINDOW_MANAGER:CreateControl(name .. "_Icon", Header, CT_TEXTURE)
    Icon:SetDimensions(10, 10)
    Icon:SetTexture(self.SV[SVKey] and "CombatCoordination/icons/down-arrow.dds" or "CombatCoordination/icons/right-arrow.dds")
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
-- [A] ADDON USERS AND PING
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
        CC.Broadcast:SendPingRequest(true)
    end)
end

----------------------------------------------------------------------------------------------------
-- [D] DRAW SHAPE
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
    self.DrawShapeButtonToggle = self:CreateButton("CC_DisplayPanel_DrawShapeButtonToggle", Content, "CUR. SHAPE: CIRCLE", function()
        if CC.DrawShape.SV.shapeType == LUT.DRAW_SHAPE.CIRCLE then
            CC.DrawShape.SV.shapeType = LUT.DRAW_SHAPE.RECTANGLE
        else
            CC.DrawShape.SV.shapeType = LUT.DRAW_SHAPE.CIRCLE
        end
        self:UpdateData()
    end)

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
-- [P] POINTER
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
-- [R] RAIDLEAD TOOLS
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
        CC.RaidleadTools:StartVote()
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
-- [S] SLAYER ASSISTANT
----------------------------------------------------------------------------------------------------
function Module:BuildSlayerAssistantContainer()
    self.ContainerSlayerAssistant = self:CreateContainer("CC_DisplayPanel_ContainerSlayerAssistant", "isOpenSlayerAssistant")
    local Content = self.ContainerSlayerAssistant.Content

    self.SlayerAssistantPositionLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_SlayerAssistantPositionLabel", Content, CT_LABEL)
    self.SlayerAssistantPositionLabel:SetFont(self.Font.Normal)
    self.SlayerAssistantPositionLabel:SetColor(unpack(self.ESO_NORMAL))
    self.SlayerAssistantPositionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.SlayerAssistantPositionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.SlayerAssistantButtonTrigger = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonTrigger", Content, "TRIGGER SLAYER", function()
        CC.SlayerAssistant:SlayerTrigger(true)
    end)

    self.SlayerAssistantButtonAssign = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonAssign", Content, "REQ ASSIGN", function()
        CC.SlayerAssistant:SendAssignmentRequest()
    end)

    self.SlayerAssistantButtonStatus = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonStatus", Content, "REQ STATUS", function()
        CC.Broadcast:SendPingRequest(true)
    end)

    self.SlayerAssistantButtonSetLeft = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonSetLeft", Content, "SET LEFT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_LEFT)
    end)

    self.SlayerAssistantButtonSetRight = self:CreateButton("CC_DisplayPanel_SlayerAssistantButtonSetRight", Content, "SET RIGHT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_RIGHT)
    end)
end

----------------------------------------------------------------------------------------------------
-- [K] ARKASIS ASSISTANT
----------------------------------------------------------------------------------------------------
function Module:BuildArkasisAssistantContainer()
    self.ContainerArkasisAssistant = self:CreateContainer("CC_DisplayPanel_ContainerArkasisAssistant", "isOpenArkasisAssistant")
    local Content = self.ContainerArkasisAssistant.Content

    self.ArkasisAssistantPositionLabel = WINDOW_MANAGER:CreateControl("CC_DisplayPanel_ArkasisAssistantPositionLabel", Content, CT_LABEL)
    self.ArkasisAssistantPositionLabel:SetFont(self.Font.Normal)
    self.ArkasisAssistantPositionLabel:SetColor(unpack(self.ESO_NORMAL))
    self.ArkasisAssistantPositionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.ArkasisAssistantPositionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ArkasisAssistantButtonTrigger = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonTrigger", Content, "TRIGGER ARKASIS", function()
        CC.ArkasisAssistant:ArkasisTrigger(true)
    end)

    self.ArkasisAssistantButtonAssign = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonAssign", Content, "REQ ASSIGN", function()
        CC.ArkasisAssistant:SendAssignmentRequest()
    end)

    self.ArkasisAssistantButtonStatus = self:CreateButton("CC_DisplayPanel_ArkasisAssistantButtonStatus", Content, "REQ STATUS", function()
        CC.Broadcast:SendPingRequest(true)
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
end

----------------------------------------------------------------------------------------------------
-- SHORT(ER) DISPLAY NAME BECAUSE OF KENDRASMYNAMEISUNNECESSARYLONGKENPACHI
----------------------------------------------------------------------------------------------------
function Module:GetShortName(longName, maxLength)
    local limit = maxLength or self.maxLenghtDisplayname
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
-- UPDATE DATA (LABELS, STRINGS, COUNTERS)
----------------------------------------------------------------------------------------------------
function Module:UpdateData()
    if not self.Parent or self.Parent:IsHidden() then return end

    local currentTime = GetGameTimeSeconds()
    local currentZoneId = CC.GetCleanZoneId()

    ----------------------------------------------------------------------------------------------------
    -- [A] ADDON USERS DATA
    ----------------------------------------------------------------------------------------------------
    local countAddonUsers = 0
    self.activeAddonUserLabels = 0

    for displayName, User in pairs(CC.UserData) do
        countAddonUsers = countAddonUsers + 1
        if self.SV.isOpenAddonUsers then
            self.activeAddonUserLabels = self.activeAddonUserLabels + 1
            local Label = self:GetOrCreateLabel(self.AddonUserLabels, "AddonUserLabels", self.activeAddonUserLabels, self.ContainerAddonUsers.Content, TEXT_ALIGN_LEFT)
            local numPing = User.ping or 0
            local isRaidlead = User.isRaidlead and " |cFFDF00RL|r" or ""

            -- ZONE CHECK
            local slayerZoneId = User.SlayerAssistant and User.SlayerAssistant.zoneId or 0
            local arkasisZoneId = User.ArkasisAssistant and User.ArkasisAssistant.zoneId or 0

            local extraInfo = ""

            if slayerZoneId == currentZoneId or arkasisZoneId == currentZoneId then
                -- SLAYER SAME ZONE OR ?
                local stringSlayer = "|c7F7F7F?|r"
                if slayerZoneId == currentZoneId then
                local slayerSideId = User.SlayerAssistant and User.SlayerAssistant.sideId or CC.SlayerAssistant.SIDE_NONE
                local slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorNone) or "|cBFBFBF"
                local slayerLetter = "?"

                if slayerSideId == CC.SlayerAssistant.SIDE_LEFT then
                    slayerLetter = "L"
                    slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorLeft)
                elseif slayerSideId == CC.SlayerAssistant.SIDE_RIGHT then
                    slayerLetter = "R"
                    slayerColorHex = CC.GetHexColorFromArray(CC.SlayerAssistant.SV.ColorRight)
                end
                    stringSlayer = string.format("%s%s|r", slayerColorHex, slayerLetter)
                end

                -- ARKASIS SAME ZONE OR ?
                local stringArkasis = "|c7F7F7F?|r"
                if arkasisZoneId == currentZoneId then
                local arkasisSideId = User.ArkasisAssistant and User.ArkasisAssistant.sideId or CC.ArkasisAssistant.SIDE_NONE
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
                    stringArkasis = string.format("%s%s|r", arkasisColorHex, arkasisLetter)
                end

                extraInfo = string.format(" - %s / %s", stringSlayer, stringArkasis)
            end

            local shortName = self:GetShortName(displayName, self.maxLenghtDisplayname)
            Label:SetText(string.format("%d) |cFFFFFF%s|r%s (%d ms)%s", self.activeAddonUserLabels, shortName, isRaidlead, numPing, extraInfo))
        end
    end

    if self.SV.isOpenAddonUsers and countAddonUsers == 0 then
        self.activeAddonUserLabels = 1
        local Label = self:GetOrCreateLabel(self.AddonUserLabels, "AddonUserLabels", self.activeAddonUserLabels, self.ContainerAddonUsers.Content, TEXT_ALIGN_LEFT)
        Label:SetText("No addon users found.")
    end

    self:HideUnusedLabels(self.AddonUserLabels, self.activeAddonUserLabels)

    local AddonUsersIcon = { iconPath = CC.NAME .. "/icons/combatcoordination.dds" }
    local expectedSize = math.max(1, GetGroupSize())
    self.ContainerAddonUsers.Title:SetText(self:GetTitleWithIcon(AddonUsersIcon, string.format("ADDON USERS: |cFFFFFF%d/%d|r", countAddonUsers, expectedSize)))

    ----------------------------------------------------------------------------------------------------
    -- [D] DRAW SHAPE
    ----------------------------------------------------------------------------------------------------
    self.DrawShapeContainer.Title:SetText(self:GetTitleWithIcon(CC.DrawShape, "DRAW SHAPE"))
    local isRectangle = (CC.DrawShape.SV.shapeType == LUT.DRAW_SHAPE.RECTANGLE)

    self.DrawShapeButtonToggle:SetText(isRectangle and "CUR. SHAPE: RECTANGLE" or "CUR. SHAPE: CIRCLE")

    local labelX = isRectangle and "Width" or "Diameter"
    self.DrawShapeLabelValueX:SetText(string.format("%s: %dm", labelX, CC.DrawShape.SV.width / 100))
    self.DrawShapeLabelValueZ:SetText(string.format("Height: %dm", CC.DrawShape.SV.height / 100))

    ----------------------------------------------------------------------------------------------------
    -- [P] POINTER
    ----------------------------------------------------------------------------------------------------
    self.PointerContainer.Title:SetText(self:GetTitleWithIcon(CC.Pointer, "3D POINTER"))

    ----------------------------------------------------------------------------------------------------
    -- [R] RAIDLEAD TOOLS
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
    local voteData = CC.RaidleadTools.VoteData
    if voteData and voteData.endTime > currentTime then
        local stringYES = string.format("|c00FF00%d|r", voteData.yes)
        local stringNO = string.format("|cFF0000%d|r", voteData.no)
        local stringIDC = string.format("|cFFDF00%d|r", voteData.idc)
        self.ButtonVoteStart:SetText(string.format("STOP %s - %s - %s", stringYES, stringNO, stringIDC))
        self.ButtonVoteStart:SetCustomColors(self.RD_NORMAL)
    else
        self.ButtonVoteStart:SetText("START VOTE")
        self.ButtonVoteStart:SetCustomColors(nil, nil)
    end

    ----------------------------------------------------------------------------------------------------
    -- [S] SLAYER ASSISTANT
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

    for displayName, User in pairs(CC.UserData) do
        if User.SlayerAssistant and User.SlayerAssistant.isEquipped ~= CC.SlayerAssistant.SET_STATUS_NONE and User.SlayerAssistant.zoneId == currentZoneId then
            countSlayerSetUsers = countSlayerSetUsers + 1
            if self.SV.isOpenSlayerAssistant then
                self.activeSlayerSetUserLabels = self.activeSlayerSetUserLabels + 1
                local Label = self:GetOrCreateLabel(self.SlayerSetUserLabels, "SlayerSetUserLabels", self.activeSlayerSetUserLabels, self.ContainerSlayerAssistant.Content, TEXT_ALIGN_LEFT)

                local isEquipped = User.SlayerAssistant.isEquipped or CC.SlayerAssistant.SET_STATUS_NONE
                local setName = CC.SlayerAssistant:GetSetNameFromStatusId(isEquipped)
                local shortName = self:GetShortName(displayName, self.maxLenghtDisplayname)
                local sideName = CC.SlayerAssistant:GetSideNameFromSideId(User.SlayerAssistant.sideId)
                Label:SetText(string.format("Set: |cFFFFFF[%s]|r - %s - %s", setName, shortName, sideName))
            end
        end
    end

    self:HideUnusedLabels(self.SlayerSetUserLabels, self.activeSlayerSetUserLabels)
    self.ContainerSlayerAssistant.Title:SetText(self:GetTitleWithIcon(CC.SlayerAssistant, "SLAYER ASSISTANT"))

    -- BUTTON TEXT
    if CC.DisplayNotification.slayerEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.slayerEndTime - currentTime)
        self.SlayerAssistantButtonTrigger:SetText(string.format("STOP SLAYER %d Sec", remaining))
        self.SlayerAssistantButtonTrigger:SetCustomColors(self.RD_NORMAL)
    else
        local configuredSecs = (CC.SlayerAssistant.SV.durationMs / 1000) or 5
        self.SlayerAssistantButtonTrigger:SetText(string.format("TRIGGER SLAYER %d Sec", configuredSecs))
        self.SlayerAssistantButtonTrigger:SetCustomColors(self.GN_NORMAL)
    end

    ----------------------------------------------------------------------------------------------------
    -- [K] ARKASIS ASSISTANT
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

    for displayName, User in pairs(CC.UserData) do
        if User.ArkasisAssistant and User.ArkasisAssistant.sideId == arkasisSideId and arkasisSideId ~= CC.ArkasisAssistant.SIDE_NONE and User.ArkasisAssistant.zoneId == currentZoneId then
            if self.SV.isOpenArkasisAssistant then
                self.activeArkasisUserLabels = self.activeArkasisUserLabels + 1
                local Label = self:GetOrCreateLabel(self.ArkasisUserLabels, "ArkasisUserLabels", self.activeArkasisUserLabels, self.ContainerArkasisAssistant.Content, TEXT_ALIGN_LEFT)

                local isEquipped = User.ArkasisAssistant.isEquipped or CC.ArkasisAssistant.SET_STATUS_NONE
                local setName = CC.ArkasisAssistant:GetSetNameFromStatusId(isEquipped)
                local shortName = self:GetShortName(displayName, self.maxLenghtDisplayname)
                local sideName = CC.ArkasisAssistant:GetSideNameFromSideId(User.ArkasisAssistant.sideId)
                Label:SetText(string.format("Set: |cFFFFFF[%s]|r - %s - %s", setName, shortName, sideName))
            end
        end
    end

    -- IS EMPTY
    if self.SV.isOpenArkasisAssistant and self.activeArkasisUserLabels == 0 then
        self.activeArkasisUserLabels = 1
        local Label = self:GetOrCreateLabel(self.ArkasisUserLabels, "ArkasisUserLabels", self.activeArkasisUserLabels, self.ContainerArkasisAssistant.Content, TEXT_ALIGN_LEFT)
        if arkasisSideId == CC.ArkasisAssistant.SIDE_NONE then
            Label:SetText("You are unassigned.")
        else
            Label:SetText("No partners in your stack.")
        end
    end

    self:HideUnusedLabels(self.ArkasisUserLabels, self.activeArkasisUserLabels)
    self.ContainerArkasisAssistant.Title:SetText(self:GetTitleWithIcon(CC.ArkasisAssistant, "ARKASIS ASSISTANT"))

    if CC.DisplayNotification.arkasisEndTime > currentTime then
        local remaining = math.ceil(CC.DisplayNotification.arkasisEndTime - currentTime)
        self.ArkasisAssistantButtonTrigger:SetText(string.format("STOP ARKASIS %d Sec", remaining))
        self.ArkasisAssistantButtonTrigger:SetCustomColors(self.RD_NORMAL)
    else
        local configuredSecs = (CC.ArkasisAssistant.SV.durationMs / 1000) or 5
        self.ArkasisAssistantButtonTrigger:SetText(string.format("TRIGGER ARKASIS %d Sec", configuredSecs))
        self.ArkasisAssistantButtonTrigger:SetCustomColors(self.YL_NORMAL)
    end

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
        self.DrawShapeContainer.Control:SetHidden(true)
        self.PointerContainer.Control:SetHidden(true)
        if self.ContainerRaidleadTools then self.ContainerRaidleadTools.Control:SetHidden(true) end
        self.ContainerSlayerAssistant.Control:SetHidden(true)
        self.ContainerArkasisAssistant.Control:SetHidden(true)
        self.LabelAuthor:SetHidden(true)

        self.Parent:SetWidth(self.SV.panelWidth)
        self.Parent:SetHeight(minimizedHeight)
        return
    else
        self.ContainerAddonUsers.Control:SetHidden(false)
        self.DrawShapeContainer.Control:SetHidden(false)
        self.PointerContainer.Control:SetHidden(false)
        self.ContainerSlayerAssistant.Control:SetHidden(false)
        self.ContainerArkasisAssistant.Control:SetHidden(false)
        self.LabelAuthor:SetHidden(false)
    end

    -- START CONTAINER
    local currentY = minimizedHeight + Layout.padding

    -- CONTAINER
    local function ProcessContainer(Container, LayoutContentFunc)
        Container.Control:SetAnchor(TOPLEFT, self.Parent, TOPLEFT, Layout.margin, currentY)
        Container.Control:SetAnchor(TOPRIGHT, self.Parent, TOPRIGHT, -Layout.margin, currentY)

        local isOpen = self.SV[Container.SVKey]
        Container.Icon:SetTexture(isOpen and "CombatCoordination/icons/down-arrow.dds" or "CombatCoordination/icons/right-arrow.dds")

        if isOpen then
            Container.Content:SetHidden(false)
            local contentHeight = LayoutContentFunc(Container.Content, contentWidth)
            local totalHeight = Layout.headerHeight + contentHeight + Layout.padding

            Container.Control:SetHeight(totalHeight)
            currentY = currentY + totalHeight + Layout.margin
        else
            Container.Content:SetHidden(true)
            Container.Control:SetHeight(Layout.headerHeight)
            currentY = currentY + Layout.headerHeight + Layout.margin
        end
    end

    -- [A] ADDON USERS
    ProcessContainer(self.ContainerAddonUsers, function(Content, width)
        local innerY = Layout.paddingTopText -- TEXT

        self.AddonUsersInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.AddonUsersInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.AddonUsersInfoLabel:GetTextHeight() + Layout.elementSpacing

        for i = 1, self.activeAddonUserLabels do
            local Label = self.AddonUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end
        innerY = innerY + Layout.elementSpacing
        self.ButtonPingRequest:SetDimensions(width - (2 * Layout.padding), Layout.elementHeight)
        self.ButtonPingRequest:SetAnchor(TOP, Content, TOP, 0, innerY)
        return innerY + Layout.elementHeight
    end)

    -- [D] DRAW SHAPE
    ProcessContainer(self.DrawShapeContainer, function(Content, width)
        local innerY = Layout.paddingTopText
        local buttonHalf = (width - (2 * Layout.padding) - Layout.elementSpacing) / 2
        local buttonFull = width - (2 * Layout.padding)

        -- 5 BUTTONS
        local widthArrowSingle = Layout.elementHeight * 1.0
        local widthArrowDouble = Layout.elementHeight * 1.0
        local widthCenterLabel = width - (2 * Layout.padding) - (4 * Layout.elementSpacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

        local isRectangle = (CC.DrawShape.SV.shapeType == LUT.DRAW_SHAPE.RECTANGLE)

        -- INFO
        self.DrawShapeInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.DrawShapeInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.DrawShapeInfoLabel:GetTextHeight() + Layout.elementSpacing

        -- TOGGLE SHAPE
        self.DrawShapeButtonToggle:SetDimensions(buttonFull, Layout.elementHeight)
        self.DrawShapeButtonToggle:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + Layout.elementHeight + Layout.elementSpacing

        -- ROW X (WIDTH / DIAMETER)
        self.DrawShapeButtonMinus10X:SetDimensions(widthArrowDouble, Layout.elementHeight)
        self.DrawShapeButtonMinus10X:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.DrawShapeButtonMinus1X:SetDimensions(widthArrowSingle, Layout.elementHeight)
        self.DrawShapeButtonMinus1X:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus10X, TOPRIGHT, Layout.elementSpacing, 0)

        self.DrawShapeLabelValueX:SetDimensions(widthCenterLabel, Layout.elementHeight)
        self.DrawShapeLabelValueX:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus1X, TOPRIGHT, Layout.elementSpacing, 0)

        self.DrawShapeButtonPlus1X:SetDimensions(widthArrowSingle, Layout.elementHeight)
        self.DrawShapeButtonPlus1X:SetAnchor(TOPLEFT, self.DrawShapeLabelValueX, TOPRIGHT, Layout.elementSpacing, 0)

        self.DrawShapeButtonPlus10X:SetDimensions(widthArrowDouble, Layout.elementHeight)
        self.DrawShapeButtonPlus10X:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        innerY = innerY + Layout.elementHeight + Layout.elementSpacing

        -- ROW Z (LENGTH) - RECTANGLE
        if isRectangle then
            self.DrawShapeButtonMinus10Z:SetHidden(false)
            self.DrawShapeButtonMinus1Z:SetHidden(false)
            self.DrawShapeLabelValueZ:SetHidden(false)
            self.DrawShapeButtonPlus1Z:SetHidden(false)
            self.DrawShapeButtonPlus10Z:SetHidden(false)

            self.DrawShapeButtonMinus10Z:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.DrawShapeButtonMinus10Z:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.DrawShapeButtonMinus1Z:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.DrawShapeButtonMinus1Z:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus10Z, TOPRIGHT, Layout.elementSpacing, 0)

            self.DrawShapeLabelValueZ:SetDimensions(widthCenterLabel, Layout.elementHeight)
            self.DrawShapeLabelValueZ:SetAnchor(TOPLEFT, self.DrawShapeButtonMinus1Z, TOPRIGHT, Layout.elementSpacing, 0)

            self.DrawShapeButtonPlus1Z:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.DrawShapeButtonPlus1Z:SetAnchor(TOPLEFT, self.DrawShapeLabelValueZ, TOPRIGHT, Layout.elementSpacing, 0)

            self.DrawShapeButtonPlus10Z:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.DrawShapeButtonPlus10Z:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.elementHeight + Layout.elementSpacing
        else
            self.DrawShapeButtonMinus10Z:SetHidden(true)
            self.DrawShapeButtonMinus1Z:SetHidden(true)
            self.DrawShapeLabelValueZ:SetHidden(true)
            self.DrawShapeButtonPlus1Z:SetHidden(true)
            self.DrawShapeButtonPlus10Z:SetHidden(true)
        end

        -- PLACE BUTTONS
        self.DrawShapeButtonCursor:SetDimensions(buttonHalf, Layout.elementHeight)
        self.DrawShapeButtonCursor:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.DrawShapeButtonSelf:SetDimensions(buttonHalf, Layout.elementHeight)
        self.DrawShapeButtonSelf:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    -- [P] POINTER
    ProcessContainer(self.PointerContainer, function(Content, width)
        local innerY = Layout.paddingTopText -- TEXT

        -- INFO
        self.PointerInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.PointerInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.PointerInfoLabel:GetTextHeight() + Layout.elementSpacing

        -- BUTTONS
        local buttonHalf = (width - (2 * Layout.padding) - Layout.elementSpacing) / 2

        self.PointerButtonCursor:SetDimensions(buttonHalf, Layout.elementHeight)
        self.PointerButtonCursor:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.PointerButtonSelf:SetDimensions(buttonHalf, Layout.elementHeight)
        self.PointerButtonSelf:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    -- [R] RAIDLEAD TOOLS
    if isRaidlead then
        self.ContainerRaidleadTools.Control:SetHidden(false)
        ProcessContainer(self.ContainerRaidleadTools, function(Content, width)
            local innerY = Layout.paddingTopText
            local buttonHalf = (width - (2 * Layout.padding) - Layout.elementSpacing) / 2

            -- 5 BUTTONS
            local widthArrowSingle = Layout.elementHeight * 1.0
            local widthArrowDouble = Layout.elementHeight * 1.0
            local widthToggle = width - (2 * Layout.padding) - (4 * Layout.elementSpacing) - (2 * widthArrowSingle) - (2 * widthArrowDouble)

            -- INFO
            self.RaidleadToolsInfoLabel:SetDimensions(width - (2 * Layout.padding), 0)
            self.RaidleadToolsInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + self.RaidleadToolsInfoLabel:GetTextHeight() + Layout.elementSpacing

            -- WIPE AND PTE
            self.ButtonWipePlease:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonWipePlease:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonExitInstance:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonExitInstance:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing

            -- PORT IN AND PORT LEAD
            self.ButtonPortInPlease:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonPortInPlease:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonPortToLeader:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonPortToLeader:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing

            -- READYCHECK AND VOTE
            self.ButtonReadyCheck:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonReadyCheck:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ButtonVoteStart:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ButtonVoteStart:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.elementHeight + (Layout.elementSpacing * 2)

            ----------------------------------------------------------------------------------------------------
            -- BREAK
            ----------------------------------------------------------------------------------------------------
            self.BreakTimerButtonMinus5:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.BreakTimerButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.BreakTimerButtonMinus1:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.BreakTimerButtonMinus1:SetAnchor(TOPLEFT, self.BreakTimerButtonMinus5, TOPRIGHT, Layout.elementSpacing, 0)

            self.BreakTimerButtonToggle:SetDimensions(widthToggle, Layout.elementHeight)
            self.BreakTimerButtonToggle:SetAnchor(TOPLEFT, self.BreakTimerButtonMinus1, TOPRIGHT, Layout.elementSpacing, 0)

            self.BreakTimerButtonPlus1:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.BreakTimerButtonPlus1:SetAnchor(TOPLEFT, self.BreakTimerButtonToggle, TOPRIGHT, Layout.elementSpacing, 0)

            self.BreakTimerButtonPlus5:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.BreakTimerButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.elementHeight + (Layout.elementSpacing * 2)

            ----------------------------------------------------------------------------------------------------
            -- PULL TOGGLE
            ----------------------------------------------------------------------------------------------------
            self.PullTimerButtonMinus5:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.PullTimerButtonMinus5:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.PullTimerButtonMinus1:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.PullTimerButtonMinus1:SetAnchor(TOPLEFT, self.PullTimerButtonMinus5, TOPRIGHT, Layout.elementSpacing, 0)

            self.PullTimerButtonToggle:SetDimensions(widthToggle, Layout.elementHeight)
            self.PullTimerButtonToggle:SetAnchor(TOPLEFT, self.PullTimerButtonMinus1, TOPRIGHT, Layout.elementSpacing, 0)

            self.PullTimerButtonPlus1:SetDimensions(widthArrowSingle, Layout.elementHeight)
            self.PullTimerButtonPlus1:SetAnchor(TOPLEFT, self.PullTimerButtonToggle, TOPRIGHT, Layout.elementSpacing, 0)

            self.PullTimerButtonPlus5:SetDimensions(widthArrowDouble, Layout.elementHeight)
            self.PullTimerButtonPlus5:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            innerY = innerY + Layout.elementHeight + Layout.elementSpacing

            return innerY
        end)
    else
        self.ContainerRaidleadTools.Control:SetHidden(true)
    end

    -- [S] SLAYER ASSSISTANT
    ProcessContainer(self.ContainerSlayerAssistant, function(Content, width)
        local innerY = Layout.paddingTopText
        local buttonHalf = (width - (2 * Layout.padding) - Layout.elementSpacing) / 2
        local buttonFull = width - (2 * Layout.padding)

        self.SlayerAssistantPositionLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.SlayerAssistantPositionLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.SlayerAssistantPositionLabel:GetTextHeight() + Layout.elementSpacing

        self.SlayerAssistantButtonSetLeft:SetDimensions(buttonHalf, Layout.elementHeight)
        self.SlayerAssistantButtonSetLeft:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        self.SlayerAssistantButtonSetRight:SetDimensions(buttonHalf, Layout.elementHeight)
        self.SlayerAssistantButtonSetRight:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.elementHeight + Layout.elementSpacing

        if isRaidlead then
            self.SlayerAssistantButtonAssign:SetHidden(false)
            self.SlayerAssistantButtonStatus:SetHidden(false)
            self.SlayerAssistantButtonAssign:SetDimensions(buttonHalf, Layout.elementHeight)
            self.SlayerAssistantButtonAssign:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.SlayerAssistantButtonStatus:SetDimensions(buttonHalf, Layout.elementHeight)
            self.SlayerAssistantButtonStatus:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing

            self.SlayerAssistantButtonTrigger:SetHidden(false)
            self.SlayerAssistantButtonTrigger:SetDimensions(buttonFull, Layout.elementHeight)
            self.SlayerAssistantButtonTrigger:SetAnchor(TOP, Content, TOP, 0, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing
        else
            self.SlayerAssistantButtonAssign:SetHidden(true)
            self.SlayerAssistantButtonStatus:SetHidden(true)
            self.SlayerAssistantButtonTrigger:SetHidden(true)
        end

        for i = 1, self.activeSlayerSetUserLabels do
            local Label = self.SlayerSetUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end

        return innerY
    end)

    -- [K] ARKASIS ASSISTANT
    ProcessContainer(self.ContainerArkasisAssistant, function(Content, width)
        local innerY = Layout.paddingTopText
        local buttonHalf = (width - (2 * Layout.padding) - Layout.elementSpacing) / 2
        local buttonThird = (width - (2 * Layout.padding) - (2 * Layout.elementSpacing)) / 3
        local buttonFull = width - (2 * Layout.padding)

        self.ArkasisAssistantPositionLabel:SetDimensions(width - (2 * Layout.padding), 0)
        self.ArkasisAssistantPositionLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        innerY = innerY + self.ArkasisAssistantPositionLabel:GetTextHeight() + Layout.elementSpacing

        self.ArkasisAssistantButtonSet1:SetDimensions(buttonThird, Layout.elementHeight)
        self.ArkasisAssistantButtonSet1:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
        self.ArkasisAssistantButtonSet2:SetDimensions(buttonThird, Layout.elementHeight)
        self.ArkasisAssistantButtonSet2:SetAnchor(TOPLEFT, self.ArkasisAssistantButtonSet1, TOPRIGHT, Layout.elementSpacing, 0)
        self.ArkasisAssistantButtonSet3:SetDimensions(buttonThird, Layout.elementHeight)
        self.ArkasisAssistantButtonSet3:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
        innerY = innerY + Layout.elementHeight + Layout.elementSpacing

        if isRaidlead then
            self.ArkasisAssistantButtonAssign:SetHidden(false)
            self.ArkasisAssistantButtonStatus:SetHidden(false)
            self.ArkasisAssistantButtonAssign:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ArkasisAssistantButtonAssign:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            self.ArkasisAssistantButtonStatus:SetDimensions(buttonHalf, Layout.elementHeight)
            self.ArkasisAssistantButtonStatus:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing

            self.ArkasisAssistantButtonTrigger:SetHidden(false)
            self.ArkasisAssistantButtonTrigger:SetDimensions(buttonFull, Layout.elementHeight)
            self.ArkasisAssistantButtonTrigger:SetAnchor(TOP, Content, TOP, 0, innerY)
            innerY = innerY + Layout.elementHeight + Layout.elementSpacing
        else
            self.ArkasisAssistantButtonAssign:SetHidden(true)
            self.ArkasisAssistantButtonStatus:SetHidden(true)
            self.ArkasisAssistantButtonTrigger:SetHidden(true)
        end

        for i = 1, self.activeArkasisUserLabels do
            local Label = self.ArkasisUserLabels[i]
            Label:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)
            innerY = innerY + Label:GetTextHeight()
        end

        return innerY
    end)

    -- AUTHOR
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
    self.SV.isOpenSlayerAssistant  = false
    self.SV.isOpenArkasisAssistant = false
    self.SV.isOpenPointer          = false
    self.SV.isOpenRaidleadTools    = false
    self.SV.isOpenDrawShape        = false
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

    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "CC_DisplayPanel_UpdateData", 1000, function() self:UpdateData() end)
end

function Module:CustomDisable()
    self:Hide()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "CC_DisplayPanel_UpdateData")
end

----------------------------------------------------------------------------------------------------
-- REGISTER MODULE / SLASH COMMAND
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)

SLASH_COMMANDS["/cc_panel"] = function() CC.DisplayPanel:Toggle() end