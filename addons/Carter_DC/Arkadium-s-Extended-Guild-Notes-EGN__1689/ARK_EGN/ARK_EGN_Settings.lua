---------------------------------------------------------
--	ARKadium's EGN			 Settings Menu file    	    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 

local LAM = LibStub("LibAddonMenu-2.0")
ARK_EGN        			= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.CombatState		 	= ARK_EGN.CombatState or{}
local CS				= ARK_EGN.CombatState

function EGN.CreateSettingsMenu()

 	local panelData ={
		type = "panel",
		name = EGN.addonName,
		displayName = EGN.displayName,
		author = EGN.author,
		version = EGN.addonVersion,
		website = EGN.guildWebSite,
		--slashCommand = "/ark",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(EGN.addonName.."_LAM", panelData)

	local optionsTable ={
		[1] = {
			type = "description",
			text = GetString(ARK_EGN_MENU_DESCRIPTION), 
		},
		[2] = {
			type = "header",
			name = EGN.Colorize(GetString(ARK_EGN_MENU_GENERAL)),
			width = "full",
		},
		[3] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_STARTMESSAGE), --"Show Start Message",
			tooltip = GetString(ARK_EGN_MENU_STARTMESSAGE_TT),--"Enables or Disables the Start Message",
			getFunc = function() return EGN.sVars.bEnableStartMessage end,
			setFunc = function(value)
				EGN.sVars.bEnableStartMessage = value   
			end,
			default = EGN.defaults.bEnableStartMessage,
			disabled = function() return not EGN.sVars.bIsARK end, --only ark members can disable 
		},
		[4] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_DEBUGMODE),--"bUseDebugMode", 
			tooltip = GetString(ARK_EGN_MENU_DEBUGMODE_TT),--"Only for Testers", 
			getFunc = function() return EGN.sVars.bUseDebugMode end,
			setFunc = function(value)
				EGN.sVars.bUseDebugMode = value            
			end,
			default = EGN.defaults.bUseDebugMode,
			disabled = function() return not EGN.sVars.bIsTester end,
		},		
		[5] = {
			type = "colorpicker",
			name = GetString(ARK_EGN_MENU_COLOR),
			tooltip = string.format(GetString(ARK_EGN_MENU_COLOR_TT), 204, 33, 39), --"Default values : r=204, g=33, b=39",
			getFunc = function() return EGN.GetMainTextColor() end, 
			setFunc = function(r,g,b,a)
				EGN.SetMainTextColor(r, g, b, a) 
				EGN.sVars.mainTextColor.hex = EGN.RGBAToHex(r, g, b)
			end,
			width = "full",
			default = function() return EGN.default.mainTextColor.r, EGN.default.mainTextColor.g, EGN.default.mainTextColor.b, EGN.default.mainTextColor.a end,
			disabled = false,
		},
		[6] = {
			type = "header",
			name = EGN.Colorize(GetString(ARK_EGN_MENU_MODULES)),
			width = "full",
		},
		[7] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_MODULENOTES),--"bEnableNotes", 
			tooltip = GetString(ARK_EGN_MENU_MODULENOTES_TT),--"", 
			getFunc = function() return EGN.sVars.bEnableNotes end,
			setFunc = function(value)
				EGN.sVars.bEnableNotes = value            
			end,
			default = EGN.defaults.bEnableNotes,
			disabled = function() return EGN.sVars.bIsARK end, --only non ark_members can disable this option
		},	
		[8] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_MODULECHAT),--"bEnableChat", 
			tooltip = GetString(ARK_EGN_MENU_MODULECHAT_TT),--"",
			getFunc = function() return EGN.sVars.bEnableChat end,
			setFunc = function(value)
				EGN.sVars.bEnableChat = value            
			end,
			default = EGN.defaults.bEnableChat,
			disabled = false,
		},	
		[9] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_MODULEGUILDHOUSE),-- "bEnableGuildHouse", 
			tooltip = GetString(ARK_EGN_MENU_MODULEGUILDHOUSE_TT),--"",
			getFunc = function() return EGN.sVars.bEnableGuildHouse end,
			setFunc = function(value)
				EGN.sVars.bEnableGuildHouse = value            
			end,
			default = EGN.defaults.bEnableGuildHouse,
			disabled = false, --function() return EGN.bIsTester end,
		},		
		[10] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_MODULECOMBATSTATE), --"bEnableCombatState", 
			tooltip = GetString(ARK_EGN_MENU_MODULECOMBATSTATE_TT),--"", 
			getFunc = function() return EGN.sVars.bEnableCombatState end,
			setFunc = function(value)
				EGN.sVars.bEnableCombatState = value            
			end,
			default = EGN.defaults.bEnableCombatState,
			disabled = false, 
		},			
		[11] = {
			type = "checkbox",
			name = GetString(ARK_EGN_MENU_MODULETESTAGE), --"bEnableTestage", 
			tooltip = GetString(ARK_EGN_MENU_MODULETESTAGE_TT),--"", 
			getFunc = function() return EGN.sVars.bEnableTestage end,
			setFunc = function(value)
				EGN.sVars.bEnableTestage = value            
			end,
			default = EGN.defaults.bEnableTestage,
			disabled = function() return not EGN.sVars.bIsTester end,
		},	
		[12] = {
			type = "divider",
			width = "full",			
		},
		[13] = {
			type = "submenu",
		    name = EGN.Colorize(GetString(ARK_EGN_MENU_MODULECOMBATSTATE)),
			reference = "SOUS_MENU",
		    controls = {
				[1] = {
					type = "colorpicker",
					name = "In-Combat Color", --GetString(ARK_CC_MENU_COLOR),
					tooltip = "Default is r=204, g=10, b=0",
					getFunc = function() return CS.GetInCombatColor() end, 
					setFunc = function(r,g,b,a)
						CS.SetInCombatColor(r,g,b,a)
						CS.RefreshCombatStateUI()
					end,
					width = "full",
					default = function() return CS.defaults.inCombatColor.r, CS.defaults.inCombatColor.g, CS.defaults.inCombatColor.b, CS.defaults.inCombatColor.a end,
					disabled = function() return not EGN.sVars.bEnableCombatState end,
				},
				[2] = {
					type = "colorpicker",
					name = "Out-of-Combat Color", --GetString(ARK_CC_MENU_COLOR),
					tooltip = "Default is r=10, g=204, b=0",
					getFunc = function() return CS.GetOuttaCombatColor() end, 
					setFunc = function(r,g,b,a)
						CS.SetOuttaCombatColor(r,g,b,a)	
						CS.RefreshCombatStateUI()
					end,
					width = "full",
					default = function() return CS.defaults.outtaCombatColor.r, CS.defaults.outtaCombatColor.g, CS.defaults.outtaCombatColor.b, CS.defaults.outtaCombatColor.a end,
					disabled = function() return not EGN.sVars.bEnableCombatState end,
				},
				[3] = {
					type = "slider",
					name = "Alpha",
					tooltip = "UI Opacity",
					min = 0.2,
					max = 1,
					step = 0.1,
					getFunc = function() return CS.sVars.ui.alpha end,
					setFunc = function(value)
						CS.sVars.ui.alpha = value  
						CS.RefreshCombatStateUI()
					end,
					default = function() return CS.defaults.ui.alpha end,
					disabled = function() return not EGN.sVars.bEnableCombatState end,
				},
				[4] = {
					type = "slider",
					name = "Scale",
					tooltip = "default scale means 50x50 px",
					min = 0.2,
					max = 1.8,
					step = 0.2,
					getFunc = function() return CS.sVars.ui.scale end,
					setFunc = function(value)
						CS.sVars.ui.scale = value
						CS.RefreshCombatStateUI()
					end,
					default = function() return CS.defaults.ui.scale end,
					disabled = function() return not EGN.sVars.bEnableCombatState end,
				},
				[5] = {
					type = "checkbox",
					name = "Always Visible", --GetString(ARK_EGN_MENU_MODULECOMBATSTATE), --"bEnableCombatState", 
					tooltip = "Stay Visible when other UIs are hidden", --GetString(ARK_EGN_MENU_MODULECOMBATSTATE_TT),--"", 
					getFunc = function() return CS.sVars.bAlwaysVisible end,
					setFunc = function(value)
						CS.sVars.bAlwaysVisible = value            
					end,
					default = CS.defaults.bAlwaysVisible,
					disabled = function() return not EGN.sVars.bEnableCombatState end,
				},	
			},
		},
  }
   
   LAM:RegisterOptionControls(EGN.addonName.."_LAM", optionsTable)
   
end


do

	


end