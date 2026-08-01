HowToBeam = HowToBeam or {}
local HowToBeam = HowToBeam

local LAM2 = LibAddonMenu2

local GlyphChoice = {
	[1] = GetString(SI_HOWTOBEAM_FLAME_NAME),
	[2] = GetString(SI_HOWTOBEAM_SHOCK_NAME),
	[3] = GetString(SI_HOWTOBEAM_ABSORB_NAME),
	[4] = GetString(SI_HOWTOBEAM_OTHER_NAME),
}

function HowToBeam.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "HowToBeam",
		displayName = "HowTo|cffd708Beam|r",
		author = "Floliroy",
		version = HowToBeam.version,
		slashCommand = "/htbeam",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("HowToBeam_Settings", panelData)
	local Unlock = false
	local sV = HowToBeam.savedVariables
	
	local optionsData = {
		{
			type = "checkbox",
			name = GetString(SI_HOWTOBEAM_ENABLE_NAME),
			tooltip = GetString(SI_HOWTOBEAM_ENABLE_TT),
			default = true,
			getFunc = function() return sV.Enable end,
			setFunc = function(newValue) 
				sV.Enable = newValue
			end,
		},
		{
			type = "header",
			name = GetString(SI_HOWTOBEAM_SETTINGS_HEADER),
		},
		{
			type = "description",
			text = GetString(SI_HOWTOBEAM_SETTINGS_DESC),
		},
		{
			type = "dropdown",
			name = GetString(SI_HOWTOBEAM_GLYPH_NAME),
			tooltip = GetString(SI_HOWTOBEAM_GLYPH_TT),
			choices = GlyphChoice,
			default = GlyphChoice[1],
			getFunc = function() return GlyphChoice[sV.Glyph] end,
			setFunc = function(selected)
				for index, name in ipairs(GlyphChoice) do
					if name == selected then
						sV.Glyph = index
						break
					end
				end
			end,
		},
		{
			type = "slider",
			name = GetString(SI_HOWTOBEAM_HP_NAME),
			tooltip = GetString(SI_HOWTOBEAM_HP_TT),
			min = 1,
			max = 20,
			step = 1,
			default = 3,
			getFunc = function() return sV.maxTargetHPchoose end,
			setFunc = function(newValue) 
				sV.maxTargetHPchoose = newValue
				end,
		},
		{
			type = "header",
			name = GetString(SI_HOWTOBEAM_CUSTOMIZATION_HEADER),
		},
		{
			type = "description",
			text = GetString(SI_HOWTOBEAM_CUSTOMIZATION_DESC),
		},
		{
			type = "checkbox",
			name = GetString(SI_HOWTOBEAM_UNLOCK_NAME),
			tooltip = GetString(SI_HOWTOBEAM_UNLOCK_TT),
			default = false,
			getFunc = function() return Unlock end,
			setFunc = function(newValue)
				HTBAlert:SetHidden(not newValue)
			end,
		},
		{
			type = "editbox",
			name = GetString(SI_HOWTOBEAM_SPAMMABLEALERT_NAME),
			tooltip = GetString(SI_HOWTOBEAM_SPAMMABLEALERT_TT),
			default = "Start Use Beam",
			getFunc = function() return sV.SpammableAlert end,
			setFunc = function(newValue) 
				sV.SpammableAlert = newValue
				end,
		},
		{
			type = "editbox",
			name = GetString(SI_HOWTOBEAM_DOTALERT_NAME),
			tooltip = GetString(SI_HOWTOBEAM_DOTALERT_TT),
			default = "Only Spear + Blockade",
			getFunc = function() return sV.DoTAlert end,
			setFunc = function(newValue) 
				sV.DoTAlert = newValue
				end,
		},
		{
			type = "editbox",
			name = GetString(SI_HOWTOBEAM_FINISHALERT_NAME),
			tooltip = GetString(SI_HOWTOBEAM_FINISHALERT_TT),
			default = "Beam Them to Death",
			getFunc = function() return sV.FinishAlert end,
			setFunc = function(newValue) 
				sV.FinishAlert = newValue
				end,
		},
		{
			type = "colorpicker",
			name = GetString(SI_HOWTOBEAM_COLOR_NAME),
			tooltip = GetString(SI_HOWTOBEAM_COLOR_TT),
			getFunc = function() return unpack(sV.ColorRGB) end,
			setFunc = function(r,g,b,a)
				sV.ColorRGB = {r,g,b,a}
				HTBAlert_Label:SetColor(unpack(sV.ColorRGB))
			end,
		},
		{
			type = "header",
			name = GetString(SI_HOWTOBEAM_DEBUG_HEADER),
		},
		{
			type = "description",
			text = GetString(SI_HOWTOBEAM_DEBUG_DESC),
		},
		{
			type = "button",
			name = GetString(SI_HOWTOBEAM_DEBUG_NAME),
			tooltip = GetString(SI_HOWTOBEAM_DEBUG_TT),
			func = function()
				HowToBeam.Debug()
			end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Advanced Mode",
			tooltip = "With this mode the first Alert will tell you which skills to drop.",
			default = false,
			getFunc = function() return sV.showWhatToDrop end,
			setFunc = function(newValue)
				sV.showWhatToDrop = newValue
			end,
			width = "half",
		},
	}
	
	LAM2:RegisterOptionControls("HowToBeam_Settings", optionsData)
end