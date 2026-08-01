local A = SafeChat
local LAM = LibAddonMenu2

local function Donate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function() 
		ZO_MailSendToField:SetText("@andy.s")
		ZO_MailSendSubjectField:SetText("SafeChat")
		ZO_MailSendBodyField:SetText("Thanks for it!")
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end

function A.BuildMenu(SV, defaults)

	local panel = {
		type = 'panel',
		name = A.GetName(),
		displayName = A.GetName(),
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', A.GetVersion()),
		donation = Donate,
		registerForRefresh = true,
	}

	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", A.UpdateHUD)

	local function CreateKeywordChannelSettings(channel, command)
		return {
			type = "checkbox",
			name = command,
			tooltip = string.format("Use custom keyword for %s channel.", command),
			default = defaults.customKeywordChannels[channel],
			getFunc = function() return SV.customKeywordChannels[channel] end,
			setFunc = function(value)
				SV.customKeywordChannels[channel] = value
			end,
		}
	end

	local options = {
		{
			type = "header",
			name = "|cFFFACDGeneral|r",
		},
		{
			reference = "SafeChatMenu_Enabled",
			type = "checkbox",
			name = function()
				return string.format(A.IsEnabled() and "|c00FF00%s|r" or "|cFF0000%s|r", "Enabled")
			end,
			tooltip = "When enabled, your chat messages will be encoded depending on the settings below. Other players will need to install SafeChat to be able to understand you.\n\nNOTE: it's not safe to share confidential data. The main goal of encoding is to prevent your messages from being flagged by automatic systems.",
			default = defaults.enabled,
			getFunc = function() return A.IsEnabled() end,
			setFunc = function(value)
				A.SetEnabled(value)
				SafeChatMenu_Enabled.label:SetText(string.format(A.IsEnabled() and "|c00FF00%s|r" or "|cFF0000%s|r", "Enabled"))
			end,
		},
		{
			type = "checkbox",
			name = "Encode all channels",
			tooltip = "When enabled, your messages will be encoded in every channel (/zone, /group, /say, etc.). When disabled, you can configure channels individually by clicking on the addon icon below chat input.",
			default = defaults.enabledEverywhere,
			getFunc = function() return SV.enabledEverywhere end,
			setFunc = function(value)
				SV.enabledEverywhere = value
			end,
		},
		{
			type = "header",
			name = "|cFFFACDCustom Keyword|r",
		},
		{
			type = "checkbox",
			name = "Use Custom Keyword",
			tooltip = "Only players with the same keyword will understand you.",
			default = defaults.useCustomKeyword,
			getFunc = function() return SV.useCustomKeyword end,
			setFunc = function(value)
				SV.useCustomKeyword = value
			end,
		},
		{
			type = "editbox",
			name = "Custom Keyword",
			tooltip = "Currently only A-Za-z0-9 letters are supported. For better encoding use a combination of them.",
            default = defaults.customKeyword,
			getFunc = function() return SV.customKeyword end,
			setFunc = function(value)
				SV.customKeyword = value or ""
			end,
			isMultiline = false,
			isExtraWide = false,
		},
		CreateKeywordChannelSettings(CHAT_CHANNEL_SAY,		'/say'),
		CreateKeywordChannelSettings(CHAT_CHANNEL_YELL,		'/yell'),
		CreateKeywordChannelSettings(CHAT_CHANNEL_EMOTE,	'/emote'),
		CreateKeywordChannelSettings(CHAT_CHANNEL_PARTY,	'/group'),
	}

	local name = A.GetName() .. 'Menu'
	A.lamPanel = LAM:RegisterAddonPanel(name, panel)
	LAM:RegisterOptionControls(name, options)
end