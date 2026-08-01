local SU = StaggerUptime
local LAM2 = LibAddonMenu2
local display = GetControl("StaggerUptimeDisplay")
local displayLabel = GetControl("StaggerUptimeDisplayLabel")
local displayBackdrop = GetControl("StaggerUptimeDisplayBackdrop")

function SU.createSettingsWindow()
	local panelData = {
		type = "panel",
		name = "[SU] Stagger Uptime",
		displayName = "|cff7f00[SU] Stagger|r |cffffffUptime|r",
		author = "|cff7f00" .. SU.author .. "|r |cffffff[EU]|r",
		version = "|cff7f00" .. SU.version .. "|r",
		registerForRefresh = true
	}
	local optionsData = {
		{
			type = "header",
			name = "|cff7f00General Options|r"
		},
		{
			type = 	"description",
			text = "Tracks |cff7f00Stagger Uptime|r and displays it on screen: |c7fff00↑[3] 89.2%|r\n" ..
					"Uptime and color depend on a 3-stack Stagger.",
			width = "full"
		},
		{
			type = "checkbox",
			name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
			tooltip = "Enables or disables all features of the addon.",
			getFunc = function() return SU.sVar.isEnabled end,
			setFunc = function(value)
				SU.sVar.isEnabled = value
				if value == true then
					SU.Enable()
				else
					SU.Disable()
				end
			end,
			width = "full"
		},
		{
			type = "header",
			name = "|cff7f00Display Options|r"
		},
		{
			type = "button",
			name = "Show Notification",
			tooltip = "Forces the Notification ON/OFF. Even when skill is not equipped.",
			func = function(value)
				SU.isForceShow = not SU.isForceShow
				if SU.isForceShow then
					value:SetText("Hide Notification")
					displayBackdrop:SetHidden(false)
					SU.showNotification()
					SU.updateDisplay()
				else
					value:SetText("Show Notification")
					displayBackdrop:SetHidden(true)
					SU.updateDisplay()
				end
			end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "half"
		},
		{
			type = "button",
			name = "Center Text",
			tooltip = "Resets the UI element's position to the center of the screen.",
			func = function()
				SU.setDefaultPosition()
				SU.updateDisplay()
			end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "half"
		},
		{
			type = "checkbox",
			name = "Show Out Of Combat",
			tooltip = "Always show the display text. Even when you are not in combat.",
			getFunc = function() return not SU.sVar.isOnlyCombat end,
			setFunc = function(value)
				SU.sVar.isOnlyCombat = not value
				SU.updateDisplay()
			end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Only Track Stagger Applied By You",
			tooltip = "If deactivated, stagger stacks applied by group members will be also tracked.",
			getFunc = function() return SU.sVar.isOnlyTrackPlayer end,
			setFunc = function(value)
				SU.sVar.isOnlyTrackPlayer = value
				SU.updateDisplay()
			end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Enable Chat Notifications",
			tooltip = "Summarizes stagger statistics in the chat after combat ends.",
			getFunc = function() return SU.sVar.isEnabledChat end,
			setFunc = function(value) SU.sVar.isEnabledChat = value end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "slider",
			name = "Minimum Fight Time For Chat Notifications",
			tooltip = "Sets the minimum duration a fight must last (in seconds) for stagger statistics to be reported in chat. Fights shorter than this will not be reported.",
			min = 0,
			max = 120,
			step = 5,
			default = 0,
			getFunc = function() return SU.sVar.minFightTime end,
			setFunc = function(value) SU.sVar.minFightTime = value end,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "slider",
			name = "Display Font Size",
			getFunc = function() return SU.sVar.fontSize end,
			setFunc = function(value)
				SU.sVar.fontSize = value
				SU.setFontSize(display, displayLabel, value)
				SU.updateDisplay()
			end,
			min = 12,
			max = 64,
			step = 2,
			default = 48,
			disabled = function() return not SU.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "divider"
		},
		{
			type = "description",
			text = "If you enjoy |cff7f00Stagger Uptime|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
			width = "full"
		},
		{
			type = "button",
			name = "Feedback / Donate",
			tooltip = "Opens a mail to send feedback or donate to the author. <3",
			func = function()
				SCENE_MANAGER:Show('mailSend')
				zo_callLater(function()
					ZO_MailSendToField:SetText(SU.author)
					ZO_MailSendSubjectField:SetText("Stagger Uptime")
					ZO_MailSendBodyField:TakeFocus()
				end, 250)
			end,
			width = "full"
		}
	}
	SU.varAddonPanel = LAM2:RegisterAddonPanel(StaggerUptime.name .. "Menu", panelData)
	LAM2:RegisterOptionControls(StaggerUptime.name .. "Menu", optionsData)
end