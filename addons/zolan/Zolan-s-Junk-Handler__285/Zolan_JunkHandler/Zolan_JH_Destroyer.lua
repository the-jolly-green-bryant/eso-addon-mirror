--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Seller)
--------------------------------------------------------------------------------
local ZJH       = Zolan_JH
local Destroyer = ZJH.Destroyer
local ZL        = ZJH.ZL

Destroyer.itemTimerCache = {}

-- ZO
local LINK_STYLE_BRACKETS = LINK_STYLE_DEFAULT
local DestroyItem         = DestroyItem
local GetItemInfo         = GetItemInfo
local GetItemLink         = GetItemLink
local IsItemJunk          = IsItemJunk
local zo_callLater        = zo_callLater
local zo_strjoin          = zo_strjoin
local d                   = d
-- Lua
local string              = string

function Destroyer:shouldDestroyItem(bagID, slotID)
    ZL:debug("Destroyer -> shouldDestroyItem")
    if not ZJH.settings.destroyAcknowledge then return end

    local _, stackCount, unitSellPrice = GetItemInfo(bagID, slotID)

    -- Safety catch so it won't destroy stacks.
    if ZJH.settings.noDestroyStackOver then
        if stackCount > ZJH.settings.noDestroyStackOverCount then
            return false, nil
        end
    end
    if ZJH.settings.destroyZeroGold then
        if unitSellPrice == 0 then
            return true, 'Is Worth Zero Gold'
        end
    end

    if ZJH.settings.destroyCheap then

        local compareSellPrice
        local additionalReason = ''

        if ZJH.settings.destroyCheapUnitPrice then
            compareSellPrice = unitSellPrice
        else
            compareSellPrice = unitSellPrice * stackCount
            additionalReason = 'Stack '
        end

        if compareSellPrice <= ZJH.settings.destroyCheapValue then
            return true, additionalReason..'Is Worth ' .. ZJH.settings.destroyCheapValue .. ' Gold Or Less'
        end
    end

    return false, nil
end

function Destroyer:destroyItem(bagID, slotID, reason)
    ZL:debug("Destroyer -> destroyItem")
    if not ZJH.settings.destroyAcknowledge then return end

    local cacheKey = zo_strjoin(
        ':',
        ZL:getUniqueItemKey(bagID, slotID),
        bagID,
        slotID
    )

    if not Destroyer.itemTimerCache[cacheKey] then return end

    local red = '|cFF0000'

    if IsItemJunk(bagID, slotID) then
        if ZJH.settings.destroyItemNotify and (not ZJH.settings.destroyBlindTrust) then
            ZL:sendMessageToChat(string.format(
                "%sDestroyed Item %s%s Because It %s",
                red,
                ZL:formatItemLink(GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)),
                red,
                reason
            ))
        end

        -- Sweet Jesus...
        DestroyItem(bagID,slotID)
    end

    Destroyer.itemTimerCache[cacheKey] = nil
end

function Destroyer:markItemToBeDestroyed(bagID,slotID,reason)
    ZL:debug("Destroyer -> destroyIfAppropriate")

    local cacheKey = zo_strjoin(
        ':',
        ZL:getUniqueItemKey(bagID, slotID),
        bagID,
        slotID
    )

    if Destroyer.itemTimerCache[cacheKey] == 1 then return end


    Destroyer.itemTimerCache[cacheKey] = 1

    local destroyInSeconds      = ZJH.settings['destroyDelayInSeconds']
    local destroyInMilliseconds = destroyInSeconds * 1000

    if destroyInSeconds >= 1 then
        local red = '|cFF0000'
        if not ZJH.settings.markAsJunkNotify and (not ZJH.settings.destroyBlindTrust) then
            ZL:sendMessageToChat(string.format(
                "%sDetroying Item %s%s In %s Seconds Because It %s.  Unmark As Junk To Cancel.",
                red,
                ZL:formatItemLink(GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)),
                red,
                destroyInSeconds,
                reason
            ))
        end

        zo_callLater(
            function()
                Destroyer:destroyItem(bagID, slotID, reason)
            end,
            destroyInMilliseconds
        )
    elseif destroyInSeconds == 0 then
        Destroyer:destroyItem(bagID, slotID, reason)
    else
        d(ZJH.Vars.outputHeader .. " SOMETHING IS WRONG WITH YOUR SETTINGS!!")
    end
end

function Destroyer:destroyIfAppropriate(bagID, slotID)
    ZL:debug("Destroyer -> destroyIfAppropriate")
    if not ZJH.settings.destroyAcknowledge then return end

    local shouldDestroy, reason = Destroyer:shouldDestroyItem(bagID, slotID)

    if shouldDestroy then Destroyer:markItemToBeDestroyed(bagID, slotID, reason) end
end

function Destroyer:junkNotificationTag(bagID, slotID)
    ZL:debug("Destroyer -> junkNotificationTag")

    local destroyNotification = ''
    local willDestroy,destroyReason = Destroyer:shouldDestroyItem(bagID, slotID)

    if ZJH.settings.markAsJunkNotify then
        if willDestroy then
            local red              = '|cFF0000'
            local destroyInSeconds = ZJH.settings['destroyDelayInSeconds']

            destroyNotification = string.format(
                ' %s[%sItem %s And Will Be Destroyed In %s Seconds%s]',
                ZJH.Vars.defaultColor,
                red,
                destroyReason,
                destroyInSeconds,
                ZJH.Vars.defaultColor
            )
        end
    end

    return destroyNotification
end
