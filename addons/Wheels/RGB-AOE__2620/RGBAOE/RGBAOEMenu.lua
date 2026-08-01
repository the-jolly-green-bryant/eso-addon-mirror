rgbaoe = rgbaoe or { }
local r = rgbaoe
local EM = GetEventManager()

function r.buildMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = r.name,
		displayName = "|cFF0000R|r|c00FF00G|r|c0000FFB|r AOE",
		author = "Wheels",
		version = ""..r.version,
	}

	local options = {
		{
			type = "header",
			name = "Settings",
		},
		{
			type = "checkbox",
			name = "Enabled",
			tooltip = "Enable or disable RGB AOE (can also use /rgbaoe in chat)",
			getFunc = function() return r.savedVars.enabled end,
			setFunc = function(value)
				r.savedVars.enabled = value
				r.setState(value, false)
			end,
			
		},
		{
			type = "colorpicker",
			name = "Default Color",
			tooltip = "The color that your AoEs will return to when RGB AOE is disabled",
			warning = "Disable RGB AOE (above) before changing this or it may act weirdly",
			getFunc = function()
				local c = r.savedVars.defaultColor
				--r.setState(false, false)
				--SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, r.savedVars.defaultColor)
				--red, green, blue = Options_Gameplay_MonsterTellsEnemyColorColor:GetColor()
				--r.setState(r.savedVars.enabled, false)
				--return red, green, blue
				return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
			end,
			setFunc = function(red,green,blue,a)
				local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
				r.savedVars.defaultColor = newColor
				SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, newColor)
			end,
		},
		{
			type = "slider",
			name = "Cycle Speed",
			tooltip = "The rate at which the colors cycle (lower is faster)",
			min = 10,
			max = 75,
			step = 1,
			getFunc = function() return r.savedVars.speed end,
			setFunc = function(value)
				r.savedVars.speed = value
				r.setState(false, false)
				r.setState(true, false)
			end,	
		},
		{
			type = "checkbox",
			name = "Turbo Mode",
			tooltip = "Enable to double the color cycle speed",
			warning = "I'm not responsible for any deaths to AoEs due to distraction",
			getFunc = function() return r.savedVars.turbo == 2 end,
			setFunc = function(value)
				if value then
					r.savedVars.turbo = 2
				else
					r.savedVars.turbo = 1
				end
			end,
			
		},
	}
	LAM:RegisterAddonPanel(r.name.."Options", panelData)
	LAM:RegisterOptionControls(r.name.."Options", options)
end

