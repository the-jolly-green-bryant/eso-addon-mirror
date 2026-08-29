ShoppingListTradingIndicators = {}

local Indicators = ShoppingListTradingIndicators
local INDICATOR_NAME = "ShoppingListResultIndicator"

local function getResultDetails(result)
    if type(result) ~= "table" then
        return nil
    end
    local itemLink = result.itemLink
    local itemName = result.itemName or result.name
    local stackCount = tonumber(result.stackCount)
    local unitPrice = tonumber(result.purchasePricePerUnit)
    local slotIndex = tonumber(result.slotIndex)
    if (not itemLink or itemLink == "") and slotIndex then
        itemLink = GetTradingHouseSearchResultItemLink(
            slotIndex,
            LINK_STYLE_DEFAULT
        )
    end
    if (not itemName or itemName == "") and itemLink and itemLink ~= "" then
        itemName = GetItemLinkName(itemLink)
    end
    if (not stackCount or not unitPrice) and slotIndex then
        local _, nativeName, _, nativeStack, _, _, totalPrice, _, _, nativeUnit =
            GetTradingHouseSearchResultItemInfo(slotIndex)
        itemName = itemName or nativeName
        stackCount = stackCount or nativeStack
        unitPrice = unitPrice or nativeUnit
        if not unitPrice and totalPrice and nativeStack and nativeStack > 0 then
            unitPrice = totalPrice / nativeStack
        end
    end
    if not itemLink or itemLink == "" then
        return nil
    end
    return itemLink, itemName, math.max(1, stackCount or 1), unitPrice or 0
end

function Indicators:New(owner)
    return setmetatable({ owner = owner, hooked = {} }, { __index = self })
end

function Indicators:Evaluate(itemLink, itemName, stackCount, unitPrice)
    local best
    for index, item in ipairs(self.owner.data:GetShoppingItems()) do
        local score = self.owner.matcher:GetItemMatchScore(
            item,
            itemLink,
            itemName
        )
        if score then
            local remaining = self.owner.data:GetRemainingQuantity(item)
            local candidate = {
                item = item,
                index = index,
                score = score,
                remaining = remaining,
            }
            if not best
                or (remaining > 0 and best.remaining == 0)
                or ((remaining > 0) == (best.remaining > 0)
                    and (score > best.score
                        or (score == best.score and index < best.index)))
            then
                best = candidate
            end
        end
    end
    if not best then
        return nil
    end
    best.unitPrice = math.max(0, tonumber(unitPrice) or 0)
    best.stackCount = math.max(1, tonumber(stackCount) or 1)
    best.hasRules = self.owner.data:ItemHasMatchingRules(best.item)
    best.withinTarget = best.item.maxUnitPrice == nil
        or best.unitPrice <= best.item.maxUnitPrice
    best.hasTarget = best.item.maxUnitPrice ~= nil
    best.wouldComplete = best.remaining > 0
        and best.stackCount >= best.remaining
    return best
end

function Indicators:Format(result)
    local parts = { "SL" }
    if result.hasTarget then
        parts[#parts + 1] = result.withinTarget and "≤" or ">"
    end
    if result.wouldComplete then parts[#parts + 1] = "+" end
    if result.hasRules then parts[#parts + 1] = "R" end
    return "[" .. table.concat(parts, " ") .. "]"
end

function Indicators:TooltipText(result)
    local lines = {
        zo_strformat(
            GetString(SI_SHOPPING_LIST_RESULT_MATCH),
            result.item.name,
            result.remaining
        ),
    }
    if result.hasTarget then
        lines[#lines + 1] = GetString(result.withinTarget
            and SI_SHOPPING_LIST_RESULT_WITHIN_TARGET
            or SI_SHOPPING_LIST_RESULT_OVER_TARGET)
    else
        lines[#lines + 1] = GetString(SI_SHOPPING_LIST_RESULT_NO_TARGET)
    end
    lines[#lines + 1] = GetString(result.wouldComplete
        and SI_SHOPPING_LIST_RESULT_COMPLETES
        or SI_SHOPPING_LIST_RESULT_PARTIAL)
    if result.hasRules then
        lines[#lines + 1] = GetString(SI_SHOPPING_LIST_RESULT_RULE_MATCH)
    end
    return table.concat(lines, "\n")
end

function Indicators:SetupRow(rowControl, resultData)
    local itemLink, itemName, stackCount, unitPrice = getResultDetails(resultData)
    local match = itemLink and self:Evaluate(
        itemLink,
        itemName,
        stackCount,
        unitPrice
    ) or nil
    local label = rowControl:GetNamedChild(INDICATOR_NAME)
    if not label then
        label = WINDOW_MANAGER:CreateControl(
            "$(parent)" .. INDICATOR_NAME,
            rowControl,
            CT_LABEL
        )
        label:SetDimensions(105, 24)
        label:SetAnchor(RIGHT, rowControl, RIGHT, -145, -9)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetFont("ZoFontGameSmall")
        label:SetMouseEnabled(true)
        label:SetHandler("OnMouseEnter", function(control)
            if not control.shoppingListResult then return end
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4, TOP)
            SetTooltipText(
                InformationTooltip,
                self:TooltipText(control.shoppingListResult)
            )
        end)
        label:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    end
    label.shoppingListResult = match
    label:SetHidden(match == nil)
    if match then
        label:SetText(self:Format(match))
        if match.hasTarget and not match.withinTarget then
            label:SetColor(1, 0.35, 0.3, 1)
        elseif match.remaining == 0 then
            label:SetColor(0.62, 0.62, 0.62, 1)
        elseif match.withinTarget then
            label:SetColor(0.45, 0.9, 0.45, 1)
        else
            label:SetColor(0.9, 0.78, 0.4, 1)
        end
    end
end

function Indicators:HookList(listControl)
    if not listControl then return false end
    local dataType = listControl.dataTypes and listControl.dataTypes[1]
        or (ZO_ScrollList_GetDataTypeTable
            and ZO_ScrollList_GetDataTypeTable(listControl, 1))
    if not dataType or type(dataType.setupCallback) ~= "function" then
        return false
    end
    if self.hooked[listControl] == dataType.setupCallback then
        return true
    end
    local original = dataType.setupCallback
    local wrapper = function(rowControl, resultData)
        original(rowControl, resultData)
        self:SetupRow(rowControl, resultData)
    end
    dataType.setupCallback = wrapper
    self.hooked[listControl] = wrapper
    return true
end

function Indicators:HookResultRows()
    self:HookList(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
    local browse = GAMEPAD_TRADING_HOUSE_BROWSE
    local gamepadList = browse and browse.itemList
        and (browse.itemList.list or browse.itemList.control)
    self:HookList(gamepadList)
end

function Indicators:Initialize()
    self:HookResultRows()
    local ags = AwesomeGuildStore
    if ags and ags.RegisterCallback and ags.callback then
        if ags.callback.AFTER_INITIAL_SETUP then
            ags:RegisterCallback(ags.callback.AFTER_INITIAL_SETUP, function()
                self:HookResultRows()
            end)
        end
    end
end

function Indicators:Refresh()
    self:HookResultRows()
    local list = ZO_TradingHouseBrowseItemsRightPaneSearchResults
    if list and ZO_ScrollList_RefreshVisible then
        ZO_ScrollList_RefreshVisible(list)
    end
end
