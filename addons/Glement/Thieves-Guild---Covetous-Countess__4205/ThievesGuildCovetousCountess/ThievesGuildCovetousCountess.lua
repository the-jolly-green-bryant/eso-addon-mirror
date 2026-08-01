-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- name of the marked for death contract book
local contractBook = {
	["Tip Board"] = true,
}

-- first few characters of the quest dialog that aren't spree contracts
local dialog = {
	["Rumors tha"] = true,
	["We've got "] = true,
	["Some of th"] = true,
	["Got some s"] = true,
}

-- override the chatter option function, so only the Dark Brotherhood Spree Contracts can be started
local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- check if the current target is the contract book
		if not contractBook[lastInteractableName] then
			PopulateChatterOption(self, index, fun, txt, type, ...)
			return
		end
		-- the player has to be on the DB map
		if GetZoneId(GetUnitZoneIndex("player")) ~= 821 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- check if the current dialog starts the Dark Brotherhood Spree Contract
		local offerText = GetOfferedQuestInfo()
		if dialog[string.sub(offerText,2,11)] then
			-- if it is a different quest, only display the goodbye option
			if type ~= CHATTER_GOODBYE then
				return
			end
			PopulateChatterOption(self, 1, fun, txt, type, ...)
			return
		end
		PopulateChatterOption(self, index, fun, txt, type, ...)
	end
end

OverwritePopulateChatterOption(GAMEPAD_INTERACTION)
OverwritePopulateChatterOption(INTERACTION) -- keyboard