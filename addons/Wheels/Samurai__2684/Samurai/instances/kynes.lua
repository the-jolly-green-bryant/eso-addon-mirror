SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()

local ka = sam.Instance:New(1196, nil, nil)

ka:AddAlert(sam.TimerNotification:New("WrathofTides", "2bcaff", "Wrath", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {134050}, true))
ka:AddAlert(sam.TimerNotification:New("CrashingWave", "19e0ff", "Wave", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {134196}, false))
--ka:AddAlert(sam.TimerNotification:New("CrashingWave", "19e0ff", "Wave", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {134196}, false))
--ka:AddAlert(sam.TimerNotification:New("kaMeteor", "19e000", "Meteor", EVENT_COMBAT_EVENT, ACTION_RESULT_EFFECT_GAINED, {140606}, false))
ka:AddAlert(sam.TimerNotification:New("Chaurus", "19e000", "Chaurus", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {133559, 139812}, true))
ka:AddAlert(sam.TimerNotification:New("StoneCurse", "ffcd57", "Stone", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {133546}, false))

ka:AddAlert(sam.ActiveNotification:New(nil, nil, "ChaurusInc", "00FFFF", EVENT_COMBAT_EVENT, ACTION_RESULT_EFFECT_GAINED, {133559, 139812}, "Poison Inc", 2000, false))
--ka:AddAlert(sam.ActiveNotification:New(nil, nil, "StoneCurse", "00FFFF", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {133546}, "Stone, Block", 2000, false))

table.insert(sam.instances, ka)
