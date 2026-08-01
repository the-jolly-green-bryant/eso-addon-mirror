local ADDON_VERSION = 1776
local ADDON_NAME = "HousingHub"
local ADDON_TITLE = "Housing Hub"
local ADDON_ROOT_PATH = "user:/AddOns/EssentialHousingTools/HousingHub/"
local ROOT_PATH = "/EssentialHousingTools/"
local HUB_PATH = ROOT_PATH .. "HousingHub/"
local HUB_TEXTURE_PATH_FORMAT = HUB_PATH .. "media/%s.dds"
local ROOT_EFFECT_TEXTURE_PATH_FORMAT = ROOT_PATH .. "media/%s.dds"

local LAM = LibAddonMenu2

function IsNewerEssentialHousingHubVersionAvailable()
	-- A newer version is already installed.
	return EssentialHousingHub and EssentialHousingHub.Version and EssentialHousingHub.Version > ADDON_VERSION
end

if IsNewerEssentialHousingHubVersionAvailable() then
	return
end

function IsEssentialHousingHubRootPathValid()
	local manager = GetAddOnManager()
	local numAddOns = manager:GetNumAddOns()
	for index = 1, numAddOns do
		local name, title, author, description, enabled = manager:GetAddOnInfo(index)
		if enabled and name == ADDON_NAME or title == ADDON_TITLE then
			local rootPath = manager:GetAddOnRootDirectoryPath(index)
			return string.lower(rootPath) == string.lower(ADDON_ROOT_PATH)
		end
	end
	return false
end

function CheckEssentialHousingHubRootPath()
	local valid = IsEssentialHousingHubRootPathValid()
	if not valid then
		zo_callLater(function()
			df("WARNING!  The %s add-on appears to be installed in an incorrect AddOns folder.", ADDON_TITLE)
			df("Please uninstall any copies of %s, and then reinstall %s to the default installation folder:", ADDON_TITLE, ADDON_TITLE)
			d("/Documents/Elder Scrolls Online/live/AddOns/EssentialHousingTools/HousingHub")
			d(" *Note: Do -NOT- remove any related SavedVariables files as they contain your settings, favorites, recently visited homes, etc.")
		end, 6000)
	end
	return valid
end

if not CheckEssentialHousingHubRootPath() then
	return
end

if not KEYBINDING_MANAGER.IsChordingAlwaysEnabled or not KEYBINDING_MANAGER:IsChordingAlwaysEnabled() then
	-- Enable the Keybind Chording (ALT+key or CTRL+key or SHIFT+key) feature.
	function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
		return true
	end
end

do
	local playerActivated, debugBuffer = false, {}
	function dhub(msg, ...)
		if playerActivated then df("[dd]"..msg, ...)
		else table.insert(debugBuffer, "[dd] "..string.format(msg, ...).."\n") end
	end
	EVENT_MANAGER:RegisterForEvent("HubDebugging", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent("HubDebugging", EVENT_PLAYER_ACTIVATED)
		playerActivated = true if 0 ~= #debugBuffer then d(table.concat(debugBuffer)) debugBuffer = {} end
	end)
end

-- Hub sort comparer forward declarations
local HubEntryDefaultComparer, HubEntryHouseTitleComparer, HubEntryOwnerComparer, HubEntryFurnitureComparer, HubEntryUnvisitedComparer, HubEntryLastVisitComparer, HubEntryNewestOpenHousesComparer, HubEntryFavIndexComparer, HubEntryCategoryComparer, HubEntryHighestTotalValueComparer, HubEntryLowestTotalValueComparer, HubEntryHighestUnitValueComparer, HubEntryLowestUnitValueComparer, HubEntryTrendingScoreComparer

---[ EssentialHousingHub Singleton Class ]---

local EHH = ZO_InitializingObject:Subclass()

function EHH:Initialize()
	EssentialHousingHub = self

	self.AddOnEnabled = true
	self.Name = ADDON_NAME
	self.Title = ADDON_TITLE
	self.AddOnVersion = ADDON_VERSION
	self.Author = "@Architectura, @Cardinal05"
	self.Modules = {}

	self.DisplayName = GetDisplayName()
	self.DisplayNameLower = string.lower(self.DisplayName)

	do
		self.IsDev = "@cardinal05" == self.DisplayNameLower or "@architectura" == self.DisplayNameLower
		local world = string.lower(GetWorldName())
		if not world or "" == world then
			self.World = ""
		elseif "na" == string.sub(world, 1, 2) then
			self.World = "na"
		elseif "eu" == string.sub(world, 1, 2) then
			self.World = "eu"
		else
			self.World = "pts"
		end
	end

	-- Order matters
	self:InitializeTextures()
	self:InitializeDefs()
	self:InitializeState()
	self:InitializeStrings()

	local function OnAddOnLoaded(_, addOnName)
		if addOnName == self.Name then
			self:InitializeSavedVariables()

			HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_ADD_ON_LOADED)
			HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_PLAYER_ACTIVATED, function(...) return self:OnPlayerActivated(...) end)
		end
	end

	HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

function EHH:InitializeSavedVariables()
	local vars = ZO_SavedVars:NewAccountWide(self.Defs.SavedVariablesKey, self.Defs.SavedVariablesVersion, nil, {}, nil, "$InstallationWide")
	self.Vars = vars
--[[
	if not vars.DataVersion then
		-- If no account-wide saved variables exist then we check to see if we can migrate from installation-wide saved variables.
		local globalVars = ZO_SavedVars:NewAccountWide(self.Defs.SavedVariablesKey, self.Defs.SavedVariablesVersion, nil, {}, nil, "$InstallationWide")
		if "table" == type(globalVars) then
			local metaTable = getmetatable(globalVars)
			if "table" == type(metaTable) and "table" == type(metaTable.__index) then
				-- If installation-wide saved variables exist then migrate that data to the account-wide saved variables.
				local globalKeys = {}
				for key in pairs(metaTable.__index) do
					table.insert(globalKeys, key)
				end

				for _, key in ipairs(globalKeys) do
					vars[key] = globalVars[key]
				end

				for _, key in ipairs(globalKeys) do
					globalVars[key] = nil
				end
			end
		end
	end
]]
	if not vars.DataVersion then vars.DataVersion = 1 end
	if not vars.Data then vars.Data = {} end
	if not vars.Data.FavoriteHouses then vars.Data.FavoriteHouses = {} end
	if not vars.Data.PersistentState then vars.Data.PersistentState = {} end
	if not vars.Data.RecentlyVisitedHouses then vars.Data.RecentlyVisitedHouses = {} end

	if not vars.SettingsVersion then vars.SettingsVersion = 1 end
	if not vars.Settings then vars.Settings = {} end
	if not vars.Settings.HubSorts then vars.Settings.HubSorts = {} end

	if not vars.UserVersion then vars.UserVersion = 1 end
	if not vars.User then vars.User = {} end
	if not vars.User.AccountName then vars.User.AccountName = self.DisplayName end
	if not vars.User.AccountNameLower then vars.User.AccountNameLower = self.DisplayNameLower end

	self.IsAccountNameChanged = vars.User.AccountNameLower ~= self.DisplayNameLower
end

function EHH:InitializeTextures()
	self.BaseTexturePathFormat = HUB_TEXTURE_PATH_FORMAT
	self.BaseEffectTexturePathFormat = ROOT_EFFECT_TEXTURE_PATH_FORMAT
	self.BaseEffectCustomTexturePathFormat = string.format(ROOT_EFFECT_TEXTURE_PATH_FORMAT, "custom/%s")

	self.Textures =
	{
		ARROW_1 = "arrow_01",
		GLASS_DIFFUSE = "glass_diffuse",
		GLASS_FROSTED = "glass_frosted",
		HOUSING_HUB_LOGO = "housing_hub_logo",
		HUB_BACKDROP_OVERLAY = "hub_backdrop_overlay",
		HUB_BUTTON = "hub_button",
		HUB_CAUSTIC = "hub_caustic",
		HUB_CAUSTIC2 = "hub_caustic2",
		HUB_LOGO = "hub_logo",
		HUB_LOGO_CONNECTIONS = "hub_logo_connections",
		HUB_LOGO_SHADED = "hub_logo_shaded",
		HUB_ROW_HOUSE_MASK = "hub_row_house_mask",
		HUB_SHINE = "hub_shine",
		HUB_TILE_EXTENSION = "hub_tile_extension",
		HUB_WAVES_1 = "hub_waves_1",
		HUB_WAVES_2 = "hub_waves_2",
		HUB_WORMHOLE = "hub_wormhole",
		HUB_WORMHOLE_CENTER = "hub_wormhole_center",
		HUB_WORMHOLE_OVERLAY = "hub_wormhole_overlay",
		HUB_BEAM_CENTER = "hub_beam_center",
		ICON_ALERT = "icon_alert",
		ICON_ALPHA = "icon_alpha",
		ICON_ANCHOR = "icon_anchor",
		ICON_ARROW = "icon_arrow",
		ICON_BACK_ARROW = "icon_back_arrow",
		ICON_BLADE = "icon_blade",
		ICON_BLADE_OVER = "icon_blade_over",
		ICON_BOOK = "icon_book",
		ICON_BUTTON = "icon_button",
		ICON_BUTTON_DOWN = "icon_button_down",
		ICON_BUTTON_OVER = "icon_button_over",
		ICON_CALENDAR = "icon_calendar",
		ICON_CAMERA = "icon_camera",
		ICON_CHECKED = "icon_checked",
		ICON_CHECKED_N = "icon_checked_n",
		ICON_CLOSE = "icon_close",
		ICON_CLOSED_HOUSE = "icon_closed_house",
		ICON_COMPASS_CARDINAL = "icon_compass_cardinal",
		ICON_COMPASS_RELATIVE = "icon_compass_relative",
		ICON_CONTINUE = "icon_continue",
		ICON_CROWN = "icon_crown",
		ICON_DECOTRACK_PROMO = "icon_decotrack_promo",
		ICON_ESO_HOUSING_STREAM = "eso_housing_stream",
		ICON_FAVORITE = "icon_favorite",
		ICON_FAVORITE_DISABLED = "icon_favorite_disabled",
		ICON_FORWARD_ARROW = "icon_forward_arrow",
		ICON_FURNITURE = "icon_furniture",
		ICON_FX = "icon_fx",
		ICON_GLOBE = "icon_globe",
		ICON_GOLD = "esoui/art/currency/currency_gold.dds",
		ICON_GUESTBOOK = "icon_guestbook",
		ICON_GUESTS = "icon_guests",
		ICON_GUILD_MOTD = "icon_guild_motd",
		ICON_HELP = "icon_help",
		ICON_HUB_WIDGET = "icon_hub_widget",
		ICON_INDETERMINATE = "icon_indeterminate",
		ICON_LINK_SHARE = "icon_link_share",
		ICON_LIST_ROWS = "icon_list_rows",
		ICON_LIST_TILES = "icon_list_tiles",
		ICON_LIVE = "icon_live",
		ICON_HOUSE_JUMP = "icon_house_jump",
		ICON_LOCK = "icon_lock",
		ICON_MAIL = "icon_mail",
		ICON_MULTISELECT = "icon_multiselect",
		ICON_NOTIFICATION = "icon_notification",
		ICON_OPEN_HOUSE = "icon_open_house",
		ICON_PIN = "icon_pin",
		ICON_PIP = "icon_pip",
		ICON_QUILL = "icon_quill",
		ICON_SHARE_FX = "icon_share_fx",
		ICON_TRADEABLE = "icon_tradeable",
		ICON_TRAVEL = "icon_travel",
		ICON_TWITCH_PLAY = "twitch_play",
		ICON_TWITCH_PLAY_GLOW = "twitch_play_glow",
		ICON_UNCHECKED = "icon_unchecked",
		ICON_VIDEO = "icon_video",
		OPEN_HOUSE_SIGN = "open_house_sign",
		OVERLAY_NEW = "overlay_new",
		OVERLAY_OPEN_HOUSE = "overlay_open_house",
		SLIDER_BORDER = "slider_border",
		SLIDER_INDICATOR = "slider_indicator",
		SOLID = "solid",
		SOLID_SOFT = "square_soft",
		SWORDS_AND_SHIELD = "swords_and_shield",
	}

	for key, value in pairs(self.Textures) do
		if not string.find(value, ".dds") then
			self.Textures[key] = string.format(HUB_TEXTURE_PATH_FORMAT, value)
		end
	end

	self.Textures.ICON_PIP = zo_iconFormat(self.Textures.ICON_PIP, 11, 11)
	self.Textures.ICON_CROWN = zo_iconFormat(self.Textures.ICON_CROWN, 20, 20)
	self.Textures.ICON_HUB_WIDGET = zo_iconFormat(self.Textures.ICON_HUB_WIDGET, 128, 28)
	self.Textures.ICON_NOTIFICATION = zo_iconFormat(self.Textures.ICON_NOTIFICATION, 20, 20)
	self.Textures.ICON_TRADEABLE = zo_iconFormat(self.Textures.ICON_TRADEABLE, 20, 20)
	self.Textures.INLINE_ICON_ALPHA = zo_iconFormat(self.Textures.ICON_ALPHA, 1, 1)
	self.Textures.INLINE_ICON_BACK_ARROW = zo_iconFormat(self.Textures.ICON_BACK_ARROW, 20, 20)
	self.Textures.INLINE_ICON_CALENDAR = zo_iconFormat(self.Textures.ICON_CALENDAR, 28, 28)
	self.Textures.INLINE_ICON_CROWN = self.Textures.ICON_CROWN
	self.Textures.INLINE_ICON_FORWARD_ARROW = zo_iconFormat(self.Textures.ICON_FORWARD_ARROW, 20, 20)
	self.Textures.INLINE_ICON_FX = zo_iconFormat(self.Textures.ICON_FX, 26, 26)
	self.Textures.INLINE_ICON_HOUSE_JUMP = zo_iconFormat(self.Textures.ICON_HOUSE_JUMP, 28, 28)
	self.Textures.INLINE_ICON_LIST_ROWS = zo_iconFormat(self.Textures.ICON_LIST_ROWS, 32, 32)
	self.Textures.INLINE_ICON_LIST_TILES = zo_iconFormat(self.Textures.ICON_LIST_TILES, 32, 32)
	self.Textures.INLINE_ICON_OPEN_HOUSE = zo_iconFormat(self.Textures.ICON_OPEN_HOUSE, 26, 26)
	self.Textures.INLINE_ICON_SHARE_FX = zo_iconFormat(self.Textures.ICON_SHARE_FX, 28, 28)
	self.Textures.INLINE_ICON_TRAVEL = zo_iconFormat(self.Textures.ICON_TRAVEL, 28, 28)
end

function EHH:InitializeDefs()
	self.Defs =
	{
		Name = ADDON_TITLE,
		BasePath = HUB_PATH,
		BaseTexturePathFormat = HUB_TEXTURE_PATH_FORMAT,
		DefaultSettings = {},
		SavedVariablesKey = ADDON_NAME .. "SavedVars",
		SavedVariablesVersion = 1,
		EnableEffects = true,
		BaseEffectItemTypeId = 1000000,
		BagIds =
		{
			BAG_BACKPACK,
			BAG_BANK,
			BAG_SUBSCRIBER_BANK,
			BAG_HOUSE_BANK_ONE,
			BAG_HOUSE_BANK_TWO,
			BAG_HOUSE_BANK_THREE,
			BAG_HOUSE_BANK_FOUR,
			BAG_HOUSE_BANK_FIVE,
			BAG_HOUSE_BANK_SIX,
			BAG_HOUSE_BANK_SEVEN,
			BAG_HOUSE_BANK_EIGHT,
			BAG_HOUSE_BANK_NINE,
			BAG_HOUSE_BANK_TEN
		},
		Controls =
		{
			Buttons =
			{
				Height = 20,
				HorizontalMargin = 10,
			},
			HubWindow =
			{
				Width = 1034,
				Height = 640,
			},
		},
		Dialogs =
		{
			Alert = ADDON_NAME .. ".Alert",
			Confirm = ADDON_NAME .. ".Confirm",
		},
		Limits =
		{
			HouseJumpRequestTimeout = 25000,
			MaxBroadcastHours = 2,
			MaxBroadcastSeconds = 2 * 60 * 60,
			MaxChannelInactivityDays = 30,
			MaxChannelInactivitySeconds = 30 * 24 * 60 * 60,
			MaxCommunityServerTimestampDifference = 60 * 60 * 24,
			MaxFavoriteHouses = 10000,
			MaxGuildNoteLength = 250,
			MaxHouseId = 500,
			MaxJournalSignatureAgeForNewStatus = 7,
			MaxOpenHouseAgeForNewStatus = 7,
			MaxRecentlyVisitedHouses = 2000,
			MaxSavedStringLength = 1999,
			MaxTrendingHouses = 120,
			MinEffectGroupId = 99990001,
			MaxEffectGroupId = 99990032,
			MinWidgetButtonDragClickMS = 300,
			BaseWidgetButtonInset = 80,
			BaseWidgetButtonIncrementalOffsetX = 18,
			MinWidgetButtonOffset = 70,
			MaxWidgetButtonOffset = 246,
			PrimaryWidgetButtonOffset = 126,
			PrimaryWidgetStatsOffset = 134,
			PerFurnitureStateChangeDelayMS = 600,
			PerFurnitureStateChangeDurationMS = 5000,
			QueryFurnitureStateIntervalMS = 20,
		},
		FurnitureLimits =
		{
			[HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE] = "Special Collectibles",
			[HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM] = "Special Furnishings",
			[HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE] = "Collectible Furnishings",
			[HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM] = "Traditional Furnishings",
		},
		Urls =
		{
			DownloadCommunityMac = "https://essentialhousingcommunity.azurewebsites.net/mac/",
			DownloadDecoTrack = "https://www.esoui.com/downloads/info2100-DecoTrack.html",
			SetupCommunityPC = "https://youtu.be/hJJdbJB8HVM",
			SetupCommunityMac = "https://www.youtube.com/watch?v=HM03EzlVyY4",
			SetupOpenHouse = "https://www.youtube.com/watch?v=1WveCn7E0ZY",
		},
		RequestResults =
		{
			[HOUSING_REQUEST_RESULT_ALREADY_APPLYING_TEMPLATE] = "HOUSING_REQUEST_RESULT_ALREADY_APPLYING_TEMPLATE",
			[HOUSING_REQUEST_RESULT_ALREADY_BEING_MOVED] = "HOUSING_REQUEST_RESULT_ALREADY_BEING_MOVED",
			[HOUSING_REQUEST_RESULT_ALREADY_SET_TO_MODE] = "HOUSING_REQUEST_RESULT_ALREADY_SET_TO_MODE",
			[HOUSING_REQUEST_RESULT_BLOCKED_BY_BLACKLISTED_COLLECTIBLE] = "HOUSING_REQUEST_RESULT_BLOCKED_BY_BLACKLISTED_COLLECTIBLE",
			[HOUSING_REQUEST_RESULT_FURNITURE_ALREADY_SELECTED] = "HOUSING_REQUEST_RESULT_FURNITURE_ALREADY_SELECTED",
			[HOUSING_REQUEST_RESULT_HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_INCORRECT_MODE] = "HOUSING_REQUEST_RESULT_INCORRECT_MODE",
			[HOUSING_REQUEST_RESULT_INVALID_FURNITURE_POSITION] = "HOUSING_REQUEST_RESULT_INVALID_FURNITURE_POSITION",
			[HOUSING_REQUEST_RESULT_INVALID_TEMPLATE] = "HOUSING_REQUEST_RESULT_INVALID_TEMPLATE",
			[HOUSING_REQUEST_RESULT_INVENTORY_REMOVE_FAILED] = "HOUSING_REQUEST_RESULT_INVENTORY_REMOVE_FAILED",
			[HOUSING_REQUEST_RESULT_IN_COMBAT] = "HOUSING_REQUEST_RESULT_IN_COMBAT",
			[HOUSING_REQUEST_RESULT_IN_SAFE_ZONE] = "HOUSING_REQUEST_RESULT_IN_SAFE_ZONE",
			[HOUSING_REQUEST_RESULT_IS_DEAD] = "HOUSING_REQUEST_RESULT_IS_DEAD",
			[HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED] = "HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED",
			[HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_ALREADY_OWN_UNIQUE] = "HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_ALREADY_OWN_UNIQUE",
			[HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_INVENTORY_FULL] = "HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_INVENTORY_FULL",
			[HOUSING_REQUEST_RESULT_ITEM_STOLEN] = "HOUSING_REQUEST_RESULT_ITEM_STOLEN",
			[HOUSING_REQUEST_RESULT_LINK_ALREADY_HAS_PARENT] = "HOUSING_REQUEST_RESULT_LINK_ALREADY_HAS_PARENT",
			[HOUSING_REQUEST_RESULT_LINK_ALREADY_LINKED] = "HOUSING_REQUEST_RESULT_LINK_ALREADY_LINKED",
			[HOUSING_REQUEST_RESULT_LINK_FAILED] = "HOUSING_REQUEST_RESULT_LINK_FAILED",
			[HOUSING_REQUEST_RESULT_LINK_HAS_NO_CHILDREN] = "HOUSING_REQUEST_RESULT_LINK_HAS_NO_CHILDREN",
			[HOUSING_REQUEST_RESULT_LINK_HAS_NO_PARENT] = "HOUSING_REQUEST_RESULT_LINK_HAS_NO_PARENT",
			[HOUSING_REQUEST_RESULT_LINK_HAS_TOO_MANY_CHILDREN] = "HOUSING_REQUEST_RESULT_LINK_HAS_TOO_MANY_CHILDREN",
			[HOUSING_REQUEST_RESULT_LINK_INFINITE_PARENT_LOOP] = "HOUSING_REQUEST_RESULT_LINK_INFINITE_PARENT_LOOP",
			[HOUSING_REQUEST_RESULT_LINK_NO_BAD_LINKAGE] = "HOUSING_REQUEST_RESULT_LINK_NO_BAD_LINKAGE",
			[HOUSING_REQUEST_RESULT_LINK_SAME_FURNITURE] = "HOUSING_REQUEST_RESULT_LINK_SAME_FURNITURE",
			[HOUSING_REQUEST_RESULT_LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_METRICS_LIMIT_HIT] = "HOUSING_REQUEST_RESULT_METRICS_LIMIT_HIT",
			[HOUSING_REQUEST_RESULT_MOVE_FAILED] = "HOUSING_REQUEST_RESULT_MOVE_FAILED",
			[HOUSING_REQUEST_RESULT_NOT_IN_HOUSE] = "HOUSING_REQUEST_RESULT_NOT_IN_HOUSE",
			[HOUSING_REQUEST_RESULT_NO_CHANGES] = "HOUSING_REQUEST_RESULT_NO_CHANGES",
			[HOUSING_REQUEST_RESULT_NO_DUPLICATES] = "HOUSING_REQUEST_RESULT_NO_DUPLICATES",
			[HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE] = "HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE",
			[HOUSING_REQUEST_RESULT_NO_TARGET] = "HOUSING_REQUEST_RESULT_NO_TARGET",
			[HOUSING_REQUEST_RESULT_PATH_CANT_RESTART_ALL_PATHS] = "HOUSING_REQUEST_RESULT_PATH_CANT_RESTART_ALL_PATHS",
			[HOUSING_REQUEST_RESULT_PATH_FURNITURE_PATHING] = "HOUSING_REQUEST_RESULT_PATH_FURNITURE_PATHING",
			[HOUSING_REQUEST_RESULT_PATH_INDEX_OUT_OF_RANGE] = "HOUSING_REQUEST_RESULT_PATH_INDEX_OUT_OF_RANGE",
			[HOUSING_REQUEST_RESULT_PATH_INVALID_FURNITURE] = "HOUSING_REQUEST_RESULT_PATH_INVALID_FURNITURE",
			[HOUSING_REQUEST_RESULT_PATH_INVALID_NODE] = "HOUSING_REQUEST_RESULT_PATH_INVALID_NODE",
			[HOUSING_REQUEST_RESULT_PATH_MODE_ONLY] = "HOUSING_REQUEST_RESULT_PATH_MODE_ONLY",
			[HOUSING_REQUEST_RESULT_PATH_NODE_TOO_CLOSE] = "HOUSING_REQUEST_RESULT_PATH_NODE_TOO_CLOSE",
			[HOUSING_REQUEST_RESULT_PATH_NOT_ENOUGH_NODES] = "HOUSING_REQUEST_RESULT_PATH_NOT_ENOUGH_NODES",
			[HOUSING_REQUEST_RESULT_PATH_NO_PATH_DATA] = "HOUSING_REQUEST_RESULT_PATH_NO_PATH_DATA",
			[HOUSING_REQUEST_RESULT_PATH_TOO_MANY_NODES] = "HOUSING_REQUEST_RESULT_PATH_TOO_MANY_NODES",
			[HOUSING_REQUEST_RESULT_PATH_TOO_MANY_PATHS] = "HOUSING_REQUEST_RESULT_PATH_TOO_MANY_PATHS",
			[HOUSING_REQUEST_RESULT_PATH_UNSUPPORTED_PATH_TYPE] = "HOUSING_REQUEST_RESULT_PATH_UNSUPPORTED_PATH_TYPE",
			[HOUSING_REQUEST_RESULT_PATH_WAIT_TIME_OUT_OF_RANGE] = "HOUSING_REQUEST_RESULT_PATH_WAIT_TIME_OUT_OF_RANGE",
			[HOUSING_REQUEST_RESULT_PERMISSION_FAILED] = "HOUSING_REQUEST_RESULT_PERMISSION_FAILED",
			[HOUSING_REQUEST_RESULT_PERSONAL_TEMP_ITEM_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_PERSONAL_TEMP_ITEM_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_PLACE_FAILED] = "HOUSING_REQUEST_RESULT_PLACE_FAILED",
			[HOUSING_REQUEST_RESULT_REMOVE_FAILED] = "HOUSING_REQUEST_RESULT_REMOVE_FAILED",
			[HOUSING_REQUEST_RESULT_REQUEST_IN_PROGRESS] = "HOUSING_REQUEST_RESULT_REQUEST_IN_PROGRESS",
			[HOUSING_REQUEST_RESULT_SET_STATE_FAILED] = "HOUSING_REQUEST_RESULT_SET_STATE_FAILED",
			[HOUSING_REQUEST_RESULT_SUCCESS] = "HOUSING_REQUEST_RESULT_SUCCESS",
			[HOUSING_REQUEST_RESULT_TOTAL_TEMP_ITEM_PLACE_LIMIT] = "HOUSING_REQUEST_RESULT_TOTAL_TEMP_ITEM_PLACE_LIMIT",
			[HOUSING_REQUEST_RESULT_UNKNOWN_FAILURE] = "HOUSING_REQUEST_RESULT_UNKNOWN_FAILURE",
		},
		States =
		{
			["TOGGLE"] = "Toggled",
			["ON"] = "On",
			["ON2"] = "On (2nd State)",
			["ON3"] = "On (3rd State)",
			["ON4"] = "On (4th State)",
			["ON5"] = "On (5th State)",
			["OFF"] = "Off",
			["RESTORE"] = "Restored",
		},
		Text =
		{
			OpenHouseDisclaimer = "By listing any home as an Open House you are publicly inviting any and all members of the Essential Housing Community - including individuals, streamers and bloggers - to visit, share and stream your home.",
			OpenHouseListedDisclaimer = "By listing this home as an Open House you have publicly invited any and all members of the Essential Housing Community - including individuals, streamers and bloggers - to visit, share and stream your home.",
		},
		ValidStreamChannelURLPrefixes =
		{
			"http://www.twitch.tv/",
			"https://www.twitch.tv/",
		},
		HubDefaultSorts =
		{
			["Favorites"] = "Manual",
			["Furniture"] = "ItemName",
			["My Homes"] = "HouseName",
			["Open Houses"] = "NewestOpenHouses",
			["Recent"] = "LastVisit",
		},
		HubSorts =
		{
			{
				id = 1,
				key = "Manual",
				name = "Manual",
				views = {["Favorites"] = true,},
				comparer = HubEntryFavIndexComparer,
				bookmarkKey = function(entry) return string.format("%s%s", entry.Owner and (entry.Owner.."\n") or "", entry.Name or "") end,
			},
			{
				id = 2,
				key = "HouseName",
				name = "House Name",
				views = {["Favorites"] = true, ["My Homes"] = true, ["Open Houses"] = true,},
				comparer = HubEntryDefaultComparer,
				bookmarkKey = "Name",
			},
			{
				id = 3,
				key = "HouseTitle",
				name = "House Title",
				views = {["Favorites"] = true, ["My Homes"] = true, ["Open Houses"] = true,},
				comparer = HubEntryHouseTitleComparer,
				bookmarkKey = "Nickname",
			},
			{
				id = 4,
				key = "LastVisit",
				name = "Last Visited",
				views = {["Favorites"] = true, ["My Homes"] = true, ["Open Houses"] = true,},
				comparer = HubEntryLastVisitComparer,
				bookmarkKey = function(entry) return entry.LastVisitAgeDays and string.format("%d days", entry.LastVisitAgeDays) or "Never visited" end,
			},
			{
				id = 5,
				key = "NewestOpenHouses",
				name = "Newest Listings",
				views = {["Open Houses"] = true,},
				comparer = HubEntryNewestOpenHousesComparer,
				bookmarkKey = function(entry) return entry.PublishedDate and self:GetRelativeTimeString(self:ConvertDaysToSeconds(entry.PublishedDate), nil, 1) or nil end,
			},
			{
				id = 6,
				key = "CategoryFurniture",
				name = "Furniture Category",
				views = {["Furniture"] = true,},
				comparer = HubEntryCategoryComparer,
				bookmarkKey = "Category",
			},
			{
				id = 7,
				key = "HighestTotalValue",
				name = "Total Value (Highest)",
				views = {["Furniture"] = true,},
				comparer = HubEntryHighestTotalValueComparer,
				bookmarkKey = function(entry) if entry.EstimatedTotalValueString and "" ~= entry.EstimatedTotalValueString then return string.sub(entry.EstimatedTotalValueString, 1, -3) else return entry.EstimatedUnitValueString or nil end end,
			},
			{
				id = 8,
				key = "LowestTotalValue",
				name = "Total Value (Lowest)",
				views = {["Furniture"] = true,},
				comparer = HubEntryLowestTotalValueComparer,
				bookmarkKey = function(entry) if entry.EstimatedTotalValueString and "" ~= entry.EstimatedTotalValueString then return string.sub(entry.EstimatedTotalValueString, 1, -3) else return entry.EstimatedUnitValueString or nil end end,
			},
			{
				id = 9,
				key = "HighestUnitValue",
				name = "Unit Value (Highest)",
				views = {["Furniture"] = true,},
				comparer = HubEntryHighestUnitValueComparer,
				bookmarkKey = "EstimatedUnitValueString",
			},
			{
				id = 10,
				key = "LowestUnitValue",
				name = "Unit Value (Lowest)",
				views = {["Furniture"] = true,},
				comparer = HubEntryLowestUnitValueComparer,
				bookmarkKey = "EstimatedUnitValueString",
			},
			{
				id = 11,
				key = "Owner",
				name = "Homeowner (@name)",
				views = {["Favorites"] = true, ["Open Houses"] = true,},
				comparer = HubEntryOwnerComparer,
				bookmarkKey = "Owner",
			},
			{
				id = 12,
				key = "ItemName",
				name = "Furniture Name",
				views = {["Furniture"] = true,},
				comparer = HubEntryFurnitureComparer,
				bookmarkKey = "FurnitureLink",
			},
			{
				id = 13,
				key = "Unvisited",
				name = "Unvisited / Remodeled",
				views = {["Favorites"] = true, ["My Homes"] = true, ["Open Houses"] = true,},
				comparer = HubEntryUnvisitedComparer,
				bookmarkKey = function(entry) return entry.LastVisitAgeDays and string.format("%d days", entry.LastVisitAgeDays) or "Never visited" end,
			},
		},
	}

	self.Defs.CategoryFilters =
	{
		Enabled = true,
		[1] =
		{
			[1] = "Activity / Arenas and Duels",
			[2] = "Activity / Contests and Events",
			[3] = "Activity / Games, Mazes and Puzzles",
			[4] = "Activity / Garage Sale",
			[5] = "Activity / Platforms and Parkour",
			[6] = "Activity / Portal Hubs",
			[7] = "Activity / Role Play",
			[8] = "Service / Combat Training",
			[9] = "Service / Crafting Sets",
			[10] = "Service / Guildhall",
			[11] = "Theme / Achievements and Trophies",
			[12] = "Theme / Aquariums and Oceanic",
			[13] = "Theme / Banquets and Feasts",
			[14] = "Theme / Baths and Spas",
			[15] = "Theme / Boats and Ships",
			[16] = "Theme / Carnivals and Festivals",
			[17] = "Theme / Castles and Fortifications",
			[18] = "Style / Coastal and Island Living",
			[19] = "Theme / Creatures and Mythic Beasts",
			[20] = "Theme / Fantasy and Magic",
			[21] = "Theme / Gardens and Estates",
			[22] = "Theme / Holidays and Celebrations",
			[23] = "Theme / Horror and Macabre",
			[24] = "Theme / Kitchens and Cuisine",
			[25] = "Theme / Libraries and Studies",
			[26] = "Theme / Lore Inspired",
			[27] = "Theme / Machines and Machinations",
			[28] = "Theme / Mature",
			[29] = "Theme / Memorials and Monuments",
			[30] = "Theme / Museums and Exhibits",
			[31] = "Theme / Nature and Outdoors",
			[32] = "Theme / Sci-Fi and Space",
			[33] = "Theme / Seasonal, Fall",
			[34] = "Theme / Seasonal, Spring",
			[35] = "Theme / Seasonal, Summer",
			[36] = "Theme / Seasonal, Winter",
			[37] = "Theme / Temples and Worship",
			[38] = "Theme / Spooky and Suspense",
			[39] = "Theme / Storage",
			[40] = "Theme / Story and Theatre",
			[41] = "Theme / Towns and Villages",
			[42] = "Theme / Under Construction",
			[43] = "Theme / Underworlds and Planes",
			[44] = "Theme / Comical and Humorous",
			[45] = "Style / Art Deco",
			[46] = "Style / Contemporary",
			[47] = "Style / Country",
			[48] = "Style / Gothic",
			[49] = "Style / Minimalist",
			[50] = "Style / Modern",
			[51] = "Style / Traditional",
			[500] = "(Uncategorized)",
			Version = 1,
		},
	}

	self.GetUncategorizedOpenHouseCategory = function(self)
		return 1.5 -- Version 1, Category 500
	end

	local hubSortKeys = {}
	self.Defs.HubSortKeys = hubSortKeys
	for _, hubSort in ipairs(self.Defs.HubSorts) do
		hubSortKeys[hubSort.key] = hubSort
	end

	for settingName, defaultValue in pairs({
		["AdjustFXSettings"] = 2, -- Ask Me
		["AutoUseHostPortals"] = true,
		["AutoUsePortals"] = true,
		["CustomUIHidingNotificationLastShown"] = 0,
		["EditEffectButtonAlpha"] = 0.8,
		["EditEffectButtonHidden"] = false,
		["EditEffectButtonSize"] = 0.5,
		["EnableCustomUIHiding"] = false,
		["EnableGuestJournalAudio"] = true,
		["EnableHousingHubWidget"] = true,
		["EnablePortalDestinationOSD"] = true,
		["ShowMyGuestJournals"] = true,
		["ShowSignedGuestJournals"] = false,
		["IndicatorScale"] = 1,
		["SuppressGuildShareNotifications"] = true,
	}) do
		self.Defs.DefaultSettings[string.lower(settingName)] = defaultValue
	end
	
	self.Defs.Easing =
	{
		BounceEasing = ZO_GenerateCubicBezierEase(.48, .74, .06, 1.54)
	}

	self.Defs.HubTileTypes =
	{
		["House"] = 1,
		["Furniture"] = 2,
		["Guild"] = 3,
	}

	self.Defs.DefaultFurnitureStates =
	{
		self.Defs.States.ON,
		self.Defs.States.OFF,
		self.Defs.States.ON2,
		self.Defs.States.ON3,
		self.Defs.States.ON4,
		self.Defs.States.ON5,
	}
	
	self.Defs.Options =
	{
		AdjustFXSettings =
		{
			"Always",
			"Ask Me",
			"Never",
		},
		AdjustFXSettingsValues =
		{
			["Always"] = 1,
			["Ask Me"] = 2,
			["Never"] = 3,
		},
	}
	
	self.Defs.Keybinds =
	{
		GuestbookInteract =
		{
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			{
				name = "Show Guest Journal",
				keybind = "GAME_CAMERA_INTERACT",
				callback = function() EssentialHousingHub:ShowGuestbook() end,
			},
		},
		Guestbook =
		{
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			{
				name = "Sign Journal",
				keybind = "UI_SHORTCUT_PRIMARY",
				callback = function() EssentialHousingHub:SignGuestbook() end,
			},
			{
				name = "Dismiss Until Next Visit",
				keybind = "UI_SHORTCUT_NEGATIVE",
				callback = function() EssentialHousingHub:DismissGuestbook() end,
			},
		},
		GuestbookAdmin =
		{
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
			{
				name = "|cff0000Wipe All Signatures|r",
				keybind = "UI_SHORTCUT_TERTIARY",
				callback = function() EssentialHousingHub:ResetGuestbook() end,
			},
		},
	}

	do
		self.Defs.Base88 = self.Defs.Base88 or {}
		local base88 = self.Defs.Base88

		base88.Digits = {}
		base88.Values = {}

		for index = 0, 87 do
			table.insert(base88.Digits, string.char(index + 36))
			base88.Values[string.char(index + 36)] = index
		end
	end

	do
		self.Defs.Time = self.Defs.Time or {}
		local baseTime = self.Defs.Time

		baseTime.SecondsPerHour = 60 * 60
		baseTime.SecondsPerDay = 24 * baseTime.SecondsPerHour
		baseTime.SecondsPerWeek = 7 * baseTime.SecondsPerDay
		baseTime.SecondsPerMonth = 31 * baseTime.SecondsPerDay
		baseTime.SecondsPerYear = 365 * baseTime.SecondsPerDay
	end
	
	do
		self.Defs.InGameTime = self.Defs.InGameTime or {}
		local baseTime = self.Defs.InGameTime

		baseTime.GameTimeOffset = 1394597000
		baseTime.RealSecondsPerGameDay = 20955
		baseTime.RealSecondsPerGameHour = baseTime.RealSecondsPerGameDay / 24
		baseTime.RealSecondsPerGameMinute = baseTime.RealSecondsPerGameHour / 60
		baseTime.RealSecondsPerGameSecond = baseTime.RealSecondsPerGameMinute / 60
	end
end

function EHH:InitializeState()
	self.ActiveTooltipControls = {}
	self.Dialogs = {}
	self.HiddenDialogs = {}
	self.NextSoundEffectMS = 0

	self.FurnitureIdList = {}
	self.FurnitureStates = {}
	self.FurnitureStateTimestamps = {}
	self.FurniturePendingStates = {}
	self.FurnitureStateQueue = {}

	self.OnLinkClickedCallback = function(...) return self:OnLinkClicked(...) end
end

function EHH:InitializeStrings()
	local LAYER = "General"
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_HOUSING_HUB", "Essential Housing Hub", {KEY_H, KEY_ALT, 0, 0, 0})
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_HOME", "Jump Home")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_1", "Jump to Favorite House 1")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_2", "Jump to Favorite House 2")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_3", "Jump to Favorite House 3")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_4", "Jump to Favorite House 4")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_5", "Jump to Favorite House 5")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_6", "Jump to Favorite House 6")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_7", "Jump to Favorite House 7")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_8", "Jump to Favorite House 8")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_9", "Jump to Favorite House 9")
	self:SetupKeybindStringId(LAYER, "SI_BINDING_NAME_EHT_FAV_HOUSE_10", "Jump to Favorite House 10")
end

---[ Deferred Initialization ]---

function EHH:DeferredInitialize()
	if not self.DeferredInitialized then
		self.DeferredInitialized = true

		if self:DeferredValidateModules() then
			self:UpgradeAndRepairSavedVariables()
			self:DeferredInitializeSlashCommands()
			self:DeferredInitializeColors()
			self:DeferredInitializeUtilities()
			self:DeferredInitializeSettingsPanel()
			self:RegisterEventHandlers()
			self.UIVisibility:DeferredInitialize()
			EHH_Widget_DeferredInitialize(EssentialHousingHub.HubWidgetControl)
		end
	end
end

function EHH:DeferredInitializeSlashCommands()
	if not SLASH_COMMANDS["/loc"] then
		SLASH_COMMANDS["/loc"] = function(...) return self:SlashCommandMyLocation(...) end
	end

	if not SLASH_COMMANDS["/re"] then
		SLASH_COMMANDS["/re"] = ReloadUI
	end

	SLASH_COMMANDS["/myloc"] = function(...) return self:SlashCommandMyLocation(...) end
	SLASH_COMMANDS["/ehh"] = function(...) return self:ShowHousingHub(...) end
	SLASH_COMMANDS["/hub"] = function(...) return self:ShowHousingHub(...) end
	SLASH_COMMANDS["/showhub"] = function(...) return self:ShowHousingHub(...) end
	SLASH_COMMANDS["/resethome"] = function(...) return self:SlashCommandResetHome(...) end
	SLASH_COMMANDS["/sethome"] = function(...) return self:SlashCommandSetHome(...) end
	SLASH_COMMANDS["/house"] = function(...) return self:SlashCommandHouse(...) end
	SLASH_COMMANDS["/home"] = function(...) return self:SlashCommandHome(...) end
	SLASH_COMMANDS["/listfavhouses"] = function(...) return self:SlashCommandListFavHouses(...) end
	SLASH_COMMANDS["/setfavhouse"] = function(...) return self:SlashCommandSetFavHouse(...) end
	SLASH_COMMANDS["/sethome"] = function(...) return self:SlashCommandSetHome(...) end
	SLASH_COMMANDS["/resethome"] = function(...) return self:SlashCommandResetHome(...) end
	SLASH_COMMANDS["/resetrecenthomes"] = function(...) return self:SlashCommandResetRecentHomes(...) end
	SLASH_COMMANDS["/gametime"] = function(...) return self:SlashCommandShowInGameTime(...) end
	SLASH_COMMANDS["/guestbook"] = function(...) return self:SlashCommandShowGuestbook(...) end
	SLASH_COMMANDS["/guestjournal"] = function(...) return self:SlashCommandShowGuestbook(...) end
	
	if self.IsDev then
		SLASH_COMMANDS["/setgametime"] = function(...) return self:SlashCommandSetInGameTime(...) end
		SLASH_COMMANDS["/refreshhub"] = function(...) return self:FlushHubListCache(...) end
		SLASH_COMMANDS["/settrendingoverride"] = function(...) return self:SetHubListTrendingOverride(...) end
	end
end

function EHH:DeferredValidateModules()
	self.AreModulesValid = false

	local m = self.Modules
	local valid = "table" == type(m)
	if valid then
		valid = valid and m.Business
		valid = valid and m.Core
		valid = valid and m.Data
		valid = valid and m.Effects
		valid = valid and m.Handlers
		valid = valid and m.Housing
		valid = valid and m.Interop
		valid = valid and m.Social
		valid = valid and m.UserInterface
		valid = valid and m.UserInterfaceHelp
		valid = valid and m.UserInterfaceVisibility
		valid = valid and m.Utilities
		valid = valid and LAM
	end

	if not valid then
		zo_callLater(function()
			local msg = 
				"|cffff88WARNING! |cffffffEssential Housing Hub may not be installed properly...\n\n" ..
				"|cffffffTypically this results from a connectivity issue or even a Minion hiccup while installing an update.\n\n" ..
				"|cffffffIf you type |c88ffff/reloadui|cffffff and still receive this message, please reinstall the Essential Housing Hub " ..
				"(but do |cff1111NOT|cffffff delete your SavedVariables files) and then type |c88ffff/reloadui|cffffff or restart your game."

			d(msg)
		end, 5000)
	end

	self.AreModulesValid = valid
	return valid
end

function EHH:DeferredInitializeSettingsPanel()
	if not self.IsEHT then
		self.SettingsPanelName = self.Name .. "SettingsPanel"
		self.SettingsPanelData =
		{
			["type"] = "panel",
			name = self.Title,
			displayName = self.Title .. " - Settings",
			author = self.Author,
			version = tostring(self.AddOnVersion),
			website = self.Defs.Urls.SetupCommunityPC,
			registerForRefresh = true,
			registerForDefaults = true,
		}
		self.SettingsPanel = LAM:RegisterAddonPanel(self.SettingsPanelName, self.SettingsPanelData)

		local settings =
		{
			{
				-- Spacer
				["type"] = "custom",
			},
			{
				["type"] = "header",
				name = "Housing Widget",
			},
			{
				["type"] = "checkbox",
				key = "EnableHousingHubWidget",
				name = "Show Housing Widget while in a house",
				tooltip = "When this option is enabled, the housing hub widget will appear on the edge of the screen and " ..
					"will indicate the number of guests present as well as the number of traditional furnishings placed in the home.\n\n" ..
					"Note that you may click and drag the widget to either side of the screen.\n\n" ..
					self.Textures.ICON_HUB_WIDGET,
			},
			{
				-- Spacer
				["type"] = "custom",
			},
			{
				["type"] = "header",
				name = "Guest Journals",
			},
			{
				["type"] = "checkbox",
				key = "ShowMyGuestJournals",
				name = "Show my own Guest Journals",
				tooltip = "When this option is enabled, your own homes' Guest Journals will appear automatically.\n\n" ..
					"Note that you can always summon Guest Journals using the Hub Widget.\n\n" ..
					self.Textures.ICON_HUB_WIDGET,
			},
			{
				["type"] = "checkbox",
				key = "ShowSignedGuestJournals",
				name = "Show signed Guest Journals",
				tooltip = "When this option is enabled, Guest Journals that you have already signed will continue to appear automatically.\n\n" ..
					"Note that you can always summon Guest Journals using the Hub Widget.\n\n" ..
					self.Textures.ICON_HUB_WIDGET,
			},
			{
				-- Spacer
				["type"] = "custom",
			},
			{
				["type"] = "header",
				name = "Visual FX",
			},
			{
				["type"] = "checkbox",
				key = "EnableCustomUIHiding",
				name = "Show FX when the UI is hidden",
				tooltip = "When this option is enabled, FX will remain visible even when the User Interface (UI) is hidden.\n\n" ..
					"While uncommon, other add-ons may conflict with this feature. If you experience any issues when toggling the User Interface, " ..
					"turn this option off or disable the conflicting add-on.",
			},
			{
				["type"] = "dropdown",
				key = "AdjustFXSettings",
				name = "Temporarily adjust video settings to support FX",
				tooltip = "The video settings that best support the display of FX are:\n" ..
					"|c88ffffDisplay Mode|r = \"|cffff88Windowed (Fullscreen)|r\"\n" ..
					"|c88ffffSubSampling Quality|r = \"|cffff88High|r\"\n\n" ..
					"Housing Hub can manage these settings when displaying FX:\n\n" ..
					"|cffff88Always|r || Automatically adjust your video settings while visiting a home with FX and automatically restore your original settings after leaving the home. |c00ffff(Recommended)|r\n\n" ..
					"|cffff88Ask Me|r || Prompt for your permission to adjust your video settings while visiting a home with FX. |cbbbb44Note:|r You will only be prompted if your settings are not configured as shown above.\n\n" ..
					"|cffff88Never|r || Never automatically adjust your video settings. |cbbbb44Note:|r FX viewed with incorrect video settings may be visible through walls and terrain, appear distorted or not be visible at all.",
				choices = self.Defs.Options.AdjustFXSettings,
				getFunc = function()
					local value = self:GetSetting("AdjustFXSettings")
					if value then
						value = self.Defs.Options.AdjustFXSettings[value]
					end
					return value or "Ask Me"
				end,
				setFunc = function(value)
					self:SetSetting("AdjustFXSettings", self.Defs.Options.AdjustFXSettingsValues[value])
				end,
				default = self.Defs.Options.AdjustFXSettingsValues["Ask Me"],
				disabled = function() return false end,
			},
		}
		self.SettingsPanelOptions = settings

		for settingIndex, setting in ipairs(settings) do
			if setting.key then
				local settingType = setting["type"]
				if "checkbox" == settingType or "slider" == settingType then
					if not setting.getFunc then
						setting.getFunc = function()
							return self:GetSetting(setting.key)
						end
					end
					
					local originalSetFunc = setting.setFunc
					setting.setFunc = function(value)
						if originalSetFunc then
							local newValue = originalSetFunc(value)
							if nil ~= newValue then
								value = newValue
							end
						end
						self:SetSetting(setting.key, value)
					end

					setting.default = self:GetDefaultSetting(setting.key)
				end
			end
		end

		LAM:RegisterOptionControls(self.SettingsPanelName, self.SettingsPanelOptions)
	end

	do
		self.StreamSettingsPanelName = self.Name .. "StreamSettingsPanel"
		self.StreamSettingsPanelData =
		{
			["type"] = "panel",
			name = "Essential Housing Streamers",
			displayName = "Essential Housing Streamers",
			author = self.Author,
			version = tostring(self.AddOnVersion),
			registerForRefresh = true,
			registerForDefaults = true,
		}
		self.StreamSettingsPanel = LAM:RegisterAddonPanel(self.StreamSettingsPanelName, self.StreamSettingsPanelData)

		local function GetSettingControl(settingName)
			local settingControls = HousingHubStreamSettingsPanel.controlsToRefresh
			for controlIndex, settingControl in ipairs(settingControls) do
				if settingControl.data.name == settingName then
					return settingControl
				end
			end
			return nil
		end

		local function IsStreamChannelURLValid(url)
			if not url or "" == url then
				return true
			end

			url = string.lower(url)
			for _, prefix in ipairs(self.Defs.ValidStreamChannelURLPrefixes) do
				if string.sub(url, 1, #prefix) == prefix then
					return true
				end
			end

			return false
		end

		local settings =
		{
			{
				type = "header",
				name = "Live Housing Streams",
			},
			{
				type = "checkbox",
				name = "Notify me when Housing Streamers go live",
				width = "full",
				tooltip = "Toggle this ON to see a brief notification when Essential Housing Streamers go live on their channel.",
				getFunc = function()
					return true ~= self:GetSetting("HideLiveStreamNotifications")
				end,
				setFunc = function(value)
					self:SetSetting("HideLiveStreamNotifications", not value)
				end,
			},
			{
				type = "custom",
			},
			{
				type = "header",
				name = "Setup Your Channel",
			},
			{
				type = "description",
				text =  "Do you stream housing related content for The Elder Scrolls Online?\n" ..
						"Announce your live stream sessions to the thousands of " ..
						"Essential Housing Community members on the EU and NA megaservers " ..
						"to grow your channel...\n\n" ..
						"1. Fill out your stream information below.\n" ..
						"2. |c88ccffBefore you begin each live stream|r " ..
						"click the \"Go Live...\" button found in the Housing Hub's \"Live Streams\" tab.",
				width = "full",
			},
			{
                type = "editbox",
                name =  "Twitch Channel URL  |cffff44(required)|r",
                tooltip = "Enter the Twitch URL for your channel which should begin with:\n" ..
					"|cff88ff https://www.twitch.tv/ |r",
                width = "full",
				isExtraWide = true,
                default = "https://www.twitch.tv/MyChannelNameHere",
				maxChars = 128,
                isMultiline = false,
                getFunc = function()
					return self:GetStreamChannelData().URL or ""
				end,
                setFunc = function(value)
					if IsStreamChannelURLValid(value) then
						self:GetStreamChannelData().URL = value
					end
				end,
				warning = function()
					local control = GetSettingControl("Channel URL")
					if control then
						local value = control.editbox and control.editbox:GetText()
						if not IsStreamChannelURLValid(value) then
							return "Please enter a valid Twitch URL for your channel."
						end
					end
					return nil
				end,
			},
			{
                type = "editbox",
                name = "Twitch Channel Name  |cffff44(required)|r",
                tooltip = "Enter the name of your channel.",
                width = "full",
				isExtraWide = true,
                default = "",
				maxChars = 30,
                isMultiline = false,
                getFunc = function()
					return self:GetStreamChannelData().ChannelName or ""
				end,
                setFunc = function(value)
					if "" == value then
						value = nil
					end
					self:GetStreamChannelData().ChannelName = value
				end,
			},
			{
                type = "editbox",
                name = "Typical Schedule  |cffff44(required)|r",
                tooltip = "Enter your typical live streaming schedule, such as:\n" ..
						  "|cff88ff Mon & Wed at 2pm EST and Weekends |r",
                width = "full",
				isExtraWide = true,
                default = "",
				maxChars = 65,
                isMultiline = false,
                getFunc = function()
					return self:GetStreamChannelData().Schedule or ""
				end,
                setFunc = function(value)
					if "" == value then
						value = nil
					end
					self:GetStreamChannelData().Schedule = value
				end,
			},
			{
                type = "editbox",
                name = "Channel Description  |cffff44(required)|r",
                tooltip = "Enter a brief description of your channel.",
                width = "full",
				isExtraWide = true,
                default = "",
				maxChars = 200,
                isMultiline = true,
                getFunc = function()
					return self:GetStreamChannelData().Description or ""
				end,
                setFunc = function(value)
					if "" == value then
						value = nil
					end
					self:GetStreamChannelData().Description = value
				end,
			},
			{
				type = "button",
				name = "Go Live...",
				tooltip = "Publish your channel details allowing all Community members to see your channel listed " ..
						  "in the \"Live Streams\" tab of the Housing Hub and list your channel as 'live' for several hours.\n\n" ..
						  "Do not forget to use the \"Go Live...\" button in the \"Live Streams\" tab of the " ..
						  "Housing Hub before you begin streaming each day in order to let Community members know " ..
						  "that you are live.\n\n" ..
						  "Note that streams that do not 'Go live' at least once every 30 days will automatically be " ..
						  "unlisted from the \"Live Streams\" tab.",
				width = "half",
				requiresReload = true,
				func = function()
					if not self:ConfirmStreamChannelGoLive() then
						self:ShowAlertDialog("Please enter all required Twitch Channel information.")
					end
				end,
			},
			{
				type = "button",
				name = "Erase channel",
				tooltip = "If you have already gone live at least once, your channel will be listed in the " ..
						  "\"Live Streams\" tab of the Housing Hub for Community members.\n\n" ..
						  "Use this option to erase your channel information from the \"Live Streams\" tab.\n\n" ..
						  "Note that you can always fill out the Channel Information section above and \"Go Live...\" " ..
						  "again at any time to republish your channel and broadcast your 'live' status to the Community.",
				width = "half",
				warning = "This will erase your channel information from the \"Live Streams\" tab of " ..
						  "the Housing Hub and reload your game's user interface.",
				isDangerous = true,
				requiresReload = true,
				func = function()
					self:ClearStreamChannelData()
					ReloadUI()
				end,
			},
--			{
--				type = "custom",
--			},
		}
		self.StreamSettingsPanelOptions = settings

		LAM:RegisterOptionControls(self.StreamSettingsPanelName, self.StreamSettingsPanelOptions)
	end

	return true
end

function EHH:ShowStreamChannelSettings()
	if LAM then
		LAM:OpenToPanel(self.StreamSettingsPanel)
	end
end

function EHH:IsEHTEnabled()
	return EHT ~= nil and EHT.Data ~= nil and EHT.Biz ~= nil and EHT.UI ~= nil
end

function EHH:IsAddOnEnabled()
	return self.AddOnEnabled
end

function EHH:DisableAddOn()
	if self.AddOnEnabled then
		self.AddOnEnabled = false
		HUB_EVENT_MANAGER:SetEnabled(false)
		HousingHubWidget:SetHidden(true)
	end
end

function EHH:IsEffectsSystemEnabled()
	return self.Defs.EnableEffects
end

function EHH:GetDefaultHubEntryComparer()
	return HubEntryDefaultComparer
end

function EHH:GetTrendingHubEntryComparer()
	return HubEntryTrendingScoreComparer
end

---[ Saved Variables ]---

function EHH:GetData()
	return self.Vars.Data
end

function EHH:GetSettings()
	return self.Vars.Settings
end

function EHH:ClearAllData()
	self.Vars.Data = {}
	ReloadUI()
end

function EHH:ClearAllSettings()
	self.Vars.Settings = {}
	ReloadUI()
end

---[ Settings ]---

function EHH:SetDefaultSetting(settingName, defaultValue)
	if "string" == type(settingName) and "" ~= settingName then
		settingName = string.lower(settingName)
		self.Defs.DefaultSettings[settingName] = defaultValue
	end
end

function EHH:GetDefaultSetting(settingName)
	return self.Defs.DefaultSettings[settingName]
end

function EHH:GetSetting(settingName, suppressDefault)
	local value = nil

	if "string" == type(settingName) and "" ~= settingName then
		settingName = string.lower(settingName)
		value = self:GetSettings()[settingName]

		if nil == value and not suppressDefault then
			value = self.Defs.DefaultSettings[settingName]
		end
	end

	return value
end

function EHH:SetSetting(settingName, value)
	if "string" == type(settingName) and "" ~= settingName then
		settingName = string.lower(settingName)
		self:GetSettings()[settingName] = value
	end
end

function EHH:GetSettingTable(tableName)
	local valueTable

	if "string" == type(tableName) and "" ~= tableName then
		tableName = string.lower(tableName)
		valueTable = self:GetSettings()[tableName]

		if not valueTable then
			valueTable = {}
			self:GetSettings()[tableName] = valueTable
		end
	end

	return valueTable
end

function EHH:GetSettingTableValue(tableName, settingName)
	local valueTable

	if "string" == type(tableName) and "" ~= tableName then
		tableName = string.lower(tableName)
		valueTable = self:GetSettings()[tableName]

		if not valueTable then
			valueTable = {}
			self:GetSettings()[tableName] = valueTable
		end
	end

	if valueTable and "string" == type(settingName) and "" ~= settingName then
		settingName = string.lower(settingName)
		return valueTable[settingName]
	end
	
	return nil
end

function EHH:SetSettingTableValue(tableName, settingName, value)
	local valueTable

	if "string" == type(tableName) and "" ~= tableName then
		tableName = string.lower(tableName)
		valueTable = self:GetSettings()[tableName]

		if not valueTable then
			valueTable = {}
			self:GetSettings()[tableName] = valueTable
		end
	end

	if valueTable and "string" == type(settingName) and "" ~= settingName then
		settingName = string.lower(settingName)
		valueTable[settingName] = value
	end
end

---[ EssentialHousingHubCallbacks Singleton Class ]---

HOUSING_HUB_CALLBACK_RECENTLY_VISITED_HOMES_UPDATED = "RecentlyVisitedHomesUpdated"

local EssentialHousingHubCallbacks = ZO_CallbackObject:Subclass()

function EssentialHousingHubCallbacks:New(...)
    local object = ZO_CallbackObject.New(self)
    object:Initialize(...)
    return object
end

function EssentialHousingHubCallbacks:Initialize(...)
	self.CallbackRegistry = {}
end

function EssentialHousingHubCallbacks:RegisterCallback(eventName, callback, ...)
	self.CallbackRegistry[eventName] = (self.CallbackRegistry[eventName] or 0) + 1
	return ZO_CallbackObject.RegisterCallback(self, eventName, callback, ...)
end

function EssentialHousingHubCallbacks:UnregisterCallback(eventName, callback)
	self.CallbackRegistry[eventName] = (self.CallbackRegistry[eventName] or 1) - 1
	if 0 >= self.CallbackRegistry[eventName] then
		self.CallbackRegistry[eventName] = nil
	end
	return ZO_CallbackObject.UnregisterCallback(self, eventName, callback)
end

function EssentialHousingHubCallbacks:UnregisterAllCallbacks(eventName)
	self.CallbackRegistry[eventName] = nil
	return ZO_CallbackObject.UnregisterAllCallbacks(self, eventName)
end

function EssentialHousingHubCallbacks:FireCallbacks(eventName, ...)
	return ZO_CallbackObject.FireCallbacks(self, eventName, ...)
end

function EssentialHousingHubCallbacks:GetCallbackRegistry()
	return self.CallbackRegistry
end

HUB_CALLBACKS = EssentialHousingHubCallbacks:New()

---[ EssentialHousingHubEventManager Singleton Class ]---

local EssentialHousingHubEventManager = ZO_InitializingObject:Subclass()

function EssentialHousingHubEventManager:Initialize()
	self.Enabled = true
	self.RegisteredCallbacks = {}
	self.RegisteredEvents = {}
	self.RegisteredUpdates = {}
end

function EssentialHousingHubEventManager:RegisterCallback(object, eventName, callback)
	local registeredCallback = self.RegisteredCallbacks[object]
	if not registeredCallback then
		registeredCallback =
		{
			object = object,
			events = {},
		}
		self.RegisteredCallbacks[object] = registeredCallback
	end

	registeredCallback.events[eventName] = callback

	if self.Enabled then
		object:RegisterCallback(eventName, callback)
	end
end

function EssentialHousingHubEventManager:UnregisterCallback(object, eventName, callback)
	local registeredCallback = self.RegisteredCallbacks[object]
	if registeredCallback then
		registeredCallback.events[eventName] = nil
	end

	object:UnregisterCallback(eventName, callback)
end

function EssentialHousingHubEventManager:RegisterForEvent(key, eventName, callback)
	local registeredEvent = self.RegisteredEvents[eventName]
	if not registeredEvent then
		registeredEvent =
		{
			eventName = eventName,
			keys = {},
		}
		self.RegisteredEvents[eventName] = registeredEvent
	end

	local registeredKey = registeredEvent.keys[key]
	if not registeredKey then
		registeredKey =
		{
			key = key,
			callback = callback,
		}
		registeredEvent.keys[key] = registeredKey
	else
		registeredKey.callback = callback
	end

	if self.Enabled then
		EVENT_MANAGER:UnregisterForEvent(key, eventName)
		EVENT_MANAGER:RegisterForEvent(key, eventName, callback)
	end
end

function EssentialHousingHubEventManager:UnregisterForEvent(key, eventName)
	local registeredEvent = self.RegisteredEvents[eventName]
	if registeredEvent then
		registeredEvent.keys[key] = nil
	end

	EVENT_MANAGER:UnregisterForEvent(key, eventName)
end

function EssentialHousingHubEventManager:RegisterForUpdate(key, interval, callback)
	local registeredKey = self.RegisteredUpdates[key]
	if not registeredKey then
		self.RegisteredUpdates[key] =
		{
			key = key,
			interval = interval,
			callback = callback,
		}

		if self.Enabled then
			EVENT_MANAGER:RegisterForUpdate(key, interval, callback)
		end
	end
end

function EssentialHousingHubEventManager:UnregisterForUpdate(key, interval, callback)
	self.RegisteredUpdates[key] = nil
	EVENT_MANAGER:UnregisterForUpdate(key)
end

function EssentialHousingHubEventManager:SetEnabled(enabled)
	if enabled ~= self.Enabled then
		self.Enabled = enabled
		
		if not enabled then
			for object, registeredCallback in pairs(self.RegisteredCallbacks) do
				for eventName, callback in pairs(registeredCallback.events) do
					object:UnregisterCallback(eventName, callback)
				end
			end

			for eventName, registeredEvent in pairs(self.RegisteredEvents) do
				for key, registeredEventKey in pairs(registeredEvent.keys) do
					EVENT_MANAGER:UnregisterForEvent(key, eventName)
				end
			end

			for key, registeredUpdate in pairs(self.RegisteredUpdates) do
				EVENT_MANAGER:UnregisterForUpdate(key)
			end
		end
	end
end

HUB_EVENT_MANAGER = EssentialHousingHubEventManager:New()

---[ Keybindings ]---

do
	local stringTable = {}

	function EHH:SetupKeybindStringId(layerName, stringName, stringText, defaultKeycode)
		local stringKey = string.sub(stringName, 17) -- Exclude the "SI_BINDING_NAME_" prefix.
		stringTable[stringKey] =
		{
			layerName = layerName,
			stringName = stringName,
			text = stringText,
			defaultKeycode = defaultKeycode,
		}
		ZO_CreateStringId(stringName, stringText)
	end

	function EHH:GetKeybindStringIds()
		return stringTable
	end
end

function EHH:GetSavedKeybinds()
	return self:GetSettingTable("KeybindConfiguration")
end

function EHH:GetSavedKeybind(bindingName, defaultKeycode)
	local keybinds = self:GetSavedKeybinds()
	local keybind = keybinds[bindingName]
	if "table" ~= type(keybind) then
		keybind = {}
		if "table" == type(defaultKeycode) then
			self:SetDefaultKeybind(bindingName, keybind, defaultKeycode)
		end
		keybinds[bindingName] = keybind
	end
	return keybind
end

function EHH:ResetKeybind( bindingName )
	local keybinds = self:GetSavedKeybinds()
	local keybind = {}
	keybinds[bindingName] = keybind
	return keybind
end

function EHH:SetDefaultKeybind(bindingName, keybind, defaultKeybind)
	if "table" ~= type(keybind) or "table" ~= type(defaultKeybind) or defaultKeybind[1] == 0 then
		return
	end

	local defaultKeycode = defaultKeybind[1]
	local keybindStringIds = self:GetKeybindStringIds()
	local keybindStringData = keybindStringIds[bindingName]
	if "table" ~= type(keybindStringData) or not keybindStringData.layerName then
		return
	end

	local existingBindingName = GetActionNameFromKey(keybindStringData.layerName, defaultKeycode)
	if "" ~= existingBindingName then
		-- The requested 'default' key code is already assigned to an action on this layer.
		local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(existingBindingName)
		for keycodeIndex = 1, 4 do
			local keycode, modifier1, modifier2, modifier3, modifier4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, keycodeIndex)
			if keycode == defaultKeycode and modifier1 == defaultKeybind[2] and modifier2 == defaultKeybind[3] and modifier3 == defaultKeybind[4] and modifier4 == defaultKeybind[5] then
				-- The existing keybind matches exactly; do not assign the default keybind.
				return
			end
		end
	end

	keybind[1] = self:CloneTable(defaultKeybind)
end

function EHH:LoadKeybind(bindingName, defaultKeycode)
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(bindingName)
	if layerIndex and categoryIndex and actionIndex then
		local savedKeybind = self:GetSavedKeybind(bindingName, defaultKeycode)

		-- Clear existing keybinds, if any.
		if IsProtectedFunction("UnbindAllKeysFromAction") then
			CallSecureProtected("UnbindAllKeysFromAction", layerIndex, categoryIndex, actionIndex)
		else
			UnbindAllKeysFromAction(layerIndex, categoryIndex, actionIndex)
		end

		for keycodeIndex, keycodeData in pairs(savedKeybind) do
			if IsProtectedFunction("BindKeyToAction") then
				CallSecureProtected("BindKeyToAction", layerIndex, categoryIndex, actionIndex, keycodeIndex, keycodeData[1], keycodeData[2], keycodeData[3], keycodeData[4], keycodeData[5])
			else
				BindKeyToAction(layerIndex, categoryIndex, actionIndex, keycodeIndex, keycodeData[1], keycodeData[2], keycodeData[3], keycodeData[4], keycodeData[5])
			end
		end
	end
end

function EHH:SaveKeybind(bindingName)
	local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName(bindingName)
	local savedKeybind = self:ResetKeybind(bindingName)

	if layerIndex and categoryIndex and actionIndex then
		for keycodeIndex = 1, 4 do
			local keycode, modifier1, modifier2, modifier3, modifier4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, keycodeIndex)
			if keycode ~= 0 then
				savedKeybind[keycodeIndex] = {keycode, modifier1, modifier2, modifier3, modifier4}
			end
		end
	end
end

do
	local initialized = false
	local loadingKeybinds = false
	
	function EHH:LoadKeybindConfiguration()
		if loadingKeybinds then
			return
		end
		loadingKeybinds = true

		local numLoaded = 0
		local keybindStringIds = self:GetKeybindStringIds()
		for stringKey, stringData in pairs(keybindStringIds) do
			self:LoadKeybind(stringKey, stringData.defaultKeycode)
			numLoaded = numLoaded + 1
		end

		loadingKeybinds = false
		initialized = true
	end

	function EHH:SaveKeybindConfiguration()
		if loadingKeybinds then
			return
		end
		
		if initialized then
			local keybindStringIds = self:GetKeybindStringIds()
			for stringKey in pairs(keybindStringIds) do
				self:SaveKeybind(stringKey)
			end
		else
			self:LoadKeybindConfiguration()
		end
	end
end

do
	local function SaveKeybindConfiguration()
		HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.SaveKeybinds")
		EssentialHousingHub:SaveKeybindConfiguration()
	end

	function EHH:OnKeybindingsUpdated()
		HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.SaveKeybinds")
		HUB_EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.SaveKeybinds", 100, SaveKeybindConfiguration)
	end
end

---[ Sort Comparer Definitions ]---

HubEntryDefaultComparer = function(entryA, entryB)
	if entryA.SortName and entryB.SortName then
		if entryA.SortName < entryB.SortName then
			return true
		elseif entryA.SortName == entryB.SortName and entryA.SortOwner < entryB.SortOwner then
			return true
		else
			return false
		end
	else
		return string.lower(entryA.Name) < string.lower(entryB.Name)
	end
end

HubEntryHouseTitleComparer = function(entryA, entryB)
	if entryA.Nickname then
		if not entryB.SortNickname then
			return true
		else
			return entryA.SortNickname < entryB.SortNickname
		end
	elseif entryB.SortNickname then
		return false
	end
	return HubEntryDefaultComparer(entryA, entryB)
end

HubEntryOwnerComparer = function(entryA, entryB)
	if entryA.SortOwner and entryB.SortOwner then
		if entryA.SortOwner < entryB.SortOwner then
			return true
		elseif entryA.SortOwner == entryB.SortOwner and entryA.SortName < entryB.SortName then
			return true
		else
			return false
		end
	else
		return string.lower(entryA.Name) < string.lower(entryB.Name)
	end
end

HubEntryFurnitureComparer = function(entryA, entryB)
	return (entryA.SortKey or "") < (entryB.SortKey or "")
end

HubEntryUnvisitedComparer = function(entryA, entryB)
	if entryA.LastVisit then
		if not entryB.LastVisit then
			return false
		else
			return entryA.LastVisit < entryB.LastVisit
		end
	elseif entryB.LastVisit then
		return true
	elseif entryA.PublishedDate then
		if not entryB.PublishedDate then
			return true
		else
			return entryA.PublishedDate > entryB.PublishedDate
		end
	elseif entryB.PublishedDate then
		return false
	else
		return HubEntryDefaultComparer(entryA, entryB)
	end
end

HubEntryLastVisitComparer = function(entryA, entryB)
	if entryA.LastVisit then
		if entryB.LastVisit then
			return entryA.LastVisit > entryB.LastVisit
		else
			return true
		end
	elseif entryB.LastVisit then
		return false
	else
		return HubEntryDefaultComparer(entryA, entryB)
	end
end

HubEntryNewestOpenHousesComparer = function(entryA, entryB)
	local pubA, pubB = entryA.PublishedDate or 0, entryB.PublishedDate or 0
	if pubA > pubB then
		return true
	elseif pubA == pubB then
		return HubEntryDefaultComparer(entryA, entryB)
	else
		return false
	end
end

HubEntryFavIndexComparer = function(entryA, entryB)
	return (entryA.FavIndex or math.huge) < (entryB.FavIndex or math.huge)
end

HubEntryCategoryComparer = function(entryA, entryB)
	if entryA.Category == entryB.Category then
		return HubEntryDefaultComparer(entryA, entryB)
	end
	return entryA.Category < entryB.Category
end

HubEntryHighestTotalValueComparer = function(entryA, entryB)
	if entryA.EstimatedTotalValue == entryB.EstimatedTotalValue then
		return HubEntryDefaultComparer(entryA, entryB)
	end
	return entryA.EstimatedTotalValue > entryB.EstimatedTotalValue
end

HubEntryLowestTotalValueComparer = function(entryA, entryB)
	if entryA.EstimatedTotalValue == entryB.EstimatedTotalValue then
		return HubEntryDefaultComparer(entryA, entryB)
	end
	return entryA.EstimatedTotalValue < entryB.EstimatedTotalValue
end

HubEntryHighestUnitValueComparer = function(entryA, entryB)
	if entryA.EstimatedUnitValue == entryB.EstimatedUnitValue then
		return HubEntryDefaultComparer(entryA, entryB)
	end
	return entryA.EstimatedUnitValue > entryB.EstimatedUnitValue
end

HubEntryLowestUnitValueComparer = function(entryA, entryB)
	if entryA.EstimatedUnitValue == entryB.EstimatedUnitValue then
		return HubEntryDefaultComparer(entryA, entryB)
	end
	return entryA.EstimatedUnitValue < entryB.EstimatedUnitValue
end

HubEntryTrendingScoreComparer = function(entryA, entryB)
	local scoreA, scoreB = entryA.TrendingScore or 0, entryB.TrendingScore or 0
	if 0 == scoreA and 0 == scoreB then
		local pubA, pubB = entryA.PublishedDate or 0, entryB.PublishedDate or 0
		return pubA < pubB
	else
		return scoreA > scoreB
	end
end

---[ Singleton Instantiation ]---

EHH:New()

if EssentialHousingHub.IsDev then
	Hub = EssentialHousingHub
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Core = true