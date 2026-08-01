local RA = ResearchAssistant

RA.currentlyLoggedInCharId = RA.currentlyLoggedInCharId or GetCurrentCharacterId()
local currentlyLoggedInCharId = RA.currentlyLoggedInCharId
local unknownStr = "n/a"
RA.unknownStr = unknownStr

--Addon variables
RA.name		= "ResearchAssistant"
RA.version 	= "0.9.6.3"
RA.author   = "ingeniousclown,katkat42,Randactyl,Baertram"
RA.website	= "https://www.esoui.com/downloads/info111-ResearchAssistant.html"
RA.donation = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
RA.feedback = "https://www.esoui.com/portal.php?id=136&a=bugreport"

local libErrorText = "[ResearchAssistant]Needed library \'%s\' was not loaded. This addon won't work without this library!"

local tos = tostring
local strfor = string.format

local DECONSTRUCTION	= ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
local UNIVERSAL_DECON   = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack

local ORNATE_TEXTURE = [[/esoui/art/tradinghouse/tradinghouse_sell_tabicon_disabled.dds]]
local ornateTextureSizeMax = 28
local INTRICATE_TEXTURE = [[/esoui/art/progression/progression_indexicon_guilds_up.dds]]
local intricateTextureSizeMax = 30
local PROTECTED_TEXTURE = [[/esoui/art/campaign/campaignbrowser_fullpop.dds]]
local protectedTextureSizeMax = 40
local traitTypes = {
	[ITEM_TRAIT_TYPE_NONE] = GetString(SI_ITEMTRAITTYPE0), --None
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = GetString(SI_ITEMTRAITTYPE1), --Powered
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = GetString(SI_ITEMTRAITTYPE2), --Charged
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = GetString(SI_ITEMTRAITTYPE3), --Precise
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = GetString(SI_ITEMTRAITTYPE4), --Infused
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = GetString(SI_ITEMTRAITTYPE5), --Defending
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = GetString(SI_ITEMTRAITTYPE6), --Training
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = GetString(SI_ITEMTRAITTYPE7), --Sharpened
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = GetString(SI_ITEMTRAITTYPE8), --Decisive
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = GetString(SI_ITEMTRAITTYPE9), --Intricate weapon
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = GetString(SI_ITEMTRAITTYPE10), --Ornate weapon

	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = GetString(SI_ITEMTRAITTYPE11), --Sturdy
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = GetString(SI_ITEMTRAITTYPE12), --Impenetrable
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = GetString(SI_ITEMTRAITTYPE13), --Reinforced
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = GetString(SI_ITEMTRAITTYPE14), --Well-fitted
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = GetString(SI_ITEMTRAITTYPE15), --Training
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = GetString(SI_ITEMTRAITTYPE16), --Infused
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = GetString(SI_ITEMTRAITTYPE17), --Prosperous
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = GetString(SI_ITEMTRAITTYPE18), --Divines
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = GetString(SI_ITEMTRAITTYPE19), --Ornate armor
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = GetString(SI_ITEMTRAITTYPE20), --Intricate armor

	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = GetString(SI_ITEMTRAITTYPE21), --Healthy
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = GetString(SI_ITEMTRAITTYPE22), --Arcane
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = GetString(SI_ITEMTRAITTYPE23), --Robust
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = GetString(SI_ITEMTRAITTYPE24), --Ornate

	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = GetString(SI_ITEMTRAITTYPE25), --Nirnhoned armor
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = GetString(SI_ITEMTRAITTYPE26), --Nirnhoned weapon

	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = GetString(SI_ITEMTRAITTYPE27), --Intricate jewelry
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = GetString(SI_ITEMTRAITTYPE28), --Swift
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = GetString(SI_ITEMTRAITTYPE29), --Harmony
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = GetString(SI_ITEMTRAITTYPE30), --Triune
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = GetString(SI_ITEMTRAITTYPE31), --Bloodthirsty
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = GetString(SI_ITEMTRAITTYPE32), --Protective
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = GetString(SI_ITEMTRAITTYPE33), --Infused
}
RA.traitTypes = traitTypes
local traitTextures = {
	--belebend: esoui/art/icons/crafting_jewelry_base_garnet_r3.dds
	--Verstärkt: esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds
	--Armor
	[ITEM_TRAIT_TYPE_NONE]					= "",
	[ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
	[ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= "esoui/art/icons/crafting_accessory_sp_names_001.dds",
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= "esoui/art/icons/crafting_jewelry_base_diamond_r3.dds",
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= "esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds",
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= "EsoUI/art/icons/crafting_potent_nirncrux_dust.dds",
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= "esoui/art/icons/crafting_jewelry_base_garnet_r3.dds",
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= "esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds",
	[ITEM_TRAIT_TYPE_ARMOR_STURDY]			= "esoui/art/icons/crafting_runecrafter_plug_component_002.dds",
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= "esoui/art/icons/crafting_jewelry_base_emerald_r2.dds",
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= "esoui/art/icons/crafting_accessory_sp_names_002.dds",
	--Jewelry
	[ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= "esoui/art/icons/jewelrycrafting_trait_refined_cobalt.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= "esoui/art/icons/jewelrycrafting_trait_refined_antimony.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= "esoui/art/icons/jewelrycrafting_trait_refined_zinc.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]	= "esoui/art/icons/crafting_enchantment_baxe_bloodstone_r1.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY]		= "esoui/art/icons/crafting_metals_tin.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED]		= "esoui/art/icons/crafting_enchantment_base_jade_r1.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]	= "esoui/art/icons/crafting_runecrafter_armor_component_006.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT]			= "esoui/art/icons/crafting_outfitter_plug_component_002.dds",
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]		= "esoui/art/icons/jewelrycrafting_trait_refined_dawnprism.dds",
	--Weapons
	[ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= "esoui/art/inventory/inventory_trait_ornate_icon.dds",
	[ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= "esoui/art/inventory/inventory_trait_intricate_icon.dds",
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= "esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds",
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= "esoui/art/icons/crafting_smith_potion__sp_names_003.dds",
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= "esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds",
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= "esoui/art/icons/crafting_enchantment_base_jade_r3.dds",
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= "esoui/art/icons/crafting_potent_nirncrux_dust.dds",
	[ITEM_TRAIT_TYPE_WEAPON_POWERED]		= "esoui/art/icons/crafting_runecrafter_potion_008.dds",
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= "esoui/art/icons/crafting_jewelry_base_ruby_r3.dds",
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= "esoui/art/icons/crafting_enchantment_base_fire_opal_r3.dds",
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= "esoui/art/icons/crafting_runecrafter_armor_component_004.dds",
}
RA.traitTextures = traitTextures

local RASettings = nil
local RAScanner = nil

local RAlang = RA.lang
local STRINGS = RA_Strings
local TOOLTIPS

local armorTypeToName
local equipmentTypeToName
local weaponTypeToName

--Global Constants
RA_CON_BEST_PREFERENCE_VALUE = 999999999
RA_CON_MAX_PREFERENCE_VALUE  = 999999999999999999

--LibResearch reasons
local libResearch_Reason_ALREADY_KNOWN 	= LIBRESEARCH_REASON_ALREADY_KNOWN 	or "AlreadyKnown"
local libResearch_Reason_WRONG_ITEMTYPE = LIBRESEARCH_REASON_WRONG_ITEMTYPE or "WrongItemType"
local libResearch_Reason_ORNATE 		= LIBRESEARCH_REASON_ORNATE 		or "Ornate"
local libResearch_Reason_INTRICATE 		= LIBRESEARCH_REASON_INTRICATE 		or "Intricate"
local libResearch_Reason_TRAITLESS  	= LIBRESEARCH_REASON_TRAITLESS 		or "Traitless"

local LIBRESEARCH_REASON_WRONG_ITEMTYPElower= "baditemtype"
local LIBRESEARCH_REASON_ORNATElower 		= libResearch_Reason_ORNATE:lower()
local LIBRESEARCH_REASON_INTRICATElower 	= libResearch_Reason_INTRICATE:lower()
local LIBRESEARCH_REASON_TRAITLESSlower 	= libResearch_Reason_TRAITLESS:lower()
--Tracking status
local TRACKING_STATE_KNOWN					= "known"
local TRACKING_STATE_RESEARCHABLE			= "researchable"
local TRACKING_STATE_DUPLICATE				= "duplicate"
local TRACKING_STATE_TRAITLESS				= LIBRESEARCH_REASON_TRAITLESSlower
local TRACKING_STATE_UNTRACKED				= "untracked"
local TRACKING_STATE_PROTECTED				= "protected"
local TRACKING_STATE_CHARACTER_NOT_SCANNED_YET = "CharacterNotScannedYet"
RA.trackingStates = {
	[TRACKING_STATE_KNOWN] 			= TRACKING_STATE_KNOWN,
	[TRACKING_STATE_RESEARCHABLE] 	= TRACKING_STATE_RESEARCHABLE,
	[TRACKING_STATE_DUPLICATE] 		= TRACKING_STATE_DUPLICATE,
	[TRACKING_STATE_TRAITLESS]		= TRACKING_STATE_TRAITLESS,
	[TRACKING_STATE_UNTRACKED] 		= TRACKING_STATE_UNTRACKED,
	[TRACKING_STATE_CHARACTER_NOT_SCANNED_YET] = TRACKING_STATE_CHARACTER_NOT_SCANNED_YET,
}

--If not created yet: Create a ResearchAssistant Settings
--Return the RAscanner
function RA.GetOrCreateRASettings()
	RA.settings = RA.settings or ResearchAssistantSettings:New()
	RASettings = RA.settings
	return RASettings
end

--If not created yet: Create an ResearchAssistant Scanner
--Return the RAscanner
function RA.GetOrCreateRAScanner()
	if RA.settings == nil then
		RA.settings = RA.GetOrCreateRASettings()
	end
	if not RA.settings then return end
	RA.scanner = RA.scanner or ResearchAssistantScanner:New(RA.settings)
	RAScanner = RA.scanner
	return RAScanner
end

local function AddTooltips(control, textFunc)
	control:SetHandler("OnMouseEnter", function(self)
		local ttText = textFunc()
		ZO_Tooltips_ShowTextTooltip(self, TOP, ttText)
	end)
	control:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
	end)
end

local function RemoveTooltips(control)
	control:SetHandler("OnMouseEnter", nil)
	control:SetHandler("OnMouseExit", nil)
end

local function HandleTooltips(control, textFunc)
	if RASettings:ShowTooltips() and textFunc ~= nil then
		control:SetMouseEnabled(true)
		AddTooltips(control, textFunc)
	else
		control:SetMouseEnabled(false)
		RemoveTooltips(control)
	end
end

local function SetToOrnate(indicatorControl)
	local textureSize = RASettings:GetTextureSize() + 12
	if textureSize > ornateTextureSizeMax then textureSize = ornateTextureSizeMax end

	indicatorControl:SetTexture(ORNATE_TEXTURE)
	indicatorControl:SetColor(unpack(RASettings:GetOrnateColor()))
	indicatorControl:SetDimensions(textureSize, textureSize)
	indicatorControl:SetHidden(false)

	HandleTooltips(indicatorControl, function() return TOOLTIPS.ornate end)
end

local function SetToIntricate(indicatorControl)
	local textureSize = RASettings:GetTextureSize() + 10
	if textureSize > intricateTextureSizeMax then textureSize = intricateTextureSizeMax end

	indicatorControl:SetTexture(INTRICATE_TEXTURE)
	indicatorControl:SetColor(unpack(RASettings:GetIntricateColor()))
	indicatorControl:SetDimensions(textureSize, textureSize)
	indicatorControl:SetHidden(false)

	HandleTooltips(indicatorControl, function() return TOOLTIPS.intricate end)
end

local function SetToProtected(indicatorControl)
	local textureSize = RASettings:GetTextureSize() + 10
	if textureSize > protectedTextureSizeMax then textureSize = protectedTextureSizeMax end

	indicatorControl:SetTexture(PROTECTED_TEXTURE)
	indicatorControl:SetColor(1, 0, 0, 1)
	indicatorControl:SetDimensions(textureSize, textureSize)
	indicatorControl:SetHidden(true)
end

local function SetToNormal(indicatorControl)
	local textureSize = RASettings:GetTextureSize()

	indicatorControl:SetTexture(RASettings:GetTexturePath())
	indicatorControl:SetDimensions(textureSize, textureSize)
	indicatorControl:SetHidden(true)
end

local function CreateIndicatorControl(parent)
	local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Research", parent, CT_TEXTURE)

	control:ClearAnchors()
	control:SetAnchor(CENTER, parent, CENTER, RASettings:GetTextureOffset())
	control:SetDrawTier(DT_HIGH)

	SetToNormal(control)
	return control
end

local function DisplayIndicator(indicatorControl, indicatorType)
	local textureOffset = 0
	indicatorType = indicatorType or "normal"

	if indicatorType == LIBRESEARCH_REASON_INTRICATElower then
		textureOffset = RASettings:GetTextureOffset() - 6
	elseif indicatorType == LIBRESEARCH_REASON_ORNATElower then
		textureOffset = RASettings:GetTextureOffset() - 6
	else
		textureOffset = RASettings:GetTextureOffset()
	end

	local control = indicatorControl:GetParent()
	indicatorControl:ClearAnchors()

	if control.isGrid or control:GetWidth() - control:GetHeight() < 5 then
		-- we're using Grid View
		indicatorControl:ClearAnchors()
		indicatorControl:SetAnchor(TOPLEFT, control, TOPLEFT, 3)
	else
		indicatorControl:ClearAnchors()
		indicatorControl:SetAnchor(LEFT, control:GetNamedChild("Name"), RIGHT, textureOffset)
	end

	indicatorControl:SetHidden(false)
end

local function buildItemTraitIconText(text, traitId)
	if not text then return "" end
	local itemTraitIconText = text
	if traitId and traitId ~= ITEM_TRAIT_TYPE_NONE then
		local traitTexture = traitTextures[traitId]
		if not traitTexture then return "" end
		--itemTraitIconText = zo_iconTextFormat(traitTextures[traitId], 20, 20, itemTraitIconText)
		itemTraitIconText = zo_strformat(text .. " <<1>>", zo_iconFormat(traitTexture, 20, 20))
	end
	return itemTraitIconText
end

--Returns true if the given item at bag and slot can be researched with the the character set in the
--ResearchAssistant settings for the crafting type. Otherwise it returns false!
function RA.IsItemResearchableWithSettingsCharacter(bagId, slotIndex)
	--ResearchAssistant Scanner and Settings are already provided? Else create them
	RAScanner = RAScanner or RA.GetOrCreateRAScanner()
	RASettings = RASettings or RA.GetOrCreateRASettings()
	if not RAScanner or not RASettings then return end

	--Return value, preset with "Not researchable with char" = false
	local isResearchableWithSettingsChar = false
	local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)

	--returns int traitKey, bool isResearchable, string reason
	local traitKey, isResearchable, reason = RAScanner:CheckIsItemResearchable(itemLink)

	if not isResearchable then
		-- if the item isn't armor or a weapon, hide and go away
		if reason == libResearch_Reason_WRONG_ITEMTYPE then
			return isResearchableWithSettingsChar
		end

		-- if the item has no trait
		if reason == libResearch_Reason_TRAITLESS then
			return isResearchableWithSettingsChar
		end

		-- if the item is ornate
		if reason == libResearch_Reason_ORNATE then
			return isResearchableWithSettingsChar
		end

		-- if the item is intricate
		if reason == libResearch_Reason_INTRICATE then
			return isResearchableWithSettingsChar
		end
	end

	--now we get into the stuff that requires the craft skill and item type
	local craftingSkill = RAScanner:GetItemCraftingSkill(itemLink)
	local itemType = RAScanner:GetResearchLineIndex(itemLink)

	--if we aren't tracking anybody for that skill, hide and go away
	if RASettings:IsMultiCharSkillOff(craftingSkill, itemType) then
		return isResearchableWithSettingsChar
	end

	--preference value for the "best" item candidate for the trait in question
	local bestTraitPreferenceScore = RASettings:GetPreferenceValueForTrait(traitKey)
	if bestTraitPreferenceScore == nil then
		-- if the item is traitless, show "researched" color. if we've never seen this trait before, show "best" color.
		if reason == libResearch_Reason_TRAITLESS then
			bestTraitPreferenceScore = true
		else
			bestTraitPreferenceScore = RA_CON_BEST_PREFERENCE_VALUE
		end
	end

	--Known already
	if bestTraitPreferenceScore == true then
		return isResearchableWithSettingsChar
	end

	--preference value for the current item
	local thisItemScore = RAScanner:CreateItemPreferenceValue(itemLink, bagId, slotIndex)
	local stackSize = GetSlotStackSize(bagId, slotIndex) or 0

	--d(GetItemName(bagId, slotIndex)..": "..tos(bestTraitPreferenceScore).." best "..tos(thisItemScore) .. " trait "..tos(traitKey))

	--if we don't know it yet
	if bestTraitPreferenceScore ~= true then
		isResearchableWithSettingsChar = true
		if bestTraitPreferenceScore == RASettings.CONST_CHARACTER_NOT_SCANNED_YET then
			--Character to research this crafttype with was not logged in yet
			return false
		else
			if (thisItemScore > bestTraitPreferenceScore or stackSize > 1) then
				--Duplicate
				return isResearchableWithSettingsChar
			else
				--Researchable!
				return isResearchableWithSettingsChar
			end
		end
	end
	--in any other case
	return isResearchableWithSettingsChar
end


--Returns true if the given item at bag and slot can be researched with the the character set in the
--ResearchAssistant settings for the crafting type.
--If the item is a researchable the return value will be true
--If the item is a duplicate the return value will be "duplicate".
--Otherwise it returns false!
function RA.IsItemResearchableOrDuplicateWithSettingsCharacter(bagId, slotIndex)
	--ResearchAssistant Scanner and Settings are already provided? Else create them
	RAScanner = RAScanner or RA.GetOrCreateRAScanner()
	RASettings = RASettings or RA.GetOrCreateRASettings()
	if not RAScanner or not RASettings then return end

	--Return value, preset with "Not researchable with char" = false
	local isNoDuplicateResearchableWithSettingsChar = false
	local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
	if not itemLink or itemLink == "" then return end
	--returns int traitKey, bool isResearchable, string reason
	local traitKey, isResearchable, reason = RAScanner:CheckIsItemResearchable(itemLink)

	if not isResearchable then
		-- if the item isn't armor or a weapon, hide and go away
		if reason == libResearch_Reason_WRONG_ITEMTYPE then
			return isNoDuplicateResearchableWithSettingsChar
		end

		-- if the item has no trait
		if reason == libResearch_Reason_TRAITLESS then
			return isNoDuplicateResearchableWithSettingsChar
		end

		-- if the item is ornate
		if reason == libResearch_Reason_ORNATE then
			return isNoDuplicateResearchableWithSettingsChar
		end

		-- if the item is intricate
		if reason == libResearch_Reason_INTRICATE then
			return isNoDuplicateResearchableWithSettingsChar
		end
	end

	--now we get into the stuff that requires the craft skill and item type
	local craftingSkill = RAScanner:GetItemCraftingSkill(itemLink)
	local itemType = RAScanner:GetResearchLineIndex(itemLink)

	--if we aren't tracking anybody for that skill, hide and go away
	if RASettings:IsMultiCharSkillOff(craftingSkill, itemType) then
		return isNoDuplicateResearchableWithSettingsChar
	end

	--preference value for the "best" item candidate for the trait in question
	local bestTraitPreferenceScore = RASettings:GetPreferenceValueForTrait(traitKey)
	if bestTraitPreferenceScore == nil then
		-- if the item is traitless, show "researched" color. if we've never seen this trait before, show "best" color.
		if reason == libResearch_Reason_TRAITLESS then
			bestTraitPreferenceScore = true
		else
			bestTraitPreferenceScore = RA_CON_BEST_PREFERENCE_VALUE
		end
	end

	--Known already
	if bestTraitPreferenceScore == true then
		return isNoDuplicateResearchableWithSettingsChar
	end

	--preference value for the current item
	local thisItemScore = RAScanner:CreateItemPreferenceValue(itemLink, bagId, slotIndex)
	local stackSize = GetSlotStackSize(bagId, slotIndex) or 0

	--d(GetItemName(bagId, slotIndex)..": "..tos(bestTraitPreferenceScore).." best "..tos(thisItemScore) .. " trait "..tos(traitKey))

	--if we don't know it yet
	if bestTraitPreferenceScore ~= true then
		isNoDuplicateResearchableWithSettingsChar = true
		if bestTraitPreferenceScore == RASettings.CONST_CHARACTER_NOT_SCANNED_YET then
			--Character to research this crafttype with was not logged in yet
			return false
		else
			if (thisItemScore > bestTraitPreferenceScore or stackSize > 1) then
				--Duplicate
				return TRACKING_STATE_DUPLICATE
			else
				--Researchable!
				return isNoDuplicateResearchableWithSettingsChar
			end
		end
	end
	--in any other case
	return isNoDuplicateResearchableWithSettingsChar
end

local function getWhoKnowsAndTraitTextAndTexture(p_itemLink, p_traitKey)
	local r_traitName
	local r_whoKnows = RASettings:GetCharsWhoKnowTrait(p_traitKey)
--d(">getWhoKnowsAndTraitTextAndTexture: " .. p_itemLink .. ", whoKnows: " ..tos(r_whoKnows))
	local traitId = GetItemLinkTraitType(p_itemLink)
	if traitId then
		r_traitName = traitTypes[traitId]
		r_traitName = buildItemTraitIconText(r_traitName, traitId)
	end
	return r_whoKnows, r_traitName
end

local function getTooltipText(showTooltips, bagId, slotIndex, itemLink, stackSize, bestTraitPreferenceScore, whoKnows, traitName, researchCharOfCraftingTypeNameDecorated, protectedStr, craftingNotTracked)
	researchCharOfCraftingTypeNameDecorated = researchCharOfCraftingTypeNameDecorated or unknownStr
	local tooltipText = ""
	if not showTooltips then return tooltipText end

	local armorType
	local weaponType
	local equipType
	local typeText = ""
	local showTooltipsType = RASettings:ShowTooltipsType()
--d(">showTooltipsType: " ..tos(showTooltipsType))
	if showTooltipsType == true then
		weaponType = GetItemLinkWeaponType(itemLink)
--d(">weaponType: " ..tos(weaponType))
		if weaponType == WEAPONTYPE_NONE then
			equipType = GetItemLinkEquipType(itemLink)
			typeText = equipmentTypeToName[equipType]
		else
			typeText = weaponTypeToName[weaponType]
		end
--d(">typeText: " ..tos(typeText))
		if typeText == nil then typeText = "" end
	end
	local armorWeightText = ""
	local showTooltipsArmorWeight = RASettings:ShowTooltipsArmorWeight()
--d(">showTooltipsArmorWeight: " ..tos(showTooltipsArmorWeight))
	if showTooltipsArmorWeight == true then
		if weaponType == nil or weaponType == WEAPONTYPE_NONE then
			armorType = GetItemLinkArmorType(itemLink)
--d(">armorType: " ..tos(armorType))
			if armorType ~= ARMORTYPE_NONE then
				armorWeightText = armorTypeToName[armorType]
			end
--d(">armorWeightText: " ..tos(armorWeightText))
			if armorWeightText == nil then armorWeightText = "" end
		end
	end


--d(">" .. itemLink .. "-equipType: " ..tos(equipType) ..", weaponType: " ..tos(weaponType) .. ", armorType: " ..tos(armorType) .. ", typeText: " ..tos(typeText) .. ", armorWeightText: " ..tos(armorWeightText))

	--rafting of the current item is not tracked?
	if craftingNotTracked == true then
		if showTooltips == true and whoKnows ~= "" then
			tooltipText = strfor(TOOLTIPS.alreadyResearched, TOOLTIPS.notTrackedCharName, (traitName ~= nil and strfor(TOOLTIPS.knownBy, traitName)) or "") .. whoKnows .. protectedStr
		else
			tooltipText = strfor(TOOLTIPS.alreadyResearched, TOOLTIPS.notTrackedCharName, ((traitName ~= nil and " \'" .. traitName .. "\'") or "")) .. protectedStr
		end
	else
		--We do not know the item?
		if bestTraitPreferenceScore ~= true then
			--Not scanned data at the current character
			if bestTraitPreferenceScore == RASettings.CONST_CHARACTER_NOT_SCANNED_YET then
				if showTooltips == true and whoKnows ~= "" then
					tooltipText = strfor(TOOLTIPS.notScannedWithNeededCharYet, researchCharOfCraftingTypeNameDecorated) .. "\n\n" .. strfor(TOOLTIPS.alreadyResearched, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and strfor(TOOLTIPS.knownBy, traitName)) or "") .. whoKnows .. protectedStr
				else
					tooltipText = strfor(TOOLTIPS.notScannedWithNeededCharYet, researchCharOfCraftingTypeNameDecorated) .. protectedStr
				end
			else
				--preference value for the current item
				local thisItemScore = RAScanner:CreateItemPreferenceValue(itemLink, bagId, slotIndex)
				--Duplicate item
				if (thisItemScore > bestTraitPreferenceScore or stackSize > 1) then
					if showTooltips == true and whoKnows ~= "" then
						tooltipText = strfor(TOOLTIPS.duplicate, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and strfor(TOOLTIPS.knownBy, traitName)) or "") .. whoKnows .. protectedStr
					else
						tooltipText = strfor(TOOLTIPS.duplicate, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and " \'" .. traitName .. "\'") or "") .. protectedStr
					end
				else
					--Unknown item
					if showTooltips == true and whoKnows ~= "" then
						tooltipText = strfor(TOOLTIPS.canResearch, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and strfor(TOOLTIPS.knownBy, traitName)) or "") .. whoKnows .. protectedStr
					else
						tooltipText = strfor(TOOLTIPS.canResearch, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and " \'" .. traitName .. "\'") or "") .. protectedStr
					end
				end
			end
		else
			--Known item
			if showTooltips == true and whoKnows ~= "" then
				tooltipText = strfor(TOOLTIPS.alreadyResearched, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and strfor(TOOLTIPS.knownBy, traitName)) or "") .. whoKnows .. protectedStr
			else
				tooltipText = strfor(TOOLTIPS.alreadyResearched, researchCharOfCraftingTypeNameDecorated, (traitName ~= nil and " \'" .. traitName .. "\'") or "") .. protectedStr
			end
		end
	end
	local preTooltipText = ""
	if typeText ~= "" then
		preTooltipText = typeText
	end
--d(">preTooltipText: " ..tos(preTooltipText))
	if armorWeightText ~= "" then
		if preTooltipText ~= "" then
			preTooltipText = preTooltipText .. " - " .. armorWeightText
		else
			preTooltipText = armorWeightText
		end
	end
--d(">preTooltipText2: " ..tos(preTooltipText))
	if preTooltipText ~= "" then
		preTooltipText = preTooltipText .. "\n"
	end
--d(">tooltipText: " ..preTooltipText .. tooltipText)
	return preTooltipText .. tooltipText
end


--[[----------------------------------------------------------------------------
	puts an additional point of data into control.dataEntry.data called
	researchAssistant
	this can be called from inventory, bank, guild bank, deconstruction window,
	or trading house which contains one of the following strings:
		"baditemtype" (not weapon or armor)
		"traitless" "ornate" "intricate" "untracked" (untracked)
		"known" "researchable" "duplicate" (tracked)
--]]----------------------------------------------------------------------------
local function AddResearchIndicatorToSlot(control, linkFunction)
	local data = control.dataEntry.data
	local bagId = data.bagId
	local slotIndex = data.slotIndex
	local itemLink = bagId and linkFunction(bagId, slotIndex) or linkFunction(slotIndex)

--d("AddResearchIndicatorToSlot: " .. itemLink)

	--get indicator control, or create one if it doesnt exist
	local indicatorControl = control:GetNamedChild("Research")
	if not indicatorControl then
		indicatorControl = CreateIndicatorControl(control)
	end

	--Should the vanilla UI research itemSellInformation texture be hidden?
	if RASettings:GetHideVanillaUIResearchableTexture() == true then
		if data.sellInformation == ITEM_SELL_INFORMATION_CAN_BE_RESEARCHED then
			local traitInfoControl = GetControl(control, "TraitInfo")
			if traitInfoControl ~= nil then
				traitInfoControl:ClearIcons()
		--else
		--	TraitInfoTexture:SetHidden(false)
			end
		end
	end

	--returns int traitKey, bool isResearchable, string reason
	local traitKey, isResearchable, reason = RAScanner:CheckIsItemResearchable(itemLink)
	--now we get into the stuff that requires the craft skill and item type
	local craftingSkill = RAScanner:GetItemCraftingSkill(itemLink)
	local itemType = RAScanner:GetResearchLineIndex(itemLink)

	local hideNow = false
	local returnNow = false

	if not isResearchable then
		-- if the item isn't armor or a weapon, hide and go away
		if reason == libResearch_Reason_WRONG_ITEMTYPE then
			data.researchAssistant = LIBRESEARCH_REASON_WRONG_ITEMTYPElower
			hideNow = true
			returnNow = true

		-- if the item has no trait and we don't want to display icon for traitless items, hide and go away
		elseif reason == libResearch_Reason_TRAITLESS then
			data.researchAssistant = LIBRESEARCH_REASON_TRAITLESSlower
			if not RASettings:ShowTraitless() then
				hideNow = true
				returnNow = true
			end
		-- if the item is ornate, make icon ornate if we show ornate and hide/go away if we don't show it
		elseif reason == libResearch_Reason_ORNATE then
			data.researchAssistant = LIBRESEARCH_REASON_ORNATElower
			if not RASettings:ShowUntrackedOrnate() or (craftingSkill == -1 or (RASettings:IsMultiCharSkillOff(craftingSkill, itemType) == true)) then
				hideNow = true
			else
				SetToOrnate(indicatorControl)
				DisplayIndicator(indicatorControl, LIBRESEARCH_REASON_ORNATElower)
			end
			returnNow = true
		-- if the item is intricate, make icon intricate if we show that and hide/go away if we don't
		elseif reason == libResearch_Reason_INTRICATE then
			data.researchAssistant = LIBRESEARCH_REASON_INTRICATElower
			if not RASettings:ShowUntrackedIntricate() or (craftingSkill == -1 or (RASettings:IsMultiCharSkillOff(craftingSkill, itemType) == true))  then
				hideNow = true
			else
				SetToIntricate(indicatorControl)
				DisplayIndicator(indicatorControl, LIBRESEARCH_REASON_INTRICATElower)
			end
			returnNow = true
		end
	end

	if hideNow == true then
		indicatorControl:SetHidden(true)
--d("<<abort 1")
	end
	if returnNow == true then
		return
	end
	hideNow = false
	returnNow = false

	--Item is protected against research so do not add any marker
	local alwaysShowResearchIcon = RASettings:GetAlwaysShowResearchIcon()
	local alwaysShowResearchIconExcludeNonTracked = RASettings:GetAlwaysShowResearchIconExcludeNonTracked()
	local isProtected = RAScanner:IsItemProtectedAgainstResearch(bagId, slotIndex, itemLink)
--d(">isProtected: " ..tos(isProtected))
	if isProtected == true then
		if not alwaysShowResearchIcon then
			indicatorControl:SetHidden(true)
			return
		else
			--Marker should always be shown: Set the value internal to "protected" and show the protected lock icon
			--and the normal tooltip telling us if the item is researchable etc.
			data.researchAssistant = TRACKING_STATE_PROTECTED
		end
	end

	--if we aren't tracking anybody for that skill, hide and go away
	local craftingNotTracked = RASettings:IsMultiCharSkillOff(craftingSkill, itemType)
	if craftingNotTracked == true then
		if not alwaysShowResearchIcon or (alwaysShowResearchIcon == true and alwaysShowResearchIconExcludeNonTracked == true) then
			data.researchAssistant = TRACKING_STATE_UNTRACKED
			indicatorControl:SetHidden(true)
			return
		end
	end

	--preference value for the "best" item candidate for the trait in question
	local bestTraitPreferenceScore = RASettings:GetPreferenceValueForTrait(traitKey)
	--research character of that item
	local researchCharOfCraftingTypeNameDecorated = RASettings:GetTrackedCharForSkill(craftingSkill, itemType, true)
	if researchCharOfCraftingTypeNameDecorated == RASettings.CONST_OFF_VALUE then
		researchCharOfCraftingTypeNameDecorated = unknownStr
	end

	if bestTraitPreferenceScore == nil then
		-- if the item is traitless, show "researched" color. if we've never seen this trait before, show "best" color.
		if reason == libResearch_Reason_TRAITLESS then
			bestTraitPreferenceScore = true
		else
			bestTraitPreferenceScore = RA_CON_BEST_PREFERENCE_VALUE
		end
	end

	if bestTraitPreferenceScore == true and not RASettings:ShowResearched() then
		data.researchAssistant = TRACKING_STATE_KNOWN
		indicatorControl:SetHidden(true)
		return
	end

	--here's the "display it" section
	local protectedStr = ""
	local showNow = true
	--Indicator controls will be hidden here!
	if isProtected == true and alwaysShowResearchIcon == true then
		SetToProtected(indicatorControl)
		protectedStr = "\n"..TOOLTIPS.protected
	else
		SetToNormal(indicatorControl)
		if craftingNotTracked == true then
			showNow = false
		end
	end
	--And now they are shown if needed
	if showNow == true then
		DisplayIndicator(indicatorControl)
	end

	local stackSize = data.stackCount or 0

	--Who knows the trait already?
	local whoKnows = ""
	local traitName
	local showTooltips = RASettings:ShowTooltips()
	if showTooltips == true then
		whoKnows, traitName = getWhoKnowsAndTraitTextAndTexture(itemLink, traitKey)
		HandleTooltips(indicatorControl, function()
			return getTooltipText(showTooltips, bagId, slotIndex, itemLink, stackSize, bestTraitPreferenceScore, whoKnows, traitName, researchCharOfCraftingTypeNameDecorated, protectedStr, craftingNotTracked)
		end)
	else
		HandleTooltips(indicatorControl, nil)
	end

	--d(">" .. strfor("traitKey: %s, isResearchable: %s, reason: %s, score: %s, stackSize: %s, char: %s, whoKnows: %s", tos(traitKey), tos(isResearchable), tos(reason), tos(bestTraitPreferenceScore), tos(stackSize), tos(researchCharOfCraftingTypeNameDecorated), tos(whoKnows)))

	--pretty colors time!
	--if we don't know it, color the icon something fun
	if bestTraitPreferenceScore ~= true then
		--Not scanned character
		if bestTraitPreferenceScore == RASettings.CONST_CHARACTER_NOT_SCANNED_YET then
			indicatorControl:SetColor(unpack(RASettings:GetNotScannedColor()))
			if not isProtected == true then
				data.researchAssistant = TRACKING_STATE_CHARACTER_NOT_SCANNED_YET
			end
		else
			--preference value for the current item
			local thisItemScore = RAScanner:CreateItemPreferenceValue(itemLink, bagId, slotIndex)
			if (thisItemScore > bestTraitPreferenceScore or stackSize > 1) then
				indicatorControl:SetColor(unpack(RASettings:GetDuplicateUnresearchedColor()))
				if not isProtected == true then
					data.researchAssistant = TRACKING_STATE_DUPLICATE
				end
			else
				indicatorControl:SetColor(unpack(RASettings:GetCanResearchColor()))
				if not isProtected == true then
					data.researchAssistant = TRACKING_STATE_RESEARCHABLE
				end
			end
		end
	else
		--Known item
		--in any other case, color it known
		indicatorControl:SetColor(unpack(RASettings:GetAlreadyResearchedColor()))
		if not isProtected == true then
			if reason == libResearch_Reason_TRAITLESS then
				data.researchAssistant = TRACKING_STATE_TRAITLESS
			else
				data.researchAssistant = TRACKING_STATE_KNOWN
			end
		end
	end
end

--[[----------------------------------------------------------------------------
	a simple event buffer to make sure that the scan doesn't happen more than
	once in a single instance, as EVENT_INVENTORY_SINGLE_SLOT_UPDATE is very
	spammy, especially with junk and bank management add-ons
--]]----------------------------------------------------------------------------
local canUpdate = true
local wasInCombatAsWantedToScan = false

local function scanBagsNow()
	if canUpdate == false then
		--d("[RA]scanBagsNow")
		RAScanner:RescanBags()
		canUpdate = true
		wasInCombatAsWantedToScan = false
	end
end

--EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
function ResearchAssistant_InvUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	--d("[RA]ResearchAssistant_InvUpdate")
	--Check if we are in combat and do not update then
	if wasInCombatAsWantedToScan == true or IsUnitInCombat("player") == true then
		canUpdate = false
		wasInCombatAsWantedToScan = true
		--d("<inCombat, aborted!")
		return
	end
	--InventoryScan can be done?
	if canUpdate == true then
		canUpdate = false
		zo_callLater(function()
			scanBagsNow()
		end, 25)
	end
end

local function RA_HookTrading()
	EVENT_MANAGER:UnregisterForEvent("RA_TRADINGHOUSE", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
	local hookedFunction = TRADING_HOUSE.searchResultsList.dataTypes[1].setupCallback
	if hookedFunction then
		SecurePostHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback", function(row, data)
			AddResearchIndicatorToSlot(row, GetTradingHouseSearchResultItemLink)
		end)
	end
end

local function RA_Event_Player_Activated(event, isA)
	--Only fire once after login!
	EVENT_MANAGER:UnregisterForEvent("RA_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
	if RA.libResearch == nil then d(strfor(libErrorText, "LibResearch")) return end
	if RA.lam == nil then d(strfor(libErrorText, "LibAddonMenu-2.0")) return end

	local noCraftingCharWasChosenYetAtAll = false
	if RA.settings and RA.settings.sv then
		local STRINGSettings = STRINGS[RAlang].SETTINGS
		local settings = RA.settings.sv
		local CONST_OFF_VALUE = RA.settings.CONST_OFF_VALUE
		--if not settings.allowNoCharsForResearch then
			if settings.useAccountWideResearchChars == true then
				--Is the value 0 (CONST_OFF_VALUE) set for all crafting chars? No char was chosen yet!
				if settings.blacksmithCharacter[CONST_OFF_VALUE]       		 == CONST_OFF_VALUE
						and settings.weaponsmithCharacter[CONST_OFF_VALUE]      == CONST_OFF_VALUE
						and settings.woodworkingCharacter[CONST_OFF_VALUE]      == CONST_OFF_VALUE
						and settings.clothierCharacter[CONST_OFF_VALUE]         == CONST_OFF_VALUE
						and settings.leatherworkerCharacter[CONST_OFF_VALUE]    == CONST_OFF_VALUE
						and settings.jewelryCraftingCharacter[CONST_OFF_VALUE]  == CONST_OFF_VALUE then
					noCraftingCharWasChosenYetAtAll = true
				end
			else
				--Use different research characters for each of your characters
				if settings.useLoggedInCharForResearch == true then
					--Use different research characters for each of your characters
					settings.blacksmithCharacter[currentlyLoggedInCharId]       = currentlyLoggedInCharId
					settings.weaponsmithCharacter[currentlyLoggedInCharId]      = currentlyLoggedInCharId
					settings.woodworkingCharacter[currentlyLoggedInCharId]      = currentlyLoggedInCharId
					settings.clothierCharacter[currentlyLoggedInCharId]         = currentlyLoggedInCharId
					settings.leatherworkerCharacter[currentlyLoggedInCharId]    = currentlyLoggedInCharId
					settings.jewelryCraftingCharacter[currentlyLoggedInCharId]  = currentlyLoggedInCharId
					noCraftingCharWasChosenYetAtAll = false
				else
					if settings.blacksmithCharacter[currentlyLoggedInCharId]       		 == CONST_OFF_VALUE
							and settings.weaponsmithCharacter[currentlyLoggedInCharId]      == CONST_OFF_VALUE
							and settings.woodworkingCharacter[currentlyLoggedInCharId]      == CONST_OFF_VALUE
							and settings.clothierCharacter[currentlyLoggedInCharId]         == CONST_OFF_VALUE
							and settings.leatherworkerCharacter[currentlyLoggedInCharId]    == CONST_OFF_VALUE
							and settings.jewelryCraftingCharacter[currentlyLoggedInCharId]  == CONST_OFF_VALUE then
						noCraftingCharWasChosenYetAtAll = true
					end
				end
			end
			if noCraftingCharWasChosenYetAtAll == true then
				local alertTextHeader = "["..RA.name.."]"
				local alertText = STRINGSettings.ERROR_CONFIGURE_ADDON .. "\n" .. STRINGSettings.ERROR_LOGIN_ALL_CHARS
				if alertText and alertText ~= "" then
					--Output the text as Center Screen Announcement
					local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
					params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
					params:SetText(alertTextHeader .. " " .. alertText)
					params:SetLifespanMS(3000)
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
					--Output the text to the chat
					d(alertText)
				end

				--Set the text of the dialog
				ESO_Dialogs[RA.dialogName].mainText = {
						text = alertText,
				}
				--Output the text as dialog which is able to open the settings directly via "Yes" button
				ZO_Dialogs_ShowDialog(RA.dialogName, {})
			end
		--end
	end
end

local function ResearchAssistant_Loaded(eventCode, addOnName)
	if addOnName ~= RA.name then return end
	EVENT_MANAGER:RegisterForEvent("RA_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, RA_Event_Player_Activated)

	local libResearch = LibResearch
	if libResearch == nil then d(strfor(libErrorText, "LibResearch")) return end
	RA.libResearch = libResearch
	local LAM = LibAddonMenu2
	if LAM == nil then d(strfor(libErrorText, "LibAddonMenu-2.0")) return end
	RA.lam = LAM
	if LibDebugLogger then
		RA.logger = LibDebugLogger(RA.name)
	end

	RA.currentlyLoggedInCharId = RA.currentlyLoggedInCharId or GetCurrentCharacterId()

	wasInCombatAsWantedToScan = false

	--Settings and Scanner
	RASettings = RASettings or RA.GetOrCreateRASettings()
	RAScanner = RAScanner or RA.GetOrCreateRAScanner()
	RAScanner:SetDebug(RASettings:IsDebug())

	local stringsOfClientLang = STRINGS[RAlang]
	local stringsOfFallbackLang = STRINGS["en"]

	TOOLTIPS = stringsOfClientLang.TOOLTIPS
	RA.tooltips = TOOLTIPS

	armorTypeToName = {
		[ARMORTYPE_LIGHT] 				= stringsOfClientLang.armorLight or stringsOfFallbackLang.armorLight,
		[ARMORTYPE_MEDIUM] 				= stringsOfClientLang.armorMedium or stringsOfFallbackLang.armorMedium,
		[ARMORTYPE_HEAVY]				= stringsOfClientLang.armorHeavy or stringsOfFallbackLang.armorHeavy,
	}
	weaponTypeToName = {
		[WEAPONTYPE_AXE] 				= stringsOfClientLang.weaponAxe or stringsOfFallbackLang.weaponAxe,
		[WEAPONTYPE_BOW] 				= stringsOfClientLang.weaponBow or stringsOfFallbackLang.weaponBow,
		[WEAPONTYPE_DAGGER] 			= stringsOfClientLang.weaponDagger or stringsOfFallbackLang.weaponDagger,
		[WEAPONTYPE_FIRE_STAFF]			= stringsOfClientLang.weaponFireStaff or stringsOfFallbackLang.weaponFireStaff,
		[WEAPONTYPE_FROST_STAFF] 		= stringsOfClientLang.weaponFrostStaff or stringsOfFallbackLang.weaponFrostStaff,
		[WEAPONTYPE_HAMMER] 			= stringsOfClientLang.weaponHammer or stringsOfFallbackLang.weaponHammer,
		[WEAPONTYPE_HEALING_STAFF] 		= stringsOfClientLang.weaponHealingStaff or stringsOfFallbackLang.weaponHealingStaff,
		[WEAPONTYPE_LIGHTNING_STAFF] 	= stringsOfClientLang.weaponLightningStaff or stringsOfFallbackLang.weaponLightningStaff,
		[WEAPONTYPE_SHIELD] 			= stringsOfClientLang.weaponShield or stringsOfFallbackLang.weaponShield,
		[WEAPONTYPE_SWORD] 				= stringsOfClientLang.weaponSword or stringsOfFallbackLang.weaponSword,
		[WEAPONTYPE_TWO_HANDED_AXE] 	= stringsOfClientLang.weapon2hdAxe or stringsOfFallbackLang.weapon2hdAxe,
		[WEAPONTYPE_TWO_HANDED_HAMMER] 	= stringsOfClientLang.weapon2hdHammer or stringsOfFallbackLang.weapon2hdHammer,
		[WEAPONTYPE_TWO_HANDED_SWORD] 	= stringsOfClientLang.weapon2hdSword or stringsOfFallbackLang.weapon2hdSword,
	}
	equipmentTypeToName = {
		[EQUIP_TYPE_CHEST] 				= stringsOfClientLang.equipChest or stringsOfFallbackLang.equipChest,
		[EQUIP_TYPE_FEET] 				= stringsOfClientLang.equipFeet or stringsOfFallbackLang.equipFeet,
		[EQUIP_TYPE_HAND] 				= stringsOfClientLang.equipHand or stringsOfFallbackLang.equipHand,
		[EQUIP_TYPE_HEAD] 				= stringsOfClientLang.equipHead or stringsOfFallbackLang.equipHead,
		[EQUIP_TYPE_LEGS] 				= stringsOfClientLang.equipLegs or stringsOfFallbackLang.equipLegs,
		[EQUIP_TYPE_NECK] 				= stringsOfClientLang.equipNeck or stringsOfFallbackLang.equipNeck,
		[EQUIP_TYPE_RING] 				= stringsOfClientLang.equipRing or stringsOfFallbackLang.equipRing,
		[EQUIP_TYPE_SHOULDERS] 			= stringsOfClientLang.equipShoulders or stringsOfFallbackLang.equipShoulders,
		[EQUIP_TYPE_WAIST] 				= stringsOfClientLang.equipWaist or stringsOfFallbackLang.equipWaist,
	}
	RA.armorTypeToName = armorTypeToName
	RA.equipmentTypeToName = equipmentTypeToName
	RA.weaponTypeToName = weaponTypeToName

	--inventories hook
	for _, v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			SecurePostHook(listView.dataTypes[1], "setupCallback", function(rowControl, slot)
				AddResearchIndicatorToSlot(rowControl, GetItemLink)
			end)
		end
	end

	--deconstruction hook
	SecurePostHook(DECONSTRUCTION.dataTypes[1], "setupCallback", function(rowControl, slot)
		AddResearchIndicatorToSlot(rowControl, GetItemLink)
	end)

	--universal deconstruction hook
	SecurePostHook(UNIVERSAL_DECON.dataTypes[1], "setupCallback", function(rowControl, slot)
		AddResearchIndicatorToSlot(rowControl, GetItemLink)
	end)

	--EVENT_PLAYER_COMBAT_STATE callback function
	local function RA_CombatState(_, inCombat)
		--d("[RA]Combat event, inCombat: " ..tos(inCombat))
		--Scan of bags was tried within combat but suppressed? Try after combat again
		if inCombat == false then
			if wasInCombatAsWantedToScan == true then
				--d(">scanning bags after combat now!")
				scanBagsNow()
			end
		end
	end

	local function RA_EnableBankScan(bankBag)
		if IsHouseBankBag(bankBag) == true then
			--Scan the house bank on first open automatically!
			RAScanner:SetHouseBankScanEnabled(true, true)
		else
			RAScanner:SetBankScanEnabled(true)
		end
	end

	local function RA_DisableBankScan()
		RAScanner:SetBankScanEnabled(false)
		RAScanner:SetHouseBankScanEnabled(false)
	end

	--trading house hook
	EVENT_MANAGER:RegisterForEvent("RA_DISABLE_BANK_SCAN", EVENT_END_CRAFTING_STATION_INTERACT, RA_DisableBankScan)
	EVENT_MANAGER:RegisterForEvent("RA_DISABLE_BANK_SCAN", EVENT_CLOSE_BANK, RA_DisableBankScan)
	EVENT_MANAGER:RegisterForEvent("RA_ENABLE_BANK_SCAN", EVENT_CRAFTING_STATION_INTERACT, RA_EnableBankScan)
	EVENT_MANAGER:RegisterForEvent("RA_ENABLE_BANK_SCAN", EVENT_OPEN_BANK, function(eventId, bankBag) RA_EnableBankScan(bankBag) end)

	EVENT_MANAGER:RegisterForEvent("RA_TRADINGHOUSE", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, RA_HookTrading)
	EVENT_MANAGER:RegisterForEvent("RA_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, RA_CombatState)
	--Items in bag changed: Rescan it
	EVENT_MANAGER:RegisterForEvent("RA_INV_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResearchAssistant_InvUpdate)
	--Add event filter to only scan upon updates of real items and not on durability changes etc.
	EVENT_MANAGER:AddFilterForEvent("RA_INV_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

	--Register the ESO dialog for ResearchAssistant
	RA.dialogName = RA.name.."_Dialog"
	ESO_Dialogs[RA.dialogName] = {
		canQueue = true,
		uniqueIdentifier = RA.dialogName,
		title = {
			text = "ResearchAssistant",
		},
		mainText = {
			text = "",
		},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback = function(dialog)
					if RA.lam and RA.settingsPanel then
						RA.lam:OpenToPanel(RA.settingsPanel)
					end
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback = function(dialog) end,
			}
		},
		setup = function(dialog, data) end,
	}

	--Add context menu entries
	if LibCustomMenu ~= nil then
		local function RA_OnContextMenu(inventorySlot, slotActions)
			local isAllowed = false
			RAScanner = RAScanner or RA.GetOrCreateRAScanner()
			if RAScanner == nil or  RASettings == nil then return end
			if not RAScanner:IsDebug() then return end

			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
			local itemLink = GetItemLink(bagId, slotIndex)
			if not itemLink or itemLink == "" then return end
			local itemType = GetItemLinkItemType(itemLink)
			if not itemType then return end
			if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON then return end

			isAllowed = true

			if isAllowed == true then
				local function doDebugTask(taskName)
					if not taskName or taskName == "" then return end
					if taskName == "ps" then
						RAScanner:Log("Preference value of " ..itemLink..": " ..tos(RAScanner:CreateItemPreferenceValue(itemLink, bagId, slotIndex)))
					elseif taskName == "ir" then
						local traitKey, isResearchable, reason = RAScanner:CheckIsItemResearchable(itemLink)
						RAScanner:Log("Is rearchable " ..itemLink..": " ..tos(isResearchable) .. ", traitKey: " ..tos(traitKey) .. ", reason: " ..tos(reason))
					elseif taskName == "ip" then
						local isProtected = RAScanner:IsItemProtectedAgainstResearch(bagId, slotIndex, itemLink)
						RAScanner:Log("Is protected " ..itemLink..": " ..tos(isProtected) .. ", settings ZOs/FCOIS/noSets: " ..tos(RASettings.sv.respectItemProtectionByZOs).."/"..tos(RASettings.sv.respectItemProtectionByFCOIS).."/"..tos(RASettings.sv.skipSets))
					end
				end
				local entries = {
					{
						label = "Get preference score",
						callback = function() doDebugTask("ps") end,
					},
					{
						label = "Is item researchable",
						callback = function() doDebugTask("ir") end,
					},
					{
						label = "Is item protected",
						callback = function() doDebugTask("ip") end,
					},
				}
				AddCustomSubMenuItem("["..RA.name.."] - DEBUG", entries)
			end
			--ShowMenu(inventorySlot)
		end
		LibCustomMenu:RegisterContextMenu(RA_OnContextMenu, LibCustomMenu.CATEGORY_EARLY)
	end
end

EVENT_MANAGER:RegisterForEvent(RA.name .."Loaded", EVENT_ADD_ON_LOADED, ResearchAssistant_Loaded)
