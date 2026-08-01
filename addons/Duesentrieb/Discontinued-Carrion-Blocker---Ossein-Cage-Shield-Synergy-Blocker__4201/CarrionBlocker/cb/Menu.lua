local CB = CarrionBlocker
local LAM2 = LibAddonMenu2
local display = GetControl("CarrionBlockerDisplay")
local displayLabel = GetControl("CarrionBlockerDisplayLabel")

function CB.createSettingsWindow()
	local panelData = {
		type = "panel",
		name = "[CB] Carrion Blocker",
		displayName = "|cff7f00[CB] Carrion|r |cffffffBlocker|r",
		author = "|cff7f00" .. CB.author .. "|r |cffffff[EU]|r",
		version = "|cff7f00" .. CB.version .. "|r",
		registerForRefresh = true
	}
	local optionsData = {
		{
			type = "header",
			name = "|cff7f00General Options|r"
		},
		{
			type = 	"description",
			text = "Tracks |cff7f00Caustic Carrion|r stacks in Ossein Cage, blocking the Carrion Shield synergy until a user-defined threshold is met.\n" ..
					"Default threshold for Jynorah and Skorkhif Hardmode: [4]",
			width = "full"
		},
		{
			type = "checkbox",
			name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
			tooltip = "Enables or disables all features of the addon. If disabled, no synergies will be blocked.",
			getFunc = function() return CB.sVar.isEnabled end,
			setFunc = function(value)
				CB.sVar.isEnabled = value
				if value == true then
					CB.Enable()
				else
					CB.isForceShow = false
					CB.hideNotification()
					CB.Disable()
				end
			end,
			width = "full"
		},
		{
			type = "slider",
			name = "Caustic Carrion Stack Threshold",
			tooltip = "Sets the caustic carrion stack threshold. The synergy remains blocked until this value is met or exceeded.",
			min = 1,
			max = 5,
			step = 1,
			default = 4,
			getFunc = function() return CB.sVar.threshold end,
			setFunc = function(value) CB.sVar.threshold = value end,
			disabled = function() return not CB.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "header",
			name = "|cff7f00Display Options|r"
		},
		{
			type = "button",
			name = "Show Notification",
			tooltip = "Forces the Notification ON/OFF.",
			func = function(value)
				CB.isForceShow = not CB.isForceShow
				if CB.isForceShow then
					value:SetText("Hide Notification")
					CB.showNotification(CB.colorHex, 5000, "MOVE TEXT - THEN HIDE IN MENU")
				else
					value:SetText("Show Notification")
					CB.hideNotification()
				end
			end,
			width = "half"
		},
		{
			type = "button",
			name = "Center Horizontally",
			tooltip = "Resets the UI element's position to the horizontal center of the screen.",
			func = function() 
				CB.centerHorizontally()
			end,
			width = "half"
		},
		{
			type = "checkbox",
			name = "Enable Chat Notifications",
			tooltip = "Notifies you in the chat as your caustic carrion stacks build up. The message is color-coded for urgency.",
			getFunc = function() return CB.sVar.isEnabledChat end,
			setFunc = function(value) CB.sVar.isEnabledChat = value end,
			disabled = function() return not CB.sVar.isEnabled end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Snap Screen Notification Text To Grid",
			tooltip = "Screen notification text will snap to the vertical or horizontal center, if close to it.",
			getFunc = function() return CB.sVar.isSnapToGrid end,
			setFunc = function(value)
				CB.sVar.isSnapToGrid = value
			end,
			width = "full"
		},
		{
			type = "slider",
			name = "Font Size",
			getFunc = function() return CB.sVar.fontSize end,
			setFunc = function(value)
				CB.sVar.fontSize = value
				CB.setFontSize(display, displayLabel, value)
			end,
			min = 24,
			max = 128,
			step = 1,
			default = 48,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Show Sceen Border Color",
			tooltip = "Enables screen border color. The border is color-coded for urgency.",
			getFunc = function() return CB.sVar.isShowBorderColor end,
			setFunc = function(value)
				CB.sVar.isShowBorderColor = value
				if CB.isForceShow then
					CB.hideNotification()
					CB.showNotification(CB.colorHex100, 5000, "MOVE TEXT - THEN HIDE IN MENU")
				end
			end,
			width = "full"
		},
		{
			type = "divider"
		},
		{
			type = "description",
			text = "If you enjoy |cff7f00Carrion Blocker|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
			width = "full"
		},
		{
			type = "button",
			name = "Feedback / Donate",
			tooltip = "Opens a mail to send feedback or donate to the author. <3",
			func = function()
				SCENE_MANAGER:Show('mailSend')
				zo_callLater(function()
					ZO_MailSendToField:SetText(CB.author)
					ZO_MailSendSubjectField:SetText("Carrion Blocker")
					ZO_MailSendBodyField:TakeFocus()
				end, 250)
			end,
			width = "full"
		}
	}
	CB.varAddonPanel = LAM2:RegisterAddonPanel(CarrionBlocker.name .. "Menu", panelData)
	LAM2:RegisterOptionControls(CarrionBlocker.name .. "Menu", optionsData)
end