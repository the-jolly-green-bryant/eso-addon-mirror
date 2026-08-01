-- ============================================
-- Lore Tooltips - Biblioteka (LoreLibrary.lua)
-- Wersja 1.0.1
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.Library = {}

local Library = LoreTooltips.Library
local WM = WINDOW_MANAGER

-- UI handles
local libWindow, detailsLabel, listControl, bgControl, titleControl, counterLabel, detailsScroll, closeBtn, categoryBtn = nil, nil, nil, nil, nil, nil, nil, nil, nil
local searchBox = nil -- Uchwyt do pola wyszukiwania PC

-- === ZMIENNE DLA KOPIOWANIA LINKU ===
local copyLinkBtn = nil
local linkPopup = nil
local linkEditBox = nil
-- ====================================

local listScrollBar = nil
local alphabetControl = nil
local alphabetButtons = {}
local shortcutWindow, shortcutBtn = nil, nil
local rows = {}
local sceneInitialized = false
local lorePanelFragment = nil 
local LORE_LIBRARY_GAMEPAD_SCENE = nil
local LORE_LIBRARY_SCENE = nil -- Scena dla PC

-- NAZWA SCENY GAMEPAD
local GAMEPAD_SCENE_NAME = "LoreTooltipsGamepadScene"

-- Dane
local dataList = {}
local filteredList = {}
local activeLetters = {} 
local currentCategory = "Wszystkie"
local currentSearch = ""
local selectedIndex = 1
local scrollOffset = 0
local ALPHABET = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

-- Config
local MAX_ROWS = 10
local GAMEPAD_COOLDOWN = 0
local ADDON_NAME = "LoreTooltips"

-- ============================================
-- 1. Logika Danych i Pomocnicze
-- ============================================

local function GetCategories()
    local cats = { ["Wszystkie"] = true }
    if LoreTooltips.Database then
        for _, entry in pairs(LoreTooltips.Database) do
            local c = (entry.category and entry.category ~= "") and entry.category or "Inne"
            cats[c] = true
        end
    end
    local sorted = {}
    for k in pairs(cats) do table.insert(sorted, k) end
    table.sort(sorted)
    return sorted
end

local function GetFirstChar(str)
    if not str or str == "" then return "" end
    return zo_strupper(zo_strsub(str, 1, 1))
end

local function BuildData()
    dataList = {}
    if not LoreTooltips.Database then return end
    for key, entry in pairs(LoreTooltips.Database) do
        table.insert(dataList, {
            key = key,
            title = entry.title or key,
            desc = entry.description or "",
            cat = (entry.category and entry.category ~= "") and entry.category or "Inne",
            src = entry.sourceDisplayName or entry.sourceName or "Nieznane"
        })
    end
    table.sort(dataList, function(a,b) return a.title < b.title end)
end

-- Funkcja filtrowania (Szukanie od 3 znaków + Aliasy)
local function FilterData()
    filteredList = {}
    activeLetters = {} 
    
    local search = currentSearch:lower()
    local searchLen = string.len(search)
    local useSearch = (searchLen >= 3)
    
    -- Cache aliasów
    local matchingAliasKeys = {}
    if useSearch and LoreTooltips.Aliases then
        for alias, key in pairs(LoreTooltips.Aliases) do
            if string.find(alias, search, 1, true) then
                matchingAliasKeys[key] = true
            end
        end
    end

    for _, item in ipairs(dataList) do
        local matchCat = (currentCategory == "Wszystkie") or (item.cat == currentCategory)
        local matchText = true
        
        if useSearch then
            local foundInTitle = string.find(item.title:lower(), search, 1, true)
            local foundInAlias = matchingAliasKeys[item.key]
            matchText = foundInTitle or foundInAlias
        end
        
        if matchCat and matchText then
            table.insert(filteredList, item)
            local firstChar = GetFirstChar(item.title)
            activeLetters[firstChar] = true
        end
    end
    
    if selectedIndex > #filteredList then selectedIndex = #filteredList end
    if selectedIndex < 1 and #filteredList > 0 then selectedIndex = 1 end
    if #filteredList == 0 then selectedIndex = 0 end
    
    scrollOffset = 0
    if selectedIndex > MAX_ROWS then
        scrollOffset = selectedIndex - MAX_ROWS
    end
end

-- Deklaracje
local RefreshList
local UpdateListScrollBar
local ApplyLayout 

-- Podświetlanie alfabetu
local function UpdateAlphabetHighlight()
    if not alphabetControl or alphabetControl:IsHidden() then return end
    
    local currentItem = filteredList[selectedIndex]
    local currentSelectionChar = ""
    if currentItem then
        currentSelectionChar = GetFirstChar(currentItem.title)
    end
    
    for i, btn in ipairs(alphabetButtons) do
        local label = btn:GetNamedChild("Label")
        local letter = ALPHABET[i]
        
        if label then
            if letter == currentSelectionChar then
                 label:SetColor(1, 0.84, 0, 1) 
                 label:SetAlpha(1)
                 btn:SetMouseEnabled(true)
            elseif activeLetters[letter] then
                 label:SetColor(0.7, 0.7, 0.7, 1)
                 label:SetAlpha(0.9)
                 btn:SetMouseEnabled(true) 
            else
                 label:SetColor(0.2, 0.2, 0.2, 1)
                 label:SetAlpha(0.5)
                 btn:SetMouseEnabled(false) 
            end
        end
    end
end

local function JumpToLetter(letter)
    if #filteredList == 0 then return end
    if not activeLetters[letter] then return end 
    
    local foundIndex = nil
    for i, item in ipairs(filteredList) do
        local first = GetFirstChar(item.title)
        if first == letter then
            foundIndex = i
            break
        end
    end
    
    if foundIndex then
        selectedIndex = foundIndex
        scrollOffset = math.max(0, selectedIndex - 1)
        RefreshList(true)
    end
end

local function JumpToNextLetterSection(direction)
    if #filteredList == 0 then return end
    local currentItem = filteredList[selectedIndex]
    if not currentItem then return end
    
    local currentChar = GetFirstChar(currentItem.title)
    local targetIndex = selectedIndex
    
    if direction > 0 then -- Następna
        for i = selectedIndex + 1, #filteredList do
            local nextChar = GetFirstChar(filteredList[i].title)
            if nextChar ~= currentChar then
                targetIndex = i
                break
            end
        end
        if targetIndex == selectedIndex and selectedIndex < #filteredList then
             targetIndex = #filteredList
        end
    else -- Poprzednia
        local prevIndex = selectedIndex - 1
        if prevIndex >= 1 then
             local prevChar = GetFirstChar(filteredList[prevIndex].title)
             if prevChar == currentChar then
                 for i = selectedIndex, 1, -1 do
                     if GetFirstChar(filteredList[i].title) ~= currentChar then
                         break
                     end
                     targetIndex = i
                 end
                 if targetIndex == selectedIndex then
                     for i = selectedIndex - 1, 1, -1 do
                         if GetFirstChar(filteredList[i].title) ~= currentChar then
                             targetIndex = i
                             local targetChar = GetFirstChar(filteredList[targetIndex].title)
                             for j = targetIndex, 1, -1 do
                                 if GetFirstChar(filteredList[j].title) ~= targetChar then
                                     break
                                 end
                                 targetIndex = j
                             end
                             break
                         end
                     end
                 end
             else
                 local targetChar = prevChar
                 targetIndex = prevIndex
                 for i = prevIndex, 1, -1 do
                     if GetFirstChar(filteredList[i].title) ~= targetChar then
                         break
                     end
                     targetIndex = i
                 end
             end
        else
            targetIndex = 1
        end
    end
    
    if targetIndex ~= selectedIndex then
        selectedIndex = targetIndex
        scrollOffset = math.max(0, selectedIndex - 1)
        RefreshList(true)
        PlaySound(SOUNDS.GAMEPAD_MENU_UP)
    end
end

-- ============================================
-- 2. Aktualizacja Wyglądu
-- ============================================

local function ShowCategoryMenu(control)
    ClearMenu()
    local cats = GetCategories()
    for _, cat in ipairs(cats) do
        AddMenuItem(cat, function()
            currentCategory = cat
            selectedIndex = 1
            FilterData()
            if ApplyLayout then ApplyLayout() end 
        end)
    end
    ShowMenu(control)
end

local function RefreshDetails()
    if not detailsLabel then return end
    local item = filteredList[selectedIndex]

    if not item then
        detailsLabel:SetText("")
        if counterLabel then counterLabel:SetText("Brak wyników") end
        return
    end
    
    local titleColor = "|cFFD700"
    local catColor = "|cAAAAAA"
    local bodyColor = "|cFFFFFF"
    local srcColor = "|c00FF00"
    
    local text = string.format("%s%s|r\n%s(%s)|r\n\n%s%s|r\n\n%s[%s]|r",
        titleColor, item.title,
        catColor, item.cat,
        bodyColor, item.desc,
        srcColor, item.src
    )
    detailsLabel:SetText(text)
    
    if counterLabel then
        counterLabel:SetText(string.format("Pozycja: %d / %d", math.max(selectedIndex, #filteredList > 0 and 1 or 0), #filteredList))
    end
end

UpdateListScrollBar = function()
    if not listScrollBar then return end
    local isGamepad = IsInGamepadPreferredMode()
    if isGamepad then
        listScrollBar:SetHidden(true)
        return
    end

    local totalData = #filteredList
    if totalData <= MAX_ROWS then
        listScrollBar:SetHidden(true)
    else
        listScrollBar:SetHidden(false)
        local maxOffset = totalData - MAX_ROWS
        listScrollBar:SetMinMax(0, maxOffset)
        listScrollBar:SetValue(scrollOffset)
        listScrollBar:SetThumbTextureHeight(30)
    end
end

RefreshList = function(manualScroll)
    if not listControl then return end
    local isGamepad = IsInGamepadPreferredMode()
    local rowHeight = isGamepad and 60 or 32
    MAX_ROWS = isGamepad and 10 or 18
    
    if not manualScroll then
        if selectedIndex > scrollOffset + MAX_ROWS then
            scrollOffset = selectedIndex - MAX_ROWS
        elseif selectedIndex < scrollOffset + 1 then
            scrollOffset = math.max(selectedIndex - 1,0)
        end
    end
    
    local maxScroll = math.max(0, #filteredList - MAX_ROWS)
    if scrollOffset < 0 then scrollOffset = 0 end
    if scrollOffset > maxScroll then scrollOffset = maxScroll end
    
    for i = 1, #rows do
        local row = rows[i]
        local dataIdx = scrollOffset + i        
        
        if i > MAX_ROWS or not filteredList[dataIdx] then
            row:SetHidden(true)
        else
            local item = filteredList[dataIdx]
            row:SetHidden(false)
            row:SetHeight(rowHeight)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, listControl, TOPLEFT, 0, (i-1)*rowHeight)
            row:SetAnchor(TOPRIGHT, listControl, TOPRIGHT, 0, ((i-1)*rowHeight)+rowHeight)
            
            local lbl = row:GetNamedChild("Label")
            lbl:SetText(item.title)
            local bg = row:GetNamedChild("BG")
            
            if isGamepad then
                lbl:SetFont("ZoFontGamepad42")
                if dataIdx == selectedIndex then
                    lbl:SetColor(1, 1, 1, 1)
                    bg:SetCenterColor(1, 1, 1, 0.2)
                    bg:SetEdgeColor(1, 1, 1, 1)
                else
                    lbl:SetColor(0.6, 0.6, 0.6, 1)
                    bg:SetCenterColor(0,0,0,0)
                    bg:SetEdgeColor(0,0,0,0)
                end
            else
                lbl:SetFont("ZoFontGameLarge")
                if dataIdx == selectedIndex then
                    lbl:SetColor(1, 0.84, 0, 1) 
                    bg:SetCenterColor(0.4, 0.4, 0.2, 0.4)
                    bg:SetEdgeColor(0.6, 0.5, 0.2, 0.8)
                else
                    lbl:SetColor(0.9, 0.9, 0.9, 1)
                    if row.isMouseOver then
                        bg:SetCenterColor(0.2, 0.2, 0.2, 0.4)
                    else
                        bg:SetCenterColor(0,0,0,0)
                        bg:SetEdgeColor(0,0,0,0)
                    end
                end
            end
            
            row.dataIndex = dataIdx
            
            if not row.eventsAdded then
                row:SetHandler("OnMouseUp", function(control, button, upInside)
                    local currentDataIdx = control.dataIndex
                    if not IsInGamepadPreferredMode() and filteredList[currentDataIdx] then
                        selectedIndex = currentDataIdx
                        RefreshList() 
                        RefreshDetails()
                    end
                end)
                
                row:SetHandler("OnMouseEnter", function(control)
                    if not IsInGamepadPreferredMode() then
                        control.isMouseOver = true
                        local bg = control:GetNamedChild("BG")
                        if selectedIndex ~= control.dataIndex then 
                            bg:SetCenterColor(0.2, 0.2, 0.2, 0.4) 
                        end
                    end
                end)
                
                row:SetHandler("OnMouseExit", function(control)
                    if not IsInGamepadPreferredMode() then
                        control.isMouseOver = false
                        local bg = control:GetNamedChild("BG")
                        if selectedIndex ~= control.dataIndex then 
                            bg:SetCenterColor(0,0,0,0) 
                        end
                    end
                end)
                
                row:SetHandler("OnMouseWheel", function(self, delta)
                    if not IsInGamepadPreferredMode() then
                        if delta > 0 then scrollOffset = scrollOffset - 1 else scrollOffset = scrollOffset + 1 end
                        RefreshList(true)
                        UpdateListScrollBar()
                    end
                end)
                row.eventsAdded = true
            end
        end
    end
    RefreshDetails()
    UpdateListScrollBar()
    UpdateAlphabetHighlight()
end

-- ============================================
-- 3. Inicjalizacja UI i SCENY
-- ============================================

-- Funkcja pomocnicza do Popupu Linku
local function ShowLinkPopup(url)
    if not linkPopup then
        linkPopup = WM:CreateTopLevelWindow("LoreLibraryLinkPopup")
        linkPopup:SetDimensions(500, 100)
        linkPopup:SetDrawTier(DT_HIGH)
        linkPopup:SetDrawLayer(DL_OVERLAY)
        linkPopup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        linkPopup:SetMouseEnabled(true)
        linkPopup:SetMovable(true)
        linkPopup:SetClampedToScreen(true)
        linkPopup:SetHidden(true)
        
        local bg = WM:CreateControl("$(parent)BG", linkPopup, CT_BACKDROP)
        bg:SetAnchorFill(linkPopup)
        bg:SetCenterColor(0.05, 0.05, 0.1, 0.95)
        bg:SetEdgeColor(0.4, 0.8, 0.4, 1)
        
        local title = WM:CreateControl("$(parent)Title", linkPopup, CT_LABEL)
        title:SetFont("ZoFontGameBold")
        title:SetColor(0.4, 1, 0.4, 1)
        title:SetAnchor(TOP, linkPopup, TOP, 0, 10)
        -- Tłumaczenie tytułu popupu (zmienna językowa)
        title:SetText(LoreTooltips.L and LoreTooltips.L.COPY_LINK_POPUP_TITLE or "Kopiuj Link")
        
        local editBg = WM:CreateControl("$(parent)EditBG", linkPopup, CT_BACKDROP)
        editBg:SetDimensions(470, 30)
        editBg:SetAnchor(TOP, linkPopup, TOP, 0, 40)
        editBg:SetCenterColor(0.1, 0.1, 0.15, 1)
        editBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
        
        linkEditBox = WM:CreateControl("$(parent)EditBox", linkPopup, CT_EDITBOX)
        linkEditBox:SetDimensions(460, 26)
        linkEditBox:SetAnchor(CENTER, editBg, CENTER, 0, 0)
        linkEditBox:SetFont("ZoFontGame")
        linkEditBox:SetColor(0.9, 0.9, 0.9, 1)
        linkEditBox:SetMaxInputChars(500)
        linkEditBox:SetMouseEnabled(true)
        
        linkEditBox:SetHandler("OnEnter", function() linkPopup:SetHidden(true) end)
        linkEditBox:SetHandler("OnEscape", function() linkPopup:SetHidden(true) end)
        
        local closeBtn = WM:CreateControl("$(parent)Close", linkPopup, CT_BUTTON)
        closeBtn:SetDimensions(100, 28)
        closeBtn:SetAnchor(BOTTOM, linkPopup, BOTTOM, 0, -10)
        closeBtn:SetMouseEnabled(true)
        
        local closeBtnBg = WM:CreateControl("$(parent)BG", closeBtn, CT_BACKDROP)
        closeBtnBg:SetAnchorFill(closeBtn)
        closeBtnBg:SetCenterColor(0.3, 0.1, 0.1, 0.9)
        closeBtnBg:SetEdgeColor(0.8, 0.4, 0.4, 1)
        closeBtnBg:SetMouseEnabled(false)
        
        local closeBtnLabel = WM:CreateControl("$(parent)Label", closeBtn, CT_LABEL)
        closeBtnLabel:SetFont("ZoFontGameSmall")
        closeBtnLabel:SetColor(1, 0.6, 0.6, 1)
        closeBtnLabel:SetAnchor(CENTER, closeBtn, CENTER, 0, 0)
        -- Tłumaczenie przycisku zamknięcia (zmienna językowa)
        closeBtnLabel:SetText(LoreTooltips.L and LoreTooltips.L.POPUP_CLOSE or "Zamknij")
        
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

local function CreateUI()
    if libWindow then return end
    
    -- Główne okno
    libWindow = WM:CreateTopLevelWindow("LoreLibraryWindow")
    libWindow:SetClampedToScreen(true)
    libWindow:SetMouseEnabled(true)
    libWindow:SetMovable(true)
    libWindow:SetHidden(true)
    
    bgControl = WM:CreateControl("$(parent)BG", libWindow, CT_BACKDROP)
    bgControl:SetAnchorFill(libWindow)
    bgControl:SetEdgeTexture(nil, 128, 2, 2)
    bgControl:SetDrawTier(DT_LOW)
    
    titleControl = WM:CreateControl("$(parent)Title", libWindow, CT_LABEL)
    titleControl:SetColor(1, 0.84, 0, 1)
    titleControl:SetAnchor(TOPLEFT, libWindow, TOPLEFT, 30, 20)
    
    closeBtn = WM:CreateControl("$(parent)Close", libWindow, CT_BUTTON)
    closeBtn:SetDimensions(32, 32)
    closeBtn:SetAnchor(TOPRIGHT, libWindow, TOPRIGHT, -10, 10)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
    closeBtn:SetHandler("OnClicked", function() Library.Toggle() end)
    closeBtn:SetHidden(true) 

    -- === POLE WYSZUKIWANIA (PC) ===
    local searchBg = WM:CreateControl("$(parent)SearchBg", libWindow, CT_BACKDROP)
    searchBg:SetDimensions(250, 30)
    searchBg:SetAnchor(TOPRIGHT, libWindow, TOPRIGHT, -60, 70) 
    searchBg:SetCenterColor(0, 0, 0, 0.5)
    searchBg:SetEdgeColor(0.4, 0.4, 0.3, 1)
    searchBg:SetEdgeTexture(nil, 1, 1, 1)
    searchBg:SetMouseEnabled(true) 
    
    searchBox = WM:CreateControlFromVirtual("$(parent)SearchBox", searchBg, "ZO_DefaultEdit")
    searchBox:SetAnchorFill(searchBg)
    searchBox:SetMaxInputChars(50)
    searchBox:SetText("")
    
    local searchPlaceholder = WM:CreateControl("$(parent)Placeholder", searchBox, CT_LABEL)
    searchPlaceholder:SetFont("ZoFontGame")
    searchPlaceholder:SetColor(0.5, 0.5, 0.5, 1)
    searchPlaceholder:SetText("Szukaj (min. 3 znaki)...")
    searchPlaceholder:SetAnchor(LEFT, searchBox, LEFT, 5, 0)

    -- Logika wpisywania
    searchBox:SetHandler("OnTextChanged", function(self)
        local text = self:GetText()
        if text ~= "" then
            searchPlaceholder:SetHidden(true)
        else
            searchPlaceholder:SetHidden(false)
        end
        currentSearch = text
        FilterData()
        RefreshList() 
    end)
    
    -- Efekty wizualne
    local function UpdateSearchVisuals(focused)
        if focused then
            searchBg:SetEdgeColor(1, 0.84, 0, 1)
            searchPlaceholder:SetHidden(true)
        else
            searchBg:SetEdgeColor(0.4, 0.4, 0.3, 1) 
            if searchBox:GetText() == "" then searchPlaceholder:SetHidden(false) end
        end
    end

    searchBox:SetHandler("OnFocusGained", function() UpdateSearchVisuals(true) end)
    searchBox:SetHandler("OnFocusLost", function() UpdateSearchVisuals(false) end)
    
    -- Kliknięcie w tło
    searchBg:SetHandler("OnMouseUp", function() searchBox:TakeFocus() end)
    searchBg:SetHandler("OnMouseEnter", function() if not searchBox:HasFocus() then searchBg:SetEdgeColor(1, 1, 1, 1) end end)
    searchBg:SetHandler("OnMouseExit", function() if not searchBox:HasFocus() then searchBg:SetEdgeColor(0.4, 0.4, 0.3, 1) end end)

    searchBox.bgControl = searchBg
    -- ==============================

    -- Skrót PC
    shortcutWindow = WM:CreateTopLevelWindow("LoreLibraryShortcutWindow")
    shortcutWindow:SetDimensions(64, 64)
    shortcutWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100) 
    shortcutWindow:SetClampedToScreen(true)
    shortcutWindow:SetMovable(true)
    shortcutWindow:SetMouseEnabled(true)
    shortcutWindow:SetHidden(true) 

    shortcutBtn = WM:CreateControl("$(parent)Btn", shortcutWindow, CT_BUTTON)
    shortcutBtn:SetAnchorFill(shortcutWindow)
    shortcutBtn:SetNormalTexture("EsoUI/Art/MainMenu/menuBar_journal_up.dds")
    shortcutBtn:SetPressedTexture("EsoUI/Art/MainMenu/menuBar_journal_down.dds")
    shortcutBtn:SetMouseOverTexture("EsoUI/Art/MainMenu/menuBar_journal_over.dds")
    
    local dragStartX, dragStartY = 0, 0
    
    shortcutBtn:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            dragStartX, dragStartY = GetUIMousePosition()
            shortcutWindow:StartMoving()
        end
    end)
    
    shortcutBtn:SetHandler("OnMouseUp", function(self, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            shortcutWindow:StopMovingOrResizing()
            if LoreTooltips.savedVars then
                LoreTooltips.savedVars.libIconPosX = shortcutWindow:GetLeft()
                LoreTooltips.savedVars.libIconPosY = shortcutWindow:GetTop()
            end
            local endX, endY = GetUIMousePosition()
            local deltaX = endX - dragStartX
            local deltaY = endY - dragStartY
            local distSq = deltaX*deltaX + deltaY*deltaY
            if upInside and distSq < 25 then 
                Library.Toggle()
            end
        end
    end)
    
    categoryBtn = WM:CreateControl("$(parent)CategoryButton", libWindow, CT_BUTTON)
    categoryBtn:SetDimensions(250, 32)
    categoryBtn:SetHidden(true)
    
    local catBg = WM:CreateControl("$(parent)BG", categoryBtn, CT_BACKDROP)
    catBg:SetAnchorFill(categoryBtn)
    catBg:SetCenterColor(0.2, 0.2, 0.2, 0.9)
    catBg:SetEdgeColor(0.4, 0.4, 0.3, 1)
    
    local catLbl = WM:CreateControl("$(parent)Label", categoryBtn, CT_LABEL)
    catLbl:SetAnchor(CENTER, categoryBtn, CENTER, 0, 0)
    catLbl:SetFont("ZoFontGame")
    catLbl:SetText("Kategoria: Wszystkie")
    
    categoryBtn:SetHandler("OnClicked", function() ShowCategoryMenu(categoryBtn) end)
    categoryBtn:SetHandler("OnMouseEnter", function() catBg:SetCenterColor(0.3, 0.3, 0.3, 1) end)
    categoryBtn:SetHandler("OnMouseExit", function() catBg:SetCenterColor(0.2, 0.2, 0.2, 0.9) end)

    -- === PRZYCISK KOPIOWANIA LINKU (NOWY) ===
    copyLinkBtn = WM:CreateControl("$(parent)CopyLink", libWindow, CT_BUTTON)
    copyLinkBtn:SetDimensions(100, 28)
    
    local linkBtnBg = WM:CreateControl("$(parent)BG", copyLinkBtn, CT_BACKDROP)
    linkBtnBg:SetAnchorFill(copyLinkBtn)
    linkBtnBg:SetCenterColor(0.1, 0.3, 0.1, 0.9)
    linkBtnBg:SetEdgeColor(0.4, 0.8, 0.4, 1)
    
    local linkBtnLabel = WM:CreateControl("$(parent)Label", copyLinkBtn, CT_LABEL)
    linkBtnLabel:SetAnchor(CENTER, copyLinkBtn, CENTER, 0, 0)
    linkBtnLabel:SetFont("ZoFontGameSmall")
    linkBtnLabel:SetColor(0.4, 1, 0.4, 1)
    -- Użycie zmiennej językowej (ta sama co w Keyboard module)
    linkBtnLabel:SetText(LoreTooltips.L and LoreTooltips.L.COPY_LINK_BUTTON or "Link")
    
    copyLinkBtn:SetHandler("OnClicked", function()
        local item = filteredList[selectedIndex]
        if item and LoreTooltips.Database[item.key] then
            local entry = LoreTooltips.Database[item.key]
            local url = entry.url
            
            if not url or url == "" then
                local wikiKey = item.key
                local sourceName = entry.sourceName or ""
                
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
            
            if url then ShowLinkPopup(url) end
        end
    end)
    -- =========================================

    counterLabel = WM:CreateControl("$(parent)Counter", libWindow, CT_LABEL)
    counterLabel:SetColor(0.7, 0.7, 0.7, 1)
    counterLabel:SetAnchor(TOPRIGHT, libWindow, TOPRIGHT, -50, 25)
    counterLabel:SetFont("ZoFontGameSmall")
    
    alphabetControl = WM:CreateControl("$(parent)Alphabet", libWindow, CT_CONTROL)
    alphabetControl:SetWidth(25)
    alphabetControl:SetHidden(true)
    
    local btnHeight = 22
    for i, letter in ipairs(ALPHABET) do
        local btn = WM:CreateControl("$(parent)Btn"..letter, alphabetControl, CT_BUTTON)
        btn:SetDimensions(20, btnHeight)
        btn:SetAnchor(TOP, alphabetControl, TOP, 0, (i-1)*btnHeight)
        
        local label = WM:CreateControl("$(parent)Label", btn, CT_LABEL)
        label:SetAnchor(CENTER, btn, CENTER, 0, 0)
        label:SetText(letter)
        label:SetFont("ZoFontGameSmall")
        label:SetColor(0.6, 0.6, 0.6, 1)
        
        btn:SetHandler("OnMouseUp", function() 
            if not IsInGamepadPreferredMode() then JumpToLetter(letter) end 
        end)
        btn:SetHandler("OnMouseEnter", function() 
            if not IsInGamepadPreferredMode() and btn:IsMouseEnabled() then 
                label:SetColor(1, 1, 1, 1) 
            end
        end)
        btn:SetHandler("OnMouseExit", function() 
             if not IsInGamepadPreferredMode() then 
                 UpdateAlphabetHighlight()
             end
        end)
        
        table.insert(alphabetButtons, btn)
    end
    
    listControl = WM:CreateControl("$(parent)List", libWindow, CT_CONTROL)
    listControl:SetMouseEnabled(true)
    listControl:SetHandler("OnMouseWheel", function(self, delta)
        if not IsInGamepadPreferredMode() then
            if delta > 0 then scrollOffset = scrollOffset - 1 else scrollOffset = scrollOffset + 1 end
            RefreshList(true)
            UpdateListScrollBar()
        end
    end)

    listScrollBar = WM:CreateControl("$(parent)ScrollBar", listControl, CT_SLIDER)
    listScrollBar:SetDimensions(16, 500)
    listScrollBar:SetAnchor(TOPRIGHT, listControl, TOPRIGHT, 0, 0)
    listScrollBar:SetAnchor(BOTTOMRIGHT, listControl, BOTTOMRIGHT, 0, 0)
    listScrollBar:SetOrientation(ORIENTATION_VERTICAL)
    listScrollBar:SetThumbTexture("EsoUI/Art/ChatWindow/chat_scrollThumb.dds", 16, 32, 0, 0, 1, 1, 0, 0)
    listScrollBar:SetBackgroundMiddleTexture("EsoUI/Art/ChatWindow/chat_scrollTrack.dds")
    listScrollBar:SetHidden(true)
    listScrollBar:SetHandler("OnValueChanged", function(self, value, eventReason)
        if eventReason == EVENT_REASON_HARDWARE then
            scrollOffset = math.floor(value)
            RefreshList(true)
        end
    end)
    
    detailsScroll = WM:CreateControlFromVirtual("$(parent)Details", libWindow, "ZO_ScrollContainer")
    local scrollChild = detailsScroll:GetNamedChild("ScrollChild")
    detailsLabel = WM:CreateControl("$(parent)Text", scrollChild, CT_LABEL)
    detailsLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, 0)
    
    for i=1, 25 do 
        local row = WM:CreateControl("LoreLibRow"..i, listControl, CT_CONTROL)
        row:SetMouseEnabled(true)
        local bg = WM:CreateControl("$(parent)BG", row, CT_BACKDROP)
        bg:SetAnchorFill(row)
        bg:SetDrawTier(DT_LOW) 
        local lbl = WM:CreateControl("$(parent)Label", row, CT_LABEL)
        lbl:SetAnchor(LEFT, row, LEFT, 10, 0)
        lbl:SetAnchor(RIGHT, row, RIGHT, -20, 0)
        table.insert(rows, row)
    end
    
    lorePanelFragment = ZO_FadeSceneFragment:New(libWindow)

    -- === FIX NAZW SCENY ===
    -- Zmieniono nazwę sceny PC na unikalną, aby nie nadpisywała systemowej "loreLibrary"
    LORE_LIBRARY_SCENE = ZO_Scene:New("LoreTooltipsScenePC", SCENE_MANAGER)
    LORE_LIBRARY_SCENE:AddFragment(lorePanelFragment)
    
    -- Gamepad scena jest tworzona w EnsureGamepadScene
end

ApplyLayout = function()
    local isGamepad = IsInGamepadPreferredMode()
    if not libWindow then return end 
    
    if isGamepad then
        -- === TRYB GAMEPAD ===
        if closeBtn then closeBtn:SetHidden(true) end
        if categoryBtn then categoryBtn:SetHidden(true) end
        if listScrollBar then listScrollBar:SetHidden(true) end
        -- Ukrywamy ikonę skrótu na padzie
        if shortcutWindow then shortcutWindow:SetHidden(true) end 
        
        -- Ukryj pole wyszukiwania PC
        if searchBox and searchBox.bgControl then 
            searchBox.bgControl:SetHidden(true) 
            searchBox:SetHidden(true)
        end
        
        -- Ukryj przycisk linku na padzie
        if copyLinkBtn then copyLinkBtn:SetHidden(true) end

        libWindow:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
        libWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        bgControl:SetCenterColor(0.05, 0.05, 0.05, 0.98)
        bgControl:SetEdgeColor(0, 0, 0, 0)
        
        titleControl:SetFont("ZoFontGamepadBold48")
        titleControl:SetText("Biblioteka Lore  (Kategoria: " .. currentCategory .. ")")
        
        if alphabetControl then
            alphabetControl:SetHidden(false)
            alphabetControl:ClearAnchors()
            alphabetControl:SetAnchor(TOPRIGHT, listControl, TOPLEFT, -10, 20)
            alphabetControl:SetHeight(600)
             for _, btn in ipairs(alphabetButtons) do
                btn:SetMouseEnabled(false) 
            end
        end

        listControl:SetDimensions(550, 700)
        listControl:ClearAnchors()
        listControl:SetAnchor(TOPLEFT, libWindow, TOPLEFT, 100, 150)
        
        detailsScroll:ClearAnchors()
        detailsScroll:SetAnchor(TOPLEFT, listControl, TOPRIGHT, 50, 0)
        detailsScroll:SetAnchor(BOTTOMRIGHT, libWindow, BOTTOMRIGHT, -100, -150)
        
        if detailsLabel then
            detailsLabel:SetFont("ZoFontGamepad34")
            local allowedWidth = (GuiRoot:GetWidth() - 100) - (100 + 550 + 50)
            detailsLabel:SetWidth(allowedWidth - 20)
        end

    else
        -- === TRYB KLAWIATURA/MYSZ ===
        if closeBtn then closeBtn:SetHidden(false) end
        if categoryBtn then 
            categoryBtn:SetHidden(false) 
            categoryBtn:ClearAnchors()
            categoryBtn:SetAnchor(TOPLEFT, libWindow, TOPLEFT, 60, 70)
            local btnLbl = categoryBtn:GetNamedChild("Label")
            if btnLbl then btnLbl:SetText("Kategoria: " .. currentCategory) end
        end
        
        -- Pokaż pole wyszukiwania PC i zsynchronizuj tekst
        if searchBox and searchBox.bgControl then 
            searchBox.bgControl:SetHidden(false) 
            searchBox:SetHidden(false)
            if searchBox:GetText() ~= currentSearch then
                searchBox:SetText(currentSearch)
            end
        end

        -- Pokaż ikonę skrótu na PC
        if shortcutWindow then 
            shortcutWindow:SetHidden(false) 
            if LoreTooltips.savedVars and LoreTooltips.savedVars.libIconPosX then
                shortcutWindow:ClearAnchors()
                shortcutWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LoreTooltips.savedVars.libIconPosX, LoreTooltips.savedVars.libIconPosY)
            end
        end 

        -- Pokaż przycisk Linku (PC)
        if copyLinkBtn then
            copyLinkBtn:SetHidden(false)
            copyLinkBtn:ClearAnchors()
            -- POPRAWKA POZYCJI: -230px od prawej, aby nie zasłaniał licznika "Pozycja: X / Y"
            copyLinkBtn:SetAnchor(TOPRIGHT, libWindow, TOPRIGHT, -230, 12) 
        end
        
        local width = 1200
        local height = 800
        libWindow:SetDimensions(width, height)
        libWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        bgControl:SetCenterColor(0.05, 0.05, 0.05, 0.98)
        bgControl:SetEdgeColor(0.6, 0.5, 0.2, 1)
        titleControl:SetFont("ZoFontWinH1")
        titleControl:SetText("Biblioteka Lore")
        
        listControl:SetDimensions(400, height - 150)
        listControl:ClearAnchors()
        listControl:SetAnchor(TOPLEFT, libWindow, TOPLEFT, 60, 110)
        
        if listScrollBar then UpdateListScrollBar() end
        
        if alphabetControl then
            alphabetControl:SetHidden(false)
            alphabetControl:ClearAnchors()
            alphabetControl:SetAnchor(TOPLEFT, libWindow, TOPLEFT, 20, 110)
            alphabetControl:SetHeight(height - 150)
            for _, btn in ipairs(alphabetButtons) do
                -- Myszka włączana/wyłączana dynamicznie w UpdateAlphabetHighlight
            end
        end
        
        detailsScroll:ClearAnchors()
        detailsScroll:SetAnchor(TOPLEFT, listControl, TOPRIGHT, 40, 0)
        detailsScroll:SetAnchor(BOTTOMRIGHT, libWindow, BOTTOMRIGHT, -30, -40)
        
        if detailsLabel then
            detailsLabel:SetFont("ZoFontGameLarge")
            local scrollWidth = (width - 30) - (60 + 400 + 40)
            detailsLabel:SetWidth(scrollWidth - 20)
        end
    end
    RefreshList()
end

Library.keybindStripDesc = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        name = "Zamknij",
        keybind = "UI_SHORTCUT_NEGATIVE",
        callback = function() Library.Toggle() end,
    },
    {
        name = "Zmień Kategorię",
        keybind = "UI_SHORTCUT_SECONDARY", -- X / Square
        callback = function()
            local cats = GetCategories()
            local currentIdx = 1
            for i, c in ipairs(cats) do if c == currentCategory then currentIdx = i break end end
            currentIdx = currentIdx + 1
            if currentIdx > #cats then currentIdx = 1 end
            currentCategory = cats[currentIdx]
            FilterData()
            ApplyLayout()
        end,
    },
    {
        name = "Szukaj",
        keybind = "UI_SHORTCUT_TERTIARY", -- Y / Triangle
        callback = function()
            -- Używamy naszego zdefiniowanego dialogu
            local data = {
                headerTitle = "Szukaj w Lore",
                instructions = "Wpisz frazę (min. 3 znaki)",
                defaultText = currentSearch,
                finishedCallback = function(text)
                    currentSearch = text or ""
                    
                    -- Synchronizacja z polem PC
                    if searchBox then searchBox:SetText(currentSearch) end
                    
                    FilterData()
                    ApplyLayout()
                    KEYBIND_STRIP:UpdateKeybindButtonGroup(Library.keybindStripDesc)
                end
            }
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_TEXT_ENTRY", data)
        end,
    },
    {
        name = "Wyczyść filtr",
        keybind = "UI_SHORTCUT_RIGHT_STICK", -- Kliknięcie Prawego Drążka (R3/RS)
        callback = function()
            currentSearch = ""
            if searchBox then searchBox:SetText("") end
            FilterData()
            RefreshList()
            PlaySound(SOUNDS.DEFAULT_CLICK)
            KEYBIND_STRIP:UpdateKeybindButtonGroup(Library.keybindStripDesc)
        end,
        visible = function() return currentSearch ~= "" end,
    },
    -- Nawigacja Alfabetyczna dla PADA (BUMPERY L1/R1)
    {
        name = "Poprzednia Litera",
        keybind = "UI_SHORTCUT_LEFT_SHOULDER", -- L1 / LB
        callback = function() JumpToNextLetterSection(-1) end,
        visible = function() return #filteredList > 1 end,
    },
    {
        name = "Następna Litera",
        keybind = "UI_SHORTCUT_RIGHT_SHOULDER", -- R1 / RB
        callback = function() JumpToNextLetterSection(1) end,
        visible = function() return #filteredList > 1 end,
    },
}

function OnUpdateHandler()
    if not libWindow then return end
    if not IsInGamepadPreferredMode() or libWindow:IsHidden() then return end
    
    -- ZABEZPIECZENIE: Nie przewijaj listy, jeśli otwarte jest okno dialogowe
    if ZO_Dialogs_IsShowingDialog() then return end

    local now = GetFrameTimeMilliseconds()
    
    -- Lewy drążek (nawigacja po liście)
    local leftY = ZO_Gamepad_GetLeftStickEasedY()
    if math.abs(leftY) > 0.2 then
        if now > GAMEPAD_COOLDOWN then
            local delta = (leftY > 0) and -1 or 1
            local nextIdx = selectedIndex + delta
            if nextIdx >= 1 and nextIdx <= #filteredList then
                selectedIndex = nextIdx
                RefreshList()
                RefreshDetails()
                PlaySound(SOUNDS.GAMEPAD_MENU_UP)
            end
            GAMEPAD_COOLDOWN = now + 150 
        end
    else
        GAMEPAD_COOLDOWN = 0
    end
    
    -- Prawy drążek (przewijanie tekstu)
    local rightY = ZO_Gamepad_GetRightStickEasedY()
    if math.abs(rightY) > 0.05 then
        if detailsScroll then
            ZO_Scroll_ScrollRelative(detailsScroll, -rightY * 15)
        end
    end
end

local function EnsureGamepadScene()
    if sceneInitialized then return end
    
    LORE_LIBRARY_GAMEPAD_SCENE = ZO_Scene:New(GAMEPAD_SCENE_NAME, SCENE_MANAGER)
    
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
    LORE_LIBRARY_GAMEPAD_SCENE:AddFragment(lorePanelFragment)
    
    LORE_LIBRARY_GAMEPAD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(Library.keybindStripDesc)
            KEYBIND_STRIP:AddKeybindButtonGroup(Library.keybindStripDesc)
            libWindow:SetHandler("OnUpdate", OnUpdateHandler)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(Library.keybindStripDesc)
            libWindow:SetHandler("OnUpdate", nil)
        end
    end)
    sceneInitialized = true
end

function Library.Initialize()
    -- Rejestracja naprawionego dialogu dla trybu Gamepad
    ZO_Dialogs_RegisterCustomDialog("GAMEPAD_TEXT_ENTRY", {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.blockDialogReleaseOnPress = true
            
            if not dialog.data then dialog.data = {} end
            
            -- 1. POLE TEKSTOWE
            local textEntryData = {
                template = "ZO_GamepadTextFieldItem",
                templateData = {
                    textChangedCallback = function(control) 
                        local newText = control:GetText()
                        dialog.data.inputText = newText
                        dialog.data.defaultText = newText
                    end,
                    setup = function(control, data, selected, reselecting, enabled, active)
                        control.editBoxControl.textChangedCallback = data.textChangedCallback
                        control.editBoxControl:SetMaxInputChars(50)
                        control.editBoxControl:SetDefaultText(dialog.data.instructions or "Wpisz tekst...")
                        -- Przywracamy zapamiętany tekst
                        control.editBoxControl:SetText(dialog.data.defaultText or "")
                        dialog.data.inputText = dialog.data.defaultText or ""
                    end,
                    callback = function(dialog)
                        local targetControl = dialog.entryList:GetTargetControl()
                        if targetControl and targetControl.editBoxControl then
                            targetControl.editBoxControl:TakeFocus()
                        end
                    end,
                },
            }

            -- 2. PRZYCISK SZUKAJ
            local searchButtonData = {
                template = "ZO_GamepadMenuEntryTemplate",
                templateData = {
                    text = "SZUKAJ", 
                    setup = function(control, data, selected, reselecting, enabled, active)
                        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselecting, enabled, active)
                    end,
                    callback = function(dialog)
                        local finalText = dialog.data.defaultText or ""
                        if dialog.data.finishedCallback then
                            dialog.data.finishedCallback(finalText)
                        end
                        ZO_Dialogs_ReleaseDialogOnButtonPress(dialog.name)
                    end,
                },
            }

            -- Budujemy listę
            dialog.info.parametricList = {
                textEntryData,
                searchButtonData
            }
            
            dialog:setupFunc()
        end,
        
        title = {
            text = function(dialog) return dialog.data.headerTitle or "Szukaj" end,
        },
        
        buttons = {
            -- Przycisk A: Wykonuje akcję z listy
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION, 
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then
                        targetData.callback(dialog)
                    end
                end,
            },
            -- Przycisk B: Anuluj/Zamknij
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)
                    ZO_Dialogs_ReleaseDialogOnButtonPress(dialog.name)
                end,
            },
        }
    })

    CreateUI()
    BuildData()
    FilterData()
    EnsureGamepadScene()
    
    EVENT_MANAGER:RegisterForEvent("LoreLibraryCursorCheck", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() 
        ApplyLayout() 
    end)
    
    ApplyLayout() 
end

function Library.Toggle()
    if not libWindow then Library.Initialize() end
    local isGamepad = IsInGamepadPreferredMode()
    
    local isShowing = false
    if isGamepad then
        isShowing = SCENE_MANAGER:IsShowing(GAMEPAD_SCENE_NAME)
    else
        isShowing = not libWindow:IsHidden()
    end

    if isShowing then
        -- === ZAMYKANIE ===
        if isGamepad then
            SCENE_MANAGER:Hide(GAMEPAD_SCENE_NAME)
        else
            libWindow:SetHidden(true)
            SCENE_MANAGER:SetInUIMode(false)
        end
        
        -- RESET FILTRÓW
        currentSearch = ""
        if searchBox then searchBox:SetText("") end
        FilterData()
        RefreshList()
    else
        -- === OTWIERANIE ===
        BuildData()
        FilterData()
        ApplyLayout()
        
        if isGamepad then
            EnsureGamepadScene()
            SCENE_MANAGER:Show(GAMEPAD_SCENE_NAME)
        else
            libWindow:SetHidden(false)
            SCENE_MANAGER:SetInUIMode(true)
        end
    end
end

SLASH_COMMANDS["/lorelib"] = function() Library.Toggle() end

-- ============================================
-- AUTO-INIT na starcie gry
-- ============================================
local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        Library.Initialize()
        EVENT_MANAGER:UnregisterForEvent("LoreLibraryAutoInit", EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent("LoreLibraryAutoInit", EVENT_ADD_ON_LOADED, OnAddOnLoaded)