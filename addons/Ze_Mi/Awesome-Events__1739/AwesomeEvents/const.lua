--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: const.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = {
    name = 'AwesomeEvents',
    panelName = 'AwesomeEventsOptions',
    title = 'Awesome Events',
    version = '1.7 build-22',

    vars = nil,
    timer = {},
    initialized = false
}

AE.const = {
    CALLBACK_VARS_DEFAULTS = "AwesomeEventsPopulateDefaults",
    CALLBACK_VARS = "AwesomeEventsVarsLoaded",
    CALLBACK_UI_PRE = "AwesomeEventsUIConfig",
    CALLBACK_CORE = "AwesomeEventsCoreLoaded",

    COLOR_AVAILABLE = 1,
    COLOR_HINT = 2,
    COLOR_WARNING = 3,

    EVENT_TIMER = 1,
    ORDER_AWESOME_MODULE_PUSH_NOTIFICATION = 75,
}

--- top-level non-const to avoid circular dependency
AE.colorDefs = {
    [AE.const.COLOR_AVAILABLE] = nil,
    [AE.const.COLOR_HINT] = nil,
    [AE.const.COLOR_WARNING] = nil
}

--- return a spacingPosition property as localized string
AE.GetSpacingPositionString = function(spacingPosition)
    if (spacingPosition == TEXT_ALIGN_TOP) then
        return GetString(SI_AWEMOD_SPACING_BOTTOM)
    end
    if (spacingPosition == TEXT_ALIGN_BOTTOM) then
        return GetString(SI_AWEMOD_SPACING_TOP)
    end
    if (spacingPosition == TEXT_ALIGN_CENTER) then
        return GetString(SI_AWEMOD_SPACING_BOTH)
    end
    return nil
end -- AE.GetSpacingPositionString

--- get spacingPosition property from localized string
AE.GetSpacingPosition = function(newSpacingPosition)
    -- translate value to key
    if (newSpacingPosition == GetString(SI_AWEMOD_SPACING_BOTTOM)) then
        return TEXT_ALIGN_TOP
    elseif (newSpacingPosition == GetString(SI_AWEMOD_SPACING_TOP)) then
        return TEXT_ALIGN_BOTTOM
    elseif (newSpacingPosition == GetString(SI_AWEMOD_SPACING_BOTH)) then
        return TEXT_ALIGN_CENTER
    end
end -- AE:GetSpacingPosition

--- return a textAlign property as localized string
AE.GetTextAlignString = function(textAlign)
    if (textAlign == TEXT_ALIGN_LEFT) then
        return GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT)
    end
    if (textAlign == TEXT_ALIGN_CENTER) then
        return GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER)
    end
    if (textAlign == TEXT_ALIGN_RIGHT) then
        return GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT)
    end
end -- AE.GetTextAlignString

--- get textAlign property from localized string
AE.GetTextAlign = function(textAlign)
    -- translate value to key
    if (textAlign == GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT)) then
        return TEXT_ALIGN_LEFT
    elseif (textAlign == GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT)) then
        return TEXT_ALIGN_RIGHT
    elseif (textAlign == GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER)) then
        return TEXT_ALIGN_CENTER
    end
end

--- make sure the color codes have only two decimals
AE.GetColor = function(rValue, gValue, bValue)
    rValue = math.floor(rValue * 100) / 100
    gValue = math.floor(gValue * 100) / 100
    bValue = math.floor(bValue * 100) / 100
    return { r = rValue, g = gValue, b = bValue }
end

--- set colors from RGB values
AE.setColorDef = function(type, r, g, b)
    if (AE.colorDefs[type] == nil) then
        AE.colorDefs[type] = ZO_ColorDef:New(r, g, b)
    else
        AE.colorDefs[type]:SetRGB(r, g, b)
    end
end

Awesome_Events = AE