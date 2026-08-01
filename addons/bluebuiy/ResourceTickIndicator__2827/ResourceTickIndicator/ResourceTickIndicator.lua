



-- GetTimeStamp
-- GetPlayerStat
-- DerivedStats:
--    STAT_STAMINA_REGEN_COMBAT
--    STAT_STAMINA_REGEN_IDLE
--    STAT_MAGICKA_REGEN_COMBAT
--    STAT_MAGICKA_REGEN_IDLE
--    STAT_HEALTH_REGEN_COMBAT
--    STAT_HEALTH_REGEN_IDLE
--  STAT_BONUS_OPTION_APPLY_BONUS

RTIaddon = {}

RTIaddon.name = "ResourceTickIndicator"

-- the resource restore tick has a period of ~ 2.01 seconds. 
RTIaddon.RESOURCE_RESTORE_PERIOD = 2000

-- last known resource restore tick
RTIaddon.last_known_passive_regen = 0
RTIaddon.latency_at_last = 0
-- assume you don't start logged in in combat
RTIaddon.in_combat = false
RTIaddon.start_time = 0
-- the animation timeline applied to the tick indicator
RTIaddon.bar_timeline = nil
-- the animation
RTIaddon.bar_animation = nil
-- the callback
RTIaddon.bar_callback = nil

function GetStaminaStat(inCombat)
    if inCombat then
        return STAT_STAMINA_REGEN_COMBAT
    else
        return STAT_STAMINA_REGEN_IDLE
    end
end

function GetMagickaStat(inCombat)
    if inCombat then
        return STAT_MAGICKA_REGEN_COMBAT
    else
        return STAT_MAGICKA_REGEN_IDLE
    end
end

function GetMountStat(inCombat)
    if inCombat then
        return STAT_MOUNT_STAMINA_REGEN_COMBAT
    else
        return STAT_MOUNT_STAMINA_REGEN_MOVING
    end
end

-- health is probably too unreliable to even bother
--function GetHealthStat(inCombat)
--    if inCombat then
--        return STAT_HEALTH_REGEN_COMBAT
--    else
--        return STAT_HEALTH_REGEN_IDLE
--    end
--end

function RTIaddon:OnAddOnLoaded(addonName)
    if addonName == RTIaddon.name then
        RTIaddon:Initialize()
    end
end

function myabs(a)
    if a < 0 then 
        return -a
    else
        return a
    end
end

function SetBarAnimDurationAndPlay(dur)

    CreateBarAnimation(dur)

    -- bug with setting callback offset, keeps getting pushed back
    --RTIaddon.bar_animation:SetDuration(dur)
    --RTIaddon.bar_timeline:SetCallbackOffset(RTIaddon.bar_callback, 0)
    
    RTIaddon.bar_timeline:PlayFromStart()
end

function BarAnimCallback()
   if RTIaddon.bar_timeline:GetFullProgress() > 0.9 then
        -- restart the animation accounting for how much time we need
        local now = GetGameTimeMilliseconds()
        --local nextRegenTick = now + (RTIaddon.RESOURCE_RESTORE_PERIOD - ((now - RTIaddon.last_known_passive_regen) % RTIaddon.RESOURCE_RESTORE_PERIOD))
        --local rem = nextRegenTick - now -- RTIaddon.RESOURCE_RESTORE_PERIOD - (passedTime % RTIaddon.RESOURCE_RESTORE_PERIOD)
        local dur = (RTIaddon.RESOURCE_RESTORE_PERIOD - ((now - RTIaddon.last_known_passive_regen) % RTIaddon.RESOURCE_RESTORE_PERIOD))
        --d("Duration: " .. (now - RTIaddon.last_known_passive_regen) % 2000)
        SetBarAnimDurationAndPlay(dur)
   end
end

function CreateBarAnimation(dur)

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType(0, 1)
    -- callback so we can restart the animation if we need to
    RTIaddon.bar_callback = timeline:InsertCallback(BarAnimCallback, dur + 200)
    local anim = timeline:InsertAnimation(ANIMATION_SIZE, ResourceTickBarStatusBar, 0)
    anim:SetDuration(dur)
    anim:SetEasingFunction(ZO_LinearEase)
    
    anim:SetStartWidth(1)
    anim:SetEndWidth(288)
    anim:SetStartHeight(38)
    anim:SetEndHeight(38)
    RTIaddon.bar_timeline = timeline
    RTIaddon.bar_animation = anim

end


function RTIaddon.PlayerResourceChange(event, unit, power, type, powerValue, powerMax, powerEffectiveMax)
    --d("call")

    local powerChange = 0
    local powerRegen = 0

    if type == POWERTYPE_STAMINA then
        powerChange = powerValue - RTIaddon.current_stamina
        RTIaddon.current_stamina = powerValue
        powerRegen = GetPlayerStat(GetStaminaStat(RTIaddon.in_combat))
    elseif type == POWERTYPE_MAGICKA then 
        powerChange = powerValue - RTIaddon.current_magicka
        RTIaddon.current_magicka = powerValue
        powerRegen = GetPlayerStat(GetMagickaStat(RTIaddon.in_combat))
    elseif type == POWERTYPE_MOUNT_STAMINA then
        powerChange = powerValue - RTIaddon.current_mount_stamina
        RTIaddon.current_mount_stamina = powerValue
        powerRegen = GetPlayerStat(GetMountStat(RTIaddon.in_combat))
    end

    local now = GetGameTimeMilliseconds()
    local latency = GetLatency()
    local offset = 0
    local envelope = 100
    if RTIaddon.last_known_passive_regen ~= 0 then
        offset = RTIaddon.RESOURCE_RESTORE_PERIOD - (now - RTIaddon.last_known_passive_regen)
        -- account for latency differences between the two sample points.  Assume the one-way trip time is half rtt.
        -- then make it a bit bigger.
        envelope = RTIaddon.latency_at_last / 2 - latency / 2 + 10
    end


    if powerRegen > 0 and myabs(powerChange - powerRegen) < 10 and offset < envelope then
        RTIaddon.last_known_passive_regen = now
        RTIaddon.latency_at_last = latency
        --d("Passive regen detected at " .. (now - RTIaddon.start_time) / 1000)
        -- releasing the usage needs to happen early on the client.  Apparently the server doesn't do latency correction.
        SetBarAnimDurationAndPlay(RTIaddon.RESOURCE_RESTORE_PERIOD - latency / 2)
    end

end

function RTIaddon.CombatStateChange(event, state)
    RTIaddon.in_combat = state
end

function RTIaddon.TickBarMoved()
    RTIaddon.saved_variables.left = ResourceTickBar:GetLeft()
    RTIaddon.saved_variables.top = ResourceTickBar:GetTop()
end

function RTIaddon:Initialize()
    local currentStam, maxStam, effMaxStam = GetUnitPower("player", POWERTYPE_STAMINA)
    self.current_stamina = currentStam

    local currentMag, maxMag, effMaxMag = GetUnitPower("player", POWERTYPE_STAMINA)
    self.current_magicka = currentMag
    
    local currentMountStam, maxMountStam, effMaxMountStam = GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)
    self.current_mount_stamina = currentMountStam

    self.start_time = GetGameTimeMilliseconds()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_POWER_UPDATE, self.PlayerResourceChange)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.CombatStateChange)

    --CreateBarAnimation()

    self.saved_variables = ZO_SavedVars:New("ResourceTickBarPosition", 1, nil, {})
    ResourceTickBar:ClearAnchors()
    ResourceTickBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saved_variables.left, self.saved_variables.top)

    local fragment = ZO_SimpleSceneFragment:New(ResourceTickBar)

    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)

end

EVENT_MANAGER:RegisterForEvent(RTIaddon.name, EVENT_ADD_ON_LOADED, RTIaddon.OnAddOnLoaded)
