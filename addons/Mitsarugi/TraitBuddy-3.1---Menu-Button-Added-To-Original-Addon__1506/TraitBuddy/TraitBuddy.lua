local TraitBuddy = {}
TraitBuddyUI = {}
local LAM = LibStub("LibAddonMenu-2.0")
local ADDON_NAME = "TraitBuddy"
local ADDON_VERSION = "3.1"
local GAMEPAD_STYLE_1 = {
	fontSize = 32,
	fontColorType = INTERFACE_COLOR_TYPE_GAMEPAD_TOOLTIP,
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
	fontStyle = "soft-shadow-thick",
	customSpacing = 15
	}
local GAMEPAD_STYLE_2 = {
	fontSize = 32,
	fontColorType = INTERFACE_COLOR_TYPE_GAMEPAD_TOOLTIP,
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3,
	fontStyle = "soft-shadow-thick",
	customSpacing = 15
	}
local function Contains(t,check)
	for k,v in ipairs(t) do
		if v == check then
			return true
		end
	end
	return false
end
local function SortCharacters()
	--Get the character ids stored in the settings and sort them by character name
	local t = {} --Numeric sorted hashtable id+name
	for id,c in pairs(TraitBuddy.settings.characters) do
		t[#t+1] = {id=id, name=c.name}
	end
	table.sort(t, function(a,b) return a.name<b.name end)
	local s = {} --Numeric table of ids
	for k,v in ipairs(t) do
		s[#s+1] = v.id
	end
	TraitBuddy.soc = s
end
local function IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex)
	return (type(character.research[craftingSkillType][researchLineIndex][traitIndex])=="table")
end
local function IsTraitKnown(character, craftingSkillType, researchLineIndex, traitIndex)
	if IsTraitBeingResearched(character, craftingSkillType, researchLineIndex, traitIndex) then
		return false
	else
		return character.research[craftingSkillType][researchLineIndex][traitIndex]
	end
end
local function StructureAndFix()
	--Fix any data bugs or add new patch features on all characters. Also sets up stuctures for new characters
	--The research and motifs hashtables will have been created from DefaultSettings()
	
	--v2.7 unique character id instead of name, removal of stored class info
	for i = 1, GetNumCharacters() do
		local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
		name = zo_strformat("<<1>>",name)
		if TraitBuddy.settings.research then --Old settings
			if TraitBuddy.settings.research[name] then
				TraitBuddy.settings.characters[id] = {
					show = TraitBuddy.settings.research[name].show,
					research = TraitBuddy.settings.research[name],
					motifs = TraitBuddy.settings.motifs[name]
				}
				TraitBuddy.settings.characters[id].research.show = nil
			end
		end
		--Update what could have changed
		if TraitBuddy.settings.characters[id] then
			TraitBuddy.settings.characters[id].name = name
		end
	end
	if TraitBuddy.settings.classes then
		TraitBuddy.settings.classes = nil
	end
	if TraitBuddy.settings.research then
		TraitBuddy.settings.research = nil
	end
	if TraitBuddy.settings.motifs then
		TraitBuddy.settings.motifs = nil
	end
	if TraitBuddy.settings.classId then
		TraitBuddy.settings.classId = nil
	end
	
	--v2.8 fix messed up character data from 2.7
	for id,c in pairs(TraitBuddy.settings.characters) do
		if type(id)=="number" and tostring(id):len()<5 then
			TraitBuddy.settings.characters[id] = nil
		end
	end
	
	--New player or new to the addon
	if not TraitBuddy.settings.characters[TraitBuddy.characterId] then
		TraitBuddy.settings.characters[TraitBuddy.characterId] = {
			name = zo_strformat("<<1>>",GetRawUnitName("player")),
			show = true,
			research = {},
			motifs = {}
		}
	end
	
	local craftingSkillTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}
	for id,c in pairs(TraitBuddy.settings.characters) do
		if c.fixes then --Removed GetCharacterInfo() workaround v3.1
			c.fixes = nil
		end
		for _,craftingSkillType in pairs(craftingSkillTypes) do
			c.research[craftingSkillType] = c.research[craftingSkillType] or {}
			c.research[craftingSkillType].MaxSimultaneousResearch = c.research[craftingSkillType].MaxSimultaneousResearch or 1
			
			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				c.research[craftingSkillType][researchLineIndex] = c.research[craftingSkillType][researchLineIndex] or {}
				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
				c.research[craftingSkillType][researchLineIndex].Name = nil
				for traitIndex = 1, numTraits do
					c.research[craftingSkillType][researchLineIndex][traitIndex] = c.research[craftingSkillType][researchLineIndex][traitIndex] or false
					if type(c.research[craftingSkillType][researchLineIndex][traitIndex]) == "number" then --research changed v2.7
						local old = c.research[craftingSkillType][researchLineIndex][traitIndex]
						c.research[craftingSkillType][researchLineIndex][traitIndex] = { duration = 0, done = old }
					end
				end
			end
		end

		c.motifs = c.motifs or {} --Motifs added in v1.6
		for styleIndex = 1, GetNumSmithingStyleItems() do
			local _, _, _, _, itemStyle, quality = GetSmithingStyleItemInfo(styleIndex)
			if itemStyle ~= ITEMSTYLE_NONE then
				local order = TraitBuddyData:GetMotifOrder(itemStyle)
				if order then
					if TraitBuddyData:MotifHasChapters(order) then
						c.motifs[order] = c.motifs[order] or {}
						if type(c.motifs[order]) == "boolean" then
							c.motifs[order] = {} --bug fix prior to v1.9 OnStyleLearned
						end
						for chapter = 1, TraitBuddyData:GetNumChapters() do
							c.motifs[order][chapter] = c.motifs[order][chapter] or false
						end
					else
						c.motifs[order] = c.motifs[order] or false
					end
				end
			end
		end
	end
end
local function UpdateMotifs()
	local c = TraitBuddy.settings.characters[TraitBuddy.characterId]
	for styleIndex = 1, GetNumSmithingStyleItems() do
		local _, _, _, _, itemStyle, quality = GetSmithingStyleItemInfo(styleIndex)
		if itemStyle ~= ITEMSTYLE_NONE then
			local order = TraitBuddyData:GetMotifOrder(itemStyle)
			if order then
				if TraitBuddyData:MotifHasChapters(order) then
					local motif = TraitBuddyData:GetMotif(order)
					for chapter = 1, TraitBuddyData:GetNumChapters() do
						local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,motif[chapter],motif.quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
						c.motifs[order][chapter] = IsItemLinkBookKnown(itemLink)
					end
				else
					c.motifs[order] = IsSmithingStyleKnown(styleIndex, 1)
				end
			end
		end
	end
end
local function UpdateResearch()
	--Update the saved research data for this character
	local c = TraitBuddy.settings.characters[TraitBuddy.characterId]
	local craftingSkillTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}
	for key,craftingSkillType in pairs(craftingSkillTypes) do
		c.research[craftingSkillType].MaxSimultaneousResearch = GetMaxSimultaneousSmithingResearch(craftingSkillType)
		for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
			local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			for traitIndex = 1, numTraits do
				local value = c.research[craftingSkillType][researchLineIndex][traitIndex]
				local _, _, known = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
				local durationSecs, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)	--can be nil
				local wasBeingResearched = IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex)
				local currentlyResearching = false
				local whenDoneTimeStamp = 0
				if durationSecs then
					currentlyResearching = true
					whenDoneTimeStamp = GetTimeStamp() + timeRemainingSecs
				end
				if wasBeingResearched then
					--Was researching at some point
					if known then
						c.research[craftingSkillType][researchLineIndex][traitIndex] = nil
						c.research[craftingSkillType][researchLineIndex][traitIndex] = true
					else
						if currentlyResearching then
							c.research[craftingSkillType][researchLineIndex][traitIndex] = { duration = durationSecs, done = whenDoneTimeStamp }
						else
							--correct some mistake
							c.research[craftingSkillType][researchLineIndex][traitIndex] = nil
							c.research[craftingSkillType][researchLineIndex][traitIndex] = false
						end
					end
				elseif currentlyResearching then
					c.research[craftingSkillType][researchLineIndex][traitIndex] = { duration = durationSecs, done = whenDoneTimeStamp }
				else
					c.research[craftingSkillType][researchLineIndex][traitIndex] = known
				end
			end
		end
	end
end
local function FindTraitIndex(craftingSkillType, researchLineIndex, traitType)
	--Trying not to hard code the trait type indexes
	local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
	for traitIndex = 1, numTraits do
		local foundTraitType, _, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
		if foundTraitType == traitType then
			return traitIndex
		end
	end
	return ITEM_TRAIT_TYPE_NONE
end
local function IsBlacksmithWeapon(weaponType)
	return weaponType == WEAPONTYPE_AXE
	    or weaponType == WEAPONTYPE_HAMMER
	    or weaponType == WEAPONTYPE_SWORD
	    or weaponType == WEAPONTYPE_TWO_HANDED_AXE
	    or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
	    or weaponType == WEAPONTYPE_TWO_HANDED_SWORD
	    or weaponType == WEAPONTYPE_DAGGER
end
local function IsWoodworkingWeapon(weaponType)
	return weaponType == WEAPONTYPE_BOW
	    or weaponType == WEAPONTYPE_FIRE_STAFF
	    or weaponType == WEAPONTYPE_FROST_STAFF
	    or weaponType == WEAPONTYPE_LIGHTNING_STAFF
	    or weaponType == WEAPONTYPE_HEALING_STAFF
	    or weaponType == WEAPONTYPE_SHIELD
end
local function ItemToCraftingSkillType(itemType, armorType, weaponType)
	--GetItemLinkCraftingSkillType didn't return what I expected
	if itemType == ITEMTYPE_ARMOR then
		if armorType == ARMORTYPE_HEAVY then
			return CRAFTING_TYPE_BLACKSMITHING
		elseif armorType == ARMORTYPE_MEDIUM or armorType == ARMORTYPE_LIGHT then
			return CRAFTING_TYPE_CLOTHIER
		end
	elseif itemType == ITEMTYPE_WEAPON then
		if IsBlacksmithWeapon(weaponType) then
			return CRAFTING_TYPE_BLACKSMITHING
		elseif IsWoodworkingWeapon(weaponType) then
			return CRAFTING_TYPE_WOODWORKING
		end
	end
	return nil
end
local function ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
	--Figure out which research index this item is. Hope to find a function to do this
	
	if itemType == ITEMTYPE_ARMOR then
		if armorType == ARMORTYPE_HEAVY then
			if equipType == EQUIP_TYPE_CHEST then --Cuirass
				return 8
			elseif equipType == EQUIP_TYPE_FEET then --Sabatons
				return 9
			elseif equipType == EQUIP_TYPE_HAND then --Gauntlets
				return 10
			elseif equipType == EQUIP_TYPE_HEAD then --Helm
				return 11
			elseif equipType == EQUIP_TYPE_LEGS then --Greaves
				return 12
			elseif equipType == EQUIP_TYPE_SHOULDERS then --Pauldron
				return 13
			elseif equipType == EQUIP_TYPE_WAIST then --Girdle
				return 14
			end
		elseif armorType == ARMORTYPE_MEDIUM then
			if equipType == EQUIP_TYPE_CHEST then --Jack
				return 8
			elseif equipType == EQUIP_TYPE_FEET then --Boots
				return 9
			elseif equipType == EQUIP_TYPE_HAND then --Bracers
				return 10
			elseif equipType == EQUIP_TYPE_HEAD then --Helmet
				return 11
			elseif equipType == EQUIP_TYPE_LEGS then --Guards
				return 12
			elseif equipType == EQUIP_TYPE_SHOULDERS then --Arm Cops
				return 13
			elseif equipType == EQUIP_TYPE_WAIST then --Belt
				return 14
			end
		elseif armorType == ARMORTYPE_LIGHT then
			if equipType == EQUIP_TYPE_CHEST then --Robe+Shirt = Robe & Jerkin
				return 1
			elseif equipType == EQUIP_TYPE_FEET then --Shoes
				return 2
			elseif equipType == EQUIP_TYPE_HAND then --Gloves
				return 3
			elseif equipType == EQUIP_TYPE_HEAD then --Hat
				return 4
			elseif equipType == EQUIP_TYPE_LEGS then --Breeches
				return 5
			elseif equipType == EQUIP_TYPE_SHOULDERS then --Epaulets
				return 6
			elseif equipType == EQUIP_TYPE_WAIST then --Sash
				return 7
			end
		end
	elseif itemType == ITEMTYPE_WEAPON then
		if weaponType == WEAPONTYPE_AXE then
			return 1
		elseif weaponType == WEAPONTYPE_HAMMER then
			return 2
		elseif weaponType == WEAPONTYPE_SWORD then
			return 3
		elseif weaponType == WEAPONTYPE_TWO_HANDED_AXE then
			return 4
		elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
			return 5
		elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
			return 6
		elseif weaponType == WEAPONTYPE_DAGGER then
			return 7
		elseif weaponType == WEAPONTYPE_BOW then
			return 1
		elseif weaponType == WEAPONTYPE_FIRE_STAFF then
			return 2
		elseif weaponType == WEAPONTYPE_FROST_STAFF then
			return 3
		elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
			return 4
		elseif weaponType == WEAPONTYPE_HEALING_STAFF then
			return 5
		elseif weaponType == WEAPONTYPE_SHIELD then
			return 6
		end
	end
	return 0
end
local function IsResearchableTrait(itemType, traitType)
	return (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR)
	   and (traitType == ITEM_TRAIT_TYPE_ARMOR_DIVINES
		or traitType == ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS
		or traitType == ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE
		or traitType == ITEM_TRAIT_TYPE_ARMOR_INFUSED
		or traitType == ITEM_TRAIT_TYPE_ARMOR_REINFORCED
		or traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY
		or traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING
		or traitType == ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED
		or traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED
		or traitType == ITEM_TRAIT_TYPE_WEAPON_CHARGED
		or traitType == ITEM_TRAIT_TYPE_WEAPON_DEFENDING
		or traitType == ITEM_TRAIT_TYPE_WEAPON_INFUSED
		or traitType == ITEM_TRAIT_TYPE_WEAPON_POWERED
		or traitType == ITEM_TRAIT_TYPE_WEAPON_PRECISE
		or traitType == ITEM_TRAIT_TYPE_WEAPON_SHARPENED
		or traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING
		or traitType == ITEM_TRAIT_TYPE_WEAPON_DECISIVE
		or traitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED)
end
local function GetWhoKnowsMotif(order, chapter)
	--Figure out who knows the motif, chapter optional. Returns sorted tables of character names
	local know = {}
	local dontKnow = {}
	for _,id in ipairs(TraitBuddy.soc) do
		local c = TraitBuddy.settings.characters[id]
		if c.show then
			if chapter then
				if c.motifs[order] then
					if c.motifs[order][chapter] == true then
						know[#know+1] = c.name
					else
						dontKnow[#dontKnow+1] = c.name
					end
				else
					dontKnow[#dontKnow+1] = c.name
				end
			else
				if c.motifs[order] == true then
					know[#know+1] = c.name
				else
					dontKnow[#dontKnow+1] = c.name
				end
			end
		end
	end
	return know, dontKnow
end
local function IsMotifKnown(order, chapter)
	--Known by anyone, chapter optional, Returns someoneKnows, selectedKnows
	local know, _ = GetWhoKnowsMotif(order, chapter)
	if #know > 0 then
		return true, Contains(know,TraitBuddy.settings.characters[TraitBuddy.selectedId].name)
	else
		return false, false
	end
end
local function GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex)
	--Figure out who knows the trait, Returns sorted tables of character names
	local know = {}
	local researching = {}
	local dontKnow = {}
	for _,id in ipairs(TraitBuddy.soc) do
		local c = TraitBuddy.settings.characters[id]
		if c.show then
			if IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
				researching[#researching+1] = c.name
			elseif IsTraitKnown(c, craftingSkillType, researchLineIndex, traitIndex) then
				know[#know+1] = c.name
			else
				dontKnow[#dontKnow+1] = c.name
			end
		end
	end
	return know, researching, dontKnow
end
local function IsTraitKnown2(craftingSkillType, researchLineIndex, traitIndex)
	--Known by anyone, returns someoneKnows, selectedKnows, someoneResearching, selectedResearching
	local know, researching, _ = GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex)
	local someoneKnows = false
	local selectedKnows = false
	if #know > 0 then
		someoneKnows = true
		selectedKnows = Contains(know,TraitBuddy.settings.characters[TraitBuddy.selectedId].name)
	end
	if #researching > 0 then
		return someoneKnows, selectedKnows, true, Contains(researching,TraitBuddy.settings.characters[TraitBuddy.selectedId].name)
	else
		return someoneKnows, selectedKnows, false, false
	end
end
local function BuildTooltipTitle(control, title, GamePadMode)
	--Title
	if GamePadMode then
		control:AddLine(ADDON_NAME, {fontSize=27, customSpacing=15}, control:GetStyle("bodyHeader"))
		control:AddLine(title, GAMEPAD_STYLE_2, control:GetStyle("bodySection"))
	else
		control:AddLine(title, "ZoFontGameBold", 1,1,1, LEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
	end
end
local function BuildTooltip(control, know, researching, canResearch, GamePadMode)
	local r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
	--Already researched
	if #know > 0 and TraitBuddy.settings.tooltip.show.knowSection then
		if GamePadMode then
			GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.settings.tooltip.colours.know_title.r,TraitBuddy.settings.tooltip.colours.know_title.g,TraitBuddy.settings.tooltip.colours.know_title.b)
			control:AddLine(GetString(TB_KNOWN), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
			control:AddLine(table.concat(know, ", "), GAMEPAD_STYLE_2, control:GetStyle("bodySection"))
		else
			control:AddLine(GetString(TB_KNOWN), "TBFontItemCategory", TraitBuddy.settings.tooltip.colours.know_title.r,TraitBuddy.settings.tooltip.colours.know_title.g,TraitBuddy.settings.tooltip.colours.know_title.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			control:AddLine(table.concat(know, ", "), "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
	--Being researched
	if #researching > 0 and TraitBuddy.settings.tooltip.show.researchingSection then
		if GamePadMode then
			GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.settings.tooltip.colours.researching_title.r,TraitBuddy.settings.tooltip.colours.researching_title.g,TraitBuddy.settings.tooltip.colours.researching_title.b)
			control:AddLine(GetString(TB_BEING_RESEARCHED), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
			control:AddLine(table.concat(researching, ", "), GAMEPAD_STYLE_2, control:GetStyle("bodySection"))
		else
			control:AddLine(GetString(TB_BEING_RESEARCHED), "TBFontItemCategory", TraitBuddy.settings.tooltip.colours.researching_title.r,TraitBuddy.settings.tooltip.colours.researching_title.g,TraitBuddy.settings.tooltip.colours.researching_title.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			control:AddLine(table.concat(researching, ", "), "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
	--Could be researched
	if #canResearch > 0 and TraitBuddy.settings.tooltip.show.canResearchSection then
		if GamePadMode then
			GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.settings.tooltip.colours.canResearch_title.r,TraitBuddy.settings.tooltip.colours.canResearch_title.g,TraitBuddy.settings.tooltip.colours.canResearch_title.b)
			control:AddLine(GetString(TB_COULD_RESEARCH), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
			control:AddLine(table.concat(canResearch, ", "), GAMEPAD_STYLE_2, control:GetStyle("bodySection"))
		else
			control:AddLine(GetString(TB_COULD_RESEARCH), "TBFontItemCategory", TraitBuddy.settings.tooltip.colours.canResearch_title.r,TraitBuddy.settings.tooltip.colours.canResearch_title.g,TraitBuddy.settings.tooltip.colours.canResearch_title.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			control:AddLine(table.concat(canResearch, ", "), "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end
local function DisplayMotifTooltip(control, itemLink, GamePadMode)
	--Add to the motif tooltips
	local style, chapter, motifOrder, chapterOrder = TraitBuddyData:GetMotifStyle(itemLink)
	if style ~= ITEMSTYLE_NONE then
		local k, d = GetWhoKnowsMotif(motifOrder, chapterOrder)
		if #k>0 or #d>0 then
			if not GamePadMode then
				control:AddVerticalPadding(5)
				ZO_Tooltip_AddDivider(control)
			end
			BuildTooltip(control, k, {}, d, GamePadMode)
		end
	end
end
local function ShowStyle(control, itemLink, GamePadMode)
	local equipType = GetItemLinkEquipType(itemLink)
	if (equipType == EQUIP_TYPE_CHEST
		or equipType == EQUIP_TYPE_FEET
		or equipType == EQUIP_TYPE_HAND
		or equipType == EQUIP_TYPE_HEAD
		or equipType == EQUIP_TYPE_LEGS
		or equipType == EQUIP_TYPE_MAIN_HAND
		or equipType == EQUIP_TYPE_OFF_HAND
		or equipType == EQUIP_TYPE_ONE_HAND
		or equipType == EQUIP_TYPE_SHOULDERS
		or equipType == EQUIP_TYPE_TWO_HAND
		or equipType == EQUIP_TYPE_WAIST) then

		if GamePadMode then
			control:AddLine(zo_iconTextFormatNoSpace("esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds", 42, 42, GetString("SI_ITEMSTYLE", GetItemLinkItemStyle(itemLink))), GAMEPAD_STYLE_2, control:GetStyle("bodySection"))
		else
			local r,g,b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
			control:AddLine(zo_iconTextFormatNoSpace("esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds", 32, 32, GetString("SI_ITEMSTYLE", GetItemLinkItemStyle(itemLink))), "TBFontGame16", r,g,b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end
local function DisplayItemLinkTooltip(control, itemLink, GamePadMode)
	local itemType = GetItemLinkItemType(itemLink)
	if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		DisplayMotifTooltip(control, itemLink, GamePadMode)
		return
	end
	local addStyle = TraitBuddy.settings.tooltip.show.itemStyle
	local traitType, traitText = GetItemLinkTraitInfo(itemLink)
	if IsResearchableTrait(itemType, traitType) then
		local show = false
		for k,id in ipairs(TraitBuddy.soc) do
			if TraitBuddy.settings.characters[id].show then
				show = true
				do break end
			end
		end
		if show then
			--I need 3 things, craftingSkillType, researchLineIndex and traitIndex
			local armorType = GetItemLinkArmorType(itemLink)
			local weaponType = GetItemLinkWeaponType(itemLink)
			local equipType = GetItemLinkEquipType(itemLink)
			local craftingSkillType = ItemToCraftingSkillType(itemType, armorType, weaponType)
			local researchLineIndex = ItemToResearchLineIndex(itemType, armorType, weaponType, equipType)
			local traitIndex = FindTraitIndex(craftingSkillType, researchLineIndex, traitType)

			if not GamePadMode then
				control:AddVerticalPadding(5)
				ZO_Tooltip_AddDivider(control)
			end

			local name, _, _, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			local k, r, d = GetWhoKnows(craftingSkillType, researchLineIndex, traitIndex)
			BuildTooltipTitle(control, name.." - "..GetString("SI_ITEMTRAITTYPE", traitType), GamePadMode)
			if addStyle then
				ShowStyle(control, itemLink, GamePadMode)
				addStyle = false
			end
			BuildTooltip(control, k, r, d, GamePadMode)

			--Additional tooltip info for items
			local c = TraitBuddy.settings.characters[TraitBuddy.characterId]
			if TraitBuddy.settings.tooltip.show.youKnowSection then
				if IsTraitKnown(c, craftingSkillType, researchLineIndex, traitIndex) then
					if GamePadMode then
						GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.colours.you_know.r, TraitBuddy.colours.you_know.g, TraitBuddy.colours.you_know.b)
						control:AddLine(GetString(TB_YOU_KNOW), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
					else
						control:AddLine(GetString(TB_YOU_KNOW), "ZoFontHeader", TraitBuddy.colours.you_know.r, TraitBuddy.colours.you_know.g, TraitBuddy.colours.you_know.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
					end
				elseif IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
					if GamePadMode then
						GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.colours.you_researching.r, TraitBuddy.colours.you_researching.g, TraitBuddy.colours.you_researching.b)
						control:AddLine(GetString(TB_YOU_ARE_RESEARCHING), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
					else
						control:AddLine(GetString(TB_YOU_ARE_RESEARCHING), "ZoFontHeader", TraitBuddy.colours.you_researching.r, TraitBuddy.colours.you_researching.g, TraitBuddy.colours.you_researching.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
					end
				else
					if GamePadMode then
						GAMEPAD_STYLE_1.fontColor = ZO_ColorDef:New(TraitBuddy.colours.you_canResearch.r, TraitBuddy.colours.you_canResearch.g, TraitBuddy.colours.you_canResearch.b)
						control:AddLine(GetString(TB_YOU_COULD_RESEARCH), GAMEPAD_STYLE_1, control:GetStyle("bodySection"))
					else
						control:AddLine(GetString(TB_YOU_COULD_RESEARCH), "ZoFontHeader", TraitBuddy.colours.you_canResearch.r, TraitBuddy.colours.you_canResearch.g, TraitBuddy.colours.you_canResearch.b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
					end
				end
			end
		elseif addStyle then
			if not GamePadMode then
				control:AddVerticalPadding(5)
			end
			ShowStyle(control, itemLink, GamePadMode)
		end
	elseif addStyle then
		if not GamePadMode then
			control:AddVerticalPadding(5)
		end
		ShowStyle(control, itemLink, GamePadMode)
	end
end
local function HookBagTooltip()
	--Inventory, Bank, Guild bank, Guild store sell
	if TraitBuddy.settings.tooltip.show.bag then
		--Non gamepad hook
		local BagItemTooltip = ItemTooltip.SetBagItem
		ItemTooltip.SetBagItem = function(control, bagId, slotIndex, ...)
			BagItemTooltip(control, bagId, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex))
		end
		--Gamepad hook
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LEFT_LayoutBagItem = GP_LEFT.LayoutBagItem
		GP_LEFT.LayoutBagItem = function(control, bagId, slotIndex, ...)
			GP_LEFT_LayoutBagItem(control, bagId, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex), true)
		end
		local GP_RIGHT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
		local GP_RIGHT_LayoutBagItem = GP_RIGHT.LayoutBagItem
		GP_RIGHT.LayoutBagItem = function(control, bagId, slotIndex, ...)
			GP_RIGHT_LayoutBagItem(control, bagId, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetItemLink(bagId, slotIndex), true)
		end
	end
end
local function HookLootTooltip()
	if TraitBuddy.settings.tooltip.show.loot then
		--Non gamepad hook
		local LootItemTooltip = ItemTooltip.SetLootItem
		ItemTooltip.SetLootItem = function(control, lootId, ...)
			LootItemTooltip(control, lootId, ...)
			DisplayItemLinkTooltip(control, GetLootItemLink(lootId))
		end
		--Gamepad hook
		local GP_RIGHT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
		local GP_LayoutItemWithStackCount = GP_RIGHT.LayoutItemWithStackCount
		GP_RIGHT.LayoutItemWithStackCount = function(control, itemLink, ...)
			GP_LayoutItemWithStackCount(control, itemLink, ...)
			if SCENE_MANAGER:IsShowing("lootGamepad") then
				DisplayItemLinkTooltip(control, itemLink, true)
			end
		end
	end
end
local function HookMailTooltip()
	if TraitBuddy.settings.tooltip.show.mail then
		--Non gamepad hook
		local AttachedMailItemTooltip = ItemTooltip.SetAttachedMailItem
		ItemTooltip.SetAttachedMailItem = function(control, openMailId, attachmentIndex, ...)
			AttachedMailItemTooltip(control, openMailId, attachmentIndex, ...)
			DisplayItemLinkTooltip(control, GetAttachedItemLink(openMailId, attachmentIndex))
		end
		--Gamepad hook
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LayoutGenericItem = GP_LEFT.LayoutGenericItem
		GP_LEFT.LayoutGenericItem = function(control, itemLink, ...)
			GP_LayoutGenericItem(control, itemLink, ...)
			if GAMEPAD_MAIL_INBOX_FRAGMENT:IsShowing() then
				DisplayItemLinkTooltip(control, itemLink, true)
			end
		end
	end
end
local function HookBuybackTooltip()
	if TraitBuddy.settings.tooltip.show.buyback then
		--Non gamepad hook
		local BuybackItemTooltip = ItemTooltip.SetBuybackItem
		ItemTooltip.SetBuybackItem = function(control, index, ...)
			BuybackItemTooltip(control, index, ...)
			DisplayItemLinkTooltip(control, GetBuybackItemLink(index))
		end
		--Gamepad hook
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LayoutBuyBackItem = GP_LEFT.LayoutBuyBackItem
		GP_LEFT.LayoutBuyBackItem = function(control, index, ...)
			GP_LayoutBuyBackItem(control, index, ...)
			DisplayItemLinkTooltip(control, GetBuybackItemLink(index), true)
		end
	end
end
local function HookTradeTooltip()
	if TraitBuddy.settings.tooltip.show.trade then
		--Non gamepad hook
		local TradeItemTooltip = ItemTooltip.SetTradeItem
		ItemTooltip.SetTradeItem = function(control, tradeWho, slotIndex, ...)
			TradeItemTooltip(control, tradeWho, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex))
		end
		--Gamepad hook
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LEFT_LayoutTradeItem = GP_LEFT.LayoutTradeItem
		GP_LEFT.LayoutTradeItem = function(control, tradeWho, slotIndex, ...)
			GP_LEFT_LayoutTradeItem(control, tradeWho, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex), true)
		end
		local GP_RIGHT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD3_TOOLTIP)
		local GP_RIGHT_LayoutTradeItem = GP_RIGHT.LayoutTradeItem
		GP_RIGHT.LayoutTradeItem = function(control, tradeWho, slotIndex, ...)
			GP_RIGHT_LayoutTradeItem(control, tradeWho, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetTradeItemLink(tradeWho, slotIndex), true)
		end
	end
end
local function HookTradingHouseTooltip()
	--Guild store search
	if TraitBuddy.settings.tooltip.show.tradingHouse then
		--Non gamepad hook
		local TradingHouseItemTooltip = ItemTooltip.SetTradingHouseItem
		ItemTooltip.SetTradingHouseItem = function(control, tradingHouseIndex, ...)
			TradingHouseItemTooltip(control, tradingHouseIndex, ...)
			DisplayItemLinkTooltip(control, GetTradingHouseSearchResultItemLink(tradingHouseIndex))
		end
	end
	--Guild store my listings
	if TraitBuddy.settings.tooltip.show.tradingHouse then
		local TradingHouseListingTooltip = ItemTooltip.SetTradingHouseListing
		ItemTooltip.SetTradingHouseListing = function(control, tradingHouseListingIndex, ...)
			TradingHouseListingTooltip(control, tradingHouseListingIndex, ...)
			DisplayItemLinkTooltip(control, GetTradingHouseListingItemLink(tradingHouseListingIndex))
		end
	end

	if TraitBuddy.settings.tooltip.show.tradingHouse or TraitBuddy.settings.tooltip.show.tradingHouse then
		--Gamepad hook
		local GP_LEFT = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local GP_LEFT_LayoutItemWithStackCountSimple = GP_LEFT.LayoutItemWithStackCountSimple
		GP_LEFT.LayoutItemWithStackCountSimple = function(control, itemLink, ...)
			GP_LEFT_LayoutItemWithStackCountSimple(control, itemLink, ...)
			DisplayItemLinkTooltip(control, itemLink, true)
		end
	end
end
local function HookChatLinkTooltip()
	if TraitBuddy.settings.tooltip.show.chat then
		local ChatLinkTooltip = PopupTooltip.SetLink
		PopupTooltip.SetLink = function(control, link, ...)
			ChatLinkTooltip(control, link, ...)
			DisplayItemLinkTooltip(control, link, false)
		end
	end
end
local function HookQuestRewardTooltip()
	if TraitBuddy.settings.tooltip.show.quest then
		local QuestRewardTooltip = ItemTooltip.SetQuestReward
		ItemTooltip.SetQuestReward = function(control, rewardIndex, ...)
			QuestRewardTooltip(control, rewardIndex, ...)
			DisplayItemLinkTooltip(control, GetQuestRewardItemLink(rewardIndex))
		end
	end
end
local function HookCraftingTooltip()
	if TraitBuddy.settings.tooltip.show.crafting then
		--Non gamepad hook
		local ResultTooltip = ZO_SmithingTopLevelCreationPanelResultTooltip
		local PendingSmithingItemTooltip = ResultTooltip.SetPendingSmithingItem
		ResultTooltip.SetPendingSmithingItem = function(control, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
			PendingSmithingItemTooltip(control, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
			DisplayItemLinkTooltip(control, GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex))
		end
		--Gamepad hook
		local GP_ResultTooltip = ZO_GamepadSmithingTopLevelCreationResultTooltip.tip
		local GP_LayoutPendingSmithingItem = GP_ResultTooltip.LayoutPendingSmithingItem
		GP_ResultTooltip.LayoutPendingSmithingItem = function(control, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
			GP_LayoutPendingSmithingItem(control, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, ...)
			DisplayItemLinkTooltip(control, GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex+1, traitIndex), true)
		end
	end
end
local function HookWornItemsTooltip()
	if TraitBuddy.settings.tooltip.show.worn then
		local WornItemTooltip = ItemTooltip.SetWornItem
		ItemTooltip.SetWornItem = function(control, slotIndex, ...)
			WornItemTooltip(control, slotIndex, ...)
			DisplayItemLinkTooltip(control, GetItemLink(BAG_WORN, slotIndex))
		end
	end
end
local function UpdateResearchingUI()
	--Add traits being researched to research screen
	local craftingSkillTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}
	for id,c in pairs(TraitBuddy.settings.characters) do
		local control = TBResearch:GetNamedChild("ScrollChild"):GetNamedChild("Character"..id)
		control:SetHidden(not c.show)
	end
	local lastCharacter
	for k,id in ipairs(TraitBuddy.soc) do
		local c = TraitBuddy.settings.characters[id]
		if c.show then
			local character = TBResearch:GetNamedChild("ScrollChild"):GetNamedChild("Character"..id)
			if lastCharacter then
				character:SetAnchor(TOPLEFT, lastCharacter, BOTTOMLEFT, 0, 30)
			end
			for key,craftingSkillType in pairs(craftingSkillTypes) do
				local craft = character:GetNamedChild("P"..craftingSkillType)
				--Hide the previous controls if they existed
				for iControl = 1, 3 do
					local ctrl = craft:GetNamedChild("Research"):GetNamedChild(iControl)
					if ctrl then
						ctrl:SetHidden(true)
					end
				end
				local lastResearch
				local numResearching = 0
				for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
					local _, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
					for traitIndex = 1, numTraits do
						if IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
							numResearching = numResearching + 1
							local researching = craft:GetNamedChild("Research"):GetNamedChild(numResearching)
							if not researching then
								researching = CreateControlFromVirtual("$(parent)", craft:GetNamedChild("Research"), "TB_Researching", numResearching)
							end
							researching:SetHidden(false)
							researching.craftingSkillType = craftingSkillType
							researching.researchLineIndex = researchLineIndex
							researching.traitIndex = traitIndex
							if lastResearch then
								researching:SetAnchor(TOPLEFT, lastResearch, BOTTOMLEFT, 0, 0)
							end
							researching:GetNamedChild("Icon"):SetTexture(icon)
							local timeRemainingSecs = GetDiffBetweenTimeStamps(c.research[craftingSkillType][researchLineIndex][traitIndex].done, GetTimeStamp())
							local timeElapsed = c.research[craftingSkillType][researchLineIndex][traitIndex].duration - timeRemainingSecs
							local now = GetFrameTimeSeconds()
							researching.timer:Start(now - timeElapsed, now + timeRemainingSecs)
							lastResearch = researching
						end
					end
				end
				craft:GetNamedChild("NumResearching"):SetText(numResearching.."/"..c.research[craftingSkillType].MaxSimultaneousResearch)
			end
			lastCharacter = character
		end
	end
end
local function UpdateResearching()
	--Update any traits which were researching that have now finished
	local nextTimeRemainingSecs = nil
	local craftingSkillTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}
	for id,c in pairs(TraitBuddy.settings.characters) do
		for _,craftingSkillType in pairs(craftingSkillTypes) do
			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
				for traitIndex = 1, numTraits do
					if IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
						local timeRemainingSecs = GetDiffBetweenTimeStamps(c.research[craftingSkillType][researchLineIndex][traitIndex].done, GetTimeStamp())
						if timeRemainingSecs <= 0 then
							c.research[craftingSkillType][researchLineIndex][traitIndex] = nil
							c.research[craftingSkillType][researchLineIndex][traitIndex] = true
							UpdateResearchingUI()
						else
							if nextTimeRemainingSecs == nil then
								nextTimeRemainingSecs = timeRemainingSecs
							else
								if timeRemainingSecs < nextTimeRemainingSecs then
									nextTimeRemainingSecs = timeRemainingSecs
								end
							end
						end
					end
				end
			end
		end
	end
	
	--When to update research again
	if nextTimeRemainingSecs then
		local ms = nextTimeRemainingSecs*1000
		--zo_callLater(UpdateResearching, ms)
		EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME.."UpdateResearching")
		EVENT_MANAGER:RegisterForUpdate(ADDON_NAME.."UpdateResearching", ms, function()
			UpdateResearching()
			EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME.."UpdateResearching")
		end)
	end
end
local function UpdateMotifUI()
	--Update the motif screen for the currently selected alt
	--TODO make this faster and more efficient, GetMotifOrder sooner, IsMotifKnown as a version of GetWhoKnowsMotif?
	if TraitBuddy.selectedId then
		local children = TraitBuddy.MotifTree.rootNode:GetChildren()
		if (children) then
			for i = 1, #children do
				if children[i]:IsLeaf() then
					local data = children[i]:GetData()
					local someoneKnows, selectedKnows = IsMotifKnown(TraitBuddyData:GetMotifOrder(data.style))

					local ctrl = children[i]:GetControl()
					ctrl.yes:SetHidden(not someoneKnows)
					ctrl.no:SetHidden(someoneKnows)
					ctrl.no:SetColor(TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b)
					if selectedKnows then
						ctrl.yes:SetColor(TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b)
					elseif someoneKnows then
						ctrl.yes:SetColor(TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b)
					end
				else
					local chapters = children[i]:GetChildren()
					local known = 0
					local othersKnow = 0
					for chapter = 1, #chapters do
						local data = chapters[chapter]:GetData()
						local someoneKnows, selectedKnows = IsMotifKnown(TraitBuddyData:GetMotifOrder(data.style), chapter)

						local ctrl = chapters[chapter]:GetControl()
						ctrl.yes:SetHidden(not someoneKnows)
						ctrl.no:SetHidden(someoneKnows)
						ctrl.no:SetColor(TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b)
						if selectedKnows then
							known = known + 1
							ctrl.yes:SetColor(TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b)
						elseif someoneKnows then
							othersKnow = othersKnow + 1
							ctrl.yes:SetColor(TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b)
						end
					end
					local ctrl = children[i]:GetControl()
					ctrl.yes:SetHidden((known < #chapters) and (othersKnow < #chapters))
					ctrl.no:SetHidden((known > 0) or (known+othersKnow == #chapters))
					ctrl.knowText:SetHidden((known == 0) or (known == #chapters) or (othersKnow == #chapters))
					ctrl.knowText:SetText(known.."/"..#chapters)
					ctrl.no:SetColor(TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b)
					if known == #chapters then
						ctrl.yes:SetColor(TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b)
					else
						ctrl.yes:SetColor(TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b)
					end
				end
			end
		end
	else
		--Disable all the motifs
		local children = TraitBuddy.MotifTree.rootNode:GetChildren()
		if (children) then
			for i = 1, #children do
				local ctrl = children[i]:GetControl()
				ctrl.yes:SetHidden(true)
				ctrl.no:SetHidden(false)
				if not children[i]:IsLeaf() then
					ctrl.knowText:SetHidden(true)
					local chapters = children[i]:GetChildren()
					for chapter = 1, #chapters do
						local ctrl = chapters[chapter]:GetControl()
						ctrl.yes:SetHidden(true)
						ctrl.no:SetHidden(false)
					end
				end
			end
		end
	end
end
local function GetResearchSplit()
	--Calculate the columns for the weapons and armours
	return {
		[CRAFTING_TYPE_BLACKSMITHING] = ItemToResearchLineIndex(ITEMTYPE_ARMOR, ARMORTYPE_HEAVY, 0, EQUIP_TYPE_CHEST),
		[CRAFTING_TYPE_CLOTHIER] = ItemToResearchLineIndex(ITEMTYPE_ARMOR, ARMORTYPE_MEDIUM, 0, EQUIP_TYPE_CHEST),
		[CRAFTING_TYPE_WOODWORKING] = ItemToResearchLineIndex(ITEMTYPE_WEAPON, 0, WEAPONTYPE_SHIELD, 0)
	}
end
local function GetSectionSplitName(craftingSkillType,researchLineIndex)
	local first = {
		[CRAFTING_TYPE_BLACKSMITHING] = "Weapons",
		[CRAFTING_TYPE_CLOTHIER] = "Light",
		[CRAFTING_TYPE_WOODWORKING] = "Weapons"
	}
	local second = {
		[CRAFTING_TYPE_BLACKSMITHING] = "Armour",
		[CRAFTING_TYPE_CLOTHIER] = "Medium",
		[CRAFTING_TYPE_WOODWORKING] = "Shields"
	}
	local researchLineSplit = GetResearchSplit()
	if researchLineIndex > 0 and researchLineIndex < researchLineSplit[craftingSkillType] then
		return first[craftingSkillType]
	else
		return second[craftingSkillType]
	end
end
local function UpdateTotals(craftingSkillType)
	--Setup the totals for a single crafting skill
	local runningTotal = 0
	local section
	local control
	local crafting = TB:GetNamedChild("Crafting")
	local researchLineSplit = GetResearchSplit()
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		if researchLineIndex == 1 then
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(GetSectionSplitName(craftingSkillType,researchLineIndex))
		elseif researchLineIndex == researchLineSplit[craftingSkillType] then
			--First screens grand total
			control = section:GetNamedChild("Headings"):GetNamedChild("Total")
			control:SetText(zo_strformat("<<1>> (<<2>>)", GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS), runningTotal))
			runningTotal = 0
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(GetSectionSplitName(craftingSkillType,researchLineIndex))
		end

		--TODO shouldnt this just be selectedCharacter always?
		local numKnown = 0
		local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			if TraitBuddy.viewingAlt then
				if IsTraitKnown(TraitBuddy.settings.characters[TraitBuddy.selectedId], craftingSkillType, researchLineIndex, traitIndex) then
					numKnown = numKnown + 1
				end
			else
				if IsTraitKnown(TraitBuddy.settings.characters[TraitBuddy.characterId], craftingSkillType, researchLineIndex, traitIndex) then
					numKnown = numKnown + 1
				end
			end
		end

		--Traits known total
		control = section:GetNamedChild("Column"..researchLineIndex):GetNamedChild("Total")
		control:SetText(numKnown)
		runningTotal = runningTotal + numKnown
	end
	
	--Seconds screens grand total
	if section then
		control = section:GetNamedChild("Headings"):GetNamedChild("Total")
		control:SetText(zo_strformat("<<1>> (<<2>>)", GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS), runningTotal))
	end
end
local function GetNumResearching(craftingSkillType)
	--How many traits is this character researching
	local numResearching = 0
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			--TODO shouldnt this alwasys be from the settings?
			--Is the trait currently being researched
			if TraitBuddy.viewingAlt then
				if IsTraitBeingResearched(TraitBuddy.settings.characters[TraitBuddy.selectedId], craftingSkillType, researchLineIndex, traitIndex) then
					numResearching = numResearching + 1
				end
			else
				local durationSecs, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
				if durationSecs then
					numResearching = numResearching + 1
				end
			end
		end
	end
	return numResearching
end
local function UpdateNumResearching()
	--Update the number of items being researched
	TB_MaxResearch_Icon:SetColor(TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b)
	local craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(TBHeadingCraftMenuBar)
	if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING or craftingSkillType == CRAFTING_TYPE_CLOTHIER or craftingSkillType == CRAFTING_TYPE_WOODWORKING then
		--TODO shouldnt this always be from the settings?
		local maxResearch = 0
		if TraitBuddy.viewingAlt then
			if TraitBuddy.selectedId then
				maxResearch = TraitBuddy.settings.characters[TraitBuddy.selectedId].research[craftingSkillType].MaxSimultaneousResearch
			end
		else
			maxResearch = GetMaxSimultaneousSmithingResearch(craftingSkillType)
		end
		--This isn't ... but Unicode horizontal ellipse
		TB_MaxResearch:SetText(GetString(SI_SMITHING_RESEARCH_IN_PROGRESS):gsub("\226\128\166$", ": ")..GetNumResearching(craftingSkillType).."/"..maxResearch)
	end
end
local function UpdateUI(craftingSkillType)
	--Update the known traits, traits being researched and traits known by alts
	local section
	local crafting = TB:GetNamedChild("Crafting")
	local researchLineSplit = GetResearchSplit()
	for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
		if researchLineIndex == 1 or researchLineIndex == researchLineSplit[craftingSkillType] then
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(GetSectionSplitName(craftingSkillType,researchLineIndex))
		end
		local column = section:GetNamedChild("Column"..researchLineIndex)
		
		local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
		for traitIndex = 1, numTraits do
			local someoneKnows, selectedKnows, someoneResearching, selectedResearching = IsTraitKnown2(craftingSkillType, researchLineIndex, traitIndex)
			local trait = column.container:GetNamedChild("Trait"..traitIndex)
			--trait.yes:SetHidden(not someoneKnows or someoneResearching)
			--trait.research:SetHidden(not someoneKnows or someoneResearching)
			--trait.no:SetHidden(not someoneKnows or someoneResearching)
			
			if selectedKnows then
				trait.yes:SetColor(TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b)
			else
				trait.yes:SetColor(TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b)
			end
			if selectedResearching then
				trait.research:SetColor(TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b)
			else
				trait.research:SetColor(TraitBuddy.settings.colours.others_researching.r, TraitBuddy.settings.colours.others_researching.g, TraitBuddy.settings.colours.others_researching.b)
			end
			trait.no:SetColor(TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b)
			
			--Longer old style for now, get it working
			if selectedKnows then
				trait.yes:SetHidden(false)
				trait.no:SetHidden(true)
				trait.research:SetHidden(true)
			elseif selectedResearching then
				trait.yes:SetHidden(true)
				trait.no:SetHidden(true)
				trait.research:SetHidden(false)
			else
				if someoneKnows then
					trait.yes:SetHidden(false)
					trait.no:SetHidden(true)
					trait.research:SetHidden(true)
				elseif someoneResearching then
					trait.yes:SetHidden(true)
					trait.no:SetHidden(true)
					trait.research:SetHidden(false)
				else
					trait.yes:SetHidden(true)
					trait.no:SetHidden(false)
					trait.research:SetHidden(true)
				end
			end
		end
	end
	
	UpdateNumResearching()
	UpdateTotals(craftingSkillType)
end
local function GetApparelData()
	-- With no idea which apparel button is selected
	local data = {
		descriptor = 0,
		label = ""
	}
	local craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(TBHeadingCraftMenuBar)
	if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING then
		data.descriptor = ZO_MenuBar_GetSelectedDescriptor(TB_Apparel1ApparelBar)
		if data.descriptor == 1 then
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_WEAPON))
		else
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_HEAVY))
		end
	elseif craftingSkillType == CRAFTING_TYPE_CLOTHIER then
		data.descriptor = ZO_MenuBar_GetSelectedDescriptor(TB_Apparel2ApparelBar)
		if data.descriptor == 1 then
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_LIGHT))
		else
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_MEDIUM))
		end
	elseif craftingSkillType == CRAFTING_TYPE_WOODWORKING then
		data.descriptor = ZO_MenuBar_GetSelectedDescriptor(TB_Apparel6ApparelBar)
		if data.descriptor == 1 then
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_WEAPON))
		else
			data.label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD))
		end
	end
	
	return data
end
local function OnResearchSelect(data)
	TBCrafting:SetHidden(true)
	TBAlts:SetHidden(true)
	TBMotifs:SetHidden(true)
	TBHeadingProf:SetText(data.label)
	TBResearch:SetHidden(false)
end
local function OnMotifSelect(data)
	TBCrafting:SetHidden(true)
	TBAlts:SetHidden(false)
	TBMotifs:SetHidden(false)
	TBHeadingProf:SetText(data.label)
	TBResearch:SetHidden(true)
end
local function OnApparelSelect(data)
	local craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(TBHeadingCraftMenuBar)
	TB_Apparel:SetText(data.label)
	TBCrafting1Weapons:SetHidden(not (craftingSkillType == CRAFTING_TYPE_BLACKSMITHING and data.descriptor == 1))
	TBCrafting1Armour:SetHidden(not (craftingSkillType == CRAFTING_TYPE_BLACKSMITHING and data.descriptor == 2))
	TBCrafting2Light:SetHidden(not (craftingSkillType == CRAFTING_TYPE_CLOTHIER and data.descriptor == 1))
	TBCrafting2Medium:SetHidden(not (craftingSkillType == CRAFTING_TYPE_CLOTHIER and data.descriptor == 2))
	TBCrafting6Weapons:SetHidden(not (craftingSkillType == CRAFTING_TYPE_WOODWORKING and data.descriptor == 1))
	TBCrafting6Shields:SetHidden(not (craftingSkillType == CRAFTING_TYPE_WOODWORKING and data.descriptor == 2))
end
local function OnCraftSelect(data)
	TBCrafting:SetHidden(false)
	TBAlts:SetHidden(false)
	TBMotifs:SetHidden(true)
	TBHeadingProf:SetText(data.label)
	TBResearch:SetHidden(true)
	TBCrafting1:SetHidden(data.descriptor ~= CRAFTING_TYPE_BLACKSMITHING)
	TBCrafting2:SetHidden(data.descriptor ~= CRAFTING_TYPE_CLOTHIER)
	TBCrafting6:SetHidden(data.descriptor ~= CRAFTING_TYPE_WOODWORKING)
	
	UpdateNumResearching()
	
	TB_Apparel1:SetHidden(data.descriptor ~= CRAFTING_TYPE_BLACKSMITHING)
	TB_Apparel2:SetHidden(data.descriptor ~= CRAFTING_TYPE_CLOTHIER)
	TB_Apparel6:SetHidden(data.descriptor ~= CRAFTING_TYPE_WOODWORKING)
	
	--Ensure when switching crafting types the selected weapons or armour update as well
	OnApparelSelect(GetApparelData())
end
local function OnStyleLearned(eventCode, styleIndex, chapterIndex)
	local c = TraitBuddy.settings.characters[TraitBuddy.characterId]
	local _, _, _, _, itemStyle, _ = GetSmithingStyleItemInfo(styleIndex)
	local order = TraitBuddyData:GetMotifOrder(itemStyle)
	if order then
		if TraitBuddyData:MotifHasChapters(order) then
			if chapterIndex == ITEM_STYLE_CHAPTER_ALL then
				--Learned from all in one motif (crown store or looted book)
				for chapter = 1, TraitBuddyData:GetNumChapters() do
					c.motifs[order][chapter] = true
				end
			else
				local chapter = TraitBuddyData:GetChapterOrder(chapterIndex)
				c.motifs[order][chapter] = true
			end
		else
			c.motifs[order] = true
		end
	end
	UpdateMotifUI()
end
local function OnResearchCompleted(eventCode, craftingSkillType, researchLineIndex, traitIndex)
	local c = TraitBuddy.settings.characters[TraitBuddy.characterId]
	if IsTraitBeingResearched(c, craftingSkillType, researchLineIndex, traitIndex) then
		c.research[craftingSkillType][researchLineIndex][traitIndex] = nil
	end
	c.research[craftingSkillType][researchLineIndex][traitIndex] = true
	UpdateUI(craftingSkillType)
	UpdateResearching()
	UpdateResearchingUI()
end
local function OnResearchStarted(eventCode, craftingSkillType, researchLineIndex, traitIndex)
	local durationSecs, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
	--durationSecs, timeRemainingSecs: both = the same time
	TraitBuddy.settings.characters[TraitBuddy.characterId].research[craftingSkillType][researchLineIndex][traitIndex] = { duration = durationSecs, done = GetTimeStamp() + timeRemainingSecs }
	UpdateUI(craftingSkillType)
	UpdateResearching()
	UpdateResearchingUI()
end
local function OnSkillPointsChanged(eventCode, oldPoints, newPoints, oldPartialPoints, newPartialPoints)
	if oldPoints ~= newPoints then
		local craftingSkillType = ZO_MenuBar_GetSelectedDescriptor(TBHeadingCraftMenuBar)
		if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING or craftingSkillType == CRAFTING_TYPE_CLOTHIER or craftingSkillType == CRAFTING_TYPE_WOODWORKING then
			TraitBuddy.settings.characters[TraitBuddy.characterId].research[craftingSkillType].MaxSimultaneousResearch = GetMaxSimultaneousSmithingResearch(craftingSkillType)
			UpdateResearch() --Points spent in reducing research times skills reduce the time immediately
		end
		UpdateNumResearching()
		UpdateResearching()
		UpdateResearchingUI()
	end
end
local function DynamicClassInfo(id)
	--Try to dynamically get class information
	for i = 1, GetNumCharacters() do
		local _, gender, _, classId, raceId, _, thisID, _ = GetCharacterInfo(i)
		if id == thisID then
			return {classId=classId, raceId=raceId, gender=gender}
		end
	end
	return {classId=0, raceId=0, gender=0}
end
local function OnAltSelected(comboBox, characterName, item, selectionChanged)
	if selectionChanged then
		TraitBuddy.selectedId = item.selectedId
		TraitBuddy.viewingAlt = TraitBuddy.selectedId ~= TraitBuddy.characterId
		local alt = TBAlts:GetNamedChild("Alternative")
		alt:GetNamedChild("Name"):SetText(characterName)
		ZO_MenuBar_SelectDescriptor(alt:GetNamedChild("Bar"), TraitBuddy.selectedId, false)
		
		UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
		UpdateUI(CRAFTING_TYPE_CLOTHIER)
		UpdateUI(CRAFTING_TYPE_WOODWORKING)
		UpdateMotifUI()
	end
end
local function AltsDropdown_SelectCharacter(selectId)
	local item = nil
	if TraitBuddy.settings.characters[selectId] and TraitBuddy.settings.characters[selectId].show then
		item = ZO_ComboBox:CreateItemEntry(TraitBuddy.settings.characters[selectId].name, OnAltSelected)
		item.selectedId = selectId
	else
		--Character you want to select is excluded or all characters have been excluded. Find one we can select
		for id,c in pairs(TraitBuddy.settings.characters) do
			if c.show then
				item = ZO_ComboBox:CreateItemEntry(c.name, OnAltSelected)
				item.selectedId = id
				do break end
			end
		end
	end
	if item then
		ZO_ComboBox_ObjectFromContainer(TBAlts:GetNamedChild("Dropdown")):SelectItem(item)
	end
end
local function AltsMenuBar_Build()
	--Build the alternative character menu bar
	local bar = TBAlts:GetNamedChild("Alternative"):GetNamedChild("Bar")
	ZO_MenuBar_ClearButtons(bar)
	--Build a list of class icons
	local classIcons = {}
	for i = 0, GetNumClasses() do
		local classId, lore, normalIcon, pressedIcon, mouseoverIcon, isSelectable, ingameIcon = GetClassInfo(i)
		classIcons[classId] = {
			normalIcon=normalIcon,
			pressedIcon=pressedIcon,
			mouseoverIcon=mouseoverIcon
		}
	end
	local className
	local raceName
	local ci
	for k,id in ipairs(TraitBuddy.soc) do
		local c = TraitBuddy.settings.characters[id]
		if c.show then
			local class = DynamicClassInfo(id)
			if class.classId > 0 then
				className = zo_strformat(SI_CLASS_NAME, GetClassName(class.gender, class.classId))
				raceName = zo_strformat(SI_RACE_NAME, GetRaceName(class.gender, class.raceId))
				ci = classIcons[class.classId]
			else
				className = "?"
				raceName = "?"
				ci = classIcons[0]
			end
			local data = {
				descriptor = id,
				normal = ci.normalIcon,
				pressed = ci.pressedIcon,
				highlight = ci.mouseoverIcon,
				callback = function(tabData)
					if TraitBuddy.selectedId ~= tabData.descriptor then
						AltsDropdown_SelectCharacter(tabData.descriptor)
					end
				end,
				className = className,
				raceName = raceName
			}
			ZO_MenuBar_AddButton(bar, data)
		end
	end
	ZO_MenuBar_UpdateButtons(bar, false)
end
local function AltsDropdown_Build()
	--Build or re-build the character dropdown
	local combobox = ZO_ComboBox_ObjectFromContainer(TBAlts:GetNamedChild("Dropdown"))
	combobox:ClearItems()
	for k,id in ipairs(TraitBuddy.soc) do
		local c = TraitBuddy.settings.characters[id]
		if c.show then
			local item = ZO_ComboBox:CreateItemEntry(c.name, OnAltSelected)
			item.selectedId = id
			combobox:AddItem(item, ZO_COMBOBOX_SUPRESS_UPDATE)
		end
	end
	combobox:UpdateItems()
	AltsDropdown_SelectCharacter(TraitBuddy.characterId)
end
local function Alts_ShowSelection()
	TBAlts:GetNamedChild("Dropdown"):SetHidden(TraitBuddy.settings.alternativeSelection)
	TBAlts:GetNamedChild("Alternative"):SetHidden(not TraitBuddy.settings.alternativeSelection)
end
local function TreeHeaderSetup(node, control, data, open)
	if not control.data then
		control.data = data
		local link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,data.id,data.quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		local ctrl = control:GetNamedChild("Text")
		local linkName = zo_strformat("<<1>>", GetItemLinkName(link))
		local toFind = tostring(TraitBuddyData:GetMotifOrder(data.style))
		local found, findStart, findEnd = zo_plainstrfind(linkName, toFind)
		if found then
			linkName = zo_strsub(linkName, findStart)
		end
		ctrl:SetText(linkName)
		local c = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
		ZO_CheckButtonLabel_SetDefaultColors(ctrl, c, c:Lerp(ZO_ColorDef:New(1, 1, 1, 1), 0.5))
		ZO_CheckButtonLabel_ColorText(ctrl, false)
		control:GetNamedChild("Icon"):SetTexture(data.icon)
		
		local material = TraitBuddyData:GetItemStyleMaterial(data.style)
		link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,material.id,30,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		ctrl = control:GetNamedChild("Material")
		ctrl:SetTexture(material.icon)
		ctrl:SetHandler("OnMouseEnter", function(self)
			InitializeTooltip(ItemTooltip, self, LEFT, 5, 0)
			ItemTooltip:SetLink(link)
		end)
		ctrl:SetHandler("OnMouseExit", function(self)
			ClearTooltip(ItemTooltip)
		end)
	end
end
local function TreeEntrySetup(node, control, data, open)
	if not control.data then
		control.data = data
		local link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,data.id,data.quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		local linkName = zo_strformat("<<1>>", GetItemLinkName(link))
		local toFind = zo_strformat("<<1>>, ", TraitBuddyData:GetMotifOrder(data.style))
		local found, findStart, findEnd = zo_plainstrfind(linkName, toFind)
		if found then
			linkName = zo_strsub(linkName, findEnd)
		end
		local ctrl = control:GetNamedChild("Text")
		ctrl:SetText(linkName)
		local c = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality))
		ZO_CheckButtonLabel_SetDefaultColors(ctrl, c, c:Lerp(ZO_ColorDef:New(1, 1, 1, 1), 0.5))
		ZO_CheckButtonLabel_ColorText(ctrl, false)
	end
end
local function TreeEntryEquality(left, right)
	return left.data.id == right.data.id
end
local function CreateUI()
	--Create the static UI elements
	
	--Calculate the columns for the weapons and armours
	local researchLineSplit = GetResearchSplit()
	--Build a list of trait icons
	local traitIcons = {}
	local traitMaterialIds = TraitBuddyData:GetTraitMaterialIDs()
	for traitIndex = 1, GetNumSmithingTraitItems() do
		local traitType, name, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitIndex) --itemStyle is zero
		if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
			traitIcons[traitType] = icon
		end
	end
	
	--Create trait ui v2
	local crafting = TB:GetNamedChild("Crafting")
	local craftingSkillTypes = {CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}
	for key,craftingSkillType in pairs(craftingSkillTypes) do
		local section, headings
		--Create the headings
		for _,researchLineIndex in pairs({1, researchLineSplit[craftingSkillType]}) do
			local _, _, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			
			section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(GetSectionSplitName(craftingSkillType,researchLineIndex))
			headings = CreateControlFromVirtual("$(parent)Headings", section, "TB_TraitColumn_Headings")
			
			local lastHeading
			for traitIndex = 1, numTraits do
				local traitType, traitDescription, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
				
				local heading = CreateControlFromVirtual("$(parent)Heading", headings.container, "TB_TraitColumn_Heading", traitIndex)
				if lastHeading then
					heading:SetAnchor(TOP, lastHeading, BOTTOM, 0, 0)
				end
				heading.displayName = GetString("SI_ITEMTRAITTYPE", traitType)
				heading.description = traitDescription
				heading.materialItemID = traitMaterialIds[traitType]
				heading:GetNamedChild("Name"):SetText(heading.displayName)
				heading:GetNamedChild("Material"):SetTexture(traitIcons[traitType])
				lastHeading = heading
			end
		end
		
		--Create the traits
		local lastColumn
		for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
			local name, icon, numTraits, _ = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
			
			if researchLineIndex == 1 or researchLineIndex == researchLineSplit[craftingSkillType] then
				section = crafting:GetNamedChild(craftingSkillType):GetNamedChild(GetSectionSplitName(craftingSkillType,researchLineIndex))
				lastColumn = section:GetNamedChild("Headings")
			end

			--Create the next column
			local column = CreateControlFromVirtual("$(parent)Column", section, "TB_TraitColumn_Traits", researchLineIndex)
			column:SetAnchor(TOPLEFT, lastColumn, TOPRIGHT, 0, 0)
			--Column heading picture
			column.heading.displayName = name
			column.heading:SetTexture(icon)
			
			local lastTrait
			for traitIndex = 1, numTraits do
				local trait = CreateControlFromVirtual("$(parent)Trait", column.container, "TB_Trait", traitIndex)
				if lastTrait then
					trait:SetAnchor(TOP, lastTrait, BOTTOM, 0, 0)
				end
				trait.craftingSkillType = craftingSkillType
				trait.researchLineIndex = researchLineIndex
				trait.traitIndex = traitIndex
				lastTrait = trait
			end
			
			lastColumn = column
		end
	end
	
	--Create menu bar and buttons for crafting professions
	local menuBar = CreateControlFromVirtual("$(parent)CraftMenuBar", TBHeading, "ZO_MenuBarTemplate")
	menuBar:SetAnchor(RIGHT, TBHeading, RIGHT, -20, 0)
	local data = {
		buttonPadding = 15,
		normalSize = 64,
		downSize = 74
	}
	ZO_MenuBar_SetData(menuBar, data)
	data = {
		descriptor = CRAFTING_TYPE_BLACKSMITHING,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_over.dds",
		callback = OnCraftSelect,
		label = zo_strformat(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING))
	}
	ZO_MenuBar_AddButton(menuBar, data)
	data = {
		descriptor = CRAFTING_TYPE_CLOTHIER,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_over.dds",
		callback = OnCraftSelect,
		label = zo_strformat(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER))
	}
	ZO_MenuBar_AddButton(menuBar, data)
	data = {
		descriptor = CRAFTING_TYPE_WOODWORKING,
		normal = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_down.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_over.dds",
		callback = OnCraftSelect,
		label = zo_strformat(SI_ABILITY_NAME, ZO_GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING))
	}
	ZO_MenuBar_AddButton(menuBar, data)
	data = {
		descriptor = "motifs",
		normal = "esoui/art/mainmenu/menubar_journal_up.dds",
		pressed = "esoui/art/mainmenu/menubar_journal_down.dds",
		disabled = "esoui/art/mainmenu/menubar_journal_disabled.dds",
		highlight = "esoui/art/mainmenu/menubar_journal_over.dds",
		callback = OnMotifSelect,
		label = GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)
	}
	ZO_MenuBar_AddButton(menuBar, data)
	data = {
		descriptor = "research",
		normal = "esoui/art/crafting/smithing_tabicon_research_up.dds",
		pressed = "esoui/art/crafting/smithing_tabicon_research_down.dds",
		disabled = "esoui/art/crafting/smithing_tabicon_research_disabled.dds",
		highlight = "esoui/art/crafting/smithing_tabicon_research_over.dds",
		callback = OnResearchSelect,
		label = GetString(SI_SMITHING_TAB_RESEARCH)
	}
	ZO_MenuBar_AddButton(menuBar, data)
	
	--Create menu bar and buttons for blacksmith weapons and armour
	local bsApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel1, "ZO_MenuBarTemplate")
	bsApparel:SetAnchor(RIGHT, TB_Apparel1, RIGHT, 0, 0)
	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	ZO_MenuBar_SetData(bsApparel, data)
	data = {
		descriptor = 1,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_WEAPON))
	}
	ZO_MenuBar_AddButton(bsApparel, data)
	data = {
		descriptor = 2,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_HEAVY))
	}
	ZO_MenuBar_AddButton(bsApparel, data)
	
	--Create menu bar and buttons for clothing armours
	local clApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel2, "ZO_MenuBarTemplate")
	clApparel:SetAnchor(RIGHT, TB_Apparel2, RIGHT, 0, 0)
	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	ZO_MenuBar_SetData(clApparel, data)
	data = {
		descriptor = 1,
		normal = "TraitBuddy/media/light_up.dds",
		pressed = "TraitBuddy/media/light_down.dds",
		disabled = "TraitBuddy/media/light_up.dds",
		highlight = "TraitBuddy/media/light_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_LIGHT))
	}
	ZO_MenuBar_AddButton(clApparel, data)
	data = {
		descriptor = 2,
		normal = "TraitBuddy/media/medium_up.dds",
		pressed = "TraitBuddy/media/medium_down.dds",
		disabled = "TraitBuddy/media/medium.dds_up",
		highlight = "TraitBuddy/media/medium_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_MEDIUM))
	}
	ZO_MenuBar_AddButton(clApparel, data)
	
	--Create menu bar and buttons for woodworking weapons and shields
	local wwApparel = CreateControlFromVirtual("$(parent)ApparelBar", TB_Apparel6, "ZO_MenuBarTemplate")
	wwApparel:SetAnchor(RIGHT, TB_Apparel6, RIGHT, 0, 0)
	data = {
		buttonPadding = 15,
		normalSize = 54,
		downSize = 64
	}
	ZO_MenuBar_SetData(wwApparel, data)
	data = {
		descriptor = 1,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ITEM_TYPE_WEAPON))
	}
	ZO_MenuBar_AddButton(wwApparel, data)
	data = {
		descriptor = 2,
		normal = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
		pressed = "EsoUI/Art/Inventory/inventory_tabIcon_armor_down.dds",
		disabled = "EsoUI/Art/Inventory/inventory_tabIcon_armor_disabled.dds",
		highlight = "EsoUI/Art/Inventory/inventory_tabIcon_armor_over.dds",
		callback = OnApparelSelect,
		label = zo_strformat("<<1>>", GetString(SI_TRADING_HOUSE_BROWSE_ARMOR_TYPE_SHIELD))
	}
	ZO_MenuBar_AddButton(wwApparel, data)
	
	ZO_MenuBar_SelectDescriptor(TB_Apparel6ApparelBar, 1, true)
	ZO_MenuBar_SelectDescriptor(TB_Apparel2ApparelBar, 1, true)
	ZO_MenuBar_SelectDescriptor(TB_Apparel1ApparelBar, 1, true)
	ZO_MenuBar_SelectDescriptor(menuBar, CRAFTING_TYPE_BLACKSMITHING, true)
	
	--Create the motif tree
	TraitBuddy.MotifTree = ZO_Tree:New(TBMotifs:GetNamedChild("ScrollChild"), 0, 0, 500)
	TraitBuddy.MotifTree:SetOpenAnimation("ZO_TreeOpenAnimation")
	TraitBuddy.MotifTree:AddTemplate("TB_MotifChildlessHeader", TreeHeaderSetup, nil, nil, 0, 0)
	TraitBuddy.MotifTree:AddTemplate("TB_MotifHeader", TreeHeaderSetup, nil, nil, 0, 0)
	TraitBuddy.MotifTree:AddTemplate("TB_MotifEntry", TreeEntrySetup, nil, TreeEntryEquality, 50, 0)
	local motifs = TraitBuddyData:GetMotifs()
	local keys = {}
	for k in pairs(motifs) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for i=1, #keys do
		local motif = motifs[keys[i]]
		if TraitBuddyData:MotifHasChapters(keys[i]) then
			local header = TraitBuddy.MotifTree:AddNode("TB_MotifHeader", {id=motif.id, quality=motif.quality, style=motif.style, icon=motif.icon}, nil, SOUNDS.JOURNAL_PROGRESS_CATEGORY_SELECTED)
			for j = 1, TraitBuddyData:GetNumChapters() do
				TraitBuddy.MotifTree:AddNode("TB_MotifEntry", {id=motif[j], quality=motif.quality, style=motif.style}, header, nil)
			end
		else 
			TraitBuddy.MotifTree:AddNode("TB_MotifChildlessHeader", {id=motif.id, quality=motif.quality, style=motif.style, icon=motif.icon}, nil, nil)
		end
	end
	
	--Create the research section
	local parent = TBResearch:GetNamedChild("ScrollChild")
	for id,c in pairs(TraitBuddy.settings.characters) do
		local control = CreateControlFromVirtual("$(parent)Character", parent, "TB_ResearchCharacter", id)
		control:GetNamedChild("Name"):SetText(c.name)
	end

	--Alternative alt selection. Let the original drop down deal with the selection
	local altBar = TBAlts:GetNamedChild("Alternative"):GetNamedChild("Bar")
	data = {
		buttonPadding = 4,
		normalSize = 30,
		downSize = 40,
		buttonTemplate = "TB_AltsMenuBarButton"
	}
	ZO_MenuBar_SetData(altBar, data)

	AltsMenuBar_Build()
	AltsDropdown_Build()
	Alts_ShowSelection()
	UpdateResearchingUI()
end
local function SetWindowPosition()
	TB:ClearAnchors()
	TB:SetAnchor(TOPLEFT, nil, TOPLEFT, TraitBuddy.settings.x, TraitBuddy.settings.y)
end
local function DefaultSettings()
	local defaults = {
		tooltip = {
			show = {
				knowSection = true,
				researchingSection = true,
				canResearchSection = true,
				youKnowSection = true,
				bag = true,
				loot = true,
				mail = true,
				buyback = true,
				trade = true,
				tradingHouse = true,
				chat = true,
				quest = true,
				crafting = true,
				worn = true,
				itemStyle = true
			},
			colours = {
				know_title = {
					r = 0,
					g = 1,
					b = 0
				},
				researching_title = {
					r = 0.25,
					g = 0.5,
					b = 1
				},
				canResearch_title = {
					r = 1,
					g = 1,
					b = 0
				}
			},
		},
		colours = {
			know = {
				r = 0,
				g = 1,
				b = 0
			},
			researching = {
				r = 0.25,
				g = 0.5,
				b = 1
			},
			others_know = {
				r = 1,
				g = 1,
				b = 0
			},
			others_researching = {
				r = 1,
				g = 0.65,
				b = 0
			},
			not_known = {
				r = 1,
				g = 0.2,
				b = 0.2
			}
		},
		characters = {},
		alternativeSelection = false,
		locked = true,
		x = 260,
		y = 115
	}
	return defaults
end
local function DeleteCharacter(id, checkbox)
	TraitBuddy.settings.characters[id] = nil
	SortCharacters()
	--Update the ui, these handle changing and selecting the alt, and updating the UI
	AltsMenuBar_Build()
	AltsDropdown_Build()
	local character = TBResearch:GetNamedChild("ScrollChild"):GetNamedChild("Character"..id)
	if character then
		character:SetHidden(true)
	end
	UpdateResearchingUI()
	checkbox.deleteMe:SetHidden(true)
end
local function OnSettingsControlsCreated(panel)
	--Settings controls created once. Using the normal LAM controls create a check box(text) with a button next to it
	local parent = GetControl("TBSettingsCharacters")
	if parent then
		local lastCharacter
		for k,id in ipairs(TraitBuddy.soc) do
			local c = TraitBuddy.settings.characters[id]
			local data = {
				type = "checkbox",
				name = c.name,
				tooltip = zo_strformat(TB_OP_SHOW_TT, c.name),
				getFunc = function()
					if TraitBuddy.settings.characters[id] then
						return c.show
					else
						return false
					end
				end,
				setFunc = function(value)
					if TraitBuddy.settings.characters[id] then
						c.show = value
						AltsMenuBar_Build()
						AltsDropdown_Build()
						UpdateResearchingUI()
					end
				end,
				default = true,
				disabled = function()
					if TraitBuddy.settings.characters[id] then
						return false
					else
						return true
					end
				end
			}
			local check = LAMCreateControl.checkbox(parent, data, nil)			
			if lastCharacter then
				check:SetAnchor(TOPLEFT, lastCharacter, BOTTOMLEFT, 0, 5)
			else
				check:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
			end
			
			data = {
				type = "button",
				name = SI_KEYCODEDELETE,
				tooltip = zo_strformat(TB_OP_DELETE_TT, ADDON_NAME, c.name),
				func = function() DeleteCharacter(id, check) end
			}
			check.deleteMe = LAMCreateControl.button(parent, data, nil)
			check.deleteMe:SetAnchor(RIGHT, check, RIGHT, 0, 0)
			check.deleteMe:SetMouseEnabled(false)
			local w = check.deleteMe.button:GetWidth() - 50
			check.deleteMe.button:SetWidth(w)

			lastCharacter = check
		end
	end
end
local function CreateSettingsMenu()
	--Settings menu
	local defaults = DefaultSettings()
	
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = "|cff8800"..ADDON_NAME.."|r",
		author = "Weolo",
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/tboptions",
		website = "http://www.esoui.com/downloads/info1058-TraitBuddy.html"
	}
	LAM:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsData = {
		{
			type = "header",
			name = "|c3f7fff"..GetString(TB_OP_HEADING1).."|r"
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_BAG),
			tooltip = GetString(TB_OP_BAG_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.bag end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.bag = value end,
			default = defaults.tooltip.show.bag,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_LOOT),
			tooltip = GetString(TB_OP_LOOT_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.loot end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.loot = value end,
			default = defaults.tooltip.show.loot,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_MAIL),
			tooltip = GetString(TB_OP_MAIL_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.mail end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.mail = value end,
			default = defaults.tooltip.show.mail,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_BUYBACK),
			tooltip = GetString(TB_OP_BUYBACK_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.buyback end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.buyback = value end,
			default = defaults.tooltip.show.buyback,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_TRADE),
			tooltip = GetString(TB_OP_TRADE_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.trade end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.trade = value end,
			default = defaults.tooltip.show.trade,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_TRADINGHOUSE),
			tooltip = GetString(TB_OP_TRADINGHOUSE_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.tradingHouse end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.tradingHouse = value end,
			default = defaults.tooltip.show.tradingHouse,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_CHAT),
			tooltip = GetString(TB_OP_CHAT_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.chat end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.chat = value end,
			default = defaults.tooltip.show.chat,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_QUEST),
			tooltip = GetString(TB_OP_QUEST_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.quest end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.quest = value end,
			default = defaults.tooltip.show.quest,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_CRAFTING),
			tooltip = GetString(TB_OP_CRAFTING_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.crafting end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.crafting = value end,
			default = defaults.tooltip.show.crafting,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_WORN),
			tooltip = GetString(TB_OP_WORN_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.worn end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.worn = value end,
			default = defaults.tooltip.show.worn,
			warning = TB_OP_RELOAD
		},
		{
			type = "header",
			name = "|c3f7fff"..GetString(TB_OP_HEADING2).."|r"
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_STYLE),
			tooltip = GetString(TB_OP_STYLE_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.itemStyle end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.itemStyle = value end,
			default = TraitBuddy.settings.tooltip.show.itemStyle
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_KNOWN),
			tooltip = GetString(TB_OP_KNOWN_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.knowSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.knowSection = value end,
			default = defaults.tooltip.show.knowSection
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_KNOWN_COLOUR),
			tooltip = GetString(TB_OP_KNOWN_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.know_title.r, TraitBuddy.settings.tooltip.colours.know_title.g, TraitBuddy.settings.tooltip.colours.know_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.know_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.know_title
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_RESEARCHING),
			tooltip = GetString(TB_OP_RESEARCHING_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.researchingSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.researchingSection = value end,
			default = defaults.tooltip.show.researchingSection
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_RESEARCHING_COLOUR),
			tooltip = GetString(TB_OP_RESEARCHING_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.researching_title.r, TraitBuddy.settings.tooltip.colours.researching_title.g, TraitBuddy.settings.tooltip.colours.researching_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.researching_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.researching_title
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_CANRESEARCH),
			tooltip = GetString(TB_OP_CANRESEARCH_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.canResearchSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.canResearchSection = value end,
			default = defaults.tooltip.show.canResearchSection
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_CANRESEARCH_COLOUR),
			tooltip = GetString(TB_OP_CANRESEARCH_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.canResearch_title.r, TraitBuddy.settings.tooltip.colours.canResearch_title.g, TraitBuddy.settings.tooltip.colours.canResearch_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.canResearch_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.canResearch_title
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_YOUKNOW),
			tooltip = GetString(TB_OP_YOUKNOW_TT),
			getFunc = function() return TraitBuddy.settings.tooltip.show.youKnowSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.youKnowSection = value end,
			default = defaults.tooltip.show.youKnowSection
		},
		{
			type = "header",
			name = "|c3f7fff"..GetString(TB_OP_HEADING5).."|r"
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_UI_KNOW_COLOUR),
			tooltip = GetString(TB_OP_UI_KNOW_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.know = {r=r,g=g,b=b}
				UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				UpdateUI(CRAFTING_TYPE_CLOTHIER)
				UpdateUI(CRAFTING_TYPE_WOODWORKING)
				UpdateMotifUI()
			end,
			default = defaults.colours.know
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_UI_RESEARCHING_COLOUR),
			tooltip = GetString(TB_OP_UI_RESEARCHING_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.researching = {r=r,g=g,b=b}
				UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				UpdateUI(CRAFTING_TYPE_CLOTHIER)
				UpdateUI(CRAFTING_TYPE_WOODWORKING)
			end,
			default = defaults.colours.researching
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_UI_OTHERS_KNOW_COLOUR),
			tooltip = GetString(TB_OP_UI_OTHERS_KNOW_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.others_know = {r=r,g=g,b=b}
				UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				UpdateUI(CRAFTING_TYPE_CLOTHIER)
				UpdateUI(CRAFTING_TYPE_WOODWORKING)
				UpdateMotifUI()
			end,
			default = defaults.colours.others_know
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_UI_OTHERS_RES_COLOUR),
			tooltip = GetString(TB_OP_UI_OTHERS_RES_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.colours.others_researching.r, TraitBuddy.settings.colours.others_researching.g, TraitBuddy.settings.colours.others_researching.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.others_researching = {r=r,g=g,b=b}
				UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				UpdateUI(CRAFTING_TYPE_CLOTHIER)
				UpdateUI(CRAFTING_TYPE_WOODWORKING)
			end,
			default = defaults.colours.others_researching
		},
		{
			type = "colorpicker",
			name = GetString(TB_OP_UI_NOTKNOWN_COLOUR),
			tooltip = GetString(TB_OP_UI_NOTKNOWN_COLOUR_TT),
			getFunc = function()
				return TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.not_known = {r=r,g=g,b=b}
				UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				UpdateUI(CRAFTING_TYPE_CLOTHIER)
				UpdateUI(CRAFTING_TYPE_WOODWORKING)
				UpdateMotifUI()
			end,
			default = defaults.colours.not_known
		},
		{
			type = "header",
			name = "|c3f7fff"..GetString(TB_OP_HEADING3).."|r"
		},
		{
			type = "checkbox",
			name = GetString(TB_OP_SELECTION),
			tooltip = GetString(TB_OP_SELECTION_TT),
			getFunc = function() return TraitBuddy.settings.alternativeSelection end,
			setFunc = function(value)
				TraitBuddy.settings.alternativeSelection = value
				Alts_ShowSelection()
			end,
			default = defaults.alternativeSelection
		},
		{
			type = "button",
			name = GetString(SI_INTERFACE_OPTIONS_FRAMERATE_LATENCY_POSITION_RESET),
			func = function()
				TraitBuddy.settings.x = defaults.x
				TraitBuddy.settings.y = defaults.y
				SetWindowPosition()
			end
		},
		{
			type = "header",
			name = "|c3f7fff"..GetString(TB_OP_HEADING4).."|r"
		},
		{
			type = "description",
			text = GetString(TB_OP_INCLUSION)
		},
		{
			type = "custom",
			reference = "TBSettingsCharacters"
		}
	}
	LAM:RegisterOptionControls(ADDON_NAME, optionsData)
end
local function OnPlayerActivated()
	if TraitBuddy.player_activated then return end	--Only the first time
	TraitBuddy.player_activated = true
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	StructureAndFix()
	SortCharacters()
	CreateUI()
	UpdateResearching()
	UpdateResearch()
	UpdateMotifs()
	SetWindowPosition()
	ZO_ToggleButton_SetState(TBLocked, not TraitBuddy.settings.locked)
	HookBagTooltip()
	HookLootTooltip()
	HookMailTooltip()
	HookBuybackTooltip()
	HookTradeTooltip()
	HookTradingHouseTooltip()
	HookChatLinkTooltip()
	HookQuestRewardTooltip()
	HookCraftingTooltip()
	HookWornItemsTooltip()
	CreateSettingsMenu()
end

--=====================================================================================  
--Button Start
--=====================================================================================
  local wm = GetWindowManager() -- we want to use whatever window manager the game is
  local TraitBuddyButtonIsClicked = false
   
  local TraitBuddyIcon = wm:CreateControl("TraitBuddyIcon",  ZO_Skills, CT_TEXTURE)
  TraitBuddyIcon:SetDimensions(65,65)
  TraitBuddyIcon:SetAnchor(TOPRIGHT, ZO_Skills, nil, -70, -65)
  TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_up.dds")
  TraitBuddyIcon:SetDrawLayer(3)
  
--Button Declaration
  local TraitBuddyIconBtn = wm:CreateControl(nil, ZO_Skills, CT_BUTTON)
  TraitBuddyIconBtn:SetAnchorFill(TraitBuddyIcon)
  TraitBuddyIconBtn:SetDimensions(25, 25)

  --Button Is Clicked
  TraitBuddyIconBtn:SetHandler("OnClicked", 
  function() 
    TraitBuddyUI:Toggle()
	if TraitBuddyButtonIsClicked == true then
	  TraitBuddyButtonIsClicked = false
	else
	  TraitBuddyButtonIsClicked = true
	end
	TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_down.dds")
  end)
   
  --Button Is Entered   
  TraitBuddyIconBtn:SetHandler("OnMouseEnter", 
  function(self)
    if TraitBuddyButtonIsClicked == true then
      TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_down.dds")
	else
	  TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_over.dds")
	end
  end)

  --Button Is Exited	  
  TraitBuddyIconBtn:SetHandler("OnMouseExit", 
  function(self)
    if TraitBuddyButtonIsClicked == true then
	  TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_down.dds")
	else
	  TraitBuddyIcon:SetTexture("esoui/art/treeicons/store_indexicon_craftingmotiff_up.dds")
	end
  end)

--=====================================================================================  
--Button End
--=====================================================================================  

function TraitBuddyUI:Toggle()
	SCENE_MANAGER:ToggleTopLevel(TB)
	if TraitBuddy.characterId ~= TraitBuddy.selectedId then --Always select the current character when re-opening
		AltsDropdown_SelectCharacter(TraitBuddy.characterId)
	end
end
function TraitBuddyUI:ToggleOptions()
	SCENE_MANAGER:HideTopLevel(TB)
	DoCommand("/tboptions")
end
function TraitBuddyUI:SetLocked(self)
	TraitBuddy.settings.locked = not ZO_ToggleButton_GetState(self)
end
function TraitBuddyUI:MoveStart(self)
	if TraitBuddy.settings.locked then
		self:StopMovingOrResizing()
	end
end
function TraitBuddyUI:MoveStop(self)
	if not TraitBuddy.settings.locked then
		TraitBuddy.settings.x = self:GetLeft()
		TraitBuddy.settings.y = self:GetTop()
	end
end
function TraitBuddyUI:MotifHeader_OnMouseUp(header, upInside)
	ZO_TreeHeader_OnMouseUp(header, upInside)
	ZO_ToggleButton_SetState(header:GetNamedChild("Toggle"), header.node:IsOpen())
end
function TraitBuddyUI:MotifHeader_OnMouseEnter(header)
	ZO_CheckButtonLabel_ColorText(header:GetNamedChild("Text"), true)
	ZO_ToggleButton_SetState(header:GetNamedChild("Toggle"), header.node:IsOpen())
end
function TraitBuddyUI:MotifHeader_OnMouseExit(header)
	ZO_CheckButtonLabel_ColorText(header:GetNamedChild("Text"), false)
	ZO_ToggleButton_SetState(header:GetNamedChild("Toggle"), header.node:IsOpen())
end
function TraitBuddyUI:MotifEntry_OnMouseEnter(entry)
	ZO_CheckButtonLabel_ColorText(entry:GetNamedChild("Text"), true)
	local data = entry.node:GetData()
	local link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,data.id,data.quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	InitializeTooltip(ItemTooltip, entry, LEFT, 5, 0)
	ItemTooltip:SetLink(link)
	DisplayMotifTooltip(ItemTooltip, link)
end
function TraitBuddyUI:MotifEntry_OnMouseExit(entry)
	ZO_CheckButtonLabel_ColorText(entry:GetNamedChild("Text"), false)
	ClearTooltip(ItemTooltip)
end
function TraitBuddyUI:Trait_OnMouseEnter(control)
	local name, _, _, _ = GetSmithingResearchLineInfo(control.craftingSkillType, control.researchLineIndex)
	local traitType, _, _ = GetSmithingResearchLineTraitInfo(control.craftingSkillType, control.researchLineIndex, control.traitIndex)
	local k, r, can = GetWhoKnows(control.craftingSkillType, control.researchLineIndex, control.traitIndex)

	InitializeTooltip(InformationTooltip, control, LEFT, 5, 0)
	BuildTooltipTitle(InformationTooltip, name.." - "..GetString("SI_ITEMTRAITTYPE", traitType))
	ZO_Tooltip_AddDivider(InformationTooltip)
	BuildTooltip(InformationTooltip, k, r, can)

	--TODO shouldnt this be from the settings?
	local c = TraitBuddy.settings.characters[TraitBuddy.selectedId]
	for i=1,#r do
		if r[i] == c.name then
			local timeRemainingSecs = GetDiffBetweenTimeStamps(c.research[control.craftingSkillType][control.researchLineIndex][control.traitIndex].done, GetTimeStamp())
			InformationTooltip:AddLine(tostring(ZO_FormatTime(timeRemainingSecs, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT, TIME_FORMAT_PRECISION_SECONDS)), "ZoFontGame", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end
function TraitBuddyUI:AltsMenuBarButton_OnMouseEnter(btn)
	local buttonData = ZO_MenuBarButtonTemplate_GetData(btn)
	ZO_MenuBarButtonTemplate_OnMouseEnter(btn)
	InitializeTooltip(InformationTooltip, btn, TOP, 0, 5)
	if TraitBuddy.settings.characters[buttonData.descriptor].name then
		SetTooltipText(InformationTooltip, TraitBuddy.settings.characters[buttonData.descriptor].name, 1, 1, 1)
	end
	SetTooltipText(InformationTooltip, buttonData.className..", "..buttonData.raceName)
end
function TraitBuddyUI:AltsMenuBarButton_OnMouseExit(btn)
	ZO_MenuBarButtonTemplate_OnMouseExit(btn)
	ZO_Tooltips_HideTextTooltip()
end
local function testMe()
	d("TEST")
	local found = false
	d("currentId: "..GetCurrentCharacterId())
	d("num characters: "..tostring(GetNumCharacters()))
	for i = 1, GetNumCharacters() do
		local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)
		name = zo_strformat("<<1>>",name)
		d("n="..name.." g="..tostring(gender).." l="..tostring(level).." c="..tostring(classId).." r="..tostring(raceId).." a="..tostring(alliance).." id="..tostring(id).." loc="..tostring(locationId))
		if id == GetCurrentCharacterId() then
			found = true
		end
	end
	d("Found id="..tostring(found))
	
	--local link = ZO_LinkHandler_CreateLink("Test link",nil,ITEM_LINK_TYPE,71566,ITEM_QUALITY_ARTIFACT,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	--d(link)
	--[[
	for styleItemIndex = 0, GetNumSmithingStyleItems() do
		local itemName, icon, sellPrice, meetsUsageRequirement, itemStyle, quality = GetSmithingStyleItemInfo(styleItemIndex)
		local itemLink = GetSmithingStyleItemLink(styleItemIndex, LINK_STYLE_DEFAULT)
		if itemStyle > ITEMSTYLE_NONE then
			d(zo_strformat("itemStyle <<1>> styleItemIndex <<2>> : <<3>>", itemStyle, styleItemIndex, itemLink))
		end
	end
	]]--
end
local function OnLoaded(eventType, addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	
	SCENE_MANAGER:RegisterTopLevel(TB, false)
	SLASH_COMMANDS["/tb"] = function(args) TraitBuddyUI:Toggle() end
	SLASH_COMMANDS["/tbtest"] = function(args) testMe() end
	
	TraitBuddy.settings = {}
	TraitBuddy.player_activated = false
	TraitBuddy.characterId = GetCurrentCharacterId()
	TraitBuddy.selectedId = nil
	TraitBuddy.viewingAlt = false
	TraitBuddy.colours = {
		--Tooltip you know colours (bottom line)
		you_know = ZO_ColorDef:New(1, 0, 0),
		you_researching = ZO_ColorDef:New(0.25, 0.5, 1),
		you_canResearch = ZO_ColorDef:New(0, 1, 0)
	}
	TraitBuddy.settings = ZO_SavedVars:NewAccountWide("TraitBuddySettings", 1, nil, DefaultSettings())

	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, OnResearchCompleted)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, OnResearchStarted)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SKILL_POINTS_CHANGED, OnSkillPointsChanged)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STYLE_LEARNED, OnStyleLearned)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnSettingsControlsCreated)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)