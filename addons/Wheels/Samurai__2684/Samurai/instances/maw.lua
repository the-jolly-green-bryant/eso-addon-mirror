SAMURAI = SAMURAI or { }
local sam = SAMURAI
local EM = GetEventManager()

local maw = sam.Instance:New(725, nil, nil)

maw:AddAlert(sam.TimerNotification:New("mawEclipse", "bc40ff", "Eclipse", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73700}, true))
maw:AddAlert(sam.ActiveNotification:New(nil, nil, "mawEclipseAll", "bc40ff", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73700}, "Eclipse Field!", 2000, false))

maw:AddAlert(sam.TimerNotification:New("mawShatter", "ffa217", "Shatter", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73249}, true))
maw:AddAlert(sam.TimerNotification:New("mawShatterEffect", "ff5117", "Shattered", EVENT_COMBAT_EVENT, ACTION_RESULT_EFFECT_GAINED_DURATION, {73250}, true))
maw:AddAlert(sam.TimerNotification:New("mawSwing", "17d4ff", "Swing", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73258}, true))

maw:AddAlert(sam.ActiveNotification:New(nil, nil, "mawVoidRush", "ff0000", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73721}, "Block!", 2000, true))
maw:AddAlert(sam.ActiveNotification:New(nil, nil, "mawShadowSlash", "ff0000", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73050}, "Block!", 2000, true))


maw:AddAlert(sam.TimerNotification:New("mawSlam", "0084ff", "Slam", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73053}, true))

maw:AddAlert(sam.TimerNotification:New("mawSavageOnslaught", "48ff00", "Onslaught", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73372}, false))
maw:AddAlert(sam.ActiveNotification:New(nil, nil, "mawSavageOnslaughtInterrupt", "48ff00", EVENT_COMBAT_EVENT, ACTION_RESULT_BEGIN, {73372}, "Interrupt!", 2000, false))

--table.insert(sam.instances, maw) -- WIP

