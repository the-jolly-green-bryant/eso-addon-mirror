--[[

This startup object is meant to run when game starts. To prevent CookeryWiz hogging
the cpu when it is doing intensive processing it uses an asyn type approach

ie will make use of many async classes which continually schedules processing after
a small timeout

]]--

local L = CookeryWizLanguage.language

CookeryWizStartup = CookeryWizUtils:class(function(a)
   a.name = "CookeryWizStartup"
end)

CookeryWizStartup.traceEnabled = true

-- async class which scans for missing recipes
CookeryWizStartup.missingRecipes = nil

-- async class which fixes up recipe indexes 
CookeryWizStartup.populateRecipeIndexes = nil

-- max loop counter
CookeryWizStartup.maxLoopCounter = CookeryWizAsync:GetMaxLoopCounter()

local function trace(msg)
  if CookeryWizStartup.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

function CookeryWizStartup:Trace(msg)
  trace(msg)
end

---------------------------------------------------------------------
-- Function: Begin
--
-- This function is called to start the processing. 
---------------------------------------------------------------------
function CookeryWizStartup:Begin()
  -- we want to begin scanning for missing recipes
  
  local timeout = 300 * 1000
  local showMetrics = self.showMetrics
  
  -- what is the last id we looked for? And how many recipes did we find?
  local lastId = CookeryWizRecipeList:GetLastIndex() + 1
  -- how many are there?
  local currentCount = CookeryWizRecipeList:GetEmbeddedCount()
  
  CookeryWizMissingRecipes.traceEnabled = self.traceEnabled
  
  local missingRecipes = CookeryWizMissingRecipes(lastId, currentCount)
  missingRecipes.timeout = timeout
  missingRecipes:SetMaxLoopCounter(self.maxLoopCounter)
  missingRecipes.showMetrics = showMetrics
  missingRecipes.OnFinished = function()
    local recipeData = missingRecipes:GetRecipeData()
    local recipeCount = recipeData.recipeCount
    
    trace("MissingRecipes finished! "..recipeCount.." recipes found")
    
    -- if we found recipes not in the list, insert them into the master list
    -- TODO
    local changed = false
    
    for catIndex = 1, #recipeData.cats do
      local catAppend = recipeData.cats[catIndex]
      local catMaster = CookeryWizRecipeList:GetCookeryWizRecipeCategory(catIndex)
      
      local appendCount = #catAppend.recipes
      if appendCount > 0 then
        if not changed then
          changed = true
        end
        trace(catIndex..": Need to append "..appendCount.." recipes")
        trace(catIndex..": Recipe count before "..catMaster:GetRecipeCount())
        for recipeIndex = 1, appendCount do
          local recipe = catAppend.recipes[recipeIndex]
          local entry = CookeryWizRecipeList:AppendMasterList(recipe, catIndex, true)
          catMaster:AddRecipeEntry(entry)
        end
        trace(catIndex..": Recipe count after "..catMaster:GetRecipeCount())
      end
    end    

    -- force the recipe list to update count?
    if changed then
      CookeryWizRecipeList:RecalculateRecipeCount()
    end
      
    -- find missing ingredients
    CookeryWizMissingIngredients.traceEnabled = self.traceEnabled
    local missingIngredients = CookeryWizMissingIngredients(recipeData)
    missingIngredients.timeout = timeout
    missingIngredients:SetMaxLoopCounter(self.maxLoopCounter)
    missingIngredients.showMetrics = showMetrics
    missingIngredients.OnFinished = function()
      
      -- insert these ingredients into master list
      local ingredientData = missingIngredients:GetIngredientData()
      local ingredientCount = ingredientData.ingredientCount
      trace("MissingIngredients finished! "..ingredientCount.." ingredients found")
      
      trace("Ingredient count before "..CookeryWizIngredients:GetCount())
      for i = 1, ingredientCount do
        local ingredient = ingredientData.ingredients[i]
        local entry = CookeryWizIngredients:AppendMasterList(ingredient.id, true)
      end
      trace("Ingredient count after "..CookeryWizIngredients:GetCount())
      
      -- TODO
      
      -- start the processing of the master recipe list to find indexes
      CookeryWizPopulateRecipeIndexes.traceEnabled = self.traceEnabled
      local populateRecipeIndexes = CookeryWizPopulateRecipeIndexes()
      populateRecipeIndexes.timeout = timeout
      populateRecipeIndexes:SetMaxLoopCounter(self.maxLoopCounter)
      populateRecipeIndexes.showMetrics = showMetrics 
      populateRecipeIndexes:Begin()
      populateRecipeIndexes.OnFinished = function()
        trace("PopulateRecipeIndexes finished!")
        trace("- total recipes with no index ["..populateRecipeIndexes.recipesNoIndex.."]")
        trace("- total recipes indexes resolved ["..populateRecipeIndexes.recipesResolved.."]")
      end
      
    end
    missingIngredients:Begin()
  end

  missingRecipes:Begin()
  --self.missingRecipes = missingRecipes
end

---------------------------------------------------------------------
-- Function: GetMaxLoopCounter
--
-- This function gets the maximum loop amount per timeslice
---------------------------------------------------------------------
function CookeryWizStartup:GetMaxLoopCounter()
  return self.maxLoopCounter
end

---------------------------------------------------------------------
-- Function: SetMaxLoopCounter
--
-- This function sets the maximum loop amount per timeslice
---------------------------------------------------------------------
function CookeryWizStartup:SetMaxLoopCounter(max)
  self.maxLoopCounter = max
end