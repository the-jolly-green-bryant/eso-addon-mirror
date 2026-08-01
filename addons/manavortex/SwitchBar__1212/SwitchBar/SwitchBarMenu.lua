--this creates a menu for the addon.
SwitchBar = SwitchBar

function SwitchBar.CreateSettings(savedVars, defaults, iconTextures)
	local LAM = LibAddonMenu2
	local LMP = LibMediaProvider

    local panelData = {
		type = "panel",
		name = "SwitchBar II",
		author = "Elsys,manavortex,dOpiate,razielsoulshadow",
		version = "1.21",
		slashCommand = "/sb",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			--Reset bar position on default click
			SwitchBarMain:ClearAnchors()
			SwitchBarMain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaults.offsetX, defaults.offsetY)
			SwitchBar_Icon1:SetAnchor(CENTER, SwitchBarMain, CENTER, 0, 0)
			SwitchBar_Icon2:SetAnchor(CENTER, SwitchBarMain, CENTER, 0, 0)
			SwitchBar.SavedVars.offsetX = defaults.offsetX
			SwitchBar.SavedVars.offsetY = defaults.offsetY
		end,
	}
	LAM:RegisterAddonPanel("SwitchBar_Settings", panelData)
	
	local optionsData = {
		{ -- Move around?
			type = "checkbox",
			name = "Lock Position?",
			tooltip = "Lock or unlock position?",
			default = not defaults.positionLockOption,
			getFunc = function() return not SwitchBar.SavedVars.positionLockOption end,
			setFunc = function(value)
				--[[Saved Vars set here instead of in setter to keep close eye on inversion status]]
				SwitchBar.SavedVars.positionLockOption = not value 
				SwitchBar.UpdateMouseLock(not value)
			end,
		},

		{ -- Show Always?
			type = "checkbox",
			name = "Show Always?",
			tooltip = "Show out of combat as well?",
			default = defaults.showAlwaysOption,
			getFunc = function() return SwitchBar.SavedVars.showAlwaysOption end,
			setFunc = function(value)
				SwitchBar.UpdateShowAlways(value)
			end,
		},
		
		{ -- Hide Background
			type = "checkbox",
			name = "Hide Background?",
			tooltip = "That dark-ish background.",
			default = defaults.hideBackground,
			getFunc = function() return SwitchBar.SavedVars.hideBackground end,
			setFunc = function(value) 
				SwitchBar.SetBGHidden(value)
			end,
		},
		
		
		{ -- Background transparency
			type = "slider",
			name = "Overall transparency",
			tooltip = "",
			default = defaults.bgAlpha,
			min = 1,
			max = 100,
			getFunc = function() return SwitchBar.SavedVars.bgAlpha end,
			setFunc = function(value)
				SwitchBar.SetAlpha(value)
			end,
		},
		
		{ -- size
			type = "slider",
			name = "Size",
			tooltip = "Width and Height are set to this value",
			min = 30,
			max = 1600,
			default = defaults.size,
			getFunc = function() return SwitchBar.SavedVars.size end,
			setFunc = function(value) 
				SwitchBar.SetSize(value)
			end,
		},

		{ -- icon 1 options lets clean this up some and remove some cludgy stuff
			type = "submenu",
			name = "Weapon Set 1 Options",
			controls = {
				{ -- icon 1 colorpicker
				type = "colorpicker",
				name = "Icon 1 colour",
				default = ZO_ColorDef:New(defaults.colours["1"]),
				getFunc = function() return SwitchBar.GetBgColor("1") end,
				setFunc = function(r,g,b,a) 
					SwitchBar.SetBgColor(r,g,b,a, "1") 
					SwapSet1:SetColor(ZO_ColorDef:New(r,g,b,a))
					end,
				},
				{
				type = "iconpicker",
				name = "Weapon Set 1 Icon",
				default = defaults.icons["1"],
				choices = iconTextures,
				choicesTooltips = SwitchBar.iconTooltips,
				visibleRows = 2,
				getFunc = function() return SwitchBar.SavedVars.icons["1"] end,
				setFunc = function(value) 
						SwitchBar.SavedVars.icons["1"] =  value
						SwitchBar.SetIcon("1", value)
					end,
				iconSize = 100,
				reference = "SwapSet1",
				defaultColor = ZO_ColorDef:New(defaults.colours["1"]),
				},
			}
		},
		{ -- icon 2 options lets clean this up some and remove some cludgy stuff
			type = "submenu",
			name = "Weapon Set 2 Options",
			controls = {
				{ -- icon 2 colorpicker
				type = "colorpicker",
				name = "Icon 2 colour",
				default = ZO_ColorDef:New(defaults.colours["2"]),
				getFunc = function() return SwitchBar.GetBgColor("2") end,
				setFunc = function(r,g,b,a) 
					SwitchBar.SetBgColor(r,g,b,a, "2") 
					SwapSet2:SetColor(ZO_ColorDef:New(r,g,b,a)) 
					end,
				},
				{
				type = "iconpicker",
				name = "Weapon Set 2 Icon",
				default = defaults.icons["2"],
				choices = iconTextures,
				choicesTooltips = SwitchBar.iconTooltips,
				visibleRows = 2,
				getFunc = function() return SwitchBar.SavedVars.icons["2"] end,
				setFunc = function(value) 
						SwitchBar.SavedVars.icons["2"] =  value
						SwitchBar.SetIcon("2", value) 
					end,
				iconSize = 100,
				reference = "SwapSet2",
				defaultColor = ZO_ColorDef:New(defaults.colours["2"]),
				}
			}
		}	
	}
	LAM:RegisterOptionControls("SwitchBar_Settings", optionsData)
end