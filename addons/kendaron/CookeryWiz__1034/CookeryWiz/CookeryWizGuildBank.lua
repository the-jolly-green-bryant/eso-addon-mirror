
local L = CookeryWizLanguage.language

local callbackRegistrations = nil

local ASYNC_KEY_GUILD_COLLECT = "guildCollect"
local ASYNC_KEY_GUILD_STOCKPILE = "guildStockpile"

local COLLECT_STATE_FETCHING = 0
local COLLECT_STATE_FETCHED = 1
local COLLECT_STATE_SPLITTING = 2
local COLLECT_STATE_ERROR_SPLITTING = 3
local COLLECT_STATE_RETURNING = 4
local COLLECT_STATE_COMPLETE = 5

CookeryWizGuildBank = {}

CookeryWizGuildBank.events = nil
CookeryWizGuildBank.lastFullSlotDataCount = 0
CookeryWizGuildBank.enabled = true
CookeryWizGuildBank.collectCount = 0
CookeryWizGuildBank.collectWritFoodControl = nil
CookeryWizGuildBank.collectWritFoodLabel = nil
CookeryWizGuildBank.collectingItem = nil

CookeryWizGuildBank.optionsComboBox = nil
CookeryWizGuildBank.optionsDropdown = nil
  
local fragmentCollectWritFood = nil

CookeryWizGuildBank.traceEnabled = false

local function trace(msg)
    if CookeryWizGuildBank.traceEnabled then
      CookeryWizUtils:Trace(msg)
    end
end


--
-- Event registration functions for global ESO events
-- These functions are local as used internally
--


---------------------------------------------------------------------
-- Function: Register
--
-- This function is called when an object wants to register itself
-- for callback events related to the guild bank.
-- A unique key is passed (usually the addon name) 
-- The callback object is stored and various callback routine called on it when
-- an ESO event occurs
---------------------------------------------------------------------
function CookeryWizGuildBank:Register(key, object)
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
function CookeryWizGuildBank:OnRegister(count, object, ...)
  trace("CookeryWizGuildBank:OnRegister:Count["..count.."]")
  
  if count == 1 then
    trace("Registering for guild bank events")
    if not self.events then
      trace("Creating new events object")
      self.events = CookeryWizEvents:new()
      
      if not fragmentCollectWritFood then
        fragmentCollectWritFood = ZO_FadeSceneFragment:New(CollectWritFood)
        local guildBankScene = SCENE_MANAGER:GetScene("guildBank")
        if guildBankScene then
          trace("Got guild bank scene")
          guildBankScene:AddFragment(fragmentCollectWritFood)
        end
      end      
    end      
  
    self.events:RegisterEvent(EVENT_GUILD_BANK_TRANSFER_ERROR, function(...)
      self:OnGuildBankTransferError(...)
      end)
   
    self.events:RegisterEvent(EVENT_OPEN_GUILD_BANK, function(...)
        self:OnOpenGuildBank(...)
      end)
    
    self.events:RegisterEvent(EVENT_GUILD_BANK_SELECTED, function(...)
        self:OnGuildBankSelected(...)
      end)

    self.events:RegisterEvent(EVENT_GUILD_BANK_ITEMS_READY, function(...)
      self:OnGuildBankItemsReady(...)
    end)

    self.events:RegisterEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
      self:OnInventorySingleSlotUpdate(...)
      end)
    
    self.events:RegisterEvent(EVENT_GUILD_BANK_ITEM_REMOVED, function(...)
      self:OnGuildBankItemRemoved(...)
      end)

    self.events:RegisterEvent(EVENT_GUILD_BANK_ITEM_ADDED, function(...)
      self:OnGuildBankItemAdded(...)
      end)  

    self.events:RegisterEvent(EVENT_GUILD_BANK_UPDATED_QUANTITY, function(...)
      self:OnGuildBankUpdatedQuantity(...)
      end)  

    self.events:RegisterEvent(EVENT_GUILD_BANK_DESELECTED, function(...)
        self:OnGuildBankDeselected(...)
      end)

    self.events:RegisterEvent(EVENT_CLOSE_GUILD_BANK , function(...)
        self:OnCloseGuildBank(...)
      end)
    -- now enable them
    self.events:EnableAllEvents(true)
  end
end

---------------------------------------------------------------------
-- Function: Unregister
--
-- This function is called when an object wants to unregister itself
-- from callbacks
---------------------------------------------------------------------
function CookeryWizGuildBank:Unregister(key)  
  trace("CookeryWizGuildBank:Unregister:Key["..key.."]")  
  
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
function CookeryWizGuildBank:OnUnregister(count, callback)
  trace("CookeryWizGuildBank:OnUnregister:Count["..count.."]")
  if count == 0 and self.events then
    trace("No more registrations, Unregistering Guild Bank events")   
    -- remove registration
    self.events:UnregisterEvent(EVENT_GUILD_BANK_TRANSFER_ERROR)
    self.events:UnregisterEvent(EVENT_OPEN_GUILD_BANK)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_SELECTED)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_ITEMS_READY)
    self.events:UnregisterEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_ITEM_REMOVED)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_ITEM_ADDED)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_UPDATED_QUANTITY)
    self.events:UnregisterEvent(EVENT_GUILD_BANK_DESELECTED)
    self.events:UnregisterEvent(EVENT_CLOSE_GUILD_BANK)
  end 
end

-- Enables/Disables guild bank handling
function CookeryWizGuildBank:Enable(enable)
  -- if at least one wants it enabled, then do not disable
  if self.enabled then
    return
  end
  self.enabled = enable
end

-- Checks whether guild bank handling is enabled or disabled
function CookeryWizGuildBank:IsEnabled()
  return self.enabled
end

---------------------------------------------------------------------
-- Function: ResetGuildBankVariables
--
-- Resets status variables used int he guild bank collection process
---------------------------------------------------------------------
function CookeryWizGuildBank:ResetGuildBankVariables()
  self.currentGuildBankId = nil
  self.lastFullSlotDataCount = 0
  self.collectingItem = nil
  self.collectCount = 0
end

--[[
function CookeryWizGuildBank:UnregisterEventsIndividually()
  self.events:UnregisterEvents(
    EVENT_GUILD_BANK_TRANSFER_ERROR, EVENT_OPEN_GUILD_BANK, EVENT_GUILD_BANK_SELECTED,
    EVENT_GUILD_BANK_ITEMS_READY, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EVENT_GUILD_BANK_ITEM_REMOVED,
    EVENT_GUILD_BANK_ITEM_ADDED, EVENT_GUILD_BANK_UPDATED_QUANTITY, EVENT_GUILD_BANK_DESELECTED,
    EVENT_CLOSE_GUILD_BANK
  )
end
]]--

function CookeryWizGuildBank:ResolveLinkFromName(name)  
  name = name:lower()
  --trace("Looking for ["..name.."]")
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    local itemLink = GetItemLink(bagId, i)
    local itemName = GetItemName(bagId, i)
    local itemLinkName = zo_strformat("<<1>>", itemName):lower()  --GetItemLinkName(itemLink) --GetItemName(bagId, i):lower()
    --trace(i..":- item is ["..itemLinkName.."]")
    if name == itemLinkName then
      return GetItemLink(bagId, i, LINK_STYLE_BRACKETS )
    end
	end
 
end

function CookeryWizGuildBank:Dump(itemType)
 local slotId = GetNextGuildBankSlotId()
  if not slotId then
    trace("No SlotId returned from GetNextGuildBankSlotId")
  end
  
  while slotId do
    local slotItemLink = GetItemLink(BAG_GUILDBANK, slotId, LINK_STYLE_DEFAULT )
    local slotItemType = GetItemLinkItemType(slotItemLink)
    if not itemType or itemType == slotItemType then
      local slotItemName = GetItemName(BAG_GUILDBANK, slotId)
      local slotItemId = CookeryWizUtils:GetItemID(slotItemLink)     
      trace("Name["..slotItemName.."]")
    end
    slotId = GetNextGuildBankSlotId(slotId)
  end  
end

---------------------------------------------------------------------
-- Function: DumpRegistrations
--
-- Displays registered objects
---------------------------------------------------------------------
function CookeryWizGuildBank:DumpRegistrations() 
  callbackRegistrations:Enumerate(function(callback)
    d(callback.key)
    end)   

end

function CookeryWizGuildBank:FindItemInGuildBank(bagId, item)
  trace("FindItemInBag")
  -- NOTE: if the stacks are split it becomes more complex, assume it is in one stack
  local bagSize = GetBagSize(bagId)
	for i = 0, bagSize do
    local itemLink = zo_strformat("<<1>>", GetItemLink(bagId, i))
    local itemName = zo_strformat("<<1>>", GetItemName(bagId, i)):lower()        
    local itemId = CookeryWizUtils:GetItemID(itemLink)
    if item.id == itemId and item.name == itemName then
      return i
    end
	end 
end

-- attempt to find the item from the name or id or both
-- name is not enough to uniquely identify (loot potions vs crafted)
-- id is not enough to uniquely identify (crafted potion)
-- so be as precise as possible
function CookeryWizGuildBank:ResolveLink(bagId, item)
  local id = item.id
  local name = item.name
  local nameLower = name:lower()

  trace("ResolveLink["..item.name.."]")
  local slotId = GetNextGuildBankSlotId()
  if not slotId then
    trace("No SlotId returned from GetNextGuildBankSlotId")
  end

  while slotId do
    local itemLink = zo_strformat("<<1>>", GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS ))
    local itemId = CookeryWizUtils:GetItemID(itemLink)
    local itemName = zo_strformat("<<1>>", GetItemName(bagId, slotId))
    local itemNameLower = itemName:lower()
    
    local haveName = (name and name ~= "")
    local matchedName = (nameLower == itemNameLower)
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
      return 
    end
    slotId = GetNextGuildBankSlotId(slotId)
  end  

end

---------------------------------------------------------------------
-- Function: CollectItem
--
-- When an item is found to exist, this routine will attempt to collect
-- it from the guild bank.
---------------------------------------------------------------------
function CookeryWizGuildBank:CollectItem(item)
  -- store a reference to the item we are collecting
  self.collectingItem = item
  
  -- if we dont have a link, resolve it from name and id, or either
  if not item.link then
    self:ResolveLink(BAG_GUILDBANK, item)    
  end
  
  if not item.link then
    trace("Failed resolving item link from name or does not exist in bank/bag")    
    self:Collect()
    return
  end
  
  -- if we dont have an id, resolve it
  if not item.id then
    trace("Resolving id from "..item.link)
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
  
  -- in case the user stops accessing the bank before we are complete
  if not self.currentGuildBankId then
    trace("Bank is no longer open")
    return
  end
  
  local slotId = GetNextGuildBankSlotId()
  if not slotId then
    trace("No SlotId returned from GetNextGuildBankSlotId")
  end
  
  while slotId do
    local slotItemLink = GetItemLink(BAG_GUILDBANK, slotId, LINK_STYLE_BRACKETS )
    local slotItemId = CookeryWizUtils:GetItemID(slotItemLink)
    
    if slotItemId == item.id then
      trace("Matched id for item["..slotItemLink.."]")
      local slotItemNameLower = zo_strformat("<<1>>", GetItemLinkName(slotItemLink)):lower()
      if slotItemNameLower == item.nameLower then
        -- we have a match!
        trace("Transferring["..item.name.."] slot["..slotId.."] from guild bank")
        item.state = COLLECT_STATE_FETCHING
        -- get the existing number of items so we can calculate how many need to be returned
        local stackCountBackpack, stackCountBank = GetItemLinkStacks(item.link)        
        trace("-item["..item.link.."]-stackCountBackpack:"..stackCountBackpack)        
        item.existingCount = stackCountBackpack
        break        
      end
    end

    slotId = GetNextGuildBankSlotId(slotId)
  end
  
  -- did we find the item?
  if item.state == COLLECT_STATE_FETCHING then     
    local text = string.format(L[CWL_BUTTON_GUILDBANK_COLLECTING_WRIT_FOOD], item.link)
    trace(text)
    self.collectWritFoodLabel:SetText(text)
    TransferFromGuildBank(slotId)
  else
    -- did not find it, so prgress to next
    self:Collect()
  end
end

---------------------------------------------------------------------
-- Function: Collect
--
-- Main routine called to perform the collection process from the
-- guild bank. Will keep calling iteself until all items are processed
---------------------------------------------------------------------
function CookeryWizGuildBank:Collect()
  
  if self.collectCount > 20 then
    return
  end
  self.collectCount = self.collectCount + 1
  
  -- make sure we only continue if everything is in a valid state
  if not self.currentGuildBankId then
    trace("No guild id specified. Ending collect process")
    return
  end
  
  local callback = callbackRegistrations:GetCurrentCallback()
  if not callback then
    trace("No more items to be collected")
    self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD_DONE])
    return
  end
    
  -- still working on the current callback object?
  if callback then
    
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
    --self.currentCallback = self:GetNextCallback()
    --if not self.currentCallback then
      --trace("No more items to be collected")
      --self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD_DONE])
      --return
    --end
  end

  -- Collect again till finished
  self:Collect()  
end


---------------------------------------------------------------------
-- Collect Food button events
---------------------------------------------------------------------
---------------------------------------------------------------------
-- Function: OnCollectWritFoodControlInitialized
--
-- reference to collectWritFoodControl stored
---------------------------------------------------------------------
function CookeryWizGuildBank:OnCollectWritFoodControlInitialized(control)
  self.collectWritFoodControl = control
  --self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_CLEAR_SEARCH])
end

---------------------------------------------------------------------
-- Function: OnCollectWritFoodLabelInitialized
--
-- reference to collectWritFoodLabel stored and text set
---------------------------------------------------------------------
function CookeryWizGuildBank:OnCollectWritFoodLabelInitialized(control)
  self.collectWritFoodLabel = control
  control:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD])
  --self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_CLEAR_SEARCH])
end



---------------------------------------------------------------------
-- Function: OnOptionsComboInitialized
--
-- called when combo is intialised
---------------------------------------------------------------------
function CookeryWizGuildBank:OnOptionsComboInitialized(control)
  self.optionsComboBox = control
  self.optionsDropdown = ZO_ComboBox:New(control)
  self.optionsDropdown:SetSelectedColor(0, 0, 0, 0)
end

---------------------------------------------------------------------
-- Function: PopulateOptionsDropDown
--
-- Populate the options in the dropdown
---------------------------------------------------------------------
function CookeryWizGuildBank:PopulateOptionsDropDown(enableStockpiles)
  
  local optionsComboItems = {}
  
  optionsComboItems[#optionsComboItems + 1] =
  { 
    displayText = L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD],
    onSelect = function()
      CookeryWizGuildBank:BeginCollection()
    end
  }
  if enableStockpiles then
    optionsComboItems[#optionsComboItems + 1] =  
    { 
      displayText = L[CWL_DROPDOWN_GUILDBANK_STOCKPILING_START],
      onSelect = function()
        trace("Begin Stockpiling")
        CookeryWizGuildBank:BeginStockpiling()
      end
    }
  end

  if not self.optionsDropdown then
    trace("No options Dropdown")
    return
  end
  
  local function OnItemSelect(dropDown, name, menuEntry)
    trace(name)
    local option = menuEntry.option
    if option.onSelect then
      option.onSelect()
    end
  end

  
  self.optionsDropdown:ClearItems()

  for i = 1, #optionsComboItems do
    local option = optionsComboItems[i]
    local entry = self.optionsDropdown:CreateItemEntry(option.displayText, OnItemSelect)
    entry.option = option
    self.optionsDropdown:AddItem(entry)
  end
  
end

---------------------------------------------------------------------
-- Function: OnCollectWritFoodControlMoveStop
--
-- Event that is triggered when the collect writ food control is moved
---------------------------------------------------------------------
function CookeryWizGuildBank:OnCollectWritFoodControlMoveStop() 
  -- save the position
 
  -- let objects that have registered that the control has moved so
  -- they can save position
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnCollectWritFoodControlMoved then 
        callback.parentObject:OnCollectWritFoodControlMoved(self.collectWritFoodControl)
      end
    end)   

end

---------------------------------------------------------------------
-- Function: OnCollectWritFoodButtonClicked
--
-- Click event for when the collect food button is clicked
---------------------------------------------------------------------
function CookeryWizGuildBank:OnCollectWritFoodButtonClicked(control) 
  self:BeginCollection()
end

CookeryWizGuildBank.currentStockpile = nil
CookeryWizGuildBank.currentStockpileCallback = nil
local limitCounter = 0

---------------------------------------------------------------------
-- Function: BeginStockpiling
--
-- Start the stockpiling process
---------------------------------------------------------------------
function CookeryWizGuildBank:BeginStockpiling()
  trace("Starting stockpile processing...")
  
  if self.asyncStockpile then
    trace("Already in progress")
    return
  end
  
  self:ResetGuildBankVariables()  
  self.currentGuildBankId = GetSelectedGuildBankId() 
  
  callbackRegistrations:ResetNextCallback()
  self:HandleNextStockpileRegistration()
end

---------------------------------------------------------------------
-- Function: HandleNextStockpileRegistration
--
-- Handles the start of managing a stockpile registration
---------------------------------------------------------------------
function CookeryWizGuildBank:HandleNextStockpileRegistration()
  trace("CookeryWizGuildBank:HandleNextStockpileRegistration")
  
  local registration = callbackRegistrations:GetNextCallback()
  if not registration then
    trace("No more registrations")
    return
  end
  
  if registration.parentObject.OnManageStockpile then
    if registration.parentObject.OnPrepareForStockpiling then
      --trace("-"..registration.key)
      registration.parentObject:OnPrepareForStockpiling(self.currentGuildBankId)
    end    
    self.currentStockpileCallback = registration.parentObject   
    -- we must handle this stockpile
    self:StartManagingStockpile()
  end
end



function CookeryWizGuildBank:StartManagingStockpile()
  trace("StartManagingStockpile")
  limitCounter = limitCounter + 1
  if limitCounter > 500 then
    trace("Too many!")
    return
  end
  
  local stockpile = self.currentStockpileCallback:OnManageStockpile(self.currentGuildBankId)
  if not stockpile then
    trace("No more stockpiles for this registration")
    -- put in a delay
    zo_callLater(function()
        self:HandleNextStockpileRegistration()
    end, 100) 
  else
    self.currentStockpile = stockpile  
    self:FinishManagingStockpile()    
  end 
end

function CookeryWizGuildBank:FinishManagingStockpile()
  trace("FinishManagingStockpile")
  self:StartManagingStockpile()
end

---------------------------------------------------------------------
-- Function: Stockpile
--
-- Handles the start of managing a stockpile object
---------------------------------------------------------------------
function CookeryWizGuildBank:Stockpile()
  trace("CookeryWizGuildBank:Stockpile")
  
  
  -- start the process      
  if not self.currentStockpile then
    -- get the next stockpile
  end
end

---------------------------------------------------------------------
-- Function: BeginCollection
--
-- Called to start the writ item processing
---------------------------------------------------------------------
function CookeryWizGuildBank:BeginCollection()
  trace("Starting collection processing...")
  
  if self.asyncCollect then
    trace("Already in progress")
    return
  end
  
 --[[
  -- let objects that have registered that the guild bank is open so they can prepare
  -- and potentially set the location of the collect button control
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnPrepareForGuildBank then 
        callback.parentObject:OnPrepareForGuildBank(self.collectWritFoodControl, self.currentGuildBankId)
      end
    end)
  ]]--
  
  self:ResetGuildBankVariables()  
  self.currentGuildBankId = GetSelectedGuildBankId() 
  
  -- create a task to collect
  local task = CookeryWizAsyncOld:new(self)
  
  -- store our own data
  task.data.key = ASYNC_KEY_GUILD_COLLECT
  
  task:SetMaxLoopCounter(1)
  task:SetTimerInterval(200)
  trace(callbackRegistrations:GetCount().." registrations")
  task:SetRange(1, callbackRegistrations:GetCount())
    
  self.asyncCollect = task
  self.asyncCollect:Begin()  
end

---------------------------------------------------------------------
-- Function: OnAsyncStart
--
-- Called at start of async task
---------------------------------------------------------------------
function CookeryWizGuildBank:OnAsyncStart(callback)
  trace("OnAsyncStart("..callback.data.key..")")
  callbackRegistrations:ResetNextCallback()
end


---------------------------------------------------------------------
-- Function: OnAsyncLoop
--
-- Called on each iteration
---------------------------------------------------------------------
function CookeryWizGuildBank:OnAsyncLoop(callback, index)
  local key = callback.data.key
  trace("OnAsyncLoop("..key..","..index..")")

  local registration = callbackRegistrations:GetNextCallback()

  if key == ASYNC_KEY_GUILD_COLLECT then
    if registration and registration.parentObject.OnPrepareForGuildBank then
      --trace("-"..registration.key)
      registration.parentObject:OnPrepareForGuildBank(self.collectWritFoodControl, self.currentGuildBankId)
    end
  end
end

---------------------------------------------------------------------
-- Function: OnAsyncStart
--
-- Called at end of async task
---------------------------------------------------------------------
function CookeryWizGuildBank:OnAsyncEnd(callback, index)
  trace("OnAsyncEnd("..callback.data.key..","..index..")")
  self.asyncCollect = nil
  callbackRegistrations:ResetNextCallback()
  self.currentCallback = callbackRegistrations:GetNextCallback()
  self:Collect()    
end


---------------------------------------------------------------------
-- Function: SplitFood
--
-- Called when we need to split a stack of food to return to the
-- Guild bank
---------------------------------------------------------------------
function CookeryWizGuildBank:SplitFood(item)

  if not self.currentGuildBankId then
    trace("Guild bank closed")
    return
  end
  
  -- do we have space?
  if GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
    d(string.format(L[CWL_NOTIFY_NO_BAG_SPACE_FOR_SPLIT], L[CWL_COOKERYWIZ_NAME]))
    return
  end  

  local destSlotId = FindFirstEmptySlotInBag(BAG_BACKPACK)

  trace("Splitting ["..item.bagItemSlotId.."] to ["..destSlotId.."]")
  item.state = COLLECT_STATE_SPLITTING
  local res = CallSecureProtected("RequestMoveItem", BAG_BACKPACK, item.bagItemSlotId, BAG_BACKPACK, destSlotId, item.returnCount)
  if res then
    trace("Successfully called RequestMoveItem");
  else
    item.state = COLLECT_STATE_ERROR_SPLITTING
    trace("Failed calling RequestMoveItem");
  end 
  
end

---------------------------------------------------------------------
-- ESO Events
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnOpenGuildBank
--
-- This function is called when the user first opens the guild
-- banks. It is then immediately followed by the guild select event
-- as ESO defaults to selecting the first available guild
---------------------------------------------------------------------
function CookeryWizGuildBank:OnOpenGuildBank(eventCode)
  trace("OpenGuildBank")
  self.enabled = false
  --self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_IDLE])
  self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD])
  --self.collectWritFoodLabel:SetEnabled(false)
  self:ResetGuildBankVariables()

  -- let objects that have registered that the guild bank is open so they can
  -- set the location of the collect button control
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnPositionGuildBankOptionsControl then 
        callback.parentObject:OnPositionGuildBankOptionsControl(self.collectWritFoodControl, guildId)
        return true
      end
    end)
end

---------------------------------------------------------------------
-- Function: OnGuildBankSelected
--
-- Called when a guild is selected and changed to.
-- If we dont have permissions we dont bother
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankSelected(eventCode, guildId)
  trace("OnGuildBankSelected["..guildId.."]")
 
  self:ResetGuildBankVariables()
  
  -- dont bother going any further if we do not have permissions to withdraw
  if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW) then
    trace("Finished with bank as we do not have permission to withdraw.")
    return
  end  
 
  self.currentGuildBankId = guildId
  
  self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_WRIT_FOOD])
  --self.collectWritFoodLabel:SetText(L[CWL_BUTTON_GUILDBANK_COLLECT_IDLE])

  -- let objects that have registered that the guild bank is open so they can
  -- set the location of the collect button control
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnGuildBankSelected then 
        callback.parentObject:OnGuildBankSelected(guildId)
        return true
      end
    end)
end

---------------------------------------------------------------------
-- Function: OnGuildBankItemsReady
--
-- Called when guild bank items have been loaded
-- They load 200 at a time until the last load
-- Normally the last load number is duplicated, so we know the load is finished
-- but it seems flaky
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankItemsReady(eventCode)
  trace("OnGuildBankItemsReady["..eventCode.."]")
  
  if not self.currentGuildBankId then
    trace("We are not interested in this event")
    return
  end

  local itemCount = GetNumBagUsedSlots(BAG_GUILDBANK) -- self:CountItemsInBag() --
  trace("Items in bag "..itemCount)
  local slotCount = self.lastFullSlotDataCount
  self.lastFullSlotDataCount = itemCount
  --self.collectWritFoodLabel:SetEnabled(self.enabled)

  -- let objects that have registered that the guild bank items are ready
  -- This allows them to scan the items if they wish
  callbackRegistrations:Enumerate(function(callback)
      if callback.parentObject.OnGuildBankItemsReady then 
        trace("OnGuildBankItemsReady "..callback.key)
        callback.parentObject:OnGuildBankItemsReady(self.currentGuildBankId)
      end
    end)  
end

---------------------------------------------------------------------
-- Function: OnGuildBankTransferError
--
-- This event happens when there is an error
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankTransferError(eventCode, reason)
  trace("OnGuildBankTransferError["..eventCode..", "..reason.."]")
end

---------------------------------------------------------------------
-- Function: OnGuildBankItemRemoved
--
-- this happens after the slot update
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankItemRemoved(eventCode, slotId)
  trace("OnGuildBankItemRemoved["..eventCode..", "..slotId.."]") 
end

---------------------------------------------------------------------
-- Function: OnGuildBankItemAdded
--
-- This event happens after slot remove
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankItemAdded(eventCode, slotId)
  trace("OnGuildBankItemAdded["..eventCode..", "..slotId.."]") 
end

---------------------------------------------------------------------
-- Function: OnGuildBankUpdatedQuantity
--
-- This event happens after change to quantity of an item
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankUpdatedQuantity(eventCode, slotId)
  trace("OnGuildBankUpdatedQuantity["..eventCode..", "..slotId.."]") 
end


---------------------------------------------------------------------
-- Function: OnInventorySingleSlotUpdate
--
-- This event happens when a slot is updated
---------------------------------------------------------------------
function CookeryWizGuildBank:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
  local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
  trace("OnInventorySingleSlotUpdate["..eventCode.."], bagId["..bagId.."], slot["..slotId.."] -"..itemLink.." -"..updateReason)
  

  local item = self.collectingItem
  if not item then
    trace("We are not transferring any items!")
    return
  end
  
  -- what state are we in?
  if item.state == COLLECT_STATE_FETCHING then   
    item.state = COLLECT_STATE_FETCHED
  end
  
  if item.state == COLLECT_STATE_FETCHED then
    -- how many were transferred and how many did we want?
    -- get the existing number of items so we can calculate how many need to be returned
    local stackCountBackpack, stackCountBank = GetItemLinkStacks(item.link)
    trace("-item["..item.link.."]-stackCountBackpack:"..stackCountBackpack)
    local returnCount = stackCountBackpack - item.existingCount - item.count
    if returnCount <= 0 then
      trace("Finished with this item "..item.link)
      item.state = COLLECT_STATE_COMPLETE
      -- continue the process of collection
      self:Collect()
      return
    end
    
    -- split off this amount
    item.returnCount = returnCount
    item.bagItemSlotId = slotId
    self:SplitFood(item)
    return
  end
  
  if item.state == COLLECT_STATE_SPLITTING then
    trace("Splitting is complete.Now send it back to guild bank")
    item.bagMoveItemSlotId = slotId
    local res = TransferToGuildBank(BAG_BACKPACK, slotId)    
    item.state = COLLECT_STATE_RETURNING
    return
  end

  if item.state == COLLECT_STATE_RETURNING and item.bagMoveItemSlotId == slotId then
    trace("Return complete. Finished")
    item.state = COLLECT_STATE_COMPLETE
    -- continue the process of collection
    self:Collect()
    return
  end
  
end

---------------------------------------------------------------------
-- Function: OnGuildBankDeselected
--
-- This function is called when the user has closed the current
-- guild bank by changing guild banks or closing the guild bank
-- gui altogether
---------------------------------------------------------------------
function CookeryWizGuildBank:OnGuildBankDeselected(eventCode)
  trace("OnGuildBankDeselected")
  self:ResetGuildBankVariables()
end


---------------------------------------------------------------------
-- Function: OnCloseGuildBank
--
-- This function is called when the user closes the guild bank
-- GUI
---------------------------------------------------------------------
function CookeryWizGuildBank:OnCloseGuildBank(eventCode)
  trace("CloseGuildBank")
  
  self:ResetGuildBankVariables()  
  
end
