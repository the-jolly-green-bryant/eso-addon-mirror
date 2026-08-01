AM0RAutoInv = {}
local autoinv = AM0RAutoInv

-- Written by M0R_Gaming

local vars = {}


autoinv.name = "AM0RAutoInv"
autoinv.varversion = 1

local DefaultSettings = {
	channels = {
		[CHAT_CHANNEL_WHISPER] = true,
		[CHAT_CHANNEL_ZONE] = true,
		[CHAT_CHANNEL_SAY] = true,
		[CHAT_CHANNEL_GUILD_1] = true,
		[CHAT_CHANNEL_GUILD_2] = true,
		[CHAT_CHANNEL_GUILD_3] = true,
		[CHAT_CHANNEL_GUILD_4] = true,
		[CHAT_CHANNEL_GUILD_5] = true,
	},
	message = "x"
}

local enabled = false


function autoinv.onMessage(_, channel, _, text, _, fromDisplayName)
	if (text == vars.message) and (vars.channels[channel] == true) then
		GroupInviteByName(fromDisplayName)
		d("Inviting "..fromDisplayName)
	end
end


function autoinv.start()
	enabled = true
	EVENT_MANAGER:RegisterForEvent(autoinv.name, EVENT_CHAT_MESSAGE_CHANNEL, autoinv.onMessage)
end

function autoinv.stop()
	enabled = false
	EVENT_MANAGER:UnregisterForEvent(autoinv.name, EVENT_CHAT_MESSAGE_CHANNEL, autoinv.onMessage)
end

function autoinv.toggle()
	if enabled then
		d("|cFFD700AM0RAutoInv|r: |cFFAAAAStopped|r automated invitations")
		autoinv.stop()
	else
		d("|cFFD700AM0RAutoInv|r: |cAAFFAAStarted|r automated invitations")
		autoinv.start()
	end
end

SLASH_COMMANDS['/autoinv'] = autoinv.toggle



local function createSettings()


	local panelName = "AM0RAutoInvSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700A M0R Automated Invite|r",
		author = "|c0DC1CF@M0R_Gaming|r",
	}

	local optionsTable = {
		{
			type = "submenu",
			name = "|cFFD700[Auto Invite Settings]|r",
			controls = {
				{
					type = "checkbox",
					name = "Enable",
					tooltip = "If this is enabled, then anyone who sends the message specified below will be invited to your group! You can also type /autoinv into your chat to toggle this!",
					getFunc = function() return enabled end,
					setFunc = function(value) 
						if value then
							d("|cFFD700AM0RAutoInv|r: |cAAFFAAStarted|r automated invitations")
							autoinv.start()
						else
							d("|cFFD700AM0RAutoInv|r: |cFFAAAAStopped|r automated invitations")
							autoinv.stop()
						end
						enabled = value
					end,
				},

	            {
	                type = "editbox",
	                name = "Message",
	                tooltip = "Configure your auto invite message in this text box!",
	                getFunc = function() return vars.message end,
	                setFunc = function(text) vars.message = text end,
	                isMultiline = false,
	                width = "half",
	            },

				{
			        type = "header",
			        name = "Enable/Disable Chat Channels",
			        width = "full",
			    },
				
				{
					type = "checkbox",
					name = "Whisper",
					tooltip = "If this is enabled, invites will be sent to anyone who whispers the message to you!",
					getFunc = function() return vars.channels.CHAT_CHANNEL_WHISPER end,
					setFunc = function(value) vars.channels.CHAT_CHANNEL_WHISPER = value end,
				},
				{
					type = "checkbox",
					name = "Zone Chat",
					tooltip = "If this is enabled, invites will be sent to anyone who sends the message in zone chat!",
					getFunc = function() return vars.channels.CHAT_CHANNEL_ZONE end,
					setFunc = function(value) vars.channels.CHAT_CHANNEL_ZONE = value end,
				},
				{
					type = "checkbox",
					name = "Say Chat",
					tooltip = "If this is enabled, invites will be sent to anyone who sends the message in say chat!",
					getFunc = function() return vars.channels.CHAT_CHANNEL_SAY end,
					setFunc = function(value) vars.channels.CHAT_CHANNEL_SAY = value end,
				},
				{
					type = "description",
					title = "",
					text = "The below toggles will only show guilds that you are in since logging in - if you just joined a guild (or left one) then press [Reload UI] below to update the menu!",
					width = "full",
				},
			}
		},

		{
			type = "description",
			title = "|cFFD700[A M0R Automated Invite]|r",
			text = "Hello, and thank you for using A M0R Automated Invite! "..
				"If you have any errors or complaints, please reach out to me either on discord (@m0r, its a zero not an o) or at the link below!",
			width = "full",
		},
		{
			type = "button",
			name = "Report Bug/Contact Me\n(QR Code)",
			tooltip = "Click this button to be directed to a QR Code which opens the esoui page for A M0R Auto Inv where you can reach out to me!",
			width = "full",
			func = function() RequestOpenUnsafeURL("https://m0rgaming.github.io/create-qr-code/?url=https://www.esoui.com/downloads/info4170-AMoreAutomatedInvite.html#comments") end,
		},
		{
			type = "button",
			name = "Report Bug/Contact Me\n(Direct Link)",
			tooltip = "Click this button to be directed to the esoui page for A M0R Auto Inv where you can reach out to me!",
			width = "full",
			func = function() RequestOpenUnsafeURL("https://www.esoui.com/downloads/info4170-AMoreAutomatedInvite.html#comments") end,
		},
		{
			type = "button",
			name = "Reload UI",
			tooltip = "Click here to reload your UI! (Will result in a load screen)",
			width = "full",
			func = function() ReloadUI() end,
		},
	}



	local guildChannels = {CHAT_CHANNEL_GUILD_1, CHAT_CHANNEL_GUILD_2, CHAT_CHANNEL_GUILD_3, CHAT_CHANNEL_GUILD_4, CHAT_CHANNEL_GUILD_5}
	for i=1,5 do
		local guildID = GetGuildId(i)
		local guildName = ""

		if guildID and guildID ~= 0 then
			guildName = GetGuildName(guildID)

			local toggleBox = {
				type = "checkbox",
				name = "Guild "..i..": "..guildName,
				tooltip = "If this is enabled, invites will be sent to anyone who sends the message in "..guildName.."! (Your Guild "..i.." Slot)",
				getFunc = function() return vars.channels[guildChannels[i]] end,
				setFunc = function(value) vars.channels[guildChannels[i]] = value end,
			}
			table.insert(optionsTable[1].controls, toggleBox)

		end
	end

	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end





-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function autoinv.OnAddOnLoaded(event, addonName)
	if addonName ~= autoinv.name then return end
	autoinv:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function autoinv:Initialize()
	-- Addon Settings Menu
	vars = ZO_SavedVars:NewAccountWide("AutoInv", autoinv.varversion, nil, DefaultSettings)
	createSettings()

	EVENT_MANAGER:UnregisterForEvent(autoinv.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(autoinv.name, EVENT_ADD_ON_LOADED, autoinv.OnAddOnLoaded)