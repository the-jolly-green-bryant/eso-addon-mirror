-- Cache the account name and date
local accountName = GetDisplayName()
local currentDate = os.date("%b %d, %y")

-- 2. Make our addon table local
local BananaAddon = {}

function BananaAddon.GetIngredientCount(itemId)
    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local count = GetItemLinkInventoryCount(itemLink, INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG)
    return count or 0
end

function BananaAddon.GetBananaCount()
    return BananaAddon.GetIngredientCount(33755)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "BananaParse" then return end
    
    EVENT_MANAGER:UnregisterForEvent("BananaParseEvent", EVENT_ADD_ON_LOADED)
    
    -- Inject the Watermark text right as the addon loads!
    if BananaParseWindowWatermark then
        BananaParseWindowWatermark:SetText(accountName .. "\n" .. currentDate)
    end

    SLASH_COMMANDS["/bananas"] = function()
        local count = BananaAddon.GetBananaCount()
        
        if BananaParseWindowCountLabel then
            BananaParseWindowCountLabel:SetText("Banana parse: " .. tostring(count))
            BananaParseWindow:SetHidden(false)
        else
            d(accountName .. " has " .. tostring(count) .. " Bananas.")
        end
    end
end

EVENT_MANAGER:RegisterForEvent("BananaParseEvent", EVENT_ADD_ON_LOADED, OnAddOnLoaded)