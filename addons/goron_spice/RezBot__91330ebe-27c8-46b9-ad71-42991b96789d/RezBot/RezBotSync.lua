RezBotSync = RezBotSync or {}
local hasRezBotUsers = {}

local LGB = LibGroupBroadcast

local function isDev()
    local name = GetDisplayName()
    return (name == "@ohmygoron" or name == "@goron_spice")
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

function RezBotSync.HasRezBot(name)
    local cleanName = normalizeName(name)
    return hasRezBotUsers[cleanName] == true
end

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

    local senderName = normalizeName(GetUnitDisplayName(unitTag))
    dbg("[RezBot] Sender name is: " .. tostring(senderName))
    if data.installed and senderName == normalizeName(data.name) then
        hasRezBotUsers[senderName] = true
        dbg("[RezBot] Registered installed user: " .. tostring(senderName))
        return
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

    -- Detect presence ping from isInstalled
    if entry.installed then
        local normName = normalizeName(data.name)
        hasRezBotUsers[normName] = true
        dbg("[RezBot] Registered installed user: " .. tostring(normName))
        -- Optionally: return here if you do NOT want to process status for presence pings
        return
    end

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
        rezProtocol:Send({
            name = name,
            charName = charName, -- Use player's character name
            status = status,
            rezzer = rezzer,
            timestamp = GetGameTimeMilliseconds(),
        })
    else
        dbg("[RezBot] Warning: Cannot send rezUpdate — protocol or Send method missing")
    end
end

function RezBotSync.isInstalled(name, charName)
    if not rezProtocol or not rezProtocol.Send then return end
    rezProtocol:Send({
        name = name,
        charName = charName,
        installed = true,
        timestamp = GetGameTimeMilliseconds(),
    })
    dbg(string.format("[RezBot] isInstalled called for %s (%s)", tostring(name), tostring(charName)))
    if data.installed and senderName == normalizeName(data.name) then
        hasRezBotUsers[senderName] = true
        dbg("[RezBot] Registered installed user: " .. tostring(senderName))
        return
    end
end

-- Sync wrapper for polling logic
function RezBotSync.SyncFromPoll(name, charName, status, rezzer)
    RezBotSync.SendStatus(name, charName, status, rezzer)
end
