-- Dark Brotherhood Killing Spree Contract Book

local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- Marked For Death Contract Book Name

local contractBook = {
	["Marked for Death"] = true,
  -- RU
  ["Приговоренные к смерти"] = true,
}

-- First Characters Of The Quests That Are Spree Contracts

local dialog = {
  ["and for "] = true,
  [" Thalmor"] = true,
  ["k to the"] = true,
  [" damn El"] = true,
  ["abal Tor"] = true,
  ["s one do"] = true,
  [" Redguar"] = true,
  ["ained re"] = true,
  ["de is th"] = true,
  [" Covenan"] = true,
  ["ggling i"] = true,
  ["er forgi"] = true,
  [" Thanes "] = true,
  [" Ebonhea"] = true,
  ["thers an"] = true,
  ["exile le"] = true,
  -- RU
  ["нь контр"] = true,
  ["земцы по"] = true,
  ["мя возвр"] = true,
  ["морцы гр"] = true,
  ["нание оп"] = true,
  ["ы Истмар"] = true,
  ["говля дл"] = true,
  ["абал-Тор"] = true,
  ["гардов з"] = true,
  ["енант пр"] = true,
  ["ос на на"] = true,
  ["жит пока"] = true,
  ["клятые э"] = true,
  ["тья и се"] = true,
  ["огда не "] = true,
  ["ряженные"] = true,
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
		if offerText ~= "" and not dialog[string.sub(offerText, utf8.offset(offerText, 5), utf8.offset(offerText, 13)-1)] then
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
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

-- Tip Board Names

local tipBoard = {
	["Tip Board"] = true,
  -- DE
	["Brett für Aufträge"] = true,
  -- FR
	["Tableau des tuyaux"] = true,
  -- RU
	["Доска объявлений"] = true,
	-- missing for JP
}

-- First Characters Of The Thieves Guild Quests

local dialog = {
	["eemed th"] = true,
  -- DE
	["ochgesch"] = true,
  -- FR
	["Voleurs "] = true,
  -- RU
	["точтимые"] = true,
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
		if not dialog[string.sub(offerText, utf8.offset(offerText, 5), utf8.offset(offerText, 13)-1)] then
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