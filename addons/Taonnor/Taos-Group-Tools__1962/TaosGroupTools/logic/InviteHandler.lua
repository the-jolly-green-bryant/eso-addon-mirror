--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
-- Group Ultimate Callbacks
TGT_GROUP_INVITE_RUNNING_CHANGED = "TGT-GroupInviteRunningChanged"

--[[
	Local variables
]]--
local REFRESHRATE = 1000 -- ms; RegisterForUpdate is in miliseconds

local _logger = nil

local _name = "TGT-InviteHandler"
local _isRunning = false
local _currentInviteString = ""
local _autoKickList = {}
local _regroupList = {}

--[[
	Table TGT_InviteHandler
]]--
TGT_InviteHandler = {}
TGT_InviteHandler.__index = TGT_InviteHandler

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Callback of EVENT_CHAT_MESSAGE_CHANNEL, handles text from chat against InviteString
]]--
local function OnNewChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    -- Ignore text in group chat
    if (channelType ~= CHAT_CHANNEL_PARTY) then
        -- Only if text is CurrentInviteString
        if (text == _currentInviteString) then
            -- Ignore messages from yourself
            if (GetDisplayName() ~= fromDisplayName) then
                -- Only if you are leader
                if (IsUnitSoloOrGroupLeader("player")) then
                    local currentGroupSize = GetGroupSize()
                    local maxGroupSize = TGT_SettingsHandler.SavedVariables.MaxGroupSize

                    -- Check against configurated maxGroupSize
                    if (currentGroupSize < maxGroupSize) then
                        -- Invite player
                        d(zo_strformat(GetString(TGT_UI_AUTOINVITE_SEND_INVITE), fromDisplayName))
                        GroupInviteByName(fromDisplayName)
                    end
                end
            end
        end
    end
end

--[[
	Starts inviting of players in base of CurrentInviteString
]]--
local function StartInvite()
    -- Set IsRunning
    _isRunning = true
    FireCallbacksAsync(TGT_GROUP_INVITE_RUNNING_CHANGED, _isRunning)

    -- Register listening on chat
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_CHAT_MESSAGE_CHANNEL, OnNewChatMessage)

    -- Start auto kick if activated
    if (TGT_SettingsHandler.SavedVariables.AutoKick) then
        TGT_InviteHandler.StartAutoKick()
        d(zo_strformat(GetString(TGT_UI_AUTOINVITE_START_KICK_INFO), _currentInviteString))
    else
        d(zo_strformat(GetString(TGT_UI_AUTOINVITE_START_INFO), _currentInviteString))
    end
end

--[[
	Called on refresh of timer
]]--
local function OnTimedUpdate(eventCode)
    -- Only if you are grouped and leader
    if (GetIsUnitGrouped() and IsUnitGroupLeader("player")) then
        -- Check all offline players and kick if > timeout
        local timeout = TGT_SettingsHandler.SavedVariables.AutoKickTimeout

        for i = #_autoKickList, 1, -1 do
            local unitTimestamp = _autoKickList[i].unitTimeStamp
            local currentTimestamp = GetTimeStamp()
            local difference = currentTimestamp - unitTimestamp

            if (difference > timeout) then
                local unitName = GetUnitDisplayName(_autoKickList[i].unitTag)

                -- Still offline?
                if (IsUnitOnline(_autoKickList[i].unitTag) == false) then
                    -- Kick
                    d(zo_strformat(GetString(TGT_UI_AUTOINVITE_AUTOKICK_INFO), unitName))
                    GroupKick(_autoKickList[i].unitTag)
                end
                
                -- Remove
                table.remove(_autoKickList, i)
            end
        end
    end
end

--[[
	Called on EVENT_GROUP_MEMBER_CONNECTED_STATUS
]]--
local function OnGroupMemberConnected(eventCode, unitTag, isOnline)
    local found = false

    for i = #_autoKickList, 1, -1 do
        if (_autoKickList[i].unitTag == unitTag) then
            -- If online, remove; otherwise update
            if (isOnline) then
                table.remove(_autoKickList, i)
            else
                _autoKickList[i].unitTimeStamp = GetTimeStamp()
            end

            found = true
            break -- found
        end
    end

    -- If not found, add
    if (found == false) then
        -- Do not add if isOnline
        if (isOnline == false) then
            local newElementId = #_autoKickList + 1
            local unitTimeStamp = GetTimeStamp()

            _autoKickList[newElementId] = {}
            _autoKickList[newElementId].unitTag = unitTag
            _autoKickList[newElementId].unitTimeStamp = unitTimeStamp
        end
    end
end

--[[
	Performs regroup process
]]--
local function PerformRegroup()
    -- Perform invite and clear
    for i = #_regroupList, 1, -1 do
        -- Invite player
        d(zo_strformat(GetString(TGT_UI_AUTOINVITE_SEND_INVITE), _regroupList[i]))
        GroupInviteByName(_regroupList[i])

        -- Clear entry
        table.remove(_regroupList, i)
    end

    -- Start auto kick if activated
    if (TGT_SettingsHandler.SavedVariables.AutoKick) then
        TGT_InviteHandler.StartAutoKick()
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Sets invite string and start/stop automatic invite
]]--
function TGT_InviteHandler.SetInviteString(inviteString)
    if (_isRunning) then
        if (inviteString == _currentInviteString) then
            -- Stop
            TGT_InviteHandler.StopInvite()
        else
            -- Change string
            _currentInviteString = inviteString

            if (TGT_SettingsHandler.SavedVariables.AutoKick) then
                d(zo_strformat(GetString(TGT_UI_AUTOINVITE_START_KICK_INFO), _currentInviteString))
            else
                d(zo_strformat(GetString(TGT_UI_AUTOINVITE_START_INFO), _currentInviteString))
            end
        end
    else
        -- Change string
        _currentInviteString = inviteString

        -- Start
        StartInvite()
    end
end

--[[
	Stops inviting of players and resets CurrentInviteString
]]--
function TGT_InviteHandler.StopInvite()
    -- Unregister listening on chat
    EVENT_MANAGER:UnregisterForEvent(_name, EVENT_CHAT_MESSAGE_CHANNEL)

    -- Resets invite string
    _currentInviteString = ""

    -- Stop auto kick
    TGT_InviteHandler.StopAutoKick()

    -- Set IsRunning
    _isRunning = false
    FireCallbacksAsync(TGT_GROUP_INVITE_RUNNING_CHANGED, _isRunning)

    d(GetString(TGT_UI_AUTOINVITE_STOP_INFO))
end

--[[
	Starts auto kicking members in group
]]--
function TGT_InviteHandler.StartAutoKick()
    -- Register listening offline/online status
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupMemberConnected)

    -- Start timer
	EVENT_MANAGER:RegisterForUpdate(_name, REFRESHRATE, OnTimedUpdate)

    -- Check group for offline members and add them to list
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if (IsUnitOnline(unitTag) == false) then
            local newElementId = #_autoKickList + 1
            local unitTimeStamp = GetTimeStamp()

            _autoKickList[newElementId] = {}
            _autoKickList[newElementId].unitTag = unitTag
            _autoKickList[newElementId].unitTimeStamp = unitTimeStamp
        end
    end
end

--[[
	Stops auto kicking members in group
]]--
function TGT_InviteHandler.StopAutoKick()
    -- Stop timer
	EVENT_MANAGER:UnregisterForUpdate(_name)

    -- Unregister listening offline/online status
    EVENT_MANAGER:UnregisterForEvent(_name, EVENT_GROUP_MEMBER_CONNECTED_STATUS)

    -- Clear auto kick list
    for i = #_autoKickList, 1, -1 do
        table.remove(_autoKickList, i)
    end
end

--[[
	Starts regroup process
]]--
function TGT_InviteHandler.Regroup()
    -- Only if you are grouped and leader
    if (GetIsUnitGrouped() and IsUnitGroupLeader("player")) then
        -- Get group display names
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            local unitDisplayName = GetUnitDisplayName(unitTag)

            -- Ignore yourself
            if (GetDisplayName() ~= unitDisplayName) then
                local newElementId = #_regroupList + 1
                _regroupList[newElementId] = unitDisplayName
            end
        end
    
        -- Stop AutoKick, because group will reinvited
        TGT_InviteHandler.StopAutoKick()

        -- Disband group
        GroupDisband()

        -- Start regroup process
        zo_callLater(TGT_InviteHandler.PerformRegroup(), REFRESHRATE)
    end
end

--[[
	Initialize initializes TGT_InviteHandler
]]--
function TGT_InviteHandler.Initialize()
    _logger = TGT_LOGGER
    _logger:logTrace("TGT_InviteHandler -> Initialized")
end