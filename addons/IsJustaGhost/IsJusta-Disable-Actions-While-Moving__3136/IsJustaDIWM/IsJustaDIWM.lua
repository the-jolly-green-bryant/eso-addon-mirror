--[[



- - - 2.1.1
○ fixed error "IsJustaDIWM.lua:151: function expected instead of nil"
○ fixed the lib name in the addon description on esoui
○ fixed some translations with google
○ add optional feature to hide interaction

- - - 2.1
○ Updated for updated LibInteractionHook

- - - 2
○ now uses LibInteractionHook to disable actions

- - - 1.5
○ fixed options error on adjusting "Other interactions"
○ the setting, optional subcategory, state now reflects "Other interactions" state

- - - 1.4.2
○ compatibility update.
	removed requirement for the experimental library


- - - 1.4.1
○ compatibility update.
- - - 1.4
○ updated for API 101034.
○ implemented support for LibHaF
○ fixed OnLoaded

1.3.1
○ removed time from chat
○ added French translation courtesy of fzr6n7
]]

local addonData = {
	displayName = GetString(SI_IJA_DIWM_Title),
	name = "IsJustaDIWM",
	prefix = "IJA_DIWM",
	version = "2.1.1",
}

local defaults = {
	delay = {},
	optional = {},
	disableOthers = false,
	disableCompanion = false,
}

local svVersion = 1.3

local OPTION_FEATURE_RETICLE	= 1
local OPTION_FEATURE_CROUCHED	= 2
local OPTION_FEATURE_DUNGEONS	= 3
local OPTION_FEATURE_PVP		= 4
local OPTION_FEATURE_HIDE		= 5

local NUM_OPTIONALS = 5
	
local IS_IN_DUNGEON = false
local IS_IN_PVP		= false

local function setInDungeonOrPVP()
	-- set these here so they are not constantly running
	IS_IN_DUNGEON = IsUnitInDungeon("player") 
	IS_IN_PVP = IsUnitPvPFlagged("player")
end

local actionsTable = {
	-- action name = settings key
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 1)]	= 1,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 2)]	= 2,
	
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 28)]	= 3,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 29)]	= 3,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 30)]	= 3,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 31)]	= 3,
	
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 4)]	= 4,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 5)]	= 5,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 6)]	= 6,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 7)]	= 7,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 12)]	= 12,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 13)]	= 13,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 15)]	= 15,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 16)]	= 16,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 19)]	= 19,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 20)]	= 20,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 24)]	= 24,
	[GetString("SI_LIB_IF_GAMECAMERAACTION", 27)]	= 27,
}

local g_reticle = RETICLE

local registerOnTryHandlingInteraction = LibInteractionHook.RegisterOnTryHandlingInteraction
local hideInteraction = LibInteractionHook.HideInteraction

--[[
/script for i=1, 100 do d(GetCompanionCollectibleId(i)) end


local companions = {}

local function getNextCompanion(companionId)
    return companionId + 1, GetCompanionCollectibleId(companionId)
end

local function buildCompanionList()
	-- Dynamically create the companions list.
	local INITITIAL_COMPANION_ID = 1
	local skipped = 0
	local companionId, collectibleId = getNextCompanion(INITITIAL_COMPANION_ID)
	repeat
		companions[ZO_CachedStrFormat("<<C:1>>", GetCollectibleName(collectibleId))] = true
        companionId, collectibleId = getNextCompanion(companionId)
		skipped = collectibleId == 0 and skipped + 1 or 0
	until skipped == 11
end

]]

local addon = ZO_InitializingCallbackObject:Subclass()

-------------------
-- Initialize
-------------------
-- update saves
function addon:Initialize(control)
	self.control 		= control
	zo_mixin(self, addonData)
	
	local function OnLoaded(_, name)
		if name ~= self.name then return end
		self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
		
		local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJA_DIWM_SavedVars", svVersion, nil, defaults, GetWorldName())
		self.savedVars = AccountWideSavedVars
		
		self:InitializeSettings()
		self:InitializeHooks()
	end
    control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
	
	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	--	d( self.displayName .. " version: " .. self.version)
		
	--	buildCompanionList()
		setInDungeonOrPVP()
		self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function(eventCode, ...) self:OnPlayerActivated(...) end)
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

function addon:OnPlayerActivated()
	setInDungeonOrPVP()
end

-----------------
-- Settings
-----------------
local function GetMenuItemList()
	return {
		LIB_IF_GAMECAMERAACTION_SEARCH,		-- Search - loot
		LIB_IF_GAMECAMERAACTION_TALK,			-- Talk
		LIB_IF_GAMECAMERAACTION_HARVEST,		-- Harvest (Mine, Collect)
		LIB_IF_GAMECAMERAACTION_DISARM,		-- Disarm
		LIB_IF_GAMECAMERAACTION_USE,			-- Use
		LIB_IF_GAMECAMERAACTION_READ,			-- Read
		LIB_IF_GAMECAMERAACTION_TAKE,			-- Take
		LIB_IF_GAMECAMERAACTION_UNLOCK,		-- Unlock
		LIB_IF_GAMECAMERAACTION_OPEN,			-- Open
		LIB_IF_GAMECAMERAACTION_EXAMINE,		-- Examine
		LIB_IF_GAMECAMERAACTION_FISH,			-- Fish
		LIB_IF_GAMECAMERAACTION_STEAL,		-- Steal
		LIB_IF_GAMECAMERAACTION_STEALFROM,	-- Steal from
		LIB_IF_GAMECAMERAACTION_HIDE,			-- Hide
		LIB_IF_GAMECAMERAACTION_EXCAVATE		-- Excavate
	}
end

function addon:InitializeSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then return end
	
	local panelData = {
		type = "panel",
		name = self.displayName,		-- list name
		displayName = self.displayName, -- header
		author = "IsJustaGhost",
		version = self.version,
        registerForDefaults = true,
		registerForRefresh = true,
	}
	
    LAM2:RegisterAddonPanel(self.name .. '_LAM', panelData)
	
	local ignoreActions_Subcategory = self.name .. "_IgnoreActions_LAM"
	
	local function disableAllOthers()
		for option=1, NUM_OPTIONALS do
		end
	end
	
	local optionsTable = {
		{
			type = "header",
 			name = '',
			width = "full",
		},
		{
			type = "checkbox",
			name 	= GetString(SI_IJA_DIWM_DISABLEINTERACT),
			tooltip = GetString(SI_IJA_DIWM_DISABLEINTERACT_TIP),
			getFunc = function() return self.savedVars.disableCompanion end,
			setFunc = function(value) self.savedVars.disableCompanion = value end,
			width = "half",
		},{
			type = "slider",		-- transparency
			name = '',
			min = 0.1,
			max = 10,
			step = 0.1,
			decimals = 1,
			getFunc = function() return self.savedVars.companionDelay end,
			setFunc = function(value) self.savedVars.companionDelay = value
			end,
			width = "half",
			disabled = function() return not self.savedVars.disableCompanion end,
	
		},
		{
			type = "checkbox",
			name 	= GetString(SI_IJA_DIWM_DISABLEMORE),
			tooltip = GetString(SI_IJA_DIWM_DISABLEMORE_TIP),
			getFunc = function() return self.savedVars.disableOthers end,
			setFunc = function(value) 
				self.savedVars.disableOthers = value
			end,
			width = "full",
		},
		{
			type = "divider",
			height = 10,
		},
		self:CreateMenuForOthers(),
		{
			type = "divider",
			height = 10,
		},
		self:CreateMenuForOptions(),
	}
	LAM2:RegisterOptionControls(self.name .. '_LAM', optionsTable)
end

function addon:CreateMenuForOthers()
	local itemList = GetMenuItemList()
	local displays = {}
	local values = {}
	
    if (not self.savedVars.interactables) then
        self.savedVars.interactables = {}
        for i, actionId in ipairs(itemList) do
            self.savedVars.interactables[actionId] = false
        end
    end

	local controlList = {}

	for i, actionId in ipairs(itemList) do
		local control = {
			type = "divider",
			height = 10,
		}
		controlList[#controlList + 1] = control
		local control = {
			type = "checkbox",
			name = '     ' .. GetString("SI_GAMECAMERAACTIONTYPE", actionId),
			getFunc = function()
				return self.savedVars.interactables[actionId]
			end,
			setFunc = function(value)
				self.savedVars.interactables[actionId] = value
			end,
			disabled = function() return not self.savedVars.disableOthers end,
			width = "half",
			
		}
		controlList[#controlList + 1] = control
		local control = {
			type = "slider",		-- transparency
			name = '',
			min = 0.1,
			max = 10,
			step = 0.1,
			decimals = 1,
			getFunc = function() return self.savedVars.delay[actionId] end,
			setFunc = function(value)
				self.savedVars.delay[actionId] = value
			end,
			width = "half",
			disabled = function() return not self.savedVars.interactables[actionId] end,
	
		}
		controlList[#controlList + 1] = control
	end
	
	local menu = {
		type = "submenu",
		name = GetString(SI_IJA_DIWM_DISABLEMORE_HEADER),
		reference = self.name .. "_IgnoreActions_LAM",
		controls = controlList,
		disabled = function() return not self.savedVars.disableOthers end,
	}
	return menu
end

function addon:CreateMenuForOptions()
	local controlList = {}

	for option=1, NUM_OPTIONALS do
		if not self.savedVars.optional then self.savedVars.optional = {} end
		local control = {
			type = "checkbox",
			name = GetString("SI_IJA_DIWM_OPTIONAL", option),
			tooltip = GetString("SI_IJA_DIWM_OPTIONAL_TIP", option),
			getFunc = function()
				return self.savedVars.optional[option]
			end,
			setFunc = function(value)
				self.savedVars.optional[option] = value
			end,
			width = "full",
			
		}
		controlList[#controlList + 1] = control
	end
	
	local menu = {
		type = "submenu",
		name = GetString(SI_IJA_DIWM_OPTIONAL),
		reference = self.name .. "_DisableOptionals_LAM",
		controls = controlList,
	}
	return menu
end

-----------------
-- Interaction
-----------------
function addon:InitializeHooks()
	local previouseFrameTimeSeconds = 0
	
	local function isOptionalDisabled()
		if GetUnitStealthState("player") ~= STEALTH_STATE_NONE then
			return not self.savedVars.optional[OPTION_FEATURE_CROUCHED] 
		end
		if IS_IN_DUNGEON then
			return not self.savedVars.optional[OPTION_FEATURE_DUNGEONS]
		end
		if IS_IN_PVP then
			return not self.savedVars.optional[OPTION_FEATURE_PVP]
		end
		return true
	end
	
	local function disabledInteractions(action, interactableName)
		if GetUnitName("companion") == interactableName and self.savedVars.disableCompanion then
			return isOptionalDisabled()
		end
		if self.savedVars.disableOthers and self.savedVars.interactables[actionsTable[action]] then
			return isOptionalDisabled()
		end
	end

	local function getDelay(action, interactableName)
		return (GetUnitName("companion") == interactableName and self.savedVars.companionDelay) or self.savedVars.delay[actionsTable[action]] or 0
	end
	
	local function playInstantlyToEnd()
		if self.savedVars.optional[OPTION_FEATURE_RETICLE] then 
			g_reticle.hitIndicatorTimeline:PlayInstantlyToEnd()
		end
	end
	local function playFromStart()
		if self.savedVars.optional[OPTION_FEATURE_RETICLE] then 
			g_reticle.hitIndicatorTimeline:PlayFromStart()
		end
	end
	
	local function isActionDisabled(action, interactableName, currentFrameTimeSeconds)
		return (previouseFrameTimeSeconds + getDelay(action, interactableName)) > currentFrameTimeSeconds
	end
	
	-- keep timer updated
	SecurePostHook(g_reticle, "OnUpdate", function(self, currentFrameTimeSeconds)
		if IsPlayerMoving() then
			-- Updates the time to be able to know how long it has been since the player stopped moving.
			previouseFrameTimeSeconds = currentFrameTimeSeconds
		end
	end)
	
	-- Register a filter for each action in the list.
	for actionName, i in pairs(actionsTable) do
		registerOnTryHandlingInteraction(self.name, actionName, function(action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract, currentFrameTimeSeconds)
			-- Is this filer enabled?
			if disabledInteractions(action, interactableName) then
				-- Should this action be disabled?
				if isActionDisabled(action, interactableName, currentFrameTimeSeconds) then
					if self.savedVars.optional[OPTION_FEATURE_HIDE] then 
						hideInteraction()
					end
					
					playFromStart()
					return true
				else
					playInstantlyToEnd()
				end
			end
			return false
		end)
	end
end

-----------------
function IJA_DIWM_Initialize( ... )
	IJA_DIWM = addon:New( ... )
end

