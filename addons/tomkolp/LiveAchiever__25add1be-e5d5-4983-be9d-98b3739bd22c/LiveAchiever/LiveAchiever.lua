LiveAchiever = {
    name = "LiveAchiever",
    savedVars = {},
    defaultVars = {
        trackedAchievements = {},
        expandedStates = {},
        accumulations = {},
        recentHistory = {}, 
        unreadCount = 0,
        notificationDuration = 7200000,
        left = 20,
        top = 600,
        locked = false,
        hideInCombat = true,
        fontSizePC = 12,
        fontSizeGamepad = 16,
        backgroundAlpha = 0,
    },
    uiContainer = nil,
    progressCache = {}, 
    accumulatedDiffs = {}, 
    timerInfos = {},
    strings = {},
    historyIndex = 1, 
    idsToRemove = {},
    isPositioning = false,
    isTempCentered = false,
}

local LA = LiveAchiever

local function InitializeLanguage()
    local defaultStrings = (LA.Lang and LA.Lang.en) or {}
    local lang = GetCVar("language.2")
    if LA.Lang and LA.Lang[lang] then
        LA.strings = LA.Lang[lang]
        if lang ~= "en" and LA.Lang.en then
            setmetatable(LA.strings, { __index = LA.Lang.en })
        end
    else
        LA.strings = LA.Lang.en or {}
    end
end

local function GetNotificationDuration()
    local val = LA.savedVars.notificationDuration
    if type(val) == "table" then
        if val.data then val = val.data else val = 3000 end
        LA.savedVars.notificationDuration = val 
    end
    return type(val) == "number" and val or 3000
end

function LA.GetDynamicFontInfo()
    local size
    if IsInGamepadPreferredMode() then
        size = LA.savedVars.fontSizeGamepad or 16
    else
        size = LA.savedVars.fontSizePC or 12
    end
    
    local fontName = "ZoFontGameSmall" 
    local fontTitle = "ZoFontGameLargeBold" 
    local critFontName = "ZoFontGameSmall"
    
    if size < 12 then
        fontName = "ZoFontGameSmall"
        fontTitle = "ZoFontGameBold"
        critFontName = "ZoFontGameSmall"
    elseif size < 16 then
        fontName = "ZoFontGame"
        fontTitle = "ZoFontGameLargeBold"
        critFontName = "ZoFontGameSmall"
    elseif size < 20 then
        fontName = "ZoFontGamepad18"
        fontTitle = "ZoFontGamepadBold22"
        critFontName = "ZoFontGamepad18"
    elseif size < 24 then
        fontName = "ZoFontGamepad22"
        fontTitle = "ZoFontGamepadBold22"
        critFontName = "ZoFontGamepad18"
    else
        fontName = "ZoFontGamepad27"
        fontTitle = "ZoFontGamepadBold27"
        critFontName = "ZoFontGamepad22"
    end
    
    return {
        rowFont = fontName,
        titleFont = fontTitle,
        critFont = critFontName,
        btnSize = math.max(14, size + 2),   
        rowHeight = (size < 16) and (size + 14) or (size + 10)
    }
end

function LA.UpdateBackgroundAlpha()
    if not LA.uiContainer then return end
    local bg = LA.uiContainer:GetNamedChild("Bg")
    if bg then
        local alphaPercent = LA.savedVars.backgroundAlpha or 0
        local alpha = alphaPercent / 100
        bg:SetCenterColor(0, 0, 0, alpha)
    end
end

function LA.ApplyAppearance()
    if not LA.uiContainer then return end
    local f = LA.GetDynamicFontInfo()
    
    local title = LA.uiContainer:GetNamedChild("Title")
    if title then title:SetFont(f.titleFont) end
    
    local addBtn = LA.uiContainer:GetNamedChild("AddBtn")
    if addBtn then
        addBtn:SetDimensions(f.btnSize, f.btnSize)
        local badge = LA.uiContainer:GetNamedChild("AddBtnBadge")
        if badge then
            badge:ClearAnchors()
            badge:SetAnchor(BOTTOMLEFT, addBtn, TOPRIGHT, -8, 5)
        end
    end
    LA.UpdateBackgroundAlpha()
    if LA.UpdateTrackerUI then LA.UpdateTrackerUI() end
end

function LA.SetPositioningMode(enabled)
    LA.isPositioning = enabled
    if LA.uiContainer then
        LA.uiContainer:SetMovable(enabled or not LA.savedVars.locked)
    end
    LA.RefreshVisibility()
end

function LA.RefreshVisibility()
    if not LA.uiContainer then return end

    if LA.savedVars.hideInCombat and IsUnitInCombat("player") then
        LA.uiContainer:SetHidden(true)
        return
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    local sceneName = scene and scene:GetName() or ""
    
    local isHud = (sceneName == "hud" or sceneName == "hudui")
    local isAchievements = (sceneName == "achievements" or sceneName == "achievementsGamepad")
    local isGroupMenu = (sceneName == "groupMenuKeyboard")
    -- [DODANO] Obsługa sceny Zone Guide Gamepad
    local isZoneStoriesGamepad = (sceneName == "zoneStoriesGamepad")
    
    -- Dodano 'isZoneStoriesGamepad' do warunku
    if not isHud and not isAchievements and not isGroupMenu and not isZoneStoriesGamepad and not LA.isPositioning then
        LA.uiContainer:SetHidden(true)
        return
    end

    local hasTracked = false
    for _ in pairs(LA.savedVars.trackedAchievements) do hasTracked = true break end
    local hasHistory = LA.savedVars.recentHistory and #LA.savedVars.recentHistory > 0
    
    local isZonePanelActive = (LA.zonePanel and not LA.zonePanel:IsHidden())

    -- Dodano 'isZoneStoriesGamepad' do warunku wyświetlania
    if (hasTracked or hasHistory or LA.isPositioning or isZonePanelActive or isZoneStoriesGamepad) then
        LA.uiContainer:SetHidden(false)
        -- Wyciągnij na wierzch, jeśli jesteśmy w menu
        if isAchievements or isGroupMenu or isZoneStoriesGamepad then
            LA.uiContainer:BringWindowToTop()
        end
    else
        LA.uiContainer:SetHidden(true)
    end
end

function LA.GetHistoryAvailableCount()
    if not LA.savedVars.recentHistory then return 0 end
    local count = 0
    for _, id in ipairs(LA.savedVars.recentHistory) do
        if not LA.savedVars.trackedAchievements[id] then
            count = count + 1
        end
    end
    return count
end

function LA.UpdateAddButtonState()
    if not LA.uiContainer then return end
    local badge = LA.uiContainer:GetNamedChild("AddBtnBadge")
    if not badge then return end
    
    local count = LA.GetHistoryAvailableCount()
    if count > 0 then
        if count > 9 then count = "9+" end 
        badge:SetText(count)
        badge:SetHidden(false)
    else
        badge:SetHidden(true)
    end
end

function LA.AddToHistory(achId)
    if not achId then return end
    if not LA.savedVars.recentHistory then LA.savedVars.recentHistory = {} end
    local history = LA.savedVars.recentHistory
    
    for i, id in ipairs(history) do
        if id == achId then
            table.remove(history, i)
            break
        end
    end
    table.insert(history, 1, achId)
    while #history > 5 do table.remove(history) end
    LA.historyIndex = 1
    LA.UpdateAddButtonState()
    
    if KEYBIND_STRIP and LA.gamepadKeybindStrip and IsInGamepadPreferredMode() then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip)
    end
end

function LA.UpdateHistoryPanelPosition()
    if not LA.historyPanel or LA.historyPanel:IsHidden() then return end
    if not LA.uiContainer then return end

    local p = LA.historyPanel
    local mainWin = LA.uiContainer
    local screenWidth = GuiRoot:GetWidth()
    local mainRight = mainWin:GetRight()
    local panelWidth = 300
    local gap = 10
    
    p:ClearAnchors()
    if (mainRight + gap + panelWidth) <= screenWidth then
        p:SetAnchor(TOPLEFT, mainWin, TOPRIGHT, gap, 0)
    else
        p:SetAnchor(TOPRIGHT, mainWin, TOPLEFT, -gap, 0)
    end
end

-- [NOWE] Funkcja do inteligentnego wyświetlania Tooltipów
function LA.ShowSmartTooltip(control, achId)
    local offsetX = 10
    local anchorPoint = LEFT
    local relativePoint = RIGHT
    
    -- Sprawdzamy czy Historia jest widoczna
    if LA.historyPanel and not LA.historyPanel:IsHidden() then
        local mainRight = LA.uiContainer:GetRight()
        local histLeft = LA.historyPanel:GetLeft()
        local histWidth = 300
        local gap = 15 -- margines bezpieczeństwa
        
        -- Sprawdzamy, czy Historia jest fizycznie po PRAWEJ stronie
        if histLeft and mainRight and histLeft >= (mainRight - 20) then
            -- Historia jest po prawej -> przesuwamy tooltip w prawo o szerokość historii
            offsetX = histWidth + gap + 10
            anchorPoint = LEFT
            relativePoint = RIGHT
        else
            -- Historia jest prawdopodobnie po LEWEJ stronie
            -- Wyświetlamy tooltip po LEWEJ stronie kontrolki (wiersza), przeskakując historię
            offsetX = -(histWidth + gap + 10)
            anchorPoint = RIGHT
            relativePoint = LEFT
        end
    end
    
    InitializeTooltip(ItemTooltip, control, anchorPoint, offsetX, 0, relativePoint)
    ItemTooltip:SetLink(GetAchievementLink(achId))
end

function LA.GetCombinedNavList()
    local list = {}
    if LA.savedVars.recentHistory then
        for _, id in ipairs(LA.savedVars.recentHistory) do
            if not LA.savedVars.trackedAchievements[id] then
                table.insert(list, {id = id, type = "HISTORY"})
            end
        end
    end
    local trackedTemp = {}
    for id, _ in pairs(LA.savedVars.trackedAchievements) do
        table.insert(trackedTemp, id)
    end
    table.sort(trackedTemp, function(a,b) 
        return GetAchievementName(a) < GetAchievementName(b) 
    end)
    for _, id in ipairs(trackedTemp) do
        table.insert(list, {id = id, type = "TRACKED"})
    end
    return list
end

local function GetSortedTrackedList()
    local list = {}
    for id, _ in pairs(LA.savedVars.trackedAchievements) do
        local rawName = GetAchievementName(id)
        table.insert(list, {id = id, name = rawName})
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function LA.HighlightCurrentSelection()
    local scene = SCENE_MANAGER:GetCurrentScene()
    local sceneName = scene and scene:GetName() or ""
    local isHud = (sceneName == "hud" or sceneName == "hudui")
    
    if isHud and not LA.isPositioning then return end

    local list = LA.GetCombinedNavList()
    if not list or #list == 0 then return end
    
    if LA.historyIndex > #list then LA.historyIndex = 1 end
    if LA.historyIndex < 1 then LA.historyIndex = #list end
    
    local target = list[LA.historyIndex]
    if not target then return end

    local COLOR_SELECTED = {0, 1, 1, 1} 
    local COLOR_NORMAL = {1, 1, 1, 1}   
    local COLOR_HISTORY = {0.9, 0.9, 0.9, 1} 
    local COLOR_COMPLETED = {0.5, 1, 0.5, 1} 

    if LA.historyPanel then
        if target.type == "HISTORY" and LA.historyPanel:IsHidden() then
            if LA.ShowHistoryMenu then LA.ShowHistoryMenu(nil) end
        end
        
        for _, row in ipairs(LA.historyRowPool) do
            if row and not row:IsHidden() then
                if row.achId == target.id and target.type == "HISTORY" then
                    if row.label then row.label:SetColor(unpack(COLOR_SELECTED)) end
                else
                    if row.label then row.label:SetColor(unpack(COLOR_HISTORY)) end
                end
            end
        end
    end

    if LA.uiContainer and LA.scrollChild then
        local i = 1
        while true do
            local row = LA.scrollChild:GetNamedChild("RowContainer" .. i)
            if not row then break end
            
            if row.achId == target.id and target.type == "TRACKED" then
                local label = row:GetNamedChild("Label")
                if label then label:SetColor(unpack(COLOR_SELECTED)) end
            else
                local label = row:GetNamedChild("Label")
                if label then 
                    local _, _, _, _, completed = GetAchievementInfo(row.achId or 0)
                    if completed then
                        label:SetColor(unpack(COLOR_COMPLETED))
                    else
                        label:SetColor(unpack(COLOR_NORMAL))
                    end
                end
            end
            i = i + 1
        end
    end
end

function LA.NavigateList(delta)
    local list = LA.GetCombinedNavList()
    if not list or #list == 0 then return end
    
    LA.historyIndex = LA.historyIndex + delta
    if LA.historyIndex > #list then LA.historyIndex = 1 end
    if LA.historyIndex < 1 then LA.historyIndex = #list end
    
    LA.HighlightCurrentSelection()
    
    if KEYBIND_STRIP and LA.gamepadKeybindStrip and IsInGamepadPreferredMode() then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip)
    end
end

function LA.ToggleExpand(achId)
    if not LA.savedVars.expandedStates[achId] then
        LA.savedVars.expandedStates[achId] = true
    else
        LA.savedVars.expandedStates[achId] = false
    end
    LA.UpdateTrackerUI()
end

function LA.UpdateTrackerUI()
    if not LA.uiContainer or not LA.scrollChild then return end
    LA.uiContainer:SetMovable(not LA.savedVars.locked)
    
    local f = LA.GetDynamicFontInfo()
    
    local i = 1
    while true do
        local row = LA.scrollChild:GetNamedChild("RowContainer" .. i)
        if not row then break end
        row:SetHidden(true); row:SetHeight(0); i = i + 1
    end
    local cPoolIndex = 1
    while true do
        local cLabel = LA.scrollChild:GetNamedChild("CritLabelPool" .. cPoolIndex)
        if not cLabel then break end
        cLabel:SetHidden(true); cLabel:SetHeight(0); cPoolIndex = cPoolIndex + 1
    end
    cPoolIndex = 1

    local count = 1
    local currentY = 0 
    
    local baseWidth = 380
    local WINDOW_WIDTH = (f.btnSize > 30) and 450 or baseWidth
    if LA.uiContainer:GetWidth() ~= WINDOW_WIDTH then
        LA.uiContainer:SetWidth(WINDOW_WIDTH)
    end
    local SCROLL_WIDTH = WINDOW_WIDTH - 20 
    local TEXT_WIDTH = SCROLL_WIDTH - (f.btnSize * 2) - 10 

    local sortedList = GetSortedTrackedList()

    for _, data in ipairs(sortedList) do
        local achId = data.id
        if achId then
            local rawName, _, _, _, completed = GetAchievementInfo(achId)
            local name = zo_strformat("<<C:1>>", rawName)
            local numCriteria = GetAchievementNumCriteria(achId)
            
            local totalCurrent, totalMax = 0, 0
            if numCriteria > 0 then
                for critIndex = 1, numCriteria do
                    local _, current, maxVal = GetAchievementCriterion(achId, critIndex)
                    totalCurrent = totalCurrent + (current or 0)
                    totalMax = totalMax + (maxVal or 1)
                end
            else
                totalCurrent = completed and 1 or 0
                totalMax = 1
            end

            local diff = 0
            local oldProgress = LA.progressCache[achId]
            if oldProgress ~= nil then diff = totalCurrent - oldProgress end
            LA.progressCache[achId] = totalCurrent
            if diff > 0 then
                LA.accumulatedDiffs[achId] = (LA.accumulatedDiffs[achId] or 0) + diff
                local duration = GetNotificationDuration()
                local now = GetTimeStamp() * 1000
                if not LA.savedVars.accumulations then LA.savedVars.accumulations = {} end
                LA.savedVars.accumulations[achId] = { diff = LA.accumulatedDiffs[achId], expiry = now + duration }
                LA.timerInfos[achId] = (LA.timerInfos[achId] or 0) + 1
                local myTimerId = LA.timerInfos[achId]
                zo_callLater(function()
                    if LA.timerInfos[achId] == myTimerId then
                        LA.accumulatedDiffs[achId] = 0 
                        if LA.savedVars.accumulations then LA.savedVars.accumulations[achId] = nil end
                        LA.UpdateTrackerUI() 
                    end
                end, duration)
            end

            local rowName = "RowContainer" .. count
            local rowContainer = LA.scrollChild:GetNamedChild(rowName)
            if not rowContainer then
                rowContainer = WINDOW_MANAGER:CreateControl("$(parent)" .. rowName, LA.scrollChild, CT_CONTROL)
                rowContainer:SetMouseEnabled(true)
            end
            
            rowContainer.achId = achId

            local expandBtn = rowContainer:GetNamedChild("ExpandBtn")
            if not expandBtn then
                expandBtn = WINDOW_MANAGER:CreateControl("$(parent)ExpandBtn", rowContainer, CT_BUTTON)
                expandBtn:SetAnchor(TOPLEFT, rowContainer, TOPLEFT, 2, 2)
            end
            expandBtn:SetDimensions(f.btnSize, f.btnSize)

            local closeBtn = rowContainer:GetNamedChild("Close")
            if not closeBtn then
                closeBtn = WINDOW_MANAGER:CreateControl("$(parent)Close", rowContainer, CT_BUTTON)
                closeBtn:SetAnchor(TOPRIGHT, rowContainer, TOPRIGHT, -2, 2)
            end
            closeBtn:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
            closeBtn:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
            closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
            
            local closeSize = math.max(14, f.btnSize - 4)
            closeBtn:SetDimensions(closeSize, closeSize)
            closeBtn:SetHandler("OnClicked", function() LA.ToggleTracking(achId) end)

            local label = rowContainer:GetNamedChild("Label")
            if not label then
                label = WINDOW_MANAGER:CreateControl("$(parent)Label", rowContainer, CT_LABEL)
                label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                label:SetAnchor(TOPLEFT, expandBtn, TOPRIGHT, 5, 0)
            end
            
            label:SetFont(f.rowFont)
            
            local percent = 0
            if totalMax > 0 then percent = math.floor((totalCurrent / totalMax) * 100) end
            local progressText = completed and LA.strings.HUD_Completed or string.format("%d%%", percent)
            label:SetText(string.format("%s (%s)", name, progressText))
            label:SetWidth(TEXT_WIDTH)
            label:SetColor(1, 1, 1, 1)
            if completed then label:SetColor(0.5, 1, 0.5, 1) end

            local textHeight = label:GetTextHeight()
            local rowHeight = math.max(f.rowHeight, textHeight + 4)
            
            rowContainer:SetDimensions(SCROLL_WIDTH, rowHeight)
            rowContainer:SetHidden(false)
            rowContainer:ClearAnchors()
            rowContainer:SetAnchor(TOPLEFT, LA.scrollChild, TOPLEFT, 5, currentY)
            
            currentY = currentY + rowHeight + 2

            rowContainer:SetHandler("OnMouseUp", function() LA.ToggleExpand(achId) end)
            
            -- [ZMIANA] Użycie ShowSmartTooltip
            rowContainer:SetHandler("OnMouseEnter", function(control)
                LA.ShowSmartTooltip(control, achId)
            end)
            rowContainer:SetHandler("OnMouseExit", function(control)
                ClearTooltip(ItemTooltip)
            end)

            local isExpanded = LA.savedVars.expandedStates[achId]
            expandBtn:SetNormalTexture(isExpanded and "EsoUI/Art/Buttons/minus_up.dds" or "EsoUI/Art/Buttons/plus_up.dds")
            expandBtn:SetHandler("OnClicked", function() LA.ToggleExpand(achId) end)

            local notify = rowContainer:GetNamedChild("Notify")
            if not notify then
                notify = WINDOW_MANAGER:CreateControl("$(parent)Notify", rowContainer, CT_LABEL)
                notify:SetColor(0, 1, 0, 1) 
            end
            notify:SetFont(f.rowFont)
            notify:ClearAnchors()
            notify:SetAnchor(RIGHT, closeBtn, LEFT, -5, 0)
            local accumulated = LA.accumulatedDiffs[achId] or 0
            if accumulated > 0 then notify:SetText(string.format("+%d", accumulated)) notify:SetHidden(false) else notify:SetHidden(true) end

            if isExpanded and numCriteria > 0 then
                for cIndex = 1, numCriteria do
                    local cDesc, cCur, cReq = GetAchievementCriterion(achId, cIndex)
                    if not cDesc or cDesc == "" then cDesc = string.format("%s %d", LA.strings.HUD_Crit_Default, cIndex) end
                    cDesc = zo_strformat("<<1>>", cDesc)
                    
                    local cText = string.format("• %s: %d/%d", cDesc, cCur, cReq)
                    local cColor = {0.7, 0.7, 0.7, 1}
                    if cCur >= cReq then cColor = {0, 1, 0, 1} cText = string.format("• %s (V)", cDesc) end

                    local cLabelName = "CritLabelPool" .. cPoolIndex
                    local cLabel = LA.scrollChild:GetNamedChild(cLabelName)
                    if not cLabel then
                        cLabel = WINDOW_MANAGER:CreateControl("$(parent)" .. cLabelName, LA.scrollChild, CT_LABEL)
                        cLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                    end
                    cLabel:SetFont(f.critFont)
                    cLabel:SetWidth(SCROLL_WIDTH - 30)
                    cLabel:SetText(cText)
                    cLabel:SetColor(unpack(cColor))
                    cLabel:SetHidden(false)
                    cLabel:ClearAnchors()
                    cLabel:SetAnchor(TOPLEFT, LA.scrollChild, TOPLEFT, 25, currentY)
                    
                    local thisCritHeight = cLabel:GetTextHeight()
                    if thisCritHeight == 0 then thisCritHeight = 20 end
                    currentY = currentY + thisCritHeight + 2
                    cPoolIndex = cPoolIndex + 1
                end
                currentY = currentY + 5
            end
            count = count + 1
        end 
    end
    LA.scrollChild:SetHeight(math.max(50, currentY))
    
    local headerHeight = f.btnSize + 15 
    local bottomPadding = 10
    local maxWindowHeight = 600 
    local minWindowHeight = headerHeight + 20 
    local desiredHeight = currentY + headerHeight + bottomPadding
    local finalHeight = math.max(minWindowHeight, math.min(desiredHeight, maxWindowHeight))
    
    LA.uiContainer:SetHeight(finalHeight)
    local scrollControl = LA.uiContainer:GetNamedChild("Scroll")
    if scrollControl then 
        ZO_Scroll_UpdateScrollBar(scrollControl) 
        scrollControl:ClearAnchors()
        scrollControl:SetAnchor(TOPLEFT, LA.uiContainer, TOPLEFT, 0, headerHeight)
        scrollControl:SetAnchor(BOTTOMRIGHT, LA.uiContainer, BOTTOMRIGHT, 0, 0)
    end
    
    LA.HighlightCurrentSelection()
    LA.RefreshVisibility()
end

local function CreateTrackerWindow()
    local f = LA.GetDynamicFontInfo()

    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("LiveAchieverHUD")
    tlw:SetDimensions(380, 60) 
    local left = LA.savedVars.left or 20
    local top = LA.savedVars.top or 600
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    tlw:SetMovable(true)
    tlw:SetMouseEnabled(true)
    tlw:SetHidden(false)
    tlw:SetClampedToScreen(true)

    tlw:SetHandler("OnMoveStop", function(control)
        if LA.isTempCentered then return end
        LA.savedVars.left = control:GetLeft()
        LA.savedVars.top = control:GetTop()
        LA.UpdateHistoryPanelPosition()
    end)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(0, 0, 0, 0)
    LA.uiContainer = tlw 
    LA.UpdateBackgroundAlpha()

    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", tlw, CT_LABEL)
    title:SetFont(f.titleFont)
    title:SetText(LA.strings.HUD_Title)
    title:SetColor(1, 1, 0, 1)
    title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 5)
    title:SetMouseEnabled(true)

    local addBtn = WINDOW_MANAGER:CreateControl("$(parent)AddBtn", tlw, CT_BUTTON)
    addBtn:SetDimensions(f.btnSize, f.btnSize)
    addBtn:SetAnchor(LEFT, title, RIGHT, 5, 0)
    addBtn:SetNormalTexture("EsoUI/Art/Buttons/plus_up.dds")
    addBtn:SetPressedTexture("EsoUI/Art/Buttons/plus_down.dds")
    addBtn:SetMouseOverTexture("EsoUI/Art/Buttons/plus_over.dds")
    
    local badge = WINDOW_MANAGER:CreateControl("$(parent)AddBtnBadge", tlw, CT_LABEL)
    badge:SetFont("ZoFontGameSmall") 
    badge:SetColor(1, 0.2, 0.2, 1)
    badge:SetAnchor(BOTTOMLEFT, addBtn, TOPRIGHT, -8, 5) 
    badge:SetText("0")
    badge:SetHidden(true)
    
    addBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -5, TOP)
        SetTooltipText(InformationTooltip, LA.strings.Btn_Add_Tooltip or "Add from History")
    end)
    addBtn:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)

    addBtn:SetHandler("OnClicked", function(control) 
        if LA.ShowHistoryMenu then LA.ShowHistoryMenu(control) end 
    end)

    title:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()
            AddMenuItem(LA.strings.Menu_ResetPos, function()
                tlw:ClearAnchors()
                tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 600)
                LA.savedVars.left = 20; LA.savedVars.top = 600
                LA.UpdateHistoryPanelPosition()
            end)
            ShowMenu(control)
        end
    end)

    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Scroll", tlw, "ZO_ScrollContainer")
    scrollContainer:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, f.btnSize + 15)
    scrollContainer:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 0, 0)
    LA.scrollChild = scrollContainer:GetNamedChild("ScrollChild")
end

function LA.RemoveFromHistory(achId)
    if not LA.savedVars.recentHistory then return end
    local found = false
    for i, id in ipairs(LA.savedVars.recentHistory) do
        if id == achId then
            table.remove(LA.savedVars.recentHistory, i)
            found = true
            break
        end
    end
    if found then
        LA.UpdateAddButtonState()
        if LA.historyPanel and not LA.historyPanel:IsHidden() then
            LA.ShowHistoryMenu(nil)
        end
    end
end

local function ToggleHistoryPanel(anchorControl)
    LA.savedVars.unreadCount = 0
    if LA.UpdateAddButtonState then LA.UpdateAddButtonState() end

    local f = LA.GetDynamicFontInfo()
    local isGamepad = IsInGamepadPreferredMode()
    local removeSize = math.max(14, f.btnSize - 4)

    if not LA.historyPanel then
        local p = WINDOW_MANAGER:CreateTopLevelWindow("LiveAchieverHistoryPanel")
        p:SetDimensions(300, 100)
        p:SetClampedToScreen(true)
        p:SetHidden(true)
        p:SetMouseEnabled(true)
        p:SetDrawTier(DT_HIGH)
        p:SetDrawLayer(DL_OVERLAY)

        local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", p, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetEdgeColor(0, 0, 0, 0)
        
        local closeBtnBg = WINDOW_MANAGER:CreateControl("$(parent)CloseBg", p, CT_BACKDROP)
        closeBtnBg:SetDimensions(24, 24)
        closeBtnBg:SetAnchor(TOPRIGHT, p, TOPRIGHT, -3, 3)
        closeBtnBg:SetCenterColor(0.3, 0, 0, 0.6) 
        closeBtnBg:SetEdgeColor(0.6, 0.2, 0.2, 0.8)

        local closeBtn = WINDOW_MANAGER:CreateControl("$(parent)Close", p, CT_BUTTON)
        closeBtn:SetDimensions(20, 20)
        closeBtn:SetAnchor(CENTER, closeBtnBg, CENTER, 0, 0)
        closeBtn:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
        closeBtn:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
        closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
        closeBtn:SetHandler("OnClicked", function() p:SetHidden(true) end)

        local infoLabel = WINDOW_MANAGER:CreateControl("$(parent)Info", p, CT_LABEL)
        infoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        infoLabel:SetAnchor(TOPLEFT, p, TOPLEFT, 10, 8)
        infoLabel:SetAnchor(TOPRIGHT, p, TOPRIGHT, -35, 8)
        infoLabel:SetText(LA.strings.History_Instruction or "Click to track:")
        infoLabel:SetColor(1, 1, 0, 1)

        LA.historyPanel = p
        LA.historyRowPool = {}
    end

    if anchorControl and not LA.historyPanel:IsHidden() then
        LA.historyPanel:SetHidden(true)
        return
    end
    
    local p = LA.historyPanel
    local bg = p:GetNamedChild("Bg")
    if bg then
        local alphaPercent = LA.savedVars.backgroundAlpha or 0
        bg:SetCenterColor(0, 0, 0, alphaPercent / 100)
    end
    
    local infoLabel = p:GetNamedChild("Info")
    if infoLabel then
        infoLabel:SetFont(f.titleFont) 
    end

    for _, row in ipairs(LA.historyRowPool) do row:SetHidden(true) end

    local currentY = (f.btnSize * 1.5) + 15
    local hasItems = false
    
    if LA.savedVars.recentHistory and #LA.savedVars.recentHistory > 0 then
        local rowIndex = 1
        for _, id in ipairs(LA.savedVars.recentHistory) do
            if not LA.savedVars.trackedAchievements[id] then
                
                if not LA.historyRowPool[rowIndex] then
                    local row = WINDOW_MANAGER:CreateControl("$(parent)Row" .. rowIndex, p, CT_BUTTON)
                    
                    local removeBtn = WINDOW_MANAGER:CreateControl("$(parent)Remove", row, CT_BUTTON)
                    removeBtn:SetAnchor(RIGHT, row, RIGHT, -2, 0)
                    removeBtn:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
                    removeBtn:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
                    removeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
                    row.removeBtn = removeBtn 
                    
                    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", row, CT_LABEL)
                    label:SetAnchor(LEFT, row, LEFT, 10, 0)
                    label:SetColor(0.9, 0.9, 0.9, 1)
                    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                    row.label = label
                    
                    row:SetHandler("OnMouseEnter", function(self)
                        self.label:SetColor(1, 1, 0, 1)
                        InitializeTooltip(ItemTooltip, self, LEFT, 10, 0, RIGHT)
                        ItemTooltip:SetLink(GetAchievementLink(self.achId))
                    end)
                    
                    row:SetHandler("OnMouseExit", function(self)
                        self.label:SetColor(0.9, 0.9, 0.9, 1)
                        ClearTooltip(ItemTooltip)
                    end)
                    
                    row:SetHandler("OnClicked", function(self)
                        LA.ToggleTracking(self.achId)
                        p:SetHidden(true)
                    end)
                    
                    table.insert(LA.historyRowPool, row)
                end
                
                local row = LA.historyRowPool[rowIndex]
                row.achId = id
                
                row:SetHeight(f.rowHeight)
                row.label:SetFont(f.rowFont)
                
                local rawName = GetAchievementName(id)
                local name = zo_strformat("<<C:1>>", rawName)
                local prefix = LA.strings.Nav_History or "[H]"
                row.label:SetText(string.format("%s %s", prefix, name))
                
                if isGamepad then
                    row.removeBtn:SetHidden(true)
                    row.label:ClearAnchors()
                    row.label:SetAnchor(LEFT, row, LEFT, 10, 0)
                    row.label:SetAnchor(RIGHT, row, RIGHT, -10, 0)
                else
                    row.removeBtn:SetHidden(false)
                    row.removeBtn:SetDimensions(removeSize, removeSize)
                    row.removeBtn:SetHandler("OnClicked", function() 
                        LA.RemoveFromHistory(id) 
                    end)
                    row.label:ClearAnchors()
                    row.label:SetAnchor(LEFT, row, LEFT, 10, 0)
                    row.label:SetAnchor(RIGHT, row.removeBtn, LEFT, -5, 0)
                end
                
                row:SetMouseEnabled(true)
                if not row:GetHandler("OnClicked") then
                     row:SetHandler("OnClicked", function(self)
                        LA.ToggleTracking(self.achId)
                        p:SetHidden(true)
                    end)
                end

                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, p, TOPLEFT, 5, currentY)
                row:SetAnchor(TOPRIGHT, p, TOPRIGHT, -5, currentY)
                row:SetHidden(false)
                
                currentY = currentY + f.rowHeight + 2
                rowIndex = rowIndex + 1
                hasItems = true
            end
        end
    end

    if not hasItems then
         if not LA.historyRowPool[1] then
             local row = WINDOW_MANAGER:CreateControl("$(parent)RowEmpty", p, CT_CONTROL)
             local label = WINDOW_MANAGER:CreateControl("$(parent)Label", row, CT_LABEL)
             label:SetAnchorFill()
             label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
             row.label = label
             table.insert(LA.historyRowPool, row)
         end
         local row = LA.historyRowPool[1]
         row:SetHeight(f.rowHeight)
         row.label:SetFont(f.rowFont)
         if row.removeBtn then row.removeBtn:SetHidden(true) end
         row:SetHidden(false)
         row.label:SetText(LA.strings.Menu_No_History or "(No updates)")
         row.label:SetColor(0.5, 0.5, 0.5, 1)
         row:SetMouseEnabled(false)
         if row.SetHandler then row:SetHandler("OnClicked", nil) end
         row:ClearAnchors()
         row:SetAnchor(TOPLEFT, p, TOPLEFT, 5, currentY)
         row:SetAnchor(TOPRIGHT, p, TOPRIGHT, -5, currentY)
         currentY = currentY + f.rowHeight
    end
    p:SetHeight(currentY + 10)
    p:SetHidden(false)
    LA.UpdateHistoryPanelPosition()
end

LA.ShowHistoryMenu = ToggleHistoryPanel

function LA.ToggleTracking(achievementId)
    if not achievementId then return end
    if LA.savedVars.trackedAchievements[achievementId] then
        LA.savedVars.trackedAchievements[achievementId] = nil
        LA.progressCache[achievementId] = nil
        LA.accumulatedDiffs[achievementId] = nil 
        if LA.savedVars.accumulations then LA.savedVars.accumulations[achievementId] = nil end
        LA.savedVars.expandedStates[achievementId] = nil
        d(LA.strings.Msg_Track_Stop)
        if LA.savedVars.recentHistory then
            for i, histId in ipairs(LA.savedVars.recentHistory) do
                if histId == achievementId then
                    table.remove(LA.savedVars.recentHistory, i)
                    break
                end
            end
        end
    else
        LA.savedVars.trackedAchievements[achievementId] = true
        LA.savedVars.expandedStates[achievementId] = true 
        local numCriteria = GetAchievementNumCriteria(achievementId)
        local totalCurrent = 0
        if numCriteria > 0 then
            for critIndex = 1, numCriteria do
                local _, current = GetAchievementCriterion(achievementId, critIndex)
                totalCurrent = totalCurrent + (current or 0)
            end
        end
        LA.progressCache[achievementId] = totalCurrent
        d(LA.strings.Msg_Track_Start)
    end
    
    LA.UpdateTrackerUI()      -- Odświeża główne okno
    LA.UpdateAddButtonState() -- Odświeża licznik na przycisku
    
    -- Jeśli istnieje funkcja rysująca panel strefy, wywołaj ją, żeby zaktualizować kolory (zielony/biały)
    if LA.RenderZonePanel then LA.RenderZonePanel() end
    
    if IsInGamepadPreferredMode() then
        if KEYBIND_STRIP and LA.gamepadKeybindStrip then
             KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip)
        end
    end
    if ACHIEVEMENTS_GAMEPAD and ACHIEVEMENTS_GAMEPAD:IsShowing() and ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
    end
end

local function OnAchievementUpdated(eventCode, achievementId)
    if LA.savedVars.trackedAchievements[achievementId] then
        LA.UpdateTrackerUI()
        LA.AddToHistory(achievementId)
        PlaySound(SOUNDS.OBJECTIVE_INCREMENT)
    else
        local _, _, _, _, completed = GetAchievementInfo(achievementId)
        if completed then return end
        LA.AddToHistory(achievementId)
        local link = GetAchievementLink(achievementId)
        local numCriteria = GetAchievementNumCriteria(achievementId)
        local blueColor = "|c00BFFF"
        local message = string.format("%s%s|r %s\n", blueColor, LA.strings.Chat_Update, link)
        if numCriteria > 0 then
            for critIndex = 1, numCriteria do
                local description, current, required = GetAchievementCriterion(achievementId, critIndex)
                if description == "" then description = LA.strings.HUD_Crit_Default .. " " .. critIndex end
                description = zo_strformat("<<1>>", description)
                local rowColor = "|cAAAAAA"
                if current >= required then rowColor = "|c00FF00" end
                message = message .. string.format("%s   • %s: %d/%d|r\n", rowColor, description, current, required)
            end
        else
            message = message .. "|cAAAAAA   • " .. LA.strings.Chat_Progress_InProgress .. "|r\n"
        end
        if not IsInGamepadPreferredMode() then
            local trackBtn = string.format("%s|H1:LiveAchieverTrack:%d|h%s|h|r", blueColor, achievementId, LA.strings.Chat_Track_Btn)
            message = message .. trackBtn
        end
        d(message)
        PlaySound(SOUNDS.NOTIFIER_INCREMENT)
        LA.RefreshVisibility()
    end
end

local function OnPlayerCombatState(event, inCombat)
    if not LA.uiContainer then return end
    if inCombat then
        if LA.savedVars.hideInCombat then
            LA.uiContainer:SetHidden(true)
        end
    else
        LA.UpdateTrackerUI()
        LA.RefreshVisibility()
    end
end

function LA.SetupSceneManagement()
    local achievementScenes = {
        ["achievements"] = true,
        ["achievementsGamepad"] = true,
        ["groupMenuKeyboard"] = true,
        ["zoneStoriesGamepad"] = true, -- Scena Przewodnika Gamepad
    }

    local function OnSceneStateChange(scene, oldState, newState)
        if newState == SCENE_SHOWING then
            local name = scene:GetName()
            
            -- Domyślne czyszczenie widoczności (nie dotyczy HUD)
            if name ~= "hud" and name ~= "hudui" then
                if LA.historyPanel then LA.historyPanel:SetHidden(true) end
            end
            
            if achievementScenes[name] then
                LA.isTempCentered = true 
                if LA.uiContainer then
                    LA.uiContainer:ClearAnchors()
                    
                    local offsetX = 0
                    if IsInGamepadPreferredMode() then
                        offsetX = 450 -- Przesunięcie w prawo dla gamepada
                    else
                        offsetX = -550 -- Przesunięcie w lewo dla PC (jeśli używane)
                    end
                    
                    LA.uiContainer:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, 0)
                    LA.RefreshVisibility() 
                end
                
                -- Jeśli to NIE JEST przewodnik na padzie -> Pokaż historię (czyli PC, Dziennik itp.)
                if name ~= "zoneStoriesGamepad" then
                    if LA.savedVars.recentHistory and #LA.savedVars.recentHistory > 0 then
                        if LA.ShowHistoryMenu then LA.ShowHistoryMenu(nil) end
                    end
                else
                    -- Jeśli to JEST przewodnik na padzie -> Ukryj historię
                    if LA.historyPanel then LA.historyPanel:SetHidden(true) end
                end
                
            elseif name == "hud" or name == "hudui" then
                if LA.isTempCentered then
                    LA.isTempCentered = false 
                    if LA.uiContainer then
                        LA.uiContainer:ClearAnchors()
                        local left = LA.savedVars.left or 20
                        local top = LA.savedVars.top or 600
                        LA.uiContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                    end
                end
                
                LA.UpdateTrackerUI()
                LA.RefreshVisibility()
            end
            
            LA.RefreshVisibility()
        end
    end
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChange)
end


local function OnAddOnLoaded(event, addonName)
    if addonName ~= LA.name then return end
    EVENT_MANAGER:UnregisterForEvent(LA.name, EVENT_ADD_ON_LOADED)

    InitializeLanguage()
    LA.savedVars = ZO_SavedVars:NewAccountWide("LiveAchieverVars", 1, nil, LA.defaultVars, GetWorldName())

    if not LA.savedVars.recentHistory then LA.savedVars.recentHistory = {} end
    
    for achId, _ in pairs(LA.savedVars.trackedAchievements) do
        local numCriteria = GetAchievementNumCriteria(achId)
        local totalCurrent = 0
        if numCriteria > 0 then
            for critIndex = 1, numCriteria do
                local _, current = GetAchievementCriterion(achId, critIndex)
                totalCurrent = totalCurrent + (current or 0)
            end
        end
        LA.progressCache[achId] = totalCurrent
    end

    local now = GetTimeStamp() * 1000
    if LA.savedVars.accumulations then
        for achId, data in pairs(LA.savedVars.accumulations) do
            if data and data.expiry and data.expiry > now then
                LA.accumulatedDiffs[achId] = data.diff
                local remaining = data.expiry - now
                LA.timerInfos[achId] = (LA.timerInfos[achId] or 0) + 1
                local myTimerId = LA.timerInfos[achId]
                zo_callLater(function()
                    if LA.timerInfos[achId] == myTimerId then
                        LA.accumulatedDiffs[achId] = 0
                        if LA.savedVars.accumulations then LA.savedVars.accumulations[achId] = nil end
                        LA.UpdateTrackerUI()
                    end
                end, remaining)
            else
                LA.savedVars.accumulations[achId] = nil
            end
        end
    end

    CreateTrackerWindow()
    LA.UpdateTrackerUI()
    LA.UpdateAddButtonState()
    
    if IsInGamepadPreferredMode() then
        if LA.InitGamepad then LA.InitGamepad() end
    else
        if LA.InitKeyboard then LA.InitKeyboard() end
    end

    if LA.CreateSettingsMenu and type(LA.CreateSettingsMenu) == "function" then 
        LA.CreateSettingsMenu() 
    end

    if LA.SetupSceneManagement then LA.SetupSceneManagement() end

    local scenesToModify = { 
        "achievements",  
        "zoneStories"    
    }
    
    for _, sceneName in ipairs(scenesToModify) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            if LA.uiContainer then 
                scene:AddFragment(ZO_SimpleSceneFragment:New(LA.uiContainer)) 
            end
            if LA.historyPanel then 
                scene:AddFragment(ZO_SimpleSceneFragment:New(LA.historyPanel)) 
            end
        end
    end
    
    EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdated)
    EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_PLAYER_ACTIVATED, function()
        LA.UpdateTrackerUI()
        LA.RefreshVisibility()
    end)
    
    EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_KEYUP, function(_, key)
        if IsChatSystemAccessingLastActiveChannel() then return end 
        if IsInGamepadPreferredMode() then return end 

        if key == KEY_LEFT_ARROW then
            LA.NavigateList(-1)
        elseif key == KEY_RIGHT_ARROW then
            LA.NavigateList(1)
        elseif key == KEY_ENTER then
            local list = LA.GetCombinedNavList()
            if list and list[LA.historyIndex] then 
                LA.ToggleTracking(list[LA.historyIndex].id) 
                zo_callLater(function() LA.HighlightCurrentSelection() end, 100)
            end
        end
    end)
    
	EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_RETICLE_HIDDEN_UPDATE, function(_, hidden)
        if not hidden then
            if LA.historyPanel then LA.historyPanel:SetHidden(true) end
        end
    end)

    if LA.savedVars.hideInCombat and IsUnitInCombat("player") and LA.uiContainer then
        LA.uiContainer:SetHidden(true)
    end
end

EVENT_MANAGER:RegisterForEvent(LA.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)