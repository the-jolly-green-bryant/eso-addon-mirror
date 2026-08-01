-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
WerewolfTimerBar = {}
WerewolfTimerBar.Name = "WerewolfTimerBar"
WerewolfTimerBar.Version = 2.6
WerewolfTimerBar.Default = 
	{
		Unlock = false,
		BarOffsetX = 20,
		BarOffsetY = 75,
		BarColor = {1, 0.4, 0, 1},
		BarWidth = 300,
		BarHeight = 20,
		BarFontName = "BOLD_FONT",
		BarFontStyle = "thick-outline",
		BarFontSize = 16,
		UltimateEnable = true
	}
local LAM2 = LibAddonMenu2
local flag = true -- Flip-flop for prehook control
local text1, text2 -- Ultimate display message --

-- Create string for the key bind
ZO_CreateStringId("SI_BINDING_NAME_BAR_ULTIMATELOCK_TOGGLE", "Toggle Lock/Unlock Ultimate")

-------------------------------------------------------------------------------------------------
--  Save Location Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SaveLoc(Control)
	WerewolfTimerBar.SavedVariables.BarOffsetX = Control:GetLeft()
	WerewolfTimerBar.SavedVariables.BarOffsetY = Control:GetTop()
end

-------------------------------------------------------------------------------------------------
--  Dimension Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetBarSize(Width, Height)
	WerewolfTimerBarWindow_StatusBar:SetDimensions(Width, Height)
	WerewolfTimerBarWindow_Backdrop:SetDimensions(WerewolfTimerBar.SavedVariables.BarWidth+10, WerewolfTimerBar.SavedVariables.BarHeight+WerewolfTimerBar.SavedVariables.BarFontSize+15)
	WerewolfTimerBarWindow:SetDimensions(WerewolfTimerBar.SavedVariables.BarWidth+10, WerewolfTimerBar.SavedVariables.BarHeight+WerewolfTimerBar.SavedVariables.BarFontSize+15)	
end

-------------------------------------------------------------------------------------------------
--  Show/Hide Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.ShowHide()
	if IsWerewolf() then
		-- If werewolf then show the bar --
		local current, max, effectiveMax = GetUnitPower('player', POWERTYPE_WEREWOLF)
		WerewolfTimerBarWindow_StatusBar:SetValue(current)
		WerewolfTimerBarWindow:SetHidden(false)
	else
		if WerewolfTimerBar.SavedVariables.Unlock then
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
	WerewolfTimerBar.SavedVariables.Unlock = true
	Control:SetHidden(false)
	WerewolfTimerBarWindow:SetTopmost(true)
	WerewolfTimerBarWindow:SetHidden(false)
	if not IsWerewolf() then
		WerewolfTimerBarWindow_StatusBar:SetValue(1000)
	end
end

function WerewolfTimerBar.ClickLockUIButton(Control)
	WerewolfTimerBar.SavedVariables.Unlock = false
	Control:SetHidden(true)
	WerewolfTimerBar.ShowHide()
end

-------------------------------------------------------------------------------------------------
--  Ultimate Block/UnBlock Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.DrawUltimateBlockButton(Control)
	if WerewolfTimerBar.SavedVariables.UltimateEnable then
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

function WerewolfTimerBar.ClickUltimateBlockButton(Control)
	-- Flip flop for lock and unlock state --
	WerewolfTimerBar.SavedVariables.UltimateEnable = not WerewolfTimerBar.SavedVariables.UltimateEnable
	-- Setup the display text --
	WerewolfTimerBar.SetupUltimateBlockText()
	-- Display the message --
	local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
	msg:SetText(text1, text2)
	msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
	msg:MarkSuppressIconFrame()
	CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
	d(string.format("%s %s", text1, text2))
	-- Update the button texture --
	WerewolfTimerBar.DrawUltimateBlockButton(Control)
end

function WerewolfTimerBar.SetupUltimateBlockText()
	-- Get keybinding --
	local keyBind = ZO_Keybindings_GetHighestPriorityBindingStringFromAction("BAR_ULTIMATELOCK_TOGGLE")
	-- Change text message depending on lock/unlock state --
	if WerewolfTimerBar.SavedVariables.UltimateEnable then
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
		-- Ultimate blocking set to true and is a werewolf --
		if WerewolfTimerBar.SavedVariables.UltimateEnable and IsWerewolf() then
			-- Get the slot number for the actionbar button pressed --
			slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)'))
			-- Ultimate button pressed --
			if slotNum == 8 then
				-- Just one message broadcast since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast --
				if flag then
					WerewolfTimerBar.SetupUltimateBlockText()
					local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
					msg:SetText(text1, text2)
					msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
					msg:MarkSuppressIconFrame()
					CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
					d(string.format("%s %s", text1, text2))
				end
				-- Returning true will block the keypress --
				return true
			end
		end
	end)
end

-------------------------------------------------------------------------------------------------
-- Setup UI Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetupUIElements()
	WerewolfTimerBar.SavedVariables.Unlock = false
	-- Lock UI button --
	WerewolfTimerBarWindow_LockUIButton:SetHidden(true)
	WerewolfTimerBarWindow_LockUIButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Lock the UI") end)
    WerewolfTimerBarWindow_LockUIButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
	-- Block ultimate button --
	WerewolfTimerBarWindow_UltimateBlockButton:SetDimensions(WerewolfTimerBar.SavedVariables.BarFontSize+2, WerewolfTimerBar.SavedVariables.BarFontSize+2)
	WerewolfTimerBarWindow_UltimateBlockButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Enable/disable ultimate button keypress") end)
	WerewolfTimerBarWindow_UltimateBlockButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
	-- Text --
	WerewolfTimerBarWindow_Label:SetFont('$('..WerewolfTimerBar.SavedVariables.BarFontName..')|'..tostring(WerewolfTimerBar.SavedVariables.BarFontSize)..'|'..WerewolfTimerBar.SavedVariables.BarFontStyle..'')
	-- Bar --
	WerewolfTimerBarWindow_StatusBar:SetColor(unpack(WerewolfTimerBar.SavedVariables.BarColor))
	WerewolfTimerBarWindow_StatusBar:SetMinMax(0,1000)
	WerewolfTimerBarWindow_StatusBar:SetValue(1000)
	WerewolfTimerBar.SetBarSize(WerewolfTimerBar.SavedVariables.BarWidth, WerewolfTimerBar.SavedVariables.BarHeight)
	-- Position --
	WerewolfTimerBarWindow:ClearAnchors()
	WerewolfTimerBarWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WerewolfTimerBar.SavedVariables.BarOffsetX,WerewolfTimerBar.SavedVariables.BarOffsetY)
end

-------------------------------------------------------------------------------------------------
--  Settings Panel Setup Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.SetupSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Werewolf Timer Bar",
		displayName = "Werewolf Timer Bar",
		author = "maximoz",
		version = "2.6",
		slashCommand = "/wwtbar",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Werewolf_Timer_Bar", panelData)
	
	local optionsData = {
		{
			type = "description",
			text = "This addon contains a status bar and prevention for pressing the ultimate when playing a werewolf."
		},
		{
			type = "header",
			name = "General Settings"
		},
		-- Account-wide/Characters settings --
		WerewolfTimerBar.SavedVariables:GetLibAddonMenuAccountCheckbox(),

		-- Bar settings --
		{
			type = "slider",
			name = "Select Bar Width",
			tooltip = "Adjusts the width",
			min = 215,
			max = 300,
			step = 1,
			default = 200,
			getFunc = function() return WerewolfTimerBar.SavedVariables.BarWidth end,
			setFunc = function(newValue) 
				WerewolfTimerBar.SavedVariables.BarWidth = newValue
				WerewolfTimerBar.SetBarSize(newValue, WerewolfTimerBar.SavedVariables.BarHeight) end,
		},
		{
			type = "slider",
			name = "Select Bar Height",
			tooltip = "Adjusts the height",
			min = 10,
			max = 50,
			step = 1,
			default = 20,
			getFunc = function() return WerewolfTimerBar.SavedVariables.BarHeight end,
			setFunc = function(newValue) 
				WerewolfTimerBar.SavedVariables.BarHeight= newValue
				WerewolfTimerBar.SetBarSize(WerewolfTimerBar.SavedVariables.BarWidth, newValue) end,
		},
		{
			type = "dropdown",
			name = "Select Font Name",
			tooltip = "Changes the font name",
			choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
			width = "full",
			default = WerewolfTimerBar.SavedVariables.BarFontName,
			getFunc = function() return WerewolfTimerBar.SavedVariables.BarFontName end,
			setFunc = function(newValue) 
				WerewolfTimerBar.SavedVariables.BarFontName= newValue
				WerewolfTimerBarWindow_Label:SetFont('$('..WerewolfTimerBar.SavedVariables.BarFontName..')|'..tostring(WerewolfTimerBar.SavedVariables.BarFontSize)..'|'..WerewolfTimerBar.SavedVariables.BarFontStyle..'') end,
		},
		{
			type = "dropdown",
			name = "Select Font Style",
			tooltip = "Changes the font style",
			choices = {"outline","thin-outline","thick-outline","shadow","soft-shadow-thin","soft-shadow-thick"},
			width = "full",
			default = WerewolfTimerBar.SavedVariables.BarFontStyle,
			getFunc = function() return WerewolfTimerBar.SavedVariables.BarFontStyle end,
			setFunc = function(newValue) 
				WerewolfTimerBar.SavedVariables.BarFontStyle= newValue
				WerewolfTimerBarWindow_Label:SetFont('$('..WerewolfTimerBar.SavedVariables.BarFontName..')|'..tostring(WerewolfTimerBar.SavedVariables.BarFontSize)..'|'..WerewolfTimerBar.SavedVariables.BarFontStyle..'') end,
		},
		{
			type = "slider",
			name = "Select Font Size",
			tooltip = "Adjusts the font size",
			min = 10,
			max = 30,
			step = 1,
			default = 14,
			getFunc = function() return WerewolfTimerBar.SavedVariables.BarFontSize end,
			setFunc = function(newValue) 
				WerewolfTimerBar.SavedVariables.BarFontSize= newValue
				WerewolfTimerBarWindow_UltimateBlockButton:SetDimensions(newValue+2, newValue+2)
				WerewolfTimerBarWindow_Backdrop:SetDimensions(WerewolfTimerBar.SavedVariables.BarWidth+10, WerewolfTimerBar.SavedVariables.BarHeight+WerewolfTimerBar.SavedVariables.BarFontSize+15)
				WerewolfTimerBarWindow_Label:SetFont('$('..WerewolfTimerBar.SavedVariables.BarFontName..')|'..tostring(WerewolfTimerBar.SavedVariables.BarFontSize)..'|'..WerewolfTimerBar.SavedVariables.BarFontStyle..'') end,
		},
		{
			type = "colorpicker",
			name = "Select Bar Color",
			tooltip = "Changes the color of the bar.",
			getFunc = function() return unpack(WerewolfTimerBar.SavedVariables.BarColor) end,
			setFunc = function(r,g,b,a) 
				WerewolfTimerBar.SavedVariables.BarColor = {r, g, b, a}
				WerewolfTimerBarWindow_StatusBar:SetColor(r,  g,  b,  a) end,
		},
		{
			type = "description",
			text = "Unlock the Werewolf Timer Bar"
		},
		{
			type = "button",
			name = "Unlock",
			tooltip = "Unlock the bar for moving",
			func = function()
				WerewolfTimerBar.UnlockUI(WerewolfTimerBarWindow_LockUIButton) end,
		},
	}
	LAM2:RegisterOptionControls("Werewolf_Timer_Bar", optionsData)
end

-------------------------------------------------------------------------------------------------
--  Update UI Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.onPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	-- Update the bar on any changes --
	WerewolfTimerBarWindow_StatusBar:SetValue(powerValue)
end

function WerewolfTimerBar.OnWerewolfStateChanged(eventCode, isWerewolf)
	if isWerewolf then
		-- If werewolf then show the bar --
		local current, max, effectiveMax = GetUnitPower('player', POWERTYPE_WEREWOLF)
		WerewolfTimerBarWindow_StatusBar:SetValue(current)
		WerewolfTimerBarWindow:SetHidden(false)
	else
		WerewolfTimerBarWindow:SetHidden(true)
		WerewolfTimerBar.SavedVariables.Unlock = false
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
			WerewolfTimerBar.ShowHide()
		-- Press 'esc' --
		elseif scene == "gameMenuInGame" then
			WerewolfTimerBar.ShowHide()
		else
			-- Hide in all other mode/scene --
			WerewolfTimerBarWindow:SetHidden(true)
		end
	else
		WerewolfTimerBar.ShowHide()
	end
end

-------------------------------------------------------------------------------------------------
--  On Player Activated  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.OnPlayerActivated(eventCode, initial)
	if initial then
		WerewolfTimerBar.ShowHide()
	end
end
 
-------------------------------------------------------------------------------------------------
--  On AddOn Loaded  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerBar.OnAddOnLoaded(eventCode, addonName)
	if addonName == WerewolfTimerBar.Name then
		EVENT_MANAGER:UnregisterForEvent(WerewolfTimerBar.Name, EVENT_ADD_ON_LOADED)
		-- Save variables using LibSavedVars --
		WerewolfTimerBar.SavedVariables = LibSavedVars
			:NewAccountWide("WerewolfTimerBarVars_Account", WerewolfTimerBar.Default)
			:AddCharacterSettingsToggle("WerewolfTimerBarVars_Characters")
		-- Setup settings panel --
		WerewolfTimerBar.SetupSettingsWindow()
		-- Setup UI elements --
		WerewolfTimerBar.SetupUIElements()
		-- Setup button press for ultimate prevention --
		WerewolfTimerBar.SetupUltimateBlock()
		-- Setup ultimate lock/unlock button ---
		WerewolfTimerBar.DrawUltimateBlockButton(WerewolfTimerBarWindow_UltimateBlockButton)
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
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerBar.Name, EVENT_PLAYER_ACTIVATED, WerewolfTimerBar.OnPlayerActivated)
			-- Register event for showing and hiding UI when it's unlock or in different scenes --
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerBar.Name, EVENT_RETICLE_HIDDEN_UPDATE, WerewolfTimerBar.OnReticleHidden)
			-- Register events for werewolf updates --
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerBar.Name, EVENT_WEREWOLF_STATE_CHANGED, WerewolfTimerBar.OnWerewolfStateChanged)
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerBar.Name, EVENT_POWER_UPDATE, WerewolfTimerBar.onPowerUpdate)
			EVENT_MANAGER:AddFilterForEvent(WerewolfTimerBar.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_WEREWOLF)
			EVENT_MANAGER:AddFilterForEvent(WerewolfTimerBar.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'player')
		end	
	end
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(WerewolfTimerBar.Name, EVENT_ADD_ON_LOADED, WerewolfTimerBar.OnAddOnLoaded)