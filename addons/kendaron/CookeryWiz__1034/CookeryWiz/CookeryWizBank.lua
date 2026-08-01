local L = CookeryWizLanguage.language

-- there should only ever be one of these!
local callbackRegistrations = nil
local events = nil

local COLLECT_STATE_FETCHING = 0
local COLLECT_STATE_FETCHED = 1
local COLLECT_STATE_SPLITTING = 2
local COLLECT_STATE_ERROR_SPLITTING = 3
local COLLECT_STATE_RETURNING = 4
local COLLECT_STATE_COMPLETE = 5

CookeryWizBank = {}
CookeryWizBank.writItem = nil
CookeryWizBank.isBankOpen = false
CookeryWizBank.collectingItem = nil
CookeryWizBank.collectCount = 0


CookeryWizBank.fetchDelay = 0
CookeryWizBank.currentFetchDelay = 0

-- We now have to process two bags. One for normal ESO users and an additional one for subscribers
CookeryWizBank.currentBagId = BAG_BANK

CookeryWizBank.traceEnabled = false
local function trace(msg)
    if CookeryWizBank.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end


---------------------------------------------------------------------
-- Function: Register
--
-- This function is called when an object wants to register itself
-- for callback events related to the bank
-- A unique key is passed (usually the addon name) 
-- The callback object is stored and various callback routine called on it when
-- an ESO event occurs
---------------------------------------------------------------------
function CookeryWizBank:Register(key, object)
  trace("Register:Key["..key.."]")

  local callback
  
  if not object then
    d("A callback object must be passed")
    return
  end
   
  if not callbackRegistrations then
    trace("Creating registrations object")
    callbackRegistrations = CookeryWizRegistrations:new()
  end
  
  callback = callbackRegistrations:Register(key, self)
  if callback then
    callback.parentObject = object
  end

end

---------------------------------------------------------------------
-- Function: OnRegister
--
-- This function is called via the registrations object when the object
-- is registered
---------------------------------------------------------------------
function CookeryWizBank:OnRegister(count, object, ...)
  trace("OnRegister:Count["..count.."]")
  if count == 1 then
    trace("Registering for bank events")
    if not events then
      trace("Creating new events object")
      events = CookeryWizEvents:new()
    end      
  
    events:RegisterEvent(EVENT_OPEN_BANK, function(...)
      self:OnOpenBank(...)
    end)
  
    events:RegisterEvent(EVENT_CLOSE_BANK, function(...)
      self:OnCloseBank(...)
    end) 
  
    -- now enable them
    events:EnableAllEvents(true)
  end
end

---------------------------------------------------------------------
-- Function: Unregister
--
-- This function is called when an object wants to unregister itself
-- from callbacks
---------------------------------------------------------------------
function CookeryWizBank:Unregister(key)
  trace("Unregister:Key["..key.."]")  
  
  if callbackRegistrations then
    callbackRegistrations:Unregister(key)
  end
end

---------------------------------------------------------------------
-- Function: OnUnregister
--
-- This function is called via the registrations object when it has
-- become unregistered
---------------------------------------------------------------------
function CookeryWizBank:OnUnregister(count, callback)
  trace("OnUnregister:Count["..count.."]")
  if count == 0 and events then
    trace("No more registrations, Unregistering Bank events")   
    -- remove registration
    events:UnregisterEvent(EVENT_OPEN_BANK)
    events:UnregisterEvent(EVENT_CLOSE_BANK)
  end 
end

---------------------------------------------------------------------
-- Function: CountItemsInBagFromId
--
-- This function counts the number of matching items in a bag and
-- return the number from backpack, bank and also the item link
---------------------------------------------------------------------
function CookeryWizBank:CountItemsInBagFromId(bagId, id, name)
  trace("CountItemsInBagFromId["..bagId.."]-"..id)
  local countBackpack, countBank
  local link
  
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    -- the fid items are stored as default type links
		local itemLink = GetItemLink(bagId, i, LINK_STYLE_BRACKETS )
    local itemLinkId = CookeryWizUtils:GetItemID(itemLink)
    local itemLinkName = zo_strformat("<<1>>", GetItemName(bagId, i)):lower()
    if id == itemLinkId and ( not name or name == "" or name == itemLinkName) then
      -- make sure we match on name too, if we have it      
      countBackpack, countBank = GetItemLinkStacks(itemLink)
      return countBackpack, countBank, itemLink
    end
	end
 
end

---------------------------------------------------------------------
-- Function: CountItemsInBagFromName
--
-- This function counts the number of matching items in a bag and
-- return the number from backpack, bank and also the item link
---------------------------------------------------------------------
function CookeryWizBank:CountItemsInBagFromName(bagId, name)
  trace("CountItemsInBagFromName["..bagId.."]-"..name)
  name = name:lower()
  local countBackpack, countBank
  local link
  
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    -- the fid items are stored as default type links
		local itemLink = GetItemLink(bagId, i, LINK_STYLE_BRACKETS )
    --local itemLinkId = self:GetItemID(itemLink)
    local itemLinkName = GetItemName(bagId, i):lower()
    if name == itemLinkName then
      countBackpack, countBank = GetItemLinkStacks(itemLink)
      return countBackpack, countBank, itemLink
    end
	end
 
end

--[[
function CookeryWizBank:ResolveLinkFromName(bagId, name)
  
  name = name:lower()
  --trace("Looking for ["..name.."]")
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    local itemLink = GetItemLink(bagId, i, LINK_STYLE_BRACKETS)
    local itemName = GetItemName(bagId, i)
    local itemLinkName = zo_strformat("<<1>>", itemName):lower()  --GetItemLinkName(itemLink) --GetItemName(bagId, i):lower()
    --trace(i..":- item is ["..itemLinkName.."]")
    if name == itemLinkName then
      return GetItemLink(bagId, i, LINK_STYLE_BRACKETS )
    end
	end 
end
]]--

-- attempt to find the item from the name or id or both
-- name is not enough to uniquely identify (loot potions vs crafted)
-- id is not enough to uniquely identify (crafted potion)
-- so be as precise as possible
function CookeryWizBank:ResolveLink(bagId, item)
  local id = item.id
  local name = item.name
  local nameLower = name:lower()  
  
  --trace("Looking for ["..name.."]")
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    local itemLink = zo_strformat("<<1>>", GetItemLink(bagId, i, LINK_STYLE_BRACKETS))
    local itemId = CookeryWizUtils:GetItemID(itemLink)
    local itemName = zo_strformat("<<1>>", GetItemName(bagId, i))
    local itemLinkName = itemName:lower()
    --trace(i..":- item is ["..itemLinkName.."]")
    local haveName = (name and name ~= "")
    local matchedName = (nameLower == itemLinkName)
    local matchedId = (id == itemId)
    local matched = false
    
    -- if we have a name and an id then it has to match both
    if haveName and id then
      if matchedName and matchedId then
        matched = true
      end
    else
      if (haveName and matchedName) or (id and matchedId) then      
        matched = true
      end
    end
    
    if matched then
      item.nameLower = nameLower
      item.link = itemLink
    end
	end 
end


function CookeryWizBank:FindItemInBag(bagId, item)
  trace("FindItemInBag")
  -- NOTE: if the stacks are split it becomes more complex, assume it is in one stack
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    local itemLink = zo_strformat("<<1>>", GetItemLink(bagId, i))
    local itemName = zo_strformat("<<1>>", GetItemName(bagId, i)):lower()        
    local itemId = CookeryWizUtils:GetItemID(itemLink)
    if item.id == itemId and item.nameLower == itemName then
      return i
    end
	end 
end


---------------------------------------------------------------------
-- Function: CollectItem
--
-- When an item is found to exist, this routine will attempt to collect
-- it from the bank.
-- An item must have one of the following:
-- A valid link that fully represents the item to collect
-- An exact name match that fully represents the item to collect
-- The id of the item to collect and optionally the exact name
---------------------------------------------------------------------
function CookeryWizBank:CollectItem(item)
  -- store a reference to the item we are collecting
  self.collectingItem = item
  
  -- if we dont have a link, resolve it from name and id, or either
  if not item.link then
    self:ResolveLink(self.currentBagId, item)    
  end
  
  if not item.link then
    trace("Failed resolving item link from name or does not exist in bank/bag")    
    self:Collect()
    return
  end
  
  -- if we dont have an id, resolve it
  if not item.id then
    item.id = CookeryWizUtils:GetItemID(item.link)
  end
  
  if not item.nameLower then
    -- dont use the link as it could be a generic link (ie for crafted potion)
    -- unless we have to
    if not item.name then
      item.name = zo_strformat("<<1>>", GetItemLinkName(item.link))
    end
    item.nameLower = item.name:lower()
  end
  
  if not item.id or not item.nameLower or item.nameLower == "" then
    trace("Failed resolving item.id and or name from link or does not exist in bank/bag")    
    self:Collect()
    return
  end
  
  -- do we have enough space?
  item.emptyBackPackSlot = FindFirstEmptySlotInBag(BAG_BACKPACK) 
  if not item.emptyBackPackSlot then
    d(string.format(L[CWL_NOTIFY_NO_BAG_SPACE], self.name))
    return
  end
  
  -- we may have no link but an id (such as a crafted potion)
  local display
  --if item.link then
    display = item.link
  --else
    --display = item.name
  --end
  
  local text = string.format(L[CWL_BUTTON_GUILDBANK_COLLECTING_WRIT_FOOD], item.link)
  trace(text)  
    
  -- in case the user stops accessing the bank before we are complete
  if not self.isBankOpen then
    trace("Bank is no longer open")
    return
  end
  
  -- get the exisiting number of items so we can calculate how many need to be returned
  -- at this point we have the link, id and name
  local stackCountBackpack, stackCountBank = GetItemLinkStacks(item.link)

  trace("stackCountBackpack["..stackCountBackpack.."],stackCountBank["..stackCountBank.."]")
  
  -- find the location of the item in the bank
  -- remember the link must be exact
  item.bankSlotId = self:FindItemInBag(self.currentBagId, item)
  if not item.bankSlotId then
    trace("Item is not in bank")
    self:Collect()
    return
  end
  
  local count = item.count
  if count > stackCountBank then
    count = stackCountBank
  end
  
  trace("Bank is open. Moving "..display.." from bankslot["..item.bankSlotId.."] to backpackslot["..item.emptyBackPackSlot.."], count["..count.."]")
  item.state = COLLECT_STATE_FETCHING
  if IsProtectedFunction("RequestMoveItem") then
    local res = CallSecureProtected("RequestMoveItem", self.currentBagId, item.bankSlotId, BAG_BACKPACK, item.emptyBackPackSlot, count)
    if res then
      trace("Successfully called RequestMoveItem");
    else
      trace("Failed calling RequestMoveItem");
    end
  else
    RequestMoveItem (self.currentBagId, itemData.slotIndex, BAG_BACKPACK, self.bankFoodSlot, item.count) 
  end
  
end

---------------------------------------------------------------------
-- Function: OnInventorySingleSlotUpdate
--
-- This function is called when items have been collected from the bank
---------------------------------------------------------------------
function CookeryWizBank:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
  trace("OnInventorySingleSlotUpdate["..eventCode.."], bagId["..bagId.."], slot["..slotId.."], currentBagId["..tostring(self.currentBagId))
  
  if bagId == BAG_BACKPACK and self.collectingItem and self.collectingItem.emptyBackPackSlot == slotId then
    trace("Item arrived. Notifying callback")
    self.collectingItem.state = COLLECT_STATE_COMPLETE
    trace("Collecting again")
    self:Collect()
  elseif self.fetchDelay ~= 0 and self.fetchDelay ~= nil then
    -- some other addon is doing stuff so delay
    trace("Reset the fetch delay")
    self.currentFetchDelay = self.fetchDelay
  end
  
end

---------------------------------------------------------------------
-- Function: Collect
--
-- Main routine called to perform the collection process from the
-- guild bank. Will keep calling iteself until all items are processed
---------------------------------------------------------------------
function CookeryWizBank:Collect()
  
  if self.collectCount > 20 then
    return
  end
  self.collectCount = self.collectCount + 1
  
  -- make sure bank is open
  if not self.isBankOpen then
    trace("Bank is not open. Ending collect process")
    return
  end
  
  local callback = callbackRegistrations:GetCurrentCallback()
  if not callback then
    trace("No more items to collect.")
    if self.currentBagId == BAG_BANK then
      local usableCount = GetBagUseableSize(BAG_SUBSCRIBER_BANK)
      trace("- Trying subscriber bag. Usable Count["..usableCount.."]")
      if usableCount > 0 then
        trace("- user is subscriber. Processing subscriber bank")
        -- Process BAG_SUBSCRIBER_BANK
        self:BeginCollection(BAG_SUBSCRIBER_BANK)
      end
    end
    return
  end
  
  -- still working on the current callback object?
  if callback then
    --d("Callback type["..type(callback).."]")
    -- have we finished with the last item?
    if self.collectingItem then
      if callback.parentObject.OnItemFetched then 
        if self.collectingItem.state == COLLECT_STATE_COMPLETE then
          callback.parentObject:OnItemFetched(self.collectingItem, true)
        elseif self.collectingItem.state ~= COLLECT_STATE_COMPLETE then
          callback.parentObject:OnItemFetched(self.collectingItem, false)
        end        
      end
      self.collectingItem = nil
    end
    -- do we have space?
    if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
      d(string.format(L[CWL_NOTIFY_NO_BAG_SPACE], L[CWL_COOKERYWIZ_NAME]))
      return
    end
    
    -- do we want to collect on this object?
    local item
    if callback.parentObject.OnItemToFetch then 
      item = callback.parentObject:OnItemToFetch()
    end
    
    if not item then
      trace("No more items to fetch for this object. Move on to next")
      callbackRegistrations:GetNextCallback()
    else
      -- make sure it is correctly formed
      if not item.count or (not item.link and not item.name) then
        d("Item from OnItemToFetch is malformed. Must have count and link/name fields")
      else
        if item.link then
          trace("Item "..item.link.." returned")
          item.id = CookeryWizUtils:GetItemID(item.link)
        else
          trace("Item "..item.name.." returned")
        end
        --if item.id then
          trace("Good to start processing this item!")
          self:CollectItem(item)
          return
        --else
          --d("Invalid item link passed")
        --end        
      end      
    end    
  --else
    --if not callbackRegistrations:GetNextCallback() then
      --trace("No more items to be collected")
      --return
    --end
  end

  -- Collect again till finished
  self:Collect()  
end

---------------------------------------------------------------------
-- ESO Event Handlers
---------------------------------------------------------------------


---------------------------------------------------------------------
-- Function: SetFetchDelay
--
-- This function sets a delay for when the bank open event is notified
-- to callback objects. This allows for other addons to do stuff first
---------------------------------------------------------------------
function CookeryWizBank:SetFetchDelay(delay)
  if not delay then
    self.fetchDelay = 0
  else
    self.fetchDelay = delay
  end
  return self.fetchDelay
end

---------------------------------------------------------------------
-- Function: OnOpenBank
--
-- This function is called when the bank is opened.
---------------------------------------------------------------------
function CookeryWizBank:OnOpenBank(eventCode)
  trace("OpenBank")
  
  if not events then
    return
  end
  
  self.isBankOpen = true
  self.collectCount = 0
  
  events:RegisterEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
    self:OnInventorySingleSlotUpdate(...)
  end)
  events:EnableEvents(EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

  -- in case of an alternative bank stacker, should we delay?
  self.currentFetchDelay = self.fetchDelay  
  self:StartCollectionCheck()
end

---------------------------------------------------------------------
-- Function: StartCollectionCheck
--
-- This function is called to check whether we can start the process.
---------------------------------------------------------------------
function CookeryWizBank:StartCollectionCheck()
  trace("StartCollectionCheck")
  if CookeryWiz:IsWritCollectionDisabled() then
    trace("Collection is disabled")
    return
  end

  
  if self.currentFetchDelay ~= 0 and self.currentFetchDelay ~= nil then
    self.currentFetchDelay = 0
    zo_callLater(function()
      trace("CallLater")
      self:StartCollectionCheck()
    end, self.fetchDelay)     
  else
    -- we will start by processing normal bank bag, then move onto BAG_SUBSCRIBER_BANK
    self:BeginCollection(BAG_BANK)
  end
  
end

---------------------------------------------------------------------
-- Function: BeginCollection
--
-- This function is called to start the process.
---------------------------------------------------------------------
function CookeryWizBank:BeginCollection(bagId)
  trace("Begin collection for bagId["..tostring(bagId).."]")
  
  -- store the bag we should use
  self.currentBagId = bagId
  
  -- let objects that have registered that the bank is open so they can prepare
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnPrepareForBank then 
        callback.parentObject:OnPrepareForBank()
      end
    end) 
  
  -- start fetching!
  callbackRegistrations:GetNextCallback()
  self:Collect()  
end

---------------------------------------------------------------------
-- Function: OnCloseBank
--
-- This function is called when the bank is closed.
---------------------------------------------------------------------
function CookeryWizBank:OnCloseBank(eventCode)
  trace("CloseBank")
  self.isBankOpen = false
  self.collectingItem = nil
  
  if events then
    events:UnregisterEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  end

end