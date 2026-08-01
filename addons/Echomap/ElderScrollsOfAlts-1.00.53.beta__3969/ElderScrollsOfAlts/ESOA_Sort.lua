--[[ ESOA UI SORT ]]-- 
 
----------------------------------------
-- ESOA GUI/UI SORTING Functions
----------------------------------------


------------------------------
-- Sort
local charSortKeys =
  {
    ["name"]          = { }, 
    ["super"]         = { tiebreaker = "name" }, 
    ["special"]       = { tiebreaker = "name" }, 
    ["alliance"]      = { tiebreaker = "name" },        
    ["class"]         = { tiebreaker = "name" },    
    ["level"]         = { tiebreaker = "name", isNumeric = true },    
    ["gender"]        = { tiebreaker = "name" },    
    ["race"]          = { tiebreaker = "name" },    
    ["alchemy"]       = { tiebreaker = "name", isNumeric = true },    
    ["blacksmithing"] = { tiebreaker = "name", isNumeric = true },    
    ["smithing"]      = { tiebreaker = "name", isNumeric = true },    
    ["clothing"]      = { tiebreaker = "name", isNumeric = true },    
    ["enchanting"]    = { tiebreaker = "name", isNumeric = true },    
    ["provisioning"]  = { tiebreaker = "name", isNumeric = true },    
    ["jewelry"]       = { tiebreaker = "name", isNumeric = true },    
    ["woodworking"]   = { tiebreaker = "name", isNumeric = true },    
    ["backpackSize"]  = { tiebreaker = "name", isNumeric = false },        
    ["backpackFree"]  = { tiebreaker = "name", isNumeric = true },        
    ["skillPoints"]   = { tiebreaker = "name", isNumeric = true },        
    ["rwoodworking1S"]   = { tiebreaker = "name", isNumeric = false },
    ["rwoodworking2S"]   = { tiebreaker = "name", isNumeric = false },
    ["rwoodworking3S"]   = { tiebreaker = "name", isNumeric = false },
    ["Legerdemain_Rank"]   = { tiebreaker = "name", isNumeric = true },
    ["riding_timeMs"]   = { tiebreaker = "name", isNumeric = true },
    ["currency_gold"]   = { tiebreaker = "name", isNumeric = true },
  }

------------------------------
-- Sort
function ElderScrollsOfAlts.SortCharData(a, b)
    ElderScrollsOfAlts.debugMsg("SortCharData: aK="..tostring(a[ElderScrollsOfAlts.view.currentSortKey]).. " bK="..tosting(b[ElderScrollsOfAlts.view.currentSortKey]) )
    return a[ElderScrollsOfAlts.view.currentSortKey] < b[ElderScrollsOfAlts.view.currentSortKey]
  --return ZO_TableOrderingFunction( a.data, b.data, ElderScrollsOfAlts.view.currentSortKey, charSortKeys, ElderScrollsOfAlts.view.currentSortOrder)
end

------------------------------
-- Sort
function ElderScrollsOfAlts:GuiSortCharBase(newKey,refreshOnly,sender)
  ElderScrollsOfAlts:debugMsg("GuiSortCharBase newKey="..tostring(newKey) )
end
  
------------------------------
--EOF