--[[
- - - 2.4.6
○ fixed missing rapport amount in loot history

- - - 2.4.5
○ fixed missing rapport icon

- - - 2.4.4
○ fixed custom role for player indicators
○ fixed displayed xp when companion is at max level.

- - - 2.4.3
○ changed selection name for custom frame from ZOS to localized 'Custom'.
○ put register filter for events inside a loop.
○ fixed BUI optional settings style index to = 'BUI' not == 'BUI'

- - - 2.4.2
○ compatibility update.
	removing requirement for the experimental library

- - - 2.4.1
○ compatibility update.

- - - 2.4
○ added French translation courtesy of fzr6n7
○ updated for API 101034.
○ implemented support for LibHaF

○ 
]]

local defaults = {
	displayName = GetString(SI_IJA_MCF_Title),
	name = "IsJustaCompanionUI",
	version = "2.4.6",
	visibility = 0,
	account = true,
	locked = false,
	occupancy = 100,
	frameScale = 100,
	priUpdate = 10,
	
	valueStyle = 1,
	valueFormat = 0,
	selectedFrameStyle = 1,
	
	anchor = ZO_Anchor:New(TOPLEFT, ZO_SmallGroupAnchorFrame, TOPLEFT, 70, 60),
	healthGradient = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
	shieldGradient ={ZO_ColorDef:New(.25, .25, .5, 1), ZO_ColorDef:New(.5, .5, 1, .5)}
}
local svVersion = 2.3

-------------------
-- Initialize
-------------------
local Companion_UI = ZO_InitializingObject:Subclass()

function Companion_UI:Initialize(control)
	self.control = control
	self.displayName	= defaults.displayName
	self.name 			= defaults.name
	self.version 		= defaults.version
	
	self.customFrames	= {}
	local function OnLoaded(_, name)
		if name ~= defaults.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		local savedVars = ZO_SavedVars:NewAccountWide("IJA_CompanionUI_SavedVars", svVersion, nil, defaults, GetWorldName())
		
		if not savedVars.account then
			savedVars = ZO_SavedVars:New("IJA_CompanionUI_SavedVars", svVersion, nil, defaults, GetWorldName())
		end
		
		if not savedVars.anchors then savedVars.anchors = {} end
		self.savedVars = savedVars
		self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function(eventCode, ...) self:OnPlayerActivated(...) end)
		
		self.companionFrames = IJA_CompanionFrames_Initialize(self)
		self.companionOverview = IJA_CompanionOverview_Initialize(self)
		self.companionIndicator = IJA_CompanionIndicator_Initialize(self)
		
	end
    control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
end

function Companion_UI:OnPlayerActivated()
	self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
--	d( self.displayName .. " version: " .. self.version)
	
	local UNIT_FRAMES_FRAGMENT = ZO_HUDFadeSceneFragment:New(IJA_CompanionUnit)
	HUD_SCENE:AddFragment(UNIT_FRAMES_FRAGMENT)
	HUD_UI_SCENE:AddFragment(UNIT_FRAMES_FRAGMENT)
	
	self:InitializeSettings()
	self:PerformDeferredInitialization()
end

function Companion_UI:PerformDeferredInitialization()
	self.companionFrames:PerformDeferredInitialization()
	self.companionOverview:PerformDeferredInitialization()
	self.companionIndicator:PerformDeferredInitialization()
end

-----------------
-- Settings
-----------------
function Companion_UI:InitializeSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then return end
	
	local panelData = {
		type = "panel",
		name = self.displayName,
		displayName = self.displayName,
		author = "IsJustaGhost",
		version = self.version,
        registerForDefaults = true,
		registerForRefresh = true,
	}
	local optionsPanel = LAM2:RegisterAddonPanel(self.name, panelData)
	
	local optionsTable = {
		{ type = "header",
 --		   name = GetString(),
			width = "full",
		},
		{ type = "checkbox",	-- account saves
            name = GetString(SI_IJA_MCF_ACCOUNT),
			tooltip = GetString(SI_IJA_MCF_ACCOUNT_TOOLTIP),
            getFunc = function()
                return self.savedVars.account
            end,
            setFunc = function(value)
                self.savedVars.account = value
            end,
            width = "full",
			requiresReload = true,
        },
		self.companionFrames:GetFrameOptions(),
		self.companionIndicator:GetSettings(),
	}
	LAM2:RegisterOptionControls(self.name, optionsTable)
end

function IJA_CompanionUI_Initialize( ... )
	IJA_COMPANION_UI = Companion_UI:New( ... )
end





---------------------------------------------------------------------------------------------------------------
-- Temporary 
---------------------------------------------------------------------------------------------------------------
--[[
/script IsJustaCompanionUI_Options:RegisterForEvent("StateChange", function(oldState, newState) end)

]]

