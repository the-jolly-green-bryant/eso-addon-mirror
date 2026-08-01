
CookeryWizUtils = {}

CookeryWizUtils.traceEnabled = false

local L = CookeryWizLanguage.language

local function trace(msg)
  if CookeryWizUtils.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

-- Helper function to split a string into a table object
function split(str, delim)
    local res = {}
    local pattern = string.format("([^%s]+)%s", delim, delim)
    for line in str:gmatch(pattern) do
        table.insert(res, line)
    end
    return res
end

---------------------------------------------------------------------
-- Function: GetFavouriteTextureFile
--
-- This function gets the texture file for the corresponding favourite
-- type
---------------------------------------------------------------------
function CookeryWizUtils:GetFavouriteTextureFile(favouriteTypeIndex)
  local textureFile = "CookeryWiz/Graphics/fav".. favouriteTypeIndex.. ".dds"
  return textureFile
end


---------------------------------------------------------------------
-- Function: SetToLinkQualityColor
--
-- This function sets the text to the quality color of the link and
-- returns the string
---------------------------------------------------------------------
function CookeryWizUtils:SetToLinkQualityColor(link, text)
  local quality =  GetItemLinkQuality(link)
  return self:SetToQualityColor(quality, text)
end

---------------------------------------------------------------------
-- Function: SetToQualityColor
--
-- This function sets the text to the quality color of the link and
-- returns the string
---------------------------------------------------------------------
function CookeryWizUtils:SetToQualityColor(quality, text)
  local colorDef = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
  return colorDef:Colorize(text)  
end

---------------------------------------------------------------------
-- Function: Trace
--
-- This function outputs a trace message to chat window
---------------------------------------------------------------------
function CookeryWizUtils:Trace(msg)
  d(GetTimeString()..":"..msg)
end


function CookeryWizUtils:SetFont(control, fontSize, face, options)

  local font
  if face == nil or face == "" then
    face = "EsoUI/Common/Fonts/univers57.otf"
  end
  if options and options ~= "" then
      font = ("%s|%s|%s"):format(face, fontSize, options)
  else
    font = ("%s|%s"):format(face, fontSize) 
  end
  control:SetFont(font)
end

function CookeryWizUtils:SendToChat(text)
  local chatEditControl = CHAT_SYSTEM.textEntry.editControl

  if chatEditControl:HasFocus() == false then
    StartChatInput()
  end

  chatEditControl:InsertText(text)
end

function CookeryWizUtils:GetItemID(link)
    if not link then
      return
    end
    local id = select(4,ZO_LinkHandler_ParseLink(link))  
    return tonumber(id)
end

---------------------------------------------------------------------
-- Function: SetupTooltip
--
-- This function sets up standard tooltips for a control
---------------------------------------------------------------------
function CookeryWizUtils:SetupTooltip(control, text)
  
  control:SetHandler("OnMouseEnter", function(control)
      ZO_Tooltips_ShowTextTooltip(control, TOP, text)
      
    end)
  control:SetHandler("OnMouseExit", function(control)
        ZO_Tooltips_HideTextTooltip() 
    end)
end

---------------------------------------------------------------------
-- Function: CenterControl
--
-- This function centers the control against the parent
---------------------------------------------------------------------
function CookeryWizUtils:CenterControl(parentWindow, control)

  if parentWindow and control then
    --d("Centring to parent")
    local dialogWidth = control:GetWidth()
    local dialogHeight = control:GetHeight()
    local parentWidth = parentWindow:GetWidth()
    local parentHeight = parentWindow:GetHeight()
    
    --d("Width:["..dialogWidth.."], Height:["..dialogHeight.."], "..self.parentWindow:GetName())
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, parentWindow, TOPLEFT, (parentWidth/2)-(dialogWidth/2), (parentHeight/2)-(dialogHeight/2)) 
  else
    --d("Not Centering to parent null")
  end  
end

---------------------------------------------------------------------
-- Function: CenterControl
--
-- This function centers the control against the parent
---------------------------------------------------------------------
function CookeryWizUtils:CenterDialog(parentWindow, control)

  if parentWindow and control then
    --d("Centring to parent")
    local dialogWidth = control:GetWidth()
    local dialogHeight = control:GetHeight()
    local parentWidth = parentWindow:GetWidth()
    local parentHeight = parentWindow:GetHeight()
    local parentTop = parentWindow:GetTop()
    local parentLeft = parentWindow:GetLeft()
    
    --d("Width:["..dialogWidth.."], Height:["..dialogHeight.."], "..self.parentWindow:GetName())
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, parentLeft + (parentWidth/2)-(dialogWidth/2), parentTop + (parentHeight/2)-(dialogHeight/2))
    control:SetParent(GuiRoot)
  else
    --d("Not Centering to parent null")
  end  
end



-- Compatible with Lua 5.1 (not 5.0).
function CookeryWizUtils:class(base, init)
   local c = {}    -- a new class instance
   if not init and type(base) == 'function' then
      init = base
      base = nil
   elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
         c[i] = v
      end
      c._base = base
   end
   -- the class will be the metatable for all its objects,
   -- and they will look up their methods in it.
   c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
   local mt = {}
   mt.__call = function(class_tbl, ...)
   local obj = {}
   setmetatable(obj,c)
   if init then
      init(obj,...)
   else 
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
      base.init(obj, ...)
      end
   end
   return obj
   end
   c.init = init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end
      return false
   end
   setmetatable(c, mt)
   return c
end

---------------------------------------------------------------------
-- Function: GetTotalFoodLists
--
-- This function gets the total food related recipes lists in the game
-- It is used to exclude furniture related lists
-- It does assume that the first XX of these lists are food related
-- and that there are no other lists added in the future.
-- If it is extended and becomes non continous then we will deal with it then
--------------------------------------------------------------------
function CookeryWizUtils:GetTotalFoodLists()
  return 16  
end

---------------------------------------------------------------------
-- Function: GetTotalRecipes
--
-- This function gets the total recipes in each list via game
-- It is only calculated once and result cached
--------------------------------------------------------------------

local totalGameRecipes = 0
function CookeryWizUtils:GetTotalRecipes()
  
  if totalGameRecipes == 0 then
    local cat
    local recipeCount = 0 
    local numLists = self:GetTotalFoodLists()
    for cat = 1, numLists do
      local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(cat)
      --d(cat.."-Name[".. name .."]["..numRecipes.."]")
      recipeCount = recipeCount + numRecipes    
    end
    totalGameRecipes = recipeCount
  end
  return totalGameRecipes
end

---------------------------------------------------------------------
-- Function: MaxEncodingBytes
--
-- This function returns the number of bytes needed to encode each
-- recipe category list
--------------------------------------------------------------------

local maxEncodingBytes = 0

function CookeryWizUtils:MaxEncodingBytes()
  if maxEncodingBytes == 0 then
    local numLists = self:GetTotalFoodLists()
    local maxBytes = 0
    
    for cat = 1, numLists do
      local name,numRecipes,upIcon,downIcon,overIcon,disabledIcon,createSound = GetRecipeListInfo(cat)
      if name then
        local bytesNeeded = math.floor(numRecipes / 8) + 1
        if bytesNeeded > maxBytes then
          maxBytes = bytesNeeded
        end
      end
    end
    --d("Max Bytes="..maxBytes)  
    maxEncodingBytes = maxBytes
  end
  return maxEncodingBytes
end

---------------------------------------------------------------------
-- Function: EncodeKnownRecipes
--
-- This function encodes the recipes known by a particular character
--------------------------------------------------------------------
function CookeryWizUtils:EncodeKnownRecipes(known)
  
  local cats = CookeryWizRecipeList:GetCats()
  
  -- Between each release of CookeryWiz, the items in each recipe category have the same order
  -- As we cannot guarentee that we know the matching in-game recipe list index we can use this
  -- order. Of course if the list changes so too should the version of the mail message
  -- Set the version to the recipe count should be enough to guarentee that it will be deconstructed
  -- properly.
  -- However, the known recipes array is not ordered. We will have to use category objects with ordered recipes
  -- by their position in the master list
  
  -- Create an array that will contain the known recipes for each recipe list
  -- Each list will be intialised to an arry of 8 bit (byte) numbers. We will convert each number to hex characters at the end
  -- Each 8 bit number corresponds to 8 recipes. We need enough numbers to handle the max number of recipes in a category
  -- Currently there are no more than 42 recipes in a category. We determine the max bytes needed once in another routine
  local lists = {}
  local numLists = self:GetTotalFoodLists()
  local maxBytes = self:MaxEncodingBytes()
  
  
  for i = 1, numLists do
    local item = {}
    for j = 1, maxBytes do
      item[j] = 0
    end
    lists[#lists + 1] = item
  end
     
  
  -- Go through each known recipe
  -- Currently known recipes are simply stored as a list of recipe IDs
  -- so we look up the corresponding recipe entry
  -- It would be nice to change the known recipes to be grouped into categories
  -- but that would require some work so leave it.
  for key, value in pairs(known) do
    
    local recipeEntry = CookeryWizRecipeList:GetEntryById(value)
    local listIndex = recipeEntry:GetRecipeListIndex()
    local listData = lists[listIndex]
    
    --if listIndex == 11 then
      -- The relative index is from 1 to n. We need it zero based
      local relativeIndex = recipeEntry:GetRelativeIndex() - 1
      local byteIndex = math.floor(relativeIndex / 8) + 1
      local bitNumber = relativeIndex - ( (byteIndex - 1) * 8)
      --d(recipeEntry:GetRecipeLink()..": relIndex="..relativeIndex..", byteIndex="..byteIndex..", bitNumber="..bitNumber..", bit="..(2 ^bitNumber))
      
      -- set the bit of the byte!
      local byte = lists[listIndex][byteIndex]
      lists[listIndex][byteIndex] = byte + (2 ^bitNumber) --setbit(byte, bit(bitNumber))
    --end
  end
  --d(lists)

  -- Now we need to encode the results into an hex string delimited by commas
  local encoded = ""
  for i = 1, numLists do
    local list = lists[i]
    for j = 1, maxBytes do
      local byte = list[j]
      --encoded = encoded.."("..byte..")"..string.format("%02X",byte)
      encoded = encoded..string.format("%02X",byte)
    end
    encoded=encoded..","
  end

--  trace(s)
--  return s 
  --d(encoded)
  return MAIL_COMMAND_KNOWN..","..CookeryWizUtils:GetTotalRecipes()..","..encoded
end


---------------------------------------------------------------------
-- Function: DecodeKnownRecipes
--
-- This function decodes encoded recipes and will return a known recipes
-- object
--------------------------------------------------------------------
function CookeryWizUtils:DecodeKnownRecipes(data)
  local strings = nil
  
  -- is it a string or table
  local dataType = type(data)
  if dataType == "string" then
    trace("Parsing string")
    strings = split(data, ",")
  elseif dataType == "table" then
    trace("Parsing table")
    strings = data
  else
    d("Invalid data type passed to DecodeKnownRecipes")
    return
  end
    
  local version = tonumber(strings[2])
  
  -- is this a valid message
  local recipeCount = CookeryWizUtils:GetTotalRecipes()  
  if version ~= recipeCount then
    d(string.format(L[CWL_NOTIFY_INCORRECT_IMPORT_VERSION], L[CWL_COOKERYWIZ_NAME]))
    return
  end
  
  -- Typical call:  if hasbit(x, bit(3)) then ...
  local function hasbit(x, p)
    return x % (p + p) >= p       
  end

  local cats = CookeryWizRecipeList:GetCats()
  local known = {}
  
  -- each entry in the strings table is comprised of multiple hex character pairs
  local i, j
  -- we skip the type of message and version
  local startStringOffset = 2
  for i = 1 + startStringOffset, #strings do
    local s = strings[i]
    local len = string.len(s)
    
    -- the recipe list catagories are in same order as strings
    local cat = cats[i - startStringOffset]
    local recipeCount = cat:GetRecipeCount()
    local relativeIndex
    local byteData
    local byteIndex = -1
    local from = -1
    
    --d(i.."-["..recipeCount.."]"..s)
    for recipeIndex = 1, recipeCount  do
      local entry = cat:GetRecipe(recipeIndex)
      if (recipeIndex - 1) % 8 == 0 then
        byteIndex = byteIndex + 1
        from = from + 2
        local byteString = s:sub(from, from+1)
        --d("-["..recipeIndex.."] Byte["..byteString.."]")
        byteData = tonumber(byteString,16)
      end
      
      -- zero based bit position we are checking
      local bitNumber = recipeIndex - (byteIndex * 8) - 1
      local bitValue = (2 ^ bitNumber)
      
      if hasbit(byteData, bitValue) then
        -- is known
        local recipeId = entry:ItemId()        
        known[tostring(recipeId)] = recipeId        
      end
      
    end
  end

  return known
end