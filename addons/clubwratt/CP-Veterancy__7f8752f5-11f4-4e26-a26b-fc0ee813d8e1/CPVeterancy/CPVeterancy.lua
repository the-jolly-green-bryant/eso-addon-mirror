-- CPVeterancy.lua
-- Forces unit frames to show Champion Points instead of the veterancy rank that
-- the base game substitutes while in an active veterancy/PvP progression zone.
--
-- ZO_UnitFrameObject:UpdateLevel() only takes the veterancy branch when
-- ShouldShowVeterancyInfo() returns true; otherwise champion characters show
-- their effective Champion Points. Overriding that check to always return false
-- gives us the out-of-PvP Champion Points display everywhere.

local ADDON_NAME = "CPVeterancy"

local function RefreshUnitFrame(unitTag)
    ---@diagnostic disable-next-line: undefined-global
    local frame = ZO_UnitFrames_GetUnitFrame(unitTag)
    if frame and frame.UpdateLevel then
        frame:UpdateLevel()
    end
end

local function RefreshAllUnitFrames()
    RefreshUnitFrame("player")
    RefreshUnitFrame("reticleover")
    RefreshUnitFrame("companion")

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            RefreshUnitFrame(unitTag)
        end
    end
end

local function OnAddOnLoaded(_eventId, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    ---@diagnostic disable-next-line: undefined-global
    function ZO_UnitFrameObject:ShouldShowVeterancyInfo()
        return false
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, RefreshAllUnitFrames)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
