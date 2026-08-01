
function HealerHelper.diffTimeinSeconds(t)
    local difms = GetGameTimeMilliseconds()-t
    local difs = difms/1000
    return difs
end
