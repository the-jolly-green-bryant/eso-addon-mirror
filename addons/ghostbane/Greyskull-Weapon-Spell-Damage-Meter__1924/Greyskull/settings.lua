local GS = Greyskull

local function buildLAMSettingsMenu()
	-- --------------------
	-- Create Settings
	-- --------------------
	local optionsData = {}
	local LAM2 = LibAddonMenu2
	local settings = GS.db.settings
	local defaults = GS.defaults_db.settings

	local panelData = {
		 type = "panel",
		 name = "Greyskull",
		 version = "1.1.1",
		 author = '|c00a313Ghostbane|r',
		 website = 'https://www.esoui.com/downloads/info1924-GreyskullWeaponSpellDamageMeter.html'
	}

	-- optionsData[#optionsData+1] = {
    --     type = 'checkbox',
    --     name = 'Account Wide Settings',
    --     tooltip = 'Check for account wide addon settings',
    --     getFunc = function() return GS.db.settings.global end,
    --     setFunc = function(value)
    
    --         if value then
    --             GS.db = ZO_SavedVars:NewAccountWide('GreyskullSettings', 2, nil, GS.defaults_db)
    --         else
    --             GS.db = ZO_SavedVars:NewCharacterIdSettings('GreyskullSettings', 2, GetWorldName(), GS.defaults_db, nil)
    --         end
    
    --         GS.db.settings.global = value
    
    --     end,
    --     -- requiresReload = true,
    --     default = false
    -- }


	optionsData[#optionsData+1] = {
		type = "dropdown",
		name = "Power type:",
		tooltip = "Choose your power type",
		choices = {'Weapon Damage','Spell Damage','Hybrid'},
		getFunc = function()
			if settings.hybrid then
				return 'Hybrid'
			elseif settings.powerType.spellPower then
				return 'Spell Damage'
			else
				return 'Weapon Damage'
			end
		end,
		setFunc = function(choice)
			
			local powerType = settings.powerType

			if choice == 'Hybrid' then
				settings.hybrid = true
				powerType.spellPower = false
				powerType.weaponPower = false
			else
				settings.hybrid = false

				if choice == 'Weapon Damage' then
					powerType.spellPower = false
					powerType.weaponPower = true
					GS.UI.PowerLabel:SetText('WD')
				else
					powerType.spellPower = true
					powerType.weaponPower = false
					GS.UI.PowerLabel:SetText('SD')
				end
			end
		end
	}

	optionsData[#optionsData+1] = {
		type = "colorpicker",
		name = "BG Color",
		tooltip = "Container BG Color",
		getFunc = function() return unpack(settings.backgroundColor) end,
		setFunc = function(r,g,b,a)
			settings.backgroundColor = {r,g,b,a}
			GS.UI.BG:SetCenterColor(r,g,b,a)
		end,
		default = unpack(defaults.backgroundColor)
	}

	optionsData[#optionsData+1] = {
		type = "slider",
		name = "Custom Scale",
		tooltip = "Enlarge by %",
		min = 0,
		max = 100,
		getFunc = function()
			return settings.customScale
		end,
		setFunc = function(value)
			GS.CustomScale(value)
			settings.customScale = value
		end,
		default = defaults.customScale
	}

	optionsData[#optionsData+1] = {
		type = "description",
		title = "",
		text = [[
		]]
	}
	optionsData[#optionsData+1] = {
		type = "header",
		name = "Color Notifcations",
	}
	optionsData[#optionsData+1] = {
		type = "description",
		text = [[You can set a damage value, and assign it a color. Whenever your Weapon/Spell Damage goes past this number, your meter value will change to this colour as an easier in-combat reference to a particular damage increase proc
		]]
	}

	local weaponDamageOptions = {}

	for i in pairs(defaults.levels.weapon) do
		weaponDamageOptions[#weaponDamageOptions+1] = {
			type = "editbox",
			name = "Weapon Damage Level #"..i,
			tooltip = "Power level for Level #"..i,
			getFunc = function() return settings.levels.weapon[i].level end,
			setFunc = function(level) settings.levels.weapon[i].level = level end,
			default = defaults.levels.weapon[i].level,
			width = 'half'
		}
		weaponDamageOptions[#weaponDamageOptions+1] = {
			type = "colorpicker",
			tooltip = "Color for Level #"..i,
			getFunc = function() return unpack(settings.levels.weapon[i].color) end,
			setFunc = function(r,g,b,a) settings.levels.weapon[i].color = {r,g,b,a} end,
			default = unpack(defaults.levels.weapon[i].color),
			width = 'half'
		}
	end

	local spellDamageOptions = {}

	for i in pairs(defaults.levels.spell) do
		spellDamageOptions[#spellDamageOptions+1] = {
			type = "editbox",
			name = "Spell Damage Level #"..i,
			tooltip = "Power level for Level #"..i,
			getFunc = function() return settings.levels.spell[i].level end,
			setFunc = function(level) settings.levels.spell[i].level = level end,
			default = defaults.levels.spell[i].level,
			width = 'half'
		}
		spellDamageOptions[#spellDamageOptions+1] = {
			type = "colorpicker",
			tooltip = "Color for Level #"..i,
			getFunc = function() return unpack(settings.levels.spell[i].color) end,
			setFunc = function(r,g,b,a) settings.levels.spell[i].color = {r,g,b,a} end,
			default = unpack(defaults.levels.spell[i].color),
			width = 'half'
		}
	end

	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = 'Weapon Damage Alerts',
		reference = "Weapon_Damage_Options_Submenu",
		controls = weaponDamageOptions
	}

	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = 'Spell Damage Alerts',
		reference = "Spell_Damage_Options_Submenu",
		controls = spellDamageOptions
	}

	optionsData[#optionsData+1] = {
		type = "description",
		title = "",
		text = [[
		]]
	}
	optionsData[#optionsData+1] = {
		type = "header",
		name = "Advanced",
	}
	optionsData[#optionsData+1] = {
		type = "description",
		title = "",
		text = [[The milliseconds for the loop that renders the damage of the meter. You can select the value based on what is the best performance for you. Default is 500ms
		]]
	}
	optionsData[#optionsData+1] = {
		type = "slider",
		name = "Render Interval",
		tooltip = "How fast should the meter re-render",
		min = 200,
		max = 3000,
		getFunc = function()
			return settings.renderTick
		end,
		setFunc = function(value)
			EVENT_MANAGER:UnregisterForUpdate(addon_name..'Render')
			EVENT_MANAGER:RegisterForUpdate(addon_name..'Render',value,GS.Render)
			settings.renderTick = value
		end,
		default = defaults.renderTick
	}

	LAM2:RegisterAddonPanel("GreyskullOptions", panelData)
	LAM2:RegisterOptionControls("GreyskullOptions", optionsData)
end

GS.buildSettingsMenu = buildLAMSettingsMenu