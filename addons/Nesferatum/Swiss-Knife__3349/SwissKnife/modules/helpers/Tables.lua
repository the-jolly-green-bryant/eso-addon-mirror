local SK = SwissKnife

local function isKeyInTable(table, key)
    return table ~= nil and key ~= nil and table[key] ~= nil
end

local function isValueInTable(table, value)
	if table ~= nil and value ~= nil then
        for _, v in pairs(table) do
            if (v == value) then return true end
        end
	end
	return false
end

local function createTableChild(table, keys)
	local child = table
	for _, key in ipairs(keys) do
		if child[key] == nil then child[key] = {} end
		child = child[key]
	end
end

local function hasTableChild(table, keys)
	if table == nil or keys == nil then return end
	local next = next
	local child = table
    local keysCount = #keys
	for i, key in ipairs(keys) do
        if child[key] == nil or (type(child[key]) == "table" and next(child[key]) == nil) then
            break
        else
	        child = child[key]
        end
        if i == keysCount and child ~= nil then return true end
    end
    return false
end

local function setTableChild(table, keys, value)
	if table == nil or keys == nil then return end
	local child = table
	local keysCount = #keys
    if not hasTableChild(table, keys) then createTableChild(table, keys) end
	for i, key in ipairs(keys) do
        if i == keysCount then child[key] = value else child = child[key] end
    end
end

-- Export helper functions
SK.HelperFunctions.isKeyInTable = isKeyInTable
SK.HelperFunctions.isValueInTable = isValueInTable
SK.HelperFunctions.createTableChild = createTableChild
SK.HelperFunctions.hasTableChild = hasTableChild
SK.HelperFunctions.setTableChild = setTableChild
