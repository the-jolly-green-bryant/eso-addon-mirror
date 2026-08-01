if RezBot and RezBot.__source and RezBot.__source ~= "GoronDev" then
    return
end

if not RezBot or RezBot.__source ~= "GoronDev" then
    return
end

RezBotSync = RezBotSync or {}
local hasRezBotUsers = {}
local selfRegistered = false

local LGB = LibGroupBroadcast

local function isDev()
    local name = GetDisplayName()
    local isDev = name == "@ohmygoron" or name == "@goron_spice"
    d("|c00ff00[RezBot Sync]:|r Checking if developer: " .. tostring(isDev) .. " for " .. tostring(name))
    return isDev
end

local function dbg(msg)
    if isDev() then
        local line = "|c00ff00[RezBot Sync]:|r " .. tostring(msg)
        d(line)
    end
end

if not LGB then
    dbg("[RezBot] Error: LibGroupBroadcast not found.")
    return RezBotSync
end

local handler = LGB:RegisterHandler("RezBotGroupSync", "RezBot")
if not handler then
    dbg("[RezBot] Error: Failed to register handler with LibGroupBroadcast.")
    return RezBotSync
end

handler:SetDisplayName("RezBot Group Sync")
handler:SetDescription("Syncs resurrection status across group members")

local function normalizeName(name)
    return string.gsub(name or "", "^@", "")
end

local function ensureSelfRegistered()
    if selfRegistered then return end
    if not GetDisplayName then return end
    local me = normalizeName(GetDisplayName())
    if me and me ~= "" then
        hasRezBotUsers[me] = true
        selfRegistered = true
        dbg("[RezBot] Registered installed user (self): " .. tostring(me))
    end
end

function RezBotSync.HasRezBot(name)
    local cleanName = normalizeName(name)
    return hasRezBotUsers[cleanName] == true
end

ensureSelfRegistered()

-- Define protocol
local rezProtocol = handler:DeclareProtocol(101, "RezBotStatus")
if not rezProtocol then
    dbg("[RezBot] Error: Failed to declare protocol RezBotStatus.")
    return RezBotSync
end

if dbg then
    dbg("[RezBot] Successfully declared RezBotStatus protocol.")
end

rezProtocol:AddField(LGB.CreateStringField("name"))
rezProtocol:AddField(LGB.CreateStringField("status"))
rezProtocol:AddField(LGB.CreateStringField("rezzer"))
rezProtocol:AddField(LGB.CreateNumericField("timestamp"))
rezProtocol:AddField(LGB.CreateFlagField("installed")) -- Optional field for installed status

rezProtocol:OnData(function(unitTag, data)
    dbg("[RezBot] OnData handler fired!")
    if not data then
        dbg("[RezBot] OnData received nil data.")
        return
    end

    dbg("OnData called with unitTag: " .. tostring(unitTag))

    local name   = data.name
    local charName = data.charName or name -- Use charName if available, otherwise fallback to name
    local status = data.status
    local rezzer = data.rezzer
    local since  = data.timestamp

    local senderDisplayName = GetUnitDisplayName and GetUnitDisplayName(unitTag) or nil
    dbg("[RezBot] Testing if this fires at all right now")
    if senderDisplayName and senderDisplayName ~= "" then
        local senderName = normalizeName(senderDisplayName)
        dbg("[RezBot] Sender name is: " .. tostring(senderName))
        if senderName ~= "" then
            hasRezBotUsers[senderName] = true
            dbg("[RezBot] Registered installed user (sender): " .. tostring(senderName))
        end
    else
        dbg("[RezBot] Sender name is empty or nil.")
    end


    local tag = findUnitTagByName and findUnitTagByName(name)
    local accountName
    if tag and GetUnitDisplayName then
        accountName = GetUnitDisplayName(tag)
    else
        accountName = name
    end

    local normName = normalizeName(accountName)

    -- Log any missing fields
    if not name then dbg("[RezBot] Missing field: name") end
    if not charName then dbg("[RezBot] Missing field: charName") end
    if not status then dbg("[RezBot] Missing field: status") end
    if not rezzer then dbg("[RezBot] Missing field: rezzer") end
    if not since then dbg("[RezBot] Missing field: timestamp") end
    local installed = data.installed

    -- Full dump for edge cases
    if not name or not status then
        dbg("[RezBot] Incomplete data received:")
        for k, v in pairs(data) do
            dbg(string.format("  %s = %s", tostring(k), tostring(v)))
        end
        return
    end

    resStates = resStates or {}
    resStates[normName] = resStates[normName] or {}
    local entry = resStates[normName]

    -- Only allow valid status transitions
    local currentStatus = entry.status
    local validTransition = true

    if currentStatus == RezBot.STATUS_PENDING then
        if status == RezBot.STATUS_DOWN then
            -- Only allow transition to DOWN if the unit is actually dead
            local tag = findUnitTagByName and findUnitTagByName(charName)
            if tag and DoesUnitExist(tag) and IsUnitDead(tag) then
                dbg(string.format("[RezBot] IsUnitDead returns true for %s", tostring(normName)))
            -- Valid transition, allow
            else
                dbg(string.format("[RezBot] Ignoring DOWN transition for %s (not actually dead)", tostring(normName)))
                validTransition = false
            end
        elseif status ~= RezBot.STATUS_REZZING and status ~= RezBot.STATUS_PENDING then
            dbg(string.format("[RezBot] Clearing pending status for %s due to %s", tostring(normName), tostring(status)))
            entry.status = nil
            entry.rezzer = nil
            entry.since = nil
            validTransition = false
        end
    end

    if validTransition then
        entry.status = status
        entry.rezzer = rezzer
        entry.since = (type(since) == "number" and since > 0) and since or GetGameTimeMilliseconds()
        entry.installed = installed
        if installed and normName ~= "" then
            hasRezBotUsers[normName] = true
            dbg("[RezBot] Registered installed user (payload): " .. tostring(normName))
        end
        dbg("RezBotSync call")
        dbg(string.format("[RezBot] Synced %s → %s (rezzer: %s, timestamp: %s)", normName, status, tostring(rezzer), tostring(since)))
    end

    if RefreshUI then
        dbg("[RezBot] Calling RefreshUI()")
        RefreshUI()
    end
end)


local ok, err = pcall(function()
    rezProtocol:Finalize({
        isRelevantInCombat = true,
        replaceQueuedMessages = true,
    })
end)

if not ok then
    dbg("[RezBot] Protocol Finalize failed: " .. tostring(err))
end

-- Optional API for other addons
local RezBotAPI = {
    GetStatus = function(name)
        return resStates and resStates[normalizeName(name)] or nil
    end
}
handler:SetApi(RezBotAPI)

-- Broadcast a resurrection update
function RezBotSync.SendStatus(name, charName, status, rezzer)
    ensureSelfRegistered()
    if not rezProtocol then
        dbg("[RezBot] rezProtocol is nil in SendStatus")
        return
    elseif not rezProtocol.Send then
        dbg("[RezBot] rezProtocol.Send is nil in SendStatus")
        return
    end
    if not charName or charName == "" then
        dbg("[RezBot] SendStatus called with empty charName")
        return
    end
    if rezProtocol and rezProtocol.Send then
        dbg("[RezBot Sync] SendStatus called")
        rezProtocol:Send({
            name = name,
            charName = charName,
            status = status,
            rezzer = rezzer,
            timestamp = GetGameTimeMilliseconds(),
            installed = true,
        })
    else
        dbg("[RezBot] Warning: Cannot send rezUpdate — protocol or Send method missing")
    end
end

-- Sync wrapper for polling logic
function RezBotSync.SyncFromPoll(name, charName, status, rezzer)
    RezBotSync.SendStatus(name, charName, status, rezzer)
end
