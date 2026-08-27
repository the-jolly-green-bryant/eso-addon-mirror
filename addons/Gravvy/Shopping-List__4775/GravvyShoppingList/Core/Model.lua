ShoppingListModel = {
    MAX_LISTS = 1000,
    MAX_ITEMS_PER_LIST = 500,
    MAX_NAME_LENGTH = 512,
    MAX_NOTE_LENGTH = 2000,
    MAX_CATEGORY_LENGTH = 80,
    MAX_LINK_LENGTH = 2048,
    MAX_QUANTITY = 1000000,
    MAX_PRICE = 4294967295,
    MAX_SET_OR_ITEM_ID = 4294967295,
    MAX_LEVEL = 50,
    MAX_CHAMPION_POINTS = 160,
    MAX_PURCHASE_HISTORY = 200,
    MAX_PURCHASE_TRANSACTIONS = 500,
    QUALITY_MODES = {
        any = true,
        minimum = true,
        exact = true,
    },
    LEVEL_MODES = {
        any = true,
        exact = true,
    },
    TARGET_MODES = {
        buy = true,
        own = true,
    },
    DUPLICATE_POLICIES = {
        keep = true,
        prompt = true,
        merge = true,
        replace = true,
    },
    ITEM_SORTS = {
        name = true,
        quantity = true,
        owned = true,
        completion = true,
        price = true,
        added = true,
    },
}

local Model = ShoppingListModel

local validQualities = {
    [ITEM_QUALITY_TRASH] = true,
    [ITEM_QUALITY_NORMAL] = true,
    [ITEM_QUALITY_MAGIC] = true,
    [ITEM_QUALITY_ARCANE] = true,
    [ITEM_QUALITY_ARTIFACT] = true,
    [ITEM_QUALITY_LEGENDARY] = true,
}

function Model:IsWholeNumber(value, minimum, maximum)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
        and value == math.floor(value)
        and (minimum == nil or value >= minimum)
        and (maximum == nil or value <= maximum)
end

function Model:IsBoundedString(value, maximum, allowEmpty)
    return type(value) == "string"
        and #value <= maximum
        and (allowEmpty or zo_strtrim(value) ~= "")
end

function Model:IsValidQuality(value)
    return self:IsWholeNumber(value) and validQualities[value] == true
end

function Model:IsValidTargetMode(value)
    return type(value) == "string" and self.TARGET_MODES[value] == true
end

function Model:IsValidDuplicatePolicy(value)
    return type(value) == "string" and self.DUPLICATE_POLICIES[value] == true
end

function Model:NormalizeTargetMode(value)
    return self:IsValidTargetMode(value) and value or "buy"
end

function Model:IsValidTraitType(value)
    if value == ITEM_TRAIT_TYPE_NONE then
        return true
    end
    local first = ITEM_TRAIT_TYPE_ITERATION_BEGIN or 1
    local last = ITEM_TRAIT_TYPE_ITERATION_END or 64
    if not self:IsWholeNumber(value, first, last) then
        return false
    end
    local label = GetString("SI_ITEMTRAITTYPE", value)
    return type(label) == "string" and label ~= ""
end

function Model:NormalizeMatchingRule(source, sanitize)
    if source == nil then
        return {
            qualityMode = "any",
            levelMode = "any",
        }
    end
    if type(source) ~= "table" then
        return sanitize and {
            qualityMode = "any",
            levelMode = "any",
        } or nil
    end

    local rule = {}
    local setName = source.setName
    if setName ~= nil then
        if type(setName) ~= "string" then
            if not sanitize then return nil end
        else
            setName = zo_strtrim(setName)
            if setName ~= "" and #setName <= self.MAX_NAME_LENGTH then
                rule.setName = setName
                rule.normalizedSetName = ShoppingListData
                    and ShoppingListData.NormalizeName
                    and ShoppingListData.NormalizeName(setName) or zo_strlower(setName)
            elseif setName ~= "" and not sanitize then
                return nil
            end
        end
    end
    if source.setId ~= nil then
        if rule.setName and self:IsWholeNumber(
            source.setId,
            1,
            self.MAX_SET_OR_ITEM_ID
        ) then
            rule.setId = source.setId
        elseif not sanitize then
            return nil
        end
    end

    if source.traitType ~= nil then
        if self:IsValidTraitType(source.traitType) then
            rule.traitType = source.traitType
        elseif not sanitize then
            return nil
        end
    end

    local qualityMode = source.qualityMode or "any"
    if not self.QUALITY_MODES[qualityMode] then
        if not sanitize then return nil end
        qualityMode = "any"
    end
    rule.qualityMode = qualityMode
    if source.quality ~= nil then
        if self:IsValidQuality(source.quality) then
            rule.quality = source.quality
        elseif not sanitize then
            return nil
        end
    end
    if qualityMode ~= "any" and rule.quality == nil then
        if not sanitize then return nil end
        rule.qualityMode = "any"
    end

    local levelMode = source.levelMode or "any"
    if not self.LEVEL_MODES[levelMode] then
        if not sanitize then return nil end
        levelMode = "any"
    end
    rule.levelMode = levelMode
    if source.level ~= nil then
        if self:IsWholeNumber(source.level, 1, self.MAX_LEVEL) then
            rule.level = source.level
        elseif not sanitize then
            return nil
        end
    end
    if source.championPoints ~= nil then
        if self:IsWholeNumber(source.championPoints, 0, self.MAX_CHAMPION_POINTS) then
            rule.championPoints = source.championPoints
        elseif not sanitize then
            return nil
        end
    end
    if levelMode == "exact" and (rule.level == nil or rule.championPoints == nil) then
        if not sanitize then return nil end
        rule.levelMode = "any"
    end
    return rule
end

function Model:IsValidMatchingRule(rule)
    return self:NormalizeMatchingRule(rule, false) ~= nil
end

local function activeTrait(rule)
    local traitType = rule and rule.traitType
    if traitType == ITEM_TRAIT_TYPE_NONE then
        return nil
    end
    return traitType
end

local function sameSetRule(left, right)
    local leftHasSet = left.setId ~= nil or left.normalizedSetName ~= nil
    local rightHasSet = right.setId ~= nil or right.normalizedSetName ~= nil
    if leftHasSet ~= rightHasSet then
        return false
    end
    if not leftHasSet then
        return true
    end
    if left.setId ~= nil and right.setId ~= nil then
        return left.setId == right.setId
    end
    return left.normalizedSetName ~= nil
        and left.normalizedSetName == right.normalizedSetName
end

function Model:MatchingRulesEqual(left, right)
    left = self:NormalizeMatchingRule(left, true)
    right = self:NormalizeMatchingRule(right, true)

    if not sameSetRule(left, right)
        or activeTrait(left) ~= activeTrait(right)
        or left.qualityMode ~= right.qualityMode
        or left.levelMode ~= right.levelMode
    then
        return false
    end
    if left.qualityMode ~= "any" and left.quality ~= right.quality then
        return false
    end
    if left.levelMode ~= "any" then
        return left.level == right.level
            and left.championPoints == right.championPoints
    end
    return true
end

function Model:ItemsAreDuplicates(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return false
    end

    if left.itemId ~= nil and right.itemId ~= nil then
        if left.itemId ~= right.itemId then
            return false
        end
    elseif left.normalizedName ~= right.normalizedName then
        return false
    end

    return self:NormalizeTargetMode(left.targetMode)
            == self:NormalizeTargetMode(right.targetMode)
        and self:MatchingRulesEqual(left.match, right.match)
end
