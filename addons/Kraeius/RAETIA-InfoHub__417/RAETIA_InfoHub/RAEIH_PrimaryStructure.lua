local LMP = LibMediaProvider
local LAN = LibAnimation

RAEIH = {}
RAEIH.Name = "RAETIA_InfoHub"
RAEIH.Version = "1.2.4"
RAEIH.SettingsVersion = 1.4

RAEIH.LMP = LMP
RAEIH.LAN = LAN
-- »

-- LMP FONT REGISTER
function RAEIH.RegisterFonts(LMP)
	LMP:Register("font", "Open Sans - Bold", 			[[RAETIA_InfoHub/Resources/Fonts/OpenSans-Bold.ttf]])
	LMP:Register("font", "Open Sans - Bold Italic", 	[[RAETIA_InfoHub/Resources/Fonts/OpenSans-BoldItalic.ttf]])
	LMP:Register("font", "Open Sans - SemiBold", 		[[RAETIA_InfoHub/Resources/Fonts/OpenSans-SemiBold.ttf]])
	LMP:Register("font", "Open Sans - SemiBold Italic", [[RAETIA_InfoHub/Resources/Fonts/OpenSans-SemiBoldItalic.ttf]])
	LMP:Register("font", "Roboto - Bold", 				[[RAETIA_InfoHub/Resources/Fonts/Roboto-Bold.ttf]])
	LMP:Register("font", "Roboto - Bold Italic", 		[[RAETIA_InfoHub/Resources/Fonts/Roboto-BoldItalic.ttf]])
	LMP:Register("font", "Diogenes", 					[[RAETIA_InfoHub/Resources/Fonts/Diogenes.ttf]])	
end

-- FONT STYLE TABLE
RAEIH.FontStyles =
{
	["Normal"] = 				"normal",
	["Outline"] = 				"outline",
	["Shadow"] = 				"shadow",
	["Soft Shadow - Thick"] = 	"soft-shadow-thick",
	["Soft Shadow - Thin"] = 	"soft-shadow-thin",
	["Thick Outline"] = 		"thick-outline"
}

-- ICON TABLE
RAEIH.Icons =
{	
	FPS = 					"/esoui/art/crafting/smithing_rightarrow_up.dds",
	Latency = 				"/esoui/art/inventory/inventory_tabicon_misc_up.dds",
	LUAMemory = 			"/esoui/art/mainmenu/menubar_collections_up.dds",	
	Time = 					"/esoui/art/cadwell/cadwell_indexicon_gold_up.dds",
	Zone = 					"/esoui/art/worldmap/map_indexicon_locations_up.dds",
	Coordinates = 			"/esoui/art/progression/progression_crafting_unlocked_up.dds",
	LVR = 					"/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
	XVP = 					"/esoui/art/charactercreate/charactercreate_bodyicon_up.dds",
	XVPperHour = 			"/esoui/art/journal/journal_tabicon_cadwell_up.dds",
	Gold = 					"/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds",
	GoldperHour = 			"/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
	BankedGold = 			"/esoui/art/bank/bank_tabicon_deposit_up.dds",
	Durability = 			"/esoui/art/repair/inventory_tabicon_repair_up.dds",
	RepairCost = 			"/esoui/art/bank/bank_tabicon_withdraw_up.dds",
	BagSlots = 				"/esoui/art/mainmenu/menubar_inventory_up.dds",
	BankSlots = 			"/esoui/art/worldmap/map_indexicon_key_up.dds",
	Thievery =	 			"/esoui/art/charactercreate/charactercreate_bosmericon_up.dds",
	Bounty =				"/esoui/art/guild/guildhistory_indexicon_combat_up.dds",
	Riding = 				"/esoui/art/mounts/tabicon_mounts_up.dds",
	Blacksmithing = 		"/esoui/art/progression/icon_1handed.dds",
	Woodworking = 			"/esoui/art/progression/icon_bows.dds",
	Clothing = 				"/esoui/art/guild/guildheraldry_indexicon_crest_up.dds",
	SoulGems = 				"/esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
	WeaponCharge = 			"/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
	AttributePoints = 		"/esoui/art/progression/addpoints_up.dds",
	SkyShards = 			"/esoui/art/progression/progression_indexicon_world_up.dds",	
	SkillPoints = 			"/esoui/art/progression/morph_up.dds",
	ChampionXP =			"/esoui/art/mainmenu/menubar_champion_up.dds",
	AlliancePoints = 		"/esoui/art/progression/progression_indexicon_ava_up.dds",
	AvARank =				"/esoui/art/campaign/campaign_tabicon_browser_up.dds",
	AchievementPoints = 	"/esoui/art/journal/journal_tabicon_achievements_up.dds",
	Friends = 				"/esoui/art/mainmenu/menubar_character_up.dds",
	TimePlayed = 			"/esoui/art/campaign/campaign_tabicon_summary_up.dds",			
	CombatState = 			"/esoui/art/campaign/campaign_tabicon_browser_up.dds",
	Vampirism = 			"/esoui/art/progression/progression_indexicon_race_up.dds",
	Lycanthropy = 			"/esoui/art/progression/progression_indexicon_race_up.dds",
	CraftingXP = 			"/esoui/art/progression/progression_indexicon_tradeskills_up.dds",
	Subtitles = 			"/esoui/art/mainmenu/menubar_social_up.dds",
	Notification = 			"/esoui/art/crafting/smithing_tabicon_improve_up.dds",
	ChamberlainClose =		"/esoui/art/buttons/closebutton_up.dds",
	ChamberlainUpArrow = 	"/esoui/art/buttons/scrollbox_uparrow_up.dds",
	ChamberlainRightArrow = "/esoui/art/buttons/rightarrow_up.dds",
	ChamberlainLeftArrow =	"/esoui/art/buttons/leftarrow_up.dds",
	ChamberlainDownArrow = 	"/esoui/art/buttons/scrollbox_downarrow_up.dds",
}

-- BACKGROUND TEXTURE TABLE
RAEIH.Backgrounds =
{	
	["Aluminium"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/Aluminium.dds",
	["Banto Bar"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/BantoBar.dds",
	["Complete Dark"] = 		"/RAETIA_InfoHub/Resources/Backgrounds/CompleteDark.dds",
	["Dark"] = 					"/RAETIA_InfoHub/Resources/Backgrounds/Dark.dds",
	["Dark Bottom"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/DarkBottom.dds",
	["Elder Scrolls Grad"] = 	"/RAETIA_InfoHub/Resources/Backgrounds/ElderScrollsGrad.dds",
	["Glass"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Glass.dds",
	["Glaze"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Glaze.dds",
	["Horizontal Grad"] = 		"/RAETIA_InfoHub/Resources/Backgrounds/HorizontalGrad.dds",
	["Horizontal GradV2"] = 	"/RAETIA_InfoHub/Resources/Backgrounds/HorizontalGradV2.dds",
	["Inner Glow"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/InnerGlow.dds",
	["Inner Shadow"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/InnerShadow.dds",
	["Inner Shadow Glass"] = 	"/RAETIA_InfoHub/Resources/Backgrounds/InnerShadowGlass.dds",
	["Lite Step"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/LiteStep.dds",
	["Melli"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Melli.dds",
	["Minimalist"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/Minimalist.dds",
	["Normal"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Normal.dds",
	["Otravi"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Otravi.dds",
	["Round"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Round.dds",
	["SandPaper"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/SandPaper.dds",
	["SandPaperV2"] = 			"/RAETIA_InfoHub/Resources/Backgrounds/SandPaperV2.dds",
	["Shadow"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Shadow.dds",
	["Smooth"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/Smooth.dds",
	["WGlass"] = 				"/RAETIA_InfoHub/Resources/Backgrounds/WGlass.dds"
}

-- RETICLE TABLE
RAEIH.Reticles =
{
	["Cross"] = 
	{ 
		Path = "RAETIA_InfoHub/Resources/Reticles/rCross.dds",
		Size = 64
	},
	
	["Dot"] = 
	{
		Path = "RAETIA_InfoHub/Resources/Reticles/rDot.dds",
		Size = 32
	}
}

-- MODULE NAME TABLE
RAEIH.MDN =
{
	["FPS"] = 						"RAEIH_FPS",
	["Latency"] = 					"RAEIH_Latency",
	["LUA Memory"] = 				"RAEIH_LUAMemory",			
	["Time"] = 						"RAEIH_Time",
	["Zone"] = 						"RAEIH_Zone",
	["Coordinates"] = 				"RAEIH_Coordinates",
	["LVR"] = 						"RAEIH_LVR",
	["XVP"] = 						"RAEIH_XVP",
	["XVP per Hour"] = 				"RAEIH_XVPperHour",
	["Gold"] = 						"RAEIH_Gold",
	["Gold per Hour"] = 			"RAEIH_GoldperHour",
	["Banked Gold"] = 				"RAEIH_BankedGold",
	["Durability"] = 				"RAEIH_Durability",
	["Repair Cost"] = 				"RAEIH_RepairCost",
	["Bag Slots"] = 				"RAEIH_BagSlots",
	["Bank Slots"] = 				"RAEIH_BankSlots",
	["Thievery"] = 					"RAEIH_Thievery",
	["Bounty"] = 					"RAEIH_Bounty",
	["Riding"] = 					"RAEIH_Riding",
	["Blacksmithing"] = 			"RAEIH_Blacksmithing",
	["Woodworking"] = 				"RAEIH_Woodworking",
	["Clothing"] = 					"RAEIH_Clothing",
	["Soul Gems"] = 				"RAEIH_SoulGems",	
	["Weapon Charge"] = 			"RAEIH_WeaponCharge",
	["Attribute Points"] = 			"RAEIH_AttributePoints",
	["AvA Rank"] = 					"RAEIH_AvARank",
	["SkyShards"] = 				"RAEIH_SkyShards",
	["Skill Points"] = 				"RAEIH_SkillPoints",
	["Champion XP"] = 				"RAEIH_ChampionXP",
	["Alliance Points"] = 			"RAEIH_AlliancePoints",
	["Achievement Points"] = 		"RAEIH_AchievementPoints",
	["Friends"] = 					"RAEIH_Friends",
	["Player Info"] = 				"RAEIH_TimePlayed",
	["Combat State"] = 				"RAEIH_CombatState",
	["Vampirism"] = 				"RAEIH_Vampirism",
	["Lycanthropy"] = 				"RAEIH_Lycanthropy",
	["Crafting XP"] = 				"RAEIH_CraftingXP",
	["Notification"] = 				"RAEIH_Notification",	
	["Empty"] = 					"Empty"
}

-- MODULE UD TABLE
RAEIH.MD = 
{
	CName = {},
	CFName = {},
	UD = {}
}

-- ON ADDON LOADED
function RAEIH.OnAddOnLoaded(eventCode, addOnName)
	if addOnName == RAEIH.Name then

		RAEIH.SavedVars = ZO_SavedVars:New("RAEIH_SavedVariables", RAEIH.SettingsVersion, nil, RAEIH.DefaultSavedVars, nil)
		
		RAEIH.RegisterFonts(LMP)
		RAEIH.RegisterSettings()
		RAEIH.GetChars()
		
		RAETIA_InfoHub:SetHandler("OnUpdate", RAEIH.UpdateAddOn)
		
		RAEIH.RegisterEvents(true)		
		RAEIH.CreateModules()
		RAEIH.SetModules()
		RAEIH.FormatModules()
		RAEIH.OrganizeModules()	
	end
end

-- TIMERS
local AWMZtime = 0
local cTime = 0
function RAEIH.NotificationTimer()
	cTime = cTime + 1
	if cTime == RAEIH.SavedVars.IgnoreMSGSecond then
		local clrDft = "|c" .. RAEIH.SavedVars.NotificationDefaultColour
		local clrA = "|c" .. RAEIH.SavedVars.NotificationAlertColour
		local clrS = "|c" .. RAEIH.SavedVars.NotificationWarningColour
		RAEIH.SavedVars.AnimStage = 0
		RAEIH.SavedVars.AnimTracker = false		
		RAEIH.NotificationText = clrDft .. "No Message"
		RAEIH_Notification_String:SetText(RAEIH.NotificationText)
		RAEIH.SecondTextAnim()	
		RAEIH.OrganizeLegatus()
		cTime = 0
		RAEIH.SavedVars.StartNotificationTimer = false
	end
end

function RAEIH.MapTimer()	
	RAEIH.SavedVars.ZDone = false
	AWMZtime = AWMZtime + 1
	if AWMZtime == 2 then		
		RAEIH.AutoWMZ()
		AWMZtime = 0
		RAEIH.SavedVars.StartMapTimer = false		
	end
end

-- REALTIME UPDATE
function RAEIH.UpdateAddOn()

	if RAEIH.SavedVars.ChangeReticleTexture == true and RAEIH_Reticle_Texture ~= nil then
		if GetUnitStealthState("player") ~= STEALTH_STATE_NONE or GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE then
			RAEIH_Reticle_Texture:SetHidden(true)
			ZO_ReticleContainerReticle:SetHidden(true)
		else
			ZO_ReticleContainerReticle:SetHidden(true)
			RAEIH_Reticle_Texture:SetHidden(false)
		end
	end

	if not BufferReached(RAEIH.Name, 1) then return; end		

	RAEIH.HideCheck()

	if RAEIH.SavedVars.StartMapTimer then		
		RAEIH.MapTimer()
	end

	if RAEIH.SavedVars.StartNotificationTimer then		
		RAEIH.NotificationTimer()
	end

	if RAEIH.SavedVars.AnimTracker then
		local cAlpha = RAEIH_Notification:GetAlpha()
		local aStage = RAEIH.SavedVars.AnimStage
		if (cAlpha < 0.2 and cAlpha > 0.1) and aStage == 1 then
			RAEIH.SecondTextAnim()			
		elseif cAlpha == 1 and aStage == 2 then
			RAEIH.FirstTextAnim()			
		end
	end

	if RAEIH.SavedVars.ShowFPS then
		RAEIH.SetFPS()
	end

	if RAEIH.SavedVars.ShowLatency then
		RAEIH.SetLatency()
	end

	if RAEIH.SavedVars.ShowLUAMemory then
		RAEIH.SetLUAMemory()
	end

	if RAEIH.SavedVars.ShowTime then
		RAEIH.SetTime()	
	end

	if RAEIH.SavedVars.ShowCoordinates then
		RAEIH.SetCoordinates()
	end

	if RAEIH.SavedVars.ShowXVPperHour then
		RAEIH.SetXVPperHour()
	end

	if RAEIH.SavedVars.ShowGoldperHour then
		RAEIH.SetGoldperHour()
	end

	if RAEIH.SavedVars.ShowBounty then
		RAEIH.SetBounty()
	end

	if RAEIH.SavedVars.ShowRiding then
		RAEIH.SetRiding()
	end

	if RAEIH.SavedVars.ShowBlacksmithing then
		RAEIH.SetBlacksmithing()
	end

	if RAEIH.SavedVars.ShowWoodworking then
		RAEIH.SetWoodworking()
	end

	if RAEIH.SavedVars.ShowClothing then
		RAEIH.SetClothing()
	end

	if RAEIH.SavedVars.ShowTimePlayed then
		RAEIH.SetTimePlayed()
	end

	if RAEIH.SavedVars.ShowVampirism then
		RAEIH.SetVampirism()
	end

	if (RAEIH.SavedVars.ShowLycanthropy or RAEIH.SavedVars.AutoShowLycanthropy) and RAEIH.InWWState then
		RAEIH.SetLycanthropy()
	end		

	if RAEIH.SavedVars.ShowSubtitles then
		local isSubVisible = RAEIH_Subtitles:GetAlpha() > 0
		if isSubVisible == false then
			RAEIH_Subtitles_String:SetText("")
			RAEIH_Subtitles:SetAlpha(0)
			RAEIH_Subtitles:SetHidden(true)
		end
	end
end

-- CREATE FIELDS
function RAEIH.CreateModules()
	RAEIH.CreateFPS()
	RAEIH.CreateLatency()
	RAEIH.CreateLUAMemory()
	RAEIH.CreateTime()
	RAEIH.CreateZone()
	RAEIH.CreateCoordinates()
	RAEIH.CreateLVR()
	RAEIH.CreateXVP()
	RAEIH.CreateXVPperHour()
	RAEIH.CreateGold()
	RAEIH.CreateGoldperHour()
	RAEIH.CreateBankedGold()
	RAEIH.CreateDurability()
	RAEIH.CreateRepairCost()
	RAEIH.CreateBagSlots()
	RAEIH.CreateBankSlots()
	RAEIH.CreateThievery()
	RAEIH.CreateBounty()
	RAEIH.CreateRiding()
	RAEIH.CreateBlacksmithing()
	RAEIH.CreateWoodworking()
	RAEIH.CreateClothing()
	RAEIH.CreateSoulGems()	
	RAEIH.CreateWeaponCharge()
	RAEIH.CreateAttributePoints()
	RAEIH.CreateSkyShards()
	RAEIH.CreateSkillPoints()
	RAEIH.CreateChampionXP()
	RAEIH.CreateAlliancePoints()
	RAEIH.CreateAvARank()
	RAEIH.CreateAchievementPoints()
	RAEIH.CreateFriends()
	RAEIH.CreateTimePlayed()
	RAEIH.CreateCombatState()
	RAEIH.CreateVampirism()
	RAEIH.CreateLycanthropy()
	RAEIH.CreateCraftingXP()
	RAEIH.CreateNotification()
	RAEIH.CreateSubtitles()
	RAEIH.CreateReticle()
	RAEIH.CreateChamberlain()
		
end

-- SET FIELDS
function RAEIH.SetModules()
	RAEIH.SetFPS()
	RAEIH.SetLatency()
	RAEIH.SetLUAMemory()	
	RAEIH.SetTime()
	RAEIH.SetZone()
	RAEIH.SetCoordinates()
	RAEIH.SetLVR()
	RAEIH.SetXVP()
	RAEIH.SetXVPperHour()
	RAEIH.SetGold()
	RAEIH.SetGoldperHour()
	RAEIH.SetBankedGold()
	RAEIH.SetDurability()
	RAEIH.SetRepairCost()
	RAEIH.SetBagSlots()
	RAEIH.SetBankSlots()
	RAEIH.SetThievery()
	RAEIH.SetBounty()
	RAEIH.SetRiding()
	RAEIH.SetBlacksmithing()
	RAEIH.SetWoodworking()
	RAEIH.SetClothing()
	RAEIH.SetSoulGems()	
	RAEIH.SetWeaponCharge()
	RAEIH.SetAttributePoints()
	RAEIH.SetSkyShards()
	RAEIH.SetSkillPoints()
	RAEIH.SetChampionXP()
	RAEIH.SetAlliancePoints()
	RAEIH.SetAvARank()
	RAEIH.SetAchievementPoints()
	RAEIH.SetFriends()
	RAEIH.SetTimePlayed()
	RAEIH.SetCombatState()
	RAEIH.SetVampirism()
	RAEIH.SetLycanthropy()
	RAEIH.SetCraftingXP()
	RAEIH.SetNotification()	
	RAEIH.SetSubtitles()
	RAEIH.SetReticle()
	RAEIH.SetChamberlain()
	
end

-- FORMAT FIELDS
function RAEIH.FormatModules()
	RAEIH.FormatFPS()
	RAEIH.FormatLatency()
	RAEIH.FormatLUAMemory()	
	RAEIH.FormatTime()	
	RAEIH.FormatZone()
	RAEIH.FormatCoordinates()
	RAEIH.FormatLVR()
	RAEIH.FormatXVP()
	RAEIH.FormatXVPperHour()
	RAEIH.FormatGold()
	RAEIH.FormatGoldperHour()
	RAEIH.FormatBankedGold()
	RAEIH.FormatDurability()
	RAEIH.FormatRepairCost()
	RAEIH.FormatBagSlots()
	RAEIH.FormatBankSlots()
	RAEIH.FormatThievery()
	RAEIH.FormatBounty()
	RAEIH.FormatRiding()
	RAEIH.FormatBlacksmithing()
	RAEIH.FormatWoodworking()
	RAEIH.FormatClothing()
	RAEIH.FormatSoulGems()	
	RAEIH.FormatWeaponCharge()
	RAEIH.FormatAttributePoints()
	RAEIH.FormatSkyShards()
	RAEIH.FormatSkillPoints()
	RAEIH.FormatChampionXP()
	RAEIH.FormatAlliancePoints()
	RAEIH.FormatAvARank()
	RAEIH.FormatAchievementPoints()
	RAEIH.FormatFriends()
	RAEIH.FormatTimePlayed()
	RAEIH.FormatCombatState()
	RAEIH.FormatVampirism()
	RAEIH.FormatLycanthropy()
	RAEIH.FormatCraftingXP()
	RAEIH.FormatNotification()
	RAEIH.FormatSubtitles()
	RAEIH.FormatReticle()
	RAEIH.FormatChamberlain()
		
end

-- ORGANIZE FIELDS
function RAEIH.OrganizeModules()
	RAEIH.OrganizeFPS()
	RAEIH.OrganizeLatency()
	RAEIH.OrganizeLUAMemory()	
	RAEIH.OrganizeTime()
	RAEIH.OrganizeZone()
	RAEIH.OrganizeCoordinates()
	RAEIH.OrganizeLVR()
	RAEIH.OrganizeXVP()
	RAEIH.OrganizeXVPperHour()
	RAEIH.OrganizeGold()
	RAEIH.OrganizeGoldperHour()
	RAEIH.OrganizeBankedGold()
	RAEIH.OrganizeDurability()
	RAEIH.OrganizeRepairCost()
	RAEIH.OrganizeBagSlots()
	RAEIH.OrganizeBankSlots()
	RAEIH.OrganizeThievery()
	RAEIH.OrganizeBounty()
	RAEIH.OrganizeRiding()
	RAEIH.OrganizeBlacksmithing()
	RAEIH.OrganizeWoodworking()
	RAEIH.OrganizeClothing()
	RAEIH.OrganizeSoulGems()	
	RAEIH.OrganizeWeaponCharge()
	RAEIH.OrganizeAttributePoints()
	RAEIH.OrganizeSkyShards()
	RAEIH.OrganizeSkillPoints()
	RAEIH.OrganizeChampionXP()
	RAEIH.OrganizeAlliancePoints()
	RAEIH.OrganizeAvARank()
	RAEIH.OrganizeAchievementPoints()
	RAEIH.OrganizeFriends()
	RAEIH.OrganizeTimePlayed()
	RAEIH.OrganizeCombatState()
	RAEIH.OrganizeVampirism()
	RAEIH.OrganizeLycanthropy()
	RAEIH.OrganizeCraftingXP()
	RAEIH.OrganizeNotification()
	RAEIH.OrganizeChamberlain()	
end