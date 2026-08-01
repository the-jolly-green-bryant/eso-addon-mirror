--[[
    Traveller by Patrick Smyth
 
    A FIFO/LIFO Queueing System which has no dependencies on Traveller.

--]]
Queue = { }

-- Queue template
local l_EmptyQueue = {
        fifo = true,
        lowEntry = -1,
        highEntry = 0,
        list = { }
        }

-- Counts the current number of queue entries
local function l_CountEntries(aQueue)
    local count = (aQueue.highEntry - aQueue.lowEntry) - 1
    return count
end

--
-- Create a fifo/lifo queue
-- You can have as many as you want - just keep each of the contexts returned by create() separate
-- Parameters
--      fifo - boolean value, true produces FIFO queue, false produces LIFO queue
-- Returns
--      Context to give to all the other routines in this module
--
function Queue:Create(fifo)
    newQueue = { }

    ZO_DeepTableCopy(l_EmptyQueue, newQueue)
    newQueue.fifo = fifo

    return newQueue
end

--
-- Add data to the queue
-- Parameters
--      aQueue - the context returned from a call to create()
--      entry - the data to be stored
--
function Queue:Push(aQueue, entry)

    if aQueue.fifo then
        -- push to tail of fifo
        aQueue.list[aQueue.lowEntry] = entry
        aQueue.lowEntry = aQueue.lowEntry - 1
    else
        -- push to head of lifo
        aQueue.list[aQueue.highEntry] = entry
        aQueue.highEntry = aQueue.highEntry + 1
    end
end

--
-- Retrieve data from the queue
-- Parameters
--      aQueue - the context returned from a call to create()
-- Returns
--      The data retrieved or nil if the queue is empty
--
function Queue:Pop(aQueue)
    local entry = nil
    local entryCount = l_CountEntries(aQueue)

    if entryCount == 0 then
        -- queue is empty
    elseif entryCount == 1 then
        -- pop last entry
        entry = aQueue.list[aQueue.highEntry - 1]
 
        -- queue is now empty - reset counts
        aQueue.highEntry = 0
        aQueue.lowEntry = -1
    else
        -- pop entry
        aQueue.highEntry = aQueue.highEntry - 1
        entry = aQueue.list[aQueue.highEntry]
    end

    return entry
end

--
-- This function allows you to look at the "next" item in the queue without retrieving it
-- The next item is the one that would currently be returned by a Pop()
-- Parameters
--      aQueue - the context returned from a call to create()
-- Returns
--      The data part of the next item or nil if the queue is empty
--
function Queue:Peek(aQueue)
    local entry = nil
    local entryCount = l_CountEntries(aQueue)

    if entryCount == 0 then
        -- queue is empty
    else
        -- peek next entry
        entry = aQueue.list[aQueue.highEntry - 1]
    end

    return entry
end

--
-- Reset the queue - all data currently in the queue is lost
-- Parameters
--      aQueue - the context returned from a call to create()
--
function Queue:Reset(aQueue)
    aQueue.highEntry = 0
    aQueue.lowEntry = -1
    ZO_ClearTable(aQueue.list)
end

--
-- Destroy the queue - all data currently in the queue is lost
-- The aQueue context cannot be reused
-- Parameters
--      aQueue - the context returned from a call to create()
--
function Queue:Destroy(aQueue)
    ZO_ClearTable(aQueue.list)
    ZO_ClearTable(aQueue)
end

--
-- Function to report whether a queue is empty
-- Parameters
--      aQueue - the context returned from a call to create()
-- Returns
--      true if there is no data in the queue, false otherwise
--
function Queue:IsEmpty(aQueue)
    local isEmpty = (l_CountEntries(aQueue) == 0)
    return isEmpty
end