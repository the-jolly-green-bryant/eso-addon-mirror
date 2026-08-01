-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
WerewolfTimerBar = {}
local WWTB = WerewolfTimerBar
WWTB.Name = "WerewolfTimerBar"
WWTB.Version = 3.04
WWTB.Default = 
	{
		Unlock = false,
		BarOffsetX = 20,
		BarOffsetY = 75,
		BarColor = {0, 1, 0, 0.6},
		BarWidth = 300,
		BarHeight = 20,
		BarFontName = "BOLD_FONT",
		BarFontStyle = "outline",
		BarFontSize = 16,
		ShowTimer = true,
		ShowFury = true,
		FuryBarColor = {0, 0, 1, 0.85},
		FuryBarMaxColor = {1, 0, 0, 1},
		WarningColor = false,
		WarningLevel = 300,
		WarningBarColor = {1, 0.5, 0, 1},
		CriticalLevel = 150,
		CriticalBarColor = {1, 0, 0, 1},
		HideCSA = true,
		UltimateEnable = true,
		BlockInCombatOnly = true,
		ShowHeader = true,
		ShowHeaderLabel = true,
		ShowBarLabels = false,
	}
local LAM2 = LibAddonMenu2
local flag = true -- Flip-flop for prehook control
local text1, text2 -- Ultimate display message --
local BarMax, FuryBarMax -- Max values for Fury & ult
_, FuryBarMax, _ = GetUnitPower('player', POWERTYPE_WEREWOLF)
_, BarMax, _ = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_ULTIMATE)
local HeaderText = "Werewolf Form"
local UltiText = "Ultimate"
local FuryText = "Fury"
local FuryMaxText = "RAMPAGE!!"

-- Create string for the key bind
ZO_CreateStringId("SI_BINDING_NAME_BAR_ULTIMATELOCK_TOGGLE", "Toggle Lock/Unlock Ultimate")

-------------------------------------------------------------------------------------------------
--  Save Location Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SaveLoc(Control)
	WWTB.SV.BarOffsetX = Control:GetLeft()
	WWTB.SV.BarOffsetY = Control:GetTop()
end

-------------------------------------------------------------------------------------------------
--  Dimension Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetBarSize(Width, Height)
	local Height = Height
	-- Dimensions used for both bars --
	WerewolfTimerBarWindow_StatusBar:SetDimensions(Width, Height)
	WerewolfTimerBarWindow_FuryBar:SetDimensions(Width, Height)
	if WWTB.SV.ShowFury and WWTB.SV.ShowTimer then
		-- If both bars enabled, double the backdrop height --
		Height = Height*2
	end
	if not WWTB.SV.ShowFury then
		-- Hide Fury bar --
		WerewolfTimerBarWindow_FuryBar:SetDimensions(Width, 0)
	end
	if not WWTB.SV.ShowTimer then
		-- Hide Timer bar --
		WerewolfTimerBarWindow_StatusBar:SetDimensions(Width, 0)
	end
	if not WWTB.SV.ShowFury and not WWTB.SV.ShowTimer then
		-- Reduce backdrop size if no bars --
		Height = 0
	end
	if WWTB.SV.ShowHeader then
		-- Add space for header bar and anchor bars to ultimate lock button --
		Height = Height+WWTB.SV.BarFontSize+2
		WerewolfTimerBarWindow_StatusBar:ClearAnchors()
		WerewolfTimerBarWindow_StatusBar:SetAnchor(TOPLEFT, WerewolfTimerBarWindow_UltimateBlockButton, BOTTOMLEFT, 0, 2)
	else
		-- Modify anchors for bars if no header --
		WerewolfTimerBarWindow_StatusBar:ClearAnchors()
		WerewolfTimerBarWindow_StatusBar:SetAnchor(TOPLEFT, WerewolfTimerBarWindow_Backdrop, TOPLEFT, 5, 5)
	end
	-- Set backdrop dimensions --
	WerewolfTimerBarWindow_Backdrop:SetDimensions(WWTB.SV.BarWidth+10, Height+10)
	WerewolfTimerBarWindow:SetDimensions(WWTB.SV.BarWidth+10, Height+10)
end

-------------------------------------------------------------------------------------------------
--  Show/Hide Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.ShowHide()
	if IsWerewolf() then
		-- If werewolf then show the bars --
		if WWTB.SV.ShowTimer then
			-- Get Ultimate value --
			local current, _, _ = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_ULTIMATE)
			WerewolfTimerBarWindow_StatusBar:SetValue(current)
			-- Set Ultimate Bar color --
			if WWTB.SV.WarningColor and current <= WWTB.SV.CriticalLevel then
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.CriticalBarColor))
			elseif WWTB.SV.WarningColor and current <= WWTB.SV.WarningLevel then
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.WarningBarColor))
			else
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.BarColor))
			end
			WerewolfTimerBarWindow_StatusBarLabel:SetText(UltiText)
		end
		if WWTB.SV.ShowFury then
			-- Get Fury value --
			local currentFury, _, _ = GetUnitPower('player', POWERTYPE_WEREWOLF)
			WerewolfTimerBarWindow_FuryBar:SetValue(currentFury)
			-- Set Fury bar color --
			if currentFury == FuryBarMax then
				WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarMaxColor))
				WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryMaxText)
			else
				WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarColor))
				WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryText)
			end
		end
		-- If any parts shown, show window --
		if WWTB.SV.ShowTimer or WWTB.SV.ShowFury or WWTB.SV.ShowHeader then
			WerewolfTimerBarWindow:SetHidden(false)
		else
			WerewolfTimerBarWindow:SetHidden(true)
		end
	else
		-- If bars unlocked, show window regardless --
		if WWTB.SV.Unlock then
			WerewolfTimerBarWindow:SetHidden(false)
		else
			WerewolfTimerBarWindow:SetHidden(true)
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Lock/Unlock UI Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.UnlockUI(Control)
	WWTB.SV.Unlock = true
	Control:SetHidden(false)
	WerewolfTimerBarWindow:SetMovable(true)
	WerewolfTimerBarWindow:SetTopmost(true)
	WerewolfTimerBarWindow:SetHidden(false)
	if not IsWerewolf() then
		-- If not werewolf, fill bars so they are visible --
		WerewolfTimerBarWindow_StatusBar:SetValue(BarMax)
		WerewolfTimerBarWindow_FuryBar:SetValue(FuryBarMax)
	end
end

function WerewolfTimerBar.ClickLockUIButton(Control)
	WWTB.SV.Unlock = false
	Control:SetHidden(true)
	WerewolfTimerBarWindow:SetTopmost(false)
	WerewolfTimerBarWindow:SetMovable(false)
	WWTB.ShowHide()
end

-------------------------------------------------------------------------------------------------
--  Ultimate Block/UnBlock Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.DrawUltimateBlockButton(Control)
	if WWTB.SV.ShowHeader then 
		if WWTB.SV.UltimateEnable then
			-- Draw the lock icon --
			Control:SetNormalTexture("/esoui/art/miscellaneous/locked_up.dds")
			Control:SetPressedTexture("/esoui/art/miscellaneous/locked_down.dds")
			Control:SetMouseOverTexture("/esoui/art/miscellaneous/locked_over.dds")
		else
			-- Draw the unlock icon --
			Control:SetNormalTexture("/esoui/art/miscellaneous/unlocked_up.dds")
			Control:SetPressedTexture("/esoui/art/miscellaneous/unlocked_down.dds")
			Control:SetMouseOverTexture("/esoui/art/miscellaneous/unlocked_over.dds")
		end
	end
end

function WerewolfTimerBar.ClickUltimateBlockButton(Control)
	-- Flip flop for lock and unlock state --
	WWTB.SV.UltimateEnable = not WWTB.SV.UltimateEnable
	-- Setup the display text --
	WWTB.SetupUltimateBlockText()
	-- Display the message, if enabled --
	if not WWTB.SV.HideCSA then
		local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
		msg:SetText(text1, text2)
		msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
		msg:MarkSuppressIconFrame()
		CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
	end
	d(string.format("%s", text1))
	-- Update the button texture --
	WWTB.DrawUltimateBlockButton(Control)
end

function WerewolfTimerBar.SetupUltimateBlockText()
	-- Get keybinding --
	local keyBind = ZO_Keybindings_GetHighestPriorityBindingStringFromAction("BAR_ULTIMATELOCK_TOGGLE")
	-- Change text message depending on lock/unlock state --
	if WWTB.SV.UltimateEnable then
		text1 = "Werewolf Timer Bar: Ultimate BLOCKED!"
		if keyBind then
			text2 = string.format("%s %s %s %s", "Click the lock in the top left of the addon", "or press [", keyBind, "] to change.")
		else
			text2 = "Click the lock in the top left of the addon to change or set a keybind to toggle this."
		end
	else
		text1 = "Werewolf Timer Bar: Ultimate UNBLOCKED!"
		if keyBind then
			text2 = string.format("%s %s %s %s", "Click the unlock in the top left of the addon", "or press [", keyBind, "] to change.")
		else
			text2 = "Click the unlock in the top left of the addon to change or set a keybind to toggle this."
		end
	end
end

function WerewolfTimerBar.SetupUltimateBlock()
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
		-- Use a flag since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast --
  		flag = not flag
		-- Player is in combat, or has permanet block enabled --
		if IsUnitInCombat("player") or not WWTB.SV.BlockInCombatOnly then
			-- Ultimate blocking set to true and is a werewolf --
			if WWTB.SV.UltimateEnable and IsWerewolf() then
				-- Get the slot number for the actionbar button pressed --
				slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)')) or tonumber(debug.traceback():match('keybind = "GAMEPAD_ACTION_BUTTON_(%d)'))
				-- Ultimate button pressed --
				if slotNum == 8 then
					-- Get ability ID --
					local ultAbilityId = GetSlotBoundId(8)
					-- Is ability werewolf ultimate or morph? --
					if ultAbilityId == 32455 or ultAbilityId == 39075 or ultAbilityId == 39076 then
						-- Just one message broadcast since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast --
						if flag and not WWTB.SV.HideCSA then
							WWTB.SetupUltimateBlockText()
							local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
							msg:SetText(text1, text2)
							msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
							msg:MarkSuppressIconFrame()
							CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
							d(string.format("%s", text1))
						end
						-- Returning true will block the keypress --
						return true
					end
				end
			end
		end
	end)
end

-------------------------------------------------------------------------------------------------
-- Setup UI Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetupUIElements()
	-- Lock UI button --
	if not WWTB.SV.Unlock then
		WerewolfTimerBarWindow_LockUIButton:SetHidden(true)
	end
	WerewolfTimerBarWindow_LockUIButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Lock the UI") end)
    WerewolfTimerBarWindow_LockUIButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
	-- Show Headers --
	if WWTB.SV.ShowHeader then
		-- Block ultimate button --
		WerewolfTimerBarWindow_UltimateBlockButton:SetHidden(false)
		WerewolfTimerBarWindow_UltimateBlockButton:SetDimensions(WWTB.SV.BarFontSize+2, WWTB.SV.BarFontSize+2)
		WerewolfTimerBarWindow_UltimateBlockButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Enable/disable ultimate button keypress") end)
		WerewolfTimerBarWindow_UltimateBlockButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
		-- Text --
		WerewolfTimerBarWindow_Label:SetFont('$('..WWTB.SV.BarFontName..')|'..tostring(WWTB.SV.BarFontSize)..'|'..WWTB.SV.BarFontStyle..'')
		WerewolfTimerBarWindow_Label:SetText(HeaderText)
		if WWTB.SV.ShowHeaderLabel then
			WerewolfTimerBarWindow_Label:SetHidden(false)
		else
			WerewolfTimerBarWindow_Label:SetHidden(true)
		end
	else
		WerewolfTimerBarWindow_UltimateBlockButton:SetHidden(true)
		WerewolfTimerBarWindow_Label:SetHidden(true)
	end
	-- Timer Bar --
	if WWTB.SV.ShowTimer then
		WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.BarColor))
		WerewolfTimerBarWindow_StatusBar:SetMinMax(0,BarMax)
		-- Labels --
		if WWTB.SV.ShowBarLabels then
			WerewolfTimerBarWindow_StatusBarLabel:SetFont('$('..WWTB.SV.BarFontName..')|'..tostring(WWTB.SV.BarFontSize)..'|'..WWTB.SV.BarFontStyle..'')
			WerewolfTimerBarWindow_StatusBarLabel:SetText(UltiText)
			WerewolfTimerBarWindow_StatusBarLabel:SetHidden(false)
		else
			WerewolfTimerBarWindow_StatusBarLabel:SetHidden(true)
		end
	else
		WerewolfTimerBarWindow_StatusBarLabel:SetHidden(true)
	end
	-- Fury Bar --
	if WWTB.SV.ShowFury then
		WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarColor))
		WerewolfTimerBarWindow_FuryBar:SetMinMax(0,FuryBarMax)
		-- Labels --
		if WWTB.SV.ShowBarLabels then
			WerewolfTimerBarWindow_FuryBarLabel:SetFont('$('..WWTB.SV.BarFontName..')|'..tostring(WWTB.SV.BarFontSize)..'|'..WWTB.SV.BarFontStyle..'')
			WerewolfTimerBarWindow_FuryBarLabel:SetHidden(false)
		else
			WerewolfTimerBarWindow_FuryBarLabel:SetHidden(true)
		end
	else
		WerewolfTimerBarWindow_FuryBarLabel:SetHidden(true)
	end
	WWTB.SetBarSize(WWTB.SV.BarWidth, WWTB.SV.BarHeight)
	
	-- Position --
	WerewolfTimerBarWindow:ClearAnchors()
	WerewolfTimerBarWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WWTB.SV.BarOffsetX,WWTB.SV.BarOffsetY)
	WWTB.ShowHide()
end

function WerewolfTimerBar.ResetPosition()
	WerewolfTimerBarWindow:ClearAnchors()
	WerewolfTimerBarWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
end

-------------------------------------------------------------------------------------------------
--  Settings Panel Setup Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetupSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Werewolf Timer Bar",
		displayName = "Werewolf Timer Bar",
		author = "PhnxZ, maximoz",
		version = string.format("%s", WWTB.Version),
		slashCommand = "/wwtbar",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			WWTB.SetupUIElements()
		end,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Werewolf_Timer_Bar", panelData)
	
	local optionsData = {
		{
			type = "description",
			text = "This addon contains a status bar and prevention from using your ultimate when in werewolf form."
		},
		{
			type = "header",
			name = "General Settings"
		},
		-- UI unlock --
		{
			type = "button",
			name = "Unlock UI",
			width = "half",
			tooltip = "Unlock the UI for moving",
			func = function()
				WWTB.UnlockUI(WerewolfTimerBarWindow_LockUIButton)
			end,
		},
		{
			type = "button",
			name = "Reset Position",
			width = "half",
			tooltip = "Reset UI position to center screen",
			func = function()
				WWTB.ResetPosition()
			end,
		},
		-- Account-wide/Characters settings --
		WWTB.SV:GetLibAddonMenuAccountCheckbox(),
		-- Section enables --
		{
			type = "submenu",
			name = "Function enables/disables",
			controls = {
				{
					type = "checkbox",
					name = "Header Bar",
					width = "half",
					tooltip = "Show/hide header bar with Ultimate lock icon & text",
					default = WWTB.Default.ShowHeader,
					getFunc = function() return WWTB.SV.ShowHeader end,
					setFunc = function(value)
						if not value then
							WWTB.SV.ShowHeader = false
						else
							WWTB.SV.ShowHeader = true
						end
						WWTB.SetupUIElements()
					end
				},
				{
					type = "checkbox",
					name = "Header Text",
					width = "half",
					tooltip = "Show/hide header text",
					default = WWTB.Default.ShowHeaderLabel,
					disabled = function() return not WWTB.SV.ShowHeader end,
					getFunc = function() return WWTB.SV.ShowHeaderLabel end,
					setFunc = function(value)
						if not value then
							WWTB.SV.ShowHeaderLabel = false
						else
							WWTB.SV.ShowHeaderLabel = true
						end
						WWTB.SetupUIElements()
					end
				},
				{
					type = "checkbox",
					name = "Ultimate Timer Bar",
					width = "half",
					tooltip = "Show bar for Ultimate timer",
					default = WWTB.Default.ShowTimer,
					getFunc = function() return WWTB.SV.ShowTimer end,
					setFunc = function(value)
						if not value then
							WWTB.SV.ShowTimer = false
							-- If both bars disabled, unregister for updates --
							if not WWTB.SV.ShowFury then
								EVENT_MANAGER:UnregisterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE)
							end
						else
							WWTB.SV.ShowTimer = true
							-- Register for updates --
							EVENT_MANAGER:RegisterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, WWTB.onPowerUpdate)
							EVENT_MANAGER:AddFilterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'player')
						end
						WWTB.SetupUIElements()
					end
				},
				{
					type = "checkbox",
					name = "Fury Bar",
					width = "half",
					tooltip = "Show bar for Fury stacks",
					default = WWTB.Default.ShowFury,
					getFunc = function() return WWTB.SV.ShowFury end,
					setFunc = function(value)
						if not value then
							WWTB.SV.ShowFury = false
							-- If both bars disabled, unregister for updates --
							if not WWTB.SV.ShowTimer then
								EVENT_MANAGER:UnregisterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE)
							end
						else
							WWTB.SV.ShowFury = true
							-- Register for updates --
							EVENT_MANAGER:RegisterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, WWTB.onPowerUpdate)
							EVENT_MANAGER:AddFilterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'player')
						end
						WWTB.SetupUIElements()
					end
				},
				{
					type = "checkbox",
					name = "Bar Text",
					tooltip = "Show text labels on bars",
					width = "half",
					default = WWTB.Default.ShowBarLabels,
					disabled = function() return not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury end,
					getFunc = function() return WWTB.SV.ShowBarLabels end,
					setFunc = function(value)
						if not value then
							WWTB.SV.ShowBarLabels = false
						else
							WWTB.SV.ShowBarLabels = true
						end
						WWTB.SetupUIElements()
					end
				},
				{
					type = "checkbox",
					name = "CSA & Chat Messages",
					tooltip = "Show Center Screen Announcements and chat messages",
					width = "half",
					default = not WWTB.Default.HideCSA,
					getFunc = function() return not WWTB.SV.HideCSA end,
					setFunc = function(value)
						if not value then
							WWTB.SV.HideCSA = true
						else
							WWTB.SV.HideCSA = false
						end
					end
				},
				{
					type = "checkbox",
					name = "Only Lock Ultimate In Combat",
					tooltip = "Only lock ultimate ability use when in combat",
					width = "half",
					default = WWTB.Default.BlockInCombatOnly,
					getFunc = function() return WWTB.SV.BlockInCombatOnly end,
					setFunc = function(value)
						if not value then
							WWTB.SV.BlockInCombatOnly = false
						else
							WWTB.SV.BlockInCombatOnly = true
						end
					end
				},
				{
					type = "checkbox",
					name = "Ultimate Low Warning Color",
					tooltip = "Change the color of the Ultimate bar when it gets low",
					width = "half",
					default = WWTB.Default.WarningColor,
					disabled = function() return not WWTB.SV.ShowTimer end,
					getFunc = function() return WWTB.SV.WarningColor end,
					setFunc = function(value)
						if not value then
							WWTB.SV.WarningColor = false
						else
							WWTB.SV.WarningColor = true
						end
						WWTB.SetupUIElements()
					end
				},
			},
		},
		-- Bar settings --
		{
			type = "submenu",
			name = "Display settings",
			controls = {
				{
					type = "slider",
					name = "Bar Width",
					tooltip = "Adjusts the width",
					width = "half",
					min = 100,
					max = 300,
					step = 5,
					default = WWTB.Default.BarWidth,
					disabled = function() return not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury end,
					getFunc = function() return WWTB.SV.BarWidth end,
					setFunc = function(newValue) 
						WWTB.SV.BarWidth = newValue
						WWTB.SetBarSize(newValue, WWTB.SV.BarHeight)
					end,
				},
				{
					type = "slider",
					name = "Bar Height",
					tooltip = "Adjusts the height",
					width = "half",
					min = 5,
					max = 50,
					step = 1,
					default = WWTB.Default.BarHeight,
					disabled = function() return not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury end,
					getFunc = function() return WWTB.SV.BarHeight end,
					setFunc = function(newValue) 
						WWTB.SV.BarHeight= newValue
						WWTB.SetBarSize(WWTB.SV.BarWidth, newValue)
					end,
				},
				{
					type = "dropdown",
					name = "Font Name",
					tooltip = "Changes the font name",
					choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
					width = "half",
					default = WWTB.Default.BarFontName,
					disabled = function() return (not WWTB.SV.ShowHeader or not WWTB.SV.ShowHeaderLabel) and ((not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury) or not WWTB.SV.ShowBarLabels) end,
					getFunc = function() return WWTB.SV.BarFontName end,
					setFunc = function(newValue) 
						WWTB.SV.BarFontName= newValue
						WWTB.SetupUIElements()
					end,
				},
				{
					type = "dropdown",
					name = "Font Style",
					tooltip = "Changes the font style",
					choices = {"outline","thin-outline","thick-outline","shadow","soft-shadow-thin","soft-shadow-thick"},
					width = "half",
					default = WWTB.Default.BarFontStyle,
					disabled = function() return (not WWTB.SV.ShowHeader or not WWTB.SV.ShowHeaderLabel) and ((not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury) or not WWTB.SV.ShowBarLabels) end,
					getFunc = function() return WWTB.SV.BarFontStyle end,
					setFunc = function(newValue) 
						WWTB.SV.BarFontStyle= newValue
						WWTB.SetupUIElements()
					end,
				},
				{
					type = "slider",
					name = "Font & Lock Icon Size",
					tooltip = "Adjusts the font & lock icon size",
					width = "half",
					min = 8,
					max = 30,
					step = 1,
					default = WWTB.Default.BarFontSize,
					disabled = function() return not WWTB.SV.ShowHeader and ((not WWTB.SV.ShowTimer and not WWTB.SV.ShowFury) or not WWTB.SV.ShowBarLabels) end,
					getFunc = function() return WWTB.SV.BarFontSize end,
					setFunc = function(newValue) 
						WWTB.SV.BarFontSize= newValue
						WWTB.SetupUIElements()
					end
				},
				{
					type = "divider",
					width = "full",
					--height = 10, (optional)
					--alpha = 0.25, (optional)
				},
				{
					type = "colorpicker",
					name = "Timer Bar Color",
					width = "half",
					tooltip = "Changes the color of the Timer bar",
					default = ZO_ColorDef:New(unpack(WWTB.Default.BarColor)),
					disabled = function() return not WWTB.SV.ShowTimer end,
					getFunc = function() return unpack(WWTB.SV.BarColor) end,
					setFunc = function(r,g,b,a) 
						WWTB.SV.BarColor = {r, g, b, a}
						WWTB.SetupUIElements()
					end,
				},
				{
					type = "colorpicker",
					name = "Fury Bar Color",
					width = "half",
					tooltip = "Changes the color of the Fury bar",
					default = ZO_ColorDef:New(unpack(WWTB.Default.FuryBarColor)),
					disabled = function() return not WWTB.SV.ShowFury end,
					getFunc = function() return unpack(WWTB.SV.FuryBarColor) end,
					setFunc = function(r,g,b,a) 
						WWTB.SV.FuryBarColor = {r, g, b, a}
						WWTB.SetupUIElements()
					end,
				},
				{
					type = "colorpicker",
					name = "Fury Bar Full Color",
					width = "half",
					tooltip = "Changes the color of the Fury bar when it is full",
					default = ZO_ColorDef:New(unpack(WWTB.Default.FuryBarMaxColor)),
					disabled = function() return not WWTB.SV.ShowFury end,
					getFunc = function() return unpack(WWTB.SV.FuryBarMaxColor) end,
					setFunc = function(r,g,b,a) 
						WWTB.SV.FuryBarMaxColor = {r, g, b, a}
						WWTB.SetupUIElements()
					end,
				},
				{
					type = "divider",
					width = "full",
					--height = 10, (optional)
					--alpha = 0.25, (optional)
				},
				-- Warning 
				{
					type = "slider",
					name = "Warning Level",
					tooltip = "Set warning level",
					width = "half",
					min = 100,
					max = 450,
					step = 10,
					default = WWTB.Default.WarningLevel,
					disabled = function() return not WWTB.SV.ShowTimer or not WWTB.SV.WarningColor end,
					getFunc = function() return WWTB.SV.WarningLevel end,
					setFunc = function(newValue) 
						WWTB.SV.WarningLevel= newValue end,
						WWTB.SetupUIElements()
				},
				{
					type = "colorpicker",
					name = "Warning Level Color",
					width = "half",
					tooltip = "Changes the color of the Timer bar when warning",
					default = ZO_ColorDef:New(unpack(WWTB.Default.WarningBarColor)),
					disabled = function() return not WWTB.SV.ShowTimer or not WWTB.SV.WarningColor end,
					getFunc = function() return unpack(WWTB.SV.WarningBarColor) end,
					setFunc = function(r,g,b,a) 
						WWTB.SV.WarningBarColor = {r, g, b, a} end,
						WWTB.SetupUIElements()
				},
				-- Critical
				{
					type = "slider",
					name = "Critical Level",
					tooltip = "Set Critical level",
					width = "half",
					min = 0,
					max = 200,
					step = 10,
					default = WWTB.Default.CriticalLevel,
					disabled = function() return not WWTB.SV.ShowTimer or not WWTB.SV.WarningColor end,
					getFunc = function() return WWTB.SV.CriticalLevel end,
					setFunc = function(newValue) 
						WWTB.SV.CriticalLevel= newValue end,
						WWTB.SetupUIElements()
				},
				{
					type = "colorpicker",
					name = "Critical Level Color",
					width = "half",
					tooltip = "Changes the color of the Timer bar when Critical",
					default = ZO_ColorDef:New(unpack(WWTB.Default.CriticalBarColor)),
					disabled = function() return not WWTB.SV.ShowTimer or not WWTB.SV.WarningColor end,
					getFunc = function() return unpack(WWTB.SV.CriticalBarColor) end,
					setFunc = function(r,g,b,a) 
						WWTB.SV.CriticalBarColor = {r, g, b, a} end,
						WWTB.SetupUIElements()
				},
			},
		},
	}
	LAM2:RegisterOptionControls("Werewolf_Timer_Bar", optionsData)
end

-------------------------------------------------------------------------------------------------
--  Update UI Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.onPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	-- Update the bar on any changes --
	if powerType == 8 and WWTB.SV.ShowTimer then
		-- powerType 8 is Ultimate -
		WerewolfTimerBarWindow_StatusBar:SetValue(powerValue)
		-- Set Ultimate bar color --
		if WWTB.SV.WarningColor and powerValue <= WWTB.SV.CriticalLevel then
			WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.CriticalBarColor))
		elseif WWTB.SV.WarningColor and powerValue <= WWTB.SV.WarningLevel then
			WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.WarningBarColor))
		else
			WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.BarColor))
		end
	elseif powerType == 2 and WWTB.SV.ShowFury then
		-- powerType 2 is Fury --
		WerewolfTimerBarWindow_FuryBar:SetValue(powerValue)
		-- Set Fury bar color --
		if powerValue == FuryBarMax then
			WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarMaxColor))
			WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryMaxText)
		else
			WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarColor))
			WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryText)
		end
	end
end

function WerewolfTimerBar.OnWerewolfStateChanged(eventCode, isWerewolf)
	if isWerewolf then
		-- If werewolf then show the bar --
		if WWTB.SV.ShowTimer then
			-- Get Ultimate value --
			local current, _, _ = GetUnitPower('player', COMBAT_MECHANIC_FLAGS_ULTIMATE)
			WerewolfTimerBarWindow_StatusBar:SetValue(current)
			-- Set Ultimate bar color --
			if current <= WWTB.SV.CriticalLevel then
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.CriticalBarColor))
			elseif current <= WWTB.SV.WarningLevel then
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.WarningBarColor))
			else
				WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WWTB.SV.BarColor))
			end
		end
		
		if WWTB.SV.ShowFury then
			-- Get Fury value --
			local currentFury, _, _ = GetUnitPower('player', POWERTYPE_WEREWOLF)
			WerewolfTimerBarWindow_FuryBar:SetValue(currentFury)
			-- Set Fury bar color --
			if currentFury == FuryBarMax then
				WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarMaxColor))
				WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryMaxText)
			else
				WerewolfTimerBarWindow_FuryBar:SetColor(unpack(WWTB.SV.FuryBarColor))
				WerewolfTimerBarWindow_FuryBarLabel:SetText(FuryText)
			end
		end
		WerewolfTimerBarWindow:SetHidden(false)
	else
		WerewolfTimerBarWindow:SetHidden(true)
		WWTB.SV.Unlock = false
	end
end

-------------------------------------------------------------------------------------------------
--  On Reticle Hidden  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.OnReticleHidden(eventCode, hidden)
	if SCENE_MANAGER:GetCurrentScene() == nil then return end
	local scene = SCENE_MANAGER:GetCurrentScene():GetName()
	if hidden then
		-- Press '.' --
		if scene == "hudui" then
			WWTB.ShowHide()
		-- Press 'esc' --
		elseif scene == "gameMenuInGame" then
			WWTB.ShowHide()
		else
			-- Hide in all other mode/scene --
			WerewolfTimerBarWindow:SetHidden(true)
		end
	else
		WWTB.ShowHide()
	end
end

-------------------------------------------------------------------------------------------------
--  On Player Activated  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.OnPlayerActivated(eventCode, initial)
	if initial then
		WWTB.ShowHide()
	end
end
 
-------------------------------------------------------------------------------------------------
--  On AddOn Loaded  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.OnAddOnLoaded(eventCode, addonName)
	if addonName == WWTB.Name then
		EVENT_MANAGER:UnregisterForEvent(WWTB.Name, EVENT_ADD_ON_LOADED)
		-- Save variables using LibSavedVars --
		WWTB.SV = LibSavedVars
			:NewAccountWide("WerewolfTimerBarVars_Account", WWTB.Default)
			:AddCharacterSettingsToggle("WerewolfTimerBarVars_Characters")
		-- Setup settings panel --
		WWTB.SetupSettingsWindow()
		-- Setup UI elements --
		WWTB.SetupUIElements()
		-- Setup button press for ultimate prevention --
		WWTB.SetupUltimateBlock()
		-- Setup ultimate lock/unlock button ---
		WWTB.DrawUltimateBlockButton(WerewolfTimerBarWindow_UltimateBlockButton)
		-- Check if player is infected by werewolf --
		local isWerewolfInfected = false
		local numberOfBuffs = GetNumBuffs('player')
		if numberOfBuffs ~= 0 then
			for i = 0, numberOfBuffs do
				local buffName, _, _, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo('player', i)
				if abilityId == 35658 or abilityId == 40521 then
					isWerewolfInfected = true
					break
				end
			end
		end
		if isWerewolfInfected then
			-- Register event for player logging in and porting --
			EVENT_MANAGER:RegisterForEvent(WWTB.Name_PlayerAct, EVENT_PLAYER_ACTIVATED, WWTB.OnPlayerActivated)
			-- Register event for showing and hiding UI when it's unlock or in different scenes --
			EVENT_MANAGER:RegisterForEvent(WWTB.Name_RetHide, EVENT_RETICLE_HIDDEN_UPDATE, WWTB.OnReticleHidden)
			-- Register events for werewolf (State change) updates --
			EVENT_MANAGER:RegisterForEvent(WWTB.Name_WWState, EVENT_WEREWOLF_STATE_CHANGED, WWTB.OnWerewolfStateChanged)
			-- Register events for werewolf updates --
			if WWTB.SV.ShowTimer or WWTB.SV.ShowFury then
				EVENT_MANAGER:RegisterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, WWTB.onPowerUpdate)
				EVENT_MANAGER:AddFilterForEvent(WWTB.Name_Upd, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'player')
			end

		end	
		if WWTB.SV.Unlock then
			WWTB.ClickLockUIButton(WerewolfTimerBarWindow_LockUIButton)
		end
	end
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(WWTB.Name, EVENT_ADD_ON_LOADED, WWTB.OnAddOnLoaded)