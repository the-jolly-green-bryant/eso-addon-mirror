-- Globals
-- ICDT = {} -- initialized in language file (en)
--ICDT.loc = {} -- initialized in language file (en)
ICDT.isAddonLoaded = false
ICDT.appName = "ItemCooldownTracker"
ICDT.displayedAppName = "|cd5b526Item|r Cooldown Tracker"
ICDT.version = "" -- will be set according to the the verion in manifest file
ICDT.author = "DeadSoon"
ICDT.website = "https://www.esoui.com/downloads/info2823-ItemCooldownTracker.html"
ICDT.chatBegin = "[ICT]"
ICDT.color = {
	colTrash     = "777777", -- Trash Gray
    colYellow    = "FFFF00" ,-- yellow
    colArcane    = "3689ef", -- blue (Rare)
    colWhite     = "FFFFFF", -- white
    colRed       = "FF0000", -- Red
    colLegendary = "d5b526", -- gold (TheShit)
    colGreen     = "00FF00", -- green
	colOrange    = "fd7a1a", -- orange
  }

ICDT.currentItem = nil

ICDT.tooltipActive = false
ICDT.tooltipCurrentControl = 0

-- server reset times in UTC
ICDT.serverResetTimes = {
	["EU Megaserver"] = 3,
	["NA Megaserver"] = 10,
	["PTS"] = 10, -- Note: PTS has always reset time from NA server
}

-------- HELPER FUNCITONS --------
-- colorize text
function ICDT.colorizeText(text, color)
	if type(color) == "string" then
		local code = ICDT.color.colWhite
		
		if string.lower(color) == "gray" then
			code = ICDT.color.colTrash
		elseif string.lower(color) == "yellow" then
			code = ICDT.color.colYellow
		elseif string.lower(color) == "blue" then
			code = ICDT.color.colArcane
		elseif string.lower(color) == "white" then
			code = ICDT.color.colWhite
		elseif string.lower(color) == "red" then
			code = ICDT.color.colRed
		elseif string.lower(color) == "gold" then
			code = ICDT.color.colLegendary
		elseif string.lower(color) == "green" then
			code = ICDT.color.colGreen
		elseif string.lower(color) == "orange" then
			code = ICDT.color.colOrange
		end
		
		return "|c" .. code .. tostring(text) .. "|r"
	end
end


-- send addon messages to the chat
function ICDT.printToChat(text)
	local prefix_colorized = ICDT.colorizeText(ICDT.chatBegin, "white")

	d(prefix_colorized .. ": " .. text)
end


-- returns a table with all numbers in range (including from and to)
local function range(from , to)
	local result = {}
	for i=from, to do
		table.insert(result, i)
	end
	return result
end


function ICDT.tableMerge(t1, t2)
	for k,v in pairs(t2) do
	   table.insert(t1, v)
	end 
	return t1
 end


-- calculates the difference between local and UTC time (in seconds)
-- the value is the offset to convert a timestamp of a specific local time into a timestamp with same time in UTC
function ICDT.getDifferenceFromUTC()
	local tmp_time = os.time()
	-- local date object
	local d1 = os.date("*t",  tmp_time)
	-- UTC date object
	local d2 = os.date("!*t", tmp_time)
	d1.isdst = false
	-- calculate difference (d1-d2) 
	local zone_diff = os.difftime(os.time(d1), os.time(d2))
	return zone_diff
end
--------


-- List of all trackable items
-- NOTE: add new items here in the beginning of the list to display them ingame in the end of the dropdown!
ICDT.trackableItemList = {
	-- PVP
	-- "Rewards For the Worthy"
	["transmutRewardCyrodiil"] = {
		name = ICDT.loc.items.transmutRewardCyrodiil,
		itemIds = {211304},
		overwriteTimestamp = false,
		containers = {134619, 145577, 181436, 184171, 190009, 194353, 204404, 210866, 214239, 219651, 224367},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["fragCyrodiil"] = {
		name = ICDT.loc.items.fragCyrodiil,
		itemIds = {138783},
		overwriteTimestamp = true,
		containers = {138812},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["fragImperialCity"] = {
		name = ICDT.loc.items.fragImperialCity,
		itemIds = {151939},
		overwriteTimestamp = true,
		containers = {151941},
		conditions = {
			onlyFromContainer = true,
		},
	},

	["dropRemainsSilent"] = {
	-- https://en.uesp.net/wiki/Online:Remains-Silent
		name = ICDT.loc.items.dropRemainsSilent,
		itemIds = {
		-- special items
		79675, 79677, 71779, 73754, 79504,
		-- all Sithis set items
		unpack(range(77236, 77525))
		},
		overwriteTimestamp = true,
		conditions = {
			onlyInOutlawZone = true,
		},
	},
	
	-- Southern Elsweyr
	["styleShieldOfSenchal"] = {
		name = ICDT.loc.items.styleShieldOfSenchal,
		itemIds = range(156628, 156641),
		overwriteTimestamp = false,
		containers = {153853, 153854},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleDragonguard"] = {
		name = ICDT.loc.items.styleDragonguard,
		itemIds = range(156556, 156569),
		overwriteTimestamp = false,
		containers = {153851, 153852},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleNewMoon"] = {
		name = ICDT.loc.items.styleNewMoon,
		itemIds = range(156609, 156622),
		overwriteTimestamp = true,
		conditions = {
			onlyInZone = {1146},
		},
	},
	
	-- Greymoor
	["styleBlackreachVanguard"] = {
		name = ICDT.loc.items.styleBlackreachVanguard,
		itemIds = range(160494, 160507),
		overwriteTimestamp = false,
		containers = {165575, 165576},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleGreymoor"] = {
		name = ICDT.loc.items.styleGreymoor,
		itemIds = range(160543, 160556),
		overwriteTimestamp = false,
		containers = {165577},
		conditions = {
			onlyFromContainer = true,
		},
	},
	
	-- Markarth
	["styleArkthzandArmory"] = {
		name = ICDT.loc.items.styleArkthzandArmory,
		itemIds = range(167961, 167974),
		overwriteTimestamp = false,
		containers = {170223, 170224},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleNighthollow"] = {
		name = ICDT.loc.items.styleNighthollow,
		itemIds = range(167944, 167957),
		overwriteTimestamp = false,
		containers = {170225},
		conditions = {
			onlyFromContainer = true,	-- could also drop from Harrowstorms (*)
		},
	},
	["styleWaywardGuardian"] = {
		name = ICDT.loc.items.styleWaywardGuardian,
		itemIds = range(167978, 167991),
		overwriteTimestamp = false,
		containers = {170226},
		conditions = {
			onlyFromContainer = true,
		},
	},
	
	-- Blackwood
	["styleBlackFinLegion"] = {
		name = ICDT.loc.items.styleBlackFinLegion,
		itemIds = range(171879, 171892),
		overwriteTimestamp = false,
		containers = {178407},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleIvoryBrigade"] = {
		name = ICDT.loc.items.styleIvoryBrigade,
		itemIds = range(171896, 171909),
		overwriteTimestamp = false,
		containers = {178408},
		conditions = {
			onlyFromContainer = true,
		},
	},
	
	-- Deadlands / Fargrave
	["styleHouseHexos"] = {
		name = ICDT.loc.items.styleHouseHexos,
		itemIds = range(170132, 170145),
		overwriteTimestamp = false,
		containers = {182936},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleFargraveGuardian"] = {
		name = ICDT.loc.items.styleFargraveGuardian,
		itemIds = range(178707, 178720),
		overwriteTimestamp = false,
		containers = {183008},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleAnnihilarch"] = {
		name = ICDT.loc.items.styleAnnihilarch,
		itemIds = range(178529, 178542),
		overwriteTimestamp = true,
		conditions = {
			onlyInZone = {1310},
		},
	},
	
	-- High Isle
	["styleSteadfastSociety"] = {
		name = ICDT.loc.items.styleSteadfastSociety,
		itemIds = range(182538, 182551),
		overwriteTimestamp = false,
		containers = {188137},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleSystresGuardian"] = {
		name = ICDT.loc.items.styleSystresGuardian,
		itemIds = range(182555, 182568),
		overwriteTimestamp = false,
		containers = {188136},
		conditions = {
			onlyFromContainer = true,
		},
	},

	-- Firesong (Galen)
	["styleHouseMornard"] = {
		name = ICDT.loc.items.styleHouseMornard,
		itemIds = range(188325, 188338),
		overwriteTimestamp = false,
		containers = {190948, 190949},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleFiresong"] = {
		name = ICDT.loc.items.styleFiresong,
		itemIds = range(188308, 188321),
		overwriteTimestamp = false,
		containers = {190952},
		conditions = {
			onlyFromContainer = true,	-- could also drop from Vulkanos (*)
		},
	},

	-- Necrom (Telvanni)
	["styleDeadKeeper"] = {
		name = ICDT.loc.items.styleDeadKeeper,
		itemIds = range(194514, 194527),
		overwriteTimestamp = false,
		containers = {197819},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleKindred"] = {
		name = ICDT.loc.items.styleKindred,
		itemIds = range(194541, 194554),
		overwriteTimestamp = false,
		containers = {197818, 197820},
		conditions = {
			onlyFromContainer = true,	-- could also drop from bosses in Bastion Nymic (*)
		},
	},

	-- Gold Road
	["styleShardBorn"] = {
		name = ICDT.loc.items.styleShardBorn,
		itemIds = range(203361, 203374),
		overwriteTimestamp = false,
		containers = {207980, 207981},
		conditions = {
			onlyFromContainer = true,
		},
	},
	["styleWestWealdLegion"] = {
		name = ICDT.loc.items.styleWestWealdLegion,
		itemIds = range(203474, 203487),
		overwriteTimestamp = false,
		containers = {207982},
		conditions = {
			onlyFromContainer = true,
		},
	},

	-- Seasons of the Worm Cult Part 1
	["styleTideBorn"] = {
		name = ICDT.loc.items.styleTideBorn,
		itemIds = range(212119, 212132),
		overwriteTimestamp = false,
		containers = {217731, 217732},
		conditions = {
			onlyFromContainer = true,
		},
	},

	-- * We assume that the drop from sources other than the specific container does not count for the cooldown. Furthermore, it is not trivial to detect a drop from a specific source (e.g. NPC or location).


	-- PUBLIC DUNGEON FRAGMENTS
	-- https://en.uesp.net/wiki/Online:Fragments#Public_Dungeon_Fragments

	-- Morrowind
	-- Dwarven Theodolite
	["fragPdDwarven"] = {
		name = ICDT.loc.prefix.morrowind .. zo_strformat("<<C:1>>", GetCollectibleName(1232)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = range(124660, 124666),
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {918},
		},
	},
	-- Sixth House Robe
	["fragPdSixthHouse"] = {
		name = ICDT.loc.prefix.morrowind .. zo_strformat("<<C:1>>", GetCollectibleName(1230)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = range(124667, 124673),
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {919},
		},
	},

	-- Summerset
	-- Big-Eared Ginger Kitten
	["fragPdBigEared"] = {
		name = ICDT.loc.prefix.summerset .. zo_strformat("<<C:1>>", GetCollectibleName(4996)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = range(139450, 139456),
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1020},
		},
	},
	-- Psijic Glowglobe
	["fragPdPsijic"] = {
		name = ICDT.loc.prefix.summerset .. zo_strformat("<<C:1>>", GetCollectibleName(5047)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = range(139457, 139463),
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1021},
		},
	},

	-- Elsweyr
	-- Grisly Mummy Tabby
	["fragPdGrisly"] = {
		name = ICDT.loc.prefix.elsweyr .. zo_strformat("<<C:1>>", GetCollectibleName(6381)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {147929},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1089},
		},
	},
	-- Peryite Skeevemaster
	["fragPdPeryite"] = {
		name = ICDT.loc.prefix.elsweyr .. zo_strformat("<<C:1>>", GetCollectibleName(6292)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {147930},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1090},
		},
	},

	-- Greymoor
	-- Master Field Cartographer
	["fragPdMasterField"] = {
		name = ICDT.loc.prefix.greymoor .. zo_strformat("<<C:1>>", GetCollectibleName(7622)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = range(166700, 166706),
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1187},
		},
	},
	-- Target Stone Husk (item)
	["fragPdTargetStone"] = {
		name = ICDT.loc.prefix.greymoor .. "'Target Stone Husk'" .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {166466},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1186},
		},
	},

	-- Blackwood
	-- Thrafey Debutante Gown
	["fragPdThrafey"] = {
		name = ICDT.loc.prefix.blackwood .. zo_strformat("<<C:1>>", GetCollectibleName(8888)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {178463},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1260},
		},
	},
	-- Replica Zenithar Adytum Gate
	["fragPdReplica"] = {
		name = ICDT.loc.prefix.blackwood .. zo_strformat("<<C:1>>", GetCollectibleName(9523)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {178462},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1259},
		},
	},

	-- High Isle
	-- Coral Haj Mota_1 (same collectible but two different fragments)
	["fragPdCoralHaj_1"] = {
		name = ICDT.loc.prefix.highIsle .. zo_strformat("<<C:1>>", GetCollectibleName(9797)) .. ICDT.loc.suffix.publicDungeonFragment .. " 1/2",
		itemIds = {188271},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1337},
		},
	},
	-- Coral Haj Mota_2 (same collectible but two different fragments)
	["fragPdCoralHaj_2"] = {
		name = ICDT.loc.prefix.highIsle .. zo_strformat("<<C:1>>", GetCollectibleName(9797)) .. ICDT.loc.suffix.publicDungeonFragment .. " 2/2",
		itemIds = {188200},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1338},
		},
	},

	-- Necrom
	-- Graht-Oak Squirrel_1 (same collectible but two different fragments)
	["fragPdGrahtOak_1"] = {
		name = ICDT.loc.prefix.necrom .. zo_strformat("<<C:1>>", GetCollectibleName(10912)) .. ICDT.loc.suffix.publicDungeonFragment .. " 1/2",
		itemIds = {197649},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1415},
		},
	},
	-- Graht-Oak Squirrel_2 (same collectible but two different fragments)
	["fragPdGrahtOak_2"] = {
		name = ICDT.loc.prefix.necrom .. zo_strformat("<<C:1>>", GetCollectibleName(10912)) .. ICDT.loc.suffix.publicDungeonFragment .. " 2/2",
		itemIds = {198095},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1416},
		},
	},

	-- Gold Road
	-- Echo of the Abolisher_1 (same collectible but two different fragments)
	["fragPdEchoAbolisher_1"] = {
		name = ICDT.loc.prefix.goldRoad .. zo_strformat("<<C:1>>", GetCollectibleName(12444)) .. ICDT.loc.suffix.publicDungeonFragment .. " 1/2",
		itemIds = {207814},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1467},
		},
	},
	-- Echo of the Abolisher_2 (same collectible but two different fragments)
	["fragPdEchoAbolisher_2"] = {
		name = ICDT.loc.prefix.goldRoad .. zo_strformat("<<C:1>>", GetCollectibleName(12444)) .. ICDT.loc.suffix.publicDungeonFragment .. " 2/2",
		itemIds = {207815},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1466},
		},
	},

	-- Seasons of the Worm Cult Part 1
	-- Eviscerate, Violet Purple
	["fragEviVioletPurple"] = {
		name = ICDT.loc.prefix.wormCult1 .. zo_strformat("<<C:1>>", GetCollectibleName(13792)) .. ICDT.loc.suffix.publicDungeonFragment,
		itemIds = {217925},
		overwriteTimestamp = false,
		conditions = {
			onlyInZone = {1514},
		},
	},

}


------------------------------------
-- initialization functions
local function playerInitAndReady()
    zo_callLater(function() ICDT.initialize() end, 1000)
	EVENT_MANAGER:UnregisterForEvent(ICDT.appName, EVENT_PLAYER_ACTIVATED)
	
	-- set hooks for item interactions
	if ICDT.savedVars.preventOpening then
		ZO_PreHook('ZO_InventorySlot_DoPrimaryAction', ICDT.primaryActionPreHook)
	elseif ICDT.savedVars.preventOpeningRestrict then
		ZO_PreHookProtected('UseItem', ICDT.useItemPreHook)
	end
	ICDT.preHookItemTooltip_OnUpdate()
	ICDT.preHookItemTooltip_OnHide()
end


local function onAddonLoaded(eventCode, addonName)
    if (ICDT.appName ~= addonName) then return end
	
	--Read the addon version from the addon's txt manifest file tag ##AddOnVersion
	local function GetAddonVersionFromManifest()
		local addOn_Name
		local ADDON_MANAGER = GetAddOnManager()
		for i = 1, ADDON_MANAGER:GetNumAddOns() do
			addOn_Name = ADDON_MANAGER:GetAddOnInfo(i)
			if addOn_Name == ICDT.appName then
				return ADDON_MANAGER:GetAddOnVersion(i)
			end
		end
		return -1
		-- Fallback: return the -1 version if AddOnManager was not read properly
	end

	--Set the version dynamically
	ICDT.version = tostring(GetAddonVersionFromManifest())

	-- defaults
    ICDT.defaults = {
		firstStart = true,
		preventOpening = true,
		preventOpeningRestrict = false,
		trackedItems = {},
    }
	
	ICDT.savedVars = ZO_SavedVars:NewAccountWide("ItemCooldownTracker_SV", 2, nil, ICDT.defaults, GetWorldName())
	
	-- May 2022
	-- tracking for every item should be active by default
	-- if the key of the tracked item is not in the savedVars (check if key exists) -> add the key
	-- in case the item is intentional untracked by the user, the key exists but is set to false
	for key, item in pairs(ICDT.trackableItemList) do
		if ICDT.savedVars.trackedItems[key] == nil then
			-- key does not appear in savedVars
			-- add to the list
			ICDT.savedVars.trackedItems[key] = true
		end
	end
	-- March 2023
	-- with Update 37 several trackable items need to be removed / deactivated temporary
	-- go over trackedItems from savedVars and remove all entries that are no longer trackable/supported
	for key, _ in pairs(ICDT.savedVars.trackedItems) do
		if not ICDT.has_index(ICDT.trackableItemList, key) then
			-- tracked item from savedVars is no longer supported
			-- remove entry from savedVars
			ICDT.savedVars.trackedItems[key] = nil
		end
	end

	EVENT_MANAGER:RegisterForEvent(ICDT.appName, EVENT_PLAYER_ACTIVATED, playerInitAndReady)	
end


function ICDT.initialize()
	-- build dropdown
	ICDT.buildDropdown()
	
	-- build settings menu
	ICDT.initializeSettingsMenu()
	
	-- register chat command
	ICDT.registerChatCommands()
	
	-- register for loot receiving
	EVENT_MANAGER:RegisterForEvent(ICDT.appName, EVENT_LOOT_RECEIVED, ICDT.lootReceived)
	
	-- check for notification
	ICDT.checkForNotification()

	-- calculate time difference to UTC times
	ICDT.zoneDiffUTC = ICDT.getDifferenceFromUTC()
end


function ICDT.initializeSettingsMenu()
	local LAM = LibAddonMenu2
	
	local panelData = {
		type 				= 'panel',
		name 				= ICDT.appName,
		displayName 		= ICDT.displayedAppName,
		author 				= ICDT.author,
		version 			= ICDT.version,
		website             = ICDT.website,
	--	feedback            = "",
		registerForRefresh  = true,
		registerForDefaults = true,
       }
	
	ICDT.SettingsPanel = LAM:RegisterAddonPanel(ICDT.appName .. "Options", panelData)
	
	local itemDescriptionDetailed = {
		type = "description",
		text = ICDT.loc.settings.itemDescriptionDetailed,
	}
	
	local optionsData = {
	     {
              type = "description",
              text = ICDT.loc.settings.introDescription,
         },
		 {
              type = "dropdown",
              name = ICDT.loc.settings.itemsToTrack,
              tooltip = ICDT.loc.settings.itemsToTrackTooltip,
			  choices = ICDT.dropdownItemsChoices,
			  choicesValues = ICDT.dropdownItemsValues,
              getFunc = function() return ICDT.currentItem end,
			  setFunc = function(key) ICDT.currentItem = key end,
			  default = nil,
			  sort = "name-up",
			  scrollable = true,
			  reference = "ICDT_ItemsTrackList",
         },
		 {
              type = "button",
              name = ICDT.loc.settings.trackSelected,
              tooltip = ICDT.loc.settings.trackSelectedTooltip,
              func = function() ICDT.trackSelectedItem(ICDT.currentItem) ICDT.updateSettingsDropdown() end,
			  disabled = function() if not ICDT.currentItem or ICDT.savedVars.trackedItems[ICDT.currentItem] then return true else return false end end,
			  width = "half",
         },
		 {
              type = "button",
              name = ICDT.loc.settings.untrackSelected,
              tooltip = ICDT.loc.settings.untrackSelectedTooltip,
              func = function() ICDT.untrackSelectedItem(ICDT.currentItem) ICDT.updateSettingsDropdown() end,
			  disabled = function() if ICDT.savedVars.trackedItems[ICDT.currentItem] then return false else return true end end,
			  width = "half",
         },
		 {
              type = "divider",
         },
		 {
              type = "checkbox",
              name = ICDT.loc.settings.preventOpening,
              tooltip = ICDT.loc.settings.preventOpeningTooltip .. " [DEFAULT: " .. tostring(ICDT.defaults.preventOpening) .. "]",
              getFunc = function() return ICDT.savedVars.preventOpening end,
              setFunc = function(value)
							ICDT.savedVars.preventOpening = value
							if value then
								ICDT.savedVars.preventOpeningRestrict = false
							end
						end,
			  default = ICDT.defaults.preventOpening,
			  requiresReload = true,
         },
		 {
              type = "checkbox",
              name = ICDT.loc.settings.preventOpeningRestrict,
              tooltip = ICDT.loc.settings.preventOpeningRestrictTooltip .. " [DEFAULT: " .. tostring(ICDT.defaults.preventOpeningRestrict) .. "]",
              getFunc = function() return ICDT.savedVars.preventOpeningRestrict end,
              setFunc = function(value)
							ICDT.savedVars.preventOpeningRestrict = value
							if value then
								ICDT.savedVars.preventOpening = false
							end
						end,
			  default = ICDT.defaults.preventOpeningRestrict,
			  requiresReload = true,
         },
		 {
              type = "submenu",
              name = ICDT.loc.settings.itemDescriptionDetailedHeader,
              tooltip = "",
			  controls = {itemDescriptionDetailed},
         },
	}
	
	LAM:RegisterOptionControls(ICDT.appName .. "Options", optionsData)
end


function ICDT.buildDropdown()
	-- dropdown list for settings
	ICDT.dropdownItemsChoices = {}
	ICDT.dropdownItemsValues = {}
	for key, item in pairs(ICDT.trackableItemList) do
		if ICDT.savedVars.trackedItems[key] then
			table.insert(ICDT.dropdownItemsChoices, ICDT.colorizeText(item.name, "green"))
		else
			table.insert(ICDT.dropdownItemsChoices, item.name)
		end
		table.insert(ICDT.dropdownItemsValues, key)
	end
end


-- rebuilds the choices & values for the dropdown in the setings menu
function ICDT.updateSettingsDropdown()
	ICDT.buildDropdown()
	ICDT_ItemsTrackList:UpdateChoices(ICDT.dropdownItemsChoices, ICDT.dropdownItemsValues)
end


function ICDT.registerChatCommands()
	SLASH_COMMANDS["/ict"] = ICDT.printCooldowns
end


-- display notifications or dialogs
function ICDT.checkForNotification()
	-- check for first start
	local LAM = LibAddonMenu2
	if ICDT.savedVars.firstStart then
		-- show setup info dialog
		ICDT.showDialogSimple("InitialSetup", ICDT.displayedAppName, ICDT.loc.dialogs.initialSetupBody, function() LAM:OpenToPanel(ICDT.SettingsPanel) ICDT.savedVars.firstStart = false end, nil)
	end

	-- check if server reset time is known (otherwise, addon cannot work probably)
	if not ICDT.serverResetTimes[GetWorldName()] then
		ICDT.showDialogSimple("NoDailyResetTime", ICDT.displayedAppName, ICDT.loc.dialogs.noServerResetTime, nil, nil)
	end
end

------------------------------------


-- adds the selected item(s) to the tracking list
function ICDT.trackSelectedItem(selectedItem)
	if selectedItem then
		-- initialize the index
		ICDT.savedVars.trackedItems[selectedItem] = true
	end
end


-- removes the selected item(s) from the tracking list
function ICDT.untrackSelectedItem(selectedItem)
	if selectedItem then
		-- remove the index the index
		ICDT.savedVars.trackedItems[selectedItem] = false
	end
end


-- triggered on any loot received
function ICDT.lootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
	-------
	--d("Current Scene: " .. SCENE_MANAGER:GetCurrentSceneName())
	--d("Previous Scene: " .. SCENE_MANAGER:GetPreviousSceneName())
	-------
	-- consider only items looted by the current player
	if self then
		-- check if itemId is in tracked items lists
		local tracked, key = ICDT.findTrackedItemKey(itemId)
		if tracked then
			-- check conditions (if existing)
			if ICDT.itemPassConditions(key) then
				ICDT.updateTimestamp(key, itemName)
			end
		end
	end
end


-- check if item passes the conditions
function ICDT.itemPassConditions(key)
	local flag_passed = true
	
	-- check if any condition exists
	if not ICDT.trackableItemList[key].conditions then
		return true
	else
		-- check existing conditions and set flag to false if one or more conditions violated
		-- if the item can only be obtained from opening a reward container/coffer, we need to check the scenes
		if ICDT.trackableItemList[key].conditions.onlyFromContainer then
			local currentScene = SCENE_MANAGER:GetCurrentSceneName()
			local prevScene = SCENE_MANAGER:GetPreviousSceneName()
			-- since we know the correct cases, we just negate our formula
			if not (
					-- user opens container in inventory and skipping loot scene (or "take all")
					(currentScene == "inventory" or currentScene == "gamepad_inventory_root")
				or
					-- main case: user get ussual loot coming from the inventory (you get also a loot scene if you loot anything in the open world)
					(currentScene == "loot" or currentScene == "lootGamepad" or currentScene == "lootInventoryGamepad") and (prevScene == "inventory" or prevScene == "gamepad_inventory_root")
				)
			then
				flag_passed = false
			end
		end
		-- check onlyInOutlawZone
		if ICDT.trackableItemList[key].conditions.onlyInOutlawZone then
			-- unfortunately Fargrave refuge is not correctly flagged as outlaw zone
			if not (IsInOutlawZone() or GetZoneId(GetUnitZoneIndex("player")) == 1293) then
				flag_passed = false
			end
		end
		-- check onlyInZone
		if ICDT.trackableItemList[key].conditions.onlyInZone then
			local playersZoneIndex = GetUnitZoneIndex("player")
			local playersZoneId = GetZoneId(playersZoneIndex)
			-- check if current zone is in the list
			if not ICDT.has_value(ICDT.trackableItemList[key].conditions.onlyInZone, playersZoneId) then
				flag_passed = false
			end
		end
		
		-- return result
		if flag_passed then
			return true
		else
			return false
		end
	end
end


-- find itemKey from itemId
function ICDT.findTrackedItemKey(itemId)
	for key, timestamp in pairs(ICDT.savedVars.trackedItems) do
		if ICDT.has_value(ICDT.trackableItemList[key].itemIds, itemId) then
			return true, key
		end
	end
	return false, nil
end


-- find itemKey from container's itemId
function ICDT.findTrackedItemKeyContainer(itemId)
	for key, timestamp in pairs(ICDT.savedVars.trackedItems) do
		if ICDT.has_value(ICDT.trackableItemList[key].containers, itemId) then
			return true, key
		end
	end
	return false, nil
end


-- update the timestamp of the tracked item
function ICDT.updateTimestamp(key, itemName)
	if not ICDT.isCooldownActive(key) or (ICDT.isCooldownActive(key) and ICDT.trackableItemList[key].overwriteTimestamp) then
		-- save current timestamp
		ICDT.savedVars.trackedItems[key] = GetTimeStamp()
		-- print message to chat
		ICDT.printToChat(ICDT.colorizeText(ICDT.loc.chat.lootRecorded, "green"))
		ICDT.printToChat(itemName)
		
		-- request prioritized saving of the savedVars
		GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(ICDT.appName)
	end
end


function ICDT.isCooldownActive(key)
	local timestamp_loot = ICDT.savedVars.trackedItems[key]
	if type(timestamp_loot) ~= "number" then
		-- no timestamp recorded
		return false
	end

	local serverResetTime = ICDT.serverResetTimes[GetWorldName()] or 0
	local localDate = os.date("*t")
	-- timestamp of a specific time of a day in local time zone + difference between UTC -> timestamp of a specific time of a day in UTC
	local daily_timestamp_1 = os.time({day=localDate.day, month=localDate.month, year=localDate.year, hour=serverResetTime, min=0 ,sec=0}) + ICDT.zoneDiffUTC
	
	local next_reset_time
	local previous_reset_time

	-- if daily_timestamp_1 is bigger than now, the specific time was not reached today, so this is the next server reset
	local timestamp_now = os.time(os.date("*t"))
	if daily_timestamp_1 > timestamp_now then
    	next_reset_time = daily_timestamp_1
    	previous_reset_time = daily_timestamp_1 - 86400 -- (minus 1 day)
	else
    	next_reset_time = daily_timestamp_1 + 86400 -- (plus 1 day)
    	previous_reset_time = daily_timestamp_1
	end

	if timestamp_loot > previous_reset_time then
		-- cooldon is still active
		-- the user has to wait until next reset time
		local secondsLeft = next_reset_time - timestamp_now
		local minutesLeft = math.floor(secondsLeft/60)
		return true, minutesLeft
	else
		return false, 0 
	end
end


-- check if any cooldown is active and print to chat
function ICDT.printCooldowns()
	local minutesLeftPrint
	d("-----------------------------")

	-- check all tracked items
	-- print all names where cooldown is active
	for key, timestamp in pairs(ICDT.savedVars.trackedItems) do
		local isCooldownActive, minutesLeft = ICDT.isCooldownActive(key)
		if isCooldownActive then
			-- since all cooldowns are the same (until next daily server reset), just use the last one
			minutesLeftPrint = minutesLeft
			ICDT.printToChat(ICDT.trackableItemList[key].name)
		end
	end

	if minutesLeftPrint then
		-- at least one item has cooldown
		local h, m = ICDT.FormatMinutes(minutesLeftPrint)
		ICDT.printToChat(ICDT.colorizeText(ICDT.loc.cooldownActive, "red"))
		ICDT.printToChat(string.format(ICDT.loc.chat.cooldownActiveTime, h,m))
	else
		-- no active cooldown
		ICDT.printToChat(ICDT.colorizeText(ICDT.loc.cooldownExpired, "green"))
	end
	
	d("-----------------------------")
end


-- search for a value
function ICDT.has_value(tab, val)
	if type(tab) == "table" then
		for index, value in pairs(tab) do
			if value == val then
				return true
			end
		end
	end
    return false
end

-- search for a index
function ICDT.has_index(tab, val)
	if type(tab) == "table" then
		for index, value in pairs(tab) do
			if index == val then
				return true
			end
		end
	end
    return false
end


------------------------

-- register and show basic dialogs
function ICDT.showDialogSimple(dialogName, dialogTitle, dialogBody, callbackYes, callbackNo)
	local dialogInfo = {
		canQueue = true,
		title = {text=dialogTitle},
		mainText = {align=TEXT_ALIGN_LEFT, text=dialogBody},
	}
	
	if callbackYes or callbackNo then
		dialogInfo.buttons = {
			{
				text = SI_DIALOG_CONFIRM,
				keybind = "DIALOG_PRIMARY",
				callback = callbackYes,
			},
			{
				text = SI_DIALOG_CANCEL,
				keybind = "DIALOG_NEGATIVE",
				callback = callbackNo,
			},
		}
	else
		-- show only one button if both callbacks are nil
		dialogInfo.buttons = {
			{
				text = SI_DIALOG_CLOSE,
				keybind = "DIALOG_NEGATIVE",
			},
		}
	end
	
	return ICDT.showDialogCustom(dialogName, dialogInfo)
end


-- register and show custom dialogs with given dialogInfo
function ICDT.showDialogCustom(dialogName, dialogInfoObject)
	local dialogInfo = dialogInfoObject
	
	-- register dialog globally
	local globalDialogName = ICDT.appName .. dialogName
	
	ESO_Dialogs[globalDialogName] = dialogInfo
	local dialogReference = ZO_Dialogs_ShowDialog(globalDialogName)
	return globalDialogName, dialogReference
end

------------------------


-- first implementation
-- because the protected function "UseItem" was hooked with "insecure" addon code, it was not longer possible to use items
-- from the inventory while in combat
-- hooking "IsItemUsable" (https://github.com/esoui/esoui/blob/aee237c37ddbfcbe714269d1685de4aff34dc321/esoui/ingame/inventory/inventoryslot.lua#L1127)
-- is close to UseItem but is also triggered when hover over inventory slots
-- The only option is to hook earlier but then we need to hook at multiple times to cover also
-- the calls when using keybind ("E") or via context menu
 
-- checks if the cooldown of the item is still active and shows dialog/warning
function ICDT.useItemPreHook(bagId, slotIndex)
	-- check if itemId is in tracked items lists
	if not bagId or not slotIndex then return false end
	local itemId = GetItemId(bagId, slotIndex)
	if not itemId then return false end
	
	local minutesLeft = ICDT.GetItemCooldown(itemId)
	if minutesLeft > 0 then
		-- cooldown is active -> show warning dialog
		local h, m = ICDT.FormatMinutes(minutesLeft)
		local body = ICDT.loc.dialogs.useItemBody1 .. " (" .. string.format(ICDT.loc.cooldownShort, h,m) .. ")\n\n" .. ICDT.colorizeText(ICDT.loc.dialogs.useItemBody2, "red")
		ICDT.showDialogSimple("UseItem", ICDT.displayedAppName, body, function() CallSecureProtected("UseItem", bagId, slotIndex) end, nil)
		
		-- stops the original "UseItem" call
		-- if necessary, the dialog will execute UseItem again
		return true
	else
		-- item is not relevant or cooldown is expired -> allow opening (let execute the original function ("UseItem"))
		return false
	end
end


-- second implementation (dialog confirming works only out of combat)
-- hooking "ZO_InventorySlot_DoPrimaryAction" covers only the item use via double click
-- to hook also keybind ("E") and context menu, we need to hook other functions too

-- checks if the cooldown of the item is still active and shows dialog/warning
function ICDT.primaryActionPreHook(inventorySlot)
	if not inventorySlot or not inventorySlot.dataEntry or not inventorySlot.dataEntry.data then return false end
	local bagId = inventorySlot.dataEntry.data.bagId
	local slotIndex = inventorySlot.dataEntry.data.slotIndex
	if not bagId or not slotIndex then return false end
	
	local itemId = GetItemId(bagId, slotIndex)
	local minutesLeft = ICDT.GetItemCooldown(itemId)
	if minutesLeft > 0 then
		-- cooldown is active -> show warning dialog
		local h, m = ICDT.FormatMinutes(minutesLeft)
		local body = ICDT.loc.dialogs.useItemBody1 .. " (" .. string.format(ICDT.loc.cooldownShort, h,m) .. ")\n\n" .. ICDT.colorizeText(ICDT.loc.dialogs.useItemBody2, "red")
		ICDT.showDialogSimple("UseItem", ICDT.displayedAppName, body, function() CallSecureProtected("UseItem", bagId, slotIndex) end, nil)
		
		-- stops the original call
		-- if necessary, the dialog will call "UseItem" (works only out of combat)
		return true
	else
		-- item is not relevant or cooldown is expired -> allow opening (let execute the original function ("UseItem"))
		return false
	end
end


-- calculates the hours and minutes combination of given total minutes
function ICDT.FormatMinutes(minutesLeft)
	if type(minutesLeft) == "number" then
		local h = math.floor(minutesLeft/60)
		local m = math.floor(minutesLeft-(h*60))
		return h, m
	else
		return 0, 0
	end
end


--[[
https://www.esoui.com/forums/showthread.php?t=6266
ZO_PreHookProtected is a rewrite of ZO_PreHook. It accepts Protected functions.
IsProtectedFunction(existingFunctionName) will still return true even if existingFunctionName is not called
Calling existingFunctionName() will work, it will call your function and depending on your code will run the prehooked function
Calling CallSecureProtected("existingFunctionName", arg1) will work, it will call the original function only. You won't be able to "fake" other addons if they're correctly written, but mainly ESOUI code.
Don't hook a non-protected function with this PreHook or game won't load
]]--
function ZO_PreHookProtected(objectTable, existingFunctionName, hookFunction)
    if(type(objectTable) == "string") then
        hookFunction = existingFunctionName
        existingFunctionName = objectTable
        objectTable = _G
    end
 
    local newFn = function(...)
        if(not hookFunction(...)) then
            if IsProtectedFunction(existingFunctionName) then
                return CallSecureProtected(existingFunctionName, ...)
            end
        end
    end
    objectTable[existingFunctionName] = newFn
end


-- hooks into tooltip update to add tracking information
function ICDT.preHookItemTooltip_OnUpdate()
	ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function()
		local control = WINDOW_MANAGER:GetMouseOverControl()
		if ICDT.tooltipActive and ICDT.tooltipCurrentControl == tostring(control) then return end
		local itemId = nil
		
		if SCENE_MANAGER:IsShowing("mailInbox") then
			-- 1. item tooltip in mail attachement
			if not control.slotIndex then return end
			local itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), control.slotIndex, LINK_STYLE_DEFAULT)
			if not itemLink then return end
			_, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
		
		elseif SCENE_MANAGER:IsShowing("interact") then
			-- 2. item tooltip in quest reward dialog
			local index = control.index
			if not index and control:GetParent() then
				index = control:GetParent().index
			end
			if not index then return end
			local itemLink = GetQuestRewardItemLink(index, LINK_STYLE_BRACKETS)
			_, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
		
		else
			-- 3. item tooltip in inventory
			if not control.dataEntry or not control.dataEntry.data then return end
			local bagId = control.dataEntry.data.bagId
			local slotIndex = control.dataEntry.data.slotIndex
			if not bagId or not slotIndex then return end
			itemId = GetItemId(bagId, slotIndex)			
		end

		if itemId then
			ICDT.tooltipActive = true
			ICDT.tooltipCurrentControl = tostring(control)
			local minutesLeft = ICDT.GetItemCooldown(tonumber(itemId))
			if minutesLeft > 0 then
				-- item is relevant and cooldown is still active
				local h, m = ICDT.FormatMinutes(minutesLeft)
				local textToAdd = ICDT.colorizeText(ICDT.loc.cooldownActive, "red") .. "\n" .. string.format(ICDT.loc.cooldownShort, h,m)
				ItemTooltip:AddLine(" ")
				ZO_Tooltip_AddDivider(ItemTooltip)
				ItemTooltip:AddLine(ICDT.displayedAppName .. ":\n" .. textToAdd, "", 1,1,1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			elseif minutesLeft == 0 then
				-- item is relevant but cooldown is expired
				local textToAdd = ICDT.colorizeText(ICDT.loc.cooldownExpired, "green")
				ItemTooltip:AddLine(" ")
				ZO_Tooltip_AddDivider(ItemTooltip)
				ItemTooltip:AddLine(ICDT.displayedAppName .. ":\n" .. textToAdd, "", 1,1,1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			end
		end
	end)
end


function ICDT.preHookItemTooltip_OnHide()
	ZO_PreHookHandler(ItemTooltip, 'OnHide', function()
		ICDT.tooltipActive = false
	end)
end



------- API functions of FCO Item Saver integration -------

-- returns a table containing all itemIds (containers) that are potential relevant for the prevention of opening (independet from user setting)
function ICDT.GetRelevantItemIds()
	local resultTable = {}
	for key, data in pairs(ICDT.trackableItemList) do
		if data and data.containers then
			ICDT.tableMerge(resultTable, data.containers)
		end
	end
	return resultTable
end


--[[
for given itemId, returns
-1  		--> item is not relevant (not trackable with addon)
0   		--> item is tracked by current setting, but cooldown is expired
number>0  	--> cooldown is active, minutes left
--]]
function ICDT.GetItemCooldown(itemId)
	local tracked, key = ICDT.findTrackedItemKeyContainer(itemId)
	if tracked then
		-- check if cooldown is active
		local isCooldownActive, minutesLeft = ICDT.isCooldownActive(key)
		if isCooldownActive then
			return minutesLeft
		else
			-- cooldown is expired
			return 0
		end
	else
		-- item is not relevant
		return -1
	end
	return false
end





-- START HERE
EVENT_MANAGER:RegisterForEvent(ICDT.appName, EVENT_ADD_ON_LOADED, onAddonLoaded)
