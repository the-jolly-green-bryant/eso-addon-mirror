-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.common = PITHKA.common or {}
PITHKA.common.api = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils

-- Debug function
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|c0eaFF[API]|r ' .. msg)
    end
end

---------------------------------------------------------------------------------------------------------
-- GUI Wrappers
---------------------------------------------------------------------------------------------------------
api.gui = {}

-- Wrapper for SetDimensions function
function api.gui.setDimensions(width, height)
    PITHKA_GUI:SetDimensions(width, height)
end

-- Wrapper for SetTitle function
function api.gui.setTitle(title)
    PITHKA_GUI:GetNamedChild("WindowTitle"):SetText(
        string.format("%s|%s%s|r", 'Pithka Achievement Tracker  ', constants.color.hexBlue, title)
    )
end

-- Wrapper for toggleUI - Full scene management for main tracker
function api.gui.toggleUI()
    SCENE_MANAGER:ToggleTopLevel(PITHKA_GUI)
end    

---------------------------------------------------------------------------------------------------------
-- Control Wrappers
---------------------------------------------------------------------------------------------------------
api.control = {}

-- Wrapper for create label 
function api.control.newLabel()
    control = WINDOW_MANAGER:CreateControl("$(parent)"..utils.uid(), PITHKA_GUI, CT_LABEL)
    control:SetDrawTier(DT_HIGH)
    return control
end

-- Wrapper for create button
function api.control.newIcon()
    control = WINDOW_MANAGER:CreateControl("$(parent)_Icon" .. utils.uid(), PITHKA_GUI, CT_TEXTURE)
    control:SetDrawTier(DT_HIGH)
    return control
end

-- Wrapper for create button
function api.control.newButton()
    control = WINDOW_MANAGER:CreateControl("$(parent)_Icon" .. utils.uid(), PITHKA_GUI, CT_BUTTON)
    control:SetDrawTier(DT_HIGH)
    return control
end


function api.control.newTexture()
    control = WINDOW_MANAGER:CreateControl("$(parent)_Texture" .. utils.uid(), PITHKA_GUI, CT_TEXTURE)
    control:SetDrawTier(DT_LOW) -- qr code lib needs this to be low
    return control
end

-- Wrapper for open tooltip
function api.control.tooltipOpenFn(control, ttt, tta, ttc, ttf)
    fn = function(control) 
        ZO_Tooltips_ShowTextTooltip(control, tta, ttt)
        --InformationTooltip:AddLine(string.format('|%s%s|r', ttc, ttt), ttf)
        end
    return fn
end

-- Wrapper for close tooltip
function api.control.tooltipCloseFn(control)
    fn = function(control) 
        -- close all other tooltip types
        ClearTooltip(InformationTooltip)
        ClearTooltip(ItemTooltip)
        ZO_Tooltips_HideTextTooltip()
    end 
    return fn
end


---------------------------------------------------------------------------------------------------------
-- Travel Wrappers
---------------------------------------------------------------------------------------------------------
api.travel = {}

-- Wrapper to queue into vet or normal dungeon
function api.travel.queueFn(id, name)
    return function()
        api.gui.toggleUI()
        d("Queueing " .. name)
        AddActivityFinderSpecificSearchEntry(id)
	    StartGroupFinderSearch()
    end
end

-- Wrapper to teleport into dungeon or trial
function api.travel.portFn(id, name)
    return function()
        api.gui.toggleUI()
        d("Porting " .. name)
        FastTravelToNode(id)
    end
end

---------------------------------------------------------------------------------------------------------
-- Score Wrappers
---------------------------------------------------------------------------------------------------------
api.scores = {}

function api.scores.requestTrial(lbIndex)
    local RAID_CATEGORY = 0 -- for trials
    QueryRaidLeaderboardData(RAID_CATEGORY, lbIndex)
end

function api.scores.requestEndless(endlessDungeonGroupType, endlessDungeonId)
    local classId = 1 -- default class ID for non-solo queries
    if endlessDungeonGroupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO then
        classId = GetUnitClassId("player") -- use player's class for solo queries
    end
    QueryEndlessDungeonLeaderboardData(endlessDungeonGroupType, endlessDungeonId, classId)
end

function api.scores.resultTrial(raidId)
    local _, bestScore = GetRaidLeaderboardLocalPlayerInfo(raidId)
    return bestScore
end

---------------------------------------------------------------------------------------------------------
-- Achievement Wrappers
---------------------------------------------------------------------------------------------------------
api.achievement ={}
api.achievement.aidcache = {}

function api.achievement.IsComplete(aid) 
	done = api.achievement.aidcache[aid]
	if(not done) then 
	   done = IsAchievementComplete(aid)
	   api.achievement.aidcache[aid] = done
	end
	return done
end

function api.achievement.released(aid)
    return GetAchievementIdFromLink(GetAchievementLink(aid,1)) ~= 0 
end

function api.achievement.tooltipFn(aid)
    return function(control) 
        InitializeTooltip(ItemTooltip, control, TOP, 0, 0, BOTTOM)
        ItemTooltip:SetLink(GetAchievementLink(aid,1))
    end
end

function api.achievement.clickForJournal(aid)
    return function (control, mButton) -- control and mButoon passed in context
        if mButton == 1	then
            -- open achievement window
            if not SCENE_MANAGER:IsShowing("achievements") then
                MAIN_MENU_KEYBOARD:ShowScene("achievements")
            end			
            -- set global aid for callback
            PITHKA.ACHIEVEMENTAID = aid
            -- update search box
            ACHIEVEMENTS.contentSearchEditBox:SetText(GetAchievementName(aid))
        end
    end
end

function api.achievement.clickForLinkInChat(aid)
    return function()
        -- Get the achievement link and send it to chat
        local achievementLink = GetAchievementLink(aid, 1)
        if achievementLink then
            -- Insert the link into the chat input box
            if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
                local currentText = CHAT_SYSTEM.textEntry:GetText()
                local newText = currentText .. achievementLink
                CHAT_SYSTEM.textEntry:SetText(newText)
                CHAT_SYSTEM.textEntry:TakeFocus()
                
                -- Provide user feedback
                local achievementName = GetAchievementName(aid)
                d("|cFFD700[Pithka]|r Achievement link for '" .. achievementName .. "' added to chat")
            else
                d("|cFF6B6B[Pithka]|r Error: Could not access chat system")
            end
        else
            d("|cFF6B6B[Pithka]|r Error: Could not generate achievement link")
        end
    end
end

function api.achievement.clickForContextMenu(aid)
    return function(control, mButton)
        -- Right click to show context menu
        if mButton == 2 then
            ClearMenu()
        elseif mButton == 1 then
            ClearMenu()
            
            -- Add "Link in Chat" option
            AddMenuItem("Link in Chat", function()
                -- Get the achievement link and send it to chat
                local achievementLink = GetAchievementLink(aid, 1)
                if achievementLink then
                    -- Insert the link into the chat input box
                    if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
                        local currentText = CHAT_SYSTEM.textEntry:GetText()
                        local newText = currentText .. achievementLink
                        CHAT_SYSTEM.textEntry:SetText(newText)
                    else
                        d("|cFF6B6B[Pithka]|r Error: Could not access chat system")
                    end
                end
            end)
            
            -- Add "Open Journal" option
            AddMenuItem("Open Journal", function()
                -- open achievement window
                if not SCENE_MANAGER:IsShowing("achievements") then
                    MAIN_MENU_KEYBOARD:ShowScene("achievements")
                end			
                -- set global aid for callback
                PITHKA.ACHIEVEMENTAID = aid
                -- update search box
                ACHIEVEMENTS.contentSearchEditBox:SetText(GetAchievementName(aid))
            end)
            
            -- Add "Create Group Finder" option
            AddMenuItem("Create Group Finder", function()
                -- Close the Pithka UI
                PITHKA.toggleUI()
                
                -- Temporarily pause GroupFinder if it's running to avoid role conflicts
                local groupFinderWasActive = false
                if PITHKA.groupFinder.instance then
                    local currentState = PITHKA.groupFinder.instance.stateMachine:GetCurrentState()
                    if currentState == PITHKA.groupFinder.StateMachine.STATES.SEARCHING then
                        groupFinderWasActive = true
                        debug("Pausing GroupFinder searches to create listing...")
                        PITHKA.groupFinder.instance:StopSearch()
                    end
                end
                
                -- Wait a moment for role changes to settle, then create listing
                zo_callLater(function()
                    local achievementData = api.achievement.getAchievementData(aid)
                    if achievementData then
                        local title = api.achievement.generateListingTitle(achievementData, aid)
                        local achievementName = GetAchievementName(aid)
                        local description = string.format("Achievement Name: %s\nCreated by Pithka Achievement Tracker", achievementName)
                        local category, difficulty, groupSize, roles = api.achievement.getGroupListingParams(achievementData)
                        
                        if category then
                            local creator = PITHKA.groupFinder.GroupListingCreator
                            local params = {
                                title = title,
                                description = description,
                                category = category,
                                difficulty = difficulty,
                                groupSize = groupSize,
                                roles = roles,
                                playstyle = difficulty == creator.DIFFICULTIES.VETERAN and creator.PLAYSTYLES.HARDCORE or creator.PLAYSTYLES.CASUAL,
                                requiresChampion = difficulty == creator.DIFFICULTIES.VETERAN,
                                autoAcceptRequests = true,
                                enforceRoles = true,
                                achievementData = achievementData -- Pass the achievement data for specific dungeon/trial mapping
                            }
                            
                            creator:CreateListing(params)
                            
                            -- Resume GroupFinder if it was active (after a delay)
                            if groupFinderWasActive then
                                zo_callLater(function()
                                    debug("Resuming GroupFinder searches...")
                                    PITHKA.groupFinder.instance:StartSearch()
                                end, 2000)
                            end
                        else
                            debug("Cannot create group listing for this achievement type")
                        end
                    else
                        debug("Achievement data not found in Pithka database")
                    end
                end, 1000) -- 1 second delay to let role changes settle
            end)
            
            ShowMenu(control)
        end
    end
end

function api.achievement.getAchievementData(aid)
    -- Search through the achievement database to find the matching achievement
    local achievements = PITHKA.data.achievements
    for _, data in pairs(achievements) do
        if data.VET == aid or data.HM == aid or data.PHM1 == aid or data.PHM2 == aid or 
           data.TRI == aid or data.EXT == aid or data.CHA == aid or data.SR == aid or data.ND == aid then
            return data
        end
    end
    return nil
end

function api.achievement.generateListingTitle(achievementData, aid)
    local achievementType = ""
    
    -- Debug: Check what fields are available
    debug("=== TITLE GENERATION DEBUG ===")
    debug("Achievement ID: " .. tostring(aid))
    debug("achievementData.NAME: " .. tostring(achievementData.NAME))
    debug("achievementData.ABBV: " .. tostring(achievementData.ABBV))
    
    -- Debug: Show all fields in achievementData
    debug("All achievement data fields:")
    for key, value in pairs(achievementData) do
        debug("  " .. tostring(key) .. ": " .. tostring(value))
    end
    
    -- Determine the achievement type based on which field matches
    if achievementData.VET == aid then
        achievementType = "Veteran"
    elseif achievementData.HM == aid then
        achievementType = "Hard Mode"
    elseif achievementData.PHM1 == aid then
        achievementType = "HM+" .. (achievementData.PHM1NAME or "1")
    elseif achievementData.PHM2 == aid then
        achievementType = "HM+" .. (achievementData.PHM2NAME or "2") 
    elseif achievementData.TRI == aid then
        achievementType = "Trifecta"
    elseif achievementData.EXT == aid then
        achievementType = "Extra"  -- Changed from "Challenge"
    elseif achievementData.CHA == aid then
        achievementType = "Challenger"
    elseif achievementData.SR == aid then
        achievementType = "Speed Run"
    elseif achievementData.ND == aid then
        achievementType = "No Death"
    else
        achievementType = "Achievement"
    end
    
    -- Use abbreviation instead of full name
    local abbreviation = achievementData.ABBV or achievementData.NAME
    debug("Using abbreviation: " .. tostring(abbreviation))
    debug("Achievement type: " .. tostring(achievementType))
    
    local finalTitle = string.format("%s %s", abbreviation, achievementType)
    debug("Final title: " .. finalTitle)
    debug("=== END TITLE DEBUG ===")
    
    return finalTitle
end

function api.achievement.getGroupListingParams(achievementData)
    local creator = PITHKA.groupFinder.GroupListingCreator
    local category, difficulty, groupSize, roles
    
    -- Determine category and settings based on achievement type
    if achievementData.TYPE == "trial" then
        category = creator.CATEGORIES.TRIAL
        difficulty = creator.DIFFICULTIES.VETERAN
        groupSize = 12
        roles = {
            [creator.ROLES.TANK] = 2,
            [creator.ROLES.HEALER] = 2,
            [creator.ROLES.DPS] = 8
        }
    elseif achievementData.TYPE == "triDungeon" or achievementData.TYPE == "baseDungeon-wI" or achievementData.TYPE == "baseDungeon-noI" then
        category = creator.CATEGORIES.DUNGEON
        difficulty = creator.DIFFICULTIES.VETERAN
        groupSize = 4
        roles = {
            [creator.ROLES.TANK] = 1,
            [creator.ROLES.HEALER] = 1,
            [creator.ROLES.DPS] = 2
        }
    elseif achievementData.TYPE == "arena" then
        category = creator.CATEGORIES.ARENA
        difficulty = creator.DIFFICULTIES.VETERAN
        groupSize = 4
        roles = {
            [creator.ROLES.TANK] = 1,
            [creator.ROLES.HEALER] = 1,
            [creator.ROLES.DPS] = 2
        }
    else
        -- For endless or other types, return nil to indicate unsupported
        return nil, nil, nil, nil
    end
    
    return category, difficulty, groupSize, roles
end

function api.achievement.clickForGroupListing(aid)
    return function (control, mButton)
        if mButton == 1 then
            -- Close the Pithka UI
            PITHKA.toggleUI()
            
            -- Temporarily pause GroupFinder if it's running to avoid role conflicts
            local groupFinderWasActive = false
            if PITHKA.groupFinder.instance then
                local currentState = PITHKA.groupFinder.instance.stateMachine:GetCurrentState()
                if currentState == PITHKA.groupFinder.StateMachine.STATES.SEARCHING then
                    groupFinderWasActive = true
                    debug("Pausing GroupFinder searches to create listing...")
                    PITHKA.groupFinder.instance:StopSearch()
                end
            end
            
            -- Wait a moment for role changes to settle, then create listing
            zo_callLater(function()
                local achievementData = api.achievement.getAchievementData(aid)
                if achievementData then
                    local title = api.achievement.generateListingTitle(achievementData, aid)
                    local achievementName = GetAchievementName(aid)
                    local description = string.format("Achievement Name: %s\nCreated by Pithka Achievement Tracker", achievementName)
                    local category, difficulty, groupSize, roles = api.achievement.getGroupListingParams(achievementData)
                    
                    if category then
                        local creator = PITHKA.groupFinder.GroupListingCreator
                        local params = {
                            title = title,
                            description = description,
                            category = category,
                            difficulty = difficulty,
                            groupSize = groupSize,
                            roles = roles,
                            playstyle = difficulty == creator.DIFFICULTIES.VETERAN and creator.PLAYSTYLES.HARDCORE or creator.PLAYSTYLES.CASUAL,
                            requiresChampion = difficulty == creator.DIFFICULTIES.VETERAN,
                            autoAcceptRequests = true,
                            enforceRoles = true,
                            achievementData = achievementData -- Pass the achievement data for specific dungeon/trial mapping
                        }
                        
                        creator:CreateListing(params)
                        
                        -- Resume GroupFinder if it was active (after a delay)
                        if groupFinderWasActive then
                            zo_callLater(function()
                                debug("Resuming GroupFinder searches...")
                                PITHKA.groupFinder.instance:StartSearch()
                            end, 2000)
                        end
                    else
                        debug("Cannot create group listing for this achievement type")
                    end
                else
                    debug("Achievement data not found in Pithka database")
                end
            end, 1000) -- 1 second delay to let role changes settle
        end
    end
end

---------------------------------------------------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------------------------------------------------
-- On Journal Search Result ----------------------
PITHKA.ACHIEVEMENTAID = 0
function PITHKA.achievementSearchCallback()
  -- limit to just searches trigged by addon
	if ACHIEVEMENTS.contentSearchEditBox:GetText() == GetAchievementName(PITHKA.ACHIEVEMENTAID) then
		-- navigate to category
		local categoryIndex, subCategoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(PITHKA.ACHIEVEMENTAID)
		ACHIEVEMENTS:OpenCategory(categoryIndex, subCategoryIndex)
		-- expand achievement
		if ACHIEVEMENTS.achievementsById[PITHKA.ACHIEVEMENTAID] then
			ACHIEVEMENTS.achievementsById[PITHKA.ACHIEVEMENTAID]:Expand()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY, PITHKA.achievementSearchCallback)     

