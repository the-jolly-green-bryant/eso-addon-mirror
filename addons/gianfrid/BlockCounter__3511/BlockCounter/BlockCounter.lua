local em = GetEventManager()
local _
local db, tlw
local dx = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE) --Get UI Scale to draw thin lines correctly
PENTEST_UI_SCALE = dx
local BOLD_FONT = "EsoUI/Common/Fonts/Univers67.otf"

-- Addon Namespace
BlockCounter = BlockCounter or {}
local BlockCounter = BlockCounter
BlockCounter.name 		= "BlockCounter"
BlockCounter.version 	= "3"
BlockCounter.debug = false
BlockCounter.staminaCost = -1
BlockCounter.magickaCost = -1
BlockCounter.hasTrifocus = false
BlockCounter.icestaffEquipped = false

-- Logger

local mainlogger
local LOG_LEVEL_VERBOSE = "V"
local LOG_LEVEL_DEBUG = "D"
local LOG_LEVEL_INFO = "I"
local LOG_LEVEL_WARNING ="W"
local LOG_LEVEL_ERROR = "E"

if LibDebugLogger then

	mainlogger = LibDebugLogger.Create(BlockCounter.name)

	LOG_LEVEL_VERBOSE = LibDebugLogger.LOG_LEVEL_VERBOSE
	LOG_LEVEL_DEBUG = LibDebugLogger.LOG_LEVEL_DEBUG
	LOG_LEVEL_INFO = LibDebugLogger.LOG_LEVEL_INFO
	LOG_LEVEL_WARNING = LibDebugLogger.LOG_LEVEL_WARNING
	LOG_LEVEL_ERROR = LibDebugLogger.LOG_LEVEL_ERROR

end

local function Print(level, ...)

	if mainlogger == nil then return end

	local logger = mainlogger

	if type(logger.Log)=="function" then logger:Log(level, ...) end

end

local function hasTrifocus()
	local skillDataTable = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap
	-- Trifocus has ID 30948
	local skillData = skillDataTable and skillDataTable[30948] and skillDataTable[30948].skillData
	return skillData.isPurchased
end

local function isIceStaff()
	local activeWeaponPair = GetActiveWeaponPairInfo()
	local activeSlot = activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN and EQUIP_SLOT_MAIN_HAND or EQUIP_SLOT_BACKUP_MAIN
	local weaponType = GetItemWeaponType(0, activeSlot)
	return weaponType == WEAPONTYPE_FROST_STAFF
end

local function hasIceStaff()
	local weaponType1 = GetItemWeaponType(0, EQUIP_SLOT_BACKUP_MAIN)
	local weaponType2 = GetItemWeaponType(0, EQUIP_SLOT_MAIN_HAND)
	return weaponType1 == WEAPONTYPE_FROST_STAFF or weaponType2 == WEAPONTYPE_FROST_STAFF
end

local function GetCleanDimensions(x, y)

	if type(x) == "number" then x = math.max(zo_round(x)*dx - 0.02, 0) end
	if type(y) == "number" then y = math.max(zo_round(y)*dx - 0.02, 0) end

	return x, y

end

local function UpdateLayout()

	local dbtlw = db.tlw

	local BG = tlw:GetNamedChild("Bg")
	BG:SetAlpha(db.opacity/100)

	local blocksControl = tlw:GetNamedChild("Blocks")

	local width = dbtlw.width
	local height = dbtlw.height

	local staminaBlocksControl = blocksControl:GetNamedChild("StaminaBlocks")

	if db.staminablocks then

		staminaBlocksControl:SetHidden(false)
		staminaBlocksControl:SetDimensions(GetCleanDimensions(width, height))

		local label = staminaBlocksControl:GetNamedChild("Label")
		label:SetFont(string.format("%s|%d|soft-shadow-thin", BOLD_FONT, height*.75 ))
	else
		staminaBlocksControl:SetHidden(true)
	end

	local magickaBlocksControl = blocksControl:GetNamedChild("MagickaBlocks")

	if db.magickaBlocks and BlockCounter.hasTrifocus and BlockCounter.icestaffEquipped then

		magickaBlocksControl:SetHidden(false)
		magickaBlocksControl:SetDimensions(GetCleanDimensions(width, height))

		local label = magickaBlocksControl:GetNamedChild("Label")
		label:SetFont(string.format("%s|%d|soft-shadow-thin", BOLD_FONT, height *.75 ))

	else

		magickaBlocksControl:SetHidden(true)

	end

	-- tlw:SetDimensions(1,1)
	-- blocksControl:SetDimensions(1,1)

	tlw:SetResizeToFitDescendents(false)
	blocksControl:SetResizeToFitDescendents(false)
	tlw:SetResizeToFitDescendents(true)
	blocksControl:SetResizeToFitDescendents(true)
end

local icestaffEquipped_temp = false
local function GetBlockValues()
	BlockCounter.icestaffEquipped = hasIceStaff()
	
	local _, blockCost, _ = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_COST)
	
	BlockCounter.hasTrifocus = hasTrifocus()
	
	if BlockCounter.hasTrifocus and isIceStaff() then
		BlockCounter.magickaCost = blockCost
	else
		BlockCounter.staminaCost = blockCost
	end

	-- check if we have an icestaff equipped and update ui
	if BlockCounter.icestaffEquipped ~= icestaffEquipped_temp then
		icestaffEquipped_temp = BlockCounter.icestaffEquipped
		UpdateLayout()
	end
end

local blue = ZO_ColorDef:New(0, 0, 1, 1)
local red = ZO_ColorDef:New(1, 0, 0, 1)
local yellow = ZO_ColorDef:New(1, 1, 0, 1)
local green = ZO_ColorDef:New(0, 0.9, 0, 1)
local white = ZO_ColorDef:New(1, 1, 1, 1)

local function UpdateControl(staminaBlocks, magickaBlocks)
	local maxwidth = db.tlw.width

	local blocksControl = tlw:GetNamedChild("Blocks")
	
	local staminaBlocksControl = blocksControl:GetNamedChild("StaminaBlocks")
	local staminaLabel = staminaBlocksControl:GetNamedChild("Label")
	local textcolorS = staminaBlocks >= db.alert and green or red
	local textcolorW = magickaBlocks >= db.alert and blue or red

	staminaLabel:SetText(staminaBlocks)
	staminaLabel:SetColor(textcolorS:UnpackRGBA())

	local magickaBlocksControl = blocksControl:GetNamedChild("MagickaBlocks")
	local magickaLabel = magickaBlocksControl:GetNamedChild("Label")
	magickaLabel:SetText(magickaBlocks)
	magickaLabel:SetColor(textcolorW:UnpackRGBA())
end

function BlockCounter.MakeMenu()
    -- load the settings->addons menu library
	local menu = LibAddonMenu2
	local def = BlockCounter.defaults

    -- the panel for the addons menu
	local panel = {
		type = "panel",
		name = "BlockCounter",
		displayName = "BlockCounter",
		author = "@gianfrid & @rollback1001",
        version = BlockCounter.version or "",
		registerForRefresh = false,
	}

	local addonpanel = menu:RegisterAddonPanel("BlockCounter_Options", panel)

	local function ClearItems()

		tlw:SetHidden(true)
	
	end

	local function ShowItems(currentpanel)

		if currentpanel ~= addonpanel then return end
		tlw:SetHidden(false)
		UpdateLayout()

	end

    --this adds entries in the addon menu
	local options = {
		{
			type = "checkbox",
			name = GetString(SI_BLOCKCOUNTER_MENU_ACCOUNTWIDE),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_ACCOUNTWIDE_TOOLTIP),
			default = def.accountwide,
			getFunc = function() return BlockCounter_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] end,
			setFunc = function(value) BlockCounter_Save.Default[GetDisplayName()]['$AccountWide']["accountwide"] = value end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = GetString(SI_BLOCKCOUNTER_MENU_LOCK),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_LOCK_TOOLTIP),
			default = def.locked,
			getFunc = function() return db.locked end,
			setFunc = function(value)
						db.locked = value
						tlw:SetMovable(not value)
						tlw:SetMouseEnabled(not value)
					  end,
		},
		{
			type = "slider",
			name = GetString(SI_BLOCKCOUNTER_REFRESH_DELAY),
			tooltip = GetString(SI_BLOCKCOUNTER_REFRESH_DELAY_TOOLTIP),
			min = 10,
			max = 1000,
			step = 10,
			default = def.delay,
			getFunc = function() return db.delay end,
			setFunc = function(value)
						db.delay = value
						UpdateLayout()
					  end,
		},
		{
			type = "slider",
			name = GetString(SI_BLOCKCOUNTER_MENU_ALERT),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_ALERT_TOOLTIP),
			min = 0,
			max = 20,
			step = 1,
			default = def.alert,
			getFunc = function() return db.alert end,
			setFunc = function(value)
						db.alert = value
						UpdateLayout()
					  end,
		},
		{
			type = "slider",
			name = GetString(SI_BLOCKCOUNTER_MENU_BG_OPACITY),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_BG_OPACITY_TOOLTIP),
			min = 0,
			max = 100,
			step = 5,
			default = def.opacity,
			getFunc = function() return db.opacity end,
			setFunc = function(value)
						db.opacity = value
						UpdateLayout()
					  end,
		},
		{
			type = "slider",
			name = GetString(SI_BLOCKCOUNTER_MENU_WINDOW_WIDTH),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_WINDOW_WIDTH_TOOLTIP),
			min = 20,
			max = 100,
			step = 5,
			default = def.tlw.width,
			getFunc = function() return zo_round(db.tlw.width) end,
			setFunc = function(value)
						db.tlw.width = zo_round(value/dx)*dx
						UpdateLayout()
					  end,
		},
		{
			type = "slider",
			name = GetString(SI_BLOCKCOUNTER_MENU_WINDOW_HEIGHT),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_WINDOW_HEIGHT_TOOLTIP),
			min = 10,
			max = 100,
			step = 1,
			default = def.tlw.height,
			getFunc = function() return zo_round(db.tlw.height) end,
			setFunc = function(value)
						db.tlw.height = zo_round(value/dx)*dx
						UpdateLayout()
					  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_BLOCKCOUNTER_MENU_SHOW_STAMINABLOCKS),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_SHOW_STAMINABLOCKS_TOOLTIP),
			default = def.staminablocks,
			getFunc = function() return db.staminablocks end,
			setFunc = function(value)
						db.staminablocks = value
						UpdateLayout()
					  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_BLOCKCOUNTER_MENU_SHOW_MAGICKABLOCKS),
			tooltip = GetString(SI_BLOCKCOUNTER_MENU_SHOW_MAGICKABLOCKS_TOOLTIP),
			default = def.magickaBlocks,
			getFunc = function() return db.magickaBlocks end,
			setFunc = function(value)
						db.magickaBlocks = value
						UpdateLayout()
					  end,
		},
	}

	menu:RegisterOptionControls("BlockCounter_Options", options)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", ShowItems )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", ClearItems )

	return menu
end

-- default values (see http://wiki.esoui.com/AddOn_Quick_Questions#How_do_I_save_settings_on_the_local_machine.3F)
BlockCounter.defaults = {
	["tlw"] = {x = 150*dx, y = 150*dx, height = zo_round(60/dx)*dx, width = zo_round(50/dx)*dx},
	["accountwide"] = true,
	["locked"] = false,
	["delay"] = 100,
	["alert"] = 5,
	["opacity"] = 10,
	["staminablocks"] = true,
	["magickaBlocks"] = true,
}

local function UpdateBlock()
	tlw:Toggle(true)

	local currStamina, _, _ = GetUnitPower("player", POWERTYPE_STAMINA)
	local staminaBlocks = math.floor(currStamina / BlockCounter.staminaCost)

	local magickaBlocks = 0
	if BlockCounter.hasTrifocus then
		local currMagicka, _, _ = GetUnitPower("player", POWERTYPE_MAGICKA)
		magickaBlocks = math.floor(currMagicka / BlockCounter.magickaCost)
	end

	UpdateControl(staminaBlocks, magickaBlocks)
end

-- Initialization
function BlockCounter:Initialize(event, addon)

	local name = self.name
	if addon ~= name then return end --Only run if this addon has been loaded

	-- load saved variables

	db = ZO_SavedVars:NewAccountWide(name.."_Save", 1, nil, self.defaults) -- taken from Aynatirs guide at http://www.esoui.com/forums/showthread.php?t=6442

	if db.accountwide == false then

		db = ZO_SavedVars:NewCharacterIdSettings(name.."_Save", 1, nil, self.defaults)
		db.accountwide = false

	end

	BlockCounter.db = db

	--register Events
	em:UnregisterForEvent(name.."load", EVENT_ADD_ON_LOADED)

	self.MakeMenu()

	-- setup display frame
	tlw = BLOCKCOUNTER_TLW
	local dbtlw = db.tlw

	local isTLWShown = false
	local fragment = ZO_SimpleSceneFragment:New(tlw)

	function tlw.Toggle(self, show)

		show = show or not db.locked

		if show == isTLWShown then return end

		if show == true then

			HUD_SCENE:AddFragment(fragment)
			HUD_UI_SCENE:AddFragment(fragment)

		else

			HUD_SCENE:RemoveFragment(fragment)
			HUD_UI_SCENE:RemoveFragment(fragment)

		end

		isTLWShown = show
	end

	if (dbtlw) then

		tlw:ClearAnchors()
		tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dbtlw.x*dx, dbtlw.y*dx)

	end

	tlw:SetMovable(not db.locked)
	tlw:SetMouseEnabled(not db.locked)

	tlw:SetHandler("OnMoveStop", function(control)

		local x, y = control:GetScreenRect()

		dbtlw.x = zo_round(x/dx)
		dbtlw.y = zo_round(y/dx)

		tlw:ClearAnchors()
		tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, dbtlw.x*dx, dbtlw.y*dx)
	end)

	GetBlockValues()
	UpdateLayout()
	-- Need bar swap to get correct block values
	EVENT_MANAGER:RegisterForEvent("BlockCounter_UpdateBlockValues", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, GetBlockValues)
	EVENT_MANAGER:RegisterForUpdate("BlockCounter_Update", db.delay, UpdateBlock)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
em:RegisterForEvent(BlockCounter.name.."load", EVENT_ADD_ON_LOADED, function(...) BlockCounter:Initialize(...) end)