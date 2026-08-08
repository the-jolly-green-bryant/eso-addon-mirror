local Relationships = {}
Relationships.name = "Relationships"

local REL = Relationships
local EM = EVENT_MANAGER

local defaultSV = {
    friendList = {},
    lastRemoved = "",
}

local ICON_YES = "|t20:20:Relationships/Textures/yes.dds|t"
local ICON_NO = "|t20:20:Relationships/Textures/no.dds|t"

function REL.OnPlayerActivated()
    local currentFriends = {}
    local numFriends = GetNumFriends()
    
    for i = 1, numFriends do
        local displayName = GetFriendInfo(i)
        if displayName and displayName ~= "" then
            currentFriends[displayName] = true
        end
    end
    
    local storedFriends = REL.SV.friendList
    for displayName, _ in pairs(storedFriends) do
        if not currentFriends[displayName] then
            local message = string.format("|cFF0000[Relationships]|r |cFFFF00%s|r %s", displayName, ICON_NO)
            d(message)
            REL.SV.lastRemoved = displayName
        end
    end
    
    REL.SV.friendList = currentFriends
end

function REL.OnFriendAdded(eventId, displayName)
    if displayName and displayName ~= "" then
        REL.SV.friendList[displayName] = true
        local message = string.format("|c00FF00[Relationships]|r |cFFFF00%s|r %s", displayName, ICON_YES)
        d(message)
    end
end

function REL.OnFriendRemoved(eventId, displayName)
    if displayName and displayName ~= "" then
        REL.SV.friendList[displayName] = nil
        REL.SV.lastRemoved = displayName
        local message = string.format("|cFF0000[Relationships]|r |cFFFF00%s|r %s", displayName, ICON_NO)
        d(message)
    end
end

function REL.OnSlashCommand()
    local lastRemoved = REL.SV.lastRemoved
    if lastRemoved and lastRemoved ~= "" then
        local message = string.format("|cFF0000[Relationships]|r Last removed: |cFFFF00%s|r %s", lastRemoved, ICON_NO)
        d(message)
    else
        d("|cFF0000[Relationships]|r No data.")
    end
end

function REL.OnAddonLoaded(event, addonName)
    if addonName ~= REL.name then return end
	
    EM:UnregisterForEvent(REL.name, EVENT_ADD_ON_LOADED)
    
    REL.SV = ZO_SavedVars:NewAccountWide("Relationships_SV", 1, nil, defaultSV, GetWorldName())
	
	SLASH_COMMANDS["/rellast"] = REL.OnSlashCommand
        
    EM:RegisterForEvent(REL.name, EVENT_PLAYER_ACTIVATED, REL.OnPlayerActivated)
    EM:RegisterForEvent(REL.name, EVENT_FRIEND_ADDED, REL.OnFriendAdded)
    EM:RegisterForEvent(REL.name, EVENT_FRIEND_REMOVED, REL.OnFriendRemoved)
end

EM:RegisterForEvent(REL.name, EVENT_ADD_ON_LOADED, REL.OnAddonLoaded)
