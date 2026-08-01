LibDataStructures = LibDataStructures or {}

local LDS = LibDataStructures
LDS.Queue = {}

local Queue = LDS.Queue
Queue.__index = Queue

--- Creates a new Queue instance.
-- @param initialData (Optional) A table of initial values for the queue.
-- @return A new Queue object.
-- @usage
-- local queue = Queue:New()
-- queue:Enqueue(10)
-- queue:Enqueue(20)
function Queue:New(initialData)
    local obj = setmetatable({}, Queue)
    obj._data = initialData or {}
    obj._front = 1
    obj._back = #obj._data
    return obj
end

--- Adds a value to the back of the queue.
-- @param value The value to be added.
-- @usage
-- queue:Enqueue(42)
function Queue:Enqueue(value)
    if value == nil then
        error("Attempt to enqueue a nil value")
    end
    self._back = self._back + 1
    self._data[self._back] = value
end

--- Removes and returns the value from the front of the queue.
-- @return The front value of the queue, or nil if the queue is empty.
-- @usage
-- local value = queue:Dequeue()
-- d(value) -- Outputs the dequeued value
function Queue:Dequeue()
    if self:IsEmpty() then
        return nil
    end
    local value = self._data[self._front]
    self._data[self._front] = nil -- Clear the reference
    self._front = self._front + 1
    return value
end

--- Returns the value at the front of the queue without removing it.
-- @return The front value of the queue, or nil if the queue is empty.
-- @usage
-- local value = queue:Peek()
-- d(value) -- Outputs the front value
function Queue:Peek()
    if self:IsEmpty() then
        return nil
    end
    return self._data[self._front]
end

--- Returns the number of elements in the queue.
-- @return The number of elements in the queue.
-- @usage
-- local count = queue:Len()
-- d(count) -- Outputs the length of the queue
function Queue:Len()
    return self._back - self._front + 1
end

--- Checks if the queue is empty.
-- @return `true` if the queue is empty, `false` otherwise.
-- @usage
-- local isEmpty = queue:IsEmpty()
-- d(isEmpty) -- Outputs true or false
function Queue:IsEmpty()
    return self._front > self._back
end

--- Clears all elements from the queue.
-- @usage
-- queue:Clear()
-- d(queue:Len()) -- Outputs 0
function Queue:Clear()
    self._data = {}
    self._front = 1
    self._back = 0
end

--- Iterates over the queue from front to back.
-- @return An iterator function.
-- @usage
-- for value in queue:Iterate() do
--     d(value)
-- end
function Queue:Iterate()
    local i = self._front - 1
    return function()
        i = i + 1
        if i <= self._back then
            return self._data[i]
        end
    end
end

--- Creates a shallow copy of the current queue.
-- The cloned queue contains the same elements in the same order,
-- but it is an independent instance with its own internal data.
-- @param deep If true, copies nested tables as well.
-- @return A new Queue object that is a clone of the current queue.
-- @usage
-- local originalQueue = Queue:New()
-- originalQueue:Enqueue(1)
-- originalQueue:Enqueue(2)
-- local clonedQueue = originalQueue:Clone()
-- print(clonedQueue:Dequeue()) -- Outputs 1
-- print(originalQueue:Dequeue()) -- Outputs 1 (independent instance)
function Queue:Clone(deep)
    local clonedData = {}
    for i = self._front, self._back do
        if deep and type(self._data[i]) == "table" then
            local copiedTable = {}
            for k, v in pairs(self._data[i]) do
                copiedTable[k] = v
            end
            clonedData[#clonedData + 1] = copiedTable
        else
            clonedData[#clonedData + 1] = self._data[i]
        end
    end
    return Queue:New(clonedData)
end

--- Converts the queue to a string representation.
-- @return A string representation of the queue.
-- @usage
-- d(queue:ToString()) -- Outputs the queue content
function Queue:ToString()
    local result = {}
    for i = self._front, self._back do
        table.insert(result, tostring(self._data[i]))
    end
    return "Queue: {" .. table.concat(result, ", ") .. "}"
end