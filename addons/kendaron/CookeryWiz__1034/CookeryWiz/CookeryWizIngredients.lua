CW_INGREDIENT_DATA_TYPE = 2

local L = CookeryWizLanguage.language

local masterIngredientList = {}
local ingredientData

CookeryWizIngredients = {}

CookeryWizIngredients.traceEnabled = false

local function trace(msg)
  if CookeryWizIngredients.traceEnabled then
    CookeryWiz:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: GetCount()
--
-- This function is called to get the ingredients count
---------------------------------------------------------------------
function CookeryWizIngredients:GetCount()
  return #masterIngredientList
end


---------------------------------------------------------------------
-- Function: GetIngredientData()
--
-- This function is called to get the wrapper ingredient data object
---------------------------------------------------------------------
function CookeryWizIngredients:GetIngredientData()
  return ingredientData
end

---------------------------------------------------------------------
-- Function: GetIngredients()
--
-- This function is called to get the ingredients data object
---------------------------------------------------------------------
function CookeryWizIngredients:GetIngredients()
  return ingredientData.ingredients
end


---------------------------------------------------------------------
-- Function: GetEmbeddedCount
--
-- This function returns the number of ingredients in the 'hard-coded
-- embedded in this file' list
---------------------------------------------------------------------
function CookeryWizIngredients:GetEmbeddedCount() 
  return ingredientData.ingredientCount 
end


function CookeryWizIngredients:GetEntry(index)
  if not index then
    d("no index specified")
    return nil
  end
  
  if index > #masterIngredientList then
    d("index greater than number of indexes")
    return nil    
  end
  
  if index <= 0 then
    d("index less than 1")
    return nil    
  end
  
  return masterIngredientList[index]  
end

---------------------------------------------------------------------
-- Function: GetEntryByName
--
-- This function is called to find the entry with the matching name
---------------------------------------------------------------------
function CookeryWizIngredients:GetEntryByName(name)
  if not name then
    d("no name specified")
    return nil
  end
  
  for key, entry in pairs(masterIngredientList) do
    if entry:GetName() == name then
      return entry
    end    
  end

end

---------------------------------------------------------------------
-- Function: Enumerate
--
-- This function is called to enumerate the ingredients calling a
-- custom function
---------------------------------------------------------------------
function CookeryWizIngredients:Enumerate(fn)
  if not fn then
    trace("No function passed to Enumerate")
    return
  end
  for key, entry in pairs(masterIngredientList) do
      if fn(entry) then
        break
      end    
  end   
end

---------------------------------------------------------------------
-- Function: GetEntryById
--
-- This function is called to find the entry with the matching id
---------------------------------------------------------------------
function CookeryWizIngredients:GetEntryById(id)
  if not id then
    d("no id specified")
    return nil
  end
  local ingredient = nil
  
  self:Enumerate(function(entry)
      if entry:GetItemId() == id then
        ingredient = entry
        return true;
      end
    end)
  
  return ingredient
end

---------------------------------------------------------------------
-- Function: ClearCookQuantities
--
-- This function is called to clear the ingredient quantities that would
-- be used in cooking
---------------------------------------------------------------------
function CookeryWizIngredients:ClearCookQuantities()
  self:Enumerate(function(ingredient)
      ingredient:SetCookQuantity(0)
      end)
end

---------------------------------------------------------------------
-- Ingredient scroll list specific Routines
---------------------------------------------------------------------

CookeryWizIngredients.ingredientToolTip = nil
CookeryWizIngredients.ingredientsScrollList = nil
CookeryWizIngredients.ingredientsScrollListWrapper = nil
CookeryWizIngredients.cookIngredients = nil

---------------------------------------------------------------------
-- Function: RefreshScrollList
--
-- This function is called to refresh the displayed content of the
-- recipe list
---------------------------------------------------------------------
function CookeryWizIngredients:RefreshScrollList()
  if self.ingredientsScrollListWrapper then
    self.ingredientsScrollListWrapper:RefreshVisible()
  end
end

---------------------------------------------------------------------
-- Function: OnListIngredientsInitialized
--
-- This function is called when the scrollist of ingredients is
-- initialised
---------------------------------------------------------------------
function CookeryWizIngredients:OnListIngredientsInitialized(control)

  trace("CookeryWizIngredients:OnListIngredientsInitialized") 

  if not control then
      trace("IngredientScrollList is nil")
      return
  end
  
  local wrapper = CookeryWizScrollList:new(control)
  wrapper:Initialise(self, control, CW_INGREDIENT_DATA_TYPE)
  self.ingredientsScrollList = control
  self.ingredientsScrollListWrapper = wrapper
end

---------------------------------------------------------------------
-- Function: OnQuantityControlInitialized
--
-- This function is called to initialise the quantity label control
---------------------------------------------------------------------
function CookeryWizIngredients:OnQuantityControlInitialized(control)
  CookeryWiz:SetupTooltip(control, L[CWL_LABEL_TOOLTIP_INGREDIENTS_CONSUMED])  
end

---------------------------------------------------------------------
-- Function: OnAvailableControlInitialized
--
-- This function is called to initialise the quantity label control
---------------------------------------------------------------------
function CookeryWizIngredients:OnAvailableControlInitialized(control)
  CookeryWiz:SetupTooltip(control, L[CWL_LABEL_TOOLTIP_INGREDIENTS_AVAILABLE])  
end

---------------------------------------------------------------------
-- Function: ClearCookIngredients
--
-- This function is called to clear the ingredients scrollist and
-- table of ingredients used
---------------------------------------------------------------------
function CookeryWizIngredients:ClearCookIngredients()
  -- clear the scroll list
  self.ingredientsScrollListWrapper:Clear()
  -- reset cook quantities on ingredients (Not sure if the clear will trigger this for each item?)
  if self.cookIngredients then
    for i = 1, #self.cookIngredients do
      local ingredient = self.cookIngredients[i]
      ingredient:SetCookQuantity(0)      
    end
    self.cookIngredients = nil
  end  
end

---------------------------------------------------------------------
-- Function: AddCookIngredient
--
-- This function adds an ingredient to the table of those used if it
-- is not already included
---------------------------------------------------------------------
function CookeryWizIngredients:AddCookIngredient(ingredient)
  
  if not self.cookIngredients then
    self.cookIngredients = {}
  end
  
  local found = false
  
  for i = 1, #self.cookIngredients do
    local cookIngredient = self.cookIngredients[i]
    if cookIngredient == ingredient then
      found = true
    end
  end
  
  if not found then
    self.cookIngredients[#self.cookIngredients + 1] = ingredient
  end

end

---------------------------------------------------------------------
-- Function: PopulateCookIngredients
--
-- This function will update the table of used ingredients
---------------------------------------------------------------------
function CookeryWizIngredients:UpdateCookIngredients(masterRecipe)

  
  if not masterRecipe then
    --d("CookeryWizIngredients:Updating normal")
    self:PopulateCookIngredients()
    if self.ingredientsScrollListWrapper then
      self.ingredientsScrollListWrapper:Populate(false)
    end
  else
    d("CookeryWizIngredients:Updating specific")
    -- we want to update specific ingredients
    local ingredients = masterRecipe:GetIngredients()
    for i = 1, #ingredients do
      -- each object in array returned resembles the folowing:
      -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}
      local ingredient = ingredients[i]
      local entry = ingredient.entry;    
      d("updating["..entry:GetName().."]")
      entry:UpdateRowControlData()
    end
  end
  
end

---------------------------------------------------------------------
-- Function: PopulateCookIngredients
--
-- This function will populate the table of used ingredients
---------------------------------------------------------------------
function CookeryWizIngredients:PopulateCookIngredients()
  
  self:ClearCookIngredients()
  
  local cookVars = CookeryWiz:GetCookVars()
  local cook = nil

 
  -- next loop through and tally the total ingredients needs for each recipe
  for cookIndex, cookEntry in pairs(cookVars) do
    local masterRecipeEntry = CookeryWizRecipeList:GetEntry(cookEntry.recipeId)
    if masterRecipeEntry then
      local ingredientsEntry = masterRecipeEntry:GetIngredients()
      -- each object in array returned resembles the folowing:
      -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}      
      -- It is quite possible we do not know the recipe
      local resultStack = 0
      
      -- NOTE: The spelunk process is not exact (as the ESO API that would help is broken)
      -- so it is guess work mostly. I have assigned an incorrect category once and the total ingredient count was wrong
      -- That is why we will do a check after the isknown section
      if masterRecipeEntry:IsKnown() then
        local recipeIndex = masterRecipeEntry:GetRecipeIndex()
        local _, icon, stack, sellPrice, quality = GetRecipeResultItemInfo(masterRecipeEntry:GetRecipeListIndex(), recipeIndex)
        --d("Result Stack for "..masterRecipeEntry:GetRecipeName().." - ["..stack.."]")
        resultStack = stack        
      end
      if resultStack == 0 then
        -- we should probably be able to work it out on whether they have the skill!
        -- but since they dont know it, set to 1 as they cannot craft it.
        -- I could also recheck the category/list index to see whether it was incorect
        resultStack = 1
      end
      
      cookEntry.realQuantity = math.ceil(cookEntry.quantity / resultStack)
      --d("resultStack["..resultStack.."] ,quantity"..cookEntry.quantity.."], realQuantity["..cookEntry.realQuantity.."]")

      --d("Count of ingredients "..#ingredientsEntry)
      
      for ingredientIndex = 1, #ingredientsEntry do
        -- a CookeryWizIngredient
        local ingredient = ingredientsEntry[ingredientIndex]
        local entry = ingredient.entry;
        
        local quantity = entry:GetCookQuantity() + (cookEntry.realQuantity * ingredient.quantity)
        entry:SetCookQuantity(quantity)
        
        self:AddCookIngredient(entry)
      end    
    end    
  end
  
  --
  if CookeryWiz:IsAlwaysShowIngredientsEnabled() then
    
  end
  
end


---------------------------------------------------------------------
-- Function: OnSortEntries
--
-- This function is called when the scrollist wants to sort the
-- data
---------------------------------------------------------------------
function CookeryWizIngredients:OnSortEntries(key, scrollData)
  local function SortNameAsc(entryA, entryB)
    return entryA.data.name < entryB.data.name
  end 
  
  table.sort(scrollData, SortNameAsc) 
  self.ingredients = scrollData  
end

---------------------------------------------------------------------
-- Function: OnFetchEntries
--
-- This function is called when the scrollist 
-- needs the items to display
---------------------------------------------------------------------
function CookeryWizIngredients:OnFetchEntries(key)
  return self.cookIngredients
end

---------------------------------------------------------------------
-- Function: OnFetchDataType
--
-- This function is called when the scrollist 
-- needs the datatype details
---------------------------------------------------------------------
function CookeryWizIngredients:OnFetchDataType(key)
  if key == CW_INGREDIENT_DATA_TYPE then
    return CW_INGREDIENT_DATA_TYPE, "IngredientRowTemplate", 28
  end
end

---------------------------------------------------------------------
-- Function: OnFetchCategoryDataType
--
-- This function is called when the scrollist 
-- needs the datatype for categories
-- We are not using categories for ingredients
---------------------------------------------------------------------
function CookeryWizIngredients:OnFetchCategoryDataType(key)

end

---------------------------------------------------------------------
-- Function: OnIngredientsTooltipInitialized
--
-- This function is called when ingredient tooltip used in the recipe
-- scroll list is initialised
---------------------------------------------------------------------
function CookeryWizIngredients:OnIngredientsTooltipInitialized(control)
  if not control then
    trace("Ingredients tooltip control is nil")
    return
  end
  control:SetParent(PopupTooltipTopLevel)
  self.ingredientToolTip = control
end

---------------------------------------------------------------------
-- Function: ShowIngredientToolTip
--
-- This function shows the tooltip for the control in the recipe list
---------------------------------------------------------------------
-- Show the tooltip for the control
function CookeryWizIngredients:ShowIngredientToolTip(rowControl, state)
  
  if not self.ingredientToolTip then
    trace("No ingredient tooltip")
    return
  end
  
  local tooltipControl = self.ingredientToolTip
  if state then
    local ingredient = rowControl.entry
    if ingredient then
      local text = ingredient:GetLink()      
      CookeryWiz:RepositionTooltip(tooltipControl)
      tooltipControl:SetLink(text)      
    end
  else
    ClearTooltip(tooltipControl)
  end
end

---------------------------------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: ConstructMasterList
--
-- This function is called to construct the master ingredient list
-- from the array of ingredients
---------------------------------------------------------------------
function CookeryWizIngredients:ConstructMasterList()
  local ingredients = self:GetIngredients()
  for i = 1, #ingredients do
    local data = ingredients[i]
    self:AppendMasterList(data.id, false)
  end
end


---------------------------------------------------------------------
-- Function: AppendMasterList
--
-- This function is called to append to the master ingredient list
-- if validate is passed it check to see if it exists before adding
---------------------------------------------------------------------
function CookeryWizIngredients:AppendMasterList(id, validate)
  local entry
  if validate then
    entry = self:GetEntryById(id)
    if entry then
      --d("Entry found: "..entry.id.." when looking for "..id)
      return entry
    end    
  end
  
  entry = CookeryWizIngredient:new(id)
  local index = #masterIngredientList + 1
  entry.index = index
  masterIngredientList[index] = entry
  
  return entry
end


function CookeryWizIngredients:Initialize()
  trace("CookeryWizIngredients:Initialize")

  -- construct the master list
  self:ConstructMasterList()
end

ingredientData = 
                     {
                    ["lastIndex"] = 150731,
                    ["ingredients"] = 
                    {
                        [1] = 
                        {
                            ["id"] = 33754,
                        },
                        [2] = 
                        {
                            ["id"] = 27063,
                        },
                        [3] = 
                        {
                            ["id"] = 33756,
                        },
                        [4] = 
                        {
                            ["id"] = 33752,
                        },
                        [5] = 
                        {
                            ["id"] = 27058,
                        },
                        [6] = 
                        {
                            ["id"] = 26954,
                        },
                        [7] = 
                        {
                            ["id"] = 27057,
                        },
                        [8] = 
                        {
                            ["id"] = 34321,
                        },
                        [9] = 
                        {
                            ["id"] = 27064,
                        },
                        [10] = 
                        {
                            ["id"] = 33753,
                        },
                        [11] = 
                        {
                            ["id"] = 28609,
                        },
                        [12] = 
                        {
                            ["id"] = 27100,
                        },
                        [13] = 
                        {
                            ["id"] = 34311,
                        },
                        [14] = 
                        {
                            ["id"] = 33755,
                        },
                        [15] = 
                        {
                            ["id"] = 34308,
                        },
                        [16] = 
                        {
                            ["id"] = 28610,
                        },
                        [17] = 
                        {
                            ["id"] = 28603,
                        },
                        [18] = 
                        {
                            ["id"] = 34305,
                        },
                        [19] = 
                        {
                            ["id"] = 34309,
                        },
                        [20] = 
                        {
                            ["id"] = 34324,
                        },
                        [21] = 
                        {
                            ["id"] = 33758,
                        },
                        [22] = 
                        {
                            ["id"] = 28604,
                        },
                        [23] = 
                        {
                            ["id"] = 34323,
                        },
                        [24] = 
                        {
                            ["id"] = 34307,
                        },
                        [25] = 
                        {
                            ["id"] = 26802,
                        },
                        [26] = 
                        {
                            ["id"] = 33774,
                        },
                        [27] = 
                        {
                            ["id"] = 27043,
                        },
                        [28] = 
                        {
                            ["id"] = 34345,
                        },
                        [29] = 
                        {
                            ["id"] = 27049,
                        },
                        [30] = 
                        {
                            ["id"] = 29030,
                        },
                        [31] = 
                        {
                            ["id"] = 28666,
                        },
                        [32] = 
                        {
                            ["id"] = 34329,
                        },
                        [33] = 
                        {
                            ["id"] = 27035,
                        },
                        [34] = 
                        {
                            ["id"] = 34348,
                        },
                        [35] = 
                        {
                            ["id"] = 27048,
                        },
                        [36] = 
                        {
                            ["id"] = 27052,
                        },
                        [37] = 
                        {
                            ["id"] = 28639,
                        },
                        [38] = 
                        {
                            ["id"] = 33771,
                        },
                        [39] = 
                        {
                            ["id"] = 34334,
                        },
                        [40] = 
                        {
                            ["id"] = 33773,
                        },
                        [41] = 
                        {
                            ["id"] = 33768,
                        },
                        [42] = 
                        {
                            ["id"] = 34330,
                        },
                        [43] = 
                        {
                            ["id"] = 28636,
                        },
                        [44] = 
                        {
                            ["id"] = 34349,
                        },
                        [45] = 
                        {
                            ["id"] = 33772,
                        },
                        [46] = 
                        {
                            ["id"] = 34333,
                        },
                        [47] = 
                        {
                            ["id"] = 34347,
                        },
                        [48] = 
                        {
                            ["id"] = 34346,
                        },
                        [49] = 
                        {
                            ["id"] = 34335,
                        },
                        [50] = 
                        {
                            ["id"] = 27059,
                        },
                        [51] = 
                        {
                            ["id"] = 64221,
                        },
                        [52] = 
                        {
                            ["id"] = 120078,
                        },
                        [53] = 
                        {
                            ["id"] = 30162,
                        },
                        [54] = 
                        {
                            ["id"] = 77590,
                        },
                        [55] = 
                        {
                            ["id"] = 46151,
                        },
                        [56] = 
                        {
                            ["id"] = 150731,
                        },
                        [57] = 
                        {
                            ["id"] = 30165,
                        },
                        [58] = 
                        {
                            ["id"] = 77583,
                        },
                        [59] = 
                        {
                            ["id"] = 42872,
                        },
                        [60] = 
                        {
                            ["id"] = 42870,
                        },
                        [61] = 
                        {
                            ["id"] = 42869,
                        },
                        [62] = 
                        {
                            ["id"] = 77587,
                        },
                        [63] = 
                        {
                            ["id"] = 30161,
                        },
                        [64] = 
                        {
                            ["id"] = 115026,
                        },
                        [65] = 
                        {
                            ["id"] = 1187,
                        },
                        [66] = 
                        {
                            ["id"] = 137958,
                        },
                        [67] = 
                        {
                            ["id"] = 33194,
                        },
                        [68] = 
                        {
                            ["id"] = 64222,
                        },
                        [69] = 
                        {
                            ["id"] = 54171,
                        },
                        [70] = 
                        {
                            ["id"] = 30166,
                        },
                        [71] = 
                        {
                            ["id"] = 139020,
                        },
                        [72] = 
                        {
                            ["id"] = 77581,
                        },
                        [73] = 
                        {
                            ["id"] = 139019,
                        },
                        [74] = 
                        {
                            ["id"] = 77589,
                        },
                        [75] = 
                        {
                            ["id"] = 30164,
                        },
                        [76] = 
                        {
                            ["id"] = 30156,
                        },
                        [77] = 
                        {
                            ["id"] = 77584,
                        },
                        [78] = 
                        {
                            ["id"] = 42871,
                        },
                        [79] = 
                        {
                            ["id"] = 30153,
                        },
                        [80] = 
                        {
                            ["id"] = 30149,
                        },
                        [81] = 
                        {
                            ["id"] = 30152,
                        },
                        [82] = 
                        {
                            ["id"] = 30154,
                        },
                        [83] = 
                        {
                            ["id"] = 77585,
                        },
                    },
                    ["ingredientCount"] = 83,
                }
               