local ADDON_NAME = "DungeonOrder"

local DUNGEON_ACTIVITY_TYPES =
{
    LFG_ACTIVITY_DUNGEON,
    LFG_ACTIVITY_MASTER_DUNGEON,
}

local DLC_NAME_COLOR = ZO_ColorDef:New("D9A441")
local originalNames = setmetatable({}, { __mode = "k" })

local function CompareLocationsByName(left, right)
    local leftName = left:GetRawName()
    local rightName = right:GetRawName()
    local leftSortName = zo_strlower(leftName)
    local rightSortName = zo_strlower(rightName)

    if leftSortName == rightSortName then
        return leftName < rightName
    end

    return leftSortName < rightSortName
end

local function IsDlcDungeon(location)
    if not location:IsSpecificEntryType() then
        return false
    end

    local requiredCollectibleId = GetRequiredActivityCollectibleId(location:GetId())
    return requiredCollectibleId ~= 0
        and GetCollectibleCategoryType(requiredCollectibleId) == COLLECTIBLE_CATEGORY_TYPE_DLC
end

local function ApplyDlcNameColor(location)
    if not IsDlcDungeon(location) then
        return
    end

    local names = originalNames[location]
    if not names then
        names =
        {
            keyboard = location:GetNameKeyboard(),
            gamepad = location:GetNameGamepad(),
        }
        originalNames[location] = names
    end

    location:SetNameKeyboard(DLC_NAME_COLOR:Colorize(names.keyboard))
    location:SetNameGamepad(DLC_NAME_COLOR:Colorize(names.gamepad))
end

local function RefreshDungeonLocations()
    for _, activityType in ipairs(DUNGEON_ACTIVITY_TYPES) do
        local locations = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(activityType)
        if locations then
            table.sort(locations, CompareLocationsByName)

            for _, location in ipairs(locations) do
                ApplyDlcNameColor(location)
            end
        end
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    RefreshDungeonLocations()
    ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnUpdateLocationData", RefreshDungeonLocations)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
