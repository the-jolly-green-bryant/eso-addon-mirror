
local linkFormat = "|H1:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local stolenLinkFormat = "|H1:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0|h|h"

STOCKPILES_SELECTION_BAG = 1
STOCKPILES_SELECTION_BANK = 2
STOCKPILES_SELECTION_GUILD1 = 3
STOCKPILES_SELECTION_GUILD2 = 4
STOCKPILES_SELECTION_GUILD3 = 5
STOCKPILES_SELECTION_GUILD4 = 6
STOCKPILES_SELECTION_GUILD5 = 7

CookeryWizStockpile = {}
CookeryWizStockpile.storageSelection = STOCKPILES_SELECTION_BAG

CookeryWizStockpile.itemType = nil
CookeryWizStockpile.storageType = STOCKPILES_SELECTION_BAG
CookeryWizStockpile.maximum = 0
CookeryWizStockpile.total = 0
CookeryWizStockpile.stackCount = 0
CookeryWizStockpile.isEnabled = false

CookeryWizStockpile.traceEnabled = false
--CookeryWizStockpile.data = nil

local function trace(msg)
  if CookeryWizStockpile.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: new
--
-- This function is called to construct a new stockpile object
---------------------------------------------------------------------
function CookeryWizStockpile:new(key, data) 
  local o = {}
  o.data = data
  o.key = key
  local id, quality, level = SplitString("-", key) 
  o.id = tonumber(id)
  o.quality = tonumber(quality)
  o.level = tonumber(level)
  o.storageSelection = STOCKPILES_SELECTION_BAG
  o.link = zo_strformat("<<1>>", string.format(linkFormat, o.id, o.quality, o.level))
  o.stolenLink = zo_strformat("<<1>>", string.format(stolenLinkFormat, o.id, o.quality, o.level))
  --o.link = string.format(linkFormat, o.id, o.quality, o.level)
  setmetatable(o, self)
  self.__index = self
  return o  
end

function CookeryWizStockpile:Dump()
  d("Name:["..self:GetName().."]")
  if self.storageSelection then
    d("Storage:["..self.storageSelection.."]")
  else
    d("Storage:[nil]")
  end
  d("Total:["..self:GetTotal().."]")
  d("Max:["..self:GetMaximum().."]")
end

---------------------------------------------------------------------
-- Function: SetItemType
--
-- This function sets the item type of the data we are using
---------------------------------------------------------------------
function CookeryWizStockpile:SetItemType(itemType)  
  self.itemType = itemType
  self:UpdateRowControlData()
end

---------------------------------------------------------------------
-- Function: SetStorageType
--
-- This function sets the storage type of the data we are using
---------------------------------------------------------------------
function CookeryWizStockpile:SetStorageType(storageType)
  self.storageType = storageType
  self:UpdateRowControlData()
end


---------------------------------------------------------------------
-- Function: GetStacks
--
-- This function is called to get the current stack counts
-- of the backpack, bank and later guild banks
---------------------------------------------------------------------
function CookeryWizStockpile:GetStacks()
  local countBackpack, countBank = GetItemLinkStacks(self.link)
  local stolenBackpack, stolenBank = GetItemLinkStacks(self.stolenLink)
  return countBackpack + stolenBackpack, countBank
end

---------------------------------------------------------------------
-- Function: GetId
--
-- This function returns the id
---------------------------------------------------------------------
function CookeryWizStockpile:GetId()
  return self.id
end

---------------------------------------------------------------------
-- Function: GetKey
--
-- This function returns the key
---------------------------------------------------------------------
function CookeryWizStockpile:GetKey()
  return self.key
end

---------------------------------------------------------------------
-- Function: GetLink
--
-- This function returns the link
---------------------------------------------------------------------
function CookeryWizStockpile:GetLink()
  return self.link
end

---------------------------------------------------------------------
-- Function: GetQuality
--
-- This function returns the quality
---------------------------------------------------------------------
function CookeryWizStockpile:GetQuality()
  return self.quality
end

---------------------------------------------------------------------
-- Function: GetLevel
--
-- This function returns the level
---------------------------------------------------------------------
function CookeryWizStockpile:GetLevel()
  return self.level
end

---------------------------------------------------------------------
-- Function: GetName
--
-- This function returns the name
---------------------------------------------------------------------
function CookeryWizStockpile:GetName()
  if not self.name then    
    self.name = zo_strformat("<<1>>", GetItemLinkName(self.link))
  end
  return self.name
end

---------------------------------------------------------------------
-- Function: GetNameLower
--
-- This function returns the lowercase name
---------------------------------------------------------------------
function CookeryWizStockpile:GetNameLower()
  if not self.nameLower then
    self.nameLower = self:GetName():lower()
  end
  return self.nameLower
end

---------------------------------------------------------------------
-- Function: PopulateData
--
-- This function populates data from the saved variables file
---------------------------------------------------------------------
function CookeryWizStockpile:PopulateData(storageTypeIndex, itemTypeVars, storageVars, itemVars)
  
  self.storageType = storageTypeIndex
  
  local isEnabled = false
  if itemVars then
    isEnabled = true
  end
  self:SetIsEnabled(isEnabled)
  
  local max
  if itemVars and itemVars.max then
    max = itemVars.max
  elseif storageVars and storageVars.default then
    max = storageVars.default
  else
    max = itemTypeVars.defaultMaxStack
  end
  self:SetMaximum(max)
  
  local total
  if itemVars and itemVars.total then
    total = tonumber(itemVars.total)
    if not total then
      total = 0
    end
  else
    if storageTypeIndex == STOCKPILES_SELECTION_BAG then
      local countBackpack, countBank = self:GetStacks()
      total = countBackpack
    elseif storageTypeIndex == STOCKPILES_SELECTION_BANK then
      local countBackpack, countBank = self:GetStacks()
      total = countBank
    end     
  end
  self:SetTotal(total)
  --self.total = total
end

---------------------------------------------------------------------
-- Function: GetMaximum
--
-- This function returns the maximum to retain for the item
---------------------------------------------------------------------
function CookeryWizStockpile:GetMaximum()
  return self.maximum
end


---------------------------------------------------------------------
-- Function: SetMaximum
--
-- This function sets the maximum amount to retain for the item
---------------------------------------------------------------------
function CookeryWizStockpile:SetMaximum(maximum)
  if maximum ~= self.maximum then
    self.maximum = maximum
    self:UpdateMaximumControl()
  end  
end

---------------------------------------------------------------------
-- Function: UpdateMaximumControl
--
-- This function updates the gui to reflect the maximum value
---------------------------------------------------------------------
function CookeryWizStockpile:UpdateMaximumControl()
  trace("UpdateMaximumControl["..self:GetName().."]")
  if self.editMaximumControl then
    local text = ""
    if self.isEnabled then
      text = self:GetMaximum()
      if text == -1 then
        -- 0xE2 0x88 0x9E
        -- 226 136 158
        --text = "∞"
        text = ""
      end
    end
    self.editMaximumControl:SetEditEnabled(self.isEnabled)
    self.editMaximumControl:SetText(text)
  end
end


---------------------------------------------------------------------
-- Function: GetTotal
--
-- This function returns the total available quantity
-- of the selected item
---------------------------------------------------------------------
function CookeryWizStockpile:GetTotal()
  return self.total
end

---------------------------------------------------------------------
-- Function: SetTotal
--
-- This function sets the total available quantity
-- of the seelcted item
---------------------------------------------------------------------
function CookeryWizStockpile:SetTotal(total)
  if self.total ~= total then
    self.total = total
    self:UpdateTotalControl()
  end  
end


---------------------------------------------------------------------
-- Function: UpdateTotalControl
--
-- This function updates the gui to reflect the total of the
-- currently selected storage
---------------------------------------------------------------------
function CookeryWizStockpile:UpdateTotalControl()
  trace("UpdateMaximumControl["..self:GetName().."]")
  if self.totalQuantityLabel then
    self.totalQuantityLabel:SetText(self:GetTotal())
  end
end

--[[
---------------------------------------------------------------------
-- Function: GetStorageSelection
--
-- This function returns the currently set storage selection
---------------------------------------------------------------------
function CookeryWizStockpile:GetStorageSelection()
  return self.storageSelection
end


---------------------------------------------------------------------
-- Function: SetCurrentStorageSelection
--
-- This function sets the storage selection to use
---------------------------------------------------------------------
function CookeryWizStockpile:SetStorageSelection(storageSelection)
  if not storageSelection then
    storageSelection = STOCKPILES_SELECTION_BAG
  end
  self.storageSelection = storageSelection
  self:UpdateRowControlData()
end
]]--

---------------------------------------------------------------------
-- Function: IsEnabled
--
-- This function returns whether inventory management is enabled for
-- this item
---------------------------------------------------------------------
function CookeryWizStockpile:IsEnabled(storageSelection)
  if not storageSelection then
    storageSelection = self.storageSelection
  end   
  --return self.data.storage[storageSelection].enabled
  return self.isEnabled
end

---------------------------------------------------------------------
-- Function: SetIsEnabled
--
-- This function enables or disables inventory management for the selected
-- item in the selected storage type
---------------------------------------------------------------------
function CookeryWizStockpile:SetIsEnabled(enabled, storageSelection)
  --[[
  if not storageSelection then
    storageSelection = self.storageSelection
  end
  if not enabled then
    -- dont clutter up the saved vars files with enabled value if false
    self.data.storage[storageSelection].enabled = nil
  else
    self.data.storage[storageSelection].enabled = true
  end
  self:UpdateEnabledControl()
  ]]--
  if self.isEnabled ~= enabled then
    self.isEnabled = enabled
    self:UpdateEnabledControl()
  end
end

---------------------------------------------------------------------
-- Function: UpdateEnabledControl
--
-- This function updates the gui to reflect the value
---------------------------------------------------------------------
function CookeryWizStockpile:UpdateEnabledControl()
  trace("UpdateEnabledControl["..self:GetName().."]")
  if self.enabledControl then
    if self:IsEnabled() then
        ZO_CheckButton_SetChecked(self.enabledControl)
    else
        ZO_CheckButton_SetUnchecked(self.enabledControl)
    end
    self:UpdateNameControl()
    self:UpdateMaximumControl()    
  end
end

---------------------------------------------------------------------
-- Function: UpdateNameControl
--
-- This function updates the gui alpha of the name control
---------------------------------------------------------------------
function CookeryWizStockpile:UpdateNameControl()
  trace("UpdateEnabledControl["..self:GetName().."]")
  if self.enabledControl then
    if self:IsEnabled() then
      self.nameLabelControl:SetAlpha(1)
    else
      self.nameLabelControl:SetAlpha(0.6)
    end
  end
end

CookeryWizStockpile.nameLabelControl = nil
CookeryWizStockpile.totalQuantityLabel = nil
CookeryWizStockpile.editMaximumControl = nil
CookeryWizStockpile.enabledControl = nil

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizStockpile:SetRowControl(rowControl)
  self.rowControl = rowControl
  if rowControl then
    
    self.nameLabelControl = rowControl:GetNamedChild("Name")    
    self.totalQuantityLabel = rowControl:GetNamedChild("TotalQuantityLabel")
    self.editMaximumControl = rowControl:GetNamedChild("EditMaximum")
    self.enabledControl = rowControl:GetNamedChild("EnableStockpileCheckButton")
    
    local name = CookeryWizUtils:SetToLinkQualityColor(self.link, self:GetName())
    self.nameLabelControl:SetText(name)    
       
    -- hmm not sure if I need all this as the update changes things
    self:UpdateRowControlData()
  else
    self.nameLabelControl = nil  
    self.totalQuantityLabel = nil
    self.editMaximumControl = nil
    self.enabledControl = nil
  end
end

---------------------------------------------------------------------
-- Function: UpdateRowControlData
--
-- This function updates the data in the row control associated with this object
---------------------------------------------------------------------
function CookeryWizStockpile:UpdateRowControlData()
  if self.rowControl then
    trace("UpdateRowControlData["..self:GetName().."]")
    -- update the data
    --CookeryWizStockpiles:UpdateItemData(self)
  
    self:UpdateEnabledControl()
        
    --local countBackpack, countBank = self:GetStacks()
    --local displayTotal = (countBackpack+countBank).." ("..countBackpack.."/"..countBank..")"
    --self.totalQuantityLabel:SetText(displayTotal)
    
    self:UpdateTotalControl()
    self:UpdateMaximumControl()
  end
end

