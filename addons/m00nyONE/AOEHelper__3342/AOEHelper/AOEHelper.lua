local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}


local function onBossChanged(_ , forceReset)
    if forceReset then
        local zoneID = GetZoneId(GetUnitZoneIndex("player"))
        local zoneColors = AOEHelper.GetZoneColors(zoneID)

        if zoneColors == nil then
            AOEHelper.LoadDefaultColors()
            return
        end

        AOEHelper.SetGameColors(zoneColors)
        --d(zo_strformat(GetString(AOEHELPER_LOADED_COLORS), AOEHelper.filterName(GetUnitZone("player"))))
        return
    end

    -- load boss colors
    local bossColors = AOEHelper.GetBossColors(AOEHelper.GetBossName())
    -- if none are found, just return and do nothing it
    if bossColors == nil then return end
    -- set the gameColors to bossColors
    AOEHelper.SetGameColors(bossColors)
end


local function onPlayerActivated()
    local zoneID = GetZoneId(GetUnitZoneIndex("player"))
    local zoneColors = AOEHelper.GetZoneColors(zoneID)

    if zoneColors == nil then
        AOEHelper.LoadDefaultColors()
        return
    end

    AOEHelper.SetGameColors(AOEHelper.GetZoneColors(zoneID))
    d(zo_strformat(GetString(AOEHELPER_LOADED_COLORS), AOEHelper.filterName(GetUnitZone("player"))))
end

function AOEHelper.OnAddOnLoaded(_, addonName)
    if addonName == AOEHelper.name then
        local startLoadTime2 = GetGameTimeMilliseconds()


        EVENT_MANAGER:UnregisterForEvent(AOEHelper.name, EVENT_ADD_ON_LOADED)

        -- load saved variables ( global )
        AOEHelper.savedVariables = AOEHelper.savedVariables or {}
        AOEHelper.savedVariables = ZO_SavedVars:NewAccountWide("AOEHelperVars", AOEHelper.variableVersion, nil, AOEHelper.defaultVariables, GetWorldName())

        -- check if its the first run
        if AOEHelper.savedVariables.defaultColors == nil then
            AOEHelper.savedVariables.defaultColors = AOEHelper.GetGameColors()
        end

        -- check if AccountSettings by Jodynn is installed & work around the auto settings
        if AccountSettings ~= nil then
            AOEHelper.globalDelay = 6000
        end

        -- create the LibAddonMenu entry
        AOEHelper.createAddonMenu()

        -- use EVENT_PLAYER_ACTIVATED to check the zones because EVENT_ZONE_CHANGED is just an unreliable piece of shit
        EVENT_MANAGER:RegisterForEvent(AOEHelper.name .. "ZoneChange", EVENT_PLAYER_ACTIVATED,
                function() zo_callLater(onPlayerActivated, AOEHelper.globalDelay) end)

        EVENT_MANAGER:RegisterForEvent(AOEHelper.name .. "BossChange", EVENT_BOSSES_CHANGED, onBossChanged)

        local endLoadTime2 = GetGameTimeMilliseconds()
        AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime2 - startLoadTime2)
    end
end

EVENT_MANAGER:RegisterForEvent(AOEHelper.name, EVENT_ADD_ON_LOADED, AOEHelper.OnAddOnLoaded)

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)