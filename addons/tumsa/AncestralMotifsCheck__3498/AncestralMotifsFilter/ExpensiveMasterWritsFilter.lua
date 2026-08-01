AMFilter = AMFilter or {}

--  IDs from: https://esoitem.uesp.net/
local expensiveTraits = {
	25,    -- trait 25, type = 45, fortified nirncrux (56862), nirnhoned
	26,    -- trait 26, type = 46, potent nirncrux (56863), nirnhoned
}

--  IDs from: https://esoitem.uesp.net/
local expensiveItems = {
    64221, -- Psijic Ambrosia
    71059, -- Orzorga's Smoked Bear Haunch,
	68343, -- hakeijo (prismatic defense glyph)
	68344, -- hakeijo (prismatic onslaught glyph)
	-- 166047, -- indeko (prismatic recovery glyph)
}

--  checks if ID is in the table
local function isInTable(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function AMFilter.ExpensiveWritFinder(item_link)
	--  https://en.uesp.net/wiki/Online:Item_Link 
	--  14 = writ5 = Trait of Blacksmith/Clothier/Woodworking/Jewelry
	--  10 = writ1 = Food item ID or Glyph item ID
	
	--  get link of an item
	local x 			= { ZO_LinkHandler_ParseLink(item_link) }
	
	--  parse the trait
	local traitnumber   = tonumber(x[14])
	
	-- parse the recipe
	local itemid  		= tonumber(x[10])
	
	--  find if the recipe is expensive
	if isInTable(expensiveItems, itemid) then return true end
	
	--  find if the trait is expensive
	if isInTable(expensiveTraits, traitnumber) then return true end
	
    return false
end