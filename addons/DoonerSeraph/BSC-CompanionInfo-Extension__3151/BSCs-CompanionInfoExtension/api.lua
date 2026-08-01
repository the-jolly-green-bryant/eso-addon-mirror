-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////// --- API -- ///////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

BSCCompanionInfoExtension = BSCCompanionInfoExtension or {}
local BSCCOIN_EX = BSCCompanionInfoExtension

-- Private Functions used by the API
local function GetCountOfArmorPiecesWornByWeight()
	local slots = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET }
	local heavyArmor = 0
	local mediumArmor = 0
	local lightArmor = 0
	for i, v in ipairs(slots) do
		local armorType = GetItemArmorType(BAG_COMPANION_WORN, v)
		if (armorType == ARMORTYPE_HEAVY) then
			heavyArmor = heavyArmor + 1
		end
		if (armorType == ARMORTYPE_MEDIUM) then
			mediumArmor = mediumArmor + 1
		end
		if (armorType == ARMORTYPE_LIGHT) then
			lightArmor = lightArmor + 1
		end
	end

	return heavyArmor, mediumArmor, lightArmor
end

-- Public Addon Function - Can be easily overridden, and used from anywhere

function BSCCOIN_EX:GetSkillLineIdFromWeaponType()
	local equippedWeaponTypeMainHand = GetItemWeaponType(BAG_COMPANION_WORN, EQUIP_SLOT_MAIN_HAND)
	local equippedWeaponTypeOffHand = GetItemWeaponType(BAG_COMPANION_WORN, EQUIP_SLOT_OFF_HAND)
	if (equippedWeaponTypeMainHand == WEAPONTYPE_AXE or equippedWeaponTypeMainHand == WEAPONTYPE_DAGGER or equippedWeaponTypeMainHand == WEAPONTYPE_HAMMER or equippedWeaponTypeMainHand == WEAPONTYPE_SWORD) then
		if (equippedWeaponTypeOffHand == WEAPONTYPE_SHIELD) then
			return 181 -- One Hand and Shield
		end
		if (equippedWeaponTypeOffHand == WEAPONTYPE_AXE or equippedWeaponTypeOffHand == WEAPONTYPE_DAGGER or equippedWeaponTypeOffHand == WEAPONTYPE_HAMMER or equippedWeaponTypeOffHand == WEAPONTYPE_SWORD) then
			return 182 -- Dual Wield
		end

		return 0
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_FIRE_STAFF or equippedWeaponTypeMainHand == WEAPONTYPE_FROST_STAFF or equippedWeaponTypeMainHand == WEAPONTYPE_LIGHTNING_STAFF) then
		return 184 -- Destruction Staff
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_HEALING_STAFF) then
		return 185 -- Restoration Staff
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_BOW) then
		return 183 -- Bow
	end

	if (equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_AXE or equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_SWORD or equippedWeaponTypeMainHand == WEAPONTYPE_TWO_HANDED_HAMMER) then
		return 180 -- Two-Handed
	end
end

function BSCCOIN_EX:GetSkillLineFromCompanionArmorPieces()
	local heavyArmor, mediumArmor, lightArmor = GetCountOfArmorPiecesWornByWeight()

	if (heavyArmor > 5) then return 188 end
	if (mediumArmor > 5) then return 187 end
	if (lightArmor > 5) then return 186 end

	return 0
end