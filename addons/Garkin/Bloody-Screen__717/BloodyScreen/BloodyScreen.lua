-------------------------------------------------------------------------------
-- Bloody Screen v0.3
-------------------------------------------------------------------------------
--
-- Copyright (c) 2015 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------
--
-- Textures are downloaded from here:
-- http://www.cutestockfootage.com/index.php?kw_list=&search=Blood+Splatter
--
-------------------------------------------------------------------------------

local ADDON_NAME = "BloodyScreen"
local TLW
local rand = math.random
local splatterKeys = {}
local SV

local defaults = {
    FADEOUT_DELAY = 0,          --milliseconds
    FADEOUT_DURATION = 3000,    --milliseconds
    MIN_SIZE = 250,             --minimal splatter size
    MAX_SIZE = 600,             --maximal splatter size
    MIN_ALPHA = 35,             --minimal splatter transparency (percent)
    MAX_ALPHA = 75,             --minimal splatter transparency (percent)
    HEALTH_PERCENT = 75,        --(percent) first splatter is shown when character is below this value
    HEALTH_STEP = 5,            --(percent) splatters are shown/hidden when there is this much change in health
}

local textures = {
    "BloodyScreen/Textures/splatter13.dds",
    "BloodyScreen/Textures/splatter14.dds",
    "BloodyScreen/Textures/splatter15.dds",
    "BloodyScreen/Textures/splatter16.dds",
    "BloodyScreen/Textures/splatter17.dds",
    "BloodyScreen/Textures/splatter25.dds",
    "BloodyScreen/Textures/splatter26.dds",
    "BloodyScreen/Textures/splatter27.dds",
    "BloodyScreen/Textures/splatter28.dds",
    "BloodyScreen/Textures/splatter30.dds",
    "BloodyScreen/Textures/splatter31.dds",
    "BloodyScreen/Textures/splatter33.dds",
    "BloodyScreen/Textures/splatter34.dds",
    "BloodyScreen/Textures/splatter35.dds",
    "BloodyScreen/Textures/splatter36.dds",
    "BloodyScreen/Textures/splatter37.dds",
    "BloodyScreen/Textures/splatter38.dds",
    "BloodyScreen/Textures/splatter39.dds",
    "BloodyScreen/Textures/splatter40.dds",
}

local function BuildSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Bloody Screen",
        displayName = ZO_HIGHLIGHT_TEXT:Colorize("Bloody Screen"),
        author = "Garkin",
        version = "0.3",
        slashCommand = "/bloodyscreen",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "slider",
            name = "Fade Out Delay (ms)",
            tooltip = "Splatter fade out delay in milliseconds. Default value is |cFFFFFF0|rms.",
            min = 0,
            max = 3000,
            step = 250,
            getFunc = function() return SV.FADEOUT_DELAY end,
            setFunc = function(value) SV.FADEOUT_DELAY = value end,
            default = defaults.FADEOUT_DELAY,
        },
        {
            type = "slider",
            name = "Fade Out Duration (ms)",
            tooltip = "Splatter fade out duration in milliseconds. Default value is |cFFFFFF3000|rms.",
            min = 1000,
            max = 5000,
            step = 250,
            getFunc = function() return SV.FADEOUT_DURATION end,
            setFunc = function(value) SV.FADEOUT_DURATION = value end,
            default = defaults.FADEOUT_DURATION,
        },
        {
            type = "slider",
            name = "Minimal Splatter Size (px)",
            tooltip = "Minimal splatter size in UI pixels. Default value is |cFFFFFF250|r pixels.",
            min = 50,
            max = GuiRoot:GetHeight(),
            step = 10,
            getFunc = function() return SV.MIN_SIZE end,
            setFunc = function(value) SV.MIN_SIZE = zo_min(value, SV.MAX_SIZE) end,
            default = defaults.MIN_SIZE,
        },
        {
            type = "slider",
            name = "Maximal Splatter Size (px)",
            tooltip = "Maximal splatter size in UI pixels. Default value is |cFFFFFF600|r pixels.",
            min = 50,
            max = GuiRoot:GetHeight(),
            step = 10,
            getFunc = function() return SV.MAX_SIZE end,
            setFunc = function(value) SV.MAX_SIZE = zo_max(value, SV.MIN_SIZE) end,
            default = defaults.MAX_SIZE,
        },
        {
            type = "slider",
            name = "Minimal Splatter Opacity (%)",
            tooltip = "Minimal splatter opacity in percents. Default value is |cFFFFFF35%|r.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SV.MIN_ALPHA end,
            setFunc = function(value) SV.MIN_ALPHA = zo_min(value, SV.MAX_ALPHA) end,
            default = defaults.MIN_ALPHA,
        },
        {
            type = "slider",
            name = "Maximal Splatter Opacity (%)",
            tooltip = "Maximal splatter opacity in percents. Default value is |cFFFFFF75%|r.",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SV.MAX_ALPHA end,
            setFunc = function(value) SV.MAX_ALPHA = zo_max(value, SV.MIN_ALPHA) end,
            default = defaults.MAX_ALPHA,
        },
        {
            type = "slider",
            name = "Health Threshold (%)",
            tooltip = "First splatter is displayed when character's health is below this threshold. Default value is |cFFFFFF75%|r.",
            min = 35,
            max = 100,
            step = 1,
            getFunc = function() return SV.HEALTH_PERCENT end,
            setFunc = function(value) SV.HEALTH_PERCENT = value end,
            default = defaults.HEALTH_PERCENT,
        },
        {
            type = "slider",
            name = "Health Value Change (%)",
            tooltip = "Splatters are shown/hidden when there is this much change in character's health. Default value is |cFFFFFF5%|r.",
            min = 1,
            max = 20,
            step = 1,
            getFunc = function() return SV.HEALTH_STEP end,
            setFunc = function(value) SV.HEALTH_STEP = value end,
            default = defaults.HEALTH_STEP,
        },
    }

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM:RegisterAddonPanel('BloodyScreen_Panel', panelData)
    LAM:RegisterOptionControls('BloodyScreen_Panel', optionsData)
end

local function SplatterFactory(pool)
    local control = WINDOW_MANAGER:CreateControl(nil, TLW, CT_TEXTURE)
    return ZO_AlphaAnimation:New(control)  
end   

local function SplatterReset(object)
    object:FadeOut(SV.FADEOUT_DELAY, SV.FADEOUT_DURATION, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, ZO_ObjectPool_DefaultResetControl, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_SHOWN)
end

local SplatterPool = ZO_ObjectPool:New(SplatterFactory, SplatterReset)

local function SetSplatter(splatter)
    local texture = textures[rand(#textures)]
    local size = rand(SV.MIN_SIZE, SV.MAX_SIZE)
    local alpha = rand(SV.MIN_ALPHA, SV.MAX_ALPHA) / 100
    local x = rand(GuiRoot:GetWidth() - size) 
    local y = rand(GuiRoot:GetHeight() - size) 
   
    local control = splatter:GetControl()
    control:SetTexture(texture)
    control:SetDimensions(size, size)
    control:SetAnchor(TOPLEFT, TLW, TOPLEFT, x, y)
    control:SetAlpha(alpha)
    control:SetHidden(false)
end

local function HideSplatters()
    SplatterPool:ReleaseAllObjects()
end

local function DisplaySplatters(healthPercent)
    local numSplatters = 0
    if healthPercent * 100 < SV.HEALTH_PERCENT then
        numSplatters = zo_roundToNearest(SV.HEALTH_PERCENT - (healthPercent * 100), SV.HEALTH_STEP) / SV.HEALTH_STEP
    end

    local activeSplatters = SplatterPool:GetActiveObjectCount()
   
    if numSplatters == 0 then
        HideSplatters()
    elseif numSplatters > activeSplatters then
        for i = 1, numSplatters - activeSplatters do
            local splatter, key = SplatterPool:AcquireObject()
            table.insert(splatterKeys, key)
            SetSplatter(splatter)
        end
    elseif numSplatters < activeSplatters then
        for i = 1, activeSplatters - numSplatters do
            local keyIndex = rand(#splatterKeys)
            SplatterPool:ReleaseObject(splatterKeys[keyIndex])
            table.remove(splatterKeys, keyIndex)
        end
    end
end

local function UpdateSplatters()
    local powerValue, powerMax = GetUnitPower("player", POWERTYPE_HEALTH)

    local healthPercent = 0
    if powerValue and powerMax > 0 then
        healthPercent = powerValue / powerMax
    end

    DisplaySplatters(healthPercent)
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax)
    if powerType == POWERTYPE_HEALTH and unitTag == "player" then
        if IsUnitDead("player") then
            HideSplatters()
            return
        end

        local healthPercent = 0
        if powerValue and powerMax > 0 then
            healthPercent = powerValue / powerMax
        end

        DisplaySplatters(healthPercent)
    end
end

local function OnLoaded(eventCode, addonName)
    if addonName == ADDON_NAME then 
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

        TLW = WINDOW_MANAGER:CreateTopLevelWindow()
        TLW:SetAnchorFill(GuiRoot)
        TLW:SetDrawLayer(DL_OVERLAY)
        TLW:SetMouseEnabled(false)

        SV = ZO_SavedVars:NewAccountWide("BloodyScreen_SavedVariables", 1, "settings", defaults)

        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD, HideSplatters)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ALIVE, UpdateSplatters)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_POWER_UPDATE, OnPowerUpdate)

        BuildSettingsMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
