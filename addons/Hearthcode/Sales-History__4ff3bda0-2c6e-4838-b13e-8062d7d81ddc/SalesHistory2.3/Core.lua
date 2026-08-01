SalesHistory = SalesHistory or {}
local SH = SalesHistory

SH.name    = "SalesHistory"
SH.version = "1.31"
SH.MAX_RESULTS = 500

-- Filter/Sort state
SH.filterState = {
    equipment = true,
    materials = true,
    furnishings = true,
    motifsRecipes = true,
    consumables = true,
    masterWrits = true,
    companionGear = true,
    miscellaneous = true,
    textSearch = "",
    sortBy = "date", -- "date", "price", "unitPrice"
    currentPage = 1,
    itemsPerPage = 12,
}

function SH.OnAddonLoaded(_, addonName)
    if addonName ~= SH.name then return end
    EVENT_MANAGER:UnregisterForEvent(SH.name, EVENT_ADD_ON_LOADED)

    SH.savedVars = ZO_SavedVars:NewAccountWide("SalesHistorySavedVars", 1, nil, {
        selectedGuildIndex = 1,
        cachedResults      = {},
        lastScanDate       = "",
    })

    SH.SetupSettings()
end

function SH.ShowSpinner()
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[SalesHistory] Scanning sales history...")
end

function SH.HideSpinner()
    -- alert clears itself
end

function SH.OnScanComplete(results)
    SH.savedVars.lastScanDate = GetDateStringFromTimestamp(GetTimeStamp())

    -- Find genuinely new sales using itemLink + price + date for dedup
    local newSales = {}
    for _, sale in ipairs(results) do
        local saleDate = sale.dateStr or GetDateStringFromTimestamp(sale.timestamp)
        local isDuplicate = false
        
        for _, existingSale in ipairs(SH.savedVars.cachedResults) do
            local existingDate = existingSale.dateStr or GetDateStringFromTimestamp(existingSale.timestamp)
            if existingSale.itemLink == sale.itemLink and 
               existingSale.price == sale.price and
               existingDate == saleDate then
                isDuplicate = true
                break
            end
        end
        
        if not isDuplicate then
            sale.source = "scan" -- Track where this came from
            table.insert(newSales, sale)
        end
    end

    if #newSales == 0 then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[SalesHistory] Scan complete. No new sales found.")
        return
    end

    -- Alert each new sale
    for _, sale in ipairs(newSales) do
        local name = sale.itemName or "Unknown"
        if sale.quantity and sale.quantity > 1 then
            name = name .. " x" .. sale.quantity
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,
            string.format("[SalesHistory] New sale: %s | %sg | %s", name, tostring(sale.price), sale.dateStr or "?"))
    end

    -- Merge new sales into cachedResults
    for _, sale in ipairs(newSales) do
        table.insert(SH.savedVars.cachedResults, sale)
    end

    -- Sort all by most recent first
    table.sort(SH.savedVars.cachedResults, function(a, b) return a.timestamp > b.timestamp end)

    -- Trim to max 500
    while #SH.savedVars.cachedResults > SH.MAX_RESULTS do
        table.remove(SH.savedVars.cachedResults)
    end

    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,
        string.format("[SalesHistory] %d new sale(s) saved. Total stored: %d.", #newSales, #SH.savedVars.cachedResults))
end

-- Category check functions
local function IsMaterial(itemType)
    return itemType == ITEMTYPE_STYLE_MATERIAL or
           itemType == ITEMTYPE_REAGENT or
           itemType == ITEMTYPE_POISON_BASE or
           itemType == ITEMTYPE_POTION_BASE or
           itemType == ITEMTYPE_INGREDIENT or
           itemType == ITEMTYPE_SPICE or
           itemType == ITEMTYPE_FLAVORING or
           itemType == ITEMTYPE_ADDITIVE or
           itemType == ITEMTYPE_FURNISHING_MATERIAL or
           itemType == ITEMTYPE_ARMOR_TRAIT or
           itemType == ITEMTYPE_ARMOR_BOOSTER or
           itemType == ITEMTYPE_WEAPON_TRAIT or
           itemType == ITEMTYPE_WEAPON_BOOSTER or
           itemType == ITEMTYPE_JEWELRY_TRAIT or
           itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
           itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
           itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
           itemType == ITEMTYPE_ENCHANTMENT_BOOSTER or
           itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or
           itemType == ITEMTYPE_WOODWORKING_BOOSTER or
           itemType == ITEMTYPE_WOODWORKING_MATERIAL or
           itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
           itemType == ITEMTYPE_CLOTHIER_BOOSTER or
           itemType == ITEMTYPE_CLOTHIER_MATERIAL or
           itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
           itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or
           itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
           itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
           itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
           itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or
           itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or
           itemType == ITEMTYPE_JEWELRY_BOOSTER or
           itemType == ITEMTYPE_JEWELRY_RAW_TRAIT
end

local function IsCompanionGear(itemLink, itemType)
    if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON then return false end
    local itemName = GetItemLinkName(itemLink)
    return itemName and itemName:lower():find("companion") ~= nil
end

local function GetItemCategory(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    
    if IsCompanionGear(itemLink, itemType) then
        return "companionGear"
    elseif itemType == ITEMTYPE_MASTER_WRIT then
        return "masterWrits"
    elseif itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
        return "equipment"
    elseif IsMaterial(itemType) then
        return "materials"
    elseif itemType == ITEMTYPE_FURNISHING then
        return "furnishings"
    elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or itemType == ITEMTYPE_RECIPE then
        return "motifsRecipes"
    elseif itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK or
           itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON or
           itemType == ITEMTYPE_SOUL_GEM then
        return "consumables"
    else
        return "miscellaneous"
    end
end

function SH.GetFilteredResults()
    local filtered = {}
    local searchLower = SH.filterState.textSearch:lower()
    
    for _, sale in ipairs(SH.savedVars.cachedResults) do
        local category = GetItemCategory(sale.itemLink)
        
        -- Check category filter
        if SH.filterState[category] then
            -- Check text search
            local passesSearch = true
            if searchLower ~= "" then
                local itemName = (sale.itemName or ""):lower()
                if not itemName:find(searchLower, 1, true) then
                    passesSearch = false
                end
            end
            
            if passesSearch then
                table.insert(filtered, sale)
            end
        end
    end
    
    -- Sort
    if SH.filterState.sortBy == "price" then
        table.sort(filtered, function(a, b) return (a.price or 0) > (b.price or 0) end)
    elseif SH.filterState.sortBy == "unitPrice" then
        table.sort(filtered, function(a, b)
            local aUnit = (a.price or 0) / (a.quantity or 1)
            local bUnit = (b.price or 0) / (b.quantity or 1)
            return aUnit > bUnit
        end)
    else -- date
        table.sort(filtered, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
    end
    
    return filtered
end

EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ADD_ON_LOADED, SH.OnAddonLoaded)
