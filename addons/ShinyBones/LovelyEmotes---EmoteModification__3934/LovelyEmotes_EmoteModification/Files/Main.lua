local _name = "LovelyEmotes_EmoteModification"

local _settings = {
	EmoteDataEntries = {},
}

local _savedAccountVariables

LovelyEmotes_EmoteDataMod = {}
LovelyEmotes.Modifications = {} -- Legacy emote modifications table

local function IsTableEmpty(table)
	for k,v in pairs(table) do return false end
	return true
end
LovelyEmotes_EmoteDataMod.IsTableEmpty = IsTableEmpty

local function MergeEmoteDataFromFile(emoteDataEntries)
	local numEmotes = GetNumEmotes()
	local emoteIDs = {}

	for i = 1, numEmotes do
		local slashName, categoryId, id = GetEmoteInfo(i)
		emoteIDs[slashName] = id
	end

	local savedEntries = _savedAccountVariables.EmoteDataEntries

	for entryKey, entry in pairs(emoteDataEntries) do
		local emoteID = emoteIDs[entryKey]
		local savedEntry = savedEntries[emoteID]

		if (savedEntry == nil) then
			savedEntry = {}
			savedEntries[emoteID] = savedEntry
		end

		savedEntry.Ignore = entry.Ignore

		for languageKey, displayName in pairs(entry.ReplaceName) do
			if savedEntry.ReplaceName == nil then savedEntry.ReplaceName = {} end
			savedEntry.ReplaceName[languageKey] = displayName
		end
	end
end

local function ReplaceEmoteDataFromFile(emoteDataEntries)
	_savedAccountVariables.EmoteDataEntries = {}
	MergeEmoteDataFromFile(emoteDataEntries)
end

function LovelyEmotes_EmoteDataMod.ApplyMofifiedEmoteData(modifiedEntries, reloadUi)
	_savedAccountVariables.EmoteDataEntries = modifiedEntries
	if reloadUi == true then ReloadUI() end
end

EVENT_MANAGER:RegisterForEvent(_name, EVENT_ADD_ON_LOADED, function(event, addonName)
	if addonName ~= _name then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	_savedAccountVariables = ZO_SavedVars:NewAccountWide("EmoteDataModVariables", 1, nil, _settings)
	LovelyEmotes_EmoteDataMod.SavedAccountVariables = _savedAccountVariables

	if IsTableEmpty(_savedAccountVariables.EmoteDataEntries) == false then
		LovelyEmotes.ModifyEmoteData(_savedAccountVariables.EmoteDataEntries)
	end
end)

SLASH_COMMANDS["/lemodifyemotedata"] = function(arg)
	if arg ~= "" then
		local emoteDataMod = LovelyEmotes.Modifications.EmoteDataMod

		if emoteDataMod ~= nil and IsTableEmpty(emoteDataMod) == false then
			if arg == "replace" then
				ReplaceEmoteDataFromFile(emoteDataMod)
			elseif arg == "merge" then
				MergeEmoteDataFromFile(emoteDataMod)
			else
				d("Valid arguments: replace, merge")
			end
		end
	end

	LE_EmoteDataModMenu:Show()
end
