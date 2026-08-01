--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Bag Cache)
--------------------------------------------------------------------------------
local ZJH = Zolan_JH

local BagCache  = ZJH.BagCache
local Destroyer = ZJH.Destroyer
local Junker    = ZJH.Junker
local ZL        = ZJH.ZL

-- ZO
local BAG_BACKPACK = BAG_BACKPACK
local GetBagSize   = GetBagSize
local GetItemLink  = GetItemLink
local IsItemJunk   = IsItemJunk
-- Lua
local string       = string

function BagCache:clear()
    ZL:debug('BagCache -> clear')
    self._cache = {}
end

function BagCache:refresh()
    ZL:debug('BagCache -> refresh')
    BagCache:clear()

    for slotID = 0, GetBagSize(BAG_BACKPACK) do
        local itemKey = ZL:getUniqueItemKey(BAG_BACKPACK, slotID)
        self._cache[itemKey] = IsItemJunk(BAG_BACKPACK, slotID)
    end
end

function BagCache:checkJunkStatusChange(bagID, slotID)
    ZL:debug('BagCache -> checkJunkStatusChange')

    local isJunk  = IsItemJunk(bagID, slotID)
    local itemKey = ZL:getUniqueItemKey(bagID, slotID)

    -- Ignore the change, it was automarked.
    if Junker.autoMarked[itemKey] then return end

    if self._cache[itemKey] ~= nil then
        if not self._cache[itemKey] == isJunk then
            if isJunk then
                if (ZJH.settings.markUserMarkedAsJunk)
                   and (not Junker.autoMarked[itemKey])
                   and (not ZJH.settings.tracking.userMarked[itemKey]) then

                    if ZJH.settings.markAsJunkNotify then
                        ZL:sendMessageToChat(string.format(
                            '%sTracking %s%s As User Specified Junk %s',
                            ZJH.Vars.defaultColor,
                            ZL:formatItemLink(GetItemLink(bagID, slotID, LINK_STYLE_DEFAULT)),
                            ZJH.Vars.defaultColor,
                            Destroyer:junkNotificationTag(bagID, slotID)
                        ))
                    end

                    ZJH.settings.tracking.userMarked[itemKey] = true
                    Destroyer:destroyIfAppropriate(bagID, slotID)
                end
            else
                if (ZJH.settings.markUserMarkedAsJunk)
                   and (not Junker.autoMarked[itemKey])
                   and (ZJH.settings.tracking.userMarked[itemKey]) then
                    if ZJH.settings.markAsJunkNotify then
                        ZL:sendMessageToChat(string.format(
                            '%sNo Longer Tracking %s%s As User Specified Junk',
                            ZJH.Vars.defaultColor,
                            ZL:formatItemLink(GetItemLink(bagID, slotID, LINK_STYLE_DEFAULT)),
                            ZJH.Vars.defaultColor
                        ))
                    end

                    ZJH.settings.tracking.userMarked[itemKey] = nil
                end
            end
        end
    end
end
