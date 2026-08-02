NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local CollectionsGearData = {}

local COLLECTION_SCAN_PADDING = 100
local FALLBACK_SCAN_MAX = 2000

local function GetCraftedSetScanMaximum()
    if not GetNextItemSetCollectionId then
        return FALLBACK_SCAN_MAX
    end

    local maximumSetId = 0
    local itemSetId = GetNextItemSetCollectionId(nil)
    while itemSetId do
        maximumSetId = math.max(maximumSetId, itemSetId)
        itemSetId = GetNextItemSetCollectionId(itemSetId)
    end
    if maximumSetId == 0 then
        return FALLBACK_SCAN_MAX
    end
    return maximumSetId + COLLECTION_SCAN_PADDING
end

function CollectionsGearData.AppendCraftedSetIds(output)
    if not GetItemSetType or ITEM_SET_TYPE_CRAFTED == nil then
        return 0
    end

    local initialCount = #output
    for itemSetId = 1, GetCraftedSetScanMaximum() do
        if GetItemSetType(itemSetId) == ITEM_SET_TYPE_CRAFTED then
            output[#output + 1] = itemSetId
        end
        if NCollections.Util and NCollections.Util.FrameTaskCheckpoint then
            NCollections.Util.FrameTaskCheckpoint(itemSetId, 25)
        end
    end
    return #output - initialCount
end

NCollections.Features.CollectionsGearData = CollectionsGearData
