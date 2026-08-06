--=====================================================================
-- Holodeck_Share.lua — group share hooks (v0.0.11)
--
-- Framed for future LibGroupBroadcast / pack broadcast.
-- Consumers: receive ON, no need to record/edit — only plant + play.
-- Leaders: export compact pack; later broadcast chunks.
--=====================================================================

local H = Holodeck
if not H then return end

H.share = H.share or {
    lastPayload = nil,
    lastFrom = nil,
    lastAt = 0,
}

local function dhd(msg)
    d(string.format("|c69c0ff[%s]|r %s", H.displayName or "Holodeck", tostring(msg)))
end

local function sv()
    return H.savedVars or {}
end

--- Compact pack from current sandbox (keyframes only — training size)
function H.ShareBuildPayload()
    if type(H.SerializeStops) ~= "function" then return nil end
    local data = H.SerializeStops()
    data.shareVersion = 1
    data.meta = data.meta or {}
    data.meta.sharedAt = GetTimeStamp and GetTimeStamp() or GetFrameTimeMilliseconds()
    return data
end

--- Apply a received/imported payload (consumer path)
function H.ShareApplyPayload(data, fromName)
    if type(data) ~= "table" or type(data.stops) ~= "table" then
        dhd("Share: invalid payload.")
        return false
    end
    if sv().shareReceiveEnabled == false then
        dhd("Share: receive is OFF in /hdsettings.")
        return false
    end
    if not H.origin then
        dhd("Share: |cC0E0FF/hd plant|r first, then import again.")
        H.share.lastPayload = data
        return false
    end
    -- Load like a save
    H.stops = {}
    H.types = {}
    for n, list in pairs(data.stops) do
        H.stops[n] = {}
        for i = 1, #list do
            local s = list[i]
            H.stops[n][i] = {
                t = s.t, x = s.x, z = s.z, hold = s.hold or 0,
                visible = s.visible, snap = s.snap,
            }
        end
    end
    if type(data.types) == "table" then
        for n, t in pairs(data.types) do H.types[n] = t end
    end
    H.workingName = data.name or "shared"
    H.playT = 0
    H.playFinished = false
    H.playing = false
    H.share.lastPayload = data
    H.share.lastFrom = fromName or "import"
    H.share.lastAt = GetFrameTimeMilliseconds() or 0

    if type(H.PreferPlayFight) == "function" then pcall(H.PreferPlayFight) end
    if type(H.RebuildPathGfx) == "function" then pcall(H.RebuildPathGfx) end
    if type(H.ApplyTimeline) == "function" then pcall(H.ApplyTimeline, 0, false) end
    if type(H.RefreshUI) == "function" then pcall(H.RefreshUI) end

    dhd(string.format("Share applied: |cC0E0FF%s|r (from %s). /hd play once",
        tostring(H.workingName), tostring(H.share.lastFrom)))
    return true
end

--- Leader: prepare share (stores payload; group bus not wired yet)
function H.ShareOffer()
    local payload = H.ShareBuildPayload()
    if not payload then
        dhd("Share: nothing to offer (empty sandbox).")
        return
    end
    local n = 0
    for _ in pairs(payload.stops or {}) do n = n + 1 end
    if n == 0 then
        dhd("Share: no entities in sandbox.")
        return
    end
    H.share.lastPayload = payload
    -- Also stash as a local save for Discord/export workflow
    if H.savedVars then
        if not H.savedVars.saves then H.savedVars.saves = {} end
        local name = "share_" .. tostring(payload.meta and payload.meta.sharedAt or GetFrameTimeMilliseconds())
        payload.name = name
        H.savedVars.saves[name] = payload
        H.savedVars.lastSaveName = name
        dhd("Share pack ready: |cC0E0FF" .. name .. "|r (" .. n .. " entities).")
        dhd("Team: install Holodeck, plant, /hd open " .. name .. " after you share the save — or use /hd export.")
        dhd("(Live group broadcast hook is stubbed for a later build.)")
    end
end

--- Stub: would register LibGroupBroadcast / map-ping channel
function H.ShareInit()
    -- Future: register message prefix, chunk sender/receiver
    -- Respect sv().shareReceiveEnabled on inbound
end

function H.CmdShare(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "" or arg == "offer" or arg == "push" then
        H.ShareOffer()
    elseif arg == "apply" or arg == "pull" then
        if H.share.lastPayload then
            H.ShareApplyPayload(H.share.lastPayload, "buffer")
        else
            dhd("Share: no buffered payload. Leader must /hd share offer first (or /hd open a save).")
        end
    elseif arg == "status" then
        dhd(string.format("Share receive=%s  buffer=%s  lastFrom=%s",
            tostring(sv().shareReceiveEnabled ~= false),
            H.share.lastPayload and "yes" or "no",
            tostring(H.share.lastFrom or "-")))
    else
        dhd("Usage: /hd share offer|apply|status  ·  receive toggle in /hdsettings")
    end
end
