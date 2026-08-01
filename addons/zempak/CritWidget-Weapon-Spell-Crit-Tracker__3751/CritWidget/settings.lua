local CW = CritWidget

local function buildLAMSettingsMenu()
	-- --------------------
	-- Create Settings
	-- --------------------
	local optionsData = {}
	local LAM2 = LibAddonMenu2
	local settings = CW.db.settings
	local defaults = CW.defaults_db.settings

	local panelData = {
		 type = "panel",
		 name = "CritWidget",
		 version = "1.0.0",
		 author = '|c00a313Ghostbane, @Zempak|r',
		 --website = 'https://www.esoui.com/downloads/info1924-GreyskullWeaponSpellDamageMeter.html'
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
		name = "Crit type:",
		tooltip = "Choose your crit type",
		choices = {'Weapon Crit','Spell Crit','Hybrid'},
		getFunc = function()
			if settings.hybrid then
				return 'Hybrid'
			elseif settings.critType.spellCrit then
				return 'Spell Crit'
			else
				return 'Weapon Crit'
			end
		end,
		setFunc = function(choice)
			
			local critType = settings.critType

			if choice == 'Hybrid' then
				settings.hybrid = true
				critType.spellCrit = false
				critType.weaponCrit = false
			else
				settings.hybrid = false

				if choice == 'Weapon Crit' then
					critType.spellCrit = false
					critType.weaponCrit = true
					CW.UI.CritLabel:SetText('WC')
				else
					critType.spellCrit = true
					critType.weaponCrit = false
					CW.UI.CritLabel:SetText('SC')
				end
			end
		end
	}

	optionsData[#optionsData+1] = {
		type = "colorpicker",
		name = "Background Color",
		tooltip = "Container BG Color",
		getFunc = function() return unpack(settings.backgroundColor) end,
		setFunc = function(r,g,b,a)
			settings.backgroundColor = {r,g,b,a}
			CW.UI.BG:SetCenterColor(r,g,b,a)
		end,
		default = unpack(defaults.backgroundColor)
	}

	optionsData[#optionsData+1] = {
		type = "slider",
		name = "Custom Scale UI",
		tooltip = "Enlarge by %",
		min = 0,
		max = 100,
		getFunc = function()
			return settings.customScale
		end,
		setFunc = function(value)
			CW.CustomScale(value)
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
		name = "Custom Color Notifcations",
	}
	optionsData[#optionsData+1] = {
		type = "description",
		text = [[You can set a crit value, and assign it a color. Whenever your Weapon/Spell Crit goes past this number, your meter value will change to this colour as an easier in-combat reference to a particular damage increase proc
		]]
	}

	local weaponCritOptions = {}

	for i in pairs(defaults.levels.weapon) do
		weaponCritOptions[#weaponCritOptions+1] = {
			type = "editbox",
			name = "Weapon Crit Level #"..i,
			tooltip = "Crit level for Level #"..i,
			getFunc = function() return settings.levels.weapon[i].level end,
			setFunc = function(level) settings.levels.weapon[i].level = level end,
			default = defaults.levels.weapon[i].level,
			width = 'half'
		}
		weaponCritOptions[#weaponCritOptions+1] = {
			type = "colorpicker",
			tooltip = "Color for Level #"..i,
			getFunc = function() return unpack(settings.levels.weapon[i].color) end,
			setFunc = function(r,g,b,a) settings.levels.weapon[i].color = {r,g,b,a} end,
			default = unpack(defaults.levels.weapon[i].color),
			width = 'half'
		}
	end

	local spellCritOptions = {}

	for i in pairs(defaults.levels.spell) do
		spellCritOptions[#spellCritOptions+1] = {
			type = "editbox",
			name = "Spell Crit Level #"..i,
			tooltip = "Crit level for Level #"..i,
			getFunc = function() return settings.levels.spell[i].level end,
			setFunc = function(level) settings.levels.spell[i].level = level end,
			default = defaults.levels.spell[i].level,
			width = 'half'
		}
		spellCritOptions[#spellCritOptions+1] = {
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
		name = 'Weapon Crit Alerts',
		reference = "Weapon_Crit_Options_Submenu",
		controls = weaponCritOptions
	}

	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = 'Spell Crit Alerts',
		reference = "Spell_Crit_Options_Submenu",
		controls = spellCritOptions
	}

	optionsData[#optionsData+1] = {
		type = "description",
		title = "",
		text = [[
		]]
	}
	optionsData[#optionsData+1] = {
		type = "header",
		name = "Advanced Setting",
	}
	optionsData[#optionsData+1] = {
		type = "description",
		title = "",
		text = [[The milliseconds for the loop that renders the damage of the meter. You can select the value based on what is the best performance for you. Default is 500ms
		]]
	}
	optionsData[#optionsData+1] = {
		type = "slider",
		name = "Render Interval Setting",
		tooltip = "How fast should the meter re-render",
		min = 200,
		max = 3000,
		getFunc = function()
			return settings.renderTick
		end,
		setFunc = function(value)
			EVENT_MANAGER:UnregisterForUpdate(addon_name..'Render')
			EVENT_MANAGER:RegisterForUpdate(addon_name..'Render',value, CW.Render)
			settings.renderTick = value
		end,
		default = defaults.renderTick
	}

	LAM2:RegisterAddonPanel("CritWidgetOptions", panelData)
	LAM2:RegisterOptionControls("CritWidgetOptions", optionsData)
end

CW.buildSettingsMenu = buildLAMSettingsMenu