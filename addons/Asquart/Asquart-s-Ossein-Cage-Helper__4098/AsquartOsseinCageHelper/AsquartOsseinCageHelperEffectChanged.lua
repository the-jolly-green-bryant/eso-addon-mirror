AOCH = AOCH or {}
local AOCH = AOCH

function AOCH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  AOCH.IdentifyUnit(unitTag, unitName, unitId)
  local isDPS, _, isTank = GetPlayerRoles()

  --------------- Trash alerts
  if changeType == EFFECT_RESULT_GAINED and unitTag == "player" and abilityId == AOCH.data.deadraiser_cursed_terrain_debuff_id and AOCH.savedVariables.show_deadraiser_cursed_terrain then
    AOCHPurpleAlert:SetHidden(false)
    AOCHPurpleAlertLabel:SetHidden(false)
    AOCHPurpleAlertLabel:SetText("Cursed Terrain !")
    PlaySound(SOUNDS.DUEL_START)
  end

  if changeType == EFFECT_RESULT_FADED and abilityId == AOCH.data.deadraiser_cursed_terrain_debuff_id then
    AOCHPurpleAlert:SetHidden(true)
  end

  if changeType == EFFECT_RESULT_GAINED and unitTag == "player" and abilityId == AOCH.data.soul_devourer_detonate_soul_debuff and AOCH.savedVariables.show_soul_devourer_detonate_soul then
    AOCHPurpleAlertLabel:SetText("Detonate Soul on You!")
    AOCHPurpleAlertLabel:SetHidden(false)
    AOCHPurpleAlert:SetHidden(false)
  end

  if changeType == EFFECT_RESULT_FADED and abilityId == AOCH.data.soul_devourer_detonate_soul_debuff then
    AOCHPurpleAlert:SetHidden(true)
  end

  if unitTag == "player" and abilityId == AOCH.data.soul_devourer_life_drain_debuff and AOCH.savedVariables.show_soul_devourer_life_drain then
    if changeType == EFFECT_RESULT_GAINED then
      if AOCH.status.life_drain_alert_id == nil then
        AOCH.status.life_drain_alert_id = CombatAlerts.Alert(nil, "Got Life Drain, cleanse!", 0x14FEFFFF, SOUNDS.DUEL_START, 10000)
      end
    elseif changeType == EFFECT_RESULT_FADED then
      CombatAlerts.DisableBanner(AOCH.status.life_drain_alert_id)
      AOCH.status.life_drain_alert_id = nil
    end
  end

  if changeType == EFFECT_RESULT_GAINED and abilityId == AOCH.data.carrion_reaper_corvid_swarm_debuff and AOCH.savedVariables.show_carrion_reaper_corvid_swarm then
    AOCHPurpleAlert:SetHidden(false)
    AOCHPurpleAlertLabel:SetHidden(false)
    AOCHPurpleAlertLabel:SetText("Corvid Swarm !")
  end

  if changeType == EFFECT_RESULT_FADED and abilityId == AOCH.data.carrion_reaper_corvid_swarm_debuff then
    AOCHPurpleAlert:SetHidden(true)
  end

  if AOCH.data.caustic_carrion_ids[abilityId] == true then
    if (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
      AOCH.status.carrion_stacks_data[unitId] = stackCount
      -- to fix the issue when tracker becomes hidden when entering portal for some reason
      if AOCH.savedVariables.show_boss_carrion_stacks and AOCH.status.is_kazpian then
        AOCHStatus:SetHidden(false)
        AOCHStatusBossCarrionTrackerLabel:SetHidden(false)
        AOCHStatusBossCarrionTrackerLabelValue:SetHidden(false)
      end
    end
    if changeType == EFFECT_RESULT_FADED then
      AOCH.status.carrion_stacks_data[unitId] = 0
    end
  end

  if AOCH.status.is_Hall_of_Fleshcraft then
    ------------- gather channeler - do it here in addition to CombatEvents - the faster we get an id - more precise portal percent display will be - every tick matters
    if AOCH.savedVariables.show_fleshcraft_portal_percent and string.match(unitName, AOCH.data.channeler_name) then
      if AOCH.status.channelers_alive[unitId] == nil then
        AOCH.status.channelers_alive[unitId] = AOCH.GetChannelerHP()
      end
    end
    ------------- same for daedroths
    if AOCH.savedVariables.show_daedroth_spawn and isTank and string.match(unitName, AOCH.data.daedroth_name) ~= nil then
      if AOCH.status.spawned_daedroths[unitId] == nil then
        AOCH.status.spawned_daedroths[unitId] = true
        CombatAlerts.Alert(nil, "Daedroth Spawned !", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
      end
    end
  end

  if AOCH.status.is_jynorah_and_skorkhif then

    ------------------- Gather titan ids ----------- same as in CombatEvent() - the earlier we get it - the better
    if AOCH.savedVariables.show_jynorah_titan_hp then
      if string.match(unitName, AOCH.data.myrinax_name) then
        if AOCH.status.myrinax_ids[unitId] == nil then
          AOCH.status.myrinax_ids[unitId] = 0
        end
      elseif string.match(unitName, AOCH.data.valneer_name) then
        if AOCH.status.valneer_ids[unitId] == nil then
          AOCH.status.valneer_ids[unitId] = 0
        end
      end
    end

    if AOCH.status.is_hm_boss then
      ---------------------------- Enfeeblement debuff gained & boss swap alert
      if abilityId == AOCH.data.jynorah_blazing_enfeeblement then
        if changeType == EFFECT_RESULT_GAINED then
          -- If player gets the debuff
          if unitTag == "player" then
            AOCH.status.jynorah_got_blazing_enfeeblement = true
            AOCH.status.jynorah_got_sparking_enfeeblement = false
            if AOCH.savedVariables.show_jynorah_enfeeblement_swap and isDPS then
              CombatAlerts.Alert(nil, "Move to Blue Boss", 0x03AFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
            end
          -- If someone else gets enfeeblement but player is a DD and is dead - swap the color so an appropriate alert will spawn when ressurected
          elseif not AOCH.status.enfeeblement_swapped_while_dead and isDPS and IsUnitDead("player") then
            if AOCH.status.jynorah_got_blazing_enfeeblement then
              AOCH.status.jynorah_got_blazing_enfeeblement = false
              AOCH.status.jynorah_got_sparking_enfeeblement = true
              AOCH.status.enfeeblement_swapped_while_dead = true
            elseif AOCH.status.jynorah_got_sparking_enfeeblement then
              AOCH.status.jynorah_got_sparking_enfeeblement = false
              AOCH.status.jynorah_got_blazing_enfeeblement = true
              AOCH.status.enfeeblement_swapped_while_dead = true
            end
          end
        end
      end

      if abilityId == AOCH.data.jynorah_sparkling_enfeeblement then
        if changeType == EFFECT_RESULT_GAINED then
          -- If player gets the debuff
          if unitTag == "player" then
            AOCH.status.jynorah_got_sparking_enfeeblement = true
            AOCH.status.jynorah_got_blazing_enfeeblement = false
            if AOCH.savedVariables.show_jynorah_enfeeblement_swap and isDPS then
              CombatAlerts.Alert(nil, "Move to Red Boss", 0xCC3B0E, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
            end
          -- If someone else gets enfeeblement but player is a DD and is dead - swap the color so an appropriate alert will spawn when ressurected
          elseif not AOCH.status.enfeeblement_swapped_while_dead and isDPS and IsUnitDead("player") then
            if AOCH.status.jynorah_got_blazing_enfeeblement then
              AOCH.status.jynorah_got_blazing_enfeeblement = false
              AOCH.status.jynorah_got_sparking_enfeeblement = true
              AOCH.status.enfeeblement_swapped_while_dead = true
            elseif AOCH.status.jynorah_got_sparking_enfeeblement then
              AOCH.status.jynorah_got_sparking_enfeeblement = false
              AOCH.status.jynorah_got_blazing_enfeeblement = true
              AOCH.status.enfeeblement_swapped_while_dead = true
            end
          end
        end
      end
      
    end

  end

  if AOCH.status.is_kazpian then
    ------------------------------- Tether Alert
    if changeType == EFFECT_RESULT_GAINED and unitTag == "player" and (abilityId == AOCH.data.kazpian_chains_debuff_1 or abilityId == AOCH.data.kazpian_chains_debuff_2) and AOCH.savedVariables.show_kazpian_chains then
      AOCHRedAlertLabel:SetText("Tether on YOU!")
    end

    ----------------------------------- Portal phase start/end
    if abilityId == AOCH.data.kazpian_portal_phase_buff_id then
      if changeType == EFFECT_RESULT_GAINED then
        AOCH.status.kazpian_portal_ongoing = true
        AOCHStatusBossCarrionTrackerLabel:SetHidden(false)
        AOCHStatusBossCarrionTrackerLabelValue:SetHidden(false)
      elseif changeType == EFFECT_RESULT_FADED then
        AOCH.status.kazpian_portal_ongoing = false
        AOCHStatusBossCarrionTrackerLabel:SetHidden(true)
        AOCHStatusBossCarrionTrackerLabelValue:SetHidden(true)
      end
    end
  end
  
end