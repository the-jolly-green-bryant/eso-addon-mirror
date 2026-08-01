local LAM 						= LibAddonMenu2
local skipPreset				= true
local resetOptions 				= false
-------------------------
-- Settings Window
-------------------------
function AD_BLOCK_PLUS.CreateSettingsWindow()

	local panelData = {
		type = "panel",
		name = "AdBlock Plus",
		displayName = "Scorps AdBlock Plus",
		author = "Scorp",
		version = AD_BLOCK_PLUS.version,
		slashCommand = AD_BLOCK_PLUS.slashCommand.settings,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3032-AdBlockPlus.html",
	}

	local totalBlocked = string.format("%s %s", AD_BLOCK_PLUS.numberFormat(AD_BLOCK_PLUS.blocked), GetString(SI_AD_BLOCK_PLUS_BLOCKED_SINCE))
	
	local function settingsPreset(index)
		if index == 1 then --Basic
			AD_BLOCK_PLUS.block.achievement = true
			AD_BLOCK_PLUS.block.automated 	= false
			AD_BLOCK_PLUS.block.crown 		= true
			AD_BLOCK_PLUS.block.guild 		= true
			AD_BLOCK_PLUS.block.group 		= false
			AD_BLOCK_PLUS.block.item 		= false			
			AD_BLOCK_PLUS.block.url 		= false
			AD_BLOCK_PLUS.block.say 		= false
			AD_BLOCK_PLUS.block.whisper 	= false
			AD_BLOCK_PLUS.block.emote 		= false
			AD_BLOCK_PLUS.block.guilds 		= false
			AD_BLOCK_PLUS.block.yell 		= false
			AD_BLOCK_PLUS.block.party 		= false
			AD_BLOCK_PLUS.block.zone 		= true
		elseif index == 2 then --Advanced
			AD_BLOCK_PLUS.block.achievement = true
			AD_BLOCK_PLUS.block.automated 	= false
			AD_BLOCK_PLUS.block.crown 		= true
			AD_BLOCK_PLUS.block.guild 		= true
			AD_BLOCK_PLUS.block.group 		= false
			AD_BLOCK_PLUS.block.item 		= false			
			AD_BLOCK_PLUS.block.url 		= true
			AD_BLOCK_PLUS.block.say 		= true
			AD_BLOCK_PLUS.block.whisper 	= false
			AD_BLOCK_PLUS.block.emote 		= false
			AD_BLOCK_PLUS.block.guilds 		= false
			AD_BLOCK_PLUS.block.yell 		= true
			AD_BLOCK_PLUS.block.party 		= false
			AD_BLOCK_PLUS.block.zone 		= true		
		elseif index == 3 then --Strict
			AD_BLOCK_PLUS.block.achievement = true
			AD_BLOCK_PLUS.block.automated 	= true
			AD_BLOCK_PLUS.block.crown 		= true
			AD_BLOCK_PLUS.block.guild 		= true
			AD_BLOCK_PLUS.block.group 		= true
			AD_BLOCK_PLUS.block.item 		= true			
			AD_BLOCK_PLUS.block.url 		= true
			AD_BLOCK_PLUS.block.say 		= true
			AD_BLOCK_PLUS.block.whisper 	= false
			AD_BLOCK_PLUS.block.emote 		= false
			AD_BLOCK_PLUS.block.guilds 		= true
			AD_BLOCK_PLUS.block.yell 		= true
			AD_BLOCK_PLUS.block.party 		= false
			AD_BLOCK_PLUS.block.zone 		= true			
		elseif index == 4 then --Full
			AD_BLOCK_PLUS.block.achievement = true
			AD_BLOCK_PLUS.block.automated 	= true
			AD_BLOCK_PLUS.block.crown 		= true
			AD_BLOCK_PLUS.block.guild 		= true
			AD_BLOCK_PLUS.block.group 		= true
			AD_BLOCK_PLUS.block.item 		= true			
			AD_BLOCK_PLUS.block.url 		= true
			AD_BLOCK_PLUS.block.say 		= true
			AD_BLOCK_PLUS.block.whisper 	= true
			AD_BLOCK_PLUS.block.emote 		= true
			AD_BLOCK_PLUS.block.guilds 		= true
			AD_BLOCK_PLUS.block.yell 		= true
			AD_BLOCK_PLUS.block.party 		= true
			AD_BLOCK_PLUS.block.zone 		= true			
		elseif index == 5 then --Custom (Reset)
			AD_BLOCK_PLUS.block.achievement = false
			AD_BLOCK_PLUS.block.automated 	= false
			AD_BLOCK_PLUS.block.crown 		= false
			AD_BLOCK_PLUS.block.guild 		= false
			AD_BLOCK_PLUS.block.group 		= false
			AD_BLOCK_PLUS.block.item 		= false			
			AD_BLOCK_PLUS.block.url 		= false
			AD_BLOCK_PLUS.block.say 		= false
			AD_BLOCK_PLUS.block.whisper 	= false
			AD_BLOCK_PLUS.block.emote 		= false
			AD_BLOCK_PLUS.block.guilds 		= false
			AD_BLOCK_PLUS.block.yell 		= false
			AD_BLOCK_PLUS.block.party 		= false
			AD_BLOCK_PLUS.block.zone 		= false			
		end		
	end
	--AD_BLOCK_PLUS.savedVariables.preset = nil
	local optionsData = {		
		{
			type = "texture",
			image = "AdBlockPlus\\textures\\AdBlockPlusLogo.dds",
			imageWidth = 510,	--max of 250 for half width, 510 for full
			imageHeight = 100,	--max of 100
			--tooltip = "",	--(optional)
			width = "full",	--or "half" (optional)
		},
		{
			type = "description",
			title = GetString(SI_AD_BLOCK_PLUS_DESCRIPTION_SLASH),
			text = "|cb7ff00/abp|r "..GetString(SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY).."\n|cb7ff00/abps|r "..GetString(SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS),
			width = "full",
		},
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"			
		},		
		{
			type = "checkbox",
			name = GetString(SI_AD_BLOCK_PLUS_ENABLE),
			tooltip = GetString(SI_AD_BLOCK_PLUS_ENABLE_TT),
			default = true,
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.enable end,
			setFunc = function(newValue) 
				AD_BLOCK_PLUS.savedVariables.enable = newValue
				AD_BLOCK_PLUS.enable = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_AD_BLOCK_PLUS_NOTIFY),
			tooltip = GetString(SI_AD_BLOCK_PLUS_NOTIFY_TT),
			default = true,
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.notify end,
			setFunc = function(newValue) 
				AD_BLOCK_PLUS.savedVariables.notify = newValue
				AD_BLOCK_PLUS.notify = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_AD_BLOCK_PLUS_FRIEND),
			tooltip = GetString(SI_AD_BLOCK_PLUS_FRIEND_TT),
			default = true,
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.friend end,
			setFunc = function(newValue) 
				AD_BLOCK_PLUS.savedVariables.friend = newValue
				AD_BLOCK_PLUS.friend = newValue
			end,
		},		
		{
			type = "dropdown",
			name = GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET),
			tooltip = GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_TT),
			choices = {
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_1),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_2),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_3),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_4),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_5),
			},
			choicesValues = {1, 2, 3, 4, 5},
			choicesTooltips = {
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_1),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_2),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_3),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_4),
				GetString(SI_AD_BLOCK_PLUS_DROPDOWN_PRESET_CHOICES_TT_5),
			},
			getFunc = function()
				if not AD_BLOCK_PLUS.savedVariables.preset then --default (Advanced)
					AD_BLOCK_PLUS.preset = 2
					AD_BLOCK_PLUS.savedVariables.preset = 2
					settingsPreset(AD_BLOCK_PLUS.preset)
				end
				return AD_BLOCK_PLUS.savedVariables.preset
			end,
			setFunc = function(newValue)
				if not skipPreset then settingsPreset(newValue)	end
				AD_BLOCK_PLUS.preset = newValue
				AD_BLOCK_PLUS.savedVariables.preset = newValue
				skipPreset = false
			end,
			width = "full",	--or "half" (optional)
			default = function()
				resetOptions = true
				skipPreset = false
				AD_BLOCK_PLUS_DROPDOWN_PRESET.data.setFunc(2)
				zo_callLater(function() resetOptions = false end, 1000) --needed so other controls dont override reset
				--return 2
			end,
			reference = "AD_BLOCK_PLUS_DROPDOWN_PRESET",
			--warning = "Will need to reload the UI.",	--(optional)
		},
	}


	-- blocking options
	table.insert(optionsData,
		{
			type = "header",
			name = GetString(SI_AD_BLOCK_PLUS_HEADER_BLOCKING),
			width = "full"			
		}
	)

	for filterType in AD_BLOCK_PLUS.sorted_table(AD_BLOCK_PLUS.chatStrings, false) do
		table.insert(optionsData,
			{
				type = "checkbox",
				name = AD_BLOCK_PLUS.chatStrings[filterType].settings[AD_BLOCK_PLUS.language].name,
				tooltip = AD_BLOCK_PLUS.chatStrings[filterType].settings[AD_BLOCK_PLUS.language].tooltip,
				default = false,
				getFunc = function() return AD_BLOCK_PLUS.savedVariables.block[filterType] end,
				setFunc = function(newValue) 
					AD_BLOCK_PLUS.savedVariables.block[filterType] = newValue
					AD_BLOCK_PLUS.block[filterType] = newValue
					if not resetOptions and AD_BLOCK_PLUS.preset ~= 5 then
						skipPreset = true
						AD_BLOCK_PLUS_DROPDOWN_PRESET.data.setFunc(5) --set to Custom
					end

				end,
				reference = "AD_BLOCK_PLUS_CHECKBOX_"..filterType,
			}
		)		
	end


	--Advanced
	local advancedAgressiveCheckbox =
		{
			type = "checkbox",
			name = GetString(SI_AD_BLOCK_PLUS_AGRESSIVE),
			tooltip = GetString(SI_AD_BLOCK_PLUS_AGRESSIVE_TT),
			default = false,
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.block.agressive end,
			setFunc = function(newValue) 
				AD_BLOCK_PLUS.savedVariables.block.agressive = newValue
				AD_BLOCK_PLUS.block.agressive = newValue
			end,
		}

	local advancedCustomCheckbox =
		{
			type = "checkbox",
			name = AD_BLOCK_PLUS.chatStringsCustom.custom.settings[AD_BLOCK_PLUS.language].name,
			tooltip = AD_BLOCK_PLUS.chatStringsCustom.custom.settings[AD_BLOCK_PLUS.language].tooltip,
			default = false,
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.block.custom end,
			setFunc = function(newValue) 
				AD_BLOCK_PLUS.savedVariables.block.custom = newValue
				AD_BLOCK_PLUS.block.custom = newValue
			end,
		}

	local advancedCustomEditbox =
		{
			type = "editbox",
			name = AD_BLOCK_PLUS.chatStringsCustom.custom.settings[AD_BLOCK_PLUS.language].tooltip,
			--tooltip = "",
			getFunc = function() return AD_BLOCK_PLUS.savedVariables.block.customWords end,
			setFunc = function(newValue)
				AD_BLOCK_PLUS.savedVariables.block.customWords = newValue
				AD_BLOCK_PLUS.block.customWords = newValue		
				AD_BLOCK_PLUS.chatStringsCustom.custom.primary = AD_BLOCK_PLUS.SetCustomWords(newValue, ";")
				AD_BLOCK_PLUS_ADVANCED_CUSTOM_EDITBOX.editbox:SetText(AD_BLOCK_PLUS.GetCustomWords(AD_BLOCK_PLUS.chatStringsCustom.custom.primary))
			end,
			isMultiline = false,	--boolean
			isExtraWide = true,
			width = "full",	--or "half" (optional)
			reference = "AD_BLOCK_PLUS_ADVANCED_CUSTOM_EDITBOX",
			--warning = "Will need to reload the UI.",	--(optional)
			default = "",	--(optional)
		}

	table.insert(optionsData,
		{
			type = "submenu",
			name = GetString(SI_AD_BLOCK_PLUS_HEADER_ADVANCED),
			controls = {advancedAgressiveCheckbox, advancedCustomCheckbox, advancedCustomEditbox},
		}
	)

	table.insert(optionsData,
		{
			type = "header",
			name = GetString(SI_AD_BLOCK_PLUS_HEADER_CHANNELS),
			width = "full"
		}
	)


	-- monitored chat channels (type)
	for chatType in AD_BLOCK_PLUS.sorted_table(AD_BLOCK_PLUS.chatType, true) do
		--local name = string.format("|c%s%s|r", AD_BLOCK_PLUS.chatColor[AD_BLOCK_PLUS.chatType[chatType].channel], AD_BLOCK_PLUS.chatType[chatType].settings[AD_BLOCK_PLUS.language].name)
		local name
		if chatType ~= "guilds" then
			name = string.format("|c%s%s|r", AD_BLOCK_PLUS.chatColor[AD_BLOCK_PLUS.chatType[chatType].channel], AD_BLOCK_PLUS.chatType[chatType].settings[AD_BLOCK_PLUS.language].name)
		else
			name = string.format("|c%s%s|r", AD_BLOCK_PLUS.chatColor[AD_BLOCK_PLUS.chatType[chatType].channel[1]], AD_BLOCK_PLUS.chatType[chatType].settings[AD_BLOCK_PLUS.language].name)
		end			
		table.insert(optionsData,
			{
				type = "checkbox",
				name = name,
				tooltip = AD_BLOCK_PLUS.chatType[chatType].settings[AD_BLOCK_PLUS.language].tooltip,
				default = false,
				getFunc = function() return AD_BLOCK_PLUS.savedVariables.block[chatType] end,
				setFunc = function(newValue) 
					AD_BLOCK_PLUS.savedVariables.block[chatType] = newValue
					AD_BLOCK_PLUS.block[chatType] = newValue
					if not resetOptions and AD_BLOCK_PLUS.preset ~= 5 then
						skipPreset = true
						AD_BLOCK_PLUS_DROPDOWN_PRESET.data.setFunc(5) --set to Custom
					end
				end,
				reference = "AD_BLOCK_PLUS_CHECKBOX_"..chatType,
			}
		)		
	end

	table.insert(optionsData,
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"			
		}
	)

	table.insert(optionsData,
		{
			type = "description",
			title = GetString(SI_AD_BLOCK_PLUS_BLOCKED_TOTAL),
			text = totalBlocked,
			width = "full",
		}
	)

	--AD_BLOCK_PLUS.controls.dropdownPreset:UpdateValue(false)

	LAM:RegisterAddonPanel("AD_BLOCK_PLUS_Settings", panelData)
	LAM:RegisterOptionControls("AD_BLOCK_PLUS_Settings", optionsData)

	skipPreset = false
end

--local name = string.format("%s %ss", GetString(SI_AD_BLOCK_PLUS_BLOCK), filterType:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end))
--AD_BLOCK_PLUS_CHECKBOX_achievement.data.setFunc(true)