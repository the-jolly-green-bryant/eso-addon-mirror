GSY = {}

-- Addon related values
GSY.name = 'DeltaScry'
GSY.displayname = 'DeltaScry'
GSY.version = 'v1.0.0'
GSY.author = 'Latetide & |c2046e5sshogrin|r'
GSY.init = false
GSY.variableVersion = 1
GSY.isDebug = false  -- switch this on for debugging to the console, or use /gsydbg

GSY.Default = {
    OffsetX = 1000,
    OffsetY = 80,
    Group = 2,
    Sort = 4,
    Treasure = false,
    Complete = false
}

GSY.partName = "Part" -- TODO: localise

GSY.hideComplete = false
GSY.hideTreasure = false

-- Define the names for the difficulties, used in Diff grouping
GSY.difficultyNames = { -- localise this?
    "Green", 
    "Blue", 
    "Purple", 
    "Gold", 
    "Orange", 
}

GSY.hiddenIDs = {}

-- Grouping definitions and translation
GSY.groupingEnum = {
    Original = 1, 
    HasLead = 2, 
    Type = 3, 
    DifficultyUp = 4, 
    DifficultyDown = 5,
    Zone = 6,
}

GSY.grouping = GSY.groupingEnum.HasLead -- from the enum above, used to pick the default selection in the combo

-- localise this
-- Used to populate the groups dropdown
GSY.groupNames = {}

GSY.groupNames[GSY.groupingEnum.Original] = "Original"
GSY.groupNames[GSY.groupingEnum.HasLead] = "Has Lead"
GSY.groupNames[GSY.groupingEnum.Type] = "Type"
GSY.groupNames[GSY.groupingEnum.DifficultyUp] = "Difficulty Up"
GSY.groupNames[GSY.groupingEnum.DifficultyDown] = "Difficulty Down"
GSY.groupNames[GSY.groupingEnum.Zone] = "Zone"

-- This one controls the order of groups in the dropdown. Simply iterating over them provides a random order, and dropdown sorting is alphabetical. 
-- DON'T FORGET TO ADD NEW GROUP TYPES HERE
-- alternative solution could be to rename the groups, e.g. "1. Original", "2. Has Lead" and enable dropdown sorting. I'm not particularly fond of that.
GSY.groupOrder = {GSY.groupingEnum.Original, GSY.groupingEnum.HasLead, GSY.groupingEnum.Type, GSY.groupingEnum.DifficultyUp, GSY.groupingEnum.DifficultyDown, GSY.groupingEnum.Zone}


-- Sorting definitions and translations
GSY.sortingEnum = { 
    Original = 1, 
    AlphaAZ = 2, 
    AlphaZA = 3, 
    Expiry = 4,  
    DiffUp = 5, 
    DiffDown = 6, 
}

GSY.sorting = GSY.sortingEnum.Expiry -- should pick from the enum above, used to pick default from the combo, only used after loading

-- localise this
-- Used to populate the sorting dropdown
GSY.sortNames = {}

GSY.sortNames[GSY.sortingEnum.Original] = "Original"
GSY.sortNames[GSY.sortingEnum.AlphaAZ] = "Alphabetical"
GSY.sortNames[GSY.sortingEnum.AlphaZA] = "Reverse Alpha"
GSY.sortNames[GSY.sortingEnum.Expiry] = "Expiry time"
GSY.sortNames[GSY.sortingEnum.DiffUp] = "Difficulty Up"
GSY.sortNames[GSY.sortingEnum.DiffDown] = "Difficulty Down"


-- Association of the allowed sorting types for the each group types, modders need to extend this if adding new group or sort types above
GSY.allowedSorting = {}

GSY.allowedSorting[GSY.groupingEnum.Original] = {
    GSY.sortingEnum.Original,
    GSY.sortingEnum.Expiry
}

GSY.allowedSorting[GSY.groupingEnum.HasLead] = {
    GSY.sortingEnum.Expiry,
    GSY.sortingEnum.AlphaAZ,
    GSY.sortingEnum.AlphaZA,
    GSY.sortingEnum.DiffUp,
    GSY.sortingEnum.DiffDown
}

GSY.allowedSorting[GSY.groupingEnum.Type] = {
    GSY.sortingEnum.AlphaAZ,
    GSY.sortingEnum.AlphaZA,
    GSY.sortingEnum.Expiry,
    GSY.sortingEnum.DiffUp,
    GSY.sortingEnum.DiffDown    
}

GSY.allowedSorting[GSY.groupingEnum.DifficultyUp] = {
    GSY.sortingEnum.AlphaAZ,
    GSY.sortingEnum.AlphaZA,
    GSY.sortingEnum.Expiry    
}

GSY.allowedSorting[GSY.groupingEnum.DifficultyDown] = {
    GSY.sortingEnum.AlphaAZ,
    GSY.sortingEnum.AlphaZA,
    GSY.sortingEnum.Expiry    
}

GSY.allowedSorting[GSY.groupingEnum.Zone] = {
    GSY.sortingEnum.AlphaAZ,
    GSY.sortingEnum.AlphaZA,
    GSY.sortingEnum.Expiry,
    GSY.sortingEnum.DiffUp,
    GSY.sortingEnum.DiffDown        
}


-- Sort functions. Controls the order inside the groups. True favours left, false favours right
-- don't put trace in here, there is a sorting testing function below, use GSY.sortingTest
GSY.sortingFunctions = {}

GSY.sortingFunctions[GSY.sortingEnum.AlphaAZ] = function(leftAntiquityData, rightAntiquityData) 
    return ZO_Antiquity.CompareNameTo(leftAntiquityData, rightAntiquityData)
end

GSY.sortingFunctions[GSY.sortingEnum.AlphaZA] = function(leftAntiquityData, rightAntiquityData) 
    return ZO_Antiquity.CompareNameTo(rightAntiquityData, leftAntiquityData)
end

GSY.sortingFunctions[GSY.sortingEnum.Expiry] = function(leftAntiquityData, rightAntiquityData)
    local leftLeadFalse = (not leftAntiquityData.requiresLead or leftAntiquityData.leadExpirationTimeS <= 0)
    local rightLeadFalse = (not rightAntiquityData.requiresLead or rightAntiquityData.leadExpirationTimeS <= 0)
    if leftLeadFalse then
        if rightLeadFalse then -- both are non expiring
            return ZO_Antiquity.CompareNameTo(leftAntiquityData, rightAntiquityData)
        else
            return false -- only right has expiry
        end
    elseif rightLeadFalse then
        return true -- only left has expiry
    end

    -- both have valid expiry
    return leftAntiquityData.leadExpirationTimeS < rightAntiquityData.leadExpirationTimeS
end

GSY.sortingFunctions[GSY.sortingEnum.DiffUp] = function(leftAntiquityData, rightAntiquityData) 
    if leftAntiquityData:GetQuality() < rightAntiquityData:GetQuality() then
        return true
    elseif leftAntiquityData:GetQuality() > rightAntiquityData:GetQuality() then
        return false
    end
    return ZO_Antiquity.CompareNameTo(leftAntiquityData, rightAntiquityData)
end

GSY.sortingFunctions[GSY.sortingEnum.DiffDown] = function(leftAntiquityData, rightAntiquityData)
    if leftAntiquityData:GetQuality() > rightAntiquityData:GetQuality() then
        return true
    elseif leftAntiquityData:GetQuality() < rightAntiquityData:GetQuality() then
        return false
    end
    return ZO_Antiquity.CompareNameTo(leftAntiquityData, rightAntiquityData)
end


-- Shortcuts for ESO globals
local EM, WM, SM = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER
local AM = ANTIQUITY_MANAGER
local ADM = ANTIQUITY_DATA_MANAGER 
local AJK = ANTIQUITY_JOURNAL_KEYBOARD
local RM = REWARDS_MANAGER -- to get the type of the lead


-- To enable verbose messaging with /gsydbg
function GSY.ToggleDebug() 
    GSY.isDebug = not GSY.isDebug
    if GSY.isDebug then
        d("DeltaScry: debug messages ON")
    else
        d("DeltaScry: debug messages OFF")
    end

end


--- Writes trace messages to the console
local function trace(fmt, ...)
	if GSY.isDebug then
		d("GSY: " .. string.format(fmt or "", ...))
    end
end


-- walks through the provided table and creates a formatted string to represent it, only used for debugging (returns the string so it can be saved)
local function printTableKeys(tbl) 
    local output = ""

    if type(tbl) ~= "table" then
        output = "Printing non table: " .. type(tbl)
    else
        output = "Keys: \n"
        for k, v in pairs(tbl) do
            local add = "?"
            if type(v) == "table" then
                add = "table"
            else
                add = tostring(v)
            end
            output = output .. k .. " -> " .. add .. "\n"
        end
    end
    if debug then
        trace(output)
    end
    return output
end


-- used to add new antiquity types to a list and count the occurances, we use this for type grouping
function GSY.addOrIncrease(type_array, ant_type) 
    if type_array[ant_type] == nil then
        type_array[ant_type] = 0
    end

    type_array[ant_type] = type_array[ant_type] + 1

    return type_array
end


-- You can use this when adding a new sorting method. 
-- Use /gsyins <name> first, it inspects the antiquities where their respective name starts with your string, e.g. "Stone"
-- From the displayed information you can get the id. 
-- Take two items, add your sort, and this will show you what it did. Check above to see how short functions work.
function GSY.sortingTest(id1, id2, sortFunction) 
    local item1 = ADM.antiquities[id1]
    local fail = false

    if not item1 then
        trace("ID incorrect: " .. id1)
        fail = true
    end
    
    local item2 = ADM.antiquities[id2]
    if not item2 then
        trace("ID incorrect: " .. id2)
        fail = true
    end
    
    if not sortFunction then
        trace("Sort function is invalid")
        fail = true
    end

    if fail then
        return
    end

    trace("Sort " .. item1.name .. " vs " .. item2.name .. ": " .. tostring(sortFunction(item1, item2)))
end


-- debug function to show details about one or more antiquities matching the name, e.g. /dsyins Stone
function GSY.InspectAntiquity(name)
    if not name then
        d("Please provide a name. Only works if Debug is on.")
        return
    end
    for _, antiquityData in pairs (ADM.antiquities) do
        if string.sub(antiquityData.name, 1, string.len(name)) == string.sub(name, 1, string.len(name)) then
            trace("************")
            trace("Inspecting: " .. antiquityData.name)
            printTableKeys(antiquityData)
            trace("************")
        end
    end
end


-- gets the type of the lead from the Reward manager - uses GSY.partName if empty. 
function getAType(antiquityData)
    return RM:GetRewardContextualTypeString(antiquityData.rewardId) or GSY.partName
end


-- Filter functions

-- should match *everything* that can be displayed
-- Extra filters can be added here
function GSY.minimumFilter(antiquityData)
    return (antiquityData:HasDiscovered() or (antiquityData:MeetsLeadRequirements() and not antiquityData:HasAchievedAllGoals())) and GSY.NotHidden(antiquityData)
end



-- Fallback section for each grouping so that we don't accidentally filter out something important
GSY.everythingElse = {
    sectionHeading = "Everything else", -- TODO: Localise
    filterFunctions = { GSY.minimumFilter }, 
    sortFunction = nil,
    sectionType = ZO_ANTIQUITY_SECTION_TYPE.AVAILABLE, -- something
    list = {}
}


-- returns the fallback block with the sorting function updated to the current selected one
function GSY.getOthersBlock(sortingFunction) 
    local others = GSY.everythingElse
    others.sortFunction = sortingFunction
    return others
end


-- This method collects all the types from the leads. For leads without type it uses GSY.partName 
function GSY.CollectTypes()
    local types = {}

    -- collect all possible types in the antiquity list
    for _, antiquityData in pairs (ADM.antiquities) do
        local rewardContextualTypeString = getAType(antiquityData)
        table.insert(types, rewardContextualTypeString)
    end

    -- sort the types alphabetically
    table.sort(types)

    return types 
end


-- This method collects all the types from the leads. For leads without type it uses GSY.partName 
function GSY.CollectZones()
    local zones = {}
    zones['Names'] = {} -- for alphabetically sorted names
    zones['IDs'] = {} -- for filtering

    -- collect all possible zones in the antiquity list
    for _, antiquityData in pairs (ADM.antiquities) do
        local zoneId = antiquityData:GetZoneId()
        local zoneName = GetZoneNameById(zoneId)
        table.insert(zones['Names'], zoneName)
        zones['IDs'][zoneName] = zoneId
    end

    -- sort the zones alphabetically
    table.sort(zones['Names'])

    return zones 
end


-- retrieves the specified sorting function or the default one
function GSY.getSortingFunction(selectedSort)
    local selectedSortFunction = GSY.sortingFunctions[selectedSort]

    if not selectedSortFunction then 
        selectedSortFunction = ZO_DefaultAntiquitySortComparison
        trace("Sorting function not found for sorting value of " .. selectedSort)
    end

    return selectedSortFunction
end


function GSY.NotHidden(antData) 
    local treasure = GSY.hideTreasure and getAType(antData) == "Treasure" -- TODO: Only if relevant checkbox is checked
    local idHidden = GSY.hiddenIDs[antData:GetId()] ~= nil -- TODO: Think of a way to hide stuff
    local found3 = GSY.hideComplete and antData:GetNumUnlockedLoreEntries() >= 3  -- TODO: Add "Found 3" checkbox and hiding

    return not (treasure or idHidden or found3)
end


function GSY.IsInProgress(antData)
    return ZO_Antiquity.IsInProgress(antData) and GSY.NotHidden(antData)
end


function GSY.MeetsAllScryingRequirements(antData)
    return ZO_Antiquity.MeetsAllScryingRequirements(antData) and GSY.NotHidden(antData)
end


function GSY.RequiresLead(antiquityData)
    return GSY.NotHidden(antiquityData) and antiquityData:IsInCurrentPlayerZone() and antiquityData:HasDiscovered() and not antiquityData:MeetsLeadRequirements() and (antiquityData:IsRepeatable() or not antiquityData:HasRecovered())
end


-- defines the groups for Has Lead, this is actually the original grouping with updated sorting
function GSY.createHasLeadAntiquityDisplayData(selectedGroup, selectedSort)
    local selectedSortFunction = GSY.getSortingFunction(selectedSort)

    local antiquitySectionData =
    {
        {
            sectionHeading = GetString(SI_ANTIQUITY_SUBHEADING_IN_PROGRESS),
            filterFunctions = { GSY.IsInProgress },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.IN_PROGRESS,
            list = {}
        },
        {
            sectionHeading = GetString(SI_ANTIQUITY_SUBHEADING_AVAILABLE),
            filterFunctions = { GSY.MeetsAllScryingRequirements },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.AVAILABLE,
            list = {}
        },
        {
            sectionHeading = GetString(SI_ANTIQUITY_SUBHEADING_REQUIRES_LEAD),
            filterFunctions =
            {
                GSY.RequiresLead
            },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.REQUIRES_LEAD,
            list = {}
        },
    }


    for antiquityDifficulty = 1, ANTIQUITY_DIFFICULTY_MAX_VALUE do
        local skillName, requiredRank, maximumRank = ZO_GetAntiquityScryingPassiveSkillInfo(antiquityDifficulty)
        local antiquitySection =
        {
            sectionHeading = zo_strformat(SI_ANTIQUITY_SUBHEADING_REQUIRES_SKILL, skillName, requiredRank, maximumRank),
            filterFunctions =
            {
                function(antiquityData)
                    local isMatch = antiquityData:IsInCurrentPlayerZone() and antiquityData:HasDiscovered() and not antiquityData:MeetsScryingSkillRequirements()
                    return GSY.NotHidden(antiquityData) and isMatch and antiquityData:GetDifficulty() == antiquityDifficulty
                end,
            },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.REQUIRES_SKILL,
            list = {}
        }
        table.insert(antiquitySectionData, antiquitySection)
    end

    local allElse = {
        sectionHeading = GetString(SI_ANTIQUITY_SUBHEADING_ACTIVE_LEADS),
        filterFunctions =
        {
            GSY.minimumFilter
        },
        sortFunction = selectedSortFunction,
        sectionType = ZO_ANTIQUITY_SECTION_TYPE.ACTIVE_LEAD,
        list = {}
    }
    table.insert(antiquitySectionData, allElse)

    return antiquitySectionData
end


-- Collects the types, set them as groups + add the sorting
function GSY.createTypeAntiquityDisplayData(selectedGroup, selectedSort)
    local selectedSortFunction = GSY.getSortingFunction(selectedSort)

    local types = GSY.CollectTypes()
    local antiquitySectionData = {}

    for i, type in ipairs(types) do
        local heading = {
            sectionHeading = type,
            filterFunctions = { function(antiquityData) return GSY.NotHidden(antiquityData) and getAType(antiquityData) == type end }, 
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.AVAILABLE, -- the type doesn't make sense here
            list = {}
        }
        table.insert(antiquitySectionData, heading)        
    end

    table.insert(antiquitySectionData, GSY.getOthersBlock(selectedSortFunction) ) -- fallback for anything not added above, should be empty

    return antiquitySectionData
end


-- Difficulties from green to orange + custom sorting
function GSY.createDiffUpAntiquityDisplayData(selectedGroup, selectedSort)
    local selectedSortFunction = GSY.getSortingFunction(selectedSort)
    local antiquitySectionData = {}

    --for ndx, name in ipairs(GSY.difficultyNames) do
    for antiquityDifficulty = 1, ANTIQUITY_DIFFICULTY_MAX_VALUE do    
        local heading = {
            sectionHeading = GSY.difficultyNames[antiquityDifficulty],
            filterFunctions = { function(antiquityData) return GSY.NotHidden(antiquityData) and antiquityData:GetQuality() == antiquityDifficulty end },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.REQUIRES_SKILL, 
            list = {}
        }
        table.insert(antiquitySectionData, heading)               
    end

    table.insert(antiquitySectionData, GSY.getOthersBlock(selectedSortFunction) ) -- fallback for anything not added above, should be empty

    return antiquitySectionData
end


-- Difficulties from orange to green + custom sorting
function GSY.createDiffDownAntiquityDisplayData(selectedGroup, selectedSort)
    local selectedSortFunction = GSY.getSortingFunction(selectedSort)
    local antiquitySectionData = {}

    for antiquityDifficulty = 1, ANTIQUITY_DIFFICULTY_MAX_VALUE do    
        local heading = {
            sectionHeading = GSY.difficultyNames[antiquityDifficulty],
            filterFunctions = { function(antiquityData) return GSY.NotHidden(antiquityData) and antiquityData:GetQuality() == antiquityDifficulty end },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.REQUIRES_SKILL, 
            list = {}
        }
        table.insert(antiquitySectionData, 1, heading)               
    end

    table.insert(antiquitySectionData, GSY.getOthersBlock(selectedSortFunction) ) -- fallback for anything not added above, should be empty

    return antiquitySectionData
end


-- Groups are zones
function GSY.createZoneAntiquityDisplayData(selectedGroup, selectedSort)
    local selectedSortFunction = GSY.getSortingFunction(selectedSort)
    local antiquitySectionData = {}
    
    local zones = GSY.CollectZones()

    for _, name in ipairs(zones['Names']) do
        local zoneID = zones['IDs'][name]
        local heading = {
            sectionHeading = name,
            filterFunctions = { function(antiquityData) return GSY.NotHidden(antiquityData) and antiquityData:GetZoneId() == zoneID end },
            sortFunction = selectedSortFunction,
            sectionType = ZO_ANTIQUITY_SECTION_TYPE.AVAILABLE, 
            list = {}
        }
        table.insert(antiquitySectionData, heading)             
    end

    table.insert(antiquitySectionData, GSY.getOthersBlock(selectedSortFunction) ) -- fallback for anything not added above, should be empty

    return antiquitySectionData
end


-- Here we define which function should be used for which group selection. 
-- These could be local functions, but for testing purposes and clarity I added them as standalone
GSY.antiquityDataFunctions = {}

GSY.antiquityDataFunctions[GSY.groupingEnum.Original] = function(a, b) d("You messed up") end -- this should never be called, if it is, you messed something up.
GSY.antiquityDataFunctions[GSY.groupingEnum.HasLead] = GSY.createHasLeadAntiquityDisplayData
GSY.antiquityDataFunctions[GSY.groupingEnum.Type] = GSY.createTypeAntiquityDisplayData
GSY.antiquityDataFunctions[GSY.groupingEnum.DifficultyUp] = GSY.createDiffUpAntiquityDisplayData
GSY.antiquityDataFunctions[GSY.groupingEnum.DifficultyDown] = GSY.createDiffDownAntiquityDisplayData
GSY.antiquityDataFunctions[GSY.groupingEnum.Zone] = GSY.createZoneAntiquityDisplayData


-- locates the relevant function for creating AntiquityDisplayData, and returns the outcome is the function is valid
function GSY.createAntiquityDisplayData(selectedGroup, selectedSort)
    local adf = GSY.antiquityDataFunctions[selectedGroup]

    if not adf then
        trace("Function invalid for " .. GSY.groupNames[selectedGroup])
        return nil
    end

    return adf(selectedGroup, selectedSort)
end


-- sets the AntiquityData display according to the current settings
function GSY.setADDisplay(group, sort)
    if group == GSY.groupingEnum.Original then
        AM.antiquitySectionData = nil
    else
        local antiquitySectionData = GSY.createAntiquityDisplayData(group, sort)
        AM.antiquitySectionData = antiquitySectionData
    end
    
    if AJK.categoryTree then -- to handle the first selection that happens before the journal is visible
        AJK:RefreshVisibleCategoryFilter()
    end
end


-- Calls into the antiquity manager to update grouping and listing
function GSY.sortComboSelection(_, entryText, entry) 
    trace("Selection in Sort: " .. entryText .. " group: " .. GSY.groupNames[entry.group])
    GSY.sorting = entry.value

    GSY.setADDisplay(entry.group, entry.value)

end


-- Populates the sort dropdown based on the group selection and selects the first item - this will trigger the sortComboSelection above
function GSY.SetupSortCombo(group)
    trace("Setup Sort Combo")

    local combo = GSY.sortComboBox

    local sortSelection = GSY.allowedSorting[group]

    local defaultEntry = nil

    if sortSelection then
        combo:ClearItems()
        for _, value in pairs(sortSelection) do
            local name = GSY.sortNames[value]
            local sortEntry = combo:CreateItemEntry(name, GSY.sortComboSelection)  
            sortEntry.value = value
            sortEntry.group = group
            combo:AddItem(sortEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
            if not defaultEntry then -- sets the first sorting function as default
                trace("* Default sort entry: " .. (name or "nil"))
                defaultEntry = sortEntry
            end
        end
    end

    combo:UpdateItems()
    if defaultEntry then
        GSY.selectedSort = defaultEntry.value
        combo:SelectItem(defaultEntry)
    end    
    
end


-- Called when an item is selected in the group combo - this doesn't check if we are re-selecting it, may be needed
function GSY.groupComboSelection(_, entryText, entry) 
    trace("Selection in Group: " .. entryText )
    GSY.grouping = entry.value
    GSY.SetupSortCombo(entry.value)
end


-- Handles the checkbox event for "Hide Complete"
function GSY.HideCompleteHandler(button, checked)
    trace("Complete Button Checked: " .. tostring(checked))
    GSY.hideComplete = checked
    GSY.setADDisplay(GSY.grouping, GSY.sorting)
end


-- Handles the checkbox event for Hide Treasure
function GSY.HideTreasureHandler(button, checked)
    trace("Complete Button Checked: " .. tostring(checked))
    GSY.hideTreasure = checked
    GSY.setADDisplay(GSY.grouping, GSY.sorting)
end


-- creates the combo boxes and populates the group one - sorting is populated based on the group combo selection
function GSY.SetupControls(control)
    trace("Setup group combo")
    GSY.control = control

    local comboBoxControl = control:GetNamedChild("GroupDropdown")
    GSY.groupComboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    GSY.groupComboBox:SetSortsItems(false)
    GSY.groupComboBox:SetSpacing(8)

    local sortComboControl = control:GetNamedChild("SortDropdown")
    GSY.sortComboBox = ZO_ComboBox_ObjectFromContainer(sortComboControl)
    GSY.sortComboBox:SetSortsItems(false)
    GSY.sortComboBox:SetSpacing(8)

    local hideTreasureCB = control:GetNamedChild("HideTreasure")
    local hideCompleteCB = control:GetNamedChild("HideComplete")
    ZO_CheckButton_SetToggleFunction(hideTreasureCB, GSY.HideTreasureHandler)
    ZO_CheckButton_SetToggleFunction(hideCompleteCB, GSY.HideCompleteHandler)

    -- The rest of the code below will load the content into the group combo, TODO: move it to a standalone function for moddability
    local combo = GSY.groupComboBox -- shortcut

    local defaultEntry = nil

    for _, value in pairs(GSY.groupOrder) do
        local name = GSY.groupNames[value]
        local groupEntry = combo:CreateItemEntry(name, GSY.groupComboSelection)  
        groupEntry.value = value
        combo:AddItem(groupEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
        if value == GSY.grouping then
            trace("* Default entry found: " .. (name or "nil") )
            defaultEntry = groupEntry
        end
    end

    combo:UpdateItems()
    if defaultEntry then
        GSY.selectedGroup = defaultEntry.value
        combo:SelectItem(defaultEntry)
    end
end    
 
--Saved Variables
--getFunc = function() return GetSelectedGroup() end
--setFunc = function(Group) SetSelectedGroup(Group) end
--getFunc = function() return GetSelectedSort() end
--setFunc = function(Sort) SetSelectedSort(Sort) end
local function GetSelectedGroup()
    return GSY.savedVariables.Group
end

local function SetSelectedGroup(Group)
    GSY.sortComboSelection:GetsetADDisplay()
    savedVariables.Group = Group
end

local function GetSelectedSort()
    return GSY.savedVariables.Sort
end

local function SetSelectedSort(Sort)
    GSY.SetupSortCombo:GetAddItem()
    savedVariables.Sort = Sort
end

function GSY.SaveLoc()
    GSY.savedVariables.OffsetX = GSY.topLevelWindow:GetLeft()
    GSY.savedVariables.OffsetY = GSY.topLevelWindow:GetTop()
end

--function GSY.SaveFilter()
    --GSY.savedVariables.Group = GSY.sortComboSelection:GetSelectedGroup()
    --GSY.savedVariables.Sort = GSY.sortComboSelection:GetSelectedSort()
    --GSY.savedVariables.Treasure = GSY.NotHidden:Get()
    --GSY.savedVariables.Complete = GSY.NotHidden:get()
--end

--function GSY.RestoreFilters()
    --Group = GSY.savedVariables.Group
    --Sort = GSY.savedVariables.Sort
    --Treasure = GSY.savedVariables.Treasure
    --Complete = GSY.savedVariables.Complete
--end

-- Create the window, populate the dropdowns and attach handlers 
function GSY.InitUI()
    trace("UI Init")
    local cParent = WM:GetControlByName("ZO_AntiquityJournal_Keyboard_TopLevelContents")


    -- Add ChangeFilterDialogue
    GSY.topLevelWindow = WINDOW_MANAGER:CreateControlFromVirtual("GammScry", cParent, "GSYHangingWindow") 
    GSY.topLevelWindow:ClearAnchors()
    GSY.topLevelWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GSY.savedVariables.OffsetX, GSY.savedVariables.OffsetY)
    GSY.topLevelWindow:SetHidden(false) 
    
    trace("* Added Hanging Window")

    GSY.SetupControls(GSY.topLevelWindow)

   

    --GSY.RestoreFilters()

    -- These lines are here as an example for testing sorting
    --GSY.sortingTest(660, 635, GSY.sortingFunctions[GSY.sortingEnum.Expiry]) -- false
    --GSY.sortingTest(635, 660, GSY.sortingFunctions[GSY.sortingEnum.Expiry]) -- true
    --GSY.sortingTest(635, 342, GSY.sortingFunctions[GSY.sortingEnum.Expiry]) -- true
    --GSY.sortingTest(660, 342, GSY.sortingFunctions[GSY.sortingEnum.Expiry]) -- false        
end



-- Attach a handler to new antiquities, create slash command, schedule UI creation
function GSY.Initialize()
    d("Init")

    GSY.savedVariables = ZO_SavedVars:NewAccountWide("DeltaScryVars", GSY.variableVersion, nil, GSY.Default, GetWorldName())
   
    local function OnAntiquityLeadAcquired(event, antiquityId)
        local antiquityData = ADM:GetAntiquityData(antiquityId)

        local colorDef = GetAntiquityQualityColor(antiquityData:GetQuality())
        local name = colorDef:Colorize(antiquityData:GetName())

        d("|cFFAA33DeltaScry - new lead:|r ["..name.."]") -- TODO: make this clickable?
    end
    
    SLASH_COMMANDS["/bsydbg"] = BSY.ToggleDebug
	SLASH_COMMANDS["/gsydbg"] = GSY.ToggleDebug
	SLASH_COMMANDS["/gsyins"] = GSY.InspectAntiquity
    
 
    EM:RegisterForEvent("DeltaScry", EVENT_ANTIQUITY_LEAD_ACQUIRED, OnAntiquityLeadAcquired)

    BSY.ZO_SortFunction = ZO_DefaultAntiquitySortComparison

    -- TODO: Add save & restore for selected group & sort

    -- initialize toggle button
    zo_callLater(BSY.InitButton, 900)
    BSY.init = true

	zo_callLater(GSY.InitUI, 900)
    GSY.init = true
end

-- Standard addon launch function
function GSY.OnAddOnLoaded(event, addonName)
  if addonName ~= GSY.name then return end

  EM:UnregisterForEvent('GSY_LOADED',EVENT_ADD_ON_LOADED)
  
  GSY.Initialize()
end


EM:RegisterForEvent('GSY_LOADED', EVENT_ADD_ON_LOADED, GSY.OnAddOnLoaded)

