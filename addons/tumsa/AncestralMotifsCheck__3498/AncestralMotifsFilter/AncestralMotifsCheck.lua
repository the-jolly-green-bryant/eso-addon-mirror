AMFilter = AMFilter or {}

--  IDs from : https://spicyeconomics.com/style-materials/ 
local expensiveStones = {
    160609, -- etched adamantite		ancestral high elf
    160592, -- etched corundum			ancestral nord
    160626, -- etched manganese			ancestral orc
    167286, -- etched bronze			ancestral reach
    167189, -- burnished goldscale		ancestral akaviri
    167206, -- etched molybdenum 		ancestral breton  		
	171874, -- pristine daedric heart 	ancient daedric
-- 	71738,  -- eagle feather   			aldmeri dominion		FOR TEST PURPOSES
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

function AMFilter.ExpensiveStyleStone(item_link)
	--  get link of an item, then motif, then style stone link 
	--  https://en.uesp.net/wiki/Online:Item_Link 
	--  15 = writ6 = style of Blacksmith/Clothier/Woodworking
	local x 			= { ZO_LinkHandler_ParseLink(item_link) }
	local motifnumber   = tonumber(x[15])
    local stylestone 	= GetItemStyleMaterialLink(motifnumber)
	
	--  get id of the stone
	local stylestoneid  = GetItemLinkItemId(stylestone)
	
	--  find if the style stone is expensive 
	--  expensive stones are in... expensiveStones table 
	if isInTable(expensiveStones, stylestoneid) then return true end
    return false
end
