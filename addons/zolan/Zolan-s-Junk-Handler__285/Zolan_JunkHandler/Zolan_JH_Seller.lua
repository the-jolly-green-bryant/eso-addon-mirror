--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Seller)
--------------------------------------------------------------------------------
local ZJH    = Zolan_JH
local Seller = ZJH.Seller
local BagCache = ZJH.BagCache
local ZL     = ZJH.ZL

-- ZO
local BAG_BACKPACK = BAG_BACKPACK
local GetBagSize   = GetBagSize
local GetItemInfo  = GetItemInfo
local GetItemLink  = GetItemLink
local HasAnyJunk   = HasAnyJunk
local IsItemJunk   = IsItemJunk
local IsItemStolen = IsItemStolen
local SellAllJunk  = SellAllJunk
local zo_strjoin   = zo_strjoin
-- Lua
local ipairs       = ipairs
local string       = string
local table        = table

function Seller:generateDetailsOfItemsToBeSold(atFence)
    local itemizedList = {}

    local bagID = BAG_BACKPACK

    local totalUniqueItemCount = 0
    local totalGold            = 0

    for slotID = 0, GetBagSize(bagID) do
        if IsItemJunk(bagID, slotID) then
            local _, stackCount, unitSellPrice = GetItemInfo(bagID, slotID)
			local isStolen = IsItemStolen(bagID, slotID)
			if ( atFence and isStolen ) or ( not atFence and not isStolen ) then
				local itemLink = GetItemLink(bagID, slotID, LINK_STYLE_DEFAULT)

				local totalSellPrice = unitSellPrice * stackCount

				totalUniqueItemCount = totalUniqueItemCount + 1
				totalGold            = totalGold + totalSellPrice

				table.insert(itemizedList, {
					["itemLink"]       = ZL:formatItemLink(itemLink),
					["stackCount"]     = stackCount,
					["totalSellPrice"] = totalSellPrice,
					["unitSellPrice"]  = unitSellPrice,
					["bagID"]          = bagID,
					["slotID"]         = slotID
				})
			end
        end
    end

    local summaryData = {
        ['totalUniqueItemCount'] = totalUniqueItemCount,
        ['totalGold']            = totalGold
    }

    return itemizedList, summaryData
end

function Seller:generateItemizedOutput(itemizedData)
    return string.format(
        "%sSold %s x %s%s(s) for %s%s gold%s. (%s%s gold%s each)",
        ZJH.Vars.defaultColor,
        itemizedData.stackCount,
        itemizedData.itemLink,
        ZJH.Vars.defaultColor,
        ZJH.Vars.currencyColor,
        itemizedData.totalSellPrice,
        ZJH.Vars.defaultColor,
        ZJH.Vars.currencyColor,
        itemizedData.unitSellPrice,
        ZJH.Vars.defaultColor
    );
end

function Seller:generateSummaryOutput(summaryData)
    return string.format(
        "%sSummary:%s Sold %s unique stacks of junk for a total of %s%s gold%s.",
        ZJH.Vars.headerColor,
        ZJH.Vars.defaultColor,
        summaryData.totalUniqueItemCount,
        ZJH.Vars.currencyColor,
        summaryData.totalGold,
        ZJH.Vars.defaultColor
    )
end

function Seller:outputReceipt(itemizedList, summaryData)
    if not HasAnyJunk(BAG_BACKPACK)    then
        if ZJH.settings.sellNotify then
            ZL:sendMessageToChat(string.format(
                '%s%s No Junk To Sell',
                ZJH.Vars.outputHeader,
                ZJH.Vars.defaultColor
            ))
        end
        return
    end

    local outputMessages = {}

    if ZJH.settings.sellNotify then
        table.insert(outputMessages,
            string.format(
                "%s%s Selling Your Junk.",
                ZJH.Vars.outputHeader,
                ZJH.Vars.defaultColor
            )
        )
    end

    if ZJH.settings.showItemized then
        for _,itemizedData in ipairs(itemizedList) do
            table.insert(outputMessages, self:generateItemizedOutput(itemizedData))
        end
    end


    if ZJH.settings.showSummary then
        table.insert(
            outputMessages,
            self:generateSummaryOutput(summaryData)
        )
    end

    if #outputMessages > 0 then
        ZL:sendMessageToChat(
            table.concat(outputMessages, "\n")
        )
    end
end

function Seller:sellAllJunk(atFence)
    ZL:debug("Seller -> handleOpenStore")
    if not ZJH.settings.enabled  then return end
    if not ZJH.settings.sellJunk then return end

    local itemizedList,summaryData = self:generateDetailsOfItemsToBeSold(atFence)

    delay = 0

    if ZJH.settings.useOldSellAllItems then
        SellAllJunk()
    else
        for _,itemizedData in ipairs(itemizedList) do
            delay = delay + ZJH.settings.msDelayBetweenSells
            zo_callLater(
                function()
                    SellInventoryItem(
                        itemizedData.bagID,
                        itemizedData.slotID,
                        itemizedData.stackCount
                    )
                end, delay
            )
        end
    end

    zo_callLater(
        function ()
            self:outputReceipt(itemizedList, summaryData)
            BagCache:refresh()
        end, delay
    )

    BagCache:refresh()
end
