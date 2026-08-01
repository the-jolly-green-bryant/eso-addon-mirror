--[[------------------------------------------------------------------------------------------------
Title:          Settings
Author:         Static_Recharge
Description:    Creates and controls the settings menu and related saved variables.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local WM = WINDOW_MANAGER
local SM = SCENE_MANAGER
local LCM = LibCustomMenu
local EM = EVENT_MANAGER
local SI = SHARED_INVENTORY


--[[------------------------------------------------------------------------------------------------
Queue Object Initialization
Queue    													                - Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :OnMoveStop()                                  - Stores the new window position.
├─ :RestoreWindow()                               - Restores the window position.
├─ :ResetPosition()                               - Resets the window position.
├─ :ShowWindow()                                  - Shows/Hides or Toggles the window.
├─ :UpdateScrollList()                            - Updates the Queue list.
├─ :Remove(index)                                 - Removes the indexed item from the list.
├─ :ShowTooltip(index)                            - Shows the tooltip for the indexed item.
├─ :HideTooltip()                                 - Hides the tooltip.
├─ :ContextMenu(rowControl, slotActions)          - Adds the context menu entry.
├─ :Add()                                         - Adds the furniture item to the Queue from the context menu. Only works from inventory scene.
├─ :DepositQueue()                                - Automatically deposits the Queue into the furnishing vault.
├─ :OnPlayerActivated(initial)                    - If first load clears the Queue.
└─ :GetParent()                                   - Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
local Queue = {}


--[[------------------------------------------------------------------------------------------------
Queue:Initialize(Parent)
Inputs:				Parent 															- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Queue:Initialize(Parent)
  self.Parent = Parent
  self.eventSpace = "SFIQueue"
  self.ListPool = {}

  -- Controls
  local w = GetControl("SFI_Queue_Window")
  self.C = {
    Window = w,
    CloseButton = GetControl(w, "CloseButton"),
    ScrollBox = GetControl(w, "ScrollBox"),
  }

  -- Libraries
  LCM:RegisterContextMenu(function(...) self:ContextMenu(...) end)

  -- Events and Callbacks
  self:DepositQueue()
  EM:RegisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED, function(_, ...) self:OnPlayerActivated(...) end)

  -- Slash Commands
  SLASH_COMMANDS["/sfiqueue"] = function() self:ShowWindow() end

  self:RestoreWindow()

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Queue:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Queue:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Queue:OnMoveStop()
Inputs:				None
Outputs:			None
Description:	Stores the new window position.
------------------------------------------------------------------------------------------------]]--
function Queue:OnMoveStop()
  local Parent = self:GetParent()
  local sv = Parent.SV
  local c = self.C
  sv.queueLeft = c.Window:GetLeft()
	sv.queueTop = c.Window:GetTop()
end


--[[------------------------------------------------------------------------------------------------
Queue:RestoreWindow()
Inputs:				None
Outputs:			None
Description:	Restores the window position.
------------------------------------------------------------------------------------------------]]--
function Queue:RestoreWindow()
  local Parent = self:GetParent()
  local sv = Parent.SV
  local c = self.C
  local left = sv.queueLeft
	local top = sv.queueTop
	if left ~= nil and top ~= nil then
		c.Window:ClearAnchors()
		c.Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  else
    c.Window:ClearAnchors()
    c.Window:SetAnchor(CENTER, GuiRoot, CENTER)
	end
end


--[[------------------------------------------------------------------------------------------------
Queue:ResetPosition()
Inputs:				None
Outputs:			None
Description:	Resets the window position.
------------------------------------------------------------------------------------------------]]--
function Queue:ResetPosition()
  local Parent = self:GetParent()
  local sv = Parent.SV
  sv.queueLeft = nil
  sv.queueTop = nil
  self:RestoreWindow()
end


--[[------------------------------------------------------------------------------------------------
Queue:ShowWindow()
Inputs:				show                                - (optional) forces the window to show if true.
Outputs:			None
Description:	Shows/Hides or Toggles the window.
------------------------------------------------------------------------------------------------]]--
function Queue:ShowWindow(show)
  local Parent = self:GetParent()
  local c = self.C
  if show == nil then
    c.Window:SetHidden(not c.Window:IsHidden())
  else
    c.Window:SetHidden(not show)
  end
  if c.Window:IsHidden() then
    SM:SetInUIMode(false)
  else
    self:UpdateScrollList()
    SM:SetInUIMode(true)
  end
end


--[[------------------------------------------------------------------------------------------------
Queue:UpdateScrollList()
Inputs:				None
Outputs:			None
Description:	Updates the Queue list.
------------------------------------------------------------------------------------------------]]--
function Queue:UpdateScrollList()
  local Parent = self:GetParent()
	for i,v in pairs(self.ListPool) do
		v:SetHidden(true)
	end
	local parent = self.C.ScrollBox
	local name = "SFIQueueListEntry"
	local template = "SFIQueueList"
	for i,v in ipairs(Parent.SV.Queue) do
		local c = {}
		if self.ListPool[i] then
			c = self.ListPool[i]
		else
			c = WM:CreateControlFromVirtual(name, parent, template, i)
			c:SetParent(self.C.ScrollBox:GetNamedChild("ScrollChild"))
			table.insert(self.ListPool, c)
			c:ClearAnchors()
			c:SetAnchor(TOPLEFT, ScrollBoxScrollChild, TOPLEFT, 4, (i-1) * 32)
		end
		c:SetText(zo_strformat("|t24:24:<<1>>|t <<2>>", v.icon, v.link))
		c:SetHidden(false)
		c:SetHandler("OnMouseUp", function(self_, button) if button == 2 then self:Remove(i) end end)
		c:SetHandler("OnMouseEnter", function(self_) self:ShowTooltip(i) end)
		c:SetHandler("OnMouseExit", function(self_) self:HideTooltip() end)
	end
end


--[[------------------------------------------------------------------------------------------------
Queue:Remove(index)
Inputs:				index                               - the index of the item to remove from the Queue
Outputs:			None
Description:	Removes the indexed item from the list.
------------------------------------------------------------------------------------------------]]--
function Queue:Remove(index)
  local Parent = self:GetParent()
	table.remove(Parent.SV.Queue, index)
	self:UpdateScrollList()
end


--[[------------------------------------------------------------------------------------------------
Queue:ShowTooltip(index)
Inputs:				index                               - the index of the item to show
Outputs:			None
Description:	Shows the tooltip for the indexed item.
------------------------------------------------------------------------------------------------]]--
function Queue:ShowTooltip(index)
  local Parent = self:GetParent()
	local itemLink = Parent.SV.Queue[index].link
	InitializeTooltip(ItemTooltip, self.C.Window, RIGHT, -5, 0, LEFT)
	ItemTooltip:SetLink(itemLink)
end


--[[------------------------------------------------------------------------------------------------
Queue:HideTooltip()
Inputs:				None
Outputs:			None
Description:	Hides the tooltip.
------------------------------------------------------------------------------------------------]]--
function Queue:HideTooltip()
	ClearTooltip(ItemTooltip)
end


--[[------------------------------------------------------------------------------------------------
Queue:ContextMenu(rowControl, slotActions)
Inputs:				rowControl                          - inventory slot information
              slotActions                         - slot actions to add to
Outputs:			None
Description:	Adds the context menu entry.
------------------------------------------------------------------------------------------------]]--
function Queue:ContextMenu(rowControl, slotActions)
  local Parent = self:GetParent()
	local bagId = rowControl.bagId
	local index = rowControl.slotIndex
	local itemType = GetItemType(bagId, index)
  local link = GetItemLink(bagId, index)
  local scene = SM:GetCurrentScene()
  if itemType ~= ITEMTYPE_FURNISHING or scene ~= Parent.Scenes.inventoryScene then return end
  AddCustomMenuItem("Add to Vault Queue" , function() self:Add(link) end, MENU_ADD_OPTION_LABEL)
  --ShowMenu(rowControl)
end


--[[------------------------------------------------------------------------------------------------
Queue:Add()
Inputs:				link                                - item to add to the Queue
Outputs:			None
Description:	Adds the furniture item to the Queue from the context menu. Only works from inventory scene.
------------------------------------------------------------------------------------------------]]--
function Queue:Add(link)
  local Parent = self:GetParent()
  local id = GetItemLinkItemId(link)
  local icon = GetItemLinkInfo(link)
  local data = {
    link = link,
    icon = icon,
    id = id,
  }
	table.insert(Parent.SV.Queue, data)
  Parent.Chat:Msg(zo_strformat("<<1>> added to the Vault Queue.", link))
  self:UpdateScrollList()
  if Parent.SV.queueShowAfterAdd then
    self:ShowWindow(true)
  end
end


--[[------------------------------------------------------------------------------------------------
Queue:DepositQueue()
Inputs:				None
Outputs:			None
Description:	Automatically deposits the Queue into the furnishing vault.
------------------------------------------------------------------------------------------------]]--
function Queue:DepositQueue()
  local Parent = self:GetParent()
	Parent.Scenes.furnitureVaultScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING and #Parent.SV.Queue > 0 then
			local backpackCache = SI:GetOrCreateBagCache(BAG_BACKPACK)
      while #Parent.SV.Queue > 0 do
        local found = false
        local qID = Parent.SV.Queue[1].id
        local qLink = Parent.SV.Queue[1].link
        for backpackIndex, backpackData in pairs(backpackCache) do
          local backpackID = GetItemId(BAG_BACKPACK, backpackIndex)
          local link = GetItemLink(BAG_BACKPACK, backpackIndex)
          local _, backpackQty = GetItemInfo(BAG_BACKPACK, backpackIndex)
          Parent.Chat:Debug(zo_strformat("qID: <<1>>, backpackID: <<2>>", qID, backpackID))
          if qID == backpackID then
            if IsProtectedFunction("PickupInventoryItem") then
              CallSecureProtected("PickupInventoryItem", BAG_BACKPACK, backpackIndex)
            else
              PickupInventoryItem(BAG_BACKPACK, backpackIndex)
            end
            if IsProtectedFunction("PlaceInTransfer") then
              CallSecureProtected("PlaceInTransfer")
            else
              PlaceInTransfer()
            end
            Parent.Chat:Msg(zo_strformat("<<1>> x<<2>> moved to furnishing vault.", link, backpackQty))
            found = true
          end	
        end
        if not found then
          Parent.Chat:Msg(zo_strformat("<<1>>not found in inventory.", link))
        end
        table.remove(Parent.SV.Queue, 1)
      end
      Parent.Chat:Msg("Item transfers from Queue finished.")
      self:UpdateScrollList()
		end
	end)
end


--[[------------------------------------------------------------------------------------------------
Queue:OnPlayerActivated(initial)
Inputs:				initial                             - true if this is the first load from login
Outputs:			None
Description:	If first load clears the Queue.
------------------------------------------------------------------------------------------------]]--
function Queue:OnPlayerActivated(initial)
  local Parent = self:GetParent()
  if initial then
    Parent.SV.Queue = {}
  end
  EM:UnregisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
Queue:GetParent()
Inputs:				None
Outputs:			Parent          										- The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Queue:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
StaticsFurnishingImprovements.Queue = Queue