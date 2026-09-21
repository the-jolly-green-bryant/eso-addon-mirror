-- ESO Build Tracker. Original prototype implementation.
ESOBuildTracker = {
    name = "ESOBuildTracker",
    title = "ESO Build Tracker",
    version = "0.3.0",
    schemaVersion = 1,
    referenceAPIVersion = 101050,
    maxSnapshots = 5,
    maxBuilds = 10,
    sceneName = "esoBuildTracker",
    viewIndex = 0, -- 0 = live; 1..5 = newest to oldest saved snapshots.
}

local A = ESOBuildTracker
local unpackValues = unpack or table.unpack

local function Pack(...)
    return { n = select("#", ...), ... }
end

function A.Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = A.Copy(child) end
    return result
end

-- A failed getter must never be mistaken for an empty slot or a zero stat.
-- This wrapper preserves interior nils in functions with multiple returns.
function A.Call(warnings, name, ...)
    local fn = _G[name]
    if type(fn) ~= "function" then
        if warnings then warnings[name] = name .. ": API not available." end
        return nil
    end
    local result = Pack(pcall(fn, ...))
    if not result[1] then
        if warnings then warnings[name] = name .. ": " .. tostring(result[2]) end
        return nil
    end
    return unpackValues(result, 2, result.n)
end

function A.CleanName(value)
    if not value or value == "" then return "Unavailable" end
    if zo_strformat then return zo_strformat("<<1>>", value) end
    return tostring(value)
end

function A.EnumName(prefix, value)
    if value == nil then return "Unavailable" end
    local result = A.Call(nil, "GetString", prefix, value)
    if not result or result == "" then return "Unknown (" .. tostring(value) .. ")" end
    return result
end

function A.WarningList(warnings)
    local result = {}
    for _, message in pairs(warnings) do result[#result + 1] = message end
    table.sort(result)
    return result
end

function A.Notify(message)
    A.statusText = message
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage("|c89d5efESO Build Tracker|r: " .. message)
    elseif d then
        d("ESO Build Tracker: " .. message)
    end
    if A.UpdateStatus then A.UpdateStatus() end
end

function A.GetViewedSnapshot()
    if A.viewIndex == 0 then return A.live end
    return A.saved and A.saved.snapshots[A.viewIndex] or nil
end

function A.Refresh(reason)
    if not A.ready then return nil end
    local ok, snapshot = pcall(A.Capture, reason or "refresh")
    if not ok then
        A.captureError = tostring(snapshot)
        A.Notify("Capture failed. Previous data was retained. Use /ebt status for details.")
        return nil
    end
    A.captureError = nil
    A.live = snapshot
    -- Last seen is automatic; user snapshots are independent deep copies.
    A.saved.lastSeen = A.Copy(snapshot)
    if A.viewIndex == 0 and A.scene and A.scene:IsShowing() then A.RebuildPages() end
    return snapshot
end

function A.SaveSnapshot()
    local snapshot = A.Refresh("saved manually")
    if not snapshot then return end
    if snapshot.characterId == nil or snapshot.coreDataComplete == false then
        A.Notify("Snapshot not saved: required equipment or bar data is unavailable. See Diagnostics.")
        return
    end
    local saved = A.Copy(snapshot)
    saved.snapshotNumber = A.saved.nextSnapshotNumber
    saved.label = "Snapshot " .. tostring(saved.snapshotNumber)
    A.saved.nextSnapshotNumber = A.saved.nextSnapshotNumber + 1
    table.insert(A.saved.snapshots, 1, saved)
    local replacedOldest = #A.saved.snapshots > A.maxSnapshots
    while #A.saved.snapshots > A.maxSnapshots do table.remove(A.saved.snapshots) end
    A.viewIndex = 1
    A.pageIndex = 1
    if A.RebuildPages then A.RebuildPages() end
    local suffix = replacedOldest and " Oldest snapshot replaced (five retained)." or ""
    A.Notify(saved.label .. " saved. It will be written by ESO on a clean logout or UI reload." .. suffix)
end

function A.CycleView()
    local count = A.saved and #A.saved.snapshots or 0
    if count == 0 then A.Notify("No snapshots yet. Press Save to record the current setup."); return end
    A.viewIndex = (A.viewIndex + 1) % (count + 1)
    A.pageIndex = 1
    if A.viewIndex == 0 then A.Refresh("returned to live view") end
    if A.RebuildPages then A.RebuildPages() end
end

function A.InitializeStorage()
    A.saved = ZO_SavedVars:NewCharacterIdSettings(
        "ESOBuildTrackerSavedVariables", A.schemaVersion, nil,
        { snapshots = {}, nextSnapshotNumber = 1 }, GetWorldName()
    )
    -- Version 1 adds missing defaults without clearing existing history.
    if type(A.saved.snapshots) ~= "table" then A.saved.snapshots = {} end
    if type(A.saved.nextSnapshotNumber) ~= "number" then A.saved.nextSnapshotNumber = 1 end
    -- Keep SavedVariables version 1: raising it would discard the user's
    -- working 0.1 snapshots. New tracking fields are additive.
    if type(A.saved.builds) ~= "table" then A.saved.builds = {} end
    if type(A.saved.nextBuildNumber) ~= "number" then A.saved.nextBuildNumber = 1 end
end
