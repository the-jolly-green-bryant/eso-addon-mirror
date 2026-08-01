if (not AdvancedFilters) then return end

local LCK = LibCharacterKnowledge
local CharacterKnowledge = CharacterKnowledge

local userId = CharacterKnowledge.userId
local charId = CharacterKnowledge.charId
local charName = GetUnitName("player")
local maxLevel = GetMaxLevel()

local function CreateKnowledgeFilter( filterName, stringId, getCallback, subfiltersOverride, onlyGroupsOverride )
	local filterInformation = {
		submenuName = filterName,

		callbackTable = {
			{ name = charId, filterCallback = getCallback(charId) },
			{ name = "AnyCharacter", filterCallback = getCallback() },
		},

		enStrings = {
			[filterName] = GetString(stringId),
			["AnyCharacter"] = GetString(SI_CK_AF_PLUGIN_ANY),
			[charId] = charName,
		},

		filterType = ITEMFILTERTYPE_ALL,
		subfilters = subfiltersOverride or { "Motif", "Recipe" },
		onlyGroups = onlyGroupsOverride or { "Consumables", "Junk" },
	}

	local accountPosition = #filterInformation.callbackTable

	local addAccount = function( account )
		local key = "CK_" .. account
		if (not filterInformation.enStrings[key]) then
			accountPosition = accountPosition + 1
			table.insert(filterInformation.callbackTable, accountPosition, {
				name = key,
				filterCallback = getCallback(nil, account),
			})
			filterInformation.enStrings[key] = string.format("(%s)", account)
		end
	end

	addAccount(userId)

	for _, character in ipairs(LCK.GetCharacterList()) do
		if (character.id ~= charId) then
			addAccount(character.account)
			table.insert(filterInformation.callbackTable, {
				name = character.id,
				filterCallback = getCallback(character.id),
			})
			filterInformation.enStrings[character.id] = character.name
		end
	end

	AdvancedFilters_RegisterFilter(filterInformation)
end

local function CreateLevelFilter( filterName, stringId, getCallback )
	local filterInformation = {
		submenuName = filterName,

		callbackTable = { },

		enStrings = {
			[filterName] = GetString(stringId),
		},

		filterType = ITEMFILTERTYPE_CONSUMABLE,
		subfilters = { "Recipe" },
	}

	for _, level in ipairs({ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 60, 100, 150, 200 }) do
		local key = string.format("CK_RecipeLevel_%d", level)

		table.insert(filterInformation.callbackTable, {
			name = key,
			filterCallback = getCallback(level),
		})

		if (level <= maxLevel) then
			filterInformation.enStrings[key] = tostring(level)
		else
			filterInformation.enStrings[key] = zo_iconTextFormatNoSpace("/esoui/art/champion/champion_icon_32.dds", 16, 16, tostring(level - maxLevel))
		end
	end

	AdvancedFilters_RegisterFilter(filterInformation)
end

LCK.RegisterForCallback("CharacterKnowledgeFilters", LCK.EVENT_INITIALIZED, function( )
	local util = AdvancedFilters.util

	CreateKnowledgeFilter("LearnableItems", SI_CK_AF_PLUGIN_LEARNABLE, function( selectedCharId, selectedAccount )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			return CharacterKnowledge.IsInventorySlotLearnableForSelected(slot, selectedCharId, selectedAccount)
		end
	end)

	CreateKnowledgeFilter("UnknownItems", SI_CK_AF_PLUGIN_UNKNOWN, function( selectedCharId, selectedAccount )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			return CharacterKnowledge.IsInventorySlotUnknownForSelected(slot, selectedCharId, selectedAccount)
		end
	end)

	CreateLevelFilter("RecipeLevels", SI_CK_AF_PLUGIN_RECIPE_LEVEL, function( selectedLevel )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			local itemType, specializedItemType = GetItemType(slot.bagId, slot.slotIndex)

			if (itemType == ITEMTYPE_RECIPE and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)) then
				local resultLink = GetItemLinkRecipeResultItemLink(GetItemLink(slot.bagId, slot.slotIndex))
				local level = GetItemLinkRequiredLevel(resultLink)
				if (level == maxLevel) then
					level = level + GetItemLinkRequiredChampionPoints(resultLink)
				end
				return level == selectedLevel
			else
				return false
			end
		end
	end)

	CreateKnowledgeFilter("ResearchableItems", SI_SMITHING_RESEARCH_RESEARCHABLE, function( selectedCharId, selectedAccount )
		return function( slot, slotIndex )
			if (util.prepareSlot ~= nil) then
				if (slotIndex ~= nil and type(slot) ~= "table") then
					slot = util.prepareSlot(slot, slotIndex)
				end
			end

			return not IsItemPlayerLocked(slot.bagId, slot.slotIndex) and CharacterKnowledge.IsInventorySlotResearchableForSelected(slot, selectedCharId, selectedAccount)
		end
	end, { "All" }, { "Weapons", "Armor", "Jewelry", "Junk", "AllUniversalDecon" })
end)
