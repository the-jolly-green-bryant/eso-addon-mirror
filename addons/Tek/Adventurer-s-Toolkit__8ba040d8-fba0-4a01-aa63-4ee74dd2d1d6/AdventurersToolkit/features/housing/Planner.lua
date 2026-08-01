-- ============================================
-- HOUSING PLANNER (Wishlist) MODULE
-- ============================================

-- Hidden Parametric List Screen class for D-pad navigation
local ATK_HiddenPlannerListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenPlannerListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenPlannerListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, PLANNER_SCENE) end
function ATK_HiddenPlannerListScreen:PerformUpdate() end
function ATK_HiddenPlannerListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Select", keybind = "UI_SHORTCUT_PRIMARY", callback = function() NWT.PlannerSelect() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "New Folder", keybind = "UI_SHORTCUT_SECONDARY", callback = function() NWT.PlannerNewFolder() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Remove", keybind = "UI_SHORTCUT_TERTIARY", callback = function() NWT.PlannerRemoveSelected() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = function() return NWT.PlannerUI.focusPanel == "folders" and "< Housing" or "< Folders" end, keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.PlannerNavigateLB() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = function() return NWT.PlannerUI.focusPanel == "items" and "Finder >" or "Items >" end, keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.PlannerNavigateRB() end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.ClosePlanner() end)
end


-- ============================================
-- STANDALONE PLANNER UI
-- ============================================

NWT.PlannerUI = { isOpen = false, sceneInitialized = false, focusPanel = "folders", selectedFolderIndex = 1, selectedItemIndex = 1, folderScrollOffset = 0, itemScrollOffset = 0 }

function NWT.InitPlannerScene()
    if NWT.PlannerUI.sceneInitialized then return end
    local ui = ATK_Planner_UI
    if not ui then return end
    
    -- Create hidden list for D-pad navigation (like Bookkeeper)
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenPlannerList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hc)
    PLANNER_SCENE = ZO_Scene:New("plannerScene", SCENE_MANAGER)
    PLANNER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    PLANNER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    PLANNER_SCENE:AddFragment(fragment)
    PLANNER_SCENE:AddFragment(hiddenFragment)
    
    NWT.HiddenPlannerListScreen = ATK_HiddenPlannerListScreen:New(hc)
    NWT.HiddenPlannerList = NWT.HiddenPlannerListScreen:GetMainList()
    NWT.HiddenPlannerList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override list movement for D-pad navigation
    NWT.HiddenPlannerList.MovePrevious = function(self, ...)
        NWT.PlannerScroll("up")
    end
    NWT.HiddenPlannerList.MoveNext = function(self, ...)
        NWT.PlannerScroll("down")
    end
    
    PLANNER_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.PlannerUI.isOpen = true
            NWT.UpdatePlannerUI()
            NWT.SyncHiddenPlannerList()
        elseif newState == SCENE_HIDDEN then
            NWT.PlannerUI.isOpen = false
        end
    end)
    
    NWT.PlannerUI.sceneInitialized = true
end

function NWT.SyncHiddenPlannerList()
    if not NWT.HiddenPlannerList then return end
    NWT.HiddenPlannerList:Clear()
    -- Add dummy entries for navigation
    for i = 1, 10 do
        local ed = ZO_GamepadEntryData:New("Item " .. i)
        ed.index = i
        NWT.HiddenPlannerList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenPlannerList:Commit()
end

function NWT.OpenPlanner()
    if NWT.PlannerUI and NWT.PlannerUI.isOpen then return end
    if not ATK_Planner_UI then return end
    -- Close other sibling scenes first to maintain proper scene stack
    if NWT.FurnitureSearch and NWT.FurnitureSearch.isOpen then SCENE_MANAGER:Hide("furnitureSearchScene") end
    if NWT.HousingDashboard and NWT.HousingDashboard.isOpen then SCENE_MANAGER:Hide("housingDashboardScene") end
    NWT.InitPlannerScene()
    if PLANNER_SCENE then 
        SCENE_MANAGER:Push("plannerScene") 
    end
end

function NWT.ClosePlanner()
    if PLANNER_SCENE then SCENE_MANAGER:Hide("plannerScene") end
end

function NWT.PlannerGoToHousing()
    NWT.HousingDashboard.activePanel = "wishlist" -- Enter on right panel
    -- Close current scene first to maintain proper scene stack
    if PLANNER_SCENE then SCENE_MANAGER:Hide("plannerScene") end
    if not HOUSING_DASHBOARD_SCENE then NWT.InitHousingDashboardScene() end
    SCENE_MANAGER:Push("housingDashboardScene")
end

function NWT.PlannerGoToFinder()
    -- Close current scene first to maintain proper scene stack
    if PLANNER_SCENE then SCENE_MANAGER:Hide("plannerScene") end
    if not FURNITURE_SEARCH_SCENE then NWT.InitFurnitureSearchScene() end
    SCENE_MANAGER:Push("furnitureSearchScene")
end

function NWT.PlannerNavigateLB()
    local p = NWT.PlannerUI
    if p.focusPanel == "folders" then
        -- On left panel, go to previous scene (Housing)
        NWT.PlannerGoToHousing()
    else
        -- Move to left panel
        p.focusPanel = "folders"
        NWT.UpdatePlannerUI()
        if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.PlannerKeybinds) end
        PlaySound(SOUNDS.POSITIVE_CLICK)
    end
end

function NWT.PlannerNavigateRB()
    local p = NWT.PlannerUI
    if p.focusPanel == "items" then
        -- On right panel, go to next scene (Finder)
        NWT.PlannerGoToFinder()
    else
        -- Move to right panel
        p.focusPanel = "items"
        NWT.UpdatePlannerUI()
        if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.PlannerKeybinds) end
        PlaySound(SOUNDS.POSITIVE_CLICK)
    end
end

function NWT.PlannerSwitchPanel(dir)
    local p = NWT.PlannerUI
    if dir == "left" then
        p.focusPanel = p.focusPanel == "items" and "folders" or "folders"
    else
        p.focusPanel = p.focusPanel == "folders" and "items" or "items"
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdatePlannerUI()
end

function NWT.PlannerSelect()
    local p = NWT.PlannerUI
    if p.focusPanel == "folders" then
        p.focusPanel = "items"
        p.selectedItemIndex = 1
        p.itemScrollOffset = 0
    end
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdatePlannerUI()
end

function NWT.PlannerNewFolder()
    local newName = "Project " .. GetTimeStamp()
    NWT.CreateWishlistProject(newName)
    NWT.UpdatePlannerUI()
end

function NWT.PlannerRemoveSelected()
    local p = NWT.PlannerUI
    if p.focusPanel == "folders" then
        -- Remove selected folder
        local folders = NWT.GetPlannerFolders()
        local folderName = folders[p.selectedFolderIndex]
        if folderName then
            NWT.DeleteWishlistProject(folderName)
            -- Adjust selection if needed
            if p.selectedFolderIndex > 1 then
                p.selectedFolderIndex = p.selectedFolderIndex - 1
            end
            -- Update active project
            local newFolders = NWT.GetPlannerFolders()
            if newFolders[p.selectedFolderIndex] then
                NWT.savedVars.wishlist.activeProject = newFolders[p.selectedFolderIndex]
            end
        end
    elseif p.focusPanel == "items" then
        -- Remove selected item
        local items = NWT.GetPlannerItems()
        local item = items[p.selectedItemIndex]
        if item then
            NWT.RemoveFromWishlist(item.key)
            if p.selectedItemIndex > 1 then
                p.selectedItemIndex = p.selectedItemIndex - 1
            end
        end
    end
    NWT.UpdatePlannerUI()
end

function NWT.PlannerScroll(dir)
    local p = NWT.PlannerUI
    if p.focusPanel == "folders" then
        local folders = NWT.GetPlannerFolders()
        if dir == "up" and p.selectedFolderIndex > 1 then
            p.selectedFolderIndex = p.selectedFolderIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and p.selectedFolderIndex < #folders then
            p.selectedFolderIndex = p.selectedFolderIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
        local sv = NWT.savedVars.wishlist
        if sv and folders[p.selectedFolderIndex] then
            sv.activeProject = folders[p.selectedFolderIndex]
        end
    else
        local items = NWT.GetPlannerItems()
        if dir == "up" and p.selectedItemIndex > 1 then
            p.selectedItemIndex = p.selectedItemIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and p.selectedItemIndex < #items then
            p.selectedItemIndex = p.selectedItemIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    end
    NWT.UpdatePlannerUI()
    if KEYBIND_STRIP then KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.PlannerKeybinds) end
end

function NWT.GetPlannerFolders()
    local sv = NWT.savedVars.wishlist
    local folders = {}
    if sv and sv.projects then
        for name, _ in pairs(sv.projects) do
            table.insert(folders, name)
        end
        table.sort(folders)
    end
    return folders
end

function NWT.GetPlannerItems()
    local sv = NWT.savedVars.wishlist
    local items = {}
    if sv and sv.projects and sv.activeProject then
        local proj = sv.projects[sv.activeProject]
        if proj then
            for key, data in pairs(proj) do
                table.insert(items, { key = key, name = data.name or tostring(key), count = data.count or 1, added = data.added or data.timestamp })
            end
            table.sort(items, function(a, b) return a.name < b.name end)
        end
    end
    return items
end

function NWT.UpdatePlannerUI()
    local ui = ATK_Planner_UI
    if not ui then return end
    
    local p = NWT.PlannerUI
    local sv = NWT.savedVars.wishlist
    local isFoldersFocus = (p.focusPanel == "folders")
    local isItemsFocus = (p.focusPanel == "items")
    
    -- Header
    local header = ui:GetNamedChild("Header")
    if header then
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then subtitle:SetText("|cFFFFFFOrganize furniture for your decorating projects|r") end
    end
    
    -- Left Column - Folders
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        local foldersCard = leftCol:GetNamedChild("FoldersCard")
        if foldersCard then
            local bg = foldersCard:GetNamedChild("BG")
            local glow = foldersCard:GetNamedChild("FocusGlow")
            local plate = foldersCard:GetNamedChild("HeaderPlate")
            if isFoldersFocus then
                if bg then bg:SetEdgeColor(0.67, 1, 0.67, 1) end
                if glow then glow:SetHidden(false) end
                if plate then plate:SetEdgeColor(0.67, 1, 0.67, 1) end
            else
                if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
                if glow then glow:SetHidden(true) end
                if plate then plate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            end
            
            local list = foldersCard:GetNamedChild("List")
            local selFrame = list and list:GetNamedChild("SelectionFrame")
            local folders = NWT.GetPlannerFolders()
            
            for i = 1, 10 do
                local label = list and list:GetNamedChild("Folder" .. i)
                if label then
                    local idx = i + p.folderScrollOffset
                    if folders[idx] then
                        local isActive = (sv.activeProject == folders[idx])
                        local isSel = (idx == p.selectedFolderIndex)
                        local prefix = isSel and "► " or "  "
                        local color = isActive and "|cAAFFAA" or "|cFFFFFF"
                        local star = isActive and " ★" or ""
                        label:SetText(color .. prefix .. folders[idx] .. star .. "|r")
                        label:SetHidden(false)
                        
                        if isSel and selFrame and isFoldersFocus then
                            selFrame:ClearAnchors()
                            selFrame:SetAnchor(TOPLEFT, list, TOPLEFT, 5, (i-1) * 40 - 2)
                            selFrame:SetHidden(false)
                        end
                    else
                        label:SetHidden(true)
                    end
                end
            end
            if not isFoldersFocus and selFrame then selFrame:SetHidden(true) end
        end
    end
    
    -- Center Column - Items
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        local bg = centerCol:GetNamedChild("BG")
        local glow = centerCol:GetNamedChild("FocusGlow")
        local plate = centerCol:GetNamedChild("HeaderPlate")
        if isItemsFocus then
            if bg then bg:SetEdgeColor(0.67, 1, 0.67, 1) end
            if glow then glow:SetHidden(false) end
            if plate then plate:SetEdgeColor(0.67, 1, 0.67, 1) end
        else
            if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if glow then glow:SetHidden(true) end
            if plate then plate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
        end
        
        local folderName = centerCol:GetNamedChild("FolderName")
        if folderName then folderName:SetText("|cAAFFAA" .. (sv.activeProject or "Default") .. "|r") end
        
        local items = NWT.GetPlannerItems()
        local itemCount = centerCol:GetNamedChild("ItemCount")
        if itemCount then itemCount:SetText(#items .. " items in folder") end
        
        local list = centerCol:GetNamedChild("List")
        local selFrame = list and list:GetNamedChild("SelectionFrame")
        
        for i = 1, 15 do
            local label = list and list:GetNamedChild("Item" .. i)
            if label then
                local idx = i + p.itemScrollOffset
                if items[idx] then
                    local item = items[idx]
                    local isSel = (idx == p.selectedItemIndex)
                    local nameText = item.name or "Unknown"
                    if #nameText > 40 then nameText = nameText:sub(1,38) .. ".." end
                    local addedText = item.added and NWT.FormatTimeAgo(item.added) or ""
                    label:SetText(string.format("|c888888%2d|r  |cFFFFFF%s|r  |cFFFF00x%d|r  |c888888%s|r", idx, nameText, item.count or 1, addedText))
                    label:SetHidden(false)
                    
                    if isSel and selFrame and isItemsFocus then
                        selFrame:ClearAnchors()
                        selFrame:SetAnchor(TOPLEFT, list, TOPLEFT, 5, (i-1) * 36 - 2)
                        selFrame:SetHidden(false)
                    end
                else
                    label:SetText("")
                    label:SetHidden(true)
                end
            end
        end
        if not isItemsFocus and selFrame then selFrame:SetHidden(true) end
        
        local summary = centerCol:GetNamedChild("Summary")
        if summary then
            local totalQty = 0
            for _, item in ipairs(items) do totalQty = totalQty + (item.count or 1) end
            summary:SetText(string.format("|c888888%d unique items  •  %d total pieces|r", #items, totalQty))
        end
    end
    
    -- Right Column - Selected Item
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        local selCard = rightCol:GetNamedChild("SelectedCard")
        if selCard then
            local items = NWT.GetPlannerItems()
            local item = items[p.selectedItemIndex]
            local name = selCard:GetNamedChild("Name")
            local qty = selCard:GetNamedChild("Quantity")
            local added = selCard:GetNamedChild("Added")
            
            if item then
                if name then name:SetText("|c00FFFF" .. (item.name or "Unknown") .. "|r") end
                if qty then qty:SetText("|c888888Quantity:|r  |cFFFF00x" .. (item.count or 1) .. "|r") end
                if added then added:SetText("|c888888Added:|r  " .. (item.added and NWT.FormatTimeAgo(item.added) or "Unknown")) end
            else
                if name then name:SetText("|c666666No item selected|r") end
                if qty then qty:SetText("") end
                if added then added:SetText("") end
            end
        end
        
        -- Item Actions
        local actionsCard = rightCol:GetNamedChild("ItemActionsCard")
        if actionsCard then
            local a1 = actionsCard:GetNamedChild("Action1")
            local a2 = actionsCard:GetNamedChild("Action2")
            local a3 = actionsCard:GetNamedChild("Action3")
            local a4 = actionsCard:GetNamedChild("Action4")
            if a1 then a1:SetText("|cFFFFFF[A]|r Select / Open") end
            if a2 then a2:SetText("|cFFFFFF[X]|r Remove from folder") end
            if a3 then a3:SetText("|cFFFFFF[+/-]|r Adjust quantity") end
            if a4 then a4:SetText("|cFFFFFF[RS]|r Move to folder") end
        end
    end
end
