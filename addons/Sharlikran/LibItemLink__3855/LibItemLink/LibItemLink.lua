-- Helpers
----------
local MAX_LEVEL = GetMaxLevel()
local MAX_LIB_ITEM_LEVEL_CP_GEAR_CAP = GetChampionPointsPlayerProgressionCap()

local ITEM_DISPLAY_QUALITY = { }
for itemQuality = ITEM_DISPLAY_QUALITY_MIN_VALUE, ITEM_DISPLAY_QUALITY_MAX_VALUE do
	ITEM_DISPLAY_QUALITY[itemQuality] = true
end

local LINK_STYLE = { }
for linkStyle = LINK_STYLE_MIN_VALUE, LINK_STYLE_MAX_VALUE do
	LINK_STYLE[linkStyle] = true
end

local ITEM_STYLES = { }
for itemStyleIndex = 1, GetNumValidItemStyles() do
	local validItemStyleId = GetValidItemStyleId(itemStyleIndex)
	if validItemStyleId > 0 then
		ITEM_STYLES[validItemStyleId] = true
	end
end

local SetValueBetweenMinAndMax, SetValueRoundFloor = zo_clamp, zo_floor
local MathMin, MathMax = math.min, math.max
local StringFormat = string.format

local function SetBooleanToValue(bool)
	if type(bool) == "boolean" and bool then
		return 1
	end
	return 0
end


-- LibItemLink
--------------
local lib = { }

-- This functions allows you to add or remove brackets of an item link.
function lib:ReplaceLinkStyle(itemLink, newLinkStyle)
-- Return 1: string itemLink
	if itemLink and type(itemLink) == "string" and newLinkStyle then
		itemLink = string.gsub(itemLink, "|H.", "|H"..self:GetValidLinkStyle(newLinkStyle))
	end
	return itemLink
end

-- There are just several item link styles available for chat messages. This function checks, if it's allowed to use.
function lib:GetValidLinkStyle(linkStyle)
-- Return 1: number linkStyle
	return LINK_STYLE[linkStyle] and linkStyle or LINK_STYLE_MIN_VALUE
end

-- The function checks for a valid item style id.
function lib:GetValidItemStyle(itemStyleId)
-- Return 1: number itemStyleId
	return ITEM_STYLES[itemStyleId] == true and itemStyleId or next(ITEM_STYLES)
end

-- Only returns a valid quality of an item.
-- Allowed item qualities: https://wiki.esoui.com/Globals#ItemQuality
function lib:GetValidQuality(quality)
-- Return 1: number quality
	return ITEM_DISPLAY_QUALITY[quality] == true and quality or ITEM_DISPLAY_QUALITY_NORMAL
end

-- An enchant id has to be a value (number).
function lib:GetValidEnchantId(enchantId)
-- Return 1: number enchantId
	return type(enchantId) == "number" and enchantId or 0
end

-- Item levels have to be from 0-50. If it's higher, it still returns 50.
function lib:GetValidLevel(itemLevel)
-- Return 1: number itemLevel
	return SetValueBetweenMinAndMax(SetValueRoundFloor(itemLevel or 0), 0, MAX_LEVEL)
end

-- Item champion points have steps of 10.
function lib:GetValidChampionPoints(championPoints)
-- Return 1: number championPoints
	return SetValueBetweenMinAndMax(SetValueRoundFloor((championPoints or 0) / 10) * 10, 0, MAX_LIB_ITEM_LEVEL_CP_GEAR_CAP)
end

-- This functions checks for item level and item quality. Please check the file LibItemLinkData.
function lib:GetItemSubTypeInfo(itemSubType)
-- Return 2: number nilable:itemLevel, number nilable:itemQuality
	local subType = LIB_ITEM_SUB_TYPES[itemSubType]
	if subType then
		return subType.level, subType.quality
	end
	return nil, nil
end

-- SubTypes of items and enchant is encrypted. This function helps you to create a valid SubType.
function lib:CreateSubTypes(itemLevel, championPoints, itemQuality, enchantQuality)
-- Return 2: number itemSubType, number enchantSubType
	itemQuality = self:GetValidQuality(itemQuality) - 1
	enchantQuality = self:GetValidQuality(enchantQuality) - 1

	itemLevel = self:GetValidLevel(itemLevel)
	championPoints = self:GetValidChampionPoints(championPoints)

	local itemSubType, enchantSubType
	if itemLevel <= MAX_LEVEL and championPoints == 0 then
		if itemLevel < 4 then
			itemSubType = 30
		elseif itemLevel < 6 then
			itemSubType = 25
		else
			itemSubType = 20
		end
		itemSubType = itemSubType + itemQuality
		enchantSubType = itemSubType + enchantQuality
	else
		local subType
		if championPoints < 110 then
			championPoints = MathMax(10, championPoints)
			subType = 124 + SetValueRoundFloor(championPoints / 10)
			itemSubType = subType + itemQuality * 10
			enchantSubType = subType + enchantQuality * 10
		elseif championPoints < 130 then
			subType = 236 + SetValueRoundFloor((championPoints - 110) / 10) * 18
			itemSubType = subType + itemQuality
			enchantSubType = subType + enchantQuality
		elseif championPoints < 150 then
			subType = 272 + SetValueRoundFloor((championPoints - 130) / 10) * 18
			itemSubType = subType + itemQuality
			enchantSubType = subType + enchantQuality
		else
			championPoints = MathMax(MAX_LIB_ITEM_LEVEL_CP_GEAR_CAP, championPoints)
			subType = 308 + SetValueRoundFloor((championPoints - 150) / 10) * 58
			itemSubType = subType + itemQuality
			enchantSubType = subType + enchantQuality
		end
	end
	return itemSubType, enchantSubType
end

-- Generates an item link
--- itemId = any itemId of a valid item
--- itemQuality = number - any valid quality type like ITEM_QUALITY_NORMAL (optional)
--- itemLevel = number 1-50 - if it's not a champion item, define the level (optional)
--- itemChampionPoints = number 0-160 - if you want to create a cp item (optional)
--- itemStyle = number - choose a motif style (optional)
--- isCrafted = boolean - if it's a crafted item (optional)
--- enchantId = number 1-unknown - if you want to add any enchantment to your item (optional)
--- enchantQuality = number - any valid quality type like ITEM_QUALITY_LEGENDARY (optional)
--- linkStyle = if you want some brackets or not (optional)
function lib:BuildItemLink(itemId, itemQuality, itemLevel, itemChampionPoints, itemStyle, isCrafted, enchantId, enchantQuality, linkStyle)
-- Return 1: string:nilable itemLink
	if itemId and type(itemId) == "number" then
		local itemSubType, enchantSubType = self:CreateSubTypes(itemLevel, itemChampionPoints, itemQuality, enchantQuality)
		itemLevel = self:GetValidLevel(itemLevel)
		return StringFormat("|H%i:item:%i:%i:%i:%i:%i:%i:0:0:0:0:0:0:0:0:0:%i:%i:0:0:10000:0|h|h", self:GetValidLinkStyle(linkStyle), itemId, itemSubType, itemLevel, self:GetValidEnchantId(enchantId), enchantSubType, itemLevel, self:GetValidItemStyle(itemStyle), SetBooleanToValue(isCrafted))
	end
	return nil
end

-- Show a tooltip when you hover a control
--- control = control from parent (owner)
--- itemLink = string - any itemLink
--- point / relativePoint = number - like LEFT or TOPLEFT, etc (optional)
--- offsetX / offsetY = number - any value for an offsetX (optional)
function lib:ShowTooltip(control, itemLink, point, offsetX, offsetY, relativePoint)
	if point or offsetX or offsetY or relativePoint then
		point = point or LEFT
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		relativePoint = relativePoint or RIGHT
		InitializeTooltip(ItemTooltip, control, point, offsetX, offsetY, relativePoint)
	else
		InitializeTooltip(ItemTooltip, control)
		ZO_Tooltips_SetupDynamicTooltipAnchors(ItemTooltip, control)
	end
	ItemTooltip:SetLink(itemLink)
end


-- Global
---------
LIB_ITEM_LINK = lib