SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()

local as = sam.Instance:New(1000, nil, nil)

as:AddAlert(sam.ActiveNotification:New(nil, nil, "asBossProtected", "FF0000", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {96010}, "Boss Protected!", 3000, false))

table.insert(sam.instances, as)
