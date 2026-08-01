--[[

NOTE:
- 21-May-2017: total recipes: 560, last valid recipe [Jewels of Misrule] with id of [120770]

This will process recipes and find all the ingredients used by the recipes

-- Start by creating an object of this type and passing the recipe info
-- It can be existing recipes or just those found via CookeryWizMissingRecipes

local i = CookeryWizMissingIngredients(CookeryWizRecipeList:GetRecipeData())

-- There is a fail safe built in which will stop processing after a nominated amount of time. This defaults to 5 minutes

-- Enable extra debug output to show ingredient found and other status information
i.traceEnabled = true

-- Show how long it takes to process
i.showMetrics = true

-- You can speed it up by setting the max number of iteration per timer event. 100 is default
-- If set too hight it can lock up you game so use cautiously!
i:SetMaxLoopCounter(200)

-- To save the results to the saved variables file, call Save to set a variable name prior to begin
i:Save("MissingIngredients")

i:Begin()

-- 

Total time to process recipes and find ingredient is less than a second

--]]

local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

local function trace(msg)
  if CookeryWizMissingIngredients.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

CookeryWizMissingIngredients = CookeryWizUtils:class(CookeryWizAsync, function(c, recipeInfo)
         CookeryWizAsync.init(c,"CookeryWizMissingIngredients") 
         
        c.recipeInfo = recipeInfo
      end)
    

function CookeryWizMissingIngredients:Trace(msg)
  trace(msg)
end

-- The recipe info that has been obtained from MissingRecipes
CookeryWizMissingIngredients.recipeInfo = nil

-- recipes to scan found
CookeryWizMissingRecipes.recipeCount = 0

-- ingredients found
CookeryWizMissingRecipes.ingredientCount = 0

-- The ingredient info that has been obtained from recipeinfo
CookeryWizMissingIngredients.ingredientInfo = nil

-- The index of the cookerywiz category we are processing
CookeryWizMissingIngredients.currentCategoryIndex = 0

-- The cookerywiz recipe category object
CookeryWizMissingIngredients.currentCategory = nil

-- The number of recipes contained within the current cookery wiz category
CookeryWizMissingIngredients.currentCategoryRecipeCount = 0
  
-- The index of the recipe we are currently processing
CookeryWizMissingIngredients.currentRecipeIndex = 0 

-- The array of ingredient names we have already found
CookeryWizMissingIngredients.ingredientNames = nil 

-- The highest id of the ingredients found
CookeryWizMissingIngredients.lastIngredientId = 0

CookeryWizMissingIngredients.traceEnabled = false

---------------------------------------------------------------------
-- Function: OnAsyncStart
--
-- This function is called at the start of the task. Initialisation
-- should be performed here.
---------------------------------------------------------------------
function CookeryWizMissingIngredients:OnAsyncStart(index)
  self.recipeCount = self.recipeInfo.recipeCount
  self.ingredientCount = 0
  self.lastIngredientId = 0
  self.ingredientInfo = {
      lastIndex = 0,
      ingredientCount = 0,
      ingredients = {}    
  }
  self.ingredientNames = {}
  self.currentCategoryIndex = 0
  self:NextCategory()
  
  trace("Total recipes to scan "..self.recipeCount)
end

---------------------------------------------------------------------
-- Function: AddIngredient
--
-- This function adds an ingredient to our table of used ingredients
---------------------------------------------------------------------
function CookeryWizMissingIngredients:AddIngredient(id)
  -- find the category object
  local ingredients = self.ingredientInfo.ingredients
  ingredients[#ingredients + 1] = {
      id = id
    }  
end

---------------------------------------------------------------------
-- Function: GetIngredients
--
-- This function returns discovered ingredients
---------------------------------------------------------------------
function CookeryWizMissingIngredients:GetIngredients()
  return self.ingredientInfo.ingredients
end

---------------------------------------------------------------------
-- Function: GetIngredientInfo
--
-- This function returns discovered ingredients wrapped in the info object
---------------------------------------------------------------------
function CookeryWizMissingIngredients:GetIngredientData()
  return self.ingredientInfo
end

---------------------------------------------------------------------
-- Function: GetIngredientCount
--
-- This function returns count of discovered ingredients
---------------------------------------------------------------------
function CookeryWizMissingIngredients:GetIngredientCount()
  return self.ingredientInfo.ingredientCount
end

---------------------------------------------------------------------
-- Function: NextCategory
--
-- This function sets up the next category and recipes variables
---------------------------------------------------------------------
function CookeryWizMissingIngredients:NextCategory()
  self.currentCategoryIndex = self.currentCategoryIndex + 1
  self.currentCategory = self.recipeInfo.cats[self.currentCategoryIndex]
  if self.currentCategory then
    self.currentCategoryRecipeCount = #self.currentCategory.recipes
  end
  self.currentRecipeIndex = 1  
end

---------------------------------------------------------------------
-- Function: OnAsyncLoop
--
-- This function is the main loop for the task
-- Use Cancel to stop
---------------------------------------------------------------------
function CookeryWizMissingIngredients:OnAsyncLoop(index)  
  local i
  
  -- is it time to get the next category?
  if self.currentRecipeIndex > self.currentCategoryRecipeCount then
    self:NextCategory()
    if self.currentCategory == nil then
      self:Cancel()
      return
    end
  end
  
  local recipe = self.currentCategory.recipes[self.currentRecipeIndex]
  if recipe then
    -- we need to construct a fake recipe link. The game can tell us if this link
    -- is a recipe or not
    local testLink = string.format(testLinkFormat, recipe.id)
  
    -- get ingredients of the recipe
    local total = GetItemLinkRecipeNumIngredients(testLink)  
    --trace("id["..recipe.id.."] - "..testLink..", total - "..total)
    for ingredientIndex = 1, total do
      local name, stockedAmount = GetItemLinkRecipeIngredientInfo(testLink, ingredientIndex)
      if self.ingredientNames[name] == nil then
        local ingredientLink = GetItemLinkRecipeIngredientItemLink(testLink, ingredientIndex)
        local id = CookeryWizUtils:GetItemID(ingredientLink)
        
        if id > self.lastIngredientId then
          self.lastIngredientId = id
        end
    
        self.ingredientNames[name] = stockedAmount
        self:AddIngredient(id)
        
        trace(#self.ingredientInfo.ingredients..":Id["..id.."] - "..ingredientLink)        
      end
    end     

  end
  
  self.currentRecipeIndex = self.currentRecipeIndex + 1
  
end

---------------------------------------------------------------------
-- Function: OnAsyncEnd
--
-- This function is called when cancelled or finished
---------------------------------------------------------------------
function CookeryWizMissingIngredients:OnAsyncEnd(index)
  trace("- finished looking for missing ingredients.")
  trace("- total recipes to scan ["..self.recipeCount.."]")
  trace("- found ["..#self.ingredientInfo.ingredients.."] ingredients")
  trace("- last id of ingredient ["..self.lastIngredientId.."]")
  
  self.ingredientInfo.lastIndex = self.lastIngredientId
  self.ingredientInfo.ingredientCount = #self.ingredientInfo.ingredients
  
  if self.settingName then

    trace("Saving ingredient info to '"..self.settingName.."'")
    local savedVars = CookeryWiz:GetSavedVars()
    savedVars[self.settingName] = self.ingredientInfo

  end
end


---------------------------------------------------------------------
-- Function: Save
--
-- This function will flag whether we should save results to the
-- saved variable file at the end of the process
---------------------------------------------------------------------
function CookeryWizMissingIngredients:Save(settingName)
  self.settingName = settingName
end



