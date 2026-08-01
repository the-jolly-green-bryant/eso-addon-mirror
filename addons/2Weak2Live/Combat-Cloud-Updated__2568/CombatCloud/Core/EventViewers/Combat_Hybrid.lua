CombatCloud_CombatHybridEventViewer = CombatCloud_EventViewer:Subclass()

local random, sqrt, min, max = math.random, math.sqrt, math.min, math.max
local format, tostring = string.format, tostring
local callLater = zo_callLater
local C = CombatCloudConstants
local poolTypes = C.poolType

function CombatCloud_CombatHybridEventViewer:New(...)
    local obj = CombatCloud_EventViewer:New(...)
    obj:RegisterCallback(C.eventType.COMBAT, function(...) self:OnEvent(...) end)
    self.eventBuffer = {}
    self.activeControls = { [C.combatType.OUTGOING] = {}, [C.combatType.INCOMING] = {} }
    self.lastControl = {}
    return obj
end

function CombatCloud_CombatHybridEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (CombatCloudSettings.animation.animationType ~= 'hybrid') then return end

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

function CombatCloud_CombatHybridEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if not self.eventBuffer[eventKey] then return end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
end

function CombatCloud_CombatHybridEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical, hits)
	local S = CombatCloudSettings

    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)
	
    local textFormat, fontSize, textColor = self:GetTextAtributes(powerType, damageType, isDamage, isHealing, isEnergize, isDrain, isDot, isHot, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, isCritical)
    if (hits > 1 and S.toggles.showThrottleTrailer) then value = format('%d (%d)', value, hits) end
	
    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType)

    -- Control setup
    local panel, point, relativePoint = CombatCloud_Outgoing, TOP, BOTTOM
    if (combatType == C.combatType.INCOMING) then
        panel = CombatCloud_Incoming
        if (S.animation.incoming.directionType == 'down') then
            point, relativePoint = BOTTOM, TOP
        end
    else
        if (S.animation.outgoing.directionType == 'down') then
            point, relativePoint = BOTTOM, TOP
        end
    end

    local w, h = panel:GetDimensions()
    local radiusW, radiusH = w / 2, h / 2
    local offsetX, offsetY = 0, 0
	
    if (isCritical and (isDamage or isHealing)) then offsetX = random(-radiusW, radiusW)
    elseif (isDot or isHot) then offsetX = random(-radiusW, radiusW)
    elseif (isDamage or isHealing or isEnergize or isDrain or isDamageShield or isBlocked) then offsetX = random(-radiusW, radiusW) end
	
    if (point == TOP) then
        if (self.lastControl[combatType] == nil) then offsetY = -25 else offsetY = max(-25, select(6, self.lastControl[combatType]:GetAnchor(0))) end
        control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)

        if (offsetY < 75 and self:IsOverlapping(control, self.activeControls[combatType])) then
            control:ClearAnchors()
            offsetY = select(6, self.lastControl[combatType]:GetAnchor(0)) + fontSize
            control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)
        end
    else
        if (self.lastControl[combatType] == nil) then offsetY = 25 else offsetY = min(25, select(6, self.lastControl[combatType]:GetAnchor(0))) end
        control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)

        if (offsetY > -75 and self:IsOverlapping(control, self.activeControls[combatType])) then
            control:ClearAnchors()
            offsetY = select(6, self.lastControl[combatType]:GetAnchor(0)) - fontSize
            control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)
        end
    end

    self.activeControls[combatType][control:GetName()] = control
    self.lastControl[combatType] = control
	
	-- Animation setup
    local animationPoolType = poolTypes.ANIMATION_SCROLL
    if (isCritical and (isDamage or isHealing)) then animationPoolType = poolTypes.ANIMATION_SCROLL_CRITICAL end

    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)

    local targetY = h + 50
    if (point == TOP) then targetY = -targetY end
    animation:GetStepByName('scroll'):SetDeltaOffsetY(targetY)

    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after use
    callLater(function()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeControls[combatType][control:GetName()] = nil
        if (self.lastControl[combatType] == control) then self.lastControl[combatType] = nil end
    end, animation:GetDuration())
end