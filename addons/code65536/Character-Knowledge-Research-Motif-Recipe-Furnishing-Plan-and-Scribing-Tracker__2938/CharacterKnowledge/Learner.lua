local LCCC = LibCodesCommonCode
local LCK = LibCharacterKnowledge
local LRM = LibRadialMenu
local CharacterKnowledge = CharacterKnowledge

local NAME = "CharacterKnowledgeLearner"

-- Any attempt to invoke the keybind prior to initialization should just be a NOP
CharacterKnowledge.Learn = LCCC.NOP

ZO_CreateStringId("SI_BINDING_NAME_CHARACTERKNOWLEDGE_LEARN", string.format("%s: %s", GetString(SI_CK_TITLE), GetString(SI_CK_LEARN_KEYBIND)))

LCK.RegisterForCallback(NAME, LCK.EVENT_INITIALIZED, function( )
	local time = 0
	local count = 0

	LCK.RegisterForCallback(NAME, LCK.EVENT_UPDATE_REFRESH, function( )
		if (count > 0 and GetGameTimeMilliseconds() - time < 3000) then
			CHAT_ROUTER:AddSystemMessage(zo_strformat(SI_CK_LEARNED_MESSAGE, count))
			count = 0
		end
	end)

	CharacterKnowledge.Learn = LCCC.RegisterSlashCommands(function( ... )
		local params = LCCC.TokenizeSlashCommandParameters(...)
		local filter = CharacterKnowledge[params.all and "IsInventorySlotUnknownForSelected" or "IsInventorySlotLearnableForSelected"]

		count = 0

		local usedIds = { }
		local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)

		for _, slot in pairs(bagCache) do
			local itemId = GetItemId(slot.bagId, slot.slotIndex)
			if (filter(slot, CharacterKnowledge.charId) and not usedIds[itemId]) then
				if (count == 0) then
					-- Workaround for TraitBuddy's grotesquely inefficient update code getting stuck when there are a lot of updates
					EVENT_MANAGER:UnregisterForEvent("TraitBuddy", EVENT_STYLE_LEARNED)
				end

				usedIds[itemId] = true
				time = GetGameTimeMilliseconds()
				count = count + 1
				CallSecureProtected("UseItem", slot.bagId, slot.slotIndex)
			end
		end
	end, "/cklearn", "/ckl")

	if (LRM) then
		LRM:RegisterAddon(CharacterKnowledge.name, CharacterKnowledge.title)
		LRM:RegisterEntry(CharacterKnowledge.name, GetString(SI_CK_LEARN_KEYBIND), "CK_LEARN", "/esoui/art/addons/gamepad/gp_mod_listing_category_libraries.dds", CharacterKnowledge.Learn, "")
	end
end)
