----- Initialization -----

FollowItem = {}
FollowItem.name = "FollowItem"

----- Restoration Functions -----

function FollowItem:ReloadAllItems()
  if (self.savedVars.items) then
    local i = 1
    while (i <= #self.savedVars.items) do
      self.savedVars.items[i].control = self.pool:AcquireObject()
      self.savedVars.items[i].control:ClearAnchors()
      self.savedVars.items[i].control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVars.items[i].window.x, self.savedVars.items[i].window.y)
      self.savedVars.items[i].control:SetDimensions(self.savedVars.items[i].window.w, self.savedVars.items[i].window.h)
      self.savedVars.items[i].control:GetNamedChild("Id"):SetText(self.savedVars.items[i].id)
      self.savedVars.items[i].control:GetNamedChild("Icon"):SetText(zo_iconFormat(GetItemLinkIcon(self.savedVars.items[i].itemLink), self.GetIconSize(self.savedVars.items[i].window)))
      self.savedVars.items[i].control:GetNamedChild("Count"):SetText(self.GetItemCountFromItemLink(self.savedVars.items[i].itemLink))
      self.savedVars.items[i].control:SetHandler("OnMouseDown", self.OnRightClicked)
      self.savedVars.items[i].control:SetHandler("OnMoveStop", self.OnMoveStop)
      self.savedVars.items[i].control:SetHandler("OnResizeStop", self.OnResizeStop)
      if (self.savedVars.show and self.savedVars.actionLayer) then
        self.savedVars.items[i].control:SetHidden(false)
      end
      i = i + 1
    end
  end
end

----- Misc Functions -----

function FollowItem.GetIconSize(window)
  local w = 40 * (window.w / 100)
  local h = 40 * (window.h / 60)
  
  if (w < h) then
    return w, w
  elseif (h < w) then
    return h, h
  else
    return w, h
  end
end

function FollowItem:GetIndexFromId(id)
  if (self.savedVars.items) then
    local i = 1
    while (i <= #self.savedVars.items) do
      if (self.savedVars.items[i].id == id) then
        return i
      end
      i = i + 1
    end
  end
  return nil
end

function FollowItem:CheckIfItemIsFollowed(itemLink)
	if (self.savedVars.items) then
		local id = select(4, ZO_LinkHandler_ParseLink(itemLink))
		local i = 1
		while (i <= #self.savedVars.items) do
			if (self.savedVars.items[i].id == id) then
				return true
			end
			i = i + 1
		end
	end
	return false
end

function FollowItem.GetItemCountFromItemLink(itemLink)
	local a, b, c = GetItemLinkStacks(itemLink)
	local total = a + b + c
	return (total)
end

----- Add/Delete Functions -----

function FollowItem:AddFollowItem(itemLink)
	local id = 1
	if (self.savedVars.items) then
		id = #self.savedVars.items + 1
	end
	self.savedVars.items[id] = {
		id = select(4, ZO_LinkHandler_ParseLink(itemLink)),
		itemLink = itemLink,
		control = self.pool:AcquireObject(),
    window = {}
	}
  local x, y = self.savedVars.items[id].control:GetScreenRect()
  local w, h = self.savedVars.items[id].control:GetDimensions()
  self.savedVars.items[id].window.x = x
  self.savedVars.items[id].window.y = y
  self.savedVars.items[id].window.w = w
  self.savedVars.items[id].window.h = h
  self.savedVars.items[id].control:GetNamedChild("Id"):SetText(self.savedVars.items[id].id)
	self.savedVars.items[id].control:GetNamedChild("Icon"):SetText(zo_iconFormat(GetItemLinkIcon(itemLink), 40, 40))
	self.savedVars.items[id].control:GetNamedChild("Count"):SetText(self.GetItemCountFromItemLink(itemLink))
  self.savedVars.items[id].control:SetHandler("OnMouseDown", self.OnRightClicked)
  self.savedVars.items[id].control:SetHandler("OnMoveStop", self.OnMoveStop)
  self.savedVars.items[id].control:SetHandler("OnResizeStop", self.OnResizeStop)
  if (self.savedVars.show and self.savedVars.actionLayer) then
    self.savedVars.items[id].control:SetHidden(false)
  end
end

function FollowItem:DeleteFollowedItem(itemLink)
	if (self.savedVars.items) then
		local id = select(4, ZO_LinkHandler_ParseLink(itemLink))
		local i = 1
		while (i <= #self.savedVars.items) do
			if (self.savedVars.items[i].id == id) then
				self.savedVars.items[i].control:SetHidden(true)
				table.remove(self.savedVars.items, i)
				return
			end
			i = i + 1
		end
	end
end

----- On Event Functions -----

function FollowItem.OnShowHideCommand()
  if (FollowItem.savedVars.show) then
    FollowItem.savedVars.show = false
    if (FollowItem.savedVars.items and FollowItem.savedVars.actionLayer) then
      local i = 1
      while (i <= #FollowItem.savedVars.items) do
        FollowItem.savedVars.items[i].control:SetHidden(true)
        i = i + 1
      end
    end
  else
    FollowItem.savedVars.show = true
    if (FollowItem.savedVars.items and FollowItem.savedVars.actionLayer) then
      local i = 1
      while (i <= #FollowItem.savedVars.items) do
        FollowItem.savedVars.items[i].control:SetHidden(false)
        i = i + 1
      end
    end
  end
end

function FollowItem.OnActionLayerPushed(event, layerIndex, activeLayerIndex)
  if (layerIndex ~= 7) then
    FollowItem.savedVars.actionLayer = false
    if (FollowItem.savedVars.items and FollowItem.savedVars.show) then
      local i = 1
      while (i <= #FollowItem.savedVars.items) do
        FollowItem.savedVars.items[i].control:SetHidden(true)
        i = i + 1
      end
    end
  end
end

function FollowItem.OnActionLayerPopped(event, layerIndex, activeLayerIndex)
  if (layerIndex ~= 7) then
    FollowItem.savedVars.actionLayer = true
    if (FollowItem.savedVars.items and FollowItem.savedVars.show) then
      local i = 1
      while (i <= #FollowItem.savedVars.items) do
        FollowItem.savedVars.items[i].control:SetHidden(false)
        i = i + 1
      end
    end
  end
end

function FollowItem.OnResizeStop(control)
  local id = control:GetNamedChild("Id"):GetText()
  local i = FollowItem:GetIndexFromId(id)
  local w, h = control:GetDimensions()
  FollowItem.savedVars.items[i].window.w = w
  FollowItem.savedVars.items[i].window.h = h
  FollowItem.savedVars.items[i].control:GetNamedChild("Icon"):SetText(zo_iconFormat(GetItemLinkIcon(FollowItem.savedVars.items[i].itemLink), FollowItem.GetIconSize(FollowItem.savedVars.items[i].window)))
  FollowItem.OnMoveStop(control)
end

function FollowItem.OnMoveStop(control)
  local id = control:GetNamedChild("Id"):GetText()
  local i = FollowItem:GetIndexFromId(id)
  local x, y = control:GetScreenRect()
  FollowItem.savedVars.items[i].window.x = x
  FollowItem.savedVars.items[i].window.y = y
end

function FollowItem.OnRightClicked(control, button, ctrl, alt, shift, command)
  if (button == 2) then
    local id = control:GetNamedChild("Id"):GetText()
    local i = FollowItem:GetIndexFromId(id)
    FollowItem.savedVars.items[i].control:SetHidden(true)
    table.remove(FollowItem.savedVars.items, i)
  end
end

function FollowItem.OnInventoryUpdate(event, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if (FollowItem.savedVars.items) then
		local i = 1
		while i <= #FollowItem.savedVars.items do
			FollowItem.savedVars.items[i].control:GetNamedChild("Count"):SetText(FollowItem.GetItemCountFromItemLink(FollowItem.savedVars.items[i].itemLink))
			i = i + 1
		end
	end
end

function FollowItem.OnAddOnLoaded(eventCode, addOnName)
  if (addOnName ~= FollowItem.name) then return end
  EVENT_MANAGER:UnregisterForEvent(FollowItem.name, EVENT_ADD_ON_LOADED)
  FollowItem.savedVars = ZO_SavedVars:New("FollowItemSavedVars", 2, nil, {items = {}, show = true, actionLayer = true})
  FollowItem.pool = ZO_ObjectPool:New(function(objectPool)
    return ZO_ObjectPool_CreateNamedControl("FollowItemWindow", "FollowItemTemplate", objectPool, GuiRoot)
  end)
  EVENT_MANAGER:RegisterForEvent(FollowItem.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, FollowItem.OnInventoryUpdate)
  EVENT_MANAGER:RegisterForEvent(FollowItem.name, EVENT_ACTION_LAYER_PUSHED, FollowItem.OnActionLayerPushed)
	EVENT_MANAGER:RegisterForEvent(FollowItem.name, EVENT_ACTION_LAYER_POPPED, FollowItem.OnActionLayerPopped)
  FollowItem:ReloadAllItems()
end

----- Add Context Menu Option -----

function FollowItem.AddContextMenuOption(rowControl)
	local bagId = rowControl.bagId
	local slotIndex = rowControl.slotIndex
	local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
  
	if (FollowItem:CheckIfItemIsFollowed(itemLink)) then
		AddCustomMenuItem(GetString(SI_FOLLOWITEM_ITEM_UNFOLLOW_OPTION), function()
			FollowItem:DeleteFollowedItem(itemLink)
		end)
	else
		AddCustomMenuItem(GetString(SI_FOLLOWITEM_ITEM_FOLLOW_OPTION), function()
			FollowItem:AddFollowItem(itemLink)
		end)
	end
  
	ShowMenu(self)
end

----- Inventory Context Menu Hook -----

local function AddContextMenuOptionSoon(rowControl)
	zo_callLater(function() FollowItem.AddContextMenuOption(rowControl) end, 0)
end

ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)

----- On AddOn Loaded Event -----

EVENT_MANAGER:RegisterForEvent(FollowItem.name, EVENT_ADD_ON_LOADED, FollowItem.OnAddOnLoaded)