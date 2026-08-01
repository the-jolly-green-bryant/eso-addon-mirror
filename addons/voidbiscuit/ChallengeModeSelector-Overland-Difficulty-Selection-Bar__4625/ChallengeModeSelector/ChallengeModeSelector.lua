-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Addon info
CMS.Name = "ChallengeModeSelector"
CMS.DisplayName = "Challenge Mode Selector"
CMS.Author = "|cFFA500voidbiscuit|r"
CMS.Version = "1.0.1"

-- Values
do
	CMS.Values = {
		control_width = 245,
		control_height = 70,
		icon_size = 32,
		icon_spacing = 6,
		selected_icon_size = 42,
		selected_icon_alpha = 0.45,
		selected_pip_size = 12,
		unselected_alpha = 0.65,
		icon_row_offset_x = -18,
		icon_row_offset_y = -2,
		mode_gap = 25,
		dungeon_mode_offset_x = -135,
		label_text = "Challenge Mode:",
		colors = {
			text = ZO_ColorDef:New(0.86, 0.82, 0.62, 1),
			disabled = ZO_ColorDef:New(0.45, 0.45, 0.45, 1),
			help = ZO_ColorDef:New(0.95, 0.72, 0.22, 1),
			help_hover = ZO_ColorDef:New(1, 0.9, 0.35, 1),
		},
	}
end

-- Main
do
	function CMS.Message(message, is_error)
		local message_color = is_error and "|cFF0000" or "|cFFA500"
		d(string.format("|c33658A[%s]|r %s%s|r", CMS.DisplayName, message_color, tostring(message)))
	end
end

-- Addon Initialize
do
	function CMS.Initialize()
		CMS.GroupMenu.CreateControl()
		CMS.SidePanel.HookStatsChallengePanel()
		CMS.EventManager.RegisterEvents()
		CMS.GroupMenu.Refresh()
	end

	function CMS.OnAddOnLoaded(event, addon_name)
		if addon_name ~= CMS.Name then
			return
		end
		EVENT_MANAGER:UnregisterForEvent(CMS.Name, EVENT_ADD_ON_LOADED)
		CMS.Initialize()
	end

	EVENT_MANAGER:RegisterForEvent(CMS.Name, EVENT_ADD_ON_LOADED, CMS.OnAddOnLoaded)
end
