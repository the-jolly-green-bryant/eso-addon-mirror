-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- localized names of the tip board
local tipBoard = {
	["Tip Board"] = true,
	["Brett für Aufträge"] = true,
	["Tableau des tuyaux"] = true,
	["Доска объявлений"] = true,
	-- missing for JP
}

-- first few characters of the covetous countess quest dialog
local dialog = {
	["eemed th"] = true,
	["ochgesch"] = true,
	["Voleurs "] = true,
	-- missing for RU
	-- missing for JP
}

-- override the chatter option function, so only the Covetous Countess quest can be started
local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- check if the current target is the tip board
		if not tipBoard[lastInteractableName] then
			PopulateChatterOption(self, index, fun, txt, type, ...)
			return
		end
		-- the player has to be on the TG map
		if GetZoneId(GetUnitZoneIndex("player")) ~= 821 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- check if the current dialog starts the Covetous Countess quest
		local offerText = GetOfferedQuestInfo()
		if not dialog[string.sub(offerText,5,12)] then
			-- if it is a different quest, only display the goodbye option
			if type ~= CHATTER_GOODBYE then
				return
			end
			PopulateChatterOption(self, 1, fun, txt, type, ...)
			return
		end
		PopulateChatterOption(self, index, fun, txt, type, ...)
		lastInteractableName = nil -- set this variable to nil, so the next dialog step isn't manipulated
	end
end

OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard