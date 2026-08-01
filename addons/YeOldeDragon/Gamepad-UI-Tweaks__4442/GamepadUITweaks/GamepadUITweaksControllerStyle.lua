GamepadUITweaks = GamepadUITweaks or {}

local function ResolveAutoControllerButtonStyle()
	local uiPlatform = GetUIPlatform and GetUIPlatform() or UI_PLATFORM_PC
	if uiPlatform == UI_PLATFORM_XBOX then
		return "xbox"
	elseif uiPlatform == UI_PLATFORM_PS4 then
		return "ps4"
	elseif uiPlatform == UI_PLATFORM_PS5 then
		return "ps5"
	end

	local mostRecentGamepadType = GetMostRecentGamepadType and GetMostRecentGamepadType() or GAMEPAD_TYPE_NONE
	if mostRecentGamepadType == GAMEPAD_TYPE_XBOX or mostRecentGamepadType == GAMEPAD_TYPE_XBSX then
		return "xbox"
	elseif mostRecentGamepadType == GAMEPAD_TYPE_PS4 or mostRecentGamepadType == GAMEPAD_TYPE_PS4_NO_TOUCHPAD then
		return "ps4"
	elseif mostRecentGamepadType == GAMEPAD_TYPE_PS5 then
		return "ps5"
	elseif mostRecentGamepadType == GAMEPAD_TYPE_SWITCH then
		return "switchpro"
	end

	return "xbox"
end

local function ResolveEffectiveControllerButtonStyle()
	local configuredStyle = GamepadUITweaks.SV and GamepadUITweaks.SV.ControllerButtonStyle or "auto"
	if configuredStyle == "xbox" or configuredStyle == "ps4" or configuredStyle == "ps5" or configuredStyle == "switchpro" then
		return configuredStyle
	end

	return ResolveAutoControllerButtonStyle()
end

local function ResolveXboxTextureTheme()
	local mostRecentGamepadType = GetMostRecentGamepadType and GetMostRecentGamepadType() or GAMEPAD_TYPE_NONE
	if mostRecentGamepadType == GAMEPAD_TYPE_XBSX then
		return "scarlett"
	end
	return "xbone"
end

local function GetControllerConsoleArtTexturePath(style)
	local textureTheme = style
	if style == "xbox" then
		textureTheme = ResolveXboxTextureTheme()
	end

	local consoleArtByTheme = {
		xbone = "/esoui/art/buttons/gamepad/xbox/console_art_xb1.dds",
		scarlett = "/esoui/art/buttons/gamepad/scarlett/console_art_scarlett.dds",
		ps4 = "/esoui/art/buttons/gamepad/ps4/console_art_ps4.dds",
		ps5 = "/esoui/art/buttons/gamepad/ps5/console_art_ps5.dds",
		switchpro = "/esoui/art/buttons/gamepad/switchpro/console_art_switchpro_agnostic.dds",
	}

	return consoleArtByTheme[textureTheme]
end

local function GetControllerButtonTexturePath(style, keyCode)
	local textureTheme = style
	if style == "xbox" then
		textureTheme = ResolveXboxTextureTheme()
	end

	local textureMapByTheme = {
		xbone = {
			[KEY_GAMEPAD_BACK] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_view.dds",
			[KEY_GAMEPAD_BACK_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_view_button_hold.dds",
			[KEY_GAMEPAD_START] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_menu.dds",
			[KEY_GAMEPAD_START_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_menu_button_hold.dds",
			[KEY_GAMEPAD_DPAD_UP] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadup.dds",
			[KEY_GAMEPAD_DPAD_UP_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad_up_hold.dds",
			[KEY_GAMEPAD_DPAD_DOWN] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpaddown.dds",
			[KEY_GAMEPAD_DPAD_DOWN_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad_down_hold.dds",
			[KEY_GAMEPAD_DPAD_LEFT] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadleft.dds",
			[KEY_GAMEPAD_DPAD_LEFT_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad_left_hold.dds",
			[KEY_GAMEPAD_DPAD_RIGHT] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadright.dds",
			[KEY_GAMEPAD_DPAD_RIGHT_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad_right_hold.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_lb.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_left_shoulder_hold.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_rb.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_right_shoulder_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_lt.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_left_trigger_hold.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_rt.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_right_trigger_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_THEN_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_hold_lt_press_rt.dds",
			[KEY_GAMEPAD_LEFT_STICK] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls.dds",
			[KEY_GAMEPAD_LEFT_STICK_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_hold.dds",
			[KEY_GAMEPAD_RIGHT_STICK] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs.dds",
			[KEY_GAMEPAD_RIGHT_STICK_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_hold.dds",
			[KEY_GAMEPAD_BUTTON_1] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_a.dds",
			[KEY_GAMEPAD_BUTTON_1_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_a_hold.dds",
			[KEY_GAMEPAD_BUTTON_2] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds",
			[KEY_GAMEPAD_BUTTON_2_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_b_hold.dds",
			[KEY_GAMEPAD_BUTTON_3] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds",
			[KEY_GAMEPAD_BUTTON_3_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_x_hold.dds",
			[KEY_GAMEPAD_BUTTON_4] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_y.dds",
			[KEY_GAMEPAD_BUTTON_4_HOLD] = "/esoui/art/buttons/gamepad/xbox/nav_xbone_y_hold.dds",
		},
		ps4 = {
			[KEY_GAMEPAD_BACK] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_share.dds",
			[KEY_GAMEPAD_BACK_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_share_hold.dds",
			[KEY_GAMEPAD_START] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_options.dds",
			[KEY_GAMEPAD_START_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_options_hold.dds",
			[KEY_GAMEPAD_DPAD_UP] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadup.dds",
			[KEY_GAMEPAD_DPAD_UP_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpad_up_hold.dds",
			[KEY_GAMEPAD_DPAD_DOWN] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpaddown.dds",
			[KEY_GAMEPAD_DPAD_DOWN_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpad_down_hold.dds",
			[KEY_GAMEPAD_DPAD_LEFT] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadleft.dds",
			[KEY_GAMEPAD_DPAD_LEFT_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpad_left_hold.dds",
			[KEY_GAMEPAD_DPAD_RIGHT] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadright.dds",
			[KEY_GAMEPAD_DPAD_RIGHT_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpad_right_hold.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_left_shoulder_hold.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_right_shoulder_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_left_trigger_hold.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_r2.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_right_trigger_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_THEN_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_hold_l2_press_r2.dds",
			[KEY_GAMEPAD_LEFT_STICK] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls.dds",
			[KEY_GAMEPAD_LEFT_STICK_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_hold.dds",
			[KEY_GAMEPAD_RIGHT_STICK] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs.dds",
			[KEY_GAMEPAD_RIGHT_STICK_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_hold.dds",
			[KEY_GAMEPAD_TOUCHPAD_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_touchpad_hold.dds",
			[KEY_GAMEPAD_TOUCHPAD_PRESSED] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_press.dds",
			[KEY_GAMEPAD_BUTTON_1] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_x.dds",
			[KEY_GAMEPAD_BUTTON_1_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_x_hold.dds",
			[KEY_GAMEPAD_BUTTON_2] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_circle.dds",
			[KEY_GAMEPAD_BUTTON_2_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_circle_hold.dds",
			[KEY_GAMEPAD_BUTTON_3] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_square.dds",
			[KEY_GAMEPAD_BUTTON_3_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_square_hold.dds",
			[KEY_GAMEPAD_BUTTON_4] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle.dds",
			[KEY_GAMEPAD_BUTTON_4_HOLD] = "/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle_hold.dds",
		},
		ps5 = {
			[KEY_GAMEPAD_BACK] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_broadcast.dds",
			[KEY_GAMEPAD_BACK_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_broadcast_hold.dds",
			[KEY_GAMEPAD_START] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_options.dds",
			[KEY_GAMEPAD_START_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_options_hold.dds",
			[KEY_GAMEPAD_DPAD_UP] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpadup.dds",
			[KEY_GAMEPAD_DPAD_UP_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpad_up_hold.dds",
			[KEY_GAMEPAD_DPAD_DOWN] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpaddown.dds",
			[KEY_GAMEPAD_DPAD_DOWN_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpad_down_hold.dds",
			[KEY_GAMEPAD_DPAD_LEFT] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpadleft.dds",
			[KEY_GAMEPAD_DPAD_LEFT_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpad_left_hold.dds",
			[KEY_GAMEPAD_DPAD_RIGHT] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpadright.dds",
			[KEY_GAMEPAD_DPAD_RIGHT_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_dpad_right_hold.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_l1.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_left_shoulder_hold.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_r1.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_right_shoulder_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_l2.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_left_trigger_hold.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_r2.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_right_trigger_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_THEN_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_hold_l2_press_r2.dds",
			[KEY_GAMEPAD_LEFT_STICK] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_ls.dds",
			[KEY_GAMEPAD_LEFT_STICK_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_ls_hold.dds",
			[KEY_GAMEPAD_RIGHT_STICK] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_rs.dds",
			[KEY_GAMEPAD_RIGHT_STICK_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_rs_hold.dds",
			[KEY_GAMEPAD_TOUCHPAD_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_touchpad_hold.dds",
			[KEY_GAMEPAD_TOUCHPAD_PRESSED] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_trackpad_press.dds",
			[KEY_GAMEPAD_BUTTON_1] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_x.dds",
			[KEY_GAMEPAD_BUTTON_1_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_x_hold.dds",
			[KEY_GAMEPAD_BUTTON_2] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_circle.dds",
			[KEY_GAMEPAD_BUTTON_2_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_circle_hold.dds",
			[KEY_GAMEPAD_BUTTON_3] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_square.dds",
			[KEY_GAMEPAD_BUTTON_3_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_square_hold.dds",
			[KEY_GAMEPAD_BUTTON_4] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_triangle.dds",
			[KEY_GAMEPAD_BUTTON_4_HOLD] = "/esoui/art/buttons/gamepad/ps5/nav_ps5_triangle_hold.dds",
		},
		switchpro = {
			[KEY_GAMEPAD_BACK] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_minus.dds",
			[KEY_GAMEPAD_BACK_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_minus_button_hold.dds",
			[KEY_GAMEPAD_START] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_plus.dds",
			[KEY_GAMEPAD_START_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_plus_button_hold.dds",
			[KEY_GAMEPAD_DPAD_UP] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpadup.dds",
			[KEY_GAMEPAD_DPAD_UP_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpad_up_hold.dds",
			[KEY_GAMEPAD_DPAD_DOWN] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpaddown.dds",
			[KEY_GAMEPAD_DPAD_DOWN_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpad_down_hold.dds",
			[KEY_GAMEPAD_DPAD_LEFT] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpadleft.dds",
			[KEY_GAMEPAD_DPAD_LEFT_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpad_left_hold.dds",
			[KEY_GAMEPAD_DPAD_RIGHT] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpadright.dds",
			[KEY_GAMEPAD_DPAD_RIGHT_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_dpad_right_hold.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_l.dds",
			[KEY_GAMEPAD_LEFT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_left_shoulder_hold.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_r.dds",
			[KEY_GAMEPAD_RIGHT_SHOULDER_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_right_shoulder_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_zl.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_left_trigger_hold.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_zr.dds",
			[KEY_GAMEPAD_RIGHT_TRIGGER_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_right_trigger_hold.dds",
			[KEY_GAMEPAD_LEFT_TRIGGER_THEN_RIGHT_TRIGGER] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_hold_zl_press_zr.dds",
			[KEY_GAMEPAD_LEFT_STICK] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_ls.dds",
			[KEY_GAMEPAD_LEFT_STICK_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_ls_hold.dds",
			[KEY_GAMEPAD_RIGHT_STICK] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_rs.dds",
			[KEY_GAMEPAD_RIGHT_STICK_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_rs_hold.dds",
			[KEY_GAMEPAD_BUTTON_1] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_b.dds",
			[KEY_GAMEPAD_BUTTON_1_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_b_hold.dds",
			[KEY_GAMEPAD_BUTTON_2] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_a.dds",
			[KEY_GAMEPAD_BUTTON_2_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_a_hold.dds",
			[KEY_GAMEPAD_BUTTON_3] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_y.dds",
			[KEY_GAMEPAD_BUTTON_3_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_y_hold.dds",
			[KEY_GAMEPAD_BUTTON_4] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_x.dds",
			[KEY_GAMEPAD_BUTTON_4_HOLD] = "/esoui/art/buttons/gamepad/switchpro/nav_switchpro_x_hold.dds",
		},
	}

	local textureMap = textureMapByTheme[textureTheme]
	if textureMap then
		return textureMap[keyCode]
	end

	return nil
end

local function InstallControllerButtonStyleHook()
	if GamepadUITweaks.ControllerButtonStyleHookInstalled then
		return
	end

	local originalGenerateIconKeyMarkup = ZO_Keybindings_GenerateIconKeyMarkup
	if type(originalGenerateIconKeyMarkup) ~= "function" then
		return
	end

	ZO_Keybindings_GenerateIconKeyMarkup = function(key, scalePercent, useDisabledIcon)
		if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
			local style = ResolveEffectiveControllerButtonStyle()
			local texturePath = GetControllerButtonTexturePath(style, key)
			if texturePath then
				local scale = scalePercent or 180
				return ("|t%.1f%%:%.1f%%:%s|t"):format(scale, scale, texturePath)
			end
		end

		return originalGenerateIconKeyMarkup(key, scalePercent, useDisabledIcon)
	end

	GamepadUITweaks.ControllerButtonStyleHookInstalled = true
end

local function ApplyControllerConsoleArtForGamepadInfoPanel(optionsObject)
	local panelOwner = optionsObject or GAMEPAD_OPTIONS
	if not (panelOwner and panelOwner.control) then
		return
	end

	local infoPanel = panelOwner.control:GetNamedChild("InfoPanel")
	if not infoPanel then
		return
	end

	local gamepadTextureControl = infoPanel:GetNamedChild("Gamepad")
	if not gamepadTextureControl then
		return
	end

	local style = ResolveEffectiveControllerButtonStyle()
	local texturePath = GetControllerConsoleArtTexturePath(style)
	if texturePath and texturePath ~= "" then
		gamepadTextureControl:SetTexture(texturePath)
	end
end

local function InstallControllerConsoleArtHook()
	if GamepadUITweaks.ControllerConsoleArtHookInstalled then
		return
	end

	if type(ZO_GamepadOptions) == "table" and type(ZO_GamepadOptions.RefreshGamepadInfoPanel) == "function" then
		SecurePostHook(ZO_GamepadOptions, "RefreshGamepadInfoPanel", function(self)
			ApplyControllerConsoleArtForGamepadInfoPanel(self)
		end)
		GamepadUITweaks.ControllerConsoleArtHookInstalled = true
	end
end

local function ApplyControllerButtonStyle()
	if not GamepadUITweaks.SV then
		return
	end

	if not IsInGamepadPreferredMode() then
		return
	end

	if KEYBIND_STRIP and type(KEYBIND_STRIP.UpdateCurrentKeybindButtonGroups) == "function" then
		KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()

		-- Force a full visual rebind of currently displayed keybind labels/icons.
		-- UpdateCurrentKeybindButtonGroups uses an update-only path that can keep
		-- existing labels unchanged when keybind names are stable, which prevents
		-- our controller-style icon override from appearing immediately.
		if type(KEYBIND_STRIP.GetStyle) == "function" and type(KEYBIND_STRIP.SetStyle) == "function" then
			local currentStyle = KEYBIND_STRIP:GetStyle()
			if currentStyle then
				KEYBIND_STRIP:SetStyle(ZO_ShallowTableCopy(currentStyle))
			end
		end

		if type(KEYBIND_STRIP.RefreshDefaultExits) == "function" then
			KEYBIND_STRIP:RefreshDefaultExits()
		end
		if type(KEYBIND_STRIP.UpdateAnchors) == "function" then
			KEYBIND_STRIP:UpdateAnchors()
		end
	end

	if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.IsShowing and MAIN_MENU_GAMEPAD:IsShowing() then
		if type(MAIN_MENU_GAMEPAD.RefreshLists) == "function" then
			MAIN_MENU_GAMEPAD:RefreshLists()
		end

		if KEYBIND_STRIP and MAIN_MENU_GAMEPAD.keybindStripDescriptor and type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
			KEYBIND_STRIP:UpdateKeybindButtonGroup(MAIN_MENU_GAMEPAD.keybindStripDescriptor)
		end
	end

	if GAMEPAD_OPTIONS and GAMEPAD_OPTIONS.IsShowing and GAMEPAD_OPTIONS:IsShowing() then
		if type(GAMEPAD_OPTIONS.RefreshKeybinds) == "function" then
			GAMEPAD_OPTIONS:RefreshKeybinds()
		end
	end

	if GAMEPAD_OPTIONS and type(GAMEPAD_OPTIONS.RefreshGamepadInfoPanel) == "function" then
		GAMEPAD_OPTIONS:RefreshGamepadInfoPanel()
	else
		ApplyControllerConsoleArtForGamepadInfoPanel()
	end
end

GamepadUITweaks.InstallControllerButtonStyleHook = InstallControllerButtonStyleHook
GamepadUITweaks.InstallControllerConsoleArtHook = InstallControllerConsoleArtHook
GamepadUITweaks.ApplyControllerButtonStyle = ApplyControllerButtonStyle
