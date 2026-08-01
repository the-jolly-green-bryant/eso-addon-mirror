-------------------------------------------------------------------------------------------------------------------------------------------------
-- Base of CODE => Bandits User Interface by Hoft 
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRMenu = {}
local DsRMenu = DsRMenu  or {}

local LMP     = LibMapPins
local LAM     = LibAddonMenu2

local DsRIcon = DsRglobals:HolidayIconLoad()

DsRMenu.name = "DsRMenu"

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MENU OPTIONS COMPONENT
local MenuOptions,MenuPanel,MenuHandlers={},{},{}
local Settings,SettingsGUILD,SettingsTEMP = {},{},{}

local MenuIcon={
	MenuMisc 				= "/esoui/art/login/authentication_trusted_down.dds",
	MenuLoot 			    = "/esoui/art/hud/loothistory_bonusdropsourceicon_expscroll.dds",
	MenuStickerbook 		= "/esoui/art/collections/collections_tabicon_itemsets_down.dds",
	MenuAllianceWarGeneral  = "/esoui/art/guild/ownership_icon_keep.dds",
	MenuAllianceWarCyrodiil = "/esoui/art/guild/ownership_icon_keep.dds",
	MenuAllianceWarImpCity  = "/esoui/art/guild/ownership_icon_keep.dds",
	MenuGroupRaid 	        = "/esoui/art/lfg/lfg_indexicon_group_down.dds",
	MenuGroupBuff 	        = "/esoui/art/lfg/lfg_indexicon_group_down.dds",
	MenuAchievTrack	        = "/esoui/art/journal/journal_tabicon_achievements_down.dds",
	MenuCrafting 	        = "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",
}
local MenuNumber={
	MenuMisc				= "|c9fb6cd1.  |r",
	MenuLoot				= "|c9fb6cd2.  |r",
	MenuStickerbook 		= "|c9fb6cd3.  |r",
	MenuAllianceWarGeneral  = "|c9fb6cd4.1 |r",
	MenuAllianceWarCyrodiil = "|c9fb6cd4.2 |r",
	MenuAllianceWarImpCity  = "|c9fb6cd4.3 |r",
	MenuGroupRaid			= "|c9fb6cd5.1 |r",
	MenuGroupBuff			= "|c9fb6cd5.2 |r",
	MenuAchievTrack			= "|c9fb6cd6.  |r",
	MenuCrafting			= "|c9fb6cd7.  |r",
}

local function loadTableToMem()
    if DsRAutoINV.cfg.Table ~= nil then
        table2 = {}
        table2 = DsRAutoINV.cfg.Table
        tl = tablelength(table2)
        DsRGuildDeathTableIndicatorData:SetText(settext(table2, "k"))
        DsRGuildDeathTableIndicatorData2:SetText(settext(table2))
        if tl == 0 then
            bglen = 55
            contlen = 0
        elseif tl < DsRAutoINV.cfg.TableLenght then
            bglen = ((26 * tl) + 55 + 20)
            contlen = ((26 * tl) + 55 + 20)
        else
            bglen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 20)
            contlen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 20)
        end
        DsRGuildDeathTableIndicatorBg:SetDimensions(230, bglen)
        DsRGuildDeathTableIndicatorContainer:SetDimensions(230, contlen)
        table1 = table2
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function MenuOptions_Init()
-- -----------------------
-- 1. Allgemeines
-- -----------------------
	MenuOptions["MenuMisc"]={
		{	type		="description", 
			name		="DsRGuild_donationTxt1",
		},		
		{	type		="description",
			name		="DsRGuildMenue_accsettings",
		},
		{type="submenu",name="DsRGuildMenue_chatcommands",controls={
			{	type		="description", 
				name		="DsRGuildMenue_accKeybindAddonUpdate",
			},		
			{	type		="description", 
				name		="DsRGuildMenue_accKeybind",
			},		
			{	type		="description", 
				name		="DsRGuildBind_slashdsrim",
			},		
			{	type		="description", 
				name		="DsRGuildBind_slashDESC1",
			},		
			{	type		="description", 
				name		="DsRGuildBind_slashDESC2",
			},		
			{	type		="description", 
				name		="DsRGuildBind_slashDESC3",
			},		
			{	type		="description", 
				name		="DsRGuildPvP_ap_telvarSaverKeybind",
			},		
		}},
		{type="submenu",name="DsRGuildMenue_Developer",controls={
			{	type		="description", 
				name		="DsRGuildMenue_DeveloperDesc",
			},		
			{	type		="checkbox",
				name		="DsRGuildMenue_DeveloperAct",
				getFunc		=function() return DsRAutoINV.cfg.DeveloperMode end,
				setFunc		=function(value) DsRAutoINV.cfg.DeveloperMode = value DsR.Menu.HandleReloadUIPressed() end,
				warning     = "ReloadUiWarn2",
			},
		}},
		{type="submenu",name="DsRGuildMenue_DsRinternalInfos",controls={
			{	type		="description", 
				name		="DsRGuildMenue_DsRInfoHome",
			},
			{	type		="checkbox",
				name		="DsRGuildMenue_DsRInfoRoster",
				getFunc		=function() return DsRAutoINV.cfg.GuildInfRosterOnOff end,
				setFunc		=function(value) DsRAutoINV.cfg.GuildInfRosterOnOff = value DsR.UI.ReloadUIButton() end,
				warning     = "ReloadUiWarn",
			},
			{	type		="checkbox",
				name		="DsRGuildMenue_DsRInfoRank",
				getFunc		=function() return DsRAutoINV.cfg.GuildInfRankOnOff end,
				setFunc		=function(value) DsRAutoINV.cfg.GuildInfRankOnOff = value DsR.UI.ReloadUIButton() end,
				warning     = "ReloadUiWarn",
			},
			{	type		="checkbox",
				name		="DsRGuildMenue_DsRInfoRecrut",
				getFunc		=function() return DsRAutoINV.cfg.GuildInfRecrutOnOff end,
				setFunc		=function(value) DsRAutoINV.cfg.GuildInfRecrutOnOff = value DsR.UI.ReloadUIButton() end,
				warning     = "ReloadUiWarn",
			},
			{	type		="checkbox",
				name		="DsRGuildMenue_DsRMasterJoint",
				getFunc		=function() return DsRAutoINV.cfg.GuildMasterJoin end,
				setFunc		=function(value) DsRAutoINV.cfg.GuildMasterJoin = value end,
			},
			{	type		="checkbox",
				name		="DsRGuildMenue_DsRMasterJoinSound",
				getFunc		=function() return DsRAutoINV.cfg.GuildMasterJoinSound end,
				setFunc		=function(value) DsRAutoINV.cfg.GuildMasterJoinSound = value end,
			},
		}},
		{	type		="subheader", 
			name		="DsRGuildMenue_DsRTakeOneMenue",
		},
		{	type		="checkbox",
			name		="DsRGuildMenue_DsRTakeOneOnOff",
			getFunc		=function() return DsRAutoINV.cfg.TakeOneOnOff end,
			setFunc		=function(value) DsRAutoINV.cfg.TakeOneOnOff = value DsR.Menu.HandleReloadUIPressed() end,
			warning     = "ReloadUiWarn2",
		},
		{	type		="subheader", 
			name		="DsRGuildMenue_DsRSTACHATMenue",
		},
		{	type		="checkbox",
			name		="DsRGuildMenue_DsRSTACHATONOFF",
			getFunc		=function() return DsRGuildLoot.sV.DefaultChatONOFF end,
			setFunc		=function(value) DsRGuildLoot.sV.DefaultChatONOFF = value end,
		},
		{	type		="dropdown",
			name		="DsRGuildMenue_DsRSTACHATdropdown",
			choices		={DsR_Chat_G1, DsR_Chat_G2, DsR_Chat_G3, DsR_Chat_G4, DsR_Chat_G5, DsR_Chat_SAY, DsR_Chat_ZONE, DsR_Chat_PARTY},
			getFunc		=function() return DsRGuildLoot.sV.DefaultChat end,
			setFunc		=function(i,value) DsRGuildLoot.sV.DefaultChat = i end,
			disabled    =function() return not DsRGuildLoot.sV.DefaultChatONOFF end,
		},
		{	type		="subheader", 
			name		="DsRGuildMenue_DsRFriendsMenue",
		},
		{	type		="checkbox",
			name		="DsRGuildMenue_DsRFriends",
			getFunc		=function() return DsRAutoINV.cfg.FriendsOnOff end,
			setFunc		=function(value) DsRAutoINV.cfg.FriendsOnOff = value DsR.UI.ReloadUIButton() end,
			warning     = "ReloadUiWarn1",
		},
		{	type		="checkbox",
			name		="DsRGuildMenue_DsRFriendsCOLOR",
			getFunc		=function() return DsRAutoINV.cfg.FriendsColor end,
			setFunc		=function(value) DsRAutoINV.cfg.FriendsColor = value DsR.UI.ReloadUIButton() end,
			disabled    = function() return DsRAutoINV.cfg.FriendsOnOff end,
			warning     = "ReloadUiWarn1",
		},
		{	type		="editboxMulti",
			name		="DsRGuildMenue_DsRFriendsLogin",
			getFunc		=function() return DsRAutoINV.cfg.ExtraNamesLogin end,
			setFunc		=function(value) DsRAutoINV.cfg.ExtraNamesLogin = value end,
    		default     = "",
		},
		{	type		="subheader", 
			name		="DsRGuildUnknown_WelcomeMain",
		},
		{	type		="description", 
			name		="DsRGuildUnknown_WelcomeAttention",
		},	
		{	type		="description", 
			name		="DsRGuildUnknown_WelcomeAttentionA",
		},	
		DsR.Menu.WelcomeGuild()

	}
	MenuPanel["MenuMisc"]={name="IndexMisc"}
	MenuHandlers["MenuMisc"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}
	
-- -----------------------
-- 2. Lootmanager
-- -----------------------
	MenuOptions["MenuLoot"]={
		{	type		="subheader", 
			name		="DsRGuildMenue_trading",
		},
		{
			type 	 = "description",
			name     = "DsRGuildLoot_trade_support1",
		},
		{
			type 	 = "description",
			name     = "DsRGuildLoot_trade_support2",
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_trade_chat",
			getFunc  = function() return DsRGuildLoot.sV.ChatTradePrice end,
			setFunc  = function(value) DsRGuildLoot.sV.ChatTradePrice = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_trade_screen",
			getFunc  = function() return DsRGuildLoot.sV.ScreenTradePrice end,
			setFunc  = function(value) DsRGuildLoot.sV.ScreenTradePrice = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_trade_history",
			getFunc  = function() return DsRGuildLoot.sV.HistoryTradePrice end,
			setFunc  = function(value) DsRGuildLoot.sV.HistoryTradePrice = value end,
		},
		{type="submenu",name="DsRGuildMenue_Container",controls={
			{
				type 	 = "description",
				name     = "DsRGuildMenue_OW",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_FM",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_FM end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_FM = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_BGR",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_BGR end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_BGR = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_BVS",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_BVS end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_BVS = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_hAR",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_hAR end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_hAR = value end,
			},
			{
				type 	 = "description",
				name     = "DsRGuildMenue_IC",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICversorger",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICversorger end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICversorger = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICschmied",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICschmied end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICschmied = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICschneider",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICschneider end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICschneider = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICalchemi",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICalchemi end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICalchemi = value end,
			},		
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICrunen",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICrunen end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICrunen = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_ICholz",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_ICholz end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_ICholz = value end,
			},
			{
				type 	 = "description",
				name     = "DsRGuildMenue_EA",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAschmuck",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAschmuck end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAschmuck = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAversorger",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAversorger end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAversorger = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAschneider",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAschneider end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAschneider = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAschmied",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAschmied end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAschmied = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAalchemi",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAalchemi end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAalchemi = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EArunen",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EArunen end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EArunen = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_EAholz",
				getFunc  = function() return DsRGuildLoot.sV.LootContainer_EAholz end,
				setFunc  = function(value) DsRGuildLoot.sV.LootContainer_EAholz = value end,
			},
		}},
		{type="submenu",name="DsRGuildMenue_notificationscreen",controls={
			{	type		="checkbox",
				name		="DsRGuildLoot_screenloot_deactivate",
				getFunc		=function() return DsRGuildLoot.sV.ScreenOnOff end,
				setFunc		=function(value) DsRGuildLoot.sV.ScreenOnOff = value end,
			},
			{	type		="dropdown",
				name		="DsRGuildLoot_own_loot_quali",
				choices		={DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
				getFunc		=function() return DsRGuildLoot.sV.ScreenQualiloot end,
				setFunc		=function(i,value) DsRGuildLoot.sV.ScreenQualiloot = value end,
				disabled    = function() return DsRGuildLoot.sV.ScreenOnOff end,
			},
			{	type		="subheader", 
				name		="DsRGuildMenue_notificationspecial",
			},
			{	type		="description", 
				name		="DsRGuildMenue_notificationspecialTxt",
			},
			{	type		="checkbox",
				name		="DsRGuildLoot_fortified_nirncrux",
				getFunc		=function() return DsRGuildLoot.sV.ScreenfNirn end,
				setFunc		=function(value) DsRGuildLoot.sV.ScreenfNirn = value end,
			},
			{	type		="checkbox",
				name		="DsRGuildLoot_potent_nirncrux",
				getFunc		=function() return DsRGuildLoot.sV.ScreensNirn end,
				setFunc		=function(value) DsRGuildLoot.sV.ScreensNirn = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_kuta",
				getFunc  = function() return DsRGuildLoot.sV.ScreenKuta end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenKuta = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_hakeijo",
				getFunc  = function() return DsRGuildLoot.sV.ScreenHakeijo end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenHakeijo = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_LuminousInk",
				getFunc  = function() return DsRGuildLoot.sV.ScreenLuminousInk end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenLuminousInk = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_rubyblossomextract",
				getFunc  = function() return DsRGuildLoot.sV.ScreenRubyblossom end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenRubyblossom = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_mourningdew",
				getFunc  = function() return DsRGuildLoot.sV.ScreenMourningdew end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenMourningdew = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_PerfectRoe",
				getFunc  = function() return DsRGuildLoot.sV.ScreenPerfectRoe end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenPerfectRoe = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_AetherialDust",
				getFunc  = function() return DsRGuildLoot.sV.ScreenAetherialDust end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenAetherialDust = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_AethericCipher",
				getFunc  = function() return DsRGuildLoot.sV.ScreenAethericCipher end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenAethericCipher = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_endeavor",
				getFunc  = function() return DsRGuildLoot.sV.ScreenBestrebung end,
				setFunc  = function(value) DsRGuildLoot.sV.ScreenBestrebung = value end,
			},
		}},		
		{type="submenu",name="DsRGuildMenue_notificationchat",controls={
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBind_ArmorCollected",
				getFunc  = function() return DsRGuildBind.bind.Chatuncollect end,
				setFunc  = function(value) DsRGuildBind.bind.Chatuncollect = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_chatloot_trait",
				getFunc  = function() return DsRGuildLoot.sV.ChatTrait end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTrait = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_chatloot_deactivate",
				getFunc  = function() return DsRGuildLoot.sV.ChatOnOff end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatOnOff = value end,
			},
			{	type	 ="dropdown",
				name	 ="DsRGuildLoot_own_loot_quali",
				choices	 ={DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
				getFunc	 =function() return DsRGuildLoot.sV.ChatQualiloot end,
				setFunc	 =function(i,value) DsRGuildLoot.sV.ChatQualiloot = value end,
				disabled = function() return DsRGuildLoot.sV.ChatOnOff end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_group_loot_deactivate",
				getFunc  = function() return DsRGuildLoot.sV.ChatGroupLoot end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatGroupLoot = value end,
			},
			{	type	 ="dropdown",
				name	 ="DsRGuildLoot_group_loot_quali",
				choices	 ={DsR_Quality_NORMAL, DsR_Quality_FINE, DsR_Quality_SUPERIOR, DsR_Quality_EPIC, DsR_Quality_LEGENDARY, DsR_Quality_MYTHIC},
				getFunc	 =function() return DsRGuildLoot.sV.ChatQualiGroupLoot end,
				setFunc	 =function(i,value) DsRGuildLoot.sV.ChatQualiGroupLoot = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatGroupLoot end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_experience_gain",
				getFunc  = function() return DsRGuildLoot.sV.ChatXP end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXP = value end,
			},
			{	type		="editbox",
				name		="DsRGuildLoot_experience_gainTXT",
				getFunc		=function() return DsRGuildLoot.sV.ChatXPtxt end,
				setFunc		=function(value) DsRGuildLoot.sV.ChatXPtxt = value end,
    			disabled    = function() return not DsRGuildLoot.sV.ChatXP end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_gold_gain",
				getFunc  = function() return DsRGuildLoot.sV.ChatGold end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatGold = value end,
			},
			{	type		="editbox",
				name		="DsRGuildLoot_gold_gainTXT",
				getFunc		=function() return DsRGuildLoot.sV.ChatGoldtxt end,
				setFunc		=function(value) DsRGuildLoot.sV.ChatGoldtxt = value end,
    			disabled    = function() return not DsRGuildLoot.sV.ChatGold end,
			},
			{	type		="subheader", 
				name		="DsRGuildMenue_notificationspecial",
			},
			{	type		="description", 
				name		="DsRGuildMenue_notificationspecialTxt",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_fortified_nirncrux",
				getFunc  = function() return DsRGuildLoot.sV.ChatfNirn end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatfNirn = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_potent_nirncrux",
				getFunc  = function() return DsRGuildLoot.sV.ChatsNirn end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatsNirn = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_kuta",
				getFunc  = function() return DsRGuildLoot.sV.ChatKuta end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatKuta = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_hakeijo",
				getFunc  = function() return DsRGuildLoot.sV.ChatHakeijo end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatHakeijo = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_LuminousInk",
				getFunc  = function() return DsRGuildLoot.sV.ChatLuminousInk end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatLuminousInk = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_rubyblossomextract",
				getFunc  = function() return DsRGuildLoot.sV.ChatRubyblossom end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatRubyblossom = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_mourningdew",
				getFunc  = function() return DsRGuildLoot.sV.ChatMourningdew end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatMourningdew = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_PerfectRoe",
				getFunc  = function() return DsRGuildLoot.sV.ChatPerfectRoe end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatPerfectRoe = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_AetherialDust",
				getFunc  = function() return DsRGuildLoot.sV.ChatAetherialDust end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatAetherialDust = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_AethericCipher",
				getFunc  = function() return DsRGuildLoot.sV.ChatAethericCipher end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatAethericCipher = value end,
			},
			{	type		="subheader", 
				name		="DsRGuildMenue_notificationOther",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_undauntedkeys",
				getFunc  = function() return DsRGuildLoot.sV.ChatUnerschrocken end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatUnerschrocken = value end,
			},
			-- {
			-- 	type 	 = "checkbox",
			-- 	name 	 = "DsRGuildLoot_event_Tickets",
			-- 	getFunc  = function() return DsRGuildLoot.sV.Chatetickets end,
			-- 	setFunc  = function(value) DsRGuildLoot.sV.Chatetickets = value end,
			-- },
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_transmute_crystals",
				getFunc  = function() return DsRGuildLoot.sV.ChatTransmut end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTransmut = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_endeavor",
				getFunc  = function() return DsRGuildLoot.sV.ChatBestrebung end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatBestrebung = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_archival_fortunes",
				getFunc  = function() return DsRGuildLoot.sV.ChatEndless end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatEndless = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_imperial_fragments",
				getFunc  = function() return DsRGuildLoot.sV.ChatIMPfragments end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatIMPfragments = value end,
			},			
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBarMenu_TomeChallenge",
				getFunc  = function() return DsRGuildLoot.sV.ChatTomeChallenge end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTomeChallenge = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBarMenu_TomePoints",
				getFunc  = function() return DsRGuildLoot.sV.ChatTomePoints end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTomePoints = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBarMenu_TomePointCach",
				getFunc  = function() return DsRGuildLoot.sV.ChatTomePointCach end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTomePointCach = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBarMenu_TomeToken",
				getFunc  = function() return DsRGuildLoot.sV.ChatTomeToken end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTomeToken = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildBarMenu_TradeBars",
				getFunc  = function() return DsRGuildLoot.sV.ChatTradeBars end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatTradeBars = value end,
			},
			{	type		="subheader", 
				name		="DsRGuildLoot_experience_A",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_completed_Achievements",
				getFunc  = function() return DsRGuildLoot.sV.ChatArchivments end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatArchivments = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_progress_Achievements",
				getFunc  = function() return DsRGuildLoot.sV.ChatArchivmentsStatus end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatArchivmentsStatus = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_bookloot",
				getFunc  = function() return DsRGuildLoot.sV.ChatBookLoot end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatBookLoot = value end,
			},
			{	type		="subheader", 
				name		="DsRGuildLoot_experience_skill",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_experience_OnOff",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPskills end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPskills = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_WEAPON",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPweapon end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPweapon = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_ARMOR",
				getFunc  = function() return DsRGuildLoot.sV.ChatXParmor end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXParmor = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_GUILD",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPguild end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPguild = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_AVA",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPava end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPava = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_Excavation",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPexcavation end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPexcavation = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_Scrying",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPscrying end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPscrying = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_Legerdemain",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPlegerdemain end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPlegerdemain = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_SoulMagic",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPsoulmagic end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPsoulmagic = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_Vampire",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPvampire end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPvampire = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_Werewolf",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPwerewolf end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPwerewolf = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPskills end
			},
			{	type		="subheader", 
				name		="DsRGuildLoot_experience_crafting",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_experience_OnOff",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPcrafting end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPcrafting = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_alchemy",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPalchemy end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPalchemy = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_blacksmithing",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPblacksmithing end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPblacksmithing = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_woodworking",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPwoodworking end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPwoodworking = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_clothier",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPclothier end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPclothier = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_enchanting",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPenchanting end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPenchanting = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_jewelrymaking",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPjewelrymaking end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPjewelrymaking = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLoot_exp_provisioner",
				getFunc  = function() return DsRGuildLoot.sV.ChatXPprovisioner end,
				setFunc  = function(value) DsRGuildLoot.sV.ChatXPprovisioner = value end,
				disabled = function() return not DsRGuildLoot.sV.ChatXPcrafting end
			},
		}},		
		{type="submenu",name="DsRGuildLootHistory_Menue",controls={
			DsR.Menu.LootHistory()
		}},		
	}
	MenuPanel["MenuLoot"]={name="IndexLootManager"}
	MenuHandlers["MenuLoot"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}
	
-- -----------------------
-- 3. Stickerbook
-- -----------------------
	MenuOptions["MenuStickerbook"]={
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildBind_autobindloot",
			getFunc  = function() return DsRGuildBind.bind.autoBind end,
			setFunc  = function(value) DsRGuildBind.bind.autoBind = value end,
		},
	{
		type 	 = "description",
		name     = "DsRGuildBind_Iconshowin",
	},
	{	
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_bag",
		getFunc  = function() return DsRGuildBind.bind.show["bag"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["bag"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_trading",
		getFunc  = function() return DsRGuildBind.bind.show["trading"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["trading"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_bank",
		getFunc  = function() return DsRGuildBind.bind.show["bank"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["bank"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_housebank",
		getFunc  = function() return DsRGuildBind.bind.show["housebank"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["housebank"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_guildbank",
		getFunc  = function() return DsRGuildBind.bind.show["guild"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["guild"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_crafting",
		getFunc  = function() return DsRGuildBind.bind.show["crafting"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["crafting"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_transmute",
		getFunc  = function() return DsRGuildBind.bind.show["transmute"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["transmute"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_show_guildstore",
		getFunc  = function() return DsRGuildBind.bind.show["guildstore"] end,
		setFunc  = function(value) 
						DsRGuildBind.bind.show["guildstore"] = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
				   end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_chat_SystemShow",
		getFunc  = function() return DsRGuildBind.bind.chatSystemShow end,
		setFunc  = function(value) DsRGuildBind.bind.chatSystemShow = value end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_chat_MessageShow",
		getFunc  = function() return DsRGuildBind.bind.chatMessageShow end,
		setFunc  = function(value) DsRGuildBind.bind.chatMessageShow = value end,
	},
	{
		type 	 = "description",
		name     = "DsRGuildBind_Iconposition",
	},
	{	type		="slider",
		name		="DsRGuildBind_pos_iconOffset",
		min			=-390,
		max			=150,
		step		=10,
		getFunc		=function() return DsRGuildBind.bind.iconOffset end,
		setFunc		=function(value) 
						DsRGuildBind.bind.iconOffset = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
					 end,
	},
	{	type		="slider",
		name		="DsRGuildBind_pos_iconStoreOffset",
		min			=-270,
		max			=330,
		step		=10,
		getFunc		=function() return DsRGuildBind.bind.iconStoreOffset end,
		setFunc		=function(value) 
						DsRGuildBind.bind.iconStoreOffset = value
						DsRGuildBind.Mark.OnSetCollectionUpdated()
					 end,
	},
	{
		type 	 = "description",
		name     = "DsRGuildBind_req_desc",
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_req_showRequestLink",
		getFunc  = function() return DsRGuildBind.bind.showRequestLink end,
		setFunc  = function(value) DsRGuildBind.bind.showRequestLink = value end,
	},
	{
		type 	 = "checkbox",
		name 	 = "DsRGuildBind_req_requestInWhisper",
		getFunc  = function() return DsRGuildBind.bind.requestInWhisper end,
		setFunc  = function(value) DsRGuildBind.bind.requestInWhisper = value end,
	},
	{	type	 ="editbox",
		name	 ="DsRGuildBind_req_requestPrefix",
		getFunc	 =function() return DsRGuildBind.bind.requestPrefix end,
		setFunc	 =function(text) DsRGuildBind.bind.requestPrefix = text end,
		default  ="Can I get",
		disabled = function() return not DsRGuildBind.bind.showRequestLink end,
	}
	}
	MenuPanel["MenuStickerbook"]={name="IndexStickerbook"}
	MenuHandlers["MenuStickerbook"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 4.1 Allianzkrieg - Allgemein
-- -----------------------
	MenuOptions["MenuAllianceWarGeneral"]={
		-- {type="submenu",name="DsRGuildMenue_PvPandBGkilling",controls={
			{	type		="subheader",
				name		="DsRGuildMenue_PvPandBGkilling",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_PvPKillFeedCyro",
				getFunc  = function() return DsRGuildPvP.pvp.PvPkillFeedCyro end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPkillFeedCyro = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_PvPKillFeedImperial",
				getFunc  = function() return DsRGuildPvP.pvp.PvPkillFeedImp end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPkillFeedImp = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_KillingBlowScreen",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKillScreen end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPKillScreen = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_KillingBlowChat",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKillBlowChat end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPKillBlowChat = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_KillingChatMenue",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKillChat end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPKillChat = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_EnableAnimation",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKillenableFrame end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPKillenableFrame = value end,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildPvP_ColorAnimation",
				getFunc	 =function() return unpack(DsRGuildPvP.pvp.PvPKillframeColor) end,
				setFunc	 =function(r,g,b,a)
								DsRGuildPvP.pvp.PvPKillframeColor = {r, g, b, a}
								DSR_KillingBlowScreenFrameOverlay:SetEdgeColor(ZO_ColorDef:New(r, g, b, a):UnpackRGBA())
						   end,
				disabled =function() return not DsRGuildPvP.pvp.PvPKillenableFrame end,
			},
		-- }},
		-- {type="submenu",name="DsRGuildMenue_cyrodiilqueue",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyrodiilqueue",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilqueueenable",
				getFunc  = function() return DsRGuildPvP.pvp.enableQueueBar end,
				setFunc  = function(value) 
								DsRGuildPvP.pvp.enableQueueBar = value
								DsRGuildPvPscore.ScoreWindow_Update()
						   end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_statsBarLocked",
				getFunc  = function() return DsRGuildPvP.pvp.statsBarLocked end,
				setFunc  = function(value) 
								DsRGuildPvP.pvp.statsBarLocked = value
								DsRScoreWindow:SetMovable(not(DsRGuildPvP.pvp.statsBarLocked))
						   end,
				disabled = function() return not DsRGuildPvP.pvp.enableQueueBar end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_hideInPvE",
				getFunc  = function() return DsRGuildPvP.pvp.hideInPvE end,
				setFunc  = function(value) 
								DsRGuildPvP.pvp.hideInPvE = value
								DsRGuildPvPscore.ScoreWindow_Update()
						   end,
				disabled = function() return not DsRGuildPvP.pvp.enableQueueBar end
			},
			{	type		="slider",
				name		="DsRGuildMenue_scoreWindowScale",
				min			=-40,
				max			=40,
				step		=1,
				getFunc		=function() return DsRGuildPvP.pvp.scoreWindowScale end,
				setFunc		=function(value) 
								DsRGuildPvP.pvp.scoreWindowScale = value
								DsRGuildPvPscore.ScoreWindow_Scale()
							 end,
				disabled    = function() return not DsRGuildPvP.pvp.enableQueueBar end
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyrodiilCP",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilCPenable",
				getFunc  = function() return DsRGuildHallPvP_SV.uiEnabled end,
				setFunc  = function(value) 
								DsRGuildHallPvP_SV.uiEnabled = value
								DsR.UI.ReloadUIButton()
						   end,
				warning  = "ReloadUiWarn1",
			},			
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilCPUNK",
				getFunc  = function() return DsRGuildHallPvP_SV.UNKPlayer end,
				setFunc  = function(value) 
								DsRGuildHallPvP_SV.UNKPlayer = value
								DsRGuildPvPcountPlayer.UpdateUI()
						   end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilCPcompl",
				getFunc  = function() return DsRGuildHallPvP_SV.PlayerStatic end,
				setFunc  = function(value) 
								DsRGuildHallPvP_SV.PlayerStatic = value
								DsRGuildPvPcountPlayer.UpdateUI()
						   end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilCPdebug",
				getFunc  = function() return DsRGuildHallPvP_SV.uiUnknown end,
				setFunc  = function(value) 
								DsRGuildHallPvP_SV.uiUnknown = value
								DsR.UI.ReloadUIButton()
						   end,
				warning  = "ReloadUiWarn1",
				disabled = function() return not DsRGuildHallPvP_SV.uiEnabled end
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyrodiilCrown",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiilCrownPfeil",
				getFunc  = function() return DsRGuildPvP.pvp.PvPCrownEnabled end,
				setFunc  = function(value) 
								DsRGuildPvP.pvp.PvPCrownEnabled = value
								-- DsR.UI.ReloadUIButton()
						   end,
				-- warning  = "ReloadUiWarn1",
			},
			{	type		="slider",
				name		="DsRGuildMenue_cyrodiilCrownPfeilSize",
				min			=32,
				max			=128,
				step		=1,
				getFunc		=function() return DsRGuildPvP.pvp.PvPCrownArrowSize end,
				setFunc		=function(value) 
								DsRGuildPvP.pvp.PvPCrownArrowSize = value
    							if DsRGuildPvPCrown and DsRGuildPvPCrown.ui then
    							    DsRGuildPvPCrown.ui:SetDimensions(value, value)
    							end
							 end,
				disabled    = function() return not DsRGuildPvP.pvp.PvPCrownEnabled end,
			},
			{	type		="slider",
				name		="DsRGuildMenue_cyrodiilCrownPfeilPos",
				min			=-300,
				max			=300,
				step		=1,
				getFunc		=function() return DsRGuildPvP.pvp.PvPCrownArrowPos end,
				setFunc		=function(value) 
								DsRGuildPvP.pvp.PvPCrownArrowPos = value
    							if DsRGuildPvPCrown and DsRGuildPvPCrown.ui then
    							    DsRGuildPvPCrown.ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, value)
    							end
							 end,
				disabled    = function() return not DsRGuildPvP.pvp.PvPCrownEnabled end,
			},
			{
			    type     = "checkbox",
			    name     = "DsRGuildMenue_cyrodiilCrownList",
			    getFunc  = function() return DsRGuildPvP.pvp.PvPCrownList end,
			    setFunc  = function(value) DsRGuildPvP.pvp.PvPCrownList = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPCrownEnabled end,
			},
			{
			    type     = "checkbox",
			    name     = "Debug: Fake-Krone aktivieren",
			    getFunc  = function() return DsRGuildPvP.pvp.PvPCrownDebug end,
			    setFunc  = function(value) DsRGuildPvP.pvp.PvPCrownDebug = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPCrownEnabled end,
			},
		-- }},
		-- {type="submenu",name="DsRGuildPvP_alliancepointsmsg",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildPvP_alliancepointsmsg",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_alliancepoints",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAP end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAP = value end,
			},
			{	type	 ="editbox",
				name	 ="DsRGuildPvP_ap_gain",
				getFunc	 =function() return DsRGuildPvP.pvp.PvPAPvalue end,
				setFunc	 =function(text) DsRGuildPvP.pvp.PvPAPvalue = text end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_repair",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPrep end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPrep = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_kills",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPdeath end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPdeath = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_offensechat",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPoffenschat end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPoffenschat = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_offensescreen",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPoffensscreen end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPoffensscreen = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_defensechat",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPdeffenschat end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPdeffenschat = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_defensescreen",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPdeffensscreen end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPdeffensscreen = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_revival",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPressurect end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPressurect = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_awards",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPmedal end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPmedal = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_quest",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPquest end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPquest = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_battleground",
				getFunc  = function() return DsRGuildPvP.pvp.PvPAPmatch end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPAPmatch = value end,
				disabled = function() return not DsRGuildPvP.pvp.PvPAP end
			},
		-- }},
	}
	MenuPanel["MenuAllianceWarGeneral"]={name="IndexAllianceWarGeneral"}
	MenuHandlers["MenuAllianceWarGeneral"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 4.2 Allianzkrieg - Cyrodiil
-- -----------------------
	MenuOptions["MenuAllianceWarCyrodiil"]={
		-- {type="submenu",name="DsRGuildMenue_cyrodiilPortImp",controls={
			{	type		="subheader",
				name		="DsRGuildMenue_cyrodiilPortImp",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_portImperial",
				getFunc  = function() return DsRGuildPvP.pvp.PvPportImpOnOff end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPportImpOnOff = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_portImperialGroup",
				getFunc  = function() return DsRGuildPvP.pvp.PvPportImpGroup end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPportImpGroup = value end,
			},
		-- }},
		-- {type="submenu",name="DsRGuildMenue_cyrodiildoor",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyrodiildoor",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildMenue_cyrodiildoorOnOff",
				getFunc  = function() return DsRGuildPvP.pvp.PvPdoorOnOff end,
				setFunc  = function(value)
								DsRGuildPvP.pvp.PvPdoorOnOff = value 
								DsR.Menu.HandleReloadUIPressed()
						   end,
				warning  = "ReloadUiWarn2",
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildMenue_cyrodiildoorpintint",
				getFunc	 =function() return DsRMenu.GetRGBColor(DsRGuildPvP.pvp.PvPdoorPinRGB) end,
				setFunc	 =function(r,g,b,a)
								DsRGuildPvP.pvp.PvPdoorPinRGB = {["r"] = r, ["g"] = g, ["b"] = b}
								LMP:RefreshPins(DsR_PinsDoor)
								DsR.UI.ReloadUIButton()
						   end,
				disabled = function() return not DsRGuildPvP.pvp.PvPdoorOnOff end,
				warning  = "ReloadUiWarn",
			},
			{	type		="slider",
				name		="DsRGuildMenue_cyrodiildoorpintsize",
				min			=20,
				max			=70,
				step		=1,
				getFunc		=function() return DsRGuildPvP.pvp.PvPdoorPinSize end,
				setFunc		=function(value) 
								DsRGuildPvP.pvp.PvPdoorPinSize = value
								LMP:SetLayoutKey(DsR_PinsDoor, "size", value)
								LMP:RefreshPins(DsR_PinsDoor)
								DsR.UI.ReloadUIButton()
							 end,
				disabled    = function() return not DsRGuildPvP.pvp.PvPdoorOnOff end,
				warning     = "ReloadUiWarn",
			},
			{	type		="slider",
				name		="DsRGuildMenue_cyrodiildoorpintlayer",
				min			=1,
				max			=300,
				step		=5,
				getFunc		=function() return DsRGuildPvP.pvp.PvPdoorPinLevel end,
				setFunc		=function(value) 
								DsRGuildPvP.pvp.PvPdoorPinLevel = value
								LMP:SetLayoutKey(DsR_PinsDoor, "level", value)
								LMP:RefreshPins(DsR_PinsDoor)
								DsR.UI.ReloadUIButton()
							 end,
				disabled    = function() return not DsRGuildPvP.pvp.PvPdoorOnOff end,
				warning     = "ReloadUiWarn",
			},
		-- }},
		-- {type="submenu",name="DsRGuildMenue_cyroposition",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyroposition",
			},
			{
				type 	 = "checkbox",
				name 	 = "PvPKeepInfo_enabled",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKeepInfoOnOff end,
				setFunc  = function(value)
								DsRGuildPvP.pvp.PvPKeepInfoOnOff = value
								DsR.Menu.HandleReloadUIPressed()
						   end,
				warning  = "ReloadUiWarn2"
			},
			{	type		="slider",
				name		="PvPKeepInfo_updatetimer",
				decimals    =0,
				step        =0.5,
				min         =0.5,
				max         =10,
				default     =1,
				getFunc		=function() return DsRGuildPvP.pvp.PvPKeepInfoUpdate end,
				setFunc		=function(value) DsRGuildPvP.pvp.PvPKeepInfoUpdate = value end,
				disabled    =function() return DsRGuildPvP.pvp.PvPKeepInfoOnOff end,
			},
			{
				type 	 = "checkbox",
				name 	 = "PvPKeepInfo_showBGtransparent",
				getFunc  = function() return DsRGuildPvP.pvp.PvPKeepInfoBGtrans end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPKeepInfoBGtrans = value end,
				disabled = function() return DsRGuildPvP.pvp.PvPKeepInfoOnOff end,
			},
		-- }},
		-- {type="submenu",name="DsRGuildMenue_cyrowar",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_cyrowar",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_enabled",
				getFunc  = DsRMenu.GetCsEnabled,
				setFunc  = DsRMenu.SetCsEnabled,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_positionfixed",
				getFunc  = DsRMenu.GetCsPositionLocked,
				setFunc  = DsRMenu.SetCsPositionLocked,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showBGtransparent",
				getFunc  = function() return DsRGuildPvP.pvp.PvPstatusshowBackground end,
				setFunc  = function(val) DsRGuildPvP.pvp.PvPstatusshowBackground = val end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_hideworldmap",
				getFunc  = DsRMenu.GetCsHideOnWorldMap,
				setFunc  = DsRMenu.SetCsHideOnWorldMap,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showflags",
				getFunc  = DsRMenu.GetCsShowFlagsEnabled,
				setFunc  = DsRMenu.SetCsShowFlagsEnabled,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showsieges",
				getFunc  = DsRMenu.GetCsShowSiegesEnabled,
				setFunc  = DsRMenu.SetCsShowSiegesEnabled,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showownerchanges",
				getFunc  = DsRMenu.GetCsShowOwnerChangesEnabled,
				setFunc  = DsRMenu.SetCsShowOwnerChangesEnabled,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showactiontimers",
				getFunc  = DsRMenu.GetCsShowActionTimersEnabled,
				setFunc  = DsRMenu.SetCsShowActionTimersEnabled,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildPvPstatus_colordefault",
				getFunc	 =DsRMenu.GetCsDefaultColor,
				setFunc  =DsRMenu.SetCsDefaultColor,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildPvPstatus_colorcooldown",
				getFunc	 =DsRMenu.GetCsCooldownColor,
				setFunc  =DsRMenu.SetCsCooldownColor,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildPvPstatus_colorflipspositive",
				getFunc	 =DsRMenu.GetCsFlipsAtPositiveColor,
				setFunc  =DsRMenu.SetCsFlipsAtPositiveColor,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildPvPstatus_colorflipsnegative",
				getFunc	 =DsRMenu.GetCsFlipsAtNegativeColor,
				setFunc  =DsRMenu.SetCsFlipsAtNegativeColor,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showkeeps",
				getFunc  = DsRMenu.GetCsShowKeeps,
				setFunc  = DsRMenu.SetCsShowKeeps,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showoutposts",
				getFunc  = DsRMenu.GetCsShowOutposts,
				setFunc  = DsRMenu.SetCsShowOutposts,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showresources",
				getFunc  = DsRMenu.GetCsShowResources,
				setFunc  = DsRMenu.SetCsShowResources,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showvillages",
				getFunc  = DsRMenu.GetCsShowVillages,
				setFunc  = DsRMenu.SetCsShowVillages,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showtemples",
				getFunc  = DsRMenu.GetCsShowTemples,
				setFunc  = DsRMenu.SetCsShowTemples,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvPstatus_showdestructibles",
				getFunc  = DsRMenu.GetCsShowDestructibles,
				setFunc  = DsRMenu.SetCsShowDestructibles,
			},
		-- }},
	}
	MenuPanel["MenuAllianceWarCyrodiil"]={name="IndexAllianceWarCyrodiil"}
	MenuHandlers["MenuAllianceWarCyrodiil"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 4.3 Allianzkrieg - Imperial City
-- -----------------------
	MenuOptions["MenuAllianceWarImpCity"]={
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildMenue_ImperialCityDistrict",
			getFunc  = function() return DsRGuildPvP.pvp.PvPdoorImperial end,
			setFunc = function(value) 
				DsRGuildPvP.pvp.PvPdoorImperial = value
				if not value then
					local impData = DsRGuildPvPdoorPins_GetImperialData() 
					for _, data in ipairs(impData) do
						LMP:RemoveCustomPin(data.label)
					end
				end
				LMP:RefreshPins(DsR_PinsDoor)
				DsR.UI.ReloadUIButton()
			end,
			warning  = "ReloadUiWarn",
		},
		{	
			type		="checkbox",
			name		="DsRGuildMenue_ImperialCitySewers",
			getFunc		=function() return DsRGuildPvP.pvp.PvPICsewers end,
			setFunc		=function(value) DsRGuildPvP.pvp.PvPICsewers = value DsR.UI.ReloadUIButton() end,
			warning     = "ReloadUiWarn",
		},		
			-- {type="submenu",name="DsRGuildPvP_ap_telvarmsg",controls={
			{	
				type		="subheader",
				name		="DsRGuildPvP_ap_telvarmsg",
			},			
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_ap_telvar",
				getFunc  = function() return DsRGuildPvP.pvp.PvPTelVar end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPTelVar = value end,
			},
			{	type		="editbox",
				name		="DsRGuildPvP_ap_telvartxt",
				getFunc		=function() return DsRGuildPvP.pvp.PvPTelVartxt end,
				setFunc		=function(value) DsRGuildPvP.pvp.PvPTelVartxt = value end,
    			disabled    = function() return not DsRGuildPvP.pvp.PvPTelVar end,
			},
			{
				type 	 = "description",
				name     = "DsRGuildPvP_telVarSaverU49"
			},			
			{
				type 	 = "description",
				name     = "DsRGuildPvP_telVarSaverU49a"
			},
		-- }},
		-- {type="submenu",name="DsRPvPBossTimer_BossTimerMenue",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRPvPBossTimer_BossTimerMenue",
			},			
			{
				type    = "checkbox",
				name    = "DsRPvPBossTimer_OPTION_TIMETABLE",
				getFunc = function() return DsRGuildPvP.pvp.PvPtimetable end,
				setFunc = function(value)
							DsRGuildPvP.pvp.PvPtimetable = value
							if value == true then
								HUD_SCENE:AddFragment(DsRGuildPvPBossTimer.ui.timetable)
								HUD_UI_SCENE:AddFragment(DsRGuildPvPBossTimer.ui.timetable)
								DsRGuildPvPBossTimerTimeTable:SetHidden(false)
							else
								DsRGuildPvPBossTimerTimeTable:SetHidden(true)
								HUD_SCENE:RemoveFragment(DsRGuildPvPBossTimer.ui.timetable)
								HUD_UI_SCENE:RemoveFragment(DsRGuildPvPBossTimer.ui.timetable)
							end
						  end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRPvPBossTimer_OPTION_MAPTIMERS",
				getFunc  = function() return DsRGuildPvP.pvp.PvPmaptimers end,
				setFunc  = function(value) DsRGuildPvP.pvp.PvPmaptimers = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRPvPBossTimer_OPTION_EVENT_TIMERS",
				getFunc  = function() return DsRGuildPvP.pvp.PvPeventtimers end,
				setFunc  = function(value)
								DsRGuildPvP.pvp.PvPeventtimers = value
								DsRGuildPvPBossTimer.editSpawnTime()
						   end,
			},
			{
				type 	 = "description",
				name     = ""
			},
			{	
				type		="subheader",
				name		="DsRGuildPvP_GoldScamp",
			},			
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildPvP_GoldScampOnOff",
				getFunc  = function() return DsRGuildPvP.pvp.PvPScampImperial end,
				setFunc  = function(value)
								DsRGuildPvP.pvp.PvPScampImperial = value
								DsR.Menu.HandleReloadUIPressed()
						   end,
				warning  = "ReloadUiWarn2"
			},
		-- }},
	}
	MenuPanel["MenuAllianceWarImpCity"]={name="IndexAllianceWarImpCity"}
	MenuHandlers["MenuAllianceWarImpCity"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 5.1 Gruppe & Raids - Allgemein
-- -----------------------
	MenuOptions["MenuGroupRaid"]={
		-- {type="submenu",name="DsRGuildDeathTable_SubMenu",controls={
			{	type		="subheader",
				name		="DsRGuildDeathTable_SubMenu",
			},	
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildDeathTable_GroupJoin",
				getFunc  = function() return DsRAutoINV.cfg.ShowGroupJoin end,
				setFunc  = function(value) DsRAutoINV.cfg.ShowGroupJoin = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildDeathTable_GroupLeave",
				getFunc  = function() return DsRAutoINV.cfg.HideGroupLeave end,
				setFunc  = function(value) DsRAutoINV.cfg.HideGroupLeave = value end,
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildDeathTable_ResetTable",
				getFunc  = function() return DsRAutoINV.cfg.ResetTable end,
				setFunc  = function(value) DsRAutoINV.cfg.ResetTable = value end,
			},
			{	type		="slider",
				name		="DsRGuildDeathTable_bgAlpha",
				min			=0,
				max			=100,
				step		=1,
				getFunc		=function() return DsRAutoINV.cfg.DeathbgAlpha end,
				setFunc		=function(value) 
								DsRAutoINV.cfg.DeathbgAlpha = value
								DsRGuildDeathTable:SetAlpha()
							 end,
			},
			-- {	type		="subheader",
			-- 	name		="DsRGuildDeathTable_Color",
			-- },
			{	type	 ="colorpicker",
				name	 ="DsRGuildDeathTable_ColorTitle",
				getFunc = function()
					if DsRAutoINV.cfg.ColorTitle then
						return unpack(DsRAutoINV.cfg.ColorTitle)
					end
				end,
				setFunc = function(r, g, b, a)
					DsRAutoINV.cfg.ColorTitle = {r, g, b, a}
					DsRGuildDeathTable:SetColour()
				end,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildDeathTable_ColorPlayer",
				getFunc = function()
					if DsRAutoINV.cfg.ColorPlayer then
						return unpack(DsRAutoINV.cfg.ColorPlayer)
					end
				end,
				setFunc = function(r, g, b, a)
					DsRAutoINV.cfg.ColorPlayer = {r, g, b, a}
					DsRGuildDeathTable:SetColour()
				end,
			},
			{	type	 ="colorpicker",
				name	 ="DsRGuildDeathTable_ColorCount",
				getFunc = function()
					if DsRAutoINV.cfg.ColorCount then
						return unpack(DsRAutoINV.cfg.ColorCount)
					end
				end,
				setFunc = function(r, g, b, a)
					DsRAutoINV.cfg.ColorCount = {r, g, b, a}
					DsRGuildDeathTable:SetColour()
				end,
			},
			-- {	type		="subheader",
			-- 	name		="DsRGuildDeathTable_Lenght",
			-- },
			{
				type 	 = "description",
				name     = "DsRGuildDeathTable_LenghtDESC",
			},
			{
				type 	 = "description",
				name     = "DsRGuildDeathTable_LenghtDESC1",
			},
			{	type		="slider",
				name		="DsRGuildDeathTable_LenghtSlid",
				min			=4,
				max			=40,
				step 		=1,
				getFunc  = function()
					if DsRAutoINV.cfg.TableLenght then
						return DsRAutoINV.cfg.TableLenght
					end
				end,
				setFunc = function(newValue)
					DsRAutoINV.cfg.TableLenght = newValue
					loadTableToMem()
				end
			},
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_GroupAttack",
			},
			{
				type 	 = "description",
				name     = "DsRGuildGroupAttack_Desc1"
			},
			{
				type 	 = "description",
				name     = "DsRGuildGroupAttack_Desc2"
			},
			{	type		="slider",
				name		="DsRGuildGroupAttackTimer",
				min			=3,
				max			=10,
				step		=1,
				getFunc		=function() return DsRGuildPvP.pvp.PvPGroupAttackTime end,
				setFunc		=function(value) DsRGuildPvP.pvp.PvPGroupAttackTime = value end,
			},
		-- }},
		-- {type="submenu",name="DsRGuildMenue_TreasureFound",controls={
			{
				type 	 = "description",
				name     = ""
			},
			{	type		="subheader",
				name		="DsRGuildMenue_TreasureFound",
			},	
			{
				type 	 = "description",
				name     = "DsRGuildLootChest_Desc1",
			},
			{
				type 	 = "description",
				name     = "DsRGuildLootChest_Desc2",
			},
			{
				type 	 = "description",
				name     = "DsRGuildLootChest_Desc3",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLootChest_MenueOnOff",
				getFunc  = function() return DsRGuildLoot.sV.ChestFoundOnOff end,
				setFunc  = function(value) DsRGuildLoot.sV.ChestFoundOnOff = value DsR.UI.ReloadUIButton() end,
				warning  = "ReloadUiWarn1",
			},
			{
				type 	 = "checkbox",
				name 	 = "DsRGuildLootChest_OnlyEN",
				getFunc  = function() return DsRGuildLoot.sV.ChestFoundOnlyEN end,
				setFunc  = function(value) DsRGuildLoot.sV.ChestFoundOnlyEN = value end,
				disabled = function() return not DsRGuildLoot.sV.ChestFoundOnOff end,
			},
		-- }},
	}
	MenuPanel["MenuGroupRaid"]={name="IndexGroupRaid"}
	MenuHandlers["MenuGroupRaid"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 5.2 Gruppe & Raids - Buffs
-- -----------------------
	MenuOptions["MenuGroupBuff"]={
		{
			type 	 = "description",
			name     = "DsRGuildMenue_BuffsDesc",
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildMenue_BuffsEnable",
			getFunc  = function() return DsRGuildLoot.sV.DsRBuffEnable end,
			setFunc  = function(value)
				DsRGuildLoot.sV.DsRBuffEnable = value
				DsR.UI.ReloadUIButton()
			end,
			warning  = "ReloadUiWarn",
		},		
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildMenue_BuffsTxtOnOff",
			getFunc  = function() return DsRGuildLoot.sV.DsRBuffTxTonoff end,
			setFunc  = function(value)
				DsRGuildLoot.sV.DsRBuffTxTonoff = value
				DsRGuildBuffs.RefreshUI()
			end,
		},
		{	type		="slider",
			name		="DsRGuildMenue_BuffsTxtSize",
			step        =1,
			min         =12,
			max         =36,
			getFunc		=function() return DsRGuildLoot.sV.DsRBuffTXTsize end,
			setFunc		=function(value) DsRGuildLoot.sV.DsRBuffTXTsize = value end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsTxtCol",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffTXTcol then
					return unpack(DsRGuildLoot.sV.DsRBuffTXTcol)
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffTXTcol = {r, g, b, a}
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff end,
		},		
		{	type		="slider",
			name		="DsRGuildMenue_BuffsDDSSize",
			step        =1,
			min         =24,
			max         =128,
			getFunc		=function() return DsRGuildLoot.sV.DsRBuffDDSsize end,
			setFunc		=function(value) DsRGuildLoot.sV.DsRBuffDDSsize = value end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsTimerCol",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffTimercol then
					return unpack(DsRGuildLoot.sV.DsRBuffTimercol)
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffTimercol = {r, g, b, a}
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsCountCol",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffCountcol then
					return unpack(DsRGuildLoot.sV.DsRBuffCountcol)
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffCountcol = {r, g, b, a}
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable end,
		},
		{	type		="slider",
			name		="DsRGuildMenue_BuffsCountSiz",
			step        =1,
			min         =12,
			max         =64,
			getFunc		=function() return DsRGuildLoot.sV.DsRBuffCountsize end,
			setFunc		=function(value) DsRGuildLoot.sV.DsRBuffCountsize = value end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable end,
		},
		{
			type 	 = "description",
			name     = "",
		},		
		{
			type 	 = "description",
			name     = "",
		},
		{	type		="slider",
			name		="DsRGuildMenue_BuffsTableRowMax",
			step        =1,
			min         =10,
			max         =100,
			getFunc		=function() return DsRGuildLoot.sV.DsRBuff_CurrentRow end,
			setFunc		=function(value) DsRGuildLoot.sV.DsRBuff_CurrentRow = value DsRGuildBuffs.RefreshUI() end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarColor",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffBarColor then
					return unpack(DsRGuildLoot.sV.DsRBuffBarColor)
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffBarColor = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{
			type 	 = "description",
			name     = "",
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildMenue_BuffsBarMultiCol",
			getFunc  = function() return DsRGuildLoot.sV.DsRBuffMultiColor end,
			setFunc  = function(value)
				DsRGuildLoot.sV.DsRBuffMultiColor = value
				DsRGuildBuffs.RefreshUI()
			end,
		},

		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarShield",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["DamageShield"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["DamageShield"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},		
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarHeal",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["Heal"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["Heal"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarDamage",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["Damage"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["Damage"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarUlti",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["Ulti"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["Ulti"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarSelfBuff",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["SelfBuff"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["SelfBuff"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarGroupBuff",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["GroupBuff"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["GroupBuff"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarOtherBuff",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["OtherBuff"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["OtherBuff"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{	type	 ="colorpicker",
			name	 ="DsRGuildMenue_BuffsBarDefault",
			getFunc = function()
				if DsRGuildLoot.sV.DsRBuffMultiBuffColors then
					return unpack(DsRGuildLoot.sV.DsRBuffMultiBuffColors["Default"])
				end
			end,
			setFunc = function(r, g, b, a)
				DsRGuildLoot.sV.DsRBuffMultiBuffColors["Default"] = {r, g, b, a}
				DsRGuildBuffs.RefreshUI()
			end,
			disabled = function() return not DsRGuildLoot.sV.DsRBuffEnable or DsRGuildLoot.sV.DsRBuffTxTonoff or not DsRGuildLoot.sV.DsRBuffMultiColor end,
		},
		{
			type 	 = "description",
			name     = "",
		},
		{	type		="subheader",
			name		="DsRGuildMenue_BuffsSettingMenu",
		},	
		{
			type 	 = "description",
			name     = "DsRGuildMenue_BuffsSettingINFO",
		},
		{
			type 	 = "description",
			name     = "DsRGuildMenue_BuffsSettingINFO1",
		},
		{	type		="button",
			name		="DsRGuildMenue_BuffsSettingBUT",
			func		= function() DsRGuildBuffSetting:Show() end,
		},	
		{
			type 	 = "description",
			name     = "",
		},
		{	type		="subheader",
			name		="DsRGuildMenue_BuffsSelectMenu",
		},	
		{
			type 	 = "description",
			name     = "DsRGuildMenue_BuffsIDinfo",
		},
		{	type		="button",
			name		="DsRGuildMenue_BuffsIDAnalyse",
			func		= function() DsRGuildBuffAnalyse:ShowAnalyseWindow() end,
		},	
	}
	MenuPanel["MenuGroupBuff"]={name="IndexGroupBuff"}
	MenuHandlers["MenuGroupBuff"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 6. Errungenschaftsverfolgung
-- -----------------------
	MenuOptions["MenuAchievTrack"]={
		{
			type 	 = "description",
			name     = "DsRGuildAchievTracker_Desc1"
		},
		{
			type 	 = "description",
			name     = "DsRGuildAchievTracker_Desc2"
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildAchievTracker_OnOff",
			getFunc  = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
			setFunc  = function(value)
							DsRGuildAchievTracker.config.AchievTrackOnOff = value
							DsR.Menu.HandleReloadUIPressed()
					   end,
			warning  = "ReloadUiWarn2",
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildAchievTracker_Lock",
			getFunc  = function() return DsRGuildAchievTracker.config.locked end,
			setFunc  = function(value) 
							DsRGuildAchievTracker.config.locked = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
					   end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildAchievTracker_ShowIcons",
			getFunc  = function() return DsRGuildAchievTracker.config.showIcons end,
			setFunc  = function(value) 
							DsRGuildAchievTracker.config.showIcons = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
					   end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildAchievTracker_Show_Desc",
			getFunc  = function() return DsRGuildAchievTracker.config.showDesc end,
			setFunc  = function(value) 
							DsRGuildAchievTracker.config.showDesc = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
					   end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildAchievTracker_hideOldZoneAchievements",
			getFunc  = function() return DsRGuildAchievTracker.config.hideOldZoneAchievements end,
			setFunc  = function(value) 
							DsRGuildAchievTracker.config.hideOldZoneAchievements = value
							-- DsRGuildAchievTracker.lastZone = nil
							DsRGuildAchievTracker:LoadTrackedAchievements()
					   end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{
			type 	 = "slider",
			name 	 = "DsRGuildAchievTracker_maxTracked",
			min			=0,
			max			=20,
			step		=1,
			getFunc  = function() return DsRGuildAchievTracker.config.maxTracked end,
			setFunc  = function(value) 
							DsRGuildAchievTracker.config.maxTracked = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
					   end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{	type		="slider",
			name		="DsRGuildAchievTracker_fontSizeName",
			min			=8,
			max			=30,
			step		=1,
			getFunc		=function() return DsRGuildAchievTracker.config.fontSizename end,
			setFunc		=function(value) 
							DsRGuildAchievTracker.config.fontSizename = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
						 end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
		{	type		="slider",
			name		="DsRGuildAchievTracker_fontSize_Desc",
			min			=8,
			max			=30,
			step		=1,
			getFunc		=function() return DsRGuildAchievTracker.config.fontSizedesc end,
			setFunc		=function(value) 
							DsRGuildAchievTracker.config.fontSizedesc = value
							DsRGuildAchievTracker:LoadTrackedAchievements()
						 end,
			disabled = function() return DsRGuildAchievTracker.config.AchievTrackOnOff end,
		},
	}
	MenuPanel["MenuAchievTrack"]={name="IndexAchievTrack"}
	MenuHandlers["MenuAchievTrack"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}

-- -----------------------
-- 7. Handwerk
-- -----------------------
	MenuOptions["MenuCrafting"]={
		{
			type = "subheader",
			name = "DsRGuildCrafting_DailyHeader"
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildCrafting_Alchemy",
			getFunc  = function() return DsRGuildLoot.sV.DsRDailyCraftAlchemy end,
			setFunc  = function(value) DsRGuildLoot.sV.DsRDailyCraftAlchemy = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildCrafting_Provision",
			getFunc  = function() return DsRGuildLoot.sV.DsRDailyCraftProvision end,
			setFunc  = function(value) DsRGuildLoot.sV.DsRDailyCraftProvision = value end,
		},
		{
			type 	 = "description",
			name     = ""
		},
		{
			type = "subheader",
			name = "DsRGuildCrafting_PrecraftHeader"
		},
		{
			type 	 = "description",
			name     = "DsRGuildCrafting_Precraft_DESC1"
		},
		{
			type 	 = "description",
			name     = "DsRGuildCrafting_Precraft_DESC2"
		},
		{
			type 	 = "description",
			name     = "DsRGuildCrafting_Precraft_DESC3"
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_exp_blacksmithing",
			getFunc  = function() return DsRGuildLoot.sV.PreCraftProfessions[1] end,
			setFunc  = function(value) DsRGuildLoot.sV.PreCraftProfessions[1] = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_exp_clothier",
			getFunc  = function() return DsRGuildLoot.sV.PreCraftProfessions[2] end,
			setFunc  = function(value) DsRGuildLoot.sV.PreCraftProfessions[2] = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_exp_woodworking",
			getFunc  = function() return DsRGuildLoot.sV.PreCraftProfessions[3] end,
			setFunc  = function(value) DsRGuildLoot.sV.PreCraftProfessions[3] = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_exp_jewelrymaking",
			getFunc  = function() return DsRGuildLoot.sV.PreCraftProfessions[6] end,
			setFunc  = function(value) DsRGuildLoot.sV.PreCraftProfessions[6] = value end,
		},
		{
			type 	 = "checkbox",
			name 	 = "DsRGuildLoot_exp_enchanting",
			getFunc  = function() return DsRGuildLoot.sV.PreCraftProfessions[7] end,
			setFunc  = function(value) DsRGuildLoot.sV.PreCraftProfessions[7] = value end,
		},
	}
	MenuPanel["MenuCrafting"]={name="IndexCrafting"}
	MenuHandlers["MenuCrafting"]={
		["OnEffectivelyHidden"]=function() DsR.init.inMenu=false end,
	}
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.WelcomeGuild()
    local GuildCount     = GetNumGuilds()
	local index          = 0
	local SettingsTEMP   = {}
	
	if GuildCount == 0 then
		table.insert(SettingsTEMP, {type="attention",name="DsRGuildUnknown_WelcomeNoGuild"})
	end


	for i = 1, GuildCount do
		local gId       = GetGuildId(i)
		local GuildName = GetGuildName(gId)
		if i == 1 then
            table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildUnknown_WelcomeGenOnOff",
										getFunc=function() return DsRAutoINV.cfg.welcomeOnOff end,
                             			setFunc=function(value) DsRAutoINV.cfg.welcomeOnOff = value end,})
			table.insert(SettingsTEMP, {type="attention",name="DsRGuildUnknown_WelcomeMemberName"})
		end
        table.insert(SettingsTEMP, {type="checkbox",name="|c9fb6cd" .. DsRAutoINV.cfg.GuildNames[gId] .. "|r",warning=false,
									getFunc=function() return DsRAutoINV.cfg.welcome[i] end,
									setFunc=function(value) DsRAutoINV.cfg.welcome[i] = value end,
									default=DsRAutoINV.cfg.welcome[i],
									disabled=function() return not DsRAutoINV.cfg.welcomeOnOff end,})
		table.insert(SettingsTEMP, {type="editboxMulti",name="DsRGuildUnknown_WelcomeTXT",warning=false,
									getFunc=function() return DsRAutoINV.cfg.message[i] end,
									setFunc=function(text) DsRAutoINV.cfg.message[i] = text end,
									default=DsRAutoINV.cfg.message[i],
									disabled=function() return not DsRAutoINV.cfg.welcomeOnOff end,})
	end

	return 	SettingsTEMP[1],  SettingsTEMP[2],  SettingsTEMP[3], SettingsTEMP[4], SettingsTEMP[5], SettingsTEMP[6], SettingsTEMP[7], SettingsTEMP[8], SettingsTEMP[9], SettingsTEMP[10],
			SettingsTEMP[11], SettingsTEMP[12], SettingsTEMP[13]
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.LootHistory()
	local index 		= 0
	local SettingsTEMP  = {}

	table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildLootHistory_MenueOnOff",warning="ReloadUiWarn1",
								getFunc=function() return DsRGuildLoot.sV.HistoryOnOff end,
								setFunc=function(value) DsRGuildLoot.sV.HistoryOnOff = value end,})
	table.insert(SettingsTEMP, {type="slider",name="DsRGuildLootHistory_NLootMS",warning=false,
								getFunc=function() return DsRGuildLoot.sV.HistoryContainerShowTime end,
								setFunc=function(value) DsRGuildLoot.sV.HistoryContainerShowTime = value DsRGuildLootHistory.UpdateContainerShowTime() end,
								min=1,max=20,step=1,
								disabled=function() return DsRGuildLoot.sV.HistoryOnOff end,})
	table.insert(SettingsTEMP, {type="slider",name="DsRGuildLootHistory_MaxItem",warning=false,
								getFunc=function() return DsRGuildLoot.sV.HistoryMaxItems end,
								setFunc=function(value) DsRGuildLoot.sV.HistoryMaxItems = value DsRGuildLootHistory.UpdateMaxEntries() end,
								min=2,max=20,step=1,
								disabled=function() return DsRGuildLoot.sV.HistoryOnOff end,})
	table.insert(SettingsTEMP, {type="checkbox",name="DsRGuildLootHistory_ShowMenue",warning=false,
								getFunc=function() return DsRGuildLoot.sV.HistoryShowInMenus end,
								setFunc=function(value) DsRGuildLoot.sV.HistoryShowInMenus = value end,DsRGuildLootHistory.UpdateLootHistoryDisplayInMenus(),
								disabled=function() return DsRGuildLoot.sV.HistoryOnOff end,})
	table.insert(SettingsTEMP, {type="description",name="DsRGuildLootHistory_ShowSkill",})

	for skillIndex, _ in pairs(DsRGuildLoot.sV.HistoryShowType) do
		local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_WORLD, skillIndex)
		table.insert(SettingsTEMP, {type="checkbox",name=skillLineData:GetFormattedName(),warning=false,
									getFunc=function() return DsRGuildLoot.sV.HistoryShowType[skillIndex] end,
									setFunc=function(value) DsRGuildLoot.sV.HistoryShowType[skillIndex] = value end,
									disabled=function() return DsRGuildLoot.sV.HistoryOnOff end,})
	end

	return 	SettingsTEMP[1],  SettingsTEMP[2],  SettingsTEMP[3],  SettingsTEMP[4],  SettingsTEMP[5],  SettingsTEMP[6],  SettingsTEMP[7],  SettingsTEMP[8],  SettingsTEMP[9],  SettingsTEMP[10],
			SettingsTEMP[11], SettingsTEMP[12], SettingsTEMP[13], SettingsTEMP[14], SettingsTEMP[15], SettingsTEMP[16], SettingsTEMP[17], SettingsTEMP[18], SettingsTEMP[19], SettingsTEMP[20],
			SettingsTEMP[21], SettingsTEMP[22], SettingsTEMP[23], SettingsTEMP[24], SettingsTEMP[25], SettingsTEMP[26], SettingsTEMP[27], SettingsTEMP[28], SettingsTEMP[29], SettingsTEMP[30]
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.Initialize()
	if DsR.init.Menu then return true end
	local AdvancedMenu=true
	--Setup the menu
	MenuOptions_Init()
	for index,data in pairs(MenuOptions) do
		local Options={}
		for i=1, #data do
			if not data[i].advanced or AdvancedMenu then
				if data[i].type=="submenu" then
					local controls={}
					for j=1, #data[i].controls do
						if (not data[i].controls[j].advanced or AdvancedMenu) and (not data[i].controls[j].curved or(data[i].controls[j].curved and DsR.Vars.CurvedFrame~="Disabled")) then
							table.insert(controls, data[i].controls[j])
						end
					end
					table.insert(Options, {["type"]="submenu",["name"]=data[i].name,["controls"]=controls})
				else
					table.insert(Options, data[i])
				end
			end
		end
		MenuPanel[index].name=MenuNumber[index].."|t32:32:"..MenuIcon[index].."|t"..DsR.Loc(MenuPanel[index].name)
		DsR.Menu.RegisterPanel("DsR_"..index, MenuPanel[index])
		if MenuHandlers[index] then for event,handler in pairs(MenuHandlers[index]) do _G["DsR_"..index]:SetHandler(event, handler) end end
		DsR.Menu.RegisterOptions("DsR_"..index, Options)
	end
	DsR.init.Menu=true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Function
-------------------------------------------------------------------------------------------------------------------------------------------------

function DsRMenu.GetCsEnabled()
	return DsRGuildPvP.pvp.PvPstatusenabled
end

function DsRMenu.SetCsEnabled(value)
	DsRGuildPvPstatus.SetEnabled(value)
end

function DsRMenu.GetCsPositionLocked()
	return DsRGuildPvP.pvp.PvPstatuspositionLocked
end

function DsRMenu.SetCsPositionLocked(value)
	DsRGuildPvPstatus.SetPositionLocked(value)
end

function DsRMenu.GetCsHideOnWorldMap()
	return DsRGuildPvP.pvp.PvPstatushideOnWorldMap
end

function DsRMenu.SetCsHideOnWorldMap(value)
	DsRGuildPvP.pvp.PvPstatushideOnWorldMap = value
end

function DsRMenu.GetCsShowFlagsEnabled()
	return DsRGuildPvP.pvp.PvPstatusshowFlags
end

function DsRMenu.SetCsShowFlagsEnabled(value)
	DsRGuildPvP.pvp.PvPstatusshowFlags = value
	DsRGuildPvPstatus.AdjustDisplayedComponents()
end

function DsRMenu.GetCsShowSiegesEnabled()
	return DsRGuildPvP.pvp.PvPstatusshowSieges
end

function DsRMenu.SetCsShowSiegesEnabled(value)
	DsRGuildPvP.pvp.PvPstatusshowSieges = value
	DsRGuildPvPstatus.AdjustDisplayedComponents()
end

function DsRMenu.GetCsShowOwnerChangesEnabled()
	return DsRGuildPvP.pvp.PvPstatusshowOwnerChanges
end

function DsRMenu.SetCsShowOwnerChangesEnabled(value)
	DsRGuildPvP.pvp.PvPstatusshowOwnerChanges = value
	DsRGuildPvPstatus.AdjustDisplayedComponents()
end

function DsRMenu.GetCsShowActionTimersEnabled()
	return DsRGuildPvP.pvp.PvPstatusshowActionTimers
end

function DsRMenu.SetCsShowActionTimersEnabled(value)
	DsRGuildPvP.pvp.PvPstatusshowActionTimers = value
	DsRGuildPvPstatus.AdjustDisplayedComponents()
end

function DsRMenu.GetCsDefaultColor()
	return DsRMenu.GetRGBColor(DsRGuildPvP.pvp.PvPstatusdefaultColor)
end

function DsRMenu.SetCsDefaultColor(r, g, b)
	DsRGuildPvP.pvp.PvPstatusdefaultColor = DsRMenu.GetColorFromRGB(r, g, b)
end

function DsRMenu.GetCsCooldownColor()
	return DsRMenu.GetRGBColor(DsRGuildPvP.pvp.PvPstatuscooldownColor)
end

function DsRMenu.SetCsCooldownColor(r, g, b)
	DsRGuildPvP.pvp.PvPstatuscooldownColor = DsRMenu.GetColorFromRGB(r, g, b)
end

function DsRMenu.GetCsFlipsAtPositiveColor()
	return DsRMenu.GetRGBColor(DsRGuildPvP.pvp.PvPstatusflipsAtPositiveColor)
end

function DsRMenu.SetCsFlipsAtPositiveColor(r, g, b)
	DsRGuildPvP.pvp.PvPstatusflipsAtPositiveColor = DsRMenu.GetColorFromRGB(r, g, b)
end

function DsRMenu.GetCsFlipsAtNegativeColor()
	return DsRMenu.GetRGBColor(DsRGuildPvP.pvp.PvPstatusflipsAtNegativeColor)
end

function DsRMenu.SetCsFlipsAtNegativeColor(r, g, b)
	DsRGuildPvP.pvp.PvPstatusflipsAtNegativeColor = DsRMenu.GetColorFromRGB(r, g, b)
end

function DsRMenu.GetCsShowKeeps()
	return DsRGuildPvP.pvp.PvPstatusshowKeeps
end

function DsRMenu.SetCsShowKeeps(value)
	DsRGuildPvP.pvp.PvPstatusshowKeeps = value
end

function DsRMenu.GetCsShowOutposts()
	return DsRGuildPvP.pvp.PvPstatusshowOutposts
end

function DsRMenu.SetCsShowOutposts(value)
	DsRGuildPvP.pvp.PvPstatusshowOutposts = value
end

function DsRMenu.GetCsShowResources()
	return DsRGuildPvP.pvp.PvPstatusshowResources
end

function DsRMenu.SetCsShowResources(value)
	DsRGuildPvP.pvp.PvPstatusshowResources = value
end

function DsRMenu.GetCsShowVillages()
	return DsRGuildPvP.pvp.PvPstatusshowVillages
end

function DsRMenu.SetCsShowVillages(value)
	DsRGuildPvP.pvp.PvPstatusshowVillages = value
end

function DsRMenu.GetCsShowTemples()
	return DsRGuildPvP.pvp.PvPstatusshowTemples
end

function DsRMenu.SetCsShowTemples(value)
	DsRGuildPvP.pvp.PvPstatusshowTemples = value
end

function DsRMenu.GetCsShowDestructibles()
	return DsRGuildPvP.pvp.PvPstatusshowDestructibles
end

function DsRMenu.SetCsShowDestructibles(value)
	DsRGuildPvP.pvp.PvPstatusshowDestructibles = value
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Color function
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRMenu.GetRGBColor(color)
	return color.r, color.g, color.b
end

function DsRMenu.GetRGBAColor(color)
	return color.r, color.g, color.b, color.a
end

function DsRMenu.GetColorFromRGB(r, g, b)
	return {["r"] = r, ["g"] = g, ["b"] = b}
end

function DsRMenu.GetColorFromRGBA(r, g, b, a)
	return {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
end
