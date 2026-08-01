EVENT_MANAGER:RegisterForEvent("zmajaPortAlert", EVENT_COMBAT_EVENT, function() CrutchAlerts.DisplayDamageable(3.9) end)
EVENT_MANAGER:AddFilterForEvent("zmajaPortAlert", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 104555)
