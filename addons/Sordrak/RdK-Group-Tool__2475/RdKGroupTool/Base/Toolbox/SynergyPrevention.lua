-- RdK Group Tool Synergy Prevention
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGTool.toolbox.sp = RdKGTool.toolbox.sp or {}
local RdKGToolSP = RdKGTool.toolbox.sp
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGTool.toolbox.so = RdKGTool.toolbox.so or {}
local RdKGToolSO = RdKGTool.toolbox.so
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group

RdKGToolSP.callbackName = RdKGTool.addonName .. "ToolboxSynergyPrevention"

RdKGToolSP.constants = {}
RdKGToolSP.constants.TLW = "RdKGTool.toolbox.sp.tlw"
RdKGToolSP.constants.blacklist = {}
RdKGToolSP.constants.MODE_BLOCK_ALL = 1
RdKGToolSP.constants.MODE_BLOCK_IF_SYNERGY_ROLE = 2

RdKGToolSP.constants.SYNERGY_ID = {}
RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD = 1
RdKGToolSP.constants.SYNERGY_ID.TALONS = 2
RdKGToolSP.constants.SYNERGY_ID.NOVA = 3
RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR = 4
RdKGToolSP.constants.SYNERGY_ID.STANDARD = 5
RdKGToolSP.constants.SYNERGY_ID.PURGE = 6
RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD = 7
RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT = 8
RdKGToolSP.constants.SYNERGY_ID.ATRONACH = 9
RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS = 10
RdKGToolSP.constants.SYNERGY_ID.RADIATE = 11
RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS = 12
RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH = 13
RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING = 14
RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER = 15
RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY = 16
RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE = 17
RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST = 18
RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL = 19
RdKGToolSP.constants.SYNERGY_ID.URSUS = 20
RdKGToolSP.constants.SYNERGY_ID.GRYPHON = 21
RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK = 22
RdKGToolSP.constants.SYNERGY_ID.PASSAGE = 23
RdKGToolSP.constants.SYNERGY_ID.RECOVERY = 24

local BLACKLIST = {}

RdKGToolSP.controls = {}

RdKGToolSP.config = {}
RdKGToolSP.config.width = 100
RdKGToolSP.config.height = 35
RdKGToolSP.config.isClampedToScreen = true
RdKGToolSP.config.onColor = {}
RdKGToolSP.config.onColor.r = 0
RdKGToolSP.config.onColor.g = 1
RdKGToolSP.config.onColor.b = 0
RdKGToolSP.config.offColor = {}
RdKGToolSP.config.offColor.r = 1
RdKGToolSP.config.offColor.g = 0
RdKGToolSP.config.offColor.b = 0
RdKGToolSP.config.updateInterval = 100
RdKGToolSP.config.defaultTexture = "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_synergy.dds"

RdKGToolSP.state = {}
RdKGToolSP.state.initialized = false
RdKGToolSP.state.registredConsumers = false
RdKGToolSP.state.foreground = true
RdKGToolSP.state.activeLayerIndex = 1
RdKGToolSP.state.registredActiveConsumers = false
RdKGToolSP.state.synergyNameList = {}
RdKGToolSP.state.blacklist = {}

local BLACKLIST = RdKGToolSP.state.blacklist

local wm = WINDOW_MANAGER

function RdKGToolSP.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolSP.callbackName, RdKGToolSP.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_SP_TOGGLE", RdKGToolSP.constants.KEYBINDING)
	RdKGToolSP.InitializeSynergyStrings()
	RdKGToolSP.CreateUI()
	RdKGToolSP.CreateSynergyIdNameList()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolSP.SetSpPositionLocked)
	RdKGToolSP.AdjustBlacklist()
	
	RdKGToolSP.state.initialized = true
	RdKGToolSP.SetEnabled(RdKGToolSP.spVars.enabled, RdKGToolSP.spVars.windowEnabled)
	RdKGToolSP.SetPositionLocked(RdKGToolSP.spVars.positionLocked)
end

function RdKGToolSP.InitializeSynergyStrings()
	--/script local data = RdKGTool.toolbox.sp.constants for key, value in pairs(testVar) do if data[key] == testVar[key] then d(data[key] .. " - OK") else d(data[key] .. " - NOK => " .. testVar[key]) end end
	--[[
	testVar = {}
	testVar.SYNERGY_COMBUSTION = zo_strformat("<<1>>", GetAbilityName(3463)) -- 3463, 26319, 29424 .. 
	testVar.SYNERGY_HEALING_COMBUSTION = zo_strformat("<<1>>", GetAbilityName(63507)) -- 63507, 63511 .. 
	testVar.SYNERGY_SHARDS_BLESSED = zo_strformat("<<1>>", GetAbilityName(26832)) -- 26832, 94973 ..
	testVar.SYNERGY_SHARDS_HOLY = zo_strformat("<<1>>", GetAbilityName(95922)) -- 95922, 95925 .. 
	testVar.SYNERGY_BLOOD_FEAST = zo_strformat("<<1>>", GetAbilityName(41963)) -- 41963, 41964 .. 
	testVar.SYNERGY_BLOOD_FUNNEL = zo_strformat("<<1>>", GetAbilityName(39500)) -- 39500, 39501 ..
	testVar.SYNERGY_SUPERNOVA = zo_strformat("<<1>>", GetAbilityName(31538)) -- 31538, 31540
	testVar.SYNERGY_GRAVITY_CRUSH = zo_strformat("<<1>>", GetAbilityName(31603)) -- 31603, 31604 .. 
	testVar.SYNERGY_SHACKLE = zo_strformat("<<1>>", GetAbilityName(32905)) -- 32905, 32910 ..
	testVar.SYNERGY_PURIFY = zo_strformat("<<1>>", GetAbilityName(22260)) -- 22260, 22269 ..
	testVar.SYNERGY_BONE_WALL = zo_strformat("<<1>>", GetAbilityName(39377)) -- 39377, 39379 ..
	testVar.SYNERGY_SPINAL_SURGE = zo_strformat("<<1>>", GetAbilityName(42194)) -- 42194, 42195 ..
	testVar.SYNERGY_IGNITE = zo_strformat("<<1>>", GetAbilityName(10805)) -- 10805, 10809 ..
	testVar.SYNERGY_RADIATE = zo_strformat("<<1>>", GetAbilityName(41838)) -- 41838, 41839 .. 
	testVar.SYNERGY_CONDUIT = zo_strformat("<<1>>", GetAbilityName(23196)) -- 23196, 136046
	testVar.SYNERGY_SPAWN_BROODLINGS = zo_strformat("<<1>>", GetAbilityName(103218)) -- 39429, 39430 ..
	testVar.SYNERGY_BLACK_WIDOWS = zo_strformat("<<1>>", GetAbilityName(41994)) -- 41994, 41996
	testVar.SYNERGY_ARACHNOPHOBIA = zo_strformat("<<1>>", GetAbilityName(18111)) -- 18111, 18116 ..
	testVar.SYNERGY_HIDDEN_REFRESH = zo_strformat("<<1>>", GetAbilityName(37729)) -- 37729, 37730 ..
	testVar.SYNERGY_SOUL_LEECH = zo_strformat("<<1>>", GetAbilityName(25169)) -- 25169, 25170 ..
	testVar.SYNERGY_HARVEST = zo_strformat("<<1>>", GetAbilityName(85572)) -- 85572, 85576 ..
	testVar.SYNERGY_ATRONACH = zo_strformat("<<1>>", GetAbilityName(48076)) -- 48076, 102310, 102321 ..
	testVar.SYNERGY_GRAVE_ROBBER = zo_strformat("<<1>>", GetAbilityName(115548)) -- 115548, 115567 ..
	testVar.SYNERGY_PURE_AGONY = zo_strformat("<<1>>", GetAbilityName(118604)) -- 118604, 118606 ..
	testVar.SYNERGY_ICY_ESCAPE = zo_strformat("<<1>>", GetAbilityName(88884)) -- 88884, 110370 ...
	testVar.SYNERGY_SANGUINE_BURST = zo_strformat("<<1>>", GetAbilityName(141920)) -- 141920, 142305
	testVar.SYNERGY_HEED_THE_CALL = zo_strformat("<<1>>", GetAbilityName(142712)) -- 142712, 142775, 142780
	testVar.SYNERGY_URSUS = zo_strformat("<<1>>", GetAbilityName(111437)) -- 111437
	]]
	RdKGToolSP.constants.SYNERGY_COMBUSTION = zo_strformat("<<1>>", GetAbilityName(3463))
	RdKGToolSP.constants.SYNERGY_HEALING_COMBUSTION = zo_strformat("<<1>>", GetAbilityName(63507)) 
	RdKGToolSP.constants.SYNERGY_SHARDS_BLESSED = zo_strformat("<<1>>", GetAbilityName(26832))
	RdKGToolSP.constants.SYNERGY_SHARDS_HOLY = zo_strformat("<<1>>", GetAbilityName(95922))
	RdKGToolSP.constants.SYNERGY_BLOOD_FEAST = zo_strformat("<<1>>", GetAbilityName(41963)) 
	RdKGToolSP.constants.SYNERGY_BLOOD_FUNNEL = zo_strformat("<<1>>", GetAbilityName(39500))
	RdKGToolSP.constants.SYNERGY_SUPERNOVA = zo_strformat("<<1>>", GetAbilityName(31538))
	RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH = zo_strformat("<<1>>", GetAbilityName(31603))
	RdKGToolSP.constants.SYNERGY_SHACKLE = zo_strformat("<<1>>", GetAbilityName(32905))
	RdKGToolSP.constants.SYNERGY_PURIFY = zo_strformat("<<1>>", GetAbilityName(22269))
	RdKGToolSP.constants.SYNERGY_BONE_WALL = zo_strformat("<<1>>", GetAbilityName(39377))
	RdKGToolSP.constants.SYNERGY_SPINAL_SURGE = zo_strformat("<<1>>", GetAbilityName(42194))
	RdKGToolSP.constants.SYNERGY_IGNITE = zo_strformat("<<1>>", GetAbilityName(10805))
	RdKGToolSP.constants.SYNERGY_RADIATE = zo_strformat("<<1>>", GetAbilityName(41838))
	RdKGToolSP.constants.SYNERGY_CONDUIT = zo_strformat("<<1>>", GetAbilityName(23196))
	RdKGToolSP.constants.SYNERGY_SPAWN_BROODLINGS = zo_strformat("<<1>>", GetAbilityName(103218))
	RdKGToolSP.constants.SYNERGY_BLACK_WIDOWS = zo_strformat("<<1>>", GetAbilityName(41994))
	RdKGToolSP.constants.SYNERGY_ARACHNOPHOBIA = zo_strformat("<<1>>", GetAbilityName(18111))
	RdKGToolSP.constants.SYNERGY_HIDDEN_REFRESH = zo_strformat("<<1>>", GetAbilityName(37729))
	RdKGToolSP.constants.SYNERGY_SOUL_LEECH = zo_strformat("<<1>>", GetAbilityName(25169))
	RdKGToolSP.constants.SYNERGY_HARVEST = zo_strformat("<<1>>", GetAbilityName(85572))
	RdKGToolSP.constants.SYNERGY_ATRONACH = zo_strformat("<<1>>", GetAbilityName(48076))
	RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER = zo_strformat("<<1>>", GetAbilityName(115548))
	RdKGToolSP.constants.SYNERGY_PURE_AGONY = zo_strformat("<<1>>", GetAbilityName(118604))
	RdKGToolSP.constants.SYNERGY_ICY_ESCAPE = zo_strformat("<<1>>", GetAbilityName(88884))
	RdKGToolSP.constants.SYNERGY_SANGUINE_BURST = zo_strformat("<<1>>", GetAbilityName(141920))
	RdKGToolSP.constants.SYNERGY_HEED_THE_CALL = zo_strformat("<<1>>", GetAbilityName(142712))
	RdKGToolSP.constants.SYNERGY_URSUS = zo_strformat("<<1>>", GetAbilityName(111437))
	RdKGToolSP.constants.SYNERGY_GRYPHON = zo_strformat("<<1>>", GetAbilityName(167041))
	RdKGToolSP.constants.SYNERGY_RUNEBREAK = zo_strformat("<<1>>", GetAbilityName(191080))
	RdKGToolSP.constants.SYNERGY_PASSAGE = zo_strformat("<<1>>", GetAbilityName(190399))
	RdKGToolSP.constants.SYNERGY_RECOVERY = zo_strformat("<<1>>", GetAbilityName(241235))
	
	
	
	--Passage sucks...
	RdKGToolSP.constants.SYNERGY_PASSAGE = RdKGToolSP.constants.SYNERGY_PASSAGE:gsub(" ",""):gsub("Between",""):gsub("Worlds",""):gsub("zwischen",""):gsub("Welten",""):gsub("entre",""):gsub("les",""):gsub("mondes","")
end

function RdKGToolSP.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.windowEnabled = true
	defaults.positionLocked = true
	defaults.pvpOnly = true
	defaults.mode = RdKGToolSP.constants.MODE_BLOCK_ALL
	defaults.maxDistance = 15
	defaults.blacklist = {}
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.TALONS] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.NOVA] = true
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.STANDARD] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURGE] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.ATRONACH] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.RADIATE] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.URSUS] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.GRYPHON] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.PASSAGE] = false
	defaults.blacklist[RdKGToolSP.constants.SYNERGY_ID.RECOVERY] = false
	return defaults
end

function RdKGToolSP.SetTlwLocation()
	if RdKGToolSP.spVars.location == nil then
		RdKGToolSP.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, -250, -250)
	else
		RdKGToolSP.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolSP.spVars.location.x, RdKGToolSP.spVars.location.y)
	end
end

function RdKGToolSP.CreateUI()
	RdKGToolSP.controls.TLW = wm:CreateTopLevelWindow(RdKGToolSP.constants.TLW)
	
	
	RdKGToolSP.SetTlwLocation()
		
	RdKGToolSP.controls.TLW:SetClampedToScreen(RdKGToolSP.config.isClampedToScreen)
	RdKGToolSP.controls.TLW:SetHandler("OnMoveStop", RdKGToolSP.SaveWindowLocation)
	RdKGToolSP.controls.TLW:SetDimensions(RdKGToolSP.config.width, RdKGToolSP.config.height)
	
	RdKGToolSP.controls.TLW.rootControl = wm:CreateControl(nil, RdKGToolSP.controls.TLW, CT_CONTROL)
	
	local rootControl = RdKGToolSP.controls.TLW.rootControl
	
	rootControl:SetDimensions(RdKGToolSP.config.width, RdKGToolSP.config.height)
	rootControl:SetAnchor(TOPLEFT, RdKGToolSP.controls.TLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolSP.config.width, RdKGToolSP.config.height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	local controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolSP.config.height - 8, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	rootControl.status = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.status:SetAnchor(TOPLEFT, rootControl, TOPLEFT, RdKGToolSP.config.height, 0)
	rootControl.status:SetDimensions(RdKGToolSP.config.width - RdKGToolSP.config.height, RdKGToolSP.config.height)
	rootControl.status:SetFont(controlFont)
	rootControl.status:SetWrapMode(ELLIPSIS)
	rootControl.status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	rootControl.texture = wm:CreateControl(nil, rootControl, CT_TEXTURE)
	rootControl.texture:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 1, 1)
	rootControl.texture:SetDimensions(RdKGToolSP.config.height - 2, RdKGToolSP.config.height - 2)
	rootControl.texture:SetTexture(RdKGToolSP.config.defaultTexture)
end

function RdKGToolSP.SetEnabled(enabled, windowEnabled)
	if RdKGToolSP.state.initialized == true and enabled ~= nil and windowEnabled ~= nil then
		RdKGToolSP.spVars.enabled = enabled
		RdKGToolSP.spVars.windowEnabled = windowEnabled
		if enabled == true or windowEnabled == true then
			if RdKGToolSP.state.registredConsumers == false then
				RdKGToolUtilGroup.AddFeature(RdKGToolSP.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE, RdKGToolSP.config.updateInterval)
				EVENT_MANAGER:RegisterForEvent(RdKGToolSP.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolSP.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolSP.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolSP.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolSP.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolSP.OnPlayerActivated)
			end
			RdKGToolSP.state.registredConsumers = true
		else
			if RdKGToolSP.state.registredConsumers == true then
				RdKGToolUtilGroup.RemoveFeature(RdKGToolSP.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_PLAYER_TO_MEMBER_DISTANCE)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolSP.callbackName, EVENT_ACTION_LAYER_POPPED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolSP.callbackName, EVENT_ACTION_LAYER_PUSHED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolSP.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolSP.state.registredConsumers = false
			RdKGToolSP.SetControlVisibility()
		end
		RdKGToolSP.OnPlayerActivated()
		if enabled == true then
			RdKGToolSP.controls.TLW.rootControl.status:SetText(RdKGToolSP.constants.ON)
			RdKGToolSP.controls.TLW.rootControl.status:SetColor(RdKGToolSP.config.onColor.r, RdKGToolSP.config.onColor.g, RdKGToolSP.config.onColor.b, 1)
		else
			RdKGToolSP.controls.TLW.rootControl.status:SetText(RdKGToolSP.constants.OFF)
			RdKGToolSP.controls.TLW.rootControl.status:SetColor(RdKGToolSP.config.offColor.r, RdKGToolSP.config.offColor.g, RdKGToolSP.config.offColor.b, 1)
		end
	end
end


function RdKGToolSP.SetPositionLocked(value)
	RdKGToolSP.spVars.positionLocked = value
	
	RdKGToolSP.controls.TLW:SetMovable(not value)
	RdKGToolSP.controls.TLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolSP.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolSP.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolSP.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolSP.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolSP.SetControlVisibility()
	local enabled = RdKGToolSP.spVars.windowEnabled
	local setHidden = true
	if enabled ~= nil and enabled == true and (RdKGToolSP.spVars.pvpOnly == false or (RdKGToolSP.spVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		setHidden = false
	end
	if setHidden == false then
		if RdKGToolSP.state.foreground == false then
			RdKGToolSP.controls.TLW:SetHidden(RdKGToolSP.state.activeLayerIndex > 2)
		else
			RdKGToolSP.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolSP.controls.TLW:SetHidden(setHidden)
	end
	--d(setHidden)
end


function RdKGToolSP.CreateSynergyIdNameList()
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_COMBUSTION] = RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_HEALING_COMBUSTION] = RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SHARDS_BLESSED] = RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SHARDS_HOLY] = RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_BLOOD_FEAST] = RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_BLOOD_FUNNEL] = RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SUPERNOVA] = RdKGToolSP.constants.SYNERGY_ID.NOVA
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH] = RdKGToolSP.constants.SYNERGY_ID.NOVA
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SHACKLE] = RdKGToolSP.constants.SYNERGY_ID.STANDARD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_PURIFY] = RdKGToolSP.constants.SYNERGY_ID.PURGE
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_BONE_WALL] = RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SPINAL_SURGE] = RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_IGNITE] = RdKGToolSP.constants.SYNERGY_ID.TALONS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_RADIATE] = RdKGToolSP.constants.SYNERGY_ID.RADIATE
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_CONDUIT] = RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SPAWN_BROODLINGS] = RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_BLACK_WIDOWS] = RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_ARACHNOPHOBIA] = RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_HIDDEN_REFRESH] = RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SOUL_LEECH] = RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_HARVEST] = RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_ATRONACH] = RdKGToolSP.constants.SYNERGY_ID.ATRONACH
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER] = RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_PURE_AGONY] = RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_ICY_ESCAPE] = RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_SANGUINE_BURST] = RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_HEED_THE_CALL] = RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_URSUS] = RdKGToolSP.constants.SYNERGY_ID.URSUS
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_GRYPHON] = RdKGToolSP.constants.SYNERGY_ID.GRYPHON
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_RUNEBREAK] = RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_PASSAGE] = RdKGToolSP.constants.SYNERGY_ID.PASSAGE
	RdKGToolSP.state.synergyNameList[RdKGToolSP.constants.SYNERGY_RECOVERY] = RdKGToolSP.constants.SYNERGY_ID.RECOVERY
end


function RdKGToolSP.GetSynergyIdForName(synergyName)
	return RdKGToolSP.state.synergyNameList[synergyName]
end

function RdKGToolSP.IsSynergyFreeForUse(synergyName)
	--d(synergyName)
	local enabled = RdKGToolSO.soVars.enabled
	--d(synergyName)
	if enabled ~= nil and enabled == true and (RdKGToolSO.soVars.pvpOnly == false or (RdKGToolSO.soVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if BLACKLIST[synergyName] ~= true then
			--d("not blacklisted")
			return true
		else
			--d("---")
			--d("on blacklist")
			local synergyId = RdKGToolSP.GetSynergyIdForName(synergyName)
			--d(synergyId)
			if synergyId ~= nil then
				--d("synergy known")
				if synergyId == RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE then
					return false
				end
				local freeForUse = true
				local players = RdKGToolUtilGroup.GetGroupInformation()
				if players ~= nil then
					for i = 1, #players do
						local player = players[i]
						--d("checking player")
						if player.role == RdKGToolUtilGroup.constants.roles.ROLE_SYNERGY and player.synergies[synergyId] == nil then
							--d("player found - synergy not in use")
							if player.isPlayer == false and player.distances ~= nil and player.distances.fromPlayer ~= nil and player.distances.fromPlayer <= RdKGToolSP.spVars.maxDistance then
								freeForUse = false
							end
						end
					end
				end
				return freeForUse
			end
			return true
		end
	else
		return true
	end
end

function RdKGToolSP.AdjustBlacklist()
	RdKGToolSP.state.blacklist = {}
	BLACKLIST = RdKGToolSP.state.blacklist
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_COMBUSTION] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_HEALING_COMBUSTION] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SHARDS_BLESSED] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SHARDS_HOLY] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.TALONS] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_IGNITE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.NOVA] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SUPERNOVA] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_GRAVITY_CRUSH] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_BLOOD_FEAST] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_BLOOD_FUNNEL] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.STANDARD] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SHACKLE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURGE] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_PURIFY] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_BONE_WALL] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SPINAL_SURGE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_CONDUIT] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.ATRONACH] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_ATRONACH] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SPAWN_BROODLINGS] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_BLACK_WIDOWS] = true
		BLACKLIST[RdKGToolSP.constants.SYNERGY_ARACHNOPHOBIA] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.RADIATE] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_RADIATE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_HIDDEN_REFRESH] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SOUL_LEECH] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_HARVEST] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_GRAVE_ROBBER] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_PURE_AGONY] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_ICY_ESCAPE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_SANGUINE_BURST] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_HEED_THE_CALL] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.URSUS] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_URSUS] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.GRYPHON] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_GRYPHON] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_RUNEBREAK] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.PASSAGE] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_PASSAGE] = true
	end
	if RdKGToolSP.spVars.blacklist[RdKGToolSP.constants.SYNERGY_ID.RECOVERY] == true then
		BLACKLIST[RdKGToolSP.constants.SYNERGY_RECOVERY] = true
	end
end

--callbacks
function RdKGToolSP.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolSP.spVars = currentProfile.toolbox.sp
		if RdKGToolSP.state.initialized == true then
			RdKGToolSP.SetPositionLocked(RdKGToolSP.spVars.positionLocked)
			RdKGToolSP.SetControlVisibility()
			RdKGToolSP.SetTlwLocation()
			RdKGToolSP.AdjustBlacklist()
		end
	end
end

function RdKGToolSP.SaveWindowLocation()
	if RdKGToolSP.spVars.positionLocked == false then
		RdKGToolSP.spVars.location = RdKGToolSP.spVars.location or {}
		RdKGToolSP.spVars.location.x = RdKGToolSP.controls.TLW:GetLeft()
		RdKGToolSP.spVars.location.y = RdKGToolSP.controls.TLW:GetTop()
	end
end

--/script RdKGTool.util.AddConditionalPreHook("test", SYNERGY, "OnSynergyAbilityChanged", function() local name, _ = GetSynergyInfo() if name ~= nil then d(name) end return true end)
function RdKGToolSP.OnPlayerActivated(eventCode, initial)
	if RdKGToolSP.spVars.enabled == true and (RdKGToolSP.spVars.pvpOnly == false or (RdKGToolSP.spVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolSP.state.registredActiveConsumers == false then
			RdKGToolUtil.AddConditionalPreHook(RdKGToolSP.callbackName, SYNERGY, "OnSynergyAbilityChanged", RdKGToolSP.OnSynergyAbilityChangedHook)
			RdKGToolSP.state.registredActiveConsumers = true
		end
	else
		if RdKGToolSP.state.registredActiveConsumers == true then
			RdKGToolUtil.RemoveConditionalPreHook(RdKGToolSP.callbackName)
			RdKGToolSP.state.registredActiveConsumers = false
		end
	end
	RdKGToolSP.SetControlVisibility()
end

function RdKGToolSP.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolSP.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolSP.state.foreground = false
	end
	--hack?
	RdKGToolSP.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolSP.SetControlVisibility()
end

function RdKGToolSP.OnKeyBinding()
	RdKGToolSP.SetEnabled(not RdKGToolSP.spVars.enabled, RdKGToolSP.spVars.windowEnabled)
end

function RdKGToolSP.OnSynergyAbilityChangedHook()
	--d("yay")
	local name, texture = GetSynergyInfo()
	name = zo_strformat("<<1>>", name)
	if texture ~= nil then
		RdKGToolSP.controls.TLW.rootControl.texture:SetTexture(texture)
		--d(texture)
		--d(name)
	else
		RdKGToolSP.controls.TLW.rootControl.texture:SetTexture(RdKGToolSP.config.defaultTexture)
	end
	if name ~= nil and RdKGToolSP.spVars.mode == RdKGToolSP.constants.MODE_BLOCK_ALL and BLACKLIST[name] == true then
		return false
	elseif name ~= nil and RdKGToolSP.spVars.mode == RdKGToolSP.constants.MODE_BLOCK_IF_SYNERGY_ROLE and RdKGToolSP.IsSynergyFreeForUse(name) == false then
		return false
	else
		return true
	end
end

--menu interaction
function RdKGToolSP.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.SP_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_ENABLED,
					getFunc = RdKGToolSP.GetSpEnabled,
					setFunc = RdKGToolSP.SetSpEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_WINDOW_ENABLED,
					getFunc = RdKGToolSP.GetSpWindowEnabled,
					setFunc = RdKGToolSP.SetSpWindowEnabled
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_PVP_ONLY,
					getFunc = RdKGToolSP.GetSpPvpOnly,
					setFunc = RdKGToolSP.SetSpPvpOnly
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_POSITION_FIXED,
					getFunc = RdKGToolSP.GetSpPositionLocked,
					setFunc = RdKGToolSP.SetSpPositionLocked
				},
				[5] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.SP_MODE,
					choices = RdKGToolSP.GetSpModes(),
					getFunc = RdKGToolSP.GetSpMode,
					setFunc = RdKGToolSP.SetSpMode
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.SP_MAX_DISTANCE,
					min = 1,
					max = 50,
					step = 1,
					getFunc = RdKGToolSP.GetSpMaxDistance,
					setFunc = RdKGToolSP.SetSpMaxDistance,
					width = "full",
					default = 25
				},
				[7] = {
					type = "divider",
					width = "full"
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_COMBUSTION_SHARD,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD, value) end
				},
				[9] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_TALONS,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.TALONS) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.TALONS, value) end
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_NOVA,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.NOVA) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.NOVA, value) end
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_BLOOD_ALTAR,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR, value) end
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_STANDARD,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.STANDARD) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.STANDARD, value) end
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_PURGE,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PURGE) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PURGE, value) end
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_BONE_SHIELD,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD, value) end
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_FLOOD_CONDUIT,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT, value) end
				},
				[16] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_ATRONACH,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.ATRONACH) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.ATRONACH, value) end
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_TRAPPING_WEBS,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS, value) end
				},
				[18] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_RADIATE,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RADIATE) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RADIATE, value) end
				},
				[19] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_CONSUMING_DARKNESS,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS, value) end
				},
				[20] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_SOUL_LEECH,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH, value) end
				},
				[21] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_WARDEN_HEALING,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING, value) end
				},
				[22] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_GRAVE_ROBBER,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER, value) end
				},
				[23] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_PURE_AGONY,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY, value) end
				},
				[24] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_ICY_ESCAPE,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.ICY_ESCAPE, value) end
				},
				[25] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_SANGUINE_BURST,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.SANGUINE_BURST, value) end
				},
				[26] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_HEED_THE_CALL,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.HEED_THE_CALL, value) end
				},
				[26] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_URSUS,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.URSUS) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.URSUS, value) end
				},
				[27] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_GRYPHON,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.GRYPHON) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.GRYPHON, value) end
				},
				[28] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_RUNEBREAK,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RUNEBREAK, value) end
				},
				[29] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_PASSAGE,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PASSAGE) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.PASSAGE, value) end
				},
				[30] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.SP_SYNERGY_RECOVERY,
					getFunc = function() return RdKGToolSP.GetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RECOVERY) end,
					setFunc = function(value) return RdKGToolSP.SetSpPreventSynergy(RdKGToolSP.constants.SYNERGY_ID.RECOVERY, value) end
				}
			}
		}
	}
	return menu
end

function RdKGToolSP.GetSpEnabled()
	return RdKGToolSP.spVars.enabled
end

function RdKGToolSP.SetSpEnabled(value)
	RdKGToolSP.SetEnabled(value, RdKGToolSP.spVars.windowEnabled)
end

function RdKGToolSP.GetSpPositionLocked()
	return RdKGToolSP.spVars.positionLocked
end

function RdKGToolSP.SetSpPositionLocked(value)
	RdKGToolSP.SetPositionLocked(value)
end

function RdKGToolSP.GetSpPvpOnly()
	return RdKGToolSP.spVars.pvpOnly
end

function RdKGToolSP.SetSpPvpOnly(value)
	RdKGToolSP.spVars.pvpOnly = value
	RdKGToolSP.OnPlayerActivated()
end

function RdKGToolSP.GetSpWindowEnabled()
	return RdKGToolSP.spVars.windowEnabled
end

function RdKGToolSP.SetSpWindowEnabled(value)
	RdKGToolSP.SetEnabled(RdKGToolSP.spVars.enabled, value)
end

function RdKGToolSP.GetSpModes()
	return RdKGToolSP.constants.MODES
end

function RdKGToolSP.GetSpMode()
	return RdKGToolSP.constants.MODES[RdKGToolSP.spVars.mode]
end

function RdKGToolSP.SetSpMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolSP.constants.MODES do
			if RdKGToolSP.constants.MODES[i] == value then
				RdKGToolSP.spVars.mode = i
			end
		end
	end
end

function RdKGToolSP.GetSpMaxDistance()
	return RdKGToolSP.spVars.maxDistance
end

function RdKGToolSP.SetSpMaxDistance(value)
	RdKGToolSP.spVars.maxDistance = value
end

function RdKGToolSP.GetSpPreventSynergy(index)
	return RdKGToolSP.spVars.blacklist[index]
end

function RdKGToolSP.SetSpPreventSynergy(index, value)
	RdKGToolSP.spVars.blacklist[index] = value
	RdKGToolSP.AdjustBlacklist()
end