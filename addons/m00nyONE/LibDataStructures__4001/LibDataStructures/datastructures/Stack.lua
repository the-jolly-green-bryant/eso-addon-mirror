LibDataStructures = LibDataStructures or {}

local LDS = LibDataStructures
LDS.Stack = {}

local Stack = LDS.Stack
Stack.__index = Stack

--- Creates a new Stack instance.
-- @param initialData (Optional) A table of initial values for the stack.
-- @return A new Stack object.
-- @usage
-- local stack = Stack:New()
-- stack:Push(10)
-- stack:Push(20)
function Stack:New(initialData)
    local obj = setmetatable({}, Stack)
    obj._data = initialData or {}
    obj._size = #obj._data

    return obj
end

--- Pushes a value onto the stack.
-- @param value The value to be pushed.
-- @usage
-- stack:Push(42)
function Stack:Push(value)
    if value == nil then
        error("Attempt to push a nil value onto the stack")
    end
    self._size = self._size + 1
    self._data[self._size] = value
end

--- Removes and returns the value from the top of the stack.
-- @return The top value of the stack, or nil if the stack is empty.
-- @usage
-- local value = stack:Pop()
-- d(value) -- Outputs the popped value
function Stack:Pop()
    if self._size == 0 then
        return nil
    end
    local value = self._data[self._size]
    self._data[self._size] = nil
    self._size = self._size - 1
    return value
end

--- Returns the value on top of the stack without removing it.
-- @return The top value of the stack, or nil if the stack is empty.
-- @usage
-- local value = stack:Peek()
-- d(value) -- Outputs the top value
function Stack:Peek()
    if self._size == 0 then
        return nil
    end
    return self._data[self._size]
end

--- Returns the number of elements in the stack.
-- @return The number of elements in the stack.
-- @usage
-- local count = stack:Len()
-- d(count) -- Outputs the length of the stack
function Stack:Len()
    return self._size
end

--- Checks if the stack is empty.
-- @return `true` if the stack is empty, `false` otherwise.
-- @usage
-- local isEmpty = stack:IsEmpty()
-- d(isEmpty) -- Outputs true or false
function Stack:IsEmpty()
    return self._size == 0
end

--- Iterates over the stack from top to bottom.
-- @return An iterator function.
-- @usage
-- for value in stack:Iterate() do
--     d(value)
-- end
function Stack:Iterate()
    local i = self._size + 1
    return function()
        i = i - 1
        if i > 0 then
            return self._data[i]
        end
    end
end

--- Creates a shallow copy of the current stack.
-- The cloned stack contains the same elements in the same order,
-- but it is an independent instance with its own internal data.
-- @param deep if True, shallow copies nested structures too
-- @return A new Stack object that is a clone of the current stack.
-- @usage
-- local originalStack = Stack:New()
-- originalStack:Push(1)
-- originalStack:Push(2)
-- local clonedStack = originalStack:Clone()
-- print(clonedStack:Pop()) -- Outputs 2
-- print(originalStack:Pop()) -- Outputs 2 (independent instance)
function Stack:Clone(deep)
    local clonedData = {}
    for i = 1, self._size do
        if deep and type(self._data[i]) == "table" then
            local copiedTable = {}
            for k, v in pairs(self._data[i]) do
                copiedTable[k] = v
            end
            clonedData[i] = copiedTable
        else
            clonedData[i] = self._data[i]
        end
    end
    return Stack:New(clonedData)
end

--- Removes all elements from the stack.
-- @usage
-- stack:Clear()
-- d(stack:Len()) -- Outputs 0
function Stack:Clear()
    self._data = {}
    self._size = 0
end

--- Converts the stack to a string representation.
-- @return A string representation of the stack.
-- @usage
-- d(stack:ToString()) -- Outputs the stack content
function Stack:ToString()
    local result = {}
    for i = self._size, 1, -1 do
        table.insert(result, tostring(self._data[i]))
    end
    return "Stack: {" .. table.concat(result, ", ") .. "}"
end
