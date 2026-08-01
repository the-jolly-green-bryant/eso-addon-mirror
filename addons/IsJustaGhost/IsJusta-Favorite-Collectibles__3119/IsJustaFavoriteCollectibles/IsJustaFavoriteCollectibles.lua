--[[TODO:
	turg asked about adding set/styles to favorites
]]

--[[ cahnge log version 3
- - - 3.5.2
○ API fix for, 101043 

○ API fix for U43, 101043 
- - - 3.5.1

○ API fix for U43, 101043 
- Keboard housing deferred Initialize

- - - 3.5
○ fixed sorting by name only. It should now sort favorites to top.

- - - 3.4.2
○ fixed error "Globals.lua:12: Attempt to access a private"

- - - 3.4.1
○ fixed bug that would happen when dismissing an assistant from the interaction prompt
-- IsJustaFavoriteCollectibles.lua:308: attempt to index a nil value

- - - 3.4
○ removed unused strings
○ added uption to hide random mount hud icon
○ removed 100 mount favorites limit

- - - 3.3.4
○ fixed error "IsJustaFavoriteCollectibles.lua:594: function expected instead of nil" that can happen when "IsJusta Collectible Randomizer" is also enabled.

- - - 3.3.3
○ improved compatible with IsJusta Collectible Randomizer

- - - 3.3.2
○ made it compatible with IsJusta Collectible Randomizer
○ Fixed the Favorites subcategory headers.
○ 

- - - 3.3.1
○ added a redundancy to prevent "collectibledatamanager.lua:261: operator < is not supported for number < boolean"
-- which is caused by saved variables from before 3.3
○ added the agility to select the import complete sound out of a small list
○ 

- - - 3.3
○ added unlimited favorites suport for non-mounts. 
-- mounts have a limit of 100 and must use the built in favorites in order to use random favorite mount.
○ improved saves importing. Now much faster. It only needs to delay for importing mounts or
-- unsetting non-mounts that were previously set in the built in favorites.
○ added dropdown options for sorting the Favorites subcategories with 3 options.

- - - 3.2.3
○ fixed error "IsJustaFavoriteCollectibles.lua:305: operator + is not supported for boolean + number"

- - - 3.2.2
○ Will no longer try to import mare than 100 favorites.

- - - 3.2.1
○ primary residence is now sorted to top of Favorites houses subcategory
○ fixed companion Favorites mounts category in keyboard mode.
○ fixed companion Favorites in gamepad mode.

- - - 3.2
○ the favorites import will now ignore unsupported collectibles that were previously saved as favorite.
-- this was to stop it from attempting to import on every load. 

- - - 3.1
○ hooked BuildContentList for keyboard mode to use for building the lists for favorites subcategory to prevent "Attempt to access a private function" errors for slotable collectibles.
-- all other collectible lists are handled natively 

- - - 3
○ re-wrote most of the addon to integrate with the new collectible favorite system
○ added a feature to copy favorites option. If not on per-character favorites, it will import the selected saved favorites to the new favorite system
-- else it will copy the selected saved favorites to teh current character. 
○ added the option to use per-character favorites
○ removed all features for furnishings since they are not included in the new favorites system
○ removed all code for housing editor
○ improved the collectible sorting functionality of the "Favorites" subcategories
]]

--[[ cahnge log version 2
- - - 2.10.2
○ fixed errors caused by zos renaming functions in collectibledatamanager.lua
○ added a clone feature for character settings to allow copying settings from account or other characters 

- - - 2.10.1
○ fixed error caused by attempting to show collectible info outside collection
-- this was due to not having a previously viewed category.
-- /AddOns/IsJustaFavoriteCollectibles/collectibledatamanager.lua:85: attempt to index a nil value
○ added setting to select account or character saves

- - - 2.9
○ reworked some base functionality
○ kb/m Favorites subcategories will no longer show all in category when switching back from another tab
○ fixed kb/m issue where collectibles in Favorites subcategories would get marked with the icon when switching back from another tab
○ fixed kb/m drag issues, when trying to add a collectible to a utility wheel.

- - - 2.8.4
○ fixed issues related to update 35

- - - 2.8.3
○ fixed error: (ScrollTemplates.lua:2170: attempt to index a nil value) while accessing companion's collection

- - - 2.8.2
○ fix for random collectible not showing in mounts or non-combat pets

- - - 2.8.1
○ fixed missing options

- - - 2.8.0
○ removed debug output
○ removed random mount
○ improved handeling of Favorites subcategories
○ improved handeling of Favorite collectibles
○ improvements based on being less invasive to base game.
○ Fixed: error Attempt to access a private function caused from loading in a player house.

- - - 2.7.10
○ removed debug output

- - - 2.7.9
○ fixed error caused by searching in collectibles. CollectionsBook_Manager.lua:112: attempt to index a nil value

- - - 2.7.8
○ removed startup debug output that was missed previously

- - - 2.7.7
○ attempt to fix favorites categories from multiplying.
○ removed the unused xml template

- - - 2.7.5
○ fixed random mount not only using favorites when UseFavorites is set
○ added: keyboard housing, the pop-up menu now closes when mouse moves over another entry

- - - 2.7.4
○ fixed keyboard drag-n-drop to quickslot from collections.

- - - 2.7.3
○ fixed OnLoaded.

- - - 2.7.2
○ compatibility update.
	removed requirement for the experimental library
	
- - -2.7.1
○ compatibility update.

- - -2.7
○ updated for API 101034.
○ implemented support for LibHaF

2.6.4
fixed Error: user:/AddOns/IsJustaFavoriteCollectibles/collectibles_GP.lua:143: function expected instead of nil

]]

local addonInfo = {
	savedVariables = 'IJA_FavCollectibles_Saves',
	displayName = '|cFF00FFIsJusta|r |cffffffFavorite Collectibles|r',
	name = "IsJustaFavoriteCollectibles",
	prefix = "IsJustaFC",
	version = "3.5.2",
}

local defaults = {
	sort = 0,
	accountWide = true,
	hideIcon = false,
	alertSound = "Campaign_Ready_Check",
	collectibleCategoryTypes = {},
	enabledCategories = {},
	favorites = {},
	randomMountIcon = {},
}
local favoritesDefaults = {
	favorites = {},
}

local svVersion = 1

---------------------------------------------------------------------------------------------------------------
-- Globals
---------------------------------------------------------------------------------------------------------------
COLLECTIBLE_FAVORITE_ICON = '/esoui/art/treeicons/achievements_indexicon_champion_down.dds'

IJA_FAVORITECOLLECTIBLES = {}

if not jo_callLater then
	jo_callLater = function(id, func, ms, ...)
		if ms == nil then ms = 0 end
		local params = {...}
		local name = "JO_CallLater_".. id
		EVENT_MANAGER:UnregisterForUpdate(name)
		
		EVENT_MANAGER:RegisterForUpdate(name, ms,
			function()
				EVENT_MANAGER:UnregisterForUpdate(name)
				func(unpack(params))
			end)
		return id
	end
end

do
	local function safeRegisterSystemObject(systemName, platform, object, scene)
		local system = SYSTEMS:GetSystem(systemName)

		if system[platform .. 'Object'] == nil then
			system[platform .. 'Object'] = object
		end
		if system[platform .. 'RootScene'] == nil then
			system[platform .. 'RootScene'] = scene
		end
	end

	safeRegisterSystemObject('collectionsCompanion', 'gamepad', COMPANION_COLLECTION_BOOK_GAMEPAD, COMPANION_COLLECTION_BOOK_GAMEPAD_SCENE)
	safeRegisterSystemObject('collectionsCompanion', 'keyboard', COMPANION_COLLECTION_BOOK_KEYBOARD, COMPANION_COLLECTION_BOOK_KEYBOARD_SCENE)
end

---------------------------------------------------------------------------------------------------------------
-- Locals
---------------------------------------------------------------------------------------------------------------
local VAR_CATEGOY_ID_HOUSING		= 20
local VAR_CATEGOY_ID_MOUNTS			= 4
local VAR_CATEGOY_ID_VANITY_PET		= 3

local MAX_NUMBER_FAVORITES			= 100

local var_anchor = ZO_Anchor:New()

local function isMount(collectibleData)
	return collectibleData:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_MOUNT
end

local function isNoncombatPet(collectibleData)
	return collectibleData:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
end

local function isHouse(collectibleData)
	return collectibleData:GetCategoryType() == COLLECTIBLE_CATEGORY_TYPE_HOUSE
end

local subcategories = {
	[VAR_CATEGOY_ID_HOUSING] = { -- "Housing"
		["group"] = {COLLECTIBLE_CATEGORY_TYPE_HOUSE},
		['categoryFilterFunctions'] = {ZO_CollectibleCategoryData.IsHousingCategory},
		['collectibleFilterFunctions'] = {isHouse},
	},
	[VAR_CATEGOY_ID_MOUNTS] = { -- "Mounts"
		["group"] = {COLLECTIBLE_CATEGORY_TYPE_MOUNT},
		['categoryFilterFunctions'] = {ZO_CollectibleCategoryData.IsStandardCategory},
		['collectibleFilterFunctions'] = {isMount},
	},
	[VAR_CATEGOY_ID_VANITY_PET] = { -- "Non-Combat Pets"
		["group"] = {COLLECTIBLE_CATEGORY_TYPE_VANITY_PET},
		['categoryFilterFunctions'] = {ZO_CollectibleCategoryData.IsStandardCategory},
		['collectibleFilterFunctions'] = {isNoncombatPet},
	},
}

local RANDOM_MOUNT_TYPE_ICONS =
{
	[RANDOM_MOUNT_TYPE_FAVORITE] = "EsoUI/Art/Collections/Random_FavoriteMount.dds",
	[RANDOM_MOUNT_TYPE_ANY] = "EsoUI/Art/Collections/Random_AnyMount.dds",
}

local _accountStorage
local _characterStorage

local function isFoundInPattern(input, pattern)
    for ptrn in string.gmatch(pattern, '(%w+)') do
        if select(2,input:gsub('^' .. ptrn .. '%W+','')) + select(2,input:gsub('%W+' .. ptrn .. '$','')) +
             select(2,input:gsub('^' .. ptrn .. '$','')) + select(2,input:gsub('%W+' .. ptrn .. '%W+','')) > 0 then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local IJA_FavoriteCollectibles = ZO_InitializingCallbackObject:Subclass()

function IJA_FavoriteCollectibles:Initialize(control)
	self.control = control
	zo_mixin(self, addonInfo)
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)

		local worldName = GetWorldName()
		_accountStorage = ZO_SavedVars:NewAccountWide(addonInfo.savedVariables, svVersion, nil, defaults, worldName)
		_characterStorage = ZO_SavedVars:NewCharacterNameSettings(addonInfo.savedVariables, svVersion, nil, favoritesDefaults, worldName)

		self.savedVars = _accountStorage
		
		
		self.dirty = true

		self:RegisterDialogues()
		self:InitializeSettings()
		self:SetupControls()

		local function onCollectibleUpdated(collectibleId)
			self:OnCollectibleUpdated(collectibleId)
		end

--		IJA_FavoriteCollectibles:RegisterCallback("OnCollectibleUpdated", onCollectibleUpdated)
--		ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectibleUpdated", onCollectibleUpdated)

	end
	control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
--			d( self.displayName .. " version: " .. self.version)
		
	--	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function(eventCode, ...) self:OnPlayerActivated(...) end)
		self:PerformDeferredInitialization()
--		ZO_COLLECTIBLE_DATA_MANAGER:RebuildCollection()
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

function IJA_FavoriteCollectibles:GetCollectionSystemObject()
	if SYSTEMS:IsShowing("collectionsCompanion") then
		return SYSTEMS:GetObject("collectionsCompanion")
	else
		return SYSTEMS:GetObject(ZO_COLLECTIONS_SYSTEM_NAME)
	end
end

---------------------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------------------
function IJA_FavoriteCollectibles:RegisterDialogues()
    local function releaseDialog(dialogueName)
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogueName)
    end
	
	ZO_Dialogs_RegisterCustomDialog("IJA_RELOAD_UI_DIALOGUE",
	{
        canQueue = true,
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title = {
			text = LibAddonMenu2.util.L["RELOAD_DIALOG_TITLE"],
		},
		mainText = {
			text = LibAddonMenu2.util.L["RELOAD_DIALOG_TEXT"],
		},
		buttons = {
			[1] = {
				text = LibAddonMenu2.util.L["RELOAD_DIALOG_RELOAD_BUTTON"],
				callback = function() ReloadUI() end,
			},
			[2] = {
				text = LibAddonMenu2.util.L["RELOAD_DIALOG_DISCARD_BUTTON"],
				callback = function(dialog)
					local data = dialog.data
					self:CreateSavedFavorites(data.copyData)
					releaseDialog()
				end,
			}
		},
	})
	
	
	ZO_Dialogs_RegisterCustomDialog("IJA_COPY_SAVE_WARN_DIALOGUE",
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = SI_IJA_FC_COPY_SAVES_TITLE,
		},
		mainText =
		{
			text = SI_IJA_FC_COPY_SAVES_TEXT,
		},
		
		buttons = {
			[1] = {
                onShowCooldown = 2000,
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_YES),
				callback = function(dialog)
					local data = dialog.data
					
					local oldfavorites = self.favorites
					self:CreateSavedFavorites(data.copyData)
					ZO_Dialogs_ShowDialog("IJA_RELOAD_UI_DIALOGUE", { oldfavorites = oldfavorites})
					
					releaseDialog()
				end,
			},
			[2] = {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_NO),
				callback = function()
					releaseDialog()
				end,
			}
		},
	})
end

function IJA_FavoriteCollectibles:SetFavorites(savedVars)
	if savedVars.sort and type(savedVars.sort) ~= 'number' then savedVars.sort = 0 end
	
	-- A fix to get the actual sound from the index if it was previously set as index.
	if SOUNDS[self.savedVars.alertSound] then self.savedVars.alertSound = SOUNDS[self.savedVars.alertSound] end

	self.favorites = savedVars.favorites
	
	if not self.favorites.lastUsedRandomMount then
		self.favorites.lastUsedRandomMount = RANDOM_MOUNT_TYPE_ANY
	end
	
	self:SetCollectibleDataManagerVariables()
	self:ImportFavorites()
end

function IJA_FavoriteCollectibles:CreateSavedFavorites(defaults)
	local newfavorites
	if self.savedVars.accountWide then
		self.savedVars.favorites = defaults.favorites
		self:SetFavorites(self.savedVars)
	else
		_characterStorage.version = nil
		_characterStorage = ZO_SavedVars:NewCharacterNameSettings(self.savedVariables, svVersion, nil, defaults, GetWorldName())
		self:SetFavorites(_characterStorage)
	end
end

function IJA_FavoriteCollectibles:InitializeSettings()
	local function onCollectionUpdated()
		ZO_COLLECTIBLE_DATA_MANAGER:MarkCollectionDirty()
	end
	
	local LAM2 = LibAddonMenu2
	if not LAM2 then return end
	
	local function sortFunction(a, b)
		return a < b
	end
	
	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
		registerForDefaults = true,
		registerForRefresh = true,
	}
	LAM2:RegisterAddonPanel(self.name .. '_LAM', panelData)
	
	local choices = {''}
	local choicesValues = {1}
	
	local function getCharacterNamesAndindexes()
		local characterNames, choiceIndexes = {}, {}
		for name, sv in pairs(_G[addonInfo.savedVariables][GetWorldName()][GetDisplayName()]) do
			if name ~= GetUnitName("player") then
				table.insert(characterNames, name)
			end
		end

		table.sort(characterNames, sortFunction)
		return characterNames
	end
	local characterNames = getCharacterNamesAndindexes()

	local copyData
	local currentName = ''
	local copyButton = self.name .. '_LAM_Copy'

	local function getCopyWarning()
		return zo_strformat(SI_IJA_FC_COPY_SAVES_WARN, currentName)
	end
	
	-- I plan to allow changing of the alert sound used when importing is complete.
	-- currently, there are too many sounds to fit in the drop down.
	local alertSounds = {}
	local ignoredSounds = {
		['TRADING_HOUSE_SEARCH_INITIATED'] = true,
		['LFG_READY_CHECK'] = true,
		['LFG_COMPLETE_ANNOUNCEMENT'] = true,
		['GROUP_ROLE_DESELECTED'] = true,
		['GROUP_PROMOTE'] = true,
		['AVA_KEEP_CAPTURED'] = true,
	}
	for soundId, sound in pairs(SOUNDS) do
		if not ignoredSounds[soundId] and isFoundInPattern(soundId, 'LFG|P2P|SEARCH|CAMPAIGN|GROUP|AVA|EMPEROR|ENLIGHTENED|ARTIFACT') then
			table.insert(alertSounds, sound)
		end
	end
	table.sort(alertSounds, sortFunction)
	table.insert(alertSounds, 1, SOUNDS.ABILITY_NOT_READY)
	
	self.alertSounds = alertSounds
	
	local optionsTable = {
		{ type = "header",
 --		   name = GetString(),
			width = "full",
		},
		{ type = "checkbox",	-- account wide savedVars
			name = GetString(SI_IJA_FC_ACCOUNT),
			tooltip = GetString(SI_IJA_FC_ACCOUNT_TIP),
			getFunc = function()
				return self.savedVars.accountWide
			end,
			setFunc = function(value)
				self.savedVars.accountWide = value
				copyCharacterSV = ''
			end,
			width = "full",
			requiresReload = true,
		},
		{ type = "header",
 		   name = GetString(SI_IJA_FC_IMPORTING_HEADER),
			width = "full",
		},
		{ type = "dropdown",	-- select character
			name = GetString(SI_IJA_FC_COPY_SAVES_TITLE),
			choices = characterNames,
			choicesValues = characterNames,
			getFunc = function() return '' end,
			setFunc = function(value)
				currentName = value
				copyData = _G[addonInfo.savedVariables][GetWorldName()][GetDisplayName()][value]
			end,
			width = "half",
		},
		{ type = "button",		-- reset
			name = 'Copy',
			tooltip = GetString(SI_IJA_FC_COPY_SAVES_TIP),
			warning = getCopyWarning,
			func = function()
				if copyData then
					local defaultData = {favorites = copyData.favorites}
					self:CreateSavedFavorites(defaultData)
					copyData = nil
					currentName = ''
				end
			end,
			disabled = function() return copyData == nil end,
            width = "half",
			isDangerous = true,
			reference = copyButton,
		},
		{ type = "dropdown",	-- selected alert sound
			name = GetString(SI_AUDIO_OPTIONS_SOUND_ENABLED),
			choices = alertSounds,
			choicesValues = alertSounds,
			getFunc = function()return self.savedVars.alertSound end,
			setFunc = function(value)
				self.savedVars.alertSound = value
				PlaySound(value)
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "dropdown",	-- selectedFrameStyle
			name = GetString(SI_IJA_FC_FILTER),
			choices = {GetString(SI_IJA_FC_SORT0), GetString(SI_IJA_FC_SORT1), GetString(SI_IJA_FC_SORT2)},
			choicesValues = {0,1,2},
			getFunc = function() return self.savedVars.sort end,
			setFunc = function(value)
				if self.savedVars.sort ~= value then
					self.savedVars.sort = value
					onCollectionUpdated()
				end
			end,
			width = "full",
		},
		{ type = "checkbox",	-- filter out unusable
			name = GetString(SI_IJA_FC_FILTER),
			tooltip = GetString(SI_IJA_FC_FILTER_TIP),
			getFunc = function()
				return self.savedVars.filterInvalid
			end,
			setFunc = function(value)
				self.savedVars.filterInvalid = value
			--	ZO_COLLECTIBLE_DATA_MANAGER:RebuildCollection()
				onCollectionUpdated()
			end,
			width = "full",
		},		
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox",	-- filter out unusable
			name = GetString(SI_IJA_FC_HIDE_ICON),
			tooltip = GetString(SI_IJA_FC_HIDE_ICON_TIP),
			getFunc = function()
				return self.savedVars.hideIcon
			end,
			setFunc = function(value)
				self.savedVars.hideIcon = value
				
				self:UpdateRandomMountIcon(GetRandomMountType(GAMEPLAY_ACTOR_CATEGORY_PLAYER))
			end,
			width = "full",
		},		
	}
	LAM2:RegisterOptionControls(self.name .. '_LAM', optionsTable)
end

---------------------------------------------------------------------------------------------------------------
-- Favorite Importing
---------------------------------------------------------------------------------------------------------------
-- Update = Add - Name = Dwarven Spider
function IJA_FavoriteCollectibles:SetOrClearCollectibleUserFlags(collectibles)
	local function updateFavoriteStatus(nextId, isNextFavorite)
		collectibleId, isFavorite = nextId, isNextFavorite
		nextId, isNextFavorite = next(collectibles, nextId)
		
		if collectibleId ~= nil then
			local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
			
			local delay = nextId ~= nil and 500 or 0
			SetOrClearCollectibleUserFlag(collectibleId, COLLECTIBLE_USER_FLAG_FAVORITE, isFavorite)
			
			zo_callLater(function()
				updateFavoriteStatus(nextId, isNextFavorite)
			end, delay)
		else
			d( GetString('SI_IJA_FC_IMPORTING', 2))
			PlaySound(self.savedVars.alertSound)
		end
	end
	
	updateFavoriteStatus(next(collectibles))
end

function IJA_FavoriteCollectibles:ImportFavorites()
		-- This will clear unsaved favorites and set saved ones.
	local collectibles = self:GetListsForImport()
	
	if NonContiguousCount(collectibles) > 0 then
		d( GetString('SI_IJA_FC_IMPORTING', 1))
		self:SetOrClearCollectibleUserFlags(collectibles)
	end
end

function IJA_FavoriteCollectibles:GetListsForImport()
	local collectibles = {}
	
	for collectibleId, collectibleData in pairs(ZO_COLLECTIBLE_DATA_MANAGER.collectibleIdToDataMap) do
		if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) and collectibleData:IsFavoritable() then
			local isFavorite = self.favorites[collectibleId] or false
			
			if isFavorite == not collectibleData:IsFavorite() then
				collectibles[collectibleId] = isFavorite
			end
		elseif collectibleData:IsUserFlagSet(COLLECTIBLE_USER_FLAG_FAVORITE) then
			-- Remove any collectible not a mount from the server favorites.
			collectibles[collectibleId] = false
		end
	end
	
	return collectibles
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function IJA_FavoriteCollectibles:SetupControls()
	local function setMovable()
		self.control:SetMovable(not self.savedVars.randomMountIcon.locked)
	end
	setMovable()

	local function showTooltip()
		ClearTooltip(InformationTooltip)
		InitializeTooltip(InformationTooltip, self.control, BOTTOM, 0, 0)

		local lockString = self.savedVars.randomMountIcon.locked and SI_ITEM_ACTION_UNMARK_AS_LOCKED or SI_ITEM_ACTION_MARK_AS_LOCKED
		SetTooltipText(InformationTooltip, zo_strformat(SI_IJA_FC_ICON_TOOLTIP, GetString(lockString)))
		jo_callLater('Hide_Mount_Icon_Tooltip', function()
			ClearTooltip(InformationTooltip)
		end, 2000)
	end

	self.control:SetHandler('OnMoveStop', function(control)
		var_anchor:SetFromControlAnchor(control)
		self.savedVars.randomMountIcon.anchor = var_anchor
	end)
	
	self.control:SetHandler("OnMouseUp", function(control, button, upInside)
		if upInside then
			if button == MOUSE_BUTTON_INDEX_RIGHT then
				self.savedVars.randomMountIcon.locked = not self.savedVars.randomMountIcon.locked
				setMovable()
				showTooltip()
			elseif MOUSE_BUTTON_INDEX_LEFT and self.savedVars.randomMountIcon.locked then
				-- TODO: what can I have left-click on locked icon do?
			end
		end
	end)
	
	self.control:SetHandler("OnMouseEnter", function()
		showTooltip()
	end)
	
	self.control:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)
	
	local savedAnchor = self.savedVars.randomMountIcon.anchor
	if savedAnchor ~= nil  then
		var_anchor:ResetToAnchor(savedAnchor)
		var_anchor:SetTarget(GuiRoot)
		var_anchor:Set(self.control)
	end
	
	self.fragment = ZO_HUDFadeSceneFragment:New(self.control)
	
	HUD_SCENE:AddFragment(self.fragment)
	HUD_UI_SCENE:AddFragment(self.fragment)
			
	self:UpdateRandomMountIcon(GetRandomMountType(GAMEPLAY_ACTOR_CATEGORY_PLAYER))
end

function IJA_FavoriteCollectibles:InitializeHooks()
	local function onRebuildCollection()
		self:BuildFavoriteSubcategories()
		self:FireCallbacks('OnRebuildCollection')
	end
	
	SecurePostHook(ZO_COLLECTIBLE_DATA_MANAGER, 'RebuildCollection', onRebuildCollection)
	onRebuildCollection()

	ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectibleUserFlagsUpdated", function(collectibleId)
		local object = self:GetCollectionSystemObject()
		if not object then return end
		if IsInGamepadPreferredMode() then
			object:OnCollectibleUpdated()

			-- Lets back out to the category list if the removed favorite was the last one in the list.
			if object.collectionList.list:IsEmpty() then
				object:ViewCategory()
			end
		else
		--	object:OnCollectibleUpdated(collectibleId)
			object:UpdateCollectionLater()
		end
		ZO_COLLECTIBLE_DATA_MANAGER:OnCollectibleUpdated(collectibleId)
	end)

	SecurePostHook('SetRandomMountType', function(randomMountType, actorCategory)
		if actorCategory == GAMEPLAY_ACTOR_CATEGORY_PLAYER and randomMountType ~= RANDOM_MOUNT_TYPE_NONE then
			self.favorites.lastUsedRandomMount = randomMountType
			self:UpdateRandomMountIcon(randomMountType)
		end
	end)
	
	local function onCollectionUpdated()
		self:ImportFavorites()
	end
--	ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", onCollectionUpdated)
--	onCollectionUpdated()

end

function IJA_FavoriteCollectibles:PerformDeferredInitialization()
	if _accountStorage.accountWide then
		self:SetFavorites(_accountStorage)
	else
		self:SetFavorites(_characterStorage)
	end

	self:InitializeHooks()
	self:InitializeCollectibles_GP()
	self:InitializeCollectibles_KB()
end

function IJA_FavoriteCollectibles:BuildFavoriteSubcategories()
	self.dirty = false
	self.subcategoryObjectPool:ReleaseAllObjects()
	for categoryId, category in pairs(subcategories) do
		local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataById(categoryId)
		local categoryIndex = categoryData:GetCategoryIndicies()
		
		categoryData.hasFavoritesSubcategory = true
		local subcategoryData = self.subcategoryObjectPool:AcquireObject()
		local subcategoryIndex = GetNumSubcategoriesInCollectibleCategory(categoryIndex) + 1
		subcategoryData:BuildData(categoryIndex, subcategoryIndex, category)
		table.insert(categoryData.orderedSubcategories, 1, subcategoryData)
	end
end

function IJA_FavoriteCollectibles:UpdateRandomMountIcon(playerRandomMountType)
	local iconFile = RANDOM_MOUNT_TYPE_ICONS[playerRandomMountType]
	
	local iconHidden = iconFile == nil
	
	if iconFile and iconFile ~= self.currentIcon then
		self.currentIcon = iconFile
		self.control.icon:SetTexture(iconFile)
	end
	
	iconHidden = iconHidden or self.savedVars.hideIcon
	
	self.fragment:SetHiddenForReason("iconHidden", iconHidden)
end

function IJA_FavoriteCollectibles:ToggleRandomMount()
    local playerRandomMountType = GetRandomMountType(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
	
	local newRandomMountType = RANDOM_MOUNT_TYPE_NONE
    if playerRandomMountType == RANDOM_MOUNT_TYPE_NONE then
		newRandomMountType = self.favorites.lastUsedRandomMount
    end
	
	PlaySound(SOUNDS.DEFAULT_CLICK)
	self:UpdateRandomMountIcon(newRandomMountType)
	SetRandomMountType(newRandomMountType, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

---------------------------------------------------------------------------------------------------------------
-- XML Handlers
---------------------------------------------------------------------------------------------------------------
function IJA_FavoriteCollectibles_Initialize( ... )
	IJA_FAVORITECOLLECTIBLES = IJA_FavoriteCollectibles:New( ... )
end

function IJA_FavoriteCollectibles_OnKeybind( ... )
	IJA_FAVORITECOLLECTIBLES:ToggleRandomMount()
end







ZO_PostHook(GAMEPAD_COLLECTIONS_BOOK, 'OnCollectibleUpdated', function(self)
	if GAMEPAD_COLLECTIONS_BOOK.currentList then
		KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_COLLECTIONS_BOOK.currentList.keybind)
	end
end)



--	/script IJA_FAVORITECOLLECTIBLES:ImportFavorites()
--	/script IJA_FAVORITECOLLECTIBLES:UpdateRandomMountIcon()
--	/script IJA_FAVORITECOLLECTIBLES.fragment:SetHiddenForReason("iconHidden", true)
--	/script HUD_SCENE:RemoveFragment(IJA_FAVORITECOLLECTIBLES.fragment)
--	/script HUD_UI_SCENE:RemoveFragment(IJA_FAVORITECOLLECTIBLES.uiFragment)
--	/script HUD_UI_SCENE:AddFragment(IJA_FAVORITECOLLECTIBLES.uiFragment)
--	/script HUD_SCENE:RemoveFragment(IJA_FAVORITECOLLECTIBLES.hudFragment)