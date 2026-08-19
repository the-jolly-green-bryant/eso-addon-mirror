ShoppingListMatcher = {}

local Matcher = ShoppingListMatcher

local function getPurchaseDetails(itemLink, itemName)
    local details = {
        itemLink = itemLink or "",
        name = itemName or "",
        normalizedName = ShoppingListData.NormalizeName(itemName),
    }

    if details.itemLink == "" then
        return details
    end

    details.itemId = GetItemLinkItemId(details.itemLink)
    details.quality = GetItemLinkDisplayQuality(details.itemLink)
    details.traitType = GetItemLinkTraitInfo(details.itemLink)
    details.level = GetItemLinkRequiredLevel(details.itemLink)
    details.championPoints = GetItemLinkRequiredChampionPoints(details.itemLink)

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(details.itemLink, false)
    if hasSet then
        details.setId = setId
        details.normalizedSetName = ShoppingListData.NormalizeName(setName)
    end

    if details.name == "" then
        details.name = GetItemLinkName(details.itemLink)
        details.normalizedName = ShoppingListData.NormalizeName(details.name)
    end

    return details
end

local function matchQuality(rule, purchase)
    if not rule.quality or rule.qualityMode == nil or rule.qualityMode == "any" then
        return true
    end
    if rule.qualityMode == "minimum" then
        return purchase.quality and purchase.quality >= rule.quality
    end
    return purchase.quality == rule.quality
end

local function matchLevel(rule, purchase)
    if rule.levelMode == nil or rule.levelMode == "any" then
        return true
    end
    return rule.level == purchase.level
        and rule.championPoints == purchase.championPoints
end

function Matcher:GetScore(entry, purchase, includeComplete)
    if not includeComplete and (entry.completed or entry.purchased >= entry.desired) then
        return nil
    end

    if entry.normalizedName ~= purchase.normalizedName then
        return nil
    end

    local score = 10
    if entry.itemId and entry.itemId == purchase.itemId then
        score = score + 100
    end

    local rule = entry.match or {}
    if rule.setId then
        if rule.setId ~= purchase.setId then
            return nil
        end
        score = score + 40
    elseif rule.normalizedSetName then
        if rule.normalizedSetName ~= purchase.normalizedSetName then
            return nil
        end
        score = score + 35
    end
    if rule.traitType and rule.traitType ~= ITEM_TRAIT_TYPE_NONE then
        if rule.traitType ~= purchase.traitType then
            return nil
        end
        score = score + 20
    end
    if not matchQuality(rule, purchase) then
        return nil
    elseif rule.qualityMode and rule.qualityMode ~= "any" then
        score = score + 5
    end
    if not matchLevel(rule, purchase) then
        return nil
    elseif rule.levelMode and rule.levelMode ~= "any" then
        score = score + 5
    end

    return score
end

function Matcher:MatchesItem(entry, itemLink, itemName)
    local details = getPurchaseDetails(itemLink, itemName)
    return self:GetScore(entry, details, true) ~= nil
end

function Matcher:ApplyPurchase(items, itemLink, itemName, quantity)
    local purchase = getPurchaseDetails(itemLink, itemName)
    local matches = {}

    for index, entry in ipairs(items) do
        local score = self:GetScore(entry, purchase)
        if score then
            matches[#matches + 1] = { entry = entry, score = score, index = index }
        end
    end

    table.sort(matches, function(left, right)
        if left.score == right.score then
            return left.index < right.index
        end
        return left.score > right.score
    end)

    local remaining = math.max(0, tonumber(quantity) or 0)
    local changes = {}
    for _, match in ipairs(matches) do
        if remaining == 0 then
            break
        end

        local entry = match.entry
        local needed = entry.desired - entry.purchased
        local applied = math.min(needed, remaining)
        if applied > 0 then
            local wasComplete = entry.completed
            entry.purchased = entry.purchased + applied
            entry.completed = entry.purchased >= entry.desired
            remaining = remaining - applied
            changes[#changes + 1] = {
                entry = entry,
                quantity = applied,
                completed = entry.completed and not wasComplete,
            }
        end
    end

    return changes
end
