local L = CookeryWizLanguage.language

local masterRecipeList = {}
local recipeListInfo = {}
local recipeData = {}

local callbackRecipeKey = "recipes"

CookeryWizRecipeList = {}
CookeryWizRecipeList.name = "CookeryWizRecipeList"

CookeryWizRecipeList.asyncPopulate = nil
CookeryWizRecipeList.isIntialised = false

CookeryWizRecipeList.traceEnabled = false

CookeryWizRecipeList.totalRecipes = 0

local function trace(msg)
  if CookeryWizRecipeList.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

function CookeryWizRecipeList:OnCanCookQuantityLabelInitialized(control)
  --CookeryWiz:SetupTooltip(control, L[CWL_BUTTON_OPTIONS_ENABLE_CHAT_THEME_TOOLTIP])  
  CookeryWizUtils:SetFont(control, 14)
end

function CookeryWizRecipeList:OnExistingQuantityLabelInitialized(control)
  CookeryWizUtils:SetFont(control, 14)
end



function CookeryWizRecipeList:OnMouseEnter(control)
  ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_LABEL_TOOLTIP_RECIPES_CAN_COOK])
  --CookeryWizRecipeList:ShowItemToolTip(control:GetParent(), true)
  --CookeryWiz:SetHighlight(control:GetParent(), true)  
end

function CookeryWizRecipeList:OnMouseExit(control)
  --CookeryWizRecipeList:ShowItemToolTip(control:GetParent(), false)
  --CookeryWiz:SetHighlight(control:GetParent(), false)  
  ZO_Tooltips_HideTextTooltip() 
end


---------------------------------------------------------------------
-- Function: DumpCategories
--
-- This function is called to info on all the recipe categories
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpCategories()
  local cats = self:GetCats()
  for i = 1, #cats do
    self:DumpCategory(i)
  end
end


---------------------------------------------------------------------
-- Function: DumpCategory
--
-- This function is called to dump info on the coresponding cat with the index
-- We copy the category and sort it on recipe index (to make it easier to compare)
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpCategory(index)
    local list = {}
    local counter = 0
    self:Enumerate(function(recipeEntry, cat)
      if cat:GetCategory() == index then
        counter = counter + 1
        --list[#list+1] = { recipeIndex = recipeEntry:GetRecipeIndex() }
        list[#list+1] =  recipeEntry
      end
    end)       
  
 d("CookeryWiz database list")
  table.sort(list, function(entryA, entryB)
    return entryA:GetRecipeIndex() < entryB:GetRecipeIndex()
  end ) 
  
  for i = 1, #list do
    local entry = list[i]
    d(i..". " ..entry:GetRecipeName()..", relIndex="..entry:GetRelativeIndex())
  end
end

---------------------------------------------------------------------
-- Function: DumpRecipes
--
-- This function will simply dump the recipes that we have in the
-- CookeryWiz database (not the game database)
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpRecipes(nameOnly)
  self:Enumerate(function(recipeEntry)
      if nameOnly then
        d(recipeEntry:GetRecipeName())
      else    
        d(recipeEntry)
      end  
  end)
end

---------------------------------------------------------------------
-- Function: DumpUnresolvedRecipesFood
--
-- This function will dump the recipes that we have in the
-- CookeryWiz database that are unresolved. (That we know
-- and are do not have a game recipe list index for)
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpUnresolvedRecipesFood(cat)
  local count = 0
  
  self:Enumerate(function(recipeEntry)
      local link = recipeEntry:GetFoodResultLink()

      local itemType = GetItemLinkItemType(link)
      if itemType == ITEMTYPE_FOOD and not recipeEntry:GetRecipeIndex() and recipeEntry:IsKnown() then
        local display = recipeEntry:GetFoodResultName()
        if not cat then      
          count = count + 1
          d("["..count.."] "..display)
        elseif cat == recipeEntry:GetRecipeListIndex() then
          count = count + 1
          d("["..count.."] "..display)
        end
      end   
  end)
 
end

---------------------------------------------------------------------
-- Function: DumpRecipesFood
--
-- This function will dump the recipes that are food
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpRecipesFood(cat)

  self:Enumerate(function(recipeEntry)
      local link = recipeEntry:GetFoodResultLink()
      local itemType = GetItemLinkItemType(link)
      if itemType == ITEMTYPE_FOOD then
        local display = recipeEntry:GetFoodResultName()
        if not cat then      
          d(display)
        elseif cat == recipeEntry:GetRecipeListIndex() then
          d(display)
        end
      end  
  end)

end

---------------------------------------------------------------------
-- Function: DumpRecipesFood
--
-- This function will dump the recipes that are drink
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpRecipesDrink(level)
  local name
  self:Enumerate(function(recipeEntry)
      local link = recipeEntry:GetFoodResultLink()
      local itemType = GetItemLinkItemType(link)
      if itemType == ITEMTYPE_DRINK then
        name = recipeEntry:GetFoodResultName().."["..recipeEntry:GetRecipeListIndex().."]"
        if not level then      
          d(name)
        elseif level > recipeEntry:GetFoodResultLevel() then
          d(name)
        end
      end
  end)  
end

---------------------------------------------------------------------
-- Function: DumpRecipeLists
--
-- This function will dump the in game recipe lists
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpRecipeLists()
  --local numLists = GetNumRecipeLists() 
  local numLists = CookeryWizUtils:GetTotalFoodLists()
  local totalUnknown = 0
  local totalKnown = 0
  local total = 0
  
  for cat = 1, numLists do
    local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(cat)
    local knownCount = 0
    local unknownCount = 0
    local s = ""
    total = total + numRecipes
    if name then
      s = "["..cat.."]-"..name..", numRecipes="..numRecipes
      for recipeIndex = 1, numRecipes do
        local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(cat, recipeIndex)
        if known then
          knownCount = knownCount + 1
        else
          unknownCount = unknownCount + 1
        end
      end
      s = s..", known="..knownCount..", unknown="..unknownCount
      d(s)
      totalKnown = totalKnown + knownCount
      totalUnknown = totalUnknown + unknownCount
    end
  end
  d("Total="..total..", Known="..totalKnown..", Unknown="..totalUnknown)
end

---------------------------------------------------------------------
-- Function: DumpKnownRecipes
--
-- This function will process the in game recipe lists and dump
-- known recipes
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpKnownRecipes()

  local numLists = GetNumRecipeLists() 
  for cat = 1, numLists do
    self:DumpKnownRecipesCategory(cat)
  end
end

---------------------------------------------------------------------
-- Function: DumpKnownRecipesCategory
--
-- This function will process the specified in game recipe list and dump
-- the known recipes
---------------------------------------------------------------------
function CookeryWizRecipeList:DumpKnownRecipesCategory(cat)
  local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(cat)
  if name then
    d("InGame list "..name)
    for recipeIndex = 1, numRecipes do
      local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(cat, recipeIndex)
      if known then
        d("["..recipeIndex.."]-"..foodName)          
      end
    end      
  end
end

function CookeryWizRecipeList:ClearCheckedIndexes()
 
  self:Enumerate(function(recipeEntry)
      if recipeEntry.recipeIndex == 0 then    
        recipeEntry.recipeIndex = nil
      end
  end)    
end

---------------------------------------------------------------------
-- Function: ResolveFoodInText
--
-- This function will check if the food is in the text passed
---------------------------------------------------------------------
function CookeryWizRecipeList:ResolveFoodInText(text) 
  trace("ResolveFoodInText["..text.."]")
  local textLower = text:lower()
  
  local foundEntry = nil
  
  self:Enumerate(function(recipeEntry)
      local display = zo_strformat("<<1>>", recipeEntry:GetFoodResultNameLower())
      local lowerFoodName = display
      if textLower:find(lowerFoodName, 1, true) == 1 then
        --trace("Found matching item")
        foundEntry = recipeEntry
        return true
      end
  end)   

  return foundEntry
end

---------------------------------------------------------------------
-- Function: GetEntryByFoodName
--
-- This function will check all recipes for the recipe that produces
-- the passed foodname
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEntryByFoodName(foodName)
  -- unfortunately some recipe names have the wrong case (Rye-in-your-Eye) so need to do
  -- case insensitive check
  local lowerFoodName = foodName:lower()
  
  local foundEntry = nil
  
  self:Enumerate(function(recipeEntry)
      local foodResultName = recipeEntry:GetFoodResultNameLower()

      --if masterEntry.cat == 8 then
        --trace(foodResultName..","..masterEntry.cat)
      --end
      if foodResultName == lowerFoodName then
        foundEntry = recipeEntry
        return true
      end
  end)   

  return foundEntry  
end

---------------------------------------------------------------------
-- Function: GetEntryByRecipeLink
--
-- This function will check all recipes for the recipe that
-- matches the passed recipe link
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEntryByRecipeLink(recipeLink)
  local recipeName = GetItemLinkName(recipeLink)
  
  local foundEntry = nil
  self:Enumerate(function(recipeEntry)
      --local link = recipeEntry:GetFoodResultLink()
      if recipeName == recipeEntry:GetRecipeName() then
        foundEntry = recipeEntry
        return true
      end
  end)  

  return foundEntry
end

---------------------------------------------------------------------
-- Function: GetEntryByFoodId
--
-- This function will check all recipes for the recipe that
-- matches the id of the food passed
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEntryByFoodId(foodId)
  
  if not foodId then
    return
  end
  trace("Looking for food id "..foodId)
  
  
  local foundEntry = nil
  self:Enumerate(function(recipeEntry)
      --local link = recipeEntry:GetFoodResultLink()
      if foodId == recipeEntry:GetFoodId() then
        --trace("Found foodId")
        foundEntry = recipeEntry
        return true
      end
  end)  

  return foundEntry  
end

---------------------------------------------------------------------
-- Function: GetEntryByRecipeIndex
--
-- This function will return the recipeEntry that comes from the specifed
-- recipe list and has the given recipeIndex
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEntryByRecipeIndex(recipeList, recipeIndex) 
  local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(recipeList, recipeIndex) 


    local cats = self:GetCats()
    local cat = cats[recipeList]
    local recipes = cat.recipes
    local recipeCount = #recipes
    --d("["..cat:GetCategory().."] "..cat:GetName().."("..recipeCount..")")
    for j = 1, #recipes do
      local masterEntry = cat.recipes[j]
      if masterEntry.cat == recipeList then    
        local foodResultName = masterEntry:GetFoodResultName()

        if foodResultName == foodName then
          return masterEntry
        end
      end
    end

  
end

-- Returns the CookeryWizRecipeListEntry by index
function CookeryWizRecipeList:GetEntry(index)
  if not index then
    trace("no index specified")
    return nil
  end
  
 
  trace("Looking for id "..index)  
  
  local foundEntry = nil
  self:Enumerate(function(recipeEntry)
      --local link = recipeEntry:GetFoodResultLink()
      if index == recipeEntry:ItemId() then
        --trace("Found foodId")
        foundEntry = recipeEntry
        return true
      end
  end)  

  return foundEntry  
  
end

---------------------------------------------------------------------
-- Function: GetEntryByRecipeIndex
--
-- This function will return the recipeEntry that comes from the specifed
-- recipe list and has the given recipeIndex
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEntryByRecipeIndex(recipeList, recipeIndex) 
  local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType = GetRecipeInfo(recipeList, recipeIndex) 


    local cats = self:GetCats()
    local cat = cats[recipeList]
    local recipes = cat.recipes
    local recipeCount = #recipes
    --d("["..cat:GetCategory().."] "..cat:GetName().."("..recipeCount..")")
    for j = 1, #recipes do
      local masterEntry = cat.recipes[j]
      if masterEntry.cat == recipeList then    
        local foodResultName = masterEntry:GetFoodResultName()

        if foodResultName == foodName then
          return masterEntry
        end
      end
    end

  
end

---------------------------------------------------------------------
-- Function: GetEntryById
--
-- This function returns the entry from the id
---------------------------------------------------------------------

function CookeryWizRecipeList:GetEntryById(id)
  if not id then
    d("no id specified")
    return nil
  end
  
  trace("Looking for id "..id)  
  
  local foundEntry = nil
  self:Enumerate(function(recipeEntry)
      --local link = recipeEntry:GetFoodResultLink()
      if id == recipeEntry:ItemId() then
        --trace("Found foodId")
        foundEntry = recipeEntry
        return true
      end
  end)  

  return foundEntry  
  
end

---------------------------------------------------------------------
-- Function: GetEntryByMasterRecipeListIndex
--
-- This function returns the entry from the master recipe list index
-- This should be redundant now that I am moving away from the 
-- masterRecipeList but it is needed to make the sending of known recipes
-- work. I will have to revise the message sending later.
---------------------------------------------------------------------
-- Returns the CookeryWizRecipeListEntry by index
function CookeryWizRecipeList:GetEntryByMasterRecipeListIndex(index)
  if not index then
    trace("no index specified")
    return nil
  end
  
  if index > #masterRecipeList then
    trace("index greater than number of recipes")
    return nil    
  end
  
  if index <= 0 then
    trace("index less than 1")
    return nil    
  end
  
  return masterRecipeList[index]
  
end

---------------------------------------------------------------------
-- Function: GetCount
--
-- This function returns the number of recipes in the list
---------------------------------------------------------------------
function CookeryWizRecipeList:GetCount()
  
  if self.totalRecipes == 0 then
    self:RecalculateRecipeCount()
  end
  
  return self.totalRecipes
end

---------------------------------------------------------------------
-- Function: GetEmbeddedCount
--
-- This function returns the number of recipes in the 'hard-coded
-- embedded in this file' list
---------------------------------------------------------------------
function CookeryWizRecipeList:GetEmbeddedCount() 
  return recipeData.recipeCount 
end

---------------------------------------------------------------------
-- Function: GetLastIndex
--
-- This function returns the last recipe index found in the 'hard-coded
-- embedded in this file' list
---------------------------------------------------------------------
function CookeryWizRecipeList:GetLastIndex() 
  return recipeData.lastIndex 
end

---------------------------------------------------------------------
-- Function: RecalculateRecipeCount
--
-- This function recalculates how many recipes are in the list
---------------------------------------------------------------------
function CookeryWizRecipeList:RecalculateRecipeCount()
  local count = 0
  
  local cats = self:GetCats()
  for i = 1, #cats do
    local cat = cats[i]
    local recipes = cat.recipes
    count = count + #recipes
  end      
  
  self.totalRecipes = count  
end

function CookeryWizRecipeList:GetListCount(cat)
  if not cat then
    d("Cat must be passed")
  end
  local recipeListInfoItem = recipeListInfo[cat]
  if not recipeListInfoItem then
    d("Invalid cat index passed")
  else
    return recipeListInfoItem:GetRecipeCount()
  end
end

--[[
-- Maps the recipes to the ingame list indexes and creates lowercase name
-- Should be called whenever the game first loads and when a recipe is learnt!
function CookeryWizRecipeList:RegenerateEntryIndexes()
  -- for performance reasons, we want to be more efficient with search filtering
  -- so create a lower case version of the recipe name
  -- and also get the in game recipe index
  local count = 0

  self:Enumerate(function(recipeEntry, cat)
    -- only get lowecase name if it has not been obtained
    recipeEntry:GetRecipeNameLower()
    -- and add the recipe index. This is constant, but will not return any info if not learnt
    if not recipeEntry:GetRecipeIndex() then
      count = count + 1
      --trace(" ["..count..": Regenerate "..recipeEntry:GetRecipeNameLower())
      recipeEntry:PopulateRecipeData(#cat.recipes)
      if not recipeEntry:GetRecipeIndex() then
        trace(recipeEntry:GetRecipeName()..": Unable to determine recipe index "..recipeEntry.recipeIndex)
      end
    end
  end)   
   
end
]]--

---------------------------------------------------------------------
-- Function: Validate
--
-- This function validates CookeryWiz recipe data
---------------------------------------------------------------------
function CookeryWizRecipeList:Validate()
  local numLists = GetNumRecipeLists()
  local cats = self:GetCats()
  local numCats =  #cats
  --for key, cat in pairs(recipeListInfo) do
    --numCats = numCats + 1
  --end
  
  d("Total number of categories")
  d("-ESO["..numLists.."]")
  d("-CW["..numCats.."]")
  
  local totalEso = 0
  local totalCW = 0
  
  d("Lists")

  for i = 1 , numLists do
    local name, numRecipes = GetRecipeListInfo(i)
    totalEso = totalEso + numRecipes
    
    local cat = cats[i]
    if not cat or cat == 0 then
      d("["..i.."] CW[ missing ] recipes[ n/a ]")    
    else

      d("["..i.."] ESO["..name.."] recipes["..numRecipes.."], CW["..cat:GetName().."] recipes["..cat:GetRecipeCount().."]")
      totalCW = totalCW + #cat.recipes
    end
  end
  d("")
  d("Total ESO - "..totalEso)
  d("Total CW - "..totalCW)

end


---------------------------------------------------------------------
-- Function: UpdateRecipeListIndex
--
-- This function updates recipe list indexes
---------------------------------------------------------------------
function CookeryWizRecipeList:UpdateRecipeListIndex(recipeListIndex, recipeIndex)
 
  local link = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
  local linkId = CookeryWizUtils:GetItemID(link)

  local cats = self:GetCats()
  local cat = cats[recipeListIndex]
  if not cat then
    return nil
  end
  local recipes = cat.recipes
  local recipeCount = #recipes
  --d("["..cat:GetCategory().."] "..cat:GetName().."("..recipeCount..")")
  for j = 1, #recipes do
    local recipeEntry = cat.recipes[j]
    trace("Checking "..recipeEntry:GetRecipeLink())
    local foodId = recipeEntry:GetFoodId()
    if linkId == foodId then          
      recipeEntry:SetRecipeIndex(recipeIndex)
      return recipeEntry
    end
  end

end


---------------------------------------------------------------------
-- Function: Enumerate
--
-- This function is called to enumerate the recipes calling a
-- custom function
---------------------------------------------------------------------
function CookeryWizRecipeList:Enumerate(fn)
  if not fn then
    trace("No function passed to Enumerate")
    return
  end
  
  local cats = self:GetCats()
  for i = 1, #cats do
    local cat = cats[i]
    local recipes = cat.recipes
    local recipeCount = #recipes
    --d("["..cat:GetCategory().."] "..cat:GetName().."("..recipeCount..")")
    for j = 1, #recipes do
      local recipeEntry = cat.recipes[j]
      if fn(recipeEntry, cat) then
        break
      end
    end
  end  
  
  --[[
  for key, entry in pairs(masterRecipeList) do
    fn(entry)
  end 
  ]]--
  
end


---------------------------------------------------------------------
-- Function: GetCats
--
-- This function is called to get the list of cats/recipes
---------------------------------------------------------------------
function CookeryWizRecipeList:GetCats()
  return recipeData.cats
end

---------------------------------------------------------------------
-- Function: GetRecipeData()
--
-- This function is called to get the recipe data object
---------------------------------------------------------------------
function CookeryWizRecipeList:GetRecipeData()
  return recipeData
end

---------------------------------------------------------------------
-- Function: GetCat
--
-- This function is called to get the coresponding cat with the index
---------------------------------------------------------------------
function CookeryWizRecipeList:GetCat(index)
  return recipeData.cats[index]
end

---------------------------------------------------------------------
-- Recipe scroll list specific Routines
---------------------------------------------------------------------

CookeryWizRecipeList.recipeToolTip = nil
CookeryWizRecipeList.recipeScrollList = nil
CookeryWizRecipeList.recipeScrollListWrapper = nil

CookeryWizRecipeList.filteredRecipes = {}

CookeryWizRecipeList.recipeTooltipControl = nil
CookeryWizRecipeList.foodTooltipControl = nil
CookeryWizRecipeList.currentToolTipEntry = nil

---------------------------------------------------------------------
-- Function: RefreshScrollList
--
-- This function is called to refresh the displayed content of the
-- recipe list
---------------------------------------------------------------------
function CookeryWizRecipeList:RefreshScrollList()
  if self.recipeScrollListWrapper then
    self.recipeScrollListWrapper:RefreshVisible()
  end
end

---------------------------------------------------------------------
-- Function: OnRecipeTooltipInitialized
--
-- This function is called the tooltip for showing recipes is
-- initialised
---------------------------------------------------------------------
function CookeryWizRecipeList:OnRecipeTooltipInitialized(control)
  if not control then
    d("Control is nil")
    return
  end
  self.recipeTooltipControl = control
  control:SetParent(PopupTooltipTopLevel)
end

---------------------------------------------------------------------
-- Function: OnFoodTooltipInitialized
--
-- This function is called the tooltip for showing food is
-- initialised
---------------------------------------------------------------------
function CookeryWizRecipeList:OnFoodTooltipInitialized(control)
  if not control then
    d("Control is nil")
    return
  end
  self.foodTooltipControl = control
  control:SetParent(PopupTooltipTopLevel)
end

---------------------------------------------------------------------
-- Function: ShowItemToolTip
--
-- This function is called to show both tooltips for a recipe
---------------------------------------------------------------------
function CookeryWizRecipeList:ShowItemToolTip(rowControl, state)
  --trace("ShowItemToolTip")
  local recipeTooltip = self.recipeTooltipControl
  local foodTooltip = self.foodTooltipControl
  if state then

    -- the recipe data entry object was assigned to the control. A 'fake' one
    -- is created for the food categories and has no .rid or .fid
    local entry = rowControl.entry
    if not entry then
      return
    end
    if entry:GetDataType() == CW_RECIPE_DATA_TYPE then
      if self.currentToolTipEntry == entry then
        return
      end
      self.currentToolTipEntry = entry
      local tooltipOffset = 10
      local text = entry.rid
      -- we need to determine optimal postion. If close to edge of screen funny things happen!
      local tooltipWidth = recipeTooltip:GetWidth()
      local vars = CookeryWiz:GetEasyFrameVars()
      local ui = CookeryWiz.ui
      --local left = vars.leftNormal
      local left = ui:GetLeft()
      local tooltipLeft = left
      local screenWidth = ui:GetParent():GetWidth()
      local uiWidth = ui:GetWidth()
      
      if left + uiWidth + tooltipWidth + tooltipOffset > screenWidth then
        InitializeTooltip(recipeTooltip, ui, TOPLEFT, -1 * (tooltipWidth + 10), -5, TOPLEFT)  
      else
        InitializeTooltip(recipeTooltip, ui, TOPLEFT, 10, -5, TOPRIGHT)
      end
        InitializeTooltip(foodTooltip, recipeTooltip, TOPLEFT, 0, 0, BOTTOMLEFT)
      
      --d("tooltipWidth-"..tooltipWidth..", tooltipLeft-"..tooltipLeft.."uiLeft-"..left)

      recipeTooltip:SetLink(text)
      -- food tooltip
      
      foodTooltip:SetLink(entry:GetFoodResultLink())

      if true then
        local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
        recipeTooltip:AddLine("", "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
        ZO_Tooltip_AddDivider(recipeTooltip)
        --recipeTooltip:AddLine("", "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
        recipeTooltip:AddLine(L[CWL_INGREDIENT_STOCK_LEVELS_TOOLTIP], "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
        r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
        local ingredients = entry:GetIngredients()
        local ingredientQuantity = 1
        local line = ""
        local item = ""
        local lineItems = 2

        for ingredientIndex = 1, #ingredients do
          -- each object in array returned from GetIngredients() resembles the folowing:
          -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}                   
          local ingredient = ingredients[ingredientIndex]
          local entry = ingredient.entry;
          local totalStock = entry:GetStock() --+ ingredient:GetStolenStock()
          local modulus = ingredientIndex % lineItems
          item = entry:GetLink().." ["..totalStock.."]"
          if modulus == 1 then
            line = item
          else
            line = line..", "..item
          end
          if modulus == 0 or #ingredients == ingredientIndex then
            recipeTooltip:AddLine(line, "ZoFontGameSmall", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
            --line = ""
          end
          --lineCounter = lineCounter + 1
        end          
     
      end    
      
    end
  else
    ClearTooltip(recipeTooltip)
    ClearTooltip(foodTooltip)
    self.currentToolTipEntry = nil
  end
end

function CookeryWizRecipeList:ShowFoodToolTip(control, state)
  local foodTooltip = self.foodTooltipControl
  if state then
    local data = control.data
    InitializeTooltip(foodTooltip, control, BOTTOMLEFT, data.offsetX, data.offsetY, TOPLEFT)
    foodTooltip:SetLink(data.foodLink)
    if data.subTitle then
      local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
      foodTooltip:AddLine("", "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
      ZO_Tooltip_AddDivider(foodTooltip)
      foodTooltip:AddLine("", "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
      local header = zo_iconTextFormat(data.texture, 48, 48, data.subTitle)
      foodTooltip:AddLine(header, "ZoFontHeader", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
      r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
      for i = 1, #data.unknownBy do
        foodTooltip:AddLine(data.unknownBy[i], "ZoFontGameSmall", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
      end
    end
  else
    ClearTooltip(foodTooltip)
  end  
end
---------------------------------------------------------------------
-- Function: OnListRecipesInitialized
--
-- This function is called when the scrollist of recipes is
-- initialised
---------------------------------------------------------------------
function CookeryWizRecipeList:OnListRecipesInitialized(control)

  trace("CookeryWizRecipeList:OnListRecipesInitialized") 

  if not control then
      trace("RecipeScrollList is nil")
      return
  end
  
  local wrapper = CookeryWizScrollList:new(control)
  wrapper:Initialise(self, control, CW_RECIPE_DATA_TYPE)
  self.recipeScrollList = control
  self.recipeScrollListWrapper = wrapper

end

---------------------------------------------------------------------
-- Function: UpdateList
--
-- This function will populate the scrollist
---------------------------------------------------------------------
function CookeryWizRecipeList:UpdateList()
  if self.recipeScrollListWrapper then
    self.recipeScrollListWrapper:Populate()
  end
end
---------------------------------------------------------------------
-- Function: PopulateMasterRecipes
--
-- This function will populate the table of (filtered) recipes
---------------------------------------------------------------------
function CookeryWizRecipeList:PopulateMasterRecipes(textSearchItems, selectedFilterChoice, selectedFilterLevel, currentQuality, selectedFavouriteFilterIndex)
  trace("CookeryWizRecipeList:PopulateMasterRecipes")
  local characterVars = CookeryWiz:GetSelectedPlayerCharacterVars()

  self.filteredRecipes = {}
  
  -- table of items to cook  
  local lastEntry = nil
  local collapsed = false
  local lastCat = 0
  local newEntry  = nil

  local useAnd = true

  local lastQuality = 0
  local lastMatchQuality = true
  
  local currentPlayer = GetUnitName("player")
  local recipeImprovementLevel = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_LEVEL)
  local recipeQualityLevel = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)  
  
  local masterRecipeCount = CookeryWizRecipeList:GetCount()
  
  --[[
  for i = 1, #cats do
    local cat = cats[i]
    local recipes = cat.recipes
    local recipeCount = #recipes
    --d("["..cat:GetCategory().."] "..cat:GetName().."("..recipeCount..")")
    for j = 1, #recipes do
      local recipeEntry = cat.recipes[j]
      if fn(recipeEntry) then
        break
      end
    end
  end
  ]]--
  
  local cats = self:GetCats()
  for i = 1, #cats do
  --for masterRecipeIndex = 1, masterRecipeCount do
    local cat = cats[i]
    local recipes = cat.recipes  
    for j = 1, #recipes do
      local recipeEntry = cat.recipes[j]

      local masterEntry = recipeEntry --CookeryWizRecipeList:GetEntry(masterRecipeIndex)
      local isKnown = false
      local cookQuantity = 0
      local matchText = false
      local matchCategory = true
      local matchQuality = true
      local matchLevel = true
      local matchCount = 0
      local recipeId = recipeEntry:ItemId()
      -- filter on entered text

      local searchItems = textSearchItems


      for searchItemIndex = 1, #searchItems do
        local searchItem = searchItems[searchItemIndex]

        local i, j = string.find(masterEntry:GetRecipeNameLower(), searchItem, 1, true)
        if i then
          matchCount = matchCount + 1
        end
        
        if matchCount == 0 then
          local ingredients = masterEntry:GetIngredients()
          for ingredientIndex = 1, #ingredients do
            -- each object in array returned from GetIngredients() resembles the folowing:
            -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}              
            local ingredient = ingredients[ingredientIndex]
            local entry = ingredient.entry;
            local i, j = string.find(entry:GetNameLower(), searchItem, 1, true)
            if i then
              matchCount = matchCount + 1
            end       
          end        
        end
      end  
      
      if #searchItems == 0 then
        matchText = true
      elseif useAnd and matchCount == #searchItems then
        matchText = true
      elseif not useAnd and matchCount >= 1 then 
        matchText = true
      end
     
      local matchFavourite = false
      local favouriteIndex = masterEntry:GetFavouriteIndex()
      if selectedFavouriteFilterIndex == 0 or favouriteIndex == selectedFavouriteFilterIndex then
        matchFavourite = true
        --d("Matched "..masterEntry:GetRecipeLink())
      end
      
      -- optimise by only checking if it has not already been filtered out
      if matchText and matchFavourite then
        
        local knownEntry = characterVars.known[tostring(recipeId)]
        if knownEntry then
          isKnown = true
        end
        local cookEntry = CookeryWiz:GetCookEntry(recipeId)
        if cookEntry then
          --d("Found cook entry - q"..cookEntry.quantity)
          cookQuantity = cookEntry.quantity
        end      
        -- Filter on category
        if selectedFilterChoice ~= CW_FILTER_CHOICE_ALL then
          if selectedFilterChoice == CW_FILTER_CHOICE_QUANTITY then
            if cookQuantity <= 0 then
              matchCategory = false
            end          
          elseif selectedFilterChoice == CW_FILTER_CHOICE_KNOWN then
            if not isKnown then        
              matchCategory = false
            end
          elseif selectedFilterChoice == CW_FILTER_CHOICE_UNKNOWN then
             if isKnown then        
              matchCategory = false
            end
          --elseif selectedFilterChoice == CW_FILTER_CHOICE_INGREDIENT then
            --matchCategory = true          
          elseif selectedFilterChoice == CW_FILTER_CHOICE_COOKABLE then
            matchCategory = masterEntry:IsCookable(recipeImprovementLevel, recipeQualityLevel)
          end        
        end    
      end
      
      -- Filter on level of food? { veteran, lower, upper }
      if matchCategory and matchFavourite and selectedFilterLevel then
        --d("Matching on level then quality")
        local foodLevel = masterEntry:GetFoodResultLevel()
        if selectedFilterLevel.champion then
          local championRank = masterEntry:GetFoodResultChampionRank()
          if championRank < selectedFilterLevel.lower or championRank > selectedFilterLevel.upper then
            matchLevel = false          
          end       
        else
          if foodLevel < selectedFilterLevel.lower or foodLevel > selectedFilterLevel.upper then
            matchLevel = false
          end
        end
      end
    
    -- now match on quality
    if matchText and matchCategory and matchLevel and matchFavourite then
      --d("Matching quality")
      local quality = masterEntry:GetFoodResultQuality() 

      if currentQuality[1] == quality or currentQuality[2] == quality or currentQuality[3] == quality then
        --d("Matched Quality"..masterEntry:GetRecipeLink())
        matchQuality = true
      else
        matchQuality = false
      end      
    end
    
    --[[
      -- filter on collapsed
      if masterEntry.cat ~= lastCat  then
        -- check on quality for this cat .. ahhh quality is no longer restricted to a category!
        local quality = masterEntry:GetFoodResultQuality() 

        if currentQuality[1] == quality or currentQuality[2] == quality or currentQuality[3] == quality then
          d("Matched Quality"..masterEntry:GetRecipeLink())
          matchQuality = true
        else
          matchQuality = false
        end
        lastMatchQuality = matchQuality
        local masterCategory

        masterCategory = self:GetCookeryWizRecipeCategory(masterEntry.cat)
        collapsed = masterCategory:IsCollapsed()
        if matchQuality and matchText and matchCategory and matchLevel and matchFavourite then
          lastCat = masterEntry.cat
          trace("Setting category["..masterCategory:GetName().."]-"..masterCategory:GetDataType())
          self.filteredRecipes[#self.filteredRecipes + 1] = masterCategory
        end
      end    
      ]]--
      
     
      
      
      -- if we found a match, then add this master recipe item
      
      if matchQuality and matchText and matchCategory and matchLevel and matchFavourite then
        -- Do we need to display a category in the list first?
        if masterEntry.cat ~= lastCat then
            local masterCategory = self:GetCookeryWizRecipeCategory(masterEntry.cat)
            if masterCategory then
              collapsed = masterCategory:IsCollapsed()    
            end
            lastCat = masterEntry.cat
            --trace("Setting category["..masterCategory:GetName().."]-"..masterCategory:GetDataType())
            self.filteredRecipes[#self.filteredRecipes + 1] = masterCategory    
        end
        if not collapsed then
          --d("Adding"..masterEntry:GetRecipeLink()) 
          self.filteredRecipes[#self.filteredRecipes + 1] = masterEntry
          lastEntry = masterEntry
        end
      end
    end
  end
end


---------------------------------------------------------------------
-- Function: OnSortEntries
--
-- This function is called when the scrollist wants to sort the
-- data
---------------------------------------------------------------------
function CookeryWizRecipeList:OnSortEntries(key, scrollData)
  --[[
  local function SortNameAsc(entryA, entryB)
    return entryA.data.name < entryB.data.name
  end 
  
  table.sort(scrollData, SortNameAsc) 
  self.ingredients = scrollData
  ]]--
end

---------------------------------------------------------------------
-- Function: OnFetchEntries
--
-- This function is called when the scrollist 
-- needs the items to display
---------------------------------------------------------------------
function CookeryWizRecipeList:OnFetchEntries(key)
  trace("CookeryWizRecipeList:OnFetchEntries["..key.."]")
  return self.filteredRecipes
end

---------------------------------------------------------------------
-- Function: OnFetchDataType
--
-- This function is called when the scrollist 
-- needs the datatype details
---------------------------------------------------------------------
function CookeryWizRecipeList:OnFetchDataType(key)
  trace("CookeryWizRecipeList:OnFetchDataType["..key.."]")
  if key == CW_RECIPE_DATA_TYPE then
    return CW_RECIPE_DATA_TYPE, "RecipeRowTemplate", 28
  end
end

---------------------------------------------------------------------
-- Function: OnFetchCategoryDataType
--
-- This function is called when the scrollist 
-- needs the datatype for categories
---------------------------------------------------------------------
function CookeryWizRecipeList:OnFetchCategoryDataType(key)
  trace("CookeryWizRecipeList:OnFetchCategoryDataType["..key.."]")  
  if key == CW_RECIPE_DATA_TYPE then
    return CW_RECIPE_CATEGORY_DATA_TYPE, "RecipeCategoryRowTemplate", 24
  end
end

---------------------------------------------------------------------
-- Function: OnExpand
--
-- This function is called when a category is expanded
---------------------------------------------------------------------
function CookeryWizRecipeList:OnExpand(key, entry)
  trace("OnExpand")
  CookeryWiz:SetCollapsed(entry:GetCategory(), false)
  CookeryWiz:RebuildMasterRecipeScrollList()
end

---------------------------------------------------------------------
-- Function: OnCollapse
--
-- This function is called when a category is collapsed
---------------------------------------------------------------------
function CookeryWizRecipeList:OnCollapse(key, entry)
  trace("OnCollapse")
  CookeryWiz:SetCollapsed(entry:GetCategory(), true)
  CookeryWiz:RebuildMasterRecipeScrollList()
end

------------------------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: ConstructMasterList
--
-- This function is called to construct the master list of recipes
-- It is still needed for sending recipes via mail (should fix that)
---------------------------------------------------------------------
function CookeryWizRecipeList:ConstructMasterList()
  local lastCatIndex = 0
  local lastCookeryWizRecipeCategory = nil
  local i
  
  local cats = self:GetCats() 
  masterRecipeList = {}
  local j

  for i = 1, #cats do
    local cat = cats[i]
    local masterRecipeCategory = CookeryWizRecipeCategory:set(cat)
    masterRecipeCategory:Initialise(i, self, tally)    
    for j = 1, #cat.recipes do
      local recipe = cat.recipes[j]
      self:AppendMasterList(recipe, i, false)
      --CookeryWizRecipeEntry:set(recipe, i, false)       
    end
  end 
end

---------------------------------------------------------------------
-- Function: AppendMasterList
--
-- This function is called to append to the master recipe list
-- if validate is passed it check to see if it exists before adding
---------------------------------------------------------------------
function CookeryWizRecipeList:AppendMasterList(recipe, recipeListIndex, validate)
  local entry
  if validate then
    entry = self:GetEntryById(recipe.id)
    if entry then
      return entry
    end    
  end
  
  local masterRecipeListIndex = #masterRecipeList
  CookeryWizRecipeEntry:set(recipe, recipeListIndex, masterRecipeListIndex)
  masterRecipeList[masterRecipeListIndex + 1] = recipe
  
  return recipe
end
---------------------------------------------------------------------
-- Function: GetCookeryWizRecipeCategory
--
-- This function gets the category of recipes specified
-- If the cat index is invalid it will return nil
---------------------------------------------------------------------
function CookeryWizRecipeList:GetCookeryWizRecipeCategory(cat)
  local cats = self:GetCats()
  if cat > #cats then
    return nil
  end
  return cats[cat]
end


function CookeryWizRecipeList:Initialize()
  trace("CookeryWizRecipeList:Initialize")
  self.isIntialised = true
  
  -- construct the 
  self:ConstructMasterList()

end


--[[
function CookeryWizRecipeList.OnAddOnLoaded(event, addonName)
  if addonName == CookeryWizRecipeList.name then
    CookeryWizRecipeList:Initialize()
  end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(CookeryWizRecipeList.name, EVENT_ADD_ON_LOADED, CookeryWizRecipeList.OnAddOnLoaded)
]]--
---------------------------------------------------------------------------
-- Forget below here
---------------------------------------------------------------------------

recipeData = {
                    ["lastIndex"] = 153628,
                    ["recipeCount"] = 568,
                    ["cats"] = 
                    {
                        [1] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56964,
                                },
                                [2] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 45968,
                                },
                                [3] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56961,
                                },
                                [4] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45900,
                                },
                                [5] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45933,
                                },
                                [6] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45909,
                                },
                                [7] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45903,
                                },
                                [8] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45950,
                                },
                                [9] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45935,
                                },
                                [10] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57000,
                                },
                                [11] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 45956,
                                },
                                [12] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 56974,
                                },
                                [13] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 56989,
                                },
                                [14] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45930,
                                },
                                [15] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45888,
                                },
                                [16] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45891,
                                },
                                [17] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68189,
                                },
                                [18] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45938,
                                },
                                [19] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 56977,
                                },
                                [20] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45953,
                                },
                                [21] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45941,
                                },
                                [22] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 56986,
                                },
                                [23] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68191,
                                },
                                [24] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45959,
                                },
                                [25] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 45965,
                                },
                                [26] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68190,
                                },
                                [27] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 56999,
                                },
                                [28] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45944,
                                },
                                [29] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56948,
                                },
                                [30] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45921,
                                },
                                [31] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45894,
                                },
                                [32] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45911,
                                },
                                [33] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45915,
                                },
                                [34] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45927,
                                },
                                [35] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45906,
                                },
                                [36] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45962,
                                },
                                [37] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45897,
                                },
                                [38] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56951,
                                },
                                [39] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45918,
                                },
                                [40] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 56998,
                                },
                                [41] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45947,
                                },
                                [42] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45924,
                                },
                            },
                        },
                        [2] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45957,
                                },
                                [2] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45889,
                                },
                                [3] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45919,
                                },
                                [4] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45913,
                                },
                                [5] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 57002,
                                },
                                [6] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45942,
                                },
                                [7] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45928,
                                },
                                [8] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45904,
                                },
                                [9] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45907,
                                },
                                [10] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45910,
                                },
                                [11] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 56987,
                                },
                                [12] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45931,
                                },
                                [13] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45898,
                                },
                                [14] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68192,
                                },
                                [15] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 45969,
                                },
                                [16] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45922,
                                },
                                [17] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57003,
                                },
                                [18] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45925,
                                },
                                [19] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45936,
                                },
                                [20] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45951,
                                },
                                [21] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 56975,
                                },
                                [22] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 56988,
                                },
                                [23] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 57001,
                                },
                                [24] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56949,
                                },
                                [25] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56962,
                                },
                                [26] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45963,
                                },
                                [27] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45892,
                                },
                                [28] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56963,
                                },
                                [29] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 45966,
                                },
                                [30] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 56976,
                                },
                                [31] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45901,
                                },
                                [32] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45895,
                                },
                                [33] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45939,
                                },
                                [34] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45948,
                                },
                                [35] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 56946,
                                },
                                [36] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45960,
                                },
                                [37] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45954,
                                },
                                [38] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45945,
                                },
                                [39] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56950,
                                },
                                [40] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68193,
                                },
                                [41] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68194,
                                },
                                [42] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45916,
                                },
                            },
                        },
                        [3] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45899,
                                },
                                [2] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 56978,
                                },
                                [3] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45912,
                                },
                                [4] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45896,
                                },
                                [5] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45946,
                                },
                                [6] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45914,
                                },
                                [7] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68196,
                                },
                                [8] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45893,
                                },
                                [9] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45887,
                                },
                                [10] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56952,
                                },
                                [11] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45929,
                                },
                                [12] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45958,
                                },
                                [13] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56966,
                                },
                                [14] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45926,
                                },
                                [15] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45905,
                                },
                                [16] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 56991,
                                },
                                [17] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45917,
                                },
                                [18] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45937,
                                },
                                [19] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68195,
                                },
                                [20] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45955,
                                },
                                [21] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45952,
                                },
                                [22] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45923,
                                },
                                [23] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57006,
                                },
                                [24] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 45967,
                                },
                                [25] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45943,
                                },
                                [26] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45949,
                                },
                                [27] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45940,
                                },
                                [28] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45902,
                                },
                                [29] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45934,
                                },
                                [30] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45908,
                                },
                                [31] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56965,
                                },
                                [32] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 56990,
                                },
                                [33] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45920,
                                },
                                [34] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45890,
                                },
                                [35] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 57004,
                                },
                                [36] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68197,
                                },
                                [37] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 57005,
                                },
                                [38] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56953,
                                },
                                [39] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 45932,
                                },
                                [40] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 56979,
                                },
                                [41] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45961,
                                },
                                [42] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 45964,
                                },
                            },
                        },
                        [4] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45639,
                                },
                                [2] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45681,
                                },
                                [3] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45711,
                                },
                                [4] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45672,
                                },
                                [5] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45685,
                                },
                                [6] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45699,
                                },
                                [7] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 56955,
                                },
                                [8] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56993,
                                },
                                [9] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57009,
                                },
                                [10] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56982,
                                },
                                [11] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45646,
                                },
                                [12] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56994,
                                },
                                [13] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 56969,
                                },
                                [14] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 56968,
                                },
                                [15] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45678,
                                },
                                [16] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45717,
                                },
                                [17] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57008,
                                },
                                [18] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68199,
                                },
                                [19] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45636,
                                },
                                [20] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45693,
                                },
                                [21] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68198,
                                },
                                [22] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45657,
                                },
                                [23] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 56956,
                                },
                                [24] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45705,
                                },
                                [25] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45688,
                                },
                                [26] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45642,
                                },
                                [27] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45664,
                                },
                                [28] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45649,
                                },
                                [29] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45675,
                                },
                                [30] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45654,
                                },
                                [31] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45667,
                                },
                                [32] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56981,
                                },
                                [33] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68200,
                                },
                                [34] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57007,
                                },
                                [35] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45652,
                                },
                                [36] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45660,
                                },
                            },
                        },
                        [5] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45703,
                                },
                                [2] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45682,
                                },
                                [3] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45640,
                                },
                                [4] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45655,
                                },
                                [5] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68203,
                                },
                                [6] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57011,
                                },
                                [7] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 56967,
                                },
                                [8] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45645,
                                },
                                [9] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45651,
                                },
                                [10] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45666,
                                },
                                [11] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68202,
                                },
                                [12] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56983,
                                },
                                [13] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45715,
                                },
                                [14] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45709,
                                },
                                [15] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56995,
                                },
                                [16] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45663,
                                },
                                [17] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45684,
                                },
                                [18] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57010,
                                },
                                [19] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 54243,
                                },
                                [20] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45670,
                                },
                                [21] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45697,
                                },
                                [22] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56980,
                                },
                                [23] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 56957,
                                },
                                [24] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45687,
                                },
                                [25] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45661,
                                },
                                [26] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45679,
                                },
                                [27] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 56970,
                                },
                                [28] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 56954,
                                },
                                [29] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45637,
                                },
                                [30] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45658,
                                },
                                [31] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45648,
                                },
                                [32] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57012,
                                },
                                [33] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68201,
                                },
                                [34] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45676,
                                },
                                [35] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45643,
                                },
                                [36] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56992,
                                },
                            },
                        },
                        [6] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45668,
                                },
                                [2] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45665,
                                },
                                [3] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57015,
                                },
                                [4] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 56958,
                                },
                                [5] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45695,
                                },
                                [6] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57013,
                                },
                                [7] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68204,
                                },
                                [8] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45653,
                                },
                                [9] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 56972,
                                },
                                [10] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 56984,
                                },
                                [11] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45686,
                                },
                                [12] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45718,
                                },
                                [13] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45644,
                                },
                                [14] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45674,
                                },
                                [15] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68205,
                                },
                                [16] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45662,
                                },
                                [17] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45647,
                                },
                                [18] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45683,
                                },
                                [19] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 56985,
                                },
                                [20] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45638,
                                },
                                [21] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 56997,
                                },
                                [22] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68206,
                                },
                                [23] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45641,
                                },
                                [24] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45677,
                                },
                                [25] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 56959,
                                },
                                [26] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45680,
                                },
                                [27] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 56996,
                                },
                                [28] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 56971,
                                },
                                [29] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45712,
                                },
                                [30] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45700,
                                },
                                [31] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45650,
                                },
                                [32] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45706,
                                },
                                [33] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45689,
                                },
                                [34] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45656,
                                },
                                [35] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57014,
                                },
                                [36] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45659,
                                },
                            },
                        },
                        [7] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 54371,
                                },
                                [2] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 68207,
                                },
                                [3] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45707,
                                },
                                [4] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 56943,
                                },
                                [5] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45671,
                                },
                                [6] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45791,
                                },
                                [7] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45708,
                                },
                                [8] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 54369,
                                },
                                [9] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45692,
                                },
                                [10] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 45719,
                                },
                                [11] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45696,
                                },
                                [12] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45702,
                                },
                                [13] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 68208,
                                },
                                [14] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 68209,
                                },
                                [15] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 56973,
                                },
                                [16] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45690,
                                },
                                [17] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45673,
                                },
                                [18] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45710,
                                },
                                [19] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 45714,
                                },
                                [20] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 56947,
                                },
                                [21] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45704,
                                },
                                [22] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45698,
                                },
                                [23] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45694,
                                },
                                [24] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 56945,
                                },
                                [25] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 56944,
                                },
                                [26] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45716,
                                },
                                [27] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57016,
                                },
                                [28] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45701,
                                },
                                [29] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45713,
                                },
                                [30] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 54370,
                                },
                                [31] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 68210,
                                },
                            },
                        },
                        [8] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 57062,
                                },
                                [2] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 46051,
                                },
                                [3] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 57056,
                                },
                                [4] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45984,
                                },
                                [5] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45971,
                                },
                                [6] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57020,
                                },
                                [7] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45972,
                                },
                                [8] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57023,
                                },
                                [9] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68212,
                                },
                                [10] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 46048,
                                },
                                [11] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 57063,
                                },
                                [12] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45974,
                                },
                                [13] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45982,
                                },
                                [14] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57047,
                                },
                                [15] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45993,
                                },
                                [16] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45978,
                                },
                                [17] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45988,
                                },
                                [18] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45992,
                                },
                                [19] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45975,
                                },
                                [20] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68211,
                                },
                                [21] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45990,
                                },
                                [22] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68213,
                                },
                                [23] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45981,
                                },
                                [24] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45985,
                                },
                                [25] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45994,
                                },
                                [26] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45995,
                                },
                                [27] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45970,
                                },
                                [28] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45991,
                                },
                                [29] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57064,
                                },
                                [30] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 46035,
                                },
                                [31] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45980,
                                },
                                [32] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57044,
                                },
                                [33] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45977,
                                },
                                [34] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 45987,
                                },
                                [35] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 57032,
                                },
                                [36] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45976,
                                },
                                [37] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45986,
                                },
                                [38] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 46054,
                                },
                                [39] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45989,
                                },
                                [40] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45979,
                                },
                                [41] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45973,
                                },
                                [42] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57035,
                                },
                            },
                        },
                        [9] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 46049,
                                },
                                [2] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 46055,
                                },
                                [3] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 46007,
                                },
                                [4] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 46000,
                                },
                                [5] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57034,
                                },
                                [6] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57045,
                                },
                                [7] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 46015,
                                },
                                [8] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 57065,
                                },
                                [9] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 46011,
                                },
                                [10] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57067,
                                },
                                [11] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 57057,
                                },
                                [12] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 46017,
                                },
                                [13] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 46009,
                                },
                                [14] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68214,
                                },
                                [15] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45998,
                                },
                                [16] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45996,
                                },
                                [17] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 57033,
                                },
                                [18] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 46052,
                                },
                                [19] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45997,
                                },
                                [20] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 46002,
                                },
                                [21] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 46019,
                                },
                                [22] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 46006,
                                },
                                [23] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 46008,
                                },
                                [24] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57046,
                                },
                                [25] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68216,
                                },
                                [26] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 46021,
                                },
                                [27] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 57066,
                                },
                                [28] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 46003,
                                },
                                [29] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 46014,
                                },
                                [30] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 46018,
                                },
                                [31] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68215,
                                },
                                [32] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45999,
                                },
                                [33] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 46012,
                                },
                                [34] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 46005,
                                },
                                [35] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57021,
                                },
                                [36] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 46016,
                                },
                                [37] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 46001,
                                },
                                [38] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 46020,
                                },
                                [39] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 46010,
                                },
                                [40] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 46004,
                                },
                                [41] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57022,
                                },
                                [42] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 46013,
                                },
                            },
                        },
                        [10] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 46032,
                                },
                                [2] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 46045,
                                },
                                [3] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 46028,
                                },
                                [4] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 46033,
                                },
                                [5] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 46030,
                                },
                                [6] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 46027,
                                },
                                [7] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 46047,
                                },
                                [8] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 46046,
                                },
                                [9] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57037,
                                },
                                [10] = 
                                {
                                    ["index"] = 40,
                                    ["id"] = 68217,
                                },
                                [11] = 
                                {
                                    ["index"] = 39,
                                    ["id"] = 57070,
                                },
                                [12] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 46022,
                                },
                                [13] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 46036,
                                },
                                [14] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 46037,
                                },
                                [15] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 46023,
                                },
                                [16] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 46050,
                                },
                                [17] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 46040,
                                },
                                [18] = 
                                {
                                    ["index"] = 42,
                                    ["id"] = 68219,
                                },
                                [19] = 
                                {
                                    ["index"] = 37,
                                    ["id"] = 57068,
                                },
                                [20] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57025,
                                },
                                [21] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 46025,
                                },
                                [22] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45983,
                                },
                                [23] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 57036,
                                },
                                [24] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 46041,
                                },
                                [25] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 46034,
                                },
                                [26] = 
                                {
                                    ["index"] = 38,
                                    ["id"] = 57069,
                                },
                                [27] = 
                                {
                                    ["index"] = 41,
                                    ["id"] = 68218,
                                },
                                [28] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 46038,
                                },
                                [29] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 46029,
                                },
                                [30] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 46056,
                                },
                                [31] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 46039,
                                },
                                [32] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 46031,
                                },
                                [33] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 46053,
                                },
                                [34] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57048,
                                },
                                [35] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57049,
                                },
                                [36] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57024,
                                },
                                [37] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 46043,
                                },
                                [38] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 46026,
                                },
                                [39] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 46024,
                                },
                                [40] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 57058,
                                },
                                [41] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 46042,
                                },
                                [42] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 46044,
                                },
                            },
                        },
                        [11] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45548,
                                },
                                [2] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45542,
                                },
                                [3] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 57038,
                                },
                                [4] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57059,
                                },
                                [5] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68222,
                                },
                                [6] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 54242,
                                },
                                [7] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45551,
                                },
                                [8] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45541,
                                },
                                [9] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57073,
                                },
                                [10] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45539,
                                },
                                [11] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 54241,
                                },
                                [12] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45552,
                                },
                                [13] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45555,
                                },
                                [14] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68221,
                                },
                                [15] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57050,
                                },
                                [16] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45553,
                                },
                                [17] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57053,
                                },
                                [18] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45540,
                                },
                                [19] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45564,
                                },
                                [20] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45631,
                                },
                                [21] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68220,
                                },
                                [22] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45556,
                                },
                                [23] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45560,
                                },
                                [24] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45546,
                                },
                                [25] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57071,
                                },
                                [26] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45563,
                                },
                                [27] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45559,
                                },
                                [28] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45554,
                                },
                                [29] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45561,
                                },
                                [30] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45544,
                                },
                                [31] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 57029,
                                },
                                [32] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45543,
                                },
                                [33] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 57041,
                                },
                                [34] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45562,
                                },
                                [35] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 57026,
                                },
                                [36] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57072,
                                },
                            },
                        },
                        [12] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45580,
                                },
                                [2] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45622,
                                },
                                [3] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 57028,
                                },
                                [4] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45569,
                                },
                                [5] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68224,
                                },
                                [6] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 45633,
                                },
                                [7] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45574,
                                },
                                [8] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45590,
                                },
                                [9] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45589,
                                },
                                [10] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68225,
                                },
                                [11] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45571,
                                },
                                [12] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45582,
                                },
                                [13] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45570,
                                },
                                [14] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45568,
                                },
                                [15] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57074,
                                },
                                [16] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45592,
                                },
                                [17] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57051,
                                },
                                [18] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45579,
                                },
                                [19] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57052,
                                },
                                [20] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45604,
                                },
                                [21] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57060,
                                },
                                [22] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57075,
                                },
                                [23] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45572,
                                },
                                [24] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45591,
                                },
                                [25] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 57039,
                                },
                                [26] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 57027,
                                },
                                [27] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45587,
                                },
                                [28] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57076,
                                },
                                [29] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45627,
                                },
                                [30] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45567,
                                },
                                [31] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45584,
                                },
                                [32] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45583,
                                },
                                [33] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45581,
                                },
                                [34] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 57040,
                                },
                                [35] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68223,
                                },
                                [36] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45588,
                                },
                            },
                        },
                        [13] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 45617,
                                },
                                [2] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 57077,
                                },
                                [3] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45608,
                                },
                                [4] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 45607,
                                },
                                [5] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45610,
                                },
                                [6] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45576,
                                },
                                [7] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 57031,
                                },
                                [8] = 
                                {
                                    ["index"] = 36,
                                    ["id"] = 68228,
                                },
                                [9] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45615,
                                },
                                [10] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45597,
                                },
                                [11] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45616,
                                },
                                [12] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 57042,
                                },
                                [13] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 57054,
                                },
                                [14] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 57061,
                                },
                                [15] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 45614,
                                },
                                [16] = 
                                {
                                    ["index"] = 34,
                                    ["id"] = 68226,
                                },
                                [17] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45600,
                                },
                                [18] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 45609,
                                },
                                [19] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 45594,
                                },
                                [20] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45624,
                                },
                                [21] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 57030,
                                },
                                [22] = 
                                {
                                    ["index"] = 32,
                                    ["id"] = 57078,
                                },
                                [23] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45598,
                                },
                                [24] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45618,
                                },
                                [25] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45596,
                                },
                                [26] = 
                                {
                                    ["index"] = 35,
                                    ["id"] = 68227,
                                },
                                [27] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 57055,
                                },
                                [28] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45602,
                                },
                                [29] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45612,
                                },
                                [30] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 57043,
                                },
                                [31] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45611,
                                },
                                [32] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 45629,
                                },
                                [33] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 45535,
                                },
                                [34] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45619,
                                },
                                [35] = 
                                {
                                    ["index"] = 33,
                                    ["id"] = 57079,
                                },
                                [36] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 45595,
                                },
                            },
                        },
                        [14] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 46079,
                                },
                                [2] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 45620,
                                },
                                [3] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 57019,
                                },
                                [4] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 45577,
                                },
                                [5] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 45621,
                                },
                                [6] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 45545,
                                },
                                [7] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 45549,
                                },
                                [8] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 57017,
                                },
                                [9] = 
                                {
                                    ["index"] = 20,
                                    ["id"] = 45632,
                                },
                                [10] = 
                                {
                                    ["index"] = 21,
                                    ["id"] = 45625,
                                },
                                [11] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 45575,
                                },
                                [12] = 
                                {
                                    ["index"] = 23,
                                    ["id"] = 45626,
                                },
                                [13] = 
                                {
                                    ["index"] = 31,
                                    ["id"] = 68232,
                                },
                                [14] = 
                                {
                                    ["index"] = 22,
                                    ["id"] = 45628,
                                },
                                [15] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 45691,
                                },
                                [16] = 
                                {
                                    ["index"] = 25,
                                    ["id"] = 45557,
                                },
                                [17] = 
                                {
                                    ["index"] = 30,
                                    ["id"] = 68231,
                                },
                                [18] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 45603,
                                },
                                [19] = 
                                {
                                    ["index"] = 19,
                                    ["id"] = 45573,
                                },
                                [20] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 57018,
                                },
                                [21] = 
                                {
                                    ["index"] = 27,
                                    ["id"] = 45634,
                                },
                                [22] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 46082,
                                },
                                [23] = 
                                {
                                    ["index"] = 28,
                                    ["id"] = 68229,
                                },
                                [24] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 45565,
                                },
                                [25] = 
                                {
                                    ["index"] = 24,
                                    ["id"] = 45599,
                                },
                                [26] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 45601,
                                },
                                [27] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 45547,
                                },
                                [28] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 46081,
                                },
                                [29] = 
                                {
                                    ["index"] = 29,
                                    ["id"] = 68230,
                                },
                                [30] = 
                                {
                                    ["index"] = 18,
                                    ["id"] = 45623,
                                },
                                [31] = 
                                {
                                    ["index"] = 26,
                                    ["id"] = 45630,
                                },
                            },
                        },
                        [15] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["id"] = 120077,
                                },
                                [2] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 96966,
                                },
                                [3] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 96965,
                                },
                                [4] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 87684,
                                },
                                [5] = 
                                {
                                    ["id"] = 153624,
                                },
                                [6] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 87698,
                                },
                                [7] = 
                                {
                                    ["id"] = 120769,
                                },
                                [8] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 87692,
                                },
                                [9] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 96968,
                                },
                                [10] = 
                                {
                                    ["id"] = 115029,
                                },
                                [11] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 71060,
                                },
                                [12] = 
                                {
                                    ["index"] = 17,
                                    ["id"] = 153626,
                                },
                                [13] = 
                                {
                                    ["index"] = 1,
                                    ["id"] = 64223,
                                },
                                [14] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 96960,
                                },
                                [15] = 
                                {
                                    ["id"] = 133552,
                                },
                                [16] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 87688,
                                },
                                [17] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 87694,
                                },
                            },
                        },
                        [16] = 
                        {
                            ["recipes"] = 
                            {
                                [1] = 
                                {
                                    ["index"] = 13,
                                    ["id"] = 96961,
                                },
                                [2] = 
                                {
                                    ["id"] = 139012,
                                },
                                [3] = 
                                {
                                    ["id"] = 139017,
                                },
                                [4] = 
                                {
                                    ["id"] = 153628,
                                },
                                [5] = 
                                {
                                    ["index"] = 15,
                                    ["id"] = 120768,
                                },
                                [6] = 
                                {
                                    ["id"] = 133553,
                                },
                                [7] = 
                                {
                                    ["index"] = 6,
                                    ["id"] = 87683,
                                },
                                [8] = 
                                {
                                    ["index"] = 7,
                                    ["id"] = 87689,
                                },
                                [9] = 
                                {
                                    ["id"] = 133551,
                                },
                                [10] = 
                                {
                                    ["index"] = 8,
                                    ["id"] = 87693,
                                },
                                [11] = 
                                {
                                    ["index"] = 10,
                                    ["id"] = 96964,
                                },
                                [12] = 
                                {
                                    ["index"] = 16,
                                    ["id"] = 120770,
                                },
                                [13] = 
                                {
                                    ["index"] = 9,
                                    ["id"] = 96967,
                                },
                                [14] = 
                                {
                                    ["index"] = 11,
                                    ["id"] = 96963,
                                },
                                [15] = 
                                {
                                    ["index"] = 3,
                                    ["id"] = 71062,
                                },
                                [16] = 
                                {
                                    ["index"] = 4,
                                    ["id"] = 71063,
                                },
                                [17] = 
                                {
                                    ["index"] = 2,
                                    ["id"] = 71061,
                                },
                                [18] = 
                                {
                                    ["index"] = 14,
                                    ["id"] = 120767,
                                },
                                [19] = 
                                {
                                    ["index"] = 12,
                                    ["id"] = 96962,
                                },
                                [20] = 
                                {
                                    ["index"] = 5,
                                    ["id"] = 87682,
                                },
                            },
                        },
                    },
                }
               
               