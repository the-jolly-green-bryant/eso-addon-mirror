local lib = GearOverview

local order = {
    [EQUIP_TYPE_HEAD] = 1,
    [EQUIP_TYPE_SHOULDERS] = 2,
    [EQUIP_TYPE_CHEST] = 3,
    [EQUIP_TYPE_HAND] = 4,
    [EQUIP_TYPE_WAIST] = 5,
    [EQUIP_TYPE_LEGS] = 6,
    [EQUIP_TYPE_FEET] = 7,
    [EQUIP_TYPE_NECK] = 8,
    [EQUIP_TYPE_RING] = 9,
    [EQUIP_TYPE_MAIN_HAND] = -1,
    [EQUIP_TYPE_OFF_HAND] = -1,
    [EQUIP_TYPE_ONE_HAND] = -1,
    [EQUIP_TYPE_TWO_HAND] = -1
}

local orderWeapons = {
    [WEAPONTYPE_DAGGER] = 10,
    [WEAPONTYPE_AXE] = 11,
    [WEAPONTYPE_HAMMER] = 12,
    [WEAPONTYPE_SWORD] = 13,
    [WEAPONTYPE_TWO_HANDED_AXE] = 14,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = 15,
    [WEAPONTYPE_TWO_HANDED_SWORD] = 16,
    [WEAPONTYPE_BOW] = 17,
    [WEAPONTYPE_HEALING_STAFF] = 18,
    [WEAPONTYPE_FIRE_STAFF] = 19,
    [WEAPONTYPE_FROST_STAFF] = 20,
    [WEAPONTYPE_LIGHTNING_STAFF] = 21,
    [WEAPONTYPE_SHIELD] = 22
}

function lib.trimString(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--- Scans all available sets in the game and creates a mapping from setName to setId
function lib.scanSets()
    for itemSetId = 1, lib.scanMaxSetId, 1 do
        local setName = GetItemSetName(itemSetId)
        if string.len(setName) > 0 then
            lib.setNameToId[string.lower(setName)] = itemSetId
            -- lib.debug(tostring(itemSetId), setName)
            lib.maxSetId = itemSetId
        end
    end
    lib.log(lib.LOG_LEVEL_DEBUG, "scanSets complete. maxSetId:", lib.maxSetId, " scanMaxSetId:", lib.scanMaxSetId)
end

--- Gets the position of the item in the matrix
--- @param itemLink string link to the order number from
--- @return number the order number in the display table
function lib.getOrderNumber(itemLink)
    local orderNumber = order[GetItemLinkEquipType(itemLink)]
    if orderNumber == -1 then
        orderNumber = orderWeapons[GetItemLinkWeaponType(itemLink)]
    end
    return orderNumber
end

--- Adds the items from the given bag to the list of owned items
--- @param bag table the bag to search in
--- @return void
function lib.getItems(bag)
    for slotId = 0, GetBagSize(bag) do
        local _, _, _, _, _, equipType, _, _ = GetItemInfo(bag, slotId)
        if equipType ~= EQUIP_TYPE_INVALID then
            local itemLink = GetItemLink(bag, slotId)
            lib.processItemLink(itemLink)
        end
    end
end

--- Return all the keys in the table
--- @param table table data
--- @return table (unsorted)list of keys in the table
function lib.getTableKeys(table)
    local keys = {}
    local n = 0
    for k, _ in pairs(table) do
        n = n + 1
        keys[n] = k
    end
    return keys
end

--- Adds the items to the list of owned items
--- @param itemLink string string item link of the item to add
--- @return void
function lib.processItemLink(itemLink)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    local quality = GetItemLinkDisplayQuality(itemLink)
    if hasSet then
        local orderNumber = lib.getOrderNumber(itemLink)
        if not lib.bag[setId] then
            lib.bag[setId] = { [orderNumber] = quality }
        else
            if lib.bag[setId][orderNumber] then
                if quality > lib.bag[setId][orderNumber] then
                    lib.bag[setId][orderNumber] = quality
                end
            else
                lib.bag[setId][orderNumber] = quality
            end
        end
    end
end

function lib.getIIFADatabase()
    if IIfA.database ~= nil then
        -- Inventory Insight <= v3.7.8
        lib.log(lib.LOG_LEVEL_DEBUG, "IIFA: Using the old database format")
        return IIfA.database
    end

    if IIFA_DATABASE ~= nil then
        -- Inventory Insight > v3.7.8
        if IIfA.currentAccount ~= nil and IIfA.currentServerType ~= nil then
            lib.log(lib.LOG_LEVEL_DEBUG, "IIFA: Using the new database format")
            return IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
        else
            lib.log(lib.LOG_LEVEL_ERROR, "IIFA_DATABASE: No database found for current account on current server")
            return nil
        end
    end

    lib.log(lib.LOG_LEVEL_ERROR, "No valid Inventory Insight database not found")
    return nil
end

function lib.fetchItems()
    lib.getItems(BAG_BACKPACK)
    lib.getItems(BAG_BANK)
    lib.getItems(BAG_SUBSCRIBER_BANK)
    lib.getItems(BAG_WORN)

    if IIfA then
        local iifa_db = lib.getIIFADatabase()
        if iifa_db ~= nil then
            lib.log(lib.LOG_LEVEL_INFO, "Searching IIfA database")
            for itemLink, _ in pairs(iifa_db) do
                lib.processItemLink(itemLink)
            end
        end
    else
        lib.log(lib.LOG_LEVEL_INFO, "Download Inventory Insight to add the items for all characters")
    end
end

function lib.parseSets(value)
    if string.len(value) then
        lib.log(lib.LOG_LEVEL_INFO, "Parse custom sets")
        lib.setList = {}
        for setName in string.gmatch(value, "[^\n\r]+") do
            if string.len(setName) then
                local setId = lib.setNameToId[string.lower(lib.trimString(setName))]
                if setId then
                    lib.log(lib.LOG_LEVEL_INFO, "Set", setName, setId)
                    table.insert(lib.setList, { name = GetItemSetName(setId), id = setId })
                else
                    lib.log(lib.LOG_LEVEL_WARNING, "Unknown set", setName)
                end
            end
        end
    end
end

function lib.takeScreenshot()
    GearOverviewUIGearViewButtonScreenshot:SetHidden(true)

    local chatHidden = CHAT_SYSTEM:IsHidden()
    local minbarShown = CHAT_SYSTEM.isMinimized
    local buiPanelShown = BUI_Panel and not BUI_Panel:IsHidden()
    if buiPanelShown then
        BUI_Panel:SetHidden(true)
    end
    if not chatHidden then
        CHAT_SYSTEM:Minimize()
        CHAT_SYSTEM:HideMinBar()
    elseif minbarShown then
        CHAT_SYSTEM:HideMinBar()
    end

    zo_callLater(function()
        TakeScreenshot()
        zo_callLater(function()
            if buiPanelShown then
                BUI_Panel:SetHidden(false)
            end
            if not chatHidden then
                CHAT_SYSTEM:ShowMinBar()
                CHAT_SYSTEM:Maximize()
            elseif minbarShown then
                CHAT_SYSTEM:ShowMinBar()
            end
            GearOverviewUIGearViewButtonScreenshot:SetHidden(false)
        end, 1000)
    end, 1000)
end

function lib.getGuildIds()
    local guildIds = {}
    for guildIndex = 1, GetNumGuilds(), 1 do
        local guildId = GetGuildId(guildIndex)
        lib.debug("Found guild", guildIndex, GetGuildName(guildId))
        guildIds[guildIndex] = guildId
    end
    return guildIds
end

function lib.getGuildPresets()
    local guildIds = lib.getGuildIds()
    local presets = {}
    for _, guildId in pairs(guildIds) do
        local guildPresets = lib.guildPresets[guildId]
        if (guildPresets ~= nil) then
            lib.debug("Found guild preset", guildId, GetGuildName(guildId), "with", #guildPresets, "sets")
            for _, preset in pairs(guildPresets) do
                local guildPreset = {
                    name = GetGuildName(guildId) .. ": " .. preset.name,
                    displayWeapons = preset.displayWeapons,
                    sets = preset.sets,
                }
                table.insert(presets, guildPreset)
            end
        end
    end
    return presets
end

function lib.getApplicablePresets()
    local presets = {}
    local guildPresets = lib.getGuildPresets()
    for _, v in pairs(guildPresets) do
        table.insert(presets, v)
    end
    for _, v in pairs(lib.presets) do
        table.insert(presets, v)
    end
    lib.debug("Found", #presets, "applicable presets")
    return presets
end

function lib.getPresetByName(name)
    for _, preset in pairs(lib.applicablePresets) do
        if (preset.name == name) then
            return preset
        end
    end
    return nil
end