-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
WerewolfTimerIcon = {}
WerewolfTimerIcon.Name = "WerewolfTimerIcon"
WerewolfTimerIcon.Version = 2.6
WerewolfTimerIcon.Default = 
	{
		Unlock = false,
		IconOffsetX = 20,
		IconOffsetY = 75,
		IconFontColor = {1, 1, 1, 1},
		IconSize = 80,
		IconFontName = "BOLD_FONT",
		IconFontStyle = "thick-outline",
		IconFontSize = 30,
		UltimateEnable = true
	}
local LAM2 = LibAddonMenu2
local flag = true -- Flip-flop for prehook control
local text1, text2 -- Ultimate display message --

-- Create string for the key bind
ZO_CreateStringId("SI_BINDING_NAME_ICON_ULTIMATELOCK_TOGGLE", "Toggle Lock/Unlock Ultimate")	

-------------------------------------------------------------------------------------------------
--  Save UI Location Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.SaveLoc(Control)
	WerewolfTimerIcon.SavedVariables.IconOffsetX = Control:GetLeft()
	WerewolfTimerIcon.SavedVariables.IconOffsetY = Control:GetTop()
end

-------------------------------------------------------------------------------------------------
--  UI Dimension Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.SetIconSize(Size)
	WerewolfTimerIconWindow_Backdrop:SetDimensions(Size+4, Size+20+8)
	WerewolfTimerIconWindow_Icon:SetDimensions(Size-6, Size-6)
	WerewolfTimerIconWindow:SetDimensions(Size+4, Size+20+8)
	WerewolfTimerIconWindow_UltimateBlockButton:ClearAnchors()
	WerewolfTimerIconWindow_UltimateBlockButton:SetAnchor(TOPLEFT, WerewolfTimerIconWindow_Backdrop, TOPLEFT, (Size/2)-5, 5)
end

-------------------------------------------------------------------------------------------------
--  Show/Hide Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.ShowHide()
	if IsWerewolf() then
		-- If werewolf then show the icon --
		local current, max, effectiveMax = GetUnitPower('player', POWERTYPE_WEREWOLF)
		local timer = (current * 0.03)
		WerewolfTimerIconWindow_Timer:SetText(string.format('%d', timer))
		WerewolfTimerIconWindow:SetHidden(false)
	else
		if WerewolfTimerIcon.SavedVariables.Unlock then
			WerewolfTimerIconWindow:SetHidden(false)
		else
			WerewolfTimerIconWindow:SetHidden(true)
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Lock/Unlock UI Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.UnlockUI(Control)
	WerewolfTimerIcon.SavedVariables.Unlock = true
	Control:SetHidden(false)
	WerewolfTimerIconWindow:SetTopmost(true)
	WerewolfTimerIconWindow:SetHidden(false)
end

function WerewolfTimerIcon.ClickLockUIButton(Control)
	WerewolfTimerIcon.SavedVariables.Unlock = false
	Control:SetHidden(true)
	WerewolfTimerIcon.ShowHide()
end

-------------------------------------------------------------------------------------------------
--  Ultimate Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.DrawUltimateBlockButton(Control)
	if WerewolfTimerIcon.SavedVariables.UltimateEnable then
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

function WerewolfTimerIcon.ClickUltimateBlockButton(Control)
	-- Flip flop for lock and unlock state --
	WerewolfTimerIcon.SavedVariables.UltimateEnable = not WerewolfTimerIcon.SavedVariables.UltimateEnable
	-- Setup the display text --
	WerewolfTimerIcon.SetupUltimateBlockText()
	-- Display the message --
	local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, nil)
	msg:SetText(text1, text2)
	msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
	msg:MarkSuppressIconFrame()
	CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
	d(string.format("%s %s", text1, text2))
	-- Update the button texture --
	WerewolfTimerIcon.DrawUltimateBlockButton(Control)
end

function WerewolfTimerIcon.SetupUltimateBlockText()
	-- Get keybinding --
	local keyBind = ZO_Keybindings_GetHighestPriorityBindingStringFromAction("ICON_ULTIMATELOCK_TOGGLE")
	-- Change text message depending on lock/unlock state --
	if WerewolfTimerIcon.SavedVariables.UltimateEnable then
		text1 = "Werewolf Timer Icon: Ultimate BLOCKED!"
		if keyBind then
			text2 = string.format("%s %s %s %s", "Click the lock in the top middle of the addon", "or press [", keyBind, "] to change.")
		else
			text2 = "Click the lock in the top middle of the addon to change or set a keybind to toggle this."
		end
	else
		text1 = "Werewolf Timer Icon: Ultimate UNBLOCKED!"
		if keyBind then
			text2 = string.format("%s %s %s %s", "Click the unlock in the top middle of the addon", "or press [", keyBind, "] to change.")
		else
			text2 = "Click the unlock in the top middle of the addon to change or set a keybind to toggle this."
		end
	end
end

function WerewolfTimerIcon.SetupUltimateBlock()
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
		-- Use a flag since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast --
  		flag = not flag
		-- Ultimate blocking set to true and is a werewolf --
		if WerewolfTimerIcon.SavedVariables.UltimateEnable and IsWerewolf() then
			-- Get the slot number for the actionbar button pressed --
			slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)'))
			-- Ultimate button pressed --
			if slotNum == 8 then
				-- Just one message broadcast since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast --
				if flag then
					WerewolfTimerIcon.SetupUltimateBlockText()
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
--  Setup UI Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.SetupUIElements()
	WerewolfTimerIcon.SavedVariables.Unlock = false
	-- Lock UI button --
	WerewolfTimerIconWindow_LockUIButton:SetHidden(true)
	WerewolfTimerIconWindow_LockUIButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Lock the UI") end)
    WerewolfTimerIconWindow_LockUIButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
	-- Block ultimate button --
	WerewolfTimerIconWindow_UltimateBlockButton:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Enable/disable ultimate button keypress") end)
	WerewolfTimerIconWindow_UltimateBlockButton:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
	-- Icon --
	local texture, weptexture, actAnimation = GetSlotTexture(8)
	WerewolfTimerIconWindow_Icon:SetTexture(texture)
	-- Timer --
	WerewolfTimerIconWindow_Timer:SetFont('$('..WerewolfTimerIcon.SavedVariables.IconFontName..')|'..tostring(WerewolfTimerIcon.SavedVariables.IconFontSize)..'|'..WerewolfTimerIcon.SavedVariables.IconFontStyle..'')
	WerewolfTimerIconWindow_Timer:SetColor(unpack(WerewolfTimerIcon.SavedVariables.IconFontColor))
	WerewolfTimerIcon.SetIconSize(WerewolfTimerIcon.SavedVariables.IconSize)
	-- Position --
	WerewolfTimerIconWindow:ClearAnchors()
	WerewolfTimerIconWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WerewolfTimerIcon.SavedVariables.IconOffsetX, WerewolfTimerIcon.SavedVariables.IconOffsetY)
end

-------------------------------------------------------------------------------------------------
--  Settings Panel Setup Function --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.SetupSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Werewolf Timer Icon",
		displayName = "Werewolf Timer Icon",
		author = "maximoz",
		version = "2.6",
		slashCommand = "/wwticon",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Werewolf_Timer_Icon", panelData)

	local optionsData = {
		{
			type = "description",
			text = "This addon contains an icon with a timer and prevention for pressing the ultimate when playing a werewolf."
		},
		{
			type = "header",
			name = "General Settings"
		},
		-- Account/Characters savedvariables settings --
		WerewolfTimerIcon.SavedVariables:GetLibAddonMenuAccountCheckbox(),

		-- Icon settings --
		{
			type = "slider",
			name = "Select Icon Size",
			tooltip = "Adjusts the size",
			min = 40,
			max = 100,
			step = 1,
			default = 300,
			getFunc = function() return WerewolfTimerIcon.SavedVariables.IconSize end,
			setFunc = function(newValue) 
				WerewolfTimerIcon.SavedVariables.IconSize = newValue
				WerewolfTimerIcon.SetIconSize(newValue) end,
		},
		{
			type = "dropdown",
			name = "Select Font Name",
			tooltip = "Changes the font name",
			choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
			width = "full",
			default = WerewolfTimerIcon.SavedVariables.IconFontName,
			getFunc = function() return WerewolfTimerIcon.SavedVariables.IconFontName end,
			setFunc = function(newValue) 
				WerewolfTimerIcon.SavedVariables.IconFontName= newValue
				WerewolfTimerIconWindow_Timer:SetFont('$('..WerewolfTimerIcon.SavedVariables.IconFontName..')|'..tostring(WerewolfTimerIcon.SavedVariables.IconFontSize)..'|'..WerewolfTimerIcon.SavedVariables.IconFontStyle..'') end,
		},
		{
			type = "dropdown",
			name = "Select Font Style",
			tooltip = "Changes the font style",
			choices = {"outline","thin-outline","thick-outline","shadow","soft-shadow-thin","soft-shadow-thick"},
			width = "full",
			default = WerewolfTimerIcon.SavedVariables.IconFontStyle,
			getFunc = function() return WerewolfTimerIcon.SavedVariables.IconFontStyle end,
			setFunc = function(newValue) 
				WerewolfTimerIcon.SavedVariables.IconFontStyle= newValue
				WerewolfTimerIconWindow_Timer:SetFont('$('..WerewolfTimerIcon.SavedVariables.IconFontName..')|'..tostring(WerewolfTimerIcon.SavedVariables.IconFontSize)..'|'..WerewolfTimerIcon.SavedVariables.IconFontStyle..'') end,
		},
		{
			type = "slider",
			name = "Select Font Size",
			tooltip = "Adjusts the font size",
			min = 10,
			max = 60,
			step = 1,
			default = 30,
			getFunc = function() return WerewolfTimerIcon.SavedVariables.IconFontSize end,
			setFunc = function(newValue) 
				WerewolfTimerIcon.SavedVariables.IconFontSize= newValue
				WerewolfTimerIconWindow_Timer:SetFont('$('..WerewolfTimerIcon.SavedVariables.IconFontName..')|'..tostring(WerewolfTimerIcon.SavedVariables.IconFontSize)..'|'..WerewolfTimerIcon.SavedVariables.IconFontStyle..'') end,
		},
		{
			type = "colorpicker",
			name = "Select Font Color",
			tooltip = "Changes the color of the timer.",
			getFunc = function() return unpack(WerewolfTimerIcon.SavedVariables.IconFontColor) end,
			setFunc = function(r,g,b,a) 
				WerewolfTimerIcon.SavedVariables.IconFontColor = {r, g, b, a}
				WerewolfTimerIconWindow_Timer:SetColor(r,  g,  b,  a) end,
		},
		{
			type = "description",
			text = "Unlock the UI"
		},
		{
			type = "button",
			name = "Unlock",
			tooltip = "Unlock the icon for moving",
			func = function()
				WerewolfTimerIcon.UnlockUI(WerewolfTimerIconWindow_LockUIButton) end,
		},
	}
	LAM2:RegisterOptionControls("Werewolf_Timer_Icon", optionsData)
end

-------------------------------------------------------------------------------------------------
--  Update UI Functions --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.onPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	-- Update the time on any changes --
	local timer = (powerValue * 0.03)
	WerewolfTimerIconWindow_Timer:SetText(string.format('%d', timer))
end

function WerewolfTimerIcon.OnWerewolfStateChanged(eventCode, isWerewolf)
	if isWerewolf then
		-- If werewolf then show the icon --
		local current, max, effectiveMax = GetUnitPower('player', POWERTYPE_WEREWOLF)
		local timer = (current * 0.03)
		WerewolfTimerIconWindow_Timer:SetText(string.format('%d', timer))
		WerewolfTimerIconWindow:SetHidden(false)
	else
		WerewolfTimerIconWindow:SetHidden(true)
	end
end

-------------------------------------------------------------------------------------------------
--  On Reticle Hidden  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.OnReticleHidden(eventCode, hidden)
	if SCENE_MANAGER:GetCurrentScene() == nil then return end
	local scene = SCENE_MANAGER:GetCurrentScene():GetName()
	if hidden then
		-- Press '.' --
		if scene == "hudui" then
			WerewolfTimerIcon.ShowHide()
		-- Press 'esc' --
		elseif scene == "gameMenuInGame" then
			WerewolfTimerIcon.ShowHide()
		else
			-- Hide in all other mode/scene --
			WerewolfTimerIconWindow:SetHidden(true)
		end
	else
		WerewolfTimerIcon.ShowHide()
	end
end

-------------------------------------------------------------------------------------------------
--  On Player Activated  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.OnPlayerActivated(eventCode, initial)
	if initial then
		WerewolfTimerIcon.ShowHide()
	end
end

-------------------------------------------------------------------------------------------------
--  On AddOn Loaded  --
-------------------------------------------------------------------------------------------------
function WerewolfTimerIcon.OnAddOnLoaded(eventCode, addonName)
	if addonName == WerewolfTimerIcon.Name then
		EVENT_MANAGER:UnregisterForEvent(WerewolfTimerIcon.Name, EVENT_ADD_ON_LOADED)
		-- Save variables using LibSavedVars --
		WerewolfTimerIcon.SavedVariables = LibSavedVars
			:NewAccountWide( "WerewolfTimerIconVars_Account", WerewolfTimerIcon.Default )
			:AddCharacterSettingsToggle( "WerewolfTimerIconVars_Characters" )
		-- Setup settings panel --
		WerewolfTimerIcon.SetupSettingsWindow()
		-- Setup UI elements --
		WerewolfTimerIcon.SetupUIElements()
		-- Setup button press for ultimate prevention --
		WerewolfTimerIcon.SetupUltimateBlock()
		-- Setup ultimate lock/unlock button ---
		WerewolfTimerIcon.DrawUltimateBlockButton(WerewolfTimerIconWindow_UltimateBlockButton)
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
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerIcon.Name, EVENT_PLAYER_ACTIVATED, WerewolfTimerIcon.OnPlayerActivated)
			-- Register event for showing and hiding UI when it's unlock or in different scenes --
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerIcon.Name, EVENT_RETICLE_HIDDEN_UPDATE, WerewolfTimerIcon.OnReticleHidden)
			-- Register events for werewolf updates --
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerIcon.Name, EVENT_WEREWOLF_STATE_CHANGED, WerewolfTimerIcon.OnWerewolfStateChanged)
			EVENT_MANAGER:RegisterForEvent(WerewolfTimerIcon.Name, EVENT_POWER_UPDATE, WerewolfTimerIcon.onPowerUpdate)
			EVENT_MANAGER:AddFilterForEvent(WerewolfTimerIcon.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_WEREWOLF)
			EVENT_MANAGER:AddFilterForEvent(WerewolfTimerIcon.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'player')
		end
	end
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(WerewolfTimerIcon.Name, EVENT_ADD_ON_LOADED, WerewolfTimerIcon.OnAddOnLoaded)