Junkee = Junkee or {}
Junkee.__index = Junkee
Junkee.name = "JunkeeReturns"

local INVENTORIES_TO_HOOK = {INVENTORY_BACKPACK, INVENTORY_BANK}

Junkee.bagId  = nil
Junkee.slotId = nil
Junkee.isJunk = false

Junkee.OnMouseEnter = function(control)
	Junkee.bagId  = control.dataEntry.data.bagId
	Junkee.slotId = control.dataEntry.data.slotIndex
	Junkee.isJunk = control.dataEntry.data.isJunk

	Junkee.AddJunkAction()
end

Junkee.OnMouseExit = function(control)
	Junkee.bagId  = nil
	Junkee.slotId = nil
	Junkee.isJunk = false

	Junkee.RemoveJunkAction()
end

local function registerHook(inventory)
	local listView = inventory.listView
	if listView and listView.dataTypes and listView.dataTypes[1] then
		local originalCallback = listView.dataTypes[1].setupCallback
		listView.dataTypes[1].setupCallback = function(rowControl, slot)
			originalCallback(rowControl, slot)
			ZO_PreHookHandler(rowControl, "OnMouseEnter", Junkee.OnMouseEnter)
			ZO_PreHookHandler(rowControl, "OnMouseExit",  Junkee.OnMouseExit)
		end
	end
end

local function registerHooks()
	for _, index in pairs(INVENTORIES_TO_HOOK) do
		registerHook(PLAYER_INVENTORY.inventories[index])
	end
end

Junkee.Loaded = function(eventCode, addonName)
	if (Junkee.name == addonName) then
		registerHooks()
	end
end

Junkee.JunkIt = function()
	if Junkee.bagId == nil then return end
	local isJunk = IsItemJunk(Junkee.bagId, Junkee.slotId)
	SetItemIsJunk(Junkee.bagId, Junkee.slotId, not isJunk)
	if isJunk then	
		PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED)		
	else
		PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)		
	end
end

Junkee.DeleteIt = function()
	if Junkee.bagId == nil then return end
	DestroyItem(Junkee.bagId, Junkee.slotId)
end

local function createJunkStripDescriptor(name)
	return JunkeeKeyStrip:New(name, "JUNKEE_JUNK_IT", Junkee.JunkIt)
end

local junkStripDescriptor = createJunkStripDescriptor(Junkee.tr("JunkLabel"))
local unjunkStripDescriptor = createJunkStripDescriptor(Junkee.tr("UnjunkLabel"))
local deleteStripDescriptor = JunkeeKeyStrip:New(Junkee.tr("DeleteLabel"), "JUNKEE_DELETE_IT", Junkee.DeleteIt)

Junkee.AddJunkAction = function()
	if (Junkee.isJunk) then
		unjunkStripDescriptor:Add(true)
	else
		junkStripDescriptor:Add(true)
	end
	deleteStripDescriptor:Add(true)
end

Junkee.RemoveJunkAction = function()
	junkStripDescriptor:Remove()
	unjunkStripDescriptor:Remove()
	deleteStripDescriptor:Remove()
end

-- Needed to bind Shift+T
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end


EVENT_MANAGER:RegisterForEvent(Junkee.name, EVENT_ADD_ON_LOADED, Junkee.Loaded)
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_JUNK_IT", Junkee.tr("JunkBindingName"))
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_DELETE_IT", Junkee.tr("DeleteBindingName"))
