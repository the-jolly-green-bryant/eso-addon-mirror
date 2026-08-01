local SK = SwissKnife
local SKH = SK.HelperFunctions

local hooksOnBagsInitialized = false
local isFirstLoadUpdate = true

local function initHooksOnBags()
    if not hooksOnBagsInitialized then
        hooksOnBagsInitialized = true
        for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
            local listView = inventory.listView
            if listView and listView.dataTypes and listView.dataTypes[1] then
                ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
                    local bagId = control.dataEntry.data.bagId
                    local slotIndex = control.dataEntry.data.slotIndex
                    SKH.addCollectablesUnlockedOrLocked(control, bagId, slotIndex)
                end)
            end
        end
    end
end

local function validateCollectablesData(setId)
	local accName = SK.AccName
    local pieces, isFull = SKH.getSetIdCollectablesInfo(setId, nil, true)
    if not isFull then
	    if #pieces.unlocked > 0 then
		    SKH.setTableChild(SK.globalSV.trackedAccountsCollectionsItems, {accName, setId, "u"}, pieces.unlocked)
	    end
	    if #pieces.locked > 0 then
		    SKH.setTableChild(SK.globalSV.trackedAccountsCollectionsItems, {accName, setId, "l"}, pieces.locked)
	    end
	else
	    SKH.setTableChild(SK.globalSV.trackedAccountsCollectionsItems, {accName, setId}, nil)
    end
end

local function fillCollectablesData()
	-- prevent refresh data twice
	if SK.isAccountsCollectionsItemsDataLoad then return end
	if SK.globalSV.trackedAccountsCollectionsItems == nil then
		SK.globalSV.trackedAccountsCollectionsItems = {}
	end
	SK.globalSV.trackedAccountsCollectionsItems[SK.AccName] = {}
    local function GetNextItemSetCollectionIdIter(_, lastItemSetId)
        return GetNextItemSetCollectionId(lastItemSetId)
    end
    for setId in GetNextItemSetCollectionIdIter do
		validateCollectablesData(setId)
    end
	SK.isAccountsCollectionsItemsDataLoad = true
end

local function refreshCollectables(isCallLater)
    if isCallLater and not isFirstLoadUpdate then return end
	if not SK.savedVars.trackAccountsCollectionsItems then return end
	SK.ITEM_NAME_PIECE_ID_MAP = {}
	fillCollectablesData()
    SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKW, SI_SK_AUT_UPDATE_COLLECTABLES_ITEMS_COMPLETE)
    isFirstLoadUpdate = false
end

local function InitCollectables()
	SK.ITEM_NAME_PIECE_ID_MAP = {}
	zo_callLater(function() refreshCollectables(true) end,
		SK.timeoutAccountsCollectionsItemsDataLoad
	)
	initHooksOnBags()
end

SK.Collectables = {
	InitCollectables = InitCollectables,
	validateCollectablesData = validateCollectablesData,
	refreshCollectables = refreshCollectables
}
