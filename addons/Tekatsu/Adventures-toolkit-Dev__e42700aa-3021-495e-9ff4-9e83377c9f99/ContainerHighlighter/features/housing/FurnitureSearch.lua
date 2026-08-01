-- ============================================
-- FURNITURE SEARCH
-- ============================================
local math_floor = math.floor

NWT.FurnitureSearch = { isOpen = false, sceneInitialized = false, searchText = "", results = {}, selectedIndex = 1, scrollOffset = 0, lastNavTime = 0, navCooldown = 200 }

local function IsHouseOwned(houseId)
    local collectibleId = GetCollectibleIdForHouse(houseId)
    return collectibleId and collectibleId > 0 and IsCollectibleUnlocked(collectibleId) or false
end

-- Crown price lookup by item ID or name
local function GetCrownPriceById(itemId)
    if not ATCrownPriceData or not ATCrownPriceData.byId then return nil end
    local data = ATCrownPriceData.byId[itemId]
    return data and data.price or nil
end

local function GetCrownPriceByName(itemName)
    if not ATCrownPriceData then return nil end
    if not itemName or itemName == "" then return nil end
    
    -- Try direct name lookup first
    if ATCrownPriceData.byName then
        local price = ATCrownPriceData.byName[itemName]
        if price then return price end
    end
    
    -- Try byId table by name match (case-insensitive)
    if ATCrownPriceData.byId then
        local searchName = string.lower(itemName)
        for _, data in pairs(ATCrownPriceData.byId) do
            if data.name and string.lower(data.name) == searchName then
                return data.price
            end
        end
    end
    
    return nil
end

local function GetCrownPrice(itemNameOrId, itemId)
    -- Try by ID first if provided
    if itemId then
        local price = GetCrownPriceById(itemId)
        if price then return price end
    end
    -- Fall back to name lookup
    return GetCrownPriceByName(itemNameOrId)
end

local function FurnitureSearchExecute(searchTerm)
    if not searchTerm or searchTerm == "" then return {} end
    searchTerm = string.lower(searchTerm)
    local results = {}
    
    -- Vault
    local vaultItems = {}
    local slotId = GetNextFurnitureVaultSlotId(nil)
    if slotId then
        while slotId do
            local itemName = GetItemName(BAG_FURNITURE_VAULT, slotId)
            if itemName and string.find(string.lower(itemName), searchTerm) then table.insert(vaultItems, itemName) end
            slotId = GetNextFurnitureVaultSlotId(slotId)
        end
    else
        for _, itemName in ipairs(NWT.savedVars.furnitureVaultCache and NWT.savedVars.furnitureVaultCache.items or {}) do
            if itemName and string.find(string.lower(itemName), searchTerm) then table.insert(vaultItems, itemName) end
        end
    end
    
    if #vaultItems > 0 then
        local grouped = {}
        for _, name in ipairs(vaultItems) do grouped[name] = (grouped[name] or 0) + 1 end
        for name, count in pairs(grouped) do table.insert(results, { location = "|cFFD700Furniture Vault|r", item = name, count = count }) end
    end
    
    -- Current House (only if owned)
    local currentHouseId = GetCurrentZoneHouseId()
    if currentHouseId and currentHouseId > 0 and IsOwnerOfCurrentHouse() then
        local houseItems = {}
        local fId = GetNextPlacedHousingFurnitureId(nil)
        while fId do
            local itemName = GetPlacedHousingFurnitureInfo(fId)
            if itemName and string.find(string.lower(itemName), searchTerm) then table.insert(houseItems, itemName) end
            fId = GetNextPlacedHousingFurnitureId(fId)
        end
        if #houseItems > 0 then
            local cId = GetCollectibleIdForHouse(currentHouseId)
            local hName = GetCollectibleName(cId) or "Current House"
            local grouped = {}
            for _, name in ipairs(houseItems) do grouped[name] = (grouped[name] or 0) + 1 end
            for name, count in pairs(grouped) do table.insert(results, { location = "|c00FFFF" .. hName .. "|r", item = name, count = count }) end
        end
    end
    
    -- Cached Houses
    for houseId, houseData in pairs(NWT.savedVars.furnitureCache or {}) do
        local numHouseId = tonumber(houseId)
        if numHouseId and numHouseId ~= currentHouseId and IsHouseOwned(numHouseId) then
            local hName = houseData.houseName or ("House " .. houseId)
            local houseItems = {}
            for _, itemName in ipairs(houseData.items or {}) do
                if itemName and string.find(string.lower(itemName), searchTerm) then table.insert(houseItems, itemName) end
            end
            if #houseItems > 0 then
                local grouped = {}
                for _, name in ipairs(houseItems) do grouped[name] = (grouped[name] or 0) + 1 end
                for name, count in pairs(grouped) do table.insert(results, { location = "|c88FF88" .. hName .. "|r", item = name, count = count }) end
            end
        end
    end
    return results
end

local function UpdateFurnitureSearchUI()
    local ui = ATK_FurnitureSearch_UI
    if not ui then return end
    local fs = NWT.FurnitureSearch
    local maxVisible = 12
    
    -- Find the correct control path: LeftCol/ResultsCard
    local leftCol = ui:GetNamedChild("LeftCol")
    local resultsCard = leftCol and leftCol:GetNamedChild("ResultsCard")
    local listCtrl = resultsCard and resultsCard:GetNamedChild("List")
    
    -- Update search text display
    local searchText = resultsCard and resultsCard:GetNamedChild("SearchText")
    if searchText then
        searchText:SetText((fs.searchText and fs.searchText ~= "") and ("\"" .. fs.searchText .. "\"") or "(press [A] to search)")
    end
    
    -- Update header
    local header = resultsCard and resultsCard:GetNamedChild("Header")
    if header then
        if #fs.results > 0 then
            local scrollInfo = #fs.results > maxVisible and (" (" .. (fs.scrollOffset + 1) .. "-" .. math.min(fs.scrollOffset + maxVisible, #fs.results) .. ")") or ""
            header:SetText("|c00FF00Found " .. #fs.results .. " results|r" .. scrollInfo)
        elseif fs.searchText and fs.searchText ~= "" then
            header:SetText("|cFF6666No results for \"" .. fs.searchText .. "\"|r")
        else
            header:SetText("|cAAFFAASEARCH RESULTS|r")
        end
    end
    
    -- Update result rows
    for i = 1, maxVisible do
        local row = listCtrl and listCtrl:GetNamedChild("Row" .. i)
        local resIdx = i + fs.scrollOffset
        if row then
            if resIdx <= #fs.results then
                local res = fs.results[resIdx]
                local countText = res.count > 1 and (" x" .. res.count) or ""
                local prefix = resIdx == fs.selectedIndex and "|cFFD700> |r" or ""
                local crownPrice = GetCrownPrice(res.item)
                local crownText = crownPrice and (" |cFFAA00[" .. crownPrice .. "]|r") or ""
                row:SetText(prefix .. res.location .. ": " .. res.item .. countText .. crownText)
            else
                row:SetText("")
            end
        end
    end
end

local function FurnitureSearchNavigate(direction)
    local fs = NWT.FurnitureSearch
    local maxVisible = 12
    if #fs.results == 0 then return end
    if direction == "up" then
        fs.selectedIndex = fs.selectedIndex - 1
        if fs.selectedIndex < 1 then fs.selectedIndex = #fs.results fs.scrollOffset = math.max(0, #fs.results - maxVisible)
        elseif fs.selectedIndex <= fs.scrollOffset then fs.scrollOffset = fs.selectedIndex - 1 end
    elseif direction == "down" then
        fs.selectedIndex = fs.selectedIndex + 1
        if fs.selectedIndex > #fs.results then fs.selectedIndex = 1 fs.scrollOffset = 0
        elseif fs.selectedIndex > fs.scrollOffset + maxVisible then fs.scrollOffset = fs.selectedIndex - maxVisible end
    end
    UpdateFurnitureSearchUI()
end

NWT.FurnitureSearch.UpdateDirectionalInput = function(self)
    local now = GetGameTimeMilliseconds()
    if (now - self.lastNavTime) < self.navCooldown then return end
    local y = DIRECTIONAL_INPUT:GetY(ZO_DI_LEFT_STICK)
    if math.abs(y) > 0.5 then
        FurnitureSearchNavigate(y > 0 and "up" or "down")
        self.lastNavTime = now
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
end

function NWT.SetupFurnitureSearchDirectionalInput() DIRECTIONAL_INPUT:Activate(NWT.FurnitureSearch, ATK_FurnitureSearch_UI) end
function NWT.RemoveFurnitureSearchDirectionalInput() DIRECTIONAL_INPUT:Deactivate(NWT.FurnitureSearch) end

local function FurnitureSearchPrompt()
    local fs = NWT.FurnitureSearch
    if fs.searchText ~= "" then
        fs.searchText, fs.results = "", {}
        PlaySound(SOUNDS.POSITIVE_CLICK)
        UpdateFurnitureSearchUI()
        return
    end
    
    if not fs.searchEditBox then
        local eb = WINDOW_MANAGER:CreateControl("FurnitureSearchEditBox", ATK_FurnitureSearch_UI, CT_EDITBOX)
        eb:SetDimensions(400, 40) eb:SetAnchor(CENTER, ATK_FurnitureSearch_UI, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad27") eb:SetMaxInputChars(50) eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            if txt and txt ~= "" then
                fs.searchText = txt
                fs.results = FurnitureSearchExecute(txt)
                fs.selectedIndex, fs.scrollOffset = 1, 0
                PlaySound(SOUNDS.POSITIVE_CLICK)
                NWT.SyncHiddenFurnitureList()
                UpdateFurnitureSearchUI()
            end
            self:SetHidden(true) self:LoseFocus()
        end)
        eb:SetHandler("OnEscape", function(self) self:SetHidden(true) self:LoseFocus() end)
        eb:SetHidden(true) fs.searchEditBox = eb
    end
    fs.searchEditBox:SetText("") fs.searchEditBox:SetHidden(false) fs.searchEditBox:TakeFocus()
end

local ATK_HiddenFurnitureListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenFurnitureListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenFurnitureListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, FURNITURE_SEARCH_SCENE) end
function ATK_HiddenFurnitureListScreen:PerformUpdate() end
function ATK_HiddenFurnitureListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Search", keybind = "UI_SHORTCUT_PRIMARY", callback = function() FurnitureSearchPrompt() PlaySound(SOUNDS.POSITIVE_CLICK) end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Clear", keybind = "UI_SHORTCUT_SECONDARY", callback = function() NWT.FurnitureSearch.searchText, NWT.FurnitureSearch.results = "", {} NWT.SyncHiddenFurnitureList() UpdateFurnitureSearchUI() PlaySound(SOUNDS.POSITIVE_CLICK) end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "< Planner", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.PlannerUI.focusPanel = "items" if NWT.OpenPlanner then NWT.OpenPlanner() end end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Housing >", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.HousingDashboard.activePanel = "houses" NWT.OpenHousingDashboard() end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseFurnitureSearch() end)
end

function NWT.SyncHiddenFurnitureList()
    if not NWT.HiddenFurnitureList then return end
    local fs = NWT.FurnitureSearch
    NWT.HiddenFurnitureList:Clear()
    for i, res in ipairs(fs.results) do
        local ed = ZO_GamepadEntryData:New(res.item or "Item")
        ed.index, ed.result = i, res
        NWT.HiddenFurnitureList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenFurnitureList:Commit()
    if fs.selectedIndex and fs.selectedIndex <= #fs.results then NWT.HiddenFurnitureList:SetSelectedIndexWithoutAnimation(fs.selectedIndex) end
end

function NWT.InitFurnitureSearchScene()
    if NWT.FurnitureSearch.sceneInitialized then return end
    local ui = ATK_FurnitureSearch_UI
    if not ui then return end
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenFurnitureList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    FURNITURE_SEARCH_SCENE = ZO_Scene:New("furnitureSearchScene", SCENE_MANAGER)
    FURNITURE_SEARCH_SCENE:AddFragment(ZO_HUDFadeSceneFragment:New(ui))
    FURNITURE_SEARCH_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    FURNITURE_SEARCH_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    FURNITURE_SEARCH_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HiddenFurnitureListScreen = ATK_HiddenFurnitureListScreen:New(hc)
    NWT.HiddenFurnitureList = NWT.HiddenFurnitureListScreen:GetMainList()
    NWT.HiddenFurnitureList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    NWT.HiddenFurnitureList:SetOnSelectedDataChangedCallback(function(list, sd)
        if sd and sd.index then
            local fs = NWT.FurnitureSearch
            fs.selectedIndex = sd.index
            if fs.selectedIndex <= fs.scrollOffset then fs.scrollOffset = fs.selectedIndex - 1
            elseif fs.selectedIndex > fs.scrollOffset + 12 then fs.scrollOffset = fs.selectedIndex - 12 end
            UpdateFurnitureSearchUI()
        end
    end)
    FURNITURE_SEARCH_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then NWT.FurnitureSearch.isOpen = true NWT.FurnitureSearch.selectedIndex, NWT.FurnitureSearch.scrollOffset = 1, 0 NWT.SyncHiddenFurnitureList() UpdateFurnitureSearchUI()
        elseif ns == SCENE_HIDDEN then NWT.FurnitureSearch.isOpen = false end
    end)
    NWT.FurnitureSearch.sceneInitialized = true
end

function NWT.OpenFurnitureSearch()
    if NWT.FurnitureSearch.isOpen then return end
    -- Close other sibling scenes first to maintain proper scene stack
    if NWT.PlannerUI and NWT.PlannerUI.isOpen then SCENE_MANAGER:Hide("plannerScene") end
    if NWT.HousingDashboard and NWT.HousingDashboard.isOpen then SCENE_MANAGER:Hide("housingDashboardScene") end
    if not FURNITURE_SEARCH_SCENE then NWT.InitFurnitureSearchScene() end
    SCENE_MANAGER:Push("furnitureSearchScene")
end

function NWT.CloseFurnitureSearch()
    if FURNITURE_SEARCH_SCENE then SCENE_MANAGER:Hide("furnitureSearchScene") end
end

-- ============================================
-- CORE HOUSING LOGIC
-- ============================================
function NWT.UpdateHousingLimitUI()
    if not HousingItemLimit_UI then return end
    local hId = GetCurrentZoneHouseId()
    if hId == 0 or not IsOwnerOfCurrentHouse() or not NWT.savedVars.housingHudEnabled or not HUD_SCENE:IsShowing() then
        HousingItemLimit_UI:SetHidden(true) return
    end
    local function GetLimitString(lType, ctrl, prefix)
        local cur = GetNumHouseFurnishingsPlaced(lType)
        local lim = GetHouseFurnishingPlacementLimit(hId, lType)
        if lim > 0 then
            local colors = NWT.GetColors()
            local color = "|c" .. colors.positive
            local pct = (cur / lim) * 100
            if pct >= 90 then color = "|c" .. colors.negative
            elseif pct >= 70 then color = "|c" .. colors.warning end
            ctrl:SetText(prefix .. ": " .. color .. cur .. "/" .. lim .. "|r")
            return true
        else ctrl:SetText("") return false end
    end
    GetLimitString(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM, HousingItemLimit_UIFurnishings, "Furnishings")
    GetLimitString(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE, HousingItemLimit_UICollectibles, "Collectibles")
    GetLimitString(HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM, HousingItemLimit_UISpecialFurnishings, "Special")
    GetLimitString(HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE, HousingItemLimit_UISpecialCollectibles, "Special Coll")
    HousingItemLimit_UI:SetHidden(false)
end

function NWT.ScanAllHouses()
    local houseStats = {}
    local numCats = GetNumCollectibleCategories()
    for ci = 1, numCats do
        local name, subs, items = GetCollectibleCategoryInfo(ci)
        if GetCollectibleCategorySpecialization(ci) == COLLECTIBLE_CATEGORY_SPECIALIZATION_HOUSING then
            for si = 1, subs do
                local inSub = GetNumCollectiblesInCollectibleCategory(ci, si)
                for i = 1, inSub do
                    local cId = GetCollectibleId(ci, si, i)
                    if IsCollectibleUnlocked(cId) then
                        local hId = GetCollectibleReferenceId(cId)
                        local count = GetHouseFurnitureCount(hId)
                        local lim = GetHouseFurnishingPlacementLimit(hId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0
                        local clim = GetHouseFurnishingPlacementLimit(hId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE) or 0
                        local tot = lim + clim
                        if hId and tot > 0 then
                            houseStats[hId] = { houseId = hId, name = GetCollectibleName(cId), count = count or 0, limit = tot, pct = tot > 0 and math_floor(((count or 0) / tot) * 100) or 0, lastScan = GetTimeStamp() }
                        end
                    end
                end
            end
        end
    end
    NWT.savedVars.housingStats = houseStats
    return houseStats
end

function NWT.ScanCurrentHouseFurniture()
    local hId = GetCurrentZoneHouseId()
    if not hId or hId == 0 then NWT.Debug("|cFFFF00[NWF]|r You must be inside a house to scan furniture.") return end
    local cId = GetCollectibleIdForHouse(hId)
    if not cId or cId == 0 or not IsCollectibleUnlocked(cId) then NWT.Debug("|cFFFF00[NWF]|r Only owned houses can be cached.") return end
    
    local items, count = {}, 0
    local totalValue, totalCrownValue, totalWritVouchers = 0, 0, 0
    local fId = GetNextPlacedHousingFurnitureId(nil)
    while fId do
        local name = GetPlacedHousingFurnitureInfo(fId)
        if name and name ~= "" then count = count + 1 items[count] = name end
        
        -- Calculate values like NetWorth.ScanCurrentHouse does
        local itemLink, collectibleLink = GetPlacedFurnitureLink(fId, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local itemId = GetItemLinkItemId(itemLink)
            local itemName = GetItemLinkName(itemLink)
            local crownPrice = NWT.GetCrownPriceForItem and NWT.GetCrownPriceForItem(itemId, itemName)
            if crownPrice then totalCrownValue = totalCrownValue + crownPrice end
            local wvCost = NWT.GetWritVoucherCostForItem and NWT.GetWritVoucherCostForItem(itemId)
            if wvCost then totalWritVouchers = totalWritVouchers + wvCost end
            local price = NWT.GetPrice and NWT.GetPrice(itemLink)
            if price and price > 0 then totalValue = totalValue + price end
        end
        if collectibleLink and collectibleLink ~= "" then
            local collId = GetCollectibleIdFromLink(collectibleLink)
            if collId then
                local collName = GetCollectibleName(collId)
                local furnitureDataId = GetCollectibleFurnitureDataId(collId)
                local crownPrice = NWT.GetCrownPriceForItem and NWT.GetCrownPriceForItem(furnitureDataId, collName)
                if crownPrice then totalCrownValue = totalCrownValue + crownPrice end
                local wvCost = NWT.GetWritVoucherCostForItem and NWT.GetWritVoucherCostForItem(furnitureDataId)
                if wvCost then totalWritVouchers = totalWritVouchers + wvCost end
            end
        end
        fId = GetNextPlacedHousingFurnitureId(fId)
    end
    NWT.savedVars.furnitureCache[hId] = { 
        houseName = GetCollectibleName(cId), 
        items = items, 
        lastScanned = GetTimeStamp(),
        goldValue = totalValue,
        crownValue = totalCrownValue,
        writVouchers = totalWritVouchers
    }
NWT.Debug("|c00FF00[NWF]|r Cached " .. count .. " items | Gold: " .. NWT.FormatGold(totalValue) .. " | Crowns: " .. totalCrownValue .. " | WV: " .. totalWritVouchers)
end

function NWT.SearchFurniture(searchTerm)
    if not searchTerm or searchTerm == "" then NWT.Debug("|cFFFF00[NWF]|r Usage: /nwf <search term>") return end
    searchTerm = string.lower(searchTerm)
    local vaultRes, curRes, cachedRes = {}, {}, {}
    local slotId = GetNextFurnitureVaultSlotId(nil)
    if slotId then
        while slotId do
            local name = GetItemName(BAG_FURNITURE_VAULT, slotId)
            if name and string.find(string.lower(name), searchTerm) then table.insert(vaultRes, name) end
            slotId = GetNextFurnitureVaultSlotId(slotId)
        end
    else
        for _, name in ipairs(NWT.savedVars.furnitureVaultCache and NWT.savedVars.furnitureVaultCache.items or {}) do
            if name and string.find(string.lower(name), searchTerm) then table.insert(vaultRes, name) end
        end
    end
    local hId = GetCurrentZoneHouseId()
    if hId and hId > 0 and IsOwnerOfCurrentHouse() then
        local fId = GetNextPlacedHousingFurnitureId(nil)
        while fId do
            local name = GetPlacedHousingFurnitureInfo(fId)
            if name and string.find(string.lower(name), searchTerm) then table.insert(curRes, name) end
            fId = GetNextPlacedHousingFurnitureId(fId)
        end
    end
    for id, data in pairs(NWT.savedVars.furnitureCache or {}) do
        local nid = tonumber(id) or id
        local cId = GetCollectibleIdForHouse(nid)
        if nid ~= hId and cId and cId > 0 and IsCollectibleUnlocked(cId) then
            local hName = data.houseName or ("House " .. id)
            for _, name in ipairs(data.items or {}) do
                if name and string.find(string.lower(name), searchTerm) then
                    if not cachedRes[hName] then cachedRes[hName] = {} end
                    table.insert(cachedRes[hName], name)
                end
            end
        end
    end
    
    local function group(list)
        local g, o = {}, {}
        for _, n in ipairs(list) do
            if not g[n] then g[n] = 0 table.insert(o, n) end
            g[n] = g[n] + 1
        end
        return g, o
    end
    local function disp(g, o) for _, n in ipairs(o) do NWT.Debug("  - " .. n .. (g[n] > 1 and " x" .. g[n] or "")) end end
    
NWT.Debug("|c00FF00========== FURNITURE SEARCH: \"" .. searchTerm .. "\" ==========|r")
    local tot = 0
    if #vaultRes > 0 then local g, o = group(vaultRes) NWT.Debug("|cFFD700Furniture Vault:|r " .. #vaultRes .. " items") disp(g, o) tot = tot + #vaultRes end
    if #curRes > 0 then local cId = GetCollectibleIdForHouse(hId) local g, o = group(curRes) NWT.Debug("|c00BFFF" .. (GetCollectibleName(cId) or "Current House") .. " (current):|r " .. #curRes .. " items") disp(g, o) tot = tot + #curRes end
    for h, items in pairs(cachedRes) do local g, o = group(items) NWT.Debug("|cAAFFAA" .. h .. " (cached):|r " .. #items .. " items") disp(g, o) tot = tot + #items end
    if tot == 0 then NWT.Debug("|cFF6666No furniture matching \"" .. searchTerm .. "\" found.|r") end
NWT.Debug("|c00FF00================================================|r")
end

function NWT.FurnitureFinderCommand(args)
    local cmd = string.lower(args or "")
    if cmd == "scan" then
        local hId = GetCurrentZoneHouseId()
        if hId and hId > 0 then NWT.ScanCurrentHouseFurniture() end
        local vCount = NWT.ScanFurnitureVault()
NWT.Debug("|c00FF00[NWF]|r Cached " .. vCount .. " items from Furniture Vault")
    elseif cmd == "list" then
NWT.Debug("|c00FF00========== FURNITURE CACHE ==========|r")
NWT.Debug("|cFFD700Furniture Vault:|r " .. #(NWT.savedVars.furnitureVaultCache and NWT.savedVars.furnitureVaultCache.items or {}) .. " items cached")
        for id, data in pairs(NWT.savedVars.furnitureCache or {}) do NWT.Debug("  " .. data.houseName .. " - " .. #(data.items or {}) .. " items cached") end
NWT.Debug("|c00FF00====================================|r")
    elseif cmd == "clear" then NWT.savedVars.furnitureCache, NWT.savedVars.furnitureVaultCache = {}, {} NWT.Debug("|cFFFF00[NWF]|r Furniture cache cleared.")
    elseif cmd == "stats" then
NWT.Debug("|c00FF00========== HOUSING STATS ==========|r")
        local totI, totC, hList = 0, 0, {}
        local numCats = GetNumCollectibleCategories()
        for ci = 1, numCats do
            if GetCollectibleCategorySpecialization(ci) == COLLECTIBLE_CATEGORY_SPECIALIZATION_HOUSING then
                local _, subs = GetCollectibleCategoryInfo(ci)
                for si = 1, subs do
                    local inSub = GetNumCollectiblesInCollectibleCategory(ci, si)
                    for i = 1, inSub do
                        local cId = GetCollectibleId(ci, si, i)
                        if IsCollectibleUnlocked(cId) then
                            local hId = GetCollectibleReferenceId(cId)
                            local fCount = GetHouseFurnitureCount(hId)
                            local lim = (GetHouseFurnishingPlacementLimit(hId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) or 0) + (GetHouseFurnishingPlacementLimit(hId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE) or 0)
                            if fCount and lim > 0 then
                                table.insert(hList, { name = GetCollectibleName(cId), count = fCount, limit = lim, pct = math_floor((fCount/lim)*100) })
                                totI, totC = totI + fCount, totC + lim
                            end
                        end
                    end
                end
            end
        end
        table.sort(hList, function(a, b) return a.pct > b.pct end)
        local colors = NWT.GetColors()
        for _, h in ipairs(hList) do
            local color = "|c" .. colors.positive
            if h.pct >= 90 then color = "|c" .. colors.negative elseif h.pct >= 70 then color = "|c" .. colors.warning end
            NWT.Debug(color .. h.name .. "|r: " .. h.count .. "/" .. h.limit .. " (" .. h.pct .. "%)")
        end
        if #hList > 0 then NWT.Debug("|c888888---------------------------------|r") NWT.Debug("|cFFD700Total:|r " .. totI .. "/" .. totC .. " (" .. math_floor((totI/totC)*100) .. "%) across " .. #hList .. " houses")
        else NWT.Debug("|cAAAAAANo owned houses found.|r") end
NWT.Debug("|c00FF00==================================|r")
    elseif cmd == "help" or cmd == "" then
NWT.Debug("|c00FF00========== FURNITURE FINDER ==========|r")
NWT.Debug("|cFFFFAA/nwf <search>|r - Search for furniture by name\n|cFFFFAA/nwf stats|r - Show all houses capacity\n|cFFFFAA/nwf scan|r - Cache current house + vault\n|cFFFFAA/nwf list|r - Show cached locations\n|cFFFFAA/nwf clear|r - Clear all cache")
NWT.Debug("|c00FF00=======================================|r")
    else NWT.SearchFurniture(cmd) end
end

function NWT.OnPlayerActivatedHousing()
    local hId = GetCurrentZoneHouseId()
    if hId and hId > 0 and IsOwnerOfCurrentHouse() then
        zo_callLater(function()
            if GetCurrentZoneHouseId() > 0 and IsOwnerOfCurrentHouse() then
                NWT.ScanCurrentHouseFurniture()
                NWT.ScanFurnitureVault()
            end
        end, 2000)
    end
end
