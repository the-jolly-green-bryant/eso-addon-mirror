local addonName = "TrampleMount"
local savedVariables, accountWideSavedVariables, characterSavedVariables

local function setActiveMount()
	if not savedVariables.enabled then return end
	local isInInstance = IsUnitInDungeon("player") or IsPlayerInRaid()
	if isInInstance then
		if savedVariables.selectedTrample and not IsCollectibleActive(savedVariables.selectedTrample, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			UseCollectible(savedVariables.selectedTrample, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		end
	else
		if savedVariables.selectedOverworld and not IsCollectibleActive(savedVariables.selectedOverworld, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			UseCollectible(savedVariables.selectedOverworld, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		end
	end
end

local function OnAddOnLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
	
	local defaults = {
		enabled = true,
		selectedTrample = select(5, GetCollectibleInfo(12963)) and 12963 or nil, -- auto mammoth
		selectedOverworld = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	}	
	accountWideSavedVariables = ZO_SavedVars:NewAccountWide("TrampleMountSV", 1, nil, defaults)
	defaults.accountWide = true
	characterSavedVariables = ZO_SavedVars:NewCharacterIdSettings("TrampleMountSV", 1, nil, defaults)
	
	savedVariables = characterSavedVariables.accountWide and accountWideSavedVariables or  characterSavedVariables
	
	local function syncToAccountWide()
		characterSavedVariables.accountWide = true
		accountWideSavedVariables.enabled = savedVariables.enabled
		accountWideSavedVariables.selectedTrample = savedVariables.selectedTrample
		accountWideSavedVariables.selectedOverworld = savedVariables.selectedOverworld
		savedVariables = accountWideSavedVariables
	end
	local function syncToCharacter()
		characterSavedVariables.accountWide = false
		characterSavedVariables.enabled = savedVariables.enabled
		characterSavedVariables.selectedTrample = savedVariables.selectedTrample
		characterSavedVariables.selectedOverworld = savedVariables.selectedOverworld
		savedVariables = characterSavedVariables
	end
	
	local mountNames = {}
	local mountIds = {}
	local _, numSubCatgories, _, _, totalCollectibles, _ = GetCollectibleCategoryInfo(11)
	for i = 1, numSubCatgories do
		local _, to, totalSubCollectibles = GetCollectibleSubCategoryInfo(11, i)
		for j = 1, to do
			local collectibleId = GetCollectibleId(11, i, j)
			local name, _, _, _, unlocked, _, isActive = GetCollectibleInfo(collectibleId)
			if unlocked then
				table.insert(mountNames, zo_strformat("<<1>>", name))
				table.insert(mountIds, collectibleId)
			end
		end
	end
	
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, function() zo_callLater(setActiveMount, 2000) end)

	local panelData = {
		type = "panel",
		name = "TrampleMount",
		displayName = "Trample Mount",
		author = "STUDLETON",
		version = "1.0",
		registerForRefresh = true,
	}

	local optionData = {
		{
			type = "description",
			text = "Automatically equips a selected mount for trample in trials/dungeons, and swaps back to the selected overworld mount.",
		},
		{
			type = "checkbox",
			name = "Accountwide",
			tooltip = "Turn off if you want this character to have it's own settings.",
			getFunc = function () return characterSavedVariables.accountWide end,
			setFunc = function (value) 
				if value then syncToAccountWide() else syncToCharacter() end
				ReloadUI()
			end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Enable auto equip",
			tooltip = "Quick toggle to enable/disable the addon",
			getFunc = function() return savedVariables.enabled end,
			setFunc = function(value) savedVariables.enabled = value end,
		},
		{
			type = "dropdown",
			name = "Trample Mount",
			choices = mountNames,
			choicesValues = mountIds,
			tooltip = "The mount to be equipped when you load into a trial/dungeon",
			scrollable = true,
			getFunc = function() 
				local name = GetCollectibleInfo(savedVariables.selectedTrample)
				return savedVariables.selectedTrample
			end,
			setFunc = function(selectedId)
				savedVariables.selectedTrample = selectedId
				setActiveMount()
			end,
		},
		{
			type = "dropdown",
			name = "Overworld Mount",
			choices = mountNames,
			choicesValues = mountIds,
			tooltip = "The mount to be equipped when you load into an overworld zone",
			scrollable = true,
			getFunc = function() 
				local name = GetCollectibleInfo(savedVariables.selectedOverworld)
				return savedVariables.selectedOverworld
			end,
			setFunc = function(selectedId)
				savedVariables.selectedOverworld = selectedId
				setActiveMount()
			end,
		},
		{
			type = "button",
			name = "Refresh list (Reloads UI)",
			tooltip = "Reloads UI to refresh the list of mounts in case you just unlocked a new one and it isn't showing up",
			func = function() ReloadUI() end
		}
	}
	
	LibAddonMenu2:RegisterAddonPanel(addonName, panelData)
	LibAddonMenu2:RegisterOptionControls(addonName, optionData)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)