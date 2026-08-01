--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: module.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local defaults = {
    active = false,
    hasUpdate = true,
    debug = false,

    title = 'UNTITLED_MODULE',
    hint = GetString(SI_AWEMOD_SHOW_HINT),

    spacing = 0,
    fontSize = 1,
    order = 40
}

local Module = {}

function Module:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Module:d(...)
    if (self.debug) then
        AE.logging.d(self.id, ...)
    end
end

function Module.Colorize(color, text)
    if (AE.colorDefs[color] ~= nil) then
        return AE.colorDefs[color]:Colorize(text)
    else
        return text
    end
end

function Module.GetColorStr(color)
    if (AE.colorDefs[color] ~= nil) then
        return '|c' .. AE.colorDefs[color]:ToHex()
    else
        return '|r'
    end
end

function Module:GetEventListeners()
    return {}
end

function Module:Enable(options)
    self:d('Enable (in debug-mode)')
    for i, _data in pairs(self.labels) do
        self.labels[i]:SetText('')
    end
    self.hasUpdate = true
end

function Module:Disable()
    self:d('Disable')
    for i, _data in pairs(self.labels) do
        self.labels[i]:SetText('')
    end
end

function Module:Set(key, value)
    self:d('Set[' .. key .. ']', value)
    self.hasUpdate = true
end

function Module:Update(options)
    self:d('Update')
end

function Module:StartTimer(seconds, updateIfFaster)
    if (AE.timer[self.id] == nil) then
        self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
        return
    end
    if (seconds == nil or seconds < 1) then
        seconds = 1
    end
    local timestamp = GetTimeStamp() + seconds
    if (AE.timer[self.id] == 0) then
        self:d('StartTimer[' .. seconds .. ']')
        AE.timer[self.id] = timestamp
    elseif (updateIfFaster == true and AE.timer[self.id] > timestamp) then
        self:d('StartTimer[' .. seconds .. '] (faster)')
        AE.timer[self.id] = timestamp
    else
        self:d('StartTimer[ignored]')
    end
end

function Module:SetTimer(seconds)
    if (AE.timer[self.id] == nil) then
        self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
        return
    end
    if (seconds == nil or seconds < 1) then
        seconds = 1
    end
    self:d('SetTimer[' .. seconds .. ']')
    AE.timer[self.id] = GetTimeStamp() + seconds
end

function Module:StopTimer()
    if (AE.timer[self.id] == nil) then
        self:d(GetString(SI_AWEVS_DEBUG_MODULE_NO_TIMER))
        return
    end
    self:d('StopTimer')
    AE.timer[self.id] = 0
end

AE.module_factory = function(o)
    if (o.id == nil or AE.core.modules[o.id] ~= nil) then
        AE.logging.d('module', 'Factory failed for', o)
        return
    end

    -- copy default values
    for key, value in pairs(defaults) do
        o[key] = o[key] or value
    end

    -- create new table instances for each and every module
    o.labels = o.labels or {[1]={}}
    o.options = o.options or {}

    AE.core.modules[o.id] = Module:new(o)
    return AE.core.modules[o.id]
end