--[[

Total time to process from 45000 to 120770 is about 100 seconds on my computer

--]]


local function trace(msg)
  if CookeryWizPopulateRecipeIndexes.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

CookeryWizPopulateRecipeIndexes = CookeryWizUtils:class(CookeryWizAsync, function(c)
         CookeryWizAsync.init(c,"CookeryWizPopulateRecipeIndexes")
         c.startIndex = 1
      end)
    

function CookeryWizPopulateRecipeIndexes:Trace(msg)
  trace(msg)
end

-- The index of the cookerywiz category we are processing
CookeryWizPopulateRecipeIndexes.currentCategoryIndex = 0

-- The cookerywiz recipe category object
CookeryWizPopulateRecipeIndexes.currentCategory = nil

-- The number of recipes contained within the current cookery wiz category
CookeryWizPopulateRecipeIndexes.currentCategoryRecipeCount = 0
  
-- The index of the recipe we are currently processing
CookeryWizPopulateRecipeIndexes.currentRecipeIndex = 0  

-- The count of how many we were able to resolve
CookeryWizPopulateRecipeIndexes.recipesResolved = 0 

-- The count of how many recipes have no index
CookeryWizPopulateRecipeIndexes.recipesNoIndex = 0 

---------------------------------------------------------------------
-- Function: OnAsyncStart
--
-- This function is called at the start of the task. Initialisation
-- should be performed here.
---------------------------------------------------------------------
function CookeryWizPopulateRecipeIndexes:OnAsyncStart(index)
  self.currentCategoryIndex = 0
  self.recipesResolved = 0 
  self.recipesNoIndex = 0
  self:NextCategory()
end

---------------------------------------------------------------------
-- Function: NextCategory
--
-- This function sets up the next category and recipes variables
---------------------------------------------------------------------
function CookeryWizPopulateRecipeIndexes:NextCategory()
  self.currentCategoryIndex = self.currentCategoryIndex + 1
  self.currentCategory = CookeryWizRecipeList:GetCookeryWizRecipeCategory(self.currentCategoryIndex)
  if self.currentCategory then
    self.currentCategoryRecipeCount = #self.currentCategory.recipes
  end
  self.currentRecipeIndex = 1  
end

---------------------------------------------------------------------
-- Function: OnAsyncLoop
--
-- This function is the main loop for the task. Use Cancel to stop 
---------------------------------------------------------------------
function CookeryWizPopulateRecipeIndexes:OnAsyncLoop(index)  
  
  -- is it time to get the next category?
  if self.currentRecipeIndex > self.currentCategoryRecipeCount then
    self:NextCategory()
    if self.currentCategory == nil then
      self:Cancel()
      return
    end
  end
  
  local masterEntry = self.currentCategory.recipes[self.currentRecipeIndex]
  if masterEntry then
    
    --trace("["..index.."]- "..masterEntry:GetRecipeName()..".")
    masterEntry:SetRelativeIndex(self.currentRecipeIndex)
    local recipeIndex = masterEntry:GetRecipeIndex()
    if recipeIndex == nil then
      self.recipesNoIndex = self.recipesNoIndex + 1
    end
    masterEntry:PopulateRecipeIndex(self.currentCategoryRecipeCount)
    if recipeIndex == nil and masterEntry:GetRecipeIndex() ~= nil then
      self.recipesResolved = self.recipesResolved + 1
      trace("["..index.."] - resolved "..masterEntry:GetRecipeName()..".")
    end
  end
  
  self.currentRecipeIndex = self.currentRecipeIndex + 1
end

---------------------------------------------------------------------
-- Function: OnAsyncEnd
--
-- This function is called when cancelled or finished
---------------------------------------------------------------------
function CookeryWizPopulateRecipeIndexes:OnAsyncEnd(index)
  trace("- finished populating recipe indexes.")
  trace("- total recipes with no index ["..self.recipesNoIndex.."]")
  trace("- total recipes indexes resolved ["..self.recipesResolved.."]")
end


