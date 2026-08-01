
local CWS_STOCKPILE_DATA_TYPE = 1
local CWS_STOCKPILE_SELECTION_DATA_TYPE = 2

local SORT_STOCKPILE_NAME = 0
local SORT_STOCKPILE_ENABLED = 1
local SORT_STOCKPILE_TOTAL = 2
local SORT_STOCKPILE_MAXIMUM = 3
--local SORT_STOCKPILE_BANK = 4

local stockpileTable = nil
local callbackRegistrations = nil
local events = nil
local currentItemType = ITEMTYPE_INGREDIENT

local L = CookeryWizLanguage.language

CookeryWizStockpiles = EasyFrameDialog:new()

CookeryWizStockpiles.name = "CookeryWizStockpiles"
CookeryWizStockpiles.stockpileData = nil
CookeryWizStockpiles.itemTypeCollection = nil
--CookeryWizStockpiles.stockpiles = {}
CookeryWizStockpiles.defaultMaxBank = 200
CookeryWizStockpiles.defaultMaxBackpack = 200
CookeryWizStockpiles.defaultMaxGuild = 200
CookeryWizStockpiles.count = 0
CookeryWizStockpiles.guildCount = 0

CookeryWizStockpiles.sortAscending = true
CookeryWizStockpiles.sortType = SORT_STOCKPILE_NAME

CookeryWizStockpiles.stockpileScrollList = nil
CookeryWizStockpiles.enableAllStockpilesCheckButton = nil
CookeryWizStockpiles.enableStockpilesTypeControl = nil

CookeryWizStockpiles.headerMaximumControl = nil
CookeryWizStockpiles.headerEnableControl = nil
CookeryWizStockpiles.headerNameControl = nil  
CookeryWizStockpiles.headerTotalControl = nil
  
CookeryWizStockpiles.itemTypeCombo = nil
CookeryWizStockpiles.itemTypeDropdown = nil
  
CookeryWizStockpiles.currentStorageType = nil
CookeryWizStockpiles.currentCallback = nil
CookeryWizStockpiles.currentItemType = nil
--CookeryWizStockpiles.currentItemTypeSavedVars = nil

CookeryWizStockpiles.traceEnabled = false

local function trace(msg)
  if CookeryWizStockpiles.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Registration handling
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: SetItemType
--
-- This function sets the item type of the data we are using
-- it is controlled by the calling application
---------------------------------------------------------------------
function CookeryWizStockpiles:SetItemType(itemType)
  self.currentItemType = itemType
  
  --[[
  -- find the callback handling this itemType
  callbackRegistrations:Enumerate(function(callback)
    if callback.itemType == itemType then
      -- now select the item in the dropdown
      d("Found item type")
      self.currentCallback = callback
      return true
    end
  end)
]]--
end

function CookeryWizStockpiles:FindCallbackFromItemType(itemType)
  -- find the callback handling this itemType
  callbackRegistrations:Enumerate(function(callback)
    if callback.itemType == itemType then
      -- now select the item in the dropdown
      trace("Found item type")
      return callback
    end
  end) 
end

function CookeryWizStockpiles:IsItemTypeGuildEnabled(guildId, itemType)
  local callback = self:FindCallbackFromItemType(itemType)
  if not callback then
    trace("Failed finding callback from itemtype")
    return
  end
  
  local storageIndex = self:ResolveGuildIndex(guildId)
  
  if storageIndex and callback.savedVariables.stockpileData.guilds[storageIndex] then
    return true
  end
end


function CookeryWizStockpiles:SetIsItemTypeGuildEnabled(guildId, itemType, enabled)
  local callback = self:FindCallbackFromItemType(itemType)
  if not callback then
    trace("Failed finding callback from itemtype")
    return
  end
  
  local savedItemTypeVars = self:GetSavedItemTypeVars(callback)
  
  local storageIndex = self:ResolveGuildIndex(guildId)
  local storageType = tostring(storageIndex)
  if storageIndex then
    local storage = savedItemTypeVars.storage[storageType]
    if not storage then
      storage = {}
      savedItemTypeVars.storage[storageType] = storage
    end    
    if enabled then
      if not callback.savedVariables.stockpileData.guilds[storageIndex] then
        callback.savedVariables.stockpileData.guilds[storageIndex] = {}
      end
      callback.savedVariables.stockpileData.guilds[storageIndex].enabled = true
    else
      callback.savedVariables.stockpileData.guilds[storageIndex] = nil
    end
  end  
end

function CookeryWizStockpiles:ResolveGuildIndex(guildId)
  -- local guildCount = GetNumGuilds()
  -- this may be in a lookup table later
  return STOCKPILES_SELECTION_BANK + guildId
end

function CookeryWizStockpiles:SetupItemType(callback)
  self.itemTypeCollection = nil
  
  -- now we want the saved variables
  if callback.parentObject.OnStockpilesGetSavedVariables then 
    local savedVariables = callback.parentObject:OnStockpilesGetSavedVariables(callback.itemType)
    if savedVariables then
      callback.savedVariables = savedVariables
      
      -- setup the basic data storage structure each registered object must have
      if not savedVariables.stockpileData then
        savedVariables.stockpileData = {}
      end
      if not savedVariables.stockpileData.guilds then
        savedVariables.stockpileData.guilds = {}
      end
      if not savedVariables.stockpileData.itemTypes then
        savedVariables.stockpileData.itemTypes = {}       
      end
      
      
      local itemType = callback.itemType      
      local itemTypeCollection = nil
      
      -- make sure the itemtype table exists
      for key, data in pairs(savedVariables.stockpileData.itemTypes) do 
        if data.itemType == itemType then
          itemTypeCollection = data
          break
        end
      end
      
      -- if it didnt exist, then we create it
      if not itemTypeCollection then
        itemTypeCollection = {}
        itemTypeCollection.count = 0
        itemTypeCollection.itemType = itemType
        local defaultMaxStack = 0
        if callback.parentObject.OnStockpilesGetDefaultMaximums then
          defaultMaxStack = callback.parentObject:OnStockpilesGetDefaultMaximums(itemType)
        end          
        itemTypeCollection.defaultMaxStack = defaultMaxStack
          
        
        itemTypeCollection.storage = {}
        savedVariables.stockpileData.itemTypes[#savedVariables.stockpileData.itemTypes + 1] = itemTypeCollection  
      end
      
      self.itemTypeCollection = itemTypeCollection
      
      
    end
  end

end


---------------------------------------------------------------------
-- Function: Register
--
-- This function is called when an object wants to register itself
-- for callback events related to stockpiles
-- A unique key is passed (usually the addon name) 
-- The callback object is stored and various callback routine called on it when
-- an ESO event occurs
---------------------------------------------------------------------
function CookeryWizStockpiles:Register(key, object, itemType, icon)
  trace("CookeryWizStockpiles:Register-Key["..key.."], itemType["..itemType.."]")
  local callback
  
  if not object then
    d("A callback object must be passed")
    return
  end
   
  if not callbackRegistrations then
    trace("Constructing new registrations object")
    callbackRegistrations = CookeryWizRegistrations:new()
    
    -- also create icons
    
  end
  
  -- setup callback registration extra data
  callback = callbackRegistrations:Register(key, self, function(callback)
      -- make sure we dont already have this type of item
      return callback.itemType == itemType
  end)

  if callback then
    callback.itemType = itemType
    callback.parentObject = object
    callback.stockpiles = {}
    callback.icon = icon
    callback.lastStockpileIndex = 1
    
    -- this will call OnStockpilesGetSavedVariables and setup the structure of default savedvariables
    self:SetupItemType(callback)
    
    if self.itemTypeCollection then
      if object.OnStockpilesLoaded then
        object:OnStockpilesLoaded(callback)
      end         
    end
  end
  
  return itemType
end

---------------------------------------------------------------------
-- Function: OnRegister
--
-- This function is called via the registrations object when it has
-- become Registered
---------------------------------------------------------------------
function CookeryWizStockpiles:OnRegister(count, object, ...)
  trace("CookeryWizStockpiles:OnRegister-Count["..count.."]")
  if count == 1 then
    --[[
    trace("Registering for quest events")
    if not events then
      trace("Creating new events object")
      events = CookeryWizEvents:new()
    end      
    events:RegisterEvent(EVENT_QUEST_COMPLETE, function(...)
      self:OnQuestComplete(...)
    end)
  
    events:RegisterEvent(EVENT_QUEST_ADDED, function(...)
      self:OnQuestAdded(...)
    end) 
  
    -- now enable them
    events:EnableAllEvents(true)
    ]]--
  end
             
end

---------------------------------------------------------------------
-- Function: Unregister
--
-- This function is called when an object wants to unregister itself
-- from stockpile management.
---------------------------------------------------------------------
function CookeryWizStockpiles:Unregister(key, itemType)
  trace("Unregister:Key["..key.."], questType["..questType.."]")  
  
  if callbackRegistrations then
    callbackRegistrations:Unregister(key, function(callback)
        return callback.itemType == itemType
    end)
  end
end

---------------------------------------------------------------------
-- Function: OnUnregister
--
-- This function is called via the registrations object when it has
-- become unregistered
---------------------------------------------------------------------
function CookeryWizStockpiles:OnUnregister(count, callback)
  trace("OnUnregister:Count["..count.."]")
  if count == 0 and events then
    --[[
    trace("No more registrations, Unregistering Quest events")   
    -- remove registration
    events:UnregisterEvent(EVENT_QUEST_COMPLETE)
    events:UnregisterEvent(EVENT_QUEST_ADDED)
    ]]--
  end 
end

---------------------------------------------------------------------
-- EasyFrame virtual functions
---------------------------------------------------------------------

function CookeryWizStockpiles:OnHideWindow(isHidden)
  trace("CookeryWizStockpiles:OnHideWindow")
 
  local ui = self.ui
  if isHidden then
    -- save any current stockpile info
    self:SaveStockpiles()
  else
    self.currentStorageType = STOCKPILES_SELECTION_BAG
    --ZO_TriStateCheckButton_SetState(self.enableAllStockpilesCheckButton, TRISTATE_CHECK_BUTTON_INDETERMINATE)
    trace("Rebuilding scroll data")
    self:PopulateItemTypeCombo()
    self:RebuildScrollData(false)
    self:RebuildStockpileSelectionData(false)
    

  end
end
---------------------------------------------------------------------
-- GUI Control events
---------------------------------------------------------------------

function CookeryWizStockpiles:ClearStorageTotals(callback)
  
  -- get the storage 
  -- find the callback handling this itemType
  callbackRegistrations:Enumerate(function(callback)
    self:Enumerate(function(stockpile)
      --trace("Stockpile["..stockpile:GetName().."]")
      stockpile:SetTotal(0)
    end, callback)       
  end)  
end

function CookeryWizStockpiles:SetIsItemStorageEnabled(enabled)
  trace("SetIsItemStorageEnabled["..tostring(enabled).."]")
  local callback = self.currentCallback
  if not callback then
    trace("-No callback")
    return
  end
  
  local savedItemTypeVars = self:GetSavedItemTypeVars()
  if not savedItemTypeVars then
    trace("-No Saved vars")
    return
  end
  
  local storageType = tostring(self.currentStorageType)
  if not enabled then
    savedItemTypeVars.storage[storageType] = nil
    -- refresh the list
    self:RebuildScrollData(false)
  else
    --self:CreateSavedItemStorageVars(callback, self.currentStorageType)
    self:GetSavedItemTypeStorageVars(callback, self.currentStorageType, true)
  end
end

function CookeryWizStockpiles:HideStockpileControls()
  local storageEnabled = self:IsItemStorageEnabled()
  trace("HideStockpileControls["..tostring(storageEnabled).."]")

    
  -- now disable and enable controls
  local hide = not storageEnabled
  --self.enableAllStockpilesCheckButton:SetHidden(hide)
  --self.setDefaultQuantityButton:SetHidden(hide)
  self.stockpileScrollList:SetHidden(hide)
  
  --self.enableAllStockpilesLabel:SetHidden(hide)
  self.editMaximumControl:SetHidden(hide)
  self.defaultMaximumLabel:SetHidden(hide)
  
  self.qualityDownButtonControl:SetHidden(hide)
  self.selectedQualityControl:SetHidden(hide)
  self.actionLabel:SetHidden(hide)
  self.actionComboBox:SetHidden(hide)
  
  self.headerMaximumControl:SetHidden(hide)
  self.headerEnableControl:SetHidden(hide)
  self.headerNameControl:SetHidden(hide)
  self.headerTotalControl:SetHidden(hide)
end

function CookeryWizStockpiles:GetItemTypeName(itemType)
  return GetString(itemType + SI_ITEMTYPE0)  
end

function CookeryWizStockpiles:OnItemTypeComboInitialized(combo)
  self.itemTypeCombo = combo
  self.itemTypeDropdown = ZO_ComboBox:New(combo)  
end


function CookeryWizStockpiles:PopulateItemTypeCombo()
  trace("PopulateItemTypeCombo")
  if not self.itemTypeDropdown then
    trace("No filter Dropdown")
    return
  end
  
  local function OnItemSelect(control, choiceText, entry)
    local callback = entry.callbackObject
    trace("Selected item - "..callback.itemType)

--[[
    local itemTypes = callback.savedVariables.stockpileData.itemTypes

    for i = 1, #itemTypes do 
      local itemTypeSavedVars = itemTypes[i]
      if itemTypeSavedVars.itemType == callback.itemType then
        self.currentItemTypeSavedVars = itemTypeSavedVars
        break
      end
    end
    ]]--
    
    -- save any current stockpile info
    self:SaveStockpiles()
    
    self.currentCallback = callback
    
    -- update enabled state
    self:UpdateStorageItemTypeStatus()
  end
  
  self.itemTypeDropdown:ClearItems()
  local count = 0
  callbackRegistrations:Enumerate(function(callback)
      count = count + 1
      local text = self:GetItemTypeName(callback.itemType)
      local icon = callback.icon
      local entryText
      if not icon then
        entryText = text
      else
        entryText = zo_iconTextFormat(icon, 32, 32, text)
        --CookeryWizUtils:SendToChat(entryText)
      end
      local entry = self.itemTypeDropdown:CreateItemEntry(entryText, OnItemSelect)
      -- cant use callback as it is used internally
      entry.callbackObject = callback
      self.itemTypeDropdown:AddItem(entry)
      callback.comboIndex = count
  end)


  if self.currentCallback then
    self.itemTypeDropdown:SelectItemByIndex(self.currentCallback.comboIndex)
  else
    callbackRegistrations:Enumerate(function(callback)
      if callback.itemType == self.currentItemType then
        -- now select the item in the dropdown
        self.itemTypeDropdown:SelectItemByIndex(callback.comboIndex)
        return true
      end
    end) 
  end

end

---------------------------------------------------------------------
-- Function: OnEnableStockpilesLabelInitialized
--
-- This function is called when the GUI label has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableStockpilesLabelInitialized(control)
  control:SetText(L[CWL_LABEL_STOCKPILES_ENABLE])
end

---------------------------------------------------------------------
-- Function: OnCookeryWizStockpilesInitialized
--
-- This function is called when the GUI control has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnCookeryWizStockpilesInitialized(control)
  self:InitializeEasyFrameDialog(L[CWL_COOKERYWIZSTOCKPILES_TITLE], CookeryWizStockpilesUI)
  
  self.ui:SetResizeHandleSize(0)
    
  --if self.reloadButton then
    --self.reloadButton:SetHidden(true)
  --end
  if self.shrinkButton then
    self.shrinkButton:SetHidden(true)
  end
  
    -- Configure strings
  self.closeTooltip = L[CWL_BUTTON_TOOLTIP_CLOSE]   
  --self:InitializeControls(control)
end

---------------------------------------------------------------------
-- Function: OnActionLabelInitialized
--
-- This function is called when the GUI label
-- for enabled items of given quality is intialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnActionLabelInitialized(control)
  self.actionLabel = control
  control:SetText(L[CWL_LABEL_ACTION_TEXT])
  CookeryWizUtils:SetFont(control, 14)    
end


---------------------------------------------------------------------
-- Function: OnMaxAmountComboInitialized
--
-- This function is called when the GUI amount combo is
-- initialise
---------------------------------------------------------------------
function CookeryWizStockpiles:OnActionComboInitialized(control)
  self.actionComboBox = control
  self.actionDropdown = ZO_ComboBox:New(control)
  
  self:PopulateActionDropDown()
end

local CW_STOCKPILES_ACTION_ENABLE = 1
local CW_STOCKPILES_ACTION_DISABLE= 2
local CW_STOCKPILES_ACTION_DEFAULT = 3
local CW_STOCKPILES_ACTION_NONE = 4
local CW_STOCKPILES_ACTION_UNLIMITED = 5
  
function CookeryWizStockpiles:PopulateActionDropDown()
  
  if not self.actionDropdown then
    trace("No action dropdown")
    return
  end
  
  self.actionDropdown:ClearItems()

  
  local defaultEntry = self:AddActionListItem(L[CWL_COMBO_OPTION_STOCKPILES_ACTION_ENABLE], CW_STOCKPILES_ACTION_ENABLE)
  self:AddActionListItem(L[CWL_COMBO_OPTION_STOCKPILES_ACTION_DISABLE], CW_STOCKPILES_ACTION_DISABLE)
  self:AddActionListItem(L[CWL_COMBO_OPTION_STOCKPILES_ACTION_DEFAULT], CW_STOCKPILES_ACTION_DEFAULT)
  self:AddActionListItem(L[CWL_COMBO_OPTION_STOCKPILES_ACTION_NONE], CW_STOCKPILES_ACTION_NONE)
  self:AddActionListItem(L[CWL_COMBO_OPTION_STOCKPILES_ACTION_UNLIMITED], CW_STOCKPILES_ACTION_UNLIMITED)
  
  --[[
  local items = self.maxAmountDropdown:GetItems()
  table.sort(items, function(a, b)
      return a.amountIndex < b.amountIndex
    end)
  ]]--
  -- set the current selection
  self.actionDropdown:SelectItem(defaultEntry)
  
end

function CookeryWizStockpiles:OnActionDropdownSelect(dropDown, name, menuEntry)
  trace("select["..name.."]")
  if not self.currentQuality then
    trace("No quality currently selected")
    return
  end
  
  local quality = self.currentQuality[1]
  local callback = self.currentCallback
  local savedItemTypeVars = self:GetSavedItemTypeVars(callback, true)
  local savedStorageVars = self:GetSavedItemTypeStorageVars(callback, self.currentStorageType, true, savedItemTypeVars)
  
  --trace(quality)
  if menuEntry.actionIndex == CW_STOCKPILES_ACTION_ENABLE then
    self:Enumerate(function(stockpile)
      if stockpile:GetQuality() == quality then
        stockpile:SetIsEnabled(true)
        self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, self.currentStorageType, savedStorageVars, savedItemTypeVars)
        --self:CreateSavedItemStorageItemVars(stockpile)
      end
    end) 
  elseif menuEntry.actionIndex == CW_STOCKPILES_ACTION_DISABLE then
    self:Enumerate(function(stockpile)
      if stockpile:GetQuality() == quality then
        stockpile:SetIsEnabled(false)
        self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, self.currentStorageType, savedStorageVars, savedItemTypeVars)
        --self:CreateSavedItemStorageItemVars(stockpile)
      end
    end)     
  elseif menuEntry.actionIndex == CW_STOCKPILES_ACTION_DEFAULT then
    --local itemVars = self:GetSavedItemVars()
    --local savedStorageVars = self:GetSavedItemTypeStorageVars()
    --if not storageVars then
      --trace("No Storage vars!")
      --return
    --end
    local default = savedStorageVars.default
    if not default then
      default = savedItemTypeVars.defaultMaxStack
    end
    
    self:Enumerate(function(stockpile)
      if stockpile:GetQuality() == quality then
        stockpile:SetMaximum(default)
        self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, self.currentStorageType, savedStorageVars, savedItemTypeVars)
        --self:CreateSavedItemStorageItemVars(stockpile)
      end
    end) 
  elseif menuEntry.actionIndex == CW_STOCKPILES_ACTION_NONE then
    self:Enumerate(function(stockpile)
      if stockpile:GetQuality() == quality then
        stockpile:SetMaximum(0)
        --self:CreateSavedItemStorageItemVars(stockpile)
        self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, self.currentStorageType, savedStorageVars, savedItemTypeVars)
      end
    end)  
  elseif menuEntry.actionIndex == CW_STOCKPILES_ACTION_UNLIMITED then
    self:Enumerate(function(stockpile)
      if stockpile:GetQuality() == quality then
        -- ∞
        stockpile:SetMaximum(-1)
        --self:CreateSavedItemStorageItemVars(stockpile)
        self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, self.currentStorageType, savedStorageVars, savedItemTypeVars)
      end
    end)  
  end
end

function CookeryWizStockpiles:AddActionListItem(text, actionIndex)

  local entry = self.actionDropdown:CreateItemEntry(text, function(...)
      self:OnActionDropdownSelect(...)
  end )
  entry.actionIndex = actionIndex
  self.actionDropdown:AddItem(entry) 
  return entry
end

--[[
---------------------------------------------------------------------
-- Function: OnEnableAllStockpilesCheckButtonInitialized
--
-- This function is called when the GUI control checkbox for enabling
-- or disabling stockpile control for all items has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableAllStockpilesCheckButtonInitialized(control)
  self.enableAllStockpilesCheckButton = control
  ZO_TriStateCheckButton_SetState(control, TRISTATE_CHECK_BUTTON_INDETERMINATE)
end

---------------------------------------------------------------------
-- Function: OnEnableAllStockpilesLabelInitialized
--
-- This function is called when the GUI label for enabling
-- or disabling stockpile control for all items has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableAllStockpilesLabelInitialized(control)
  self.enableAllStockpilesLabel = control
  control:SetText(L[CWL_BUTTON_STOCKPILES_ENABLE_ALL_STOCKPILES])
  CookeryWizUtils:SetFont(control, 14)    
end

---------------------------------------------------------------------
-- Function: OnMouseEnterEnableAllStockpilesCheckButton
--
-- This function is called when the GUI control for enable stockpile
-- control mouse enter event occurs. We update the tooltip
---------------------------------------------------------------------
function CookeryWizStockpiles:OnMouseEnterEnableAllStockpilesCheckButton(control)
  local storage = self:GetStorageName(CookeryWizStockpiles.currentStorageType)
  local itemTypeName = self:GetItemTypeName(self.currentCallback.itemType)
  local text = string.format( L[CWL_BUTTON_STOCKPILES_ENABLE_ALL_STOCKPILES_TOOLTIP], storage, itemTypeName)
  ZO_Tooltips_ShowTextTooltip(control, TOP, text)
end

---------------------------------------------------------------------
-- Function: OnEnableAllStockpilesCheckButtonClicked
--
-- This function is called when the GUI control checkbox for enabling
-- or disabling stockpile control for all items has been clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableAllStockpilesCheckButtonClicked(control, mouseButton)
  local state = ZO_TriStateCheckButton_GetState(control)
  local isChecked = false
  
  if state == TRISTATE_CHECK_BUTTON_CHECKED then
    -- it becomes unchecked and we uncheck everything
    ZO_TriStateCheckButton_SetState(control, TRISTATE_CHECK_BUTTON_UNCHECKED)
    isChecked = false
  elseif state == TRISTATE_CHECK_BUTTON_UNCHECKED or state == TRISTATE_CHECK_BUTTON_INDETERMINATE then
    -- it becomes checked and we check everything
    ZO_TriStateCheckButton_SetState(control, TRISTATE_CHECK_BUTTON_CHECKED)
    isChecked = true
  end  
  
  self:Enumerate(function(stockpile)
    if stockpile:GetQuality() <= ITEM_QUALITY_MAGIC then
      stockpile:SetIsEnabled(isChecked)
      self:CreateSavedItemStorageItemVars(stockpile)
    end
  end)  
end
]]--

--[[
function CookeryWizStockpiles:OnSelectedQualityButtonInitialized(control)
  self.selectedQualityControl = control
end

function CookeryWizStockpiles:OnQualityDownButtonInitialized(control)
  self.qualityDownButtonControl = control
end
]]--

---------------------------------------------------------------------
-- Function: OnDefaultMaximumEditInitialized
--
-- This function is called when the GUI label for the default max
-- has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnDefaultMaximumEditInitialized(control)
  self.editMaximumControl = control
  --CookeryWizUtils:SetFont(control, 14)
end

function CookeryWizStockpiles:OnDefaultMaximumLabelInitialized(control)
  self.defaultMaximumLabel = control
  control:SetText(L[CWL_BUTTON_STOCKPILES_DEFAULT_MAX])
  CookeryWizUtils:SetFont(control, 14) 
end

--
-- Enable Stockpiles
--

---------------------------------------------------------------------
-- Function: OnEnableStockpilesCheckButtonInitialized
--
-- This function is called when the GUI control checkbox for enabling
-- stockpile control for this storage type has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableStockpilesCheckButtonInitialized(control)
  self.enableStockpilesTypeControl = control 
end

---------------------------------------------------------------------
-- Function: OnMouseEnterEnableStockpilesCheckButton
--
-- This function is called when the GUI control for enable stockpile
-- control mouse enter event occurs. We update the tooltip
---------------------------------------------------------------------
function CookeryWizStockpiles:OnMouseEnterEnableStockpilesCheckButton(control)
  local storage = self:GetStorageName(CookeryWizStockpiles.currentStorageType)
  local itemTypeName = self:GetItemTypeName(self.currentCallback.itemType)
  local text = string.format( L[CWL_LABEL_STOCKPILES_ENABLE_STOCKPILE_CONTROL_TOOLTIP], storage, itemTypeName)
  ZO_Tooltips_ShowTextTooltip(control, TOP, text)
end

---------------------------------------------------------------------
-- Function: OnEnableStockpilesCheckButtonClicked
--
-- This function is called when the GUI control checkbox for enabling
-- stockpiles control for the given storage type has been clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableStockpilesCheckButtonClicked(control, mouseButton)
  local storageEnabled = self:IsItemStorageEnabled()
  self:SetIsItemStorageEnabled(not storageEnabled)
  self:HideStockpileControls()
  ZO_CheckButton_OnClicked(control, mouseButton)
end

---------------------------------------------------------------------
-- Function: OnSetDefaultQuantityButtonInitialized
--
-- This function is called when the GUI button for setting the
-- default stockpile quantities has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnSetDefaultQuantityButtonInitialized(control)
  self.setDefaultQuantityButton = control
  -- set the tooltip and text
  control:SetText(L[CWL_BUTTON_STOCKPILES_SET_TO_DEFAULTS])
end

---------------------------------------------------------------------
-- Function: OnSetDefaultQuantityButtonClicked
--
-- This function is called when the GUI control button for setting
-- the default stockiple quantities has been clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnSetDefaultQuantityButtonClicked(control)
  self:Enumerate(function(stockpile)
    if stockpile:GetQuality() <= ITEM_QUALITY_MAGIC then
      stockpile:SetMaxBackpack(self.defaultMaxBackpack)
      stockpile:SetMaxBank(self.defaultMaxBank)
    end
  end)  
end


---------------------------------------------------------------------
-- Function: OnEnableStockpileCheckButtonInitialized
--
-- This function is called when the GUI control checkbox for enabling
-- stockpile control has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableStockpileCheckButtonInitialized(control)
  --control:SetText(L[CWL_LABEL_OPTIONS_DISABLE_SHRINK_TEXT]) 
end

---------------------------------------------------------------------
-- Function: OnEnableStockpileCheckButtonClicked
--
-- This function is called when the GUI control checkbox for enabling
-- stockpile control has been clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableStockpileCheckButtonClicked(control, mouseButton)
  -- the data entry item has been associated with the row control
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  
  -- not initialised yet or hidden
  if not entry then
    return
  end
  
  local enabled = not entry:IsEnabled()

  entry:SetIsEnabled(enabled)
  --self:CreateSavedItemStorageItemVars(entry)  
  self:GetSavedItemTypeStorageItemVars(entry, true)
  --ZO_CheckButton_OnClicked(control, mouseButton)
end

---------------------------------------------------------------------
-- Function: GetDisplayMaximum
--
-- This function returns the maximum to retain for the item
---------------------------------------------------------------------
function CookeryWizStockpiles:GetDisplayMaximum(max)
  if max == -1 then
    return L[CWL_BUTTON_STOCKPILES_UNLIMITED]
  elseif max == self:GetDefaultMax() then
    return L[CWL_BUTTON_STOCKPILES_DEFAULT_MAX]
  else
    return max
  end
end

---------------------------------------------------------------------
-- Function: ShowStockpileToolTip
--
-- This function shows the tooltip for the control in the stockpile list
---------------------------------------------------------------------
-- Show the tooltip for the control
function CookeryWizStockpiles:ShowStockpileToolTip(rowControl, state)
  if state then
    local stockpile = rowControl.entry
    if stockpile then
      local storageName = self:GetStorageName(self.currentStorageType)
      local text
      local name = CookeryWizUtils:SetToQualityColor(stockpile:GetQuality(), stockpile:GetName())
      if stockpile:IsEnabled() then
        local max = self:GetDisplayMaximum(stockpile:GetMaximum())
        text = string.format(L[CWL_STOCKPILE_KEEP_AMOUNT_CONTROLLED_TOOLTIP], max, name, storageName)
      else
        text = string.format(L[CWL_STOCKPILE_KEEP_AMOUNT_NOT_CONTROLLED_TOOLTIP], name)
      end
      ZO_Tooltips_ShowTextTooltip(rowControl, TOP, text)
    end
  else
    ZO_Tooltips_HideTextTooltip()
  end
end

---------------------------------------------------------------------
-- Function: OnEditMaximimChanged
--
-- This function is called when the GUI edit control for max items
-- limit has changed
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEditMaximimChanged(control)
  local text = control:GetText()

  -- the data entry item has been associated with the row control
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  
  -- not initialised yet or hidden
  if not entry then
    return
  end
  

  if not text or text == "" then
    if control:HasFocus() then
      text = "-1"
    else
      return
    end
  end
  
  local amount = tonumber(text)
  if not amount then
    amount = -1
  end
  
  if amount >= -1 then
    local currentMax = entry:GetMaximum()
    if currentMax ~= amount then
      trace("OnEditMaximimChanged:Setting ["..entry:GetName().."] to '"..text.."'")
      entry:SetMaximum(amount)
      self:GetSavedItemTypeStorageItemVars(entry, true)
    end    
  end

end


---------------------------------------------------------------------
-- Function: OnHeaderEnableButtonInitialized
--
-- This function is called when the GUI enable header button is
-- initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderEnableButtonInitialized(control)
  self.headerEnableControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_STOCKPILES_HEADER_ENABLE_TOOLTIP])
end

---------------------------------------------------------------------
-- Function: OnHeaderEnableButtonClicked
--
-- This function is called when the GUI enable header button is
-- clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderEnableButtonClicked(control, mouseButton) 
  self:ChangeSortType(SORT_STOCKPILE_ENABLED)
end

---------------------------------------------------------------------
-- Function: OnHeaderMaximumButtonInitialized
--
-- This function is called when the GUI Backpack header button is
-- initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderMaximumButtonInitialized(control)
  self.headerMaximumControl = control
  control:SetText(L[CWL_BUTTON_STOCKPILES_HEADER_MAXIMUM])  
  self:SetupTooltip(control, L[CWL_BUTTON_STOCKPILES_HEADER_MAXIMUM_TOOLTIP])    
end

---------------------------------------------------------------------
-- Function: OnHeaderMaximumButtonClicked
--
-- This function is called when the GUI maximum header button is
-- clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderMaximumButtonClicked(control, mouseButton)
  self:ChangeSortType(SORT_STOCKPILE_MAXIMUM)
end


---------------------------------------------------------------------
-- Function: OnHeaderNameButtonInitialized
--
-- This function is called when the GUI name header button is
-- initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderNameButtonInitialized(control)
  self.headerNameControl = control
  control:SetText(L[CWL_BUTTON_STOCKPILES_HEADER_NAME])
  self:SetupTooltip(control, L[CWL_BUTTON_STOCKPILES_HEADER_NAME_TOOLTIP])
end

---------------------------------------------------------------------
-- Function: OnHeaderNameButtonClicked
--
-- This function is called when the GUI name header button is
-- clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderNameButtonClicked(control, mouseButton)
  self:ChangeSortType(SORT_STOCKPILE_NAME)
end

---------------------------------------------------------------------
-- Function: OnHeaderTotalButtonInitialized
--
-- This function is called when the GUI total header button is
-- initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderTotalButtonInitialized(control)
  self.headerTotalControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_STOCKPILES_HEADER_TOTAL_TOOLTIP])
end

---------------------------------------------------------------------
-- Function: OnHeaderTotalButtonClicked
--
-- This function is called when the GUI total header button is
-- clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnHeaderTotalButtonClicked(control, mouseButton)
  self:ChangeSortType(SORT_STOCKPILE_TOTAL)
end

--[[
---------------------------------------------------------------------
-- Function: OnEnableButtonInitialized
--
-- This function is called when the GUI button control for enabling
-- stockpiles for this ingredient is initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableButtonInitialized(control)
--CWL_BUTTON_STOCKPILES_ENABLE = cwl("Enable")

--CWL_BUTTON_STOCKPILES_ENABLE_TOOLTIP = cwl("Check this to let %s maintain inventory stocks for this ingredient.")  
end

---------------------------------------------------------------------
-- Function: OnEnableButtonInitialized
--
-- This function is called when the GUI button control for enabling
-- stockpiles for this ingredient is clicked
---------------------------------------------------------------------
function CookeryWizStockpiles:OnEnableButtonClicked(control, mouseButton)
end
]]--



---------------------------------------------------------------------
-- StockpileSelection specific Routines
---------------------------------------------------------------------

CookeryWizStockpiles.stockpileSelectionScrollList = nil

---------------------------------------------------------------------
-- Function: OnStockpileSelectionMouseUp
--
-- This function is called when the GUI control for the stockpile
-- selection has received a mouse up event
---------------------------------------------------------------------
function CookeryWizStockpiles:OnStockpileSelectionMouseUp(rowControl)
  local data = ZO_ScrollList_GetData(rowControl) 
  if not data then
    return
  end
  
  -- save any current stockpile info
  self:SaveStockpiles()
  
  self.currentStorageType = data.storageType
  
  self:UpdateStorageItemTypeStatus()
  
  ZO_ScrollList_SelectData(self.stockpileSelectionScrollList, data, rowControl)    
end

function CookeryWizStockpiles:GetDefaultMax()
  local savedStorageVars = self:GetSavedItemTypeStorageVars()
  local default
  if savedStorageVars then
    default = savedStorageVars.default
  end
  
  if not default then
    local savedItemTypeVars = self:GetSavedItemTypeVars()
    default = savedItemTypeVars.defaultMaxStack
  end
  return default
end

function CookeryWizStockpiles:UpdateStorageItemTypeStatus()
  local storageEnabled = self:IsItemStorageEnabled()
  if storageEnabled then
      ZO_CheckButton_SetChecked(self.enableStockpilesTypeControl)
  else
      ZO_CheckButton_SetUnchecked(self.enableStockpilesTypeControl)
  end
  
  local default = self:GetDefaultMax()
  
  self.editMaximumControl:SetText(default)
  
  self:HideStockpileControls()
  
  -- populate them with the current data
  local callback = self.currentCallback
  local storageTypeIndex = self.currentStorageType
  
  self:RetrieveAllStockpileData(callback, storageTypeIndex)
   
   --[[
  self:Enumerate(function(stockpile)
    stockpile:UpdateRowControlData()
  end) 
  ]]--
end


---------------------------------------------------------------------
-- Function: OnStockpileSelectionInitialized
--
-- This function is called when the GUI control for the stockpile
-- selection has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnStockpileSelectionInitialized(control)
  self.stockpileSelectionScrollList = control
  if not control then
      trace("stockpileSelectionScrollList is nil")
      return
  end  
  
 	local function OnInitializeRow(rowControl, entry)
    local nameLabelControl = rowControl:GetNamedChild("Name") 
    local iconControl = rowControl:GetNamedChild("Icon") 
    local iconTextureControl = iconControl:GetNamedChild("IconTexture")
    
    nameLabelControl:SetText(entry.name)
    iconTextureControl:SetTexture(entry.icon)
    
    --d("OnInitializeRow")
    --entry:SetRowControl(rowControl)
    -- Store the entry object with the row control so we can fetch it later at will
    --rowControl.entry = entry
  end
  
  -- oldData, newData
 	local function OnSelectRow(oldData, newData)
    d("Selected")

    if not newData then
      d("-data nil")
      return
    end
    
    local storageType = newData.storage
    CookeryWizStockpileData:SetStorageType(storageType)
    
    d("-Setting")
    ZO_ScrollList_SelectData(self.stockpileSelectionScrollList, newData, control) 
    
    self:Enumerate(function(stockpile)
      stockpile:UpdateRowControlData()
    end)       
  end
  
	local function OnDestroyRow(rowControl)
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
    ZO_ObjectPool_DefaultResetControl(rowControl)
	end  
  
	local function OnHideRow(rowControl, entry)
    --[[
    if entry then
      trace("Hidden row["..entry:GetName().."]")
    else
      trace("Hidden row")
    end
    -- Clear the entry object with the row contol so nothing is changed via GUI events
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
    ]]--
	end  
  
  ZO_ScrollList_Initialize(control)
  ZO_ScrollList_AddDataType(control, CWS_STOCKPILE_SELECTION_DATA_TYPE, "StockpileSelectionRowTemplate", 60, OnInitializeRow, OnHideRow, nil, OnDestroyRow)
  
  --ZO_ScrollList_EnableSelection(control, "ZO_ThinListHighlight", OnSelectRow)
  --ZO_ScrollList_SetAutoSelect(control, true)
    
  ZO_ScrollList_EnableSelection(control, "ZO_ThinListHighlight")
  ZO_ScrollList_SetAutoSelect(control, false)
	ZO_ScrollList_AddResizeOnScreenResize(control) 
  
end

function CookeryWizStockpiles:RebuildStockpileSelectionData(resetTop)
  trace("RebuildStockpileSelectionData stockpile entries")
  
  local listControl = self.stockpileSelectionScrollList
  if not listControl then
    trace("No listControl specified")
    return
  end
  
	local scrollData = ZO_ScrollList_GetDataList(listControl)
	ZO_ScrollList_Clear(listControl)
  if resetTop then
    ZO_ScrollList_ResetToTop(listControl)
  end
 

  scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(CWS_STOCKPILE_SELECTION_DATA_TYPE,
    {
      storageType = STOCKPILES_SELECTION_BAG,
      icon = "/esoui/art/tooltips/icon_bag.dds",
      name = self:GetStorageName(STOCKPILES_SELECTION_BAG)
    }
  )

  scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(CWS_STOCKPILE_SELECTION_DATA_TYPE,
    {
      storageType = STOCKPILES_SELECTION_BANK,
      icon = "/esoui/art/tooltips/icon_bank.dds",
      name = self:GetStorageName(STOCKPILES_SELECTION_BANK)
    }
  )
  
  local guildCount = GetNumGuilds()
  self.guildCount = guildCount
  
  for i = 1, guildCount do
    local alliance = GetGuildAlliance(i)
    --local iconFile = GetAllianceSymbolIcon(alliance)
    local iconFile = GetAllianceTexture(alliance)
    
     
    --[[
    if alliance == ALLIANCE_ALDMERI_DOMINION then
      iconFile = "/esoui/art/guild/guildbanner_icon_aldmeri.dds"
    elseif alliance == ALLIANCE_EBONHEART_PACT then
      iconFile = "/esoui/art/guild/guildbanner_icon_ebonheart.dds"
    elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
      iconFile = "/esoui/art/guild/guildbanner_icon_daggerfall.dds"
    end
    ]]--
    scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(CWS_STOCKPILE_SELECTION_DATA_TYPE,
      {
        storageType = STOCKPILES_SELECTION_BANK + i,
        icon = iconFile,
        name = GetGuildName(i)
      }
    )    
  end

      
  ZO_ScrollList_Commit(listControl)
  
  ZO_ScrollList_SelectDataAndScrollIntoView(listControl, scrollData[1].data)
  ZO_ScrollList_RefreshVisible(listControl)

end

---------------------------------------------------------------------
-- Function: GetStorageName
--
-- This function returns the textual name for the storage type
---------------------------------------------------------------------
function CookeryWizStockpiles:GetStorageName(storageSelection)
  if storageSelection == STOCKPILES_SELECTION_BAG then
    return L[CWL_LABEL_SELECTION_BAG]
  elseif storageSelection == STOCKPILES_SELECTION_BANK then
    return L[CWL_LABEL_SELECTION_BANK]
  elseif storageSelection >= STOCKPILES_SELECTION_GUILD1 and storageSelection <= (STOCKPILES_SELECTION_BANK + self.guildCount) then
    return GetGuildName(storageSelection - STOCKPILES_SELECTION_BANK)
  else
    return "n/a"
  end  
end


---------------------------------------------------------------------
-- StockpileList specific Routines
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnStockpileListInitialized
--
-- This function is called when the GUI control for the stockpile
-- list has been initialised
---------------------------------------------------------------------
function CookeryWizStockpiles:OnStockpileListInitialized(control)
  self.stockpileScrollList = control
  if not control then
      trace("stockpileScrollList is nil")
      return
  end  
  
  -- It is important to note that rows are reused. This is an efficient way of optimising memory usage
  -- However, the row control will have left over data and settings from the previous time it was used
  -- This means you cannot rely on defaults and must explicitly clear/set them

  local function DestroyBaseRow(rowControl)
    ZO_ObjectPool_DefaultResetControl(rowControl)
  end

 	local function InitializeRow(rowControl, entry)    
    entry:SetRowControl(rowControl)
    -- Store the entry object with the row control so we can fetch it later at will
    rowControl.entry = entry
  end
  
 	local function SelectedStockpileRow(rowControl, entry)
    --d("Selected")
  end
  
	local function DestroyStockpileRow(rowControl)
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
		DestroyBaseRow(rowControl)
	end  
  
	local function HiddenStockpileRow(rowControl, entry)
    if entry then
      trace("Hidden row["..entry:GetName().."]")
    else
      trace("Hidden row")
    end
    -- Clear the entry object with the row contol so nothing is changed via GUI events
    if rowControl.entry then
      rowControl.entry:SetRowControl(nil)
      rowControl.entry = nil
    end
	end  
  
  ZO_ScrollList_Initialize(control)
  ZO_ScrollList_AddDataType(control, CWS_STOCKPILE_DATA_TYPE, "StockpileRowTemplate", 26, InitializeRow, HiddenStockpileRow, nil, DestroyStockpileRow)
  ZO_ScrollList_EnableSelection(control, "ZO_ThinListHighlight")
  ZO_ScrollList_SetAutoSelect(control, false)
	ZO_ScrollList_AddResizeOnScreenResize(control) 
  
end

function CookeryWizStockpiles:ChangeSortType(sortType)
  if self.sortType == sortType then
    self.sortAscending = not self.sortAscending
  end
  self:SortStockpile(sortType)
end


function CookeryWizStockpiles:SortStockpile(sortType)
  local listControl = self.stockpileScrollList
  if not listControl then
    trace("No listControl specified")
    return
  end
  
  local function SortName(a, b, sortAscending)
    local asc = self.sortAscending
    
    if sortAscending ~= nil then
      asc = sortAscending
    end
    
    if asc then     
      return a.data:GetName() < b.data:GetName()
    else
      return a.data:GetName() > b.data:GetName()
    end
  end 
  
  local function SortEnabled(a, b)
    if a.data:IsEnabled() == b.data:IsEnabled() then
      return SortName(a,b, true)
    end     
    if self.sortAscending then     
      return a.data:IsEnabled()
    else
      return b.data:IsEnabled()
    end
  end 
  
  local function SortMaximum(a, b)
    if a.data:GetMaximum() == b.data:GetMaximum() then
      return SortName(a,b, true)
    end    
    if self.sortAscending then     
      return a.data:GetMaximum() < b.data:GetMaximum()
    else
      return a.data:GetMaximum() > b.data:GetMaximum()
    end
  end

  
  local function SortTotal(a, b)
    if a.data:GetTotal() == b.data:GetTotal() then
      return SortName(a,b, true)
    end    
    if self.sortAscending then     
      return a.data:GetTotal() < b.data:GetTotal()
    else
      return a.data:GetTotal() > b.data:GetTotal()
    end    
    --[[
    local countBackpackA, countBankA = a.data:GetStacks()
    local countBackpackB, countBankB = b.data:GetStacks()
    local totalA = countBackpackA+countBankA
    local totalB = countBackpackB+countBankB
    if totalA == totalB then
      return SortName(a,b, true)
    end
    if self.sortAscending then
      return totalA < totalB
    else
      return totalA > totalB
    end
    ]]--
  end 
  
	local scrollData = ZO_ScrollList_GetDataList(listControl)
  local fnSort

  if sortType == SORT_STOCKPILE_NAME then
    fnSort = SortName
  elseif sortType == SORT_STOCKPILE_TOTAL then
    fnSort = SortTotal
  elseif sortType == SORT_STOCKPILE_MAXIMUM then
    fnSort = SortMaximum
  elseif sortType == SORT_STOCKPILE_ENABLED then
    fnSort = SortEnabled
  end
  
  self.sortType = sortType
  table.sort(scrollData, fnSort )  
  
  ZO_ScrollList_Commit(listControl) 
  
  ZO_ScrollList_RefreshVisible(listControl)
end

function CookeryWizStockpiles:RebuildScrollData(resetTop)
  trace("RebuildScrollData stockpile entries")
  
  local listControl = self.stockpileScrollList
  if not listControl then
    trace("No listControl specified")
    return
  end
   
  -- try and retain position in scroll list if already populated
  --self:SavePlayerTop()
  
	local scrollData = ZO_ScrollList_GetDataList(listControl)
	ZO_ScrollList_Clear(listControl)
  if resetTop then
    ZO_ScrollList_ResetToTop(listControl)
  end
 
  self:Enumerate(function(stockpile)
    local newEntry = ZO_ScrollList_CreateDataEntry(CWS_STOCKPILE_DATA_TYPE, stockpile)
    scrollData[#scrollData+1] = newEntry    
  end)

  self:SortStockpile(self.sortType)  

  trace("RebuildScrollData finished")
end


---------------------------------------------------------------------
-- General Routines
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: GetCount
--
-- This function returns the count of items for the given itemtype
-- TODO: more than just ingredient
---------------------------------------------------------------------
function CookeryWizStockpiles:GetCount(itemType)
  return self.count
end

---------------------------------------------------------------------
-- Function: SetStockpileHighlight
--
-- This function is called highlight the specified stockpile control
---------------------------------------------------------------------
function CookeryWizStockpiles:SetStockpileHighlight(control, state)

  local highlightControl = control:GetNamedChild("Highlight")

  highlightControl:SetHidden(not state)
end




function CookeryWizStockpiles:OnSelectedQualityButtonInitialized(control)
  self.selectedQualityControl = control
end

function CookeryWizStockpiles:OnQualityDownButtonInitialized(control)
  self.qualityDownButtonControl = control
end

function CookeryWizStockpiles:OnListQualityInitialized(control)
  self.qualityListControl = control
  control.selectCallback = self
end

function CookeryWizStockpiles:OnScrollListSelect(scrollList, entry)
  local quality = entry:GetQualityEntry()
  self.currentQuality = quality
  self.qualitySelector:SetSelectedQuality(quality)
  scrollList:SetHidden(true)
  --self:OnReloadRecipes(false)
end

local qualityTable = {
  {ITEM_QUALITY_NORMAL},
  {ITEM_QUALITY_ARTIFACT}, 
  {ITEM_QUALITY_LEGENDARY}  
}

---------------------------------------------------------------------
-- Function: Initialise
--
-- This function is called to initialise the stockpile information
-- object. Data is saved in the savedvariables file and this object
-- is passed to the function
---------------------------------------------------------------------
function CookeryWizStockpiles:Initialise(vars)
  CookeryWizGuildBank:Register(self.name, self) 
  
  self.qualitySelector = CookeryWizQualitySelector:new()
  self.qualitySelector:Initialise(self, self.qualityListControl, self.selectedQualityControl, self.qualityDownButtonControl, qualityTable)
  self.qualitySelector:PopulateQualityEntries()
  self.currentQuality = qualityTable[1]
  self.qualitySelector:SetSelectedQuality(self.currentQuality)  
  
  
  --[[
  if not vars.stockpileData or #vars.stockpileData == 0 then
    vars.stockpileData = {}
    vars.stockpileData.guilds = {}
    vars.stockpileData.itemTypes = {}
    vars.defaultMaxBackpack = 200
    vars.defaultMaxBank = 200
    vars.defaultMaxGuild = 200
  end
  
  -- store a reference to it
  --self.stockpileData = vars.stockpileData
  self.defaultMaxBackpack = vars.defaultMaxBackpack
  self.defaultMaxBank = vars.defaultMaxBank
  self.defaultMaxGuild = vars.defaultMaxGuild
  ]]--
end


---------------------------------------------------------------------
-- CookeryWizGuildBank events and related functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: RetrieveAllStockpileData
--
-- This function is called to populate all the stockpile objects with
-- stored data
---------------------------------------------------------------------
function CookeryWizStockpiles:RetrieveAllStockpileData(callback, storageTypeIndex, savedItemTypeVars, savedStorageVars)
  
  if not savedItemTypeVars then
    savedItemTypeVars = self:GetSavedItemTypeVars(callback)
    if not savedItemTypeVars then
      trace("Failed getting savedItemTypeVars")
      return
    end
  end
  
  if not savedStorageVars then
    savedStorageVars = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, false, savedItemTypeVars)
    if not savedStorageVars then
      trace("Failed getting savedStorageVars")
      return
    end
  end

  self:Enumerate(function(stockpile)
    local savedItemVars = self:GetSavedItemTypeStorageItemVars(stockpile, false, callback, storageTypeIndex, savedStorageVars, savedItemTypeVars)
    stockpile:PopulateData(storageTypeIndex, savedItemTypeVars, savedStorageVars, savedItemVars)
  end, callback)

end

---------------------------------------------------------------------
-- Function: RetrieveStockpileData
--
-- This function is called to populate a stockpile object with
-- stored data
---------------------------------------------------------------------
function CookeryWizStockpiles:RetrieveStockpileData(stockpile, callback, storageTypeIndex, savedItemTypeVars, savedStorageVars)
  trace("RetrieveStockpileData["..storageTypeIndex.."]")
  if not savedItemTypeVars then
    savedItemTypeVars = self:GetSavedItemTypeVars(callback)
    if not savedItemTypeVars then
      trace("Failed getting savedItemTypeVars")
      return
    end
  end
  
  if not savedStorageVars then
    savedStorageVars = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, false, savedItemTypeVars)
    if not savedStorageVars then
      trace("Failed getting savedStorageVars")
      return
    end
  end


  local savedItemVars = self:GetSavedItemTypeStorageItemVars(stockpile, false, callback, storageTypeIndex, savedStorageVars, savedItemTypeVars)
  stockpile:PopulateData(storageTypeIndex, savedItemTypeVars, savedStorageVars, savedItemVars)
end

CookeryWizStockpiles.lastSlotId = nil


function CookeryWizStockpiles:DumpStockpileData(itemType)

  callbackRegistrations:Enumerate(function(callback)
      if callback.itemType == itemType then
        d(callback.stockpiles)
        self:Enumerate(function(stockpile)           
          --d(stockpile:GetName()..", isEnabled["..tostring(stockpile:IsEnabled()).."]")
        end, callback)
        return true
      end
    end)      
end
---------------------------------------------------------------------
-- Function: OnGuildBankItemsReady
--
-- This function is called when a guild has been selected and items
-- are ready. It can be called multiple times in chunks of 200
---------------------------------------------------------------------

function CookeryWizStockpiles:OnGuildBankItemsReady(guildId)
  trace("CookeryWizStockpiles:OnGuildBankItemsReady")

  if self.lastSlotId == nil then
    -- reset the count for this storage and items
    trace("Reset the count")
    --callbackRegistrations:Enumerate(function(callback)
        --self:ClearStorageTotals(callback)
    --end)
    --self.manageStockpiles = {}
  end
  
  local slotId = GetNextGuildBankSlotId(self.lastSlotId)
  if not slotId then
    trace("-No SlotId returned from GetNextGuildBankSlotId")
    return
  end

  local storageTypeIndex = self:ResolveGuildIndex(guildId)
  trace("storageTypeIndex["..storageTypeIndex.."]")
  
  -- make sure the stockpile objects are populated with latest data
  callbackRegistrations:Enumerate(function(callback)
      
    local savedItemTypeVars = self:GetSavedItemTypeVars(callback)
    if not savedItemTypeVars then
      trace("Failed getting savedItemTypeVars")
      return
    end
  
    local savedStorageVars = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, true, savedItemTypeVars)
    if not savedStorageVars then
      trace("Failed getting savedStorageVars")
      return
    end
    
    self:RetrieveAllStockpileData(callback, storageTypeIndex, savedItemTypeVars, savedStorageVars)
    
    -- clear the totals
    self:Enumerate(function(stockpile)
      stockpile:SetTotal(0)
    end, callback)
  
  end)


    
  while slotId do
    local slotItemLink = GetItemLink(BAG_GUILDBANK, slotId, LINK_STYLE_DEFAULT )
    local slotItemType = GetItemLinkItemType(slotItemLink)
    local slotItemName = GetItemName(BAG_GUILDBANK, slotId)
    local slotItemId = CookeryWizUtils:GetItemID(slotItemLink)
    local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(BAG_GUILDBANK, slotId)
    --local stack, maxStack = GetSlotStackSize(BAG_GUILDBANK, slotId)    
    -- set the selected storage    
    callbackRegistrations:Enumerate(function(callback)
      --trace("slotItemType["..slotItemType.."], callback.itemType["..callback.itemType.."]")
      if callback.itemType == slotItemType then
        trace(slotItemName.."["..stack.."]")
        self:Enumerate(function(stockpile)           
          if stockpile:IsEnabled() then
            trace("-Stockpile["..stockpile:GetName().."] enabled")
            if stockpile:GetId() == slotItemId then
              trace("- Stockpile["..stockpile:GetName().."]")
              local total = stockpile:GetTotal() + stack
              stockpile:SetTotal(total)
                          
              local item = self:GetSavedItemTypeStorageItemVars(stockpile, true, callback, storageTypeIndex)
              item.total = total
              -- do we need to manage this?
              if stockpile:GetTotal() > stockpile:GetMaximum() then
                local found = false
                for i = 1, #callback.manageStockpiles do
                  if callback.manageStockpiles[i] == stockpile then
                    found = true
                    break
                  end
                end
                if not found then
                  callback.manageStockpiles[#callback.manageStockpiles + 1] = stockpile
                end
              end
            end
          end
        end, callback)       
      end
    end)    
    self.lastSlotId = slotId
    slotId = GetNextGuildBankSlotId(slotId)
  end
  
  local storageIndex = self:ResolveGuildIndex(guildId) 
  local storageType = tostring(storageIndex)

  callbackRegistrations:Enumerate(function(callback)
    self:SaveStockpiles(callback, storageIndex)
  end)     
  
  
end



---------------------------------------------------------------------
-- Function: OnManageStockpile
--
-- This function is called when the (guild)bank is to manage a
-- stockpile. We return a stockpile object to be managed
---------------------------------------------------------------------
function CookeryWizStockpiles:OnManageStockpile(guildId)
	trace("CookeryWizStockpiles:OnManageStockpile")

	local callback = callbackRegistrations:GetCurrentCallback()
	if not callback then
		trace("No callback. Finished")
		return
	end

	-- if we have managed all stockpiles for this callback, move to next
	if #callback.manageStockpiles == 0 then
		callback = callbackRegistrations:GetNextCallback()
		-- no more? then we have finished
		if not callback then
			trace("No more callbacks. Finished")
			return
		end
	end

	local stockpile = table.remove(callback.manageStockpiles)
  return stockpile
end

---------------------------------------------------------------------
-- Function: OnPrepareForGuildBank
--
-- This function is called when the guild bank is opened. It gives
-- us a chance to setup before things happen
---------------------------------------------------------------------
function CookeryWizStockpiles:OnPrepareForGuildBank(control)
  trace("CookeryWizStockpiles:OnPrepareForGuildBank")
  self.lastSlotId = nil
  callbackRegistrations:ResetNextCallback()
end

function CookeryWizStockpiles:OnGuildBankSelected(guildId)
  trace("CookeryWizStockpiles:OnGuildBankSelected")
  self.lastSlotId = nil
  callbackRegistrations:ResetNextCallback()
  -- reset the stockpile indexes for each call back
  callbackRegistrations:Enumerate(function(callback)
    callback.manageStockpiles = {}
  end)   
end

function CookeryWizStockpiles:OnPrepareForStockpiling(guildId)
  self.lastSlotId = nil
  callbackRegistrations:ResetNextCallback()
    
end

---------------------------------------------------------------------
-- Function: GetSavedItemTypeVars
--
-- This function is called to get the saved variables data structure
-- for the specific item type
-- If it does not exist then nil is returned
-- It can optionally create it if required
---------------------------------------------------------------------
function CookeryWizStockpiles:GetSavedItemTypeVars(callback, create)
  if not callback then
    callback = self.currentCallback
    if not callback then
      return
    end
  end
  
  local itemType = callback.itemType
  
  local itemTypes = callback.savedVariables.stockpileData.itemTypes
  local savedItemTypeVars
  
  for i = 1, #itemTypes do 
    local itemTypeSavedVars = itemTypes[i]
    if itemTypeSavedVars.itemType == itemType then
      savedItemTypeVars = itemTypeSavedVars
      break
    end
  end
  
  if not savedItemTypeVars and create then
    savedItemTypeVars = {}
    savedItemTypeVars.count = 0
    savedItemTypeVars.itemType = itemType
    local defaultMaxStack = 0
    if callback.parentObject.OnStockpilesGetDefaultMaximums then
      defaultMaxStack = callback.parentObject:OnStockpilesGetDefaultMaximums(itemType)
    end          
    savedItemTypeVars.defaultMaxStack = defaultMaxStack
          
    savedItemTypeVars.storage = {}
    itemTypes[#itemTypes + 1] = savedItemTypeVars  
  end
  
  return savedItemTypeVars
end

--[[
---------------------------------------------------------------------
-- Function: GetSavedItemVars
--
-- This function is called to get the saved variables data structure
-- for the specific item type
-- If it does not exist then nil is returned
---------------------------------------------------------------------
function CookeryWizStockpiles:GetSavedItemVars(callback)
  if not callback then
    callback = self.currentCallback
    if not callback then
      return
    end
  end
  
  local itemType = callback.itemType
  
  local itemTypes = callback.savedVariables.stockpileData.itemTypes
  for i = 1, #itemTypes do 
    local itemTypeSavedVars = itemTypes[i]
    if itemTypeSavedVars.itemType == itemType then
      return itemTypeSavedVars
    end
  end  
end
]]--

---------------------------------------------------------------------
-- Function: GetSavedItemTypeStorageVars
--
-- This function is called to get the saved variables data structure
-- for the specific item type and storage type
-- If it does not exist then nil is returned
---------------------------------------------------------------------
function CookeryWizStockpiles:GetSavedItemTypeStorageVars(callback, storageTypeIndex, create, itemTypeInfo)
  trace("GetSavedItemTypeStorageVars")
  
  if not callback then
    callback = self.currentCallback
    if not callback then
      trace("- no callback")
      return
    end
  end
  
  local savedItemTypeVars
  local typeOf = type(itemTypeInfo)
  if typeOf == "table" then
    -- we are item type vars
    trace("-passed savedItemTypeVars")
    savedItemTypeVars = itemTypeInfo
  else
    savedItemTypeVars = self:GetSavedItemTypeVars(callback, create)
  end
  
  if not savedItemTypeVars then
    trace("- failed finding itemtype saved vars")
    return
  end
  
  if not storageTypeIndex then
    trace("-using current storageTypeIndex")
    storageTypeIndex = self.currentStorageType
  end
  
  local storageType = tostring(storageTypeIndex)
  local storage = savedItemTypeVars.storage[storageType]
  
  if not storage and create then
    trace("-creating storage")
    storage = {}
    storage.default = savedItemTypeVars.defaultMaxStack
    savedItemTypeVars.storage[storageType] = storage
  end
  
  if storage and create then
    local items = storage.items
    if not items then
      items = {}
      storage.items = items
    end
  end
  
  if not storage then
    trace("-No storage")
  end
  return storage
  
end

--[[
---------------------------------------------------------------------
-- Function: GetSavedItemStorageVars
--
-- This function is called to get the saved variables data structure
-- for the specific item type and storage type
-- If it does not exist then nil is returned
---------------------------------------------------------------------
function CookeryWizStockpiles:GetSavedItemStorageVars(callback, storageTypeIndex, savedItemTypeVars)
  trace("GetSavedItemStorageVars")
  if not callback then
    callback = self.currentCallback
    if not callback then
      trace("- no callback")
      return
    end
  end
  
  if not storageTypeIndex then
    storageTypeIndex = self.currentStorageType
  end
  
  if not savedItemTypeVars then
    savedItemTypeVars = self:GetSavedItemTypeVars(callback)
  end
  
  if not savedItemTypeVars then
    trace("- failed finding itemtype saved vars")
    return
  end

  local storageType = tostring(storageTypeIndex)
  local storage = savedItemTypeVars.storage[storageType]
  
  return storage
  
end
]]--


--[[
---------------------------------------------------------------------
-- Function: CreateSavedItemStorageVars
--
-- This function is called to create the saved variables data
-- structures for the specific item type and storage type
---------------------------------------------------------------------
function CookeryWizStockpiles:CreateSavedItemStorageVars(callback, storageTypeIndex, savedItemTypeVars)
  if not callback then
    callback = self.currentCallback
    if not callback then
      return
    end
  end
 
  if not storageTypeIndex then
    storageTypeIndex = self.currentStorageType    
  end
  
  -- they should always exist as it is part of the registration process
  if not savedItemTypeVars then
    savedItemTypeVars = self:GetSavedItemTypeVars(callback)
  end
  
  if not savedItemTypeVars then
    trace("failed finding itemtype saved vars")
    return
  end
  
  local storage = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, false, savedItemTypeVars)
  if not storage then
    local storageType = tostring(storageTypeIndex)
    storage = {}
    storage.default = savedItemTypeVars.defaultMaxStack
    savedItemTypeVars.storage[storageType] = storage
  end
  
  local items = storage.items
  if not items then
    items = {}
    storage.items = items
  end
  
  return storage
end
]]--

---------------------------------------------------------------------
-- Function: GetSavedItemTypeStorageItemVars
--
-- This function is called to create the saved variables data
-- structures for the specific item type and storage type and stockpile
-- item
---------------------------------------------------------------------
function CookeryWizStockpiles:GetSavedItemTypeStorageItemVars(stockpile, create, callback, storageTypeIndex, savedStorageVars, savedItemTypeVars)
   
  if not savedStorageVars then
    if not savedItemTypeVars then
      savedItemTypeVars = self:GetSavedItemTypeVars(callback, create)
      if not savedItemTypeVars then
        trace("Unable to get item type vars")
        return
      end
    end
    
    savedStorageVars = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, create, savedItemTypeVars)
    if not savedStorageVars then
      trace("Unable to get storage vars")
      return
    end    
  end

  
  local items = savedStorageVars.items
  local itemKey = stockpile:GetKey()
  local item = items[itemKey]
  
  if create then
    if stockpile:IsEnabled() then
      if not item then
        item = {}
        items[itemKey] = item
      end
      
      local max = stockpile:GetMaximum()
      if max ~= savedStorageVars.default then
        item.max = max
      else
        item.max = nil
      end
      
      if not storageTypeIndex then
        storageTypeIndex = self.currentStorageType    
      end    
      local total = stockpile:GetTotal()
      trace("total["..total.."]")
      if total == 0 or storageTypeIndex <= STOCKPILES_SELECTION_BANK then
        item.total = nil
      else
        item.total = total
      end    
    else
      items[itemKey] = nil
    end
  end
  return item
end

--[[
---------------------------------------------------------------------
-- Function: CreateSavedItemStorageItemVars
--
-- This function is called to create the saved variables data
-- structures for the specific item type and storage type and stockpile
-- item
---------------------------------------------------------------------
function CookeryWizStockpiles:CreateSavedItemStorageItemVars(stockpile, callback, storageTypeIndex, savedItemVars)
  local storage = self:GetSavedItemTypeStorageVars(callback, storageTypeIndex, true, savedItemVars)
  --local storage = self:CreateSavedItemStorageVars(callback, storageTypeIndex, savedItemVars)
  if not storage then
    trace("Unable to creat storage")
    return
  end
  
  local items = storage.items
  local itemKey = stockpile:GetKey()
  if stockpile:IsEnabled() then
    local item = items[itemKey]
    if not item then        
      item = {}
      items[itemKey] = item
    end
    
    local max = stockpile:GetMaximum()
    if max ~= storage.default then
      item.max = max
    else
      item.max = nil
    end
    
    if not storageTypeIndex then
      storageTypeIndex = self.currentStorageType    
    end    
    local total = stockpile:GetTotal()
    trace("total["..total.."]")
    if total == 0 or storageTypeIndex <= STOCKPILES_SELECTION_BANK then
      item.total = nil
    else
      item.total = total
    end    
  else
    items[itemKey] = nil
  end  

end
]]--

---------------------------------------------------------------------
-- Function: SaveStockpiles
--
-- This function is called to save stockpile information to the
-- saved variables storage
-- It is meant to be called every time the storage selection changes
-- or the item type changes
-- In the future I may optimise it to only have in memory one item type
-- collection of object which reload according to storage and type
---------------------------------------------------------------------
function CookeryWizStockpiles:SaveStockpiles(callback, storageTypeIndex)
  trace("SaveStockpiles")
  --[[
  if not callback then
    callback = self.currentCallback
    if not callback then
      trace("-No callback")
      return
    end
  end
  
  if not storageTypeIndex then
    storageTypeIndex = self.currentStorageType
  end
  
  local savedVars = self:GetSavedItemVars(callback)
      
  if savedVars then
    trace("-Saving")
    local storageType = tostring(storageTypeIndex)
    -- storage first
    local storage = savedVars.storage[storageType]
    if not storage then
      storage = {}
      savedVars.storage[storageType] = storage
    end
    
    local items = storage.items
    if not items then
      items = {}
      storage.items = items
    end
    
    local countEnabled = 0
    self:Enumerate(function(stockpile)
      local itemKey = stockpile:GetKey()
      if stockpile:IsEnabled() then
        countEnabled = countEnabled + 1
        trace("Stockpile["..stockpile:GetName().."] is enabled")

        
        local item = items[itemKey]
        if not item then        
          item = {}
          items[itemKey] = item
        end
        
        local max = stockpile:GetMaximum()
        if max ~= savedVars.defaultMaxStack then
          item.max = max
        else
          item.max = nil
        end
        
        local total = stockpile:GetTotal()
        trace("total["..total.."]")
        if total == 0 then
          item.total = nil
        else
          item.total = total
        end
      else
        items[itemKey] = nil
      end
      
    end, callback)  
    
    if countEnabled == 0 then
      trace("Removing storage type["..storageType.."]")
      savedVars.storage[storageType] = nil
    end
  end
  ]]--
end

---------------------------------------------------------------------
-- Function: IsItemStorageEnabled
--
-- This function is called to determine whether item storage is
-- enabled for the current item type and selected storage
---------------------------------------------------------------------
function CookeryWizStockpiles:IsItemStorageEnabled(callback)
  trace("IsItemStorageEnabled")
  if not callback then
    callback = self.currentCallback
    if not callback then
      trace("-No callback")
      return
    end
  end
  
  local savedItemTypeVars = self:GetSavedItemTypeVars(callback)
  if not savedItemTypeVars then
    trace("-No Saved vars")
    return
  end
  
  local storageType = tostring(self.currentStorageType)
  trace("-storageType["..storageType.."]")
  local storage = savedItemTypeVars.storage[storageType]
  if storage then
    return true
  else
    return false
  end
  
end

---------------------------------------------------------------------
-- Function: CreateStockpile
--
-- This function is called to create a stockpile object
-- with a given id, quality, level
---------------------------------------------------------------------
function CookeryWizStockpiles:CreateStockpile(callback, id, quality, level)
  local keyStockpile = tostring(id)
  if quality then
    keyStockpile = keyStockpile.."-"..quality
    if level then
      keyStockpile = keyStockpile.."-"..level
    end
  end
  
  local stockpile = callback.stockpiles[keyStockpile]
  if not stockpile then
    callback.count = self.count + 1
    stockpile = CookeryWizStockpile:new(keyStockpile, data)
    callback.stockpiles[keyStockpile] = stockpile
  end

  return stockpile  

end



---------------------------------------------------------------------
-- Function: UpdateItemData
--
-- This function is called to update a stockpile object
-- with current data (stored or defaults)
---------------------------------------------------------------------
function CookeryWizStockpiles:UpdateItemData(stockpile)
  --trace("UpdateItemData")
  local defaultMaxStack = 100
  local total = ""
  
  local savedItemTypeVars = self:GetSavedItemTypeVars()
  if not savedItemTypeVars then
    trace("- no saved vars!")
    return
  end
  
  local storageSelection = self.currentStorageType
  if not storageSelection then
    storageSelection = STOCKPILES_SELECTION_BAG
  end  

  local storageType = tostring(storageSelection)
  
  defaultMaxStack = savedItemTypeVars.defaultMaxStack

  local isEnabled = false
  local item = nil
  local items
  
  -- storage first
  local storage = savedItemTypeVars.storage[storageType]
  if storage then
    items = storage.items
    if items then
      local itemKey = stockpile:GetKey()
      item = items[itemKey]      
      if item then
        isEnabled = true
      end
    end
  end

  
  if storageSelection == STOCKPILES_SELECTION_BAG then
    local countBackpack, countBank = stockpile:GetStacks()
    total = countBackpack
  elseif storageSelection == STOCKPILES_SELECTION_BANK then
    local countBackpack, countBank = stockpile:GetStacks()
    total = countBank
  end
  
  local maximum = defaultMaxStack
  
  if item then
    --trace("Saved Entry found")
    if item.max then
      maximum = item.max
    end
    if item.total and item.total ~= "" then
      total = item.total
    end    
  end
  
  stockpile:SetTotal(total)
  stockpile:SetMaximum(maximum)
  stockpile:SetIsEnabled(isEnabled)
end
---------------------------------------------------------------------
-- Function: Enumerate
--
-- This function is called to enumerate the stockpile items calling a
-- custom function
---------------------------------------------------------------------
function CookeryWizStockpiles:Enumerate(fn, callback)
  if not fn then
    trace("No function passed to Enumerate")
    return
  end
  
  if not callback then
    callback = self.currentCallback
    if not callback then
      trace("No current callback")
      return   
    end
  end
  
  for key, stockpile in pairs(callback.stockpiles) do 
    if fn(stockpile) then
      break
    end
  end    
end

---------------------------------------------------------------------
-- Function: GetStockpile
--
-- This function is called to retrieve the stockpile object
-- for a given key
-- For CookeryWiz this key will be ingredient id or food id
-- The key will be forced to a string
---------------------------------------------------------------------
--[[
function CookeryWizStockpiles:GetStockpile(key)
  local keyStockpile = tostring(key)
  local stockpile = self.stockpiles[keyStockpile]
  return stockpile
end
]]--

---------------------------------------------------------------------
-- Function: GetCount()
--
-- This function returns the number of stockpile objects
---------------------------------------------------------------------
function CookeryWizStockpiles:GetCount()
  return self.count
end

---------------------------------------------------------------------
-- Function: GetDefaultMaxBackpack
--
-- This function returns the default max backpack amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:GetDefaultMaxBackpack()
  if self.itemTypeCollection and self.itemTypeCollection.defaultMaxBackpack then
    return self.itemTypeCollection.defaultMaxBackpack
  else
    return 0
  end
end

---------------------------------------------------------------------
-- Function: SetDefaultMaxBackpack
--
-- This function sets the default max backpack amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:SetDefaultMaxBackpack(defaultMaxBackpack)
  if self.itemTypeCollection then  
    self.itemTypeCollection.defaultMaxBackpack = defaultMaxBackpack
  end
end

---------------------------------------------------------------------
-- Function: GetDefaultMaxBank
--
-- This function returns the default max bank amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:GetDefaultMaxBank()
  if self.itemTypeCollection and self.itemTypeCollection.defaultMaxBank then
    return self.itemTypeCollection.defaultMaxBank
  else
    return 0
  end
end

---------------------------------------------------------------------
-- Function: SetDefaultMaxBank
--
-- This function sets the default max bank amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:SetDefaultMaxBank(defaultMaxBank)
  if self.itemTypeCollection then  
    self.itemTypeCollection.defaultMaxBank = defaultMaxBank
  end  
end

---------------------------------------------------------------------
-- Function: GetDefaultMaxGuild
--
-- This function returns the default max guild amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:GetDefaultMaxGuild()
  if self.itemTypeCollection and self.itemTypeCollection.defaultMaxGuild then
    return self.itemTypeCollection.defaultMaxGuild
  else
    return 0
  end
end


---------------------------------------------------------------------
-- Function: SetDefaultMaxGuild
--
-- This function sets the default max guild amount
-- which is used for new entries
---------------------------------------------------------------------
function CookeryWizStockpiles:SetDefaultMaxGuild(defaultMaxGuild)
  if self.itemTypeCollection then  
    self.itemTypeCollection.defaultMaxGuild = defaultMaxGuild
  end  
end

---------------------------------------------------------------------
-- Function: SetStockpile
--
-- This function is called to set the stockpile object
-- for a given key
-- For CookeryWiz this key will be ingredient id or food id
-- The key will be forced to a string
---------------------------------------------------------------------
--[[
function CookeryWizStockpiles:SetStockpile(key)
  local stockpile = self.stockpiles[tostring(key)]
end
]]--

function CookeryWizStockpiles:Dump()
  -- set the selected storage
  self:Enumerate(function(stockpile)
    stockpile:Dump()
  end)  
end
