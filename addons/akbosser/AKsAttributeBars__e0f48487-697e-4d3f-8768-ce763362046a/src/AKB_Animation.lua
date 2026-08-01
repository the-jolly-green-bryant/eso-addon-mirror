-- ============================================================================
-- AKsAttributeBars - Animation Module
-- ============================================================================
-- Handles smooth visual transitions for bar width changes with console compatibility

-- Create or get the global addon namespace (console-safe)
AKsAttributeBars = AKsAttributeBars or {}
local AKB = AKsAttributeBars

-- Create Animation namespace
AKB.Animation = AKB.Animation or {}

-- Animation constants
local ANIMATION_DURATION = 200  -- milliseconds for smooth transition
local ANIMATION_FPS = 60       -- target FPS for smooth animation
local FRAME_TIME = 1000 / ANIMATION_FPS  -- time per frame in milliseconds

-- Active animations storage
local activeAnimations = {}
local animationUpdateName = "AKsAttributeBars_BarAnimations"
local isAnimationSystemEnabled = false
local isUpdateRegistered = false  -- Track registration state manually for console compatibility

-- Animation easing function (ease-out for natural feeling)
local function EaseOut(t)
    return 1 - (1 - t) * (1 - t)
end

-- Safe wrapper for EVENT_MANAGER (console compatibility)
local function GetEventManager()
    -- Try different possible event manager references
    return EVENT_MANAGER or (GetEventManager and GetEventManager()) or nil
end

-- Safe wrapper for getting current time (console compatibility)
local function GetCurrentTime()
    local time = 0
    pcall(function()
        -- Try different time functions that might be available
        if GetGameTimeMilliseconds then
            time = GetGameTimeMilliseconds()
        elseif GetTimeStamp then
            time = GetTimeStamp() * 1000  -- Convert seconds to milliseconds
        elseif os and os.time then
            time = os.time() * 1000  -- Convert seconds to milliseconds
        end
    end)
    return time
end

-- Check if animation system can be enabled
local function CheckAnimationSupport()
    if isAnimationSystemEnabled then
        return true
    end
    
    -- Check if we have the required ESO API functions
    local hasSupport = false
    pcall(function()
        local eventManager = GetEventManager()
        local currentTime = GetCurrentTime()
        
        -- Helper function to check if something is callable (console-compatible)
        local function isCallable(val)
            local t = type(val)
            return t == "function" or t == "userdata" or t == "table"
        end
        
        -- Check if we have the required functions for animation
        -- Note: IsRegisteredForUpdate might not exist on all platforms, so we make it optional
        if eventManager and 
           currentTime > 0 and
           isCallable(eventManager.RegisterForUpdate) and
           isCallable(eventManager.UnregisterForUpdate) then
            
            hasSupport = true
        end
    end)
    
    isAnimationSystemEnabled = hasSupport
    return hasSupport
end

-- Check if bars should be hidden due to UI state (menus/maps open)
local function ShouldBarsBeHidden()
    -- Check if any major UI is open
    if AKB.Events and AKB.Events.IsAnyMenuOpen then
        local status, menuOpen = pcall(AKB.Events.IsAnyMenuOpen)
        if status and menuOpen then
            return true
        end
    end
    return false
end

-- Start a smooth bar width animation
function AKB.Animation.AnimateBarWidth(barControl, targetWidth, targetHeight, onComplete)
    if not barControl or not barControl.SetDimensions then
        return
    end
    
    -- Check if bars should be hidden due to UI state (menus/maps open)
    if ShouldBarsBeHidden() then
        -- Don't animate or show bars when UI state requires them to be hidden
        return
    end
    
    -- If targetHeight not provided, get current height
    if not targetHeight then
        pcall(function()
            targetHeight = barControl:GetHeight() or 20
        end)
        targetHeight = targetHeight or 20
    end
    
    -- Check if animation system is supported
    if not CheckAnimationSupport() then
        -- Fallback to instant update if animation system not available
        pcall(function()
            barControl:SetDimensions(targetWidth, targetHeight)
        end)
        if onComplete then
            pcall(onComplete)
        end
        return
    end
    
    -- Get current width safely
    local currentWidth = 0
    pcall(function()
        currentWidth = barControl:GetWidth() or 0
    end)
    
    -- If target is very close to current, do instant update (no need to animate tiny changes)
    if math.abs(targetWidth - currentWidth) < 2 then
        pcall(function()
            barControl:SetDimensions(targetWidth, targetHeight)
        end)
        if onComplete then
            pcall(onComplete)
        end
        return
    end
    
    -- Cancel any existing animation for this control
    local controlId = tostring(barControl)
    if activeAnimations[controlId] then
        activeAnimations[controlId] = nil
    end
    
    -- Create new animation data
    local animationData = {
        control = barControl,
        startWidth = currentWidth,
        targetWidth = targetWidth,
        targetHeight = targetHeight,
        startTime = GetCurrentTime(),
        duration = ANIMATION_DURATION,
        onComplete = onComplete
    }
    
    -- Store animation
    activeAnimations[controlId] = animationData
    
    -- Ensure animation update is running
    AKB.Animation.StartAnimationUpdate()
end

-- Start the animation update loop
function AKB.Animation.StartAnimationUpdate()
    if not CheckAnimationSupport() then
        return
    end
    
    -- Safely check and start animation update
    pcall(function()
        local eventManager = GetEventManager()
        if eventManager and next(activeAnimations) and not isUpdateRegistered then
            eventManager:RegisterForUpdate(animationUpdateName, FRAME_TIME, AKB.Animation.UpdateAnimations)
            isUpdateRegistered = true
        end
    end)
end

-- Stop the animation update loop
function AKB.Animation.StopAnimationUpdate()
    if not CheckAnimationSupport() then
        return
    end
    
    -- Safely stop animation update
    pcall(function()
        local eventManager = GetEventManager()
        if eventManager and isUpdateRegistered then
            eventManager:UnregisterForUpdate(animationUpdateName)
            isUpdateRegistered = false
        end
    end)
end

-- Update all active animations
function AKB.Animation.UpdateAnimations()
    if not CheckAnimationSupport() then
        activeAnimations = {}
        return
    end
    
    -- Check if bars should be hidden due to UI state
    if ShouldBarsBeHidden() then
        -- Clear all animations and stop updating when UI state requires bars to be hidden
        activeAnimations = {}
        AKB.Animation.StopAnimationUpdate()
        return
    end
    
    local currentTime = GetCurrentTime()
    local hasActiveAnimations = false
    
    for controlId, animData in pairs(activeAnimations) do
        if animData.control and animData.control.SetDimensions then
            local elapsed = currentTime - animData.startTime
            local progress = math.min(elapsed / animData.duration, 1.0)
            
            -- Apply easing
            local easedProgress = EaseOut(progress)
            
            -- Calculate current width
            local widthDiff = animData.targetWidth - animData.startWidth
            local currentWidth = animData.startWidth + (widthDiff * easedProgress)
            
            -- Update the control safely with pcall
            local updateSuccess = pcall(function()
                animData.control:SetDimensions(currentWidth, animData.targetHeight)
            end)
            
            -- Check if animation is complete
            if progress >= 1.0 then
                -- Ensure exact target width with pcall
                pcall(function()
                    animData.control:SetDimensions(animData.targetWidth, animData.targetHeight)
                end)
                
                -- Call completion callback if provided
                if animData.onComplete then
                    pcall(animData.onComplete)
                end
                
                -- Remove completed animation
                activeAnimations[controlId] = nil
            elseif updateSuccess then
                hasActiveAnimations = true
            else
                -- Remove failed animation
                activeAnimations[controlId] = nil
            end
        else
            -- Remove invalid animation
            activeAnimations[controlId] = nil
        end
    end
    
    -- Stop update loop if no more animations
    if not hasActiveAnimations then
        AKB.Animation.StopAnimationUpdate()
    end
end

-- Clear all animations (useful for cleanup)
function AKB.Animation.ClearAllAnimations()
    activeAnimations = {}
    AKB.Animation.StopAnimationUpdate()
end

-- Cancel animation for specific control
function AKB.Animation.CancelAnimation(barControl)
    if barControl then
        local controlId = tostring(barControl)
        activeAnimations[controlId] = nil
        
        -- Stop update if no more animations
        if not next(activeAnimations) then
            AKB.Animation.StopAnimationUpdate()
        end
    end
end

-- Utility function to animate bar with immediate data update but smooth visual transition
function AKB.Animation.UpdateBarWithAnimation(barControl, currentValue, maxValue, fullBarWidth, barHeight)
    if not barControl or not barControl.SetDimensions then
        return
    end
    
    -- Check if bars should be hidden due to UI state (menus/maps open)
    if ShouldBarsBeHidden() then
        -- Don't animate or show bars when UI state requires them to be hidden
        return
    end
    
    -- Calculate target width immediately (data is always up-to-date)
    local percentage = 0
    if maxValue > 0 then
        percentage = currentValue / maxValue
    end
    
    local targetWidth = math.max(1, fullBarWidth * percentage)
    
    -- Animate to target width for smooth visual transition
    AKB.Animation.AnimateBarWidth(barControl, targetWidth, barHeight)
end

-- Initialize animation system
function AKB.Animation.Initialize()
    -- Clear any existing animations on initialization
    AKB.Animation.ClearAllAnimations()
    
    -- Try to enable animation system
    CheckAnimationSupport()
end

-- Cleanup animation system
function AKB.Animation.Cleanup()
    AKB.Animation.ClearAllAnimations()
    isAnimationSystemEnabled = false
    isUpdateRegistered = false
end
