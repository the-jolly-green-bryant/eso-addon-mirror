-- ============================================
-- TOOLTIP HOOKS
-- ============================================

local function isItemWishlisted(itemLink)
    if not NWT.savedVars or not NWT.savedVars.wishlist then return false, nil, 0 end
    local itemId = GetItemLinkItemId(itemLink)
    local itemName = GetItemLinkName(itemLink)
    local nameKey = itemName and ("name_" .. itemName) or nil
    
    for projectName, items in pairs(NWT.savedVars.wishlist.projects) do
        if itemId and itemId > 0 and items[itemId] then return true, projectName, items[itemId].count or 1 end
        if nameKey and items[nameKey] then return true, projectName, items[nameKey].count or 1 end
        if itemName and itemName ~= "" then
            for _, data in pairs(items) do
                if data.name and data.name == itemName then return true, projectName, data.count or 1 end
            end
        end
    end
    return false, nil, 0
end

local function addPriceToTooltip(tooltip, itemLink)
    local priceSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
    if not priceSection then return false end
    
    local wishlisted, projectName, count = isItemWishlisted(itemLink)
    if wishlisted then
        priceSection:AddLine("|c00FF00★ WISHLISTED|r (" .. projectName .. (count > 1 and " x" .. count or "") .. ")", tooltip:GetStyle("bodyDescription"))
    end
    
    -- Only show price in tooltip if item is NOT bound (users use tooltip for pricing)
    local isBound = IsItemLinkBound(itemLink)
    if not isBound then
        local price = NWT.GetPrice(itemLink)
        if price then
            priceSection:AddLine("NWT: |cDBC14D" .. NWT.FormatGold(price) .. "g|r", tooltip:GetStyle("bodyDescription"))
            local backpack, bank, craftBag, houseBanks, furnitureVault, vengeanceBag = GetItemLinkStacks(itemLink)
            local totalStacks = (backpack or 0) + (bank or 0) + (craftBag or 0) + (houseBanks or 0) + (furnitureVault or 0) + (vengeanceBag or 0)
            if totalStacks > 1 then
                priceSection:AddLine("Stack (" .. totalStacks .. "): |cDBC14D" .. NWT.FormatGold(price * totalStacks) .. "g|r", tooltip:GetStyle("bodyDescription"))
            end
        end
    end
    
    local hasContent = wishlisted or (not isBound and NWT.GetPrice(itemLink))
    if hasContent then
        tooltip:AddSection(priceSection)
        return true
    end
    return false
end

local function addPriceToGamepadTooltip(tooltipObject, tooltipType, itemLink)
    if not tooltipType or not tooltipObject or type(itemLink) ~= "string" then return end
    local tooltip = tooltipObject:GetTooltip(tooltipType)
    if not tooltip then return end
    pcall(addPriceToTooltip, tooltip, itemLink)
end

function NWT.hookGamepadTooltips()
    local function OnTooltipActivated()
        EVENT_MANAGER:UnregisterForEvent("NWT_TooltipHook", EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            if GAMEPAD_TOOLTIPS then
                local leftTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
                local rightTooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
                if leftTooltip then
                    if leftTooltip.AddItemTitle then ZO_PostHook(leftTooltip, "AddItemTitle", function(self, itemLink) addPriceToGamepadTooltip(GAMEPAD_TOOLTIPS, GAMEPAD_LEFT_TOOLTIP, itemLink) end)
                    elseif leftTooltip.LayoutItem then ZO_PostHook(leftTooltip, "LayoutItem", function(self, itemLink) addPriceToGamepadTooltip(GAMEPAD_TOOLTIPS, GAMEPAD_LEFT_TOOLTIP, itemLink) end) end
                end
                if rightTooltip then
                    if rightTooltip.AddItemTitle then ZO_PostHook(rightTooltip, "AddItemTitle", function(self, itemLink) addPriceToGamepadTooltip(GAMEPAD_TOOLTIPS, GAMEPAD_RIGHT_TOOLTIP, itemLink) end)
                    elseif rightTooltip.LayoutItem then ZO_PostHook(rightTooltip, "LayoutItem", function(self, itemLink) addPriceToGamepadTooltip(GAMEPAD_TOOLTIPS, GAMEPAD_RIGHT_TOOLTIP, itemLink) end) end
                end
            end
        end, 1000)
    end
    EVENT_MANAGER:RegisterForEvent("NWT_TooltipHook", EVENT_PLAYER_ACTIVATED, OnTooltipActivated)
end
