-- Главная таблица аддона
NecroCat = NecroCat or {
    name    = "NecroCat",
    author  = "Soul_Hagans",
    version = "1.9.4",
}

local NC = NecroCat
NC.lastWhisperTime = 0 

-- Регистрация клавиш
ZO_CreateStringId("SI_BINDING_NAME_NECROCAT_MOUNT_UP", "Сесть на маунт согруппника")
ZO_CreateStringId("SI_BINDING_NAME_NC_DIFF_BASEGAME", "Сложность: Нормал")
ZO_CreateStringId("SI_BINDING_NAME_NC_DIFF_JOURNEYMAN", "Сложность: Опытный игрок")
ZO_CreateStringId("SI_BINDING_NAME_NC_DIFF_ADVENTURER", "Сложность: Мастер")
ZO_CreateStringId("SI_BINDING_NAME_NC_DIFF_VETERAN", "Сложность: Отголосок")
ZO_CreateStringId("SI_BINDING_NAME_NECROCAT_FOLLOW_SEND", "Отправить сигнал Follow")
ZO_CreateStringId("SI_BINDING_NAME_NECROCAT_FOLLOW_YES", "Follow: Телепортироваться (Принять)")
ZO_CreateStringId("SI_BINDING_NAME_NECROCAT_FOLLOW_NO", "Follow: Отмена")
ZO_CreateStringId("SI_BINDING_NAME_NECROCAT_SELF_WHISPER", "Шепот самому себе (Заметка)")

---------------------------------------------------------
-- 1. ФУНКЦИИ ДЕЙСТВИЙ (МАУНТ, ЧАТ, ТЕЛЕПОРТ)
---------------------------------------------------------

function NC.CastleHall()
    local accountName = GetDisplayName()
    if accountName == "@NecroCat_Crimson" then
        RequestJumpToHouse(13)
    else
        JumpToSpecificHouse("@NecroCat_Crimson", 13)
    end
end

function NC.SelfWhisper()
    local myId = GetDisplayName()
    if myId and myId ~= "" then
        StartChatInput("/w " .. myId .. " ")
    end
end

function NC.MountRider()
    if IsUnitInCombat("player") or IsUnitDead("player") then return end
    if not IsUnitGrouped("player") then return end

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if not AreUnitsEqual("player", unitTag) and IsUnitOnline(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            local mountedState, hasGroupMount, hasFreeSlot = GetTargetMountedStateInfo(displayName)
            
            if mountedState == MOUNTED_STATE_MOUNT_RIDER and hasGroupMount and hasFreeSlot then
                local _, x1, y1, z1 = GetUnitWorldPosition("player")
                local _, x2, y2, z2 = GetUnitWorldPosition(unitTag)
                if (zo_distance3D(x1, y1, z1, x2, y2, z2) / 100) < 5 then
                    EnablePreviewMode(true)
                    DisablePreviewMode()
                    UseMountAsPassenger(displayName)
                    return
                end
            end
        end
    end
end

function NC.OnChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    if channelType ~= CHAT_CHANNEL_WHISPER or not NC.savedVars.whisperAlert then return end

    local sender = fromDisplayName:gsub("%^%w+", "")
    if sender == "" then sender = fromName:gsub("%^%w+", "") end
    
    NC.WhisperLabel:SetText("|c66f2ff" .. sender .. "|r написал в личку!")
    NC.WhisperFrame:SetHidden(false)
    PlaySound("Whisper_Receive")

    local currentTime = GetFrameTimeSeconds()
    NC.lastWhisperTime = currentTime
    zo_callLater(function() 
        if NC.WhisperFrame and NC.lastWhisperTime == currentTime then 
            NC.WhisperFrame:SetHidden(true) 
        end
    end, NC.savedVars.whisperDuration * 1000)
end

-- Автоприем готовности при нахождении данжа (Activity Finder)
function NC.OnActivityFinderStatusUpdate(eventCode, status)
    if not NC.savedVars.autoAcceptDungeon then return end

    if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        zo_callLater(function()
            if GetActivityFinderStatus() == ACTIVITY_FINDER_STATUS_READY_CHECK then
                AcceptLFGReadyCheckNotification()
                d("|c66f2ff[NecroCat]|r Данж найден! Готовность принята автоматически.")
            end
        end, 500) -- Небольшая задержка в 0.5 сек, чтобы движок игры успел проинициализировать окно
    end
end

-- Автоматический отзыв и возврат небоевых питомцев в триалах
function NC.CheckTrialPets()
    if not NC.savedVars.dismissPetsInTrials then return end

    -- Проверяем ID текущей зоны через нашу внешнюю базу данных
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local isInTrial = (zoneId and NC.TrialZoneIds and NC.TrialZoneIds[zoneId]) or (IsRaidInProgress and IsRaidInProgress())

    if isInTrial then
        local activePetId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
        if activePetId and activePetId > 0 then
            NC.savedVars.storedPetId = activePetId
            zo_callLater(function()
                if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) == activePetId then
                    UseCollectible(activePetId)
                    d("|c66f2ff[NecroCat]|r Небоевой питомец отозван на время триала.")
                end
            end, 1500)
        end
    else
        local storedPet = NC.savedVars.storedPetId
        if storedPet and storedPet > 0 then
            zo_callLater(function()
                if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET) == 0 then
                    UseCollectible(storedPet)
                    d("|c66f2ff[NecroCat]|r Питомец призван обратно.")
                end
                NC.savedVars.storedPetId = 0
            end, 2000)
        end
    end
end



-- Поиск всех неизвестных рецептов, чертежей мебели, мотивов и страниц стилей
function NC.GetUnknownKnowledgeItems()
    local unknownList = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemType(BAG_BACKPACK, slotIndex)
            local isUnknown = false

            -- 1. Рецепты еды, напитков и чертежи мебели
            if itemType == ITEMTYPE_RECIPE then
                if not IsItemLinkRecipeKnown(itemLink) then
                    isUnknown = true
                end

            -- 2. Ремесленные мотивы (главы и книги крафта)
            elseif NC.savedVars.includeMotifs and itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
                if not IsItemLinkBookKnown(itemLink) then
                    isUnknown = true
                end

            -- 3. Страницы стилей нарядов (маски монстров, плечи, оружие ивентов)
            elseif NC.savedVars.includeStylePages then
                local numCollectibles = GetItemLinkNumContainerCollectibles and GetItemLinkNumContainerCollectibles(itemLink) or 0
                if numCollectibles > 0 then
                    local collectibleId = GetItemLinkContainerCollectibleId(itemLink, 1)
                    if collectibleId and not IsCollectibleUnlocked(collectibleId) then
                        isUnknown = true
                    end
                end
            end

            if isUnknown then
                table.insert(unknownList, {
                    slotIndex = slotIndex,
                    itemLink  = itemLink,
                })
            end
        end
    end

    return unknownList
end

-- Глушение всплывающего окна книги при изучении мотивов
local function HookLoreReaderSuppression()
    if not LORE_READER then return end
    ZO_PreHook(LORE_READER, "Show", function(self)
        if NC.isLearningKnowledge then
            EndInteraction(INTERACTION_BOOK)
            return true -- Глушим открытие книги на весь экран
        end
    end)
end

-- Поочередное быстрое изучение найденных предметов (Турбо-режим)
function NC.LearnAllUnknownKnowledge()
    if IsUnitInCombat("player") or IsUnitDead("player") then
        d("|cFF0000[NecroCat]|r Нельзя изучать предметы в бою!")
        return
    end

    local items = NC.GetUnknownKnowledgeItems()
    if #items == 0 then
        d("|c66f2ff[NecroCat]|r Неизвестных рецептов, мотивов или стилей в сумке не найдено.")
        return
    end

    d(string.format("|c66f2ff[NecroCat]|r Найдено неизвестных предметов: |c00FF00%d|r. Начинаем изучение...", #items))

    NC.isLearningKnowledge = true -- Включаем блокировку читалки книг
    local count = 0

    local function ProcessNext(index)
        if index > #items then
            NC.isLearningKnowledge = false -- Выключаем блокировку
            d(string.format("|c00FF00[NecroCat]|r Изучение завершено! Всего изучено: %d шт.|r", count))
            return
        end

        local item = items[index]
        local currentLink = GetItemLink(BAG_BACKPACK, item.slotIndex)

        -- Проверяем, что предмет все еще в слоте
        if currentLink == item.itemLink then
            CallSecureProtected("UseItem", BAG_BACKPACK, item.slotIndex)
            count = count + 1
            d(string.format("|c66f2ff[NecroCat]|r Изучено (%d/%d): %s", index, #items, item.itemLink))
        end

        -- Быстрая пауза 0.35 сек (в 4 раза быстрее, без лагов сервера)
        zo_callLater(function()
            ProcessNext(index + 1)
        end, 350)
    end

    ProcessNext(1)
end

---------------------------------------------------------
-- AUTO-RECHARGE & AUTO-REPAIR: ПОИСК РАСХОДНИКОВ
---------------------------------------------------------

function NC.FindSoulGem(priority)
    local normalSlot, crownSlot = nil, nil
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemType, specializedType = GetItemType(BAG_BACKPACK, slotIndex)
        if itemType == ITEMTYPE_SOUL_GEM then
            local _, isFilled = GetSoulGemItemInfo(BAG_BACKPACK, slotIndex)
            if isFilled and (isFilled == 1 or isFilled == true) then
                local link = GetItemLink(BAG_BACKPACK, slotIndex)
                local itemId = GetItemLinkItemId(link)
                local isCrown = (itemId == 61422) or (specializedType == SPECIALIZED_ITEMTYPE_SOUL_GEM_CROWN)
                
                if isCrown then
                    if not crownSlot then crownSlot = slotIndex end
                else
                    if not normalSlot then normalSlot = slotIndex end
                end
                
                -- Нашли оба варианта — дальше сумку можно не перебирать
                if normalSlot and crownSlot then break end
            end
        end
    end

    if priority == 1 then     -- Только обычные
        return normalSlot
    elseif priority == 2 then -- Сначала обычные -> затем кронные
        return normalSlot or crownSlot
    elseif priority == 3 then -- Сначала кронные -> затем обычные
        return crownSlot or normalSlot
    elseif priority == 4 then -- Только кронные
        return crownSlot
    end

    return normalSlot or crownSlot
end

function NC.FindRepairKit(priority)
    local normalSlot, crownSlot = nil, nil
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local itemType, specializedType = GetItemType(BAG_BACKPACK, slotIndex)
        -- В ESO походные ремнаборы имеют базовый тип ITEMTYPE_TOOL («Инструмент»)
        if itemType == ITEMTYPE_TOOL or itemType == ITEMTYPE_REPAIR_KIT or specializedType == SPECIALIZED_ITEMTYPE_TOOL_REPAIR_KIT then
            local link = GetItemLink(BAG_BACKPACK, slotIndex)
            local itemId = GetItemLinkItemId(link)

            -- Отсекаем отмычки (ID 30357)
            if itemId ~= 30357 then
                local isCrown = (itemId == 61421) 
                    or (specializedType == SPECIALIZED_ITEMTYPE_TOOL_REPAIR_KIT_CROWN) 
                    or (specializedType == SPECIALIZED_ITEMTYPE_REPAIR_KIT_CROWN)

                if isCrown then
                    if not crownSlot then crownSlot = slotIndex end
                else
                    if not normalSlot then normalSlot = slotIndex end
                end

                -- Нашли оба варианта — дальше сумку можно не перебирать
                if normalSlot and crownSlot then break end
            end
        end
    end

    if priority == 1 then     -- Только обычные
        return normalSlot
    elseif priority == 2 then -- Сначала обычные -> затем кронные
        return normalSlot or crownSlot
    elseif priority == 3 then -- Сначала кронные -> затем обычные
        return crownSlot or normalSlot
    elseif priority == 4 then -- Только кронные
        return crownSlot
    end

    return normalSlot or crownSlot
end

-- Авто-зарядка оружия и починка брони ремнаборами
function NC.OnWornSlotUpdate(eventCode, bagId, slotIndex)
    if bagId ~= BAG_WORN then return end
    if IsUnitDead("player") then return end

    -- 1. АВТО-ЗАРЯДКА ОРУЖИЯ
    if NC.savedVars.autoRechargeEnabled then
        local charge, maxcharge = GetChargeInfoForItem(BAG_WORN, slotIndex)
        if maxcharge and maxcharge > 0 then
            local percent = (charge / maxcharge) * 100
            if percent <= (NC.savedVars.autoRechargeThreshold or 20) then
                local gemSlot = NC.FindSoulGem(NC.savedVars.autoRechargePriority or 2)
                if gemSlot then
                    ChargeItemWithSoulGem(BAG_WORN, slotIndex, BAG_BACKPACK, gemSlot)
                end
            end
        end
    end

    -- 2. АВТО-ПОЧИНКА РЕМНАБОРАМИ (доспехи)
    if NC.savedVars.autoRepairKitsEnabled then
        local itemType = GetItemType(BAG_WORN, slotIndex)
        if itemType == ITEMTYPE_ARMOR then
            local condition = GetItemCondition(BAG_WORN, slotIndex)
            if condition and condition <= (NC.savedVars.autoRepairKitsThreshold or 20) then
                local kitSlot = NC.FindRepairKit(NC.savedVars.autoRepairKitsPriority or 2)
                if kitSlot then
                    local link = GetItemLink(BAG_BACKPACK, kitSlot)
                    local itemId = GetItemLinkItemId(link)

                    -- Если это кронный ремнабор (ID 61421), используем его только вне боя (в бою UseItem запрещен игрой)
                    if itemId == 61421 then
                        if not IsUnitInCombat("player") then
                            if IsProtectedFunction("UseItem") then
                                CallSecureProtected("UseItem", BAG_BACKPACK, kitSlot)
                            else
                                UseItem(BAG_BACKPACK, kitSlot)
                            end
                        end
                    else
                        RepairItemWithRepairKit(BAG_WORN, slotIndex, BAG_BACKPACK, kitSlot)
                    end
                end
            end
        end
    end

    -- 3. ОБНОВЛЕНИЕ РАМОК И ЦИФР НА ЭКРАНЕ ПЕРСОНАЖА (C)
    if NC.UpdateCharacterSlotGear then
        NC.UpdateCharacterSlotGear(slotIndex)
    end
end

-- Авто-починка у торговца за золото
function NC.OnOpenStore()
    if not NC.savedVars.autoVendorRepairEnabled then return end

    if CanStoreRepair() and GetRepairAllCost() > 0 then
        local cost = GetRepairAllCost()
        local currentMoney = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        if currentMoney >= cost then
            RepairAll()
            d(string.format("|c66f2ff[NecroCat]|r Снаряжение починено у торговца за |cFFD700%d|r золота.", cost))

            -- Обновляем все слоты на экране персонажа
            if NC.UpdateAllCharacterGear then
                NC.UpdateAllCharacterGear()
            end
        end
    end
end

---------------------------------------------------------
-- 2. ЛОГИКА ГРУППЫ (ИНВЕРСИЯ ИМЕН И @ID)
---------------------------------------------------------

-- Автоматический перевод группы в рейд при 5+ участниках
function NC.CheckAutoConvertToRaid()
    if not NC.savedVars.autoConvertToRaid then return end

    if IsUnitGroupLeader("player") and GetGroupSize() >= 5 and not IsGroupRaid() then
        ConvertToRaid()
        d("|c66f2ff[NecroCat]|r Группа автоматически преобразована в рейд (5+ чел.)")
    end
end

-- Глушение назойливых всплывающих окон и авто-телепорт
local function SuppressDialog(dialogName, dialogData)
    -- 1. Глушим предупреждение о рейде
    if NC.savedVars.autoConvertToRaid then
        if dialogName == "LARGE_GROUP_INVITE_WARNING" 
           or dialogName == "CONVERT_TO_RAID" 
           or dialogName == "CONFIRM_CONVERT_TO_RAID" then
            return true
        end
    end

    -- 2. Глушим предложение телепорта к лидеру при входе в группу
    if NC.savedVars.suppressJumpToLeader then
        if dialogName == "JUMP_TO_GROUP_LEADER" 
           or dialogName == "CONFIRM_JUMP_TO_GROUP_LEADER"
           or (type(dialogName) == "string" and string.find(dialogName, "JUMP_TO_GROUP_LEADER")) then
            return true
        end
    end

    -- 3. Мгновенный телепорт (и бесплатный от святилища, и платный из любой точки)
    if NC.savedVars.fastTravelConfirm and (dialogName == "FAST_TRAVEL_CONFIRM" or dialogName == "RECALL_CONFIRM") then
        if dialogData and dialogData.nodeIndex then
            FastTravelToNode(dialogData.nodeIndex)
            if SCENE_MANAGER and SCENE_MANAGER:IsShowing("worldMap") then
                SCENE_MANAGER:Hide("worldMap")
            end
            return true
        end
    end
end

-- Авто-заполнение проверочного текста (Крафт и Уничтожение предметов)
local function AutoConfirmDialog(dialogName)
    if type(dialogName) ~= "string" then return end

    -- Строжайшая защита: наглухо блокируем удаление персонажей, писем и разбор вещей на станках
    if string.find(dialogName, "DELETE") or string.find(dialogName, "DECONSTRUCT") then
        return
    end

    local shouldFill = false

    -- 1. Проверка для крафта (заточка, глифы, улучшение)
    if NC.savedVars.autoConfirmCrafting then
        if string.find(dialogName, "IMPROVE")
           or string.find(dialogName, "ENCHANT")
           or string.find(dialogName, "RETRAIT")
           or string.find(dialogName, "RECONSTRUCT")
           or string.find(dialogName, "TRANSMUTE")
           or string.find(dialogName, "MODIFY_LOCKED") then
            shouldFill = true
        end
    end

    -- 2. Проверка для уничтожения предметов из инвентаря (Мифики, кронные расходники)
    if NC.savedVars.autoConfirmDestroy then
        if string.find(dialogName, "DESTROY") then
            shouldFill = true
        end
    end

    if shouldFill then
        zo_callLater(function()
            local dialog = ZO_Dialog1
            if dialog and not dialog:IsHidden() then
                local editBox = ZO_Dialog1EditBox or dialog:GetNamedChild("EditBox")
                if editBox and not editBox:IsHidden() then
                    local matchText = GetString(SI_PERFORM_ACTION_CONFIRMATION)
                    local dialogInfo = ESO_Dialogs and ESO_Dialogs[dialogName]
                    if dialogInfo and dialogInfo.editBox and dialogInfo.editBox.matchingString then
                        local ms = dialogInfo.editBox.matchingString
                        if type(ms) == "string" and ms ~= "" then
                            matchText = ms
                        elseif type(ms) == "number" then
                            matchText = GetString(ms)
                        elseif type(ms) == "function" then
                            matchText = ms(dialog)
                        end
                    end

                    if matchText and matchText ~= "" then
                        editBox:SetText(matchText)
                    end
                end
            end
        end, 20)
    end
end

local function HookDialogSuppressions()
    HookLoreReaderSuppression()
    ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function(dialogName, dialogData)
        AutoConfirmDialog(dialogName)
        return SuppressDialog(dialogName, dialogData)
    end)
    ZO_PreHook("ZO_Dialogs_ShowDialog", function(dialogName, dialogData)
        AutoConfirmDialog(dialogName)
        return SuppressDialog(dialogName, dialogData)
    end)
end

local function ShowNecroTooltip(header, text)
    InitializeTooltip(InformationTooltip, GuiRoot, TOPLEFT, 0, 0)
    local mouseX, mouseY = GetUIMousePosition()
    InformationTooltip:ClearAnchors()
    InformationTooltip:SetAnchor(BOTTOM, GuiRoot, TOPLEFT, mouseX, mouseY - 15)
    
    InformationTooltip:AddLine(header, "ZoFontGameSmall")
    InformationTooltip:AddLine(text, "ZoFontWinH4", 1, 1, 1, CENTER)
end

local function NC_GroupEntryHook(self, control, data)
    if not control.characterNameLabel or not data then return end

    local charName = zo_strformat("<<1>>", data.characterName)
    local userID   = zo_strformat("<<1>>", data.displayName)

    local listText, tooltipHeader, tooltipText

    if NC.savedVars.swapGroupNames then
        listText = userID
        tooltipHeader = "Имя персонажа:"
        tooltipText = charName
    else
        listText = charName
        tooltipHeader = "ID аккаунта:"
        tooltipText = userID
    end

    control.characterNameLabel:SetText(zo_strformat(SI_GROUP_LIST_PANEL_CHARACTER_NAME, data.index, listText))

    local onEnter = function(ctrl) ShowNecroTooltip(tooltipHeader, tooltipText) end
    local onExit = function() ClearTooltip(InformationTooltip) end

    control.characterNameLabel:SetMouseEnabled(true)
    control.characterNameLabel:SetHandler("OnMouseEnter", onEnter)
    control.characterNameLabel:SetHandler("OnMouseExit", onExit)

    control:SetHandler("OnMouseEnter", onEnter)
    control:SetHandler("OnMouseExit", onExit)
end

---------------------------------------------------------
-- 3. INTERACTION FIX
---------------------------------------------------------

local function NC_InitInteractionFix()
    if not PLAYER_TO_PLAYER then return end

    ZO_PreHook(PLAYER_TO_PLAYER, "AddMenuEntry", function(self, text)
        if NC.savedVars.hideRemoveFromGroup and text == GetString(SI_PLAYER_TO_PLAYER_REMOVE_GROUP) then
            return true -- Отменяем добавление кнопки
        end
        if NC.savedVars.hideAddFriend and text == GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND) then
            return true -- Отменяем добавление кнопки
        end
        if NC.savedVars.hideTributeInvite and text then
            if (SI_PLAYER_TO_PLAYER_TRIBUTE_INVITE and text == GetString(SI_PLAYER_TO_PLAYER_TRIBUTE_INVITE))
               or string.find(text, "наградах")
               or string.find(text, "Tribute") then
                return true -- Отменяем приглашение в карточную игру
            end
        end
    end)
end

function NC.UpdateJumpToLeaderSuppression()
    if not PLAYER_TO_PLAYER or not PLAYER_TO_PLAYER.control then return end

    if NC.savedVars.suppressJumpToLeader then
        PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_UNIT_CREATED)
        PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_ZONE_UPDATE)
        PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_GROUP_MEMBER_JOINED)
        PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_LEADER_UPDATE)
        PLAYER_TO_PLAYER.control:UnregisterForEvent(EVENT_GROUP_MEMBER_LEFT)
    end
end

---------------------------------------------------------
-- 4. РАБОТА С UI И МЕНЮ
---------------------------------------------------------

NC.GuildIcons = {
    [839248] = "NecroCat/imgs/CastleofNecroCat.dds",
    [698160] = "NecroCat/imgs/garden.dds",
    [766278] = "NecroCat/imgs/gym.dds", 
}

NC.TrialZoneIds = {
    [636]  = true, -- Hel Ra Citadel (Цитадель Хель-Ра)
    [638]  = true, -- Aetherian Archive (Этерианский Архив)
    [639]  = true, -- Sanctum Ophidia (Санктум-Офидия)
    [725]  = true, -- Maw of Lorkhaj (Пасть Лоркаджа)
    [975]  = true, -- Halls of Fabrication (Залы Фабрикации)
    [1000] = true, -- Asylum Sanctorium (Изоляционный Санктуарий)
    [1051] = true, -- Cloudrest (Клаудрест)
    [1121] = true, -- Sunspire (Солнечный Шпиль)
    [1196] = true, -- Kyne's Aegis (Эгида Кин)
    [1263] = true, -- Rockgrove (Каменная Роща)
    [1344] = true, -- Dreadsail Reef (Риф Зловещих Парусов)
    [1427] = true, -- Sanity's Edge (Грань Безумия)
    [1478] = true, -- Lucent Citadel (Цитадель Люцентов)
    [1548] = true, -- Ossein Cage (Костяная Клетка)
    [1565] = true, -- Opulent Ordeal (Платиновое горнило)
}

-- [NEW MODULE] Guild Bank Switcher UI (с поддержкой нашего порядка)
function NC.UpdateGuildBankButtons()
    if not NC.BankFrame then return end

    local sortedGuilds = NC.GetSortedGuildList()
    local numGuilds = #sortedGuilds

    for i = 1, 5 do
        local btn = NC.BankFrame.buttons and NC.BankFrame.buttons[i]
        if not btn then
            NC.BankFrame.buttons = NC.BankFrame.buttons or {}
            btn = WINDOW_MANAGER:CreateControl("NecroCat_BankBtn" .. i, NC.BankFrame, CT_BUTTON)
            btn:SetDimensions(30, 30)
            btn:SetAnchor(LEFT, NC.BankFrame, LEFT, 5 + ((i - 1) * 35), 0)
            NC.BankFrame.buttons[i] = btn
        end

        local gData = sortedGuilds[i]
        if gData then
            local gid = gData.guildId
            local customIcon = NC.GuildIcons[gid]

            if customIcon then
                btn:SetNormalTexture(customIcon)
                btn:SetMouseOverTexture(customIcon)
            else
                btn:SetNormalTexture("EsoUI/Art/Buttons/pointsplus_up.dds")
                btn:SetMouseOverTexture("EsoUI/Art/Buttons/pointsplus_over.dds")
            end

            btn:SetHandler("OnClicked", function()
                ZO_SharedInventory_SelectAccessibleGuildBank(gid)
            end)

            btn:SetHandler("OnMouseEnter", function(ctrl)
                InitializeTooltip(InformationTooltip, ctrl, TOP, 0, 5)
                SetTooltipText(InformationTooltip, gData.guildName)
            end)

            btn:SetHandler("OnMouseExit", function() 
                ClearTooltip(InformationTooltip) 
            end)

            btn:SetHidden(false)
        else
            btn:SetHidden(true)
        end
    end

    NC.BankFrame:SetWidth(10 + (numGuilds * 35))
end

---------------------------------------------------------
-- МОДУЛЬ: ЦВЕТ КАЧЕСТВА И ПРОЧНОСТЬ НА ЭКРАНЕ ПЕРСОНАЖА (C)
---------------------------------------------------------

local GEAR_SLOTS = {
    [EQUIP_SLOT_HEAD]           = ZO_CharacterEquipmentSlotsHead,
    [EQUIP_SLOT_NECK]           = ZO_CharacterEquipmentSlotsNeck,
    [EQUIP_SLOT_CHEST]          = ZO_CharacterEquipmentSlotsChest,
    [EQUIP_SLOT_SHOULDERS]      = ZO_CharacterEquipmentSlotsShoulder,
    [EQUIP_SLOT_MAIN_HAND]      = ZO_CharacterEquipmentSlotsMainHand,
    [EQUIP_SLOT_OFF_HAND]       = ZO_CharacterEquipmentSlotsOffHand,
    [EQUIP_SLOT_POISON]         = ZO_CharacterEquipmentSlotsPoison,
    [EQUIP_SLOT_WAIST]          = ZO_CharacterEquipmentSlotsBelt,
    [EQUIP_SLOT_LEGS]           = ZO_CharacterEquipmentSlotsLeg,
    [EQUIP_SLOT_FEET]           = ZO_CharacterEquipmentSlotsFoot,
    [EQUIP_SLOT_COSTUME]        = ZO_CharacterEquipmentSlotsCostume,
    [EQUIP_SLOT_RING1]          = ZO_CharacterEquipmentSlotsRing1,
    [EQUIP_SLOT_RING2]          = ZO_CharacterEquipmentSlotsRing2,
    [EQUIP_SLOT_HAND]           = ZO_CharacterEquipmentSlotsGlove,
    [EQUIP_SLOT_BACKUP_MAIN]    = ZO_CharacterEquipmentSlotsBackupMain,
    [EQUIP_SLOT_BACKUP_OFF]     = ZO_CharacterEquipmentSlotsBackupOff,
    [EQUIP_SLOT_BACKUP_POISON]  = ZO_CharacterEquipmentSlotsBackupPoison,
}

local function GetDurabilityColor(val, a)
    local r, g
    if val > 100 then val = 100 end

    if val >= 50 then
        r = 100 - ((val - 50) * 2)
        g = 100
    else
        r = 100
        g = val * 2
    end

    return r / 100, g / 100, 0, a or 0.95
end

function NC.UpdateCharacterSlotGear(slot)
    if slot == EQUIP_SLOT_COSTUME then return end

    local t = _G["NecroCat_GearBg" .. slot]
    local l = _G["NecroCat_GearLabel" .. slot]
    if not t or not l then return end

    local p = t:GetParent()
    if not p then return end

    p:SetMouseOverTexture(not ZO_Character_IsReadOnly() and "NecroCat/imgs/mo.dds" or nil)
    p:SetPressedMouseOverTexture(not ZO_Character_IsReadOnly() and "NecroCat/imgs/mo.dds" or nil)

    local s = p:GetNamedChild("DropCallout")
    if s then
        s:ClearAnchors()
        s:SetAnchor(TOPLEFT, p, TOPLEFT, 0, 2)
        s:SetDimensions(52, 52)
        s:SetTexture("NecroCat/imgs/spot.dds")
        s:SetDrawLayer(0)
    end

    s = p:GetNamedChild("Highlight")
    if s then
        s:ClearAnchors()
        s:SetAnchor(TOPLEFT, p, TOPLEFT, 0, 2)
        s:SetDimensions(52, 52)
        s:SetTexture("NecroCat/imgs/spot.dds")
    end

    if not NC.savedVars.showGearStatus then
        t:SetHidden(true)
        l:SetHidden(true)
        return
    end

    if GetItemInstanceId(BAG_WORN, slot) then
        local itemLink = GetItemLink(BAG_WORN, slot)

        t:SetHidden(false)
        t:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkDisplayQuality(itemLink)))

        local hasDurability = (DoesItemHaveDurability and DoesItemHaveDurability(BAG_WORN, slot)) or (GetItemType(BAG_WORN, slot) == ITEMTYPE_ARMOR)
        
        if hasDurability and (slot ~= EQUIP_SLOT_NECK and slot ~= EQUIP_SLOT_RING1 and slot ~= EQUIP_SLOT_RING2) then
            local con = GetItemLinkCondition(itemLink)
            l:SetText(con .. "%")
            l:SetColor(GetDurabilityColor(con, 0.95))
            l:SetHidden(false)
        elseif DoesItemLinkHaveEnchantCharges and DoesItemLinkHaveEnchantCharges(itemLink) then
            local maxC = GetItemLinkMaxEnchantCharges(itemLink)
            if maxC and maxC > 0 then
                local con = (GetItemLinkNumEnchantCharges(itemLink) / maxC) * 100
                l:SetText(zo_round(con) .. "%")
                l:SetColor(GetDurabilityColor(con, 0.95))
                l:SetHidden(false)
            else
                l:SetHidden(true)
            end
        else
            l:SetHidden(true)
        end
    else
        t:SetHidden(true)
        l:SetHidden(true)
    end
end

function NC.InitCharacterGearUI()
    if NC.gearUIInitialized then return end

    for slotId, slotControl in pairs(GEAR_SLOTS) do
        if slotControl then
            local s = WINDOW_MANAGER:CreateControl("NecroCat_GearBg" .. slotId, slotControl, CT_TEXTURE)
            s:SetHidden(true)
            s:SetDrawLevel(1)
            s:SetTexture("NecroCat/imgs/hole.dds")
            s:SetAnchorFill()

            local l = WINDOW_MANAGER:CreateControl("NecroCat_GearLabel" .. slotId, slotControl, CT_LABEL)
            l:SetFont("ZoFontGameBold")
            l:SetAnchor(TOPRIGHT, slotControl, TOPRIGHT, 7, -8)
            l:SetDimensions(50, 14)
            l:SetHidden(true)
            l:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
    end

    NC.gearUIInitialized = true
end

function NC.UpdateAllCharacterGear()
    if not NC.gearUIInitialized then
        NC.InitCharacterGearUI()
    end

    for slotId in pairs(GEAR_SLOTS) do
        NC.UpdateCharacterSlotGear(slotId)
    end
end

function NC.CreateGuildBankUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("NecroCat_BankFrame")
    frame:SetDimensions(200, 40)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NC.savedVars.guildBankLeft, NC.savedVars.guildBankTop)
    frame:SetMovable(true)
    frame:SetMouseEnabled(true)
    frame:SetClampedToScreen(true)
    frame:SetHidden(true)
    frame:SetHandler("OnMoveStop", function(self)
        NC.savedVars.guildBankLeft = self:GetLeft()
        NC.savedVars.guildBankTop = self:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl("NecroCat_BankBG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0, 0, 0, 0.5)
    bg:SetEdgeColor(0, 0, 0, 0.5)

    NC.BankFrame = frame
    NC.UpdateGuildBankButtons()
end

function NC.CreateDifficultyUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("NecroCat_DifficultyFrame")
    frame:SetDimensions(400, 50)
    frame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
    frame:SetHidden(true)
    local label = WINDOW_MANAGER:CreateControl("NecroCat_DifficultyLabel", frame, CT_LABEL)
    label:SetAnchorFill(frame)
    label:SetFont("ZoFontWinH2")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    NC.DifficultyFrame = frame
    NC.DifficultyLabel = label
end

-- Создание переключателя "Автоприем" в меню группы (P)
function NC.CreateGroupMenuAutoAcceptUI()
    local parent = ZO_SearchingForGroupStatus and ZO_SearchingForGroupStatus:GetParent() or ZO_GroupMenu_Keyboard_TopLevel
    if not parent then return end

    local check = CreateControlFromVirtual("NecroCat_AutoAcceptDungeonCheck", parent, "ZO_CheckButton")
    if not check then return end

    check:ClearAnchors()
    if ZO_SearchingForGroupStatus then
        check:SetAnchor(BOTTOMLEFT, ZO_SearchingForGroupStatus, TOPLEFT, 0, -25)
    else
        check:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 20, -90)
    end

    check:SetDrawTier(DT_HIGH)
    check:SetHidden(not NC.savedVars.showAutoAcceptButton)

    ZO_CheckButton_SetLabelText(check, "|c66f2ffАвтоприем|r")
    ZO_CheckButton_SetCheckState(check, NC.savedVars.autoAcceptDungeon)

    ZO_CheckButton_SetToggleFunction(check, function(control, isChecked)
        NC.savedVars.autoAcceptDungeon = isChecked
    end)

    NC.AutoAcceptDungeonCheck = check
end

-- [NEW MODULE] Плавающая иконка изучения рецептов (Инвентарь и Банки)
function NC.UpdateRecipeButtonVisibility()
    if not NC.RecipeFragment then return end
    if NC.savedVars.showRecipeButton then
        -- Добавляем фрагмент в сцены
        SCENE_MANAGER:GetScene("inventory"):AddFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("bank"):AddFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("guildBank"):AddFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("houseBank"):AddFragment(NC.RecipeFragment)
    else
        -- Убираем фрагмент из сцен
        SCENE_MANAGER:GetScene("inventory"):RemoveFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("bank"):RemoveFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("guildBank"):RemoveFragment(NC.RecipeFragment)
        SCENE_MANAGER:GetScene("houseBank"):RemoveFragment(NC.RecipeFragment)
    end
end

function NC.CreateRecipeLearnerUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("NecroCat_RecipeFrame")
    frame:SetDimensions(36, 36)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NC.savedVars.recipeButtonLeft or 400, NC.savedVars.recipeButtonTop or 300)
    frame:SetMovable(true)
    frame:SetMouseEnabled(true)
    frame:SetClampedToScreen(true)
    frame:SetDrawTier(DT_HIGH)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetHidden(true)

    -- Иконка книги
    local icon = WINDOW_MANAGER:CreateControl("$(parent)Icon", frame, CT_TEXTURE)
    icon:SetAnchorFill(frame)
    icon:SetTexture("EsoUI/Art/MainMenu/menuBar_journal_up.dds")

    -- Подсветка при наведении
    local highlight = WINDOW_MANAGER:CreateControl("$(parent)Highlight", frame, CT_TEXTURE)
    highlight:SetAnchorFill(frame)
    highlight:SetTexture("EsoUI/Art/MainMenu/menuBar_journal_over.dds")
    highlight:SetHidden(true)

    -- Перетаскивание: движок ESO сам перемещает окно
    frame:SetHandler("OnMoveStop", function(self)
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self:GetLeft(), self:GetTop())
        NC.savedVars.recipeButtonLeft = self:GetLeft()
        NC.savedVars.recipeButtonTop = self:GetTop()
    end)

    -- Фиксируем начальную точку клика
    local startX, startY = 0, 0
    frame:SetHandler("OnMouseDown", function(self, button)
        startX, startY = self:GetLeft(), self:GetTop()
    end)

    -- Если отпустили на том же месте — это клик (изучаем). Если сдвинули — это перетаскивание!
    frame:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside then
            local endX, endY = self:GetLeft(), self:GetTop()
            if math.abs(endX - startX) < 5 and math.abs(endY - startY) < 5 then
                NC.LearnAllUnknownKnowledge()
            end
        end
    end)

    frame:SetHandler("OnMouseEnter", function(self)
        highlight:SetHidden(false)
        local count = #NC.GetUnknownKnowledgeItems()
        InitializeTooltip(InformationTooltip, self, TOP, 0, 5)
        InformationTooltip:AddLine("|c66f2ffNecroCat: Изучение рецептов|r", "ZoFontWinH4")
        InformationTooltip:AddLine(string.format("Неизвестных в сумке: |c00FF00%d|r", count), "ZoFontGame")
        InformationTooltip:AddLine("|c00FF00Клик:|r Изучить всё неизвестное", "ZoFontGameSmall")
        InformationTooltip:AddLine("|cFFFF22Зажать ЛКМ:|r Перетащить иконку", "ZoFontGameSmall")
    end)

    frame:SetHandler("OnMouseExit", function(self)
        highlight:SetHidden(true)
        ClearTooltip(InformationTooltip)
    end)

    NC.RecipeFrame = frame
    NC.RecipeFragment = ZO_SimpleSceneFragment:New(frame)

    NC.UpdateRecipeButtonVisibility()
end

function NC.ShowFriendNotification(displayName)
    if not NC.FriendNotificationFrame then return end
    
    local now = GetFrameTimeSeconds()
    NC.lastNotificationTime = NC.lastNotificationTime or {}
    if NC.lastNotificationTime[displayName] and (now - NC.lastNotificationTime[displayName] < 2) then 
        return 
    end
    NC.lastNotificationTime[displayName] = now 
    
    NC.FriendNotificationLabel:SetText("|c00ff00" .. displayName .. "|r вошел в игру!")
    NC.FriendNotificationFrame:SetHidden(false)
    PlaySound("Quest_Complete")
    zo_callLater(function() if NC.FriendNotificationFrame then NC.FriendNotificationFrame:SetHidden(true) end end, 5000)
end

function NC.ShowDifficultyStatus(text)
    if not NC.DifficultyFrame then return end
    NC.DifficultyLabel:SetText(text)
    NC.DifficultyFrame:SetHidden(false)
    zo_callLater(function() if NC.DifficultyFrame then NC.DifficultyFrame:SetHidden(true) end end, 10000)
end

function NC.UpdateFriendUI()
    if not NC.FriendNotificationFrame then return end
    local locked = NC.savedVars.friendNotificationLocked
    NC.FriendNotificationFrame:SetMovable(not locked)
    NC.FriendNotificationFrame:SetMouseEnabled(not locked)
    NC.FriendNotificationBG:SetCenterColor(0, 0, 0, locked and 0 or 0.5)
    if not locked then NC.FriendNotificationLabel:SetText("Перетащите плашку (Friend)!") end
end

local function CreateFriendNotificationUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("NecroCat_FriendFrame")
    frame:SetDimensions(500, 60)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NC.savedVars.friendNotificationLeft, NC.savedVars.friendNotificationTop)
    frame:SetClampedToScreen(true)
    frame:SetHidden(true)
    frame:SetHandler("OnMoveStop", function(self)
        NC.savedVars.friendNotificationLeft = self:GetLeft()
        NC.savedVars.friendNotificationTop = self:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl("NecroCat_FriendBG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl("NecroCat_FriendLabel", frame, CT_LABEL)
    label:SetAnchor(CENTER, frame, CENTER, 0, 0)
    label:SetFont("ZoFontWinH1")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    NC.FriendNotificationFrame = frame
    NC.FriendNotificationLabel = label
    NC.FriendNotificationBG    = bg
end

function NC.UpdateWhisperUI()
    if not NC.WhisperFrame then return end
    local locked = NC.savedVars.whisperLocked
    NC.WhisperFrame:SetMovable(not locked)
    NC.WhisperFrame:SetMouseEnabled(not locked)
    NC.WhisperFrame:SetHidden(locked)
    NC.WhisperBG:SetCenterColor(0, 0, 0, locked and 0 or 0.5)
    if not locked then NC.WhisperLabel:SetText("Перетащите плашку!") end
end

local function CreateWhisperUI()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("NecroCat_WhisperFrame")
    frame:SetDimensions(500, 60)
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, NC.savedVars.whisperLeft, NC.savedVars.whisperTop)
    frame:SetClampedToScreen(true)
    frame:SetHandler("OnMoveStop", function(self)
        NC.savedVars.whisperLeft = self:GetLeft()
        NC.savedVars.whisperTop = self:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl("NecroCat_WhisperBG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)

    local label = WINDOW_MANAGER:CreateControl("NecroCat_WhisperLabel", frame, CT_LABEL)
    label:SetAnchor(CENTER, frame, CENTER, 0, 0)
    label:SetFont("ZoFontWinH1")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    NC.WhisperFrame = frame
    NC.WhisperLabel = label
    NC.WhisperBG    = bg
end

local function UpdateCastleIconPosition(newCoord)
    NC.savedVars.vrxCoord = newCoord
    NC.CastleIcon:ClearAnchors()
    NC.CastleIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -newCoord, 10)
end

local function UpdateNoteIconPosition(newCoord)
    NC.savedVars.noteXCoord = newCoord
    NC.NoteIcon:ClearAnchors()
    NC.NoteIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -newCoord, 10)
end

function NC.OpenSettings()
    local LAM = LibAddonMenu2
    if LAM and NC.settingsPanel then
        LAM:OpenToPanel(NC.settingsPanel)
    end
end

local function InitializeMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type                = "panel",
        name                = "NecroCatMenu",
        displayName         = "|c66f2ffCastle of Necro cat|r",
        author              = NC.author,
        version             = NC.version,
        registerForDefaults = true,
    }

    -- Формируем список доступных гильдий для настроек
    local guildChoices = { "(По умолчанию)" }
    local guildValues = { 0 }
    for i = 1, GetNumGuilds() do
        local gid = GetGuildId(i)
        local name = GetGuildName(gid)
        table.insert(guildChoices, name)
        table.insert(guildValues, gid)
    end

    local optionsTable = {
        -- =====================================================
        -- 1. ПОДМЕНЮ: ГРУППА И FOLLOWME
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff1. Группа и FollowMe|r",
            tooltip = "Настройки интерфейса группы, автоприема данжей, рейдов и следования",
            controls = {
                { type = "header", name = "Отображение и поиск" },
                {
                    type = "checkbox",
                    name = "Показывать @ID вместо имен",
                    getFunc = function() return NC.savedVars.swapGroupNames end,
                    setFunc = function(v) 
                        NC.savedVars.swapGroupNames = v 
                        if GROUP_LIST then GROUP_LIST:RefreshData() end
                    end,
                },
                {
                    type = "checkbox",
                    name = "Group Finder: показывать все роли",
                    getFunc = function() return NC.savedVars.disableEnforceRole end,
                    setFunc = function(v) NC.savedVars.disableEnforceRole = v end,
                },

                { type = "header", name = "Автоматизация группы" },
                {
                    type = "checkbox",
                    name = "Кнопка 'Автоприем' в меню группы",
                    tooltip = "Показывать переключатель автоприема в левом нижнем углу меню группы (P)",
                    getFunc = function() return NC.savedVars.showAutoAcceptButton end,
                    setFunc = function(v) 
                        NC.savedVars.showAutoAcceptButton = v 
                        if NC.AutoAcceptDungeonCheck then 
                            NC.AutoAcceptDungeonCheck:SetHidden(not v) 
                        end
                    end,
                },
                {
                    type = "checkbox",
                    name = "Авто-перевод группы в рейд (5+ чел.)",
                    tooltip = "Автоматически преобразует группу в большую (рейд) при 5+ участниках и отключает окно с предупреждением",
                    getFunc = function() return NC.savedVars.autoConvertToRaid end,
                    setFunc = function(v) 
                        NC.savedVars.autoConvertToRaid = v 
                        if v and NC.CheckAutoConvertToRaid then 
                            NC.CheckAutoConvertToRaid() 
                        end
                    end,
                },
                {
                    type = "checkbox",
                    name = "Отключить диалог 'Прыжок к лидеру'",
                    tooltip = "Отключает экранное предложение переместиться к лидеру при вступлении в группу",
                    getFunc = function() return NC.savedVars.suppressJumpToLeader end,
                    setFunc = function(v) 
                        NC.savedVars.suppressJumpToLeader = v 
                        if NC.UpdateJumpToLeaderSuppression then 
                            NC.UpdateJumpToLeaderSuppression() 
                        end
                    end,
                },

                { type = "header", name = "Модуль FollowMe (Следование)" },
                {
                    type = "checkbox",
                    name = "Авто-прием телепорта",
                    getFunc = function() return NC.savedVars.followAutoAccept end,
                    setFunc = function(v) NC.savedVars.followAutoAccept = v end,
                },
                {
                    type = "checkbox",
                    name = "Видеть свои сигналы",
                    getFunc = function() return NC.savedVars.followShowOwn end,
                    setFunc = function(v) NC.savedVars.followShowOwn = v end,
                },
                {
                    type = "checkbox",
                    name = "Кнопка в чате",
                    getFunc = function() return NC.savedVars.followShowButton end,
                    setFunc = function(v) 
                        NC.savedVars.followShowButton = v
                        if NecroCat.Follow.ChatButton then NecroCat.Follow.ChatButton:SetHidden(not v) end
                    end,
                },
                {
                    type = "slider",
                    name = "Позиция кнопки (X)",
                    min = 0, max = 500,
                    getFunc = function() return NC.savedVars.followButtonX end,
                    setFunc = function(v) 
                        NC.savedVars.followButtonX = v 
                        if NecroCat.Follow.ChatButton then NecroCat.Follow.UpdateButtonPosition() end
                    end,
                },
                {
                    type = "button",
                    name = "Сбросить позицию кнопки",
                    func = function() NecroCat.Follow.ResetButtonPosition() end,
                },
            },
        },

        -- =====================================================
        -- 2. ПОДМЕНЮ: ГИЛЬДИИ
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff2. Гильдии|r",
            tooltip = "Настройки порядка гильдий, панели банка и кнопок гильдхолла",
            controls = {
                { type = "header", name = "Порядок гильдий в меню (1-5)" },
                {
                    type = "dropdown",
                    name = "1-е место в списке",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return (NC.savedVars.customGuildOrder and NC.savedVars.customGuildOrder[1]) or 0 end,
                    setFunc = function(v)
                        if not NC.savedVars.customGuildOrder then NC.savedVars.customGuildOrder = {} end
                        NC.savedVars.customGuildOrder[1] = v
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },
                {
                    type = "dropdown",
                    name = "2-е место в списке",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return (NC.savedVars.customGuildOrder and NC.savedVars.customGuildOrder[2]) or 0 end,
                    setFunc = function(v)
                        if not NC.savedVars.customGuildOrder then NC.savedVars.customGuildOrder = {} end
                        NC.savedVars.customGuildOrder[2] = v
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },
                {
                    type = "dropdown",
                    name = "3-е место в списке",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return (NC.savedVars.customGuildOrder and NC.savedVars.customGuildOrder[3]) or 0 end,
                    setFunc = function(v)
                        if not NC.savedVars.customGuildOrder then NC.savedVars.customGuildOrder = {} end
                        NC.savedVars.customGuildOrder[3] = v
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },
                {
                    type = "dropdown",
                    name = "4-е место в списке",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return (NC.savedVars.customGuildOrder and NC.savedVars.customGuildOrder[4]) or 0 end,
                    setFunc = function(v)
                        if not NC.savedVars.customGuildOrder then NC.savedVars.customGuildOrder = {} end
                        NC.savedVars.customGuildOrder[4] = v
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },
                {
                    type = "dropdown",
                    name = "5-е место в списке",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return (NC.savedVars.customGuildOrder and NC.savedVars.customGuildOrder[5]) or 0 end,
                    setFunc = function(v)
                        if not NC.savedVars.customGuildOrder then NC.savedVars.customGuildOrder = {} end
                        NC.savedVars.customGuildOrder[5] = v
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },
                {
                    type = "button",
                    name = "Сбросить порядок гильдий",
                    tooltip = "Возвращает стандартный порядок отображения всех гильдий",
                    func = function()
                        NC.savedVars.customGuildOrder = {}
                        if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then GUILD_SHARED_INFO:UpdateGuildSelector() end
                        if NC.UpdateGuildBankButtons then NC.UpdateGuildBankButtons() end
                    end,
                },

                { type = "header", name = "Банк Гильдий (Панель)" },
                {
                    type = "checkbox",
                    name = "Включить панель переключения",
                    getFunc = function() return NC.savedVars.guildBankEnabled end,
                    setFunc = function(v) 
                        NC.savedVars.guildBankEnabled = v
                        if NC.BankFrame then NC.BankFrame:SetHidden(not v) end
                    end,
                },
                {
                    type = "dropdown",
                    name = "Гильдия по умолчанию",
                    tooltip = "Гильдия, банк которой будет открываться автоматически при подходе к банкиру",
                    choices = guildChoices,
                    choicesValues = guildValues,
                    getFunc = function() return NC.savedVars.guildBankDefaultGuildId or 0 end,
                    setFunc = function(v) NC.savedVars.guildBankDefaultGuildId = v end,
                },

                { type = "header", name = "Отображение кнопок Гильдхолла" },
                {
                    type = "dropdown",
                    name = "Режим отображения кнопок",
                    tooltip = "Выберите, где показывать кнопки быстрого перемещения на экране гильдии",
                    choices = {"Показывать всегда", "Только в своей гильдии", "Скрыть полностью"},
                    choicesValues = {1, 2, 3},
                    getFunc = function() return NC.savedVars.guildHomeVisibility or 1 end,
                    setFunc = function(v) 
                        NC.savedVars.guildHomeVisibility = v 
                        if NC.UpdateGuildHomeVisibility then NC.UpdateGuildHomeVisibility() end
                    end,
                },
            },
        },

        -- =====================================================
        -- 3. ПОДМЕНЮ: ВЗАИМОДЕЙСТВИЕ (F)
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff3. Взаимодействие с игроками (F)|r",
            tooltip = "Скрытие лишних пунктов из радиального меню взаимодействия",
            controls = {
                {
                    type = "checkbox",
                    name = "Скрыть 'Исключить из группы'",
                    getFunc = function() return NC.savedVars.hideRemoveFromGroup end,
                    setFunc = function(v) NC.savedVars.hideRemoveFromGroup = v end,
                },
                {
                    type = "checkbox",
                    name = "Скрыть 'Добавить в друзья'",
                    getFunc = function() return NC.savedVars.hideAddFriend end,
                    setFunc = function(v) NC.savedVars.hideAddFriend = v end,
                },
                {
                    type = "checkbox",
                    name = "Скрыть 'Легенды о наградах' (Карты)",
                    tooltip = "Убирает приглашение в карточную игру из колеса взаимодействия (F)",
                    getFunc = function() return NC.savedVars.hideTributeInvite end,
                    setFunc = function(v) NC.savedVars.hideTributeInvite = v end,
                },
            },
        },

        -- =====================================================
        -- 4. ПОДМЕНЮ: ЧАТ И ИКОНКИ
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff4. Чат и Иконки|r",
            tooltip = "Настройки кнопок быстрого доступа у окна чата",
            controls = {
                {
                    type = "checkbox",
                    name = "Показывать иконку телепорта в дом",
                    getFunc = function() return NC.savedVars.showIcon end,
                    setFunc = function(v) NC.savedVars.showIcon = v NC.CastleIcon:SetHidden(not v) end,
                },
                {
                    type = "slider",
                    name = "Позиция иконки телепорта",
                    min = 0, max = 800,
                    getFunc = function() return NC.savedVars.vrxCoord end,
                    setFunc = function(v) UpdateCastleIconPosition(v) end,
                },
                {
                    type = "checkbox",
                    name = "Показывать блокнот (шепот себе)",
                    getFunc = function() return NC.savedVars.showNoteIcon end,
                    setFunc = function(v) 
                        NC.savedVars.showNoteIcon = v 
                        NC.NoteIcon:SetHidden(not v) 
                    end,
                },
                {
                    type = "slider",
                    name = "Позиция блокнота",
                    min = 0, max = 800,
                    getFunc = function() return NC.savedVars.noteXCoord end,
                    setFunc = function(v) UpdateNoteIconPosition(v) end,
                },
            },
        },
            
        -- =====================================================
        -- 5. ПОДМЕНЮ: УВЕДОМЛЕНИЯ И УДОБСТВА
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff5. Уведомления и Удобства|r",
            tooltip = "Оповещения о шепоте, входе друзей и автоматический телепорт через святилища",
            controls = {
                { type = "header", name = "Уведомления о личных сообщениях (шепот)" },
                {
                    type = "checkbox",
                    name = "Включить всплывающую плашку",
                    getFunc = function() return NC.savedVars.whisperAlert end,
                    setFunc = function(v) NC.savedVars.whisperAlert = v end,
                },
                {
                    type = "slider",
                    name = "Длительность показа (сек)",
                    min = 1, max = 60, step = 0.5, decimals = 1,
                    getFunc = function() return NC.savedVars.whisperDuration end,
                    setFunc = function(v) NC.savedVars.whisperDuration = v end,
                },
                {
                    type = "checkbox",
                    name = "Закрепить положение плашки",
                    getFunc = function() return NC.savedVars.whisperLocked end,
                    setFunc = function(v) 
                        NC.savedVars.whisperLocked = v 
                        NC.UpdateWhisperUI()
                    end,
                },

                { type = "header", name = "Уведомления о входе друзей" },
                {
                    type = "checkbox",
                    name = "Разблокировать окно уведомлений",
                    getFunc = function() return not NC.savedVars.friendNotificationLocked end,
                    setFunc = function(v) 
                        NC.savedVars.friendNotificationLocked = not v
                        NC.UpdateFriendUI()
                    end,
                },

                { type = "header", name = "Быстрое перемещение" },
                {
                    type = "checkbox",
                    name = "Телепортация без подтверждения",
                    tooltip = "Отключает диалог подтверждения при бесплатном перемещении через дорожное святилище (сразу начинает телепорт)",
                    getFunc = function() return NC.savedVars.fastTravelConfirm end,
                    setFunc = function(v) NC.savedVars.fastTravelConfirm = v end,
                },          
                {
                    type = "checkbox",
                    name = "Прятать небоевых питомцев в триалах",
                    getFunc = function() return NC.savedVars.dismissPetsInTrials end,
                    setFunc = function(v) 
                        NC.savedVars.dismissPetsInTrials = v 
                        if v and NC.CheckTrialPets then NC.CheckTrialPets() end
                    end,
                },
                { type = "header", name = "Изучение рецептов и стилей" },
                {
                    type = "checkbox",
                    name = "Показывать иконку изучения в инвентаре",
                    tooltip = "Отображает плавающую кнопку быстрого изучения рецептов при открытии рюкзака или банка",
                    getFunc = function() return NC.savedVars.showRecipeButton end,
                    setFunc = function(v) 
                        NC.savedVars.showRecipeButton = v 
                        if NC.UpdateRecipeButtonVisibility then NC.UpdateRecipeButtonVisibility() end
                    end,
                },
                {
                    type = "checkbox",
                    name = "Изучать ремесленные мотивы (стили крафта)",
                    tooltip = "Если включено, аддон будет также изучать неизвестные главы и книги мотивов",
                    getFunc = function() return NC.savedVars.includeMotifs end,
                    setFunc = function(v) NC.savedVars.includeMotifs = v end,
                },
                {
                    type = "checkbox",
                    name = "Изучать страницы стилей нарядов (маски, оружие)",
                    tooltip = "Если включено, аддон будет изучать неизвестные страницы масок монстров и ивентовых стилей",
                    getFunc = function() return NC.savedVars.includeStylePages end,
                    setFunc = function(v) NC.savedVars.includeStylePages = v end,
                },
                {
                    type = "button",
                    name = "Сбросить позицию иконки изучения",
                    func = function()
                        NC.savedVars.recipeButtonLeft = 400
                        NC.savedVars.recipeButtonTop = 300
                        if NC.RecipeFrame then
                            NC.RecipeFrame:ClearAnchors()
                            NC.RecipeFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 400, 300)
                        end
                    end,
                },
                { type = "header", name = "Цвет качества экипировки" },
                {
                    type = "checkbox",
                    name = "Цвет качества экипировки",
                    tooltip = "Отображает цветные платформы качества заточки предметов и точные проценты прочности и заряда",
                    getFunc = function() return NC.savedVars.showGearStatus end,
                    setFunc = function(v) 
                        NC.savedVars.showGearStatus = v 
                        if NC.UpdateAllCharacterGear then 
                            NC.UpdateAllCharacterGear() 
                        end
                    end,
                },
                { type = "header", name = "Авто-подтверждение действий" },
                {
                    type = "checkbox",
                    name = "Авто-вставка текста: Крафт и Заточка",
                    tooltip = "Автоматически подставляет проверочное слово ('ПОДТВЕРЖДАЮ' / 'CONFIRM') при зачаровании глифами и заточке заблокированных предметов.",
                    getFunc = function() return NC.savedVars.autoConfirmCrafting end,
                    setFunc = function(v) NC.savedVars.autoConfirmCrafting = v end,
                },
                {
                    type = "checkbox",
                    name = "Авто-вставка текста: Уничтожение предметов",
                    tooltip = "Автоматически подставляет проверочное слово ('ПОДТВЕРЖДАЮ' / 'CONFIRM') при уничтожении мифических предметов и кронных расходников из инвентаря. Удаление персонажей и писем по-прежнему строго защищено.",
                    getFunc = function() return NC.savedVars.autoConfirmDestroy end,
                    setFunc = function(v) NC.savedVars.autoConfirmDestroy = v end,
                },
            },
        },
        -- =====================================================
        -- 6. ПОДМЕНЮ: АВТО-ЗАРЯДКА И ПОЧИНКА
        -- =====================================================
        {
            type = "submenu",
            name = "|c66f2ff6. Авто-зарядка и Починка|r",
            tooltip = "Настройки автоматической зарядки оружия и ремонта снаряжения",
            controls = {
                { type = "header", name = "Авто-зарядка оружия" },
                {
                    type = "checkbox",
                    name = "Включить авто-зарядку",
                    tooltip = "Автоматически заряжает оружие камнем душ прямо в бою или исследовании мира при падении заряда ниже указанного порога",
                    getFunc = function() return NC.savedVars.autoRechargeEnabled end,
                    setFunc = function(v) NC.savedVars.autoRechargeEnabled = v end,
                },
                {
                    type = "slider",
                    name = "Порог заряда (%)",
                    tooltip = "Если заряд зачарования оружия упадет до этого значения или ниже — сработает зарядка",
                    min = 1, max = 100, step = 1,
                    getFunc = function() return NC.savedVars.autoRechargeThreshold end,
                    setFunc = function(v) NC.savedVars.autoRechargeThreshold = v end,
                },
                {
                    type = "dropdown",
                    name = "Приоритет камней душ",
                    tooltip = "Выберите, какие камни душ расходовать в первую очередь",
                    choices = {
                        "Только обычные камни душ",
                        "Сначала обычные -> затем кронные",
                        "Сначала кронные -> затем обычные",
                        "Только кронные камни душ",
                    },
                    choicesValues = { 1, 2, 3, 4 },
                    getFunc = function() return NC.savedVars.autoRechargePriority end,
                    setFunc = function(v) NC.savedVars.autoRechargePriority = v end,
                },

                { type = "header", name = "Авто-починка ремнаборами (в поле/бою)" },
                {
                    type = "checkbox",
                    name = "Включить починку ремнаборами",
                    tooltip = "Автоматически чинит конкретную поврежденную деталь брони походным ремнабором при падении прочности",
                    getFunc = function() return NC.savedVars.autoRepairKitsEnabled end,
                    setFunc = function(v) NC.savedVars.autoRepairKitsEnabled = v end,
                },
                {
                    type = "slider",
                    name = "Порог прочности (%)",
                    tooltip = "Если прочность надетого элемента брони упадет до этого значения или ниже — сработает ремонт",
                    min = 1, max = 100, step = 1,
                    getFunc = function() return NC.savedVars.autoRepairKitsThreshold end,
                    setFunc = function(v) NC.savedVars.autoRepairKitsThreshold = v end,
                },
                {
                    type = "dropdown",
                    name = "Приоритет ремнаборов",
                    tooltip = "Выберите, какие ремнаборы расходовать в первую очередь",
                    choices = {
                        "Только обычные ремнаборы",
                        "Сначала обычные -> затем кронные",
                        "Сначала кронные -> затем обычные",
                        "Только кронные ремнаборы",
                    },
                    choicesValues = { 1, 2, 3, 4 },
                    getFunc = function() return NC.savedVars.autoRepairKitsPriority end,
                    setFunc = function(v) NC.savedVars.autoRepairKitsPriority = v end,
                },

                { type = "header", name = "Починка у торговца" },
                {
                    type = "checkbox",
                    name = "Авто-починка за золото у торговца",
                    tooltip = "При открытии любого магазина торговца автоматически чинит все снаряжение за золото, чтобы экономить походные ремнаборы",
                    getFunc = function() return NC.savedVars.autoVendorRepairEnabled end,
                    setFunc = function(v) NC.savedVars.autoVendorRepairEnabled = v end,
                },
            },
        },
    }

    NC.settingsPanel = LAM:RegisterAddonPanel("NecroCatMenu", panelData)
    LAM:RegisterOptionControls("NecroCatMenu", optionsTable)
end

---------------------------------------------------------
-- 5. ИНВАЙТ И МЕНЮ
---------------------------------------------------------


local function TryTeleportToPlayer(displayName)
    if not displayName or displayName == "" then return end


    if IsFriend(displayName) then
        JumpToFriend(displayName)
        d("|c66f2ff[NecroCat]|r Прыжок к другу: " .. displayName)
        return
    end

    local foundInGroup = false
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(unitTag) == displayName then
            JumpToGroupMember(unitTag)
            d("|c66f2ff[NecroCat]|r Прыжок к согруппнику: " .. displayName)
            foundInGroup = true
            break
        end
    end
    
    if foundInGroup then return end

    d("|cFF0000[NecroCat]|r Телепорт к " .. displayName .. " невозможен (не друг и не в группе).")
end

-- =========================================================
-- КОПИРОВАНИЕ ID И ХУК ЧАТА
-- =========================================================

-- Функция копирования через игровой чат
function NC.ShowCopyDialog(textToCopy)
    StartChatInput(textToCopy) -- Открывает чат и вставляет ник
    if ZO_ChatWindowTextEntryEditBox then
        ZO_ChatWindowTextEntryEditBox:SelectAll() -- Выделяет ник синим цветом
        ZO_ChatWindowTextEntryEditBox:TakeFocus() -- Переводит клавиатуру на чат
    end
end

-- Хук для клика по нику в чате
local function HookChatContextMenu()
    ZO_PreHook("ZO_ChatSystem_ShowGameplayContextMenu", function(link)
        if not LibCustomMenu then return end -- Безопасность: если библиотеки нет, просто ничего не делаем и не ломаем игру
        local linkType, displayName = ZO_LinkHandler_ParseLink(link)
        if linkType == "player" and displayName then
            AddCustomMenuItem("|c22ff22Скопировать @ID|r", function()
                NC.ShowCopyDialog(displayName)
            end)
        end
    end)
end


-- Финальная функция меню NecroCat с каскадным меню первого уровня
local function AddNecroMenuEntries(data)
    local displayName = data.displayName
    if not displayName then return end

    -- 1. Пункт Копирования @ID (на главном уровне контекстного меню)
    AddCustomMenuItem("|c22ff22Скопировать @ID|r", function()
        NC.ShowCopyDialog(displayName)
    end)

    -- 2. Пункт Телепорта (на главном уровне контекстного меню)
    AddCustomMenuItem("|cff6401Телепорт к игроку|r", function() 
        TryTeleportToPlayer(displayName)
    end)
    
    -- 3. Пункт Инвайта (на главном уровне контекстного меню)
    AddCustomMenuItem("|c66f2ffInvite to Party|r", function() 
        if GroupInviteByName then GroupInviteByName(displayName) end 
    end)
    
    -- СОБИРАЕМ ВЫЕЗЖАЮЩЕЕ ПОДМЕНЮ ДЛЯ ПУНКТА "NecroCat"
    if not NecroCat.savedVars.trackedPlayers then NecroCat.savedVars.trackedPlayers = {} end
    local isTracked = NecroCat.savedVars.trackedPlayers[displayName]

    local necroCatSubMenu = {
        -- Опция 1: Включение/выключение отслеживания (Tracking)
        {
            label = isTracked and "|cFF5555Disable Tracking|r" or "|c55FF55Enable Tracking|r",
            callback = function()
                if isTracked then
                    NecroCat.savedVars.trackedPlayers[displayName] = nil
                    d(string.format("[NecroCat] Отслеживание %s отключено.", displayName))
                else
                    NecroCat.savedVars.trackedPlayers[displayName] = true
                    d(string.format("[NecroCat] Отслеживание %s включено.", displayName))
                end
            end
        },
        -- Опция 2: Подготовка команды ЗАКРЕПЛЕНИЯ в чат
        {
            label = "|cffff22Закрепить друга (в чат)|r",
            callback = function()
                -- Вычисляем следующий свободный номер приоритета
                local nextNum = 1
                if NC.savedVars and NC.savedVars.pinned then
                    for name, priority in pairs(NC.savedVars.pinned) do
                        if priority >= nextNum then
                            nextNum = priority + 1
                        end
                    end
                end
                -- Пишем шаблон в чат
                StartChatInput(string.format("/pinfriend %s %d", displayName, nextNum))
            end
        },
        -- Опция 3: Подготовка команды ОТКРЕПЛЕНИЯ в чат
        {
            label = "|cff5555Открепить друга (в чат)|r",
            callback = function()
                -- Пишем шаблон в чат
                StartChatInput(string.format("/unpinfriend %s", displayName))
            end
        },
        -- Опция 4: Показать текущий список закрепленных
        {
            label = "Показать список",
            callback = function()
                SLASH_COMMANDS["/listpinned"]() -- Напрямую запускаем показ списка в чат
            end
        },
        -- Опция 5: Очистить список закреплений
        {
            label = "Очистить весь список",
            callback = function()
                SLASH_COMMANDS["/pinclear"]() -- Напрямую сбрасываем список
            end
        }
    }

    -- Добавляем красивую выезжающую строчку "NecroCat"
    AddCustomSubMenuItem("|c66f2ffNecroCat|r", necroCatSubMenu)
end

local function HookFriendsAndGuildMenu()
    if not LibCustomMenu then return end
    
    local function AddCustomItems(data)
        AddNecroMenuEntries(data)
    end
    
    LibCustomMenu:RegisterFriendsListContextMenu(AddCustomItems, LibCustomMenu.CATEGORY_LATE)
    LibCustomMenu:RegisterGuildRosterContextMenu(AddCustomItems, LibCustomMenu.CATEGORY_LATE)
end

-- Хук для перекраски пунктов стандартных контекстных меню
function NC.HookMenuColors()
    local origAddMenuItem = AddMenuItem
    if not origAddMenuItem then return end

    AddMenuItem = function(text, callback, itemType, font, normalColor, highlightColor, item)
        if text and type(text) == "string" and not string.find(text, "^|c") then
            local inGroupScene = SCENE_MANAGER and (SCENE_MANAGER:IsShowing("groupMenuKeyboard") or SCENE_MANAGER:IsShowing("groupList"))

            -- 1. Золотой: Сделать лидером
            if (SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER and text == GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER))
               or string.find(text, "Сделать лидером")
               or string.find(text, "Promote to Leader") then
                text = "|cFFD700" .. text .. "|r"

            -- 2. Красный: Исключить из группы, Голосование за исключение
            elseif (SI_GROUP_LIST_MENU_KICK_FROM_GROUP and text == GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP))
               or (SI_GROUP_LIST_MENU_VOTE_KICK_FROM_GROUP and text == GetString(SI_GROUP_LIST_MENU_VOTE_KICK_FROM_GROUP))
               or string.find(text, "Исключить")
               or string.find(text, "Голосовать за исключение")
               or string.find(text, "Remove from Group")
               or string.find(text, "Vote to Kick") then
                text = "|cFF4444" .. text .. "|r"

            -- 3. Синий: Покинуть группу, Распустить группу
            elseif (SI_GROUP_LIST_MENU_LEAVE_GROUP and text == GetString(SI_GROUP_LIST_MENU_LEAVE_GROUP))
               or (SI_GROUP_LIST_MENU_DISBAND_GROUP and text == GetString(SI_GROUP_LIST_MENU_DISBAND_GROUP))
               or string.find(text, "Покинуть группу")
               or string.find(text, "Распустить группу")
               or string.find(text, "Leave Group")
               or string.find(text, "Disband") then
                text = "|c55AAFF" .. text .. "|r"

            -- 4. Синий: Переместиться к игроку (ТОЛЬКО в группе / на плашках группы)
            elseif (SI_GROUP_LIST_MENU_JUMP_TO_MEMBER and text == GetString(SI_GROUP_LIST_MENU_JUMP_TO_MEMBER))
               or (inGroupScene and (string.find(text, "Переместиться") or string.find(text, "Travel to") or string.find(text, "Jump to")))
               or string.find(text, "согруппнику")
               or string.find(text, "Group Member") then
                text = "|c55AAFF" .. text .. "|r"

            -- 5. Зеленый: Пригласить в группу (везде)
            elseif (SI_GROUP_LIST_MENU_INVITE_TO_GROUP and text == GetString(SI_GROUP_LIST_MENU_INVITE_TO_GROUP))
               or (SI_FRIENDS_LIST_MENU_INVITE_TO_GROUP and text == GetString(SI_FRIENDS_LIST_MENU_INVITE_TO_GROUP))
               or (SI_CHAT_PLAYER_CONTEXT_INVITE_TO_GROUP and text == GetString(SI_CHAT_PLAYER_CONTEXT_INVITE_TO_GROUP))
               or string.find(text, "Пригласить в группу")
               or string.find(text, "Invite to Group") then
                text = "|c22FF22" .. text .. "|r"
            end
        end

        return origAddMenuItem(text, callback, itemType, font, normalColor, highlightColor, item)
    end
    
    ZO_Menu_AddMenuItem = AddMenuItem
end

---------------------------------------------------------
-- 6. ЗАГРУЗКА
---------------------------------------------------------

function NC.OnAddOnLoaded(eventCode, addOnName)
    if not addOnName or string.lower(addOnName) ~= string.lower(NC.name) then return end

    NC.savedVars = ZO_SavedVars:NewAccountWide("NecroCat_SV", 1, nil, {
        vrxCoord        = 136,
        noteXCoord      = 170,
        showIcon        = true,
        showNoteIcon    = false,
        guildHomeVisibility = 1,
        pinned          = {},
        whisperAlert    = false,
        whisperLocked   = true,
        whisperLeft     = 500,
        whisperTop      = 300,
        whisperDuration = 3.5,
        firstLoad       = true,
        disableEnforceRole = true,
        swapGroupNames  = false,
        hideRemoveFromGroup = false,
        hideAddFriend       = false,
        hideTributeInvite   = false,
        trackedPlayers           = {},
        friendNotificationLeft   = 500,
        friendNotificationTop    = 200,
        friendNotificationLocked = true,
        followAutoAccept = false,
        followShowOwn = false,
        followShowButton = true,
        followButtonX = 177,
        followDialogLeft = 500,
        followDialogTop = 300,
        followAutoPrepare = false,
        guildBankEnabled = false,
        guildBankLeft = 500,
        guildBankTop = 300,
        customGuildOrder = {},
        guildBankDefaultGuildId = 0,
        autoAcceptDungeon = false,
        showAutoAcceptButton = false,
        autoConvertToRaid    = false,
        suppressJumpToLeader = false,
        fastTravelConfirm    = false,
        dismissPetsInTrials  = false,
        storedPetId          = 0,
        autoConfirmCrafting  = false,
        autoConfirmDestroy   = false,
        showRecipeButton     = true,
        recipeButtonLeft     = 400,
        recipeButtonTop      = 300,
        includeMotifs        = true,
        includeStylePages    = true,
        -- Smart Auto-Recharge & Auto-Repair
        autoRechargeEnabled     = true,
        autoRechargeThreshold   = 20,
        autoRechargePriority    = 2, -- 1: Только обычные, 2: Обычные -> Кронные, 3: Кронные -> Обычные, 4: Только кронные
        
        autoRepairKitsEnabled   = true,
        autoRepairKitsThreshold = 20,
        autoRepairKitsPriority  = 2, -- 1: Только обычные, 2: Обычные -> Кронные, 3: Кронные -> Обычные, 4: Только кронные
        
        autoVendorRepairEnabled = true,
        showGearStatus          = false,
    }, GetWorldName())
    -- Бесшовная миграция старой настройки банка со слота на ID
    if (not NC.savedVars.guildBankDefaultGuildId or NC.savedVars.guildBankDefaultGuildId == 0) and NC.savedVars.guildBankDefaultIndex and NC.savedVars.guildBankDefaultIndex > 0 then
        NC.savedVars.guildBankDefaultGuildId = GetGuildId(NC.savedVars.guildBankDefaultIndex)
    end

    if NC.savedVars.firstLoad then
        NC.savedVars.firstLoad = false
        NC.savedVars.vrxCoord = 136
    end

    NC.CastleIcon = WINDOW_MANAGER:CreateControl("NecroCatGuildHall", ZO_ChatWindow, CT_BUTTON)
    NC.CastleIcon:SetDimensions(25, 25)
    NC.CastleIcon:SetNormalTexture("NecroCat/imgs/CastleofNecroCat.dds")
    NC.CastleIcon:SetHidden(not NC.savedVars.showIcon)
    NC.CastleIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -NC.savedVars.vrxCoord, 10)
    NC.CastleIcon:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside then return end
        if button == MOUSE_BUTTON_INDEX_LEFT then
            NC.CastleHall()
        elseif button == MOUSE_BUTTON_INDEX_RIGHT then
            NC.OpenSettings()
        end
    end)
    NC.CastleIcon:SetHandler("OnMouseEnter", function(ctrl)
        InitializeTooltip(InformationTooltip, ctrl, TOP, 0, 5)
        InformationTooltip:AddLine("|c66f2ffNecro cat's Guildhall|r", "ZoFontWinH4")
        InformationTooltip:AddLine("|c00FF00ЛКМ:|r Телепорт в гильдхолл", "ZoFontGameSmall")
        InformationTooltip:AddLine("|c66f2ffПКМ:|r Настройки аддона", "ZoFontGameSmall")
    end)
    NC.CastleIcon:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    
    NC.NoteIcon = WINDOW_MANAGER:CreateControl("NecroCatSelfWhisper", ZO_ChatWindow, CT_BUTTON)
    NC.NoteIcon:SetDimensions(25, 25)
    NC.NoteIcon:SetNormalTexture("EsoUI/Art/MainMenu/menuBar_journal_up.dds")
    NC.NoteIcon:SetHidden(not NC.savedVars.showNoteIcon)
    NC.NoteIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -NC.savedVars.noteXCoord, 10)
    NC.NoteIcon:SetHandler("OnClicked", NC.SelfWhisper)
    NC.NoteIcon:SetHandler("OnMouseEnter", function(ctrl)
        InitializeTooltip(InformationTooltip, ctrl, TOP, 0, 5)
        SetTooltipText(InformationTooltip, "|c66f2ffНаписать себе в личку|r")
    end)
    NC.NoteIcon:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    
    NC.isReady = false
    zo_callLater(function() NC.isReady = true end, 5000) 
    
    if GROUP_LIST then
        ZO_PostHook(GROUP_LIST, "SetupGroupEntry", NC_GroupEntryHook)
    end

    ZO_PreHook(GROUP_FINDER_SEARCH_MANAGER, 'ExecuteSearch', function()
        if NC.savedVars.disableEnforceRole then
            SetGroupFinderFilterEnforceRoles(false)
        end
    end)

    NC_InitInteractionFix()
    NC.UpdateJumpToLeaderSuppression()
    
    -- Безопасные вызовы хуков
    if HookFriendsAndGuildMenu then HookFriendsAndGuildMenu() end
    NC.HookFriendsSorting()
    NC.HookGuildSelector()
    NC.HookMenuColors()
    
    CreateWhisperUI()
    NC.UpdateWhisperUI()
    CreateFriendNotificationUI()
    NC.UpdateFriendUI()
    NC.CreateDifficultyUI()
    NC.CreateGuildBankUI()
    NC.CreateRecipeLearnerUI()
    NC.CreateGroupMenuAutoAcceptUI()
    
-- Сцена банка гильдии
    local bankScene = SCENE_MANAGER:GetScene("guildBank")
    
    local function AutoSelectDefaultGuildBank()
        local gid = NC.savedVars.guildBankDefaultGuildId
        if gid and gid > 0 then
            zo_callLater(function()
                ZO_SharedInventory_SelectAccessibleGuildBank(gid)
            end, 200)
        end
    end

    bankScene:RegisterCallback("StateChange", function(oldState, newState)
        if not NC.savedVars.guildBankEnabled then return end
        
        if newState == SCENE_SHOWING then
            NC.BankFrame:SetHidden(false)
            AutoSelectDefaultGuildBank()
        elseif newState == SCENE_HIDING then
            NC.BankFrame:SetHidden(true)
        end
    end)

    -- Проверка при старте (если мы уже в банке)
    if bankScene:GetState() == SCENE_SHOWING and NC.savedVars.guildBankEnabled then
        NC.BankFrame:SetHidden(false)
        AutoSelectDefaultGuildBank()
    else
        NC.BankFrame:SetHidden(true)
    end


    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_CHAT_MESSAGE_CHANNEL, NC.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, NC.OnActivityFinderStatusUpdate)
    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_PLAYER_ACTIVATED, function()
        NC.CheckTrialPets()
    end)
    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_GROUP_MEMBER_JOINED, function()
        NC.CheckAutoConvertToRaid()
    end)
    HookDialogSuppressions()
    
    -- Подключение модуля отображения качества и прочности экипировки
    NC.InitCharacterGearUI()

    -- Авто-обновление при ЛЮБОМ открытии окна персонажа (C)
    if ZO_Character then
        ZO_PostHookHandler(ZO_Character, "OnEffectivelyShown", function()
            if NC.UpdateAllCharacterGear then
                NC.UpdateAllCharacterGear()
            end
        end)
    end

    -- Обновление при смене сборки в оружейной
    EVENT_MANAGER:RegisterForEvent(NC.name .. "_Armory", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function()
        if NC.UpdateAllCharacterGear then
            NC.UpdateAllCharacterGear()
        end
    end)
    
    -- Регистрация авто-починки у торговца
    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_OPEN_STORE, NC.OnOpenStore)

    -- Регистрация проверки надетого снаряжения со строгим фильтром BAG_WORN (надетые вещи)
    EVENT_MANAGER:RegisterForEvent(NC.name .. "_WornSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, NC.OnWornSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(NC.name .. "_WornSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    
    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(eventCode, displayName, characterName, oldStatus, newStatus)
        if NC.isReady and newStatus == PLAYER_STATUS_ONLINE and NC.savedVars.trackedPlayers[displayName] then
            NC.ShowFriendNotification(displayName)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(eventCode, guildId, displayName, characterName, oldStatus, newStatus)
        if NC.isReady and newStatus == PLAYER_STATUS_ONLINE and NC.savedVars.trackedPlayers[displayName] then
            NC.ShowFriendNotification(displayName)
        end
    end)

-- Запуск хука для чата
    HookChatContextMenu()

    InitializeMenu()
    NecroCat.Follow.Init()
    
    EVENT_MANAGER:UnregisterForEvent(NC.name, EVENT_ADD_ON_LOADED)
end

---------------------------------------------------------
-- 7. УПРАВЛЕНИЕ СЛОЖНОСТЬЮ
---------------------------------------------------------

NC.lastDifficultySwitchTime = 0

function NC.SetDifficulty(difficultyType)
    local reason = GetOverlandDifficultyDisabledReason()
    
    if reason ~= OVERLAND_DIFFICULTY_DISABLED_REASON_NONE then
        d("|cFF0000[NecroCat]|r Невозможно сменить сложность. Причина: " .. tostring(reason))
        return
    end

    local now = GetFrameTimeSeconds()
    if (now - NC.lastDifficultySwitchTime) < 10 then
        local remaining = math.ceil(10 - (now - NC.lastDifficultySwitchTime))
        NC.ShowDifficultyStatus("Подождите еще " .. remaining .. " сек.")
        return
    end

    NC.lastDifficultySwitchTime = now
    RequestChangePlayerOverlandDifficulty(difficultyType)
    NC.ShowDifficultyStatus("Сложность изменена!")
end

function NC.SetDiffAdventurer() NC.SetDifficulty(OVERLAND_DIFFICULTY_TYPE_ADVENTURER) end
function NC.SetDiffBasegame()   NC.SetDifficulty(OVERLAND_DIFFICULTY_TYPE_BASEGAME) end
function NC.SetDiffJourneyman() NC.SetDifficulty(OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN) end
function NC.SetDiffVeteran()    NC.SetDifficulty(OVERLAND_DIFFICULTY_TYPE_VETERAN) end

EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_ADD_ON_LOADED, NC.OnAddOnLoaded)

-- =========================================================
-- ЛОГИКА СОРТИРОВКИ ГИЛЬДИЙ
-- =========================================================

function NC.GetSortedGuildList()
    local guildList = {}
    local assignedGids = {}
    local numGuilds = GetNumGuilds()

    -- 1. Сначала берем гильдии из настроенных слотов 1..5
    if NC.savedVars.customGuildOrder then
        for slot = 1, 5 do
            local targetGid = NC.savedVars.customGuildOrder[slot]
            if targetGid and targetGid > 0 then
                for i = 1, numGuilds do
                    local gid = GetGuildId(i)
                    if gid == targetGid and not assignedGids[gid] then
                        table.insert(guildList, {
                            guildId    = gid,
                            guildIndex = i,
                            guildName  = GetGuildName(gid),
                            slot       = slot,
                        })
                        assignedGids[gid] = true
                        break
                    end
                end
            end
        end
    end

    -- 2. Все остальные гильдии добавляем следом в их обычном порядке
    for i = 1, numGuilds do
        local gid = GetGuildId(i)
        if not assignedGids[gid] then
            table.insert(guildList, {
                guildId    = gid,
                guildIndex = i,
                guildName  = GetGuildName(gid),
                slot       = nil,
            })
        end
    end

    return guildList
end

-- Функция перехвата и сортировки выпадающего списка гильдий
function NC.HookGuildSelector()
    if not ZO_GuildSelectorComboBox then return end
    local cb = ZO_ComboBox_ObjectFromContainer(ZO_GuildSelectorComboBox)
    if not cb then return end

    ZO_PreHook(cb, "ShowDropdown", function(self)
        if not NC.savedVars.customGuildOrder then return end

        local sortedGuilds = NC.GetSortedGuildList()
        if #sortedGuilds == 0 then return end

        local guildEntries = {}
        local otherEntries = {}

        -- Разделяем гильдии и служебные пункты (Поиск/Создание)
        for _, entry in ipairs(self.m_sortedItems or {}) do
            local isGuild = false
            for _, gData in ipairs(sortedGuilds) do
                if (entry.guildId and entry.guildId == gData.guildId) or (entry.name and string.find(entry.name, gData.guildName, 1, true)) then
                    entry.ncGuildId = gData.guildId
                    table.insert(guildEntries, entry)
                    isGuild = true
                    break
                end
            end
            if not isGuild then
                table.insert(otherEntries, entry)
            end
        end

        -- Сортируем гильдии в порядке из наших настроек
        local orderMap = {}
        for index, gData in ipairs(sortedGuilds) do
            orderMap[gData.guildId] = index
        end

        table.sort(guildEntries, function(a, b)
            local orderA = orderMap[a.ncGuildId] or 99
            local orderB = orderMap[b.ncGuildId] or 99
            return orderA < orderB
        end)

        -- Собираем итоговый правильный список
        local newItems = {}
        for _, entry in ipairs(guildEntries) do
            table.insert(newItems, entry)
        end
        for _, entry in ipairs(otherEntries) do
            table.insert(newItems, entry)
        end

        self.m_sortedItems = newItems
    end)
end

-- =========================================================
-- ЛОГИКА ЗАКРЕПЛЕНИЯ ДРУЗЕЙ (МЫ ПЕРЕНЕСЛИ ЕЁ СЮДА!)
-- =========================================================

-- Функция для закрепления со сдвигом
function NC.PinAndShift(targetName, targetPriority)
    NC.savedVars.pinned[targetName] = nil

    for name, priority in pairs(NC.savedVars.pinned) do
        if priority >= targetPriority then
            NC.savedVars.pinned[name] = priority + 1
        end
    end

    NC.savedVars.pinned[targetName] = targetPriority

    local tempArray = {}
    for name, priority in pairs(NC.savedVars.pinned) do
        table.insert(tempArray, { name = name, priority = priority })
    end

    table.sort(tempArray, function(a, b)
        return a.priority < b.priority
    end)

    NC.savedVars.pinned = {}
    for index, item in ipairs(tempArray) do
        NC.savedVars.pinned[item.name] = index
    end
end

-- Функция для открепления со схлопыванием
function NC.UnpinAndNormalize(targetName)
    NC.savedVars.pinned[targetName] = nil

    local tempArray = {}
    for name, priority in pairs(NC.savedVars.pinned) do
        table.insert(tempArray, { name = name, priority = priority })
    end

    table.sort(tempArray, function(a, b)
        return a.priority < b.priority
    end)

    NC.savedVars.pinned = {}
    for index, item in ipairs(tempArray) do
        NC.savedVars.pinned[item.name] = index
    end
end

-- Функция сортировки в интерфейсе списка друзей
function NC.HookFriendsSorting()
    if not FRIENDS_LIST then return end

    local originalSortFunction = FRIENDS_LIST.sortFunction
    if not originalSortFunction then return end

    FRIENDS_LIST.sortFunction = function(listEntry1, listEntry2)
        if listEntry1 and listEntry2 and listEntry1.data and listEntry2.data then
            local data1 = listEntry1.data
            local data2 = listEntry2.data

            local name1 = data1.displayName
            local name2 = data2.displayName

            if name1 and name2 then
                local priority1 = NC.savedVars.pinned[name1]
                local priority2 = NC.savedVars.pinned[name2]

                if priority1 and not priority2 then
                    return true
                elseif not priority1 and priority2 then
                    return false
                elseif priority1 and priority2 then
                    if priority1 ~= priority2 then
                        return priority1 < priority2
                    else
                        return name1 < name2
                    end
                end
            end
        end

        return originalSortFunction(listEntry1, listEntry2)
    end
end

-- =========================================================
-- КОМАНДЫ УПРАВЛЕНИЯ В ЧАТЕ
-- =========================================================

SLASH_COMMANDS["/pinfriend"] = function(argStr)
    local displayName, priorityStr = string.match(argStr, "^(%S+)%s*(%d*)$")
    local priority = tonumber(priorityStr) or 1

    if not displayName or displayName == "" then
        d("[NecroCat] Использование: /pinfriend @ИмяДруга Позиция")
        return
    end

    NC.PinAndShift(displayName, priority)
    d(string.format("[NecroCat] %s теперь на позиции %d! Остальные сдвинулись.", displayName, priority))

    FRIENDS_LIST:RefreshData()
end

SLASH_COMMANDS["/unpinfriend"] = function(displayName)
    if not displayName or displayName == "" then
        d("[NecroCat] Использование: /unpinfriend @ИмяДруга")
        return
    end

    if NC.savedVars.pinned[displayName] then
        NC.UnpinAndNormalize(displayName)
        d(string.format("[NecroCat] Друг %s удален, позиции остальных скорректированы.", displayName))
        FRIENDS_LIST:RefreshData()
    else
        d(string.format("[NecroCat] Друг %s не найден в закрепленных.", displayName))
    end
end

SLASH_COMMANDS["/listpinned"] = function()
    local sortedList = {}
    for name, priority in pairs(NC.savedVars.pinned) do
        table.insert(sortedList, { name = name, priority = priority })
    end

    if #sortedList == 0 then
        d("[NecroCat] Список закрепленных пуст.")
        return
    end

    table.sort(sortedList, function(a, b)
        return a.priority < b.priority
    end)

    d("[NecroCat] Текущая очередь закреплений:")
    for index, item in ipairs(sortedList) do
        d(string.format(" %d. %s", index, item.name))
    end
end

SLASH_COMMANDS["/pinclear"] = function()
    for name in pairs(NC.savedVars.pinned) do
        NC.savedVars.pinned[name] = nil
    end
    d("[NecroCat] Список друзей полностью очищен!")
    if FRIENDS_LIST then FRIENDS_LIST:RefreshData() end
end

SLASH_COMMANDS["/guildsclear"] = function()
    NC.savedVars.customGuildOrder = {}
    d("[NecroCat] Порядок всех гильдий сброшен на стандартный!")
    if GUILD_SHARED_INFO and GUILD_SHARED_INFO.UpdateGuildSelector then
        GUILD_SHARED_INFO:UpdateGuildSelector()
    end
end

SLASH_COMMANDS["/necrocat"] = function() NC.OpenSettings() end
SLASH_COMMANDS["/nc"]       = function() NC.OpenSettings() end
-- =========================================================
-- СПРАВОЧНАЯ КОМАНДА NECROCAT
-- =========================================================

SLASH_COMMANDS["/necrohelp"] = function()
    d("|c66f2ff[NecroCat] Справка по командам аддона:|r")
    d("|cffff22Друзья:|r")
    d("  |c22ff22/pinfriend @Имя [Позиция]|r - Закрепить друга со сдвигом остальных.")
    d("  |c22ff22/unpinfriend @Имя|r - Убрать друга из закрепленных.")
    d("  |c22ff22/listpinned|r - Показать очередь друзей.")
    d("  |c22ff22/pinclear|r - Сбросить закрепления друзей.")
    d("|cffff22Гильдии:|r")
    d("  Настройка порядка: |c22ff22Настройки -> Дополнения -> Castle of Necro cat|r")
    d("  |c22ff22/guildsclear|r - Быстрый сброс порядка гильдий на стандартный.")
end