-- ============================================
-- HOUSING MODULE (Dashboard/Scene Orchestrator)
-- ============================================
-- Supporting features are split into:
--   features/housing/FurnitureSearch.lua
--   features/housing/CrownCapture.lua
--   features/housing/HousingSettings.lua

-- Localize globals for performance
local math_floor = math.floor
local string_format = string.format

NWT.HousingDashboard = { 
    isOpen = false, 
    sceneInitialized = false, 
    selectedHouseIndex = 1, 
    houseScrollOffset = 0,
    maxVisibleHouses = 8,  -- Matches XML House1-House8
    sortedHouses = {},
    selectedWishlistIndex = 1,
    wishlistItems = {},
    activePanel = "houses",
    selectedFinderIndex = 1,
    finderItems = {},
    finderScrollOffset = 0,
    maxVisibleRows = 15,
    filterMode = 1,  -- 1=All, 2=Favorites Only
    filterModes = {"All Houses", "Favorites"},
}

-- Hidden Parametric List Screen class for D-pad navigation
local ATK_HiddenHouseListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()

function ATK_HiddenHouseListScreen:New(control)
    return ZO_Gamepad_ParametricList_Screen.New(self, control)
end

function ATK_HiddenHouseListScreen:Initialize(control)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NWT.HousingDashboardScene)
end

function ATK_HiddenHouseListScreen:PerformUpdate()
end

function ATK_HiddenHouseListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                return NWT.HousingDashboard.activePanel == "houses" and "Travel" or "Select"
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                local hd = NWT.HousingDashboard
                if hd.activePanel == "houses" then
                    NWT.TravelToSelectedHouse()
                end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = "Refresh",
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                NWT.ScanAllHouses()
                NWT.UpdateHousingDashboard()
NWT.Debug("|c00FF00[Housing]|r Stats refreshed")
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                local hd = NWT.HousingDashboard
                if hd.activePanel == "houses" then
                    local house = hd.sortedHouses[hd.selectedHouseIndex]
                    if house then
                        local isFav = NWT.savedVars.housingFavorites and NWT.savedVars.housingFavorites[house.houseId]
                        return isFav and "Unfavorite" or "Favorite"
                    end
                end
                return "Remove Item"
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function()
                local hd = NWT.HousingDashboard
                if hd.activePanel == "houses" then
                    NWT.ToggleHouseFavorite()
                else
                    if NWT.HousingWishlistRemoveItem then NWT.HousingWishlistRemoveItem() end
                end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                local hd = NWT.HousingDashboard
                return "Filter: " .. (hd.filterModes[hd.filterMode] or "All")
            end,
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                NWT.CycleHousingFilter()
            end,
            visible = function()
                return NWT.HousingDashboard.activePanel == "houses"
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                return NWT.HousingDashboard.activePanel == "houses" and "Settings" or "< Houses"
            end,
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                local hd = NWT.HousingDashboard
                if hd.activePanel == "houses" then
                    NWT.OpenHousingSettings()
                else
                    -- Go back to houses panel
                    hd.activePanel = "houses"
                    NWT.SyncHiddenHouseList()
                    NWT.UpdateHousingDashboardVisuals()
                    if NWT.UpdateHousingWishlistVisuals then NWT.UpdateHousingWishlistVisuals() end
                    PlaySound(SOUNDS.POSITIVE_CLICK)
                    KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHouseListScreen.keybindStripDescriptor)
                end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                return NWT.HousingDashboard.activePanel == "houses" and "Items >" or "Planner >"
            end,
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                local hd = NWT.HousingDashboard
                if hd.activePanel == "houses" then
                    -- Move to right panel (items/wishlist)
                    hd.activePanel = "wishlist"
                    NWT.UpdateHousingDashboard()
                    PlaySound(SOUNDS.POSITIVE_CLICK)
                else
                    -- On right panel, go to next scene (Planner)
                    if NWT.OpenPlanner then NWT.OpenPlanner() end
                end
            end,
        },
    }
    local function OnBack()
        NWT.CloseHousingDashboard()
    end
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, OnBack)
end

function NWT.HousingDashboardSwitchPanel(direction)
    local hd = NWT.HousingDashboard
    if hd.activePanel == "houses" then
        hd.activePanel = "wishlist"
    else
        hd.activePanel = "houses"
    end
    
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    NWT.SyncHiddenHouseList()
    NWT.UpdateHousingDashboardVisuals()
    if NWT.UpdateHousingWishlistVisuals then NWT.UpdateHousingWishlistVisuals() end
    
    if KEYBIND_STRIP and NWT.HiddenHouseListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHouseListScreen.keybindStripDescriptor)
    end
end

function NWT.InitHousingDashboardScene()
    if NWT.HousingDashboard.sceneInitialized then return end
    local ui = ATK_Housing_UI or ATK_Housing_UI
    if not ui then return end
    
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenHouseList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    
    NWT.HousingDashboardScene = ZO_Scene:New("housingDashboardScene", SCENE_MANAGER)
    NWT.HousingDashboardScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NWT.HousingDashboardScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HousingDashboardScene:AddFragment(fragment)
    NWT.HousingDashboardScene:AddFragment(hiddenFragment)
    
    NWT.HiddenHouseListScreen = ATK_HiddenHouseListScreen:New(hiddenControl)
    NWT.HiddenHouseList = NWT.HiddenHouseListScreen:GetMainList()
    
    local function SetupHiddenEntry(control, data, selected, reselectingDuringRebuild, enabled, active)
        local label = control:GetNamedChild("Label")
        if label then label:SetText(data.name or "") end
    end
    
    NWT.HiddenHouseList:AddDataTemplate("ZO_GamepadItemEntryTemplate", SetupHiddenEntry, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override list movement for D-pad navigation (like Bookkeeper does)
    NWT.HiddenHouseList.MovePrevious = function(self, ...)
        NWT.HousingScroll("up")
    end
    NWT.HiddenHouseList.MoveNext = function(self, ...)
        NWT.HousingScroll("down")
    end
    
    NWT.HiddenHouseList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if selectedData and selectedData.index then
            local hd = NWT.HousingDashboard
            if hd.activePanel == "houses" then
                hd.selectedHouseIndex = selectedData.index
                if hd.selectedHouseIndex <= hd.houseScrollOffset then
                    hd.houseScrollOffset = hd.selectedHouseIndex - 1
                elseif hd.selectedHouseIndex > hd.houseScrollOffset + hd.maxVisibleHouses then
                    hd.houseScrollOffset = hd.selectedHouseIndex - hd.maxVisibleHouses
                end
                NWT.UpdateHousingDashboardVisuals()
            elseif hd.activePanel == "wishlist" then
                hd.selectedWishlistIndex = selectedData.index
                if NWT.UpdateHousingWishlistVisuals then NWT.UpdateHousingWishlistVisuals() end
            end
        end
    end)
    
    NWT.HiddenHouseList:SetOnMovementChangedCallback(function(list, movement)
        if movement == MOVEMENT_CONTROLLER_MOVE_NEXT_HORIZONTAL then
            NWT.HousingDashboardSwitchPanel("right")
        elseif movement == MOVEMENT_CONTROLLER_MOVE_PREVIOUS_HORIZONTAL then
            NWT.HousingDashboardSwitchPanel("left")
        end
    end)
    
    NWT.HousingDashboardScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.HousingDashboard.isOpen = true
            NWT.UpdateHousingDashboard()
        elseif newState == SCENE_HIDDEN then
            NWT.HousingDashboard.isOpen = false
        end
    end)
    NWT.HousingDashboard.sceneInitialized = true
end

function NWT.HousingScroll(dir)
    local hd = NWT.HousingDashboard
    if hd.activePanel == "houses" then
        if dir == "up" and hd.selectedHouseIndex > 1 then
            hd.selectedHouseIndex = hd.selectedHouseIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and hd.selectedHouseIndex < #hd.sortedHouses then
            hd.selectedHouseIndex = hd.selectedHouseIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
        -- Update scroll offset to keep selection visible
        if hd.selectedHouseIndex <= hd.houseScrollOffset then
            hd.houseScrollOffset = hd.selectedHouseIndex - 1
        elseif hd.selectedHouseIndex > hd.houseScrollOffset + hd.maxVisibleHouses then
            hd.houseScrollOffset = hd.selectedHouseIndex - hd.maxVisibleHouses
        end
    elseif hd.activePanel == "wishlist" then
        if dir == "up" and hd.selectedWishlistIndex > 1 then
            hd.selectedWishlistIndex = hd.selectedWishlistIndex - 1
            PlaySound(SOUNDS.GAMEPAD_MENU_BACKWARD)
        elseif dir == "down" and hd.wishlistItems and hd.selectedWishlistIndex < #hd.wishlistItems then
            hd.selectedWishlistIndex = hd.selectedWishlistIndex + 1
            PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
        end
    end
    NWT.UpdateHousingDashboardVisuals()
    if NWT.UpdateHousingWishlistVisuals then NWT.UpdateHousingWishlistVisuals() end
    if KEYBIND_STRIP and NWT.HiddenHouseListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHouseListScreen.keybindStripDescriptor)
    end
end

function NWT.UpdateHousingDashboardVisuals()
    local ui = ATK_Housing_UI or ATK_Housing_UI
    if not ui then return end
    local hd = NWT.HousingDashboard
    local leftCol = ui:GetNamedChild("LeftCol")
    local centerCol = ui:GetNamedChild("CenterCol")
    local leftPanel = leftCol or ui:GetNamedChild("LeftPanel")
    if not leftPanel then return end
    local colors = NWT.GetColors()
    local isHousesPanel = (hd.activePanel == "houses")
    local isItemsPanel = (hd.activePanel == "wishlist")
    
    -- Update focus highlights for left column (houses)
    if leftCol then
        local housesCard = leftCol:GetNamedChild("HousesCard")
        if housesCard then
            local bg = housesCard:GetNamedChild("BG")
            local glow = housesCard:GetNamedChild("FocusGlow")
            local plate = housesCard:GetNamedChild("HeaderPlate")
            if isHousesPanel then
                if bg then bg:SetEdgeColor(1, 0, 1, 1) end
                if glow then glow:SetHidden(false) end
                if plate then plate:SetEdgeColor(1, 0, 1, 1) end
            else
                if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
                if glow then glow:SetHidden(true) end
                if plate then plate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            end
        end
    end
    
    -- Update focus highlights for center column (items/wishlist)
    if centerCol then
        local bg = centerCol:GetNamedChild("BG")
        local glow = centerCol:GetNamedChild("FocusGlow")
        local plate = centerCol:GetNamedChild("HeaderPlate")
        if isItemsPanel then
            if bg then bg:SetEdgeColor(1, 0, 1, 1) end
            if glow then glow:SetHidden(false) end
            if plate then plate:SetEdgeColor(1, 0, 1, 1) end
        else
            if bg then bg:SetEdgeColor(0.3, 0.3, 0.3, 1) end
            if glow then glow:SetHidden(true) end
            if plate then plate:SetEdgeColor(0.3, 0.3, 0.3, 1) end
        end
    end
    
    local header = leftPanel:GetNamedChild("Header")
    if header then
        header:SetText(isHousesPanel and "|cFFD700>> Your Houses <<|r" or "|cFFFFAAYour Houses|r")
    end
    
    local offset = hd.houseScrollOffset or 0
    local housesCard = leftPanel:GetNamedChild("HousesCard")
    local listParent = housesCard and housesCard:GetNamedChild("List") or leftPanel
    for i = 1, hd.maxVisibleHouses do
        local houseLabel = listParent:GetNamedChild("House" .. i) or leftPanel:GetNamedChild("House" .. i)
        if not houseLabel then break end
        local dataIndex = i + offset
        if hd.sortedHouses[dataIndex] then
            local data = hd.sortedHouses[dataIndex]
            local color = "|c" .. colors.positive
            if data.pct >= 90 then color = "|c" .. colors.negative
            elseif data.pct >= 70 then color = "|c" .. colors.warning
            end
            local prefix = (dataIndex == hd.selectedHouseIndex and isHousesPanel) and "|cFFD700> |r" or ""
            local isFav = NWT.savedVars.housingFavorites and NWT.savedVars.housingFavorites[data.houseId]
            local star = isFav and "|cFFD700*|r" or ""
            houseLabel:SetText(string_format("%s%s|cFFFFFF%s|r: %s%d/%d|r (%d%%)", prefix, star, data.name, color, data.count, data.limit, data.pct))
        else
            houseLabel:SetText("")
        end
    end
    
    -- Update center panel with selected house details
    if centerCol and hd.sortedHouses[hd.selectedHouseIndex] then
        local house = hd.sortedHouses[hd.selectedHouseIndex]
        local houseName = centerCol:GetNamedChild("HouseName")
        if houseName then houseName:SetText("|cFF00FF" .. (house.name or "Unknown House") .. "|r") end
        
        local location = centerCol:GetNamedChild("Location")
        if location then location:SetText("|c888888Select a house to view details|r") end
        
        -- Stats section
        local stats = centerCol:GetNamedChild("Stats")
        if stats then
            local items = stats:GetNamedChild("Items")
            if items then items:SetText(string_format("|cFFFFAAItems:|r %d", house.count or 0)) end
            local traditional = stats:GetNamedChild("Traditional")
            if traditional then traditional:SetText(string_format("|cFFFFAALimit:|r %d", house.limit or 0)) end
            local special = stats:GetNamedChild("Special")
            if special then special:SetText(string_format("|cFFFFAAUsed:|r %d%%", house.pct or 0)) end
            
            local cached = NWT.savedVars.furnitureCache and NWT.savedVars.furnitureCache[house.houseId]
            local value = stats:GetNamedChild("Value")
            if value then 
                if cached and cached.goldValue then
                    value:SetText(string_format("|c00FF00Est. Value:|r %sg", NWT.FormatGold(cached.goldValue)))
                else
                    value:SetText("|c00FF00Est. Value:|r |c888888Visit to scan|r")
                end
            end
            local crownValue = stats:GetNamedChild("CrownValue")
            if crownValue then 
                if cached and (cached.crownValue or 0) > 0 then
                    crownValue:SetText(string_format("|cFFD700Crown Value:|r %s crowns", NWT.FormatGold(cached.crownValue)))
                else
                    crownValue:SetText("")
                end
            end
            local slotsUsed = stats:GetNamedChild("SlotsUsed")
            if slotsUsed then 
                if cached and (cached.writVouchers or 0) > 0 then
                    slotsUsed:SetText(string_format("|c00FFFFWrit Vouchers:|r %s WV", NWT.FormatGold(cached.writVouchers)))
                else
                    slotsUsed:SetText("")
                end
            end
            
            -- Progress bar
            local progressFill = stats:GetNamedChild("ProgressFill")
            if progressFill then
                local fillWidth = math.min(660, math.max(1, math_floor(660 * (house.pct or 0) / 100)))
                progressFill:SetWidth(fillWidth)
                -- Color based on percentage
                if house.pct >= 90 then progressFill:SetCenterColor(1, 0.3, 0.3, 1)
                elseif house.pct >= 70 then progressFill:SetCenterColor(1, 1, 0.3, 1)
                else progressFill:SetCenterColor(1, 0, 1, 1) end
            end
            local progressText = stats:GetNamedChild("ProgressText")
            if progressText then progressText:SetText(string_format("|cFFFFFF%d / %d slots|r", house.count or 0, house.limit or 0)) end
        end
        
        -- Top items list (placeholder - needs furniture cache)
        local itemsList = centerCol:GetNamedChild("ItemsList")
        if itemsList then
            local cached = NWT.savedVars.furnitureCache and NWT.savedVars.furnitureCache[house.houseId]
            for i = 1, 10 do
                local itemLabel = itemsList:GetNamedChild("Item" .. i)
                if itemLabel then
                    if cached and cached.items and cached.items[i] then
                        itemLabel:SetText(string_format("|cFFFFFF%d.|r %s", i, cached.items[i]))
                    else
                        itemLabel:SetText(i == 1 and "|c888888Visit house to scan furniture|r" or "")
                    end
                end
            end
        end
    end
    
    -- Update Total Summary panel
    local summaryCard = leftCol and leftCol:GetNamedChild("SummaryCard")
    if summaryCard then
        local totalHouses = summaryCard:GetNamedChild("TotalHouses")
        local totalItems = summaryCard:GetNamedChild("TotalItems")
        local totalSlots = summaryCard:GetNamedChild("TotalSlots")
        local totalValue = summaryCard:GetNamedChild("TotalValue")
        
        local houseCount, itemCount, slotCount = 0, 0, 0
        for _, h in ipairs(hd.sortedHouses) do
            houseCount = houseCount + 1
            itemCount = itemCount + (h.count or 0)
            slotCount = slotCount + (h.limit or 0)
        end
        
        if totalHouses then totalHouses:SetText(string_format("|cFFFFAAHouses:|r %d", houseCount)) end
        if totalItems then totalItems:SetText(string_format("|cFFFFAATotal Items:|r %d", itemCount)) end
        if totalSlots then totalSlots:SetText(string_format("|cFFFFAATotal Slots:|r %d", slotCount)) end
        if totalValue then totalValue:SetText(string_format("|cFFFFAAUsage:|r %d%%", slotCount > 0 and math_floor(itemCount / slotCount * 100) or 0)) end
    end
end

function NWT.SyncHiddenHouseList()
    if not NWT.HiddenHouseList then return end
    local hd = NWT.HousingDashboard
    NWT.HiddenHouseList:Clear()
    
    if hd.activePanel == "houses" then
        for i, data in ipairs(hd.sortedHouses) do
            local entryData = ZO_GamepadEntryData:New(data.name or "House")
            entryData.houseId, entryData.houseName, entryData.index = data.houseId, data.name, i
            NWT.HiddenHouseList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
        end
        NWT.HiddenHouseList:Commit()
        if hd.selectedHouseIndex and hd.selectedHouseIndex <= #hd.sortedHouses then
            NWT.HiddenHouseList:SetSelectedIndexWithoutAnimation(hd.selectedHouseIndex)
        end
    else
        if NWT.SyncHiddenPlannerList then NWT.SyncHiddenPlannerList() end
    end
end

-- Toggle favorite status for selected house
function NWT.ToggleHouseFavorite()
    local hd = NWT.HousingDashboard
    local house = hd.sortedHouses[hd.selectedHouseIndex]
    if not house then return end
    
    if not NWT.savedVars.housingFavorites then NWT.savedVars.housingFavorites = {} end
    
    if NWT.savedVars.housingFavorites[house.houseId] then
        NWT.savedVars.housingFavorites[house.houseId] = nil
NWT.Debug("|cFF00FF[Housing]|r Removed " .. house.name .. " from favorites")
    else
        NWT.savedVars.housingFavorites[house.houseId] = true
NWT.Debug("|cFF00FF[Housing]|r Added " .. house.name .. " to favorites")
    end
    
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateHousingDashboardVisuals()
    if KEYBIND_STRIP and NWT.HiddenHouseListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHouseListScreen.keybindStripDescriptor)
    end
end

-- Cycle through filter modes
function NWT.CycleHousingFilter()
    local hd = NWT.HousingDashboard
    hd.filterMode = hd.filterMode >= #hd.filterModes and 1 or hd.filterMode + 1
    hd.selectedHouseIndex = 1
    hd.houseScrollOffset = 0
NWT.Debug("|cFF00FF[Housing]|r Filter: " .. hd.filterModes[hd.filterMode])
    PlaySound(SOUNDS.POSITIVE_CLICK)
    NWT.UpdateHousingDashboard()
    if KEYBIND_STRIP and NWT.HiddenHouseListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenHouseListScreen.keybindStripDescriptor)
    end
end

function NWT.UpdateHousingDashboard()
    local ui = ATK_Housing_UI or ATK_Housing_UI
    if not ui then return end
    local hd = NWT.HousingDashboard
    NWT.RebuildHousingFilterModes()  -- Rebuild filters including custom categories
    local stats = NWT.ScanAllHouses()
    
    -- Build list of all houses first
    local allHouses = {}
    for id, data in pairs(stats) do table.insert(allHouses, data) end
    
    -- Add demo data if no houses found
    if #allHouses == 0 then
        allHouses = {
            { houseId = 1, name = "Alinor Crest Townhouse", count = 245, limit = 400, pct = 61 },
            { houseId = 2, name = "Coldharbour Surreal Estate", count = 580, limit = 600, pct = 97 },
            { houseId = 3, name = "Grand Psijic Villa", count = 320, limit = 700, pct = 46 },
            { houseId = 4, name = "Hakkvild's High Hall", count = 175, limit = 350, pct = 50 },
            { houseId = 5, name = "Linchal Grand Manor", count = 425, limit = 600, pct = 71 },
            { houseId = 6, name = "Moonsugar Meadow", count = 88, limit = 200, pct = 44 },
            { houseId = 7, name = "Sleek Creek House", count = 150, limit = 200, pct = 75 },
            { houseId = 8, name = "Stay-Moist Mansion", count = 290, limit = 400, pct = 73 },
        }
    end
    
    -- Apply filter
    hd.sortedHouses = {}
    local favorites = NWT.savedVars.housingFavorites or {}
    local cats = NWT.savedVars.housingCategories or {}
    for _, house in ipairs(allHouses) do
        if hd.filterMode == 1 then -- All houses
            table.insert(hd.sortedHouses, house)
        elseif hd.filterMode == 2 and favorites[house.houseId] then -- Favorites only
            table.insert(hd.sortedHouses, house)
        elseif hd.filterMode > 2 then -- Custom category
            local catIndex = hd.filterMode - 2
            local cat = cats[catIndex]
            if cat and cat.houses and cat.houses[house.houseId] then
                table.insert(hd.sortedHouses, house)
            end
        end
    end
    
    table.sort(hd.sortedHouses, function(a, b) return a.name < b.name end)
    
    if hd.selectedHouseIndex > #hd.sortedHouses then hd.selectedHouseIndex = math.max(1, #hd.sortedHouses) end
    
    if NWT.BuildWishlistItems then NWT.BuildWishlistItems() end
    
    NWT.UpdateHousingDashboardVisuals()
    if NWT.UpdateHousingWishlistVisuals then NWT.UpdateHousingWishlistVisuals() end
    if NWT.UpdateHousingWishlistPanel then NWT.UpdateHousingWishlistPanel() end
    
    NWT.SyncHiddenHouseList()
    local updated = ui:GetNamedChild("Updated")
    if updated then updated:SetText("|c888888Last updated: " .. GetTimeString() .. "|r") end
end

function NWT.TravelToSelectedHouse()
    local hd = NWT.HousingDashboard
    if not hd.sortedHouses or #hd.sortedHouses == 0 then return end
    local sel = hd.sortedHouses[hd.selectedHouseIndex]
    if not sel or not sel.houseId then return end
    local houseId, houseName = sel.houseId, sel.name or "house"
    SCENE_MANAGER:ShowBaseScene()
    zo_callLater(function()
        RequestJumpToHouse(houseId)
NWT.Debug("|c00FF00[Housing]|r Traveling to " .. houseName .. "...")
    end, 100)
end

function NWT.OpenHousingDashboard()
    if NWT.HousingDashboard.isOpen then return end
    -- Close other sibling scenes first to maintain proper scene stack
    if NWT.PlannerUI and NWT.PlannerUI.isOpen then SCENE_MANAGER:Hide("plannerScene") end
    if NWT.FurnitureSearch and NWT.FurnitureSearch.isOpen then SCENE_MANAGER:Hide("furnitureSearchScene") end
    NWT.InitHousingDashboardScene()
    if not NWT.HousingDashboardScene then return end
    SCENE_MANAGER:Push("housingDashboardScene")
end

function NWT.CloseHousingDashboard()
    if NWT.HousingDashboardScene then SCENE_MANAGER:Hide("housingDashboardScene") end
end
