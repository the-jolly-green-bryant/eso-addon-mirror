local CE = CustomEmotes
local internal = CE.internal

-- Variables to track events
internal.event = {}
internal.event.lastX = 0
internal.event.lastY = 0
internal.event.lastZ = 0
internal.event.isTracking = false

-- Addon loaded event
function internal.addonLoadEvent(event, name)
    if(name == CE.name) then
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_ADD_ON_LOADED)
        internal.initializeAddon()
        internal.initializeUtils()
        internal.initializeUI()
        internal.registerCommands()
    end
end

-- Any event that stops an emote
function internal.stopEmoteEvent(e)
    internal.cancelCurrentEmote()
end

-- Update for checking player movement
function internal.checkPlayerMovementUpdate()
    local x, y, z = GetUnitWorldPosition("player")
    if (x ~= internal.event.lastX or y ~= internal.event.lastY or z ~= internal.event.lastZ) then
        internal.cancelCurrentEmote()
    end
end

-- Cancel the current emote
function internal.cancelCurrentEmote()
    internal.interpreter.stopEmote()
end

-- Schedule an action
function internal.scheduleAction(delayMs, actionIndex)
    EVENT_MANAGER:RegisterForUpdate(CE.name .. "ExecuteEmoteActions", delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(CE.name .. "ExecuteEmoteActions")
        internal.interpreter.playActions(actionIndex)
    end)
end

-- Stop a scheduled action
function internal.stopSheduledAction()
    EVENT_MANAGER:UnregisterForUpdate(actionName)
end

-- Turn on and off the emote event
function internal.listenForEmote(state)

    -- Avoid executing double
    if internal.event.isTracking == state then
        return
    end

    -- Set the state
    internal.event.isTracking = state

    if state then

        -- Save the current position
        local x, y, z = GetUnitWorldPosition("player")
        internal.event.lastX = x
        internal.event.lastY = y
        internal.event.lastZ = z

        -- Registers the events to track movements
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_MOUNTED_STATE_CHANGED, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_COMBAT_STATE, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_MAIL_OPEN_MAILBOX, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_DEAD, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_SWIMMING, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_PLAYER_ACTIVATED, internal.stopEmoteEvent)
        EVENT_MANAGER:RegisterForUpdate(CE.name .. "CheckPlayerMovement", 100, internal.checkPlayerMovementUpdate)

    else

        -- Unregister the events
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_MOUNTED_STATE_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_MAIL_OPEN_MAILBOX)
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_PLAYER_DEAD)
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_PLAYER_SWIMMING)
        EVENT_MANAGER:UnregisterForEvent(CE.name, EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForUpdate(CE.name .. "CheckPlayerMovement")

    end

end

EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_ADD_ON_LOADED, internal.addonLoadEvent)