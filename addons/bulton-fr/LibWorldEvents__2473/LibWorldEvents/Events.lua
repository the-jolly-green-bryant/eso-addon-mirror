LibWorldEvents.Events = {}

LibWorldEvents.Events.callbackManager = ZO_CallbackObject:New()
LibWorldEvents.Events.callbackEvents  = {
    dragon       = {
        new          = "LibWETracker_Event_Dragon_New",
        changeStatus = "LibWETracker_Event_Dragon_ChangeStatus",
        changeType   = "LibWETracker_Event_Dragon_ChangeType",
        resetStatus  = "LibWETracker_Event_Dragon_ResetStatus",
        poped        = "LibWETracker_Event_Dragon_Poped",
        killed       = "LibWETracker_Event_Dragon_Killed",
        waiting      = "LibWETracker_Event_Dragon_Waiting",
        fight        = "LibWETracker_Event_Dragon_Fight",
        weak         = "LibWETracker_Event_Dragon_Weak",
        flying       = "LibWETracker_Event_Dragon_flying",
        landed       = "LibWETracker_Event_Dragon_landed",
    },
    dragonList   = {
        reset     = "LibWETracker_Event_DragonList_Reset",
        add       = "LibWETracker_Event_DragonList_Add",
        update    = "LibWETracker_Event_DragonList_Update",
        removeAll = "LibWETracker_Event_DragonList_RemoveAll",
        createAll = "LibWETracker_Event_DragonList_CreateAll",
    },
    dragonStatus = {
        initDragon = "LibWETracker_Event_DragonStatus_InitDragon",
        checkAll   = "LibWETracker_Event_DragonStatus_CheckAll",
        check      = "LibWETracker_Event_DragonStatus_Check",
    },
    poi       = {
        new          = "LibWETracker_Event_POI_New",
        changeStatus = "LibWETracker_Event_POI_ChangeStatus",
        resetStatus  = "LibWETracker_Event_POI_ResetStatus",
        started      = "LibWETracker_Event_POI_Started",
        ended        = "LibWETracker_Event_POI_Ended",
    },
    poiList   = {
        reset     = "LibWETracker_Event_POIList_Reset",
        add       = "LibWETracker_Event_POIList_Add",
        update    = "LibWETracker_Event_POIList_Update",
        removeAll = "LibWETracker_Event_POIList_RemoveAll",
        createAll = "LibWETracker_Event_POIList_CreateAll",
    },
    poiStatus = {
        initPOI  = "LibWETracker_Event_POIStatus_InitPOI",
        checkAll = "LibWETracker_Event_POIStatus_CheckAll",
        check    = "LibWETracker_Event_POIStatus_Check",
    },
    zone         = {
        updateInfo       = "LibWETracker_Event_Zone_UpdateInfo",
        checkWorldEvents = "LibWETracker_Event_Zone_CheckWorldEvents",
    }
}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function LibWorldEvents.Events.onLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == LibWorldEvents.name then
        LibWorldEvents:Initialise()
    end
end

--[[
-- Called when the user's interface loads and their character is activated after logging in or performing a reload of the UI.
-- This happens after <EVENT_ADD_ON_LOADED>, so the UI and all addons should be initialised already.
--
-- @param integer eventCode
-- @param boolean initial : true if the user just logged on, false with a UI reload (for example)
--]]
function LibWorldEvents.Events.onLoadScreen(eventCode, initial)
    if LibWorldEvents.ready == false then
        return
    end

    LibWorldEvents.Zone:updateInfo()
end

--[[
-- Called when a World Event start (aka dragon pop or dolmen will start).
--
-- @param number eventCode
-- @param number worldEventInstanceId The worldEventID of the dragon or POI.
--]]
function LibWorldEvents.Events.onWEActivate(eventCode, worldEventInstanceId)
    if LibWorldEvents.ready == false then
        return
    end

    -- d(zo_strformat("WE Activate #<<1>>", worldEventInstanceId))

    if LibWorldEvents.Dragons.ZoneInfo.onMap == true then
        local dragon = LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(worldEventInstanceId)

        if dragon == nil then -- dragon not already created
            return
        end

        dragon:poped()
    elseif
        LibWorldEvents.POI.HarrowStorms.onMap == true or
        LibWorldEvents.POI.Geyser.onMap == true or
        LibWorldEvents.POI.Dolmen.onMap == true or
        LibWorldEvents.POI.VolcanicVent.onMap == true or
        LibWorldEvents.POI.Mirrormoor.onMap == true or
        LibWorldEvents.POI.Writhing.onMap == true
    then
        -- d("WEACtivate for poi")

        local _, poiIdx = GetWorldEventPOIInfo(worldEventInstanceId)
        LibWorldEvents.POI.POIList:updateActiveWEIndex(poiIdx)
        local poi = LibWorldEvents.POI.POIList:obtainForPoiIdx(poiIdx)

        if poi == nil then
            -- d("unknown poi from worldEventInstanceID")
            return
        end

        poi:changeStatus(LibWorldEvents.POI.POIStatus.list.started)
    end
end

--[[
-- Called when a World Event is finished (aka dragon killed).
--
-- @param number eventCode
-- @param number worldEventInstanceId The worldEventID of the dragon or POI.
--]]
function LibWorldEvents.Events.onWEDeactivate(eventCode, worldEventInstanceId)
    if LibWorldEvents.ready == false then
        return
    end

    -- d(zo_strformat("WE Deactivate #<<1>>", worldEventInstanceId))

    if LibWorldEvents.Dragons.ZoneInfo.onMap == true then
        local dragon = LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(worldEventInstanceId)

        if dragon == nil then -- dragon not already created
            return
        end

        dragon:changeStatus(LibWorldEvents.Dragons.DragonStatus.list.killed)
    elseif
        LibWorldEvents.POI.HarrowStorms.onMap == true or
        LibWorldEvents.POI.Geyser.onMap == true or
        LibWorldEvents.POI.Dolmen.onMap == true or
        LibWorldEvents.POI.VolcanicVent.onMap == true or
        LibWorldEvents.POI.Mirrormoor.onMap == true or
        LibWorldEvents.POI.Writhing.onMap == true
    then
        local poi = LibWorldEvents.POI.POIList:obtainLastActive()

        if poi == nil then
            return
        end

        poi:changeStatus(LibWorldEvents.POI.POIStatus.list.ended)
    end
end

--[[
-- Called when a World Event has this map pin changed (aka new dragon or dragon in fight).
-- Not used (also maybe called) for POI
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- @param string unitTag The dragon's unitTag
-- @param number oldPinType the old pinType
-- @param number newPinType the new pinType
--]]
function LibWorldEvents.Events.onWEUnitPin(eventCode, worldEventInstanceId, unitTag, oldPinType, newPinType)
    if LibWorldEvents.ready == false then
        return
    end

    -- d(zo_strformat("WE UnitPin #<<1>> - <<2>> - <<3>> - <<4>>", worldEventInstanceId, unitTag, oldPinType, newPinType))

    if LibWorldEvents.Dragons.ZoneInfo.onMap == false then
        return
    end

    local dragon = LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(worldEventInstanceId)
    local status = LibWorldEvents.Dragons.DragonStatus:convertMapPin(newPinType)

    if dragon == nil then -- dragon not already created
        return
    end

    if status == LibWorldEvents.Dragons.DragonStatus.list.waiting and dragon.justPoped == true then
        status = LibWorldEvents.Dragons.DragonStatus.list.flying
    end

    dragon:changeStatus(status, unitTag, newPinType)
end

--[[
-- Called when a World Event change location
-- Dragons only
--
-- @param number eventCode
-- @param number worldEventInstanceId The concerned world event (aka dragon).
-- @param number oldWorldEventLocationId The old dragon's locationId
-- @param number newWorldEventLocationId The new dragon's locationId
--]]
function LibWorldEvents.Events.onWELocChanged(eventCode, worldEventInstanceId, oldWorldEventLocationId, newWorldEventLocationId)
    if LibWorldEvents.ready == false then
        return
    end

    if LibWorldEvents.Dragons.ZoneInfo.onMap == false then
        return
    end

    local dragon       = LibWorldEvents.Dragons.DragonList:obtainForWEInstanceId(worldEventInstanceId)
    local flyingStatus = LibWorldEvents.Dragons.DragonStatus.list.flying

    if dragon == nil then -- dragon not already created
        return
    end

    -- Check because on a pop dragon, we have events onWEActivate, onWEUnitPin and onWELocChanged
    if dragon.status.current ~= flyingStatus then
        dragon:changeStatus(flyingStatus)
    end
end

--[[
-- Called when something change in GUI (like open inventory).
-- Used to some debug, the add to event is commented.
--]]
function LibWorldEvents.Events.onGuiChanged(eventCode)
    if LibWorldEvents.ready == false then
        return
    end
end
