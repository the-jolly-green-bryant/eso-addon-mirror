OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator
local SYNC_EVENT = "OpulentOrdealNavigatorColorSync"
local PREFIX = "[OONCOLOR]"

local function NormalizeAssignment(value)
    value = value and string.lower(value) or nil
    if value == "yellow" then
        value = "orange"
    end
    if value == "middle" or value == "center" or value == "colourless" or value == "colorless" or value == "none" then
        return "none"
    end
    if value == "red" or value == "orange" or value == "purple" then
        return value
    end
    return nil
end

local function BuildPacket(displayName, color)
    return string.format("%s %s %s", PREFIX, displayName, color)
end

local function NormalizeDisplayName(value)
    value = value and string.match(value, "(@[^%s|]+)") or nil
    return value and string.lower(value) or nil
end

local function ApplyPacket(text, senderName)
    local name, color = string.match(text or "", "^%[OONCOLOR%]%s+(%S+)%s+(%S+)")
    color = NormalizeAssignment(color)
    if not name or not color or NormalizeDisplayName(name) ~= NormalizeDisplayName(senderName) then
        return
    end

    if OON.SetRosterColorSilent then
        OON.SetRosterColorSilent(name, color, "sync")
    end
    if OON.Print then
        OON.Print(string.format("Synced %s as %s.", name, color == "none" and "None" or zo_strformat("<<C:1>>", color)))
    end
end

local function OnChatMessage(_, channelType, fromName, text)
    if not OON.saved
        or not OON.saved.colorSync
        or OON.saved.colorSync.enabled ~= true
        or not OON.IsActive
        or not OON.IsActive()
        or channelType ~= CHAT_CHANNEL_PARTY
    then
        return
    end

    if type(text) == "string" and string.find(text, PREFIX, 1, true) then
        ApplyPacket(text, fromName)
    end
end

function OON.RegisterColorSync()
    if OON.colorSyncRegistered then
        return
    end
    OON.colorSyncRegistered = true

    if EVENT_CHAT_MESSAGE_CHANNEL then
        EVENT_MANAGER:RegisterForEvent(SYNC_EVENT, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
    end
end

function OON.ShareColorAssignment(displayName, color)
    color = NormalizeAssignment(color)
    displayName = displayName or GetUnitDisplayName("player") or GetUnitName("player")
    if not displayName or displayName == "" or not color then
        if OON.Print then
            OON.Print("Use /oon share red, orange, purple, or none.")
        end
        return
    end

    local packet = BuildPacket(displayName, color)
    if StartChatInput and CHAT_CHANNEL_PARTY then
        StartChatInput(packet, CHAT_CHANNEL_PARTY)
        if OON.Print then
            OON.Print("Press Enter to share your OON color packet in party chat.")
        end
        return
    end

    if OON.Print then
        OON.Print("No chat send API available. Share this manually: " .. packet)
    end
end

function OON.BroadcastColorAssignment(displayName, color, reason)
    OON.saved.colorSync = OON.saved.colorSync or {}
    if OON.saved.colorSync.enabled ~= true then
        return
    end

    OON.ShareColorAssignment(displayName, color)
end

function OON.SetColorSyncEnabled(enabled)
    OON.saved.colorSync = OON.saved.colorSync or {}
    OON.saved.colorSync.enabled = enabled == true
    if OON.Print then
        OON.Print(OON.saved.colorSync.enabled and "Color sync receiver enabled. Use /oon share to prepare a party message." or "Color sync disabled.")
    end
end
