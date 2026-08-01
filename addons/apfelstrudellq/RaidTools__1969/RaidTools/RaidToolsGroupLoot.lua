RaidToolsModules_GroupLootAnnounce = {}

local relevant_loop_types = {
	ITEMTYPE_ARMOR,
	ITEMTYPE_WEAPON,
	SPECIALIZED_ITEMTYPE_ARMOR,
	SPECIALIZED_ITEMTYPE_WEAPON
}
local traits = {
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 'Divines',
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 'Impenetrable',
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 'Infused',
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = 'Intricate',
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 'Nirnhoned',
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = 'Ornate',
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 'Prosperous',
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 'Reinforced',
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 'Sturdy',
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 'Training',
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 'Well-fitted',
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 'Arcane',
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 'Healthy',
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = 'Ornate',
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 'Robust',
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 'Charged',
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 'Decisive',
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 'Defending',
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 'Infused',
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = 'Intricate',
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 'Nirnhoned',
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = 'Ornate',
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 'Powered',
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 'Precise',
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 'Sharpened',
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 'Training',
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 'Bloodthirsty',
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 'Harmony',
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 'Infused',
	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = 'Intricate',
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 'Protective',
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 'Swift',
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 'Triune',
}
local armour_types = {
	[ARMORTYPE_HEAVY] = 'Heavy',
	[ARMORTYPE_LIGHT] = 'Light',
	[ARMORTYPE_MEDIUM] = 'Medium',
}
function RaidToolsModules_GroupLootAnnounce.OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isSelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
	if not RaidTools.storage.modules.group_loot then return end
	if lootType ~= LOOT_TYPE_ITEM and lootType ~= LOOT_TYPE_CHAOTIC_CREATIA then return end
	local icon = GetItemLinkInfo(itemName)
	local type, stype = GetItemLinkItemType(itemName)
	if not has_value(relevant_loop_types, type) and not has_value(relevant_loop_types, stype) then return end
	local name = FixName(receivedBy)
	local hasSet, setName, numBonuses, _, _, setId = GetItemLinkSetInfo(itemName)
	if hasSet or GetItemLinkQuality(itemName) == 5 then
		local message = ''
		if isSelf then
			message = 'You looted '
		else
			message = ZO_LinkHandler_CreatePlayerLink(FixName(receivedBy)).. ' looted '
		end

		message = message .. '|t22:22:'.. icon ..'|t ' .. itemName

		if GetItemLinkEquipType(itemName) ~= EQUIP_TYPE_INVALID then
			local traitType, triatDesc = GetItemLinkTraitInfo(itemName)
			local armour_type = GetItemLinkArmorType(itemName)
			message = message .. ' ('
			if traits[traitType] then
				message = message .. traits[traitType]
			end
			if armour_types[armour_type] then
				message = message .. ', ' .. armour_types[armour_type]
			end
			message = message ..')'
		end
		RaidTools.BaseMessage(message)
	end
end