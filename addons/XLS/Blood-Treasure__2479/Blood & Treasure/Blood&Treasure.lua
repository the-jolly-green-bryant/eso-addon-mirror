-- Dark Brotherhood Killing Spree Contract Book

local lastInteractableName
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- Marked For Death Contract Book Name

local contractBook = {
	["Marked for Death"] = true,
}

-- First Characters Of The Quests That Are NOT Spree Contracts

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

-- No Single Target Quests, Only Spree

local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- Check If The Current Target Is The Contract Book
		if not contractBook[lastInteractableName] then
			PopulateChatterOption(self, index, fun, txt, type, ...)
			return
		end
		-- The Player Has To Be On The Dark Brotherhood Map
		if GetZoneId(GetUnitZoneIndex("player")) ~= 826 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- Check If The Current Dialog Starts The Dark Brotherhood Spree Contract
		local offerText = GetOfferedQuestInfo()
		if dialog[string.sub(offerText,5,12)] then
			-- If It Is A Single Target Quest, Only Display "Goodbye" option
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





-- Thieves Guild Laundering Deals

local lastInteractableName
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- Tip Board Names

local tipBoard = {
	["Tip Board"] = true,
	["Brett für Aufträge"] = true,
	["Tableau des tuyaux"] = true,
	["Доска объявлений"] = true,
	-- missing for JP
}

-- First Characters Of The Thieves Guild Quests

local dialog = {
	["eemed th"] = true,
	["ochgesch"] = true,
	["Voleurs "] = true,
	-- missing for RU
	-- missing for JP
}

-- No Chatter Option, Only The Thieves Guild Quest

local function OverwritePopulateChatterOption(interaction)
	local PopulateChatterOption = interaction.PopulateChatterOption
	interaction.PopulateChatterOption = function(self, index, fun, txt, type, ...)
		-- check if the current target is the tip board
		if not tipBoard[lastInteractableName] then
			PopulateChatterOption(self, index, fun, txt, type, ...)
			return
		end
		-- The Player Has To Be On The Thieves Guild Map
		if GetZoneId(GetUnitZoneIndex("player")) ~= 821 then
			return PopulateChatterOption(self, index, fun, txt, type, ...)
		end
		-- Check If The Current Dialog Starts The Dark Deals Quest
		local offerText = GetOfferedQuestInfo()
		if not dialog[string.sub(offerText,5,12)] then
			-- If It Is A Different Quest, Only Display "Goodbye" option
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