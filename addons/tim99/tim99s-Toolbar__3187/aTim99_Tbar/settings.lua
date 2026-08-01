aTim99_Tbar = aTim99_Tbar or {}
local ttb = aTim99_Tbar 

function ttb.initMenu()
	local LAM2 = LibAddonMenu2
	local panelData = {
		type        = "panel",
		name        = "|c9B30FFtim99s Toolbar|r",
		author      = "|c9B30FFtim99|r",
		version	    = "666",
		website		= "https://www.esoui.com/downloads/info3187-tim99sToolbar.html",
		--feedback	= "https://www.esoui.com/downloads/info3187-tim99sToolbar.html#comments",
		donation	= "https://www.esoui.com/forums/member.php?userid=33743",
		registerForRefresh = true,	--will refresh all options controls when a setting is changed and when the panel is shown
		registerForDefaults = true	--will set all options controls back to default values
	}
	LAM2:RegisterAddonPanel("tim99s Toolbar", panelData)
--===============================================================================================--
	local optionsData = {
		{	type		= "description",
			title		= "|c9B30FFDescription|r",
			text		= "|c999999I have come here to chew bubblegum and kick ass... and I'm all out of bubblegum|r",
			width		= "half",
		}, ----------------------------------------------------------------------------
		{	type		= "texture",
			image		= "/esoui/art/icons/assistant_banker_01.dds",
			--text      = "text",
			imageWidth	= 96,
			imageHeight	= 96,
			width		= "half",
		}, 
		--========================================================================--
		{	type = "divider",
			alpha = 0.5,
		}, -------------------------------------------
		{	type    = "description",
			title   = "|c9B30FFAccountwide settings|r",
			text    = "",
		}, -------------------------------------------
		{	type = "slider",
			name = "Refresh time in sec|u1:4::|u"..zo_iconFormat("/esoui/art/tutorial/timer_icon.dds",28,28),
			getFunc = function() return ttb.dbA.refreshTime end,
			setFunc = function(value) 
				EVENT_MANAGER:UnregisterForUpdate("Toolbar_Update")
				ttb.dbA.refreshTime = value
				local refreshSeconds = ttb.dbA.refreshTime * 1000
				EVENT_MANAGER:RegisterForUpdate("Toolbar_Update", refreshSeconds, ttb.Toolbar_Update)
			end,
			min = 1, max = 10,
			default = ttb.svDefAcc.refreshTime,
			width = "full",
			clampInput = true,
			decimals = 0,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Hide the AD prank (restart game)|u1:2::|u"..zo_iconFormat("aTim99_Tbar/img/keep.dds",52,52),
			getFunc = function() return ttb.dbA.hideTheTruth end,
			setFunc = function(value) 
				ttb.dbA.hideTheTruth=value
				ttb.GetStaticInfos(TimTbarWindowPlayer, TimTbarWindowAllianzL, TimTbarWindowAllianzR)
			end,
			default = ttb.svDefAcc.hideTheTruth,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Bold font",
			getFunc = function() return ttb.dbA.fontBold end,
			setFunc = function(value) 
				ttb.dbA.fontBold=value
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.fontBold,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "divider",
			alpha = 0.2,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Skull (Trophy)|u1:4::|u"..zo_iconFormat("/esoui/art/icons/quest_head_monster_016.dds",28,28),
			getFunc = function() return ttb.dbA.showSkull end,
			setFunc = function(value) 
				ttb.dbA.showSkull=value
				ttb.setOffset("TimTbarWindowSkull",ttb.offsets.skull,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showSkull,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Remains-Silent (Brotherhood)|u1:4::|u"..zo_iconFormat("/esoui/art/icons/mapkey/mapkey_darkbrotherhood.dds",28,28),
			getFunc = function() return ttb.dbA.showSilent end,
			setFunc = function(value) 
				ttb.dbA.showSilent=value
				ttb.doReadSilent=true
				ttb.setOffset("TimTbarWindowRemainsSilent",ttb.offsets.silent,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showSilent,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "New-Moon Motif (Dragonguard)|u1:4::|u"..zo_iconFormat("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_dragonguard.dds",24,26),
			getFunc = function() return ttb.dbA.showDragon end,
			setFunc = function(value) 
				ttb.dbA.showDragon=value
				ttb.doReadDragon=true
				ttb.setOffset("TimTbarWindowDragonguard",ttb.offsets.dragon,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showDragon,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		--[[
		{	type = "checkbox",
			name = "Annihil Motif (Deadland Portal)|u1:4::|u"..zo_iconFormat("/esoui/art/treeicons/gamepad/gp_lorelibrary_categoryicon_daedric.dds",28,28),
			getFunc = function() return ttb.dbA.showDeadland end,
			setFunc = function(value) 
				ttb.dbA.showDeadland=value
				ttb.doReadAnnihil=true
				ttb.setOffset("TimTbarWindowDeadlands",ttb.offsets.deadlands,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showDeadland,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		]]
		{	type = "checkbox",
			name = "Imperial City Merits|u1:4::|u"..zo_iconFormat("/esoui/art/compass/ava_imperialcity_neutral.dds",28,30),
			getFunc = function() return ttb.dbA.showIC end,
			setFunc = function(value)
				ttb.dbA.showIC=value
				ttb.setOffset("TimTbarWindowImperialMerits",ttb.offsets.ic,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showIC,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "divider",
			alpha = 0.2,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Show percentage behind XP numbers|u1:4::|u",
			getFunc = function() return ttb.dbA.showXPperc end,
			setFunc = function(value)
				ttb.dbA.showXPperc=value
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.showXPperc,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "divider",
			alpha = 0.5,
		}, -------------------------------------------
		{	type    = "description",
			title   = "|c9B30FFCharacterwide settings|r",
			text    = "",
		}, -------------------------------------------
		{	type = "slider",
			name = "Character sort order|u1:4::|u"..zo_iconFormat("/esoui/art/tutorial/timer_icon.dds",28,28),
			getFunc = function() return ttb.dbA.charList[ttb.charName].sort end,
			setFunc = function(value) 
				ttb.dbA.charList[ttb.charName].sort = value
			end,
			min = 1, max = 21,
			default = ttb.svDefAcc.charList[ttb.charName].sort,
			width = "full",
			clampInput = true,
			decimals = 0,
			requiresReload = true,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Crafting Reseach|u1:4::|u"..zo_iconFormat("/esoui/art/tutorial/inventory_trait_not_researched_icon.dds",28,30),
			getFunc = function() return ttb.dbA.charList[ttb.charName].showResearch end,
			setFunc = function(value)
				ttb.dbA.charList[ttb.charName].showResearch=value
				ttb.setOffset("TimTbarWindowResearchSmithing",ttb.offsets.research1,value)
				ttb.setOffset("TimTbarWindowResearchWoodworking",ttb.offsets.research23,value)
				ttb.setOffset("TimTbarWindowResearchClothier",ttb.offsets.research23,value)
				ttb.setOffset("TimTbarWindowResearchJewelry",ttb.offsets.research4,value)
				ttb.Toolbar_Update()
			end,
			default = ttb.svDefAcc.charList[ttb.charName].showResearch,
			width = "full",
			requiresReload = false,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Destroy |H1:item:79332:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h|u1:4::|u"..zo_iconFormat("/esoui/art/icons/justice_stolen_prop_royal_carpet.dds",28,30),
			getFunc = function() return ttb.dbA.charList[ttb.charName].destroyMonk end,
			setFunc = function(value)
				ttb.dbA.charList[ttb.charName].destroyMonk=value
			end,
			default = ttb.svDefAcc.charList[ttb.charName].destroyMonk,
			width = "full",
			requiresReload = true,
		}, -------------------------------------------
		{	type = "divider",
			alpha = 0.5,
		}, -------------------------------------------
		{	type    = "description",
			title   = "|c9B30FFTooltip settings|r",
			text    = "",
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Show this char in Writs-Tooltip|u1:4::|u",
			getFunc = function() return ttb.dbA.charList[ttb.charName].trackWrit end,
			setFunc = function(value)
				ttb.dbA.charList[ttb.charName].trackWrit=value
			end,
			default = ttb.svDefAcc.charList[ttb.charName].trackWrit,
			width = "full",
			--requiresReload = true,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Show this char in Brotherhood-Tooltip|u1:4::|u",
			getFunc = function() return ttb.dbA.charList[ttb.charName].trackStiller end,
			setFunc = function(value)
				ttb.dbA.charList[ttb.charName].trackStiller=value
			end,
			default = ttb.svDefAcc.charList[ttb.charName].trackStiller,
			width = "full",
			--requiresReload = true,
		}, -------------------------------------------
		{	type = "checkbox",
			name = "Show this char in Mount-Tooltip|u1:4::|u",
			getFunc = function() return ttb.dbA.charList[ttb.charName].trackMount end,
			setFunc = function(value)
				ttb.dbA.charList[ttb.charName].trackMount=value
			end,
			default = ttb.svDefAcc.charList[ttb.charName].trackMount,
			width = "full",
			--requiresReload = true,
		}, -------------------------------------------
		{	type = "divider",
			alpha = 0.5,
		}, -------------------------------------------
		{	type    = "description",
			title   = "|c9B30FFDebug|r",
			text    = "",
		}, -------------------------------------------
		{	type = "checkbox",
			name = "show debug messages|u1:4::|u",
			getFunc = function() return ttb.dbA.showDebug end,
			setFunc = function(value)
				ttb.dbA.showDebug=value
			end,
			default = ttb.dbA.showDebug,
			width = "full",
		}, -------------------------------------------
	}
	LAM2:RegisterOptionControls("tim99s Toolbar", optionsData)
end
