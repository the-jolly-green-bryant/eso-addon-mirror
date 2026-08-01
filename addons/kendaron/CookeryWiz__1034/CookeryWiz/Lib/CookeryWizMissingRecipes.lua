--[[

NOTE:
- 21-May-2017: total recipes: 560, last valid recipe [Jewels of Misrule] with id of [120770]


-- To process all possible recipes, pass no parameters. It will start from 45000 and
-- keep going until it has discovered the total number of recipes as reported by the game

a = CookeryWizMissingRecipes()

-- You can start from a specific id, but if you do so then you MUST pass the number of recipes
-- to find. Getting this wrong can keep it going way beyond what it should. There is a fail safe
-- built in which will stop processing after a nominated amount of time. This defaults to 5 minutes

-- Enable extra debug output to show recipes found and other status information
a:SetTraceEnabled(true)

-- Show how long it takes to process
a.showMetrics = true

-- You can speed it up by setting the max number of iteration per timer event. 100 is default
-- If set too hight it can lock up you game so use cautiously!
a:SetMaxLoopCounter(200)

-- If you do not want it to exceed a max id, set it as below
-- NOTE: 96968 was the last max recipe prior to morrowwind
a:SetMaxId(96968)

-- To save the results to the saved variables file call Save to set a variable name prior to begin
a:Save("MissingRecipes")

a:Begin()

-- 
a = CookeryWizMissingRecipes(86000,97000)

As it processes recipes it will create an array of recipe list object objects. These are similar to
those that are included in CookeryWizRecipeList

It takes the format of

{
  ["lastIndex"] = XXX,
  ["recipeCount"] = YYYY,
  ["cats"] = {
    [<recipeList>] = {
      ["recipes"] = {
        [<normal array index>] = {
            ["index"] = <index of recipe in recipe list>,
            ["id"] = <id of recipe>,
        }
    }
  }
}

If you are processing all recipes you will be able to replace the recipe list array in CookeryWizRecipeList.lua with the data

ie
recipeData = {
...
}


Total time to process from 45000 to 120770 is about 100 seconds on my computer

--]]

local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

local totalGameRecipes = CookeryWizUtils:GetTotalRecipes()  

local dupes = {}

local function trace(msg)
  if CookeryWizMissingRecipes.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

local SPELUNK_RECIPE_LIST_INDEX_UNKNOWN = nil

local SPELUNK_CAT_UNKNOWN = 0
local SPELUNK_CAT_MEAT_DISH = 1
local SPELUNK_CAT_FRUIT_DISH = 2
local SPELUNK_CAT_VEGETABLE_DISH = 3
local SPELUNK_CAT_SAVOURIES_DISH = 4
local SPELUNK_CAT_RAGOUT = 5
local SPELUNK_CAT_ENTREMENT = 6
local SPELUNK_CAT_GOURMET = 7
local SPELUNK_CAT_ALCOHOLIC_DRINK = 8
local SPELUNK_CAT_TEA = 9
local SPELUNK_CAT_TONIC = 10
local SPELUNK_CAT_LIQUEUR = 11
local SPELUNK_CAT_TINCTURE = 12
local SPELUNK_CAT_CORDIAL_TEA = 13
local SPELUNK_CAT_DISTILLATE = 14
local SPELUNK_CAT_DELICACIES_DRINK = 15
local SPELUNK_CAT_DELICACIES_FOOD = 16
local SPELUNK_LAST_FOOD_CAT = SPELUNK_CAT_DELICACIES_FOOD

local foodLists = {
  SPECIALIZED_ITEMTYPE_FOOD_MEAT,
  SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
  SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
  SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
  SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,  
  SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,  
  SPECIALIZED_ITEMTYPE_FOOD_GOURMET,  
  SPECIALIZED_ITEMTYPE_FOOD_UNIQUE
}

local drinkLists = {
  SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
  SPECIALIZED_ITEMTYPE_DRINK_TEA,
  SPECIALIZED_ITEMTYPE_DRINK_TONIC,
  SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
  SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
  SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
  SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
  SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
}

local listMap = {}

listMap[SPECIALIZED_ITEMTYPE_FOOD_MEAT] = SPELUNK_CAT_MEAT_DISH
listMap[SPECIALIZED_ITEMTYPE_FOOD_FRUIT] = SPELUNK_CAT_FRUIT_DISH
listMap[SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE] = SPELUNK_CAT_VEGETABLE_DISH
listMap[SPECIALIZED_ITEMTYPE_FOOD_SAVOURY] = SPELUNK_CAT_SAVOURIES_DISH
listMap[SPECIALIZED_ITEMTYPE_FOOD_RAGOUT] = SPELUNK_CAT_RAGOUT
listMap[SPECIALIZED_ITEMTYPE_FOOD_ENTREMET] = SPELUNK_CAT_ENTREMENT
listMap[SPECIALIZED_ITEMTYPE_FOOD_GOURMET] = SPELUNK_CAT_GOURMET
listMap[SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC] = SPELUNK_CAT_ALCOHOLIC_DRINK
listMap[SPECIALIZED_ITEMTYPE_DRINK_TEA] = SPELUNK_CAT_TEA
listMap[SPECIALIZED_ITEMTYPE_DRINK_TONIC] = SPELUNK_CAT_TONIC
listMap[SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR] = SPELUNK_CAT_LIQUEUR
listMap[SPECIALIZED_ITEMTYPE_DRINK_TINCTURE] = SPELUNK_CAT_TINCTURE
listMap[SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA] = SPELUNK_CAT_CORDIAL_TEA
listMap[SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE] = SPELUNK_CAT_DISTILLATE
listMap[SPECIALIZED_ITEMTYPE_DRINK_UNIQUE] = SPELUNK_CAT_DELICACIES_DRINK
listMap[SPECIALIZED_ITEMTYPE_FOOD_UNIQUE] = SPELUNK_CAT_DELICACIES_FOOD

CookeryWizMissingRecipes = CookeryWizUtils:class(CookeryWizAsync, function(c, startIndex, recipeCount)
         CookeryWizAsync.init(c,"CookeryWizMissingRecipes") 
         
        -- do we want to dynamically adjust range?
        if (startIndex == nil and recipeCount == nil) then
          c.dynamicRange = true
          c.startIndex = 45000
          c.startRecipeCount = 0
        else
          c.dynamicRange = false
          c.startIndex = startIndex
          c.startRecipeCount = recipeCount       
        end
         
        --c.endIndex = c.startIndex + 1        
        trace("startId["..c.startIndex.."], startCount["..c.startRecipeCount.."]")
      end)
    

function CookeryWizMissingRecipes:Trace(msg)
  trace(msg)
end


-- recipes found
CookeryWizMissingRecipes.recipeCount = 0

-- starting recipe count
CookeryWizMissingRecipes.startRecipeCount = 0

-- number of found recipes that are unknown by the logged in character
CookeryWizMissingRecipes.recipeUnknownCount = 0

-- number of recipes we could not resolve the in game recipe list from
CookeryWizMissingRecipes.recipeUnresolvedCount = 0

-- last in game recipe id that was found
CookeryWizMissingRecipes.lastRecipeId = 0

-- Whether we should generate a master list compatible with CookeryWizRecipeList
CookeryWizMissingRecipes.generateMaster = false

-- The name of the setting to save in the savedvariables file. nil = do not save
CookeryWizMissingRecipes.settingName = nil

-- Object which has array of recipes that we have discovered plus summary data
CookeryWizMissingRecipes.recipeInfo = nil

-- Do we want to limit to a max id?
CookeryWizMissingRecipes.maxId = nil

CookeryWizMissingRecipes.traceEnabled = false

---------------------------------------------------------------------
-- Function: SetTraceEnabled
--
-- This function will enable tracing
---------------------------------------------------------------------
function CookeryWizMissingRecipes:SetTraceEnabled(trace)
  CookeryWizMissingRecipes.traceEnabled = trace
end


---------------------------------------------------------------------
-- Function: OnAsyncStart
--
-- This function is called at the start of the task. Initialisation
-- should be performed here.
---------------------------------------------------------------------
function CookeryWizMissingRecipes:OnAsyncStart(index)
  dupes = {}
  
  self.recipeCount = self.startRecipeCount
  self.recipeUnresolvedCount = 0
  self.recipeUnknownCount = 0
  --self.cookeryWizRecipeCount = CookeryWizRecipeList:GetCount()
  self.recipeInfo = {
      lastIndex = 0,
      recipeCount = 0,
      cats = {}
    }
  --self.recipes = {}
  for i = 1, SPELUNK_LAST_FOOD_CAT do
    self.recipeInfo.cats[i] = { recipes = {}}
  end
  trace("Total game recipes "..totalGameRecipes)
  --totalGameRecipes = 10
  --totalGameRecipes = totalGameRecipes
end

---------------------------------------------------------------------
-- Function: AddRecipe
--
-- This function adds a recipe to our table of discovered recipes
---------------------------------------------------------------------
function CookeryWizMissingRecipes:AddRecipe(recipeList, id, recipeListIndex, foodName)
  -- find the category object
  local cat = self.recipeInfo.cats[recipeList]
  cat.recipes[#cat.recipes + 1] = {
      index = recipeListIndex,
      id = id,
      name = foodName
    }  

end

---------------------------------------------------------------------
-- Function: GetRecipes
--
-- This function returns discovered recipes
---------------------------------------------------------------------
function CookeryWizMissingRecipes:GetRecipes()
  return self.recipeInfo.cats
end

---------------------------------------------------------------------
-- Function: GetRecipeData
--
-- This function returns discovered recipes wrapped in the info object
---------------------------------------------------------------------
function CookeryWizMissingRecipes:GetRecipeData()
  return self.recipeInfo
end

---------------------------------------------------------------------
-- Function: OnAsyncLoop
--
-- This function is the main loop for the task
-- Use Cancel to stop
---------------------------------------------------------------------
function CookeryWizMissingRecipes:OnAsyncLoop(index)  
  local i
    --d("CookeryWizMissingRecipes:OnAsyncLoop")
  -- we need to construct a fake recipe link. The game can tell us if this link
  -- is a recipe or not
  local testLink = string.format(testLinkFormat, index)
 
  -- what does the game think this link type is? 
  local itemType, specializedItemType = GetItemLinkItemType(testLink)
  
  -- if it is a recipe AND is of food type
  if itemType == ITEMTYPE_RECIPE and ( specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD ) then
    
    local foodLink = GetItemLinkRecipeResultItemLink(testLink)
    local foodId = CookeryWizUtils:GetItemID(foodLink)
    
    --trace(self.recipeCount..":Id["..index.."] - "..foodLink.." ["..recipeList..","..text.."]")
    
    local foodType, specializedFoodType = GetItemLinkItemType(foodLink)        
    
    -- find the in game recipe list this belongs to
    local recipeList = SPELUNK_CAT_UNKNOWN
    if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK then
      recipeList = self:ResolveDrinkList(specializedFoodType)
    else
      recipeList = self:ResolveFoodList(specializedFoodType)
    end 
    
    if recipeList == SPELUNK_CAT_UNKNOWN then
      self.recipeUnresolvedCount = self.recipeUnresolvedCount + 1    
    end
    
    -- If we know this recipe then we can get the index of the in-game recipe list
    local recipeListIndex = SPELUNK_RECIPE_LIST_INDEX_UNKNOWN
    if IsItemLinkRecipeKnown(testLink) then
      recipeListIndex = self:ResolveRecipeListIndex(recipeList, foodLink)
    end
    
    if recipeListIndex == SPELUNK_RECIPE_LIST_INDEX_UNKNOWN then
      self.recipeUnknownCount = self.recipeUnknownCount + 1
      trace(self.recipeCount..":Id["..index.."] - "..foodLink.." ["..recipeList.."], [?]")
    else      
      trace(self.recipeCount..":Id["..index.."] - "..foodLink.." ["..recipeList.."], ["..recipeListIndex.."]")
    end
    
    -- add this to our recipes table
    local foodName = GetItemLinkName(foodLink):lower()
    
    --if foodName == "roast pig" and dupes[foodName] == 1 then
      --if 
    --end
    --if dupes[foodName] and foodName ~= "roast pig" then
    if dupes[foodName] then
      if foodName ~= "roast pig" then
        d(foodName.." exists!")
      else
        if dupes[foodName] == 1 then
          self.recipeCount = self.recipeCount + 1
          self.lastRecipeId = index
          dupes[foodName] = 2
        end
      end
    else
        dupes[foodName] = 1
        self.recipeCount = self.recipeCount + 1
        self.lastRecipeId = index
        
        --d("RecipeCount("..self.recipeCount..")")
        self:AddRecipe(recipeList, index ,recipeListIndex, foodName)    
 
    end
    -- d(foodName)
    --[[ if foodName == "carrot soup" then
      self:Cancel()
      return
    end ]]--
  
  end 

  -- Have we finished?
      
  if self.recipeCount >= totalGameRecipes or (self.maxId and index >= self.maxId) then

    self:Cancel()
  end        
end

---------------------------------------------------------------------
-- Function: OnAsyncEnd
--
-- This function is called when cancelled or finished
---------------------------------------------------------------------
function CookeryWizMissingRecipes:OnAsyncEnd(index)
  
  dupes = nil
  
  trace("- finished looking for missing recipes.")
  trace("- total recipes to look for ["..totalGameRecipes.."]")
  trace("- found ["..self.recipeCount.."], unknown["..self.recipeUnknownCount.."], Unresolved["..self.recipeUnresolvedCount.."]")
  trace("- last id of recipes ["..self.lastRecipeId.."]")
  
  self.recipeInfo.lastIndex = self.lastRecipeId
  self.recipeInfo.recipeCount = self.recipeCount
  
  if self.settingName then
    -- sort on category
    local count = #self.recipeInfo.cats
    trace("Sorting recipes for "..count.." cats")
    for i = 1, count do
      local cat = self.recipeInfo.cats[i]
      --trace("Sorting recipes for "..i)
      table.sort(cat.recipes, function(a, b)
          return a.name < b.name
      end)
    
      -- remove the names of the recipe
      for j = 1 , #cat.recipes do
        local recipe = cat.recipes[j]
        recipe.name = nil
      end
    end      
      

    trace("Saving recipe info to '"..self.settingName.."'")
    local savedVars = CookeryWiz:GetSavedVars()
    savedVars[self.settingName] = self.recipeInfo
  end
end

---------------------------------------------------------------------
-- Function: ResolveFoodList
--
-- This function attempts to resolve the in game recipe list from the
-- specialized food type with known food lists
---------------------------------------------------------------------
function CookeryWizMissingRecipes:ResolveFoodList(specializedFoodType)
  
  for i = 1, #foodLists do
    local list = foodLists[i]
    if list == specializedFoodType then    
      local cat = listMap[list]
      --trace("- food category for specializedFoodType["..cat.."]")
      return cat
    end
  end
  trace("failed to find recipe list from food")
  return SPELUNK_CAT_UNKNOWN       
end

---------------------------------------------------------------------
-- Function: ResolveDrinkList
--
-- This function attempts to resolve the in game recipe list from the
-- specialized food type with known drink lists
---------------------------------------------------------------------
function CookeryWizMissingRecipes:ResolveDrinkList(specializedFoodType)
  
  for i = 1, #drinkLists do   
    local list = drinkLists[i]
    if list == specializedFoodType then
      local cat = listMap[list]
      --trace("- drink category for specializedFoodType["..cat.."]")
      return cat
    end
  end
  trace("failed to find recipe list from drink")
  return SPELUNK_CAT_UNKNOWN       
end

---------------------------------------------------------------------
-- Function: ResolveRecipeListIndex
--
-- This function attempts to resolve the in-game index of the recipe
-- in the recipe list. The logged on character must know this recipe.
---------------------------------------------------------------------
function CookeryWizMissingRecipes:ResolveRecipeListIndex(recipeList, recipeFoodLink)
  local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(recipeList)
  
  for i = 1, numRecipes do   
    local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(recipeList, i)
    if known then
      local foodLink = GetRecipeResultItemLink(recipeList, i, LINK_STYLE_DEFAULT)
      if foodLink == recipeFoodLink then
        return i
      end       
    end
  end
  trace("failed to find recipe list index")
  return SPELUNK_RECIPE_LIST_INDEX_UNKNOWN      
end

---------------------------------------------------------------------
-- Function: Save
--
-- This function will flag whether we should save results to the
-- saved variable file at the end of the process
---------------------------------------------------------------------
function CookeryWizMissingRecipes:Save(settingName)
  self.settingName = settingName
end

---------------------------------------------------------------------
-- Function: SetMaxId
--
-- This function will set a maximum id that we will not scan past
-- Completely optional and is really only here for testing
---------------------------------------------------------------------
function CookeryWizMissingRecipes:SetMaxId(maxId)
  self.maxId = maxId
end




