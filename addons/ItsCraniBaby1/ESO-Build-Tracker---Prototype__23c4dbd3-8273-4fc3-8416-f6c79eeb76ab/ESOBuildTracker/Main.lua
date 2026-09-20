local A = ESOBuildTracker
local refreshName = A.name .. "QueuedRefresh"

-- Coalesce equipment/skill event bursts into one complete read. There is no
-- combat loop, filesystem access, network request, or equipment mutation.
function A.QueueRefresh(reason)
    if not A.ready or not A.active then return end
    EVENT_MANAGER:UnregisterForUpdate(refreshName)
    EVENT_MANAGER:RegisterForUpdate(refreshName, 250, function()
        EVENT_MANAGER:UnregisterForUpdate(refreshName)
        A.Refresh(reason)
    end)
end

function A.PrintStatus()
    local snapshot = A.live
    A.Notify("Version " .. A.version .. "; API " .. tostring(GetAPIVersion()) .. "; menu " .. (A.menuInstalled and "installed" or "unavailable") .. "; snapshots " .. tostring(A.saved and #A.saved.snapshots or 0) .. ".")
    if snapshot then
        A.Notify("Captured " .. A.CaptureTimeText(snapshot) .. "; " .. tostring(#snapshot.warnings) .. " warning(s).")
        for _, warning in ipairs(snapshot.warnings) do A.Notify(warning) end
    end
    if A.captureError then A.Notify("Last capture error: " .. A.captureError) end
    if A.uiError then A.Notify("Interface error: " .. A.uiError) end
end

local function OnSlash(text)
    local command = string.lower((text or ""):match("^%s*(%S*)") or "")
    if command == "save" then
        A.SaveSnapshot()
    elseif command == "refresh" then
        if A.Refresh("chat refresh") then A.Notify("Live setup refreshed.") end
    elseif command == "status" then
        A.PrintStatus()
    elseif command == "help" then
        A.Notify("/ebt opens Gear, Skills, Stats and Builds. LB/RB changes tabs; up/down selects; A opens options; Y refreshes. /ebt save records live gear and bars. /ebt status shows diagnostics.")
    else
        A.Open()
    end
end

local function OnPlayerActivated()
    A.active = true
    if not A.ready then
        A.InitializeStorage()
        A.ready = true
    end
    local ok, err = pcall(function()
        A.BuildUI()
        A.InstallMenuEntry()
    end)
    if not ok then A.uiError = tostring(err); A.Notify("Interface setup failed. /ebt status shows details; capture is still available.") end
    A.QueueRefresh("character loaded")
    if not A.welcomed then
        A.welcomed = true
        A.Notify("Prototype loaded. Open ESO Build Tracker at the bottom of the controller menu, or use /ebt. Use /ebt status if it is missing.")
    end
end

local function Register(eventName, callback)
    local event = _G[eventName]
    if event ~= nil then EVENT_MANAGER:RegisterForEvent(A.name .. eventName, event, callback) end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= A.name then return end
    EVENT_MANAGER:UnregisterForEvent(A.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/ebt"] = OnSlash
    Register("EVENT_PLAYER_ACTIVATED", OnPlayerActivated)
    Register("EVENT_PLAYER_DEACTIVATED", function()
        A.active = false
        EVENT_MANAGER:UnregisterForUpdate(refreshName)
        -- Keep the last complete capture. Do not query a character while it is
        -- being unloaded; ESO persists our declared SavedVariables itself.
    end)
    Register("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", function(_, bag)
        if bag == BAG_WORN then A.QueueRefresh("equipped item changed") end
    end)
    Register("EVENT_INVENTORY_FULL_UPDATE", function() A.QueueRefresh("inventory refreshed") end)
    Register("EVENT_HOTBAR_SLOT_UPDATED", function(_, _, category)
        if category == HOTBAR_CATEGORY_PRIMARY or category == HOTBAR_CATEGORY_BACKUP then A.QueueRefresh("skill assignment changed") end
    end)
    Register("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED", function() A.QueueRefresh("active hotbar changed") end)
    Register("EVENT_ACTIVE_WEAPON_PAIR_CHANGED", function() A.QueueRefresh("weapon pair changed") end)
    Register("EVENT_SKILLS_FULL_UPDATE", function() A.QueueRefresh("skills refreshed") end)
    Register("EVENT_SKILL_POINTS_CHANGED", function() A.QueueRefresh("skill points changed") end)
end

EVENT_MANAGER:RegisterForEvent(A.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
