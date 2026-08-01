LibDataStructures = LibDataStructures or {}

local LDS = LibDataStructures
LDS.BinaryTree = {}

local BinaryTree = LDS.BinaryTree
BinaryTree.__index = BinaryTree

---------------------------------------
-- Internal Node definition
---------------------------------------
local Node = {}
Node.__index = Node

function Node:New(value)
    local obj = setmetatable({}, Node)
    obj.value = value
    obj.left = nil
    obj.right = nil
    return obj
end

---------------------------------------
-- BinaryTree definition
---------------------------------------

--- Creates a new BinaryTree instance.
-- @param compareFunc (Optional) A custom comparison function that takes two values a and b and returns:
--        -1 if a < b
--         0 if a == b
--         1 if a > b
-- If omitted, the default comparison uses Lua operators < and ==.
-- @return A new BinaryTree object.
-- @usage
-- local tree = BinaryTree:New()
-- tree:Insert(10)
-- tree:Insert(5)
-- tree:Insert(15)
function BinaryTree:New(compareFunc)
    local obj = setmetatable({}, BinaryTree)
    obj._root = nil
    obj._size = 0
    obj._compare = compareFunc or function(a, b)
        if a == b then return 0 end
        return a < b and -1 or 1
    end
    return obj
end

--- Inserts a value into the binary search tree.
-- @param value The value to insert.
-- @usage
-- local tree = BinaryTree:New()
-- tree:Insert(10)
-- tree:Insert(5)
-- tree:Insert(15)
function BinaryTree:Insert(value)
    if value == nil then
        error("Attempt to insert a nil value into the binary tree")
    end

    local function insertNode(node, val)
        if node == nil then
            return Node:New(val)
        end
        local cmp = self._compare(val, node.value)
        if cmp < 0 then
            node.left = insertNode(node.left, val)
        elseif cmp > 0 then
            node.right = insertNode(node.right, val)
        else
            -- value already in tree; decision: ignore duplicates or handle differently
            -- here we just ignore duplicates
        end
        return node
    end

    self._root = insertNode(self._root, value)
    self._size = self._size + 1
end

--- Checks if a value is present in the tree.
-- @param value The value to search for.
-- @return true if found, false otherwise.
-- @usage
-- local found = tree:Find(10)
function BinaryTree:Find(value)
    local node = self._root
    while node ~= nil do
        local cmp = self._compare(value, node.value)
        if cmp == 0 then
            return true
        elseif cmp < 0 then
            node = node.left
        else
            node = node.right
        end
    end
    return false
end

--- Removes a value from the tree if it exists.
-- @param value The value to remove.
-- @usage
-- tree:Remove(10)
function BinaryTree:Remove(value)
    local function findMin(n)
        while n.left do
            n = n.left
        end
        return n
    end

    local function removeNode(node, val)
        if node == nil then
            return nil
        end

        local cmp = self._compare(val, node.value)
        if cmp < 0 then
            node.left = removeNode(node.left, val)
        elseif cmp > 0 then
            node.right = removeNode(node.right, val)
        else
            -- We found the node to remove
            -- Case 1: No child
            if node.left == nil and node.right == nil then
                node = nil
                -- Case 2: One child
            elseif node.left == nil then
                node = node.right
            elseif node.right == nil then
                node = node.left
            else
                -- Case 3: Two children
                local minRight = findMin(node.right)
                node.value = minRight.value
                node.right = removeNode(node.right, minRight.value)
            end
        end
        return node
    end

    if self:Find(value) then
        self._root = removeNode(self._root, value)
        self._size = self._size - 1
    end
end

--- Returns the number of elements in the tree.
-- @return The number of elements.
-- @usage
-- local count = tree:Len()
function BinaryTree:Len()
    return self._size
end

--- Checks if the tree is empty.
-- @return true if empty, false otherwise.
-- @usage
-- local empty = tree:IsEmpty()
function BinaryTree:IsEmpty()
    return self._size == 0
end

--- Clears the tree by removing all elements.
-- @usage
-- tree:Clear()
-- print(tree:Len())  -- Outputs 0
function BinaryTree:Clear()
    self._root = nil
    self._size = 0
end

--- In-order traversal of the tree.
-- Calls the provided callback function(value) for each node in ascending order.
-- @param callback A function to call for each node's value.
-- @usage
-- tree:InOrder(function(v) d(v) end)
function BinaryTree:InOrder(callback)
    local function inOrder(node)
        if node == nil then return end
        inOrder(node.left)
        callback(node.value)
        inOrder(node.right)
    end
    inOrder(self._root)
end

--- Pre-order traversal of the tree.
-- Calls the provided callback function(value) for each node, starting from the root.
-- @param callback A function to call for each node's value.
-- @usage
-- tree:PreOrder(function(v) d(v) end)
function BinaryTree:PreOrder(callback)
    local function preOrder(node)
        if node == nil then return end
        callback(node.value)
        preOrder(node.left)
        preOrder(node.right)
    end
    preOrder(self._root)
end

--- Post-order traversal of the tree.
-- Calls the provided callback function(value) for each node after visiting children.
-- @param callback A function to call for each node's value.
-- @usage
-- tree:PostOrder(function(v) d(v) end)
function BinaryTree:PostOrder(callback)
    local function postOrder(node)
        if node == nil then return end
        postOrder(node.left)
        postOrder(node.right)
        callback(node.value)
    end
    postOrder(self._root)
end

--- Returns a string representation of the tree.
-- This is a simple representation for debugging purposes.
-- @return A string representation of the tree.
-- @usage
-- d(tree:ToString())
function BinaryTree:ToString()
    local values = {}
    self:InOrder(function(v) table.insert(values, tostring(v)) end)
    return "BinaryTree: {" .. table.concat(values, ", ") .. "}"
end

--- Creates a shallow copy of the current tree by inserting its elements into a new tree.
-- @param deep Not implemented here, as the tree nodes are typically values. If needed, you can implement a deep copy logic for complex values.
-- @return A new BinaryTree object that is a clone of the current tree.
-- @usage
-- local clone = tree:Clone()
function BinaryTree:Clone(deep)
    local newTree = BinaryTree:New(self._compare)
    self:InOrder(function(v)
        -- Wenn deep Copy für komplexe Werte benötigt wird, hier erweitern
        newTree:Insert(v)
    end)
    return newTree
end
