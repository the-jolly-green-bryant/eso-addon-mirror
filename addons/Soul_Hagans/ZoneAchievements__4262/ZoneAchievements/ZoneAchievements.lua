-- ZoneAchievements.lua (исправленное ядро + кэш)
local ADDON_NAME = "ZoneAchievements"
local ZA = {}
ZA.Cache = {}
local ZA_EXPECTED = _G["ZA_Names"] or {}

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_ZONEACH_WINDOW", "Открыть/закрыть окно ZoneAchievements")

-- вспомогательный массив для отслеживания созданных строк (чтобы безопасно удалять)
local createdRows = {}

-- Получаем ID и название зоны
function ZA:GetCurrentZoneInfo()
    local zoneIndex = GetCurrentMapZoneIndex() or 0
    local zoneId = (zoneIndex > 0 and GetZoneId(zoneIndex)) or GetZoneId(0) or 0
    local zoneName = (zoneId > 0 and GetZoneNameById(zoneId)) or GetUnitZone('player') or "Неизвестно"

    local mapId = (GetCurrentMapId and GetCurrentMapId()) or 0

    -- Если для конкретного mapId есть запись в таблице ачивок и mapId отличается от zoneId — используем его
    if mapId > 0 and mapId ~= zoneId and ZONE_ACHIEVEMENTS and ZONE_ACHIEVEMENTS[mapId] and #ZONE_ACHIEVEMENTS[mapId] > 0 then
        d(string.format("ZoneAchievements: используем mapId %d (zoneId=%d)", mapId, zoneId))
        return mapId, zoneName
    end

    return zoneId, zoneName
end





-- Получаем информацию об ачивке
function ZA:GetAchievementInfo(achievementId)
    local name, description, points, icon, completed, earned, category, hidden = GetAchievementInfo(achievementId)
    return {
        id = achievementId,
        name = name or "Неизвестно",
        desc = description or "",
        points = points or 0,
        icon = icon or "/esoui/art/icons/icon_missing.dds",
        completed = completed or false,
        earned = earned or false
    }
end

-- Прогресс
function ZA:GetAchievementProgress(achievementId)
    local numCriteria = GetAchievementNumCriteria(achievementId)
    if not numCriteria or numCriteria == 0 then
        local completed = select(5, GetAchievementInfo(achievementId))
        return completed and 1 or 0, 1
    end
    local done, total = 0, 0
    for i = 1, numCriteria do
        local _, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
        done = done + (numCompleted or 0)
        total = total + (numRequired or 0)
    end
    return done, total
end

-- ================= Окно =================
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 500, 520

local ZAWindow = WINDOW_MANAGER:CreateTopLevelWindow("ZAWindow")
ZAWindow:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
ZAWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
ZAWindow:SetMovable(true)
ZAWindow:SetClampedToScreen(true)
ZAWindow:SetHidden(true)
ZAWindow:SetMouseEnabled(true)
ZAWindow:SetResizeHandleSize(10)
ZAWindow:SetHandler("OnShow", function()
    SCENE_MANAGER:SetInUIMode(true)
end)

ZAWindow:SetHandler("OnHide", function()
    SCENE_MANAGER:SetInUIMode(false)
end)

-- Фон
local bg = WINDOW_MANAGER:CreateControl(nil, ZAWindow, CT_BACKDROP)
bg:SetAnchorFill()
bg:SetCenterColor(0, 0, 0, 0.7)
bg:SetEdgeColor(0.7, 0.7, 0.7, 1)

-- Заголовок
local title = WINDOW_MANAGER:CreateControl(nil, ZAWindow, CT_LABEL)
title:SetFont("ZoFontWinH1")
title:SetAnchor(TOP, ZAWindow, TOP, 0, 12)
title:SetText("|c39DB92Zone Achievements|r")

-- Кнопка закрытия
local closeBtn = WINDOW_MANAGER:CreateControl(nil, ZAWindow, CT_BUTTON)
closeBtn:SetDimensions(40, 40)
closeBtn:SetAnchor(TOPRIGHT, ZAWindow, TOPRIGHT, 5, 5)
closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
closeBtn:SetHandler("OnClicked", function() ZAWindow:SetHidden(true) end)

-- Скролл-контейнер
local scroll = WINDOW_MANAGER:CreateControlFromVirtual("ZA_Scroll", ZAWindow, "ZO_ScrollContainer")
scroll:SetAnchor(TOPLEFT, ZAWindow, TOPLEFT, 14, 50)
scroll:SetDimensions(DEFAULT_WIDTH - 28, DEFAULT_HEIGHT - 72)
local scrollChild = scroll:GetNamedChild("ScrollChild")
scrollChild:SetAnchor(TOPLEFT, scrollChild:GetParent(), TOPLEFT, 0, 0)
scrollChild:SetWidth(scroll:GetWidth() - 10)

-- Очистка (надёжно удаляем старые элементы)
local function ClearScrollChild()
    if not scrollChild then return end

    -- Если доступен быстрый метод - используем
    if type(scrollChild.RemoveAllChildren) == "function" then
        scrollChild:RemoveAllChildren()
    else
        for i = scrollChild:GetNumChildren(), 1, -1 do
            local child = scrollChild:GetChild(i)
            if child then
                if type(child.Destroy) == "function" then
                    child:Destroy()
                else
                    child:SetHidden(true)
                    child:ClearAnchors()
                    child:SetParent(nil)
                end
            end
        end
    end

    -- также попробуем избавиться от всех сохранённых строк
    for i = #createdRows, 1, -1 do
        local r = createdRows[i]
        if r then
            if type(r.Destroy) == "function" then
                r:Destroy()
            else
                r:SetHidden(true)
                r:ClearAnchors()
                r:SetParent(nil)
            end
        end
        createdRows[i] = nil
    end

    scrollChild:SetHeight(0)
end

-- ================== КЭШИРОВАНИЕ ==================
local function BuildZoneCache(zoneId)
    local achievementIds = ZONE_ACHIEVEMENTS[zoneId] or {}
    local zoneCache = {}

    for _, achId in ipairs(achievementIds) do
        local achInfo = ZA:GetAchievementInfo(achId)
        local done, total = ZA:GetAchievementProgress(achId)
        table.insert(zoneCache, {
            info = achInfo,
            done = done,
            total = total,
        })
    end

    ZA.Cache[zoneId] = zoneCache
    return zoneCache
end

-- =======================
-- Глобальная функция пересчёта (доступна из OnResizeStop и из кнопки)
-- =======================
function ZA:RecalculateAll()
    if not self.rows or not self.scrollChild or not self.scroll or not self.header then return end

    local header = self.header
    local rows = self.rows
    local scrollChildLocal = self.scrollChild
    local scrollLocal = self.scroll

    -- пересчёт высот строк
    for _, r in ipairs(rows) do
        if r.criteriaContainer then
            if r.criteriaContainer:IsHidden() then
                local ch = r.collapsedHeight or (r.desc and (r.desc:GetBottom() - r:GetTop() + 10) or 40)
                r:SetHeight(ch)
            else
                local newH = (r.criteriaContainer:GetBottom() - r:GetTop()) + 10
                r:SetHeight(newH)
            end
        end
    end

    -- перевязка строк одна под другой
    local prev = header
    for _, r in ipairs(rows) do
        r:ClearAnchors()
        r:SetAnchor(TOPLEFT, prev, BOTTOMLEFT, 0, 20)
        prev = r
    end

    -- корректируем высоту scrollChild по реальной нижней границе последнего элемента
    local top = scrollChildLocal:GetTop()
    local lastBottom = prev and prev:GetBottom() or top
    local newHeight = lastBottom - top + 30
    scrollChildLocal:SetHeight(math.max(newHeight, scrollLocal:GetHeight() + 1))

    if type(ZO_Scroll_UpdateScrollBar) == "function" then
        ZO_Scroll_UpdateScrollBar(scrollLocal)
    elseif scrollLocal.UpdateScroll and type(scrollLocal.UpdateScroll) == "function" then
        scrollLocal:UpdateScroll()
    end
end

function ZA:UpdateRowWidths(newWidth)
    if not self.rows then return end
    for _, r in ipairs(self.rows) do
        local scrollbarReserve = 20 -- запас справа под скролл
        if r.desc then
            r.desc:SetWidth(newWidth - 90 - scrollbarReserve)
            r.desc:SetText(r.desc:GetText())
        end
        if r.nameLabel then
            r.nameLabel:SetWidth(newWidth - 120 - scrollbarReserve)
            r.nameLabel:SetText(r.nameLabel:GetText())
        end
        if r.criteriaContainer and r.criteriaContainer:GetNumChildren() > 0 then
            for i = 1, r.criteriaContainer:GetNumChildren() do
                local critRow = r.criteriaContainer:GetChild(i)
                if critRow and critRow:GetNumChildren() > 1 then
                    local critLabel = critRow:GetChild(2)
                    if critLabel and critLabel.SetWidth then
                        critLabel:SetWidth(newWidth - 140 - scrollbarReserve)
                        critLabel:SetText(critLabel:GetText())
                    end
                end
            end
        end
    end
    zo_callLater(function() ZA:RecalculateAll() end, 50)
end

-- ================== Показ ==================
function ZA:ShowZoneAchievementsWindow()
    local zoneId, zoneName = self:GetCurrentZoneInfo()

    -- Берём из кэша или строим заново
    local cache = self.Cache[zoneId]
    if not cache then
        cache = BuildZoneCache(zoneId)
    end

    -- Полная очистка и сброс UI
    ClearScrollChild()

    local leftPadding = 6
    local blockWidth = scrollChild:GetWidth()

    -- массив строк (локальный для перестройки)
    local rows = {}

    -- helper: обновление скролла (fallback-safe)
    local function RefreshScroll()
        if type(ZO_Scroll_UpdateScrollBar) == "function" then
            ZO_Scroll_UpdateScrollBar(scroll)
        elseif scroll.UpdateScroll and type(scroll.UpdateScroll) == "function" then
            scroll:UpdateScroll()
        end
    end

    -- Заголовок зоны: убран визуально, но нужен невидимый якорь для строк/сообщений
    local header = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
    header:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, leftPadding, 10)
    header:SetHidden(true)

    -- Если нет ачивок для этой зоны
    if #cache == 0 then
        ZA.rows = {}
        ZA.header = header
        ZA.scrollChild = scrollChild
        ZA.scroll = scroll
        ZA:RecalculateAll()
        ZAWindow:SetHidden(false)
        return
    end

    -- Сохраняем порядок, но группируем: сначала выполненные, затем невыполненные
    local completedList, incompleteList = {}, {}
    for _, entry in ipairs(cache) do
        if entry.info and entry.info.completed then
            table.insert(completedList, entry)
        else
            table.insert(incompleteList, entry)
        end
    end
    local ordered = {}
    for _, e in ipairs(completedList) do table.insert(ordered, e) end
    for _, e in ipairs(incompleteList) do table.insert(ordered, e) end

    -- === цикл по ачивкам (по ordered) ===
    for _, entry in ipairs(ordered) do
        local achInfo = entry.info
        local done, total = entry.done, entry.total

        local percent = total > 0 and math.floor((done / total) * 100) or 0
        local statusColor = achInfo.completed and "00FF00" or "FF0000"

        local row = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_CONTROL)
        -- временная привязка, потом RecalculateAll её скорректирует
        row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, leftPadding, 0)
        row:SetWidth(blockWidth - 10)

        -- фон (для hover)
        local rowBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        rowBg:SetAnchorFill(row)
        rowBg:SetCenterColor(0, 0, 0, 0)
        rowBg:SetEdgeColor(0, 0, 0, 0)

        row:SetMouseEnabled(true)
        row:SetHandler("OnMouseEnter", function() rowBg:SetCenterColor(0.2, 0.4, 0.8, 0.25) end)
        row:SetHandler("OnMouseExit", function() rowBg:SetCenterColor(0, 0, 0, 0) end)
        row:SetHandler("OnMouseUp", function(_, button, upInside)
            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                ACHIEVEMENTS:ShowAchievement(achInfo.id)
            end
        end)

        -- Иконка
        local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
        icon:SetDimensions(48, 48)
        icon:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        icon:SetTexture(achInfo.icon)
        icon:SetColor(achInfo.completed and 1 or 0.35, achInfo.completed and 1 or 0.35, achInfo.completed and 1 or 0.35, 1)

        -- Название + дата (в одну строку)
        local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        nameLabel:SetFont("ZoFontWinH4")
        nameLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 10, 0)
        nameLabel:SetWidth(blockWidth - 180) -- оставляем запас под прогресс/отступы
        nameLabel:SetWrapMode(TEXT_WRAP_MODE_WORD)
        nameLabel:SetMaxLineCount(2)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        local earnedDate = ""
        if achInfo.completed and achInfo.earned and achInfo.earned ~= "" then
            earnedDate = " |cAAAAAA" .. achInfo.earned .. "|r"
        end

        nameLabel:SetText("|c" .. statusColor .. achInfo.name .. "|r  (" .. percent .. "%)" .. earnedDate)
        row.nameLabel = nameLabel

        -- Кнопка развертывания (плюс/минус)
        local toggleBtn = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
        toggleBtn:SetDimensions(24, 24)
        toggleBtn:ClearAnchors()
        toggleBtn:SetAnchor(TOPLEFT, icon, TOPLEFT, -5, -5)
        toggleBtn:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
        toggleBtn:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
        toggleBtn:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")

        -- Рамка для прогресс-бара
        local barFrame = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        local barWidth = math.max(blockWidth - 180, 120)
        barFrame:SetDimensions(barWidth + 4, 22)
        barFrame:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, -2, 4)
        barFrame:SetCenterColor(0, 0, 0, 0)
        barFrame:SetEdgeTexture(nil, 1, 1, 1, 1)
        barFrame:SetEdgeColor(0.9, 0.7, 0.2, 1)

        -- Прогресс-бар внутри рамки
        local bar = WINDOW_MANAGER:CreateControl(nil, barFrame, CT_STATUSBAR)
        bar:SetAnchor(TOPLEFT, barFrame, TOPLEFT, 2, 2)
        bar:SetAnchor(BOTTOMRIGHT, barFrame, BOTTOMRIGHT, -2, -2)
        bar:SetMinMax(0, total > 0 and total or 1)
        bar:SetValue(done)
        bar:SetColor(achInfo.completed and 0 or 0.7, achInfo.completed and 0.7 or 0.2, 0.2, 1)

        -- Цифры по центру
        local progLabel = WINDOW_MANAGER:CreateControl(nil, bar, CT_LABEL)
        progLabel:SetFont("ZoFontGameSmall")
        progLabel:SetAnchor(CENTER, bar, CENTER, 0, 0)
        progLabel:SetColor(1, 1, 1, 1)
        progLabel:SetText(string.format("%d / %d", done, total))

        -- Описание
        local desc = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        desc:SetFont("ZoFontGame")
        desc:SetAnchor(TOPLEFT, bar, BOTTOMLEFT, 0, 6)
        desc:SetWidth(blockWidth - 70)
        desc:SetWrapMode(TEXT_WRAP_MODE_WORD)
        desc:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        desc:SetText(achInfo.desc)

        -- Контейнер критериев (скрываемый)
        local criteriaContainer = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
        criteriaContainer:SetAnchor(TOPLEFT, desc, BOTTOMLEFT, 0, 6)
        -- Используем ширину окна за вычетом отступов, а не GetWidth() контейнера
        local criteriaWidth = ZAWindow:GetWidth() - 80 
        criteriaContainer:SetWidth(criteriaWidth)
        criteriaContainer:SetResizeToFitDescendents(true)

        local previousCrit = nil
        local numCriteria = GetAchievementNumCriteria(achInfo.id) or 0
        for i = 1, numCriteria do
            local critDesc, cur, max, flag = GetAchievementCriterion(achInfo.id, i)
            if critDesc and critDesc ~= "" then
                local isDone = (max and max > 0 and cur >= max) or flag

                local critRow = WINDOW_MANAGER:CreateControl(nil, criteriaContainer, CT_CONTROL)
                critRow:SetAnchor(TOPLEFT, previousCrit or criteriaContainer, previousCrit and BOTTOMLEFT or TOPLEFT, 0, previousCrit and 4 or 0)
                -- Указываем конкретную ширину явно
                critRow:SetWidth(criteriaWidth) 
                critRow:SetHeight(25) -- Немного увеличим высоту для надежности

                local critIcon = WINDOW_MANAGER:CreateControl(nil, critRow, CT_TEXTURE)
                critIcon:SetDimensions(18, 18)
                critIcon:SetAnchor(LEFT, critRow, LEFT, 0, 0)
                critIcon:SetTexture(isDone and "/esoui/art/buttons/accept_up.dds" or "/esoui/art/buttons/decline_up.dds")
                critIcon:SetColor(isDone and 0 or 1, isDone and 1 or 0, 0, 1)

                local critLabel = WINDOW_MANAGER:CreateControl(nil, critRow, CT_LABEL)
                critLabel:SetFont("ZoFontGame")
                critLabel:SetAnchor(LEFT, critIcon, RIGHT, 8, 0)
                -- Устанавливаем правую границу, чтобы текст мог переноситься
                critLabel:SetAnchor(RIGHT, critRow, RIGHT, 0, 0)
                critLabel:SetWrapMode(TEXT_WRAP_MODE_WORD)
                critLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                -- ПРИНУДИТЕЛЬНО задаем белый цвет
                critLabel:SetColor(1, 1, 1, 1) 
                
                local displayText = max and max > 1 and string.format("%s (%d/%d)", critDesc, cur or 0, max) or critDesc
                critLabel:SetText(displayText)

                previousCrit = critRow
            end
        end

        -- Скрываем по умолчанию
        criteriaContainer:SetHidden(true)

        -- сохраняем ссылки/высоты в row, чтобы RecalculateAll мог работать
        local collapsedHeight = desc:GetBottom() - row:GetTop() + 10
        row.collapsedHeight = collapsedHeight
        row.desc = desc
        row.criteriaContainer = criteriaContainer
        row:SetHeight(collapsedHeight)

        -- обработчик кнопки: переключаем видимость criteriaContainer и пересчитываем всё через небольшой delay
        toggleBtn:SetHandler("OnClicked", function()
            local wasHidden = criteriaContainer:IsHidden()
            criteriaContainer:SetHidden(not wasHidden)
            if wasHidden then
                toggleBtn:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
            else
                toggleBtn:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
            end
            zo_callLater(function() ZA:RecalculateAll() end, 50)
        end)

        table.insert(rows, row)
        table.insert(createdRows, row)
    end

    -- сохраняем ссылки для глобального пересчёта
    ZA.rows = rows
    ZA.header = header
    ZA.scrollChild = scrollChild
    ZA.scroll = scroll

    -- Финальный пересчёт позиций и размеров
    ZA:RecalculateAll()
    ZAWindow:SetHidden(false)
end

-- ================== Сохранение позиции и размера ==================
local function InitializeSavedVars()
    ZA.SavedVars = ZO_SavedVars:NewAccountWide("ZA_SavedVars", 1, nil, {
        left = nil,
        top = nil,
        width = DEFAULT_WIDTH,
        height = DEFAULT_HEIGHT,
        Snapshots = {}, -- тут будем хранить снапшоты
    })


    if ZA.SavedVars.left and ZA.SavedVars.top then
        ZAWindow:ClearAnchors()
        ZAWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ZA.SavedVars.left, ZA.SavedVars.top)
    else
        ZAWindow:ClearAnchors()
        ZAWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    ZAWindow:SetDimensions(ZA.SavedVars.width, ZA.SavedVars.height)
    local w, h = ZAWindow:GetDimensions()
    scroll:SetDimensions(w - 28, h - 72)
    scrollChild:SetWidth(scroll:GetWidth() - 10)
end

local function SnapshotAchievements()
    local snapshot = {}

    for zoneId, achievementIds in pairs(ZONE_ACHIEVEMENTS) do
        snapshot[zoneId] = {}
        for _, achId in ipairs(achievementIds) do
            local name = select(1, GetAchievementInfo(achId))
            if name and name ~= "" then
                table.insert(snapshot[zoneId], { id = achId, expectedName = name })
            else
                table.insert(snapshot[zoneId], { id = achId, expectedName = "???" })
            end
        end
    end

    ZA.SavedVars.Snapshots = snapshot
    d("|c39DB92[ZA]|r Снимок ачивок сохранён. Перезагрузи UI и посмотри SavedVariables.")
end

local function CheckAchievementNames()
    for zoneId, entries in pairs(ZA_EXPECTED) do
        for _, entry in ipairs(entries) do
            local currentName = select(1, GetAchievementInfo(entry.id))
            if currentName and currentName ~= entry.expectedName then
                d(zo_strformat(
                    "|cFF0000[ZA]|r ID <<1>> изменился: ожидалось \"<<2>>\", стало \"<<3>>\"",
                    entry.id, entry.expectedName, currentName
                ))
            end
        end
    end
    d("|c39DB92[ZA]|r Проверка завершена")
end

local function RegisterSlashCommands()
    SLASH_COMMANDS["/za"] = function()
        ZA:ShowZoneAchievementsWindow()
    end
    SLASH_COMMANDS["/zoneach"] = function()
        ZA:ShowZoneAchievementsWindow()
    end
---    SLASH_COMMANDS["/zasnap"] = function()
---        SnapshotAchievements()
---    end
--    SLASH_COMMANDS["/zacheck"] = function()
--        CheckAchievementNames()
--   end
end

ZAWindow:SetHandler("OnMoveStop", function()
    ZA.SavedVars.left, ZA.SavedVars.top = ZAWindow:GetLeft(), ZAWindow:GetTop()
end)

ZAWindow:SetHandler("OnResizeStop", function()
    local w, h = ZAWindow:GetDimensions()
    ZA.SavedVars.width, ZA.SavedVars.height = w, h
    scroll:SetDimensions(w - 28, h - 72)
    scrollChild:SetWidth(scroll:GetWidth() - 10)

    zo_callLater(function()
        ZA:UpdateRowWidths(w)
    end, 50)
end)

-- Автозагрузка
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    InitializeSavedVars()
    RegisterSlashCommands()
    d("|cFF00FFZoneAchievements загружен!|r Используй |cFFFF00/za|r")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)


-- ================== Глобальная функция для биндинга ==================
function ZoneAchievements_ToggleWindow()
    if ZAWindow:IsHidden() then
        ZA:ShowZoneAchievementsWindow()
    else
        ZAWindow:SetHidden(true)
    end
end
