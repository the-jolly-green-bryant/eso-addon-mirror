LibTextFormat = LibTextFormat or {}
local LTF = LibTextFormat

LTF.Core = LTF.Core or { ["v1"] = {} }

LTF.Core["v1"]["plural"] = function(ctx, text)
    text = text or ""
    local count = ctx.scope:Get("count")
    local singular = ctx.scope:Get("singular")
    local plural = ctx.scope:Get("plural") or (singular .. "s")
    if count == 1 then
      return singular
    end
    return plural
end

LTF.Core["repeat"] = function(ctx, text)
    text = text or ""
    local unit = ctx.scope:Get("unit")
    local times = ctx.scope:Get("times")
    return text..string.rep(unit, times)
end
