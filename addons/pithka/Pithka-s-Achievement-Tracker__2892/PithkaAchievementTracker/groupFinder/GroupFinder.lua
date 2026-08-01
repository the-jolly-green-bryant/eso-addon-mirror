PITHKA = PITHKA or {}
PITHKA.groupFinder = PITHKA.groupFinder or {}

--[[
    GroupFinder - ESO Group Finder Integration
    
    NEW ARCHITECTURE (as of this migration):
    This system now uses "all roles" searches with client-side filtering for maximum efficiency.
    
    OLD SYSTEM:
    - Generated permutations: category × difficulty × role (e.g., Dungeon+Veteran+Tank, Dungeon+Veteran+Healer, etc.)
    - Each permutation = 1 separate API call with UpdateSelectedLFGRole(specificRole)
    - Results filtered by ESO server based on role
    - 3x more API calls when all roles enabled
    
    NEW SYSTEM:
    - Generate searches: category × difficulty only (no role permutations)
    - Each search uses SetGroupFinderFilterEnforceRoles(false) to get ALL roles
    - Results filtered client-side by user's enabled role toggles
    - ~3x fewer API calls, dramatically improved performance
    
    EXCEPTION: Priority searches (for joining specific groups) still use role-specific searches
    to target the exact group the user wants to join.
--]]

local StateMachine = PITHKA.groupFinder.StateMachine
local DataStore = PITHKA.groupFinder.DataStore
local SearchQueue = PITHKA.groupFinder.SearchQueue
local savedVars = PITHKA.data.savedVars

local GroupFinder = ZO_Object:Subclass()

local debug_enabled = false -- ENABLED FOR DEBUGGING: Set to true to enable debug output for testing
-- TEMP: Set to true to debug role cleanup feature: localdebug_enabled = true
local function debug(msg)
    if debug_enabled then
        d("|c00AAFF[GroupFinder Debug]|r " .. tostring(msg))
    end
end

-- Mapping from savedVars keys to search parameters
local SEARCH_PARAM_MAP = {
    groupFinderHealer   = {role = LFG_ROLE_HEAL},
    groupFinderTank     = {role = LFG_ROLE_TANK},
    groupFinderDps      = {role = LFG_ROLE_DPS},
    groupFinderDungeons = {category = GROUP_FINDER_CATEGORY_DUNGEON},
    groupFinderTrials   = {category = GROUP_FINDER_CATEGORY_TRIAL},
    groupFinderNormal   = {difficulty = DUNGEON_DIFFICULTY_NORMAL},
    groupFinderVeteran  = {difficulty = DUNGEON_DIFFICULTY_VETERAN},
}


--------------------------------------------------
-- Set state based on tray changes
--------------------------------------------------




--------------------------------------------------
-- Handle State Transitions
--------------------------------------------------

function GroupFinder:CancelPendingDelayedSearches()
    local count = 0
    for delayedSearchId, _ in pairs(self.pendingDelayedSearches) do
        self.pendingDelayedSearches[delayedSearchId] = nil
        count = count + 1
    end
    if count > 0 then
        debug(string.format("[CancelPendingDelayedSearches] Cancelled %d pending delayed searches", count))
    end
end

function GroupFinder:OnIdleState(oldState, data)
    debug(string.format("[OnIdleState] Entering IDLE state from %s", tostring(oldState)))
    
    -- Hide joining overlay
    self:HideJoiningOverlay()
    
    -- Cancel any pending delayed searches
    self:CancelPendingDelayedSearches()
    
    -- Clear stale search results but keep the queue (queue is bound to saved variables, not search state)
    self.dataStore:ClearAll()
    
    -- Reset search counter when going idle
    self.searchQueue.searchCounter = 0
    
    -- Queue persists based on saved variables, not search state
    debug("[OnIdleState] Cleared stale data, kept queue (bound to saved variables)")
end

function GroupFinder:OnSearchingState(oldState, data)
    -- Hide joining overlay
    self:HideJoiningOverlay()
    
    -- Cancel any pending delayed searches from previous state
    self:CancelPendingDelayedSearches()
    
    self.searchQueue:BuildFromEnabled(self:GetEnabledCategories(), self:GetEnabledDifficulties(), self:GetEnabledRoles())
    self:ProcessNextSearch()
end


function GroupFinder:OnJoiningState(oldState, data)
    if not data or not data.listing then return end
    
    debug(string.format("[OnJoiningState] Entering JOINING state from %s", tostring(oldState)))
    
    -- Track usage analytics: increment join attempts counter
    local savedVars = PITHKA.data.savedVars
    if savedVars and savedVars.db and savedVars.db.groupFinderUsage then
        savedVars.db.groupFinderUsage.joiningAttempts = (savedVars.db.groupFinderUsage.joiningAttempts or 0) + 1
        debug(string.format("[OnJoiningState] *** ANALYTICS *** Incremented joining attempts to: %d", savedVars.db.groupFinderUsage.joiningAttempts))
    end
    
    -- Show joining overlay
    self:ShowJoiningOverlay()
    
    -- Cancel any pending delayed searches from previous state
    self:CancelPendingDelayedSearches()
    
    -- Store the target listing for comparison in ProcessSearchResults
    self.stateMachine:SetStateData("targetListing", data.listing)
    
    -- Note: No longer switching tray since Group Finder is now standalone
    debug("[OnJoiningState] Starting priority search for group join")
    
    -- Extract the difficulty ID - it might be in difficultyID or we need to derive it from difficulty string
    local difficultyID = data.listing.difficultyID
    if not difficultyID and data.listing.difficulty then
        -- Convert difficulty string to ID
        if data.listing.difficulty:lower():find("veteran") then
            difficultyID = DUNGEON_DIFFICULTY_VETERAN
        elseif data.listing.difficulty:lower():find("normal") then
            difficultyID = DUNGEON_DIFFICULTY_NORMAL
        end
    end
    
    debug(string.format("[OnJoiningState] Storing target listing: %s, adding priority search for category=%s, difficulty=%s (difficultyID=%s), role=%s", 
        tostring(data.listing.leader), tostring(data.listing.category), tostring(data.listing.difficulty), tostring(difficultyID), tostring(data.listing.role)))
    
    if not difficultyID then
        debug("[OnJoiningState] ERROR: Could not determine difficultyID from listing data!")
        return
    end
    
    self.searchQueue:AddPrioritySearch(data.listing.category, difficultyID, data.listing.role)
    -- Immediately start processing the priority search
    self:ProcessNextSearch()
end


----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

-- Callback for when a search param is toggled
local function searchParamsToggled(var, value)
    -- Only respond to GroupFinder search parameter changes
    if not SEARCH_PARAM_MAP[var] then return end
    
    debug(string.format("[searchParamsToggled] %s changed to %s", var, tostring(value)))
    
    local groupFinder = PITHKA.groupFinder.instance
    
    -- Role toggles should clean up IMMEDIATELY (just database filtering)
    -- Check for any disabled search parameters and clean up irrelevant listings
    debug("[searchParamsToggled] Search parameter changed - checking for cleanup")
    groupFinder:CheckForDisabledSearchParams()
    
    -- Rebuild the search queue based on new parameters
    debug("[searchParamsToggled] Rebuilding queue due to search param change")
    groupFinder.searchQueue:BuildFromEnabled(
        groupFinder:GetEnabledCategories(),
        groupFinder:GetEnabledDifficulties(),
        groupFinder:GetEnabledRoles()
    )
    
    -- Let the simple state management handle start/stop
    groupFinder:UpdateSearchState()
end

function GroupFinder:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function GroupFinder:Initialize()
    assert(StateMachine, 'StateMachine is nil!')
    assert(DataStore, 'DataStore is nil!')
    assert(SearchQueue, 'SearchQueue is nil!')
    self.stateMachine = StateMachine:New()
    self.dataStore = DataStore:New()
    self.searchQueue = SearchQueue:New()
    self.isSearching = false -- Add flag to prevent concurrent searches
    self.pendingDelayedSearches = {} -- Track delayed searches to cancel them
    
    -- NEW: Track previous role states to detect when roles are disabled
    self.previousRoleStates = {}
    local currentRoles = self:GetEnabledRoles()
    for role, enabled in pairs(currentRoles) do
        self.previousRoleStates[role] = enabled
    end

    -- Set up the datastore reference in the search queue for coordinated cleanup
    self.searchQueue:SetDataStore(self.dataStore)

    -- Register state callbacks
    self.stateMachine:RegisterCallback(StateMachine.STATES.SEARCHING, function(oldState, data) self:OnSearchingState(oldState, data) end)
    self.stateMachine:RegisterCallback(StateMachine.STATES.JOINING, function(oldState, data) self:OnJoiningState(oldState, data) end)
    self.stateMachine:RegisterCallback(StateMachine.STATES.IDLE, function(oldState, data) self:OnIdleState(oldState, data) end)
    -- Register for game events
    EVENT_MANAGER:RegisterForEvent("PithkaGroupFinder", EVENT_GROUP_FINDER_SEARCH_COMPLETE, 
        function(...) self:OnSearchComplete(...) end)
    -- Register the search param toggle callback
    local savedVars = PITHKA.data.savedVars
    savedVars.registerCallback(searchParamsToggled)

    -- Register for search completion events
    EVENT_MANAGER:RegisterForEvent("GroupFinder", EVENT_GROUP_FINDER_SEARCH_RESULTS_READY, function(...)
        self:OnSearchComplete(...)
    end)

    -- Register for state change callbacks
    self.stateMachine:RegisterCallback("OnStateChange", function(fromState, toState, eventData)
        self:OnStateChanged(fromState, toState, eventData)
    end)
    
    -- Build initial search queue based on current saved variables
    debug("[Initialize] Building initial search queue from saved variables")
    self.searchQueue:BuildFromEnabled(
        self:GetEnabledCategories(),
        self:GetEnabledDifficulties(),
        self:GetEnabledRoles()
    )
end

--------------------------------------------------
-- State Machine Handlers
--------------------------------------------------




--------------------------------------------------
-- Search Processing
--------------------------------------------------

function GroupFinder:ProcessNextSearch()
    local currentState = self.stateMachine:GetCurrentState()
    if currentState ~= StateMachine.STATES.SEARCHING and currentState ~= StateMachine.STATES.JOINING then
        return
    end

    local search = self.searchQueue:Next(currentState)
    if not search then
        debug("[ProcessNextSearch] No searches left in queue. Stopping search.")
        self.stateMachine:HandleEvent(StateMachine.EVENTS.STOP_SEARCH)
        return
    end

    debug(string.format("[ProcessNextSearch] Executing search: category=%s, difficulty=%s, role=%s, priority=%s", tostring(search.category), tostring(search.difficulty), tostring(search.role), tostring(search.priority)))
    self:ExecuteSearch(search)
end

function GroupFinder:GetDifficultyIndex(difficultyConstant)
    -- Convert difficulty constant to 1-based index for the API
    -- The ESO API expects indices starting from 1, not the constant values
    if difficultyConstant == DUNGEON_DIFFICULTY_NORMAL then
        return 1
    elseif difficultyConstant == DUNGEON_DIFFICULTY_VETERAN then 
        return 2
    else
        debug(string.format("[GetDifficultyIndex] Unknown difficulty constant: %s", tostring(difficultyConstant)))
        return 1 -- Default to normal
    end
end

function GroupFinder:ExecuteSearch(search)
    -- Check if we're still in a valid state to execute searches
    local currentState = self.stateMachine:GetCurrentState()
    if currentState ~= StateMachine.STATES.SEARCHING and currentState ~= StateMachine.STATES.JOINING then
        debug("[ExecuteSearch] Aborting search - state is now " .. tostring(currentState))
        return
    end

    -- Prevent concurrent searches
    if self.isSearching then
        debug("[ExecuteSearch] Search already in progress, skipping duplicate request")
        return
    end
    self.isSearching = true

    -- Log current API state before setting parameters
    debug(string.format("[ExecuteSearch] BEFORE - Current role: %s, category: %s, difficulty: %s", 
        tostring(GetSelectedLFGRole()), 
        tostring(GetGroupFinderFilterCategory()), 
        tostring(GetGroupFinderFilterPrimaryOptionByIndex())))

    -- Set up the search parameters - MAJOR CHANGE: Use "all roles" mode
    local difficultyIndex = self:GetDifficultyIndex(search.difficulty)
    debug(string.format("[ExecuteSearch] Setting parameters: category=%s, difficulty=%s (index=%s) - ALL ROLES MODE", 
        tostring(search.category), tostring(search.difficulty), tostring(difficultyIndex)))
    
    -- NEW: Disable role enforcement to get all roles in results
    SetGroupFinderFilterEnforceRoles(false)
    
    -- Set category and difficulty (no longer setting specific role)
    SetGroupFinderFilterCategory(search.category)
    SetGroupFinderFilterPrimaryOptionByIndex(difficultyIndex, true)
    
    -- For priority searches (joining specific groups), we still need to set the role
    if search.priority == self.searchQueue.PRIORITY.HIGH and search.role then
        debug(string.format("[ExecuteSearch] Priority search - setting specific role: %s", tostring(search.role)))
        UpdateSelectedLFGRole(search.role, true)
        SetGroupFinderFilterEnforceRoles(true) -- Re-enable for targeted joining
    end
    
    -- Log current API state after setting parameters
    debug(string.format("[ExecuteSearch] AFTER - Current role: %s, category: %s, difficulty: %s, enforce roles: %s", 
        tostring(GetSelectedLFGRole()), 
        tostring(GetGroupFinderFilterCategory()), 
        tostring(GetGroupFinderFilterPrimaryOptionByIndex()),
        tostring(DoesGroupFinderFilterRequireEnforceRoles())))
    
    -- Handle cooldown
    if IsGroupFinderSearchOnCooldown() then
        self.isSearching = false -- Reset flag before retry
        -- Create a proper closure that captures the search parameters by value
        local searchCopy = {
            category = search.category,
            difficulty = search.difficulty,
            role = search.role,
            priority = search.priority
        }
        debug(string.format("[ExecuteSearch] Search on cooldown, retrying in 1500ms with: category=%s, difficulty=%s, role=%s, priority=%s", 
            tostring(searchCopy.category), tostring(searchCopy.difficulty), tostring(searchCopy.role), tostring(searchCopy.priority)))
        
        -- Track this delayed search so we can cancel it if needed
        local delayedSearchId = GetTimeStamp() .. "_" .. tostring(math.random(1000000))
        self.pendingDelayedSearches[delayedSearchId] = true
        
        zo_callLater(function() 
            -- Check if this delayed search was cancelled
            if self.pendingDelayedSearches[delayedSearchId] then
                self.pendingDelayedSearches[delayedSearchId] = nil
                self:ExecuteSearch(searchCopy) 
            else
                debug(string.format("[ExecuteSearch] Cancelled delayed search: %s", delayedSearchId))
            end
        end, 1500)
        return
    end
    
    -- Execute the search
    debug("[ExecuteSearch] Called with: category=" .. tostring(search.category) .. ", difficulty=" .. tostring(search.difficulty) .. ", priority=" .. tostring(search.priority))
    RequestGroupFinderSearch()
end

function GroupFinder:OnSearchComplete(_, result, searchId)
    -- Reset the search flag
    self.isSearching = false
    debug(string.format("[OnSearchComplete] Search completed, reset isSearching flag"))
    
    local state = self.stateMachine:GetCurrentState()
    if state == StateMachine.STATES.SEARCHING then
        self:ProcessSearchResults()
        self:ProcessNextSearch()
    elseif state == StateMachine.STATES.JOINING then
        local currentSearch = self.searchQueue:GetCurrentSearch()
        if currentSearch and currentSearch.priority == self.searchQueue.PRIORITY.HIGH then
            -- This is the priority search we were waiting for
            debug("[OnSearchComplete] Priority search completed in JOINING state")
            self:ProcessSearchResults() -- will attempt join and then transition to idle
            -- If ProcessSearchResults didn't transition to IDLE (target not found), do it now
        if self.stateMachine:GetCurrentState() == StateMachine.STATES.JOINING then
                debug("[OnSearchComplete] Target not found, transitioning to IDLE")
                self.stateMachine:HandleEvent(StateMachine.EVENTS.STOP_SEARCH)
        end
        else
            -- This was a normal search that was in-flight when we transitioned to JOINING
            -- Continue to the next search (which should be the priority search)
            debug("[OnSearchComplete] Normal search completed in JOINING state, continuing to priority search")
            self:ProcessSearchResults()
            self:ProcessNextSearch()
        end
    end
end

--------------------------------------------------
-- Result Processing
--------------------------------------------------

-- NEW: Get user's enabled roles for client-side filtering
function GroupFinder:GetEnabledRolesForFiltering()
    local enabledRoles = {}
    local roles = self:GetEnabledRoles()
    for role, enabled in pairs(roles) do
        if enabled then
            table.insert(enabledRoles, role)
        end
    end
    
    -- Debug logging to show current enabled roles
    local roleNames = {}
    for _, role in ipairs(enabledRoles) do
        table.insert(roleNames, self:GetRoleName(role))
    end
    debug(string.format("[GetEnabledRolesForFiltering] User has enabled roles: %s", 
        #roleNames > 0 and table.concat(roleNames, ", ") or "NONE"))
    
    return enabledRoles
end

-- NEW: Check if a listing matches user's role preferences
function GroupFinder:IsListingRoleMatch(listing)
    local enabledRoles = self:GetEnabledRolesForFiltering()
    if #enabledRoles == 0 then
        debug(string.format("[IsListingRoleMatch] No roles enabled - listing %s does not match", tostring(listing.leader)))
        return false -- No roles enabled
    end
    
    debug(string.format("[IsListingRoleMatch] Checking listing %s against enabled roles. Tank:%d/%d, Healer:%d/%d, DPS:%d/%d", 
        tostring(listing.leader),
        listing.tankAttained or 0, listing.tankDesired or 0,
        listing.healerAttained or 0, listing.healerDesired or 0,
        listing.dpsAttained or 0, listing.dpsDesired or 0))
    
    -- Check if the listing has openings for any of the user's enabled roles
    for _, role in ipairs(enabledRoles) do
        local desired, attained = 0, 0
        local roleName = ""
        if role == LFG_ROLE_TANK then
            desired, attained = listing.tankDesired or 0, listing.tankAttained or 0
            roleName = "Tank"
        elseif role == LFG_ROLE_HEAL then
            desired, attained = listing.healerDesired or 0, listing.healerAttained or 0
            roleName = "Healer"
        elseif role == LFG_ROLE_DPS then
            desired, attained = listing.dpsDesired or 0, listing.dpsAttained or 0
            roleName = "DPS"
        end
        
        -- If this role has openings, the listing matches
        if desired > attained then
            debug(string.format("[IsListingRoleMatch] Listing %s MATCHES - has openings for %s (%d/%d)", 
                tostring(listing.leader), roleName, attained, desired))
            return true
        end
    end
    
    debug(string.format("[IsListingRoleMatch] Listing %s does NOT match - no openings for enabled roles", tostring(listing.leader)))
    return false -- No openings for any enabled roles
end

-- NEW: Comprehensive filtering - checks if a listing matches ALL current search preferences
function GroupFinder:IsListingRelevant(listing)
    -- Check roles first (most likely to filter out results)
    if not self:IsListingRoleMatch(listing) then
        debug(string.format("[IsListingRelevant] Listing %s filtered out - role mismatch", tostring(listing.leader)))
        return false
    end
    
    -- Check categories (dungeon vs trial)
    local enabledCategories = self:GetEnabledCategories()
    local categoryMatch = enabledCategories[listing.category]
    if not categoryMatch then
        local categoryName = self:GetCategoryName(listing.category)
        debug(string.format("[IsListingRelevant] Listing %s filtered out - category %s not enabled", 
            tostring(listing.leader), categoryName))
        return false
    end
    
    -- Check difficulties (normal vs veteran)
    local enabledDifficulties = self:GetEnabledDifficulties()
    local difficultyMatch = enabledDifficulties[listing.difficultyID]
    if not difficultyMatch then
        local difficultyName = self:GetDifficultyName(listing.difficultyID)
        debug(string.format("[IsListingRelevant] Listing %s filtered out - difficulty %s not enabled", 
            tostring(listing.leader), difficultyName))
        return false
    end
    
    debug(string.format("[IsListingRelevant] Listing %s PASSES all filters - role, category, difficulty", 
        tostring(listing.leader)))
    return true
end

function GroupFinder:ProcessSearchResults()
    local currentSearch = self.searchQueue:GetCurrentSearch()
    if not currentSearch then return end
    
    local searchKey = currentSearch.searchKey
    local state = self.stateMachine:GetCurrentState()
    
    if state == StateMachine.STATES.SEARCHING then
        -- Clear old search results for this search key before adding new ones
        debug(string.format("[ProcessSearchResults] Clearing old results for search key: %s", searchKey))
        self.dataStore:ClearSearchResults(searchKey)
    end
    
    local numResults = GetGroupFinderSearchNumListings()
    debug(string.format("[ProcessSearchResults] Found %d results in state %s", numResults, tostring(state)))
    
    local filteredCount = 0
    local totalProcessed = 0
    
    for i = 1, numResults do
        local listing = self:ProcessListing(i, searchKey)
        totalProcessed = totalProcessed + 1
        
        if state == StateMachine.STATES.JOINING then
            local targetListing = self.stateMachine:GetStateData("targetListing")
            debug(string.format("[ProcessSearchResults] Checking listing %s against target %s", 
                tostring(listing.leader), tostring(targetListing and targetListing.leader)))
            if targetListing and listing.leader == targetListing.leader then
                debug(string.format("[ProcessSearchResults] *** FOUND TARGET *** Found target listing! Attempting to join."))
                self:JoinTargetGroup(i)
                debug("[ProcessSearchResults] *** TESTING: TRANSITION TO SEARCHING *** Testing if we can search while dialog is open")
                -- TEST: Instead of stopping search, continue searching in background during dialog
                self.stateMachine:HandleEvent(StateMachine.EVENTS.START_SEARCH)
                return
            end
        elseif state == StateMachine.STATES.SEARCHING then
            -- Apply comprehensive client-side filtering (roles, categories, difficulties)
            if self:IsListingRelevant(listing) then
                self.dataStore:UpsertListing(listing)
                filteredCount = filteredCount + 1
                debug(string.format("[ProcessSearchResults] Listing %s passed comprehensive filter", tostring(listing.leader)))
            else
                debug(string.format("[ProcessSearchResults] Listing %s filtered out (failed comprehensive filter)", tostring(listing.leader)))
            end
        end
    end
    
    if state == StateMachine.STATES.SEARCHING then
        debug(string.format("[ProcessSearchResults] Processed %d results, %d passed comprehensive filter for search key: %s", 
            totalProcessed, filteredCount, searchKey))
        
        -- NOTE: Stale entry cleanup happens automatically via ClearSearchResults() above
        -- This removes old listings that weren't returned in the fresh search results
    end
    
    -- If we're in JOINING state but didn't find the target, log it
    if state == StateMachine.STATES.JOINING then
        local targetListing = self.stateMachine:GetStateData("targetListing")
        debug(string.format("[ProcessSearchResults] Target listing %s not found in results. Continuing search.", 
            tostring(targetListing and targetListing.leader)))
    end
end


-- to do, clean up listing, you ahve two timestamps, and catetory is id, but difficulty is name
function GroupFinder:ProcessListing(listingIndex, searchKey)
    local currentSearch = self.searchQueue:GetCurrentSearch() or {}
    local listing = {
        title = GetGroupFinderSearchListingTitleByIndex(listingIndex),
        description = GetGroupFinderSearchListingDescriptionByIndex(listingIndex),
        category = GetGroupFinderSearchListingCategoryByIndex(listingIndex),
        --groupSize = GetGroupFinderSearchListingGroupSizeByIndex(listingIndex),
        numRoles = GetGroupFinderSearchListingNumRolesByIndex(listingIndex),
        leader = GetGroupFinderSearchListingLeaderDisplayNameByIndex(listingIndex),
        tankDesired = select(1, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_TANK)),
        tankAttained = select(2, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_TANK)),
        healerDesired = select(1, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_HEAL)),
        healerAttained = select(2, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_HEAL)),
        dpsDesired = select(1, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_DPS)),
        dpsAttained = select(2, GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_DPS)),
        totalAttained = 0, -- will set below
        searchTime = GetTimeStamp(),
        searchParams = searchKey, -- Use the consistent search key
        searchKey = searchKey, -- Also store it directly for clarity
        difficulty = select(1, GetGroupFinderSearchListingOptionsSelectionTextByIndex(listingIndex)), -- string for display
        specificActivity = select(2, GetGroupFinderSearchListingOptionsSelectionTextByIndex(listingIndex)),
        timestamp = GetTimeStamp(),
        difficultyID = currentSearch.difficulty -- add the numeric difficultyID for logic
    }
    listing.totalAttained = (listing.tankAttained or 0) + (listing.healerAttained or 0) + (listing.dpsAttained or 0)
    
    -- DON'T store the listing here - let ProcessSearchResults decide after filtering
    -- This was the bug: storing ALL listings before role filtering
    
    return listing
end

--------------------------------------------------
-- Group Joining
--------------------------------------------------

function GroupFinder:JoinGroup(listing)
    debug("[JoinGroup] Called with listing: " .. tostring(listing and listing.leader))
    -- Transition to joining state with the target listing
    return self.stateMachine:HandleEvent(StateMachine.EVENTS.JOIN_GROUP, {listing = listing})
end

function GroupFinder:JoinTargetGroup(listingIndex)
    debug(string.format("[JoinTargetGroup] Called with listingIndex: %s", tostring(listingIndex)))
    
    -- Check each component individually
    debug(string.format("[JoinTargetGroup] ZO_Dialogs_ShowPlatformDialog type: %s", type(ZO_Dialogs_ShowPlatformDialog)))
    debug(string.format("[JoinTargetGroup] ZO_GroupListingSearchData type: %s", type(ZO_GroupListingSearchData)))
    
    if ZO_GroupListingSearchData then
        debug(string.format("[JoinTargetGroup] ZO_GroupListingSearchData.New type: %s", type(ZO_GroupListingSearchData.New)))
    else
        debug("[JoinTargetGroup] ZO_GroupListingSearchData is nil!")
    end
    
    if type(ZO_Dialogs_ShowPlatformDialog) == "function" and type(ZO_GroupListingSearchData) == "table" and type(ZO_GroupListingSearchData.New) == "function" then
        debug("[JoinTargetGroup] All required functions available, creating search data...")
        local searchData = ZO_GroupListingSearchData:New(listingIndex)
        debug(string.format("[JoinTargetGroup] Search data created: %s", tostring(searchData)))
        
        -- Set up basic event handler for join result (no restart logic)
        local function OnGroupFinderApplyResult(eventCode, result)
            debug(string.format("[OnGroupFinderApplyResult] Join result: %s", tostring(result)))
            
            if result ~= GROUP_FINDER_ACTION_RESULT_SUCCESS then
                -- Show error message for failures
                debug(string.format("[OnGroupFinderApplyResult] Join request failed with result: %s", tostring(result)))
                debug("Pithka Group Finder Error: Unable to join group, listing no longer available")
            else
                debug("[OnGroupFinderApplyResult] Join request successful!")
            end
            
            -- Unregister the event handler after handling the result
            EVENT_MANAGER:UnregisterForEvent("PithkaGroupFinderJoin", EVENT_GROUP_FINDER_APPLY_TO_GROUP_LISTING_RESULT)
            debug("[OnGroupFinderApplyResult] Event handler unregistered")
            
            -- No restart logic - just let the background search continue
        end
        
        -- Register for the join result event
        EVENT_MANAGER:RegisterForEvent("PithkaGroupFinderJoin", EVENT_GROUP_FINDER_APPLY_TO_GROUP_LISTING_RESULT, OnGroupFinderApplyResult)
        
        debug("[JoinTargetGroup] Attempting to show dialog...")
        ZO_Dialogs_ShowPlatformDialog("GROUP_FINDER_APPLICATION_KEYBOARD", searchData)
        debug("[JoinTargetGroup] Dialog show command executed - clean test, no hooks")
        
        -- Don't close any windows - let user manage window state
        debug("[JoinTargetGroup] Join dialog shown, keeping windows open")
        
        -- Remove the high-priority search from the queue after showing the dialog
        if self.searchQueue and self.searchQueue.RemovePrioritySearch then
            self.searchQueue:RemovePrioritySearch()
            debug("[JoinTargetGroup] Removed priority search from queue")
        end
    else
        debug("[JoinTargetGroup] ERROR: Required ESO UI functions/classes are not available!")
        debug(string.format("[JoinTargetGroup] - ZO_Dialogs_ShowPlatformDialog: %s", type(ZO_Dialogs_ShowPlatformDialog)))
        debug(string.format("[JoinTargetGroup] - ZO_GroupListingSearchData: %s", type(ZO_GroupListingSearchData)))
        if ZO_GroupListingSearchData then
            debug(string.format("[JoinTargetGroup] - ZO_GroupListingSearchData.New: %s", type(ZO_GroupListingSearchData.New)))
        end
    end
end

--------------------------------------------------
-- Utility Functions
--------------------------------------------------

function GroupFinder:CreateSearchParamsString(search)
    return string.format("%s_%s_%s",
        self:GetRoleName(search.role),
        self:GetCategoryName(search.category),
        self:GetDifficultyName(search.difficulty)
    )
end

local savedVars = PITHKA.data.savedVars

function GroupFinder:GetEnabledCategories()
    return {
        [GROUP_FINDER_CATEGORY_TRIAL] = savedVars.get("groupFinderTrials"),
        [GROUP_FINDER_CATEGORY_DUNGEON] = savedVars.get("groupFinderDungeons"),
    }
end

function GroupFinder:GetEnabledDifficulties()
    return {
        [DUNGEON_DIFFICULTY_NORMAL] = savedVars.get("groupFinderNormal"),
        [DUNGEON_DIFFICULTY_VETERAN] = savedVars.get("groupFinderVeteran"),
    }
end

function GroupFinder:GetEnabledRoles()
    return {
        [LFG_ROLE_TANK] = savedVars.get("groupFinderTank"),
        [LFG_ROLE_HEAL] = savedVars.get("groupFinderHealer"),
        [LFG_ROLE_DPS] = savedVars.get("groupFinderDps"),
    }
end

function GroupFinder:GetRoleName(role)
    if role == LFG_ROLE_TANK then return "TANK"
    elseif role == LFG_ROLE_HEAL then return "HEALER"
    elseif role == LFG_ROLE_DPS then return "DPS"
    else return tostring(role) end
end

function GroupFinder:GetCategoryName(category)
    if category == GROUP_FINDER_CATEGORY_TRIAL then return "TRIAL"
    elseif category == GROUP_FINDER_CATEGORY_DUNGEON then return "DUNGEON"
    else return tostring(category) end
end

function GroupFinder:GetDifficultyName(difficulty)
    if difficulty == DUNGEON_DIFFICULTY_NORMAL then return "NORMAL"
    elseif difficulty == DUNGEON_DIFFICULTY_VETERAN then return "VETERAN"
    else return tostring(difficulty) end
end

--------------------------------------------------
-- Search State Management
--------------------------------------------------

-- Simple check: should we be searching right now?
function GroupFinder:ShouldBeSearching()
    -- Check 1: Is the Group Finder window visible?
    local windowVisible = PITHKA_GROUP_FINDER_GUI and not PITHKA_GROUP_FINDER_GUI:IsControlHidden()
    
    -- Check 2: Do we have a valid search queue?
    local hasQueue = self.searchQueue and #self.searchQueue:GetQueue() > 0
    
    debug(string.format("[ShouldBeSearching] Window visible: %s, Has queue: %s", tostring(windowVisible), tostring(hasQueue)))
    
    return windowVisible and hasQueue
end

-- Update search state based on current conditions
function GroupFinder:UpdateSearchState()
    local currentState = self.stateMachine:GetCurrentState()
    local shouldSearch = self:ShouldBeSearching()
    
    debug(string.format("[UpdateSearchState] *** UPDATE SEARCH STATE *** Should search: %s, Current state: %s", tostring(shouldSearch), tostring(currentState)))
    
    if shouldSearch and currentState == StateMachine.STATES.IDLE then
        debug("[UpdateSearchState] *** STARTING SEARCH *** Starting search")
        self.stateMachine:HandleEvent(StateMachine.EVENTS.START_SEARCH)
    elseif not shouldSearch and currentState == StateMachine.STATES.SEARCHING then
        debug("[UpdateSearchState] *** STOPPING SEARCH *** Stopping search")
        self.stateMachine:HandleEvent(StateMachine.EVENTS.STOP_SEARCH)
    else
        debug(string.format("[UpdateSearchState] *** NO ACTION *** No state change needed. shouldSearch=%s, currentState=%s", tostring(shouldSearch), tostring(currentState)))
    end
end

--------------------------------------------------
-- Public API Methods
--------------------------------------------------

function GroupFinder:StartSearch()
    return self.stateMachine:HandleEvent(StateMachine.EVENTS.START_SEARCH)
end

function GroupFinder:StopSearch()
    return self.stateMachine:HandleEvent(StateMachine.EVENTS.STOP_SEARCH)
end

-- NEW: Clean up listings that are no longer relevant when search preferences change
function GroupFinder:CleanupIrrelevantListings()
    local allListings = self.dataStore:GetAllListings()
    local removedCount = 0
    
    debug("[CleanupIrrelevantListings] Starting cleanup of irrelevant listings")
    
    for leader, listing in pairs(allListings) do
        if not self:IsListingRelevant(listing) then
            debug(string.format("[CleanupIrrelevantListings] Removing irrelevant listing: %s", leader))
            self.dataStore:RemoveListing(leader)
            removedCount = removedCount + 1
        end
    end
    
    debug(string.format("[CleanupIrrelevantListings] Removed %d irrelevant listings", removedCount))
    
    -- Let datastore callbacks handle UI updates naturally instead of forcing immediate refresh
    -- This prevents multiple rapid UI updates that could cause flickering
    
    return removedCount
end

-- NEW: Detect which search parameters were disabled and trigger cleanup if needed
function GroupFinder:CheckForDisabledSearchParams()
    local currentRoles = self:GetEnabledRoles()
    local currentCategories = self:GetEnabledCategories()
    local currentDifficulties = self:GetEnabledDifficulties()
    
    local searchParamsWereDisabled = false
    local disabledParams = {}
    
    debug(string.format("[CheckForDisabledSearchParams] Checking search parameter states - Tank:%s, Healer:%s, DPS:%s", 
        tostring(currentRoles[LFG_ROLE_TANK]), 
        tostring(currentRoles[LFG_ROLE_HEAL]), 
        tostring(currentRoles[LFG_ROLE_DPS])))
    debug(string.format("[CheckForDisabledSearchParams] Categories - Dungeons:%s, Trials:%s", 
        tostring(currentCategories[GROUP_FINDER_CATEGORY_DUNGEON]), 
        tostring(currentCategories[GROUP_FINDER_CATEGORY_TRIAL])))
    debug(string.format("[CheckForDisabledSearchParams] Difficulties - Normal:%s, Veteran:%s", 
        tostring(currentDifficulties[DUNGEON_DIFFICULTY_NORMAL]), 
        tostring(currentDifficulties[DUNGEON_DIFFICULTY_VETERAN])))
    
    -- Check if any roles were disabled (changed from true to false)
    for role, previouslyEnabled in pairs(self.previousRoleStates or {}) do
        local currentlyEnabled = currentRoles[role] or false
        if previouslyEnabled and not currentlyEnabled then
            local roleName = self:GetRoleName(role)
            debug(string.format("[CheckForDisabledSearchParams] Role %s was disabled", roleName))
            table.insert(disabledParams, roleName)
            searchParamsWereDisabled = true
        end
    end
    
    -- Check if any categories were disabled
    for category, previouslyEnabled in pairs(self.previousCategoryStates or {}) do
        local currentlyEnabled = currentCategories[category] or false
        if previouslyEnabled and not currentlyEnabled then
            local categoryName = self:GetCategoryName(category)
            debug(string.format("[CheckForDisabledSearchParams] Category %s was disabled", categoryName))
            table.insert(disabledParams, categoryName)
            searchParamsWereDisabled = true
        end
    end
    
    -- Check if any difficulties were disabled
    for difficulty, previouslyEnabled in pairs(self.previousDifficultyStates or {}) do
        local currentlyEnabled = currentDifficulties[difficulty] or false
        if previouslyEnabled and not currentlyEnabled then
            local difficultyName = self:GetDifficultyName(difficulty)
            debug(string.format("[CheckForDisabledSearchParams] Difficulty %s was disabled", difficultyName))
            table.insert(disabledParams, difficultyName)
            searchParamsWereDisabled = true
        end
    end
    
    -- Update previous states for next check
    self.previousRoleStates = {}
    for role, enabled in pairs(currentRoles) do
        self.previousRoleStates[role] = enabled
    end
    
    self.previousCategoryStates = {}
    for category, enabled in pairs(currentCategories) do
        self.previousCategoryStates[category] = enabled
    end
    
    self.previousDifficultyStates = {}
    for difficulty, enabled in pairs(currentDifficulties) do
        self.previousDifficultyStates[difficulty] = enabled
    end
    
    -- Search parameter toggle cleanup is IMMEDIATE (just database filtering)
    if searchParamsWereDisabled then
        debug(string.format("[CheckForDisabledSearchParams] Search parameters disabled: %s - performing immediate cleanup", 
            table.concat(disabledParams, ", ")))
        self:CleanupIrrelevantListings()
    else
        debug("[CheckForDisabledSearchParams] No search parameters were disabled - no cleanup needed")
    end
end

--------------------------------------------------
-- UI Helper Functions
--------------------------------------------------

function GroupFinder:ShowJoiningOverlay()
    if PITHKA_GROUP_FINDER_GUI then
        local contentContainer = PITHKA_GROUP_FINDER_GUI:GetNamedChild("ContentContainer")
        local overlay = contentContainer:GetNamedChild("JoiningOverlay")
        local list = contentContainer:GetNamedChild("List")
        
        if overlay then
            overlay:SetHidden(false)
            debug("[ShowJoiningOverlay] Joining overlay shown")
        end
        
        if list then
            list:SetHidden(true)
            debug("[ShowJoiningOverlay] List hidden")
        end
    end
end

function GroupFinder:HideJoiningOverlay()
    if PITHKA_GROUP_FINDER_GUI then
        local contentContainer = PITHKA_GROUP_FINDER_GUI:GetNamedChild("ContentContainer")
        local overlay = contentContainer:GetNamedChild("JoiningOverlay")
        local list = contentContainer:GetNamedChild("List")
        
        if overlay then
            overlay:SetHidden(true)
            debug("[HideJoiningOverlay] Joining overlay hidden")
        end
        
        if list then
            list:SetHidden(false)
            debug("[HideJoiningOverlay] List shown")
        end
    end
end

-- Export the module
PITHKA.groupFinder.GroupFinder = GroupFinder