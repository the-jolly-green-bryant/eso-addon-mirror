--*********************************************************************
-- Initialisation des variables
--*********************************************************************
ODT = 
{
    ["chanbuffer"] = {},
}


local ODT = ODT

local MainSettings=ODTMainSettings

currentInteractableName = "nil"

ODTAddon = WINDOW_MANAGER:CreateControl(nil, GuiRoot)
ODT.addonName = "ODT"
ODT.version = "version 2.70"
ODT.Author = "@blackdragon06"
ODT_Combox_State = 2

ODT_GUILD1_NAME = ""
ODT_GUILD2_NAME = ""
ODT_GUILD3_NAME = ""
ODT_GUILD4_NAME = ""
ODT_GUILD5_NAME = ""

ODTDebug = 0

ODT_HideCombat_GLOBAL = false
ODT_HideCombat_BG = false
ODT_HideCombat_CLOCK = false
ODT_HideCombat_CHRONO = false
ODT_HideCombat_TIMER = false
ODT_HideCombat_PERF = false
ODT_HideCombat_INVENTORY = false
ODT_HideCombat_STATS = false
ODT_HideCombat_HORSE = false
ODT_HideCombat_STOLEN = false

ODT_ShowClock = true
ODT_ShowClockFontSize = 16
ODT_ShowClockFontColor = "|c04D631Vert"

ODT_ShowChrono = true
ODT_ShowChronoFontSize = 16
ODT_ShowChronoFontColor = "|c04D631Vert"
ODT_Chrono_ONOFF = "ON"

ODT_ShowTimer = true
ODT_ShowTimerFontSize = 16
ODT_ShowTimerFontColor = "|c04D631Vert"
ODT_Timer_ONOFF = "ON"
ODT_Timer_Seconds = 10
ODT_Timer_SOUND = 0

ODT_ShowBag = true
ODT_ShowBag_ONOFF = "ON"

ODT_ShowPERF = true

ODT_ShowFOOD = true
ODT_ShowFOOD_TIME = 1
ODT_ShowFOOD_SOUND = 0
ODT_ShowFOOD_POPDURATION = 8
ODT_ShowFOOD_CHECKONLOAD = 1
ODT_ShowFoodMsg = 1
ODT_FoodTime = 60
EventODT_FoodTime = 60
ODT_isFoodActive = false

ODT_ShowXPSCROLL = true
ODT_ShowXPSCROLLMsg = 1
ODT_ShowXPSCROLL_POPDURATION = 8
ODT_ShowXPSCROLL_SOUND = 0

ODT_HORSE = true
ODT_HORSE_SHOWBG = true
ODT_HORSE_SHOWPERMA = true
ODT_HORSE_SHOWTIME = 1
ODT_HORSE_SOUND = 0
ODT_HORSE_CHECKONLOAD = true
ODT_HORSE_CHECKONLOAD_MSG = true

ODT_MailRTS_ONOFF = true
ODT_MailRTS_SOUND1 = 0
ODT_MailRTS_SOUND2 = 0

ODT_WA_ONOFF = true
ODT_WABG = false
ODT_WA_SOUND_ARMOR = 0
ODT_WA_SOUND_WEAPON = 0
ODT_WA_WTX = true
ODT_WA_ATX = true
ODT_WA_Recharge = true
ODT_ShowMsgWeaponCharge1 = 1
ODT_ShowMsgWeaponCharge2 = 1
ODT_ShowMsgWeaponCharge3 = 1
ODT_ShowMsgWeaponCharge4 = 1
ODT_ShowMsgArmorBrocked = 1

ODT_GM1 = true
ODT_GM2 = true
ODT_GM3 = true
ODT_GM4 = true
ODT_GM5 = true
ODT_GuildName = true
ODT_GMCharacterName = true
ODT_GMAlliance = true
ODT_GMSound = 0
ODT_GMNotif = true
ODT_GMHeure = true

ODT_Notif_Say = 0
ODT_Notif_Yell = 0
ODT_Notif_Tell = 16
ODT_Notif_Party = 0
ODT_Notif_Z = 0
ODT_Notif_ZEN = 0
ODT_Notif_ZFR = 0
ODT_Notif_ZDE = 0
ODT_Notif_G1 = 0
ODT_Notif_G2 = 0
ODT_Notif_G3 = 0
ODT_Notif_G4 = 0
ODT_Notif_G5 = 0
ODT_Notif_G1OFF = 0
ODT_Notif_G2OFF = 0
ODT_Notif_G3OFF = 0
ODT_Notif_G4OFF = 0
ODT_Notif_G5OFF = 0

ODT_CustomChatPermachanged = false
ODT_CustomChatPerma = false
ODT_CustomChatDate = true
ODT_CustomChatTime = true
ODT_CustomChatChan = true
ODT_CustomChatAccount = true
ODT_CustomChatPersoInfos = true
ODT_CustomChatName = true
ODT_CustomChatAlliance = true
ODT_CustomChatClasse = true
ODT_CustomChatLvl = true

ODT_Fish = true

ODT_CharacterName = ""
ODT_CharacterAlliance = ""

ODT_BG_Show = true
ODT_BGX = 240
ODT_BGY = 80

ODT_ShowDeath = true
ODT_ShowDeathMsg = true
ODT_ShowDeathChat = true
ODT_ShowDeathList = true
ODT_ShowDeathRez = true
ODT_ShowDeathSnd = 0
MemodtMsg = ""
ODTStillDead01=0
ODTStillDead02=0
ODTStillDead03=0
ODTStillDead04=0
ODTStillDead05=0
ODTStillDead06=0
ODTStillDead07=0
ODTStillDead08=0
ODTStillDead09=0
ODTStillDead10=0
ODTStillDead11=0
ODTStillDead12=0

ODTStillRez01=0
ODTStillRez02=0
ODTStillRez03=0
ODTStillRez04=0
ODTStillRez05=0
ODTStillRez06=0
ODTStillRez07=0
ODTStillRez08=0
ODTStillRez09=0
ODTStillRez10=0
ODTStillRez11=0
ODTStillRez12=0

ODTIsRez01=0
ODTIsRez02=0
ODTIsRez03=0
ODTIsRez04=0
ODTIsRez05=0
ODTIsRez06=0
ODTIsRez07=0
ODTIsRez08=0
ODTIsRez09=0
ODTIsRez10=0
ODTIsRez11=0
ODTIsRez12=0

ODT_LOCKWINDOWS = false

ODT_SettinsLoaded = 0

ODT_OPTION_SHOW_SET_BUTTONS = 2

ODT_itemIcon = ""
ODT_itemIcon11 = ""
ODT_itemIcon12 = ""
ODT_itemIcon21 = ""
ODT_itemIcon22 = ""
ODT_itemCharge = 0

ODT_sleepTime = 2000

ODT_ShowStolen = true
ODT_ShowStolenBG = true 
StolenDayAmount = 0
StolenMoney = 0

ODT_MapX = 0
ODT_MapY = 0

local showStartMessage = true
local ShowTest =""
local ODT_Pledges = ""
local ODT_PledgesX = ""
local ODT_PledgesA = ""
local ODT_PledgesB = ""
local ODT_PledgesC = ""
local ODT_GuildMemberInfo = ""

isODTMember = false

ODT_BugEaterLoaded = 0

ODTguildId =0
ODTMsgGuildLoad = 0
ODT_ChkBox01_isChecked = true

local d = d
local strjoin = zo_strjoin
local strsplit = zo_strsplit
local GetNumActionLayers = GetNumActionLayers
local GetActionLayerInfo = GetActionLayerInfo
local GetActionLayerCategoryInfo = GetActionLayerCategoryInfo
local GetActionInfo = GetActionInfo
local GetActionIndicesFromName = GetActionIndicesFromName
local showStartMessage = true

-- Panel for quick access
local addOnPanel = {}
autoSets = {}

------------------------------------------------------------
-- Couleurs du menu Settings
------------------------------------------------------------
local defaults = {
	miscColorCodes = {
		SettingRed =		ZO_ColorDef:New("ff0000"),
		SettingBlue =		ZO_ColorDef:New("6699ff"),
		SettingGreen =		ZO_ColorDef:New("99ff66"),
		SettingIce =		ZO_ColorDef:New("CCFFFF"),
		SettingOrange =		ZO_ColorDef:New("ff7b39"),
		SettingYellow =		ZO_ColorDef:New("ffff0d"),
		SettingGray = 		ZO_ColorDef:New("4f4f4f"),
		SettingSAY = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_SAY)),
		SettingYELL = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_YELL)),
		SettingWHISPIN = 	ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_WHISPER_INCOMING)),
		SettingWHISPOUT = 	ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_WHISPER_OUTGOING)),
		SettingPARTY = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_PARTY)),
		SettingZ = 			ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_ZONE)),
		SettingZEN = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_ZONE_ENGLISH)),
		SettingZFR = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_ZONE_FRENCH)),
		SettingZDE = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_ZONE_GERMAN)),
		SettingG1 = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_1)),
		SettingG2 = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_2)),
		SettingG3 = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_3)),
		SettingG4 = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_4)),
		SettingG5 = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_5)),
		SettingG1OFF = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_1)),
		SettingG2OFF = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_2)),
		SettingG3OFF = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_3)),
		SettingG4OFF = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_4)),
		SettingG5OFF = 		ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_5)),

	}
}

--*********************************************************************
--Librairies
--*********************************************************************
local LAM2, LN

--local ODTCHATLC = LibStub("libChat-1.0")
local ODTCHATLC = LibChatMessage

--*********************************************************************
-- Fonction Print
--*********************************************************************
local function print(...)
    d(strjoin("", ...))
end

--*********************************************************************
-- Bouton dans la boite de dialogue
--*********************************************************************
function ODT.isShowSetButtons()
	return ODT.account.option[ODT_OPTION_SHOW_SET_BUTTONS]
end

function ODT.setShowSetButtons(value)
	ODT.account.option[ODT_OPTION_SHOW_SET_BUTTONS] = value
	ODT.setupSetButtons()
end

--*********************************************************************
-- Events mouse en XML Menu
-- Enter|Exit|Clicked|Up|Shift+Click
--*********************************************************************
local function ClearChat()
	CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
end

local function ODT_Reload(control, option) 
	if option == 11 then
		if IsShiftKeyDown() == false then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			if ODT_GuildRank < 5 then
				ODT_Btn_Tooltip = GetString(btnchan_officers)
			else
				ODT_Btn_Tooltip = GetString(btnchan)
			end
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif IsShiftKeyDown() == true then
		end
	elseif option == 12 or option == 22 or option == 32 or option == 42 or option == 52 or option == 62 or option == 72 or option == 82 or option == 92 or option == 102 or option == 302 or option == 304 or option == 306 or option == 308 then
		ClearTooltip(InformationTooltip)
		ODT_BAG_INVENTORY_NUMBERS:SetHidden(true)
		ODT_BAG_LOCKED_NUMBERS:SetHidden(true)
		ODT_BAG_STOLEN_NUMBERS:SetHidden(true)
	elseif option == 13 then
		if IsShiftKeyDown() == true then
			
			------------------------------------------------------------
			-- affiche la fenetre de la liste des commmandes
			------------------------------------------------------------
			if ODT_Combox_State == 1 then
				ODT_:SetHidden(true)
				ODT_Combox_State = 2
			elseif ODT_Combox_State ==2 then
				ODT_:SetHidden(false)
				ODT_Combox_State = 1
			end
		elseif IsShiftKeyDown() == false then
			ODT_SlashCommand("pledges -c")
		end
		elseif option == 21 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_Btn_Tooltip = GetString(btnexecute)
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 31 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_Btn_Tooltip = GetString(btnexecuteoptions)
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 41 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_Btn_Tooltip = GetString(closewindow)
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 51 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_Btn_Tooltip = btnraz
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 61 then
			if ODT_Chrono_ONOFF == "OFF" then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(chrono_start)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
			end
		elseif option == 65 then
			if ODT_Timer_ONOFF == "OFF" then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(timer_start)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
			end
		elseif option == 71 then
			if ODT_Chrono_ONOFF == "ON" then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(chrono_stop)

				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
			end
		elseif option == 75 then
			if ODT_Timer_ONOFF == "ON" then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(timer_stop)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
			end
		elseif option == 81 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, SHOW_BAG_INVENTORY_NUMBERS)
		elseif option == 91 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, SHOW_BAG_STOLEN_NUMBERS)
		elseif option == 101 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, SHOW_BAG_LOCKED_NUMBERS)
		elseif option == 105 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				SetTooltipText(InformationTooltip, SHOW_BANSPACE)
		elseif option == 111 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btnerase)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 121 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btninserthouseicon)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 131 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btninsertraidicon)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 141 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btninsertpvpicon)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 151 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btninsertbdgicon)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 161 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btninsertsign)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 171 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|cf81e1eRouge"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 172 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|c94DE23Vert"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 173 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|c000cffBleu"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 174 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|c00fffaCyan"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 175 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|cff00d0Magenta"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 176 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|cff9000Orange"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 177 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "|cffe100Jaune"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 180 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btnloadsave)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 190 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(btnsend)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 301 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_WA_WEAPON11_IMG_Tooltip = ODT_ItemLink11
			SetTooltipText(InformationTooltip, ODT_WA_WEAPON11_IMG_Tooltip)
		elseif option == 303 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_WA_WEAPON12_IMG_Tooltip = ODT_ItemLink12
			SetTooltipText(InformationTooltip, ODT_WA_WEAPON12_IMG_Tooltip)
		elseif option == 305 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_WA_WEAPON21_IMG_Tooltip = ODT_ItemLink21
			SetTooltipText(InformationTooltip, ODT_WA_WEAPON21_IMG_Tooltip)
		elseif option == 307 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_WA_WEAPON22_IMG_Tooltip = ODT_ItemLink22
			SetTooltipText(InformationTooltip, ODT_WA_WEAPON22_IMG_Tooltip)
		elseif option == 309 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_MSG_FOOD_ICON_Tooltip = GetString(closewindow)
				SetTooltipText(InformationTooltip, ODT_MSG_FOOD_ICON_Tooltip)
		elseif option == 319 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_MSG_HORSE_ICON_Tooltip = GetString(closewindow)
				SetTooltipText(InformationTooltip, ODT_MSG_HORSE_ICON_Tooltip)
		elseif option == 329 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_MSG_XPSCROLL_CLOSE_Tooltip = GetString(closewindow)
				SetTooltipText(InformationTooltip, ODT_MSG_XPSCROLL_CLOSE_Tooltip)
		elseif option == 401 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(savecolors)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 402 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = GetString(loadcolors)
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 403 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "Sauvegarde des commandes - prévu pour une version ultérieure"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 404 then
				InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
				local ODT_Btn_Tooltip = "Chargement des commandes - prévu pour une version ultérieure"
				SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
		elseif option == 421 then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			local ODT_Btn_Tooltip = GetString(btnchooseguild)
			SetTooltipText(InformationTooltip, ODT_Btn_Tooltip)
			
		end	

		ODT_MouseOpt = option
end

------------------------------------------------------------
-- Events mouse en XML 
-- Bouton gauche|centre|droit
------------------------------------------------------------
function XML_ODT_MouseBtn(control, button)

	if button == MOUSE_BUTTON_INDEX_LEFT then
		if IsControlKeyDown() == true then	
			ReloadUI()
		end
	elseif button == MOUSE_BUTTON_INDEX_MIDDLE then
		if IsShiftKeyDown() == false then
			ODT_SlashCommand("recrut")
		else 
			ODT_SlashCommand("bvnu")
		end
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		if IsShiftKeyDown() == false then
			ODT_SlashCommand("mdg")
		else 
			ODT_GuildMail_Show()
		end

	end
	ODT_MouseBtn = button
end

--*********************************************************************
-- Guild Mail
--*********************************************************************
function ODT_GuildMail_GuildSelect(guildnumber, mousemode)
	ODT_GuildMail_Guild1:SetColor(0.31, 0.31, 0.31)
	ODT_GuildMail_Guild2:SetColor(0.31, 0.31, 0.31)
	ODT_GuildMail_Guild3:SetColor(0.31, 0.31, 0.31)
	ODT_GuildMail_Guild4:SetColor(0.31, 0.31, 0.31)
	ODT_GuildMail_Guild5:SetColor(0.31, 0.31, 0.31)
	if mousemode == "Enter" then
		if guildnumber == 1 then
			ODT_GuildMail_Guild1:SetColor(0.5, 1.0, 0.9)
		elseif guildnumber == 2 then
			ODT_GuildMail_Guild2:SetColor(0.5, 1.0, 0.9)
		elseif guildnumber == 3 then
			ODT_GuildMail_Guild3:SetColor(0.5, 1.0, 0.9)
		elseif guildnumber == 4 then
			ODT_GuildMail_Guild4:SetColor(0.5, 1.0, 0.9)
		elseif guildnumber == 5 then
			ODT_GuildMail_Guild5:SetColor(0.5, 1.0, 0.9)
		end
	end
end

function ODT_GuildMail_GuildSelected(guildnumber)

	GuildSelectedNumber = guildnumber
	------------------------------------------------------------
	-- Charge le nombre de membres par rang
	------------------------------------------------------------
	guildId = GetGuildId(GuildSelectedNumber)
	local guildName = GetGuildName(guildId)
	
	ODTMAIL_cptGuildMembers = GetNumGuildMembers(guildId)

	ODT_MailMemberID = 0
	
	guildrank1cpt = 0
	guildrank2cpt = 0
	guildrank3cpt = 0
	guildrank4cpt = 0
	guildrank5cpt = 0
	guildrank6cpt = 0
	guildrank7cpt = 0
	guildrank8cpt = 0
	guildrank9cpt = 0
	guildrank10cpt = 0

	ODT_GuildRank01_Cpt:SetText("")
	ODT_GuildRank02_Cpt:SetText("")
	ODT_GuildRank03_Cpt:SetText("")
	ODT_GuildRank04_Cpt:SetText("")
	ODT_GuildRank05_Cpt:SetText("")
	ODT_GuildRank06_Cpt:SetText("")
	ODT_GuildRank07_Cpt:SetText("")
	ODT_GuildRank08_Cpt:SetText("")
	ODT_GuildRank09_Cpt:SetText("")
	ODT_GuildRank10_Cpt:SetText("")

	ODT_GuildRank01_Lbl:SetText("")
	ODT_GuildRank02_Lbl:SetText("")
	ODT_GuildRank03_Lbl:SetText("")
	ODT_GuildRank04_Lbl:SetText("")
	ODT_GuildRank05_Lbl:SetText("")
	ODT_GuildRank06_Lbl:SetText("")
	ODT_GuildRank07_Lbl:SetText("")
	ODT_GuildRank08_Lbl:SetText("")
	ODT_GuildRank09_Lbl:SetText("")
	ODT_GuildRank10_Lbl:SetText("")

	ODT_GuildMail_GuildRank01_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank02_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank03_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank04_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank05_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank06_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank07_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank08_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank09_Chk:SetHidden(true)
	ODT_GuildMail_GuildRank10_Chk:SetHidden(true)
	
	------------------------------------------------------------
	-- Récupère la liste des rangs (Guild Mail)
	------------------------------------------------------------
	local guildranks =  GetNumGuildRanks(guildId)
	for r=1,guildranks do
		local guildrankname = GetGuildRankCustomName(guildId, r)
		if r == 1 then 
			if guildName == "Orbe du Temps" or guildrankname == nil or guildrankname == "" then
				guildrankname = "Maître de Guilde"
			end
			ODT_GuildMail_GuildRank01_Chk:SetHidden(false)
			ODT_GuildRank01_Lbl:SetText(guildrankname)
		elseif r == 2 then 
			ODT_GuildMail_GuildRank02_Chk:SetHidden(false)
			ODT_GuildRank02_Lbl:SetText(guildrankname)
		elseif r == 3 then 
			ODT_GuildMail_GuildRank03_Chk:SetHidden(false)
			ODT_GuildRank03_Lbl:SetText(guildrankname)
		elseif r == 4 then 
			if guildName == "Orbe du Temps" then
				guildrankname = "Officier"
			end
			ODT_GuildMail_GuildRank04_Chk:SetHidden(false)
			ODT_GuildRank04_Lbl:SetText(guildrankname)
		elseif r == 5 then 
			ODT_GuildMail_GuildRank05_Chk:SetHidden(false)
			ODT_GuildRank05_Lbl:SetText(guildrankname)
		elseif r == 6 then 
			ODT_GuildMail_GuildRank06_Chk:SetHidden(false)
			ODT_GuildRank06_Lbl:SetText(guildrankname)
		elseif r == 7 then 
			ODT_GuildMail_GuildRank07_Chk:SetHidden(false)
			ODT_GuildRank07_Lbl:SetText(guildrankname)
		elseif r == 8 then 
			ODT_GuildMail_GuildRank08_Chk:SetHidden(false)
			ODT_GuildRank08_Lbl:SetText(guildrankname)
		elseif r == 9 then 
			ODT_GuildMail_GuildRank09_Chk:SetHidden(false)
			ODT_GuildRank09_Lbl:SetText(guildrankname)
		elseif r == 10 then 
			ODT_GuildMail_GuildRank10_Chk:SetHidden(false)
			ODT_GuildRank10_Lbl:SetText(guildrankname)
		end
	end
 
	for ODT_MailMemberID=1,ODTMAIL_cptGuildMembers do
		------------------------------------------------------------
		-- Récupère le nombre de membres par rang
		------------------------------------------------------------
		ODT_GuildMail_accountName, _, rankIndex = GetGuildMemberInfo(guildId, ODT_MailMemberID)	
		if rankIndex == 1 then 
			guildrank1cpt = guildrank1cpt + 1
			ODT_GuildRank01_Cpt:SetText("(" .. guildrank1cpt .. ")")
		elseif rankIndex == 2 then 
			 guildrank2cpt = guildrank2cpt + 1
			ODT_GuildRank02_Cpt:SetText("(" .. guildrank2cpt .. ")")
		elseif rankIndex == 3 then 
			 guildrank3cpt = guildrank3cpt + 1
			ODT_GuildRank03_Cpt:SetText("(" .. guildrank3cpt .. ")")
		elseif rankIndex == 4 then 
			 guildrank4cpt = guildrank4cpt + 1
			ODT_GuildRank04_Cpt:SetText("(" .. guildrank4cpt .. ")")
		elseif rankIndex == 5 then 
			 guildrank5cpt = guildrank5cpt + 1
			ODT_GuildRank05_Cpt:SetText("(" .. guildrank5cpt .. ")")
		elseif rankIndex == 6 then 
			 guildrank6cpt = guildrank6cpt + 1
			ODT_GuildRank06_Cpt:SetText("(" .. guildrank6cpt .. ")")
		elseif rankIndex == 7 then 
			 guildrank7cpt = guildrank7cpt + 1
			ODT_GuildRank07_Cpt:SetText("(" .. guildrank7cpt .. ")")
		elseif rankIndex == 8 then 
			 guildrank8cpt = guildrank8cpt + 1
			ODT_GuildRank08_Cpt:SetText("(" .. guildrank8cpt .. ")")
		elseif rankIndex == 9 then 
			 guildrank9cpt = guildrank9cpt + 1
			ODT_GuildRank09_Cpt:SetText("(" .. guildrank9cpt .. ")")
		elseif rankIndex == 10 then 
			 guildrank10cpt = guildrank10cpt + 1
			ODT_GuildRank10_Cpt:SetText("(" .. guildrank10cpt .. ")")
		end
	end

end

function ODT_GuildMail_Show()
	------------------------------------------------------------
	-- si [ODT] vérifie que le joueur est officier
	------------------------------------------------------------
	if isODTMember == true then
		if ODT_GuildRank > 4 then
			print ("|c94DE23[ODT]|cFF8174 Cette fonction est réservée aux officiers")
			return
		end
	end

	------------------------------------------------------------
	-- Force la sélection sur la guilde 1
	------------------------------------------------------------
	ODT_GuildMail_GuildSelect(1, "Enter")	
	ODT_GuildMail_GuildSelected(1)	

	------------------------------------------------------------
	-- Charge les noms de guildes
	------------------------------------------------------------
	for i=1,GetNumGuilds() do
		guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if guildName == nil or guildName == "" then
--			ODT_GuildMail_Guild1:SetHidden(true)
		else
			if i == 1 then
				ODT_GuildMail_Guild1:SetText(guildName)
			elseif i == 2 then
				ODT_GuildMail_Guild2:SetText(guildName)
			elseif i == 3 then
				ODT_GuildMail_Guild3:SetText(guildName)
			elseif i == 4 then
				ODT_GuildMail_Guild4:SetText(guildName)
			elseif i == 5 then
				ODT_GuildMail_Guild5:SetText(guildName)
			end
		end
	end
	
	------------------------------------------------------------
	-- Charge les messages	
	------------------------------------------------------------
	ODT_GuildMail_MsgCliCked("1", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("2", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("3", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("4", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("5", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("6", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("7", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("8", MOUSE_BUTTON_INDEX_LEFT)
	ODT_GuildMail_MsgCliCked("9", MOUSE_BUTTON_INDEX_LEFT)
	local aff = ODT_GuildMail_RAZButtonCliked()
	
	------------------------------------------------------------
	-- Initialise les checks de sendmail 
	------------------------------------------------------------
	ODT_GuildMail_GuildRank01_Mail = 1
	ODT_GuildMail_GuildRank02_Mail = 1
	ODT_GuildMail_GuildRank03_Mail = 1
	ODT_GuildMail_GuildRank04_Mail = 1
	ODT_GuildMail_GuildRank05_Mail = 1
	ODT_GuildMail_GuildRank06_Mail = 1
	ODT_GuildMail_GuildRank07_Mail = 1
	ODT_GuildMail_GuildRank08_Mail = 1
	ODT_GuildMail_GuildRank09_Mail = 1
	ODT_GuildMail_GuildRank10_Mail = 1

	------------------------------------------------------------
	-- Affiche la fenêtre
	------------------------------------------------------------
	ODT_GuildMail:SetHidden(false)
	ODT_:SetHidden(true)
	ODT_GuildMail_TitleText:SetMaxInputChars(50)
	ODT_GuildMail_TextText:SetMaxInputChars(700)	
	ODT_GuildMail_TitleText:TakeFocus()
	ODT_GuildMail_TitleText:SetText("|c84FF00ODT : ")	

end
	------------------------------------------------------------
	-- Envoi du code couleur dans le message
	------------------------------------------------------------
function ODT_GuildMail_ColorButtonCliCked(chx)
	if chx == "R" then
		ODT_chx = "|cf91b02"
	elseif chx == "V" then
		ODT_chx = "|c94DE23"
	elseif chx == "B" then
		ODT_chx = "|c000cff"
	elseif chx == "C" then
		ODT_chx = "|c00fffa"
	elseif chx == "M" then
		ODT_chx = "|cff00d0"
	elseif chx == "O" then
		ODT_chx = "|cff9000"
	elseif chx == "J" then
		ODT_chx = "|cffe100"
	end
	
	ODT_chx = ODT_GuildMail_TextText:GetText() .. ODT_chx 
	ODT_GuildMail_TextText:SetText(ODT_chx)
end

	------------------------------------------------------------
	-- Charge/Sauve le message
	------------------------------------------------------------
function ODT_GuildMail_MsgCliCked(chx, button)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		if chx == "1" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg1Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg1Text)
			ODT_GuildMail_Msg1_Lbl:SetText(ODT.savedVariables.Msg1Tit)			
		elseif chx == "2" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg2Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg2Text)
			ODT_GuildMail_Msg2_Lbl:SetText(ODT.savedVariables.Msg2Tit)			
		elseif chx == "3" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg3Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg3Text)
			ODT_GuildMail_Msg3_Lbl:SetText(ODT.savedVariables.Msg3Tit)			
		elseif chx == "4" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg4Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg4Text)
			ODT_GuildMail_Msg4_Lbl:SetText(ODT.savedVariables.Msg4Tit)			
		elseif chx == "5" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg5Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg5Text)
			ODT_GuildMail_Msg5_Lbl:SetText(ODT.savedVariables.Msg5Tit)			
		elseif chx == "6" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg6Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg6Text)
			ODT_GuildMail_Msg6_Lbl:SetText(ODT.savedVariables.Msg6Tit)			
		elseif chx == "7" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg7Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg7Text)
			ODT_GuildMail_Msg7_Lbl:SetText(ODT.savedVariables.Msg7Tit)			
		elseif chx == "8" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg8Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg8Text)
			ODT_GuildMail_Msg8_Lbl:SetText(ODT.savedVariables.Msg8Tit)			
		elseif chx == "9" then
			ODT_GuildMail_TitleText:SetText(ODT.savedVariables.Msg9Tit)
			ODT_GuildMail_TextText:SetText(ODT.savedVariables.Msg9Text)
			ODT_GuildMail_Msg9_Lbl:SetText(ODT.savedVariables.Msg9Tit)			
		end
	
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		ODT_chx = ODT_GuildMail_TitleText:GetText()
		
		if chx == "1" then
			ODT_GuildMail_Msg1_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg1Tit = ODT_chx
			ODT.savedVariables.Msg1Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "2" then
			ODT_GuildMail_Msg2_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg2Tit = ODT_chx
			ODT.savedVariables.Msg2Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "3" then
			ODT_GuildMail_Msg3_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg3Tit = ODT_chx
			ODT.savedVariables.Msg3Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "4" then
			ODT_GuildMail_Msg4_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg4Tit = ODT_chx
			ODT.savedVariables.Msg4Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "5" then
			ODT_GuildMail_Msg5_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg5Tit = ODT_chx
			ODT.savedVariables.Msg5Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "6" then
			ODT_GuildMail_Msg6_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg6Tit = ODT_chx
			ODT.savedVariables.Msg6Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "7" then
			ODT_GuildMail_Msg7_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg7Tit = ODT_chx
			ODT.savedVariables.Msg7Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "8" then
			ODT_GuildMail_Msg8_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg8Tit = ODT_chx
			ODT.savedVariables.Msg8Text = ODT_GuildMail_TextText:GetText()
		elseif chx == "9" then
			ODT_GuildMail_Msg9_Lbl:SetText(ODT_chx)
			ODT.savedVariables.Msg9Tit = ODT_chx
			ODT.savedVariables.Msg9Text = ODT_GuildMail_TextText:GetText()
		end

	end

end

	------------------------------------------------------------
	-- Guild Rank : Chk → UnChk
	------------------------------------------------------------
function ODT_GuildRanChk(rankchx)
	if rankchx == 1 then
		ODT_GuildMail_GuildRank01_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank01_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank01_Mail = 0
	elseif rankchx == 2 then
		ODT_GuildMail_GuildRank02_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank02_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank02_Mail = 0
	elseif rankchx == 3 then
		ODT_GuildMail_GuildRank03_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank03_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank03_Mail = 0
	elseif rankchx == 4 then
		ODT_GuildMail_GuildRank04_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank04_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank04_Mail = 0
	elseif rankchx == 5 then
		ODT_GuildMail_GuildRank05_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank05_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank05_Mail = 0
	elseif rankchx == 6 then
		ODT_GuildMail_GuildRank06_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank06_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank06_Mail = 0
	elseif rankchx == 7 then
		ODT_GuildMail_GuildRank07_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank07_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank07_Mail = 0
	elseif rankchx == 8 then
		ODT_GuildMail_GuildRank08_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank08_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank08_Mail = 0
	elseif rankchx == 9 then
		ODT_GuildMail_GuildRank09_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank09_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank09_Mail = 0
	elseif rankchx == 10 then
		ODT_GuildMail_GuildRank10_Chk:SetHidden(true)
		ODT_GuildMail_GuildRank10_UnChk:SetHidden(false)
		ODT_GuildMail_GuildRank10_Mail = 0
	end
end
	------------------------------------------------------------
	-- Guild Rank : UnChk → Ckh
	------------------------------------------------------------
function ODT_GuildRanUnChk(rankchx)
	if rankchx == 1 then
		ODT_GuildMail_GuildRank01_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank01_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank01_Mail = 1
	elseif rankchx == 2 then
		ODT_GuildMail_GuildRank02_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank02_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank02_Mail = 1
	elseif rankchx == 3 then
		ODT_GuildMail_GuildRank03_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank03_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank03_Mail = 1
	elseif rankchx == 4 then
		ODT_GuildMail_GuildRank04_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank04_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank04_Mail = 1
	elseif rankchx == 5 then
		ODT_GuildMail_GuildRank05_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank05_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank05_Mail = 1
	elseif rankchx == 6 then
		ODT_GuildMail_GuildRank06_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank06_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank06_Mail = 1
	elseif rankchx == 7 then
		ODT_GuildMail_GuildRank07_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank07_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank07_Mail = 1
	elseif rankchx == 8 then
		ODT_GuildMail_GuildRank08_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank08_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank08_Mail = 1
	elseif rankchx == 9 then
		ODT_GuildMail_GuildRank09_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank09_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank09_Mail = 1
	elseif rankchx == 10 then
		ODT_GuildMail_GuildRank10_Chk:SetHidden(false)
		ODT_GuildMail_GuildRank10_UnChk:SetHidden(true)
		ODT_GuildMail_GuildRank10_Mail = 1
	end
end

	------------------------------------------------------------
	-- Titre (sujet du mail)
	------------------------------------------------------------
function XML_ODT_GuildMail_Title()
	local gmtitle = ODT_GuildMail_TitleText:GetText()
	ODT_GuildMail_Title_Show:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Texte du mail
	------------------------------------------------------------
function XML_ODT_GuildMail_Text()
	local gmtitle = ODT_GuildMail_TextText:GetText()
	ODT_GuildMail_Text_Show:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Modification du texte : affichage
	------------------------------------------------------------
function ODT_GuildMail_TextText.onTextChanged()
	local length = string.len(ODT_GuildMail_TextText:GetText())
	ODT_GuildMail_Text_Length:SetText(length .. "/700")
	local aff = XML_ODT_GuildMail_Text()
end

	------------------------------------------------------------
	-- Modification du titre : affichage
	------------------------------------------------------------
function ODT_GuildMail_TitleText.onTextChanged()
	local length = string.len(ODT_GuildMail_TitleText:GetText())
	ODT_GuildMail_Title_Length:SetText(length .. "/50")
	local aff = XML_ODT_GuildMail_Title()
end

	------------------------------------------------------------
	-- Bouton RAZ
	------------------------------------------------------------
function ODT_GuildMail_RAZButtonCliked()
	ODT_GuildMail_TitleText:Clear()
	ODT_GuildMail_TextText:Clear()
	ODT_GuildMail_TitleText:SetText("|c84FF00ODT : ")
end

	------------------------------------------------------------
	-- Bouton fermeture de la fenêtre
	------------------------------------------------------------
function ODT_GuildMail_CloseButtonCliked()
	ODT_GuildMail:SetHidden(true)
end

	------------------------------------------------------------
	-- Bouton Maison de guilde
	------------------------------------------------------------
function ODT_GuildMail_HouseButtonCliked()
	local gmtitle = ODT_GuildMail_TextText:GetText() .. "|t32:32:esoui/art/icons/housing_ad_manor.dds|t"
	ODT_GuildMail_TextText:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Bouton Raid
	------------------------------------------------------------
function ODT_GuildMail_RaidButtonCliked()
	local gmtitle = ODT_GuildMail_TextText:GetText() .. "|t36:36:esoui/art/journal/leaderboard_indexicon_raids_up.dds|t"
	ODT_GuildMail_TextText:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Bouton PvP
	------------------------------------------------------------
function ODT_GuildMail_PVPButtonCliked()
	local gmtitle = ODT_GuildMail_TextText:GetText() .. "|t36:36:esoui/art/icons/icon_dualwield.dds|t"
	ODT_GuildMail_TextText:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Bouton Banque de guilde
	------------------------------------------------------------
function ODT_GuildMail_BankButtonCliked()
	local gmtitle = ODT_GuildMail_TextText:GetText() .. "|t28:28:esoui/art/icons/mapkey/mapkey_bank.dds|t"
	ODT_GuildMail_TextText:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Bouton Messager
	------------------------------------------------------------
function ODT_GuildMail_SignButtonCliked()
	local gmtitle = ODT_GuildMail_TextText:GetText() .. "|cFFBD00|t64:64:esoui/art/icons/pet_059.dds|t Messager de l'Orbe du Temps"
	ODT_GuildMail_TextText:SetText(gmtitle)
end

	------------------------------------------------------------
	-- Bouton Envoi message 
	------------------------------------------------------------
function ODT_GuildMail_SendMail()
	
	ODT_GuildMail_CptRead_SendMail:SetColor(1,.5,0,1) --orange
	ODT_GuildMail_Account_SendMail:SetText("")
	ODT_GuildMail_CptRead_SendMail:SetText("")
	ODT_GuildMail_CptSend_SendMail:SetText("")
	------------------------------------------------------------
	-- Récupère le nombre de membres dans la guilde
	------------------------------------------------------------
	for i=1,GetNumGuilds() do
		guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
--		if guildName == "Orbe du Temps" then
		if i == GuildSelectedNumber then
			ODTguildId = guildId
			ODTMAIL_cptGuildMembers = GetNumGuildMembers(guildId)
		end 
	end
	
	ODTcptSend = 0
	ODT_SendSuccess = 1	
	ODT_MailMemberID = 0

	zo_callLater(function() ODT_GuildMail_SendMailTimed() end, 1200)			
end

function ODT_GuildMail_SendMailTimed()

	------------------------------------------------------------
	-- Fin du balayage de la liste des membres
	------------------------------------------------------------
	if ODT_MailMemberID == ODTMAIL_cptGuildMembers then
		ODT_GuildMail_CptRead_SendMail:SetColor(.5,1,0,1) --vert
		ODT_GuildMail_Retry:SetText("")		
		return
	end

	------------------------------------------------------------
	-- Teste que l'envoi se soit effectué avec succès
	------------------------------------------------------------	
	if ODT_SendSuccess == 0 then
		ODT_GuildMail_DoSendMail() 
	else

		------------------------------------------------------------
		-- Membre suivant
		------------------------------------------------------------
		ODT_SendRetry = 0 
		ODT_MailMemberID = ODT_MailMemberID + 1
		ODTdoSend = 0
		
		ODT_GuildMail_CptRead_SendMail:SetText(ODT_MailMemberID .. "/" .. ODTMAIL_cptGuildMembers .. " traités")

		------------------------------------------------------------
		-- Récupère le nom et rang du joueur
		------------------------------------------------------------
		ODT_GuildMail_accountName, _, rankIndex = GetGuildMemberInfo(ODTguildId, ODT_MailMemberID)	
		------------------------------------------------------------
		-- Contrôle que le rang fait partie de la liste de diffusion
		------------------------------------------------------------
		if rankIndex == 1 and ODT_GuildMail_GuildRank01_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 2 and ODT_GuildMail_GuildRank02_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 3 and ODT_GuildMail_GuildRank03_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 4 and ODT_GuildMail_GuildRank04_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 5 and ODT_GuildMail_GuildRank05_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 6 and ODT_GuildMail_GuildRank06_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 7 and ODT_GuildMail_GuildRank07_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 8 and ODT_GuildMail_GuildRank08_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 9 and ODT_GuildMail_GuildRank09_Mail == 1 then
			ODTdoSend = 1
		end
		if rankIndex == 10 and ODT_GuildMail_GuildRank10_Mail == 1 then
			ODTdoSend = 1
		end
		------------------------------------------------------------
		-- Envoi le mail
		------------------------------------------------------------		
		if ODTdoSend == 1 then
			ODT_MailFailedReason = 0
			ODT_SendSuccess = 0
			ODT_SendRetry = 0
			zo_callLater(function() ODT_GuildMail_DoSendMail() end, 1200)	
		else
			ODT_SendRetry = 0
			ODT_SendSuccess = 1
			aff = ODT_GuildMail_SendMailTimed()
		end
	end
end

function ODT_GuildMail_DoSendMail() 
	------------------------------------------------------------
	-- Affiche le nom du membre
	------------------------------------------------------------		
	ODT_GuildMail_Account_SendMail:SetText(ODT_GuildMail_accountName)
	------------------------------------------------------------
	-- Affiche le nombre d'essais de renvoi (failed)
	------------------------------------------------------------		
	ODT_GuildMail_Retry:SetText(ODT_SendRetry)

	------------------------------------------------------------
	-- Envoi le mail
	------------------------------------------------------------		
	RequestOpenMailbox()		
	SendMail(ODT_GuildMail_accountName, ODT_GuildMail_TitleText:GetText(),  ODT_GuildMail_TextText:GetText())
	CloseMailbox() 

	------------------------------------------------------------
	-- Si echec (failed) teste 5 envois 
	------------------------------------------------------------		
	if ODT_SendSuccess == 0 then
		if ODT_MailFailedReason > 0 then
			if ODT_MailFailedReason == 11 then
				ODT_MailMemberID = ODT_MailMemberID - 1
			end 
			ODT_MailFailedReason = 0
			ODT_SendRetry = 0
			ODT_SendSuccess = 1	
			aff = ODT_GuildMail_SendMailTimed()
			return
		end
		ODT_SendRetry = ODT_SendRetry + 1
		ODT_GuildMail_Retry:SetText(ODT_SendRetry)
		if ODT_SendRetry < 5 then
			zo_callLater(function() ODT_GuildMail_DoSendMail() end, 1200)	
			
		else
			------------------------------------------------------------
			-- Echec après 5 essais : passe au membre suivant
			------------------------------------------------------------		
			print(GetString(mailsenderror) .. ODT_GuildMail_accountName .. ")")			
			ODT_Playsound(ODT_MailRTS_SOUND2)
			ODT_SendRetry = 0
			ODT_SendSuccess = 1	
			aff = ODT_GuildMail_SendMailTimed()
		end
	else
		------------------------------------------------------------
		-- Si succès : affiche le nom du joueur
		--             icrémente le compteur d'envois
		--             passe au membre suivant
		------------------------------------------------------------		
		------------------------------------------------------------
		-- Sauf si envoi à soi-même ou boîte pleine
		------------------------------------------------------------		
		ODT_GuildMail_Retry:SetText("")
		ODT_SendRetry = 0
		ODT_SendSuccess = 1	
		ODTcptSend  = ODTcptSend  + 1
		ODT_GuildMail_CptSend_SendMail:SetText(ODTcptSend  .. GetString(mailsendsuccess))
		aff = ODT_GuildMail_SendMailTimed()
	end
end

--*********************************************************************
-- MAILBOX : RTS
--*********************************************************************
function ODT_MailInboxUpdate()
	if ODT_MailRTS_ONOFF == true then
		local NbMails = GetNumMailItems()
		local MailId = nil		

		for m = 0, NbMails, 1 do
			MailId = GetNextMailId(MailId)
			local SenderAccount, SenderName, Subject, Icon, systemBool1, systemBool2, bool3, returnedMail, numAttachments, num2, num3, daysLeft, someNumber = GetMailItemInfo(MailId)
			if string.find(SenderAccount, "@") then
				if SenderName ~= "" and Subject ~= "" then
					if string.upper(string.sub(Subject,1,4)) == "RTS" then
						if numAttachments > 0 then
							print (GetString(mailrtssender) .. SenderAccount .. GetString(mailrtsobjects) .. numAttachments)
							
							RequestOpenMailbox()		
							ReturnMail(MailId);
							CloseMailbox() 
--							zo_callLater(function() ODT_MailDelete(MailId) end, 500) 						


						else
							ODT_Playsound(ODT_MailRTS_SOUND2)
							print (GetString(mailrtsnil) .. SenderAccount)
						end
					end
				end
			end
		end
	end

end 
-------------------------------------------------------- 
-- MAILBOX : Delete & Clear
-------------------------------------------------------- 
function ODT_MailDelete(mailId)
    DeleteMail(mailId, true)

	QueueMoneyAttachment(0) 
	ZO_MailSendToField:SetText( "" )
	ZO_MailSendSubjectField:SetText( "" )
	ZO_MailSendBodyField:SetText("")
	ClearQueuedMail()
	ODT_Playsound(ODT_MailRTS_SOUND1)
	CloseMailbox()
end

--*********************************************************************
-- MAILBOX : SEND FAILED
--*********************************************************************
function ODT_MailboxSendFailed(eventCode, reason)
	if reason == 8		then print("|cC80F14COD Error")
		ODT_MailFailedReason = 8
	elseif reason == 11 then print (GetString(mailsenderrorself))
		ODT_MailFailedReason = 11
	elseif reason == 7  then print( "|cC80F14Blank Mail")
		ODT_MailFailedReason = 7
	elseif reason == 1  then print( "|cC80F14DB Error")
		ODT_MailFailedReason = 1
	elseif reason == 4  then print( "|cC80F14Ignored")
		ODT_MailFailedReason = 4
	elseif reason == 10 then print( "|cC80F14In Progress")
		ODT_MailFailedReason = 10
	elseif reason == 2  then print( "|cC80F14Invalid Name")
		ODT_MailFailedReason = 2
	elseif reason == 3  then print (GetString(mailsenderrorfull) .. ODT_GuildMail_accountName .. ")")
		ODT_MailFailedReason = 3
	elseif reason == 6  then print( "|cC80F14Invalid Item")
		ODT_MailFailedReason = 6
	elseif reason == 12 then print( "|cC80F14Mail Disabled")
		ODT_MailFailedReason = 12
	elseif reason == 13 then print (GetString(mailsenderrorclosed))
		ODT_MailFailedReason = 13
	elseif reason == 9  then print( "|cC80F14COD Error")
		ODT_MailFailedReason = 9
	elseif reason == 5  then print( "|cC80F14Gold Error")
		ODT_MailFailedReason = 5
	elseif reason == 15 then print( "|cC80F14User Not Found")
		ODT_MailFailedReason = 15
	elseif reason == 14 then print( "|cC80F14Attachment Error")
		ODT_MailFailedReason = 14
	else print( "|cC80F14Unknown Error")
	end
	ODT_SendSuccess = 0
	
end

--*********************************************************************
-- MAILBOX : SEND SUCCESS
--*********************************************************************
function ODT_MailboxSendSuccess()
	ODT_SendSuccess = 1	
	ODT_MailFailedReason = 0
end

--*********************************************************************
-- Fenêtre des commandes
--*********************************************************************
	------------------------------------------------------------
	-- Bouton de fermeture de la fenêtre liste commandes
	------------------------------------------------------------
function ODT_CloseButtonCliked()
	ODT_:SetHidden(true)
	ODT_Combox_State = 2
end

	------------------------------------------------------------
	-- Bouton de commande
	------------------------------------------------------------
function ODT_CmdListBtnClicked(control, option)
	if ODT_ChkBox01_isChecked == true then
		option = option .. " -c"
	end
	ODT_SlashCommand(option)
end

	------------------------------------------------------------
	-- Ckeckbox options
	------------------------------------------------------------
function ODT_Box01()
	if ODT_ChkBox01_isChecked == true then
		ODT_Box01Chk:SetHidden(true)
		ODT_Box01UnChk:SetHidden(false)
		ODT_ChkBox01_isChecked = false
	else
		ODT_Box01Chk:SetHidden(false)
		ODT_Box01UnChk:SetHidden(true)
		ODT_ChkBox01_isChecked = true
	end 
end 

	-------------------------------------------------------- 
	-- Affiche la liste des commandes
	-------------------------------------------------------- 
uiCmdList = function ()
	ODT_Version:SetText(ODT.version)
	
 	ODT_CmdList1:Clear()
	ODT_CmdList2:Clear()

	ODT_CmdList1:AddMessage("|cFF874CCommandes officiers :")
	ODT_CmdList1:AddMessage("|cFFB04D• Message de recrutement")
	ODT_CmdList1:AddMessage("|cFFB04D• Message d'accueil")
	ODT_CmdList1:AddMessage("|cFFB04D• Mail de guilde")
	ODT_CmdList1:AddMessage(" ")  
	ODT_CmdList1:AddMessage("|c94DE23Forum :")
	ODT_CmdList1:AddMessage("|cFFB04D• Adresse du forum")
	ODT_CmdList1:AddMessage("|cFFB04D• Règles de la guilde")
	ODT_CmdList1:AddMessage("|cFFB04D• Evénements")
	ODT_CmdList1:AddMessage(" ")  
	ODT_CmdList1:AddMessage("|c94DE23Divers :")
	ODT_CmdList1:AddMessage("|cFFB04D• Code d'invitation discord")
	ODT_CmdList1:AddMessage("|cFFB04D• Aller en maison de guilde")
	ODT_CmdList1:AddMessage("|cFFB04D• Sauvegarder les couleurs du chat")
	ODT_CmdList1:AddMessage("|cFFB04D• Charger les couleurs du chat")
	ODT_CmdList1:AddMessage("|c696967• Sauvegarder les commandes")
	ODT_CmdList1:AddMessage("|c696967• Charger les commandes")
	ODT_CmdList1:AddMessage("|cFFB04D• Version de l'addon")
	ODT_CmdList1:AddMessage(" ")  
	ODT_CmdList1:AddMessage("|cF346FFSerments des indomptables (dailies)")
	ODT_CmdList1:AddMessage(GetString(cmd_pledges_today))
	ODT_CmdList1:AddMessage(GetString(cmd_pledges_before_yesterday))
	ODT_CmdList1:AddMessage(GetString(cmd_pledges_yesterday))
	ODT_CmdList1:AddMessage(GetString(cmd_pledges_tomorrow))
	ODT_CmdList1:AddMessage(GetString(cmd_pledges_after_tomorrow))
	ODT_CmdList1:AddMessage(" ")  
	ODT_CmdList1:AddMessage("|c00D7FFOptions :")
	ODT_CmdList1:AddMessage("|cFFB04D -c")     
	ODT_CmdList1:AddMessage("|cFFB04D -g")     
	ODT_CmdList1:AddMessage(" ")  
	ODT_CmdList1:AddMessage("|c94DE23Exemples :")
	ODT_CmdList1:AddMessage("|c94DE23|cEDFF00/odt pledges+1 -c")   
	ODT_CmdList1:AddMessage("|c94DE23|cEDFF00/odt discord -c")   	

	ODT_CmdList2:AddMessage(" ")
	ODT_CmdList2:AddMessage("|cEDFF00/odt recrut")
	ODT_CmdList2:AddMessage("|cEDFF00/odt bvnu")
	ODT_CmdList2:AddMessage("|cEDFF00/odt mail")
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage(" ")
	ODT_CmdList2:AddMessage("|cEDFF00/odt forum |c00D7FF-option ")
	ODT_CmdList2:AddMessage("|cEDFF00/odt regles |c00D7FF-option ")
	ODT_CmdList2:AddMessage("|cEDFF00/odt event |c00D7FF-option ")
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage("|cEDFF00/odt discord |c00D7FF-option ")
	ODT_CmdList2:AddMessage("|cEDFF00/odt mdg")
	ODT_CmdList2:AddMessage("|cEDFF00/odt savechatcolors")
	ODT_CmdList2:AddMessage("|cEDFF00/odt loadchatcolors")
	ODT_CmdList2:AddMessage("|c696967prévu pour une version ultérieure")
	ODT_CmdList2:AddMessage("|c696967prévu pour une version ultérieure")
	ODT_CmdList2:AddMessage("|cEDFF00/odt v")
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage("|cEDFF00/odt pledges |c00D7FF-option")
	ODT_CmdList2:AddMessage("|cEDFF00/odt pledges-2 |c00D7FF-option")
	ODT_CmdList2:AddMessage("|cEDFF00/odt pledges-1 |c00D7FF-option")
	ODT_CmdList2:AddMessage("|cEDFF00/odt pledges+1 |c00D7FF-option")
	ODT_CmdList2:AddMessage("|cEDFF00/odt pledges+2 |c00D7FF-option")
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage("|c94DE23Copie le message dans le chat")     
	ODT_CmdList2:AddMessage("|c94DE23Met à jour les dailies en message de guilde")     
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage(" ")  
	ODT_CmdList2:AddMessage("|cFFB04DAffiche des dailies de demain |cEDFF00[pledges+1] |cFFB04Det les envoi dans le tchat |c00D7FF[-c]")   
	ODT_CmdList2:AddMessage("|cFFB04DAffiche le code d'invitation discord |cEDFF00[discord] |cFFB04Det l'envoi dans le tchat |c00D7FF[-c]")   	
 end

--*********************************************************************
-- Affichage de l'ui liste des commmandes (initialisation)
--*********************************************************************
local function uiShow()
	-------------------------------------------------------- 
	-- Charge la liste des commandes
	-------------------------------------------------------- 
 		uiCmdList()

	-------------------------------------------------------- 
	-- Masque la fenêtre
	-------------------------------------------------------- 
	ODT_Combox_State = 2
	ODT_:SetHidden(true)
end

--*********************************************************************
-- Message d'information de chargement de l'addon (timé)
--*********************************************************************
function ODT_InitMsg(InitMsg)
	if InitMsg == "addonloaded" then
		print ("|cFF6909addon ODT (" .. ODT.version .. GetString(addonloaded))
	end 
	if InitMsg == "MsgGuild" then
		print (GetString(dailiesupdated))
	end 
	
end 

--*********************************************************************
-- Chargement du joueur
--*********************************************************************
local function ODT_EVENT_PLAYER_ACTIVATED(eventId)
	------------------------------------------------------------
	-- Info de chargement de l'addon - Timer 500ms
	------------------------------------------------------------
	if showStartMessage == true then
		zo_callLater(function() ODT_InitMsg("addonloaded") end, 500) 
--		zo_callLater(function() ODT_LoadSettings() end, 100) 	  
		ODT_LoadSettings()

		zo_callLater(function() ODT_BagInfo() end, 800) 	  
		if ODT_MailRTS_ONOFF == true then
			zo_callLater(function() ODT_InitMsg("MailRTS") end, 800) 
			zo_callLater(function() ODT_MailInboxUpdate() end, 800) 	  
		end

		zo_callLater(function() ODT_Stolen() end, 800) 	  

		zo_callLater(function() ODT_WeaponsCharge(EQUIP_SLOT_MAIN_HAND) end, 500) 	  
		zo_callLater(function() ODT_WeaponsCharge(EQUIP_SLOT_OFF_HAND) end, 500) 	  
		zo_callLater(function() ODT_WeaponsCharge(EQUIP_SLOT_BACKUP_MAIN) end, 500) 	  
		zo_callLater(function() ODT_WeaponsCharge(EQUIP_SLOT_BACKUP_OFF) end, 500) 	  

		zo_callLater(function() ODT_OpenStore() end, 500) 	  
		
		zo_callLater(function() ODTMsgSpecial() end, 1000) 	  

		zo_callLater(function() ODT_NoFadeDisableFading() end, 3000) 	  		

		zo_callLater(function() ODT_BackGround() end, 100) 	  

		InitFish = 1
		zo_callLater(function() ODT_OnInterAct() end, 1000) 	  		
		
		
	end 

	------------------------------------------------------------
	-- Récupère le nom de compte @userid
	------------------------------------------------------------
	ODT_AccountName = GetDisplayName()

	------------------------------------------------------------
	-- Vérifie que le joueur est membre de la guilde
	-- Récupère le rang du joueur dans la guilde
	-- Récupère le nom des guildes
	------------------------------------------------------------
	
	for i=1,GetNumGuilds() do
		guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if     i == 1 then
			ODT_GUILD1_NAME = guildName
			ODT_GUILD1_ID = guildId
		elseif i == 2 then
			ODT_GUILD2_NAME = guildName
			ODT_GUILD2_ID = guildId
		elseif i == 3 then
			ODT_GUILD3_NAME = guildName
			ODT_GUILD3_ID = guildId
		elseif i == 4 then
			ODT_GUILD4_NAME = guildName
			ODT_GUILD4_ID = guildId
		elseif i == 5 then
			ODT_GUILD5_NAME = guildName
			ODT_GUILD5_ID = guildId
		end
		
		if guildName == "Orbe du Temps" then
			ODTguildId = guildId

			------------------------------------------------------------
			-- Récupère le rang du joueur
			------------------------------------------------------------
			local _, _, rankIndex = GetGuildMemberInfo(guildId, GetPlayerGuildMemberIndex(guildId))	
			ODT_GuildRank = rankIndex

			------------------------------------------------------------
			-- Récupère la liste des rangs (Guild Mail)
			------------------------------------------------------------
			local guildranks =  GetNumGuildRanks(guildId)
			for r=1,guildranks do
				local guildrankname = GetGuildRankCustomName(guildId, r)
				if r == 1 then 
					guildrankname = "Maître de Guilde"
					ODT_GuildMail_GuildRank01_Chk:SetHidden(false)
					ODT_GuildRank01_Lbl:SetText(guildrankname)
				elseif r == 2 then 
					ODT_GuildMail_GuildRank02_Chk:SetHidden(false)
					ODT_GuildRank02_Lbl:SetText(guildrankname)
				elseif r == 3 then 
					ODT_GuildMail_GuildRank03_Chk:SetHidden(false)
					ODT_GuildRank03_Lbl:SetText(guildrankname)
				elseif r == 4 then 
					guildrankname = "Officier"
					ODT_GuildMail_GuildRank04_Chk:SetHidden(false)
					ODT_GuildRank04_Lbl:SetText(guildrankname)
				elseif r == 5 then 
					ODT_GuildMail_GuildRank05_Chk:SetHidden(false)
					ODT_GuildRank05_Lbl:SetText(guildrankname)
				elseif r == 6 then 
					ODT_GuildMail_GuildRank06_Chk:SetHidden(false)
					ODT_GuildRank06_Lbl:SetText(guildrankname)
				elseif r == 7 then 
					ODT_GuildMail_GuildRank07_Chk:SetHidden(false)
					ODT_GuildRank07_Lbl:SetText(guildrankname)
				elseif r == 8 then 
					ODT_GuildMail_GuildRank08_Chk:SetHidden(false)
					ODT_GuildRank08_Lbl:SetText(guildrankname)
				elseif r == 9 then 
					ODT_GuildMail_GuildRank09_Chk:SetHidden(false)
					ODT_GuildRank09_Lbl:SetText(guildrankname)
				elseif r == 10 then 
					ODT_GuildMail_GuildRank10_Chk:SetHidden(false)
					ODT_GuildRank10_Lbl:SetText(guildrankname)
				end
			end

			------------------------------------------------------------
			-- Renseigne les dailies en message de guilde
			------------------------------------------------------------
			if ODT_GuildRank  < 5 then
				local MsgGuild = ODT_MsgGuild(ODTguildId, "load")
			end

			------------------------------------------------------------
			-- Renseigne que le joueur est membre de la guilde
			------------------------------------------------------------
			isODTMember = true
		end
	end

	showStartMessage = false
	
    character =123
--	ODT.savedVariables.autoSets[character] = "123456"
	
end

--*********************************************************************
-- Mise à jour des pledges en message de guilde
--*********************************************************************
function ODT_MsgGuild(guildId, appel)
	donothing = false

  	local ToDay = GetDateStringFromTimestamp(GetTimeStamp())		 	
	local ToDayparts = { zo_strsplit("/", ToDay) }
	local ToDay_Day = ToDayparts[1]

	local retVal, val, c = "", GetTimeString(), {215/255,213/255,205/255,1}
	local hh, mm, ss = val:match("([^:]+):([^:]+):([^:]+)")
	local hhmm = hh .. mm 

	dDay = GetDateStringFromTimestamp(GetTimeStamp())		 
	
	------------------------------------------------------------
	-- Désactive la mise à jour en chargement de zone
	------------------------------------------------------------
	if appel == "load" and ODTMsgGuildLoad == 1 then
		return
	end 
	
	------------------------------------------------------------
	-- Découpage du message de guilde
	------------------------------------------------------------
	local MsgGuild = GetGuildMotD(guildId)
	local parts = { zo_strsplit(" ", MsgGuild) }

	------------------------------------------------------------
	-- Récupère les dailies
	------------------------------------------------------------
	dayOffset = 0
	ODT_Pledges = (GetPledgesString(dayOffset))
	
	------------------------------------------------------------
	-- Met à jour le message ou pas
	------------------------------------------------------------
	if string.find(parts[2], dDay) then	
		------------------------------------------------------------
		-- Si déjà mis à jour ne fait rien
		------------------------------------------------------------
		donothing = true
	else	
		donothing = false
	end 

	if appel == "cmd" then
		donothing = false
	end 
	
	if donothing == false then
		------------------------------------------------------------
		-- S'il est 8h00 minimum met à jour
		------------------------------------------------------------
		if hhmm > "0759" then
			------------------------------------------------------------
			-- Reconstruction du message de guilde
			------------------------------------------------------------
			MsgGuild = parts[1] .. " (" .. dDay .. ") " .. ODT_PledgesJ .. " " .. parts[3]

			------------------------------------------------------------
			-- Mise à jour du message de guilde
			------------------------------------------------------------
			local a = SetGuildMotD(guildId, MsgGuild)
			
			ODTMsgGuildLoad = 1

			if showStartMessage == true then
				zo_callLater(function() ODT_InitMsg("MsgGuild") end, 510) 
			end 
		end
	end
	
end

--*********************************************************************
-- FISH : affiche le type d'eau et les appâts
--*********************************************************************
local currentInteractableName
function ODT_OnInterAct()
 
	local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
	local x,y,z = GetMapPlayerPosition("player")
	x=math.floor(x*1000)/1000
	y=math.floor(y*1000)/1000
	
	if interactableName ~= currentInteractableName then
		currentInteractableName = interactableName
--print(action .. " " .. interactableName)
		if action == "Pêcher" or action == "Fish" then
			if ODT_Fish == true then
				if string.find(interactableName, "Saltwater") or string.find(interactableName, "mer") or string.find(interactableName, "mystique") or string.find(interactableName, "Mystic") then
					iconFile = "/esoui/art/icons/crafting_worms.dds"
					printfish = GetString(fish_ocean)
				end
				if string.find(interactableName, "River") or string.find(interactableName, "rivière")then
					iconFile = "/esoui/art/icons/crafting_critter_flying_insect_bug_thorax.dds"
					printfish = GetString(fish_river)
				end
				if string.find(interactableName, "Lake") or string.find(interactableName, "lacustre")then
					iconFile = "/esoui/art/icons/crafting_critter_vertebrate_guts.dds"
					printfish = GetString(fish_lake)
				end
				if string.find(interactableName, "Foul") or string.find(interactableName, "sale") or string.find(interactableName, "huileux") or string.find(interactableName, "Oily") then
					iconFile = "/esoui/art/icons/crafting_fishing_fish_roe.dds"
					printfish = GetString(fish_foul)
				end

				iconprint = zo_iconFormat(iconFile, 20, 20)		
				print("|c04D631[ODT] : " .. iconprint .. printfish)
			end
		end
	end
--	if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
--	end
end


function ODT_FishReset()
	InitFish = 0
	currentInteractableName = nil
end
function ODT_OnReticleTargetPlayerChanged()
--	currentInteractableName = ""
end
	
------------------------------------------------------------
-- Message spécial
------------------------------------------------------------
function ODTMsgSpecial()
	local Language = GetCVar("Language.2")
	if Language == "en" then 
		print ("|c04D631[→")
		print ("|c04D631[ODT] ENGLISH VERSION :")
		print ("|c04D631If some bad/miss translation please send mail")
		print ("|c04D631@bldragon06@gmail.com with screen if possible")
		print ("|c04D631←]")
	else
		print ("|c04D631[→")
		print ("|c04D631[ODT]  :")
		print ("|c04D631Pour tout report de bug ou suggestion d'amélioration")
		print ("|c04D631merci d'envoyer un mail @bldragon06@gmail.com")
		print ("|c04D631←]")
	end
	

  	local ToDay = GetDateStringFromTimestamp(GetTimeStamp())		 	
	local ToDayparts = { zo_strsplit("/", ToDay) }
	local ToDay_Day = ToDayparts[1]
	local ToDay_Month = ToDayparts[2]
	local ToDay_Date = ToDayparts[1] .. ToDayparts[2]
	local ToDay_Year =  "20" .. ToDayparts[3]

	if ToDay_Month == "01" then
		Special0101 = ODT.savedVariables.Special0101 
		if Special0101 == ToDay_Year then
			local a = nil
		else
		ODT_MSGSPECIAL:SetHidden(false)
		ODT_MSGSPECIAL_INFO:SetText("\n                  Bonne année " .. ToDay_Year .. " et meilleurs voeux")
		ODT.savedVariables.Special0101 = ToDay_Year 			
		end
	end 			

end

--*********************************************************************
-- Bindings
--*********************************************************************
function ODTAddon.Bindings(option)
	if option == 1 then
		ToggleChatWindow()
	elseif option == 2 then
		ReloadUIBinding()
	elseif option == 3 then
		CHAT_SYSTEM.primaryContainer.currentBuffer:Clear()
	end
end

--*********************************************************************
-- Pledges
--*********************************************************************
	------------------------------------------------------------
	-- Fonction de calcul de date pour les pledges
	------------------------------------------------------------
local function FormatTimeBetween(startTime, endTime)
	local diff = math.abs(GetDiffBetweenTimeStamps(startTime, endTime))
	return ZO_FormatTime(diff, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR):gsub("m.-$","m")
end

	------------------------------------------------------------
	-- Fonctions pledges
	------------------------------------------------------------
local function GetDungeonName(pledgeCycle, diff)
	local cycleIndex = 1 + diff % #pledgeCycle
	local dungeonIndex = pledgeCycle[cycleIndex]
	return GetLFGOption(LFG_ACTIVITY_DUNGEON, dungeonIndex)
end


function GetPledgesString(dayOffset)
    -- Liste des donjons 
    -- GetLFGOption(LFG_ACTIVITY_DUNGEON, index):
    -- 1: Champignonnière I
    -- 2: Tressefuseau I
    -- 3: Le cachot interdit I
    -- 4: Cavernes d'Ombre-noire I
    -- 5: Egouts d'Haltevoie I
    -- 6: Creuset des aînés I
    -- 7: Arx Corinium
    -- 8: Crypte des coeurs I
    -- 9: Cité des cendres I
    -- 10: Affregivre
    -- 11: Volenfell
    -- 12: Ile des tempêtes
    -- 13: Creuset béni
    -- 14: Havre de Coeurnoir
    -- 15: Toile de Sélène
    -- 16: Chambres de la folie
    -- 17: Champignonnière II
    -- 18: Egouts d'Haltevoie II
    -- 19: Tour d'or blanc						DLC - 
    -- 20: Prison de la cité imprériale			DLC - 
    -- 21: Ruines de Mazzatun					DLC - 
    -- 22: Berceau des ombres					DLC - 
    -- 23: Le cachot iterdit II
    -- 24: Creuset des aînés II
    -- 25: Cavernes d'Ombre-noire II
    -- 26: Tressefuseau II
    -- 27: Crypte des coeurs II
    -- 28: Cité des cendres II
    -- 29: Forge de Sangracine					DLC - 
    -- 30: Forteresse d'Epervine				DLC - 
    -- 31: Pic de Mandécaille					DLC - 
    -- 32: Repaire du croc						DLC - 
	-- 33: Le fort du chasseur lunaire			DLC - 
	-- 34: Procession des sacrifiés				DLC
	-- 35: Arquegivre							DLC - 
	-- 36: Profondeurs de Malatar				DLC - 
	-- 37: Reliquaire des lunes funèbres		DLC - 
	-- 38: Repaire de Maarselok					DLC - 
	-- 39: Crève-Nève							DLC - 
	-- 40: Sépulcre profane						DLC - 
	-- 41: Jardin de pierre						DLC - 
	-- 42: Bastion-les-ronce					DLC - 
	-- 43: Villa du dragon noir					DLC - 
	-- 44: Le chaudron							DLC - 
	-- 45: Le bastion du pétale rouge			DLC - 
	-- 46: La cave d'effroi						DLC - 
	-- 47: Aire de corail						DLC - 
	-- 48: Regret du charpentier				DLC - 
	-- 49: Enclave des racines de la terre 		DLC - 
	-- 50: Profondeurs mortuaires				DLC - 
	-- 51: BAL SUNNAR							DLC - 
	-- 52: SALLES DU SCRIBE						DLC - 
	-- 53: Oathsworn Pit / Fosse aux fidèles
	-- 54: Bedlam Veil / Voile des fous
	-- 55: Exiled Redoubt / Redoute de l'Exil
	-- 56: Lep Seclusa
	-- 57: Naj-Caldeesh
	-- 58: Black Gem Foundry / Fonderie des Pierres noires

	local startTime = 1473055200
	local SECONDS_PER_DAY = 24 * 3600

	-- donjon A: Maj al-Ragath
	local pledgeCycleA = {26, 3, 17, 2, 25, 6, 18, 1, 23, 4, 24, 5}

	-- donjon B: Glirion 
	local pledgeCycleB = {10, 16, 27, 9, 12, 14, 7, 15, 28, 8, 11, 13}

	-- donjon dlc : Urgalarg 
	--APIVersion: 101035
	local pledgeCycleC = {40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 20, 21, 19, 22, 29, 30, 32, 31, 33, 34, 36, 35, 37, 38, 39}
	
	local now = GetTimeStamp()
	local diff = math.floor(GetDiffBetweenTimeStamps(now, startTime) / SECONDS_PER_DAY)
	dayOffset = tonumber(dayOffset)

	if(dayOffset) then
		diff = diff + dayOffset
	else
		dayOffset = 0
	end

	local currentStartTime = startTime + diff * SECONDS_PER_DAY
	local dateString = FormatAchievementLinkTimestamp(currentStartTime)
	local dayOffsetAbs = math.abs(dayOffset)
	local timeToStartString = FormatTimeBetween(now, currentStartTime)
	local timeToEndString = FormatTimeBetween(now, currentStartTime + SECONDS_PER_DAY)

	local dungeonA = "[" .. GetDungeonName(pledgeCycleA, diff) .. "]"
	local dungeonB = "[" .. GetDungeonName(pledgeCycleB, diff) .. "]"
	local dungeonC = "[" .. GetDungeonName(pledgeCycleC, diff) .. "]"

	if dayOffset == 0  then
		ODT_PledgesX = GetString(pledges_today) .. dungeonA .. "    " .. dungeonB .. "    " .. dungeonC
		ODT_PledgesJ = dungeonA .. "    " .. dungeonB .. "    " .. dungeonC
	elseif dayOffset == 1 then
		ODT_PledgesX = GetString(pledges_tomorrow) .. dungeonA .. "    " .. dungeonB .. "    " .. dungeonC		
	elseif dayOffset == 2 then
		ODT_PledgesX = GetString(pledges_after_tomorrow) .. dungeonA .. "    " .. dungeonB .. "    " .. dungeonC
	elseif dayOffset == -1 then
		ODT_PledgesX = GetString(pledges_yesterday) .. dungeonA .. "    " .. dungeonB .. "    " .. dungeonC
	elseif dayOffset == -2 then
		ODT_PledgesX = GetString(pledges_before_yesterday) .. dungeonA .. "    " .. dungeonB .. "    " .. dungeonC
	end

	ODT_PledgesA= "|cF346FFMaj al-Ragath : |cEDFF00" .. dungeonA
	ODT_PledgesB= "|cF346FFGlirion : |cEDFF00" .. dungeonB

	--ODT_PledgesC= "|cF346FFUrgalarg : |cEDFF00 séquence en cours de codage" 
	ODT_PledgesC= "|cF346FFUrgalarg : |cEDFF00" .. dungeonC
end

--*********************************************************************
-- Slash /ODT
--*********************************************************************
function ODT_SlashCommand(option)	
	---------------------------------------------------
	-- Vérifie que le joueur soit un membre ODT
	---------------------------------------------------
	if isODTMember == false then

		print ("|c94DE23[ODT]|cFF8174 Désolé, vous devez être membre de l'Orbe du Temps pour utiliser cette fonction.")
		print ("|c94DE23forum : http://orbedutemps.free.fr/forums/index.php")
		print("|c94DE23Contact IG : @blackdragon06")
		print("|c94DE23email : bldragon06@gmail.com")

		return
	end

	local options = {string.match(option,"^(%S*)%s*(.-)$")}

	------------------------------------------------------------
	-- Commandes /ODT
	------------------------------------------------------------
	if not option or option == "" then

		ODT_:SetHidden(false)
		ODT_Combox_State = 1

	else

		---------------------------------------------------
		-- Message de recrutement de guilde
		---------------------------------------------------
		if options[1] == "recrut" then

			if ODT_GuildRank  < 5 then

				print ("|c94DE23[ODT]|cEDFF00 Message de recrutement copié dans le chat. [Entrée] pour l'envoyer.")

				chattext = "L'Orbe du Temps recrute des francophones matures dans une guilde d'entraide, où respect et bonne ambiance sont de mise. Aucune contrainte ni obligation. Débutant(e)s accepté(e)s... /w " .. ODT_AccountName .. " pour invitation"
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)

			else

				print ("|c94DE23[ODT]|cFF8174 Cette fonction est réservée aux officiers")

			end

		---------------------------------------------------
		-- Message d'accueil en guilde
		---------------------------------------------------
		elseif options[1] == "bvnu" then

			if ODT_GuildRank  < 5  then

				print ("|c94DE23[ODT]|cEDFF00 Message d'accueil copié dans le chat. [Entrée] pour l'envoyer.")

				chattext = "Bienvenue dans l'Orbe du Temps. Si tu as des questions concernant la Guilde ou le jeu n'hésites pas à les poser en chan de guilde ou en vocal. Merci de consulter les REGLES sur le forum (http://orbedutemps.free.fr/forums/index.php) où tu trouveras un tas de choses utiles si tu es débutant.e"
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)

			else

				print ("|c94DE23[ODT]|cFF8174 Cette fonction est réservée aux officiers")

			end
		---------------------------------------------------
		-- non du donjon / index
		---------------------------------------------------
		elseif options[1] == "nomdonjon" then

			if ODT_GuildRank  < 5  then

				print ("|c94DE23[ODT]|cEDFF00 Message d'accueil copié dans le chat. [Entrée] pour l'envoyer.")

				--chattext = "Bienvenue dans l'Orbe du Temps. Si tu as des questions concernant la Guilde ou le jeu n'hésites pas à les poser en chan de guilde ou en vocal. Merci de consulter les REGLES sur le forum (http://orbedutemps.free.fr/forums/index.php) où tu trouveras un tas de choses utiles si tu es débutant.e"
				chattext = GetLFGOption(LFG_ACTIVITY_DUNGEON, options[2])
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)

			else

				print ("|c94DE23[ODT]|cFF8174 Cette fonction est réservée aux officiers")

			end
		---------------------------------------------------
		-- Adresse du forum
		---------------------------------------------------
		elseif options[1] == "forum" then

			print ("|c94DE23[ODT] forum → http://orbedutemps.free.fr/forums/index.php")

			if options[2] == "-c" then

			print ("|c94DE23[ODT]|cEDFF00 Adresse du forum copié dans le chat. [Entrée] pour l'envoyer.")
				chattext = "forum → http://orbedutemps.free.fr/forums/index.php"
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)
				end 

		---------------------------------------------------
		-- Adresse des règles
		---------------------------------------------------
		elseif options[1] == "regles" then

			print ("|c94DE23[ODT] Règles → http://orbedutemps.free.fr/forums/index.php?topic=2438.0")
			print ("|c94DE23[ODT] Règles → Forum de la Guilde > Elder Scrolls Online : la Guilde > Règles, Fonctionnement, Banque, Serveur Vocal > Règles de la guilde")

			if options[2] == "-c" then

				print ("|c94DE23[ODT]|cEDFF00 Règles copiées dans le chat. [Entrée] pour envoyer.")

				chattext = "Règles → Forum de la Guilde > Elder Scrolls Online : la Guilde > Règles, Fonctionnement, Banque, Serveur Vocal > Règles de la guilde"
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)

			end 

		---------------------------------------------------
		-- Code invitation discord
		---------------------------------------------------
		elseif options[1] == "discord" then

			print ("|c94DE23[ODT] discord → https://discord.gg/XCRQ8Je")

			if options[2] == "-c" then

				print ("|c94DE23[ODT]|cEDFF00 Code d'invitation discord copié dans le chat. [Entrée] pour l'envoyer.")
				chattext = "Code d'invitation discord  →  https://discord.gg/XCRQ8Je"
				ZO_ChatWindowTextEntryEditBox:SetText(chattext)
						   
			end 

		---------------------------------------------------
		-- Pledges
		---------------------------------------------------
		elseif options[1] == "pledges" or 
			  options[1] == "pledges+1" or
			  options[1] == "pledges+2" or
			  options[1] == "pledges-1" or
			  options[1] == "pledges-2"
		then
			dayOffset = 0
			if options[1] == "pledges+1" then
				dayOffset = 1
			end
			if options[1] == "pledges+2" then
				dayOffset = 2
			end 
			if options[1] == "pledges-1" then
				dayOffset = -1
			end 
			if options[1] == "pledges-2" then
				dayOffset = -2
			end 

			ODT_Pledges = (GetPledgesString(dayOffset))

			if options[2] == "-c" then
				ZO_ChatWindowTextEntryEditBox:SetText("(addon ODT) " .. ODT_PledgesX)	
			end

			if options[2] == "-g" then
				local MsgGuild = ODT_MsgGuild(ODTguildId, "cmd")
				print (GetString(dailiesupdated))
			end

			if dayOffset == 0  then
				print(GetString(cmd_pledges_today))
			elseif dayOffset == 1 then
				print(GetString(cmd_pledges_tomorrow))
			elseif dayOffset == 2 then
				print(GetString(cmd_pledges_after_tomorrow))
			elseif dayOffset == -1 then
				print(GetString(cmd_pledges_yesterday))
			elseif dayOffset == -2 then
				print(GetString(cmd_pledges_before_yesterday))
			end
			print(ODT_PledgesA)
			print(ODT_PledgesB)
			print(ODT_PledgesC)

		---------------------------------------------------
		-- Maison de guilde
		---------------------------------------------------
		elseif options[1] == "mdg" then
			JumpToHouse("@blackdragon06")

		---------------------------------------------------
		-- Version de l'addon
		---------------------------------------------------
		elseif options[1] == "v" then
			print ("|cFF6909addon ODT (" .. ODT.version .. ")")

		---------------------------------------------------
		-- Sauvegarde des couleurs de chat
		---------------------------------------------------
		elseif options[1] == "savechatcolors" then
			print ("Couleurs de chat sauvegardées")
			ODT.savedVariables.CHAT_CATEGORY_SAY_R, ODT.savedVariables.CHAT_CATEGORY_SAY_V, ODT.savedVariables.CHAT_CATEGORY_SAY_B = GetChatCategoryColor(CHAT_CATEGORY_SAY)
			ODT.savedVariables.CHAT_CATEGORY_YELL_R, ODT.savedVariables.CHAT_CATEGORY_YELL_V, ODT.savedVariables.CHAT_CATEGORY_YELL_B = GetChatCategoryColor(CHAT_CATEGORY_YELL)
			ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_R, ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_V, ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_B = GetChatCategoryColor(CHAT_CATEGORY_WHISPER_INCOMING)
			ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_R, ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_V, ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_B = GetChatCategoryColor(CHAT_CATEGORY_WHISPER_OUTGOING)
			ODT.savedVariables.CHAT_CATEGORY_PARTY_R, ODT.savedVariables.CHAT_CATEGORY_PARTY_V, ODT.savedVariables.CHAT_CATEGORY_PARTY_B = GetChatCategoryColor(CHAT_CATEGORY_PARTY)
			ODT.savedVariables.CHAT_CATEGORY_ZONE_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_B = GetChatCategoryColor(CHAT_CATEGORY_ZONE)
			ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_B = GetChatCategoryColor(CHAT_CATEGORY_ZONE_ENGLISH)
			ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_B = GetChatCategoryColor(CHAT_CATEGORY_ZONE_FRENCH)
			ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_B = GetChatCategoryColor(CHAT_CATEGORY_ZONE_GERMAN)
			ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_R, ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_V, ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_B = GetChatCategoryColor(CHAT_CATEGORY_MONSTER_SAY)
			ODT.savedVariables.CHAT_CATEGORY_EMOTE_R, ODT.savedVariables.CHAT_CATEGORY_EMOTE_V, ODT.savedVariables.CHAT_CATEGORY_EMOTE_B = GetChatCategoryColor(CHAT_CATEGORY_EMOTE)
			ODT.savedVariables.CHAT_CATEGORY_SYSTEM_R, ODT.savedVariables.CHAT_CATEGORY_SYSTEM_V, ODT.savedVariables.CHAT_CATEGORY_SYSTEM_B = GetChatCategoryColor(CHAT_CATEGORY_SYSTEM)
			ODT.savedVariables.CHAT_CATEGORY_GUILD_1_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_1_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_1_B = GetChatCategoryColor(CHAT_CATEGORY_GUILD_1)
			ODT.savedVariables.CHAT_CATEGORY_GUILD_2_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_2_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_2_B = GetChatCategoryColor(CHAT_CATEGORY_GUILD_2)
			ODT.savedVariables.CHAT_CATEGORY_GUILD_3_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_3_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_3_B = GetChatCategoryColor(CHAT_CATEGORY_GUILD_3)
			ODT.savedVariables.CHAT_CATEGORY_GUILD_4_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_4_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_4_B = GetChatCategoryColor(CHAT_CATEGORY_GUILD_4)
			ODT.savedVariables.CHAT_CATEGORY_GUILD_5_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_5_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_5_B = GetChatCategoryColor(CHAT_CATEGORY_GUILD_5)
			ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_B = GetChatCategoryColor(CHAT_CATEGORY_OFFICER_1)
			ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_B = GetChatCategoryColor(CHAT_CATEGORY_OFFICER_2)
			ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_B = GetChatCategoryColor(CHAT_CATEGORY_OFFICER_3)
			ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_B = GetChatCategoryColor(CHAT_CATEGORY_OFFICER_4)
			ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_B = GetChatCategoryColor(CHAT_CATEGORY_OFFICER_5)
			
		---------------------------------------------------
		-- Chargement des couleurs de chat
		---------------------------------------------------
		elseif options[1] == "loadchatcolors" then
			print ("Couleurs de chat chargées")
			SetChatCategoryColor(CHAT_CATEGORY_SAY, ODT.savedVariables.CHAT_CATEGORY_SAY_R, ODT.savedVariables.CHAT_CATEGORY_SAY_V, ODT.savedVariables.CHAT_CATEGORY_SAY_B);
			SetChatCategoryColor(CHAT_CATEGORY_YELL, ODT.savedVariables.CHAT_CATEGORY_YELL_R, ODT.savedVariables.CHAT_CATEGORY_YELL_V, ODT.savedVariables.CHAT_CATEGORY_YELL_B);
			SetChatCategoryColor(CHAT_CATEGORY_WHISPER_INCOMING, ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_R, ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_V, ODT.savedVariables.CHAT_CATEGORY_WHISPER_INCOMING_B);
			SetChatCategoryColor(CHAT_CATEGORY_WHISPER_OUTGOING, ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_R, ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_V, ODT.savedVariables.CHAT_CATEGORY_WHISPER_OUTGOING_B);
			SetChatCategoryColor(CHAT_CATEGORY_PARTY, ODT.savedVariables.CHAT_CATEGORY_PARTY_R, ODT.savedVariables.CHAT_CATEGORY_PARTY_V, ODT.savedVariables.CHAT_CATEGORY_PARTY_B);
			SetChatCategoryColor(CHAT_CATEGORY_ZONE , ODT.savedVariables.CHAT_CATEGORY_ZONE_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_B);
			SetChatCategoryColor(CHAT_CATEGORY_ZONE_ENGLISH, ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_ENGLISH_B);
			SetChatCategoryColor(CHAT_CATEGORY_ZONE_FRENCH, ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_FRENCH_B);
			SetChatCategoryColor(CHAT_CATEGORY_ZONE_GERMAN, ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_R, ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_V, ODT.savedVariables.CHAT_CATEGORY_ZONE_GERMAN_B);
			SetChatCategoryColor(CHAT_CATEGORY_MONSTER_SAY, ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_R, ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_V, ODT.savedVariables.CHAT_CATEGORY_MONSTER_SAY_B);
			SetChatCategoryColor(CHAT_CATEGORY_EMOTE, ODT.savedVariables.CHAT_CATEGORY_EMOTE_R, ODT.savedVariables.CHAT_CATEGORY_EMOTE_V, ODT.savedVariables.CHAT_CATEGORY_EMOTE_B);
			SetChatCategoryColor(CHAT_CATEGORY_SYSTEM, ODT.savedVariables.CHAT_CATEGORY_SYSTEM_R, ODT.savedVariables.CHAT_CATEGORY_SYSTEM_V, ODT.savedVariables.CHAT_CATEGORY_SYSTEM_B);
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_1, ODT.savedVariables.CHAT_CATEGORY_GUILD_1_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_1_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_1_B);
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_2, ODT.savedVariables.CHAT_CATEGORY_GUILD_2_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_2_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_2_B);
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_3, ODT.savedVariables.CHAT_CATEGORY_GUILD_3_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_3_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_3_B);
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_4, ODT.savedVariables.CHAT_CATEGORY_GUILD_4_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_4_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_4_B);
			SetChatCategoryColor(CHAT_CATEGORY_GUILD_5, ODT.savedVariables.CHAT_CATEGORY_GUILD_5_R, ODT.savedVariables.CHAT_CATEGORY_GUILD_5_V, ODT.savedVariables.CHAT_CATEGORY_GUILD_5_B);
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_1, ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_1_B);
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_2, ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_2_B);
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_3, ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_3_B);
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_4, ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_4_B);
			SetChatCategoryColor(CHAT_CATEGORY_OFFICER_5, ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_R, ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_V, ODT.savedVariables.CHAT_CATEGORY_OFFICER_5_B);

			
		---------------------------------------------------
		-- mail
		---------------------------------------------------
		elseif options[1] == "mail" then
			local aff = ODT_GuildMail_Show()

		---------------------------------------------------
		-- GM
		---------------------------------------------------
		elseif options[1] == "gm" then
			local aff = ODT_GuildMail_Show()
			if options[2] == "bjr" then
				ZO_ChatWindowTextEntryEditBox:SetText("{{  SALUT LA GUILDE  }}")
			end

		---------------------------------------------------
		-- TEST
		---------------------------------------------------
		elseif options[1] == "debug" then
			ODTDebug = 1
			
		---------------------------------------------------
		-- TEST
		---------------------------------------------------
		elseif options[1] == "test" then
print("test")
				ODT_MSG_XPSCROLL_CLOSE:SetAnchor(TOPRIGHT, ODT_MSGXPSCROLL, TOPRIGHT, -620, 5)			
				ODT_MSG_XPSCROLL_ICON:SetAnchor(TOPRIGHT, ODT_MSGXPSCROLL, TOPRIGHT, -620, 5)			
				ODT_XPSCROLL_SHOW(GetString(XPScroll_timer_msg), "esoui/art/icons/crafting_researchscrolls_allprofessions.dds", ODT_ShowXPSCROLL_POPDURATION)

		end
	end
end

--*********************************************************************
-- Horloge
--*********************************************************************
function ODT_ClockOnUpdate()
	if ODT_SettinsLoaded == 1 then
		local retVal, val, c = "", GetTimeString(), {215/255,213/255,205/255,1}
		local hh, mm, ss = val:match("([^:]+):([^:]+):([^:]+)")
		local ampm, del = " am", "|cA0A0CF:|r"
		ODT_ClocLbl:SetText(val)		
	end
	
end

--*********************************************************************
-- Chronomètre
--*********************************************************************
function ODT_ChronoOnUpdate()
	if ODT_SettinsLoaded == 1 then
		if ODT_Chrono_ONOFF == "ON" then
			local diff = math.abs(GetDiffBetweenTimeStamps(ODT_ChronoStart, GetTimeStamp()))
			local val = FormatTimeSeconds(diff)
			ODT_Chrono_Lbl:SetText(val)	
			ODT_Chrono_LblInfo:SetText(GetString(chrono_title))
			
		end
	end
end

	-------------------------------------------------------- 
	-- Chronomètre START
	-------------------------------------------------------- 
function ODT_ChronoStartCliked(control)
	if ODT_Chrono_ONOFF == "OFF" then
		ODT_ChronoStop:SetHidden(false)	
		ODT_ChronoStart = GetTimeStamp()
		ODT_Chrono_ONOFF = "ON"
	end
end

	-------------------------------------------------------- 
	-- Chronomètre STOP
	-------------------------------------------------------- 
function ODT_ChronoStopCliked(control)
	if ODT_Chrono_ONOFF == "ON" then
		ODT_ChronoStop:SetHidden(true)	
		ODT_Chrono_ONOFF = "OFF"
	end
end

--*********************************************************************
-- Timer
--*********************************************************************
function ODT_TimerOnUpdate()
	ODT_timer_LblInfo:SetText(GetString(timer_title))
	if ODT_SettinsLoaded == 1 then
		if ODT_Timer_ONOFF == "ON" then
			local diff = math.abs(GetDiffBetweenTimeStamps(ODT_timerStart, GetTimeStamp()))
			if GetTimeStamp() < ODT_timerStart then
				local val = FormatTimeSeconds(diff)
				ODT_timer_Lbl:SetText(val)	
			else
				ODT_timerStopCliked()
				ODT_timer_Lbl:SetText("0:00")			
				ODT_MSG_SHOW(GetString(timer_ended), ODT_Timer_SOUND)
			end
		end
	end
end

	-------------------------------------------------------- 
	-- Timer START
	-------------------------------------------------------- 
function ODT_timerStartCliked()
	if ODT_Timer_ONOFF == "OFF" then
		ODT_timerStop:SetHidden(false)	
		ODT_timerStart = GetTimeStamp() + ODT_Timer_Seconds
		ODT_Timer_ONOFF = "ON"
		ODT_TimerOnUpdate()		
	end
end

	-------------------------------------------------------- 
	-- Timer STOP
	-------------------------------------------------------- 
function ODT_timerStopCliked()
	if ODT_Timer_ONOFF == "ON" then
		ODT_timerStop:SetHidden(true)	
		ODT_Timer_ONOFF = "OFF"
	end
end
	
--*********************************************************************
-- FPS
--*********************************************************************
function ODT_PERF_FPSOnUpdate()
	local fpsLow = 30
	local fpsMid = 50
	
	ODT_PERF_FPS:SetColor(.5,1,0,1) --vert
	
	local framerate = GetFramerate()
		
	if framerate <= fpsMid and framerate > fpsLow then 
		ODT_PERF_FPS:SetColor(1,1,0,1) --jaune
	elseif 
		framerate <= fpsLow then
		ODT_PERF_FPS:SetColor(1,.5,0,1) --orange
	end
	if framerate < 11 then
		ODT_PERF_FPS:SetColor(1,0,0,1) --rouge
	end
	
	ODT_PERF_FPS:SetText(math.floor(framerate))
end

--*********************************************************************
-- PING
--*********************************************************************
function ODT_PERF_PINGOnUpdate()
	local latHigh = 300
	local latMid = 150
	
	local latency = GetLatency()	

	if latency < latMid then 
		ODT_PERF_PING:SetColor(.5,1,0,1) -- vert
	elseif latency >= latMid and latency < latHigh then 
		ODT_PERF_PING:SetColor(1,1,0,1) -- jaune
	elseif latency >= latHigh then 
		ODT_PERF_PING:SetColor(1,.5,0,1) -- orange
	end
	if latency > 999 then 
		ODT_PERF_PING:SetColor(1,0,0,1) -- rouge
	end

	ODT_PERF_PING:SetText(math.floor(latency))

end

--*********************************************************************
-- BAG : INVENTAIRE 
--*********************************************************************
function ODT_BagInfo()
	local bagSize, bagUsed, bagFree = GetBagSize(1), GetNumBagUsedSlots(1), GetNumBagFreeSlots(1)
	local bagPcent = (bagUsed / bagSize)*100
	local bagPcentStr = Round((bagUsed / bagSize)*100, 0) .. "%" 
	local gold = GetCurrentMoney()
	
	local bankgold = GetBankedMoney()
	local bankid = BAG_BANK
	local bankSize, bankUsed, bankFree = GetBagSize(bankid), GetNumBagUsedSlots(bankid), GetNumBagFreeSlots(bankid)
	local subbankid = BAG_SUBSCRIBER_BANK
	local subbankSize, subbankUsed, subbankFree = GetBagSize(subbankid), GetNumBagUsedSlots(subbankid), GetNumBagFreeSlots(subbankid)
	local totalBankUsed = bankUsed + subbankUsed
	local totalBankSize = bankSize + subbankSize
	SHOW_BANSPACE = totalBankUsed .. "/" .. totalBankSize
	
	local itemStolen = 0
	local itemLocked = 0
	StolenCurrentMoney = 0
	
	for id = 1, bagUsed, 1 do
		if IsItemStolen(1, id) == true then
  			itemStolen = itemStolen + 1
			local icon, stackCount, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(1, id)
			StolenCurrentMoney = StolenCurrentMoney + (sellPrice * stackCount)
		end
		if IsItemPlayerLocked(1, id) == true then
			itemLocked = itemLocked + 1
		end
	end

	if itemLocked ~= 0 and bagUsed ~= 0 then
		local bagLockedPcent = Round((itemLocked / bagUsed)*100, 0)
		ODT_BAG_LOCKED_PCENT:SetText(bagLockedPcent .. "%")
	else 
		ODT_BAG_LOCKED_PCENT:SetText("0%") 
	end
	
	-------------------------------------------------------- 
	-- Sac 
	-------------------------------------------------------- 
	local bagLow = 50
	local bagMid = 80

	if 	bagUsed == 100 then
		ODT_BAG_INVENTORY_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -135, 10)
	elseif 
		bagUsed > 9 then
		ODT_BAG_INVENTORY_PCENT:SetAnchor(TOPRIGHT, ODT_BAG , TOPRIGHT, -140,10)
	else
		ODT_BAG_INVENTORY_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -145, 10)
	end
	
	ODT_BAG_INVENTORY_PCENT:SetText(bagPcentStr)
	ODT_BAG_INVENTORY_PCENT:SetColor(1,.5,0,1)	
	if bagPcent <= bagMid then 
		ODT_BAG_INVENTORY_PCENT:SetColor(1,1,0,1)
	end
	if bagPcent <= bagLow then 
		ODT_BAG_INVENTORY_PCENT:SetColor(.5,1,0,1)
	end
	if bagPcent > 95 then 
		ODT_BAG_INVENTORY_PCENT:SetColor(1,0,0,1)
	end

	ODT_BAG_INVENTORY_NUMBERS:SetText(bagUsed .. "/" .. bagSize)
	SHOW_BAG_INVENTORY_NUMBERS = bagUsed .. "/" .. bagSize
	-------------------------------------------------------- 
	-- Objets volés
	-------------------------------------------------------- 
	bagStolenPcent = 0
	if itemStolen ~= 0 and bagUsed ~= 0 then
		bagStolenPcent = (itemStolen / bagUsed)*100
		local bagStolenPcentStr = Round((itemStolen / bagUsed)*100, 0) 
		ODT_BAG_STOLEN_PCENT:SetText(bagStolenPcentStr .. "%") 
	else 
		local bagStolenPcent = 0
		ODT_BAG_STOLEN_PCENT:SetText("0%") 
	end

	if 	bagStolenPcent == 100 then
		ODT_BAG_STOLEN_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -70, 10)
	elseif 
		bagStolenPcent > 9 then
		ODT_BAG_STOLEN_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -75, 10)
	else
		ODT_BAG_STOLEN_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -80, 10)
	end

	ODT_BAG_STOLEN_NUMBERS:SetText(itemStolen .. "/" .. bagUsed)
	SHOW_BAG_STOLEN_NUMBERS = itemStolen .. "/" .. bagUsed
	-------------------------------------------------------- 
	-- Objets verrouillés
	-------------------------------------------------------- 
	bagLockedPcentStr = 0
	if itemLocked ~= 0 and bagUsed ~= 0 then
		bagLockedPcent = (itemLocked / bagUsed)*100
		local bagLockedPcentStr = Round((itemLocked / bagUsed)*100, 0) 
		ODT_BAG_LOCKED_PCENT:SetText(bagLockedPcentStr .. "%") 
	else 
		local bagLockedPcent = 0
		ODT_BAG_LOCKED_PCENT:SetText("0%") 
	end
	if bagLockedPcent == nil then
		bagLockedPcent = 0
	end
	if 	bagLockedPcent == 100 then
		ODT_BAG_LOCKED_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -10, 10)
	elseif 
		bagLockedPcent > 9 then
		ODT_BAG_LOCKED_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -15, 10)
	elseif
		bagLockedPcent < 10 then
		ODT_BAG_LOCKED_PCENT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -20, 10)
	end

	ODT_BAG_LOCKED_NUMBERS:SetText(itemLocked .. "/" .. bagUsed)
	SHOW_BAG_LOCKED_NUMBERS = itemLocked .. "/" .. bagUsed
	-------------------------------------------------------- 
	-- Gold
	-------------------------------------------------------- 
	ODT_BAG_GOLD_AMOUNT:SetText(gold)
	if gold > 9999999 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -120, 38)
	elseif
		gold > 999999 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -125, 38)
	elseif
		gold > 99999 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -130, 38)
	elseif
		gold > 9999 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -135, 38)
	elseif
		gold > 999 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -140, 38)
	elseif
		gold > 99 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -145, 38)
	elseif
		gold > 9 then
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -150, 38)
	else
		ODT_BAG_GOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -155, 38)
	end

	-------------------------------------------------------- 
	-- Bank Gold
	-------------------------------------------------------- 

	ODT_BANGOLD_AMOUNT:SetText(bankgold)
	if bankgold > 9999999 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -30, 38)
	elseif
		bankgold > 999999 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -35, 38)
	elseif
		bankgold > 99999 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -40, 38)
	elseif
		bankgold > 9999 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -45, 38)
	elseif
		bankgold > 999 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -50, 38)
	elseif
		bankgold > 99 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -55, 38)
	elseif
		bankgold > 9 then
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -60, 38)
	else
		ODT_BANGOLD_AMOUNT:SetAnchor(TOPRIGHT, ODT_BAG, TOPRIGHT, -65, 38)
	end

	ODT_Stolen()
end

--*********************************************************************
-- VOL
--*********************************************************************
function ODT_Stolen() 

	if ODT.savedVariables.StolenDay == nil then
		ODT.savedVariables.StolenDay = "00/00/0000"
		ODT.savedVariables.StolenDayAmount = 0
	end 
	dDay = GetDateStringFromTimestamp(GetTimeStamp())		 

	if ODT.savedVariables.StolenDay ~= dDay then
		ODT.savedVariables.StolenDay = dDay
		ODT.savedVariables.StolenDayAmount = 0
	end

	StolenDayAmount	= ODT.savedVariables.StolenDayAmount 
	
    local totalSells, sellsUsed, sellsReset = GetFenceSellTransactionInfo()
	local hours   = math.floor( sellsReset / 3600 )
	local minutes = math.floor( ( sellsReset - ( hours * 3600 ) ) / 60 )
	sellsReset = string.format("%dh%dm", hours, minutes )
	
	local totalLaunders, laundersUsed, laundersReset = GetFenceLaunderTransactionInfo()
	local hours   = math.floor( laundersReset / 3600 )
	local minutes = math.floor( ( laundersReset - ( hours * 3600 ) ) / 60 )

	iconprint = zo_iconFormat("esoui/art/vendor/vendor_tabicon_fence_down.dds", 24, 24)		
	local StolenInfos = iconprint .. " [" .. dDay .. "] " .. StolenDayAmount .. "   "

	iconprint = zo_iconFormat("esoui/art/icons/item_generic_coinbag.dds", 24, 24)		
	local StolenInfos = StolenInfos .. iconprint .. " " .. StolenCurrentMoney .. "   "

	iconprint = zo_iconFormat("esoui/art/inventory/inventory_stolenitem_icon.dds", 24, 24)		
	local StolenInfos = StolenInfos .. iconprint .. " " .. sellsUsed .. "/" .. totalSells .. "   "
	
	iconprint = zo_iconFormat("esoui/art/vendor/vendor_tabicon_sell_down.dds", 24, 24)		
	local StolenInfos = StolenInfos .. iconprint .. " " .. laundersUsed .. "/" .. totalLaunders .. "   "
	
	iconprint = zo_iconFormat("esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds", 24, 24)		
	local StolenInfos = StolenInfos .. iconprint .. " " .. sellsReset
	local StolenInfosCenter = ""

	local length = string.len(StolenInfos)	
	for i=1,(340-length)/1.2 do
		StolenInfosCenter = StolenInfosCenter .. " "
	end
	local length = string.len(StolenInfosCenter)	
	
	ODT_STOLEN_INFOS:SetText(StolenInfosCenter .. StolenInfos)
	
	zo_callLater(function() ODT_Stolen() end, 10000)		
	
end


--*********************************************************************
-- BUFFS XP SCROLL
--*********************************************************************
 function ODT_XPSCROLLCheck() 

 	if ODT_ShowXPSCROLL == true then
 		zo_callLater(function() ODT_XPSCROLLCheck() end, 1000)		
		
		local UNIT_TAG_PLAYER = "player"
		local numBuffs = GetNumBuffs(UNIT_TAG_PLAYER)
		for buffIndex = 1, numBuffs do
			local buffName, startTime, endTime, buffSlot, stackCount, iconFile, unitTag, effectType, abilityType, statusEffectType = GetUnitBuffInfo(UNIT_TAG_PLAYER, buffIndex) 	
			local buffnamefood = { zo_strsplit("_", iconFile) }		
			local buffnametest = buffnamefood[2]
			
			if string.find(buffName, "Expérience accrue") or string.find(buffName, "Increased Experience") then			
				iconprint = zo_iconFormat(iconFile, 16, 16)		
			
				if ShowXPSCROLLMsgEvent == 2 then
					ShowXPSCROLLMsgEvent = 1
					return
				end

				local now = GetTimeStamp() 

				local diff = math.abs(GetDiffBetweenTimeStamps(endTime, startTime))
				local val = FormatTimeSeconds(diff)

				local btwn = FormatTimeBetween(endTime, startTime)
				local btwn = math.abs(endTime - (GetGameTimeMilliseconds() / 1000)) 
				EventODT_XPSCROLLTime = btwn / 60

				if EventODT_XPSCROLLTime > 0.15 then
					SendXPSCROLLMsg = 1
				else
					if ShowXPSCROLLMsgEvent == 1 and SendXPSCROLLMsg == 1 then
						SendXPSCROLLMsg = 0
						iconprint = zo_iconFormat(iconFile, 16, 16)		
						print("|c04D631[ODT] : " .. iconprint .. GetString(XPScroll_timer_msg) )

						ODT_MSG_XPSCROLL_CLOSE:SetAnchor(TOPRIGHT, ODT_MSGXPSCROLL, TOPRIGHT, -620, 5)			
						ODT_MSG_XPSCROLL_ICON:SetAnchor(TOPRIGHT, ODT_MSGXPSCROLL, TOPRIGHT, -620, 5)			
						ODT_XPSCROLL_SHOW(GetString(XPScroll_timer_msg), "esoui/art/icons/crafting_researchscrolls_allprofessions.dds", ODT_ShowXPSCROLL_POPDURATION)
					end
				end
			end
		end
	
	end
end
 
function ODT_XPSCROLL_HIDE()
	ODT_MSGXPSCROLL:SetHidden(true)
end

function ODT_XPSCROLL_SHOW(XPScrollMsg, XPScrollIcon, XPScrollDuration)
	ODT_MSG_XPSCROLL_NAME:SetText(XPScrollMsg)
	ODT_MSG_XPSCROLL_ICON:SetTexture(XPScrollIcon)
	ODT_MSGXPSCROLL:SetHidden(false)
	ODT_Playsound(ODT_ShowXPSCROLL_SOUND)
	
	if XPScrollDuration == 0 then
		ODT_MSG_XPSCROLL_CLOSE:SetHidden(false)
	else
		zo_callLater(function() ODT_XPSCROLL_HIDE() end, XPScrollDuration * 1000)	
	end
	
end


--*********************************************************************
-- BUFFS FOOD
--*********************************************************************
 function ODT_FoodCheck() 

 	if ODT_ShowFOOD == true then
		
		ODT_isFoodActive = false
		
		local UNIT_TAG_PLAYER = "player"
		local numBuffs = GetNumBuffs(UNIT_TAG_PLAYER)
		for buffIndex = 1, numBuffs do
			local buffName, startTime, endTime, buffSlot, stackCount, iconFile, unitTag, effectType, abilityType, statusEffectType = GetUnitBuffInfo(UNIT_TAG_PLAYER, buffIndex) 	
			local buffnamefood = { zo_strsplit("_", iconFile) }		
			local buffnametest = buffnamefood[2]
			
			if buffnamefood[1] == "/esoui/art/icons/crafting" or buffnamefood[1] == "/esoui/art/icons/event" then
  				if buffnamefood[2] ~= "leather" and buffnamefood[2] ~= "slaughterfish.dds" then
				
					if isODTMember == true and buffnamefood[2] ~= "cooking" and buffnamefood[2] ~= "midyear" then
						if ODTDebug == 1 then
							print("DEBUG buffName→ " .. buffName .. " →buffnamefood[1] " .. buffnamefood[1] .. " →buffnamefood[2] " .. buffnamefood[2])
						end
					end

					if ShowFoodMsgEvent == 2 then
						ShowFoodMsgEvent = 1
					end
					if ODT_ShowFoodMsg == 2 then			
						ShowFoodMsg	= 1
					end
					ODT_isFoodActive = true

					local now = GetTimeStamp() 
--					local val = FormatTimeSeconds(now)
					
--					local val = FormatTimeSeconds(startTime)

--					local val = FormatTimeSeconds(endTime)

					local diff = math.abs(GetDiffBetweenTimeStamps(endTime, startTime))
					local val = FormatTimeSeconds(diff)

					local btwn = FormatTimeBetween(endTime, startTime)
					local btwn = math.abs(endTime - (GetGameTimeMilliseconds() / 1000)) 
					if buffnamefood[2] == "cooking" then
						ODT_FoodTime = btwn / 60
					else
						EventODT_FoodTime = btwn / 60
					end

					SendFoodMsg = 0

					if ODT_FoodTime > ODT_ShowFOOD_TIME then
						ODT_ShowFoodMsg = 1
					else
						if ODT_ShowFoodMsg == 1 then
							ODT_ShowFoodMsg = 0
							SendFoodMsg = 1
						end
					end
					if EventODT_FoodTime > ODT_ShowFOOD_TIME then
						ShowFoodMsgEvent = 1
					else
						if ShowFoodMsgEvent == 1 then
							ShowFoodMsgEvent = 0
							SendFoodMsg = 1
						end
					end

					if SendFoodMsg == 1 then
						SendFoodMsg = 0
						iconprint = zo_iconFormat(iconFile, 16, 16)		
						print("|c04D631[ODT] : " .. iconprint .. GetString(food_timer_print) .. ODT_ShowFOOD_TIME .. " mn")

						if buffnamefood[2] ~= "leather" then
							ODT_MSG_FOOD_CLOSE:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -440, 5)			
							ODT_MSG_FOOD_ICON:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -440, 5)			
							ODT_FOOD_SHOW(GetString(food_timer_msg) .. ODT_ShowFOOD_TIME .. " mn", iconFile, ODT_ShowFOOD_POPDURATION)
						end
					end
				end
			end
		end
		
		if ODT_ShowFOOD_CHECKONLOAD == true and ODT_ShowFoodMsg == 2 and ODT_isFoodActive == false then
				iconprint = zo_iconFormat("esoui/art/icons/justice_stolen_food_001.dds", 16, 16)		
				print("|c04D631[ODT] : " .. iconprint .. " |cE6F702" .. GetString(food_ended_msg))

				ODT_MSG_FOOD_CLOSE:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -620, 5)			
				ODT_MSG_FOOD_ICON:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -620, 5)			
				ODT_FOOD_SHOW(GetString(food_ended_msg), "esoui/art/icons/justice_stolen_food_001.dds", 0)

				ODT_ShowFoodMsg = 1
		end
		
		
		if ODT_ShowFoodMsg == 1 then
			zo_callLater(function() ODT_FoodCheck() end, 10000)		
		else
			zo_callLater(function() ODT_FoodCheck() end, 1000)		
		end 
	end
end
 

function ODT_FOOD_HIDE()
	ODT_MSGFOOD:SetHidden(true)
end

function ODT_FOOD_SHOW(FoodMsg, FoodIcon, FoodDuration)
	ODT_MSG_FOOD_NAME:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -120, 10)
	if FoodMsg == "no food/drink" then
		ODT_MSG_FOOD_NAME:SetAnchor(TOPRIGHT, ODT_MSGFOOD, TOPRIGHT, -420, 10)
	end
	ODT_MSG_FOOD_NAME:SetText(FoodMsg)
	ODT_MSG_FOOD_ICON:SetTexture(FoodIcon)
	ODT_MSGFOOD:SetHidden(false)
	ODT_Playsound(ODT_ShowFOOD_SOUND)
	
	if FoodDuration == 0 then
		ODT_MSG_FOOD_CLOSE:SetHidden(false)
	else
		zo_callLater(function() ODT_FOOD_HIDE() end, ODT_ShowFOOD_POPDURATION * 1000)	
	end
end

--*********************************************************************
-- Changement de status de membre 
--*********************************************************************
function ODT_playerStatusChanged(_, guildId, accName, _, newStatus)

	odtShowStatus = 1

	------------------------------------------------------------
	-- N'affiche pas le message si le status change sur le compte lui-même
	------------------------------------------------------------
	if ODT_AccountName == accName then 
		odtShowStatus = 0
	end

	------------------------------------------------------------
	-- N'affiche pas le message si la guilde n'est pas sélectionnée
	------------------------------------------------------------
	if ODT_GM1 == false and guildId == ODT_GUILD1_ID then
		odtShowStatus = 0
	end
	if ODT_GM2 == false and guildId == ODT_GUILD2_ID then
		odtShowStatus = 0
	end
	if ODT_GM3 == false and guildId == ODT_GUILD3_ID then
		odtShowStatus = 0
	end
	if ODT_GM4 == false and guildId == ODT_GUILD4_ID then
		odtShowStatus = 0
	end
	if ODT_GM5 == false and guildId == ODT_GUILD5_ID then
		odtShowStatus = 0
	end

	------------------------------------------------------------
	-- Compose le message
	------------------------------------------------------------
	if odtShowStatus == 1 then
		------------------------------------------------------------
		-- Cherche l'index du membre 
		------------------------------------------------------------
		GuildMemberIndex = 0

		ODT_cptGuildMembers = GetNumGuildMembers(guildId)
		for ODT_MailMemberID=1,ODT_cptGuildMembers do
			local indexname  = GetGuildMemberInfo(guildId, ODT_MailMemberID)
			if accName == indexname then
				GuildMemberIndex = ODT_MailMemberID
			end
		end

		if GuildMemberIndex ~= 0 then
			------------------------------------------------------------
			-- Récupère les infos du perso
			------------------------------------------------------------
			local _, characterName, zoneName, classType, alliance, level, veteranRank = GetGuildMemberCharacterInfo(guildId, GuildMemberIndex)
			local charName = { zo_strsplit("^", characterName) }		
			
			odtcharName = charName[1]

			if alliance == 1 then
				allianceiconprint = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_aldmeri.dds", 16, 16)
			elseif alliance == 2 then
				allianceiconprint = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_ebonheart.dds", 16, 16)
			elseif alliance == 3 then
				allianceiconprint = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_daggerfall.dds", 16, 16)
			end
		end
		
		------------------------------------------------------------
		-- Message
		------------------------------------------------------------
		
		------------------------------------------------------------
		-- Horodatage
		------------------------------------------------------------
		local retVal, val, c = "", GetTimeString(), {215/255,213/255,205/255,1}
  		if ODT_GMHeure == true then
			StatusMsg = "|c848484[" .. val .. "] |cE6F702"
		else
			StatusMsg = "|cE6F702"
		end 
		------------------------------------------------------------
		-- Nom de guilde
		------------------------------------------------------------
		local guildName = GetGuildName(guildId)
		if ODT_GuildName == true then
			StatusMsg = StatusMsg .. "[" .. guildName .."]"
		end

		------------------------------------------------------------
		-- Icone status
		------------------------------------------------------------
		if newStatus == 1 then
			statusiconprint = zo_iconFormat("esoui/art/contacts/gamepad/gp_social_status_online.dds", 24, 24)
		elseif newStatus == 2 then
			statusiconprint = zo_iconFormat("esoui/art/contacts/gamepad/gp_social_status_afk.dds", 24, 24)
		elseif newStatus == 3 then
			statusiconprint = zo_iconFormat("esoui/art/contacts/gamepad/gp_social_status_dnd.dds", 24, 24)
		elseif newStatus == 4 then
			statusiconprint = zo_iconFormat("esoui/art/contacts/gamepad/gp_social_status_offline.dds", 24, 24)
		end

		------------------------------------------------------------
		-- Nom du @compte
		------------------------------------------------------------
		linkaccName = ZO_LinkHandler_CreateDisplayNameLink(accName)	
		StatusMsg = StatusMsg .. statusiconprint .. linkaccName
		
		------------------------------------------------------------
		-- Status | Alliance | Nom du perso
		------------------------------------------------------------
		if newStatus == 1 then
			StatusMsg = StatusMsg .. GetString(status_online)
			
			if ODT_GMCharacterName == true then
				StatusMsg = StatusMsg .. GetString(status_with)
				if ODT_GMAlliance == true then
					StatusMsg = StatusMsg .. allianceiconprint .. " "
				end
				StatusMsg = StatusMsg .. odtcharName
			end
		elseif newStatus == 2 then
			StatusMsg = StatusMsg .. GetString(status_afk)
		elseif newStatus == 3 then
			StatusMsg = StatusMsg .. GetString(status_npd)
		elseif newStatus == 4 then
			StatusMsg = StatusMsg .. GetString(status_offline)
		end

		print(StatusMsg)
		ODT_Playsound(ODT_GMSound) 
	end
end


--*********************************************************************
-- NoFade Window Channel
--*********************************************************************
function ODT_NoFadeDisableFading()
	if ODT_SettinsLoaded == 1 and ODT_CustomChatPerma == true then
		local numWindows = ZO_ChatWindowWindowContainer:GetNumChildren()
		for i=1,numWindows do
			local window = ZO_ChatWindowWindowContainer:GetChild(i)
			local buffer = window["buffer"]
			buffer:SetLineFade(604800, 1) -- 604800 = 60*60*24*7, number of seconds in a week
  			ODT.chanbuffer[i] = buffer
		end
	end
end

--*********************************************************************
-- CHAT MESSAGE
--*********************************************************************
function ODT_chatMessageChannel(eventCode, messageType, fromName, messageText, isCustomerService)
	ODT_NoFadeDisableFading()
	
	if fromName ~= ODT_AccountName then
		if     messageType == 0 then
			ODT_Playsound(ODT_Notif_Say) 
		elseif messageType == 1 then
			ODT_Playsound(ODT_Notif_Yell) 
		elseif messageType == 2 then
			ODT_Playsound(ODT_Notif_Tell) 
		elseif messageType == 3 then
			ODT_Playsound(ODT_Notif_Party) 
		elseif messageType == 4 then
			-- → Whisp 
			local donothing = true
		elseif messageType == 7 then
			-- PNJ
			local donothing = true
		elseif messageType == 8 then
			-- PNJ
			local donothing = true
		elseif messageType == 9 then
			-- PNJ
			local donothing = true
		elseif messageType == 36 then
			-- PNJ
			local donothing = true
		elseif messageType == 31 then
			ODT_Playsound(ODT_Notif_Z) 
		elseif messageType == 32 then
			ODT_Playsound(ODT_Notif_ZEN) 
		elseif messageType == 33 then
			ODT_Playsound(ODT_Notif_ZFR) 
		elseif messageType == 34 then
			ODT_Playsound(ODT_Notif_ZDE) 
		elseif messageType == 35 then
			ODT_Playsound(ODT_Notif_ZJP) 
		elseif messageType == 12 then
			ODT_Playsound(ODT_Notif_G1) 
		elseif messageType == 13 then
			ODT_Playsound(ODT_Notif_G2) 
		elseif messageType == 14 then
			ODT_Playsound(ODT_Notif_G3) 
		elseif messageType == 15 then
			ODT_Playsound(ODT_Notif_G4) 
		elseif messageType == 16 then
			ODT_Playsound(ODT_Notif_G5) 
		elseif messageType == 17 then
			ODT_Playsound(ODT_Notif_G1OFF) 
		elseif messageType == 18 then
			ODT_Playsound(ODT_Notif_G2OFF) 
		elseif messageType == 19 then
			ODT_Playsound(ODT_Notif_G3OFF) 
		elseif messageType == 20 then
			ODT_Playsound(ODT_Notif_G4OFF) 
		elseif messageType == 21 then
			ODT_Playsound(ODT_Notif_G5OFF) 
		else
			print("eventCode→" .. eventCode .. "   messageType→" .. messageType)
		end
	end
end

--*********************************************************************
-- CUSTOM CHAT
--*********************************************************************
local function ODT_FormatMessage(chanCode, from, text)
	local channelInfo = ZO_ChatSystem_GetChannelInfo()[chanCode]
	------------------------------------------------------------
	-- Horodatage
	------------------------------------------------------------
	local CustomChatDate = GetDateStringFromTimestamp(GetTimeStamp())		 	
	local retVal, val, c = "", GetTimeString(), {215/255,213/255,205/255,1}
	local CustomChatTime =  val 
	
	CustomChatDateTime = ""
	if ODT_CustomChatDate == true or ODT_CustomChatTime == true then
		
		 CustomChatDateTime = "|c848484["	
		
		if ODT_CustomChatDate == true then
				CustomChatDateTime = CustomChatDateTime .. CustomChatDate
			if ODT_CustomChatTime == true then	
				CustomChatDateTime = CustomChatDateTime .. " "
			end
		end
		if ODT_CustomChatTime == true then	
			CustomChatDateTime = CustomChatDateTime .. CustomChatTime
		end
		
		CustomChatDateTime = CustomChatDateTime .. "]|r"
	end
		
	------------------------------------------------------------
	-- Chan
	------------------------------------------------------------
	if     chanCode == 0 then
		CustomChatChan = GetString(CustomChatChan0)
	elseif chanCode == 1 then
		CustomChatChan =  GetString(CustomChatChan1)
	elseif chanCode == 2 then
		CustomChatChan =  GetString(CustomChatChan2)
	elseif chanCode == 3 then
		CustomChatChan =  GetString(CustomChatChan3)
	elseif chanCode == 4 then
		CustomChatChan =  GetString(CustomChatChan4)
	elseif chanCode == 7 then
		CustomChatChan =  GetString(CustomChatChan7)
	elseif chanCode == 8 then
		CustomChatChan =  GetString(CustomChatChan8)
	elseif chanCode == 9 then
		CustomChatChan =  GetString(CustomChatChan9)
	elseif chanCode == 31 then
		CustomChatChan =  GetString(CustomChatChan31)
	elseif chanCode == 32 then
		CustomChatChan =  GetString(CustomChatChan32)
	elseif chanCode == 33 then
		CustomChatChan =  GetString(CustomChatChan33)
	elseif chanCode == 34 then
		CustomChatChan =  GetString(CustomChatChan34)
	elseif chanCode == 35 then
		CustomChatChan =  GetString(CustomChatChan35)
	end

	guildId = 0
	if chanCode > 11 and chanCode < 17 then
			guildId = GetGuildId(chanCode -11)
	end
	if chanCode > 16 and chanCode < 22 then
		guildId = GetGuildId(chanCode -16)
	end
	if guildId > 0 then
		local guildName = GetGuildName(guildId)
		CustomChatChan = "[" .. guildName .. "]"
	end
	
	if ODT_CustomChatChan == false then
		CustomChatChan = ""
	end 

	CustomChatAccount = ""
	CustomChatName = ""
	CustomChatLvl = "" 
	CustomChatAlliance = ""
	CustomChatClasse = "" 
	
	------------------------------------------------------------
	-- Nom du compte | Nom du perso 
	------------------------------------------------------------
	if string.find(from, "@") then
		------------------------------------------------------------
		-- Le chan contient le @nomducompte
		------------------------------------------------------------
		CustomChatAccount = from
		CustomChatSearch =  1
	else
		------------------------------------------------------------
		-- Le chan contient le nomduperso^
		------------------------------------------------------------
		local charName = { zo_strsplit("^", from) }
		CustomChatName = charName[1]
		CustomChatSearch =  2
	end

	------------------------------------------------------------
	-- Cherche l'index du membre dans une guilde
	------------------------------------------------------------
	GuildMemberIndex = 0
	CustomChatFound = false
	
	------------------------------------------------------------
	-- Boucle guildes
	------------------------------------------------------------
	for i=1,GetNumGuilds() do
		guildId = GetGuildId(i)

		GuildMemberIndex = 0
		
		ODT_cptGuildMembers = GetNumGuildMembers(guildId)
		
		------------------------------------------------------------
		-- Boucle membres
		------------------------------------------------------------
		for ODT_MailMemberID=1,ODT_cptGuildMembers do

			local indexname = GetGuildMemberInfo(guildId, ODT_MailMemberID)
			local _, characterName, zoneName, classType, alliance, level, veteranRank = GetGuildMemberCharacterInfo(guildId, ODT_MailMemberID)
			
			if CustomChatSearch == 1 and from == indexname then
				GuildMemberIndex = ODT_MailMemberID
				CustomChatFound = true
			end
			if CustomChatSearch == 2 and from == characterName then
				GuildMemberIndex = ODT_MailMemberID
				CustomChatAccount = indexname
				CustomChatFound = true
			end

			------------------------------------------------------------
			-- Si le membre a été trouvé
			------------------------------------------------------------
			if GuildMemberIndex ~= 0 then
				------------------------------------------------------------
				-- Récupère les infos du perso
				------------------------------------------------------------
				local _, characterName, zoneName, classType, alliance, level, veteranRank = GetGuildMemberCharacterInfo(guildId, GuildMemberIndex)
				local charName = { zo_strsplit("^", characterName) }		
				
			
				------------------------------------------------------------
				-- Nom du perso
				------------------------------------------------------------
				CustomChatName = charName[1]

				------------------------------------------------------------
				-- Lvl du perso
				------------------------------------------------------------
				if level == 50 then
					CustomChatLvl = "[vet " .. veteranRank .. "] "
				else
					CustomChatLvl = "[lvl " .. level .. "] "
				end 
				------------------------------------------------------------
				-- Classe du perso
				------------------------------------------------------------
				CustomChatClasse = classType
				if     classType == 1 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_dragonknight.dds", 16, 16)
				elseif classType == 2 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_sorcerer.dds", 16, 16)
				elseif classType == 3 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_nightblade.dds", 16, 16)
				elseif classType == 4 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_warden.dds", 16, 16)
				elseif classType == 5 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_necro.dds", 16, 16)
				elseif classType == 6 then
					CustomChatClasse = zo_iconFormat("esoui/art/icons/class/gamepad/gp_class_templar.dds", 16, 16)
				end

				------------------------------------------------------------
				-- Alliance du perso
				------------------------------------------------------------
				if alliance == 1 then
					CustomChatAlliance = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_aldmeri.dds", 16, 16)
				elseif alliance == 2 then
					CustomChatAlliance = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_ebonheart.dds", 16, 16)
				elseif alliance == 3 then
					CustomChatAlliance = zo_iconFormat("esoui/art/tutorial/gamepad/gp_overview_allianceicon_daggerfall.dds", 16, 16)
				end
			end
		end
	end
	
	------------------------------------------------------------
	-- Link @compte / perso
	------------------------------------------------------------
	if channelInfo.channelLinkable then
		if CustomChatAccount ~= nil and CustomChatAccount ~= "" then
			CustomChatAccount = ZO_LinkHandler_CreateDisplayNameLink(CustomChatAccount)	

			CustomChatName = "[" .. CustomChatName .. "]"
			if ODT_CustomChatName == false then
				CustomChatName = ""
			end
		else
			if CustomChatName ~= nil then
				CustomChatAccount = "[" .. CustomChatAccount .. "]"
				CustomChatName = ZO_LinkHandler_CreateCharacterLink(CustomChatName)	
			end
		end 
	else
		if chanCode == 31 or chanCode == 32 or chanCode == 33 or chanCode == 34 or chanCode == 4 or chanCode == 3 or chanCode == 2 or chanCode == 1 or chanCode == 0 then
			CustomChatAccount = "[" .. CustomChatAccount .. "]"
			CustomChatName = ZO_LinkHandler_CreateCharacterLink(CustomChatName)
		else 
			CustomChatAccount = ZO_LinkHandler_CreateDisplayNameLink(CustomChatAccount)	
			CustomChatName = ""
		end
 	end 

	if CustomChatAccount == "[]" or CustomChatAccount == "[] " then
		CustomChatAccount = ""
	end
	
	if CustomChatName == "[]" or CustomChatName == "[] " then
		CustomChatName = ""
	end
	
	------------------------------------------------------------
	-- Lvl du perso
	------------------------------------------------------------
	if ODT_CustomChatLvl == false then
		CustomChatLvl = "" 
	end

	------------------------------------------------------------
	-- Alliance du perso
	------------------------------------------------------------
	if ODT_CustomChatAlliance == false then
		CustomChatAlliance = ""
	end

	------------------------------------------------------------
	-- Classe du perso
	------------------------------------------------------------
	if ODT_CustomChatClasse	== false then
		CustomChatClasse = "" 
	end

	------------------------------------------------------------
	-- Formate les infos du personnage
	------------------------------------------------------------
	if ODT_CustomChatPersoInfos == false then
		CustomChatName = ""
		CustomChatLvl = "" 
		CustomChatAlliance = ""
		CustomChatClasse = "" 
	end 

	------------------------------------------------------------
	-- Retourne le message en Chat
	------------------------------------------------------------
	if CustomChatChan  == " PNJ " or CustomChatChan  == " NPC " then
		local charName = { zo_strsplit("^", from) }		
		message = CustomChatDateTime .. "[" .. charName[1] .. "] : " .. text
	else
		message = CustomChatDateTime .. CustomChatChan .. CustomChatAccount .. CustomChatName .. CustomChatLvl .. CustomChatAlliance .. CustomChatClasse .. " : " .. text
	end

    --CopyToTextEntry(message)
   
	return message
end

--*********************************************************************
-- MONTURE
--*********************************************************************
function ODT_HorseTimer()
	if ODT_HORSE_SHOWPERMA == true then
		ODT_HorseShow:SetHidden(false)
	else
		ODT_HorseShow:SetHidden(true)
	end

	ODT_HorseShow_BG:SetHidden(ODT_HORSE_SHOWBG)
	
	if ODT_HORSE == true then
		
		local mountFeedTimer, mountFeedTotalTime = GetTimeUntilCanBeTrained()

		if mountFeedTimer ~= nil then
			if mountFeedTimer == 0 then
				local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
				if inventoryBonus ~= maxInventoryBonus or staminaBonus ~= maxStaminaBonus or speedBonus ~= maxSpeedBonus then
					ODT_MSG_HORSE_CLOSE:SetAnchor(TOPRIGHT, ODT_MSGHORSE, TOPRIGHT, -620, 5)			
					ODT_MSG_HORSE_ICON:SetAnchor(TOPRIGHT, ODT_MSGHORSE, TOPRIGHT, -620, 5)			
					ODT_HorseShow_Timer:SetText(GetString(horse_timer_ended))

					if ODT_HORSE_CHECKONLOAD == true and ODT_HORSE_CHECKONLOAD_MSG == true then
						ODT_HORSE_SHOW(GetString(horse_msg_ended), "esoui/art/icons/mapkey/mapkey_stables.dds", 0)
						ODT_HORSE_CHECKONLOAD_MSG = false
					else
						ODT_HORSE_SHOW(GetString(horse_msg_ended), "esoui/art/icons/mapkey/mapkey_stables.dds", ODT_HORSE_SHOWTIME)
					end
					iconprint = zo_iconFormat("esoui/art/icons/mapkey/mapkey_stables.dds", 24, 24)
					print("|c04D631[ODT] : " .. iconprint .. " |cE6F702" .. GetString(horse_msg_ended))
				else
					ODT_HorseShow:SetHidden(true)
				end
			elseif mountFeedTimer > 0 then
				local hours   = math.floor( mountFeedTimer / 3600000 )
				local minutes = math.floor( ( mountFeedTimer - ( hours * 3600000 ) ) / 60000 )

				ODT_HorseShow_Update = 60000
				zo_callLater(function() ODT_HorseTimer() end, 60000)

				mountFeedMessage = string.format("%dh%dm", hours, minutes )
				ODT_HorseShow_Timer:SetText(mountFeedMessage)
			end
		end
	end
end 

function ODT_HORSE_SHOW(HORSEMsg, HORSEIcon, HORSEDuration)
	ODT_MSG_HORSE_NAME:SetText(HORSEMsg)
	ODT_MSG_HORSE_ICON:SetTexture(HORSEIcon)
	ODT_MSGHORSE:SetHidden(false)
	ODT_Playsound(ODT_HORSE_SOUND)
	
	if HORSEDuration == 0 then
		ODT_MSG_HORSE_CLOSE:SetHidden(false)
	else
		zo_callLater(function() ODT_HORSE_HIDE() end, HORSEDuration * 1000)	
	end
end
function ODT_HORSE_HIDE()
	ODT_MSGHORSE:SetHidden(true)
end

--*********************************************************************
-- TESTS
--*********************************************************************
function ODT_OnLootReceived()
print("ODT_OnLootReceived")
end
function ODT_OnLootClosed()
print("ODT_OnLootClosed")
end
function ODT_ActionLayerChanged()
print("ODT_ActionLayerChanged")
end
function ODT_ActionLayerPushed()
print("ODT_ActionLayerPushed")
end
function ODT_ActionLayerPopped()
print("ODT_ActionLayerPopped")
end
--*********************************************************************
-- UI ERROR
--*********************************************************************
function ODT_OnUIError(event, error_output)
	ZO_UIErrors_HideCurrent()
 	ZO_UIErrors:SetAlpha(0)	
end

--*********************************************************************
-- Application des paramètres
--*********************************************************************
local function ApplySettings() 
--	local LAM = LibStub("LibAddonMenu-2.0")
	local LAM = LibAddonMenu2
	--------------------------------------------------------
	-- Horloge
	--------------------------------------------------------
	if ODT_ShowClock == true then
		ODT_Clock:SetHidden(false)
	elseif ODT_ShowClock == false then
		ODT_Clock:SetHidden(true)
	end

	clocframex = 70
	clocframey = 50

	local fz = "$(MEDIUM_FONT)|" .. ODT_ShowClockFontSize
	ODT_ClocLbl:SetFont(fz)

	if     ODT_ShowClockFontSize == 12 then
			clocframex = 70
			clocframey = 50
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
		elseif ODT_ShowClockFontSize == 16 then
			clocframex = 70
			clocframey = 50
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
		elseif ODT_ShowClockFontSize == 20 then
			clocframex = 80
			clocframey = 50
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
		elseif ODT_ShowClockFontSize == 24 then
			clocframex = 90
			clocframey = 50
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
		elseif ODT_ShowClockFontSize == 28 then
			clocframex = 100
			clocframey = 65
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
		elseif ODT_ShowClockFontSize == 32 then
			clocframex = 130
			clocframey = 70
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
		elseif ODT_ShowClockFontSize == 36 then
			clocframex = 140
			clocframey = 75
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
		elseif ODT_ShowClockFontSize == 40 then
			clocframex = 155
			clocframey = 80
			ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
	end
	
	ODT_Clock:SetDimensions(clocframex, clocframey)
	
	ODT_ClocBG:SetDimensions(clocframex, clocframey)
	ODT_ClocBG:SetHidden(ODT_ShowClockBG)

	if ODT_ShowClockFontColor == "|cFFFFFFBlanc" then
		ODT_ClocLbl:SetColor(1,1,1)

	elseif ODT_ShowClockFontColor == "|cE6F702Jaune" then
		ODT_ClocLbl:SetColor(1,1,0)
		
	elseif ODT_ShowClockFontColor == "|c04D631Vert" then
		ODT_ClocLbl:SetColor(.5,1,0,1)
		
	elseif ODT_ShowClockFontColor == "|cF2AE04Orange" then
		ODT_ClocLbl:SetColor(1,.5,0,1)
		
	end

	--------------------------------------------------------
	-- Chronomètre
	--------------------------------------------------------
	if ODT_ShowChrono == true then
		ODT_Chrono:SetHidden(false)
	else
		ODT_Chrono:SetHidden(true)
	end

	Chrono_framex = 145
	Chrono_framey = 60

	local fz = "$(MEDIUM_FONT)|" .. ODT_ShowChronoFontSize
	ODT_Chrono_Lbl:SetFont(fz)

	if ODT_ShowChronoFontSize > 20 then
		if ODT_ShowChronoFontSize == 24 then
			Chrono_framex = 145
			Chrono_framey = 65
		elseif ODT_ShowChronoFontSize == 28 then
			Chrono_framex = 145
			Chrono_framey = 70
		elseif ODT_ShowChronoFontSize == 32 then
			Chrono_framex = 145
			Chrono_framey = 75
		elseif ODT_ShowChronoFontSize == 36 then
			Chrono_framex = 145
			Chrono_framey = 80
		elseif ODT_ShowChronoFontSize == 40 then
			Chrono_framex = 145
			Chrono_framey = 85
		end
	end
	
	ODT_Chrono:SetDimensions(Chrono_framex, Chrono_framey)
	
	ODT_Chrono_BG:SetDimensions(Chrono_framex, Chrono_framey)
	ODT_Chrono_BG:SetHidden(ODT_ShowChronoBG)
	
	if ODT_ShowChronoFontColor == "|cFFFFFFBlanc" then
		ODT_Chrono_Lbl:SetColor(1,1,1)

	elseif ODT_ShowChronoFontColor == "|cE6F702Jaune" then
		ODT_Chrono_Lbl:SetColor(1,1,0)
		
	elseif ODT_ShowChronoFontColor == "|c04D631Vert" then
		ODT_Chrono_Lbl:SetColor(.5,1,0,1)
		
	elseif ODT_ShowChronoFontColor == "|cF2AE04Orange" then
		ODT_Chrono_Lbl:SetColor(1,.5,0,1)
		
	end

	--------------------------------------------------------
	-- Timer
	--------------------------------------------------------
	if ODT_ShowTimer == true then
		ODT_timer:SetHidden(false)
	else
		ODT_timer:SetHidden(true)
	end

	Timer_framex = 145
	Timer_framey = 60

	local fz = "$(MEDIUM_FONT)|" .. ODT_ShowTimerFontSize
	ODT_timer_Lbl:SetFont(fz)

	if ODT_ShowTimerFontSize > 20 then
		if ODT_ShowTimerFontSize == 24 then
			Timer_framex = 145
			Timer_framey = 65
		elseif ODT_ShowTimerFontSize == 28 then
			Timer_framex = 145
			Timer_framey = 70
		elseif ODT_ShowTimerFontSize == 32 then
			Timer_framex = 145
			Timer_framey = 75
		elseif ODT_ShowTimerFontSize == 36 then
			Timer_framex = 145
			Timer_framey = 80
		elseif ODT_ShowTimerFontSize == 40 then
			Timer_framex = 145
			Timer_framey = 85
		end
	end
	
	ODT_timer:SetDimensions(Timer_framex, Timer_framey)
	
	ODT_timer_BG:SetDimensions(Timer_framex, Timer_framey)
	ODT_timer_BG:SetHidden(ODT_ShowTimerBG)
	
	if ODT_ShowTimerFontColor == "|cFFFFFFBlanc" then
		ODT_timer_Lbl:SetColor(1,1,1)

	elseif ODT_ShowTimerFontColor == "|cE6F702Jaune" then
		ODT_timer_Lbl:SetColor(1,1,0)
		
	elseif ODT_ShowTimerFontColor == "|c04D631Vert" then
		ODT_timer_Lbl:SetColor(.5,1,0,1)
		
	elseif ODT_ShowTimerFontColor == "|cF2AE04Orange" then
		ODT_timer_Lbl:SetColor(1,.5,0,1)
		
	end

	--------------------------------------------------------
	-- Performances
	--------------------------------------------------------
	if ODT_ShowPERF == true then
		ODT_PERF:SetHidden(false)
	else
		ODT_PERF:SetHidden(true)
	end

	ODT_PERF_BG:SetHidden(ODT_ShowPERFBG)

	--------------------------------------------------------
	-- Inventaire
	--------------------------------------------------------
	if ODT_ShowBag == true then
		ODT_BAG:SetHidden(false)
	else
		ODT_BAG:SetHidden(true)
	end

	ODT_BAG_BG:SetHidden(ODT_ShowBagBG)
	
	--------------------------------------------------------
	-- Armes & Armure
	--------------------------------------------------------
	if ODT_WA_ONOFF == true then
		ODT_WA:SetHidden(false)
	else
		ODT_WA:SetHidden(true)
	end

	ODT_WA_BG:SetHidden(ODT_WABG)
	
	--------------------------------------------------------
	-- Monture
	--------------------------------------------------------
	ODT_HorseShow:SetHidden(true)
	if ODT_HORSE == true then
		zo_callLater(function() ODT_HorseTimer() end, 1000)
		if ODT_HORSE_SHOWPERMA == true then
			ODT_HorseShow:SetHidden(false)
		end
	end

	-----------------------------------------------------
	-- VOL
	-----------------------------------------------------
	if ODT_ShowStolen == true then
		ODT_STOLEN:SetHidden(false)
	else
		ODT_STOLEN:SetHidden(true)
	end

	ODT_STOLEN_BG:SetHidden(ODT_ShowStolenBG)
	
	--------------------------------------------------------
	-- BackGround
	--------------------------------------------------------
	ODT_BackGround()

	--------------------------------------------------------
	-- BackGround
	--------------------------------------------------------
	if ODT_LOCKWINDOWS == true then
		ODT_Clock:SetMovable(false)
		ODT_Chrono:SetMovable(false)
		ODT_timer:SetMovable(false)
		ODT_PERF:SetMovable(false)
		ODT_BAG:SetMovable(false)
		ODT_WA:SetMovable(false)
		ODT_HorseShow:SetMovable(false)
		ODT_BG:SetMovable(false)
		ODT_STOLEN:SetMovable(false)
	else
		ODT_Clock:SetMovable(true)
		ODT_Chrono:SetMovable(true)
		ODT_timer:SetMovable(true)
		ODT_PERF:SetMovable(true)
		ODT_BAG:SetMovable(true)
		ODT_WA:SetMovable(true)
		ODT_HorseShow:SetMovable(true)
		ODT_BG:SetMovable(true)
		ODT_STOLEN:SetMovable(true)
	end

	-----------------------------------------------------
	-- Hide in combat
	-----------------------------------------------------
	if ODT_HideCombat_GLOBAL == true then
		ODT_HideCombat_BG = true
		ODT_HideCombat_CLOCK = true
		ODT_HideCombat_CHRONO = true
		ODT_HideCombat_TIMER = true
		ODT_HideCombat_PERF = true
		ODT_HideCombat_INVENTORY = true
		ODT_HideCombat_STATS = true
		ODT_HideCombat_HORSE = true
		ODT_HideCombat_STOLEN = true
	end
end

--*********************************************************************
-- Chargement des variables du Control Panel (Settings)
--*********************************************************************
function ODT_LoadSettings()

	ODT_ChronoStart = GetTimeStamp()
	
--	ODT.savedVariables = ZO_SavedVars:New("ODTAddonSavedVariables", 1, nil, {})	
	ODT.savedVariables = ZO_SavedVars:NewAccountWide("ODTAddonSavedVariables", 1, nil, {})	

	if ODT.savedVariables.ShowClock  == nil or ODT.savedVariables.ShowClock == "" then
		CreateDefaultSettings()
		return
	else
		-----------------------------------------------------
		-- Hide in combat
		-----------------------------------------------------
		if ODT.savedVariables.HideCombat_GLOBAL == nil or ODT.savedVariables.HideCombat_GLOBAL == "" then
			ODT.savedVariables.HideCombat_GLOBAL = false
			ODT.savedVariables.HideCombat_BG = false
			ODT.savedVariables.HideCombat_CLOCK = false
			ODT.savedVariables.HideCombat_CHRONO = false
			ODT.savedVariables.HideCombat_TIMER = false
			ODT.savedVariables.HideCombat_PERF = false
			ODT.savedVariables.HideCombat_INVENTORY = false
			ODT.savedVariables.HideCombat_STATS = false
			ODT.savedVariables.HideCombat_HORSE = false
			ODT.savedVariables.HideCombat_STOLEN = false
		end
		ODT_HideCombat_GLOBAL = ODT.savedVariables.HideCombat_GLOBAL
		ODT_HideCombat_BG = ODT.savedVariables.HideCombat_BG
		ODT_HideCombat_CLOCK = ODT.savedVariables.HideCombat_CLOCK
		ODT_HideCombat_CHRONO = ODT.savedVariables.HideCombat_CHRONO
		ODT_HideCombat_TIMER = ODT.savedVariables.HideCombat_TIMER
		ODT_HideCombat_PERF = ODT.savedVariables.HideCombat_PERF
		ODT_HideCombat_INVENTORY = ODT.savedVariables.HideCombat_INVENTORY
		ODT_HideCombat_STATS = ODT.savedVariables.HideCombat_STATS
		ODT_HideCombat_HORSE = ODT.savedVariables.HideCombat_HORSE
		ODT_HideCombat_STOLEN = ODT.savedVariables.HideCombat_STOLEN

		-----------------------------------------------------
		-- Horloge
		-----------------------------------------------------
	
		ODT_ShowClock = ODT.savedVariables.ShowClock
		ODT_ShowClockFontSize = ODT.savedVariables.ShowClockFontSize 
		ODT_ShowClockFontColor = ODT.savedVariables.ShowClockFontColor
		ODT_ShowClockBG = ODT.savedVariables.ShowClockBG
		
		local left = ODT.savedVariables.clockleft
		local top = ODT.savedVariables.clocktop
		ODT_Clock:ClearAnchors()
		ODT_Clock:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

		-----------------------------------------------------
		-- Chronomètre
		-----------------------------------------------------
		ODT_ShowChrono = ODT.savedVariables.ShowChrono
		ODT_ShowChronoFontSize = ODT.savedVariables.ShowChronoFontSize 
		ODT_ShowChronoFontColor = ODT.savedVariables.ShowChronoFontColor
		ODT_ShowChronoBG = ODT.savedVariables.ShowChronoBG
		
		local left = ODT.savedVariables.chronoleft
		local top = ODT.savedVariables.chronotop
		ODT_Chrono:ClearAnchors()
		ODT_Chrono:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	
		-----------------------------------------------------
		-- Timer
		-----------------------------------------------------
		if ODT.savedVariables.ShowTimer == nil then
			ODT.savedVariables.ShowTimer = true
			ODT.savedVariables.ShowTimerFontSize = 12
			ODT.savedVariables.ShowTimerFontColor = "|c04D631Vert"			
			ODT.savedVariables.ShowTimerBG = false
			ODT.savedVariables.timerSeconds = 3600
			ODT.savedVariables.timerleft = 300
			ODT.savedVariables.timertop = 300
		end 
		
		ODT_ShowTimer = ODT.savedVariables.ShowTimer
		ODT_ShowTimerFontSize = ODT.savedVariables.ShowTimerFontSize 
		ODT_ShowTimerFontColor = ODT.savedVariables.ShowTimerFontColor
		ODT_ShowTimerBG = ODT.savedVariables.ShowTimerBG
		ODT_Timer_Seconds = ODT.savedVariables.timerSeconds 
		ODT_Timer_SOUND	= ODT.savedVariables.TimerSOUND
			
		local left = ODT.savedVariables.timerleft
		local top = ODT.savedVariables.timertop
		ODT_timer:ClearAnchors()
		ODT_timer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	
		-----------------------------------------------------
		-- Performances
		-----------------------------------------------------
		if ODT.savedVariables.ShowPERF == nil then
			ODT.savedVariables.ShowPERF = true
			ODT.savedVariables.ShowPERFBG = false
			ODT.savedVariables.ShowPERFFontSize = 12
		end
		
		ODT_ShowPERF = ODT.savedVariables.ShowPERF
		ODT_ShowPERFFontSize = ODT.savedVariables.ShowPERFFontSize 
		ODT_ShowPERFBG = ODT.savedVariables.ShowPERFBG
		
		local left = ODT.savedVariables.perfleft
		local top = ODT.savedVariables.perftop
		ODT_PERF:ClearAnchors()
		ODT_PERF:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

		-----------------------------------------------------
		-- MAIL : RTS
		-----------------------------------------------------
		if ODT.savedVariables.MailRTS_ONOFF == nil then
			ODT.savedVariables.MailRTS_ONOFF = true
			ODT.savedVariables.MailRTS_SOUND1 = 0
			ODT.savedVariables.MailRTS_SOUND1 = 0
		end
		
		ODT_MailRTS_ONOFF = ODT.savedVariables.MailRTS_ONOFF
		ODT_MailRTS_SOUND1 = ODT.savedVariables.MailRTS_SOUND1 
		ODT_MailRTS_SOUND2 = ODT.savedVariables.MailRTS_SOUND2 

		-----------------------------------------------------
		-- Inventaire
		-----------------------------------------------------
		if ODT.savedVariables.ShowBAG == nil then
			ODT.savedVariables.ShowBAG = true
			ODT.savedVariables.ShowBAGBG = false
		end
		
		ODT_ShowBag = ODT.savedVariables.ShowBAG
		ODT_ShowBagBG = ODT.savedVariables.ShowBAGBG
		
		local left = ODT.savedVariables.bagleft
		local top = ODT.savedVariables.bagtop
		ODT_BAG:ClearAnchors()
		ODT_BAG:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	
		-----------------------------------------------------
		-- Armes & Armures
		-----------------------------------------------------
		if ODT.savedVariables.ODT_WA_ONOFF == nil then
			ODT.savedVariables.ODT_WA_ONOFF = true
			ODT.savedVariables.ODT_WABG = false
			ODT.savedVariables.ODT_WA_ATX = true
			ODT.savedVariables.ODT_WA_SOUND_ARMOR = 0
			ODT.savedVariables.ODT_WA_WTX = true
			ODT.savedVariables.ODT_WA_Recharge = true
			ODT.savedVariables.ODT_WA_SOUND_WEAPON = 0
		end

		ODT_WA_ONOFF = ODT.savedVariables.ODT_WA_ONOFF 
		ODT_WABG = ODT.savedVariables.ODT_WABG
		ODT_WA_ATX = ODT.savedVariables.ODT_WA_ATX
		ODT_WA_SOUND_ARMOR = ODT.savedVariables.ODT_WA_SOUND_ARMOR
		ODT_WA_WTX = ODT.savedVariables.ODT_WA_WTX
		ODT_WA_SOUND_WEAPON = ODT.savedVariables.ODT_WA_SOUND_WEAPON 
		ODT_WA_Recharge = ODT.savedVariables.ODT_WA_Recharge
		
		local left = ODT.savedVariables.WAleft
		local top = ODT.savedVariables.WAtop
		ODT_WA:ClearAnchors()
		ODT_WA:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
		
		-----------------------------------------------------
		-- Nourriture & Boisson
		-----------------------------------------------------
		if ODT.savedVariables.ShowFOOD == nil then
			ODT.savedVariables.ShowFOOD = true
			ODT.savedVariables.ShowFOOD_TIME = 1
			ODT.savedVariables.ShowFOOD_SOUND = 0
			ODT.savedVariables.ShowFOOD_POPDURATION = 8
			ODT.savedVariables.ShowFOOD_CHECKONLOAD = false
		end
		
		ODT_ShowFOOD = ODT.savedVariables.ShowFOOD
		ODT_ShowFOOD_TIME = ODT.savedVariables.ShowFOOD_TIME
		ODT_ShowFOOD_SOUND = ODT.savedVariables.ShowFOOD_SOUND
		ODT_ShowFOOD_POPDURATION = ODT.savedVariables.ShowFOOD_POPDURATION
		ODT_ShowFOOD_CHECKONLOAD = ODT.savedVariables.ShowFOOD_CHECKONLOAD
		
		if ODT_ShowFOOD == true then
			ODT_ShowFoodMsg = 2
			ShowFoodMsgEvent = 2
			zo_callLater(function() ODT_FoodCheck() end, 1000)
		end
		
		-----------------------------------------------------
		-- XP Scroll
		-----------------------------------------------------
		if ODT.savedVariables.ShowXPSCROLL == nil then
			ODT.savedVariables.ShowXPSCROLL = true
			ODT.savedVariables.ShowXPSCROLL_SOUND = 0
			ODT.savedVariables.ShowXPSCROLL_POPDURATION = 8
		end
		
		ODT_ShowXPSCROLL = ODT.savedVariables.ShowXPSCROLL
		ODT_ShowXPSCROLL_SOUND = ODT.savedVariables.ShowXPSCROLL_SOUND
		ODT_ShowXPSCROLL_POPDURATION = ODT.savedVariables.ShowXPSCROLL_POPDURATION
		
		if ODT_ShowXPSCROLL == true then
			ShowXPSCROLLMsgEvent = 2
			zo_callLater(function() ODT_XPSCROLLCheck() end, 1000)
		end
		
		-----------------------------------------------------
		-- Monture
		-----------------------------------------------------
		if ODT.savedVariables.ODT_HORSE == nil then
			ODT.savedVariables.ODT_HORSE = true
			ODT.savedVariables.ODT_HORSE_SHOWBG = false
			ODT.savedVariables.ODT_HORSE_SHOWTIME = 10
			ODT.savedVariables.ODT_HORSE_SOUND = 0
			ODT.savedVariables.ODT_HORSE_CHECKONLOAD = true
		end
		
		local left = ODT.savedVariables.ODT_HorseShowleft
		local top = ODT.savedVariables.ODT_HorseShowtop
		ODT_HorseShow:ClearAnchors()
		ODT_HorseShow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

		ODT_HORSE = ODT.savedVariables.ODT_HORSE
		ODT_HORSE_SHOWBG = ODT.savedVariables.ODT_HORSE_SHOWBG
		ODT_HORSE_SHOWPERMA = ODT.savedVariables.ODT_HORSE_SHOWPERMA
		ODT_HORSE_SHOWTIME = ODT.savedVariables.ODT_HORSE_SHOWTIME
		ODT_HORSE_SOUND = ODT.savedVariables.ODT_HORSE_SOUND
		ODT_HORSE_CHECKONLOAD = ODT.savedVariables.ODT_HORSE_CHECKONLOAD


		-----------------------------------------------------
		-- Guildes : notifications status guilde
		-----------------------------------------------------
		if ODT.savedVariables.ODT_GM1 == nil then
			ODT.savedVariables.ODT_GM1 = true
			ODT.savedVariables.ODT_GM2 = true
			ODT.savedVariables.ODT_GM3 = true
			ODT.savedVariables.ODT_GM4 = true
			ODT.savedVariables.ODT_GM5 = true
			ODT.savedVariables.ODT_GuildName = true
			ODT.savedVariables.ODT_GMCharacterName = true
			ODT.savedVariables.ODT_GMAlliance = true
			ODT.savedVariables.ODT_GMSound = 0
			ODT.savedVariables.ODT_GMNotif = true
			ODT.savedVariables.ODT_GMHeure = true
		end
		
		ODT_GM1 = ODT.savedVariables.ODT_GM1 
		ODT_GM2 = ODT.savedVariables.ODT_GM2 
		ODT_GM3 = ODT.savedVariables.ODT_GM3
		ODT_GM4 = ODT.savedVariables.ODT_GM4 
		ODT_GM5 = ODT.savedVariables.ODT_GM5 
		ODT_GuildName = ODT.savedVariables.ODT_GuildName 
		ODT_GMCharacterName = ODT.savedVariables.ODT_GMCharacterName
		ODT_GMAlliance = ODT.savedVariables.ODT_GMAlliance 
		ODT_GMSound = ODT.savedVariables.ODT_GMSound
		ODT_GMNotif = ODT.savedVariables.ODT_GMNotif
		ODT_GMHeure = ODT.savedVariables.ODT_GMHeure

		-----------------------------------------------------
		-- CHAT : notifications
		-----------------------------------------------------
		if ODT.savedVariables.ODT_Notif_Say == nil then
			ODT.savedVariables.ODT_Notif_Say = 0
			ODT.savedVariables.ODT_Notif_Yell = 0
			ODT.savedVariables.ODT_Notif_Tell = 16
			ODT.savedVariables.ODT_Notif_Party = 0
			ODT.savedVariables.ODT_Notif_Z = 0
			ODT.savedVariables.ODT_Notif_ZEN = 0
			ODT.savedVariables.ODT_Notif_ZFR = 0
			ODT.savedVariables.ODT_Notif_ZDE = 0
			ODT.savedVariables.ODT_Notif_G1 = 0
			ODT.savedVariables.ODT_Notif_G2 = 0 
			ODT.savedVariables.ODT_Notif_G3 = 0 
			ODT.savedVariables.ODT_Notif_G4 = 0 
			ODT.savedVariables.ODT_Notif_G5 = 0
			ODT.savedVariables.ODT_Notif_G1OFF = 0
			ODT.savedVariables.ODT_Notif_G2OFF = 0 
			ODT.savedVariables.ODT_Notif_G3OFF = 0
			ODT.savedVariables.ODT_Notif_G4OFF = 0
			ODT.savedVariables.ODT_Notif_G5OFF = 0
		end
		ODT_Notif_Say = ODT.savedVariables.ODT_Notif_Say
		ODT_Notif_Yell = ODT.savedVariables.ODT_Notif_Yell
		ODT_Notif_Tell = ODT.savedVariables.ODT_Notif_Tell
		ODT_Notif_Party = ODT.savedVariables.ODT_Notif_Party
		ODT_Notif_Z = ODT.savedVariables.ODT_Notif_Z
		ODT_Notif_ZEN = ODT.savedVariables.ODT_Notif_ZEN
		ODT_Notif_ZFR = ODT.savedVariables.ODT_Notif_ZFR
		ODT_Notif_ZDE = ODT.savedVariables.ODT_Notif_ZDE
		ODT_Notif_G1 = ODT.savedVariables.ODT_Notif_G1
		ODT_Notif_G2 = ODT.savedVariables.ODT_Notif_G2
		ODT_Notif_G3 = ODT.savedVariables.ODT_Notif_G3
		ODT_Notif_G4 = ODT.savedVariables.ODT_Notif_G4
		ODT_Notif_G5 = ODT.savedVariables.ODT_Notif_G5
		ODT_Notif_G1OFF = ODT.savedVariables.ODT_Notif_G1OFF
		ODT_Notif_G2OFF = ODT.savedVariables.ODT_Notif_G2OFF
		ODT_Notif_G3OFF = ODT.savedVariables.ODT_Notif_G3OFF
		ODT_Notif_G4OFF = ODT.savedVariables.ODT_Notif_G4OFF
		ODT_Notif_G5OFF = ODT.savedVariables.ODT_Notif_G5OFF


		-----------------------------------------------------
		-- CHAT PERSONNALISE
		-----------------------------------------------------
		if ODT.savedVariables.ODT_CustomChatDate == nil then
			ODT.savedVariables.ODT_CustomChatPerma = true
			ODT.savedVariables.ODT_CustomChatDate = true
			ODT.savedVariables.ODT_CustomChatTime = true
			ODT.savedVariables.ODT_CustomChatChan = true
			ODT.savedVariables.ODT_CustomChatAccount = true
			ODT_CustomChatPersoInfos = false
			ODT.savedVariables.ODT_CustomChatName = false
			ODT.savedVariables.ODT_CustomChatAlliance = false
			ODT.savedVariables.ODT_CustomChatClasse = false
			ODT.savedVariables.ODT_CustomChatLvl = false
		end

		if ODT.savedVariables.ODT_CustomChatPerma == nil then
			ODT.savedVariables.ODT_CustomChatPerma = true
		end
		ODT_CustomChatPerma	= ODT.savedVariables.ODT_CustomChatPerma
		ODT_CustomChatDate = ODT.savedVariables.ODT_CustomChatDate
		ODT_CustomChatTime = ODT.savedVariables.ODT_CustomChatTime
		ODT_CustomChatChan = ODT.savedVariables.ODT_CustomChatChan
		ODT_CustomChatAccount = ODT.savedVariables.ODT_CustomChatAccount
		ODT_CustomChatPersoInfos = ODT.savedVariables.ODT_CustomChatPersoInfos
		ODT_CustomChatName = ODT.savedVariables.ODT_CustomChatName
		ODT_CustomChatAlliance = ODT.savedVariables.ODT_CustomChatAlliance
		ODT_CustomChatClasse = ODT.savedVariables.ODT_CustomChatClasse
		ODT_CustomChatLvl = ODT.savedVariables.ODT_CustomChatLvl

		-----------------------------------------------------
		-- PECHE
		-----------------------------------------------------
		if ODT.savedVariables.ODT_Fish == nil then
			ODT.savedVariables.ODT_Fish = true
		end
		ODT_Fish = ODT.savedVariables.ODT_Fish

		-----------------------------------------------------
		-- VOL
		-----------------------------------------------------
		if ODT.savedVariables.ODT_ShowStolen == nil then
			ODT.savedVariables.ODT_ShowStolen = true
			ODT.savedVariables.ODT_ShowStolenBG = false
			ODT.savedVariables.ODT_STOLENleft = ODT_StolenShow:GetLeft()
			ODT.savedVariables.ODT_STOLENtop = ODT_StolenShow:GetTop()
		end

		ODT_ShowStolen = ODT.savedVariables.ODT_ShowStolen
		ODT_ShowStolenBG = ODT.savedVariables.ODT_ShowStolenBG
		
		local left = ODT.savedVariables.ODT_STOLENleft
		local top = ODT.savedVariables.ODT_STOLENtop 
		ODT_STOLEN:ClearAnchors()
		ODT_STOLEN:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
		
		-----------------------------------------------------
		-- Liste des morts
		-----------------------------------------------------
		if ODT.savedVariables.ODT_ShowDeath == nil then
			ODT.savedVariables.ODT_ShowDeath = true
			ODT.savedVariables.ODT_ShowDeathMsg = true
			ODT.savedVariables.ODT_ShowDeathChat = true
			ODT.savedVariables.ODT_ShowDeathList = true
			ODT.savedVariables.ODT_ShowDeathRez = 0
			ODT.savedVariables.ODT_ShowDeathSnd = 0
		end
		
		ODT_ShowDeath = ODT.savedVariables.ODT_ShowDeath 
		ODT_ShowDeathMsg = ODT.savedVariables.ODT_ShowDeathMsg 
		ODT_ShowDeathChat = ODT.savedVariables.ODT_ShowDeathChat
		ODT_ShowDeathList = ODT.savedVariables.ODT_ShowDeathList
		ODT_ShowDeathRez = ODT.savedVariables.ODT_ShowDeathRez
		ODT_ShowDeathSnd = ODT.savedVariables.ODT_ShowDeathSnd
		
		local left = ODT.savedVariables.ODT_MSGDEATHLISTleft 
		local top = ODT.savedVariables.ODT_MSGDEATHLISTtop
		ODT_MSGDEATHLIST:ClearAnchors()
		ODT_MSGDEATHLIST:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
		
		-----------------------------------------------------
		-- Message spécial
		-----------------------------------------------------
		if ODT.savedVariables.Special0101 == nil then
			ODT.savedVariables.Special0101 = 0
		end 
		
		-----------------------------------------------------
		-- BackGround
		-----------------------------------------------------
		ODT_BG_Show = ODT.savedVariables.ODT_BG_Show
		ODT_BGX = ODT.savedVariables.ODT_BGX
		ODT_BGY = ODT.savedVariables.ODT_BGY
		ODT_BackGround()
		
		-----------------------------------------------------
		-- Divers
		-----------------------------------------------------
		ODT_LOCKWINDOWS = ODT.savedVariables.ODT_LOCKWINDOWS
		
		-----------------------------------------------------
		-- Application des paramètres 
		-----------------------------------------------------
		ApplySettings()
		ODT_SettinsLoaded = 1			
		ODT_ClockOnUpdate()
		ODT_ChronoOnUpdate()
		ODT_timerStopCliked()
		ODT_TimerOnUpdate()		
		ODT_PERF_FPSOnUpdate()
	end

end

--*********************************************************************
-- Création des variables par défaut si savedVariables est vide
--*********************************************************************
function CreateDefaultSettings()
	
	-----------------------------------------------------
	-- Horloge
	-----------------------------------------------------
	ODT.savedVariables.ShowClock = ODT_ShowClock
	ODT.savedVariables.ShowClockFontSize = 16
	ODT.savedVariables.ShowClockFontColor = "|c04D631Vert"
	ODT.savedVariables.ShowClockBG = false
	ODT.savedVariables.clockleft = 100
	ODT.savedVariables.clocktop = 100

	-----------------------------------------------------
	-- Chronomètre
	-----------------------------------------------------
	ODT.savedVariables.ShowChrono = ODT_ShowChrono
	ODT.savedVariables.ShowChronoFontSize = 16
	ODT.savedVariables.ShowChronoFontColor = "|c04D631Vert"
	ODT.savedVariables.ShowChronoBG = false
	ODT.savedVariables.chronoleft = 200
	ODT.savedVariables.chronotop = 200

	-----------------------------------------------------
	-- Timer
	-----------------------------------------------------
	ODT.savedVariables.ShowTimer = ODT_ShowTimer
	ODT.savedVariables.ShowTimerFontSize = 12 
	ODT.savedVariables.ShowTimerFontColor = "|c04D631Vert"
	ODT.savedVariables.ShowTimerBG = false
	ODT.savedVariables.timer_Seconds = 3600
	
	-----------------------------------------------------
	-- Performances
	-----------------------------------------------------
	ODT.savedVariables.ShowPERF = ODT_ShowPERF
	ODT.savedVariables.ShowPERFBG = false

	-----------------------------------------------------
	-- Inventaire
	-----------------------------------------------------
	ODT.savedVariables.ShowBAG = ODT_ShowBag
	ODT.savedVariables.ShowBAGBG = false

	-----------------------------------------------------
	-- Nourriture & Boisson
	-----------------------------------------------------
	ODT.savedVariables.ShowFOOD = true
	ODT.savedVariables.ShowFOOD_TIME = 1
	ODT.savedVariables.ShowFOOD_SOUND = 0
	ODT.savedVariables.ShowFOOD_POPDURATION = 8
	ODT.savedVariables.ShowFOOD_CHECKONLOAD = false

	-----------------------------------------------------
	-- Monture
	-----------------------------------------------------
	ODT.savedVariables.ODT_HORSE = true
	ODT.savedVariables.ODT_HORSE_SHOWBG = false
	ODT.savedVariables.ODT_HORSE_SHOWPERMA = true
	ODT.savedVariables.ODT_HORSE_SHOWTIME = 10
	ODT.savedVariables.ODT_HORSE_SOUND = 0
	ODT.savedVariables.ODT_HORSE_CHECKONLOAD = true

	-----------------------------------------------------
	-- BackGround
	-----------------------------------------------------
	ODT.savedVariables.ODT_BG_Show = true
	ODT.savedVariables.ODT_BGX = 240
	ODT.savedVariables.ODT_BGY = 80

	-----------------------------------------------------
	-- Guildes : notifications status guilde
	-----------------------------------------------------
	ODT.savedVariables.ODT_GM1 = true
	ODT.savedVariables.ODT_GM2 = true
	ODT.savedVariables.ODT_GM3 = true
	ODT.savedVariables.ODT_GM4 = true
	ODT.savedVariables.ODT_GM5 = true
	ODT.savedVariables.ODT_GuildName = true
	ODT.savedVariables.ODT_GMCharacterName = true
	ODT.savedVariables.ODT_GMAlliance = true
	ODT.savedVariables.ODT_GMSound = 0
	ODT.savedVariables.ODT_GMNotif = true
	ODT.savedVariables.ODT_GMHeure = true

	-----------------------------------------------------
	-- CHAT : notifications
	-----------------------------------------------------
	ODT.savedVariables.ODT_Notif_Say = 0
	ODT.savedVariables.ODT_Notif_Yell = 0
	ODT.savedVariables.ODT_Notif_Tell = 16
	ODT.savedVariables.ODT_Notif_Party = 16
	ODT.savedVariables.ODT_Notif_Z = 0
	ODT.savedVariables.ODT_Notif_ZEN = 0
	ODT.savedVariables.ODT_Notif_ZFR = 0
	ODT.savedVariables.ODT_Notif_ZDE = 0
	ODT.savedVariables.ODT_Notif_G1 = 0
	ODT.savedVariables.ODT_Notif_G2 = 0 
	ODT.savedVariables.ODT_Notif_G3 = 0 
	ODT.savedVariables.ODT_Notif_G4 = 0 
	ODT.savedVariables.ODT_Notif_G5 = 0
	ODT.savedVariables.ODT_Notif_G1OFF = 0
	ODT.savedVariables.ODT_Notif_G2OFF = 0 
	ODT.savedVariables.ODT_Notif_G3OFF = 0
	ODT.savedVariables.ODT_Notif_G4OFF = 0
	ODT.savedVariables.ODT_Notif_G5OFF = 0

	-----------------------------------------------------
	-- CHAT PERSONNALISE
	-----------------------------------------------------
	ODT.savedVariables.ODT_CustomChatPerma = true
	ODT.savedVariables.ODT_CustomChatDate = true
	ODT.savedVariables.ODT_CustomChatTime = true
	ODT.savedVariables.ODT_CustomChatChan = true
	ODT.savedVariables.ODT_CustomChatAccount = true
	ODT_CustomChatPersoInfos = false
	ODT.savedVariables.ODT_CustomChatName = false
	ODT.savedVariables.ODT_CustomChatAlliance = false
	ODT.savedVariables.ODT_CustomChatClasse = false
	ODT.savedVariables.ODT_CustomChatLvl = false

	-----------------------------------------------------
	-- PECHE
	-----------------------------------------------------
	ODT.savedVariables.ODT_Fish = true	

	-----------------------------------------------------
	-- Vol
	-----------------------------------------------------
	ODT.savedVariables.ODT_ShowStolen = true
	ODT.savedVariables.ODT_ShowStolenBG = false

	-----------------------------------------------------
	-- Morts
	-----------------------------------------------------
	ODT.savedVariables.ODT_ShowDeath = true
	ODT.savedVariables.ODT_ShowDeathMsg = true
	ODT.savedVariables.ODT_ShowDeathChat = true
	ODT.savedVariables.ODT_ShowDeathList = true
	ODT.savedVariables.ODT_ShowDeathRez = 0
	ODT.savedVariables.ODT_ShowDeathSnd = 0
	
	-----------------------------------------------------
	-- Divers
	-----------------------------------------------------
	ODT.savedVariables.ODT_LOCKWINDOWS = false
		
	-----------------------------------------------------
	-- Hide en Combat
	-----------------------------------------------------
	ODT.savedVariables.HideCombat_GLOBAL = false
	ODT.savedVariables.HideCombat_BG = false
	ODT.savedVariables.HideCombat_CLOCK = false
	ODT.savedVariables.HideCombat_CHRONO = false
	ODT.savedVariables.HideCombat_TIMER = false
	ODT.savedVariables.HideCombat_PERF = false
	ODT.savedVariables.HideCombat_INVENTORY = false
	ODT.savedVariables.HideCombat_STATS = false
	ODT.savedVariables.HideCombat_HORSE = false
	ODT.savedVariables.HideCombat_STOLEN = false

	-----------------------------------------------------
	-- Infos Player
	-----------------------------------------------------
	ODT.savedVariables.accountname = ODT_AccountName
	local character = GetUnitName("player")
	ODT.savedVariables.charactername = character

	ReloadUI()
end

--*********************************************************************
-- Sauvegarde la position de l'horloge
--*********************************************************************
function ODT_Clock.MoveStop()
	ODT.savedVariables.clockleft = ODT_Clock:GetLeft()
	ODT.savedVariables.clocktop = ODT_Clock:GetTop()
end

--*********************************************************************
-- Sauvegarde la position du chronomètre
--*********************************************************************
function ODT_Chrono.MoveStop()
	ODT.savedVariables.chronoleft = ODT_Chrono:GetLeft()
	ODT.savedVariables.chronotop = ODT_Chrono:GetTop()
end

--*********************************************************************
-- Sauvegarde la position du timer
--*********************************************************************
function ODT_timer.MoveStop()
	ODT.savedVariables.timerleft = ODT_timer:GetLeft()
	ODT.savedVariables.timertop = ODT_timer:GetTop()
end

--*********************************************************************
-- Sauvegarde la position des performances
--*********************************************************************
function ODT_PERF.MoveStop()
	ODT.savedVariables.perfleft = ODT_PERF:GetLeft()
	ODT.savedVariables.perftop = ODT_PERF:GetTop()
end

--*********************************************************************
-- Sauvegarde la position de l'inventaire
--*********************************************************************
function ODT_BAG.MoveStop()
	ODT.savedVariables.bagleft = ODT_BAG:GetLeft()
	ODT.savedVariables.bagtop = ODT_BAG:GetTop()
end

--*********************************************************************
-- Sauvegarde la position des stats armure/armes
--*********************************************************************
function ODT_WA.MoveStop()
	ODT.savedVariables.WAleft = ODT_WA:GetLeft()
	ODT.savedVariables.WAtop = ODT_WA:GetTop()
end

--*********************************************************************
-- Sauvegarde la position de la monture
--*********************************************************************
function ODT_HorseShow.MoveStop()
	ODT.savedVariables.ODT_HorseShowleft = ODT_HorseShow:GetLeft()
	ODT.savedVariables.ODT_HorseShowtop = ODT_HorseShow:GetTop()
end

--*********************************************************************
-- Sauvegarde la position des infos de VOL
--*********************************************************************
function ODT_STOLEN.MoveStop()
	ODT.savedVariables.ODT_STOLENleft = ODT_STOLEN:GetLeft()
	ODT.savedVariables.ODT_STOLENtop = ODT_STOLEN:GetTop()
end

--*********************************************************************
-- Sauvegarde la position de la liste des morts
--*********************************************************************
function ODT_MSGDEATHLIST.MoveStop()
	ODT.savedVariables.ODT_MSGDEATHLISTleft = ODT_MSGDEATHLIST:GetLeft()
	ODT.savedVariables.ODT_MSGDEATHLISTtop = ODT_MSGDEATHLIST:GetTop()
end

--*********************************************************************
-- Sauvegarde la position du background
--*********************************************************************
function ODT_BG.MoveStop()
	ODT.savedVariables.ODT_BGleft = ODT_BG:GetLeft()
	ODT.savedVariables.ODT_BGtop = ODT_BG:GetTop()
end
--*********************************************************************
-- BackGround
--*********************************************************************
function ODT_BackGround()
	if ODT_BG_Show == true then
		local left = ODT.savedVariables.ODT_BGleft
		local top = ODT.savedVariables.ODT_BGtop
		ODT_BG:ClearAnchors()
		ODT_BG:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
		ODT_BG:SetHidden(false)
		ODT_BG_Version:SetText("Orbe du Temps - " .. ODT.version)
		ODT_BG_BG:SetWidth(ODT_BGX)
		ODT_BG_BG:SetHeight(ODT_BGY)
	else
		ODT_BG:SetHidden(true)
	end 
end

--*********************************************************************
-- Sauvegarde des variables du Control Panel (Settings)
--*********************************************************************
local function SaveSettings(option)
	ApplySettings()

	--------------------------------------------------------
	-- Création du panneau 
	--------------------------------------------------------
	local fc = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)

	--------------------------------------------------------
	-- Sauvegarde des variables
	--------------------------------------------------------
	if option == "save" then
		-----------------------------------------------------
		-- Hide in Combat
		--------------------------------------------	
		ODT.savedVariables.HideCombat_GLOBAL = ODT_HideCombat_GLOBAL
		ODT.savedVariables.HideCombat_BG = ODT_HideCombat_BG
		ODT.savedVariables.HideCombat_CLOCK = ODT_HideCombat_CLOCK
		ODT.savedVariables.HideCombat_CHRONO = ODT_HideCombat_CHRONO
		ODT.savedVariables.HideCombat_TIMER = ODT_HideCombat_TIMER
		ODT.savedVariables.HideCombat_PERF = ODT_HideCombat_PERF
		ODT.savedVariables.HideCombat_INVENTORY = ODT_HideCombat_INVENTORY 
		ODT.savedVariables.HideCombat_STATS = ODT_HideCombat_STATS
		ODT.savedVariables.HideCombat_HORSE = ODT_HideCombat_HORSE
		ODT.savedVariables.HideCombat_STOLEN = ODT_HideCombat_STOLEN
		
		-----------------------------------------------------
		-- Horloge
		-----------------------------------------------------
		ODT.savedVariables.ShowClock = ODT_ShowClock
		ODT.savedVariables.ShowClockFontSize = ODT_ShowClockFontSize
		ODT.savedVariables.ShowClockFontColor = ODT_ShowClockFontColor
		ODT.savedVariables.ShowClockBG = ODT_ShowClockBG
		
		-----------------------------------------------------
		-- Chronomètre
		-----------------------------------------------------
		ODT.savedVariables.ShowChrono = ODT_ShowChrono
		ODT.savedVariables.ShowChronoFontSize = ODT_ShowChronoFontSize
		ODT.savedVariables.ShowChronoFontColor = ODT_ShowChronoFontColor
		ODT.savedVariables.ShowChronoBG = ODT_ShowChronoBG

		-----------------------------------------------------
		-- Timer
		-----------------------------------------------------
		ODT.savedVariables.ShowTimer = ODT_ShowTimer
		ODT.savedVariables.ShowTimerFontSize = ODT_ShowTimerFontSize
		ODT.savedVariables.ShowTimerFontColor = ODT_ShowTimerFontColor
		ODT.savedVariables.ShowTimerBG = ODT_ShowTimerBG
		ODT.savedVariables.timerSeconds = ODT_Timer_Seconds
		ODT.savedVariables.TimerSOUND = ODT_Timer_SOUND
		
		-----------------------------------------------------
		-- Performances
		-----------------------------------------------------
		ODT.savedVariables.ShowPERF = ODT_ShowPERF
		ODT.savedVariables.ShowPERFBG = ODT_ShowPERFBG

		-----------------------------------------------------
		-- MAIL : RTS
		-----------------------------------------------------
		ODT.savedVariables.MailRTS_ONOFF = ODT_MailRTS_ONOFF
		ODT.savedVariables.MailRTS_SOUND1 = ODT_MailRTS_SOUND1
		ODT.savedVariables.MailRTS_SOUND2 = ODT_MailRTS_SOUND2

		-----------------------------------------------------
		-- Inventaire
		-----------------------------------------------------
		ODT.savedVariables.ShowBAG = ODT_ShowBag
		ODT.savedVariables.ShowBAGBG = ODT_ShowBagBG

		-----------------------------------------------------
		-- Armes & Armures
		-----------------------------------------------------
		ODT.savedVariables.ODT_WA_ONOFF = ODT_WA_ONOFF
		ODT.savedVariables.ODT_WABG = ODT_WABG
		ODT.savedVariables.ODT_WA_ATX = ODT_WA_ATX 
		ODT.savedVariables.ODT_WA_SOUND_ARMOR = ODT_WA_SOUND_ARMOR
		ODT.savedVariables.ODT_WA_WTX = ODT_WA_WTX
		ODT.savedVariables.ODT_WA_SOUND_WEAPON = ODT_WA_SOUND_WEAPON
		ODT.savedVariables.ODT_WA_Recharge = ODT_WA_Recharge

		-----------------------------------------------------
		-- Nourriture & Boisson
		-----------------------------------------------------
		ODT.savedVariables.ShowFOOD = ODT_ShowFOOD
		ODT.savedVariables.ShowFOOD_TIME = ODT_ShowFOOD_TIME
		ODT.savedVariables.ShowFOOD_SOUND = ODT_ShowFOOD_SOUND
		ODT.savedVariables.ShowFOOD_POPDURATION = ODT_ShowFOOD_POPDURATION
		ODT.savedVariables.ShowFOOD_CHECKONLOAD = ODT_ShowFOOD_CHECKONLOAD
		if ODT_ShowFOOD == true then
			zo_callLater(function() ODT_FoodCheck() end, 1000)
		end

		-----------------------------------------------------
		-- XP Scroll
		-----------------------------------------------------
		ODT.savedVariables.ShowXPSCROLL = ODT_ShowXPSCROLL
		ODT.savedVariables.ShowXPSCROLL_SOUND = ODT_ShowXPSCROLL_SOUND
		ODT.savedVariables.ShowXPSCROLL_POPDURATION = ODT_ShowXPSCROLL_POPDURATION
		ODT.savedVariables.ShowXPSCROLL_CHECKONLOAD = ODT_ShowXPSCROLL_CHECKONLOAD
		if ODT_ShowXPSCROLL == true then
			zo_callLater(function() ODT_XPSCROLLCheck() end, 1000)
		end

		-----------------------------------------------------
		-- Monture
		-----------------------------------------------------
		ODT.savedVariables.ODT_HORSE = ODT_HORSE
		ODT.savedVariables.ODT_HORSE_SHOWBG = ODT_HORSE_SHOWBG
		ODT.savedVariables.ODT_HORSE_SHOWPERMA = ODT_HORSE_SHOWPERMA
		ODT.savedVariables.ODT_HORSE_SHOWTIME = ODT_HORSE_SHOWTIME
		ODT.savedVariables.ODT_HORSE_SOUND = ODT_HORSE_SOUND
		ODT.savedVariables.ODT_HORSE_CHECKONLOAD = ODT_HORSE_CHECKONLOAD

		-----------------------------------------------------
		-- Pêche
		-----------------------------------------------------
		ODT.savedVariables.ODT_Fish = ODT_Fish
		
		-----------------------------------------------------
		-- Vol
		-----------------------------------------------------
		ODT.savedVariables.ODT_ShowStolen = ODT_ShowStolen
		ODT.savedVariables.ODT_ShowStolenBG = ODT_ShowStolenBG

		-----------------------------------------------------
		-- Mort
		-----------------------------------------------------
		ODT.savedVariables.ODT_ShowDeath = ODT_ShowDeath
		ODT.savedVariables.ODT_ShowDeathMsg = ODT_ShowDeathMsg
		ODT.savedVariables.ODT_ShowDeathChat = ODT_ShowDeathChat
		ODT.savedVariables.ODT_ShowDeathList = ODT_ShowDeathList
		ODT.savedVariables.ODT_ShowDeathRez = ODT_ShowDeathRez
		ODT.savedVariables.ODT_ShowDeathSnd = ODT_ShowDeathSnd

		-----------------------------------------------------
		-- BackGround
		-----------------------------------------------------
		ODT.savedVariables.ODT_BG_Show = ODT_BG_Show
		ODT.savedVariables.ODT_BGX = ODT_BGX
		ODT.savedVariables.ODT_BGY = ODT_BGY

		-----------------------------------------------------
		-- Divers
		-----------------------------------------------------
		ODT.savedVariables.ODT_LOCKWINDOWS = ODT_LOCKWINDOWS
		
		-----------------------------------------------------
		-- Guildes : notifications status guilde
		-----------------------------------------------------
		ODT.savedVariables.ODT_GM1 = ODT_GM1
		ODT.savedVariables.ODT_GM2 = ODT_GM2
		ODT.savedVariables.ODT_GM3 = ODT_GM3
		ODT.savedVariables.ODT_GM4 = ODT_GM4
		ODT.savedVariables.ODT_GM5 = ODT_GM5
		ODT.savedVariables.ODT_GuildName = ODT_GuildName
		ODT.savedVariables.ODT_GMCharacterName = ODT_GMCharacterName
		ODT.savedVariables.ODT_GMAlliance = ODT_GMAlliance
		ODT.savedVariables.ODT_GMSound = ODT_GMSound
		ODT.savedVariables.ODT_GMNotif = ODT_GMNotif
		ODT.savedVariables.ODT_GMHeure = ODT_GMHeure

		-----------------------------------------------------
		-- CHAT : notifications
		-----------------------------------------------------
		ODT.savedVariables.ODT_Notif_Say = ODT_Notif_Say
		ODT.savedVariables.ODT_Notif_Yell = ODT_Notif_Yell
		ODT.savedVariables.ODT_Notif_Tell = ODT_Notif_Tell
		ODT.savedVariables.ODT_Notif_Party = ODT_Notif_Party
		ODT.savedVariables.ODT_Notif_Z = ODT_Notif_Z 
		ODT.savedVariables.ODT_Notif_ZEN = ODT_Notif_ZEN
		ODT.savedVariables.ODT_Notif_ZFR = ODT_Notif_ZFR
		ODT.savedVariables.ODT_Notif_ZDE = ODT_Notif_ZDE
		ODT.savedVariables.ODT_Notif_G1 = ODT_Notif_G1
		ODT.savedVariables.ODT_Notif_G2 = ODT_Notif_G2
		ODT.savedVariables.ODT_Notif_G3 = ODT_Notif_G3
		ODT.savedVariables.ODT_Notif_G4 = ODT_Notif_G4
		ODT.savedVariables.ODT_Notif_G5 = ODT_Notif_G5
		ODT.savedVariables.ODT_Notif_G1OFF = ODT_Notif_G1OFF
		ODT.savedVariables.ODT_Notif_G2OFF = ODT_Notif_G2OFF
		ODT.savedVariables.ODT_Notif_G3OFF = ODT_Notif_G3OFF
		ODT.savedVariables.ODT_Notif_G4OFF = ODT_Notif_G4OFF
		ODT.savedVariables.ODT_Notif_G5OFF = ODT_Notif_G5OFF

		-----------------------------------------------------
		-- CHAT PERSONNALISE
		-----------------------------------------------------
		ODT.savedVariables.ODT_CustomChatPerma = ODT_CustomChatPerma
		ODT.savedVariables.ODT_CustomChatDate = ODT_CustomChatDate 
		ODT.savedVariables.ODT_CustomChatTime = ODT_CustomChatTime
		ODT.savedVariables.ODT_CustomChatChan = ODT_CustomChatChan
		ODT.savedVariables.ODT_CustomChatAccount = ODT_CustomChatAccount
		ODT.savedVariables.ODT_CustomChatPersoInfos = ODT_CustomChatPersoInfos 
		ODT.savedVariables.ODT_CustomChatName = ODT_CustomChatName 
		ODT.savedVariables.ODT_CustomChatAlliance = ODT_CustomChatAlliance
		ODT.savedVariables.ODT_CustomChatClasse = ODT_CustomChatClasse
		ODT.savedVariables.ODT_CustomChatLvl = ODT_CustomChatLvl

		-----------------------------------------------------
		-- BACKGROUND
		-----------------------------------------------------
		ODT.savedVariables.ODT_BG_Show = ODT_BG_Show
		ODT.savedVariables.ODT_BGX = ODT_BGX
		ODT.savedVariables.ODT_BGY = ODT_BGY
		
		-----------------------------------------------------
		-- Infos Player
		-----------------------------------------------------
		ODT.savedVariables.accountname = ODT_AccountName
		local character = GetUnitName("player")
		ODT.savedVariables.charactername = character


		ReloadUI()
	end 

end

--*********************************************************************
-- ARMES & ARMURE
--*********************************************************************
function ODT_WeaponsAndArmor()
	ODT_WeaponsCharge(EQUIP_SLOT_MAIN_HAND)
	ODT_itemIcon11 = ODT_itemIcon
	if ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds" then
		ODT_WA_WEAPON11_IMG:SetHidden(false)
		ODT_WA_WEAPON11_IMG:SetTexture(ODT_itemIcon11)
		ODT_WA_WEAPON11_PCENT:SetText(ODT_itemCharge .. "%")
		ODT_ItemLink11 = ODT_ItemLink
	else
		ODT_WA_WEAPON11_IMG:SetHidden(true)
		ODT_ItemLink11 = ""
	end

	ODT_WeaponsCharge(EQUIP_SLOT_OFF_HAND)
	ODT_itemIcon12 = ODT_itemIcon
	if ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds" then
		ODT_WA_WEAPON12_IMG:SetHidden(false)
		ODT_WA_WEAPON12_IMG:SetTexture(ODT_itemIcon12)
		ODT_WA_WEAPON12_PCENT:SetText(ODT_itemCharge .. "%")
		ODT_ItemLink12 = ODT_ItemLink
	else
		ODT_WA_WEAPON12_IMG:SetHidden(true)
		ODT_ItemLink12 = ""
	end
	
	ODT_WeaponsCharge(EQUIP_SLOT_BACKUP_MAIN)
	ODT_itemIcon21 = ODT_itemIcon
	if ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds" then
		ODT_WA_WEAPON21_IMG:SetTexture(ODT_itemIcon21)
		ODT_WA_WEAPON21_IMG:SetHidden(false)
		ODT_WA_WEAPON21_PCENT:SetText(ODT_itemCharge .. "%")
		ODT_ItemLink21 = ODT_ItemLink
	else
		ODT_WA_WEAPON21_IMG:SetHidden(true)
		ODT_ItemLink21 = ""
	end

	ODT_WeaponsCharge(EQUIP_SLOT_BACKUP_OFF)
	ODT_itemIcon22 = ODT_itemIcon
	if ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds" then
		ODT_WA_WEAPON22_IMG:SetTexture(ODT_itemIcon22)
		ODT_WA_WEAPON22_IMG:SetHidden(false)
		ODT_WA_WEAPON22_PCENT:SetText(ODT_itemCharge .. "%")
		ODT_ItemLink22 = ODT_ItemLink
	else
		ODT_WA_WEAPON22_IMG:SetHidden(true)
		ODT_ItemLink22 = ""
	end
	
	ODT_ArmorRepair()
	
	if showStartMessage	== true then
		ODT_ShowMsgWeaponCharge1 = 1
		ODT_ShowMsgWeaponCharge2 = 1
		ODT_ShowMsgWeaponCharge3 = 1
		ODT_ShowMsgWeaponCharge4 = 1
		ODT_ShowMsgArmorBrocked = 1
	end
	
end
-------------------------------------------------------- 
-- ARMES : % de charge
-------------------------------------------------------- 
function ODT_WeaponsCharge(slot)
    local chargeInfo = {GetChargeInfoForItem(BAG_WORN, slot)}
	local charge = math.ceil(chargeInfo[1]/chargeInfo[2]*100)	
    local itemInfo = GetItemInfo(BAG_WORN, slot)
	ODT_ItemLink = GetItemLink(BAG_WORN, slot)
	ODT_itemIcon = itemInfo
	ODT_itemCharge = charge
	
	if string.find(itemInfo, "shield") or ODT_itemIcon == "/esoui/art/icons/icon_missing.dds" or string.find(charge, "-nan") then 
		charge = 999
		ODT_itemCharge = ""

		if 	slot == EQUIP_SLOT_MAIN_HAND then
			ODT_WA_WEAPON11_PCENT:SetHidden(true)
		elseif
			slot == EQUIP_SLOT_OFF_HAND then
			ODT_WA_WEAPON12_PCENT:SetHidden(true)
		elseif
			slot == EQUIP_SLOT_BACKUP_MAIN then
			ODT_WA_WEAPON21_PCENT:SetHidden(true)
		elseif
			slot == EQUIP_SLOT_BACKUP_OFF then
			ODT_WA_WEAPON22_PCENT:SetHidden(true)
		end
	else
		if 	slot == EQUIP_SLOT_MAIN_HAND then
			ODT_WA_WEAPON11_PCENT:SetHidden(false)
		elseif
			slot == EQUIP_SLOT_OFF_HAND then
			ODT_WA_WEAPON12_PCENT:SetHidden(false)
		elseif
			slot == EQUIP_SLOT_BACKUP_MAIN then
			ODT_WA_WEAPON21_PCENT:SetHidden(false)
		elseif
			slot == EQUIP_SLOT_BACKUP_OFF then
			ODT_WA_WEAPON22_PCENT:SetHidden(false)
		end
	end

	-------------------------------------------------------- 
	-- ARMES : Recharge automatique de l'enchantement
	-------------------------------------------------------- 
	if charge < 1 and ODT_WA_Recharge == true then
		local gem = ODT_GetSoulgem()
		if gem then
			ODT_MSG_SHOW(ODT_ItemLink .. GetString(weaponcharged), ODT_WA_SOUND_WEAPON)
			ChargeItemWithSoulGem(BAG_WORN, slot, BAG_BACKPACK, gem)

			local chargeInfo = {GetChargeInfoForItem(BAG_WORN, slot)}
			local charge = math.ceil(chargeInfo[1]/chargeInfo[2]*100)			
		else
			ODT_MSG_SHOW(ODT_ItemLink .. GetString(nosoulgem), ODT_WA_SOUND_WEAPON)
		end
		
	end

	if string.find(charge, "-nan") then
		ODT_itemCharge = "bug "
	end	
	
	
	-------------------------------------------------------- 
	-- ARMES : Couleur du taux %  / Affichage du message si % <10
	-------------------------------------------------------- 
	if 	charge > 50 then 
			-- Vert
			if 	slot == EQUIP_SLOT_MAIN_HAND then
				ODT_WA_WEAPON11_PCENT:SetColor(.5,1,0,1)
				ODT_ShowMsgWeaponCharge1 = 1
			elseif
				slot == EQUIP_SLOT_OFF_HAND then
				ODT_WA_WEAPON12_PCENT:SetColor(.5,1,0,1)
				ODT_ShowMsgWeaponCharge2 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_MAIN then
				ODT_WA_WEAPON21_PCENT:SetColor(.5,1,0,1)
				ODT_ShowMsgWeaponCharge3 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_OFF then
				ODT_WA_WEAPON22_PCENT:SetColor(.5,1,0,1)
				ODT_ShowMsgWeaponCharge4 = 1
			end
	elseif 
		-- jaune
		charge > 30 then 
			if 	slot == EQUIP_SLOT_MAIN_HAND then
				ODT_WA_WEAPON11_PCENT:SetColor(1,1,0,1)
				ODT_ShowMsgWeaponCharge1 = 1
			elseif
				slot == EQUIP_SLOT_OFF_HAND then
				ODT_WA_WEAPON12_PCENT:SetColor(1,1,0,1)
				ODT_ShowMsgWeaponCharge2 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_MAIN then
				ODT_WA_WEAPON21_PCENT:SetColor(1,1,0,1)
				ODT_ShowMsgWeaponCharge3 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_OFF then
				ODT_WA_WEAPON22_PCENT:SetColor(1,1,0,1)
				ODT_ShowMsgWeaponCharge4 = 1
			end
	elseif 
		-- orange
		charge > 3 then 
			if 	slot == EQUIP_SLOT_MAIN_HAND then
				ODT_WA_WEAPON11_PCENT:SetColor(1,.5,0,1)
				ODT_ShowMsgWeaponCharge1 = 1
			elseif
				slot == EQUIP_SLOT_OFF_HAND then
				ODT_WA_WEAPON12_PCENT:SetColor(1,.5,0,1)
				ODT_ShowMsgWeaponCharge2 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_MAIN then
				ODT_WA_WEAPON21_PCENT:SetColor(1,.5,0,1)
				ODT_ShowMsgWeaponCharge3 = 1
			elseif
				slot == EQUIP_SLOT_BACKUP_OFF then
				ODT_WA_WEAPON22_PCENT:SetColor(1,.5,0,1)
				ODT_ShowMsgWeaponCharge4 = 1
			end
	else
		-- rouge
			if 	slot == EQUIP_SLOT_MAIN_HAND then
				ODT_WA_WEAPON11_PCENT:SetColor(1,0,0,1)
				if ODT_ShowMsgWeaponCharge1 == 1 and ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds"  then
					if ODT_WA_WTX == true then 
						ODT_MSG_SHOW(ODT_ItemLink .. GetString(weaponwarning1), ODT_WA_SOUND_WEAPON)
						ODT_ShowMsgWeaponCharge1 = 0
					end
				end
			elseif
				slot == EQUIP_SLOT_OFF_HAND then
				ODT_WA_WEAPON12_PCENT:SetColor(1,0,0,1)
				if ODT_ShowMsgWeaponCharge2 == 1 and ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds"  then
					if ODT_WA_WTX == true then 
						ODT_MSG_SHOW(ODT_ItemLink .. GetString(weaponwarning2), ODT_WA_SOUND_WEAPON)
						ODT_ShowMsgWeaponCharge2 = 0
					end
				end
			elseif
				slot == EQUIP_SLOT_BACKUP_MAIN then
				ODT_WA_WEAPON21_PCENT:SetColor(1,0,0,1)
				if ODT_ShowMsgWeaponCharge3 == 1 and ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds"  then
					if ODT_WA_WTX == true then 
						ODT_MSG_SHOW(ODT_ItemLink .. GetString(weaponwarning3), ODT_WA_SOUND_WEAPON)
						ODT_ShowMsgWeaponCharge3 = 0
					end
				end
			elseif
				slot == EQUIP_SLOT_BACKUP_OFF then
				ODT_WA_WEAPON22_PCENT:SetColor(1,0,0,1)
				if ODT_ShowMsgWeaponCharge4 == 1 and ODT_itemIcon ~= "/esoui/art/icons/icon_missing.dds"  then
					if ODT_WA_WTX == true then 
						ODT_MSG_SHOW(ODT_ItemLink .. GetString(weaponwarning4), ODT_WA_SOUND_WEAPON)
						ODT_ShowMsgWeaponCharge4 = 0
					end
				end
			end
	end

end

-------------------------------------------------------- 
-- Pierre d'âme pour recharge d'arme
-------------------------------------------------------- 
function ODT_GetSoulgem()
	local result, tier = false, 0
    local bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)
    
	for _,data in pairs(bag) do
        if IsItemSoulGem(SOUL_GEM_TYPE_FILLED,BAG_BACKPACK,data.slotIndex) then
            local geminfo = GetSoulGemItemInfo(BAG_BACKPACK,data.slotIndex)
            if geminfo > tier then
				tier = geminfo;
				result = data.slotIndex 
			end
        end
    end
    
	return result
end

-------------------------------------------------------- 
-- ARMURE : % et coût réparation
-------------------------------------------------------- 
function ODT_ArmorRepair()
	bag = BAG_WORN
	local minval = 100
	local costs = 0
	local numSlots = GetBagSize(bag)

	for slot = 0, numSlots do
		local _, stack = GetItemInfo(bag, slot)
		if stack > 0 and GetItemCondition(bag, slot) < 100 then
			
			con = GetItemCondition(BAG_WORN, slot)
			if con < minval then
				minval = con
			end
			
			costs = costs + GetItemRepairCost(bag, slot)
			end
	end
	
	if 	minval > 50 then 
			-- Vert
			ODT_WA_ARMOR_PCENT:SetColor(.5,1,0,1)
			ODT_ShowMsgArmorBrocked = 1
	elseif 
		-- jaune
		minval > 30 then 
			ODT_WA_ARMOR_PCENT:SetColor(1,1,0,1)
			ODT_ShowMsgArmorBrocked = 1
	elseif 
		-- orange
		minval > 10 then 
			ODT_WA_ARMOR_PCENT:SetColor(1,.5,0,1)
			ODT_ShowMsgArmorBrocked = 1
	else
		-- rouge
			ODT_WA_ARMOR_PCENT:SetColor(1,0,0,1)
			if ODT_ShowMsgArmorBrocked == 1 then
				ODT_ShowMsgArmorBrocked = 0
				if ODT_WA_ATX == true then 
					ODT_MSG_SHOW(GetString(armorwarning), ODT_WA_SOUND_ARMOR)
				end 
			end
	end

	ODT_WA_ARMOR_PCENT:SetText(minval .. "%")
	ODT_WA_ARMOR_GOLD:SetText(costs)
end

--*********************************************************************
-- COMBAT 
--*********************************************************************
function ODT.OnPlayerCombatState(event, inCombat)
    if inCombat then  
		if ODT_HideCombat_BG == true then
			ODT_BG:SetHidden(true)
		end
		if ODT_HideCombat_CLOCK == true then
			ODT_Clock:SetHidden(true)
			ODT_ClocBG:SetHidden(true)
		end
		if ODT_HideCombat_CHRONO == true then
			ODT_Chrono:SetHidden(true)
			ODT_Chrono_BG:SetHidden(true)
		end
		if ODT_HideCombat_TIMER == true then
			ODT_timer:SetHidden(true)
			ODT_timer_BG:SetHidden(true)
		end
		if ODT_HideCombat_PERF == true then
			ODT_PERF:SetHidden(true)
			ODT_PERF_BG:SetHidden(true)
		end
		if ODT_HideCombat_INVENTORY == true then
			ODT_BAG:SetHidden(true)
			ODT_BAG_BG:SetHidden(true)
		end
		if ODT_HideCombat_STATS == true then
			ODT_WA:SetHidden(true)
			ODT_WA_BG:SetHidden(true)
		end
		if ODT_HideCombat_HORSE == true then
			ODT_HorseShow:SetHidden(true)
		end
		if ODT_HideCombat_STOLEN == true then
			ODT_STOLEN:SetHidden(true)
		end
	else
		--------------------------------------------------------
		-- Horloge
		--------------------------------------------------------
		if ODT_ShowClock == true then
			ODT_Clock:SetHidden(false)
		elseif ODT_ShowClock == false then
			ODT_Clock:SetHidden(true)
		end

		clocframex = 70
		clocframey = 50

		local fz = "$(MEDIUM_FONT)|" .. ODT_ShowClockFontSize
		ODT_ClocLbl:SetFont(fz)

		if     ODT_ShowClockFontSize == 12 then
				clocframex = 70
				clocframey = 50
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
			elseif ODT_ShowClockFontSize == 16 then
				clocframex = 70
				clocframey = 50
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
			elseif ODT_ShowClockFontSize == 20 then
				clocframex = 80
				clocframey = 50
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
			elseif ODT_ShowClockFontSize == 24 then
				clocframex = 90
				clocframey = 50
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
			elseif ODT_ShowClockFontSize == 28 then
				clocframex = 100
				clocframey = 65
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -10, 15)
			elseif ODT_ShowClockFontSize == 32 then
				clocframex = 130
				clocframey = 70
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
			elseif ODT_ShowClockFontSize == 36 then
				clocframex = 140
				clocframey = 75
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
			elseif ODT_ShowClockFontSize == 40 then
				clocframex = 155
				clocframey = 80
				ODT_ClocLbl:SetAnchor(TOPRIGHT, ODT_Clock, TOPRIGHT, -20, 15)
		end
		
		ODT_Clock:SetDimensions(clocframex, clocframey)
		
		ODT_ClocBG:SetDimensions(clocframex, clocframey)
		ODT_ClocBG:SetHidden(ODT_ShowClockBG)

		if ODT_ShowClockFontColor == "|cFFFFFFBlanc" then
			ODT_ClocLbl:SetColor(1,1,1)

		elseif ODT_ShowClockFontColor == "|cE6F702Jaune" then
			ODT_ClocLbl:SetColor(1,1,0)
			
		elseif ODT_ShowClockFontColor == "|c04D631Vert" then
			ODT_ClocLbl:SetColor(.5,1,0,1)
			
		elseif ODT_ShowClockFontColor == "|cF2AE04Orange" then
			ODT_ClocLbl:SetColor(1,.5,0,1)
			
		end

		--------------------------------------------------------
		-- Chronomètre
		--------------------------------------------------------
		if ODT_ShowChrono == true then
			ODT_Chrono:SetHidden(false)
		else
			ODT_Chrono:SetHidden(true)
		end
		ODT_Chrono_BG:SetHidden(ODT_ShowChronoBG)
		--------------------------------------------------------
		-- Timer
		--------------------------------------------------------
		if ODT_ShowTimer == true then
			ODT_timer:SetHidden(false)
		else
			ODT_timer:SetHidden(true)
		end
		ODT_timer_BG:SetHidden(ODT_ShowTimerBG)
		--------------------------------------------------------
		-- Performances
		--------------------------------------------------------
		if ODT_ShowPERF == true then
			ODT_PERF:SetHidden(false)
		else
			ODT_PERF:SetHidden(true)
		end
		ODT_PERF_BG:SetHidden(ODT_ShowPERFBG)
		--------------------------------------------------------
		-- Inventaire
		--------------------------------------------------------
		if ODT_ShowBag == true then
			ODT_BAG:SetHidden(false)
		else
			ODT_BAG:SetHidden(true)
		end
		ODT_BAG_BG:SetHidden(ODT_ShowBagBG)
		--------------------------------------------------------
		-- Armes & Armure
		--------------------------------------------------------
		if ODT_WA_ONOFF == true then
			ODT_WA:SetHidden(false)
		else
			ODT_WA:SetHidden(true)
		end
		ODT_WA_BG:SetHidden(ODT_WABG)
		
		--------------------------------------------------------
		-- Monture
		--------------------------------------------------------
		if ODT_HORSE == true then
			if ODT_HORSE_SHOWPERMA == true then
				ODT_HorseShow:SetHidden(false)
			end
		end
		-----------------------------------------------------
		-- VOL
		-----------------------------------------------------
		if ODT_ShowStolen == true then
			ODT_STOLEN:SetHidden(false)
		else
			ODT_STOLEN:SetHidden(true)
		end
		ODT_STOLEN_BG:SetHidden(ODT_ShowStolenBG)
		--------------------------------------------------------
		-- BackGround
		--------------------------------------------------------
		if ODT_BG_Show == true then
			ODT_BG:SetHidden(false)
		else
			ODT_BG:SetHidden(true)
		end 
		
	end

end
--*********************************************************************
-- Annonce de la mort d'un joueur
--*********************************************************************
function ODT_OnPlayerDead()
	odtMsgDeath = ""
	deathsendmsg = 0
	DeathListMsg = 0
	DeathInit = 1

--	SettingRed =		ZO_ColorDef:New("ff0000"),
--		SettingGreen =		ZO_ColorDef:New("99ff66"),
--		SettingOrange =		ZO_ColorDef:New("ff7b39"),

--print("----------")
--print(DeathInit)
--print("----------")

	odtDeadCount = 0
	odtRez = 0
	
	for i = 1, GetGroupSize() do
--print(i)
		
		group_role = GetGroupMemberSelectedRole("group"..i)

		if group_role == LFG_ROLE_DPS then
			group_role = "[DPS]"
		elseif group_role == LFG_ROLE_HEAL then
			group_role = "[HEAL]"
		elseif group_role == LFG_ROLE_TANK then
			group_role = "[TANK]"
		else 
			group_role = "[HORS CONNEXION]"
		end 

		group_accountname = "[" .. GetUnitDisplayName("group"..i) .. "]"
		group_playername = "[" .. GetUnitName("group"..i) .. "]"

		odtRez = 1
		odtdeadstatus = ""
		
		if IsUnitBeingResurrected("group"..i) then		
			odtdeadstatus = "inrez"
		elseif DoesUnitHaveResurrectPending("group"..i) then
			odtdeadstatus = "isrez"
		elseif IsUnitDead("group"..i) then
			odtdeadstatus = "dead"
		end 
		
		if odtdeadstatus == "inrez" then		
			odtMsgDeath = odtMsgDeath .. "\nRésurrection en cours → " .. group_accountname .. "   " .. group_playername .. "   " .. group_role
			
			if ODT_ShowDeathRez == true then
				if i == 1 and ODTStillRez01 == 0 then
					ODTStillRez01 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 2 and ODTStillRez02 == 0 then
					ODTStillRez02 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 3 and ODTStillRez03 == 0 then
					ODTStillRez03 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 4 and ODTStillRez04 == 0 then
					ODTStillRez04 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 5 and ODTStillRez05 == 0 then
					ODTStillRez05 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 6 and ODTStillRez06 == 0 then
					ODTStillRez06 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 7 and ODTStillRez07 == 0 then
					ODTStillRez07 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 8 and ODTStillRez08 == 0 then
					ODTStillRez08 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 9 and ODTStillRez09 == 0 then
					ODTStillRez09 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 10 and ODTStillRez10 == 0 then
					ODTStillRez10 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 11 and ODTStillRez11 == 0 then
					ODTStillRez11 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 12 and ODTStillRez12 == 0 then
					ODTStillRez12 = 1
					print("|cff7b39Résurrection en cours : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
			end
		else
			if i == 1 then 
				ODTStillRez01 =0 
			end
			if i == 2 then 
				ODTStillRez02 =0 
			end
			if i == 3 then 
				ODTStillRez03 =0 
			end
			if i == 4 then 
				ODTStillRez04 =0 
			end
			if i == 5 then 
				ODTStillRez05 =0 
			end
			if i == 6 then 
				ODTStillRez06 =0
			end
			if i == 7 then 
				ODTStillRez07 =0 
			end
			if i == 8 then 
				ODTStillRez08 =0 
			end 
			if i == 9 then 
				ODTStillRez08 =0 
			end
			if i == 10 then 
				ODTStillRez10=0 
			end
			if i == 11 then 
				ODTStillRez11=0 
			end 
			if i == 12 then 
				ODTStillRez12=0 
			end

		end 

		if odtdeadstatus == "isrez" then
			odtMsgDeath = odtMsgDeath .. "\nRescucité(e) → " .. group_accountname .. "   " .. group_playername .. "   " .. group_role
			odtRez = 1
			
			if ODT_ShowDeathRez == true then
				if i == 1 and ODTIsRez01 == 0 then
					ODTIsRez01 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 2 and ODTIsRez02 == 0 then
					ODTIsRez02 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 3 and ODTIsRez03 == 0 then
					ODTIsRez03 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 4 and ODTIsRez04 == 0 then
					ODTIsRez04 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 5 and ODTIsRez05 == 0 then
					ODTIsRez05 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 6 and ODTIsRez06 == 0 then
					ODTIsRez06 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 7 and ODTIsRez07 == 0 then
					ODTIsRez07 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 8 and ODTIsRez08 == 0 then
					ODTIsRez08 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 9 and ODTIsRez09 == 0 then
					ODTIsRez09 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 10 and ODTIsRez10 == 0 then
					ODTIsRez10 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 11 and ODTIsRez11 == 0 then
					ODTIsRez11 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 12 and ODTIsRez12 == 0 then
					ODTIsRez12 = 1
					print("|c99ff66Rescucité(e) : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
			end
		else
			if i == 1 then 
				ODTIsRez01 =0 
			end
			if i == 2 then 
				ODTIsRez02 =0 
			end
			if i == 3 then 
				ODTIsRez03 =0 
			end
			if i == 4 then 
				ODTIsRez04 =0 
			end
			if i == 5 then 
				ODTIsRez05 =0 
			end
			if i == 6 then 
				ODTIsRez06 =0
			end
			if i == 7 then 
				ODTIsRez07 =0 
			end
			if i == 8 then 
				ODTIsRez08 =0 
			end 
			if i == 9 then 
				ODTIsRez08 =0 
			end
			if i == 10 then 
				ODTIsRez10=0 
			
			end
			if i == 11 then 
				ODTIsRez11=0 
			end 
			if i == 12 then 
				ODTIsRez12=0 
			end
		end
		
		
		if odtdeadstatus == "dead" then
			DeathListMsg = 1
			deathsendmsg = 1
			odtDeadCount = odtDeadCount + 1

			odtMsgDeath = odtMsgDeath .. "\n|cff0000" .. group_accountname .. "   " .. group_playername .. "   " .. group_role
			
			if ODT_ShowDeathChat == true then
				if i == 1 and ODTStillDead01 == 0 then
					ODTStillDead01 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 2 and ODTStillDead02 == 0 then
					ODTStillDead02 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 3 and ODTStillDead03 == 0 then
					ODTStillDead03 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 4 and ODTStillDead04 == 0 then
					ODTStillDead04 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 5 and ODTStillDead05 == 0 then
					ODTStillDead05 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 6 and ODTStillDead06 == 0 then
					ODTStillDead06 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 7 and ODTStillDead07 == 0 then
					ODTStillDead07 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 8 and ODTStillDead08 == 0 then
					ODTStillDead08 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 9 and ODTStillDead09 == 0 then
					ODTStillDead09 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 10 and ODTStillDead10 == 0 then
					ODTStillDead10 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 11 and ODTStillDead11 == 0 then
					ODTStillDead11 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
				if i == 12 and ODTStillDead12 == 0 then
					ODTStillDead12 = 1
					print("|cff0000MORT : " .. group_accountname .. "   " .. group_playername .. "   " .. group_role)
				end 
			end
		else
			if i == 1 then 
				ODTStillDead01 =0 
			end
			if i == 2 then 
				ODTStillDead02 =0 
			end
			if i == 3 then 
				ODTStillDead03 =0 
			end
			if i == 4 then 
				ODTStillDead04 =0 
			end
			if i == 5 then 
				ODTStillDead05 =0 
			end
			if i == 6 then 
				ODTStillDead06 =0
			end
			if i == 7 then 
				ODTStillDead07 =0 
			end
			if i == 8 then 
				ODTStillDead08 =0 
			end 
			if i == 9 then 
				ODTStillDead08 =0 
			end
			if i == 10 then 
				ODTStillDead10=0 
			end
			if i == 11 then 
				ODTStillDead11=0 
			end 
			if i == 12 then 
				ODTStillDead12=0 
			end
		end 
		
	end

		if MemodtMsgDeath == nil or MemodtMsgDeath == "" then
			MemodtMsgDeath = odtMsgDeath
			ODT_DeathAnnounce()		
		else		
			if MemodtMsgDeath == odtMsgDeath then
				donothing = true
			else
				MemodtMsgDeath = odtMsgDeath
				ODT_DeathAnnounce()		
			end
		end
		if odtDeadCount == 0 then
			MemodtMsgDeath = ""
			ODT_MSGDEATHLIST:SetHidden(true)
		end
	
end

function ODT_DeathAnnounce()
	if deathsendmsg == 1 then
		if odtRez == 0 then
			ODT_Playsound(ODT_ShowDeathSnd)
		end 
		if ODT_ShowDeath == true then
			ODT_Playsound(ODT_ShowDeathSnd)
			if ODT_ShowDeathMsg == true then
				ODT_MSGDEATH_SHOW("MORT(S) : \n"..odtMsgDeath, 0)
			end
		end
	end 
	
	if ODT_ShowDeathList == true then
		if DeathListMsg == 1 then 
			ODT_MSGDEATHLIST:SetHidden(false)
			ODT_MSGDEATHLIST_List:SetText("Liste des morts : \n" .. odtMsgDeath)
		end
	end 
end


--*********************************************************************
-- PlaySound
--*********************************************************************
function ODT_Playsound(value)

	if value == 0     then ps = "OFF"
		elseif value == 1 then ps = "MAIL_SENT" 
		elseif value == 2 then ps = "NEW_MAIL"
		elseif value == 3 then ps = "VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE" 
		elseif value == 4 then ps = "VOICE_CHAT_MENU_CHANNEL_JOINED"
		elseif value == 5 then ps = "VOICE_CHAT_MENU_CHANNEL_LEFT"
		elseif value == 6 then ps = "EMPEROR_DEPOSED_ALDMERI"
		elseif value == 7 then ps = "AVA_GATE_CLOSED"
		elseif value == 8 then ps = "NEW_NOTIFICATION"
		elseif value == 9 then ps= "QUICKSLOT_SET"
		elseif value == 10 then ps= "BLACKSMITH_EXTRACTED_BOOSTER"
		elseif value == 11 then ps= "SMITHING_OPENED"
		elseif value == 12 then ps= "GROUP_DISBAND"
		elseif value == 13 then ps= "Champion_ZoomIn"
		elseif value == 14 then ps= "Champion_ZoomOut"
		elseif value == 15 then ps= "Champion_StarLocked"
		elseif value == 16 then ps= "Champion_PointsCommitted"
		elseif value == 17 then ps= "Champion_PointGained"
		elseif value == 18 then ps= "Champion_CycledToMage"
		elseif value == 19 then ps= "BooCollection_Completed"
		elseif value == 20 then ps= "ACHIEVEMENT_AWARDED"
		elseif value == 21 then ps= "BG_CountDown_Finish"
		elseif value == 22 then ps= "BG_One_Minute_Warning"
		elseif value == 23 then ps= "BG_MatchWon"
		elseif value == 24 then ps= "BG_MatchLost"
		elseif value == 25 then ps= "Alchemy_Create_Tooltip_Glow_Fail"
		elseif value == 26 then ps= "Champion_SystemUnlocked"
	end 
	
	PlaySound(ps) 

end

--*********************************************************************
-- MESSAGE SPECIAL
--*********************************************************************
function ODT_MSGSPECIAL_SHOW(odtMsg)
	ODT_MSGSPECIAL_INFO:SetText(odtMsg)
	ODT_MSGSPECIAL:SetHidden(false)
end
function ODT_MSGSPECIAL_HIDE()
print(hide)
	ODT_MSGSPECIAL:SetHidden(true)
end

--*********************************************************************
-- MESSAGE D'ALERTE
--*********************************************************************
function ODT_MSG_SHOW(odtMsg, ps)
	ODT_MSG_INFO:SetText(odtMsg)
	ODT_MSG:SetHidden(false)
	zo_callLater(function() ODT_MSG_HIDE() end, 3000)
	ODT_Playsound(ps)
end
function ODT_MSG_HIDE()
	ODT_MSG:SetHidden(true)
end

--*********************************************************************
-- MESSAGE D'ALERTE MORT
--*********************************************************************
function ODT_MSGDEATH_SHOW(odtMsg, ps)
	ODT_MSG_DEATH_NAME:SetText(odtMsg)
	iconFile = "/esoui/art/icons/death_recap_bleed.dds"
	ODT_MSG_DEATH_ICON:SetTexture(iconFile)	
	ODT_MSGDEATH:SetHidden(false)
	zo_callLater(function() ODT_MSGDEATH_HIDE() end, 3000)
	ODT_Playsound(ps)
end
function ODT_MSGDEATH_HIDE()
	ODT_MSGDEATH:SetHidden(true)
end

--*********************************************************************
-- Open Store
--*********************************************************************
function ODT_OpenStore()
	--*********************************************************************
	-- Mise à jour du coût de réparation
	--*********************************************************************
	ODT_WeaponsAndArmor()

	--*********************************************************************
	-- Initalisation du montant d'objets volés vendus
	--*********************************************************************
	local bagSize, bagUsed, bagFree = GetBagSize(1), GetNumBagUsedSlots(1), GetNumBagFreeSlots(1)
	OpenStoreGold = GetCurrentMoney()
	CloseStoreGold = 0
	
	OpenStoreitemStolen = 0
	for id = 1, bagUsed, 1 do
		if IsItemStolen(1, id) == true then
  			OpenStoreitemStolen = OpenStoreitemStolen + 1
		end
	end
end
--*********************************************************************
-- Close Store
--*********************************************************************
function ODT_CloseStore()
	--*********************************************************************
	-- Mise à jour du coût de réparation
	--*********************************************************************
	ODT_WeaponsAndArmor()
	
	--*********************************************************************
	-- Calcul du montant d'objets volés vendus
	--*********************************************************************
	local bagSize, bagUsed, bagFree = GetBagSize(1), GetNumBagUsedSlots(1), GetNumBagFreeSlots(1)
	CloseStoreGold = GetCurrentMoney()
	
	CloseStoreitemStolen = 0
	for id = 1, bagUsed, 1 do
		if IsItemStolen(1, id) == true then
  			CloseStoreitemStolen = CloseStoreitemStolen + 1
		end
	end
	if CloseStoreitemStolen	~= OpenStoreitemStolen then
		StolenMoney = CloseStoreGold - OpenStoreGold
	else
		StolenMoney	= 0
	end

	dDay = GetDateStringFromTimestamp(GetTimeStamp())		 
	if ODT.savedVariables.StolenDay == dDay then
		if StolenMoney > 0 then
			StolenDayAmount = ODT.savedVariables.StolenDayAmount + StolenMoney
			ODT.savedVariables.StolenDayAmount = StolenDayAmount
			StolenMoney = 0
		end
	end
	
	ODT_Stolen()

	OpenStoreGold = 0
	CloseStoreGold = 0
	
end

--*********************************************************************
-- [POWER UPDATE : ANNONCE DE MORT DE COMPAGNON
--*********************************************************************

local function ODT_OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if string.match(unitTag, "companion") then 
		local unitIndex = { zo_strsplit("c", unitTag) }		
		group_accountname = "[" .. GetUnitDisplayName(unitIndex[1]) .. "]"

		odtMsgDeath = odtMsgDeath .. "\n|cff0000compagnon de " .. group_accountname

		if (powerType==POWERTYPE_HEALTH) and powerValue == 0 then
			DeathListMsg = 1
			deathsendmsg = 1
			if ODT_ShowDeathChat == true then
				if unitIndex[1] == "group1" and ODTStillCompanionDead01 == 0 then
					ODTStillCompanionDead01 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group2" and ODTStillCompanionDead02 == 0 then
					ODTStillCompanionDead02 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group3" == 3 and ODTStillCompanionDead03 == 0 then
					ODTStillCompanionDead03 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group4" and ODTStillCompanionDead04 == 0 then
					ODTStillCompanionDead04 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group5" and ODTStillCompanionDead05 == 0 then
					ODTStillCompanionDead05 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group6" and ODTStillCompanionDead06 == 0 then
					ODTStillCompanionDead06 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group7" and ODTStillCompanionDead07 == 0 then
					ODTStillCompanionDead07 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group8" and ODTStillCompanionDead08 == 0 then
					ODTStillCompanionDead08 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group9" and ODTStillCompanionDead09 == 0 then
					ODTStillCompanionDead09 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group10" and ODTStillCompanionDead10 == 0 then
					ODTStillCompanionDead10 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group11" and ODTStillCompanionDead11 == 0 then
					ODTStillCompanionDead11 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
				if unitIndex[1] == "group12" and ODTStillCompanionDead12 == 0 then
					ODTStillCompanionDead12 = 1
					print("|cff0000MORT : compagnon de " .. group_accountname)
				end 
			end
			
			ODT_DeathAnnounce()
		end
		
		if (powerType==POWERTYPE_HEALTH) and powerValue ~= 0 then
			if unitIndex[1] == "group1" then 
				ODTStillCompanionDead01 =0 
			end
			if unitIndex[1] == "group2" then 
				ODTStillCompanionDead02 =0 
			end
			if unitIndex[1] == "group3" then 
				ODTStillCompanionDead03 =0 
			end
			if unitIndex[1] == "group4" then 
				ODTStillCompanionDead04 =0 
			end
			if unitIndex[1] == "group5" then 
				ODTStillCompanionDead05 =0 
			end
			if unitIndex[1] == "group6" then 
				ODTStillCompanionDead06 =0
			end
			if unitIndex[1] == "group7" then 
				ODTStillCompanionDead07 =0 
			end
			if unitIndex[1] == "group8" then 
				ODTStillCompanionDead08 =0 
			end 
			if unitIndex[1] == "group9" then 
				ODTStillCompanionDead08 =0 
			end
			if unitIndex[1] == "group10" then 
				ODTStillCompanionDead10=0 
			end
			if unitIndex[1] == "group11" then 
				ODTStillCompanionDead11=0 
			end 
			if unitIndex[1] == "group12" then 
				ODTStillCompanionDead12=0 
			end
		end 
	end

end

--*********************************************************************
-- [KEY] Chronomètre ON/OFF 
--*********************************************************************
function ODTToggleChronoONOFF()
	if ODT_Chrono_ONOFF == "ON" then
		ODT_Chrono_ONOFF = "OFF"
		ODT_ChronoStop:SetHidden(true)	
	else
		ODT_ChronoStart = GetTimeStamp()	
		ODT_Chrono_ONOFF = "ON"
		ODT_ChronoStop:SetHidden(false)	
	end
end

--*********************************************************************
-- [KEY] Horloge affichée/masquée
--*********************************************************************
function ODTToggleClock()
	if ODT_ShowClock == true then
		ODT_ShowClock = false
	else
		ODT_ShowClock = true
	end 
	
	if ODT_ShowClock == true then
		ODT_Clock:SetHidden(false)
	elseif ODT_ShowClock == false then
		ODT_Clock:SetHidden(true)
	end
end

--*********************************************************************
-- [KEY] Chronomètre affiché/masqué
--*********************************************************************
function ODTToggleChrono()
	if ODT_ShowChrono == true then
		ODT_Chrono:SetHidden(true)
		ODT_ShowChrono = false
	else
		ODT_Chrono:SetHidden(false)
		ODT_ShowChrono = true
	end 
end

--*********************************************************************
-- [KEY] Timer affiché/masqué
--*********************************************************************
function ODTToggleTimer()
	if ODT_ShowTimer == true then
		ODT_timer:SetHidden(true)
		ODT_ShowTimer = false
	else
		ODT_timer:SetHidden(false)
		ODT_ShowTimer = true
	end 
end

--*********************************************************************
-- [KEY] Timer ON/OFF
--*********************************************************************
function ODTToggleTimerONOFF()
	if ODT_Timer_ONOFF == "OFF" then
		ODT_timerStartCliked()
	else
		ODT_timerStopCliked()	
	end
end

--*********************************************************************
-- [KEY] Performances affichées/masquées
--*********************************************************************
function ODTTogglePERF()
	if ODT_ShowPERF == true then
		ODT_PERF:SetHidden(true)
		ODT_ShowPERF = false
	else
		ODT_PERF:SetHidden(false)
		ODT_ShowPERF = true
	end 

end

--*********************************************************************
-- [KEY] Performances affichées/masquées
--*********************************************************************
function ODTToggleSTATS()
	if ODT_WA_ONOFF == true then
		ODT_WA:SetHidden(true)
		ODT_WA_ONOFF = false
	else
		ODT_WA:SetHidden(false)
		ODT_WA_ONOFF = true
	end 

end

--*********************************************************************
-- [KEY] Reload UI
--*********************************************************************
function ODTToggleRLUI()
	ReloadUI()
end

--*********************************************************************
-- [KEY] FR/EN
--*********************************************************************
function ODTToggleFREN()
	if ODT.savedVariables.FREN == "FR" then
		SetCVar("Language.2", "en")
		ODT.savedVariables.FREN = "EN"
	else
		SetCVar("Language.2", "fr")
		ODT.savedVariables.FREN = "FR"
	end
end


--*********************************************************************
-- [KEY] HEAVY SACK
--*********************************************************************
function ODTToggleSENDSACK()
	iconFile = "/esoui/art/icons/item_generic_coinbag.dds"
	iconprint = zo_iconFormat(iconFile, 20, 20)	
	msg = "|c04D631[ODT] : " .. iconprint .."|cCCFFFF Sac Lourd || Heavy Sack ← Message envoyé dans le chat"
print(msg)
	ZO_ChatWindowTextEntryEditBox:SetText("/g → Sac Lourd | Heavy Sack")
end

--*********************************************************************
-- [KEY] HEAVY CHEST
--*********************************************************************
function ODTToggleSENDCHEST()
	iconFile = "/esoui/art/icons/housing_bre_con_treasurechest001.dds"
	iconprint = zo_iconFormat(iconFile, 20, 20)	
	msg = "|c04D631[ODT] : " .. iconprint .."|cCCFFFF Coffre || Chest ← Message envoyé dans le chat"
print(msg)
	ZO_ChatWindowTextEntryEditBox:SetText("/g → Coffre | Chest")
end

--*********************************************************************
-- ARRONDI
--*********************************************************************
function Round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

--*********************************************************************
-- INITIALISATION
--*********************************************************************

------------------------------------------------------------
-- Init XML
------------------------------------------------------------
function XML_ODT_Navigation(control, option)
	ODT_Reload(control, option)
end

------------------------------------------------------------
-- Initialisation savedVariables
------------------------------------------------------------
function ODTAddon:Initialize()

end

------------------------------------------------------------
-- Initialisation du Control Panel (Settings)
------------------------------------------------------------
function addon_Initialise()

	local LAM = LibStub("LibAddonMenu-2.0")

 	local panelData =
	{
		type = "panel",
		name = ODT.addonName,
		displayName = ODT.addonName,
		author = ODT.Author,
		version = ODT.version,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://orbedutemps.free.fr/forums/index.php",
	}
	
	local optionsTable = 
	{
		-----------------------------------------------------
		-- Général
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingBlue:Colorize(GetString(submenu_globals)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_LOCKWINDOWS), 
					getFunc = function() return ODT_LOCKWINDOWS end,
					setFunc = function(value)
								ODT_LOCKWINDOWS = value
								changed = true	
					end,
					default = false
				},
			}
		},
		
		-----------------------------------------------------
		-- BackGround
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingBlue:Colorize(GetString(submenu_background)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_BG_Show), 
					getFunc = function() return ODT_BG_Show end,
					setFunc = function(value)
								ODT_BG_Show = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_BGX),
					min = 0, max = 1920, step = 10, 
					getFunc = function() return ODT_BGX end,
					setFunc = function(value)
								ODT_BGX = value
								ODT_BG_BG:SetWidth(ODT_BGX)
								changed = true	
					end,
					disabled = function() return ODT_BG_Show == false end,
					default = 240
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_BGY),
					min = 0, max = 1080, step = 10, 
					getFunc = function() return ODT_BGY end,
					setFunc = function(value)
								ODT_BGY = value
								ODT_BG_BG:SetHeight(ODT_BGY)
								changed = true	
					end,
					disabled = function() return ODT_BG_Show == false end,
					default = 80
				},
			}
		},
		
		-----------------------------------------------------
		-- Hide in Combat
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGray:Colorize(GetString(submenu_HideCombat)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_GLOBAL), 
					getFunc = function() return ODT_HideCombat_GLOBAL end,
					setFunc = function(value)
								ODT_HideCombat_GLOBAL = value
								changed = true	
					end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_BG), 
					getFunc = function() return ODT_HideCombat_BG end,
					setFunc = function(value)
								ODT_HideCombat_BG = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_CLOCK), 
					getFunc = function() return ODT_HideCombat_CLOCK end,
					setFunc = function(value)
								ODT_HideCombat_CLOCK = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_CHRONO), 
					getFunc = function() return ODT_HideCombat_CHRONO end,
					setFunc = function(value)
								ODT_HideCombat_CHRONO = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_TIMER), 
					getFunc = function() return ODT_HideCombat_TIMER end,
					setFunc = function(value)
								ODT_HideCombat_TIMER = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_PERF), 
					getFunc = function() return ODT_HideCombat_PERF end,
					setFunc = function(value)
								ODT_HideCombat_PERF = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_INVENTORY), 
					getFunc = function() return ODT_HideCombat_INVENTORY end,
					setFunc = function(value)
								ODT_HideCombat_INVENTORY = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_STATS), 
					getFunc = function() return ODT_HideCombat_STATS end,
					setFunc = function(value)
								ODT_HideCombat_STATS = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_HORSE), 
					getFunc = function() return ODT_HideCombat_HORSE end,
					setFunc = function(value)
								ODT_HideCombat_HORSE = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_HideCombat_STOLEN), 
					getFunc = function() return ODT_HideCombat_STOLEN end,
					setFunc = function(value)
								ODT_HideCombat_STOLEN = value
								changed = true	
					end,
					disabled = function() return ODT_HideCombat_GLOBAL == true end,
					default = false
				},
			}
		},
		
		-----------------------------------------------------
		-- Horloge
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_clock)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowClock), 
					getFunc = function() return ODT_ShowClock end,
					setFunc = function(value)
								ODT_ShowClock = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowClockFontSize),
					min = 12, max = 40, step = 4, 
					getFunc = function() return ODT_ShowClockFontSize end,
					setFunc = function(value)
								ODT_ShowClockFontSize = value
								changed = true	
					end,
					disabled = function() return ODT_ShowClock == false end,
					default = 16
				},
				{
					type = "dropdown",
					name = GetString(submenu_ODT_ShowClockFontColor),
					choices = {"|cFFFFFFBlanc", "|cE6F702Jaune", "|c04D631Vert", "|cF2AE04Orange"},
					getFunc = function() return ODT_ShowClockFontColor end,
					setFunc = function(value)
								ODT_ShowClockFontColor = value
								changed = true	
					end,
					disabled = function() return ODT_ShowClock == false end,
					default = "|c04D631Vert"
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowClockBG), 
					getFunc = function() return ODT_ShowClockBG end,
					setFunc = function(value)
								ODT_ShowClockBG = value
								changed = true	
					end,
					disabled = function() return ODT_ShowClock == false end,
					default = true
				},
			}
		},
	
		-----------------------------------------------------
		-- Chronomètre
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_chrono)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowChrono), 
					getFunc = function() return ODT_ShowChrono end,
					setFunc = function(value)
								ODT_ShowChrono = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowChronoFontSize),
					min = 12, max = 40, step = 4, 
					getFunc = function() return ODT_ShowChronoFontSize end,
					setFunc = function(value)
								ODT_ShowChronoFontSize = value
								changed = true	
					end,
					disabled = function() return ODT_ShowChrono == false end,
					default = 16
				},
				{
					type = "dropdown",
					name = GetString(submenu_ODT_ShowChronoFontColor),
					choices = {"|cFFFFFFBlanc", "|cE6F702Jaune", "|c04D631Vert", "|cF2AE04Orange"},
					getFunc = function() return ODT_ShowChronoFontColor end,
					setFunc = function(value)
								ODT_ShowChronoFontColor = value
								changed = true	
					end,
					disabled = function() return ODT_ShowChrono == false end,
					default = "|c04D631Vert"

				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowChronoBG), 
					getFunc = function() return ODT_ShowChronoBG end,
					setFunc = function(value)
								ODT_ShowChronoBG = value
								changed = true	
					end,
					disabled = function() return ODT_ShowChrono == false end,
					default = true
				}
			}
		},

		-----------------------------------------------------
		-- Timer
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_timer)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowTimer), 
					getFunc = function() return ODT_ShowTimer end,
					setFunc = function(value)
								ODT_ShowTimer = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowTimerFontSize),
					min = 12, max = 40, step = 4, 
					getFunc = function() return ODT_ShowTimerFontSize end,
					setFunc = function(value)
								ODT_ShowTimerFontSize = value
								changed = true	
					end,
					disabled = function() return ODT_ShowTimer == false end,
					default = 16
				},
				{
					type = "dropdown",
					name = GetString(submenu_ODT_ShowTimerFontColor),
					choices = {"|cFFFFFFBlanc", "|cE6F702Jaune", "|c04D631Vert", "|cF2AE04Orange"},
					getFunc = function() return ODT_ShowTimerFontColor end,
					setFunc = function(value)
								ODT_ShowTimerFontColor = value
								changed = true	
					end,
					disabled = function() return ODT_ShowTimer == false end,
					default = "|c04D631Vert"

				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowTimerBG), 
					getFunc = function() return ODT_ShowTimerBG end,
					setFunc = function(value)
								ODT_ShowTimerBG = value
								changed = true	
					end,
					disabled = function() return ODT_ShowTimer == false end,
					default = true
				},
				{
					type = "editbox",
					name = GetString(submenu_ODT_Timer_Seconds ), 
					getFunc = function() return ODT_Timer_Seconds end,
					setFunc = function(value)
								ODT_Timer_Seconds = value
								changed = true	
					end,
					disabled = function() return ODT_ShowTimer == false end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_Timer_SOUND),
					tooltip	= GetString(submenu_ODT_Timer_SOUND_TOOLTIP), 					
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Timer_SOUND end,
					setFunc = function(value)
								ODT_Timer_SOUND = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_ShowTimer == false end,
					default = 0
				},
			}
		},

		-----------------------------------------------------
		-- Performances
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_perf)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowPERF),
					getFunc = function() return ODT_ShowPERF end,
					setFunc = function(value)
								ODT_ShowPERF = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowPERFBG), 
					getFunc = function() return ODT_ShowPERFBG end,
					setFunc = function(value)
								ODT_ShowPERFBG = value
								changed = true	
					end,
					disabled = function() return ODT_ShowPERF == false end,
					default = true
				},
			}
		},
		
		-----------------------------------------------------
		-- Inventaire
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_inventory)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowBag), 
					getFunc = function() return ODT_ShowBag end,
					setFunc = function(value)
								ODT_ShowBag = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowBagBG),
					getFunc = function() return ODT_ShowBagBG end,
					setFunc = function(value)
								ODT_ShowBagBG = value
								changed = true	
					end,
					disabled = function() return ODT_ShowBag == false end,
					default = true
				},
			}
		},
		
		-----------------------------------------------------
		-- Armes & armures
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingGreen:Colorize(GetString(submenu_WA_STATS)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_WA_ONOFF), 
					tooltip = GetString(submenu_WA_STATS_TOOLTIP),
					getFunc = function() return ODT_WA_ONOFF end,
					setFunc = function(value)
								ODT_WA_ONOFF = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_WABG), 
					getFunc = function() return ODT_WABG end,
					setFunc = function(value)
								ODT_WABG = value
								changed = true	
					end,
					disabled = function() return ODT_WA_ONOFF == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_WA_ATX), 
					tooltip	= GetString(submenu_ODT_WA_ATX_TOOLTIP), 					
					getFunc = function() return ODT_WA_ATX end,
					setFunc = function(value)
								ODT_WA_ATX = value
								changed = true	
					end,
					disabled = function() return ODT_WA_ONOFF == false end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_WA_SOUND_ARMOR),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_WA_SOUND_ARMOR end,
					setFunc = function(value)
								ODT_WA_SOUND_ARMOR = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_WA_ATX == false or ODT_WA_ONOFF == false end,
					default = 0
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_WA_WTX),
					tooltip	= GetString(submenu_ODT_WA_WTX_TOOLTIP), 
					getFunc = function() return ODT_WA_WTX end,
					setFunc = function(value)
								ODT_WA_WTX = value
								changed = true	
					end,
					disabled = function() return ODT_WA_ONOFF == false end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_WA_SOUND_WEAPON),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_WA_SOUND_WEAPON end,
					setFunc = function(value)
								ODT_WA_SOUND_WEAPON = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_WA_WTX == false or ODT_WA_ONOFF == false end,
					default = 0
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_WA_Recharge),
					tooltip	= GetString(submenu_ODT_WA_Recharge_TOOLTIP), 
  					getFunc = function() return ODT_WA_Recharge end,
 					setFunc = function(value)
								ODT_WA_Recharge = value
								changed = true	
					end,
					disabled = function() return ODT_WA_ONOFF == false end,
					default = true
				},
			}
		},

		-----------------------------------------------------
		-- Nourriture / Boisson
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingIce:Colorize(GetString(submenu_food)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowFOOD), 
					getFunc = function() return ODT_ShowFOOD end,
					setFunc = function(value)
								ODT_ShowFOOD = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowFOOD_TIME),
					tooltip	= GetString(submenu_ODT_ShowFOOD_TIME_TOOLTIP), 
					min = 1, max = 5, step = 1, 
					getFunc = function() return ODT_ShowFOOD_TIME end,
					setFunc = function(value)
								ODT_ShowFOOD_TIME = value
								changed = true	
					end,
					disabled = function() return ODT_ShowFOOD == false end,
					default = 1
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowFOOD_POPDURATION),
					tooltip	= GetString(submenu_ODT_ShowFOOD_POPDURATION_TOOLTIP), 
					min = 0, max = 30, step = 1, 
					getFunc = function() return ODT_ShowFOOD_POPDURATION end,
					setFunc = function(value)
								ODT_ShowFOOD_POPDURATION = value
								changed = true	
					end,
					disabled = function() return ODT_ShowFOOD == false end,
					default = 8
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_ShowFOOD_SOUND),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_ShowFOOD_SOUND end,
					setFunc = function(value)
								ODT_ShowFOOD_SOUND = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_ShowFOOD == false end,
					default = 0
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowFOOD_CHECKONLOAD), 
					tooltip	= GetString(submenu_ODT_ShowFOOD_CHECKONLOAD_TOOLTIP), 
					getFunc = function() return ODT_ShowFOOD_CHECKONLOAD end,
					setFunc = function(value)
								ODT_ShowFOOD_CHECKONLOAD = value
								changed = true	
					end,
					disabled = function() return ODT_ShowFOOD == false end,
					default = false
				},
			}
		},

		-----------------------------------------------------
		-- XP Scroll
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingIce:Colorize(GetString(submenu_XPScroll)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_XPScroll), 
					getFunc = function() return ODT_ShowXPSCROLL end,
					setFunc = function(value)
								ODT_ShowXPSCROLL = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_XPScroll_POPDURATION),
					tooltip	= GetString(submenu_ODT_XPScroll_POPDURATION_TOOLTIP), 
					min = 0, max = 30, step = 1, 
					getFunc = function() return ODT_ShowXPSCROLL_POPDURATION end,
					setFunc = function(value)
								ODT_ShowXPSCROLL_POPDURATION = value
								changed = true	
					end,
					disabled = function() return ODT_ShowXPSCROLL == false end,
					default = 8
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_XPScroll_SOUND),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_ShowXPSCROLL_SOUND end,
					setFunc = function(value)
								ODT_ShowXPSCROLL_SOUND = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_ShowXPSCROLL == false end,
					default = 0
				},
			}
		},
				
		-----------------------------------------------------
		-- Monture
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingIce:Colorize(GetString(submenu_horse)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_HORSE), 
					getFunc = function() return ODT_HORSE end,
					setFunc = function(value)
								ODT_HORSE = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_HORSE_SHOWPERMA), 
					tooltip	= GetString(submenu_ODT_HORSE_SHOWPERMA_TOOLTIP), 
					getFunc = function() return ODT_HORSE_SHOWPERMA end,
					setFunc = function(value)
								ODT_HORSE_SHOWPERMA = value
								changed = true	
					end,
					disabled = function() return ODT_HORSE == false end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_HORSE_SHOWBG), 
					getFunc = function() return ODT_HORSE_SHOWBG end,
					setFunc = function(value)
								ODT_HORSE_SHOWBG = value
								changed = true	
					end,
					disabled = function() return ODT_HORSE_SHOWPERMA == false end,
					default = false
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_HORSE_SHOWTIME),
					tooltip	= GetString(submenu_ODT_HORSE_SHOWTIME_TOOLTIP), 
					min = 0, max = 30, step = 1, 
					getFunc = function() return ODT_HORSE_SHOWTIME end,
					setFunc = function(value)
								ODT_HORSE_SHOWTIME = value
								changed = true	
					end,
					disabled = function() return ODT_HORSE == false end,
					default = 8
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_HORSE_SOUND),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_HORSE_SOUND end,
					setFunc = function(value)
								ODT_HORSE_SOUND = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_HORSE == false end,
					default = 0
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_HORSE_CHECKONLOAD), 
					tooltip	= GetString(submenu_ODT_HORSE_CHECKONLOAD_TOOLTIP), 
					getFunc = function() return ODT_HORSE_CHECKONLOAD end,
					setFunc = function(value)
								ODT_HORSE_CHECKONLOAD = value
								changed = true	
					end,
					disabled = function() return ODT_HORSE == false end,
					default = true
				},
			}
		},
		
		-----------------------------------------------------
		-- Pêche
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingIce:Colorize(GetString(submenu_FISH_Title)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_Fish), 
					getFunc = function() return ODT_Fish end,
					setFunc = function(value)
								ODT_Fish = value
								changed = true	
					end,
					default = true
				},
			}
		},

		-----------------------------------------------------
		-- Vol
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingIce:Colorize(GetString(submenu_Stolen_Title)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_Stolen), 
					tooltip = GetString(submenu_ODT_StolenTOOLTIP),
					getFunc = function() return ODT_ShowStolen end,
					setFunc = function(value)
								ODT_ShowStolen = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_ShowStolenBG), 
					getFunc = function() return ODT_ShowStolenBG end,
					setFunc = function(value)
								ODT_ShowStolenBG = value
								changed = true	
					end,
					default = false
				},
			}
		},

		-----------------------------------------------------
		-- Mort
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingRed:Colorize(GetString(submenu_ShowDeath_Title)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ShowDeath), 
					getFunc = function() return ODT_ShowDeath end,
					setFunc = function(value)
								ODT_ShowDeath = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ShowDeath_Msg), 
					getFunc = function() return ODT_ShowDeathMsg end,
					setFunc = function(value)
								ODT_ShowDeathMsg = value
								changed = true	
					end,
					disabled = function() return ODT_ShowDeath == false end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ShowDeath_Chat), 
					getFunc = function() return ODT_ShowDeathChat end,
					setFunc = function(value)
								ODT_ShowDeathChat = value
								changed = true	
					end,
					disabled = function() return ODT_ShowDeath == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ShowDeath_List), 
					getFunc = function() return ODT_ShowDeathList end,
					setFunc = function(value)
								ODT_ShowDeathList = value
								changed = true	
					end,
					disabled = function() return ODT_ShowDeath == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ShowDeath_rez), 
					getFunc = function() return ODT_ShowDeathRez end,
					setFunc = function(value)
								ODT_ShowDeathRez = value
								changed = true	
					end,
					disabled = function() return ODT_ShowDeath == false end,
					default = false
				},
				{
					type = "slider",
					name = GetString(submenu_ShowDeath_Snd),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_ShowDeathSnd end,
					setFunc = function(value)
								ODT_ShowDeathSnd = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_ShowDeath == false end,
					default = 0
				},
			}
		},

		-----------------------------------------------------
		-- MAILBOX
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingOrange:Colorize(GetString(submenu_mail)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_MailRTS_ONOFF), 
					tooltip = GetString(submenu_ODT_MailRTS_ONOFF_TOOLTIP),
					getFunc = function() return ODT_MailRTS_ONOFF end,
					setFunc = function(value)
								ODT_MailRTS_ONOFF = value
								changed = true	
					end,
					default = true
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_MailRTS_SOUND1),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_MailRTS_SOUND1 end,
					setFunc = function(value)
								ODT_MailRTS_SOUND1 = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_MailRTS_ONOFF == false end,
					default = 0
				},
				{
					type = "slider",
					name = GetString(submenu_ODT_MailRTS_SOUND2),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_MailRTS_SOUND2 end,
					setFunc = function(value)
								ODT_MailRTS_SOUND2 = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_MailRTS_ONOFF == false end,
					default = 0
				},
			}
		},

		-----------------------------------------------------
		-- GUILDES : Notifications status membres"
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingYellow:Colorize(GetString(submenu_guildsnotifications)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_guildsnotifications), 
					getFunc = function() return ODT_GMNotif end,
					setFunc = function(value)
								ODT_GMNotif = value
								changed = true	
					end,
					default = true
				},

				{
					type = "checkbox",
					name = ODT_GUILD1_NAME, 
					getFunc = function() return ODT_GM1 end,
					setFunc = function(value)
								ODT_GM1 = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				{
					type = "checkbox",
					name = ODT_GUILD2_NAME, 
					getFunc = function() return ODT_GM2 end,
					setFunc = function(value)
								ODT_GM2 = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				{
					type = "checkbox",
					name = ODT_GUILD3_NAME, 
					getFunc = function() return ODT_GM3 end,
					setFunc = function(value)
								ODT_GM3 = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				{
					type = "checkbox",
					name = ODT_GUILD4_NAME, 
					getFunc = function() return ODT_GM4 end,
					setFunc = function(value)
								ODT_GM4 = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				{
					type = "checkbox",
					name = ODT_GUILD5_NAME, 
					getFunc = function() return ODT_GM5 end,
					setFunc = function(value)
								ODT_GM5 = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},

				{
					type = "checkbox",
					name = GetString(submenu_ODT_GMHeure), 
					getFunc = function() return ODT_GMHeure end,
					setFunc = function(value)
								ODT_GMHeure = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
		
				{
					type = "checkbox",
					name = GetString(submenu_ODT_GuildName), 
					getFunc = function() return ODT_GuildName end,
					setFunc = function(value)
								ODT_GuildName = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},

				{
					type = "checkbox",
					name = GetString(submenu_ODT_GMCharacterName), 
					getFunc = function() return ODT_GMCharacterName end,
					setFunc = function(value)
								ODT_GMCharacterName = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_GMAlliance), 
					getFunc = function() return ODT_GMAlliance end,
					setFunc = function(value)
								ODT_GMAlliance = value
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = true
				},
				
				
				{
					type = "slider",
					name = GetString(submenu_ODT_GMSound),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_GMSound end,
					setFunc = function(value)
								ODT_GMSound = value
								ODT_Playsound(value)
								changed = true	
					end,
					disabled = function() return ODT_GMNotif == false end,
					default = 0
				},
			}
		},
		
		-----------------------------------------------------
		-- CHAT Notifications
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingYellow:Colorize(GetString(submenu_chat_notifications)),
			controls = 
			{
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingSAY:Colorize(GetString(submenu_ODT_Notif_Say)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_Say end,
					setFunc = function(value)
								ODT_Notif_Say = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingYELL:Colorize(GetString(submenu_ODT_Notif_Yell)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_Yell end,
					setFunc = function(value)
								ODT_Notif_Yell = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingWHISPIN:Colorize(GetString(submenu_ODT_Notif_Tell)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_Tell end,
					setFunc = function(value)
								ODT_Notif_Tell = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 16
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingPARTY:Colorize(GetString(submenu_ODT_Notif_Party)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_Party end,
					setFunc = function(value)
								ODT_Notif_Party = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingZ:Colorize(GetString(submenu_ODT_Notif_Z)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_Z end,
					setFunc = function(value)
								ODT_Notif_Z = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingZEN:Colorize(GetString(submenu_ODT_Notif_ZEN)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_ZEN end,
					setFunc = function(value)
								ODT_Notif_ZEN = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingZFR:Colorize(GetString(submenu_ODT_Notif_ZFR)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_ZFR end,
					setFunc = function(value)
								ODT_Notif_ZFR = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingZDE:Colorize(GetString(submenu_ODT_Notif_ZDE)),
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_ZDE end,
					setFunc = function(value)
								ODT_Notif_ZDE = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG1:Colorize(ODT_GUILD1_NAME), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G1 end,
					setFunc = function(value)
								ODT_Notif_G1 = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG2:Colorize(ODT_GUILD2_NAME), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G2 end,
					setFunc = function(value)
								ODT_Notif_G2 = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG3:Colorize(ODT_GUILD3_NAME), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G3 end,
					setFunc = function(value)
								ODT_Notif_G3 = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG4:Colorize(ODT_GUILD4_NAME), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G4 end,
					setFunc = function(value)
								ODT_Notif_G4 = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG5:Colorize(ODT_GUILD5_NAME), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G5 end,
					setFunc = function(value)
								ODT_Notif_G5 = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG1OFF:Colorize(ODT_GUILD1_NAME .. GetString(ODT_notif_officers)), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G1OFF	end,
					setFunc = function(value)
								ODT_Notif_G1OFF = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG2OFF:Colorize(ODT_GUILD2_NAME .. GetString(ODT_notif_officers)), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G2OFF end,
					setFunc = function(value)
								ODT_Notif_G2OFF = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG3OFF:Colorize(ODT_GUILD3_NAME .. GetString(ODT_notif_officers)), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G3OFF end,
					setFunc = function(value)
								ODT_Notif_G3OFF = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG4OFF:Colorize(ODT_GUILD4_NAME .. GetString(ODT_notif_officers)), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G4OFF end,
					setFunc = function(value)
								ODT_Notif_G4OFF = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
				{
					type = "slider",
					name = defaults.miscColorCodes.SettingG5OFF:Colorize(ODT_GUILD5_NAME .. GetString(ODT_notif_officers)), 
					min = 0, max = 26, step = 1, 
					getFunc = function() return ODT_Notif_G5OFF end,
					setFunc = function(value)
								ODT_Notif_G5OFF = value
								ODT_Playsound(value)
								changed = true	
					end,
					default = 0
				},
			}
		},

		-----------------------------------------------------
		-- CHAT Personnalisé
		-----------------------------------------------------
		{
			type = "submenu",
			name = defaults.miscColorCodes.SettingYellow:Colorize(GetString(submenu_customchat)),
			controls = 
			{
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatPerma), 
					tooltip = GetString(submenu_ODT_CustomChatPerma_TOOLTIP),
					getFunc = function() return ODT_CustomChatPerma end,
					setFunc = function(value)
								ODT_CustomChatPerma = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatDate), 
					getFunc = function() return ODT_CustomChatDate end,
					setFunc = function(value)
								ODT_CustomChatDate = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatTime), 
					getFunc = function() return ODT_CustomChatTime end,
					setFunc = function(value)
								ODT_CustomChatTime = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatChan), 
					getFunc = function() return ODT_CustomChatChan end,
					setFunc = function(value)
								ODT_CustomChatChan = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatAccount), 
					getFunc = function() return ODT_CustomChatAccount end,
					setFunc = function(value)
								ODT_CustomChatAccount = value
								changed = true	
					end,
					default = true
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatPersoInfos), 
					tooltip = GetString(submenu_ODT_CustomChatPersoInfos_TOOLTIP),
					getFunc = function() return ODT_CustomChatPersoInfos end,
					setFunc = function(value)
								ODT_CustomChatPersoInfos = value
								changed = true	
					end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatName),
					getFunc = function() return ODT_CustomChatName end,
					setFunc = function(value)
								ODT_CustomChatName = value
								changed = true	
					end,
					disabled = function() return ODT_CustomChatPersoInfos == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatLvl), 
					getFunc = function() return ODT_CustomChatLvl end,
					setFunc = function(value)
								ODT_CustomChatLvl = value
								changed = true	
					end,
					disabled = function() return ODT_CustomChatPersoInfos == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatAlliance), 
					getFunc = function() return ODT_CustomChatAlliance end,
					setFunc = function(value)
								ODT_CustomChatAlliance = value
								changed = true	
					end,
					disabled = function() return ODT_CustomChatPersoInfos == false end,
					default = false
				},
				{
					type = "checkbox",
					name = GetString(submenu_ODT_CustomChatClasse), 
					getFunc = function() return ODT_CustomChatClasse end,
					setFunc = function(value)
								ODT_CustomChatClasse = value
								changed = true	
					end,
					disabled = function() return ODT_CustomChatPersoInfos == false end,
					default = false
				},
			}
		},
		
		-----------------------------------------------------
		-- Bouton d'application
		-----------------------------------------------------
		{
			type = "header",
		},		
        {
            type = "button",
            name = GetString(submenu_ODT_Apply),
			tooltip = GetString(submenu_ODT_Apply_TOOLTIP),
            func = function() SaveSettings("apply") end,
			disabled = function() return not changed end,
        },		
		-----------------------------------------------------
		-- Bouton de sauvegarde
		-----------------------------------------------------
        {
            type = "button",
            name = GetString(submenu_ODT_Save),
			tooltip = GetString(submenu_ODT_Save_TOOLTIP),
            func = function() SaveSettings("save") end,
			disabled = function() return not changed end,
        },		

	}
	

	addOnPanel = LAM:RegisterAddonPanel(ODT.addonName.."_LAM", panelData)
	LAM:RegisterOptionControls(ODT.addonName.."_LAM", optionsTable)	

		
end


--*********************************************************************
-- Chargement de l'addon
--*********************************************************************
function ODT.Initialize( eventCode, addOnName )
	
	if ( addOnName ~= ODT.addonName ) then
		return 
	end	
	EVENT_MANAGER:RegisterForEvent("ODT", EVENT_PLAYER_COMBAT_STATE, ODT.OnPlayerCombatState)

	BugEaterLoaded = 0

	for i=1,GetNumGuilds() do
		guildId = GetGuildId(i)

		local guildName = GetGuildName(guildId)

		if     i == 1 then
			ODT_GUILD1_NAME = GetGuildName(guildId)
		elseif i == 2 then
			ODT_GUILD2_NAME = GetGuildName(guildId)
		elseif i == 3 then
			ODT_GUILD3_NAME = GetGuildName(guildId)
		elseif i == 4 then
			ODT_GUILD4_NAME = GetGuildName(guildId)
		elseif i == 5 then
			ODT_GUILD5_NAME = GetGuildName(guildId)
		end
	end
	
	EVENT_MANAGER:UnregisterForEvent("ODT", EVENT_ADD_ON_LOADED)	


	-- BASTIAN  = 9245
	-- COMMERCE = 9744
	-- EZABI    = 6376
	-- EMBER    = 9911
	-- FEZEZ    = 6378
	-- GHRASH   = 9745
	-- GILADIL  = 10184
	-- ISOBEL   = 9912
	-- JANGLE   = 8994
	-- MIRRI    = 9353
	-- NUZIMEH  = 301
	-- PEDDLER  = 8995
	-- PIRHARRI = 300
	-- PROPERTY = 9743
	-- TYTHIS   = 267

	local assistants = {
		[267] = true,
		[6376] = true,
		[8994] = true,

		[300] = true,
		[6378] = true,
		[10184] = true,
		[8995] = true,

		[9745] = true,

		[301] = true,

		[9245] = true,
		[9911] = true,
		[9912] = true,
		[9353] = true,
		
		[9743] = true,
		[9744] = true,
	}
	
	for assistantIndex in pairs(assistants) do
	
		local assistantName, _, _, _, unlocked = GetCollectibleInfo(assistantIndex)
		
		if unlocked then
			ZO_CreateStringId("SI_BINDING_NAME_PERSONNALASSISTANT_" .. assistantIndex, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, "|c6699ff"..assistantName))
		end
		
	end

	ZO_CreateStringId("SI_BINDING_NAME_ODT_Clock", GetString(lng_SI_BINDING_NAME_ODT_Clock))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_Chrono", GetString(lng_SI_BINDING_NAME_ODT_Chrono))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_ChronoONOFF", GetString(lng_SI_BINDING_NAME_ODT_ChronoONOFF))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_Timer", GetString(lng_SI_BINDING_NAME_ODT_Timer))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_TimerONOFF", GetString(lng_SI_BINDING_NAME_ODT_TimerONOFF))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_PERF", GetString(lng_SI_BINDING_NAME_ODT_PERF))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_STATS", GetString(lng_SI_BINDING_NAME_ODT_STATS))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_RLUI", GetString(lng_SI_BINDING_NAME_ODT_RLUI))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_FREN", GetString(lng_SI_BINDING_NAME_ODT_FREN))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_SENDSACK", GetString(lng_SI_BINDING_NAME_ODT_SACK))
	ZO_CreateStringId("SI_BINDING_NAME_ODT_SENDCHEST", GetString(lng_SI_BINDING_NAME_ODT_CHEST))

	ODT_ReloadMnuBtn = ODTAddon_MenuBtn
	ODT_ReloadMnuBtn:SetParent(ZO_ChatWindowNotifications:GetParent())

	addon_Initialise()	

	CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, ODT_FormatMessage)
	
	InitFish =  2
	ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", ODT_OnInterAct)

    EVENT_MANAGER:RegisterForUpdate("ODT", 100, ODT_OnPlayerDead)

end


EVENT_MANAGER:RegisterForEvent("ODT", EVENT_ADD_ON_LOADED , ODT.Initialize)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_PLAYER_ACTIVATED, ODT_EVENT_PLAYER_ACTIVATED)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_BAG_CAPACITY_CHANGED, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_BOUGHT_BAG_SPACE, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_ITEM_DESTROYED, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_ITEM_USED, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_OPEN_BANK, ODT_BagInfo)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_CLOSE_BANK, ODT_BagInfo)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_INVENTORY_FULL_UPDATE, ODT_WeaponsAndArmor)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_PLAYER_COMBAT_STATE, ODT_WeaponsAndArmor)		
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_ITEM_SLOT_CHANGED, ODT_WeaponsAndArmor)		

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_OPEN_FENCE, ODT_OpenStore)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_CLOSE_STORE, ODT_CloseStore)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_STABLE_INTERACT_END, ODT_HorseTimer)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_MAIL_INBOX_UPDATE, ODT_MailInboxUpdate)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_MAIL_SEND_FAILED, ODT_MailboxSendFailed)
EVENT_MANAGER:RegisterForEvent("ODT", EVENT_MAIL_SEND_SUCCESS, ODT_MailboxSendSuccess)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, ODT_playerStatusChanged)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_CHAT_MESSAGE_CHANNEL, ODT_chatMessageChannel)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_LUA_ERROR, ODT_OnUIError)	

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_RETICLE_TARGET_PLAYER_CHANGED, ODT_OnReticleTargetPlayerChanged)
EVENT_MANAGER:RegisterForEvent('odt', EVENT_PLAYER_COMBAT_STATE, ODT.OnPlayerCombatState)

EVENT_MANAGER:RegisterForEvent("ODT", EVENT_POWER_UPDATE,				ODT_OnPowerUpdate)


--EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RESURRECT_REQUEST, ODT_OnPlayerRez(eventCode, requesterCharacterName, timeLeftToAccept, requesterDisplayName))
--EVENT_RESURRECT_REQUEST (number eventCode, string requesterCharacterName, number timeLeftToAccept, s&tring requesterDisplayName)
--EVENT_RESURRECT_RESULT (number eventCode, string targetCharacterName, ResurrectResult result, string targetDisplayName)



--EVENT_MANAGER:RegisterForEvent("ODT", EVENT_LOOT_RECEIVED, ODT_OnLootReceived)
--EVENT_MANAGER:RegisterForEvent("ODT", EVENT_LOOT_CLOSED, ODT_OnLootClosed)
--EVENT_MANAGER:RegisterForEvent("ODT", EVENT_ACTION_LAYER_POPPED, ODT_ActionLayerChanged)
--EVENT_MANAGER:RegisterForEvent("ODT", EVENT_ACTION_LAYER_PUSHED, ODT_ActionLayerPushed)

ODT_GuildMail_TextText:SetHandler("OnTextChanged", ODT_GuildMail_TextText.onTextChanged)
ODT_GuildMail_TitleText:SetHandler("OnTextChanged", ODT_GuildMail_TitleText.onTextChanged)

SLASH_COMMANDS["/odt"] = ODT_SlashCommand

BugEaterLoaded = 0

uiShow()

