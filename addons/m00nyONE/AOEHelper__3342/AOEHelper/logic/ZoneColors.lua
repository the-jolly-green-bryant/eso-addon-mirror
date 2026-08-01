local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}

-- save colors for a zone to saved variables
--[[
    zoneID: number
    color = {
        enemyColor: string | nil
        enemyBrightness: number | nil
        friendlyColor: string | nil
        friendlyBrightness: number | nil
    }
]]--
function AOEHelper.SetZoneColors(zoneID, colors)

    if type(colors) ~= "table" then d("argument is not a table") return end

    if AOEHelper.savedVariables.savedZones[zoneID] == nil then
        AOEHelper.savedVariables.savedZones[zoneID] = {}
    end

    if colors.enemyColor ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].enemyColor = colors.enemyColor
    end
    if colors.enemyBrightness ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].enemyBrightness = colors.enemyBrightness
    end
    if colors.friendlyColor ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].friendlyColor = colors.friendlyColor
    end
    if colors.friendlyBrightness ~= nil then
        AOEHelper.savedVariables.savedZones[zoneID].friendlyBrightness = colors.friendlyBrightness
    end
end

-- get the Colors from a saved zone - if it does not exist it returns nil
--[[
    zoneID: number
]]--
function AOEHelper.GetZoneColors(zoneID)

    if AOEHelper.savedVariables.savedZones[zoneID] == nil then return nil end

    local defaultColors = AOEHelper.savedVariables.defaultColors
    local zoneColors = AOEHelper.savedVariables.savedZones[zoneID]

    if zoneColors.enemyColor == nil then zoneColors.enemyColor = defaultColors.enemyColorend end
    if zoneColors.enemyBrightness == nil then zoneColors.enemyBrightness = defaultColors.enemyBrightness end
    if zoneColors.friendlyColor == nil then zoneColors.friendlyColor = defaultColors.friendlyColor end
    if zoneColors.friendlyBrightness == nil then zoneColors.friendlyBrightness = defaultColors.friendlyBrightness end

    return zoneColors
end

-- remove a zone from the saved variables
function AOEHelper.DeleteZoneColors(zoneID)
    if AOEHelper.savedVariables.savedZones[zoneID] == nil then return end
    AOEHelper.savedVariables.savedZones[zoneID] = nil
end

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)