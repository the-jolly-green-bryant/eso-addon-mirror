local SWT = SamiWorldTimers
local util = SWT.util

local currentZoneId = nil

local function onUnitDeath(event, uTag, isDead)
    if not isDead then return end
    if not uTag or uTag == "" then return end
    if GetCurrentZoneDungeonDifficulty() ~= 0 then return end
    if not string.find(uTag, "boss") then return end

    local bossName = GetUnitName(uTag)
    if not bossName or bossName == "" then return end
    if util.tableContains(SWT.blacklist, bossName) then return end

    local respawnTime = 300
    if util.getCurrentZoneId() == 1133 then respawnTime = 600 end
    if uTag ~= "boss1" then return end

    if SWT.settings.debug then
        d(string.format("[SamiWorldTimers] UnitDeathCallback: event=%s tag=%s isDead=%s", tostring(event), tostring(uTag), tostring(isDead)))
    end

    SWT.addTimer(bossName, respawnTime)
end

local function updateDeathEventState()
    local inDungeonOrTrial = GetCurrentZoneDungeonDifficulty() ~= 0
    
    if inDungeonOrTrial then
        if SWT.settings.debug then
            d(string.format("Unregistering Death event..."))
        end
        EVENT_MANAGER:UnregisterForEvent(SWT.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED)
        SamiWorldTimersTLC:SetHidden(true)
    else
        if SWT.settings.debug then
            d(string.format("Registering Death event..."))
        end
        EVENT_MANAGER:RegisterForEvent(SWT.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, onUnitDeath)
        SamiWorldTimersTLC:SetHidden(false)
    end
end

local function wipeTimersOnZoneChange(oldZoneId, newZoneId)
    if not SWT.settings.wipeOnZoneChange then return end
    
    if oldZoneId ~= nil and oldZoneId ~= newZoneId then
        -- Clear all timers
        SWT.bossTimes = {}
        SWT.sortedBosses = {}
        SWT.sortedDirty = true
        SWT.ui.setText("")
        EVENT_MANAGER:UnregisterForUpdate(SWT.name .. "Boss Tracker")
        
        if SWT.settings.debug then
            d(string.format("[SamiWorldTimers] Zone changed from %s to %s, timers wiped", tostring(oldZoneId), tostring(newZoneId)))
        end
    end
end

local function onZoneChanged(initial)
    local newZoneId = util.getCurrentZoneId()

    updateDeathEventState()
    wipeTimersOnZoneChange(currentZoneId, newZoneId)
    
    currentZoneId = newZoneId
end

local function onAddOnLoaded(event, addonName)
    if addonName ~= SWT.name then return end
    EVENT_MANAGER:UnregisterForEvent(SWT.name, EVENT_ADD_ON_LOADED)

    SWT.settings = ZO_SavedVars:NewAccountWide(SWT.name .. "Settings", 1, nil, SWT.defaults)
    util.migrateSettings(SWT.settings)

    -- Initialize current zone
    currentZoneId = util.getCurrentZoneId()

    SWT.settingsInit()
    SWT.ui.init()

    updateDeathEventState()
    EVENT_MANAGER:RegisterForEvent(SWT.name .. "ZoneChange", EVENT_PLAYER_ACTIVATED, onZoneChanged)
end

EVENT_MANAGER:RegisterForEvent(SWT.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
