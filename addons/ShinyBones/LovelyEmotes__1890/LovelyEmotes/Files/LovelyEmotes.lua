local _savedAccountVariables
local _availablePersonalities = {}
local _availableEmotes = {}
local _numberOfAvailableEmotes = 0
local _idEmoteList = {}
local _emoteData
local _categoryNames = {}
local _mainWindow = {}
local _name = "LovelyEmotes"

LovelyEmotes = {
	Name = _name,
	Version = "5.1",

	AvailableEmotes = _availableEmotes,
	AvailablePersonalities = _availablePersonalities,
	MainWindow = _mainWindow,
}

function LovelyEmotes.GetNumberOfAvailableEmotes()
	return _numberOfAvailableEmotes
end

local function OnGameCameraUiModeChanged(eventCode)
	if _savedAccountVariables.MinimizeAutomatically and not IsGameCameraUIModeActive() then
		if _mainWindow.IsMinimized() then
			_mainWindow.SetMinimizedLocked(true)
			return
		end

		_mainWindow.SetMinimized(true, true)
	end
end

local function SortAvailableEmotes()
	if _savedAccountVariables.ShowSlashNames then
		table.sort(_availableEmotes, function(firstValue, secondValue) return firstValue.SlashName < secondValue.SlashName end)
	else
		table.sort(_availableEmotes, function(firstValue, secondValue) return firstValue.DisplayName < secondValue.DisplayName end)
	end
end
LovelyEmotes.SortAvailableEmotes = SortAvailableEmotes

local function RefreshAvailableEmotesOverridden()
	for id, emote in pairs(_idEmoteList) do
		if id > -1 then emote.IsOverridden = IsPlayerEmoteOverridden(id) end
	end

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_EmotesOverriddenUpdated)
end

local function ConcurrencyWorkaround()
	if CustomIdleAnimation ~= nil and CustomIdleAnimation.StopActiveIdleSetTemporarily then
		CustomIdleAnimation.StopActiveIdleSetTemporarily()
	end
end

local function InitializeAvailableEmotes()
	local cVarString = GetCVar("language.2")

	local function AddEmoteToLists(emote)
		table.insert(_availableEmotes, emote)
		_idEmoteList[emote.ID] = emote
	end

	local function TryAddEmote(index)
		local slashName, categoryId, id, displayName = GetEmoteInfo(index)
		local emoteDataEntry = _emoteData[id]

		if emoteDataEntry == nil or not emoteDataEntry.Ignore then
			if emoteDataEntry ~= nil and emoteDataEntry.ReplaceName ~= nil then
				local newDisplayName = emoteDataEntry.ReplaceName[cVarString]
				if newDisplayName ~= nil then displayName = newDisplayName end
			end

			local emote = {
				SlashName = slashName,
				DisplayName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, displayName),
				CategoryID = categoryId,
				ID = id,
				Index = index,
				IsOverridden = IsPlayerEmoteOverridden(id),
				Play = function()
					PlayEmoteByIndex(index)
					ConcurrencyWorkaround()
				end,
				TagString = string.lower(zo_strformat("<<1>> <<2>>", slashName, displayName)),
			}

			AddEmoteToLists(emote)
		end

		if not _categoryNames[categoryId] then
			_categoryNames[categoryId] = GetString(_G[zo_strformat("SI_EMOTECATEGORY<<1>>", categoryId)])
		end
	end

	local numEmotes = GetNumEmotes()
	if not _savedAccountVariables.ShowLockedEmotes then
		for i = 1, numEmotes do
			local collectibleId = GetEmoteCollectibleId(i)
			if not collectibleId or IsCollectibleUnlocked(collectibleId) then
				TryAddEmote(i)
			end
		end
	else
		for i = 1, numEmotes do
			TryAddEmote(i)
		end
	end

	_numberOfAvailableEmotes = #_availableEmotes

	if _savedAccountVariables.EnablePersonalitiesAsFavorites then
		for i, data in ipairs(_availablePersonalities) do
			local emote = {
				SlashName = data.Name,
				DisplayName = data.Name,
				CategoryID = LE_Const_PersonalityCategoryId,
				ID = LE_Const_PersonalityOffset - data.CollectibleId,
				Play = function() UseCollectible(data.CollectibleId) end,
				TagString = string.lower(data.Name),
			}

			AddEmoteToLists(emote)
		end

		_categoryNames[LE_Const_PersonalityCategoryId] = GetString(SI_COLLECTIBLECATEGORYTYPE9)
	end

	local favoriteCommandsData = _savedAccountVariables.FavoriteCommandsData
	if #favoriteCommandsData > 0 then
		for id, data in ipairs(favoriteCommandsData) do
			local commandString = data.Command
			local displayName = data.DisplayName

			if displayName == nil then
				displayName = commandString
			end

			local emote = {
				SlashName = commandString,
				DisplayName = displayName,
				CategoryID = LE_Const_FavoriteCommandsCategoryId,
				ID = id * -1,
				Play = function() DoCommand(commandString) end,
				TagString = string.lower(zo_strformat("<<1>> <<2>>", commandString, displayName)),
			}

			AddEmoteToLists(emote)
		end

		_categoryNames[LE_Const_FavoriteCommandsCategoryId] = GetString(SI_GRAPHICSPRESETS7)
	end

	SortAvailableEmotes()

	LovelyEmotes_EventSystem.Invoke(LE_EVENT_AvailableEmotesUpdated)
end

local function InitializeAvailablePersonalities()
	local index = 1

	while true do
		local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, index)
		if not collectibleId or collectibleId < 1 then break end

		if IsCollectibleUnlocked(collectibleId) then
			local personalityData = {
				CollectibleId = collectibleId,
				Name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(collectibleId)),
			}

			table.insert(_availablePersonalities, personalityData)
		end

		index = index + 1
	end
end

local function GetEmoteByID(id)
	if not id then return id end
	return _idEmoteList[id]
end
LovelyEmotes.GetEmoteByID = GetEmoteByID

local function GetSavedEmote(emoteIndex, tabIndex)
	return GetEmoteByID(LovelyEmotes_Settings.GetSavedFavoriteID(emoteIndex, tabIndex))
end
LovelyEmotes.GetSavedEmote = GetSavedEmote

function LovelyEmotes.GetCategoryNameByID(categoryId)
	return _categoryNames[categoryId]
end

function LovelyEmotes.SaveRandomEmote(slotIndex, tabIndex)
	local randomEmoteIndex = math.random(1, #LovelyEmotes.AvailableEmotes)
	local emote = LovelyEmotes.AvailableEmotes[randomEmoteIndex]

	LovelyEmotes_Settings.SaveEmote(slotIndex, emote.ID, tabIndex)

	return emote
end

function LovelyEmotes.PlaySavedEmote(index)
	local emote = GetSavedEmote(index)

	if not emote then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_LOVELYEMOTES_ALERT_NO_EMOTE_SELECTED))
		return
	end

	emote.Play()
end

local function AddLoopIcon(emoteId, name)
	local data = _emoteData[emoteId]
	if data == nil or not data.HasLoop then return name end
	return zo_strformat("<<1>> ∞", name)
end

function LovelyEmotes.GetEmoteDisplayName(emote)
	if not _savedAccountVariables.ShowEndlessLoopIcons then return emote.DisplayName end
	return AddLoopIcon(emote.ID, emote.DisplayName)
end

function LovelyEmotes.GetEmoteSlashName(emote)
	if not _savedAccountVariables.ShowEndlessLoopIcons then return emote.SlashName end
	return AddLoopIcon(emote.ID, emote.SlashName)
end

function LovelyEmotes.GetEmoteTextColor(emote)
	if emote then
		if emote.ID > -1 and emote.IsOverridden then
			return ZO_PERSONALITY_EMOTES_COLOR:UnpackRGBA()
		elseif emote.ID < LE_Const_PersonalityOffset and IsCollectibleActive(emote.ID * -1 + LE_Const_PersonalityOffset) then
			return LOVELYEMOTES_COLOR_PERSONALITY_ACTIVE:UnpackRGBA()
		end
	end

	return ZO_NORMAL_TEXT:UnpackRGBA()
end

function LovelyEmotes.ReinitializeAvailableEmotes()
	ZO_ClearNumericallyIndexedTable(_availableEmotes)
	ZO_ClearNumericallyIndexedTable(_availablePersonalities)
	ZO_ClearTable(_idEmoteList)

	InitializeAvailablePersonalities()
	InitializeAvailableEmotes()
end

function LovelyEmotes.SetCombatStateEventActive(value)
	_savedAccountVariables.MinimizeInCombat = value

	if value then
		EVENT_MANAGER:RegisterForEvent(_name, EVENT_PLAYER_COMBAT_STATE, function (eventCode, inCombat)
			if _mainWindow.IsMinimizedLocked() and not inCombat then return end
			_mainWindow.SetMinimized(inCombat, false)
		end)

		return
	end

	EVENT_MANAGER:UnregisterForEvent(_name, EVENT_PLAYER_COMBAT_STATE)
end

function LovelyEmotes.ModifyEmoteData(emoteDataMod)
	local cVarString = GetCVar("language.2")
	local emoteDataEntry

	for id, entry in pairs(emoteDataMod) do
		emoteDataEntry = _emoteData[id]

		if not emoteData then
			emoteDataEntry = {}
			_emoteData[id] = emoteDataEntry
		end

		if entry.Ignore ~= nil then
			emoteDataEntry.Ignore = entry.Ignore
		end

		if entry.ReplaceName ~= nil and entry.ReplaceName[cVarString] ~= nil then
			if emoteDataEntry.ReplaceName == nil then emoteDataEntry.ReplaceName = {} end
			emoteDataEntry.ReplaceName[cVarString] = entry.ReplaceName[cVarString]
		end
	end

	LovelyEmotes.ReinitializeAvailableEmotes()
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_LOVELYEMOTES_ALERT_EMOTE_MODIFICATIONS_APPLIED))
end

--[[
local function LeOnCollectibleUpdated(collectibleId)
	local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
	if not collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_EMOTE) or collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) then return end

	LovelyEmotes.ReinitializeAvailableEmotes()
end
]]

local function LeOnCollectionUpdated(collectionUpdateType, collectiblesByNewUnlockState)
	for k, unlockStates in pairs(collectiblesByNewUnlockState) do
		for i, collectibleData in ipairs(unlockStates) do
			if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_EMOTE) or collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) then
				LovelyEmotes.ReinitializeAvailableEmotes()
				return
			end
		end
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= _name then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

	LovelyEmotes_Settings.Initialize()
	_savedAccountVariables = LovelyEmotes_Settings.SavedAccountVariables

	_emoteData = LE_EmoteData

	local invisibleFragment = ZO_SimpleSceneFragment:New(LE_Invisible)
	HUD_SCENE:AddFragment(invisibleFragment)
	HUD_UI_SCENE:AddFragment(invisibleFragment)

	LovelyEmotes.CheckForSettingsUpdate()
	InitializeAvailablePersonalities()
	InitializeAvailableEmotes()

	LovelyEmotes.EmoteList = LovelyEmotes_EmoteList_CreateNew("LovelyEmotes_EmoteList")
	LovelyEmotes.EmoteList:ShowSlashNames(_savedAccountVariables.ShowSlashNames)
	LovelyEmotes_EventSystem.AddListener(LE_EVENT_ShowSlashNamesChanged, function(value) LovelyEmotes.EmoteList:ShowSlashNames(value) end)

	_mainWindow.Initialize()
	LE_RadialMenu:Initialize()
	LE_FavoriteCommandsMenu:Initialize()
	LE_ChatWindowButton:Initialize()
	LovelyEmotes.InitializeEmoteSync()
	LovelyEmotes.InitializeSettingsMenu()

	LovelyEmotes.UpdateButtonClickSounds(_savedAccountVariables.EnableAlternativeSounds)

	EVENT_MANAGER:RegisterForEvent(_name, EVENT_PERSONALITY_CHANGED, RefreshAvailableEmotesOverridden)
	--ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectibleUpdated", LeOnCollectibleUpdated)
	ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", LeOnCollectionUpdated)
end

local function OnPlayerActivated(eventCode, initial)
	EVENT_MANAGER:UnregisterForEvent(_name, EVENT_PLAYER_ACTIVATED)

	EVENT_MANAGER:RegisterForEvent(_name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnGameCameraUiModeChanged)
	if _savedAccountVariables.MinimizeInCombat then LovelyEmotes.SetCombatStateEventActive(true) end
end

local function OnRandomSlashCommand(arg)
	local targetEmotes = {}

	for i, emote in ipairs(_availableEmotes) do
		if emote.ID >= 0 then
			local collectibleId = GetEmoteCollectibleId(emote.Index)

			if not collectibleId then
				table.insert(targetEmotes, emote)
			elseif IsCollectibleUnlocked(collectibleId) then
				table.insert(targetEmotes, emote)
			end
		end
	end

	targetEmotes[math.random(1, #targetEmotes)].Play()
end

SLASH_COMMANDS["/letoggle"] = function(arg) _mainWindow.ToggleMinimized() end
SLASH_COMMANDS["/lerandom"] = OnRandomSlashCommand
SLASH_COMMANDS["/lefavoritecommands"] = function(arg) LE_FavoriteCommandsMenu:Open() end
EVENT_MANAGER:RegisterForEvent(_name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
