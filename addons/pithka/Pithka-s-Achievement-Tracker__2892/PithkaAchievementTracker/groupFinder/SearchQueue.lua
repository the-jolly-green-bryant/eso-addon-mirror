PITHKA = PITHKA or {}
PITHKA.groupFinder = PITHKA.groupFinder or {}

local debug_enabled = false -- Set to true to enable debug output for testing
local function debug(msg)
    if debug_enabled then
        d("|cFF8800[SearchQueue Debug]|r " .. tostring(msg))
    end
end


local GFSearchQueue = ZO_Object:Subclass()

-- Priority levels
GFSearchQueue.PRIORITY = {
    HIGH = 1,   -- For targeted searches (joining)
    NORMAL = 2, -- For regular search rotation
}


function GFSearchQueue:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function GFSearchQueue:Initialize()
    self.queue = {}
    self.history = {}
    self.currentSearch = nil
    self.totalSearches = 0 -- Track total number of searches in the current cycle
    self.searchCounter = 0 -- Track total number of searches executed ever, used for visual sugar
    self.dataStore = nil -- Reference to datastore for cleanup operations
end

-- Set the datastore reference for cleanup operations
function GFSearchQueue:SetDataStore(dataStore)
    self.dataStore = dataStore
end

-- Generate a unique key for a search combination (no longer includes role)
function GFSearchQueue:GenerateSearchKey(category, difficulty)
    return string.format("%s_%s", tostring(category), tostring(difficulty))
end

-- Create a search object (role parameter removed)
function GFSearchQueue:CreateSearch(category, difficulty, priority)
    return {
        category = category,
        difficulty = difficulty,
        role = nil, -- No longer used - API will return all roles
        priority = priority or self.PRIORITY.NORMAL,
        timestamp = GetTimeStamp(),
        searchKey = self:GenerateSearchKey(category, difficulty),
    }
end

-- Add a search to the queue
function GFSearchQueue:Enqueue(search)
    -- Add to queue based on priority
    if search.priority == self.PRIORITY.HIGH then
        table.insert(self.queue, 1, search)
    else
        table.insert(self.queue, search)
    end
    self:UpdateTotalSearches()
end

-- Get next search from queue
function GFSearchQueue:Dequeue()
    return table.remove(self.queue, 1)
end

-- Move current search to history and get next
function GFSearchQueue:Next(currentState)
    local StateMachine = PITHKA.groupFinder.StateMachine
    local search
    
    debug(string.format("[Next] Called with state: %s, queue length: %d", tostring(currentState), #self.queue))
    if #self.queue > 0 then
        debug(string.format("[Next] First search in queue has priority: %s", tostring(self.queue[1].priority)))
    end
    
    if currentState == StateMachine.STATES.JOINING then
        if #self.queue == 0 or self.queue[1].priority ~= self.PRIORITY.HIGH then
            debug("[Next] Expected priority search at front of queue in JOINING state!")
            return nil
        end
        search = table.remove(self.queue, 1)
        debug(string.format("[Next] Removed priority search from queue in JOINING state"))
    else -- SEARCHING or other states
        search = table.remove(self.queue, 1)
        if search and search.priority ~= self.PRIORITY.HIGH then
            table.insert(self.queue, search) -- re-enqueue normal searches at end
            debug(string.format("[Next] Re-enqueued normal search at end of queue"))
        else
            debug(string.format("[Next] Processed high-priority search in non-JOINING state"))
        end
    end
    
    self.currentSearch = search
    if search then
        self.searchCounter = self.searchCounter + 1
        debug(string.format("[Next] Returning search: category=%s, difficulty=%s, role=%s, priority=%s", 
            tostring(search.category), tostring(search.difficulty), tostring(search.role), tostring(search.priority)))
    else
        debug("[Next] No search to return")
    end
    return search
end

-- Add a high-priority search for specific parameters (role still used for joining specific groups)
function GFSearchQueue:AddPrioritySearch(category, difficulty, role)
    -- Only allow one high-priority search at a time
    self:RemovePrioritySearch()
    -- For priority searches (joining), we still track the role for targeting
    local search = {
        category = category,
        difficulty = difficulty,
        role = role, -- Keep role for priority searches to find specific groups
        priority = self.PRIORITY.HIGH,
        timestamp = GetTimeStamp(),
        searchKey = self:GenerateSearchKey(category, difficulty),
    }
    debug(string.format("[AddPrioritySearch] Adding priority search: category=%s, difficulty=%s, role=%s", 
        tostring(category), tostring(difficulty), tostring(role)))
    self:Enqueue(search)
    debug(string.format("[AddPrioritySearch] Queue now has %d searches, first priority: %s", 
        #self.queue, tostring(self.queue[1] and self.queue[1].priority)))
end

-- Remove the first high-priority search from the queue
function GFSearchQueue:RemovePrioritySearch()
    for i = 1, #self.queue do
        if self.queue[i].priority == self.PRIORITY.HIGH then
            local removedSearch = table.remove(self.queue, i)
            debug("[RemovePrioritySearch] Removed high-priority search from queue.")
            self:UpdateTotalSearches()
            return
        end
    end
    debug("[RemovePrioritySearch] No high-priority search found in queue.")
end

-- Intelligently build queue from enabled search combinations (MAJOR CHANGE: no role permutations)
function GFSearchQueue:BuildFromEnabled(enabledCategories, enabledDifficulties, enabledRoles)
    debug("[BuildFromEnabled] Starting intelligent queue update - NEW SYSTEM: category+difficulty only")
    
    -- Build the set of search combinations that should exist (category × difficulty only)
    local expectedSearches = {}
    for category, categoryEnabled in pairs(enabledCategories) do
        for difficulty, difficultyEnabled in pairs(enabledDifficulties) do
            if categoryEnabled and difficultyEnabled then
                -- Check if ANY role is enabled for this category+difficulty combo
                local anyRoleEnabled = false
            for role, roleEnabled in pairs(enabledRoles) do
                    if roleEnabled then
                        anyRoleEnabled = true
                        break
                    end
                end
                
                if anyRoleEnabled then
                    local searchKey = self:GenerateSearchKey(category, difficulty)
                    expectedSearches[searchKey] = {
                        category = category,
                        difficulty = difficulty,
                        searchKey = searchKey
                    }
                    debug(string.format("[BuildFromEnabled] Expected search: %s", searchKey))
                end
            end
        end
    end
    
    -- Create a set of existing searches (excluding high priority ones)
    local existingSearches = {}
    for _, search in ipairs(self.queue) do
        if search.priority ~= self.PRIORITY.HIGH then
            existingSearches[search.searchKey] = search
        end
    end
    
    -- Find searches to remove (exist but shouldn't)
    local searchesToRemove = {}
    for searchKey, search in pairs(existingSearches) do
        if not expectedSearches[searchKey] then
            table.insert(searchesToRemove, search)
            debug(string.format("[BuildFromEnabled] Marking search for removal: %s", searchKey))
        end
    end
    
    -- Find searches to add (should exist but don't)
    local searchesToAdd = {}
    for searchKey, searchParams in pairs(expectedSearches) do
        if not existingSearches[searchKey] then
            table.insert(searchesToAdd, searchParams)
            debug(string.format("[BuildFromEnabled] Marking search for addition: %s", searchKey))
        end
    end
    
    -- Remove obsolete searches and their data
    for _, search in ipairs(searchesToRemove) do
        self:RemoveSearchAndData(search.category, search.difficulty)
    end
    
    -- Add new searches
    for _, searchParams in ipairs(searchesToAdd) do
        local search = self:CreateSearch(searchParams.category, searchParams.difficulty)
        self:Enqueue(search)
        debug(string.format("[BuildFromEnabled] Added new search: %s", search.searchKey))
    end

    -- Update total searches and reset search counter only if we made changes
    if #searchesToRemove > 0 or #searchesToAdd > 0 then
        self:UpdateTotalSearches()
        self.searchCounter = 0 -- Reset counter on changes
        debug(string.format("[BuildFromEnabled] Queue updated. Removed: %d, Added: %d, Total searches: %d", 
            #searchesToRemove, #searchesToAdd, self.totalSearches))
    else
        debug("[BuildFromEnabled] No changes needed to queue")
    end
end

-- Get the current search
function GFSearchQueue:GetCurrentSearch()
    return self.currentSearch
end

-- Get all searches in queue
function GFSearchQueue:GetQueue()
    return self.queue
end

-- Get search history
function GFSearchQueue:GetHistory()
    return self.history
end

-- Clear the queue including high priority searches
function GFSearchQueue:Clear()
    self.queue = {}
    self:UpdateTotalSearches()
end

-- Remove a search from the queue by category and difficulty (role parameter removed)
function GFSearchQueue:RemoveSearch(category, difficulty)
    for i = #self.queue, 1, -1 do
        local s = self.queue[i]
        if s.category == category and s.difficulty == difficulty and s.priority ~= self.PRIORITY.HIGH then
            table.remove(self.queue, i)
        end
    end
    self:UpdateTotalSearches()
end

-- Remove a search from queue AND clean up its associated data from datastore
function GFSearchQueue:RemoveSearchAndData(category, difficulty)
    debug(string.format("[RemoveSearchAndData] Removing search and data for: category=%s, difficulty=%s", 
        tostring(category), tostring(difficulty)))
    
    -- Remove from queue
    for i = #self.queue, 1, -1 do
        local s = self.queue[i]
        if s.category == category and s.difficulty == difficulty and s.priority ~= self.PRIORITY.HIGH then
            local removedSearch = table.remove(self.queue, i)
            debug(string.format("[RemoveSearchAndData] Removed search from queue: %s", removedSearch.searchKey))
        end
    end
    
    -- Clean up associated data from datastore
    if self.dataStore then
        local searchKey = self:GenerateSearchKey(category, difficulty)
        self.dataStore:ClearSearchResults(searchKey)
        debug(string.format("[RemoveSearchAndData] Cleared datastore results for: %s", searchKey))
    else
        debug("[RemoveSearchAndData] Warning: No datastore reference set, cannot clean up data")
    end
    
    self:UpdateTotalSearches()
end

-- Check if a search exists in the queue by category and difficulty
function GFSearchQueue:HasSearch(category, difficulty)
    for _, s in ipairs(self.queue) do
        if s.category == category and s.difficulty == difficulty and s.priority ~= self.PRIORITY.HIGH then
            return true
        end
    end
    return false
end

-- Get the current search index
-- function GFSearchQueue:GetCurrentSearchIndex()
--     if not self.currentSearch then return nil, #self.queue end
--     for i, search in ipairs(self.queue) do
--         if search == self.currentSearch then
--             return i, #self.queue
--         end
--     end
--     return nil, #self.queue
-- end

function GFSearchQueue:GetTotalSearches()
    return self.totalSearches
end

function GFSearchQueue:GetVisualSearchIndex()
    if self.totalSearches == 0 then return 0 end
    return ((self.searchCounter - 1) % self.totalSearches) + 1
end

function GFSearchQueue:UpdateTotalSearches()
    local count = 0
    for _, search in ipairs(self.queue) do
        if search.priority ~= self.PRIORITY.HIGH then
            count = count + 1
        end
    end
    self.totalSearches = count
end

-- Export the module
PITHKA.groupFinder.SearchQueue = GFSearchQueue