--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: AwesomeEvents.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local _lastUpdate = 0
local _events = {}

local function OnEvent(...)
    local args = { ... }
    local eventCode = args[1] or 'unknown'
    if (_events[eventCode] ~= nil) then
        for mod_id, callback in pairs(_events[eventCode]) do
            -- AE.logging.d('main','OnEvent['..mod_id..']: '..eventCode)
            callback(unpack(args))
        end
    else
        AE.logging.d('main', 'OnEvent: ' .. eventCode .. ' - ' .. GetString(SI_AWEVS_DEBUG_NO_EVENT_CALLBACKS), _events)
        EVENT_MANAGER:UnregisterForEvent(AE.name, eventCode)
    end
end -- OnEvent

local function OnModulesChanged()
    AE.logging.d('main', 'UpdateEventListeners')

    -- remove old listeners
    for eventCode, event in pairs(_events) do
        if (event.code ~= AE.const.EVENT_TIMER) then
            EVENT_MANAGER:UnregisterForEvent(AE.name, eventCode)
        end
    end

    AE.timer = {}
    _events = {
        [AE.const.EVENT_TIMER] = {}
    }

    -- foreach module
    for mod_id, mod in pairs(AE.core.modules) do
        if (mod.active) then
            local events = mod:GetEventListeners()
            for i, event in pairs(events) do
                if (event.eventCode ~= nil and event.callback ~= nil) then

                    if (_events[event.eventCode] == nil) then
                        _events[event.eventCode] = {}
                        if (event.code ~= AE.const.EVENT_TIMER) then
                            EVENT_MANAGER:RegisterForEvent(AE.name, event.eventCode, function(...)
                                OnEvent(unpack({ ... }))
                            end)
                        end
                    end

                    if (event.eventCode == AE.const.EVENT_TIMER) then
                        AE.timer[mod_id] = 1
                    end
                    _events[event.eventCode][mod.id] = event.callback
                else
                    AE.logging.d('main', 'UpdateEventListeners[' .. mod_id .. ']', GetString(SI_AWEVS_DEBUG_MODULE_EVENT_INVALID), event)
                end
            end
        end
    end
end -- UpdateEventListeners

--- Initialize modules, config menu, views and user configuration
local function initialize()
    if (AE.initialized) then
        return
    end

    -- register MODULE events
    CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_CORE, OnModulesChanged)

    -- load module- and user configuration
    AE.load()

    -- register UI events
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", AE.ui.onSceneStateChanged)

    AE.initialized = true

    AE.ui.show()
end -- AE.Initialize

-- main update: firering timer, call mod update functions, update the viewsize
local function update(timestamp)
    -- trigger EVENT_TIMER
    if (_events[AE.const.EVENT_TIMER] ~= nil) then
        local secondsToNextMinute = 60 - timestamp % 60
        if (secondsToNextMinute < 10) then
            secondsToNextMinute = secondsToNextMinute + 60
        end
        for mod_id, callback in pairs(_events[AE.const.EVENT_TIMER]) do
            if (AE.timer[mod_id] > 0 and AE.timer[mod_id] <= timestamp) then
                AE.logging.d('main', 'OnTimer[' .. mod_id .. ']')
                local seconds = callback(AE.const.EVENT_TIMER, timestamp)
                -- no return value => execute every minute
                if (type(seconds) ~= 'number') then
                    seconds = secondsToNextMinute
                else
                    AE.logging.d('main', 'NextCustomTimer[' .. mod_id .. '] in ' .. tostring(seconds) .. ' seconds')
                end
                -- timer still enabled ?
                if (AE.timer[mod_id] > 0) then
                    if (seconds < 1) then
                        AE.logging.d('main', 'StopTimer[' .. mod_id .. ']')
                        AE.timer[mod_id] = 0
                    else
                        AE.timer[mod_id] = timestamp + seconds
                    end
                end
            end
        end
    end
    local resizeView = false
    -- update each module
    for mod_id, mod in pairs(AE.core.modules) do
        if (mod.active and mod.hasUpdate) then
            mod.hasUpdate = false
            mod:Update(AE.vars[mod.id])
            resizeView = true
        end
    end
    if (resizeView) then
        AE.ui.UpdateViewSize();
    end
end -- update

local function OnPlayerActivated(event, initial)
    -- Only initialize the addon (after all addons are loaded)
    EVENT_MANAGER:UnregisterForEvent(AE.name, EVENT_PLAYER_ACTIVATED)
    initialize()
end -- OnPlayerActivated

AE.OnUpdate = function(timestamp)
    -- Bail if we haven't completed the initialisation routine yet.
    if (not AE.initialized or AE.ui.dragging) then
        return
    end
    -- Only run this update if a full second has elapsed since last time we did so.
    --local timestamp = GetTimeStamp()
    if (timestamp > _lastUpdate) then
        _lastUpdate = timestamp
        update(GetTimeStamp())
    end
end -- AE.OnUpdate

--------------------
-- SLASH COMMANDS --
--------------------

-- Typing /aedump as a command will activate this function. Primarily used for testing.
local function __SlashAEDebug(command)
    local args = {}
    for word in command:gmatch("%w+") do
        table.insert(args, word)
    end

    local task = args[1] or 'unknown';

    if (task == 'show') then
        return AE.logging.show()
    end
    if (task == 'hide') then
        return AE.logging.hide()
    end

    local mod_id = task
    local value = args[2] or nil

    if (mod_id ~= nil and AE.core.modules[mod_id] ~= nil) then
        local mod = AE.core.modules[mod_id]
        if (value ~= nil) then
            if (value == 'on' or value == 'On' or value == 'ON' or value == 'oN') then
                mod.debug = true
            else
                mod.debug = false
            end

            CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_CORE)
        end
        local enabled = GetString(SI_AWEVS_DEBUG_DISABLED)
        if (mod.debug) then
            enabled = GetString(SI_AWEVS_DEBUG_ENABLED)
        end
        d('[AwesomeEvents] Debug [' .. mod_id .. ']: ' .. enabled)
        AE.logging.d('Debug-Log: ' .. enabled)
    else
        d('[AwesomeEvents] Debug [' .. mod_id .. ']: ' .. GetString(SI_AWEVS_DEBUG_MODULE_NOT_FOUND), 'Usage: /aedebug mod_id (on||off)')
    end
end -- __SlashAEDebug

AE.logging.slashCmd = 'aedebug'
SLASH_COMMANDS['/aedebug'] = __SlashAEDebug

EVENT_MANAGER:RegisterForEvent(AE.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)