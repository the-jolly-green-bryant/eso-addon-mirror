local NirncruxMiner = {}
local NM = NirncruxMiner
NM.name = "NirncruxMiner"

ZO_CreateStringId("SI_NIRNCRUX_MINER_OPTION", "Nirncrux Miner")
ZO_CreateStringId("SI_NIRNCRUX_MINER_DIALOG_TITLE", "Nirncrux Miner")

local NIRN = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED

local processing = false
local pendingItems = {}
local currentIndex = 0
local deconstructQueue = {}
local deconstructReady = false
local atRetraitStation = false

function NM.FindIdenticalWeapons(itemLink, skipSlot)
    local targetId = GetItemLinkItemId(itemLink)
    if not targetId then return {} end

    local matches = {}
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        if not skipSlot or slot ~= skipSlot then
            local link = GetItemLink(BAG_BACKPACK, slot)
            if link then
                local id = GetItemLinkItemId(link)
                if id == targetId and GetItemLinkItemType(link) == ITEMTYPE_WEAPON then
                    table.insert(matches, {
                        bag = BAG_BACKPACK,
                        slot = slot,
                        itemId = id,
                        itemLink = link,
                    })
                end
            end
        end
    end
    return matches
end

function NM.GetCrystalCount()
    local location = GetCurrencyPlayerStoredLocation(CURT_TRANSMUTE_CRYSTALS)
    return GetCurrencyAmount(CURT_TRANSMUTE_CRYSTALS, location)
end

function NM.FormatCurrency(amount)
    local r, g, b = GetCurrencyKeyboardColor(CURT_TRANSMUTE_CRYSTALS)
    local icon = GetCurrencyKeyboardIcon(CURT_TRANSMUTE_CRYSTALS)
    local colorText = ("|c%02x%02x%02x"):format(r * 255, g * 255, b * 255)
    return colorText .. amount .. "|r |t20:20:" .. icon .. "|t"
end

function NM.AddToDeconstructQueue(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then return end
    
    if not deconstructQueue[itemId] then
        deconstructQueue[itemId] = { itemId = itemId, itemLink = itemLink, count = 0 }
    end
    deconstructQueue[itemId].count = deconstructQueue[itemId].count + 1
    deconstructReady = true
end

function NM.ProcessDeconstructQueue()
    local craftingType = GetCraftingInteractionType()
    if craftingType ~= CRAFTING_TYPE_BLACKSMITHING and craftingType ~= CRAFTING_TYPE_WOODWORKING then
        return
    end

    PrepareDeconstructMessage()
    local totalAdded = 0
    local bagSize = GetBagSize(BAG_BACKPACK)
    
    for slot = 0, bagSize - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot)
        if link then
            local itemId = GetItemLinkItemId(link)
            if deconstructQueue[itemId] and deconstructQueue[itemId].count > 0 then
                if CanItemBeDeconstructed(BAG_BACKPACK, slot) then
                    if AddItemToDeconstructMessage(BAG_BACKPACK, slot, 1) then
                        deconstructQueue[itemId].count = deconstructQueue[itemId].count - 1
                        if deconstructQueue[itemId].count <= 0 then
                            deconstructQueue[itemId] = nil
                        end
                        totalAdded = totalAdded + 1
                    end
                end
            end
        end
    end
    
    if totalAdded > 0 then
        SendDeconstructMessage()
    end
    
    if next(deconstructQueue) == nil then
        deconstructReady = false
    end
end

function NM.ProcessNextItem()
    if not processing then return end

    if currentIndex > #pendingItems then
        processing = false
        for _, item in ipairs(pendingItems) do
            NM.AddToDeconstructQueue(item.itemLink)
        end
        pendingItems = {}
        currentIndex = 0
        d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/yes.dds|t")
        return
    end

    local item = pendingItems[currentIndex]
    local bag, slot = item.bag, item.slot
    local link = GetItemLink(bag, slot)
    
    if not link then
        currentIndex = currentIndex + 1
        NM.ProcessNextItem()
        return
    end

    if GetItemLinkTraitInfo(link) == NIRN then
        currentIndex = currentIndex + 1
        NM.ProcessNextItem()
        return
    end

    local cost = GetItemRetraitCost(bag, slot)
    if NM.GetCrystalCount() < cost then
        d("[NirncruxMiner] Insufficient transmute crystals.")
        processing = false
        pendingItems = {}
        currentIndex = 0
        return
    end

    d("[NirncruxMiner] " .. currentIndex .. "/" .. #pendingItems)
    RequestItemTraitChange(bag, slot, NIRN)
end

function NM.OnRetraitResponse(_, result, bag, slot, itemLink, traitType)
    if not processing then return end

    if result ~= RETRAIT_RESPONSE_SUCCESS then
        d("[NirncruxMiner] Failed: " .. GetString("SI_RETRAITRESPONSE", result))
    end

    currentIndex = currentIndex + 1
    NM.ProcessNextItem()
end

function NM.StartProcessing(items)
    if processing then return end

    local filtered = {}
    for _, item in ipairs(items) do
        local link = GetItemLink(item.bag, item.slot)
        if link and GetItemLinkTraitInfo(link) ~= NIRN then
            table.insert(filtered, item)
        end
    end

    if #filtered == 0 then
        d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/no.dds|t No items to process (all already Nirnhoned).")
        return
    end

    pendingItems = filtered
    currentIndex = 1
    processing = true
    NM.ProcessNextItem()
end

function NM.ShowConfirmationDialog(items, itemLink)
    local totalCost = 0
    for _, item in ipairs(items) do
        totalCost = totalCost + GetItemRetraitCost(item.bag, item.slot)
    end

    local dialogParams = {
        callback = function() NM.StartProcessing(items) end,
        mainText = zo_strformat(
            "Retrait <<1>> items of |cFFFFFF\"<<2>>\"|r to |cFFA500Nirnhoned|r?\n\nCost: <<3>>",
            #items,
            zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)),
            NM.FormatCurrency(totalCost)
        )
    }

    ZO_Dialogs_ShowDialog('NIRNCRUX_MINER_CONFIRMATION_DIALOG', dialogParams)
end

function NM.RegisterDialog()
    ESO_Dialogs["NIRNCRUX_MINER_CONFIRMATION_DIALOG"] = {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        title = { text = SI_NIRNCRUX_MINER_DIALOG_TITLE },
        mainText = { text = function(dialog) return dialog.data.mainText end },
        mustChoose = true,
        buttons = {
            [1] = { text = SI_DIALOG_ACCEPT, callback = function(dialog) dialog.data.callback() end },
            [2] = { text = SI_DIALOG_CANCEL },
        },
    }
end

function NM.AddNirncruxOption(inventorySlot, slotActions)
    slotActions:AddCustomSlotAction(
        SI_NIRNCRUX_MINER_OPTION,
        function()
            local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
            if not bagId then return end

            local link = GetItemLink(bagId, slotIndex)
            if GetItemLinkItemType(link) ~= ITEMTYPE_WEAPON then
				d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/no.dds|t Not a weapon.")
				return
			end

            local matches = NM.FindIdenticalWeapons(link, slotIndex)
            if #matches == 0 then
                d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/no.dds|t No matching weapons found.")
                return
            end

            local allMatches = {
                { bag = bagId, slot = slotIndex, itemId = GetItemLinkItemId(link), itemLink = link }
            }
            for _, m in ipairs(matches) do
                table.insert(allMatches, m)
            end

            local filtered = {}
            for _, item in ipairs(allMatches) do
                local itemLink = GetItemLink(item.bag, item.slot)
                if itemLink and GetItemLinkTraitInfo(itemLink) ~= NIRN then
                    table.insert(filtered, item)
                end
            end

            if #filtered < 2 then
                d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/no.dds|t Need at least 2 items to retrait (found " .. #filtered .. " retrait-able items).")
                return
            end

            local totalCost = 0
            for _, item in ipairs(filtered) do
                totalCost = totalCost + GetItemRetraitCost(item.bag, item.slot)
            end
            
            local have = NM.GetCrystalCount()
            if have < totalCost then
                d("[NirncruxMiner] |t24:24:NirncruxMiner/textures/no.dds|t Not enough |t20:20:" .. GetCurrencyKeyboardIcon(CURT_TRANSMUTE_CRYSTALS) .. "|t (need " .. totalCost .. ", have " .. have .. ").")
                return
            end

            NM.ShowConfirmationDialog(filtered, link)
        end,
        "",
        function() return atRetraitStation end
    )
end

function NM.OnAddonLoaded(event, addonName)
    if addonName ~= NM.name then return end
    EVENT_MANAGER:UnregisterForEvent(NM.name, EVENT_ADD_ON_LOADED)

    NM.RegisterDialog()
    LibCustomMenu:RegisterContextMenu(NM.AddNirncruxOption, LibCustomMenu.CATEGORY_LATE)

    EVENT_MANAGER:RegisterForEvent(NM.name .. "_RetraitStationStart", EVENT_RETRAIT_STATION_INTERACT_START, function()
		atRetraitStation = true
	end)

	EVENT_MANAGER:RegisterForEvent(NM.name .. "_InteractionEnded", EVENT_INTERACTION_ENDED, function(_, interactType)
		if interactType == INTERACTION_RETRAIT then
			atRetraitStation = false
		end
	end)
	
    EVENT_MANAGER:RegisterForEvent(NM.name .. "_RetraitResponse", EVENT_RETRAIT_RESPONSE, NM.OnRetraitResponse)
	
	EVENT_MANAGER:RegisterForEvent(NM.name .. "_StationInteract", EVENT_CRAFTING_STATION_INTERACT, function(event, craftingType)
		if (craftingType == CRAFTING_TYPE_BLACKSMITHING or craftingType == CRAFTING_TYPE_WOODWORKING) and deconstructReady then
			NM.ProcessDeconstructQueue()
		end
	end)
end

EVENT_MANAGER:RegisterForEvent(NM.name, EVENT_ADD_ON_LOADED, NM.OnAddonLoaded)