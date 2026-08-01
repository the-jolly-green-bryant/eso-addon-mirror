DoItAll = DoItAll or {}

DoItAll.Slots = ZO_Object:Subclass()
DoItAll.Slots.notAllowedSlots = {}
DoItAll.Slots.callExtractAfterEvent = false
DoItAll.Slots.eventActive = false

function DoItAll.Slots:New(filter)
  local obj = ZO_Object.New(self)
    obj.filter = filter
  return obj
end

function DoItAll.Slots:GetCallExtractAfterEvent()
	return self.callExtractAfterEvent
end

function DoItAll.Slots:SetCallExtractAfterEvent(value)
	self.callExtractAfterEvent = value
end

function DoItAll.Slots:GetEventActive()
	return self.eventActive
end

function DoItAll.Slots:SetEventActive(value)
	self.eventActive = value
end

function DoItAll.Slots:InitNotAllowed()
	self.notAllowedSlots = {}
end

function DoItAll.Slots:AddToNotAllowed(bagId, slotIndex)
	if self.notAllowedSlots == nil then self:InitNotAllowed() end
	local notAllowedEntry = {}
    notAllowedEntry.bagId = bagId
    notAllowedEntry.slotIndex = slotIndex
	table.insert(self.notAllowedSlots, notAllowedEntry)
end

function DoItAll.Slots:CheckAllowed(bagId, slotIndex)
	if self.notAllowedSlots == nil then
    	self:InitNotAllowed()
    else
	  	for index, notAllowedSlot in pairs(self.notAllowedSlots) do
	    	if notAllowedSlot.bagId == bagId and notAllowedSlot.slotIndex == slotIndex then
	        	return false
	        end
		end
	end
    return true
end

function DoItAll.Slots:ClearNotAllowed()
	if self.notAllowedSlots == nil then
    	self:InitNotAllowed()
    else
	    self.notAllowedSlots = {}
    end
	return false
end

local function ExtractSlotData(slot)
  return {
    bagId = slot.data.bagId,
    slotIndex = slot.data.slotIndex,
    name = slot.data.name,
    stackCount = slot.data.stackCount
  }
end

--[[
function DoItAll.Slots:Fill(container, limit)
--d("[DoItAll] Slots - Fill")
  self:Init(limit)
  for _, slot in pairs(container.data) do
	--Check if slot is allowed -> Else take the next one
	local allowed = self:CheckAllowed(slot.data.bagId, slot.data.slotIndex)
	if allowed then
	    if self.filter == nil or (self.filter ~= nil and not self.filter:Filter(slot)) then
			table.insert(self.slots, ExtractSlotData(slot))
	    end
	else
		--Increase the limit by 1 if item is not allowed, to get next item
		self.limit = self.limit + 1
	end
	--Is the limit reached?
	if self:ReachedLimit() then
		break
	end
  end
  return not self:Empty()
end
]]
--Compatible with AutoComplete addon's categories inside the inventory list
function DoItAll.Slots:Fill(container, limit)
    self:Init(limit)
    for _, slot in pairs(container.data) do
        local data = slot.data
        --isHeader = added by addon "AutoCategory": collapsable catgory header
        if data.dataEntry and not data.dataEntry.isHeader then
--d(">checking item: " .. GetItemLink(data.bagId, data.slotIndex))
            --Check if slot is allowed -> Else take the next one
            local allowed = self:CheckAllowed(data.bagId, data.slotIndex)
            if allowed then
--d(">>allowed!")
                if self.filter == nil or (self.filter ~= nil and not self.filter:Filter(slot)) then
                    table.insert(self.slots, ExtractSlotData(slot))
                end
            else
                --Increase the limit by 1 if item is not allowed, to get next item
                self.limit = self.limit + 1
            end
            --Is the limit reached?
            if self:ReachedLimit() then
                break
            end
        end
    end
    return not self:Empty()
end

function DoItAll.Slots:Take(slots, limit)
  self:Init(limit)
  while not slots:Empty() and not self:ReachedLimit() do
    local slot = slots:Next()
    table.insert(self.slots, slot)
  end
  return not self:Empty()
end

function DoItAll.Slots:Init(limit)
  self.limit = limit
  self.slots = {}
end

function DoItAll.Slots:ReachedLimit()
  return self.limit ~= nil and table.getn(self.slots) >= self.limit
end

function DoItAll.Slots:Empty()
  return table.getn(self.slots) == 0
end

function DoItAll.Slots:Next()
  return table.remove(self.slots, 1)
end

function DoItAll.Slots:ForEach(fct)
  while not self:Empty() do
    if not fct(self:Next()) then return false end
  end
  return true
end