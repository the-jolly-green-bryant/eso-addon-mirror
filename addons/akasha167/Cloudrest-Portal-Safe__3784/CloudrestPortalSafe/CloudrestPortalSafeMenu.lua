function CRPS.initializeSettingsMenu()
	local LAM2 = LibAddonMenu2
	local sv = CRPS.vars

	local panel = {
		type = "panel",
		name = "Cloudrest Portal Safe",
		displayName = "|c8F7FFFCloudrest|r Portal Safe",
		author = "akasha167",
		version = CRPS.version,
		registerForRefresh = true,
	}

	local options = {
		{
			type = "divider",
		},
		{
			type = "button",
			name = GetString(CRPS_LABEL_UNLOCK),
			tooltip = GetString(CRPS_TOOLTIP_UNLOCK),
			func = function(value)
				CRPS.toggleMovable()
				if not CRPS.isMovable then
					value:SetText("Unlock alert")
				else
					value:SetText("Lock alert")
				end
			end,
			width = "half",
		},
		{
			type = "button",
			name = GetString(CRPS_LABEL_RESET),
			tooltip = GetString(CRPS_TOOLTIP_RESET),
			func = function(value) CRPS.resetParams() end,
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(CRPS_LABEL_DEBUG),
			tooltip = GetString(CRPS_TOOLTIP_DEBUG),
			getFunc = function() return sv.debugEnabled end,
			setFunc = function(value) sv.debugEnabled = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(CRPS_LABEL_ALERTSELF),
			tooltip = GetString(CRPS_TOOLTIP_ALERTSELF),
			getFunc = function() return sv.alertMyself end,
			setFunc = function(value) sv.alertMyself = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(CRPS_LABEL_SPEARSDONE),
			tooltip = GetString(CRPS_TOOLTIP_SPEARSDONE),
			getFunc = function() return sv.showSpearsDone end,
			setFunc = function(value) sv.showSpearsDone = value end,
			width = "full"
		},
		{
			type = "slider",
			name = GetString(CRPS_LABEL_DURATION),
			tooltip = GetString(CRPS_TOOLTIP_DURATION),
			getFunc = function() return sv.alertDuration end,
			setFunc = function(value) sv.alertDuration = value end,
			min = 2,
			max = 10,
			step = 1,
			default = 2,
			width = "full",
		},
		{
			type = "slider",
			name = GetString(CRPS_LABEL_FONTSIZE),
			tooltip = GetString(CRPS_TOOLTIP_FONTSIZE),
			getFunc = function() return sv.alertFontSize end,
			setFunc = function(value)
				sv.alertFontSize = value
				CRPS.setFont(sv.alertFontSize, sv.alertFontColor)
			end,
			min = 32,
			max = 64,
			step = 2,
			default = 48,
			width = "full",
		},
		{
			type = "colorpicker",
			name = GetString(CRPS_LABEL_TEXTCOLOR),
			tooltip = GetString(CRPS_TOOLTIP_TEXTCOLOR),
			getFunc = function() return unpack(sv.alertFontColor) end,
			setFunc = function(r, g, b, a)
				sv.alertFontColor = {r, g, b, a}
				CRPS.setFont(sv.alertFontSize, sv.alertFontColor)
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(CRPS_LABEL_ENABLESOUND),
			tooltip = GetString(CRPS_TOOLTIP_ENABLESOUND),
			getFunc = function() return sv.soundEnabled end,
			setFunc = function(value) sv.soundEnabled = value end,
			width = "full"
		},
		{
			type = "slider",
			name = GetString(CRPS_LABEL_SOUNDVOLUME),
			tooltip = GetString(CRPS_TOOLTIP_SOUNDVOLUME),
			getFunc = function() return sv.soundVolume end,
			setFunc = function(value) sv.soundVolume = value end,
			min = 1,
			max = 15,
			step = 1,
			default = 1,
			width = "full",
			disabled = function() return not sv.soundEnabled end
		},
		{
			type = "divider",
		},
		{
			type = "button",
			name = GetString(CRPS_LABEL_TEST),
			tooltip = GetString(CRPS_TOOLTIP_TEST),
			func = function(value) CRPS.sendAlert(string.format(GetString(CRPS_ALERT_SAFE), GetString(CRPS_MSG_TANKINPORTAL))) end,
			width = "full",
		},
	}
	local settings = LAM2:RegisterAddonPanel(CRPS.name .. "Settings", panel)
	LAM2:RegisterOptionControls(CRPS.name .. "Settings", options)
	CRPS.OpenSettingsPanel = function() LAM2:OpenToPanel(settings) end
end