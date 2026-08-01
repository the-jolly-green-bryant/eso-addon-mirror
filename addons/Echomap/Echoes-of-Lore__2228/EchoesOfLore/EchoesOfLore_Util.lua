-----------------------
---EchoesOfLore_UTIL---
-----------------------

function EchoesOfLore:debugMsg(text)
    if text == nil then
      return
    end  
	if EchoesOfLore.savedVariables.debug then
		d("(" .. EchoesOfLore.name .. ") " .. text);
	end
end
function EchoesOfLore.debugMsg(self,text)
    if text == nil then
      return
    end
    if EchoesOfLore.savedVariables.debug then
      d("(" .. EchoesOfLore.name .. ") " .. text);
    end
end

function EchoesOfLore:getColoredString(color, s)
	local c = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, color))
	return c:Colorize(s)
end

-- Wraps text with a color.
function EchoesOfLore.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = EchoesOfLore.color end
    text = "|c" .. color .. text .. "|r"
    return text
end

--[[
function EchoesOfLore:tabletostring(t)
  d("tabletostring called ")
   for key,value in pairs(t) do print(key,value) end
   for key,value in ipairs(t) do print(key,value) end
end
]]--

function EchoesOfLore:matchStringList(str,itemlist)
  for _, v in ipairs(itemlist) do
      if v == str then
          return true
      end
  end
  return false;
end


--------
--------
--Sort--
local dungeonSortKeys =
  {
    ["name"]          = { }, 
    ["text"]          = { tiebreaker = "name" }, 
    ["order"]         = { tiebreaker = "name", isNumeric = true }, 
  }
  
--Sort
function EchoesOfLore.SortDungeonData(a, b)
  return ZO_TableOrderingFunction( a.data, b.data, "order", dungeonSortKeys, ZO_SORT_ORDER_DOWN )
end
--Sort
function EchoesOfLore.SortDungeonData2(a, b)
  if(a==nil or a.order==nil)then return true end
  if(b==nil or b.order==nil)then return false end
  return a.order < b.order
end

--------
--Sort--
local bossesSortKeys =
  {
    ["name"]          = { }, 
    ["text"]          = { tiebreaker = "name" }, 
    ["order"]         = { tiebreaker = "name", isNumeric = true }, 
  }
  
--Sort
function EchoesOfLore.SortBossesData(a, b)
  return ZO_TableOrderingFunction( a, b, "order", bossesSortKeys, ZO_SORT_ORDER_DOWN )
end
function EchoesOfLore.SortBossesData2(a, b)
  if(a==nil or a.order==nil)then return true end
  if(b==nil or b.order==nil)then return false end
  return a.order<b.order
end

--------
--Sort--
local buttonSortKeys =
  {
    ["name"]          = { }, 
    ["text"]          = { tiebreaker = "name" }, 
    ["order"]         = { tiebreaker = "text", isNumeric = true }, 
  }
  
--Sort
function EchoesOfLore.SortButtonData(a, b)
  return ZO_TableOrderingFunction( a, b, "order", buttonSortKeys, ZO_SORT_ORDER_DOWN )
end

--Sort
local dungeonSortKeys =
  {
    ["name"]          = { }, 
    ["order"]         = { tiebreaker = "name", isNumeric = true }, 
  }
  
--Sort
function EchoesOfLore.SortDungeonData(a, b)
  return ZO_TableOrderingFunction( a.data, b.data, "order", dungeonSortKeys, ZO_SORT_ORDER_DOWN )
end

