local DEBUG =
function() end
-- d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

IM.LAM = LibAddonMenu2
if not IM.LAM and LibStub then IM.LAM = LibStub("LibAddonMenu-2.0")  end

IM.name = "InventoryManager"
IM.loadedAddons = {}

-- The current inventory we're working on
IM.currentInventory = nil
IM.currentBagType = nil
IM.opssuspended = false

-- The current ruleset we're working with
IM.currentRuleset = { }

local ADDON_VERSION = "2.5.1"
local ADDON_WEBSITE = "https://www.esoui.com/downloads/info1642-InventoryManager.html"

function IM:ProcessSingleItem(dryrun, data)
	if not dryrun then IM.actionfunctions[data.action](data) end
	IM:ReportAction(data, dryrun, data.action, data.index, data.text)
end

function IM:ReportAction(data, dryrun, action, rIndex, rString)
  if not rIndex then return end
  
	if not dryrun and not IM.settings.progressreport then return end

	local index = (dryrun and 0) or 1
	if self.FCOISL:IsProtectedAction(data.action, data.bagId, data.slotId) then
		index = 2
	end
	CHAT_SYSTEM:AddMessage(zo_strformat(GetString("IM_TAKENACTION", index),
			GetString("IM_ACTIONTXT",action),
			data.icon, 
			data.lnk,
			rIndex or "",
			rString or ""))
end

function IM:SetCurrentInventory(bagType)
	self.currentInventory = SHARED_INVENTORY:GetOrCreateBagCache(bagType)

	self.currentBagType = bagType

end

function IM:SetShownInventory()
	local bagType = nil
	
	if SCENE_MANAGER.currentScene == SCENE_MANAGER.scenes.inventory then
		bagType = BAG_BACKPACK
	elseif SCENE_MANAGER.currentScene == SCENE_MANAGER.scenes.bank then
		if INVENTORY_FRAGMENT:IsShowing() then
			bagType = BAG_BACKPACK
		elseif BANK_FRAGMENT:IsShowing() then
			bagType = BAG_BANK			
		end
	end

	if not bagType then
		return nil
	end
	self:SetCurrentInventory(bagType)
	return bagType
end

function IM:GetItemData(slotId, _inv)
	local data = {}
	local inv = nil
	
	if _inv then
		inv = _inv
	else
		inv = self.currentInventory
	end
	
	if not inv or not inv[slotId] then
		return nil
	end
	
	local itemLink = GetItemLink(self.currentBagType, slotId)
	local uID = Id64ToString(GetItemUniqueId(self.currentBagType, slotId))

	data.bagId = self.currentBagType
	data.slotId = slotId
	
	data.name = inv[slotId].name
	data.lnk = itemLink
	data.itemInstanceId = inv[slotId].itemInstanceId
	
	data.count, data.maxCount = GetSlotStackSize(self.currentBagType, slotId)
	data.locked = IsItemPlayerLocked(self.currentBagType, slotId)
	data.junk = IsItemJunk(self.currentBagType, slotId)
	
	data.itemType, data.specialitemtype = GetItemLinkItemType(itemLink)
	data.value = GetItemLinkValue(itemLink, false)

	data.icon, _, _, data.equipType, data.itemStyle = GetItemLinkInfo(itemLink)
	
	if data.itemType == ITEMTYPE_ARMOR then
		data.armorType = GetItemLinkArmorType(itemLink)
	elseif data.itemType == ITEMTYPE_WEAPON then
		data.weaponType = GetItemLinkWeaponType(itemLink)
	end

	data.traitType = GetItemLinkTraitInfo(itemLink)

	data.isSet, data.set = GetItemLinkSetInfo(itemLink)
	
	data.quality = GetItemLinkQuality(itemLink)
	data.stolen = IsItemLinkStolen(itemLink)
	data.crafted = IsItemLinkCrafted(itemLink)
	data.unique = IsItemLinkUnique(itemLink)
	
	data.unknownself, data.unknownothers = self.CSL:isUnknown(itemLink, uID)
	return data
end

function IM:listrules()
  IM.currentRuleset:List()
end

function IM:dryrun()
	self:WorkBackpack(true)
end

function IM:run()
	self:WorkBackpack(false)
end

function IM:OpenSettings()
	self.LAM:OpenToPanel(self.UI.panel)
	IM.UI.RuleEdit:UpdateFCOIcons()
end

function IM:help()	
	-- self:SetCurrentInventory(BAG_BACKPACK)
	-- for i, entry in pairs(self.currentInventory) do
		-- local knownString = ""
		-- local oneself, others = self.CSL:isUnknown(entry.lnk)
		-- if oneself then
			-- knownString = " (unknown to you)"
		-- end
		-- if others then
			-- knownString = knownString .. " (unknown to others)"
		-- end
		-- CHAT_SYSTEM:AddMessage("  Item " .. i .. ": " .. entry.lnk .. knownString);
	-- end
	CHAT_SYSTEM:AddMessage("/im listrules - list the rules currently defined")
	CHAT_SYSTEM:AddMessage("/im dryrun    - show what the currently defined rules would do to your inventory")
	CHAT_SYSTEM:AddMessage("/im run       - make a pass of the filters over your inventory")
	CHAT_SYSTEM:AddMessage("/im as-off    - Quickly disable autosell")
	CHAT_SYSTEM:AddMessage("/im as-on     - Quickly enable autosell")
	CHAT_SYSTEM:AddMessage("/im off       - Completely suspend operations for this session and until resumed")
	CHAT_SYSTEM:AddMessage("/im on        - Resume operations")
	CHAT_SYSTEM:AddMessage("/im settings  - Open up the settings menu")
end

function IM:SlashCommand(argv)
    local options = {}
    local searchResult = { string.match(argv,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 then
		self:OpenSettings()
	elseif options[1] == "help" then
		self:help()
	elseif options[1] == "listrules" then
		self:listrules()
	elseif options[1] == "dryrun" then
		self:dryrun()
	elseif options[1] == "run" then
		self:run()
	elseif options[1] == "settings" then
		self:OpenSettings()
	elseif options[1] == "as-off" then
		IM.settings.autosell = false
		self:ReportASState(false)
	elseif options[1] == "as-on" then
		IM.settings.autosell = true
		self:ReportASState(false)
	elseif options[1] == "off" then
		IM.opssuspended = true
		self:ReportOpsState(false)
	elseif options[1] == "on" then
		IM.opssuspended = false
		self:ReportOpsState(false)
	else
		CHAT_SYSTEM:AddMessage("Unknown parameter '" .. argv .. "'")
	end
end

IM.UI = { }
IM.UI.RuleEdit = { }
IM.UI.ProfileEdit = { }
IM.UI.Settings = { }

local RuleEdit = IM.UI.RuleEdit
local ProfileEdit = IM.UI.ProfileEdit
local Settings = IM.UI.Settings

function IM:InitializeUI()
	
	local panelData = {
		type = "panel",
		name = "InventoryManager",
		author = "iwontsay & iFedix",
		version = ADDON_VERSION,
		-- slashCommand = "/im", -- Nope. This would completely remove the commandline parsing we need.
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true,
		website = ADDON_WEBSITE,
	}	
		
	local mainPanel = {
		{
			type = "submenu",
			name = GetString(IM_UI_PM),
			tooltip = GetString(IM_UI_PM_TOOLTIP),	--(optional)
			controls = ProfileEdit:GetControls(),
		},
		{
			type = "submenu",
			name = GetString(IM_UI_RM),
			tooltip = GetString(IM_UI_RM_TOOLTIP),	--(optional)
			controls = RuleEdit:GetControls(),
		},
		{
			type = "submenu",
			name = GetString(IM_UI_SETTINGS),
			tooltip = GetString(IM_UI_SETTINGS_TOOLTIP),	--(optional)
			controls = Settings:GetControls(),
		},
		
	}
	
	self.UI.panel = self.LAM:RegisterAddonPanel("iwontsayInventoryManager", panelData)
	self.LAM:RegisterOptionControls("iwontsayInventoryManager", mainPanel)
end

local function loadProfile(profileData)
	local _new = { }
	for k,v in pairs(profileData) do
		_new[k] = IM.IM_RulesetV2.Clone(v)
    _new[k].name = v.name
    _new[k].settings = v.settings or { }
    _new[k].settings.Version = 3
	end
	return _new
end

function IM:Update()
	local version = self.settings.Version or 1
  
  if version < 3 then
    self.currentRuleset         = IM.IM_Ruleset:New()
    self.currentRuleset.rules	  = self.charVariables.currentRules or { }
    self.currentRuleset         = self.currentRuleset:Clone()
  end
  
	if version < 2 then
		local _rule = self.IM_Rule:New()
		_rule.action = self.ACTION_SELL
		_rule.junk = true
		local rs = self.currentRuleset.rules
		table.insert(rs, 1, _rule)
		CHAT_SYSTEM:AddMessage(GetString(IM_INIT_UPDATE_V2_NOTE))
	end
	
  if version < 3 then
    self.currentRuleset         = IM.IM_RulesetV2.Clone(self.currentRuleset)
		CHAT_SYSTEM:AddMessage(GetString(IM_INIT_UPDATE_V3_NOTE))
  end
  
	self.settings.Version = 3
	self:Save()
end

function IM:Init()
  
	self.charDefaults = {
		["settings"]		    = {
			["destroyThreshold"]	= 5,
			["bankMoveDelay"]		  = 20,
			["bankInitDelay"]	  	= 1000,
			["statusChangeDelay"]	= 20,
			["maxGold"]		    		= 5000,
			["minGold"]		    		= 1000,
			["maxTV"]			      	= 10,
			["minTV"]			      	= 0,
			["maxAP"]		    		= 10,
			["minAP"]		    		= 0,
			["maxVW"]			      	= 10,
			["minVW"]			      	= 0,
			["autosell"]	    		= true,
			["progressreport"]			= true,
			["Version"]         	  	= 3,
		}
	}
	
	self.accDefaults = {
		["Profiles"] = { }
	}
	
	self.migrateDefaults = {
		["NotPresent"] = true;
	}
	
	self.accVariables = ZO_SavedVars:NewAccountWide(
		"IMSavedVars",
		1,
		nil,
		self.accDefaults)
	
	self.Profiles 		      		= loadProfile(self.accVariables.Profiles)
	self.presetProfiles			    = loadProfile(self.presetProfiles)

	self.migrateVariables = ZO_SavedVars:New(
		"IMSavedVars",
		1,
		nil,
		self.migrateDefaults)

	if not self.migrateVariables.NotPresent then
		CHAT_SYSTEM:AddMessage(self.name .. " Migrating settings from name based save.")
		if self.migrateVariables.currentRuleset then
			self.currentRuleset = IM.IM_RulesetV2.Clone(self.migrateVariables.currentRuleset)
		else
			self.currentRuleset = IM.IM_RulesetV2:New()
		end
		self.settings = self.migrateVariables.settings

		self.charVariables = ZO_SavedVars:NewCharacterIdSettings(
			"IMSavedVars",
			1,
			nil,
			self.charDefaults)
	else
		self.charVariables = ZO_SavedVars:NewCharacterIdSettings(
			"IMSavedVars",
			1,
			nil,
			self.charDefaults)
		
		-- ... How could that be set?! :O
		self.charVariables.NotPresent = nil;
			
		if self.charVariables.currentRuleset then
			self.currentRuleset = IM.IM_RulesetV2.Clone(self.charVariables.currentRuleset)
		else
			self.currentRuleset = IM.IM_RulesetV2:New()
		end

		self.settings				        = self.charVariables.settings
	end
	
	self.migrateVariables = nil;  
	
	self.CSL.hasCSAddon()
	self.FCOISL:hasAddon()
	
	self:Update()
	self:InitializeUI()
	
	self:ReportASState(true)

	CHAT_SYSTEM:AddMessage(self.name .. " Addon Loaded.")
	CHAT_SYSTEM:AddMessage("Use /im help for an overview")	
end

function IM:Save()
	self.charVariables.settings		      = self.settings
	self.charVariables.currentRuleset	  = self.currentRuleset
	self.charVariables.Profiles		      = nil
	self.charVariables.currentRules	    = nil
	
	self.accVariables.Profiles 		      = self.Profiles
end

local function OnAddOnLoaded(eventCode, addonName)
	if addonName == IM.name then
		IM:Init()
	else
		IM.loadedAddons[addonName] = true
	end
end

local function OnPCCreated()
	RuleEdit:PopulateUI()
	ProfileEdit:PopulateUI()
	Settings:PopulateUI()
end

EVENT_MANAGER:RegisterForEvent(IM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS["/im"] = function(argv) IM:SlashCommand(argv) end

CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnPCCreated)
