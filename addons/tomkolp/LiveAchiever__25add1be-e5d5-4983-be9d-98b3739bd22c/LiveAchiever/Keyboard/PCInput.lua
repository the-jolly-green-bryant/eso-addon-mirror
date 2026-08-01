if not LiveAchiever then return end
local LA = LiveAchiever

LA.zonePanel = nil
LA.zoneScrollChild = nil
LA.dynamicFragments = {}
LA.detectedAchievements = {} 
LA.refreshPending = false
LA.zonePanelExpandedStates = {} -- [NOWE] Tabela do przechowywania stanu rozwinięcia tylko dla Panelu Strefy

-- ============================================================================
-- 1. OBSŁUGA KLIKNIĘĆ W LINKI
-- ============================================================================

local function HandleLinkClick(link, button, text, color, linkType, achievementId)
    if linkType == "LiveAchieverTrack" then
        LA.ToggleTracking(tonumber(achievementId))
        return true
    end
end

-- ============================================================================
-- 2. TWORZENIE OKNA
-- ============================================================================

local function CreateZonePanel()
    if LA.zonePanel then return end
    local f = LA.GetDynamicFontInfo()

    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("LiveAchieverZonePanel")
    tlw:SetDimensions(380, 200)
    tlw:SetHidden(true)
    tlw:SetClampedToScreen(true)
    tlw:SetMovable(false)
    tlw:SetMouseEnabled(true)
    
    local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 0, 0)
    local alphaPercent = LA.savedVars.backgroundAlpha or 0
    bg:SetCenterColor(0, 0, 0, alphaPercent / 100)
    bg:SetEdgeColor(0, 0, 0, 0)
    
    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", tlw, CT_LABEL)
    title:SetText(LA.strings.Zone_Panel_Title)
    title:SetFont(f.titleFont) 
    title:SetColor(1, 0.8, 0, 1)
    title:SetAnchor(TOP, tlw, TOP, 0, 5)
    
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Scroll", tlw, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 35)
    scroll:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -10, -10)
    
    LA.zonePanel = tlw
    LA.zoneScrollChild = scroll:GetNamedChild("ScrollChild")
end

local function DockZonePanel()
    if not LA.zonePanel then return end
    if LA.uiContainer then
        LA.zonePanel:ClearAnchors()
        LA.zonePanel:SetAnchor(BOTTOMLEFT, LA.uiContainer, TOPLEFT, 0, -5)
        LA.zonePanel:SetWidth(LA.uiContainer:GetWidth())
    end
end

-- ============================================================================
-- 3. RYSOWANIE LISTY
-- ============================================================================

local function ToggleZoneExpand(achId)
    -- [ZMIANA] Używamy lokalnej tabeli zamiast savedVars.expandedStates
    if not LA.zonePanelExpandedStates[achId] then
        LA.zonePanelExpandedStates[achId] = true
    else
        LA.zonePanelExpandedStates[achId] = false
    end
    LA.RenderZonePanel()
    -- Usunięto wywołanie LA.UpdateTrackerUI(), ponieważ zmiana dotyczy tylko widoku strefy
end

function LA.RenderZonePanel()
    LA.refreshPending = false
    if not LA.zonePanel or not LA.zoneScrollChild then return end

    local f = LA.GetDynamicFontInfo()
    local SCROLL_WIDTH = LA.zoneScrollChild:GetWidth()
    
    local numChildren = LA.zoneScrollChild:GetNumChildren()
    for i = 1, numChildren do
        LA.zoneScrollChild:GetChild(i):SetHidden(true)
    end
    
    local cPoolIndex = 1
    while true do
        local cLabel = LA.zoneScrollChild:GetNamedChild("ZoneCrit" .. cPoolIndex)
        if not cLabel then break end
        cLabel:SetHidden(true)
        cPoolIndex = cPoolIndex + 1
    end
    cPoolIndex = 1

    local sortedIds = {}
    for id, _ in pairs(LA.detectedAchievements) do
        table.insert(sortedIds, id)
    end
    table.sort(sortedIds, function(a, b) 
        return GetAchievementName(a) < GetAchievementName(b) 
    end)
    
    local index = 0
    local currentY = 0
    
    for _, achId in ipairs(sortedIds) do
        local _, _, _, _, completed = GetAchievementInfo(achId)
        
        if not completed then
            index = index + 1
            
            local rowName = "RowContainer" .. index
            local rowContainer = LA.zoneScrollChild:GetNamedChild(rowName)
            if not rowContainer then
                rowContainer = WINDOW_MANAGER:CreateControl("$(parent)" .. rowName, LA.zoneScrollChild, CT_CONTROL)
                rowContainer:SetMouseEnabled(true)
            end
            
            local expandBtn = rowContainer:GetNamedChild("ExpandBtn")
            if not expandBtn then
                expandBtn = WINDOW_MANAGER:CreateControl("$(parent)ExpandBtn", rowContainer, CT_BUTTON)
                expandBtn:SetAnchor(TOPLEFT, rowContainer, TOPLEFT, 2, 2)
            end
            
            local label = rowContainer:GetNamedChild("Label")
            if not label then
                label = WINDOW_MANAGER:CreateControl("$(parent)Label", rowContainer, CT_LABEL)
                label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                label:SetAnchor(TOPLEFT, expandBtn, TOPRIGHT, 5, 0)
            end

            expandBtn:SetDimensions(f.btnSize, f.btnSize)
            label:SetFont(f.rowFont)
            
            local name = GetAchievementName(achId)
            local isTracked = LA.savedVars.trackedAchievements[achId]
            
            -- [ZMIANA] Pobieranie stanu rozwinięcia z lokalnej tabeli
            local isExpanded = LA.zonePanelExpandedStates[achId]
            
            name = zo_strformat("<<C:1>>", name)
            label:SetText(name)
            
            if isTracked then
                label:SetColor(0, 1, 0, 1)
            else
                label:SetColor(0.9, 0.9, 0.9, 1)
            end

            label:SetWidth(SCROLL_WIDTH - f.btnSize - 10)
            local textHeight = label:GetTextHeight()
            local baseRowHeight = math.max(f.rowHeight, textHeight + 4)
            
            expandBtn:SetNormalTexture(isExpanded and "EsoUI/Art/Buttons/minus_up.dds" or "EsoUI/Art/Buttons/plus_up.dds")
            expandBtn:SetHandler("OnClicked", function() ToggleZoneExpand(achId) end)
            
            rowContainer:SetHandler("OnMouseUp", function() 
                LA.ToggleTracking(achId)
                if LA.savedVars.trackedAchievements[achId] then
                    label:SetColor(0, 1, 0, 1)
                else
                    label:SetColor(1, 1, 0, 1)
                end
                label:SetText(name)
            end)
            
            rowContainer:SetHandler("OnMouseEnter", function(self)
                if not LA.savedVars.trackedAchievements[achId] then
                    label:SetColor(1, 1, 0, 1)
                end
                if LA.ShowSmartTooltip then LA.ShowSmartTooltip(self, achId) end
            end)
            
            rowContainer:SetHandler("OnMouseExit", function(self)
                if LA.savedVars.trackedAchievements[achId] then
                    label:SetColor(0, 1, 0, 1)
                else
                    label:SetColor(0.9, 0.9, 0.9, 1)
                end
                ClearTooltip(ItemTooltip)
            end)

            rowContainer:SetHidden(false)
            rowContainer:ClearAnchors()
            rowContainer:SetAnchor(TOPLEFT, LA.zoneScrollChild, TOPLEFT, 0, currentY)
            
            local currentRowHeight = baseRowHeight
            
            if isExpanded then
                local numCriteria = GetAchievementNumCriteria(achId)
                if numCriteria > 0 then
                    local critY = baseRowHeight
                    
                    for cIndex = 1, numCriteria do
                        local cDesc, cCur, cReq = GetAchievementCriterion(achId, cIndex)
                        if not cDesc or cDesc == "" then 
                            cDesc = string.format("%s %d", LA.strings.HUD_Crit_Default, cIndex) 
                        end
                        cDesc = zo_strformat("<<1>>", cDesc)
                        
                        local cText = string.format("• %s: %d/%d", cDesc, cCur, cReq)
                        local cColor = {0.7, 0.7, 0.7, 1}
                        if cCur >= cReq then 
                            cColor = {0, 1, 0, 1}
                            cText = string.format("• %s (V)", cDesc) 
                        end
                        
                        local cLabelName = "ZoneCrit" .. cPoolIndex
                        local cLabel = LA.zoneScrollChild:GetNamedChild(cLabelName)
                        if not cLabel then
                            cLabel = WINDOW_MANAGER:CreateControl("$(parent)" .. cLabelName, LA.zoneScrollChild, CT_LABEL)
                            cLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                        end
                        
                        cLabel:SetFont(f.critFont)
                        cLabel:SetWidth(SCROLL_WIDTH - 25)
                        cLabel:SetText(cText)
                        cLabel:SetColor(unpack(cColor))
                        cLabel:SetHidden(false)
                        cLabel:ClearAnchors()
                        cLabel:SetAnchor(TOPLEFT, rowContainer, TOPLEFT, 25, critY)
                        
                        local ch = cLabel:GetTextHeight()
                        if ch == 0 then ch = 18 end
                        critY = critY + ch + 2
                        cPoolIndex = cPoolIndex + 1
                    end
                    currentRowHeight = critY + 5 
                end
            end
            
            rowContainer:SetDimensions(SCROLL_WIDTH, currentRowHeight)
            currentY = currentY + currentRowHeight + 2
        end
    end
    
    local finalHeight = math.max(60, math.min(currentY + 45, 400))
    LA.zonePanel:SetHeight(finalHeight)

    local emptyLbl = LA.zoneScrollChild:GetNamedChild("Empty")
    if index == 0 then
        if not emptyLbl then
            emptyLbl = WINDOW_MANAGER:CreateControl("$(parent)Empty", LA.zoneScrollChild, CT_LABEL)
            emptyLbl:SetFont(f.rowFont)
            emptyLbl:SetText(LA.strings.Zone_Panel_Empty)
            emptyLbl:SetColor(0.5, 0.5, 0.5, 1)
            emptyLbl:SetAnchor(TOPLEFT, LA.zoneScrollChild, TOPLEFT, 0, 0)
        end
        emptyLbl:SetHidden(false)
    else
        if emptyLbl then emptyLbl:SetHidden(true) end
    end
    
    DockZonePanel()
    
    local bg = LA.zonePanel:GetNamedChild("Bg")
    if bg then
        local alphaPercent = LA.savedVars.backgroundAlpha or 0
        bg:SetCenterColor(0, 0, 0, alphaPercent / 100)
    end
end

-- ============================================================================
-- 4. LOGIKA POBIERANIA DANYCH
-- ============================================================================

local function GetAchievementIdFromCompletionType(zoneId, completionType)
    if not zoneId or not completionType then return nil end
    
    -- Sprawdzamy czy dla danego typu aktywności w tej strefie są osiągnięcia
    local num = GetNumAssociatedAchievementsForZoneCompletionType(zoneId, completionType)
    if num > 0 then
        -- Pobieramy ID pierwszego powiązanego osiągnięcia
        local aid = GetAssociatedAchievementIdForZoneCompletionType(zoneId, completionType, 1)
        if aid > 0 then return aid end
    end
    
    -- Opcjonalna metoda dodatkowa
    if GetZoneStoryActivityCompletionTypeInfo then
        local _,_,_,_,_, achId = GetZoneStoryActivityCompletionTypeInfo(zoneId, completionType)
        if achId and achId > 0 then return achId end
    end

    return nil
end

local function GetIdFromData(data, fallbackZoneId)
    if not data then return nil end
    
    -- 1. Standardowe kafelki (Duże)
    if data.achievementId then return data.achievementId end
    if data.id then return data.id end
    
    -- 2. Małe ikonki (Activity Tiles)
    if data.completionType then
        -- Priorytet 1: ZoneID z danych kafelka
        local zoneId = data.zoneId
        
        -- Priorytet 2: Fallback (np. z self.zoneData)
        if not zoneId then zoneId = fallbackZoneId end
        
        -- Priorytet 3: Globalny manager
        if not zoneId and ZONE_STORIES_KEYBOARD then
            zoneId = ZONE_STORIES_KEYBOARD.zoneId
        end
        
        if zoneId then
            local derivedId = GetAchievementIdFromCompletionType(zoneId, data.completionType)
            if derivedId and derivedId > 0 then return derivedId end
        end
    end
    return nil
end

local function CaptureTileData(control, data, fallbackZoneId)
    local aid = GetIdFromData(data, fallbackZoneId)
    
    if aid and aid > 0 then
        if not LA.detectedAchievements[aid] then
            LA.detectedAchievements[aid] = true
            if not LA.refreshPending then
                LA.refreshPending = true
                zo_callLater(LA.RenderZonePanel, 100)
            end
        end
    end
end

function LA.ScrapeCurrentGrid()
    if not ZONE_STORIES_KEYBOARD then return end
    
    -- Próbujemy ustalić ID strefy
    local globalZoneId = ZONE_STORIES_KEYBOARD.zoneId
    if not globalZoneId then
        local mapZoneIndex = GetCurrentMapZoneIndex()
        if mapZoneIndex then
            globalZoneId = GetZoneId(mapZoneIndex)
        end
    end
    
    local foundAny = false
    
    -- 1. Skanowanie głównej listy (duże kafelki)
    if ZONE_STORIES_KEYBOARD.gridList and ZONE_STORIES_KEYBOARD.gridList.dataList then
        for _, entry in ipairs(ZONE_STORIES_KEYBOARD.gridList.dataList) do
            if entry.data then
                local aid = GetIdFromData(entry.data, globalZoneId)
                if aid and aid > 0 then
                    LA.detectedAchievements[aid] = true
                    foundAny = true
                end
            end
        end
    end
    
    -- 2. Skanowanie małych ikonek (jeśli lista jest dostępna)
    if ZONE_STORIES_KEYBOARD.activityCompletionList and ZONE_STORIES_KEYBOARD.activityCompletionList.dataList then
        for _, entry in ipairs(ZONE_STORIES_KEYBOARD.activityCompletionList.dataList) do
            if entry.data then
                local aid = GetIdFromData(entry.data, globalZoneId)
                if aid and aid > 0 then
                    LA.detectedAchievements[aid] = true
                    foundAny = true
                end
            end
        end
    end
    
    if foundAny then
        LA.RenderZonePanel()
    end
end

-- ============================================================================
-- 5. WIDOCZNOŚĆ
-- ============================================================================

local function SetupVisibility()
    if not LA.dynamicFragments["main"] and LA.uiContainer then
        LA.dynamicFragments["main"] = ZO_SimpleSceneFragment:New(LA.uiContainer)
    end
    if not LA.dynamicFragments["history"] and LA.historyPanel then
        LA.dynamicFragments["history"] = ZO_SimpleSceneFragment:New(LA.historyPanel)
    end
    if not LA.dynamicFragments["zone"] and LA.zonePanel then
        LA.dynamicFragments["zone"] = ZO_SimpleSceneFragment:New(LA.zonePanel)
    end

    local function AddWindowsToScene(sceneName)
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            if LA.dynamicFragments["main"] then scene:AddFragment(LA.dynamicFragments["main"]) end
            if LA.dynamicFragments["history"] then scene:AddFragment(LA.dynamicFragments["history"]) end
            
            if LA.dynamicFragments["zone"] and not IsInGamepadPreferredMode() then 
                scene:AddFragment(LA.dynamicFragments["zone"]) 
            end
            
            if LA.uiContainer then LA.uiContainer:SetHidden(false) end
            if LA.historyPanel then LA.historyPanel:SetHidden(false) end
            
            if LA.zonePanel and not IsInGamepadPreferredMode() then 
                LA.zonePanel:SetHidden(false) 
                DockZonePanel()
            end
            
            if LA.UpdateHistoryPanelPosition then LA.UpdateHistoryPanelPosition() end
        end
    end
    
    local function RemoveWindowsFromScene(sceneName)
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            if LA.dynamicFragments["zone"] then scene:RemoveFragment(LA.dynamicFragments["zone"]) end
        end
    end

    if ZONE_STORIES_FRAGMENT then
        ZONE_STORIES_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
            local currentSceneName = SCENE_MANAGER:GetCurrentSceneName()
            
            if newState == SCENE_FRAGMENT_SHOWING then
                if not IsInGamepadPreferredMode() then
                    LA.ScrapeCurrentGrid()
                end
                AddWindowsToScene(currentSceneName)
                
            elseif newState == SCENE_FRAGMENT_HIDING then
                RemoveWindowsFromScene(currentSceneName)
                if LA.zonePanel then LA.zonePanel:SetHidden(true) end
            end
        end)
    end
end

-- ============================================================================
-- 6. INICJALIZACJA I HOOKI
-- ============================================================================

function LA.InitKeyboard()
    if ShowMenu then
        ZO_PreHook("ShowMenu", function(control)
            if IsInGamepadPreferredMode() then return end
            
            local achievementId = nil
            if control and control.data then achievementId = control.data.id or control.data.achievementId end
            if not achievementId and control and ZO_ScrollList_GetData then
                local data = ZO_ScrollList_GetData(control)
                if data then achievementId = data.id or data.achievementId end
            end
            if not achievementId and control then
                if control.achievementId then achievementId = control.achievementId
                elseif control.achievement and type(control.achievement.GetId) == "function" then achievementId = control.achievement:GetId() end
            end

            if achievementId then
                if LA.savedVars.trackedAchievements[achievementId] then
                    AddMenuItem(LA.strings.Menu_StopTrack, function() LA.ToggleTracking(achievementId) end)
                else
                    AddMenuItem(LA.strings.Menu_Track, function() LA.ToggleTracking(achievementId) end)
                end
            end
            return false 
        end)
    end

    CreateZonePanel()
    SetupVisibility()

    -- Hook na duże kafelki osiągnięć
    if ZO_ZoneStory_AchievementTile_Keyboard then
        SecurePostHook(ZO_ZoneStory_AchievementTile_Keyboard, "Layout", function(self, data)
            CaptureTileData(self.control, data)
        end)
    end
    
    -- Hook na kafelki zadań
    if ZO_ZoneStory_TaskCompletionTile_Keyboard then
        SecurePostHook(ZO_ZoneStory_TaskCompletionTile_Keyboard, "Layout", function(self, data)
            CaptureTileData(self.control, data)
        end)
    end

    -- Hook na małe ikonki (aktywności strefy)
    if ZO_ZoneStory_ActivityCompletionTile_Keyboard then
        SecurePostHook(ZO_ZoneStory_ActivityCompletionTile_Keyboard, "Layout", function(self, data)
            local tileData = data or self.data
            
            if tileData then
                -- Pobieramy ID strefy bezpośrednio z obiektu kafelka (kluczowe!)
                local fallbackZoneId = nil
                if self.zoneData then
                    fallbackZoneId = self.zoneData.id
                end
                
                local aid = GetIdFromData(tileData, fallbackZoneId)
                
                if aid and aid > 0 then
                    -- Wstrzykujemy znalezione ID, aby CaptureTileData i menu kontekstowe je widziały
                    tileData.achievementId = aid
                    if self.control then self.control.achievementId = aid end
                    CaptureTileData(self.control, tileData)
                end
            end
        end)
    end

    if ZONE_STORIES_KEYBOARD then
        ZO_PreHook(ZONE_STORIES_KEYBOARD, "BuildGridList", function()
             LA.detectedAchievements = {}
             LA.RenderZonePanel()
             zo_callLater(LA.ScrapeCurrentGrid, 500)
        end)
    end

    if LINK_HANDLER and LINK_HANDLER.RegisterCallback then
        if LINK_HANDLER.LINK_MOUSE_UP_EVENT then
            LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleLinkClick)
        end
        if LINK_HANDLER.LINK_CLICKED_EVENT then
            LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleLinkClick)
        end
    end
end