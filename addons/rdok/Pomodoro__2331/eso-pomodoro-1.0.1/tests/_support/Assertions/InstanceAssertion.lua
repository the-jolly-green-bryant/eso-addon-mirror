local assert = require('luassert.assert')
local say = require("say")

-- Consider instance of table a table that has the same functions key names
local function instance_of(state, arguments)
    if not type(arguments[1]) == "table" or #arguments ~= 2 then
        return false
    end

    local expectedInstance = arguments[1]
    local actualInstance = arguments[2]

    for property, value in pairs(expectedInstance) do
        if (type(property) == 'function') then
          dd('assert object has function')
        end
    end

    return false
end

say:set("assertion.instance_of.true", "\n\nExpected instance: %s. \n\nActual: %s")
say:set("assertion.instance_of.false", "\nExpected instance: %s. \n\nActual: %s")
assert:register("assertion", "instance_of", instance_of, "assertion.instance_of.true", "assertion.instance_of.false")
