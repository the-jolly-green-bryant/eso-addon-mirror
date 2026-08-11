local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayDialog",
    Parent = nil,
    Fragment = nil,

    Buttons = {},

    Data = {
        slayerZoneId = 0,
        arkasisZoneId = 0,
        leaderName = "",
    },

    isVisible = false,
    isInstallCheckRequested = false,
    installCheckState = 0,

    isSlayerRequested = false,
    isArkasisRequested = false,
    isExitInstanceRequested = false,
    isPortToLeaderRequested = false,
    isVoteRequested = false,

    -------------------------------------------------------------------------------------------------
    -- COLORS
    -------------------------------------------------------------------------------------------------
    GN_NORMAL    = { 0, 1, 0, 1 },
    RD_NORMAL    = { 1, 0, 0, 1 },
    BL_NORMAL    = { 0, 0.5, 1, 1 },
    YL_NORMAL    = { 1, 0.875, 0, 1 },

    OG_HIGHLIGHT  = { 1,    0.75,  0.5,  1 },
    OG_BRIGHT     = { 1,    0.625, 0.25, 1 },
    OG_NORMAL     = { 1,    0.5,   0,    1 },
    OG_MUTED      = { 0.75, 0.375, 0,    1 },
    OG_DARK       = { 0.5,  0.25,  0,    1 },

    ESO_HIGHLIGHT = { 1 / 255 * 239, 1 / 255 * 235, 1 / 255 * 190, 1 },
    ESO_NORMAL    = { 1 / 255 * 197, 1 / 255 * 194, 1 / 255 * 158, 1 },
    ESO_MUTED     = { 1 / 255 * 148, 1 / 255 * 143, 1 / 255 * 115, 1 },

    -------------------------------------------------------------------------------------------------
    -- LAYOUT
    -------------------------------------------------------------------------------------------------
    Layout = {
        width            = 400,
        margin           = 10,  -- DISTANCE TO EDGES AND BETWEEN CONTAINERS
        padding          = 10,  -- DISTANCE INSIDE CONTAINER
        headerHeight     = 24,  -- HEIGHT OF THE CONTAINER HEADER
        elementHeight    = 28,  -- HEIGHT OF BUTTONS
        elementSpacing   = 5,   -- DISTANCE BETWEEN ELEMENTS
    },

    Font = {
        Title         = "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick",
        SubTitle      = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thick",
        Button        = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick",
        Normal        = "$(BOLD_FONT)|$(KB_16)|soft-shadow-thick",
        Small         = "$(BOLD_FONT)|$(KB_14)|soft-shadow-thick",
    },

    Default = {
        offsetX = nil,
        offsetY = nil,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CREATE DIALOG
----------------------------------------------------------------------------------------------------
function Module:CreateDialog()
    if self.Parent then return end

    -- MAIN WINDOW
    self.Parent = WINDOW_MANAGER:CreateTopLevelWindow("CC_DisplayDialog_Parent")
    self.Parent:SetDimensions(self.Layout.width, 100)
    self.Parent:SetClampedToScreen(true)
    self.Parent:SetMouseEnabled(true)
    self.Parent:SetMovable(true)
    self.Parent:SetDrawTier(DT_HIGH)
    self.Parent:SetHidden(true)

    self:ApplyAnchor()

    self.Parent:SetHandler("OnMoveStop", function(control)
        self.SV.offsetX = control:GetLeft()
        self.SV.offsetY = control:GetTop()
    end)

    -- BACKGROUND
    self.Background = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_Background", self.Parent, CT_BACKDROP)
    self.Background:SetAnchorFill()
    self.Background:SetPixelRoundingEnabled(true)
    self.Background:SetCenterColor(0, 0, 0, 0.75)
    self.Background:SetEdgeColor(unpack(self.OG_DARK))
    self.Background:SetEdgeTexture("", 1, 1, 2)

    -- MAIN TITLE
    self.MainTitle = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_Title", self.Parent, CT_LABEL)
    self.MainTitle:SetFont(self.Font.Title)
    self.MainTitle:SetColor(unpack(self.OG_NORMAL))
    self.MainTitle:SetText("|cFF7F00COMBAT|r |cFFFFFFCOORDINATION|r")
    self.MainTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.MainTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.MainTitle:SetAnchor(TOP, self.Parent, TOP, 0, self.Layout.margin)

    -- CLOSE BUTTON (X ICON)
    local ButtonClose = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_Close", self.Parent, CT_BUTTON)
    ButtonClose:SetDimensions(20, 20)
    ButtonClose:SetAnchor(TOPRIGHT, self.Parent, TOPRIGHT, -self.Layout.margin, self.Layout.margin)
    ButtonClose:SetState(BSTATE_NORMAL)
    ButtonClose:SetClickSound("Click")

    local ButtonCloseIcon = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_CloseIcon", ButtonClose, CT_TEXTURE)
    ButtonCloseIcon:SetAnchorFill()
    ButtonCloseIcon:SetTexture("CombatCoordination/icons/close.dds")
    ButtonCloseIcon:SetColor(unpack(self.ESO_MUTED))

    ButtonClose:SetHandler("OnMouseEnter", function() ButtonCloseIcon:SetColor(unpack(self.ESO_HIGHLIGHT)) end)
    ButtonClose:SetHandler("OnMouseExit", function() ButtonCloseIcon:SetColor(unpack(self.ESO_MUTED)) end)
    ButtonClose:SetHandler("OnMouseUp", function() self:HideAll() end)

    ButtonClose.ResetVisuals = function()
        ButtonCloseIcon:SetColor(unpack(self.ESO_MUTED))
        ButtonClose:SetState(BSTATE_NORMAL)
    end
    table.insert(self.Buttons, ButtonClose)
    self.ButtonClose = ButtonClose

    -- BUILD CONTAINERS
    self:BuildSlayerContainer()
    self:BuildArkasisContainer()
    self:BuildExitInstanceContainer()
    self:BuildPortToLeaderContainer()
    self:BuildVoteContainer()
    self:BuildInstallCheckContainer()

    -- SCENE FRAGMENT
    self.Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    self.Fragment:SetConditional(function() return self.isVisible end)
end

----------------------------------------------------------------------------------------------------
-- BUTTON
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

    Button.customCallback = callback
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

    -- INIT DEFAULT
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

    Button.ResetVisuals = function()
        SetEdge(1)
        Background:SetEdgeColor(unpack(self.ESO_MUTED))
        Button:SetState(BSTATE_NORMAL)
    end
    table.insert(self.Buttons, Button)

    return Button
end

----------------------------------------------------------------------------------------------------
-- CONTAINER
----------------------------------------------------------------------------------------------------
function Module:CreateStaticContainer(name, titleText)
    local Container = WINDOW_MANAGER:CreateControl(name, self.Parent, CT_BACKDROP)
    Container:SetPixelRoundingEnabled(true)
    Container:SetCenterColor(0, 0, 0, 0.5)
    Container:SetEdgeColor(unpack(self.OG_MUTED))
    Container:SetEdgeTexture("", 1, 1, 1)

    -- HEADER
    local Header = WINDOW_MANAGER:CreateControl(name .. "_Header", Container, CT_CONTROL)
    Header:SetAnchor(TOPLEFT, Container, TOPLEFT, 0, 0)
    Header:SetAnchor(TOPRIGHT, Container, TOPRIGHT, 0, 0)
    Header:SetHeight(self.Layout.headerHeight)

    -- HEADER TITLE
    local Title = WINDOW_MANAGER:CreateControl(name .. "_Title", Header, CT_LABEL)
    Title:SetFont(self.Font.SubTitle)
    Title:SetColor(unpack(self.OG_BRIGHT))
    Title:SetAnchor(LEFT, Header, LEFT, self.Layout.padding, 0)
    Title:SetAnchor(RIGHT, Header, RIGHT, -self.Layout.padding, 0)
    Title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    Title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    Title:SetText(titleText)

    -- CONTENT
    local Content = WINDOW_MANAGER:CreateControl(name .. "_Content", Container, CT_CONTROL)
    Content:SetAnchor(TOPLEFT, Header, BOTTOMLEFT, 0, 0)
    Content:SetAnchor(TOPRIGHT, Header, BOTTOMRIGHT, 0, 0)

    return {
        Control = Container,
        Header = Header,
        Title = Title,
        Content = Content,
    }
end

----------------------------------------------------------------------------------------------------
-- SAVE POSITION / RESTORE
----------------------------------------------------------------------------------------------------
function Module:ApplyAnchor()
    if not self.Parent then return end
    self.Parent:ClearAnchors()

    if self.SV.offsetX and self.SV.offsetY then
        self.Parent:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.offsetX, self.SV.offsetY)
    else
        self.Parent:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

----------------------------------------------------------------------------------------------------
-- CHECK FOR MISSING TEXTURES
----------------------------------------------------------------------------------------------------
function Module:BuildInstallCheckContainer()
    self.ContainerInstallCheck = self:CreateStaticContainer("CC_DisplayDialog_ContainerInstallCheck", "INSTALLATION CHECK")
    local Content = self.ContainerInstallCheck.Content

    self.InstallInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_InstallInfoLabel", Content, CT_LABEL)
    self.InstallInfoLabel:SetFont(self.Font.Normal)
    self.InstallInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.InstallInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.InstallInfoLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)

    self.InstallTexture = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_InstallTexture", Content, CT_TEXTURE)
    self.InstallTexture:SetTexture("CombatCoordination/icons/combatcoordination.dds")

    self.ButtonInstallYes = self:CreateButton("CC_DisplayDialog_ButtonInstallYes", Content, "YES, I SEE IT", function()
        CC.SV.areTexturesVisible = true
        d(string.format("%s Installation verified. Welcome to Combat Coordination!", CC.CHAT))
        self.isInstallCheckRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonInstallYes:SetCustomColors(self.GN_NORMAL)

    self.ButtonInstallNo = self:CreateButton("CC_DisplayDialog_ButtonInstallNo", Content, "NO, IT'S INVISIBLE", function()
        CC.SV.areTexturesVisible = false
        self.installCheckState = 1 -- ERROR STATUS
        self:UpdateDimensions()
        d(string.format("%s |cFF0000ERROR:|r Please restart the game to load missing textures.", CC.CHAT))
    end)
    self.ButtonInstallNo:SetCustomColors(self.RD_NORMAL)

    self.ButtonInstallClose = self:CreateButton("CC_DisplayDialog_ButtonInstallClose", Content, "CLOSE & RESTART LATER", function()
        CC.SV.areTexturesVisible = false
        self.isInstallCheckRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonInstallClose:SetCustomColors(self.YL_NORMAL)
end

----------------------------------------------------------------------------------------------------
-- SLAYER CONTAINER
----------------------------------------------------------------------------------------------------
function Module:BuildSlayerContainer()
    self.ContainerSlayer = self:CreateStaticContainer("CC_DisplayDialog_ContainerSlayer", "SLAYER STACK")
    local Content = self.ContainerSlayer.Content

    self.SlayerInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_SlayerInfoLabel", Content, CT_LABEL)
    self.SlayerInfoLabel:SetFont(self.Font.Normal)
    self.SlayerInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.SlayerInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.SlayerInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ButtonSlayerLeft = self:CreateButton("CC_DisplayDialog_ButtonSlayerLeft", Content, "LEFT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_LEFT, self.Data.slayerZoneId)
        self.isSlayerRequested = false
        self:UpdateDimensions()
    end)

    self.ButtonSlayerRight = self:CreateButton("CC_DisplayDialog_ButtonSlayerRight", Content, "RIGHT", function()
        CC.SlayerAssistant:AssignPlayerSide(CC.SlayerAssistant.SIDE_RIGHT, self.Data.slayerZoneId)
        self.isSlayerRequested = false
        self:UpdateDimensions()
    end)
end

----------------------------------------------------------------------------------------------------
-- ARKASIS CONTAINER
----------------------------------------------------------------------------------------------------
function Module:BuildArkasisContainer()
    self.ContainerArkasis = self:CreateStaticContainer("CC_DisplayDialog_ContainerArkasis", "ARKASIS STACK")
    local Content = self.ContainerArkasis.Content

    self.ArkasisInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_ArkasisInfoLabel", Content, CT_LABEL)
    self.ArkasisInfoLabel:SetFont(self.Font.Normal)
    self.ArkasisInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.ArkasisInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.ArkasisInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ButtonArkasis1 = self:CreateButton("CC_DisplayDialog_ButtonArkasis1", Content, "STACK 1", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_1, self.Data.arkasisZoneId)
        self.isArkasisRequested = false
        self:UpdateDimensions()
    end)

    self.ButtonArkasis2 = self:CreateButton("CC_DisplayDialog_ButtonArkasis2", Content, "STACK 2", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_2, self.Data.arkasisZoneId)
        self.isArkasisRequested = false
        self:UpdateDimensions()
    end)

    self.ButtonArkasis3 = self:CreateButton("CC_DisplayDialog_ButtonArkasis3", Content, "STACK 3", function()
        CC.ArkasisAssistant:AssignPlayerSide(CC.ArkasisAssistant.SIDE_3, self.Data.arkasisZoneId)
        self.isArkasisRequested = false
        self:UpdateDimensions()
    end)
end

----------------------------------------------------------------------------------------------------
-- EXIT INSTANCE CONTAINER
----------------------------------------------------------------------------------------------------
function Module:BuildExitInstanceContainer()
    self.ContainerExitInstance = self:CreateStaticContainer("CC_DisplayDialog_ContainerExitInstance", "EXIT INSTANCE")
    local Content = self.ContainerExitInstance.Content

    self.ExitInstanceInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_ExitInstanceInfoLabel", Content, CT_LABEL)
    self.ExitInstanceInfoLabel:SetFont(self.Font.Normal)
    self.ExitInstanceInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.ExitInstanceInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.ExitInstanceInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.ExitInstanceInfoLabel:SetText("Group leader requested exit instance.\nConfirm P-T-E")

    self.ButtonExitInstanceConfirm = self:CreateButton("CC_DisplayDialog_ButtonExitInstanceConfirm", Content, "CONFIRM", function()
        ExitInstanceImmediately()
        self.isExitInstanceRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonExitInstanceConfirm:SetCustomColors(self.GN_NORMAL)

    self.ButtonExitInstanceDecline = self:CreateButton("CC_DisplayDialog_ButtonExitInstanceDecline", Content, "DECLINE", function()
        self.isExitInstanceRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonExitInstanceDecline:SetCustomColors(self.RD_NORMAL)
end

----------------------------------------------------------------------------------------------------
-- PORT TO LEADER CONTAINER
----------------------------------------------------------------------------------------------------
function Module:BuildPortToLeaderContainer()
    self.ContainerPortToLeader = self:CreateStaticContainer("CC_DisplayDialog_ContainerPortToLeader", "PORT TO LEADER")
    local Content = self.ContainerPortToLeader.Content

    self.PortToLeaderInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_PortToLeaderInfoLabel", Content, CT_LABEL)
    self.PortToLeaderInfoLabel:SetFont(self.Font.Normal)
    self.PortToLeaderInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.PortToLeaderInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.PortToLeaderInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.ButtonPortToLeaderConfirm = self:CreateButton("CC_DisplayDialog_ButtonPortToLeaderConfirm", Content, "CONFIRM", function()
        if self.Data.leaderName ~= "" then
            JumpToGroupMember(self.Data.leaderName)
        end
        self.isPortToLeaderRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonPortToLeaderConfirm:SetCustomColors(self.GN_NORMAL)

    self.ButtonPortToLeaderDecline = self:CreateButton("CC_DisplayDialog_ButtonPortToLeaderDecline", Content, "DECLINE", function()
        self.isPortToLeaderRequested = false
        self:UpdateDimensions()
    end)
    self.ButtonPortToLeaderDecline:SetCustomColors(self.RD_NORMAL)
end

----------------------------------------------------------------------------------------------------
-- VOTE CONTAINER
----------------------------------------------------------------------------------------------------
function Module:BuildVoteContainer()
    self.ContainerVote = self:CreateStaticContainer("CC_DisplayDialog_ContainerVote", "GROUP VOTE")
    local Content = self.ContainerVote.Content

    self.VoteInfoLabel = WINDOW_MANAGER:CreateControl("CC_DisplayDialog_VoteInfoLabel", Content, CT_LABEL)
    self.VoteInfoLabel:SetFont(self.Font.Normal)
    self.VoteInfoLabel:SetColor(unpack(self.ESO_NORMAL))
    self.VoteInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.VoteInfoLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.VoteInfoLabel:SetText("Group leader initiated a vote.")

    self.ButtonVoteYes = self:CreateButton("CC_DisplayDialog_ButtonVoteYes", Content, "YES", function()
        self.isVoteRequested = false
        CC.RaidleadTools:SendVoteReply(1)
        self:UpdateDimensions()
    end)
    self.ButtonVoteYes:SetCustomColors(self.GN_NORMAL)

    self.ButtonVoteNo = self:CreateButton("CC_DisplayDialog_ButtonVoteNo", Content, "NO", function()
        self.isVoteRequested = false
        CC.RaidleadTools:SendVoteReply(2)
        self:UpdateDimensions()
    end)
    self.ButtonVoteNo:SetCustomColors(self.RD_NORMAL)

    self.ButtonVoteAbstain = self:CreateButton("CC_DisplayDialog_ButtonVoteAbstain", Content, "IDC", function()
        self.isVoteRequested = false
        CC.RaidleadTools:SendVoteReply(3)
        self:UpdateDimensions()
    end)
    self.ButtonVoteAbstain:SetCustomColors(self.YL_NORMAL)
end

----------------------------------------------------------------------------------------------------
-- LAYOUT / DIMENSIONS
----------------------------------------------------------------------------------------------------
function Module:UpdateDimensions()
    if not self.Buttons then return end
    for _, Button in ipairs(self.Buttons) do
        if Button.ResetVisuals then Button:ResetVisuals() end
    end

    -- NOTHING REQUESTED -> HIDE!
    if not self.isSlayerRequested
    and not self.isArkasisRequested
    and not self.isExitInstanceRequested
    and not self.isPortToLeaderRequested
    and not self.isVoteRequested
    and not self.isInstallCheckRequested then
        self:HideAll()
        return
    end

    local Layout = self.Layout
    local contentWidth = Layout.width - (Layout.margin * 2)
    local currentY = Layout.margin + self.MainTitle:GetTextHeight() + Layout.margin

    local function ProcessContainer(Container, isRequested, LayoutContentFunc)
        if isRequested then
            Container.Control:SetHidden(false)
            Container.Control:SetAnchor(TOPLEFT, self.Parent, TOPLEFT, Layout.margin, currentY)
            Container.Control:SetAnchor(TOPRIGHT, self.Parent, TOPRIGHT, -Layout.margin, currentY)

            local contentHeight = LayoutContentFunc(Container.Content, contentWidth)
            local totalHeight = Layout.headerHeight + contentHeight + Layout.padding

            Container.Control:SetHeight(totalHeight)
            currentY = currentY + totalHeight + Layout.margin
        else
            Container.Control:SetHidden(true)
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- INSTALLATION CHECK
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerInstallCheck, self.isInstallCheckRequested, function(Content, width)
        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.InstallInfoLabel:ClearAnchors()
        self.InstallTexture:ClearAnchors()
        self.ButtonInstallYes:ClearAnchors()
        self.ButtonInstallNo:ClearAnchors()
        self.ButtonInstallClose:ClearAnchors()

        if self.installCheckState == 0 then
            -- CHECK .. 0
            local textureSize = 64
            local labelWidth = availableWidth - textureSize - Layout.elementSpacing

            self.InstallInfoLabel:SetDimensions(labelWidth, 0)
            self.InstallInfoLabel:SetText("|cFF7F00Welcome to Combat Coordination!|r\n\n" ..
                                          "Textures only load after a full restart.\n" ..
                                          "A simple /reloadui is not enough.\n\n" ..
                                          "Do you see the icon on the right?")

            self.InstallInfoLabel:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.InstallTexture:SetHidden(false)
            self.InstallTexture:SetDimensions(textureSize, textureSize)
            self.InstallTexture:SetAnchor(LEFT, self.InstallInfoLabel, RIGHT, Layout.elementSpacing, 0)

            local contentHeight = math.max(self.InstallInfoLabel:GetTextHeight(), textureSize)
            innerY = innerY + contentHeight + Layout.padding

            local buttonWidth = (availableWidth - Layout.elementSpacing) / 2

            self.ButtonInstallYes:SetHidden(false)
            self.ButtonInstallYes:SetDimensions(buttonWidth, Layout.elementHeight)
            self.ButtonInstallYes:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

            self.ButtonInstallNo:SetHidden(false)
            self.ButtonInstallNo:SetDimensions(buttonWidth, Layout.elementHeight)
            self.ButtonInstallNo:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

            self.ButtonInstallClose:SetHidden(true)

            return innerY + Layout.elementHeight
        else
            -- ERROR (NO TEXTURE) .. 1
            self.InstallInfoLabel:SetDimensions(availableWidth, 0)
            self.InstallInfoLabel:SetText("|cFF0000ERROR: Missing Textures!|r\n\n" ..
                                          "Please restart the game completely.\n" ..
                                          "This prompt will reappear upon login.")
            self.InstallInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)

            self.InstallTexture:SetHidden(true)

            innerY = innerY + self.InstallInfoLabel:GetTextHeight() + Layout.padding

            self.ButtonInstallYes:SetHidden(true)
            self.ButtonInstallNo:SetHidden(true)

            self.ButtonInstallClose:SetHidden(false)
            self.ButtonInstallClose:SetDimensions(availableWidth, Layout.elementHeight)
            self.ButtonInstallClose:SetAnchor(TOP, Content, TOP, 0, innerY)

            return innerY + Layout.elementHeight
        end
    end)

    ----------------------------------------------------------------------------------------------------
    -- SLAYER
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerSlayer, self.isSlayerRequested, function(Content, width)
        self.SlayerInfoLabel:ClearAnchors()
        self.ButtonSlayerLeft:ClearAnchors()
        self.ButtonSlayerRight:ClearAnchors()

        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.SlayerInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + self.SlayerInfoLabel:GetTextHeight() + Layout.padding

        local buttonWidth = (availableWidth - Layout.elementSpacing) / 2
        self.ButtonSlayerLeft:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonSlayerLeft:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.ButtonSlayerRight:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonSlayerRight:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    ----------------------------------------------------------------------------------------------------
    -- ARKASIS
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerArkasis, self.isArkasisRequested, function(Content, width)
        self.ArkasisInfoLabel:ClearAnchors()
        self.ButtonArkasis1:ClearAnchors()
        self.ButtonArkasis2:ClearAnchors()
        self.ButtonArkasis3:ClearAnchors()

        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.ArkasisInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + self.ArkasisInfoLabel:GetTextHeight() + Layout.padding

        local buttonWidth = (availableWidth - (2 * Layout.elementSpacing)) / 3
        self.ButtonArkasis1:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonArkasis1:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.ButtonArkasis2:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonArkasis2:SetAnchor(TOPLEFT, self.ButtonArkasis1, TOPRIGHT, Layout.elementSpacing, 0)

        self.ButtonArkasis3:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonArkasis3:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    ----------------------------------------------------------------------------------------------------
    -- EXIT INSTANCE
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerExitInstance, self.isExitInstanceRequested, function(Content, width)
        self.ExitInstanceInfoLabel:ClearAnchors()
        self.ButtonExitInstanceConfirm:ClearAnchors()
        self.ButtonExitInstanceDecline:ClearAnchors()

        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.ExitInstanceInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + self.ExitInstanceInfoLabel:GetTextHeight() + Layout.padding

        local buttonWidth = (availableWidth - Layout.elementSpacing) / 2
        self.ButtonExitInstanceConfirm:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonExitInstanceConfirm:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.ButtonExitInstanceDecline:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonExitInstanceDecline:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    ----------------------------------------------------------------------------------------------------
    -- PORT TO LEADER
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerPortToLeader, self.isPortToLeaderRequested, function(Content, width)
        self.PortToLeaderInfoLabel:ClearAnchors()
        self.ButtonPortToLeaderConfirm:ClearAnchors()
        self.ButtonPortToLeaderDecline:ClearAnchors()

        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.PortToLeaderInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + self.PortToLeaderInfoLabel:GetTextHeight() + Layout.padding

        local buttonWidth = (availableWidth - Layout.elementSpacing) / 2
        self.ButtonPortToLeaderConfirm:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonPortToLeaderConfirm:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.ButtonPortToLeaderDecline:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonPortToLeaderDecline:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    ----------------------------------------------------------------------------------------------------
    -- VOTE LAYOUT
    ----------------------------------------------------------------------------------------------------
    ProcessContainer(self.ContainerVote, self.isVoteRequested, function(Content, width)
        self.VoteInfoLabel:ClearAnchors()
        self.ButtonVoteYes:ClearAnchors()
        self.ButtonVoteNo:ClearAnchors()
        self.ButtonVoteAbstain:ClearAnchors()

        local innerY = Layout.padding
        local availableWidth = width - (2 * Layout.padding)

        self.VoteInfoLabel:SetAnchor(TOP, Content, TOP, 0, innerY)
        innerY = innerY + self.VoteInfoLabel:GetTextHeight() + Layout.padding

        local buttonWidth = (availableWidth - (2 * Layout.elementSpacing)) / 3
        self.ButtonVoteYes:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonVoteYes:SetAnchor(TOPLEFT, Content, TOPLEFT, Layout.padding, innerY)

        self.ButtonVoteNo:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonVoteNo:SetAnchor(TOPLEFT, self.ButtonVoteYes, TOPRIGHT, Layout.elementSpacing, 0)

        self.ButtonVoteAbstain:SetDimensions(buttonWidth, Layout.elementHeight)
        self.ButtonVoteAbstain:SetAnchor(TOPRIGHT, Content, TOPRIGHT, -Layout.padding, innerY)

        return innerY + Layout.elementHeight
    end)

    -- UPDATE PARENT DIMENS
    self.Parent:SetHeight(currentY)
end

----------------------------------------------------------------------------------------------------
-- TRIGGER FUNCTIONS
----------------------------------------------------------------------------------------------------
function Module:RequestSlayer(zoneId, zoneName, sideName)
    if not self.Parent then self:CreateDialog() end

    self.Data.slayerZoneId = zoneId
    self.isSlayerRequested = true

    self.SlayerInfoLabel:SetText(string.format("Position confirmation required for |cFFFFFF[%s]|r.\nCurrent parameter: %s", zoneName, sideName))

    local ColorLeft = CC.SlayerAssistant.SV.ColorLeft or {1, 0, 0, 1}
    local ColorRight = CC.SlayerAssistant.SV.ColorRight or {0, 0.5, 1, 1}

    self.ButtonSlayerLeft:SetCustomColors(ColorLeft)
    self.ButtonSlayerRight:SetCustomColors(ColorRight)

    self:Show()
end

function Module:RequestArkasis(zoneId, zoneName, sideName)
    if not self.Parent then self:CreateDialog() end

    self.Data.arkasisZoneId = zoneId
    self.isArkasisRequested = true

    self.ArkasisInfoLabel:SetText(string.format("Position confirmation required for |cFFFFFF[%s]|r.\nCurrent parameter: %s", zoneName, sideName))

    local ColorNormal = CC.ArkasisAssistant.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or CC.ArkasisAssistant.SV.Color or {1, 0.875, 0, 1}

    self.ButtonArkasis1:SetCustomColors(ColorNormal)
    self.ButtonArkasis2:SetCustomColors(ColorNormal)
    self.ButtonArkasis3:SetCustomColors(ColorNormal)

    self:Show()
end

function Module:RequestExitInstance()
    if not self.Parent then self:CreateDialog() end

    self.isExitInstanceRequested = true

    self.ButtonExitInstanceConfirm:SetText("CONFIRM")
    self.ButtonExitInstanceDecline:SetText("DECLINE")

    self:Show()
end

function Module:RequestPortToLeader(characterName, displayName)
    if not self.Parent then self:CreateDialog() end

    self.Data.leaderName = characterName
    self.isPortToLeaderRequested = true

    self.PortToLeaderInfoLabel:SetText(string.format("%s requested port to leader.\nConfirm travel.", displayName))

    self.ButtonPortToLeaderConfirm:SetText("CONFIRM")
    self.ButtonPortToLeaderDecline:SetText("DECLINE")

    self:Show()
end

function Module:RequestVote()
    if not self.Parent then self:CreateDialog() end

    self.isVoteRequested = true

    self.ButtonVoteYes:SetText("YES")
    self.ButtonVoteNo:SetText("NO")

    self:Show()
end

----------------------------------------------------------------------------------------------------
-- RESET BUTTON VISUALS
----------------------------------------------------------------------------------------------------
function Module:ResetAllButtons()
    if not self.Buttons then return end
    for _, Button in ipairs(self.Buttons) do
        if Button.ResetVisuals then Button:ResetVisuals() end
    end
end

----------------------------------------------------------------------------------------------------
-- INSTALL CHECK
----------------------------------------------------------------------------------------------------
function Module:RequestInstallCheck()
    if not self.Parent then self:CreateDialog() end

    self.isInstallCheckRequested = true
    self.installCheckState = 0

    self:Show()
end

----------------------------------------------------------------------------------------------------
-- SHOW / HIDE
----------------------------------------------------------------------------------------------------
function Module:Show()
    self:ResetAllButtons()

    if not self.isVisible then
        self:ApplyAnchor()
    end

    self:UpdateDimensions()
    self.isVisible = true
    self.Parent:SetHidden(false)

    if not HUD_SCENE:HasFragment(self.Fragment) then
        HUD_SCENE:AddFragment(self.Fragment)
    end
    if not HUD_UI_SCENE:HasFragment(self.Fragment) then
        HUD_UI_SCENE:AddFragment(self.Fragment)
    end

    SCENE_MANAGER:SetInUIMode(true)
end

----------------------------------------------------------------------------------------------------
-- HIDE ALL
----------------------------------------------------------------------------------------------------
function Module:HideAll()
    if not self.Parent then return end

    self:ResetAllButtons()
    self.isVisible = false
    self.isSlayerRequested = false
    self.isArkasisRequested = false
    self.isExitInstanceRequested = false
    self.isPortToLeaderRequested = false
    self.isVoteRequested = false
    self.isInstallCheckRequested = false
    self.installCheckState = 0

    self.Parent:SetHidden(true)

    if HUD_SCENE:HasFragment(self.Fragment) then
        HUD_SCENE:RemoveFragment(self.Fragment)
    end
    if HUD_UI_SCENE:HasFragment(self.Fragment) then
        HUD_UI_SCENE:RemoveFragment(self.Fragment)
    end

    SCENE_MANAGER:SetInUIMode(false)
end

----------------------------------------------------------------------------------------------------
-- MODULE REGISTRATION
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)