-- TTDungeon_UI.lua
-- User interface creation and management

TTDungeon = TTDungeon or {}

-- ================================================================================
-- Main UI Creation
-- ================================================================================

function TTDungeon.CreateMainUI()
    local sv = TTDungeon.savedVars
    TTDungeon.Debug("Creating Main UI..")

    local WINDOW_WIDTH         = 280
    local HEADER_HEIGHT        = 55
    local ESO_BORDER_THICKNESS = 8

    -- Main Window
    local ui = CreateControl("TTDungeonUI", GuiRoot, CT_TOPLEVELCONTROL)
    ui:SetDimensions(WINDOW_WIDTH, sv.expandedHeight)
    ui:SetClampedToScreen(true)
    ui:SetMouseEnabled(true)
    ui:SetMovable(not sv.lockUI)
    ui:SetHidden(true)
    ui:ClearAnchors()
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.offsetX, sv.offsetY)
    
    ui:SetHandler("OnMoveStop", function()
        if not sv.lockUI then
            sv.offsetX = ui:GetLeft()
            sv.offsetY = ui:GetTop()
        end
    end)
    TTDungeon.uiControl = ui

    -- Scene fragment for ESO's UI system
    local uiFragment = ZO_HUDFadeSceneFragment:New(ui)
    TTDungeon.uiFragment = uiFragment

    -- Window Background
    local backdrop = CreateControl(nil, ui, CT_BACKDROP)
    backdrop:SetAnchorFill(ui)
    backdrop:SetCenterTexture("EsoUI/Art/Miscellaneous/inset_bg.dds")
    backdrop:SetCenterColor(0, 0, 0, sv.backgroundAlpha or 0.8)
    backdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/inset_frame.dds", 256, 256, ESO_BORDER_THICKNESS)
    backdrop:SetEdgeColor(0.9, 0.9, 0.9, 1)
    backdrop:SetInsets(ESO_BORDER_THICKNESS, ESO_BORDER_THICKNESS, -ESO_BORDER_THICKNESS, -ESO_BORDER_THICKNESS)
    TTDungeon.bg = backdrop

    -- Header
    local header = CreateControl("TTDungeon_Header", ui, CT_CONTROL)
    header:SetDimensions(WINDOW_WIDTH - 2 * ESO_BORDER_THICKNESS, HEADER_HEIGHT)
    header:SetAnchor(TOPLEFT, ui, TOPLEFT, ESO_BORDER_THICKNESS, ESO_BORDER_THICKNESS)
    TTDungeon.header = header

    local headerDivider = CreateControl(nil, header, CT_TEXTURE)
    headerDivider:SetAnchor(BOTTOMLEFT, header, BOTTOMLEFT, 0, 0)
    headerDivider:SetAnchor(BOTTOMRIGHT, header, BOTTOMRIGHT, 0, 0)
    headerDivider:SetHeight(2)
    headerDivider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    headerDivider:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
    headerDivider:SetColor(0.8, 0.7, 0.4, 0.8)

    -- Title
    local title = CreateControl(nil, header, CT_LABEL)
    title:SetAnchor(TOPLEFT, header, TOPLEFT, 10, 4)
    title:SetFont("$(BOLD_FONT)|$(KB_22)|soft-shadow-thick")
    title:SetText("|cFFD700TT|r|cDDDDDDDungeon|r")

    -- Minimize Button
    local miniBtn = CreateControl(nil, header, CT_BUTTON)
    miniBtn:SetDimensions(26, 26)
    miniBtn:SetAnchor(TOPRIGHT, header, TOPRIGHT, -4, 3)
    miniBtn:SetFont("ZoFontWinH3")
    miniBtn:SetText(TTDungeon.isMinimized and "+" or "-")
    miniBtn:SetNormalFontColor(0.8, 0.8, 0.8, 1)
    miniBtn:SetMouseOverFontColor(1, 0.84, 0, 1)
    miniBtn:SetPressedFontColor(0.6, 0.6, 0.6, 1)
    miniBtn:SetHandler("OnClicked", function()
        TTDungeon.wasManuallyMinimized = not TTDungeon.isMinimized
        TTDungeon.ToggleMinimized()
    end)
    TTDungeon.minimizeButton = miniBtn

    -- Dungeon Selector Dropdown
    local selectorButton = CreateControl(nil, header, CT_BUTTON)
    selectorButton:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
    selectorButton:SetDimensions(WINDOW_WIDTH - 2 * ESO_BORDER_THICKNESS - 35, 24)
    selectorButton:SetFont("$(MEDIUM_FONT)|$(KB_15)")
    selectorButton:SetMouseEnabled(true)
    selectorButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    selectorButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    selectorButton:SetText("  Select Dungeon...")
    selectorButton:SetHidden(false)
    selectorButton:SetNormalFontColor(0.8, 0.8, 0.8, 1)
    selectorButton:SetMouseOverFontColor(1, 1, 1, 1)
    selectorButton:SetPressedFontColor(0.6, 0.6, 0.6, 1)
    
    local dropdownBg = CreateControl("$(parent)BG", selectorButton, CT_BACKDROP)
    dropdownBg:SetAnchorFill(selectorButton)
    dropdownBg:SetCenterTexture("EsoUI/Art/Miscellaneous/dropdown_bg.dds")
    dropdownBg:SetCenterColor(0, 0, 0, 0.8)
    dropdownBg:SetEdgeTexture("EsoUI/Art/Miscellaneous/dropdown_border.dds", 32, 4)
    dropdownBg:SetEdgeColor(0.7, 0.7, 0.7, 1)
    dropdownBg:SetInsets(1, 1, -1, -1)
    
    local dropdownArrow = CreateControl(nil, selectorButton, CT_TEXTURE)
    dropdownArrow:SetDimensions(14, 14)
    dropdownArrow:SetAnchor(RIGHT, selectorButton, RIGHT, -5, 0)
    dropdownArrow:SetTexture("EsoUI/Art/Miscellaneous/dropdown_arrow_normal.dds")
    dropdownArrow:SetColor(0.9, 0.9, 0.9, 1)
    TTDungeon.dropdownArrow = dropdownArrow
    
    selectorButton:SetHandler("OnClicked", function()
        TTDungeon.Debug("Dropdown button clicked!")
        TTDungeon.ShowDungeonSelector()
    end)
    
    selectorButton:SetHandler("OnMouseEnter", function()
        dropdownArrow:SetTexture("EsoUI/Art/Miscellaneous/dropdown_arrow_over.dds")
        dropdownBg:SetEdgeColor(0.9, 0.8, 0.5, 1)
    end)
    
    selectorButton:SetHandler("OnMouseExit", function()
        if not TTDungeon.dropdownOpen then
            dropdownArrow:SetTexture("EsoUI/Art/Miscellaneous/dropdown_arrow_normal.dds")
            dropdownBg:SetEdgeColor(0.7, 0.7, 0.7, 1)
        end
    end)
    
    TTDungeon.dungeonSelectorButton = selectorButton

    -- Dungeon Label (alternative to dropdown when in dungeon)
    local dungeonLabel = CreateControl(nil, header, CT_LABEL)
    dungeonLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
    dungeonLabel:SetDimensions(WINDOW_WIDTH - 2 * ESO_BORDER_THICKNESS - 35, 24)
    dungeonLabel:SetFont("$(BOLD_FONT)|$(KB_15)")
    dungeonLabel:SetColor(1, 1, 1, 1)
    dungeonLabel:SetText("")
    dungeonLabel:SetHidden(true)
    TTDungeon.dungeonLabel = dungeonLabel

    -- Content Panel
    local contentPanelHeight = sv.expandedHeight - HEADER_HEIGHT - (ESO_BORDER_THICKNESS * 2)
    if contentPanelHeight < 0 then contentPanelHeight = 0 end
    
    local contentPanel = CreateControl("TTDungeon_ContentPanel", ui, CT_CONTROL)
    contentPanel:SetDimensions(WINDOW_WIDTH - 2 * ESO_BORDER_THICKNESS, contentPanelHeight)
    contentPanel:SetAnchor(TOPLEFT, ui, TOPLEFT, ESO_BORDER_THICKNESS, HEADER_HEIGHT + ESO_BORDER_THICKNESS)
    contentPanel:SetHidden(TTDungeon.isMinimized)
    TTDungeon.contentPanel = contentPanel
    
    TTDungeon.UpdateHeaderHeight = function()
        local headerHeight = HEADER_HEIGHT
        
        local newContentHeight = sv.expandedHeight - headerHeight - (ESO_BORDER_THICKNESS * 2)
        if newContentHeight < 0 then newContentHeight = 0 end
        contentPanel:SetHeight(newContentHeight)
        contentPanel:ClearAnchors()
        contentPanel:SetAnchor(TOPLEFT, ui, TOPLEFT, ESO_BORDER_THICKNESS, headerHeight + ESO_BORDER_THICKNESS)
        
        if TTDungeon.encountersContainer then
            local tabBarY = 3
            local tabHeight = 32
            local scHeight = newContentHeight - tabBarY - tabHeight - 5
            if scHeight < 0 then scHeight = 0 end
            TTDungeon.encountersContainer:SetHeight(scHeight)
            TTDungeon.setsContainer:SetHeight(scHeight)
            TTDungeon.achContainer:SetHeight(scHeight)
        end
    end

    TTDungeon.CreateTabs(contentPanel, sv)
    TTDungeon.CreateContentContainers(contentPanel, contentPanelHeight)

    TTDungeon.UpdateScale(sv.uiScale)
    TTDungeon.HighlightTab(TTDungeon.tabs.encBtn)

    TTDungeon.Debug("Main UI created.")
    
    TTDungeon.UpdateDungeonSelector()
    TTDungeon.UpdateHeaderHeight()
    
    if TTDungeon.UpdateTabLayout then
        TTDungeon.UpdateTabLayout()
    end
end

-- ================================================================================
-- Tab Creation
-- ================================================================================

function TTDungeon.CreateTabs(contentPanel, sv)
    local tabBarY = 3
    
    local tabSeparator = CreateControl(nil, contentPanel, CT_TEXTURE)
    tabSeparator:SetAnchor(TOPLEFT, contentPanel, TOPLEFT, 0, tabBarY + 32)
    tabSeparator:SetAnchor(TOPRIGHT, contentPanel, TOPRIGHT, 0, tabBarY + 32)
    tabSeparator:SetHeight(2)
    tabSeparator:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    tabSeparator:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
    tabSeparator:SetColor(0.4, 0.4, 0.4, 0.5)
    
    TTDungeon.UpdateTabLayout = function()
        if not TTDungeon.tabs or not TTDungeon.contentPanel then return end
        
        local currentLang = TTDungeon.savedVars.language or "en"
        local tabWidth = 78
        local tabCount = 3
        local totalWidth = TTDungeon.contentPanel:GetWidth()
        local totalTabsW = tabWidth * tabCount
        local leftover = totalWidth - totalTabsW
        local marginLeft = leftover / 2
        
        if TTDungeon.tabs.encBtn then
            TTDungeon.tabs.encBtn:ClearAnchors()
            TTDungeon.tabs.encBtn:SetAnchor(TOPLEFT, TTDungeon.contentPanel, TOPLEFT, marginLeft, tabBarY)
            TTDungeon.tabs.encBtn:SetDimensions(tabWidth, 30)
        end
        
        if TTDungeon.tabs.setBtn then
            TTDungeon.tabs.setBtn:ClearAnchors()
            TTDungeon.tabs.setBtn:SetAnchor(TOPLEFT, TTDungeon.contentPanel, TOPLEFT, marginLeft + tabWidth, tabBarY)
            TTDungeon.tabs.setBtn:SetDimensions(tabWidth, 30)
        end
        
        if TTDungeon.tabs.achBtn then
            TTDungeon.tabs.achBtn:ClearAnchors()
            TTDungeon.tabs.achBtn:SetAnchor(TOPLEFT, TTDungeon.contentPanel, TOPLEFT, marginLeft + (tabWidth * 2), tabBarY)
            TTDungeon.tabs.achBtn:SetDimensions(tabWidth, 30)
        end
    end

    local function OnTabMouseEnter(tabButton)
        if tabButton:GetState() ~= BSTATE_PRESSED then
            if tabButton.label then
                tabButton.label:SetColor(1, 1, 1, 1)
            end
        end
    end
    
    local function OnTabMouseExit(tabButton)
        if tabButton:GetState() ~= BSTATE_PRESSED then
            if tabButton.label then
                tabButton.label:SetColor(0.8, 0.8, 0.8, 1)
            end
        end
    end

    local function CreateTabButton(parent, xOffset, text, onClick, tabKey)
        local btn = CreateControl(nil, parent, CT_BUTTON)
        btn:SetDimensions(78, 30)
        btn:SetAnchor(TOPLEFT, parent, TOPLEFT, xOffset, tabBarY)
        btn:SetNormalTexture("EsoUI/Art/Miscellaneous/tab_normal.dds")
        btn:SetPressedTexture("EsoUI/Art/Miscellaneous/tab_active.dds")
        btn:SetMouseOverTexture("EsoUI/Art/Miscellaneous/tab_over.dds")
        btn:SetHandler("OnClicked", onClick)
        btn.tabKey = tabKey
        
        local underline = CreateControl(nil, btn, CT_TEXTURE)
        underline:SetDimensions(btn:GetWidth() - 10, 2)
        underline:SetAnchor(BOTTOM, btn, BOTTOM, 0, 0)
        underline:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
        underline:SetColor(1, 0.84, 0, 1)
        underline:SetHidden(true)
        btn.underline = underline
        
        local lbl = CreateControl(nil, btn, CT_LABEL)
        lbl:SetAnchor(CENTER, btn, CENTER, 0, 0)
        lbl:SetFont("$(BOLD_FONT)|$(KB_14)|soft-shadow-thin")
        lbl:SetColor(0.8, 0.8, 0.8, 1)
        lbl:SetText(text)
        btn.label = lbl
        
        btn:SetHandler("OnMouseEnter", function() OnTabMouseEnter(btn) end)
        btn:SetHandler("OnMouseExit",  function() OnTabMouseExit(btn)  end)
        
        return btn
    end

    TTDungeon.tabs    = {}
    TTDungeon.allTabs = {}
    local initialLang = sv.language or "en"
    
    local encText = initialLang == "de" and "Bosse" or "Enc"
    local setText = initialLang == "de" and "Sets" or "Sets"
    local achText = initialLang == "de" and "Erf." or "Ach"
    
    TTDungeon.tabs.encBtn = CreateTabButton(contentPanel, 0,  encText,  function() TTDungeon.ShowTab("enc") end, "enc")
    TTDungeon.tabs.setBtn = CreateTabButton(contentPanel, 78, setText, function() TTDungeon.ShowTab("sets") end, "sets")
    TTDungeon.tabs.achBtn = CreateTabButton(contentPanel, 156,  achText,  function() TTDungeon.ShowTab("ach") end, "ach")
    TTDungeon.allTabs = { TTDungeon.tabs.encBtn, TTDungeon.tabs.setBtn, TTDungeon.tabs.achBtn }
    
    TTDungeon.UpdateTabLayout()
end

-- ================================================================================
-- Content Containers
-- ================================================================================

function TTDungeon.CreateContentContainers(contentPanel, contentPanelHeight)
    local subContainerTop = 3 + 32 + 3
    local scHeight = contentPanelHeight - subContainerTop - 5
    if scHeight < 0 then scHeight = 0 end

    -- Encounters Container
    local encContainer = CreateControl("TTD_EncountersContainer", contentPanel, CT_CONTROL)
    encContainer:SetDimensions(contentPanel:GetWidth(), scHeight)
    encContainer:SetAnchor(TOPLEFT, contentPanel, TOPLEFT, 0, subContainerTop)
    encContainer:SetHidden(false)
    TTDungeon.encountersContainer = encContainer
    
    local encScroll = CreateControl("TTD_EncounterScroll", encContainer, CT_SCROLL)
    encScroll:SetAnchor(TOPLEFT, encContainer, TOPLEFT, 5, 5)
    encScroll:SetDimensions(encContainer:GetWidth() - 10, encContainer:GetHeight() - 10)
    encScroll:SetMouseEnabled(true)
    encScroll.offsetY = 0
    
    encScroll:SetHandler("OnMouseWheel", function(self, delta)
        local step = 20
        if TTDungeon.savedVars.invertScroll then 
            self.offsetY = self.offsetY + (delta * step)
        else 
            self.offsetY = self.offsetY - (delta * step) 
        end
        TTDungeon.ClampScrollOffset(self)
    end)
    
    local encScrollChild = CreateControl("TTD_EncounterScrollChild", encScroll, CT_CONTROL)
    encScrollChild:SetAnchor(TOPLEFT, encScroll, TOPLEFT, 0, 0)
    encScrollChild:SetDimensions(encScroll:GetWidth(), 0)
    encScroll.scrollChild = encScrollChild
    
    TTDungeon.encounterScroll      = encScroll
    TTDungeon.encounterScrollChild = encScrollChild
    TTDungeon.bossEntries          = {}

    -- Sets Container
    local setsContainer = CreateControl("TTD_SetsContainer", contentPanel, CT_CONTROL)
    setsContainer:SetDimensions(contentPanel:GetWidth(), scHeight)
    setsContainer:SetAnchor(TOPLEFT, contentPanel, TOPLEFT, 0, subContainerTop)
    setsContainer:SetHidden(true)
    TTDungeon.setsContainer = setsContainer

    -- Achievements Container
    local achContainer = CreateControl("TTD_AchContainer", contentPanel, CT_CONTROL)
    achContainer:SetDimensions(contentPanel:GetWidth(), scHeight)
    achContainer:SetAnchor(TOPLEFT, contentPanel, TOPLEFT, 0, subContainerTop)
    achContainer:SetHidden(true)
    TTDungeon.achContainer = achContainer
    
    local achLinesParent = CreateControl("TTD_AchLabelInTab", achContainer, CT_CONTROL)
    achLinesParent:SetAnchor(TOPLEFT, achContainer, TOPLEFT, 5, 5)
    achLinesParent:SetDimensions(achContainer:GetWidth() - 10, achContainer:GetHeight() - 10)
    achLinesParent:SetHidden(false)
    TTDungeon.achLabelInTab = achLinesParent
end

-- ================================================================================
-- Tab Highlighting
-- ================================================================================

function TTDungeon.HighlightTab(tabBtn)
    if not tabBtn then return end
    
    for _, tab in ipairs(TTDungeon.allTabs or {}) do
        if tab then
            tab:SetState(BSTATE_NORMAL, false)
            if tab.label then tab.label:SetColor(0.8, 0.8, 0.8, 1) end
            if tab.underline then tab.underline:SetHidden(true) end
        end
    end
    
    tabBtn:SetState(BSTATE_PRESSED, true)
    if tabBtn.label then 
        tabBtn.label:SetColor(1, 0.84, 0, 1)
    end
    if tabBtn.underline then
        tabBtn.underline:SetHidden(false)
    end
end