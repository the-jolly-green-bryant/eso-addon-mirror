---------------------------------------------------------
--	ARKadium's Extended Guild Notes test file  		    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 




ARK_EGN              	= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.CombatState		 	= ARK_EGN.CombatState or{}
local CS				= ARK_EGN.CombatState
CS.sVars			= {}
CS.savedVarsVersion= 1
CS.defaults				= {
	--UI default options
	bAlwaysVisible		= true,
	ui					={
		scale			= 1,
		offsetX			= 935,
		offsetY			= 515,
		alpha			= 0.7,	
	},
	inCombatColor		={
		r 				= 0.8, --204
		g 				= 0.13, --33
		b 				= 0.153, --39
		a 				= 1, --255
		hex 			= "CC2127",
	},	
	outtaCombatColor		={
		r 				= 0.13, --33
		g 				= 0.8, --204
		b 				= 0.153, --39
		a 				= 1, --255
		hex 			= "21CC27",
	},	
}
CS.bIsInCombat = false

local WM = WINDOW_MANAGER

do

	function CS.Initialize()
		--loads saved variables from file or default
		CS.sVars = ZO_SavedVars:New( "ARK_EGN_SavedVariables", CS.savedVarsVersion, "CombatState", CS.defaults )
		
		--initialize settings
		
		--intialize ui
		CS.InitUI()
		
		--register events
		EVENT_MANAGER:RegisterForEvent( EGN.addonName, EVENT_ACTION_LAYER_PUSHED, CS.OnActionLayerPushed )
		EVENT_MANAGER:RegisterForEvent( EGN.addonName, EVENT_ACTION_LAYER_POPPED, CS.OnActionLayerPopped )
		EVENT_MANAGER:RegisterForEvent( EGN.addonName, EVENT_PLAYER_COMBAT_STATE, CS.OnPlayerCombatState )
		
		zo_callLater(function() EGN.Debug( "CombatState","Module Loaded" ) end, 2600)
	end

	--retrive controls from the xml file
	function CS.InitUI()
		--get the top level control
		CS.CombatStateUI = WM:GetControlByName( "ARK_EGN_CS_UI" )

		local CSUI = CS.CombatStateUI
		CSUI:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, CS.sVars.ui.offsetX, CS.sVars.ui.offsetY )
		--alpha
		CSUI.alphaControl = WM:GetControlByName( "ARK_EGN_CS_UI_ALPHA" )
		--color texture
		CSUI.colorControl = WM:GetControlByName( "ARK_EGN_CS_UI_COLOR" )
		--animation texture
		CSUI.spriteControl = WM:GetControlByName( "ARK_EGN_CS_UI_SPRITE" )
		
		--create the animation timeline from xml definition : <TextureAnimation cellsHigh = "3" cellsWide = "3" framerate = "45"/>
		CS.spriteTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ARK_EGN_CS_TIMELINE", CSUI.spriteControl)
		CS.spriteTimeline:SetHandler("OnStop", function() CSUI.spriteControl:SetHidden(true) end)	
		CS.spriteTimeline:InsertCallback(function() CSUI.spriteControl:SetHidden(false) end, 1)
		
		CS.RefreshCombatStateUI()
		CS.CombatStateUI:SetHidden(false)
				
	end

	--set the ui scale, alpha and colors depending on combatstate
	function CS.RefreshCombatStateUI()
		
		local uiDimension = 50*CS.sVars.ui.scale
		CS.CombatStateUI:SetDimensionConstraints(uiDimension ,uiDimension ,uiDimension ,uiDimension )
				
		CS.CombatStateUI.alphaControl:SetAlpha(CS.sVars.ui.alpha)	
		
		if CS.bIsInCombat then
			CS.CombatStateUI.colorControl:SetColor(CS.GetInCombatColor())
		else
			CS.CombatStateUI.colorControl:SetColor(CS.GetOuttaCombatColor())
		end
		
	end
	
	--player's combat state changed
	function CS.OnPlayerCombatState(eventCode, inCombat)
		
		CS.bIsInCombat = inCombat
		
		if EGN.sVars.bEnableCombatState then
			CS.RefreshCombatStateUI()
			CS.spriteTimeline:PlayFromStart()
		end
		
		--todo : use as events
		if inCombat then
			CS.OnCombatStarted()
		else
			CS.OnCombatEnded()
		end
	end
	
	function CS.OnCombatStarted()
		--do whatever
	end
	
	function CS.OnCombatEnded()
		--do whatever
	end	
	
	--hide ui alongside other combat uis
	function CS.OnActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
		if CS.sVars.bAlwaysVisible then return end
		if layerIndex == 3 then -- layers 3, 7 and 11
			CS.CombatStateUI:SetHidden(true)	
		end
	end
	
	--show ui alongside other combat uis
	function CS.OnActionLayerPopped(eventCode, layerIndex, activeLayerIndex)
		if CS.sVars.bAlwaysVisible then return end
		if layerIndex == 3 then-- layers 3, 7 and 11
			CS.CombatStateUI:SetHidden(false)				
		end
	end
	
	function CS.OnUIMoveStart()
		--EGN.Debug( "CS.OnUIMoveStart()", "Function" )		
	end
	--store new position after move stopped
	function CS.OnUIMoveStop()
		CS.sVars.ui.offsetX = CS.CombatStateUI:GetLeft()
		CS.sVars.ui.offsetY = CS.CombatStateUI:GetTop()	
	end

	--linked by binding.xml
	function CS.ToggleCSUI()
		CS.CombatStateUI:ToggleHidden()
	end

	function CS.GetInCombatColor()
		return CS.sVars.inCombatColor.r, CS.sVars.inCombatColor.g, CS.sVars.inCombatColor.b, CS.sVars.inCombatColor.a
	end	

	function CS.SetInCombatColor(r, g, b, a)
		CS.sVars.inCombatColor.r = r
		CS.sVars.inCombatColor.g = g 
		CS.sVars.inCombatColor.b = b 
		CS.sVars.inCombatColor.a = a 
		CS.sVars.inCombatColor.hex = EGN.RGBAToHex(r, g, b)
		
	end

	function CS.GetOuttaCombatColor()
		return CS.sVars.outtaCombatColor.r, CS.sVars.outtaCombatColor.g, CS.sVars.outtaCombatColor.b, CS.sVars.outtaCombatColor.a
	end	

	function CS.SetOuttaCombatColor(r, g, b, a)
		CS.sVars.outtaCombatColor.r = r
		CS.sVars.outtaCombatColor.g = g 
		CS.sVars.outtaCombatColor.b = b 
		CS.sVars.outtaCombatColor.a = a 
		CS.sVars.outtaCombatColor.hex = EGN.RGBAToHex(r, g, b)		
	end
end



