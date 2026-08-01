TargetColor = {}

function OnTarget(Event, Unit)
local react1, react2, react3 = GetUnitReactionColor("reticleover")
ZO_TargetUnitFramereticleoverBarLeft:SetColor(react1, react2, react3, 1)
ZO_TargetUnitFramereticleoverBarRight:SetColor(react1, react2, react3, 1)
end

EVENT_MANAGER:RegisterForEvent("Target", EVENT_RETICLE_TARGET_CHANGED, OnTarget)
