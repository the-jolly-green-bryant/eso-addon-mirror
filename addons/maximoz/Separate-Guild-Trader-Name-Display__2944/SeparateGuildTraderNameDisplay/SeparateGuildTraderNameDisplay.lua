-------------------------------------------------------------------------------------------------
--  Initialize variables --
-------------------------------------------------------------------------------------------------
SeparateGuildTraderNameDisplay = {}
SeparateGuildTraderNameDisplay.Name = "SeparateGuildTraderNameDisplay"
SeparateGuildTraderNameDisplay.Version = 1.3
SeparateGuildTraderNameDisplay.Default = 
	{
		Unlock = false,
		OffsetX = 500,
		OffsetY = 500,
		Show = true,
		Font = "BOLD_FONT",
		FontStyle = "soft-shadow-thick",
		FontSize = 18,
		FontColor = {1, 1, 1, 1}
	}
local LAM2 = LibAddonMenu2
local isRegistered = false

-------------------------------------------------------------------------------------------------
--  Save guild name display position --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.SaveLoc(Control)
	SeparateGuildTraderNameDisplay.SavedVariables.OffsetX = Control:GetLeft()
	SeparateGuildTraderNameDisplay.SavedVariables.OffsetY = Control:GetTop()
end

-------------------------------------------------------------------------------------------------
--  Lock/unlock guild name display  --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.UnlockUI(Control)
	SeparateGuildTraderNameDisplay.SavedVariables.Unlock = true
	Control:SetHidden(false)
	SeparateGuildTraderNameDisplayWindow_Backdrop:SetCenterColor(0, 0.5, 0.7, 0.32)
	SeparateGuildTraderNameDisplayWindow_Backdrop:SetEdgeColor(0, 0.5, 0.7, 1)
	SeparateGuildTraderNameDisplayWindow_Backdrop:SetHidden(false)
	SeparateGuildTraderNameDisplayWindow_Caption:SetText("Separate Guild Name Display Control")
	SeparateGuildTraderNameDisplayWindow:SetHidden(false)
end

function SeparateGuildTraderNameDisplay.ClickLockUIButton(Control)
	SeparateGuildTraderNameDisplay.SavedVariables.Unlock = false
	Control:SetHidden(true)
	SeparateGuildTraderNameDisplayWindow_Backdrop:SetHidden(true)
	SeparateGuildTraderNameDisplayWindow:SetHidden(true)
end

-------------------------------------------------------------------------------------------------
--  Settings panel setup --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.SettingsWindow()
	local panelData = {
		type = "panel",
		name = "Separate Guild Trader Name Display",
		displayName = "Separate Guild Trader Name Display",
		author = "maximoz",
		version = "1.3",
		slashCommand = "/sgtnd",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SGTND", panelData)
	
	local optionsData = {
		{
			type = "description",
			text = "Shows a separate label displaying guild trader name with options to format the text display and also reposition it."
		},
		{
			type = "header",
			name = "General Settings"
		},
		-- Account-wide/characters settings --
		SeparateGuildTraderNameDisplay.SavedVariables:GetLibAddonMenuAccountCheckbox(),
		
		-- Guild trader name display --
		{
			type = "checkbox",
			name = "Show Separate Guild Name Display",
			tooltip = "When ON, will display the guild trader name on a separate movable text control",
			default = true,
			getFunc = function() return SeparateGuildTraderNameDisplay.SavedVariables.Show end,
			setFunc = function(newValue)
				SeparateGuildTraderNameDisplay.SavedVariables.Show = newValue
				SeparateGuildTraderNameDisplay.GuildEventsRegister(SeparateGuildTraderNameDisplay.SavedVariables.Show) end,
		},
		{
			type = "dropdown",
			name = "Select Font",
			tooltip = "Changes the font name",
			choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT"},
			width = "full",
			default = SeparateGuildTraderNameDisplay.SavedVariables.Font,
			getFunc = function() return SeparateGuildTraderNameDisplay.SavedVariables.Font end,
			setFunc = function(newValue) 
				SeparateGuildTraderNameDisplay.SavedVariables.Font = newValue
				SeparateGuildTraderNameDisplayWindow_Caption:SetFont('$('..SeparateGuildTraderNameDisplay.SavedVariables.Font..')|'..tostring(SeparateGuildTraderNameDisplay.SavedVariables.FontSize)..'|'..SeparateGuildTraderNameDisplay.SavedVariables.FontStyle..'') end,
		},
		{
			type = "dropdown",
			name = "Select Font Style",
			tooltip = "Changes the font style",
			choices = {"thick-outline","soft-shadow-thick","soft-shadow-thin"},
			width = "full",
			default = SeparateGuildTraderNameDisplay.SavedVariables.FontStyle,
			getFunc = function() return SeparateGuildTraderNameDisplay.SavedVariables.FontStyle end,
			setFunc = function(newValue) 
				SeparateGuildTraderNameDisplay.SavedVariables.FontStyle= newValue
				SeparateGuildTraderNameDisplayWindow_Caption:SetFont('$('..SeparateGuildTraderNameDisplay.SavedVariables.Font..')|'..tostring(SeparateGuildTraderNameDisplay.SavedVariables.FontSize)..'|'..SeparateGuildTraderNameDisplay.SavedVariables.FontStyle..'') end,
		},
		{
			type = "slider",
			name = "Select Font Size",
			tooltip = "Adjusts the font size",
			min = 10,
			max = 30,
			step = 1,
			default = 14,
			getFunc = function() return SeparateGuildTraderNameDisplay.SavedVariables.FontSize end,
			setFunc = function(newValue) 
				SeparateGuildTraderNameDisplay.SavedVariables.FontSize= newValue
				SeparateGuildTraderNameDisplayWindow_Caption:SetFont('$('..SeparateGuildTraderNameDisplay.SavedVariables.Font..')|'..tostring(SeparateGuildTraderNameDisplay.SavedVariables.FontSize)..'|'..SeparateGuildTraderNameDisplay.SavedVariables.FontStyle..'') end,
		},
		{
			type = "colorpicker",
			name = "Select Font Color",
			tooltip = "Changes the font color",
			getFunc = function() return unpack(SeparateGuildTraderNameDisplay.SavedVariables.FontColor) end,
			setFunc = function(r,g,b,a)
				SeparateGuildTraderNameDisplay.SavedVariables.FontColor = {r, g, b, a}
				SeparateGuildTraderNameDisplayWindow_Caption:SetColor(r,  g,  b,  a) end,
		},
		{
			type = "description",
			text = "Unlock Separate Guild Name Display"
		},
		{
			type = "button",
			name = "Unlock",
			tooltip = "Unlock the UI for moving",
			func = function()
				SeparateGuildTraderNameDisplay.UnlockUI(SeparateGuildTraderNameDisplayWindow_LockUIButton) end,
		},
	}
	LAM2:RegisterOptionControls("SGTND", optionsData)
end

-------------------------------------------------------------------------------------------------
--  Update the guild name text --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.GuildTextUpdate()
	-- If npc is a guild trader --
	if IsUnitGuildKiosk("reticleover") then
		local unitCaption = GetUnitCaption("reticleover")
		SeparateGuildTraderNameDisplayWindow_Caption:SetText(unitCaption)
		SeparateGuildTraderNameDisplayWindow:SetHidden(false)
	else
		if SeparateGuildTraderNameDisplay.SavedVariables.Unlock then
			SeparateGuildTraderNameDisplayWindow:SetHidden(false)
		else
			SeparateGuildTraderNameDisplayWindow:SetHidden(true)
		end
	end
end

-------------------------------------------------------------------------------------------------
--  Event functions for displaying the guild name  --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.OnGuildIdChanged()
	SeparateGuildTraderNameDisplay.GuildTextUpdate()
end

function SeparateGuildTraderNameDisplay.OnGuildNameAvailable()
	SeparateGuildTraderNameDisplay.GuildTextUpdate()
end

function SeparateGuildTraderNameDisplay.OnReticleTargetChanged(_)
	SeparateGuildTraderNameDisplay.GuildTextUpdate()
end

-------------------------------------------------------------------------------------------------
--  Enable/disable the guild name dipslay thru events --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.GuildEventsRegister(Show)
	if Show then
		EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_RETICLE_TARGET_CHANGED, SeparateGuildTraderNameDisplay.OnReticleTargetChanged)
		EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_GUILD_NAME_AVAILABLE, SeparateGuildTraderNameDisplay.OnGuildNameAvailable)
		EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_GUILD_ID_CHANGED, SeparateGuildTraderNameDisplay.OnGuildIdChanged)
		EVENT_MANAGER:AddFilterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_GUILD_ID_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
	else
		EVENT_MANAGER:UnregisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_RETICLE_TARGET_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_GUILD_NAME_AVAILABLE)
		EVENT_MANAGER:UnregisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_GUILD_ID_CHANGED)
	end
end

-------------------------------------------------------------------------------------------------
--  Show/hide depending on scenes  --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.OnReticleHiddenUpdate(eventCode, hidden)
	if SCENE_MANAGER:GetCurrentScene() == nil then return end
	local scene = SCENE_MANAGER:GetCurrentScene():GetName()
	if hidden then
		-- Press '.' --
		if scene == "hudui" then
			-- Show if unlock button is clicked --
			if SeparateGuildTraderNameDisplay.SavedVariables.Unlock then
				SeparateGuildTraderNameDisplayWindow:SetHidden(false)
			else
				SeparateGuildTraderNameDisplayWindow:SetHidden(true)
			end
		-- Press 'esc' --
		elseif scene == "gameMenuInGame" then
			-- Using setupscene function to set this up hence do nothing here --
			--return
			if SeparateGuildTraderNameDisplay.SavedVariables.Unlock then
				SeparateGuildTraderNameDisplayWindow:SetHidden(false)
			else
				SeparateGuildTraderNameDisplayWindow:SetHidden(true)
			end
		else
			-- Hide in all other mode/scene --
			SeparateGuildTraderNameDisplayWindow:SetHidden(true)
		end
	else
		-- Show if unlock button is clicked --
		if SeparateGuildTraderNameDisplay.SavedVariables.Unlock then
			SeparateGuildTraderNameDisplayWindow:SetHidden(false)
		else
			SeparateGuildTraderNameDisplayWindow:SetHidden(true)
		end
	end
end

-------------------------------------------------------------------------------------------------
--  When logging in, porting, etc  --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.OnPlayerActivated()
	-- Show guild name is true --
	if SeparateGuildTraderNameDisplay.SavedVariables.Show then
		-- If in pvp and dungeon, disable it --
		if IsPlayerInAvAWorld() or IsActiveWorldBattleground() or IsUnitInDungeon("player") and not IsInOutlawZone() then
			SeparateGuildTraderNameDisplay.GuildEventsRegister(false)
			isRegistered = false
		else
			if isRegistered == false then
				SeparateGuildTraderNameDisplay.GuildEventsRegister(true)
				isRegistered = true
			end
		end
	else
		SeparateGuildTraderNameDisplay.GuildEventsRegister(false)
		isRegistered = false
	end
end

-------------------------------------------------------------------------------------------------
--  On addon loaded  --
-------------------------------------------------------------------------------------------------
function SeparateGuildTraderNameDisplay.OnAddOnLoaded(eventCode, addonName)
	if addonName == SeparateGuildTraderNameDisplay.Name then
		EVENT_MANAGER:UnregisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_ADD_ON_LOADED)
		-- Save variables using LibSavedVars --
		SeparateGuildTraderNameDisplay.SavedVariables = LibSavedVars
			:NewAccountWide("SeparateGuildTraderNameDisplayVars_Account", SeparateGuildTraderNameDisplay.Default)
			:AddCharacterSettingsToggle("SeparateGuildTraderNameDisplayVars_Characters")
		-- Addon settings panel setup --
		SeparateGuildTraderNameDisplay.SettingsWindow()
		-- Setup UI to game scenes --
		--SeparateGuildTraderNameDisplay.SetupScenes()
		-- Guild name display lock/unlock setup --
		SeparateGuildTraderNameDisplay.SavedVariables.Unlock = false
		-- Guild name display font setup --
		SeparateGuildTraderNameDisplayWindow_Caption:SetColor(unpack(SeparateGuildTraderNameDisplay.SavedVariables.FontColor))
		SeparateGuildTraderNameDisplayWindow_Caption:SetFont('$('..SeparateGuildTraderNameDisplay.SavedVariables.Font..')|'..tostring(SeparateGuildTraderNameDisplay.SavedVariables.FontSize)..'|'..SeparateGuildTraderNameDisplay.SavedVariables.FontStyle..'')
		-- Guild name display position setup --
		SeparateGuildTraderNameDisplayWindow:ClearAnchors()
		SeparateGuildTraderNameDisplayWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SeparateGuildTraderNameDisplay.SavedVariables.OffsetX,SeparateGuildTraderNameDisplay.SavedVariables.OffsetY)
		-- Register event for player logging in and porting --
		EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_PLAYER_ACTIVATED, SeparateGuildTraderNameDisplay.OnPlayerActivated)
		-- Register event for showing and hiding UI when it's unlock or in different scenes --
		EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_RETICLE_HIDDEN_UPDATE, SeparateGuildTraderNameDisplay.OnReticleHiddenUpdate)
	end
end
 
-------------------------------------------------------------------------------------------------
--  Register events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SeparateGuildTraderNameDisplay.Name, EVENT_ADD_ON_LOADED, SeparateGuildTraderNameDisplay.OnAddOnLoaded)