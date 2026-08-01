-- ============================================
-- Lore Tooltips - Moduł Klawiatury (PC)
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.Keyboard = {}

local L = {}

-- Zmienne lokalne podstawowe
local lorePanelVisible = false
local uniqueEntriesCache = {}

-- Uchwyt do ComboBoxa (Dropdowna) dla PC
local lorePanelReferenceCombo = nil

-- Historia nawigacji
local navigationStack = {}
local isNavigatingBack = false

-- Stałe konfiguracyjne
local HEADER_HEIGHT = 45

local currentPanelWidth = 0
local currentContentWidth = 0

-- Deklaracje
local HideLorePanel, ShowLorePanel, ShowEntryAtIndex
local lorePanelScrollContainer = nil 
local lorePanel, lorePanelContent
local loreNavLabel, lorePrevBtn, loreNextBtn
local loreEntryControls = {}

local loreButton, loreButtonLabel, loreButtonBg
local loreJournalButton, loreJournalButtonLabel, loreJournalButtonBg
local loreBookButton, loreBookButtonLabel, loreBookButtonBg

-- ============================================
-- FUNKCJE POMOCNICZE UI
-- ============================================

local function ClearLoreEntryControls()
    for _, control in ipairs(loreEntryControls) do
        if control then control:SetHidden(true) end
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
        keyword = keyword,
        loreEntry = entry,
        startPos = 0, endPos = 0
    }}
    
    uniqueEntriesCache = {}
    table.insert(uniqueEntriesCache, LoreTooltips.currentMatches[1])
    LoreTooltips.currentEntryIndex = 1
    
    ShowEntryAtIndex(1)
    PlaySound(SOUNDS.BOOK_PAGE_TURN)
end

-- ============================================
-- WYŚWIETLANIE TREŚCI (PC)
-- ============================================

ShowEntryAtIndex = function(index)
    if #uniqueEntriesCache == 0 then return end
    if index < 1 then index = 1 end
    if index > #uniqueEntriesCache then index = #uniqueEntriesCache end
    LoreTooltips.currentEntryIndex = index
    
    isNavigatingBack = false 

    ClearLoreEntryControls()
    
    -- Zabezpieczenie: upewniamy się, że panel jest na dobrej warstwie (MEDIUM), aby combobox działał
    if lorePanel then
        lorePanel:SetDrawTier(DT_MEDIUM)
        lorePanel:SetDrawLayer(DL_STD)
    end

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
            if template then
                control = WINDOW_MANAGER:CreateControlFromVirtual(uniqueName, parent, template)
            elseif controlType == CT_BUTTON then
                control = WINDOW_MANAGER:CreateControlFromVirtual(uniqueName, parent, "ZO_DefaultButton")
            else
                control = WINDOW_MANAGER:CreateControl(uniqueName, parent, controlType)
            end
        else
            control:SetParent(parent)
            control:ClearAnchors()
            control:SetHidden(false)
            if controlType == CT_BUTTON then 
                control:SetState(BSTATE_NORMAL, false)
                control:SetEnabled(true)
                control:SetHandler("OnClicked", nil)
                control:SetText("")
                control.isBackButton = false 
                control.refData = nil
            elseif controlType == CT_LABEL then
                control:SetText("")
            end
        end
        
        table.insert(loreEntryControls, control)
        return control
    end
    -- ===========================

    local totalWidth = currentContentWidth
    
    local titleFont = "ZoFontGameLargeBold"
    local headerFont = "ZoFontGameBold"
    local bodyFont = "ZoFontGame"
    local btnFont = "ZoFontGameSmall"

    local allEntries = LoreTooltips.MultiSourceEntries and LoreTooltips.MultiSourceEntries[keyword] or {{ 
        title = match.loreEntry.title, description = match.loreEntry.description, 
        sourceName = match.loreEntry.sourceName, sourceDisplayName = match.loreEntry.sourceDisplayName 
    }}

    -- Skanowanie w poszukiwaniu odnośników w całym tekście
    local combinedDesc = ""
    for _, entry in ipairs(allEntries) do
        combinedDesc = combinedDesc .. (entry.description or "") .. " "
    end
    
    local foundMatches = LoreTooltips.FindAllLoreMatches(combinedDesc)
    local refMap = {}     
    local uniqueRefs = {} 
    local refCounter = 0
    
    table.sort(foundMatches, function(a,b) return a.startPos < b.startPos end)

    for _, m in ipairs(foundMatches) do
        -- WAŻNE: Ignorujemy samych siebie (Pęknina w Pękninie)
        if m.keyword ~= keyword and not refMap[m.keyword] then
            refCounter = refCounter + 1
            refMap[m.keyword] = refCounter
            table.insert(uniqueRefs, m)
        end
    end
    
    -- === PANEL GÓRNY (Linki + Wstecz) ===
    local topContainer = GetPooledControl(CT_CONTROL, lorePanel, nil)
    topContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 10, 10)
    topContainer:SetWidth(totalWidth)
    topContainer:SetDrawTier(DT_MEDIUM) -- Warstwa MEDIUM aby nie zasłaniać listy
    
    local currentY = 0
    local currentX = 0
    local controlHeight = 32
    local btnSpacing = 10

    -- 1. Przycisk WSTECZ
    if #navigationStack > 0 then 
        local backBtn = GetPooledControl(CT_BUTTON, topContainer, "ZO_DefaultButton")
        backBtn:SetText(L.BACK_BUTTON)
        backBtn.isBackButton = true 
        
        local backLabel = backBtn:GetLabelControl() or backBtn:GetNamedChild("Label")
        local backWidth = 90
        if backLabel then 
            backLabel:SetFont(btnFont)
            backLabel:SetColor(0.9, 0.9, 0.7, 1) -- Ustawiamy normalny beżowy
            backLabel:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
            backWidth = backLabel:GetTextWidth() + 40
        end
        backBtn:SetWidth(backWidth)
        backBtn:SetHeight(controlHeight)
        
        backBtn:SetAnchor(TOPLEFT, topContainer, TOPLEFT, currentX, currentY)
        backBtn:SetHandler("OnClicked", function()
            -- Logika cofania
            local prev = table.remove(navigationStack)
            if prev then
                isNavigatingBack = true 
                LoreTooltips.currentMatches = prev.matches
                LoreTooltips.currentEntryIndex = prev.index
                uniqueEntriesCache = {}
                for _, m in ipairs(LoreTooltips.currentMatches) do table.insert(uniqueEntriesCache, m) end
                ShowEntryAtIndex(prev.index)
                PlaySound(SOUNDS.BOOK_PAGE_TURN)
            end
        end)
        
        currentX = currentX + backWidth + btnSpacing
    end

    -- 2. Lista Odnośników (PC: ComboBox)
    if #uniqueRefs > 0 then
        -- === PC: ComboBox (Dropdown) WZOROWANY NA LORELIBRARY ===
        if not lorePanelReferenceCombo then
             lorePanelReferenceCombo = WINDOW_MANAGER:CreateControlFromVirtual("LorePanelReferenceCombo", lorePanel, "ZO_ComboBox")
        end
        lorePanelReferenceCombo:SetHidden(false)
        -- Musimy przypisać rodzica do kontenera z puli, bo on się zmienia
        lorePanelReferenceCombo:SetParent(topContainer)
        lorePanelReferenceCombo:ClearAnchors()
        lorePanelReferenceCombo:SetAnchor(TOPLEFT, topContainer, TOPLEFT, currentX, currentY)
        
        -- Dynamiczna szerokość combo w zależności od szerokości panelu (żeby nie wyłaził)
        local comboWidth = 350
        if (currentX + comboWidth) > totalWidth then
            comboWidth = totalWidth - currentX - 10
        end
        lorePanelReferenceCombo:SetDimensions(comboWidth, controlHeight)
        
        local m_comboBox = ZO_ComboBox_ObjectFromContainer(lorePanelReferenceCombo)
        m_comboBox:ClearItems()
        m_comboBox:SetSortsItems(false)
        m_comboBox:SetFont("ZoFontGame")
        -- Tłumaczenie nagłówka comboboxa
        m_comboBox:SetSelectedItem(L.SELECT_TOPIC_DROPDOWN .. " (" .. #uniqueRefs .. ")...")
        
        for i, ref in ipairs(uniqueRefs) do
             local entryText = "[" .. i .. "] " .. (ref.loreEntry.title or ref.keyword)
             local entry = m_comboBox:CreateItemEntry(entryText, function()
                 SwitchToLoreEntry(ref.keyword, ref.loreEntry)
             end)
             m_comboBox:AddItem(entry)
        end
        
        currentX = currentX + comboWidth + 10
    else
        -- Jeśli brak odnośników, ukryj combo
        if lorePanelReferenceCombo then lorePanelReferenceCombo:SetHidden(true) end
    end
    
    local topAreaHeight = controlHeight + 10
    topContainer:SetHeight(topAreaHeight)

    -- === PRZESUNIĘCIE I SKALOWANIE SCROLLA ===
    if lorePanelScrollContainer then
        lorePanelScrollContainer:ClearAnchors()
        lorePanelScrollContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 15, topAreaHeight + 15)
        -- Zostawiamy miejsce na dole na przycisk Linku
        lorePanelScrollContainer:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -15, -50) 
        if lorePanelContent then lorePanelContent:SetWidth(totalWidth) end
    end

    -- === TREŚĆ ===
    local lastControl = nil
    local function AddToScroll(control, offsetY)
        if lastControl then
            control:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, offsetY)
        else
            control:SetAnchor(TOPLEFT, lorePanelContent, TOPLEFT, 0, 0)
        end
        lastControl = control
    end

    local mainTitle = GetPooledControl(CT_LABEL, lorePanelContent, nil)
    mainTitle:SetFont(titleFont)
    mainTitle:SetColor(1, 0.84, 0, 1)
    mainTitle:SetText(match.loreEntry.title or keyword)
    mainTitle:SetWidth(totalWidth)
    AddToScroll(mainTitle, 0)

    for i, entry in ipairs(allEntries) do
        if i > 1 then
            local sep = GetPooledControl(CT_TEXTURE, lorePanelContent, nil)
            sep:SetDimensions(totalWidth, 2)
            sep:SetColor(0.5, 0.4, 0.2, 0.8)
            AddToScroll(sep, 15)
        end

        local srcLbl = GetPooledControl(CT_LABEL, lorePanelContent, nil)
        srcLbl:SetFont(headerFont)
        srcLbl:SetColor(0.5, 1, 0.5, 1)
        -- Tłumaczenie etykiety źródła
        srcLbl:SetText("[" .. (entry.sourceDisplayName or entry.sourceName or L.SOURCE_LABEL) .. "]")
        AddToScroll(srcLbl, 10)

        local descLbl = GetPooledControl(CT_LABEL, lorePanelContent, nil)
        descLbl:SetFont(bodyFont)
        descLbl:SetColor(0.9, 0.9, 0.9, 1)
        descLbl:SetWidth(totalWidth)
        
        -- Pobieramy opis z bazy
        local rawDesc = entry.description or ""
        
        -- NAPRAWA UESP: Zamieniamy tekstowy znak "\\n" (backslash + n) na prawdziwy Enter.
        rawDesc = rawDesc:gsub("\\n", "\n") 
        
        -- Teraz rawText to po prostu poprawiony opis.
        local rawText = rawDesc
        
        -- Przekazujemy 'keyword' jako 4. argument (ignoreKeyword)
        local processedText, _ = LoreTooltips.HighlightKeywordsInText(rawText, nil, refMap, keyword)
        
        descLbl:SetText(processedText)
        AddToScroll(descLbl, 5)
    end
    
    if loreNavLabel then loreNavLabel:SetText(index .. " / " .. #uniqueEntriesCache) end
    ZO_Scroll_ResetToTop(lorePanelScrollContainer)
end

-- ============================================
-- TWORZENIE OKIEN (PC)
-- ============================================

local linkPopup, linkEditBox

local function ShowLinkPopup(url)
    if not linkPopup then
        linkPopup = WINDOW_MANAGER:CreateTopLevelWindow("LoreTooltipsLinkPopup")
        linkPopup:SetDimensions(500, 100)
        linkPopup:SetDrawTier(DT_HIGH); linkPopup:SetDrawLayer(DL_OVERLAY)

        if LoreTooltips.savedVars and LoreTooltips.savedVars.linkPopupPosX and LoreTooltips.savedVars.linkPopupPosY then
            linkPopup:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LoreTooltips.savedVars.linkPopupPosX, LoreTooltips.savedVars.linkPopupPosY)
        else
            if lorePanel then
                linkPopup:SetAnchor(RIGHT, lorePanel, LEFT, -20, 0)
            else
                linkPopup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            end
        end

        linkPopup:SetMouseEnabled(true)
        linkPopup:SetMovable(true)
        linkPopup:SetClampedToScreen(true)
        linkPopup:SetHidden(true)

        linkPopup:SetHandler("OnMoveStop", function()
            if LoreTooltips.savedVars then
                LoreTooltips.savedVars.linkPopupPosX = linkPopup:GetLeft()
                LoreTooltips.savedVars.linkPopupPosY = linkPopup:GetTop()
            end
        end)
        
        local bg = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkPopupBG", linkPopup, CT_BACKDROP)
        bg:SetAnchorFill(linkPopup)
        bg:SetCenterColor(0.05, 0.05, 0.1, 0.95)
        bg:SetEdgeColor(0.4, 0.8, 0.4, 1)
        
        local title = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkPopupTitle", linkPopup, CT_LABEL)
        title:SetFont("ZoFontGameBold")
        title:SetColor(0.4, 1, 0.4, 1)
        title:SetAnchor(TOP, linkPopup, TOP, 0, 10)
        title:SetText(L.COPY_LINK_POPUP_TITLE)
        
        local editBg = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkEditBG", linkPopup, CT_BACKDROP)
        editBg:SetDimensions(470, 30)
        editBg:SetAnchor(TOP, linkPopup, TOP, 0, 40)
        editBg:SetCenterColor(0.1, 0.1, 0.15, 1)
        editBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
        
        linkEditBox = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkEditBox", linkPopup, CT_EDITBOX)
        linkEditBox:SetDimensions(460, 26)
        linkEditBox:SetAnchor(CENTER, editBg, CENTER, 0, 0)
        linkEditBox:SetFont("ZoFontGame")
        linkEditBox:SetColor(0.9, 0.9, 0.9, 1)
        linkEditBox:SetMaxInputChars(500)
        linkEditBox:SetMouseEnabled(true)
        
        linkEditBox:SetHandler("OnEnter", function() linkPopup:SetHidden(true) end)
        linkEditBox:SetHandler("OnEscape", function() linkPopup:SetHidden(true) end)
        
        local closeBtn = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkPopupClose", linkPopup, CT_BUTTON)
        closeBtn:SetDimensions(100, 28)
        closeBtn:SetAnchor(BOTTOM, linkPopup, BOTTOM, 0, -10)
        closeBtn:SetMouseEnabled(true)
        
        local closeBtnBg = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkPopupCloseBG", closeBtn, CT_BACKDROP)
        closeBtnBg:SetAnchorFill(closeBtn)
        closeBtnBg:SetCenterColor(0.3, 0.1, 0.1, 0.9)
        closeBtnBg:SetEdgeColor(0.8, 0.4, 0.4, 1)
        closeBtnBg:SetMouseEnabled(false)
        
        local closeBtnLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsLinkPopupCloseLabel", closeBtn, CT_LABEL)
        closeBtnLabel:SetFont("ZoFontGameSmall")
        closeBtnLabel:SetColor(1, 0.6, 0.6, 1)
        closeBtnLabel:SetAnchor(CENTER, closeBtn, CENTER, 0, 0)
        closeBtnLabel:SetText(L.POPUP_CLOSE)
        closeBtnLabel:SetMouseEnabled(false)
        
        closeBtn:SetHandler("OnMouseUp", function(control, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                linkPopup:SetHidden(true)
            end
        end)
    end
    
    linkEditBox:SetText(url)
    linkPopup:SetHidden(false)
    linkEditBox:TakeFocus()
    linkEditBox:SelectAll()
end

local function CreateLorePanel()
    if lorePanel then return end
    lorePanel = WINDOW_MANAGER:CreateTopLevelWindow("LoreTooltipsPanel")
    -- ZMIANA WARSTWY: MEDIUM pozwala na działanie listy rozwijanej (combo box) ponad oknem
    lorePanel:SetDrawTier(DT_MEDIUM)
    lorePanel:SetDrawLayer(DL_STD)
    
    -- Wymiary początkowe (zostaną nadpisane)
    lorePanel:SetDimensions(800, 600)
    
    -- Pozycja (zostanie nadpisana dynamicznie)
    lorePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)
    
    lorePanel:SetMouseEnabled(true)
    lorePanel:SetMovable(true)
    lorePanel:SetHidden(true)
    
    
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
    
	-- Przycisk Linku
    local linkBtn = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelLinkBtn", lorePanel, CT_BUTTON)
    linkBtn:SetDimensions(100, 28)
    -- ZMIANA: Prawy górny róg, offset -45 (żeby nie zasłaniał X, który jest na -5)
    linkBtn:SetAnchor(TOPRIGHT, lorePanel, TOPRIGHT, -45, 5)
    linkBtn:SetMouseEnabled(true)
    linkBtn:SetDrawTier(DT_HIGH); linkBtn:SetDrawLayer(DL_OVERLAY)
    
    local linkBtnBg = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelLinkBtnBG", linkBtn, CT_BACKDROP)
    linkBtnBg:SetAnchorFill(linkBtn)
    linkBtnBg:SetCenterColor(0.1, 0.3, 0.1, 0.9)
    linkBtnBg:SetEdgeColor(0.4, 0.8, 0.4, 1)
    linkBtnBg:SetMouseEnabled(false)
    
    local linkBtnLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelLinkBtnLabel", linkBtn, CT_LABEL)
    linkBtnLabel:SetFont("ZoFontGameSmall")
    linkBtnLabel:SetColor(0.4, 1, 0.4, 1)
    linkBtnLabel:SetAnchor(CENTER, linkBtn, CENTER, 0, 0)
    linkBtnLabel:SetText(L.COPY_LINK_BUTTON)
    linkBtnLabel:SetMouseEnabled(false)
    
	linkBtn:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            local match = uniqueEntriesCache[LoreTooltips.currentEntryIndex]
            if match and match.loreEntry then
                local url = match.loreEntry.url
                
                -- Jeśli wpis nie ma sztywnego URL, generujemy go dynamicznie
                if not url or url == "" then
                    local wikiKey = match.keyword
                    local sourceName = match.loreEntry.sourceName or ""
                    
                    if string.find(sourceName, "UESP") then
                        local safeKey = wikiKey:gsub(" ", "_")
                        url = "https://en.uesp.net/wiki/Lore:" .. safeKey
                        
                    elseif string.find(sourceName, "Cesarska") then
                        local safeKey = wikiKey:gsub(" ", "_")
                        url = "https://cesarskabiblioteka.fandom.com/wiki/" .. safeKey
                        
                    elseif string.find(sourceName, "Fandom") then
                        local safeKey = wikiKey:gsub(" ", "_")
                        if string.find(sourceName, "PL") then
                            url = "https://elderscrolls.fandom.com/pl/wiki/" .. safeKey
                        else
                            url = "https://elderscrolls.fandom.com/wiki/" .. safeKey
                        end
                    end
                end
                
                if url then 
                    ShowLinkPopup(url) 
                else
                end
            end
        end
    end)
    
    lorePanelScrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("LoreTooltipsPanelScroll", lorePanel, "ZO_ScrollContainer")
    lorePanelScrollContainer:SetAnchor(TOPLEFT, lorePanel, TOPLEFT, 15, HEADER_HEIGHT)
    lorePanelScrollContainer:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -15, -50)
    lorePanelScrollContainer:SetDrawTier(DT_HIGH); lorePanelScrollContainer:SetDrawLayer(DL_OVERLAY)
    
    local scrollBar = lorePanelScrollContainer:GetNamedChild("ScrollBar")
    if scrollBar then scrollBar:SetDrawTier(DT_HIGH); scrollBar:SetDrawLayer(DL_OVERLAY) end
    
    lorePanelContent = lorePanelScrollContainer:GetNamedChild("ScrollChild")
    lorePanelContent:SetWidth(600) -- Wstępna szerokość
    
    lorePrevBtn = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelPrev", lorePanel, CT_BUTTON)
    lorePrevBtn:SetDimensions(30, 30)
    lorePrevBtn:SetAnchor(BOTTOMLEFT, lorePanel, BOTTOMLEFT, 15, -10)
    lorePrevBtn:SetNormalTexture("/esoui/art/buttons/scrollbox_uparrow_up.dds")
    lorePrevBtn:SetHandler("OnClicked", function() ShowEntryAtIndex(LoreTooltips.currentEntryIndex - 1) end)
    lorePrevBtn:SetDrawTier(DT_HIGH); lorePrevBtn:SetDrawLayer(DL_OVERLAY)
    
    loreNavLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelNav", lorePanel, CT_LABEL)
    loreNavLabel:SetFont("ZoFontGameBold")
    loreNavLabel:SetAnchor(BOTTOM, lorePanel, BOTTOM, 0, -15)
    
    loreNextBtn = WINDOW_MANAGER:CreateControl("LoreTooltipsPanelNext", lorePanel, CT_BUTTON)
    loreNextBtn:SetDimensions(30, 30)
    loreNextBtn:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -15, -10)
    loreNextBtn:SetNormalTexture("/esoui/art/buttons/scrollbox_downarrow_up.dds")
    loreNextBtn:SetHandler("OnClicked", function() ShowEntryAtIndex(LoreTooltips.currentEntryIndex + 1) end)
    loreNextBtn:SetDrawTier(DT_HIGH); loreNextBtn:SetDrawLayer(DL_OVERLAY)
    
    -- Resize Handle
    local resizeHandle = WINDOW_MANAGER:CreateControl("LorePanelResizeHandle", lorePanel, CT_TEXTURE)
    resizeHandle:SetDimensions(16, 16)
    resizeHandle:SetAnchor(BOTTOMRIGHT, lorePanel, BOTTOMRIGHT, -2, -2)
    resizeHandle:SetTexture("/esoui/art/chatwindow/chat_resizehandle.dds")
    resizeHandle:SetMouseEnabled(true)
    resizeHandle:SetHandler("OnMouseDown", function() lorePanel:StartSizing("BOTTOMRIGHT") end)
    resizeHandle:SetHandler("OnMouseUp", function() 
        lorePanel:StopSizing() 
        currentContentWidth = lorePanel:GetWidth() - 50
        if lorePanelContent then lorePanelContent:SetWidth(currentContentWidth) end
        ShowEntryAtIndex(LoreTooltips.currentEntryIndex)
    end)
end

ShowLorePanel = function()
    if #LoreTooltips.currentMatches == 0 then return end
    CreateLorePanel()
    
    -- === DYNAMICZNE SKALOWANIE (JAK NA KONSOLI) ===
    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    
    -- Wykrywanie kontekstu (Czytanie książki / Dziennik / Rozmowa NPC)
    local isBookMode = (ZO_LoreReader and not ZO_LoreReader:IsHidden())
    local isJournalMode = (ZO_QuestJournal and not ZO_QuestJournal:IsHidden())
    
    -- Marginesy dla wysokości
    local topMargin = 80
    local bottomMargin = 120 -- Domyślny margines dolny
    
    -- Obliczanie szerokości
    if isBookMode then
        currentPanelWidth = screenWidth * 0.22
        if currentPanelWidth < 340 then currentPanelWidth = 340 end 
    elseif isJournalMode then
        currentPanelWidth = screenWidth * 0.45
        if currentPanelWidth < 500 then currentPanelWidth = 500 end
        
        -- Zwiększamy margines dolny o ok. 15% wysokości ekranu (żeby okno wisiało wyżej)
        bottomMargin = screenHeight * 0.15
    else
        -- TRYB NPC / DOMYŚLNY: Okno po lewej, szerokie (45%), WYŻSZE OD DOŁU
        currentPanelWidth = screenWidth * 0.45
        if currentPanelWidth < 500 then currentPanelWidth = 500 end
        
        -- Zwiększamy margines dolny o ok. 15% wysokości ekranu
        bottomMargin = screenHeight * 0.15
    end
    
    local dynamicHeight = screenHeight - (topMargin + bottomMargin)

    -- Aplikowanie wymiarów
    lorePanel:SetDimensions(currentPanelWidth, dynamicHeight)
    lorePanel:ClearAnchors()
    
    -- Aplikowanie Pozycji
    if isBookMode then
        -- Prawa strona
        lorePanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, topMargin)
    else
        -- Lewa strona (NPC / Journal)
        lorePanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, topMargin)
    end
    
    -- Aktualizacja szerokości contentu (minus scrollbar)
    currentContentWidth = currentPanelWidth - 40
    if lorePanelContent then lorePanelContent:SetWidth(currentContentWidth) end
    -- ===============================================
    
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
    
    -- Reset historii
    navigationStack = {}      
    table.insert(navigationStack, { matches = LoreTooltips.currentMatches, index = 1 }) 
    isNavigatingBack = false   

    -- Ustawienie warstwy okna, aby nie zasłaniało comboboxa
    lorePanel:SetDrawTier(DT_MEDIUM)
    lorePanel:SetDrawLayer(DL_STD)

    ShowEntryAtIndex(1)
    lorePanel:SetHidden(false)
    lorePanelVisible = true
end

HideLorePanel = function()
    if lorePanel then 
        lorePanel:SetHidden(true)
        lorePanelVisible = false 
    end
end

-- ============================================
-- PRZYCISKI (KEYBOARD)
-- ============================================

function LoreTooltips.Keyboard:CreateLoreButton()
    if loreButton then return end
    loreButton = WINDOW_MANAGER:CreateControl("LoreTooltipsButton", ZO_InteractWindow, CT_CONTROL)
    loreButton:SetDimensions(110, 36)
    loreButton:SetAnchor(BOTTOMRIGHT, ZO_InteractWindowTargetAreaBodyText, TOPRIGHT, 0, -5)
    loreButton:SetMouseEnabled(true)
    loreButton:SetHidden(true)
    loreButtonBg = WINDOW_MANAGER:CreateControl("LoreTooltipsButtonBG", loreButton, CT_BACKDROP)
    loreButtonBg:SetAnchorFill(loreButton)
    loreButtonBg:SetCenterColor(0.1, 0.1, 0.3, 0.9)
    loreButtonBg:SetEdgeColor(0.4, 0.6, 1, 1)
    loreButtonLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsButtonLabel", loreButton, CT_LABEL)
    loreButtonLabel:SetFont("ZoFontGameBold")
    loreButtonLabel:SetColor(0.4, 0.8, 1, 1)
    loreButtonLabel:SetAnchor(CENTER, loreButton, CENTER, 0, 0)
    loreButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (0)")
    loreButton:SetHandler("OnMouseUp", function(c, b) if b == 1 then if lorePanelVisible then HideLorePanel() else ShowLorePanel() end end end)
end

function LoreTooltips.Keyboard:CreateLoreJournalButton()
    if loreJournalButton then return end
    if not ZO_QuestJournal then return end
    loreJournalButton = WINDOW_MANAGER:CreateControl("LoreTooltipsJournalButton", ZO_QuestJournal, CT_CONTROL)
    loreJournalButton:SetDimensions(110, 36)
    loreJournalButton:SetAnchor(TOPRIGHT, ZO_QuestJournalQuestInfoContainer, TOPRIGHT, 0, -40)
    loreJournalButton:SetMouseEnabled(true)
    loreJournalButton:SetHidden(true)
    loreJournalButton:SetDrawTier(DT_HIGH)
    loreJournalButtonBg = WINDOW_MANAGER:CreateControl("LoreTooltipsJournalButtonBG", loreJournalButton, CT_BACKDROP)
    loreJournalButtonBg:SetAnchorFill(loreJournalButton)
    loreJournalButtonBg:SetCenterColor(0.1, 0.1, 0.3, 0.9)
    loreJournalButtonBg:SetEdgeColor(0.4, 0.6, 1, 1)
    loreJournalButtonLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsJournalButtonLabel", loreJournalButton, CT_LABEL)
    loreJournalButtonLabel:SetFont("ZoFontGameBold")
    loreJournalButtonLabel:SetColor(0.4, 0.8, 1, 1)
    loreJournalButtonLabel:SetAnchor(CENTER, loreJournalButton, CENTER, 0, 0)
    loreJournalButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (0)")
    loreJournalButton:SetHandler("OnMouseUp", function(c, b) if b == 1 then if lorePanelVisible then HideLorePanel() else ShowLorePanel() end end end)
end

function LoreTooltips.Keyboard:CreateLoreBookButton()
    if loreBookButton then return end
    if not ZO_LoreReader then return end
    loreBookButton = WINDOW_MANAGER:CreateControl("LoreTooltipsBookButton", ZO_LoreReader, CT_CONTROL)
    loreBookButton:SetDimensions(110, 36)
    loreBookButton:SetAnchor(TOPRIGHT, ZO_LoreReader, TOPRIGHT, -50, 50)
    loreBookButton:SetMouseEnabled(true)
    loreBookButton:SetHidden(true)
    loreBookButton:SetDrawTier(DT_HIGH)
    loreBookButtonBg = WINDOW_MANAGER:CreateControl("LoreTooltipsBookButtonBG", loreBookButton, CT_BACKDROP)
    loreBookButtonBg:SetAnchorFill(loreBookButton)
    loreBookButtonBg:SetCenterColor(0.1, 0.1, 0.3, 0.9)
    loreBookButtonBg:SetEdgeColor(0.4, 0.6, 1, 1)
    loreBookButtonLabel = WINDOW_MANAGER:CreateControl("LoreTooltipsBookButtonLabel", loreBookButton, CT_LABEL)
    loreBookButtonLabel:SetFont("ZoFontGameBold")
    loreBookButtonLabel:SetColor(0.4, 0.8, 1, 1)
    loreBookButtonLabel:SetAnchor(CENTER, loreBookButton, CENTER, 0, 0)
    loreBookButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (0)")
    loreBookButton:SetHandler("OnMouseUp", function(c, b) if b == 1 then if lorePanelVisible then HideLorePanel() else ShowLorePanel() end end end)
end

-- ============================================
-- INTERFACE PUBLICZNY
-- ============================================

function LoreTooltips.Keyboard:Initialize(localization)
    L = localization
    self:CreateLoreButton()
    self:CreateLoreJournalButton()
    self:CreateLoreBookButton()
end

function LoreTooltips.Keyboard:UpdateInteractions(uniqueCount)
    if not loreButton then self:CreateLoreButton() end
    if loreButton then
        if uniqueCount > 0 then
            loreButton:SetHidden(false)
            loreButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (" .. uniqueCount .. ")")
        else
            loreButton:SetHidden(true)
        end
    end
end

function LoreTooltips.Keyboard:UpdateJournalInteractions(uniqueCount)
    if not loreJournalButton then self:CreateLoreJournalButton() end
    if loreJournalButton then
        if uniqueCount > 0 then
            loreJournalButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (" .. uniqueCount .. ")")
            loreJournalButton:SetHidden(false)
        else
            loreJournalButton:SetHidden(true)
        end
    end
end

function LoreTooltips.Keyboard:UpdateBookInteractions(uniqueCount)
    if not loreBookButton then self:CreateLoreBookButton() end
    if loreBookButton then
         if uniqueCount > 0 then
            loreBookButtonLabel:SetText(L.LORE_BUTTON_TEXT .. " (" .. uniqueCount .. ")")
            loreBookButton:SetHidden(false)
            loreBookButton:SetDrawTier(DT_HIGH); loreBookButton:SetDrawLayer(DL_OVERLAY)
         else
            loreBookButton:SetHidden(true)
         end
    end
end

function LoreTooltips.Keyboard:HideLorePanel()
    HideLorePanel()
end