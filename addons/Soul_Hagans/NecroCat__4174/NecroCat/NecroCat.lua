-- Главная таблица аддона
NecroCat = NecroCat or {
    name    = "NecroCat",
    author  = "Soul_Hagans",
    version = "1.9.1",
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

---------------------------------------------------------
-- 2. ЛОГИКА ГРУППЫ (ИНВЕРСИЯ ИМЕН И @ID)
---------------------------------------------------------

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
    local originalAddMenuEntry = PLAYER_TO_PLAYER.AddMenuEntry
    
    PLAYER_TO_PLAYER.AddMenuEntry = function(self, text, ...)
        if NC.savedVars.hideRemoveFromGroup and text == GetString(SI_PLAYER_TO_PLAYER_REMOVE_GROUP) then
            return 
        end
        if NC.savedVars.hideAddFriend and text == GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND) then
            return 
        end
        return originalAddMenuEntry(self, text, ...)
    end
end

---------------------------------------------------------
-- 4. РАБОТА С UI И МЕНЮ
---------------------------------------------------------

NC.GuildIcons = {
    [839248] = "NecroCat/imgs/CastleofNecroCat.dds",
    [698160] = "NecroCat/imgs/garden.dds",
}

-- [NEW MODULE] Guild Bank Switcher UI
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

    -- Dynamic Buttons
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local btn = WINDOW_MANAGER:CreateControl("NecroCat_BankBtn" .. i, frame, CT_BUTTON)
        btn:SetDimensions(30, 30)
        btn:SetAnchor(LEFT, frame, LEFT, 5 + ((i - 1) * 35), 0)
        
        local gid = GetGuildId(i)
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
            local _, name = GetGuildName(gid)
            InitializeTooltip(InformationTooltip, ctrl, TOP, 0, 5)
            SetTooltipText(InformationTooltip, name)
        end)
        
        btn:SetHandler("OnMouseExit", function() 
            ClearTooltip(InformationTooltip) 
        end)
    end
    
    frame:SetWidth(10 + (numGuilds * 35))
    NC.BankFrame = frame
end -- ВОТ ЭТОТ END БЫЛ ПОТЕРЯН!

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
    NC.CastleIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -newCoord, 10)
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

    local optionsTable = {
        { type = "header", name = "Интерфейс Группы (P)" },
        {
            type = "checkbox",
            name = "Показывать @ID вместо имен",
            getFunc = function() return NC.savedVars.swapGroupNames end,
            setFunc = function(v) 
                NC.savedVars.swapGroupNames = v 
                if GROUP_LIST then GROUP_LIST:RefreshData() end
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
            choices = {"Выкл", "1", "2", "3", "4", "5"},
            choicesValues = {0, 1, 2, 3, 4, 5}, -- 0 - это выкл, 1-5 - гильдии
            getFunc = function() return NC.savedVars.guildBankDefaultIndex or 0 end,
            setFunc = function(v) NC.savedVars.guildBankDefaultIndex = v end,
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
                -- Если окно гильдии сейчас открыто, мы сразу обновим видимость кнопок
                if ZO_GuildHome_NecroCat_UpdateVisibility then 
                    ZO_GuildHome_NecroCat_UpdateVisibility() 
                end
            end,
        },
        { type = "header", name = "Взаимодействие (F)" },
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
        { type = "header", name = "Уведомления о друзьях" },
        {
            type = "checkbox",
            name = "Разблокировать окно уведомлений",
            getFunc = function() return not NC.savedVars.friendNotificationLocked end,
            setFunc = function(v) 
                NC.savedVars.friendNotificationLocked = not v
                NC.UpdateFriendUI()
            end,
        },
        { type = "header", name = "Прочее" },
        {
            type = "checkbox",
            name = "Group Finder: показывать все роли",
            getFunc = function() return NC.savedVars.disableEnforceRole end,
            setFunc = function(v) NC.savedVars.disableEnforceRole = v end,
        },
        { type = "header", name = "Иконка телепорта" },
        {
            type = "checkbox",
            name = "Показывать иконку",
            getFunc = function() return NC.savedVars.showIcon end,
            setFunc = function(v) NC.savedVars.showIcon = v NC.CastleIcon:SetHidden(not v) end,
        },
        {
            type = "slider",
            name = "Позиция иконки",
            min = 0, max = 800,
            getFunc = function() return NC.savedVars.vrxCoord end,
            setFunc = function(v) UpdateCastleIconPosition(v) end,
        },
        { type = "header", name = "Уведомления о личке" },
        {
            type = "checkbox",
            name = "Включить уведомления",
            getFunc = function() return NC.savedVars.whisperAlert end,
            setFunc = function(v) NC.savedVars.whisperAlert = v end,
        },
        {
            type = "slider",
            name = "Длительность (сек)",
            min = 1, max = 60, step = 0.5, decimals = 1,
            getFunc = function() return NC.savedVars.whisperDuration end,
            setFunc = function(v) NC.savedVars.whisperDuration = v end,
        },
        {
            type = "checkbox",
            name = "Закрепить положение",
            getFunc = function() return NC.savedVars.whisperLocked end,
            setFunc = function(v) 
                NC.savedVars.whisperLocked = v 
                NC.UpdateWhisperUI()
            end,
        },
        { type = "header", name = "FollowMe (Следование)" },
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
    }

    LAM:RegisterAddonPanel("NecroCatMenu", panelData)
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

function HookFriendsAndGuildMenu()
    if not LibCustomMenu then return end
    
    local function AddCustomItems(data)
        AddNecroMenuEntries(data)
    end
    
    LibCustomMenu:RegisterFriendsListContextMenu(AddCustomItems, LibCustomMenu.CATEGORY_LATE)
    LibCustomMenu:RegisterGuildRosterContextMenu(AddCustomItems, LibCustomMenu.CATEGORY_LATE)
end


---------------------------------------------------------
-- 6. ЗАГРУЗКА
---------------------------------------------------------

function NC.OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= NC.name then return end

    NC.savedVars = ZO_SavedVars:NewAccountWide("NecroCat_SV", 1, nil, {
        vrxCoord        = 136,
        showIcon        = true,
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
        guildBankEnabled = false,
        guildBankLeft = 500,
        guildBankTop = 300,
    }, GetWorldName())

    if NC.savedVars.firstLoad then
        NC.savedVars.firstLoad = false
        NC.savedVars.vrxCoord = 136
    end

    NC.CastleIcon = WINDOW_MANAGER:CreateControl("NecroCatGuildHall", ZO_ChatWindow, CT_BUTTON)
    NC.CastleIcon:SetDimensions(25, 25)
    NC.CastleIcon:SetNormalTexture("NecroCat/imgs/CastleofNecroCat.dds")
    NC.CastleIcon:SetHidden(not NC.savedVars.showIcon)
    NC.CastleIcon:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -NC.savedVars.vrxCoord, 10)
    NC.CastleIcon:SetHandler("OnClicked", NC.CastleHall)
    NC.CastleIcon:SetHandler("OnMouseEnter", function(ctrl)
        InitializeTooltip(InformationTooltip, ctrl, TOP, 0, 5)
        SetTooltipText(InformationTooltip, "|c66f2ffNecro cat's Guildhall|r")
    end)
    NC.CastleIcon:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    
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
    
    -- Безопасные вызовы хуков
    if HookFriendsAndGuildMenu then HookFriendsAndGuildMenu() end
    NC.HookFriendsSorting()
    
    CreateWhisperUI()
    NC.UpdateWhisperUI()
    CreateFriendNotificationUI()
    NC.UpdateFriendUI()
    NC.CreateDifficultyUI()
    NC.CreateGuildBankUI()
    
-- Сцена банка гильдии
    local bankScene = SCENE_MANAGER:GetScene("guildBank")
    
    bankScene:RegisterCallback("StateChange", function(oldState, newState)
        if not NC.savedVars.guildBankEnabled then return end
        
        if newState == SCENE_SHOWING then
            NC.BankFrame:SetHidden(false)
            
            -- Автоматический выбор гильдии (только если индекс > 0)
            local gidIndex = NC.savedVars.guildBankDefaultIndex
            if gidIndex and gidIndex > 0 then
                zo_callLater(function()
                    local gid = GetGuildId(gidIndex)
                    if gid then ZO_SharedInventory_SelectAccessibleGuildBank(gid) end
                end, 200)
            end
            
        elseif newState == SCENE_HIDING then
            NC.BankFrame:SetHidden(true)
        end
    end)

    -- Проверка при старте (если мы уже в банке)
    if bankScene:GetState() == SCENE_SHOWING and NC.savedVars.guildBankEnabled then
        NC.BankFrame:SetHidden(false)
        
        -- Повторяем ту же логику для авто-выбора при релоаде
        local gidIndex = NC.savedVars.guildBankDefaultIndex
        if gidIndex and gidIndex > 0 then
            zo_callLater(function()
                local gid = GetGuildId(gidIndex)
                if gid then ZO_SharedInventory_SelectAccessibleGuildBank(gid) end
            end, 200)
        end
    else
        NC.BankFrame:SetHidden(true)
    end

    EVENT_MANAGER:RegisterForEvent(NC.name, EVENT_CHAT_MESSAGE_CHANNEL, NC.OnChatMessage)
    
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
    d("[NecroCat] Список полностью очищен!")
    FRIENDS_LIST:RefreshData()
end

-- =========================================================
-- СПРАВОЧНАЯ КОМАНДА ДЛЯ ЗАКРЕПЛЕНИЯ ДРУЗЕЙ
-- =========================================================

SLASH_COMMANDS["/necrohelp"] = function()
    d("|c66f2ff[NecroCat] Справка по закреплению друзей:|r")
    d("Команды управления списком:")
    d("  |c22ff22/pinfriend @ИмяАккаунта [Позиция]|r - Закрепить друга на позицию (например, 1). Остальные сдвинутся вниз.")
    d("  |c22ff22/unpinfriend @ИмяАккаунта|r - Убрать друга из закрепленных. Номера остальных сдвинутся вверх без пустот.")
    d("  |c22ff22/listpinned|r - Показать список текущих закреплений по номерам.")
    d("  |c22ff22/pinclear|r - Полностью очистить весь список закреплений.")
    d("Имя аккаунта обязательно вводить с собачкой (например: |c66f2ff@Soul_Hagans|r).")
end