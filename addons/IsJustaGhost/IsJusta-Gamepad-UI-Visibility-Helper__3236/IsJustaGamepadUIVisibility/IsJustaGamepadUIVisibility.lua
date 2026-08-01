--[[

- - -1.9.5
○ Fixed dinamic chat.

- - -1.9.4
○ removed debug output

- - -1.9.3
○ improved chat position updating. 
- Chat should no longer try to show prematurely.

- - -1.9.2
○ improved chat position updating. 
- Chat should now position properly for gamepad dialogues.

- - -1.9.1
○ HUD meters preview hides, if showing, when settings is closed.

- - -1.9
○ Re-wrote most of the addon
○ added: if chat window is told to open while closing, it will fully close then open automatically in order to open to the correct position.
○ improved: previews for, LootHistory and HUD meters
○ added: options to toggle show preview for LootHistory and HUD meters

- - -1.8.3
○ improved lootHidsory font size line width handeling

- - -1.8.2
○ removed debug output

- - -1.8.1
○ added standard keyboad loothistory setting to disable custom on set
○ Fixed keyboard lootHidsory from not showing when directly setting from use "Use modded Keyboard Loot History".
○ Fixed/improved HUD meter moving
○ Added previews for the HUD meters

- - -1.8
○ rewrote the loot history. now uses a cloned keyboard loot history.
○ added option to use the standard keyboard loot history.
- options are: use custom keyboard, use standard keyboard, if those are off, use standard gamepad. 
○ Custom keyboard and standard gamepad both are effected by the font changes.

- - -1.7
○ Chat will no longer pass the right edge of the screen and come back for scenes such as Mail
○ Chat should no longer reset position if scene has shown while chat was moving.

- - -1.6.1
○ removed debug text output.

- - -1.6
○ updated api version to 101038
○ improved hud meters platform change functionality
○ improved loot history functionality

- - -1.5
○ updated to U38 api
○ added a reset anchor to chat for when it is supposed to be back in it's original position 
-- to prevent chat from ending up off screen or other positions when it shouldn't be

- - -1.4
○ improved chat repositioning
-- attempt to fix chat getting reset in the wrong place
○ fixed chat positioning not working properly in housing editor.

- - -1.3.2
○ fixed error caused by addition of "rapport adjustment Type" when adjusting loot history settings.

- - -1.3.1
○ added support for gamepad dialogues.

- - -1.3
○ updated for API 101034.

1.2
○ user:/AddOns/IsJustaGamepadUIVisibility/IsJustaGamepadUIVisibility.lua:242: function expected instead of nil - should now be fixed
○ added French translation courtesy of fzr6n7
○ rewrote loot history and dynamic chat window position - mainly just changed the	 format of the code for loot history
○ improved chat position handling.
	- it no longer uses update loops to watch for changing UI elements. 
	- should not "bounce" if chat was closed prior to returning back to HUD
	- stopped screen flash caused by re-anchoring when chat was already in saved position
○ added some support for KelapadUI
○ added simple move.

○ ----------------------
○ improved loot history handling, will now enable/disable properly
○ demo loot will now be visible in options when making a change to loot history options
○ loot history should now appear over other elements
○ loot history row dimensions are now dynamically set based on font size and text height
○ ----------------------
○ added ability to move hud meters (Telvar, Infamy, and Daedric energy)

1.2.2
○ fixed error /EsoUI/Libraries/Globals/Globals.lua:128: operator < is not supported for number < nil


campaigns initially breaks position

loot history line height not matching up for crafting materials - with statusIcon


i joined a group. traveled to leader. not sure the cause, but when i went to look thru my inventory positioning was not working
had position not work for crown crate scene


check instant positioning on settings change
currently it is direct anchor
do i want it to slide 

]]

local addonInfo = {
	displayName = "|cFF00FFIsJusta|r |cffffffGamepad UI Visibility Helper|r",
	name = "IsJustaGamepadUIVisibility",
	version = "1.9.4",
}

local STATE_DISABLED = 0
local STATE_ENABLED = 1
local STATE_EXTRA = 2

local defaults = {
	lootHistoryOverlayFont = "ZoFontGamepad22",
	lootHistoryLabelFont = "ZoFontGamepad22",
	dynamicChatPosition = STATE_DISABLED,
	moveLootHistory = STATE_DISABLED,
	moveHudMeters = STATE_DISABLED,
	moveLootHistoryPreview = true,
	moveHudMetersPreview = true,
--	scale = 1,
}

local svVersion = 2

local isGamepadMode

--local options = {'moveLootHistory', 'dynamicChatPosition', 'moveHudMeters', 'resizeActionBar'}
local options = {'moveLootHistory', 'dynamicChatPosition', 'moveHudMeters'}

local boolToNumber = {
	[false] = STATE_DISABLED,
	[true] = STATE_ENABLED,
}

local toggleOptions = {
	['dynamicChatPosition'] = function(self, state)
		if not self.chatPosition then
			self.chatPosition = IJA_GamepadUIVisibility_ChatPosition_Initialize()
		end
		self.chatPosition:SetState(state)
	end,
	['moveLootHistory'] = function(self, state)
		if not self.lootHistory then
			self.lootHistory = IJA_GamepadUIVisibility_LootHistory_Initialize()
		end
		
		self.lootHistory:UpdateFonts(self.savedVars)
		self.lootHistory:SetState(state)
	end,
	['moveHudMeters'] = function(self, state)
		if not self.hudMeters then
			self.hudMeters = IJA_GamepadUIVisibility_MoveHudMeters_Initialize()
		end
		self.hudMeters:SetState(state)
	end,
	['resizeActionBar'] = function(self, enabled)
	--d( enabled)
		local scale = enabled and self.savedVars.scale or 1
	--d( scale)
		ZO_ActionBar1:SetScale(scale)
	end,
}

local fontList = {
	[1] = "ZoFontGamepad18",
	[2] = "ZoFontGamepad20",
	[3] = "ZoFontGamepad22",
	[4] = "ZoFontGamepad25",
	[5] = "ZoFontGamepad27",
	[6] = "ZoFontGamepad34",
	[7] = "ZoFontGamepad36",
	[8] = "ZoFontGamepad42",
}

local fontSizes = {}
do
	local fontFormatter = string.format('%s %%s', GetString(SI_CHAT_OPTIONS_FONT_SIZE))
	for k, fontString in ipairs(fontList) do
		fontSizes[#fontSizes + 1] = string.format(fontFormatter, fontString:match('%d+'))
	end
end

local function showPreview(self, show)
	if not SCENE_MANAGER:GetScene("gameMenuInGame"):IsShowing() then return end

	if self ~= nil then
		self:ShowPreview(show)
	end
end

local function toggleAll(self)
	for _, option in pairs(options) do
		self:ToggleOption(option)
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

local addon = ZO_InitializingObject:Subclass()

function addon:Initialize(control)
	self.control = control
	zo_mixin(self, addonInfo)
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		self.savedVars = ZO_SavedVars:NewAccountWide("IJA_GamepadUIVisibility_SavedVars", svVersion, nil, defaults, GetWorldName())
		
		local function onPlayerActivated()
			control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
			local function onGamepadPreferredModeChanged()
				isGamepadMode = IsInGamepadPreferredMode()

				toggleAll(self)
			end
			ZO_PlatformStyle:New(onGamepadPreferredModeChanged)
		
			self:SetupSettings()
		--	d( self.displayName .. " version: " .. self.version)
		end
		control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	end
    control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
end

--------------------------------------------------------------------------------
-- Toggle features
--------------------------------------------------------------------------------

function addon:ToggleOption(option)
	local state = self.savedVars[option]
	
	if not isGamepadMode then
		state = STATE_DISABLED
	elseif type(state) == 'bool' then
		state = boolToNumber[state]
	end

	self:Toggle(option, state)
end

function addon:GetToggleFunction(option)
	return toggleOptions[option]
end

function addon:Toggle(option, state)
	self:GetToggleFunction(option)(self, state)
end

-------------------------------------------------------------
-- Settings menu
--------------------------------------------------------------------------------

function addon:SetupSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then
		return
	end
	
	local function updateFont(option, value)
		self.savedVars[option] = value
		if self.lootHistory then
			self.lootHistory:UpdateFonts(self.savedVars)
			showPreview(self.lootHistory, self.savedVars.moveLootHistoryPreview)
		end
	end
	
	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel(self.name .. '_LAM', panelData)

	local optionsTable = {
		{ type = "dropdown", -- SI_IJA_DYNAMIC_CHAT
			name 	= GetString(SI_IJA_DYNAMIC_CHAT),
			tooltip = GetString(SI_IJA_DYNAMIC_CHAT_TOOLTIP),
			choices = { GetString(SI_ADDONLOADSTATE3), GetString(SI_GROUPFINDERCATEGORY6), GetString(SI_IJA_SIMPLE_CHAT)},
			choicesValues = {STATE_DISABLED, STATE_ENABLED, STATE_EXTRA},
			getFunc = function() return self.savedVars.dynamicChatPosition end,
			setFunc = function(value)
				self.savedVars.dynamicChatPosition = value
				self:ToggleOption('dynamicChatPosition')
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "dropdown", -- SI_IJA_LOOTHISTORY_MOVE
			name 	= GetString(SI_IJA_LOOTHISTORY_MOVE),
			tooltip = GetString(SI_IJA_DYNAMIC_CHAT_TOOLTIP),
			choices = { GetString(SI_ADDONLOADSTATE3), GetString(SI_GROUPFINDERCATEGORY6), GetString(SI_GROUPFINDERPLAYSTYLE1)},
			choicesValues = {STATE_DISABLED, STATE_ENABLED, STATE_EXTRA},
			getFunc = function() return self.savedVars.moveLootHistory end,
			setFunc = function(value) 
				self.savedVars.moveLootHistory = value
				self:ToggleOption('moveLootHistory')
				showPreview(self.lootHistory, self.savedVars.moveLootHistoryPreview)
			end,
			width = "half",
		},
		{ type = "checkbox", -- moveLootHistoryPreview
			name = GetString(SI_GAMECAMERAACTIONTYPE25),
			getFunc = function() return self.savedVars.moveLootHistoryPreview end,
			setFunc = function(value) 
				self.savedVars.moveLootHistoryPreview = value
				showPreview(self.lootHistory, value)
			end,
			width = "half",
		},
		{ type = "dropdown", -- SI_IJA_LOOTHISTORY_FONTS_OVERLAY
			reference = "IJA_GamepadUIVisibility_OverlayFont",
			choices = fontSizes,
			choicesValues = fontList,
			name = GetString(SI_IJA_LOOTHISTORY_FONTS_OVERLAY),
			getFunc = function() return self.savedVars.lootHistoryOverlayFont end,
			setFunc = function(value)
				updateFont('lootHistoryOverlayFont', value)
			end,
			width = "half",
			disabled = function() return self.savedVars.moveLootHistory >  STATE_ENABLED end,
		},
		{ type = "dropdown", -- SI_IJA_LOOTHISTORY_FONTS_LABEL
			reference = "IJA_GamepadUIVisibility_LabelFont",
			choices = fontSizes,
			choicesValues = fontList,
			name = GetString(SI_IJA_LOOTHISTORY_FONTS_LABEL),
			getFunc = function() return self.savedVars.lootHistoryLabelFont end,
			setFunc = function(value)
				updateFont('lootHistoryLabelFont', value)
			end,
			width = "half",
			disabled = function() return self.savedVars.moveLootHistory >  STATE_ENABLED end,
		},
		{ type = "divider",
			height = 10,
		},
		{ type = "checkbox", -- SI_IJA_HUDMETERS_MOVE
			name = GetString(SI_IJA_HUDMETERS_MOVE),
			tooltip = GetString(SI_IJA_HUDMETERS_MOVE_TOOLTIP),
			getFunc = function() return self.savedVars.moveHudMeters end,
			setFunc = function(value)
				self.savedVars.moveHudMeters = boolToNumber[value]
				self:ToggleOption('moveHudMeters')
				showPreview(self.hudMeters, self.savedVars.moveHudMetersPreview)
			end,
			width = "half",
		},
		{ type = "checkbox", -- moveHudMetersPreview
			name = GetString(SI_GAMECAMERAACTIONTYPE25),
			getFunc = function() return self.savedVars.moveHudMetersPreview end,
			setFunc = function(value)
				self.savedVars.moveHudMetersPreview = value
				showPreview(self.hudMeters, value)
			end,
			width = "half",
		},
		--[[
		{ type = "divider",
			height = 10,
		},
		{ type = "slider",		-- actionBar scale
            name = GetString(SI_IJA_HUDMETERS_MOVE),
			tooltip = GetString(SI_IJA_HUDMETERS_MOVE_TOOLTIP),
			min = 0.2,
			max = 2,
			step = 0.1,
			decimals = 1,
			getFunc = function() return self.savedVars.scale end,
			setFunc = function(value)
				self.savedVars.scale = value
				self:ToggleOption('resizeActionBar')
			end,
			width = "full",
		},
		]]
	}
	LAM2:RegisterOptionControls(self.name .. '_LAM', optionsTable)
end

--------------------------------------------------------------------------------
-- XML Handlers
--------------------------------------------------------------------------------

function IJA_GamepadUIVisibility_Initialize(...)
	IJA_GAMEPADUIVISIBILITY = addon:New(...)
end

--[[
	/script IJA_GAMEPADUIVISIBILITY.lootHistory:ShowPreview(true)
	/script IJA_GAMEPADUIVISIBILITY.hudMeters:ShowPreview(true)
]]