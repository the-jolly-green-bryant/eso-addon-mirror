-- ZoneSets.lua (Полная финальная версия: Сетка, Тосты, Сессии, Группа, Конвейер и Авто-Трейд)
local ADDON_NAME = "ZoneSets"
local ZS = {}
ZS.Cache = {}
ZS.KnownPieces = {}
ZS.CurrentTab = "zone"
ZS.ChatQueue = nil
ZS.TradeRequests = {} -- Кратковременная память запросов на обмен (15 мин)

-- ================= ЛОКАЛИЗАЦИЯ (СЛОВАРЬ) =================
local lang = GetCVar("language.2")
local L = {}

if lang == "ru" then
    L.title = "|c39DB92Zone Sets|r"
    L.unknownZone = "Неизвестная локация"
    L.noSetsFound = "В этой локации нет сетов стикербука"
    L.tabZone = "Зона"
    L.tabHistory = "История"
    L.historyTitle = "История привязок"
    L.currentSession = "|c00FF00[Текущий заход]|r"
    L.previousSession = "|cAAAAAA[Прошлый заход]|r"
    L.noCurrentItems = "В этом заходе пока нет новых привязок"
    L.noPreviousItems = "Нет данных о прошлом заходе"
    L.groupLootHeader = "|c39DB92[Лут группы — нужно мне]|r"
    L.noGroupLoot = "В этом рейде сопартийцы пока не выбивали нужных вам вещей"
    L.askAllBtn = "Попросить всё"
    L.askSingleBtn = "Спросить"
    L.itemsNeededCount = "нужно %d шт."
    L.justNow = "Только что"
    L.minutesAgo = "%d мин. назад"
    L.hoursAgo = "%d ч. назад"
    L.testTitle = "|c39DB92[ZS-Test] Перетащи меня!|r"
    L.dragMe = "Зажми левую кнопку мыши для переноса"
    L.addedToColl = "|c00FF00Добавлено в коллекцию!|r"
    L.chatBtnTooltip = "Сформировать запрос сета в чат группы"
    L.setCompletedMsg = "Сет уже собран на 100%, просить нечего!"
    L.bindingToggle = "Открыть/закрыть ZoneSets"
    L.toastProgressFormat = "%s — Прогресс: |cFFFF00%d / %d|r"
    L.testShown = "|c39DB92[ZoneSets]|r Тестовое окно открыто. Перетащи его мышкой. Напиши |cFFFF00/zs test|r снова, чтобы скрыть и сохранить позицию."
    L.testSaved = "|c39DB92[ZoneSets]|r Позиция сохранена, тест скрыт."
    L.toastDisabled = "|c39DB92[ZoneSets]|r Всплывающие уведомления |cFF0000ОТКЛЮЧЕНЫ|r."
    L.toastEnabled = "|c39DB92[ZoneSets]|r Всплывающие уведомления |c00FF00ВКЛЮЧЕНЫ|r."
    L.toastDurationSet = "|c39DB92[ZoneSets]|r Уведомления включены, длительность: |cFFFF00%d|r сек."
    L.toastStatus = "|c39DB92[ZoneSets]|r Уведомления: %s (Длительность: |cFFFF00%d|r сек.).\nОтключить: |cFFFF00/zs toast off|r. Изменить время: |cFFFF00/zs toast <секунды>|r"
    L.shareExtraBtn = "Раздать лишний лут (%d)"
    L.shareExtraBtn = "Раздать лишний лут в чат"
    L.noTradableDupes = "|c39DB92[ZoneSets]|r В рюкзаке нет лишних сетовых вещей для раздачи."
    L.shareBtnTooltip = "Сформировать сообщение с вашими лишними сетовыми вещами в чат"
    L.tradeHelperTitle = "|c39DB92[ZoneSets Помощник обмена]|r"
    L.tradePutRequested = "Запрошенное (%d)"
    L.tradeDumpExtra = "Лишний лут (%d)"
    L.tradeNoItems = "Нет подходящих вещей для обмена"
    L.tradeFilledMsg = "|c39DB92[ZoneSets]|r Добавлено в обмен: %d предметов"
else
    L.title = "|c39DB92Zone Sets|r"
    L.unknownZone = "Unknown Zone"
    L.noSetsFound = "No item sets found for this zone"
    L.tabZone = "Zone"
    L.tabHistory = "History"
    L.historyTitle = "Bound History"
    L.currentSession = "|c00FF00[Current Run]|r"
    L.previousSession = "|cAAAAAA[Previous Run]|r"
    L.noCurrentItems = "No new items bound in this run yet"
    L.noPreviousItems = "No previous run data"
    L.groupLootHeader = "|c39DB92[Group Loot — Needed by Me]|r"
    L.noGroupLoot = "No needed items looted by teammates in this run yet"
    L.askAllBtn = "Ask All"
    L.askSingleBtn = "Ask"
    L.itemsNeededCount = "needed: %d"
    L.justNow = "Just now"
    L.minutesAgo = "%d m ago"
    L.hoursAgo = "%d h ago"
    L.testTitle = "|c39DB92[ZS-Test] Drag Me!|r"
    L.dragMe = "Hold Left Mouse Button to drag"
    L.addedToColl = "|c00FF00Added to Collection!|r"
    L.chatBtnTooltip = "Generate group chat request"
    L.setCompletedMsg = "Set is already 100% collected, nothing to ask for!"
    L.bindingToggle = "Toggle ZoneSets Window"
    L.toastProgressFormat = "%s — Progress: |cFFFF00%d / %d|r"
    L.testShown = "|c39DB92[ZoneSets]|r Test window is shown. Left-click and drag it anywhere. Type |cFFFF00/zs test|r again to hide and save position."
    L.testSaved = "|c39DB92[ZoneSets]|r Position saved, test window hidden."
    L.toastDisabled = "|c39DB92[ZoneSets]|r Screen notifications are now |cFF0000DISABLED|r."
    L.toastEnabled = "|c39DB92[ZoneSets]|r Screen notifications are now |c00FF00ENABLED|r."
    L.toastDurationSet = "|c39DB92[ZoneSets]|r Screen notifications enabled, duration set to |cFFFF00%d|r sec."
    L.toastStatus = "|c39DB92[ZoneSets]|r Screen notifications are currently: %s (Duration: |cFFFF00%d|r sec.).\nTo disable: |cFFFF00/zs toast off|r. To change duration: |cFFFF00/zs toast <seconds>|r"
    L.shareExtraBtn = "Share Extra Loot (%d)"
    L.shareExtraBtn = "Share Extra Loot to Chat"
    L.noTradableDupes = "|c39DB92[ZoneSets]|r No extra tradable set items in backpack to share."
    L.shareBtnTooltip = "Post all your extra tradable set items to chat"
    L.tradeHelperTitle = "|c39DB92[ZoneSets Trade Helper]|r"
    L.tradePutRequested = "Requested (%d)"
    L.tradeDumpExtra = "Extra Loot (%d)"
    L.tradeNoItems = "No matching items for trade"
    L.tradeFilledMsg = "|c39DB92[ZoneSets]|r Added to trade: %d items"
end

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ZONESETS_WINDOW", L.bindingToggle)

local createdRows = {}

-- Определение текущей локации
function ZS:GetCurrentZoneInfo()
    local zoneId = GetUnitWorldPosition("player") or 0
    local rawZoneName = (zoneId > 0 and GetZoneNameById(zoneId)) or GetUnitZone("player") or L.unknownZone
    local cleanZoneName = zo_strformat("<<1>>", rawZoneName)
    return zoneId, cleanZoneName
end

-- Очистка названий от римских цифр (I, II)
local function CleanZoneString(str)
    if not str then return "" end
    local clean = zo_strformat("<<1>>", str)
    clean = string.lower(clean)
    clean = string.gsub(clean, "%s+[ivx]+$", "")
    clean = string.gsub(clean, "%s+%d+$", "")
    clean = string.match(clean, "^%s*(.-)%s*$") or clean
    return clean
end

-- Переход в стикербук через авто-поиск по названию
function ZS:ShowItemSetInJournal(itemSetDataOrName)
    if not itemSetDataOrName then return end

    local setName = ""
    if type(itemSetDataOrName) == "string" then
        setName = zo_strformat("<<1>>", itemSetDataOrName)
    elseif type(itemSetDataOrName) == "table" and itemSetDataOrName.GetFormattedName then
        setName = zo_strformat("<<1>>", itemSetDataOrName:GetFormattedName())
    end

    if setName == "" then return end

    if MAIN_MENU_KEYBOARD and MAIN_MENU_KEYBOARD.ShowSceneGroup then
        MAIN_MENU_KEYBOARD:ShowSceneGroup("collectionsSceneGroup", "itemSetsBook")
    else
        SCENE_MANAGER:Show("itemSetsBook")
    end

    zo_callLater(function()
        local book = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD
        if not book then return end

        local searchEdit = (book.searchBox and book.searchBox.editBox) 
            or book.searchEditBox 
            or (book.control and book.control:GetNamedChild("SearchBox"))
            or _G["ZO_ItemSetsBook_Keyboard_TopLevelSearchBox"]
            or _G["ZO_ItemSetsBook_Keyboard_TopLevelSearchBoxEdit"]

        if searchEdit and searchEdit.SetText then
            searchEdit:SetText(setName)
        elseif book.SetSearchString then
            book:SetSearchString(setName)
        end
    end, 100)
end

-- Формирование умного интернационального запроса сета в чат группы
function ZS:RequestSetInChat(setInfo)
    if not setInfo or not setInfo.itemSetData then return end

    local missingWeaponsJewelry = {}
    local missingArmor = {}

    if setInfo.itemSetData.PieceIterator then
        for _, pieceData in setInfo.itemSetData:PieceIterator() do
            if pieceData and type(pieceData) == "table" then
                local isUnlocked = pieceData:IsUnlocked()
                if not isUnlocked then
                    local itemLink = pieceData:GetItemLink() or (GetItemSetCollectionPieceItemLink and GetItemSetCollectionPieceItemLink(pieceData:GetId(), LINK_STYLE_BRACKETS))
                    if itemLink and itemLink ~= "" then
                        local equipType = GetItemLinkEquipType(itemLink)
                        local isWepOrJewel = (equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK 
                            or equipType == EQUIP_TYPE_MAIN_HAND or equipType == EQUIP_TYPE_ONE_HAND 
                            or equipType == EQUIP_TYPE_TWO_HAND or equipType == EQUIP_TYPE_OFF_HAND)

                        if isWepOrJewel then
                            table.insert(missingWeaponsJewelry, itemLink)
                        else
                            table.insert(missingArmor, itemLink)
                        end
                    end
                end
            end
        end
    end

    local totalMissingWepJewel = #missingWeaponsJewelry
    local totalMissingArmor = #missingArmor

    if totalMissingWepJewel == 0 and totalMissingArmor == 0 then
        d("|c39DB92[ZoneSets]|r |c00FF00" .. tostring(setInfo.name) .. "|r: " .. (L.setCompletedMsg or "Сет уже собран на 100%!"))
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local message = ""

    if totalMissingWepJewel >= 5 then
        local sampleLink = missingWeaponsJewelry[1] or ""
        if sampleLink ~= "" then
            message = string.format("LF any weapons / jewelry of %s set, please! :)", sampleLink)
        else
            message = string.format("LF any weapons / jewelry of %s set, please! :)", setInfo.name)
        end
    elseif totalMissingWepJewel > 0 then
        local linksStr = table.concat(missingWeaponsJewelry, " ")
        message = string.format("LF: %s if you don't need, please! :)", linksStr)
    elseif totalMissingArmor > 0 and totalMissingArmor <= 4 then
        local linksStr = table.concat(missingArmor, " ")
        message = string.format("LF: %s if you don't need, please! :)", linksStr)
    elseif totalMissingArmor >= 5 then
        local sampleArmorLink = missingArmor[1] or ""
        if sampleArmorLink ~= "" then
            message = string.format("LF any body pieces of %s set, please! :)", sampleArmorLink)
        else
            message = string.format("LF any body pieces of %s set, please! :)", setInfo.name)
        end
    end

    if message ~= "" then
        if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
            CHAT_SYSTEM.textEntry:Open()
            if CHAT_SYSTEM.textEntry.editControl then
                CHAT_SYSTEM.textEntry.editControl:SetText(message)
                CHAT_SYSTEM.textEntry.editControl:SetCursorPosition(string.len(message))
            end
        end
    end
end

-- ================= УМНЫЙ КОНВЕЙЕР ШЕПОТОВ И РАЗДАЧИ ЛУТА =================

-- Поиск всех передаваемых дубликатов сетов в рюкзаке
function ZS:GetTradableDuplicatesInBag()
    local items = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local isTradable = (not IsItemBound(BAG_BACKPACK, slotIndex)) or (IsItemBoPAndTradeable and IsItemBoPAndTradeable(BAG_BACKPACK, slotIndex))
            if isTradable then
                local hasSet = GetItemLinkSetInfo(itemLink)
                local pieceId = GetItemLinkItemId(itemLink)

                if hasSet and pieceId and pieceId > 0 and IsItemSetCollectionPieceUnlocked(pieceId) then
                    table.insert(items, itemLink)
                end
            end
        end
    end

    return items
end

function ZS:LoadNextChatChunk()
    if not self.ChatQueue or not self.ChatQueue.chunks then return end
    local chunk = self.ChatQueue.chunks[self.ChatQueue.currentIdx]
    if not chunk then
        self.ChatQueue = nil
        return
    end

    local totalChunks = #self.ChatQueue.chunks
    local currentIdx = self.ChatQueue.currentIdx
    local linksStr = table.concat(chunk, " ")
    local mode = self.ChatQueue.mode or "whisper"
    local target = self.ChatQueue.target

    local message = ""

    -- 1. Режим индивидуального шепота
    if mode == "whisper" then
        if totalChunks == 1 then
            message = string.format("Hi! If you don't need %s, could you share please? :)", linksStr)
        else
            message = string.format("(%d/%d) Hi! If you don't need %s, please share! :)", currentIdx, totalChunks, linksStr)
        end

        if CHAT_SYSTEM and CHAT_SYSTEM.StartTextEntry then
            CHAT_SYSTEM:StartTextEntry(message, CHAT_CHANNEL_WHISPER, target)
        elseif CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
            CHAT_SYSTEM.textEntry:Open()
            if CHAT_SYSTEM.textEntry.editControl then
                CHAT_SYSTEM.textEntry.editControl:SetText(message)
                CHAT_SYSTEM.textEntry.editControl:SetCursorPosition(string.len(message))
            end
        end

    -- 2. Режим раздачи лишнего лута в чат группы / текущий канал
    else
        if totalChunks == 1 then
            message = string.format("Free / Up for grabs: %s (let me know if you need! :)", linksStr)
        else
            message = string.format("(%d/%d) Free / Up for grabs: %s (let me know!)", currentIdx, totalChunks, linksStr)
        end

        if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
            CHAT_SYSTEM.textEntry:Open()
            if CHAT_SYSTEM.textEntry.editControl then
                CHAT_SYSTEM.textEntry.editControl:SetText(message)
                CHAT_SYSTEM.textEntry.editControl:SetCursorPosition(string.len(message))
            end
        end
    end
end

function ZS:QueueChatMessages(targetPlayer, itemsList)
    if not targetPlayer or not itemsList or #itemsList == 0 then return end

    local links = {}
    for _, item in ipairs(itemsList) do
        if item.itemLink and item.itemLink ~= "" then
            table.insert(links, item.itemLink)
        end
    end

    if #links == 0 then return end

    local chunks = {}
    local currentChunk = {}

    for _, link in ipairs(links) do
        table.insert(currentChunk, link)
        if #currentChunk == 3 then
            table.insert(chunks, currentChunk)
            currentChunk = {}
        end
    end

    if #currentChunk > 0 then
        table.insert(chunks, currentChunk)
    end

    self.ChatQueue = {
        mode = "whisper",
        target = targetPlayer,
        chunks = chunks,
        currentIdx = 1,
    }

    self:LoadNextChatChunk()
end

-- Запуск раздачи всех лишних вещей в чат
function ZS:ShareExtraLootInChat()
    local dupes = self:GetTradableDuplicatesInBag()
    if #dupes == 0 then
        d(L.noTradableDupes)
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local chunks = {}
    local currentChunk = {}

    for _, link in ipairs(dupes) do
        table.insert(currentChunk, link)
        if #currentChunk == 3 then
            table.insert(chunks, currentChunk)
            currentChunk = {}
        end
    end

    if #currentChunk > 0 then
        table.insert(chunks, currentChunk)
    end

    self.ChatQueue = {
        mode = "offer",
        chunks = chunks,
        currentIdx = 1,
    }

    self:LoadNextChatChunk()
end


-- Автоматический поиск сетов для зоны (универсальный: Зоны, Данжи, Архив, БГ и Канализация)
function ZS:GetZoneSets(zoneId, zoneName)
    local results = {}
    if not ITEM_SET_COLLECTIONS_DATA_MANAGER then return results end

    local cleanPlayerZone = CleanZoneString(zoneName)
    if cleanPlayerZone == "" then return results end

    local myClassName = zo_strformat("<<1>>", GetUnitClass("player"))
    local cleanMyClass = CleanZoneString(myClassName)

    -- 1. Детектор Полей сражений (БГ)
    local isBG = IsActiveWorldBattleground and IsActiveWorldBattleground()

    -- 2. Детектор Имперского города и Канализации
    local isImperialOrSewers = string.find(cleanPlayerZone, "имперск", 1, true)
        or string.find(cleanPlayerZone, "imperial", 1, true)
        or string.find(cleanPlayerZone, "канализац", 1, true)
        or string.find(cleanPlayerZone, "sewer", 1, true)
        or string.find(cleanPlayerZone, "égout", 1, true)
        or string.find(cleanPlayerZone, "kanalisation", 1, true)

    local isArchiveMode = false

    for itemSetId in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionIterator() do
        local itemSetData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(itemSetId)
        
        if itemSetData and itemSetData.GetCategoryData then
            local categoryData = itemSetData:GetCategoryData()
            if categoryData and categoryData.GetFormattedName then
                local subCatName = categoryData:GetFormattedName()
                local cleanSubCat = CleanZoneString(subCatName)
                
                local parentCatData = categoryData.GetParentCategoryData and categoryData:GetParentCategoryData()
                local parentCatName = parentCatData and parentCatData.GetFormattedName and parentCatData:GetFormattedName() or ""
                local cleanParentCat = CleanZoneString(parentCatName)

                local isMatch = false
                local isClassSet = false

                -- СЛУЧАЙ 1: Мы на Полях сражений (БГ)
                if isBG then
                    local isBGCategory = (cleanSubCat == "поля сражений") 
                        or (cleanSubCat == "battlegrounds") 
                        or (cleanSubCat == "champs de bataille") 
                        or (cleanSubCat == "schlachtfelder")
                        or (string.find(cleanParentCat, "pvp", 1, true) and (string.find(cleanSubCat, "battle", 1, true) or string.find(cleanSubCat, "поля", 1, true)))
                    if isBGCategory then
                        isMatch = true
                    end

                -- СЛУЧАЙ 2: Мы в Имперском городе / Канализации
                elseif isImperialOrSewers then
                    local isImpCat = string.find(cleanSubCat, "имперск", 1, true)
                        or string.find(cleanSubCat, "imperial", 1, true)
                        or string.find(cleanSubCat, "cité impériale", 1, true)
                        or string.find(cleanSubCat, "kaiserstadt", 1, true)
                    -- Исключаем данжи Имперского города, если мы не внутри них
                    local isImpDungeon = string.find(cleanSubCat, "тюрьм", 1, true) 
                        or string.find(cleanSubCat, "prison", 1, true) 
                        or string.find(cleanSubCat, "башн", 1, true) 
                        or string.find(cleanSubCat, "tower", 1, true)
                    if isImpCat and not isImpDungeon then
                        isMatch = true
                    end

                -- СЛУЧАЙ 3: Обычные зоны, данжи, триалы (по подкатегории)
                elseif cleanPlayerZone == cleanSubCat or (cleanSubCat ~= "" and (string.find(cleanPlayerZone, cleanSubCat, 1, true) or string.find(cleanSubCat, cleanPlayerZone, 1, true))) then
                    isMatch = true

                -- СЛУЧАЙ 4: Бесконечный Архив (по родительской категории)
                elseif cleanParentCat ~= "" and (cleanPlayerZone == cleanParentCat or string.find(cleanPlayerZone, cleanParentCat, 1, true) or string.find(cleanParentCat, cleanPlayerZone, 1, true)) then
                    isMatch = true
                    isClassSet = true
                    isArchiveMode = true
                end

                if isMatch then
                    local rawName = zo_strformat("<<1>>", itemSetData:GetFormattedName())
                    local displayName = rawName
                    local isMyClassSet = false

                    -- В Архиве добавляем тег класса
                    if isClassSet and subCatName ~= "" then
                        displayName = string.format("%s |c00FFFF[%s]|r", rawName, subCatName)
                        if cleanSubCat == cleanMyClass or (cleanMyClass ~= "" and (string.find(cleanMyClass, cleanSubCat, 1, true) or string.find(cleanSubCat, cleanMyClass, 1, true))) then
                            isMyClassSet = true
                        end
                    end

                    table.insert(results, {
                        id = itemSetData:GetId(),
                        name = displayName,
                        rawName = rawName,
                        className = subCatName,
                        numPieces = itemSetData:GetNumPieces(),
                        numUnlocked = itemSetData:GetNumUnlockedPieces(),
                        itemSetData = itemSetData,
                        isMyClass = isMyClassSet,
                    })
                end
            end
        end
    end

    -- В Бесконечном Архиве сортируем свой класс на 1-е место
    if isArchiveMode and #results > 1 then
        table.sort(results, function(a, b)
            if a.isMyClass ~= b.isMyClass then
                return a.isMyClass == true
            end
            if a.className ~= b.className then
                return a.className < b.className
            end
            return a.rawName < b.rawName
        end)
    end

    return results
end

-- Получение списка кусочков сета
local function GetSetPiecesList(itemSetData)
    local pieces = {}
    if not itemSetData or not itemSetData.PieceIterator then return pieces end
    
    for _, pieceData in itemSetData:PieceIterator() do
        if pieceData and type(pieceData) == "table" then
            table.insert(pieces, {
                id = pieceData:GetId(),
                name = zo_strformat("<<1>>", pieceData:GetFormattedName()),
                icon = pieceData:GetIcon(),
                isUnlocked = pieceData:IsUnlocked(),
                itemLink = pieceData:GetItemLink()
            })
        end
    end
    return pieces
end

-- ================= ИНТЕРФЕЙС (ГЛАВНОЕ ОКНО) =================
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 500, 520

local ZSWindow = WINDOW_MANAGER:CreateTopLevelWindow("ZoneSets_Window")
ZSWindow:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
ZSWindow:SetDimensionConstraints(350, 250, 900, 900)
ZSWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
ZSWindow:SetMovable(true)
ZSWindow:SetClampedToScreen(true)
ZSWindow:SetHidden(true)
ZSWindow:SetMouseEnabled(true)
ZSWindow:SetResizeHandleSize(10)

ZSWindow:SetHandler("OnShow", function() SCENE_MANAGER:SetInUIMode(true) end)
ZSWindow:SetHandler("OnHide", function() SCENE_MANAGER:SetInUIMode(false) end)

local bg = WINDOW_MANAGER:CreateControl(nil, ZSWindow, CT_BACKDROP)
bg:SetAnchorFill()
bg:SetCenterColor(0, 0, 0, 0.75)
bg:SetEdgeColor(0.7, 0.7, 0.7, 1)

local title = WINDOW_MANAGER:CreateControl(nil, ZSWindow, CT_LABEL)
title:SetFont("ZoFontWinH1")
title:SetAnchor(TOP, ZSWindow, TOP, 0, 10)
title:SetText(L.title)

local zoneLabel = WINDOW_MANAGER:CreateControl(nil, ZSWindow, CT_LABEL)
zoneLabel:SetFont("ZoFontGameLargeBold")
zoneLabel:SetAnchor(TOP, title, BOTTOM, 0, 2)
zoneLabel:SetColor(1, 1, 0, 1)
ZS.ZoneLabel = zoneLabel

local closeBtn = WINDOW_MANAGER:CreateControl(nil, ZSWindow, CT_BUTTON)
closeBtn:SetDimensions(40, 40)
closeBtn:SetAnchor(TOPRIGHT, ZSWindow, TOPRIGHT, 5, 5)
closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
closeBtn:SetHandler("OnClicked", function() ZSWindow:SetHidden(true) end)

local tabContainer = WINDOW_MANAGER:CreateControl("ZoneSets_TabContainer", ZSWindow, CT_CONTROL)
tabContainer:SetDimensions(250, 30)
tabContainer:SetAnchor(TOP, zoneLabel, BOTTOM, 0, 6)

local tabZone = WINDOW_MANAGER:CreateControlFromVirtual("ZoneSets_TabZone", tabContainer, "ZO_DefaultTextButton")
tabZone:SetText(L.tabZone)
tabZone:SetDimensions(110, 25)
tabZone:SetAnchor(LEFT, tabContainer, LEFT, 0, 0)

local tabHistory = WINDOW_MANAGER:CreateControlFromVirtual("ZoneSets_TabHistory", tabContainer, "ZO_DefaultTextButton")
tabHistory:SetText(L.tabHistory)
tabHistory:SetDimensions(110, 25)
tabHistory:SetAnchor(RIGHT, tabContainer, RIGHT, 0, 0)

function ZS:UpdateTabVisuals()
    if self.CurrentTab == "history" then
        tabZone:SetNormalFontColor(0.6, 0.6, 0.6, 1)
        tabHistory:SetNormalFontColor(0.9, 0.7, 0.2, 1)
    else
        tabZone:SetNormalFontColor(0.9, 0.7, 0.2, 1)
        tabHistory:SetNormalFontColor(0.6, 0.6, 0.6, 1)
    end
end

tabZone:SetHandler("OnClicked", function()
    ZS.CurrentTab = "zone"
    ZS:UpdateTabVisuals()
    ZS:ShowWindow()
end)

tabHistory:SetHandler("OnClicked", function()
    ZS.CurrentTab = "history"
    ZS:UpdateTabVisuals()
    ZS:ShowWindow()
end)

-- ================= ВСПЛЫВАЮЩЕЕ ОКНО (TOAST HUD) =================
local ZSToast = WINDOW_MANAGER:CreateTopLevelWindow("ZoneSets_Toast")
ZSToast:SetDimensions(360, 60)
ZSToast:SetAnchor(TOP, GuiRoot, TOP, 0, 150)
ZSToast:SetHidden(true)
ZSToast:SetClampedToScreen(true)
ZSToast:SetMovable(true)
ZSToast:SetMouseEnabled(true)

local toastBg = WINDOW_MANAGER:CreateControl(nil, ZSToast, CT_BACKDROP)
toastBg:SetAnchorFill()
toastBg:SetCenterColor(0, 0, 0, 0.85)
toastBg:SetEdgeColor(0.9, 0.7, 0.2, 1)
toastBg:SetEdgeTexture(nil, 1, 1, 1, 0)

local toastIcon = WINDOW_MANAGER:CreateControl(nil, ZSToast, CT_TEXTURE)
toastIcon:SetDimensions(44, 44)
toastIcon:SetAnchor(LEFT, ZSToast, LEFT, 8, 0)
toastIcon:SetTexture("/esoui/art/icons/icon_missing.dds")

local toastTitle = WINDOW_MANAGER:CreateControl(nil, ZSToast, CT_LABEL)
toastTitle:SetFont("ZoFontWinH4")
toastTitle:SetAnchor(TOPLEFT, toastIcon, TOPRIGHT, 10, 2)
toastTitle:SetColor(1, 1, 1, 1)

local toastProgress = WINDOW_MANAGER:CreateControl(nil, ZSToast, CT_LABEL)
toastProgress:SetFont("ZoFontGameSmall")
toastProgress:SetAnchor(BOTTOMLEFT, toastIcon, BOTTOMRIGHT, 10, -2)
toastProgress:SetColor(0.9, 0.7, 0.2, 1)

ZSToast:SetHandler("OnMoveStop", function()
    if ZS.SavedVars then
        ZS.SavedVars.toastLeft, ZS.SavedVars.toastTop = ZSToast:GetLeft(), ZSToast:GetTop()
    end
end)

-- Контейнер скролла
local scroll = WINDOW_MANAGER:CreateControlFromVirtual("ZoneSets_Scroll", ZSWindow, "ZO_ScrollContainer")
scroll:SetAnchor(TOPLEFT, ZSWindow, TOPLEFT, 14, 115)
scroll:SetDimensions(DEFAULT_WIDTH - 28, DEFAULT_HEIGHT - 170)

local scrollChild = scroll:GetNamedChild("ScrollChild")
scrollChild:SetAnchor(TOPLEFT, scrollChild:GetParent(), TOPLEFT, 0, 0)
scrollChild:SetWidth(scroll:GetWidth() - 10)

local function ClearScrollChild()
    if not scrollChild then return end
    for i = #createdRows, 1, -1 do
        local r = createdRows[i]
        if r then
            r:SetHidden(true)
            r:ClearAnchors()
            r:SetParent(nil)
        end
        createdRows[i] = nil
    end
    scrollChild:SetHeight(0)
end

-- Кнопка раздачи лишнего лута внизу главного окна
local shareBtn = WINDOW_MANAGER:CreateControlFromVirtual("ZoneSets_ShareLootBtn", ZSWindow, "ZO_DefaultTextButton")
shareBtn:SetDimensions(DEFAULT_WIDTH - 28, 28)
shareBtn:SetAnchor(BOTTOM, ZSWindow, BOTTOM, 0, -8)
shareBtn:SetFont("ZoFontGameBold")
shareBtn:SetText(string.format("|cFFD700[%s]|r", L.shareExtraBtn))
ZS.ShareBtn = shareBtn

shareBtn:SetHandler("OnMouseEnter", function()
    shareBtn:SetText(string.format("|cFFFFFF[%s]|r", L.shareExtraBtn))
end)
shareBtn:SetHandler("OnMouseExit", function()
    shareBtn:SetText(string.format("|cFFD700[%s]|r", L.shareExtraBtn))
end)
shareBtn:SetHandler("OnClicked", function()
    if ZS.ShareExtraLootInChat then
        ZS:ShareExtraLootInChat()
    end
end)

function ZS:RecalculateAll()
    if not self.rows or not scrollChild or not scroll or not self.header then return end

    for _, r in ipairs(self.rows) do
        if r.piecesContainer then
            if r.piecesContainer:IsHidden() then
                r:SetHeight(56)
            else
                local gridH = r.piecesContainer:GetHeight() or 130
                r:SetHeight(56 + gridH + 10)
            end
        end
    end

    local prev = self.header
    for _, r in ipairs(self.rows) do
        r:ClearAnchors()
        r:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 15)
        prev = r
    end

    local top = scrollChild:GetTop()
    local lastBottom = prev and prev:GetBottom() or top
    local newHeight = lastBottom - top + 30
    scrollChild:SetHeight(math.max(newHeight, scroll:GetHeight() + 1))

    if type(ZO_Scroll_UpdateScrollBar) == "function" then
        ZO_Scroll_UpdateScrollBar(scroll)
    end
end

-- Адаптивная ширина всех элементов при растягивании/сжатии окна
function ZS:UpdateRowWidths(newWidth)
    if not self.rows then return end
    local scrollbarReserve = 25
    local targetWidth = newWidth - 28 - scrollbarReserve

    for _, r in ipairs(self.rows) do
        -- Обновляем ширину самой строки (чтобы [LF] двигалась вместе с краем)
        r:SetWidth(targetWidth)

        if r.headerArea then
            r.headerArea:SetWidth(targetWidth)
        end
        if r.nameLabel then
            r.nameLabel:SetWidth(math.max(targetWidth - 75, 80))
        end
        if r.barFrame then
            r.barFrame:SetWidth(math.max(targetWidth - 20, 100))
        end
        if r.piecesContainer then
            r.piecesContainer:SetWidth(targetWidth)
        end
    end
    zo_callLater(function() ZS:RecalculateAll() end, 50)
end

-- ================== ЛОГИКА СЕССИЙ И ИСТОРИИ ==================

function ZS:FormatTimeElapsed(timestamp)
    local now = GetTimeStamp()
    local elapsed = now - (timestamp or now)
    if elapsed < 0 then elapsed = 0 end

    if elapsed < 60 then
        return L.justNow
    elseif elapsed < 3600 then
        return string.format(L.minutesAgo, math.floor(elapsed / 60))
    else
        return string.format(L.hoursAgo, math.floor(elapsed / 3600))
    end
end

-- Добавление полученного сетового предмета в историю захода
function ZS:AddLootToHistory(itemLink, pieceId)
    if not self.SavedVars or not itemLink then return end
    self.SavedVars.ZoneHistory = self.SavedVars.ZoneHistory or {}

    local zoneId, zoneName = self:GetCurrentZoneInfo()
    if zoneId <= 0 then return end

    self.SavedVars.ZoneHistory[zoneId] = self.SavedVars.ZoneHistory[zoneId] or { current = {}, previous = {} }
    local zoneHistory = self.SavedVars.ZoneHistory[zoneId]

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    local done, total = 0, 0
    if setId and setId > 0 and ITEM_SET_COLLECTIONS_DATA_MANAGER then
        local itemSetData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(setId)
        if itemSetData then
            done = itemSetData:GetNumUnlockedPieces()
            total = itemSetData:GetNumPieces()
        end
    end

    local icon = GetItemLinkIcon(itemLink) or "/esoui/art/icons/icon_missing.dds"
    local pName = zo_strformat("<<1>>", GetItemLinkName(itemLink))

    table.insert(zoneHistory.current, 1, {
        pieceId = pieceId,
        name = pName,
        setName = zo_strformat("<<1>>", setName or ""),
        done = done,
        total = total,
        icon = icon,
        itemLink = itemLink,
        timestamp = GetTimeStamp(),
    })

    -- Очищаем этот предмет из списка нужного лута группы, если он там был
    if pieceId and pieceId > 0 and self.SavedVars.ZoneGroupLoot and self.SavedVars.ZoneGroupLoot[zoneId] then
        local gList = self.SavedVars.ZoneGroupLoot[zoneId]
        for i = #gList, 1, -1 do
            if gList[i].pieceId == pieceId then
                table.remove(gList, i)
            end
        end
    end
end

-- Проверка перехода зон и архивация сессий
function ZS:CheckZoneTransition()
    if not self.SavedVars then return end
    self.SavedVars.ZoneHistory = self.SavedVars.ZoneHistory or {}

    local zoneId = GetUnitWorldPosition("player") or 0
    if zoneId <= 0 then return end

    local now = GetTimeStamp()

    if self.LastZoneId and self.LastZoneId ~= zoneId then
        local oldId = self.LastZoneId
        local oldHistory = self.SavedVars.ZoneHistory[oldId]
        
        if oldHistory and oldHistory.current and #oldHistory.current > 0 then
            oldHistory.previous = oldHistory.current
            oldHistory.current = {}
        end

        if self.SavedVars.ZoneGroupLoot and self.SavedVars.ZoneGroupLoot[oldId] then
            self.SavedVars.ZoneGroupLoot[oldId] = {}
        end
    end

    self.LastZoneId = zoneId
    self.LastZoneTime = now
    ZS.TradeRequests = {} -- Очищаем запросы на обмен при смене зоны
end

-- ================== ПОКАЗ ОКНА ==================
function ZS:ShowWindow()
    local zoneId, zoneName = self:GetCurrentZoneInfo()

    if self.CurrentTab == "history" then
        self.ZoneLabel:SetText(string.format("|cFFFF00%s:|r %s", L.historyTitle, zoneName))
    else
        self.ZoneLabel:SetText(string.format("%s |cAAAAAA(ID: %d)|r", zoneName, zoneId))
    end

    ClearScrollChild()

    local leftPadding = 6
    local blockWidth = scrollChild:GetWidth()
    local rows = {}

    local header = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
    header:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, leftPadding, 5)
    header:SetHidden(true)

    -- === ВКЛАДКА ИСТОРИИ ===
    if self.CurrentTab == "history" then
        self.SavedVars.ZoneHistory = self.SavedVars.ZoneHistory or {}
        self.SavedVars.ZoneGroupLoot = self.SavedVars.ZoneGroupLoot or {}

        local historyData = self.SavedVars.ZoneHistory[zoneId] or { current = {}, previous = {} }
        local rawGroupLoot = self.SavedVars.ZoneGroupLoot[zoneId] or {}

        -- 1. СЕКЦИЯ: ЛУТ ГРУППЫ (НУЖНО МНЕ)
        local activeGroupLoot = {}
        for _, entry in ipairs(rawGroupLoot) do
            if entry.pieceId and not IsItemSetCollectionPieceUnlocked(entry.pieceId) then
                table.insert(activeGroupLoot, entry)
            end
        end

        local playersMap = {}
        local playersOrder = {}
        for _, item in ipairs(activeGroupLoot) do
            local pName = item.player or "Unknown"
            if not playersMap[pName] then
                playersMap[pName] = {}
                table.insert(playersOrder, pName)
            end
            table.insert(playersMap[pName], item)
        end

        local gSecHeader = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
        gSecHeader:SetWidth(blockWidth - 10)
        gSecHeader:SetHeight(28)

        local gSecLabel = WINDOW_MANAGER:CreateControl(nil, gSecHeader, CT_LABEL)
        gSecLabel:SetFont("ZoFontWinH3")
        gSecLabel:SetAnchor(TOPLEFT, gSecHeader, TOPLEFT, 4, 0)
        gSecLabel:SetText(L.groupLootHeader)

        table.insert(rows, gSecHeader)
        table.insert(createdRows, gSecHeader)

        if #playersOrder == 0 then
            local emptyRow = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
            emptyRow:SetWidth(blockWidth - 10)
            emptyRow:SetHeight(24)

            local emptyLbl = WINDOW_MANAGER:CreateControl(nil, emptyRow, CT_LABEL)
            emptyLbl:SetFont("ZoFontGame")
            emptyLbl:SetAnchor(TOPLEFT, emptyRow, TOPLEFT, 12, 0)
            emptyLbl:SetColor(0.6, 0.6, 0.6, 1)
            emptyLbl:SetText(L.noGroupLoot)

            table.insert(rows, emptyRow)
            table.insert(createdRows, emptyRow)
        else
            for _, pName in ipairs(playersOrder) do
                local pItems = playersMap[pName]

                local pCardHeader = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
                pCardHeader:SetWidth(blockWidth - 10)
                pCardHeader:SetHeight(30)

                local pBg = WINDOW_MANAGER:CreateControl(nil, pCardHeader, CT_BACKDROP)
                pBg:SetAnchorFill()
                pBg:SetCenterColor(0.1, 0.2, 0.3, 0.4)
                pBg:SetEdgeColor(0.3, 0.5, 0.7, 0.6)
                pBg:SetEdgeTexture(nil, 1, 1, 1, 0)

                local pLabel = WINDOW_MANAGER:CreateControl(nil, pCardHeader, CT_LABEL)
                pLabel:SetFont("ZoFontWinH4")
                pLabel:SetAnchor(LEFT, pCardHeader, LEFT, 8, 0)
                pLabel:SetText(string.format("|c00FFFF%s|r  |cAAAAAA(%s)|r", pName, string.format(L.itemsNeededCount, #pItems)))

                -- Кнопка [Попросить всё]
                local askAllBtn = WINDOW_MANAGER:CreateControl(nil, pCardHeader, CT_BUTTON)
                askAllBtn:SetDimensions(110, 22)
                askAllBtn:SetAnchor(RIGHT, pCardHeader, RIGHT, -6, 0)
                askAllBtn:SetFont("ZoFontGameBold")
                askAllBtn:SetText(string.format("|cFFD700[%s]|r", L.askAllBtn))

                askAllBtn:SetHandler("OnMouseEnter", function() askAllBtn:SetText(string.format("|cFFFFFF[%s]|r", L.askAllBtn)) end)
                askAllBtn:SetHandler("OnMouseExit", function() askAllBtn:SetText(string.format("|cFFD700[%s]|r", L.askAllBtn)) end)
                askAllBtn:SetHandler("OnClicked", function()
                    ZS:QueueChatMessages(pName, pItems)
                end)

                table.insert(rows, pCardHeader)
                table.insert(createdRows, pCardHeader)

                for _, item in ipairs(pItems) do
                    local gRow = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_BUTTON)
                    gRow:SetWidth(blockWidth - 20)
                    gRow:SetHeight(44)

                    local gRowBg = WINDOW_MANAGER:CreateControl(nil, gRow, CT_BACKDROP)
                    gRowBg:SetAnchorFill()
                    gRowBg:SetCenterColor(0, 0, 0, 0.5)
                    gRowBg:SetEdgeColor(0.5, 0.1, 0.1, 0.5)
                    gRowBg:SetEdgeTexture(nil, 1, 1, 1, 0)
                    gRowBg:SetMouseEnabled(false)

                    local gIcon = WINDOW_MANAGER:CreateControl(nil, gRow, CT_TEXTURE)
                    gIcon:SetDimensions(34, 34)
                    gIcon:SetAnchor(LEFT, gRow, LEFT, 6, 0)
                    gIcon:SetTexture(item.icon)
                    gIcon:SetMouseEnabled(false)

                    local gName = WINDOW_MANAGER:CreateControl(nil, gRow, CT_LABEL)
                    gName:SetFont("ZoFontWinH4")
                    gName:SetAnchor(TOPLEFT, gIcon, TOPRIGHT, 8, 2)
                    gName:SetText(item.name)
                    gName:SetColor(1, 1, 1, 1)
                    gName:SetMouseEnabled(false)

                    local timeStr = ZS:FormatTimeElapsed(item.timestamp)
                    local gSub = WINDOW_MANAGER:CreateControl(nil, gRow, CT_LABEL)
                    gSub:SetFont("ZoFontGameSmall")
                    gSub:SetAnchor(BOTTOMLEFT, gIcon, BOTTOMRIGHT, 8, -2)
                    gSub:SetText(string.format("|cFFD700%s|r  |cAAAAAA(%s)|r", item.setName, timeStr))
                    gSub:SetMouseEnabled(false)

                    -- Кнопка [Спросить]
                    local askSingleBtn = WINDOW_MANAGER:CreateControl(nil, gRow, CT_BUTTON)
                    askSingleBtn:SetDimensions(80, 20)
                    askSingleBtn:SetAnchor(RIGHT, gRow, RIGHT, -6, 0)
                    askSingleBtn:SetFont("ZoFontGame")
                    askSingleBtn:SetText(string.format("|c39DB92[%s]|r", L.askSingleBtn))

                    askSingleBtn:SetHandler("OnMouseEnter", function() askSingleBtn:SetText(string.format("|cFFFFFF[%s]|r", L.askSingleBtn)) end)
                    askSingleBtn:SetHandler("OnMouseExit", function() askSingleBtn:SetText(string.format("|c39DB92[%s]|r", L.askSingleBtn)) end)
                    askSingleBtn:SetHandler("OnClicked", function()
                        ZS:QueueChatMessages(pName, { item })
                    end)

                    gRow:SetHandler("OnMouseEnter", function()
                        gRowBg:SetCenterColor(0.2, 0.4, 0.8, 0.3)
                        local rCenterX = gRow:GetCenter()
                        local sCenterX = GuiRoot:GetWidth() / 2
                        if rCenterX and sCenterX and rCenterX < sCenterX then
                            InitializeTooltip(ItemTooltip, gRow, LEFT, 10, 0, RIGHT)
                        else
                            InitializeTooltip(ItemTooltip, gRow, RIGHT, -10, 0, LEFT)
                        end
                        if item.itemLink and item.itemLink ~= "" then
                            ItemTooltip:SetLink(item.itemLink)
                        end
                    end)

                    gRow:SetHandler("OnMouseExit", function()
                        gRowBg:SetCenterColor(0, 0, 0, 0.5)
                        ClearTooltip(ItemTooltip)
                    end)

                    gRow:SetHandler("OnMouseUp", function(_, button, upInside)
                        if not upInside then return end
                        if button == MOUSE_BUTTON_INDEX_LEFT then
                            if item.itemLink and item.itemLink ~= "" then
                                ZO_LinkHandler_InsertLink(item.itemLink)
                            end
                        elseif button == MOUSE_BUTTON_INDEX_RIGHT then
                            ZS:ShowItemSetInJournal(item.setName)
                        end
                    end)

                    table.insert(rows, gRow)
                    table.insert(createdRows, gRow)
                end
            end
        end

        -- 2. СЕКЦИИ: МОЙ ТЕКУЩИЙ И ПРОШЛЫЙ ЗАХОД
        local function RenderSessionBlock(titleText, itemsList, emptyText)
            local secHeader = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
            secHeader:SetWidth(blockWidth - 10)
            secHeader:SetHeight(28)

            local secLabel = WINDOW_MANAGER:CreateControl(nil, secHeader, CT_LABEL)
            secLabel:SetFont("ZoFontWinH3")
            secLabel:SetAnchor(TOPLEFT, secHeader, TOPLEFT, 4, 0)
            secLabel:SetText(titleText)

            table.insert(rows, secHeader)
            table.insert(createdRows, secHeader)

            if #itemsList == 0 then
                local emptyRow = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
                emptyRow:SetWidth(blockWidth - 10)
                emptyRow:SetHeight(24)

                local emptyLbl = WINDOW_MANAGER:CreateControl(nil, emptyRow, CT_LABEL)
                emptyLbl:SetFont("ZoFontGame")
                emptyLbl:SetAnchor(TOPLEFT, emptyRow, TOPLEFT, 12, 0)
                emptyLbl:SetColor(0.6, 0.6, 0.6, 1)
                emptyLbl:SetText(emptyText)

                table.insert(rows, emptyRow)
                table.insert(createdRows, emptyRow)
            else
                for _, item in ipairs(itemsList) do
                    local hRow = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_BUTTON)
                    hRow:SetWidth(blockWidth - 10)
                    hRow:SetHeight(48)

                    local hBg = WINDOW_MANAGER:CreateControl(nil, hRow, CT_BACKDROP)
                    hBg:SetAnchorFill()
                    hBg:SetCenterColor(0, 0, 0, 0.5)
                    hBg:SetEdgeColor(0.4, 0.4, 0.4, 0.5)
                    hBg:SetEdgeTexture(nil, 1, 1, 1, 0)
                    hBg:SetMouseEnabled(false)

                    local hIcon = WINDOW_MANAGER:CreateControl(nil, hRow, CT_TEXTURE)
                    hIcon:SetDimensions(36, 36)
                    hIcon:SetAnchor(LEFT, hRow, LEFT, 6, 0)
                    hIcon:SetTexture(item.icon)
                    hIcon:SetMouseEnabled(false)

                    local hName = WINDOW_MANAGER:CreateControl(nil, hRow, CT_LABEL)
                    hName:SetFont("ZoFontWinH4")
                    hName:SetAnchor(TOPLEFT, hIcon, TOPRIGHT, 8, 2)
                    hName:SetText(item.name)
                    hName:SetColor(1, 1, 1, 1)
                    hName:SetMouseEnabled(false)

                    local timeStr = ZS:FormatTimeElapsed(item.timestamp)
                    local hSub = WINDOW_MANAGER:CreateControl(nil, hRow, CT_LABEL)
                    hSub:SetFont("ZoFontGameSmall")
                    hSub:SetAnchor(BOTTOMLEFT, hIcon, BOTTOMRIGHT, 8, -2)
                    hSub:SetText(string.format("|cFFD700%s|r (%d/%d)  |cAAAAAA(%s)|r", item.setName, item.done, item.total, timeStr))
                    hSub:SetMouseEnabled(false)

                    hRow:SetHandler("OnMouseEnter", function()
                        hBg:SetCenterColor(0.2, 0.4, 0.8, 0.3)
                        local rCenterX = hRow:GetCenter()
                        local sCenterX = GuiRoot:GetWidth() / 2
                        if rCenterX and sCenterX and rCenterX < sCenterX then
                            InitializeTooltip(ItemTooltip, hRow, LEFT, 10, 0, RIGHT)
                        else
                            InitializeTooltip(ItemTooltip, hRow, RIGHT, -10, 0, LEFT)
                        end
                        if item.itemLink and item.itemLink ~= "" then
                            ItemTooltip:SetLink(item.itemLink)
                        end
                    end)

                    hRow:SetHandler("OnMouseExit", function()
                        hBg:SetCenterColor(0, 0, 0, 0.5)
                        ClearTooltip(ItemTooltip)
                    end)

                    hRow:SetHandler("OnMouseUp", function(_, button, upInside)
                        if not upInside then return end
                        if button == MOUSE_BUTTON_INDEX_LEFT then
                            if item.itemLink and item.itemLink ~= "" then
                                ZO_LinkHandler_InsertLink(item.itemLink)
                            end
                        elseif button == MOUSE_BUTTON_INDEX_RIGHT then
                            ZS:ShowItemSetInJournal(item.setName)
                        end
                    end)

                    table.insert(rows, hRow)
                    table.insert(createdRows, hRow)
                end
            end
        end

        RenderSessionBlock(L.currentSession, historyData.current or {}, L.noCurrentItems)
        RenderSessionBlock(L.previousSession, historyData.previous or {}, L.noPreviousItems)

    -- === ВКЛАДКА ЗОНЫ ===
    else
        local sets = self:GetZoneSets(zoneId, zoneName)

        if #sets == 0 then
            local emptyLabel = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_LABEL)
            emptyLabel:SetFont("ZoFontGameMedium")
            emptyLabel:SetAnchor(TOP, scrollChild, TOP, 0, 40)
            emptyLabel:SetColor(0.7, 0.7, 0.7, 1)
            emptyLabel:SetText(L.noSetsFound)
            table.insert(createdRows, emptyLabel)
        else
            for _, setInfo in ipairs(sets) do
                local done, total = setInfo.numUnlocked, setInfo.numPieces
                local isComplete = (done >= total and total > 0)
                local percent = total > 0 and math.floor((done / total) * 100) or 0
                local statusColor = isComplete and "00FF00" or "FFFFFF"

                local row = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
                row:SetWidth(blockWidth - 10)
                row:SetHeight(56)

                local headerArea = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
                headerArea:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
                headerArea:SetDimensions(blockWidth - 10, 54)
                headerArea:SetMouseEnabled(true)
                row.headerArea = headerArea

                local headerBg = WINDOW_MANAGER:CreateControl(nil, headerArea, CT_BACKDROP)
                headerBg:SetAnchorFill()
                headerBg:SetCenterColor(0, 0, 0, 0)
                headerBg:SetEdgeColor(0, 0, 0, 0)

                headerArea:SetHandler("OnMouseEnter", function() headerBg:SetCenterColor(0.2, 0.4, 0.8, 0.2) end)
                headerArea:SetHandler("OnMouseExit", function() headerBg:SetCenterColor(0, 0, 0, 0) end)
                headerArea:SetHandler("OnMouseUp", function(_, button, upInside)
                    if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                        ZS:ShowItemSetInJournal(setInfo.itemSetData)
                    end
                end)

                -- Кнопка [+] / [-]
                local toggleBtn = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
                toggleBtn:SetDimensions(22, 22)
                toggleBtn:SetAnchor(TOPLEFT, row, TOPLEFT, 2, 0)
                toggleBtn:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
                toggleBtn:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
                toggleBtn:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")

                local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
                nameLabel:SetFont("ZoFontWinH4")
                nameLabel:SetAnchor(TOPLEFT, toggleBtn, TOPRIGHT, 6, -2)
                nameLabel:SetText(string.format("|c%s%s|r  |cAAAAAA(%d%%)|r", statusColor, setInfo.name, percent))
                row.nameLabel = nameLabel

                -- Кнопка [LF]
                local chatBtn = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
                chatBtn:SetDimensions(38, 22)
                chatBtn:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 0)
                chatBtn:SetFont("ZoFontGameBold")
                chatBtn:SetText("|cFFD700[LF]|r")

                chatBtn:SetHandler("OnMouseEnter", function()
                    chatBtn:SetText("|cFFFFFF[LF]|r")
                    InitializeTooltip(InformationTooltip, chatBtn, TOP, 0, -5)
                    SetTooltipText(InformationTooltip, L.chatBtnTooltip)
                end)
                chatBtn:SetHandler("OnMouseExit", function()
                    chatBtn:SetText("|cFFD700[LF]|r")
                    ClearTooltip(InformationTooltip)
                end)
                chatBtn:SetHandler("OnClicked", function()
                    ZS:RequestSetInChat(setInfo)
                end)

                -- Рамка прогресс-бара
                local barFrame = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
                barFrame:SetDimensions(blockWidth - 30, 22)
                barFrame:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, -28, 4)
                barFrame:SetCenterColor(0, 0, 0, 0.6)
                barFrame:SetEdgeColor(0.9, 0.7, 0.2, 1)
                barFrame:SetEdgeTexture(nil, 1, 1, 1, 0)
                row.barFrame = barFrame

                local bar = WINDOW_MANAGER:CreateControl(nil, barFrame, CT_STATUSBAR)
                bar:SetAnchor(TOPLEFT, barFrame, TOPLEFT, 2, 2)
                bar:SetAnchor(BOTTOMRIGHT, barFrame, BOTTOMRIGHT, -2, -2)
                bar:SetMinMax(0, total > 0 and total or 1)
                bar:SetValue(done)
                bar:SetColor(isComplete and 0 or 0.7, isComplete and 0.7 or 0.2, 0.2, 1)

                local progLabel = WINDOW_MANAGER:CreateControl(nil, bar, CT_LABEL)
                progLabel:SetFont("ZoFontGameSmall")
                progLabel:SetAnchor(CENTER, bar, CENTER, 0, 0)
                progLabel:SetColor(1, 1, 1, 1)
                progLabel:SetText(string.format("%d / %d", done, total))

                local piecesContainer = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
                piecesContainer:SetAnchor(TOPLEFT, barFrame, BOTTOMLEFT, 0, 8)
                piecesContainer:SetWidth(blockWidth - 30)

                local piecesList = GetSetPiecesList(setInfo.itemSetData)
                local tileSize = 40
                local spacing = 6
                local cols = math.max(math.floor((blockWidth - 30) / (tileSize + spacing)), 1)

                for i, piece in ipairs(piecesList) do
                    local colIdx = (i - 1) % cols
                    local rowIdx = math.floor((i - 1) / cols)
                    local posX = colIdx * (tileSize + spacing)
                    local posY = rowIdx * (tileSize + spacing)

                    local tile = WINDOW_MANAGER:CreateControl(nil, piecesContainer, CT_BUTTON)
                    tile:SetDimensions(tileSize, tileSize)
                    tile:SetAnchor(TOPLEFT, piecesContainer, TOPLEFT, posX, posY)
                    tile:SetMouseEnabled(true)

                    local tileBg = WINDOW_MANAGER:CreateControl(nil, tile, CT_BACKDROP)
                    tileBg:SetAnchorFill()
                    tileBg:SetCenterColor(0, 0, 0, 0.8)
                    tileBg:SetEdgeTexture(nil, 1, 1, 1, 0)
                    tileBg:SetMouseEnabled(false)

                    if piece.isUnlocked then
                        tileBg:SetEdgeColor(0.8, 0.65, 0.2, 0.9)
                    else
                        tileBg:SetEdgeColor(0.5, 0.1, 0.1, 0.6)
                    end

                    local icon = WINDOW_MANAGER:CreateControl(nil, tile, CT_TEXTURE)
                    icon:SetDimensions(tileSize - 6, tileSize - 6)
                    icon:SetAnchor(CENTER, tile, CENTER, 0, 0)
                    icon:SetTexture(piece.icon)
                    icon:SetMouseEnabled(false)

                    if piece.isUnlocked then
                        icon:SetColor(1, 1, 1, 1)
                    else
                        icon:SetColor(0.25, 0.25, 0.25, 0.65)
                    end

                    tile:SetHandler("OnMouseEnter", function()
                        tileBg:SetCenterColor(0.2, 0.4, 0.8, 0.4)
                        local tileCenterX = tile:GetCenter()
                        local screenCenterX = GuiRoot:GetWidth() / 2
                        if tileCenterX and screenCenterX and tileCenterX < screenCenterX then
                            InitializeTooltip(ItemTooltip, tile, LEFT, 10, 0, RIGHT)
                        else
                            InitializeTooltip(ItemTooltip, tile, RIGHT, -10, 0, LEFT)
                        end
                        if piece.itemLink and piece.itemLink ~= "" then
                            ItemTooltip:SetLink(piece.itemLink)
                        end
                    end)

                    tile:SetHandler("OnMouseExit", function()
                        tileBg:SetCenterColor(0, 0, 0, 0.8)
                        ClearTooltip(ItemTooltip)
                    end)

                    tile:SetHandler("OnClicked", function()
                        if piece.itemLink and piece.itemLink ~= "" then
                            ZO_LinkHandler_InsertLink(piece.itemLink)
                        end
                    end)
                end

                local totalRows = math.ceil(#piecesList / cols)
                local gridHeight = totalRows * (tileSize + spacing)
                piecesContainer:SetHeight(gridHeight)
                piecesContainer:SetHidden(true)

                row.piecesContainer = piecesContainer

                toggleBtn:SetHandler("OnClicked", function()
                    local wasHidden = piecesContainer:IsHidden()
                    piecesContainer:SetHidden(not wasHidden)
                    if wasHidden then
                        toggleBtn:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
                        toggleBtn:SetPressedTexture("/esoui/art/buttons/minus_down.dds")
                        toggleBtn:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
                    else
                        toggleBtn:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
                        toggleBtn:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
                        toggleBtn:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
                    end
                    zo_callLater(function() ZS:RecalculateAll() end, 50)
                end)

                table.insert(rows, row)
                table.insert(createdRows, row)
            end
        end
    end

    ZS.rows = rows
    ZS.header = header
    ZS:RecalculateAll()
    
    ZSWindow:SetHidden(false)
end

function ZoneSets_ToggleWindow()
    if ZSWindow:IsHidden() then
        ZS:ShowWindow()
    else
        ZSWindow:SetHidden(true)
    end
end

-- ================= ПОКАЗ ТОСТОВ И ОБНОВЛЕНИЕ =================

function ZS:ShowTestToast()
    EVENT_MANAGER:UnregisterForUpdate("ZS_Toast_Hide_Timer")
    toastIcon:SetTexture("/esoui/art/icons/icon_missing.dds")
    toastTitle:SetText(L.testTitle)
    toastProgress:SetText(L.dragMe)
    ZSToast:SetHidden(false)
end

function ZS:ShowToastNotification(pieceData, itemSetData)
    if not self.SavedVars or self.SavedVars.showToast == false then return end

    local setName = (itemSetData and zo_strformat("<<1>>", itemSetData:GetFormattedName())) or "Новый сет"
    local done = (itemSetData and itemSetData:GetNumUnlockedPieces()) or 0
    local total = (itemSetData and itemSetData:GetNumPieces()) or 0

    local icon = (pieceData and pieceData.GetIcon and pieceData:GetIcon()) or "/esoui/art/icons/icon_missing.dds"
    local pieceName = (pieceData and pieceData.GetFormattedName and zo_strformat("<<1>>", pieceData:GetFormattedName())) or "Новый предмет"

    toastIcon:SetTexture(icon)
    toastTitle:SetText(pieceName)
    
    if total > 0 then
        toastProgress:SetText(string.format(L.toastProgressFormat, setName, done, total))
    else
        toastProgress:SetText(L.addedToColl)
    end

    ZSToast:SetHidden(false)

    local timerName = "ZS_Toast_Hide_Timer"
    EVENT_MANAGER:UnregisterForUpdate(timerName)
    EVENT_MANAGER:RegisterForUpdate(timerName, self.SavedVars.toastDuration or 4000, function()
        EVENT_MANAGER:UnregisterForUpdate(timerName)
        ZSToast:SetHidden(true)
    end)
end

-- Умный обработчик события привязки (только для Тостов)
local function OnItemSetCollectionUpdated(eventCode, itemSetId)
    if not itemSetId or itemSetId <= 0 or not ITEM_SET_COLLECTIONS_DATA_MANAGER then return end

    local itemSetData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(itemSetId)
    if not itemSetData or not itemSetData.PieceIterator then return end

    local targetPiece = nil

    for _, pieceData in itemSetData:PieceIterator() do
        if pieceData and type(pieceData) == "table" and pieceData.GetId and pieceData.IsUnlocked then
            local pId = pieceData:GetId()
            local isUnlocked = pieceData:IsUnlocked()

            if isUnlocked and not ZS.KnownPieces[pId] then
                targetPiece = pieceData
                ZS.KnownPieces[pId] = true
                break
            end
        end
    end

    if targetPiece then
        ZS:ShowToastNotification(targetPiece, itemSetData)

        -- Если изучили вещь, подчищаем её из списка нужного лута группы
        local pieceId = targetPiece.GetId and targetPiece:GetId()
        local zoneId = (ZS.GetCurrentZoneInfo and ZS:GetCurrentZoneInfo()) or 0
        if pieceId and zoneId > 0 and ZS.SavedVars and ZS.SavedVars.ZoneGroupLoot and ZS.SavedVars.ZoneGroupLoot[zoneId] then
            local gList = ZS.SavedVars.ZoneGroupLoot[zoneId]
            for i = #gList, 1, -1 do
                if gList[i].pieceId == pieceId then
                    table.remove(gList, i)
                end
            end
        end

        if not ZSWindow:IsHidden() then
            ZS:ShowWindow()
        end
    end
end

-- ================= СЛЕЖКА ЗА ЛУТОМ ГРУППЫ =================

-- Ловец сетовых предметов в нашем рюкзаке
local function OnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId ~= BAG_BACKPACK or not isNewItem then return end

    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return end

    -- Проверяем, есть ли у предмета сет
    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    if not hasSet or not setId or setId <= 0 then return end

    local pieceId = GetItemLinkItemId(itemLink)
    if not pieceId or pieceId <= 0 then return end

    -- Отправляем в «Текущий заход»
    ZS:AddLootToHistory(itemLink, pieceId)

    if not ZSWindow:IsHidden() and ZS.CurrentTab == "history" then
        ZS:ShowWindow()
    end
end

-- Ловец лута сопартийцев
local function OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, questItem, lootData, isSystemLoot)
    if not itemName or itemName == "" then return end

    local myCharName = zo_strformat("<<1>>", GetUnitName("player"))
    local myDisplayName = GetDisplayName()
    local receiver = zo_strformat("<<1>>", receivedBy)

    -- Игнорируем себя и пустые имена
    if receiver == myCharName or receiver == myDisplayName or receiver == "" then
        return
    end

    local hasSet, setName = GetItemLinkSetInfo(itemName)
    if not hasSet or not setName or setName == "" then return end

    local pieceId = GetItemLinkItemId(itemName)
    if not pieceId or pieceId <= 0 then return end

    -- Если у нас уже есть эта вещь — игнорируем
    local isUnlocked = IsItemSetCollectionPieceUnlocked(pieceId)
    if isUnlocked then return end

    local zoneId, zoneName = ZS:GetCurrentZoneInfo()
    if zoneId <= 0 then return end

    ZS.SavedVars.ZoneGroupLoot = ZS.SavedVars.ZoneGroupLoot or {}
    ZS.SavedVars.ZoneGroupLoot[zoneId] = ZS.SavedVars.ZoneGroupLoot[zoneId] or {}
    local gList = ZS.SavedVars.ZoneGroupLoot[zoneId]

    for _, entry in ipairs(gList) do
        if entry.player == receiver and entry.pieceId == pieceId then
            return
        end
    end

    local icon = GetItemLinkIcon(itemName) or "/esoui/art/icons/icon_missing.dds"
    local pName = zo_strformat("<<1>>", GetItemLinkName(itemName))

    table.insert(gList, 1, {
        player = receiver,
        pieceId = pieceId,
        name = pName,
        setName = zo_strformat("<<1>>", setName),
        icon = icon,
        itemLink = itemName,
        timestamp = GetTimeStamp(),
    })

    if not ZSWindow:IsHidden() and ZS.CurrentTab == "history" then
        ZS:ShowWindow()
    end
end

-- ================= ОТСЛЕЖИВАНИЕ ЧАТА ДЛЯ ТРЕЙДА И КОНВЕЙЕРА =================

local function OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    -- Конвейер сообщений (если отправили мы сами)
    if fromDisplayName == GetDisplayName() or channelType == CHAT_CHANNEL_WHISPER_SENT then
        if ZS.ChatQueue and ZS.ChatQueue.chunks then
            if ZS.ChatQueue.currentIdx < #ZS.ChatQueue.chunks then
                ZS.ChatQueue.currentIdx = ZS.ChatQueue.currentIdx + 1
                zo_callLater(function()
                    ZS:LoadNextChatChunk()
                end, 150)
            else
                ZS.ChatQueue = nil
            end
        end
        return
    end

    -- Если пишет кто-то другой — ловим ВСЕ ссылки на сеты без исключений
    if not text or text == "" then return end

    for itemLink in string.gmatch(text, "|H.-|h.-|h") do
        local hasSet = GetItemLinkSetInfo(itemLink)
        local pieceId = GetItemLinkItemId(itemLink)

        if hasSet and pieceId and pieceId > 0 then
            ZS.RecentRequestedPieces = ZS.RecentRequestedPieces or {}
            ZS.RecentRequestedPieces[pieceId] = GetTimeStamp()
        end
    end
end

-- ================= ПОМОЩНИК ОБМЕНА (TRADE HELPER) =================

local tradeHelper = nil
local btnPutRequested = nil
local btnDumpExtra = nil

-- Запоминаем текущего партнера по трейду
ZS.CurrentTradePartner = ""

local function GetTradePartnerName()
    if ZS.CurrentTradePartner and ZS.CurrentTradePartner ~= "" then
        return ZS.CurrentTradePartner
    end
    if TRADE_WINDOW and TRADE_WINDOW.targetName and TRADE_WINDOW.targetName.GetText then
        return zo_strformat("<<1>>", TRADE_WINDOW.targetName:GetText())
    end
    return ""
end

-- Поиск запрошенных вещей в сумке (напрямую по списку линков из чата)
local function FindRequestedItemsInBag(partnerName)
    local results = {}
    if not ZS.RecentRequestedPieces then return results end

    local now = GetTimeStamp()
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local isTradable = (not IsItemBound(BAG_BACKPACK, slotIndex)) or (IsItemBoPAndTradeable and IsItemBoPAndTradeable(BAG_BACKPACK, slotIndex))
            if isTradable then
                local hasSet = GetItemLinkSetInfo(itemLink)
                local pieceId = GetItemLinkItemId(itemLink)

                if hasSet and pieceId and pieceId > 0 then
                    -- Если эту вещь линковали в чате за последние 15 минут:
                    if ZS.RecentRequestedPieces[pieceId] and (now - ZS.RecentRequestedPieces[pieceId]) <= 900 then
                        table.insert(results, slotIndex)
                        if #results == 5 then break end
                    end
                end
            end
        end
    end

    return results
end

-- Поиск любого лишнего сетового лута с таймером в сумке
local function FindExtraDungeonLootInBag()
    local results = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            -- Проверяем: либо вещь вообще не привязана, либо на ней висит таймер группы/Архива
            local isTradable = (not IsItemBound(BAG_BACKPACK, slotIndex)) or (IsItemBoPAndTradeable and IsItemBoPAndTradeable(BAG_BACKPACK, slotIndex))
            if isTradable then
                local hasSet = GetItemLinkSetInfo(itemLink)
                local pieceId = GetItemLinkItemId(itemLink)

                if hasSet and pieceId and pieceId > 0 and IsItemSetCollectionPieceUnlocked(pieceId) then
                    table.insert(results, slotIndex)
                    if #results == 5 then break end
                end
            end
        end
    end

    return results
end

local function ExecuteTradeFill(slotsList)
    if not slotsList or #slotsList == 0 then return end
    local added = 0
    for _, slotIndex in ipairs(slotsList) do
        if TRADE_WINDOW and TRADE_WINDOW.AddItemToTrade then
            TRADE_WINDOW:AddItemToTrade(BAG_BACKPACK, slotIndex)
            added = added + 1
        elseif TradeAddItem then
            TradeAddItem(BAG_BACKPACK, slotIndex)
            added = added + 1
        end
    end
    d(string.format(L.tradeFilledMsg, added))
end

local function CreateTradeHelper()
    if tradeHelper then return end

    -- Создаем независимое окно верхнего уровня (поверх всех сцен и PerfectPixel)
    tradeHelper = WINDOW_MANAGER:CreateTopLevelWindow("ZoneSets_TradeHelper")
    tradeHelper:SetDimensions(420, 68)
    tradeHelper:SetClampedToScreen(true)
    tradeHelper:SetMovable(true)
    tradeHelper:SetMouseEnabled(true)
    tradeHelper:SetHidden(true)

    if ZS.SavedVars and ZS.SavedVars.tradeHelperLeft and ZS.SavedVars.tradeHelperTop then
        tradeHelper:ClearAnchors()
        tradeHelper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZS.SavedVars.tradeHelperLeft, ZS.SavedVars.tradeHelperTop)
    else
        -- По умолчанию ставим слева от центра, над блоком предложения
        tradeHelper:ClearAnchors()
        tradeHelper:SetAnchor(CENTER, GuiRoot, CENTER, -250, 180)
    end

    tradeHelper:SetHandler("OnMoveStop", function()
        if ZS.SavedVars then
            ZS.SavedVars.tradeHelperLeft, ZS.SavedVars.tradeHelperTop = tradeHelper:GetLeft(), tradeHelper:GetTop()
        end
    end)

    local tradeHelperBg = WINDOW_MANAGER:CreateControl(nil, tradeHelper, CT_BACKDROP)
    tradeHelperBg:SetAnchorFill()
    tradeHelperBg:SetCenterColor(0, 0, 0, 0.85)
    tradeHelperBg:SetEdgeColor(0.9, 0.7, 0.2, 1)
    tradeHelperBg:SetEdgeTexture(nil, 1, 1, 1, 0)
    tradeHelperBg:SetMouseEnabled(false)

    local tradeHelperTitle = WINDOW_MANAGER:CreateControl(nil, tradeHelper, CT_LABEL)
    tradeHelperTitle:SetFont("ZoFontWinH4")
    tradeHelperTitle:SetAnchor(TOPLEFT, tradeHelper, TOPLEFT, 10, 6)
    tradeHelperTitle:SetText(L.tradeHelperTitle)
    tradeHelperTitle:SetMouseEnabled(false)

    btnPutRequested = WINDOW_MANAGER:CreateControl(nil, tradeHelper, CT_BUTTON)
    btnPutRequested:SetDimensions(195, 24)
    btnPutRequested:SetAnchor(BOTTOMLEFT, tradeHelper, BOTTOMLEFT, 10, -8)
    btnPutRequested:SetFont("ZoFontGameBold")

    btnDumpExtra = WINDOW_MANAGER:CreateControl(nil, tradeHelper, CT_BUTTON)
    btnDumpExtra:SetDimensions(195, 24)
    btnDumpExtra:SetAnchor(BOTTOMRIGHT, tradeHelper, BOTTOMRIGHT, -10, -8)
    btnDumpExtra:SetFont("ZoFontGameBold")
end

local function OnTradeWindowOpen()
    CreateTradeHelper()
    if not tradeHelper then return end

    local partner = GetTradePartnerName()
    local requestedSlots = FindRequestedItemsInBag(partner)
    local extraSlots = FindExtraDungeonLootInBag()

    if #requestedSlots > 0 then
        btnPutRequested:SetText(string.format("|c00FF00[%s]|r", string.format(L.tradePutRequested, #requestedSlots)))
        btnPutRequested:SetEnabled(true)
        btnPutRequested:SetHandler("OnClicked", function()
            ExecuteTradeFill(requestedSlots)
            btnPutRequested:SetEnabled(false)
        end)
    else
        btnPutRequested:SetText("|c777777[" .. string.format(L.tradePutRequested, 0) .. "]|r")
        btnPutRequested:SetEnabled(false)
    end

    if #extraSlots > 0 then
        btnDumpExtra:SetText(string.format("|cFFD700[%s]|r", string.format(L.tradeDumpExtra, #extraSlots)))
        btnDumpExtra:SetEnabled(true)
        btnDumpExtra:SetHandler("OnClicked", function()
            ExecuteTradeFill(extraSlots)
            btnDumpExtra:SetEnabled(false)
        end)
    else
        btnDumpExtra:SetText("|c777777[" .. string.format(L.tradeDumpExtra, 0) .. "]|r")
        btnDumpExtra:SetEnabled(false)
    end

    tradeHelper:SetHidden(false)
end

local function OnTradeWindowClose()
    if tradeHelper then
        tradeHelper:SetHidden(true)
    end
end

local function OnTradeSucceeded()
    local partner = GetTradePartnerName()
    if partner and ZS.TradeRequests[partner] then
        ZS.TradeRequests[partner] = nil
    end
    if tradeHelper then
        tradeHelper:SetHidden(true)
    end
end

-- ================= СОХРАНЕНИЕ ПОЗИЦИИ И НАСТРОЕК =================
local function InitializeSavedVars()
    ZS.SavedVars = ZO_SavedVars:NewAccountWide("ZoneSets_AccountSavedVariables", 1, nil, {
        left = nil,
        top = nil,
        width = DEFAULT_WIDTH,
        height = DEFAULT_HEIGHT,
        toastLeft = nil,
        toastTop = nil,
        toastDuration = 4000,
        showToast = true,
        ZoneHistory = {},
        ZoneGroupLoot = {},
    }, GetWorldName())

    if ZS.SavedVars.left and ZS.SavedVars.top then
        ZSWindow:ClearAnchors()
        ZSWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZS.SavedVars.left, ZS.SavedVars.top)
    else
        ZSWindow:ClearAnchors()
        ZSWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    if ZSToast then
        if ZS.SavedVars.toastLeft and ZS.SavedVars.toastTop then
            ZSToast:ClearAnchors()
            ZSToast:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZS.SavedVars.toastLeft, ZS.SavedVars.toastTop)
        else
            ZSToast:ClearAnchors()
            ZSToast:SetAnchor(TOP, GuiRoot, TOP, 0, 150)
        end
    end

    if ZSWindow and ZS.SavedVars then
        ZSWindow:SetDimensions(ZS.SavedVars.width, ZS.SavedVars.height)
        local w, h = ZSWindow:GetDimensions()
        if scroll then
            scroll:SetDimensions(w - 28, h - 170)
            if scrollChild then
                scrollChild:SetWidth(scroll:GetWidth() - 10)
            end
        end
        if ZS.ShareBtn and ZS.ShareBtn.SetWidth then
            ZS.ShareBtn:SetWidth(w - 28)
        end
    end
end

ZSWindow:SetHandler("OnMoveStop", function()
    if ZS.SavedVars then
        ZS.SavedVars.left, ZS.SavedVars.top = ZSWindow:GetLeft(), ZSWindow:GetTop()
    end
end)

ZSWindow:SetHandler("OnResizeStop", function()
    local w, h = ZSWindow:GetDimensions()
    if ZS.SavedVars then
        ZS.SavedVars.width, ZS.SavedVars.height = w, h
    end
    if scroll then
        scroll:SetDimensions(w - 28, h - 170)
        if scrollChild then
            scrollChild:SetWidth(scroll:GetWidth() - 10)
        end
    end
    if ZS.ShareBtn and ZS.ShareBtn.SetWidth then
        ZS.ShareBtn:SetWidth(w - 28)
    end

    zo_callLater(function()
        if ZS.UpdateRowWidths then
            ZS:UpdateRowWidths(w)
        end
    end, 50)
end)

-- Регистрация команд
local function RegisterSlashCommands()
    local function SlashCommandParser(extra)
        local args = {}
        for word in string.gmatch(extra, "%S+") do
            table.insert(args, string.lower(word))
        end

        local cmd = args[1] or ""

        if cmd == "test" then
            if ZSToast:IsHidden() then
                ZS:ShowTestToast()
                d(L.testShown)
            else
                ZSToast:SetHidden(true)
                d(L.testSaved)
            end

        elseif cmd == "toast" then
            local arg = args[2] or ""
            if arg == "off" or arg == "disable" then
                ZS.SavedVars.showToast = false
                d(L.toastDisabled)
            elseif arg == "on" or arg == "enable" then
                ZS.SavedVars.showToast = true
                d(L.toastEnabled)
            else
                local secs = tonumber(arg)
                if secs and secs > 0 then
                    ZS.SavedVars.showToast = true
                    ZS.SavedVars.toastDuration = secs * 1000
                    d(string.format(L.toastDurationSet, secs))
                else
                    local status = (ZS.SavedVars.showToast ~= false) and "|c00FF00ВКЛЮЧЕНЫ|r" or "|cFF0000ОТКЛЮЧЕНЫ|r"
                    local curSecs = (ZS.SavedVars.toastDuration or 4000) / 1000
                    d(string.format(L.toastStatus, status, curSecs))
                end
            end

        -- Тестовая имитация запроса вещи из рюкзака
        elseif cmd == "fake" or cmd == "req" then
            local bagSize = GetBagSize(BAG_BACKPACK)
            local found = false
            for slotIndex = 0, bagSize - 1 do
                local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
                if itemLink and itemLink ~= "" then
                    local isTradable = (not IsItemBound(BAG_BACKPACK, slotIndex)) or (IsItemBoPAndTradeable and IsItemBoPAndTradeable(BAG_BACKPACK, slotIndex))
                    if isTradable then
                        local hasSet = GetItemLinkSetInfo(itemLink)
                        local pieceId = GetItemLinkItemId(itemLink)
                        if hasSet and pieceId and pieceId > 0 then
                            ZS.RecentRequestedPieces = ZS.RecentRequestedPieces or {}
                            ZS.RecentRequestedPieces[pieceId] = GetTimeStamp()
                            d("|c39DB92[ZoneSets Test]|r Сымитирован запрос на: " .. itemLink)
                            found = true
                            break
                        end
                    end
                end
            end
            if not found then
                d("|c39DB92[ZoneSets Test]|r В рюкзаке не найдено подходящих сетовых вещей для теста.")
            end

        else
            ZoneSets_ToggleWindow()
        end
    end

    SLASH_COMMANDS["/zs"] = SlashCommandParser
    SLASH_COMMANDS["/zonesets"] = SlashCommandParser
end

local function OnPlayerActivated(event)
    ZS:CheckZoneTransition()
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    InitializeSavedVars()
    RegisterSlashCommands()
    
    ZS.CurrentTab = "zone"
    ZS:UpdateTabVisuals()
    
    -- Запоминаем открытые вещи при старте
    if ITEM_SET_COLLECTIONS_DATA_MANAGER and ITEM_SET_COLLECTIONS_DATA_MANAGER.ItemSetCollectionIterator then
        for itemSetId in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionIterator() do
            local setData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(itemSetId)
            if setData and setData.PieceIterator then
                for _, p in setData:PieceIterator() do
                    if p and p.IsUnlocked and p:IsUnlocked() then
                        ZS.KnownPieces[p:GetId()] = true
                    end
                end
            end
        end
    end
    
    -- Подключаем сцену торговли
    local tradeScene = SCENE_MANAGER:GetScene("trade")
    if tradeScene then
        tradeScene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                OnTradeWindowOpen()
            elseif newState == SCENE_HIDDEN then
                OnTradeWindowClose()
            end
        end)
    end
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ITEM_SET_COLLECTION_UPDATED, OnItemSetCollectionUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, OnLootReceived)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_TRADE_SUCCEEDED, OnTradeSucceeded)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_TRADE_INVITE_WAITING, function(event, invitee) ZS.CurrentTradePartner = zo_strformat("<<1>>", invitee) end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_TRADE_INVITE_CONSIDERING, function(event, inviter) ZS.CurrentTradePartner = zo_strformat("<<1>>", inviter) end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)