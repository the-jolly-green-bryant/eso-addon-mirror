-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Interface.lua
-- -----------------------------------------------------------------------------

SFC.UI = {}

local WM = WINDOW_MANAGER
local AM = ANIMATION_MANAGER

-- -----------------------------------------------------------------------------
-- UI Elements
-- -----------------------------------------------------------------------------

SFC.UI.Contexts = {
    animation = SFC_BuffDurationAnimationProgress,
    frame = SFC_BuffDurationAnimationProgressFrame,
    count = SFC_BuffDurationAnimationProgressCount,
}

local buffDisplay = SFC_BuffDurationAnimation
local buffDisplayLabel = SFC.UI.Contexts.count
local buffDuration = SFC.UI.Contexts.animation

local buffDurationAnimationIn = AM:CreateTimelineFromVirtual("SFC_BuffDurationIn", buffDuration)
local buffDurationAnimationOut = AM:CreateTimelineFromVirtual("SFC_BuffDurationOut", buffDuration)

local NO_LEADING_EDGE = false
local BUFF_DURATION_MS


-- -----------------------------------------------------------------------------
-- UI Functions
-- -----------------------------------------------------------------------------

local function LoadColorPrefs()
    for element, _ in pairs(SFC.UI.Contexts) do
        SFC.UI.UpdateColor(element, SFC.preferences[element])
    end
end

local function LoadShowFrame()
    SFC.UI.Contexts["frame"]:SetHidden(not SFC.preferences.showFrame)
end

local function LoadLockedState()
    SFC.UI.Contexts["animation"]:SetMovable(SFC.preferences.unlocked)
end

local function LoadPosition()
    local left = SFC.preferences.positionLeft
    local top = SFC.preferences.positionTop
    local context = SFC.UI.Contexts["animation"]

    SFC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)

    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition()
    local container = SFC.UI.Contexts.animation
    local top   = container:GetTop()
    local left  = container:GetLeft()

    SFC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    SFC.preferences.positionLeft = left
    SFC.preferences.positionTop  = top
end


function SFC.UI.Setup()
    -- Load duration
    BUFF_DURATION_MS = SFC.Tracking.GetAbilityDuration()

    -- Set UI preferences
    LoadColorPrefs()
    LoadShowFrame()
    LoadLockedState()
    LoadPosition()

    local fragment = ZO_SimpleSceneFragment:New(buffDisplay)
    HUD_UI_SCENE:AddFragment(fragment)
    HUD_SCENE:AddFragment(fragment)
    LOOT_SCENE:AddFragment(fragment)

    SFC:Trace(2, "Finished UI Setup")
end

function SFC.UI.UpdateColor(element, color)

    SFC:Trace(2, "<<1>>: R <<2>> G <<3>> B <<4>> A <<5>>", element, color.r, color.g, color.b, color.a)

    if element == "animation" then
        SFC.UI.Contexts[element]:SetFillColor(color.r, color.g, color.b, color.a)
    else
        SFC.UI.Contexts[element]:SetColor(color.r, color.g, color.b, color.a)
    end

end

function SFC.UI.OnMoveStop()
    SFC:Trace(1, "Moved")
    SavePosition()
end

function SFC.UI.UpdateStacks(stackCount, isActive)

    buffDisplayLabel:SetText(stackCount)

    -- From 0 to 1 stacks, play fade in animation
    if stackCount == 1 and isActive then
        -- Stop fade out animation first
        buffDurationAnimationOut:Stop()
        buffDurationAnimationIn:PlayFromStart(0)
        buffDuration:StartCooldown(BUFF_DURATION_MS, BUFF_DURATION_MS, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)

    -- Don't play fade in animation if we have more than one stack
    -- We assume we already did fade in
    elseif stackCount > 1 and isActive then
        buffDuration:StartCooldown(BUFF_DURATION_MS, BUFF_DURATION_MS, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, NO_LEADING_EDGE)

    -- Play fade out animation when returning to 0 stacks
    else
        buffDurationAnimationOut:PlayFromStart(0)

    end
end

function SFC.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(SFC.prefix .. "Setting debug level to 0 (Off)")
        SFC.debugMode = 0
        SFC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(SFC.prefix .. "Setting debug level to 1 (Low)")
        SFC.debugMode = 1
        SFC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(SFC.prefix .. "Setting debug level to 2 (Medium)")
        SFC.debugMode = 2
        SFC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(SFC.prefix .. "Setting debug level to 3 (High)")
        SFC.debugMode = 3
        SFC.preferences.debugMode = 3

    -- Default ----------------------------------------------------------------
    else
        d(SFC.prefix .. "Command not recognized!")
    end
end

