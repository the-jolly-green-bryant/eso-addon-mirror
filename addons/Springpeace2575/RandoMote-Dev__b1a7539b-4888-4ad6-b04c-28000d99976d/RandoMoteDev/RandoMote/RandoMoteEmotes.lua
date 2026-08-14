-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Emotes for RandoMote add-on
-----------------------------------------------------------

RandoMoteEmotesInner = RandoMoteEmotesInner or {}
local RMEmotes = RandoMoteEmotesInner
local RMData = RandoMoteDataInner

RMEmotes.sv = {
    debug = false,
    useStandard = true,
    useCollectible = true,
    useFavouriteOnly = false,
    selectedPreset = "None",
    showLocked = false,
    showSlash = false,

    useEmote = {},
    useCategory = {},
    favEmote = {},
	presetEmote = {
        None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
    },
}

RMEmotes.state = {
	rebuildLists = false,

    emoteData = {},
    cats = {},
    catIds = {},
    normalEmoteList = {},
    favEmoteList = {},
    presetEmoteList = {
        None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
    },
}

RMEmotes.callbacks = {
	RefreshFull = function() end,
}

function RMEmotes.Initialize(sv, state, RefreshFull)
	RMEmotes.sv = sv
	RMEmotes.state = state

	RMEmotes.EnsureSavedVariables()
    RMEmotes.EnsureState()

	if RefreshFull then RMEmotes.callbacks.RefreshFull = RefreshFull end

	RMEmotes.InitializeEmoteData()
	RMEmotes.InitializeCategories()
	RMEmotes.RebuildPresetEmoteState()
	RMEmotes.RequestRebuildEmoteLists()
end

function RMEmotes.EnsureSavedVariables()
	if type(RMEmotes.sv.debug) ~= "boolean" then RMEmotes.sv.debug = false end
	if type(RMEmotes.sv.useStandard) ~= "boolean" then RMEmotes.sv.useStandard = true end
	if type(RMEmotes.sv.useCollectible) ~= "boolean" then RMEmotes.sv.useCollectible = true end
	if type(RMEmotes.sv.useFavouriteOnly) ~= "boolean" then RMEmotes.sv.useFavouriteOnly = false end
	if type(RMEmotes.sv.selectedPreset) ~= "string" then RMEmotes.sv.selectedPreset = "None" end
	if type(RMEmotes.sv.showLocked) ~= "boolean" then RMEmotes.sv.showLocked = false end
	if type(RMEmotes.sv.showSlash) ~= "boolean" then RMEmotes.sv.showSlash = false end
	if type(RMEmotes.sv.useEmote) ~= "table" then RMEmotes.sv.useEmote = {} end
	if type(RMEmotes.sv.useCategory) ~= "table" then RMEmotes.sv.useCategory = {} end
	if type(RMEmotes.sv.favEmote) ~= "table" then RMEmotes.sv.favEmote = {} end
	if type(RMEmotes.sv.presetEmote) ~= "table" then
		RMEmotes.sv.presetEmote = {
			None = {},
			Dancer = {},
			Musician = {},
			Goofball = {},
			Custom1 = {},
			Custom2 = {},
			Custom3 = {},
		}
	end
end

function RMEmotes.EnsureState()
	RMEmotes.state.rebuildLists = RMEmotes.state.rebuildLists or false
	RMEmotes.state.emoteData = RMEmotes.state.emoteData or {}
	RMEmotes.state.cats = RMEmotes.state.cats or {}
	RMEmotes.state.catIds = RMEmotes.state.catIds or {}
	RMEmotes.state.normalEmoteList = RMEmotes.state.normalEmoteList or {}
	RMEmotes.state.favEmoteList = RMEmotes.state.favEmoteList or {}
	RMEmotes.state.emoteData = RMEmotes.state.emoteData or {}
	RMEmotes.state.presetEmoteList = RMEmotes.state.presetEmoteList or {
		None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
	}
end

function RMEmotes.InitializeEmoteData()
	local emoteData = {}

	for i = 1, GetNumEmotes() do
		local slashName, categoryId, emoteId, displayName = GetEmoteInfo(i)
		local collectibleId = GetEmoteCollectibleId(i)
		local isCollectibleUnlocked = (collectibleId ~= nil) and (IsCollectibleUnlocked(collectibleId) == true)
		-- local isValid = RMEmotes.IsShowable(collectibleId, isCollectibleUnlocked)
		local key = slashName:sub(2)

		emoteData[#emoteData + 1] = {
			index = i,
			categoryId = categoryId,
			emoteId = emoteId,
			emoteKey = key,
			collectibleId = collectibleId,
			unlocked = isCollectibleUnlocked,
			slash = slashName,
			display = displayName,
			-- overridden = IsPlayerEmoteOverridden(emoteId),
		}
	end

	table.sort(emoteData, function(a, b) return a.display < b.display end)

	RMEmotes.state.emoteData = emoteData

	-- ensure use flags filled
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		local key = emote.emoteKey
		local categoryId = emote.categoryId

		RMEmotes.sv.useEmote[key] = RMEmotes.sv.useEmote[key] or true
		RMEmotes.sv.useCategory[categoryId] = RMEmotes.sv.useCategory[categoryId] or true
		RMEmotes.sv.favEmote[key] = RMEmotes.sv.favEmote[key] or false
	end
end

function RMEmotes.InitializeCategories()
	-- Group emotes by categoryId
	local cats = {}
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		local cid = emote.categoryId or 0
		cats[cid] = cats[cid] or {}
		table.insert(cats[cid], emote)
	end

	local catIds = {}
	for cid in pairs(cats) do table.insert(catIds, cid) end
	table.sort(catIds)

	for idx, cid in ipairs(catIds) do
		table.sort(cats[cid], function(a, b) return a.display < b.display end)
	end

	RMEmotes.state.cats = cats
	RMEmotes.state.catIds = catIds
end

function RMEmotes.RebuildPresetEmoteState()
	for _, preset in pairs(RMData.Presets) do
		local presetEmoteState = {}

		local predefinedPresetEmote = RMData.predefinedPresetEmote[preset]
		if predefinedPresetEmote ~= nil then
			for key, value in pairs(predefinedPresetEmote) do
				presetEmoteState[key] = value
			end
		end

		local presetEmote = RMEmotes.sv.presetEmote[preset]
		if presetEmote ~= nil then
			for key, value in pairs(presetEmote) do
				presetEmoteState[key] = value
			end
		end

		RMEmotes.sv.presetEmote[preset] = presetEmoteState

		local emoteList = {}
		for _, emote in ipairs(RMEmotes.state.emoteData) do
			local key = emote.emoteKey
			if presetEmoteState[key] == true then
				table.insert(emoteList, emote)
			end
		end

		table.sort(emoteList, function(a, b) return a.display < b.display end)
		RMEmotes.state.presetEmoteList[preset] = emoteList
	end
end

-- TODO: consider to call RebuildEmoteLists directly instead of RequestRebuildEmoteLists
function RMEmotes.RequestRebuildEmoteLists()
	RMEmotes.state.rebuildLists = true
end

function RMEmotes.RebuildEmoteLists()
	if RMEmotes.state.rebuildLists == false then
		return
	end

	RMEmotes.state.normalEmoteList = {}
	RMEmotes.state.favEmoteList = {}

	for _, emote in ipairs(RMEmotes.state.emoteData) do
		if
			RMEmotes.IsAllowed(emote.collectibleId, emote.unlocked)
			and RMEmotes.IsCategoryEnabled(emote.categoryId)
			and RMEmotes.IsEmoteEnabled(emote)
			and RMEmotes.IsEmoteInPresetEnabled(emote)
		then
			if RMEmotes.IsEmoteFavourite(emote) then
				RMEmotes.state.favEmoteList[#RMEmotes.state.favEmoteList + 1] = emote
			else
				RMEmotes.state.normalEmoteList[#RMEmotes.state.normalEmoteList + 1] = emote
			end
		end
	end

	RMEmotes.state.rebuildLists = false
end

function RMEmotes.IsEmoteInPreset(preset, key)
	local predefinedValue = RMData.predefinedPresetEmote[preset][key]
	local stateValue = RMEmotes.sv.presetEmote[preset][key]
	if stateValue ~= nil then
		return stateValue
	elseif predefinedValue ~= nil then
		return predefinedValue
	else
		return false
	end
end

function RMEmotes.GetCategoryOrPresetEmotesList(cid, preset)
	local fullList = RMEmotes.state.cats[cid] or {}
	if cid ~= nil then
		fullList = RMEmotes.state.cats[cid]
	elseif preset ~= nil then
		fullList = RMEmotes.state.presetEmoteList[preset]
	end

	local list = {}
	for _, emote in ipairs(fullList) do
		if RMEmotes.IsShowable(emote.collectibleId, emote.unlocked) then
			table.insert(list, emote)
		end
	end

	return list
end

function RMEmotes.IsShowable(collectibleId, isCollectibleUnlocked)
	return (RMEmotes.sv.showLocked == true) or not collectibleId or (isCollectibleUnlocked == true)
end

function RMEmotes.IsAllowed(collectibleId, isCollectibleUnlocked)
	if not collectibleId then
		return RMEmotes.sv.useStandard == true
	end

	return (RMEmotes.sv.useCollectible == true) and (isCollectibleUnlocked == true)
end

function RMEmotes.IsCategoryEnabled(categoryId)
	local v = RMEmotes.sv.useCategory and RMEmotes.sv.useCategory[categoryId]
	return v ~= false
end

function RMEmotes.IsEmoteEnabled(emote)
	local key = emote.emoteKey

	return RMEmotes.sv.useEmote[key] == true
end

function RMEmotes.IsEmoteInPresetEnabled(emote)
	local key = emote.emoteKey

	return (RMEmotes.sv.selectedPreset == RMData.Presets[1]) or (RMEmotes.sv.presetEmote[RMEmotes.sv.selectedPreset][key] == true)
end

function RMEmotes.IsEmoteFavourite(emote)
	local key = emote.emoteKey

	return RMEmotes.sv.favEmote[key] == true
end

function RMEmotes.IsEmoteTrulyEnabled(emote)
	local key = emote.emoteKey

	return RMEmotes.IsEmoteEnabled(emote)
		and RMEmotes.IsCategoryEnabled(emote.categoryId)
		and RMEmotes.IsAllowed(emote.collectibleId, emote.unlocked)
		and RMEmotes.IsEmoteInPresetEnabled(emote)
		and (not RMEmotes.sv.useFavouriteOnly or RMEmotes.IsEmoteFavourite(emote))
end

function RMEmotes.CountEnabledEmotes()
	local enabled = 0
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		if RMEmotes.IsEmoteTrulyEnabled(emote) then
			enabled = enabled + 1
		end
	end
	return enabled
end

function RMEmotes.IsCollectibleEmote(emote)
	return emote and emote.collectibleId ~= nil
end

function RMEmotes.IsCollectibleUnlockedEmote(emote)
	if not RMEmotes.IsCollectibleEmote(emote) then return false end
	return emote.unlocked == true
end

function RMEmotes.GetEmotesCountsDisplayInfo()
	return "All Emotes (" .. tostring(RMEmotes.CountEnabledEmotes()) .. "/" .. tostring(RMEmotes.CountTotalEmotes()) .. ")"
end

function RMEmotes.EmoteTypeTag(emote)
	-- Keep it simple: symbols like ✓/✗ can fail in ESO fonts for some locales
	if RMEmotes.IsCollectibleEmote(emote) then
		if RMEmotes.IsCollectibleUnlockedEmote(emote) then
			return "|c66ff66[COL]|r "
		else
			return "|cff6666[COL]|r "
		end
	end
	return "|c999999[STD]|r "
end

function RMEmotes.GetCategoryDisplayName(cid)
	return RMData.categoryNames[cid] or ("CategoryId: " .. tostring(cid))
end

function RMEmotes.GetCategoryInfoToDisplay(cid)
	local list = RMEmotes.state.cats[cid] or {}

	local enabled = 0
	local total = 0

	for _, emote in ipairs(list) do
		if RMEmotes.IsEmoteTrulyEnabled(emote) then
			enabled = enabled + 1
		end

		if RMEmotes.IsShowable(emote.collectibleId, emote.unlocked) then
			total = total + 1
		end
	end

	return RMEmotes.GetCategoryDisplayName(cid) .. " (" .. tostring(enabled) .. "/" .. tostring(total) .. ")"
end

function RMEmotes.GetPresetInfoToDisplay(preset)
	local list = RMEmotes.state.presetEmoteList[preset]

	local enabled = 0
	local total = 0

	for _, emote in ipairs(list) do
		if RMEmotes.IsEmoteTrulyEnabled(emote) then
			enabled = enabled + 1
		end

		if RMEmotes.IsShowable(emote.collectibleId, emote.unlocked) then
			total = total + 1
		end
	end

	return RMData.PresetNamesMap[preset] .. " (" .. tostring(enabled) .. "/" .. tostring(total) .. ")"
end

function RMEmotes.GetEmoteInfoToDisplay(emote)
	local slash = ""
	if RMEmotes.sv.showSlash == true then
		slash = emote.slash
	end
	return RMEmotes.EmoteTypeTag(emote) .. "|cb7ff00" .. emote.display .. "|r |cffffff" .. slash .. "|r"
end

function RMEmotes.GetEmoteInfoToDisplayWithFlags(emote)
	local key = emote.emoteKey
	local flags = ""
	if RMEmotes.IsEmoteTrulyEnabled(emote) then flags = flags .. "ON " end -- elseif RMEmotes.useEmote[key] == true then flags = flags .. "OFF " end
	if RMEmotes.sv.favEmote[key] == true then flags = flags .. "FAV " end
	return flags .. RMEmotes.GetEmoteInfoToDisplay(emote)
end

function RMEmotes.CountTotalEmotes()
	local count = 0
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		if RMEmotes.IsShowable(emote.collectibleId, emote.unlocked) then
			count = count + 1
		end
	end
	return count
end

function RMEmotes.ResetEmote(emote)
	if emote ~= nil then
		local key = emote.emoteKey
		RMEmotes.sv.useEmote[key] = true
		RMEmotes.sv.favEmote[key] = false
	end
end

function RMEmotes.ResetCategory(cid)
	if cid ~= nil then
		RMEmotes.sv.useCategory[cid] = true
	end
end

function RMEmotes.ResetEmotesInCategory(cid)
	if cid ~= nil then
		local emotes = RMEmotes.GetCategoryEmoteList(cid)

		for _, emote in ipairs(emotes) do
			RMEmotes.ResetEmote(emote)
		end
	end
end

function RMEmotes.ResetCategories()
	for cid, _ in pairs(RMEmotes.cats or {}) do
		RMEmotes.ResetCategory(cid)
		RMEmotes.ResetEmotesInCategory(cid)
	end
end

function RMEmotes.ResetPreset(preset)
	if preset ~= nil then
		RMEmotes.sv.presetEmote[preset] = {}
	end
end

function RMEmotes.ResetPresets()
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Dancer)
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Musician)
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Goofball)
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Custom1)
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Custom2)
	RMEmotes.ResetPreset(RMData.PresetEmoteKey.Custom3)
end

function RMEmotes.ResetEmotesInPreset(preset)
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		RMEmotes.ResetEmoteInPreset(preset, emote)
	end
end

function RMEmotes.ResetEmoteInPreset(preset, emote)
	if preset ~= nil and emote ~= nil then
		local key = emote.emoteKey
		RMEmotes.sv.presetEmote[preset][key] = RMData.predefinedPresetEmote[preset][key]
	end
end

function RMEmotes.ResetEmoteInPresets(emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Dancer, emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Musician, emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Goofball, emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Custom1, emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Custom2, emote)
	RMEmotes.ResetEmoteInPreset(RMData.PresetEmoteKey.Custom3, emote)
end

function RMEmotes.ResetEmotesInPresets()
	for _, emote in ipairs(RMEmotes.state.emoteData) do
		 RMEmotes.ResetEmoteInPresets(emote)
	end
end

function RMEmotes.GetCategoryIds()
	return RMEmotes.state.catIds
end

function RMEmotes.GetCategoryEmoteList(cid)
	return RMEmotes.state.cats[cid] or {}
end

function RMEmotes.GetPresetEmoteList(preset)
	return RMEmotes.state.presetEmoteList[preset] or {}
end

function RMEmotes.RecheckUncollectedItem(collectibleId)
	local refreshed = 0

    local _, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)

	if categoryType == COLLECTIBLE_CATEGORY_TYPE_EMOTE then
		for _, emote in ipairs(RMEmotes.state.emoteData) do
			if emote.collectibleId == collectibleId then
				emote.unlocked = unlocked
				refreshed = refreshed + 1
			end
		end
	end

	if refreshed > 0 then
		RMEmotes.callbacks.RefreshFull()
	end

    return refreshed
end

function RMEmotes.Debug(text)
    if RMEmotes.sv and RMEmotes.sv.debug then
        d(string.format("[RM] DEBUG: %s", tostring(text)))
    end
end

local function GetNextDirtyUnlockStateCollectibleIdIter(_, lastCollectibleId)
    return GetNextDirtyUnlockStateCollectibleId(lastCollectibleId)
end

function RMEmotes.OnCollectiblesUnlockStateChanged()
    for collectibleId in GetNextDirtyUnlockStateCollectibleIdIter do
        local refreshed = RMEmotes.RecheckUncollectedItem(collectibleId)
        if refreshed > 0 then
            RMEmotes.Debug("Item collected - " .. tostring(collectibleId))
        else
            RMEmotes.Debug("EVENT_COLLECTIBLES_UPDATED had no effect - " .. tostring(collectibleId))
        end
    end
end

function RMEmotes.GetActivePersonality()
	local personalityId = GetActiveCollectibleByType(
		COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
		GAMEPLAY_ACTOR_CATEGORY_PLAYER
	)
	if personalityId and personalityId ~= 0 then
		local personalityName = GetCollectibleName(personalityId)
		local emoteNames = { GetCollectiblePersonalityOverridenEmoteDisplayNames(personalityId) }
		-- local isActive = IsCollectibleActive(personalityId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		return personalityId, personalityName, emoteNames
	end
	return nil, nil, nil
end
