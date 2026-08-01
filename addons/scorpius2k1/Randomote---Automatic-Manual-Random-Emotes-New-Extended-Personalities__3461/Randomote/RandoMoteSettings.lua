local LAM 			= LibAddonMenu2
local skipPreset	= true
local resetOptions 	= false

-------------------------
-- Settings Window
-------------------------
function RANDOMOTE.CreateSettingsWindow()

	local function updateLAMSlider(control, forceDefault, value)
		if control == nil then return end
		control:UpdateValue(forceDefault, value)
	end

	local panelData = {
		type = "panel",
		name = "RandoMote",
		displayName = "Scorps RandoMote",
		author = "Scorp",
		version = RANDOMOTE.version,
		slashCommand = RANDOMOTE.slashCommand.settings,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3461",
	}

	local advancedData = {}
	for k, v in ipairs(RANDOMOTE.emoteData) do
		if v ~= nil then
			table.insert(advancedData,
				{
					type = "checkbox",
					name = "|cb7ff00"..RANDOMOTE.emoteData[k].display.."|r |cffffff"..RANDOMOTE.emoteData[k].slash.."|r",
					--tooltip = GetString()
					default = true,
					getFunc = function() return RANDOMOTE.savedVariables.useEmote[RANDOMOTE.emoteData[k].slash:sub(2)] end,
					setFunc = function(newValue)
						RANDOMOTE.useEmote[RANDOMOTE.emoteData[k].slash:sub(2)] = newValue
						RANDOMOTE.savedVariables.useEmote[RANDOMOTE.emoteData[k].slash:sub(2)] = newValue
					end,
				}
			)
		end
	end

	local optionsData = {		
		{
			type = "texture",
			image = "RandoMote\\textures\\RandoMoteLogo.dds",
			imageWidth = 510,	--max of 250 for half width, 510 for full
			imageHeight = 100,	--max of 100
			--tooltip = "",	--(optional)
			width = "full",	--or "half" (optional)
		},
		--[[
		{
			type = "description",
			--title = GetString(SI_RANDOMOTE_DESCRIPTION_SLASH),
			--text = "|cb7ff00"..RANDOMOTE.slashCommand.emote.."|r "..GetString(SI_RANDOMOTE_DESCRIPTION_EMOTE).."\n|cb7ff00"..RANDOMOTE.slashCommand.settings.."|r "..GetString(SI_RANDOMOTE_DESCRIPTION_SETTINGS).."\n|c"..RANDOMOTE.ConvertChannelRGBToHex(CHAT_CATEGORY_EMOTE)..RANDOMOTE.GetTotalEmotes().." Emotes Total|r",
			text = "|c"..RANDOMOTE.ConvertChannelRGBToHex(CHAT_CATEGORY_EMOTE)..RANDOMOTE.GetTotalEmotes().." Emotes Total|r",
			width = "full",
		},
		]]
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"			
		},		
		{
			type = "checkbox",
			name = GetString(SI_RANDOMOTE_ENABLE),
			tooltip = GetString(SI_RANDOMOTE_ENABLE_TT),
			default = true,
			getFunc = function() return RANDOMOTE.savedVariables.enable end,
			setFunc = function(newValue) 
				RANDOMOTE.enable = newValue
				RANDOMOTE.savedVariables.enable = newValue
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_RANDOMOTE_STANDARD),
			tooltip = GetString(SI_RANDOMOTE_STANDARD_TT),
			default = true,
			getFunc = function() return RANDOMOTE.savedVariables.useStandard end,
			setFunc = function(newValue) 
				RANDOMOTE.useStandard = newValue
				RANDOMOTE.savedVariables.useStandard = newValue
				--RANDOMOTE.InitializeEmoteData()
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_RANDOMOTE_COLLECTIBLE),
			tooltip = GetString(SI_RANDOMOTE_COLLECTIBLE_TT),
			default = true,
			getFunc = function() return RANDOMOTE.savedVariables.useCollectible end,
			setFunc = function(newValue) 
				RANDOMOTE.useCollectible = newValue
				RANDOMOTE.savedVariables.useCollectible = newValue
				--RANDOMOTE.InitializeEmoteData()
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_RANDOMOTE_CHAT_OUTPUT),
			tooltip = GetString(SI_RANDOMOTE_CHAT_OUTPUT_TT),
			default = false,
			getFunc = function() return RANDOMOTE.savedVariables.chatOutput end,
			setFunc = function(newValue) 
				RANDOMOTE.chatOutput = newValue
				RANDOMOTE.savedVariables.chatOutput = newValue
				RANDOMOTE.ResetData()
			end,
		},						
		{
			type = "slider",
			name = GetString(SI_RANDOMOTE_DELAY_IDLE),
			tooltip = GetString(SI_RANDOMOTE_DELAY_IDLE_TT),
			min = 5,
			max = 120,
			step = 5,
			default = RANDOMOTE.defaults.idleMax,
			getFunc = function() return RANDOMOTE.savedVariables.idleMax end,
			setFunc = function(newValue) 
				RANDOMOTE.idleMax = newValue
				RANDOMOTE.savedVariables.idleMax = newValue
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_RANDOMOTE_DELAY_MIN),
			tooltip = GetString(SI_RANDOMOTE_DELAY_MIN_TT),
			min = 5,
			max = 300,
			step = 5,
			default = RANDOMOTE.defaults.minTime,
			getFunc = function() return RANDOMOTE.savedVariables.minTime end,
			reference = "RANDOMOTE_OPTION_MINTIME",
			setFunc = function(newValue)
				RANDOMOTE.minTime = newValue
				RANDOMOTE.savedVariables.minTime = newValue
				if newValue > RANDOMOTE.maxTime then updateLAMSlider(RANDOMOTE_OPTION_MAXTIME, false, newValue) end
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "slider",
			name = GetString(SI_RANDOMOTE_DELAY_MAX),
			tooltip = GetString(SI_RANDOMOTE_DELAY_MAX_TT),
			min = 5,
			max = 300,
			step = 5,
			default = RANDOMOTE.defaults.maxTime,
			getFunc = function() return RANDOMOTE.savedVariables.maxTime end,
			reference = "RANDOMOTE_OPTION_MAXTIME",
			setFunc = function(newValue)				
				RANDOMOTE.maxTime = newValue
				RANDOMOTE.savedVariables.maxTime = newValue
				if newValue < RANDOMOTE.minTime then updateLAMSlider(RANDOMOTE_OPTION_MINTIME, false, newValue) end
				RANDOMOTE.ResetData()
			end,
		},
		{
			type = "submenu",
			name = GetString(SI_RANDOMOTE_EMOTE_LIST).." ("..RANDOMOTE.GetTotalEmotes()..")",
			controls = advancedData,
		},
		{
			type = "divider",
			height = 15,
			alpha = 1.0,
			width = "full"			
		},
		{
			type = "button",
			name = GetString(SI_RANDOMOTE_FEEDBACK),
			func = function() MAIN_MENU_KEYBOARD:ShowScene("mailSend") MAIL_SEND:SetReply("@scorpius2k1", RANDOMOTE.name) end,
			tooltip = GetString(SI_RANDOMOTE_FEEDBACK_TT),
		},			
	}

	LAM:RegisterAddonPanel("RANDOMOTE_Settings", panelData)
	LAM:RegisterOptionControls("RANDOMOTE_Settings", optionsData)

end

--local name = string.format("%s %ss", GetString(SI_RANDOMOTE_BLOCK), filterType:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end))
--RANDOMOTE_CHECKBOX_achievement.data.setFunc(true)