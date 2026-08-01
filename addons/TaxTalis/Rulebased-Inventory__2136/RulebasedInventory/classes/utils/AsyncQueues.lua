-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: AsyncQueue.lua
-- File Description: This class offers different async queues.
-- Load Order Requirements: directly after RulebasedInventory
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local utils = RbI.Import(RbI.utils)

-- @param autoStart: when true queue starts automatically when an entry is pushed
-- @param equalsFn: only the first push arguments will be compared!
-- running: true: indicates that the queue is running and is awaiting then NextCallback
-- pauseFlag: controlled by Run() or Pause(). Can be overrriden with an Push() with autostart=true
-- stopFlag: controlled by Run(true) or Pause(true). Is controlled by the user of the queue. Can not be overrridden by an autostart=true
function utils.NewAbstractAsyncQueue(autoStart, doNextFn, equalsFn, finishFn, startFn, waitForNextFn, packFn, unpackFn)
    local queue = {}
    local first = 0
    local last = -1
    local running = false
    local pauseFlag = false
    local stopFlag = false
    packFn = packFn or function(...) return {...} end
    unpackFn = unpackFn or function(entry) return unpack(entry) end

    local startCallbacks = {}
    local finishCallbacks = {}

    local function OnStart()
        if (startFn) then startFn() end
        local temp = startCallbacks
        startCallbacks = {}
        for _, cb in pairs(temp) do cb() end
    end

    local function OnFinish()
        if(finishFn) then finishFn() end
        if(running or pauseFlag or stopFlag) then return end -- no! it's not the end yet!!
        local temp = finishCallbacks
        finishCallbacks = {}
        for _, cb in pairs(temp) do cb() end
    end

    local function AddFinishCallback(callback)
        table.insert(finishCallbacks, callback)
    end

    local function AddStartCallback(callback)
        table.insert(startCallbacks, callback)
    end

    local function RemoveFinishCallback(callback)
        utils.TableRemoveElement(finishCallbacks, callback)
    end

    local function RemoveStartCallback(callback)
        utils.TableRemoveElement(startCallbacks, callback)
    end

    local Next
    local function NextCallback()
        local packedEntry = queue[first]
        queue[first] = nil
        first = first + 1
        doNextFn(unpackFn(packedEntry))
        if(pauseFlag) then
            running = false
        else
            Next() -- keep running
        end
    end

    Next = function()
        if(first <= last) then
            waitForNextFn(NextCallback, unpackFn(queue[first]))
        else -- empty
            running = false
            OnFinish()
        end
    end

    -- starts the queue, the first entry will only have 1 delay and not the defaultDelay
    local function Run(force)
        if(force) then stopFlag = false end
        pauseFlag = false
        if(running == false and stopFlag == false) then
            running = true
            OnStart()
            Next()
        end
    end

    local function Pause(force)
        pauseFlag = true
        if(force) then stopFlag = true end
    end

    local function Push(...)
        local packedEntry = packFn(...)
        local packedEntryFirst = packedEntry[1]
        if(equalsFn) then
            for i = first, last do
                if(equalsFn(packedEntryFirst, queue[i][1])) then
                    return
                end
            end
        end
        -- only if no equal entry was found
        last = last + 1
        queue[last] = packedEntry
        if(autoStart) then Run() end
    end

    return {
        Run = Run,
        Push = Push,
        Pause = Pause,
        AddFinishCallback = AddFinishCallback,
        AddStartCallback = AddStartCallback,
        RemoveStartCallback = RemoveStartCallback,
        RemoveFinishCallback = RemoveFinishCallback,
        IsRunning = function() return running end,
    }

end

-- @param autoStart: when true queue starts automatically when an entry is pushed
-- For this queue type: Push(entry, optDelayTime)
function utils.NewAsyncQueue(autoStart, defaultDelay, nextFn, equalsFn, finishFn, startFn)

    local function getDelay(optDelayTime)
        if(optDelayTime) then return math.max(1, optDelayTime - GetGameTimeMilliseconds()) end
        return defaultDelay
    end

    return utils.NewAbstractAsyncQueue(autoStart, nextFn, equalsFn, finishFn, startFn,
        function(continueFn, entry, optDelay) -- waitForNextFn
            zo_callLater(continueFn, getDelay(optDelay))
        end
    )
end

local craftingQueueName = RbI.name.."CraftingQueue"
function utils.NewCraftingQueue(autoStart, doNextFn, equalsFn, finishFn, startFn)
    return utils.NewAbstractAsyncQueue(autoStart, doNextFn, equalsFn, finishFn, startFn,
        function(continueFn, entry, metaInfo) -- waitForNextFn
            local eventContinue = function()
                EVENT_MANAGER:UnregisterForEvent(craftingQueueName, EVENT_CRAFT_COMPLETED)
                EVENT_MANAGER:UnregisterForEvent(craftingQueueName, EVENT_CRAFT_FAILED)
                continueFn()
            end
            if(IsPerformingCraftProcess()) then
                EVENT_MANAGER:RegisterForEvent(craftingQueueName, EVENT_CRAFT_COMPLETED, eventContinue)
                EVENT_MANAGER:RegisterForEvent(craftingQueueName, EVENT_CRAFT_FAILED, eventContinue)
            else
                continueFn()
            end
        end
    )

end