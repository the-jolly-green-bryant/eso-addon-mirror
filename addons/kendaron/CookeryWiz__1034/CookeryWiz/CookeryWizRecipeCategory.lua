
local L = CookeryWizLanguage.language

-- retain a list of categories created.
-- It will make it quicker to parse for missing recipes
local categories = {}
local unknownRecipes = {}

local callbackRecipeKey = "unknown"

CookeryWizRecipeCategory = {}
CookeryWizRecipeCategory.traceEnabled = false

local function trace(msg)
    if CookeryWizRecipeCategory.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end

---------------------------------------------------------------------
-- Function: new
--
-- This function is called to construct a new category object
---------------------------------------------------------------------
function CookeryWizRecipeCategory:new() 
  local o = {}
 
  return self:set(o)  
end

function CookeryWizRecipeCategory:set(o) 
  setmetatable(o, self)
  self.__index = self
  
  -- Add this to the list of categories
  categories[#categories + 1] = o
  
  return o  
end

CookeryWizRecipeCategory.name = nil
CookeryWizRecipeCategory.recipeCountGame = nil

CookeryWizRecipeCategory.category = nil
CookeryWizRecipeCategory.isCollapsed = false
CookeryWizRecipeCategory.callback = nil

---------------------------------------------------------------------
-- Function: Initialise
--
-- This function is called to initialise the category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:Initialise(listIndex, callback, startIndex)
  local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(listIndex)
  self.category = listIndex
  self.name = name
  self.recipeCountGame = numRecipes
  self.callback = callback
  self.startIndex = startIndex
  self.icon = upIcon
  self.isCollapsed = CookeryWiz:IsCollapsed(listIndex) 
  
  -- Create a new array for recipes that are part of this category. We can parse it later to see what is missing
  if not self.recipes then
    self.recipes = {}
  end
  
end


---------------------------------------------------------------------
-- Function: GetName
--
-- This function returns the name of the category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetName()
  return self.name
end

---------------------------------------------------------------------
-- Function: Recipes
--
-- This function returns the recipes array belonging to this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:Recipes()
  return self.recipes
end

---------------------------------------------------------------------
-- Function: AddRecipeEntry
--
-- This function returns adds a recipe to this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:AddRecipeEntry(entry)
  self.recipes[#self.recipes + 1] = entry
  entry:SetRelativeIndex(#self.recipes)
end

---------------------------------------------------------------------
-- Function: GetIcon
--
-- This function returns the icon of the category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetIcon()
  return self.icon
end

---------------------------------------------------------------------
-- Function: GetCategory
--
-- This function returns the category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetCategory()
  return self.category
end

---------------------------------------------------------------------
-- Function: GetRecipeCount
--
-- This function returns the recipe count for this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetRecipeCount()
  return #self.recipes
end

---------------------------------------------------------------------
-- Function: GetRecipe
--
-- This function returns a recipe for this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetRecipe(index)
  return self.recipes[index]
end

---------------------------------------------------------------------
-- Function: GetRecipeCountGame
--
-- This function returns the recipe count for this category list
-- as reported by the game
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetRecipeCountGame()
  return self.recipeCountGame
end



---------------------------------------------------------------------
-- Function: GetCallback
--
-- This function returns the callback object for this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetCallback()
  return self.callback
end

---------------------------------------------------------------------
-- Function: SetCallback
--
-- This function sets the callback object for this category
---------------------------------------------------------------------
function CookeryWizRecipeCategory:SetCallback(callback)
  self.callback = callback
end

---------------------------------------------------------------------
-- Function: GetRecipeStartIndex
--
-- This function returns the start index of the first recipe
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetRecipeStartIndex()
  return self.startIndex
end

---------------------------------------------------------------------
-- Function: GetRecipeEndIndex
--
-- This function returns the end index of the first recipe
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetRecipeEndIndex()
  return self.endIndex
end

---------------------------------------------------------------------
-- Function: SetRecipeEndIndex
--
-- This function sets the end index of the first recipe
---------------------------------------------------------------------
function CookeryWizRecipeCategory:SetRecipeEndIndex(endIndex)
  self.endIndex = endIndex
end

---------------------------------------------------------------------
-- Function: IsCollapsed
--
-- This function returns whether the category is collapsed
---------------------------------------------------------------------
function CookeryWizRecipeCategory:IsCollapsed()
  return self.isCollapsed
end

---------------------------------------------------------------------
-- Function: SetIsCollapsed
--
-- This function sets whether the category is collapsed
---------------------------------------------------------------------
function CookeryWizRecipeCategory:SetIsCollapsed(isCollapsed)
  if self.isCollapsed == isCollapsed then
    return
  end
 
  self.isCollapsed = isCollapsed
  self:UpdateExpandControl()
end

---------------------------------------------------------------------
-- Function: UpdateExpandControl
--
-- This function updates the gui to reflect the value
---------------------------------------------------------------------
function CookeryWizRecipeCategory:UpdateExpandControl()
  trace("UpdateExpandControl["..self:GetName().."]")
  if self.expandButtonControl and self.collapseButtonControl then
    if self.isCollapsed then
      self.currentExpandControl = self.expandButtonControl
      self.expandButtonControl:SetHidden(false)
      self.collapseButtonControl:SetHidden(true)
    else
      self.currentExpandControl = self.collapseButtonControl
      self.expandButtonControl:SetHidden(true)
      self.collapseButtonControl:SetHidden(false)        
    end 
  end
end

---------------------------------------------------------------------
-- Function: GetDataType
--
-- This function returns the scroll list template data type
---------------------------------------------------------------------
function CookeryWizRecipeCategory:GetDataType()
  return CW_RECIPE_CATEGORY_DATA_TYPE
end

---------------------------------------------------------------------
-- Recipe scroll list specific Routines
---------------------------------------------------------------------

CookeryWizRecipeCategory.nameControl = nil
CookeryWizRecipeCategory.expandButtonControl = nil
CookeryWizRecipeCategory.collapseButtonControl = nil
CookeryWizRecipeCategory.bgControl = nil
CookeryWizRecipeCategory.currentExpandControl = nil

---------------------------------------------------------------------
-- Function: SetRowControl
--
-- This function sets the row control associated with this object
---------------------------------------------------------------------
function CookeryWizRecipeCategory:SetRowControl(rowControl)
  self.rowControl = rowControl
  if rowControl then
    self.nameControl = rowControl:GetNamedChild("Name")
    self.expandButtonControl = rowControl:GetNamedChild("ExpandButton")
    self.collapseButtonControl = rowControl:GetNamedChild("CollapseButton")     
    self.bgControl = rowControl:GetNamedChild("Bg")

    -- recipe category name will not change
    local iconText = zo_iconTextFormat(self:GetIcon(), 24, 24, self.name)
    self.nameControl:SetText(iconText)    
    --self.nameControl:SetText(self.name)
    
    self:UpdateRowControlData()
  else
    self.nameControl = nil
    self.expandButtonControl = nil
    self.collapseButtonControl = nil
    self.bgControl = nil
  end
end

---------------------------------------------------------------------
-- Function: UpdateRowControlData
--
-- This function updates the data in the row control associated with this object
---------------------------------------------------------------------
function CookeryWizRecipeCategory:UpdateRowControlData()
  if self.rowControl then
    self:UpdateExpandControl()
  else
    d("No rowcontrol")
  end
end