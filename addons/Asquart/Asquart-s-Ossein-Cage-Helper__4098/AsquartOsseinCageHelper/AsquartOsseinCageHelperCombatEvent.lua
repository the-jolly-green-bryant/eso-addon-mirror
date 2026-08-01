AOCH = AOCH or {}
local AOCH = AOCH

function AOCH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  local isDPS, isHeal, isTank = GetPlayerRoles()
  
  --d(abilityName .. " " .. tostring(abilityId))

    -------------------- Caustic carrion purge
    if result == ACTION_RESULT_EFFECT_GAINED and AOCH.data.carrion_shield_cast_ids[abilityId] then
      AOCH.status.carrion_stacks_data = {}
      if AOCH.savedVariables.block_carrion_synergy then
        AOCH.status.carrion_shield_blocked = true
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetCarrionBlock", AOCH.savedVariables.carrion_synergy_block_time,
            function()
              EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetCarrionBlock")
              AOCH.status.carrion_shield_blocked = false
            end)
      end
    end

    -------------------- Remove dead people from carrion tracking
    if AOCH.savedVariables.show_boss_carrion_stacks and (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and AOCH.status.carrion_stacks_data[targetUnitId] ~= nil then
      AOCH.status.carrion_stacks_data[targetUnitId] = nil
    end

  --------------- Trash alerts
  ---------------------------------- Spike Cage alert
  if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.deadraiser_spike_cage and AOCH.savedVariables.show_deadraiser_spike_cage then
    if targetUnitId ~= nil and AOCH.units[targetUnitId] ~= nil then
      local unitTag = AOCH.units[targetUnitId].tag
      local _, unitX, unitY, unitZ = GetUnitWorldPosition(unitTag)
      local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
      local distance = AOCH.GetDist(unitX,unitY,unitZ,playerX,playerY,playerZ)
      if distance < 400 then
        CombatAlerts.Alert(nil, "Spike Cage !", 0xFF0000FF, SOUNDS.DUEL_START, 3000)
      end
    end
  end

  if string.match(sourceName, AOCH.data.spectral_revenant_name) ~= nil and targetType == COMBAT_UNIT_TYPE_PLAYER and AOCH.savedVariables.show_deadraiser_spectral_revenant then
    AOCHStatus:SetHidden(false)
    AOCHStatusRedWarningLabel2:SetText("REVENANT ON YOU!")
    AOCHStatusRedWarningLabel2:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideRevenantText", 3000,
                                    function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideRevenantText")
                                      AOCHStatus:SetHidden(true)
                                      AOCHStatusRedWarningLabel2:SetHidden(true)
                                    end)
  end

  if abilityId == AOCH.data.spectral_revenge_id and result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and AOCH.savedVariables.show_deadraiser_spectral_revenant then
    AOCHRedAlertLabel:SetText("DODGE REVENANT!")
    PlaySound(SOUNDS.DUEL_START)
    AOCHRedAlertLabel:SetHidden(false)
    AOCHRedAlert:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideRevenantDodgeText", 2000,
                                    function()
                                   EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideRevenantDodgeText")
                                   AOCHRedAlertLabel:SetHidden(true)
                                   AOCHRedAlert:SetHidden(true)
                                    end)
  end

  if abilityId == AOCH.data.channeler_heavy_id and result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and AOCH.savedVariables.show_channeler_heavy_alert then
    if not isTank then
      PlaySound(SOUNDS.DUEL_START)
    end
  end

  if AOCH.savedVariables.show_carrion_reaper_corvid_swarm and abilityId == AOCH.data.carrion_reaper_corvid_swarm_cast and result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER then
    if AOCH.status.corvid_swarm_alert_id == nil then
      PlaySound(SOUNDS.DUEL_START)
      AOCH.status.corvid_swarm_alert_id = CombatAlerts.AlertCast(abilityId, "Swarm on you, kite!" , 3000, { -3, 1, false } )
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "CorvidSwarmAlertRemogved", 2000,
                                    function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "CorvidSwarmAlertRemogved")
                                    AOCH.status.corvid_swarm_alert_id = nil
                                  end)
    end
  end

  ------------------------------- Abductor alerts
  if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.abduct_cast_id and AOCH.savedVariables.show_abduct_cast_alert then
    AOCH.status.abductor_cast_data[sourceUnitId] = true
    AOCHStatus:SetHidden(false)
    AOCHStatusRedWarningLabel2:SetText("Bash Abductor!")
    AOCHStatusRedWarningLabel2:SetHidden(false)
    PlaySound(SOUNDS.DUEL_START)
    EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "AbductEnded", 9000,
                                    function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "AbductEnded")
                                    if AOCH.status.abductor_cast_data[sourceUnitId] ~= nil then
                                      AOCH.status.abductor_cast_data[sourceUnitId] = nil
                                      AOCHStatus:SetHidden(true)
                                      AOCHStatusRedWarningLabel2:SetHidden(true)
                                    end
                                    end)
  end

  if result == ACTION_RESULT_DIED or result == ACTION_RESULT_STUNNED or result == ACTION_RESULT_INTERRUPT or result == ACTION_RESULT_DIED_XP then
    if AOCH.status.abductor_cast_data[targetUnitId] ~= nil then
      AOCHStatus:SetHidden(true)
      AOCHStatusRedWarningLabel2:SetHidden(true)
      AOCH.status.abductor_cast_data[targetUnitId] = nil
    end
  end

  -------------------------- Abducted
  if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.abduct_cast_end_id then
    if AOCH.status.abductor_cast_data[sourceUnitId] ~= nil then
      AOCH.status.abductor_cast_data[sourceUnitId] = nil
      AOCHStatus:SetHidden(true)
      AOCHStatusRedWarningLabel2:SetHidden(true)
    end
  end

  -------------------- Remove interrupted cast alerts
  if result == ACTION_RESULT_DIED or result == ACTION_RESULT_STUNNED or result == ACTION_RESULT_INTERRUPT or result == ACTION_RESULT_DIED_XP then
    if AOCH.status.cast_alert_ids[targetUnitId] ~= nil then
      CombatAlerts.CastAlertsStop(AOCH.status.cast_alert_ids[targetUnitId])
      AOCH.status.cast_alert_ids[targetUnitId] = nil
    end
  end
  
  --------------- Gedna Relvel
  if AOCH.status.is_Gedna_Relvel then
    ------------------ reset phantasms phase
    if result == ACTION_RESULT_EFFECT_FADED and abilityId == AOCH.data.summon_phantasms_id then
      AOCH.status.witch_is_first_countdown = false
      AOCH.status.witch_last_phantasms_time = GetGameTimeSeconds()
    end

    --------------------------- barrage alert
    if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.phantasmal_barrage_id then
      if not AOCH.status.phantasmal_barrage_alert_playing then 
        AOCH.status.phantasmal_barrage_alert_playing = true
        CombatAlerts.AlertCast(abilityId, "Phantasmal Barrage", 2000, { -3, 1, true })
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "PhantasmalBarrageEnded", 3000,
                                    function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "PhantasmalBarrageEnded")
                                    AOCH.status.phantasmal_barrage_alert_playing = false
                                    end)
      end
    end
  end

  --------------- Tortured Ranyu
  if AOCH.status.is_Tortured_Ranyu then
    ------------------ reset jump_timer
    if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.ranyu_jump_id then
      AOCH.status.ranyu_has_jumped = true
    end
  end

  ---------------- Blooddrinker Thisa
  if AOCH.status.is_Blood_Drinker_Thisa then
    if result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.thisa_blood_dive then
      CombatAlerts.Alert(nil, "Blood Dive", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 1500)
    end
  end

  ------------------------------------ Hall of Fleshcraft ----------------------------------------

  if AOCH.status.is_Hall_of_Fleshcraft then

    --------------------------- Play Harvester alert
    if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and string.match(sourceName, AOCH.data.harvester_name) ~= nil
      and (abilityId == AOCH.data.harvester_ethereal_burst_1 or abilityId == AOCH.data.harvester_ethereal_burst_2)
      and AOCH.savedVariables.show_harvester_aggro
      and not AOCH.status.harvesterAlertPlaying then
      if isDPS or isHeal then
        AOCH.status.harvesterAlertPlaying = true
        AOCHRedAlertLabel:SetText("HARVESTER ATTACKS YOU!")
        AOCHRedAlertLabel:SetHidden(false)
        AOCHRedAlert:SetHidden(false)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideHarvesterText", 2500,
                                        function()
                                        EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideHarvesterText")
                                        AOCHRedAlertLabel:SetHidden(true)
                                        AOCHRedAlert:SetHidden(true)
                                        AOCH.status.harvesterAlertPlaying = false
                                        end)
      end
    end

    ------------- Place ogrim icon on charge
    if AOCH.savedVariables.show_ogrim_charge_alert and abilityId == AOCH.data.ogrim_charge and result == ACTION_RESULT_BEGIN then
      if AOCH.units[targetUnitId] ~= nil then
        local unitTag = AOCH.units[targetUnitId].tag
        local _, unitX, unitY, unitZ = GetUnitWorldPosition(unitTag)
        local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
        local distance = AOCH.GetDist(unitX,unitY,unitZ,playerX,playerY,playerZ)
        if distance < 400 then
          CombatAlerts.Alert(nil, "Ogrim Charge !", 0xFFFFFF00, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
        end

        if AOCH.hasOSI() then
          local icon = OSI.CreatePositionIcon(
            unitX, unitY, unitZ,
            AOCH.icons_data.ogrim_texture,
            OSI.GetIconSize())
          AOCH.status.ogrim_charge_alerts[icon] = true
          EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "RemoveOgrimIcon", 2000,
                            function()
                            EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "RemoveOgrimIcon")
                                OSI.DiscardPositionIcon(icon)
                            end)
        end
      end
    end

    ------------- gather fleshspawns
    if AOCH.status.show_fleshspawn_counter and string.match(targetName, AOCH.data.fleshspawn_name) then
      if AOCH.status.fleshspawns_alive[targetUnitId] == nil then
        AOCH.status.fleshspawns_alive[targetUnitId] = true
      end
    end
    if AOCH.status.show_fleshspawn_counter and string.match(sourceName, AOCH.data.fleshspawn_name) then
      if AOCH.status.fleshspawns_alive[sourceUnitId] == nil then
        AOCH.status.fleshspawns_alive[sourceUnitId] = true
      end
    end

    ------------- gather channelers
    if AOCH.savedVariables.show_fleshcraft_portal_percent and string.match(targetName, AOCH.data.channeler_name) then
      if AOCH.status.channelers_alive[targetUnitId] == nil then
        AOCH.status.channelers_alive[targetUnitId] = AOCH.GetChannelerHP()
      end
    end
    if AOCH.savedVariables.show_fleshcraft_portal_percent and string.match(sourceName, AOCH.data.channeler_name) then
      if AOCH.status.channelers_alive[sourceUnitId] == nil then
        AOCH.status.channelers_alive[sourceUnitId] = AOCH.GetChannelerHP()
      end
    end
    
    ------------- gather daedroths
    if AOCH.savedVariables.show_daedroth_spawn and isTank and string.match(targetName, AOCH.data.daedroth_name) ~= nil then
      if AOCH.status.spawned_daedroths[targetUnitId] == nil then
        AOCH.status.spawned_daedroths[targetUnitId] = true
        CombatAlerts.Alert(nil, "Daedroth Spawned !", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
      end
    end

    if AOCH.savedVariables.show_fleshspawn_counter and result ~= ACTION_RESULT_EFFECT_GAINED and abilityId == AOCH.data.abomination_spawn_buff then --------------- Abo spawned. Fires twice per abo spawn for some reason
      AOCH.status.num_fleshspawn = AOCH.status.num_fleshspawn - 1
      if AOCH.status.num_fleshspawn < 0 then
        AOCH.status.num_fleshspawn = 0
      end
      AOCH.UpdateFleshspawnCounter()
    end

    if AOCH.savedVariables.show_fleshspawn_counter and result == ACTION_RESULT_EFFECT_GAINED and abilityId == AOCH.data.fleshspawn_fleshiplasm_buff_id then --------------- Fleshiplasm gained
    if AOCH.status.fleshspawns_alive[targetUnitId] == nil then
        AOCH.status.fleshspawns_alive[targetUnitId] = AOCH.GetFleshspawnHP()
        AOCH.status.num_fleshspawn = AOCH.status.num_fleshspawn + 1
        AOCH.UpdateFleshspawnCounter()
      end
    end

    if AOCH.savedVariables.show_fleshspawn_counter and (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and AOCH.status.fleshspawns_alive[targetUnitId] ~= nil then -------------- Fleshspawn died
      AOCH.status.fleshspawns_alive[targetUnitId] = nil
      AOCH.status.num_fleshspawn = AOCH.status.num_fleshspawn - 1
      if AOCH.status.num_fleshspawn < 0 then
        AOCH.status.num_fleshspawn = 0
      end
      AOCH.UpdateFleshspawnCounter()
    end
    

    ---------------------------- Accumulate Channeler damage
    if AOCH.savedVariables.show_fleshcraft_portal_percent
      and not AOCH.status.channeler_immune
      and AOCH.status.channelers_alive[targetUnitId] ~= nil
      and AOCH.data.hpDamageActionResults[result] ~= nil then

      AOCH.status.channelers_alive[targetUnitId] = AOCH.status.channelers_alive[targetUnitId] - hitValue
      AOCH.status.fleshcraft_portal_percent = AOCH.status.channelers_alive[targetUnitId] / AOCH.status.current_channeler_max_hp

      if AOCH.status.channelers_alive[targetUnitId] <= 0 then --------------- Channeler died

      end
    end

    if AOCH.savedVariables.show_fleshcraft_portal_percent and (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and AOCH.status.channelers_alive[targetUnitId] ~= nil then
      AOCH.status.channelers_alive[targetUnitId] = nil
      if not AOCH.status.initial_channeler_dead then
        AOCH.status.initial_channeler_dead = true
        AOCH.status.channeler_immune = true
        AOCH.status.current_channeler_hp = AOCH.GetChannelerHP()
        AOCH.status.fleshcraft_portal_percent = 1
        AOCH.status.channelers_alive[targetUnitId] = nil
        AOCHStatusRedWarningLabel1:SetHidden(true)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "RemoveChannelerImmune", 4000,
                                      function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "RemoveChannelerImmune")
                                      AOCH.status.channeler_immune = false
                                      end)
      else
        AOCHStatusRedWarningLabel1:SetHidden(true)
        AOCH.status.fleshcraft_portal_UI_hidden = true
        AOCH.status.channeler_immune = true
        AOCH.status.current_channeler_hp = AOCH.GetChannelerHP()
        AOCH.status.fleshcraft_portal_percent = 1
        AOCH.status.channelers_alive[targetUnitId] = nil
        AOCHStatusRedWarningLabel2:SetHidden(false)
        AOCHStatusRedWarningLabel2:SetText("Portal Done !")
        PlaySound(SOUNDS.OBJECTIVE_DISCOVERED)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "RemovePortalDone", 4000,
                                      function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "RemovePortalDone")
                                      AOCHStatusRedWarningLabel2:SetHidden(true)
                                      AOCH.status.channeler_immune = false
                                      end)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "RemoveChannelerImmune", 4000,
                                      function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "RemoveChannelerImmune")
                                      AOCH.status.channeler_immune = false
                                      end)
      end
    end

    --------------------------- Play Expellant alert
    if AOCH.savedVariables.show_effluvial_expellant_block and result == ACTION_RESULT_BEGIN and abilityId == AOCH.data.shaper_of_flesh_effluvial_expellant then
      AOCHPurpleAlert:SetHidden(false)
      AOCHPurpleAlertLabel:SetHidden(false)
      AOCHPurpleAlertLabel:SetText("Expellant Block!")
      PlaySound(SOUNDS.DUEL_START)
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideExpellantText", 2500,
                                        function()
                                        EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideExpellantText")
                                        AOCHPurpleAlert:SetHidden(true)
                                        end)
    end

  end
  ------------------------------------ Hall of Fleshcraft ----------------------------------------

  ------------------------------------ Jynorah and Skorknif --------------------------------------
  if AOCH.status.is_jynorah_and_skorkhif then

    ------------------------------ Titanic Leap
    if AOCH.savedVariables.show_jynorah_titanic_leap and AOCH.data.titanic_leap_ids[abilityId] and result == ACTION_RESULT_BEGIN then
      CombatAlerts.Alert(nil, "Titanic Leap", 0xCC8747FF, SOUNDS.DUEL_START, 2500)
    end

    ------------------------------ Curse Cast
    if (abilityId == AOCH.data.jynorah_curse_cast_id or abilityId == AOCH.data.skorknif_curse_cast_id) and not AOCH.status.jynorah_curse_ongoing then
      AOCH.status.jynorah_curse_ongoing = true
      AOCH.status.jynorah_next_curse = GetGameTimeSeconds() + AOCH.data.jynorah_curse_consecutive_countdown
      PlaySound(SOUNDS.DUEL_START)
      AOCHRedAlertLabel:SetText("Curse !")
      AOCHRedAlertLabel:SetHidden(false)
      AOCHRedAlert:SetHidden(false)
      ---------------- remove alert
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideCurseAlert", 3000,
                                  function()
                                   EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideCurseAlert")
                                   AOCHRedAlertLabel:SetHidden(true)
                                   AOCHRedAlert:SetHidden(true)
                                  end)
      ------------------- set curse ongoing to false
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "SetCurseEnded", 9000,
                                  function()
                                   EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "SetCurseEnded")
                                   AOCH.status.jynorah_curse_ongoing = false
                                  end)
    end



    ------------------------------ Titanic Clash start
    if (abilityId == AOCH.data.jynorah_titanic_clash_id or abilityId == AOCH.data.skorknif_titanic_clash_id) and not AOCH.status.jynorah_titanic_clash_ongoing then
      AOCH.status.jynorah_titanic_clash_ongoing = true
      AOCH.status.jynorah_titanic_clash_just_started = true
      AOCH.status.blazing_atronachs_alive = {}
      AOCH.status.sparking_atronachs_alive = {}

      if AOCH.savedVariables.show_boss_carrion_stacks then
        AOCHStatusBossCarrionTrackerLabel:SetHidden(false)
        AOCHStatusBossCarrionTrackerLabelValue:SetHidden(false)
      end

      AOCHStatusJynorahCurseTimerLabel:SetHidden(true)
      AOCHStatusJynorahCurseTimerLabelValue:SetHidden(true)

      ------------------- set curse ongoing to false
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetTitanicClashStart", 10000,
            function()
              EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetTitanicClashStart")
              AOCH.status.jynorah_titanic_clash_just_started = false
            end)

      if AOCH.status.is_hm_boss and AOCH.savedVariables.show_jynorah_portal_color then
        if AOCH.status.jynorah_got_blazing_enfeeblement then
          CombatAlerts.Alert(nil, "Go Blue Portal", 0x3399FFD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        elseif AOCH.status.jynorah_got_sparking_enfeeblement then
          CombatAlerts.Alert(nil, "Go Red Portal", 0xFF5733D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        end
      end

      AOCHYellowAlert:SetHidden(false)
      AOCHYellowAlertLabel:SetHidden(false)
      if AOCH.status.current_jyronah_percent > AOCH.status.current_skorknif_percent then
        AOCHYellowAlertLabel:SetColor(0.909,0.494,0.082,0.85)
        AOCHYellowAlertLabel:SetText("Skorkhif & Valneer lose")
        AOCH.status.skorknif_lost_portal = true
      else
        AOCHYellowAlertLabel:SetColor(0.141,0.141,0.788,0.85)
        AOCHYellowAlertLabel:SetText("Jyronah & Myrinax lose")
        AOCH.status.jynorah_lost_portal = true
      end
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideLoseAlert", 4000,
                                  function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideLoseAlert")
                                    AOCHYellowAlertLabel:SetHidden(true)
                                    AOCHYellowAlertLabel:SetColor(0.929,0.835,0.101,0.85)
                                  end)
    end

    --------------------------- Titanic Clash end ----------------- moved to EffectChanged()
    if AOCH.status.jynorah_titanic_clash_ongoing
      and not AOCH.status.jynorah_titanic_clash_just_started
      and AOCH.data.hpDamageActionResults[result] ~= nil
      and (string.match(targetName, AOCH.data.jynorah_name) ~= nil or string.match(targetName, AOCH.data.skorknif_name) ~= nil) then

      AOCH.status.jynorah_titanic_clash_ongoing = false

      if isDPS and AOCH.savedVariables.show_jynorah_enfeeblement_swap then
        if AOCH.status.jynorah_got_blazing_enfeeblement then
          CombatAlerts.Alert(nil, "Go to Blue Boss", 0x3399FFD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        elseif AOCH.status.jynorah_got_sparking_enfeeblement then
          CombatAlerts.Alert(nil, "Go to Red Boss", 0xFF5733D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        end
      end

      -------- start curse countdows
      local curseCountdown = AOCH.data.jynorah_curse_initial_countdown
      if AOCH.status.is_hm_boss then
        curseCountdown = AOCH.data.jynorah_curse_initial_countdown_hm
      end
      AOCH.status.jynorah_next_curse = GetGameTimeSeconds() + curseCountdown
      -------- restore curse labels
      if AOCH.savedVariables.show_jynorah_curse_timer then
        AOCHStatusJynorahCurseTimerLabelValue:SetHidden(false)
        AOCHStatusJynorahCurseTimerLabel:SetHidden(false)
      end
      
      AOCHStatusBossCarrionTrackerLabel:SetHidden(true)
      AOCHStatusBossCarrionTrackerLabelValue:SetHidden(true)
    end

    -------------------- Surge alert
    if targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_BEGIN then
      if abilityId == AOCH.data.jynorah_coldflame_surge then
        CombatAlerts.Alert(nil, "Surge, Kite !", 0x3399FFD9, SOUNDS.DUEL_START, 3000)
      elseif abilityId == AOCH.data.skorknif_brimstone_surge then
        CombatAlerts.Alert(nil, "Surge, Kite !", 0xFF5733D9, SOUNDS.DUEL_START, 3000)
      end
    end

    if AOCH.status.is_hm_boss then

      ----------------------- Reflective Scales alerts
      if not AOCH.status.reflective_scales_valneer_playing and abilityId == AOCH.data.reflective_scales_valneer and targetType == COMBAT_UNIT_TYPE_PLAYER then
        AOCH.status.reflective_scales_valneer_playing = true
        CombatAlerts.Alert(nil, "Reflective Scales", 0xFF5733D9, nil, 2400)
        LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetReflectValneer", 2500,
                                    function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetReflectValneer")
                                      AOCH.status.reflective_scales_valneer_playing = false
                                    end)
      end

      -------------------- Titan Breath
      if AOCH.savedVariables.show_jynorah_titan_breath and abilityId == AOCH.data.valneer_breath_id and result == ACTION_RESULT_BEGIN then
        CombatAlerts.Alert(nil, "Titan Breath", 0x3399FFD9, SOUNDS.DUEL_START, 2500)
      end

      if AOCH.savedVariables.show_jynorah_titan_breath and abilityId == AOCH.data.myrinax_breath_id and result == ACTION_RESULT_BEGIN then
        CombatAlerts.Alert(nil, "Titan Breath", 0x3399FFD9, SOUNDS.DUEL_START, 2500)
      end
  
      if not AOCH.status.reflective_scales_myrinax_playing and abilityId == AOCH.data.reflective_scales_myrinax and targetType == COMBAT_UNIT_TYPE_PLAYER then
        AOCH.status.reflective_scales_myrinax_playing = true
        CombatAlerts.Alert(nil, "Reflective Scales", 0x3399FFD9, nil, 2400)
        LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetReflectMyrinax", 2500,
                                    function()
                                      EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetReflectMyrinax")
                                      AOCH.status.reflective_scales_myrinax_playing = false
                                    end)
      end

      ------------------------------ Heatray Alerts
      if AOCH.savedVariables.show_jynorah_heatray and abilityId == AOCH.data.jynorah_blazing_heat_ray_cast_id and result == ACTION_RESULT_BEGIN and not isTank and not AOCH.status.jynorah_got_blazing_enfeeblement then
        CombatAlerts.Alert(nil, "Heat Ray, Stack!", 0xFF5733D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 4000)
      end

      if AOCH.savedVariables.show_jynorah_heatray and abilityId == AOCH.data.jynorah_sparking_heat_ray_cast_id and result == ACTION_RESULT_BEGIN and not isTank and not AOCH.status.jynorah_got_sparking_enfeeblement then
        CombatAlerts.Alert(nil, "Heat Ray, Stack!", 0x3399FFD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 4000)
      end

      ------------------------------- Process atronachs and seeking surge
      if AOCH.savedVariables.show_jynorah_seeking_surge_alert and not isTank and not AOCH.status.jynorah_titanic_clash_ongoing and abilityId == AOCH.data.jynorah_seeking_flames_cast then
        if AOCH.status.myrinax_ids[targetUnitId] ~= nil then -------------- Blazing flames spawned
          if not AOCH.status.jynorah_got_blazing_enfeeblement then ---------------- play alert if applicable
            CombatAlerts.Alert(nil, "Get Seeking Fire", 0xFF5733D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
          end
        elseif AOCH.status.valneer_ids[targetUnitId] then
          if not AOCH.status.jynorah_got_sparking_enfeeblement then ---------------- play alert if applicable
            CombatAlerts.Alert(nil, "Get Seeking Fire", 0x3399FFD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
          end
        end
      end

    end
   
    ----------------------------- Gather titans IDs
    if AOCH.savedVariables.show_jynorah_titan_hp then
      if string.match(sourceName, AOCH.data.myrinax_name) then
        if AOCH.status.myrinax_ids[sourceUnitId] == nil then
          AOCH.status.myrinax_ids[sourceUnitId] = 0
        end
      elseif string.match(targetName, AOCH.data.myrinax_name) then
        if AOCH.status.myrinax_ids[targetUnitId] == nil then
          AOCH.status.myrinax_ids[targetUnitId] = 0
        end
      elseif string.match(sourceName, AOCH.data.valneer_name) then
        if AOCH.status.valneer_ids[sourceUnitId] == nil then
          AOCH.status.valneer_ids[sourceUnitId] = 0
        end
      elseif string.match(targetName, AOCH.data.valneer_name) then
        if AOCH.status.valneer_ids[targetUnitId] == nil then
          AOCH.status.valneer_ids[targetUnitId] = 0
        end
      end
    end

    --------------------- Accumulate Valneer Damage
    if AOCH.savedVariables.show_jynorah_titan_hp
      and AOCH.status.valneer_ids[targetUnitId] ~= nil
      and AOCH.data.hpDamageActionResults[result] ~= nil then
      AOCH.status.valneer_ids[targetUnitId] = AOCH.status.valneer_ids[targetUnitId] + hitValue
    end

        --------------------- Accumulate Myrinax Damage
    if AOCH.savedVariables.show_jynorah_titan_hp
      and AOCH.status.myrinax_ids[targetUnitId] ~= nil
      and AOCH.data.hpDamageActionResults[result] ~= nil then
      AOCH.status.myrinax_ids[targetUnitId] = AOCH.status.myrinax_ids[targetUnitId] + hitValue
    end

  end
  ------------------------------------ Jynorah and Skorknif --------------------------------------

  ------------------------------------- Overfiend Kazpian -----------------------------------------
  if AOCH.status.is_kazpian then

    ---------------------- agonizer bomb spawn
    if not AOCH.status.kazpian_bombs_spawned and abilityId == AOCH.data.agonizer_bomb_spawn_cast_id and AOCH.savedVariables.show_kazpian_bombs then
      AOCH.status.kazpian_bombs_spawned = true
      AOCHYellowAlertLabel:SetText("Bombs spawned")
      AOCHYellowAlertLabel:SetHidden(false)
      AOCHYellowAlert:SetHidden(false)
      PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideBombsAlert", 3000,
                                  function()
                                   EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideBombsAlert")
                                   AOCHYellowAlertLabel:SetHidden(true)
                                   AOCHYellowAlert:SetHidden(true)
                                  end)
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetBombsSpawn", 20000,
                                  function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetBombsSpawn")
                                    AOCH.status.kazpian_bombs_spawned = false
                                  end)
    end

    --------------------- Tether Alert
    if abilityId == AOCH.data.kazpian_chains_cast and result == ACTION_RESULT_BEGIN and AOCH.savedVariables.show_kazpian_chains then
      AOCHRedAlertLabel:SetText("Tether !")
      AOCHRedAlertLabel:SetHidden(false)
      AOCHRedAlert:SetHidden(false)
      PlaySound(SOUNDS.OBJECTIVE_DISCOVERED)
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideTetherText", 4000,
                                      function()
                                     EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideTetherText")
                                     AOCHRedAlertLabel:SetHidden(true)
                                     AOCHRedAlert:SetHidden(true)
                                      end)
    end

    ------------------------- Immolating Sphere alert
    if AOCH.savedVariables.show_immolating_sphere and abilityId == AOCH.data.immolating_sphere and targetType == COMBAT_UNIT_TYPE_PLAYER then
      CombatAlerts.Alert(nil, "Immolating Sphere", 0xFF5733D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2400)
    end

    ------------------------- Kazpian jump
    if AOCH.savedVariables.show_kazpian_jump and not AOCH.savedVariables.show_kazpian_jump_enraged_only and abilityId == AOCH.data.kazpian_jump and result == ACTION_RESULT_BEGIN then
      local currentTime = GetGameTimeSeconds()
      local time_since_last_jump = currentTime - AOCH.status.kazpian_last_jump_time
      if time_since_last_jump > 6 then
        AOCH.status.kazpian_last_jump_time = currentTime
        CombatAlerts.Alert(nil, "Boss Jump", 0xFF5733D9, SOUNDS.OBJECTIVE_DISCOVERED, 2000)
      end
    end

    ------------------------- Kazpian enraged jump
    if AOCH.savedVariables.show_kazpian_jump and abilityId == AOCH.data.kazpian_jump_enraged and result == ACTION_RESULT_BEGIN then
      local currentTime = GetGameTimeSeconds()
      local time_since_last_jump = currentTime - AOCH.status.kazpian_last_enraged_jump_time
      if time_since_last_jump > 6 then
        AOCH.status.kazpian_last_enraged_jump_time = currentTime
        CombatAlerts.Alert(nil, "Boss Jump Enraged", 0xFF0000FF, SOUNDS.DUEL_START, 2000)
      end
    end

    ------------------------- Biting Blaze alert

    if AOCH.savedVariables.show_kazpian_curse_alert and AOCH.data.kazpian_curse_cast_ids[abilityId] ~= nil and not AOCH.status.kazpian_curse_spawned then
      AOCH.status.kazpian_curse_spawned = true
      if AOCH.savedVariables.show_kazpian_curse_alert_only_player then
        if targetType == COMBAT_UNIT_TYPE_PLAYER and isDPS then
          CombatAlerts.Alert(nil, "Blaze on you, STACK", 0xFF0000FF, nil, 3000)
          LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
        end
      else
        if targetType == COMBAT_UNIT_TYPE_PLAYER and isDPS then
          CombatAlerts.Alert(nil, "Blaze on you, STACK", 0xFF0000FF, nil, 3000)
          LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
        else
          CombatAlerts.Alert(nil, "Biting Blaze starts", 0xFF0000FF, nil, 3000)
          LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
        end
      end
      EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ResetCurseSpawn", 3000,
                                  function()
                                    EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ResetCurseSpawn")
                                    AOCH.status.kazpian_curse_spawned = false
                                  end)
    end

    --------------------- frenzy tank swap
    if abilityId == AOCH.data.kazpian_frenzy_cast and not AOCH.status.kazpian_frenzy_alert_queued and AOCH.savedVariables.show_kazpian_frenzy_alert and isTank then
      AOCH.status.kazpian_frenzy_alert_queued = true
      if AOCH.savedVariables.show_kazpian_frenzy_timer then
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ShowSwapTimer", 5000,
                                      function()
                                     EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ShowSwapTimer")
                                     AOCHSwapAlertLabel:SetText("Swap in : 5")
                                     AOCHSwapAlertLabel:SetHidden(false)
                                     AOCHSwapAlert:SetHidden(false)
                                     AOCH.status.kazpian_frenzy_alert_playing = true
                                     AOCH.status.kazpian_frenzy_alert_start = GetGameTimeSeconds()
                                      end)
      else
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "ShowSwapAlert", 5000,
          function()
          EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "ShowSwapAlert")

          AOCHSwapAlertLabel:SetText("You should swap")
          AOCHSwapAlertLabel:SetHidden(false)
          AOCHSwapAlert:SetHidden(false)
          AOCH.status.kazpian_frenzy_alert_queued = false
          LibCombatAlerts.PlaySounds("SCRYING_ACTIVATE_BOMB", 10, nil)
          EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideSwapAlert", 3000,
              function()
              EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideSwapAlert")
              AOCHSwapAlertLabel:SetHidden(true)
              AOCHSwapAlert:SetHidden(true)
              end)
          end)
      end
    end

  end

end
