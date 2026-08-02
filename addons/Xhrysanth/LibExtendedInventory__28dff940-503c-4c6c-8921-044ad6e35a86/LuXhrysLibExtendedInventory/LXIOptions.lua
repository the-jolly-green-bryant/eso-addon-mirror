
--[[ LuXhrys Module Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibExtendedInventory ]]
--[[ LXIOptions.lua]]
--[[ LOAD ORDER FIRST ]]

--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:

This file is part of the core module for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk contains option-setting functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ =========================> AUTHORIZATION <=========================== ]]--


do
	local playerName = GetDisplayName ()

	assert (playerName == "@Xhrysanth" or playerName == "Xhrysanth", "[LuXhrysLXIO] CRIT: Not an authorized user. This chunk will not be loaded.")
end


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ============================= [ Namespace ] ============================= --


LUXHRYS = {}


-- ============================== [ Metadata ] ============================= --


local ADDON_SYSTEM_NAME = "LuXhrys"
local ADDON_DESCRIPTION = "The LuXhrys modular add-on system for the Elder Scrolls Online game."
local ADDON_DISCLAIMER = "This add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved."
local ADDON_AUTHOR = "Xhrysanth (PSNA)"
local ADDON_COPYRIGHT_AND_LICENSE = "Copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software."

LUXHRYS.METADATA =
{
	ADDON_SYSTEM_NAME = ADDON_SYSTEM_NAME,
	ADDON_DESCRIPTION = ADDON_DESCRIPTION,
	ADDON_DISCLAIMER = ADDON_DISCLAIMER,
	ADDON_AUTHOR = ADDON_AUTHOR,
	ADDON_COPYRIGHT_AND_LICENSE = ADDON_COPYRIGHT_AND_LICENSE
}

local ADDON_MODULE_NAME = "LibExtendedInventory"
local ADDON_MODULE_SHORT_NAME = "LXI"
local ADDON_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME
local ADDON_MODULE_VERSION = "0.3a" -- Can we substitute with reading a var provided by the API?
local ADDON_MODULE_DESCRIPTION = "Implements core functionality for the LuXhrys add-on system for the Elder Scrolls Online."

LUXHRYS.LXI = {}
LUXHRYS.LXI.METADATA =
{
	ADDON_MODULE_NAME = ADDON_MODULE_NAME,
	ADDON_MODULE_SHORT_NAME = ADDON_MODULE_SHORT_NAME,
	ADDON_NAME = ADDON_NAME,
	ADDON_MODULE_VERSION = ADDON_MODULE_VERSION,
	ADDON_MODULE_DESCRIPTION = ADDON_MODULE_DESCRIPTION
}

local ADDON_CHUNK_NAME = "Options"
local ADDON_CHUNK_SHORT_NAME = "O"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| C functions |--------------------------------------------------------------
-------------------------------------------------------------------------------


local GetDisplayName = GetDisplayName

local GetTotalUserAddOnMemoryPoolUsageMB = GetTotalUserAddOnMemoryPoolUsageMB
local GetTotalUserAddOnMemoryPoolCapacityMB = GetTotalUserAddOnMemoryPoolCapacityMB

local GetCVar = GetCVar
local SetCVar = SetCVar


-------------------------------------------------------------------------------
--| Native Lua Functions |-----------------------------------------------------
-------------------------------------------------------------------------------


--local TableInsert = table.insert
--local TableRemove = table.remove
local StrFormat = string.format


-------------------------------------------------------------------------------
--| ZOS Lua Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


--local ZO_LinkHandler_ParseLink = ZO_LinkHandler_ParseLink
local zo_iconFormat = zo_iconFormat



-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


local Debug
local StrUtils
local STATE
local Bag
local icons
local Location
local COLORS


-------------------------------------------------------------------------------
--| 7. Local vars for this module |--------------------------------------------
-------------------------------------------------------------------------------


-- We need to define our own bags in addition to the standard ones before
-- LXICommon loads.

local BAG_PLACED_FURNISHINGS = -1
local BAG_INBOX = -2
local BAG_TRADER = -3


-- We also need to define location type filters before LXICommon loads.

local LOCATION_TYPE_FILTER_ALL = 1
local LOCATION_TYPE_FILTER_BACKPACK = 2
local LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE = 3
local LOCATION_TYPE_FILTER_FURNITURE_VAULT = 4
local LOCATION_TYPE_FILTER_HOUSE = 5
local LOCATION_TYPE_FILTER_TRADER = 6
local LOCATION_TYPE_FILTER_INBOX = 7
local LOCATION_TYPE_FILTER_GUILD = 8
local LOCATION_TYPE_FILTER_WORN = 9
local LOCATION_TYPE_FILTER_BUYBACK = 10
local LOCATION_TYPE_FILTER_COMPANION = 11
local LOCATION_TYPE_FILTER_VENGEANCE = 12


--[[ ============================> FUNCTIONS <============================ ]]--


-------------------------------------------------------------------------------
--| Utility Functions |--------------------------------------------------------
-------------------------------------------------------------------------------


-- Since everyone on console can install this, lock it down so only developer
-- can use it.

local function IsNotDeveloper ()
	return GetDisplayName () ~= "Xhrysanth" and GetDisplayName () ~= "@Xhrysanth"
end


-- ========================== [ Option Defaults ] ========================== --


LUXHRYS.optionDefaults = {}


	LUXHRYS.optionDefaults.system =
	{
		platform = 0,
		onPC = 0,
		consoleUI = 0,
		usingGamepad = 0,
		consoleForcedMode = 0
	}


-------------------------------------------------------------------------------
--| User-Controllable Options |------------------------------------------------
-------------------------------------------------------------------------------


	LUXHRYS.optionDefaults.debug =
	{
		debugLevel = 1, -- Verbosity of debug output.
	}

	LUXHRYS.optionDefaults.async =
	{
		useAsync = false -- Use asynchronous processing.
	}

	LUXHRYS.optionDefaults.bagTracking =
	{
		[BAG_WORN] = true,
		[BAG_BACKPACK] = true,
		[BAG_BANK] = false, -- always visible -- we never track this
		[BAG_GUILDBANK] = false,
		[BAG_BUYBACK] = true,
		[BAG_VIRTUAL] = false, -- always visible -- we never track this
		[BAG_SUBSCRIBER_BANK] = false, -- always visible -- we never track this
		[BAG_HOUSE_BANK_ONE] = false,
		[BAG_HOUSE_BANK_TWO] = false,
		[BAG_HOUSE_BANK_THREE] = false,
		[BAG_HOUSE_BANK_FOUR] = false,
		[BAG_HOUSE_BANK_FIVE] = false,
		[BAG_HOUSE_BANK_SIX] = false,
		[BAG_HOUSE_BANK_SEVEN] = false,
		[BAG_HOUSE_BANK_EIGHT] = false,
		[BAG_HOUSE_BANK_NINE] = false, -- future?
		[BAG_HOUSE_BANK_TEN] = false, -- future?	[BAG_COMPANION_WORN] = true,
		[BAG_COMPANION_WORN] = false,
		[BAG_FURNITURE_VAULT] = false,
		[BAG_VENGEANCE] = false, -- visible only when in vengeance zone, we can track
		[BAG_PLACED_FURNISHINGS] = true,
		[BAG_INBOX] = true,
		[BAG_TRADER] = false
	}

	LUXHRYS.optionDefaults.counting =
	{
		pollingInterval = 3000 -- how often we check to see if new bags are ready to be scanned in milliseconds
	}

	LUXHRYS.optionDefaults.mail =
	{
		keepUnread = true, -- When scanning inbox, the game marks scanned mail as read. Keep it unread until player reads it?
		firstRun = true, -- scan all messages, not just new ones
		rebuild = false -- clear and rebuild the mail cache
	}

	LUXHRYS.optionDefaults.matching =
	{
		useLevel = true,
		useCP = true,
		useTrait = false,
		useMotif = false,
		useEnchant = false
	}

	LUXHRYS.optionDefaults.masterColor =
	{
		r = 163/255,
		g = 255/255,
		b = 218/255,
		a = 1,
		selectedDarkeningFactor = 0.5,
		iconDarkeningFactor = 0.8
	}


	-- These are tiny, so we'll keep these here instead of the other modules to make thigs easier.

	LUXHRYS.optionDefaults.VaC =
	{
		wrapTabBar = true,
		previewingEnabled = true
	}

	LUXHRYS.optionDefaults.VaC.listScreenTabOrder =
	{	LOCATION_TYPE_FILTER_ALL,
		LOCATION_TYPE_FILTER_BACKPACK,
		LOCATION_TYPE_FILTER_HOUSE,
		LOCATION_TYPE_FILTER_INBOX,
		LOCATION_TYPE_FILTER_WORN,
		LOCATION_TYPE_FILTER_BUYBACK
	}

--[[ TODO: Not sure it's worth keeping this.
	LUXHRYS.optionDefaults.VaC.listScreenCustomSortOrder =
	{
			bestItemCategoryName = { tiebreaker = "name" },
			displayQuality = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
			stackCount = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
			sellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
			name = { tiebreaker = "requiredLevel" },
			requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
			requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
			iconFile = { tieBreakerSortOrder = ZO_SORT_ORDER_UP }
	}
]]


	LUXHRYS.optionDefaults.FS =
	{
		useHousingHUD = true,
		useHUDSellMode = true,
		useHUDBuyMode = true
	}


-- ============================== [ Options ] ============================== --


local Options = ZO_InitializingObject:Subclass ()


-------------------------------------------------------------------------------
--| Initialization of "Class" and Saved Variables |----------------------------
-------------------------------------------------------------------------------


function Options:Initialize ()

	-- Options that are not user-configurable.

	self.memoryUsageAtStartup = collectgarbage ("count")
	self.memoryUsageAfterInitialization = 0

	self.optionsVersion = 0
	self.databaseVersion = 0
	self.mailCacheVersion = 0


	--options.onPC = 0 -- set during initialization
	--options.usingGamepad = 0 -- set during initialization


	-- Create savedVars for options using hard-coded options as the default.

	self.settings = ZO_SavedVars:NewAccountWide (ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME .. "_SV", self.optionsVersion, "options", LUXHRYS.optionDefaults, GetWorldName ())

	if self.settings and type (self.settings) == "table"
	then
		d ("[" .. ADDON_DEBUG_NAME .. ":O_I]" .. " INFO: Successful initialization of settings variables.")
	else -- Probably shouldn't ever reach this.
		d ("[" .. ADDON_DEBUG_NAME .. ":O_I]" .. " WARN: Settings variables failed to initialize.")
		return
	end


	-- Create shortcuts.

	self.system = self.settings.system
	self.debug = self.settings.debug
	self.async = self.settings.async
	self.bagTracking = self.settings.bagTracking
	self.counting = self.settings.counting
	self.mail = self.settings.mail
	self.matching = self.settings.matching
	self.masterColor = self.settings.masterColor
	self.VaC = self.settings.VaC
	self.FS = self.settings.FS


	-- Prepare for the initialization of the settings panel.

	self.playerAlreadyActivatedOnce = false

end


-------------------------------------------------------------------------------
--| Initialization of Settings Panel |-----------------------------------------
-------------------------------------------------------------------------------


-- This needs to happen after LXICommon is loaded and everything in it is
-- initialized. Therefore, we will call this when player is first activated.

function Options:InitializeSettingsPanel ()

	if self.playerAlreadyActivatedOnce then
		return
	else
		self.playerAlreadyActivatedOnce = true
	end


	-- Can we create a settings panel?

	if not LibHarvensAddonSettings then
		Debug.Msg (0, ADDON_DEBUG_NAME, "O_ISP", "WARN: LibHarvensAddonSettings is not installed. Customizing add-on options will not be available unless installed.")
		return
	end


	-- Set up private functions for settings panel.
--[[
	local function GetOptionValue (...)
		DebugMsg (2, "GOV: Called with args %s.", table.concat ({...}, "."))

--		return options[varToGet]
--		local keys = {...}
    local nKeys = select ("#", ...)
    local current = options

--    for _, key in ipairs(keys) do
    for i = 1, nKeys do

--			current = current[key]
			local key = select (i, ...)
			current = current[key]
			DebugMsg (2, "GOV: Current key: %s, type: %s", tostring (key), type (key))
    end
		DebugMsg (2, "GOV: Returning %s, type %s.", tostring (current), type (current))
    return current
	end


	local function SetOptionValue (value, ...)
		DebugMsg (2, "SOV: Called with args %s, %s.", tostring (value), table.concat ({...}, "."))

		-- The settings panel can never clear an option.

		if not value then return end

		if not GetOptionValue (...) then
			DebugMsg (0, "WARN: Option %s does not exist.", table.concat ({...}, "."))
			return
		end

--		local keys = {...}
    local nKeys = select ("#", ...)
		local key
    local current = options
--    for _, key in ipairs(keys) do
    for i = 1, nKeys do
--        current = current[key]
			key = select (i, ...)
			current = current[key]
			DebugMsg (2, "SOV: Current key: %s, type: %s", tostring (key), type (key))
    end

		DebugMsg (2, "SOV: Setting key to value %s. Returning.", tostring (value))
		key = value

	end
]]



	-- Restore defaults to options table. TODO: There is a ZOS function for this. TODO: Add confirmation dialog?

	local function RestoreOptionDefaults ()
		Debug.Msg (0, ADDON_DEBUG_NAME, "O_ISP_RDO", "WARN: Restoring default options. All previous settings are lost.")
	--	ZO_DeepTableCopy (LUXHRYS.optionDefaults, OPTIONS.settings)
		self.settings:ResetToDefaults ()
	end

--[[ ZOS Code

    interface.ResetToDefaults = function(self)
        local sv = getmetatable(self).__index
        if sv then
            local version = sv.version
            ZO_ClearTable(sv)
            sv.version = version
            if self.default then
                CopyDefaults(sv, self.default)
            end
        end
    end

]]


	local function GetCurrentColorSettings ()
		return self.masterColor.r, self.masterColor.g, self.masterColor.b, self.masterColor.a
	end


	local function SetCurrentColorSettings (r, g, b)
		self.masterColor.r = r
		self.masterColor.g = g
		self.masterColor.b = b
--		self.masterColor.a
	end


	local function RestoreDefaultColorSettings ()
		self.masterColor.r = LUXHRYS.optionDefaults.masterColor.r
		self.masterColor.g = LUXHRYS.optionDefaults.masterColor.g
		self.masterColor.b = LUXHRYS.optionDefaults.masterColor.b
		self.masterColor.a = LUXHRYS.optionDefaults.masterColor.a
	end


	local function ShouldDisableHousingStorage ()
		return STATE:IsAnyHousingStorageCollected () == false
	end


	local function ShouldDisableCompanions ()
		return STATE:IsAnyCompanionCollected () == false
	end


	local function ShouldDisableFurnitureVault ()
--		return not XI_HasUnlockedFurnitureVault ()
		return HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault () == false
	end


	local function ShouldDisableMailOptions ()
		return self.bagTracking[BAG_INBOX] == false
	end

--[[
	local function GetOptionsPanelLabelIconString (bagID, text)
		return COLORS:GetColorizedIcon (icons.tooltipStackCount[bagID], 28, 28) .. " " .. text
	end
]]

	local function GetOptionsPanelLabelIconString (locationTypeFilter)
		return COLORS:GetColorizedIcon (Location.locationTypeFilters[locationTypeFilter].tooltipIcon, 28, 28) .. " " .. StrUtils.TitleCase (Location.locationTypeFilters[locationTypeFilter].name)
	end


	local function MemoryFlush ()
		Debug.MemoryFlush ()
	end

	-- Setup dynamic tooltip functions.

	local function GetHousingStorageTooltipText ()
		local returnValue = "Enable scanning of the items in your " .. Bag.GetName (BAG_HOUSE_BANK_ONE) .. " storage so you can see their contents when not in one of your houses.\n\nScanning of the " .. Bag.GetName (BAG_FURNITURE_VAULT) .. " is controlled by a different setting."
		if ShouldDisableHousingStorage () then
			return returnValue .. "\n\n This setting is currently disabled because no ".. Bag.GetName (BAG_HOUSE_BANK_ONE) .. " has been obtained. One of these items is available as a reward for reaching level 18, and the others can be purchased with in-game currency, including from Rolis Hlaalu with writ vouchers and in the Imperial City Sewers with tel var stones."
		end
		return returnValue
	end

	-- These appear to be duplicates. TODO: Pick one. Done.

	local function GetHousingStorageOption ()
		for index = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
			if self.bagTracking[index] == true then return true end
		end
	end


	local function SetHousingStorageOption (value)
		for index = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
			self.bagTracking[index] = STATE:IsHousingStorageCollected (index) and value or false
		end
	end

--[[
	local function SetHousingStorageEnabled (value)
		for bagID = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
			self.bagTracking[bagID] = value
		end
	end
]]

	local function GetCompanionTooltipText ()
		local returnValue = "Enable scanning of " .. Bag.GetName (BAG_COMPANION_WORN) .. " so you can see it while your comapnion is away."
		if ShouldDisableCompanions () then
			return returnValue .. "\n\nThis setting is currently disabled because you have not collected any companions."
		end
		return returnValue
	end


	local function GetFurnitureVaultTooltipText ()
		local returnValue = "Enable scanning of the items in your " .. Bag.GetName (BAG_FURNITURE_VAULT) .. " so you can see its contents when not in one of your houses.\n\nScanning of the " .. Bag.GetName (BAG_HOUSE_BANK_ONE) .. " is controlled by a different setting."
		if ShouldDisableFurnitureVault () then
			return returnValue .. "\n\nThis setting is currently disabled because the " .. Bag.GetName (BAG_FURNITURE_VAULT) .. " is not currently collected. It can be claimed for free from the crown store while you have ESO Plus. If this option is enabled, this add-on will continue to scan the vault once obtained, even if you lose access to place new items in it."
		end
		return returnValue
	end


	local function GetAsyncTooltipText ()
		return "Asynchronous processing currently " .. (self.async.useAsync == true and "enabled." or "disabled.")
	end

	local function GetCurrentNonconfigurableOptionValues ()
		return table.concat (
		{
			"Current Non-Configurable Settings\n\n",
			"Add-On Core Module v", ADDON_MODULE_VERSION, "\n",
			"Options v", self.optionsVersion, "\n",
			"Database v", self.databaseVersion, "\n",
			"Mail Cache v", self.mailCacheVersion, "\n",
			"Platform: ", Debug.PlatformName (self.platform), "\n",
			"UI Mode: ", self.consoleUI == true and "Console" .. (GetCVar("ForceConsoleFlow.2") == "1" and " (Forced)\n" or "\n") or " PC\n",
			"Input Mode: ", self.usingGamepad == true and "Gamepad" or "Keyboard and Mouse", "\n",
			zo_iconFormat ("EsoUI/Art/Miscellaneous/gamepad/horizontaldivider.dds", "800%", 4), "\n",
--			XI_StrFormat ("Preload Memory Usage: %.2f MB\n", self.memoryUsageAtStartup / 1000),
--			XI_StrFormat ("Loaded Memory Usage: %.2f MB\n", self.memoryUsageAfterInitialization / 1000),
--			XI_StrFormat ("Current Memory Usage: %.2f MB\n", collectgarbage ("count") / 1000),
			StrFormat ("Current Memory Usage:\n       %.2f / %.0f MB\n", GetTotalUserAddOnMemoryPoolUsageMB (), GetTotalUserAddOnMemoryPoolCapacityMB())
		})
	end

--[[
* GetTotalUserAddOnMemoryPoolUsageMB()
** _Returns:_ *number* _totalUserAddOnMemoryPoolCapacityMB_

* GetTotalUserAddOnMemoryPoolCapacityMB()
** _Returns:_ *number* _totalUserAddOnMemoryPoolCapacityMB_

* GetTotalUserAddOnCPUTimeUsedNowMS()
** _Returns:_ *number* _totalUserAddOnCPUTimeUsedThisFrameMS_

* GetTotalUserAddOnCPUTimeUsedLastFrameMS()
** _Returns:_ *number* _totalUserAddOnCPUTimeUsedLastFrameMS_

* GetTotalUserAddOnCPUTimeAvailableEachFrameMS()
** _Returns:_ *number* _totalUserAddOnCPUTimeAvailableEachFrameMS_


* ShouldWarnConsoleAddOnMemoryLimit()
** _Returns:_ *bool* _warnConsoleAddOnMemoryLimit_

* ShouldWarnConsoleAddOnSavedVariableLimit()
** _Returns:_ *bool* _warnConsoleAddOnSavedVariableLimit_

* ClearWarnConsoleAddOnMemoryLimit()

* ClearWarnConsoleAddOnSavedVariableLimit()

]]



	local function GetDebugLevelTooltipText ()
		if IsNotDeveloper () then
			return "Function restricted to developers only."
		else
			return table.concat (
			{
				"Debug Level Settings\n\n",
				"Level 0 - Information Only: General information, warnings, and critical errors.\n",
				"Level 1 - Terse: Function calls.\n",
				"Level 2 - Detailed: Function completion.\n",
				"Level 3 - Enhanced: Within-function variable tracking.\n",
				"Level 4 - Verbose: Extremely detailed information, including table dumps."
			})
		end
	end


	-- LibHarvensAddonSettings options

	local settingsOptions =
	{
		allowDefaults = true,  -- Show "Reset to Defaults" button
		defaultsFunction = RestoreOptionDefaults,
		allowRefresh = true    -- Enable automatic control updates
	}


	-- Set up controls of the settings panel

	local titlePanel =
	{
		type = LibHarvensAddonSettings.ST_SECTION,
		label = ADDON_SYSTEM_NAME
	}


	local subtitlePanel =
	{
		type = LibHarvensAddonSettings.ST_LABEL,
		label = "by " .. ADDON_AUTHOR
	}


	local matchingPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Item Matching Options"
		},
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = "Overview",
			tooltip = "Some items, such as gear, have multiple attributes that distinguish them from other similar items. When this add-on counts how many of an item you have, some of these attributes can be used or ignored. You may set your preferences here. Items with inherent traits or other attributes may have different identifiers for otherwise identical items. For example, a Ring of the Trainee can come with arcane, robust, or healthy traits, but each of those have a separate identifier and will not match."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Base Level",
			default = LUXHRYS.optionDefaults.matching.useLevel,
			getFunction = function () return self.matching.useLevel end,
			setFunction = function (value) self.matching.useLevel = value end,
			tooltip = "Should matching take the item's required base level to equip into account?\n\nMatching by champion points required to equip controlled by a different setting."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Champion Points",
			default = LUXHRYS.optionDefaults.matching.useCP,
			getFunction = function () return self.matching.useCP end,
			setFunction = function (value) self.matching.useCP = value end,
			tooltip = "Should matching take the item's required champion points to equip into account?\n\nMatching by base level required to equip is controlled by a different setting."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Trait",
			default = LUXHRYS.optionDefaults.matching.useTrait,
			getFunction = function () return self.matching.useTrait end,
			setFunction = function (value) self.matching.useTrait = value end,
			tooltip = "Should matching take trait into account? Using this option is not recommended since traits can vary so much, but it can be useful for counting or locating very specific items."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Motif",
			default = LUXHRYS.optionDefaults.matching.useMotif,
			getFunction = function () return self.matching.useMotif end,
			setFunction = function (value) self.matching.useMotif = value end,
			tooltip = "Should matching take motif into account? This option only applies to the motif that the item was crafted in. It does not consider the applied outfit style, which is not attached to the item but the player. Using this option is not recommended since motif can vary so much, but it can be useful for counting or locating very specific items."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Enchantment Type",
			default = LUXHRYS.optionDefaults.matching.useEnchant,
			getFunction = function () return self.matching.useEnchant end,
			setFunction = function (value) self.matching.useLevel = value end,
			tooltip = "Should matching take enchantment into account? This option only applies to enchantment type. It does not consider the level or quality of the enchantment. Using this option is not recommended since enchantments can vary so much, but it can be useful for counting or locating very specific items."
		}
--[[,
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Reserved",
			default = LUXHRYS.optionDefaults.matching.useLevel,
			getFunction = function () return self.matching.useLevel end,
			setFunction = function (value) self.matching.useLevel = value end,
		}
]]
	}


	local asyncPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Asynchronous Processing Options"
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Enable Asynchronous Processing",
			default = LUXHRYS.optionDefaults.useAsync,
--			getFunction = GetOptionValue ("useAsync"),
--			setFunction = SetOptionValue ("useAsync", value)
			getFunction = function () return self.async.useAsync end,
			setFunction = function (value) self.async.useAsync = value end,
--			tooltip = GetAsyncTooltipText
		}
	}


	local inventoryBagsPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Inventory Location Options",
--			tooltip = "All inventory locations are handled by this add-on, excluding the bank, ESO+ expanded bank, and crafting bag, since the items in those locations are always visible to all characters. Below, you will find settings to enable or disable each inventory location. The icons appearing for each category will appear on tooltips with the related item count."
		},
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = "Overview",
			tooltip = "All inventory locations are handled by this add-on, excluding the bank, ESO+ expanded bank, and crafting bag, since the items in those locations are always visible to all characters. Below, you will find settings to enable or disable each inventory location. The icons appearing for each category will appear on tooltips with the related item count."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_WORN) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_WORN],
			getFunction = function () return self.bagTracking[BAG_WORN] end,
			setFunction = function (value) self.bagTracking[BAG_WORN] = value end,
			tooltip = "Enable scanning of the " .. Bag.GetName (BAG_WORN) .. " on each character so you can see it while playing other characters." -- "If you only use one character, enabling this option will waste memory." -- Equipped items do not appear in base tooltip stack count.
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_BACKPACK) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_BACKPACK],
			getFunction = function () return self.bagTracking[BAG_BACKPACK] end,
			setFunction = function (value) self.bagTracking[BAG_BACKPACK] = value end,
			tooltip = "Enable scanning of each character's " .. Bag.GetName (BAG_BACKPACK) .. " so you can see its contents while playing characters. If you only use one character, enabling this option will waste memory."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_GUILD) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_GUILDBANK],
			getFunction = function () return self.bagTracking[BAG_GUILDBANK] end,
			setFunction = function (value) self.bagTracking[BAG_GUILDBANK] = value end,
			tooltip = "Enable scanning of accessible " .. Bag.GetName (BAG_GUILDBANK) .. "s so you can see their contents when not at the banker. If you enable this option but do not currently have full access to any " .. Bag.GetName (BAG_GUILDBANK) .. "s, no inventory will be counted until you gain access to remove items from a " .. Bag.GetName (BAG_GUILDBANK) .. "."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_BUYBACK) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_BUYBACK],
			getFunction = function () return self.bagTracking[BAG_BUYBACK] end,
			setFunction = function (value) self.bagTracking[BAG_BUYBACK] = value end,
			tooltip = "Enable scanning of the " .. Bag.GetName (BAG_BUYBACK) .. " items for each character so you can see them while playing other characters or not at the vendor."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_COLLECTIBLE_STORAGE) end,
			default = STATE:IsAnyHousingStorageCollected () and LUXHRYS.optionDefaults.bagTracking[BAG_HOUSE_BANK_ONE], -- Proxy for all housing storage.
--			getFunction = function () return self.bagTracking[BAG_HOUSE_BANK_ONE] end,
			getFunction = GetHousingStorageOption, -- This is a little more robust than relying on first housing chest, because the player may not have that chest and it could lead to problems.
			setFunction = SetHousingStorageOption,
			tooltip = GetHousingStorageTooltipText,
			disable = ShouldDisableHousingStorage
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_COMPANION) end,
			default = STATE:IsAnyCompanionCollected () and LUXHRYS.optionDefaults.bagTracking[BAG_COMPANION_WORN],
			getFunction = function () return self.bagTracking[BAG_COMPANION_WORN] end,
			setFunction = function (value) self.bagTracking[BAG_COMPANION_WORN] = STATE:IsAnyCompanionCollected () and value or false end,
			tooltip = GetCompanionTooltipText,
			disable = ShouldDisableCompanions
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_FURNITURE_VAULT) end,
			default = HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault () and LUXHRYS.optionDefaults.bagTracking[BAG_FURNITURE_VAULT],
			getFunction = function () return self.bagTracking[BAG_FURNITURE_VAULT] end,
			setFunction = function (value) self.bagTracking[BAG_FURNITURE_VAULT] = HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault () and value or false end,
			tooltip = GetFurnitureVaultTooltipText,
			disable = ShouldDisableFurnitureVault
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_VENGEANCE) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_VENGEANCE],
			getFunction = function () return self.bagTracking[BAG_VENGEANCE] end,
			setFunction = function (value) self.bagTracking[BAG_VENGEANCE] = value end,
			tooltip = "Enable scanning of your " .. Bag.GetName (BAG_VENGEANCE) .. " so you can see those items while outside of the PVP area."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_HOUSE) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_PLACED_FURNISHINGS],
			getFunction = function () return self.bagTracking[BAG_PLACED_FURNISHINGS] end,
			setFunction = function (value) self.bagTracking[BAG_PLACED_FURNISHINGS] = value end,
			tooltip = "Enable scanning of the " .. Bag.GetName (BAG_PLACED_FURNISHINGS) .. " in your homes so you can see them while outside of the house.  If you enable this option but do not currently have any homes, no inventory will be counted until you obtain and enter your own home."
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_INBOX) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_INBOX],
			getFunction = function () return self.bagTracking[BAG_INBOX] end,
			setFunction = function (value) self.bagTracking[BAG_INBOX] = value end,
			tooltip = "Enable scanning of your " .. Bag.GetName (BAG_INBOX) .. " so you can see the items in your mail attachments.",
--			disable = ShouldDisableMailOptions
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = function () return GetOptionsPanelLabelIconString (LOCATION_TYPE_FILTER_TRADER) end,
			default = LUXHRYS.optionDefaults.bagTracking[BAG_TRADER],
			getFunction = function () return self.bagTracking[BAG_TRADER] end,
			setFunction = function (value) self.bagTracking[BAG_TRADER] = value end,
			tooltip = "Enable scanning of your " .. Bag.GetName (BAG_TRADER) .. " listings so you can see them while away from the " .. Bag.GetName (BAG_TRADER) .. ". If you enable this option but do not currently have access to list on any " .. Bag.GetName (BAG_TRADER) .. "s, no inventory will be counted until you gain access to do so. Existing listings will not be counted."
		}
	}


-- TODO: Implement VaC menu options, such as tab order, tab exclusion, &c.
-- TODO: Implement VaC custom sort order.

--[[ Reorder example from zo_guildranks_gamepad.lua


------------------
-- Reorder Rank --
------------------

function ZO_GuildRanks_Gamepad:GetSelectedRankIndex()
    return self:GetRankIndexById(self.selectedRank:GetRankId())
end

function ZO_GuildRanks_Gamepad:IsGuildMasterSelected()
    if self.selectedRank ~= nil and self.selectedRank.index ~= nil then
        return IsGuildRankGuildMaster(self.guildId, self.selectedRank.index)
    end

    return false
end

function ZO_GuildRanks_Gamepad:IsLastRankSelected()
    return self:GetSelectedRankIndex() >= #self.ranks
end

function ZO_GuildRanks_Gamepad:InSecondRankSelected()
    return self:GetSelectedRankIndex() <= GUILDMASTER_INDEX + 1
end

function ZO_GuildRanks_Gamepad:ReorderSelectedRank(up)
    if self.selectedRank ~= nil then
        local oldIndex = self:GetSelectedRankIndex()
        local newIndex = oldIndex
        if up then
            newIndex = newIndex - 1
        else
            newIndex = newIndex + 1
        end

        newIndex = zo_clamp(newIndex, GUILDMASTER_INDEX + 1, #self.ranks)

        if newIndex ~= oldIndex then
            local tmp = self.ranks[oldIndex]
            self.ranks[oldIndex] = self.ranks[newIndex]
            self.ranks[newIndex] = tmp

            PlaySound(SOUNDS.GUILD_RANK_REORDERED)

            self:ActivateRankList(REFRESH_SCREEN)
            self.rankList:SetSelectedIndexWithoutAnimation(newIndex)
        end
    end
end

           if not isGuildmasterRankSelected then
                if not self:InSecondRankSelected() then
                    data = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_RANK_REORDER_UP), ICON_REORDER_UP)
                    data.unfadeRankList = true
                    data.callback = function()
                        self:ReorderSelectedRank(true)
                    end
                    AddEntry(data)
                end

                if not self:IsLastRankSelected() then
                    data = ZO_GamepadEntryData:New(GetString(SI_GAMEPAD_GUILD_RANK_REORDER_DOWN), ICON_REORDER_DOWN)
                    data.unfadeRankList= true
                    data.callback = function()
                        self:ReorderSelectedRank(false)
                    end
                    AddEntry(data)
                end
            end


]]


	local mailPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Mailbox Options"
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Keep Scanned Messages as Unread",
			default = LUXHRYS.optionDefaults.useAsync,
--			getFunction = GetOptionValue ("mail", "keepUnread"),
--			setFunction = SetOptionValue (value, "mail", "keepUnread"),
			getFunction = function () return self.mail.keepUnread end,
			setFunction = function (value) self.mail.keepUnread = value end,
			tooltip = "When the add-on scans your " .. Bag.GetName (BAG_INBOX) .. " to inventory your attachments, the server sets the messages as read. If you would like the add-on to mark scanned messages as unread until you actually read them, enable this setting. To differentiate from messages that the server considers unread, scanned messages will display a tinted new mail icon. You may use the default mint green color or choose an alternative below.",
			disable = ShouldDisableMailOptions
		},
--		{
--			type = LibHarvensAddonSettings.ST_LABEL,
--			label = "Mail Attachment Inventory"
--		},
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "Enable Rescan",
			buttonText = "Enable Rescan",
			tooltip = "If your " .. Bag.GetName (BAG_INBOX) .. " inventory cache becomes unsynchronized, you may click this button to clear and rebuild it the next time your " .. Bag.GetName (BAG_INBOX) .. " is scanned.",
--			clickHandler = SetOptionValue (true, "mail", "firstRun"),
			clickHandler = function () self.mail.rebuild = true end,
			disable = ShouldDisableMailOptions
		}
	}


	local colorPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Color Options"
		},

		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = "Overview",
			tooltip = "Choose the color for this add-on's tooltip inventory counts, unread mail indicators, and other icons and text. In tooltips, icons will always be slightly subdued compared to the text."
		},
		{
			type = LibHarvensAddonSettings.ST_COLOR,
--			label = "Text Color",
--			tooltip = "Choose the text color",
--			tooltip = "Choose the color for this add-on's tooltip inventory counts, unread mail indicators, and other icons and text. In tooltips, icons will always be slightly subdued compared to text.",
			getFunction = GetCurrentColorSettings,
			setFunction = function (r, g, b) SetCurrentColorSettings (r, g, b) end,
			default = {
				LUXHRYS.optionDefaults.masterColor.r,
				LUXHRYS.optionDefaults.masterColor.g,
				LUXHRYS.optionDefaults.masterColor.b,
				LUXHRYS.optionDefaults.masterColor.a
			}
		},
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "Restore Add-On Default Color",
			buttonText = "Restore Default",
			clickHandler = RestoreDefaultColorSettings
		}
	}


	local debugPanel =
	{
		{
			type = LibHarvensAddonSettings.ST_SECTION,
			label = "Debugging Options"
		},
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			min = 0, -- Basic informational and warning messages
			max = 4, -- Verbose output
			step = 1,
			format = "%d",
			tooltip = GetDebugLevelTooltipText,
			default = LUXHRYS.optionDefaults.debugLevel,
			getFunction = function () return self.debugLevel end,
			setFunction = function (value) self.debugLevel = value end,
			disable = IsNotDeveloper
		},
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Force Console Mode",
			tooltip = "Enable forced console mode. Changing this option will reload the UI.",
			getFunction = function () return GetCVar("ForceConsoleFlow.2") == "1" end,
			setFunction = function (value) SetCVar("ForceConsoleFlow.2", value == true and "1" or "0") end,
			disable = IsNotDeveloper
		},
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "Flush Memory",
			buttonText = "Flush Memory",
			clickHandler = MemoryFlush
		},
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = "Add-On Information",
			tooltip = GetCurrentNonconfigurableOptionValues
		}
	}


	-- Create the panel.

	self.settingsPanel = LibHarvensAddonSettings:AddAddon(ADDON_SYSTEM_NAME, settingsOptions)

--	DebugMsg (2, "IO: Setting up title panel.")
--	settingsPanel:AddSettings (titlePanel)

	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up matching panel.")
	self.settingsPanel:AddSettings (matchingPanel)
	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up subtitle panel.")
	self.settingsPanel:AddSettings (subtitlePanel)
	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up async panel.")
	self.settingsPanel:AddSettings (asyncPanel)
	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", " Setting up bags panel.")
	self.settingsPanel:AddSettings (inventoryBagsPanel) -- tooltips

-- TODO: Implement extended inventory menu options, such as tab order, tab exclusion, &c.

	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up mail panel.")
	self.settingsPanel:AddSettings (mailPanel)
	Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up color panel.")
	self.settingsPanel:AddSettings (colorPanel)

	if IsNotDeveloper () == false then
		Debug.Msg (4, ADDON_DEBUG_NAME, "IO", "Setting up debug panel.")
		self.settingsPanel:AddSettings (debugPanel)
	end

end


-- =========================== [ Initialization ] ========================== --


-- Some "classes" rely on OPTIONS or use saved variables, which cannot be
-- initialized until EVENT_ADD_ON_LOADED.

local function InitializeOptions (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug = LUXHRYS.Debug

		Debug.Msg (1, ADDON_DEBUG_NAME, "IO", "Initializing %s.", ADDON_CHUNK_NAME)

		LUXHRYS.OPTIONS = Options:New ()
		StrUtils = LUXHRYS.StrUtils
		Bag = LUXHRYS.Bag
		icons = LUXHRYS.icons
		Location = LUXHRYS.Location

		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)

		Debug.Msg (1, ADDON_DEBUG_NAME, "IO", "%s initialization %s.", ADDON_CHUNK_NAME, LUXHRYS.OPTIONS ~= nil and "successful" or "failed")
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeOptions)


-- We need STATE and COLORS for this, which won't initialize until after
-- OPTIONS. We'll delay initializing the setting panel.

local function InitializeSettingsPanel (_, addonName)
	Debug.Msg (1, ADDON_DEBUG_NAME, "ISP", "Starting %s Panel.", ADDON_CHUNK_NAME)

	STATE = LUXHRYS.STATE
	COLORS = LUXHRYS.COLORS

	LUXHRYS.OPTIONS:InitializeSettingsPanel ()

	EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED)

	Debug.Msg (1, ADDON_DEBUG_NAME, "ISP", "%s Panel now available.", ADDON_CHUNK_NAME)
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_PLAYER_ACTIVATED, InitializeSettingsPanel)














