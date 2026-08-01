local list = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "List")
local bg = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "BG")
local button1 = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "Button1")
local button2 = GetControl(LOOT_WINDOW_FRAGMENT.control:GetNamedChild("AlphaContainer"), "Button2")

bg:SetHeight(562)
button2:ClearAnchors()
button2:SetAnchor(TOPLEFT, button1, BOTTOMLEFT, 0, 4)

local freeSlots = WINDOW_MANAGER:CreateControl("HarvensBagSpaceFreeSlots", LOOT_WINDOW_FRAGMENT.control, CT_LABEL)
freeSlots:SetAnchor(TOPLEFT, list, BOTTOMLEFT, 16, 8)
freeSlots:SetFont("ZoFontGameLargeBold")
freeSlots:SetColor(ZO_NORMAL_TEXT:UnpackRGB())

local function UpdateSlotCounts()
	local numUsedSlots = 0
	local numSlots = 0
	if GetNumBagUsedSlots then
		numUsedSlots = GetNumBagUsedSlots(INVENTORY_BACKPACK)
		numSlots = GetBagSize(INVENTORY_BACKPACK)
	else
		numUsedSlots = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].numUsedSlots
		numSlots = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].numSlots
	end
	
	if numUsedSlots < numSlots then
		freeSlots:SetText(zo_strformat(SI_INVENTORY_BACKPACK_REMAINING_SPACES, numUsedSlots, numSlots))
	else
		freeSlots:SetText(zo_strformat(SI_INVENTORY_BACKPACK_COMPLETELY_FULL, numUsedSlots, numSlots))
	end
end

EVENT_MANAGER:RegisterForEvent("HarvensBagSpaceSingleSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventType, bagId) 
	if bagId ~= BAG_BACKPACK or freeSlots:IsHidden() == true then
		return
	end
	
	UpdateSlotCounts()
end)

LOOT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	if newState == SCENE_SHOWING then
		freeSlots:SetHidden(true)
	elseif newState == SCENE_SHOWN then
		freeSlots:SetHidden(false)
		UpdateSlotCounts()
	end
end)
