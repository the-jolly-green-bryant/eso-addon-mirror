--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: vars.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local defaults = {
    isDefault = true,
    showDisabledText = true,
    window = {
        left = GuiRoot:GetWidth() / 2,
        top = 100,
        backgroundAlpha = 0.0,
        movable = true,
        scaling = 1.0,
        textAlign = TEXT_ALIGN_CENTER,
        textColor = {
            [AE.const.COLOR_AVAILABLE] = { r = 0.5, g = 0.83, b = 0.5 },
            [AE.const.COLOR_HINT] = { r = 0.83, g = 0.8, b = 0.5 },
            [AE.const.COLOR_WARNING] = { r = 0.83, g = 0.59, b = 0.5 },
        }
    },
}

local function __postLoad()
    -- restore derived vars
    for key, color in pairs(AE.vars.window.textColor) do
        AE.setColorDef(key, color.r, color.g, color.b)
    end

    -- lazy allow callback after load
    CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_VARS)
end

AE.load = function()
    -- allow modules to inject their defaults
    CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_VARS_DEFAULTS, defaults)

    AE.vars = ZO_SavedVars:New("AwesomeEvents", 1, nil, defaults)
    AE.vars.isDefault = false

    __postLoad()
end

local function __recursive_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[__recursive_copy(orig_key)] = __recursive_copy(orig_value)
        end
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end -- __recursive_copy

AE.importConfigFromCharacter = function(characterName)
    AE.logging.d('main', 'ImportConfigFromCharacter', characterName)
    if (characterName == nil or characterName == GetString(SI_AWEVS_IMPORT_CHARACTER_SELECT)) then
        return
    end

    local characterId
    if (characterName ~= GetUnitName('player')) then
        for i = 1, GetNumCharacters() do
            local name, _, _, _, _, _, id = GetCharacterInfo(i)
            if (characterName == zo_strformat("<<1>>", name)) then
                characterId = id
            end
        end
    end

    if (characterId ~= nil) then
        local tempVars = ZO_SavedVars:New('AwesomeEvents', 1, nil, defaults, "Default", GetDisplayName(), characterName, characterId, ZO_SAVED_VARS_CHARACTER_NAME_KEY)
        if (tempVars.isDefault) then
            d("[AwesomeEvents] Your character" .. characterName .. " does not have any settings for this addon.")
        else
            for key in pairs(defaults) do
                AE.vars[key] = __recursive_copy(tempVars[key])
            end
            AE.logging.d('main', 'Imported successfully!')

            __postLoad()
            return true
        end
    end
    return false
end -- importConfigFromCharacter