LC = LC or {}
local LC = LC
LC.Xoryn = {}


function LC.Xoryn.UpdateTick(timeSec)
    -- Xoryn Tempest Assault Panel
    if LC.savedVariables.showXorynMirrorPanel then
        LC.Xoryn.UpdateTempestAssaultPanel()
    end
    
    -- Xoryn Tempest Assault Alert
    if LC.savedVariables.showXorynMirrorAlert then
        LC.Xoryn.UpdateTempestAssaultAlert()
    end

    -- Xoryn Fluctuating Current Panel
    --if LC.savedVariables.showXorynMirrorPanel then
        --LC.Xoryn.UpdateTempestAssaultPanel()
    --end
    
    
    -- Xoryn Fluctuating Panel
    if LC.savedVariables.showXorynFluxPanel then
        LC.Xoryn.UpdateFluctuatingPanel()
    end

    -- Xoryn Fluctuating Current Alert
    if LC.savedVariables.showXorynFluctuatingAlert then
        LC.Xoryn.UpdateFluctuatingAlert()
    end

    -- Xoryn Arcane Knot Panel
    -- if LC.savedVariables.showXorynArcaneKnotPanel then
        -- LC.Xoryn.UpdateArcaneKnotPanel()
    -- end

    -- Xoryn Arcane Knot Alert
    -- if LC.savedVariables.showXorynArcaneKnotAlerts then
        -- LC.Xoryn.UpdateArcaneKnotAlert()
    -- end

    -- Xoryn Tempest Panel
    if LC.savedVariables.showXorynMirrorPanel then
        LC.Xoryn.UpdateTempestAssaultPanel()
    end

end

function LC.Xoryn.InitializeFluctuatingOrder()
    if LC.savedVariables.illuminatiCoreMode then
        LC.status.fluctuatingHolders = LC.status.illuminatiFluctuatingHolders
    elseif LC.savedVariables.kmpCoreMode then
        LC.status.fluctuatingHolders = LC.status.kmpFluctuatingHolders
    end

    LC.status.viableFluctuatingHolders = LC.status.fluctuatingHolders
    LC.status.fluctuatingHoldersOnCooldown = LC.status.viableFluctuatingHolders
    local lengthOfFluctuatingHoldersOnCooldown = LC.GetTableLength(LC.status.fluctuatingHoldersOnCooldown)
    for i=1, lengthOfFluctuatingHoldersOnCooldown do
        LC.status.fluctuatingHoldersOnCooldown[i] = nil
    end

end

function LC.Xoryn.UpdateFluctuatingPanel()
    --if LC.status.arcaneKnotPickupTime > 0 then
        --local timeUntilArcaneKnotDrop = (LC.status.arcaneKnotPickupTime + LC.data.arcane_knot_cooldown) - GetGameTimeSeconds()
        --if timeUntilArcaneKnotDrop > 0 then
            --local timeUntilArcaneKnotDropTxt = tostring(string.format("%.1f", timeUntilArcaneKnotDrop))
            --LCStatusLabel2:SetText("Knot Drop (s): ")
            --LCStatusLabel2:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            --if timeUntilArcaneKnotDropTxt ~= nil then
                --LCStatusLabel2Value:SetText(timeUntilArcaneKnotDropTxt)
                --LCStatusLabel2Value:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            --else
                --d("timeUntilArcaneKnotDropTxt is nil")
                --LCStatusLabel2Value:SetHidden(true)
            --end
        --elseif timeUntilArcaneKnotDrop > -10 and timeUntilArcaneKnotDrop <= 0 then
            --LCStatusLabel2:SetText("Knot Drop (s): ")
            --LCStatusLabel2Value:SetText("Now")
            --LCStatusLabel2:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
            --LCStatusLabel2Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
        --else
            --LCStatusLabel2:SetHidden(true)
            --LCStatusLabel2Value:SetHidden(true)
        --end
    --end

    --LCStatusLabel3:SetText("Current Knot: ")
    --LCStatusLabel3Value:SetText(LC.status.arcaneKnotCurrentArcaneKnotHolder)
    --LCStatusLabel3:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    --LCStatusLabel3Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    LCStatusLabelFluctuating1:SetText("Next Flux: ")
    LCStatusLabelFluctuating1Value:SetText(LC.status.xorynNextFluctuatingHolder)
    LCStatusLabelFluctuating1:SetHidden(not LC.savedVariables.showXorynFluxPanel)
    LCStatusLabelFluctuating1Value:SetHidden(not LC.savedVariables.showXorynFluxPanel)

    --LCStatusLabel5:SetText("Backup Knot: ")
    --LCStatusLabel5Value:SetText(LC.status.arcaneKnotBackupArcaneKnotHolder)
    --LCStatusLabel5:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    --LCStatusLabel5Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
end

function LC.Xoryn.UpdateFluctuatingAlert()
    if LC.status.xorynFluctuatingPickupTime > 0 then
        local fluctuatingPickupTimer = GetGameTimeSeconds() - LC.status.xorynFluctuatingPickupTime
        local fluctuatingPickupTimerTxt = tostring(string.format("%.1f", fluctuatingPickupTimer))
        if fluctuatingPickupTimer > 0 and fluctuatingPickupTimer < 15 then
            LCMessage1Label:SetText(LC.status.xorynNextFluctuatingHolder .. " flux " .. fluctuatingPickupTimerTxt)
            LCMessage1:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)
        else
            LCMessage1:SetHidden(true)
        end
    end
end

function LC.Xoryn.DecideOnNextFluctuatingHolder(j)
    -- passing in the next person without Arcane Knot consideration

    local lengthOfViableFluctuatingHoldersTable = LC.GetTableLength(LC.status.viableFluctuatingHolders)
    for i=j, lengthOfViableFluctuatingHoldersTable do
        if LC.status.viableFluctuatingHolders[i] ~= LC.status.arcaneKnotCurrentArcaneKnotHolder
        and LC.status.viableFluctuatingHolders[i] ~= LC.status.arcaneKnotNextArcaneKnotHolder then
            return LC.status.viableFluctuatingHolders[i]
        end
    end
end

function LC.Xoryn.UpdateFluctuating(result, targetType, hitValue, targetUnitId)
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
        local unitTag = LC.GetTagForId(targetUnitId)
        if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
            LC.status.xorynCurrentFluctuatingHolder = LC.GetNameForId(unitTag)
            LC.status.xorynFluctuatingPickupTime = GetGameTimeSeconds()

            --if LC.savedVariables.illuminatiCoreMode then
                --LC.status.fluctuatingHolders = LC.savedVariables.illuminatiFluctuatingHolders
            --end
            local lengthOfViableFluctuatingHoldersTable = LC.GetTableLength(LC.status.viableFluctuatingHolders)

            -- if a player dies then I need to remove them from the list of viable Fluctuating holders

            for i=1, lengthOfViableFluctuatingHoldersTable do
                if LC.status.xorynCurrentFluctuatingHolder == LC.status.viableFluctuatingHolders[i] then
                    if i == lengthOfViableFluctuatingHoldersTable then
                        i = 1
                    end
                    LC.status.xorynNextFluctuatingHolder = LC.Xoryn.DecideOnNextFluctuatingHolder(i)
                    --LC.status.xorynNextFluctuatingHolder = LC.status.viableFluctuatingHolders[i+1]
                    LC.RemoveHolderFromViableFluctuatingHoldersTable(LC.status.xorynCurrentFluctuatingHolder)
                    return
                end
                -- if went through table and current holder is not in the table, then just move on to the person after the next person but skip the next person because it means they needed a fill
                if i == lengthOfViableFluctuatingHoldersTable then
                    if LC.status.xorynCurrentFluctuatingHolder ~= LC.status.viableFluctuatingHolders[i] then
                        i = 1
                        LC.status.xorynNextFluctuatingHolder = LC.status.viableFluctuatingHolders[2]
                        --LC.status.xorynNextFluctuatingHolder = LC.status.viableFluctuatingHolders[i+1]
                        -- remove the next person
                        LC.RemoveHolderFromViableFluctuatingHoldersTable(LC.status.viableFluctuatingHolders[1])
                    end
                    return
                end
            end
        end
    end
end

function LC.Xoryn.HandleOverloaded(result, targetType, hitValue, targetUnitId)
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
        local unitTag = LC.GetTagForId(targetUnitId)
        local atName = LC.GetNameForId(unitTag)
        if result == ACTION_RESULT_EFFECT_FADED then
            LC.MoveAtNameFromFluctuatingHoldersOnCooldownTableToViableTable(atName)
        end
    end
end

function LC.MoveAtNameFromFluctuatingHoldersOnCooldownTableToViableTable(atName)
    local lengthOfViableFluctuatingHoldersOnCooldownTable = LC.GetTableLength(LC.status.fluctuatingHoldersOnCooldown)
    for i=1, lengthOfViableFluctuatingHoldersOnCooldownTable do
        if LC.status.fluctuatingHoldersOnCooldown[i] == atName then
            LC.status.fluctuatingHoldersOnCooldown[i] = nil
            LC.AddAtNameToViableFluctuatingHoldersTable(atName)
            return
        end
    end
end

function LC.RemoveHolderFromViableFluctuatingHoldersTable(atName)
    --local newTable = {}
    local lengthOfViableFluctuatingHoldersTable = LC.GetTableLength(LC.status.viableFluctuatingHolders)
    local j = lengthOfViableFluctuatingHoldersTable
    for i=1, lengthOfViableFluctuatingHoldersTable do
        if LC.status.viableFluctuatingHolders[i] == atName then
            j = i
            --LC.status.fluctuatingHoldersOnCooldown
            LC.AddAtNameToFluctuatingHoldersOnCooldownTable(atName)

        end
        if i > j then
            -- keep it the same
        elseif i == j then
            LC.status.viableFluctuatingHolders[i] = LC.status.viableFluctuatingHolders[i+1]
        elseif i < j and i < lengthOfViableFluctuatingHoldersTable then
            LC.status.viableFluctuatingHolders[i] = LC.status.viableFluctuatingHolders[i+1]
        elseif i == lengthOfViableFluctuatingHoldersTable then
            LC.status.viableFluctuatingHolders[i] = nil
        end
    end
end

function LC.AddAtNameToViableFluctuatingHoldersTable(atName)
    local lengthOfViableFluctuatingHoldersTable = LC.GetTableLength(LC.status.viableFluctuatingHolders)
    local firstNilSpotFound = lengthOfViableFluctuatingHoldersTable
    if LC.status.viableFluctuatingHolders[lengthOfViableFluctuatingHoldersTable] == nil then
        LC.status.viableFluctuatingHolders[lengthOfViableFluctuatingHoldersTable] = atName
    elseif LC.status.viableFluctuatingHolders[lengthOfViableFluctuatingHoldersTable] ~= nil then

    end
    -- LC.status.fluctuatingHolders
    for i=1, lengthOfViableFluctuatingHoldersTable do
        if LC.status.viableFluctuatingHolders[i] == atName then
            j = i
        end
        if i > j then
            -- keep it the same
        elseif i == j then
            LC.status.viableFluctuatingHolders[i] = LC.status.viableFluctuatingHolders[i+1]
        elseif i < j and i < lengthOfViableFluctuatingHoldersTable then
            LC.status.viableFluctuatingHolders[i] = LC.status.viableFluctuatingHolders[i+1]
        elseif i == lengthOfViableFluctuatingHoldersTable then
            LC.status.viableFluctuatingHolders[i] = nil
        end
    end
end

function LC.AddAtNameToFluctuatingHoldersOnCooldownTable(atName)
    local lengthOfViableFluctuatingHoldersOnCooldownTable = LC.GetTableLength(LC.status.fluctuatingHoldersOnCooldown)
    for i=1, lengthOfViableFluctuatingHoldersOnCooldownTable do
        if LC.status.fluctuatingHoldersOnCooldown[i] == nil then
            LC.status.fluctuatingHoldersOnCooldown[i] = atName
            return
        end
    end
end

function LC.Xoryn.UpdateArcaneKnotPanel()
    if LC.status.arcaneKnotPickupTime > 0 then
        local timeUntilArcaneKnotDrop = (LC.status.arcaneKnotPickupTime + LC.data.arcane_knot_cooldown) - GetGameTimeSeconds()
        if timeUntilArcaneKnotDrop > 0 then
            local timeUntilArcaneKnotDropTxt = tostring(string.format("%.1f", timeUntilArcaneKnotDrop))
            LCStatusLabel2:SetText("Knot Drop (s): ")
            LCStatusLabel2:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            if timeUntilArcaneKnotDropTxt ~= nil then
                LCStatusLabel2Value:SetText(timeUntilArcaneKnotDropTxt)
                LCStatusLabel2Value:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            else
                d("timeUntilArcaneKnotDropTxt is nil")
                LCStatusLabel2Value:SetHidden(true)
            end
        elseif timeUntilArcaneKnotDrop > -10 and timeUntilArcaneKnotDrop <= 0 then
            LCStatusLabel2:SetText("Knot Drop (s): ")
            LCStatusLabel2Value:SetText("Now")
            LCStatusLabel2:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
            LCStatusLabel2Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
        else
            LCStatusLabel2:SetHidden(true)
            LCStatusLabel2Value:SetHidden(true)
        end
    end

    LCStatusLabel3:SetText("Current Knot: ")
    LCStatusLabel3Value:SetText(LC.status.arcaneKnotCurrentArcaneKnotHolder)
    LCStatusLabel3:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabel3Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    LCStatusLabel4:SetText("Next Knot: ")
    LCStatusLabel4Value:SetText(LC.status.arcaneKnotNextArcaneKnotHolder)
    LCStatusLabel4:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabel4Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    LCStatusLabel5:SetText("Backup Knot: ")
    LCStatusLabel5Value:SetText(LC.status.arcaneKnotBackupArcaneKnotHolder)
    LCStatusLabel5:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabel5Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
end

function LC.Xoryn.UpdateArcaneKnotAlert()
    if LC.status.arcaneKnotPickupTime > 0 then
        local timeUntilArcaneKnotDrop = (LC.status.arcaneKnotPickupTime + LC.data.arcane_knot_cooldown) - GetGameTimeSeconds()
        if timeUntilArcaneKnotDrop > 0 and timeUntilArcaneKnotDrop < 5 then
            LCMessage3Label:SetText("Next Knot is " .. LC.status.arcaneKnotNextArcaneKnotHolder .. " or " .. LC.status.arcaneKnotBackupArcaneKnotHolder)
            LCMessage3:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)
        elseif timeUntilArcaneKnotDrop > -10 and timeUntilArcaneKnotDrop <= 0 then
            LCMessage1Label:SetText("Now Knot is " .. LC.status.arcaneKnotNextArcaneKnotHolder .. " or " .. LC.status.arcaneKnotBackupArcaneKnotHolder)
            LCMessage1:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)
        else
            LCMessage1:SetHidden(true)
            LCMessage3:SetHidden(true)
        end
    end
end

function LC.Xoryn.UpdateArcaneKnot(changeType, unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        LC.status.arcaneKnotCurrentArcaneKnotHolder = GetUnitDisplayName(unitTag)
        LC.status.arcaneKnotPickupTime = GetGameTimeSeconds()

        if LC.savedVariables.illuminatiCoreMode then
            LC.savedVariables.arcaneKnotHolders = LC.savedVariables.illuminatiArcaneKnotHolders
        end

        for i=1, 12 do
            if LC.status.arcaneKnotCurrentArcaneKnotHolder == LC.savedVariables.arcaneKnotHolders[i] then
                if i == 12 then
                    i = i - 12
                end
                LC.status.arcaneKnotNextArcaneKnotHolder = LC.savedVariables.arcaneKnotHolders[i+1]
                if i == 11 then
                    i = i - 12
                end
                LC.status.arcaneKnotBackupArcaneKnotHolder = LC.savedVariables.arcaneKnotHolders[i+2]
            end
        end
    end
end

function LC.Xoryn.UpdateTempestAssaultPanel()
    if LC.status.xorynLastTempestAssault > 0 then
        local timeUntilNextTempestAssault = (LC.status.xorynLastTempestAssault + LC.data.xoryn_tempest_assault_cooldown) - GetGameTimeSeconds()
        if timeUntilNextTempestAssault > 0 then
            local timeUntilNextTempestAssaulTxt = tostring(string.format("%.1f", timeUntilNextTempestAssault))
            LCStatusLabelTempest:SetText("Tempest Assault: ")
            LCStatusLabelTempest:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
            if timeUntilNextTempestAssaulTxt ~= nil then
                LCStatusLabelTempestValue:SetText(timeUntilNextTempestAssaulTxt)
                LCStatusLabelTempestValue:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
            else
                d("timeUntilNextTempestAssaulTxt is nil")
                LCStatusLabelTempestValue:SetHidden(true)
            end
        elseif timeUntilNextTempestAssault > -10 and timeUntilNextTempestAssault <= 0 then
            LCStatusLabelTempest:SetText("Tempest Assault: ")
            LCStatusLabelTempestValue:SetText("INC")
            LCStatusLabelTempest:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
            LCStatusLabelTempestValue:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
        else
            LCStatusLabelTempest:SetHidden(true)
            LCStatusLabelTempestValue:SetHidden(true)
        end
    end
end

function LC.Xoryn.UpdateTempestAssaultAlert()
    local timeUntilNextTempestAssault = (LC.status.xorynLastTempestAssault + LC.data.xoryn_tempest_assault_cooldown) - GetGameTimeSeconds()
    if timeUntilNextTempestAssault < 10 and LC.status.xorynLastTempestAssault > 0 then

        local timeUntilNextTempestAssaulTxt = tostring(string.format("%.1f", timeUntilNextTempestAssault))

        if timeUntilNextTempestAssaulTxt ~= nil then
            LCMessage2Label:SetText("Tempest Assault: " .. timeUntilNextTempestAssaulTxt)
            LCMessage2:SetHidden(not LC.savedVariables.showXorynMirrorAlert)
        else
            d("timeUntilNextTempestAssaulTxt is nil")
        end
    elseif timeUntilNextTempestAssault > -5 and timeUntilNextTempestAssault <= 0 then
        LCMessage2Label:SetText("Tempest Assault: INC")
        LCMessage2:SetHidden(not LC.savedVariables.showXorynMirrorAlert)
    else
        LCMessage2:SetHidden(true)
    end
end

function LC.Xoryn.PrintPlayersDistance()
  for i=1, 12 do
    local unitTag = "group" .. tostring(i)
    local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
    --if px ~= nil and py ~= nil and pz ~= nil then
    if true then
      local dist = LC.GetDistMeters(
        LC.data.taleria_center_pos[1],
        LC.data.taleria_center_pos[2],
        LC.data.taleria_center_pos[3],
        px, py, pz)
      local displayName = GetUnitDisplayName(unitTag)
      if displayName ~= nil then
        d("[LC] Rapid Deluge " .. displayName .. " (" .. string.format("%.3f", dist) .. ")")
      end
    end
  end
end

-- Can be used to update next line tracker
function LC.Xoryn.UpdateMirrorMechTracker()
    LC.status.xorynLastTempestAssault = GetGameTimeSeconds()
end

-- Can be used to update next line tracker
function LC.Xoryn.UpdateNextBridgeTracker(bossPercentage, threshold)
  local percentageLeft = (bossPercentage - threshold) * 100
  if (percentageLeft > 0) then
    LCStatusLabelTaleria4:SetText("Next Bridge (" .. LC.status.taleriaPortalNum + 1 .. "):")
    LCStatusLabelTaleria4Value:SetText(string.format("%.1f", percentageLeft) .. "% ")
    LCStatusLabelTaleria4:SetHidden(not LC.savedVariables.showNextBridge)
    LCStatusLabelTaleria4Value:SetHidden(not LC.savedVariables.showNextBridge)
  else
    -- Past threshold, waiting to open.
    LCStatusLabelTaleria4:SetText("Next Bridge (" .. LC.status.taleriaPortalNum+1 .. "):")
    LCStatusLabelTaleria4Value:SetText("INC")
    LCStatusLabelTaleria4:SetHidden(not LC.savedVariables.showNextBridge)
    LCStatusLabelTaleria4Value:SetHidden(not LC.savedVariables.showNextBridge)
  end
end

-- Can be used for line notification or lightning thing notification
function LC.Xoryn.LureOfTheSea()
  if LC.savedVariables.showLureOfTheSea then
    CombatAlerts.CastAlertsStart(
      LC.data.taleria_matron_lure_of_the_sea,
      "Lure of the Sea", 3000+1000, nil,
      {0.5, 0, 0.5, 0.6},
      {1000, "Break free!", 1, 0, 1, 1, nil})
    PlaySound(SOUNDS.DUEL_FORFEIT)
  end
end

-- Can be used for lightning thing icon
function LC.Xoryn.LureOfTheSeaIcon(targetUnitId)
  if LC.savedVariables.showLureOfTheSeaIcon then
    if targetUnitId ~= nil and LC.units[targetUnitId] ~= nil then
      LC.AddIconForDuration(LC.units[targetUnitId].tag, "LucentCitadel/icons/lemon.dds", 3000)
    end
  end
end

