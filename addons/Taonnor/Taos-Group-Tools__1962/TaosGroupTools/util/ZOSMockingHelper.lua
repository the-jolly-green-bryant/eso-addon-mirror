--[[
	Addon: util
	Author: TProg Taonnor
	Created by @Taonnor
]]--

-- Version Control
local VERSION = 2

--[[
	Class definition (Static class)
]]--
-- A table in hole lua workspace must be unique
-- The ui helper is global util table, used in several of my addons
-- The table is created as "static" class without constructor and static helper methods
if (TaosZOSMockingHelper == nil or TaosZOSMockingHelper.Version == nil or TaosZOSMockingHelper.Version < VERSION) then
	TaosZOSMockingHelper = {}
	TaosZOSMockingHelper.__index = TaosZOSMockingHelper
    TaosZOSMockingHelper.Version = VERSION

	local _oldGetGroupUnitTagByIndex = nil
    local _oldGetUnitName = nil
    local _oldIsUnitDead = nil
    local _oldIsUnitGrouped = nil
    local _oldGetGroupSize = nil
    local _oldIsUnitInCombat = nil
    local _oldGetUnitPower = nil
    
    --[[
	    ===============
        PRIVATE METHODS
        ===============
    ]]--

    --[[
	    Mocks GetGroupUnitTagByIndex, returns always "player"
    ]]--
    local function GetGroupUnitTagByIndexMock(i)
        return "waypoint" .. i
    end

    --[[
	    Mocks GetUnitName, returns always playerTag if not "player"
    ]]--
    local function GetUnitNameMock(playerTag)
        if (playerTag == "player") then
            return "waypoint1"
        elseif (playerTag == "") then
            return _oldGetUnitName("player")
        else 
            return playerTag
        end
    end

    --[[
	    Mocks IsUnitDead, returns randomly unit death
    ]]--
    local function IsUnitDeadMock(playerTag)
        return _oldIsUnitDead("player")
    end

    --[[
	    Mocks IsUnitGrouped, returns always player in group
    ]]--
    local function IsUnitGroupedMock(playerTag)
        return true
    end

    --[[
	    Mocks GetGroupSize, returns always player in group with 6 players
    ]]--
    local function GetGroupSizeMock()
        return 24
    end
    
    --[[
	    Mocks IsUnitInCombatMock, returns always player status
    ]]--
    local function IsUnitInCombatMock(playerTag)
        return _oldIsUnitInCombat("player")
    end
    
    --[[
	    Mocks GetUnitPowerMock, returns always player status
    ]]--
    local function GetUnitPowerMock(playerTag, powerType)
        return _oldGetUnitPower("player", powerType)
    end

    --[[
	    ==============
        PUBLIC METHODS
        ==============
    ]]--

    --[[
	    Mocks needed ZOS methods with mock methods
    ]]--
    function MockZOSMethods()
		-- Mock GetGroupUnitTagByIndex
		_oldGetGroupUnitTagByIndex = GetGroupUnitTagByIndex
		GetGroupUnitTagByIndex = GetGroupUnitTagByIndexMock
		
        -- Mock GetUnitName
        _oldGetUnitName = GetUnitName
        GetUnitName = GetUnitNameMock

        -- Mock IsUnitDead
        _oldIsUnitDead = IsUnitDead
        IsUnitDead = IsUnitDeadMock

        -- Mock IsUnitGrouped
        _oldIsUnitGrouped = IsUnitGrouped
        IsUnitGrouped = IsUnitGroupedMock

        -- Mock GetGroupSize
        _oldGetGroupSize = GetGroupSize
        GetGroupSize = GetGroupSizeMock

        -- Mock IsUnitInCombat
        _oldIsUnitInCombat = IsUnitInCombat
        IsUnitInCombat = IsUnitInCombatMock

        -- Mock GetUnitPower
        _oldGetUnitPower = GetUnitPower
        GetUnitPower = GetUnitPowerMock
    end
end