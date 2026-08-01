if not EHT then EHT = { } end
if not EHT.Biz then EHT.Biz = { } end
if not EHT.CT then EHT.CT = { } end
if not EHT.Data then EHT.Data = { } end
if not EHT.Handlers then EHT.Handlers = { } end
if not EHT.Housing then EHT.Housing = { } end
if not EHT.Interop then EHT.Interop = { } end
if not EHT.Setup then EHT.Setup = { } end
if not EHT.UI then EHT.UI = { } end
if not EHT.Util then EHT.Util = { } end

EHT.ADDON_VERSION = "1776"
EHT.ADDON_AUTHOR = "@Cardinal05, @Architectura"
EHT.ADDON_NAME = "EssentialHousingTools"
EHT.ADDON_TITLE = "Essential Housing Tools"
EHT.ADDON_TITLE_LONG = EHT.ADDON_TITLE .. " (v " .. EHT.ADDON_VERSION .. ")"
EHT.ADDON_HELP_URL = "https://www.youtube.com/watch\?v\=HsKZfBCB7wM\&list\=PLxkqemlv6asjxpAtzBLt4bPfV4H4jUtn4"
EHT.ADDON_INDEX = nil
EHT.ADDON_FOLDER = nil

EHT.IsDev = "@cardinal05" == string.lower(GetDisplayName()) or "@architectura" == string.lower(GetDisplayName())
EHT.IsMac = false

EHT.GetPlayerPosition = GetUnitRawWorldPosition

---[ Debug ]---

EHT.D = function() end
EHT.DEBUG_MODE = false

if EHT.IsDev then
	SLASH_COMMANDS["/ehtdebug"] = function()
		EHT.DEBUG_MODE = not EHT.DEBUG_MODE
		if EHT.DEBUG_MODE then
			EHT.D = df
		else
			EHT.D = function() end
		end
		df("Debug mode is now %s", EHT.DEBUG_MODE and "ON" or "OFF")
	end
end

local function CloneTable(obj)
	if "table" ~= type(obj) then
		return obj
	end
	local tbl = {}
	for k, v in pairs(obj) do
		tbl["table" ~= type(k) and k or CloneTable(k)] = "table" ~= type(v) and v or CloneTable(v)
	end
	return tbl
end
EHT.Util.CloneTable = CloneTable

if false then
	EHT.EventManagerRegisterForUpdate = EVENT_MANAGER.RegisterForUpdate
	EHT.EventManagerUnregisterForUpdate = EVENT_MANAGER.UnregisterForUpdate
	EHT.EventManagerUpdateRegistrations = {}
	EHT.OutputEventManagerEvents = false

	local function EHTRegisterForUpdate(eventManager, key, intervalMS, callback)
		if "string" ~= type(key) then
			return
		end

		local registeredCallback = EHT.EventManagerUpdateRegistrations[key]
		if registeredCallback then
			return
		end

		registeredCallback =
		{
			numCallbacks = 0,
			runtimeMS = 0,
			startMS = GetGameTimeMilliseconds(),
		}
		EHT.EventManagerUpdateRegistrations[key] = registeredCallback

		registeredCallback.callback = function(...)
			local startMS = GetGameTimeMilliseconds()
			callback(...)
			local runtimeMS = GetGameTimeMilliseconds() - startMS

			registeredCallback.numCallbacks = registeredCallback.numCallbacks + 1
			registeredCallback.runtimeMS = registeredCallback.runtimeMS + runtimeMS

			if EHT.OutputEventManagerEvents then
				local gt = GetGameTimeMilliseconds()
				local runtimeS = registeredCallback.runtimeMS / 1000
				local totalS = ( gt - registeredCallback.startMS ) / 1000
				local totalPercent = 100 * runtimeS / totalS
				df( "[%.2f, #%d] %.2fs of %.2fs (%.2f%%) total : %s", gt / 1000, registeredCallback.numCallbacks, runtimeS, totalS, totalPercent, key or "(anonymous)" )
			end
		end

		EHT.EventManagerRegisterForUpdate( eventManager, key, intervalMS, registeredCallback.callback )
	end

	local function EHTUnregisterForUpdate( eventManager, key )
		if "string" ~= type( key ) then
			return
		end

		local registeredCallback = EHT.EventManagerUpdateRegistrations[ key ]
		if not registeredCallback then
			return
		end

		EHT.EventManagerUpdateRegistrations[ key ] = nil
		EHT.EventManagerUnregisterForUpdate( eventManager, key )
	end

	EVENT_MANAGER.RegisterForUpdate = EHTRegisterForUpdate
	EVENT_MANAGER.UnregisterForUpdate = EHTUnregisterForUpdate

	EVENT_MANAGER:RegisterForEvent( "EHT.EventManager.PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent( "EHT.EventManager.PlayerActivated", EVENT_PLAYER_ACTIVATED )
		SLASH_COMMANDS[ "/toggleevents" ] = function()
			EHT.OutputEventManagerEvents = not EHT.OutputEventManagerEvents
			df( "Event output %s", EHT.OutputEventManagerEvents and "enabled" or "disabled" )
		end
	end )
end

---[ Stack Timestamps ]---

do
	local tsStack = { }
	local tsResults = { }

	function EHT.PushTS( label )
		table.insert( tsStack, { label, GetGameTimeMilliseconds() } )
	end

	function EHT.PopTS( label )
		local ts = GetGameTimeMilliseconds()
		local item = table.remove( tsStack, #tsStack )

		if 1 == 0 and item and EHT.IsDev then
			local s

			if label ~= item[1] then
				s = string.format( "Out-of-order 'pop' operation: %s", label )

				if tsResults then
					table.insert( tsResults, s )
				else
					d( s )
				end
			end

			s = string.format( "|cffffff[%.5f] |cffff00%.5f |c00ffff%s", item[2] / 1000, ( ts - item[2] ) / 1000, item[1] )

			if tsResults then
				table.insert( tsResults, s )
			else
				d( s )
			end
		end
	end

	function EHT.DumpTS()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.DumpTS" )

		if tsResults and 0 < #tsResults then
			d( table.concat( tsResults, "\n" ) )
			tsResults = nil
		end
	end
end

EHT.PushTS( "Initial Compilation" )

EHT.CONST = { }
EHT.CONST.UI = { }

EHT.INVALID_PATH_NODE = 4294967296

EHT.CONST.URLS =
{
	DownloadCommunityMac = "https://essentialhousingcommunity.azurewebsites.net/mac/",
	DownloadDecoTrack = "https://www.esoui.com/downloads/info2100-DecoTrack.html",
	SetupCommunityPC = "https://youtu.be/hJJdbJB8HVM",
	SetupCommunityMac = "https://www.youtube.com/watch?v=HM03EzlVyY4",
	SetupOpenHouse = "https://www.youtube.com/watch?v=1WveCn7E0ZY",
}

if not EHT.ADDON_FOLDER then EHT.ADDON_FOLDER = "/EssentialHousingTools/" end

EHT.PATH_TEXTURES = EHT.ADDON_FOLDER .. "media/%s.dds"
EHT.PATH_TEXTURES_CUSTOM = EHT.ADDON_FOLDER .. "media/custom/%s%s.dds"
EHT.PATH_TEXTURES_HUB = EHT.ADDON_FOLDER .. "HousingHub/media/%s.dds"

EHT.UI_TEXTURES =
{
	GLASS_FROSTED = string.format(EHT.PATH_TEXTURES_HUB, "glass_frosted"),
}

EHT.PROCESS_NAME = { }
EHT.PROCESS_NAME.ADD_FROM_INVENTORY = "Placing from inventory"
EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP = "Updating furniture"
EHT.PROCESS_NAME.BUILD = "Building"
EHT.PROCESS_NAME.CHANGE_FURNITURE_STATE = "Changing furniture state"
EHT.PROCESS_NAME.CUT_GROUP_TO_INVENTORY = "Removing to clipboard"
EHT.PROCESS_NAME.MEASURE_DIMENSIONS = "Measuring furniture dimensions"
EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_INVENTORY = "Pasting from clipboard"
EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_HOUSE = "Pasting layout to house items"
EHT.PROCESS_NAME.PLAY_SCENE = "Playing animation"
EHT.PROCESS_NAME.REDO = "Redoing changes"
EHT.PROCESS_NAME.REPLACE_MISSING_ITEMS = "Replacing missing furniture"
EHT.PROCESS_NAME.UNDO = "Undoing changes"
EHT.PROCESS_NAME.RESET_FURNITURE = "Resetting furniture"
EHT.PROCESS_NAME.LINK_GROUP = "Linking selected furniture together"
EHT.PROCESS_NAME.UNLINK_GROUP = "Unlinking selected furniture"
EHT.PROCESS_NAME.SUMMON_KIOSK = "Summoning kiosk"
EHT.PROCESS_NAME.DISMISS_KIOSK = "Dismissing kiosk"
EHT.PROCESS_NAME.UPDATE_PERMISSIONS = "Updating house permissions"

EHT.CONST.ADJUST_FX_SETTINGS =
{
	"Always",
	"Ask Me",
	"Never",
}
EHT.CONST.ADJUST_FX_SETTINGS_VALUES =
{
	["Always"] = 1,
	["Ask Me"] = 2,
	["Never"] = 3,
}

EHT.CONST.MOVE_OP = 1
EHT.CONST.PLACE_OP = 2
EHT.CONST.REMOVE_OP = 3
EHT.CONST.MOVE_PATH_NODE_OP = 4
EHT.CONST.PLACE_PATH_NODE_OP = 5
EHT.CONST.REMOVE_PATH_NODE_OP = 6

EHT.INVENTORY_KEYBIND_BUTTONS = {
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
	{
		name = "Place All Furniture",
		keybind = "EHT_PLACE_ALL_FURNITURE",
		callback = function()
			EHT.UI.ShowConfirmationDialog("", "|cffffffPlace and select |c00ffffall furniture items|cffffff from your inventory?|r", function()
				EHT.Biz.AddAllItemsFromInventory(BAG_BACKPACK, true)
			end)
		end,
		visible = function()
			return "inventory" == EHT.UI.GetCurrentSceneName() and EHT.Biz.CanPlaceAllItems()
		end,
	},
}

EHT.KEYBIND_BUTTONS = { }
EHT.KEYBIND_BUTTONS.PRIMARY = {
	name = function()
		local mode = GetHousingEditorMode()

		if mode == HOUSING_EDITOR_MODE_PLACEMENT then
			local stackCount = HousingEditorGetSelectedFurnitureStackCount()

			if stackCount <= 1 then
				return GetString( SI_HOUSING_EDITOR_PLACE )
			else
				return zo_strformat( SI_HOUSING_EDITOR_PLACE_WITH_STACK_COUNT, stackCount )
			end
		elseif mode == HOUSING_EDITOR_MODE_SELECTION then
			return GetString( SI_HOUSING_EDITOR_SELECT )
		end
	end,
	keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
	callback = function()
		local mode = GetHousingEditorMode()

		if mode == HOUSING_EDITOR_MODE_SELECTION then
			local result = EHT.UI.SteadySelectTargettedFurniture()

			ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, result)

			if result == HOUSING_REQUEST_RESULT_SUCCESS then
				PlaySound( SOUNDS.HOUSING_EDITOR_PICKUP_ITEM )
				return true
			end
		elseif mode == HOUSING_EDITOR_MODE_PLACEMENT then
			EHT.UI.BeginSteadyCam()
			local result = HousingEditorRequestSelectedPlacement()

			ZO_AlertEvent( EVENT_HOUSING_EDITOR_REQUEST_RESULT, result )

			if result == HOUSING_REQUEST_RESULT_SUCCESS then
				PlaySound( SOUNDS.HOUSING_EDITOR_PLACE_ITEM )
			end

			HOUSING_EDITOR_SHARED:ClearPlacementKeyPresses()
			return true
		end

		return false
	end,
	order = 10,
}
EHT.KEYBIND_BUTTONS.CHOOSE_TARGET = {
	name = "Choose Target Item",
	keybind = "HOUSING_EDITOR_PRIMARY_ACTION",
	callback = function() EHT.UI.ChooseAnItemCallback() end,
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}
EHT.KEYBIND_BUTTONS.UNDO = {
	name = "Undo",
	keybind = "EHT_UNDO",
	callback = function() EHT.UI.Undo() end,
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}
EHT.KEYBIND_BUTTONS.REDO = {
	name = "Redo",
	keybind = "EHT_REDO",
	callback = function() EHT.UI.Redo() end,
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}
EHT.KEYBIND_BUTTONS.QUICK_ACTIONS = {
	name = "|c55ffffOrganize|r",
	keybind = "EHT_QUICK_ACTIONS",
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
}
EHT.KEYBIND_BUTTONS.POSITION = {
	name = "Position",
	keybind = "EHT_EDIT_POSITION",
	callback = function() EHT.UI.ShowPositionDialog() end,
	alignment = KEYBIND_STRIP_ALIGN_RIGHT
}
EHT.KEYBIND_BUTTONS.SELECT = {
	name = "Group Select",
	keybind = "EHT_SELECT_DESELECT",
	callback = function() EHT.UI.GroupUngroupFurniture() end,
	alignment = KEYBIND_STRIP_ALIGN_RIGHT
}
EHT.KEYBIND_BUTTONS.DESELECT = {
	name = "Group Deselect",
	keybind = "EHT_SELECT_DESELECT",
	callback = function() EHT.UI.GroupUngroupFurniture() end,
	alignment = KEYBIND_STRIP_ALIGN_RIGHT
}
EHT.KEYBIND_BUTTONS.SNAP_FURNITURE = {
	name = "Snap Together",
	keybind = "EHT_SNAP_FURNITURE",
	callback = function() EHT.UI.SnapFurniture() end,
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}

EHT.EASYSLIDE_KEYBIND_BUTTONS = { }
EHT.EASYSLIDE_KEYBIND_BUTTONS.EDITOR_LOCK_AXIS = {
	name = "Lock Axis (Hold)",
	keybind = "EHT_EDITOR_LOCK_AXIS",
	alignment = KEYBIND_STRIP_ALIGN_RIGHT
}
EHT.EASYSLIDE_KEYBIND_BUTTONS.EDITOR_EXIT = {
	name = "Cancel",
	keybind = "EHT_EDITOR_EXIT",
	alignment = KEYBIND_STRIP_ALIGN_RIGHT
}

EHT.GUESTBOOK_KEYBIND_BUTTONS = { }
EHT.GUESTBOOK_KEYBIND_BUTTONS.SHOW = {
	name = "Show Guest Journal",
	--keybind = "UI_SHORTCUT_PRIMARY",
	keybind = "EHT_SHOW_GUEST_JOURNAL",
	callback = function() EHT.UI.ShowGuestbook() end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER
}
EHT.GUESTBOOK_KEYBIND_BUTTONS.SIGN = {
	name = "Sign Journal",
	keybind = "UI_SHORTCUT_PRIMARY",
	callback = function() EHT.UI.SignGuestbook() end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER
}
EHT.GUESTBOOK_KEYBIND_BUTTONS.DISMISS = {
	name = "Dismiss Until Next Visit",
	keybind = "UI_SHORTCUT_NEGATIVE",
	callback = function() EHT.UI.DismissGuestbook() end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER
}
EHT.GUESTBOOK_KEYBIND_BUTTONS.RESET = {
	name = "|cff0000Wipe All Signatures|r",
	keybind = "UI_SHORTCUT_TERTIARY",
	callback = function() EHT.UI.ResetGuestbook() end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER
}

EHT.STATE = { }
EHT.STATE.TOGGLE = "Toggled"
EHT.STATE.ON = "On"
EHT.STATE.ON2 = "On (2nd State)"
EHT.STATE.ON3 = "On (3rd State)"
EHT.STATE.ON4 = "On (4th State)"
EHT.STATE.ON5 = "On (5th State)"
EHT.STATE.OFF = "Off"
EHT.STATE.RESTORE = "Restored"

EHT.TASK_TYPE = { }
EHT.TASK_TYPE.SET_GROUP_STATE = "GS"
EHT.TASK_TYPE.PLAY_SCENE = "PS"
EHT.TASK_TYPE.ACTIVATE_TRIGGER = "AT"

EHT.STATE_CHECK_ID = EHT.ADDON_NAME .. "StateCheck"
EHT.STATE_CHECK_INTERVAL = 1

EHT.TRIGGER_QUEUE_ID = EHT.ADDON_NAME .. "TriggerQueue"
EHT.TRIGGER_CHECK_ID = EHT.ADDON_NAME .. "TriggerCheck"
EHT.TRIGGER_CHECK_INTERVAL = 350
EHT.TRIGGER_CHECK_INTERVAL_INCREASE_PER_TRIGGER = 3

EHT.TRIGGER_CHECK_RADIUS_ID = EHT.ADDON_NAME .. "TriggerRadiusCheck"
EHT.TRIGGER_CHECK_RADIUS_INTERVAL = 250

EHT.TRIGGER_QUEUE_MAX_ITEMS = 100

EHT.CONST.MAX_COMMUNITY_LOCAL_SERVER_TIMESTAMP_DELTA = 60 * 60 * 24
EHT.CONST.MAX_FAV_HOUSES = 100
EHT.CONST.MAX_GUILD_NOTE_LENGTH = 254
EHT.CONST.MAX_RECENT_SOUNDS = 5
EHT.CONST.MAX_RECENTLY_VISITED = 40
EHT.CONST.MAX_CLIPBOARD_LENGTH = 28000
EHT.CONST.MAX_TRENDING_HOUSES = 10
EHT.CONST.DEFAULT_OPEN_HOUSE_PERIOD_DAYS = 3650

EHT.CONST.EFFECT_GROUP_ID_MIN = 99990001
EHT.CONST.EFFECT_GROUP_ID_MAX = 99990032

EHT.CONST.KIOSK_ITEMS = {
	{ Type = "storage", CollectibleId = 4678, Name = "Storage Chest, Oaken", X = 202, Y = 90, Z = 103, },
	{ Type = "storage", CollectibleId = 4680, Name = "Storage Chest, Sturdy", X = 202, Y = 90, Z = 103, },
	{ Type = "storage", CollectibleId = 4679, Name = "Storage Chest, Secure", X = 202, Y = 90, Z = 103, },
	{ Type = "storage", CollectibleId = 4674, Name = "Storage Chest, Fortified", X = 202, Y = 90, Z = 103, },

	{ Type = "storage", CollectibleId = 4675, Name = "Storage Coffer, Oaken", X = 126, Y = 66, Z = 95, },
	{ Type = "storage", CollectibleId = 4677, Name = "Storage Coffer, Sturdy", X = 126, Y = 66, Z = 95, },
	{ Type = "storage", CollectibleId = 4676, Name = "Storage Coffer, Secure", X = 126, Y = 66, Z = 95, },
	{ Type = "storage", CollectibleId = 4673, Name = "Storage Coffer, Fortified", X = 126, Y = 66, Z = 95, },

	{ Type = "assistant", CollectibleId = 267, Name = "Tythis Andromo, the Banker", X = 68, Y = 237, Z = 40, },
	{ Type = "assistant", CollectibleId = 301, Name = "Nuzhimeh the Merchant", X = 88, Y = 237, Z = 40, },
	{ Type = "assistant", CollectibleId = 300, Name = "Pirharri the Smuggler", X = 60, Y = 130, Z = 76, },
	{ Type = "assistant", CollectibleId = 6376, Name = "Ezabi the Banker", X = 68, Y = 237, Z = 40, },
	{ Type = "assistant", CollectibleId = 6378, Name = "Fezez the Merchant", X = 68, Y = 237, Z = 40, },

	{ Type = "craft", Link = "|H1:item:118328:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Alchemy Station",			RadiusOffset = 0,	YOffset = 0,	},
	{ Type = "craft", Link = "|H1:item:119781:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Blacksmithing Station",		RadiusOffset = 0,	YOffset = 0,	},
	{ Type = "craft", Link = "|H1:item:119707:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Clothing Station",			RadiusOffset = 0,	YOffset = 0,	FlipY = true, },
	{ Type = "craft", Link = "|H1:item:118330:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Enchanting Station",		RadiusOffset = 0,	YOffset = 0,	},
	{ Type = "craft", Link = "|H1:item:137870:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Jewelry Crafting Station",	RadiusOffset = 0,	YOffset = 0,	FlipY = true, },
	{ Type = "craft", Link = "|H1:item:118327:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Provisioning Station",		RadiusOffset = 0,	YOffset = -3,	},
	{ Type = "craft", Link = "|H1:item:133576:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Transmute Station",			RadiusOffset = 20,	YOffset = 0,	FlipY = true, },
	{ Type = "craft", Link = "|H1:item:119744:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", Name = "Woodworking Station",		RadiusOffset = 0,	YOffset = 0,	FlipY = true, },
}

EHT.CONST.AXIS = { }
EHT.CONST.AXIS.X = "X"
EHT.CONST.AXIS.Y = "Y"
EHT.CONST.AXIS.Z = "Z"

EHT.CONST.DIALOG_ALERT = "EHTAlert"
EHT.CONST.DIALOG_CONFIRM = "EHTConfirm"
EHT.CONST.DIALOG_CUSTOM = "EHTCustom"

EHT.CONST.DIALOG = { }
EHT.CONST.DIALOG.BACKUPS = "EHTBackups"
EHT.CONST.DIALOG.CLIPBOARD = "EHTClipboard"
EHT.CONST.DIALOG.CLONE_SCENE = "EHTCloneScene"
EHT.CONST.DIALOG.COPY_FROM_SELECTION = "EHTCopyFromSelection"
EHT.CONST.DIALOG.EFFECTS_PREVIEW = "EHTEffectsPreview"
EHT.CONST.DIALOG.FXMENU = "EHTEffectsButtonContextMenu"
EHT.CONST.DIALOG.GUILDCAST = "EHTGuildcast"
EHT.CONST.DIALOG.IMPORT_CLIPBOARD = "EHTImportClipboard"
EHT.CONST.DIALOG.EXPORT_CLIPBOARD = "EHTExportClipboard"
EHT.CONST.DIALOG.ITEM_INFO = "EHTItemInfo"
EHT.CONST.DIALOG.INTERACTION_PROMPT = "InteractionPromptDialog"
EHT.CONST.DIALOG.MANAGE_BUILDS = "EHTManageBuilds"
EHT.CONST.DIALOG.MANAGE_SELECTIONS = "EHTManageSelections"
EHT.CONST.DIALOG.POSITION = "EHTPosition"
EHT.CONST.DIALOG.TOOL = "EHTTool"
EHT.CONST.DIALOG.TRIGGERQUEUE = "EHTTriggerQueue"
EHT.CONST.DIALOG.SNAP_FURNITURE = "EHTSnapFurniture"
EHT.CONST.DIALOG.EDIT_FURNITURE = "EHTEditFurniture"
EHT.CONST.DIALOG.TUTORIAL = "EHTTutorial"
EHT.CONST.DIALOG.PROTRACTED_SELECTION = "EHTProtractedSelection"
EHT.CONST.DIALOG.REPORT = "EHTReport"

EHT.CONST.COLORS = { }
EHT.CONST.COLORS.NORMAL = "|r"
EHT.CONST.COLORS.HIGHLIGHT = "|cccccff"

EHT.CONST.UI.TOOL_DIALOG = { }
EHT.CONST.UI.TOOL_DIALOG.MINIMIZED_HEIGHT = 45
EHT.CONST.UI.TOOL_DIALOG.MIN_HEIGHT = 675
EHT.CONST.UI.TOOL_DIALOG.MAX_HEIGHT = 1000
EHT.CONST.UI.TOOL_DIALOG.MIN_WIDTH = 420
EHT.CONST.UI.TOOL_DIALOG.MAX_WIDTH = 420

EHT.CONST.UI.MAX_FADE_GRADIENT_SIZE = 40

EHT.CONST.GROUP_DEFAULT = "new selection"
EHT.CONST.GROUP_NAME_MAX_LEN = 40
EHT.CONST.PROTRACTED_GROUP_DIMENSION_MIN = 2500

EHT.CONST.BUILD_DISTANCE_WARNING = 3000

EHT.CONST.FX_REQUEST_DELAY = 50
EHT.CONST.HOUSING_REQUEST_DELAY_MIN = 110
EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN = 600
EHT.CONST.HOUSING_STATE_REQUEST_DELAY_PER_ITEM = 5000
EHT.CONST.HOUSING_PLACE_DELAY = 500
EHT.CONST.HOUSING_REMOVE_DELAY = 500
EHT.CONST.HOUSING_REQUEST_MAX_DEFERRED_DELAY = 1000
EHT.CONST.HOUSING_LINK_DELAY = 500
EHT.CONST.HOUSING_UNLINK_DELAY = 500
EHT.CONST.BUILD_START_DELAY = 100
EHT.CONST.DRAG_ITEMS_DELAY = 80
EHT.CONST.OPEN_HOUSE_PERMISSIONS_ALERT_DELAY = 60 * 60 * 12

EHT.CONST.MIN_HOUSE_HISTORY = 10
EHT.CONST.MAX_HOUSE_HISTORY = 100
EHT.CONST.MAX_HOUSE_BACKUPS = 5
EHT.CONST.MAX_HOUSE_PRE_RESTORE_BACKUP_AGE = 600

EHT.CONST.MIN_SELECTION_INDICATOR_ALPHA = 0.25
EHT.CONST.MIN_SELECTION_BOX_ALPHA = 0.25
EHT.CONST.MIN_GRID_ALPHA = 0.3
EHT.CONST.MIN_GRID_RADIUS = 4
EHT.CONST.MAX_GRID_RADIUS = 20
EHT.CONST.MIN_GRID_UNITS = 50
EHT.CONST.MAX_GRID_UNITS = 500

EHT.CONST.BAG_IDS = {
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
}

EHT.CONST.ITEM_TEMPLATES = {
	--[[ Armor / Jewelry ]]

	[18] =
	{
		-- Necklace
		armorType = 0,
		equipType = 2,
	},
	[24] =
	{
		-- Ring
		armorType = 0,
		equipType = 12,
	},

	--[[ Armor / Light ]]

	[26] =
	{
		-- Head / Light
		armorType = 1,
		equipType = 1,
	},
	[27] =
	{
		-- Neck / Light
		armorType = 1,
		equipType = 2,
	},
	[28] =
	{
		-- Chest / Light
		armorType = 1,
		equipType = 3,
	},
	[29] =
	{
		-- Shoulder / Light
		armorType = 1,
		equipType = 4,
	},
	[30] =
	{
		-- Waist / Light
		armorType = 1,
		equipType = 8,
	},
	[31] =
	{
		-- Legs / Light
		armorType = 1,
		equipType = 9,
	},
	[32] =
	{
		-- Feet / Light
		armorType = 1,
		equipType = 10,
	},
	[33] =
	{
		-- Ring / Light
		armorType = 1,
		equipType = 12,
	},
	[34] =
	{
		-- Hand / Light
		armorType = 1,
		equipType = 13,
	},

	--[[ Armor / Medium ]]

	[35] =
	{
		-- Head / Medium
		armorType = 2,
		equipType = 1,
	},
	[36] =
	{
		-- Neck / Medium
		armorType = 2,
		equipType = 2,
	},
	[37] =
	{
		-- Chest / Medium
		armorType = 2,
		equipType = 3,
	},
	[38] =
	{
		-- Shoulder / Medium
		armorType = 2,
		equipType = 4,
	},
	[39] =
	{
		-- Waist / Medium
		armorType = 2,
		equipType = 8,
	},
	[40] =
	{
		-- Legs / Medium
		armorType = 2,
		equipType = 9,
	},
	[41] =
	{
		-- Feet / Medium
		armorType = 2,
		equipType = 10,
	},
	[42] =
	{
		-- Ring / Medium
		armorType = 2,
		equipType = 12,
	},
	[43] =
	{
		-- Hand / Medium
		armorType = 2,
		equipType = 13,
	},

	--[[ Armor / Heavy ]]

	[44] =
	{
		-- Head / Heavy
		armorType = 3,
		equipType = 1,
	},
	[45] =
	{
		-- Neck / Heavy
		armorType = 3,
		equipType = 2,
	},
	[46] =
	{
		-- Chest / Heavy
		armorType = 3,
		equipType = 3,
	},
	[47] =
	{
		-- Shoulder / Heavy
		armorType = 3,
		equipType = 4,
	},
	[48] =
	{
		-- Waist / Heavy
		armorType = 3,
		equipType = 8,
	},
	[49] =
	{
		-- Legs / Heavy
		armorType = 3,
		equipType = 9,
	},
	[50] =
	{
		-- Feet / Heavy
		armorType = 3,
		equipType = 10,
	},
	[51] =
	{
		-- Ring / Heavy
		armorType = 3,
		equipType = 12,
	},
	[52] =
	{
		-- Hand / Heavy
		armorType = 3,
		equipType = 13,
	},

	--[[ Weapon ]]

	[53] =
	{
		-- Axe / 1-Handed
		weaponType = 1,
	},
	[56] =
	{
		-- Mace / 1-Handed
		weaponType = 2,
	},
	[59] =
	{
		-- Sword / 1-Handed
		weaponType = 3,
	},
	[62] =
	{
		-- Dagger
		weaponType = 11,
	},
	[65] =
	{
		-- Shield
		weaponType = 14,
	},
	[67] =
	{
		-- Sword / 2-Handed
		weaponType = 4,
	},
	[68] =
	{
		-- Axe / 2-Handed
		weaponType = 5,
	},
	[69] =
	{
		-- Mace / 2-Handed
		weaponType = 6,
	},
	[70] =
	{
		-- Bow
		weaponType = 8,
	},
	[71] =
	{
		-- Staff / Restoration
		weaponType = 9,
	},
	[72] =
	{
		-- Staff / Fire
		weaponType = 12,
	},
	[73] =
	{
		-- Staff / Ice
		weaponType = 13,
	},
	[74] =
	{
		-- Staff / Lightning
		weaponType = 15,
	},
}

EHT.CONST.LIMIT_TYPES = { }
EHT.CONST.LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE ] = "Special Collectibles"
EHT.CONST.LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM ] = "Special Furnishings"
EHT.CONST.LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE ] = "Collectible Furnishings"
EHT.CONST.LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM ] = "Traditional Furnishings"


EHT.CONST.CHANGE_TYPE = { }
EHT.CONST.CHANGE_TYPE.PLACE = "P"
EHT.CONST.CHANGE_TYPE.REMOVE = "R"
EHT.CONST.CHANGE_TYPE.CHANGE = "C"

EHT.CONST.BUILD_TEMPLATE = { }
EHT.CONST.BUILD_TEMPLATE.BRIDGE = "Bridge"
EHT.CONST.BUILD_TEMPLATE.CIRCLE = "Circle"
EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS = "Crafting Stations (Pods)"
EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_ROWS = "Crafting Stations (Rows)"
EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_COLS = "Crafting Stations (Columns)"
EHT.CONST.BUILD_TEMPLATE.CUBE = "Cube"
EHT.CONST.BUILD_TEMPLATE.CYLINDER = "Cylinder"
EHT.CONST.BUILD_TEMPLATE.CONE = "Cone"
EHT.CONST.BUILD_TEMPLATE.DISC = "Disc"
EHT.CONST.BUILD_TEMPLATE.DOME = "Dome"
EHT.CONST.BUILD_TEMPLATE.FLOOR = "Floor"
EHT.CONST.BUILD_TEMPLATE.PYRAMID = "Pyramid"
EHT.CONST.BUILD_TEMPLATE.RECTANGLE = "Rectangle "  -- Trailing space is deliberate.
EHT.CONST.BUILD_TEMPLATE.RECTANGLE_OUTLINE = "Rectangle (Outline)"
EHT.CONST.BUILD_TEMPLATE.SCATTER_POSITION = "Scatter (Position)"
EHT.CONST.BUILD_TEMPLATE.SCATTER_ORIENTATION = "Scatter (Orientation)"
EHT.CONST.BUILD_TEMPLATE.SPHERE = "Sphere"
EHT.CONST.BUILD_TEMPLATE.SPIRAL = "Spiral"
EHT.CONST.BUILD_TEMPLATE.STAIRS = "Stairs"
EHT.CONST.BUILD_TEMPLATE.TEXT = "Text"
EHT.CONST.BUILD_TEMPLATE.WALL = "Wall"
EHT.CONST.BUILD_TEMPLATE.WAVE = "Wave"

EHT.CONST.BUILD_TEMPLATE_DEFAULT = EHT.CONST.BUILD_TEMPLATE.CIRCLE

EHT.CONST.BUILD_TEMPLATE_DEFAULT_VALUES = {
	TemplateName = EHT.CONST.BUILD_TEMPLATE_DEFAULT,
	SelectionChanged = false,
	ArcLength = 360,
	Radius = 300,
	Circumference = 10
}

EHT.CONST.ALL_BUILD_TEMPLATE_CONTROLS = {
	"ShapeDimensionsHeading",

	"ItemCount",
	"EllipseParam",
	"Radius",
	"RadiusX",
	"RadiusY",
	"RadiusZ",
	"RadiusStart",
	"RadiusEnd",
	"ArcLength",
	"Length",
	"Width",
	"Height",
	"CheckerPattern",
	"ReverseSort",
	"Message",
	"CharacterSpacing",
	"LineSpacing",

	"ItemOrientationHeading",

	"ItemPitch",
	"ItemYaw",
	"ItemRoll",

	"ItemSpacingHeading",

	"ItemSpacingAuto",
	"Circumference",
	"ItemSpacingLength",
	"ItemSpacingWidth",
	"ItemSpacingHeight",

	"ItemDimensionsHeading",

	"ItemLength",
	"ItemWidth",
	"ItemHeight",

	"ShapeOrientationHeading",

	"Pitch",
	"Yaw",
	"Roll",

	"ShapePositionHeading",

	"X",
	"Y",
	"Z",
}

EHT.CONST.GLOBAL_BUILD_TEMPLATE_CONTROLS = {
	"ItemCount",

	"ItemPitch",
	"ItemYaw",
	"ItemRoll",

	"ItemSpacingLength",
	"ItemSpacingWidth",
	"ItemSpacingHeight",

	"ItemLength",
	"ItemWidth",
	"ItemHeight",

	"Pitch",
	"Yaw",
	"Roll",

	"X",
	"Y",
	"Z",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS = { }

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.BRIDGE ] = {
	"RadiusY",
	"RadiusZ",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CIRCLE ] = {
	"ArcLength",
	"EllipseParam",
	"Radius",
	"RadiusX",
	"RadiusZ",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_PODS ] = {
	"ReverseSort",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_ROWS ] = {
	"ReverseSort",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CRAFTING_STATIONS_COLS ] = {
	"ReverseSort",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CUBE ] = {
	"Height",
	"Length",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CYLINDER ] = {
	"ArcLength",
	"CheckerPattern",
	"Radius",
	"Circumference",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.CONE ] = {
	"RadiusStart",
	"RadiusEnd",
	"Height",
	"Circumference",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.DISC ] = {
	"ArcLength",
	"CheckerPattern",
	"Radius",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.DOME ] = {
	"ArcLength",
	"Radius",
	"CheckerPattern",
	"Circumference",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.FLOOR ] = {
	"Length",
	"Width",
	"CheckerPattern",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.PYRAMID ] = {
	"Height",
	"Length",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.RECTANGLE ] = {
	"Length",
	"Width",
	"CheckerPattern",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.RECTANGLE_OUTLINE ] = {
	"Length",
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.SPHERE ] = {
	"ArcLength",
	"Radius",
	"CheckerPattern",
	"Circumference",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.SPIRAL ] = {
	"RadiusStart",
	"RadiusEnd",
	"Circumference",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.STAIRS ] = {
	"Width",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.TEXT ] = {
	"Message",
	"CharacterSpacing",
	"LineSpacing",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.WALL ] = {
	"Length",
	"Height",
	"CheckerPattern",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.WAVE ] = {
	"EllipseParam",
	"Radius",
	"RadiusX",
	"RadiusZ",
	"Circumference",
	"ItemSpacingAuto",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.SCATTER_POSITION ] = {
	"RadiusX",
	"RadiusY",
	"RadiusZ",
}

EHT.CONST.BUILD_TEMPLATE_CONTROLS[ EHT.CONST.BUILD_TEMPLATE.SCATTER_ORIENTATION ] = {
}


EHT.CONST.SCENE_DEFAULT = "new scene"
EHT.CONST.SCENE_NAME_MAX_LEN = 40
EHT.CONST.SCENE_FRAME_DURATION_DEFAULT = 100
EHT.CONST.SCENE_FRAME_DURATION_MIN = 100
EHT.CONST.SCENE_FRAME_DURATION_MAX = 1000 * 60 * 60
EHT.CONST.SCENE_FRAME_COUNT_MAX = 3600

EHT.CONST.CONTROL_DEFAULT = { }
EHT.CONST.CONTROL_DEFAULT.BUTTON_HEIGHT = 20
EHT.CONST.CONTROL_DEFAULT.BUTTON_TEXT_MARGIN_WIDTH = 10

EHT.CONST.DIALOG_ANIMATION = { }
EHT.CONST.DIALOG_ANIMATION.EDIT_SCENE = "Edit Scene"
EHT.CONST.DIALOG_ANIMATION.LOAD_SCENE = "Load Scene"
EHT.CONST.DIALOG_ANIMATION.SAVE_SCENE = "Save Scene"

EHT.CONST.FIND_ADJACENT_RADIUS_MIN = 0
EHT.CONST.FIND_ADJACENT_RADIUS_MAX = 100

EHT.CONST.SNAP_FURNITURE_RADIUS_MIN = 20
EHT.CONST.SNAP_FURNITURE_RADIUS_MAX = 50

EHT.CONST.AUTO_LEVEL_THRESHOLD = 0.96

EHT.CONST.TOOL_TABS = { }
EHT.CONST.TOOL_TABS.ANIMATE = "Scenes"
EHT.CONST.TOOL_TABS.BUILD = "Builds"
EHT.CONST.TOOL_TABS.CLIPBOARD = "Clipboard"
EHT.CONST.TOOL_TABS.HISTORY = "Undo"
EHT.CONST.TOOL_TABS.SELECT = "Select"
EHT.CONST.TOOL_TABS.TOOLS = "Tools"
EHT.CONST.TOOL_TABS.TRIGGERS = "Triggers"

EHT.CONST.TOOL_TABS_STATE = { }
EHT.CONST.TOOL_TABS_STATE.DEFAULT = "Default"
EHT.CONST.TOOL_TABS_STATE.LOAD = "Load"
EHT.CONST.TOOL_TABS_STATE.SAVE = "Save"
EHT.CONST.TOOL_TABS_STATE.MERGE = "Merge"
EHT.CONST.TOOL_TABS_STATE.APPEND = "Append"

EHT.CONST.UI_DISABLED_CONTROLS = {
	SelectionTab = true,
	EditSection = true,
	ManageScenesGroup = true,
	FrameIndex = true,
	ManageFramesGroup = true,
	FrameDurationGroup = true
}

EHT.CONST.EDIT_MODE = { }
EHT.CONST.EDIT_MODE.ABSOLUTE = "Absolute"
EHT.CONST.EDIT_MODE.RELATIVE = "Relative"

EHT.CONST.SELECTION_MODE = { }
EHT.CONST.SELECTION_MODE.ADD_SELECTION = "Add Another Selection's Items"
EHT.CONST.SELECTION_MODE.REMOVE_SELECTION = "Remove Another Selection's Items"
EHT.CONST.SELECTION_MODE.ALL_HOMOGENEOUS = "All Items (Same As Target)"
EHT.CONST.SELECTION_MODE.EXCEPT_EFFECTS = "All Items (Except Effects)"
EHT.CONST.SELECTION_MODE.EXCEPT_STATIONS = "All Items (Except Stations)"
EHT.CONST.SELECTION_MODE.ALL_STATIONS = "All Stations"
EHT.CONST.SELECTION_MODE.ALL_STATIONS_HOMOGENEOUS = "All Stations (Same Set As Target)"
EHT.CONST.SELECTION_MODE.CONNECTED = "Connected Items"
EHT.CONST.SELECTION_MODE.CONNECTED_HOMOGENEOUS = "Connected Items (Same As Target)"
EHT.CONST.SELECTION_MODE.LINKED = "Linked Relatives"
EHT.CONST.SELECTION_MODE.LINKED_CHILDREN = "Linked Children Only"
EHT.CONST.SELECTION_MODE.RADIUS = "Radius"
EHT.CONST.SELECTION_MODE.RADIUS_HOMOGENEOUS = "Radius (Same As Target)"
EHT.CONST.SELECTION_MODE.RELATED_PATH_NODES = "Related Path Nodes"
EHT.CONST.SELECTION_MODE.SINGLE = "Single Item"
EHT.CONST.SELECTION_MODE.LIMIT_TRADITIONAL = "By Limit (Traditional)"
EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL = "By Limit (Special)"
EHT.CONST.SELECTION_MODE.LIMIT_COLLECTIBLE = "By Limit (Collectible)"
EHT.CONST.SELECTION_MODE.LIMIT_SPECIAL_COLLECTIBLE = "By Limit (Special Collectible)"

EHT.CONST.GROUP_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.DEFAULT = "Change these items..."

EHT.CONST.GROUP_OPERATIONS.LINK_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.LINK_OPERATIONS.DEFAULT = "Connect these items..."
EHT.CONST.GROUP_OPERATIONS.LINK_OPERATIONS.LINK_GROUP = "Link Group"
EHT.CONST.GROUP_OPERATIONS.LINK_OPERATIONS.UNLINK_GROUP = "Unlink Group"

EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS.DEFAULT = "Move or copy these items..."
EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS.CUT_GROUP = "Remove Items"
EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS.CUT_COPY_GROUP = "Copy & Remove Items"
EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS.COPY_GROUP = "Copy Items"
EHT.CONST.GROUP_OPERATIONS.CLIPBOARD_OPERATIONS.PASTE_GROUP = "Paste Copied Items"

EHT.CONST.GROUP_OPERATIONS.A_SUMMON_OPERATION = { }
EHT.CONST.GROUP_OPERATIONS.A_SUMMON_OPERATION.DEFAULT = "Summon these items..."
EHT.CONST.GROUP_OPERATIONS.A_SUMMON_OPERATION.BRING_TO_ME = "Bring to Me"

EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.DEFAULT = "Align these items..."
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_X = "Align Each Item with Target X-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_Y = "Align Each Item with Target Y-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_EACH_WITH_TARGET_AXIS_Z = "Align Each Item with Target Z-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_X = "Align Group with Target X-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Y = "Align Group with Target Y-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.ALIGN_GROUP_WITH_TARGET_AXIS_Z = "Align Group with Target Z-Axis"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.CENTER_ON_TARGET = "Center Group on Target"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.CENTER_BETWEEN_2_TARGETS = "Center Group between 2 Targets"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.LEVEL_EACH_WITH_TARGET = "Level Each Item with Target"
EHT.CONST.GROUP_OPERATIONS.ALIGN_OPERATIONS.LEVEL_GROUP_WITH_TARGET = "Level Group with Target"

EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.DEFAULT = "Arrange these items..."
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.FLIP_GROUP_ON_X_AXIS = "Flip Group on X-Axis"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.FLIP_GROUP_ON_Y_AXIS = "Flip Group on Y-Axis"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.FLIP_GROUP_ON_Z_AXIS = "Flip Group on Z-Axis"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.MATCH_TARGET_ORIENTATION = "Orient Each Item with Target's Orientation"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.RESET_EACH_ORIENTATION = "Reset Each Item's Orientation"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.STACK_IN_1_GROUP = "Stack in a Pile"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.STACK_IN_2_GROUPS = "Stack in 2 Groups"
EHT.CONST.GROUP_OPERATIONS.ARRANGE_OPERATIONS.STACK_IN_4_GROUPS = "Stack in 4 Groups"

EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.DEFAULT = "Order these items..."
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.ALTERNATE_BY_NAME_ASC = "By Alternating Names (A-Z)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.ALTERNATE_BY_NAME_DESC = "By Alternating Names (Z-A)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.DESELECT_EVEN_ITEMS = "Deselect (Even Items)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.DESELECT_ODD_ITEMS = "Deselect (Odd Items)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.GROUP_BY_NAME_ASC = "By Name (A-Z)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.GROUP_BY_NAME_DESC = "By Name (Z-A)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.ORDER_BY_DISTANCE_ASC = "By Distance (Nearest)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.ORDER_BY_DISTANCE_DESC = "By Distance (Farthest)"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.RANDOMIZE = "Randomize"
EHT.CONST.GROUP_OPERATIONS.ORDER_OPERATIONS.REVERSE = "Reverse Order"

EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS = { }
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.DEFAULT = "Toggle these items..."
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.TOGGLE_STATE = "Toggle these items"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_OFF = "Turn these items Off"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_ON = "Turn these items On"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_ON2 = "Turn these items On (2)"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_ON3 = "Turn these items On (3)"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_ON4 = "Turn these items On (4)"
EHT.CONST.GROUP_OPERATIONS.STATE_OPERATIONS.SET_STATE_ON5 = "Turn these items On (5)"


EHT.CONST.SCENE_OPERATIONS = { }
EHT.CONST.SCENE_OPERATIONS.DEFAULT = "Change this scene..."

EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS = { }
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.DEFAULT = "Arrange this scene..."
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_X = "Align Scene with Target X-Axis"
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Y = "Align Scene with Target Y-Axis"
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.ALIGN_SCENE_WITH_TARGET_AXIS_Z = "Align Scene with Target Z-Axis"
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.BRING_TO_ME = "Bring to Me"
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.CENTER_ON_TARGET = "Center Scene on Target"
EHT.CONST.SCENE_OPERATIONS.ARRANGE_OPERATIONS.CENTER_BETWEEN_2_TARGETS = "Center Scene between 2 Targets"

EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS = { }
EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS.DEFAULT = "Edit this scene..."
EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS.COPY_SCENE = "Clone another home's scene"
EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS.MERGE_WITH_SCENE = "Merge with another Scene"
EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS.APPEND_WITH_SCENE = "Append another Scene at the end"
EHT.CONST.SCENE_OPERATIONS.EDIT_OPERATIONS.REVERSE_SCENE = "Reverse this Scene"

EHT.CONST.SCENE_OPERATIONS.EDIT_ITEM_OPERATIONS = { }
EHT.CONST.SCENE_OPERATIONS.EDIT_ITEM_OPERATIONS.DEFAULT = "Modify which items are in this scene..."
EHT.CONST.SCENE_OPERATIONS.EDIT_ITEM_OPERATIONS.SELECT_ITEMS = "Select Scene Items"
EHT.CONST.SCENE_OPERATIONS.EDIT_ITEM_OPERATIONS.ADD_ITEMS = "Add Selected Items"
EHT.CONST.SCENE_OPERATIONS.EDIT_ITEM_OPERATIONS.REMOVE_ITEMS = "Remove Selected Items"


EHT.CONST.ICONS = { }
EHT.CONST.ICONS.ROTATE_LEFT = "esoui/art/charactercreate/rotate_left_up.dds"
EHT.CONST.ICONS.ROTATE_RIGHT = "esoui/art/charactercreate/rotate_right_up.dds"

EHT.CONST.MAX_DIMENSION_CACHE_ITEMS = 3000

EHT.CONST.DIMENSION = { }
EHT.CONST.DIMENSION.X = 1
EHT.CONST.DIMENSION.Y = 2
EHT.CONST.DIMENSION.Z = 3
EHT.CONST.DIMENSION.OFFSET_X = 4
EHT.CONST.DIMENSION.OFFSET_Y = 5
EHT.CONST.DIMENSION.OFFSET_Z = 6

EHT.CONST.SNAP_MARGIN = { }
EHT.CONST.SNAP_MARGIN.MAX_X = 200
EHT.CONST.SNAP_MARGIN.MIN_X = -200
EHT.CONST.SNAP_MARGIN.MAX_Y = 200
EHT.CONST.SNAP_MARGIN.MIN_Y = -200
EHT.CONST.SNAP_MARGIN.MAX_Z = 200
EHT.CONST.SNAP_MARGIN.MIN_Z = -200

EHT.CONST.TRIGGER_CONDITION = { }
EHT.CONST.TRIGGER_CONDITION.NONE = "No additional criteria"
EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE = "A light or switch is in a specific state"
EHT.CONST.TRIGGER_CONDITION.PHRASE = "A specific phrase is used in /say, /tell, /group, /zone or /yell"
EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT = "You are in combat"
EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION = "Someone is in a specific location"
EHT.CONST.TRIGGER_CONDITION.LEAVE_COMBAT = "You are out of combat"
EHT.CONST.TRIGGER_CONDITION.LEAVE_POSITION = "No one is in a specific location"
EHT.CONST.TRIGGER_CONDITION.EMOTE = "You play an emote"
EHT.CONST.TRIGGER_CONDITION.QUICKSLOT = "You use a specific item from a Quickslot"
EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET = "You interact with something (books, doors, assistants, stations, etc.)"
EHT.CONST.TRIGGER_CONDITION.GUEST_ARRIVES = "A guest arrives"
EHT.CONST.TRIGGER_CONDITION.GUEST_DEPARTS = "A guest departs"
EHT.CONST.TRIGGER_CONDITION.DAY_TIME = "It is daytime"
EHT.CONST.TRIGGER_CONDITION.NIGHT_TIME = "It is nighttime"

EHT.CONST.TRIGGER_DEFAULT_GROUP = "- Do not use a saved selection -"
EHT.CONST.TRIGGER_DEFAULT_SCENE = "- Do not play a scene - "
EHT.CONST.TRIGGER_DEFAULT_TRIGGER = "- Do not activate another trigger -"

EHT.CONST.FURNITURE_CATEGORY_ID = { }
EHT.CONST.FURNITURE_CATEGORY_ID.TARGET_DUMMIES = 98
EHT.CONST.FURNITURE_CATEGORY_ID.CRAFTING_STATIONS = 104
EHT.CONST.FURNITURE_CATEGORY_ID.MUNDUS_STONES = 160
EHT.CONST.FURNITURE_CATEGORY_ID.ASSISTANT_BANKERS = 31
EHT.CONST.FURNITURE_CATEGORY_ID.ASSISTANT_MERCHANTS = 32
EHT.CONST.FURNITURE_CATEGORY_ID.STRUCTURES = 13
EHT.CONST.FURNITURE_CATEGORY_ID.STRUCTURES_DOORWAYS = 163

------[[ Text Rasterization ]]------

-- Sample Characters:
--  a b c d e f g h i j k l m n o p q r s t u v w x y z ~ 1 2 3 4 5 6 7 8 9 0 @ . , ' " ` _ - + = / \ ? ( )

local ch = { }
EHT.CONST.LED_CHARS = ch

--          1  2  3  4  5  6  7  8  9 10 11 12 13
ch[" "] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
ch["."] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ch[","] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4 }
ch["'"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
ch["\""]= { 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 }
ch["`"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 }
ch["_"] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ch["-"] = { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }
ch["+"] = { 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0 }
ch["="] = { 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0 }
ch[":"] = { 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0 }
ch["/"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0 }
ch["\\"]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 }
ch["?"] = { 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0 }
ch[")"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 }
ch["("] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1 }
ch["0"] = { 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0 }
ch["1"] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 4, 0, 5, 5 }
ch["2"] = { 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0 }
ch["3"] = { 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 }
ch["4"] = { 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0 }
ch["5"] = { 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 }
ch["6"] = { 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 }
ch["7"] = { 0, 0, 0, 0, 1, 1, 0, 0, 0, 5, 5, 0, 0 }
ch["8"] = { 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 }
ch["9"] = { 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0 }
--          1  2  3  4  5  6  7  8  9 10 11 12 13
ch["a"] = { 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0 }
ch["b"] = { 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0 }
ch["c"] = { 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0 }
ch["d"] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 5, 4, 5, 4 }
ch["e"] = { 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 }
ch["f"] = { 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 }
ch["g"] = { 1, 1, 0, 0, 0, 1, 1, 3, 1, 0, 0, 0, 0 }
ch["h"] = { 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0 }
ch["i"] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 5, 5, 5, 5 }
ch["j"] = { 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 }
ch["k"] = { 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 3, 0, 0 }
ch["l"] = { 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ch["m"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0 }
ch["n"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1 }
ch["o"] = { 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0 }
ch["p"] = { 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0 }
ch["q"] = { 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 3 }
ch["r"] = { 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 3 }
ch["s"] = { 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 }
ch["t"] = { 0, 0, 1, 1, 0, 0, 0, 0, 0, 5, 5, 0, 0 }
ch["u"] = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 }
ch["v"] = { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 4, 4 }
ch["w"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1 }
ch["x"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3 }
ch["y"] = { 0, 0, 0, 1, 0, 0, 0, 0, 0, 3, 3, 0, 0 }
ch["z"] = { 0, 0, 3, 2, 0, 0, 0, 0, 0, 5, 5, 5, 5 }
--          1  2  3  4  5  6  7  8  9 10 11 12 13

--			   LEDs
--		 777777777777777
--		1 10    3    11 5
--		1  10   3   11  5
--		1   10  3  11   5
--		1    10 3 11    5
--		 888888888888888
--		2    12 4 13    6
--		2   12  4  13   6
--		2  12   4   13  6
--		2 12    4    13 6
--		 999999999999999

------[ Housing Request Results ]------

EHT.CONST.HOUSING_REQUEST_RESULTS =
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
}

function EHT.GetHousingRequestResultName( result )
	return EHT.CONST.HOUSING_REQUEST_RESULTS[ result ] or ""
end

------[ Sounds ]------

EHT.SoundIds = {
[1] = "Ability_CasterBusy",
[2] = "Ability_CasterDead",
[3] = "Ability_CasterDisoriented",
[4] = "Ability_CasterFeared",
[5] = "Ability_CasterLevitated",
[6] = "Ability_CasterPacified",
[7] = "Ability_CasterSilenced",
[8] = "Ability_CasterStunned",
[9] = "Ability_Click",
[10] = "Ability_Failed",
[11] = "Ability_FailedInCombat",
[12] = "Ability_FailedRequirements",
[13] = "Ability_InvalidJusticeTarget",
[14] = "Ability_MorphAvailable",
[15] = "Ability_MorphPurchased",
[16] = "Ability_MorphSold",
[17] = "Ability_NotEnoughHealth",
[18] = "Ability_NotEnoughMagicka",
[19] = "Ability_NotEnoughStamina",
[20] = "Ability_NotEnoughUltimate",
[21] = "Ability_Picked_Up",
[22] = "Ability_RankedUp",
[23] = "Ability_Ready",
[24] = "Ability_Respec_MorphPurchased",
[25] = "Ability_Respec_SkillPurchased",
[26] = "Ability_Respec_UpgradePurchased",
[27] = "Ability_SkillPurchased",
[28] = "Ability_SkillSold",
[29] = "Ability_Slot_Menu_Open",
[30] = "Ability_Slotted",
[31] = "Ability_Synergy_Ready_Sound",
[32] = "Ability_TargetBadTarget",
[33] = "Ability_TargetDead",
[34] = "Ability_TargetImmune",
[35] = "Ability_TargetNotPvPFlagged",
[36] = "Ability_TargetOutOfLineOfSight",
[37] = "Ability_TargetOutOfRange",
[38] = "Ability_TargetTooClose",
[39] = "Ability_Ultimate_Ready_Sound",
[40] = "Ability_Unslotted",
[41] = "Ability_UpgradePurchased",
[42] = "Ability_UpgradeSold",
[43] = "Ability_WrongWeapon",
[44] = "Achievement_Awarded",
[45] = "Achievement_CategorySelected",
[46] = "Achievement_Collapsed",
[47] = "Achievement_Expanded",
[48] = "Achievement_SubCategorySelected",
[49] = "ActiveCombatTip_Failed",
[50] = "ActiveCombatTip_Shown",
[51] = "ActiveCombatTip_Success",
[52] = "Agent_Chat_Active",
[53] = "Alchemy_Closed",
[54] = "Alchemy_Create_Tooltip_Glow_Fail",
[55] = "Alchemy_Create_Tooltip_Glow_Success",
[56] = "Alchemy_Opened",
[57] = "Alchemy_Reagent_Placed",
[58] = "Alchemy_Reagent_Removed",
[59] = "Alchemy_Solvent_Placed",
[60] = "Alchemy_Solvent_Removed",
[61] = "AlliancePoint_Transact",
[62] = "AllianceWarWindow_Close",
[63] = "AllianceWarWindow_Open",
[64] = "AvA_Gate_Closed",
[65] = "AvA_Gate_Opened",
[66] = "AvA_KeepCaptured",
[67] = "Backpack_Close",
[68] = "Backpack_Open",
[69] = "Bank_Close",
[70] = "Bank_Open",
[71] = "Battleground_InactivityWarning",
[72] = "BG_CA_AreaCaptured_Moved",
[73] = "BG_CA_AreaCaptured_OtherTeam",
[74] = "BG_CA_AreaCaptured_OwnTeam",
[75] = "BG_CA_AreaCaptured_Spawned",
[76] = "BG_CM_CapturingArea",
[77] = "BG_CM_ContestingArea",
[78] = "BG_Countdown_Finish",
[79] = "BG_CTF_FlagCaptured",
[80] = "BG_CTF_FlagDropped_OtherTeam",
[81] = "BG_CTF_FlagDropped_OwnTeam",
[82] = "BG_CTF_FlagReturned",
[83] = "BG_CTF_FlagTaken_OtherTeam",
[84] = "BG_CTF_FlagTaken_OwnTeam",
[85] = "BG_CTF_TeamFlagCapture",
[86] = "BG_Kill_Assist",
[87] = "BG_Kill_KilledByEnemyTeam",
[88] = "BG_Kill_KilledByMyTeam",
[89] = "BG_Kill_KillingBlow",
[90] = "BG_Kill_StolenByEnemyTeam",
[91] = "BG_MatchLost",
[92] = "BG_MatchWon",
[93] = "BG_MB_BallDropped_OtherTeam",
[94] = "BG_MB_BallDropped_OwnTeam",
[95] = "BG_MB_BallReturned",
[96] = "BG_MB_BallTaken_OtherTeam",
[97] = "BG_MB_BallTaken_OwnTeam",
[98] = "BG_MedalReceived",
[99] = "BG_One_Minute_Warning",
[100] = "BG_VictoryNear",
[101] = "Blacksmith_Create_Tooltip_Glow",
[102] = "Blacksmith_Extract_Start_Anim",
[103] = "Blacksmith_Extracted_Booster",
[104] = "Blacksmith_Failed_Extraction",
[105] = "Blacksmith_Improve_Tooltip_Glow_Fail",
[106] = "Blacksmith_Improve_Tooltip_Glow_Success",
[107] = "Book_Acquired",
[108] = "Book_Close",
[109] = "Book_Collection_Completed",
[110] = "Book_Metal_Close",
[111] = "Book_Metal_Open",
[112] = "Book_Metal_PageTurn",
[113] = "Book_Open",
[114] = "Book_PageTurn",
[115] = "Cadwell_BladeSelected",
[116] = "Cadwell_ItemSelected",
[117] = "Campaign_BladeSelected",
[118] = "Champion_Closed",
[119] = "Champion_CycledToMage",
[120] = "Champion_CycledToThief",
[121] = "Champion_CycledToWarrior",
[122] = "Champion_DamageTaken",
[123] = "Champion_MageMouseover",
[124] = "Champion_Opened",
[125] = "Champion_PendingPointsCleared",
[126] = "Champion_PointGained",
[127] = "Champion_PointsCommitted",
[128] = "Champion_RespecAccept",
[129] = "Champion_RespecToggled",
[130] = "Champion_SpinnerDown",
[131] = "Champion_SpinnerUp",
[132] = "Champion_StarLocked",
[133] = "Champion_StarMouseover",
[134] = "Champion_StarUnlocked",
[135] = "Champion_SystemUnlocked",
[136] = "Champion_ThiefMouseover",
[137] = "Champion_WarriorMouseover",
[138] = "Champion_ZoomIn",
[139] = "Champion_ZoomOut",
[140] = "ChampionPointsIncreased",
[141] = "Character_Close",
[142] = "Character_Open",
[143] = "Chat_Max",
[144] = "Chat_Min",
[145] = "Click",
[146] = "Click",
[147] = "Click",
[148] = "Click_AllianceButton",
[149] = "Click_CC_Selector",
[150] = "Click_ClassButton",
[151] = "Click_Combo",
[152] = "Click_CreateButton",
[153] = "Click_Edit",
[154] = "Click_MenuBar",
[155] = "Click_Negative",
[156] = "Click_Positive",
[157] = "Click_RaceButton",
[158] = "Click_RandomizeButton",
[159] = "Click_SaveButton",
[160] = "Clothier_Create_Tooltip_Glow",
[161] = "Clothier_Extract_Start_Anim",
[162] = "Clothier_Extracted_Booster",
[163] = "Clothier_Failed_Extraction",
[164] = "Clothier_Improve_Tooltip_Glow_Fail",
[165] = "Clothier_Improve_Tooltip_Glow_Success",
[166] = "Codex_Close",
[167] = "Codex_Open",
[168] = "Collectible_Activated",
[169] = "Collectible_Deactivated",
[170] = "Collectible_On_Cooldown",
[171] = "Collectible_Unlocked",
[172] = "Collection_Completed",
[173] = "Collections_Close",
[174] = "Collections_Open",
[175] = "Console_Alchemy_Begin",
[176] = "Console_Character_Click",
[177] = "Console_Game_Enter",
[178] = "Console_Map_Complete_Map_Change",
[179] = "Console_Map_Start_Map_Change",
[180] = "Console_Menu_Back",
[181] = "Console_Menu_Down",
[182] = "Console_Menu_Forward",
[183] = "Console_Menu_Jump_Down",
[184] = "Console_Menu_Jump_Up",
[185] = "Console_Menu_Up",
[186] = "Console_Page_Back",
[187] = "Console_Page_Forward",
[188] = "Console_Page_Navigation_Failed",
[189] = "Console_Stats_Single_Purchase",
[190] = "Console_Window_Close",
[191] = "Console_Window_Open",
[192] = "Contacts_Close",
[193] = "Contacts_Open",
[194] = "Countdown_Tick",
[195] = "Countdown_Warning",
[196] = "Crafting_Create_Slot_Animated",
[197] = "Crafting_Gained_Inspiration",
[198] = "CrownCrates_Card_Flipping",
[199] = "CrownCrates_Card_Selected",
[200] = "CrownCrates_Cards_Leave",
[201] = "CrownCrates_Cards_Reveal_All",
[202] = "CrownCrates_Deal_Bonus",
[203] = "CrownCrates_Deal_Primary",
[204] = "CrownCrates_Gain_Gems",
[205] = "CrownCrates_Gem_Item",
[206] = "CrownCrates_GemmingWobble",
[207] = "CrownCrates_Manifest_Chosen",
[208] = "CrownCrates_Manifest_In",
[209] = "CrownCrates_Manifest_Out",
[210] = "CrownCrates_Manifest_Selected",
[211] = "CrownCrates_Purchased_With_Gems",
[212] = "CrownCrates_Scene_Closed",
[213] = "CrownCrates_Scene_Open",
[214] = "DailyLoginRewards_ActionClaim",
[215] = "DailyLoginRewards_ClaimAnnouncement",
[216] = "DailyLoginRewards_ClaimFanfare",
[217] = "DailyLoginRewards_MonthChange",
[218] = "Damage_Shield_Effect_Added",
[219] = "Damage_Shield_Effect_Added_Target",
[220] = "Damage_Shield_Effect_Lost",
[221] = "Damage_Shield_Effect_Lost_Target",
[222] = "DeathRecap_AttackShown",
[223] = "DeathRecap_KillingBlowShown",
[224] = "Decreased_Armor_Effect_Added",
[225] = "Decreased_Armor_Effect_Added_Target",
[226] = "Decreased_Armor_Effect_Lost",
[227] = "Decreased_Armor_Effect_Lost_Target",
[228] = "Decreased_Health_Regen_Effect_Added",
[229] = "Decreased_Health_Regen_Effect_Added_Target",
[230] = "Decreased_Health_Regen_Effect_Lost",
[231] = "Decreased_Health_Regen_Effect_Lost_Target",
[232] = "Decreased_Magicka_Regen_Effect_Added",
[233] = "Decreased_Magicka_Regen_Effect_Added_Target",
[234] = "Decreased_Magicka_Regen_Effect_Lost",
[235] = "Decreased_Magicka_Regen_Effect_Lost_Target",
[236] = "Decreased_Power_Effect_Added",
[237] = "Decreased_Power_Effect_Added_Target",
[238] = "Decreased_Power_Effect_Lost",
[239] = "Decreased_Power_Effect_Lost_Target",
[240] = "Decreased_Stamina_Regen_Effect_Added",
[241] = "Decreased_Stamina_Regen_Effect_Added_Target",
[242] = "Decreased_Stamina_Regen_Effect_Lost",
[243] = "Decreased_Stamina_Regen_Effect_Lost_Target",
[244] = "Default_Recipe_Crafted",
[245] = "Defer_Notification",
[246] = "Dialog_Accept",
[247] = "Dialog_Decline",
[248] = "Dialog_Hide",
[249] = "Dialog_Show",
[250] = "Display_Announcement",
[251] = "Duel_Accepted",
[252] = "Duel_Boundary_Warning",
[253] = "Duel_Forfeit",
[254] = "Duel_InviteReceived",
[255] = "Duel_Start",
[256] = "Duel_Won",
[257] = "DungeonDifficultySetToNormal",
[258] = "DungeonDifficultySetToVeteran",
[259] = "Dyeing_Accept_Binding",
[260] = "Dyeing_Apply_Changes",
[261] = "Dyeing_Apply_Changes_From_Dialogue",
[262] = "Dyeing_Closed",
[263] = "Dyeing_Opened",
[264] = "Dyeing_Randomize_Dyes",
[265] = "Dyeing_Saved_Set_Selected",
[266] = "Dyeing_Swatch_Selected",
[267] = "Dyeing_Tool_Dye_Selected",
[268] = "Dyeing_Tool_Dye_Used",
[269] = "Dyeing_Tool_Erase_Selected",
[270] = "Dyeing_Tool_Erase_Used",
[271] = "Dyeing_Tool_Fill_All_Selected",
[272] = "Dyeing_Tool_Fill_All_Used",
[273] = "Dyeing_Tool_Fill_Selected",
[274] = "Dyeing_Tool_Sample_Selected",
[275] = "Dyeing_Tool_Sample_Used",
[276] = "Dyeing_Tool_Set_Fill_Selected",
[277] = "Dyeing_Tool_Set_Fill_Used",
[278] = "Dyeing_Undo_Changes",
[279] = "ElderScroll_Captured_Aldmeri",
[280] = "ElderScroll_Captured_Daggerfall",
[281] = "ElderScroll_Captured_Ebonheart",
[282] = "Emperor_Abdicated",
[283] = "Emperor_Coronated_Aldmeri",
[284] = "Emperor_Coronated_Daggerfall",
[285] = "Emperor_Coronated_Ebonheart",
[286] = "Emperor_Deposed_Aldmeri",
[287] = "Emperor_Deposed_Daggerfall",
[288] = "Emperor_Deposed_Ebonheart",
[289] = "Enchanting_ArmorGlyph_Placed",
[290] = "Enchanting_ArmorGlyph_Removed",
[291] = "Enchanting_AspectRune_Placed",
[292] = "Enchanting_AspectRune_Removed",
[293] = "Enchanting_Closed",
[294] = "Enchanting_Create_Tooltip_Glow",
[295] = "Enchanting_EssenceRune_Placed",
[296] = "Enchanting_EssenceRune_Removed",
[297] = "Enchanting_Extract_Start_Anim",
[298] = "Enchanting_JewelryGlyph_Placed",
[299] = "Enchanting_JewelryGlyph_Removed",
[300] = "Enchanting_Opened",
[301] = "Enchanting_PotencyRune_Placed",
[302] = "Enchanting_PotencyRune_Removed",
[303] = "Enchanting_WeaponGlyph_Placed",
[304] = "Enchanting_WeaponGlyph_Removed",
[305] = "EnlightenedState_Gained",
[306] = "EnlightenedState_Lost",
[307] = "ESOPlus_TrialEnded",
[308] = "ESOPlus_TrialStarted",
[309] = "Fence_Item_Laundered",
[310] = "Finesse_Rank_Four_Ender",
[311] = "Finesse_Rank_One_Ender",
[312] = "Finesse_Rank_Three_Ender",
[313] = "Finesse_Rank_Two_Ender",
[314] = "General_Alert_Error",
[315] = "General_FailedRequirements",
[316] = "GiftInventory_ActionClaim",
[317] = "GiftInventoryView_FanfareBlast",
[318] = "GiftInventoryView_FanfareSparks",
[319] = "GiftInventoryView_FanfareStarburst",
[320] = "Group_Close",
[321] = "Group_Disband",
[322] = "Group_Invite",
[323] = "Group_Join",
[324] = "Group_Kick",
[325] = "Group_Leave",
[326] = "Group_Open",
[327] = "Group_Promote",
[328] = "GroupElection_Requested",
[329] = "GroupElection_ResultLost",
[330] = "GroupElection_ResultWon",
[331] = "GroupElection_VotedSubmitted",
[332] = "Guild_Close",
[333] = "Guild_Heraldry_Applied",
[334] = "Guild_Heraldry_CategorySelected",
[335] = "Guild_Heraldry_StyleSelected",
[336] = "Guild_Heraldry_SubCategorySelected",
[337] = "Guild_Heraldry_UndoChanges",
[338] = "Guild_Keep_Claimed",
[339] = "Guild_Keep_Lost",
[340] = "Guild_Keep_Released",
[341] = "Guild_Open",
[342] = "Guild_Self_Joined",
[343] = "Guild_Self_Left",
[344] = "GuildHistory_Blade_Selected",
[345] = "GuildHistory_Entry_Selected",
[346] = "GuildRank_Created",
[347] = "GuildRank_Deleted",
[348] = "GuildRank_Reordered",
[349] = "GuildRank_Saved",
[350] = "GuildRank_Selected",
[351] = "GuildRankLogo_Selected",
[352] = "GuildRoster_Added",
[353] = "GuildRoster_Demote",
[354] = "GuildRoster_Promote",
[355] = "GuildRoster_Removed",
[356] = "Help_BladeSelected",
[357] = "Help_Close",
[358] = "Help_ItemSelected",
[359] = "Help_Open",
[360] = "Horizontal_List_Item_Selected",
[361] = "Housing_BuyForGold",
[362] = "Housing_CloseBrowser",
[363] = "Housing_MenuClosed",
[364] = "Housing_MenuOpen",
[365] = "Housing_OpenBrowser",
[366] = "Housing_PickupItem",
[367] = "Housing_PlaceItem",
[368] = "Housing_StoreItem",
[369] = "HUD_ArmorBroken",
[370] = "HUD_WeaponDepleted",
[371] = "Immunity_Effect_Added",
[372] = "Immunity_Effect_Added_Target",
[373] = "Immunity_Effect_Lost",
[374] = "Immunity_Effect_Lost_Target",
[375] = "Imperial_City_Access_Gained_Aldmeri",
[376] = "Imperial_City_Access_Gained_Daggerfall",
[377] = "Imperial_City_Access_Gained_Ebonheart",
[378] = "Imperial_City_Access_Lost_Aldmeri",
[379] = "Imperial_City_Access_Lost_Daggerfall",
[380] = "Imperial_City_Access_Lost_Ebonheart",
[381] = "Increased_Armor_Effect_Added",
[382] = "Increased_Armor_Effect_Added_Target",
[383] = "Increased_Armor_Effect_Lost",
[384] = "Increased_Armor_Effect_Lost_Target",
[385] = "Increased_Health_Regen_Effect_Added",
[386] = "Increased_Health_Regen_Effect_Added_Target",
[387] = "Increased_Health_Regen_Effect_Lost",
[388] = "Increased_Health_Regen_Effect_Lost_Target",
[389] = "Increased_Magicka_Regen_Effect_Added",
[390] = "Increased_Magicka_Regen_Effect_Added_Target",
[391] = "Increased_Magicka_Regen_Effect_Lost",
[392] = "Increased_Magicka_Regen_Effect_Lost_Target",
[393] = "Increased_Power_Effect_Added",
[394] = "Increased_Power_Effect_Added_Target",
[395] = "Increased_Power_Effect_Lost",
[396] = "Increased_Power_Effect_Lost_Target",
[397] = "Increased_Stamina_Regen_Effect_Added",
[398] = "Increased_Stamina_Regen_Effect_Added_Target",
[399] = "Increased_Stamina_Regen_Effect_Lost",
[400] = "Increased_Stamina_Regen_Effect_Lost_Target",
[401] = "Interact_Close",
[402] = "Interact_Open",
[403] = "Inventory_DestroyJunk",
[404] = "InventoryItem_ApplyCharge",
[405] = "InventoryItem_ApplyEnchant",
[406] = "InventoryItem_MarkAsJunk",
[407] = "InventoryItem_NotJunk",
[408] = "InventoryItem_Repair",
[409] = "Item_On_Cooldown",
[410] = "JewelryCrafter_Create_Tooltip_Glow",
[411] = "JewelryCrafter_Extract_Start_Anim",
[412] = "JewelryCrafter_Extracted_Booster",
[413] = "JewelryCrafter_Failed_Extraction",
[414] = "JewelryCrafter_Improve_Tooltip_Glow_Fail",
[415] = "JewelryCrafter_Improve_Tooltip_Glow_Success",
[416] = "Journal_Progress_CategorySelected",
[417] = "Journal_Progress_SubCategorySelected",
[418] = "Justice_GoldRemoved",
[419] = "Justice_ItemRemoved",
[420] = "Justice_NoLongerKOS",
[421] = "Justice_NowKOS",
[422] = "Justice_PickpocketBonus",
[423] = "Justice_PickpocketFailed",
[424] = "Justice_StateChanged",
[425] = "Keep_Close",
[426] = "Keep_Open",
[427] = "Keybind_Button_Disabled",
[428] = "Leaderboard_CategorySelected",
[429] = "Leaderboard_SubCategorySelected",
[430] = "LevelUp",
[431] = "LevelUpReward_Claim",
[432] = "LevelUpReward_ClaimAppear",
[433] = "LevelUpReward_Fanfare",
[434] = "LevelUpReward_SectionAppear",
[435] = "LFG_Complete_Announcement",
[436] = "LFG_Find_Replacement",
[437] = "LFG_Ready_Check",
[438] = "LFG_Search_Finished",
[439] = "LFG_Search_Started",
[440] = "Lock_Value",
[441] = "Lock_Value",
[442] = "Lockpicking_chamber_locked",
[443] = "Lockpicking_chamber_reset",
[444] = "Lockpicking_chamber_start",
[445] = "Lockpicking_chamber_stress",
[446] = "Lockpicking_failed",
[447] = "Lockpicking_force",
[448] = "Lockpicking_lockpick_broke",
[449] = "Lockpicking_lockpick_contact",
[450] = "Lockpicking_start",
[451] = "Lockpicking_success",
[452] = "Lockpicking_unlocked",
[453] = "LootRoll",
[454] = "Lore_BladeSelected",
[455] = "Lore_ItemSelected",
[456] = "Mail_AcceptCod",
[457] = "Mail_Close",
[458] = "Mail_ItemDeleted",
[459] = "Mail_ItemSelected",
[460] = "Mail_Open",
[461] = "Mail_Sent",
[462] = "Map_Close",
[463] = "Map_Location_Clicked",
[464] = "Map_Open",
[465] = "Map_Ping",
[466] = "Map_Ping_Remove",
[467] = "Map_Zoom_In",
[468] = "Map_Zoom_Level_Clicked",
[469] = "Map_Zoom_Out",
[470] = "Mara_InviteReceived",
[471] = "Market_CategorySelected",
[472] = "Market_Closed",
[473] = "Market_CrownGemsSpent",
[474] = "Market_CrownsSpent",
[475] = "Market_GiftSelected",
[476] = "Market_Opened",
[477] = "Market_PreviewSelected",
[478] = "Market_PurchaseSelected",
[479] = "Market_SubCategorySelected",
[480] = "Max_Health_Decreased",
[481] = "Max_Health_Decreased_Target",
[482] = "Max_Health_Increased",
[483] = "Max_Health_Increased_Target",
[484] = "Max_Health_Normal",
[485] = "Max_Health_Normal_Target",
[486] = "Max_Magicka_Decreased",
[487] = "Max_Magicka_Decreased_Target",
[488] = "Max_Magicka_Increased",
[489] = "Max_Magicka_Increased_Target",
[490] = "Max_Magicka_Normal",
[491] = "Max_Magicka_Normal_Target",
[492] = "Max_Stamina_Decreased",
[493] = "Max_Stamina_Decreased_Target",
[494] = "Max_Stamina_Increased",
[495] = "Max_Stamina_Increased_Target",
[496] = "Max_Stamina_Normal",
[497] = "Max_Stamina_Normal_Target",
[498] = "Menu_Header_Selection",
[499] = "Menu_Subcategory_Selection",
[500] = "Money_Transact",
[501] = "New_Mail",
[502] = "New_Notification",
[503] = "New_NotificationTimed",
[504] = "No_Interact_Target",
[505] = "No_lockpicks_or_impossible",
[506] = "No_Sound",
[507] = "No_Sound",
[508] = "Note_Close",
[509] = "Note_Open",
[510] = "Note_PageTurn",
[511] = "Notifications_Close",
[512] = "Notifications_Open",
[513] = "Objective_Accept",
[514] = "Objective_Complete",
[515] = "Objective_Discovered",
[516] = "Outfit_Changes_Applied",
[517] = "Outfitting_ArmorAdd_Clothing",
[518] = "Outfitting_ArmorAdd_Heavy",
[519] = "Outfitting_ArmorAdd_Hide",
[520] = "Outfitting_ArmorAdd_Light",
[521] = "Outfitting_ArmorAdd_Medium",
[522] = "Outfitting_ArmorAdd_Signature",
[523] = "Outfitting_ArmorAdd_Undaunted",
[524] = "Outfitting_Console_MenuEnter",
[525] = "Outfitting_Console_MenuExit",
[526] = "Outfitting_Console_UndoChanges",
[527] = "Outfitting_GoToStyle",
[528] = "Outfitting_RemoveStyle",
[529] = "Outfitting_WeaponAdd_Axe",
[530] = "Outfitting_WeaponAdd_Bow",
[531] = "Outfitting_WeaponAdd_Dagger",
[532] = "Outfitting_WeaponAdd_Mace",
[533] = "Outfitting_WeaponAdd_Rune",
[534] = "Outfitting_WeaponAdd_Shield",
[535] = "Outfitting_WeaponAdd_Staff",
[536] = "Outfitting_WeaponAdd_Sword",
[537] = "Overland_Boss_Kill",
[538] = "PlayerAction_NotEnoughMoney",
[539] = "PlayerMenu_EntryDisabled",
[540] = "Possession_Effect_Applied",
[541] = "Possession_Effect_Applied_Target",
[542] = "Possession_Effect_Removed",
[543] = "Possession_Effect_Removed_Target",
[544] = "Preview_Gear",
[545] = "Provisioning_BladeSelected",
[546] = "Provisioning_Closed",
[547] = "Provisioning_EntrySelected",
[548] = "Provisioning_Opened",
[549] = "Quest_Abandon",
[550] = "Quest_Accept",
[551] = "Quest_Blade_Selected",
[552] = "Quest_Complete",
[553] = "Quest_Focused",
[554] = "Quest_ObjectivesComplete",
[555] = "Quest_ObjectivesIncrement",
[556] = "Quest_ObjectivesStarted",
[557] = "Quest_Selected",
[558] = "Quest_Share_Sent",
[559] = "Quest_Shared",
[560] = "Quest_Shared",
[561] = "Quest_StepFailed",
[562] = "QuestShare_Accepted",
[563] = "QuestShare_Accepted",
[564] = "QuestShare_Declined",
[565] = "QuestShare_Declined",
[566] = "Quickslot_Clear",
[567] = "Quickslot_Close",
[568] = "Quickslot_Mouseover",
[569] = "Quickslot_Open",
[570] = "Quickslot_Set",
[571] = "Quickslot_Use_Empty",
[572] = "Radial_Menu_Close",
[573] = "Radial_Menu_Mouseover",
[574] = "Radial_Menu_Open",
[575] = "Radial_Menu_Selection",
[576] = "Raid_Life_Display_Changed",
[577] = "Raid_Life_Display_Shown",
[578] = "Raid_Trial_Completed",
[579] = "Raid_Trial_Counter_Update",
[580] = "Raid_Trial_Failed",
[581] = "Raid_Trial_New_Best",
[582] = "Raid_Trial_Score_Added_High",
[583] = "Raid_Trial_Score_Added_Low",
[584] = "Raid_Trial_Score_Added_Normal",
[585] = "Raid_Trial_Score_Added_Very_High",
[586] = "Raid_Trial_Score_Added_Very_Low",
[587] = "Raid_Trial_Started",
[588] = "RankUp",
[589] = "Recipe_Learned",
[590] = "Retraiting_Item_To_Retrait_Placed",
[591] = "Retraiting_Item_To_Retrait_Removed",
[592] = "Retraiting_Retrait_Tooltip_Glow_Success",
[593] = "Retraiting_Start_Retrait",
[594] = "ScriptedEvent_Completion",
[595] = "Single_Setting_Reset",
[596] = "Skill_Gained",
[597] = "SkillLine_Added",
[598] = "SkillLine_Leveled",
[599] = "SkillLine_Select",
[600] = "Skills_Close",
[601] = "Skills_Open",
[602] = "SkillsAdvisor_Select",
[603] = "SkillType_Armor",
[604] = "SkillType_AvA",
[605] = "SkillType_Class",
[606] = "SkillType_Guild",
[607] = "SkillType_Racial",
[608] = "SkillType_Tradeskill",
[609] = "SkillType_Weapon",
[610] = "SkillType_World",
[611] = "SkillXP_BossKilled",
[612] = "SkillXP_DarkAnchorClosed",
[613] = "SkillXP_DarkFissureClosed",
[614] = "Skyshard_Gained",
[615] = "Smithing_Closed",
[616] = "Smithing_Finish_Research",
[617] = "Smithing_Item_To_Extract_Placed",
[618] = "Smithing_Item_To_Extract_Removed",
[619] = "Smithing_Item_To_Improve_Placed",
[620] = "Smithing_Item_To_Improve_Removed",
[621] = "Smithing_Opened",
[622] = "Smithing_Start_Research",
[623] = "Spinner_Down",
[624] = "Spinner_Up",
[625] = "Stable_BuyClicked",
[626] = "Stable_BuyMount",
[627] = "Stable_FeedCarry",
[628] = "Stable_FeedSpeed",
[629] = "Stable_FeedStamina",
[630] = "Stable_ManageClicked",
[631] = "Stats_Purchase",
[632] = "Stealth_Detected",
[633] = "Stealth_Hidden",
[634] = "Store_BuyClicked",
[635] = "Store_Close",
[636] = "Store_Open",
[637] = "Store_RepairClicked",
[638] = "Store_SellClicked",
[639] = "System_Broadcast",
[640] = "System_Close",
[641] = "System_Open",
[642] = "Tablet_Close",
[643] = "Tablet_Open",
[644] = "Tablet_PageTurn",
[645] = "Target_Deselect",
[646] = "Target_Select",
[647] = "Telvar_Gained",
[648] = "Telvar_Lost",
[649] = "Telvar_MultiplierMax",
[650] = "Telvar_MultiplierUp",
[651] = "Telvar_Transact",
[652] = "Trade_Close",
[653] = "Trade_InviteReceived",
[654] = "Trade_Open",
[655] = "Trade_ParticipantReady",
[656] = "Trade_ParticipantReconsider",
[657] = "TradingHouse_Close",
[658] = "TradingHouse_Open",
[659] = "TradingHouse_StartSearch",
[660] = "Trauma_Effect_Added",
[661] = "Trauma_Effect_Added_Target",
[662] = "Trauma_Effect_Lost",
[663] = "Trauma_Effect_Lost_Target",
[664] = "TreasureMap_Close",
[665] = "TreasureMap_Open",
[666] = "Tutorial_Info_Show",
[667] = "Tutorial_Window_Show",
[668] = "Unlock_Value",
[669] = "Unlock_Value",
[670] = "Voice_Chat_Alert_Channel_Made_Active",
[671] = "Voice_Chat_Menu_Channel_Joined",
[672] = "Voice_Chat_Menu_Channel_Left",
[673] = "Voice_Chat_Menu_Channel_Made_Active",
[674] = "Volume_Ding_All_Sound",
[675] = "Volume_Ding_Ambient",
[676] = "Volume_Ding_Music",
[677] = "Volume_Ding_SFX",
[678] = "Volume_Ding_UI",
[679] = "Volume_Ding_VO",
[680] = "weapon_swap_fail",
[681] = "weapon_swap_success",
[682] = "Window_Close",
[683] = "Window_Open",
[684] = "Woodworker_Create_Tooltip_Glow",
[685] = "Woodworker_Extract_Start_Anim",
[686] = "Woodworker_Extracted_Booster",
[687] = "Woodworker_Failed_Extraction",
[688] = "Woodworker_Improve_Tooltip_Glow_Fail",
[689] = "Woodworker_Improve_Tooltip_Glow_Success",
[690] = "WritVoucher_Transact",
}

EHT.Sounds = { }

for soundId, sound in pairs( EHT.SoundIds ) do
	EHT.Sounds[ sound ] = soundId
end


------[[ Saved Variables ]]------


EHT.SAVED_VARS_VERSION = 1
EHT.SAVED_VARS_FILE = "EssentialHousingToolsSavedVars"
EHT.SAVED_VARS_DEFAULTS = {
	AutoBackup = true,
	AutoBuild = true,
	AutoRepairStations = true,
	AutoStackExcessBuildMaterials = true,
	Build = { },
	Clipboard = { },
	Dimensions = { },
	DirectionalControlsFocusPositionEditor = true,
	DisableTriggers = false,
	EditMode = EHT.CONST.EDIT_MODE.RELATIVE,
	EditSpeed = 100,
	EnableHouseHistory = true,
	EnableHouseMapJumping = true,
	EnableHUDItemData = true,
	EnableHUDDecoTrackData = true,
	EnableEffectsMapcast = true,
	EnableProtractedSelectionCheck = true,
	EnableQuickPlacement = true,
	EnableQuickRetrieval = true,
	EnableSmoothMotion = true,
	EnableTrueCenter = true,
	GuidelinesAlpha = 0.55,
	GuidelinesLaserAlpha = 0.40,
	GuidelinesRadius = 8,
	GuidelinesUnits = 100,
	HideKeybinds = false,
	HideHousingEditorHUDButton = false,
	HideHousingEditorUndoStack = false,
	HideDuringPlacement = true,
	Houses = { },
	LimitItemIds = 0,
	MaxHouseHistory = 100,
	ScenePreview = true,
	SnapFurnitureRadius = 35,
	SelectionIndicatorAlpha = 0.75,
	SelectionBoxAlpha = 0.5,
	SelectionPrecisionUseCustom = false,
	SelectionLinkItems = false,
	SelectionMode = EHT.CONST.SELECTION_MODE.SINGLE,
	SelectionPrecision = 3,
	SelectionPrecisionMoveCustom = 20,
	SelectionPrecisionRotateCustom = 10,
	SelectionRadius = 50,
	SelectionVolatile = false,
	SelectionModifierAlt = EHT.CONST.SELECTION_MODE.SINGLE,
	SelectionModifierCtrl = EHT.CONST.SELECTION_MODE.CONNECTED_HOMOGENEOUS,
	SelectionModifierShift = EHT.CONST.SELECTION_MODE.CONNECTED,
	ShowEssentialEffectsReceived = true,
	ShowGuidelines = true,
	ShowGuidelinesVertical = true,
	ShowGuidelinesBoundaryHighlights = true,
	ShowStatsOnWindow = true,
	ShowSelectionInChat = false,
	ShowSelectionIndicators = true,
	ShowSelectionBoxIndicator = true,
	ShowTriggersInChat = false,
	ShowUndoRedoInChat = true,
	SnapToGuidelinesHorizontal = false,
	SnapToGuidelinesVertical = false,
	SnapRotationToGuidelines = false,
	SummonAssistants = true,
	TutorialsDisabled = false,
	TutorialsShown = { },
	UI = {
		DialogSettings = { },
	},
	WarnLoadScene = true,
}


------[[ Variables ]]------


EHT.SavedVars = { }

EHT.IsNewBuild = true
EHT.PreviousZoneHouseId = nil
EHT.PreviousEditorMode = nil
EHT.CurrentHousePopulation = 0

EHT.Process = nil
EHT.ProcessId = nil
EHT.ProcessData = nil

EHT.ItemIdLocalBoundsCache = {}
EHT.FurnitureIdList = {}
EHT.FurnitureIds = {}

EHT.EditorItemBefore = {}
EHT.EditorItemAfter = {}
EHT.EditorItemCache = {}

EHT.PositionItemId = nil
EHT.RecordingSceneFrames = false

EHT.SnapFurnitureItem = nil
EHT.SnapFurnitureMargins = { X = 0, Y = 0, Z = 0 }

EHT.SuppressSliderFunctions = false

EHT.IgnoreHouseLimits = false
EHT.SuppressAssistantSummoningDisabledWarning = false

EHT.TriggerPhrases = nil
EHT.TriggerQueue = { }

EHT.DirtyHouseFX = { }

EHT.DefaultSettings = { }
EHT.FurnitureStateTimestamps = { }


EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Namespaces = true
