-- ============================================
-- Lore Tooltips - Główny plik addonu v1.0.1
-- ============================================
LoreTooltips = LoreTooltips or {}
LoreTooltips.UI = nil 

d("|cFF0000[LORE]|r LoreTooltips.lua wczytany (Core).")

local ADDON_NAME = "LoreTooltips"
local ADDON_VERSION = "1.0.1"

local L = {}

-- Zmienne lokalne podstawowe
LoreTooltips.currentNPCName = ""
local alreadyShownTexts = {}
LoreTooltips.currentMatches = {}
LoreTooltips.lorePanelVisible = false
LoreTooltips.currentEntryIndex = 1

-- Domyślne wartości
local DEFAULTS = {
    autoAliases = {},
    -- Pozycje dla PC
    panelPosX = nil,
    panelPosY = nil,
    -- Pozycje dla Gamepada (NOWE - aby nie kolidowały z PC)
    gamepadPanelPosX = nil,
    gamepadPanelPosY = nil,
    
    linkPopupPosX = nil,
    linkPopupPosY = nil,
    libIconPosX = 0,
    libIconPosY = 221,
    forcePolish = false,
    debugMode = true,
    highlightColor = "00BFFF",
    highlightColorBook = "0033CC",
    highlightColorJournal = "00BFFF"
}

local HIGHLIGHT_COLOR_END = "|r"

-- ============================================
-- SYSTEM WYSZUKIWANIA
-- ============================================
local searchPatterns = {}
local multiWordDict = {}

local function IsWordByte(byte)
    if not byte then return false end
    if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then return true end
    if byte >= 48 and byte <= 57 then return true end
    if byte >= 128 then return true end
    return false
end

local function IsWordBoundary(text, pos, atStart)
    if atStart then
        if pos <= 1 then return true end
        local byteBefore = string.byte(text, pos - 1)
        return not IsWordByte(byteBefore)
    else
        if pos >= #text then return true end
        local byteAfter = string.byte(text, pos + 1)
        return not IsWordByte(byteAfter)
    end
end

local function BuildSearchPatterns()
    searchPatterns = {}
    multiWordDict = {}
    local tempMultiWords = {}
    
    -- 1. Przetwarzanie ręcznych aliasów z LoreAliases.lua
    if LoreTooltips.Aliases then
        for alias, value in pairs(LoreTooltips.Aliases) do
            local wikiKey
            local exclusions = {}
            
            if type(value) == "table" then
                wikiKey = value.key or value.wikiKey
                exclusions = value.excluded or {}
            else
                wikiKey = value
            end
            
            local aliasLower = alias:lower()
            
            for _, excl in ipairs(exclusions) do
                local exclLower = excl:lower()
                table.insert(tempMultiWords, { 
                    pattern = exclLower, 
                    wikiKey = nil, 
                    length = #exclLower,
                    isExclusion = true 
                })
            end
            
            if aliasLower:find(" ") or aliasLower:find("-") then
                table.insert(tempMultiWords, { pattern = aliasLower, wikiKey = wikiKey, length = #aliasLower })
            else
                searchPatterns[aliasLower] = wikiKey
            end
        end
    end

    -- 2. Przetwarzanie automatyczne z bazy danych
    if LoreTooltips.Database then
        for wikiKey, _ in pairs(LoreTooltips.Database) do
            local searchForm = wikiKey:gsub("_", " "):lower()
            if searchForm:find(" ") or searchForm:find("-") then
                local exists = false
                for _, mp in ipairs(tempMultiWords) do
                    if mp.pattern == searchForm and not mp.isExclusion then exists = true; break end
                end
                if not exists then
                    table.insert(tempMultiWords, { pattern = searchForm, wikiKey = wikiKey, length = #searchForm })
                end
            else
                if not searchPatterns[searchForm] then searchPatterns[searchForm] = wikiKey end
            end
        end
    end
    
    -- Sortowanie od najdłuższego do najkrótszego
    table.sort(tempMultiWords, function(a, b) return a.length > b.length end)
    
    -- Optymalizacja: Grupowanie wyrażeń wieloczłonowych wg pierwszego słowa
    for _, mp in ipairs(tempMultiWords) do
        local firstWord = ""
        for i = 1, #mp.pattern do
            local byte = string.byte(mp.pattern, i)
            if IsWordByte(byte) then
                firstWord = firstWord .. string.char(byte)
            else
                if #firstWord > 0 then break end
            end
        end
        
        if firstWord ~= "" then
            if not multiWordDict[firstWord] then multiWordDict[firstWord] = {} end
            table.insert(multiWordDict[firstWord], mp)
        end
    end
end

-- ZOPTYMALIZOWANA FUNKCJA: Jeden Przebieg (Single Pass)
function LoreTooltips.FindAllLoreMatches(text)
    if not text or text == "" then return {} end
    local results = {}
    local textLower = text:lower()
    local textLen = #textLower
    local usedRanges = {}
    
    local function isRangeUsed(startPos, endPos)
        for _, range in ipairs(usedRanges) do
            if not (endPos < range.startPos or startPos > range.endPos) then return true end
        end
        return false
    end
    
    local wordStart = 1
    while wordStart <= textLen do
        -- Szukaj początku słowa z użyciem błyskawicznego odczytu byte'a
        while wordStart <= textLen do
            local byte = string.byte(textLower, wordStart)
            if IsWordByte(byte) then break end
            wordStart = wordStart + 1
        end
        if wordStart > textLen then break end
        
        -- Szukaj końca słowa
        local wordEnd = wordStart
        while wordEnd <= textLen do
            local byte = string.byte(textLower, wordEnd)
            if not IsWordByte(byte) then break end
            wordEnd = wordEnd + 1
        end
        wordEnd = wordEnd - 1
        
        if not isRangeUsed(wordStart, wordEnd) then
            local word = textLower:sub(wordStart, wordEnd)
            local matchFound = false
            local jumpEnd = wordEnd
            
            -- Wpierw sprawdzamy, czy to słowo nie jest początkiem długiego wyrażenia z bazy (np. "Gamyne Bandu")
            local mwList = multiWordDict[word]
            if mwList then
                for _, mp in ipairs(mwList) do
                    local mwEnd = wordStart + mp.length - 1
                    if mwEnd <= textLen then
                        if textLower:sub(wordStart, mwEnd) == mp.pattern then
                            if IsWordBoundary(textLower, mwEnd, false) and not isRangeUsed(wordStart, mwEnd) then
                                if mp.isExclusion then
                                    table.insert(usedRanges, {startPos = wordStart, endPos = mwEnd})
                                    matchFound = true
                                    jumpEnd = mwEnd
                                    break
                                else
                                    local loreEntry = LoreTooltips.Database[mp.wikiKey]
                                    if loreEntry then
                                        table.insert(results, {
                                            startPos = wordStart, endPos = mwEnd, keyword = mp.wikiKey, loreEntry = loreEntry, originalWord = text:sub(wordStart, mwEnd)
                                        })
                                        table.insert(usedRanges, {startPos = wordStart, endPos = mwEnd})
                                        matchFound = true
                                        jumpEnd = mwEnd
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Jeśli to nie było długie wyrażenie (lub nie było w bazie), to testujemy pojedyncze słowo
            if not matchFound then
                local wikiKey = searchPatterns[word]
                if wikiKey then
                    local loreEntry = LoreTooltips.Database[wikiKey]
                    if loreEntry then
                        table.insert(results, {
                            startPos = wordStart, endPos = wordEnd, keyword = wikiKey, loreEntry = loreEntry, originalWord = text:sub(wordStart, wordEnd)
                        })
                        table.insert(usedRanges, {startPos = wordStart, endPos = wordEnd})
                    end
                end
            end
            
            -- Skaczemy za znaleziony element, by nie iterować podwójnie
            wordStart = jumpEnd + 1
        else
            wordStart = wordEnd + 1
        end
    end
    
    table.sort(results, function(a, b) return a.startPos < b.startPos end)
    return results
end

-- POPRAWIONE: Dodano argument ignoreKeyword, aby nie podświetlać obecnego tematu
-- Funkcja udostępniona globalnie dla modułów UI
function LoreTooltips.HighlightKeywordsInText(originalText, customColorHex, referenceMap, ignoreKeyword)
    if not originalText or originalText == "" then return originalText, {} end
    local matches = LoreTooltips.FindAllLoreMatches(originalText)
    if #matches == 0 then return originalText, matches end
    table.sort(matches, function(a, b) return a.startPos > b.startPos end)
    local highlightedText = originalText
    
    local colorHex = customColorHex or (LoreTooltips.savedVars and LoreTooltips.savedVars.highlightColor) or "00BFFF"
    local colorCode = "|c" .. colorHex
    
    for _, match in ipairs(matches) do
        -- Sprawdzamy, czy to nie jest ten sam wyraz, o którym czytamy
        if match.keyword ~= ignoreKeyword then
            local before = highlightedText:sub(1, match.startPos - 1)
            local word = highlightedText:sub(match.startPos, match.endPos)
            local after = highlightedText:sub(match.endPos + 1)
            
            -- Dodawanie numerka [1] jeśli jest w mapie referencji
            local suffix = ""
            if referenceMap and referenceMap[match.keyword] then
                 suffix = " |cFFFF00[" .. referenceMap[match.keyword] .. "]|r"
            end
            
            highlightedText = before .. colorCode .. word .. HIGHLIGHT_COLOR_END .. suffix .. after
        end
    end
    table.sort(matches, function(a, b) return a.startPos < b.startPos end)
    return highlightedText, matches
end

local function CountUniqueMatches(matchesTable)
    local unique = 0
    local seen = {}
    if matchesTable then
        for _, m in ipairs(matchesTable) do
            if not seen[m.keyword] then seen[m.keyword] = true; unique = unique + 1 end
        end
    end
    return unique
end

-- ============================================
-- INTEGRACJA Z MENU I INNE
-- ============================================

local function ProcessLabelControl(labelControl, customColorHex)
    -- ZMIANA: Zwracamy nil zamiast 0, aby pętla ipairs się nie uruchamiała
    if not labelControl then return nil end 
    
    local text = labelControl:GetText()
    -- ZMIANA: Tutaj również nil zamiast 0
    if not text or text == "" then return nil end 
    
    local cleanText = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    local highlightedText, matches = LoreTooltips.HighlightKeywordsInText(cleanText, customColorHex)
    
    if #matches > 0 then
        labelControl:SetText(highlightedText)
        return matches
    end
    
    return nil
end

local function ProcessDialogText(source)
    local isGamepad = IsInGamepadPreferredMode()
    local dialogControl = isGamepad and ZO_InteractWindow_GamepadContainerText or ZO_InteractWindowTargetAreaBodyText
    local titleControl = isGamepad and ZO_InteractWindow_GamepadTitle or ZO_InteractWindowTargetAreaTitle

    if not dialogControl then return end
    
    local text = dialogControl:GetText()
    local titleText = (titleControl and titleControl:GetText()) or (LoreTooltips.currentNPCName or "") 

    if (not text or text == "") and (not titleText or titleText == "") then return end
    
    local textHash = (text or ""):sub(1, 50) .. (titleText or ""):sub(1, 20)
    if alreadyShownTexts[textHash] then return end
    alreadyShownTexts[textHash] = true
    
    local bodyHighlighted, bodyMatches = text, {}
    if text and text ~= "" then
        local cleanText = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
        bodyHighlighted, bodyMatches = LoreTooltips.HighlightKeywordsInText(cleanText)
    end
    
    local titleHighlighted, titleMatches = titleText, {}
    if titleText and titleText ~= "" and titleText ~= L.UNKNOWN_SOURCE then
        local cleanTitle = titleText:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
        titleHighlighted, titleMatches = LoreTooltips.HighlightKeywordsInText(cleanTitle)
    end

    LoreTooltips.currentMatches = {}
    if titleMatches then for _, m in ipairs(titleMatches) do table.insert(LoreTooltips.currentMatches, m) end end
    if bodyMatches then for _, m in ipairs(bodyMatches) do table.insert(LoreTooltips.currentMatches, m) end end
    
    if #bodyMatches > 0 then
        dialogControl:SetText(bodyHighlighted)
    end
    
    if titleControl and #titleMatches > 0 then
        titleControl:SetText(titleHighlighted)
    end
    
    -- Delegujemy aktualizację przycisku do modułu UI
    if LoreTooltips.UI and LoreTooltips.UI.UpdateInteractions then
        LoreTooltips.UI:UpdateInteractions(CountUniqueMatches(LoreTooltips.currentMatches))
    end
end

local function UpdateJournalLore()
    LoreTooltips.currentMatches = {}
    local journalColor = (LoreTooltips.savedVars and LoreTooltips.savedVars.highlightColorJournal) or "00BFFF"
    local matches1, matches2
    if IsInGamepadPreferredMode() then
        if not QUEST_JOURNAL_GAMEPAD then return end
        matches1 = ProcessLabelControl(QUEST_JOURNAL_GAMEPAD.bgText, journalColor)
        matches2 = ProcessLabelControl(QUEST_JOURNAL_GAMEPAD.stepText, journalColor)
    else
        -- Wywołujemy funkcję tworzącą przycisk w module UI, jeśli nie istnieje, ale logika jest w module
        if not QUEST_JOURNAL_KEYBOARD then return end
        matches1 = ProcessLabelControl(QUEST_JOURNAL_KEYBOARD.bgText, journalColor)
        matches2 = ProcessLabelControl(QUEST_JOURNAL_KEYBOARD.stepText, journalColor)
    end
    if matches1 then for _, m in ipairs(matches1) do table.insert(LoreTooltips.currentMatches, m) end end
    if matches2 then for _, m in ipairs(matches2) do table.insert(LoreTooltips.currentMatches, m) end end
    
    if LoreTooltips.UI and LoreTooltips.UI.UpdateJournalInteractions then
        LoreTooltips.UI:UpdateJournalInteractions(CountUniqueMatches(LoreTooltips.currentMatches))
    end
end

local function UpdateBookLore()
    if not LORE_READER then return end
    local fullText = LORE_READER.bodyText
    if not fullText or fullText == "" then 
        LoreTooltips.currentMatches = {}
        if LoreTooltips.UI and LoreTooltips.UI.UpdateBookInteractions then
            LoreTooltips.UI:UpdateBookInteractions(0)
        end
        return 
    end
    local cleanText = fullText:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    
    local bookColor = (LoreTooltips.savedVars and LoreTooltips.savedVars.highlightColorBook) or "0033CC"
    local highlightedText, matches = LoreTooltips.HighlightKeywordsInText(cleanText, bookColor)
    
    LoreTooltips.currentMatches = matches
    local uniqueCount = CountUniqueMatches(matches)
    if uniqueCount > 0 then
        if LORE_READER.firstPage and LORE_READER.firstPage.body then
            LORE_READER.firstPage.body:SetText(highlightedText)
        end
        if LORE_READER.secondPage and LORE_READER.secondPage.body then
            LORE_READER.secondPage.body:SetText(highlightedText)
        end
    end
    
    if LoreTooltips.UI and LoreTooltips.UI.UpdateBookInteractions then
        LoreTooltips.UI:UpdateBookInteractions(uniqueCount)
    end
end

local function ProcessCurrentDialogText(source)
    alreadyShownTexts = {}
    ProcessDialogText(source)
end

local function UpdateLoreButton() 
    -- Logika przycisku jest teraz w ProcessDialogText i UI module
end

local function OnConversationUpdated(event, body, optionCount)
    LoreTooltips.currentMatches = {}
    zo_callLater(function() ProcessCurrentDialogText("ConversationUpdated") end, 100)
end
local function OnChatterBegin(event)
    LoreTooltips.currentMatches = {}
    LoreTooltips.currentNPCName = zo_strformat(SI_UNIT_NAME, GetRawUnitName("interact")) or L.UNKNOWN_SOURCE
    zo_callLater(function() ProcessCurrentDialogText("ChatterBegin") end, 150)
end
local function OnChatterEnd(event)
    LoreTooltips.currentNPCName = ""
    LoreTooltips.currentMatches = {}
    
    if LoreTooltips.UI and LoreTooltips.UI.HideLorePanel then
        LoreTooltips.UI:HideLorePanel()
    end
    if LoreTooltips.UI and LoreTooltips.UI.UpdateInteractions then
        LoreTooltips.UI:UpdateInteractions(0)
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Inicjalizacja Zmiennych Zapisanych
    LoreTooltips.savedVars = ZO_SavedVars:NewAccountWide("LoreTooltipsSavedVars", 1, nil, DEFAULTS, GetWorldName())
    
    local loadedLangData = nil
    
    if LoreTooltips.Localization then
        -- Sprawdzamy po kolei najpopularniejsze (w tym to co załadowała gra)
        local clientLang = GetCVar("language.2")
        
        if LoreTooltips.Localization[clientLang] then
            loadedLangData = LoreTooltips.Localization[clientLang]
        elseif LoreTooltips.Localization["pl"] then
            loadedLangData = LoreTooltips.Localization["pl"]
        elseif LoreTooltips.Localization["en"] then
            loadedLangData = LoreTooltips.Localization["en"]
        end
    end

    if loadedLangData then
        L = loadedLangData
    else
        -- Fallback absolutny (gdyby żaden plik się nie wczytał - np. błąd manifestu)
        L = {
            BACK_BUTTON = "Back", SHOW_REFS_BUTTON = "Refs", 
            SELECT_TOPIC_DROPDOWN = "Select topic", CLOSE_BUTTON = "Close",
            COPY_LINK_BUTTON = "Link", COPY_LINK_POPUP_TITLE = "Copy",
            POPUP_CLOSE = "Close", SOURCE_LABEL = "Source",
            UNKNOWN_SOURCE = "Unknown", LORE_BUTTON_TEXT = "LORE",
            LIBRARY_MENU_ENTRY = "Lore Library", GAMEPAD_DIALOG_TITLE = "Refs",
            KEYBIND_NEXT_TOPIC = "Next", KEYBIND_PREV_OPTION = "Prev",
            KEYBIND_NEXT_OPTION = "Next", KEYBIND_SELECT = "Select",
            KEYBIND_SHOW_LORE = "Show", DIALOG_SELECT_OPTION = "Select",
            DIALOG_CANCEL = "Cancel",
            -- Default DB messages
            DB_CRITICAL_ERROR = "ERROR", DB_CONFLICT_HEADER = "Conflict",
            DB_CONFLICT_DESC = "Conflict <<1>>", DB_CONFLICT_ACTION = "Disable one lib",
            DB_WARNING_HEADER = "WARNING", DB_MISSING_HEADER = "Missing DB",
            DB_MISSING_DESC = "Install LibLoreLibrary",
            DB_SUCCESS_LOADED = "Loaded <<1>> (<<2>>)"
        }
    end
    LoreTooltips.L = L 

    -- Nowa inicjalizacja baz danych
    if LoreTooltips.InitializeDatabases then LoreTooltips.InitializeDatabases() end
    
    -- Sprawdzamy czy mamy dane przed budowaniem wzorców
    local entryCount = 0
    if LoreTooltips.Database then
        for _ in pairs(LoreTooltips.Database) do entryCount = entryCount + 1 end
    end

    if entryCount > 0 then
        -- WYŁĄCZONE DLA GRACZY (Dev tool):
        -- if LoreTooltips.BuildAutoAliases then LoreTooltips.BuildAutoAliases() end 
        
        BuildSearchPatterns()
    else
    end
    
    if LoreTooltips.Library and LoreTooltips.Library.Initialize then LoreTooltips.Library.Initialize() end
    if LoreTooltips.BuildMenu then LoreTooltips.BuildMenu() end

    -- === SEPARACJA MODUŁÓW UI ZGODNIE Z POLECENIEM ===
    if IsInGamepadPreferredMode() then
        if LoreTooltips.Gamepad and LoreTooltips.Gamepad.Initialize then
            LoreTooltips.Gamepad:Initialize(L)
            LoreTooltips.UI = LoreTooltips.Gamepad
        end
    else
        if LoreTooltips.Keyboard and LoreTooltips.Keyboard.Initialize then
            LoreTooltips.Keyboard:Initialize(L)
            LoreTooltips.UI = LoreTooltips.Keyboard
        end
    end
    -- =================================================

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, function(e) OnChatterBegin(e); zo_callLater(UpdateLoreButton, 150) end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, function(e) OnChatterEnd(e) end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CONVERSATION_UPDATED, function(e, b, o) OnConversationUpdated(e, b, o); zo_callLater(UpdateLoreButton, 100) end)
    
    if QUEST_JOURNAL_KEYBOARD then
        SecurePostHook(QUEST_JOURNAL_KEYBOARD, "RefreshDetails", function() zo_callLater(UpdateJournalLore, 50) end)
    end
    if QUEST_JOURNAL_GAMEPAD then
        SecurePostHook(QUEST_JOURNAL_GAMEPAD, "RefreshDetails", function() zo_callLater(UpdateJournalLore, 50) end)
    end
    if LORE_READER then
        SecurePostHook(LORE_READER, "LayoutText", function() zo_callLater(UpdateBookLore, 100) end)
    end
    
    local journalScenes = {"questJournal", "gamepad_quest_journal"}
    for _, sceneName in ipairs(journalScenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_SHOWING then
                    zo_callLater(UpdateJournalLore, 100)
                elseif newState == SCENE_HIDDEN then
                    if LoreTooltips.UI and LoreTooltips.UI.UpdateJournalInteractions then
                        LoreTooltips.UI:UpdateJournalInteractions(0)
                    end
                    if LoreTooltips.UI and LoreTooltips.UI.HideLorePanel then
                        LoreTooltips.UI:HideLorePanel()
                    end
                end
            end)
        end
    end
    
    local readerScenes = {
        "loreReaderDefault", "loreReaderInventory", "loreReaderLoreLibrary",
        "gamepad_loreReaderDefault", "gamepad_loreReaderInventory", "gamepad_loreReaderLoreLibrary"
    }
    for _, sceneName in ipairs(readerScenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_HIDDEN then
                    if LoreTooltips.UI and LoreTooltips.UI.UpdateBookInteractions then
                        LoreTooltips.UI:UpdateBookInteractions(0)
                    end
                    if LoreTooltips.UI and LoreTooltips.UI.HideLorePanel then
                        LoreTooltips.UI:HideLorePanel()
                    end
                end
            end)
        end
    end
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_HIDE_BOOK, function()
        if LoreTooltips.UI and LoreTooltips.UI.HideLorePanel then
            LoreTooltips.UI:HideLorePanel()
        end
    end)
    
    SLASH_COMMANDS["/lore"] = function(extra) 
        -- 1. Obsługa komendy /lore stats
        if extra == "stats" then
            local count = 0
            if LoreTooltips.Database then
                for _ in pairs(LoreTooltips.Database) do count = count + 1 end
            end
            d("|cFFD700[Lore Tooltips]|r Załadowanych wpisów: " .. count)
            
        -- 2. Obsługa komendy /lore check (Twoja diagnostyka)
        elseif extra == "check" then
            if LoreTooltips.BuildAutoAliases then
                LoreTooltips.BuildAutoAliases()
            else
                d("|cFF0000[Lore Tooltips]|r Błąd: Funkcja BuildAutoAliases nie jest dostępna.")
            end

        -- 3. Obsługa samego /lore (bez argumentów)
        else
            -- Wyświetlamy info na czacie
            d("Lore Tooltips v" .. tostring(ADDON_VERSION or "?"))
            d("Komendy:")
            d("  /lore stats - statystyki")
            d("  /lore check - (DEV) naprawa aliasów")
            
            -- BEZPIECZNE OTWIERANIE MENU:
            if LibHarvensAddonSettings and type(LibHarvensAddonSettings.OpenToPanel) == "function" then
                LibHarvensAddonSettings:OpenToPanel("Lore Tooltips")
            end
        end
    end -- Koniec funkcji anonimowej dla SLASH_COMMANDS
end -- Koniec funkcji OnAddonLoaded

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

    -- Opóźnienie 2 sekundy (2000ms), aby upewnić się, że gracz widzi czat
    zo_callLater(function()
        -- Wywołujemy funkcję drukującą status (zdefiniowaną w LoreDatabaseManager.lua)
        if LoreTooltips.PrintLoadStatus then
            LoreTooltips.PrintLoadStatus()
        end
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)