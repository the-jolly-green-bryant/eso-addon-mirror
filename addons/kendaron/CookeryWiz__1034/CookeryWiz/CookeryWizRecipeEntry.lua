local L = CookeryWizLanguage.language

CookeryWizRecipeEntry = {}

local recipeLinkFormat = "|H1:item:%u:%u:%u:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

CookeryWizRecipeEntry.traceEnabled = false
CookeryWizRecipeEntry.isFavourite = false

local function trace(msg)
  if CookeryWizRecipeEntry.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

function CookeryWizRecipeEntry:new (id, cat, index, favouriteIndex)
  o = {}   
  return self:set(o, id, cat, index, favouriteIndex)
end

---------------------------------------------------------------------
-- Function: set
--
-- This function is called to associate the recipe object with a base
-- class CookeryWizRecipeEntry
---------------------------------------------------------------------
function CookeryWizRecipeEntry:set (o, cat, masterRecipeListIndex)
  --o.id = id 
  local id = o.id
  o.cat = cat
  -- basically rename this field
  o.recipeIndex = o.index
  o.index = masterRecipeListIndex  
  o.favouriteIndex = CookeryWiz:GetFavouriteIndex(id)
  o.relativeIndex = 0
  
  local recipelink  
  recipelink = string.format(testLinkFormat, id) 
  -- try and get name, as this determines whether we are valid!
  o.name = GetItemLinkName(recipelink)
  
  if o.name and o.name ~= "" then
    local quality = GetItemLinkQuality(recipelink)
    local level = GetItemLinkRequiredLevel(recipelink)
    o.rid =  zo_strformat("<<1>>", string.format(recipeLinkFormat, id, quality, level)) 
    o.name = GetItemLinkName(o.rid)
  end
  setmetatable(o, self)
  self.__index = self      
  return o
end


function CookeryWizRecipeEntry:setOld (o, id, cat, index, favouriteIndex)
  o.id = id 
  o.cat = cat
  o.recipeIndex = index
  o.favouriteIndex = favouriteIndex
  local recipelink  
  recipelink = string.format(testLinkFormat, id) 
  -- try and get name, as this determines whether we are valid!
  o.name = GetItemLinkName(recipelink)
  
  if o.name and o.name ~= "" then
    local quality = GetItemLinkQuality(recipelink)
    local level = GetItemLinkRequiredLevel(recipelink)
    o.rid =  zo_strformat("<<1>>", string.format(recipeLinkFormat, id, quality, level)) 
    o.name = GetItemLinkName(o.rid)
  end
  setmetatable(o, self)
  self.__index = self      
  return o
end

-- Set it manually. This would be used when a recipe is learnt
function CookeryWizRecipeEntry:SetRecipeIndex(recipeIndex)
  self.recipeIndex = recipeIndex
end


CookeryWizRecipeEntry.useNew = false


function CookeryWizRecipeEntry:DumpKeyData()
  
  d("Id:"..self.id..",FoodId:"..self.foodId)
end


---------------------------------------------------------------------
-- Function: SetRelativeIndex
--
-- This function sets the relative index of the recipe in the recipe category.
-- This is the CookeryWiz recipe category, not the in-game list.
-- This is used when encoding known recipes for sending via mail
---------------------------------------------------------------------
function CookeryWizRecipeEntry:SetRelativeIndex(relativeIndex)
  self.relativeIndex = relativeIndex
end

---------------------------------------------------------------------
-- Function: GetRelativeIndex
--
-- This function gets the relative index of the recipe in the recipe category.
-- This is the CookeryWiz recipe category, not the in-game list.
-- This is used when encoding known recipes for sending via mail
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetRelativeIndex()
  return self.relativeIndex
end

---------------------------------------------------------------------
-- Function: PopulateRecipeIndex
--
-- This function attempts to match up a recipe with the in-game recipeList
-- by finding its recipe list index. If the index already exists it will
-- not be updated again
---------------------------------------------------------------------
function CookeryWizRecipeEntry:PopulateRecipeIndex(recipeCount)
  --recipeCount = nil
  -- only do if it is nil
  if not self.recipeIndex then
    if not recipeCount then
      -- using count from recipeCount has to be faster using this stored value rather than calling GetRecipeListInfo!
      local name, numRecipes = GetRecipeListInfo(self.cat)
      recipeCount = numRecipes
      --recipeCount = MasterRecipeList:GetListCount(self.cat)
    end

    -- cache the return value
    local foodId = self:GetFoodId()
    for i= 1, recipeCount do    
      local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(self.cat, i)
      --trace("-"..foodName)
      if known then
        local link = GetRecipeResultItemLink(self.cat, i)
        --d(link)
        local id = select(4,ZO_LinkHandler_ParseLink(link))  
        local linkId = tonumber(id)
        if linkId == foodId then          
          self.recipeIndex = i
          break;
        end         
      end
    end
  end
end



---------------------------------------------------------------------
-- Function: GetRecipeIndex
--
-- Gets the index of the recipe in the in-game recipe list
-- is nil if not set
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetRecipeIndex()
  return self.recipeIndex
end

---------------------------------------------------------------------
-- Function: GetRecipeListIndex
--
-- Returns the recipe list index it belongs to
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetRecipeListIndex()
  return self.cat
end

function CookeryWizRecipeEntry:GetIngredientCount()
  if not self.numIngredients then
    self.numIngredients = GetItemLinkRecipeNumIngredients(self.rid)
  end
  return self.numIngredients
end

function CookeryWizRecipeEntry:GetStackCount()  
  local _, icon, stack, sellPrice, quality = GetRecipeResultItemInfo(self:GetRecipeListIndex(), self:GetRecipeIndex())
  return stack
end

-- Returns a table of ingredients
function CookeryWizRecipeEntry:GetIngredients()
  if not self.ingredients then
    local ingredients = {}
    local total = self:GetIngredientCount()
    
    for i=1, total do
      local name, stockedAmount, amountRequired = GetItemLinkRecipeIngredientInfo(self.rid, i)

      --d(name.."["..stockedAmount.."]")
      -- They are all now one of each?
      local entryIngredient = CookeryWizIngredients:GetEntryByName(name)
      --local entry = { name = name, link = entryIngredient:GetLink(), quantity = 1, stocked = stockedAmount }
      --ingredients[#ingredients + 1] = entry
      
      ingredients[#ingredients + 1] = { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}
    end

    self.ingredients = ingredients
  end
  return self.ingredients
end

function CookeryWizRecipeEntry:GetRecipeNameLower()
  if not self.lowername then
    self.lowername = self:GetRecipeName():lower()
  end
  return self.lowername
end

---------------------------------------------------------------------
-- Function: GetRecipeName
--
-- Returns the name of the recipe
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetRecipeName()
  if not self.name then
    self.name = GetItemLinkName(self.rid)
  end
  return self.name
end

---------------------------------------------------------------------
-- Function: ItemId
--
-- returns the ingame numeric id corresponding to this recipe
---------------------------------------------------------------------
function CookeryWizRecipeEntry:ItemId()
  if not self.id then
    local id = select(4,ZO_LinkHandler_ParseLink(self.rid)) 
    self.id = tonumber(id)
  end
  return self.id
end
  
function CookeryWizRecipeEntry:GetRecipeLink()
  return self.rid
end

function CookeryWizRecipeEntry:IsKnown()
  return IsItemLinkRecipeKnown(self.rid)
end

---------------------------------------------------------------------
-- Function: GetIndex
--
-- returns the index of this entry in the master recipe list table
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetIndex()
  return self.index
end

function CookeryWizRecipeEntry:GetFoodResultLink(linkStyle)
  if not self.fid then
    self.fid = GetItemLinkRecipeResultItemLink(self.rid)
    --self.fid = zo_strformat("<<1>>", GetItemLinkRecipeResultItemLink(self.rid))
  end  
  return self.fid
end

function CookeryWizRecipeEntry:GetFoodId()
    if not self.foodId then
      local id = select(4,ZO_LinkHandler_ParseLink(self:GetFoodResultLink()))  
      self.foodId = tonumber(id)
    end  
    return self.foodId
end

---------------------------------------------------------------------
-- Function: GetFoodLevel
--
-- This function returns the level of the food
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetFoodLevel()
  local link = self:GetFoodResultLink()
  local level = GetItemLinkRequiredLevel(link)
  return level
end

function CookeryWizRecipeEntry:GetFoodResultLinkStyle(linkStyle)
  return zo_strformat("<<1>>", GetItemLinkRecipeResultItemLink(self.rid, linkStyle))
end

--[[
function CookeryWizRecipeEntry:GetRecipeRank()
  if not self.recipeRank then
    --self.recipeLevel = GetItemLinkRequiredCraftingSkillRank(self.rid)
    self.recipeRank = GetItemLinkRecipeRankRequirement(self.rid) 
  end
  return self.recipeRank
end
]]--

function CookeryWizRecipeEntry:GetRecipeQualityRequirement()
  if not self.recipeQualityRequirement then
    self.recipeQualityRequirement = GetItemLinkRecipeQualityRequirement(self.rid)
    --self:PopulateRecipeData(nil)
  end
  return self.recipeQualityRequirement
end

-- Checks to see whether the crafter is high enough level
-- with high enough quality level to craft this recipe
function CookeryWizRecipeEntry:CanCook(provisionerRank, provisionerQuality)
  if not provisionerRank then
    d("A valid provisioner rank must be passed")
    return false
  end
  if not provisionerQuality then
    d("A valid provisioner quality rank must be passed")
    return false
  end 
  --trace("provisionerRank:"..provisionerRank.."["..self:GetRecipeRank().."], Quality:"..provisionerQuality.."["..self:GetRecipeQualityRequirement().."]")
  if provisionerQuality < self:GetRecipeQualityRequirement() then
    --trace("Need a provisioner level["..self:GetRecipeRank().."], qualityLevel["..self:GetRecipeQualityRequirement().."]")
    return false
  end
  
  return true
end

function CookeryWizRecipeEntry:IsCookable(provisionerRank, provisionerQuality)
  if self:IsKnown() == false then
    return false
  end
  if not self:CanCook(provisionerRank, provisionerQuality) then
    return false
  end
  -- check on cookable quantity
  if self:CalculateCanCookQuantity() > 0 then
    return true
  else
    return false
  end  
end

function CookeryWizRecipeEntry:GetFoodResultLevel()
  if not self.foodLevel then
    self.foodLevel = GetItemLinkRequiredLevel(self:GetFoodResultLink())
  end
  return self.foodLevel
end

function CookeryWizRecipeEntry:GetFoodResultChampionRank()
  if not self.foodChampionRank then
    self.foodChampionRank = GetItemLinkRequiredChampionPoints(self:GetFoodResultLink())
  end
  return self.foodChampionRank
end


function CookeryWizRecipeEntry:GetFoodResultQuality()
  if not self.foodQuality then
    local link = self:GetFoodResultLink()
    self.foodQuality = GetItemLinkQuality(link)
  end
  return self.foodQuality
end

---------------------------------------------------------------------
-- Function: GetColouredFoodResultName
--
-- This function returns the coloured version of food name based on
-- quality
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetColouredFoodResultName()
  if not self.foodNameColoured then
    self.foodNameColoured = zo_strformat("<<t:1>>", self:GetFoodResultLink())    
  end
  return self.foodNameColoured

end

function CookeryWizRecipeEntry:GetFoodResultName()
  if not self.foodName then    
    self.foodName = zo_strformat("<<1>>", GetItemLinkName(self:GetFoodResultLink()):gsub("\160", " "))
  end
  return self.foodName
  --return zo_strformat("<<1>>", GetItemLinkName(self:GetFoodResultLink())))
end

function CookeryWizRecipeEntry:GetFoodResultNameColored()
  local quality =  GetItemLinkQuality(self.rid)
  local colorDef = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
  --if self:IsKnown() then
    --colorDef 
  --else
    --colorDef = self.mutedQualityColor[quality]
  --end
  local text = colorDef:Colorize(self:GetFoodResultName())  
  return text
end

function CookeryWizRecipeEntry:GetFoodResultNameLower()
  return self:GetFoodResultName():lower()
end



---------------------------------------------------------------------
-- Function: GetDataType
--
-- This function returns the scroll list template data type
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetDataType()
  return CW_RECIPE_DATA_TYPE
end

---------------------------------------------------------------------
-- Recipe scroll list specific Routines
---------------------------------------------------------------------

CookeryWizRecipeEntry.nameControl = nil
CookeryWizRecipeEntry.editAmountControl = nil
CookeryWizRecipeEntry.tickControl = nil
CookeryWizRecipeEntry.existingQuantityLabel = nil 
CookeryWizRecipeEntry.canCookQuantityLabel = nil 
CookeryWizRecipeEntry.bgControl = nil
  
CookeryWizRecipeEntry.cookEntry = nil

---------------------------------------------------------------------
-- Function: GetCookEntry
--
-- This function returns and existing cook entry associated with
-- the recipe
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetCookEntry()
  return self.cookEntry
end


---------------------------------------------------------------------
-- Function: OnMouseEnterExistingQuantityLabel
--
-- This function is called when the mouse is over the favourite icon
---------------------------------------------------------------------
function CookeryWizRecipeEntry:OnMouseEnterExistingQuantityLabel(control)
  --control:SetAlpha(1)
  ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_LABEL_TOOLTIP_RECIPES_EXISTING_QUANTITY])
end

---------------------------------------------------------------------
-- Function: OnMouseExitExistingQuantityLabel
--
-- This function is called when the mouse exits the favourite icon
---------------------------------------------------------------------
function CookeryWizRecipeEntry:OnMouseExitExistingQuantityLabel(control)
  --control:SetAlpha(0.4)
  ZO_Tooltips_HideTextTooltip()
end

---------------------------------------------------------------------
-- Function: GetIcon
--
-- This function returns the icon for the resulting food item
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetIcon()
  if not self.icon then
    local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(self:GetFoodResultLink())    
    self.icon = icon
  end
  return self.icon
end

---------------------------------------------------------------------
-- Function: SetCookEntry
--
-- This function sets a cook entry associated with
-- the recipe
---------------------------------------------------------------------
function CookeryWizRecipeEntry:SetCookEntry(cookEntry)
  self.cookEntry = cookEntry
  self:UpdateCookEntry()
end

function CookeryWizRecipeEntry:UpdateCookEntry()
  if self.editAmountControl then
    local text = self.editAmountControl:GetText()
    if not self.cookEntry or self.cookEntry.quantity == 0 then
      if text ~= "" then
        self.editAmountControl:SetText("")
      end
    else
      self.editAmountControl:SetText(self.cookEntry.quantity)
    end
  end
end

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizRecipeEntry:CalculateCanCookQuantity()

  -- It is quite possible we do not know the recipe
  local resultStack = 0 
  if self:IsKnown() then
    local recipeIndex = self:GetRecipeIndex()
    local _, icon, stack, sellPrice, quality = GetRecipeResultItemInfo(self:GetRecipeListIndex(), recipeIndex)
    --d("Result Stack for "..masterRecipeEntry:GetRecipeName().." - ["..stack.."]")
    resultStack = stack        
  else
    -- we should probably be able to work it out on whether they have the skill!
    -- but since they dont know it, set to 1 as they cannot craft it
    resultStack = 1
  end
  --trace("resultStack ["..resultStack.."]")
  
  local ingredients = self:GetIngredients()
  --local ingredientQuantity = 1
  local minStock = 1000000
  for ingredientIndex = 1, #ingredients do
    -- each object in array returned from GetIngredients() resembles the folowing:
    -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}  
    local ingredient = ingredients[ingredientIndex]
    local entry = ingredient.entry;
    
    local totalStock = math.floor( entry:GetStock() / ingredient.quantity) --+ ingredient:GetStolenStock()
    if minStock > totalStock then
      minStock = totalStock
    end
    
  end       
  local quantity = resultStack * minStock
  --trace("["..self:GetFoodResultName().."] - Can Cook ["..quantity.."], minStock["..minStock.."]")
  return quantity
end

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizRecipeEntry:SetRowControl(rowControl)
  self.rowControl = rowControl
  if rowControl then
    self.nameControl = rowControl:GetNamedChild("Name")
    self.editAmountControl = rowControl:GetNamedChild("EditAmount")
    self.tickControl = rowControl:GetNamedChild("Tick")
    self.existingQuantityLabel = rowControl:GetNamedChild("ExistingQuantityLabel")      
    self.bgControl = rowControl:GetNamedChild("Bg")
    self.canCookQuantityLabel = rowControl:GetNamedChild("CanCookQuantityLabel")
    self.cookEntry = CookeryWiz:GetCookEntry(self.id)
    self.favouriteButton = rowControl:GetNamedChild("Favourite")
    self.favouriteButton:SetAlpha(0.4)
    self.favouriteButton:SetHidden(true)
    -- recipe name will not change
    --local qualityColor = 
    
    local text = self:GetFoodResultNameColored()
    --local text = self:GetFoodResultLink()
    local iconText = zo_iconTextFormat(self:GetIcon(), 24, 24, text)
    --local iconAndNameControl = self.nameControl:GetNamedChild("IconAndName")
    
    self.nameControl:SetText(iconText)
    --iconAndNameControl:SetText("blah")
    --iconAndNameControl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    
    if CookeryWiz:IsKnownBySelectedCharacter(self.id) then
      self.nameControl:SetAlpha(1)
    else
      self.nameControl:SetAlpha(0.6)
    end
    self:UpdateRowControlData()
  else
    self.nameControl = nil
    self.editAmountControl = nil
    self.tickControl = nil
    self.existingQuantityLabel = nil      
    self.bgControl = nil
    self.canCookQuantityLabel = nil
    self.favouriteButton = nil
  end
end

function CookeryWizRecipeEntry:UpdateNameControl()
  
end

local displayTicks = false

---------------------------------------------------------------------
-- Function: SetDisplayTicksEnabled
--
-- This function sets whether ticks are enabled
---------------------------------------------------------------------
function CookeryWizRecipeEntry:SetDisplayTicksEnabled(enabled)
  displayTicks = enabled
end

local counter = 0
local FAVOURITE_ICON_ON = "CookeryWiz/Graphics/heart_off.dds"


function CookeryWizRecipeEntry:HandleOnMouseEnterRow(rowControl)
  CookeryWizRecipeList:ShowItemToolTip(rowControl, true)
  CookeryWiz:SetHighlight(rowControl, true) 

  local entry = rowControl.entry
  if not entry then
    return
  end

  entry.favouriteButton:SetHidden(false)

end

function CookeryWizRecipeEntry:HandleOnMouseExitRow(rowControl)
  CookeryWizRecipeList:ShowItemToolTip(rowControl, false)
  CookeryWiz:SetHighlight(rowControl, false)  
  local entry = rowControl.entry
  if not entry then
    return
  end
  
  if entry:IsFavourite() then
    entry.favouriteButton:SetHidden(false)
  else
    entry.favouriteButton:SetHidden(true)
  end
end


---------------------------------------------------------------------
-- Function: GetFavouriteIndex
--
-- This function returns the favourite icon index
-- An index of 0 means that it is not a favourite
---------------------------------------------------------------------
function CookeryWizRecipeEntry:GetFavouriteIndex()
  return self.favouriteIndex
end

---------------------------------------------------------------------
-- Function: SetFavouriteIndex
--
-- This function sets the favourite icon index
-- An index of 0 means that it is not a favourite
---------------------------------------------------------------------
function CookeryWizRecipeEntry:SetFavouriteIndex(favouriteIndex)
  self.favouriteIndex = favouriteIndex
  if self.rowControl then
    self:UpdateFavourite()
  end  
end

---------------------------------------------------------------------
-- Function: IsFavourite
--
-- This function returns the favourite state
---------------------------------------------------------------------
function CookeryWizRecipeEntry:IsFavourite()
  if self.favouriteIndex == 0 then
    return false
  else
    return true
  end
end

---------------------------------------------------------------------
-- Function: UpdateFavourite
--
-- This function updates the favourite icon
---------------------------------------------------------------------
function CookeryWizRecipeEntry:UpdateFavourite()
  if self.favouriteButton then
    if self.favouriteIndex ~= 0 then        
      self.favouriteButton:SetHidden(false)
    end
    local textureFile = "CookeryWiz/Graphics/fav".. self.favouriteIndex.. ".dds"
    self.favouriteButton:SetNormalTexture(textureFile) 
  end
end

---------------------------------------------------------------------
-- Function: UpdateRowControlData
--
-- This function updates the data in the row control associated with this object
---------------------------------------------------------------------
function CookeryWizRecipeEntry:UpdateRowControlData()
  if self.rowControl then
    if displayTicks then
      if CookeryWiz:IsKnownBySelectedCharacter(self.id) then
        self.tickControl:SetHidden(false)
      else
        self.tickControl:SetHidden(true)
      end
    else
      self.tickControl:SetHidden(true)
    end
    -- set the color
    if self:CanCook(CookeryWiz:GetProvisionerRecipeImprovement(), CookeryWiz:GetProvisionerRecipeQuality()) then
      self.editAmountControl:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
    else
      self.editAmountControl:SetColor(ZO_ERROR_COLOR:UnpackRGBA())
    end    

    -- How many existing are there?
    local stackCountBackpack, stackCountBank = GetItemLinkStacks(self:GetFoodResultLink())

    local total = stackCountBackpack + stackCountBank
    --trace("Total - "..total)
    if total == 0 then
      self.existingQuantityLabel:SetHidden(true)
    else
      self.existingQuantityLabel:SetText(total)
      self.existingQuantityLabel:SetHidden(false)
    end
    --self.existingQuantityLabel:SetText(total)
    
    local canCook = self:CalculateCanCookQuantity()
    --canCook = 1
    if canCook == 0 then
      self.canCookQuantityLabel:SetHidden(true)
    else
      self.canCookQuantityLabel:SetHidden(false)
      self.canCookQuantityLabel:SetText(canCook)      
    end

    
    self:UpdateFavourite()
    
    self:UpdateCookEntry()
  end
end