
local DropDown = {}

local Utils = FasterTravel.Utils

local function Refresh(control,items,callback,getSelected)
	control:ClearItems()
	
	local lookup = {}
	
	local entries = Utils.map(items,function(i)
		local e = control:CreateItemEntry(i.text,callback)
		e.item = i 
		lookup[i.id] = e
		return e
	end)
	
	control:AddItems(entries)

	if getSelected ~= nil then 
		local item = getSelected(lookup)
		if item ~= nil then 
			control:SelectItem(item)
		end 
	end
	
	return lookup
end 

DropDown.Refresh = Refresh

FasterTravel.DropDown = DropDown



