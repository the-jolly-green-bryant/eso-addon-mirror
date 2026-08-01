local FR = FastRide
local LAM = LibAddonMenu2
local SF = LibSFUtils

local color = SF.hex
local RapidsSkillsArray = FR.RapidsSkillsArray



-- settings page
function FR.RegisterSettings()

	local panelData = {
	   type = "panel",
	   name = FR.name,
	   displayName = SF.GetIconized(FR.name, color.gold),
	   author = SF.GetIconized(FR.author, color.purple),
	   version = SF.GetIconized(FR.version, color.gold),
	   slashCommand = "/fastride.settings",
	   registerForRefresh = true,
	}

	local optionsTable = {
	-- accountwide section
		{
			type = "checkbox",
			name = GetString(FR_ACCOUNTWIDE),
			getFunc = function() return FR.isAccountWide() end,
			setFunc = function(value) FR.setCurrentSV(value) end,
			width = "full",
		},
	-- autoswitchSection
		{
			type = "header",
			name = SF.GetIconized(FR_AUTOSWITCH_NM, color.gold), -- or string id or function returning a string
			width = "full", --or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(FR_ABILITYSLOT),
			min = 1, max = 5, step = 1,
			getFunc = function() return FR.saved.switchSlot end,
			setFunc = function(value) FR.saved.switchSlot = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(FR_SWITCH_MOUNTED),
			disabled = function()
					if(FR.hasRapids() == false) then
						return true
					end
					return false
				end,
			getFunc = function() return FR.saved.autoswitchEnabled end,
			setFunc = function(value)
				FR.saved.autoswitchEnabled = value
				FR.RegisterMountSwitch()
				end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(FR_NOSWITCH_IF_ACTIVE),
			disabled = function()
					if(FR.hasRapids() == true and FR.saved.autoswitchEnabled == true) then
						return false
					end
					return true
				end,
			getFunc = function() return FR.saved.noSwitchActive end,
			setFunc = function(value) FR.saved.noSwitchActive=value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(FR_REVERT_USED),
			disabled = function()
					if(FR.hasRapids() == true and FR.saved.autoswitchEnabled == true) then
						return false
					end
					return true
				end,
			getFunc = function() return FR.saved.revertSwitch end,
			setFunc = function(value) FR.saved.revertSwitch=value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(FR_SWITCH_FADE),
			disabled = function()
					if(FR.hasRapids() == true and FR.saved.revertSwitch == true and FR.saved.autoswitchEnabled == true) then
						return false
					end
					return true
				end,
			getFunc = function() return FR.saved.fadeswitch end,
			setFunc = function(value) FR.saved.fadeswitch=value end,
			width = "full",
		},
		{
			type = "slider",
			name = GetString(FR_SWITCH_FADE_SEC),
			min = 0, max = 5, step = 1,
			getFunc = function() return FR.saved.fadesecs end,
			setFunc = function(value) FR.saved.fadesecs=value end,
			width = "full",
			disabled = function()
					if(FR.hasRapids() == true and FR.saved.revertSwitch == true and FR.saved.autoswitchEnabled == true and FR.saved.fadeswitch == true) then
							return false
						end
					return true
				end,
		},
		{
			type = "checkbox",
			name = GetString(FR_ENABLEICON),
			getFunc = function() return FR.saved.iconEnabled end,
			setFunc = function(value)
					FR.saved.iconEnabled = value
					if( FR.saved.iconEnabled == true and FR.hasRapids() ) then
						FastRideWindowIndicator:SetAlpha(1)
					else
						FastRideWindowIndicator:SetAlpha(0)
					end
				end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(FR_ENABLE_UNSHEATHE),
            tooltip = FR_ENABLE_UNSHEATHE_TT,
			getFunc = function() return FR.saved.unsheatheEnabled end,
			setFunc = function(value)
					FR.saved.unsheatheEnabled = value
				end,
			width = "full",
		},
	-- notifySection
		{
			type = "header",
			name = SF.GetIconized(FR_NOTIFY_NM, color.gold), -- or string id or function returning a string
			width = "full", --or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(FR_NOTIFY_FAILURE),
			getFunc = function() return FR.saved.notify end,
			setFunc = function(value) FR.saved.notify = value end,
			width = "full",
		},
	-- soundSection
		{
			type = "header",
			name = SF.GetIconized(FR_SOUND_NM, color.gold), -- or string id or function returning a string
			width = "full", --or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(FR_SOUND_ENABLED),
			getFunc = function() return FR.saved.soundEnabled end,
			setFunc = function(value) FR.saved.soundEnabled = value end,
			width = "full",
		},
        {-- Sound
            type = "slider",
            name = GetString(FR_SOUND_INDEX),
            min = 1, max = SF.numSounds(), step = 1,
            getFunc = function()
                if type(FR.saved.sound) == "string" then
                    return SF.getSoundIndex(FR.saved.sound)
                end
                return SF.getSoundIndex(FR.saved.sound)
            end,
            setFunc = function(value)
                FR.saved.sound = SF.getSound(value)
                local ctrl = WINDOW_MANAGER:GetControlByName("FR_SOUND_NAME")
                if ctrl ~= nil then
                    ctrl.data.text = SF.ColorText(FR.saved.sound, SF.hex.normal)
                end
                SF.PlaySound(FR.saved.sound)
            end,
            width = "full",
            disabled = function() return not FR.saved.soundEnabled end,
            default = FR.Defaults.sound,
        },
        {
            type = "description",
            title = GetString(FR_SOUND_NAME),
            text = SF.ColorText(FR.saved.sound, SF.hex.normal),
            disable = false,
            reference = "FR_SOUND_NAME",
        },
        -- skillLocalizationSection
		{
			type = "header",
			name = SF.GetIconized(FR_SKILL_LOC_NM, color.gold), -- or string id or function returning a string
			width = "full", --or "half" (optional)
		},
        {
            type = "dropdown",
            name = FR_SKILL_LOC_NM,
            tooltip = FR_SKILL_LOC,
            scrollable = false,
            choices = FR.skillChoices,
            getFunc = function()
                    if FR.saved.skillsloc ~= nil and FR.RapidsSkillsArray[FR.saved.skillsloc] ~= nil then
                        return FR.RapidsSkillsArray[FR.saved.skillsloc]
                    end
                    return FR.RapidsSkillsArray[FR.skillChoices[1] ]
                end,
            setFunc = function(var)
                FR.saved.skillsloc = FR.RapidsSkillsArray[var]
                FR.loadRapids()
            end,
            width = "full",
        },  -- end dropdown
		{
			type = "divider",
			width = "full", --or "half" (optional)
			height = 10,
			alpha = 0.5,
		},
	}

	if LAM == nil then return end
	LAM:RegisterAddonPanel("FastRideOptions", panelData)
	LAM:RegisterOptionControls("FastRideOptions", optionsTable)
end
