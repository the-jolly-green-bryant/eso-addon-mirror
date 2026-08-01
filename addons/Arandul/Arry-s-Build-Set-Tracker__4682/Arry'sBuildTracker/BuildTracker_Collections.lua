-- BuildTracker_Collections.lua
--
-- Wraps ESO's built-in "Set Item Collections" (Sticker Book) API - the
-- permanent, account-wide record of every set piece you've ever bound.
-- Once a piece is in there, ZOS lets you Reconstruct it at a transmute
-- station for crystals, regardless of whether you still physically own
-- the original item. That makes it a far more reliable "do I still need
-- to go find this" signal than bag/bank/craft bag contents, which go
-- stale the moment a piece gets deconstructed, sold, or traded away.
--
-- CREDIT WHERE DUE: the correct function here - IsItemSetCollectionPieceUnlocked(itemId),
-- a single-argument base-game global - was found by reading the AutoCategory
-- addon's source (AutoCategory_RuleFunc.lua), after several increasingly
-- convoluted attempts to derive the right itemSetId/slot pair from
-- LibSets-documented functions all turned out to be unnecessary. Much
-- simpler than expected: no itemSetId, no id64 slot value, just the itemId.
--
-- CAVEAT: crafted sets are NOT tracked in the Collections menu at all -
-- they're not "collected" from the world, so there's nothing to look up
-- (you just craft another one anytime). IsItemLinkCrafted() is used to
-- detect this and correctly return nil (unknown) rather than false
-- (which would incorrectly imply "confirmed missing").

BuildTracker = BuildTracker or {}
BuildTracker.Collections = {}

local Collections = BuildTracker.Collections

-- Returns true (collected/reconstructable), false (confirmed not
-- collected), or nil (couldn't determine - most commonly a crafted set).
--
-- setId (LibSets' bonus setId) is accepted for API stability but not
-- needed for the lookup itself.
function Collections.IsItemCollected(setId, itemId)
    if not itemId then return nil end

    local itemLink = BuildTracker.Sets.BuildItemLink(itemId)
    if itemLink then
        local ok, isCrafted = pcall(IsItemLinkCrafted, itemLink)
        if ok and isCrafted then
            return nil
        end
    end

    local ok, isUnlocked = pcall(IsItemSetCollectionPieceUnlocked, itemId)
    if ok then
        return isUnlocked
    end
    return nil
end
