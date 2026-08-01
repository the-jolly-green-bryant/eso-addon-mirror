--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: logging.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local logging = {
    enabled = true,
    slashCmd = "zmdebug"
}

local _handler = nil
local _buffer = {}
local _window = nil

local function __boolToStr(value)
    if (value) then
        return 'true'
    else
        return 'false'
    end
end

local function __tostring(object, level)
    local lvlPrefix = ''
    if (level ~= nil) then
        lvlPrefix = string.rep('--', level)
    end
    local str = ''
    if (type(object) == 'table') then
        if (level == nil) then
            for i in ipairs(object) do
                if (i == 1) then
                    str = str .. __tostring(object[i], 1)
                else
                    str = str .. '> ' .. __tostring(object[i], 1)
                end
            end
        else
            str = 'Table\n'
            for key, value in pairs(object) do
                str = str .. lvlPrefix .. '> .' .. key .. ' = ' .. __tostring(value, level + 1)
            end
        end
    elseif (type(object) == 'number') then
        str = tostring(object)
    elseif (type(object) == 'boolean') then
        str = __boolToStr(object)
    elseif (type(object) == 'string') then
        str = object
    else
        str = type(object)
    end
    return str .. '\n'
end

logging.d = function(...)
    if (not logging.enabled) then
        return
    end
    local args = { ... }

    local str = ''
    if (args[1] ~= nil and type(args[1]) == "string") then
        args[1] = '|cD4CD82[|c82D482' .. args[1] .. '|cD4CD82]|cFFFFFF '
        if (type(args[2]) == "string") then
            args[1] = args[1] .. ' ' .. args[2]
            table.remove(args, 2)
        end
        if (#args == 1) then
            str = args[1]
        end
    end
    if (str == '') then
        str = __tostring(args)
    end
    if (_handler == nil) then
        table.insert(_buffer, str)
    else
        _handler(str)
    end
end

-- Create Debug _window
logging.show = function()
    if (LibMsgWin == nil) then
        d("[AwesomeEvents] LibMsgWin-1.0 not found, cannot show debug window")
        return
    end

    if (_window == nil) then
        _window = LibMsgWin:CreateMsgWindow("AwesomeEventsDebug_window", "Awesome Events Debug Log", 0, 0)
        _window:SetWidth(600)
        _window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)
        if (logging.enabled) then
            for i, value in ipairs(_buffer) do
                _window:AddText(value)
            end
            _buffer = {}
        end
        _handler = function(value)
            _window:AddText(value)
        end
    else
        _window:SetHidden(false)
    end

    if (not logging.enabled) then
        _window:AddText('Debug-Log: ' .. GetString(SI_AWEVS_DEBUG_DISABLED))
        _window:AddText('Usage: /' .. logging.slashCmd .. ' mod_id (on\off)')
    end
end -- show

logging.hide = function()
    if (_window ~= nil) then
        _window:SetHidden(true)
    end
end -- hide

logging.clear = function()
    _buffer = {}

    if (_window) then
        _window:SetHidden(true)
        _window:ClearText()
    end
end

local function OnModulesChanged()
    -- logging
    local enabled = false
    for mod_id, mod in pairs(AE.core.modules) do
        if (mod.debug) then
            enabled = true
        end
    end
    logging.enabled = enabled
    if (enabled) then
        logging.show()
    else
        logging.hide()
        logging.clear()
    end
end

CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_CORE, OnModulesChanged)

AE.logging = logging