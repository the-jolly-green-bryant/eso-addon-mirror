-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Modules
CMS.GroupMenu = CMS.GroupMenu or {}
local GroupMenu = CMS.GroupMenu
local Difficulty = CMS.Difficulty
local SidePanel = CMS.SidePanel
local Values = CMS.Values
local WM = WINDOW_MANAGER

-- State
GroupMenu.control = nil
GroupMenu.buttons = {}
GroupMenu.pending_difficulty = nil

-- Local helpers
local function button_texture_helper(button, texture_format)
	button:SetNormalTexture(string.format(texture_format, "up"))
	button:SetPressedTexture(string.format(texture_format, "down"))
	button:SetMouseOverTexture(string.format(texture_format, "over"))
	button:SetPressedMouseOverTexture(string.format(texture_format, "down_over"))
	button:SetDisabledTexture(string.format(texture_format, "disabled"))
	button:SetDisabledPressedTexture(string.format(texture_format, "down_disabled"))
end

local function determine_button_state(pressed, enabled)
	return enabled and (pressed and BSTATE_PRESSED or BSTATE_NORMAL)
		or (pressed and BSTATE_DISABLED_PRESSED or BSTATE_DISABLED)
end

local function make_label(parent, font, color)
	local label = WM:CreateControl(nil, parent, CT_LABEL)
	label:SetFont(font)
	label:SetColor(color:UnpackRGBA())
	return label
end

local function get_icon_row_width(difficulties)
	local icon_size = Values.icon_size
	local icon_spacing = Values.icon_spacing
	local difficulty_count = #difficulties
	return (icon_size * difficulty_count) + (icon_spacing * (difficulty_count - 1))
end

-- Main
do
	function GroupMenu.SelectDifficulty(difficulty)
		-- If difficulty isn't enabled, don't allow change
		if not Difficulty.IsOverlandDifficultyEnabled() then
			return
		end
		-- If no difficulty change, break
		if difficulty.id == Difficulty.GetOverlandDifficultyId() then
			return
		end
		-- Request the change
		GroupMenu.pending_difficulty = difficulty
		RequestChangePlayerOverlandDifficulty(difficulty.id)
		-- Call to reset pending difficulty if the change fails
		zo_callLater(function()
			if GroupMenu.pending_difficulty == difficulty then
				GroupMenu.pending_difficulty = nil
			end
		end, 5000)
		-- Done
	end

	function GroupMenu.ShowDifficultyTooltip(button)
		InitializeTooltip(InformationTooltip, button, BOTTOM, 0, 0)
		InformationTooltip:AddLine(button.difficulty.name, "ZoFontGameMedium")
		if not Difficulty.IsOverlandDifficultyEnabled() then
			local disabled_text = Difficulty.GetOverlandDifficultyDisabledReason()
			InformationTooltip:AddLine(disabled_text, "ZoFontGameMedium", ZO_ERROR_COLOR:UnpackRGB())
		end
	end

	function GroupMenu.ShowHelpTooltip(control)
		InitializeTooltip(InformationTooltip, control, RIGHT, -5, 0)
		InformationTooltip:AddLine(GetString(SI_CHALLENGE_DIFFICULTY_TITLE), "ZoFontGameMedium")
		InformationTooltip:AddLine("Click to open the full Challenge Difficulty menu.", "ZoFontGame")
	end

	function GroupMenu.AnchorDungeonMode(dungeon_mode)
		-- Move dungeon mode to the left a bit
		dungeon_mode:ClearAnchors()
		dungeon_mode:SetAnchor(BOTTOM, ZO_GroupList, TOP, Values.dungeon_mode_offset_x, -10)
	end

	function GroupMenu.CreateDifficultyButton(parent, difficulty, previous_button)
		-- Button
		local button = WM:CreateControl(string.format("%sButton%d", CMS.Name, difficulty.id), parent, CT_BUTTON)
		do
			button:SetDimensions(Values.icon_size, Values.icon_size)
			button_texture_helper(button, difficulty.texture_format)
			button:SetMouseEnabled(true)
			button.difficulty = difficulty
		end
		-- Selected glow
		button.selected_glow = WM:CreateControl(nil, button, CT_TEXTURE)
		do
			button.selected_glow:SetTexture(string.format(difficulty.texture_format, "over"))
			button.selected_glow:SetDimensions(Values.selected_icon_size, Values.selected_icon_size)
			button.selected_glow:SetAnchor(CENTER, button, CENTER)
			button.selected_glow:SetDrawLayer(DL_OVERLAY)
			button.selected_glow:SetBlendMode(TEX_BLEND_MODE_ADD)
			button.selected_glow:SetAlpha(Values.selected_icon_alpha)
			button.selected_glow:SetHidden(true)
		end
		-- Selected pip
		button.selected_pip = WM:CreateControl(nil, button, CT_TEXTURE)
		do
			button.selected_pip:SetTexture("EsoUI/Art/Miscellaneous/selectedPip.dds")
			button.selected_pip:SetDimensions(Values.selected_pip_size, Values.selected_pip_size)
			button.selected_pip:SetAnchor(TOP, button, BOTTOM, 0, -7)
			button.selected_pip:SetDrawLayer(DL_OVERLAY)
			button.selected_pip:SetHidden(true)
		end
		-- Relative anchors
		do
			if previous_button then
				button:SetAnchor(LEFT, previous_button, RIGHT, Values.icon_spacing, 0)
			else
				button:SetAnchor(LEFT)
			end
		end
		-- Handlers
		do
			button:SetHandler("OnMouseEnter", GroupMenu.ShowDifficultyTooltip)
			button:SetHandler("OnMouseExit", function()
				ClearTooltip(InformationTooltip)
			end)
			button:SetHandler("OnClicked", function(control)
				GroupMenu.SelectDifficulty(control.difficulty)
			end)
		end
		-- Done
		table.insert(GroupMenu.buttons, button)
		return button
	end

	function GroupMenu.CreateControl()
		-- Init
		local difficulties = Difficulty.difficulties
		local colors = CMS.Values.colors
		-- Check already exist
		if GroupMenu.control then
			return
		end
		-- Shuffle the vet mode switcher to the left, and anchor overland switcher to the right
		local dungeon_mode = ZO_GroupList:GetNamedChild("VeteranDifficultySettings")
		GroupMenu.AnchorDungeonMode(dungeon_mode)
		-- Control
		local control = WM:CreateControl(string.format("%sSettings", CMS.Name), ZO_GroupList, CT_CONTROL)
		do
			control:SetDimensions(Values.control_width, Values.control_height)
			control:SetAnchor(TOPLEFT, dungeon_mode, TOPRIGHT, Values.mode_gap, 0)
			control:SetHidden(false)
		end
		-- Help
		control.help = WM:CreateControl(nil, control, CT_TEXTURE)
		do
			control.help:SetTexture("EsoUI/Art/Miscellaneous/help_icon.dds")
			control.help:SetDimensions(Values.icon_size, Values.icon_size)
			control.help:SetAnchor(TOPLEFT)
			control.help:SetMouseEnabled(true)
			control.help:SetDrawLayer(DL_OVERLAY)
			control.help:SetColor(colors.help:UnpackRGBA())
		end
		--Handlers
		do
			control.help:SetHandler("OnMouseEnter", function(help_control)
				help_control:SetColor(colors.help_hover:UnpackRGBA())
				GroupMenu.ShowHelpTooltip(help_control)
			end)
			control.help:SetHandler("OnMouseExit", function(help_control)
				help_control:SetColor(colors.help:UnpackRGBA())
				ClearTooltip(InformationTooltip)
			end)
			control.help:SetHandler("OnMouseUp", function(_, mouse_button, up_inside)
				if mouse_button == MOUSE_BUTTON_INDEX_LEFT and up_inside then
					SidePanel.Toggle()
				end
			end)
		end
		-- Label
		do
			control.label = make_label(control, "ZoFontGameLargeBold", colors.text)
			control.label:SetText(Values.label_text)
			control.label:SetAnchor(LEFT, control.help, RIGHT, 5, 0)
		end
		-- Selector
		do
			control.icon_row = WM:CreateControl(nil, control, CT_CONTROL)
			control.icon_row:SetDimensions(get_icon_row_width(difficulties), Values.icon_size)
			control.icon_row:SetAnchor(TOP, control.label, BOTTOM, Values.icon_row_offset_x, Values.icon_row_offset_y)
		end
		-- Create and anchor the buttons
		local previous_button = nil
		for _, difficulty in ipairs(difficulties) do
			previous_button = GroupMenu.CreateDifficultyButton(control.icon_row, difficulty, previous_button)
		end
		-- Done
		GroupMenu.control = control
	end

	function GroupMenu.Refresh()
		GroupMenu.CreateControl()
		GroupMenu.control:SetHidden(false)

		local current_difficulty_id = Difficulty.GetOverlandDifficultyId()
		local can_change = Difficulty.IsOverlandDifficultyEnabled()
		for _, button in ipairs(GroupMenu.buttons) do
			local difficulty_id = button.difficulty.id
			local is_current_difficulty = difficulty_id == current_difficulty_id
			-- Update UI
			do
				button:SetState(determine_button_state(is_current_difficulty, can_change), is_current_difficulty)
				button.selected_glow:SetHidden(not is_current_difficulty)
				button.selected_pip:SetHidden(not is_current_difficulty)
				button:SetAlpha(is_current_difficulty and 1 or Values.unselected_alpha)
			end
		end
	end
end
