AOCH = AOCH or {}
local AOCH = AOCH

function AOCH.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()

  -- update icons even out of combat
  -- check if OdySupportIcons is active
  if AOCH.hasOSI() then
      -- [!] search for group members with custom timer
      for i = 1, GROUP_SIZE_MAX do
          local name = GetUnitDisplayName( "group" .. i )
          local icon = OSI.GetIconForPlayer( name )
          -- [!] update custom label if icon and timer are available
          if icon and icon.myTimer and timeSec <= icon.myTimer then
            local timeLeft = icon.myTimer - timeSec
            if timeLeft < 3 then
              if math.fmod(zo_floor(timeLeft*10), 10) < 5 then
                icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
              else
                icon.myLabel:SetColor(0.9,0,0,0.85)
              end
            end
            icon.myLabel:SetText(tostring(zo_floor(timeLeft)))
            AOCH.AdjustLabelForIcon(icon)
          end
      end
  end

  if IsUnitInCombat("boss1") or IsUnitInCombat("boss2") or IsUnitInCombat("boss3") or IsUnitInCombat("boss4") or IsUnitInCombat("boss5") or IsUnitInCombat("boss6") then
    AOCH.status.inCombat = true
  end

  if AOCH.status.is_trash then
    AOCH.SetTrashIcons()

    --------------------- Abductor Spawn
    if AOCH.savedVariables.show_abductor_spawn and AOCH.status.abductor_spawned and not AOCH.status.abductor_notification_played then
      CombatAlerts.Alert(nil, "Abductor Spawned !", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 4000)
      AOCH.status.abductor_notification_played = true
    end
  end

  if AOCH.savedVariables.show_boss_carrion_stacks or AOCH.savedVariables.block_carrion_synergy then
      local maxStacks = 0
      for _, stacksNum in pairs(AOCH.status.carrion_stacks_data) do
        if stacksNum > maxStacks then
          maxStacks = stacksNum
        end
      end
      AOCH.status.carrion_stacks_num = maxStacks
      AOCH.UpdateCarrionCounter()
  end

  --------------------------------   Genda Relvel
  if AOCH.status.is_Gedna_Relvel then
    AOCH.SetGlobalMiniBossIcons()
    -- Update phantasms phase timer
    if AOCH.savedVariables.show_witch_summon_phantasms_timer then
      local phantasms_timer = AOCH.data.witch_summon_phantasms_initial_countdown
      if not AOCH.status.witch_is_first_countdown then
        phantasms_timer = AOCH.data.witch_summon_phantasms_consecutive_countdown
      end
      local phase_duration = timeSec - AOCH.status.witch_last_phantasms_time

      if phase_duration < phantasms_timer then
        local time_to_phantasms = phantasms_timer - phase_duration
        local txtDuration = tostring(string.format("%.0f", time_to_phantasms))
        AOCHStatusGednaRelvelTimerLabelValue:SetText(txtDuration .. "s")
      else
        AOCHStatusGednaRelvelTimerLabelValue:SetText("In Progress")
      end
    end
  end

  -- Tortured Ranyu
  if AOCH.status.is_Tortured_Ranyu then
    AOCH.SetGlobalMiniBossIcons()
    -- Update phantasms phase timer
    if AOCH.savedVariables.show_ranyu_jump_timer then
      local jump_timer = AOCH.data.ranyu_jump_countdown
      if not AOCH.status.ranyu_has_jumped then
        jump_timer = AOCH.data.witch_summon_phantasms_consecutive_countdown
        local phase_duration = timeSec - AOCH.status.ranyu_last_jump_time

        if phase_duration < jump_timer then
          local time_to_jump = jump_timer - phase_duration
          local txtDuration = tostring(string.format("%.0f", time_to_jump))
          AOCHStatusGednaRelvelTimerLabelValue:SetText(txtDuration .. "s")
        else  
          AOCHStatusGednaRelvelTimerLabelValue:SetText("Jump Incoming")
        end
      else
        AOCHStatusGednaRelvelTimerLabel:SetHidden(true)
        AOCHStatusGednaRelvelTimerLabelValue:SetHidden(true)
      end
    end
  end

  -- Blood Drinker Thisa
  if AOCH.status.is_Blood_Drinker_Thisa then
    AOCH.SetGlobalMiniBossIcons()
  end

  ----------------------------------------- Hall of Fleshcraft----------------------------------------
  if AOCH.status.is_Hall_of_Fleshcraft then
    AOCH.SetHallOfFleshcraftIcons()

    if AOCH.savedVariables.show_fleshspawn_counter then
      AOCHStatus:SetHidden(false)
      AOCHStatusFleshSpawnCounterLabel:SetHidden(false)
      AOCHStatusFleshSpawnCounterLabelValue:SetHidden(false)
    end

    ------------------------------------ Process channeler damage and update UI------------------------------------------------
    if AOCH.savedVariables.show_fleshcraft_portal_percent then
      if AOCH.status.initial_channeler_dead then ------------ if initial channeler killed
        if AOCH.status.fleshcraft_portal_percent < 1 and AOCH.status.fleshcraft_portal_percent > 0 then --------- if portal in progress
          ------------------- Show UI
          if AOCH.status.fleshcraft_portal_UI_hidden then
            AOCHStatusRedWarningLabel1:SetHidden(false)
            AOCH.status.fleshcraft_portal_UI_hidden = false
          end
          ------------------- Update UI
          local txtPercent = tostring(string.format("%.1f", AOCH.status.fleshcraft_portal_percent * 100))
          AOCHStatusRedWarningLabel1:SetText("Portal percent : " .. txtPercent .. "%")
        elseif AOCH.status.fleshcraft_portal_percent <= 0 then --------------------- finish portal
          if not AOCH.status.fleshcraft_portal_UI_hidden then
            AOCHStatusRedWarningLabel1:SetHidden(true)
            AOCH.status.fleshcraft_portal_UI_hidden = true
          end
        end
      else -------------------- Initial channeler still alive
        if not AOCH.status.fleshcraft_portal_UI_hidden then
          AOCH.status.fleshcraft_portal_UI_hidden = true
          AOCHStatusRedWarningLabel1:SetHidden(true)
        end
      end
    end
    ------------------------------------ Process channeler damage and update UI------------------------------------------------


  end
  ----------------------------------------- Hall of Fleshcraft ----------------------------------------
  
  ----------------------------------------- Jynorah and Skorknif ---------------------------------------------------
  if AOCH.status.is_jynorah_and_skorkhif then
    AOCH.SetJynorahIcons()

    local jynorahHP, maxJynorahHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local skorknifHP, maxSkorknifHP, _ = GetUnitPower("boss2", POWERTYPE_HEALTH)

    AOCH.status.current_jyronah_percent = jynorahHP / maxJynorahHP
    AOCH.status.current_skorknif_percent = skorknifHP / maxSkorknifHP

    local totalBossPercent = (AOCH.status.current_jyronah_percent + AOCH.status.current_skorknif_percent) / 2

    local txtPercentNum = tostring(string.format("%.0f", AOCH.status.current_jyronah_percent * 100))
    ----------------- hp counters update
    if AOCH.savedVariables.show_jynorah_boss_hp then
      if AOCHStatusJynorahHpCounterLabel:IsHidden() then
        AOCHStatusJynorahHpCounterLabel:SetHidden(false)
      end
      AOCHStatusJynorahHpCounterLabel:SetText("Jynorah HP: " .. txtPercentNum .. "%")

      txtPercentNum = tostring(string.format("%.0f", AOCH.status.current_skorknif_percent * 100))
      if AOCHStatusSkorknifHpCounterLabel:IsHidden() then
        AOCHStatusSkorknifHpCounterLabel:SetHidden(false)
      end
      AOCHStatusSkorknifHpCounterLabel:SetText("Skorkhif HP: " .. txtPercentNum .. "%")

      if 0.354 < totalBossPercent and totalBossPercent < 0.754 then
        if AOCH.status.skorknif_lost_portal then
          AOCHStatusJynorahDamageIcon:SetHidden(false)
        end
        if AOCH.status.jynorah_lost_portal then
          AOCHStatusSkorknifDamageIcon:SetHidden(false)
        end
      else
        AOCHStatusJynorahDamageIcon:SetHidden(true)
        AOCHStatusSkorknifDamageIcon:SetHidden(true)
      end

    end

    ----------------- portal countdown
    if AOCH.savedVariables.show_jynorah_portal_countdown then
      local portalLeft = 0
      if 0.754 < totalBossPercent and totalBossPercent < 0.80  then
        portalLeft = (totalBossPercent - 0.754)*100
      elseif 0.354 < totalBossPercent and totalBossPercent < 0.4 then
        portalLeft = (totalBossPercent - 0.354)*100
      else
        portalLeft = 0
      end
      

      if portalLeft > 0 and not AOCH.status.jynorah_titanic_clash_ongoing then
        local txtPercentNum = tostring(string.format("%.1f", portalLeft))
        AOCHPurpleAlert:SetHidden(false)
        AOCHPurpleAlertLabel:SetHidden(false)
        AOCHPurpleAlertLabel:SetText("Portals in: " .. txtPercentNum .. "%")
      else
        AOCHPurpleAlert:SetHidden(true)
      end
    end

    ------------------------ Update curse timer
    if AOCH.savedVariables.show_jynorah_curse_timer and not AOCH.status.jynorah_titanic_clash_ongoing and AOCH.status.inCombat then
      local timeToNextCurse = AOCH.status.jynorah_next_curse - timeSec
      if not AOCH.status.inCombat then
        AOCHStatusJynorahCurseTimerLabelValue:SetText("Pending")
      elseif AOCH.status.jynorah_curse_ongoing then
        AOCHStatusJynorahCurseTimerLabelValue:SetText("In progress")
      elseif timeToNextCurse > 0 then
        local txtTime = tostring(string.format("%.0f", timeToNextCurse))
        AOCHStatusJynorahCurseTimerLabelValue:SetText(txtTime .. "s")
      else
        AOCHStatusJynorahCurseTimerLabelValue:SetText("Incoming")
      end
    end

    ----------------------- Update titans HP
    if AOCH.savedVariables.show_jynorah_titan_hp then
       --------------------- Crutch-way of tracking titans HP cuz well... they are not bosses it seems
      local totalValneerDamage = 0
      local totalMyrinaxDamage = 0
      for _, damage in pairs(AOCH.status.valneer_ids) do
        totalValneerDamage = totalValneerDamage + damage
      end
      for _, damage in pairs(AOCH.status.myrinax_ids) do
        totalMyrinaxDamage = totalMyrinaxDamage + damage
      end
      
      local myrinaxPercentage = (AOCH.status.titan_max_hp - totalMyrinaxDamage) / AOCH.status.titan_max_hp
      local valneerPercentage = (AOCH.status.titan_max_hp - totalValneerDamage) / AOCH.status.titan_max_hp
      ------------------- Update UI
      local txtPercentNum = tostring(string.format("%.1f", valneerPercentage * 100))
      if AOCHStatusValneerHpCounterLabel:IsHidden() then
        AOCHStatusValneerHpCounterLabel:SetHidden(false)
      end
      AOCHStatusValneerHpCounterLabel:SetText("Valneer HP : " .. txtPercentNum .. "%")

      txtPercentNum = tostring(string.format("%.1f", myrinaxPercentage * 100))
      if AOCHStatusMyrinaxHpCounterLabel:IsHidden() then
        AOCHStatusMyrinaxHpCounterLabel:SetHidden(false)
      end
      AOCHStatusMyrinaxHpCounterLabel:SetText("Myrinax HP : " .. txtPercentNum .. "%")
    end

  end
  ----------------------------------------- Jynorah and Skorknif ---------------------------------------------------

  ----------------------------------------- Overfiend Kazpian ------------------------------------------------------
  if AOCH.status.is_kazpian then
    local kazpianHP, maxKazpianHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local kazpianPercentage = kazpianHP / maxKazpianHP

    AOCH.status.is_kazpian_start_arena = true
    AOCH.status.is_low_warden_arena = false
    AOCH.status.is_molag_kena_arena = false
    AOCH.status.is_krogo_arena = false

    --------------- set current arena
    if kazpianPercentage > 0.85 then
      AOCH.status.is_kazpian_start_arena = true
      AOCH.status.is_low_warden_arena = false
      AOCH.status.is_molag_kena_arena = false
      AOCH.status.is_krogo_arena = false
    elseif kazpianPercentage > 0.55 then
      AOCH.status.is_kazpian_start_arena = false
      AOCH.status.is_low_warden_arena = true
      AOCH.status.is_molag_kena_arena = false
      AOCH.status.is_krogo_arena = false
    elseif kazpianPercentage > 0.35 then
      AOCH.status.is_kazpian_start_arena = false
      AOCH.status.is_low_warden_arena = false
      AOCH.status.is_molag_kena_arena = true
      AOCH.status.is_krogo_arena = false
    else
      AOCH.status.is_kazpian_start_arena = false
      AOCH.status.is_low_warden_arena = false
      AOCH.status.is_molag_kena_arena = false
      AOCH.status.is_krogo_arena = true
    end
    AOCH.SetKazpianIcons()

    ----------------- portal countdown
    if AOCH.savedVariables.show_kazpian_portal_countdown then
      local portalLeft = 0
      if 0.858 < kazpianPercentage and kazpianPercentage < 0.9  then
        portalLeft = (kazpianPercentage - 858)*100
      elseif 0.558 < kazpianPercentage and kazpianPercentage < 0.6 then
        portalLeft = (kazpianPercentage - 0.558)*100
      elseif 0.358 < kazpianPercentage and kazpianPercentage < 0.4 then
        portalLeft = (kazpianPercentage - 0.358)*100
      else
        portalLeft = 0
      end

      if portalLeft > 0 then
        local txtPercentNum = tostring(string.format("%.1f", portalLeft))
        AOCHPurpleAlertLabel:SetText("Portal in: " .. txtPercentNum .. "%")
        AOCHPurpleAlert:SetHidden(false)
        AOCHPurpleAlertLabel:SetHidden(false)
      else
        AOCHPurpleAlert:SetHidden(true)
      end
    end

    ---------------- tank swap alert
    if AOCH.savedVariables.show_kazpian_frenzy_alert and AOCH.savedVariables.show_kazpian_frenzy_timer and AOCH.status.kazpian_frenzy_alert_playing then
      local alertTime = timeSec - AOCH.status.kazpian_frenzy_alert_start
      if alertTime < 5 then
        local txtTime = tostring(string.format("%d", 6 - alertTime))
        AOCHSwapAlertLabel:SetText("Swap in : " .. txtTime)
      else
        AOCH.status.kazpian_frenzy_alert_playing = false
        AOCH.status.kazpian_frenzy_alert_queued = false
        AOCHSwapAlertLabel:SetText("Swap")
        PlaySound(SOUNDS.DUEL_START)
        EVENT_MANAGER:RegisterForUpdate(AOCH.name .. "HideSwapAlert", 1000,
                                      function()
                                     EVENT_MANAGER:UnregisterForUpdate(AOCH.name .. "HideSwapAlert")
                                     AOCHSwapAlertLabel:SetHidden(true)
                                     AOCHSwapAlert:SetHidden(true)
                                      end)
      end
    end
  end
  ----------------------------------------- Overfiend Kazpian ------------------------------------------------------
end