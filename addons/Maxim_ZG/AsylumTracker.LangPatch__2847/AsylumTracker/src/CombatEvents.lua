local AST = AsylumTracker

-- Llothis/Felms have no boss unit tag in the +1/+2 fight, so we map each unitId to its boss: first by the
-- localised name (the early path - fires on the unit's first aura of any kind), and as a fallback for clients
-- with no translation, by the boss's signature abilityIds.
local LLOTHIS_ABILITIES = {
     [95545] = true, -- Defiling Blast
     [95585] = true, -- Oppressive Bolts (self aura)
     [96147] = true, -- Awakening of the Fabricants (self aura)
}
local FELMS_ABILITIES = {
     [99138] = true, -- Teleport Strike
     [95657] = true, -- Maim
     [99132] = true, -- Shard Storm (self aura)
}

AST.bossUnitIds = AST.bossUnitIds or {} -- [unitId] = "llothis" | "felms", rebuilt each fight (reset in Core's CombatState)

-- Name fragments come from the locale files (AST.lang.<locale>.bossNames). They are aggregated across every
-- locale so a boss is matched whatever the client language or loaded locale is. Built lazily (locales load after this file).
local bossNames
local function GetBossNames()
     if bossNames then return bossNames end
     bossNames = { llothis = {}, felms = {} }
     for _, locale in pairs(AST.lang) do
          if type(locale) == "table" and locale.bossNames then
               for boss, fragments in pairs(locale.bossNames) do
                    if bossNames[boss] then
                         for _, fragment in ipairs(fragments) do
                              table.insert(bossNames[boss], fragment)
                         end
                    end
               end
          end
     end
     return bossNames
end

-- Returns "llothis" / "felms" / nil for a unit, caching the result for the fight so later events (e.g. the
-- shared dormant aura) still resolve to the right boss.
local function IdentifyBoss(unitId, abilityId, unitName)
     if AST.bossUnitIds[unitId] then return AST.bossUnitIds[unitId] end

     local boss
     if unitName then -- Early path: localised name match
          for b, fragments in pairs(GetBossNames()) do
               for _, fragment in ipairs(fragments) do
                    if unitName:find(fragment, 1, true) then
                         boss = b
                         break
                    end
               end
               if boss then break end
          end
     end
     if not boss then -- Fallback for untranslated clients: signature abilityId
          if LLOTHIS_ABILITIES[abilityId] then
               boss = "llothis"
          elseif FELMS_ABILITIES[abilityId] then
               boss = "felms"
          end
     end

     if boss then AST.bossUnitIds[unitId] = boss end
     return boss
end

-- Converts a unitID obtained from AST.OnCombatEvent into the displayName for a player
local function UnitIdToName(unitId)
     local name = AST.GetNameForUnitId(unitId) -- Obtains the character name for a player's unitID
     if name == "" then
          name = "#"..unitId -- If the function couldn't determine the player's name, then return #unitID
     else
          if AST.groupMembers[name] ~= nil then
               name = AST.groupMembers[name] -- Convert the player's character name into their displayName
               name = UndecorateDisplayName(name) -- Removes the @ in front of the displayName
               name = zo_strformat("<<C:1>>", name) -- Capitalizes the displayName
          else
               return name
          end
     end
     return name
end

-- Returns the world position (x, y, z) of the player with the given @DisplayName, via their group unit tag
-- (or the "player" tag for yourself). Used to drop a static ground marker at a mechanic's impact location.
local function GetPlayerWorldPosition(atName)
     if not atName then return nil end
     if atName == GetUnitDisplayName("player") then
          local _, x, y, z = GetUnitRawWorldPosition("player")
          return x, y, z
     end
     for i = 1, GROUP_SIZE_MAX do
          if GetUnitDisplayName("group" .. i) == atName then
               local _, x, y, z = GetUnitRawWorldPosition("group" .. i)
               return x, y, z
          end
     end
     return nil
end

function AST.OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
     -- Whenever Llothis is interrupted, display the interrupted message and then reset the timer for Oppressive Bolts 1s later
     if result == ACTION_RESULT_INTERRUPT and AST.sv.oppressive_bolts then
          AsylumTrackerOppressiveBoltsLabel:SetText(AST.sv["interrupt_message"])
          zo_callLater(function() AST.SetTimer("oppressive_bolts") end, 1000)
          return
     end
     if result == ACTION_RESULT_BEGIN then

          if abilityId == AST.id["storm_the_heavens"] then
               if not AST.stormIsActive and AST.sv["sound_enabled"] then
                    PlaySound(SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH)
               end

               if not AST.initialStorm then AST.initialStormOccured = true end
               AST.stormIsActive = true

               AST.SetTimer("storm_the_heavens") -- Storm the Heavens just started, so create a new timer to preemtively warn for the next Storm the Heavens
               AST.dbgability(abilityId, result, hitValue)

               if AST.sv.storm_the_heavens then
                    AsylumTrackerStormLabel:SetText(GetString(AST_NOTIF_KITE_NOW)) -- Sets the warning notifcation to KITE when Storm the Heavens is active
                    AsylumTrackerStorm:SetHidden(false) -- Unhides the notifcation for Storm the Heavens
               end

               -- Storm the Heavens doesn't return a result to let you know when the storm ends, so I tell it to remove the notifcation from the screen 6 seconds after the storm started
               zo_callLater(function() AsylumTrackerStorm:SetHidden(true) AST.stormIsActive = false end, 6000)

          elseif abilityId == AST.id["defiling_blast"] and hitValue == 2000 then

               targetName = UnitIdToName(targetUnitId) -- Gets the @DisplayName for the player targeted by Llothis' defiling blast cone
               if targetName:sub(1, 1) == "#" then targetName = GetString(AST_SETT_YOU) end -- If UnitIdToName failed and returned #targetUnitId, then it was probably because you're not in a group, therefore we're assuming the target is the player
               if targetName == zo_strformat("<<C:1>>", AST.displayName) then targetName = GetString(AST_SETT_YOU) end -- It capitalizes the display name because the UnitIdToName function capitalizes the displayName before returning it
               if HashString(AST.displayName) == 1325046754 then targetName = "Gary" end

               if not AST.LlothisSpawned then AST.LlothisSpawned = true end

               AST.SetTimer("defiling_blast")
               AST.dbgability(abilityId, result, hitValue)

               -- OSI matches units by their decorated @DisplayName (GetUnitDisplayName includes the @), so the
               -- overhead marker needs the @-name, not the undecorated/capitalized name used for the on-screen text.
               local osiName
               local charName = AST.GetNameForUnitId(targetUnitId)
               if targetName == GetString(AST_SETT_YOU) then
                    osiName = GetUnitDisplayName("player")
               elseif charName ~= "" and AST.groupMembers[charName] then
                    osiName = AST.groupMembers[charName]
               end

               if OSI and osiName and AST.sv.osi_support and AST.sv.defiling_blast_osi then -- Green arrow over the targeted player. NOTE: OSI only draws mechanic icons while you are in a GROUP and in combat; solo it shows nothing.
                    OSI.SetMechanicIconForUnit(osiName, "OdySupportIcons/icons/green_arrow.dds", 2 * OSI.GetIconSize())
                    AST.blastMarkedName = osiName -- Removed when the cone ends (defiling_blast EFFECT_FADED below), so the marker lasts the whole cast
                    zo_callLater(function() -- Safety net: drop the marker after 10s in case the FADED event is missed, so it can never get stuck
                         if AST.blastMarkedName == osiName then
                              OSI.RemoveMechanicIconForUnit(osiName)
                              AST.blastMarkedName = nil
                         end
                    end, 10000)
               end

               if targetName == GetString(AST_SETT_YOU) then
                    AsylumTrackerBlastLabel:SetText(GetString(AST_NOTIF_BLAST) .. "|cff0000" .. targetName .. "|r") -- If the player is the target of the cone
                    if AST.sv["sound_enabled"] then PlaySound(SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH) end
               else
                    AsylumTrackerBlastLabel:SetText(GetString(AST_NOTIF_BLAST) .. targetName .. "|r") -- States who the cone is targeting
                    if AST.sv["sound_enabled"] then PlaySound(SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH) end
               end

               AsylumTrackerBlast:SetHidden(false) -- Unhides the notifcation
			  
          elseif abilityId == AST.id["oppressive_bolts"] then

               if not AST.LlothisSpawned then AST.LlothisSpawned = true end

               AST.SetTimer("oppressive_bolts", 0)

               AST.dbgability(abilityId, result, hitValue)
               AsylumTrackerOppressiveBoltsLabel:SetText("|cff0000" .. GetString(AST_NOTIF_INTERRUPT) .. "|r")
               AsylumTrackerOppressiveBolts:SetHidden(false)

          elseif abilityId == AST.id["teleport_strike"] then

               targetName = UnitIdToName(targetUnitId)
               if targetName:sub(1, 1) == "#" then targetName = GetString(AST_SETT_YOU) end
               if targetName == zo_strformat("<<C:1>>", AST.displayName) then targetName = GetString(AST_SETT_YOU) end -- It capitalizes the display name because the UnitIdToName function capitalizes the displayName before returning it

               if not AST.FelmsSpawned then AST.FelmsSpawned = true end

               AST.SetTimer("teleport_strike")
               AST.dbgability(abilityId, result, hitValue)

               -- OSI marker on the player Felms is jumping to (same @DisplayName approach as Defiling Blast)
               local osiName
               local charName = AST.GetNameForUnitId(targetUnitId)
               if targetName == GetString(AST_SETT_YOU) then
                    osiName = GetUnitDisplayName("player")
               elseif charName ~= "" and AST.groupMembers[charName] then
                    osiName = AST.groupMembers[charName]
               end
               if OSI and osiName and AST.sv.osi_support and AST.sv.teleport_strike_osi then -- See note in Defiling Blast: OSI only draws in a group, in combat
                    OSI.SetMechanicIconForUnit(osiName, "OdySupportIcons/icons/lightning-bolt.dds", 2 * OSI.GetIconSize())
                    zo_callLater(function() OSI.RemoveMechanicIconForUnit(osiName) end, 4000)
               end

               if targetName == GetString(AST_SETT_YOU) then
                    AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_NOTIF_JUMP) .. "|cff0000" .. targetName .. "|r")
               else
                    AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_NOTIF_JUMP) .. targetName)
               end

               AsylumTrackerTeleportStrike:SetHidden(false)
               -- Removes the notifcation from the screen 2 seconds after Felm's jumps on his target
               zo_callLater(function() AsylumTrackerTeleportStrike:SetHidden(true) end, 2000)

          elseif abilityId == AST.id["gusts_of_steam"] then

               -- Removed the HIDE notification from the screen 10 seconds after Olms starts jumping at his 90% 75% 50% 25% marks
               AsylumTrackerOlmsHPLabel:SetText(GetString(AST_NOTIF_OLMS_JUMP))

               AST.dbgability(abilityId, result, hitValue)
               AST.olmsJumping = true

               if AST.firstJump then -- First in sequence (first of his 4 jumps around the room, not referring to the 90% jump)
                    AST.firstJump = false
                    if AsylumTracker.olmsHealth > 80 then
                         AST.SetTimer("storm_the_heavens", 15)
                    end
                    zo_callLater(function()
                         AsylumTrackerOlmsHP:SetHidden(true)
                         AST.olmsJumping = false
                         AST.firstJump = true
                    end, 12000)
               end

          elseif abilityId == AST.id["trial_by_fire"] then

               AST.SetTimer("trial_by_fire")

               if AST.sv.trial_by_fire then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerFireLabel:SetText(GetString(AST_NOTIF_FIRE) .. "|cff0000" .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerFire:SetHidden(false)
                    zo_callLater(function() AsylumTrackerFire:SetHidden(true) end, 7000)
               end

          elseif abilityId == AST.id["scalding_roar"] and hitValue == 2300 then

               AST.SetTimer("scalding_roar")

               if AST.sv.scalding_roar then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerSteamLabel:SetText(GetString(AST_NOTIF_STEAM) .. "|cff0000" .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerSteam:SetHidden(false)
                    zo_callLater(function() AsylumTrackerSteam:SetHidden(true) end, 5000)
               end

          elseif abilityId == AST.id["exhaustive_charges"] then

               AST.SetTimer("exhaustive_charges")

               if AST.sv.exhaustive_charges then
                    AST.dbgability(abilityId, result, hitValue)
                    AsylumTrackerChargesLabel:SetText(GetString(AST_NOTIF_CHARGES) .. "|cff0000" .. GetString(AST_SETT_NOW) .. "|r")
                    AsylumTrackerCharges:SetHidden(false)
                    zo_callLater(function() AsylumTrackerCharges:SetHidden(true) end, 2000)
               end

          elseif abilityId == AST.id["manifest_wrath"] then
               -- Manifest Wrath is a homing cast: it lands where the target ends up, not where they were at cast start.
               -- So on the cast (BEGIN) we remember the target, wait for the projectile to travel, then drop a static
               -- ground marker at the target's position then. Position icons render even solo (unlike unit markers).
               AST.dbgability(abilityId, result, hitValue)
               if OSI and AST.sv.osi_support and AST.sv.maim_osi then
                    local cn = AST.GetNameForUnitId(targetUnitId)
                    local atName = (cn ~= "" and AST.groupMembers[cn]) or nil
                    if atName then
                         zo_callLater(function() -- 800ms: sample the target's position shortly after the cast, when the landing spot is projected (tune by feel)
                              local x, y, z = GetPlayerWorldPosition(atName)
                              if x then
                                   if AST.maimMarker then OSI.DiscardPositionIcon(AST.maimMarker) end -- clear a previous marker
                                   AST.maimMarker = OSI.CreatePositionIcon(x, y, z, "OdySupportIcons/icons/cross.dds", 2 * OSI.GetIconSize(), nil, 0)
                                   local marker = AST.maimMarker
                                   zo_callLater(function() -- Fixed 5s display
                                        if AST.maimMarker == marker then
                                             OSI.DiscardPositionIcon(marker)
                                             AST.maimMarker = nil
                                        end
                                   end, 5000)
                              end
                         end, 800)
                    end
               end

          end
     end

     if result == ACTION_RESULT_EFFECT_GAINED then

          if abilityId == AST.id["static_shield"] then -- Instead of tracking when the protector spawns, I track when the protector gives Olms a shield
               AST.sphereIsUp = true -- If Olms has a shield, then a protector is active
               AST.dbgability(abilityId, result, hitValue)
               AsylumTrackerSphereLabel:SetText(GetString(AST_NOTIF_PROTECTOR))
               AsylumTrackerSphere:SetHidden(false)

          elseif abilityId == AST.id["boss_event"] and hitValue == 1 then
               AST.spawnTimes[targetUnitId] = GetGameTimeSeconds();
               AST.dbg("Boss Event for [" .. targetUnitId .. "]")

          elseif abilityId == AST.id["maim"] then
               AST.dbgability(abilityId, result, hitValue)
          end
     end
     if result == ACTION_RESULT_EFFECT_FADED then

          if abilityId == AST.id["defiling_blast"] then
               AsylumTrackerBlast:SetHidden(true) -- Hides defiling blast notification when the cone ends
               if OSI and AST.blastMarkedName then -- Remove the overhead marker now the cone has actually ended
                    OSI.RemoveMechanicIconForUnit(AST.blastMarkedName)
                    AST.blastMarkedName = nil
               end

          elseif abilityId == AST.id["oppressive_bolts"] then
               AST.SetTimer("oppressive_bolts")

          elseif abilityId == AST.id["static_shield"] then -- All spheres dead, shield goes down.
               AST.sphereIsUp = false
               AsylumTrackerSphere:SetHidden(true)
          end
     end
end

function AST.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
     local boss = IdentifyBoss(unitId, abilityId, unitName) -- "llothis" / "felms" / nil, language-independent

     if boss == "llothis" then
          if not AST.LlothisSpawned then
               AST.LlothisSpawned = true
               if AST.spawnTimes[unitId] then
                    local llothis_uptime = GetGameTimeSeconds() - AST.spawnTimes[unitId]
                    if AST.sv.defiling_blast then
                         AST.SetTimer("defiling_blast", 12 - llothis_uptime)
                    end
                    if AST.sv.oppressive_bolts then
                         AST.SetTimer("oppressive_bolts", 12 - llothis_uptime)
                    end
               end
          end

     elseif boss == "felms" then
          if not AST.FelmsSpawned then
               AST.FelmsSpawned = true
               if AST.spawnTimes[unitId] then
                    local felms_uptime = GetGameTimeSeconds() - AST.spawnTimes[unitId]
                    if AST.sv.teleport_strike then
                         AST.SetTimer("teleport_strike", 12 - felms_uptime)
                    end
               end
          end
     end

     -- If Llothis or Felms' active state changes fix their timers
     if abilityId == AST.id["dormant"] then
          if changeType == EFFECT_RESULT_GAINED then
               if boss == "llothis" then

                    if AST.sv.defiling_blast then AST.SetTimer("defiling_blast", 45) end
                    if AST.sv.oppressive_bolts then AST.SetTimer("oppressive_bolts", 45) end

                    AST.SetTimer("llothis_dormant")

                    if AST.sv["llothis_notifications"] then
                         AST.CreateNotification("|c00ff00" .. GetString(AST_NOTIF_LLOTHIS_DOWN) .. "|r", 3000)
                    end

               elseif boss == "felms" then

                    if AST.sv.teleport_strike then
                         AST.SetTimer("teleport_strike", 45)
                         AsylumTrackerTeleportStrike:SetHidden(true)
                    end

                    AST.SetTimer("felms_dormant")

                    if AST.sv["felms_notifications"] then
                         AST.CreateNotification("|c00ff00" .. GetString(AST_NOTIF_FELMS_DOWN) .. "|r", 3000)
                    end
               end
          elseif changeType == EFFECT_RESULT_FADED then

               if boss == "llothis" then
                    AST.SetTimer("llothis_dormant", 0)

                    if AST.sv["llothis_notifications"] then
                         AST.CreateNotification("|ce34234" .. GetString(AST_NOTIF_LLOTHIS_UP) .. "|r", 3000)
                    end

               elseif boss == "felms" then

                    AST.SetTimer("felms_dormant", 0)

                    if AST.sv["felms_notifications"] then
                         AST.CreateNotification("|ce34234" .. GetString(AST_NOTIF_FELMS_UP) .. "|r", 3000)
                    end
               end
          end
     end
end
