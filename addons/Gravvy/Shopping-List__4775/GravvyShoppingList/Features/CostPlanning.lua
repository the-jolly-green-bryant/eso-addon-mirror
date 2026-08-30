ShoppingListCostPlanning = {}

local CostPlanning = ShoppingListCostPlanning
local MAX_SAFE_COST = 9007199254740991

local function addCost(current, amount)
    if current >= MAX_SAFE_COST or amount >= MAX_SAFE_COST - current then
        return MAX_SAFE_COST, true
    end
    return current + amount, false
end

function CostPlanning:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function CostPlanning:GetProjection(list)
    list = list or self.owner.data:GetCurrentList()
    local spent = math.max(
        0,
        tonumber(list.transactionSpent or list.totalSpent) or 0
    )
    local projection = {
        listId = list.id,
        spent = spent,
        projectedRemaining = 0,
        projectedTotal = spent,
        pricedEntries = 0,
        unpricedEntries = 0,
        remainingEntries = 0,
        remainingQuantity = 0,
        capped = false,
    }

    for _, item in ipairs(list.items) do
        local remaining = self.owner.data:GetRemainingQuantity(item)
        if remaining > 0 then
            projection.remainingEntries = projection.remainingEntries + 1
            projection.remainingQuantity = projection.remainingQuantity + remaining
            if item.maxUnitPrice then
                projection.pricedEntries = projection.pricedEntries + 1
                local itemCost = math.min(
                    MAX_SAFE_COST,
                    remaining * item.maxUnitPrice
                )
                local capped
                projection.projectedRemaining, capped = addCost(
                    projection.projectedRemaining,
                    itemCost
                )
                projection.capped = projection.capped or capped
            else
                projection.unpricedEntries = projection.unpricedEntries + 1
            end
        end
    end

    local capped
    projection.projectedTotal, capped = addCost(
        projection.spent,
        projection.projectedRemaining
    )
    projection.capped = projection.capped or capped
    if list.budget then
        projection.budget = list.budget
        projection.remainingBudget = list.budget - projection.spent
        projection.projectedBudget = list.budget - projection.projectedTotal
    end
    return projection
end

function CostPlanning:GetSuggestion(item)
    local settings = self.owner.data:GetSettings()
    if settings.showPriceSuggestions == false or not self.owner.priceData then
        return nil
    end
    return self.owner.priceData:GetSuggestion(
        item and item.itemLink,
        settings.priceSource
    )
end

function CostPlanning:FormatProjection(projection, formatGold)
    local amount = formatGold or tostring
    local lines = {
        zo_strformat(
            GetString(SI_SHOPPING_LIST_COST_SPENT),
            amount(projection.spent)
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_COST_REMAINING),
            amount(projection.projectedRemaining)
        ),
        zo_strformat(
            GetString(SI_SHOPPING_LIST_COST_TOTAL),
            amount(projection.projectedTotal)
        ),
    }
    if projection.budget then
        lines[#lines + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_COST_BUDGET_REMAINING),
            amount(projection.remainingBudget)
        )
        lines[#lines + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_COST_BUDGET_AFTER_PLAN),
            amount(projection.projectedBudget)
        )
    else
        lines[#lines + 1] = GetString(SI_SHOPPING_LIST_COST_NO_BUDGET)
    end
    lines[#lines + 1] = zo_strformat(
        GetString(SI_SHOPPING_LIST_COST_UNPRICED),
        projection.unpricedEntries
    )
    if projection.capped then
        lines[#lines + 1] = GetString(SI_SHOPPING_LIST_COST_CAPPED)
    end
    return table.concat(lines, "\n")
end
