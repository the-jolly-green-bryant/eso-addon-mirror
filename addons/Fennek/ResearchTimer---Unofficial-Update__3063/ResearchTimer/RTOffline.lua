--Licence: No restriction and no responsibility
-- Version 1
local dateformat = "%d/%m, %H:%M"

require( "iuplua" )
require( "iupluacontrols" )

dofile "../../SavedVariables/ResearchTimer.lua"

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


for i,_ in pairs(ResearchTimer["Default"]) do -- Only one entry
	myaccount = i
end

local allcraft = ResearchTimer["Default"][myaccount]["$AccountWide"]["Craft"]
local donetimestr = ""

-- print (dump (allcraft))

--get all character names into an array
local names = {}
 for char, _ in pairs(allcraft) do
    if allcraft[char]["shortest"] ~= nil  -- Some chars may have incorrect data. Just Skip.
		then
      table.insert (names, char)
		end
	end
--Sort by soonest occuring. This is stored by the addon.
table.sort(names, function (a,b) return allcraft[a].shortest < allcraft[b].shortest end)


mat = iup.matrix {numcol=4, numlin= #names, numlin_visible = #names, numcol_visible=4, widthdef=200,heightdef=40}
mat.resizematrix = "YES"
mat.hidefocus = "YES"
mat.multiline = "YES"
mat.readonly = "YES"

mat:setcell(0,0,"Character")
mat:setcell(0,1,"Blacksmithing")
mat:setcell(0,2,"Clothing")
mat:setcell(0,3,"Woodworking")
mat:setcell(0,4,"Jewelrycrafting")

for k, char in ipairs(names) do
mat:setcell(k,0,char)

  for  thiscraft = 0,3  do  -- can't use ipairs as it starts from 0. can't use pairs, has "shortest" as key
	  local itemstr = "" 
	  for _, thisitem in pairs(allcraft[char][thiscraft].doing) do

		local itempadded = thisitem.Item_name .. "\\" .. thisitem.Trait_name .. string.rep("-", 40)
		itempadded = string.sub(itempadded,1,26)
		if (thisitem.EndTimeStamp <os.time()) 
			then
			donetimestr = "Finished"
			else donetimestr = os.date(dateformat,thisitem.EndTimeStamp)
		end
		itemstr = itemstr .. itempadded    .. "  " .. donetimestr .. "\n"
	  end

	  mat:setcell(k,thiscraft+1, string.sub(itemstr, 1, string.len(itemstr)-1))  -- cut trailing newline
  end
end


dlg = iup.dialog{iup.vbox{mat; margin="10x10"}}

dlg:showxy(iup.CENTER, iup.CENTER)
dlg.title="Research"

if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end

