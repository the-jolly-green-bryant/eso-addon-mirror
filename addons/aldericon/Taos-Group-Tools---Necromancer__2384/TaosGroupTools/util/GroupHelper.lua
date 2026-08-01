--[[
	Addon: util
	Author: TProg Taonnor
	Created by @Taonnor
]]--

-- Version Control
local VERSION = 3

--[[
	Class definition (Static class)
]]--
-- A table in hole lua workspace must be unique
-- The group helper is global util table, used in several of my addons
-- The table is created as "static" class without constructor and static helper methods
if (TaosGroupHelper == nil or TaosGroupHelper.Version == nil or TaosGroupHelper.Version < VERSION) then
	TaosGroupHelper = {}
	TaosGroupHelper.__index = TaosGroupHelper
    TaosGroupHelper.Version = VERSION

    -- Global Callback Variables
    TAO_GROUP_CHANGED = "TAO-GroupChanged"
    TAO_UNIT_GROUPED_CHANGED = "TAO-UnitGroupedChanged"

	-- local members
	local REFRESH_TIME = 1000 -- ms
	
    local _name = "TaosGroupHelper"
    local _isUnitGrouped = false
	local _groupPlayers = {}
    
    --[[
	    ==============
        PUBLIC METHODS
        ==============
    ]]--

    --[[
        GetIsUnitGrouped Gets the current UnitGrouped state
    ]]--
    function GetIsUnitGrouped()
        return _isUnitGrouped
    end
    
    --[[
        IsTargetGroupMember Gets the information if target is group member
    ]]--
    function IsTargetGroupMember(targetName)
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if (unitTag and zo_strformat("<<1>>", targetName) == GetUnitName(unitTag)) then
                return true, unitTag
            end
        end

        return false
    end
        
    --[[
        IsGroupInCombat Gets the information if group is in combat
    ]]--
    function IsGroupInCombat()
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if (unitTag and IsUnitInCombat(unitTag)) then
                return true
            end
        end

        return false
    end
    
    --[[
	    ===============
        PRIVATE METHODS
        ===============
    ]]--

    --[[
	    Called when group updated
    ]]--
    local function OnGroupUpdate()
        local isGrouped = IsUnitGrouped("player")

        if (isGrouped ~= _isUnitGrouped) then
            _isUnitGrouped = isGrouped
            FireCallbacksAsync(TAO_UNIT_GROUPED_CHANGED, isGrouped)
        end
    end

    --[[
	    Called when group member joined group
    ]]--
    local function OnGroupMemberJoined(eventCode, memberName)
		local playerName = zo_strformat("<<1>>", memberName)
		local isGroupMember, unitTag = IsTargetGroupMember(playerName)

		if (isGroupMember) then
			_groupPlayers[playerName] = true
			FireCallbacksAsync(TAO_GROUP_CHANGED, playerName, true)
		end
		
        OnGroupUpdate()
    end

    --[[
	    Called when group member left group
    ]]--
    local function OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
		local playerName = zo_strformat("<<1>>", memberCharacterName)
		_groupPlayers[playerName] = nil
		
        FireCallbacksAsync(TAO_GROUP_CHANGED, playerName, false)
        OnGroupUpdate()
    end

    --[[
	    Called when loading UI finished
    ]]--
    local function OnPlayerActivated(eventCode)
        -- Initial state
        _isUnitGrouped = IsUnitGrouped("player")

        FireCallbacksAsync(TAO_UNIT_GROUPED_CHANGED, _isUnitGrouped)
        FireCallbacksAsync(TAO_GROUP_CHANGED, "player", false)
    end

    --[[
	    Called REFRESH_TIME finished and updates group players if not catched via MemberJoined
    ]]--
	local function OnTimedUpdate()
		for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if (unitTag and unitTag ~= "invalid") then
                local playerName = GetUnitName(unitTag)

				if (_groupPlayers[playerName] == nil) then
					_groupPlayers[playerName] = true
					FireCallbacksAsync(TAO_GROUP_CHANGED, playerName, true)
				end
            end
        end
	end
	
    --[[
        Register events
    ]]--
	EVENT_MANAGER:RegisterForUpdate(_name, REFRESH_TIME, OnTimedUpdate)
	
	EVENT_MANAGER:RegisterForEvent(_name, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
	EVENT_MANAGER:RegisterForEvent(_name, EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    
end