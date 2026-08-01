-- BuildTracker_Notifications.lua
--
-- Chat alert when you (or a groupmate, in Need/Greed or Round Robin loot
-- content) loot an item matching a set piece a registered build still
-- needs. "Still needs" means the build's assigned itemId for that slot
-- isn't Collection-unlocked yet (BuildTracker.Collections.IsItemCollected)
-- - once you've reconstructed/collected a piece, further copies of it
-- aren't useful, so no point alerting on those.
--
-- EVENT_LOOT_RECEIVED already tells us who looted it (the isSelf flag) and
-- the raw itemId, without needing to touch the other addon mentioned during
-- planning that graphically displays loot - this hooks the base game event
-- directly, independent of whatever other loot-display addons are running.
--
-- Matching is by Collections "setId:slotKey" (BuildTracker.Sets.
-- GetCollectionsSlotKey), not raw itemId equality - the same alias-itemId
-- gotcha documented in PROJECT_STATUS.md (gotcha #5) means two different
-- itemIds can be the exact same conceptual Collections piece, and raw
-- itemId equality would miss that.

BuildTracker = BuildTracker or {}
BuildTracker.Notifications = {}

local Notifications = BuildTracker.Notifications

-- Converts a 0-1 float RGB triple (LibAddonMenu-2.0 colorpicker's native
-- format, see BuildTracker_Settings.lua) to the "RRGGBB" hex string ESO's
-- |cRRGGBB chat color escape expects. Rounds rather than truncates so a
-- picked pure white (1,1,1) reliably comes out FFFFFF, not FEFEFE.
local function ColorToHex(r, g, b)
    return string.format("%02X%02X%02X",
        math.floor((r or 1) * 255 + 0.5),
        math.floor((g or 1) * 255 + 0.5),
        math.floor((b or 1) * 255 + 0.5))
end

-- Every "BuildName (SlotName)" pair, across all builds, whose assigned
-- piece for this exact setId+Collections-slot-key isn't unlocked yet.
local function FindNeedingBuilds(setId, lootedSlotKey)
    local Sets = BuildTracker.Sets
    local Data = BuildTracker.Data
    local Collections = BuildTracker.Collections

    local needed = {}
    for _, buildInfo in ipairs(Data.GetAllBuildsSorted()) do
        local build = Data.GetBuild(buildInfo.id)
        if build then
            for slotId, slotData in pairs(build.slots) do
                if slotData.setId == setId then
                    local link = Sets.BuildItemLink(slotData.itemId)
                    local slotKey = link and Sets.GetCollectionsSlotKey(link)
                    if slotKey and slotKey == lootedSlotKey then
                        if Collections.IsItemCollected(setId, slotData.itemId) == false then
                            table.insert(needed, string.format("%s (%s)", build.name, BuildTracker.SLOT_NAMES[slotId] or "?"))
                        end
                    end
                end
            end
        end
    end
    return needed
end

-- EVENT_LOOT_RECEIVED(receivedBy, itemName, quantity, soundCategory,
-- lootType, isSelf, isPickpocketLoot, questItemIcon, itemId, isStolen) -
-- confirmed signature/param order via LuiExtended's documented handler and
-- cross-checked against MapPins' own real usage. Note the 2nd param is a
-- plain display name string, NOT an itemLink - the itemId (9th param) is
-- what we actually need, fed through Sets.BuildItemLink like every other
-- itemId->set lookup in this addon.
local function OnLootReceived(_, receivedBy, itemName, _, _, lootType, isSelf, _, _, itemId)
    if lootType ~= LOOT_TYPE_ITEM then return end
    if not itemId then return end

    local Data = BuildTracker.Data
    if not Data.GetNotifyOnLoot() then return end
    if isSelf and not Data.GetNotifyOnLootSelf() then return end
    if not isSelf and not Data.GetNotifyOnLootGroup() then return end

    local Sets = BuildTracker.Sets
    local itemLink = Sets.BuildItemLink(itemId)
    if not itemLink then return end

    local ok, hasSet, _, _, _, _, setId = pcall(GetItemLinkSetInfo, itemLink, false)
    if not ok or not hasSet or not setId then return end

    local lootedSlotKey = Sets.GetCollectionsSlotKey(itemLink)
    if not lootedSlotKey then return end

    local needed = FindNeedingBuilds(setId, lootedSlotKey)
    if #needed == 0 then return end

    -- A single "BuildName (SlotName)" is worth naming; once more than one
    -- build needs it, naming all of them just clutters a busy chat log
    -- during a dungeon/trial run - "needed for multiple builds" says
    -- everything that actually matters (go check /bt ui to see which).
    local neededText
    if #needed == 1 then
        neededText = "needed for: " .. needed[1]
    else
        neededText = "needed for multiple builds"
    end

    local looter = isSelf and "You" or (receivedBy or "A groupmate")
    local alertColor = isSelf and ColorToHex(Data.GetSelfLootColor()) or ColorToHex(Data.GetGroupLootColor())
    d(string.format("|c%s[BT] %s looted %s - %s|r", alertColor, looter, itemName or "an item", neededText))
end

function Notifications.Initialize()
    EVENT_MANAGER:RegisterForEvent(BuildTracker.name .. "_Loot", EVENT_LOOT_RECEIVED, OnLootReceived)
end
