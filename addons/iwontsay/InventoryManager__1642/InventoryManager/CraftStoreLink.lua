local DEBUG = 
function() end
-- d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local CSL = {}

local hasCS = nil

IM.CSL = CSL

function CSL:hasCSAddon()
	if hasCS ~= nil then 
	
		return hasCS
	end
	
	if CS then
		CHAT_SYSTEM:AddMessage(GetString(IM_INIT_DETECTED_CS_NEW))
		hasCS = true
	else
		hasCS = false
	end
	return hasCS
end

local CURRENT_PLAYER = GetUnitName("player")

-- It would help me LOTS if Is*Needed would return the raw names list rather than formatted strings.
-- Now I have to take them apart again and make graceful assumptions on their format. :(
function CSL:parseNeeded(needStr)

	-- Can happen with items which cannot be deconstructed (or researched)
	if not needStr then
		return false, false
	end

	local nameHeader = "|cFF1010" -- output modifier: red coloring
	local formattedName = nameHeader .. CURRENT_PLAYER .. "|r" -- including tail to reset the output modifier
	local headerpos = needStr:find(nameHeader)

	-- If we don't find a red coloured name at all, no one seems to need it.
	if not headerpos then
		return false, false
	end

	-- true of we found our own name on the list
	local needSelf = (needStr:find(formattedName) or -1) > -1

	-- string length, minus header (everything in front of the first name), and
	-- eventually the own name. If there's something left, other characters need it, too.
	local lenOthers = needStr:len() - headerpos + 1
	if needSelf then
		lenOthers = lenOthers - formattedName:len()
	end

	local needOthers = lenOthers > 0

	return needSelf, needOthers
end

function CSL:IsItemNeeded(itemLink, uID)
	local craft, row, trait = CS.GetTrait(itemLink)
	return self:parseNeeded(CS.IsItemNeeded(craft, row, trait, uID, itemLink))
end


function CSL:IsStyleNeeded(itemLink)
	return self:parseNeeded(CS.IsStyleNeeded(itemLink))
end

function CSL:IsRecipeNeeded(itemLink)
	return self:parseNeeded(CS.IsRecipeNeeded(itemLink))
end

function CSL:IsBlueprintNeeded(itemLink)
	return self:parseNeeded(CS.IsBlueprintNeeded(itemLink))
end

function CSL:isUnknown(itemLink, uID)
	local oneself, others
	local itemType, specItemType
	
	if not CSL:hasCSAddon() then
		return false, false
	end

	itemType, specItemType = GetItemLinkItemType(itemLink)
	if itemType == ITEMTYPE_RECIPE then
		if specItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING or
		specItemType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING then
			oneself, others = CSL:IsBlueprintNeeded(itemLink)
		else
			oneself, others = CSL:IsRecipeNeeded(itemLink)
		end
	elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
		oneself, others = CSL:IsStyleNeeded(itemLink)
	elseif itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
		oneself, others = CSL:IsItemNeeded(itemLink, uID)
	end

	-- allow (nil, nil) for items which don't fit in any category
	return oneself, others
end
