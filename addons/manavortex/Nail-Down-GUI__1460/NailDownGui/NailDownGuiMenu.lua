 local NailDownGui = NailDownGui
 local NDG = NailDownGui
 
 local anchorSettings = {"TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT"}
  
 function NailDownGui.CreateSettings(savedVars, defaults)
	
	local settings = NailDownGui.settings
	
	local LAM 	= LibStub("LibAddonMenu-2.0")
	local LL 	= LibLazy
	
	local panelData = {
		type = "panel",
		name = "Nail Down Gui",
		displayName = name,
	 	author = "manavortex",
		version = "1",
		registerSlashCommand = "ndgm",
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true	--boolean (optional) (will set all options controls back to default values)
	}

	NailDownGui.SettingsPanel = LAM:RegisterAddonPanel("NailDownGui_OptionsPanel", panelData)


	local optionsData = {

		{ -- apply when 		- do not copy as template
			type = "submenu",
			name = "apply when...",
			controls = {
				{
					type = "checkbox",
					name = "ALL THE TIME!!!",
					getFunc = function() return settings.onActionLayer end,
					setFunc = function(choice) settings.onActionLayer = choice end
				},
				{
					type = "checkbox",
					name = "player initialized",
					getFunc = function() return settings.resizeOnPlayerInitialized end,
					setFunc = function(choice) settings.resizeOnPlayerInitialized = choice end
				},
				{
					type = "checkbox",
					name = "window size changed",
					getFunc = function() return settings.resizeOnSizeChange end,
					setFunc = function(choice) settings.resizeOnSizeChange = choice end
				},
				{
					type = "checkbox",
					name = "GUI is done loading",
					getFunc = function() return settings.resizeOnGuiLoad end,
					setFunc = function(choice) settings.resizeOnGuiLoad = choice end
				},
				
			},
		},
		{ -- chat 				- do not copy as template
			type = "submenu",
			name = "Chat",
			controls = {
				{ --active?
					type = "checkbox",
					name = "Keep chat maximized at all times?",
					tooltip = "this will work even if you disable the checkbox below, unless it's bugged. You might want to either make your chat very tiny, or make sure it's in background.",
					getFunc = function() return NDG.settings.chatStartMaximized end,
					setFunc = function(choice) NDG.settings.chatStartMaximized = choice end
				},
				{ -- in background?
					type = "checkbox",
					name = "Chat in background?",
					tooltip = "This will put the chat on DrawLayer 0 and the Settings menu on DrawLayer 2. Everything else will stay on DrawLayer 1. Please disable this if you run into any issues.",
					getFunc = function() return settings.chatInBackground end,
					setFunc = function(choice) 
						settings.chatInBackground = choice 
						NailDownGui.ChatZIndex()
					end
				},	
				{ --active?
					type = "checkbox",
					name = "Activate chat re-sizing and re-anchoring?",
					getFunc = function() return NDG.GetActive("chatContainer") end,
					setFunc = function(choice) NDG.SetActive("chatContainer", choice) end
				},			
				{ -- my anchor
					type = "dropdown",
					name = "anchor my",
					tooltip = "What position should this element have (unless selected otherwise, relative to GUI_ROOT)?",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetPosition("chatContainer", choice)
					end
				},
				{ -- anchorName
					type = "dropdown",
					name = "to control",
					choices = {"GuiRoot", "wykkydsToolbar"},
					getFunc = function() return NDG.GetAnchorName("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetAnchorName("chatContainer", choice)
					end
				},
				{ -- anchor anchor
					type = "dropdown",
					name = "s...",
					choices = anchorSettings,
					getFunc = function() return NDG.GetAnchorPosition("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetAnchorPosition("chatContainer", choice)
					end
				},
				{ -- offset X
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetXOffset("chatContainer", choice)
					end
				},
				{ -- offset Y
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetYOffset("chatContainer", choice)
					end
				},
				{ -- width
					type = "editbox",
					name = "width",
					width = "half",
					getFunc = function() return NDG.GetSizeX("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetSizeX("chatContainer", choice)
					end
				},
				{ -- height
					type = "editbox",
					name = "height",
					width = "half",
					getFunc = function() return NDG.GetSizeY("chatContainer") end,
					setFunc = function(choice) 
						NDG.SetSizeY("chatContainer", choice)
					end
				},
			},
		}, 	
		{ -- wykkydsToolbar
			type = "submenu",
			name = "wykkyds Toolbar",
			controls = {
			
				{ -- active
					type = "checkbox",
					name = "Reposition Wykkyds Toolbar",
					getFunc = function() return NDG.GetActive("wykkydsToolbar") end,
					setFunc = function(choice) 
						NDG.SetActive("wykkydsToolbar", choice)
					end
					
				},				
				{
					type = "dropdown",
					name = "Position",
					tooltip = "What position should this element have (unless selected otherwise, relative to GUI_ROOT)?",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("wykkydsToolbar") end,
					setFunc = function(choice) 
						NDG.SetPosition("wykkydsToolbar", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("wykkydsToolbar") end,
					setFunc = function(choice) 
						NDG.SetXOffset("wykkydsToolbar", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("wykkydsToolbar") end,
					setFunc = function(choice) 
						NDG.SetYOffset("wykkydsToolbar", choice)
					end
				},			
				
			},
		},
		{ -- DailyAutoshare
			type = "submenu",
			name = "DailyAutoshare",
			controls = {
			
				{ -- active
					type = "checkbox",
					name = "Reposition DailyAutoshare?",
					getFunc = function() return NDG.GetActive("das") end,
					setFunc = function(choice) 
					end
					
				},				
				{
					type = "dropdown",
					name = "Position",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("das") end,
					setFunc = function(choice) 
						NDG.SetPosition("das", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("das") end,
					setFunc = function(choice) 
						NDG.SetXOffset("das", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("das") end,
					setFunc = function(choice) 
						NDG.SetYOffset("das", choice)
					end
				},
				
			},
		},
		{ -- LootDrop
			type = "submenu",
			name = "LootDrop",
			controls = {
			
				{ -- active
					type = "checkbox",
					name = "Reposition LootDrop?",
					getFunc = function() return NDG.GetActive("lootDrop") end,
					setFunc = function(choice) 
						NDG.SetActive("lootDrop", choice)
					end
					
				},				
				{
					type = "dropdown",
					name = "Position",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("lootDrop", choice) end,
					setFunc = function(choice) 
						NDG.SetPosition("lootDrop", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("lootDrop") end,
					setFunc = function(choice) 
						NDG.SetXOffset("lootDrop", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("lootDrop") end,
					setFunc = function(choice) 
						NDG.SetYOffset("lootDrop", choice)
					end
				},				
			},
		},
		{ -- alertText
			type = "submenu",
			name = "ZOS Quest alert",
			controls = {
				{ -- active
					type = "checkbox",
					name = "Reposition AlertText?",
					getFunc = function() return NDG.GetActive("alertText") end,
					setFunc = function(choice) 
						 NDG.SetActive("alertText", choice)
					end					
				},				
				{
					type = "dropdown",
					name = "Position",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("alertText") end,
					setFunc = function(choice) 
						NDG.SetPosition("alertText", choice)
					end
				},
				{ -- anchorName
					type = "dropdown",
					name = "to control",
					choices = NDG.GetAnchorChoices("alertText"),
					getFunc = function() return NDG.GetAnchorName("alertText") end,
					setFunc = function(choice) 
						NDG.SetAnchorName("magickaBar", choice)
					end
				},
				{ -- anchorPosition
					type = "dropdown",
					name = "'s",
					choices = anchorSettings,
					getFunc = function() return NDG.GetAnchorPosition("alertText") end,
					setFunc = function(choice) 
						NDG.SetAnchorPosition("alertText", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("alertText") end,
					setFunc = function(choice) 
						NDG.SetXOffset("alertText", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("alertText") end,
					setFunc = function(choice)
						NDG.SetYOffset("alertText", choice) 
					end
				},				
			},
		},
		{ -- miniMap
			type = "submenu",
			name = "MiniMap",
			controls = {
				
				{ -- active
					type = "checkbox",
					name = "Reposition miniMap?",
					getFunc = function() return NDG.GetActive("miniMap") end,
					setFunc = function(choice) 
						 NDG.SetActive("miniMap", choice)
					end					
				},
				{
					type = "dropdown",
					name = "Minimap name..?",
					tooltip = "Select ZO_PlayerAttributeHealth if you're not using AdvancedUI",
					choices = LL.values(NDG.controls.miniMap), 
					getFunc = function() return NDG.GetControlName("miniMap") end,
					setFunc = function(choice) 
						NDG.SetControlName("miniMap", choice)
					end
				},	
				
				{
					type = "dropdown",
					name = "Position",
					choices = anchorSettings,
					getFunc = function() return NDG.GetPosition("miniMap") end,
					setFunc = function(choice) 
						NDG.SetPosition("miniMap", choice)
					end
				},
				{ -- anchorName
					type = "dropdown",
					name = "to control",
					choices = NDG.GetAnchorChoices("miniMap"),
					getFunc = function() return NDG.GetAnchorName("miniMap") end,
					setFunc = function(choice) 
						NDG.SetAnchorName("miniMap", choice)
					end
				},
				{ -- anchorPosition
					type = "dropdown",
					name = "'s",
					choices = anchorSettings,
					getFunc = function() return NDG.GetAnchorPosition("miniMap") end,
					setFunc = function(choice) 
						NDG.SetAnchorPosition("miniMap", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset X",
					width = "half",
					getFunc = function() return NDG.GetXOffset("miniMap") end,
					setFunc = function(choice) 
						NDG.SetXOffset("miniMap", choice)
					end
				},
				{
					type = "editbox",
					name = "Offset Y",
					width = "half",
					getFunc = function() return NDG.GetYOffset("miniMap") end,
					setFunc = function(choice)
						NDG.SetYOffset("miniMap", choice) 
					end
				},				
			},
		},
		{ -- AttributeBars 		- do not copy as template
			type = "submenu",
			name = "AttributeBars",
			controls = {
				{ -- active
					type = "checkbox",
					name = "Reposition AttributeBars",
					getFunc = function() return NDG.GetActive("healthBar") end,
					setFunc = function(choice) 
						 NDG.SetActive("healthBar", choice)
						 NDG.SetActive("magickaBar", choice)
						 NDG.SetActive("staminaBar", choice)
					end					
				},		
				{ -- HealthBar
					type = "submenu",
					name = "HealthBar",
					controls = {
						{
							type = "dropdown",
							name = "Health bar name..?",
							tooltip = "Select ZO_PlayerAttributeHealth if you're not using AdvancedUI",
							choices = LL.values(NDG.attributeBarControls.healthBar), 
							getFunc = function() return NDG.GetControlName("healthBar") end,
							setFunc = function(choice) 
								NDG.SetControlName("healthBar", choice)
							end
						},			
						{ -- my anchor
							type = "dropdown",
							name = "anchor health bar's",
							choices = anchorSettings,
							getFunc = function() return NDG.GetPosition("healthBar") end,
							setFunc = function(choice) 
								NDG.SetPosition("healthBar", choice)
							end
						},
						{ -- anchorName
							type = "dropdown",
							name = "to control",
							choices = {"GuiRoot"},
							getFunc = function() return NDG.GetAnchorName("healthBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorName("healthBar", choice)
							end
						},
						{ -- anchor anchor
							type = "dropdown",
							name = "s...",
							choices = anchorSettings,
							getFunc = function() return NDG.GetAnchorPosition("healthBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorPosition("healthBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Health Bar Offset X",
							width = "half",
							getFunc = function() return NDG.GetXOffset("healthBar") end,
							setFunc = function(choice) 
								NDG.SetXOffset("healthBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Health Bar Offset Y",
							width = "half",
							getFunc = function() return NDG.GetYOffset("healthBar") end,
							setFunc = function(choice)
								NDG.SetYOffset("healthBar", choice) 
							end
						},			
					},
				},		
				{ -- MagickaBar
					type = "submenu",
					name = "MagickaBar",	
					controls = {
						{ -- my anchor
							type = "dropdown",
							name = "anchor magicka bar's",
							choices = anchorSettings,
							getFunc = function() return NDG.GetPosition("magickaBar") end,
							setFunc = function(choice) 
								NDG.SetPosition("magickaBar", choice)
							end
						},
						{ -- anchorName
							type = "dropdown",
							name = "to control",
							choices = NDG.GetAnchorChoices("magickaBar"),
							getFunc = function() return NDG.GetAnchorName("magickaBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorName("magickaBar", choice)
							end
						},
						{ -- anchor anchor
							type = "dropdown",
							name = "s...",
							choices = anchorSettings,
							getFunc = function() return NDG.GetAnchorPosition("magickaBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorPosition("magickaBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Magicka Bar Offset X",
							width = "half",
							getFunc = function() return NDG.GetXOffset("magickaBar") end,
							setFunc = function(choice) 
								NDG.SetXOffset("magickaBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Magicka Bar Offset Y",
							width = "half",
							getFunc = function() return NDG.GetYOffset("magickaBar") end,
							setFunc = function(choice)
								NDG.SetYOffset("magickaBar", choice) 
							end
						},			
					},
				},
				{ -- Stamina Bar
					type = "submenu",
					name = "StaminaBar",		
					controls = {
						{ -- my anchor
							type = "dropdown",
							name = "anchor stamina bar's",
							choices = anchorSettings,
							getFunc = function() return NDG.GetPosition("staminaBar") end,
							setFunc = function(choice) 
								NDG.SetPosition("staminaBar", choice)
							end
						},
						{ -- anchorName
							type = "dropdown",
							name = "to control",
							choices = NDG.GetAnchorChoices("staminaBar"),
							getFunc = function() return NDG.GetAnchorName("staminaBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorName("staminaBar", choice)
							end
						},
						{ -- anchor anchor
							type = "dropdown",
							name = "s...",
							choices = anchorSettings,
							getFunc = function() return NDG.GetAnchorPosition("staminaBar") end,
							setFunc = function(choice) 
								NDG.SetAnchorPosition("staminaBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Stamina Bar Offset X",
							width = "half",
							getFunc = function() return NDG.GetXOffset("staminaBar") end,
							setFunc = function(choice) 
								NDG.SetXOffset("staminaBar", choice)
							end
						},
						{
							type = "editbox",
							name = "Stamina Bar Offset Y",
							width = "half",
							getFunc = function() return NDG.GetYOffset("staminaBar") end,
							setFunc = function(choice)
								NDG.SetYOffset("staminaBar", choice) 
							end
						},			
					},
				},
			},
		},
		
	}
	LAM:RegisterOptionControls("NailDownGui_OptionsPanel", optionsData)
end
