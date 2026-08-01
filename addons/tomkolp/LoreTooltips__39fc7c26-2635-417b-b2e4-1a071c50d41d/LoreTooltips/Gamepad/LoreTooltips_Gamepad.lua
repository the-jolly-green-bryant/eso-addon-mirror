-- ============================================
-- Lore Tooltips - Moduł Gamepad (Konsola)
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.Gamepad = {}

local L = {}

-- Zmienne lokalne podstawowe
local lorePanelVisible = false
local uniqueEntriesCache = {}
local isLoreKeybindAdded = false

-- Zmienne dla Gamepada
local currentLinkControls = {}  
local currentLinkIndex = 0

-- Historia nawigacji
local navigationStack = {}
local isNavigatingBack = false

-- Stałe konfiguracyjne (Nagłówek)
local HEADER_HEIGHT = 45

-- Zmienne wymiarowe (Dynamiczne, obliczane przy otwarciu)
local currentPanelWidth = 0
local currentContentWidth = 0

-- Deklaracje
local HideLorePanel, ShowLorePanel, ShowEntryAtIndex
local lorePanelScrollContainer = nil 
local lorePanel, lorePanelContent
local loreNavLabel
local loreEntryControls = {}

local lorePanelKeybindDescriptor 
local loreKeybindDescriptor

-- ============================================
-- LOGIKA GAMEPADA I NAWIGACJI
-- ============================================

local function UpdateLinkSelectionVisuals()
    if not currentLinkControls or #currentLinkControls == 0 then return end
    for i, btn in ipairs(currentLinkControls) do
        local label = btn:GetLabelControl() or btn:GetNamedChild("Label")
        if label then
            if i == currentLinkIndex then
                label:SetColor(0.4, 1, 0.4, 1) 
                btn:SetState(BSTATE_PRESSED, true)
            else
                label:SetColor(0.9, 0.9, 0.7, 1) 
                btn:SetState(BSTATE_NORMAL, false)
            end
        end
    end
end

local function SwitchToLoreEntry(keyword, entry)
    if LoreTooltips.currentMatches and #LoreTooltips.currentMatches > 0 then
        table.insert(navigationStack, {
            matches = LoreTooltips.currentMatches,
            index = LoreTooltips.currentEntryIndex or 1
        })
        if #navigationStack > 50 then table.remove(navigationStack, 1) end
    end
    LoreTooltips.currentMatches = {{
        keyword = keyword, loreEntry = entry, startPos = 0, endPos = 0
    }}
    uniqueEntriesCache = {}
    table.insert(uniqueEntriesCache, LoreTooltips.currentMatches[1])
    LoreTooltips.currentEntryIndex = 1
    ShowEntryAtIndex(1)
    PlaySound(SOUNDS.BOOK_PAGE_TURN)
end

local function CycleLoreLinks(delta)
    if not currentLinkControls or #currentLinkControls == 0 then return end
    if currentLinkIndex == 0 then
        currentLinkIndex = (delta > 0) and 1 or #currentLinkControls
    else
        currentLinkIndex = currentLinkIndex + delta
    end
    if currentLinkIndex > #currentLinkControls then currentLinkIndex = 1 end
    if currentLinkIndex < 1 then currentLinkIndex = #currentLinkControls end
    
    UpdateLinkSelectionVisuals()
    PlaySound(SOUNDS.MENU_BAR_CLICK)
    if KEYBIND_STRIP and lorePanelKeybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(lorePanelKeybindDescriptor)
    end
end

local function ActivateCurrentLoreLink()
    if currentLinkIndex > 0 and currentLinkControls[currentLinkIndex] then
        local btn = currentLinkControls[currentLinkIndex]
        PlaySound(SOUNDS.MENU_BAR_CLICK)
        if btn:GetHandler("OnClicked") then
            btn:GetHandler("OnClicked")(btn)
        end
    end
end

local function SetupKeybinds()
    loreKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = function() return L.KEYBIND_SHOW_LORE end,
            keybind = "UI_SHORTCUT_RIGHT_STICK", 
            callback = function() if lorePanelVisible then HideLorePanel() else ShowLorePanel() end end,
            visible = function() return #LoreTooltips.currentMatches > 0 and not lorePanelVisible end
        }
    }
    lorePanelKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = function() return L.CLOSE_BUTTON end,
            keybind = "UI_SHORTCUT_LEFT_STICK",
            callback = function() HideLorePanel() end,
        },
        {
            name = function() return L.KEYBIND_NEXT_TOPIC end,
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function() 
                local nextIndex = LoreTooltips.currentEntryIndex + 1
                if nextIndex > #uniqueEntriesCache then nextIndex = 1 end
                ShowEntryAtIndex(nextIndex)
                PlaySound(SOUNDS.BOOK_PAGE_TURN)
            end,
            visible = function() return #uniqueEntriesCache > 1 end,
        },
        {
            name = function() return L.KEYBIND_PREV_OPTION end,
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function() CycleLoreLinks(-1) end,
            visible = function() return #currentLinkControls > 0 end,
        },
        {
            name = function() return L.KEYBIND_NEXT_OPTION end,
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function() CycleLoreLinks(1) end,
            visible = function() return #currentLinkControls > 0 end,
        },
        {
            name = function() return L.KEYBIND_SELECT end,
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function() ActivateCurrentLoreLink() end,
            visible = function() return currentLinkIndex > 0 end,
        }
    }
end

local function UpdateLoreKeybinds()
    local shouldShowOpen = (#LoreTooltips.currentMatches > 0) and (not lorePanelVisible)
    if isLoreKeybindAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(loreKeybindDescriptor)
        isLoreKeybindAdded = false
    end
    if shouldShowOpen then
        KEYBIND_STRIP:AddKeybindButtonGroup(loreKeybindDescriptor)
        isLoreKeybindAdded = true
    end
end

-- ============================================
-- WYŚWIETLANIE TREŚCI
-- ============================================

local function ClearLoreEntryControls()
    for _, control in ipairs(loreEntryControls) do
        if control then control:SetHidden(true) end
    end
end

ShowEntryAtIndex = function(index)
    if #uniqueEntriesCache == 0 then return end
    if index < 1 then index = 1 end
    if index > #uniqueEntriesCache then index = #uniqueEntriesCache end
    LoreTooltips.currentEntryIndex = index
    
    isNavigatingBack = false 

    ClearLoreEntryControls()
    
    if lorePanel then
        lorePanel:SetDrawTier(DT_MEDIUM); lorePanel:SetDrawLayer(DL_STD)
    end

    currentLinkControls = {} 
    currentLinkIndex = 0
    
    local match = uniqueEntriesCache[index]
    local keyword = match.keyword
    
    -- === POOLING ===
    local poolCounters = { [CT_LABEL]=0, [CT_BUTTON]=0, [CT_TEXTURE]=0, [CT_CONTROL]=0, [CT_BACKDROP]=0 }
    
    local function GetPooledControl(controlType, parent, template)
        poolCounters[controlType] = (poolCounters[controlType] or 0) + 1
        local typeName = "Ctrl"
        if controlType == CT_LABEL then typeName = "Lbl"
        elseif controlType == CT_BUTTON then typeName = "Btn"
        elseif controlType == CT_TEXTURE then typeName = "Tex" end
        
        local uniqueName = "LorePanel_" .. typeName .. "_" .. poolCounters[controlType]
        local control = GetControl(uniqueName)
        
        if not control then
            if template then control = WINDOW_MANAGER:CreateControlFromVirtual(uniqueName, parent, template)
            elseif controlType == CT_BUTTON then control = WINDOW_MANAGER:CreateControlFromVirtual(uniqueName, parent, "ZO_DefaultButton")
            else control = WINDOW_MANAGER:CreateControl(uniqueName, parent, controlType) end
        else
            control:SetParent(parent)
            control:ClearAnchors()
            control:SetHidden(false)
            if controlType == CT_BUTTON then 
                control:SetState(BSTATE_NORMAL, false); control:SetEnabled(true); control:SetHandler("OnClicked", nil)
                control:SetText(""); control.isBackButton = false; control.refData = nil
            elseif controlType == CT_LABEL then control:SetText("") end
        end
        table.insert(loreEntryControls, control)
        return control
    end

    local totalWidth = currentContentWidth
    
    local titleFont = "ZoFontGamepadBold54"
    local headerFont = "ZoFontGamepadBold34"
    local bodyFont = "ZoFontGamepad42"
    local btnFont = "ZoFontGamepad34"

    local allEntries = LoreTooltips.MultiSourceEntries and LoreTooltips.MultiSourceEntries[keyword] or {{ 
        title = match.loreEntry.title, description = match.loreEntry.description, 
        sourceName = match.loreEntry.sourceName, sourceDisplayName = match.loreEntry.sourceDisplayName 
    }}

    local combinedDesc = ""
    for _, entry in ipairs(allEntries) do combinedDesc = combinedDesc .. (entry.description or "") .. " " end
    local foundMatches = LoreTooltips.FindAllLoreMatches(combinedDesc)
    local refMap = {}     
    local uniqueRefs = {} 
    local refCounter = 0
    
    table.sort(foundMatches, function(a,b) return a.startPos < b.startPos end)
    for _, m in ipairs(foundMatches) do
        if m.keyword ~= keyword and not refMap[m.keyword] then
            refCounter = refCounter + 1; refMap[m.keyword] = refCounter; table.insert(uniqueRefs, m)
        end
    end
    
    local topContainer = GetPooledControl(CT_CONTROL, lorePanel, nil)
    topContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 10, 10)
    topContainer:SetWidth(totalWidth)
    topContainer:SetDrawTier(DT_MEDIUM)
    
    local currentY = 0; local currentX = 0; local controlHeight = 32; local btnSpacing = 10

    if #navigationStack > 0 then 
        local backBtn = GetPooledControl(CT_BUTTON, topContainer, "ZO_DefaultButton")
        backBtn:SetText(L.BACK_BUTTON); backBtn.isBackButton = true
        local backLabel = backBtn:GetLabelControl() or backBtn:GetNamedChild("Label")
        local backWidth = 90
        if backLabel then 
            backLabel:SetFont(btnFont); backLabel:SetColor(0.9, 0.9, 0.7, 1)
            backLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE); backWidth = backLabel:GetTextWidth() + 40
        end
        backBtn:SetWidth(backWidth); backBtn:SetHeight(controlHeight)
        backBtn:SetAnchor(TOPLEFT, topContainer, TOPLEFT, currentX, currentY)
        backBtn:SetHandler("OnClicked", function()
            local prev = table.remove(navigationStack)
            if prev then
                isNavigatingBack = true; LoreTooltips.currentMatches = prev.matches
                LoreTooltips.currentEntryIndex = prev.index
                uniqueEntriesCache = {}; for _, m in ipairs(LoreTooltips.currentMatches) do table.insert(uniqueEntriesCache, m) end
                ShowEntryAtIndex(prev.index); PlaySound(SOUNDS.BOOK_PAGE_TURN)
            end
        end)
        table.insert(currentLinkControls, backBtn); currentX = currentX + backWidth + btnSpacing
    end

    if #uniqueRefs > 0 then
        local refBtn = GetPooledControl(CT_BUTTON, topContainer, "ZO_DefaultButton")
        refBtn:SetText(L.SHOW_REFS_BUTTON .. " (" .. #uniqueRefs .. ")")
        local refLabel = refBtn:GetLabelControl() or refBtn:GetNamedChild("Label")
        local refWidth = 220
        if refLabel then
            refLabel:SetFont(btnFont); refLabel:SetColor(1, 1, 1, 1)
            refLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE); refWidth = refLabel:GetTextWidth() + 50
        end
        refBtn:SetWidth(refWidth); refBtn:SetHeight(controlHeight)
        refBtn:SetAnchor(TOPLEFT, topContainer, TOPLEFT, currentX, currentY)
        refBtn:SetHandler("OnClicked", function()
                local dialogData = { refs = uniqueRefs }
                ZO_Dialogs_ShowGamepadDialog("LORE_TOOLTIPS_REF_LIST", dialogData)
        end)
        table.insert(currentLinkControls, refBtn); currentX = currentX + refWidth + btnSpacing
    end
    
    local topAreaHeight = controlHeight + 10; topContainer:SetHeight(topAreaHeight)

    if KEYBIND_STRIP and lorePanelKeybindDescriptor then KEYBIND_STRIP:UpdateKeybindButtonGroup(lorePanelKeybindDescriptor) end
    UpdateLinkSelectionVisuals()

    if lorePanelScrollContainer then
        lorePanelScrollContainer:ClearAnchors()
        lorePanelScrollContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 15, topAreaHeight + 15)
        lorePanelScrollContainer:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -15, -50) 
        if lorePanelContent then lorePanelContent:SetWidth(totalWidth) end
    end

    local lastControl = nil
    local function AddToScroll(control, offsetY)
        if lastControl then control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, offsetY)
        else control:SetAnchor(TOPLEFT, lorePanelContent, TOPLEFT, 0, 0) end
        lastControl = control
    end

    local mainTitle = GetPooledControl(CT_LABEL, lorePanelContent, nil)
    mainTitle:SetFont(titleFont); mainTitle:SetColor(1, 0.84, 0, 1)
    mainTitle:SetText(match.loreEntry.title or keyword); mainTitle:SetWidth(totalWidth)
    AddToScroll(mainTitle, 0)

    for i, entry in ipairs(allEntries) do
        if i > 1 then
            local sep = GetPooledControl(CT_TEXTURE, lorePanelContent, nil)
            sep:SetDimensions(totalWidth, 2); sep:SetColor(0.5, 0.4, 0.2, 0.8)
            AddToScroll(sep, 15)
        end
        local srcLbl = GetPooledControl(CT_LABEL, lorePanelContent, nil)
        srcLbl:SetFont(headerFont); srcLbl:SetColor(0.5, 1, 0.5, 1)
        srcLbl:SetText("[" .. (entry.sourceDisplayName or entry.sourceName or L.SOURCE_LABEL) .. "]")
        AddToScroll(srcLbl, 10)

        local descLbl = GetPooledControl(CT_LABEL, lorePanelContent, nil)
        descLbl:SetFont(bodyFont); descLbl:SetColor(0.9, 0.9, 0.9, 1); descLbl:SetWidth(totalWidth)
        local rawDesc = entry.description or ""; rawDesc = rawDesc:gsub("\\n", "\n") 
        local processedText, _ = LoreTooltips.HighlightKeywordsInText(rawDesc, nil, refMap, keyword)
        descLbl:SetText(processedText)
        AddToScroll(descLbl, 5)
    end
    if loreNavLabel then loreNavLabel:SetText(index .. " / " .. #uniqueEntriesCache) end
    ZO_Scroll_ResetToTop(lorePanelScrollContainer)
end

-- ============================================
-- TWORZENIE OKIEN
-- ============================================

local function CreateLorePanel()
    if lorePanel then return end
    lorePanel = WINDOW_MANAGER:CreateTopLevelWindow("LoreTooltipsPanel")
    lorePanel:SetDrawTier(DT_MEDIUM); lorePanel:SetDrawLayer(DL_STD)
    
    -- Wymiary inicjalne (zostaną nadpisane dynamicznie)
    lorePanel:SetDimensions(800, 600)
    -- Domyślna pozycja (zostanie nadpisana)
    lorePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 100)

    lorePanel:SetMouseEnabled(true)
    lorePanel:SetMovable(true)
    lorePanel:SetHidden(true)
    
    lorePanel:SetHandler("OnMoveStop", function()
         local isBookMode = (ZO_LoreReader and not ZO_LoreReader:IsHidden())
         -- Zapisujemy pozycję tylko dla trybu swobodnego (NPC), a nie dla wymuszonych widoków (Journal/Book)
         if not isBookMode and LoreTooltips.savedVars then
            LoreTooltips.savedVars.gamepadPanelPosX = lorePanel:GetLeft()
            LoreTooltips.savedVars.gamepadPanelPosY = lorePanel:GetTop()
         end
    end)
    
    lorePanel:SetHandler("OnUpdate", function()
        if not lorePanelVisible then return end
        if lorePanelScrollContainer then
            local scrollY = 0
            if ZO_Gamepad_GetRightStickEasedY then scrollY = ZO_Gamepad_GetRightStickEasedY()
            elseif ZO_Gamepad_GetRightStickY then scrollY = ZO_Gamepad_GetRightStickY() end
            
            if scrollY and math.abs(scrollY) > 0.05 then
                if ZO_Scroll_ScrollRelative then ZO_Scroll_ScrollRelative(lorePanelScrollContainer, -scrollY * 25) end
            end
        end
    end)
    
    local bg = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelBG", lorePanel, CT_BACKDROP)
    bg:SetAnchorFill(lorePanel)
    bg:SetCenterColor(0.02, 0.02, 0.08, 0.95)
    bg:SetEdgeColor(0.6, 0.5, 0.2, 1)
    
    local closeBtn = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelClose", lorePanel, CT_BUTTON)
    closeBtn:SetDimensions(28, 28)
    closeBtn:SetAnchor(TOPRIGHT, lorePanel, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeBtn:SetHandler("OnClicked", function() HideLorePanel() end)
    closeBtn:SetDrawTier(DT_HIGH); closeBtn:SetDrawLayer(DL_OVERLAY)
    
    lorePanelScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("LoreTooltipsPanelScroll", lorePanel, "ZO_ScrollContainer")
    lorePanelScrollContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 15, HEADER_HEIGHT)
    lorePanelScrollContainer:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -15, -50)
    lorePanelScrollContainer:SetDrawTier(DT_HIGH); lorePanelScrollContainer:SetDrawLayer(DL_OVERLAY)
    
    local scrollBar = lorePanelScrollContainer:GetNamedChild("ScrollBar")
    if scrollBar then scrollBar:SetDrawTier(DT_HIGH); scrollBar:SetDrawLayer(DL_OVERLAY) end
    
    lorePanelContent = lorePanelScrollContainer:GetNamedChild("ScrollChild")
    lorePanelContent:SetWidth(600) 
    
    loreNavLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelNav", lorePanel, CT_LABEL)
    loreNavLabel:SetFont("ZoFontGameBold")
    loreNavLabel:SetAnchor(BOTTOM, lorePanel, BOTTOM, 0, -15)
end

ShowLorePanel = function()
    if #LoreTooltips.currentMatches == 0 then return end
    CreateLorePanel()
    
    -- Wykrywanie trybów
    local isBookMode = (ZO_LoreReader and not ZO_LoreReader:IsHidden())
    local isJournalMode = false
    if SCENE_MANAGER then
        local currentScene = SCENE_MANAGER:GetCurrentScene()
        if currentScene and currentScene.name == "gamepad_quest_journal" then
            isJournalMode = true
        end
    end

    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()

    -- Wymiary i Marginesy
    local topMargin = 80
    local bottomMargin = 220 
    local dynamicHeight = screenHeight - (topMargin + bottomMargin)

    -- Obliczanie szerokości dla standardowych okien (NPC) - 45%
    currentPanelWidth = screenWidth * 0.45
    if currentPanelWidth < 550 then currentPanelWidth = 550 end
    
    -- SPECYFICZNE DLA DZIENNIKA: Trochę węższe (35%)
    if isJournalMode then
        currentPanelWidth = screenWidth * 0.35
        if currentPanelWidth < 450 then currentPanelWidth = 450 end
    end
    
    -- SPECYFICZNE DLA KSIĄŻKI: Jeszcze węższe (26%)
    if isBookMode then
        currentPanelWidth = screenWidth * 0.26
        if currentPanelWidth < 400 then currentPanelWidth = 400 end
    end
    
    currentContentWidth = currentPanelWidth - 40

    -- Aplikowanie wymiarów (Wysokość dynamiczna wszędzie)
    lorePanel:SetDimensions(currentPanelWidth, dynamicHeight)
    lorePanel:ClearAnchors()

    -- === POZYCJONOWANIE ===
    
    if isJournalMode then
        -- DZIENNIK: Prawa strona, Offset 0 (przyklejone)
        lorePanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, topMargin)
        
    elseif isBookMode then
        -- KSIĄŻKA: Na maksa do prawej (Offset 0) i WĄSKIE
        lorePanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, topMargin)
        
    else
        -- NPC: Lewa strona (Standardowa szerokość 45%)
        if LoreTooltips.savedVars and LoreTooltips.savedVars.gamepadPanelPosX then
            lorePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LoreTooltips.savedVars.gamepadPanelPosX, LoreTooltips.savedVars.gamepadPanelPosY)
        else
            lorePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, topMargin)
        end
    end
    -- =======================
    
    if lorePanelContent then lorePanelContent:SetWidth(currentContentWidth) end
    
    ClearLoreEntryControls()
    LoreTooltips.currentEntryIndex = 1
    uniqueEntriesCache = {}
    local seenKeywords = {}
    for _, match in ipairs(LoreTooltips.currentMatches) do
        if not seenKeywords[match.keyword] then
            seenKeywords[match.keyword] = true
            table.insert(uniqueEntriesCache, match)
        end
    end
    
    navigationStack = {}      
    table.insert(navigationStack, { matches = LoreTooltips.currentMatches, index = 1 }) 
    isNavigatingBack = false   

    lorePanel:SetDrawTier(DT_MEDIUM); lorePanel:SetDrawLayer(DL_STD)

    ShowEntryAtIndex(1)
    lorePanel:SetHidden(false)
    lorePanelVisible = true
    
    if isLoreKeybindAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(loreKeybindDescriptor)
        isLoreKeybindAdded = false
    end
    KEYBIND_STRIP:AddKeybindButtonGroup(lorePanelKeybindDescriptor)
    isLoreKeybindAdded = true
end

HideLorePanel = function()
    if lorePanel then 
        lorePanel:SetHidden(true)
        lorePanelVisible = false 
        KEYBIND_STRIP:RemoveKeybindButtonGroup(lorePanelKeybindDescriptor)
        UpdateLoreKeybinds()
    end
end

-- ============================================
-- MENU GAMEPADA
-- ============================================

local function InjectGamepadMenuEntry()
    if not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES then return end
    for _, entry in ipairs(ZO_MENU_ENTRIES) do
        if entry.subMenu then
             for _, subEntry in ipairs(entry.subMenu) do
                 if subEntry.data and subEntry.data.name == L.LIBRARY_MENU_ENTRY then return end
             end
        end
    end
    local customEntryData = {
        scene = "LoreTooltipsGamepadScene", 
        name = L.LIBRARY_MENU_ENTRY, 
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_loreLibrary.dds",
    }
    if ZO_GamepadEntryData then
        local newEntry = ZO_GamepadEntryData:New(customEntryData.name, customEntryData.icon)
        newEntry.data = customEntryData
        newEntry:SetIconTintOnSelection(true)
        newEntry:SetIconDisabledTintOnSelection(true)
        local journalIndex = ZO_MENU_MAIN_ENTRIES.JOURNAL
        local journalEntry = ZO_MENU_ENTRIES[journalIndex]
        if journalEntry and journalEntry.subMenu then
            newEntry.id = #journalEntry.subMenu + 1
            table.insert(journalEntry.subMenu, newEntry)
            if MAIN_MENU_GAMEPAD then MAIN_MENU_GAMEPAD:RefreshLists() end
        end
    end
end

-- ============================================
-- INTERFACE PUBLICZNY
-- ============================================

function LoreTooltips.Gamepad:Initialize(localization)
    L = localization
    SetupKeybinds()
    InjectGamepadMenuEntry()
    
    ZO_Dialogs_RegisterCustomDialog("LORE_TOOLTIPS_REF_LIST", {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog)
            dialog.info.parametricList = {}
            if dialog.data and dialog.data.refs then
                for i, ref in ipairs(dialog.data.refs) do
                     local entry = {
                         template = "ZO_GamepadMenuEntryTemplate",
                         templateData = {
                             text = "["..i.."] " .. (ref.loreEntry.title or ref.keyword),
                             setup = ZO_SharedGamepadEntry_OnSetup,
                             callback = function() 
                                SwitchToLoreEntry(ref.keyword, ref.loreEntry)
                                ZO_Dialogs_ReleaseDialogOnButtonPress(dialog.name)
                             end
                         }
                     }
                     table.insert(dialog.info.parametricList, entry)
                end
            end
            dialog:setupFunc()
        end,
        title = { text = L.GAMEPAD_DIALOG_TITLE },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY", text = L.DIALOG_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then targetData.callback() end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE", text = L.DIALOG_CANCEL,
                callback = function(dialog) ZO_Dialogs_ReleaseDialogOnButtonPress(dialog.name) end,
            },
        }
    })
end

function LoreTooltips.Gamepad:UpdateInteractions(count)
    if count > 0 then UpdateLoreKeybinds()
    else
        if isLoreKeybindAdded then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(loreKeybindDescriptor)
            isLoreKeybindAdded = false
        end
    end
end

function LoreTooltips.Gamepad:UpdateJournalInteractions(count) self:UpdateInteractions(count) end
function LoreTooltips.Gamepad:UpdateBookInteractions(count) self:UpdateInteractions(count) end
function LoreTooltips.Gamepad:HideLorePanel() HideLorePanel() end