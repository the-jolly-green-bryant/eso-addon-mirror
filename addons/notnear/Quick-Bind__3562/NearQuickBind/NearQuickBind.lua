local addon = {
    name = "NearQuickBind",
    title 		= "Near's Quick Bind",
	shortTitle 	= "Quick Bind",
	author 		= "|cCC99FFnotnear|r",
    bagId  = nil,
    slotId = nil,
}
NEAR_QB = addon

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Register hooks
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local INVENTORY_TO_HOOK = {}
INVENTORY_TO_HOOK[INVENTORY_BACKPACK] = true
INVENTORY_TO_HOOK[INVENTORY_BANK] = true

local function HookOnMouseEnter()
    ZO_PreHook("ZO_InventorySlot_OnMouseEnter", function(control)
        if control.dataEntry and control.dataEntry.data then
            if control.dataEntry.data.bagId and INVENTORY_TO_HOOK[control.dataEntry.data.bagId] == true then
                addon.OnMouseEnter(control)
            end
        end
    end)
end

local function HookOnMouseExit()
    ZO_PreHook("ZO_InventorySlot_OnMouseExit", function(control)
        if control.dataEntry and control.dataEntry.data then
            if control.dataEntry.data.bagId and INVENTORY_TO_HOOK[control.dataEntry.data.bagId] == true then
                addon.OnMouseExit(control)
            end
        end
    end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Binding function
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function addon.Bind()
	if addon.bagId == nil then return end
	d( "|cCC99FF" .. "Bound Item " .. "|r" .. GetItemLink(addon.bagId, addon.slotId) )
	BindItem(addon.bagId, addon.slotId)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Key Strip
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local canItemBind = nil

function addon.OnMouseEnter(control)
	addon.bagId  = control.dataEntry.data.bagId
	addon.slotId = control.dataEntry.data.slotIndex

    if (GetItemType(addon.bagId, addon.slotId) == ITEMTYPE_ARMOR) or (GetItemType(addon.bagId, addon.slotId) == ITEMTYPE_WEAPON) then canItemBind = true
    else canItemBind = false end

    if (canItemBind) and not IsItemBound(addon.bagId, addon.slotId) then
        addon.AddBindAction()
    end
end

function addon.OnMouseExit(control)
	addon.bagId  = nil
	addon.slotId = nil

    addon.RemoveBindAction()
end

local BindStripDescriptor = NEAR_QB_KeyStrip:New(GetString(NQB_BindLabel), "NQB_BIND", addon.Bind)

function addon.AddBindAction()
	BindStripDescriptor:Add(true)
end

function addon.RemoveBindAction()
	BindStripDescriptor:Remove()
end

function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
	return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    HookOnMouseEnter()
    HookOnMouseExit()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
