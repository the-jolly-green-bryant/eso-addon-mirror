--[[------------------------------------------------------------------------------------------------
Title:					Static's Letter Opener
Author:					Static_Recharge
Version:			  1.1.0
Description:		Opens master writs and survey letters automatically
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Static Values
------------------------------------------------------------------------------------------------]]--
local Containers = {
	["surveys"] = {
		[219849] = true,			-- blacksmithing
		[219850] = true,			-- clothing
		[219851] = true,			-- woodworking
		[219852] = true,			-- enchanting
		[219853] = true,			-- alchemy
		[219854] = true,			-- jewelry
	},

	["masterWrits"] = {
		[217917] = true,			-- blacksmithing
		[217918] = true,			-- clothing
		[217919] = true,			-- woodworking
		[217920] = true,			-- enchanting
		[217921] = true,			-- provisioning
		[217922] = true,			-- alchemy
		[217923] = true,			-- jewelry
	},

	["maps"] = {
		[224681] = true, 			-- treasure map
	},
}


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener Class Initialization
StaticsLetterOpener    														- Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
│              																		- Adds found items to the Que and starts the opening event.
├─ :Open()                												- Opens the next item in the Que.
├─ :GetInventoryIndex()                           - Searches for and returns the slot number of the next item in the Que.
└─ :Test(...)                                     - For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--
StaticsLetterOpener = {}


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:Initialize()
Inputs:				None
Outputs:			None
Description:	Initializes all of the variables, object managers, slash commands and main event
							callbacks.
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:Initialize()
	-- Static definitions
	self.addonName = "StaticsLetterOpener"
	self.addonVersion = "1.1.0"
	self.author = "|CFF0000Static_Recharge|r"
	self.varsVersion = 1

	self.Defaults = {
		surveys = true,
		masterWrits = false,
		maps = false,
		openAll = false,
		chatEnabled = true,
		debugEnabled = false,
		settingsChanged = true,
	}

	-- Session variables
	self.Que = {}
	self.started = false

	-- Saved variables initialization
	self.SV = ZO_SavedVars:NewAccountWide("StaticsLetterOpenerAccountWideVars", self.varsVersion, nil, self.Defaults, GetWorldName())

	-- Library initialization
	local Options = {
		addonIdentifier = "Letter Opener",
		prefixColor = "FFFFFF",
		textColor = "FFFFFF",
		chatEnabled = self.SV.chatEnabled,
		debugEnabled = self.SV.debugEnabled,
	}
	self.Chat = LibStatic:ChatNew(Options)

	-- Module initilization
	self.Settings:Initialize(self)
	
	-- Event Registrations
	EM:RegisterForEvent(self.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:OnInventorySingleSlotUpdate(...) end)
	EM:AddFilterForEvent(self.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	EM:AddFilterForEvent(self.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

	--SLASH_COMMANDS["/slotest"] = function(...) self:Test(...) end

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
Inputs:				eventCode														- Internal ZOS event code, not used here.
							bagId																- Number for which bag was affected (use globals)
							slotId 															- Slot number for the item that was affected
							isNewItem 													- True if the item is new to the player
							itemSoundCategory 									- Sound information for the item
							inventoryUpdateReason 							- Global reason for inventory change
							stackCountChange 										- new stack count
Outputs:			None
Description: 	Adds found items to the Que and starts the opening event.
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	-- If open all is disabled and the item isn't new then exit as there's nothing to do.
	if not self.SV.openAll and not isNewItem then return end

	local itemData = {
		id = GetItemId(bagId, slotId),
		link = GetItemLink(bagId, slotId),
	}

	-- search through containers and ids for a match
	for category, container in pairs(Containers) do
		if container[itemData.id] and self.SV[category] then
			table.insert(self.Que, itemData)
			self.Chat:Debug(zo_strformat("<<1>> Qued", itemData.link))
			if not self.started then
				EM:RegisterForUpdate(self.addonName, 500, function() self:Open() end)
				self.started = true
			end
		end
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:Open()
Inputs:				None
Outputs:			None
Description:	Opens the next item in the Que.
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:Open()
	local bag = BAG_BACKPACK
	if #self.Que == 0 then
		EM:UnregisterForUpdate(self.addonName)
		self.started = false
		return
	end
	if GetSlotCooldownInfo(1) == 0 then
		local slotId = self:GetInventoryIndex()
		if slotId then
			self.Chat:Debug(zo_strformat("Item Found: slotId: <<1>>, bag: <<2>>, <<3>>", slotId, bag, GetItemLink(bag, slotId)))
			if IsProtectedFunction("UseItem") then
				CallSecureProtected("UseItem", bag, slotId)
			else
				UseItem(bag, slotId)
			end
			self.Chat:Msg(zo_strformat("<<1>> Opened", self.Que[1].link))
		else
			self.Chat:Msg(zo_strformat("<<1>> Not found", self.Que[1].link))
		end
		table.remove(self.Que, 1)
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:GetInventoryIndex()
Inputs:				None
Outputs:			slotIndex 													- The slot containing the next item in the Que
Description:	Searches for and returns the slot number of the next item in the Que.
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:GetInventoryIndex()
	local bag = BAG_BACKPACK
	local bagData = SHARED_INVENTORY:GetOrCreateBagCache(bag)
	if not ZO_IsTableEmpty(bagData) then
		local queOne = self.Que[1]
		for slotIndex, slotData in pairs(bagData) do
			if HasItemInSlot(bag, slotIndex) and GetItemId(bag, slotIndex) == queOne.id then
				self.Chat:Debug(zo_strformat("<<1>> Found", queOne.link))
				return slotIndex
			end
		end
	end
end


--[[------------------------------------------------------------------------------------------------
StaticsLetterOpener:Test()
Inputs:				None
Outputs:			None
Description:	
------------------------------------------------------------------------------------------------]]--
function StaticsLetterOpener:Test(...)
	d("test")
end


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, StaticsLetterOpener, of the LO class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("StaticsLetterOpener", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "StaticsLetterOpener" then return end
	EM:UnregisterForEvent("StaticsLetterOpener", EVENT_ADD_ON_LOADED)
	StaticsLetterOpener:Initialize()
end)