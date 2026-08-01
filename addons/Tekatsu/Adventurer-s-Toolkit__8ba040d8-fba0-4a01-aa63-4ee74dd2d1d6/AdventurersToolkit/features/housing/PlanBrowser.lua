-- ============================================
-- PLAN BROWSER MODULE
-- ============================================

-- Localize globals for performance
local math_floor = math.floor
local string_format = string.format

NWT.PlanBrowser = {
    isOpen = false,
    categories = {},
    currentCategoryIndex = 1,
    currentItemIndex = 1,
    items = {},
    listRows = {},
    maxVisibleRows = 15,
    scrollOffset = 0,
    filterMode = 1,
    filterModes = {"All", "Unknown", "Known"},
    searchText = "",
    lastNavTime = 0,
    navCooldown = 200,
}

local PB_categoryToStation = {
    ["lighting"] = {name = "Alchemy", color = "00FF00"},
    ["light"] = {name = "Alchemy", color = "00FF00"},
    ["target skeleton"] = {name = "Alchemy", color = "00FF00"},
    ["attunable"] = {name = "Alchemy", color = "00FF00"},
    ["seating"] = {name = "Woodworking", color = "8B4513"},
    ["tables"] = {name = "Woodworking", color = "8B4513"},
    ["shelves"] = {name = "Woodworking", color = "8B4513"},
    ["parlor"] = {name = "Clothing", color = "DEB887"},
    ["dining"] = {name = "Provisioning", color = "FFAA00"},
    ["gallery"] = {name = "Blacksmithing", color = "C0C0C0"},
    ["courtyard"] = {name = "Woodworking", color = "8B4513"},
    ["library"] = {name = "Woodworking", color = "8B4513"},
    ["workshop"] = {name = "Blacksmithing", color = "C0C0C0"},
    ["undercroft"] = {name = "Blacksmithing", color = "C0C0C0"},
    ["suite"] = {name = "Clothing", color = "DEB887"},
    ["enchanting"] = {name = "Enchanting", color = "9966FF"},
    ["hearth"] = {name = "Provisioning", color = "FFAA00"},
    ["structures"] = {name = "Enchanting", color = "9966FF"},
}

local PB_stationNames = nil
local function GetPB_stationNames()
    if not PB_stationNames then
        PB_stationNames = {
            [CRAFTING_TYPE_BLACKSMITHING] = {name = "Blacksmithing", color = "C0C0C0"},
            [CRAFTING_TYPE_CLOTHIER] = {name = "Clothing", color = "DEB887"},
            [CRAFTING_TYPE_ENCHANTING] = {name = "Enchanting", color = "9966FF"},
            [CRAFTING_TYPE_ALCHEMY] = {name = "Alchemy", color = "00FF00"},
            [CRAFTING_TYPE_PROVISIONING] = {name = "Provisioning", color = "FFAA00"},
            [CRAFTING_TYPE_WOODWORKING] = {name = "Woodworking", color = "8B4513"},
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {name = "Jewelry", color = "FFD700"},
        }
    end
    return PB_stationNames
end

local ATK_HiddenPlanBrowserListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenPlanBrowserListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenPlanBrowserListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, PLAN_BROWSER_SCENE) end
function ATK_HiddenPlanBrowserListScreen:PerformUpdate() end

function ATK_HiddenPlanBrowserListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Search", keybind = "UI_SHORTCUT_PRIMARY", callback = function() NWT.PlanBrowserSearch() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "View Materials", keybind = "UI_SHORTCUT_SECONDARY", callback = function() NWT.PlanBrowserLoadMaterials() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Filter", keybind = "UI_SHORTCUT_TERTIARY", callback = function() NWT.PlanBrowserCycleFilter() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Wishlist", keybind = "UI_SHORTCUT_QUATERNARY", callback = function() NWT.PlanBrowserAddToWishlist() end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Prev Category", keybind = "UI_SHORTCUT_LEFT_SHOULDER", callback = function() NWT.PlanBrowserNavigate("left") end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Next Category", keybind = "UI_SHORTCUT_RIGHT_SHOULDER", callback = function() NWT.PlanBrowserNavigate("right") end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Page Up", keybind = "UI_SHORTCUT_LEFT_TRIGGER", callback = function() NWT.PlanBrowserNavigate("pageup") end },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, name = "Page Down", keybind = "UI_SHORTCUT_RIGHT_TRIGGER", callback = function() NWT.PlanBrowserNavigate("pagedown") end },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.ClosePlanBrowser() end)
end

-- Scan known plans and save by ID (runs once per session, minimal memory)
function NWT.ScanKnownPlans()
    local sv = NWT.savedVars
    if not sv then return end
    if not sv.knownPlanIds then sv.knownPlanIds = {} end
    local currentChar = GetUnitName("player")
    if not sv.knownPlanIds[currentChar] then sv.knownPlanIds[currentChar] = {} end
    
    -- Skip if already scanned this session
    if NWT.PlanBrowser.knownScanned then return end
    
    NWT.Debug("|cFFD700[Plan Browser]|r Scanning known plans...")
    local charKnown = sv.knownPlanIds[currentChar]
    local count = 0
    
    -- Use PlanData.lua to get listIndex/recipeIndex, only check known status
    if ATPlanDataXBNA and ATPlanDataXBNA.planData then
        for name, data in pairs(ATPlanDataXBNA.planData) do
            if data.li and data.ri and data.id then
                local kn = select(1, GetRecipeInfo(data.li, data.ri))
                if kn then
                    charKnown[data.id] = true
                    count = count + 1
                end
            end
        end
    end
    
    NWT.PlanBrowser.knownScanned = true
    NWT.Debug(string_format("|c00FF00[Plan Browser]|r Found %d known plans for %s", count, currentChar))
end

function NWT.InitPlanBrowser()
    local pb = NWT.PlanBrowser
    local ui = ATK_ATK_PlanBrowser_UI
    if not ui then ui = ATK_PlanBrowser_UI end -- fallback
    if not ui then return end
    pb.ui = ui
    pb.dataBuilt = false
    
    -- Scan known plans on init (delayed to avoid load spike)
    zo_callLater(function() NWT.ScanKnownPlans() end, 3000)
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenPlanBrowserList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true) hc:SetAlpha(0)
    PLAN_BROWSER_SCENE = ZO_Scene:New("planBrowserScene", SCENE_MANAGER)
    PLAN_BROWSER_SCENE:AddFragment(ZO_SimpleSceneFragment:New(ui))
    PLAN_BROWSER_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    PLAN_BROWSER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    PLAN_BROWSER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NWT.HiddenPlanBrowserListScreen = ATK_HiddenPlanBrowserListScreen:New(hc)
    NWT.HiddenPlanBrowserList = NWT.HiddenPlanBrowserListScreen:GetMainList()
    NWT.HiddenPlanBrowserList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) local l = c:GetNamedChild("Label") if l then l:SetText(d.name or "") end end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    NWT.HiddenPlanBrowserList:SetOnSelectedDataChangedCallback(function(list, sd)
        -- Skip if navigating programmatically (triggers/category change)
        if pb.skipCallback then return end
        if sd and sd.index then
            pb.currentItemIndex = sd.index
            if pb.currentItemIndex <= pb.scrollOffset then pb.scrollOffset = pb.currentItemIndex - 1
            elseif pb.currentItemIndex > pb.scrollOffset + pb.maxVisibleRows then pb.scrollOffset = pb.currentItemIndex - pb.maxVisibleRows end
            NWT.UpdatePlanBrowserList()
            NWT.UpdatePlanBrowserDetails()
        end
    end)
    PLAN_BROWSER_SCENE:RegisterCallback("StateChange", function(os, ns) if ns == SCENE_HIDDEN then pb.isOpen = false end end)
end

function NWT.BuildPlanBrowserData(onComplete)
    local pb = NWT.PlanBrowser
    local currentChar = GetUnitName("player")
    if pb.lastBuiltChar ~= currentChar then pb.dataBuilt = false end
    if pb.dataBuilt and #pb.categories > 0 then 
        if onComplete then onComplete() end
        return 
    end
    
    -- If already building, don't start again
    if pb.isBuilding then return end
    pb.isBuilding = true
    
    NWT.Debug("|cFFD700[Plan Browser]|r Rebuilding plan index...")
    pb.lastBuiltChar, pb.categories = currentChar, {}
    local sv = NWT.savedVars
    if not sv.knownPlans then sv.knownPlans = {} end
    if not sv.knownPlans[currentChar] then sv.knownPlans[currentChar] = {} end
    local charKnown = sv.knownPlans[currentChar]
    
    -- Get station names (lazy initialized)
    local stations = GetPB_stationNames()
    
    -- Organize by crafting type
    local craftCategories = {
        [CRAFTING_TYPE_WOODWORKING] = {name = "Blueprints (Woodworking)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_WOODWORKING]},
        [CRAFTING_TYPE_PROVISIONING] = {name = "Designs (Provisioning)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_PROVISIONING]},
        [CRAFTING_TYPE_BLACKSMITHING] = {name = "Diagrams (Blacksmithing)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_BLACKSMITHING]},
        [CRAFTING_TYPE_ALCHEMY] = {name = "Formulas (Alchemy)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_ALCHEMY]},
        [CRAFTING_TYPE_CLOTHIER] = {name = "Patterns (Clothing)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_CLOTHIER]},
        [CRAFTING_TYPE_ENCHANTING] = {name = "Praxes (Enchanting)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_ENCHANTING]},
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {name = "Sketches (Jewelry)", items = {}, knownCount = 0, station = stations[CRAFTING_TYPE_JEWELRYCRAFTING]},
    }
    
    local function finalizeBuild()
        -- Add non-empty categories
        for _, cat in pairs(craftCategories) do
            if #cat.items > 0 then
                cat.totalCount = #cat.items
                table.insert(pb.categories, cat)
            end
        end
        table.sort(pb.categories, function(a, b) return a.name < b.name end)
        pb.dataBuilt = true
        pb.isBuilding = false
        NWT.Debug("|cFFD700[Plan Browser]|r Build complete: " .. #pb.categories .. " categories")
        if onComplete then onComplete() end
    end
    
    -- Use PlanData.lua as primary source (NO API calls during build = no memory spike)
    if ATPlanDataXBNA and ATPlanDataXBNA.planData then
        NWT.Debug("|cFFD700[Plan Browser]|r Using pre-loaded PlanData.lua (chunked)")
        local iconCache = sv.planIconCache or {}
        local knownIds = (sv.knownPlanIds and sv.knownPlanIds[currentChar]) or {}
        local qualityColors = { [1] = "FFFFFF", [2] = "2DC50E", [3] = "3A92FF", [4] = "A02EF7", [5] = "EECA2A" }
        
        -- Convert pairs to indexed array for chunked processing
        local planNames = {}
        for name, _ in pairs(ATPlanDataXBNA.planData) do
            table.insert(planNames, name)
        end
        
        local totalPlans = #planNames
        local currentIndex = 1
        local chunkSize = 200  -- Process 200 plans per frame
        
        local function processChunk()
            local endIndex = math.min(currentIndex + chunkSize - 1, totalPlans)
            
            for i = currentIndex, endIndex do
                local name = planNames[i]
                local data = ATPlanDataXBNA.planData[name]
                local ct = data.ct
                local cat = craftCategories[ct]
                if cat then
                    local cached = iconCache[name]
                    local icon = cached and cached.icon or nil
                    if not icon and data.ic and data.ic ~= "" then
                        icon = "/esoui/art/icons/" .. data.ic
                    end
                    local quality = (cached and cached.quality) or data.q or 1
                    local kn = (data.id and knownIds[data.id]) or false
                    local coloredName = "|c" .. (qualityColors[quality] or "FFFFFF") .. name .. "|r"
                    table.insert(cat.items, {
                        name = name,
                        coloredName = coloredName,
                        known = kn,
                        quality = quality,
                        icon = icon,
                        resultItemId = data.id or 0,
                        station = cat.station,
                        listIndex = data.li,
                        recipeIndex = data.ri,
                    })
                    if kn then cat.knownCount = cat.knownCount + 1 end
                end
            end
            
            currentIndex = endIndex + 1
            
            if currentIndex <= totalPlans then
                -- Schedule next chunk
                zo_callLater(processChunk, 1)
            else
                -- Done processing all plans
                finalizeBuild()
            end
        end
        
        -- Start processing
        processChunk()
    else
        -- Fallback: scan from game API if PlanData.lua not available (also chunked)
        NWT.Debug("|cFFFF00[Plan Browser]|r PlanData.lua not found, scanning recipes...")
        local numLists = GetNumRecipeLists()
        local currentList = 17
        
        local function processListChunk()
            local listsThisFrame = 0
            while currentList <= numLists and listsThisFrame < 3 do
                local ln, nr = GetRecipeListInfo(currentList)
                if nr > 0 then
                    for ri = 1, nr do
                        local kn, name, ning, _, qreq, _, tradeSkillType, rId = GetRecipeInfo(currentList, ri)
                        if name and name ~= "" and tradeSkillType and tradeSkillType ~= CRAFTING_TYPE_INVALID then
                            local cat = craftCategories[tradeSkillType]
                            if cat then
                                local icon, dq = nil, qreq
                                local _, iconR, _, _, qR = GetRecipeResultItemInfo(currentList, ri)
                                if iconR and iconR ~= "" and not iconR:lower():find("missing") then icon, dq = iconR, qR or dq end
                                if not dq or dq <= 0 then dq = qreq or 1 end if dq > 5 then dq = 5 end
                                table.insert(cat.items, {name = name, known = kn, quality = dq, icon = icon, resultItemId = rId, station = cat.station, numIngredients = ning or 0, listIndex = currentList, recipeIndex = ri})
                                if kn then cat.knownCount = cat.knownCount + 1 charKnown[name] = true end
                            end
                        end
                    end
                end
                currentList = currentList + 1
                listsThisFrame = listsThisFrame + 1
            end
            
            if currentList <= numLists then
                zo_callLater(processListChunk, 1)
            else
                finalizeBuild()
            end
        end
        
        processListChunk()
    end
end

function NWT.GetFilteredItems(category)
    local pb = NWT.PlanBrowser
    local searchLower = pb.searchText:lower()
    local hasSearch = searchLower ~= ""
    if pb.filterMode == 1 and not hasSearch then return category.items end
    local filtered = {}
    local allKnown = {}
    for _, charPlans in pairs(NWT.savedVars.knownPlans or {}) do for name, _ in pairs(charPlans) do allKnown[name] = true end end
    for _, item in ipairs(category.items) do
        local passF = true
        local knAny = allKnown[item.name] or item.known
        if pb.filterMode == 2 and knAny then passF = false elseif pb.filterMode == 3 and not knAny then passF = false end
        if passF and (not hasSearch or item.name:lower():find(searchLower, 1, true)) then table.insert(filtered, item) end
    end
    return filtered
end

function NWT.UpdatePlanBrowserList()
    local pb = NWT.PlanBrowser
    local ui = pb.ui or ATK_ATK_PlanBrowser_UI or ATK_PlanBrowser_UI
    if not ui then return end
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    pb.filteredItems = NWT.GetFilteredItems(cat)
    local items = pb.filteredItems
    if pb.currentItemIndex > #items then pb.currentItemIndex = #items > 0 and #items or 1 end
    local colors = NWT.GetColors()
    
    -- Update header
    local leftCol = ui:GetNamedChild("LeftCol")
    local plansCard = leftCol and leftCol:GetNamedChild("PlansCard")
    local header = plansCard and plansCard:GetNamedChild("Header")
    if header then header:SetText(string.format("|cFFD700%s|r |c888888(%d)|r", cat.name, #items)) end
    
    -- Update list rows
    local list = plansCard and plansCard:GetNamedChild("List")
    local selFrame = list and list:GetNamedChild("SelectionFrame")
    for i = 1, 15 do
        local row = list and list:GetNamedChild("Row" .. i)
        if row then
            local idx = pb.scrollOffset + i
            if idx <= #items then
                local it = items[idx]
                local isSel = (idx == pb.currentItemIndex)
                -- Use pre-computed coloredName, cache knownByAny
                if it.knownByAnyCache == nil then it.knownByAnyCache = NWT.IsKnownByAny(it.name) end
                local st = it.known and "|c00FF00✓|r " or (it.knownByAnyCache and "|cFFFF00◐|r " or "|cFF4444✗|r ")
                local prefix = isSel and "► " or "  "
                row:SetText(prefix .. st .. (it.coloredName or it.name))
                row:SetHidden(false)
                if isSel and selFrame then
                    selFrame:ClearAnchors()
                    selFrame:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -2)
                    selFrame:SetHidden(false)
                end
            else
                row:SetHidden(true)
            end
        end
    end
end

function NWT.IsKnownByAny(name)
    for _, plans in pairs(NWT.savedVars.knownPlans or {}) do if plans[name] then return true end end
    return false
end

function NWT.UpdatePlanBrowserDetails()
    local pb = NWT.PlanBrowser
    local ui = pb.ui or ATK_ATK_PlanBrowser_UI or ATK_PlanBrowser_UI
    if not ui then return end
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    local item = (pb.filteredItems or cat.items)[pb.currentItemIndex]
    if not item then return end
    
    local centerCol = ui:GetNamedChild("CenterCol")
    if not centerCol then return end
    
    local icon = centerCol:GetNamedChild("Icon")
    local border = centerCol:GetNamedChild("IconBorder")
    local nameL = centerCol:GetNamedChild("ItemName")
    local catL = centerCol:GetNamedChild("Category")
    local statL = centerCol:GetNamedChild("Station")
    local knownL = centerCol:GetNamedChild("Known")
    local wishL = centerCol:GetNamedChild("Wishlisted")
    local matL = centerCol:GetNamedChild("Materials")
    
    -- Use RELEASE_TEXTURE_AT_ZERO_REFERENCES to free memory when texture changes
    if icon then
        icon:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
        if item.icon then
            icon:SetTexture(item.icon)
            icon:SetHidden(false)
        else
            icon:SetTexture("")
            icon:SetHidden(true)
        end
    end
    -- Hardcoded quality RGB colors (no API calls)
    local qualityRGB = { [1]={1,1,1}, [2]={0.18,0.77,0.05}, [3]={0.23,0.57,1}, [4]={0.63,0.18,0.97}, [5]={0.93,0.79,0.17} }
    local rgb = qualityRGB[item.quality or 1] or qualityRGB[1]
    if border then border:SetColor(rgb[1], rgb[2], rgb[3], 1) end
    if nameL then nameL:SetText(item.coloredName or item.name) end
    if catL then catL:SetText("|c888888" .. cat.name .. "|r") end
    if statL then statL:SetText(item.station and ("|c" .. item.station.color .. "Craft at: " .. item.station.name .. "|r") or "") end
    
    local colors = NWT.GetColors()
    -- Cache knownByAny to avoid repeated iteration
    if item.knownByAnyCache == nil then
        item.knownByAnyCache = NWT.IsKnownByAny(item.name)
    end
    if knownL then
        if item.known then knownL:SetText("|c" .. colors.positive .. "✓ Plan Known|r")
        elseif item.knownByAnyCache then knownL:SetText("|c" .. colors.warning .. "⚠ Unknown on this toon|r")
        else knownL:SetText("|c" .. colors.negative .. "✗ Plan Unknown|r") end
    end
    
    -- Cache wishlist check
    if item.wishCache == nil then
        item.wishCache = false
        for p, its in pairs(NWT.savedVars.wishlist.projects or {}) do 
            if its["name_" .. item.name] then item.wishCache = true break end 
        end
    end
    if wishL then wishL:SetText(item.wishCache and "|c00FF00★ Wishlisted|r" or "|c888888Not wishlisted|r") end
    
    -- Show materials if loaded, otherwise inventory locations
    if matL then
        if item.matsCache then
            matL:SetText("|cFFFFAACRAFTING MATERIALS|r\n" .. item.matsCache)
        else
            if not item.invCache then
                item.invCache = NWT.FindItemInInventoryText(item.name)
            end
            matL:SetText(item.invCache)
        end
    end
    
    -- Update filter label
    local rightCol = ui:GetNamedChild("RightCol")
    local filterCard = rightCol and rightCol:GetNamedChild("FilterCard")
    if filterCard then
        local filterL = filterCard:GetNamedChild("CurrentFilter")
        local searchL = filterCard:GetNamedChild("SearchText")
        if filterL then
            local filterName = pb.filterModes[pb.filterMode] or "All"
            local colors = {"FFFFFF", "FF6666", "66FF66"}
            filterL:SetText("|c" .. colors[pb.filterMode] .. filterName .. "|r")
        end
        if searchL then
            searchL:SetText(pb.searchText ~= "" and ("|c00FFFF\"" .. pb.searchText .. "\"|r") or "")
        end
    end
end

function NWT.UpdatePlanBrowserStats()
    local pb = NWT.PlanBrowser
    local ui = pb.ui or ATK_ATK_PlanBrowser_UI or ATK_PlanBrowser_UI
    if not ui then return end
    local tot, me, any = 0, 0, 0
    local allK = {} for _, p in pairs(NWT.savedVars.knownPlans or {}) do for n, _ in pairs(p) do allK[n] = true end end
    for _, c in ipairs(pb.categories) do
        tot = tot + c.totalCount me = me + c.knownCount
        for _, it in ipairs(c.items) do if allK[it.name] then any = any + 1 end end
    end
    local colors = NWT.GetColors()
    
    local rightCol = ui:GetNamedChild("RightCol")
    local statsCard = rightCol and rightCol:GetNamedChild("StatsCard")
    if statsCard then
        local totalL = statsCard:GetNamedChild("TotalPlans")
        local knownL = statsCard:GetNamedChild("KnownPlans")
        local unknownL = statsCard:GetNamedChild("UnknownPlans")
        local pctL = statsCard:GetNamedChild("Percentage")
        if totalL then totalL:SetText("|c888888Total:|r |cFFFFFF" .. tot .. "|r") end
        if knownL then knownL:SetText("|c00FF00Known:|r |cFFFFFF" .. me .. "|r") end
        if unknownL then unknownL:SetText("|cFF4444Unknown:|r |cFFFFFF" .. (tot - me) .. "|r") end
        if pctL then pctL:SetText("|cFFD700Progress:|r |cFFFFFF" .. string_format("%.1f%%", tot > 0 and (me/tot)*100 or 0) .. "|r") end
    end
end

function NWT.PlanBrowserNavigate(dir)
    local pb = NWT.PlanBrowser
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    
    -- Block callback during programmatic navigation
    pb.skipCallback = true
    
    -- Always use filtered items for proper bounds
    pb.filteredItems = pb.filteredItems or NWT.GetFilteredItems(cat)
    local items = pb.filteredItems
    local maxIdx = #items
    if maxIdx == 0 then pb.skipCallback = false return end
    
    if dir == "up" then
        if pb.currentItemIndex > 1 then
            pb.currentItemIndex = pb.currentItemIndex - 1
            if pb.currentItemIndex <= pb.scrollOffset then pb.scrollOffset = pb.currentItemIndex - 1 end
        end
    elseif dir == "down" then
        if pb.currentItemIndex < maxIdx then
            pb.currentItemIndex = pb.currentItemIndex + 1
            if pb.currentItemIndex > pb.scrollOffset + pb.maxVisibleRows then pb.scrollOffset = pb.currentItemIndex - pb.maxVisibleRows end
        end
    elseif dir == "left" then
        if pb.currentCategoryIndex > 1 then
            pb.currentCategoryIndex = pb.currentCategoryIndex - 1
            pb.filteredItems = nil  -- Clear so it rebuilds for new category
            pb.currentItemIndex, pb.scrollOffset = 1, 0
            NWT.UpdatePlanBrowserCategoryTabs()
            NWT.SyncHiddenPlanBrowserList()
        end
    elseif dir == "right" then
        if pb.currentCategoryIndex < #pb.categories then
            pb.currentCategoryIndex = pb.currentCategoryIndex + 1
            pb.filteredItems = nil  -- Clear so it rebuilds for new category
            pb.currentItemIndex, pb.scrollOffset = 1, 0
            NWT.UpdatePlanBrowserCategoryTabs()
            NWT.SyncHiddenPlanBrowserList()
        end
    elseif dir == "pageup" then
        pb.currentItemIndex = math.max(1, pb.currentItemIndex - 10)
        pb.scrollOffset = math.max(0, pb.currentItemIndex - 1)
        NWT.SyncHiddenPlanBrowserList()
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    elseif dir == "pagedown" then
        pb.currentItemIndex = math.min(maxIdx, pb.currentItemIndex + 10)
        if pb.currentItemIndex > pb.scrollOffset + pb.maxVisibleRows then pb.scrollOffset = pb.currentItemIndex - pb.maxVisibleRows end
        NWT.SyncHiddenPlanBrowserList()
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
    
    -- Clamp index to valid range
    if pb.currentItemIndex > maxIdx then pb.currentItemIndex = maxIdx end
    if pb.currentItemIndex < 1 then pb.currentItemIndex = 1 end
    
    NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails()
    
    -- Re-enable callback after navigation complete
    pb.skipCallback = false
end

function NWT.PlanBrowserAddToWishlist()
    local pb = NWT.PlanBrowser
    local item = (pb.filteredItems or pb.categories[pb.currentCategoryIndex].items)[pb.currentItemIndex]
    if not item then return end
    local sv = NWT.savedVars.wishlist
    local id = "name_" .. item.name
    if sv.projects[sv.activeProject][id] then sv.projects[sv.activeProject][id].count = (sv.projects[sv.activeProject][id].count or 1) + 1
    else sv.projects[sv.activeProject][id] = { name = item.name, count = 1, addedTime = GetTimeStamp() } end
    item.wishCache = true  -- Invalidate cache
NWT.Debug(string_format("|c00FF00[Wishlist]|r Added %s to %s", item.name, sv.activeProject))
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdatePlanBrowserDetails()
end

-- Find item locations and return formatted text (no intermediate tables)
function NWT.FindItemInInventoryText(itemName)
    if not itemName then return "|c888888Not found in inventory|r" end
    local itemFinder = NWT.savedVars.itemFinder
    if not itemFinder or not itemFinder.characters then return "|c888888Not found in inventory|r\n|c666666(Run /itemfinder to scan)|r" end
    
    local searchLower = itemName:lower()
    local found = false
    local text = ""
    for charName, charData in pairs(itemFinder.characters) do
        for _, item in ipairs(charData.items or {}) do
            if item.name and item.name:lower() == searchLower then
                if found then text = text .. "\n" end
                text = text .. string_format("|c00FF00✓|r %s: |cFFFFFF%s|r x%d", charName, item.location or "Unknown", item.count or 1)
                found = true
            end
        end
    end
    return found and text or "|c888888Not found in inventory|r\n|c666666(Run /itemfinder to scan)|r"
end

function NWT.PlanBrowserLoadMaterials()
    local pb = NWT.PlanBrowser
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    local item = (pb.filteredItems or cat.items)[pb.currentItemIndex]
    if not item then return end
    
    -- If already cached, just refresh display
    if item.matsCache then
        NWT.UpdatePlanBrowserDetails()
        PlaySound(SOUNDS.POSITIVE_CLICK)
        return
    end
    
    -- Load materials on-demand (one-time API call per item)
    if item.listIndex and item.recipeIndex then
        local mats = {}
        local _, _, numIng = GetRecipeInfo(item.listIndex, item.recipeIndex)
        numIng = numIng or 0
        for i = 1, numIng do
            local n, _, q = GetRecipeIngredientItemInfo(item.listIndex, item.recipeIndex, i)
            if n then table.insert(mats, "• " .. n .. " x" .. q) end
        end
        item.matsCache = #mats > 0 and table.concat(mats, "\n") or "|c888888No materials required|r"
    else
        item.matsCache = "|c888888Materials unavailable|r"
    end
    
    NWT.UpdatePlanBrowserDetails()
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.PlanBrowserPreview3D()
    local pb = NWT.PlanBrowser
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    local item = (pb.filteredItems or cat.items)[pb.currentItemIndex]
    if not item then return end
    
    local listIndex = item.listIndex
    local recipeIndex = item.recipeIndex
    local resultItemId = item.resultItemId
    
    -- If no resultItemId, try to look it up from PlanData.lua
    if (not resultItemId or resultItemId == 0) and ATPlanDataXBNA and ATPlanDataXBNA.planData then
        local planData = ATPlanDataXBNA.planData[item.name]
        if planData and planData.id and planData.id > 0 then
            resultItemId = planData.id
            listIndex = planData.li or listIndex
            recipeIndex = planData.ri or recipeIndex
        end
    end
    
    -- Try to get item link from game first, fall back to constructed link
    local itemLink = nil
    if listIndex and recipeIndex then
        itemLink = GetRecipeResultItemLink(listIndex, recipeIndex, LINK_STYLE_BRACKETS)
    end
    
    -- Fallback: construct link from resultItemId
    if (not itemLink or itemLink == "") and resultItemId and resultItemId > 0 then
        itemLink = string_format("|H1:item:%d:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", resultItemId)
    end
    
    if not itemLink or itemLink == "" then
        d("|cFF4444[Plan Browser]|r No item data for preview - " .. (item.name or "unknown"))
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    
    d(string_format("|cFFD700[Plan Browser]|r Previewing: %s", item.name))
    
    -- Close the Plan Browser scene first
    NWT.ClosePlanBrowser()
    
    -- Delay to let scene fully close, then preview
    zo_callLater(function()
        -- Match the exact sequence from inventory preview:
        -- 1. EnablePreviewMode
        -- 2. Preview the item using PreviewItemLink (public API)
        -- 3. Show 'hudui' scene
        
        EnablePreviewMode(false)
        PreviewItemLink(itemLink, 1)
        SCENE_MANAGER:Show("hudui")
        PlaySound(SOUNDS.POSITIVE_CLICK)
    end, 300)
end

function NWT.PlanBrowserCycleFilter()
    local pb = NWT.PlanBrowser
    pb.filterMode = (pb.filterMode % 3) + 1
    pb.currentItemIndex, pb.scrollOffset = 1, 0
    PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails() NWT.UpdatePlanBrowserStats()
end

function NWT.PlanBrowserSearch()
    local pb = NWT.PlanBrowser
    if pb.searchText ~= "" then
        pb.searchText, pb.currentItemIndex, pb.scrollOffset = "", 1, 0
        PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails()
        return
    end
    if not pb.searchEditBox then
        local ui = pb.ui or ATK_ATK_PlanBrowser_UI or ATK_PlanBrowser_UI
        local eb = WINDOW_MANAGER:CreateControl("PlanBrowserSearchEditBox", ui, CT_EDITBOX)
        eb:SetDimensions(400, 40) eb:SetAnchor(CENTER, ui, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad27") eb:SetMaxInputChars(50) eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            if txt and txt ~= "" then
                pb.searchText = txt pb.currentItemIndex, pb.scrollOffset = 1, 0
NWT.Debug(string_format("|cFFD700[Plan Browser]|r Searching: |cFFFFFF%s|r", txt))
                PlaySound(SOUNDS.POSITIVE_CLICK) NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails()
            end
            self:SetHidden(true) self:LoseFocus()
        end)
        eb:SetHandler("OnEscape", function(self) self:SetHidden(true) self:LoseFocus() end)
        eb:SetHidden(true) pb.searchEditBox = eb
    end
    pb.searchEditBox:SetText("") pb.searchEditBox:SetHidden(false) pb.searchEditBox:TakeFocus()
end

function NWT.SyncHiddenPlanBrowserList()
    if not NWT.HiddenPlanBrowserList then return end
    local pb = NWT.PlanBrowser
    local cat = pb.categories[pb.currentCategoryIndex]
    if not cat then return end
    local items = pb.filteredItems or NWT.GetFilteredItems(cat) or {}
    NWT.HiddenPlanBrowserList:Clear()
    for i, item in ipairs(items) do
        local ed = ZO_GamepadEntryData:New(item.name or "Item")
        ed.index = i
        NWT.HiddenPlanBrowserList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenPlanBrowserList:Commit()
    if pb.currentItemIndex and pb.currentItemIndex <= #items then NWT.HiddenPlanBrowserList:SetSelectedIndexWithoutAnimation(pb.currentItemIndex) end
end

function NWT.UpdatePlanBrowserCategoryTabs()
    local pb = NWT.PlanBrowser
    local tabLabel = ATK_PlanBrowser_UICategoryTabs
    if not tabLabel then return end
    local tabs = {}
    local maxTabs = 5
    local startIdx = math.max(1, pb.currentCategoryIndex - 2)
    local endIdx = math.min(#pb.categories, startIdx + maxTabs - 1)
    if endIdx - startIdx < maxTabs - 1 then startIdx = math.max(1, endIdx - maxTabs + 1) end
    for i = startIdx, endIdx do
        local cat = pb.categories[i]
        if i == pb.currentCategoryIndex then table.insert(tabs, string.format("|cFFD700[%s]|r", cat.name))
        else table.insert(tabs, string.format("|c888888%s|r", cat.name)) end
    end
    tabLabel:SetText(table.concat(tabs, "   "))
end

function NWT.OpenPlanBrowser()
    local pb = NWT.PlanBrowser
    if pb.isOpen then return end
    if pb.isBuilding then return end  -- Don't open while building
    if CHAT_SYSTEM then if CHAT_SYSTEM.HideTextEntry then CHAT_SYSTEM:HideTextEntry() end if CHAT_SYSTEM.Minimize then CHAT_SYSTEM:Minimize() end end
    
    -- If already built, open immediately
    if pb.dataBuilt and #pb.categories > 0 then
        pb.isOpen, pb.currentCategoryIndex, pb.currentItemIndex, pb.scrollOffset = true, 1, 1, 0
        if PLAN_BROWSER_SCENE then SCENE_MANAGER:Push("planBrowserScene") end
        NWT.UpdatePlanBrowserCategoryTabs() NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails() NWT.UpdatePlanBrowserStats()
        NWT.SyncHiddenPlanBrowserList()
        return
    end
    
    -- Build data async, then open when complete
    NWT.BuildPlanBrowserData(function()
        if #pb.categories == 0 then 
            NWT.Debug("|cFFFF00[Plan Browser]|r No plans found.") 
            return 
        end
        pb.isOpen, pb.currentCategoryIndex, pb.currentItemIndex, pb.scrollOffset = true, 1, 1, 0
        if PLAN_BROWSER_SCENE then SCENE_MANAGER:Push("planBrowserScene") end
        NWT.UpdatePlanBrowserCategoryTabs() NWT.UpdatePlanBrowserList() NWT.UpdatePlanBrowserDetails() NWT.UpdatePlanBrowserStats()
        NWT.SyncHiddenPlanBrowserList()
    end)
end

function NWT.ClosePlanBrowser()
    if NWT.PlanBrowser.isOpen then
        NWT.PlanBrowser.isOpen = false
        if PLAN_BROWSER_SCENE then SCENE_MANAGER:Hide("planBrowserScene") end
    end
end
