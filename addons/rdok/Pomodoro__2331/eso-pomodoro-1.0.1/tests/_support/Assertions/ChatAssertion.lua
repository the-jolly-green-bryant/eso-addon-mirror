local assert = require('luassert.assert')
local say = require("say")

-- Consider instance of table a table that has the same functions key names
local function chat_contains(state, arguments)
    if #arguments ~= 1 or not type(arguments[1]) == "string" then
        return false
    end

    return CHAT_SYSTEM:contains(arguments[1])
end

say:set("assertion.chat.true", "Expected text not found in chat window: %s.")
say:set("assertion.chat.false", "Unexpected text found in chat window: %s.")
assert:register("assertion", "chat", chat_contains, "assertion.chat.true", "assertion.chat.false")
