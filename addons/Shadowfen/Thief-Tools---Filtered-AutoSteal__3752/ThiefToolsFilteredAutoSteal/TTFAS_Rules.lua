local SF = LibSFUtils

local dbg = TTFAS.dbg
TTFAS.rules = {}

local basezoneMapID = {
    --khenarthis roost
    43695, 43696, 43697, 43698, 44939, 45010,
    --auridon
    43625, 43626, 43627, 43628, 43629, 43630, 44927,
    --grahtwood
    43631, 43632, 43633, 43634, 43635, 43636, 44937,
    --greenshade
    43637, 43638, 43639, 43640, 43641, 43642, 44938,
    --malabal tor
    43643, 43644, 43645, 43646, 43647, 43648, 44940,
    --reapers march
    43649, 43650, 43651, 43652, 43653, 43654, 44941,
    --bleakrock
    43699, 43700, 44931,
    --bal foyen
    43701, 43702, 44928,
    --stonefalls
    43655, 43656, 43657, 43658, 43659, 43660, 44944,
    --deshaan
    43661, 43662, 43663, 43664, 43665, 43666, 44934,
    --shadowfen
    43667, 43668, 43669, 43670, 43671, 43672, 44943,
    --eastmarch
    43673, 43674, 43675, 43676, 43677, 43678, 44935,
    --the rift
    43679, 43680, 43681, 43682, 43683, 43684, 44947,
    --stros mkai
    43691, 43692, 44946,
    --betnihk
    43693, 43694, 44930,
    --glenumbra
    43507, 43525, 43527, 43600, 43509, 43526, 44936,
    --stormhaven
    43601, 43602, 43603, 43604, 43605, 43606, 44945,
    --rivenspire
    43607, 43608, 43609, 43610, 43611, 43612, 44942,
    --alikr
    43613, 43614, 43615, 43616, 43617, 43618, 44926,
    --bangkorai
    43619, 43620, 43621, 43622, 43623, 43624, 44929,
    --coldharbour
    43685, 43686, 43687, 43688, 43689, 43690, 44932,
    --craglorn
    43721, 43722, 43723, 43724, 43725, 43726
}

FASrule = ZO_Object:Subclass()

function FASrule:New(filterValue, checkfunc, cfg)
    if filterValue == nil then return nil end
    if checkfunc == nil then return nil end
    
    local result = ZO_Object.New(self)
    result.filterValue = filterValue
    result.checkfunc = checkfunc
    -- copy cfg table if necessary
    result.cfg = cfg or {}
    return result
end

function FASrule:check(lootitem)
    if lootitem == nil then return nil end
    return self.checkfunc(self, lootitem)
end

-----

-- modified from Slasher
-- Will return true if Azandar is active and his rapport is not maxed
-- Returns false otherwise (i.e. he will not gain rapport)
local function isAzandarActive()
	local AZANDAR = 11114
	local name, _, _, _, unlocked, _, isActive = GetCollectibleInfo(AZANDAR)
	if unlocked and isActive then
		local rapport = GetActiveCompanionRapport()
		if rapport < 5500 then
			return true
		end
	end
	return false
end

-- return true if someone doesn't know it
-- return false if everyone knows it
-- modified version of function from AutoCategory
local function CheckUTUnknown(filterVal, lootitem)
	-- availability of UnknownTracker is checked before calling this function
	dbg("CheckUTUnknown started")
	
	local isValid, knownlist, isGear = UnknownTracker:IsValidAndWhoKnowsIt(lootitem:GetItemLink())
	dbg("CheckUTUnknown - isValid = ", isValid, " isGear = ",isGear)
	if not knownlist then return true end
	dbg("CheckUTUnknown -  knownlist = ")
	for k,v in pairs(knownlist) do
		dbg(v, " ",k)
	end
    local allchars, allacct = UnknownTracker:GetCharacterList()
    local fst = next(knownlist)
    local unknowers = {}
    if fst == nil then 
		dbg("No one knows this")
		return true
	end
	if "@" == string.sub(fst,1,1) then
		--looking for account names
		unknowers = UnknownTracker:RemainsList(allacct, knownlist)
	else    
		unknowers = UnknownTracker:RemainsList(allchars, knownlist)
	end
    if not next(unknowers) then
        -- everyone knows it
		dbg("everyone knows it")
        return false
    end
	dbg("unknowers list =")
	for k,v in pairs(unknowers) do
		dbg(v, " ",k)
	end
	dbg("someone does not know it")
	return true
	
-- the remaining code needs a list of specific characters
-- to check if they know, but I don't have the UI to be able 
-- to build such a list. Maybe later.

--[[    
    if next(characters) == nil then
        -- not looking for particular character
        return false
    end
	
    -- check against parameter list of toon names
    -- looking for specific toons that don't know
    for charname,v in pairs(unknowers) do
        if characters[charname] == nil then
            -- we were looking for toon that does not know
            return true
        end
    end
--]]
    -- everyone in our parameter list knows
    --return false	
end

----

--[[
The checkfunc function will return true if it determines that the lootitem should be taken. A true means take the lootitem and stop checking rules. False means continue to check the next rule.

Params:
    * a FASrule having necessary config settings
    * the lootitem under evaluation

Check flow
    * lootitem does not match rule item discriminator, return false
    * filterValue == FASFV:val(FAS_ALWAYS), return true
    * check if the item meets requirements - returning true 
if it does and false otherwise.

Does not need to do safety (nil) checks on filterValue and lootitem because
those have already been done.
Rule is not created for filterValue == FASFV:val(FAS_NEVER)
]]



function TTFAS.rules.CheckQuest(rule, lootitem)

	if not lootitem.isQuest then return false end
	
	dbg("Checking quest item")
	return true
end


function TTFAS.rules.CheckTreasureMap(rule, lootitem)

	if lootitem.itemType ~= ITEMTYPE_TROPHY then return false end
	
   if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
	
    if rule.filterValue == "only non-base-zone" then
        if ZO_IsElementInNonContiguousTable(basezoneMapID, lootitem.itemId) then 
			dbg("map - base zone")
            return false
        end
    
    else
		dbg("map - dlc zone")
        return true
    end
    return false
end

local function CheckQuality(filterValue, lootitem, minquality)
	if minquality == nil then minquality = ITEM_DISPLAY_QUALITY_NORMAL end

	dbg(SF.dstr(" ","CheckQuality -",filterValue, minquality))
	dbg(SF.dstr(" ","CheckQuality -",lootitem.quality, minquality))
    if lootitem.quality >= minquality then
		dbg(SF.dstr(" ","CheckQuality - minQuality", minquality, "<=", lootitem.quality, true))
        return true
    end
	dbg(SF.str("CheckQuality - no match"))
	return false
end

local function CheckValue(filterValue, lootitem, minvalue)
	if minvalue == nil then minvalue = 0 end

	dbg(SF.dstr(" ","CheckValue -",filterValue, minvalue))
	dbg(SF.dstr(" ","CheckValue -",lootitem.value, minvalue))

    if lootitem.value >= minvalue then
		dbg(SF.dstr(" ","CheckValue - minvalue", minvalue, "<=", lootitem.value, true))
        return true
    end
	dbg(SF.str("CheckValue - no match"))
	return false
end

local function CheckTTCValue(rule, lootitem, minvalue, baseprice, profit)
	if not TamrielTradeCentre then return false end
	
	if minvalue == nil then return false end
	local suggested, avg = lootitem:getTTCPrice()
	--if rule.filterValue == "Do not check" then return false end
	dbg(SF.dstr(" ","CheckTTCValue -", baseprice, "suggested ",suggested, "minval ",minvalue))
	
	if not profit then
		if baseprice == L(TTFAS_PP_SUGGESTED) then
			dbg(SF.dstr(" ","CheckValue - suggested",suggested, minvalue))
			if suggested and suggested > 0 and suggested >= minvalue then
				dbg(SF.dstr(" ","CheckTTCValue - suggested", minvalue, "<=", suggested, true))
				return true
			end
			
		elseif baseprice == L(TTFAS_PP_AVERAGE) then
			if ave and ave > 0 and ave >= minvalue then
				dbg(SF.dstr(" ","CheckTTCValue - average", minvalue, "<=", avg, true))
				return true
			end
		end
	
	else
		if baseprice == L(TTFAS_PP_SUGGESTED) then
			if not suggested or suggested < 1 then return false end
			local profit = suggested - lootitem.value - (suggested * 0.07)
			dbg(SF.dstr(" ","CheckValue - suggested",suggested, minvalue))
			if profit >= minvalue then
				dbg(SF.dstr(" ","CheckTTCValue - suggested profit ", minvalue, "<=", profit, true))
				return true
			end
			
		elseif baseprice == L(TTFAS_PP_AVERAGE) then
			if not ave or ave < 1 then return false end
			local profit = ave - lootitem.value - (ave * 0.07)
			if profit >= minvalue then
				dbg(SF.dstr(" ","CheckTTCValue - average profit ", minvalue, "<=", profit, true))
				return true
			end
		end
	end

	dbg(SF.str("CheckTTCValue - no match"))
	return false
end

local azandarLikes = {
	-- 62385  Pouch of Bronzed Acorns
	-- 63131  Tuft of Hair
	-- 64388  Rune Chunk
	-- 64382  Petrified Bull Charm
	62385, 63131, 64382, 64388,	--normal
	-- 198182 Wooden Guar Whistle
	-- 198207 Shadowspun Prayer Mat
	-- 198208 Ashen Gaze of the Inevitable Knower
	-- 198233 Ceramic Urn Slip Cast
	-- 192267 Mage Turoth's Funerary Ash
	-- 198263 Pickled Tomeshell Tongue
	-- 198269 Degraded Dwemer Quarrel
	198182, 198207, 198208, 198233, 192267, 198268, 198263, 198269, --green
	-- 198180 Cryptguard Lantern
	-- 198212 Firesteel of the Immolant One
	-- 198272 Grahl-Eye Gem Purse
	198180, 198212, 198272, -- blue
}
function TTFAS.rules.CheckTreasures(rule, lootitem)
    if lootitem.itemType ~= ITEMTYPE_TREASURE then return false end
    
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end

    local cfg = rule.cfg
    if cfg.minQual == nil then
        cfg.minQual = ITEM_DISPLAY_QUALITY_NORMAL
    end

	dbg("Checking Quality of ", lootitem.name, " minQuality = ", SF.str(cfg.minQual))
	if CheckQuality(rule.filterValue, lootitem, cfg.minQual) then
		dbg("met Quality requirement")
		return true
    end
	if isAzandarActive() and ZO_IsElementInNonContiguousTable(azandarLikes, lootitem.itemId) then
        dbg("Azandar likes it")
        return true
	end
    return false        
 end

function TTFAS.rules.CheckEnchMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT 
		or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE 
		or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY 
		or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
		    return false
		end

	dbg("Checking enchanting mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
	
    return false
end

function TTFAS.rules.CheckBlksmMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_BLACKSMITHING_BOOSTER 
		or itemType == ITEMTYPE_BLACKSMITHING_MATERIAL 
		or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL) then return false end
		
	dbg("Checking blacksmithing mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
				
    return false
end

function TTFAS.rules.CheckClothMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_CLOTHIER_BOOSTER 
		or itemType == ITEMTYPE_CLOTHIER_MATERIAL 
		or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL) then return false end
				
	dbg("Checking clothing mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
				
    return false
end

function TTFAS.rules.CheckWoodMat(rule, lootitem)
local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_WOODWORKING_BOOSTER 
		or itemType == ITEMTYPE_WOODWORKING_MATERIAL 
		or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then return false end
		
	dbg("Checking woodworking mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end

    return false
end

function TTFAS.rules.CheckJewelryMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER 
		or itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL 
		or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER 
		or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL) then return false end
				
	dbg("Checking jewelry mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end

    return false
end

function TTFAS.rules.CheckStyleMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_RAW_MATERIAL 
		or itemType == ITEMTYPE_STYLE_MATERIAL) then return false end
				
	dbg("Checking raw/style mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end

    if rule.filterValue == FASFV:val(FAS_NON_RACIAL) then
        local itemType = lootitem.itemType

        if itemType == ITEMTYPE_RAW_MATERIAL then
            return true
            
        else
            local styleId = lootitem:GetItemStyle()
			if styleId == nil then return false end
            -- if it is racial style material
            if ((styleId >= 1 and styleId <= 9) or styleId == 15 or styleId == 17 or styleId == 19 or styleId == 20 or styleId == GetImperialStyleId()) then
                return false
                
            else
                return true
            end
        end
    end

    return false
end

function TTFAS.rules.CheckTraitMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_WEAPON_TRAIT 
		or itemType == ITEMTYPE_ARMOR_TRAIT 
		or itemType == ITEMTYPE_JEWELRY_RAW_TRAIT 
		or itemType == ITEMTYPE_JEWELRY_TRAIT) then return false end
	
	dbg("Checking trait mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end

    return false
end

function TTFAS.rules.CheckProvisMat(rule, lootitem)
	if lootitem.itemType ~= ITEMTYPE_INGREDIENT then return false end
	
	dbg("Checking provisioning mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end

function TTFAS.rules.CheckAlchemyMat(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_POTION_BASE 
		or itemType == ITEMTYPE_POISON_BASE 
		or itemType == ITEMTYPE_REAGENT) then return false end
		
	dbg("Checking alchemy mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end

function TTFAS.rules.CheckFurnMat(rule, lootitem)
    if lootitem.itemType ~= ITEMTYPE_FURNISHING_MATERIAL then return false end

	dbg("Checking furnishing mat")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end

function TTFAS.rules.CheckGlyph(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_GLYPH_ARMOR 
		or itemType == ITEMTYPE_GLYPH_JEWELRY 
		or itemType == ITEMTYPE_GLYPH_WEAPON) then return false end
		
	dbg("Checking glyph")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end


function TTFAS.rules.CheckContainer(rule, lootitem)
    local itemType = lootitem.itemType
    if not (itemType == ITEMTYPE_CONTAINER 
		or itemType == ITEMTYPE_CONTAINER_CURRENCY) then return false end

	dbg("Checking container")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end

function TTFAS.rules.CheckFurniture(rule, lootitem)
    -- can you actually steal furniture?? ANS: Actually yes.
    if lootitem.itemType ~= ITEMTYPE_FURNISHING then return false end
    
	dbg("Checking furnishing")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
    return false
end

local potentPotions = {
	[176040] = true,
	[176041] = true,
	[176042] = true,
}
function TTFAS.rules.CheckPotion(rule, lootitem)
    local itemType = lootitem.itemType
    if itemType ~= ITEMTYPE_POTION then return false end
    
	dbg("Checking potion")

    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
	
	local itemId = lootitem.itemId
	local isPotent = SF.isTrue(potentPotions[itemId])
    if rule.filterValue == FASFV:val(FAS_POTENT_POTIONS) and isPotent then
        return true
    end
	if rule.filterValue == FASFV:val(FAS_NORMAL_POTIONS) and not isPotent then
        return true
    end
    return false
end

function TTFAS.rules.CheckPoison(rule, lootitem)
    local itemType = lootitem.itemType
    if itemType ~= ITEMTYPE_POISON then return false end
    
	dbg("Checking poison")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    return false
end

function TTFAS.rules.CheckProvisions(rule, lootitem)
    local itemType = lootitem.itemType
	if not (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then  return false end

	dbg("Checking food/drink")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    return false
end

-- Depends on CheckUTUnknown
function TTFAS.rules.CheckCollectible(rule, lootitem)
    if not (lootitem.itemType == ITEMTYPE_COLLECTIBLE 
		or lootitem.lootType == LOOT_TYPE_COLLECTIBLE) then return false end
				
	dbg("Checking collectibles")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    if TTFAS.UT_addon and rule.filterValue == FASFV:val(FAS_UNKNOWN_BY_ANY) then
			return CheckUTUnknown(rule.filterValue, lootitem)
    end
    return false
	
end

function TTFAS.rules.CheckStylePage(rule, lootitem)
    if not (lootitem.itemId == ITEMTYPE_COLLECTIBLE and lootitem.specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE) then return false end
				
	dbg("Checking style pages")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    if TTFAS.UT_addon and rule.filterValue == FASFV:val(FAS_UNKNOWN_BY_ANY) then
			return CheckUTUnknown(rule.filterValue, lootitem)
    end
    return false
	
end

function TTFAS.rules.CheckWrit(rule, lootitem)
    if lootitem.itemType ~= ITEMTYPE_MASTER_WRIT then return false end
    
	dbg("Checking master writ")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    return false
end



function TTFAS.rules.CheckMotif(rule, lootitem)
    if lootitem.itemType ~= ITEMTYPE_RACIAL_STYLE_MOTIF then return false end
    
	dbg("Checking motif")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
	if rule.filterValue == FASFV:val(FAS_UNKNOWN) and not IsItemLinkRecipeKnown(lootitem.link) then
        return true
    end
	
    if rule.filterValue == FASFV:val(FAS_UNKNOWN_BY_ANY) then
		if TTFAS.UT_addon then
			return CheckUTUnknown(rule.filterValue, lootitem)
			
		elseif not IsItemLinkRecipeKnown(lootitem.link) then
			return true
		end
	end

    return false
	
end

function TTFAS.rules.CheckRecipe(rule, lootitem)
    if lootitem.itemType ~= ITEMTYPE_RECIPE then return false end
    
	dbg("Checking recipe")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
    
	dbg("Checking only unknown")
	if rule.filterValue == FASFV:val(FAS_UNKNOWN) and not IsItemLinkRecipeKnown(lootitem.link) then
        return true
    end
	
	dbg("Checking unknown by any")
    if rule.filterValue == FASFV:val(FAS_UNKNOWN_BY_ANY) then
		--dbg("Checking if UnknownTracker installed")
		if TTFAS.UT_addon then
			--dbg("Checking with UnknownTracker")
			return CheckUTUnknown(rule.filterValue, lootitem)
			
		elseif not IsItemLinkRecipeKnown(lootitem.link) then
			return true
		end
	end

    return false
	
end

function TTFAS.rules.CheckPaperTTC(rule, lootitem)
	if not TamrielTradeCentre then return false end
    if not ((lootitem.itemId == ITEMTYPE_COLLECTIBLE and lootitem.specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE) 
		or lootitem.itemType == ITEMTYPE_RACIAL_STYLE_MOTIF 
		or lootitem.itemType == ITEMTYPE_RECIPE) then return false end
				
	dbg("Checking paper TTC")
    local cfg = rule.cfg
	-- Remember that here FAS_ALWAYS means always check against the TTC price
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
		return CheckTTCValue(rule, lootitem, cfg.minVal, cfg.baseprice, cfg.profit)
	end
    return false
	
end

function TTFAS.rules.CheckLockpick(rule, lootitem)
	
	--if lootitem.itemType ~= ITEMTYPE_TOOL then return false end
	if lootitem.itemType ~= ITEMTYPE_LOCKPICK then return false end
	dbg("Checking lockpicks")
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
	return false
end

function TTFAS.rules.CheckSoulGem(rule, lootitem)
	if itemType ~= ITEMTYPE_SOUL_GEM then
		return false
	end

    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        looted = true
        return true
    end

	-- can't get if soulgem is filled or not from a link, so guess with value
    if rule.filterValue == FASFV:val(FAS_FILLED) and lootitem.value > 5 then
        return true
		
    elseif rule.filterValue == FASFV:val(FAS_UNFILLED) and lootitem.value <= 5 then
        return true
    end

    return false
end

function TTFAS.rules.CheckCompanionGear(rule, lootitem)

	if not lootitem:isCompanionGear() then return false end
	
	dbg("is companion gear - ",rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
    end
	local cfg = rule.cfg
    if rule.filterValue == FASFV:val(FAS_MIN_QUALITY) and cfg.minQual <= lootitem.quality then
        return true
    end

    return false
end

function TTFAS.rules.CheckIsSetGear(rule, lootitem)
	local hasSet = lootitem:GetSetInfo()
	if not (hasSet and not lootitem:isJewelry()) then return false end
	
	local cfg = rule.cfg
	dbg("is set gear - ",rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
		
    elseif rule.filterValue == FASFV:val(FAS_COLLECTED) and lootitem.isCollected then
		return true
		
    elseif rule.filterValue == FASFV:val(FAS_UNCOLLECTED) and lootitem.isCollected == false then
		return true

    elseif rule.filterValue == FASFV:val(FAS_TTC_MIN_VALUE) then
		return CheckTTCValue(rule, lootitem, cfg.minVal, cfg.baseprice, cfg.profit)
	end	

    return false
end

function TTFAS.rules.CheckIsSetJewel(rule, lootitem)
	local hasSet = lootitem:GetSetInfo()
	if not (hasSet and lootitem:isJewelry()) then return false end
	
	dbg("is set gear - ",rule.filterValue)
	local cfg = rule.cfg
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
		
    elseif rule.filterValue == FASFV:val(FAS_COLLECTED) and lootitem.isCollected then
		return true
		
    elseif rule.filterValue == FASFV:val(FAS_UNCOLLECTED) and lootitem.isCollected == false then
		return true

    elseif rule.filterValue == FASFV:val(FAS_TTC_MIN_VALUE) then
		return CheckTTCValue(rule, lootitem, cfg.minVal, cfg.baseprice, cfg.profit)
	end	

    return false
end

function TTFAS.rules.CheckCanResearch(rule, lootitem)
	if not lootitem:canResearch() then return false end
	
	dbg("can research item - ",rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
	end
	
    return false
end

function TTFAS.rules.CheckIsOrnate(rule, lootitem)
	if not lootitem.isOrnate then return false end
	
	dbg("is item ornate - ",rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
	end
	
    return false
end


local weapons_wood = {
	WEAPONTYPE_BOW = true,
	WEAPONTYPE_FIRE_STAFF = true,
	WEAPONTYPE_FROST_STAFF = true,
	WEAPONTYPE_LIGHTNING_STAFF = true,
	WEAPONTYPE_HEALING_STAFF = true,
	WEAPONTYPE_SHIELD = true,
}
function TTFAS.rules.CheckIsIntricate(rule, lootitem)
	if not lootitem.isIntricate then return false end
	
	dbg("is item intricate - ",rule.filterValue)
	local cfg = rule.cfg
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
	
	elseif rule.filterValue == FASFV:val(FAS_TYPE_BASED) then
		dbg("filterValue == type based")

		-- if jewelry
		if lootitem.isJewelry and cfg.jewel == FASFV:val(FAS_ALWAYS) then
			dbg("isJewelry = true")
			return true
		end

		-- made it here so is not jewelry
		local armorType = lootitem:GetArmorType()
		if armorType ~= ARMORTYPE_NONE then
			dbg("armorType == ", armorType)
			
			-- if clothing
			if cfg.cloth == FASFV:val(FAS_ALWAYS) and (armorType == ARMORTYPE_LIGHT or armorType == ARMORTYPE_MEDIUM) then
				return true
			
			-- if blacksmithing
			elseif cfg.metal == FASFV:val(FAS_ALWAYS) and armorType == ARMORTYPE_HEAVY then
				return true
			end
			return false
		end

		if weaponType ~= WEAPONTYPE_NONE then
			dbg("weaponType == ", weaponType)
			if cfg.wood == FASFV:val(FAS_ALWAYS) and weapons_wood[weaponType] then
				return true
			end
			return false
		end
	end
	
    return false
end


function TTFAS.rules.CheckJewelry(rule, lootitem)
	if not lootitem:isJewelry() then return false end
	
	dbg("is jewelry - ", rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
	end

    local cfg = rule.cfg
    SF.dTable(cfg, 2, "rule cfg")
    if cfg.minQual == nil then
        cfg.minQual = ITEM_DISPLAY_QUALITY_NORMAL
    end
    if cfg.minVal == nil then
        cfg.minVal = 0
    end
	

    if rule.filterValue == FASFV:val(FAS_MIN_QUALITY) then
		if CheckQuality(rule.filterValue, lootitem, cfg.minQual) then
			dbg("met Quality requirement")
			return true
		end
	end
	
    if rule.filterValue == FASFV:val(FAS_MIN_VALUE) then
		if CheckValue(rule.filterValue, lootitem, cfg.minVal) then
			dbg(SF.dstr(" ","CheckJewelry - minVal", cfg.minVal, "<=", lootitem.value, true))
			return true
		end

    elseif rule.filterValue == FASFV:val(FAS_TTC_MIN_VALUE) then
		return CheckTTCValue(rule, lootitem, cfg.minVal, cfg.baseprice, cfg.profit)
	end
	dbg(SF.str("CheckJewelry - no match"))
    return false
end

function TTFAS.rules.CheckArmor(rule, lootitem)
	if lootitem.itemType ~= ITEMTYPE_ARMOR or lootitem:isJewelry() then return false end
	
	dbg("is armor - fv ", rule.filterValue, " -  val ", FASFV:val(FAS_ALWAYS), " - str ", FASFV:str(FAS_ALWAYS))
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
		dbg("returning true for armor")
        return true
	end

    local cfg = rule.cfg
    SF.dTable(cfg, 2, "rule cfg")
    if cfg.minQual == nil then
        cfg.minQual = ITEM_DISPLAY_QUALITY_NORMAL
    end
    if cfg.minVal == nil then
        cfg.minVal = 0
    end
	

    if rule.filterValue == FASFV:val(FAS_MIN_QUALITY) then
		dbg("CheckArmor - checking quality")
		if CheckQuality(rule.filterValue, lootitem, cfg.minQual) then
			dbg("met Quality requirement")
			return true
		end
	end
	
    if rule.filterValue == FASFV:val(FAS_MIN_VALUE) then
		dbg("CheckArmor - checking value")
		if CheckValue(rule.filterValue, lootitem, cfg.minVal) then
			dbg(SF.dstr(" ","CheckArmor - minVal", cfg.minVal, "<=", lootitem.value, true))
			return true
		end

    elseif rule.filterValue == FASFV:val(FAS_TTC_MIN_VALUE) then
		dbg("CheckArmor - checking TTC value")
		return CheckTTCValue(rule, lootitem, cfg.minTTCVal, cfg.baseprice, cfg.profit)
	end
	dbg(SF.str("CheckArmor - no match"))
    return false
end

function TTFAS.rules.CheckWeapons(rule, lootitem)
	if lootitem.itemType ~= ITEMTYPE_WEAPON then return false end
	
	dbg("is weapon - ", rule.filterValue)
    if rule.filterValue == FASFV:val(FAS_ALWAYS) then
        return true
	end

    local cfg = rule.cfg
    SF.dTable(cfg, 2, "rule cfg")
    if cfg.minQual == nil then
        cfg.minQual = ITEM_DISPLAY_QUALITY_NORMAL
    end
    if cfg.minVal == nil then
        cfg.minVal = 0
    end
	

    if rule.filterValue == FASFV:val(FAS_MIN_QUALITY) then
		if CheckQuality(rule.filterValue, lootitem, cfg.minQual) then
			dbg(SF.dstr(" ","CheckWeapons - minQual", cfg.minQual, "<=", lootitem.quality, true))
			return true
		end
	end
	
    if rule.filterValue == FASFV:val(FAS_MIN_VALUE) then
		if CheckValue(rule.filterValue, lootitem, cfg.minVal) then
			dbg(SF.dstr(" ","CheckWeapons - minVal", cfg.minVal, "<=", lootitem.value, true))
			return true
		end

    elseif rule.filterValue == FASFV:val(FAS_TTC_MIN_VALUE) then
		return CheckTTCValue(rule, lootitem, cfg.minTTCVal, cfg.baseprice, cfg.profit)
	end
	dbg(SF.str("CheckWeapons - no match"))
    return false
end

function TTFAS.CheckBait(rule, lootitem)
	if lootitem.itemType ~= ITEMTYPE_LURE then return end
	
	dbg("Checking bait")
	if rule.filterValue == FASFV:val(FAS_ALWAYS) then
		return true
	end
end

function TTFAS.CheckAntiquity(rule, lootitem)
	local lootType = GetLootItemType(lootitem.lootId)
	if lootType ~= LOOT_TYPE_ANTIQUITY_LEAD then return false end
	
	--always pick up antiquities
	return true
end
