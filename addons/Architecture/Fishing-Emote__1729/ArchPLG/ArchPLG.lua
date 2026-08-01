local ArchPLG = {}
--ZO_Object:Subclass()

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
local em = GetEventManager()

function ArchPLG:New(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function ArchPLG:d(...)
	if self.sv.debug and false then
		d(...)
	end
end

local function ParseCommandOptions(option)
	local options = {}
	local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
			options[i] = string.lower(v)
		end
	end
	
	return options
end

function ArchPLG:SetupOptions()
	local panelData = {
		type = "panel",
		name = self.addonDisplayName,
		displayName = self.addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsTable = {
		-- Undaunted Pledge Quests
		{
			type = "header",
			name = "Random Fishing Emote",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Enabled",
			tooltip = "Enables or disables the random emote while fishing.",
			getFunc = function() return self.sv.enabled end,
			setFunc = function(value)
				self.sv.enabled = value
			end,
			width = "full",
		},
		{
			type = "editbox",
			name = "Emote Command Name",
			tooltip = "Specify the emote command to use (without the leading '/' in front), e.g. leanbackcoin (this can also be changed using '/fishingemote leanbackcoin' in chat)",
			disabled = function()
				return not self.sv.enabled
			end,
			getFunc = function() return self.sv.commandName end,
			setFunc = function(value) local options = ParseCommandOptions(value) if not #options == 0 and not options[1] == "help" then self.sv.commandName = options[1] end end,
			default = "leanbackcoin",
			width = "full",
		},
		{
			type = "slider",
			name = "Cast Time / Duration (ms)",
			tooltip = "Specify a delay or pause after beginning cast and when the emote will be performed -- in milliseconds (0 to disable the delay and immediately perform the emote upon interacting with fishing hole)",
			min = 0,
			max = 15000,
			step = 100,
			default = 0,
			disabled = function()
				return not self.sv.enabled
			end,
			getFunc = function()
				return self.sv.commandDelay
			end,
			setFunc = function(value)
				self.sv.commandDelay = value
			end,
		},
		{
			type = "checkbox",
			name = "Idle Emote After Reel In",
			tooltip = "Enables or disables the performing the '/idle' emote to stop any emote after reeling in. If you are unsure what to set this as then feel free to disable it.",
			disabled = function()
				return not self.sv.enabled
			end,
			getFunc = function() return self.sv.idleAfterReelIn end,
			setFunc = function(value)
				self.sv.idleAfterReelIn = value
			end,
			width = "full",
		},
		{
			type = "button",
			name = function() if self.sv.commandName ~= nil and self.sv.commandName ~= "" then return "Test (/" .. self.sv.commandName .. ")" end return "Test Emote" end,
			tooltip = "Test the emote command entered above by clicking this button (this will include any simulated delay specified in settings above).",
			disabled = function()
				return not self.sv.enabled
			end,
			func = function()
				if self.sv.commandName ~= nil and self.sv.commandName ~= "" then
					self:DoEmoteCommand()
				else
					ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Invalid or blank emote command name specified")
				end
			end,
			width = "full",
		},
	}
	
	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

function ArchPLG:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

function ArchPLG:DoEmoteCommand()
	if self.sv.commandDelay > 0 then
		zo_callLater(function() DoCommand("/" .. self.sv.commandName) end, self.sv.commandDelay)
	else
		DoCommand("/" .. self.sv.commandName)
	end
end

function ArchPLG:RandomFishingEmote()
	self.lastAction = ""
	self.interactionReady = false
	self.lure = nil
	self.lureLast = nil
	
	local function PlayerActivated()
		self.lastAction = ""
		self.lure = nil
	end
	
	local function PlayerActivatedFirstTime()
		em:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
		
		--CleanUp()
		self.unitName = GetRawUnitName("player")
		
		--CALLBACK_MANAGER:RegisterCallback(gps.LIB_EVENT_STATE_CHANGED, WaitForLibGPS)
		em:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, PlayerActivated)
		--QUEST_TRACKER:RegisterCallback("QuestTrackerRefreshedMapPins", QuestTrackerRefreshedMapPins)
		
		--GAMEPAD_WORLD_MAP_FILTERS_FRAGMENT:RegisterCallback("StateChange", AddFilter)
		--WORLD_MAP_INFO_FRAGMENT:RegisterCallback("StateChange", AddFilter)
		--CALLBACK_MANAGER:RegisterCallback("OnFyrMiniNewMapEntered", OnFyrMiniNewMapEntered)
		
		--if gps:GetCurrentMapMeasurements() ~= nil then WaitForLibGPS(false) end
		PlayerActivated()
		zo_callLater( function() self.interactionReady = true end, 1000)
	end
	
	local function StopFishing()
		if self.fishing then
			self:d("Done fishing...")
			self.fishing = false
			--em:UnregisterForEvent(self.name, EVENT_LOOT_RECEIVED)
			--em:UnregisterForEvent(self.name, EVENT_LOOT_CLOSED)
			--em:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED)
			--em:UnregisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED)
			--Stop animation
			--StopReelIn()
			
			if (self.sv.enabled) then
				if self.sv.idleAfterReelIn then
					DoCommand("/idle")
				end
			end
		end
	end
	
	local function StartFishing()
		local lureIndex = GetFishingLure()
		if lureIndex then
			self:d("Fishing!")
			--currentBaitName = GetFishingLureInfo(lureIndex)
			--currentBaitCount = CountCurrentBait()
			--em:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, OnLootReceived)
			--em:RegisterForEvent(self.name, EVENT_LOOT_CLOSED, OnLootClosed)
			--em:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SlotUpdate)
			--em:RegisterForEvent(self.name, EVENT_ACTION_LAYER_POPPED, ActionLayerChanged)
			--em:RegisterForEvent(self.name, EVENT_ACTION_LAYER_PUSHED, ActionLayerChanged)
			self.inDialog = false
			self.fishing = true
			
			if (self.sv.enabled) then
				if self.sv.commandName == nil or self.sv.commandName == "" then
					self.sv.commandName = "leanbackcoin"
				end
				
				self:DoEmoteCommand()
			end
			
		end
	end
	
	local fishingInteractableName
	local function NewInteraction()
		if not self.interactionReady then return end
		local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
		if action then
			if self.lastAction == action then
				--if lure and interactableName == self.fishingInteractableName then UpdatePosition() end
				return false
			end
			self.lastAction = action
			if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
				self.fishingInteractableName = interactableName
				--FishingNode()
				if self.lure == nil then
					StopFishing()
				else
					--[[if data.settings.autoHideRFT and RFT and RFT.window then
						if RFT.SetIsFishing then
							RFT:SetIsFishing(true)
						else
							RFT.window:SetHidden(false)
						end
					end]]
				end
			else
				local isNotFishing = not(interactableName == self.fishingInteractableName)
				if isNotFishing then
					StopFishing()
				else
					StartFishing()
				end
				--data.base:SetHidden(isNotFishing)
			end
		else
			if self.lastAction == action then return false end
			self.lastAction = action
			--data.base:SetHidden(true)
			--[[if data.settings.autoHideRFT and RFT and RFT.window then
				if RFT.SetIsFishing then
					RFT:SetIsFishing(false)
				else
					RFT.window:SetHidden(not RFT.settings.shown)
				end
			end]]
			self.lastHeading = -1
		end
		return false
	end
	
	local function HookInteraction()
		-- Call ZO_PreHookHandler and not SetHandler to prevent overwriting another handler
		ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", NewInteraction)
		ZO_PreHookHandler(RETICLE.interact, "OnHide", NewInteraction)
	end
	
	local success, msg = pcall(HookInteraction)
	if not success then
		zo_callLater( function() self:d(self.name .. ": HookInteraction failed.", msg) end, 2000)
	else
		em:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, PlayerActivatedFirstTime)
	end
end

function ArchPLG:RegisterSlashCommands()
	local RandomFishingEmoteCommandName = "fishingemote"
	local function RandomFishingEmote(opt)
		local options = ParseCommandOptions(opt)
		
		if #options == 0 or options[1] == "help" then
			-- Display help
			if self.sv.commandName == nil then
				self.sv.commandName = ""
			end
			
			d(self.addonDisplayName .. ": Set the fishing emote\nExample: |cFFA500/" .. RandomFishingEmoteCommandName .. " leanbackcoin|r\n|cCCCCCC(currently set to '" .. self.sv.commandName .. "')|r")
			
			return
		end
		
		self.sv.commandName = options[1]
		
		d(self.addonDisplayName .. ": Emote command set to |cFFA500" .. self.sv.commandName .. "|r!")
	end
	
	SLASH_COMMANDS["/"..RandomFishingEmoteCommandName] = RandomFishingEmote
	SLASH_COMMANDS["/rfe"] = RandomFishingEmote
	SLASH_COMMANDS["/fe"] = RandomFishingEmote
	SLASH_COMMANDS["/rf"] = RandomFishingEmote
	SLASH_COMMANDS["/fishemote"] = RandomFishingEmote
	SLASH_COMMANDS["/femote"] = RandomFishingEmote
end

--- Initialize
-- @param addonName
--
function ArchPLG:Initialize(addonName)
	self.name = addonName
	self.addonDisplayName = "|c0066FFArch's|r Fishing Emote"
	
	self:DefineColors()
	
	self.sv = {}
	
	local defaults = {
		enabled = true,
		commandName = "leanbackcoin",
		commandDelay = 800,
		idleAfterReelIn = false,
		debug = false,
	}
	
	self.sv = ZO_SavedVars:NewAccountWide(self.name .. "_SavedVariables", 1, nil, defaults)
	
	self:d(self.name .. ": Initialized the " .. self.name .. " addon!")

	self:SetupOptions()

	self:RegisterSlashCommands()
	
	if self.sv.enabled then
		self:RandomFishingEmote()
	end
end

ARCH_PLG = ArchPLG:New()

-- Addon Initialization
local function ArchPLG_Init(eventType, addonName)
	if addonName ~= "ArchPLG" then
		return
	end
	
	ARCH_PLG:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchPLGInit", EVENT_ADD_ON_LOADED, ArchPLG_Init)
