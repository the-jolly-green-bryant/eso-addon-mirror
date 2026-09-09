-- Development-only smoke tests. This file is intentionally not in the addon manifest.
-- Run it from an ESO-aware Lua test harness after loading the core/language files.

local TT = TamrielicTongues
local samples = {
    "Meet me at the old bridge after midnight.",
    "I trust you, friend.",
    "Follow the guard and wait outside.",
    "Leiadriel will return tomorrow.",
    "Do not open the gate.",
}

for _, profile in ipairs(TT.Registry:GetOrdered()) do
    for _, sample in ipairs(samples) do
        local ok, result = TT.RoundTrip:Validate(profile.id, sample)
        assert(ok, string.format(
            "%s failed round trip: %s -> %s -> %s",
            profile.id,
            sample,
            result and result.encoded or "<encode failed>",
            result and result.decoded or "<decode failed>"
        ))
    end
end
