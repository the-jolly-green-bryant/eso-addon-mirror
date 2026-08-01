---------
-- locals
---------
-- local SPRINT_ABILITY_ID = 973
-- local PLAYER_UNIT_TAG = "player"

---------------
-- sprint start
---------------
-- EVENT_MANAGER:RegisterForEvent(SprintSens.events.sprintStart, EVENT_COMBAT_EVENT, SprintSens.OnSprintStart)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStart, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStart, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStart, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SPRINT_ABILITY_ID)

--------------
-- sprint stop
--------------
-- EVENT_MANAGER:RegisterForEvent(SprintSens.events.sprintStop, EVENT_COMBAT_EVENT, SprintSens.OnSprintStop)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStop, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStop, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
-- EVENT_MANAGER:AddFilterForEvent(SprintSens.events.sprintStop, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SPRINT_ABILITY_ID)

--------
-- inits
--------
-- EVENT_MANAGER:RegisterForEvent(SprintSens.events.activation, EVENT_PLAYER_ACTIVATED, SprintSens.OnSprintStop)
EVENT_MANAGER:RegisterForEvent(SprintSens.name, EVENT_ADD_ON_LOADED, SprintSens.OnLoad)