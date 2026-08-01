CombatCloud_CombatCloudEventViewer = CombatCloud_EventViewer:Subclass()

local random, sqrt, format, tostring = math.random, math.sqrt, string.format, tostring
local callLater = zo_callLater
local C = CombatCloudConstants
local poolTypes = C.poolType

function CombatCloud_CombatCloudEventViewer:New(...)
    local obj = CombatCloud_EventViewer:New(...)
    obj:RegisterCallback(C.eventType.COMBAT, function(...) self:OnEvent(...) end)
    self.eventBuffer = {}
    return obj
end

function CombatCloud_CombatCloudEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (CombatCloudSettings.animation.animationType ~= 'cloud') then return end

    local T = CombatCloudSettings.throttles

    if (isCritical and (isDamage or isHealing)) and (not CombatCloudSettings.toggles.throttleCriticals) then
        self:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, 1)
    else
        local eventKey = format('%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', combatType, powerType, abilityName, abilityId, damageType, tostring(isDamage), tostring(isHealing), tostring(isEnergize), tostring(isDrain), tostring(isDot), tostring(isHot), tostring(isMiss), tostring(isImmune), tostring(isParried), tostring(isReflected), tostring(isDamageShield), tostring(isDodged), tostring(isBlocked), tostring(isInterrupted), tostring(isCritical))
        if (self.eventBuffer[eventKey] == nil) then
            self.eventBuffer[eventKey] = { value = value, hits = 1 }
            local throttleTime = 0
            if (isDamage) then throttleTime = T.damage
            elseif (isDot) then throttleTime = T.dot
            elseif (isHealing) then throttleTime = T.healing
            elseif (isHot) then throttleTime = T.hot end
            callLater(function() self:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical) end, throttleTime)
        else
            self.eventBuffer[eventKey].value = self.eventBuffer[eventKey].value + value
            self.eventBuffer[eventKey].hits = self.eventBuffer[eventKey].hits + 1
        end
    end
end

function CombatCloud_CombatCloudEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if not self.eventBuffer[eventKey] then return end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
end

function CombatCloud_CombatCloudEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
    local S = CombatCloudSettings

    -- Control setup
    local panel = CombatCloud_Outgoing
    if (combatType == C.combatType.INCOMING) then panel = CombatCloud_Incoming end
    local w, h = panel:GetDimensions()
    local radiusW, radiusH = w/2, h/2
    local offsetX, offsetY = nil, nil

    if (isCritical and (isDamage or isHealing)) then
        offsetX, offsetY = random(-radiusW * .5, radiusW * .5), random(-radiusH * .5, radiusH * .5)
    elseif (isDot or isHot) then -- http://www.mathopenref.com/coordgeneralellipse.html
        offsetX = random(-radiusW * .95, radiusW * .95) -- Make radiusW a bit smaller to avoid horizontal animations
        offsetY = sqrt((radiusH) ^ 2 * (1 - (offsetX ^ 2 / (radiusW) ^ 2)))
        if (combatType == C.combatType.OUTGOING) then offsetY = -offsetY end
    elseif (isDamage or isHealing or isEnergize or isDrain or isDamageShield or isBlocked) then
        offsetX, offsetY = random(-radiusW, radiusW), random(-radiusH * .5, radiusH)
    end

    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    if (isDot or isHot) then
        control:SetAnchor(CENTER, panel, CENTER, 0, 0) -- Offsets are set in animation, not here
    else
        control:SetAnchor(CENTER, panel, CENTER, offsetX, offsetY)
    end

    -- Label setup in the correct order that the game handles damage
    local textFormat, fontSize, textColor = self:GetTextAtributes(powerType, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (hits > 1 and S.toggles.showThrottleTrailer) then value = format('%d (%d)', value, hits) end
    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType)

    -- Animation setup
    local animationPoolType = poolTypes.ANIMATION_CLOUD
    if (isCritical and (isDamage or isHealing)) then animationPoolType = poolTypes.ANIMATION_CLOUD_CRITICAL
    elseif (isDot or isHot) then animationPoolType = poolTypes.ANIMATION_CLOUD_FIREWORKS end
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)

    if (animationPoolType == poolTypes.ANIMATION_CLOUD_FIREWORKS) then
        local moveStep = animation:GetStepByName('move')
        moveStep:SetDeltaOffsetX(offsetX)
        moveStep:SetDeltaOffsetY(offsetY)
    end

    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after use
    callLater(function()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
    end, animation:GetDuration())
end