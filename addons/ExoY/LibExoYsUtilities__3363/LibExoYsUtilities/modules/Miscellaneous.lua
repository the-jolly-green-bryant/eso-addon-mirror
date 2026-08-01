LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities


--[[ ----------------------- ]]
--[[ -- Predefined Colors -- ]]
--[[ ----------------------- ]]

local colorTable = {
  ["orange"] = "FF8800", 
  ["gray"] = "8F8F8F",
  ["cyan"] = "00FFFF",
  ["red"] = "ff0000",
  ["green"] = "00ff00", 
} 


function LibExoY.ColorHex( color )
  if LibExoY.IsString( color ) then 
    return colorTable[color] or color 
  elseif LibExoY.IsTable( color ) then 
    return ZO_ColorDef.FloatsToHex( unpack(color) )
  else 
    return "FFFFFF"
  end
end


--[[ ------------------------- ]]
--[[ -- Check Variable Type -- ]]
--[[ ------------------------- ]]

function LibExoY.IsTable( t )
  return type(t) == "table"
end

function LibExoY.IsFunc( f )
  return type(f) == "function"
end

function LibExoY.IsString( s ) 
  return type(s) == "string"
end

function LibExoY.IsNumber( n ) 
  return type(n) == "number"
end

function LibExoY.IsBool( b ) 
  return type(b) == "boolean" 
end

function LibExoY.IsNil( v ) 
  return type(v) == "nil" 
end

function LibExoY.IsTrue( b , ...) 
  if LibExoY.IsBool(b) then return b end
  if LibExoY.IsFunc(b) then 
    local c = b( ... )
    if LibExoY.IsBool( c ) then return c end
  end
  return nil
end

--[[ ------------------------- ]]
--[[ -- Eso Specific Checks -- ]]
--[[ ------------------------- ]]

function LibExoY.IsAccount( s )
  if LibExoY.IsString(s) then 
    return string.find(s, "@") ~= nil
  end
end


--[[ -------------------------- ]]
--[[ -- Custom Function Call -- ]]
--[[ -------------------------- ]]


function LibExoY.SecureAuthCall( auth, f, ...) 
  if LibExoY.IsTrue(auth) then return LibExoY.SecureCall( f, ...) end
end


function LibExoY.AuthCall( auth, f, ...) 
  if LibExoY.IsTrue(auth) then return f(...) end 
end 


function LibExoY.SecureCall( f, ... ) 
  if LibExoY.IsFunc(f) then 
    f(...) 
  end
end



--[[ ---------------------- ]]
--[[ -- String Functions -- ]]
--[[ ---------------------- ]]

function LibExoY.IsEmptyString(s) 
  if s == "" then return true end 
end 

-- todo, check if string only consists of spaces 
function LibExoY.IsStringEmpty(s, allowSpaces) 
  if LibExoY.IsString(s) then 
    -- check if empty string
    if s == "" then return true 
    -- if not empty, but only spaces are ok
    elseif allowSpaces then return false 
    -- check if all are spaces 
    else  
      local nonSpacePosition = string.find(s, "%S")
      return not LibExoY.IsNumber(nonSpacePosition)
    end   
  else 
    ---debug?
    return  
  end
end

function LibExoY.StartsWithSpace(s)
  if LibExoY.IsString(s) then 
    return string.sub(s,1,1) == " "
  else 
    ---debug? 
    return
  end
end


--[[ --------------------- ]]
--[[ -- Table Functions -- ]]
--[[ --------------------- ]]

-- /Media.lua/LibExoY.GetOutlineNumber()
-- /Media.lua/LibExoY.GetFontNumber()
-- /SavedVariables/PM:GetIdByName()


-- finds the key k, which has the entry e (unsure about table support) 
-- if value is not found then default value d is returned
function LibExoY.FindNumericKey(t, e, d) 
  for k,v in ipairs(t) do
    if e == v then 
      return k
    end
  end
  return d 
end 


function LibExoY.VerifyHashTable(t, e) 
  if not LibExoY.IsTable(t) then return false end 
  for _,ev in ipairs(e) do 
    if not t[ev] then return false end
  end
  return true
end

-- returns >true> if duplicate string is found in t
-- only applicable to tables containing strings 
-- if "cases" is true, than capitalization is considered
--  e.g.  cases = true  ->  "Dog" and "dog" are not! duplicates
--        cases = false ->  "Dog" and "dog" are duplicates 
function LibExoY.HasDuplicateString(t, s, cases) 
  local d = false
  for _,v in pairs(t) do 
    if cases then 
      if v == s then d = true break end
    else 
      if string.lower(v) == string.lower(s) then d = true break end
    end
  end
  return d 
end
-- /script d(LibExoYsUtilities.CheckDuplicateString({"Dog", "Cat"},"dog"))