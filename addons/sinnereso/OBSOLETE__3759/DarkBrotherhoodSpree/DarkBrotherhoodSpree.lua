-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- name of the marked for death contract book
local contractBook = {
	["Marked for Death"] = true,
}

-- first few characters of the quest dialog that aren't spree contracts
local dialog = {
	["'d think"] = true,
	[" Queen h"] = true,
	["re's a b"] = true,
	["en Ayren"] = true,
	["as passi"] = true,
	["re is a "] = true,
	["annot ab"] = true,
	[" Spinner"] = true,
	["e and Jo"] = true,
	["g Aerada"] = true,
	[" don't t"] = true,
	["re's a t"] = true,
	["spouse b"] = true,
	["more Tha"] = true,
	["ry day I"] = true,
	[" of the "] = true,
	["e fool k"] = true,
	["kwasten "] = true,
	["ave a cu"] = true,
	["s one se"] = true,
	["en-ja is"] = true,
	["dbeats. "] = true,
	["ls of Ju"] = true,
	["re are s"] = true,
	["ave been"] = true,
	[" Stone O"] = true,
	[" cheerin"] = true,
	[" at peak"] = true,
	["e been d"] = true,
	["m positi"] = true,
	["py hides"] = true,
	["an't tol"] = true,
	[" being m"] = true,
	["oward hi"] = true,
	["prey has"] = true,
	["se Dorel"] = true,
	["advancem"] = true,
	["t the be"] = true,
	["se who s"] = true,
	["ealous b"] = true,
	["agitator"] = true,
	["re's an "] = true,
	["m forced"] = true,
	[" seeds o"] = true,
	["eek to g"] = true,
	["elers ma"] = true,
	["kin dish"] = true,
	[" careles"] = true,
	["lorious "] = true,
	["rect the"] = true,
	["eally ca"] = true,
	["people m"] = true,
	["lover—"] = true,
	["losed ar"] = true,
	["re is a "] = true,
	["rine dut"] = true,
	["n the Da"] = true,
	[" losing "] = true,
	["d slaugh"] = true,
	[" milk-dr"] = true,
	[" suspici"] = true,
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
		if GetZoneId(GetUnitZoneIndex("player")) ~= 826 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- check if the current dialog starts the Dark Brotherhood Spree Contract
		local offerText = GetOfferedQuestInfo()
		if dialog[string.sub(offerText,5,12)] then
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