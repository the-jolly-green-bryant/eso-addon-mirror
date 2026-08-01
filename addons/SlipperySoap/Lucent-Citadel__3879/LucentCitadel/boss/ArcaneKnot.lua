LC = LC or {}
local LC = LC
LC.ArcaneKnot = {}


function LC.ArcaneKnot.UpdateTick(timeSec)
    -- Arcane Knot Panel
    if LC.savedVariables.showXorynArcaneKnotPanel then
        LC.ArcaneKnot.UpdateArcaneKnotPanel()
    end

    -- Xoryn Arcane Knot Alert
    if LC.savedVariables.showXorynArcaneKnotAlerts then
        LC.ArcaneKnot.UpdateArcaneKnotAlert()
    end

end

function LC.ArcaneKnot.UpdateArcaneKnotPanel()
    if LC.status.arcaneKnotPickupTime > 0 then
        local timeUntilArcaneKnotDrop = (LC.status.arcaneKnotPickupTime + LC.data.arcane_knot_cooldown) - GetGameTimeSeconds()
        if timeUntilArcaneKnotDrop > 0 then
            local timeUntilArcaneKnotDropTxt = tostring(string.format("%.1f", timeUntilArcaneKnotDrop))
            LCStatusLabelArcaneKnot4:SetText("Knot Drop: ")
            LCStatusLabelArcaneKnot4:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            if timeUntilArcaneKnotDropTxt ~= nil then
                LCStatusLabel2Value:SetText(timeUntilArcaneKnotDropTxt)
                LCStatusLabel2Value:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            else
                d("timeUntilArcaneKnotDropTxt is nil")
                LCStatusLabel2Value:SetHidden(true)
            end
        elseif timeUntilArcaneKnotDrop > -10 and timeUntilArcaneKnotDrop <= 0 then
            LCStatusLabelArcaneKnot4:SetText("Knot Drop: ")
            LCStatusLabelArcaneKnot4Value:SetText("Now")
            LCStatusLabelArcaneKnot4:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
            LCStatusLabelArcaneKnot4Value:SetHidden(not LC.savedVariables.showXorynArcaneKnotPanel)
        else
            LCStatusLabelArcaneKnot4:SetHidden(true)
            LCStatusLabelArcaneKnot4Value:SetHidden(true)
        end
    end

    -- need to change offset: LCStatusLabelArcaneKnot1 offset -> 
    -- previous Reef Guardian UI offset:  offsetY="0" offsetX="420"/>

    LCStatusLabelArcaneKnot1:SetText("Current Knot: ")
    LCStatusLabelArcaneKnot1Value:SetText(LC.status.arcaneKnotCurrentArcaneKnotHolder)
    LCStatusLabelArcaneKnot1:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabelArcaneKnot1Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    LCStatusLabelArcaneKnot2:SetText("Next Knot: ")
    LCStatusLabelArcaneKnot2Value:SetText(LC.status.arcaneKnotNextArcaneKnotHolder)
    LCStatusLabelArcaneKnot2:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabelArcaneKnot2Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    LCStatusLabelArcaneKnot3:SetText("Backup Knot: ")
    LCStatusLabelArcaneKnot3Value:SetText(LC.status.arcaneKnotBackupArcaneKnotHolder)
    LCStatusLabelArcaneKnot3:SetHidden(not LC.savedVariables.showXorynMirrorPanel)
    LCStatusLabelArcaneKnot3Value:SetHidden(not LC.savedVariables.showXorynMirrorPanel)

    -- moving the trackers around
    -- Arcane Knot Drop tracker was offsetY="120" and offsetY="120" offsetX="230"
    -- previous color: FF5733 orange
end

function LC.ArcaneKnot.UpdateArcaneKnotAlert()
    if LC.status.arcaneKnotPickupTime > 0 then
        local timeUntilArcaneKnotDrop = (LC.status.arcaneKnotPickupTime + LC.data.arcane_knot_cooldown) - GetGameTimeSeconds()
        if timeUntilArcaneKnotDrop > 0 and timeUntilArcaneKnotDrop < 5 then
            LCMessage3Label:SetText("Next Knot is " .. LC.status.arcaneKnotNextArcaneKnotHolder .. " or " .. LC.status.arcaneKnotBackupArcaneKnotHolder)
            LCMessage3:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)
        elseif timeUntilArcaneKnotDrop > -10 and timeUntilArcaneKnotDrop <= 0 then
            -- Updated
            LCMessage3Label:SetText("Now Knot is " .. LC.status.arcaneKnotNextArcaneKnotHolder .. " or " .. LC.status.arcaneKnotBackupArcaneKnotHolder)
            LCMessage3:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)

            -- Previous
            --LCMessage2Label:SetText("Knot Loose!")
            --LCMessage2:SetHidden(not LC.savedVariables.showXorynArcaneKnotAlerts)
        else
            -- LCMessage2 currently dark pink
            --LCMessage2:SetHidden(true)
            LCMessage3:SetHidden(true)
        end
    end
end

function LC.ArcaneKnot.UpdateArcaneKnot(changeType, unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        LC.status.arcaneKnotCurrentArcaneKnotHolder = GetUnitDisplayName(unitTag)
        LC.status.arcaneKnotPickupTime = GetGameTimeSeconds()

        if LC.savedVariables.illuminatiCoreMode then
            LC.status.arcaneKnotHolders = LC.status.illuminatiArcaneKnotHolders
        elseif LC.savedVariables.kmpCoreMode then
            LC.status.arcaneKnotHolders = LC.status.kmpArcaneKnotHolders
        end

        LC.status.currentArcaneKnot =  LC.status.currentArcaneKnot + 1

        -- LC.status.currentArcaneKnot
        -- LC.status.kmpArcaneKnotHolders


        for i=1, 12 do
            
            if LC.status.arcaneKnotCurrentArcaneKnotHolder ~= nil and LC.status.arcaneKnotHolders[i] ~= nil then
                if LC.status.arcaneKnotCurrentArcaneKnotHolder == LC.status.arcaneKnotHolders[i] then
                    if i == 11 then
                        --i = i - 12
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[12]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[1]
                    elseif i == 12 then
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[1]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[2]
                        --i = i - 12
                    else
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[i+1]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[i+2]
                    end
                    --LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[i+1]
                    return
                end
                if i == 12 and LC.status.arcaneKnotCurrentArcaneKnotHolder ~= LC.status.arcaneKnotHolders[i] then
                    
                    if LC.status.currentArcaneKnot == 11 then
                        --i = i - 12
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[12]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[1]
                    elseif LC.status.currentArcaneKnot == 12 then
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[1]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[2]
                        --i = i - 12
                    else
                        LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[LC.status.currentArcaneKnot+1]
                        LC.status.arcaneKnotBackupArcaneKnotHolder = LC.status.arcaneKnotHolders[LC.status.currentArcaneKnot+2]
                    end
                    --LC.status.arcaneKnotNextArcaneKnotHolder = LC.status.arcaneKnotHolders[i+1]
                    return
                    --LC.status.arcaneKnotNextArcaneKnotHolder = "@unknown"
                    --LC.status.arcaneKnotBackupArcaneKnotHolder = "@unknown"
                end
                
            end
        end
    end
end

function LC.ArcaneKnot.InitializeKnotOrder()
    if LC.savedVariables.illuminatiCoreMode then
        LC.status.arcaneKnotHolders = LC.status.illuminatiArcaneKnotHolders
    elseif LC.savedVariables.kmpCoreMode then
        LC.status.arcaneKnotHolders = LC.status.kmpArcaneKnotHolders
    end

    LC.status.viableArcaneKnotHolders = LC.status.arcaneKnotHolders
end

function LC.ArcaneKnot.PrintPlayersDistance()
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
function LC.ArcaneKnot.UpdateMirrorMechTracker()
    LC.status.xorynLastTempestAssault = GetGameTimeSeconds()
end

-- Can be used to update next line tracker
function LC.ArcaneKnot.UpdateNextBridgeTracker(bossPercentage, threshold)
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
function LC.ArcaneKnot.LureOfTheSea()
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
function LC.ArcaneKnot.LureOfTheSeaIcon(targetUnitId)
  if LC.savedVariables.showLureOfTheSeaIcon then
    if targetUnitId ~= nil and LC.units[targetUnitId] ~= nil then
      LC.AddIconForDuration(LC.units[targetUnitId].tag, "LucentCitadel/icons/lemon.dds", 3000)
    end
  end
end

