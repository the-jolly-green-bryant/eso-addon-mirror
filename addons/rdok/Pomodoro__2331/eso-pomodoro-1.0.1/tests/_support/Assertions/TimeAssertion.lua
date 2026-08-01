local assert = require('luassert.assert')
local say = require("say")

local function valid_time(state, arguments)
    if not type(arguments[1]) == "table" or #arguments ~= 1 then
        return false
    end

    return (pcall(os.date, "*t", arguments[1]))
end

say:set("assertion.valid_time.true", "Expected valid time. Actual: %s")
say:set("assertion.valid_time.false", "Expected invalid time. Actual: %s")
assert:register("assertion", "valid_time", valid_time, "assertion.valid_time.true", "assertion.valid_time.false")
