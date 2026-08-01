PITHKA = PITHKA or {}
PITHKA.groupFinder = PITHKA.groupFinder or {}

local GFDataStore = ZO_Object:Subclass()

-- Utility functions to replace ESO-specific ones
local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

local function tableContains(table, searchValue)
    for _, value in ipairs(table) do
        if value == searchValue then
            return true
        end
    end
    return false
end

-- Event types for callbacks
GFDataStore.EVENTS = {
    LISTING_ADDED = "LISTING_ADDED",
    LISTING_UPDATED = "LISTING_UPDATED",
    LISTING_REMOVED = "LISTING_REMOVED",
    STORE_CLEARED = "STORE_CLEARED"
}

function GFDataStore:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function GFDataStore:Initialize()
    self.listings = {}           -- Main storage: leader -> listing
    self.searchIndex = {}        -- Search params -> {leader1, leader2, ...}
    self.activityIndex = {}      -- activity -> {leader1, leader2, ...}
    self.callbacks = {}          -- event -> {callback1, callback2, ...}
    self.listingHistory = {}     -- leader -> {timestamp -> listing}
end

function GFDataStore:RegisterCallback(event, callback)
    self.callbacks[event] = self.callbacks[event] or {}
    table.insert(self.callbacks[event], callback)
end

function GFDataStore:UnregisterCallback(event, callback)
    if self.callbacks[event] then
        for i, cb in ipairs(self.callbacks[event]) do
            if cb == callback then
                table.remove(self.callbacks[event], i)
                break
            end
        end
    end
end

-- Convenience method to register for all listing changes
function GFDataStore:RegisterUpdateCallback(callback)
    if type(callback) == "function" then
        self:RegisterCallback(self.EVENTS.LISTING_ADDED, callback)
        self:RegisterCallback(self.EVENTS.LISTING_UPDATED, callback)
        self:RegisterCallback(self.EVENTS.LISTING_REMOVED, callback)
        self:RegisterCallback(self.EVENTS.STORE_CLEARED, callback)
    end
end

function GFDataStore:FireCallbacks(event, data)
    if self.callbacks[event] then
        for _, callback in ipairs(self.callbacks[event]) do
            callback(data)
        end
    end
end

-- Add or update a listing
function GFDataStore:UpsertListing(listing)
    local isNew = not self.listings[listing.leader]
    local oldListing = self.listings[listing.leader]
    
    -- Update main storage
    self.listings[listing.leader] = listing
    
    -- Update history
    self.listingHistory[listing.leader] = self.listingHistory[listing.leader] or {}
    self.listingHistory[listing.leader][GetTimeStamp()] = shallowCopy(listing)
    
    -- Update search index (use searchParams as key)
    local searchKey = listing.searchParams or listing.searchKey
    self.searchIndex[searchKey] = self.searchIndex[searchKey] or {}
    if not tableContains(self.searchIndex[searchKey], listing.leader) then
        table.insert(self.searchIndex[searchKey], listing.leader)
    end
    
    -- Update activity index
    self.activityIndex[listing.specificActivity] = self.activityIndex[listing.specificActivity] or {}
    if not tableContains(self.activityIndex[listing.specificActivity], listing.leader) then
        table.insert(self.activityIndex[listing.specificActivity], listing.leader)
    end
    
    -- Fire appropriate callback
    if isNew then
        self:FireCallbacks(self.EVENTS.LISTING_ADDED, listing)
    else
        self:FireCallbacks(self.EVENTS.LISTING_UPDATED, {old = oldListing, new = listing})
    end
end

-- Remove a listing
function GFDataStore:RemoveListing(leader)
    local listing = self.listings[leader]
    if not listing then return end
    
    -- Remove from main storage
    self.listings[leader] = nil
    
    -- Remove from search index (use searchParams as key)
    local searchKey = listing.searchParams or listing.searchKey
    if self.searchIndex[searchKey] then
        for i, l in ipairs(self.searchIndex[searchKey]) do
            if l == leader then
                table.remove(self.searchIndex[searchKey], i)
                break
            end
        end
        -- Clean up empty search index entries
        if #self.searchIndex[searchKey] == 0 then
            self.searchIndex[searchKey] = nil
        end
    end
    
    -- Remove from activity index
    if self.activityIndex[listing.specificActivity] then
        for i, l in ipairs(self.activityIndex[listing.specificActivity]) do
            if l == leader then
                table.remove(self.activityIndex[listing.specificActivity], i)
                break
            end
        end
        -- Clean up empty activity index entries
        if #self.activityIndex[listing.specificActivity] == 0 then
            self.activityIndex[listing.specificActivity] = nil
        end
    end
    
    -- Fire callback
    self:FireCallbacks(self.EVENTS.LISTING_REMOVED, listing)
end

-- Clear listings by search params/key
function GFDataStore:ClearSearchResults(searchKey)
    if not searchKey or not self.searchIndex[searchKey] then 
        return 
    end
    
    -- Copy the array since we'll be modifying it during iteration
    local leaders = shallowCopy(self.searchIndex[searchKey])
    local removedCount = 0
    
    for _, leader in ipairs(leaders) do
        if self.listings[leader] then
            self:RemoveListing(leader)
            removedCount = removedCount + 1
        end
    end
    
    -- Clean up the search index entry
    self.searchIndex[searchKey] = nil
    
    return removedCount
end

-- Get all listings
function GFDataStore:GetAllListings()
    return self.listings
end

-- Get listings by search params
function GFDataStore:GetListingsBySearchParams(searchParams)
    local results = {}
    if self.searchIndex[searchParams] then
        for _, leader in ipairs(self.searchIndex[searchParams]) do
            if self.listings[leader] then
                table.insert(results, self.listings[leader])
            end
        end
    end
    return results
end

-- Get listings by activity
function GFDataStore:GetListingsByActivity(activity)
    local results = {}
    if self.activityIndex[activity] then
        for _, leader in ipairs(self.activityIndex[activity]) do
            if self.listings[leader] then
                table.insert(results, self.listings[leader])
            end
        end
    end
    return results
end

-- Get listing history for a leader
function GFDataStore:GetListingHistory(leader)
    return self.listingHistory[leader]
end

-- Clear all data
function GFDataStore:Clear()
    self.listings = {}
    self.searchIndex = {}
    self.activityIndex = {}
    -- Note: We keep the history
    
    self:FireCallbacks(self.EVENTS.STORE_CLEARED)
end

function GFDataStore:ClearAll()
    self.listings = {}
    self.searchIndex = {}
    self.activityIndex = {}
    -- Note: We keep the history
    self:FireCallbacks(self.EVENTS.STORE_CLEARED)
end

-- Export the module
PITHKA.groupFinder.DataStore = GFDataStore