
CookeryWizIngredient = {}


CookeryWizIngredient.id = nil
CookeryWizIngredient.cookQuantity = 0

local realLinkFormat = "|H0:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local stolenLinkFormat = "|H1:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:16:0:0:0:1:0:0|h|h"
local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

function CookeryWizIngredient:new (id)
  o = {}
  o.id = id 
  
  local ingredientLink
  ingredientLink = string.format(testLinkFormat, id) 
  -- try and get name, as this determines whether we are valid!
  o.name = GetItemLinkName(ingredientLink)
  
  if o.name and o.name ~= "" then
    
    o.quality = GetItemLinkQuality(ingredientLink)
    o.level = GetItemLinkRequiredLevel(ingredientLink)
    o.link = string.format(realLinkFormat, id, o.quality, o.level)  
    o.stolenLink = string.format(stolenLinkFormat, id, o.quality, o.level)  
  end  

  setmetatable(o, self)
  self.__index = self      
  return o
end

function CookeryWizIngredient:GetName()
  if not self.name then
    self.name = GetItemLinkName(self.link)
  end
  return self.name  
end

function CookeryWizIngredient:GetQuality()
  return self.quality  
end

function CookeryWizIngredient:GetLevel()
  return self.level  
end


function CookeryWizIngredient:GetStock()

  local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(self.link)
  --d("Backpack-"..stackCountBackpack..", Bank-"..stackCountBank, Craft-"..stackCountCraftBag)
  local total = stackCountBackpack + stackCountBank + stackCountCraftBag
  return total  
end

function CookeryWizIngredient:GetStolenStock()
  local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(self.stolenLink)
  --d("Backpack-"..stackCountBackpack..", Bank-"..stackCountBank, Craft-"..stackCountCraftBag)
  local total = stackCountBackpack + stackCountBank + stackCountCraftBag
  return total  
end


function CookeryWizIngredient:GetNameLower()
  if not self.lowername then
    self.lowername = self:GetName():lower()
  end
  return self.lowername
end

function CookeryWizIngredient:GetLink()
  return self.link
end

function CookeryWizIngredient:GetItemId()
    if not self.id then      
      self.id = CookeryWizUtils:GetItemID(self.link)
    end
    return self.id
end

---------------------------------------------------------------------
-- Function: GetIcon
--
-- This function returns the icon for the ingredient
---------------------------------------------------------------------
function CookeryWizIngredient:GetIcon()
  if not self.icon then
    local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(self.link)    
    self.icon = icon
  end
  return self.icon
end

---------------------------------------------------------------------
-- Function: GetDataType
--
-- This function returns the scroll list template data type
---------------------------------------------------------------------
function CookeryWizIngredient:GetDataType()
  return CW_INGREDIENT_DATA_TYPE
end

---------------------------------------------------------------------
-- Ingredient scroll list specific routines
---------------------------------------------------------------------

CookeryWizIngredient.rowControl = nil
CookeryWizIngredient.quantityControl = nil
CookeryWizIngredient.iconControl = nil
CookeryWizIngredient.availableControl = nil

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizIngredient:SetRowControl(rowControl)
  self.rowControl = rowControl
  if rowControl then
    self.quantityControl = rowControl:GetNamedChild("Quantity")
    self.iconControl = rowControl:GetNamedChild("Icon")
    self.availableControl = rowControl:GetNamedChild("Available")
    
    -- icon only needs to be set once
    local iconText = zo_iconTextFormat(self:GetIcon(), 24, 24, self.link)
    self.iconControl:SetText(iconText)
    
    self:UpdateRowControlData()
  else
    self.iconControl = nil
    self.quantityControl = nil
    self.availableControl = nil
  end
end

---------------------------------------------------------------------
-- Function: UpdateRowControlData
--
-- This function updates the data in the row control associated with this object
---------------------------------------------------------------------
function CookeryWizIngredient:UpdateRowControlData()
  if self.rowControl then
    self:UpdateQuantityControl()
    self:UpdateAvailableControl()
  else
    d("No rowcontrol")
  end
end

---------------------------------------------------------------------
-- Function: UpdateQuantityControl
--
-- This function displays the quantity required
---------------------------------------------------------------------
function CookeryWizIngredient:UpdateQuantityControl()
  if not self.quantityControl then
    return
  end  

  local quantityControl = self.quantityControl


  local stocked = self:GetStock()
  --local stolen = self:GetStolenStock()
  local totalStock = stocked --+ stolen
  
  local quantityText = self.cookQuantity

  if totalStock and self.cookQuantity <= totalStock then
    quantityControl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
  else
    quantityControl:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
  end

  --d("setText["..quantityText.."]")
  quantityControl:SetText(quantityText)
end

---------------------------------------------------------------------
-- Function: UpdateAvailableControl
--
-- This function displays the available amount
---------------------------------------------------------------------
function CookeryWizIngredient:UpdateAvailableControl()
  if not self.availableControl then
    return
  end  

  local availableControl = self.availableControl

  local stocked = self:GetStock()
  --local stolen = self:GetStolenStock()
  local totalStock = stocked --+ stolen
  
  availableControl:SetText(totalStock)
end

---------------------------------------------------------------------
-- Function: GetCookQuantity
--
-- This function returns the total quantity of this type of ingredient
-- used in the recipes that are to be cooked
---------------------------------------------------------------------
function CookeryWizIngredient:GetCookQuantity()
  return self.cookQuantity  
end

---------------------------------------------------------------------
-- Function: GetCookQuantity
--
-- This function sets the total quantity of this type of ingredient
-- used in the recipes that are to be cooked
---------------------------------------------------------------------
function CookeryWizIngredient:SetCookQuantity(cookQuantity)
  self.cookQuantity = cookQuantity
  self:UpdateQuantityControl()
end
