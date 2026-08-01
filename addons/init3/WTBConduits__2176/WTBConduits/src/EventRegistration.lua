local wtb = WTBConduits
local EM = EVENT_MANAGER
local _WARDEN = 4
local _SORC   = 2
local _NECRO  = 5

function wtb.RegisterEvents()
     wtb.dbg("Registering Events")
     local abilities = {}

     local function RegisterForAbility(abilityId)
          if not abilities[abilityId] then -- If ability has not yet been registered
               abilities[abilityId] = true
               eventName = wtb.name .. "_" .. abilityId
               EM:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, wtb.OnCombatEvent) -- Registers all combat events
               EM:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId) -- Filters the event to a specific ability
          end
     end

     if wtb.sv.autodetermination then
          wtb.dbg("Using Autodetermination")
          wtb.dbg("Registering Tracked Synergies")
          if wtb.playerClass == _SORC then
               EM:RegisterForEvent(wtb.name .. "_conduit", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_conduit", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108607)
               wtb.dbg("     +++     Conduit")
          end
          if wtb.playerClass == _WARDEN then
               EM:RegisterForEvent(wtb.name .. "_harvest", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_harvest", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108826)
               wtb.dbg("     +++     Harvest")
          end
          if wtb.playerClass == _NECRO then
               EM:RegisterForEvent(wtb.name .. "_boneyard", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_boneyard", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 125219)
               EM:RegisterForEvent(wtb.name .. "_agony", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_agony", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 125220)
               wtb.dbg("     +++     Boneyard")
               wtb.dbg("     +++     Pure Agony")
          end
          if wtb.playerRole == LFG_ROLE_HEAL then -- If player is a healer (Healers are 4, Tanks are 2 and DPS are 1)
               EM:RegisterForEvent(wtb.name .. "_orbs_1", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_orbs_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108799)
               EM:RegisterForEvent(wtb.name .. "_orbs_2", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_orbs_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108802)
               EM:RegisterForEvent(wtb.name .. "_shards_1", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_shards_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108821)
               EM:RegisterForEvent(wtb.name .. "_shards_2", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_shards_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108924)
               wtb.dbg("     +++     Orbs/Shards")
          end
     else
          wtb.dbg("Not using Autodetermination")
          wtb.dbg("Registering Tracked Synergies")
          if wtb.sv.trackConduit then
               EM:RegisterForEvent(wtb.name .. "_conduit", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_conduit", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108607)
               wtb.dbg("     +++     Conduit")
          end
          if wtb.sv.trackOrbs then
               EM:RegisterForEvent(wtb.name .. "_orbs_1", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_orbs_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108799)
               EM:RegisterForEvent(wtb.name .. "_orbs_2", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_orbs_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108802)
               EM:RegisterForEvent(wtb.name .. "_shards_1", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_shards_1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108821)
               EM:RegisterForEvent(wtb.name .. "_shards_2", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_shards_2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108924)
               wtb.dbg("     +++     Orbs/Shards")
          end
          if wtb.sv.trackHarvest then
               EM:RegisterForEvent(wtb.name .. "_harvest", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_harvest", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 108826)
               wtb.dbg("     +++     Harvest")
          end
          if wtb.sv.trackBoneyard then
               EM:RegisterForEvent(wtb.name .. "_boneyard", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_boneyard", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 125219)
               wtb.dbg("     +++     Boneyard")
          end
          if wtb.sv.trackAgony then
               EM:RegisterForEvent(wtb.name .. "_agony", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
               EM:AddFilterForEvent(wtb.name .. "_agony", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 125220)
               wtb.dbg("     +++     Pure Agony")
          end
     end
     -- Additional Synergies for tracking Alkosh
     wtb.dbg("Registering Untracked Synergies")
     RegisterForAbility(108782)
     RegisterForAbility(108787)
     RegisterForAbility(108788)
     RegisterForAbility(108791)
     RegisterForAbility(108792)
     RegisterForAbility(108793)
     RegisterForAbility(108794)
     RegisterForAbility(108797)
     RegisterForAbility(108824)
     RegisterForAbility(108805)
     RegisterForAbility(108807)
     RegisterForAbility(108822)
     RegisterForAbility(108823)
     RegisterForAbility(108808)
     RegisterForAbility(108814)

     EM:RegisterForEvent(wtb.name, EVENT_PLAYER_COMBAT_STATE, wtb.CombatState)
     if wtb.sv.trackLinebreaker then
          EM:RegisterForEvent(wtb.name .. "_linebreaker", EVENT_COMBAT_EVENT, wtb.OnCombatEvent)
          EM:AddFilterForEvent(wtb.name .. "_linebreaker", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, wtb.synergies.linebreaker)
          wtb.dbg("Linebreaker Tracking: |c00ff00Enabled|r")
     else
          wtb.dbg("Linebreaker Tracking: |cff0000Disabled|r")
     end
     EM:RegisterForUpdate(wtb.name, 250, wtb.UpdateTimers)
end

function wtb.UnregisterEvents()
     wtb.dbg("Unregistering Events")

     local function UnregisterForAbility(abilityId)
          eventName = wtb.name .. "_" .. abilityId
          EM:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT, wtb.OnCombatEvent) -- Unregisters all combat events
     end

     EM:UnregisterForEvent(wtb.name .. "_conduit", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_harvest", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_orbs_1", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_orbs_2", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_shards_1", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_shards_2", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_boneyard", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_agony", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name .. "_linebreaker", EVENT_COMBAT_EVENT)
     EM:UnregisterForEvent(wtb.name, EVENT_PLAYER_COMBAT_STATE)
     EM:UnregisterForUpdate(wtb.name)

     UnregisterForAbility(108782)
     UnregisterForAbility(108787)
     UnregisterForAbility(108788)
     UnregisterForAbility(108791)
     UnregisterForAbility(108792)
     UnregisterForAbility(108793)
     UnregisterForAbility(108794)
     UnregisterForAbility(108797)
     UnregisterForAbility(108824)
     UnregisterForAbility(108805)
     UnregisterForAbility(108807)
     UnregisterForAbility(108822)
     UnregisterForAbility(108823)
     UnregisterForAbility(108808)
     UnregisterForAbility(108814)
end
