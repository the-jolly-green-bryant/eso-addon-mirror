--  Cost Calculator v1.0.0
--
--  By Peter Ogdin a.k.a. @TheBunnynator1001
--  With lots of help from Scootworks
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
-- The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. 
-- in the United States and/or other countries.
-- All rights reserved.
--
-- Any questions or suggestions can be sent to:
-- TheBunnynator1001 (in game), @DeBunnynator#2728 (Discord), or esthebunnynator1001@gmail.com (email)
--
-- Thank you for using my addon and for your support!
--

local em = GetEventManager()

local cCalc = {}

cCalc.name = 'Cost Calculator'
cCalc.version = '1.0.0'
cCalc.author = 'TheBunnynator1001'

function cCalc.init()

    if addonName ~= 'Cost Calculator' then return end
    zo_callLater(function () d('Cost Calculator Loaded') end , 2000)
    zo_callLater(function() d('Version ' .. cCalc.version) end, 2000)
    zo_callLater(function() d('A personal thank you for using this addon!') end, 2000)
    em:UnregisterForEvent(cCalc.name, ON_ADD_ON_LOADED)

end

em:RegisterForEvent(cCalc.name, ON_ADD_ON_LOADED, cCalc.init())

local mathTable = { }

local function AddToMathTable(arg)
    table.insert(mathTable, arg)
end

local function GetSummary()
    local sum = 0
    for index, value in ipairs(mathTable) do
        -- df("index %s, value %s", tostring(index), tostring(value))
        sum = sum + value
    end
    return sum
end

local function Split(s)
    local t = {}
    s:gsub('%-?%d+', function(n)
        t[#t+1] = tonumber(n)
    end)
    return t
end

local function Calculate(...)
    ZO_ClearNumericallyIndexedTable(mathTable)

    local values = Split(...)
    for index, value in ipairs(values) do
        AddToMathTable(value)
    end

    local price = GetSummary() + 500
    local gPrice = price - (price * .20)
    d('Item price: ' .. price)
    d('Guild Member Item Price: ' .. gPrice)
end

SLASH_COMMANDS['/calc'] = Calculate