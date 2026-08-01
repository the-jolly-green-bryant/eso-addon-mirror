local util = AdvancedFilters.util
local function GetFilterCallback(name)
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
		if slotIndex ~= nil and type(slot) ~= "table" then
			slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--get the item link
		local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
		local ttc = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			-- Gets the item quality
			if(ttc ~= nil) then
				local avg = ttc["Avg"]  
				if(name == "inf 500") then 
					if(avg <= 500) then
						return true
					end 
				end					
				if(name == "inf 1000") then 
					if(avg <= 1000) then
						return true
					end 
				end			
				if(name == "inf 10000") then 
					if(avg <= 10000) then
						return true
					end 
				end				
				if(name == "sup 5000") then 
					if(avg >= 5000) then
						return true
					end 
				end					
				if(name == "sup 10000") then 
					if(avg >= 10000) then
						return true
					end 
				end				
				if(name == "sup 100000") then 
					if(avg >= 100000) then
						return true
					end 
				end				
				if(name == "sup 250000") then 
					if(avg >= 250000) then
						return true
					end 
				end			
				if(name == "sup 500000") then 
					if(avg >= 500000) then
						return true
					end 
				end
				return false
			else
				return false
			end
		return true
	end
end

local TCCFilterCallBacks = {
	[1] = {name = "inf 500", filterCallback = GetFilterCallback("inf 500")},
	[2] = {name = "inf 1000", filterCallback = GetFilterCallback("inf 1000")},
	[3] = {name = "inf 10000", filterCallback = GetFilterCallback("inf 10000")},
	[4] = {name = "sup 5000", filterCallback = GetFilterCallback("sup 5000")},
	[4] = {name = "sup 10000", filterCallback = GetFilterCallback("sup 10000")},
	[5] = {name = "sup 100000", filterCallback = GetFilterCallback("sup 100000")},
	[6] = {name = "sup 250000", filterCallback = GetFilterCallback("sup 250000")},
	[7] = {name = "sup 500000", filterCallback = GetFilterCallback("sup 500000")},
}

local en = {
	["TTC Filter"] = "TTC Filter",
	["inf 500"] = "<= 0.5k",
	["inf 1000"] = "<= 1k",
	["inf 10000"] = "<= 10k",
	["sup 5000"] = ">= 5k",
	["sup 10000"] = ">= 10k",
	["sup 100000"] = ">= 100k",
	["sup 250000"] = ">= 250k",
	["sup 500000"] = ">= 500k",
}


local filterInformation = {
	submenuName = "TTC Filter",
	callbackTable = TCCFilterCallBacks,
	filterType = ITEMFILTERTYPE_ALL,
	subfilters = {"All",},
	enStrings = en
}

AdvancedFilters_RegisterFilter(filterInformation)