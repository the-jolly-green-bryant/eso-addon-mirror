-- ============================================
-- TheElderSporesOnline - Companion Addon
-- Version 2.2.1 
-- ============================================

local SPORES = {}
TheElderSporesOnline = SPORES

-- ============================================
-- CONSTANTS
-- ============================================
  SPORES.VERSION = "2.2.1"
  SPORES.SCHEMA_VERSION = "1.2"

-- Slot mappings for equipment
  SPORES.EQUIP_SLOTS = {
    armor = {
        head = EQUIP_SLOT_HEAD,
        shoulders = EQUIP_SLOT_SHOULDERS,
        chest = EQUIP_SLOT_CHEST,
        hands = EQUIP_SLOT_HAND,
        waist = EQUIP_SLOT_WAIST,
        legs = EQUIP_SLOT_LEGS,
        feet = EQUIP_SLOT_FEET,
    },
    jewelry = {
        necklace = EQUIP_SLOT_NECK,
        ring1 = EQUIP_SLOT_RING1,
        ring2 = EQUIP_SLOT_RING2,
    },
    weapons = {
        frontbar_primary = EQUIP_SLOT_MAIN_HAND,
        frontbar_offhand = EQUIP_SLOT_OFF_HAND,
        backbar_primary = EQUIP_SLOT_BACKUP_MAIN,
        backbar_offhand = EQUIP_SLOT_BACKUP_OFF,
    }
}

-- Action bar slots
  SPORES.ACTION_SLOTS = {
    [1] = { 3, 4, 5, 6, 7, 8 },  -- Front bar: slots 3-7 + ultimate 8
    [2] = { 3, 4, 5, 6, 7, 8 },  -- Back bar (when swapped)
}

-- Champion Point trees
  SPORES.CP_DISCIPLINES = {
    [1] = "craft",
    [2] = "warfare", 
    [3] = "fitness"
}

-- ============================================
-- SAVED VARIABLES DEFAULTS
-- ============================================
  SPORES.defaults = {
    windowPos = { x = 0, y = 0 },
    minButtonPos = { x = -450, y = -200 },
    positionLocked = false,
    activeTab = "export",
    -- Phase 4-5: Build guides storage
    buildGuides = {},
    activeGuide = nil,
}

-- ============================================
-- COLORS
-- ============================================
  SPORES.colors = {
    gold = "|cFFD700",
    green = "|c00FF00",
    red = "|cFF0000",
    yellow = "|cFFFF00",
    cyan = "|c00FFFF",
    orange = "|cFFA500",
    white = "|cFFFFFF",
    gray = "|cAAAAAA",
    reset = "|r",
}

-- ============================================
-- UI REFERENCES
-- ============================================
  SPORES.ui = {}

-- ============================================
-- INITIALIZATION
-- ============================================
function   SPORES:Initialize()
    -- Initialize SavedVariables
    self.sv = ZO_SavedVars:NewAccountWide("TheElderSporesOnlineSV", 1, nil, self.defaults, GetWorldName())
    
    -- Check for imported guide file
    self:CheckGuideImport()
    
    -- Register slash commands
    SLASH_COMMANDS["/teso"] = function()   SPORES:ToggleWindow() end
    SLASH_COMMANDS["/eldersporesonline"] = function()   SPORES:ToggleWindow() end
    
    -- Get UI references
    self.ui.mainWindow = TESO_MainWindow
    self.ui.minButton = TESO_MinButton
    
    if not self.ui.mainWindow or not self.ui.minButton then
        d(self.colors.red .. "[SPORES] ERROR: UI elements not found" .. self.colors.reset)
        return
    end
    
    -- Setup UI components
    self:SetupUI()
    self:SetupDragHandlers()
    
    -- Close window on Escape key
    self.ui.mainWindow:SetHandler("OnKeyDown", function(control, key)
        if key == KEY_ESCAPE and not control:IsHidden() then
            self:MinimizeWindow()
        end
    end)
    self.ui.mainWindow:SetKeyboardEnabled(true)
    
    -- Restore positions after delay to ensure UI is fully ready
    zo_callLater(function()
          SPORES:RestorePositions()
    end, 200)
    
    -- Show startup message
    d(self.colors.gold .. "[TheElderSporesOnline]" .. self.colors.reset .. " v" .. self.VERSION .. " Loaded")
    d(self.colors.gray .. "  /teso to toggle window" .. self.colors.reset)
end

-- ============================================
-- UI SETUP
-- ============================================
function   SPORES:SetupUI()
    local mainWin = self.ui.mainWindow
    
    -- Setup subtitle
    local subtitle = GetControl(mainWin, "_Subtitle")
    if subtitle then
        subtitle:SetText("Build Export Tool - TheElderSporesOnline.com")
    end
    
    -- Setup lock button
    self:SetupLockButton()
    
    -- Apply saved lock state
    if self.sv.positionLocked then
        self.ui.mainWindow:SetMovable(false)
        self.ui.minButton:SetMovable(false)
    end
    
    -- Setup tab buttons
    self:CreateTabButtons()
    
    -- Setup Export tab
    self:SetupExportTab()
    
    -- Setup Guide tab
    self:SetupGuideTab()
end

function   SPORES:CreateTabButtons()
    local tabBar = GetControl(self.ui.mainWindow, "_TabBar")
    if not tabBar then return end
    
    local tabs = {
        { id = "export", label = "Export Build" },
        { id = "guide", label = "Build Guides" },
    }
    
    -- Auto-center tabs with 20px gap
    local tabWidth = 210
    local gap = 20
    local totalWidth = (#tabs * tabWidth) + ((#tabs - 1) * gap)
    local startX = (660 - totalWidth) / 2
    for i, tab in ipairs(tabs) do
        tab.x = startX + ((i - 1) * (tabWidth + gap))
    end
    
    for _, tab in ipairs(tabs) do
        -- Create button container for background
        local btnContainer = WINDOW_MANAGER:CreateControl("TESO_TabContainer_" .. tab.id, tabBar, CT_CONTROL)
        btnContainer:SetDimensions(210, 36)
        btnContainer:SetAnchor(TOPLEFT, tabBar, TOPLEFT, tab.x, 0)
        
        -- Create backdrop for button
        local btnBg = WINDOW_MANAGER:CreateControl("TESO_TabBG_" .. tab.id, btnContainer, CT_BACKDROP)
        btnBg:SetAnchorFill(btnContainer)
        btnBg:SetCenterColor(0.15, 0.15, 0.15, 0.9)
        btnBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
        btnBg:SetEdgeTexture("", 1, 1, 1, 0)
        
        -- Create button
        local btn = WINDOW_MANAGER:CreateControl("TESO_Tab_" .. tab.id, btnContainer, CT_BUTTON)
        btn:SetAnchorFill(btnContainer)
        btn:SetFont("ZoFontGameBold")
        btn:SetText(tab.label)
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        btn:SetNormalFontColor(0.7, 0.7, 0.7, 1)
        btn:SetMouseOverFontColor(1, 0.84, 0, 1)
        btn:SetHandler("OnClicked", function()   SPORES:SwitchTab(tab.id) end)
        
        -- Store references
        self.ui["tab_" .. tab.id] = btn
        self.ui["tabBg_" .. tab.id] = btnBg
    end
    
    -- Highlight active tab
    self:UpdateTabHighlights()
end

function   SPORES:SwitchTab(tabId)
    self.sv.activeTab = tabId
    
    -- Hide all tab content
    GetControl(self.ui.mainWindow, "_ExportTab"):SetHidden(true)
    GetControl(self.ui.mainWindow, "_GuideTab"):SetHidden(true)
    
    -- Show selected tab
    local tabControl = GetControl(self.ui.mainWindow, "_" .. tabId:gsub("^%l", string.upper) .. "Tab")
    if tabControl then
        tabControl:SetHidden(false)
    end
    
    -- Refresh guide checklist when switching to guide tab
    if tabId == "guide" then
        self:RefreshGuideDisplay()
    end
    
    self:UpdateTabHighlights()
end

function   SPORES:UpdateTabHighlights()
    local activeTab = self.sv.activeTab or "export"
    
    for _, tabId in ipairs({"export", "guide"}) do
        local btn = self.ui["tab_" .. tabId]
        local btnBg = self.ui["tabBg_" .. tabId]
        if btn then
            if tabId == activeTab then
                btn:SetNormalFontColor(1, 0.84, 0, 1)
                if btnBg then
                    btnBg:SetCenterColor(0.3, 0.25, 0.1, 0.9)
                    btnBg:SetEdgeColor(1, 0.84, 0, 1)
                end
            else
                btn:SetNormalFontColor(0.7, 0.7, 0.7, 1)
                if btnBg then
                    btnBg:SetCenterColor(0.15, 0.15, 0.15, 0.9)
                    btnBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
                end
            end
        end
    end
end

-- ============================================
-- EXPORT TAB SETUP
-- ============================================
function   SPORES:SetupExportTab()
    local exportTab = GetControl(self.ui.mainWindow, "_ExportTab")
    if not exportTab then return end
    
    -- Instructions
    local instructions = GetControl(exportTab, "_Instructions")
    if instructions then
        instructions:SetText("Click 'Export Current Build' to generate web-ready build data.")
    end
    
    -- Export button
    local exportBtn = GetControl(exportTab, "_ExportBtn")
    if exportBtn then
        exportBtn:SetFont("ZoFontGameBold")
        exportBtn:SetText("EXPORT CURRENT BUILD")
        exportBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        exportBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        exportBtn:SetNormalFontColor(0, 0, 0, 1)
        exportBtn:SetMouseOverFontColor(0.2, 0.1, 0, 1)
        exportBtn:SetHandler("OnClicked", function()   SPORES:ExportBuild() end)
        
        -- Style the button with gold background
        local btnBg = WINDOW_MANAGER:CreateControl(nil, exportBtn, CT_BACKDROP)
        btnBg:SetAnchorFill(exportBtn)
        btnBg:SetCenterColor(1, 0.84, 0, 1)
        btnBg:SetEdgeColor(0.7, 0.6, 0, 1)
        btnBg:SetEdgeTexture("", 1, 1, 1, 0)
        btnBg:SetDrawLevel(0)
        
        -- Store for hover effects
        self.ui.exportBtnBg = btnBg
        exportBtn:SetHandler("OnMouseEnter", function()
            btnBg:SetCenterColor(1, 0.9, 0.4, 1)
        end)
        exportBtn:SetHandler("OnMouseExit", function()
            btnBg:SetCenterColor(1, 0.84, 0, 1)
        end)
    end
    
    -- Store EditBox reference
    self.ui.exportEditBox = GetControl(exportTab, "_EditBox")
    
    -- Update copy hint to browser button
    local copyHint = GetControl(exportTab, "_CopyHint")
    if copyHint then
        copyHint:SetHidden(true)
    end
    
    -- Create "Open in Browser" button
    local browserBtn = WINDOW_MANAGER:CreateControl("TESO_BrowserBtn", exportTab, CT_BUTTON)
    browserBtn:SetDimensions(200, 40)
    browserBtn:SetAnchor(BOTTOM, exportTab, BOTTOM, 0, 80)
    browserBtn:SetFont("ZoFontGameBold")
    browserBtn:SetText("OPEN IN BROWSER")
    browserBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    browserBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    browserBtn:SetNormalFontColor(0, 0, 0, 1)
    browserBtn:SetMouseOverFontColor(0.2, 0.1, 0, 1)
    browserBtn:SetHandler("OnClicked", function() 
        if   SPORES.pendingExportUrl then
            RequestOpenUnsafeURL(  SPORES.pendingExportUrl)
        else
            d(  SPORES.colors.yellow .. "[SPORES]" ..   SPORES.colors.reset .. " Click 'Export Current Build' first!")
        end
    end)
    
    -- Style browser button
    local browserBtnBg = WINDOW_MANAGER:CreateControl(nil, browserBtn, CT_BACKDROP)
    browserBtnBg:SetAnchorFill(browserBtn)
    browserBtnBg:SetCenterColor(0.2, 0.7, 0.3, 1)
    browserBtnBg:SetEdgeColor(0.1, 0.5, 0.2, 1)
    browserBtnBg:SetEdgeTexture("", 1, 1, 1, 0)
    browserBtnBg:SetDrawLevel(0)
    
    browserBtn:SetHandler("OnMouseEnter", function()
        browserBtnBg:SetCenterColor(0.3, 0.8, 0.4, 1)
    end)
    browserBtn:SetHandler("OnMouseExit", function()
        browserBtnBg:SetCenterColor(0.2, 0.7, 0.3, 1)
    end)
    
    self.ui.browserBtn = browserBtn
end

-- ============================================
-- GUIDE FILE IMPORT (reads SPORES_GuideImport.lua on load)
-- ============================================
function   SPORES:CheckGuideImport()
    if not SPORES_GuideImport or type(SPORES_GuideImport) ~= "table" then return end
    if not SPORES_GuideImport.v then return end
    
    -- Validate schema version
    if SPORES_GuideImport.v < 2 then
        d(self.colors.red .. "[SPORES] Guide file has unsupported format version." .. self.colors.reset)
        SPORES_GuideImport = nil
        return
    end
    
    -- Check guide limit (max 5)
    local guideCount = 0
    for _ in pairs(self.sv.buildGuides) do guideCount = guideCount + 1 end
    
    if guideCount >= 5 then
        d(self.colors.yellow .. "[SPORES] You already have 5 build guides. Delete one from the Guide tab to import new ones." .. self.colors.reset)
        SPORES_GuideImport = nil
        return
    end
    
    -- Extract metadata
    local buildName = SPORES_GuideImport.bn or "Unnamed Build"
    local creator = SPORES_GuideImport.cn or SPORES_GuideImport.u or "Unknown"
    
    -- Check for duplicate (same name + creator)
    for _, existing in pairs(self.sv.buildGuides) do
        if existing.name == buildName and existing.creator == creator then
            d(self.colors.yellow .. "[SPORES] Guide already imported: " .. self.colors.gold .. buildName .. self.colors.reset)
            SPORES_GuideImport = nil
            return
        end
    end
    
    -- Store in main SavedVariables
    local guideKey = "guide_" .. GetTimeStamp()
    self.sv.buildGuides[guideKey] = {
        name = buildName,
        creator = creator,
        data = SPORES_GuideImport,
        importedAt = GetTimeStamp(),
    }
    
    -- Set as active guide
    self.sv.activeGuide = guideKey
    
    -- Clear the import file (will be empty on next save)
    SPORES_GuideImport = nil
    
    d(self.colors.green .. "[SPORES] Build guide imported: " .. self.colors.gold .. buildName .. self.colors.reset)
    d(self.colors.green .. "[SPORES] Creator: " .. self.colors.gold .. creator .. self.colors.reset)
    d(self.colors.cyan .. "[SPORES] " .. self.colors.reset .. "Open the addon to view your guide.")
end

-- ============================================
-- IMPORT TAB SETUP
-- ============================================
function   SPORES:SetupImportTab()
    local importTab = GetControl(self.ui.mainWindow, "_ImportTab")
    if not importTab then return end
    
    -- Instructions
    local instructions = GetControl(importTab, "_ImportInstructions")
    if instructions then
        instructions:SetText("Paste the build guide code from TheElderSporesOnline.com, then click Import.")
    end
    
    -- Store UI references
    self.ui.importEditBox = GetControl(importTab, "_ImportEditBox")
    self.ui.importNameInput = GetControl(importTab, "_NameInput")
    self.ui.importCreatorLabel = GetControl(importTab, "_CreatorValue")
    
    if self.ui.importCreatorLabel then
        self.ui.importCreatorLabel:SetText("--")
    end
    
    -- Click to focus (ESO requires explicit focus grab for keyboard input)
    if self.ui.importEditBox then
        self.ui.importEditBox:SetHandler("OnMouseDown", function(control)
            control:TakeFocus()
        end)
        self.ui.importEditBox:SetHandler("OnTextChanged", function(control)
            self:PreviewImportData(control:GetText())
        end)
    end
    
    if self.ui.importNameInput then
        self.ui.importNameInput:SetHandler("OnMouseDown", function(control)
            control:TakeFocus()
        end)
    end
    
    -- Import button
    local importBtn = GetControl(importTab, "_ImportBtn")
    if importBtn then
        importBtn:SetFont("ZoFontGameBold")
        importBtn:SetText("IMPORT BUILD GUIDE")
        importBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        importBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        importBtn:SetNormalFontColor(0, 0, 0, 1)
        importBtn:SetMouseOverFontColor(0.2, 0.1, 0, 1)
        importBtn:SetEnabled(true)
        importBtn:SetHandler("OnClicked", function()   SPORES:ImportBuildGuide() end)
        
        local btnBg = WINDOW_MANAGER:CreateControl(nil, importBtn, CT_BACKDROP)
        btnBg:SetAnchorFill(importBtn)
        btnBg:SetCenterColor(0.2, 0.7, 0.3, 1)
        btnBg:SetEdgeColor(0.1, 0.5, 0.2, 1)
        btnBg:SetEdgeTexture("", 1, 1, 1, 0)
        btnBg:SetDrawLevel(0)
        
        self.ui.importBtnBg = btnBg
        importBtn:SetHandler("OnMouseEnter", function()
            btnBg:SetCenterColor(0.3, 0.8, 0.4, 1)
        end)
        importBtn:SetHandler("OnMouseExit", function()
            btnBg:SetCenterColor(0.2, 0.7, 0.3, 1)
        end)
    end
end

-- ============================================
-- IMPORT: PREVIEW PASTED DATA
-- ============================================
function   SPORES:PreviewImportData(rawText)
    if not rawText or rawText == "" then
        if self.ui.importNameInput then self.ui.importNameInput:SetText("") end
        if self.ui.importCreatorLabel then self.ui.importCreatorLabel:SetText("--") end
        return
    end
    
    -- Try Base64 decode → JSON parse
    local ok, decoded = pcall(function() return self:Base64Decode(rawText:gsub("%s+", "")) end)
    if not ok or not decoded or decoded == "" then return end
    
    local data, err = self:JSONParse(decoded)
    if not data then return end
    
    -- Preview build name
    if data.bn and self.ui.importNameInput then
        self.ui.importNameInput:SetText(tostring(data.bn))
    end
    
    -- Preview creator name
    if self.ui.importCreatorLabel then
        local creator = data.cn or data.u or "Unknown"
        self.ui.importCreatorLabel:SetText(tostring(creator))
    end
end

-- ============================================
-- IMPORT: PROCESS BUILD GUIDE
-- ============================================
function   SPORES:ImportBuildGuide()
    -- Get pasted text
    if not self.ui.importEditBox then
        d(self.colors.red .. "[SPORES] Import EditBox not found." .. self.colors.reset)
        return
    end
    
    local rawText = self.ui.importEditBox:GetText()
    if not rawText or rawText:gsub("%s+", "") == "" then
        d(self.colors.red .. "[SPORES] Nothing to import. Paste a build guide code first." .. self.colors.reset)
        return
    end
    
    -- Decode Base64
    local cleanText = rawText:gsub("%s+", "")
    local ok, decoded = pcall(function() return self:Base64Decode(cleanText) end)
    if not ok or not decoded or decoded == "" then
        d(self.colors.red .. "[SPORES] Failed to decode. Make sure you copied the full code." .. self.colors.reset)
        return
    end
    
    -- Parse JSON
    local data, err = self:JSONParse(decoded)
    if not data then
        d(self.colors.red .. "[SPORES] Invalid build data: " .. tostring(err) .. self.colors.reset)
        return
    end
    
    -- Validate schema version
    if not data.v or data.v < 2 then
        d(self.colors.red .. "[SPORES] Unsupported build format version." .. self.colors.reset)
        return
    end
    
    -- Get build name (from NameInput override or decoded data)
    local buildName = "Unnamed Build"
    if self.ui.importNameInput then
        local inputName = self.ui.importNameInput:GetText()
        if inputName and inputName ~= "" then
            buildName = inputName
        end
    end
    if buildName == "Unnamed Build" and data.bn then
        buildName = tostring(data.bn)
    end
    
    -- Get creator name
    local creator = data.cn or data.u or "Unknown"
    
    -- Check guide limit (max 5)
    local guideCount = 0
    for _ in pairs(self.sv.buildGuides) do guideCount = guideCount + 1 end
    
    if guideCount >= 5 then
        d(self.colors.yellow .. "[SPORES] You already have 5 build guides. Delete one first from the Guide tab." .. self.colors.reset)
        return
    end
    
    -- Generate a unique key
    local guideKey = "guide_" .. GetTimeStamp()
    
    -- Store in SavedVariables
    self.sv.buildGuides[guideKey] = {
        name = buildName,
        creator = creator,
        data = data,
        importedAt = GetTimeStamp(),
    }
    
    -- Set as active guide
    self.sv.activeGuide = guideKey
    
    d(self.colors.green .. "[SPORES] Build guide imported: " .. self.colors.gold .. buildName .. self.colors.reset)
    d(self.colors.green .. "[SPORES] Creator: " .. self.colors.gold .. creator .. self.colors.reset)
    d(self.colors.cyan .. "[SPORES] " .. self.colors.reset .. "Switch to the Guide tab to view your build guide.")
    
    -- Clear the import fields
    if self.ui.importEditBox then self.ui.importEditBox:SetText("") end
    if self.ui.importNameInput then self.ui.importNameInput:SetText("") end
    if self.ui.importCreatorLabel then self.ui.importCreatorLabel:SetText("--") end
    
    -- Auto-switch to guide tab
    self:SwitchTab("guide")
end

-- ============================================
-- GUIDE TAB SETUP
-- ============================================
function   SPORES:SetupGuideTab()
    local guideTab = GetControl(self.ui.mainWindow, "_GuideTab")
    if not guideTab then return end
    
    local header = GetControl(guideTab, "_GuideHeader")
    if not header then return end
    
    -- "No Guide" placeholder (shown when no guides exist)
    local noGuideLabel = WINDOW_MANAGER:CreateControl("TESO_NoGuideLabel", header, CT_LABEL)
    noGuideLabel:SetFont("ZoFontWinH3")
    noGuideLabel:SetColor(0.6, 0.6, 0.6, 1)
    noGuideLabel:SetAnchor(CENTER)
    noGuideLabel:SetText("No Build Guide Active\n(Import a guide from the Import tab)")
    self.ui.noGuideLabel = noGuideLabel
    
    -- Build Name (large, gold, read-only)
    local nameLabel = WINDOW_MANAGER:CreateControl("TESO_GuideName", header, CT_LABEL)
    nameLabel:SetFont("ZoFontWinH2")
    nameLabel:SetColor(1, 0.84, 0, 1)
    nameLabel:SetAnchor(TOPLEFT, header, TOPLEFT, 5, 2)
    nameLabel:SetDimensions(400, 24)
    nameLabel:SetHidden(true)
    self.ui.guideNameLabel = nameLabel
    
    -- Creator Name (below build name, read-only, locked attribution)
    local creatorLabel = WINDOW_MANAGER:CreateControl("TESO_GuideCreator", header, CT_LABEL)
    creatorLabel:SetFont("ZoFontGame")
    creatorLabel:SetColor(0.7, 0.7, 0.7, 1)
    creatorLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 10, 2)
    creatorLabel:SetDimensions(400, 20)
    creatorLabel:SetHidden(true)
    self.ui.guideCreatorLabel = creatorLabel
    
    -- Guide selector dropdown (top right)
    local dropdownBtn = WINDOW_MANAGER:CreateControl("TESO_GuideDropdown", header, CT_BUTTON)
    dropdownBtn:SetDimensions(160, 28)
    dropdownBtn:SetAnchor(TOPRIGHT, header, TOPRIGHT, -70, 5)
    dropdownBtn:SetFont("ZoFontGameSmall")
    dropdownBtn:SetText("Select Guide")
    dropdownBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    dropdownBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    dropdownBtn:SetNormalFontColor(1, 1, 1, 1)
    dropdownBtn:SetMouseOverFontColor(1, 0.84, 0, 1)
    dropdownBtn:SetHidden(true)
    
    local dropBg = WINDOW_MANAGER:CreateControl(nil, dropdownBtn, CT_BACKDROP)
    dropBg:SetAnchorFill(dropdownBtn)
    dropBg:SetCenterColor(0.15, 0.15, 0.15, 0.9)
    dropBg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    dropBg:SetEdgeTexture("", 1, 1, 1, 0)
    dropBg:SetDrawLevel(0)
    
    dropdownBtn:SetHandler("OnClicked", function()   SPORES:ShowGuideDropdown() end)
    self.ui.guideDropdownBtn = dropdownBtn
    
    -- Delete guide button (top right corner)
    local deleteBtn = WINDOW_MANAGER:CreateControl("TESO_GuideDelete", header, CT_BUTTON)
    deleteBtn:SetDimensions(55, 28)
    deleteBtn:SetAnchor(TOPRIGHT, header, TOPRIGHT, -5, 5)
    deleteBtn:SetFont("ZoFontGameSmall")
    deleteBtn:SetText("Delete")
    deleteBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    deleteBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    deleteBtn:SetNormalFontColor(1, 0.3, 0.3, 1)
    deleteBtn:SetMouseOverFontColor(1, 0.5, 0.5, 1)
    deleteBtn:SetHidden(true)
    
    local delBg = WINDOW_MANAGER:CreateControl(nil, deleteBtn, CT_BACKDROP)
    delBg:SetAnchorFill(deleteBtn)
    delBg:SetCenterColor(0.3, 0.1, 0.1, 0.9)
    delBg:SetEdgeColor(0.6, 0.2, 0.2, 1)
    delBg:SetEdgeTexture("", 1, 1, 1, 0)
    delBg:SetDrawLevel(0)
    
    deleteBtn:SetHandler("OnClicked", function()   SPORES:DeleteActiveGuide() end)
    self.ui.guideDeleteBtn = deleteBtn
    
    -- Refresh guide display with saved data
    self:RefreshGuideDisplay()
end

-- ============================================
-- GUIDE: REFRESH DISPLAY
-- ============================================
function   SPORES:RefreshGuideDisplay()
    local activeKey = self.sv.activeGuide
    local guide = activeKey and self.sv.buildGuides[activeKey] or nil
    
    local hasGuides = false
    for _ in pairs(self.sv.buildGuides) do hasGuides = true break end
    
    if not guide then
        -- No active guide
        if self.ui.noGuideLabel then self.ui.noGuideLabel:SetHidden(false) end
        if self.ui.guideNameLabel then self.ui.guideNameLabel:SetHidden(true) end
        if self.ui.guideCreatorLabel then self.ui.guideCreatorLabel:SetHidden(true) end
        if self.ui.guideDropdownBtn then self.ui.guideDropdownBtn:SetHidden(not hasGuides) end
        if self.ui.guideDeleteBtn then self.ui.guideDeleteBtn:SetHidden(true) end
        self:ClearGuideChecklist()
        return
    end
    
    -- Show active guide
    if self.ui.noGuideLabel then self.ui.noGuideLabel:SetHidden(true) end
    
    if self.ui.guideNameLabel then
        self.ui.guideNameLabel:SetText(guide.name or "Unnamed Build")
        self.ui.guideNameLabel:SetHidden(false)
    end
    
    if self.ui.guideCreatorLabel then
        self.ui.guideCreatorLabel:SetText("by " .. (guide.creator or "Unknown"))
        self.ui.guideCreatorLabel:SetHidden(false)
    end
    
    if self.ui.guideDropdownBtn then
        -- Count total guides
        local guideCount = 0
        for _ in pairs(self.sv.buildGuides) do guideCount = guideCount + 1 end
        if guideCount > 1 then
            self.ui.guideDropdownBtn:SetText("Next Guide (" .. guideCount .. ")")
        else
            self.ui.guideDropdownBtn:SetText("1 Guide Saved")
        end
        self.ui.guideDropdownBtn:SetHidden(false)
    end
    
    if self.ui.guideDeleteBtn then self.ui.guideDeleteBtn:SetHidden(false) end
    
    -- Build the checklist
    self:BuildGuideChecklist(guide.data)
end

-- ============================================
-- GUIDE: DROPDOWN SELECTOR
-- ============================================
function   SPORES:ShowGuideDropdown()
    -- Simple cycle through guides (ESO doesn't have native dropdown widgets easily)
    -- Collect all guide keys
    local keys = {}
    for k, _ in pairs(self.sv.buildGuides) do
        table.insert(keys, k)
    end
    table.sort(keys)
    
    if #keys == 0 then return end
    
    -- Find current index and advance to next
    local currentIdx = 1
    for i, k in ipairs(keys) do
        if k == self.sv.activeGuide then
            currentIdx = i
            break
        end
    end
    
    local nextIdx = (currentIdx % #keys) + 1
    self.sv.activeGuide = keys[nextIdx]
    
    local nextGuide = self.sv.buildGuides[keys[nextIdx]]
    d(self.colors.cyan .. "[SPORES] " .. self.colors.reset .. "Switched to: " .. self.colors.gold .. (nextGuide.name or "Unknown") .. self.colors.reset)
    
    self:RefreshGuideDisplay()
end

-- ============================================
-- GUIDE: DELETE ACTIVE
-- ============================================
function   SPORES:DeleteActiveGuide()
    local activeKey = self.sv.activeGuide
    if not activeKey or not self.sv.buildGuides[activeKey] then return end
    
    local name = self.sv.buildGuides[activeKey].name or "Unknown"
    self.sv.buildGuides[activeKey] = nil
    self.sv.activeGuide = nil
    
    -- Set next available guide as active
    for k, _ in pairs(self.sv.buildGuides) do
        self.sv.activeGuide = k
        break
    end
    
    d(self.colors.yellow .. "[SPORES] " .. self.colors.reset .. "Deleted guide: " .. name)
    self:RefreshGuideDisplay()
end

-- ============================================
-- GUIDE: CHECKLIST (stubs - full logic next)
-- ============================================
function   SPORES:ClearGuideChecklist()
    -- Clear scroll area children
    local guideTab = GetControl(self.ui.mainWindow, "_GuideTab")
    local scrollArea = guideTab and GetControl(guideTab, "_GuideScroll")
    if not scrollArea then return end
    -- Destroy any dynamically created children
    if self.guideChecklistControls then
        for _, ctrl in ipairs(self.guideChecklistControls) do
            ctrl:SetHidden(true)
            ctrl:ClearAnchors()
        end
    end
    self.guideChecklistControls = {}
end

function   SPORES:BuildGuideChecklist(guideData)
    d("[SPORES DEBUG] BuildGuideChecklist called")
    self:ClearGuideChecklist()
    if not guideData then d("[SPORES DEBUG] guideData is nil") return end
    d("[SPORES DEBUG] guideData exists, checking scroll area")
    
    local guideTab = GetControl(self.ui.mainWindow, "_GuideTab")
    local scrollArea = guideTab and GetControl(guideTab, "_GuideScroll")
    if not scrollArea then return end
    
    self.guideChecklistControls = {}
    local yOffset = 0
    
    d("[SPORES DEBUG] scrollArea width: " .. tostring(scrollArea:GetWidth()) .. " height: " .. tostring(scrollArea:GetHeight()))
    d("[SPORES DEBUG] guideData.i exists: " .. tostring(guideData.i ~= nil))
    d("[SPORES DEBUG] guideData.g exists: " .. tostring(guideData.g ~= nil))
    d("[SPORES DEBUG] guideData.s exists: " .. tostring(guideData.s ~= nil))
    d("[SPORES DEBUG] guideData.vn exists: " .. tostring(guideData.vn ~= nil))
    
    -- Helper: create a section header
    local function addHeader(text)
        local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        label:SetFont("ZoFontWinH4")
        label:SetColor(1, 0.84, 0, 1)
        label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 5, yOffset)
        label:SetDimensions(620, 22)
        label:SetText(text)
        table.insert(self.guideChecklistControls, label)
        yOffset = yOffset + 26
    end
    
    -- Helper: create a content row
    local function addRow(text, color)
        color = color or {0.8, 0.8, 0.8, 1}
        local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetColor(unpack(color))
        label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 15, yOffset)
        label:SetDimensions(610, 20)
        label:SetText(text)
        table.insert(self.guideChecklistControls, label)
        yOffset = yOffset + 20
    end
    
    -- Helper: add a thin separator line
    local function addSeparator()
        yOffset = yOffset + 4
        local sep = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_BACKDROP)
        sep:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 10, yOffset)
        sep:SetDimensions(620, 2)
        sep:SetCenterColor(0.4, 0.4, 0.4, 0.6)
        sep:SetEdgeColor(0, 0, 0, 0)
        table.insert(self.guideChecklistControls, sep)
        yOffset = yOffset + 8
    end
    
    -- Slot compact key to display name
    local slotNames = {
        h = "Head", sh = "Shoulders", c = "Chest", ha = "Hands",
        w = "Waist", l = "Legs", f = "Feet",
        n = "Necklace", r1 = "Ring 1", r2 = "Ring 2",
        mh = "Main Hand", oh = "Off Hand", bm = "Backbar Main", bo = "Backbar Off"
    }
    
    -- Quality ID to display color
    local qualityColors = {
        [1] = {0.8, 0.8, 0.8, 1},
        [2] = {0.2, 0.8, 0.2, 1},
        [3] = {0.3, 0.5, 1, 1},
        [4] = {0.6, 0.2, 0.9, 1},
        [5] = {1, 0.84, 0, 1},
    }
    
    -- Armor weight ID to name
    local weightNames = { [1] = "Light", [2] = "Medium", [3] = "Heavy" }
    
    -- Weapon type ID to name
    local weaponNames = {
        [1] = "Sword", [2] = "Axe", [3] = "Hammer",
        [4] = "2H Sword", [5] = "2H Axe", [6] = "2H Hammer",
        [7] = "Bow", [9] = "Resto Staff", [10] = "Rune",
        [11] = "Dagger", [12] = "Inferno Staff", [13] = "Ice Staff",
        [14] = "Shield", [15] = "Lightning Staff"
    }
    
    -- ======= CHARACTER INFO =======
    addSeparator()
    if guideData.i then
        addHeader("CHARACTER")
        
        local raceNames = {
            [1] = "Breton", [2] = "Redguard", [3] = "Orc", [4] = "Dark Elf",
            [5] = "Nord", [6] = "Argonian", [7] = "High Elf", [8] = "Wood Elf",
            [9] = "Khajiit", [10] = "Imperial"
        }
        local classNames = {
            [1] = "Dragonknight", [2] = "Sorcerer", [3] = "Nightblade",
            [4] = "Warden", [5] = "Necromancer", [6] = "Templar", [117] = "Arcanist"
        }
        
        local race = raceNames[guideData.i.r] or "Unknown"
        local class = classNames[guideData.i.c] or "Unknown"
        local mundus = guideData.i.m or "None"
        
        -- Line 1: Race (left) + Mundus (right, aligned with trait column)
        local raceCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        raceCtrl:SetFont("ZoFontGame")
        raceCtrl:SetColor(0.8, 0.8, 0.8, 1)
        raceCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 15, yOffset)
        raceCtrl:SetHeight(18)
        raceCtrl:SetText(race)
        table.insert(self.guideChecklistControls, raceCtrl)
        
        local mundusLbl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        mundusLbl:SetFont("ZoFontGame")
        mundusLbl:SetColor(0.6, 0.6, 0.6, 1)
        mundusLbl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 355, yOffset)
        mundusLbl:SetHeight(18)
        mundusLbl:SetText("Mundus:")
        table.insert(self.guideChecklistControls, mundusLbl)
        
        local mundusVal = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        mundusVal:SetFont("ZoFontGame")
        mundusVal:SetColor(0.8, 0.8, 0.8, 1)
        mundusVal:SetAnchor(LEFT, mundusLbl, RIGHT, 6, 0)
        mundusVal:SetHeight(18)
        mundusVal:SetText(mundus)
        table.insert(self.guideChecklistControls, mundusVal)
        yOffset = yOffset + 20
        
        -- Line 2: Class
        addRow(class)
        
        -- Line 3: Attributes - three centered columns (Magicka / Health / Stamina)
        if guideData.a then
            local magVal = guideData.a.magicka or 0
            local hpVal = guideData.a.health or 0
            local stamVal = guideData.a.stamina or 0
            
            -- Attribute columns with tight spacing
            -- Magicka (blue: 0.46, 0.72, 1.0)
            local magNum = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            magNum:SetFont("ZoFontGame")
            magNum:SetColor(1, 1, 1, 1)
            magNum:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 185, yOffset)
            magNum:SetHeight(18)
            magNum:SetText(tostring(magVal))
            table.insert(self.guideChecklistControls, magNum)
            
            local magLbl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            magLbl:SetFont("ZoFontGame")
            magLbl:SetColor(0.46, 0.72, 1.0, 1)
            magLbl:SetAnchor(LEFT, magNum, RIGHT, 4, 0)
            magLbl:SetHeight(18)
            magLbl:SetText("Magicka")
            table.insert(self.guideChecklistControls, magLbl)
            
            -- Health (red: 0.9, 0.2, 0.2)
            local hpNum = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            hpNum:SetFont("ZoFontGame")
            hpNum:SetColor(1, 1, 1, 1)
            hpNum:SetAnchor(LEFT, magLbl, RIGHT, 20, 0)
            hpNum:SetHeight(18)
            hpNum:SetText(tostring(hpVal))
            table.insert(self.guideChecklistControls, hpNum)
            
            local hpLbl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            hpLbl:SetFont("ZoFontGame")
            hpLbl:SetColor(0.9, 0.2, 0.2, 1)
            hpLbl:SetAnchor(LEFT, hpNum, RIGHT, 4, 0)
            hpLbl:SetHeight(18)
            hpLbl:SetText("Health")
            table.insert(self.guideChecklistControls, hpLbl)
            
            -- Stamina (green: 0.2, 0.8, 0.2)
            local stamNum = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            stamNum:SetFont("ZoFontGame")
            stamNum:SetColor(1, 1, 1, 1)
            stamNum:SetAnchor(LEFT, hpLbl, RIGHT, 20, 0)
            stamNum:SetHeight(18)
            stamNum:SetText(tostring(stamVal))
            table.insert(self.guideChecklistControls, stamNum)
            
            local stamLbl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            stamLbl:SetFont("ZoFontGame")
            stamLbl:SetColor(0.2, 0.8, 0.2, 1)
            stamLbl:SetAnchor(LEFT, stamNum, RIGHT, 4, 0)
            stamLbl:SetHeight(18)
            stamLbl:SetText("Stamina")
            table.insert(self.guideChecklistControls, stamLbl)
            
            yOffset = yOffset + 20
        end

        yOffset = yOffset + 6
        addSeparator()
    end
    
    -- ======= GUIDE CONTENT TABS =======
    yOffset = yOffset + 6
    local tabStartY = yOffset
    local activeGuideTab = self.activeGuideTab or 1
    
    local function createGuideTab(xPos, width, text, isActive)
        local btn = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_BUTTON)
        btn:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, xPos, tabStartY)
        btn:SetDimensions(width, 28)
        btn:SetFont("ZoFontGameBold")
        btn:SetMouseEnabled(true)
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetText(text)
        if isActive then
            btn:SetNormalFontColor(1, 0.84, 0, 1)
            btn:SetMouseOverFontColor(1, 0.9, 0.3, 1)
        else
            btn:SetNormalFontColor(0.6, 0.6, 0.6, 1)
            btn:SetMouseOverFontColor(0.8, 0.8, 0.8, 1)
        end
        table.insert(self.guideChecklistControls, btn)
        return btn
    end
    
    local tab2Label = guideData.vn and "Loadout & Perks" or "Champion Points"
    local tab1Btn = createGuideTab(10, 305, "Gear & Skills", activeGuideTab == 1)
    local tab2Btn = createGuideTab(325, 305, tab2Label, activeGuideTab == 2)
    
    tab1Btn:SetHandler("OnClicked", function()
        if self.activeGuideTab ~= 1 then
            self.activeGuideTab = 1
            self:BuildGuideChecklist(guideData)
        end
    end)
    tab2Btn:SetHandler("OnClicked", function()
        if self.activeGuideTab ~= 2 then
            self.activeGuideTab = 2
            self:BuildGuideChecklist(guideData)
        end
    end)
    
    yOffset = tabStartY + 34
    addSeparator()
    
    if activeGuideTab == 1 then
    -- ======= GEAR =======
    if guideData.g then
        yOffset = yOffset + 6
        addHeader("GEAR")
        
        local slotOrder = {"h", "sh", "c", "ha", "w", "l", "f", "n", "r1", "r2", "mh", "oh", "bm", "bo"}
        
        for _, slotKey in ipairs(slotOrder) do
            local gearArr = guideData.g[slotKey]
            if gearArr then
                local setId = gearArr[1] or 0
                local quality = gearArr[4] or 5
                local typeVal = gearArr[5] or 0
                
                -- Resolve set name from guide data (provided by website)
                local setName = "Unknown Set"
                if type(gearArr[8]) == "string" and gearArr[8] ~= "" then
                    setName = gearArr[8]
                elseif setId > 0 then
                    setName = "Set #" .. setId
                end
                
                local slotLabel = slotNames[slotKey] or slotKey
                local qColor = qualityColors[quality] or qualityColors[5]
                
                -- Trait lookup
                local traitNames = {
                    [0] = "None", [1] = "Powered", [2] = "Charged", [3] = "Precise",
                    [4] = "Infused", [5] = "Defending", [6] = "Training", [7] = "Sharpened",
                    [8] = "Decisive", [9] = "Nirnhoned",
                    [11] = "Sturdy", [12] = "Impenetrable", [13] = "Reinforced",
                    [14] = "Well-Fitted", [15] = "Training", [16] = "Infused",
                    [17] = "Invigorating", [18] = "Divines", [19] = "Nirnhoned",
                    [22] = "Healthy", [23] = "Arcane", [24] = "Robust",
                    [25] = "Triune", [26] = "Infused", [27] = "Protective",
                    [28] = "Swift", [29] = "Harmony", [30] = "Bloodthirsty",
                }
                local traitId = gearArr[2] or 0
                local traitStr = ""
                if type(gearArr[6]) == "string" and gearArr[6] ~= "" then
                    -- Title case and strip redundant " Trait" suffix
                    traitStr = gearArr[6]:lower():gsub("(%a)([%w]*)", function(a, b) return a:upper() .. b end):gsub(" Trait$", "")
                elseif traitId > 0 and traitNames[traitId] then
                    traitStr = traitNames[traitId]
                end
                local enchantStr = ""
                if type(gearArr[7]) == "string" and gearArr[7] ~= "" then
                    -- Title case and strip "Enchantment" suffix
                    enchantStr = gearArr[7]:lower():gsub("(%a)([%w]*)", function(a, b) return a:upper() .. b end):gsub(" Enchantment$", "")
                end
                
                -- Type info (weight or weapon)
                local typeStr = ""
                if weightNames[typeVal] then
                    typeStr = weightNames[typeVal]
                elseif weaponNames[typeVal] then
                    typeStr = weaponNames[typeVal]
                end
                
                -- Set name + type as one unit
                local setAndType = setName
                
                -- Create slot label in white (col 1)
                local slotCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                slotCtrl:SetFont("ZoFontGame")
                slotCtrl:SetColor(1, 1, 1, 1)
                slotCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 15, yOffset)
                slotCtrl:SetDimensions(80, 18)
                slotCtrl:SetText(slotLabel .. ":")
                table.insert(self.guideChecklistControls, slotCtrl)
                
                -- Set name in quality color, then type in grey (inline)
                local setCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                setCtrl:SetFont("ZoFontGame")
                setCtrl:SetColor(unpack(qColor))
                setCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 105, yOffset)
                setCtrl:SetHeight(18)
                setCtrl:SetText(setAndType)
                table.insert(self.guideChecklistControls, setCtrl)
                
                -- Type in grey anchored right after set name
                if typeStr ~= "" then
                    local typeCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                    typeCtrl:SetFont("ZoFontGame")
                    typeCtrl:SetColor(0.7, 0.7, 0.7, 1)
                    typeCtrl:SetAnchor(LEFT, setCtrl, RIGHT, 6, 0)
                    typeCtrl:SetDimensions(100, 18)
                    typeCtrl:SetText("(" .. typeStr .. ")")
                    table.insert(self.guideChecklistControls, typeCtrl)
                end
                
                -- Trait in white (col 3 - fixed position)
                if traitStr ~= "" then
                    local traitCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                    traitCtrl:SetFont("ZoFontGame")
                    traitCtrl:SetColor(0.8, 0.8, 0.8, 1)
                    traitCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 370, yOffset)
                    traitCtrl:SetDimensions(120, 18)
                    traitCtrl:SetText(traitStr)
                    table.insert(self.guideChecklistControls, traitCtrl)
                end
                
                -- Enchant in white (col 4 - fixed position)
                if enchantStr ~= "" then
                    local enchCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                    enchCtrl:SetFont("ZoFontGame")
                    enchCtrl:SetColor(0.7, 0.7, 0.7, 1)
                    enchCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, 495, yOffset)
                    enchCtrl:SetDimensions(200, 18)
                    enchCtrl:SetText(enchantStr)
                    table.insert(self.guideChecklistControls, enchCtrl)
                end
                
                yOffset = yOffset + 20
            end
        end
        
        yOffset = yOffset + 6
        addSeparator()
    end
    
    -- ======= SKILLS (2-column) =======
    if guideData.s then
        yOffset = yOffset + 6
        addHeader("SKILLS")
        
        -- Helper to resolve skill name
        local function resolveSkillName(skillEntry)
            if type(skillEntry) == "number" and skillEntry > 0 then
                local name = GetAbilityName(skillEntry)
                return (name and name ~= "") and name or ("Ability #" .. skillEntry)
            elseif type(skillEntry) == "table" and skillEntry.g then
                if skillEntry.n and skillEntry.n ~= "" then
                    return skillEntry.n
                end
                local name = GetCraftedAbilityDisplayName and GetCraftedAbilityDisplayName(skillEntry.g) or ""
                return (name and name ~= "") and (name .. " (Scribed)") or ("Scribed #" .. (skillEntry.g or 0))
            end
            return "Empty"
        end
        
        local hasWW = guideData.s.b3 and #guideData.s.b3 > 0
        local colLeft, colRight, colWW, colWidth
        if hasWW then
            colLeft = 15
            colRight = 220
            colWW = 430
            colWidth = 195
        else
            colLeft = 15
            colRight = 325
            colWidth = 295
        end
        
        -- Bar headers (Front, Back, and optionally Werewolf)
        local fbHeader = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        fbHeader:SetFont("ZoFontGameBold")
        fbHeader:SetColor(1, 0.84, 0, 0.8)
        fbHeader:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colLeft, yOffset)
        fbHeader:SetDimensions(colWidth, 20)
        fbHeader:SetText("Front Bar:")
        table.insert(self.guideChecklistControls, fbHeader)
        
        local bbHeader = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
        bbHeader:SetFont("ZoFontGameBold")
        bbHeader:SetColor(1, 0.84, 0, 0.8)
        bbHeader:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colRight, yOffset)
        bbHeader:SetDimensions(colWidth, 20)
        bbHeader:SetText("Back Bar:")
        table.insert(self.guideChecklistControls, bbHeader)
        
        if hasWW then
            local wwHeader = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            wwHeader:SetFont("ZoFontGameBold")
            wwHeader:SetColor(1, 0.84, 0, 0.8)
            wwHeader:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colWW, yOffset)
            wwHeader:SetDimensions(colWidth, 20)
            wwHeader:SetText("Werewolf Bar:")
            table.insert(self.guideChecklistControls, wwHeader)
        end
        
        yOffset = yOffset + 28
        
        local b1 = guideData.s.b1 or {}
        local b2 = guideData.s.b2 or {}
        local b3 = hasWW and guideData.s.b3 or {}
        
        -- Skills 1-5 (all bars side by side)
        for i = 1, 5 do
            if b1[i] then
                local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                label:SetFont("ZoFontGame")
                label:SetColor(0.9, 0.9, 0.9, 1)
                label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colLeft, yOffset)
                label:SetDimensions(colWidth, 18)
                label:SetText(resolveSkillName(b1[i]))
                table.insert(self.guideChecklistControls, label)
            end
            if b2[i] then
                local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                label:SetFont("ZoFontGame")
                label:SetColor(0.9, 0.9, 0.9, 1)
                label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colRight, yOffset)
                label:SetDimensions(colWidth, 18)
                label:SetText(resolveSkillName(b2[i]))
                table.insert(self.guideChecklistControls, label)
            end
            if b3[i] then
                local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                label:SetFont("ZoFontGame")
                label:SetColor(0.9, 0.9, 0.9, 1)
                label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colWW, yOffset)
                label:SetDimensions(colWidth, 18)
                label:SetText(resolveSkillName(b3[i]))
                table.insert(self.guideChecklistControls, label)
            end
            yOffset = yOffset + 20
        end
        
        -- Gap before ultimate
        yOffset = yOffset + 6
        
        -- Ultimate (slot 6, all bars)
        if b1[6] then
            local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetColor(0.9, 0.9, 0.9, 1)
            label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colLeft, yOffset)
            label:SetDimensions(colWidth, 18)
            label:SetText(resolveSkillName(b1[6]))
            table.insert(self.guideChecklistControls, label)
        end
        if b2[6] then
            local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetColor(0.9, 0.9, 0.9, 1)
            label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colRight, yOffset)
            label:SetDimensions(colWidth, 18)
            label:SetText(resolveSkillName(b2[6]))
            table.insert(self.guideChecklistControls, label)
        end
        if b3[6] then
            local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetColor(0.9, 0.9, 0.9, 1)
            label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colWW, yOffset)
            label:SetDimensions(colWidth, 18)
            label:SetText(resolveSkillName(b3[6]))
            table.insert(self.guideChecklistControls, label)
        end
        yOffset = yOffset + 20
        
    end
    
    -- ======= CLASS MASTERY (enabled passives, ≤2) =======
    -- cm = array of ability IDs; names resolved in-game via GetAbilityName,
    -- mirroring the skills section. Rendered as a single comma-joined row to
    -- conserve vertical space. Non-Vengeance only (export-gated).
    if activeGuideTab == 1 and guideData.cm and #guideData.cm > 0 then
        yOffset = yOffset + 6
        local masteryNames = {}
        for _, abilityId in ipairs(guideData.cm) do
            if type(abilityId) == "number" and abilityId > 0 then
                local name = GetAbilityName(abilityId)
                masteryNames[#masteryNames + 1] = (name and name ~= "") and name or ("Ability #" .. abilityId)
            end
        end
        if #masteryNames > 0 then
            -- Gold "Class Mastery:" label (matches section headers) + soft-purple names,
            -- two-toned in one row via inline color markup to preserve the single-row fit.
            addRow("|cFFD700Class Mastery:|r  |cD9BFF2" .. table.concat(masteryNames, ", ") .. "|r", {1, 1, 1, 1})
        end
    end
    
    end -- if activeGuideTab == 1
    
    -- ======= CHAMPION POINTS (3-column) =======
    -- Hidden entirely for Vengeance builds (CP doesn't apply; vn section replaces it).
    if activeGuideTab == 2 and guideData.cp and not guideData.vn then
        yOffset = yOffset + 6
        addHeader("CHAMPION POINTS")
        
        local discColors = {
            w = {0.46, 0.72, 1.0, 1},
            f = {0.9, 0.2, 0.2, 1},
            c = {0.2, 0.8, 0.2, 1},
        }
        local discNames = { w = "Warfare", f = "Fitness", c = "Craft" }
        local discOrder = {"w", "f", "c"}
        local colPositions = { w = 5, f = 210, c = 420 }
        local colWidth = 195
        
        -- New format: cp.warfare/fitness/craft with .slotted[] and .passives[] as name strings
        local discToKey = { warfare = "w", fitness = "f", craft = "c" }
        
        local discData = {}
        for discName, discKey in pairs(discToKey) do
            local disc = guideData.cp[discName]
            if disc then
                discData[discKey] = {
                    slotted = disc.slotted or {},
                    passives = disc.passives or {}
                }
            else
                discData[discKey] = { slotted = {}, passives = {} }
            end
        end
        
        -- Slotted headers
        for _, discKey in ipairs(discOrder) do
            local headerCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
            headerCtrl:SetFont("ZoFontGame")
            headerCtrl:SetColor(unpack(discColors[discKey]))
            headerCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colPositions[discKey], yOffset)
            headerCtrl:SetDimensions(colWidth, 18)
            headerCtrl:SetText(discNames[discKey] .. " - Slotted")
            table.insert(self.guideChecklistControls, headerCtrl)
        end
        yOffset = yOffset + 22
        
        -- Slotted skills
        local maxSlotted = 0
        for _, discKey in ipairs(discOrder) do
            maxSlotted = math.max(maxSlotted, #discData[discKey].slotted)
        end
        for row = 1, maxSlotted do
            for _, discKey in ipairs(discOrder) do
                local name = discData[discKey].slotted[row]
                if name then
                    local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                    label:SetFont("ZoFontGame")
                    label:SetColor(1, 1, 1, 1)
                    label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colPositions[discKey] + 5, yOffset)
                    label:SetDimensions(colWidth - 5, 18)
                    label:SetText(name)
                    table.insert(self.guideChecklistControls, label)
                end
            end
            yOffset = yOffset + 18
        end
        yOffset = yOffset + 8
        
        -- Passive headers
        for _, discKey in ipairs(discOrder) do
            if #discData[discKey].passives > 0 then
                local headerCtrl = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                headerCtrl:SetFont("ZoFontGame")
                headerCtrl:SetColor(unpack(discColors[discKey]))
                headerCtrl:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colPositions[discKey], yOffset)
                headerCtrl:SetDimensions(colWidth, 18)
                headerCtrl:SetText(discNames[discKey] .. " - Passives")
                table.insert(self.guideChecklistControls, headerCtrl)
            end
        end
        yOffset = yOffset + 22
        
        -- Passive skills
        local maxPassives = 0
        for _, discKey in ipairs(discOrder) do
            maxPassives = math.max(maxPassives, #discData[discKey].passives)
        end
        for row = 1, maxPassives do
            for _, discKey in ipairs(discOrder) do
                local name = discData[discKey].passives[row]
                if name then
                    local label = WINDOW_MANAGER:CreateControl(nil, scrollArea, CT_LABEL)
                    label:SetFont("ZoFontGame")
                    label:SetColor(1, 1, 1, 1)
                    label:SetAnchor(TOPLEFT, scrollArea, TOPLEFT, colPositions[discKey] + 5, yOffset)
                    label:SetDimensions(colWidth - 5, 18)
                    label:SetText(name)
                    table.insert(self.guideChecklistControls, label)
                end
            end
            yOffset = yOffset + 18
        end
    end

    -- ======= VENGEANCE LOADOUT & PERKS (tab 2, replaces CP for Vengeance) =======
    if activeGuideTab == 2 and guideData.vn then
        local vn = guideData.vn
        yOffset = yOffset + 6
        addHeader("VENGEANCE LOADOUT")

        local loadoutName = vn.ln or (vn.lo and ("Loadout #" .. vn.lo)) or "Unknown"
        addRow(loadoutName, {1, 1, 1, 1})
        yOffset = yOffset + 6

        addHeader("VENGEANCE PERKS")
        local perkRows = {
            { name = vn.prn, idx = vn.pr, label = "Red",    color = {0.87, 0.36, 0.31, 1} },
            { name = vn.pyn, idx = vn.py, label = "Yellow", color = {0.76, 0.67, 0.29, 1} },
            { name = vn.pbn, idx = vn.pb, label = "Blue",   color = {0.31, 0.51, 0.74, 1} },
        }
        for _, p in ipairs(perkRows) do
            if p.idx then
                local pname = p.name or ("Perk #" .. p.idx)
                addRow(p.label .. ":  " .. pname, p.color)
            end
        end
    end
end

-- ============================================
-- POSITION MANAGEMENT
-- ============================================
function   SPORES:RestorePositions()
    self.ui.mainWindow:ClearAnchors()
    self.ui.mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.windowPos.x, self.sv.windowPos.y)
    
    self.ui.minButton:ClearAnchors()
    self.ui.minButton:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.minButtonPos.x, self.sv.minButtonPos.y)
end

function   SPORES:SetupDragHandlers()
    self.ui.mainWindow:SetHandler("OnMoveStop", function()
        if not self.sv.positionLocked then
            self.sv.windowPos.x = self.ui.mainWindow:GetLeft()
            self.sv.windowPos.y = self.ui.mainWindow:GetTop()
        end
    end)
    
    self.ui.minButton:SetHandler("OnMouseUp", function(control, button, upInside)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
              SPORES:ToggleWindow()
        end
    end)
    
    self.ui.minButton:SetHandler("OnMoveStop", function()
        if not self.sv.positionLocked then
            self.sv.minButtonPos.x = self.ui.minButton:GetLeft()
            self.sv.minButtonPos.y = self.ui.minButton:GetTop()
        end
    end)
end

-- ============================================
-- POSITION LOCK
-- ============================================
function   SPORES:SetupLockButton()
    local lockBtn = GetControl(self.ui.mainWindow, "_LockBtn")
    if not lockBtn then return end
    
    self.ui.lockBtn = lockBtn
    
    -- Create backdrop
    local lockBg = WINDOW_MANAGER:CreateControl(nil, lockBtn, CT_BACKDROP)
    lockBg:SetAnchorFill(lockBtn)
    lockBg:SetDrawLevel(0)
    self.ui.lockBtnBg = lockBg
    
    -- Create icon label
    local lockIcon = WINDOW_MANAGER:CreateControl(nil, lockBtn, CT_LABEL)
    lockIcon:SetAnchorFill(lockBtn)
    lockIcon:SetFont("ZoFontGameBold")
    lockIcon:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lockIcon:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.ui.lockIcon = lockIcon
    
    -- Set initial state
    self:UpdateLockButtonVisual()
end

function   SPORES:TogglePositionLock()
    self.sv.positionLocked = not self.sv.positionLocked
    
    -- Update movability
    self.ui.mainWindow:SetMovable(not self.sv.positionLocked)
    self.ui.minButton:SetMovable(not self.sv.positionLocked)
    
    -- Save current positions when locking
    if self.sv.positionLocked then
        self.sv.windowPos.x = self.ui.mainWindow:GetLeft()
        self.sv.windowPos.y = self.ui.mainWindow:GetTop()
        
        self.sv.minButtonPos.x = self.ui.minButton:GetLeft()
        self.sv.minButtonPos.y = self.ui.minButton:GetTop()
        
        d(self.colors.green .. "[SPORES]" .. self.colors.reset .. " Position locked")
    else
        d(self.colors.yellow .. "[SPORES]" .. self.colors.reset .. " Position unlocked - drag to reposition")
    end
    
    self:UpdateLockButtonVisual()
end

function   SPORES:UpdateLockButtonVisual()
    if not self.ui.lockBtnBg or not self.ui.lockIcon then return end
    
    if self.sv.positionLocked then
        -- Locked = Red/Orange (stopped, can't move)
        self.ui.lockBtnBg:SetCenterColor(0.4, 0.2, 0.2, 0.9)
        self.ui.lockBtnBg:SetEdgeColor(0.8, 0.3, 0, 1)
        self.ui.lockIcon:SetText("Locked")
        self.ui.lockIcon:SetColor(1, 0.5, 0, 1)
    else
        -- Unlocked = Green (go, can move)
        self.ui.lockBtnBg:SetCenterColor(0.2, 0.5, 0.2, 0.9)
        self.ui.lockBtnBg:SetEdgeColor(0, 0.8, 0, 1)
        self.ui.lockIcon:SetText("Unlocked")
        self.ui.lockIcon:SetColor(0, 1, 0, 1)
    end
end

-- ============================================
-- WINDOW TOGGLE
-- ============================================
function   SPORES:ToggleWindow()
    if self.ui.mainWindow:IsHidden() then
        self.ui.mainWindow:SetHidden(false)
        self.ui.minButton:SetHidden(true)
        self:SwitchTab("export")
    else
        self:MinimizeWindow()
    end
end

function   SPORES:MinimizeWindow()
    self.ui.mainWindow:SetHidden(true)
    self.ui.minButton:SetHidden(false)
end

-- ============================================
-- BUILD EXPORT - MAIN FUNCTION
-- ============================================
function   SPORES:ExportBuild()

    -- In ExportBuild, before collecting data:
    local numBuffs = GetNumBuffs("player")
    d("[SPORES] Debug - checking " .. numBuffs .. " buffs:")
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName then
            d("[SPORES] Buff " .. i .. ": " .. buffName)
        end
    end

    d(self.colors.cyan .. "[SPORES]" .. self.colors.reset .. " Collecting build data...")
    
    -- Compact build - IDs only, no names (website looks up names)
    local build = {
        v = self.SCHEMA_VERSION,
        u = GetDisplayName(),
    }
    
    local success, result
    
    -- Identity: race ID, class ID, level, CP, mundus, curse
    success, result = pcall(function() return self:CollectIdentityCompact() end)
    if success then build.i = result else d(self.colors.red .. "[SPORES] Identity error: " .. tostring(result) .. self.colors.reset) build.i = {} end
    
    -- Attributes: just 3 numbers
    success, result = pcall(function() return self:CollectAttributes() end)
    if success then build.a = result else d(self.colors.red .. "[SPORES] Attributes error: " .. tostring(result) .. self.colors.reset) build.a = {} end
    
    -- Skills: bar ability IDs only
    success, result = pcall(function() return self:CollectSkillsCompact() end)
    if success then build.s = result else d(self.colors.red .. "[SPORES] Skills error: " .. tostring(result) .. self.colors.reset) build.s = {} end
    
    -- Scribing: grimoire configs (IDs only)
    success, result = pcall(function() return self:CollectScribingCompact() end)
    if success then build.sc = result else d(self.colors.red .. "[SPORES] Scribing error: " .. tostring(result) .. self.colors.reset) build.sc = {} end
    
    -- Gear: set IDs, traits, enchants (IDs only)
    success, result = pcall(function() return self:CollectGearCompact() end)
    if success then build.g = result else d(self.colors.red .. "[SPORES] Gear error: " .. tostring(result) .. self.colors.reset) build.g = {} end
    
    -- CP: allocations and slotted (IDs only)
    success, result = pcall(function() return self:CollectChampionPointsCompact() end)
    if success then build.cp = result else d(self.colors.red .. "[SPORES] CP error: " .. tostring(result) .. self.colors.reset) build.cp = {} end
    
    -- Vengeance loadout + perks (only for Vengeance builds)
    if self:IsVengeanceBuild() then
        success, result = pcall(function() return self:CollectVengeanceCompact() end)
        if success then build.vn = result else d(self.colors.red .. "[SPORES] Vengeance error: " .. tostring(result) .. self.colors.reset) build.vn = {} end
    else
        -- Class Mastery enabled passives (non-Vengeance only — Mastery is locked out in Vengeance)
        success, result = pcall(function() return self:CollectClassMasteryCompact() end)
        if success then if #result > 0 then build.cm = result end else d(self.colors.red .. "[SPORES] Class Mastery error: " .. tostring(result) .. self.colors.reset) end
    end
    
    -- Convert to minified JSON for URL
    d(self.colors.cyan .. "[SPORES]" .. self.colors.reset .. " Converting to JSON...")
    
    success, result = pcall(function() return self:TableToJSONMin(build) end)
    if not success then
        d(self.colors.red .. "[SPORES] JSON error: " .. tostring(result) .. self.colors.reset)
        return
    end
    
    local json = result
    d(self.colors.cyan .. "[SPORES]" .. self.colors.reset .. " JSON length: " .. string.len(json))
    
    -- Base64 encode the JSON
    local encoded = self:Base64Encode(json)
    d(self.colors.cyan .. "[SPORES]" .. self.colors.reset .. " Encoded length: " .. string.len(encoded))
    
    -- // Build the import URL ( LIVE or LOCALHOST for testing ) //
    local importUrl = "https://theeldersporesonline.com/buildeditor.html?import=" .. encoded
    -- local importUrl = "http://localhost:3001/buildeditor.html?import=" .. encoded
    
    -- Display info in EditBox
    if self.ui.exportEditBox then
        self.ui.exportEditBox:SetText("Build data ready!\n\nClick 'Open in Browser' below to send your build to TheElderSporesOnline.com\n\nURL length: " .. string.len(importUrl) .. " characters")
    end
    
    -- Store URL for the browser button
    self.pendingExportUrl = importUrl
    
    d(self.colors.green .. "[SPORES]" .. self.colors.reset .. " Build ready! Click 'Open in Browser' to export.")
end

-- ============================================
-- IDENTITY COLLECTION
-- ============================================

function   SPORES:GetCurseStatus()
    -- Check buffs for Vampire or Werewolf status
    local numBuffs = GetNumBuffs("player")
    
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName then
            local lowerName = string.lower(buffName)
            -- Vampire stages show as "Vampirism" or stage-related buffs
            if string.find(lowerName, "vampirism") or string.find(lowerName, "vampire") then
                return "Vampire"
            end
            -- Werewolf transformation buff
            if string.find(lowerName, "werewolf") then
                return "Werewolf"
            end
        end
    end
    
    -- Alternative: Check skill lines for unlocked Vampire/Werewolf
    local worldSkillType = SKILL_TYPE_WORLD
    local numLines = GetNumSkillLines(worldSkillType)
    
    for lineIndex = 1, numLines do
        local lineName, lineRank, discovered = GetSkillLineInfo(worldSkillType, lineIndex)
        if discovered and lineName then
            if lineName == "Vampire" then
                return "Vampire"
            elseif lineName == "Werewolf" then
                return "Werewolf"
            end
        end
    end
    
    return "none"
end

-- ============================================
-- ATTRIBUTES COLLECTION
-- ============================================
function   SPORES:CollectAttributes()
    return {
        health = GetAttributeSpentPoints(ATTRIBUTE_HEALTH),
        magicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA),
        stamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA),
    }
end

-- ============================================
-- GEAR COLLECTION
-- ============================================

function   SPORES:GetQualityName(quality)
    local qualityNames = {
        [ITEM_DISPLAY_QUALITY_TRASH] = "trash",
        [ITEM_DISPLAY_QUALITY_NORMAL] = "normal",
        [ITEM_DISPLAY_QUALITY_MAGIC] = "fine",
        [ITEM_DISPLAY_QUALITY_ARCANE] = "superior",
        [ITEM_DISPLAY_QUALITY_ARTIFACT] = "epic",
        [ITEM_DISPLAY_QUALITY_LEGENDARY] = "legendary",
        [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "mythic",
    }
    return qualityNames[quality] or "normal"
end

function   SPORES:GetTraitName(traitType, category)
    local traitNames = {
        -- Armor traits
        [ITEM_TRAIT_TYPE_ARMOR_STURDY] = "Sturdy",
        [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "Impenetrable",
        [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "Reinforced",
        [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "Well-Fitted",
        [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "Training",
        [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "Infused",
        [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "Prosperous",
        [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "Divines",
        [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "Nirnhoned",
        
        -- Weapon traits
        [ITEM_TRAIT_TYPE_WEAPON_POWERED] = "Powered",
        [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "Charged",
        [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "Precise",
        [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "Infused",
        [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "Defending",
        [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "Training",
        [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "Sharpened",
        [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "Decisive",
        [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "Nirnhoned",
        
        -- Jewelry traits
        [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "Arcane",
        [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "Healthy",
        [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "Robust",
        [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "Triune",
        [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "Infused",
        [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "Protective",
        [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "Swift",
        [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "Harmony",
        [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "Bloodthirsty",
    }
    
    return traitNames[traitType] or "None"
end

function   SPORES:GetArmorWeightName(armorType)
    local weightNames = {
        [ARMORTYPE_LIGHT] = "light",
        [ARMORTYPE_MEDIUM] = "medium",
        [ARMORTYPE_HEAVY] = "heavy",
    }
    return weightNames[armorType] or "none"
end

function   SPORES:GetWeaponTypeName(weaponType)
    local weaponNames = {
        [WEAPONTYPE_AXE] = "Axe",
        [WEAPONTYPE_HAMMER] = "Mace",
        [WEAPONTYPE_SWORD] = "Sword",
        [WEAPONTYPE_TWO_HANDED_AXE] = "Battle Axe",
        [WEAPONTYPE_TWO_HANDED_HAMMER] = "Maul",
        [WEAPONTYPE_TWO_HANDED_SWORD] = "Greatsword",
        [WEAPONTYPE_BOW] = "Bow",
        [WEAPONTYPE_DAGGER] = "Dagger",
        [WEAPONTYPE_FIRE_STAFF] = "Fire Staff",
        [WEAPONTYPE_FROST_STAFF] = "Ice Staff",
        [WEAPONTYPE_LIGHTNING_STAFF] = "Lightning Staff",
        [WEAPONTYPE_HEALING_STAFF] = "Restoration Staff",
        [WEAPONTYPE_SHIELD] = "Shield",
    }
    return weaponNames[weaponType] or "Unknown"
end

-- ============================================
-- CONSUMABLES COLLECTION
-- ============================================
function   SPORES:CollectConsumables()
    local consumables = {
        activeSlots = {
            frontBarPoison = self:GetEquippedPoison(EQUIP_SLOT_MAIN_HAND),
            backBarPoison = self:GetEquippedPoison(EQUIP_SLOT_BACKUP_MAIN),
            food = self:GetActiveFood(),
            potion = nil,  -- Can't easily detect equipped potion
        },
        favorites = {nil, nil, nil, nil, nil, nil},
    }
    
    return consumables
end

function   SPORES:GetEquippedPoison(weaponSlot)
    local poisonLink = GetItemLink(BAG_WORN, weaponSlot, LINK_STYLE_DEFAULT, ITEM_LINK_SOURCE_POISON)
    
    if poisonLink and poisonLink ~= "" then
        local itemName = GetItemLinkName(poisonLink)
        return {
            name = itemName,
            icon = GetItemLinkIcon(poisonLink),
        }
    end
    
    return nil
end

function   SPORES:GetActiveFood()
    -- Search buffs for food effects
    local numBuffs = GetNumBuffs("player")
    
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, icon, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        
        -- Food buffs typically have very long durations (1-2 hours) and specific ability types
        local duration = timeEnding - timeStarted
        if duration > 1800 and abilityType == ABILITY_TYPE_BONUS then
            -- This is likely a food buff
            return {
                name = buffName,
                abilityId = abilityId,
                icon = icon,
            }
        end
    end
    
    return nil
end

-- ============================================
-- COMPACT DATA COLLECTION (for URL export)
-- ============================================
-- Detects Vengeance by checking whether any CURRENTLY SLOTTED ability belongs
-- to a "Vengeance " skill line. Uses only APIs already proven in the extractor
-- (GetNumSkillLines / GetSkillLineInfo / GetNumSkillAbilities / GetSkillAbilityId).
function   SPORES:IsVengeanceBuild()
    -- 1) Build a set of all Vengeance-line ability IDs (name prefix "Vengeance ").
    local vengeanceIds = {}
    for skillTypeIndex = 1, 9 do
        local numLines = GetNumSkillLines(skillTypeIndex)
        if numLines and numLines > 0 then
            for lineIndex = 1, numLines do
                local lineName = GetSkillLineInfo(skillTypeIndex, lineIndex)
                if lineName and string.find(lineName, "Vengeance ") == 1 then
                    local numAbil = GetNumSkillAbilities(skillTypeIndex, lineIndex)
                    for a = 1, (numAbil or 0) do
                        local aId = GetSkillAbilityId(skillTypeIndex, lineIndex, a)
                        if aId and aId > 0 then vengeanceIds[aId] = true end
                    end
                end
            end
        end
    end

    -- 2) Check currently slotted front/back-bar abilities against that set.
    for _, category in ipairs({ HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }) do
        for i = 3, 8 do
            local slottedId = GetSlotBoundId(i, category)
            if slottedId and vengeanceIds[slottedId] then
                return true
            end
        end
    end

    return false
end

-- Reads equipped Vengeance loadout + perks from ZO_VENGEANCE_MANAGER.
-- vn = { lo = loadoutIndex, pr/py/pb = perk index per color slot }.
-- perkSlots is iterated in order: 1st=red, 2nd=yellow, 3rd=blue.
function   SPORES:CollectVengeanceCompact()
    local vn = {}
    local mgr = ZO_VENGEANCE_MANAGER
    if type(mgr) ~= "table" then return vn end

    local okL, loadoutData = pcall(function() return mgr:GetEquippedLoadoutData() end)
    if okL and type(loadoutData) == "table" and loadoutData.index then
        vn.lo = loadoutData.index
    end

    local slots = {}
    if type(mgr.perkSlots) == "table" then
        for _, slotId in ipairs(mgr.perkSlots) do
            slots[#slots + 1] = slotId
        end
    end

    local perkKeys = { "pr", "py", "pb" }
    for position, slotId in ipairs(slots) do
        local key = perkKeys[position]
        if key then
            local okP, perkIndex = pcall(function() return mgr:GetEquippedPerkIndexBySlot(slotId) end)
            if okP and type(perkIndex) == "number" and perkIndex > 0 then
                vn[key] = perkIndex
            end
        end
    end

    return vn
end

function   SPORES:CollectIdentityCompact()
    return {
        r = GetUnitRaceId("player"),
        c = GetUnitClassId("player"),
        l = GetUnitLevel("player"),
        cp = GetPlayerChampionPointsEarned(),
        m = self:GetActiveMundusId(),
        cu = self:GetCurseStatus(),
        ve = self:IsVengeanceBuild(),
    }
end

-- Reads enabled Class Mastery passives (skill type 1, line "Class Mastery").
-- Class Mastery options have no skill-point cost; the API exposes their enabled
-- state as the `purchased` return of GetSkillAbilityInfo. Returns an array of
-- the enabled ability IDs (≤2). Only the current class's line is populated
-- in-game, so a simple name match yields only the correct options.
function   SPORES:CollectClassMasteryCompact()
    local cm = {}
    local numLines = GetNumSkillLines(1)
    if not numLines or numLines == 0 then return cm end

    for lineIndex = 1, numLines do
        local lineName = GetSkillLineInfo(1, lineIndex)
        if lineName == "Class Mastery" then
            local numAbil = GetNumSkillAbilities(1, lineIndex)
            for a = 1, (numAbil or 0) do
                local _, _, _, _, _, purchased = GetSkillAbilityInfo(1, lineIndex, a)
                if purchased then
                    local aId = GetSkillAbilityId(1, lineIndex, a)
                    if aId and aId > 0 then
                        cm[#cm + 1] = aId
                        if #cm >= 2 then return cm end
                    end
                end
            end
        end
    end

    return cm
end

function   SPORES:GetActiveMundusId()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if buffName then
            -- Mundus boons show as "Boon: The Lord" etc
            if string.find(buffName, "Boon:") then
                -- Extract the mundus name after "Boon: "
                local mundusName = string.match(buffName, "Boon:%s*(.+)")
                if mundusName then
                    return mundusName
                end
            end
        end
    end
    return ""
end

function   SPORES:CollectSkillsCompact()
    local skills = {
        b1 = {},
        b2 = {},
    }
    
    -- Build grimoire lookup using proven API calls
    local grimoireSet = {}
    local numCrafted = GetNumCraftedAbilities()
    if numCrafted and numCrafted > 0 then
        for i = 1, numCrafted do
            local craftedAbilityId = GetCraftedAbilityIdAtIndex(i)
            if craftedAbilityId then
                grimoireSet[craftedAbilityId] = true
            end
        end
    end
    
    -- Front bar
    for i = 3, 8 do
        local abilityId = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
        if abilityId and grimoireSet[abilityId] then
            local f, s, a = GetCraftedAbilityActiveScriptIds(abilityId)
            d("[TESO-DEBUG] Front slot " .. i .. " SCRIBED grimoire=" .. abilityId .. " f=" .. tostring(f) .. " s=" .. tostring(s) .. " a=" .. tostring(a))
            table.insert(skills.b1, { g = abilityId, f = f or 0, s = s or 0, a = a or 0 })
        else
            table.insert(skills.b1, abilityId or 0)
        end
    end
    
    -- Back bar
    for i = 3, 8 do
        local abilityId = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
        if abilityId and grimoireSet[abilityId] then
            local f, s, a = GetCraftedAbilityActiveScriptIds(abilityId)
            d("[TESO-DEBUG] Back slot " .. i .. " SCRIBED grimoire=" .. abilityId .. " f=" .. tostring(f) .. " s=" .. tostring(s) .. " a=" .. tostring(a))
            table.insert(skills.b2, { g = abilityId, f = f or 0, s = s or 0, a = a or 0 })
        else
            table.insert(skills.b2, abilityId or 0)
        end
    end
    
    -- Werewolf bar
    if self:GetCurseStatus() == "Werewolf" then
        skills.b3 = {}
        for i = 3, 8 do
            local abilityId = GetSlotBoundId(i, HOTBAR_CATEGORY_WEREWOLF)
            d("[TESO-DEBUG] WW slot " .. i .. " abilityId=" .. tostring(abilityId) .. " name=" .. tostring(GetAbilityName(abilityId or 0)))
            if abilityId and grimoireSet[abilityId] then
                local f, s, a = GetCraftedAbilityActiveScriptIds(abilityId)
                table.insert(skills.b3, { g = abilityId, f = f or 0, s = s or 0, a = a or 0 })
            else
                table.insert(skills.b3, abilityId or 0)
            end
        end
    end
    
    return skills
end

function   SPORES:CollectScribingCompact()
    local scribing = {}
    
    local success = pcall(function()
        if not SCRIBING_DATA_MANAGER then return end
        
        local craftedAbilities = SCRIBING_DATA_MANAGER:GetAllCraftedAbilityData()
        d("[TESO-DEBUG] craftedAbilities type: " .. type(craftedAbilities))
        if not craftedAbilities then 
            d("[TESO-DEBUG] craftedAbilities is nil/false")
            return 
        end
        
        for _, craftedAbility in pairs(craftedAbilities) do
            local craftedAbilityId = craftedAbility:GetId()
            local abilityId = craftedAbility:GetAbilityId()
            
            if abilityId and abilityId > 0 then
                d("[TESO-DEBUG] Scribed: craftedAbilityId=" .. tostring(craftedAbilityId) .. " runtimeAbilityId=" .. tostring(abilityId))
                local primaryScriptId, secondaryScriptId, tertiaryScriptId = craftedAbility:GetScriptIds()
                if primaryScriptId or secondaryScriptId or tertiaryScriptId then
                    scribing[tostring(craftedAbilityId)] = {
                        primaryScriptId or 0,
                        secondaryScriptId or 0,
                        tertiaryScriptId or 0
                    }
                end
            end
        end
    end)
    
    if not success then
        d("[TESO-DEBUG] CollectScribingCompact pcall FAILED")
    end
    d("[TESO-DEBUG] Scribing entries collected: " .. tostring(#scribing))
    
    return scribing
end

function   SPORES:CollectGearCompact()
    local gear = {}
    
    local slots = {
        {EQUIP_SLOT_HEAD, "h"}, {EQUIP_SLOT_SHOULDERS, "sh"}, {EQUIP_SLOT_CHEST, "c"},
        {EQUIP_SLOT_HAND, "ha"}, {EQUIP_SLOT_WAIST, "w"}, {EQUIP_SLOT_LEGS, "l"},
        {EQUIP_SLOT_FEET, "f"}, {EQUIP_SLOT_NECK, "n"}, {EQUIP_SLOT_RING1, "r1"},
        {EQUIP_SLOT_RING2, "r2"}, {EQUIP_SLOT_MAIN_HAND, "mh"}, {EQUIP_SLOT_OFF_HAND, "oh"},
        {EQUIP_SLOT_BACKUP_MAIN, "bm"}, {EQUIP_SLOT_BACKUP_OFF, "bo"},
    }
    
    for _, slotData in ipairs(slots) do
        local slotId, key = slotData[1], slotData[2]
        local itemLink = GetItemLink(BAG_WORN, slotId, LINK_STYLE_DEFAULT)
        
        if itemLink and itemLink ~= "" then
            local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
            local traitType = GetItemLinkTraitInfo(itemLink)
            -- Parse enchant item ID from item link (position 6 in 1-indexed Lua array)
            -- Format: |H0:item:ItemId:SubType:Level:EnchantId:EnchantSubType:EnchantLevel:...
            -- Split: [1]|H0 [2]item [3]ItemId [4]SubType [5]Level [6]EnchantId ...
            local enchantId = 0
            local linkParts = {zo_strsplit(":", itemLink)}
            if linkParts[6] then
                enchantId = tonumber(linkParts[6]) or 0
            end
            -- DEBUG: Log what we're parsing
            d("[SPORES] Slot " .. key .. " link: " .. itemLink)
            d("[SPORES] Slot " .. key .. " parsed enchantId: " .. tostring(enchantId) .. " from position 6: " .. tostring(linkParts[6] or "nil"))
            local quality = GetItemLinkDisplayQuality(itemLink)
            local armorType = GetItemLinkArmorType(itemLink)
            local weaponType = GetItemWeaponType(BAG_WORN, slotId)
            
            gear[key] = {
                hasSet and setId or 0,
                traitType or 0,
                enchantId or 0,
                quality or 0,
                armorType > 0 and armorType or weaponType or 0
            }
        end
    end
    
    return gear
end

function   SPORES:CollectChampionPointsCompact()
    local cp = {
        w = {},  -- Warfare allocations
        f = {},  -- Fitness allocations
        c = {},  -- Craft allocations
        ws = {}, -- Warfare slotted
        fs = {}, -- Fitness slotted
        cs = {}, -- Craft slotted
    }
    
    local disciplineKeys = {[1] = "c", [2] = "w", [3] = "f"}
    local slottedKeys = {[1] = "cs", [2] = "ws", [3] = "fs"}
    
    for disciplineIndex = 1, 3 do
        local key = disciplineKeys[disciplineIndex]
        local slotKey = slottedKeys[disciplineIndex]
        local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
        
        for skillIndex = 1, numSkills do
            local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
            local points = GetNumPointsSpentOnChampionSkill(skillId)
            
            if points and points > 0 then
                cp[key][tostring(skillId)] = points
            end
        end
        
        -- Get slotted from champion hotbar (slots 1-4=Craft, 5-8=Warfare, 9-12=Fitness)
        local slotOffset = (disciplineIndex - 1) * 4
        for slotIndex = 1, 4 do
            local skillId = GetSlotBoundId(slotOffset + slotIndex, HOTBAR_CATEGORY_CHAMPION)
            if skillId and skillId > 0 then
                table.insert(cp[slotKey], skillId)
            end
        end
    end
    
    return cp
end

-- ============================================
-- JSON SERIALIZATION
-- ============================================
function   SPORES:TableToJSON(tbl, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    local nextSpaces = string.rep("  ", indent + 1)
    local result = {}
    
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return '"' .. self:EscapeJSON(tbl) .. '"'
        elseif type(tbl) == "boolean" then
            return tbl and "true" or "false"
        elseif tbl == nil then
            return "null"
        else
            return tostring(tbl)
        end
    end
    
    -- Check if array or object
    local isArray = #tbl > 0 or next(tbl) == nil
    local maxIndex = 0
    for k, _ in pairs(tbl) do
        if type(k) == "number" then
            maxIndex = math.max(maxIndex, k)
        else
            isArray = false
            break
        end
    end
    
    if isArray then
        table.insert(result, "[\n")
        local items = {}
        for i = 1, maxIndex do
            table.insert(items, nextSpaces .. self:TableToJSON(tbl[i], indent + 1))
        end
        table.insert(result, table.concat(items, ",\n"))
        table.insert(result, "\n" .. spaces .. "]")
    else
        table.insert(result, "{\n")
        local items = {}
        
        -- Sort keys for consistent output
        local keys = {}
        for k in pairs(tbl) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        
        for _, k in ipairs(keys) do
            local v = tbl[k]
            local key = type(k) == "string" and k or tostring(k)
            table.insert(items, nextSpaces .. '"' .. key .. '": ' .. self:TableToJSON(v, indent + 1))
        end
        table.insert(result, table.concat(items, ",\n"))
        table.insert(result, "\n" .. spaces .. "}")
    end
    
    return table.concat(result)
end

function   SPORES:EscapeJSON(str)
    local escapes = {
        ["\\"] = "\\\\",
        ['"'] = '\\"',
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
    }
    return (str:gsub('[\\"\n\r\t]', escapes))
end

-- Minified JSON for URL export (no whitespace)
function   SPORES:TableToJSONMin(tbl)
    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return '"' .. self:EscapeJSON(tbl) .. '"'
        elseif type(tbl) == "boolean" then
            return tbl and "true" or "false"
        elseif tbl == nil then
            return "null"
        else
            return tostring(tbl)
        end
    end
    
    -- Check if array or object
    local isArray = #tbl > 0 or next(tbl) == nil
    local maxIndex = 0
    for k, _ in pairs(tbl) do
        if type(k) == "number" then
            maxIndex = math.max(maxIndex, k)
        else
            isArray = false
            break
        end
    end
    
    if isArray then
        local items = {}
        for i = 1, maxIndex do
            table.insert(items, self:TableToJSONMin(tbl[i]))
        end
        return "[" .. table.concat(items, ",") .. "]"
    else
        local items = {}
        local keys = {}
        for k in pairs(tbl) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        
        for _, k in ipairs(keys) do
            local v = tbl[k]
            local key = type(k) == "string" and k or tostring(k)
            table.insert(items, '"' .. key .. '":' .. self:TableToJSONMin(v))
        end
        return "{" .. table.concat(items, ",") .. "}"
    end
end

-- ============================================
-- BASE64 ENCODING
-- ============================================
function   SPORES:Base64Encode(data)
    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i = 8, 1, -1 do 
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') 
        end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then 
            return '' 
        end
        local c = 0
        for i = 1, 6 do 
            c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) 
        end
        return b64:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- ============================================
-- BASE64 DECODING
-- ============================================
function   SPORES:Base64Decode(data)
    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = data:gsub('[^' .. b64 .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64:find(x) - 1)
        for i = 6, 1, -1 do
            r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
        end
        return string.char(c)
    end))
end

-- ============================================
-- JSON PARSING (Decode JSON string → Lua table)
-- ============================================
function   SPORES:JSONParse(str)
    local pos = 1
    local function skipWS()
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == ' ' or c == '\t' or c == '\n' or c == '\r' then
                pos = pos + 1
            else break end
        end
    end
    local function peek() skipWS() return str:sub(pos, pos) end
    local parseValue
    local function parseString()
        pos = pos + 1
        local result = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '"' then pos = pos + 1 return table.concat(result)
            elseif c == '\\' then
                pos = pos + 1
                local esc = str:sub(pos, pos)
                if esc == '"' then table.insert(result, '"')
                elseif esc == '\\' then table.insert(result, '\\')
                elseif esc == '/' then table.insert(result, '/')
                elseif esc == 'n' then table.insert(result, '\n')
                elseif esc == 'r' then table.insert(result, '\r')
                elseif esc == 't' then table.insert(result, '\t')
                elseif esc == 'u' then pos = pos + 4 table.insert(result, '?')
                end
                pos = pos + 1
            else table.insert(result, c) pos = pos + 1 end
        end
    end
    local function parseNumber()
        local s = pos
        if str:sub(pos, pos) == '-' then pos = pos + 1 end
        while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
        if pos <= #str and str:sub(pos, pos) == '.' then
            pos = pos + 1
            while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
        end
        if pos <= #str and str:sub(pos, pos):match('[eE]') then
            pos = pos + 1
            if pos <= #str and str:sub(pos, pos):match('[%+%-]') then pos = pos + 1 end
            while pos <= #str and str:sub(pos, pos):match('[%d]') do pos = pos + 1 end
        end
        return tonumber(str:sub(s, pos - 1))
    end
    local function parseArray()
        pos = pos + 1
        local arr, idx = {}, 1
        skipWS()
        if peek() == ']' then pos = pos + 1 return arr end
        while true do
            arr[idx] = parseValue()
            idx = idx + 1
            skipWS()
            local c = str:sub(pos, pos)
            if c == ']' then pos = pos + 1 return arr
            elseif c == ',' then pos = pos + 1
            end
        end
    end
    local function parseObject()
        pos = pos + 1
        local obj = {}
        skipWS()
        if peek() == '}' then pos = pos + 1 return obj end
        while true do
            skipWS()
            local key = parseString()
            skipWS()
            pos = pos + 1
            obj[key] = parseValue()
            skipWS()
            local c = str:sub(pos, pos)
            if c == '}' then pos = pos + 1 return obj
            elseif c == ',' then pos = pos + 1
            end
        end
    end
    parseValue = function()
        skipWS()
        local c = str:sub(pos, pos)
        if c == '"' then return parseString()
        elseif c == '{' then return parseObject()
        elseif c == '[' then return parseArray()
        elseif c == 't' then pos = pos + 4 return true
        elseif c == 'f' then pos = pos + 5 return false
        elseif c == 'n' then pos = pos + 4 return nil
        elseif c == '-' or c:match('[%d]') then return parseNumber()
        end
    end
    local ok, result = pcall(parseValue)
    if not ok then return nil, result end
    return result
end

-- ============================================
-- EVENT REGISTRATION
-- ============================================
EVENT_MANAGER:RegisterForEvent("TheElderSporesOnline", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == "TheElderSporesOnline" then
          SPORES:Initialize()
        EVENT_MANAGER:UnregisterForEvent("TheElderSporesOnline", EVENT_ADD_ON_LOADED)
    end
end)
