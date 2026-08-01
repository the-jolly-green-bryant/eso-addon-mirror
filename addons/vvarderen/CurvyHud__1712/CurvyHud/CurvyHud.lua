--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/CurvyHud.lua 
	
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

-- Settings
CurvyHud 					= {}
CurvyHud.name 				= "CurvyHud"
CurvyHud.version 			= "|cFF95006|cFFFFFF.|cFF950012"
CurvyHud.varsVersion		= 4
CurvyHud.varsAccountVersion	= 4
CurvyHud.author				= "|c922BFFVvarderen"
CurvyHud.website			= "http://www.esoui.com/downloads/info1712-CurvyHud.html"
-- Default Config 
CurvyHud.defaultConfigs 	= {
	[1] = {
		barSpacing				=	5, 
		barWidth				=	75, 
		barHeight				= 	450, 
		hideDefaultTargetFrame 	= 	true, 
		hideDefaultPlayerFrame	= 	true, 
		combatAlpha 			=	1, 
		oocAlpha				=	0.5, 
		targetOocAlpha			=	0.7, 
		targetinCombatAlpha		= 	1, 
		attributeUsedAlpha		=   0.7,
		showDecimal				= 	true,
		localizationDecimal		=	true,
		textureConfig			=	'default', 
		iconBoss				=	'default_boss', 
		combatChatIndic			=	false,
		covertChatIndic			= 	false,
		guildmatesChatIndic		=	false,
		guildOne				=	false,
		guildTwo				=	false,
		guildThree				=	false,
		guildFour				=	false,
		guildFive				=	false,
		showCritters			= 	false,
		showDead				=	false,
		troll					=	true,
		
		compass				= {
			show				=	true, 
			boss				= 	true,
			inCombat			= 	false, 
			notexture			=	false, 
			colorVisibility		= 	false, 
		}, 

		barContainerLeft	= {
			stepOn				=	true, 
			anchor				=	{CENTER, nil, CENTER,  -350,  0}, 
		}, 
	
		barContainerRight	= {
			stepOn 				=	true, 
			anchor				=	{CENTER, nil, CENTER,  350,  0}, 
		}, 
		
		targetNameplate		= {
			show				=	true, 
			anchor				=	{CENTER, nil, CENTER,  0,  -300}, 
			fontName			=	'Univers 67', 
			fontSize			=	 26, 
			alignment			=	TEXT_ALIGN_CENTER, 
			colorIcons			=	'default', 
			classIcon			=	true,
			level				=	true,
			allianceIcon		=	true, 
			rankIcon			=	true, 
			raceIcon			=	true, 
			caption				= 	true,
			colorGuard 			=	{150/255,  0/255,  150/255,  1}, 
			showTypeName		=	"name", 
		}, 
		
		interactionPrompt	= {
			anchor				= {CENTER, nil, CENTER,  0,  300}, 
		}, 
		
		alertTextNotification	= {
			anchor				= {CENTER, nil, CENTER,  500,  500}, 
		},
		
		playerinteractionPrompt	= {
			anchor				= {CENTER, nil, CENTER,  0,  400}, 
		}, 
		
		reticleOption		= {
			hidden				= 	false, 
			color				=	false,
			inCombat			= 	false,
			textureConfig		= 	"default",
			anchor				= 	{CENTER, nil, CENTER,  0,  0},
		}, 
		
		healthBar			= {
			show				= 	true, 
			position			= 	'left', 
			index				= 	0, 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0.8}, 
			colorMax			= 	{130/255,  0  /255,  0  /255,  1  }, 
			colorLow			= 	{255/255,  0  /255,  0  /255,  1  }, 
			borderShow	 		=  	true, 
			
			showText 			= 	true, 
			textAnchor			=   {CENTER, nil, CENTER, -400, 240}, 
			textColor			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
		
		staminaBar			= {
			show				= 	true, 
			position			= 	'left', 
			index				= 	2, 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0.8}, 
			colorMax			= 	{0  /255,  130/255,  0  /255,  1  }, 
			colorLow			= 	{0  /255,  255/255,  0  /255,  1  }, 
			borderShow	 		=  	true, 
			
			showText 			= 	true, 
			textAnchor  		=   {CENTER, nil, CENTER, -480, 180}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
		
		magickaBar			= {
			show				= 	true, 
			position			= 	'left', 
			index				= 	1, 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0.8}, 
			colorMax			= 	{0  /255,  0  /255,  130/255,  1  }, 
			colorLow			= 	{0  /255,  0/255,  255/255,  1  }, 
			borderShow	 		=  	true, 			
			
			showText 			= 	true, 
			textAnchor  		=   {CENTER, nil, CENTER, -440, 210}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		},

		differentiationBar	= {
			showAlly			=	true, 
			showNPCNeutral		=	true, 
			colorMax			=	{35 /255,  175/255,  220/255,  1}, 
			colorLow			=	{15 /255,  90 /255,  120/255,  1}, 
		}, 
		
		targetBar			= {
			show				= 	true, 
			position			= 	'right', 
			index				= 	0, 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0.8}, 
			colorMax			= 	{130/255,  0  /255,  0  /255,  1  }, 
			colorLow			= 	{255/255,  0  /255,  0  /288,  1  }, 
			borderShow	 		=  	true, 
			
			showText 			= 	true, 
			textAnchor  		=    {CENTER, nil, CENTER, 400, 240}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{per}% - {val} / {max}' , 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
	
		mountBar 			= {
			show				= 	true, 
			index				= 	2, 
			position			= 	'left', 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0  }, 
			colorMax			= 	{255/255,  255/255,  255/255,  0.4}, 
			colorLow			= 	{255/255,  255/255,  255/255,  0.4}, 
			borderShow	 		=  	false, 
			
			showText 			= 	false, 
			textAnchor  		=   {CENTER, nil, CENTER, -480, 180}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
		
		werewolfBar 		= {
			show				= 	true, 
			index				= 	1, 
			position			= 	'left', 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0  }, 
			colorMax			= 	{255/255,  255/255,  255/255,  0.4}, 
			colorLow			= 	{255/255,  255/255,  255/255,  0.4}, 
			borderShow	 		=  	false, 
			
			showText 			= 	false, 
			textAnchor  		=   {CENTER, nil, CENTER, -440, 210}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
		
		siegeBar 			= {
			show				= 	true, 
			index				= 	0, 
			position			= 	'left', 
			
			backgroundColor 	= 	{0  /255,  0  /255,  0  /255,  0  }, 
			colorMax			= 	{255/255,  255/255,  255/255,  0.4}, 
			colorLow			= 	{255/255,  255/255,  255/255,  0.4}, 
			borderShow	 		=  	false, 
			
			showText 			= 	false, 
			textAnchor  		=   {CENTER, nil, CENTER, -0, 150}, 
			textColor 			=  	'default', 
			textFormat 			= 	'{val} / {max} - {per}%', 
			fontName			= 	'Univers 67', 
			fontSize			= 	22, 
		}, 
		
		visuals 			= {
			shield		= {
				show			= true, 
				color			= {50 /255,  0  /255,  200/255,  0.6},
				
				showText		= true, 
				textAnchor 		= {CENTER, nil, CENTER, -500, 0}, 
				textColor 		= {150/255,  0, 255/255,  1}, 
				textFormat 		= '(+{val})', 
				fontName		= 'Univers 67', 
				fontSize		= 21, 
			}, 
			
			regen		= {
				show			= true, 
			}, 
			
			majorEffect	= {
				incShow			= true,
				decShow			= true,
			}, 
			
			minorEffect	= {
				incShow			= true,
				decShow			= true,
			},
	
			antinomic	= {
				show			= true
			},
				
		}, 
		
		targetVisuals		= {
			shield		= {
				show			= true, 
				color			= {50 /255, 0  /255, 200/255, 0.6}, 
				
				showText		= true, 
				textAnchor 		= {CENTER, nil, CENTER, 450, 0}, 
				textColor 		= {150/255,  0, 255/255,  1},
				textFormat 		= '(+{val})', 
				fontName		= 'Univers 67', 
				fontSize		= 21, 
			}, 
			
			regen		= {
				show			= true, 
			},
			
			majorEffect	= {
				incShow			= true,
				decShow			= true,
			}, 
			
			minorEffect	= {
				incShow			= true,
				decShow			= true,
			},
			
			taunt		= {
				show			= true,
				anchor			= {CENTER, nil, CENTER,  200,  -240},
				iconSize		= 20,
			},
	
			antinomic	= {
				show			= true
			},
				
		}, 
		
		effects				= {
			physResistIncColor	= {190/255, 190/255, 80 /255, 0.7},
			physResistDecColor	= {150/255, 150/255, 150/255, 0.8}, 
			spellResistIncColor	= {110/255, 100/255, 255/255, 0.7},
			spellResistDecColor	= {160/255, 180/255, 240/255, 0.8}, 
			physResistDualColor	= {80 /255, 255/255, 110/255, 0.6},
			spellResistDualColor= {100/255, 80 /255, 255/255, 0.6},
			showMajPhysResistInc	= false,
			showMinPhysResistInc	= false,
			showMajSpellResistInc	= false,
			showMinSpellResistInc	= false,
			showMajPhysResistDec	= false,
			showMinPhysResistDec	= false,
			showMajSpellResistDec	= false,
			showMinSpellResistDec	= false,
			showMajPhysResistDual	= false,
			showMinPhysResistDual	= false,
			showMajSpellResistDual	= false,
			showMinSpellResistDual	= false,
		},
		
		lowAttributes		= {
			show				= true, 
			trigger				= 30, 
			anchor	 			= {CENTER, nil, CENTER, 700, 0}, 
			fontName			= 'Univers 67', 
			fontSize			= 21, 
		}, 		
		combatTips			= {
			show				= true, 
			zoShow				= true, 
			anchor 				= {CENTER, nil, CENTER, -700, 0}, 
			fontName			= 'Univers 67', 
			fontSize			= 30, 
			blockColor 			= {255/255,  200/255,  200/255,  1}, 
			exploitColor 		= {200/255,  255/255,  230/255,  1}, 
			interruptColor 		= {230/255,  200/255,  255/255,  1}, 
			dodgeColor 			= {255/255,  230/255,  200/255,  1}, 
		},
		
		clepsydre			= {
			show				= true,
			anchor 				= {CENTER, nil, CENTER, 0, -570}, 
			fontName			= 'Univers 67', 
			fontSize			= 20, 
			color	 			= {255/255,  255/255,  255/255,  1},
			chronocolor			= {255/255,  255/255,  255/255,  1},			
			alpha				= 1,
			automaticChrono		= "mano",
			timetoshwochrono	= 5,
			chronoTurnSignal	= true,
		},
	}, 
}
	
local varsAccountDefaults	= {
	userConfigs = {
	}
}

local varsDefaults = {
	config = CurvyHud.defaultConfigs[1]
}

-- Settings : Save and Loc
-- Reset saved vars to default values
function  CurvyHud.ResetToDefaults()
	for key ,  value in pairs( varsDefaults ) do
		CurvyHud.vars[key] = varsDefaults[key]
	end
	for key ,  value in pairs( varsAccountDefaults ) do
		CurvyHud.varsAccount[key] = varsAccountDefaults[key]
	end
end

-- Get the appropriate localization table
function CurvyHud:GetLoc()
	if (GetCVar('language.2') == 'fr') then
		return CurvyHud.FR
	elseif (GetCVar('language.2') == 'de')  then
		return CurvyHud.DE
	else
		return CurvyHud.EN
	end
end
-- On Addon Loaded
function CurvyHud:OnAddonLoaded(event,  addonName)
	if (addonName ~= CurvyHud.name) then
		return
	end
	-- unregistering from EVENT_ADD_ON_LOADED cause we don't need it anymore
	EVENT_MANAGER:UnregisterForEvent(CurvyHud.name,  EVENT_ADD_ON_LOADED)	
	-- Loading saved vars
	CurvyHud.varsAccount = ZO_SavedVars:NewAccountWide('CurvyHudData',  CurvyHud.varsAccountVersion,  nil,  varsAccountDefaults)
	CurvyHud.vars = ZO_SavedVars:New('CurvyHudData',  CurvyHud.varsVersion	,  nil,  varsDefaults)
	-- loading configuration from saved vars
	CurvyHud.config = CurvyHud.vars.config
	CurvyHud.bars 				= {}
	CurvyHud.state 				= {}
	CurvyHud.state.countButton 	= 0
	CurvyHud.state.animChrono 	= 0
	CurvyHud.movableFrames 		= {}
	CurvyHud.moveMode = {}
	CurvyHud.moveMode.enabled = false
	CurvyHud.button = {}
	CurvyHud.button.new 	= false
	CurvyHud.button.load 	= false
	CurvyHud.button.save	= false
	CurvyHud.targetEffects 	= {}
	CurvyHud.playerEffects 	= {}
	CurvyHud.location		= {}
	CurvyHud:InitializeMainVisuals()
	CurvyHud:BuildVisualizers()
	CurvyHud:MoveMode()
	CurvyHud:WelcomeInGame()
	CurvyHud:BagSlot()
	CurvyHud:InitializeClepsydre()
	CurvyHud:InitializeState()	
	CurvyHud:MenuPanel()
	-- Registering events
	CurvyHud:RegisteringEvents()
end

	EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_ADD_ON_LOADED, function(...) CurvyHud:OnAddonLoaded(...) end)