local AST = AsylumTracker
local EM = EVENT_MANAGER

function AST.RegisterEvents()
     if AST.isInVAS then
          local abilities = {}
          local eventName = AST.name .. "_event_" -- each filter needs a unique identifier
          local eventIndex = 0
          local function RegisterForAbility(abilityId)
               if not abilities[abilityId] then
                    abilities[abilityId] = true
                    eventIndex = eventIndex + 1
                    EM:RegisterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, AST.OnCombatEvent)
                    EM:AddFilterForEvent(eventName .. eventIndex, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
               end
          end

          -- Register abilities the player has enabled in settings
          for key, id in pairs(AST.id) do
               if AST.sv[key] and type(id) == "number" then
                    RegisterForAbility(id)
               end
          end

          -- TODO: Verify whether these are needed. ACTION_RESULT_INTERRUPT may fire with the
          -- interrupted ability's ID (oppressive_bolts), making these redundant. The list is
          -- also incomplete — many interrupt abilities are missing — so this is either outdated
          -- or the whole block can be removed.
          if AST.sv.oppressive_bolts then
               RegisterForAbility(AST.id.bash)
               RegisterForAbility(AST.id.force_shock)
               RegisterForAbility(AST.id.deep_breath)
               RegisterForAbility(AST.id.charge)
               RegisterForAbility(AST.id.poison_arrow)
               RegisterForAbility(AST.id.shrouded_daggers)
          end

          -- Always register these for timer tracking regardless of display settings
          RegisterForAbility(AST.id.gusts_of_steam)      -- Olms jumps at 90/75/50/25%
          RegisterForAbility(AST.id.scalding_roar)       -- needed to track Storm the Heavens timer
          RegisterForAbility(AST.id.storm_the_heavens)
          RegisterForAbility(AST.id.exhaustive_charges)
          RegisterForAbility(AST.id.trial_by_fire)

          AST.registeredEventCount = eventIndex
          AST.GetSounds()

          EM:RegisterForEvent(AST.name, EVENT_PLAYER_COMBAT_STATE, AST.CombatState)
          EM:RegisterForEvent(AST.name .. "_dormant", EVENT_EFFECT_CHANGED, AST.OnEffectChanged)
          EM:RegisterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT, AST.OnCombatEvent)
          EM:AddFilterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, AST.id.boss_event)
          EM:RegisterForUpdate(AST.name .. "_updateTimers", AST.refreshRate, AST.UpdateTimers)
          EM:RegisterForUpdate(AST.name .. "_monitorOlmsHP", AST.refreshRate, AST.MonitorOlmsHP)
          EM:RegisterForUpdate(AST.name .. "_alternateColors", 1000, AST.AlternateNotificationColors)
     end
end

function AST.UnregisterEvents()
     if not AST.isInVAS then
          local eventName = AST.name .. "_event_"
          for i = 1, AST.registeredEventCount or 0 do
               EM:UnregisterForEvent(eventName .. i, EVENT_COMBAT_EVENT)
          end
          AST.registeredEventCount = 0

          EM:UnregisterForEvent(AST.name, EVENT_PLAYER_COMBAT_STATE)
          EM:UnregisterForEvent(AST.name .. "_dormant", EVENT_EFFECT_CHANGED)
          EM:UnregisterForEvent(AST.name .. "_bossaura", EVENT_COMBAT_EVENT)
          EM:UnregisterForUpdate(AST.name .. "_updateTimers")
          EM:UnregisterForUpdate(AST.name .. "_monitorOlmsHP")
          EM:UnregisterForUpdate(AST.name .. "_alternateColors")
     end
end