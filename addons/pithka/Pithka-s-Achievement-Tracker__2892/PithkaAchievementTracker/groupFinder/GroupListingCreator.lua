PITHKA = PITHKA or {}
PITHKA.groupFinder = PITHKA.groupFinder or {}

local GroupListingCreator = {}
PITHKA.groupFinder.GroupListingCreator = GroupListingCreator

-- Constants for easy reference
GroupListingCreator.CATEGORIES = {
    DUNGEON = GROUP_FINDER_CATEGORY_DUNGEON,
    ARENA = GROUP_FINDER_CATEGORY_ARENA,
    TRIAL = GROUP_FINDER_CATEGORY_TRIAL,
    ENDLESS_DUNGEON = GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON,
    CUSTOM = GROUP_FINDER_CATEGORY_CUSTOM
}

GroupListingCreator.DIFFICULTIES = {
    NORMAL = DUNGEON_DIFFICULTY_NORMAL,
    VETERAN = DUNGEON_DIFFICULTY_VETERAN
}

GroupListingCreator.ROLES = {
    TANK = LFG_ROLE_TANK,
    HEALER = LFG_ROLE_HEAL,
    DPS = LFG_ROLE_DPS
}

GroupListingCreator.PLAYSTYLES = {
    BEGINNER = GROUP_FINDER_PLAYSTYLE_BEGINNER,
    CASUAL = GROUP_FINDER_PLAYSTYLE_CASUAL,
    HARDCORE = GROUP_FINDER_PLAYSTYLE_HARDCORE
}

-- Debug function
local debugEnabled = false  -- Temporarily enable debug
local function debug(msg)
    if debugEnabled then
        d('|c00FFFF[GroupListingCreator]|r ' .. msg)
    end
end

-- Helper function to clear all draft settings
function GroupListingCreator:ClearDraftSettings()
    local userType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    
    -- Clear roles (essential - we always set specific roles)
    GroupFinderUserTypeGroupListingClearDesiredRoles(userType)
    
    -- Only clear the fields we actually set - comment out defaults we don't need
    -- SetGroupFinderUserTypeGroupListingTitle(userType, "")  -- We always set title
    -- SetGroupFinderUserTypeGroupListingDescription(userType, "")  -- We always set description
    -- SetGroupFinderUserTypeGroupListingCategory(userType, self.CATEGORIES.DUNGEON)  -- We always set category
    -- SetGroupFinderUserTypeGroupListingGroupSize(userType, 4)  -- We always set group size
    -- SetGroupFinderUserTypeGroupListingRequiresChampion(userType, false)  -- We set this based on difficulty
    -- SetGroupFinderUserTypeGroupListingChampionPoints(userType, 0)  -- We don't set this, leave default
    -- SetGroupFinderUserTypeGroupListingRequiresVOIP(userType, false)  -- We don't set this, leave default
    -- SetGroupFinderUserTypeGroupListingRequiresInviteCode(userType, false)  -- We don't set this, leave default
    -- SetGroupFinderUserTypeGroupListingInviteCode(userType, 0)  -- We don't set this, leave default
    -- SetGroupFinderUserTypeGroupListingAutoAcceptRequests(userType, true)  -- We set this
    -- SetGroupFinderUserTypeGroupListingEnforceRoles(userType, false)  -- We set this
end

-- Helper function to find the secondary option index for a specific dungeon/trial name
function GroupListingCreator:FindSecondaryOptionIndex(achievementData, userType)
    if not achievementData or not achievementData.NAME then
        return nil
    end
    
    local achievementName = achievementData.NAME
    local numSecondaryOptions = GetGroupFinderUserTypeGroupListingNumSecondaryOptions(userType)
    
    debug("Looking for secondary option for: " .. achievementName)
    debug("Total secondary options available: " .. tostring(numSecondaryOptions))
    
    -- Collect all options with their indices first
    local options = {}
    for i = 1, numSecondaryOptions do
        local optionName, _ = GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex(userType, i)
        if optionName then
            table.insert(options, {
                name = optionName,
                index = i
            })
        end
    end
    
    -- Sort by length descending (longest names first) to prioritize more specific matches
    -- This ensures "Wayrest Sewers II" matches before "Wayrest Sewers I"
    table.sort(options, function(a, b)
        return #a.name > #b.name
    end)
    
    -- Search through sorted options to find a match
    for _, option in ipairs(options) do
        local optionName = option.name
        local index = option.index
        
        debug("Option " .. index .. ": " .. optionName)
        
        -- Try exact match first
        if optionName == achievementName then
            debug("Found exact match at index: " .. index)
            return index
        end
        
        -- Try case-insensitive exact match
        if string.lower(optionName) == string.lower(achievementName) then
            debug("Found case-insensitive exact match at index: " .. index .. " (" .. optionName .. ")")
            return index
        end
        
        -- For partial matching, be more precise to handle Roman numerals correctly
        local lowerOptionName = string.lower(optionName)
        local lowerAchievementName = string.lower(achievementName)
        
        -- Check if achievement name ends with Roman numeral
        local achievementHasRomanNumeral = lowerAchievementName:match(" i+$") ~= nil
        local optionHasRomanNumeral = lowerOptionName:match(" i+$") ~= nil
        
        if achievementHasRomanNumeral and optionHasRomanNumeral then
            -- Both have Roman numerals - they must match exactly for Roman numeral part
            if lowerOptionName == lowerAchievementName then
                debug("Found exact Roman numeral match at index: " .. index .. " (" .. optionName .. ")")
                return index
            end
        elseif not achievementHasRomanNumeral and not optionHasRomanNumeral then
            -- Neither has Roman numerals - safe to do partial matching
            if string.find(lowerOptionName, lowerAchievementName, 1, true) or 
               string.find(lowerAchievementName, lowerOptionName, 1, true) then
                debug("Found partial match at index: " .. index .. " (" .. optionName .. ")")
                return index
            end
        elseif not achievementHasRomanNumeral and optionHasRomanNumeral then
            -- Achievement has no numeral, option does - check if base names match
            local optionBaseName = lowerOptionName:gsub(" i+$", "")
            if optionBaseName == lowerAchievementName or string.find(optionBaseName, lowerAchievementName, 1, true) then
                debug("Found base name match (option has numeral, achievement doesn't) at index: " .. index .. " (" .. optionName .. ")")
                return index
            end
        end
        -- If achievement has Roman numeral but option doesn't, skip partial matching to avoid confusion
    end
    
    debug("No matching secondary option found for: " .. achievementName)
    return nil
end

-- Main function to pre-populate and show creation dialog
function GroupListingCreator:CreateListing(params)
    local userType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    
    -- Enhanced validation with detailed error reporting
    local canCreate, errorMessage = ZO_GroupFinder_CanDoCreateEdit()
    if not canCreate then
        debug("Cannot create group listing: " .. (errorMessage or "Unknown error"))
        
        -- Check specific conditions and provide helpful suggestions
        if IsGroupFinderRoleChangeRequested() then
            debug("Issue: Role change is pending. Waiting 3 seconds and retrying...")
            zo_callLater(function()
                self:CreateListing(params)
            end, 3000)
            return false
        elseif ZO_GroupFinder_GetIsCurrentlyInQueue() then
            debug("Issue: Currently in group finder queue. Please leave queue first.")
            return false
        elseif not IsUnitSoloOrGroupLeader("player") then
            debug("Issue: Must be solo or group leader to create listing.")
            return false
        else
            debug("Issue: " .. (errorMessage or "Unknown condition blocking creation"))
            return false
        end
    end
    
    -- Debug: Log current state
    debug("Creating group listing...")
    debug("Role change requested: " .. tostring(IsGroupFinderRoleChangeRequested()))
    debug("In queue: " .. tostring(ZO_GroupFinder_GetIsCurrentlyInQueue()))
    debug("Is solo/leader: " .. tostring(IsUnitSoloOrGroupLeader("player")))
    
    -- Clear any existing draft data first
    self:ClearDraftSettings()
    
    -- Show the creation dialog FIRST, navigating to the correct category
    local targetCategory = params.category
    self:ShowCreationDialog(targetCategory)
    
    -- Set our values AFTER the dialog opens and initializes (to avoid being overridden)
    zo_callLater(function()
        self:SetListingValues(params)
    end, 500) -- Increased delay to account for category navigation
    
    debug("Group listing dialog opened successfully!")
    
    return true
end

-- Separate function to set listing values after dialog initialization
function GroupListingCreator:SetListingValues(params)
    local userType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    
    debug("=== SETTING VALUES AFTER DIALOG INIT ===")
    
    -- Set basic parameters
    if params.title then
        debug("Setting title: " .. params.title)
        SetGroupFinderUserTypeGroupListingTitle(userType, params.title)
    end
    
    if params.description then
        debug("Setting description: " .. params.description)
        SetGroupFinderUserTypeGroupListingDescription(userType, params.description)
    end
    
    if params.category then
        debug("Setting category to: " .. tostring(params.category))
        SetGroupFinderUserTypeGroupListingCategory(userType, params.category)
        
        -- Update options after setting category to populate available selections
        UpdateGroupFinderUserTypeGroupListingOptions(userType)
        SetGroupFinderUserTypeGroupListingSecondaryOptionDefault(userType)
        
        debug("Category verification: " .. tostring(GetGroupFinderUserTypeGroupListingCategory(userType)))
        
        -- Set difficulty for dungeons/trials/arenas
        if params.difficulty and (params.category == self.CATEGORIES.DUNGEON or 
                                  params.category == self.CATEGORIES.ARENA or 
                                  params.category == self.CATEGORIES.TRIAL) then
            debug("Setting difficulty to: " .. tostring(params.difficulty))
            SetGroupFinderUserTypeGroupListingPrimaryOption(userType, params.difficulty)
            
            -- Update options again after setting primary option to populate secondary options
            UpdateGroupFinderUserTypeGroupListingOptions(userType)
            
            -- Set specific dungeon/trial if achievement data is provided
            if params.achievementData then
                debug("Will attempt to set specific " .. (params.category == self.CATEGORIES.TRIAL and "trial" or "dungeon") .. ": " .. params.achievementData.NAME)
                -- Wait a moment for the options to be fully updated, then set secondary
                zo_callLater(function()
                    local secondaryIndex = self:FindSecondaryOptionIndex(params.achievementData, userType)
                    if secondaryIndex then
                        debug("Setting secondary option to index: " .. secondaryIndex)
                        SetGroupFinderUserTypeGroupListingSecondaryOption(userType, secondaryIndex)
                        
                        -- Force UI refresh after all values are set
                        self:ForceUIRefresh()
                    end
                end, 100)
            else
                -- Force UI refresh even without secondary option
                self:ForceUIRefresh()
            end
        end
    end
    
    -- Check group size constraints before setting any value
    local groupSizeToSet = nil
    if params.groupSize then
        groupSizeToSet = params.groupSize
        debug("Will set explicit group size: " .. tostring(groupSizeToSet))
    elseif params.category then
        -- Auto-determine group size based on category if not explicitly set
        if params.category == self.CATEGORIES.DUNGEON or params.category == self.CATEGORIES.ARENA then
            groupSizeToSet = 4
        elseif params.category == self.CATEGORIES.TRIAL then
            groupSizeToSet = 12
        end
        if groupSizeToSet then
            debug("Will auto-set group size to " .. tostring(groupSizeToSet) .. " based on category " .. tostring(params.category))
        end
    end
    
    -- Check constraints for any group size we're trying to set
    if groupSizeToSet and params.category then
        debug("=== GROUP SIZE CONSTRAINTS DEBUG ===")
        debug("Category: " .. tostring(GetGroupFinderUserTypeGroupListingCategory(userType)))
        debug("Attempting to set group size: " .. tostring(groupSizeToSet))
        
        -- Use the correct ESO API functions for size constraints
        local minSize = GetGroupFinderUserTypeGroupSizeIterationBegin and GetGroupFinderUserTypeGroupSizeIterationBegin(userType) or "N/A"
        local maxSize = GetGroupFinderUserTypeGroupSizeIterationEnd and GetGroupFinderUserTypeGroupSizeIterationEnd(userType) or "N/A"
        debug("Min group size: " .. tostring(minSize))
        debug("Max group size: " .. tostring(maxSize))
        
        -- Check if our desired size is within valid range
        if type(minSize) == "number" and type(maxSize) == "number" then
            debug("Desired size " .. tostring(groupSizeToSet) .. " vs valid range [" .. tostring(minSize) .. ", " .. tostring(maxSize) .. "]")
            if groupSizeToSet < minSize or groupSizeToSet > maxSize then
                debug("ERROR: Desired group size " .. tostring(groupSizeToSet) .. " is outside valid range!")
                groupSizeToSet = math.max(minSize, math.min(maxSize, groupSizeToSet)) -- Clamp to valid range
                debug("Clamped group size to: " .. tostring(groupSizeToSet))
            else
                debug("Group size " .. tostring(groupSizeToSet) .. " is within valid range")
            end
        end
        debug("=== END CONSTRAINTS DEBUG ===")
    end
    
    -- Now set the group size (if we have one to set)
    if groupSizeToSet then
        debug("Group size before setting: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
        SetGroupFinderUserTypeGroupListingGroupSize(userType, groupSizeToSet)
        debug("Group size after setting: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
        
        -- Set it again after a delay to ensure it sticks (ESO might override it)
        zo_callLater(function()
            debug("Re-setting group size to " .. tostring(groupSizeToSet) .. " to ensure it sticks")
            debug("Group size before re-setting: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
            SetGroupFinderUserTypeGroupListingGroupSize(userType, groupSizeToSet)
            debug("Group size after re-setting: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
            
            -- If it's still not set correctly (especially for trials), try more aggressive approach
            if GetGroupFinderUserTypeGroupListingGroupSize(userType) ~= groupSizeToSet then
                debug("Group size still incorrect! Trying more aggressive approach...")
                
                -- Try setting it multiple times with short delays
                for i = 1, 5 do
                    zo_callLater(function()
                        debug("Retry attempt " .. i .. ": setting group size to " .. tostring(groupSizeToSet))
                        SetGroupFinderUserTypeGroupListingGroupSize(userType, groupSizeToSet)
                        debug("Group size after retry " .. i .. ": " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
                    end, i * 100) -- 100ms, 200ms, 300ms, 400ms, 500ms delays
                end
                
                -- Also try setting it much later after all other values are set
                zo_callLater(function()
                    debug("Final late attempt: setting group size to " .. tostring(groupSizeToSet))
                    debug("Group size before final attempt: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
                    SetGroupFinderUserTypeGroupListingGroupSize(userType, groupSizeToSet)
                    debug("Group size after final attempt: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
                    
                    -- Force UI refresh after final group size attempt
                    self:ForceUIRefresh()
                end, 1000) -- 1 second delay
            end
            
            -- Force UI refresh after group size change
            self:ForceUIRefresh()
        end, 200)
    end
    
    if params.playstyle then
        debug("Setting playstyle: " .. tostring(params.playstyle))
        SetGroupFinderUserTypeGroupListingPlaystyle(userType, params.playstyle)
    end
    
    -- Set role requirements
    if params.roles then
        debug("Setting role requirements...")
        GroupFinderUserTypeGroupListingClearDesiredRoles(userType)
        for role, count in pairs(params.roles) do
            if count > 0 then
                SetGroupFinderUserTypeGroupListingRoleCount(userType, role, count)
            end
        end
    end
    
    -- Set optional parameters
    if params.requiresChampion ~= nil then
        debug("Setting requires champion: " .. tostring(params.requiresChampion))
        SetGroupFinderUserTypeGroupListingRequiresChampion(userType, params.requiresChampion)
    end
    
    if params.autoAcceptRequests ~= nil then
        debug("Setting auto accept: " .. tostring(params.autoAcceptRequests))
        SetGroupFinderUserTypeGroupListingAutoAcceptRequests(userType, params.autoAcceptRequests)
    end
    
    if params.enforceRoles ~= nil then
        debug("Setting enforce roles: " .. tostring(params.enforceRoles))
        SetGroupFinderUserTypeGroupListingEnforceRoles(userType, params.enforceRoles)
    end
    
    debug("=== FINISHED SETTING VALUES ===")
end

-- Force UI refresh to display our set values
function GroupListingCreator:ForceUIRefresh()
    zo_callLater(function()
        if GROUP_FINDER_KEYBOARD and GROUP_FINDER_KEYBOARD.createGroupListingContent then
            debug("Forcing final UI refresh...")
            GROUP_FINDER_KEYBOARD.createGroupListingContent:Refresh()
        end
    end, 50)
end

-- Show the appropriate creation dialog based on platform
function GroupListingCreator:ShowCreationDialog(targetCategory)
    if IsInGamepadPreferredMode() then
        -- Gamepad mode
        if GROUP_FINDER_GAMEPAD and GROUP_FINDER_GAMEPAD.createEditDialogObject then
            GROUP_FINDER_GAMEPAD.createEditDialogObject:ShowDialog()
        end
    else
        -- Keyboard mode - navigate to correct category first, then open CREATE_EDIT
        if GROUP_FINDER_KEYBOARD and GROUP_MENU_KEYBOARD then
            -- Check if we're already in CREATE_EDIT mode and need to exit first
            local isAlreadyInCreateMode = GROUP_FINDER_KEYBOARD.mode == ZO_GROUP_FINDER_MODES.CREATE_EDIT
            
            if isAlreadyInCreateMode then
                debug("Already in CREATE_EDIT mode, exiting first to refresh data...")
                -- Exit the current create/edit state to allow new data to be set
                GROUP_FINDER_KEYBOARD:ExitCreateEditState()
                
                -- Wait a moment for the exit to complete, then proceed
                zo_callLater(function()
                    self:ShowCreationDialog(targetCategory) -- Recursively call to proceed with normal flow
                end, 100)
                return
            end
            
            -- Step 1: Navigate to the correct category in the search tree
            if targetCategory then
                debug("Navigating to category: " .. tostring(targetCategory) .. " before opening CREATE_EDIT")
                
                -- Set the search category directly to influence CREATE_EDIT initialization
                SetGroupFinderFilterCategory(targetCategory)
                
                -- Navigate to Group Finder scene and then set the category
                local tree = GROUP_MENU_KEYBOARD:GetTree()
                if tree then
                    -- First find the Group Finder category data
                    local groupFinderCategoryData = nil
                    tree:ExecuteOnSubTree(nil, function(node)
                        local data = node:GetData()
                        if data and data.isGroupFinder then
                            groupFinderCategoryData = data
                            return true -- Stop searching
                        end
                        return false
                    end)
                    
                    if groupFinderCategoryData then
                        -- Show the Group Menu scene first
                        GROUP_MENU_KEYBOARD:ShowCategoryByData(groupFinderCategoryData)
                        
                        -- Wait for scene to show, then find and select the target category node
                        zo_callLater(function()
                            -- Now find the specific category node (Trial/Dungeon/etc.)
                            local targetNode = nil
                            tree:ExecuteOnSubTree(nil, function(node)
                                local data = node:GetData()
                                if data and data.searchCategory == targetCategory then
                                    targetNode = node
                                    return true -- Stop searching
                                end
                                return false
                            end)
                            
                            if targetNode then
                                debug("Found target category node, selecting it...")
                                tree:SelectNode(targetNode)
                            else
                                debug("Warning: Could not find category node for " .. tostring(targetCategory))
                            end
                            
                            -- Wait for navigation to complete, then open CREATE_EDIT
                            zo_callLater(function()
                                debug("Category navigation complete, now opening CREATE_EDIT mode...")
                                GROUP_FINDER_KEYBOARD:SetMode(ZO_GROUP_FINDER_MODES.CREATE_EDIT)
                                debug("Group listing creation dialog should now be open with correct category!")
                            end, 200)
                        end, 100)
                    else
                        debug("Error: Could not find Group Finder category data")
                    end
                else
                    debug("Error: Could not access Group Menu tree")
                end
            else
                -- Fallback to original navigation logic if no target category specified
                local tree = GROUP_MENU_KEYBOARD:GetTree()
                if tree then
                    -- Find the Group Finder category data and its overview child node
                    local groupFinderCategoryData = nil
                    local overviewChildNode = nil
                    
                    tree:ExecuteOnSubTree(nil, function(node)
                        local data = node:GetData()
                        if data and data.isGroupFinder then
                            groupFinderCategoryData = data
                            -- Look for the overview child node (mode = OVERVIEW, no name)
                            local children = node:GetChildren()
                            if children then
                                for _, childNode in ipairs(children) do
                                    local childData = childNode:GetData()
                                    if childData and childData.mode == ZO_GROUP_FINDER_MODES.OVERVIEW then
                                        overviewChildNode = childNode
                                        break
                                    end
                                end
                            end
                            return true -- Stop searching
                        end
                        return false
                    end)
                    
                    if groupFinderCategoryData and overviewChildNode then
                        -- Step 1: Show the Group Menu scene
                        GROUP_MENU_KEYBOARD:ShowCategoryByData(groupFinderCategoryData)
                        
                        -- Step 2: Select the Group Finder overview node to activate Group Finder mode
                        zo_callLater(function()
                            debug("Selecting Group Finder overview node...")
                            tree:SelectNode(overviewChildNode)
                            
                            -- Step 3: Set CREATE_EDIT mode after Group Finder is active
                            zo_callLater(function()
                                if GROUP_FINDER_KEYBOARD then
                                    debug("Setting CREATE_EDIT mode...")
                                    GROUP_FINDER_KEYBOARD:SetMode(ZO_GROUP_FINDER_MODES.CREATE_EDIT)
                                    debug("Group listing creation dialog should now be open!")
                                end
                            end, 200)
                        end, 100)
                    else
                        debug("Error: Could not find Group Finder overview node")
                        debug("GroupFinderCategoryData: " .. tostring(groupFinderCategoryData ~= nil))
                        debug("OverviewChildNode: " .. tostring(overviewChildNode ~= nil))
                    end
                else
                    debug("Error: Could not access Group Menu tree")
                end
            end
        else
            debug("Error: Group Finder or Group Menu not available")
        end
    end
end

-- Convenience functions for common listing types
function GroupListingCreator:CreateDungeonListing(title, description, difficulty, requiresChampion)
    local params = {
        title = title or "LF Dungeon Group",
        description = description or "Looking for group to complete dungeon",
        category = self.CATEGORIES.DUNGEON,
        difficulty = difficulty or self.DIFFICULTIES.NORMAL,
        groupSize = 4,
        roles = {
            [self.ROLES.TANK] = 1,
            [self.ROLES.HEALER] = 1,
            [self.ROLES.DPS] = 2
        },
        playstyle = self.PLAYSTYLES.CASUAL,
        requiresChampion = requiresChampion or false,
        autoAcceptRequests = true,
        enforceRoles = true
    }
    
    return self:CreateListing(params)
end

function GroupListingCreator:CreateTrialListing(title, description, difficulty, requiresChampion, championPoints)
    local params = {
        title = title or "LF Trial Group",
        description = description or "Looking for group to complete trial",
        category = self.CATEGORIES.TRIAL,
        difficulty = difficulty or self.DIFFICULTIES.NORMAL,
        groupSize = 12,
        roles = {
            [self.ROLES.TANK] = 2,
            [self.ROLES.HEALER] = 2,
            [self.ROLES.DPS] = 8
        },
        playstyle = self.PLAYSTYLES.HARDCORE,
        requiresChampion = requiresChampion or true,
        championPoints = championPoints or 160,
        autoAcceptRequests = false,
        enforceRoles = true
    }
    
    return self:CreateListing(params)
end

function GroupListingCreator:CreateCustomListing(title, description, groupSize)
    local params = {
        title = title or "Custom Group",
        description = description or "Custom group activity",
        category = self.CATEGORIES.CUSTOM,
        groupSize = groupSize or 4,
        playstyle = self.PLAYSTYLES.CASUAL,
        autoAcceptRequests = true,
        enforceRoles = false
    }
    
    return self:CreateListing(params)
end

-- Debug function to print current draft settings
function GroupListingCreator:DebugCurrentDraft()
    local userType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    
    debug("=== Current Draft Settings ===")
    debug("Title: " .. (GetGroupFinderUserTypeGroupListingTitle(userType) or ""))
    debug("Description: " .. (GetGroupFinderUserTypeGroupListingDescription(userType) or ""))
    debug("Category: " .. tostring(GetGroupFinderUserTypeGroupListingCategory(userType)))
    debug("Size: " .. tostring(GetGroupFinderUserTypeGroupListingGroupSize(userType)))
    debug("Requires Champion: " .. tostring(DoesGroupFinderUserTypeGroupListingRequireChampion(userType)))
    -- debug("Champion Points: " .. tostring(GetGroupFinderCreateGroupListingChampionPoints(userType)))  -- We don't set this
    -- debug("Requires VOIP: " .. tostring(DoesGroupFinderUserTypeGroupListingRequireVOIP(userType)))  -- We don't set this
    debug("Auto Accept: " .. tostring(DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(userType)))
    debug("Enforce Roles: " .. tostring(DoesGroupFinderUserTypeGroupListingEnforceRoles(userType)))
    
    for _, role in pairs(self.ROLES) do
        local count = GetGroupFinderUserTypeGroupListingDesiredRoleCount(userType, role)
        if count > 0 then
            local roleName = role == self.ROLES.TANK and "Tank" or 
                           role == self.ROLES.HEALER and "Healer" or "DPS"
            debug(roleName .. ": " .. count)
        end
    end
    debug("=== End Draft Settings ===")
end

-- Debug function to test secondary option mapping without creating a listing
function GroupListingCreator:DebugSecondaryOptions(achievementData, category, difficulty)
    local userType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    
    debug("=== Setting up for debug ===")
    debug("Input Category: " .. tostring(category))
    debug("Input Difficulty: " .. tostring(difficulty))
    
    -- Set category and difficulty first
    SetGroupFinderUserTypeGroupListingCategory(userType, category)
    debug("Category set, now updating options...")
    
    -- Update options after setting category
    UpdateGroupFinderUserTypeGroupListingOptions(userType)
    SetGroupFinderUserTypeGroupListingSecondaryOptionDefault(userType)
    
    debug("Verifying category was set: " .. tostring(GetGroupFinderUserTypeGroupListingCategory(userType)))
    
    if difficulty then
        SetGroupFinderUserTypeGroupListingPrimaryOption(userType, difficulty)
        debug("Difficulty set, updating options again...")
        UpdateGroupFinderUserTypeGroupListingOptions(userType)
    end
    
    -- Wait a moment for options to update, then list them
    zo_callLater(function()
        debug("=== Secondary Options Debug ===")
        debug("Achievement: " .. (achievementData and achievementData.NAME or "None"))
        debug("Final Category: " .. tostring(GetGroupFinderUserTypeGroupListingCategory(userType)))
        debug("Final Difficulty: " .. tostring(difficulty))
        
        local numSecondaryOptions = GetGroupFinderUserTypeGroupListingNumSecondaryOptions(userType)
        debug("Total secondary options: " .. tostring(numSecondaryOptions))
        
        for i = 1, numSecondaryOptions do
            local optionName, _ = GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex(userType, i)
            if optionName then
                debug("  " .. i .. ": " .. optionName)
            end
        end
        
        if achievementData then
            local foundIndex = self:FindSecondaryOptionIndex(achievementData, userType)
            debug("Found match at index: " .. tostring(foundIndex))
        end
        
        debug("=== End Debug ===")
    end, 150)
end

-- Test function for achievement-based group listing creation
function GroupListingCreator:TestAchievementListing(achievementId)
    debug("Testing achievement " .. tostring(achievementId))
    local api = PITHKA.common.api
    local achievementData = api.achievement.getAchievementData(achievementId)
    
    if achievementData then
        debug("Found achievement data: " .. achievementData.NAME .. " (" .. achievementData.TYPE .. ")")
        local title = api.achievement.generateListingTitle(achievementData, achievementId)
        debug("Generated title: " .. title)
        
        local category, difficulty, groupSize, roles = api.achievement.getGroupListingParams(achievementData)
        if category then
            debug("Category: " .. tostring(category) .. ", Difficulty: " .. tostring(difficulty) .. ", Size: " .. tostring(groupSize))
        else
            debug("Unsupported achievement type for group listings")
        end
    else
        debug("Achievement not found in database")
    end
end 