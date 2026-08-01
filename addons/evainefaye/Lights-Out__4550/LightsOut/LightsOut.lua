LightsOut = LightsOut or {}
LightsOut.name = "LightsOut"
LightsOut.author = "@evainefaye"
LightsOut.version = "2.1.0"

local DEFAULT_SAVED_VARIABLES = {
    debug = false,
    houses = {},
}

function LightsOut.Dbg(message)
    if LightsOut.savedVars and LightsOut.savedVars.debug then
        d("|c66CCFF[LightsOut]|r " .. tostring(message))
    end
end

function LightsOut.Print(message)
    d("|c66CCFF[LightsOut]|r " .. tostring(message))
end

function LightsOut.ShowHelp()
    LightsOut.Print("|cFFFF00LightsOut Commands:|r")
    LightsOut.Print("/lo or /lightsout - Open the preferred LightsOut panel")
    LightsOut.Print("/lo help - Show this help")
    LightsOut.Print("/lo populatehouse - Scan the current house and add possible teams")
    LightsOut.Print("/lo teams - Prepare zone chat team/scoring information")
    LightsOut.Print("/lo add <teamname> - Manually add the selected item for Target/Threshold")
    LightsOut.Print("/lo add war <teamname> - Manually add the selected item/state for War")
    LightsOut.Print("")
    LightsOut.Print("Use the Game Setup panel to enable teams, choose mode/count/timer, start games, reset games, and open the Mini Panel.")
end


--[[
    LightsOut.IsInHouse

    Determines whether the player is currently inside a player house.

    This function checks the current zone's house ID using the ESO API:
        GetCurrentZoneHouseId()

    Parameters:
        showMessage (boolean, optional)
            true  - Print "House Zone Only Function" if not in a house
            false - Do not print any message (default behavior)

    Returns:
        boolean
            true  - Player is inside a house
            false - Player is not inside a house

    Behavior:
        - Returns true if inside a house
        - Returns false if not in a house
        - Optionally prints a message when not in a house

    Notes:
        - Keeps messaging logic centralized
        - Prevents repeating error messages across functions

    Example:
        if not LightsOut.IsInHouse(true) then return end
]]
function LightsOut.IsInHouse(showMessage)
    local inHouse = GetCurrentZoneHouseId() ~= 0

    if not inHouse and showMessage then
        LightsOut.Print("House Zone Only Function")
    end
    
    return inHouse
end


local function LightsOut_DefaultControlPanelSettings()
    return {
        left = 90,
        top = 70,
        width = 1360,
        height = 844,
        selectedMode = "threshold",
        requiredCount = "all",
        timeLimitMinutes = nil,
        confirmCounted = true,
    }
end

local function LightsOut_TableHasEntries(t)
    if type(t) ~= "table" then return false end
    for _ in pairs(t) do return true end
    return false
end

local function LightsOut_NormalizeSavedVarKeyPart(value, fallback)
    local text = tostring(value or ""):match("^%s*(.-)%s*$")

    if text == "" or string.lower(text) == "nil" then
        text = fallback or "unknown"
    end

    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("[%[%]{}=,;]", " ")
    text = text:gsub("%s+", "_")
    text = text:gsub("[^%w@_%-]", "")
    text = text:gsub("_+", "_")
    text = text:match("^_*(.-)_*$")
    text = string.lower(text or "")

    if text == "" then
        text = fallback or "unknown"
    end

    return text
end

function LightsOut.GetCurrentHouseOwnerKey()
    local owner = nil

    -- GetCurrentHouseOwner is the expected ESO API while visiting a house.
    -- The alternate names are defensive fallbacks for API/version differences.
    local ownerFunctions = {
        rawget(_G, "GetCurrentZoneHouseOwner"),
        rawget(_G, "GetCurrentHouseOwner"),
        rawget(_G, "GetCurrentHousingHouseOwner"),
        rawget(_G, "GetHousingCurrentHouseOwner"),
    }

    for _, ownerFunction in ipairs(ownerFunctions) do
        if type(ownerFunction) == "function" then
            local ok, result = pcall(ownerFunction)

            if ok and result and tostring(result) ~= "" then
                owner = result
                break
            end
        end
    end

    -- Fallback for owned houses or API cases where the owner function is not
    -- available. This keeps existing behavior safe instead of writing to nil.
    if (owner == nil or tostring(owner) == "") and type(GetUnitDisplayName) == "function" then
        local ok, result = pcall(GetUnitDisplayName, "player")

        if ok and result and tostring(result) ~= "" then
            owner = result
        end
    end

    return LightsOut_NormalizeSavedVarKeyPart(owner, "unknown_owner")
end

function LightsOut.GetCurrentHouseKey()
    local houseId = 0

    if type(GetCurrentZoneHouseId) == "function" then
        houseId = GetCurrentZoneHouseId() or 0
    end

    houseId = tonumber(houseId) or 0

    if houseId <= 0 then
        return nil
    end

    local ownerKey = LightsOut.GetCurrentHouseOwnerKey()

    -- House zone IDs are template IDs, so two different players can own the
    -- same house ID. Store data under owner + house ID to keep those setups
    -- separate.
    return tostring(ownerKey) .. ":" .. tostring(houseId)
end

function LightsOut.GetHouseSavedVars()
    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.houses = LightsOut.savedVars.houses or {}

    local houseKey = LightsOut.GetCurrentHouseKey() or "0"
    local hadHouseData = LightsOut_TableHasEntries(LightsOut.savedVars.houses)
    local houseVars = LightsOut.savedVars.houses[houseKey]

    if not houseVars then
        houseVars = {
            items = {},
            warTeams = {},
            controlPanel = LightsOut_DefaultControlPanelSettings(),
        }

        -- One-time migration for existing saves that were created before data
        -- was stored per house. Only the first real house loaded receives the
        -- old account-wide setup, so later houses start with their own empty setup.
        if houseKey ~= "0" and not hadHouseData and not LightsOut.savedVars.legacyHouseDataMigrated then
            if LightsOut_TableHasEntries(rawget(LightsOut.savedVars, "items")) then
                houseVars.items = LightsOut.savedVars.items
            end

            if LightsOut_TableHasEntries(rawget(LightsOut.savedVars, "warTeams")) then
                houseVars.warTeams = LightsOut.savedVars.warTeams
            end

            if type(rawget(LightsOut.savedVars, "controlPanel")) == "table" then
                houseVars.controlPanel = LightsOut.savedVars.controlPanel
            end

            LightsOut.savedVars.legacyHouseDataMigrated = true
        end

        LightsOut.savedVars.houses[houseKey] = houseVars
    end

    houseVars.items = houseVars.items or {}
    houseVars.warTeams = houseVars.warTeams or {}

    local defaultControlPanel = LightsOut_DefaultControlPanelSettings()
    houseVars.controlPanel = houseVars.controlPanel or {}

    for key, value in pairs(defaultControlPanel) do
        if houseVars.controlPanel[key] == nil then
            houseVars.controlPanel[key] = value
        end
    end

    houseVars.controlPanel.selectedMode = houseVars.controlPanel.selectedMode or "threshold"
    if houseVars.controlPanel.selectedMode ~= "target" and houseVars.controlPanel.selectedMode ~= "war" then
        houseVars.controlPanel.selectedMode = "threshold"
    end

    -- timeLimitMinutes intentionally allows nil because nil means no time limit.
    -- Store setup options separately per game mode.  "all" is the default
    -- required target setting and is resolved to the current maximum count when
    -- the game starts.
    houseVars.controlPanel.modeSettings = houseVars.controlPanel.modeSettings or {}
    for _, modeKey in ipairs({ "threshold", "target", "war" }) do
        local settings = houseVars.controlPanel.modeSettings[modeKey] or {}
        if settings.requiredCount == nil then
            settings.requiredCount = "all"
        elseif settings.requiredCount ~= "all" then
            settings.requiredCount = math.max(1, tonumber(settings.requiredCount or 1) or 1)
        end

        -- Leave nil alone; nil means no time limit.
        if settings.timeLimitMinutes ~= nil then
            settings.timeLimitMinutes = tonumber(settings.timeLimitMinutes)
        end

        -- Target-only setup option.  Keep it per-mode so it can persist with
        -- the Target configuration without affecting Threshold or War.
        if settings.confirmCounted == nil then
            settings.confirmCounted = true
        else
            settings.confirmCounted = settings.confirmCounted == true
        end

        houseVars.controlPanel.modeSettings[modeKey] = settings
    end

    -- One-time migration for the earlier per-mode patch that seeded every mode
    -- with 1.  That patch did not let the selector update correctly, so treat
    -- those untouched default-looking values as All.
    if not houseVars.controlPanel.perModeAllDefaultMigrated then
        for _, modeKey in ipairs({ "threshold", "target", "war" }) do
            local settings = houseVars.controlPanel.modeSettings[modeKey]
            if settings and tonumber(settings.requiredCount) == 1 and settings.timeLimitMinutes == nil then
                settings.requiredCount = "all"
            end
        end
        houseVars.controlPanel.perModeAllDefaultMigrated = true
    end

    local selectedSettings = houseVars.controlPanel.modeSettings[houseVars.controlPanel.selectedMode]
    if selectedSettings then
        houseVars.controlPanel.requiredCount = selectedSettings.requiredCount or "all"
        houseVars.controlPanel.timeLimitMinutes = selectedSettings.timeLimitMinutes
        houseVars.controlPanel.confirmCounted = selectedSettings.confirmCounted == true
    else
        houseVars.controlPanel.requiredCount = "all"
        houseVars.controlPanel.timeLimitMinutes = nil
        houseVars.controlPanel.confirmCounted = true
    end

    return houseVars
end

function LightsOut.SetActiveHouseSavedVars()
    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.houses = LightsOut.savedVars.houses or {}

    local houseKey = LightsOut.GetCurrentHouseKey()

    if not houseKey then
        LightsOut.savedVars.activeHouseKey = nil
        LightsOut.savedVars.items = {}
        LightsOut.savedVars.warTeams = {}
        LightsOut.savedVars.controlPanel = LightsOut_DefaultControlPanelSettings()
        return nil
    end

    local houseVars = LightsOut.GetHouseSavedVars()

    -- Keep legacy direct references working while storing the real data under houses[owner:houseId].
    LightsOut.savedVars.activeHouseKey = houseKey
    LightsOut.savedVars.items = houseVars.items
    LightsOut.savedVars.warTeams = houseVars.warTeams
    LightsOut.savedVars.controlPanel = houseVars.controlPanel

    return houseVars
end

local function LightsOut_IsValidFurnitureId(furnitureId)
    if furnitureId == nil or furnitureId == 0 then return false end

    local asNumber = tonumber(furnitureId)
    if not asNumber then return false end

    -- NaN is the only Lua number that is not equal to itself.  ESO can
    -- serialize that as -nan in SavedVariables, which corrupts the save file.
    if asNumber ~= asNumber then return false end

    local asText = string.lower(tostring(furnitureId))
    if string.find(asText, "nan", 1, true) then return false end

    return true
end

local function LightsOut_IsValidFurnitureDataId(furnitureDataId)
    local asNumber = tonumber(furnitureDataId)
    if not asNumber or asNumber == 0 or asNumber ~= asNumber then return false end

    local asText = string.lower(tostring(furnitureDataId))
    if string.find(asText, "nan", 1, true) then return false end

    return true
end

local function LightsOut_SafeText(value, fallback)
    local text = tostring(value or ""):match("^%s*(.-)%s*$")
    if text == "" or string.lower(text) == "nil" then
        text = fallback or "Unknown"
    end

    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("[\r\n\t]", " ")
    text = text:gsub("[%[%]{}=,;]", " ")
    text = text:gsub("%s+", " ")
    text = text:match("^%s*(.-)%s*$")

    if text == "" then text = fallback or "Unknown" end
    return text
end

local function LightsOut_SafeKey(value, fallback)
    local text = string.lower(LightsOut_SafeText(value, fallback or "team"))
    text = text:gsub("[^%w%s_%-]", "")
    text = text:gsub("%s+", "_")
    text = text:gsub("_+", "_")
    text = text:match("^_*(.-)_*$")

    if text == "" then text = fallback or "team" end
    return text
end



--[[
    HouseFurnishingCount

    Counts the total number of placed furnishings in the current house.

    This function uses the ESO housing iterator:
        GetNextPlacedHousingFurnitureId(previousFurnitureId)

    The iterator works by:
        - Passing nil to retrieve the first furnishing
        - Passing the last returned furnitureId to retrieve the next
        - Continuing until the API returns nil or 0, indicating the end

    Behavior:
        - Requires the player to be inside a house
        - Iterates through ALL placed furnishings
        - Increments a counter for each valid furnishing found
        - Prints the final count to chat

    Returns:
        nil (prints result via LightsOut.Print())

    Notes:
        - furnitureId is a unique identifier for each placed instance
        - This function does NOT inspect furnishing types or states,
          it only counts total placed objects
        - This is the most reliable way to enumerate all furnishings
          in the current house using the ESO API

    Example Output:
        Total Furnishings in House: 159
]]
function LightsOut.HouseFurnishingCount()

    -- Ensure the player is currently inside a house before running
    if not LightsOut.IsInHouse(true) then
        return
    end

    -- Iterator state: holds the previously returned furnitureId
    -- Starts as nil to retrieve the first furnishing
    local previousId = nil

    -- Running total of furnishings found
    local count = 0

    -- Iterate through all placed furnishings
    while true do
        -- Get the next furnishing in the sequence
        local furnitureId = GetNextPlacedHousingFurnitureId(previousId)

        -- Stop when no more furnishings are returned
        if not furnitureId or furnitureId == 0 then
            break
        end

        -- Increment count for each valid furnishing
        count = count + 1

        -- Update iterator to continue traversal
        previousId = furnitureId
    end

    -- Output the total count to chat
    LightsOut.Print("Total Furnishings in House: " .. count)
end

--[[
    ListHouseItems

    Iterates through ALL placed furnishings in the current house and prints
    identifying information for each item to the chat window.

    This function uses the ESO housing iterator:
        GetNextPlacedHousingFurnitureId(previousFurnitureId)

    Iterator Behavior:
        - Pass nil to retrieve the first placed furnishing
        - Pass the previously returned furnitureId to retrieve the next
        - Continue until the API returns nil or 0 (end of list)

    Important:
        - This iterator traverses EVERY placed furnishing in the house
        - This is the most reliable way to enumerate house contents

    For each furnishing, the function retrieves:
        - name               : Display name of the furnishing
        - furnitureId        : Unique identifier for this specific placed instance
        - furnitureDataId    : Shared identifier for all copies of this furnishing type

    Output Format:
        <Name> | furnitureID (unique): <id> | furnitureDataId (shared): <id>

    Behavior:
        - Requires the player to be inside a house
        - Iterates through every placed furnishing
        - Prints each furnishing’s identifying information
        - Tracks and prints the total number of furnishings scanned

    Returns:
        nil (results are printed to chat using LightsOut.Print())

    Notes:
        - furnitureId is unique per placed object (instance-specific)
        - furnitureDataId is consistent across identical furnishing types
        - furnitureDataId should be used for grouping/matching items
        - This function is intended for debugging and validation

    Example Output:
        Alinor Sconce, Wall | furnitureID (unique): 123456789 | furnitureDataId (shared): 9876
        Scanned 159 placed furnishing(s).
]]
function LightsOut.ListHouseItems()

    -- Ensure the player is currently inside a house before running
    if not LightsOut.IsInHouse(true) then
        return
    end

    -- Iterator state: holds the previously returned furnitureId
    -- Starts as nil to retrieve the first furnishing
    local previousFurnitureId = nil

    -- Track furnitureDataIds that have already been displayed so each
    -- furnishing type is listed only once, even if multiple copies are placed.
    local seenFurnitureDataIds = {}

    -- Running counts for scanned furnishings and unique furnishing types listed
    local scannedCount = 0
    local listedCount = 0

    -- Iterate through all placed furnishings
    while true do
        -- Retrieve the next furnishing in the sequence
        local furnitureId = GetNextPlacedHousingFurnitureId(previousFurnitureId)

        -- Exit loop when no more furnishings are returned
        if not furnitureId or furnitureId == 0 then
            break
        end

        -- Advance iterator to next furnishing before any filtering/printing
        previousFurnitureId = furnitureId
        scannedCount = scannedCount + 1

        if not LightsOut_IsValidFurnitureId(furnitureId) then
            LightsOut.Dbg("Skipped invalid furnitureId while listing house items: " .. tostring(furnitureId))
        else
            local name, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
            local furnitureDataKey = tostring(furnitureDataId or "")

            -- Only inspect/print the first placed copy of each furnitureDataId.
            if LightsOut_IsValidFurnitureDataId(furnitureDataId) and not seenFurnitureDataIds[furnitureDataKey] then
            seenFurnitureDataIds[furnitureDataKey] = true

            -- Only list interactable furnishings that expose two or more object states
            local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)
            numStates = tonumber(numStates or 0) or 0

            if numStates >= 2 then
                listedCount = listedCount + 1

                for stateIndex = 0, numStates - 1 do
                    local stateName = LightsOut.GetStateDisplayName(furnitureId, stateIndex)

                    LightsOut.Print(zo_strformat(
                        "|c00FF00<<1>>|r (<<2>>) |cFFFF00<<3>>|r",
                        tostring(name or "Unknown"),
                        tostring(numStates),
                        tostring(stateName or ("State " .. tostring(stateIndex)))
                    ))
                end
            end
            end
        end
    end

    LightsOut.Print("Listed " .. tostring(listedCount) .. " unique interactable furnishing type(s) with 2+ states. Scanned " .. tostring(scannedCount) .. " placed furnishing(s).")
end

local function LightsOut_FurnitureDataIdIsAssignedToStandardTeam(furnitureDataId)
    furnitureDataId = tonumber(furnitureDataId)
    if not furnitureDataId then return false end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    for _, entry in pairs(LightsOut.savedVars.items) do
        if entry and tonumber(entry.furnitureDataId) == furnitureDataId then
            return true
        end
    end

    return false
end

local function LightsOut_FurnitureDataIdIsAssignedToWarTeam(furnitureDataId)
    furnitureDataId = tonumber(furnitureDataId)
    if not furnitureDataId then return false end

    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}

    for _, entry in pairs(LightsOut.savedVars.warTeams) do
        if entry and tonumber(entry.furnitureDataId) == furnitureDataId then
            return true
        end
    end

    return false
end

local function LightsOut_FurnitureDataIdIsAssigned(furnitureDataId)
    return LightsOut_FurnitureDataIdIsAssignedToStandardTeam(furnitureDataId)
        or LightsOut_FurnitureDataIdIsAssignedToWarTeam(furnitureDataId)
end

local function LightsOut_MakeUniqueTeamName(baseName, itemName, tableRef)
    baseName = LightsOut_SafeText(baseName, "State")

    tableRef = tableRef or {}
    local candidate = baseName
    local key = LightsOut_SafeKey(candidate, "team")

    if tableRef[key] == nil then
        return candidate, key
    end

    local itemPart = LightsOut_SafeText(itemName, "Item")

    candidate = baseName .. " - " .. itemPart
    key = LightsOut_SafeKey(candidate, "team")

    if tableRef[key] == nil then
        return candidate, key
    end

    local suffix = 2
    while tableRef[key] ~= nil do
        candidate = baseName .. " - " .. itemPart .. " " .. tostring(suffix)
        key = LightsOut_SafeKey(candidate, "team")
        suffix = suffix + 1
    end

    return candidate, key
end

local function LightsOut_AddPopulateWarTeamsForItem(furnitureId, furnitureDataId, itemName, icon, numStates, matchingFurniture, matchingCount)
    if LightsOut_FurnitureDataIdIsAssignedToWarTeam(furnitureDataId) then
        return 0
    end

    local added = 0

    for stateIndex = 0, numStates - 1 do
        local stateName = LightsOut_SafeText(LightsOut.GetStateDisplayName(furnitureId, stateIndex), "State " .. tostring(stateIndex))
        local teamName = stateName
        local normalizedName = LightsOut_SafeKey(teamName, "state")
        local teamKey = tostring(tonumber(furnitureDataId)) .. ":" .. normalizedName
        local suffix = 2

        while LightsOut.savedVars.warTeams[teamKey] ~= nil do
            teamName = stateName .. " " .. tostring(suffix)
            normalizedName = LightsOut_SafeKey(teamName, "state")
            teamKey = tostring(tonumber(furnitureDataId)) .. ":" .. normalizedName
            suffix = suffix + 1
        end

        LightsOut.savedVars.warTeams[teamKey] = {
            name = teamName,
            itemName = LightsOut_SafeText(itemName, "Unknown Item"),
            icon = icon,
            enabled = false,
            furnitureDataId = furnitureDataId,
            state = stateIndex,
            stateName = stateName,
            numStates = numStates,
            matchingCount = matchingCount,
            furnitureIds = matchingFurniture,
        }

        added = added + 1
    end

    return added
end


local function LightsOut_ItemHasUniqueWarStateNames(furnitureId, numStates)
    numStates = tonumber(numStates or 0) or 0
    if numStates < 2 then return false end

    local seenStateNames = {}

    for stateIndex = 0, numStates - 1 do
        local stateName = LightsOut_SafeText(
            LightsOut.GetStateDisplayName(furnitureId, stateIndex),
            "State " .. tostring(stateIndex)
        )
        local stateKey = LightsOut_SafeKey(stateName, "state")

        if seenStateNames[stateKey] then
            return false
        end

        seenStateNames[stateKey] = true
    end

    return true
end

function LightsOut.PopulateHouseTeams()
    if LightsOut.populateInProgress then
        LightsOut.Print("Populate is already running.")
        return
    end

    if not LightsOut.IsInHouse(true) then return end

    LightsOut.SetActiveHouseSavedVars()
    LightsOut.savedVars.items = LightsOut.savedVars.items or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}

    LightsOut.populateInProgress = true

    local countBatchSize = 150
    local scanBatchSize = 80
    local totalFurnishings = 0
    local previousFurnitureId = nil

    local groups = {}
    local groupOrder = {}
    local scannedCount = 0
    local eligibleCount = 0
    local skippedStandardAssignedCount = 0
    local skippedWarAssignedCount = 0
    local skippedWarDuplicateStateNameCount = 0
    local normalTeamsAdded = 0
    local warTeamsAdded = 0

    local function finishPopulate(cancelled)
        LightsOut.populateInProgress = false

        if cancelled then
            LightsOut.UpdateProgressWindow("Populate cancelled", "Populate stopped because you are no longer in a house.", scannedCount, math.max(totalFurnishings, 1))
            LightsOut.HideProgressWindowSoon(1300)
            return
        end

        if type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
            -- Counts were just built from the populate scan, so do not do another
            -- expensive full furnishing recount while rebuilding the panel.
            LightsOut.RefreshControlPanelForTeamChange({ refreshCounts = false })
        elseif LightsOut.ui and LightsOut.ui.controlWindow and type(LightsOut.RefreshControlWindow) == "function" then
            LightsOut.RefreshControlWindow()
        end

        LightsOut.UpdateProgressWindow(
            "Populate complete",
            zo_strformat("Scanned <<1>> furnishing(s), added <<2>> team(s) and <<3>> War team(s).", tostring(scannedCount), tostring(normalTeamsAdded), tostring(warTeamsAdded)),
            math.max(totalFurnishings, 1),
            math.max(totalFurnishings, 1)
        )

        LightsOut.HideProgressWindowSoon(1000)

        LightsOut.Print(zo_strformat(
            "Populate House complete. Scanned <<1>> furnishing(s), found <<2>> unique interactable furnishing type(s), skipped <<3>> standard-assigned type(s), skipped <<4>> War-assigned type(s), skipped <<5>> War type(s) with duplicate state names, added <<6>> team(s) and <<7>> War team(s).",
            tostring(scannedCount),
            tostring(eligibleCount),
            tostring(skippedStandardAssignedCount),
            tostring(skippedWarAssignedCount),
            tostring(skippedWarDuplicateStateNameCount),
            tostring(normalTeamsAdded),
            tostring(warTeamsAdded)
        ))
    end

    local function buildTeamsFromGroups()
        LightsOut.UpdateProgressWindow(
            "Building team assignments...",
            "Creating team entries from the scanned furnishing cache. ESO may briefly pause while controls refresh.",
            scannedCount,
            math.max(totalFurnishings, 1)
        )

        for _, dataKey in ipairs(groupOrder) do
            local group = groups[dataKey]
            if group and group.numStates and group.numStates >= 2 then
                eligibleCount = eligibleCount + 1

                local furnitureDataId = group.furnitureDataId
                local matchingFurniture = group.furnitureIds or {}
                local matchingCount = #matchingFurniture

                if group.numStates == 2 then
                    if LightsOut_FurnitureDataIdIsAssignedToStandardTeam(furnitureDataId) then
                        skippedStandardAssignedCount = skippedStandardAssignedCount + 1
                    else
                        local stateIndex = 0
                        local stateName = LightsOut_SafeText(LightsOut.GetStateDisplayName(group.firstFurnitureId, stateIndex), "State " .. tostring(stateIndex))
                        local teamName, teamKey = LightsOut_MakeUniqueTeamName(stateName, group.itemName, LightsOut.savedVars.items)

                        LightsOut.savedVars.items[teamKey] = {
                            name = teamName,
                            itemName = LightsOut_SafeText(group.itemName, "Unknown Item"),
                            icon = group.icon,
                            enabled = false,
                            furnitureDataId = furnitureDataId,
                            state = stateIndex,
                            stateName = stateName,
                            matchingCount = matchingCount,
                            furnitureIds = matchingFurniture,
                        }

                        normalTeamsAdded = normalTeamsAdded + 1
                    end
                end

                if not LightsOut_ItemHasUniqueWarStateNames(group.firstFurnitureId, group.numStates) then
                    skippedWarDuplicateStateNameCount = skippedWarDuplicateStateNameCount + 1
                else
                    local addedWarTeams = LightsOut_AddPopulateWarTeamsForItem(group.firstFurnitureId, furnitureDataId, group.itemName, group.icon, group.numStates, matchingFurniture, matchingCount)
                    if addedWarTeams == 0 then
                        skippedWarAssignedCount = skippedWarAssignedCount + 1
                    else
                        warTeamsAdded = warTeamsAdded + addedWarTeams
                    end
                end
            end
        end

        finishPopulate(false)
    end

    local function scanStep()
        if not LightsOut.IsInHouse(false) then
            finishPopulate(true)
            return
        end

        local processed = 0
        while processed < scanBatchSize do
            local furnitureId = GetNextPlacedHousingFurnitureId(previousFurnitureId)
            if not furnitureId or furnitureId == 0 then
                previousFurnitureId = nil
                buildTeamsFromGroups()
                return
            end

            previousFurnitureId = furnitureId
            scannedCount = scannedCount + 1
            processed = processed + 1

            if not LightsOut_IsValidFurnitureId(furnitureId) then
                LightsOut.Dbg("Skipped invalid furnitureId while populating house: " .. tostring(furnitureId))
            else
                local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
                if LightsOut_IsValidFurnitureDataId(furnitureDataId) then
                    local dataKey = tostring(furnitureDataId)
                    local group = groups[dataKey]

                    if group == nil then
                        local numStates = tonumber(GetPlacedHousingFurnitureNumObjectStates(furnitureId) or 0) or 0
                        if numStates >= 2 then
                            group = {
                                furnitureDataId = furnitureDataId,
                                firstFurnitureId = furnitureId,
                                itemName = itemName,
                                icon = icon,
                                numStates = numStates,
                                furnitureIds = {},
                            }
                            groups[dataKey] = group
                            table.insert(groupOrder, dataKey)
                        else
                            groups[dataKey] = false
                        end
                    end

                    if group then
                        local list = group.furnitureIds
                        list[#list + 1] = { furnitureId = furnitureId }
                    end
                end
            end
        end

        LightsOut.UpdateProgressWindow(
            "Scanning house furnishings...",
            zo_strformat("Scanned <<1>>/<<2>> furnishing(s). Building a cache so Populate does not repeatedly rescan the house.", tostring(scannedCount), tostring(totalFurnishings)),
            scannedCount,
            math.max(totalFurnishings, 1)
        )

        if type(zo_callLater) == "function" then
            zo_callLater(scanStep, 1)
        else
            scanStep()
        end
    end

    local function countStep()
        if not LightsOut.IsInHouse(false) then
            finishPopulate(true)
            return
        end

        local processed = 0
        while processed < countBatchSize do
            local furnitureId = GetNextPlacedHousingFurnitureId(previousFurnitureId)
            if not furnitureId or furnitureId == 0 then
                previousFurnitureId = nil
                LightsOut.UpdateProgressWindow(
                    "Scanning house furnishings...",
                    zo_strformat("Found <<1>> placed furnishing(s). Starting interactable scan now.", tostring(totalFurnishings)),
                    0,
                    math.max(totalFurnishings, 1)
                )
                if type(zo_callLater) == "function" then
                    zo_callLater(scanStep, 1)
                else
                    scanStep()
                end
                return
            end

            previousFurnitureId = furnitureId
            totalFurnishings = totalFurnishings + 1
            processed = processed + 1
        end

        LightsOut.UpdateProgressWindow(
            "Counting house furnishings...",
            zo_strformat("Counted <<1>> furnishing(s) so far. ESO may briefly pause during large housing scans.", tostring(totalFurnishings)),
            0,
            1
        )

        if type(zo_callLater) == "function" then
            zo_callLater(countStep, 1)
        else
            countStep()
        end
    end

    LightsOut.ShowProgressWindow(
        "Counting house furnishings...",
        "Populate is scanning your house. ESO may briefly pause while furnishing data is read.",
        0,
        1
    )

    if type(zo_callLater) == "function" then
        zo_callLater(countStep, 50)
    else
        countStep()
    end
end

--[[
    LightsOut.CanEditHouse

    Determines whether the player currently has permission to edit (decorate)
    the active house.

    This function performs two checks in order:
        1. Confirms the player is inside a house
        2. Checks if the player has editing permissions

    Returns:
        boolean
            true  - Player is inside a house AND has editing permissions
            false - Player is not in a house OR lacks editing permissions

    Behavior:
        - Immediately returns false if the player is not inside a house
        - Uses HasAnyEditingPermissionsForCurrentHouse() for permission check
        - Covers owner, decorator, and any role with edit access

    Notes:
        - This is the recommended ESO API for checking housing edit permissions
        - Safe to call from anywhere without additional guards

    Example:
        if not LightsOut.CanEditHouse() then
            LightsOut.Print("Must be in a house with edit permissions.")
            return
        end
]]
function LightsOut.CanEditHouse()
    -- First ensure we are inside a house
    if not LightsOut.IsInHouse(false) then
        return false
    end

    -- Then check edit permissions
    return HasAnyEditingPermissionsForCurrentHouse()
end

--[[
    LightsOut.HasVisitorOrHigherAccessForCurrentHouse

    Determines whether the player can interact with adjustable furnishings in the
    current house. Limited Visitor access can enter the house, but cannot adjust
    lights/interactive furnishings, so starting a game requires Visitor or higher.
]]
function LightsOut.HasVisitorOrHigherAccessForCurrentHouse()
    if not LightsOut.IsInHouse(false) then
        return false
    end

    if type(HasAnyEditingPermissionsForCurrentHouse) == "function" and HasAnyEditingPermissionsForCurrentHouse() then
        return true
    end

    if type(GetHousingPermissionPresetType) == "function" then
        local ok, permissionPreset = pcall(GetHousingPermissionPresetType)

        if ok then
            local visitorPreset = rawget(_G, "HOUSING_PERMISSION_PRESET_SETTING_VISITOR") or rawget(_G, "HOUSE_PERMISSION_PRESET_SETTING_VISITOR")
            local decoratorPreset = rawget(_G, "HOUSING_PERMISSION_PRESET_SETTING_DECORATOR") or rawget(_G, "HOUSE_PERMISSION_PRESET_SETTING_DECORATOR")

            if visitorPreset ~= nil and permissionPreset == visitorPreset then
                return true
            end

            if decoratorPreset ~= nil and permissionPreset == decoratorPreset then
                return true
            end

            -- Fallback for API versions where the numeric values are exposed but
            -- the constants are not. Earlier testing used 1=Visitor, 2=Decorator.
            if visitorPreset == nil and decoratorPreset == nil then
                local numericPreset = tonumber(permissionPreset)
                if numericPreset == 1 or numericPreset == 2 then
                    return true
                end
            end
        end
    end

    return false
end

function LightsOut.RequireVisitorOrHigherAccessForGameStart()
    if LightsOut.HasVisitorOrHigherAccessForCurrentHouse() then
        return true
    end

    LightsOut.Print("You must have Visitor access or higher to start a game because the game changes interactive furnishings.")
    return false
end




--[[
    LightsOut.GetMatchingHouseFurniture

    Scans all placed furnishings in the current house and returns every
    furnishing instance that matches the provided furnitureDataId.

    Parameters:
        targetFurnitureDataId (number)
            The shared furnitureDataId to search for

    Returns:
        table, number
            matches - table of matching placed furniture placement(s)
            count   - number of matches found
]]
function LightsOut.GetMatchingHouseFurniture(targetFurnitureDataId)

    local matches = {}
    local count = 0
    local previousFurnitureId = nil

    while true do
        local furnitureId = GetNextPlacedHousingFurnitureId(previousFurnitureId)

        if not furnitureId or furnitureId == 0 then
            break
        end

        local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)

        if LightsOut_IsValidFurnitureId(furnitureId) and tonumber(furnitureDataId) == tonumber(targetFurnitureDataId) then
            count = count + 1

            matches[count] = {
                furnitureId = furnitureId,
            }
        end

        previousFurnitureId = furnitureId
    end

    return matches, count
end




--[[
    LightsOut.AddSelectedFurniture

    Assigns the currently selected housing furnishing to a named entry
    and stores its identifying information and current state.

    This function performs the following steps:
        1. Validates and normalizes the provided name
        2. Confirms the player is inside a house
        3. Retrieves the currently selected furnishing from the housing editor
        4. Validates the furnishing is a 2-state interactable object
        5. Reads the current state (0-based index)
        6. Retrieves furnishing identity data (name and furnitureDataId)
        7. Attempts to resolve a human-readable state name
        8. Ensures uniqueness of furnitureDataId across all saved entries
        9. Saves or replaces the entry in SavedVariables

    Parameters:
        name (string)
            A user-defined label used to identify the entry (e.g., team name)

    Returns:
        nil (results are stored in SavedVariables and confirmed via chat output)

    Behavior:
        - Requires the player to be inside a house
        - Requires a furnishing to be selected in the housing editor
        - Only accepts interactable furnishings with exactly two states
        - Removes any existing entry using the same furnitureDataId
        - Overwrites existing entries using the same name (case-insensitive)

    Data Stored:
        name              : User-defined label for the entry
        itemName          : Display name of the furnishing
        furnitureDataId   : Shared identifier for all copies of this furnishing type
        state             : Current state index (0-based)
        stateName         : Human-readable state label (if available)

    Notes:
        - furnitureId is instance-specific and used only to read state
        - furnitureDataId is type-specific and used for long-term tracking
        - State indices are 0-based (typically 0 = OFF, 1 = ON)
        - Display state names may require a 1-based index (state + 1)
        - Not all ESO API versions expose state display names
        - Fallback labeling ("State X") is used when display names are unavailable

    Example:
        /lo add TeamAlpha

        -- With a valid item selected, this will:
        -- 1. Capture its current ON/OFF state
        -- 2. Store the furnishing type (furnitureDataId)
        -- 3. Associate it with "TeamAlpha"
]]

function LightsOut.GetStateDisplayName(furnitureId, stateIndex)
    stateIndex = tonumber(stateIndex)

    if stateIndex == nil then
        return "Unknown"
    end

    if type(GetPlacedFurniturePreviewVariationDisplayName) == "function" then
        local displayIndex = stateIndex + 1
        local stateName = GetPlacedFurniturePreviewVariationDisplayName(furnitureId, displayIndex)

        if stateName and stateName ~= "" then
            return stateName
        end
    end

    return "State " .. tostring(stateIndex)
end

function LightsOut.GetWarTeamTable()
    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}
    return LightsOut.savedVars.warTeams
end

function LightsOut.GetActiveGameTeamTable()
    local mode = LightsOut.game and LightsOut.game.mode or nil

    if mode == "war" then
        return LightsOut.GetWarTeamTable()
    end

    if mode == "threshold" or mode == "target" then
        return LightsOut.savedVars and LightsOut.savedVars.items or {}
    end

    return {}
end

function LightsOut.AddSelectedFurniture(name)

    -- Normalize and trim the provided name
    name = tostring(name or ""):match("^%s*(.-)%s*$")

    -- Validate name input
    if name == "" then
        LightsOut.Print("Use: /lo add <name>")
        return
    end

    -- Ensure player is inside a house
    if not LightsOut.IsInHouse(true) then return end

    -- Manual /lo add requires editor permissions because it depends on the
    -- currently selected housing editor furnishing.
    if not HasAnyEditingPermissionsForCurrentHouse() then
        LightsOut.Print("You must have housing editor permissions to use this command.")
        return
    end

    -- Get the currently selected furnishing from the housing editor
    local furnitureId = HousingEditorGetSelectedFurnitureId()
    if not furnitureId then
        LightsOut.Print("Open the housing editor and select an item first.")
        return
    end

    -- Ensure the selected object is a 2-state interactable (e.g., ON/OFF)
    local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)
    if not numStates or numStates ~= 2 then
        LightsOut.Print("This command works only with interactable objects that have exactly two states.")
        return
    end

    -- Get the current state index of the selected furnishing
    -- NOTE: This is 0-based (typically 0 = OFF, 1 = ON)
    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
    if currentState == nil then
        LightsOut.Print("Could not read the selected item's current state.")
        return
    end

    -- Retrieve identifying information for the furnishing
    -- furnitureDataId is shared across all items of this type
    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    if not furnitureDataId then
        LightsOut.Print("Could not read the selected item's furnitureDataId.")
        return
    end

    -- Determine a readable state name
    -- ESO uses 0-based indexing for state, but display APIs are often 1-based
    local stateName = "Unknown"

    if type(GetPlacedFurniturePreviewVariationDisplayName) == "function" then
        -- Convert 0-based state to 1-based index for display lookup
        local displayIndex = currentState + 1

        -- Attempt to retrieve a readable state name from the API
        -- NOTE: Uses furnitureId (instance-level), not furnitureDataId (item-level)
        stateName = GetPlacedFurniturePreviewVariationDisplayName(furnitureId, displayIndex)
            or ("State " .. tostring(currentState))

        -- Debug output for verification
        LightsOut.Dbg("furnitureDataId: " .. tostring(furnitureDataId))
        LightsOut.Dbg("currentState: " .. tostring(currentState))
        LightsOut.Dbg("displayIndex: " .. tostring(displayIndex))
        LightsOut.Dbg("stateName: " .. tostring(stateName))
    else
        -- Fallback if API function is unavailable
        stateName = "State " .. tostring(currentState)
    end

    -- Ensure saved variables table exists
    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    name = LightsOut_SafeText(name, "Team")

    -- Normalize key for storage (case-insensitive and SavedVariables-safe)
    local newKey = LightsOut_SafeKey(name, "team")

    -- Enforce uniqueness:
    -- If another entry already uses this furnitureDataId, remove it
    for existingKey, entry in pairs(LightsOut.savedVars.items) do
        if existingKey ~= newKey and tonumber(entry.furnitureDataId) == tonumber(furnitureDataId) then
            LightsOut.savedVars.items[existingKey] = nil
            LightsOut.Print("Removed duplicate assignment from: " .. tostring(entry.name or existingKey))
        end
    end

    -- Scan the house for all placed furnishings with this same furnitureDataId
    local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)

    -- Save or overwrite the entry for this team/name
    LightsOut.savedVars.items[newKey] = {
        name = name,                         -- User-defined label
        itemName = itemName,                 -- ESO display name
        icon = icon,                         -- ESO furnishing icon for the control panel
        enabled = false,                     -- New teams are disabled in the control panel by default
        furnitureDataId = furnitureDataId,   -- Type identifier
        state = currentState,                -- Winning state value
        stateName = stateName,               -- Winning state display label
        matchingCount = matchingCount,       -- Number of matching placed items
        furnitureIds = matchingFurniture,    -- Sub-table of matching placed furnitureIds
    }

    -- Confirmation output to chat
    LightsOut.Print(zo_strformat(
        "Saved |c00FF00<<1>>|r as |c00FF00<<2>>|r - State |c00FF00<<3>>|r - Found |c00FF00<<4>>|r matching item(s)",
        tostring(name),
        tostring(itemName),
        tostring(stateName),
        tostring(matchingCount)
    ))

    LightsOut.RefreshControlPanelForTeamChange()
end





--[[
    LightsOut.AddSelectedWarTeam

    Creates or replaces a War team assignment.

    War team rules:
        - Multiple teams may use the same furnishing type
        - Each team using that furnishing type must have a different win state
        - The maximum number of teams for one furnishing type is the number of
          object states that furnishing supports
]]
function LightsOut.AddSelectedWarTeam(name)
    name = tostring(name or ""):match("^%s*(.-)%s*$")

    if name == "" then
        return
    end

    if not LightsOut.IsInHouse(true) then return end

    -- Manual /lo war add requires editor permissions because it depends on the
    -- currently selected housing editor furnishing.
    if not HasAnyEditingPermissionsForCurrentHouse() then
        LightsOut.Print("You must have housing editor permissions to use this command.")
        return
    end

    local furnitureId = HousingEditorGetSelectedFurnitureId()
    if not furnitureId then
        LightsOut.Print("Open the housing editor and select an item first.")
        return
    end

    local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)
    if not numStates or numStates < 2 then
        LightsOut.Print("War teams require an interactable object with at least two states.")
        return
    end

    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
    if currentState == nil then
        LightsOut.Print("Could not read the selected item's current state.")
        return
    end

    currentState = tonumber(currentState)

    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    if not furnitureDataId then
        LightsOut.Print("Could not read the selected item's furnitureDataId.")
        return
    end

    name = LightsOut_SafeText(name, "Team")

    local warTeams = LightsOut.GetWarTeamTable()
    local normalizedName = LightsOut_SafeKey(name, "team")
    local newKey = tostring(tonumber(furnitureDataId)) .. ":" .. normalizedName

    -- War mode can store multiple furnishing types. Team names only need to be
    -- unique within the same furnishing type, so different item groups can use
    -- the same team names.

    for existingKey, entry in pairs(warTeams) do
        if entry and tonumber(entry.furnitureDataId) == tonumber(furnitureDataId) and LightsOut_SafeKey(entry.name or existingKey, "team") == normalizedName then
            newKey = existingKey
            break
        end
    end

    local sameItemTeamCount = 0

    for existingKey, entry in pairs(warTeams) do
        if existingKey ~= newKey and tonumber(entry.furnitureDataId) == tonumber(furnitureDataId) then
            sameItemTeamCount = sameItemTeamCount + 1

            if tonumber(entry.state) == currentState then
                LightsOut.Print(zo_strformat(
                    "War team not saved. |c00FF00<<1>>|r already uses |cFFFF00<<2>>|r for this item.",
                    tostring(entry.name or existingKey),
                    tostring(entry.stateName or ("State " .. tostring(currentState)))
                ))
                return
            end
        end
    end

    local existingEntry = warTeams[newKey]
    local isReplacingSameItem = existingEntry and tonumber(existingEntry.furnitureDataId) == tonumber(furnitureDataId)

    if not isReplacingSameItem and sameItemTeamCount >= tonumber(numStates) then
        LightsOut.Print(zo_strformat(
            "War team not saved. This item has only |cFFFF00<<1>>|r state(s), so it can only support |cFFFF00<<1>>|r War team(s).",
            tostring(numStates)
        ))
        return
    end

    local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)
    local stateName = LightsOut.GetStateDisplayName(furnitureId, currentState)

    for _, entry in pairs(warTeams) do
        if entry and tonumber(entry.furnitureDataId) ~= tonumber(furnitureDataId) then
            LO_SetTeamEnabledForMode(entry, "war", false)
        end
    end

    warTeams[newKey] = {
        name = name,
        itemName = itemName,
        icon = icon,
        enabled = false,
        furnitureDataId = furnitureDataId,
        state = currentState,
        stateName = stateName,
        numStates = numStates,
        matchingCount = matchingCount,
        furnitureIds = matchingFurniture,
    }

    LightsOut.Print(zo_strformat(
        "Saved War team |c00FF00<<1>>|r as |c00FF00<<2>>|r - Win State |cFFFF00<<3>>|r - Found |c00FF00<<4>>|r matching item(s)",
        tostring(name),
        tostring(itemName),
        tostring(stateName),
        tostring(matchingCount)
    ))

    LightsOut.RefreshControlPanelForTeamChange()
end

function LightsOut.ListWarTeams()
    local warTeams = LightsOut.GetWarTeamTable()
    local count = 0

    for key, entry in pairs(warTeams) do
        count = count + 1
        LightsOut.Print(zo_strformat(
            "War Team: |c00FF00<<1>>|r - Item: |c00FF00<<2>>|r - Win State: |cFFFF00<<3>>|r (<<4>>) - Matching: |c00FF00<<5>>|r",
            tostring(entry.name or key),
            tostring(entry.itemName or "Unknown"),
            tostring(entry.stateName or "Unknown"),
            tostring(entry.state or "?"),
            tostring(entry.matchingCount or 0)
        ))
    end

    if count == 0 then
        LightsOut.Print("No War teams have been created.")
        return
    end

    LightsOut.Print("Listed " .. tostring(count) .. " War team(s).")
end

--legacy code, due to be removed.
function LightsOut.DeleteWarTeam(name)
    name = tostring(name or ""):match("^%s*(.-)%s*$")

    if name == "" then        return
    end

    local warTeams = LightsOut.GetWarTeamTable()
    local key = LightsOut_SafeKey(name, "team")
    local entry = warTeams[key]

    if not entry then
        LightsOut.Print("No War team found with name: " .. tostring(name))
        return
    end

    warTeams[key] = nil

    LightsOut.Print(zo_strformat(
        "Deleted War team |c00FF00<<1>>|r (Item: |c00FF00<<2>>|r)",
        tostring(entry.name or name),
        tostring(entry.itemName or "Unknown")
    ))

    LightsOut.RefreshControlPanelForTeamChange()
end

--legacy code, due to be removed.
function LightsOut.DeleteAllWarTeams()
    local warTeams = LightsOut.GetWarTeamTable()
    local count = 0

    for _ in pairs(warTeams) do
        count = count + 1
    end

    LightsOut.savedVars.warTeams = {}

    if count == 0 then
        LightsOut.Print("No War teams to delete.")
    else
        LightsOut.Print("Deleted " .. tostring(count) .. " War team(s).")
    end

    LightsOut.RefreshControlPanelForTeamChange()
end

--[[
    LightsOut.ListTeams

    Lists all saved team/item assignments.

    For each saved team, this prints:
        - Team name
        - Assigned furnishing name
        - Winning state name
        - Number of matching placed furnishings

    Returns:
        nil
]]
function LightsOut.ListTeams()

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local count = 0

    for key, entry in pairs(LightsOut.savedVars.items) do
        count = count + 1

        LightsOut.Print(zo_strformat(
            "Team: |c00FF00<<1>>|r - Item: |c00FF00<<2>>|r - State: |c00FF00<<3>>|r - Matching: |c00FF00<<4>>|r",
            tostring(entry.name or key),
            tostring(entry.itemName or "Unknown"),
            tostring(entry.stateName or "Unknown"),
            tostring(entry.matchingCount or 0)
        ))
    end

    if count == 0 then
        LightsOut.Print("No teams have been created.")
        return
    end

    LightsOut.Print("Listed " .. tostring(count) .. " team(s).")
end


--[[
    LightsOut.DeleteTeam

    Removes a saved team assignment by name.

    Parameters:
        name (string)
            The name of the team to delete

    Returns:
        nil

    Behavior:
        - Normalizes the provided name (trim + lowercase key)
        - Checks if the team exists
        - Deletes the team if found
        - Prints confirmation or error message

    Example:
        /lo delete TeamAlpha
]]
--legacy code, due to be removed.
function LightsOut.DeleteTeam(name)

    -- Normalize and trim input
    name = tostring(name or ""):match("^%s*(.-)%s*$")

    if name == "" then
        return
    end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local key = LightsOut_SafeKey(name, "team")
    local entry = LightsOut.savedVars.items[key]

    if not entry then
        LightsOut.Print("No team found with name: " .. tostring(name))
        return
    end

    -- Remove the team
    LightsOut.savedVars.items[key] = nil

    LightsOut.Print(zo_strformat(
        "Deleted team |c00FF00<<1>>|r (Item: |c00FF00<<2>>|r)",
        tostring(entry.name or name),
        tostring(entry.itemName or "Unknown")
    ))

    LightsOut.RefreshControlPanelForTeamChange()
end


--[[
    LightsOut.DeleteAllTeams

    Removes ALL saved team assignments.

    Returns:
        nil

    Behavior:
        - Clears the entire items table in SavedVariables
        - Prints how many teams were removed
        - Safe to call even if no teams exist

    Example:
]]
--legacy code, due to be removed.
function LightsOut.DeleteAllTeams()

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local count = 0
    for _ in pairs(LightsOut.savedVars.items) do
        count = count + 1
    end

    -- Clear all teams
    LightsOut.savedVars.items = {}

    if count == 0 then
        LightsOut.Print("No teams to delete.")
    else
        LightsOut.Print("Deleted " .. tostring(count) .. " team(s).")
    end

    LightsOut.RefreshControlPanelForTeamChange()
end




--[[
    LightsOut Combined Control Panel

    First-pass integration of the standalone control panel into the real addon.
    This replaces the old separate status window and old dropdown control panel
    with one movable/resizable panel that has setup and in-game status views.
]]
LightsOut.ui = LightsOut.ui or {}

LightsOut.CONTROL_TIME_OPTIONS = {
    { label = "None", value = nil },
    { label = "1 minute", value = 1 },
    { label = "2 minutes", value = 2 },
    { label = "3 minutes", value = 3 },
    { label = "5 minutes", value = 5 },
    { label = "10 minutes", value = 10 },
    { label = "15 minutes", value = 15 },
    { label = "30 minutes", value = 30 },
    { label = "60 minutes", value = 60 },
}

local LO_MODE_OPTIONS = {
    { key = "threshold", label = "Threshold" },
    { key = "target", label = "Target" },
    { key = "war", label = "War" },
}

local function LO_Saved()
    local houseVars = LightsOut.SetActiveHouseSavedVars()

    -- When zoning out of a house, SetActiveHouseSavedVars() intentionally returns nil.
    -- The mini panel can still exist for a moment during EVENT_PLAYER_ACTIVATED, so
    -- provide a safe temporary table instead of indexing nil. The real per-house
    -- saved vars are restored as soon as the player is back inside a house.
    if not houseVars then
        return {
            items = {},
            warTeams = {},
            controlPanel = LightsOut_DefaultControlPanelSettings(),
        }
    end

    houseVars.items = houseVars.items or {}
    houseVars.warTeams = houseVars.warTeams or {}
    houseVars.controlPanel = houseVars.controlPanel or LightsOut_DefaultControlPanelSettings()
    return houseVars
end
local function LO_CP()
    return LO_Saved().controlPanel
end

local LO_GetControlPanelMaxCount

local function LO_NormalizeModeKey(mode)
    mode = string.lower(tostring(mode or "threshold"))
    if mode ~= "target" and mode ~= "war" then
        mode = "threshold"
    end
    return mode
end

local function LO_IsAllRequiredCount(value)
    return value == nil or tostring(value) == "all"
end

local function LO_TargetPlacementCount(skipRescan)
    local placements = LO_GetControlPanelMaxCount and LO_GetControlPanelMaxCount("target", skipRescan) or 0
    placements = tonumber(placements or 0) or 0
    return math.max(0, placements)
end

local function LO_TargetRequiredMax(skipRescan)
    return math.max(1, LO_TargetPlacementCount(skipRescan) - 1)
end

local function LO_DefaultTargetRequiredCount(skipRescan)
    local placements = LO_TargetPlacementCount(skipRescan)
    local targetMax = LO_TargetRequiredMax(skipRescan)

    if placements <= 1 then
        return 1
    end

    return math.max(1, math.min(targetMax, math.floor(placements / 2)))
end

local function LO_NormalizeRequiredCountValue(value)
    if LO_IsAllRequiredCount(value) then
        return "all"
    end

    return math.max(1, tonumber(value or 1) or 1)
end

local function LO_GetModeConfig(mode, cpOverride)
    local cp = cpOverride or LO_CP()
    mode = LO_NormalizeModeKey(mode or cp.selectedMode)
    cp.modeSettings = cp.modeSettings or {}
    cp.modeSettings[mode] = cp.modeSettings[mode] or {}

    local settings = cp.modeSettings[mode]
    settings.requiredCount = LO_NormalizeRequiredCountValue(settings.requiredCount)

    if mode == "target" and LO_IsAllRequiredCount(settings.requiredCount) then
        settings.requiredCount = LO_DefaultTargetRequiredCount(true)
    end

    -- nil timeLimitMinutes is meaningful: no time limit.
    if settings.timeLimitMinutes ~= nil then
        settings.timeLimitMinutes = tonumber(settings.timeLimitMinutes)
    end

    return settings
end

local function LO_SaveSelectedModeConfig(cpOverride)
    -- Do not call LO_CP() after the caller has just changed cp.requiredCount or
    -- cp.timeLimitMinutes; LO_CP() reloads the selected mode from saved modeSettings
    -- and would overwrite the pending UI edit before it could be saved.
    local cp = cpOverride or (LightsOut.savedVars and LightsOut.savedVars.controlPanel) or LO_CP()
    local mode = LO_NormalizeModeKey(cp.selectedMode)
    local settings = LO_GetModeConfig(mode, cp)
    settings.requiredCount = LO_NormalizeRequiredCountValue(cp.requiredCount)
    settings.timeLimitMinutes = cp.timeLimitMinutes
    settings.confirmCounted = cp.confirmCounted == true
end

local function LO_LoadModeConfig(mode, cpOverride)
    local cp = cpOverride or LO_CP()
    mode = LO_NormalizeModeKey(mode or cp.selectedMode)
    local settings = LO_GetModeConfig(mode, cp)
    cp.selectedMode = mode
    cp.requiredCount = LO_NormalizeRequiredCountValue(settings.requiredCount)
    cp.timeLimitMinutes = settings.timeLimitMinutes
    cp.confirmCounted = settings.confirmCounted == true
    return settings
end

local function LO_RequiredCountLabel(mode, requiredCount, skipRescan)
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))

    if mode == "war" then
        return "All"
    end

    if mode == "target" then
        local value = tonumber(requiredCount)

        if value == nil then
            value = LO_DefaultTargetRequiredCount(skipRescan)
        end

        local targetMax = LO_TargetRequiredMax(skipRescan)
        value = math.max(1, math.min(targetMax, value))

        return tostring(value)
    end

    if LO_IsAllRequiredCount(requiredCount) then
        return "All"
    end

    return tostring(tonumber(requiredCount or 1) or 1)
end

local function LO_ResolveRequiredCount(mode, requiredCount, skipRescan)
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))

    if mode == "war" or LO_IsAllRequiredCount(requiredCount) then
        local limit = LO_GetControlPanelMaxCount and LO_GetControlPanelMaxCount(mode, skipRescan)
        limit = tonumber(limit or 0) or 0
        if limit >= 1 then return limit end
        return 1
    end

    if mode == "target" then
        local targetMax = LO_TargetRequiredMax(skipRescan)
        local value = tonumber(requiredCount)

        if value == nil then
            value = LO_DefaultTargetRequiredCount(skipRescan)
        end

        return math.max(1, math.min(targetMax, value))
    end

    return math.max(1, tonumber(requiredCount or 1) or 1)
end

local function LO_TeamModeDefaultEnabled(team, mode)
    -- Preserve legacy behavior for existing saves: if a team had only the old
    -- top-level enabled flag, use that value as the starting value for each
    -- mode until that mode is changed independently.
    if team and team.enabled ~= nil then
        return team.enabled ~= false
    end
    return true
end

local function LO_IsTeamEnabledForMode(team, mode)
    if not team then return false end
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))
    team.enabledByMode = team.enabledByMode or {}
    if team.enabledByMode[mode] == nil then
        team.enabledByMode[mode] = LO_TeamModeDefaultEnabled(team, mode)
    end
    return team.enabledByMode[mode] ~= false
end

local function LO_SetTeamEnabledForMode(team, mode, value)
    if not team then return end
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))
    team.enabledByMode = team.enabledByMode or {}
    team.enabledByMode[mode] = value == true

    -- Keep the legacy field synced for the currently selected mode and for War,
    -- because older game-state code still reads entry.enabled in a few places.
    local cp = LO_CP()
    if LO_NormalizeModeKey(cp.selectedMode) == mode then
        team.enabled = value == true
    end
end

local function LO_GetDefaultStandardTeamName(team)
    if not team then return "Team" end

    local stateIndex = tonumber(team.state)
    local defaultFallback = stateIndex ~= nil and ("State " .. tostring(stateIndex)) or "Team"
    local defaultStateName = LightsOut_SafeText(team.stateName, defaultFallback)

    if defaultStateName == "" then
        defaultStateName = defaultFallback
    end

    local itemName = LightsOut_SafeText(team.itemName, "")
    if itemName ~= "" then
        return defaultStateName .. " - " .. itemName
    end

    return defaultStateName
end

local function LO_GetTeamNameForMode(team, mode, isWar)
    if not team then return "" end
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))

    if isWar or mode == "war" then
        return tostring(team.name or team.stateName or "Team")
    end

    team.namesByMode = team.namesByMode or {}

    if team.namesByMode[mode] == nil or tostring(team.namesByMode[mode]) == "" then
        -- If this save predates per-mode names, keep the existing current name
        -- for the first mode that touches it. Other modes get Populate-style
        -- defaults until explicitly renamed.
        if team.name and tostring(team.name) ~= "" and not team.perModeNamesInitialized then
            team.namesByMode[mode] = tostring(team.name)
            team.perModeNamesInitialized = true
        else
            team.namesByMode[mode] = LO_GetDefaultStandardTeamName(team)
        end
    end

    return tostring(team.namesByMode[mode] or LO_GetDefaultStandardTeamName(team))
end

local function LO_ApplyTeamNameForMode(team, mode, isWar)
    if not team then return end
    team.name = LO_GetTeamNameForMode(team, mode, isWar)
end

local function LO_ApplyModeEnabledState(mode)
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))
    local saved = LO_Saved()
    local isWar = mode == "war"
    local source = isWar and saved.warTeams or saved.items

    for _, entry in pairs(source or {}) do
        LO_ApplyTeamNameForMode(entry, mode, isWar)
        entry.enabled = LO_IsTeamEnabledForMode(entry, mode)
    end
end

local function LO_SetSelectedMode(mode)
    local cp = (LightsOut.savedVars and LightsOut.savedVars.controlPanel) or LO_CP()
    LO_SaveSelectedModeConfig(cp)
    LO_LoadModeConfig(mode, cp)
    LO_ApplyModeEnabledState(mode)
end

local LO_uniqueControlId = 0
local function LO_UniqueControlName(prefix)
    prefix = tostring(prefix or "LightsOutControl")

    -- CreateControlFromVirtual requires a global name. The control panel can be
    -- rebuilt several times in the same UI session, and random names can repeat
    -- often enough to throw "Duplicate name" errors. Use a monotonic counter
    -- and verify the generated global does not already exist.
    repeat
        LO_uniqueControlId = LO_uniqueControlId + 1
        local name = prefix .. tostring(LO_uniqueControlId)
        if not _G[name] then
            return name
        end
    until false
end

local function LO_Label(parent, text, font, r, g, b, a)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    c:SetFont(font or "ZoFontGame")
    c:SetColor(r or 1, g or 1, b or 1, a or 1)
    c:SetText(text or "")
    return c
end

local function LO_SingleLine(label, width, height)
    if not label then return label end
    label:SetDimensions(width or 100, height or 22)
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    return label
end

local function LO_Tooltip(control, text)
    if not control or not text or text == "" then return control end
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
        SetTooltipText(InformationTooltip, tostring(text))
    end)
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    return control
end

local function LO_Backdrop(parent, alpha)
    local bg = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    if bg.SetMouseEnabled then bg:SetMouseEnabled(false) end
    bg:SetAnchorFill(parent)
    bg:SetCenterColor(0.02, 0.02, 0.025, alpha or 0.86)
    bg:SetEdgeColor(0.45, 0.38, 0.25, 0.90)
    bg:SetEdgeTexture(nil, 1, 1, 2)
    return bg
end

local function LO_Panel(parent, x, y, w, h)
    local p = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    if p.SetMouseEnabled then p:SetMouseEnabled(false) end
    p:SetDimensions(w, h)
    p:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    LO_Backdrop(p, 0.62)
    return p
end


local function LO_AddHeaderBox(control)
    if not control or control._lightsOutHeaderBox then return end

    local bg = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    bg:SetAnchorFill(control)
    bg:SetCenterColor(0.02, 0.02, 0.025, 0.35)
    bg:SetEdgeColor(0.60, 0.48, 0.18, 0.95)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    bg:SetEdgeInsets(1, 1, -1, -1)

    if bg.SetDrawLayer and DL_BACKGROUND then bg:SetDrawLayer(DL_BACKGROUND) end
    if bg.SetDrawTier and DT_LOW then bg:SetDrawTier(DT_LOW) end
    if bg.SetDrawLevel then bg:SetDrawLevel(0) end

    control._lightsOutHeaderBox = bg
end


local function LO_Button(parent, text, w, h, tone)
    local b = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    if b.SetMouseEnabled then b:SetMouseEnabled(true) end
    b:SetDimensions(w or 160, h or 36)
    b:SetFont("ZoFontGameBold")
    b:SetText(text or "")
    if b.SetHorizontalAlignment and TEXT_ALIGN_CENTER then b:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if b.SetVerticalAlignment and TEXT_ALIGN_CENTER then b:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    b:SetNormalFontColor(1, 1, 1, 1)
    b:SetMouseOverFontColor(0.9, 0.95, 1, 1)
    b:SetPressedFontColor(0.75, 0.85, 1, 1)
    local bg = WINDOW_MANAGER:CreateControl(nil, b, CT_BACKDROP)
    bg:SetAnchorFill(b)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    local colors = {
        blue = {0.05, 0.13, 0.22, 0.95, 0.15, 0.38, 0.70, 1},
        green = {0.08, 0.22, 0.04, 0.95, 0.25, 0.75, 0.18, 1},
        red = {0.26, 0.05, 0.05, 0.95, 0.80, 0.15, 0.15, 1},
        yellow = {0.28, 0.22, 0.03, 0.95, 0.95, 0.78, 0.15, 1},
        orange = {0.30, 0.13, 0.02, 0.95, 0.95, 0.45, 0.12, 1},
        gray = {0.12, 0.12, 0.13, 0.95, 0.35, 0.35, 0.38, 1},
    }
    local c = colors[tone or "blue"] or colors.blue
    local function apply(mult)
        bg:SetCenterColor(c[1] * mult, c[2] * mult, c[3] * mult, c[4])
        bg:SetEdgeColor(c[5], c[6], c[7], c[8])
    end
    function b:SetLightsOutTone(newTone)
        c = colors[newTone or "blue"] or colors.blue
        apply(1)
    end
    apply(1)
    b:SetHandler("OnMouseEnter", function() apply(1.25) end)
    b:SetHandler("OnMouseExit", function() apply(1) end)
    b:SetHandler("OnMouseDown", function() apply(0.72) end)
    b:SetHandler("OnMouseUp", function() apply(1.25) end)
    return b
end


-- Lightweight progress overlay used during game initialization and throttled furnishing state changes.
local function LightsOut_SetProgressWindowOnTop(window)
    if not window then return end

    -- Keep progress/notification windows above the main control panel.  The
    -- control panel can be large and opaque, so progress overlays must use a
    -- higher draw layer/tier/level whenever they are shown or refreshed.
    if window.SetDrawLayer and DL_OVERLAY then window:SetDrawLayer(DL_OVERLAY) end
    if window.SetDrawTier and DT_HIGH then window:SetDrawTier(DT_HIGH) end
    if window.SetDrawLevel then window:SetDrawLevel(20000) end
    if window.BringWindowToTop then window:BringWindowToTop() end
end

function LightsOut.EnsureProgressWindow()
    LightsOut.ui = LightsOut.ui or {}

    if LightsOut.ui.progressWindow then
        LightsOut_SetProgressWindowOnTop(LightsOut.ui.progressWindow)
        return LightsOut.ui.progressWindow
    end

    local wm = WINDOW_MANAGER
    if not wm then return nil end

    local window = wm:CreateTopLevelWindow("LightsOutProgressWindow")
    window:SetDimensions(500, 162)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    window:SetHidden(true)
    window:SetMouseEnabled(false)

    LightsOut_SetProgressWindowOnTop(window)

    local bg = wm:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.02, 0.02, 0.025, 0.94)
    bg:SetEdgeColor(0.45, 0.38, 0.25, 0.95)
    bg:SetEdgeTexture(nil, 1, 1, 2)

    local title = LO_Label(window, "LightsOut is working...", "ZoFontGameLargeBold", 1, 1, 1, 1)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 16)
    title:SetDimensions(456, 28)

    local detail = LO_Label(window, "Preparing...", "ZoFontGame", 0.82, 0.88, 0.96, 1)
    detail:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    detail:SetDimensions(456, 48)
    if detail.SetMaxLineCount then detail:SetMaxLineCount(2) end
    if detail.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then detail:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end

    local track = wm:CreateControl(nil, window, CT_BACKDROP)
    track:SetAnchor(TOPLEFT, detail, BOTTOMLEFT, 0, 10)
    track:SetDimensions(456, 18)
    track:SetCenterColor(0.08, 0.08, 0.09, 0.96)
    track:SetEdgeColor(0.28, 0.28, 0.32, 1)
    track:SetEdgeTexture(nil, 1, 1, 1)

    local fill = wm:CreateControl(nil, track, CT_BACKDROP)
    fill:SetAnchor(LEFT, track, LEFT, 0, 0)
    fill:SetDimensions(1, 18)
    fill:SetCenterColor(0.14, 0.58, 0.10, 0.96)
    fill:SetEdgeColor(0.42, 0.95, 0.26, 1)
    fill:SetEdgeTexture(nil, 1, 1, 1)

    local percent = LO_Label(window, "0%", "ZoFontGameBold", 1, 1, 1, 1)
    percent:SetAnchor(TOPRIGHT, track, BOTTOMRIGHT, 0, 8)
    percent:SetDimensions(90, 22)
    if percent.SetHorizontalAlignment and TEXT_ALIGN_RIGHT then percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end

    window.titleLabel = title
    window.detailLabel = detail
    window.progressTrack = track
    window.progressFill = fill
    window.percentLabel = percent
    window.progressMaxWidth = 456

    LightsOut.ui.progressWindow = window
    return window
end

function LightsOut.ShowProgressWindow(title, detail, completed, total)
    LightsOut.progressHideToken = (LightsOut.progressHideToken or 0) + 1

    local window = LightsOut.EnsureProgressWindow()
    if not window then return end

    LightsOut_SetProgressWindowOnTop(window)
    window:SetHidden(false)
    LightsOut.UpdateProgressWindow(title, detail, completed, total)
end

function LightsOut.UpdateProgressWindow(title, detail, completed, total)
    local window = LightsOut.EnsureProgressWindow()
    if not window then return end
    LightsOut_SetProgressWindowOnTop(window)

    if title and window.titleLabel then
        window.titleLabel:SetText(tostring(title))
    end

    if detail and window.detailLabel then
        window.detailLabel:SetText(tostring(detail))
    end

    completed = tonumber(completed or 0) or 0
    total = tonumber(total or 0) or 0

    local percentValue = 0
    if total > 0 then
        percentValue = math.floor((math.max(0, math.min(completed, total)) / total) * 100)
    end

    local fillWidth = math.max(1, math.floor((window.progressMaxWidth or 416) * (percentValue / 100)))
    if window.progressFill then
        window.progressFill:SetDimensions(fillWidth, 18)
    end

    if window.percentLabel then
        window.percentLabel:SetText(tostring(percentValue) .. "%")
    end
end

function LightsOut.HideProgressWindow()
    LightsOut.progressHideToken = (LightsOut.progressHideToken or 0) + 1

    if LightsOut.ui and LightsOut.ui.progressWindow then
        LightsOut.ui.progressWindow:SetHidden(true)
    end
end

function LightsOut.HideProgressWindowSoon(delayMs)
    local token = (LightsOut.progressHideToken or 0) + 1
    LightsOut.progressHideToken = token

    local function hideIfStillCurrent()
        if LightsOut.progressHideToken == token and LightsOut.ui and LightsOut.ui.progressWindow then
            LightsOut.ui.progressWindow:SetHidden(true)
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(hideIfStillCurrent, tonumber(delayMs or 700) or 700)
    else
        hideIfStillCurrent()
    end
end

local function LightsOut_DeferProgressOperation(title, detail, callback)
    LightsOut.ShowProgressWindow(title or "LightsOut is initializing...", detail or "Preparing game data...", 0, 1)

    local function runCallback()
        local ok, err = pcall(callback)

        if not ok then
            LightsOut.Print("LightsOut error while preparing: " .. tostring(err))
        end

        if not LightsOut.IsStateChangeQueueRunning() then
            LightsOut.HideProgressWindowSoon(ok and 650 or 1800)
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(runCallback, 50)
    else
        runCallback()
    end
end

local function LO_Toggle(parent, value, callback)
    local t = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    t:SetDimensions(58, 26)
    t:SetMouseEnabled(true)
    t.value = value ~= false
    local track = WINDOW_MANAGER:CreateControl(nil, t, CT_BACKDROP)
    track:SetAnchorFill(t)
    track:SetEdgeTexture(nil, 1, 1, 1)
    local thumb = WINDOW_MANAGER:CreateControl(nil, t, CT_BACKDROP)
    thumb:SetDimensions(20, 20)
    thumb:SetCenterColor(0.94, 0.94, 0.94, 1)
    thumb:SetEdgeColor(1, 1, 1, 1)
    thumb:SetEdgeTexture(nil, 1, 1, 1)
    local function refresh()
        thumb:ClearAnchors()
        if t.value then
            if t.partial then
                track:SetCenterColor(0.58, 0.42, 0.04, 0.95)
                track:SetEdgeColor(1.00, 0.82, 0.18, 1)
            else
                track:SetCenterColor(0.14, 0.58, 0.10, 0.95)
                track:SetEdgeColor(0.42, 0.95, 0.26, 1)
            end
            thumb:SetAnchor(RIGHT, t, RIGHT, -4, 0)
        else
            track:SetCenterColor(0.13, 0.13, 0.15, 0.95)
            track:SetEdgeColor(0.40, 0.40, 0.44, 1)
            thumb:SetAnchor(LEFT, t, LEFT, 4, 0)
        end
    end
    function t:SetLightsOutPartial(isPartial)
        self.partial = isPartial == true
        refresh()
    end
    function t:RefreshLightsOutToggle()
        refresh()
    end
    t:SetHandler("OnMouseUp", function()
        t.value = not t.value
        t.partial = false
        refresh()
        if callback then callback(t.value) end
    end)
    refresh()
    return t
end

local function LO_ModeLabel(mode)
    if mode == "target" then return "Target" end
    if mode == "war" then return "War" end
    return "Threshold"
end

local function LO_TimeLabel(minutes)
    if not minutes or tonumber(minutes) == 0 then return "None" end
    if tonumber(minutes) == 1 then return "1 minute" end
    return tostring(minutes) .. " minutes"
end

local function LO_TableToList(source, mode)
    local result = {}
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))
    for key, entry in pairs(source or {}) do
        entry.key = entry.key or key
        entry.enabled = LO_IsTeamEnabledForMode(entry, mode)
        table.insert(result, entry)
    end
    return result
end

local function LO_TeamsForMode(mode)
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))

    if mode == "war" then
        local teams = LO_TableToList(LO_Saved().warTeams, mode)
        local filtered = {}

        -- War mode needs at least 3 placements for an item group to be eligible.
        for _, team in ipairs(teams or {}) do
            if (tonumber(team.matchingCount or 0) or 0) >= 3 then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    local teams = LO_TableToList(LO_Saved().items, mode)

    -- Target mode requires multiple placements. Items with only one placement
    -- are not eligible and should not be shown or selectable in Target setup.
    if mode == "target" then
        local filtered = {}

        for _, team in ipairs(teams or {}) do
            if (tonumber(team.matchingCount or 0) or 0) > 1 then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    return teams
end

local function LO_AllTeamsForMode(mode)
    mode = LO_NormalizeModeKey(mode or (LO_CP().selectedMode))

    if mode == "war" then
        return LO_TableToList(LO_Saved().warTeams, mode)
    end

    return LO_TableToList(LO_Saved().items, mode)
end

local function LO_CountEnabled(teams)
    local count = 0
    for _, team in ipairs(teams or {}) do
        if team.enabled ~= false then count = count + 1 end
    end
    return count
end

local function LO_SortedTeams(teams, isWar)
    local sorted = {}
    local nonWarGroupSizes = {}

    for _, team in ipairs(teams or {}) do
        table.insert(sorted, team)

        if not isWar then
            local placedCount = tonumber(team.matchingCount or 0) or 0
            nonWarGroupSizes[placedCount] = (nonWarGroupSizes[placedCount] or 0) + 1
        end
    end

    table.sort(sorted, function(a, b)
        if isWar then
            local supportedA = tonumber(a.numStates or 0) or 0
            local supportedB = tonumber(b.numStates or 0) or 0

            -- Primary sort: number of supported statuses/teams ascending.
            if supportedA ~= supportedB then
                return supportedA < supportedB
            end

            local placedA = tonumber(a.matchingCount or 0) or 0
            local placedB = tonumber(b.matchingCount or 0) or 0

            -- Secondary sort: number of furnishings placed ascending.
            if placedA ~= placedB then
                return placedA < placedB
            end

            local itemA = tostring(a.itemName or "")
            local itemB = tostring(b.itemName or "")

            -- Tertiary sort: item name.
            if itemA ~= itemB then return itemA < itemB end

            return tostring(a.stateName or a.name or a.key or "") < tostring(b.stateName or b.name or b.key or "")
        end

        local placedA = tonumber(a.matchingCount or 0) or 0
        local placedB = tonumber(b.matchingCount or 0) or 0

        local supportedA = tonumber(nonWarGroupSizes[placedA] or 0) or 0
        local supportedB = tonumber(nonWarGroupSizes[placedB] or 0) or 0

        -- Primary sort: groups with fewer supported teams first.
        if supportedA ~= supportedB then
            return supportedA < supportedB
        end

        -- Secondary sort: within the same supported-team count, fewer furnishings placed first.
        if placedA ~= placedB then
            return placedA < placedB
        end

        return tostring(a.name or a.key or "") < tostring(b.name or b.key or "")
    end)

    return sorted
end

local function LO_GetSetupTeamScrollValue()
    local scroll = LightsOut.ui and LightsOut.ui.teamSetupScroll
    if not scroll then return 0 end
    if scroll.GetVerticalScroll then return scroll:GetVerticalScroll() or 0 end
    if scroll.GetScrollValue then return scroll:GetScrollValue() or 0 end
    if scroll.scroll and scroll.scroll.GetVerticalScroll then return scroll.scroll:GetVerticalScroll() or 0 end
    return 0
end

local function LO_RestoreSetupTeamScrollValue(value)
    if value == nil then return end
    local function apply()
        local scroll = LightsOut.ui and LightsOut.ui.teamSetupScroll
        if not scroll then return end
        if scroll.SetVerticalScroll then scroll:SetVerticalScroll(value) return end
        if scroll.SetScrollValue then scroll:SetScrollValue(value) return end
        if scroll.scroll and scroll.scroll.SetVerticalScroll then scroll.scroll:SetVerticalScroll(value) return end
        if type(ZO_Scroll_SetScrollPosition) == "function" then ZO_Scroll_SetScrollPosition(scroll, value) end
    end
    if type(zo_callLater) == "function" then zo_callLater(apply, 1) else apply() end
end

function LightsOut.PopulateControlCountDropdown()
    -- Compatibility no-op. The new panel uses arrow selectors instead of combo boxes.
end

function LightsOut.RefreshControlPanelForTeamChange(options)
    if LightsOut.ui and LightsOut.ui.controlWindow then
        LightsOut.PopulateControlCountDropdown()
        LightsOut.RebuildControlPanel(options)
    end
end

local function LO_SetControlPanelMousePassthrough(control)
    -- Keep the window/backdrop/panel surfaces from consuming mouse clicks,
    -- but do not recurse into child controls. Buttons, toggles, scrollbars,
    -- and other interactive controls keep their own mouse handlers.
    if not control then return end

    if control.SetMouseEnabled then
        control:SetMouseEnabled(false)
    end
end

function LightsOut.RefreshTeamMatchingCounts()
    if not LightsOut.savedVars then return end
    LightsOut.savedVars.items = LightsOut.savedVars.items or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}
    if not LightsOut.IsInHouse(false) then return end
    for _, entry in pairs(LightsOut.savedVars.items) do
        if entry.furnitureDataId then
            local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(entry.furnitureDataId)
            entry.furnitureIds = matchingFurniture
            entry.matchingCount = matchingCount
        end
    end
    for _, entry in pairs(LightsOut.savedVars.warTeams) do
        if entry.furnitureDataId then
            local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(entry.furnitureDataId)
            entry.furnitureIds = matchingFurniture
            entry.matchingCount = matchingCount
        end
    end
end


local function LightsOut_TryGetFurnitureDataIdFromArgs(...)
    for index = 1, select("#", ...) do
        local candidate = select(index, ...)
        if LightsOut_IsValidFurnitureId(candidate) then
            local ok, _itemName, _icon, furnitureDataId = pcall(GetPlacedHousingFurnitureInfo, candidate)
            if ok and LightsOut_IsValidFurnitureDataId(furnitureDataId) then
                return tonumber(furnitureDataId), candidate
            end
        end
    end

    return nil, nil
end

local function LightsOut_UpdateTeamsForFurnitureDataId(furnitureDataId, disableEnabled)
    furnitureDataId = tonumber(furnitureDataId)
    if not furnitureDataId then return false end

    LightsOut.SetActiveHouseSavedVars()
    LightsOut.savedVars.items = LightsOut.savedVars.items or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}

    local changed = false
    local matchingFurniture = nil
    local matchingCount = nil

    local function refreshEntry(entry)
        if not entry or tonumber(entry.furnitureDataId) ~= furnitureDataId then
            return
        end

        if matchingFurniture == nil then
            matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)
        end

        entry.furnitureIds = matchingFurniture
        entry.matchingCount = matchingCount

        if disableEnabled then
            entry.enabled = false
            entry.enabledByMode = entry.enabledByMode or {}
            entry.enabledByMode.threshold = false
            entry.enabledByMode.target = false
            entry.enabledByMode.war = false
        end

        changed = true
    end

    for _, entry in pairs(LightsOut.savedVars.items) do
        refreshEntry(entry)
    end

    for _, entry in pairs(LightsOut.savedVars.warTeams) do
        refreshEntry(entry)
    end

    if changed then
        if type(LO_ClampRequiredCount) == "function" then
            LO_ClampRequiredCount(true)
        end

        if type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
            LightsOut.RefreshControlPanelForTeamChange()
        elseif LightsOut.ui and LightsOut.ui.controlWindow and type(LightsOut.RebuildControlPanel) == "function" then
            LightsOut.RebuildControlPanel()
        end
    end

    return changed
end

function LightsOut.HandleHousingFurnitureAdded(eventCode, ...)
    if LightsOut.game and LightsOut.game.active then
        return
    end

    if not LightsOut.IsInHouse(false) then
        return
    end

    local furnitureDataId = LightsOut_TryGetFurnitureDataIdFromArgs(...)
    if not furnitureDataId then
        return
    end

    LightsOut_UpdateTeamsForFurnitureDataId(furnitureDataId, true)
end

local function LightsOut_GetPlacedFurnitureLookup()
    local placed = {}
    local previousFurnitureId = nil

    while true do
        local furnitureId = GetNextPlacedHousingFurnitureId(previousFurnitureId)

        if not furnitureId or furnitureId == 0 then
            break
        end

        placed[tostring(furnitureId)] = true
        previousFurnitureId = furnitureId
    end

    return placed
end

local function LightsOut_FindMissingActiveGameFurniture()
    if not (LightsOut.game and LightsOut.game.active) then
        return nil
    end

    if not LightsOut.IsInHouse(false) then
        return nil
    end

    local placedFurnitureLookup = LightsOut_GetPlacedFurnitureLookup()
    local activeTeams = LightsOut.GetActiveGameTeamTable()

    for _, activeEntry in ipairs(LightsOut.GetActiveGameEntries(activeTeams or {})) do
        local key, entry = activeEntry.key, activeEntry.entry
        if entry and entry.trackedFurnitureIds then
            for _, furnitureInfo in ipairs(entry.trackedFurnitureIds or {}) do
                local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                if furnitureId and not placedFurnitureLookup[tostring(furnitureId)] then
                    return {
                        teamKey = key,
                        teamName = entry.name or key,
                        itemName = entry.itemName or "Unknown Item",
                        furnitureId = furnitureId,
                    }
                end
            end
        end
    end

    return nil
end

function LightsOut.CancelActiveGameIfTrackedFurnitureWasRemoved()
    local missing = LightsOut_FindMissingActiveGameFurniture()

    if not missing then
        return false
    end

    local itemName = tostring(missing.itemName or "Unknown Item")
    local teamName = tostring(missing.teamName or "Unknown Team")

    LightsOut.StopThresholdGame(true)
    LightsOut.HideGameStatusWindow()

    LightsOut.Print(zo_strformat(
        "Game cancelled because a tracked game item was removed from the house. Team: |c00FF00<<1>>|r - Item: |cFFFF00<<2>>|r",
        teamName,
        itemName
    ))

    return true
end


function LightsOut.RefreshAssignedTeamsAfterFurnitureRemoved(eventCode, ...)
    if LightsOut.game and LightsOut.game.active then
        local function checkRemovedActiveFurniture()
            LightsOut.CancelActiveGameIfTrackedFurnitureWasRemoved()
        end

        if type(zo_callLater) == "function" then
            zo_callLater(checkRemovedActiveFurniture, 50)
        else
            checkRemovedActiveFurniture()
        end

        return
    end

    if not LightsOut.IsInHouse(false) then
        return
    end

    LightsOut.SetActiveHouseSavedVars()
    LightsOut.savedVars.items = LightsOut.savedVars.items or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}

    local refreshedByFurnitureDataId = {}
    local changed = false
    local removedCount = 0

    local function removeEntryFromSource(source, entry)
        if not source or not entry then
            return false
        end

        for key, existingEntry in pairs(source) do
            if existingEntry == entry then
                source[key] = nil
                removedCount = removedCount + 1
                return true
            end
        end

        return false
    end

    local function removeEntryWhenNoInstancesRemain(entry)
        if removeEntryFromSource(LightsOut.savedVars.items, entry) then
            return true
        end

        -- War group headers are built from the remaining War team entries.
        -- Removing the last team for a furnitureDataId automatically removes
        -- that empty group header the next time the control panel is rebuilt.
        return removeEntryFromSource(LightsOut.savedVars.warTeams, entry)
    end

    local function refreshEntryIfCountShrank(entry)
        if not entry or not LightsOut_IsValidFurnitureDataId(entry.furnitureDataId) then
            return
        end

        local furnitureDataId = tonumber(entry.furnitureDataId)
        local dataKey = tostring(furnitureDataId)
        local oldCount = tonumber(entry.matchingCount or 0) or 0

        if refreshedByFurnitureDataId[dataKey] == nil then
            local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)
            refreshedByFurnitureDataId[dataKey] = {
                furnitureIds = matchingFurniture,
                matchingCount = tonumber(matchingCount or 0) or 0,
            }
        end

        local refreshed = refreshedByFurnitureDataId[dataKey]
        local newCount = tonumber(refreshed.matchingCount or 0) or 0

        if newCount < oldCount then
            if newCount <= 0 then
                removeEntryWhenNoInstancesRemain(entry)
            else
                entry.furnitureIds = refreshed.furnitureIds
                entry.matchingCount = newCount

                entry.enabled = false
                entry.enabledByMode = entry.enabledByMode or {}
                entry.enabledByMode.threshold = false
                entry.enabledByMode.target = false
                entry.enabledByMode.war = false
            end

            changed = true
        end
    end

    -- Copy entries before modifying the source tables so deleting teams during
    -- iteration cannot skip entries in the same table.
    local standardEntries = {}
    for _, entry in pairs(LightsOut.savedVars.items) do
        table.insert(standardEntries, entry)
    end

    local warEntries = {}
    for _, entry in pairs(LightsOut.savedVars.warTeams) do
        table.insert(warEntries, entry)
    end

    for _, entry in ipairs(standardEntries) do
        refreshEntryIfCountShrank(entry)
    end

    for _, entry in ipairs(warEntries) do
        refreshEntryIfCountShrank(entry)
    end

    if changed then
        if removedCount > 0 then
            LightsOut.Print("Removed " .. tostring(removedCount) .. " team(s) because no matching item placement(s) remain.")
        end

        if type(LO_ClampRequiredCount) == "function" then
            LO_ClampRequiredCount(true)
        end

        if type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
            LightsOut.RefreshControlPanelForTeamChange()
        elseif LightsOut.ui and LightsOut.ui.controlWindow and type(LightsOut.RebuildControlPanel) == "function" then
            LightsOut.RebuildControlPanel()
        end
    end
end
function LightsOut.RegisterHousingFurnitureChangeEvents()
    local addedEvents = {
        rawget(_G, "EVENT_HOUSING_FURNITURE_PLACED"),
        rawget(_G, "EVENT_HOUSING_FURNITURE_ADDED"),
        rawget(_G, "EVENT_HOUSING_EDITOR_ITEM_PLACED"),
    }

    local removedEvents = {
        rawget(_G, "EVENT_HOUSING_FURNITURE_REMOVED"),
        rawget(_G, "EVENT_HOUSING_EDITOR_ITEM_REMOVED"),
        rawget(_G, "EVENT_HOUSING_FURNITURE_REMOVED_FROM_HOUSE"),
    }

    local registered = {}
    for _, eventId in ipairs(addedEvents) do
        if eventId ~= nil and not registered[eventId] then
            registered[eventId] = true
            EVENT_MANAGER:UnregisterForEvent(LightsOut.name, eventId)
            EVENT_MANAGER:RegisterForEvent(LightsOut.name, eventId, LightsOut.HandleHousingFurnitureAdded)
        end
    end

    for _, eventId in ipairs(removedEvents) do
        if eventId ~= nil and not registered[eventId] then
            registered[eventId] = true
            EVENT_MANAGER:UnregisterForEvent(LightsOut.name, eventId)
            EVENT_MANAGER:RegisterForEvent(LightsOut.name, eventId, LightsOut.RefreshAssignedTeamsAfterFurnitureRemoved)
        end
    end
end

function LightsOut.GetControlPanelCountInfo(mode, skipRescan)
    mode = string.lower(tostring(mode or "threshold"))
    if not skipRescan then LightsOut.RefreshTeamMatchingCounts() end
    if mode == "war" then
        local teamCount, firstFurnitureDataId, matchingCount, sameItem = 0, nil, nil, true
        for _, entry in pairs(LightsOut.savedVars and LightsOut.savedVars.warTeams or {}) do
            if LO_IsTeamEnabledForMode(entry, "war") then
                teamCount = teamCount + 1
                if firstFurnitureDataId == nil then
                    firstFurnitureDataId = entry.furnitureDataId
                    matchingCount = tonumber(entry.matchingCount or 0) or 0
                elseif tonumber(entry.furnitureDataId) ~= tonumber(firstFurnitureDataId) then
                    sameItem = false
                end
            end
        end
        if teamCount == 0 then return 0, "No enabled War teams", teamCount end
        if not sameItem then return 0, "War teams use different items", teamCount end
        if tonumber(matchingCount or 0) < 1 then return 0, "No matching items found", teamCount end
        return tonumber(matchingCount), nil, teamCount
    end

    local teamCount, firstCount, countsAreEqual = 0, nil, true
    for _, entry in pairs(LightsOut.savedVars and LightsOut.savedVars.items or {}) do
        if LO_IsTeamEnabledForMode(entry, mode) then
            teamCount = teamCount + 1
            local count = tonumber(entry.matchingCount or 0) or 0
            if firstCount == nil then firstCount = count elseif count ~= firstCount then countsAreEqual = false end
        end
    end
    if teamCount == 0 then return 0, "No enabled teams", teamCount end
    if not countsAreEqual then return 0, "Enabled team counts do not match", teamCount end
    if tonumber(firstCount or 0) < 1 then return 0, "No matching items found", teamCount end
    return tonumber(firstCount), nil, teamCount
end

LO_GetControlPanelMaxCount = function(mode, skipRescan)
    -- GetControlPanelCountInfo returns multiple values: maxCount, reason, teamCount.
    -- Always capture the first return before tonumber(), otherwise Lua may pass
    -- the reason string as tonumber()'s base argument when no teams are enabled.
    local maxCount = LightsOut.GetControlPanelCountInfo(mode, skipRescan)
    return tonumber(maxCount or 0) or 0
end

local function LO_ClampRequiredCount(skipRescan)
    local cp = LO_CP()
    LO_LoadModeConfig(cp.selectedMode, cp)

    if cp.selectedMode == "war" then
        cp.requiredCount = "all"
        LO_SaveSelectedModeConfig(cp)
        return
    end

    if cp.selectedMode == "target" then
        local targetMax = LO_TargetRequiredMax(skipRescan)
        local value = tonumber(cp.requiredCount)

        if value == nil then
            value = LO_DefaultTargetRequiredCount(skipRescan)
        end

        cp.requiredCount = math.max(1, math.min(targetMax, value))
        LO_SaveSelectedModeConfig(cp)
        return
    end

    if LO_IsAllRequiredCount(cp.requiredCount) then
        cp.requiredCount = "all"
        LO_SaveSelectedModeConfig(cp)
        return
    end

    local limit = LO_GetControlPanelMaxCount(cp.selectedMode, skipRescan)

    if limit < 1 then
        cp.requiredCount = math.max(1, tonumber(cp.requiredCount or 1) or 1)
        LO_SaveSelectedModeConfig(cp)
        return
    end

    cp.requiredCount = math.max(1, math.min(limit, tonumber(cp.requiredCount or 1) or 1))
    LO_SaveSelectedModeConfig(cp)
end

local function LO_TeamPercent(team, mode)
    local active = tonumber(team.currentWinCount or 0) or 0
    local required = tonumber(team.requiredWinCount or (LightsOut.game and LightsOut.game.threshold) or LO_CP().requiredCount or 1) or 1
    if mode == "war" then required = tonumber(team.matchingCount or required) or required end
    if required <= 0 then return 0 end
    return math.floor(((active / required) * 100) + 0.5)
end

local function LO_SetRight(label)
    if label and label.SetHorizontalAlignment and TEXT_ALIGN_RIGHT then label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
end

local function LO_TimerText()
    if type(LightsOut.GetGameTimerDisplayText) == "function" then return LightsOut.GetGameTimerDisplayText() end
    return ""
end

local function LO_StatusText()
    local g = LightsOut.game or {}
    if g.winner then return "Winner: " .. tostring(g.winner) end
    if g.active then return "In Progress" end
    return "Not Started"
end

local function LO_Leaders(mode)
    local teams = LO_TeamsForMode(mode)
    local best, leaders = nil, {}

    for _, team in ipairs(teams) do
        if team.enabled ~= false then
            local pct = LO_TeamPercent(team, mode)

            if best == nil or pct > best then
                best = pct
                leaders = { team.name or team.key or "Unknown" }
            elseif pct == best then
                table.insert(leaders, team.name or team.key or "Unknown")
            end
        end
    end

    -- If nobody has made progress toward a win, there is no current leader.
    if #leaders == 0 or tonumber(best or 0) <= 0 then return "None" end

    return table.concat(leaders, ", ")
end

local function LO_IsGameStatusVisibleState()
    local g = LightsOut.game or {}
    return g.active == true or g.winner ~= nil or g.cancelled == true
end

local function LO_ApplyTimerColor(label)
    if not label then return end

    local g = LightsOut.game or {}

    if g.cancelled then
        label:SetColor(1.00, 0.18, 0.18, 1)
    elseif g.winner then
        label:SetColor(0.30, 0.65, 1.00, 1)
    elseif g.overtime then
        label:SetColor(1.00, 0.86, 0.18, 1)
    else
        label:SetColor(0.25, 1.00, 0.15, 1)
    end
end

local function LO_OverviewResultText(mode)
    local g = LightsOut.game or {}

    if g.winner then
        return "Winner: " .. tostring(g.winner)
    end

    if g.cancelled then
        return "Current Leader: " .. LO_Leaders(mode)
    end

    return "Current Leader: " .. LO_Leaders(mode)
end

local function LO_MiniPanelStatusLabelText()
    local g = LightsOut.game or {}

    if g.winner then
        return "Winner:"
    end

    return "Current Leader:"
end

local function LO_MiniPanelStatusValueText()
    local g = LightsOut.game or {}
    local mode = g.mode or LO_CP().selectedMode or "threshold"

    if g.winner then
        return tostring(g.winner)
    end

    return LO_Leaders(mode)
end

local function LO_MiniPanelStatusText()
    return LO_MiniPanelStatusLabelText() .. " " .. LO_MiniPanelStatusValueText()
end

local function LO_MiniPanelHighestScoreText()
    local cp = LO_CP()
    local g = LightsOut.game or {}
    local mode = g.mode or cp.selectedMode or "threshold"
    local teams = LO_TeamsForMode(mode)

    local bestActive = 0
    local bestRequired = nil

    for _, team in ipairs(teams or {}) do
        if team.enabled ~= false then
            local active = tonumber(team.currentWinCount or 0) or 0
            local required = tonumber(team.requiredWinCount or (LightsOut.game and LightsOut.game.threshold) or cp.requiredCount or 0) or 0

            if mode == "war" then
                required = tonumber(team.matchingCount or required) or required
            end

            if required <= 0 then
                required = tonumber(team.matchingCount or 0) or 0
            end

            if bestRequired == nil or active > bestActive then
                bestActive = active
                bestRequired = required
            end
        end
    end

    bestRequired = tonumber(bestRequired or cp.requiredCount or 0) or 0

    local requiredText = tostring(bestRequired)
    local percent = 0

    if bestRequired <= 0 then
        requiredText = "ALL"
    else
        percent = math.floor(((bestActive / bestRequired) * 100) + 0.5)
    end

    return zo_strformat(
        "Highest Score: <<1>>/<<2>> (<<3>>%)",
        tostring(bestActive),
        requiredText,
        tostring(percent)
    )
end

local function LO_MiniPanelHighestScoreValueText()
    local text = LO_MiniPanelHighestScoreText()
    text = tostring(text or "")
    return text:gsub("^Highest Score:%s*", "")
end

local function LO_MiniPanelActionTextAndTone()
    local g = LightsOut.game or {}

    if g.winner ~= nil or g.cancelled == true then
        return "RESET GAME", "blue"
    end

    if g.active == true then
        return "CANCEL", "red"
    end

    return "START", "green"
end

function LightsOut.RecordMiniPanelCountUpdate(team, oldCount, newCount)
    oldCount = tonumber(oldCount or 0) or 0
    newCount = tonumber(newCount or 0) or 0

    if oldCount == newCount then
        return
    end

    local direction = newCount > oldCount and "up" or "down"
    local teamName = tostring(team and (team.name or team.key) or "Unknown Team")
    local updateText = zo_strformat(
        "<<1>> went <<2>> (<<3>> -> <<4>>)",
        teamName,
        direction,
        tostring(oldCount),
        tostring(newCount)
    )

    LightsOut.game = LightsOut.game or {}
    LightsOut.game.lastMiniPanelUpdate = updateText
    LightsOut.game.miniPanelUpdateHistory = LightsOut.game.miniPanelUpdateHistory or {}

    table.insert(LightsOut.game.miniPanelUpdateHistory, 1, {
        text = updateText,
        timestampMs = LightsOut.GetNowMs(),
    })

    while #LightsOut.game.miniPanelUpdateHistory > 6 do
        table.remove(LightsOut.game.miniPanelUpdateHistory)
    end

    if LightsOut.ui and LightsOut.ui.miniPanelWindow and not LightsOut.ui.miniPanelWindow:IsHidden() then
        LightsOut.RefreshMiniPanel()
    end
end

local function LO_MiniPanelSetupSummaryText()
    local cp = LO_CP()
    local g = LightsOut.game or {}
    local mode = tostring(g.mode or cp.selectedMode or "threshold")
    local modeText = string.lower(tostring(LO_ModeLabel(mode) or mode))
    modeText = string.gsub(modeText, "^%l", string.upper)

    local requiredValue = cp.requiredCount
    if mode == "war" or requiredValue == nil or tostring(requiredValue) == "all" or tonumber(requiredValue or 0) == 0 then
        requiredValue = "ALL"
    else
        requiredValue = tostring(requiredValue)
    end

    local activeTeams = LO_CountEnabled(LO_TeamsForMode(mode))

    if mode == "target" then
        local confirmText = LightsOut.IsTargetConfirmCountedEnabled and LightsOut.IsTargetConfirmCountedEnabled() and "Confirm: On" or "Confirm: Off"
        return zo_strformat(
            "<<1>>  |  <<2>>  |  Required: <<3>>  |  Teams: <<4>>",
            modeText,
            confirmText,
            tostring(requiredValue),
            tostring(activeTeams)
        )
    end

    return zo_strformat(
        "<<1>>  |  Required: <<2>>  |  Teams: <<3>>",
        modeText,
        tostring(requiredValue),
        tostring(activeTeams)
    )
end

local function LO_ShowPage(pageKey)
    LightsOut.ui.pages = LightsOut.ui.pages or {}
    for key, page in pairs(LightsOut.ui.pages) do
        page:SetHidden(key ~= pageKey)
    end
    LightsOut.ui.activePage = pageKey
end

local function LO_SelectValueBox(parent, labelText, valueText, x, y, w, onPrev, onNext)
    local label = LO_Label(parent, labelText, "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    local box = LO_Panel(parent, x, y + 26, w, 44)
    local value = LO_Label(box, valueText, "ZoFontGameBold", 1, 1, 1, 1)
    value:SetAnchor(CENTER, box, CENTER, 0, 0)
    local prev = LO_Button(box, "<", 36, 30, "gray")
    prev:SetAnchor(LEFT, box, LEFT, 8, 0)
    prev:SetHandler("OnClicked", onPrev)
    local next = LO_Button(box, ">", 36, 30, "gray")
    next:SetAnchor(RIGHT, box, RIGHT, -8, 0)
    next:SetHandler("OnClicked", onNext)
    return value
end


local function LO_NormalizeTeamName(name)
    -- Preserve a truly blank rename value so LO_SaveTeamName can restore the
    -- Populate House default name instead of turning the blank into "Team".
    local text = tostring(name or ""):match("^%s*(.-)%s*$")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    text = text:gsub("[\r\n\t]", " ")
    text = text:gsub("[%[%]{}=,;]", " ")
    text = text:gsub("%s+", " ")
    text = text:match("^%s*(.-)%s*$") or ""
    return text
end

local function LO_UppercaseFirstTeamNameCharacter(name)
    local text = tostring(name or "")
    if text == "" then return text end

    -- Capitalize the first typed letter, even if the player accidentally
    -- starts the edit box with spaces.  This also runs again on save, so the
    -- stored team name is protected even if an edit-box event is missed.
    local changed = false
    local updated = text:gsub("^(%s*)(%a)", function(prefix, firstLetter)
        changed = true
        return prefix .. string.upper(firstLetter)
    end, 1)

    if changed then
        return updated
    end

    return text
end

local function LO_GetTeamStorageInfo(team, isWar)
    local saved = LO_Saved()
    local source = isWar and (saved.warTeams or {}) or (saved.items or {})
    local currentKey = team and team.key or nil

    if currentKey and source[currentKey] == team then
        return source, currentKey
    end

    for key, entry in pairs(source) do
        if entry == team then
            return source, key
        end
    end

    return source, currentKey
end

local function LO_TeamNameExistsInRenameGroup(team, isWar, proposedName)
    local saved = LO_Saved()
    local compareName = string.lower(LO_NormalizeTeamName(proposedName))
    local mode = LO_NormalizeModeKey((LO_CP() and LO_CP().selectedMode) or "threshold")

    if isWar then
        local furnitureDataId = tonumber(team and team.furnitureDataId)
        for _, entry in pairs(saved.warTeams or {}) do
            if entry ~= team and tonumber(entry.furnitureDataId) == furnitureDataId then
                if string.lower(LO_NormalizeTeamName(entry.name or "")) == compareName then
                    return true
                end
            end
        end
    else
        local matchingCount = tonumber(team and team.matchingCount or 0) or 0
        for _, entry in pairs(saved.items or {}) do
            if entry ~= team and (tonumber(entry.matchingCount or 0) or 0) == matchingCount then
                local entryName = LO_GetTeamNameForMode(entry, mode, false)
                if string.lower(LO_NormalizeTeamName(entryName or "")) == compareName then
                    return true
                end
            end
        end
    end

    return false
end

local function LO_SaveTeamName(team, isWar, proposedName)
    if not team then return false end

    local newName = LO_NormalizeTeamName(proposedName)
    if newName ~= "" then
        newName = LO_UppercaseFirstTeamNameCharacter(newName)
    end

    -- If the rename box is left blank, restore the default auto-generated
    -- name that Populate House would have assigned for this furnishing/state.
    if newName == "" then
        local stateIndex = tonumber(team.state)
        local defaultFallback = stateIndex ~= nil and ("State " .. tostring(stateIndex)) or "Team"
        local defaultStateName = LO_NormalizeTeamName(team.stateName or defaultFallback)

        if defaultStateName == "" then
            defaultStateName = defaultFallback
        end

        -- Match Populate House naming:
        --   Standard teams: <state name> - <item name>
        --   War teams:      <state name>
        if isWar then
            newName = defaultStateName
        else
            newName = LO_GetDefaultStandardTeamName(team)
        end
    end

    if LO_TeamNameExistsInRenameGroup(team, isWar, newName) then
        LightsOut.Print("Team name not changed. Another team in this group already uses: " .. tostring(newName))
        return false
    end

    local source, oldKey = LO_GetTeamStorageInfo(team, isWar)

    if isWar then
        local newKey = tostring(tonumber(team.furnitureDataId) or tostring(team.furnitureDataId or "0")) .. ":" .. LightsOut_SafeKey(newName, "team")

        if source[newKey] ~= nil and source[newKey] ~= team then
            LightsOut.Print("Team name not changed. The saved key already exists for: " .. tostring(newName))
            return false
        end

        if oldKey and oldKey ~= newKey and source[oldKey] == team then
            source[oldKey] = nil
        end

        team.name = newName
        team.key = newKey
        source[newKey] = team

        if LightsOut.game and LightsOut.game.winner == oldKey then
            LightsOut.game.winner = newName
        end
    else
        local mode = LO_NormalizeModeKey((LO_CP() and LO_CP().selectedMode) or "threshold")
        team.namesByMode = team.namesByMode or {}
        team.namesByMode[mode] = newName
        team.name = newName

        -- Do not re-key standard teams when renaming. Threshold and Target can
        -- now have different names for the same saved furnishing entry, so the
        -- SavedVariables key must remain stable across modes.
        if oldKey then
            team.key = oldKey
            source[oldKey] = team
        end
    end

    return true
end


local function LO_SetTeamNameEditorError(editor, hasError)
    if not editor then return end

    editor.hasError = hasError == true

    if editor.backdrop then
        if editor.hasError then
            editor.backdrop:SetCenterColor(0.20, 0.02, 0.02, 0.96)
            editor.backdrop:SetEdgeColor(1.00, 0.15, 0.15, 1)
        else
            editor.backdrop:SetCenterColor(0.03, 0.04, 0.05, 0.98)
            editor.backdrop:SetEdgeColor(0.55, 0.75, 1.0, 1)
        end
    end
end

local function LO_FocusTeamNameEditor(editor)
    if not editor or not editor.editBox then return end

    if editor.editBox.TakeFocus then
        editor.editBox:TakeFocus()
    end

    if editor.editBox.HighlightText then
        editor.editBox:HighlightText()
    end
end


local function LO_RefreshTeamEditVisuals(team)
    if not team or not LightsOut.ui then return false end

    local updated = false

    -- Setup rows are keyed by the team table itself, so a team rename that
    -- changes the SavedVariables key does not require a full control-panel
    -- rebuild just to find the row again.
    local setupRow = LightsOut.ui.setupRows and LightsOut.ui.setupRows[team]
    if setupRow then
        if setupRow.nameLabel and setupRow.nameLabel.SetText then
            setupRow.nameLabel:SetText(tostring(LO_GetTeamNameForMode(team, nil, false) or ""))
            updated = true
        end
        if setupRow.stateLabel and setupRow.stateLabel.SetText then
            setupRow.stateLabel:SetText(tostring(team.stateName or ""))
            updated = true
        end
    end

    -- Status rows are keyed for fast score updates, but key values can change
    -- when a team is renamed. Scan the small visible status-row map by team
    -- reference so the in-game panel stays current without rebuilding.
    for _, statusRow in pairs(LightsOut.ui.statusRows or {}) do
        if statusRow and statusRow.team == team then
            if statusRow.nameLabel and statusRow.nameLabel.SetText then
                statusRow.nameLabel:SetText(tostring(LO_GetTeamNameForMode(team, nil, LO_NormalizeModeKey((LO_CP() and LO_CP().selectedMode) or "threshold") == "war") or ""))
                updated = true
            end
            if statusRow.stateLabel and statusRow.stateLabel.SetText then
                statusRow.stateLabel:SetText(tostring(team.stateName or ""))
                updated = true
            end
        end
    end

    return updated
end

local function LO_CloseTeamNameEditor(save)
    local editor = LightsOut.ui and LightsOut.ui.activeTeamNameEditor
    if not editor or editor.closed then return false end

    local saved = false
    local displayName = editor.originalName or ""

    if save then
        local proposedName = editor.editBox and editor.editBox.GetText and editor.editBox:GetText() or editor.originalName
        saved = LO_SaveTeamName(editor.team, editor.isWar, proposedName)

        if not saved then
            -- Invalid values stay in edit mode so the user can correct them.
            LO_SetTeamNameEditorError(editor, true)
            LO_FocusTeamNameEditor(editor)
            return false
        end

        displayName = tostring(LO_GetTeamNameForMode(editor.team, editor.mode, editor.isWar) or proposedName or "")
    end

    LO_SetTeamNameEditorError(editor, false)

    LightsOut.ui.activeTeamNameEditor = nil
    editor.closed = true

    if editor.editBox then
        editor.editBox:SetHidden(true)
        if WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
            WINDOW_MANAGER:DestroyControl(editor.editBox)
        end
    end

    if editor.label then
        editor.label._lightsOutEditingHidden = false
        editor.label:SetText(displayName)

        if type(LO_Tooltip) == "function" then
            LO_Tooltip(editor.label, tostring(displayName or ""))
        end

        if editor.label.SetAlpha then editor.label:SetAlpha(1) end
        if editor.label.SetMouseEnabled then editor.label:SetMouseEnabled(true) end
        editor.label:SetHidden(false)
    end

    if saved then
        -- Update any currently visible rows that reference this same team.
        -- This keeps main setup rows, main status rows, and mini assignment rows
        -- consistent without rebuilding unrelated UI.
        LO_RefreshTeamEditVisuals(editor.team)
    end

    return saved
end

local function LO_DefaultTeamNameForReset(team, isWar)
    if not team then return "Team" end

    if isWar then
        local stateIndex = tonumber(team.state)
        local defaultFallback = stateIndex ~= nil and ("State " .. tostring(stateIndex)) or "Team"
        local defaultStateName = LO_NormalizeTeamName(team.stateName or defaultFallback)

        if defaultStateName == "" then
            defaultStateName = defaultFallback
        end

        return defaultStateName
    end

    return LO_GetDefaultStandardTeamName(team)
end

function LightsOut.ResetCurrentSetupTeamNames()
    LightsOut.SetActiveHouseSavedVars()

    local cp = LO_CP()
    local mode = LO_NormalizeModeKey(cp.selectedMode or "threshold")
    LO_ApplyModeEnabledState(mode)

    local isWar = mode == "war"
    local teams = LO_AllTeamsForMode(mode)
    local resetCount = 0
    local skippedCount = 0

    if not teams or #teams == 0 then
        LightsOut.Print("No eligible team names to reset for " .. tostring(LO_ModeLabel(mode)) .. " mode.")
        return
    end

    if LightsOut.ui and LightsOut.ui.activeTeamNameEditor then
        LO_CloseTeamNameEditor(false)
    end

    for _, team in ipairs(teams) do
        local defaultName = LO_DefaultTeamNameForReset(team, isWar)
        local currentName = LO_GetTeamNameForMode(team, mode, isWar)

        if tostring(currentName or "") ~= tostring(defaultName or "") then
            if LO_SaveTeamName(team, isWar, "") then
                resetCount = resetCount + 1
            else
                skippedCount = skippedCount + 1
            end
        end
    end

    LO_ApplyModeEnabledState(mode)

    if type(LightsOut.RebuildControlPanel) == "function" then
        LightsOut.RebuildControlPanel()
    elseif type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
        LightsOut.RefreshControlPanelForTeamChange({ refreshCounts = false })
    end

    if skippedCount > 0 then
        LightsOut.Print(zo_strformat(
            "Reset <<1>> team name(s) for <<2>> mode. Skipped <<3>> name(s) because of conflicts.",
            tostring(resetCount),
            tostring(LO_ModeLabel(mode)),
            tostring(skippedCount)
        ))
    else
        LightsOut.Print(zo_strformat(
            "Reset <<1>> team name(s) for <<2>> mode.",
            tostring(resetCount),
            tostring(LO_ModeLabel(mode))
        ))
    end
end



local function LO_SetTeamNameLabelEditingVisual(label, editing)
    if not label then return end

    label._lightsOutEditingHidden = editing == true

    if label.SetHidden then label:SetHidden(editing == true) end
    if label.SetAlpha then label:SetAlpha(editing == true and 0 or 1) end
    if label.SetMouseEnabled then label:SetMouseEnabled(editing ~= true) end
end

local function LO_RegisterMiniAssignmentTeamLabel(team, label)
    if not team or not label then return end

    LightsOut.ui = LightsOut.ui or {}
    LightsOut.ui.miniAssignmentTeamLabels = LightsOut.ui.miniAssignmentTeamLabels or {}

    local labels = LightsOut.ui.miniAssignmentTeamLabels[team]
    if not labels then
        labels = {}
        LightsOut.ui.miniAssignmentTeamLabels[team] = labels
    end

    labels[#labels + 1] = label
    label._lightsOutMiniAssignmentTeam = team
end

local function LO_SetMiniAssignmentTeamLabelsEditing(team, editing)
    if not (LightsOut.ui and LightsOut.ui.miniAssignmentTeamLabels and team) then
        return
    end

    local labels = LightsOut.ui.miniAssignmentTeamLabels[team]
    if not labels then return end

    for _, label in ipairs(labels) do
        LO_SetTeamNameLabelEditingVisual(label, editing)
    end
end


local function LO_StartTeamNameEdit(label, team, isWar, width, height)
    if not label or not team then return end

    LO_CloseTeamNameEditor(false)

    local parent = label:GetParent()
    if not parent then return end

    local mode = (LightsOut.game and LightsOut.game.mode) or (LO_CP() and LO_CP().selectedMode) or nil
    local originalName = tostring(LO_GetTeamNameForMode(team, mode, isWar) or "")

    local editBox = WINDOW_MANAGER:CreateControl(nil, parent, CT_EDITBOX)
    editBox:SetDimensions(width or 160, height or 24)
    editBox:SetAnchor(TOPLEFT, label, TOPLEFT, 0, 0)
    editBox:SetFont("ZoFontGameBold")
    editBox:SetText(originalName)
    editBox:SetMaxInputChars(64)
    editBox:SetMouseEnabled(true)
    editBox:SetEditEnabled(true)
    editBox:SetSelectAllOnFocus(true)

    if editBox.SetColor then editBox:SetColor(1, 1, 1, 1) end
    if editBox.SetNormalFontColor then editBox:SetNormalFontColor(1, 1, 1, 1) end
    if editBox.SetMouseOverFontColor then editBox:SetMouseOverFontColor(1, 1, 1, 1) end
    if editBox.SetFocusFontColor then editBox:SetFocusFontColor(1, 1, 1, 1) end
    if editBox.SetTextColor then editBox:SetTextColor(1, 1, 1, 1) end
    if editBox.SetCursorColor then editBox:SetCursorColor(1, 1, 1, 1) end
    if editBox.SetSelectionColor then editBox:SetSelectionColor(0.25, 0.55, 1.0, 0.55) end

    local backdrop = WINDOW_MANAGER:CreateControl(nil, editBox, CT_BACKDROP)
    backdrop:SetAnchorFill(editBox)
    backdrop:SetCenterColor(0.03, 0.04, 0.05, 0.98)
    backdrop:SetEdgeColor(0.55, 0.75, 1.0, 1)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)
    if backdrop.SetDrawLayer and DL_BACKGROUND then backdrop:SetDrawLayer(DL_BACKGROUND) end
    if backdrop.SetDrawTier and DT_LOW then backdrop:SetDrawTier(DT_LOW) end
    if backdrop.SetDrawLevel then backdrop:SetDrawLevel(0) end

    -- The display label must fully disappear while editing.
    -- The edit box sits in the same location and is restored to a label on save/cancel.
    label._lightsOutEditingHidden = true
    label:SetHidden(true)
    if label.SetAlpha then label:SetAlpha(0) end
    if label.SetMouseEnabled then label:SetMouseEnabled(false) end

    local editor = {
        editBox = editBox,
        backdrop = backdrop,
        label = label,
        team = team,
        isWar = isWar,
        mode = mode,
        originalName = originalName,
        closed = false,
        hasError = false,
    }

    LightsOut.ui = LightsOut.ui or {}
    LightsOut.ui.activeTeamNameEditor = editor

    local function saveAndClose()
        LO_CloseTeamNameEditor(true)
    end

    local function cancelAndClose()
        LO_CloseTeamNameEditor(false)
    end

    editBox:SetHandler("OnEnter", saveAndClose)
    editBox:SetHandler("OnFocusLost", saveAndClose)
    editBox:SetHandler("OnEscape", cancelAndClose)

    if editBox.TakeFocus then
        editBox:TakeFocus()
    end
end

local function LO_MakeTeamNameEditable(label, team, isWar, width, height)
    if not label or not team then return label end
    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseUp", function()
        LO_StartTeamNameEdit(label, team, isWar, width, height)
    end)
    return label
end

local function LO_CloseStatePicker(save)
    local picker = LightsOut.ui and LightsOut.ui.activeStatePicker
    if not picker or picker.closed then return false end

    LightsOut.ui.activeStatePicker = nil
    picker.closed = true

    -- Close must be visually instant, but destruction of a popup tree from
    -- inside a child row OnMouseUp can stall ESO's UI event dispatch.  Hide all
    -- popup pieces now, let the original row repaint, then destroy later.
    local overlay = picker.overlay
    if overlay then
        overlay:SetHidden(true)
        overlay:SetMouseEnabled(false)
    end

    if picker.popup then
        picker.popup:SetHidden(true)
        picker.popup:SetMouseEnabled(false)
    end

    if picker.solidBg then
        picker.solidBg:SetHidden(true)
        picker.solidBg:SetMouseEnabled(false)
    end

    if picker.catcher then
        picker.catcher:SetHidden(true)
        picker.catcher:SetMouseEnabled(false)
    end

    if picker.label then
        picker.label:SetHidden(false)
    end

    local function destroyOverlay()
        if overlay and WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
            WINDOW_MANAGER:DestroyControl(overlay)
        end
    end

    if type(zo_callLater) == "function" then
        -- Keep this comfortably delayed. The popup is already hidden, so the
        -- user sees the selected state immediately while cleanup happens later.
        zo_callLater(destroyOverlay, 500)
    else
        destroyOverlay()
    end

    return true
end

local function LO_GetRepresentativeFurnitureId(team)
    if not team then return nil end

    if team.furnitureIds then
        local first = team.furnitureIds[1]
        if type(first) == "table" and first.furnitureId then
            return first.furnitureId
        end
        if first then
            return first
        end
    end

    if team.trackedFurnitureIds then
        local first = team.trackedFurnitureIds[1]
        if type(first) == "table" and first.furnitureId then
            return first.furnitureId
        end
        if first then
            return first
        end
    end

    if team.furnitureDataId then
        local matchingFurniture = LightsOut.GetMatchingHouseFurniture(team.furnitureDataId)
        if matchingFurniture and matchingFurniture[1] then
            return matchingFurniture[1].furnitureId or matchingFurniture[1]
        end
    end

    return nil
end

local function LO_GetStateOptionsForTeam(team, isWar)
    local options = {}
    local furnitureId = LO_GetRepresentativeFurnitureId(team)
    local numStates = tonumber(team and team.numStates or 0) or 0
    local currentState = tonumber(team and team.state)
    local furnitureDataId = tonumber(team and team.furnitureDataId)
    local usedWarStates = {}

    if furnitureId and type(GetPlacedHousingFurnitureNumObjectStates) == "function" then
        local apiStates = tonumber(GetPlacedHousingFurnitureNumObjectStates(furnitureId) or 0) or 0
        if apiStates > 0 then numStates = apiStates end
    end

    if numStates <= 0 then numStates = 2 end

    -- In War setup, states must be unique for all teams sharing the same
    -- furnitureDataId.  Show this team's current state, plus any states not
    -- already assigned to another team in the same item group.
    if isWar and furnitureDataId ~= nil then
        local saved = LO_Saved()

        for _, entry in pairs(saved.warTeams or {}) do
            if entry ~= team and tonumber(entry.furnitureDataId) == furnitureDataId then
                local usedState = tonumber(entry.state)
                if usedState ~= nil then
                    usedWarStates[usedState] = true
                end
            end
        end
    end

    for stateIndex = 0, numStates - 1 do
        if not isWar or stateIndex == currentState or not usedWarStates[stateIndex] then
            local stateName
            if furnitureId then
                stateName = LightsOut.GetStateDisplayName(furnitureId, stateIndex)
            end
            stateName = LightsOut_SafeText(stateName, "State " .. tostring(stateIndex))
            options[#options + 1] = { state = stateIndex, name = stateName }
        end
    end

    return options
end

local function LO_WarStateAlreadyUsed(team, newState)
    local saved = LO_Saved()
    local furnitureDataId = tonumber(team and team.furnitureDataId)
    newState = tonumber(newState)

    for _, entry in pairs(saved.warTeams or {}) do
        if entry ~= team and tonumber(entry.furnitureDataId) == furnitureDataId and tonumber(entry.state) == newState then
            return true, entry
        end
    end

    return false, nil
end

local function LO_SaveTeamState(team, isWar, newState, newStateName)
    if not team then return false end

    newState = tonumber(newState)
    if newState == nil then return false end

    if isWar then
        local duplicate, existing = LO_WarStateAlreadyUsed(team, newState)
        if duplicate then
            LightsOut.Print("State not changed. War team " .. tostring(existing.name or "Unknown") .. " already uses " .. tostring(newStateName or ("State " .. tostring(newState))) .. ".")
            return false
        end
    end

    team.state = newState
    team.stateName = LightsOut_SafeText(newStateName, "State " .. tostring(newState))

    return true
end

local function LO_ApplyStateVisualsFast(team, label)
    if not team then return end

    local stateText = tostring(team.stateName or ("State " .. tostring(team.state or "?")))

    -- Update the exact clicked label first. This is the visible row the user
    -- interacted with, so it should change before any popup cleanup happens.
    if label and label.SetText then
        label:SetText(stateText)
    end

    local setupRow = LightsOut.ui and LightsOut.ui.setupRows and LightsOut.ui.setupRows[team]
    if setupRow and setupRow.stateLabel and setupRow.stateLabel.SetText then
        setupRow.stateLabel:SetText(stateText)
    end

    -- The status-row map is small and only exists during active-game/status
    -- views. Do not rebuild or rescan anything; just repaint matching row text.
    for _, statusRow in pairs((LightsOut.ui and LightsOut.ui.statusRows) or {}) do
        if statusRow and statusRow.team == team and statusRow.stateLabel and statusRow.stateLabel.SetText then
            statusRow.stateLabel:SetText(stateText)
        end
    end
end

local function LO_StartStatePicker(label, team, isWar, width, height)
    if not label or not team then return end
    if LightsOut.game and LightsOut.game.active then return end

    LO_CloseTeamNameEditor(false)
    LO_CloseStatePicker(false)

    local window = LightsOut.ui and LightsOut.ui.controlWindow
    if not window then return end

    local options = LO_GetStateOptionsForTeam(team, isWar)
    if #options < 2 then return end

    local function setPickerDraw(control, level)
        if not control then return end
        if control.SetDrawLayer and DL_OVERLAY then control:SetDrawLayer(DL_OVERLAY) end
        if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
        if control.SetDrawLevel then control:SetDrawLevel(level or 1000) end
    end

    -- IMPORTANT:
    -- Do not make the parent overlay itself mouse-enabled. In ESO, a large
    -- mouse-enabled parent can intercept clicks before its children. Instead,
    -- create a separate outside-click catcher behind the popup, then create the
    -- popup after it so the popup rows receive mouse input normally.
    local overlay = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    overlay:SetAnchorFill(window)
    overlay:SetMouseEnabled(false)
    setPickerDraw(overlay, 1000)
    overlay.isPopup = true

    local catcher = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
    catcher:SetAnchorFill(overlay)
    catcher:SetMouseEnabled(true)
    setPickerDraw(catcher, 1001)
    catcher:SetCenterColor(0, 0, 0, 0.18)
    catcher:SetEdgeColor(0, 0, 0, 0)
    catcher.isPopup = true

    local picker = {
        overlay = overlay,
        catcher = catcher,
        label = label,
        team = team,
        isWar = isWar,
        closed = false,
        selectedIndex = 1,
        optionRows = {},
    }

    LightsOut.ui = LightsOut.ui or {}
    LightsOut.ui.activeStatePicker = picker

    local popupWidth = math.max(width or 160, 220)
    local popupHeight = (#options * 34) + 24

    -- Keep an always-opaque backdrop outside the animated popup content.
    -- Fading the popup control itself also fades child backdrops, which makes
    -- the game/setup rows visible underneath during the animation.
    local solidBg = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
    solidBg:SetDimensions(popupWidth, popupHeight)
    solidBg:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 4)
    solidBg:SetMouseEnabled(false)
    setPickerDraw(solidBg, 1009)
    solidBg:SetCenterColor(0.035, 0.035, 0.045, 1)
    solidBg:SetEdgeColor(0.95, 0.78, 0.32, 1)
    solidBg:SetEdgeTexture(nil, 1, 1, 4)
    if solidBg.SetInsets then solidBg:SetInsets(-3, -3, 3, 3) end
    solidBg.isPopup = true
    picker.solidBg = solidBg

    local popup = WINDOW_MANAGER:CreateControl(nil, overlay, CT_CONTROL)
    popup:SetDimensions(popupWidth, popupHeight)
    popup:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 4)
    popup:SetMouseEnabled(true)
    setPickerDraw(popup, 1010)
    popup.isPopup = true
    if popup.SetAlpha then popup:SetAlpha(1) end
    if popup.SetScale then popup:SetScale(0.96) end
    picker.popup = popup

    local bg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    setPickerDraw(bg, 1011)
    bg:SetCenterColor(0.035, 0.035, 0.045, 1)
    bg:SetEdgeColor(0.95, 0.78, 0.32, 1)
    bg:SetEdgeTexture(nil, 1, 1, 4)
    if bg.SetInsets then bg:SetInsets(-3, -3, 3, 3) end

    local function fadePopupIn()
        -- Keep the popup fully opaque. Use a short scale-in animation instead
        -- of fading the whole popup, so nothing underneath can show through.
        if not popup.SetScale then return end

        local steps = 6
        local delayMs = 18

        for step = 1, steps do
            local scale = 0.96 + ((step / steps) * 0.04)
            local function applyScale()
                if LightsOut.ui and LightsOut.ui.activeStatePicker == picker and not picker.closed and popup.SetScale then
                    popup:SetScale(scale)
                end
            end

            if type(zo_callLater) == "function" then
                zo_callLater(applyScale, step * delayMs)
            else
                applyScale()
            end
        end
    end

    local title = LO_Label(popup, "Select State", "ZoFontGameSmall", 1.0, 0.88, 0.55, 1)
    title:SetAnchor(TOPLEFT, popup, TOPLEFT, 10, 4)
    LO_SingleLine(title, popupWidth - 20, 18)
    setPickerDraw(title, 1300)

    local currentState = tonumber(team.state)
    for index, option in ipairs(options) do
        if tonumber(option.state) == currentState then
            picker.selectedIndex = index
            break
        end
    end

    local function refreshSelection()
        for index, rowInfo in ipairs(picker.optionRows or {}) do
            if rowInfo.backdrop then
                if index == picker.selectedIndex then
                    rowInfo.backdrop:SetCenterColor(0.10, 0.25, 0.08, 1)
                    rowInfo.backdrop:SetEdgeColor(0.42, 0.95, 0.26, 1)
                elseif tonumber(rowInfo.option.state) == currentState then
                    rowInfo.backdrop:SetCenterColor(0.08, 0.18, 0.07, 1)
                    rowInfo.backdrop:SetEdgeColor(0.35, 0.65, 0.25, 1)
                else
                    rowInfo.backdrop:SetCenterColor(0.12, 0.12, 0.13, 1)
                    rowInfo.backdrop:SetEdgeColor(0.38, 0.38, 0.42, 1)
                end
            end
        end
    end

    local function chooseSelected()
        if picker.choosing then return end
        picker.choosing = true

        local option = options[picker.selectedIndex]
        if not option then
            picker.choosing = false
            return
        end

        -- Selecting the current state should only close the picker; it should
        -- not trigger any refresh path.
        if tonumber(team.state) == tonumber(option.state) then
            LO_CloseStatePicker(false)
            return
        end

        if LO_SaveTeamState(team, isWar, option.state, option.name) then
            -- Only change data and repaint the affected row(s). Do not rebuild,
            -- resort, refresh counts, or recreate the setup list for a win-state
            -- edit. The popup is hidden after the label text has already changed.
            LO_ApplyStateVisualsFast(team, picker.label)
            LO_CloseStatePicker(true)
        else
            picker.choosing = false
        end
    end

    local function moveSelection(delta)
        local count = #options
        if count <= 0 then return end
        picker.selectedIndex = ((picker.selectedIndex - 1 + delta) % count) + 1
        refreshSelection()
    end

    catcher:SetHandler("OnMouseUp", function()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
            LO_CloseStatePicker(false)
        end
    end)

    for index, option in ipairs(options) do
        local row = WINDOW_MANAGER:CreateControl(nil, popup, CT_CONTROL)
        row:SetDimensions(popupWidth - 16, 30)
        row:SetAnchor(TOPLEFT, popup, TOPLEFT, 8, 22 + ((index - 1) * 34))
        row:SetMouseEnabled(true)
        setPickerDraw(row, 1020 + index)
        row.isPopup = true

        local rowBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        rowBg:SetAnchorFill(row)
        setPickerDraw(rowBg, 1021 + index)
        rowBg:SetCenterColor(0.12, 0.12, 0.13, 1)
        rowBg:SetEdgeColor(0.38, 0.38, 0.42, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1)

        local text = LO_Label(row, tostring(option.name), "ZoFontGame", 1, 1, 1, 1)
        text:SetAnchor(LEFT, row, LEFT, 10, 0)
        LO_SingleLine(text, popupWidth - 36, 24)
        setPickerDraw(text, 1300 + index)

        picker.optionRows[index] = {
            row = row,
            backdrop = rowBg,
            option = option,
        }

        row:SetHandler("OnMouseEnter", function()
            if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
                picker.selectedIndex = index
                refreshSelection()
            end
        end)

        row:SetHandler("OnMouseDown", function()
            if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
                picker.selectedIndex = index
                refreshSelection()
            end
        end)

        row:SetHandler("OnMouseUp", function()
            if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
                picker.selectedIndex = index
                -- Do not repaint the whole popup selection immediately before
                -- closing it. That visual work is unnecessary and can cause a
                -- noticeable stall in large UI trees.
                chooseSelected()
            end
        end)
    end

    refreshSelection()
    -- Avoid popup animation timers. The state picker needs to feel instant,
    -- especially in large houses where control churn is already costly.
    -- fadePopupIn()

    -- Keyboard handling: ESO edit boxes reliably receive OnEnter/OnEscape,
    -- but arrow handlers vary by API build. Use both named arrow handlers and
    -- OnKeyDown with common key constants when available.
    local keyBox = WINDOW_MANAGER:CreateControl(nil, popup, CT_EDITBOX)
    keyBox:SetDimensions(1, 1)
    keyBox:SetAnchor(TOPLEFT, popup, TOPLEFT, 2, 2)
    keyBox:SetMouseEnabled(true)
    setPickerDraw(keyBox, 1100)
    keyBox:SetEditEnabled(true)
    keyBox:SetMaxInputChars(1)
    keyBox:SetText("")
    if keyBox.SetAlpha then keyBox:SetAlpha(0) end
    keyBox.isPopup = true
    picker.keyBox = keyBox

    local function cancel()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
            LO_CloseStatePicker(false)
        end
    end

    keyBox:SetHandler("OnEscape", cancel)
    keyBox:SetHandler("OnEnter", function()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
            chooseSelected()
        end
    end)
    keyBox:SetHandler("OnUpArrow", function()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
            moveSelection(-1)
        end
    end)
    keyBox:SetHandler("OnDownArrow", function()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker then
            moveSelection(1)
        end
    end)
    keyBox:SetHandler("OnKeyDown", function(_, keyCode)
        if not (LightsOut.ui and LightsOut.ui.activeStatePicker == picker) then return end

        local key = tonumber(keyCode)
        if key ~= nil then
            local esc = rawget(_G, "KEY_ESCAPE")
            local enter = rawget(_G, "KEY_ENTER")
            local numEnter = rawget(_G, "KEY_NUMPAD_ENTER")
            local up = rawget(_G, "KEY_UPARROW") or rawget(_G, "KEY_ARROW_UP")
            local down = rawget(_G, "KEY_DOWNARROW") or rawget(_G, "KEY_ARROW_DOWN")

            if esc ~= nil and key == esc then
                cancel()
            elseif (enter ~= nil and key == enter) or (numEnter ~= nil and key == numEnter) then
                chooseSelected()
            elseif up ~= nil and key == up then
                moveSelection(-1)
            elseif down ~= nil and key == down then
                moveSelection(1)
            end
        end
    end)

    -- Keep focus on the hidden key box after the popup is fully constructed.
    local function focusKeyBox()
        if LightsOut.ui and LightsOut.ui.activeStatePicker == picker and keyBox.TakeFocus then
            keyBox:TakeFocus()
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(focusKeyBox, 1)
    else
        focusKeyBox()
    end
end

local function LO_MakeStateEditable(label, team, isWar, width, height)
    if not label or not team then return label end
    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseUp", function()
        LO_StartStatePicker(label, team, isWar, width, height)
    end)
    return label
end


local function LO_SetHighOverlayDraw(control, level)
    if not control then return end
    if control.SetDrawLayer and DL_OVERLAY then control:SetDrawLayer(DL_OVERLAY) end
    if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLevel then control:SetDrawLevel(level or 1200) end
end

local function LO_CloseDeleteConfirm()
    local dialog = LightsOut.ui and LightsOut.ui.activeDeleteConfirm
    if not dialog or dialog.closed then return false end

    LightsOut.ui.activeDeleteConfirm = nil
    dialog.closed = true

    if dialog.overlay then
        dialog.overlay:SetHidden(true)
        if WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
            WINDOW_MANAGER:DestroyControl(dialog.overlay)
        end
    end

    return true
end

local function LO_ShowDeleteConfirm(titleText, bodyText, confirmText, onConfirm)
    LightsOut.ui = LightsOut.ui or {}

    LO_CloseTeamNameEditor(false)
    LO_CloseStatePicker(false)
    LO_CloseDeleteConfirm()

    local window = LightsOut.ui.controlWindow
    if not window then return end

    local overlay = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    overlay:SetAnchorFill(window)
    -- The overlay must be mouse-enabled so ESO routes clicks to the popup layer
    -- instead of the pass-through control panel beneath it. Child controls still
    -- receive their own clicks because they sit above the blocker/dialog.
    overlay:SetMouseEnabled(true)
    if overlay.SetKeyboardEnabled then overlay:SetKeyboardEnabled(true) end
    LO_SetHighOverlayDraw(overlay, 1200)
    overlay.isPopup = true

    local blocker = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
    blocker:SetAnchorFill(overlay)
    -- The blocker intentionally catches clicks outside the dialog so they do not
    -- fall through to controls behind the modal. It does not close the dialog.
    blocker:SetMouseEnabled(true)
    blocker:SetCenterColor(0, 0, 0, 0.42)
    blocker:SetEdgeColor(0, 0, 0, 0)
    LO_SetHighOverlayDraw(blocker, 1201)
    blocker.isPopup = true

    local dialog = WINDOW_MANAGER:CreateControl(nil, overlay, CT_CONTROL)
    dialog:SetDimensions(430, 190)
    dialog:SetAnchor(CENTER, overlay, CENTER, 0, 0)
    dialog:SetMouseEnabled(true)
    if dialog.SetKeyboardEnabled then dialog:SetKeyboardEnabled(true) end
    LO_SetHighOverlayDraw(dialog, 1210)
    dialog.isPopup = true

    local bg = WINDOW_MANAGER:CreateControl(nil, dialog, CT_BACKDROP)
    bg:SetAnchorFill(dialog)
    bg:SetMouseEnabled(false)
    LO_SetHighOverlayDraw(bg, 1211)
    bg:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    bg:SetEdgeColor(0.95, 0.78, 0.32, 1)
    bg:SetEdgeTexture(nil, 1, 1, 4)

    local title = LO_Label(dialog, titleText or "Confirm Delete", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 16)
    title:SetMouseEnabled(false)
    LO_SetHighOverlayDraw(title, 1230)
    title.isPopup = true
    LO_SingleLine(title, 394, 26)

    local body = LO_Label(dialog, bodyText or "Delete this item?", "ZoFontGame", 0.92, 0.94, 0.98, 1)
    body:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 54)
    body:SetDimensions(394, 62)
    body:SetMouseEnabled(false)
    LO_SetHighOverlayDraw(body, 1230)
    body.isPopup = true

    local function cancelDelete()
        LO_CloseDeleteConfirm()
    end

    local function confirmDelete()
        local callback = onConfirm
        LO_CloseDeleteConfirm()
        if callback then callback() end
    end

    local function makeDialogButton(text, tone, onClick)
        local button = WINDOW_MANAGER:CreateControl(nil, dialog, CT_CONTROL)
        button:SetDimensions(120, 34)
        button:SetMouseEnabled(true)
        LO_SetHighOverlayDraw(button, 1220)
        button.isPopup = true

        local buttonBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
        buttonBg:SetAnchorFill(button)
        buttonBg:SetMouseEnabled(false)
        buttonBg:SetEdgeTexture(nil, 1, 1, 1)
        LO_SetHighOverlayDraw(buttonBg, 1221)
        buttonBg.isPopup = true

        local buttonLabel = LO_Label(button, text or "", "ZoFontGameBold", 1, 1, 1, 1)
        buttonLabel:SetAnchor(CENTER, button, CENTER, 0, 0)
        buttonLabel:SetMouseEnabled(false)
        LO_SetHighOverlayDraw(buttonLabel, 1222)
        buttonLabel.isPopup = true

        local function apply(over)
            if tone == "red" then
                if over then
                    buttonBg:SetCenterColor(0.34, 0.04, 0.04, 1)
                    buttonBg:SetEdgeColor(1.00, 0.28, 0.28, 1)
                    buttonLabel:SetColor(1.00, 0.92, 0.92, 1)
                else
                    buttonBg:SetCenterColor(0.18, 0.02, 0.02, 1)
                    buttonBg:SetEdgeColor(0.78, 0.12, 0.12, 1)
                    buttonLabel:SetColor(1.00, 0.82, 0.82, 1)
                end
            else
                if over then
                    buttonBg:SetCenterColor(0.20, 0.20, 0.23, 1)
                    buttonBg:SetEdgeColor(0.70, 0.70, 0.76, 1)
                    buttonLabel:SetColor(1.00, 1.00, 1.00, 1)
                else
                    buttonBg:SetCenterColor(0.10, 0.10, 0.12, 1)
                    buttonBg:SetEdgeColor(0.40, 0.40, 0.46, 1)
                    buttonLabel:SetColor(0.88, 0.88, 0.90, 1)
                end
            end
        end

        button:SetHandler("OnMouseEnter", function() apply(true) end)
        button:SetHandler("OnMouseExit", function() apply(false) end)
        button:SetHandler("OnMouseUp", function() if onClick then onClick() end end)
        apply(false)
        return button
    end

    local cancel = makeDialogButton("Cancel", "gray", cancelDelete)
    cancel:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -148, -18)

    local confirm = makeDialogButton(confirmText or "Delete", "red", confirmDelete)
    confirm:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -18, -18)

    local function handleEscape(_, key)
        if key == KEY_ESCAPE then
            cancelDelete()
            return true
        end
    end
    overlay:SetHandler("OnKeyDown", handleEscape)
    dialog:SetHandler("OnKeyDown", handleEscape)

    local function focusDialogForEscape()
        if dialog and dialog.TakeFocus then
            dialog:TakeFocus()
        elseif overlay and overlay.TakeFocus then
            overlay:TakeFocus()
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(focusDialogForEscape, 1)
    else
        focusDialogForEscape()
    end

    LightsOut.ui.activeDeleteConfirm = {
        overlay = overlay,
        dialog = dialog,
        closed = false,
    }
end

local function LO_DeleteTeamEntry(team, isWar, onChanged)
    if not team then return end

    local source, key = LO_GetTeamStorageInfo(team, isWar)

    if key and source and source[key] == team then
        source[key] = nil
    elseif source then
        for existingKey, entry in pairs(source) do
            if entry == team then
                source[existingKey] = nil
                break
            end
        end
    end

    if LightsOut.ui then
        LightsOut.ui.restoreTeamSetupScrollValue = LO_GetSetupTeamScrollValue()
    end

    if onChanged then onChanged() end
end

local function LO_DeleteTeamGroup(isWar, groupValue, onChanged)
    local saved = LO_Saved()
    local source = isWar and (saved.warTeams or {}) or (saved.items or {})

    for key, entry in pairs(source) do
        if isWar then
            if tostring(entry.furnitureDataId or entry.itemName or "Unknown") == tostring(groupValue or "Unknown") then
                source[key] = nil
            end
        else
            if (tonumber(entry.matchingCount or 0) or 0) == (tonumber(groupValue or 0) or 0) then
                source[key] = nil
            end
        end
    end

    if LightsOut.ui then
        LightsOut.ui.restoreTeamSetupScrollValue = 0
        if not isWar then
            LightsOut.ui.nonWarSetupCountFilter = nil
        end
    end

    if onChanged then onChanged() end
end

local function LO_CreateDeleteButton(parent, tooltipText, onClicked)
    local button = LO_Button(parent, "X", 28, 24, "red")
    if button.SetHandler then button:SetHandler("OnClicked", onClicked) end
    LO_Tooltip(button, tooltipText or "Delete")
    return button
end

local function LO_GridHeader(parent, y, w, isWar, isStatus)
    local header = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    header:SetDimensions(w, 24)
    header:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, y)
    local team = LO_Label(header, "TEAM", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
    team:SetAnchor(LEFT, header, LEFT, isWar and 18 or 44, 0)
    LO_SingleLine(team, 150, 20)
    if isStatus then
        local count = LO_Label(header, "COUNT", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        count:SetAnchor(LEFT, header, LEFT, isWar and math.max(210, w - 330) or 210, 0)
        LO_SingleLine(count, 52, 20)
        LO_SetRight(count)
        local percent = LO_Label(header, "%", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        percent:SetAnchor(LEFT, header, LEFT, isWar and math.max(270, w - 265) or 270, 0)
        LO_SingleLine(percent, 58, 20)
        LO_SetRight(percent)
        if not isWar then
            local item = LO_Label(header, "ITEM", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
            item:SetAnchor(LEFT, header, LEFT, 340, 0)
            LO_SingleLine(item, math.max(260, math.max(620, w - 180) - 350), 20)
        end
        local state = LO_Label(header, "STATE", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        state:SetAnchor(LEFT, header, LEFT, isWar and math.max(340, w - 190) or math.max(620, w - 180), 0)
        LO_SingleLine(state, 120, 20)
    else
        if not isWar then
            -- Non-War setup no longer has a COUNT column; teams are grouped by
            -- instance count instead. Keep this header aligned with LO_SetupRow.
            local item = LO_Label(header, "ITEM", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
            item:SetAnchor(LEFT, header, LEFT, 220, 0)
            LO_SingleLine(item, math.max(330, w - 585), 20)
        end
        local state = LO_Label(header, "STATE", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        state:SetAnchor(LEFT, header, LEFT, isWar and math.max(220, w - 250) or math.max(600, w - 270), 0)
        LO_SingleLine(state, 120, 20)
        local enabled = LO_Label(header, "ENABLED", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        enabled:SetAnchor(RIGHT, header, RIGHT, -42, 0)
        LO_SingleLine(enabled, 82, 20)
        local delete = LO_Label(header, "DEL", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
        delete:SetAnchor(RIGHT, header, RIGHT, -4, 0)
        LO_SingleLine(delete, 32, 20)
    end
end

local function LO_SetupRow(parent, team, y, w, isWar, onChanged)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(w, isWar and 34 or 38)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, y)
    if LightsOut.ui then
        LightsOut.ui.setupRows = LightsOut.ui.setupRows or {}
        LightsOut.ui.setupRows[team] = LightsOut.ui.setupRows[team] or { row = row, team = team, isWar = isWar }
    end
    local currentMode = isWar and "war" or LO_NormalizeModeKey(LO_CP().selectedMode)
    local toggle = LO_Toggle(row, LO_IsTeamEnabledForMode(team, currentMode), function(value)
        LO_SetTeamEnabledForMode(team, currentMode, value)
        if isWar and value == true then
            for _, other in pairs(LO_Saved().warTeams or {}) do
                if other ~= team and tonumber(other.furnitureDataId) ~= tonumber(team.furnitureDataId) then
                    LO_SetTeamEnabledForMode(other, "war", false)
                end
            end
        elseif not isWar and value == true then
            local selectedCount = tonumber(team.matchingCount or 0) or 0

            for _, other in pairs(LO_Saved().items or {}) do
                if other ~= team then
                    local otherCount = tonumber(other.matchingCount or 0) or 0

                    if LO_IsTeamEnabledForMode(other, currentMode) and otherCount ~= selectedCount then
                        for _, reset in pairs(LO_Saved().items or {}) do
                            LO_SetTeamEnabledForMode(reset, currentMode, false)
                        end
                        break
                    end
                end
            end

            LO_SetTeamEnabledForMode(team, currentMode, true)
        end
        if onChanged then onChanged() end
    end)
    toggle:SetAnchor(RIGHT, row, RIGHT, -42, 0)

    local deleteButton = LO_CreateDeleteButton(row, "Delete team", function()
        local teamLabel = tostring(team.name or team.key or "this team")
        LO_ShowDeleteConfirm(
            "Delete Team",
            "Delete team \"" .. teamLabel .. "\"? This cannot be undone.",
            "Delete",
            function()
                LO_DeleteTeamEntry(team, isWar, onChanged)
            end
        )
    end)
    deleteButton:SetAnchor(RIGHT, row, RIGHT, -8, 0)

    if isWar then
        local teamName = LO_Label(row, tostring(team.name or ""), "ZoFontGameBold", 0.70, 0.90, 1.0, 1)
        teamName:SetAnchor(LEFT, row, LEFT, 18, 0)
        LO_SingleLine(teamName, math.max(160, w - 300), 24)
        LO_MakeTeamNameEditable(teamName, team, true, math.max(160, w - 300), 24)
        LO_Tooltip(teamName, tostring(LO_GetTeamNameForMode(team, "war", true) or team.name or team.key or "Unknown Team"))
        local state = LO_Label(row, tostring(team.stateName or ""), "ZoFontGame", 0.88, 0.90, 0.95, 1)
        state:SetAnchor(LEFT, row, LEFT, math.max(220, w - 250), 0)
        LO_SingleLine(state, 150, 24)
        LO_MakeStateEditable(state, team, true, 150, 24)
        if LightsOut.ui and LightsOut.ui.setupRows and LightsOut.ui.setupRows[team] then
            LightsOut.ui.setupRows[team].nameLabel = teamName
            LightsOut.ui.setupRows[team].stateLabel = state
        end
        return
    end

    local iconBox = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    iconBox:SetDimensions(30, 30)
    iconBox:SetAnchor(LEFT, row, LEFT, 0, 0)
    iconBox:SetCenterColor(0.06, 0.06, 0.06, 0.95)
    iconBox:SetEdgeColor(0.45, 0.36, 0.22, 0.9)
    iconBox:SetEdgeTexture(nil, 1, 1, 1)
    local icon = WINDOW_MANAGER:CreateControl(nil, iconBox, CT_TEXTURE)
    icon:SetDimensions(22, 22)
    icon:SetAnchor(CENTER, iconBox, CENTER, 0, 0)
    icon:SetTexture(team.icon or "EsoUI/Art/Inventory/inventory_tabIcon_furnishing_up.dds")
    local teamName = LO_Label(row, tostring(team.name or ""), "ZoFontGameBold", 0.70, 0.90, 1.0, 1)
    teamName:SetAnchor(LEFT, row, LEFT, 44, 0)
    LO_SingleLine(teamName, 170, 24)
    LO_MakeTeamNameEditable(teamName, team, false, 170, 24)
    LO_Tooltip(teamName, tostring(LO_GetTeamNameForMode(team, nil, false) or team.name or team.key or "Unknown Team"))
    local item = LO_Label(row, tostring(team.itemName or ""), "ZoFontGame", 0.82, 0.86, 0.92, 1)
    item:SetAnchor(LEFT, row, LEFT, 220, 0)
    LO_SingleLine(item, math.max(330, w - 585), 24)
    LO_Tooltip(item, tostring(team.itemName or ""))
    local state = LO_Label(row, tostring(team.stateName or ""), "ZoFontGame", 0.88, 0.90, 0.95, 1)
    state:SetAnchor(LEFT, row, LEFT, math.max(600, w - 270), 0)
    LO_SingleLine(state, 160, 24)
    LO_MakeStateEditable(state, team, false, 160, 24)
    if LightsOut.ui and LightsOut.ui.setupRows and LightsOut.ui.setupRows[team] then
        LightsOut.ui.setupRows[team].nameLabel = teamName
        LightsOut.ui.setupRows[team].stateLabel = state
    end
end


local function LO_GetNonWarInstanceCounts(teams)
    local teamsPerPlacementCount = {}
    local seenSupportedCounts = {}
    local counts = {}

    -- Keep the function name for compatibility, but the values now represent
    -- minimum "Supported Teams" values. Each matchingCount group contributes
    -- one supported-team total.
    for _, team in ipairs(teams or {}) do
        local placedCount = tonumber(team.matchingCount or 0) or 0
        teamsPerPlacementCount[placedCount] = (teamsPerPlacementCount[placedCount] or 0) + 1
    end

    for _, supportedCount in pairs(teamsPerPlacementCount) do
        supportedCount = tonumber(supportedCount or 0) or 0
        if supportedCount > 0 and not seenSupportedCounts[supportedCount] then
            seenSupportedCounts[supportedCount] = true
            table.insert(counts, supportedCount)
        end
    end

    table.sort(counts, function(a, b) return a < b end)
    return counts
end

local function LO_GetWarSupportedTeamCounts(teams)
    local seen = {}
    local counts = {}

    for _, team in ipairs(teams or {}) do
        local supportedCount = tonumber(team.numStates or 0) or 0
        if supportedCount > 0 and not seen[supportedCount] then
            seen[supportedCount] = true
            table.insert(counts, supportedCount)
        end
    end

    table.sort(counts, function(a, b) return a < b end)
    return counts
end

local function LO_ApplyNonWarSetupFilters(teams)
    local filtered = {}
    local searchText = LightsOut.ui and LightsOut.ui.nonWarSetupSearchText or ""
    searchText = string.lower(tostring(searchText or ""):match("^%s*(.-)%s*$"))

    -- The text search filter wins over the minimum-supported-teams filter.
    -- It checks Team, Item, and State names using partial matches.
    if searchText ~= "" then
        if LightsOut.ui then LightsOut.ui.nonWarSetupCountFilter = nil end

        for _, team in ipairs(teams or {}) do
            local teamName = string.lower(tostring(team.name or team.key or ""))
            local itemName = string.lower(tostring(team.itemName or ""))
            local stateName = string.lower(tostring(team.stateName or ""))

            if string.find(teamName, searchText, 1, true)
                or string.find(itemName, searchText, 1, true)
                or string.find(stateName, searchText, 1, true) then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    local countFilter = LightsOut.ui and tonumber(LightsOut.ui.nonWarSetupCountFilter) or nil
    if countFilter ~= nil then
        local teamsPerPlacementCount = {}

        for _, team in ipairs(teams or {}) do
            local placedCount = tonumber(team.matchingCount or 0) or 0
            teamsPerPlacementCount[placedCount] = (teamsPerPlacementCount[placedCount] or 0) + 1
        end

        for _, team in ipairs(teams or {}) do
            local placedCount = tonumber(team.matchingCount or 0) or 0
            local supportedCount = tonumber(teamsPerPlacementCount[placedCount] or 0) or 0

            -- Minimum Supported Teams filter:
            -- selecting 2 shows 2+, selecting 3 shows 3+, etc.
            if supportedCount >= countFilter then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    for _, team in ipairs(teams or {}) do
        table.insert(filtered, team)
    end

    return filtered
end

local function LO_ApplyWarSetupFilters(teams)
    local filtered = {}
    local searchText = LightsOut.ui and LightsOut.ui.nonWarSetupSearchText or ""
    searchText = string.lower(tostring(searchText or ""):match("^%s*(.-)%s*$"))

    -- War text search uses the shared Text Search value, filters by item name,
    -- and keeps all status/team rows for matching item groups.
    if searchText ~= "" then
        if LightsOut.ui then LightsOut.ui.nonWarSetupCountFilter = nil end

        for _, team in ipairs(teams or {}) do
            local itemName = string.lower(tostring(team.itemName or ""))

            if string.find(itemName, searchText, 1, true) then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    local countFilter = LightsOut.ui and tonumber(LightsOut.ui.nonWarSetupCountFilter) or nil
    if countFilter ~= nil then
        for _, team in ipairs(teams or {}) do
            local supportedCount = tonumber(team.numStates or 0) or 0

            -- Minimum Supported Teams filter:
            -- selecting 2 shows 2+, selecting 3 shows 3+, etc.
            if supportedCount >= countFilter then
                table.insert(filtered, team)
            end
        end

        return filtered
    end

    for _, team in ipairs(teams or {}) do
        table.insert(filtered, team)
    end

    return filtered
end

local function LO_RebuildTeamSetupForFilterChange()
    if LightsOut.ui then
        LightsOut.ui.restoreTeamSetupScrollValue = 0
    end

    if type(LightsOut.RebuildControlPanel) == "function" then
        LightsOut.RebuildControlPanel()
    elseif type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
        LightsOut.RefreshControlPanelForTeamChange()
    end
end

local function LO_RebuildTeamSetupForSearchTextChange()
    LightsOut.ui = LightsOut.ui or {}
    LightsOut.ui.restoreTeamSetupScrollValue = 0
    LightsOut.ui.nonWarSetupSearchChangeVersion = (LightsOut.ui.nonWarSetupSearchChangeVersion or 0) + 1

    local version = LightsOut.ui.nonWarSetupSearchChangeVersion

    local function rebuild()
        if not LightsOut.ui or LightsOut.ui.nonWarSetupSearchChangeVersion ~= version then return end
        if type(LightsOut.RebuildControlPanel) == "function" then
            LightsOut.RebuildControlPanel()
        elseif type(LightsOut.RefreshControlPanelForTeamChange) == "function" then
            LightsOut.RefreshControlPanelForTeamChange()
        end

        -- The panel rebuild replaces the edit box. Return focus to the new
        -- search box so typing can continue after the filtered list refreshes.
        local box = LightsOut.ui and LightsOut.ui.nonWarSetupSearchBox
        if box and box.TakeFocus then
            box:TakeFocus()
        end
    end

    -- A tiny debounce lets ESO finish updating the edit box text before the
    -- team list is rebuilt. Rebuilding immediately on every key press can make
    -- the edit box feel like it will not accept typing.
    if type(zo_callLater) == "function" then
        zo_callLater(rebuild, 80)
    else
        rebuild()
    end
end

local function LO_CreateSmallClearButton(parent, text, w, h, onClicked)
    local button = LO_Button(parent, text or "X", w or 28, h or 24, "gray")
    button:SetHandler("OnClicked", onClicked)
    return button
end

local function LO_CreateSetupFilters(shell, teams, isWar, x, y, w)
    LightsOut.ui = LightsOut.ui or {}

    local counts = isWar and LO_GetWarSupportedTeamCounts(teams) or LO_GetNonWarInstanceCounts(teams)
    local currentCount = tonumber(LightsOut.ui.nonWarSetupCountFilter)
    local searchText = tostring(LightsOut.ui.nonWarSetupSearchText or "")
    local searchActive = searchText:match("^%s*(.-)%s*$") ~= ""

    if searchActive then
        currentCount = nil
        LightsOut.ui.nonWarSetupCountFilter = nil
    end

    local filterLabel = LO_Label(shell, "Minimum Supported Teams", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
    filterLabel:SetAnchor(TOPLEFT, shell, TOPLEFT, x, y - 14)
    LO_SingleLine(filterLabel, 190, 18)

    local countBox = LO_Panel(shell, x, y, 178, 30)
    local countText = LO_Label(countBox, currentCount and tostring(currentCount) or "All", "ZoFontGameBold", 1, 1, 1, searchActive and 0.45 or 1)
    countText:SetAnchor(CENTER, countBox, CENTER, 0, 0)
    LO_SingleLine(countText, 70, 22)

    local prev = LO_Button(countBox, "<", 28, 22, "gray")
    prev:SetAnchor(LEFT, countBox, LEFT, 5, 0)
    prev:SetHandler("OnClicked", function()
        if #counts == 0 then return end

        local selectedIndex = 1

        if currentCount ~= nil then
            for i, value in ipairs(counts) do
                if value == currentCount then
                    selectedIndex = i - 1
                    break
                end
            end
        end

        if selectedIndex < 1 then selectedIndex = #counts end

        LightsOut.ui.nonWarSetupSearchText = ""
        LightsOut.ui.nonWarSetupCountFilter = counts[selectedIndex]
        LO_RebuildTeamSetupForFilterChange()
    end)

    local next = LO_Button(countBox, ">", 28, 22, "gray")
    next:SetAnchor(RIGHT, countBox, RIGHT, -34, 0)
    next:SetHandler("OnClicked", function()
        if #counts == 0 then return end

        local selectedIndex = 1

        if currentCount ~= nil then
            for i, value in ipairs(counts) do
                if value == currentCount then
                    selectedIndex = i + 1
                    break
                end
            end
        end

        if selectedIndex > #counts then selectedIndex = 1 end

        LightsOut.ui.nonWarSetupSearchText = ""
        LightsOut.ui.nonWarSetupCountFilter = counts[selectedIndex]
        LO_RebuildTeamSetupForFilterChange()
    end)

    local clearCount = LO_CreateSmallClearButton(countBox, "X", 24, 22, function()
        LightsOut.ui.nonWarSetupCountFilter = nil
        LO_RebuildTeamSetupForFilterChange()
    end)
    clearCount:SetAnchor(RIGHT, countBox, RIGHT, -5, 0)

    local searchLabel = LO_Label(shell, "Text Search", "ZoFontGameSmall", 0.85, 0.85, 0.78, 1)
    searchLabel:SetAnchor(TOPLEFT, shell, TOPLEFT, x + 195, y - 14)
    LO_SingleLine(searchLabel, 120, 18)

    local searchBg = LO_Panel(shell, x + 195, y, math.max(260, w - 250), 30)
    local searchBox = WINDOW_MANAGER:CreateControl(nil, searchBg, CT_EDITBOX)
    searchBox:SetAnchor(TOPLEFT, searchBg, TOPLEFT, 8, 3)
    searchBox:SetAnchor(BOTTOMRIGHT, searchBg, BOTTOMRIGHT, -6, -3)
    searchBox:SetFont("ZoFontGameBold")
    if searchBox.SetVerticalAlignment and TEXT_ALIGN_CENTER then searchBox:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    searchBox:SetText(searchText)
    searchBox:SetMaxInputChars(80)
    searchBox:SetMouseEnabled(true)
    searchBox:SetEditEnabled(true)
    searchBox:SetSelectAllOnFocus(false)
    if searchBox.SetDrawLayer and DL_CONTROLS then searchBox:SetDrawLayer(DL_CONTROLS) end
    if searchBox.SetDrawTier and DT_HIGH then searchBox:SetDrawTier(DT_HIGH) end
    if searchBox.SetDrawLevel then searchBox:SetDrawLevel(10) end
    LightsOut.ui.nonWarSetupSearchBox = searchBox

    searchBox:SetHandler("OnMouseUp", function(self)
        if self and self.TakeFocus then self:TakeFocus() end
    end)

    local function normalizeSearchText(value)
        return tostring(value or ""):match("^%s*(.-)%s*$") or ""
    end

    searchBox:SetHandler("OnTextChanged", function(self)
        if not (LightsOut.ui and self and self.GetText) then return end

        local value = normalizeSearchText(self:GetText())
        LightsOut.ui.nonWarSetupSearchText = value

        -- Text Search and Minimum Supported Teams are mutually exclusive.
        if value ~= "" then
            LightsOut.ui.nonWarSetupCountFilter = nil
        end

        LO_RebuildTeamSetupForSearchTextChange()
    end)

    searchBox:SetHandler("OnEnter", function(self)
        if self and self.LoseFocus then self:LoseFocus() end
    end)

    searchBox:SetHandler("OnFocusLost", function(self)
        if not (LightsOut.ui and self and self.GetText) then return end
        LightsOut.ui.nonWarSetupSearchText = normalizeSearchText(self:GetText())
    end)

    searchBox:SetHandler("OnEscape", function()
        LightsOut.ui.nonWarSetupSearchText = ""
        searchBox:SetText("")
        if searchBox.LoseFocus then searchBox:LoseFocus() end
        LO_RebuildTeamSetupForFilterChange()
    end)

    local clearSearch = LO_CreateSmallClearButton(shell, "X", 28, 30, function()
        LightsOut.ui.nonWarSetupSearchText = ""
        if LightsOut.ui.nonWarSetupSearchBox and LightsOut.ui.nonWarSetupSearchBox.SetText then
            LightsOut.ui.nonWarSetupSearchBox:SetText("")
        end
        LO_RebuildTeamSetupForFilterChange()
    end)
    clearSearch:SetAnchor(TOPLEFT, searchBg, TOPRIGHT, 4, 0)
end

-- Backward-compatible wrapper in case any later code still calls the old name.
local function LO_CreateNonWarSetupFilters(shell, teams, x, y, w)
    LO_CreateSetupFilters(shell, teams, false, x, y, w)
end

local function LO_CreateNonWarSetupGroupHeader(parent, teams, itemCount, y, w, onChanged)
    local header = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    header:SetDimensions(w, 34)
    header:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, y)

    local bg = WINDOW_MANAGER:CreateControl(nil, header, CT_BACKDROP)
    bg:SetAnchorFill(header)
    bg:SetCenterColor(0.06, 0.055, 0.04, 0.92)
    bg:SetEdgeColor(0.55, 0.45, 0.26, 0.85)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local currentMode = LO_NormalizeModeKey(LO_CP().selectedMode)
    local groupTotal = 0
    local groupEnabled = 0
    for _, team in ipairs(teams or {}) do
        if (tonumber(team.matchingCount or 0) or 0) == itemCount then
            groupTotal = groupTotal + 1
            if LO_IsTeamEnabledForMode(team, currentMode) then
                groupEnabled = groupEnabled + 1
            end
        end
    end

    local label = LO_Label(
        header,
        zo_strformat("|c66CCFF<<1>>|r Team(s) Supported, |c66CCFF<<2>>|r Furnishing(s) Placed", tostring(groupTotal), tostring(itemCount)),
        "ZoFontGameBold",
        1.0, 0.88, 0.55, 1
    )
    label:SetAnchor(LEFT, header, LEFT, 12, 0)
    LO_SingleLine(label, math.max(220, w - 160), 24)

    local anyEnabled = groupEnabled > 0
    local partialEnabled = groupEnabled > 0 and groupEnabled < groupTotal

    local toggle = LO_Toggle(header, anyEnabled, function(value)
        local saved = LO_Saved()
        for _, entry in pairs(saved.items or {}) do
            local entryCount = tonumber(entry.matchingCount or 0) or 0
            if entryCount == itemCount then
                LO_SetTeamEnabledForMode(entry, currentMode, value == true)
            elseif value == true then
                -- Non-War games require all enabled teams to have the same item count.
                LO_SetTeamEnabledForMode(entry, currentMode, false)
            end
        end

        if onChanged then onChanged() end
    end)
    if toggle.SetLightsOutPartial then
        toggle:SetLightsOutPartial(partialEnabled)
    end
    toggle:SetAnchor(RIGHT, header, RIGHT, -42, 0)

    local deleteButton = LO_CreateDeleteButton(header, "Delete this instance-count group", function()
        LO_ShowDeleteConfirm(
            "Delete Group",
            "Delete all " .. tostring(itemCount) .. " copy item teams? This cannot be undone.",
            "Delete",
            function()
                LO_DeleteTeamGroup(false, itemCount, onChanged)
            end
        )
    end)
    deleteButton:SetAnchor(RIGHT, header, RIGHT, -8, 0)

    return header
end

local function LO_StatusRow(parent, team, y, w, isWar)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(w, isWar and 34 or 38)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, y)
    local mode = isWar and "war" or ((LightsOut.game and LightsOut.game.mode) or LO_CP().selectedMode or "threshold")
    local active = tonumber(team.currentWinCount or 0) or 0
    local pct = LO_TeamPercent(team, mode)
    local rowKey = tostring(team.key or team.name or team.furnitureDataId or "")

    if LightsOut.ui then
        LightsOut.ui.statusRows = LightsOut.ui.statusRows or {}
        LightsOut.ui.statusRows[rowKey] = {
            team = team,
            mode = mode,
            isWar = isWar,
        }
    end

    if isWar then
        local teamName = LO_Label(row, tostring(team.name or ""), "ZoFontGameBold", 0.70, 0.90, 1.0, 1)
        teamName:SetAnchor(LEFT, row, LEFT, 18, 0)
        LO_SingleLine(teamName, math.max(120, w - 360), 24)
        LO_MakeTeamNameEditable(teamName, team, true, math.max(120, w - 360), 24)
        local count = LO_Label(row, tostring(active), "ZoFontGame", 0.90, 0.90, 0.90, 1)
        count:SetAnchor(LEFT, row, LEFT, math.max(210, w - 330), 0)
        LO_SingleLine(count, 52, 24)
        LO_SetRight(count)
        local percent = LO_Label(row, tostring(pct) .. "%", "ZoFontGame", 0.90, 0.90, 0.90, 1)
        percent:SetAnchor(LEFT, row, LEFT, math.max(270, w - 265), 0)
        LO_SingleLine(percent, 58, 24)
        LO_SetRight(percent)
        if LightsOut.ui and LightsOut.ui.statusRows and LightsOut.ui.statusRows[rowKey] then
            LightsOut.ui.statusRows[rowKey].nameLabel = teamName
            LightsOut.ui.statusRows[rowKey].countLabel = count
            LightsOut.ui.statusRows[rowKey].percentLabel = percent
        end
        local state = LO_Label(row, tostring(team.stateName or ""), "ZoFontGame", 0.88, 0.90, 0.95, 1)
        state:SetAnchor(LEFT, row, LEFT, math.max(340, w - 190), 0)
        LO_SingleLine(state, 150, 24)
        if LightsOut.ui and LightsOut.ui.statusRows and LightsOut.ui.statusRows[rowKey] then
            LightsOut.ui.statusRows[rowKey].stateLabel = state
        end
        return
    end

    local iconBox = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    iconBox:SetDimensions(30, 30)
    iconBox:SetAnchor(LEFT, row, LEFT, 0, 0)
    iconBox:SetCenterColor(0.06, 0.06, 0.06, 0.95)
    iconBox:SetEdgeColor(0.45, 0.36, 0.22, 0.9)
    iconBox:SetEdgeTexture(nil, 1, 1, 1)
    local icon = WINDOW_MANAGER:CreateControl(nil, iconBox, CT_TEXTURE)
    icon:SetDimensions(22, 22)
    icon:SetAnchor(CENTER, iconBox, CENTER, 0, 0)
    icon:SetTexture(team.icon or "EsoUI/Art/Inventory/inventory_tabIcon_furnishing_up.dds")
    local teamName = LO_Label(row, tostring(team.name or ""), "ZoFontGameBold", 0.70, 0.90, 1.0, 1)
    teamName:SetAnchor(LEFT, row, LEFT, 44, 0)
    LO_SingleLine(teamName, 160, 24)
    LO_MakeTeamNameEditable(teamName, team, false, 160, 24)
    local count = LO_Label(row, tostring(active), "ZoFontGame", 0.90, 0.90, 0.90, 1)
    count:SetAnchor(LEFT, row, LEFT, 210, 0)
    LO_SingleLine(count, 52, 24)
    LO_SetRight(count)
    local percent = LO_Label(row, tostring(pct) .. "%", "ZoFontGame", 0.90, 0.90, 0.90, 1)
    percent:SetAnchor(LEFT, row, LEFT, 270, 0)
    LO_SingleLine(percent, 58, 24)
    LO_SetRight(percent)
    if LightsOut.ui and LightsOut.ui.statusRows and LightsOut.ui.statusRows[rowKey] then
        LightsOut.ui.statusRows[rowKey].nameLabel = teamName
        LightsOut.ui.statusRows[rowKey].countLabel = count
        LightsOut.ui.statusRows[rowKey].percentLabel = percent
    end
    local item = LO_Label(row, tostring(team.itemName or ""), "ZoFontGame", 0.82, 0.86, 0.92, 1)
    item:SetAnchor(LEFT, row, LEFT, 340, 0)
    LO_SingleLine(item, math.max(260, math.max(620, w - 180) - 350), 24)
    LO_Tooltip(item, tostring(team.itemName or ""))
    local state = LO_Label(row, tostring(team.stateName or ""), "ZoFontGame", 0.88, 0.90, 0.95, 1)
    state:SetAnchor(LEFT, row, LEFT, math.max(620, w - 180), 0)
    LO_SingleLine(state, 160, 24)
    if LightsOut.ui and LightsOut.ui.statusRows and LightsOut.ui.statusRows[rowKey] then
        LightsOut.ui.statusRows[rowKey].stateLabel = state
    end
end

local function LO_CreateTeamScroll(parent, teams, isWar, x, y, w, h, onChanged)
    if LightsOut.ui then
        LightsOut.ui.setupRows = {}
    end

    local shell = LO_Panel(parent, x, y, w, h)
    local headerTop = isWar and 10 or 16
    local filterTop = 28
    local noteTop = 62
    local dividerTop = 92
    local stickyHeaderTop = 104
    local scrollTop = isWar and 104 or 130

    local headerCenterY = filterTop + 15

    local title = LO_Label(shell, isWar and "AVAILABLE WAR TEAMS" or "AVAILABLE TEAMS", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    title:SetAnchor(LEFT, shell, TOPLEFT, 12, headerCenterY)
    if title.SetVerticalAlignment and TEXT_ALIGN_CENTER then title:SetVerticalAlignment(TEXT_ALIGN_CENTER) end

    local count = LO_Label(shell, tostring(LO_CountEnabled(teams)) .. " Enabled", "ZoFontGameBold", 0.55, 0.95, 1, 1)
    count:SetAnchor(RIGHT, shell, TOPRIGHT, -18, headerCenterY)
    if count.SetVerticalAlignment and TEXT_ALIGN_CENTER then count:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    local note = LO_Label(shell, isWar and "War mode allows only one item type active at a time, but as many teams as their are states." or "Only enabled teams are included when the game starts. Teams must be within the same instance count.", "ZoFontGameSmall", 0.75, 0.78, 0.82, 1)
    note:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, noteTop)
    note:SetDimensions(w - 32, 34)

    if isWar then
        -- War filters use the same layout as non-War filters.  The text search
        -- filters by item name and keeps the matching item group/status rows.
        LO_CreateSetupFilters(shell, teams, true, 235, filterTop, w - 480)

        local divider = WINDOW_MANAGER:CreateControl(nil, shell, CT_BACKDROP)
        divider:SetDimensions(w - 24, 1)
        divider:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, dividerTop)
        divider:SetCenterColor(0.55, 0.45, 0.26, 0.45)
        divider:SetEdgeColor(0, 0, 0, 0)
    else
        -- Minimum-supported-teams filter and text search are mutually exclusive.
        -- Text search wins and automatically clears the count filter when applied.
        -- The extra vertical padding keeps the header/filter row from looking cramped.
        LO_CreateSetupFilters(shell, teams, false, 235, filterTop, w - 480)

        local divider = WINDOW_MANAGER:CreateControl(nil, shell, CT_BACKDROP)
        divider:SetDimensions(w - 24, 1)
        divider:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, dividerTop)
        divider:SetCenterColor(0.55, 0.45, 0.26, 0.45)
        divider:SetEdgeColor(0, 0, 0, 0)
    end

    local gridWidth = w - 58

    -- Keep the Non-War column labels sticky above the scrolling team rows.
    -- Group headers stay inside the scroll because they belong to each count group.
    if not isWar then
        local stickyHeader = WINDOW_MANAGER:CreateControl(nil, shell, CT_CONTROL)
        stickyHeader:SetDimensions(gridWidth + 20, 24)
        stickyHeader:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, stickyHeaderTop)
        LO_GridHeader(stickyHeader, 0, gridWidth, false, false)
    end

    local scroll = WINDOW_MANAGER:CreateControlFromVirtual(LO_UniqueControlName("LightsOutTeamSetupScroll"), shell, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, scrollTop)
    scroll:SetAnchor(BOTTOMRIGHT, shell, BOTTOMRIGHT, -12, -12)
    local child = scroll:GetNamedChild("ScrollChild")
    local displayTeams = LO_SortedTeams(isWar and LO_ApplyWarSetupFilters(teams) or LO_ApplyNonWarSetupFilters(teams), isWar)
    local yPos = 4
    local lastCount, lastGroupKey = nil, nil
    for _, team in ipairs(displayTeams) do
        if isWar then
            local groupKey = tostring(team.furnitureDataId or team.itemName or "Unknown")
            if groupKey ~= lastGroupKey then
                if lastGroupKey ~= nil then
                    yPos = yPos + 10
                    local line = WINDOW_MANAGER:CreateControl(nil, child, CT_BACKDROP)
                    line:SetDimensions(w - 72, 2)
                    line:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                    line:SetCenterColor(0.55, 0.45, 0.26, 0.85)
                    line:SetEdgeColor(0, 0, 0, 0)
                    yPos = yPos + 18
                end
                local icon = WINDOW_MANAGER:CreateControl(nil, child, CT_TEXTURE)
                icon:SetDimensions(22, 22)
                icon:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                icon:SetTexture(team.icon or "EsoUI/Art/Inventory/inventory_tabIcon_furnishing_up.dds")
                local group = LO_Label(child, zo_strformat("<<1>> - |c66CCFF<<2>>|r Team(s) Supported, |c66CCFF<<3>>|r Furnishing(s) Placed", tostring(team.itemName or "Unknown Item"), tostring(team.numStates or 0), tostring(team.matchingCount or 0)), "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
        LO_AddHeaderBox(row)
                group:SetAnchor(LEFT, icon, RIGHT, 8, 0)
                LO_SingleLine(group, w - 230, 24)
                LO_Tooltip(group, tostring(team.itemName or "Unknown Item"))

                local groupEnabledCount = 0
                local groupTeamCount = 0
                for _, groupTeam in ipairs(displayTeams or {}) do
                    if tostring(groupTeam.furnitureDataId or groupTeam.itemName or "Unknown") == groupKey then
                        groupTeamCount = groupTeamCount + 1
                        if LO_IsTeamEnabledForMode(groupTeam, "war") then
                            groupEnabledCount = groupEnabledCount + 1
                        end
                    end
                end

                local groupAnyEnabled = groupEnabledCount > 0
                local groupPartiallyEnabled = groupEnabledCount > 0 and groupEnabledCount < groupTeamCount

                local groupToggle = LO_Toggle(child, groupAnyEnabled, function(value)
                    local saved = LO_Saved()
                    for _, entry in pairs(saved.warTeams or {}) do
                        local entryGroupKey = tostring(entry.furnitureDataId or entry.itemName or "Unknown")
                        if entryGroupKey == groupKey then
                            LO_SetTeamEnabledForMode(entry, "war", value == true)
                        elseif value == true then
                            -- War mode allows only one furnishing type to be active at a time.
                            LO_SetTeamEnabledForMode(entry, "war", false)
                        end
                    end

                    if onChanged then onChanged() end
                end)
                groupToggle:SetAnchor(TOPRIGHT, child, TOPLEFT, gridWidth - 32, yPos - 2)
                if groupToggle.SetLightsOutPartial then
                    groupToggle:SetLightsOutPartial(groupPartiallyEnabled)
                end

                local deleteGroupButton = LO_CreateDeleteButton(child, "Delete this item group", function()
                    local itemLabel = tostring(team.itemName or "this item group")
                    LO_ShowDeleteConfirm(
                        "Delete Group",
                        "Delete all War teams for \"" .. itemLabel .. "\"? This cannot be undone.",
                        "Delete",
                        function()
                            LO_DeleteTeamGroup(true, groupKey, onChanged)
                        end
                    )
                end)
                deleteGroupButton:SetAnchor(TOPRIGHT, child, TOPLEFT, gridWidth + 2, yPos - 1)
                yPos = yPos + 28
                LO_GridHeader(child, yPos, gridWidth, true, false)
                yPos = yPos + 24
                lastGroupKey = groupKey
            end
        else
            local itemCount = tonumber(team.matchingCount or 0) or 0
            if itemCount ~= lastCount then
                if lastCount ~= nil then
                    yPos = yPos + 10
                end
                LO_CreateNonWarSetupGroupHeader(child, displayTeams, itemCount, yPos, gridWidth, onChanged)
                yPos = yPos + 38
                lastCount = itemCount
            end
        end
        LO_SetupRow(child, team, yPos, gridWidth, isWar, onChanged)
        yPos = yPos + (isWar and 36 or 40)
    end
    child:SetDimensions(w - 44, math.max(h - (isWar and 92 or 152), yPos + 10))
    LightsOut.ui.teamSetupScroll = scroll
    if LightsOut.ui.restoreTeamSetupScrollValue ~= nil then
        LO_RestoreSetupTeamScrollValue(LightsOut.ui.restoreTeamSetupScrollValue)
        LightsOut.ui.restoreTeamSetupScrollValue = nil
    end
end

local function LO_CreateStatusScroll(parent, teams, isWar, x, y, w, h)
    if LightsOut.ui then
        LightsOut.ui.statusRows = {}
    end

    local shell = LO_Panel(parent, x, y, w, h)
    local title = LO_Label(shell, isWar and "WAR TEAMS IN GAME" or "TEAMS IN GAME", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    title:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, 10)
    local activeTeams = {}
    for _, team in ipairs(teams or {}) do
        if team.enabled ~= false and (team.trackedFurnitureIds ~= nil or (LightsOut.game and LightsOut.game.active)) then
            table.insert(activeTeams, team)
        end
    end
    local count = LO_Label(shell, tostring(#activeTeams) .. " Playing", "ZoFontGameBold", 0.55, 0.95, 1, 1)
    count:SetAnchor(TOPRIGHT, shell, TOPRIGHT, -18, 10)
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual(LO_UniqueControlName("LightsOutStatusScroll"), shell, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, shell, TOPLEFT, 12, 48)
    scroll:SetAnchor(BOTTOMRIGHT, shell, BOTTOMRIGHT, -12, -12)
    local child = scroll:GetNamedChild("ScrollChild")
    local displayTeams = LO_SortedTeams(activeTeams, isWar)
    local yPos = 4
    local gridWidth = w - 58
    local lastCount, lastGroupKey = nil, nil
    for _, team in ipairs(displayTeams) do
        if isWar then
            local groupKey = tostring(team.furnitureDataId or team.itemName or "Unknown")
            if groupKey ~= lastGroupKey then
                if lastGroupKey ~= nil then
                    yPos = yPos + 18
                    local line = WINDOW_MANAGER:CreateControl(nil, child, CT_BACKDROP)
                    line:SetDimensions(w - 72, 2)
                    line:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                    line:SetCenterColor(0.55, 0.45, 0.26, 0.85)
                    line:SetEdgeColor(0, 0, 0, 0)
                    yPos = yPos + 18
                end
                local icon = WINDOW_MANAGER:CreateControl(nil, child, CT_TEXTURE)
                icon:SetDimensions(22, 22)
                icon:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                icon:SetTexture(team.icon or "EsoUI/Art/Inventory/inventory_tabIcon_furnishing_up.dds")
                local group = LO_Label(child, zo_strformat("<<1>> - |c66CCFF<<2>>|r placement(s), |c66CCFF<<3>>|r status(s)", tostring(team.itemName or "Unknown Item"), tostring(team.matchingCount or 0), tostring(team.numStates or 0)), "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
        LO_AddHeaderBox(row)
                group:SetAnchor(LEFT, icon, RIGHT, 8, 0)
                LO_SingleLine(group, w - 120, 24)
                LO_Tooltip(group, tostring(team.itemName or "Unknown Item"))
                yPos = yPos + 30
                LO_GridHeader(child, yPos, gridWidth, true, true)
                yPos = yPos + 24
                lastGroupKey = groupKey
            end
        else
            local itemCount = tonumber(team.matchingCount or 0) or 0
            if itemCount ~= lastCount then
                if lastCount ~= nil then
                    yPos = yPos + 10
                    local line = WINDOW_MANAGER:CreateControl(nil, child, CT_BACKDROP)
                    line:SetDimensions(w - 72, 2)
                    line:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                    line:SetCenterColor(0.55, 0.45, 0.26, 0.85)
                    line:SetEdgeColor(0, 0, 0, 0)
                    yPos = yPos + 18
                end
                local group = LO_Label(child, zo_strformat("<<1>> Item(s)", tostring(itemCount)), "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
                group:SetAnchor(TOPLEFT, child, TOPLEFT, 8, yPos)
                LO_SingleLine(group, w - 100, 24)
                yPos = yPos + 28
                LO_GridHeader(child, yPos, gridWidth, false, true)
                yPos = yPos + 24
                lastCount = itemCount
            end
        end
        LO_StatusRow(child, team, yPos, gridWidth, isWar)
        yPos = yPos + (isWar and 36 or 40)
    end
    child:SetDimensions(w - 44, math.max(h - 72, yPos + 10))
end


local function LO_GameModeExplanation(mode, requiredCount, timeLimitMinutes, confirmCounted)
    mode = string.lower(tostring(mode or "threshold"))
    local requiredText = LO_RequiredCountLabel(mode, requiredCount, true)
    local minutes = tonumber(timeLimitMinutes or 0) or 0
    local timeText = ""

    if mode == "threshold" then
        if minutes > 0 then
            timeText = " Within " .. tostring(minutes) .. " minute(s)."
        end

        return "Find at least " .. requiredText .. " items of your team's type and place it in the correct state." .. timeText .. " NOTE: Other teams may actively undo your progress while you're working."
    end

    if mode == "target" then
        if minutes > 0 then
            timeText = " Must complete within " .. tostring(minutes) .. " minute(s)."
        end

        if confirmCounted == true then
            return "Find the " .. requiredText .. " items that are randomly selected from all the items your team has in the house and place it in the correct state. Only targeted items count towards your win. All your needed items start in the non-winning state; other items of your team are randomly assigned off or on. Your item will switch states a few times to indicate it counted if it does!" .. timeText
        end

        return "Find the " .. requiredText .. " items that are randomly selected from all the items your team has in the house and place it in the correct state. Only targeted items count towards your win. All your needed items start in the non-winning state; other items of your team are randomly assigned off or on. You won't know how you're doing until you're done!" .. timeText
    end

    return "Think king of the hill: you and another team or team(s) are fighting to get all the items of the selected type in the state assigned to your team. Your change doesn't count until your item remains in the state for 5 seconds. But you gotta move quick; your opponents are undoing your progress and switching it to theirs."
end

local function LO_BuildSetupPage(parent)
    local page = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local cp = LO_CP()
    cp.selectedMode = cp.selectedMode or "threshold"
    LO_LoadModeConfig(cp.selectedMode, cp)
    LO_ApplyModeEnabledState(cp.selectedMode)
    LO_ClampRequiredCount(true)
    local title = LO_Label(page, "GAME SETUP", "ZoFontWinH2", 1, 1, 1, 1)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 24, 18)

    local populate = LO_Button(page, "POPULATE", 130, 34, "orange")
    populate:SetAnchor(TOPRIGHT, page, TOPRIGHT, -24, 12)
    if populate.SetHorizontalAlignment and TEXT_ALIGN_CENTER then populate:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if populate.SetVerticalAlignment and TEXT_ALIGN_CENTER then populate:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    populate:SetHandler("OnClicked", function()
        LightsOut.PopulateHouseTeams()
    end)
    LO_Tooltip(populate, "Scans the house for interactable furnishings that meet the requirement(s) to be included in a LightsOut game and adds them to the possible team assignments.")

    local resetTeams = LO_Button(page, "RESET TEAM NAME(S)", 190, 34, "gray")
    resetTeams:SetText("RESET TEAM NAME(S)")
    resetTeams:SetAnchor(TOPRIGHT, populate, TOPLEFT, -10, 0)
    if resetTeams.SetHorizontalAlignment and TEXT_ALIGN_CENTER then resetTeams:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if resetTeams.SetVerticalAlignment and TEXT_ALIGN_CENTER then resetTeams:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    resetTeams:SetHandler("OnClicked", function()
        LightsOut.ResetCurrentSetupTeamNames()
    end)
    LO_Tooltip(resetTeams, "Reset the visible team name(s) for the selected game mode/items to their default names.")
    local summary = LO_Label(page, "Choose game mode, required targets, optional time limit, and which teams are enabled for that mode.", "ZoFontGame", 0.80, 0.85, 0.90, 1)
    summary:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    local top = LO_Panel(page, 24, 82, 1080, 216)
    local modeIndex, timeIndex = 1, 1
    for i, m in ipairs(LO_MODE_OPTIONS) do if m.key == cp.selectedMode then modeIndex = i end end
    for i, t in ipairs(LightsOut.CONTROL_TIME_OPTIONS) do if t.value == cp.timeLimitMinutes then timeIndex = i end end
    local modeValue, countValue, timeValue, explanation
    local confirmCountedRow, confirmCountedToggle
    local function refreshTexts()
        LO_ClampRequiredCount(true)

        modeIndex = 1
        for i, m in ipairs(LO_MODE_OPTIONS) do
            if m.key == cp.selectedMode then modeIndex = i break end
        end

        timeIndex = 1
        for i, t in ipairs(LightsOut.CONTROL_TIME_OPTIONS) do
            if t.value == cp.timeLimitMinutes then timeIndex = i break end
        end

        modeValue:SetText(LO_ModeLabel(cp.selectedMode))
        countValue:SetText(LO_RequiredCountLabel(cp.selectedMode, cp.requiredCount, true))
        timeValue:SetText(LO_TimeLabel(cp.timeLimitMinutes))
        if explanation then
            explanation:SetText(LO_GameModeExplanation(cp.selectedMode, cp.requiredCount, cp.timeLimitMinutes, cp.confirmCounted == true))
        end

        if confirmCountedRow then
            confirmCountedRow:SetHidden(cp.selectedMode ~= "target")
        end

        if confirmCountedToggle then
            confirmCountedToggle.value = cp.confirmCounted == true
            if confirmCountedToggle.RefreshLightsOutToggle then
                confirmCountedToggle:RefreshLightsOutToggle()
            end
        end
    end
    modeValue = LO_SelectValueBox(top, "Game Mode", LO_ModeLabel(cp.selectedMode), 24, 18, 300, function()
        modeIndex = modeIndex - 1
        if modeIndex < 1 then modeIndex = #LO_MODE_OPTIONS end
        LO_SetSelectedMode(LO_MODE_OPTIONS[modeIndex].key)
        refreshTexts()
        LightsOut.RebuildControlPanel()
    end, function()
        modeIndex = modeIndex + 1
        if modeIndex > #LO_MODE_OPTIONS then modeIndex = 1 end
        LO_SetSelectedMode(LO_MODE_OPTIONS[modeIndex].key)
        refreshTexts()
        LightsOut.RebuildControlPanel()
    end)
    countValue = LO_SelectValueBox(top, "Required Targets", LO_RequiredCountLabel(cp.selectedMode, cp.requiredCount, true), 360, 18, 260, function()
        if cp.selectedMode == "target" then
            local targetMax = LO_TargetRequiredMax(true)
            local value = tonumber(cp.requiredCount)

            if value == nil then
                value = LO_DefaultTargetRequiredCount(true)
            end

            cp.requiredCount = math.max(1, math.min(targetMax, value - 1))
        elseif cp.selectedMode ~= "war" then
            local limit = LO_GetControlPanelMaxCount(cp.selectedMode, true)
            if LO_IsAllRequiredCount(cp.requiredCount) then
                cp.requiredCount = math.max(1, tonumber(limit or 1) or 1)
            else
                cp.requiredCount = math.max(1, (tonumber(cp.requiredCount or 1) or 1) - 1)
            end
        end
        LO_SaveSelectedModeConfig(cp)
        refreshTexts()
    end, function()
        if cp.selectedMode == "target" then
            local targetMax = LO_TargetRequiredMax(true)
            local value = tonumber(cp.requiredCount)

            if value == nil then
                value = LO_DefaultTargetRequiredCount(true)
            end

            cp.requiredCount = math.max(1, math.min(targetMax, value + 1))
        elseif cp.selectedMode ~= "war" then
            -- GetControlPanelCountInfo returns multiple values: maxCount, reason, teamCount.
            -- Capture the first return value before calling tonumber(), otherwise Lua passes
            -- the reason string as tonumber()'s base argument and raises:
            -- bad argument #2 to 'tonumber' (integer expected, got string).
            local limit = LO_GetControlPanelMaxCount(cp.selectedMode, true)
            if limit < 1 then
                cp.requiredCount = "all"
            elseif LO_IsAllRequiredCount(cp.requiredCount) then
                cp.requiredCount = 1
            else
                local nextCount = (tonumber(cp.requiredCount or 1) or 1) + 1
                if nextCount > limit then
                    cp.requiredCount = "all"
                else
                    cp.requiredCount = nextCount
                end
            end
        end
        LO_SaveSelectedModeConfig(cp)
        refreshTexts()
    end)
    timeValue = LO_SelectValueBox(top, "Time Limit", LO_TimeLabel(cp.timeLimitMinutes), 656, 18, 260, function()
        timeIndex = timeIndex - 1
        if timeIndex < 1 then timeIndex = #LightsOut.CONTROL_TIME_OPTIONS end
        cp.timeLimitMinutes = LightsOut.CONTROL_TIME_OPTIONS[timeIndex].value
        LO_SaveSelectedModeConfig(cp)
        refreshTexts()
    end, function()
        timeIndex = timeIndex + 1
        if timeIndex > #LightsOut.CONTROL_TIME_OPTIONS then timeIndex = 1 end
        cp.timeLimitMinutes = LightsOut.CONTROL_TIME_OPTIONS[timeIndex].value
        LO_SaveSelectedModeConfig(cp)
        refreshTexts()
    end)

    confirmCountedRow = WINDOW_MANAGER:CreateControl(nil, top, CT_CONTROL)
    confirmCountedRow:SetDimensions(360, 34)
    confirmCountedRow:SetAnchor(TOPLEFT, top, TOPLEFT, 360, 92)
    if confirmCountedRow.SetMouseEnabled then confirmCountedRow:SetMouseEnabled(false) end
    confirmCountedRow:SetHidden(cp.selectedMode ~= "target")

    confirmCountedToggle = LO_Toggle(confirmCountedRow, cp.confirmCounted == true, function(value)
        cp.confirmCounted = value == true
        LO_SaveSelectedModeConfig(cp)
        refreshTexts()
    end)
    confirmCountedToggle:SetAnchor(LEFT, confirmCountedRow, LEFT, 0, 0)
    LO_Tooltip(confirmCountedToggle, "Target mode only: require counted targets to be confirmed.")

    local confirmCountedLabel = LO_Label(confirmCountedRow, "Confirm Counted", "ZoFontGameBold", 0.92, 0.94, 1.00, 1)
    confirmCountedLabel:SetAnchor(LEFT, confirmCountedToggle, RIGHT, 10, 0)
    LO_SingleLine(confirmCountedLabel, 250, 28)
    LO_Tooltip(confirmCountedLabel, "Target mode only: require counted targets to be confirmed.")

    explanation = LO_Label(top, LO_GameModeExplanation(cp.selectedMode, cp.requiredCount, cp.timeLimitMinutes, cp.confirmCounted == true), "ZoFontGame", 0.92, 0.94, 1.00, 1)
    explanation:SetAnchor(TOPLEFT, top, TOPLEFT, 24, 138)
    explanation:SetDimensions(1032, 114)
    if explanation.SetMaxLineCount then explanation:SetMaxLineCount(6) end
    if explanation.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then explanation:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    if explanation.SetDrawLayer and DL_OVERLAY then explanation:SetDrawLayer(DL_OVERLAY) end
    if explanation.SetDrawLevel then explanation:SetDrawLevel(5) end

    local hasEnabledTeams = LO_CountEnabled(LO_TeamsForMode(cp.selectedMode)) > 0
    local setupBusy = LightsOut.IsStateChangeQueueRunning and LightsOut.IsStateChangeQueueRunning()
    local start = LO_Button(top, setupBusy and "PREPARING" or "START GAME", 130, 44, (hasEnabledTeams and not setupBusy) and "green" or "gray")
    -- Align the Start Game button vertically with the selector boxes.
    -- LO_SelectValueBox places the option box at row y + 26, so with row y=18
    -- the box top is 44. The Start button uses the same height as those boxes.
    start:SetAnchor(TOPRIGHT, top, TOPRIGHT, -24, 44)
    if start.SetHorizontalAlignment and TEXT_ALIGN_CENTER then start:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if start.SetVerticalAlignment and TEXT_ALIGN_CENTER then start:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if setupBusy or not hasEnabledTeams then
        if start.SetEnabled then start:SetEnabled(false) end
        start:SetMouseEnabled(false)
        start:SetNormalFontColor(0.55, 0.55, 0.55, 1)
        start:SetMouseOverFontColor(0.55, 0.55, 0.55, 1)
        start:SetPressedFontColor(0.55, 0.55, 0.55, 1)
    else
        start:SetHandler("OnClicked", function()
            local maxCount, reason = LightsOut.GetControlPanelCountInfo(cp.selectedMode, true)
            if tonumber(maxCount or 0) < 1 then
                LightsOut.Print(reason or "No valid game count is available.")
                LightsOut.RebuildControlPanel()
                return
            end
            if cp.selectedMode == "war" then
                LightsOut.StartWarMode(cp.timeLimitMinutes)
            elseif cp.selectedMode == "target" then
                LightsOut.StartTargetMode(LO_ResolveRequiredCount(cp.selectedMode, cp.requiredCount, true), cp.timeLimitMinutes)
            else
                LightsOut.StartThresholdMode(LO_ResolveRequiredCount(cp.selectedMode, cp.requiredCount, true), cp.timeLimitMinutes)
            end
            LightsOut.RefreshControlWindow()
        end)
    end
    if setupBusy and LightsOut.stateChangeQueue then
        local q = LightsOut.stateChangeQueue
        local progress = LO_Label(page, zo_strformat("<<1>>: <<2>>/<<3>> item state change(s)", tostring(q.label or "Preparing"), tostring(q.completed or 0), tostring(q.total or 0)), "ZoFontGameBold", 1.0, 0.78, 0.35, 1)
        progress:SetAnchor(TOPLEFT, top, BOTTOMLEFT, 0, 8)
        LO_SingleLine(progress, 900, 24)
        LightsOut.ui.prepProgressLabel = progress
    end

    LO_CreateTeamScroll(page, LO_TeamsForMode(cp.selectedMode), cp.selectedMode == "war", 24, setupBusy and 342 or 326, 1080, setupBusy and 402 or 418, function()
        LightsOut.ui.restoreTeamSetupScrollValue = LO_GetSetupTeamScrollValue()
        LightsOut.RebuildControlPanel()
    end)
    return page
end


local function LO_OverviewTeamsForMode(mode)
    mode = LO_NormalizeModeKey(mode or (LightsOut.game and LightsOut.game.mode) or (LO_CP().selectedMode))

    -- When a game is started from the mini panel, the active game rows are already
    -- stored in LightsOut.game.activeGameEntries.  Do not rebuild the overview
    -- from the setup table here because LO_TeamsForMode/LO_TableToList can reload
    -- setup-mode enabled flags and mark the active rows disabled, producing a
    -- blank "0 Playing" status list when returning to the main control panel.
    if LightsOut.game and LightsOut.game.activeGameEntries and #LightsOut.game.activeGameEntries > 0 then
        local teams = {}

        for _, activeEntry in ipairs(LightsOut.game.activeGameEntries) do
            local entry = activeEntry and activeEntry.entry
            if entry then
                entry.key = entry.key or activeEntry.key
                entry.enabled = true
                table.insert(teams, entry)
            end
        end

        return teams
    end

    return LO_TeamsForMode(mode)
end

local function LO_BuildOverviewPage(parent)
    local page = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local g = LightsOut.game or {}
    local mode = g.mode or LO_CP().selectedMode or "threshold"
    local title = LO_Label(page, string.upper(LO_ModeLabel(mode) .. " GAME"), "ZoFontWinH2", 1, 1, 1, 1)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 24, 18)
    local timer = LO_Label(page, LO_TimerText(), "ZoFontWinH2", 0.25, 1.0, 0.15, 1)
    timer:SetAnchor(TOPRIGHT, page, TOPRIGHT, -26, 18)
    LO_ApplyTimerColor(timer)
    LightsOut.ui.overviewTimerLabel = timer
    local requiredText = tostring(g.threshold or LO_RequiredCountLabel(LO_CP().selectedMode, LO_CP().requiredCount, true))
    local modeInfoText = "Required: " .. requiredText

    if mode == "target" then
        local confirmOn = false

        if g.active == true or g.winner ~= nil or g.cancelled == true then
            confirmOn = g.confirmCounted == true
        else
            confirmOn = LO_CP().confirmCounted == true
        end

        modeInfoText = modeInfoText .. "    Confirmation: " .. (confirmOn and "On" or "Off")
    end

    modeInfoText = modeInfoText .. "    Time: " .. LO_TimeLabel(g.timeLimitMinutes)

    local modeInfo = LO_Label(page, modeInfoText, "ZoFontGame", 0.80, 0.85, 0.90, 1)
    modeInfo:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    LO_CreateStatusScroll(page, LO_OverviewTeamsForMode(mode), mode == "war", 24, 90, 820, 390)
    local actions = LO_Panel(page, 860, 90, 240, 250)
    local actionTitle = LO_Label(actions, "GAME ACTIONS", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    actionTitle:SetAnchor(TOPLEFT, actions, TOPLEFT, 14, 14)
    local text = LO_OverviewResultText(mode)
    local result = LO_Label(actions, text, "ZoFontGame", 0.90, 0.90, 0.86, 1)
    LightsOut.ui.overviewLeaderLabel = result
    LightsOut.ui.overviewMode = mode
    result:SetAnchor(TOPLEFT, actions, TOPLEFT, 18, 50)
    result:SetDimensions(204, 80)
    local gameIsCompleteOrCancelled = g.winner ~= nil or g.cancelled == true
    local actionButton = LO_Button(actions, gameIsCompleteOrCancelled and "RESET GAME" or "CANCEL", 200, 46, gameIsCompleteOrCancelled and "blue" or "red")
    actionButton:SetAnchor(TOP, actions, TOP, 0, 135)
    actionButton:SetHandler("OnClicked", function()
        if gameIsCompleteOrCancelled then
            LightsOut.ResetGame()
            LightsOut.ui.activePage = "setup"
            LightsOut.ShowControlWindow()
        else
            LightsOut.CancelGame()
        end
    end)
    return page
end


local function LO_EstimateAboutTextHeight(text, width)
    text = tostring(text or "")
    width = tonumber(width or 460) or 460

    local charsPerLine = math.max(42, math.floor(width / 7))
    local lineCount = 0

    for line in string.gmatch(text .. "\n", "(.-)\n") do
        local lineLength = string.len(line or "")
        lineCount = lineCount + math.max(1, math.ceil(lineLength / charsPerLine))
    end

    return math.max(80, (lineCount * 22) + 14)
end

local function LO_CreateAboutSection(parent, x, y, w, h, titleText, bodyText)
    local panel = LO_Panel(parent, x, y, w, h)

    local header = LO_Label(panel, titleText, "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    header:SetAnchor(TOPLEFT, panel, TOPLEFT, 16, 12)
    LO_SingleLine(header, w - 32, 24)
    LO_Tooltip(header, tostring(titleText or ""))

    local scroll = WINDOW_MANAGER:CreateControlFromVirtual(LO_UniqueControlName("LightsOutAboutScroll"), panel, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, panel, TOPLEFT, 14, 42)
    scroll:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -12, -12)

    local child = scroll:GetNamedChild("ScrollChild")
    local bodyWidth = w - 52
    local bodyHeight = LO_EstimateAboutTextHeight(bodyText, bodyWidth)

    local body = LO_Label(child, bodyText, "ZoFontGame", 0.86, 0.88, 0.92, 1)
    body:SetAnchor(TOPLEFT, child, TOPLEFT, 0, 0)
    body:SetDimensions(bodyWidth, bodyHeight)

    child:SetDimensions(bodyWidth, bodyHeight + 8)

    return panel
end

local function LO_BuildAboutPage(parent)
    local page = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    page:SetAnchorFill(parent)

    local title = LO_Label(page, "ABOUT / HELP", "ZoFontWinH2", 1, 1, 1, 1)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 24, 18)

    LO_CreateAboutSection(page, 24, 70, 520, 220, "LightsOut Housing Mini Games", [=[LightsOut turns interactable furnishings in an ESO house into competitive mini games.

Target and Threshold give each team their own item and winning state. Threshold scores a set number of items. Target secretly chooses which items count, starts those targets in the non-winning state, and gives no feedback until the game is won.

War uses one shared item type. Each team is assigned a different state, and states must hold for 5 seconds before counting.]=])

    LO_CreateAboutSection(page, 570, 70, 520, 220, "Quick Start", [=[1. Type /lo or /lightsout to open the Control Panel.
2. Click Populate to find usable interactable items in the current house.
3. Left-click a team name to rename it. Press Enter or click away to save; press Esc to cancel.
4. Click a state to change the scoring state when allowed.
5. Use team or group toggles to choose who is playing.]=])

    LO_CreateAboutSection(page, 24, 310, 520, 190, "Team Setup Rules", [=[Target/Threshold teams must have the same item instance count. Enabling a team in a different count group disables teams from the previous group.

War teams must use the same item type. Enabling a different item group disables the previous item group.

Use the delete button on the far right to delete a team or an entire group.]=])

    LO_CreateAboutSection(page, 570, 310, 520, 190, "Starting / Playing", [=[Enable at least one team, choose mode, required targets, and optional timer, then click Start.

The status view shows teams, item/status, correct count, percent, and required state. The timer counts down with a time limit or up without one.

Timer colors: green active, yellow sudden death, red cancelled, blue completed.

Once a game has finished, click Reset Game to return to Game Setup and start again. You may also use the Mini Panel for a condensed play view that can restart the same game without full setup options.]=])

    LO_CreateAboutSection(page, 24, 520, 520, 135, "Adding / Removing Items", [=[Counts are verified before games start. New interactable items may be added automatically as options. Removed items update counts and may disable teams.

Adding or removing an item type currently in play cancels the game. Leaving or changing houses also ends the game.]=])

    LO_CreateAboutSection(page, 570, 520, 520, 135, "Manual Add / Commands", [=[If Populate misses an item, open the housing editor, select the item, then use:
/lo add <teamname>
/lo add war <teamname>

Manual teams start disabled until you enable them.]=])

    return page
end
local LO_ApplyMiniPanelActionEnabledState

local function LO_PerformMiniPanelAction()
    local g = LightsOut.game or {}

    if g.winner ~= nil or g.cancelled == true then
        -- Resetting from the mini panel should keep the mini panel as the active UI.
        -- ResetGame normally returns to the full control panel after the reset queue completes.
        LightsOut.returnToMiniPanelAfterReset = true
        LightsOut.ResetGame()
        LightsOut.RefreshMiniPanel()
        return
    end

    if g.active == true then
        LightsOut.CancelGame()
        LightsOut.RefreshMiniPanel()
        return
    end

    local cp = LO_CP()
    local maxCount, reason = LightsOut.GetControlPanelCountInfo(cp.selectedMode, true)

    if tonumber(maxCount or 0) < 1 then
        LightsOut.Print(reason or "No valid game count is available.")
        LightsOut.RefreshMiniPanel()
        return
    end

    -- Starting from the mini panel should keep the full control/status window closed.
    LightsOut.suppressNextGameStatusWindow = true

    if cp.selectedMode == "war" then
        LightsOut.StartWarMode(cp.timeLimitMinutes)
    elseif cp.selectedMode == "target" then
        LightsOut.StartTargetMode(LO_ResolveRequiredCount(cp.selectedMode, cp.requiredCount, true), cp.timeLimitMinutes)
    else
        LightsOut.StartThresholdMode(LO_ResolveRequiredCount(cp.selectedMode, cp.requiredCount, true), cp.timeLimitMinutes)
    end

    LightsOut.RefreshMiniPanel()
end

local function LO_ColorizeMiniPanelLastUpdateText(text)
    text = tostring(text or "")

    if text == "" then
        text = "None"
    end

    -- Color only the direction word, not the whole phrase.
    text = text:gsub("(%f[%a])up(%f[%A])", "|c00FF00up|r")
    text = text:gsub("(%f[%a])down(%f[%A])", "|cFF3333down|r")

    return text
end

local function LO_FormatMiniPanelUpdateAge(timestampMs)
    timestampMs = tonumber(timestampMs or 0) or 0
    if timestampMs <= 0 then
        return "--"
    end

    local nowMs = LightsOut.GetNowMs() or 0

    -- When a winner is declared, freeze the mini-panel Last Updates ages at
    -- the exact game-end moment so the completed game shows a final snapshot
    -- instead of continuing to count upward.
    if LightsOut.game and LightsOut.game.winner ~= nil and LightsOut.game.frozenTimeMs ~= nil then
        nowMs = tonumber(LightsOut.game.frozenTimeMs) or nowMs
    end

    local elapsedSeconds = math.max(0, math.floor((nowMs - timestampMs) / 1000))

    if elapsedSeconds < 1 then
        return "now"
    end

    if elapsedSeconds < 60 then
        return tostring(elapsedSeconds) .. "s"
    end

    local minutes = math.floor(elapsedSeconds / 60)
    local seconds = elapsedSeconds % 60

    if minutes < 60 then
        return string.format("%dm %02ds", minutes, seconds)
    end

    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    return string.format("%dh %02dm", hours, minutes)
end

local function LO_StartMiniPanelHistoryTimer()
    if not (LightsOut.ui and LightsOut.ui.miniPanelWindow) then return end
    if LightsOut.ui.miniPanelHistoryTimerRunning then return end

    LightsOut.ui.miniPanelHistoryTimerRunning = true

    local function tick()
        if not (LightsOut.ui and LightsOut.ui.miniPanelWindow and not LightsOut.ui.miniPanelWindow:IsHidden()) then
            LightsOut.ui.miniPanelHistoryTimerRunning = false
            return
        end

        if type(LO_RefreshMiniPanelUpdateHistory) == "function" then
            LO_RefreshMiniPanelUpdateHistory(false)
        end

        if type(zo_callLater) == "function" then
            zo_callLater(tick, 1000)
        else
            LightsOut.ui.miniPanelHistoryTimerRunning = false
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(tick, 1000)
    else
        LightsOut.ui.miniPanelHistoryTimerRunning = false
    end
end

function LO_RefreshMiniPanelUpdateHistory(animateNewest)
    local ui = LightsOut.ui
    if not ui then return end

    local rows = ui.miniPanelLastUpdateRows or {}
    local history = LightsOut.game and LightsOut.game.miniPanelUpdateHistory or nil
    local newestSignature = nil

    for index = 1, 6 do
        local row = rows[index]
        local entry = history and history[index] or nil

        if row then
            local textLabel = row.textLabel
            local ageLabel = row.ageLabel

            if entry and tostring(entry.text or "") ~= "" then
                local text = LO_ColorizeMiniPanelLastUpdateText(entry.text)
                local age = LO_FormatMiniPanelUpdateAge(entry.timestampMs)

                if index == 1 then
                    newestSignature = tostring(entry.text or "") .. ":" .. tostring(entry.timestampMs or "")
                end

                if textLabel then
                    textLabel:SetHidden(false)
                    textLabel:SetFont("ZoFontGameSmall")
                    textLabel:SetAlpha(index == 1 and 1 or 0.82)
                    textLabel:SetText(text)
                end

                if ageLabel then
                    ageLabel:SetHidden(false)
                    ageLabel:SetFont("ZoFontGameSmall")
                    ageLabel:SetAlpha(index == 1 and 1 or 0.82)
                    ageLabel:SetText(age)
                end
            elseif index == 1 then
                if textLabel then
                    textLabel:SetHidden(false)
                    textLabel:SetFont("ZoFontGameSmall")
                    textLabel:SetAlpha(0.65)
                    textLabel:SetText("None")
                end

                if ageLabel then
                    ageLabel:SetHidden(false)
                    ageLabel:SetFont("ZoFontGameSmall")
                    ageLabel:SetAlpha(0.65)
                    ageLabel:SetText("--")
                end
            else
                if textLabel then
                    textLabel:SetText("")
                    textLabel:SetHidden(true)
                end

                if ageLabel then
                    ageLabel:SetText("")
                    ageLabel:SetHidden(true)
                end
            end
        end
    end

    if animateNewest and newestSignature and ui.miniPanelLastUpdateNewestSignature ~= newestSignature then
        ui.miniPanelLastUpdateNewestSignature = newestSignature

        local firstRow = rows[1]
        if firstRow then
            if firstRow.textLabel and firstRow.textLabel.SetScale then firstRow.textLabel:SetScale(1.08) end
            if firstRow.ageLabel and firstRow.ageLabel.SetScale then firstRow.ageLabel:SetScale(1.08) end

            if type(zo_callLater) == "function" then
                zo_callLater(function()
                    if not (LightsOut.ui and LightsOut.ui.miniPanelLastUpdateRows and LightsOut.ui.miniPanelLastUpdateRows[1] == firstRow) then return end
                    if firstRow.textLabel and firstRow.textLabel.SetScale then firstRow.textLabel:SetScale(1.0) end
                    if firstRow.ageLabel and firstRow.ageLabel.SetScale then firstRow.ageLabel:SetScale(1.0) end
                end, 120)
            else
                if firstRow.textLabel and firstRow.textLabel.SetScale then firstRow.textLabel:SetScale(1.0) end
                if firstRow.ageLabel and firstRow.ageLabel.SetScale then firstRow.ageLabel:SetScale(1.0) end
            end
        end
    elseif newestSignature then
        ui.miniPanelLastUpdateNewestSignature = ui.miniPanelLastUpdateNewestSignature or newestSignature
    end

    if not (LightsOut.game and LightsOut.game.winner ~= nil and LightsOut.game.frozenTimeMs ~= nil) then
        LO_StartMiniPanelHistoryTimer()
    end
end



local function LO_ClearMiniPanelAssignments()
    local ui = LightsOut.ui or {}
    ui.miniAssignmentTeamLabels = {}
    local child = ui.miniPanelAssignmentsScrollChild
    if child and child.GetNumChildren then
        for i = child:GetNumChildren(), 1, -1 do
            local c = child:GetChild(i)
            if c then
                c:SetHidden(true)
                c._lightsOutEditingHidden = false
                if c.SetAlpha then c:SetAlpha(1) end
                if c.SetMouseEnabled then c:SetMouseEnabled(false) end

                if WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
                    WINDOW_MANAGER:DestroyControl(c)
                end
            end
        end
    end
end

function LightsOut.QueueMiniPanelAssignmentsRefresh()
    if not (LightsOut.ui and LightsOut.ui.miniPanelWindow and not LightsOut.ui.miniPanelWindow:IsHidden()) then
        return
    end

    if LightsOut.ui.activeStatePicker and not LightsOut.ui.activeStatePicker.closed then
        return
    end

    if type(LightsOut.RefreshMiniPanelAssignments) ~= "function" then
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if LightsOut.ui and LightsOut.ui.miniPanelWindow and not LightsOut.ui.miniPanelWindow:IsHidden() then
                LightsOut.RefreshMiniPanelAssignments()
            end
        end, 50)
    else
        LightsOut.RefreshMiniPanelAssignments()
    end
end

function LightsOut.RefreshMiniPanelAssignments()
    if not (LightsOut.ui and LightsOut.ui.miniPanelAssignmentsScrollChild) then
        return
    end

    -- Do not rebuild the mini assignment list while an editor/picker is open.
    -- Rebuilding can create fresh labels under active popups or steal draw order.
    if LightsOut.ui.activeTeamNameEditor and not LightsOut.ui.activeTeamNameEditor.closed then
        return
    end

    if LightsOut.ui.activeStatePicker and not LightsOut.ui.activeStatePicker.closed then
        return
    end

    LO_ClearMiniPanelAssignments()

    local child = LightsOut.ui.miniPanelAssignmentsScrollChild
    local mode = (LightsOut.game and LightsOut.game.mode) or (LO_CP().selectedMode)
    local entries, resolvedMode = LightsOut.BuildTeamInfoEntriesForMode(mode)
    resolvedMode = LO_NormalizeModeKey(resolvedMode or mode)

    local font = "ZoFontGameSmall"
    local teamX, itemX, stateX = 8, 128, 322
    local teamW, itemW, stateW = 116, 190, 76
    local y = 4

    if not entries or #entries == 0 then
        local none = LO_Label(child, "No enabled teams for this mode.", font, 0.78, 0.86, 0.95, 1)
        none:SetAnchor(TOPLEFT, child, TOPLEFT, 8, y)
        none:SetDimensions(300, 22)
        if none.SetMaxLineCount then none:SetMaxLineCount(1) end
        child:SetDimensions(1, y + 34)
        return
    end

    local teamHeader = LO_Label(child, "Team Name", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    teamHeader:SetAnchor(TOPLEFT, child, TOPLEFT, teamX, y)
    LO_SingleLine(teamHeader, teamW, 20)

    local itemHeader = LO_Label(child, "Item Name", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    itemHeader:SetAnchor(TOPLEFT, child, TOPLEFT, itemX, y)
    LO_SingleLine(itemHeader, itemW, 20)

    local stateHeader = LO_Label(child, "State", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    stateHeader:SetAnchor(TOPLEFT, child, TOPLEFT, stateX, y)
    LO_SingleLine(stateHeader, stateW, 20)

    y = y + 24

    local line = WINDOW_MANAGER:CreateControl(nil, child, CT_BACKDROP)
    line:SetDimensions(392, 2)
    line:SetAnchor(TOPLEFT, child, TOPLEFT, 8, y)
    line:SetCenterColor(0.55, 0.45, 0.26, 0.85)
    line:SetEdgeColor(0, 0, 0, 0)
    y = y + 8

    local rowIndex = 0

    for _, activeEntry in ipairs(entries) do
        local entry = activeEntry and activeEntry.entry
        if entry then
            rowIndex = rowIndex + 1

            if rowIndex % 2 == 0 then
                local rowBg = WINDOW_MANAGER:CreateControl(nil, child, CT_BACKDROP)
                rowBg:SetDimensions(392, 20)
                rowBg:SetAnchor(TOPLEFT, child, TOPLEFT, 6, y)
                rowBg:SetCenterColor(0.18, 0.18, 0.20, 0.45)
                rowBg:SetEdgeColor(0, 0, 0, 0)
                if rowBg.SetDrawLayer and DL_BACKGROUND then rowBg:SetDrawLayer(DL_BACKGROUND) end
                if rowBg.SetDrawTier and DT_LOW then rowBg:SetDrawTier(DT_LOW) end
                if rowBg.SetDrawLevel then rowBg:SetDrawLevel(0) end
            end
            local isWar = resolvedMode == "war"
            local teamName = tostring(LO_GetTeamNameForMode(entry, resolvedMode, isWar) or activeEntry.key or "Unknown Team")
            local itemName = tostring(entry.itemName or "Unknown Item")
            local stateName = tostring(entry.stateName or ("State " .. tostring(entry.state or "?")))

            local teamLabel = LO_Label(child, teamName, font, 0.78, 0.86, 0.95, 1)
            teamLabel:SetAnchor(TOPLEFT, child, TOPLEFT, teamX, y)
            teamLabel:SetDimensions(teamW, 20)
            if teamLabel.SetMaxLineCount then teamLabel:SetMaxLineCount(1) end
            if teamLabel.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then teamLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
            LO_MakeTeamNameEditable(teamLabel, entry, isWar, teamW, 20)
            LO_Tooltip(teamLabel, teamName)

            local itemLabel = LO_Label(child, itemName, font, 0.78, 0.86, 0.95, 1)
            itemLabel:SetAnchor(TOPLEFT, child, TOPLEFT, itemX, y)
            itemLabel:SetDimensions(itemW, 20)
            if itemLabel.SetMaxLineCount then itemLabel:SetMaxLineCount(1) end
            if itemLabel.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then itemLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
            LO_Tooltip(itemLabel, itemName)

            local stateLabel = LO_Label(child, stateName, font, 0.78, 0.86, 0.95, 1)
            stateLabel:SetAnchor(TOPLEFT, child, TOPLEFT, stateX, y)
            stateLabel:SetDimensions(stateW, 20)
            if stateLabel.SetMaxLineCount then stateLabel:SetMaxLineCount(1) end
            if stateLabel.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then stateLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
            LO_Tooltip(stateLabel, stateName)

            y = y + 22
        end
    end

    child:SetDimensions(1, y + 10)
end


function LightsOut.CreateMiniPanelWindow()
    if LightsOut.ui and LightsOut.ui.miniPanelWindow then
        return LightsOut.ui.miniPanelWindow
    end

    LightsOut.ui = LightsOut.ui or {}

    local existingWindow = _G["LightsOutMiniPanelWindow"]
    local window = existingWindow or WINDOW_MANAGER:CreateTopLevelWindow("LightsOutMiniPanelWindow")
    window:SetDimensions(860, 360)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 160, 120)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    if window.SetResizable then window:SetResizable(false) end
    if window.SetResizeHandleSize then window:SetResizeHandleSize(0) end
    LO_Backdrop(window, 0.46)

    local miniGroup = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    miniGroup:SetDimensions(430, 360)
    miniGroup:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    LightsOut.ui.miniPanelMainGroup = miniGroup

    local assignmentsGroup = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    assignmentsGroup:SetDimensions(430, 360)
    assignmentsGroup:SetAnchor(TOPLEFT, miniGroup, TOPRIGHT, 0, 0)
    LightsOut.ui.miniPanelAssignmentsGroup = assignmentsGroup

    local miniDivider = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    miniDivider:SetDimensions(2, 360)
    miniDivider:SetAnchor(TOPLEFT, miniGroup, TOPRIGHT, -1, 0)
    miniDivider:SetCenterColor(0.45, 0.38, 0.25, 0.90)
    miniDivider:SetEdgeColor(0, 0, 0, 0)
    LightsOut.ui.miniPanelDivider = miniDivider

    local title = LO_Label(miniGroup, "LightsOut Mini Panel", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    title:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 14, 10)

    local summary = LO_Label(miniGroup, LO_MiniPanelSetupSummaryText(), "ZoFontGame", 0.78, 0.86, 0.95, 1)
    summary:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 18, 34)
    summary:SetDimensions(390, 22)
    if summary.SetMaxLineCount then summary:SetMaxLineCount(1) end
    LightsOut.ui.miniPanelSetupSummaryLabel = summary

    local returnButton = LO_Button(miniGroup, "<", 28, 24, "gray")
    returnButton:SetAnchor(TOPRIGHT, miniGroup, TOPRIGHT, -8, 8)
    LO_Tooltip(returnButton, "Return to main control panel")
    returnButton:SetHandler("OnClicked", function()
        LightsOut.ReturnFromMiniPanelToFullPanel()
    end)

    local timer = LO_Label(miniGroup, LO_TimerText(), "ZoFontWinH2", 0.25, 1.0, 0.15, 1)
    timer:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 18, 58)
    LO_ApplyTimerColor(timer)
    LightsOut.ui.miniPanelTimerLabel = timer

    local actionText, actionTone = LO_MiniPanelActionTextAndTone()
    local action = LO_Button(miniGroup, actionText, 140, 40, actionTone)
    action:SetAnchor(TOPRIGHT, miniGroup, TOPRIGHT, -18, 92)
    if action.SetHorizontalAlignment and TEXT_ALIGN_CENTER then action:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if action.SetVerticalAlignment and TEXT_ALIGN_CENTER then action:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    action:SetHandler("OnClicked", LO_PerformMiniPanelAction)
    LightsOut.ui.miniPanelActionButton = action
    LightsOut.ui.miniPanelLastActionTone = actionTone
    LO_ApplyMiniPanelActionEnabledState(action)

    local teamInfoButton = LO_Button(miniGroup, "TEAM INFO TO CHAT", 255, 40, "blue")
    teamInfoButton:SetAnchor(RIGHT, action, LEFT, -8, 0)
    if teamInfoButton.SetHorizontalAlignment and TEXT_ALIGN_CENTER then teamInfoButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if teamInfoButton.SetVerticalAlignment and TEXT_ALIGN_CENTER then teamInfoButton:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if teamInfoButton.SetMaxLineCount then teamInfoButton:SetMaxLineCount(1) end
    if teamInfoButton.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then teamInfoButton:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    LO_Tooltip(teamInfoButton, "Prepare team scoring information in chat")
    teamInfoButton:SetHandler("OnClicked", function()
        if type(LightsOut.HandleSlashCommand) == "function" then
            LightsOut.HandleSlashCommand("teams")
        else
            LightsOut.Print("Team info to chat is not available.")
        end
    end)
    LightsOut.ui.miniPanelTeamInfoButton = teamInfoButton

    local leaderTitle = LO_Label(miniGroup, LO_MiniPanelStatusLabelText(), "ZoFontGameSmall", 1.0, 0.88, 0.55, 1)
    leaderTitle:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 18, 140)
    leaderTitle:SetDimensions(104, 22)
    if leaderTitle.SetMaxLineCount then leaderTitle:SetMaxLineCount(1) end
    LightsOut.ui.miniPanelLeaderTitleLabel = leaderTitle

    local leader = LO_Label(miniGroup, LO_MiniPanelStatusValueText(), "ZoFontGameSmall", 0.78, 0.86, 0.95, 1)
    leader:SetAnchor(LEFT, leaderTitle, RIGHT, 6, 0)
    leader:SetDimensions(240, 22)
    if leader.SetMaxLineCount then leader:SetMaxLineCount(1) end
    if leader.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then leader:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    LightsOut.ui.miniPanelLeaderLabel = leader

    local highScoreTitle = LO_Label(miniGroup, "Highest Score:", "ZoFontGameSmall", 1.0, 0.88, 0.55, 1)
    highScoreTitle:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 18, 164)
    highScoreTitle:SetDimensions(104, 22)
    if highScoreTitle.SetMaxLineCount then highScoreTitle:SetMaxLineCount(1) end
    LightsOut.ui.miniPanelHighestScoreTitleLabel = highScoreTitle

    local highScore = LO_Label(miniGroup, LO_MiniPanelHighestScoreValueText(), "ZoFontGameSmall", 0.78, 0.86, 0.95, 1)
    highScore:SetAnchor(LEFT, highScoreTitle, RIGHT, 6, 0)
    highScore:SetDimensions(240, 22)
    if highScore.SetMaxLineCount then highScore:SetMaxLineCount(1) end
    if highScore.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then highScore:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    LightsOut.ui.miniPanelHighestScoreLabel = highScore

    local lastTitle = LO_Label(miniGroup, "Last Updates:", "ZoFontGameSmall", 1.0, 0.88, 0.55, 1)
    lastTitle:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 18, 190)
    lastTitle:SetDimensions(104, 22)
    if lastTitle.SetMaxLineCount then lastTitle:SetMaxLineCount(1) end
    LightsOut.ui.miniPanelLastUpdateTitleLabel = lastTitle

    LightsOut.ui.miniPanelLastUpdateRows = {}
    for index = 1, 6 do
        local y = 190 + ((index - 1) * 22)
        local updateLabel = LO_Label(miniGroup, "", "ZoFontGameSmall", 0.78, 0.86, 0.95, 1)
        updateLabel:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 128, y)
        updateLabel:SetDimensions(218, 22)
        if updateLabel.SetMaxLineCount then updateLabel:SetMaxLineCount(1) end
        if updateLabel.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then updateLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end

        local ageLabel = LO_Label(miniGroup, "", "ZoFontGameSmall", 0.62, 0.72, 0.86, 1)
        ageLabel:SetAnchor(TOPLEFT, miniGroup, TOPLEFT, 354, y)
        ageLabel:SetDimensions(58, 22)
        if ageLabel.SetMaxLineCount then ageLabel:SetMaxLineCount(1) end
        if ageLabel.SetHorizontalAlignment and TEXT_ALIGN_RIGHT then ageLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end

        LightsOut.ui.miniPanelLastUpdateRows[index] = {
            textLabel = updateLabel,
            ageLabel = ageLabel,
        }
    end

    -- Backward-compatible alias in case any external helper still checks this field.
    LightsOut.ui.miniPanelLastUpdateLabel = LightsOut.ui.miniPanelLastUpdateRows[1].textLabel
    LO_RefreshMiniPanelUpdateHistory(false)

    local assignmentTitle = LO_Label(assignmentsGroup, "Team Assignments", "ZoFontGameBold", 1.0, 0.88, 0.55, 1)
    assignmentTitle:SetAnchor(TOPLEFT, assignmentsGroup, TOPLEFT, 14, 10)
    assignmentTitle:SetDimensions(320, 22)
    if assignmentTitle.SetMaxLineCount then assignmentTitle:SetMaxLineCount(1) end
    LightsOut.ui.miniPanelAssignmentsTitle = assignmentTitle

    local assignmentScroll = WINDOW_MANAGER:CreateControlFromVirtual(LO_UniqueControlName("LightsOutMiniAssignmentsScroll"), assignmentsGroup, "ZO_ScrollContainer")
    assignmentScroll:SetAnchor(TOPLEFT, assignmentsGroup, TOPLEFT, 12, 38)
    assignmentScroll:SetAnchor(BOTTOMRIGHT, assignmentsGroup, BOTTOMRIGHT, -12, -12)
    LightsOut.ui.miniPanelAssignmentsScroll = assignmentScroll
    LightsOut.ui.miniPanelAssignmentsScrollChild = assignmentScroll:GetNamedChild("ScrollChild")

    window:SetHandler("OnMoveStop", function(self)
        LightsOut.savedVars = LightsOut.savedVars or {}
        LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
        LightsOut.savedVars.miniPanel.left = self:GetLeft()
        LightsOut.savedVars.miniPanel.top = self:GetTop()
    end)

    if LightsOut.savedVars and LightsOut.savedVars.miniPanel then
        local left = tonumber(LightsOut.savedVars.miniPanel.left)
        local top = tonumber(LightsOut.savedVars.miniPanel.top)
        if left and top then
            window:ClearAnchors()
            window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        end
    end

    LightsOut.ui.miniPanelWindow = window
    LightsOut.RefreshMiniPanel()
    return window
end



local function LO_CancelActiveTeamNameEditForPanelSwitch()
    if type(LO_CloseTeamNameEditor) == "function" then
        LO_CloseTeamNameEditor(false)
    end

    if not LightsOut.ui then return end

    local function restoreHiddenLabel(label)
        if label and label._lightsOutEditingHidden then
            label._lightsOutEditingHidden = false
            if label.SetAlpha then label:SetAlpha(1) end
            if label.SetMouseEnabled then label:SetMouseEnabled(true) end
            if label.SetHidden then label:SetHidden(false) end
        end
    end

    if LightsOut.ui.setupRows then
        for _, row in pairs(LightsOut.ui.setupRows) do
            restoreHiddenLabel(row and row.nameLabel)
        end
    end

    if LightsOut.ui.statusRows then
        for _, row in pairs(LightsOut.ui.statusRows) do
            restoreHiddenLabel(row and row.nameLabel)
        end
    end

    if LightsOut.ui.miniPanelAssignmentsScrollChild and LightsOut.ui.miniPanelAssignmentsScrollChild.GetNumChildren then
        local child = LightsOut.ui.miniPanelAssignmentsScrollChild
        for i = 1, child:GetNumChildren() do
            restoreHiddenLabel(child:GetChild(i))
        end
    end
end


function LightsOut.ReturnFromMiniPanelToFullPanel()
    LO_CloseTeamNameEditor(false)
    LO_CancelActiveTeamNameEditForPanelSwitch()
    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
    LightsOut.savedVars.miniPanel.preferMini = false

    if not LightsOut.IsInHouse(true) then
        if LightsOut.ui and LightsOut.ui.miniPanelWindow then
            LightsOut.ui.miniPanelWindow:SetHidden(true)
        end
        return
    end

    if LightsOut.ui and LightsOut.ui.miniPanelWindow then
        LightsOut.ui.miniPanelWindow:SetHidden(true)
    end

    -- Return directly to the full panel without using ToggleControlWindow(),
    -- because ToggleControlWindow() performs an explicit furnishing recount.
    -- If the full panel already exists, do not rebuild it at all: simply unhide
    -- it and refresh the visible labels from cached state.  This avoids both
    -- furnishing rescans and the shorter UI pause caused by recreating all rows.
    local existingWindow = LightsOut.ui and LightsOut.ui.controlWindow or nil
    if existingWindow then
        existingWindow:SetHidden(false)

        if type(LO_ShowPage) == "function" then
            if type(LO_IsGameStatusVisibleState) == "function" and LO_IsGameStatusVisibleState() then
                LO_ShowPage("overview")
            else
                LO_ShowPage("setup")
            end
        end

        if type(LightsOut.RefreshControlWindow) == "function" then
            LightsOut.RefreshControlWindow()
        end

        if type(LO_SetControlPanelMousePassthrough) == "function" then
            LO_SetControlPanelMousePassthrough(existingWindow)
        end

        return
    end

    -- First return in a session still has to create the main panel.  Creation
    -- performs its initial build once; later mini-panel returns use the fast path above.
    if type(LightsOut.CreateControlWindow) == "function" then
        local window = LightsOut.CreateControlWindow()
        if window then
            window:SetHidden(false)
        end
    end
end


local function LO_IsMiniPanelActionEnabled()
    local g = LightsOut.game or {}

    -- RESET and CANCEL must remain available from the mini panel. Only START
    -- follows the same validation rules as the main control panel start button.
    if g.winner ~= nil or g.cancelled == true or g.active == true then
        return true
    end

    if not LightsOut.IsInHouse(false) then
        return false
    end

    local setupBusy = LightsOut.IsStateChangeQueueRunning and LightsOut.IsStateChangeQueueRunning()
    if setupBusy then
        return false
    end

    local cp = LO_CP()
    local hasEnabledTeams = LO_CountEnabled(LO_TeamsForMode(cp.selectedMode)) > 0
    if not hasEnabledTeams then
        return false
    end

    local maxCount = LO_GetControlPanelMaxCount(cp.selectedMode, true)
    return maxCount >= 1
end

LO_ApplyMiniPanelActionEnabledState = function(button)
    if not button then return end

    local enabled = LO_IsMiniPanelActionEnabled()
    local _actionText, actionTone = LO_MiniPanelActionTextAndTone()

    if button.SetEnabled then
        button:SetEnabled(enabled)
    end

    button:SetMouseEnabled(enabled)

    if enabled then
        if button.SetLightsOutTone then button:SetLightsOutTone(actionTone) end
        button:SetAlpha(1)
        button:SetNormalFontColor(1, 1, 1, 1)
        button:SetMouseOverFontColor(0.9, 0.95, 1, 1)
        button:SetPressedFontColor(0.75, 0.85, 1, 1)
    else
        if button.SetLightsOutTone then button:SetLightsOutTone("gray") end
        button:SetAlpha(0.60)
        button:SetNormalFontColor(0.55, 0.55, 0.55, 1)
        button:SetMouseOverFontColor(0.55, 0.55, 0.55, 1)
        button:SetPressedFontColor(0.55, 0.55, 0.55, 1)
    end
end

function LightsOut.RefreshMiniPanel()
    if not (LightsOut.ui and LightsOut.ui.miniPanelWindow) then
        return
    end

    if LightsOut.ui.miniPanelSetupSummaryLabel then
        LightsOut.ui.miniPanelSetupSummaryLabel:SetText(LO_MiniPanelSetupSummaryText())
    end

    if LightsOut.ui.miniPanelTimerLabel then
        LightsOut.ui.miniPanelTimerLabel:SetText(LO_TimerText())
        LO_ApplyTimerColor(LightsOut.ui.miniPanelTimerLabel)
    end

    if LightsOut.ui.miniPanelLeaderTitleLabel then
        LightsOut.ui.miniPanelLeaderTitleLabel:SetText(LO_MiniPanelStatusLabelText())
        LightsOut.ui.miniPanelLeaderTitleLabel:SetFont("ZoFontGameSmall")
    end

    if LightsOut.ui.miniPanelLeaderLabel then
        LightsOut.ui.miniPanelLeaderLabel:SetFont("ZoFontGameSmall")
        LightsOut.ui.miniPanelLeaderLabel:SetText(LO_MiniPanelStatusValueText())
    end

    if LightsOut.ui.miniPanelHighestScoreTitleLabel then
        LightsOut.ui.miniPanelHighestScoreTitleLabel:SetFont("ZoFontGameSmall")
        LightsOut.ui.miniPanelHighestScoreTitleLabel:SetText("Highest Score:")
    end

    if LightsOut.ui.miniPanelHighestScoreLabel then
        LightsOut.ui.miniPanelHighestScoreLabel:SetFont("ZoFontGameSmall")
        LightsOut.ui.miniPanelHighestScoreLabel:SetText(LO_MiniPanelHighestScoreValueText())
    end

    if LightsOut.ui.miniPanelLastUpdateRows then
        local history = LightsOut.game and LightsOut.game.miniPanelUpdateHistory or nil
        local newestEntry = history and history[1] or nil
        local updateSignature = newestEntry and (tostring(newestEntry.text or "") .. ":" .. tostring(newestEntry.timestampMs or "")) or "None"
        local animateUpdate = LightsOut.ui.miniPanelLastUpdateRawText ~= updateSignature
        LightsOut.ui.miniPanelLastUpdateRawText = updateSignature
        LO_RefreshMiniPanelUpdateHistory(animateUpdate)
    end

    if LightsOut.ui.miniPanelActionButton then
        local actionText, actionTone = LO_MiniPanelActionTextAndTone()
        LightsOut.ui.miniPanelActionButton:SetText(actionText)
        if LightsOut.ui.miniPanelLastActionTone ~= actionTone then
            LightsOut.ui.miniPanelLastActionTone = actionTone
            if LightsOut.ui.miniPanelActionButton.SetLightsOutTone then
                LightsOut.ui.miniPanelActionButton:SetLightsOutTone(actionTone)
            end
        end
        LO_ApplyMiniPanelActionEnabledState(LightsOut.ui.miniPanelActionButton)
    end

end

local function LO_CanOpenMiniPanel()
    return LO_IsMiniPanelActionEnabled()
end

local function LO_ApplyMiniPanelNavButtonEnabledState(button)
    if not button then return end

    local enabled = LO_CanOpenMiniPanel()
    if button.SetEnabled then button:SetEnabled(enabled) end
    button:SetMouseEnabled(enabled)

    if enabled then
        if button.SetLightsOutTone then button:SetLightsOutTone("gray") end
        button:SetAlpha(1)
        button:SetNormalFontColor(1, 1, 1, 1)
        button:SetMouseOverFontColor(0.9, 0.95, 1, 1)
        button:SetPressedFontColor(0.75, 0.85, 1, 1)
    else
        if button.SetLightsOutTone then button:SetLightsOutTone("gray") end
        button:SetAlpha(0.50)
        button:SetNormalFontColor(0.55, 0.55, 0.55, 1)
        button:SetMouseOverFontColor(0.55, 0.55, 0.55, 1)
        button:SetPressedFontColor(0.55, 0.55, 0.55, 1)
    end
end

function LightsOut.OpenPreferredPanel()
    if not LightsOut.IsInHouse(true) then
        return
    end

    local preferMini = LightsOut.savedVars
        and LightsOut.savedVars.miniPanel
        and LightsOut.savedVars.miniPanel.preferMini == true

    if preferMini and LO_CanOpenMiniPanel() then
        LightsOut.ShowMiniPanel()
    else
        LightsOut.ShowControlWindow()
    end
end

function LightsOut.OpenPreferredPanelWithStartupProgress()
    -- Used by /lo with no arguments. Show this before the first-open panel
    -- validation/rebuild work so the UI does not look idle during startup.
    if not LightsOut.IsInHouse(true) then
        return
    end

    LightsOut.ShowProgressWindow(
        "LightsOut is initializing...",
        "Preparing the control panel. ESO may briefly pause while setup data is checked.",
        0,
        100
    )

    local function openPanelStep()
        LightsOut.UpdateProgressWindow(
            "LightsOut is initializing...",
            "Loading saved setup and preparing the preferred panel...",
            35,
            100
        )

        local ok, err = pcall(function()
            LightsOut.SetActiveHouseSavedVars()
            LightsOut.UpdateProgressWindow(
                "LightsOut is initializing...",
                "Building the LightsOut panel. ESO may pause briefly.",
                70,
                100
            )
            LightsOut.OpenPreferredPanel()
        end)

        if ok then
            LightsOut.UpdateProgressWindow(
                "LightsOut ready",
                "Control panel ready.",
                100,
                100
            )
            LightsOut.HideProgressWindowSoon(250)
        else
            LightsOut.UpdateProgressWindow(
                "LightsOut startup error",
                tostring(err or "Unknown error while opening the panel."),
                100,
                100
            )
            LightsOut.HideProgressWindowSoon(2500)
            LightsOut.Print("LightsOut error while opening panel: " .. tostring(err))
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(openPanelStep, 50)
    else
        openPanelStep()
    end
end



local function LO_RecreateMiniPanelAssignmentsScroll()
    if not (LightsOut.ui and LightsOut.ui.miniPanelAssignmentsGroup) then
        return
    end

    if LightsOut.ui.miniPanelAssignmentsScroll then
        LightsOut.ui.miniPanelAssignmentsScroll:SetHidden(true)
        if WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
            WINDOW_MANAGER:DestroyControl(LightsOut.ui.miniPanelAssignmentsScroll)
        end
    end

    local assignmentsGroup = LightsOut.ui.miniPanelAssignmentsGroup
    local assignmentScroll = WINDOW_MANAGER:CreateControlFromVirtual(LO_UniqueControlName("LightsOutMiniAssignmentsScroll"), assignmentsGroup, "ZO_ScrollContainer")
    assignmentScroll:SetAnchor(TOPLEFT, assignmentsGroup, TOPLEFT, 12, 38)
    assignmentScroll:SetAnchor(BOTTOMRIGHT, assignmentsGroup, BOTTOMRIGHT, -12, -12)

    LightsOut.ui.miniPanelAssignmentsScroll = assignmentScroll
    LightsOut.ui.miniPanelAssignmentsScrollChild = assignmentScroll:GetNamedChild("ScrollChild")
end

local function LO_RebuildMiniPanelAssignmentsOnOpen()
    if type(LO_CloseTeamNameEditor) == "function" then
        LO_CloseTeamNameEditor(false)
    end

    LO_RecreateMiniPanelAssignmentsScroll()

    if type(LightsOut.RefreshMiniPanelAssignments) == "function" then
        LightsOut.RefreshMiniPanelAssignments()
    end
end


function LightsOut.ShowMiniPanel()
    LO_CloseTeamNameEditor(false)
    LO_CancelActiveTeamNameEditForPanelSwitch()
    if not LO_CanOpenMiniPanel() then
        LightsOut.savedVars = LightsOut.savedVars or {}
        LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
        LightsOut.savedVars.miniPanel.preferMini = false
        LightsOut.ShowControlWindow()
        return
    end

    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
    LightsOut.savedVars.miniPanel.preferMini = true

    if LightsOut.ui and LightsOut.ui.controlWindow then
        LightsOut.ui.controlWindow:SetHidden(true)
    end

    local window = LightsOut.CreateMiniPanelWindow()
    window:SetHidden(false)
    LightsOut.RefreshMiniPanel()

    LO_RebuildMiniPanelAssignmentsOnOpen()
end

function LightsOut.ToggleMiniPanel()
    LO_CloseTeamNameEditor(false)
    LO_CancelActiveTeamNameEditForPanelSwitch()
    if not LightsOut.IsInHouse(true) then
        return
    end

    if not LO_CanOpenMiniPanel() then
        LightsOut.savedVars = LightsOut.savedVars or {}
        LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
        LightsOut.savedVars.miniPanel.preferMini = false
        LightsOut.ShowControlWindow()
        return
    end

    local window = LightsOut.CreateMiniPanelWindow()
    if window:IsHidden() then
        LightsOut.savedVars = LightsOut.savedVars or {}
        LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
        LightsOut.savedVars.miniPanel.preferMini = true

        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.ui.controlWindow:SetHidden(true)
        end

        window:SetHidden(false)
        LightsOut.RefreshMiniPanel()

        LO_RebuildMiniPanelAssignmentsOnOpen()
    else
        -- The mini panel no longer closes by itself. Toggling it while open
        -- returns the user to the full control panel instead.
        LightsOut.ReturnFromMiniPanelToFullPanel()
    end
end

function LightsOut.CreateControlWindow()
    if LightsOut.ui.controlWindow then return LightsOut.ui.controlWindow end
    local cp = LO_CP()
    cp.height = math.max(844, tonumber(cp.height or 844) or 844)
    local window = WINDOW_MANAGER:CreateTopLevelWindow("LightsOutControlWindow")
    window:SetDimensions(cp.width or 1360, cp.height)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, cp.left or 90, cp.top or 70)
    window:SetMouseEnabled(false)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    if window.SetResizable then window:SetResizable(false) end
    if window.SetResizeHandleSize then window:SetResizeHandleSize(0) end
    if window.SetDimensionConstraints then window:SetDimensionConstraints(1180, 764, 1600, 1024) end
    LO_Backdrop(window, 0.88)
    local dragHandle = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(TOPRIGHT, window, TOPRIGHT, -52, 0)
    dragHandle:SetHeight(54)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnMouseDown", function() window:StartMoving() end)
    dragHandle:SetHandler("OnMouseUp", function() window:StopMovingOrResizing() end)

    local title = LO_Label(window, "LightsOut Control Panel", "ZoFontWinH1", 1, 1, 1, 1)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 12)
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function() window:StartMoving() end)
    title:SetHandler("OnMouseUp", function() window:StopMovingOrResizing() end)
    local close = LO_Button(window, "X", 30, 28, "gray")
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
    close:SetHandler("OnClicked", function() window:SetHidden(true) end)
    local nav = LO_Panel(window, 18, 62, 200, 744)
    local setupButton = LO_Button(nav, LO_IsGameStatusVisibleState() and "  Game Status" or "  Game Setup", 176, 34, "gray")
    setupButton:SetAnchor(TOPLEFT, nav, TOPLEFT, 12, 14)
    setupButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    setupButton:SetHandler("OnClicked", function()
        if LO_IsGameStatusVisibleState() then
            -- During a game, or after a game has ended/cancelled, return to the
            -- in-game status/overview page.
            LO_ShowPage("overview")
        else
            -- When no game is active, return to the normal setup page.
            LO_ShowPage("setup")
        end
    end)
    LightsOut.ui.setupNavButton = setupButton
    local miniButton = LO_Button(nav, "  Mini Panel", 176, 34, "gray")
    miniButton:SetAnchor(TOPLEFT, setupButton, BOTTOMLEFT, 0, 12)
    miniButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    miniButton:SetHandler("OnClicked", function() LightsOut.ToggleMiniPanel() end)
    LightsOut.ui.miniNavButton = miniButton
    LO_ApplyMiniPanelNavButtonEnabledState(miniButton)

    local teamInfoButton = LO_Button(nav, "  Team Info to Chat", 176, 34, "gray")
    teamInfoButton:SetAnchor(TOPLEFT, miniButton, BOTTOMLEFT, 0, 12)
    teamInfoButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    teamInfoButton:SetHandler("OnClicked", function()
        if type(LightsOut.HandleSlashCommand) == "function" then
            LightsOut.HandleSlashCommand("teams")
        else
            LightsOut.Print("Team info to chat is not available.")
        end
    end)
    LightsOut.ui.teamInfoNavButton = teamInfoButton

    local aboutButton = LO_Button(nav, "  About", 176, 34, "gray")
    aboutButton:SetAnchor(TOPLEFT, teamInfoButton, BOTTOMLEFT, 0, 12)
    aboutButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    aboutButton:SetHandler("OnClicked", function() LO_ShowPage("about") end)
    LightsOut.ui.aboutNavButton = aboutButton
    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    content:SetAnchor(TOPLEFT, window, TOPLEFT, 230, 62)
    content:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -22)
    LightsOut.ui.content = content
    window:SetHandler("OnMoveStop", function(self)
        local saved = LO_CP()
        saved.left = self:GetLeft()
        saved.top = self:GetTop()
    end)
    window:SetHandler("OnResizeStop", function(self)
        local saved = LO_CP()
        saved.width = self:GetWidth()
        saved.height = self:GetHeight()
        LightsOut.RebuildControlPanel()
    end)
    LightsOut.ui.controlWindow = window
    LightsOut.RebuildControlPanel({ refreshCounts = true })
    return window
end

function LightsOut.RebuildControlPanel(options)
    if not LightsOut.ui or not LightsOut.ui.controlWindow then return end

    options = options or {}
    local refreshCounts = options.refreshCounts == true

    LO_CloseTeamNameEditor(false)
    LO_CloseStatePicker(false)

    -- Full furnishing recounts are expensive in populated houses.
    -- Rebuild the UI from cached matchingCount/furnitureIds by default, and
    -- only rescan when the caller explicitly knows house contents may be stale.
    if refreshCounts then
        LightsOut.RefreshTeamMatchingCounts()
    end

    if type(LO_ApplyMiniPanelNavButtonEnabledState) == "function" then
        LO_ApplyMiniPanelNavButtonEnabledState(LightsOut.ui.miniNavButton)
    end

    LightsOut.ui.pages = {}

    -- ESO controls do not support DestroyAllChildren(), so rebuild by replacing
    -- the content container. This avoids the /lo controls error where Lua tried
    -- to call a missing DestroyAllChildren method.
    if LightsOut.ui.content then
        LightsOut.ui.content:SetHidden(true)
        if WINDOW_MANAGER and WINDOW_MANAGER.DestroyControl then
            WINDOW_MANAGER:DestroyControl(LightsOut.ui.content)
        end
    end

    local window = LightsOut.ui.controlWindow
    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    content:SetAnchor(TOPLEFT, window, TOPLEFT, 230, 62)
    content:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -22)
    LightsOut.ui.content = content

    LightsOut.ui.pages.setup = LO_BuildSetupPage(LightsOut.ui.content)
    LightsOut.ui.pages.overview = LO_BuildOverviewPage(LightsOut.ui.content)
    LightsOut.ui.pages.about = LO_BuildAboutPage(LightsOut.ui.content)

    local g = LightsOut.game or {}
    if LightsOut.ui.activePage == "about" then
        LO_ShowPage("about")
    elseif LO_IsGameStatusVisibleState() then
        LO_ShowPage("overview")
    else
        LO_ShowPage("setup")
    end

    LightsOut.RefreshControlWindow()
    LO_SetControlPanelMousePassthrough(LightsOut.ui.controlWindow)
end

function LightsOut.RefreshControlWindow()
    if not LightsOut.ui or not LightsOut.ui.controlWindow then return end

    if LightsOut.ui.overviewTimerLabel then
        LightsOut.ui.overviewTimerLabel:SetText(LO_TimerText())
        LO_ApplyTimerColor(LightsOut.ui.overviewTimerLabel)
    end

    if LightsOut.ui.setupNavButton then
        LightsOut.ui.setupNavButton:SetText(LO_IsGameStatusVisibleState() and "  Game Status" or "  Game Setup")
    end

    if LightsOut.ui.statusRows then
        for _, rowInfo in pairs(LightsOut.ui.statusRows) do
            local team = rowInfo and rowInfo.team

            if team then
                local active = tonumber(team.currentWinCount or 0) or 0
                local pct = LO_TeamPercent(team, rowInfo.mode or (LightsOut.game and LightsOut.game.mode) or LO_CP().selectedMode or "threshold")

                if rowInfo.countLabel then
                    rowInfo.countLabel:SetText(tostring(active))
                end

                if rowInfo.percentLabel then
                    rowInfo.percentLabel:SetText(tostring(pct) .. "%")
                end
            end
        end
    end

    if LightsOut.ui.overviewLeaderLabel then
        local g = LightsOut.game or {}
        local mode = LightsOut.ui.overviewMode or g.mode or LO_CP().selectedMode or "threshold"
        LightsOut.ui.overviewLeaderLabel:SetText(LO_OverviewResultText(mode))
    end

    LightsOut.RefreshMiniPanel()
end


-- Compatibility shim: older game-state watcher code still calls the former
-- separate status-window refresh function. The new UI uses one combined panel,
-- so route those calls to the combined control panel refresh instead.
function LightsOut.RefreshGameStatusWindow()
    if LightsOut.suppressNextGameStatusWindow == true then
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
        return
    end

    LightsOut.RefreshControlWindow()
    if type(LightsOut.RefreshMiniPanel) == "function" then
        LightsOut.RefreshMiniPanel()
    end
end

function LightsOut.ShowGameStatusWindow()
    if LightsOut.suppressNextGameStatusWindow == true then
        LightsOut.suppressNextGameStatusWindow = false

        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end

        return
    end

    local window = LightsOut.CreateControlWindow()
    window:SetHidden(false)

    local g = LightsOut.game or {}
    LightsOut.RebuildControlPanel({ refreshCounts = not (g.active == true or g.winner ~= nil or g.cancelled == true) })
end

function LightsOut.HideGameStatusWindow()
    if LightsOut.ui and LightsOut.ui.controlWindow then LightsOut.ui.controlWindow:SetHidden(true) end
end

function LightsOut.ToggleGameStatusWindow()
    LightsOut.ToggleControlWindow()
end

function LightsOut.ShowControlWindow()
    LO_CancelActiveTeamNameEditForPanelSwitch()
    if not LightsOut.IsInHouse(true) then
        return
    end

    LightsOut.savedVars = LightsOut.savedVars or {}
    LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
    LightsOut.savedVars.miniPanel.preferMini = false

    local window = LightsOut.CreateControlWindow()
    window:SetHidden(false)
    LightsOut.RebuildControlPanel({ refreshCounts = true })
end

function LightsOut.HideControlWindow()
    if LightsOut.ui and LightsOut.ui.controlWindow then LightsOut.ui.controlWindow:SetHidden(true) end
end

function LightsOut.ToggleControlWindow()
    LO_CancelActiveTeamNameEditForPanelSwitch()
    if not LightsOut.IsInHouse(true) then
        return
    end

    local window = LightsOut.CreateControlWindow()
    if window:IsHidden() then
        LightsOut.savedVars = LightsOut.savedVars or {}
        LightsOut.savedVars.miniPanel = LightsOut.savedVars.miniPanel or {}
        LightsOut.savedVars.miniPanel.preferMini = false
        if LightsOut.ui and LightsOut.ui.miniPanelWindow then
            LightsOut.ui.miniPanelWindow:SetHidden(true)
        end
        window:SetHidden(false)
        LightsOut.RebuildControlPanel({ refreshCounts = true })
    else
        window:SetHidden(true)
    end
end


LightsOut.game = LightsOut.game or {
    active = false,
    mode = nil,
    threshold = 0,
    winner = nil,
    cancelled = false,
    locked = false,
    pulseState = false,
    pulseIntervalMs = 1500,
    pulseSequence = {},
    pulseIndex = 0,
    pulsePreviousFurnitureId = nil,
    startTimeMs = nil,
    endTimeMs = nil,
    frozenTimeMs = nil,
    timeLimitMinutes = nil,
    overtime = false,
    lastTimerRefreshSecond = nil,
}

function LightsOut.GetNowMs()
    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end

    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    return math.floor(GetFrameTimeSeconds() * 1000)
end

function LightsOut.FormatTimerFromSeconds(totalSeconds)
    totalSeconds = math.max(0, math.floor(tonumber(totalSeconds or 0)))

    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60

    return string.format("%02d:%02d", minutes, seconds)
end

function LightsOut.TitleCaseFirst(value)
    value = tostring(value or "")

    if value == "" then
        return "None"
    end

    return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2)
end

function LightsOut.GetGameTimerDisplayText()
    local game = LightsOut.game or {}

    if not game.startTimeMs then
        return ""
    end

    local nowMs = game.frozenTimeMs or LightsOut.GetNowMs()

    if game.overtime and not game.winner and game.endTimeMs then
        return LightsOut.FormatTimerFromSeconds(0)
    end

    if game.endTimeMs then
        local remainingSeconds = math.ceil((game.endTimeMs - nowMs) / 1000)
        return LightsOut.FormatTimerFromSeconds(remainingSeconds)
    end

    local elapsedSeconds = math.floor((nowMs - game.startTimeMs) / 1000)
    return LightsOut.FormatTimerFromSeconds(elapsedSeconds)
end

function LightsOut.GetGameModeDisplayText()
    local game = LightsOut.game or {}

    if not game.mode then
        return "None"
    end

    local text = LightsOut.TitleCaseFirst(game.mode)

    if game.threshold and tonumber(game.threshold or 0) > 0 then
        text = text .. " (" .. tostring(game.threshold) .. ")"
    end

    local timerText = LightsOut.GetGameTimerDisplayText()
    if timerText ~= "" then
        text = text .. " " .. timerText
    end

    return text
end

function LightsOut.ClearRuntimeTeamGameData()
    for _, entry in pairs(LightsOut.savedVars and LightsOut.savedVars.items or {}) do
        entry.trackedFurnitureIds = nil
        entry.targetFurnitureIds = nil
        entry.decoyFurnitureIds = nil
        entry.requiredWinCount = nil
        entry.currentWinCount = nil
        entry.lastStates = nil
    end

    for _, entry in pairs(LightsOut.savedVars and LightsOut.savedVars.warTeams or {}) do
        entry.trackedFurnitureIds = nil
        entry.requiredWinCount = nil
        entry.currentWinCount = nil
        entry.lastStates = nil
        entry.pendingStates = nil
        entry.pendingSinceMs = nil
        entry.appliedStates = nil
    end

    if LightsOut.game then
        LightsOut.game.activeGameEntries = {}
        LightsOut.game.activeGameTeamLookup = {}
    end
end

function LightsOut.ResetActiveGameEntries()
    LightsOut.game = LightsOut.game or {}
    LightsOut.game.activeGameEntries = {}
    LightsOut.game.activeGameTeamLookup = {}
end

function LightsOut.AddActiveGameEntry(key, entry)
    if not key or not entry then return end

    LightsOut.game = LightsOut.game or {}
    LightsOut.game.activeGameEntries = LightsOut.game.activeGameEntries or {}
    LightsOut.game.activeGameTeamLookup = LightsOut.game.activeGameTeamLookup or {}

    if LightsOut.game.activeGameTeamLookup[key] then
        return
    end

    LightsOut.game.activeGameTeamLookup[key] = true
    table.insert(LightsOut.game.activeGameEntries, { key = key, entry = entry })
end

function LightsOut.GetActiveGameEntries(fallbackTable)
    if LightsOut.game and LightsOut.game.activeGameEntries and #LightsOut.game.activeGameEntries > 0 then
        return LightsOut.game.activeGameEntries
    end

    local entries = {}

    for key, entry in pairs(fallbackTable or {}) do
        if entry and entry.enabled ~= false and entry.trackedFurnitureIds then
            table.insert(entries, { key = key, entry = entry })
        end
    end

    return entries
end

local function LightsOut_GetFirstFurnitureIdForEntry(entry)
    if not entry then return nil end

    local sources = {
        entry.trackedFurnitureIds,
        entry.furnitureIds,
        entry.targetFurnitureIds,
        entry.decoyFurnitureIds,
    }

    for _, source in ipairs(sources) do
        if type(source) == "table" then
            local first = source[1]
            if type(first) == "table" and first.furnitureId then
                return first.furnitureId
            elseif first then
                return first
            end
        end
    end

    return nil
end

local function LightsOut_GetFurnitureLinkForChat(entry)
    local fallback = tostring((entry and entry.itemName) or "Unknown Item")
    local furnitureId = LightsOut_GetFirstFurnitureIdForEntry(entry)
    if not furnitureId then return fallback end

    local linkStyle = rawget(_G, "LINK_STYLE_BRACKETS") or rawget(_G, "LINK_STYLE_DEFAULT") or 0
    local function tryFunction(functionName)
        local fn = rawget(_G, functionName)
        if type(fn) ~= "function" then return nil end

        local ok, result = pcall(fn, furnitureId, linkStyle)
        if ok and result and tostring(result) ~= "" then
            return result
        end

        ok, result = pcall(fn, furnitureId)
        if ok and result and tostring(result) ~= "" then
            return result
        end

        return nil
    end

    return tryFunction("GetPlacedHousingFurnitureLink")
        or tryFunction("GetPlacedFurnitureLink")
        or tryFunction("GetHousingFurnitureItemLink")
        or fallback
end

local function LightsOut_NormalizeZoneChatLine(message)
    message = tostring(message or "")

    -- Remove common chat prefixes and ESO formatting/link markup so matching can
    -- tolerate item links, colors, punctuation differences, and channel echoes.
    message = message:gsub("|c%x%x%x%x%x%x", "")
    message = message:gsub("|r", "")
    message = message:gsub("|H.-|h(.-)|h", "%1")
    message = message:gsub("^[%s/]*zone%s+", "")
    message = message:gsub("^[%s/]*z%s+", "")
    message = message:gsub("[%[%]%(%){}<>|]", " ")
    message = message:gsub("[%p]", " ")
    message = message:gsub("%s+", " ")
    message = message:match("^%s*(.-)%s*$") or ""
    return string.lower(message)
end

local function LightsOut_ZoneChatLinesFuzzyMatch(expected, actual)
    expected = LightsOut_NormalizeZoneChatLine(expected)
    actual = LightsOut_NormalizeZoneChatLine(actual)

    if expected == "" or actual == "" then return false end
    if expected == actual then return true end
    if string.find(actual, expected, 1, true) or string.find(expected, actual, 1, true) then return true end

    local expectedWords = {}
    local expectedCount = 0
    for word in string.gmatch(expected, "%S+") do
        if string.len(word) > 2 then
            expectedWords[word] = true
            expectedCount = expectedCount + 1
        end
    end

    if expectedCount == 0 then return false end

    local matched = 0
    for word in string.gmatch(actual, "%S+") do
        if expectedWords[word] then
            matched = matched + 1
            expectedWords[word] = nil
        end
    end

    return (matched / expectedCount) >= 0.72
end

local function LightsOut_IsOwnChatMessage(fromName, fromDisplayName)
    local ownDisplayName = nil

    if type(GetUnitDisplayName) == "function" then
        local ok, result = pcall(GetUnitDisplayName, "player")
        if ok and result and result ~= "" then ownDisplayName = tostring(result) end
    end

    if not ownDisplayName or ownDisplayName == "" then
        return true
    end

    local function clean(value)
        value = tostring(value or ""):lower()
        value = value:gsub("|c%x%x%x%x%x%x", "")
        value = value:gsub("|r", "")
        value = value:match("^%s*(.-)%s*$") or ""
        return value
    end

    local own = clean(ownDisplayName)
    return clean(fromDisplayName) == own or clean(fromName) == own
end

local function LightsOut_IsZoneChatChannel(channelType)
    local zone = rawget(_G, "CHAT_CHANNEL_ZONE")
    if zone ~= nil and channelType == zone then return true end

    -- Some API variants expose localized/alternate zone constants.  If the
    -- channel type is unknown, still allow matching against our own exact text.
    local zoneLanguage = rawget(_G, "CHAT_CHANNEL_ZONE_LANGUAGE_1")
    if zoneLanguage ~= nil and channelType == zoneLanguage then return true end

    return false
end

local function LightsOut_RegisterZoneAnnouncementMonitor()
    if not EVENT_MANAGER or not EVENT_CHAT_MESSAGE_CHANNEL then return end
    EVENT_MANAGER:UnregisterForEvent(LightsOut.name .. "ZoneAnnouncementQueue", EVENT_CHAT_MESSAGE_CHANNEL)
    EVENT_MANAGER:RegisterForEvent(LightsOut.name .. "ZoneAnnouncementQueue", EVENT_CHAT_MESSAGE_CHANNEL, LightsOut.OnZoneAnnouncementChatMessage)
end

local function LightsOut_UnregisterZoneAnnouncementMonitor()
    if EVENT_MANAGER and EVENT_CHAT_MESSAGE_CHANNEL then
        EVENT_MANAGER:UnregisterForEvent(LightsOut.name .. "ZoneAnnouncementQueue", EVENT_CHAT_MESSAGE_CHANNEL)
    end
end

local function LightsOut_PutLineInChatInput(message)
    message = tostring(message or "")
    message = message:gsub("^[%s/]*zone%s+", "")
    message = message:gsub("^[%s/]*z%s+", "")
    message = message:match("^%s*(.-)%s*$") or ""
    if message == "" then return false end

    local chatText = "/zone " .. message

    -- SmartChatMessages-style behavior: prepare the user's chat input only.
    -- The player still presses Enter manually, so no protected auto-send API is used.
    if type(StartChatInput) == "function" then
        local ok = pcall(StartChatInput, chatText)
        if ok then return true end
    end

    local chatSystem = rawget(_G, "CHAT_SYSTEM")
    local editBox = chatSystem and chatSystem.textEntry and chatSystem.textEntry.editBox
    if editBox and editBox.SetText then
        local ok = pcall(function()
            if editBox.TakeFocus then editBox:TakeFocus() end
            editBox:SetText(chatText)
        end)
        if ok then return true end
    end

    return false
end

function LightsOut.ClearZoneAnnouncementQueue()
    LightsOut.pendingZoneAnnouncementLines = nil
    LightsOut.pendingZoneAnnouncementIndex = nil
    LightsOut.pendingZoneAnnouncementCurrentLine = nil
    LightsOut.pendingZoneAnnouncementCurrentIndex = nil
    LightsOut.pendingZoneAnnouncementActive = false
    LightsOut.zoneAnnouncementThrottle = nil
    LightsOut_UnregisterZoneAnnouncementMonitor()
end

local function LightsOut_GetZoneAnnouncementNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local now = GetFrameTimeMilliseconds()
        if now then return tonumber(now) or 0 end
    end

    if type(GetGameTimeMilliseconds) == "function" then
        local now = GetGameTimeMilliseconds()
        if now then return tonumber(now) or 0 end
    end

    if os and type(os.time) == "function" then
        return os.time() * 1000
    end

    return 0
end

local function LightsOut_GetZoneAnnouncementThrottle()
    LightsOut.zoneAnnouncementThrottle = LightsOut.zoneAnnouncementThrottle or {
        burstLimit = 10,
        cooldownMs = 2500,
        lineDelayMs = 150,
        batchCount = 0,
        lastPreparedMs = 0,
        token = 0,
        cooldownNoticeShown = false,
    }

    return LightsOut.zoneAnnouncementThrottle
end

local function LightsOut_ResetZoneAnnouncementBurstIfIdle(throttle, nowMs)
    if not throttle then return end

    nowMs = tonumber(nowMs or LightsOut_GetZoneAnnouncementNowMs()) or 0
    local lastPreparedMs = tonumber(throttle.lastPreparedMs or 0) or 0
    local cooldownMs = tonumber(throttle.cooldownMs or 2500) or 2500

    if lastPreparedMs <= 0 or (nowMs - lastPreparedMs) >= cooldownMs then
        throttle.batchCount = 0
        throttle.cooldownNoticeShown = false
    end
end

local function LightsOut_ShouldDelayNextZoneAnnouncementLine()
    local throttle = LightsOut_GetZoneAnnouncementThrottle()
    local nowMs = LightsOut_GetZoneAnnouncementNowMs()
    LightsOut_ResetZoneAnnouncementBurstIfIdle(throttle, nowMs)

    local burstLimit = tonumber(throttle.burstLimit or 10) or 10
    local batchCount = tonumber(throttle.batchCount or 0) or 0
    if batchCount < burstLimit then
        return false, 0
    end

    local cooldownMs = tonumber(throttle.cooldownMs or 2500) or 2500
    local lastPreparedMs = tonumber(throttle.lastPreparedMs or 0) or 0
    local elapsedMs = nowMs - lastPreparedMs
    local remainingMs = math.max(1, cooldownMs - elapsedMs)

    return true, remainingMs
end

local function LightsOut_RecordZoneAnnouncementLinePrepared()
    local throttle = LightsOut_GetZoneAnnouncementThrottle()
    local nowMs = LightsOut_GetZoneAnnouncementNowMs()
    LightsOut_ResetZoneAnnouncementBurstIfIdle(throttle, nowMs)

    throttle.batchCount = (tonumber(throttle.batchCount or 0) or 0) + 1
    throttle.lastPreparedMs = nowMs
    throttle.cooldownNoticeShown = false
end

function LightsOut.PrepareNextZoneAnnouncementLine(silentIfDone)
    local lines = LightsOut.pendingZoneAnnouncementLines or {}
    local index = tonumber(LightsOut.pendingZoneAnnouncementIndex or 1) or 1
    local line = lines[index]

    if not line then
        LightsOut.ClearZoneAnnouncementQueue()
        if not silentIfDone then
            LightsOut.Print("All LightsOut zone announcement lines have been prepared.")
        end
        return false
    end

    local shouldDelay, delayMs = LightsOut_ShouldDelayNextZoneAnnouncementLine()
    if shouldDelay then
        local throttle = LightsOut_GetZoneAnnouncementThrottle()
        throttle.token = (tonumber(throttle.token or 0) or 0) + 1
        local token = throttle.token

        if not throttle.cooldownNoticeShown then
            LightsOut.Print(zo_strformat("LightsOut Team Info is pausing briefly after <<1>> prepared line(s) to avoid sending zone chat too quickly.", tostring(throttle.burstLimit or 10)))
            throttle.cooldownNoticeShown = true
        end

        local function continueAfterCooldown()
            local currentThrottle = LightsOut_GetZoneAnnouncementThrottle()
            if currentThrottle.token ~= token then return end
            currentThrottle.batchCount = 0
            currentThrottle.cooldownNoticeShown = false

            if LightsOut.pendingZoneAnnouncementActive then
                LightsOut.PrepareNextZoneAnnouncementLine(true)
            end
        end

        if type(zo_callLater) == "function" then
            zo_callLater(continueAfterCooldown, delayMs)
        else
            continueAfterCooldown()
        end

        return true
    end

    local ok = LightsOut_PutLineInChatInput(line)
    if ok then
        LightsOut.pendingZoneAnnouncementActive = true
        LightsOut.pendingZoneAnnouncementCurrentLine = line
        LightsOut.pendingZoneAnnouncementCurrentIndex = index
        LightsOut.pendingZoneAnnouncementIndex = index + 1
        LightsOut_RecordZoneAnnouncementLinePrepared()
        LightsOut_RegisterZoneAnnouncementMonitor()

        local remaining = #lines - index
        if remaining > 0 then
            LightsOut.Print(zo_strformat("Prepared LightsOut zone announcement line <<1>>/<<2>>. Press Enter to send it; the next line will be prepared automatically.", tostring(index), tostring(#lines)))
        else
            LightsOut.Print(zo_strformat("Prepared final LightsOut zone announcement line <<1>>/<<2>>. Press Enter to send it.", tostring(index), tostring(#lines)))
        end
    else
        LightsOut.Print("Could not open the chat input. Copy this manually to zone chat: /zone " .. tostring(line))
    end

    return ok
end

function LightsOut.OnZoneAnnouncementChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    if not LightsOut.pendingZoneAnnouncementActive then return end
    if not LightsOut.pendingZoneAnnouncementCurrentLine then return end
    if not LightsOut_IsOwnChatMessage(fromName, fromDisplayName) then return end

    -- Prefer zone-channel confirmation, but still allow exact/fuzzy matching if
    -- a client/API variant reports a different channel constant.
    local channelLooksRight = LightsOut_IsZoneChatChannel(channelType)
    local messageMatches = LightsOut_ZoneChatLinesFuzzyMatch(LightsOut.pendingZoneAnnouncementCurrentLine, text)

    if not messageMatches then return end
    if not channelLooksRight then
        LightsOut.Dbg("Zone announcement line matched from own chat without recognized zone channel.")
    end

    LightsOut.pendingZoneAnnouncementCurrentLine = nil
    LightsOut.pendingZoneAnnouncementCurrentIndex = nil

    local function prepareNext()
        if LightsOut.pendingZoneAnnouncementActive then
            LightsOut.PrepareNextZoneAnnouncementLine(true)
        end
    end

    local throttle = LightsOut_GetZoneAnnouncementThrottle()
    local delayMs = tonumber(throttle.lineDelayMs or 150) or 150

    if type(zo_callLater) == "function" then
        zo_callLater(prepareNext, delayMs)
    else
        prepareNext()
    end
end

function LightsOut.QueueZoneAnnouncementLines(lines)
    if LightsOut.pendingZoneAnnouncementActive then
        local currentIndex = tonumber(LightsOut.pendingZoneAnnouncementCurrentIndex or 0) or 0
        local total = #(LightsOut.pendingZoneAnnouncementLines or {})
        if currentIndex > 0 and total > 0 then
            LightsOut.Print(zo_strformat("LightsOut Team Info is already preparing line <<1>>/<<2>>. Press Enter to continue, or wait for the current queue to finish.", tostring(currentIndex), tostring(total)))
        else
            LightsOut.Print("LightsOut Team Info is already preparing zone announcement lines. Press Enter to continue, or wait for the current queue to finish.")
        end
        return
    end

    LightsOut.ClearZoneAnnouncementQueue()
    LightsOut.pendingZoneAnnouncementLines = lines or {}
    LightsOut.pendingZoneAnnouncementIndex = 1
    LightsOut_GetZoneAnnouncementThrottle()

    if #LightsOut.pendingZoneAnnouncementLines == 0 then
        return
    end

    LightsOut.Print("LightsOut prepared " .. tostring(#LightsOut.pendingZoneAnnouncementLines) .. " zone announcement line(s). Press Enter to send each line; the next line will be inserted automatically. Team Info will pause briefly after every 10 prepared lines to avoid chat flooding.")
    LightsOut.PrepareNextZoneAnnouncementLine()
end

function LightsOut.BuildTeamInfoEntriesForMode(mode)
    mode = LO_NormalizeModeKey(mode or (LightsOut.game and LightsOut.game.mode) or (LO_CP().selectedMode))

    if LightsOut.game and LightsOut.game.activeGameEntries and #LightsOut.game.activeGameEntries > 0 then
        local isWar = mode == "war"
        for _, activeEntry in ipairs(LightsOut.game.activeGameEntries or {}) do
            if activeEntry and activeEntry.entry then
                LO_ApplyTeamNameForMode(activeEntry.entry, mode, isWar)
            end
        end
        return LightsOut.game.activeGameEntries, mode
    end

    LightsOut.SetActiveHouseSavedVars()
    LO_LoadModeConfig(mode)
    LO_ApplyModeEnabledState(mode)

    local entries = {}
    local source = mode == "war" and (LightsOut.GetWarTeamTable and LightsOut.GetWarTeamTable() or {}) or (LightsOut.savedVars and LightsOut.savedVars.items or {})

    for key, entry in pairs(source or {}) do
        if entry and LO_IsTeamEnabledForMode(entry, mode) then
            table.insert(entries, { key = key, entry = entry })
        end
    end

    table.sort(entries, function(a, b)
        local ea = a and a.entry or {}
        local eb = b and b.entry or {}
        local ia = tostring(ea.itemName or "")
        local ib = tostring(eb.itemName or "")
        if ia ~= ib then return ia < ib end

        local isWar = mode == "war"
        local an = LO_GetTeamNameForMode(ea, mode, isWar)
        local bn = LO_GetTeamNameForMode(eb, mode, isWar)
        return tostring(an or a.key or "") < tostring(bn or b.key or "")
    end)

    return entries, mode
end

function LightsOut.AnnounceActiveGameTeamsToZone(mode)
    local entries, resolvedMode = LightsOut.BuildTeamInfoEntriesForMode(mode)
    if not entries or #entries == 0 then
        LightsOut.Print("No enabled LightsOut teams are available for the current game type.")
        return
    end

    local lines = {}

    local modeLabel = LO_ModeLabel(resolvedMode or mode or (LightsOut.game and LightsOut.game.mode) or "")
    local headerText = "LightsOut " .. tostring(modeLabel)

    if resolvedMode == "target" then
        local cp = LO_CP()
        local requiredCount

        if LightsOut.game and LightsOut.game.active == true and tonumber(LightsOut.game.threshold) and tonumber(LightsOut.game.threshold) > 0 then
            requiredCount = tonumber(LightsOut.game.threshold)
        else
            requiredCount = LO_ResolveRequiredCount("target", cp.requiredCount, true)
        end

        local confirmText = cp.confirmCounted == true and "On" or "Off"
        headerText = headerText .. " - Confirm: " .. tostring(confirmText) .. " - Required: " .. tostring(requiredCount) .. " -"
    elseif resolvedMode == "threshold" then
        local cp = LO_CP()
        local requiredCountText

        if not (LightsOut.game and LightsOut.game.active == true) and LO_IsAllRequiredCount(cp.requiredCount) then
            requiredCountText = "ALL"
        else
            local requiredCount

            if LightsOut.game and LightsOut.game.active == true and tonumber(LightsOut.game.threshold) and tonumber(LightsOut.game.threshold) > 0 then
                requiredCount = tonumber(LightsOut.game.threshold)
            else
                requiredCount = LO_ResolveRequiredCount("threshold", cp.requiredCount, true)
            end

            if LO_IsAllRequiredCount(cp.requiredCount) and (not requiredCount or tonumber(requiredCount) == 0) then
                requiredCountText = "ALL"
            else
                requiredCountText = tostring(requiredCount)
            end
        end

        headerText = headerText .. " - Required: " .. tostring(requiredCountText) .. " -"
    end

    table.insert(lines, headerText .. " Team scoring states:")

    for _, activeEntry in ipairs(entries) do
        local entry = activeEntry and activeEntry.entry
        if entry then
            local isWar = (resolvedMode == "war")
            local teamName = tostring(LO_GetTeamNameForMode(entry, resolvedMode, isWar) or activeEntry.key or "Unknown Team")
            local itemLink = LightsOut_GetFurnitureLinkForChat(entry)
            local stateName = tostring(entry.stateName or ("State " .. tostring(entry.state or "?")))
            table.insert(lines, zo_strformat("LightsOut: <<1>> — <<2>> — scoring state: <<3>>", teamName, itemLink, stateName))
        end
    end

    LightsOut.lastZoneAnnouncementLines = lines
    LightsOut.QueueZoneAnnouncementLines(lines)
end

function LightsOut.ShowTeamInfo()
    local mode = (LightsOut.game and LightsOut.game.mode) or (LO_CP().selectedMode)
    LightsOut.AnnounceActiveGameTeamsToZone(mode)
end

function LightsOut.StopThresholdGame(clearWinner)
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "ThresholdWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WarWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WinnerPulse")
    LightsOut.ClearRuntimeTeamGameData()

    LightsOut.game = LightsOut.game or {}
    LightsOut.game.active = false
    LightsOut.game.mode = nil
    LightsOut.game.threshold = 0
    LightsOut.game.locked = false
    LightsOut.game.cancelled = false
    LightsOut.game.pulseState = false
    LightsOut.game.pulseTeamKey = nil
    LightsOut.game.pulseFurnitureLookup = {}
    LightsOut.game.pulseSequence = {}
    LightsOut.game.pulseIndex = 0
    LightsOut.game.pulsePreviousFurnitureId = nil
    LightsOut.game.pulseIntervalMs = 1500
    LightsOut.game.warNeutralState = nil
    LightsOut.game.startTimeMs = nil
    LightsOut.game.endTimeMs = nil
    LightsOut.game.frozenTimeMs = nil
    LightsOut.game.timeLimitMinutes = nil
    LightsOut.game.overtime = false
    LightsOut.game.lastTimerRefreshSecond = nil
    LightsOut.game.activeGameEntries = {}
    LightsOut.game.activeGameTeamLookup = {}

    if clearWinner then
        LightsOut.game.winner = nil
        LightsOut.game.winnerKey = nil
    end
end

function LightsOut.CancelGame()
    if not LightsOut.game or (not LightsOut.game.active and not LightsOut.game.mode) then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "ThresholdWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WarWatcher")
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WinnerPulse")

    LightsOut.game.active = false
    LightsOut.game.locked = true
    LightsOut.game.cancelled = true
    LightsOut.game.frozenTimeMs = LightsOut.GetNowMs()
    LightsOut.game.pulseState = false
    LightsOut.game.pulseTeamKey = nil
    LightsOut.game.pulseFurnitureLookup = {}
    LightsOut.game.pulseSequence = {}
    LightsOut.game.pulseIndex = 0
    LightsOut.game.pulsePreviousFurnitureId = nil
    LightsOut.game.activeGameEntries = {}
    LightsOut.game.activeGameTeamLookup = {}

    local cancellationMode = LightsOut.game.mode or (LO_CP and LO_CP().selectedMode) or "threshold"
    local cancellationLeaders = LO_Leaders(cancellationMode)

    LightsOut.Print("Game Cancelled!")

    if cancellationLeaders and cancellationLeaders ~= "None" then
        LightsOut.Print("Leader(s) at cancellation: " .. tostring(cancellationLeaders))
    end

    if LightsOut.ui and LightsOut.ui.controlWindow then
        LightsOut.RebuildControlPanel()
    else
        LightsOut.RefreshGameStatusWindow()
        LightsOut.RefreshControlWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
    end
end

function LightsOut.ShowThresholdCountMismatch()
    LightsOut.Print("|cFF0000Item counts are not equal. Start cancelled.|r")

    for key, entry in pairs(LightsOut.savedVars.items or {}) do
        LightsOut.Print(zo_strformat(
            "Team: |c00FF00<<1>>|r - Item: |c00FF00<<2>>|r - Matching Count: |cFFFF00<<3>>|r",
            tostring(entry.name or key),
            tostring(entry.itemName or "Unknown"),
            tostring(entry.matchingCount or 0)
        ))
    end
end

function LightsOut.GetNonWinningState(winningState)
    winningState = tonumber(winningState)

    if winningState == 0 then
        return 1
    end

    return 0
end

function LightsOut.TryShowWinnerAnnouncement(message)
    if CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.AddMessage then
        pcall(function()
            CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_DISPLAY_ANNOUNCEMENT, CSA_EVENT_SMALL_TEXT, nil, message)
        end)
    end
end

function LightsOut.TryPlayWinnerSound()
    if type(PlaySound) == "function" and type(SOUNDS) == "table" then
        pcall(function()
            PlaySound(SOUNDS.DUEL_WON or SOUNDS.QUEST_COMPLETE or SOUNDS.OBJECTIVE_COMPLETE)
        end)
    end
end

function LightsOut.GetWinnerPulseThrottle(itemCount)
    itemCount = tonumber(itemCount or 0) or 0

    -- ESO housing can disconnect the player if too many furnishing state
    -- changes are requested too quickly. Scale both the batch size and the
    -- delay by the number of winning/twinkling items so large games create a
    -- slower, safer sparkle instead of a rapid strobe.
    if itemCount <= 10 then
        return 1, 1800
    elseif itemCount <= 25 then
        return 2, 2600
    elseif itemCount <= 50 then
        return 3, 3800
    elseif itemCount <= 100 then
        return 4, 5200
    elseif itemCount <= 200 then
        return 5, 7200
    end

    return 6, 9500
end

function LightsOut.GetWinnerPulseFurnitureIds(winnerKey, entry)
    local pulseIds = {}

    if not entry or not entry.trackedFurnitureIds then
        return pulseIds
    end

    local winningState = tonumber(entry.state)

    -- War mode should only pulse the items that are actually counted for the
    -- winning team: the furnishings whose applied/stable state is currently
    -- that team's win state. This prevents the full War item set from flashing.
    if LightsOut.game and LightsOut.game.mode == "war" then
        local appliedStates = entry.appliedStates or {}

        for _, furnitureInfo in ipairs(entry.trackedFurnitureIds or {}) do
            local furnitureId = furnitureInfo and furnitureInfo.furnitureId

            if furnitureId and appliedStates[furnitureId] ~= nil and tonumber(appliedStates[furnitureId]) == winningState then
                table.insert(pulseIds, furnitureId)
            end
        end

        return pulseIds
    end

    -- Threshold/Target keep the existing behavior: pulse the winning team's
    -- tracked items in sequence.
    for _, furnitureInfo in ipairs(entry.trackedFurnitureIds or {}) do
        local furnitureId = furnitureInfo and furnitureInfo.furnitureId

        if furnitureId then
            table.insert(pulseIds, furnitureId)
        end
    end

    return pulseIds
end

function LightsOut.StartWinnerPulse(winnerKey)
    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WinnerPulse")

    local entry = LightsOut.GetActiveGameTeamTable()[winnerKey]
    if not entry or not entry.trackedFurnitureIds then
        return
    end

    LightsOut.game.pulseTeamKey = winnerKey
    LightsOut.game.pulseFurnitureLookup = {}
    LightsOut.game.pulseSequence = LightsOut.GetWinnerPulseFurnitureIds(winnerKey, entry)
    LightsOut.game.pulseIndex = 0
    LightsOut.game.pulsePreviousFurnitureId = nil

    local pulseMaxChanges, pulseIntervalMs = LightsOut.GetWinnerPulseThrottle(#(LightsOut.game.pulseSequence or {}))
    LightsOut.game.pulseIntervalMs = pulseIntervalMs
    LightsOut.game.pulseMaxChangesPerTick = pulseMaxChanges

    LightsOut.game.pulseWarStateIndex = nil
    LightsOut.game.pulseWarStates = nil
    LightsOut.game.pulseWarStateLookup = nil
    LightsOut.game.pulseWarCurrentStates = nil
    LightsOut.game.pulseWarMaxChangesPerTick = pulseMaxChanges
    LightsOut.game.pulseStandardCurrentStates = nil
    LightsOut.game.pulseStandardMaxChangesPerTick = pulseMaxChanges

    for _, furnitureId in ipairs(LightsOut.game.pulseSequence or {}) do
        if furnitureId then
            LightsOut.game.pulseFurnitureLookup[furnitureId] = true
        end
    end

    if #(LightsOut.game.pulseSequence or {}) == 0 then
        LightsOut.Dbg("Winner pulse skipped because no winning-state furniture was found.")
        return
    end

    LightsOut.Dbg(zo_strformat(
        "Winner pulse throttle: <<1>> item(s), <<2>> change(s) every <<3>>ms.",
        tostring(#(LightsOut.game.pulseSequence or {})),
        tostring(LightsOut.game.pulseMaxChangesPerTick or 0),
        tostring(LightsOut.game.pulseIntervalMs or 0)
    ))

    -- In War mode, winner celebration cycles the winning items through every
    -- possible state of the shared War furnishing, rather than alternating only
    -- between the winner state and a neutral/alternate state.
    if LightsOut.game.mode == "war" then
        local numStates = tonumber(entry.numStates or 0) or 0

        if numStates < 2 then
            local firstFurnitureId = LightsOut.game.pulseSequence[1]
            if firstFurnitureId then
                numStates = tonumber(GetPlacedHousingFurnitureNumObjectStates(firstFurnitureId) or 0) or 0
            end
        end

        if numStates >= 2 then
            LightsOut.game.pulseWarStates = {}
            LightsOut.game.pulseWarStateLookup = {}
            LightsOut.game.pulseWarCurrentStates = {}

            for stateIndex = 0, numStates - 1 do
                table.insert(LightsOut.game.pulseWarStates, stateIndex)
                LightsOut.game.pulseWarStateLookup[stateIndex] = #LightsOut.game.pulseWarStates
            end

            -- Start every winning/twinkling item from the winner's state. During
            -- the celebration, each pulse tick randomly advances only a small
            -- subset of items to its next state. This creates a twinkle effect
            -- and avoids sending a large burst of state changes all at once.
            local winningState = tonumber(entry.state)
            LightsOut.game.pulseWarStateIndex = LightsOut.game.pulseWarStateLookup[winningState] or 1

            for _, furnitureId in ipairs(LightsOut.game.pulseSequence or {}) do
                if furnitureId then
                    LightsOut.game.pulseWarCurrentStates[furnitureId] = winningState
                end
            end
        end
    else
        LightsOut.game.pulseStandardCurrentStates = {}
        local winningState = tonumber(entry.state)

        for _, furnitureId in ipairs(LightsOut.game.pulseSequence or {}) do
            if furnitureId then
                LightsOut.game.pulseStandardCurrentStates[furnitureId] = winningState
            end
        end
    end

    EVENT_MANAGER:RegisterForUpdate(LightsOut.name .. "WinnerPulse", LightsOut.game.pulseIntervalMs, function()
        local pulseEntry = LightsOut.GetActiveGameTeamTable()[winnerKey]
        local sequence = LightsOut.game.pulseSequence or {}

        if not LightsOut.game.locked or not pulseEntry or not pulseEntry.trackedFurnitureIds or #sequence == 0 then
            EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WinnerPulse")
            return
        end

        if LightsOut.game.mode == "war" and LightsOut.game.pulseWarStates and #LightsOut.game.pulseWarStates > 0 then
            local maxChanges = math.max(1, tonumber(LightsOut.game.pulseWarMaxChangesPerTick or 6) or 6)
            maxChanges = math.min(maxChanges, #sequence)

            -- Randomly choose up to maxChanges different furnishings on each
            -- pulse tick. Each chosen item advances to its next available state,
            -- so multi-state War winners still cycle through all states, but the
            -- celebration is throttled to avoid too many state-change requests.
            local available = {}
            for index = 1, #sequence do
                available[index] = index
            end

            LightsOut.game.pulseWarCurrentStates = LightsOut.game.pulseWarCurrentStates or {}
            LightsOut.game.pulseWarStateLookup = LightsOut.game.pulseWarStateLookup or {}

            for changeIndex = 1, maxChanges do
                local pickIndex = math.random(changeIndex, #available)
                available[changeIndex], available[pickIndex] = available[pickIndex], available[changeIndex]

                local furnitureId = sequence[available[changeIndex]]
                if furnitureId then
                    local currentState = tonumber(LightsOut.game.pulseWarCurrentStates[furnitureId])
                    local stateIndex = LightsOut.game.pulseWarStateLookup[currentState]

                    if not stateIndex then
                        stateIndex = tonumber(LightsOut.game.pulseWarStateIndex or 1) or 1
                    end

                    local nextIndex = (stateIndex % #LightsOut.game.pulseWarStates) + 1
                    local nextState = LightsOut.game.pulseWarStates[nextIndex]

                    if nextState ~= nil then
                        HousingEditorRequestChangeState(furnitureId, nextState)
                        LightsOut.game.pulseWarCurrentStates[furnitureId] = nextState
                    end
                end
            end

            return
        end

        local winningState = tonumber(pulseEntry.state)
        local flashState = LightsOut.GetNonWinningState(winningState)

        -- Threshold/Target winner celebration now uses the same throttled
        -- twinkle approach as War mode: each pulse tick randomly changes no
        -- more than 10 winning items instead of sending state changes for the
        -- whole set at once. Each selected item toggles between the winning
        -- state and the non-winning flash state.
        local maxChanges = math.max(1, tonumber(LightsOut.game.pulseStandardMaxChangesPerTick or 6) or 6)
        maxChanges = math.min(maxChanges, #sequence)

        local available = {}
        for index = 1, #sequence do
            available[index] = index
        end

        LightsOut.game.pulseStandardCurrentStates = LightsOut.game.pulseStandardCurrentStates or {}

        for changeIndex = 1, maxChanges do
            local pickIndex = math.random(changeIndex, #available)
            available[changeIndex], available[pickIndex] = available[pickIndex], available[changeIndex]

            local furnitureId = sequence[available[changeIndex]]
            if furnitureId then
                local currentState = tonumber(LightsOut.game.pulseStandardCurrentStates[furnitureId])
                if currentState == nil then
                    currentState = winningState
                end

                local nextState = winningState
                if currentState == winningState then
                    nextState = flashState
                end

                if nextState ~= nil then
                    HousingEditorRequestChangeState(furnitureId, nextState)
                    LightsOut.game.pulseStandardCurrentStates[furnitureId] = nextState
                end
            end
        end
    end)
end

function LightsOut.ClearActiveGameDueToLeavingHouse()
    if not LightsOut.game or not LightsOut.game.active then
        return
    end

    LightsOut.StopThresholdGame(true)
    LightsOut.HideGameStatusWindow()
    LightsOut.Print("Game cleared because you left the house.")
end

function LightsOut.GetHighestPercentTeams()
    local highestPercent = nil
    local leaders = {}

    for key, entry in pairs(LightsOut.GetActiveGameTeamTable()) do
        if entry.trackedFurnitureIds then
            local currentCount = tonumber(entry.currentWinCount or 0) or 0
            local requiredCount = tonumber(entry.requiredWinCount or LightsOut.game.threshold or 0) or 0
            local percent = 0

            if requiredCount > 0 then
                percent = (currentCount / requiredCount) * 100
            end

            if highestPercent == nil or percent > highestPercent then
                highestPercent = percent
                leaders = {
                    {
                        key = key,
                        entry = entry,
                        percent = percent,
                    }
                }
            elseif percent == highestPercent then
                table.insert(leaders, {
                    key = key,
                    entry = entry,
                    percent = percent,
                })
            end
        end
    end

    return leaders, highestPercent or 0
end

function LightsOut.CheckThresholdTimerExpired()
    local game = LightsOut.game or {}

    if game.locked or not game.endTimeMs then
        return false
    end

    local nowMs = LightsOut.GetNowMs()
    if nowMs < game.endTimeMs and not game.overtime then
        return false
    end

    local leaders, highestPercent = LightsOut.GetHighestPercentTeams()

    if tonumber(highestPercent or 0) > 0 and #leaders == 1 then
        LightsOut.DeclareThresholdWinner(leaders[1].key, leaders[1].entry)
        return true
    end

    if #leaders > 1 or tonumber(highestPercent or 0) <= 0 then
        if not game.overtime then
            if tonumber(highestPercent or 0) <= 0 then
                LightsOut.Print("Time expired with no current leader. Overtime continues until one team has progress toward the win.")
            else
                LightsOut.Print("Time expired with a tie. Overtime continues until one team has the highest percentage.")
            end
        end

        game.overtime = true
        if game.endTimeMs then game.frozenTimeMs = game.endTimeMs end
        LightsOut.RefreshGameStatusWindow()
    end

    return false
end

function LightsOut.OnPlayerActivated()
    local previousHouseKey = LightsOut.savedVars and LightsOut.savedVars.activeHouseKey or nil
    local currentHouseKey = LightsOut.GetCurrentHouseKey()
    local inHouse = currentHouseKey ~= nil
    local houseChanged = previousHouseKey ~= nil and previousHouseKey ~= currentHouseKey

    -- Print the welcome/play message only when transitioning into a house,
    -- or when moving from one house directly to another. The nil first-run
    -- guard prevents duplicate chat spam after /reloadui while already inside
    -- a house.
    if LightsOut.wasInHouse == nil then
        LightsOut.wasInHouse = inHouse
    else
        if inHouse and (not LightsOut.wasInHouse or houseChanged) then
            LightsOut.Print("Lights Out by @evainefaye Enabled, type /lo to play! Help included in the about section.")
        end

        LightsOut.wasInHouse = inHouse
    end

    if houseChanged and LightsOut.ui then
        if LightsOut.ui.controlWindow then
            LightsOut.ui.controlWindow:SetHidden(true)
        end

        -- Treat the mini panel like the main control window when zoning away
        -- from a house or moving between houses. It should not stay open and
        -- try to refresh against house-scoped data that no longer exists.
        if LightsOut.ui.miniPanelWindow then
            LightsOut.ui.miniPanelWindow:SetHidden(true)
        end
    end

    LightsOut.SetActiveHouseSavedVars()
    LightsOut.ClearActiveGameDueToLeavingHouse()

    if LightsOut.ui and LightsOut.ui.controlWindow and not LightsOut.ui.controlWindow:IsHidden() then
        LightsOut.RefreshControlWindow()
    end

    if LightsOut.IsInHouse(false) and LightsOut.ui and LightsOut.ui.miniPanelWindow and not LightsOut.ui.miniPanelWindow:IsHidden() then
        LightsOut.RefreshMiniPanel()
    end
end
function LightsOut.DeclareThresholdWinner(winnerKey, entry)
    if LightsOut.game.locked then
        return
    end

    local winnerName = tostring(entry.name or winnerKey)

    LightsOut.game.winner = winnerName
    LightsOut.game.winnerKey = winnerKey
    LightsOut.game.locked = true
    LightsOut.game.active = true
    LightsOut.game.cancelled = false
    LightsOut.game.frozenTimeMs = LightsOut.GetNowMs()
    LightsOut.RefreshMiniPanel()

    local message = zo_strformat("|c00FF00<<1>> wins!|r", winnerName)

    LightsOut.Print(message)
    LightsOut.TryShowWinnerAnnouncement(zo_strformat("Winner - <<1>>", winnerName))
    LightsOut.TryPlayWinnerSound()
    LightsOut.RefreshGameStatusWindow()
    LightsOut.StartWinnerPulse(winnerKey)

    if LightsOut.ui and LightsOut.ui.controlWindow then
        LightsOut.RebuildControlPanel()
    end
end

function LightsOut.CheckThresholdGameState()
    if not LightsOut.game or not LightsOut.game.active or LightsOut.game.mode ~= "threshold" then
        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "ThresholdWatcher")
        return
    end

    if not LightsOut.IsInHouse(false) then
        LightsOut.ClearActiveGameDueToLeavingHouse()
        return
    end

    local nowMs = LightsOut.GetNowMs()
    local currentTimerSecond = math.floor(nowMs / 1000)
    if not LightsOut.game.locked and LightsOut.game.lastTimerRefreshSecond ~= currentTimerSecond then
        LightsOut.game.lastTimerRefreshSecond = currentTimerSecond
        LightsOut.RefreshGameStatusWindow()
        LightsOut.RefreshControlWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
    end

    local pulseLookup = LightsOut.game.pulseFurnitureLookup or {}

    for _, activeEntry in ipairs(LightsOut.GetActiveGameEntries(LightsOut.savedVars.items or {})) do
        local key, entry = activeEntry.key, activeEntry.entry
        if entry and entry.trackedFurnitureIds and entry.lastStates then
            local winningState = tonumber(entry.state)
            local currentWinCount = 0

            for _, furnitureInfo in ipairs(entry.trackedFurnitureIds) do
                local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                if furnitureId then
                    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
                    local previousState = entry.lastStates[furnitureId]

                    if currentState ~= nil then
                        currentState = tonumber(currentState)

                        if LightsOut.game.locked then
                            if not pulseLookup[furnitureId] and previousState ~= nil and tonumber(previousState) ~= currentState then
                                HousingEditorRequestChangeState(furnitureId, previousState)
                                currentState = tonumber(previousState)
                            end
                        else
                            entry.lastStates[furnitureId] = currentState
                        end

                        if currentState == winningState then
                            currentWinCount = currentWinCount + 1
                        end
                    end
                end
            end

            if not LightsOut.game.locked then
                LightsOut.RecordMiniPanelCountUpdate(entry, entry.currentWinCount, currentWinCount)
                entry.currentWinCount = currentWinCount
                LightsOut.RefreshGameStatusWindow()

                if currentWinCount >= tonumber(entry.requiredWinCount or LightsOut.game.threshold or 0) then
                    LightsOut.DeclareThresholdWinner(key, entry)
                    return
                end
            end
        end
    end

    if not LightsOut.game.locked then
        LightsOut.CheckThresholdTimerExpired()
    end
end


LightsOut.STATE_CHANGE_BATCH_SIZE = 4
LightsOut.STATE_CHANGE_DELAY_MS = 150
LightsOut.stateChangeQueue = LightsOut.stateChangeQueue or {
    running = false,
    total = 0,
    completed = 0,
    label = "",
}

function LightsOut.IsStateChangeQueueRunning()
    return LightsOut.stateChangeQueue and LightsOut.stateChangeQueue.running == true
end

function LightsOut.GetStateChangeEstimateText(totalActions)
    local total = tonumber(totalActions or 0) or 0
    if total <= 0 then
        return "now"
    end

    local batchSize = math.max(1, tonumber(LightsOut.STATE_CHANGE_BATCH_SIZE or 4) or 4)
    local delayMs = math.max(1, tonumber(LightsOut.STATE_CHANGE_DELAY_MS or 150) or 150)
    local batches = math.ceil(total / batchSize)
    local estimatedMs = math.max(0, (batches - 1) * delayMs)

    if estimatedMs < 1000 then
        return "under 1 second"
    end

    return "about " .. tostring(math.ceil(estimatedMs / 1000)) .. " second(s)"
end

function LightsOut.QueueHousingStateChange(actions, furnitureId, state)
    if type(actions) ~= "table" then return end

    furnitureId = tonumber(furnitureId)
    state = tonumber(state)

    if not furnitureId or furnitureId ~= furnitureId or not state or state ~= state then
        return
    end

    table.insert(actions, function()
        HousingEditorRequestChangeState(furnitureId, state)
    end)
end

function LightsOut.RunStateChangeQueue(label, actions, onComplete)
    actions = actions or {}

    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return false
    end

    local total = #actions
    local queue = LightsOut.stateChangeQueue or {}
    LightsOut.stateChangeQueue = queue
    queue.running = true
    queue.total = total
    queue.completed = 0
    queue.label = label or "Preparing items"

    local estimateText = LightsOut.GetStateChangeEstimateText(total)

    LightsOut.ShowProgressWindow(
        tostring(queue.label or "Preparing items"),
        total > 0 and zo_strformat("Queued <<1>> furnishing state change(s). Estimated time: <<2>>.", tostring(total), tostring(estimateText)) or "No furnishing state changes are needed.",
        0,
        math.max(total, 1)
    )

    if total > 0 then
        LightsOut.Print(zo_strformat(
            "<<1>>: setting |c00FF00<<2>>|r item(s) in batches of |cFFFF00<<3>>|r every |cFFFF00<<4>>ms|r. Estimated time: |cFFFF00<<5>>|r.",
            tostring(queue.label),
            tostring(total),
            tostring(LightsOut.STATE_CHANGE_BATCH_SIZE or 4),
            tostring(LightsOut.STATE_CHANGE_DELAY_MS or 150),
            tostring(estimateText)
        ))
        LightsOut.TryShowWinnerAnnouncement(zo_strformat("<<1>>: <<2>> item(s), <<3>>", tostring(queue.label), tostring(total), tostring(estimateText)))
    end

    if LightsOut.ui and LightsOut.ui.controlWindow then
        LightsOut.RefreshControlWindow()
    end

    local function finish()
        queue.running = false
        queue.completed = total

        local isReset = string.find(string.lower(tostring(queue.label or "")), "reset", 1, true) ~= nil
        if isReset then
            LightsOut.Print("Items are in the correct state. Reset complete.")
            LightsOut.TryShowWinnerAnnouncement("LightsOut reset complete!")
        else
            LightsOut.Print("Items are in the correct state. Starting now.")
            LightsOut.TryShowWinnerAnnouncement("LightsOut items ready!")
        end

        LightsOut.UpdateProgressWindow(
            tostring(queue.label or "Preparing"),
            zo_strformat("Complete: <<1>>/<<2>> furnishing state change(s).", tostring(queue.completed or 0), tostring(queue.total or 0)),
            queue.completed or 0,
            math.max(queue.total or 0, 1)
        )

        if LightsOut.ui and LightsOut.ui.prepProgressLabel then
            LightsOut.ui.prepProgressLabel:SetText(zo_strformat("<<1>>: <<2>>/<<3>> item state change(s)", tostring(queue.label or "Preparing"), tostring(queue.completed or 0), tostring(queue.total or 0)))
        end

        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.RefreshControlWindow()
        end

        if onComplete then onComplete() end

        LightsOut.HideProgressWindowSoon(900)
    end

    if total <= 0 then
        finish()
        return true
    end

    local index = 1
    local batchSize = math.max(1, tonumber(LightsOut.STATE_CHANGE_BATCH_SIZE or 4) or 4)
    local delayMs = math.max(1, tonumber(LightsOut.STATE_CHANGE_DELAY_MS or 150) or 150)

    local function step()
        if not LightsOut.IsInHouse(false) then
            queue.running = false
            LightsOut.Print("Item state setup cancelled because you are no longer in a house.")
            LightsOut.UpdateProgressWindow(tostring(queue.label or "Preparing"), "Cancelled because you are no longer in a house.", queue.completed or 0, math.max(queue.total or 0, 1))
            LightsOut.HideProgressWindowSoon(1200)
            if LightsOut.ui and LightsOut.ui.controlWindow then
                LightsOut.RefreshControlWindow()
            end
            return
        end

        local processed = 0
        while processed < batchSize and index <= total do
            local action = actions[index]
            index = index + 1
            processed = processed + 1

            if action then
                pcall(action)
            end
        end

        queue.completed = math.min(total, index - 1)

        LightsOut.UpdateProgressWindow(
            tostring(queue.label or "Preparing"),
            zo_strformat("Applying furnishing state changes: <<1>>/<<2>> complete.", tostring(queue.completed or 0), tostring(queue.total or 0)),
            queue.completed or 0,
            math.max(queue.total or 0, 1)
        )

        if LightsOut.ui and LightsOut.ui.prepProgressLabel then
            LightsOut.ui.prepProgressLabel:SetText(zo_strformat("<<1>>: <<2>>/<<3>> item state change(s)", tostring(queue.label or "Preparing"), tostring(queue.completed or 0), tostring(queue.total or 0)))
        end

        if index <= total then
            local remaining = total - queue.completed
            local remainingEstimate = LightsOut.GetStateChangeEstimateText(remaining)
            LightsOut.Dbg(zo_strformat(
                "<<1>> progress: <<2>>/<<3>> item state change(s), remaining <<4>>.",
                tostring(queue.label),
                tostring(queue.completed),
                tostring(total),
                tostring(remainingEstimate)
            ))
            zo_callLater(step, delayMs)
        else
            finish()
        end
    end

    step()
    return true
end


--[[
    Pre-game state snapshot

    Runtime-only table used by Reset Game.  It is created when a game starts,
    before any furnishing state changes are queued/applied, and is cleared after
    Reset Game completes.  Keys use Id64ToString(furnitureId) so very large ESO
    furnitureIds do not collapse into scientific notation strings.
]]
local function LO_FurnitureIdSnapshotKey(furnitureId)
    if furnitureId == nil then return nil end

    if type(Id64ToString) == "function" then
        local ok, result = pcall(Id64ToString, furnitureId)
        if ok and result and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    return tostring(furnitureId)
end

function LightsOut.BeginOriginalStateSnapshot()
    LightsOut.originalStateSnapshot = {}
    LightsOut.originalStateSnapshotOrder = {}

    -- Compatibility aliases for older helper code in this file.
    LightsOut.pendingOriginalStates = LightsOut.originalStateSnapshot
    LightsOut.pendingOriginalStateOrder = LightsOut.originalStateSnapshotOrder

    LightsOut.game = LightsOut.game or {}
    LightsOut.game.originalStates = LightsOut.originalStateSnapshot
    LightsOut.game.originalStateOrder = LightsOut.originalStateSnapshotOrder
end

function LightsOut.ClearOriginalStateSnapshot()
    LightsOut.originalStateSnapshot = nil
    LightsOut.originalStateSnapshotOrder = nil
    LightsOut.pendingOriginalStates = nil
    LightsOut.pendingOriginalStateOrder = nil

    if LightsOut.game then
        LightsOut.game.originalStates = nil
        LightsOut.game.originalStateOrder = nil
    end
end

function LightsOut.GetOriginalStateSnapshotTables()
    local states = LightsOut.originalStateSnapshot
        or LightsOut.pendingOriginalStates
        or (LightsOut.game and LightsOut.game.originalStates)

    local order = LightsOut.originalStateSnapshotOrder
        or LightsOut.pendingOriginalStateOrder
        or (LightsOut.game and LightsOut.game.originalStateOrder)

    return states, order
end

function LightsOut.CaptureOriginalFurnitureState(furnitureId)
    if not furnitureId then return false end

    if type(LightsOut.originalStateSnapshot) ~= "table" then
        LightsOut.BeginOriginalStateSnapshot()
    end

    local key = LO_FurnitureIdSnapshotKey(furnitureId)
    if not key then return false end

    if LightsOut.originalStateSnapshot[key] ~= nil then
        return true
    end

    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
    currentState = tonumber(currentState)

    if currentState == nil or currentState ~= currentState then
        return false
    end

    LightsOut.originalStateSnapshot[key] = currentState
    table.insert(LightsOut.originalStateSnapshotOrder, furnitureId)
    return true
end

function LightsOut.CaptureOriginalFurnitureList(furnitureList)
    local captured = 0
    local attempted = 0

    for _, furnitureInfo in ipairs(furnitureList or {}) do
        local furnitureId = furnitureInfo and furnitureInfo.furnitureId
        if furnitureId then
            attempted = attempted + 1
            if LightsOut.CaptureOriginalFurnitureState(furnitureId) then
                captured = captured + 1
            end
        end
    end

    return captured, attempted
end

function LightsOut.CaptureEnabledNonWarSnapshot(mode)
    LightsOut.BeginOriginalStateSnapshot()

    local captured = 0
    local attempted = 0

    for _, entry in pairs(LightsOut.savedVars and LightsOut.savedVars.items or {}) do
        if LO_IsTeamEnabledForMode(entry, mode) then
            local furnitureList = entry.furnitureIds or entry.trackedFurnitureIds
            local c, a = LightsOut.CaptureOriginalFurnitureList(furnitureList)
            captured = captured + (c or 0)
            attempted = attempted + (a or 0)
        end
    end

    if attempted > 0 and captured < attempted then
        LightsOut.Print(zo_strformat(
            "<<1>> mode cancelled. Captured only <<2>> of <<3>> pre-game item state(s), so reset would not be safe.",
            tostring(mode or "Game"),
            tostring(captured),
            tostring(attempted)
        ))
        LightsOut.ClearOriginalStateSnapshot()
        return false
    end

    return true
end

function LightsOut.CaptureWarSnapshot(matchingFurniture)
    LightsOut.BeginOriginalStateSnapshot()

    local captured, attempted = LightsOut.CaptureOriginalFurnitureList(matchingFurniture)

    if attempted > 0 and captured < attempted then
        LightsOut.Print(zo_strformat(
            "War mode cancelled. Captured only <<1>> of <<2>> pre-game item state(s), so reset would not be safe.",
            tostring(captured),
            tostring(attempted)
        ))
        LightsOut.ClearOriginalStateSnapshot()
        return false
    end

    return true
end

--[[
    LightsOut.StartThresholdMode

    Starts threshold mode.

    Usage:
        /lo start threshold <count> [minutes]

    Rules:
        - Rescans matching items for every team
        - Requires all teams to have the same number of matching items
        - count must be at least 1
        - count cannot exceed the matching item count
        - All matching items are tracked
        - A team wins when count tracked items are in that team's saved winning state
]]
function LightsOut.StartThresholdMode(thresholdCount, timeLimitMinutes, lightsOutDeferredStart)
    if lightsOutDeferredStart ~= true then
        LightsOut_DeferProgressOperation(
            "Initializing threshold game...",
            "Scanning enabled teams and preparing furnishing changes.",
            function() LightsOut.StartThresholdMode(thresholdCount, timeLimitMinutes, true) end
        )
        return
    end
    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return
    end

    if not LightsOut.IsInHouse(true) then return end

    thresholdCount = tonumber(thresholdCount)
    timeLimitMinutes = tonumber(timeLimitMinutes)

    if not thresholdCount or thresholdCount < 1 or thresholdCount ~= math.floor(thresholdCount) then
        LightsOut.Print("Use: /lo start threshold <count> [minutes]")
        LightsOut.Print("Count must be a whole number of at least 1.")
        return
    end

    if timeLimitMinutes ~= nil then
        if timeLimitMinutes < 1 or timeLimitMinutes > 60 or timeLimitMinutes ~= math.floor(timeLimitMinutes) then
            LightsOut.Print("Use: /lo start threshold <count> [minutes]")
            LightsOut.Print("Optional minutes must be a whole number from 1 to 60.")
            return
        end
    end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local teamCount = 0
    local expectedMatchCount = nil
    local countsAreEqual = true
    local stateActions = {}

    -- Stop any prior threshold watcher/pulse before starting a new game.
    LightsOut.StopThresholdGame(true)
    LightsOut.ResetActiveGameEntries()

    for key, entry in pairs(LightsOut.savedVars.items) do
        if LO_IsTeamEnabledForMode(entry, "threshold") then
            teamCount = teamCount + 1

            local furnitureDataId = entry.furnitureDataId

            if furnitureDataId then
                local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)

                entry.furnitureIds = matchingFurniture
                entry.trackedFurnitureIds = matchingFurniture
                entry.matchingCount = matchingCount
                entry.requiredWinCount = thresholdCount
                entry.currentWinCount = 0
                entry.lastStates = {}
                LightsOut.AddActiveGameEntry(key, entry)

                if expectedMatchCount == nil then
                    expectedMatchCount = matchingCount
                elseif matchingCount ~= expectedMatchCount then
                    countsAreEqual = false
                end
            else
                entry.furnitureIds = {}
                entry.trackedFurnitureIds = {}
                entry.matchingCount = 0
                entry.requiredWinCount = thresholdCount
                entry.currentWinCount = 0
                entry.lastStates = {}
                countsAreEqual = false
            end
        end
    end

    if teamCount == 0 then
        LightsOut.Print("No teams have been created.")
        return
    end

    if not countsAreEqual then
        LightsOut.ShowThresholdCountMismatch()
        LightsOut.ClearRuntimeTeamGameData()
        return
    end

    expectedMatchCount = tonumber(expectedMatchCount or 0)

    if thresholdCount > expectedMatchCount then
        LightsOut.Print(zo_strformat(
            "Threshold mode cancelled. Count must be between 1 and <<1>>.",
            tostring(expectedMatchCount)
        ))
        LightsOut.ClearRuntimeTeamGameData()
        return
    end

    if not LightsOut.CaptureEnabledNonWarSnapshot("threshold") then
        LightsOut.ClearRuntimeTeamGameData()
        return
    end

    for key, entry in pairs(LightsOut.savedVars.items) do
        if LO_IsTeamEnabledForMode(entry, "threshold") then
            local winningState = tonumber(entry.state)
            local nonWinningState = LightsOut.GetNonWinningState(winningState)

            for _, furnitureInfo in ipairs(entry.trackedFurnitureIds or {}) do
                local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                if furnitureId then
                    local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)

                    if numStates == 2 then
                        local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)

                        if tonumber(currentState) ~= tonumber(nonWinningState) then
                            LightsOut.QueueHousingStateChange(stateActions, furnitureId, nonWinningState)
                        end

                        entry.lastStates[furnitureId] = nonWinningState
                    end
                end
            end
        end
    end

    LightsOut.RunStateChangeQueue("Preparing threshold game", stateActions, function()
        LightsOut.game.active = true
        LightsOut.game.mode = "threshold"
    LightsOut.game.lastMiniPanelUpdate = "None"
        LightsOut.game.miniPanelUpdateHistory = {}
        LightsOut.game.threshold = thresholdCount
        LightsOut.game.winner = nil
        LightsOut.game.winnerKey = nil
        LightsOut.game.locked = false
        LightsOut.game.cancelled = false
        LightsOut.game.pulseFurnitureLookup = {}
        LightsOut.game.pulseSequence = {}
        LightsOut.game.pulseIndex = 0
        LightsOut.game.pulsePreviousFurnitureId = nil
        LightsOut.game.pulseIntervalMs = 1500
        LightsOut.game.startTimeMs = LightsOut.GetNowMs()
        LightsOut.game.timeLimitMinutes = timeLimitMinutes
        LightsOut.game.endTimeMs = timeLimitMinutes and (LightsOut.game.startTimeMs + (timeLimitMinutes * 60 * 1000)) or nil
        LightsOut.game.frozenTimeMs = nil
        LightsOut.game.overtime = false
        LightsOut.game.lastTimerRefreshSecond = nil

        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "ThresholdWatcher")
        EVENT_MANAGER:RegisterForUpdate(LightsOut.name .. "ThresholdWatcher", 250, LightsOut.CheckThresholdGameState)

        LightsOut.ShowGameStatusWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
        LightsOut.Print(zo_strformat(
            "Started threshold mode. Refreshed |c00FF00<<1>>|r team(s), tracking |c00FF00<<2>>|r item(s) per team. First team with |c00FF00<<3>>|r item(s) in the winning state wins.",
            tostring(teamCount),
            tostring(expectedMatchCount),
            tostring(thresholdCount)
        ))

        if #stateActions > 0 then
            LightsOut.Dbg("Placed " .. tostring(#stateActions) .. " item(s) into their non-winning state.")
        end

        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.RefreshControlWindow()
        end
    end)
end

function LightsOut.SeedRandomOnce()
    if LightsOut.randomSeeded then
        return
    end

    local seed = 0

    if type(GetTimeStamp) == "function" then
        seed = seed + tonumber(GetTimeStamp() or 0)
    end

    if type(GetGameTimeMilliseconds) == "function" then
        seed = seed + tonumber(GetGameTimeMilliseconds() or 0)
    end

    math.randomseed(seed)
    math.random()
    math.random()
    math.random()

    LightsOut.randomSeeded = true
end

function LightsOut.ShuffleFurnitureList(source)
    LightsOut.SeedRandomOnce()

    local shuffled = {}

    for index, value in ipairs(source or {}) do
        shuffled[index] = value
    end

    for index = #shuffled, 2, -1 do
        local swapIndex = math.random(index)
        shuffled[index], shuffled[swapIndex] = shuffled[swapIndex], shuffled[index]
    end

    return shuffled
end

function LightsOut.SplitRandomTargetAndDecoyFurniture(source, targetCount)
    local shuffled = LightsOut.ShuffleFurnitureList(source)
    local targets = {}
    local decoys = {}

    for index, furnitureInfo in ipairs(shuffled) do
        if index <= tonumber(targetCount or 0) then
            table.insert(targets, furnitureInfo)
        else
            table.insert(decoys, furnitureInfo)
        end
    end

    return targets, decoys
end


function LightsOut.IsTargetConfirmCountedEnabled()
    if LightsOut.game and LightsOut.game.mode == "target" then
        return LightsOut.game.confirmCounted == true
    end

    local cp = LightsOut.savedVars and LightsOut.savedVars.controlPanel
    return cp and cp.confirmCounted == true
end

function LightsOut.GetTargetConfirmBlinkState(furnitureId, winningState)
    winningState = tonumber(winningState)

    local numStates = 0
    if furnitureId and type(GetPlacedHousingFurnitureNumObjectStates) == "function" then
        numStates = tonumber(GetPlacedHousingFurnitureNumObjectStates(furnitureId) or 0) or 0
    end

    if numStates <= 1 then
        return nil
    end

    if numStates == 2 then
        return LightsOut.GetNonWinningState(winningState)
    end

    for stateIndex = 0, numStates - 1 do
        if tonumber(stateIndex) ~= winningState then
            return stateIndex
        end
    end

    return nil
end

function LightsOut.BeginTargetConfirmBlink(furnitureId, winningState, entry)
    if not LightsOut.game or LightsOut.game.mode ~= "target" or LightsOut.game.locked then
        return false
    end

    if not LightsOut.IsTargetConfirmCountedEnabled() then
        return false
    end

    if not furnitureId then
        return false
    end

    winningState = tonumber(winningState)
    if winningState == nil then
        return false
    end

    local key = LO_FurnitureIdSnapshotKey(furnitureId) or tostring(furnitureId)
    LightsOut.game.targetConfirmBlinkLookup = LightsOut.game.targetConfirmBlinkLookup or {}
    LightsOut.game.targetConfirmedLookup = LightsOut.game.targetConfirmedLookup or {}

    if LightsOut.game.targetConfirmedLookup[key] or LightsOut.game.targetConfirmBlinkLookup[key] then
        return false
    end

    local blinkState = LightsOut.GetTargetConfirmBlinkState(furnitureId, winningState)
    if blinkState == nil or tonumber(blinkState) == winningState then
        return false
    end

    LightsOut.game.targetConfirmBlinkLookup[key] = {
        furnitureId = furnitureId,
        winningState = winningState,
        blinkState = blinkState,
        startedMs = LightsOut.GetNowMs(),
    }

    if entry then
        entry.lastStates = entry.lastStates or {}
        entry.lastStates[furnitureId] = winningState
    end

    local function applyBlinkState(state, isFinal)
        if not LightsOut.game or LightsOut.game.mode ~= "target" then
            return
        end

        if not LightsOut.IsInHouse(false) then
            return
        end

        HousingEditorRequestChangeState(furnitureId, state)

        if isFinal then
            if LightsOut.game then
                LightsOut.game.targetConfirmBlinkLookup = LightsOut.game.targetConfirmBlinkLookup or {}
                LightsOut.game.targetConfirmedLookup = LightsOut.game.targetConfirmedLookup or {}
                LightsOut.game.targetConfirmBlinkLookup[key] = nil
                LightsOut.game.targetConfirmedLookup[key] = true
            end

            if entry then
                entry.lastStates = entry.lastStates or {}
                entry.lastStates[furnitureId] = winningState
            end

            LightsOut.RefreshGameStatusWindow()
            if type(LightsOut.RefreshMiniPanel) == "function" then
                LightsOut.RefreshMiniPanel()
            end
            if LightsOut.ui and LightsOut.ui.controlWindow then
                LightsOut.RefreshControlWindow()
            end
        end
    end

    zo_callLater(function() applyBlinkState(blinkState, false) end, 500)
    zo_callLater(function() applyBlinkState(winningState, false) end, 1000)
    zo_callLater(function() applyBlinkState(blinkState, false) end, 1500)
    zo_callLater(function() applyBlinkState(winningState, true) end, 2000)

    return true
end

function LightsOut.CheckTargetGameState()
    if not LightsOut.game or not LightsOut.game.active or LightsOut.game.mode ~= "target" then
        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetWatcher")
        return
    end

    if not LightsOut.IsInHouse(false) then
        LightsOut.ClearActiveGameDueToLeavingHouse()
        return
    end

    local nowMs = LightsOut.GetNowMs()
    local currentTimerSecond = math.floor(nowMs / 1000)
    if not LightsOut.game.locked and LightsOut.game.lastTimerRefreshSecond ~= currentTimerSecond then
        LightsOut.game.lastTimerRefreshSecond = currentTimerSecond
        LightsOut.RefreshGameStatusWindow()
        LightsOut.RefreshControlWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
    end

    local pulseLookup = LightsOut.game.pulseFurnitureLookup or {}

    for _, activeEntry in ipairs(LightsOut.GetActiveGameEntries(LightsOut.savedVars.items or {})) do
        local key, entry = activeEntry.key, activeEntry.entry
        if entry and entry.trackedFurnitureIds and entry.lastStates then
            local winningState = tonumber(entry.state)
            local currentWinCount = 0

            for _, furnitureInfo in ipairs(entry.trackedFurnitureIds) do
                local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                if furnitureId then
                    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
                    local previousState = entry.lastStates[furnitureId]

                    if currentState ~= nil then
                        currentState = tonumber(currentState)

                        local confirmKey = LO_FurnitureIdSnapshotKey(furnitureId) or tostring(furnitureId)
                        local confirmBlinkLookup = LightsOut.game.targetConfirmBlinkLookup or {}
                        local confirmedLookup = LightsOut.game.targetConfirmedLookup or {}
                        local isConfirmBlinking = confirmBlinkLookup[confirmKey] ~= nil
                        local isConfirmedTarget = confirmedLookup[confirmKey] == true

                        if isConfirmedTarget and currentState ~= winningState then
                            confirmedLookup[confirmKey] = nil
                            isConfirmedTarget = false
                        end

                        if LightsOut.game.locked then
                            if not pulseLookup[furnitureId] and not isConfirmBlinking and previousState ~= nil and tonumber(previousState) ~= currentState then
                                HousingEditorRequestChangeState(furnitureId, previousState)
                                currentState = tonumber(previousState)
                            end
                        else
                            if isConfirmBlinking then
                                -- The visible state may be temporarily changing as a Target confirmation blink.
                                -- Keep the score/dashboard anchored to the counted winning state instead of
                                -- letting the animation lower the count or create extra mini-panel updates.
                                currentState = winningState
                                entry.lastStates[furnitureId] = winningState
                            elseif isConfirmedTarget and currentState == winningState then
                                entry.lastStates[furnitureId] = winningState
                            else
                                entry.lastStates[furnitureId] = currentState
                                if currentState == winningState and LightsOut.IsTargetConfirmCountedEnabled() then
                                    LightsOut.BeginTargetConfirmBlink(furnitureId, winningState, entry)
                                end
                            end
                        end

                        if currentState == winningState then
                            currentWinCount = currentWinCount + 1
                        end
                    end
                end
            end

            if not LightsOut.game.locked then
                LightsOut.RecordMiniPanelCountUpdate(entry, entry.currentWinCount, currentWinCount)
                entry.currentWinCount = currentWinCount
                LightsOut.RefreshGameStatusWindow()

                if currentWinCount >= tonumber(entry.requiredWinCount or LightsOut.game.threshold or 0) then
                    LightsOut.DeclareThresholdWinner(key, entry)
                    return
                end
            end
        end
    end

    if not LightsOut.game.locked then
        LightsOut.CheckThresholdTimerExpired()
    end
end

--[[
    LightsOut.StartTargetMode

    Starts target mode.

    Usage:
        /lo start target <count> [minutes]

    Rules:
        - Rescans matching items for every team
        - Randomly selects count furnishingIds per team as monitored targets
        - Only monitored targets count toward completion and winning
        - Non-monitored decoys are randomly set to win/non-win states one by one
        - Optional minutes works the same as threshold mode, including overtime ties
]]
function LightsOut.StartTargetMode(targetCount, timeLimitMinutes, lightsOutDeferredStart)
    if lightsOutDeferredStart ~= true then
        LightsOut_DeferProgressOperation(
            "Initializing target game...",
            "Selecting targets and preparing furnishing changes.",
            function() LightsOut.StartTargetMode(targetCount, timeLimitMinutes, true) end
        )
        return
    end
    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return
    end

    if not LightsOut.IsInHouse(true) then return end

    targetCount = tonumber(targetCount)
    timeLimitMinutes = tonumber(timeLimitMinutes)

    if not targetCount or targetCount < 1 or targetCount ~= math.floor(targetCount) then
        LightsOut.Print("Use: /lo start target <count> [minutes]")
        LightsOut.Print("Count must be a whole number of at least 1.")
        return
    end

    if timeLimitMinutes ~= nil then
        if timeLimitMinutes < 1 or timeLimitMinutes > 60 or timeLimitMinutes ~= math.floor(timeLimitMinutes) then
            LightsOut.Print("Use: /lo start target <count> [minutes]")
            LightsOut.Print("Optional minutes must be a whole number from 1 to 60.")
            return
        end
    end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local teamCount = 0
    local decoyQueue = {}
    local totalDecoyCount = 0
    local stateActions = {}

    LightsOut.StopThresholdGame(true)
    LightsOut.ResetActiveGameEntries()

    for key, entry in pairs(LightsOut.savedVars.items) do
        if LO_IsTeamEnabledForMode(entry, "target") then
            teamCount = teamCount + 1

            local furnitureDataId = entry.furnitureDataId
            if furnitureDataId then
                local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)
                entry.furnitureIds = matchingFurniture
                entry.matchingCount = matchingCount

                if targetCount > matchingCount then
                    LightsOut.Print(zo_strformat(
                        "Target mode cancelled. Team |c00FF00<<1>>|r only has |cFFFF00<<2>>|r matching item(s); count must be between 1 and <<2>>.",
                        tostring(entry.name or key),
                        tostring(matchingCount)
                    ))
                    LightsOut.ClearRuntimeTeamGameData()
                    return
                end

                local targets, decoys = LightsOut.SplitRandomTargetAndDecoyFurniture(matchingFurniture, targetCount)
                entry.trackedFurnitureIds = targets
                entry.targetFurnitureIds = targets
                entry.decoyFurnitureIds = decoys
                entry.requiredWinCount = targetCount
                entry.currentWinCount = 0
                entry.lastStates = {}
                LightsOut.AddActiveGameEntry(key, entry)

                local winningState = tonumber(entry.state)
                local nonWinningState = LightsOut.GetNonWinningState(winningState)

                for _, furnitureInfo in ipairs(targets) do
                    local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                    if furnitureId then
                        local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)
                        if numStates == 2 then
                            local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)

                            if tonumber(currentState) ~= tonumber(nonWinningState) then
                                LightsOut.QueueHousingStateChange(stateActions, furnitureId, nonWinningState)
                            end

                            entry.lastStates[furnitureId] = nonWinningState
                        end
                    end
                end

                for _, furnitureInfo in ipairs(decoys) do
                    local furnitureId = furnitureInfo and furnitureInfo.furnitureId
                    if furnitureId then
                        table.insert(decoyQueue, {
                            furnitureId = furnitureId,
                            winningState = winningState,
                            nonWinningState = nonWinningState,
                        })
                        totalDecoyCount = totalDecoyCount + 1
                    end
                end
            else
                LightsOut.Print(zo_strformat(
                    "Target mode cancelled. Team |c00FF00<<1>>|r does not have a furnitureDataId.",
                    tostring(entry.name or key)
                ))
                LightsOut.ClearRuntimeTeamGameData()
                return
            end
        end
    end

    if teamCount == 0 then
        LightsOut.Print("No teams have been created.")
        return
    end

    if not LightsOut.CaptureEnabledNonWarSnapshot("target") then
        LightsOut.ClearRuntimeTeamGameData()
        return
    end

    LightsOut.RunStateChangeQueue("Preparing target game", stateActions, function()
        LightsOut.game.active = true
        LightsOut.game.mode = "target"
    LightsOut.game.lastMiniPanelUpdate = "None"
        LightsOut.game.miniPanelUpdateHistory = {}
        LightsOut.game.threshold = targetCount
        LightsOut.game.winner = nil
        LightsOut.game.winnerKey = nil
        LightsOut.game.locked = false
        LightsOut.game.cancelled = false
        LightsOut.game.pulseFurnitureLookup = {}
        LightsOut.game.pulseSequence = {}
        LightsOut.game.pulseIndex = 0
        LightsOut.game.pulsePreviousFurnitureId = nil
        LightsOut.game.pulseIntervalMs = 1500
        local activeControlPanel = LightsOut.savedVars and LightsOut.savedVars.controlPanel or nil
        LightsOut.game.confirmCounted = activeControlPanel and activeControlPanel.confirmCounted == true
        LightsOut.game.targetConfirmBlinkLookup = {}
        LightsOut.game.targetConfirmedLookup = {}
        LightsOut.game.startTimeMs = LightsOut.GetNowMs()
        LightsOut.game.timeLimitMinutes = timeLimitMinutes
        LightsOut.game.endTimeMs = timeLimitMinutes and (LightsOut.game.startTimeMs + (timeLimitMinutes * 60 * 1000)) or nil
        LightsOut.game.frozenTimeMs = nil
        LightsOut.game.overtime = false
        LightsOut.game.lastTimerRefreshSecond = nil

        decoyQueue = LightsOut.ShuffleFurnitureList(decoyQueue)
        local decoyIndex = 0

        if #decoyQueue > 0 then
            EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer")
            EVENT_MANAGER:RegisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer", 500, function()
                if not LightsOut.game or not LightsOut.game.active or LightsOut.game.mode ~= "target" or LightsOut.game.locked then
                    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer")
                    return
                end

                if not LightsOut.IsInHouse(false) then
                    LightsOut.ClearActiveGameDueToLeavingHouse()
                    return
                end

                decoyIndex = decoyIndex + 1
                local decoy = decoyQueue[decoyIndex]

                if not decoy then
                    EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetDecoyRandomizer")
                    return
                end

                local targetState = math.random(0, 1) == 1 and decoy.winningState or decoy.nonWinningState
                HousingEditorRequestChangeState(decoy.furnitureId, targetState)
            end)
        end

        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "TargetWatcher")
        EVENT_MANAGER:RegisterForUpdate(LightsOut.name .. "TargetWatcher", 250, LightsOut.CheckTargetGameState)

        LightsOut.ShowGameStatusWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
        LightsOut.Print(zo_strformat(
            "Started target mode. Refreshed |c00FF00<<1>>|r team(s), randomly selected |c00FF00<<2>>|r monitored target item(s) per team, and queued |c00FF00<<3>>|r decoy item(s) for random states.",
            tostring(teamCount),
            tostring(targetCount),
            tostring(totalDecoyCount)
        ))

        if #stateActions > 0 then
            LightsOut.Dbg("Placed " .. tostring(#stateActions) .. " monitored target item(s) into their non-winning state.")
        end

        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.RefreshControlWindow()
        end
    end)
end

function LightsOut.GetUnusedWarState(numStates, usedStates)
    numStates = tonumber(numStates or 0) or 0
    usedStates = usedStates or {}

    for state = 0, numStates - 1 do
        if not usedStates[state] then
            return state
        end
    end

    return nil
end

function LightsOut.GetBalancedWarStateAssignments(matchingFurniture, availableStates)
    local assignments = {}
    local shuffledFurniture = LightsOut.ShuffleFurnitureList(matchingFurniture or {})
    local shuffledStates = LightsOut.ShuffleFurnitureList(availableStates or {})

    if #shuffledStates == 0 then
        return assignments
    end

    -- Assign states in a shuffled round-robin pattern. This keeps counts as
    -- equal as possible while still making the starting layout feel random.
    for index, furnitureInfo in ipairs(shuffledFurniture) do
        local stateIndex = ((index - 1) % #shuffledStates) + 1
        table.insert(assignments, {
            furnitureInfo = furnitureInfo,
            state = shuffledStates[stateIndex],
        })
    end

    return assignments
end

function LightsOut.GetRandomWarState(numStates)
    numStates = tonumber(numStates or 0) or 0
    if numStates < 1 then
        return 0
    end

    return math.random(0, numStates - 1)
end

function LightsOut.GetWarStableDelayMs()
    return 5000
end

function LightsOut.UpdateWarAppliedState(entry, furnitureId, currentState, nowMs)
    if not entry or not furnitureId or currentState == nil then
        return nil
    end

    entry.pendingStates = entry.pendingStates or {}
    entry.pendingSinceMs = entry.pendingSinceMs or {}
    entry.appliedStates = entry.appliedStates or {}

    currentState = tonumber(currentState)
    local pendingState = entry.pendingStates[furnitureId]

    -- A new observed state starts/restarts the five-second stability timer.
    if pendingState == nil or tonumber(pendingState) ~= currentState then
        entry.pendingStates[furnitureId] = currentState
        entry.pendingSinceMs[furnitureId] = nowMs
        return entry.appliedStates[furnitureId]
    end

    local sinceMs = tonumber(entry.pendingSinceMs[furnitureId] or nowMs) or nowMs
    if nowMs - sinceMs >= LightsOut.GetWarStableDelayMs() then
        entry.appliedStates[furnitureId] = currentState
    end

    return entry.appliedStates[furnitureId]
end

function LightsOut.CheckWarGameState()
    if not LightsOut.game or not LightsOut.game.active or LightsOut.game.mode ~= "war" then
        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WarWatcher")
        return
    end

    if not LightsOut.IsInHouse(false) then
        LightsOut.ClearActiveGameDueToLeavingHouse()
        return
    end

    local nowMs = LightsOut.GetNowMs()
    local currentTimerSecond = math.floor(nowMs / 1000)
    if not LightsOut.game.locked and LightsOut.game.lastTimerRefreshSecond ~= currentTimerSecond then
        LightsOut.game.lastTimerRefreshSecond = currentTimerSecond
        LightsOut.RefreshGameStatusWindow()
        LightsOut.RefreshControlWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
    end

    local pulseLookup = LightsOut.game.pulseFurnitureLookup or {}

    for _, activeEntry in ipairs(LightsOut.GetActiveGameEntries(LightsOut.GetWarTeamTable())) do
        local key, entry = activeEntry.key, activeEntry.entry
        if entry and entry.trackedFurnitureIds then
            local winningState = tonumber(entry.state)
            local currentWinCount = 0

            entry.lastStates = entry.lastStates or {}
            entry.pendingStates = entry.pendingStates or {}
            entry.pendingSinceMs = entry.pendingSinceMs or {}
            entry.appliedStates = entry.appliedStates or {}

            for _, furnitureInfo in ipairs(entry.trackedFurnitureIds) do
                local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                if furnitureId then
                    local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)

                    if currentState ~= nil then
                        currentState = tonumber(currentState)

                        if LightsOut.game.locked then
                            local previousState = entry.lastStates[furnitureId]
                            if not pulseLookup[furnitureId] and previousState ~= nil and tonumber(previousState) ~= currentState then
                                HousingEditorRequestChangeState(furnitureId, previousState)
                                currentState = tonumber(previousState)
                            end
                        else
                            entry.lastStates[furnitureId] = currentState

                            -- War mode only counts a state after the item has remained
                            -- unchanged in that state for five seconds. If the state changes
                            -- again before the delay expires, the pending timer restarts.
                            LightsOut.UpdateWarAppliedState(entry, furnitureId, currentState, nowMs)
                        end

                        local appliedState = entry.appliedStates[furnitureId]
                        if appliedState ~= nil and tonumber(appliedState) == winningState then
                            currentWinCount = currentWinCount + 1
                        end
                    end
                end
            end

            if not LightsOut.game.locked then
                LightsOut.RecordMiniPanelCountUpdate(entry, entry.currentWinCount, currentWinCount)
                entry.currentWinCount = currentWinCount
                LightsOut.RefreshGameStatusWindow()

                if currentWinCount >= tonumber(entry.requiredWinCount or LightsOut.game.threshold or 0) then
                    LightsOut.DeclareThresholdWinner(key, entry)
                    return
                end
            end
        end
    end

    if not LightsOut.game.locked then
        LightsOut.CheckThresholdTimerExpired()
    end
end

function LightsOut.StartWarMode(timeLimitMinutes, lightsOutDeferredStart)
    if lightsOutDeferredStart ~= true then
        LightsOut_DeferProgressOperation(
            "Initializing War game...",
            "Scanning the shared War item and preparing furnishing changes.",
            function() LightsOut.StartWarMode(timeLimitMinutes, true) end
        )
        return
    end
    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return
    end

    if not LightsOut.IsInHouse(true) then return end

    timeLimitMinutes = tonumber(timeLimitMinutes)

    if timeLimitMinutes ~= nil then
        if timeLimitMinutes < 1 or timeLimitMinutes > 60 or timeLimitMinutes ~= math.floor(timeLimitMinutes) then            LightsOut.Print("Optional minutes must be a whole number from 1 to 60.")
            return
        end
    end

    local warTeams = LightsOut.GetWarTeamTable()
    local teamCount = 0
    local firstFurnitureDataId = nil
    local sameItem = true
    local matchingFurniture = nil
    local matchingCount = 0
    local numStates = nil

    LightsOut.StopThresholdGame(true)
    LightsOut.ResetActiveGameEntries()

    for key, entry in pairs(warTeams) do
        if LO_IsTeamEnabledForMode(entry, "war") then
            teamCount = teamCount + 1

            if firstFurnitureDataId == nil then
                firstFurnitureDataId = entry.furnitureDataId
            elseif tonumber(entry.furnitureDataId) ~= tonumber(firstFurnitureDataId) then
                sameItem = false
            end
        end
    end

    if teamCount == 0 then
        LightsOut.Print("No War teams have been created.")
        return
    end

    if not sameItem then
        LightsOut.Print("War mode cancelled. All War teams must use the same furnishing item.")
        return
    end

    matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(firstFurnitureDataId)

    if matchingCount < 1 then
        LightsOut.Print("War mode cancelled. No matching placed items were found for the War item.")
        return
    end

    local firstFurnitureId = matchingFurniture[1] and matchingFurniture[1].furnitureId
    if firstFurnitureId then
        numStates = GetPlacedHousingFurnitureNumObjectStates(firstFurnitureId)
    end

    if not numStates or numStates < 2 then
        LightsOut.Print("War mode cancelled. The War item must have at least two states.")
        return
    end

    if teamCount > numStates then
        LightsOut.Print(zo_strformat(
            "War mode cancelled. This item has |cFFFF00<<1>>|r state(s), so it can only support |cFFFF00<<1>>|r War team(s).",
            tostring(numStates)
        ))
        return
    end

    local usedStates = {}
    for key, entry in pairs(warTeams) do
        if LO_IsTeamEnabledForMode(entry, "war") then
            local state = tonumber(entry.state)

            if state == nil or state < 0 or state >= numStates then
                LightsOut.Print(zo_strformat(
                    "War mode cancelled. Team |c00FF00<<1>>|r has an invalid win state.",
                    tostring(entry.name or key)
                ))
                LightsOut.ClearRuntimeTeamGameData()
                return
            end

            if usedStates[state] then
                LightsOut.Print("War mode cancelled. Two War teams are using the same win state.")
                LightsOut.ClearRuntimeTeamGameData()
                return
            end

            usedStates[state] = true

            entry.furnitureIds = matchingFurniture
            entry.trackedFurnitureIds = matchingFurniture
            entry.matchingCount = matchingCount
            entry.requiredWinCount = matchingCount
            entry.currentWinCount = 0
            entry.lastStates = {}
            entry.pendingStates = {}
            entry.pendingSinceMs = {}
            entry.appliedStates = {}
            LightsOut.AddActiveGameEntry(key, entry)
        end
    end

    if not LightsOut.CaptureWarSnapshot(matchingFurniture) then
        LightsOut.ClearRuntimeTeamGameData()
        return
    end

    local randomizeStartMs = LightsOut.GetNowMs()
    local neutralState = LightsOut.GetUnusedWarState(numStates, usedStates)
    local startAssignments = {}
    local stateActions = {}

    LightsOut.SeedRandomOnce()

    if neutralState ~= nil then
        -- If there is an unused state, use it as a neutral starting color for
        -- every item. It is also used later as the winner flash-away state.
        for _, furnitureInfo in ipairs(matchingFurniture) do
            table.insert(startAssignments, {
                furnitureInfo = furnitureInfo,
                state = neutralState,
            })
        end
    else
        -- If every state is owned by a War team, assign starting states using
        -- a shuffled round-robin distribution so the colors stay as equal as
        -- possible while still being randomized.
        local availableStates = {}
        for state = 0, numStates - 1 do
            table.insert(availableStates, state)
        end

        startAssignments = LightsOut.GetBalancedWarStateAssignments(matchingFurniture, availableStates)
    end

    for _, assignment in ipairs(startAssignments) do
        local furnitureInfo = assignment.furnitureInfo
        local furnitureId = furnitureInfo and furnitureInfo.furnitureId
        local startState = tonumber(assignment.state)

        if furnitureId and startState ~= nil then
            local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
            if tonumber(currentState) ~= tonumber(startState) then
                LightsOut.QueueHousingStateChange(stateActions, furnitureId, startState)
            end

            for _, entry in pairs(warTeams) do
                if LO_IsTeamEnabledForMode(entry, "war") then
                    entry.lastStates[furnitureId] = startState
                    entry.pendingStates[furnitureId] = startState
                    entry.pendingSinceMs[furnitureId] = randomizeStartMs
                    entry.appliedStates[furnitureId] = nil
                end
            end
        end
    end

    LightsOut.RunStateChangeQueue("Preparing War game", stateActions, function()
        LightsOut.game.active = true
        LightsOut.game.mode = "war"
    LightsOut.game.lastMiniPanelUpdate = "None"
        LightsOut.game.miniPanelUpdateHistory = {}
        LightsOut.game.threshold = matchingCount
        LightsOut.game.winner = nil
        LightsOut.game.winnerKey = nil
        LightsOut.game.locked = false
        LightsOut.game.cancelled = false
        LightsOut.game.pulseFurnitureLookup = {}
        LightsOut.game.pulseSequence = {}
        LightsOut.game.pulseIndex = 0
        LightsOut.game.pulsePreviousFurnitureId = nil
        LightsOut.game.pulseIntervalMs = 1500
        LightsOut.game.warNeutralState = neutralState
        LightsOut.game.startTimeMs = LightsOut.GetNowMs()
        LightsOut.game.timeLimitMinutes = timeLimitMinutes
        LightsOut.game.endTimeMs = timeLimitMinutes and (LightsOut.game.startTimeMs + (timeLimitMinutes * 60 * 1000)) or nil
        LightsOut.game.frozenTimeMs = nil
        LightsOut.game.overtime = false
        LightsOut.game.lastTimerRefreshSecond = nil

        EVENT_MANAGER:UnregisterForUpdate(LightsOut.name .. "WarWatcher")
        EVENT_MANAGER:RegisterForUpdate(LightsOut.name .. "WarWatcher", 250, LightsOut.CheckWarGameState)

        LightsOut.ShowGameStatusWindow()
        if type(LightsOut.RefreshMiniPanel) == "function" then
            LightsOut.RefreshMiniPanel()
        end
        local startModeText = "balanced random starting states"
        if neutralState ~= nil then
            startModeText = "neutral state " .. tostring(neutralState)
        end

        LightsOut.Print(zo_strformat(
            "Started War mode. Tracking |c00FF00<<1>>|r War team(s) across |c00FF00<<2>>|r item(s). Starting with |cFFFF00<<3>>|r. States count only after remaining unchanged for 5 seconds.",
            tostring(teamCount),
            tostring(matchingCount),
            tostring(startModeText)
        ))

        if #stateActions > 0 then
            LightsOut.Dbg("Set " .. tostring(#stateActions) .. " War item(s) to their starting state.")
        end

        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.RefreshControlWindow()
        end
    end)
end

function LightsOut.Start(lightsOutDeferredStart)
    if lightsOutDeferredStart ~= true then
        LightsOut_DeferProgressOperation(
            "Initializing game setup...",
            "Scanning teams and preparing furnishing changes.",
            function() LightsOut.Start(true) end
        )
        return
    end
    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return
    end

    LightsOut.StopThresholdGame(true)

    if not LightsOut.IsInHouse(true) then return end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}

    local teamCount = 0
    local stateActions = {}

    for key, entry in pairs(LightsOut.savedVars.items) do
        teamCount = teamCount + 1

        local furnitureDataId = entry.furnitureDataId
        local winningState = tonumber(entry.state)

        if furnitureDataId and winningState ~= nil then
            -- Refresh matching furniture list for this team
            local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(furnitureDataId)

            entry.furnitureIds = matchingFurniture
            entry.matchingCount = matchingCount

            -- Since this command only supports 2-state objects:
            -- if winning state is 0, non-winning is 1
            -- if winning state is 1, non-winning is 0
            local nonWinningState = winningState == 0 and 1 or 0

            for _, furnitureInfo in ipairs(matchingFurniture) do
                local furnitureId = furnitureInfo.furnitureId

                if furnitureId then
                    local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)

                    if numStates == 2 then
                        local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)

                        if tonumber(currentState) ~= tonumber(nonWinningState) then
                            LightsOut.QueueHousingStateChange(stateActions, furnitureId, nonWinningState)

                            LightsOut.Dbg(zo_strformat(
                                "Team <<1>> furnitureId <<2>> queued for state <<3>>",
                                tostring(entry.name or key),
                                tostring(furnitureId),
                                tostring(nonWinningState)
                            ))
                        end
                    end
                end
            end
        end
    end

    if teamCount == 0 then
        LightsOut.Print("No teams have been created.")
        return
    end

    LightsOut.RunStateChangeQueue("Preparing game setup", stateActions, function()
        LightsOut.Print(zo_strformat(
            "Started game setup. Refreshed |c00FF00<<1>>|r team(s) and placed |c00FF00<<2>>|r item(s) into their non-winning state.",
            tostring(teamCount),
            tostring(#stateActions)
        ))
    end)
end

function LightsOut.ResetGame(lightsOutDeferredReset)
    if lightsOutDeferredReset ~= true then
        LightsOut_DeferProgressOperation(
            "Initializing reset...",
            "Checking tracked furnishings and preparing reset changes.",
            function() LightsOut.ResetGame(true) end
        )
        return
    end
    if LightsOut.IsStateChangeQueueRunning() then
        LightsOut.Print("Please wait for the current item state changes to finish.")
        return
    end

    if not LightsOut.IsInHouse(true) then
        return
    end

    LightsOut.savedVars.items = LightsOut.savedVars.items or {}
    LightsOut.savedVars.warTeams = LightsOut.savedVars.warTeams or {}

    local originalStates, originalStateOrder = LightsOut.GetOriginalStateSnapshotTables()
    if type(originalStates) == "table" and next(originalStates) ~= nil then
        local stateActions = {}
        local checkedCount = 0
        local queuedCount = 0
        local alreadyCorrectCount = 0
        local queuedFurnitureIds = {}

        local function queueSnapshotRestore(furnitureId)
            local key = LO_FurnitureIdSnapshotKey(furnitureId)
            if not key or queuedFurnitureIds[key] then
                return
            end
            queuedFurnitureIds[key] = true

            local desiredState = tonumber(originalStates[key])
            if desiredState == nil or desiredState ~= desiredState then
                return
            end

            checkedCount = checkedCount + 1
            local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)

            if tonumber(currentState) ~= tonumber(desiredState) then
                queuedCount = queuedCount + 1
                LightsOut.QueueHousingStateChange(stateActions, furnitureId, desiredState)
            else
                alreadyCorrectCount = alreadyCorrectCount + 1
            end
        end

        if type(originalStateOrder) == "table" and #originalStateOrder > 0 then
            for _, furnitureId in ipairs(originalStateOrder) do
                queueSnapshotRestore(furnitureId)
            end
        end

        -- Stop all active game update loops after reading the snapshot list.
        LightsOut.StopThresholdGame(true)
        LightsOut.HideGameStatusWindow()

        LightsOut.RunStateChangeQueue("Resetting game", stateActions, function()
            LightsOut.Print(zo_strformat(
                "Reset complete. Restored <<1>> changed item(s); <<2>> captured item(s) were already correct.",
                tostring(queuedCount),
                tostring(alreadyCorrectCount)
            ))

            LightsOut.ClearOriginalStateSnapshot()
            LightsOut.ui.activePage = "setup"

            if LightsOut.returnToMiniPanelAfterReset == true then
                LightsOut.returnToMiniPanelAfterReset = false

                if LightsOut.ui and LightsOut.ui.controlWindow then
                    LightsOut.ui.controlWindow:SetHidden(true)
                end

                if type(LightsOut.RefreshMiniPanel) == "function" then
                    LightsOut.RefreshMiniPanel()
                end

                if LightsOut.ui and LightsOut.ui.miniPanelWindow then
                    LightsOut.ui.miniPanelWindow:SetHidden(false)
                elseif type(LightsOut.ShowMiniPanel) == "function" then
                    LightsOut.ShowMiniPanel()
                end

                return
            end

            LightsOut.RefreshControlPanelForTeamChange()
            if LightsOut.ui and LightsOut.ui.controlWindow then
                LightsOut.ui.controlWindow:SetHidden(false)
            end
        end)
        return
    end

    local activeMode = LightsOut.game and LightsOut.game.mode or nil
    local selectedMode = LO_CP().selectedMode or "threshold"
    local resetMode = activeMode or selectedMode
    local teamCount = 0
    local scannedCount = 0
    local stateActions = {}
    local queuedFurnitureIds = {}

    local function queueIfNeeded(furnitureId, desiredState)
        furnitureId = tonumber(furnitureId)
        desiredState = tonumber(desiredState)

        if not furnitureId or furnitureId ~= furnitureId or desiredState == nil or desiredState ~= desiredState then
            return
        end

        local furnitureKey = tostring(furnitureId)
        if queuedFurnitureIds[furnitureKey] then
            return
        end

        local currentState = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId)
        scannedCount = scannedCount + 1

        if tonumber(currentState) ~= tonumber(desiredState) then
            queuedFurnitureIds[furnitureKey] = true
            LightsOut.QueueHousingStateChange(stateActions, furnitureId, desiredState)
        end
    end

    local function getRuntimeFurnitureList(entry)
        if entry.trackedFurnitureIds ~= nil then
            return entry.trackedFurnitureIds
        end

        if resetMode == "target" and entry.targetFurnitureIds ~= nil then
            return entry.targetFurnitureIds
        end

        return nil
    end

    if resetMode == "war" then
        local resetState = 0

        if LightsOut.game and LightsOut.game.warNeutralState ~= nil then
            resetState = tonumber(LightsOut.game.warNeutralState) or 0
        end

        for key, entry in pairs(LightsOut.savedVars.warTeams or {}) do
            if LO_IsTeamEnabledForMode(entry, "war") then
                teamCount = teamCount + 1

                local furnitureList = getRuntimeFurnitureList(entry)

                if not furnitureList and entry.furnitureDataId then
                    local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(entry.furnitureDataId)
                    furnitureList = matchingFurniture
                    entry.furnitureIds = matchingFurniture
                    entry.matchingCount = matchingCount
                end

                for _, furnitureInfo in ipairs(furnitureList or {}) do
                    local furnitureId = furnitureInfo and furnitureInfo.furnitureId
                    if furnitureId then
                        queueIfNeeded(furnitureId, resetState)
                    end
                end
            end
        end
    else
        for key, entry in pairs(LightsOut.savedVars.items or {}) do
            if LO_IsTeamEnabledForMode(entry, resetMode) then
                teamCount = teamCount + 1

                local winningState = tonumber(entry.state)
                local nonWinningState = LightsOut.GetNonWinningState(winningState)
                local furnitureList = getRuntimeFurnitureList(entry)

                -- If a game is active, only reset the runtime-tracked items for that mode.
                -- If no game is active, fall back to the enabled teams for the selected non-war mode.
                if not furnitureList and not activeMode and entry.furnitureDataId then
                    local matchingFurniture, matchingCount = LightsOut.GetMatchingHouseFurniture(entry.furnitureDataId)
                    furnitureList = matchingFurniture
                    entry.furnitureIds = matchingFurniture
                    entry.matchingCount = matchingCount
                end

                for _, furnitureInfo in ipairs(furnitureList or {}) do
                    local furnitureId = furnitureInfo and furnitureInfo.furnitureId

                    if furnitureId then
                        local numStates = GetPlacedHousingFurnitureNumObjectStates(furnitureId)

                        if tonumber(numStates) == 2 then
                            queueIfNeeded(furnitureId, nonWinningState)
                        end
                    end
                end
            end
        end
    end

    -- Stop all active game update loops after capturing the runtime furniture lists.
    -- This unregisters threshold, target, decoy randomizer, and winner pulse updates.
    LightsOut.StopThresholdGame(true)
    LightsOut.HideGameStatusWindow()

    if teamCount == 0 then
        LightsOut.Print("No enabled team(s) found for the current game mode.")
        return
    end

    LightsOut.RunStateChangeQueue("Resetting game", stateActions, function()
        LightsOut.Print(zo_strformat(
            "Reset complete. Stopped the active game and set |c00FF00<<1>>|r of |c00FF00<<2>>|r enabled |cFFFF00<<3>>|r item(s) to their reset state.",
            tostring(#stateActions),
            tostring(scannedCount),
            tostring(resetMode or "non-war")
        ))

        LightsOut.ui.activePage = "setup"

        if LightsOut.returnToMiniPanelAfterReset == true then
            LightsOut.returnToMiniPanelAfterReset = false

            if LightsOut.ui and LightsOut.ui.controlWindow then
                LightsOut.ui.controlWindow:SetHidden(true)
            end

            if type(LightsOut.RefreshMiniPanel) == "function" then
                LightsOut.RefreshMiniPanel()
            end

            if LightsOut.ui and LightsOut.ui.miniPanelWindow then
                LightsOut.ui.miniPanelWindow:SetHidden(false)
            elseif type(LightsOut.ShowMiniPanel) == "function" then
                LightsOut.ShowMiniPanel()
            end

            return
        end

        LightsOut.RefreshControlPanelForTeamChange()
        if LightsOut.ui and LightsOut.ui.controlWindow then
            LightsOut.ui.controlWindow:SetHidden(false)
        end
    end)
end

function LightsOut.HandleSlashCommand(args)
    local cmd, rest = string.match(args or "", "^%s*(%S*)%s*(.-)%s*$")
    cmd = string.lower(cmd or "")

    if cmd == "" then
        if type(LightsOut.OpenPreferredPanelWithStartupProgress) == "function" then
            LightsOut.OpenPreferredPanelWithStartupProgress()
        else
            LightsOut.OpenPreferredPanel()
        end
        return
    end

    LightsOut.SetActiveHouseSavedVars()

    if cmd == "help" then
        LightsOut.ShowHelp()
        return
    end

    if cmd == "teams" or cmd == "teaminfo" then
        LightsOut.ShowTeamInfo()
        return
    end

    if cmd == "add" then
        local addMode, addName = string.match(rest or "", "^(%S*)%s*(.-)%s*$")
        addMode = string.lower(addMode or "")

        if addMode == "war" then
            LightsOut.AddSelectedWarTeam(addName)
        else
            LightsOut.AddSelectedFurniture(rest)
        end

        return
    end
    if cmd == "populatehouse" or (cmd == "populate" and string.lower(tostring(rest or "")):match("^%s*house%s*$")) then
        LightsOut.PopulateHouseTeams()
        return
    end
    if cmd == "war" then
        local subCmd, subRest = string.match(rest or "", "^(%S*)%s*(.-)%s*$")
        subCmd = string.lower(subCmd or "")        return
    end


    if cmd == "start" then
        local mode, countText = string.match(rest or "", "^(%S*)%s*(.-)$")
        mode = string.lower(mode or "")
        if mode == "threshold" or mode == "target" then
            local countValue, minutesText, extraText = string.match(countText or "", "^(%S*)%s*(%S*)%s*(.-)%s*$")

            if extraText and extraText ~= "" then
                LightsOut.Print("Use: /lo start " .. tostring(mode) .. " <count> [minutes]")
                return
            end

            if minutesText == "" then
                minutesText = nil
            end

            if mode == "threshold" then
                LightsOut.StartThresholdMode(countValue, minutesText)
            else
                LightsOut.StartTargetMode(countValue, minutesText)
            end

            return
        end

        if mode ~= "" then
            LightsOut.Print("Unknown start mode: " .. tostring(mode))
        end

        LightsOut.Print("Use: /lo start threshold <count> [minutes]")
        LightsOut.Print("Use: /lo start target <count> [minutes]")        return
    end


    LightsOut.Print("Unknown command: " .. tostring(cmd))
    LightsOut.ShowHelp()
end

function LightsOut.OnAddonLoaded(eventCode, addonName)
    if addonName ~= LightsOut.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(LightsOut.name, EVENT_ADD_ON_LOADED)

    LightsOut.savedVars = ZO_SavedVars:NewAccountWide(
        "LightsOutSavedVariables",
        1,
        GetWorldName(),
        DEFAULT_SAVED_VARIABLES
    )

    LightsOut.savedVars.houses = LightsOut.savedVars.houses or {}
    LightsOut.SetActiveHouseSavedVars()

    SLASH_COMMANDS["/lightsout"] = LightsOut.HandleSlashCommand
    SLASH_COMMANDS["/lo"] = LightsOut.HandleSlashCommand

    EVENT_MANAGER:RegisterForEvent(LightsOut.name, EVENT_PLAYER_ACTIVATED, LightsOut.OnPlayerActivated)
    LightsOut.RegisterHousingFurnitureChangeEvents()

    LightsOut.Dbg("Initialized.")
end

EVENT_MANAGER:RegisterForEvent(LightsOut.name, EVENT_ADD_ON_LOADED, LightsOut.OnAddonLoaded)


-- Mini Panel Icon Return Button Behavior Update
-- Replaced the mini panel close (X) button with a small icon-style return button.
-- Clicking it hides the mini panel and returns to the main control panel.
-- Toggling the mini panel while it is already open also returns to the main control panel.


-- Mini panel now shows mode, required target count, and active team count.
