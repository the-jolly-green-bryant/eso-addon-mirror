EVENT_LIB_ITEMS_FETCHER_FETCH_BEGIN = "EVENT_LIB_ITEMS_FETCHER_FETCH_BEGIN"
EVENT_LIB_ITEMS_FETCHER_FETCH_END = "EVENT_LIB_ITEMS_FETCHER_FETCH_END"
EVENT_LIB_ITEMS_FETCHER_ITEM_FETCHED = "EVENT_LIB_ITEMS_FETCHER_ITEM_FETCHED"

local function iter(start, finish)
    local counter = start - 1

    return function()
        counter = counter + 1

        if counter > finish then
            return nil
        end

        return counter
    end
end

local addon = ZO_CallbackObject:Subclass()
LibItemsFetcher = addon

function addon:New(...)
    local obj = ZO_CallbackObject.New(self)
    obj:initialize(...)
    return obj
end

function addon:initialize(chunkSize, chunkTimeout, notValidItemsThreshold)
    self.chunkSize = chunkSize or 1000
    self.chunkTimeout = chunkTimeout or 500
    self.notValidItemsThreshold = notValidItemsThreshold or 50000
    self.notValidItemsCounter = 0
    self.currentId = 0
end

function addon.fetchItem(id)
    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id)
    local itemName = GetItemLinkName(itemLink) or ""
    if itemName == "" then
        return nil
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    return {
        id = id,
        name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName),
        itemType = itemType,
        specializedItemType = specializedItemType,
    }
end

function addon:fetchChunk(start, finish)
    for id in iter(start, finish) do
        self.currentId = id
        if self.notValidItemsCounter > self.notValidItemsThreshold then
            self:FireCallbacks(EVENT_LIB_ITEMS_FETCHER_FETCH_END, self.currentId - 1)
            return
        end

        local data = self.fetchItem(id)
        if data == nil then
            self:FireCallbacks(EVENT_LIB_ITEMS_FETCHER_ITEM_FETCHED, id, false, nil)
            self.notValidItemsCounter = self.notValidItemsCounter + 1
        else
            self:FireCallbacks(EVENT_LIB_ITEMS_FETCHER_ITEM_FETCHED, id, true, data)
            self.notValidItemsCounter = 0
        end
    end

    zo_callLater(function()
        self:fetchChunk(finish + 1, finish + self.chunkSize)
    end, self.chunkTimeout)
end

function addon:Fetch()
    self:FireCallbacks(EVENT_LIB_ITEMS_FETCHER_FETCH_BEGIN)

    zo_callLater(function()
        self:fetchChunk(self.currentId + 1, self.currentId + self.chunkSize)
    end, self.chunkTimeout)
end
