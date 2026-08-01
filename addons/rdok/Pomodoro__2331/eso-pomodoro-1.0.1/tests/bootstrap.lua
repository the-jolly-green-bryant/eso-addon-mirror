require "TimeAssertion"
require "InstanceAssertion"
require "ChatAssertion"

local esouiLoader = require 'EsoLuaLoader'
esouiLoader:initializeGlobals()
esouiLoader:requireLuaFiles()

function dd(variable)
    local inspectioner = require 'inspect'
    local inspection = inspectioner.inspect(variable)
    print(inspection)
    os.exit()
end

--function TestCase:assertChatWindowContains(value)
--end
