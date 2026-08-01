local RPR = RewardPopupsReworked
RPR.Utils = {}

local U = RPR.Utils
local Unpack = unpack or table.unpack

function U.GetGlobal(path)
    if type(path) ~= "string" or path == "" then return nil end

    local current = _G
    for part in string.gmatch(path, "[^%.]+") do
        if type(current) ~= "table" and type(current) ~= "userdata" then
            return nil
        end
        current = current[part]
        if current == nil then return nil end
    end

    return current
end

local function AppendArgs(target, args)
    if not args then return end
    for i = 1, #args do
        table.insert(target, args[i])
    end
end

function U.Invoke(call, ...)
    if not call then return false end

    local fn
    local object
    local fixedArgs

    if type(call) == "function" then
        fn = call
    elseif type(call) == "string" then
        fn = U.GetGlobal(call)
    elseif type(call) == "table" then
        fixedArgs = call.args
        if call.object and call.method then
            object = U.GetGlobal(call.object)
            fn = object and object[call.method]
        elseif call.func then
            fn = U.GetGlobal(call.func)
        end
    end

    if type(fn) ~= "function" then return false end

    local args = {}
    AppendArgs(args, fixedArgs)
    for i = 1, select("#", ...) do
        table.insert(args, select(i, ...))
    end

    if object then
        return pcall(fn, object, Unpack(args))
    end

    return pcall(fn, Unpack(args))
end

function U.CallFirst(calls, ...)
    if not calls then return false end

    for _, call in ipairs(calls) do
        local ok, a, b, c, d = U.Invoke(call, ...)
        if ok and a ~= false then
            return true, a, b, c, d
        end
    end

    return false
end

function U.ClickFirstControl(controlNames)
    if not controlNames then return false end

    for _, controlName in ipairs(controlNames) do
        local control = type(controlName) == "string" and U.GetGlobal(controlName) or controlName
        if control then
            local enabled = true
            if control.IsEnabled then
                local ok, result = pcall(control.IsEnabled, control)
                enabled = ok and result ~= false
            end

            if enabled then
                local handler
                if control.GetHandler then
                    local ok, result = pcall(control.GetHandler, control, "OnClicked")
                    if ok then handler = result end
                end

                if type(handler) == "function" then
                    local ok, result = pcall(handler, control, MOUSE_BUTTON_INDEX_LEFT or 1, false)
                    if ok and result ~= false then return true end
                elseif type(control.OnClicked) == "function" then
                    local ok, result = pcall(control.OnClicked, control, MOUSE_BUTTON_INDEX_LEFT or 1, false)
                    if ok and result ~= false then return true end
                end
            end
        end
    end

    return false
end

function U.FirstNumber(calls)
    if not calls then return nil end

    for _, call in ipairs(calls) do
        local ok, a, b, c, d = U.Invoke(call)
        if ok then
            local values = { a, b, c, d }
            for i = 1, #values do
                local value = tonumber(values[i])
                if value then return value end
            end
            if a == true then return 1 end
        end
    end

    return nil
end

function U.FirstBoolean(calls)
    if not calls then return nil end

    for _, call in ipairs(calls) do
        local ok, value = U.Invoke(call)
        if ok and type(value) == "boolean" then
            return value
        end
    end

    return nil
end

function U.ShowFirstScene(sceneNames)
    if not sceneNames or not SCENE_MANAGER then return false end

    for _, sceneName in ipairs(sceneNames) do
        local scene
        if SCENE_MANAGER.GetScene then
            local ok, result = pcall(SCENE_MANAGER.GetScene, SCENE_MANAGER, sceneName)
            if ok then scene = result end
        end

        if scene and SCENE_MANAGER.Show then
            local ok = pcall(SCENE_MANAGER.Show, SCENE_MANAGER, sceneName)
            if ok then return true end
        end
    end

    return false
end

function U.RegisterForExistingEvents(namespace, eventNames, callback)
    if not EVENT_MANAGER then return end
    if type(namespace) ~= "string" or namespace == "" then return end
    if type(eventNames) ~= "table" then return end
    if type(callback) ~= "function" then return end

    for _, eventName in ipairs(eventNames) do
        local eventId = type(eventName) == "string" and _G[eventName] or eventName

        if eventId then
            local registrationName =
                namespace .. "_" .. tostring(eventName)

            EVENT_MANAGER:UnregisterForEvent(
                registrationName,
                eventId
            )

            EVENT_MANAGER:RegisterForEvent(
                registrationName,
                eventId,
                callback
            )
        end
    end
end

function U.TableContains(list, value)
    if not list then return false end

    for _, item in ipairs(list) do
        if item == value then return true end
    end

    return false
end
