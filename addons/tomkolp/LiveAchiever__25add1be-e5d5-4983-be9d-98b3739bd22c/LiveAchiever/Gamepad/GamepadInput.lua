if not LiveAchiever then return end
local LA = LiveAchiever

LA.rightTooltip = nil
LA.rightTooltipLabel = nil
LA.gamepadKeybindStrip = nil
LA.gamepadKeybindStripZone = nil

-- ============================================================================
-- 1. FUNKCJA POMOCNICZA: Tłumaczenie typu aktywności na ID osiągnięcia
-- ============================================================================
local function GetAchievementIdFromCompletionType(zoneId, completionType)
    if not zoneId or not completionType then return nil end
    
    local num = GetNumAssociatedAchievementsForZoneCompletionType(zoneId, completionType)
    if num > 0 then
        local aid = GetAssociatedAchievementIdForZoneCompletionType(zoneId, completionType, 1)
        if aid > 0 then return aid end
    end
    
    if GetZoneStoryActivityCompletionTypeInfo then
        local _,_,_,_,_, achId = GetZoneStoryActivityCompletionTypeInfo(zoneId, completionType)
        if achId and achId > 0 then return achId end
    end

    return nil
end

-- ============================================================================
-- 2. STANDARDOWA LOGIKA GAMEPADA (GŁÓWNE MENU OSIĄGNIĘĆ)
-- ============================================================================
function LA.GetGamepadTargetId()
    if not ACHIEVEMENTS_GAMEPAD then return nil end

    local list = nil
    if ACHIEVEMENTS_GAMEPAD.GetCurrentList then
        list = ACHIEVEMENTS_GAMEPAD:GetCurrentList()
    end
    if not list and ACHIEVEMENTS_GAMEPAD.achievementList then
        list = ACHIEVEMENTS_GAMEPAD.achievementList
    end
    
    if list and list.GetTargetData then
        local data = list:GetTargetData()
        if data then
            if data.id then return data.id end
            if data.dataSource and data.dataSource.id then return data.dataSource.id end
            if data.achievementId then return data.achievementId end
        end
    end
    return nil
end

function LA.InitGamepad()
    -- --- DYMEK (Tooltip) ---
    if not LA.rightTooltip then
        local tlw = WINDOW_MANAGER:CreateTopLevelWindow("LiveAchieverRightTooltip")
        tlw:SetResizeToFitDescendents(true)
        tlw:SetDrawLayer(DL_OVERLAY)
        tlw:SetDrawTier(DT_HIGH)
        tlw:SetHidden(true)
        tlw:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -40, -180) 

        local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
        bg:SetCenterColor(0, 0, 0, 0.9)
        bg:SetEdgeColor(0.4, 0.4, 0.4, 0.8)
        bg:SetEdgeTexture("", 1, 1, 1)

        local label = WINDOW_MANAGER:CreateControl("$(parent)Label", tlw, CT_LABEL)
        label:SetFont("ZoFontGamepadBold22")
        label:SetColor(1, 1, 1, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) 
        label:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -15, 10)

        bg:SetAnchor(TOPLEFT, label, TOPLEFT, -15, -10)
        bg:SetAnchor(BOTTOMRIGHT, label, BOTTOMRIGHT, 15, 10)
        bg:SetExcludeFromResizeToFitExtents(true)

        LA.rightTooltip = tlw
        LA.rightTooltipLabel = label
    end

    local function UpdateRightTooltip()
        if not LA.rightTooltip then return end
        if not ACHIEVEMENTS_GAMEPAD or not ACHIEVEMENTS_GAMEPAD:IsShowing() then
            LA.rightTooltip:SetHidden(true)
            return
        end

        local targetId = LA.GetGamepadTargetId()
        if targetId then
            local rawName = GetAchievementName(targetId)
            local cleanName = zo_strformat("<<C:1>>", rawName)
            local actionText = LA.savedVars.trackedAchievements[targetId] and ("|cFF0000" .. LA.strings.Menu_StopTrack .. "|r") or ("|c00FF00" .. LA.strings.Menu_Track .. "|r")
            local pressText = LA.strings.Menu_Btn_Press or "Press Right Stick"
            LA.rightTooltipLabel:SetText(string.format("|cBBBBBB%s|r\n%s: |cFFFFFF%s|r", pressText, actionText, cleanName))
            LA.rightTooltip:SetHidden(false)
        else
            LA.rightTooltip:SetHidden(true)
        end
    end

    -- --- PRAWY DRĄŻEK (IKONA NA PASKU) ---
    local trackKeybind = {
        name = "", 
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        order = 1000, 
        callback = function()
            local id = LA.GetGamepadTargetId()
            if id then 
                LA.ToggleTracking(id) 
                UpdateRightTooltip() 
            end
        end,
        visible = function() return LA.GetGamepadTargetId() ~= nil end,
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
    }

    local function InjectKeybind()
        if ACHIEVEMENTS_GAMEPAD then
            if ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor then
                table.insert(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor, trackKeybind)
            end
            if ACHIEVEMENTS_GAMEPAD.listKeybindStripDescriptor then
                table.insert(ACHIEVEMENTS_GAMEPAD.listKeybindStripDescriptor, trackKeybind)
            end
        end
    end
    zo_callLater(InjectKeybind, 500)

    if ACHIEVEMENTS_GAMEPAD then
        SecurePostHook(ACHIEVEMENTS_GAMEPAD, "OnSelectionChanged", function()
            if ACHIEVEMENTS_GAMEPAD:IsShowing() then
                UpdateRightTooltip()
                if ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor then
                    KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
                end
            end
        end)
    end
    
    -- --- LEWA STRONA (HISTORIA) ---
    LA.gamepadKeybindStrip = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = function()
                local combinedList = LA.GetCombinedNavList()
                if combinedList and #combinedList > 0 then
                    if LA.historyIndex > #combinedList then LA.historyIndex = 1 end
                    local item = combinedList[LA.historyIndex]
                    if not item then return "" end
                    local rawName = GetAchievementName(item.id)
                    local cleanName = zo_strformat("<<C:1>>", rawName)
                    local prefix = (item.type == "TRACKED") and (LA.strings.Nav_Tracked) or (LA.strings.Nav_History)
                    local action = (item.type == "TRACKED") and (LA.strings.Nav_Action_Remove) or (LA.strings.Nav_Action_Add)
                    return string.format("%s [%d/%d]: %s %s", prefix, LA.historyIndex, #combinedList, cleanName, action)
                end
                return ""
            end,
            keybind = "UI_SHORTCUT_LEFT_STICK",
            callback = function()
                local combinedList = LA.GetCombinedNavList()
                if combinedList and #combinedList > 0 then
                    if LA.historyIndex > #combinedList then LA.historyIndex = 1 end
                    local item = combinedList[LA.historyIndex]
                    if item then 
                        LA.ToggleTracking(item.id)
                        zo_callLater(function() 
                            if LA.HighlightCurrentSelection then LA.HighlightCurrentSelection() end
                        end, 100)
                    end
                end
            end,
            visible = function() local list = LA.GetCombinedNavList(); return list and #list > 0 end,
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
        },
        {
            name = function() return LA.strings.Hist_Prev end,
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                if LA.NavigateList then LA.NavigateList(-1) else
                    local combinedList = LA.GetCombinedNavList()
                    if combinedList and #combinedList > 1 then
                        LA.historyIndex = (LA.historyIndex > 1) and (LA.historyIndex - 1) or #combinedList
                        if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip) end
                    end
                end
            end,
            visible = function() local list = LA.GetCombinedNavList(); return list and #list > 1 end,
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
        },
        {
            name = function() return LA.strings.Hist_Next end,
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                if LA.NavigateList then LA.NavigateList(1) else
                    local combinedList = LA.GetCombinedNavList()
                    if combinedList and #combinedList > 1 then
                        LA.historyIndex = (LA.historyIndex < #combinedList) and (LA.historyIndex + 1) or 1
                        if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStrip) end
                    end
                end
            end,
            visible = function() local list = LA.GetCombinedNavList(); return list and #list > 1 end,
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
        }
    }

    local scene = SCENE_MANAGER:GetScene("achievementsGamepad")
    if scene then
        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                LA.historyIndex = 1
                KEYBIND_STRIP:AddKeybindButtonGroup(LA.gamepadKeybindStrip)
                UpdateRightTooltip() 
                if LA.HighlightCurrentSelection then LA.HighlightCurrentSelection() end
            elseif newState == SCENE_HIDDEN then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(LA.gamepadKeybindStrip)
                if LA.rightTooltip then LA.rightTooltip:SetHidden(true) end
            end
        end)
    end
end

-- ============================================================================
-- 3. ZONE GUIDE GAMEPAD (NAPRAWIONE MAŁE IKONY I ODŚWIEŻANIE)
-- ============================================================================

local function GetZoneGuideGamepadTargetId()
    if not ZONE_STORIES_GAMEPAD or not ZONE_STORIES_GAMEPAD.gridList then return nil end
    local selectedData = ZONE_STORIES_GAMEPAD.gridList:GetSelectedData()
    if not selectedData then return nil end

    -- 1. Bezpośrednie ID (dla dużych kafelków lub jeśli mała ikona już je otrzymała)
    if selectedData.achievementId then return selectedData.achievementId end
    if selectedData.id then return selectedData.id end

    -- 2. Małe ikony (gdy ID jeszcze nie zostało wpisane przez hook)
    if selectedData.completionType then
        local zoneId = nil
        -- Próbujemy pobrać strefę z samego kafelka (najpewniejsze źródło)
        if selectedData.zoneId then 
            zoneId = selectedData.zoneId 
        -- Jeśli brak, bierzemy z głównego managera (np. po zmianie strefy)
        elseif ZONE_STORIES_GAMEPAD.zoneId then
            zoneId = ZONE_STORIES_GAMEPAD.zoneId
        end

        -- UWAGA: Usunięto tutaj 'GetCurrentMapZoneIndex()'. 
        -- Dzięki temu nie pobieramy strefy "fizycznej", jeśli przeglądamy inną mapę.

        if zoneId then
            local calculatedId = GetAchievementIdFromCompletionType(zoneId, selectedData.completionType)
            if calculatedId and calculatedId > 0 then
                return calculatedId
            end
        end
    end

    return nil
end

function LA.InitGamepadZoneGuide()

    -- 1. Hook na Layout (Działa jak w PC - wiąże dane ze strefą kafelka)
    if ZO_ZoneStory_ActivityCompletionTile_Gamepad then
        SecurePostHook(ZO_ZoneStory_ActivityCompletionTile_Gamepad, "Layout", function(self, data)
            local tileData = data or self.data
            
            if tileData and tileData.completionType and not tileData.achievementId then
                local zoneId = nil
                -- Najważniejsze: pobieramy ID strefy z obiektu (self.zoneData).
                -- To gwarantuje, że bierzemy strefę, do której należy ten konkretny kafelek.
                if self.zoneData then 
                    zoneId = self.zoneData.id 
                elseif ZONE_STORIES_GAMEPAD and ZONE_STORIES_GAMEPAD.zoneId then
                    zoneId = ZONE_STORIES_GAMEPAD.zoneId
                end

                if zoneId then
                    local aid = GetAchievementIdFromCompletionType(zoneId, tileData.completionType)
                    if aid and aid > 0 then
                        tileData.achievementId = aid
                        if self.control then self.control.achievementId = aid end
                    end
                end
            end
        end)
    end

    -- 2. Hook na RefreshGridList (Naprawa braku przycisku po zmianie strefy)
    if ZONE_STORIES_GAMEPAD then
        SecurePostHook(ZONE_STORIES_GAMEPAD, "RefreshGridList", function()
             -- Po przebudowaniu listy dajemy chwilę na ustawienie zaznaczenia i odświeżamy pasek
             zo_callLater(function()
                 if SCENE_MANAGER:IsShowing("zoneStoriesGamepad") then
                     KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStripZone)
                 end
             end, 150)
        end)
    end

    local zoneKeybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = function()
                local aid = GetZoneGuideGamepadTargetId()
                if not aid then return "" end
                return LA.savedVars.trackedAchievements[aid] and ("|cFF0000" .. LA.strings.Menu_StopTrack .. "|r") or ("|c00FF00" .. LA.strings.Menu_Track .. "|r")
            end,
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function()
                local aid = GetZoneGuideGamepadTargetId()
                if aid then
                    LA.ToggleTracking(tonumber(aid))
                    PlaySound(SOUNDS.MENU_BAR_CLICK)
                    if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStripZone) end
                end
            end,
            visible = function() return GetZoneGuideGamepadTargetId() ~= nil end,
            order = 1000,
        }
    }
    LA.gamepadKeybindStripZone = zoneKeybindStripDescriptor

    local scene = SCENE_MANAGER:GetScene("zoneStoriesGamepad")
    if scene then
        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                KEYBIND_STRIP:AddKeybindButtonGroup(LA.gamepadKeybindStripZone)
                KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStripZone)
                
                if ZONE_STORIES_GAMEPAD and ZONE_STORIES_GAMEPAD.gridList then
                    local existingCallback = ZONE_STORIES_GAMEPAD.gridList.onSelectedDataChangedCallback
                    ZONE_STORIES_GAMEPAD.gridList:SetOnSelectedDataChangedCallback(function(...)
                        KEYBIND_STRIP:UpdateKeybindButtonGroup(LA.gamepadKeybindStripZone)
                        if existingCallback then existingCallback(...) end
                    end)
                end
            elseif newState == SCENE_HIDDEN then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(LA.gamepadKeybindStripZone)
            end
        end)
    end
end

if IsInGamepadPreferredMode() then
    zo_callLater(LA.InitGamepadZoneGuide, 500)
end