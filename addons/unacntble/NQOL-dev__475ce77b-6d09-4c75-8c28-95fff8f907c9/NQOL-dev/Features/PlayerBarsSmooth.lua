NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local PlayerBars = NQOL.Features.PlayerBars
PlayerBars.Smooth = PlayerBars.Smooth or {}

local Smooth = PlayerBars.Smooth
local C = PlayerBars.Constants
local ANIMATION_MS = 250
local FADE_MS = 500
local UPDATE_MS = 16
local UPDATE_NAME = C.EVENT_NAMESPACE .. "_SmoothBars"

local animations = {}
local activeCount = 0
local registered = false

local function GetNow()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    return 0
end

local function Lerp(startValue, endValue, progress)
    return startValue + (endValue - startValue) * progress
end

local function IsUpdating(animation)
    return animation and (animation.active == true or animation.lossActive == true)
end

local function GetOwnerAnimations(owner, create)
    local ownerAnimations = animations[owner]
    if not ownerAnimations and create then
        ownerAnimations = {}
        animations[owner] = ownerAnimations
    end
    return ownerAnimations
end

local function StopUpdates()
    if registered and activeCount <= 0 and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        registered = false
    end
end

local function OnUpdate()
    local now = GetNow()
    for _, ownerAnimations in pairs(animations) do
        for _, animation in pairs(ownerAnimations) do
            local wasUpdating = IsUpdating(animation)
            if animation.active then
                local progress = (now - animation.startTime) / ANIMATION_MS
                if progress >= 1 then
                    animation.displayValue = animation.targetValue
                    animation.active = false
                else
                    if progress < 0 then
                        progress = 0
                    end
                    animation.displayValue = Lerp(animation.startValue, animation.targetValue, progress)
                end
            end

            if animation.lossActive then
                local fadeProgress = (now - animation.lossStartTime) / FADE_MS
                if fadeProgress >= 1 then
                    animation.lossActive = false
                    animation.lossValue = nil
                    animation.lossAlpha = 0
                else
                    if fadeProgress < 0 then
                        fadeProgress = 0
                    end
                    animation.lossAlpha = 0.32 * (1 - fadeProgress)
                end
            end

            if wasUpdating then
                if animation.onUpdate then
                    animation.onUpdate()
                end
                if not IsUpdating(animation) then
                    activeCount = activeCount - 1
                end
            end
        end
    end

    StopUpdates()
end

local function StartUpdates()
    if not registered and activeCount > 0 and EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_MS, OnUpdate)
        registered = true
    end
end

function Smooth.GetValue(owner, key, targetValue, onUpdate, rangeMaximum, trackLoss)
    targetValue = tonumber(targetValue) or 0
    local ownerAnimations = GetOwnerAnimations(owner, true)
    local animation = ownerAnimations[key]

    if animation and rangeMaximum ~= nil and animation.rangeMaximum ~= rangeMaximum then
        -- ESO can publish the maximum and its matching current value in either
        -- order. Preserve the previous percentage for a maximum-only event;
        -- if both values changed together, snap directly to the supplied value.
        local synchronizedValue = targetValue
        local previousMaximum = tonumber(animation.rangeMaximum) or 0
        local previousTarget = tonumber(animation.targetValue) or 0
        if previousMaximum > 0 and rangeMaximum > 0 and targetValue == previousTarget then
            synchronizedValue = previousTarget * rangeMaximum / previousMaximum
            synchronizedValue = math.max(0, math.min(synchronizedValue, rangeMaximum))
        end
        Smooth.Reset(owner, key)
        ownerAnimations = GetOwnerAnimations(owner, true)
        ownerAnimations[key] = {
            displayValue = synchronizedValue,
            targetValue = synchronizedValue,
            onUpdate = onUpdate,
            rangeMaximum = rangeMaximum,
        }
        return synchronizedValue
    end

    if not animation then
        ownerAnimations[key] = {
            displayValue = targetValue,
            targetValue = targetValue,
            onUpdate = onUpdate,
            rangeMaximum = rangeMaximum,
        }
        return targetValue
    end

    animation.onUpdate = onUpdate
    animation.rangeMaximum = rangeMaximum
    if animation.targetValue ~= targetValue then
        local wasUpdating = IsUpdating(animation)
        if targetValue < animation.targetValue and trackLoss ~= false then
            animation.lossValue = math.max(animation.targetValue, animation.displayValue or 0)
            animation.lossAlpha = 0.32
            animation.lossStartTime = GetNow()
            animation.lossActive = true
        end
        animation.startValue = animation.displayValue
        animation.targetValue = targetValue
        animation.startTime = GetNow()
        animation.active = true
        if not wasUpdating then
            activeCount = activeCount + 1
        end
        StartUpdates()
    end

    return animation.displayValue
end

function Smooth.GetLoss(owner, key)
    local ownerAnimations = GetOwnerAnimations(owner, false)
    local animation = ownerAnimations and ownerAnimations[key]
    if animation and animation.lossActive then
        return animation.lossValue or 0, animation.lossAlpha or 0
    end

    return 0, 0
end

function Smooth.Reset(owner, key)
    local ownerAnimations = GetOwnerAnimations(owner, false)
    local animation = ownerAnimations and ownerAnimations[key]
    if IsUpdating(animation) then
        activeCount = activeCount - 1
    end
    if ownerAnimations then
        ownerAnimations[key] = nil
        if next(ownerAnimations) == nil then
            animations[owner] = nil
        end
    end
    StopUpdates()
end

function Smooth.ResetAll()
    for owner in pairs(animations) do
        animations[owner] = nil
    end
    activeCount = 0
    StopUpdates()
end
