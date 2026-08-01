--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Junker)
--------------------------------------------------------------------------------
local ZJH       = Zolan_JH
local BagCache  = ZJH.BagCache
local Destroyer = ZJH.Destroyer
local Junker    = ZJH.Junker
local ZL        = ZJH.ZL

Junker.autoMarked       = {}
Junker.ickyItemPatterns = {
    '^cloudy%s',
    '^cold%s',
    '^congealed%s',
    '^flat%s',
    '^murky%s',
    '^stale%s'
}

-- ZO
local BAG_BACKPACK                   = BAG_BACKPACK
local ITEMTYPE_DRINK                 = ITEMTYPE_DRINK
local ITEMTYPE_FOOD                  = ITEMTYPE_FOOD
local ITEMTYPE_TRASH                 = ITEMTYPE_TRASH
local ITEM_QUALITY_NORMAL            = ITEM_QUALITY_NORMAL
local ITEM_TRAIT_TYPE_ARMOR_ORNATE   = ITEM_TRAIT_TYPE_ARMOR_ORNATE
local ITEM_TRAIT_TYPE_JEWELRY_ORNATE = ITEM_TRAIT_TYPE_JEWELRY_ORNATE
local ITEM_TRAIT_TYPE_WEAPON_ORNATE  = ITEM_TRAIT_TYPE_WEAPON_ORNATE
local GetBagSize                     = GetBagSize
local GetItemInfo                    = GetItemInfo
local GetItemLink                    = GetItemLink
local GetItemName                    = GetItemName
local GetItemTrait                   = GetItemTrait
local GetItemType                    = GetItemType
local IsItemJunk                     = IsItemJunk
local SetItemIsJunk                  = SetItemIsJunk
local zo_strlower                    = zo_strlower
-- Lua
local string                         = string

function Junker:isItemTrash(bagID, slotID)
    ZL:debug("   +_ Junker:isItemTrash")

    local isItemTrash = false
    if not ZJH.settings.markTrashAsJunk then return isItemTrash end

    local itemType = GetItemType(bagID, slotID)

    if itemType == ITEMTYPE_TRASH then isItemTrash = true end

    return isItemTrash
end

function Junker:isItemOrnate(bagID, slotID)
    ZL:debug("   +_ Junker:isItemOrnate")

    local isItemOrnate = false
    if not ZJH.settings.markOrnateAsJunk then return isItemOrnate end

    local itemTrait = GetItemTrait(bagID, slotID)

    if itemTrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE   then isItemOrnate = true end
    if itemTrait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then isItemOrnate = true end
    if itemTrait == ITEM_TRAIT_TYPE_WEAPON_ORNATE  then isItemOrnate = true end

    return isItemOrnate
end

function Junker:isItemIckyFood(bagID, slotID)
    ZL:debug("   +_ Junker:isItemIckyFood")

    local isItemIckyFood = false
    if not ZJH.settings.markIckyFoodAsJunk then return isItemIckyFood end

    local itemName    = GetItemName(bagID, slotID)
    local itemType    = GetItemType(bagID, slotID)
    local itemInfo    = { GetItemInfo(bagID, slotID) }
    local itemQuality = itemInfo[8]

    itemName = zo_strlower(itemName)

    if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
        if itemQuality == ITEM_QUALITY_NORMAL then
            for i=1, #self.ickyItemPatterns do
                if itemName:match(self.ickyItemPatterns[i]) then
                    isItemIckyFood = true
                end
            end
        end
    end

    return isItemIckyFood
end

function Junker:isItemWorthlessWeaponOrArmor(bagID, slotID)
    ZL:debug("   +_ Junker:isItemWorthlessWeaponOrArmor")

    local isItemWorthlessWeaponOrArmor = false
    if not ZJH.settings.markWeaponsArmorsAsJunk then return isItemWorthlessWeaponOrArmor end
	
    local itemType    = GetItemType(bagID, slotID)
    local itemInfo    = { GetItemInfo(bagID, slotID) }
    local itemQuality = itemInfo[8]
	local sellPrice   = itemInfo[3]
	
	if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
        if itemQuality == ITEM_QUALITY_NORMAL and sellPrice == 0 then
			if GetItemTrait(bagID, slotID) == ITEM_TRAIT_TYPE_NONE then
				isItemWorthlessWeaponOrArmor = true
			end
		end
	end
	
	return isItemWorthlessWeaponOrArmor
end

function Junker:isItemUserMarked(bagID, slotID)
    ZL:debug("   +_ Junker:isItemUserMarked")

    local isItemUserMarked = false
    if not ZJH.settings.markUserMarkedAsJunk then return isItemUserMarked end

    local itemKey = ZL:getUniqueItemKey(bagID, slotID)

    if ZJH.settings.tracking.userMarked[itemKey] ~= nil and ZJH.settings.tracking.userMarked[itemKey] then
        isItemUserMarked = true
    end

    return isItemUserMarked
end

function Junker:isJunkAuto(bagID, slotID)
    ZL:debug("+_ Junker:isJunkAuto")

    local autoJunkTypes = { 'Trash', 'Ornate', 'Icky Food', 'Worthless Weapon Or Armor' }
    for i = 1, #autoJunkTypes do
        local junkType = autoJunkTypes[i]
        local methodizedJunkType = junkType:gsub('%s', '')

        local methodName = 'isItem'..methodizedJunkType

        if Junker[methodName](self, bagID, slotID) then
            return true, junkType
        end
    end

    return false, nil
end

function Junker:isJunkUserMarked(bagID, slotID)
    ZL:debug("+_ Junker:isJunkUserMarked")

    if self:isItemUserMarked(bagID, slotID) then
        return true, 'Previously Identified'
    end
end

function Junker:notify(bagID, slotID, junkType, triggerType)
    ZL:debug("+_ Junker -> notify")

    local destroyNotification = Destroyer:junkNotificationTag(bagID, slotID)

    if destroyNotification == '' then
        if ZJH.settings.markAsJunkSound ~= SOUNDS.NONE then
            PlaySound(ZJH.settings.markAsJunkSound)
        end
    else
        if ZJH.settings.destroySound ~= SOUNDS.NONE then
            PlaySound(ZJH.settings.destroySound)
        end
    end

    if ZJH.settings.markAsJunkNotify then
        ZL:debug("+_ Notifying chat that we are marking item as junk.")

        local itemLink = ZL:formatItemLink(
            GetItemLink(bagID, slotID, LINK_STYLE_DEFAULT)
        )

        if triggerType == ZJH.Vars.MARK_AS_JUNK_REASON_SCAN_BACKPACK then
            ZL:sendMessageToChat(string.format(
                "%sBag Scan Marked %s Item %s%s As Junk %s",
                ZJH.Vars.defaultColor,
                junkType,
                itemLink,
                ZJH.Vars.defaultColor,
                destroyNotification
            ))
        else
            -- ASSUMES ANYTHING ELSE IS ZJH.Vars.MARK_AS_JUNK_REASON_NEW_ITEM FOR NOW
            ZL:sendMessageToChat(string.format(
                "%sMarking %s Item %s%s As Junk %s",
                ZJH.Vars.defaultColor,
                junkType,
                itemLink,
                ZJH.Vars.defaultColor,
                destroyNotification
            ))
        end
    end
end

function Junker:markIfJunk(bagID, slotID, triggerType)
    ZL:debug("Junker -> markIfJunk")

    local isJunk, junkType = false, nil
    local itemKey  = ZL:getUniqueItemKey(bagID, slotID)

    local continue = true
    if continue then
        isJunk, junkType = self:isJunkAuto(bagID, slotID)
        if isJunk then
            continue                 = false
            self.autoMarked[itemKey] = true
        end
    end

    if continue then
        isJunk, junkType = self:isJunkUserMarked(bagID, slotID)
        if isJunk then continue = false end
    end

    if isJunk then
        if not IsItemJunk(bagID, slotID) then
            Junker:notify(bagID, slotID, junkType, triggerType)
        end

        SetItemIsJunk(bagID, slotID, true)
        Destroyer:destroyIfAppropriate(bagID, slotID)
    end
end

function Junker:scanBackpackForJunk()
    ZL:debug("Junker -> scanBackpackForJunk")

    if not ZJH.settings.enabled             then return end
    if not ZJH.settings.scanBackpackForJunk then return end

    local bagID = BAG_BACKPACK

    for slotID = 0, GetBagSize(bagID) do
        Junker:markIfJunk(bagID, slotID, ZJH.Vars.MARK_AS_JUNK_REASON_SCAN_BACKPACK)
    end

    BagCache:refresh()
end

function Junker:scanSlotForJunk(bagID, slotID, isNew)
    ZL:debug("Junker -> scanSlotForJunk")

    if not ZJH.settings.enabled then return end

    if bagID == BAG_BACKPACK then
        BagCache:checkJunkStatusChange(bagID, slotID)

        if isNew then
            Junker:markIfJunk(bagID, slotID, ZJH.Vars.MARK_AS_JUNK_REASON_NEW_ITEM)
        end
    end

    BagCache:refresh()
end
