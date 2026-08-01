ItemSaverLite = {}

local ISL = ItemSaverLite

ISL.name = "ItemSaverLite"


ISL.markerTextures = {}
ISL.SV = nil

ISL.defaultSV = {
    savedItems = {},
    markerTexture = "Padlock",	
    markerColor = "00ff00",
    filterStore = true,
    filterDeconstruction = true,
    filterResearch = true,
    filterGuildStore = false,
    filterMail = false,
    filterTrade = false,
    markerScale = 0.6,
    markerAnchor = 7,
    offsetX = -1,
    offsetY = 1,
	enableContextMenu = true,
}

ZO_CreateStringId("SI_ITEMSAVERLITE_SAVE", "Save Item")
ZO_CreateStringId("SI_ITEMSAVERLITE_UNSAVE", "Unlock")
ZO_CreateStringId("SI_BINDING_NAME_ITEMSAVERLITE_TOGGLE", "Toggle Lock")

local LF = LibFilters3
local LCM = LibCustomMenu

function ItemSaver_ToggleItemSave(bagId, slotIndex)
    if not bagId then
        local target = WINDOW_MANAGER:GetMouseOverControl()
        local function FindData(control)
            if not control or control == GuiRoot then return nil, nil end
            local bag, slot = ISL.GetInfoFromRowControl(control)
            if bag then return bag, slot end
            return FindData(control:GetParent())
        end
        bagId, slotIndex = FindData(target)
    end
    
    if not bagId then return false end
    return ISL.ToggleItemSave(bagId, slotIndex)
end

local LISTS = {
    ZO_PlayerInventoryList, 
	ZO_PlayerBankBackpack,
    ZO_GuildBankBackpack, 
	ZO_CraftBagList, 
	ZO_HouseBankBackpack, 
	ZO_FurnitureVaultList,
    ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
    ZO_EnchantingTopLevelInventoryBackpack, 
	ZO_AlchemyTopLevelInventoryBackpack,
    ZO_VengeanceInventoryList
}

local ANCHOR_OFFSETS = {
    [TOPLEFT] = {x = 2, y = 2},    
	[TOP] = {x = 0, y = 2},    
	[TOPRIGHT] = {x = -2, y = 2},
    [RIGHT] = {x = -2, y = 0},     
	[BOTTOMRIGHT] = {x = -2, y = -2}, 
	[BOTTOM] = {x = 0, y = -2},
    [BOTTOMLEFT] = {x = 2, y = -2}, 
	[LEFT] = {x = 2, y = 0},   
	[CENTER] = {x = 0, y = 0}
}

function ISL.SignItemInstanceId(itemInstanceId)
    if itemInstanceId and itemInstanceId > 2147483647 then
        return itemInstanceId - 4294967296
    end
    return itemInstanceId
end

function ISL.RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", (r < 0 and 0 or r > 1 and 1 or r) * 255, (g < 0 and 0 or g > 1 and 1 or g) * 255, (b < 0 and 0 or b > 1 and 1 or b) * 255)
end

function ISL.HexToRGB(hex)
    return tonumber(string.sub(hex, 1, 2), 16) / 255, tonumber(string.sub(hex, 3, 4), 16) / 255, tonumber(string.sub(hex, 5, 6), 16) / 255
end

function ISL.GetMarkerTextureArrays()
    local paths, names, keys = {}, {}, {}
    for name in pairs(ISL.markerTextures) do table.insert(keys, name) end
    table.sort(keys)
    for i = 1, #keys do
        paths[i] = ISL.markerTextures[keys[i]]
        names[i] = keys[i]
    end
    return paths, names
end

function ISL.GetInfoFromRowControl(rowControl)
    if not rowControl then return end
    local data = rowControl.dataEntry and rowControl.dataEntry.data or rowControl
    return data.bagId or data.bag, data.slotIndex or data.index
end

function ISL.CreateMarkerControl(parent)
    if not ISL.SV then return end

    local control = parent:GetNamedChild("ItemSaverLite")
    if not control then
        control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ItemSaverLite", parent, CT_TEXTURE)
        control:SetDrawTier(DT_HIGH)
    end

    local bagId, slotIndex = ISL.GetInfoFromRowControl(parent)
    local texturePath, r, g, b = ISL.GetMarkerInfo(bagId, slotIndex)
    if not texturePath then
        control:SetHidden(true)
        return
    end

    local markerAnchor, customOffsetX, customOffsetY = ISL.GetMarkerAnchor()
    local offsets = ANCHOR_OFFSETS[markerAnchor] or ANCHOR_OFFSETS[TOPLEFT]

    control:SetHidden(false)
    control:SetTexture(texturePath)
    control:SetColor(r, g, b)
    
    local scale = (ISL.SV.markerScale or 1.0) * 32
    control:SetDimensions(scale, scale)
    control:ClearAnchors()
    control:SetAnchor(markerAnchor, parent, markerAnchor, offsets.x + customOffsetX, offsets.y + customOffsetY)
end

function ISL.RefreshEquipmentControls()
    for i = 1, ZO_Character:GetNumChildren() do
        local child = ZO_Character:GetChild(i)
        if child and string.find(child:GetName(), "ZO_CharacterEquipmentSlots") then
            ISL.CreateMarkerControl(child)
        end
    end
end

function ISL.RefreshAll()
    local filters = {
        LF_INVENTORY, 
		LF_BANK_WITHDRAW, 
		LF_BANK_DEPOSIT, 
		LF_GUILDBANK_WITHDRAW,
        LF_GUILDBANK_DEPOSIT, 
		LF_SMITHING_DECONSTRUCT, 
		LF_SMITHING_IMPROVEMENT,
        LF_ENCHANTING_CREATION, 
		LF_ENCHANTING_EXTRACTION, 
		LF_CRAFTBAG,
		LF_FURNITURE_VAULT_WITHDRAW,
		LF_FURNITURE_VAULT_DEPOSIT
    }
    for i = 1, #filters do LF:RequestUpdate(filters[i]) end
    ISL.RefreshEquipmentControls()
end

function ISL.RegisterMarkers()
    local markers = {
        { "Box Star", [[/esoui/art/guild/guild_rankicon_leader_large.dds]] },
        { "Flag",     [[/esoui/art/ava/tabicon_bg_score_disabled.dds]] },
        { "Padlock",  [[/esoui/art/campaign/campaignbrowser_fullpop.dds]] },
        { "Star",     [[/esoui/art/campaign/overview_indexicon_bonus_disabled.dds]] },
        { "Timer",    [[/esoui/art/tutorial/timer_icon.dds]] },
    }
    
    for i = 1, #markers do
        local m = markers[i]
        ISL.markerTextures[m[1]] = m[2]
    end
end

function ISL.ToggleFilter(suffix, filterType)
    local filterTag = "ItemSaverLite_" .. suffix
    if LF:IsFilterRegistered(filterTag, filterType) then
        LF:UnregisterFilter(filterTag, filterType)
    else
        LF:RegisterFilter(filterTag, filterType, function(slotOrBagId, slotIndex)
            local bagId = type(slotOrBagId) == "number" and slotOrBagId or ISL.GetInfoFromRowControl(slotOrBagId)
            return not ISL.IsItemSaved(bagId, slotIndex or select(2, ISL.GetInfoFromRowControl(slotOrBagId)))
        end)
    end
    LF:RequestUpdate(filterType)
end

function ISL.ToggleFilters()
    if ISL.SV.filterStore then ISL.ToggleFilter("VendorSell", LF_VENDOR_SELL) end
    if ISL.SV.filterDeconstruction then
        ISL.ToggleFilter("SmithingDeconstruct", LF_SMITHING_DECONSTRUCT)
        ISL.ToggleFilter("JewelryDeconstruct", LF_JEWELRY_DECONSTRUCT)
    end
    if ISL.SV.filterResearch then
        ISL.ToggleFilter("SmithingResearch", LF_SMITHING_RESEARCH)
        ISL.ToggleFilter("JewelryResearch", LF_JEWELRY_RESEARCH)
    end
    if ISL.SV.filterGuildStore then ISL.ToggleFilter("GuildStoreSell", LF_GUILDSTORE_SELL) end
    if ISL.SV.filterMail then ISL.ToggleFilter("MailSend", LF_MAIL_SEND) end
    if ISL.SV.filterTrade then ISL.ToggleFilter("Trade", LF_TRADE) end
end

function ISL.ToggleItemSave(bagId, slotIndex)
    if not ISL.SV or not ISL.SV.savedItems then return false end
    local id = ISL.SignItemInstanceId(GetItemInstanceId(bagId, slotIndex))
    local isSaved
    if ISL.IsItemSaved(bagId, slotIndex) then
        ISL.SV.savedItems[id] = nil
        isSaved = false
    else
        ISL.SV.savedItems[id] = true
        isSaved = true
    end
    ISL.RefreshAll()
    return isSaved
end

function ISL.GetMarkerInfo(bagId, slotIndex)
    if not ISL.SV or not ISL.IsItemSaved(bagId, slotIndex) then return nil end
    return ISL.markerTextures[ISL.SV.markerTexture], ISL.HexToRGB(ISL.SV.markerColor)
end

function ISL.IsItemSaved(bagId, slotIndex)
    if not ISL.SV or not ISL.SV.savedItems then return false end
    local items = ISL.SV.savedItems
    return items[ISL.SignItemInstanceId(GetItemInstanceId(bagId, slotIndex))] == true
end

function ISL.GetMarkerAnchor()
    local d = ISL.SV
    local constants = { TOPLEFT, TOP, TOPRIGHT, RIGHT, BOTTOMRIGHT, BOTTOM, BOTTOMLEFT, LEFT, CENTER }
    return constants[d and d.markerAnchor or 1] or TOPLEFT, d and d.offsetX or 0, d and d.offsetY or 0
end

function ISL.InitializeHooks()
    local hooked = {}
    local function setupWrapper(rowControl, slot)
        local parentName = rowControl:GetParent():GetParent():GetName()
        if hooked[parentName] then hooked[parentName](rowControl, slot) end
        ISL.CreateMarkerControl(rowControl)
    end
    for i = 1, #LISTS do
        local list = LISTS[i]
        if list and list.dataTypes and list.dataTypes[1] then
            hooked[list:GetName()] = list.dataTypes[1].setupCallback
            list.dataTypes[1].setupCallback = setupWrapper
        end
    end
end

function ISL.AddItemContextMenu(inventorySlot, slotActions)
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if not bagId then return end
    
    if ISL.IsItemSaved(bagId, slotIndex) then
        slotActions:AddCustomSlotAction(
            SI_ITEMSAVERLITE_UNSAVE,
            function() 
                ISL.ToggleItemSave(bagId, slotIndex)
            end, ""
        )
    else
        slotActions:AddCustomSlotAction(
            SI_ITEMSAVERLITE_SAVE,
            function() 
                ISL.ToggleItemSave(bagId, slotIndex)
            end, ""
        )
    end
end

function ISL.OnAddonLoaded(eventCode, addonName)
    if addonName ~= ISL.name then return end   
    EVENT_MANAGER:UnregisterForEvent(ISL.name, EVENT_ADD_ON_LOADED)
    
    ISL.SV = ZO_SavedVars:NewAccountWide("ItemSaverLite_SV", 1, nil, ISL.defaultSV)

    ISL.RegisterMarkers()
    LF:InitializeLibFilters()
    ISL.ToggleFilters()
    ISL.InitializeHooks()
    ISL.RefreshEquipmentControls()
    ISL.CreateSettingsMenu()

    if ISL.SV.enableContextMenu then
        LCM:RegisterContextMenu(ISL.AddItemContextMenu, LCM.CATEGORY_LATE)
    end
	
    EVENT_MANAGER:RegisterForEvent(ISL.name .. "EquipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, _, isNew, _, reason)
        if bagId == BAG_WORN and not isNew and reason == 0 then ISL.RefreshEquipmentControls() end
    end)
end
EVENT_MANAGER:RegisterForEvent(ISL.name, EVENT_ADD_ON_LOADED, ISL.OnAddonLoaded)