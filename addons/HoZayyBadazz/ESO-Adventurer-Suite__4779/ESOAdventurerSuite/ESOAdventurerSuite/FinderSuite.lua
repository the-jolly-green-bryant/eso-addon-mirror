-- ESO Adventurer Suite
-- Suite-native Finder extensions (Zone Guide, Tales of Tribute, Home Tours)
-- v0.29.36

local EPC = ESOProgressionCoach
EPC.FinderSuite = EPC.FinderSuite or {}
local F = EPC.FinderSuite

F.PAGE_SIZE = 10
F.state = F.state or {}

local function clean(value)
    value = tostring(value or "")
    value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

local function lower(value)
    return string.lower(clean(value))
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

local function safeMethod(obj, methodName, default, ...)
    if not obj then return default end
    local fn = obj[methodName]
    if type(fn) ~= "function" then return default end
    local ok, a, b, c, d, e, f = pcall(fn, obj, ...)
    if not ok then return default end
    if a == nil then return default end
    return a, b, c, d, e, f
end

local function notify(text)
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(text)
    elseif type(d) == "function" then
        d("[EAS] " .. tostring(text))
    end
end

local function stateFor(tab, defaultFilter)
    local s = F.state[tab]
    if not s then
        s = { page = 1, filter = defaultFilter or "ALL", selectedKey = nil }
        F.state[tab] = s
    end
    if not s.filter then s.filter = defaultFilter or "ALL" end
    if not s.page then s.page = 1 end
    return s
end

local function makeKey(prefix, ...)
    local parts = {prefix}
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...) or "")
    end
    return table.concat(parts, ":")
end

local function paginate(tab, allRows, title, description, defaultFilter)
    local s = stateFor(tab, defaultFilter)
    local total = #allRows
    local pages = math.max(1, math.ceil(total / F.PAGE_SIZE))
    s.page = math.max(1, math.min(tonumber(s.page) or 1, pages))

    local selected
    if s.selectedKey then
        for _, row in ipairs(allRows) do
            if row.key == s.selectedKey then selected = row break end
        end
    end
    if not selected and allRows[1] then
        selected = allRows[1]
        s.selectedKey = selected.key
    end

    local first = ((s.page - 1) * F.PAGE_SIZE) + 1
    local rows = {}
    for i = first, math.min(total, first + F.PAGE_SIZE - 1) do
        rows[#rows + 1] = allRows[i]
    end

    return {
        title = title,
        description = description,
        hint = description,
        rows = rows,
        allRows = allRows,
        selected = selected,
        total = total,
        page = s.page,
        pageCount = pages,
        filter = s.filter,
    }
end

function F:Handles(tab)
    return tab == "ZONEGUIDE" or tab == "TRIBUTE" or tab == "HOMETOURS"
end

function F:SetFilter(tab, filter)
    local s = stateFor(tab, "ALL")
    s.filter = tostring(filter or "ALL")
    s.page = 1
    s.selectedKey = nil
end

function F:ChangePage(tab, delta)
    local s = stateFor(tab, "ALL")
    s.page = math.max(1, (tonumber(s.page) or 1) + (tonumber(delta) or 0))
    s.selectedKey = nil
end

function F:SelectVisibleRow(tab, visibleIndex)
    local view = self:BuildView(tab)
    local row = view and view.rows and view.rows[tonumber(visibleIndex) or 1]
    if row then
        local s = stateFor(tab, "ALL")
        s.selectedKey = row.key
        return row
    end
    return nil
end

function F:GetSelected(tab)
    local view = self:BuildView(tab)
    return view and view.selected or nil
end

-- --------------------------------------------------------------------------
-- Zone Guide
-- --------------------------------------------------------------------------

local function currentZoneInfo()
    local zoneIndex = 0
    local zoneId = 0
    local zoneName = "Current Zone"

    if type(GetUnitZoneIndex) == "function" then
        local ok, value = pcall(GetUnitZoneIndex, "player")
        if ok then zoneIndex = tonumber(value) or 0 end
    end
    if type(ZO_ExplorationUtils_GetZoneStoryZoneIdByZoneIndex) == "function" and zoneIndex > 0 then
        local ok, value = pcall(ZO_ExplorationUtils_GetZoneStoryZoneIdByZoneIndex, zoneIndex)
        if ok then zoneId = tonumber(value) or 0 end
    end
    if zoneId <= 0 and type(ZO_ExplorationUtils_GetPlayerCurrentZoneId) == "function" then
        local ok, value = pcall(ZO_ExplorationUtils_GetPlayerCurrentZoneId)
        if ok then zoneId = tonumber(value) or 0 end
    elseif zoneId <= 0 and zoneIndex > 0 and type(GetZoneId) == "function" then
        local ok, value = pcall(GetZoneId, zoneIndex)
        if ok then zoneId = tonumber(value) or 0 end
    end
    if zoneId > 0 and type(GetZoneNameById) == "function" then
        local ok, value = pcall(GetZoneNameById, zoneId)
        if ok and clean(value) ~= "" then zoneName = clean(value) end
    elseif zoneIndex > 0 and type(GetZoneNameByIndex) == "function" then
        local ok, value = pcall(GetZoneNameByIndex, zoneIndex)
        if ok and clean(value) ~= "" then zoneName = clean(value) end
    end

    return zoneIndex, zoneId, zoneName
end

local function zoneStoryList()
    local zones = {}
    if type(GetNextZoneStoryZoneId) ~= "function" then return zones end

    local previousId = nil
    for _ = 1, 500 do
        local ok, zoneId = pcall(GetNextZoneStoryZoneId, previousId)
        zoneId = ok and tonumber(zoneId) or nil
        if not zoneId or zoneId <= 0 or zoneId == previousId then break end

        local name = "Zone " .. tostring(zoneId)
        local description = ""
        if type(GetZoneNameById) == "function" then
            local okName, value = pcall(GetZoneNameById, zoneId)
            if okName and clean(value) ~= "" then name = clean(value) end
        end
        if type(GetZoneDescriptionById) == "function" then
            local okDescription, value = pcall(GetZoneDescriptionById, zoneId)
            if okDescription then description = clean(value) end
        end

        zones[#zones + 1] = { id = zoneId, name = name, description = description }
        previousId = zoneId
    end

    table.sort(zones, function(a, b) return lower(a.name) < lower(b.name) end)
    return zones
end

local function zoneDataForId(zoneId)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 then return nil end

    local name = "Zone " .. tostring(zoneId)
    local description = ""
    if type(GetZoneNameById) == "function" then
        local ok, value = pcall(GetZoneNameById, zoneId)
        if ok and clean(value) ~= "" then name = clean(value) end
    end
    if type(GetZoneDescriptionById) == "function" then
        local ok, value = pcall(GetZoneDescriptionById, zoneId)
        if ok then description = clean(value) end
    end
    return { id = zoneId, name = name, description = description }
end

local function zoneCompletionTypes()
    local names = {
        "ZONE_COMPLETION_TYPE_PRIORITY_QUESTS",
        "ZONE_COMPLETION_TYPE_WAYSHRINES",
        "ZONE_COMPLETION_TYPE_DELVES",
        "ZONE_COMPLETION_TYPE_GROUP_DELVES",
        "ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST",
        "ZONE_COMPLETION_TYPE_STRIKING_LOCALES",
        "ZONE_COMPLETION_TYPE_SET_STATIONS",
        "ZONE_COMPLETION_TYPE_MUNDUS_STONES",
        "ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS",
        "ZONE_COMPLETION_TYPE_WORLD_EVENTS",
        "ZONE_COMPLETION_TYPE_GROUP_BOSSES",
        "ZONE_COMPLETION_TYPE_SKYSHARDS",
        "ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS",
    }
    local values = {}
    local seen = {}
    for _, name in ipairs(names) do
        local value = rawget(_G, name)
        if type(value) == "number" and not seen[value] then
            seen[value] = true
            values[#values + 1] = value
        end
    end
    return values
end

local function zoneCompletionLabel(completionType)
    if type(GetString) == "function" then
        local ok, value = pcall(GetString, "SI_ZONECOMPLETIONTYPE", completionType)
        if ok and clean(value) ~= "" then return clean(value) end
    end
    return "Map Activity"
end

local function zoneCompletionDescription(completionType)
    if type(GetString) == "function" then
        local ok, value = pcall(GetString, "SI_ZONECOMPLETIONTYPE_DESCRIPTION", completionType)
        if ok and clean(value) ~= "" then return clean(value) end
    end
    return zoneCompletionLabel(completionType) .. " completion for this zone."
end

local function getCompletionProgress(zoneId, completionType)
    if type(GetNumCompletedZoneActivitiesForZoneCompletionType) ~= "function" or type(GetNumZoneActivitiesForZoneCompletionType) ~= "function" then
        return 0, 0
    end
    local okCompleted, completed = pcall(GetNumCompletedZoneActivitiesForZoneCompletionType, zoneId, completionType)
    local okTotal, total = pcall(GetNumZoneActivitiesForZoneCompletionType, zoneId, completionType)
    completed = okCompleted and (tonumber(completed) or 0) or 0
    total = okTotal and (tonumber(total) or 0) or 0
    return completed, total
end

local function getCompletionIcon(completionType)
    local managerClass = rawget(_G, "ZO_ZoneStories_Manager")
    if type(managerClass) == "table" and type(managerClass.GetCompletionTypeIcon) == "function" then
        local ok, value = pcall(managerClass.GetCompletionTypeIcon, completionType)
        if ok then return value end
    end
    return nil
end

local function zoneStoryIsComplete(zoneId)
    if type(IsZoneStoryComplete) == "function" then
        local ok, value = pcall(IsZoneStoryComplete, zoneId)
        if ok then return value == true end
    end
    return false
end

local function getFeaturedAchievementRows(zoneId, zoneName)
    local rows = {}
    local featuredType = rawget(_G, "ZONE_COMPLETION_TYPE_FEATURED_ACHIEVEMENTS")
    if type(featuredType) ~= "number" or type(GetNumUnblockedZoneStoryActivitiesForZoneCompletionType) ~= "function" or type(GetZoneActivityIdForZoneCompletionType) ~= "function" then
        return rows
    end

    local okCount, count = pcall(GetNumUnblockedZoneStoryActivitiesForZoneCompletionType, zoneId, featuredType)
    count = okCount and (tonumber(count) or 0) or 0
    for activityIndex = 1, math.min(count, 8) do
        local okId, achievementId = pcall(GetZoneActivityIdForZoneCompletionType, zoneId, featuredType, activityIndex)
        achievementId = okId and (tonumber(achievementId) or 0) or 0
        if achievementId > 0 and type(GetAchievementInfo) == "function" then
            local okInfo, name, description, points, icon, completed, date, time = pcall(GetAchievementInfo, achievementId)
            if okInfo then
                name = clean(name)
                description = clean(description)
                points = tonumber(points) or 0
                completed = completed == true
                if name ~= "" then
                    local status = completed and "Completed" or "In Progress"
                    if points > 0 then status = status .. " • " .. tostring(points) .. " pts" end
                    if completed and clean(date) ~= "" then status = status .. " • " .. clean(date) end
                    rows[#rows + 1] = {
                        key = makeKey("zone-featured", zoneId, achievementId),
                        kind = "FEATURED_ACHIEVEMENT",
                        name = name,
                        title = name,
                        detail = status,
                        description = description ~= "" and description or ("Featured " .. zoneName .. " achievement."),
                        zoneName = zoneName,
                        zoneId = zoneId,
                        achievementId = achievementId,
                        points = points,
                        completed = completed,
                        icon = icon,
                        date = date,
                        time = time,
                    }
                end
            end
        end
    end
    return rows
end

local function normalizeSelectedZone(s, zones, currentZoneId)
    local selectedId = tonumber(s.selectedZoneId) or 0
    local found = false
    for _, zone in ipairs(zones) do
        if zone.id == selectedId then found = true break end
    end
    if not found then
        selectedId = tonumber(currentZoneId) or 0
        found = false
        for _, zone in ipairs(zones) do
            if zone.id == selectedId then found = true break end
        end
    end
    if not found and zones[1] then selectedId = zones[1].id end
    s.selectedZoneId = selectedId
    return selectedId
end

function F:SelectCurrentZoneGuideZone()
    local s = stateFor("ZONEGUIDE", "ALL")
    local _, currentZoneId = currentZoneInfo()
    if currentZoneId > 0 then
        s.selectedZoneId = currentZoneId
        s.page = 1
        s.selectedKey = nil
    end
end

function F:ChangeZoneGuideZone(delta)
    local s = stateFor("ZONEGUIDE", "ALL")
    local zones = zoneStoryList()
    if #zones == 0 then return end
    local _, currentZoneId = currentZoneInfo()
    local selectedId = normalizeSelectedZone(s, zones, currentZoneId)
    local index = 1
    for i, zone in ipairs(zones) do
        if zone.id == selectedId then index = i break end
    end
    index = index + (tonumber(delta) or 0)
    if index < 1 then index = #zones elseif index > #zones then index = 1 end
    s.selectedZoneId = zones[index].id
    s.page = 1
    s.selectedKey = nil
end

function F:BuildZoneGuideView()
    local s = stateFor("ZONEGUIDE", "ALL")
    local _, currentZoneId, currentZoneName = currentZoneInfo()
    local zones = zoneStoryList()
    local selectedZoneId = normalizeSelectedZone(s, zones, currentZoneId)
    local zoneData = zoneDataForId(selectedZoneId) or { id = currentZoneId, name = currentZoneName, description = "" }
    local zoneName = zoneData.name or currentZoneName
    local rows = {}
    local completionRows = {}
    local completionSummary = {}
    local completedTotal, activityTotal = 0, 0

    for _, completionType in ipairs(zoneCompletionTypes()) do
        local completed, total = getCompletionProgress(zoneData.id, completionType)
        if total > 0 then
            completedTotal = completedTotal + completed
            activityTotal = activityTotal + total
            local labelText = zoneCompletionLabel(completionType)
            completionSummary[#completionSummary + 1] = string.format("%s: %d/%d", labelText, completed, total)
            completionRows[#completionRows + 1] = {
                key = makeKey("zone-completion", zoneData.id, completionType),
                kind = "COMPLETION",
                name = labelText,
                title = labelText,
                detail = string.format("%d / %d complete", completed, total),
                description = zoneCompletionDescription(completionType),
                detailText = string.format("MAP COMPLETION\n%s: %d/%d", labelText, completed, total),
                zoneName = zoneName,
                zoneId = zoneData.id,
                completionType = completionType,
                completed = completed,
                totalActivities = total,
                icon = getCompletionIcon(completionType),
            }
        end
    end

    local overallPercent = activityTotal > 0 and math.floor((completedTotal / activityTotal) * 100 + 0.5) or 0
    rows[#rows + 1] = {
        key = makeKey("zone-summary", zoneData.id),
        kind = "SUMMARY",
        name = zoneName,
        title = zoneName,
        detail = zoneStoryIsComplete(zoneData.id) and "Zone Story Complete" or ("Zone Story • " .. tostring(overallPercent) .. "% map completion"),
        description = zoneData.description ~= "" and zoneData.description or ("Zone Guide information for " .. zoneName .. "."),
        detailText = (#completionSummary > 0) and ("MAP COMPLETION\n" .. table.concat(completionSummary, "\n")) or "Map completion data is not available for this zone.",
        zoneName = zoneName,
        zoneId = zoneData.id,
        completed = zoneStoryIsComplete(zoneData.id),
        completionType = rawget(_G, "ZONE_COMPLETION_TYPE_PRIORITY_QUESTS"),
        background = type(GetZoneStoryKeyboardBackground) == "function" and select(2, pcall(GetZoneStoryKeyboardBackground, zoneData.id)) or nil,
    }

    local featuredRows = getFeaturedAchievementRows(zoneData.id, zoneName)
    for _, row in ipairs(featuredRows) do rows[#rows + 1] = row end
    for _, row in ipairs(completionRows) do rows[#rows + 1] = row end

    local view = paginate(
        "ZONEGUIDE",
        rows,
        "Zone Guide",
        "Browse the selected zone's story, featured achievements, and map completion entirely inside ESO Adventurer Suite.",
        "ALL"
    )
    view.zoneName = zoneName
    view.zoneId = zoneData.id
    view.zoneDescription = zoneData.description
    view.currentZoneId = currentZoneId
    view.currentZoneName = currentZoneName
    view.isCurrentZone = zoneData.id == currentZoneId
    view.zoneCount = #zones
    view.completionSummary = completionSummary
    view.overallCompleted = completedTotal
    view.overallTotal = activityTotal
    return view
end

function F:TrackSelectedZoneGuide()
    local selected = self:GetSelected("ZONEGUIDE")
    if not selected then notify("Zone Guide: select an entry first."); return false end
    local zoneId = tonumber(selected.zoneId) or 0
    if zoneId <= 0 or type(TrackNextActivityForZoneStory) ~= "function" then
        notify("Zone Guide tracking API is unavailable on this client.")
        return false
    end

    local completionType = tonumber(selected.completionType)
    local featuredType = rawget(_G, "ZONE_COMPLETION_TYPE_FEATURED_ACHIEVEMENTS")
    if completionType == featuredType then completionType = nil end
    local ok = pcall(TrackNextActivityForZoneStory, zoneId, completionType, true)
    if ok then
        notify("Zone Guide tracking updated for " .. tostring(selected.zoneName or selected.name or "selected zone") .. ".")
        return true
    end
    notify("ESO rejected the Zone Guide tracking request.")
    return false
end

function F:StopZoneGuideTracking()
    if type(ClearTrackedZoneStory) ~= "function" then
        notify("Zone Guide stop-tracking API is unavailable on this client.")
        return false
    end
    local ok = pcall(ClearTrackedZoneStory)
    if ok then notify("Zone Guide tracking cleared.") end
    return ok
end

-- --------------------------------------------------------------------------
-- Tales of Tribute finder
-- --------------------------------------------------------------------------

local function getActivityRoot()
    return rawget(_G, "ZO_ACTIVITY_FINDER_ROOT_MANAGER")
end

local function tributeActivityTypes()
    -- ESO's own Tribute Finder manager is initialized with exactly these two
    -- activity types: competitive and casual. Keep a mode map instead of
    -- guessing from unrelated Activity Finder row names/descriptions.
    local types = {}
    local competitive = rawget(_G, "LFG_ACTIVITY_TRIBUTE_COMPETITIVE")
    local casual = rawget(_G, "LFG_ACTIVITY_TRIBUTE_CASUAL")
    if type(competitive) == "number" then types[competitive] = "COMPETITIVE" end
    if type(casual) == "number" then types[casual] = "CASUAL" end

    -- Compatibility fallback: ask ESO's Tribute Finder manager which activity
    -- types it owns. This touches only the known manager object; it never scans _G.
    local manager = rawget(_G, "TRIBUTE_FINDER_MANAGER")
    local filterModeData = manager and safeMethod(manager, "GetFilterModeData", nil) or nil
    local activityTypes = filterModeData and safeMethod(filterModeData, "GetActivityTypes", nil) or nil
    if type(activityTypes) == "table" then
        for index, value in ipairs(activityTypes) do
            value = tonumber(value)
            if value and not types[value] then
                -- ESO currently exposes the manager in competitive, casual order.
                types[value] = index == 1 and "COMPETITIVE" or "CASUAL"
            end
        end
    end
    return types
end

local function activityLocationRow(activityType, location, tributeMode)
    if not location or not tributeMode then return nil end
    if safeMethod(location, "IsSetEntryType", true) == false then return nil end
    if safeMethod(location, "IsActive", true) == false then return nil end

    local id = tonumber(safeMethod(location, "GetId", 0)) or 0
    local rawName = clean(safeMethod(location, "GetRawName", ""))
    if rawName == "" then rawName = clean(safeMethod(location, "GetNameKeyboard", "")) end
    local rawDescription = clean(safeMethod(location, "GetDescription", ""))
    local locked = safeMethod(location, "IsLocked", false) == true
    local lockReason = clean(safeMethod(location, "GetLockReasonText", ""))
    local dailyReady = safeMethod(location, "IsEligibleForDailyReward", false) == true
    local competitive = tributeMode == "COMPETITIVE"
    local displayName = competitive and "Competitive Tales of Tribute" or "Casual Tales of Tribute"
    local description = rawDescription
    if description == "" then
        description = competitive
            and "Queue for ranked Tales of Tribute matchmaking."
            or "Queue for casual Tales of Tribute matchmaking."
    end

    return {
        key = makeKey("tribute", activityType, id, tributeMode),
        id = id,
        activityType = activityType,
        tributeMode = tributeMode,
        competitive = competitive,
        location = location,
        name = displayName,
        title = displayName,
        rawName = rawName,
        detail = locked and "Locked" or (dailyReady and "Available • Daily reward" or "Available"),
        description = description,
        locked = locked,
        lockReason = lockReason,
        dailyReady = dailyReady,
    }
end

function F:BuildTributeView()
    local s = stateFor("TRIBUTE", "ALL")
    local rows = {}
    local root = getActivityRoot()
    local tributeTypes = tributeActivityTypes()

    if root and type(root.GetLocationsData) == "function" then
        if type(root.UpdateLocationData) == "function" then pcall(root.UpdateLocationData, root) end
        local seenModes = {}
        -- Ask ESO only for the two Tribute activity buckets. Do not walk the
        -- dungeon/PvP/etc. buckets at all, so their names and lock reasons can
        -- never leak into the Tales of Tribute page.
        for activityType, tributeMode in pairs(tributeTypes) do
            local ok, locations = pcall(root.GetLocationsData, root, activityType)
            if ok and type(locations) == "table" then
                for _, location in ipairs(locations) do
                    local row = activityLocationRow(activityType, location, tributeMode)
                    if row then
                        local include = s.filter == "ALL" or s.filter == tributeMode
                        if include and not seenModes[tributeMode] then
                            seenModes[tributeMode] = true
                            rows[#rows + 1] = row
                        end
                    end
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        if a.competitive ~= b.competitive then return not a.competitive end
        if a.locked ~= b.locked then return not a.locked end
        return lower(a.name) < lower(b.name)
    end)

    local description
    if #rows > 0 then
        description = "Choose Casual or Competitive Tales of Tribute and queue directly from the Suite."
    elseif next(tributeTypes) == nil then
        description = "This ESO client has not exposed the Tales of Tribute Activity Finder types yet."
    else
        description = "ESO has not exposed the Tales of Tribute queue entries yet. Refresh after Activity Finder data finishes loading."
    end
    local view = paginate("TRIBUTE", rows, "Tales of Tribute", description, "ALL")
    view.queued = self:IsActivityQueued()
    return view
end

function F:IsActivityQueued()
    if type(IsCurrentlySearchingForGroup) == "function" then
        local ok, queued = pcall(IsCurrentlySearchingForGroup)
        if ok and queued then return true end
    end
    if type(GetActivityFinderStatus) == "function" then
        local ok, status = pcall(GetActivityFinderStatus)
        if ok then
            if rawget(_G, "ACTIVITY_FINDER_STATUS_QUEUED") ~= nil and status == ACTIVITY_FINDER_STATUS_QUEUED then return true end
            if rawget(_G, "ACTIVITY_FINDER_STATUS_READY_CHECK") ~= nil and status == ACTIVITY_FINDER_STATUS_READY_CHECK then return true end
        end
    end
    return false
end

function F:QueueSelectedTribute()
    local selected = self:GetSelected("TRIBUTE")
    if not selected then notify("Tales of Tribute: select a queue first."); return false end
    if selected.locked then notify(selected.lockReason ~= "" and selected.lockReason or "That Tales of Tribute queue is locked."); return false end
    if self:IsActivityQueued() then notify("You are already in an Activity Finder queue."); return false end
    if type(ClearActivityFinderSearch) ~= "function" or type(StartActivityFinderSearch) ~= "function" then
        notify("ESO Activity Finder API is unavailable on this client.")
        return false
    end
    if not selected.location or type(selected.location.AddActivitySearchEntry) ~= "function" then
        notify("ESO did not expose a queue action for that Tales of Tribute entry.")
        return false
    end

    pcall(ClearActivityFinderSearch)
    local okAdd = pcall(selected.location.AddActivitySearchEntry, selected.location)
    if not okAdd then notify("Could not add that Tales of Tribute queue."); return false end
    local ok, result = pcall(StartActivityFinderSearch)
    if not ok then notify("ESO rejected the Tales of Tribute queue request."); return false end
    if rawget(_G, "ACTIVITY_QUEUE_RESULT_SUCCESS") ~= nil and result ~= ACTIVITY_QUEUE_RESULT_SUCCESS then
        notify("ESO rejected the Tales of Tribute queue request.")
        return false
    end
    notify("Tales of Tribute queue requested: " .. tostring(selected.name or "queue") .. ".")
    return true
end

function F:CancelActivityQueue()
    if type(CancelGroupSearches) ~= "function" then
        notify("Cancel queue API is unavailable.")
        return false
    end
    local ok = pcall(CancelGroupSearches)
    if ok then notify("Activity Finder queue canceled.") end
    return ok
end

-- --------------------------------------------------------------------------
-- Home Tours / housing browser
-- --------------------------------------------------------------------------

local function extractListingValue(data, keys)
    if type(data) ~= "table" then return nil end
    for _, key in ipairs(keys) do
        local value = data[key]
        if value ~= nil and value ~= "" then return value end
    end
    return nil
end

local function addHouseTourScrollRows(rows, object, sourceName)
    if not object or type(ZO_ScrollList_GetDataList) ~= "function" then return end
    local controls = {}
    local function addControl(control) if control then controls[#controls + 1] = control end end
    addControl(object.list)
    addControl(object.scrollList)
    addControl(object.resultsList)
    addControl(object.listControl)
    addControl(object.control and object.control.list)
    local seenControls = {}
    for _, control in ipairs(controls) do
        if control and not seenControls[control] then
            seenControls[control] = true
            local ok, dataList = pcall(ZO_ScrollList_GetDataList, control)
            if ok and type(dataList) == "table" then
                for _, entry in ipairs(dataList) do
                    local data = type(entry) == "table" and (entry.data or entry) or nil
                    if type(data) == "table" then
                        local name = clean(extractListingValue(data, {"houseName", "name", "formattedHouseName", "title"}) or "")
                        local owner = clean(extractListingValue(data, {"ownerDisplayName", "ownerName", "displayName", "accountName"}) or "")
                        local houseId = tonumber(extractListingValue(data, {"houseId", "houseCollectibleId", "referenceId"})) or 0
                        if name ~= "" or owner ~= "" then
                            if name == "" then name = "Home Tour" end
                            rows[#rows + 1] = {
                                key = makeKey("tour", sourceName, houseId, owner, name),
                                name = name,
                                title = name,
                                detail = owner ~= "" and ("Hosted by " .. owner) or "Public Home Tour",
                                description = "Public Home Tours listing exposed by ESO.",
                                owner = owner,
                                houseId = houseId,
                                listingData = data,
                                source = sourceName,
                                publicTour = true,
                                owned = false,
                            }
                        end
                    end
                end
            end
        end
    end
end

local function collectPublicHouseTourRows()
    local rows = {}
    local names = {
        "HOUSE_TOURS_SEARCH_RESULTS_KEYBOARD",
        "HOUSE_TOURS_RECOMMENDED_KEYBOARD",
        "HOUSE_TOURS_FAVORITES_KEYBOARD",
        "HOUSE_TOURS_SEARCH_RESULTS",
        "HOUSE_TOURS_MANAGER",
    }
    for _, name in ipairs(names) do
        local object = rawget(_G, name)
        if object then
            for _, refreshName in ipairs({"RefreshData", "RefreshList", "RefreshSearchResults", "UpdateSearchResults"}) do
                local fn = object[refreshName]
                if type(fn) == "function" then pcall(fn, object) end
            end
            addHouseTourScrollRows(rows, object, name)
        end
    end
    return rows
end

local function collectHouseCatalogRows()
    local rows = {}
    local categoryType = rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_HOUSE")
    if not categoryType or type(GetTotalCollectiblesByCategoryType) ~= "function" or type(GetCollectibleIdFromType) ~= "function" then
        return rows
    end

    local okCount, count = pcall(GetTotalCollectiblesByCategoryType, categoryType)
    count = okCount and (tonumber(count) or 0) or 0
    local primaryHouseId = 0
    if type(GetHousingPrimaryHouse) == "function" then
        local ok, value = pcall(GetHousingPrimaryHouse)
        if ok then primaryHouseId = tonumber(value) or 0 end
    end

    for index = 1, count do
        local okId, collectibleId = pcall(GetCollectibleIdFromType, categoryType, index)
        collectibleId = okId and (tonumber(collectibleId) or 0) or 0
        if collectibleId > 0 then
            local name, icon = "House", ""
            if type(GetCollectibleInfo) == "function" then
                local okInfo, cName, _, cIcon = pcall(GetCollectibleInfo, collectibleId)
                if okInfo then
                    name = clean(cName) ~= "" and clean(cName) or name
                    icon = tostring(cIcon or "")
                end
            end
            local unlocked = false
            if type(IsCollectibleUnlocked) == "function" then
                local ok, value = pcall(IsCollectibleUnlocked, collectibleId)
                unlocked = ok and value == true
            end
            local houseId = 0
            if type(GetCollectibleReferenceId) == "function" then
                local ok, value = pcall(GetCollectibleReferenceId, collectibleId)
                if ok then houseId = tonumber(value) or 0 end
            end
            local primary = houseId > 0 and houseId == primaryHouseId
            rows[#rows + 1] = {
                key = makeKey("house", collectibleId),
                collectibleId = collectibleId,
                houseId = houseId,
                name = name,
                title = name,
                detail = primary and "Owned • Primary residence" or (unlocked and "Owned" or "Not owned"),
                description = unlocked and "Owned house available through the Suite housing browser." or "House from ESO's live housing collection.",
                owned = unlocked,
                primary = primary,
                icon = icon,
                publicTour = false,
            }
        end
    end
    return rows
end

function F:BuildHomeToursView()
    local s = stateFor("HOMETOURS", "PUBLIC")
    local publicRows = collectPublicHouseTourRows()
    local catalogRows = collectHouseCatalogRows()
    local rows = {}

    if s.filter == "PUBLIC" then
        for _, row in ipairs(publicRows) do rows[#rows + 1] = row end
        -- ESO only instantiates some House Tours result objects after their data
        -- has been requested. Keep the page useful without leaving the Suite by
        -- falling back to the live housing catalog when no public rows exist yet.
        if #rows == 0 then
            for _, row in ipairs(catalogRows) do rows[#rows + 1] = row end
        end
    elseif s.filter == "OWNED" then
        for _, row in ipairs(catalogRows) do if row.owned then rows[#rows + 1] = row end end
    elseif s.filter == "ALL" then
        for _, row in ipairs(catalogRows) do rows[#rows + 1] = row end
    end

    table.sort(rows, function(a, b)
        if a.publicTour ~= b.publicTour then return a.publicTour == true end
        if a.primary ~= b.primary then return a.primary == true end
        if a.owned ~= b.owned then return a.owned == true end
        return lower(a.name) < lower(b.name)
    end)

    local description
    if #publicRows > 0 and s.filter == "PUBLIC" then
        description = "Browse ESO Home Tours results directly inside the Suite."
    elseif s.filter == "PUBLIC" then
        description = "Home Tours stays inside the Suite. Until ESO exposes public search results, the live housing catalog is shown here instead."
    else
        description = "Browse your ESO housing collection directly inside the Suite."
    end
    return paginate("HOMETOURS", rows, "Home Tours", description, "PUBLIC")
end

local function tryListingVisit(row)
    local data = row and row.listingData
    if data then
        for _, methodName in ipairs({"Visit", "RequestVisit", "JumpToHouse", "TravelToHouse"}) do
            if type(data[methodName]) == "function" then
                local ok = pcall(data[methodName], data)
                if ok then return true end
            end
        end
    end
    return false
end

function F:VisitSelectedHome()
    local row = self:GetSelected("HOMETOURS")
    if not row then notify("Home Tours: select a home first."); return false end
    if tryListingVisit(row) then return true end

    if row.publicTour and row.owner ~= "" and type(JumpToHouse) == "function" then
        local ok = pcall(JumpToHouse, row.owner)
        if ok then return true end
    end

    if row.houseId and row.houseId > 0 and row.owned and type(RequestJumpToHouse) == "function" then
        local ok = pcall(RequestJumpToHouse, row.houseId, false)
        if ok then return true end
    end

    notify(row.owned and "ESO rejected the house travel request." or "That home is not currently available to visit from the exposed addon API.")
    return false
end

-- --------------------------------------------------------------------------
-- Shared entry points used by ModernAppUI
-- --------------------------------------------------------------------------

function F:BuildView(tab)
    if tab == "ZONEGUIDE" then return self:BuildZoneGuideView() end
    if tab == "TRIBUTE" then return self:BuildTributeView() end
    if tab == "HOMETOURS" then return self:BuildHomeToursView() end
    return { rows = {}, total = 0, page = 1, pageCount = 1, title = tostring(tab or "Finder") }
end

function F:RunFilter(tab, index)
    index = tonumber(index) or 1
    if tab == "ZONEGUIDE" then
        if index == 1 then self:SelectCurrentZoneGuideZone()
        elseif index == 2 then self:ChangeZoneGuideZone(-1)
        elseif index == 3 then self:ChangeZoneGuideZone(1) end
    elseif tab == "TRIBUTE" then
        local values = {"ALL", "CASUAL", "COMPETITIVE"}
        if index <= 3 then self:SetFilter(tab, values[index]) end
    elseif tab == "HOMETOURS" then
        local values = {"PUBLIC", "OWNED", "ALL"}
        if index <= 3 then self:SetFilter(tab, values[index]) end
    end
end

function F:RunSecondary(tab, index)
    index = tonumber(index) or 1
    if index == 1 then self:ChangePage(tab, -1)
    elseif index == 2 then self:ChangePage(tab, 1) end
end

