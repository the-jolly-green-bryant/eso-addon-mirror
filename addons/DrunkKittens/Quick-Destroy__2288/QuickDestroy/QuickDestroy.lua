QuickDestroy = QuickDestroy or {}
QuickDestroy.__index = QuickDestroy
QuickDestroy.name = "QuickDestroy"

local INVENTORY_TO_HOOK = {}
INVENTORY_TO_HOOK[INVENTORY_BACKPACK] = true
INVENTORY_TO_HOOK[INVENTORY_BANK] = true

QuickDestroy.bagId  = nil
QuickDestroy.slotId = nil

QuickDestroy.OnMouseEnter = function(control)
	QuickDestroy.bagId  = control.dataEntry.data.bagId
	QuickDestroy.slotId = control.dataEntry.data.slotIndex

QuickDestroy.AddDestroyAction()

end

QuickDestroy.OnMouseExit = function(control)
	QuickDestroy.bagId  = nil
	QuickDestroy.slotId = nil

QuickDestroy.RemoveDestroyAction()

end

QuickDestroy.Loaded = function(eventCode, addonName)
	if (QuickDestroy.name == addonName) then
		
		ZO_PreHook("ZO_InventorySlot_OnMouseEnter", function(control)
            if control.dataEntry and control.dataEntry.data then
                if control.dataEntry.data.bagId and INVENTORY_TO_HOOK[control.dataEntry.data.bagId] == true then
                    QuickDestroy.OnMouseEnter(control)
                end
            end
        end)

        ZO_PreHook("ZO_InventorySlot_OnMouseExit", function(control)
            if control.dataEntry and control.dataEntry.data then
                if control.dataEntry.data.bagId and INVENTORY_TO_HOOK[control.dataEntry.data.bagId] == true then
                    QuickDestroy.OnMouseExit(control)
                end
            end
        end)
	end
end

QuickDestroy.Destroy = function()
	if QuickDestroy.bagId == nil then return end
	d("|ccc0099Destroyed Item|r " .. GetItemLink(QuickDestroy.bagId, QuickDestroy.slotId))
	DestroyItem(QuickDestroy.bagId, QuickDestroy.slotId)
	
end

local DestroyStripDescriptor = QuickDestroyKeyStrip:New(QuickDestroy.tr("DestroyLabel"), "QUICKDESTROY_DESTROY", QuickDestroy.Destroy)

QuickDestroy.AddDestroyAction = function()
	
	DestroyStripDescriptor:Add(true)
end

QuickDestroy.RemoveDestroyAction = function()
	
	DestroyStripDescriptor:Remove()
end

function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end

EVENT_MANAGER:RegisterForEvent(QuickDestroy.name, EVENT_ADD_ON_LOADED, QuickDestroy.Loaded)

ZO_CreateStringId("SI_BINDING_NAME_QUICKDESTROY_DESTROY", QuickDestroy.tr("DestroyBindingName"))
