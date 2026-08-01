LibDataStructures = LibDataStructures or {}
local LDS = LibDataStructures

LDS.Tests = LDS.Tests or {}

LDS.Tests.PERFORMANCE_ITERATIONS = 100000

LDS.Tests.measureTime = function(label, func)
    local startTime = GetGameTimeMilliseconds()
    func()
    local endTime = GetGameTimeMilliseconds()
    d(string.format("%s: %d ms", label, endTime - startTime))
end