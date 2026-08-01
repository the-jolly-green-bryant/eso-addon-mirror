local AST = AsylumTracker
local EM = EVENT_MANAGER

function AST.RegisterEvents()
     if AST.isInVAS then -- Only register events if player is in Asylum to save resources
          local abilities = {} -- Stores event ids to be registered
          local eventName = AST.name .. "_event_" -- Each filter must be registered separately, and must therefore have a different unique identifier.
          local eventIndex = 0
          local function RegisterForAbility(abilityId)
               if not abilities[abilityId] then -- If ability has not yet been registered
                    abilities[abilityId] = true
                    eventIndex = eventIndex + 1
                    EM:RegisterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, AST.OnCombatEvent) -- Registers all combat events
                    EM:AddFilterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId) -- Filters the event to a specific ability
               end
          end

          -- Only registers abilities enabled in the settings
          for x, y in pairs(AST.id) do
               if AST.sv[x] and type(y) == "number" then
                    RegisterForAbility(y)
               end
          end
          if AST.sv["oppressive_bolts"] then
               -- These are needed for tracking interrupts on Llothis
               RegisterForAbility(AST.id["bash"])
               RegisterForAbility(AST.id["force_shock"])
               RegisterForAbility(AST.id["deep_breath"])
               RegisterForAbility(AST.id["charge"])
               RegisterForAbility(AST.id["poison_arrow"])
               RegisterForAbility(AST.id["shrouded_daggers"])
          end
          RegisterForAbility(AST.id["gusts_of_steam"]) -- Olms Jump at 90/75/50/25
          -- Registers Olms' Steam Breath regardless of whether it is to be displayed in order to correctly track Olms' Storm the Heavens Timer
          if not AST.sv.scalding_roar then RegisterForAbility(AST.id["scalding_roar"]) end
          if not AST.sv.storm_the_heavens then RegisterForAbility(AST.id["storm_the_heavens"]) end
          if not AST.sv.exhaustive_charges then RegisterForAbility(AST.id["exhaustive_charges"]) end
          if not AST.sv.trial_by_fire then RegisterForAbility(AST.id["trial_by_fire"]) end

          EM:RegisterForEvent(AST.name, EVENT_PLAYER_COMBAT_STATE, AST.CombatState) -- Used to determine player's combat state
          EM:RegisterForEvent(AST.name .. "_dormant", EVENT_EFFECT_CHANGED, AST.OnEffectChanged) -- Used to determine if Llothis/Felms go down
          EM:RegisterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT, AST.OnCombatEvent)
          EM:AddFilterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, AST.id.boss_event)
          EM:RegisterForUpdate(AST.name .. "_updateTimers", AST.refreshRate, AST.UpdateTimers) -- Calls this function every half second to update timers and Olm's health
          EM:RegisterForUpdate(AST.name .. "_monitorOlmsHP", AST.refreshRate, AST.MonitorOlmsHP)
          EM:RegisterForUpdate(AST.name .. "_alternateColors", 1000, AST.AlternateNotificationColors)
     end
end

-- Unregisters events if not in Asylum Sanctorium
function AST.UnregisterEvents()
     if not AST.isInVAS then
          local eventName = AST.name .. "_event_"
          eventIndex = 0
          for x, y in pairs(AST.id) do
               eventIndex = eventIndex + 1
               EM:UnregisterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT)
          end

          EM:UnregisterForEvent(AST.name, EVENT_PLAYER_COMBAT_STATE, AST.CombatState)
          EM:UnregisterForEvent(AST.name .. "_dormant", EVENT_EFFECT_CHANGED, AST.OnEffectChanged)
          EM:UnregisterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT, AST.OnCombatEvent)
          EM:UnregisterForUpdate(AST.name .. "_updateTimers")
          EM:UnregisterForUpdate(AST.name .. "_monitorOlmsHP")
          EM:UnregisterForUpdate(AST.name .. "_alternateColors")
     end
end
