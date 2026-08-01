AIRI = AIRI or {}
local AIRI = AIRI

AIRI.name = "AddedInfoRaidInfo"
AIRI.version = "1.2.2"

local deaths = 0

local function RefreshDisplay(self)
    self.reviveCounter:SetText(zo_strformat(AIRI_DEATHS, self.count, GetCurrentRaidStartingReviveCounters(), deaths))
end

local function UpdateTime()
    AIRI.raidInfoControl.time:SetText(ZO_FormatTimeMilliseconds(GetRaidDuration(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
    if GetRaidDuration() > GetRaidTargetTime() then
        AIRI.raidInfoControl.time:SetColor(1, 0, 0, 1)
    else
        AIRI.raidInfoControl.time:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()) 
    end
    RefreshDisplay(AIRI.raidInfoControl)
end

local function Reset()
    deaths = 0
    AIRI.raidInfoControl.timeLabel:SetText(GetString(AIRI_TIME))
    AIRI.raidInfoControl.time:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()) 
end

local function OnTrialStart()
    Reset()
    EVENT_MANAGER:RegisterForUpdate(AIRI.name .. "Tick", 1000, UpdateTime)
end

local function OnTrialEnd()
    AIRI.raidInfoControl.timeLabel:SetText(GetString(AIRI_FINAL_TIME))
    EVENT_MANAGER:UnregisterForUpdate(AIRI.name .. "Tick")
end

local function OnPlayerActivated()
    if GetRaidDuration() > 0 then
        EVENT_MANAGER:RegisterForUpdate(AIRI.name .. "Tick", 1000, UpdateTime)
    end
    if HasRaidEnded() then
        AIRI.raidInfoControl.timeLabel:SetText(GetString(AIRI_FINAL_TIME))
        AIRI.raidInfoControl.scoreLabel:SetText(GetString(SI_REVIVE_COUNTER_FINAL_SCORE))
    end
    
    deaths = deaths or (deaths > 0 and deaths or GetCurrentRaidDeaths())
end

local function OnPlayerDeath(_, unitTag, isDead)
    if string.find(unitTag, "group") and isDead then
        deaths = deaths + 1
    end
end

-- Initializes
local function Initialize()
    -- Reference to the info control
    AIRI.raidInfoControl = HUD_RAID_LIFE.displayObject
    
    -- Time control
    local time = WINDOW_MANAGER:CreateControl(AIRI.raidInfoControl.control:GetName() .. "Time", AIRI.raidInfoControl.control, CT_LABEL)
    time:SetAnchor(RIGHT, AIRI.raidInfoControl.scoreLabel, LEFT, -20, -2)
    time:SetFont("ZoFontWinH2")
    time:SetText("00:00")
    AIRI.raidInfoControl.time = time
    
    -- Time Label
    local timeLabel = WINDOW_MANAGER:CreateControl(AIRI.raidInfoControl.control:GetName() .. "TimeLabel", AIRI.raidInfoControl.control, CT_LABEL)
    timeLabel:SetAnchor(RIGHT, AIRI.raidInfoControl.time, LEFT, -5, 2)
    timeLabel:SetFont("ZoFontGameLargeBold")
    timeLabel:SetText(GetString(AIRI_TIME))
    timeLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    AIRI.raidInfoControl.timeLabel = timeLabel
    
    -- Hooking the update function to display total amount of deaths (even beyond the raid limit)
    ZO_PostHook(AIRI.raidInfoControl, "RefreshDisplay", RefreshDisplay)
    
    -- Move the info panel above the compass
    --HUD_RAID_LIFE.control:ClearAnchors()
    --HUD_RAID_LIFE.control:SetAnchor(BOTTOM, ZO_CompassFrame, TOP, 160, -5)
    
    EVENT_MANAGER:RegisterForEvent(AIRI.name, EVENT_RAID_TRIAL_STARTED, OnTrialStart)
    EVENT_MANAGER:RegisterForEvent(AIRI.name, EVENT_RAID_TRIAL_COMPLETE, OnTrialEnd)
    EVENT_MANAGER:RegisterForEvent(AIRI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(AIRI.name, EVENT_UNIT_DEATH_STATE_CHANGED, OnPlayerDeath)
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIRI.name then return end
    EVENT_MANAGER:UnregisterForEvent(AIRI.name, EVENT_ADD_ON_LOADED)

    Initialize()
end

EVENT_MANAGER:RegisterForEvent(AIRI.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)