--[[ 
	LibWykkydFactory, or LWF, is an addon registration and handling framework that imparts a standard functionality base to all registered addons including
	a series of global variables and API functions designed to simplify development of addons by standardizing repetitive tasks. It is loaded via LibStub and as such
	expects a functional copy of LibStub to be loaded prior to starting up.
	
	To use this addon the following should be in your addon's .txt file in the root addon folder (NOTE that LWF comes pre-packaged with all of these libraries):
	
	IF USING SETTING MENUS THROUGH LWF:
	
		## OptionalDependsOn: LibAddonMenu-1.0 LibWykkydFactory
		
		Lib/LibStub/LibStub.lua
		Lib/LibAddonMenu/LibAddonMenu-1.0.lua
		Lib/LibWykkydFactory/LibWykkydFactory.lua
	
	IF NOT USING SETTING MENUS THROUGH LWAF:
	
		## OptionalDependsOn: _lwf.AddonPrep
		
		Lib/LibStub/LibStub.lua
		Lib/LibWykkydFactory/LibWykkydFactory.lua
		
	Globals and functions provided by this library are attached to your addon's global base when you register with the library. This will not function properly if your
	addon does not register itself via the provided function, or if your addon covers multiple Lua files if you use a locally scoped variable as the addon's base. It is
	recommended that you create a singular global variable as the base of your entire addon and register with this library using something like this:
	
		myAddon = {}
		myAddon._v = {}
		myAddon._v.major		= 1
		myAddon._v.monthly 	= 5
		myAddon._v.daily 		= 1
		myAddon._v.minor 		= 1
		myAddon.Version 		= myAddon._v.major
			.."."..myAddon._v.monthly
			.."."..myAddon._v.daily
			.."."..myAddon._v.minor
			
		myAddon.MAJOR 		= myAddon._v.major.."."..myAddon._v.monthly.."."..myAddon._v.daily
		myAddon.MINOR 		= myAddon._v.minor
		myAddon.Name			= "myAddonName"
		myAddon.DisplayName  	= "My Addon Name"
		myAddon.SettingsName 	= "myAddon Settings"

		myAddon.SavedVariableVersion = 3
		myAddon.Player = GetUnitName("player")

		myAddon.Settings = {}

		myAddon.LoadSavedVariables = function( self )
			if myAddonGlobal == nil then myAddonGlobal = {} end
			if myAddonGlobal[self.SavedVariableVersion] == nil then myAddonGlobal[self.SavedVariableVersion] = {} end
			if myAddonGlobal[self.SavedVariableVersion][self.Player] == nil then myAddonGlobal[self.SavedVariableVersion][self.Player] = {} end
			if myAddonGlobal[self.SavedVariableVersion]["global"] == nil then myAddonGlobal[self.SavedVariableVersion]["global"] = {} end
			self.Settings = myAddonGlobal[self.SavedVariableVersion][self.Player]
			self.GlobalSettings = myAddonGlobal[self.SavedVariableVersion]["global"]
		end

		myAddon.LoadSettingsMenu = function( self )
			self:CreateMenu()
			self:AddMenuAddonLabel()
			...
		end

		myAddon.Initialize = function( self )
			...
		end

		REGISTER_WYKKYD_FACTORY( 
			myAddon, false, true, 
			function( self ) myAddon.LoadSavedVariables( self ) end, 
			function( self ) myAddon.LoadSettingsMenu( self ) end, 
			function( self ) myAddon.Initialize( self ) end 
		)

	For a full list of available functions & globals that this API provides see the API documentation linked in the included readme file.
]]--

local _lwf = {}
_lwf.name = "LibWykkydAddonFramework"
_lwf._v = {}
_lwf._v.major = 1
_lwf._v.monthly = 5
_lwf._v.daily = 2
_lwf._v.minor = 1
_lwf.version = _lwf._v.major
	..".".._lwf._v.monthly
	..".".._lwf._v.daily
	..".".._lwf._v.minor
local MAJOR, MINOR = _lwf.name.."-".._lwf._v.major..".".._lwf._v.monthly..".".._lwf._v.daily, _lwf._v.minor
if not LibStub then return end
_lwf.libStub, _lwf.oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not _lwf.libStub then return end

_lwf.__index = _lwf

_lwf._var = {}
_lwf._func = {}
_lwf._global = {}
_lwf._global.Var = {}
_lwf._global.Func = {}

local wm = GetWindowManager()

_lwf._global.Frames = {}

_lwf._var.bufferList = {}

_lwf._global.Func.BufferPause = function(key, buffer) 
	if not key then return end
	local ct, buffer = GetFrameTimeMilliseconds(), buffer or 3
	if not _lwf._var.bufferList[key] then _lwf._var.bufferList[key] = ct end
	if (ct - _lwf._var.bufferList[key]) >= buffer
	then _lwf._var.bufferList[key] = ct; return true;
	else return false; end
end

_lwf._global.Var.ChatChannels = {
	p = { channel = CHAT_CHANNEL_PARTY, channelDescr = "CHAT_CHANNEL_PARTY" },
	party = { channel = CHAT_CHANNEL_PARTY, channelDescr = "CHAT_CHANNEL_PARTY" },
	em = { channel = CHAT_CHANNEL_EMOTE, channelDescr = "CHAT_CHANNEL_EMOTE" },
	emote = { channel = CHAT_CHANNEL_EMOTE, channelDescr = "CHAT_CHANNEL_EMOTE" },
	s = { channel = CHAT_CHANNEL_SAY, channelDescr = "CHAT_CHANNEL_SAY" },
	say = { channel = CHAT_CHANNEL_SAY, channelDescr = "CHAT_CHANNEL_SAY" },
	g1 = { channel = CHAT_CHANNEL_GUILD_1, channelDescr = "CHAT_CHANNEL_GUILD_1" },
	g2 = { channel = CHAT_CHANNEL_GUILD_2, channelDescr = "CHAT_CHANNEL_GUILD_2" },
	g3 = { channel = CHAT_CHANNEL_GUILD_3, channelDescr = "CHAT_CHANNEL_GUILD_3" },
	g4 = { channel = CHAT_CHANNEL_GUILD_4, channelDescr = "CHAT_CHANNEL_GUILD_4" },
	g5 = { channel = CHAT_CHANNEL_GUILD_5, channelDescr = "CHAT_CHANNEL_GUILD_5" },
	o1 = { channel = CHAT_CHANNEL_OFFICER_1, channelDescr = "CHAT_CHANNEL_OFFICER_1" },
	o2 = { channel = CHAT_CHANNEL_OFFICER_2, channelDescr = "CHAT_CHANNEL_OFFICER_2" },
	o3 = { channel = CHAT_CHANNEL_OFFICER_3, channelDescr = "CHAT_CHANNEL_OFFICER_3" },
	o4 = { channel = CHAT_CHANNEL_OFFICER_4, channelDescr = "CHAT_CHANNEL_OFFICER_4" },
	o5 = { channel = CHAT_CHANNEL_OFFICER_5, channelDescr = "CHAT_CHANNEL_OFFICER_5" },
	guild1 = { channel = CHAT_CHANNEL_GUILD_1, channelDescr = "CHAT_CHANNEL_GUILD_1" },
	guild2 = { channel = CHAT_CHANNEL_GUILD_2, channelDescr = "CHAT_CHANNEL_GUILD_2" },
	guild3 = { channel = CHAT_CHANNEL_GUILD_3, channelDescr = "CHAT_CHANNEL_GUILD_3" },
	guild4 = { channel = CHAT_CHANNEL_GUILD_4, channelDescr = "CHAT_CHANNEL_GUILD_4" },
	guild5 = { channel = CHAT_CHANNEL_GUILD_5, channelDescr = "CHAT_CHANNEL_GUILD_5" },
	officer1 = { channel = CHAT_CHANNEL_OFFICER_1, channelDescr = "CHAT_CHANNEL_OFFICER_1" },
	officer2 = { channel = CHAT_CHANNEL_OFFICER_2, channelDescr = "CHAT_CHANNEL_OFFICER_2" },
	officer3 = { channel = CHAT_CHANNEL_OFFICER_3, channelDescr = "CHAT_CHANNEL_OFFICER_3" },
	officer4 = { channel = CHAT_CHANNEL_OFFICER_4, channelDescr = "CHAT_CHANNEL_OFFICER_4" },
	officer5 = { channel = CHAT_CHANNEL_OFFICER_5, channelDescr = "CHAT_CHANNEL_OFFICER_5" },
	z = { channel = CHAT_CHANNEL_ZONE, channelDescr = "CHAT_CHANNEL_ZONE" },
	zone = { channel = CHAT_CHANNEL_ZONE, channelDescr = "CHAT_CHANNEL_ZONE" },
	y = { channel = CHAT_CHANNEL_YELL, channelDescr = "CHAT_CHANNEL_YELL" },
	yell = { channel = CHAT_CHANNEL_YELL, channelDescr = "CHAT_CHANNEL_YELL" },
}

_lwf._global.Var.TextAlign = {
	["h"] = {
		["left"]	= TEXT_ALIGN_LEFT,
		["center"]	= TEXT_ALIGN_CENTER,
		["right"]	= TEXT_ALIGN_RIGHT,
	},
	["v"] = {
		["top"]		= TEXT_ALIGN_TOP,
		["center"]	= TEXT_ALIGN_CENTER,
		["bottom"]	= TEXT_ALIGN_BOTTOM,
	},
}
for k,v in pairs(_lwf._global.Var.TextAlign["h"]) do _lwf._global.Var.TextAlign["h"][string.upper(k)] = v end
for k,v in pairs(_lwf._global.Var.TextAlign["v"]) do _lwf._global.Var.TextAlign["v"][string.upper(k)] = v end
_lwf._global.Var.TextAlign["H"] = _lwf._global.Var.TextAlign["h"]
_lwf._global.Var.TextAlign["V"] = _lwf._global.Var.TextAlign["v"]

_lwf._global.Var.EquipSlot = {
	["EQUIP_SLOT_HEAD"] 		= EQUIP_SLOT_HEAD,
	["EQUIP_SLOT_NECK"] 		= EQUIP_SLOT_NECK,
	["EQUIP_SLOT_CHEST"] 		= EQUIP_SLOT_CHEST,
	["EQUIP_SLOT_SHOULDERS"] 	= EQUIP_SLOT_SHOULDERS,
	["EQUIP_SLOT_MAIN_HAND"] 	= EQUIP_SLOT_MAIN_HAND,
	["EQUIP_SLOT_OFF_HAND"] 	= EQUIP_SLOT_OFF_HAND,
	["EQUIP_SLOT_WAIST"] 		= EQUIP_SLOT_WAIST,
	["EQUIP_SLOT_LEGS"] 		= EQUIP_SLOT_LEGS,
	["EQUIP_SLOT_FEET"] 		= EQUIP_SLOT_FEET,
	["EQUIP_SLOT_COSTUME"] 		= EQUIP_SLOT_COSTUME,
	["EQUIP_SLOT_RING1"] 		= EQUIP_SLOT_RING1,
	["EQUIP_SLOT_RING2"] 		= EQUIP_SLOT_RING2,
	["EQUIP_SLOT_HAND"] 		= EQUIP_SLOT_HAND,
	["EQUIP_SLOT_BACKUP_MAIN"] 	= EQUIP_SLOT_BACKUP_MAIN,
	["EQUIP_SLOT_BACKUP_OFF"] 	= EQUIP_SLOT_BACKUP_OFF,
}
_lwf._global.Var.EquipSlotBagSlot = {
	["EQUIP_SLOT_HEAD"] 		= 0,
	["EQUIP_SLOT_NECK"] 		= 1,
	["EQUIP_SLOT_CHEST"] 		= 2,
	["EQUIP_SLOT_SHOULDERS"] 	= 3,
	["EQUIP_SLOT_MAIN_HAND"] 	= 4,
	["EQUIP_SLOT_OFF_HAND"] 	= 5,
	["EQUIP_SLOT_WAIST"] 		= 6,
	["EQUIP_SLOT_LEGS"] 		= 8,
	["EQUIP_SLOT_FEET"] 		= 9,
	["EQUIP_SLOT_COSTUME"] 		= 10,
	["EQUIP_SLOT_RING1"] 		= 11,
	["EQUIP_SLOT_RING2"] 		= 12,
	["EQUIP_SLOT_HAND"] 		= 16,
	["EQUIP_SLOT_BACKUP_MAIN"] 	= 20,
	["EQUIP_SLOT_BACKUP_OFF"] 	= 21,
}
_lwf._global.Var.EquipSlotDescrByBagSlot = {}
for descr,slot in pairs(_lwf._global.Var.EquipSlotBagSlot) do _lwf._global.Var.EquipSlotDescrByBagSlot[slot] = descr end

_lwf._global.Var.GameImages = {
	"/esoui/art/achievements/achievements_points_05.dds",
	"/esoui/art/achievements/achievements_points_10.dds",
	"/esoui/art/achievements/achievements_points_15.dds",
	"/esoui/art/achievements/achievements_points_50.dds",
	"/esoui/art/achievements/achievements_points_legendary.dds",
	"/esoui/art/actionbar/ability_keybindbg.dds",
	"/esoui/art/actionbar/abilitybar_frame_left.dds",
	"/esoui/art/actionbar/abilitybar_frame_right.dds",
	"/esoui/art/actionbar/abilitybar_lockedslot.dds",
	"/esoui/art/actionbar/abilitybar_unlockedslot.dds",
	"/esoui/art/actionbar/abilityframe64_down.dds",
	"/esoui/art/actionbar/abilityframe64_empty.dds",
	"/esoui/art/actionbar/abilityframe64_locked.dds",
	"/esoui/art/actionbar/abilityframe64_up.dds",
	"/esoui/art/actionbar/actionbar_bg_1xheight.dds",
	"/esoui/art/actionbar/actionbar_bg_2xheight.dds",
	"/esoui/art/actionbar/actionbar_bg_2xheight_bottom.dds",
	"/esoui/art/actionbar/buff_frame.dds",
	"/esoui/art/actionbar/classbar_bg.dds",
	"/esoui/art/actionbar/debuff_frame.dds",
	"/esoui/art/actionbar/magechamber_firespelloverlay_down.dds",
	"/esoui/art/actionbar/magechamber_firespelloverlay_up.dds",
	"/esoui/art/actionbar/magechamber_icespelloverlay_down.dds",
	"/esoui/art/actionbar/magechamber_icespelloverlay_up.dds",
	"/esoui/art/actionbar/magechamber_lightningspelloverlay_down.dds",
	"/esoui/art/actionbar/magechamber_lightningspelloverlay_up.dds",
	"/esoui/art/actionbar/magechamber_magespelloverlay_down.dds",
	"/esoui/art/actionbar/magechamber_magespelloverlay_up.dds",
	"/esoui/art/actionbar/magechamber_magespelloverlay02_down.dds",
	"/esoui/art/actionbar/magechamber_magespelloverlay02_up.dds",
	"/esoui/art/actionbar/pagination_down_down.dds",
	"/esoui/art/actionbar/pagination_down_over.dds",
	"/esoui/art/actionbar/pagination_down_up.dds",
	"/esoui/art/actionbar/pagination_up_down.dds",
	"/esoui/art/actionbar/pagination_up_over.dds",
	"/esoui/art/actionbar/pagination_up_up.dds",
	"/esoui/art/actionbar/passiveabilityframe_round_down.dds",
	"/esoui/art/actionbar/passiveabilityframe_round_empty.dds",
	"/esoui/art/actionbar/passiveabilityframe_round_locked.dds",
	"/esoui/art/actionbar/passiveabilityframe_round_over.dds",
	"/esoui/art/actionbar/passiveabilityframe_round_up.dds",
	"/esoui/art/actionbar/quickslotbg.dds",
	"/esoui/art/actionbar/ultimatemeter_frame64.dds",
	"/esoui/art/ava/ava_allianceflag_aldmeri.dds",
	"/esoui/art/ava/ava_allianceflag_daggerfall.dds",
	"/esoui/art/ava/ava_allianceflag_ebonheart.dds",
	"/esoui/art/ava/ava_allianceflag_neutral.dds",
	"/esoui/art/ava/ava_hud_emblem_neutral.dds",
	"/esoui/art/ava/ava_keepstatus_icon_collectionrate.dds",
	"/esoui/art/ava/ava_keepstatus_icon_food_aldmeri.dds",
	"/esoui/art/ava/ava_keepstatus_icon_food_daggerfall.dds",
	"/esoui/art/ava/ava_keepstatus_icon_food_ebonheart.dds",
	"/esoui/art/ava/ava_keepstatus_icon_food_neutral.dds",
	"/esoui/art/ava/ava_keepstatus_icon_ore_aldmeri.dds",
	"/esoui/art/ava/ava_keepstatus_icon_ore_daggerfall.dds",
	"/esoui/art/ava/ava_keepstatus_icon_ore_ebonheart.dds",
	"/esoui/art/ava/ava_keepstatus_icon_ore_neutral.dds",
	"/esoui/art/ava/ava_keepstatus_icon_surpluslevel.dds",
	"/esoui/art/ava/ava_keepstatus_icon_timetoupgrade.dds",
	"/esoui/art/ava/ava_keepstatus_icon_wood_aldmeri.dds",
	"/esoui/art/ava/ava_keepstatus_icon_wood_daggerfall.dds",
	"/esoui/art/ava/ava_keepstatus_icon_wood_ebonheart.dds",
	"/esoui/art/ava/ava_keepstatus_icon_wood_neutral.dds",
	"/esoui/art/ava/ava_keepstatus_resourcetab_bg_left.dds",
	"/esoui/art/ava/ava_keepstatus_resourcetab_bg_right.dds",
	"/esoui/art/ava/ava_keepstatus_summary_bg_left.dds",
	"/esoui/art/ava/ava_keepstatus_summary_bg_right.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_food.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_food_inactive.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_keep.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_keep_inactive.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_ore.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_ore_inactive.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_wood.dds",
	"/esoui/art/ava/ava_keepstatus_tabicon_wood_inactive.dds",
	"/esoui/art/ava/ava_medal.dds",
	"/esoui/art/ava/ava_rankicon_firstseargant.dds",
	"/esoui/art/ava/ava_rankicon_grandoverlord.dds",
	"/esoui/art/ava/ava_rankicon_praetorian.dds",
	"/esoui/art/ava/ava_rankicon64_firstseargant.dds",
	"/esoui/art/ava/ava_rankicon64_grandoverlord.dds",
	"/esoui/art/ava/ava_resourcestatus_bg_left.dds",
	"/esoui/art/ava/ava_resourcestatus_bg_right.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay_down.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_achieved_overlay_up.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_fill.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_leadingedge.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_unachieved_overlay_down.dds",
	"/esoui/art/ava/ava_resourcestatus_progbar_unachieved_overlay_up.dds",
	"/esoui/art/ava/ava_resourcestatus_progbarframe.dds",
	"/esoui/art/ava/ava_resourcestatus_tabicon_defense.dds",
	"/esoui/art/ava/ava_resourcestatus_tabicon_defense_inactive.dds",
	"/esoui/art/ava/ava_resourcestatus_tabicon_production.dds",
	"/esoui/art/ava/ava_resourcestatus_tabicon_production_inactive.dds",
	"/esoui/art/ava/ava_resourcestatus_total_inset.dds",
	"/esoui/art/ava/ava_resourcestatus_upkeeplevel_marker.dds",
	"/esoui/art/ava/ava_rightcolumndivider_left.dds",
	"/esoui/art/ava/ava_rightcolumndivider_right.dds",
	"/esoui/art/ava/ava_seigecontrols_bg.dds",
	"/esoui/art/ava/ava_siegecontrols_bg_bottom.dds",
	"/esoui/art/ava/ava_siegecontrols_bg_top.dds",
	"/esoui/art/ava/ava_siegeupgrade_bg.dds",
	"/esoui/art/ava/ava_siegeupgrade_bg_bottom.dds",
	"/esoui/art/ava/ava_siegeupgrade_bg_top.dds",
	"/esoui/art/ava/ava_transitline.dds",
	"/esoui/art/ava/ava_transitline_dashed.dds",
	"/esoui/art/ava/ava_transitlocked.dds",
	"/esoui/art/ava/bg_queueing_left.dds",
	"/esoui/art/ava/bg_queueing_right.dds",
	"/esoui/art/ava/hookpoint_disabled.dds",
	"/esoui/art/ava/hookpoint_locked.dds",
	"/esoui/art/ava/hookpoint_npc.dds",
	"/esoui/art/ava/hookpoint_npc_over.dds",
	"/esoui/art/ava/hookpoint_npc_pending.dds",
	"/esoui/art/ava/hookpoint_oil.dds",
	"/esoui/art/ava/hookpoint_oil_over.dds",
	"/esoui/art/ava/hookpoint_oil_pending.dds",
	"/esoui/art/ava/hookpoint_siege.dds",
	"/esoui/art/ava/hookpoint_siege_over.dds",
	"/esoui/art/ava/hookpoint_siege_pending.dds",
	"/esoui/art/ava/pvp_queueing_left.dds",
	"/esoui/art/ava/pvp_queueing_right.dds",
	"/esoui/art/ava/tabicon_bg_helper_disabled.dds",
	"/esoui/art/ava/tabicon_bg_helper_inactive.dds",
	"/esoui/art/ava/tabicon_bg_score_disabled.dds",
	"/esoui/art/ava/tabicon_bg_score_inactive.dds",
	"/esoui/art/bank/bank_purchaseover.dds",
	"/esoui/art/buttons/accept_down.dds",
	"/esoui/art/buttons/accept_over.dds",
	"/esoui/art/buttons/accept_up.dds",
	"/esoui/art/buttons/blade_closed_down.dds",
	"/esoui/art/buttons/blade_closed_up.dds",
	"/esoui/art/buttons/blade_disabled.dds",
	"/esoui/art/buttons/blade_mouseover.dds",
	"/esoui/art/buttons/blade_open_down.dds",
	"/esoui/art/buttons/blade_open_up.dds",
	"/esoui/art/buttons/cancel_down.dds",
	"/esoui/art/buttons/cancel_over.dds",
	"/esoui/art/buttons/cancel_up.dds",
	"/esoui/art/buttons/checkbox_indeterminate.dds",
	"/esoui/art/buttons/clearslot_disabled.dds",
	"/esoui/art/buttons/clearslot_down.dds",
	"/esoui/art/buttons/clearslot_up.dds",
	"/esoui/art/buttons/decline_down.dds",
	"/esoui/art/buttons/decline_over.dds",
	"/esoui/art/buttons/decline_up.dds",
	"/esoui/art/buttons/dropbox_arrow_disabled.dds",
	"/esoui/art/buttons/edit_cancel_down.dds",
	"/esoui/art/buttons/edit_cancel_over.dds",
	"/esoui/art/buttons/edit_cancel_up.dds",
	"/esoui/art/buttons/edit_disabled.dds",
	"/esoui/art/buttons/edit_down.dds",
	"/esoui/art/buttons/edit_over.dds",
	"/esoui/art/buttons/edit_save_disabled.dds",
	"/esoui/art/buttons/edit_save_down.dds",
	"/esoui/art/buttons/edit_save_over.dds",
	"/esoui/art/buttons/edit_save_up.dds",
	"/esoui/art/buttons/edit_up.dds",
	"/esoui/art/buttons/generic_highlight.dds",
	"/esoui/art/buttons/info_disabled.dds",
	"/esoui/art/buttons/info_down.dds",
	"/esoui/art/buttons/info_over.dds",
	"/esoui/art/buttons/info_up.dds",
	"/esoui/art/buttons/left_mousedown.dds",
	"/esoui/art/buttons/left_normal.dds",
	"/esoui/art/buttons/leftarrow_disabled.dds",
	"/esoui/art/buttons/maximize_mousedown.dds",
	"/esoui/art/buttons/maximize_normal.dds",
	"/esoui/art/buttons/minimize_mousedown.dds",
	"/esoui/art/buttons/minimize_normal.dds",
	"/esoui/art/buttons/minmax_mouseover.dds",
	"/esoui/art/buttons/pinned_mousedown.dds",
	"/esoui/art/buttons/pinned_mouseover.dds",
	"/esoui/art/buttons/pinned_normal.dds",
	"/esoui/art/buttons/pointsminus_disabled.dds",
	"/esoui/art/buttons/pointsminus_down.dds",
	"/esoui/art/buttons/pointsminus_over.dds",
	"/esoui/art/buttons/pointsminus_up.dds",
	"/esoui/art/buttons/pointsplus_disabled.dds",
	"/esoui/art/buttons/pointsplus_down.dds",
	"/esoui/art/buttons/pointsplus_highlight.dds",
	"/esoui/art/buttons/pointsplus_over.dds",
	"/esoui/art/buttons/pointsplus_up.dds",
	"/esoui/art/buttons/radiobuttondisableddown.dds",
	"/esoui/art/buttons/right_mousedown.dds",
	"/esoui/art/buttons/right_normal.dds",
	"/esoui/art/buttons/rightarrow_disabled.dds",
	"/esoui/art/buttons/searchbutton_disabled.dds",
	"/esoui/art/buttons/swatchframe_down.dds",
	"/esoui/art/buttons/swatchframe_over.dds",
	"/esoui/art/buttons/swatchframe_selected.dds",
	"/esoui/art/buttons/swatchframe_selected_disabled.dds",
	"/esoui/art/buttons/swatchframe_up.dds",
	"/esoui/art/buttons/switch_disabled.dds",
	"/esoui/art/buttons/switch_down.dds",
	"/esoui/art/buttons/switch_up.dds",
	"/esoui/art/buttons/unpinned_mousedown.dds",
	"/esoui/art/buttons/unpinned_mouseover.dds",
	"/esoui/art/buttons/unpinned_normal.dds",
	"/esoui/art/campaign/campaign_tabicon_browser_down.dds",
	"/esoui/art/campaign/campaign_tabicon_browser_over.dds",
	"/esoui/art/campaign/campaign_tabicon_browser_up.dds",
	"/esoui/art/campaign/campaign_tabicon_history_down.dds",
	"/esoui/art/campaign/campaign_tabicon_history_over.dds",
	"/esoui/art/campaign/campaign_tabicon_history_up.dds",
	"/esoui/art/campaign/campaign_tabicon_leaderboard_down.dds",
	"/esoui/art/campaign/campaign_tabicon_leaderboard_over.dds",
	"/esoui/art/campaign/campaign_tabicon_leaderboard_up.dds",
	"/esoui/art/campaign/campaign_tabicon_summary_down.dds",
	"/esoui/art/campaign/campaign_tabicon_summary_over.dds",
	"/esoui/art/campaign/campaign_tabicon_summary_up.dds",
	"/esoui/art/campaign/campaignbonus_emporershipicon.dds",
	"/esoui/art/campaign/campaignbonus_keepicon.dds",
	"/esoui/art/campaign/campaignbonus_scrollicon.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_ad.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_ad_over.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_dc.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_dc_over.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_ep.dds",
	"/esoui/art/campaign/campaignbrowser_columnheader_ep_over.dds",
	"/esoui/art/campaign/campaignbrowser_divider_short.dds",
	"/esoui/art/campaign/campaignbrowser_friends.dds",
	"/esoui/art/campaign/campaignbrowser_fullpop.dds",
	"/esoui/art/campaign/campaignbrowser_group.dds",
	"/esoui/art/campaign/campaignbrowser_guestcampaign.dds",
	"/esoui/art/campaign/campaignbrowser_guild.dds",
	"/esoui/art/campaign/campaignbrowser_hipop.dds",
	"/esoui/art/campaign/campaignbrowser_homecampaign.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_hardcore_down.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_hardcore_over.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_hardcore_up.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_normal_down.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_normal_over.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds",
	"/esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
	"/esoui/art/campaign/campaignbrowser_listdivider_left.dds",
	"/esoui/art/campaign/campaignbrowser_listdivider_right.dds",
	"/esoui/art/campaign/campaignbrowser_lowpop.dds",
	"/esoui/art/campaign/campaignbrowser_medpop.dds",
	"/esoui/art/campaign/emporer_playerbg_left.dds",
	"/esoui/art/campaign/emporer_playerbg_right.dds",
	"/esoui/art/campaign/leaderboard_meddivider_left.dds",
	"/esoui/art/campaign/leaderboard_meddivider_right.dds",
	"/esoui/art/campaign/leaderboard_playerhighlight_left.dds",
	"/esoui/art/campaign/leaderboard_playerhighlight_right.dds",
	"/esoui/art/campaign/leaderboard_top100banner.dds",
	"/esoui/art/campaign/leaderboard_top20banner.dds",
	"/esoui/art/campaign/leaderboard_top50banner.dds",
	"/esoui/art/campaign/overview_allianceicon_aldmeri.dds",
	"/esoui/art/campaign/overview_allianceicon_daggefall.dds",
	"/esoui/art/campaign/overview_allianceicon_ebonheart.dds",
	"/esoui/art/campaign/overview_indexicon_bonus_disabled.dds",
	"/esoui/art/campaign/overview_indexicon_bonus_down.dds",
	"/esoui/art/campaign/overview_indexicon_bonus_over.dds",
	"/esoui/art/campaign/overview_indexicon_bonus_up.dds",
	"/esoui/art/campaign/overview_indexicon_emperor_disabled.dds",
	"/esoui/art/campaign/overview_indexicon_emperor_down.dds",
	"/esoui/art/campaign/overview_indexicon_emperor_over.dds",
	"/esoui/art/campaign/overview_indexicon_emperor_up.dds",
	"/esoui/art/campaign/overview_indexicon_scoring_disabled.dds",
	"/esoui/art/campaign/overview_indexicon_scoring_down.dds",
	"/esoui/art/campaign/overview_indexicon_scoring_over.dds",
	"/esoui/art/campaign/overview_indexicon_scoring_up.dds",
	"/esoui/art/campaign/overview_keepicon_aldmeri.dds",
	"/esoui/art/campaign/overview_keepicon_daggefall.dds",
	"/esoui/art/campaign/overview_keepicon_ebonheart.dds",
	"/esoui/art/campaign/overview_outposticon_aldmeri.dds",
	"/esoui/art/campaign/overview_outposticon_daggefall.dds",
	"/esoui/art/campaign/overview_outposticon_ebonheart.dds",
	"/esoui/art/campaign/overview_resourcesicon_aldmeri.dds",
	"/esoui/art/campaign/overview_resourcesicon_daggefall.dds",
	"/esoui/art/campaign/overview_resourcesicon_ebonheart.dds",
	"/esoui/art/campaign/overview_rewardprogbar_left.dds",
	"/esoui/art/campaign/overview_rewardprogbar_right.dds",
	"/esoui/art/campaign/overview_scoringbg_aldmeri_left.dds",
	"/esoui/art/campaign/overview_scoringbg_aldmeri_right.dds",
	"/esoui/art/campaign/overview_scoringbg_daggerfall_left.dds",
	"/esoui/art/campaign/overview_scoringbg_daggerfall_right.dds",
	"/esoui/art/campaign/overview_scoringbg_ebonheart_left.dds",
	"/esoui/art/campaign/overview_scoringbg_ebonheart_right.dds",
	"/esoui/art/campaign/overview_scrollicon_aldmeri.dds",
	"/esoui/art/campaign/overview_scrollicon_daggefall.dds",
	"/esoui/art/campaign/overview_scrollicon_ebonheart.dds",
	"/esoui/art/charactercreate/charactercreate_accessory_down.dds",
	"/esoui/art/charactercreate/charactercreate_accessory_over.dds",
	"/esoui/art/charactercreate/charactercreate_accessory_up.dds",
	"/esoui/art/charactercreate/charactercreate_altmericon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_argonianicon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_bodyicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_bodyicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_bodyicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_bosmericon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_bretonicon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_classicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_classicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_classicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_dunmericon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_faceicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_faceicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_femaleicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_femaleicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_femaleicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_khajiiticon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_leftarrow_down.dds",
	"/esoui/art/charactercreate/charactercreate_leftarrow_over.dds",
	"/esoui/art/charactercreate/charactercreate_leftarrow_up.dds",
	"/esoui/art/charactercreate/charactercreate_maleicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_maleicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_maleicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_nordicon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_raceicon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_raceicon_down.dds",
	"/esoui/art/charactercreate/charactercreate_raceicon_over.dds",
	"/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
	"/esoui/art/charactercreate/charactercreate_redguardicon_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_rightarrow_down.dds",
	"/esoui/art/charactercreate/charactercreate_rightarrow_over.dds",
	"/esoui/art/charactercreate/charactercreate_rightarrow_up.dds",
	"/esoui/art/charactercreate/charactercreate_zoom-_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_zoom-_down.dds",
	"/esoui/art/charactercreate/charactercreate_zoom_over.dds",
	"/esoui/art/charactercreate/charactercreate_zoom-_over.dds",
	"/esoui/art/charactercreate/charactercreate_zoom-_up.dds",
	"/esoui/art/charactercreate/charactercreate_zoom+_disabled.dds",
	"/esoui/art/charactercreate/charactercreate_zoom+_down.dds",
	"/esoui/art/charactercreate/charactercreate_zoom+_over.dds",
	"/esoui/art/charactercreate/charactercreate_zoom+_up.dds",
	"/esoui/art/charactercreate/rotate_left_down.dds",
	"/esoui/art/charactercreate/rotate_left_over.dds",
	"/esoui/art/charactercreate/rotate_left_up.dds",
	"/esoui/art/charactercreate/rotate_right_down.dds",
	"/esoui/art/charactercreate/rotate_right_over.dds",
	"/esoui/art/charactercreate/rotate_right_up.dds",
	"/esoui/art/charactercreate/selectortriangle.dds",
	"/esoui/art/charactercreate/selectortriangle_disabled.dds",
	"/esoui/art/charactercreate/triangle_selector_pip.dds",
	"/esoui/art/charactercreate/triangle_selector_pip_disabled.dds",
	"/esoui/art/charactercreate/triangle_selector_pip_glow.dds",
	"/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds",
	"/esoui/art/charactercreate/unavailable_overlay.dds",
	"/esoui/art/charactercreate/windowdivider.dds",
	"/esoui/art/characterwindow/alliancebadge_aldmeri.dds",
	"/esoui/art/characterwindow/alliancebadge_daggerfall.dds",
	"/esoui/art/characterwindow/alliancebadge_ebonheart.dds",
	"/esoui/art/characterwindow/characterwindow_leftside_divider.dds",
	"/esoui/art/characterwindow/characterwindow_leftsidebg_bottom.dds",
	"/esoui/art/characterwindow/characterwindow_leftsidebg_top.dds",
	"/esoui/art/characterwindow/charsheet_guildtab_icon_inactive.dds",
	"/esoui/art/characterwindow/charsheet_statstab_icon_inactive.dds",
	"/esoui/art/characterwindow/gearslot_belt.dds",
	"/esoui/art/characterwindow/gearslot_chest.dds",
	"/esoui/art/characterwindow/gearslot_costume.dds",
	"/esoui/art/characterwindow/gearslot_feet.dds",
	"/esoui/art/characterwindow/gearslot_hands.dds",
	"/esoui/art/characterwindow/gearslot_head.dds",
	"/esoui/art/characterwindow/gearslot_legs.dds",
	"/esoui/art/characterwindow/gearslot_mainhand.dds",
	"/esoui/art/characterwindow/gearslot_neck.dds",
	"/esoui/art/characterwindow/gearslot_offhand.dds",
	"/esoui/art/characterwindow/gearslot_over.dds",
	"/esoui/art/characterwindow/gearslot_quickslot.dds",
	"/esoui/art/characterwindow/gearslot_ring.dds",
	"/esoui/art/characterwindow/gearslot_selected.dds",
	"/esoui/art/characterwindow/gearslot_shoulders.dds",
	"/esoui/art/characterwindow/gearslot_tabard.dds",
	"/esoui/art/characterwindow/sigil_armor.dds",
	"/esoui/art/characterwindow/sigil_health.dds",
	"/esoui/art/characterwindow/sigil_stamina.dds",
	"/esoui/art/characterwindow/weaponswap_disabled.dds",
	"/esoui/art/characterwindow/weaponswap_down.dds",
	"/esoui/art/characterwindow/weaponswap_locked.dds",
	"/esoui/art/characterwindow/weaponswap_over.dds",
	"/esoui/art/characterwindow/weaponswap_up.dds",
	"/esoui/art/characterwindow/xpbar_left.dds",
	"/esoui/art/characterwindow/xpbar_right.dds",
	"/esoui/art/chatwindow/chat_addtab_disabled.dds",
	"/esoui/art/chatwindow/chat_addtab_down.dds",
	"/esoui/art/chatwindow/chat_addtab_over.dds",
	"/esoui/art/chatwindow/chat_addtab_up.dds",
	"/esoui/art/chatwindow/chat_bg_center.dds",
	"/esoui/art/chatwindow/chat_bg_edge.dds",
	"/esoui/art/chatwindow/chat_friendsonline_down.dds",
	"/esoui/art/chatwindow/chat_friendsonline_over.dds",
	"/esoui/art/chatwindow/chat_friendsonline_up.dds",
	"/esoui/art/chatwindow/chat_notification_burst.dds",
	"/esoui/art/chatwindow/chat_notification_disabled.dds",
	"/esoui/art/chatwindow/chat_notification_down.dds",
	"/esoui/art/chatwindow/chat_notification_echo.dds",
	"/esoui/art/chatwindow/chat_notification_glow.dds",
	"/esoui/art/chatwindow/chat_notification_over.dds",
	"/esoui/art/chatwindow/chat_notification_up.dds",
	"/esoui/art/chatwindow/chat_options_down.dds",
	"/esoui/art/chatwindow/chat_options_over.dds",
	"/esoui/art/chatwindow/chat_options_up.dds",
	"/esoui/art/chatwindow/chat_overflowarrow_down.dds",
	"/esoui/art/chatwindow/chat_overflowarrow_over.dds",
	"/esoui/art/chatwindow/chat_overflowarrow_up.dds",
	"/esoui/art/chatwindow/chat_scrollbar_track.dds",
	"/esoui/art/chatwindow/chat_thumb.dds",
	"/esoui/art/chatwindow/chat_thumb_disabled.dds",
	"/esoui/art/chatwindow/tabicon_chatcolors_inactive.dds",
	"/esoui/art/chatwindow/tabicon_chatoptions_inactive.dds",
	"/esoui/art/compass/area2frameanim_assisted_center.dds",
	"/esoui/art/compass/area2frameanim_assisted_endcap.dds",
	"/esoui/art/compass/area2frameanim_centers.dds",
	"/esoui/art/compass/area2frameanim_standard_center.dds",
	"/esoui/art/compass/area2frameanim_standard_endcap.dds",
	"/esoui/art/compass/areapin2frame_ends.dds",
	"/esoui/art/compass/compass.dds",
	"/esoui/art/compass/quest_areapin.dds",
	"/esoui/art/compass/quest_assistedareapin.dds",
	"/esoui/art/compass/quest_available_icon.dds",
	"/esoui/art/compass/quest_icon.dds",
	"/esoui/art/compass/quest_icon_assisted.dds",
	"/esoui/art/compass/quest_icon_door.dds",
	"/esoui/art/compass/quest_icon_door_assisted.dds",
	"/esoui/art/contacts/notificationicon_friend.dds",
	"/esoui/art/contacts/notificationicon_guild.dds",
	"/esoui/art/contacts/social_allianceicon_aldmeri.dds",
	"/esoui/art/contacts/social_allianceicon_daggerfall.dds",
	"/esoui/art/contacts/social_allianceicon_ebonheart.dds",
	"/esoui/art/contacts/social_classicon_dragonknight.dds",
	"/esoui/art/contacts/social_classicon_nightblade.dds",
	"/esoui/art/contacts/social_classicon_sorcerer.dds",
	"/esoui/art/contacts/social_classicon_templar.dds",
	"/esoui/art/contacts/social_list_bgstrip.dds",
	"/esoui/art/contacts/social_list_bgstrip_highlight.dds",
	"/esoui/art/contacts/social_note_down.dds",
	"/esoui/art/contacts/social_note_over.dds",
	"/esoui/art/contacts/social_note_up.dds",
	"/esoui/art/contacts/social_status_afk.dds",
	"/esoui/art/contacts/social_status_dnd.dds",
	"/esoui/art/contacts/social_status_highlight.dds",
	"/esoui/art/contacts/social_status_offline.dds",
	"/esoui/art/contacts/social_status_online.dds",
	"/esoui/art/contacts/tabicon_friends_down.dds",
	"/esoui/art/contacts/tabicon_friends_over.dds",
	"/esoui/art/contacts/tabicon_friends_up.dds",
	"/esoui/art/contacts/tabicon_ignored_down.dds",
	"/esoui/art/contacts/tabicon_ignored_over.dds",
	"/esoui/art/contacts/tabicon_ignored_up.dds",
	"/esoui/art/crafting/advance_mode_delevel.dds",
	"/esoui/art/crafting/advance_mode_freeze.dds",
	"/esoui/art/crafting/advance_mode_level.dds",
	"/esoui/art/crafting/alchemy_icon.dds",
	"/esoui/art/crafting/anvil_icon.dds",
	"/esoui/art/crafting/campfire_icon.dds",
	"/esoui/art/crafting/crafting_bg_bottom.dds",
	"/esoui/art/crafting/crafting_bg_top.dds",
	"/esoui/art/crafting/enchanter_icon.dds",
	"/esoui/art/crafting/header_bg_left.dds",
	"/esoui/art/crafting/header_bg_right.dds",
	"/esoui/art/crafting/itemslot_highlight.dds",
	"/esoui/art/crafting/raceicon_altmer_available.dds",
	"/esoui/art/crafting/raceicon_altmer_unavailable.dds",
	"/esoui/art/crafting/raceicon_argonian_available.dds",
	"/esoui/art/crafting/raceicon_argonian_unavailable.dds",
	"/esoui/art/crafting/raceicon_bosmer_available.dds",
	"/esoui/art/crafting/raceicon_bosmer_unavailable.dds",
	"/esoui/art/crafting/raceicon_breton_available.dds",
	"/esoui/art/crafting/raceicon_breton_unavailable.dds",
	"/esoui/art/crafting/raceicon_dunmer_available.dds",
	"/esoui/art/crafting/raceicon_dunmer_unavailable.dds",
	"/esoui/art/crafting/raceicon_imperial_available.dds",
	"/esoui/art/crafting/raceicon_imperial_unavailable.dds",
	"/esoui/art/crafting/raceicon_khajiit_available.dds",
	"/esoui/art/crafting/raceicon_khajiit_unavailable.dds",
	"/esoui/art/crafting/raceicon_mouseover_underlay.dds",
	"/esoui/art/crafting/raceicon_nord_available.dds",
	"/esoui/art/crafting/raceicon_nord_unavailable.dds",
	"/esoui/art/crafting/raceicon_orc_available.dds",
	"/esoui/art/crafting/raceicon_orc_unavailable.dds",
	"/esoui/art/crafting/raceicon_redguard_available.dds",
	"/esoui/art/crafting/raceicon_redguard_unavailable.dds",
	"/esoui/art/crafting/wizard_steplabel1_active.dds",
	"/esoui/art/crafting/wizard_steplabel1_inactive.dds",
	"/esoui/art/crafting/wizard_steplabel2_active.dds",
	"/esoui/art/crafting/wizard_steplabel2_inactive.dds",
	"/esoui/art/crafting/workbench_icon.dds",
	"/esoui/art/enchanting/enchanting_arrow.dds",
	"/esoui/art/enchanting/enchanting_highlight.dds",
	"/esoui/art/fishing/bait_emptyslot.dds",
	"/esoui/art/friends/friends_tabicon_friends_inactive.dds",
	"/esoui/art/friends/friends_tabicon_ignore_inactive.dds",
	"/esoui/art/guild/banner_aldmeri.dds",
	"/esoui/art/guild/banner_daggerfall.dds",
	"/esoui/art/guild/banner_ebonheart.dds",
	"/esoui/art/guild/guild_bankaccess.dds",
	"/esoui/art/guild/guild_indexicon_leader_down.dds",
	"/esoui/art/guild/guild_indexicon_leader_over.dds",
	"/esoui/art/guild/guild_indexicon_leader_up.dds",
	"/esoui/art/guild/guild_indexicon_member_down.dds",
	"/esoui/art/guild/guild_indexicon_member_over.dds",
	"/esoui/art/guild/guild_indexicon_member_up.dds",
	"/esoui/art/guild/guild_indexicon_officer_down.dds",
	"/esoui/art/guild/guild_indexicon_officer_over.dds",
	"/esoui/art/guild/guild_indexicon_officer_up.dds",
	"/esoui/art/guild/guild_indexicon_recruit_down.dds",
	"/esoui/art/guild/guild_indexicon_recruit_over.dds",
	"/esoui/art/guild/guild_indexicon_recruit_up.dds",
	"/esoui/art/guild/guild_rankicon_leader.dds",
	"/esoui/art/guild/guild_rankicon_leader_large.dds",
	"/esoui/art/guild/guild_rankicon_member.dds",
	"/esoui/art/guild/guild_rankicon_member_large.dds",
	"/esoui/art/guild/guild_rankicon_officer.dds",
	"/esoui/art/guild/guild_rankicon_officer_large.dds",
	"/esoui/art/guild/guild_rankicon_recruit.dds",
	"/esoui/art/guild/guild_rankicon_recruit_large.dds",
	"/esoui/art/guild/guild_tradinghouseaccess.dds",
	"/esoui/art/guild/guildbanner_icon_aldmeri.dds",
	"/esoui/art/guild/guildbanner_icon_daggerfall.dds",
	"/esoui/art/guild/guildbanner_icon_ebonheart.dds",
	"/esoui/art/guild/guildhistory_indexicon_campaigns_down.dds",
	"/esoui/art/guild/guildhistory_indexicon_campaigns_over.dds",
	"/esoui/art/guild/guildhistory_indexicon_campaigns_up.dds",
	"/esoui/art/guild/guildhistory_indexicon_guild_down.dds",
	"/esoui/art/guild/guildhistory_indexicon_guild_over.dds",
	"/esoui/art/guild/guildhistory_indexicon_guild_up.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildbank_down.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildbank_over.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildbank_up.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildstore_down.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildstore_over.dds",
	"/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds",
	"/esoui/art/guild/sectiondivider_left.dds",
	"/esoui/art/guild/sectiondivider_right.dds",
	"/esoui/art/guild/tabicon_history_disabled.dds",
	"/esoui/art/guild/tabicon_history_down.dds",
	"/esoui/art/guild/tabicon_history_over.dds",
	"/esoui/art/guild/tabicon_history_up.dds",
	"/esoui/art/guild/tabicon_home_disabled.dds",
	"/esoui/art/guild/tabicon_home_down.dds",
	"/esoui/art/guild/tabicon_home_over.dds",
	"/esoui/art/guild/tabicon_home_up.dds",
	"/esoui/art/guild/tabicon_ranks_disabled.dds",
	"/esoui/art/guild/tabicon_ranks_down.dds",
	"/esoui/art/guild/tabicon_ranks_over.dds",
	"/esoui/art/guild/tabicon_ranks_up.dds",
	"/esoui/art/guild/tabicon_roster_disabled.dds",
	"/esoui/art/guild/tabicon_roster_down.dds",
	"/esoui/art/guild/tabicon_roster_over.dds",
	"/esoui/art/guild/tabicon_roster_up.dds",
	"/esoui/art/hud/chargebar_frame.dds",
	"/esoui/art/hud/cloud.dds",
	"/esoui/art/hud/radialicon_addfriend_over.dds",
	"/esoui/art/hud/radialicon_addfriend_up.dds",
	"/esoui/art/hud/radialicon_cancel_over.dds",
	"/esoui/art/hud/radialicon_cancel_up.dds",
	"/esoui/art/hud/radialicon_invitegroup_over.dds",
	"/esoui/art/hud/radialicon_invitegroup_up.dds",
	"/esoui/art/hud/radialicon_trade_over.dds",
	"/esoui/art/hud/radialicon_trade_up.dds",
	"/esoui/art/hud/radialicon_whisper_over.dds",
	"/esoui/art/hud/radialicon_whisper_up.dds",
	"/esoui/art/hud/radialmenu_bg.dds",
	"/esoui/art/hud/radialmenu_bg_unselected.dds",
	"/esoui/art/hud/revivemeter_frame.dds",
	"/esoui/art/hud/revivemeter_progbar.dds",
	"/esoui/art/hud/starburst.dds",
	"/esoui/art/hud/xpbar_divider.dds",
	"/esoui/art/hud/xpbar_efxoverlay.dds",
	"/esoui/art/hud/xpbar_frame.dds",
	"/esoui/art/hud/xpbar_gridoverlay.dds",
	"/esoui/art/hud/xpbar_progbarbase.dds",
	"/esoui/art/interaction/conversation_textbg.dds",
	"/esoui/art/interaction/conversation_verticalborder.dds",
	"/esoui/art/inventory/inventory_all_tabicon_active.dds",
	"/esoui/art/inventory/inventory_all_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_all_tabicon_mouseover.dds",
	"/esoui/art/inventory/inventory_armor_tabicon_active.dds",
	"/esoui/art/inventory/inventory_armor_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_consumables_tabicon_active.dds",
	"/esoui/art/inventory/inventory_consumables_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_craft_tabicon_active.dds",
	"/esoui/art/inventory/inventory_craft_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_junk_tabicon_active.dds",
	"/esoui/art/inventory/inventory_junk_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_misc_tabicon_active.dds",
	"/esoui/art/inventory/inventory_misc_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_quest_tabicon_active.dds",
	"/esoui/art/inventory/inventory_quest_tabicon_inactive.dds",
	"/esoui/art/inventory/inventory_tabicon_all_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_all_down.dds",
	"/esoui/art/inventory/inventory_tabicon_all_over.dds",
	"/esoui/art/inventory/inventory_tabicon_all_up.dds",
	"/esoui/art/inventory/inventory_tabicon_armor_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_armor_down.dds",
	"/esoui/art/inventory/inventory_tabicon_armor_over.dds",
	"/esoui/art/inventory/inventory_tabicon_armor_up.dds",
	"/esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_consumables_down.dds",
	"/esoui/art/inventory/inventory_tabicon_consumables_over.dds",
	"/esoui/art/inventory/inventory_tabicon_consumables_up.dds",
	"/esoui/art/inventory/inventory_tabicon_crafting_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_crafting_down.dds",
	"/esoui/art/inventory/inventory_tabicon_crafting_over.dds",
	"/esoui/art/inventory/inventory_tabicon_crafting_up.dds",
	"/esoui/art/inventory/inventory_tabicon_junk_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_junk_down.dds",
	"/esoui/art/inventory/inventory_tabicon_junk_over.dds",
	"/esoui/art/inventory/inventory_tabicon_junk_up.dds",
	"/esoui/art/inventory/inventory_tabicon_misc_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_misc_down.dds",
	"/esoui/art/inventory/inventory_tabicon_misc_over.dds",
	"/esoui/art/inventory/inventory_tabicon_misc_up.dds",
	"/esoui/art/inventory/inventory_tabicon_quest_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_quest_down.dds",
	"/esoui/art/inventory/inventory_tabicon_quest_over.dds",
	"/esoui/art/inventory/inventory_tabicon_quest_up.dds",
	"/esoui/art/inventory/inventory_tabicon_quickslot_down.dds",
	"/esoui/art/inventory/inventory_tabicon_quickslot_over.dds",
	"/esoui/art/inventory/inventory_tabicon_quickslot_up.dds",
	"/esoui/art/inventory/inventory_tabicon_weapons_disabled.dds",
	"/esoui/art/inventory/inventory_tabicon_weapons_down.dds",
	"/esoui/art/inventory/inventory_tabicon_weapons_over.dds",
	"/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
	"/esoui/art/inventory/inventory_weapons_tabicon_active.dds",
	"/esoui/art/inventory/inventory_weapons_tabicon_inactive.dds",
	"/esoui/art/inventory/newitem_icon.dds",
	"/esoui/art/itemtooltip/item_chargemeter.dds",
	"/esoui/art/itemtooltip/simpleprogbarbg_center.dds",
	"/esoui/art/itemtooltip/simpleprogbarbg_edge.dds",
	"/esoui/art/journal/journal_tabicon_achievements_disabled.dds",
	"/esoui/art/journal/journal_tabicon_achievements_down.dds",
	"/esoui/art/journal/journal_tabicon_achievements_over.dds",
	"/esoui/art/journal/journal_tabicon_achievements_up.dds",
	"/esoui/art/journal/journal_tabicon_lorelibrary_disabled.dds",
	"/esoui/art/journal/journal_tabicon_lorelibrary_down.dds",
	"/esoui/art/journal/journal_tabicon_lorelibrary_over.dds",
	"/esoui/art/journal/journal_tabicon_lorelibrary_up.dds",
	"/esoui/art/journal/journal_tabicon_quest_disabled.dds",
	"/esoui/art/journal/journal_tabicon_quest_down.dds",
	"/esoui/art/journal/journal_tabicon_quest_over.dds",
	"/esoui/art/journal/journal_tabicon_quest_up.dds",
	"/esoui/art/lfg/lfg_dps_down.dds",
	"/esoui/art/lfg/lfg_dps_over.dds",
	"/esoui/art/lfg/lfg_dps_up.dds",
	"/esoui/art/lfg/lfg_healer_down.dds",
	"/esoui/art/lfg/lfg_healer_over.dds",
	"/esoui/art/lfg/lfg_healer_up.dds",
	"/esoui/art/lfg/lfg_leader_icon.dds",
	"/esoui/art/lfg/lfg_tabicon_grouptools_disabled.dds",
	"/esoui/art/lfg/lfg_tabicon_grouptools_down.dds",
	"/esoui/art/lfg/lfg_tabicon_grouptools_over.dds",
	"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds",
	"/esoui/art/lfg/lfg_tabicon_mygroup_disabled.dds",
	"/esoui/art/lfg/lfg_tabicon_mygroup_down.dds",
	"/esoui/art/lfg/lfg_tabicon_mygroup_over.dds",
	"/esoui/art/lfg/lfg_tabicon_mygroup_up.dds",
	"/esoui/art/lfg/lfg_tank_down.dds",
	"/esoui/art/lfg/lfg_tank_over.dds",
	"/esoui/art/lfg/lfg_tank_up.dds",
	"/esoui/art/lockpicking/lock_body.dds",
	"/esoui/art/lockpicking/lock_mask.dds",
	"/esoui/art/lockpicking/lock_pick.dds",
	"/esoui/art/lockpicking/lock_pick_broken_left.dds",
	"/esoui/art/lockpicking/lock_pick_broken_right.dds",
	"/esoui/art/lockpicking/lock_tensioner_bottom.dds",
	"/esoui/art/lockpicking/lock_tensioner_top.dds",
	"/esoui/art/lockpicking/pins.dds",
	"/esoui/art/lockpicking/pins_over.dds",
	"/esoui/art/lockpicking/pins_set.dds",
	"/esoui/art/lockpicking/spring_01.dds",
	"/esoui/art/lockpicking/spring_02.dds",
	"/esoui/art/lockpicking/spring_03.dds",
	"/esoui/art/lockpicking/spring_04.dds",
	"/esoui/art/lockpicking/spring_05.dds",
	"/esoui/art/login/loginannouncement_bg_bottom.dds",
	"/esoui/art/login/loginannouncement_bg_top.dds",
	"/esoui/art/login/loginannouncement_divider.dds",
	"/esoui/art/login/loginbg.dds",
	"/esoui/art/loot/loot_finesseitem.dds",
	"/esoui/art/lorelibrary/lorelibrary_bg_left.dds",
	"/esoui/art/lorelibrary/lorelibrary_bg_right.dds",
	"/esoui/art/lorelibrary/lorelibrary_letter.dds",
	"/esoui/art/lorelibrary/lorelibrary_note.dds",
	"/esoui/art/lorelibrary/lorelibrary_paperbook.dds",
	"/esoui/art/lorelibrary/lorelibrary_rubbingbook.dds",
	"/esoui/art/lorelibrary/lorelibrary_scroll.dds",
	"/esoui/art/lorelibrary/lorelibrary_skinbook.dds",
	"/esoui/art/lorelibrary/lorelibrary_stonetablet.dds",
	"/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds",
	"/esoui/art/mail/mail_inbox_readmessage.dds",
	"/esoui/art/mail/mail_inbox_returned.dds",
	"/esoui/art/mail/mail_inbox_unreadmessage.dds",
	"/esoui/art/mainmenu/menubar_ava_disabled.dds",
	"/esoui/art/mainmenu/menubar_ava_down.dds",
	"/esoui/art/mainmenu/menubar_ava_over.dds",
	"/esoui/art/mainmenu/menubar_ava_up.dds",
	"/esoui/art/mainmenu/menubar_character_disabled.dds",
	"/esoui/art/mainmenu/menubar_character_down.dds",
	"/esoui/art/mainmenu/menubar_character_over.dds",
	"/esoui/art/mainmenu/menubar_character_up.dds",
	"/esoui/art/mainmenu/menubar_inventory_disabled.dds",
	"/esoui/art/mainmenu/menubar_inventory_down.dds",
	"/esoui/art/mainmenu/menubar_inventory_over.dds",
	"/esoui/art/mainmenu/menubar_inventory_up.dds",
	"/esoui/art/mainmenu/menubar_journal_disabled.dds",
	"/esoui/art/mainmenu/menubar_journal_down.dds",
	"/esoui/art/mainmenu/menubar_journal_over.dds",
	"/esoui/art/mainmenu/menubar_journal_up.dds",
	"/esoui/art/mainmenu/menubar_map_disabled.dds",
	"/esoui/art/mainmenu/menubar_map_down.dds",
	"/esoui/art/mainmenu/menubar_map_over.dds",
	"/esoui/art/mainmenu/menubar_map_up.dds",
	"/esoui/art/mainmenu/menubar_social_disabled.dds",
	"/esoui/art/mainmenu/menubar_social_down.dds",
	"/esoui/art/mainmenu/menubar_social_over.dds",
	"/esoui/art/mainmenu/menubar_social_up.dds",
	"/esoui/art/mainmenu/menubar_system_disabled.dds",
	"/esoui/art/mainmenu/menubar_system_down.dds",
	"/esoui/art/mainmenu/menubar_system_over.dds",
	"/esoui/art/mainmenu/menubar_system_up.dds",
	"/esoui/art/mappins/ava_3way.dds",
	"/esoui/art/mappins/ava_artifact_almaruma.dds",
	"/esoui/art/mappins/ava_artifact_altadoon.dds",
	"/esoui/art/mappins/ava_artifact_chim.dds",
	"/esoui/art/mappins/ava_artifact_ghartok.dds",
	"/esoui/art/mappins/ava_artifact_mnem.dds",
	"/esoui/art/mappins/ava_artifact_nimohk.dds",
	"/esoui/art/mappins/ava_artifactgate_aldmeri_closed.dds",
	"/esoui/art/mappins/ava_artifactgate_aldmeri_open.dds",
	"/esoui/art/mappins/ava_artifactgate_daggerfall_closed.dds",
	"/esoui/art/mappins/ava_artifactgate_daggerfall_open.dds",
	"/esoui/art/mappins/ava_artifactgate_ebonheart_closed.dds",
	"/esoui/art/mappins/ava_artifactgate_ebonheart_open.dds",
	"/esoui/art/mappins/ava_artifacttemple_aldmeri.dds",
	"/esoui/art/mappins/ava_artifacttemple_aldmeril_underattack.dds",
	"/esoui/art/mappins/ava_artifacttemple_daggerfall.dds",
	"/esoui/art/mappins/ava_artifacttemple_daggerfall_underattack.dds",
	"/esoui/art/mappins/ava_artifacttemple_ebonheart.dds",
	"/esoui/art/mappins/ava_artifacttemple_ebonheart_underattack.dds",
	"/esoui/art/mappins/ava_attackburst_32.dds",
	"/esoui/art/mappins/ava_attackburst_64.dds",
	"/esoui/art/mappins/ava_borderkeep_linked_backdrop.dds",
	"/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds",
	"/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds",
	"/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds",
	"/esoui/art/mappins/ava_cemetary_aldmeri.dds",
	"/esoui/art/mappins/ava_cemetary_daggerfall.dds",
	"/esoui/art/mappins/ava_cemetary_ebonheart.dds",
	"/esoui/art/mappins/ava_cemetary_linked_backdrop.dds",
	"/esoui/art/mappins/ava_keep_linked_backdrop.dds",
	"/esoui/art/mappins/ava_keeptransitselection.dds",
	"/esoui/art/mappins/ava_largekeep_aldmeri.dds",
	"/esoui/art/mappins/ava_largekeep_aldmeri_underattack.dds",
	"/esoui/art/mappins/ava_largekeep_daggerfall.dds",
	"/esoui/art/mappins/ava_largekeep_daggerfall_underattack.dds",
	"/esoui/art/mappins/ava_largekeep_ebonheart.dds",
	"/esoui/art/mappins/ava_largekeep_ebonheart_underattack.dds",
	"/esoui/art/mappins/ava_largekeep_neutral.dds",
	"/esoui/art/mappins/ava_largekeep_neutral_underattack.dds",
	"/esoui/art/mappins/ava_outpost_aldmeri.dds",
	"/esoui/art/mappins/ava_outpost_daggerfall.dds",
	"/esoui/art/mappins/ava_outpost_ebonheart.dds",
	"/esoui/art/mappins/ava_outpost_linked_backdrop.dds",
	"/esoui/art/mappins/ava_outpost_neutral.dds",
	"/esoui/art/mappins/ava_transitlink_aldmeri.dds",
	"/esoui/art/mappins/ava_transitlink_daggerfall.dds",
	"/esoui/art/mappins/ava_transitlink_ebonheart.dds",
	"/esoui/art/mappins/compassvendor.dds",
	"/esoui/art/mappins/follower_pin.dds",
	"/esoui/art/mappins/group_pin.dds",
	"/esoui/art/mappins/hostile_pin.dds",
	"/esoui/art/mappins/mapping.dds",
	"/esoui/art/mappins/mappingarrow.dds",
	"/esoui/art/mappins/maprallypoint.dds",
	"/esoui/art/mappins/maprallypointarrow.dds",
	"/esoui/art/mappins/minimap_bank.dds",
	"/esoui/art/mappins/poi_wayshrine_glow.dds",
	"/esoui/art/mappins/questpin.dds",
	"/esoui/art/mappins/questpin_above.dds",
	"/esoui/art/mappins/questpin_below.dds",
	"/esoui/art/mappins/questpin_glow.dds",
	"/esoui/art/mappins/questpinassisted.dds",
	"/esoui/art/mappins/questpinassisted_above.dds",
	"/esoui/art/mappins/questpinassisted_below.dds",
	"/esoui/art/mappins/travel_aldmerilwayshrine.dds",
	"/esoui/art/mappins/travel_daggerfallwayshrine.dds",
	"/esoui/art/mappins/travel_ebonheartfallwayshrine.dds",
	"/esoui/art/mappins/travel_wayshrine.dds",
	"/esoui/art/mappins/travel_wayshrine_currentloc.dds",
	"/esoui/art/mappins/travel_wayshrine_unavailable.dds",
	"/esoui/art/mappins/ui-worldmapplayercamerapip.dds",
	"/esoui/art/mappins/wayshrine.dds",
	"/esoui/art/mappins/wayshrine_undiscovered.dds",
	"/esoui/art/menubar/button_flash.dds",
	"/esoui/art/menubar/icon_highlight.dds",
	"/esoui/art/menubar/menubar_character_down.dds",
	"/esoui/art/menubar/menubar_character_over.dds",
	"/esoui/art/menubar/menubar_character_up.dds",
	"/esoui/art/menubar/menubar_inventory_down.dds",
	"/esoui/art/menubar/menubar_inventory_over.dds",
	"/esoui/art/menubar/menubar_inventory_up.dds",
	"/esoui/art/menubar/menubar_levelup_announce_down.dds",
	"/esoui/art/menubar/menubar_levelup_announce_over.dds",
	"/esoui/art/menubar/menubar_levelup_announce_up.dds",
	"/esoui/art/menubar/menubar_levelup_down.dds",
	"/esoui/art/menubar/menubar_levelup_over.dds",
	"/esoui/art/menubar/menubar_levelup_up.dds",
	"/esoui/art/menubar/menubar_mail_announce_down.dds",
	"/esoui/art/menubar/menubar_mail_announce_over.dds",
	"/esoui/art/menubar/menubar_mail_announce_up.dds",
	"/esoui/art/menubar/menubar_mail_down.dds",
	"/esoui/art/menubar/menubar_mail_over.dds",
	"/esoui/art/menubar/menubar_mail_up.dds",
	"/esoui/art/menubar/menubar_mainmenu_down.dds",
	"/esoui/art/menubar/menubar_mainmenu_over.dds",
	"/esoui/art/menubar/menubar_mainmenu_up.dds",
	"/esoui/art/menubar/menubar_quests_down.dds",
	"/esoui/art/menubar/menubar_quests_over.dds",
	"/esoui/art/menubar/menubar_quests_up.dds",
	"/esoui/art/menubar/menubar_social_down.dds",
	"/esoui/art/menubar/menubar_social_over.dds",
	"/esoui/art/menubar/menubar_social_up.dds",
	"/esoui/art/menubar/menubar_temp_down.dds",
	"/esoui/art/menubar/menubar_temp_over.dds",
	"/esoui/art/menubar/menubar_temp_up.dds",
	"/esoui/art/minimap/assisted_map_pin_above.dds",
	"/esoui/art/minimap/assisted_map_pin_below.dds",
	"/esoui/art/minimap/minimap_bracket.dds",
	"/esoui/art/minimap/minimap_filter_disabled.dds",
	"/esoui/art/minimap/minimap_frame_bottomleft.dds",
	"/esoui/art/minimap/minimap_frame_bottomright.dds",
	"/esoui/art/minimap/minimap_frame_topleft.dds",
	"/esoui/art/minimap/minimap_frame_topright.dds",
	"/esoui/art/minimap/minimap_lfg_disabled.dds",
	"/esoui/art/minimap/minimap_lfg_down.dds",
	"/esoui/art/minimap/minimap_lfg_up.dds",
	"/esoui/art/minimap/minimap_maximize_down.dds",
	"/esoui/art/minimap/minimap_maximize_up.dds",
	"/esoui/art/minimap/minimap_minimize_down.dds",
	"/esoui/art/minimap/minimap_minimize_up.dds",
	"/esoui/art/minimap/minimap_recall_disabled.dds",
	"/esoui/art/minimap/minimap_recall_down.dds",
	"/esoui/art/minimap/minimap_recall_up.dds",
	"/esoui/art/miscellaneous/announce_icon_frame.dds",
	"/esoui/art/miscellaneous/announce_icon_levelup.dds",
	"/esoui/art/miscellaneous/borderedinset_center.dds",
	"/esoui/art/miscellaneous/borderedinset_edgefile.dds",
	"/esoui/art/miscellaneous/borderedinsettransparent_edgefile.dds",
	"/esoui/art/miscellaneous/bottom_bar.dds",
	"/esoui/art/miscellaneous/bullet.dds",
	"/esoui/art/miscellaneous/centerscreen_indexarea_left.dds",
	"/esoui/art/miscellaneous/centerscreen_indexarea_right.dds",
	"/esoui/art/miscellaneous/centerscreen_left.dds",
	"/esoui/art/miscellaneous/centerscreen_right.dds",
	"/esoui/art/miscellaneous/centerscreen_topdivider.dds",
	"/esoui/art/miscellaneous/dialog_scrollinset_left.dds",
	"/esoui/art/miscellaneous/dialog_scrollinset_right.dds",
	"/esoui/art/miscellaneous/dropdown_center.dds",
	"/esoui/art/miscellaneous/dropdown_edge.dds",
	"/esoui/art/miscellaneous/help_icon.dds",
	"/esoui/art/miscellaneous/horizontaldivider.dds",
	"/esoui/art/miscellaneous/icon_cmb.dds",
	"/esoui/art/miscellaneous/icon_highlight_pulse.dds",
	"/esoui/art/miscellaneous/icon_keys.dds",
	"/esoui/art/miscellaneous/icon_lmb.dds",
	"/esoui/art/miscellaneous/icon_lmbrmb.dds",
	"/esoui/art/miscellaneous/icon_rmb.dds",
	"/esoui/art/miscellaneous/inset_bg.dds",
	"/esoui/art/miscellaneous/inset_center.dds",
	"/esoui/art/miscellaneous/inset_edgefile.dds",
	"/esoui/art/miscellaneous/insethighlight_center.dds",
	"/esoui/art/miscellaneous/insethighlight_edge.dds",
	"/esoui/art/miscellaneous/interactkeyframe_center.dds",
	"/esoui/art/miscellaneous/interactkeyframe_center_4x32_down.dds",
	"/esoui/art/miscellaneous/interactkeyframe_center_4x32_over.dds",
	"/esoui/art/miscellaneous/interactkeyframe_center_down.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge_4x32.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge_4x32_down.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge_4x32_over.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge_down.dds",
	"/esoui/art/miscellaneous/interactkeyframe_edge_over.dds",
	"/esoui/art/miscellaneous/key_edgefile.dds",
	"/esoui/art/miscellaneous/list_sortdown.dds",
	"/esoui/art/miscellaneous/list_sortheader_icon_neutral.dds",
	"/esoui/art/miscellaneous/list_sortheader_icon_over.dds",
	"/esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds",
	"/esoui/art/miscellaneous/list_sortheader_icon_sortup.dds",
	"/esoui/art/miscellaneous/list_sortup.dds",
	"/esoui/art/miscellaneous/listitem_backdrop.dds",
	"/esoui/art/miscellaneous/listitem_highlight.dds",
	"/esoui/art/miscellaneous/listitem_selectedhighlight.dds",
	"/esoui/art/miscellaneous/locked_down.dds",
	"/esoui/art/miscellaneous/locked_over.dds",
	"/esoui/art/miscellaneous/locked_up.dds",
	"/esoui/art/miscellaneous/progressbar_frame.dds",
	"/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds",
	"/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_blunt.dds",
	"/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds",
	"/esoui/art/miscellaneous/progressbar_texture_overlay.dds",
	"/esoui/art/miscellaneous/rightpanel_bg_left.dds",
	"/esoui/art/miscellaneous/rightpanel_bg_right.dds",
	"/esoui/art/miscellaneous/scrollbox_track.dds",
	"/esoui/art/miscellaneous/search_icon.dds",
	"/esoui/art/miscellaneous/singlelinesection_left.dds",
	"/esoui/art/miscellaneous/singlelinesection_right.dds",
	"/esoui/art/miscellaneous/slottingframe_vertical_bottom.dds",
	"/esoui/art/miscellaneous/slottingframe_vertical_middle.dds",
	"/esoui/art/miscellaneous/slottingframe_vertical_top.dds",
	"/esoui/art/miscellaneous/spinnerarrow_left_over.dds",
	"/esoui/art/miscellaneous/spinnerarrow_right_over.dds",
	"/esoui/art/miscellaneous/spinnerbg_left.dds",
	"/esoui/art/miscellaneous/spinnerbg_right.dds",
	"/esoui/art/miscellaneous/spinnerminus_disabled.dds",
	"/esoui/art/miscellaneous/spinnerminus_down.dds",
	"/esoui/art/miscellaneous/spinnerminus_over.dds",
	"/esoui/art/miscellaneous/spinnerminus_up.dds",
	"/esoui/art/miscellaneous/spinnerplus_disabled.dds",
	"/esoui/art/miscellaneous/spinnerplus_down.dds",
	"/esoui/art/miscellaneous/spinnerplus_over.dds",
	"/esoui/art/miscellaneous/spinnerplus_up.dds",
	"/esoui/art/miscellaneous/textentry_highlight_edge.dds",
	"/esoui/art/miscellaneous/titledeco_left.dds",
	"/esoui/art/miscellaneous/titledeco_right.dds",
	"/esoui/art/miscellaneous/top_bar.dds",
	"/esoui/art/miscellaneous/tutorial_highlight_edge.dds",
	"/esoui/art/miscellaneous/unlocked_down.dds",
	"/esoui/art/miscellaneous/unlocked_over.dds",
	"/esoui/art/miscellaneous/unlocked_up.dds",
	"/esoui/art/miscellaneous/wait_icon.dds",
	"/esoui/art/miscellaneous/wide_divider_left.dds",
	"/esoui/art/miscellaneous/wide_divider_right.dds",
	"/esoui/art/miscellaneous/window_bg_falloff.dds",
	"/esoui/art/miscellaneous/window_edge.dds",
	"/esoui/art/mounts/activemount_icon.dds",
	"/esoui/art/mounts/feed_icon.dds",
	"/esoui/art/mounts/mountportait_empty.dds",
	"/esoui/art/mounts/mounts_apple_disabled.dds",
	"/esoui/art/mounts/mounts_apple_down.dds",
	"/esoui/art/mounts/mounts_apple_over.dds",
	"/esoui/art/mounts/mounts_apple_up.dds",
	"/esoui/art/mounts/mounts_hay_disabled.dds",
	"/esoui/art/mounts/mounts_hay_down.dds",
	"/esoui/art/mounts/mounts_hay_over.dds",
	"/esoui/art/mounts/mounts_hay_up.dds",
	"/esoui/art/mounts/mounts_oats_disabled.dds",
	"/esoui/art/mounts/mounts_oats_down.dds",
	"/esoui/art/mounts/mounts_oats_over.dds",
	"/esoui/art/mounts/mounts_oats_up.dds",
	"/esoui/art/mounts/tabicon_mounts_disabled.dds",
	"/esoui/art/mounts/tabicon_mounts_down.dds",
	"/esoui/art/mounts/tabicon_mounts_over.dds",
	"/esoui/art/mounts/tabicon_mounts_up.dds",
	"/esoui/art/mounts/timer_icon.dds",
	"/esoui/art/mounts/timer_overlay.dds",
	"/esoui/art/perks/perks_tabicon_battle_inactive.dds",
	"/esoui/art/perks/perks_tabicon_inherent_inactive.dds",
	"/esoui/art/perks/perks_tabicon_social_inactive.dds",
	"/esoui/art/progression/ability_line.dds",
	"/esoui/art/progression/ability_tree_left.dds",
	"/esoui/art/progression/ability_tree_right.dds",
	"/esoui/art/progression/abilitybar_divider.dds",
	"/esoui/art/progression/abilityframe_empty.dds",
	"/esoui/art/progression/abilityframe_filled.dds",
	"/esoui/art/progression/addpoints_down.dds",
	"/esoui/art/progression/addpoints_over.dds",
	"/esoui/art/progression/addpoints_up.dds",
	"/esoui/art/progression/headerbg.dds",
	"/esoui/art/progression/health_points_frame.dds",
	"/esoui/art/progression/icon_1handed.dds",
	"/esoui/art/progression/icon_1handplusrune.dds",
	"/esoui/art/progression/icon_2handed.dds",
	"/esoui/art/progression/icon_alchemist.dds",
	"/esoui/art/progression/icon_armorsmith.dds",
	"/esoui/art/progression/icon_bows.dds",
	"/esoui/art/progression/icon_dualwield.dds",
	"/esoui/art/progression/icon_enchanter.dds",
	"/esoui/art/progression/icon_firestaff.dds",
	"/esoui/art/progression/icon_healstaff.dds",
	"/esoui/art/progression/icon_icestaff.dds",
	"/esoui/art/progression/icon_lightningstaff.dds",
	"/esoui/art/progression/icon_provisioner.dds",
	"/esoui/art/progression/icon_weaponsmith.dds",
	"/esoui/art/progression/levelup_progbar_frame.dds",
	"/esoui/art/progression/list_header_bg.dds",
	"/esoui/art/progression/lock.dds",
	"/esoui/art/progression/magicka_points_frame.dds",
	"/esoui/art/progression/morph_disabled.dds",
	"/esoui/art/progression/morph_down.dds",
	"/esoui/art/progression/morph_graphic.dds",
	"/esoui/art/progression/morph_over.dds",
	"/esoui/art/progression/morph_up.dds",
	"/esoui/art/progression/passiveability_frame_bottom.dds",
	"/esoui/art/progression/passiveability_frame_top.dds",
	"/esoui/art/progression/progression_crafting_1stentry_bg.dds",
	"/esoui/art/progression/progression_crafting_delevel_down.dds",
	"/esoui/art/progression/progression_crafting_delevel_over.dds",
	"/esoui/art/progression/progression_crafting_delevel_up.dds",
	"/esoui/art/progression/progression_crafting_entry_bg.dds",
	"/esoui/art/progression/progression_crafting_locked_down.dds",
	"/esoui/art/progression/progression_crafting_locked_over.dds",
	"/esoui/art/progression/progression_crafting_locked_up.dds",
	"/esoui/art/progression/progression_crafting_unlocked_down.dds",
	"/esoui/art/progression/progression_crafting_unlocked_over.dds",
	"/esoui/art/progression/progression_crafting_unlocked_up.dds",
	"/esoui/art/progression/progression_indexicon_armor_down.dds",
	"/esoui/art/progression/progression_indexicon_armor_over.dds",
	"/esoui/art/progression/progression_indexicon_armor_up.dds",
	"/esoui/art/progression/progression_indexicon_ava_down.dds",
	"/esoui/art/progression/progression_indexicon_ava_over.dds",
	"/esoui/art/progression/progression_indexicon_ava_up.dds",
	"/esoui/art/progression/progression_indexicon_class_down.dds",
	"/esoui/art/progression/progression_indexicon_class_over.dds",
	"/esoui/art/progression/progression_indexicon_class_up.dds",
	"/esoui/art/progression/progression_indexicon_guilds_down.dds",
	"/esoui/art/progression/progression_indexicon_guilds_over.dds",
	"/esoui/art/progression/progression_indexicon_guilds_up.dds",
	"/esoui/art/progression/progression_indexicon_race_down.dds",
	"/esoui/art/progression/progression_indexicon_race_over.dds",
	"/esoui/art/progression/progression_indexicon_race_up.dds",
	"/esoui/art/progression/progression_indexicon_weapons_down.dds",
	"/esoui/art/progression/progression_indexicon_weapons_over.dds",
	"/esoui/art/progression/progression_indexicon_weapons_up.dds",
	"/esoui/art/progression/progression_indexicon_world_down.dds",
	"/esoui/art/progression/progression_indexicon_world_over.dds",
	"/esoui/art/progression/progression_indexicon_world_up.dds",
	"/esoui/art/progression/progression_progbar_genericfill.dds",
	"/esoui/art/progression/progression_progbar_leadingedge.dds",
	"/esoui/art/progression/progression_tabicon_active_active.dds",
	"/esoui/art/progression/progression_tabicon_active_inactive.dds",
	"/esoui/art/progression/progression_tabicon_backup_active.dds",
	"/esoui/art/progression/progression_tabicon_backup_inactive.dds",
	"/esoui/art/progression/progression_tabicon_backup_over.dds",
	"/esoui/art/progression/progression_tabicon_combatskills_down.dds",
	"/esoui/art/progression/progression_tabicon_combatskills_over.dds",
	"/esoui/art/progression/progression_tabicon_combatskills_up.dds",
	"/esoui/art/progression/progression_tabicon_passive_active.dds",
	"/esoui/art/progression/progression_tabicon_passive_inactive.dds",
	"/esoui/art/progression/progression_tabicon_tradeskills_down.dds",
	"/esoui/art/progression/progression_tabicon_tradeskills_over.dds",
	"/esoui/art/progression/progression_tabicon_tradeskills_up.dds",
	"/esoui/art/progression/progression_tabicon_weapons_active.dds",
	"/esoui/art/progression/progression_tabicon_weapons_inactive.dds",
	"/esoui/art/progression/skillpoint_header_bg.dds",
	"/esoui/art/progression/skyshard_1.dds",
	"/esoui/art/progression/skyshard_2.dds",
	"/esoui/art/progression/skyshard_3.dds",
	"/esoui/art/progression/skyshard_base.dds",
	"/esoui/art/progression/stamina_points_frame.dds",
	"/esoui/art/quest/map_configure_disabled.dds",
	"/esoui/art/quest/map_configure_down.dds",
	"/esoui/art/quest/map_configure_up.dds",
	"/esoui/art/quest/quest_abandon_disabled.dds",
	"/esoui/art/quest/quest_abandon_down.dds",
	"/esoui/art/quest/quest_abandon_up.dds",
	"/esoui/art/quest/quest_assist_down.dds",
	"/esoui/art/quest/quest_assist_up.dds",
	"/esoui/art/quest/quest_share_disabled.dds",
	"/esoui/art/quest/quest_share_down.dds",
	"/esoui/art/quest/quest_share_up.dds",
	"/esoui/art/quest/quest_showonmap_disabled.dds",
	"/esoui/art/quest/quest_showonmap_down.dds",
	"/esoui/art/quest/quest_showonmap_up.dds",
	"/esoui/art/quest/quest_track_disabled.dds",
	"/esoui/art/quest/quest_track_down.dds",
	"/esoui/art/quest/quest_track_up.dds",
	"/esoui/art/quest/quest_untrack_disabled.dds",
	"/esoui/art/quest/quest_untrack_down.dds",
	"/esoui/art/quest/quest_untrack_up.dds",
	"/esoui/art/quest/questjournal_divider.dds",
	"/esoui/art/quest/questjournal_inset_left.dds",
	"/esoui/art/quest/questjournal_inset_right.dds",
	"/esoui/art/quest/questjournal_trackedquest_icon.dds",
	"/esoui/art/quest/tracked_pin.dds",
	"/esoui/art/quest/tracker_currentquest_bullet.dds",
	"/esoui/art/quickslots/quickslot_dragslot.dds",
	"/esoui/art/quickslots/quickslot_emptyslot.dds",
	"/esoui/art/quickslots/quickslot_highlight_blob.dds",
	"/esoui/art/quickslots/quickslot_mapping_bg.dds",
	"/esoui/art/repair/inventory_tabicon_repair_disabled.dds",
	"/esoui/art/repair/inventory_tabicon_repair_down.dds",
	"/esoui/art/repair/inventory_tabicon_repair_over.dds",
	"/esoui/art/repair/inventory_tabicon_repair_up.dds",
	"/esoui/art/reticle/crosshair_mousedown.dds",
	"/esoui/art/reticle/crosshairred_mousedown.dds",
	"/esoui/art/reticle/preferred_crosshair_mousedown.dds",
	"/esoui/art/reticle/preferred_crosshairred_mousedown.dds",
	"/esoui/art/reticle/reticle_mousedown.dds",
	"/esoui/art/reticle/reticlered_mousedown.dds",
	"/esoui/art/screens/loadingbar_center.dds",
	"/esoui/art/screens/loadingbar_edge.dds",
	"/esoui/art/screens/loadingbar_fill.dds",
	"/esoui/art/screens/loadscreen_bottommunge_tile.dds",
	"/esoui/art/screens/loadscreen_title.dds",
	"/esoui/art/screens/loadscreen_topmunge_tile.dds",
	"/esoui/art/screens/munge_overlay.dds",
	"/esoui/art/stealth/stealth_64.dds",
	"/esoui/art/tabs/bottom_tab_active.dds",
	"/esoui/art/tabs/bottom_tab_highlightblob.dds",
	"/esoui/art/tabs/bottom_tab_inactive.dds",
	"/esoui/art/tabs/bottom_tab_inactive_mousedown.dds",
	"/esoui/art/tabs/bottom_tab_inactive_mouseover.dds",
	"/esoui/art/tabs/tab_chat_active.dds",
	"/esoui/art/tabs/tab_top_active.dds",
	"/esoui/art/tabs/tab_top_highlightblob.dds",
	"/esoui/art/tabs/tab_top_inactive.dds",
	"/esoui/art/tabs/tab_top_inactive_disabled.dds",
	"/esoui/art/tabs/tab_top_inactive_mousedown.dds",
	"/esoui/art/tabs/tab_top_inactive_mouseover.dds",
	"/esoui/art/tooltips/arrow_down.dds",
	"/esoui/art/tooltips/arrow_up.dds",
	"/esoui/art/tooltips/munge_overlay.dds",
	"/esoui/art/tooltips/tooltip_downarrow.dds",
	"/esoui/art/tooltips/tooltip_leftarrow.dds",
	"/esoui/art/tooltips/tooltip_rightarrow.dds",
	"/esoui/art/tooltips/tooltip_uparrow.dds",
	"/esoui/art/tradewindow/trade_acceptoverlay_top.dds",
	"/esoui/art/tradinghouse/tradinghouse_browse_tabicon_disabled.dds",
	"/esoui/art/tradinghouse/tradinghouse_browse_tabicon_down.dds",
	"/esoui/art/tradinghouse/tradinghouse_browse_tabicon_over.dds",
	"/esoui/art/tradinghouse/tradinghouse_browse_tabicon_up.dds",
	"/esoui/art/tradinghouse/tradinghouse_divider_short.dds",
	"/esoui/art/tradinghouse/tradinghouse_emptysellslot_icon.dds",
	"/esoui/art/tradinghouse/tradinghouse_itemicon_highlightbg.dds",
	"/esoui/art/tradinghouse/tradinghouse_listings_tabicon_disabled.dds",
	"/esoui/art/tradinghouse/tradinghouse_listings_tabicon_down.dds",
	"/esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds",
	"/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
	"/esoui/art/tradinghouse/tradinghouse_sell_tabicon_disabled.dds",
	"/esoui/art/tradinghouse/tradinghouse_sell_tabicon_down.dds",
	"/esoui/art/tradinghouse/tradinghouse_sell_tabicon_over.dds",
	"/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
	"/esoui/art/tradinghouse/tradinghouse_sellblock-bghighlight_bottom.dds",
	"/esoui/art/tradinghouse/tradinghouse_sellblock-bghighlight_top.dds",
	"/esoui/art/tutorial/tutorial_hud_windowbg.dds",
	"/esoui/art/unitattributevisualizer/attributebar_arrow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_bg.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_large.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_large_glow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_small.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_small_glow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_standard.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_standard_glow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedpower_halo.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_fill.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_frame.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_healthglow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_bg.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_frame.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpowerglow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpoweroverlay_fill.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpoweroverlay_leadingedge.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable_munge.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_magickaglow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_dynamic_staminaglow.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_base.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_frame.dds",
	"/esoui/art/unitattributevisualizer/attributebar_small_glow.dds",
	"/esoui/art/unitattributevisualizer/increasedpower_animatedhalo_32fr.dds",
	"/esoui/art/unitframes/enemycastbar_inset_left.dds",
	"/esoui/art/unitframes/enemycastbar_inset_right.dds",
	"/esoui/art/unitframes/playercastbar_inset_left.dds",
	"/esoui/art/unitframes/playercastbar_inset_right.dds",
	"/esoui/art/unitframes/target_health_frame.dds",
	"/esoui/art/unitframes/target_name_bracket_left.dds",
	"/esoui/art/unitframes/target_name_bracket_right.dds",
	"/esoui/art/unitframes/unitframe_player.dds",
	"/esoui/art/unitframes/unitframe_target_left.dds",
	"/esoui/art/unitframes/unitframe_target_right.dds",
	"/esoui/art/vendor/vendor_tabicon_buyback_down.dds",
	"/esoui/art/vendor/vendor_tabicon_buyback_over.dds",
	"/esoui/art/vendor/vendor_tabicon_buyback_up.dds",
	"/esoui/art/worldmap/map_backdrop_center.dds",
	"/esoui/art/worldmap/map_configure_down.dds",
	"/esoui/art/worldmap/map_configure_up.dds",
	"/esoui/art/worldmap/selectedquesthighlight.dds",
}

_lwf._global.Func.table_count = function( T ) if T == nil then return 0; end; local c = 0;for _ in pairs(T) do c = c + 1 end; return c; end
_lwf._global.Func.table_next = function( T ) if T == nil then return 0; end; return _lwf._global.Func.table_count( T )+1; end
_lwf._global.Func.table_findRemove = function( input, item )
	local i=1
	while i <= #input do
		if input[i] == item then table.remove(input, i)
		else i = i + 1 end
	end
end
_lwf._global.Func.comma_value = function(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end
_lwf._global.Func.string_trim = function( s ) return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'; end
_lwf._global.Func.string_split = function( str, delim, max )
    if max == nil then max = -1 end
    if delim == nil then delim = " " end
    local last, start, stop = 1
    local result = {}
    while max ~= 0 do
        start, stop = str:find(delim, last )
        if start == nil then break; end
        table.insert( result, str:sub( last, start-1 ) )
        last = stop+2
        max = max - 1
    end
    table.insert( result, str:sub( last ) )
    return result
end
_lwf._global.Func.Round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
_lwf._global.Func.MillisecondsToHuman = function(milliseconds, includeMs)
	if milliseconds == nil and not includeMs then return "00:00:00" end
	if milliseconds == nil then return "00:00:00:00" end
	local totalseconds = math.floor(milliseconds / 1000)
	milliseconds = milliseconds % 1000
	local seconds = totalseconds % 60
	local minutes = math.floor(totalseconds / 60)
	local hours = math.floor(minutes / 60)
	minutes = minutes % 60
	if includeMs then return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds) end
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

_lwf._global.Func.PairsByKeys = function(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0
		local iter = function ()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

_lwf._global.Func.LoadEmotes = function( self ) 
	if self.GLOBAL.emotes == nil then 
		self.GLOBAL.emotes = {}
		self.GLOBAL.emotesSorted = {}
		local tbl = {}
		for e = 1, GetNumEmotes(), 1 do 
			local em = GetEmoteSlashName(e)
			if em ~= nil and _lwf._global.Func.string_trim(em) ~= "" then tbl[em] = e end
		end 
		for em,e in _lwf._global.Func.PairsByKeys(tbl) do
			self.GLOBAL.emotes[ em ] = e
			self.GLOBAL.emotesSorted[ _lwf._global.Func.table_next(self.GLOBAL.emotesSorted) ] = { name = em, code = e }
		end
	end
	return self.GLOBAL.emotes
end

_lwf._global.Func.FindGameImage = function( txt, dumpToChat )
	local lst = {}
	for _,v in pairs(_lwf._global.Var.GameImages) do
		if string.find(v, string.lower(_lwf._global.Func.string_trim(txt))) then 
			lst[_lwf._global.Func.table_next(lst)] = v
			if dumpToChat then d( v ) end
		end
	end
	return lst
end

_lwf.Events = {}
_lwf.Events.Registry = {}
_lwf.Events.GameEventTable = {}
_lwf.Events.GameEventsByCode = {}
_lwf.Events.Registered_onupdatecallback = {}

_lwf.Events.GameEventTable = {
	["EVENT_ABILITY_COOLDOWN_UPDATED"] = {
		CODE = EVENT_ABILITY_COOLDOWN_UPDATED,
		DESCR = "EVENT_ABILITY_COOLDOWN_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			abilityId = { name = "abilityId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ABILITY_LIST_CHANGED"] = {
		CODE = EVENT_ABILITY_LIST_CHANGED,
		DESCR = "EVENT_ABILITY_LIST_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ABILITY_PROGRESSION_FULL_UPDATE"] = {
		CODE = EVENT_ABILITY_PROGRESSION_FULL_UPDATE,
		DESCR = "EVENT_ABILITY_PROGRESSION_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ABILITY_PROGRESSION_RANK_UPDATE"] = {
		CODE = EVENT_ABILITY_PROGRESSION_RANK_UPDATE,
		DESCR = "EVENT_ABILITY_PROGRESSION_RANK_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			progressionIndex = { name = "progressionIndex", dataType = "luaindex", paramNum = 2 },
			rank = { name = "rank", dataType = "integer", paramNum = 3 },
			maxRank = { name = "maxRank", dataType = "integer", paramNum = 4 },
			morph = { name = "morph", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_ABILITY_PROGRESSION_RESULT"] = {
		CODE = EVENT_ABILITY_PROGRESSION_RESULT,
		DESCR = "EVENT_ABILITY_PROGRESSION_RESULT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ABILITY_PROGRESSION_XP_UPDATE"] = {
		CODE = EVENT_ABILITY_PROGRESSION_XP_UPDATE,
		DESCR = "EVENT_ABILITY_PROGRESSION_XP_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			progressionIndex = { name = "progressionIndex", dataType = "luaindex", paramNum = 2 },
			lastRankXP = { name = "lastRankXP", dataType = "integer", paramNum = 3 },
			nextRankXP = { name = "nextRankXP", dataType = "integer", paramNum = 4 },
			currentXP = { name = "currentXP", dataType = "integer", paramNum = 5 },
			atMorph = { name = "atMorph", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_ABILITY_RANGE_CHANGED"] = {
		CODE = EVENT_ABILITY_RANGE_CHANGED,
		DESCR = "EVENT_ABILITY_RANGE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ACHIEVEMENTS_UPDATED"] = {
		CODE = EVENT_ACHIEVEMENTS_UPDATED,
		DESCR = "EVENT_ACHIEVEMENTS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ACHIEVEMENT_AWARDED"] = {
		CODE = EVENT_ACHIEVEMENT_AWARDED,
		DESCR = "EVENT_ACHIEVEMENT_AWARDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			name = { name = "name", dataType = "string", paramNum = 2 },
			points = { name = "points", dataType = "integer", paramNum = 3 },
			id = { name = "id", dataType = "integer", paramNum = 4 },
			link = { name = "link", dataType = "string", paramNum = 5 },
		},
	},
	["EVENT_ACHIEVEMENT_UPDATED"] = {
		CODE = EVENT_ACHIEVEMENT_UPDATED,
		DESCR = "EVENT_ACHIEVEMENT_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			id = { name = "id", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ACTION_PAGE_UPDATED"] = {
		CODE = EVENT_ACTION_PAGE_UPDATED,
		DESCR = "EVENT_ACTION_PAGE_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			physicalPage = { name = "physicalPage", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_ACTION_SLOTS_FULL_UPDATE"] = {
		CODE = EVENT_ACTION_SLOTS_FULL_UPDATE,
		DESCR = "EVENT_ACTION_SLOTS_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			isHotbarSwap = { name = "isHotbarSwap", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_ACTION_SLOT_ABILITY_SLOTTED"] = {
		CODE = EVENT_ACTION_SLOT_ABILITY_SLOTTED,
		DESCR = "EVENT_ACTION_SLOT_ABILITY_SLOTTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newAbilitySlotted = { name = "newAbilitySlotted", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_ACTION_SLOT_STATE_UPDATED"] = {
		CODE = EVENT_ACTION_SLOT_STATE_UPDATED,
		DESCR = "EVENT_ACTION_SLOT_STATE_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotNum = { name = "slotNum", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_ACTION_SLOT_UPDATED"] = {
		CODE = EVENT_ACTION_SLOT_UPDATED,
		DESCR = "EVENT_ACTION_SLOT_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotNum = { name = "slotNum", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_ACTION_UPDATE_COOLDOWNS"] = {
		CODE = EVENT_ACTION_UPDATE_COOLDOWNS,
		DESCR = "EVENT_ACTION_UPDATE_COOLDOWNS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ACTIVE_QUEST_TOOL_CHANGED"] = {
		CODE = EVENT_ACTIVE_QUEST_TOOL_CHANGED,
		DESCR = "EVENT_ACTIVE_QUEST_TOOL_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			toolIndex = { name = "toolIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_ACTIVE_QUEST_TOOL_CLEARED"] = {
		CODE = EVENT_ACTIVE_QUEST_TOOL_CLEARED,
		DESCR = "EVENT_ACTIVE_QUEST_TOOL_CLEARED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ACTIVE_QUICKSLOT_CHANGED"] = {
		CODE = EVENT_ACTIVE_QUICKSLOT_CHANGED,
		DESCR = "EVENT_ACTIVE_QUICKSLOT_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ACTIVE_WEAPON_PAIR_CHANGED"] = {
		CODE = EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
		DESCR = "EVENT_ACTIVE_WEAPON_PAIR_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			activeWeaponPair = { name = "activeWeaponPair", dataType = "integer", paramNum = 2 },
			locked = { name = "locked", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_AGENT_CHAT_REQUESTED"] = {
		CODE = EVENT_AGENT_CHAT_REQUESTED,
		DESCR = "EVENT_AGENT_CHAT_REQUESTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ALLIANCE_POINT_UPDATE"] = {
		CODE = EVENT_ALLIANCE_POINT_UPDATE,
		DESCR = "EVENT_ALLIANCE_POINT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			alliancePoints = { name = "alliancePoints", dataType = "integer", paramNum = 2 },
			playSound = { name = "playSound", dataType = "bool", paramNum = 3 },
			difference = { name = "difference", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_ARTIFACT_CONTROL_STATE"] = {
		CODE = EVENT_ARTIFACT_CONTROL_STATE,
		DESCR = "EVENT_ARTIFACT_CONTROL_STATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			artifactName = { name = "artifactName", dataType = "string", paramNum = 2 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 3 },
			playerName = { name = "playerName", dataType = "string", paramNum = 4 },
			playerAlliance = { name = "playerAlliance", dataType = "integer", paramNum = 5 },
			controlEvent = { name = "controlEvent", dataType = "integer", paramNum = 6 },
			controlState = { name = "controlState", dataType = "integer", paramNum = 7 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 8 },
		},
	},
	["EVENT_ASSIGNED_CAMPAIGN_CHANGED"] = {
		CODE = EVENT_ASSIGNED_CAMPAIGN_CHANGED,
		DESCR = "EVENT_ASSIGNED_CAMPAIGN_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newAssignedCampaignId = { name = "newAssignedCampaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ATTRIBUTE_FORCE_RESPEC"] = {
		CODE = EVENT_ATTRIBUTE_FORCE_RESPEC,
		DESCR = "EVENT_ATTRIBUTE_FORCE_RESPEC",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ATTRIBUTE_UPGRADE_UPDATED"] = {
		CODE = EVENT_ATTRIBUTE_UPGRADE_UPDATED,
		DESCR = "EVENT_ATTRIBUTE_UPGRADE_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_AVENGE_KILL"] = {
		CODE = EVENT_AVENGE_KILL,
		DESCR = "EVENT_AVENGE_KILL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			avengedPlayerName = { name = "avengedPlayerName", dataType = "string", paramNum = 2 },
			killedPlayerName = { name = "killedPlayerName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_BATTLE_TOKEN_UPDATE"] = {
		CODE = EVENT_BATTLE_TOKEN_UPDATE,
		DESCR = "EVENT_BATTLE_TOKEN_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			battleTokens = { name = "battleTokens", dataType = "integer", paramNum = 2 },
			playSound = { name = "playSound", dataType = "bool", paramNum = 3 },
			difference = { name = "difference", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_BEGIN_CAST"] = {
		CODE = EVENT_BEGIN_CAST,
		DESCR = "EVENT_BEGIN_CAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			actionName = { name = "actionName", dataType = "string", paramNum = 3 },
			startTime = { name = "startTime", dataType = "number", paramNum = 4 },
			endTime = { name = "endTime", dataType = "number", paramNum = 5 },
			isChannel = { name = "isChannel", dataType = "bool", paramNum = 6 },
			barType = { name = "barType", dataType = "integer", paramNum = 7 },
			blockable = { name = "blockable", dataType = "bool", paramNum = 8 },
			interruptible = { name = "interruptible", dataType = "bool", paramNum = 9 },
			isChargeUp = { name = "isChargeUp", dataType = "bool", paramNum = 10 },
		},
	},
	["EVENT_BEGIN_LOCKPICK"] = {
		CODE = EVENT_BEGIN_LOCKPICK,
		DESCR = "EVENT_BEGIN_LOCKPICK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_BEGIN_SIEGE_CONTROL"] = {
		CODE = EVENT_BEGIN_SIEGE_CONTROL,
		DESCR = "EVENT_BEGIN_SIEGE_CONTROL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_BEGIN_SIEGE_UPGRADE"] = {
		CODE = EVENT_BEGIN_SIEGE_UPGRADE,
		DESCR = "EVENT_BEGIN_SIEGE_UPGRADE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_BOSSES_CHANGED"] = {
		CODE = EVENT_BOSSES_CHANGED,
		DESCR = "EVENT_BOSSES_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_BROADCAST"] = {
		CODE = EVENT_BROADCAST,
		DESCR = "EVENT_BROADCAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			message = { name = "message", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_BUYBACK_RECEIPT"] = {
		CODE = EVENT_BUYBACK_RECEIPT,
		DESCR = "EVENT_BUYBACK_RECEIPT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemLink = { name = "itemLink", dataType = "string", paramNum = 2 },
			itemQuantity = { name = "itemQuantity", dataType = "integer", paramNum = 3 },
			money = { name = "money", dataType = "integer", paramNum = 4 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_BUY_RECEIPT"] = {
		CODE = EVENT_BUY_RECEIPT,
		DESCR = "EVENT_BUY_RECEIPT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			entryName = { name = "entryName", dataType = "string", paramNum = 2 },
			entryType = { name = "entryType", dataType = "integer", paramNum = 3 },
			entryQuantity = { name = "entryQuantity", dataType = "integer", paramNum = 4 },
			money = { name = "money", dataType = "integer", paramNum = 5 },
			specialCurrencyType1 = { name = "specialCurrencyType1", dataType = "integer", paramNum = 6 },
			specialCurrencyInfo1 = { name = "specialCurrencyInfo1", dataType = "string", paramNum = 7 },
			specialCurrencyQuantity1 = { name = "specialCurrencyQuantity1", dataType = "integer", paramNum = 8 },
			specialCurrencyType2 = { name = "specialCurrencyType2", dataType = "integer", paramNum = 9 },
			specialCurrencyInfo2 = { name = "specialCurrencyInfo2", dataType = "string", paramNum = 10 },
			specialCurrencyQuantity2 = { name = "specialCurrencyQuantity2", dataType = "integer", paramNum = 11 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 12 },
		},
	},
	["EVENT_CAMERA_DISTANCE_SETTING_CHANGED"] = {
		CODE = EVENT_CAMERA_DISTANCE_SETTING_CHANGED,
		DESCR = "EVENT_CAMERA_DISTANCE_SETTING_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAMPAIGN_EMPEROR_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_EMPEROR_CHANGED,
		DESCR = "EVENT_CAMPAIGN_EMPEROR_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED,
		DESCR = "EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED,
		DESCR = "EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAMPAIGN_QUEUE_JOINED"] = {
		CODE = EVENT_CAMPAIGN_QUEUE_JOINED,
		DESCR = "EVENT_CAMPAIGN_QUEUE_JOINED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			isGroup = { name = "isGroup", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_CAMPAIGN_QUEUE_LEFT"] = {
		CODE = EVENT_CAMPAIGN_QUEUE_LEFT,
		DESCR = "EVENT_CAMPAIGN_QUEUE_LEFT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			isGroup = { name = "isGroup", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,
		DESCR = "EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			isGroup = { name = "isGroup", dataType = "bool", paramNum = 3 },
			position = { name = "position", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_CAMPAIGN_QUEUE_STATE_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_QUEUE_STATE_CHANGED,
		DESCR = "EVENT_CAMPAIGN_QUEUE_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			isGroup = { name = "isGroup", dataType = "bool", paramNum = 3 },
			state = { name = "state", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_CAMPAIGN_SCORE_DATA_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_SCORE_DATA_CHANGED,
		DESCR = "EVENT_CAMPAIGN_SCORE_DATA_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAMPAIGN_SELECTION_DATA_CHANGED"] = {
		CODE = EVENT_CAMPAIGN_SELECTION_DATA_CHANGED,
		DESCR = "EVENT_CAMPAIGN_SELECTION_DATA_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAMPAIGN_STATE_INITIALIZED"] = {
		CODE = EVENT_CAMPAIGN_STATE_INITIALIZED,
		DESCR = "EVENT_CAMPAIGN_STATE_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM"] = {
		CODE = EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM,
		DESCR = "EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CANNOT_DO_THAT_WHILE_DEAD"] = {
		CODE = EVENT_CANNOT_DO_THAT_WHILE_DEAD,
		DESCR = "EVENT_CANNOT_DO_THAT_WHILE_DEAD",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CANNOT_FISH_WHILE_SWIMMING"] = {
		CODE = EVENT_CANNOT_FISH_WHILE_SWIMMING,
		DESCR = "EVENT_CANNOT_FISH_WHILE_SWIMMING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CAPTURE_AREA_STATUS"] = {
		CODE = EVENT_CAPTURE_AREA_STATUS,
		DESCR = "EVENT_CAPTURE_AREA_STATUS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			objectiveId = { name = "objectiveId", dataType = "integer", paramNum = 3 },
			battlegroundContext = { name = "battlegroundContext", dataType = "integer", paramNum = 4 },
			curValue = { name = "curValue", dataType = "integer", paramNum = 5 },
			maxValue = { name = "maxValue", dataType = "integer", paramNum = 6 },
			currentCapturePlayers = { name = "currentCapturePlayers", dataType = "integer", paramNum = 7 },
		},
	},
	["EVENT_CHATTER_BEGIN"] = {
		CODE = EVENT_CHATTER_BEGIN,
		DESCR = "EVENT_CHATTER_BEGIN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			optionCount = { name = "optionCount", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CHATTER_END"] = {
		CODE = EVENT_CHATTER_END,
		DESCR = "EVENT_CHATTER_END",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CHAT_CHANNEL_INVITE"] = {
		CODE = EVENT_CHAT_CHANNEL_INVITE,
		DESCR = "EVENT_CHAT_CHANNEL_INVITE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			channelName = { name = "channelName", dataType = "string", paramNum = 2 },
			playerName = { name = "playerName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_CHAT_CHANNEL_JOIN"] = {
		CODE = EVENT_CHAT_CHANNEL_JOIN,
		DESCR = "EVENT_CHAT_CHANNEL_JOIN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			channelId = { name = "channelId", dataType = "integer", paramNum = 2 },
			customChannelId = { name = "customChannelId", dataType = "integer", paramNum = 3 },
			channelName = { name = "channelName", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_CHAT_CHANNEL_LEAVE"] = {
		CODE = EVENT_CHAT_CHANNEL_LEAVE,
		DESCR = "EVENT_CHAT_CHANNEL_LEAVE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			channelId = { name = "channelId", dataType = "integer", paramNum = 2 },
			customChannelId = { name = "customChannelId", dataType = "integer", paramNum = 3 },
			channelName = { name = "channelName", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_CHAT_LOG_TOGGLED"] = {
		CODE = EVENT_CHAT_LOG_TOGGLED,
		DESCR = "EVENT_CHAT_LOG_TOGGLED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			opened = { name = "opened", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_CHAT_MESSAGE_CHANNEL"] = {
		CODE = EVENT_CHAT_MESSAGE_CHANNEL,
		DESCR = "EVENT_CHAT_MESSAGE_CHANNEL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			messageType = { name = "messageType", dataType = "integer", paramNum = 2 },
			fromName = { name = "fromName", dataType = "string", paramNum = 3 },
			text = { name = "text", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_CHAT_MESSAGE_COMBAT"] = {
		CODE = EVENT_CHAT_MESSAGE_COMBAT,
		DESCR = "EVENT_CHAT_MESSAGE_COMBAT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			text = { name = "text", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_CLOSE_BANK"] = {
		CODE = EVENT_CLOSE_BANK,
		DESCR = "EVENT_CLOSE_BANK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CLOSE_GUILD_BANK"] = {
		CODE = EVENT_CLOSE_GUILD_BANK,
		DESCR = "EVENT_CLOSE_GUILD_BANK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CLOSE_HOOK_POINT_STORE"] = {
		CODE = EVENT_CLOSE_HOOK_POINT_STORE,
		DESCR = "EVENT_CLOSE_HOOK_POINT_STORE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CLOSE_STORE"] = {
		CODE = EVENT_CLOSE_STORE,
		DESCR = "EVENT_CLOSE_STORE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CLOSE_TRADING_HOUSE"] = {
		CODE = EVENT_CLOSE_TRADING_HOUSE,
		DESCR = "EVENT_CLOSE_TRADING_HOUSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_COMBAT_EVENT"] = {
		CODE = EVENT_COMBAT_EVENT,
		DESCR = "EVENT_COMBAT_EVENT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			result = { name = "result", dataType = "integer", paramNum = 2 },
			isError = { name = "isError", dataType = "bool", paramNum = 3 },
			abilityName = { name = "abilityName", dataType = "string", paramNum = 4 },
			abilityGraphic = { name = "abilityGraphic", dataType = "integer", paramNum = 5 },
			abilityActionSlotType = { name = "abilityActionSlotType", dataType = "integer", paramNum = 6 },
			sourceName = { name = "sourceName", dataType = "string", paramNum = 7 },
			sourceType = { name = "sourceType", dataType = "integer", paramNum = 8 },
			targetName = { name = "targetName", dataType = "string", paramNum = 9 },
			targetType = { name = "targetType", dataType = "integer", paramNum = 10 },
			hitValue = { name = "hitValue", dataType = "integer", paramNum = 11 },
			powerType = { name = "powerType", dataType = "integer", paramNum = 12 },
			damageType = { name = "damageType", dataType = "integer", paramNum = 13 },
			log = { name = "log", dataType = "bool", paramNum = 14 },
		},
	},
	["EVENT_CONTROLLED_SIEGE_SOCKETS_CHANGED"] = {
		CODE = EVENT_CONTROLLED_SIEGE_SOCKETS_CHANGED,
		DESCR = "EVENT_CONTROLLED_SIEGE_SOCKETS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CONVERSATION_FAILED_INVENTORY_FULL"] = {
		CODE = EVENT_CONVERSATION_FAILED_INVENTORY_FULL,
		DESCR = "EVENT_CONVERSATION_FAILED_INVENTORY_FULL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_CONVERSATION_UPDATED"] = {
		CODE = EVENT_CONVERSATION_UPDATED,
		DESCR = "EVENT_CONVERSATION_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			conversationBodyText = { name = "conversationBodyText", dataType = "string", paramNum = 2 },
			conversationOptionCount = { name = "conversationOptionCount", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_CORONATE_EMPEROR_NOTIFICATION"] = {
		CODE = EVENT_CORONATE_EMPEROR_NOTIFICATION,
		DESCR = "EVENT_CORONATE_EMPEROR_NOTIFICATION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			emperorName = { name = "emperorName", dataType = "string", paramNum = 3 },
			emperorAlliance = { name = "emperorAlliance", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_CRAFTING_STATION_INTERACT"] = {
		CODE = EVENT_CRAFTING_STATION_INTERACT,
		DESCR = "EVENT_CRAFTING_STATION_INTERACT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			craftSkill = { name = "craftSkill", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CRAFT_COMPLETED"] = {
		CODE = EVENT_CRAFT_COMPLETED,
		DESCR = "EVENT_CRAFT_COMPLETED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			craftSkill = { name = "craftSkill", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CURRENT_CAMPAIGN_CHANGED"] = {
		CODE = EVENT_CURRENT_CAMPAIGN_CHANGED,
		DESCR = "EVENT_CURRENT_CAMPAIGN_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newCurrentCampaignId = { name = "newCurrentCampaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CURRENT_WEAPON_SET_UPDATE"] = {
		CODE = EVENT_CURRENT_WEAPON_SET_UPDATE,
		DESCR = "EVENT_CURRENT_WEAPON_SET_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			weaponSetIndex = { name = "weaponSetIndex", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_CURSOR_DROPPED"] = {
		CODE = EVENT_CURSOR_DROPPED,
		DESCR = "EVENT_CURSOR_DROPPED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			type = { name = "type", dataType = "integer", paramNum = 2 },
			param1 = { name = "param1", dataType = "integer", paramNum = 3 },
			param2 = { name = "param2", dataType = "integer", paramNum = 4 },
			param3 = { name = "param3", dataType = "integer", paramNum = 5 },
			param4 = { name = "param4", dataType = "integer", paramNum = 6 },
			param5 = { name = "param5", dataType = "integer", paramNum = 7 },
			param6 = { name = "param6", dataType = "integer", paramNum = 8 },
		},
	},
	["EVENT_CURSOR_PICKUP"] = {
		CODE = EVENT_CURSOR_PICKUP,
		DESCR = "EVENT_CURSOR_PICKUP",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			type = { name = "type", dataType = "integer", paramNum = 2 },
			param1 = { name = "param1", dataType = "integer", paramNum = 3 },
			param2 = { name = "param2", dataType = "integer", paramNum = 4 },
			param3 = { name = "param3", dataType = "integer", paramNum = 5 },
			param4 = { name = "param4", dataType = "integer", paramNum = 6 },
			param5 = { name = "param5", dataType = "integer", paramNum = 7 },
			param6 = { name = "param6", dataType = "integer", paramNum = 8 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 9 },
		},
	},
	["EVENT_DELAY_CAST"] = {
		CODE = EVENT_DELAY_CAST,
		DESCR = "EVENT_DELAY_CAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			actionName = { name = "actionName", dataType = "string", paramNum = 3 },
			startTime = { name = "startTime", dataType = "number", paramNum = 4 },
			endTime = { name = "endTime", dataType = "number", paramNum = 5 },
			isChannel = { name = "isChannel", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_DEPOSE_EMPEROR_NOTIFICATION"] = {
		CODE = EVENT_DEPOSE_EMPEROR_NOTIFICATION,
		DESCR = "EVENT_DEPOSE_EMPEROR_NOTIFICATION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			emperorName = { name = "emperorName", dataType = "string", paramNum = 3 },
			emperorAlliance = { name = "emperorAlliance", dataType = "integer", paramNum = 4 },
			abdication = { name = "abdication", dataType = "bool", paramNum = 5 },
		},
	},
	["EVENT_DIFFICULTY_LEVEL_CHANGED"] = {
		CODE = EVENT_DIFFICULTY_LEVEL_CHANGED,
		DESCR = "EVENT_DIFFICULTY_LEVEL_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			difficultyLevel = { name = "difficultyLevel", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_DISABLE_SIEGE_AIM_ABILITY"] = {
		CODE = EVENT_DISABLE_SIEGE_AIM_ABILITY,
		DESCR = "EVENT_DISABLE_SIEGE_AIM_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_DISABLE_SIEGE_FIRE_ABILITY"] = {
		CODE = EVENT_DISABLE_SIEGE_FIRE_ABILITY,
		DESCR = "EVENT_DISABLE_SIEGE_FIRE_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_DISABLE_SIEGE_PACKUP_ABILITY"] = {
		CODE = EVENT_DISABLE_SIEGE_PACKUP_ABILITY,
		DESCR = "EVENT_DISABLE_SIEGE_PACKUP_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_DISGUISE_STATE_CHANGED"] = {
		CODE = EVENT_DISGUISE_STATE_CHANGED,
		DESCR = "EVENT_DISGUISE_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			disguiseState = { name = "disguiseState", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_DISPLAY_ACTIVE_COMBAT_TIP"] = {
		CODE = EVENT_DISPLAY_ACTIVE_COMBAT_TIP,
		DESCR = "EVENT_DISPLAY_ACTIVE_COMBAT_TIP",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			activeCombatTipId = { name = "activeCombatTipId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_DISPLAY_TUTORIAL"] = {
		CODE = EVENT_DISPLAY_TUTORIAL,
		DESCR = "EVENT_DISPLAY_TUTORIAL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			tutorialIndex = { name = "tutorialIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_DISPOSITION_UPDATE"] = {
		CODE = EVENT_DISPOSITION_UPDATE,
		DESCR = "EVENT_DISPOSITION_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_DROWN_TIMER_UPDATE"] = {
		CODE = EVENT_DROWN_TIMER_UPDATE,
		DESCR = "EVENT_DROWN_TIMER_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			startTime = { name = "startTime", dataType = "number", paramNum = 3 },
			endTime = { name = "endTime", dataType = "number", paramNum = 4 },
		},
	},
	["EVENT_EFFECTS_FULL_UPDATE"] = {
		CODE = EVENT_EFFECTS_FULL_UPDATE,
		DESCR = "EVENT_EFFECTS_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_EFFECT_CHANGED"] = {
		CODE = EVENT_EFFECT_CHANGED,
		DESCR = "EVENT_EFFECT_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			changeType = { name = "changeType", dataType = "integer", paramNum = 2 },
			effectSlot = { name = "effectSlot", dataType = "integer", paramNum = 3 },
			effectName = { name = "effectName", dataType = "string", paramNum = 4 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 5 },
			beginTime = { name = "beginTime", dataType = "number", paramNum = 6 },
			endTime = { name = "endTime", dataType = "number", paramNum = 7 },
			stackCount = { name = "stackCount", dataType = "integer", paramNum = 8 },
			iconName = { name = "iconName", dataType = "string", paramNum = 9 },
			buffType = { name = "buffType", dataType = "string", paramNum = 10 },
			effectType = { name = "effectType", dataType = "integer", paramNum = 11 },
			abilityType = { name = "abilityType", dataType = "integer", paramNum = 12 },
			statusEffectType = { name = "statusEffectType", dataType = "integer", paramNum = 13 },
		},
	},
	["EVENT_ENABLE_SIEGE_AIM_ABILITY"] = {
		CODE = EVENT_ENABLE_SIEGE_AIM_ABILITY,
		DESCR = "EVENT_ENABLE_SIEGE_AIM_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ENABLE_SIEGE_FIRE_ABILITY"] = {
		CODE = EVENT_ENABLE_SIEGE_FIRE_ABILITY,
		DESCR = "EVENT_ENABLE_SIEGE_FIRE_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ENABLE_SIEGE_PACKUP_ABILITY"] = {
		CODE = EVENT_ENABLE_SIEGE_PACKUP_ABILITY,
		DESCR = "EVENT_ENABLE_SIEGE_PACKUP_ABILITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_CAST"] = {
		CODE = EVENT_END_CAST,
		DESCR = "EVENT_END_CAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			interrupted = { name = "interrupted", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_END_CRAFTING_STATION_INTERACT"] = {
		CODE = EVENT_END_CRAFTING_STATION_INTERACT,
		DESCR = "EVENT_END_CRAFTING_STATION_INTERACT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_FAST_TRAVEL_INTERACTION"] = {
		CODE = EVENT_END_FAST_TRAVEL_INTERACTION,
		DESCR = "EVENT_END_FAST_TRAVEL_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_FAST_TRAVEL_KEEP_INTERACTION"] = {
		CODE = EVENT_END_FAST_TRAVEL_KEEP_INTERACTION,
		DESCR = "EVENT_END_FAST_TRAVEL_KEEP_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_KEEP_GUILD_CLAIM_INTERACTION"] = {
		CODE = EVENT_END_KEEP_GUILD_CLAIM_INTERACTION,
		DESCR = "EVENT_END_KEEP_GUILD_CLAIM_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_KEEP_GUILD_RELEASE_INTERACTION"] = {
		CODE = EVENT_END_KEEP_GUILD_RELEASE_INTERACTION,
		DESCR = "EVENT_END_KEEP_GUILD_RELEASE_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_SIEGE_CONTROL"] = {
		CODE = EVENT_END_SIEGE_CONTROL,
		DESCR = "EVENT_END_SIEGE_CONTROL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_END_SOUL_GEM_RESURRECTION"] = {
		CODE = EVENT_END_SOUL_GEM_RESURRECTION,
		DESCR = "EVENT_END_SOUL_GEM_RESURRECTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ENTER_GROUND_TARGET_MODE"] = {
		CODE = EVENT_ENTER_GROUND_TARGET_MODE,
		DESCR = "EVENT_ENTER_GROUND_TARGET_MODE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_EXPERIENCE_GAIN"] = {
		CODE = EVENT_EXPERIENCE_GAIN,
		DESCR = "EVENT_EXPERIENCE_GAIN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			value = { name = "value", dataType = "integer", paramNum = 2 },
			reason = { name = "reason", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_EXPERIENCE_GAIN_DISCOVERY"] = {
		CODE = EVENT_EXPERIENCE_GAIN_DISCOVERY,
		DESCR = "EVENT_EXPERIENCE_GAIN_DISCOVERY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			areaName = { name = "areaName", dataType = "string", paramNum = 2 },
			value = { name = "value", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_EXPERIENCE_UPDATE"] = {
		CODE = EVENT_EXPERIENCE_UPDATE,
		DESCR = "EVENT_EXPERIENCE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			currentExp = { name = "currentExp", dataType = "integer", paramNum = 3 },
			maxExp = { name = "maxExp", dataType = "integer", paramNum = 4 },
			reason = { name = "reason", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED"] = {
		CODE = EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED,
		DESCR = "EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			linkIndex = { name = "linkIndex", dataType = "luaindex", paramNum = 2 },
			linkType = { name = "linkType", dataType = "integer", paramNum = 3 },
			owningAlliance = { name = "owningAlliance", dataType = "integer", paramNum = 4 },
			oldLinkType = { name = "oldLinkType", dataType = "integer", paramNum = 5 },
			oldOwningAlliance = { name = "oldOwningAlliance", dataType = "integer", paramNum = 6 },
			isLocal = { name = "isLocal", dataType = "bool", paramNum = 7 },
		},
	},
	["EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED"] = {
		CODE = EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED,
		DESCR = "EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_FAST_TRAVEL_NETWORK_UPDATED"] = {
		CODE = EVENT_FAST_TRAVEL_NETWORK_UPDATED,
		DESCR = "EVENT_FAST_TRAVEL_NETWORK_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			nodeIndex = { name = "nodeIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_FEEDBACK_REQUESTED"] = {
		CODE = EVENT_FEEDBACK_REQUESTED,
		DESCR = "EVENT_FEEDBACK_REQUESTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			feedbackId = { name = "feedbackId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT"] = {
		CODE = EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT,
		DESCR = "EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_FINESSE_RANK_CHANGED"] = {
		CODE = EVENT_FINESSE_RANK_CHANGED,
		DESCR = "EVENT_FINESSE_RANK_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			rankNum = { name = "rankNum", dataType = "luaindex", paramNum = 3 },
			name = { name = "name", dataType = "string", paramNum = 4 },
			xpBonus = { name = "xpBonus", dataType = "integer", paramNum = 5 },
			loot = { name = "loot", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_FISHING_LURE_CLEARED"] = {
		CODE = EVENT_FISHING_LURE_CLEARED,
		DESCR = "EVENT_FISHING_LURE_CLEARED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_FISHING_LURE_SET"] = {
		CODE = EVENT_FISHING_LURE_SET,
		DESCR = "EVENT_FISHING_LURE_SET",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			fishingLure = { name = "fishingLure", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_FORWARD_CAMPS_UPDATED"] = {
		CODE = EVENT_FORWARD_CAMPS_UPDATED,
		DESCR = "EVENT_FORWARD_CAMPS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GAME_CAMERA_ACTIVATED"] = {
		CODE = EVENT_GAME_CAMERA_ACTIVATED,
		DESCR = "EVENT_GAME_CAMERA_ACTIVATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GAME_CAMERA_DEACTIVATED"] = {
		CODE = EVENT_GAME_CAMERA_DEACTIVATED,
		DESCR = "EVENT_GAME_CAMERA_DEACTIVATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GAME_CAMERA_UI_MODE_CHANGED"] = {
		CODE = EVENT_GAME_CAMERA_UI_MODE_CHANGED,
		DESCR = "EVENT_GAME_CAMERA_UI_MODE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GAME_FOCUS_CHANGED"] = {
		CODE = EVENT_GAME_FOCUS_CHANGED,
		DESCR = "EVENT_GAME_FOCUS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			hasFocus = { name = "hasFocus", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_GAME_SCORE"] = {
		CODE = EVENT_GAME_SCORE,
		DESCR = "EVENT_GAME_SCORE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			alliance1 = { name = "alliance1", dataType = "integer", paramNum = 2 },
			alliance2 = { name = "alliance2", dataType = "integer", paramNum = 3 },
			alliance3 = { name = "alliance3", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_GAME_STATE_CHANGED"] = {
		CODE = EVENT_GAME_STATE_CHANGED,
		DESCR = "EVENT_GAME_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			oldState = { name = "oldState", dataType = "integer", paramNum = 2 },
			newState = { name = "newState", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_GAME_TIMER_PAUSED"] = {
		CODE = EVENT_GAME_TIMER_PAUSED,
		DESCR = "EVENT_GAME_TIMER_PAUSED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			isPaused = { name = "isPaused", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_GRAVEYARD_USAGE_FAILURE"] = {
		CODE = EVENT_GRAVEYARD_USAGE_FAILURE,
		DESCR = "EVENT_GRAVEYARD_USAGE_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GROUPING_TOOLS_STATUS_UPDATE"] = {
		CODE = EVENT_GROUPING_TOOLS_STATUS_UPDATE,
		DESCR = "EVENT_GROUPING_TOOLS_STATUS_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inQueue = { name = "inQueue", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED"] = {
		CODE = EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED,
		DESCR = "EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GROUP_DISBANDED"] = {
		CODE = EVENT_GROUP_DISBANDED,
		DESCR = "EVENT_GROUP_DISBANDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GROUP_INVITE_RECEIVED"] = {
		CODE = EVENT_GROUP_INVITE_RECEIVED,
		DESCR = "EVENT_GROUP_INVITE_RECEIVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inviterName = { name = "inviterName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_GROUP_INVITE_REMOVED"] = {
		CODE = EVENT_GROUP_INVITE_REMOVED,
		DESCR = "EVENT_GROUP_INVITE_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GROUP_INVITE_RESPONSE"] = {
		CODE = EVENT_GROUP_INVITE_RESPONSE,
		DESCR = "EVENT_GROUP_INVITE_RESPONSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inviterName = { name = "inviterName", dataType = "string", paramNum = 2 },
			response = { name = "response", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_GROUP_MEMBER_CONNECTED_STATUS"] = {
		CODE = EVENT_GROUP_MEMBER_CONNECTED_STATUS,
		DESCR = "EVENT_GROUP_MEMBER_CONNECTED_STATUS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			isOnline = { name = "isOnline", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_GROUP_MEMBER_JOINED"] = {
		CODE = EVENT_GROUP_MEMBER_JOINED,
		DESCR = "EVENT_GROUP_MEMBER_JOINED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			memberName = { name = "memberName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_GROUP_MEMBER_LEFT"] = {
		CODE = EVENT_GROUP_MEMBER_LEFT,
		DESCR = "EVENT_GROUP_MEMBER_LEFT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			memberName = { name = "memberName", dataType = "string", paramNum = 2 },
			reason = { name = "reason", dataType = "integer", paramNum = 3 },
			wasLocalPlayer = { name = "wasLocalPlayer", dataType = "bool", paramNum = 4 },
		},
	},
	["EVENT_GROUP_MEMBER_ROLES_CHANGED"] = {
		CODE = EVENT_GROUP_MEMBER_ROLES_CHANGED,
		DESCR = "EVENT_GROUP_MEMBER_ROLES_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			dps = { name = "dps", dataType = "bool", paramNum = 3 },
			healer = { name = "healer", dataType = "bool", paramNum = 4 },
			tank = { name = "tank", dataType = "bool", paramNum = 5 },
		},
	},
	["EVENT_GROUP_NOTIFICATION_MESSAGE"] = {
		CODE = EVENT_GROUP_NOTIFICATION_MESSAGE,
		DESCR = "EVENT_GROUP_NOTIFICATION_MESSAGE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			messageId = { name = "messageId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GROUP_SUPPORT_RANGE_UPDATE"] = {
		CODE = EVENT_GROUP_SUPPORT_RANGE_UPDATE,
		DESCR = "EVENT_GROUP_SUPPORT_RANGE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			status = { name = "status", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_GROUP_TYPE_CHANGED"] = {
		CODE = EVENT_GROUP_TYPE_CHANGED,
		DESCR = "EVENT_GROUP_TYPE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			largeGroup = { name = "largeGroup", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_GUEST_CAMPAIGN_CHANGED"] = {
		CODE = EVENT_GUEST_CAMPAIGN_CHANGED,
		DESCR = "EVENT_GUEST_CAMPAIGN_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newGuestCampaignId = { name = "newGuestCampaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_DESELECTED"] = {
		CODE = EVENT_GUILD_BANK_DESELECTED,
		DESCR = "EVENT_GUILD_BANK_DESELECTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GUILD_BANK_ITEMS_READY"] = {
		CODE = EVENT_GUILD_BANK_ITEMS_READY,
		DESCR = "EVENT_GUILD_BANK_ITEMS_READY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GUILD_BANK_ITEM_ADDED"] = {
		CODE = EVENT_GUILD_BANK_ITEM_ADDED,
		DESCR = "EVENT_GUILD_BANK_ITEM_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_ITEM_REMOVED"] = {
		CODE = EVENT_GUILD_BANK_ITEM_REMOVED,
		DESCR = "EVENT_GUILD_BANK_ITEM_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_OPEN_ERROR"] = {
		CODE = EVENT_GUILD_BANK_OPEN_ERROR,
		DESCR = "EVENT_GUILD_BANK_OPEN_ERROR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_SELECTED"] = {
		CODE = EVENT_GUILD_BANK_SELECTED,
		DESCR = "EVENT_GUILD_BANK_SELECTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			guildId = { name = "guildId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_TRANSFER_ERROR"] = {
		CODE = EVENT_GUILD_BANK_TRANSFER_ERROR,
		DESCR = "EVENT_GUILD_BANK_TRANSFER_ERROR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_BANK_UPDATED_QUANTITY"] = {
		CODE = EVENT_GUILD_BANK_UPDATED_QUANTITY,
		DESCR = "EVENT_GUILD_BANK_UPDATED_QUANTITY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_GUILD_MEMBER_ACHIEVEMENT_AWARDED"] = {
		CODE = EVENT_GUILD_MEMBER_ACHIEVEMENT_AWARDED,
		DESCR = "EVENT_GUILD_MEMBER_ACHIEVEMENT_AWARDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			playerName = { name = "playerName", dataType = "string", paramNum = 2 },
			id = { name = "id", dataType = "integer", paramNum = 3 },
			link = { name = "link", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_GUILD_REPUTATION_ADDED"] = {
		CODE = EVENT_GUILD_REPUTATION_ADDED,
		DESCR = "EVENT_GUILD_REPUTATION_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			repIndex = { name = "repIndex", dataType = "luaindex", paramNum = 2 },
			repName = { name = "repName", dataType = "string", paramNum = 3 },
			rankName = { name = "rankName", dataType = "string", paramNum = 4 },
			curPoints = { name = "curPoints", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_GUILD_REPUTATION_LOADED"] = {
		CODE = EVENT_GUILD_REPUTATION_LOADED,
		DESCR = "EVENT_GUILD_REPUTATION_LOADED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_GUILD_REPUTATION_POINTS_UPDATED"] = {
		CODE = EVENT_GUILD_REPUTATION_POINTS_UPDATED,
		DESCR = "EVENT_GUILD_REPUTATION_POINTS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			repIndex = { name = "repIndex", dataType = "luaindex", paramNum = 2 },
			repName = { name = "repName", dataType = "string", paramNum = 3 },
			rankName = { name = "rankName", dataType = "string", paramNum = 4 },
			pointGain = { name = "pointGain", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_GUILD_REPUTATION_RANK_UPDATED"] = {
		CODE = EVENT_GUILD_REPUTATION_RANK_UPDATED,
		DESCR = "EVENT_GUILD_REPUTATION_RANK_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			repIndex = { name = "repIndex", dataType = "luaindex", paramNum = 2 },
			repName = { name = "repName", dataType = "string", paramNum = 3 },
			rankName = { name = "rankName", dataType = "string", paramNum = 4 },
			curPoints = { name = "curPoints", dataType = "integer", paramNum = 5 },
			newRank = { name = "newRank", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_HELP_INITIALIZED"] = {
		CODE = EVENT_HELP_INITIALIZED,
		DESCR = "EVENT_HELP_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_HELP_SEARCH_RESULTS_READY"] = {
		CODE = EVENT_HELP_SEARCH_RESULTS_READY,
		DESCR = "EVENT_HELP_SEARCH_RESULTS_READY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_HIDE_BOOK"] = {
		CODE = EVENT_HIDE_BOOK,
		DESCR = "EVENT_HIDE_BOOK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_HIDE_OBJECTIVE_STATUS"] = {
		CODE = EVENT_HIDE_OBJECTIVE_STATUS,
		DESCR = "EVENT_HIDE_OBJECTIVE_STATUS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_HOOK_POINTS_UPDATED"] = {
		CODE = EVENT_HOOK_POINTS_UPDATED,
		DESCR = "EVENT_HOOK_POINTS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_HOT_BAR_RESULT"] = {
		CODE = EVENT_HOT_BAR_RESULT,
		DESCR = "EVENT_HOT_BAR_RESULT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK"] = {
		CODE = EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK,
		DESCR = "EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			interactableName = { name = "interactableName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_INTERACTABLE_LOCKED"] = {
		CODE = EVENT_INTERACTABLE_LOCKED,
		DESCR = "EVENT_INTERACTABLE_LOCKED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			interactableName = { name = "interactableName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_INTERACTION_TRANSITION_PENDING"] = {
		CODE = EVENT_INTERACTION_TRANSITION_PENDING,
		DESCR = "EVENT_INTERACTION_TRANSITION_PENDING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_INTERACT_BUSY"] = {
		CODE = EVENT_INTERACT_BUSY,
		DESCR = "EVENT_INTERACT_BUSY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_INTERFACE_SETTING_CHANGED"] = {
		CODE = EVENT_INTERFACE_SETTING_CHANGED,
		DESCR = "EVENT_INTERFACE_SETTING_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			system = { name = "system", dataType = "integer", paramNum = 2 },
			settingId = { name = "settingId", dataType = "integer", paramNum = 3 },
			value = { name = "value", dataType = "bool", paramNum = 4 },
		},
	},
	["EVENT_INVENTORY_BOUGHT_BAG_SPACE"] = {
		CODE = EVENT_INVENTORY_BOUGHT_BAG_SPACE,
		DESCR = "EVENT_INVENTORY_BOUGHT_BAG_SPACE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			numberOfSlots = { name = "numberOfSlots", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_BOUGHT_BANK_SPACE"] = {
		CODE = EVENT_INVENTORY_BOUGHT_BANK_SPACE,
		DESCR = "EVENT_INVENTORY_BOUGHT_BANK_SPACE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			numberOfSlots = { name = "numberOfSlots", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_BUY_BAG_SPACE"] = {
		CODE = EVENT_INVENTORY_BUY_BAG_SPACE,
		DESCR = "EVENT_INVENTORY_BUY_BAG_SPACE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			cost = { name = "cost", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_BUY_BANK_SPACE"] = {
		CODE = EVENT_INVENTORY_BUY_BANK_SPACE,
		DESCR = "EVENT_INVENTORY_BUY_BANK_SPACE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			cost = { name = "cost", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_CLOSE_BUY_SPACE"] = {
		CODE = EVENT_INVENTORY_CLOSE_BUY_SPACE,
		DESCR = "EVENT_INVENTORY_CLOSE_BUY_SPACE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_INVENTORY_FULL_UPDATE"] = {
		CODE = EVENT_INVENTORY_FULL_UPDATE,
		DESCR = "EVENT_INVENTORY_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_INVENTORY_ITEM_DESTROYED"] = {
		CODE = EVENT_INVENTORY_ITEM_DESTROYED,
		DESCR = "EVENT_INVENTORY_ITEM_DESTROYED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_ITEM_USED"] = {
		CODE = EVENT_INVENTORY_ITEM_USED,
		DESCR = "EVENT_INVENTORY_ITEM_USED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_INVENTORY_SINGLE_SLOT_UPDATE"] = {
		CODE = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
		DESCR = "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bagId = { name = "bagId", dataType = "integer", paramNum = 2 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 3 },
			isNewItem = { name = "isNewItem", dataType = "bool", paramNum = 4 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 5 },
			updateReason = { name = "updateReason", dataType = "integer", paramNum = 6 },
		},
	},
	["EVENT_INVENTORY_SLOT_LOCKED"] = {
		CODE = EVENT_INVENTORY_SLOT_LOCKED,
		DESCR = "EVENT_INVENTORY_SLOT_LOCKED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bagId = { name = "bagId", dataType = "integer", paramNum = 2 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_INVENTORY_SLOT_UNLOCKED"] = {
		CODE = EVENT_INVENTORY_SLOT_UNLOCKED,
		DESCR = "EVENT_INVENTORY_SLOT_UNLOCKED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bagId = { name = "bagId", dataType = "integer", paramNum = 2 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_ITEM_REPAIR_FAILURE"] = {
		CODE = EVENT_ITEM_REPAIR_FAILURE,
		DESCR = "EVENT_ITEM_REPAIR_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_ITEM_SLOT_CHANGED"] = {
		CODE = EVENT_ITEM_SLOT_CHANGED,
		DESCR = "EVENT_ITEM_SLOT_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_JUMP_FAILED"] = {
		CODE = EVENT_JUMP_FAILED,
		DESCR = "EVENT_JUMP_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEPS_INITIALIZED"] = {
		CODE = EVENT_KEEPS_INITIALIZED,
		DESCR = "EVENT_KEEPS_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_KEEP_ALLIANCE_OWNER_CHANGED"] = {
		CODE = EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
		DESCR = "EVENT_KEEP_ALLIANCE_OWNER_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			owningAlliance = { name = "owningAlliance", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_KEEP_BATTLE_TOKENS_UPDATE"] = {
		CODE = EVENT_KEEP_BATTLE_TOKENS_UPDATE,
		DESCR = "EVENT_KEEP_BATTLE_TOKENS_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEP_CAPTURE_REWARDS"] = {
		CODE = EVENT_KEEP_CAPTURE_REWARDS,
		DESCR = "EVENT_KEEP_CAPTURE_REWARDS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			captured = { name = "captured", dataType = "bool", paramNum = 3 },
			alliance = { name = "alliance", dataType = "integer", paramNum = 4 },
			experience = { name = "experience", dataType = "integer", paramNum = 5 },
			alliancePoints = { name = "alliancePoints", dataType = "integer", paramNum = 6 },
		},
	},
	["EVENT_KEEP_COMBAT_STATE_CHANGED"] = {
		CODE = EVENT_KEEP_COMBAT_STATE_CHANGED,
		DESCR = "EVENT_KEEP_COMBAT_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			inCombat = { name = "inCombat", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_KEEP_END_INTERACTION"] = {
		CODE = EVENT_KEEP_END_INTERACTION,
		DESCR = "EVENT_KEEP_END_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_KEEP_GATE_STATE_CHANGED"] = {
		CODE = EVENT_KEEP_GATE_STATE_CHANGED,
		DESCR = "EVENT_KEEP_GATE_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			open = { name = "open", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_KEEP_GUILD_CLAIM_UPDATE"] = {
		CODE = EVENT_KEEP_GUILD_CLAIM_UPDATE,
		DESCR = "EVENT_KEEP_GUILD_CLAIM_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEP_INITIALIZED"] = {
		CODE = EVENT_KEEP_INITIALIZED,
		DESCR = "EVENT_KEEP_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION"] = {
		CODE = EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION,
		DESCR = "EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			campaignId = { name = "campaignId", dataType = "integer", paramNum = 2 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 3 },
			oldOwner = { name = "oldOwner", dataType = "integer", paramNum = 4 },
			newOwner = { name = "newOwner", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_KEEP_RESOURCE_LOCK_UPDATE"] = {
		CODE = EVENT_KEEP_RESOURCE_LOCK_UPDATE,
		DESCR = "EVENT_KEEP_RESOURCE_LOCK_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEP_RESOURCE_UPDATE"] = {
		CODE = EVENT_KEEP_RESOURCE_UPDATE,
		DESCR = "EVENT_KEEP_RESOURCE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_KEEP_START_INTERACTION"] = {
		CODE = EVENT_KEEP_START_INTERACTION,
		DESCR = "EVENT_KEEP_START_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_KEEP_UNDER_ATTACK_CHANGED"] = {
		CODE = EVENT_KEEP_UNDER_ATTACK_CHANGED,
		DESCR = "EVENT_KEEP_UNDER_ATTACK_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
			underAttack = { name = "underAttack", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_KILL_LOCATIONS_UPDATED"] = {
		CODE = EVENT_KILL_LOCATIONS_UPDATED,
		DESCR = "EVENT_KILL_LOCATIONS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_KILL_SPAM"] = {
		CODE = EVENT_KILL_SPAM,
		DESCR = "EVENT_KILL_SPAM",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			killingPlayer = { name = "killingPlayer", dataType = "string", paramNum = 2 },
			killingPlayerAlliance = { name = "killingPlayerAlliance", dataType = "integer", paramNum = 3 },
			killedPlayer = { name = "killedPlayer", dataType = "string", paramNum = 4 },
			killedPlayerAlliance = { name = "killedPlayerAlliance", dataType = "integer", paramNum = 5 },
			subzoneName = { name = "subzoneName", dataType = "string", paramNum = 6 },
		},
	},
	["EVENT_LEADER_UPDATE"] = {
		CODE = EVENT_LEADER_UPDATE,
		DESCR = "EVENT_LEADER_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			leaderTag = { name = "leaderTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE"] = {
		CODE = EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE,
		DESCR = "EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			response = { name = "response", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_LEAVE_RAM_ESCORT"] = {
		CODE = EVENT_LEAVE_RAM_ESCORT,
		DESCR = "EVENT_LEAVE_RAM_ESCORT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LEVEL_UPDATE"] = {
		CODE = EVENT_LEVEL_UPDATE,
		DESCR = "EVENT_LEVEL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			level = { name = "level", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_LEVEL_UP_INFO_UPDATED"] = {
		CODE = EVENT_LEVEL_UP_INFO_UPDATED,
		DESCR = "EVENT_LEVEL_UP_INFO_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LINKED_WORLD_POSITION_CHANGED"] = {
		CODE = EVENT_LINKED_WORLD_POSITION_CHANGED,
		DESCR = "EVENT_LINKED_WORLD_POSITION_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_ABILITY_OCCURED"] = {
		CODE = EVENT_LOCAL_PLAYER_ABILITY_OCCURED,
		DESCR = "EVENT_LOCAL_PLAYER_ABILITY_OCCURED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_CHARGEUP_BEGIN"] = {
		CODE = EVENT_LOCAL_PLAYER_CHARGEUP_BEGIN,
		DESCR = "EVENT_LOCAL_PLAYER_CHARGEUP_BEGIN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_CHARGEUP_COMPLETE"] = {
		CODE = EVENT_LOCAL_PLAYER_CHARGEUP_COMPLETE,
		DESCR = "EVENT_LOCAL_PLAYER_CHARGEUP_COMPLETE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_KICKOFF_CAST"] = {
		CODE = EVENT_LOCAL_PLAYER_KICKOFF_CAST,
		DESCR = "EVENT_LOCAL_PLAYER_KICKOFF_CAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_BEGIN"] = {
		CODE = EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_BEGIN,
		DESCR = "EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_BEGIN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_END"] = {
		CODE = EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_END,
		DESCR = "EVENT_LOCAL_PLAYER_WEAPON_ABILITY_WAIT_END",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCKPICK_BROKE"] = {
		CODE = EVENT_LOCKPICK_BROKE,
		DESCR = "EVENT_LOCKPICK_BROKE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inactivityLengthMs = { name = "inactivityLengthMs", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_LOCKPICK_FAILED"] = {
		CODE = EVENT_LOCKPICK_FAILED,
		DESCR = "EVENT_LOCKPICK_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOCKPICK_SUCCESS"] = {
		CODE = EVENT_LOCKPICK_SUCCESS,
		DESCR = "EVENT_LOCKPICK_SUCCESS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOGOUT_DEFERRED"] = {
		CODE = EVENT_LOGOUT_DEFERRED,
		DESCR = "EVENT_LOGOUT_DEFERRED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			deferMilliseconds = { name = "deferMilliseconds", dataType = "integer", paramNum = 2 },
			quitRequested = { name = "quitRequested", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_LOGOUT_DISALLOWED"] = {
		CODE = EVENT_LOGOUT_DISALLOWED,
		DESCR = "EVENT_LOGOUT_DISALLOWED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			quitRequested = { name = "quitRequested", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_LOOT_CLOSED"] = {
		CODE = EVENT_LOOT_CLOSED,
		DESCR = "EVENT_LOOT_CLOSED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LOOT_ITEM_FAILED"] = {
		CODE = EVENT_LOOT_ITEM_FAILED,
		DESCR = "EVENT_LOOT_ITEM_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			itemName = { name = "itemName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_LOOT_RECEIVED"] = {
		CODE = EVENT_LOOT_RECEIVED,
		DESCR = "EVENT_LOOT_RECEIVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			receivedBy = { name = "receivedBy", dataType = "string", paramNum = 2 },
			itemName = { name = "itemName", dataType = "string", paramNum = 3 },
			quantity = { name = "quantity", dataType = "integer", paramNum = 4 },
			itemSound = { name = "itemSound", dataType = "integer", paramNum = 5 },
			lootType = { name = "lootType", dataType = "integer", paramNum = 6 },
			self = { name = "self", dataType = "bool", paramNum = 7 },
		},
	},
	["EVENT_LOOT_UPDATED"] = {
		CODE = EVENT_LOOT_UPDATED,
		DESCR = "EVENT_LOOT_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_LORE_BOOK_ALREADY_KNOWN"] = {
		CODE = EVENT_LORE_BOOK_ALREADY_KNOWN,
		DESCR = "EVENT_LORE_BOOK_ALREADY_KNOWN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bookTitle = { name = "bookTitle", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_LORE_BOOK_LEARNED"] = {
		CODE = EVENT_LORE_BOOK_LEARNED,
		DESCR = "EVENT_LORE_BOOK_LEARNED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			categoryIndex = { name = "categoryIndex", dataType = "luaindex", paramNum = 2 },
			collectionIndex = { name = "collectionIndex", dataType = "luaindex", paramNum = 3 },
			bookIndex = { name = "bookIndex", dataType = "luaindex", paramNum = 4 },
			guildIndex = { name = "guildIndex", dataType = "luaindex", paramNum = 5 },
		},
	},
	["EVENT_LORE_COLLECTION_COMPLETED"] = {
		CODE = EVENT_LORE_COLLECTION_COMPLETED,
		DESCR = "EVENT_LORE_COLLECTION_COMPLETED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			categoryIndex = { name = "categoryIndex", dataType = "luaindex", paramNum = 2 },
			collectionIndex = { name = "collectionIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_LORE_LIBRARY_INITIALIZED"] = {
		CODE = EVENT_LORE_LIBRARY_INITIALIZED,
		DESCR = "EVENT_LORE_LIBRARY_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MAIL_ATTACHED_MONEY_CHANGED"] = {
		CODE = EVENT_MAIL_ATTACHED_MONEY_CHANGED,
		DESCR = "EVENT_MAIL_ATTACHED_MONEY_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			moneyAmount = { name = "moneyAmount", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_MAIL_ATTACHMENT_ADDED"] = {
		CODE = EVENT_MAIL_ATTACHMENT_ADDED,
		DESCR = "EVENT_MAIL_ATTACHMENT_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			attachmentSlot = { name = "attachmentSlot", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_MAIL_ATTACHMENT_REMOVED"] = {
		CODE = EVENT_MAIL_ATTACHMENT_REMOVED,
		DESCR = "EVENT_MAIL_ATTACHMENT_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			attachmentSlot = { name = "attachmentSlot", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_MAIL_CLOSE_MAILBOX"] = {
		CODE = EVENT_MAIL_CLOSE_MAILBOX,
		DESCR = "EVENT_MAIL_CLOSE_MAILBOX",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MAIL_COD_CHANGED"] = {
		CODE = EVENT_MAIL_COD_CHANGED,
		DESCR = "EVENT_MAIL_COD_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			codAmount = { name = "codAmount", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_MAIL_INBOX_UPDATE"] = {
		CODE = EVENT_MAIL_INBOX_UPDATE,
		DESCR = "EVENT_MAIL_INBOX_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MAIL_NUM_UNREAD_CHANGED"] = {
		CODE = EVENT_MAIL_NUM_UNREAD_CHANGED,
		DESCR = "EVENT_MAIL_NUM_UNREAD_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			numUnread = { name = "numUnread", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_MAIL_OPEN_MAILBOX"] = {
		CODE = EVENT_MAIL_OPEN_MAILBOX,
		DESCR = "EVENT_MAIL_OPEN_MAILBOX",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MAIL_READABLE"] = {
		CODE = EVENT_MAIL_READABLE,
		DESCR = "EVENT_MAIL_READABLE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mailId = { name = "mailId", dataType = "id64", paramNum = 2 },
		},
	},
	["EVENT_MAIL_REMOVED"] = {
		CODE = EVENT_MAIL_REMOVED,
		DESCR = "EVENT_MAIL_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mailId = { name = "mailId", dataType = "id64", paramNum = 2 },
		},
	},
	["EVENT_MAIL_SEND_FAILED"] = {
		CODE = EVENT_MAIL_SEND_FAILED,
		DESCR = "EVENT_MAIL_SEND_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_MAIL_SEND_SUCCESS"] = {
		CODE = EVENT_MAIL_SEND_SUCCESS,
		DESCR = "EVENT_MAIL_SEND_SUCCESS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS"] = {
		CODE = EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS,
		DESCR = "EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mailId = { name = "mailId", dataType = "id64", paramNum = 2 },
		},
	},
	["EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS"] = {
		CODE = EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS,
		DESCR = "EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mailId = { name = "mailId", dataType = "id64", paramNum = 2 },
		},
	},
	["EVENT_MAP_PING"] = {
		CODE = EVENT_MAP_PING,
		DESCR = "EVENT_MAP_PING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			pingEventType = { name = "pingEventType", dataType = "integer", paramNum = 2 },
			pingType = { name = "pingType", dataType = "integer", paramNum = 3 },
			pingTag = { name = "pingTag", dataType = "string", paramNum = 4 },
			offsetX = { name = "offsetX", dataType = "number", paramNum = 5 },
			offsetY = { name = "offsetY", dataType = "number", paramNum = 6 },
		},
	},
	["EVENT_MEDAL_AWARDED"] = {
		CODE = EVENT_MEDAL_AWARDED,
		DESCR = "EVENT_MEDAL_AWARDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			name = { name = "name", dataType = "string", paramNum = 2 },
			texture = { name = "texture", dataType = "string", paramNum = 3 },
			condition = { name = "condition", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_MINIMAP_FILTERS_INITIALIZED"] = {
		CODE = EVENT_MINIMAP_FILTERS_INITIALIZED,
		DESCR = "EVENT_MINIMAP_FILTERS_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MISSING_LURE"] = {
		CODE = EVENT_MISSING_LURE,
		DESCR = "EVENT_MISSING_LURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MONEY_UPDATE"] = {
		CODE = EVENT_MONEY_UPDATE,
		DESCR = "EVENT_MONEY_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newMoney = { name = "newMoney", dataType = "integer", paramNum = 2 },
			oldMoney = { name = "oldMoney", dataType = "integer", paramNum = 3 },
			reason = { name = "reason", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_MOUNTED_STATE_CHANGED"] = {
		CODE = EVENT_MOUNTED_STATE_CHANGED,
		DESCR = "EVENT_MOUNTED_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mounted = { name = "mounted", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_MOUNTS_FULL_UPDATE"] = {
		CODE = EVENT_MOUNTS_FULL_UPDATE,
		DESCR = "EVENT_MOUNTS_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MOUNT_FAILURE"] = {
		CODE = EVENT_MOUNT_FAILURE,
		DESCR = "EVENT_MOUNT_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			arg1 = { name = "arg1", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_MOUNT_UPDATE"] = {
		CODE = EVENT_MOUNT_UPDATE,
		DESCR = "EVENT_MOUNT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			mountIndex = { name = "mountIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_MOUSEOVER_CHANGED"] = {
		CODE = EVENT_MOUSEOVER_CHANGED,
		DESCR = "EVENT_MOUSEOVER_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_MOUSE_REQUEST_ABANDON_QUEST"] = {
		CODE = EVENT_MOUSE_REQUEST_ABANDON_QUEST,
		DESCR = "EVENT_MOUSE_REQUEST_ABANDON_QUEST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			name = { name = "name", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_MOUSE_REQUEST_DESTROY_ITEM"] = {
		CODE = EVENT_MOUSE_REQUEST_DESTROY_ITEM,
		DESCR = "EVENT_MOUSE_REQUEST_DESTROY_ITEM",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bagId = { name = "bagId", dataType = "integer", paramNum = 2 },
			slotIndex = { name = "slotIndex", dataType = "integer", paramNum = 3 },
			itemCount = { name = "itemCount", dataType = "integer", paramNum = 4 },
			name = { name = "name", dataType = "string", paramNum = 5 },
			needsConfirm = { name = "needsConfirm", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_NEW_DISCOVERY_AREA"] = {
		CODE = EVENT_NEW_DISCOVERY_AREA,
		DESCR = "EVENT_NEW_DISCOVERY_AREA",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			zoneName = { name = "zoneName", dataType = "string", paramNum = 2 },
			discoveryName = { name = "discoveryName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_NEW_MOVEMENT_IN_UI_MODE"] = {
		CODE = EVENT_NEW_MOVEMENT_IN_UI_MODE,
		DESCR = "EVENT_NEW_MOVEMENT_IN_UI_MODE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_NEW_REVEAL"] = {
		CODE = EVENT_NEW_REVEAL,
		DESCR = "EVENT_NEW_REVEAL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			revealIndex = { name = "revealIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_NON_COMBAT_BONUS_CHANGED"] = {
		CODE = EVENT_NON_COMBAT_BONUS_CHANGED,
		DESCR = "EVENT_NON_COMBAT_BONUS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			nonConbatBonus = { name = "nonConbatBonus", dataType = "integer", paramNum = 2 },
			oldValue = { name = "oldValue", dataType = "integer", paramNum = 3 },
			newValue = { name = "newValue", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_NOT_ENOUGH_MONEY"] = {
		CODE = EVENT_NOT_ENOUGH_MONEY,
		DESCR = "EVENT_NOT_ENOUGH_MONEY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OBJECTIVES_UPDATED"] = {
		CODE = EVENT_OBJECTIVES_UPDATED,
		DESCR = "EVENT_OBJECTIVES_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OBJECTIVE_COMPLETED"] = {
		CODE = EVENT_OBJECTIVE_COMPLETED,
		DESCR = "EVENT_OBJECTIVE_COMPLETED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			zoneIndex = { name = "zoneIndex", dataType = "luaindex", paramNum = 2 },
			poiIndex = { name = "poiIndex", dataType = "luaindex", paramNum = 3 },
			xpGained = { name = "xpGained", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_OBJECTIVE_CONTROL_STATE"] = {
		CODE = EVENT_OBJECTIVE_CONTROL_STATE,
		DESCR = "EVENT_OBJECTIVE_CONTROL_STATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			objectiveKeepId = { name = "objectiveKeepId", dataType = "integer", paramNum = 2 },
			objectiveObjectiveId = { name = "objectiveObjectiveId", dataType = "integer", paramNum = 3 },
			battlegroundContext = { name = "battlegroundContext", dataType = "integer", paramNum = 4 },
			objectiveName = { name = "objectiveName", dataType = "string", paramNum = 5 },
			objectiveType = { name = "objectiveType", dataType = "integer", paramNum = 6 },
			objectiveControlEvent = { name = "objectiveControlEvent", dataType = "integer", paramNum = 7 },
			objectiveControlState = { name = "objectiveControlState", dataType = "integer", paramNum = 8 },
			objectiveParam1 = { name = "objectiveParam1", dataType = "integer", paramNum = 9 },
			objectiveParam2 = { name = "objectiveParam2", dataType = "integer", paramNum = 10 },
		},
	},
	["EVENT_OPEN_BANK"] = {
		CODE = EVENT_OPEN_BANK,
		DESCR = "EVENT_OPEN_BANK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OPEN_GUILD_BANK"] = {
		CODE = EVENT_OPEN_GUILD_BANK,
		DESCR = "EVENT_OPEN_GUILD_BANK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OPEN_HOOK_POINT_STORE"] = {
		CODE = EVENT_OPEN_HOOK_POINT_STORE,
		DESCR = "EVENT_OPEN_HOOK_POINT_STORE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OPEN_STORE"] = {
		CODE = EVENT_OPEN_STORE,
		DESCR = "EVENT_OPEN_STORE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_OPEN_TRADING_HOUSE"] = {
		CODE = EVENT_OPEN_TRADING_HOUSE,
		DESCR = "EVENT_OPEN_TRADING_HOUSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_ACTIVATED"] = {
		CODE = EVENT_PLAYER_ACTIVATED,
		DESCR = "EVENT_PLAYER_ACTIVATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_ALIVE"] = {
		CODE = EVENT_PLAYER_ALIVE,
		DESCR = "EVENT_PLAYER_ALIVE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_AURA_UPDATE"] = {
		CODE = EVENT_PLAYER_AURA_UPDATE,
		DESCR = "EVENT_PLAYER_AURA_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			auraIndex = { name = "auraIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_PLAYER_COMBAT_STATE"] = {
		CODE = EVENT_PLAYER_COMBAT_STATE,
		DESCR = "EVENT_PLAYER_COMBAT_STATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inCombat = { name = "inCombat", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_PLAYER_DEACTIVATED"] = {
		CODE = EVENT_PLAYER_DEACTIVATED,
		DESCR = "EVENT_PLAYER_DEACTIVATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_DEAD"] = {
		CODE = EVENT_PLAYER_DEAD,
		DESCR = "EVENT_PLAYER_DEAD",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_DEATH_INFO_UPDATE"] = {
		CODE = EVENT_PLAYER_DEATH_INFO_UPDATE,
		DESCR = "EVENT_PLAYER_DEATH_INFO_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_DEATH_REQUEST_FAILURE"] = {
		CODE = EVENT_PLAYER_DEATH_REQUEST_FAILURE,
		DESCR = "EVENT_PLAYER_DEATH_REQUEST_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLAYER_IN_PIN_AREA_CHANGED"] = {
		CODE = EVENT_PLAYER_IN_PIN_AREA_CHANGED,
		DESCR = "EVENT_PLAYER_IN_PIN_AREA_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			pinType = { name = "pinType", dataType = "integer", paramNum = 2 },
			param1 = { name = "param1", dataType = "integer", paramNum = 3 },
			param2 = { name = "param2", dataType = "integer", paramNum = 4 },
			param3 = { name = "param3", dataType = "integer", paramNum = 5 },
			playerIsInside = { name = "playerIsInside", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_PLAYER_TITLES_UPDATE"] = {
		CODE = EVENT_PLAYER_TITLES_UPDATE,
		DESCR = "EVENT_PLAYER_TITLES_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLEDGE_OF_MARA_OFFER"] = {
		CODE = EVENT_PLEDGE_OF_MARA_OFFER,
		DESCR = "EVENT_PLEDGE_OF_MARA_OFFER",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			targetName = { name = "targetName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_PLEDGE_OF_MARA_OFFER_REMOVED"] = {
		CODE = EVENT_PLEDGE_OF_MARA_OFFER_REMOVED,
		DESCR = "EVENT_PLEDGE_OF_MARA_OFFER_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_PLEDGE_OF_MARA_RESULT"] = {
		CODE = EVENT_PLEDGE_OF_MARA_RESULT,
		DESCR = "EVENT_PLEDGE_OF_MARA_RESULT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			targetName = { name = "targetName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_POIS_INITIALIZED"] = {
		CODE = EVENT_POIS_INITIALIZED,
		DESCR = "EVENT_POIS_INITIALIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_POI_DISCOVERED"] = {
		CODE = EVENT_POI_DISCOVERED,
		DESCR = "EVENT_POI_DISCOVERED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			zoneIndex = { name = "zoneIndex", dataType = "luaindex", paramNum = 2 },
			poiIndex = { name = "poiIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_POI_UPDATED"] = {
		CODE = EVENT_POI_UPDATED,
		DESCR = "EVENT_POI_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			zoneIndex = { name = "zoneIndex", dataType = "luaindex", paramNum = 2 },
			poiIndex = { name = "poiIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_POWER_UPDATE"] = {
		CODE = EVENT_POWER_UPDATE,
		DESCR = "EVENT_POWER_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			powerIndex = { name = "powerIndex", dataType = "luaindex", paramNum = 3 },
			powerType = { name = "powerType", dataType = "integer", paramNum = 4 },
			powerValue = { name = "powerValue", dataType = "integer", paramNum = 5 },
			powerMax = { name = "powerMax", dataType = "integer", paramNum = 6 },
			powerEffectiveMax = { name = "powerEffectiveMax", dataType = "integer", paramNum = 7 },
		},
	},
	["EVENT_PREFERRED_CAMPAIGN_CHANGED"] = {
		CODE = EVENT_PREFERRED_CAMPAIGN_CHANGED,
		DESCR = "EVENT_PREFERRED_CAMPAIGN_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			newPreferredCampaignId = { name = "newPreferredCampaignId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_PREFERRED_TARGET_HIGHLIGHT_UPDATE"] = {
		CODE = EVENT_PREFERRED_TARGET_HIGHLIGHT_UPDATE,
		DESCR = "EVENT_PREFERRED_TARGET_HIGHLIGHT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			highlighted = { name = "highlighted", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_PVP_FLAG_CHANGED"] = {
		CODE = EVENT_PVP_FLAG_CHANGED,
		DESCR = "EVENT_PVP_FLAG_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			isEnabled = { name = "isEnabled", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_QUEST_ADDED"] = {
		CODE = EVENT_QUEST_ADDED,
		DESCR = "EVENT_QUEST_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			questName = { name = "questName", dataType = "string", paramNum = 3 },
			objectiveName = { name = "objectiveName", dataType = "string", paramNum = 4 },
		},
	},
	["EVENT_QUEST_ADVANCED"] = {
		CODE = EVENT_QUEST_ADVANCED,
		DESCR = "EVENT_QUEST_ADVANCED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			questName = { name = "questName", dataType = "string", paramNum = 3 },
			isPushed = { name = "isPushed", dataType = "bool", paramNum = 4 },
			isComplete = { name = "isComplete", dataType = "bool", paramNum = 5 },
			mainStepChanged = { name = "mainStepChanged", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL"] = {
		CODE = EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL,
		DESCR = "EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_QUEST_COMPLETE_DIALOG"] = {
		CODE = EVENT_QUEST_COMPLETE_DIALOG,
		DESCR = "EVENT_QUEST_COMPLETE_DIALOG",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_QUEST_COMPLETE_EXPERIENCE"] = {
		CODE = EVENT_QUEST_COMPLETE_EXPERIENCE,
		DESCR = "EVENT_QUEST_COMPLETE_EXPERIENCE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			questName = { name = "questName", dataType = "string", paramNum = 2 },
			xpGained = { name = "xpGained", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_QUEST_CONDITION_COUNTER_CHANGED"] = {
		CODE = EVENT_QUEST_CONDITION_COUNTER_CHANGED,
		DESCR = "EVENT_QUEST_CONDITION_COUNTER_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			questName = { name = "questName", dataType = "string", paramNum = 3 },
			conditionText = { name = "conditionText", dataType = "string", paramNum = 4 },
			conditionType = { name = "conditionType", dataType = "integer", paramNum = 5 },
			currConditionVal = { name = "currConditionVal", dataType = "integer", paramNum = 6 },
			newConditionVal = { name = "newConditionVal", dataType = "integer", paramNum = 7 },
			conditionMax = { name = "conditionMax", dataType = "integer", paramNum = 8 },
			isFailCondition = { name = "isFailCondition", dataType = "bool", paramNum = 9 },
			stepOverrideText = { name = "stepOverrideText", dataType = "string", paramNum = 10 },
			isPushed = { name = "isPushed", dataType = "bool", paramNum = 11 },
			isComplete = { name = "isComplete", dataType = "bool", paramNum = 12 },
			isConditionComplete = { name = "isConditionComplete", dataType = "bool", paramNum = 13 },
			isStepHidden = { name = "isStepHidden", dataType = "bool", paramNum = 14 },
		},
	},
	["EVENT_QUEST_DAILY_COUNT_CHANGED"] = {
		CODE = EVENT_QUEST_DAILY_COUNT_CHANGED,
		DESCR = "EVENT_QUEST_DAILY_COUNT_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			dailyCount = { name = "dailyCount", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_QUEST_INTERACT_DIALOG"] = {
		CODE = EVENT_QUEST_INTERACT_DIALOG,
		DESCR = "EVENT_QUEST_INTERACT_DIALOG",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_QUEST_LIST_UPDATED"] = {
		CODE = EVENT_QUEST_LIST_UPDATED,
		DESCR = "EVENT_QUEST_LIST_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_QUEST_OFFERED"] = {
		CODE = EVENT_QUEST_OFFERED,
		DESCR = "EVENT_QUEST_OFFERED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			questIndex = { name = "questIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_QUEST_POSITION_REQUEST_COMPLETE"] = {
		CODE = EVENT_QUEST_POSITION_REQUEST_COMPLETE,
		DESCR = "EVENT_QUEST_POSITION_REQUEST_COMPLETE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			taskId = { name = "taskId", dataType = "integer", paramNum = 2 },
			pinType = { name = "pinType", dataType = "integer", paramNum = 3 },
			xLoc = { name = "xLoc", dataType = "number", paramNum = 4 },
			yLoc = { name = "yLoc", dataType = "number", paramNum = 5 },
			areaRadius = { name = "areaRadius", dataType = "number", paramNum = 6 },
			insideCurrentMapWorld = { name = "insideCurrentMapWorld", dataType = "bool", paramNum = 7 },
		},
	},
	["EVENT_QUEST_REMOVED"] = {
		CODE = EVENT_QUEST_REMOVED,
		DESCR = "EVENT_QUEST_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			isCompleted = { name = "isCompleted", dataType = "bool", paramNum = 2 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 3 },
			questName = { name = "questName", dataType = "string", paramNum = 4 },
			zoneIndex = { name = "zoneIndex", dataType = "luaindex", paramNum = 5 },
			poiIndex = { name = "poiIndex", dataType = "luaindex", paramNum = 6 },
		},
	},
	["EVENT_QUEST_SHARED"] = {
		CODE = EVENT_QUEST_SHARED,
		DESCR = "EVENT_QUEST_SHARED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			questId = { name = "questId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_QUEST_SHARE_REMOVED"] = {
		CODE = EVENT_QUEST_SHARE_REMOVED,
		DESCR = "EVENT_QUEST_SHARE_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			questId = { name = "questId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_QUEST_SHARE_UPDATE"] = {
		CODE = EVENT_QUEST_SHARE_UPDATE,
		DESCR = "EVENT_QUEST_SHARE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			update = { name = "update", dataType = "integer", paramNum = 2 },
			playerName = { name = "playerName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_QUEST_SHOW_JOURNAL_ENTRY"] = {
		CODE = EVENT_QUEST_SHOW_JOURNAL_ENTRY,
		DESCR = "EVENT_QUEST_SHOW_JOURNAL_ENTRY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_QUEST_TIMER_PAUSED"] = {
		CODE = EVENT_QUEST_TIMER_PAUSED,
		DESCR = "EVENT_QUEST_TIMER_PAUSED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			isPaused = { name = "isPaused", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_QUEST_TIMER_UPDATED"] = {
		CODE = EVENT_QUEST_TIMER_UPDATED,
		DESCR = "EVENT_QUEST_TIMER_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_QUEST_TOOL_UPDATED"] = {
		CODE = EVENT_QUEST_TOOL_UPDATED,
		DESCR = "EVENT_QUEST_TOOL_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			journalIndex = { name = "journalIndex", dataType = "luaindex", paramNum = 2 },
			questName = { name = "questName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE"] = {
		CODE = EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE,
		DESCR = "EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			response = { name = "response", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_RAM_ESCORT_COUNT_UPDATE"] = {
		CODE = EVENT_RAM_ESCORT_COUNT_UPDATE,
		DESCR = "EVENT_RAM_ESCORT_COUNT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			numEscorts = { name = "numEscorts", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_RANK_POINT_UPDATE"] = {
		CODE = EVENT_RANK_POINT_UPDATE,
		DESCR = "EVENT_RANK_POINT_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			rankPoints = { name = "rankPoints", dataType = "integer", paramNum = 3 },
			difference = { name = "difference", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_REASSIGN_CAMPAIGN_FAILED"] = {
		CODE = EVENT_REASSIGN_CAMPAIGN_FAILED,
		DESCR = "EVENT_REASSIGN_CAMPAIGN_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_RECIPE_LEARNED"] = {
		CODE = EVENT_RECIPE_LEARNED,
		DESCR = "EVENT_RECIPE_LEARNED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			recipeListIndex = { name = "recipeListIndex", dataType = "luaindex", paramNum = 2 },
			recipeIndex = { name = "recipeIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_REMOVE_ACTIVE_COMBAT_TIP"] = {
		CODE = EVENT_REMOVE_ACTIVE_COMBAT_TIP,
		DESCR = "EVENT_REMOVE_ACTIVE_COMBAT_TIP",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			activeCombatTipId = { name = "activeCombatTipId", dataType = "integer", paramNum = 2 },
			result = { name = "result", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_REMOVE_TUTORIAL"] = {
		CODE = EVENT_REMOVE_TUTORIAL,
		DESCR = "EVENT_REMOVE_TUTORIAL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			tutorialIndex = { name = "tutorialIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_REQUIREMENTS_FAIL"] = {
		CODE = EVENT_REQUIREMENTS_FAIL,
		DESCR = "EVENT_REQUIREMENTS_FAIL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			errorId = { name = "errorId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_RESURRECT_FAILURE"] = {
		CODE = EVENT_RESURRECT_FAILURE,
		DESCR = "EVENT_RESURRECT_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			targetName = { name = "targetName", dataType = "string", paramNum = 2 },
			reason = { name = "reason", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_RESURRECT_REQUEST"] = {
		CODE = EVENT_RESURRECT_REQUEST,
		DESCR = "EVENT_RESURRECT_REQUEST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			requester = { name = "requester", dataType = "string", paramNum = 2 },
			timeLeftToAccept = { name = "timeLeftToAccept", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_RESURRECT_REQUEST_REMOVED"] = {
		CODE = EVENT_RESURRECT_REQUEST_REMOVED,
		DESCR = "EVENT_RESURRECT_REQUEST_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_RETICLE_HIDDEN_UPDATE"] = {
		CODE = EVENT_RETICLE_HIDDEN_UPDATE,
		DESCR = "EVENT_RETICLE_HIDDEN_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			hidden = { name = "hidden", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_RETICLE_TARGET_CHANGED"] = {
		CODE = EVENT_RETICLE_TARGET_CHANGED,
		DESCR = "EVENT_RETICLE_TARGET_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_REVENGE_KILL"] = {
		CODE = EVENT_REVENGE_KILL,
		DESCR = "EVENT_REVENGE_KILL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			killedPlayerName = { name = "killedPlayerName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_SCRIPTED_WORLD_EVENT_INVITE"] = {
		CODE = EVENT_SCRIPTED_WORLD_EVENT_INVITE,
		DESCR = "EVENT_SCRIPTED_WORLD_EVENT_INVITE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			eventId = { name = "eventId", dataType = "integer", paramNum = 2 },
			scriptedEventName = { name = "scriptedEventName", dataType = "string", paramNum = 3 },
			inviterName = { name = "inviterName", dataType = "string", paramNum = 4 },
			questName = { name = "questName", dataType = "string", paramNum = 5 },
		},
	},
	["EVENT_SELL_RECEIPT"] = {
		CODE = EVENT_SELL_RECEIPT,
		DESCR = "EVENT_SELL_RECEIPT",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemName = { name = "itemName", dataType = "string", paramNum = 2 },
			itemQuantity = { name = "itemQuantity", dataType = "integer", paramNum = 3 },
			money = { name = "money", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_SERVER_SHUTDOWN_INFO"] = {
		CODE = EVENT_SERVER_SHUTDOWN_INFO,
		DESCR = "EVENT_SERVER_SHUTDOWN_INFO",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			action = { name = "action", dataType = "integer", paramNum = 2 },
			timeRemaining = { name = "timeRemaining", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_SET_CHEVRON"] = {
		CODE = EVENT_SET_CHEVRON,
		DESCR = "EVENT_SET_CHEVRON",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotNum = { name = "slotNum", dataType = "integer", paramNum = 2 },
			percent = { name = "percent", dataType = "number", paramNum = 3 },
		},
	},
	["EVENT_SHOW_BOOK"] = {
		CODE = EVENT_SHOW_BOOK,
		DESCR = "EVENT_SHOW_BOOK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bookTitle = { name = "bookTitle", dataType = "string", paramNum = 2 },
			body = { name = "body", dataType = "string", paramNum = 3 },
			medium = { name = "medium", dataType = "integer", paramNum = 4 },
			showTitle = { name = "showTitle", dataType = "bool", paramNum = 5 },
		},
	},
	["EVENT_SHOW_LINKED_CAST"] = {
		CODE = EVENT_SHOW_LINKED_CAST,
		DESCR = "EVENT_SHOW_LINKED_CAST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			linkTime = { name = "linkTime", dataType = "number", paramNum = 2 },
		},
	},
	["EVENT_SHOW_SCOREBOARD"] = {
		CODE = EVENT_SHOW_SCOREBOARD,
		DESCR = "EVENT_SHOW_SCOREBOARD",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SHOW_SCOREBUTTON"] = {
		CODE = EVENT_SHOW_SCOREBUTTON,
		DESCR = "EVENT_SHOW_SCOREBUTTON",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SHOW_TIME"] = {
		CODE = EVENT_SHOW_TIME,
		DESCR = "EVENT_SHOW_TIME",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			state = { name = "state", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_SHOW_TREASURE_MAP"] = {
		CODE = EVENT_SHOW_TREASURE_MAP,
		DESCR = "EVENT_SHOW_TREASURE_MAP",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			treasureMapIndex = { name = "treasureMapIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_SIEGE_BUSY"] = {
		CODE = EVENT_SIEGE_BUSY,
		DESCR = "EVENT_SIEGE_BUSY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			siegeName = { name = "siegeName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_SIEGE_CONTROL_ANOTHER_PLAYER"] = {
		CODE = EVENT_SIEGE_CONTROL_ANOTHER_PLAYER,
		DESCR = "EVENT_SIEGE_CONTROL_ANOTHER_PLAYER",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			siegeName = { name = "siegeName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM"] = {
		CODE = EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM,
		DESCR = "EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR"] = {
		CODE = EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR,
		DESCR = "EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SIEGE_FIRE_FAILED_COOLDOWN"] = {
		CODE = EVENT_SIEGE_FIRE_FAILED_COOLDOWN,
		DESCR = "EVENT_SIEGE_FIRE_FAILED_COOLDOWN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SIEGE_FIRE_FAILED_RETARGETING"] = {
		CODE = EVENT_SIEGE_FIRE_FAILED_RETARGETING,
		DESCR = "EVENT_SIEGE_FIRE_FAILED_RETARGETING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL"] = {
		CODE = EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL,
		DESCR = "EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SIEGE_PACK_FAILED_NOT_CREATOR"] = {
		CODE = EVENT_SIEGE_PACK_FAILED_NOT_CREATOR,
		DESCR = "EVENT_SIEGE_PACK_FAILED_NOT_CREATOR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SKILLS_FULL_UPDATE"] = {
		CODE = EVENT_SKILLS_FULL_UPDATE,
		DESCR = "EVENT_SKILLS_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SKILL_ADDEDFORCE_RESPEC"] = {
		CODE = EVENT_SKILL_ADDEDFORCE_RESPEC,
		DESCR = "EVENT_SKILL_ADDEDFORCE_RESPEC",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SKILL_LINE_ADDED"] = {
		CODE = EVENT_SKILL_LINE_ADDED,
		DESCR = "EVENT_SKILL_LINE_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			skillType = { name = "skillType", dataType = "integer", paramNum = 2 },
			skillIndex = { name = "skillIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_SKILL_POINTS_CHANGED"] = {
		CODE = EVENT_SKILL_POINTS_CHANGED,
		DESCR = "EVENT_SKILL_POINTS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			pointsBefore = { name = "pointsBefore", dataType = "integer", paramNum = 2 },
			pointsNow = { name = "pointsNow", dataType = "integer", paramNum = 3 },
			isSkyShard = { name = "isSkyShard", dataType = "bool", paramNum = 4 },
		},
	},
	["EVENT_SKILL_RANK_UPDATE"] = {
		CODE = EVENT_SKILL_RANK_UPDATE,
		DESCR = "EVENT_SKILL_RANK_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			skillType = { name = "skillType", dataType = "integer", paramNum = 2 },
			skillIndex = { name = "skillIndex", dataType = "luaindex", paramNum = 3 },
			rank = { name = "rank", dataType = "luaindex", paramNum = 4 },
		},
	},
	["EVENT_SKILL_XP_UPDATE"] = {
		CODE = EVENT_SKILL_XP_UPDATE,
		DESCR = "EVENT_SKILL_XP_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			skillType = { name = "skillType", dataType = "integer", paramNum = 2 },
			skillIndex = { name = "skillIndex", dataType = "luaindex", paramNum = 3 },
			lastRankXP = { name = "lastRankXP", dataType = "integer", paramNum = 4 },
			nextRankXP = { name = "nextRankXP", dataType = "integer", paramNum = 5 },
			currentXP = { name = "currentXP", dataType = "integer", paramNum = 6 },
		},
	},
	["EVENT_SLOT_IS_LOCKED_FAILURE"] = {
		CODE = EVENT_SLOT_IS_LOCKED_FAILURE,
		DESCR = "EVENT_SLOT_IS_LOCKED_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			bagId = { name = "bagId", dataType = "integer", paramNum = 2 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED"] = {
		CODE = EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
		DESCR = "EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			craftingSkillType = { name = "craftingSkillType", dataType = "integer", paramNum = 2 },
			researchLineIndex = { name = "researchLineIndex", dataType = "luaindex", paramNum = 3 },
			traitIndex = { name = "traitIndex", dataType = "luaindex", paramNum = 4 },
		},
	},
	["EVENT_SMITHING_TRAIT_RESEARCH_STARTED"] = {
		CODE = EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
		DESCR = "EVENT_SMITHING_TRAIT_RESEARCH_STARTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			craftingSkillType = { name = "craftingSkillType", dataType = "integer", paramNum = 2 },
			researchLineIndex = { name = "researchLineIndex", dataType = "luaindex", paramNum = 3 },
			traitIndex = { name = "traitIndex", dataType = "luaindex", paramNum = 4 },
		},
	},
	["EVENT_SOCKETING_ITEM_ALREADY_HAS_PROPERTY"] = {
		CODE = EVENT_SOCKETING_ITEM_ALREADY_HAS_PROPERTY,
		DESCR = "EVENT_SOCKETING_ITEM_ALREADY_HAS_PROPERTY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemLink = { name = "itemLink", dataType = "string", paramNum = 2 },
			property = { name = "property", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_SOCKETING_UNIT_DESTROYED"] = {
		CODE = EVENT_SOCKETING_UNIT_DESTROYED,
		DESCR = "EVENT_SOCKETING_UNIT_DESTROYED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SOCKETING_UNIT_SOCKETS_CHANGED"] = {
		CODE = EVENT_SOCKETING_UNIT_SOCKETS_CHANGED,
		DESCR = "EVENT_SOCKETING_UNIT_SOCKETS_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE"] = {
		CODE = EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE,
		DESCR = "EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_STABLE_INTERACT_END"] = {
		CODE = EVENT_STABLE_INTERACT_END,
		DESCR = "EVENT_STABLE_INTERACT_END",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_STABLE_INTERACT_START"] = {
		CODE = EVENT_STABLE_INTERACT_START,
		DESCR = "EVENT_STABLE_INTERACT_START",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_START_FAST_TRAVEL_INTERACTION"] = {
		CODE = EVENT_START_FAST_TRAVEL_INTERACTION,
		DESCR = "EVENT_START_FAST_TRAVEL_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			nodeIndex = { name = "nodeIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_START_FAST_TRAVEL_KEEP_INTERACTION"] = {
		CODE = EVENT_START_FAST_TRAVEL_KEEP_INTERACTION,
		DESCR = "EVENT_START_FAST_TRAVEL_KEEP_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			keepId = { name = "keepId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_START_KEEP_GUILD_CLAIM_INTERACTION"] = {
		CODE = EVENT_START_KEEP_GUILD_CLAIM_INTERACTION,
		DESCR = "EVENT_START_KEEP_GUILD_CLAIM_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_START_KEEP_GUILD_RELEASE_INTERACTION"] = {
		CODE = EVENT_START_KEEP_GUILD_RELEASE_INTERACTION,
		DESCR = "EVENT_START_KEEP_GUILD_RELEASE_INTERACTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_START_SOUL_GEM_RESURRECTION"] = {
		CODE = EVENT_START_SOUL_GEM_RESURRECTION,
		DESCR = "EVENT_START_SOUL_GEM_RESURRECTION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			durationMs = { name = "durationMs", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_STATS_UPDATED"] = {
		CODE = EVENT_STATS_UPDATED,
		DESCR = "EVENT_STATS_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_STEALTH_STATE_CHANGED"] = {
		CODE = EVENT_STEALTH_STATE_CHANGED,
		DESCR = "EVENT_STEALTH_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			stealthState = { name = "stealthState", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_STORE_FAILURE"] = {
		CODE = EVENT_STORE_FAILURE,
		DESCR = "EVENT_STORE_FAILURE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_STYLE_LEARNED"] = {
		CODE = EVENT_STYLE_LEARNED,
		DESCR = "EVENT_STYLE_LEARNED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			styleIndex = { name = "styleIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_SYNERGY_ABILITY_GAINED"] = {
		CODE = EVENT_SYNERGY_ABILITY_GAINED,
		DESCR = "EVENT_SYNERGY_ABILITY_GAINED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			synergyBuffSlot = { name = "synergyBuffSlot", dataType = "integer", paramNum = 2 },
			grantedAbilityName = { name = "grantedAbilityName", dataType = "string", paramNum = 3 },
			beginTime = { name = "beginTime", dataType = "number", paramNum = 4 },
			endTime = { name = "endTime", dataType = "number", paramNum = 5 },
			iconName = { name = "iconName", dataType = "string", paramNum = 6 },
		},
	},
	["EVENT_SYNERGY_ABILITY_LOST"] = {
		CODE = EVENT_SYNERGY_ABILITY_LOST,
		DESCR = "EVENT_SYNERGY_ABILITY_LOST",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			synergyBuffSlot = { name = "synergyBuffSlot", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_TARGET_CHANGED"] = {
		CODE = EVENT_TARGET_CHANGED,
		DESCR = "EVENT_TARGET_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_TITLE_UPDATE"] = {
		CODE = EVENT_TITLE_UPDATE,
		DESCR = "EVENT_TITLE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_TRACKING_UPDATE"] = {
		CODE = EVENT_TRACKING_UPDATE,
		DESCR = "EVENT_TRACKING_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY"] = {
		CODE = EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY,
		DESCR = "EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_CANCELED"] = {
		CODE = EVENT_TRADE_CANCELED,
		DESCR = "EVENT_TRADE_CANCELED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			cancelerName = { name = "cancelerName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_TRADE_CONFIRMATION_CHANGED"] = {
		CODE = EVENT_TRADE_CONFIRMATION_CHANGED,
		DESCR = "EVENT_TRADE_CONFIRMATION_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			who = { name = "who", dataType = "integer", paramNum = 2 },
			level = { name = "level", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_TRADE_ELEVATION_FAILED"] = {
		CODE = EVENT_TRADE_ELEVATION_FAILED,
		DESCR = "EVENT_TRADE_ELEVATION_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			itemName = { name = "itemName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_TRADE_FAILED"] = {
		CODE = EVENT_TRADE_FAILED,
		DESCR = "EVENT_TRADE_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_TRADE_INVITE_ACCEPTED"] = {
		CODE = EVENT_TRADE_INVITE_ACCEPTED,
		DESCR = "EVENT_TRADE_INVITE_ACCEPTED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_INVITE_CANCELED"] = {
		CODE = EVENT_TRADE_INVITE_CANCELED,
		DESCR = "EVENT_TRADE_INVITE_CANCELED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_INVITE_CONSIDERING"] = {
		CODE = EVENT_TRADE_INVITE_CONSIDERING,
		DESCR = "EVENT_TRADE_INVITE_CONSIDERING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			inviter = { name = "inviter", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_TRADE_INVITE_DECLINED"] = {
		CODE = EVENT_TRADE_INVITE_DECLINED,
		DESCR = "EVENT_TRADE_INVITE_DECLINED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_INVITE_FAILED"] = {
		CODE = EVENT_TRADE_INVITE_FAILED,
		DESCR = "EVENT_TRADE_INVITE_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			name = { name = "name", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_TRADE_INVITE_REMOVED"] = {
		CODE = EVENT_TRADE_INVITE_REMOVED,
		DESCR = "EVENT_TRADE_INVITE_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADE_INVITE_WAITING"] = {
		CODE = EVENT_TRADE_INVITE_WAITING,
		DESCR = "EVENT_TRADE_INVITE_WAITING",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			invitee = { name = "invitee", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_TRADE_ITEM_ADDED"] = {
		CODE = EVENT_TRADE_ITEM_ADDED,
		DESCR = "EVENT_TRADE_ITEM_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			who = { name = "who", dataType = "integer", paramNum = 2 },
			tradeIndex = { name = "tradeIndex", dataType = "luaindex", paramNum = 3 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_TRADE_ITEM_ADD_FAILED"] = {
		CODE = EVENT_TRADE_ITEM_ADD_FAILED,
		DESCR = "EVENT_TRADE_ITEM_ADD_FAILED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			reason = { name = "reason", dataType = "integer", paramNum = 2 },
			itemName = { name = "itemName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_TRADE_ITEM_REMOVED"] = {
		CODE = EVENT_TRADE_ITEM_REMOVED,
		DESCR = "EVENT_TRADE_ITEM_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			who = { name = "who", dataType = "integer", paramNum = 2 },
			tradeIndex = { name = "tradeIndex", dataType = "luaindex", paramNum = 3 },
			itemSoundCategory = { name = "itemSoundCategory", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_TRADE_ITEM_UPDATED"] = {
		CODE = EVENT_TRADE_ITEM_UPDATED,
		DESCR = "EVENT_TRADE_ITEM_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			who = { name = "who", dataType = "integer", paramNum = 2 },
			tradeIndex = { name = "tradeIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_TRADE_MONEY_CHANGED"] = {
		CODE = EVENT_TRADE_MONEY_CHANGED,
		DESCR = "EVENT_TRADE_MONEY_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			who = { name = "who", dataType = "integer", paramNum = 2 },
			money = { name = "money", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_TRADE_SUCCEEDED"] = {
		CODE = EVENT_TRADE_SUCCEEDED,
		DESCR = "EVENT_TRADE_SUCCEEDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRADING_HOUSE_AWAITING_RESPONSE"] = {
		CODE = EVENT_TRADING_HOUSE_AWAITING_RESPONSE,
		DESCR = "EVENT_TRADING_HOUSE_AWAITING_RESPONSE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			responseType = { name = "responseType", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE"] = {
		CODE = EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE,
		DESCR = "EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			pendingPurchaseIndex = { name = "pendingPurchaseIndex", dataType = "luaindex", paramNum = 2 },
		},
	},
	["EVENT_TRADING_HOUSE_ERROR"] = {
		CODE = EVENT_TRADING_HOUSE_ERROR,
		DESCR = "EVENT_TRADING_HOUSE_ERROR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			errorCode = { name = "errorCode", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE"] = {
		CODE = EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE,
		DESCR = "EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			slotId = { name = "slotId", dataType = "integer", paramNum = 2 },
			isPending = { name = "isPending", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_TRADING_HOUSE_RESPONSE_RECEIVED"] = {
		CODE = EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,
		DESCR = "EVENT_TRADING_HOUSE_RESPONSE_RECEIVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			responseType = { name = "responseType", dataType = "integer", paramNum = 2 },
			result = { name = "result", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED"] = {
		CODE = EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED,
		DESCR = "EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			guildId = { name = "guildId", dataType = "integer", paramNum = 2 },
			numItemsOnPage = { name = "numItemsOnPage", dataType = "integer", paramNum = 3 },
			currentPage = { name = "currentPage", dataType = "integer", paramNum = 4 },
			hasMorePages = { name = "hasMorePages", dataType = "bool", paramNum = 5 },
		},
	},
	["EVENT_TRADING_HOUSE_STATUS_RECEIVED"] = {
		CODE = EVENT_TRADING_HOUSE_STATUS_RECEIVED,
		DESCR = "EVENT_TRADING_HOUSE_STATUS_RECEIVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_TRAIT_LEARNED"] = {
		CODE = EVENT_TRAIT_LEARNED,
		DESCR = "EVENT_TRAIT_LEARNED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			itemName = { name = "itemName", dataType = "string", paramNum = 2 },
			itemTrait = { name = "itemTrait", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED"] = {
		CODE = EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED,
		DESCR = "EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			enabled = { name = "enabled", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_UI_ERROR"] = {
		CODE = EVENT_UI_ERROR,
		DESCR = "EVENT_UI_ERROR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			stringId = { name = "stringId", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED"] = {
		CODE = EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,
		DESCR = "EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			unitAttributeVisual = { name = "unitAttributeVisual", dataType = "integer", paramNum = 3 },
			statType = { name = "statType", dataType = "integer", paramNum = 4 },
			attributeType = { name = "attributeType", dataType = "integer", paramNum = 5 },
			powerType = { name = "powerType", dataType = "integer", paramNum = 6 },
			value = { name = "value", dataType = "number", paramNum = 7 },
			maxValue = { name = "maxValue", dataType = "number", paramNum = 8 },
		},
	},
	["EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED"] = {
		CODE = EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
		DESCR = "EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			unitAttributeVisual = { name = "unitAttributeVisual", dataType = "integer", paramNum = 3 },
			statType = { name = "statType", dataType = "integer", paramNum = 4 },
			attributeType = { name = "attributeType", dataType = "integer", paramNum = 5 },
			powerType = { name = "powerType", dataType = "integer", paramNum = 6 },
			value = { name = "value", dataType = "number", paramNum = 7 },
			maxValue = { name = "maxValue", dataType = "number", paramNum = 8 },
		},
	},
	["EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED"] = {
		CODE = EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,
		DESCR = "EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			unitAttributeVisual = { name = "unitAttributeVisual", dataType = "integer", paramNum = 3 },
			statType = { name = "statType", dataType = "integer", paramNum = 4 },
			attributeType = { name = "attributeType", dataType = "integer", paramNum = 5 },
			powerType = { name = "powerType", dataType = "integer", paramNum = 6 },
			oldValue = { name = "oldValue", dataType = "number", paramNum = 7 },
			newValue = { name = "newValue", dataType = "number", paramNum = 8 },
			oldMaxValue = { name = "oldMaxValue", dataType = "number", paramNum = 9 },
			newMaxValue = { name = "newMaxValue", dataType = "number", paramNum = 10 },
		},
	},
	["EVENT_UNIT_CREATED"] = {
		CODE = EVENT_UNIT_CREATED,
		DESCR = "EVENT_UNIT_CREATED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_UNIT_DEATH_STATE_CHANGED"] = {
		CODE = EVENT_UNIT_DEATH_STATE_CHANGED,
		DESCR = "EVENT_UNIT_DEATH_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			isDead = { name = "isDead", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_UNIT_DESTROYED"] = {
		CODE = EVENT_UNIT_DESTROYED,
		DESCR = "EVENT_UNIT_DESTROYED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_UNIT_FRAME_UPDATE"] = {
		CODE = EVENT_UNIT_FRAME_UPDATE,
		DESCR = "EVENT_UNIT_FRAME_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_UPDATE_BUYBACK"] = {
		CODE = EVENT_UPDATE_BUYBACK,
		DESCR = "EVENT_UPDATE_BUYBACK",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_UPDATE_GAME_STATE"] = {
		CODE = EVENT_UPDATE_GAME_STATE,
		DESCR = "EVENT_UPDATE_GAME_STATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_VETERAN_DIFFICULTY_CHANGED"] = {
		CODE = EVENT_VETERAN_DIFFICULTY_CHANGED,
		DESCR = "EVENT_VETERAN_DIFFICULTY_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			isDifficult = { name = "isDifficult", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_VETERAN_POINTS_UPDATE"] = {
		CODE = EVENT_VETERAN_POINTS_UPDATE,
		DESCR = "EVENT_VETERAN_POINTS_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			currentPoints = { name = "currentPoints", dataType = "integer", paramNum = 3 },
			maxPoints = { name = "maxPoints", dataType = "integer", paramNum = 4 },
			reason = { name = "reason", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_VETERAN_RANK_UPDATE"] = {
		CODE = EVENT_VETERAN_RANK_UPDATE,
		DESCR = "EVENT_VETERAN_RANK_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			rank = { name = "rank", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_WEAPON_SET_FULL_UPDATE"] = {
		CODE = EVENT_WEAPON_SET_FULL_UPDATE,
		DESCR = "EVENT_WEAPON_SET_FULL_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_WEAPON_SET_RANK_UPDATE"] = {
		CODE = EVENT_WEAPON_SET_RANK_UPDATE,
		DESCR = "EVENT_WEAPON_SET_RANK_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			weaponSetIndex = { name = "weaponSetIndex", dataType = "integer", paramNum = 2 },
			rank = { name = "rank", dataType = "integer", paramNum = 3 },
			maxRank = { name = "maxRank", dataType = "integer", paramNum = 4 },
		},
	},
	["EVENT_WEAPON_SET_XP_UPDATE"] = {
		CODE = EVENT_WEAPON_SET_XP_UPDATE,
		DESCR = "EVENT_WEAPON_SET_XP_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			weaponSetIndex = { name = "weaponSetIndex", dataType = "integer", paramNum = 2 },
			lastRankXP = { name = "lastRankXP", dataType = "integer", paramNum = 3 },
			nextRankXP = { name = "nextRankXP", dataType = "integer", paramNum = 4 },
			currentXP = { name = "currentXP", dataType = "integer", paramNum = 5 },
		},
	},
	["EVENT_WEAPON_SWAP_LOCKED"] = {
		CODE = EVENT_WEAPON_SWAP_LOCKED,
		DESCR = "EVENT_WEAPON_SWAP_LOCKED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			swapLevel = { name = "swapLevel", dataType = "integer", paramNum = 2 },
		},
	},
	["EVENT_WEREWOLF_STATE_CHANGED"] = {
		CODE = EVENT_WEREWOLF_STATE_CHANGED,
		DESCR = "EVENT_WEREWOLF_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			werewolf = { name = "werewolf", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_ZONE_CHANGED"] = {
		CODE = EVENT_ZONE_CHANGED,
		DESCR = "EVENT_ZONE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			zoneName = { name = "zoneName", dataType = "string", paramNum = 2 },
			subZoneName = { name = "subZoneName", dataType = "string", paramNum = 3 },
			newSubzone = { name = "newSubzone", dataType = "bool", paramNum = 4 },
		},
	},
	["EVENT_ZONE_CHANNEL_CHANGED"] = {
		CODE = EVENT_ZONE_CHANNEL_CHANGED,
		DESCR = "EVENT_ZONE_CHANNEL_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ZONE_SCORING_CHANGED"] = {
		CODE = EVENT_ZONE_SCORING_CHANGED,
		DESCR = "EVENT_ZONE_SCORING_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_ZONE_UPDATE"] = {
		CODE = EVENT_ZONE_UPDATE,
		DESCR = "EVENT_ZONE_UPDATE",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			unitTag = { name = "unitTag", dataType = "string", paramNum = 2 },
			newZoneName = { name = "newZoneName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_ACTION_LAYER_POPPED"] = {
		CODE = EVENT_ACTION_LAYER_POPPED,
		DESCR = "EVENT_ACTION_LAYER_POPPED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			layerIndex = { name = "layerIndex", dataType = "luaindex", paramNum = 2 },
			activeLayerIndex = { name = "activeLayerIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_ACTION_LAYER_PUSHED"] = {
		CODE = EVENT_ACTION_LAYER_PUSHED,
		DESCR = "EVENT_ACTION_LAYER_PUSHED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			layerIndex = { name = "layerIndex", dataType = "luaindex", paramNum = 2 },
			activeLayerIndex = { name = "activeLayerIndex", dataType = "luaindex", paramNum = 3 },
		},
	},
	["EVENT_ADD_ON_LOADED"] = {
		CODE = EVENT_ADD_ON_LOADED,
		DESCR = "EVENT_ADD_ON_LOADED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			addonName = { name = "addonName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_CAPS_LOCK_STATE_CHANGED"] = {
		CODE = EVENT_CAPS_LOCK_STATE_CHANGED,
		DESCR = "EVENT_CAPS_LOCK_STATE_CHANGED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			capsLockEnabled = { name = "capsLockEnabled", dataType = "bool", paramNum = 2 },
		},
	},
	["EVENT_GLOBAL_MOUSE_DOWN"] = {
		CODE = EVENT_GLOBAL_MOUSE_DOWN,
		DESCR = "EVENT_GLOBAL_MOUSE_DOWN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			button = { name = "button", dataType = "integer", paramNum = 2 },
			ctrl = { name = "ctrl", dataType = "bool", paramNum = 3 },
			alt = { name = "alt", dataType = "bool", paramNum = 4 },
			shift = { name = "shift", dataType = "bool", paramNum = 5 },
			command = { name = "command", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_GLOBAL_MOUSE_UP"] = {
		CODE = EVENT_GLOBAL_MOUSE_UP,
		DESCR = "EVENT_GLOBAL_MOUSE_UP",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			button = { name = "button", dataType = "integer", paramNum = 2 },
			ctrl = { name = "ctrl", dataType = "bool", paramNum = 3 },
			alt = { name = "alt", dataType = "bool", paramNum = 4 },
			shift = { name = "shift", dataType = "bool", paramNum = 5 },
			command = { name = "command", dataType = "bool", paramNum = 6 },
		},
	},
	["EVENT_GUI_HIDDEN"] = {
		CODE = EVENT_GUI_HIDDEN,
		DESCR = "EVENT_GUI_HIDDEN",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			guiName = { name = "guiName", dataType = "string", paramNum = 2 },
			hidden = { name = "hidden", dataType = "bool", paramNum = 3 },
		},
	},
	["EVENT_KEYBINDINGS_LOADED"] = {
		CODE = EVENT_KEYBINDINGS_LOADED,
		DESCR = "EVENT_KEYBINDINGS_LOADED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
		},
	},
	["EVENT_KEYBINDING_CLEARED"] = {
		CODE = EVENT_KEYBINDING_CLEARED,
		DESCR = "EVENT_KEYBINDING_CLEARED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			layerIndex = { name = "layerIndex", dataType = "luaindex", paramNum = 2 },
			categoryIndex = { name = "categoryIndex", dataType = "luaindex", paramNum = 3 },
			actionIndex = { name = "actionIndex", dataType = "luaindex", paramNum = 4 },
			bindingIndex = { name = "bindingIndex", dataType = "luaindex", paramNum = 5 },
		},
	},
	["EVENT_KEYBINDING_SET"] = {
		CODE = EVENT_KEYBINDING_SET,
		DESCR = "EVENT_KEYBINDING_SET",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			layerIndex = { name = "layerIndex", dataType = "luaindex", paramNum = 2 },
			categoryIndex = { name = "categoryIndex", dataType = "luaindex", paramNum = 3 },
			actionIndex = { name = "actionIndex", dataType = "luaindex", paramNum = 4 },
			bindingIndex = { name = "bindingIndex", dataType = "luaindex", paramNum = 5 },
			keyCode = { name = "keyCode", dataType = "integer", paramNum = 6 },
			mod1 = { name = "mod1", dataType = "integer", paramNum = 7 },
			mod2 = { name = "mod2", dataType = "integer", paramNum = 8 },
			mod3 = { name = "mod3", dataType = "integer", paramNum = 9 },
			mod4 = { name = "mod4", dataType = "integer", paramNum = 10 },
		},
	},
	["EVENT_LUA_ERROR"] = {
		CODE = EVENT_LUA_ERROR,
		DESCR = "EVENT_LUA_ERROR",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			error = { name = "error", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_SCREEN_RESIZED"] = {
		CODE = EVENT_SCREEN_RESIZED,
		DESCR = "EVENT_SCREEN_RESIZED",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			x = { name = "x", dataType = "integer", paramNum = 2 },
			y = { name = "y", dataType = "integer", paramNum = 3 },
		},
	},
	["EVENT_SCRIPT_ACCESS_VIOLATION"] = {
		CODE = EVENT_SCRIPT_ACCESS_VIOLATION,
		DESCR = "EVENT_SCRIPT_ACCESS_VIOLATION",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			protectedFunctionName = { name = "protectedFunctionName", dataType = "string", paramNum = 2 },
		},
	},
	["EVENT_SHOW_GUI"] = {
		CODE = EVENT_SHOW_GUI,
		DESCR = "EVENT_SHOW_GUI",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			guiName = { name = "guiName", dataType = "string", paramNum = 2 },
			desiredStateName = { name = "desiredStateName", dataType = "string", paramNum = 3 },
		},
	},
	["EVENT_UPDATE_GUI_LOADING_PROGRESS"] = {
		CODE = EVENT_UPDATE_GUI_LOADING_PROGRESS,
		DESCR = "EVENT_UPDATE_GUI_LOADING_PROGRESS",
		PARAMS = {
			eventCode = { name = "eventCode", dataType = "integer", paramNum = 1 },
			guiName = { name = "guiName", dataType = "string", paramNum = 2 },
			assetsLoaded = { name = "assetsLoaded", dataType = "integer", paramNum = 3 },
			assetsTotal = { name = "assetsTotal", dataType = "integer", paramNum = 4 },
		},
	},
}
for e,t in pairs(_lwf.Events.GameEventTable) do
	if t.CODE ~= nil then _lwf.Events.GameEventsByCode[ t.CODE ] = t end
end

_lwf._global.Func.ColorScale_RedGreenPowerMeter = function(val, maxVal, reverseMe)
	if val == nil or maxVal == nil then return 1, 1, 1; end
	local pct = _lwf._global.Func.Round( val / maxVal, 2 )
	local ss, ee, bb = 255, 255, 0
	if pct == .50 then 
		return 1, 1, 1
	elseif pct >= .51 then 
		ee = 255
		ss = ss * (1 - ((pct - .50)*2))
		bb = ss
	elseif pct < .50 then 
		ss = 255 
		ee = ee * (pct*2)
		bb = ee
	end
	ss = ss / 255
	ee = ee / 255
	bb = bb / 255
	if reverseMe then return ss, ee, bb;
	else return ee, ss, bb; end
end

_lwf._global.Func.Print = function( Text ) d( Text ); end

_lwf._global.Func.CountOf = function(T) return _lwf._global.Func.table_count( T ); end
_lwf._global.Func.NextOf = function(T) return _lwf._global.Func.table_next( T ); end

_lwf._global.Func.GetDateTimeString = function()
	local ts = GetTimeStamp() 
	if not ts then return nil end
	local dt = GetDateStringFromTimestamp(ts) or ""
	local tm = GetTimeString() or ""
	return dt.." "..tm
end

_lwf._var.UniqueNamesUsed = {}
_lwf._global.Func.UniqueName = function( self, NAME )
	local addon
	if self then
		addon = self.ID
	else
		addon = _lwf.name.."_MC"
	end
	if not NAME then NAME = "lWAF_Ctrl" end
	if _lwf._var.UniqueNamesUsed[NAME] == nil and _G[NAME] == nil then
		_lwf._var.UniqueNamesUsed[NAME] = NAME
		return NAME
	end
	if _lwf._var.UniqueNamesUsed[NAME] == nil and _G[NAME] == nil then
		_lwf._var.UniqueNamesUsed[NAME] = NAME
		return NAME
	end
	for c = 1, 6000, 1 do
		if _lwf._var.UniqueNamesUsed[NAME.."_"..c] == nil and _G[NAME.."_"..c] == nil then
			_lwf._var.UniqueNamesUsed[NAME.."_"..c] = NAME.."_"..c
			return NAME.."_"..c
		end
	end
end
_lwf._global.Func.FindFrame = function(frameName) return _G[frameName] end

_lwf._global.Func.Indentation = function(num)
	local r = ""
	for xx = 0,num do
		r = r.."."
	end
	return r.." "
end
_lwf._global.Func.DumpWindowName = function(win,num)
	if win then d(_lwf._global.Func.Indentation(num)..win:GetName()); end
end
_lwf._global.Func.DumpWindowsToChat = function(win,num)
	if not win and not num then
		_lwf._global.Func.DumpWindowsToChat(GuiRoot)
		return
	end
	if not win then return end
	local nn = num or 0
	local xx = nn + 1
	_lwf._global.Func.DumpWindowName(win,nn)
	local x = win:GetNumChildren()
	if x > 0 then	
		for ii = 1, x do
			_lwf._global.Func.DumpWindowsToChat(win:GetChild(ii),xx)
		end
	end
end

_lwf._global.Func.DumpCommandsToChat = function() table.foreach(_G,d); end

_lwf._global.GuildName = function(n) return GetGuildName(GetGuildId(n)) or "<no guild "..n..">" end

_lwf._global.Func.GetOrDefault = function( self, defaultIfNil, value )
	if value == nil then return defaultIfNil else return value end
end

_lwf.Events.GlobalHandler = function( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11
	, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 )
	local e = _lwf.Events.GameEventsByCode[ arg1 ]
	if e == nil then return end
	if _lwf.Events.Registry[ e.DESCR ] == nil then return end
	if _lwf._global.Func.table_count(_lwf.Events.Registry[ e.DESCR ]) > 0 then
		local args = {
			[1] = arg1,   [2] = arg2,   [3] = arg3,   [4] = arg4,   [5] = arg5, 
			[6] = arg6,   [7] = arg7,   [8] = arg8,   [9] = arg9,   [10] = arg10, 
			[11] = arg11, [12] = arg12, [13] = arg13, [14] = arg14, [15] = arg15, 
			[16] = arg16, [17] = arg17, [18] = arg18, [19] = arg19, [20] = arg20,
		}
		for k,a in pairs(_lwf.Events.Registry[ e.DESCR ]) do
			if a ~= nil then
				if a.Handler ~= nil then
					if a.TableParms then
						local parms = {}
						if e.PARAMS ~= nil then
							for _,parm in pairs ( e.PARAMS ) do
								parms[ parm.name ] = args[ parm.paramNum ]
							end
							a.Handler( parms )
						end
					else
						a.Handler( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11
							, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 )
					end
				end
			end
		end
	end
end

_lwf.Events._RegisteredToGlobalHandler = {}
_lwf.Events._NumRegisteredToGlobalHandler = {}

_lwf.Events._hasUnregistered = {}

_lwf.Commands = {}
_lwf.Commands.Callbacks = {}

_lwf.Commands.Toggle = function( self, Command, Callback )
	if not Command then return end
	local COMMAND = Command
	if not string.find(COMMAND, "/") then COMMAND = "/"..COMMAND end
	local UCOMMAND, LCOMMAND = string.upper(COMMAND), string.lower(COMMAND)
	if Callback then 
		SLASH_COMMANDS[COMMAND]  = Callback
		SLASH_COMMANDS[UCOMMAND] = Callback
		SLASH_COMMANDS[LCOMMAND] = Callback
		_lwf.Commands.Callbacks[COMMAND] = {}
		_lwf.Commands.Callbacks[COMMAND].Command = COMMAND
		_lwf.Commands.Callbacks[COMMAND].Callback = Callback
		_lwf.Commands.Callbacks[UCOMMAND] = {}
		_lwf.Commands.Callbacks[UCOMMAND].Command = UCOMMAND
		_lwf.Commands.Callbacks[UCOMMAND].Callback = Callback
		_lwf.Commands.Callbacks[LCOMMAND] = {}
		_lwf.Commands.Callbacks[LCOMMAND].Command = LCOMMAND
		_lwf.Commands.Callbacks[LCOMMAND].Callback = Callback
	else 
		SLASH_COMMANDS[COMMAND]  = nil
		SLASH_COMMANDS[UCOMMAND] = nil
		SLASH_COMMANDS[LCOMMAND] = nil
		_lwf.Commands.Callbacks[COMMAND] = nil
		_lwf.Commands.Callbacks[UCOMMAND] = nil
		_lwf.Commands.Callbacks[LCOMMAND] = nil
	end
end

_lwf.Commands.Add = function( self, COMMAND, HANDLER ) _lwf.Commands.Toggle( COMMAND, HANDLER ) end
_lwf.Commands.Remove = function( self, COMMAND ) _lwf.Commands.Toggle( COMMAND ) end

_lwf._func.trim = function(s) return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'; end
_lwf._func.split = function( str, delim, max )
    if max == nil then max = -1 end
    if delim == nil then delim = " " end
    local last, start, stop = 1
    local result = {}
    while max ~= 0 do
        start, stop = str:find(delim, last )
        if start == nil then break; end
        table.insert( result, str:sub( last, start-1 ) )
        last = stop+2
        max = max - 1
    end
    table.insert( result, str:sub( last ) )
    return result
end

_lwf.SlashCommand = function( Command, Callback ) _lwf.Commands.Toggle( Command, Callback ) end

_lwf.Tic = function( self, TicName, Callback, ThrottleInSeconds )
	if TicName == nil then return end
	if Callback == nil then
		_lwf.Events.Registered_onupdatecallback[TicName] = nil
		if ThrottleInSeconds ~= nil then
		   d("DEBUG Tic: ThrottleInSeconds="..ThrottleInSeconds.." but Callback is nil for TicName="..TicName)
		   end
	else
		_lwf.Events.Registered_onupdatecallback[TicName] = {}
		_lwf.Events.Registered_onupdatecallback[TicName].Buffer = ThrottleInSeconds
		_lwf.Events.Registered_onupdatecallback[TicName].Callback = Callback
	end
end

_lwf._func.EventName = function( EventToWatch )
	for e,t in pairs(_lwf.Events.GameEventTable) do
		if t.DESCR == EventToWatch or t.CODE == EventToWatch
		then return t.DESCR end
	end
	return nil
end

_lwf.Event = function( self, EventToWatch, Callback, ParamsAsTable )
	if EventToWatch == nil then return end
	local event = _lwf._func.EventName( EventToWatch )
	if event == nil then return end
	local AddonID = self.ID
	if _lwf.Events.Registry[event] == nil then _lwf.Events.Registry[event] = {} end
	if Callback == nil then
		if _lwf.Events.Registry[event][AddonID] ~= nil then
			_lwf.Events.Registry[event][AddonID].Unregister = true
		end
	else
		_lwf.Events.Registry[event][AddonID] = {}
		_lwf.Events.Registry[event][AddonID].Code = _lwf.Events.GameEventTable[event].CODE
		_lwf.Events.Registry[event][AddonID].Handler = Callback
		_lwf.Events.Registry[event][AddonID].Addon = AddonID
		_lwf.Events.Registry[event][AddonID].TableParms = ParamsAsTable
	end
end
_lwf.Events.Register = function( self, EVENT, HANDLER, ParamsAsTable )
	_lwf.Event( self, EVENT, HANDLER, ParamsAsTable )
end
_lwf.Events.Unregister = function( self, EVENT )
	_lwf.Event( self, EVENT, nil, nil )
end

if not _lwf.Addons then _lwf.Addons = {} end

_lwf._var.AddonState = {}
_lwf._var.Descr = function( addOn ) return addOn.DisplayName.." v"..addOn.Version end
_lwf._var.LoadAlert = function( addOn ) return d( "|cffffff[Addon Loaded]|r ".._lwf._var.Descr( addOn ) ) end

_lwf.AddonPrep = function( eventCode, addOnName )
	if _lwf.Addons[addOnName] then
		local base = _lwf.Addons[addOnName].__base
		if base then
			if not _lwf._var.AddonState[addOnName] then _lwf._var.AddonState[addOnName] = {} end
			base.Ready = true
			if not _lwf._var.AddonState[addOnName].Started then
				_lwf._var.AddonState[addOnName].Loaded = true
				_lwf._var.AddonState[addOnName].Started = true
				if base.onBeforeStartupCallback then base:onBeforeStartupCallback() end
				if base.onStartupCallback then base:onStartupCallback() end
				if base.onAfterStartupCallback then base:onAfterStartupCallback() end
				_lwf._var.LoadAlert( base )
			end
		end
	end
end

_lwf._global.Frames.Chain = function( object )
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end

_lwf._global.Frames.__NewTopLevel = function(str) 
	local object = _lwf._global.Frames.NewTopLevel(str)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end 
	end })
	return T
end
_lwf._global.Frames.NewTopLevel = function(str)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateTopLevelWindow(nm))
	.__END
	return obj
end

_lwf._global.Frames.__NewBackdrop = function(str, pappy) 
	local object = _lwf._global.Frames.NewBackdrop(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewBackdrop = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_BACKDROP))
	.__END
	return obj
end

_lwf._global.Frames.__NewImage = function(str, pappy) 
	local object = _lwf._global.Frames.NewImage(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewImage = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_TEXTURE))
	.__END
	return obj
end

_lwf._global.Frames.__NewLabel = function(str, pappy) 
	local object = _lwf._global.Frames.NewLabel(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewLabel = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_LABEL))
	.__END
	return obj
end

_lwf._global.Frames.__NewButton = function(str, pappy) 
	local object = _lwf._global.Frames.NewButton(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewButton = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_BUTTON))
	.__END
	return obj
end

_lwf._global.Frames.__NewSlider = function(str, pappy) 
	local object = _lwf._global.Frames.NewSlider(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewSlider = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_SLIDER))
	.__END
	return obj
end

_lwf._global.Frames.__NewEditBox = function(str, pappy) 
	local object = _lwf._global.Frames.NewEditBox(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewEditBox = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_EDITBOX))
	.__END
	return obj
end

_lwf._global.Frames.__NewLine = function(str, pappy) 
	local object = _lwf._global.Frames.NewLine(str, pappy)
	local T = {}
	setmetatable( T , { __index = function( self , func )
		if func == "__END" then	return object end
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	return T
end
_lwf._global.Frames.NewLine = function(str, pappy)
	local nm = _lwf._global.Func.UniqueName( nil, str)
	local obj = _lwf._global.Frames.Chain(wm:CreateControl(nm, pappy or GuiRoot, CT_LINE))
	.__END
	return obj
end

_lwf._global.Frames.Events = {}
_lwf._global.Frames.Events.UIModeRegisteredWindows = {}

_lwf._global.Frames.Events.ToggleUIFrames = function(eventCode)
	if _lwf._global.Func.table_count(_lwf._global.Frames.Events.UIModeRegisteredWindows) == 0 then return end
	local shouldBeOff = _lwf._global.Frames.UIShouldBeHidden()
	
	for nm,st in pairs(_lwf._global.Frames.Events.UIModeRegisteredWindows) do
		local obj = _G[nm]
		if obj and st ~= nil then 
			if shouldBeOff then obj:Hide(true) end
			if not shouldBeOff then obj:Show() end
		end
	end
end

_lwf._global.Frames.UIShouldBeHidden = function()
	if not ZO_MainMenuCategoryBar:IsHidden() then return true end
	if not ZO_OptionsWindow:IsHidden() then return true end
	if not ZO_SharedTreeUnderlay:IsHidden() then return true end
	if not ZO_ChatterOption1:IsHidden() then return true end
	if not STORE_WINDOW["container"]:IsHidden() then return true end
	if not STABLE["control"]:IsHidden() then return true end
	if not SMITHING["control"]:IsHidden() then return true end
	if not LOCK_PICK["control"]:IsHidden() then return true end
	if not KEYBIND_STRIP["control"]:IsHidden() then return true end
	return false
end

_lwf._global.Frames.CalculateRelativeAnchor = function()
	local left, top		= frame:GetLeft(), frame:GetTop()
	local right, bottom	= frame:GetRight(), frame:GetBottom()
	local rootW, rootH	= GuiRoot:GetWidth(), GuiRoot:GetHeight()
	local point			= 0
	local x, y

	if (left < (rootW - right) and left < math.abs((left + right) / 2 - rootW / 2)) then
		x, point = left, 2 -- 'LEFT'
	elseif ((rootW - right) < math.abs((left + right) / 2 - rootW / 2)) then
		x, point = right - rootW, 8 -- 'RIGHT'
	else
		x, point = (left + right) / 2 - rootW / 2, 0
	end

	if (bottom < (rootH - top) and bottom < math.abs((bottom + top) / 2 - rootH / 2)) then
		y, point = top, point + 1 -- 'TOP|TOPLEFT|TOPRIGHT'
	elseif ((rootH - top) < math.abs((bottom + top) / 2 - rootH / 2)) then
		y, point = bottom - rootH, point + 4 -- 'BOTTOM|BOTTOMLEFT|BOTTOMRIGHT'
	else
		y = (bottom + top) / 2 - rootH / 2
	end

	point = (point == 0) and 128 or point -- 'CENTER'

	return point, x, y
end

_lwf._global.Frames.UIBackdrop = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
	if parent == nil then return end
	local obj = cascade or {}
	obj.Backdrop = _lwf._global.Frames.__NewBackdrop(uniqueName.."_Backdrop", parent)
		:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
		:SetDimensions( w , h )
		:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
		:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
		:SetEdgeTexture(edgeTexture[1], edgeTexture[2], edgeTexture[3], edgeTexture[4])
		:SetAlpha(alpha)
		:SetHidden(false)
	.__END
	return obj
end

_lwf._global.Frames.UIButton = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, fontColor, cascade, textX, textY)
	if parent == nil then return end
	local obj = cascade or {}
	local tX = textX or 0
	local tY = textY or ((h-6)*-1)
	obj = _lwf._global.Frames.UIBackdrop(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, obj)
	obj.Button = _lwf._global.Frames.__NewButton(uniqueName, obj.Backdrop)
		:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
		:SetDimensions( w-2 , h-2 )
		:EnableMouseButton(1,true)
		:SetEnabled(true)
		:SetHidden(false)
	.__END
	obj = _lwf._global.Frames.UILabel(obj.Button, uniqueName.."_Label", {CENTER, obj.Button, CENTER, tX, tY}, w-4, h-4, alpha, text, fontColor, obj)
	return obj
end

_lwf._global.Frames.UIButton2 = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, cascade)
	if parent == nil then return end
	local obj = cascade or {}
	local tX = textX or 0
	local tY = textY or ((h-6)*-1)
	obj = _lwf._global.Frames.UIBackdrop(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
	obj.Button = _lwf._global.Frames.__NewButton(uniqueName, obj.Backdrop)
		:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
		:SetDimensions( w-2 , h-2 )
		:EnableMouseButton(1,true)
		:SetEnabled(true)
		:SetHidden(false)
		:SetText(text)
	.__END
	return obj
end

_lwf._global.Frames.UIImageButton = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, imagePath, cascade)
	if parent == nil then return end
	local obj = cascade or {}
	local tX = textX or 0
	local tY = textY or ((h-6)*-1)
	obj = _lwf._global.Frames.UIBackdrop(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
	obj.Button = _lwf._global.Frames.__NewButton(uniqueName, obj.Backdrop)
		:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
		:SetDimensions( w-2 , h-2 )
		:EnableMouseButton(1,true)
		:SetEnabled(true)
		:SetHidden(false)
	.__END
	obj.Image = _lwf._global.Frames.__NewImage(uniqueName.."_image", obj.Button)
		:SetAnchor(CENTER, obj.Button, CENTER, 0, 0)
		:SetDimensions(w-4, h-4)
		:SetAlpha(alpha)
		:SetTexture(imagePath)
	.__END
	return obj
end

_lwf._global.Frames.UIFrame = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
	if parent == nil then return end
	local obj = cascade or {}
	obj.Frame = _lwf._global.Frames.__NewTopLevel( uniqueName )
		:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		:SetDimensions( w, h )
		:SetHidden( false )
	.__END
	obj.Backdrop = _lwf._global.Frames.__NewBackdrop( uniqueName.."_Backdrop", obj.Frame )
		:SetAnchor(CENTER, obj.Frame, CENTER, 0, 0)
		:SetDimensions( w , h )
		:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
		:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
		:SetEdgeTexture(edgeTexture[1], edgeTexture[2], edgeTexture[3], edgeTexture[4])
		:SetAlpha(alpha)
		:SetHidden(false)
	.__END
	return obj
end

_lwf._global.Frames.UILabel = function(parent, uniqueName, anchor, w, h, alpha, text, fontColor, cascade)
	if parent == nil then return end
	local obj = cascade or {}
	obj.Label = _lwf._global.Frames.__NewLabel(uniqueName.."_Label", parent)
		:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
		:SetDimensions( w , h )
		:SetFont("ZoFontGame")
		:SetColor(fontColor[1], fontColor[2], fontColor[3], fontColor[4])
		:SetAlpha(alpha)
		:SetHidden(false)
		:SetText(text)
	.__END
	return obj
end

local verticalScrollTexture = "/esoui/art/miscellaneous/scrollbox_elevator.dds"

_lwf._global.Frames.UIPopup = function( name, title, anchor, width, textLinks, closeCallback, ignoreMouseOut )
	local obj = _G[name]
	if obj == nil then 
		obj = _lwf._global.Frames.__NewTopLevel(name)
			:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
			:SetHidden(false)
			:SetMovable(false)
			:SetMouseEnabled(true)
			:SetDimensions( width, 40 )
		.__END
		obj = _lwf._global.Frames.UIBackdrop(
			obj, 
			name, 
			{CENTER,obj,CENTER,0,0}, 
			obj:GetWidth(), 
			obj:GetHeight(), 
			{0.1,0.1,0.1,1}, 
			{0,0,0,1}, 
			{"", 8, 1, 1}, 
			1, 
			obj
		)
		if title then
			obj.Title = _lwf._global.Frames.UITextBlock(
				obj.Backdrop, 
				name.."_Title", 
				{ TOPLEFT, obj.Backdrop, TOPLEFT, 1, 1 }, 
				width, 
				16, 
				{0,0,0,1}, 
				{0.2,0.2,0.7,1}, 
				{"", 8, 1, 1}, 
				1, 
				title, 
				{1,1,1,1}, 
				nil, 
				0, 
				-4
			)
			obj.Title.Backdrop:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, -1, 1 )
			obj.Title.Label:SetWidth(obj.Title.Backdrop:GetWidth()*1.7)
			obj.Title.Label:SetHorizontalAlignment(WF_UTIL.TextAlign["h"]["center"])
			obj.Title.Label:SetVerticalAlignment(WF_UTIL.TextAlign["v"]["center"])
			--obj.Title.Label:SetAnchor(LEFT, obj.Title.Backdrop, LEFT, 3, 0)
			obj.Title.Label:SetScale(.85)
		end
		obj.MousedOver = false
		obj.ignoreMouseOut = ignoreMouseOut
		function obj:IsMousedOver() if obj.ignoreMouseOut then return false else return self.MousedOver end end
		function obj:MouseIn() 
			obj.MousedOver = true
		end
		function obj:MouseOut() 
			obj.MousedOver = false
			obj:SetHidden( true )
			_lwf.Tic( nil, name.."_hoverWatch" )
			if closeCallback ~= nil then closeCallback() end
		end
		function obj:CloseMe() 
			obj:SetHidden( true )
			_lwf.Tic( nil, name.."_hoverWatch" )
		end
		function obj:ShowMe() 
			obj:SetHidden( false )
			obj.MousedOver = false
			_lwf.Tic( nil, name.."_hoverWatch", function()
				if ( obj:IsMousedOver() and wm:IsMouseOverWorld() )
				or IsUnitInCombat("player") 
				or IsPlayerMoving() then
					obj:MouseOut()
				end
			end )
		end
		obj:ShowMe()
		obj:SetHandler( "OnMouseEnter", function(self) obj:MouseIn() end )
		local startY, modY = 0, 0
		local widest, count = 0, 0
		if title == nil then modY = 6 end
		obj.Clickies = {}
		if textLinks ~= nil then
			if table_count(textLinks) > 0 then
				for i,tbl in WF_PairsByKeys(textLinks) do
					startY = 2 + modY + (count * 20)
					count = count + 1
					local btn = _lwf._global.Frames.UIButton(
						obj, name.."_link", 
						{TOPLEFT, obj.Backdrop, TOPLEFT, 4, startY }, 
						width or 72, 18, 
						{0,0,0,0}, 
						{0.2,0.2,0.7,0}, 
						{"", 8, 1, 0}, 
						1, tbl.name, 
						{1,1,1,1}, 
						nil, nil, -4
					)
					local ww = btn.Label:GetWidth() + 2
					if ww > widest then widest = ww end
					btn.Button:SetWidth( ww )
					btn.Button:EnableMouseButton(2,true)
					btn.Button:SetHandler("OnClicked", function(self,button) tbl.onClick(self,button,tbl.params); obj:MouseOut(); end )
					btn.Button:SetHandler("OnMouseEnter", function() btn.Label:SetColor(.5,.6,1,1) end)
					btn.Button:SetHandler("OnMouseExit", function() btn.Label:SetColor(1,1,1,1) end)
					obj.Clickies[i] = btn
				end
			end
		end
		if title then count = count + 1 end
		local offset = 6
		if title then offset = 20 end
		if widest == 0 then widest = nil end
		obj.Backdrop:ClearAnchors()
		obj:SetDimensions( widest or width, (count*22)+offset )
		obj.Backdrop:SetAnchor(TOPLEFT, obj, TOPLEFT, 0, 0)
		obj.Backdrop:SetAnchor(BOTTOMRIGHT, obj, BOTTOMRIGHT, 0, 0)
		obj:SetHidden( false )
		return obj
	end
	obj.MousedOver = false
	obj:SetHidden( false )
	obj:ClearAnchors()
	obj:SetDrawLayer(2)
	obj:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
	obj.Backdrop:ClearAnchors()
	obj.Backdrop:SetAnchor(TOPLEFT, obj, TOPLEFT, 0, 0)
	obj.Backdrop:SetAnchor(BOTTOMRIGHT, obj, BOTTOMRIGHT, 0, 0)
	if textLinks ~= nil then
		if table_count(textLinks) > 0 then
			for i = 1, table_count(textLinks), 1 do
				obj.Clickies[i].Button:SetHandler("OnClicked", function(self,button) 
					textLinks[i].onClick(self,button,textLinks[i].params); 
					obj:MouseOut(); 
				end )
			end
		end
	end
	obj:ShowMe()
	return obj
end

_lwf._global.Frames.UITextBlock = function(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, fontColor, cascade, textX, textY)
	if parent == nil then return end
	local obj = cascade or {}
	local tX = textX or 0
	local tY = textY or ((h-6)*-1)
	obj = _lwf._global.Frames.UIBackdrop(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, obj)
	obj = _lwf._global.Frames.UILabel(obj.Backdrop, uniqueName.."_Label", {CENTER, obj.Backdrop, CENTER, tX, tY}, w-2, h-2, alpha, text, fontColor, obj)
	return obj
end

_lwf._global.Frames.UIWindow = {}

local closeButtonUp = "/esoui/art/buttons/clearslot_up.dds"
local closeButtonDown = "/esoui/art/buttons/clearslot_down.dds"
local unlockedButtonUp = "/esoui/art/quest/quest_untrack_up.dds"
local unlockedButtonDown = "/esoui/art/quest/quest_untrack_down.dds"
local lockedButtonUp = "/esoui/art/quest/quest_track_up.dds"
local lockedButtonDown = "/esoui/art/quest/quest_track_down.dds"

function _lwf._global.Frames.UIWindow:Create(baseName, title, useMover, useCloser, Settings, width, height, overAlpha)
	local obj = _lwf._global.Func.FindFrame(baseName)
	if obj ~= nil then return end
	
	local moverText = lockedButtonUp
	if Settings.Moveable then moverText = unlockedButtonUp end
	
	local minW = 40 + 2
	local minH = 50
	
	if useMover then minW = minW + 15 end
	if useCloser then minW = minW + 15 end
	
	local w = width or minW
	local h = height or minH
	
	if w < minW then w = minW end
	if h < minH then h = minH end
	
	local titleWminus = 2
	if useMover then titleWminus = titleWminus + 15 end
	if useCloser then titleWminus = titleWminus + 15 end
	
	local a = overAlpha or .85
		
	obj = _lwf._global.Frames.__NewTopLevel(baseName)
		:SetAnchor(CENTER, GuiRoot, CENTER, Settings.ShiftX, Settings.ShiftY)
		:SetDimensions(w,h)
		:SetHidden(Settings.Hidden)
		:SetMovable(Settings.Moveable)
		:SetMouseEnabled(true)
	.__END
	
	obj.OutAlpha = .5
	obj.InAlpha = overAlpha or .85
	
	obj = _lwf._global.Frames.UIBackdrop(
		obj, 
		baseName, 
		{CENTER,obj,CENTER,0,0}, 
		obj:GetWidth(), 
		obj:GetHeight(), 
		{0.1,0.1,0.1,1}, 
		{0,0,0,1}, 
		{"", 8, 1, 1}, 
		obj.OutAlpha, 
		obj
	)
	
	obj.Title = _lwf._global.Frames.UITextBlock(
		obj.Backdrop, 
		baseName.."_Title", 
		{TOPLEFT,obj.Backdrop,TOPLEFT,1,1}, 
		(obj:GetWidth()-titleWminus), 
		16, 
		{0,0,0,1}, 
		{0.2,0.2,0.7,1}, 
		{"", 8, 1, 1}, 
		1, 
		title, 
		{1,1,1,1}, 
		nil, 
		0, 
		0
	)
	obj.Title.Label:SetWidth(obj.Title.Backdrop:GetWidth()*1.7)
	obj.Title.Label:SetAnchor(LEFT, obj.Title.Backdrop, LEFT, 3, -2)
	obj.Title.Label:SetScale(.65)
	
	obj.MousedOver = false
	function obj.IsMousedOver(self) return self.MousedOver end
	
	function obj.MouseIn() 
		obj.MousedOver = true
		obj.Backdrop:SetAlpha(obj.InAlpha)
	end
	function obj.MouseOut() 
		obj.MousedOver = false
		obj.Backdrop:SetAlpha(obj.OutAlpha)
	end
	
	if useCloser then
		obj.CloseButton = _lwf._global.Frames.__NewImage(baseName.."_CloseButton", obj.Backdrop)
			:SetDimensions(16, 16)
			:SetTexture( closeButtonUp )
			:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, -1, 1 )
			:SetMouseEnabled( true )
			:SetHandler( "OnMouseDown", function(self) self:SetTexture( closeButtonDown ) end )
			:SetHandler( "OnMouseUp", function(self) obj:Hide(); self:SetTexture( closeButtonUp ) end )
		.__END
	end
	
	if useMover then
		local moveShiftX = -1
		if useCloser then moveShiftX = -18 end
		
		function obj.ClickMove(self, forceMoveable)
			if Settings.Moveable and not forceMoveable then self:Lock()
			else self:Move() end
		end
		function obj.Move(self)
			Settings.Moveable = true
			self.MoveButton:SetTexture( unlockedButtonUp )
			self:SetMovable(Settings.Moveable)
		end
		function obj.Lock(self)
			Settings.Moveable = false
			self.MoveButton:SetTexture( lockedButtonUp )
			self:SetMovable(Settings.Moveable)
		end
		
		obj.MoveButton = _lwf._global.Frames.__NewImage(baseName.."_MoveButton", obj.Backdrop)
			:SetDimensions(16, 16)
			:SetTexture( moverText )
			:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, moveShiftX, 1 )
			:SetMouseEnabled( true )
			:SetHandler( "OnMouseDown", function(self) 
				if Settings.Moveable then self:SetTexture( unlockedButtonDown )
				else self:SetTexture( lockedButtonDown ) end
			end )
			:SetHandler( "OnMouseUp", function(self) obj:ClickMove() end )
		.__END
	else
		function obj.Move(self)
			Settings.Moveable = true
			self:SetMovable(Settings.Moveable)
		end
		function obj.Lock(self)
			Settings.Moveable = false
			self:SetMovable(Settings.Moveable)
		end
	end
	
	if not Settings.Hidden then _lwf._global.Frames.Events.UIModeRegisteredWindows[obj:GetName()] = obj:GetName() end
	
	function obj.SetOutAlpha(self, a) self.OutAlpha = a end
	function obj.SetInAlpha(self, a) self.InAlpha = a end
	
	function obj.Show(self)
		if _lwf._global.Frames.UIShouldBeHidden() then return end
		_lwf._global.Frames.Events.UIModeRegisteredWindows[self:GetName()] = self:GetName()
		Settings.Hidden = false
		self:SetHidden(Settings.Hidden)
	end
	function obj.Hide(self, temporary)
		if temporary == nil then temporary = false end
		if temporary then
			_lwf._global.Frames.Events.UIModeRegisteredWindows[self:GetName()] = self:GetName()
		else
			_lwf._global.Frames.Events.UIModeRegisteredWindows[self:GetName()] = nil
		end
		Settings.Hidden = true
		self:SetHidden(Settings.Hidden)
	end
	function obj.Toggle(self)
		if self:IsHidden() 
		then self:Show()
		else self:Hide(false) end
	end
	function obj.SetFrameCoords(self)
		local addOnX, addOnY = self:GetCenter()
		local guiRootX, guiRootY = GuiRoot:GetCenter()
		local x = addOnX - guiRootX
		local y = addOnY - guiRootY
		Settings.ShiftX = x
		Settings.ShiftY = y
	end
	obj.CanMove = Settings.Moveable
	if useMover then
		function obj.SetMoveState(self, bool)
			self.CanMove = bool
			Settings.Moveable = bool
			self:SetMovable(bool)
			self:ClickMove(bool)
		end
	else
		function obj.SetMoveState(self, bool)
			self.CanMove = bool
			Settings.Moveable = bool
			self:SetMovable(bool)
		end
	end
	
	obj:SetHandler("OnMoveStop", function(self) obj:SetFrameCoords() end)
	obj:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
	obj:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
	if useMover then
		obj.MoveButton:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
		obj.MoveButton:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
	end
	if useCloser then
		obj.CloseButton:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
		obj.CloseButton:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
	end
	
	return obj
end

_lwf._func.SelectableItem = function( itm )
	local key = "LWF_ScrollingDDL_PopUp_Item"..itm
	if _G[key] then return _G[key] end
	local o = _lwf._global.Frames.__NewBackdrop( key, LWF_ScrollingDDL_PopUp )
		:SetDimensions( 111, 26 )
		:SetCenterColor( .15, .15, .15, 1 )
		:SetEdgeColor( 0, 0, 0, 0 )
	.__END
	o.Label = _lwf._global.Frames.__NewLabel( key.."Label", LWF_ScrollingDDL_PopUp )
		:SetDimensions( 100, 22 )
		:SetAnchor( LEFT, o, LEFT, 3, 0 )
		:SetFont( string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 18, "soft-shadow-thick") )
		:SetHorizontalAlignment( _lwf._global.Var.TextAlign["h"]["left"] )
		:SetVerticalAlignment( _lwf._global.Var.TextAlign["v"]["center"] )
		:SetMouseEnabled( true )
		:SetHandler( "OnMouseEnter", function( self, button )
			_G[key]:SetCenterColor( .15, .35, .65, 1 )
		end )
		:SetHandler( "OnMouseExit", function( self, button )
			_G[key]:SetCenterColor( .15, .15, .15, 1 )
		end )
		:SetHandler( "OnMouseWheel", function( self, button )
			if button > 0 then LWF_ScrollingDDL_PopUp.ScrollUp()
			else LWF_ScrollingDDL_PopUp.ScrollDown() end
		end )
		:SetHandler( "OnMouseDown", function( self )
			_G[key]:SetCenterColor( 0, 0, 0, .85 )
			LWF_ScrollingDDL_PopUp.ClickItem( self )
		end )
	.__END
	return o
end

_lwf._func.ScrollingDDL = function()
	if LWF_ScrollingDDL_PopUp then return LWF_ScrollingDDL_PopUp end
	local imgPath = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	local o1 = _lwf._global.Frames.__NewTopLevel( "LWF_ScrollingDDL_PopUp_HideAway" )
		:SetHidden( true )
	.__END
	local o = _lwf._global.Frames.__NewTopLevel( "LWF_ScrollingDDL_PopUp" )
		:SetDimensions( 111, 110 )
		:SetHidden( true )
	.__END
	LWF_ScrollingDDL_PopUp.data = {}
	LWF_ScrollingDDL_PopUp.callBackFunc = function() return end
	LWF_ScrollingDDL_PopUp.Item1 = _lwf._func.SelectableItem( 1 )
	LWF_ScrollingDDL_PopUp.Item2 = _lwf._func.SelectableItem( 2 )
	LWF_ScrollingDDL_PopUp.Item3 = _lwf._func.SelectableItem( 3 )
	LWF_ScrollingDDL_PopUp.Item4 = _lwf._func.SelectableItem( 4 )
	LWF_ScrollingDDL_PopUp.Item5 = _lwf._func.SelectableItem( 5 )
	LWF_ScrollingDDL_PopUp.Item1:SetAnchor( TOPLEFT )
	LWF_ScrollingDDL_PopUp.Item2:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item1, BOTTOMLEFT, 0, 0 )
	LWF_ScrollingDDL_PopUp.Item3:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item2, BOTTOMLEFT, 0, 0 )
	LWF_ScrollingDDL_PopUp.Item4:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item3, BOTTOMLEFT, 0, 0 )
	LWF_ScrollingDDL_PopUp.Item5:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item4, BOTTOMLEFT, 0, 0 )
	LWF_ScrollingDDL_PopUp.SetWidthAll = function( width )
		LWF_ScrollingDDL_PopUp:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item1:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item1.Label:SetWidth( width-11 )
		LWF_ScrollingDDL_PopUp.Item2:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item2.Label:SetWidth( width-11 )
		LWF_ScrollingDDL_PopUp.Item3:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item3.Label:SetWidth( width-11 )
		LWF_ScrollingDDL_PopUp.Item4:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item4.Label:SetWidth( width-11 )
		LWF_ScrollingDDL_PopUp.Item5:SetWidth( width )
		LWF_ScrollingDDL_PopUp.Item5.Label:SetWidth( width-11 )
	end
	LWF_ScrollingDDL_PopUp.SetCallBack = function( func )
		LWF_ScrollingDDL_PopUp.callBackFunc = func
	end
	LWF_ScrollingDDL_PopUp.slider = _lwf._global.Frames.__NewSlider( "LWF_ScrollingDDL_PopUp_Slider", LWF_ScrollingDDL_PopUp )
		:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item1, TOPRIGHT, -9, 6 )
		:SetThumbTexture( imgPath, imgPath, imgPath, 8, 22, 0, 0, 1, 1 )
		:SetValueStep( 1 )
		:SetDimensions( 8, 110 )
		:SetMouseEnabled( true )
		:SetHandler( "OnMouseWheel", function( self, button )
			if button > 0 then LWF_ScrollingDDL_PopUp.ScrollUp()
			else LWF_ScrollingDDL_PopUp.ScrollDown() end
		end )
		:SetHandler("OnValueChanged", function( self, value, eventReason ) 
			LWF_ScrollingDDL_PopUp.SetScroll( value )
		end )
	.__END
	LWF_ScrollingDDL_PopUp.ClickItem = function( itm )
		if itm then
			LWF_ScrollingDDL_PopUp:SetParent( LWF_ScrollingDDL_PopUp_HideAway )
			LWF_ScrollingDDL_PopUp:SetHidden( true ) 
			if itm:GetText() ~= nil and itm:GetText() ~= "" then
				LWF_ScrollingDDL_PopUp.callBackFunc( itm:GetText() )
			end
		end
	end
	LWF_ScrollingDDL_PopUp.SetListData = function( data )
		LWF_ScrollingDDL_PopUp.data = data
		LWF_ScrollingDDL_PopUp.slider:SetMinMax( 1, _lwf._global.Func.CountOf(data)-4 )
	end
	LWF_ScrollingDDL_PopUp.scrollPosition = 1
	LWF_ScrollingDDL_PopUp.SetScroll = function( pos )
		local maxScroll = (_lwf._global.Func.CountOf(LWF_ScrollingDDL_PopUp.data) - 4)
		LWF_ScrollingDDL_PopUp.scrollPosition = pos
		if LWF_ScrollingDDL_PopUp.scrollPosition <= 1 then LWF_ScrollingDDL_PopUp.scrollPosition = 1 end
		if LWF_ScrollingDDL_PopUp.scrollPosition > maxScroll then LWF_ScrollingDDL_PopUp.scrollPosition = maxScroll end
		LWF_ScrollingDDL_PopUp.slider:SetValue( LWF_ScrollingDDL_PopUp.scrollPosition )
		LWF_ScrollingDDL_PopUp.Item1.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition] ) )
		LWF_ScrollingDDL_PopUp.Item2.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+1] ) )
		LWF_ScrollingDDL_PopUp.Item3.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+2] ) )
		LWF_ScrollingDDL_PopUp.Item4.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+3] ) )
		LWF_ScrollingDDL_PopUp.Item5.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+4] ) )
	end
	LWF_ScrollingDDL_PopUp.ShowList = function()
		LWF_ScrollingDDL_PopUp.SetScroll( 1 )
		LWF_ScrollingDDL_PopUp:SetHidden( false )
	end
	LWF_ScrollingDDL_PopUp.ScrollUp = function()
		LWF_ScrollingDDL_PopUp.scrollPosition = LWF_ScrollingDDL_PopUp.scrollPosition - 1
		LWF_ScrollingDDL_PopUp.SetScroll( LWF_ScrollingDDL_PopUp.scrollPosition )
	end
	LWF_ScrollingDDL_PopUp.ScrollDown = function()
		LWF_ScrollingDDL_PopUp.scrollPosition = LWF_ScrollingDDL_PopUp.scrollPosition + 1
		LWF_ScrollingDDL_PopUp.SetScroll( LWF_ScrollingDDL_PopUp.scrollPosition )
	end
	return LWF_ScrollingDDL_PopUp
end

_lwf._global.Frames.UIDDL = function( name, parent, data, selected, dontChangeBase, callBack, scrollSupport )
    local combo = WINDOW_MANAGER:CreateControlFromVirtual( parent:GetName()..name, parent , "ZO_StatsDropdownRow" )
    combo:SetAnchor(CENTER)
	combo:GetNamedChild("Dropdown"):SetWidth(100)
	
 	combo.data = data
    combo.selected = combo.name
    combo.selected:SetFont("ZoFontGame")
    combo.dropdown = combo.dropdown
    combo.dropdown:SetFont("ZoFontGame")
    if selected then combo.dropdown:SetSelectedItem(selected) end
 
    combo.dropdown.OnSelect = function(self,value)
		if dontChangeBase and selected then combo.dropdown:SetSelectedItem(selected) end
		callBack( value )
    end
 
	if scrollSupport then
		local clickBait = combo:GetNamedChild("DropdownOpenDropdown")
		clickBait:SetHandler( "OnClicked", function()
			if LWF_ScrollingDDL_PopUp then
				if not LWF_ScrollingDDL_PopUp:IsHidden() then 
					LWF_ScrollingDDL_PopUp:SetParent( LWF_ScrollingDDL_PopUp_HideAway )
					LWF_ScrollingDDL_PopUp:SetHidden( true ) 
					return
				end
			end
			local dd = combo:GetNamedChild("Dropdown")
			_lwf._func.ScrollingDDL()
			LWF_ScrollingDDL_PopUp:SetParent( dd )
			LWF_ScrollingDDL_PopUp:ClearAnchors()
			LWF_ScrollingDDL_PopUp:SetAnchor( TOP, dd, BOTTOM, 0, -5 )
			LWF_ScrollingDDL_PopUp.SetCallBack( callBack )
			LWF_ScrollingDDL_PopUp.SetListData( data )
			LWF_ScrollingDDL_PopUp.ShowList()
		end )
	else
		for i = 1,#data do
			local entry = combo.dropdown:CreateItemEntry(data[i],combo.dropdown.OnSelect)
			combo.dropdown:AddItem(entry)
		end
	end
    return combo
end

_lwf.SettingsMenu = {}
_lwf.SettingsMenu.defaultMenu = "|cFF2222Wykkyd|r Config"
_lwf.SettingsMenu.lastHeaderAdded = nil

if not _lwf.SettingsMenu.LAM then _lwf.SettingsMenu.LAM = LibStub("LibAddonMenu-1.0") end
if not LWF_SETTINGSMENUS then LWF_SETTINGSMENUS = {} end

local idAndBaseName = function( self, parentKey )
	local key = parentKey or _lwf.SettingsMenu.defaultMenu
	if LWF_SETTINGSMENUS[key] ~= nil then
		return LWF_SETTINGSMENUS[key].ID, LWF_SETTINGSMENUS[key].Key
	else
		return "", ""
	end
end

local idAndUniqueName = function( self, parentKey, suffix )
	local panel, namePrefix = idAndBaseName(self, parentKey)
	return panel, self:GetUniqueName(namePrefix..suffix)
end

_lwf.SettingsMenu.AddMenu = function( self, _lam )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	if not _G[self.SettingsPanel] then
		LWF_SETTINGSMENUS[self.SettingsPanel] = { Key = self.SettingsPanel, Name = self.SettingsName }
		LWF_SETTINGSMENUS[self.SettingsPanel].ID = _lwf.SettingsMenu.LAM:CreateControlPanel(LWF_SETTINGSMENUS[self.SettingsPanel].Key, LWF_SETTINGSMENUS[self.SettingsPanel].Name)
	end
end

_lwf.SettingsMenu.AddonLabel = function( self, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "AddonLabel")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddHeader( panel, name, "|cCAB222".._lwf._var.Descr( self ).."|r" )
end

_lwf.SettingsMenu.AddHeader = function( self, displayText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	if displayText == nil then return nil; end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Header")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddHeader( panel, name, "|cCAB222"..displayText.."|r" )
end

_lwf.SettingsMenu.AddSlider = function( self, text, tooltip, minValue, maxValue, step, getFunc, setFunc, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Slider")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddSlider( panel, name, text, tooltip, minValue, maxValue, step, getFunc, setFunc, warning, warningText )
end

_lwf.SettingsMenu.AddDropdown = function( self, text, tooltip, validChoices, getFunc, setFunc, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Dropdown")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddDropdown( panel, name, text, tooltip, validChoices, getFunc, setFunc, warning, warningText )
end

_lwf.SettingsMenu.AddCheckbox = function( self, text, tooltip, getFunc, setFunc, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Checkbox")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddCheckbox( panel, name, text, tooltip, getFunc, setFunc, warning, warningText )
end

_lwf.SettingsMenu.AddColorPicker = function( self, text, tooltip, getFunc, setFunc, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "ColorPicker")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddColorPicker( panel, name, text, tooltip, getFunc, setFunc, warning, warningText )
end

_lwf.SettingsMenu.AddEditBox = function( self, text, tooltip, isMultiLine, getFunc, setFunc, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "EditBox")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddEditBox( panel, name, text, tooltip, isMultiLine, getFunc, setFunc, warning, warningText )
end

_lwf.SettingsMenu.AddButton = function( self, text, tooltip, onClick, warning, warningText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Button")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddButton( panel, name, text, tooltip, onClick, warning, warningText )
end

_lwf.SettingsMenu.AddDescription = function( self, text, titleText, _lam, _specificPanel )
	if not self then return end
	if not _lam then _lam = _lwf.SettingsMenu.LAM end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Description")
	if _specificPanel then panel = _specificPanel end
	if not panel then return end
	return _lam:AddDescription( panel, name, text, titleText )
end

_lwf.SettingsMenu._configButtonToAttach = function( self, text, onClick )
	local wm = GetWindowManager()
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "ConfigButton")
	local button = wm:CreateTopLevelWindow(name)
	button:SetParent(ZO_OptionsWindowSettingsScrollChild)
	button:SetDimensions(140, 28)
	button:SetMouseEnabled(true)
	
	button.btn = wm:CreateControlFromVirtual(name.."Button", button, "ZO_DefaultButton")
	local btn = button.btn
	btn:SetAnchor(TOPRIGHT)
	btn:SetWidth(140)
	btn:SetText(text)
	btn:SetHandler("OnClicked", onClick)
	
	button.controlType = OPTIONS_CUSTOM
	button.customSetupFunction = function() end	--move handlers into this function? (since I created a function...)
	button.panel = panel
	btn:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	btn:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	ZO_OptionsWindow_InitializeControl(button)
	
	return button
end

_lwf.SettingsMenu.AddCheckboxAndConfig = function( self, text, tooltip, getFunc, setFunc, warning, warningText, buttonText, onClick )
	if not self then return end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Dropdown")
	if not panel then return end
	local obj = _lwf.SettingsMenu.LAM:AddCheckbox( panel, name, text, tooltip, getFunc, setFunc, warning, warningText )
	obj:SetWidth( obj:GetWidth()-140 )
	obj:GetNamedChild("Checkbox"):SetWidth( obj:GetNamedChild("Checkbox"):GetWidth()-140 )
	local btn = _lwf.SettingsMenu._configButtonToAttach( self, buttonText, onClick )
	btn:SetAnchor( TOPLEFT, obj, TOPRIGHT, 4, 0 )
	return obj, btn
end

_lwf.SettingsMenu.AddDropdownAndConfig = function( self, text, tooltip, validChoices, getFunc, setFunc, warning, warningText, buttonText, onClick )
	if not self then return end
	local panel, name = idAndUniqueName(self, self.SettingsPanel, "Dropdown")
	if not panel then return end
	local obj = _lwf.SettingsMenu.LAM:AddDropdown( panel, name, text, tooltip, validChoices, getFunc, setFunc, warning, warningText )
	obj:SetWidth( obj:GetWidth()-140 )
	local btn = _lwf.SettingsMenu._configButtonToAttach( self, buttonText, onClick )
	btn:SetAnchor( LEFT, obj, RIGHT, 4, 0 )
	return obj, btn
end

--[[
	EXPECTED FORMAT OF listOfSettings
	{
		{
			label = *string*,
			settingKey = *string*,
			defaultValue = *variant*, 	-- can be any data type // if typeOf is "colorpicker" then this should be an array of { r=#, g=#, b=#, a=# }
			typeOf = *string*, 			-- MUST BE ONE OF: checkbox, dropdown, button, slider, colorpicker, editbox, header // editbox will always be single line in this format
			validChoices = *table*,		-- only used by typeOf="dropdown"
			minValue = *int*, 			-- only used by typeOf="slider"
			maxValue = *int*, 			-- only used by typeOf="slider"
			step = *int*,				-- only used by typeOf="slider"
			onClick = *func*,			-- only user by typeOf="button"
			tooltip = *string*,
		},
	}
	Top-level keys will be extracted out in the order they were inserted
]]--

local chillens = .1
local childGroupTables = {}

_lwf.SettingsMenu._GenerateChildGroup = function( self, parent, settingObj, listOfSettings, callBack )
	if not self then return end
	local los = listOfSettings
	if not los then return end
	local losCount = _lwf._global.Func.table_count( los )
	chillens = chillens + .00001
	parent.childPanelCode = _G[self.SettingsPanel] + chillens
	childGroupTables[_G[self.SettingsPanel] + chillens] = {}
	local _specificPanel = parent.childPanelCode
	local drewChild = false
	for x = 2, losCount, 1 do
		local thisObj = los[x]
		drewChild = false
		if thisObj then
			if thisObj.label then
				if thisObj.settingKey then
					if thisObj.typeOf == "checkbox" then
						local thisChild = _lwf.SettingsMenu.AddCheckbox( self, thisObj.label, thisObj.tooltip, function()
							return _lwf._global.Func.GetOrDefault( self, thisObj.defaultValue, settingObj[ thisObj.settingKey ] )
						end, function( val ) callBack( val, thisObj.settingKey ) end, nil, nil, nil, _specificPanel )
						if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
						table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
						drewChild = true
					elseif thisObj.typeOf == "header" then
						local thisChild = _lwf.SettingsMenu.AddHeader( self, thisObj.label, nil, _specificPanel )
						if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
						table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
						drewChild = true
					elseif thisObj.typeOf == "dropdown" then
						if thisObj.validChoices then
							local thisChild = _lwf.SettingsMenu.AddDropdown( self, thisObj.label, thisObj.tooltip, thisObj.validChoices, function()
								return _lwf._global.Func.GetOrDefault( self, thisObj.defaultValue, settingObj[ thisObj.settingKey ] )
							end, function( val ) callBack( val, thisObj.settingKey ) end, nil, nil, nil, _specificPanel )
							if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
							table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
							drewChild = true
						end
					elseif thisObj.typeOf == "button" then
						if thisObj.onClick then
							local thisChild = _lwf.SettingsMenu.AddButton( self, thisObj.label, thisObj.tooltip, thisObj.onClick, nil, nil, nil, _specificPanel )
							if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
							table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
							drewChild = true
						end
					elseif thisObj.typeOf == "slider" then
						if thisObj.minValue and thisObj.maxValue and thisObj.step then
							local thisChild = _lwf.SettingsMenu.AddSlider( self, thisObj.label, thisObj.tooltip, thisObj.minValue, thisObj.maxValue, thisObj.step, function()
								return _lwf._global.Func.GetOrDefault( self, thisObj.defaultValue, settingObj[ thisObj.settingKey ] )
							end, function( val ) callBack( val, thisObj.settingKey ) end, nil, nil, nil, _specificPanel )
							if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
							table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
							drewChild = true
						end
					elseif thisObj.typeOf == "colorpicker" then
						local thisChild = _lwf.SettingsMenu.AddColorPicker( self, thisObj.label, thisObj.tooltip, function()
							local color = _lwf._global.Func.GetOrDefault( self, thisObj.defaultValue, settingObj[ thisObj.settingKey ] )
							return color.r, color.g, color.b, color.a
						end, function( cr,cg,cb,ca ) callBack( { r=cr,g=cg,b=cb,a=ca }, thisObj.settingKey ) end, nil, nil, nil, _specificPanel )
						if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
						table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
						drewChild = true
					elseif thisObj.typeOf == "editbox" then
						local thisChild = _lwf.SettingsMenu.AddEditBox( self, thisObj.label, thisObj.tooltip, false, function()
							return _lwf._global.Func.GetOrDefault( self, thisObj.defaultValue, settingObj[ thisObj.settingKey ] )
						end, function( val ) callBack( val, thisObj.settingKey ) end, nil, nil, nil, _specificPanel )
						if x == 2 then thisChild:ClearAnchors(); thisChild:SetAnchor(TOPLEFT); end
						table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], thisChild )
						drewChild = true
					end
				end
			end
		end
	end
	if drewChild then
		local doneButton = _lwf.SettingsMenu.AddButton( self, "<< Back", nil, function() 
			ZO_OptionsWindow_ChangePanels( parent.panelCode ) 
		end, nil, nil, nil, _specificPanel )
		table.insert( childGroupTables[_G[self.SettingsPanel] + chillens], doneButton )
	end
	return childGroupTables[_G[self.SettingsPanel] + chillens]
end

local optionGroups = {}

_lwf.SettingsMenu.AddBoolWithChildGroup = function( self, settingObj, listOfSettings, callBack, buttonText )
	if not self then return end
	local los = listOfSettings
	if not los then return end
	local losCount = _lwf._global.Func.table_count( los )
	if not (losCount > 1) then return end
	local topLevel = los[1]
	if not topLevel then return end
	if not topLevel.label then return end
	if not topLevel.settingKey then return end
	local callMeWhenClicked = function()
		if optionGroups then
			if optionGroups[ topLevel.label ] then
				if not ZO_OptionsWindow.controlTable[optionGroups[ topLevel.label ].parent.childPanelCode] then
					ZO_OptionsWindow.controlTable[optionGroups[ topLevel.label ].parent.childPanelCode] = childGroupTables[optionGroups[ topLevel.label ].parent.childPanelCode]
				end
				if not ZO_OptionsWindow.panelNames[optionGroups[ topLevel.label ].parent.childPanelCode] then
					ZO_OptionsWindow.panelNames[optionGroups[ topLevel.label ].parent.childPanelCode] = optionGroups[ topLevel.label ].parent.childWinName
				end
				ZO_OptionsWindow_ChangePanels( optionGroups[ topLevel.label ].parent.childPanelCode )
			end
		end
	end
	local parent, btn = _lwf.SettingsMenu.AddCheckboxAndConfig( self, topLevel.label, nil, function()
		return _lwf._global.Func.GetOrDefault( self, topLevel.defaultValue, settingObj[ topLevel.settingKey ] )
	end, function( val ) callBack( val, topLevel.settingKey ) end, nil, nil, buttonText, function( self ) 
		callMeWhenClicked()
	end )
	parent.panelCode = _G[self.SettingsPanel]
	optionGroups[ topLevel.label ] = {}
	optionGroups[ topLevel.label ].parent = parent
	optionGroups[ topLevel.label ].children = _lwf.SettingsMenu._GenerateChildGroup( self, parent, settingObj, listOfSettings, callBack )
end

_lwf.SettingsMenu.AddDDLWithChildGroup = function( self, settingObj, listOfSettings, callBack, buttonText )
	if not self then return end
	local los = listOfSettings
	if not los then return end
	local losCount = _lwf._global.Func.table_count( los )
	if not losCount > 1 then return end
	local topLevel = los[1]
	if not topLevel then return end
	if not topLevel.label then return end
	if not topLevel.settingKey then return end
	local callMeWhenClicked = function()
		if optionGroups then
			if optionGroups[ topLevel.label ] then
				if not ZO_OptionsWindow.controlTable[optionGroups[ topLevel.label ].parent.childPanelCode] then
					ZO_OptionsWindow.controlTable[optionGroups[ topLevel.label ].parent.childPanelCode] = childGroupTables[optionGroups[ topLevel.label ].parent.childPanelCode]
				end
				if not ZO_OptionsWindow.panelNames[optionGroups[ topLevel.label ].parent.childPanelCode] then
					ZO_OptionsWindow.panelNames[optionGroups[ topLevel.label ].parent.childPanelCode] = optionGroups[ topLevel.label ].parent.childWinName
				end
				ZO_OptionsWindow_ChangePanels( optionGroups[ topLevel.label ].parent.childPanelCode )
			end
		end
	end
	local parent, btn = _lwf.SettingsMenu.AddDropdownAndConfig( self, topLevel.label, nil, topLevel.validChoices, function()
		return _lwf._global.Func.GetOrDefault( self, topLevel.defaultValue, settingObj[ topLevel.settingKey ] )
	end, function( val ) callBack( val, topLevel.settingKey ) end, nil, nil, buttonText, function( self ) 
		callMeWhenClicked()
	end )
	parent.panelCode = _G[self.SettingsPanel]
	optionGroups[ topLevel.label ] = {}
	optionGroups[ topLevel.label ].parent = parent
	optionGroups[ topLevel.label ].children = _lwf.SettingsMenu._GenerateChildGroup( self, parent, settingObj, listOfSettings, callBack )
end

_lwf.UpdateTicRegistered = false

local LWF_UPDATEHANDLER = function()
	local libAddonHook = "LibWykkydAddonFramework_StandardEventRegister"
	if _lwf._global.Func.table_count(_lwf.Events.Registry) > 0 then
		for e,v in pairs(_lwf.Events.Registry) do
			if not _lwf.Events._NumRegisteredToGlobalHandler[e] then _lwf.Events._NumRegisteredToGlobalHandler[e] = 0 end
			if not _lwf.Events._RegisteredToGlobalHandler[e] then _lwf.Events._RegisteredToGlobalHandler[e] = false end
			for a,t in pairs(v) do
				if t.Unregister and not t.Unregistered then
					_lwf.Events._NumRegisteredToGlobalHandler[e] = _lwf.Events._NumRegisteredToGlobalHandler[e] - 1
					t.Unregistered = true
				elseif not t.Registered and not t.Unregister then
					_lwf.Events._NumRegisteredToGlobalHandler[e] = _lwf.Events._NumRegisteredToGlobalHandler[e] + 1
					t.Registered = true
				end
			end
			if _lwf.Events._NumRegisteredToGlobalHandler[e] > 0 then
				if not _lwf.Events._RegisteredToGlobalHandler[e] then
					EVENT_MANAGER:RegisterForEvent(
						libAddonHook, 
						_lwf.Events.GameEventTable[e].CODE, 
						_lwf.Events.GlobalHandler)
					_lwf.Events._RegisteredToGlobalHandler[e] = true
				end
			else
				if _lwf.Events._RegisteredToGlobalHandler[e] then
					if _lwf.Events._hasUnregistered[_lwf.Events.GameEventTable[e].CODE] ~= nil then
						if _lwf.Events._hasUnregistered[_lwf.Events.GameEventTable[e].CODE][libAddonHook] == nil then
							EVENT_MANAGER:UnregisterEvent(libAddonHook, _lwf.Events.GameEventTable[e].CODE)
							_lwf.Events._hasUnregistered[_lwf.Events.GameEventTable[e].CODE][libAddonHook] = true
						end
					end
				end
			end
		end
	end
	
	_lwf._global.Frames.Events.ToggleUIFrames()
	
	for k,t in pairs(_lwf.Events.Registered_onupdatecallback) do
		if t.Callback then
			if t.Buffer then
				if _lwf._global.Func.BufferPause(k, t.Buffer) then t.Callback() end
			else t.Callback() end
		end
	end
end

REGISTER_WYKKYD_FACTORY = 
function( self, addonLoadedIndependently, enableFrameworkOnUpdate, onBeforeStartupCallback, onStartupCallback, onAfterStartupCallback )
	if not self then return end
	
	self.addonLoadedIndependently 	= addonLoadedIndependently
	self.enableFrameworkOnUpdate 	= enableFrameworkOnUpdate
	self.onBeforeStartupCallback 	= onBeforeStartupCallback
	self.onStartupCallback 			= onStartupCallback
	self.onAfterStartupCallback 	= onAfterStartupCallback
	
	if self.ID == nil and self.Name ~= nil then self.ID = self.Name end

	self.GLOBAL = {}
	self.GLOBAL.ChatChannels 		= _lwf._global.Var.ChatChannels
	self.GLOBAL.TextAlign 			= _lwf._global.Var.TextAlign
	self.GLOBAL.EquipSlot 			= _lwf._global.Var.EquipSlot
	self.GLOBAL.EquipSlotBagSlot 	= _lwf._global.Var.EquipSlotBagSlot
	self.GLOBAL.GameImages 			= _lwf._global.Var.GameImages
	
	self.Frames						= _lwf._global.Frames

	self.table_findRemove
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.table_findRemove( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.comma_value
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.comma_value( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.string_trim
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.string_trim( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.string_split
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.string_split( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.Round
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.Round( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetMillisecondsToHuman
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.MillisecondsToHuman( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.PairsByKeys
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.PairsByKeys( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.LoadEmotes = _lwf._global.Func.LoadEmotes
	self.GetGameImage
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.FindGameImage( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetColorScale_RedGreenPowerMeter
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.ColorScale_RedGreenPowerMeter( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.Print
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			_lwf._global.Func.Print( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetCountOf
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.CountOf( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetNextOf
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.NextOf( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetDateTimeString
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.GetDateTimeString( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetUniqueName = _lwf._global.Func.UniqueName
	self.GetFrame
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.FindFrame( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.DumpWindowsToChat
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.DumpWindowsToChat( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.DumpCommandsToChat
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.DumpCommandsToChat( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.BufferPause
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.BufferPause( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.DeriveGuildName
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.GuildName( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.GetOrDefault = _lwf._global.Func.GetOrDefault
	self.trim
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.trim( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	self.split
		= function( self, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) 
			return _lwf._global.Func.split( p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20 ) end
	
	self.RegisterEvent			= _lwf.Events.Register
	self.UnregisterEvent		= _lwf.Events.Unregister
	self.OnUpdateCallback		= _lwf.Tic
	self.SlashCommand			= _lwf.Commands.Toggle
	self.SlashCommand_Add		= _lwf.Commands.Add
	self.SlashCommand_Remove	= _lwf.Commands.Remove
	
	self.CreateMenu 				= _lwf.SettingsMenu.AddMenu
	self.AddMenuAddonLabel  		= _lwf.SettingsMenu.AddonLabel
	self.AddMenuHeader 				= _lwf.SettingsMenu.AddHeader
	self.AddMenuSlider 				= _lwf.SettingsMenu.AddSlider
	self.AddMenuDropdown 			= _lwf.SettingsMenu.AddDropdown
	self.AddMenuCheckbox 			= _lwf.SettingsMenu.AddCheckbox
	self.AddMenuColorPicker 		= _lwf.SettingsMenu.AddColorPicker
	self.AddMenuEditBox 			= _lwf.SettingsMenu.AddEditBox
	self.AddMenuButton 				= _lwf.SettingsMenu.AddButton
	self.AddMenuDropdownWithConfig	= _lwf.SettingsMenu.AddDropdownAndConfig
	self.AddMenuCheckboxWithConfig	= _lwf.SettingsMenu.AddCheckboxAndConfig
	self.AddMenuBoolWithChildGroup	= _lwf.SettingsMenu.AddBoolWithChildGroup
	self.AddMenuDDLWithChildGroup	= _lwf.SettingsMenu.AddDDLWithChildGroup
	
	if self.SettingsName then
		self.SettingsPanel = self.SettingsName.."Panel"
	else
		self.SettingsPanel = _lwf.SettingsMenu.defaultMenu
	end
	
	if not _lwf.Addons then _lwf.Addons = {} end
	if not _lwf.Addons[self.Name] then _lwf.Addons[self.Name] = {} end
	_lwf.Addons[self.Name].__base = self
	self.__index = self
	
	if not _lwf.UpdateTicRegistered then EVENT_MANAGER:RegisterForUpdate("LWF_UpdateTic", 100, LWF_UPDATEHANDLER) end
	_lwf.UpdateTicRegistered = true
end

EVENT_MANAGER:RegisterForEvent( "LibWykkydFactory_StartUp", EVENT_ADD_ON_LOADED, _lwf.AddonPrep )
