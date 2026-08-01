local AST = AsylumTracker

local COLOR_RED      = "|cff0000"
local COLOR_GREEN    = "|c00ff00"
local NOTIF_DURATION = 3000

local function isLlothis(name)
     return name:find("Llothis") or name:find("ロシス") or name:find("ллотис")
end

local function isFelms(name)
     return name:find("Felms") or name:find("フェルムス") or name:find("фелмс")
end

local function UnitIdToName(unitId)
     local name = AST.GetNameForUnitId(unitId)
     if name == "" then
          return "#" .. unitId
     elseif AST.groupMembers[name] then
          return zo_strformat("<<C:1>>", UndecorateDisplayName(AST.groupMembers[name]))
     end
     return name
end

local function NormaliseTargetName(name)
     if name:sub(1, 1) == "#" then return GetString(AST_SETT_YOU) end
     if name == zo_strformat("<<C:1>>", AST.displayName) then return GetString(AST_SETT_YOU) end
     return name
end

function AST.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     if result == ACTION_RESULT_INTERRUPT and AST.sv.oppressive_bolts then
          AsylumTrackerOppressiveBoltsLabel:SetText(AST.sv.interrupt_message)
          zo_callLater(function() AST.SetTimer("oppressive_bolts") end, 1000)
          return
     end

     if result == ACTION_RESULT_BEGIN then

          if abilityId == AST.id.storm_the_heavens then
               if not AST.stormIsActive and AST.sv.sound_enabled then
                    PlaySound(SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH)
               end

               AST.initialStormOccured = true
               AST.stormIsActive = true
               AST.SetTimer("storm_the_heavens")
               AST.dbgability(abilityId, result, hitValue)

               if AST.sv.storm_the_heavens then
                    AsylumTrackerStormLabel:SetText(GetString(AST_NOTIF_KITE_NOW))
                    AsylumTrackerStorm:SetHidden(false)
               end

               -- Storm the Heavens gives no end event, so hide the notification after 6 seconds
               zo_callLater(function() AsylumTrackerStorm:SetHidden(true) AST.stormIsActive = false end, 6000)

          elseif abilityId == AST.id.defiling_blast and hitValue == 2000 then

               targetName = NormaliseTargetName(UnitIdToName(targetUnitId))

               AST.LlothisSpawned = true
               AST.SetTimer("defiling_blast")
               AST.dbgability(abilityId, result, hitValue)

               local color = targetName == GetString(AST_SETT_YOU) and COLOR_RED or ""
               AsylumTrackerBlastLabel:SetText(GetString(AST_NOTIF_BLAST) .. color .. targetName .. "|r")
               if AST.sv.sound_enabled then PlaySound(SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH) end
               AsylumTrackerBlast:SetHidden(false)

          elseif abilityId == AST.id.oppressive_bolts then

               AST.LlothisSpawned = true
               AST.SetTimer("oppressive_bolts", 0)
               AST.dbgability(abilityId, result, hitValue)
               AsylumTrackerOppressiveBoltsLabel:SetText(COLOR_RED .. GetString(AST_NOTIF_INTERRUPT) .. "|r")
               AsylumTrackerOppressiveBolts:SetHidden(false)

          elseif abilityId == AST.id.teleport_strike then

               targetName = NormaliseTargetName(UnitIdToName(targetUnitId))

               AST.FelmsSpawned = true
               AST.SetTimer("teleport_strike")
               AST.dbgability(abilityId, result, hitValue)

               local color = targetName == GetString(AST_SETT_YOU) and COLOR_RED or ""
               AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_NOTIF_JUMP) .. color .. targetName .. "|r")
               AsylumTrackerTeleportStrike:SetHidden(false)
               zo_callLater(function() AsylumTrackerTeleportStrike:SetHidden(true) end, 2000)

          elseif abilityId == AST.id.gusts_of_steam then

               AsylumTrackerOlmsHPLabel:SetText(GetString(AST_NOTIF_OLMS_JUMP))
               AST.dbgability(abilityId, result, hitValue)
               AST.olmsJumping = true

               if AST.firstJump then -- First in the 4-jump sequence around the room, not the 90% jump
                    AST.firstJump = false
                    if AST.olmsHealth > 80 then
                         AST.SetTimer("storm_the_heavens", 15)
                    end
                    zo_callLater(function()
                         AsylumTrackerOlmsHP:SetHidden(true)
                         AST.olmsJumping = false
                         AST.firstJump = true
                    end, 12000)
               end

          elseif abilityId == AST.id.trial_by_fire then

               AST.SetTimer("trial_by_fire")
               if AST.sv.trial_by_fire then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerFireLabel:SetText(GetString(AST_NOTIF_FIRE) .. COLOR_RED .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerFire:SetHidden(false)
                    zo_callLater(function() AsylumTrackerFire:SetHidden(true) end, 7000)
               end

          elseif abilityId == AST.id.scalding_roar and hitValue == 2300 then

               AST.SetTimer("scalding_roar")
               if AST.sv.scalding_roar then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerSteamLabel:SetText(GetString(AST_NOTIF_STEAM) .. COLOR_RED .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerSteam:SetHidden(false)
                    zo_callLater(function() AsylumTrackerSteam:SetHidden(true) end, 5000)
               end

          elseif abilityId == AST.id.exhaustive_charges then

               AST.SetTimer("exhaustive_charges")
               if AST.sv.exhaustive_charges then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerChargesLabel:SetText(GetString(AST_NOTIF_CHARGES) .. COLOR_RED .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerCharges:SetHidden(false)
                    zo_callLater(function() AsylumTrackerCharges:SetHidden(true) end, 2000)
               end
          end
     end

     if result == ACTION_RESULT_EFFECT_GAINED then
          if abilityId == AST.id.static_shield then -- Track the protector via the shield it gives Olms rather than its spawn event
               AST.sphereIsUp = true
               AST.dbgability(abilityId, result, hitValue)
               AsylumTrackerSphereLabel:SetText(GetString(AST_NOTIF_PROTECTOR))
               AsylumTrackerSphere:SetHidden(false)

          elseif abilityId == AST.id.boss_event and hitValue == 1 then
               AST.spawnTimes[targetUnitId] = GetGameTimeSeconds()
               AST.dbg("Boss Event for [" .. targetUnitId .. "]")

          elseif abilityId == AST.id.maim then
               AST.dbgability(abilityId, result, hitValue)
          end
     end

     if result == ACTION_RESULT_EFFECT_FADED then
          if abilityId == AST.id.defiling_blast then
               AsylumTrackerBlast:SetHidden(true)

          elseif abilityId == AST.id.oppressive_bolts then
               AST.SetTimer("oppressive_bolts")

          elseif abilityId == AST.id.static_shield then -- All protectors dead, shield fades
               AST.sphereIsUp = false
               AsylumTrackerSphere:SetHidden(true)
          end
     end
end

function AST.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
     -- Llothis and Felms have no boss tags in +1/+2 fights so we identify them by name.
     -- Hard-coded for English/French/German (Llothis), Japanese (ロシス), and ruESO (ллотис).
     if isLlothis(unitName) then
          if not AST.LlothisSpawned then
               AST.LlothisSpawned = true
               if AST.spawnTimes[unitId] then
                    local uptime = GetGameTimeSeconds() - AST.spawnTimes[unitId]
                    if AST.sv.defiling_blast then AST.SetTimer("defiling_blast", 12 - uptime) end
                    if AST.sv.oppressive_bolts then AST.SetTimer("oppressive_bolts", 12 - uptime) end
               end
          end

     elseif isFelms(unitName) then
          if not AST.FelmsSpawned then
               AST.FelmsSpawned = true
               if AST.spawnTimes[unitId] then
                    local uptime = GetGameTimeSeconds() - AST.spawnTimes[unitId]
                    if AST.sv.teleport_strike then AST.SetTimer("teleport_strike", 12 - uptime) end
               end
          end
     end

     -- Adjust timers when Llothis or Felms go dormant or wake up
     if abilityId == AST.id.dormant then
          if changeType == EFFECT_RESULT_GAINED then
               if isLlothis(unitName) then
                    if AST.sv.defiling_blast then AST.SetTimer("defiling_blast", 45) end
                    if AST.sv.oppressive_bolts then AST.SetTimer("oppressive_bolts", 45) end
                    AST.SetTimer("llothis_dormant")
                    if AST.sv.llothis_notifications then
                         AST.CreateNotification(COLOR_GREEN .. GetString(AST_NOTIF_LLOTHIS_DOWN) .. "|r", NOTIF_DURATION)
                    end

               elseif isFelms(unitName) then
                    if AST.sv.teleport_strike then
                         AST.SetTimer("teleport_strike", 45)
                         AsylumTrackerTeleportStrike:SetHidden(true)
                    end
                    AST.SetTimer("felms_dormant")
                    if AST.sv.felms_notifications then
                         AST.CreateNotification(COLOR_GREEN .. GetString(AST_NOTIF_FELMS_DOWN) .. "|r", NOTIF_DURATION)
                    end
               end

          elseif changeType == EFFECT_RESULT_FADED then
               if isLlothis(unitName) then
                    AST.SetTimer("llothis_dormant", 0)
                    if AST.sv.llothis_notifications then
                         AST.CreateNotification(COLOR_GREEN .. GetString(AST_NOTIF_LLOTHIS_UP) .. "|r", NOTIF_DURATION)
                    end

               elseif isFelms(unitName) then
                    AST.SetTimer("felms_dormant", 0)
                    if AST.sv.felms_notifications then
                         AST.CreateNotification(COLOR_GREEN .. GetString(AST_NOTIF_FELMS_UP) .. "|r", NOTIF_DURATION)
                    end
               end
          end
     end
end