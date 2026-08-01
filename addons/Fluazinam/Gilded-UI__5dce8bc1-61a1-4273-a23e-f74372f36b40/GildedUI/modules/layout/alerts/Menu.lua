if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildAlertTextMenu(H)
	local sv = self.state.sv
	local limits = self.limits
	local controls = {
		H.Slider(
			"Position X",
			limits.alertTextOffsetX.min,
			limits.alertTextOffsetX.max,
			5,
			function() return sv.alertTextOffsetX end,
			function(v)
				sv.alertTextOffsetX = v
				Addon:ApplyAlertText()
			end,
			Addon.defaults.alertTextOffsetX
		),
		H.Slider(
			"Position Y",
			limits.alertTextOffsetY.min,
			limits.alertTextOffsetY.max,
			5,
			function() return sv.alertTextOffsetY end,
			function(v)
				sv.alertTextOffsetY = v
				Addon:ApplyAlertText()
			end,
			Addon.defaults.alertTextOffsetY
		),
		{
			type = "selector",
			name = "Alignment",
			choices = { "Left", "Center", "Right" },
			choicesValues = { "left", "center", "right" },
			getFunc = function() return sv.alertTextAlign end,
			setFunc = function(value)
				sv.alertTextAlign = value
				Addon:ApplyAlertText()
			end,
			default = Addon.defaults.alertTextAlign,
		},
		H.Toggle(
			"Show layout preview",
			function() return sv.alertTextShowPreview end,
			function(v)
				sv.alertTextShowPreview = v
				Addon:UpdateAlertTextPreview()
			end,
			Addon.defaults.alertTextShowPreview
		),
	}

	return {
		type = "submenu",
		name = "Alert Text",
		tooltip = "Moves the top-right notification alerts (group errors, busy, etc.). Width still follows the compass gutter.",
		controls = controls,
	}
end
