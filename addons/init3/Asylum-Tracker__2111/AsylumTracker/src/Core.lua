AsylumTracker = AsylumTracker or {}
local AST = AsylumTracker
local EM = EVENT_MANAGER

local ASYLUM_SANCTORIUM = 1000

AST.name = "AsylumTracker"
AST.author = "init3 [NA]"
AST.version = "2.0.5"
AST.variableVersion = 1
AST.lang = {}
AST.fontSize = 48
AST.isMovable = false
AST.olmsHealth = 100
AST.isInVAS = false
AST.isInCombat = false
AST.olmsJumping = false
AST.firstJump = true
AST.initialStormOccured = false
AST.spawnTimes = {}
AST.LlothisSpawned = false
AST.FelmsSpawned = false
AST.LlothisLastNotified = 0
AST.FelmsLastNotified = 0
AST.soundPlayed = false
AST.isRegistered = false
AST.sphereIsUp = false
AST.groupMembers = {}
AST.refreshRate = 500
AST.displayName = UndecorateDisplayName(GetUnitDisplayName("player"))
AST.displayResolution = {
     width = GuiRoot:GetWidth(),
     height = GuiRoot:GetHeight()
}

AST.id = {
     -- Olms' Mechanics
     storm_the_heavens = 98535,
     trial_by_fire = 98582, -- Fire below 25% HP
     scalding_roar = 98683, -- Steam Breath
     gusts_of_steam = 98868, -- The jumps at 90/75/50/25% HP
     exhaustive_charges = 95482,
     static_shield = 96010, -- Shield provided by protectors

     -- Llothis' Mechanics
     defiling_blast = 95545,
     oppressive_bolts = 95585,

     -- Felms' Mechanics
     teleport_strike = 99138,
     maim = 95657,

     -- Felms and Llothis
     dormant = 99990, -- Whether Felms and Llothis are active or not
     boss_event = 10298, -- Used for determining the exact spawn time for Llothis and Felms

     -- Abilities for Interrupting
     bash = 21973,
     force_shock = 48010,
     deep_breath = 32797,
     charge = 26508,
     poison_arrow = 38648,
     shrouded_daggers = 38914,
}

AST.defaults = {
     -- Debugging
     debug = false,
     debug_ability = false,
     debug_timers = false,
     debug_units = false,

     -- Settings
     languageOverride = false,
     chosenLocale = "en",
     sound_enabled = true,
     llothis_notifications = true,
     felms_notifications = true,
     adjust_timers_olms = false,
     adjust_timers_llothis = false,

     -- Abilities
     interrupt_message = "Toxic",
     sphere_message_toggle = false,
     sphere_message = "SPHERE",
     storm_the_heavens = true,
     defiling_blast = true,
     static_shield = true,
     teleport_strike = false,
     oppressive_bolts = false,
     trial_by_fire = false,
     scalding_roar = false,
     exhaustive_charges = false,
     maim = false,

     -- XML Offsets
     olms_hp_offsetX = AST.displayResolution["width"] / 1.7,
     olms_hp_offsetY = 330,
     storm_offsetX = AST.displayResolution["width"] / 1.7,
     storm_offsetY = 380,
     blast_offsetX = AST.displayResolution["width"] / 1.7,
     blast_offsetY = 430,
     sphere_offsetX = AST.displayResolution["width"] / 1.7,
     sphere_offsetY = 480,
     teleport_strike_offsetX = AST.displayResolution["width"] / 1.7,
     teleport_strike_offsetY = 530,
     oppressive_bolts_offsetX = AST.displayResolution["width"] / 1.7,
     oppressive_bolts_offsetY = 580,
     fire_offsetX = AST.displayResolution["width"] / 1.7,
     fire_offsetY = 630,
     steam_offsetX = AST.displayResolution["width"] / 1.7,
     steam_offsetY = 680,
     maim_offsetX = AST.displayResolution["width"] / 1.7,
     maim_offsetY = 730,
     exhaustive_charges_offsetX = AST.displayResolution["width"] / 1.7,
     exhaustive_charges_offsetY = 780,

     -- Font Sizes
     font_size = 38,
     font_size_olms_hp = 38,
     font_size_storm = 38,
     font_size_blast = 38,
     font_size_sphere = 38,
     font_size_teleport_strike = 38,
     font_size_oppressive_bolts = 38,
     font_size_fire = 38,
     font_size_scalding_roar = 38,
     font_size_maim = 38,
     font_size_exhaustive_charges = 38,

     -- Notification Scale
     olms_hp_scale = 1,
     storm_scale = 1,
     blast_scale = 1,
     sphere_scale = 1,
     teleport_strike_scale = 1,
     oppressive_bolts_scale = 1,
     fire_scale = 1,
     scalding_roar_scale = 1,
     maim_scale = 1,
     exhaustive_charges_scale = 1,

     -- Colors
     color_timer = {0.81, .37, .03},
     color_olms_hp = {1, 0.4, 0, 1},
     color_olms_hp2 = {1, 0, 0, 1},
     color_storm = {1, 1, 1, 1},
     color_storm2 = {1, 1, 0, 1},
     color_blast = {0, 1, 0, 1},
     color_sphere = {0, 0, 1, 1},
     color_sphere2 = {1, 0, 0, 1},
     color_teleport_strike = {1, 0, 1, 1},
     color_oppressive_bolts = {0, 0, 1, 1},
     color_fire = {1, 0.4, 0, 1},
     color_scalding_roar = {0.5, 0.05, 1, 1},
     color_maim = {0.2, 0.93, .79, 1},
     color_exhaustive_charges = {0.18, 0.37, 0.45, 1},

     -- Sound Effects
     storm_the_heavens_sound = "BATTLEGROUND_CAPTURE_FLAG_CAPTURED_BY_OWN_TEAM",
     storm_the_heavens_volume = 1,
     defiling_blast_sound = "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM",
     defiling_blast_volume = 1,
}

-- The time remaining until the next instance of a mechanic. If this is at 0, the function for updating timers will ignore it.
AST.timers = {
     storm_the_heavens = 0,
     defiling_blast = 0,
     teleport_strike = 0,
     oppressive_bolts = 0,
     scalding_roar = 0,
     maim = 0,
     exhaustive_charges = 0,
     trial_by_fire = 0,
     felms_dormant = 0,
     llothis_dormant = 0,
}

-- The game time in seconds that a mechanic is predicted to happen.
AST.endTimes = {
     storm_the_heavens = 0,
     defiling_blast = 0,
     teleport_strike = 0,
     oppressive_bolts = 0,
     scalding_roar = 0,
     maim = 0,
     exhaustive_charges = 0,
     trial_by_fire = 0,
     felms_dormant = 0,
     llothis_dormant = 0,
}

-- Used for formatting the GetGameTimeSeconds in the debug functions
local function round(number, decimalPlaces)
     local mult = 10^(decimalPlaces or 0)
     local value = zo_floor(number * mult + 0.5) / mult
     local decimal = tostring(value):match("%.(%d+)")
     if decimal then
          if #decimal == nil then
               value = value .. "000"
          elseif #decimal == 1 then
               value = value .. "00"
          elseif #decimal == 2 then
               value = value .. "0"
          end
          return value
     else
          return value .. ".000"
     end
end

-- The colors for mechanics are stored in rgb format. For use in strings it needs to be converted to hex. This will drop any alpha value for the saved color
function AST.RGBToHex(r, g, b)
     r = string.format("%x", r * 255)
     g = string.format("%x", g * 255)
     b = string.format("%x", b * 255)
     if #r < 2 then r = "0" .. r end
     if #g < 2 then g = "0" .. g end
     if #b < 2 then b = "0" .. b end
     return r .. g .. b
end

-------------------------
-- Debugging functions --
-------------------------
function AST.dbg(text)
     if AST.sv.debug then
          d("|cff0096AsylumTracker [" .. round(GetGameTimeSeconds(), 3) .. "] ::|r|c992A18 " .. text .. "|r")
     end
end

function AST.dbgability(abilityId, result, hitValue)
     if abilityId and result and hitValue then
          if AST.sv.debug_ability then
               d("|cff0096AsylumTracker [" .. round(GetGameTimeSeconds(), 3) .. "] ::|r|c184599 " .. GetAbilityName(abilityId) .. " (" .. abilityId .. ") with a result of " .. result .. " and a hit value of " .. hitValue)
          end
     end
end

function AST.dbgtimers(text)
     if AST.sv.debug_timers then
          d("|cff0096AsylumTracker [" .. round(GetGameTimeSeconds(), 3) .. "] ::|r|c02731E " .. text .. "|r")
     end
end

function AST.dbgunits(text)
     if AST.sv.debug_units then
          d("|cff0096AsylumTracker [" .. round(GetGameTimeSeconds(), 3) .. "] ::|r|c992A18 " .. text .. "|r")
     end
end

-- Whenever the player loads into a new area, checks to see if the player is in Asylum Sanctorium, and (un)registers needed events
local function OnPlayerActivated()
     local zone = zo_strformat("<<C:1>>", GetUnitZone("player"))
     local asylum = zo_strformat("<<C:1>>", GetZoneNameById(ASYLUM_SANCTORIUM))
     if zone == asylum then
          AST.isInVAS = true
          AST.dbg("Entering Asylum Sanctorium")
          if not AST.isRegistered then
               AST.RegisterEvents()
               AST.dbg("Events Registered.")
               AST.isRegistered = true
          end
     else
          AST.isInVAS = false
          AST.dbg("Not in Asylum Sanctorium.")
          if AST.isRegistered then
               AST.UnregisterEvents()
               AST.dbg("Events Unregistered.")
               AST.isRegistered = false
          end
     end
end

-- Function for setting the mechanic timers
function AST.SetTimer(key, timer_override, endtime_override)
     local duration
     if key == "storm_the_heavens" then
          duration = timer_override or 41
     elseif key == "defiling_blast" then
          duration = timer_override or 21
     elseif key == "teleport_strike" then
          duration = timer_override or 21
     elseif key == "oppressive_bolts" then
          duration = timer_override or 12
     elseif key == "exhaustive_charges" then
          duration = timer_override or 12
     elseif key == "scalding_roar" then
          duration = timer_override or 28
     elseif key == "trial_by_fire" then
          duration = timer_override or 27
     elseif key == "llothis_dormant" then
          duration = timer_override or 45
     elseif key == "felms_dormant" then
          duration = timer_override or 45
     elseif key == "maim" then
          duration = timer_override or 15
     end
     AST.timers[key] = duration
     AST.endTimes[key] = endtime_override or (GetGameTimeSeconds() + duration)
end

--
local function UpdateMaimedStatus()
     if AST.sv.maim then
          for i = 1, 50 do
               local buffName, timeStarted, timeEnding, buffSlot, stackCount, fileName, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
               if abilityId == AST.id.maim then
                    local timerState = AST.timers.maim
                    local timeRemaining = timeEnding - GetGameTimeSeconds()
                    local diff = zo_abs(timerState - timeRemaining)
                    if diff > 0.15 then
                         AST.SetTimer("maim", timeEnding - GetGameTimeSeconds(), timeEnding)
                         AST.dbg("Updated Maim timer to " .. AST.timers.maim .. " seconds.")
                    end
                    break
               elseif abilityId == nil or abilityId == "" or abilityId == 0 then
                    break
               end
          end
     end
end

-- Creates a notification using Center_Screen_Announce. This is called when Llothis/Felms switch between active and dormant.
function AST.CreateNotification(text, duration)
     if type(text) ~= "string" then
          AST.dbg("Attempt to create a Center Screen Announce notification terminated due to an invalid text value")
          return
     elseif type(duration) ~= "number" then
          AST.dbg("Attempt to create a Center Screen Announce notification terminated due to an invalid duration value")
          return
     end
     local CSA = CENTER_SCREEN_ANNOUNCE
     local params = CSA:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)
     params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
     params:SetText(text)
     params:SetLifespanMS(duration)
     CSA:AddMessageWithParams(params)
end

-- Looping a sound effect makes it louder. Used for changing the volume of sound notifications
function AST.LoopSound(numberOfLoops, soundEffect)
     for i = 1, numberOfLoops do
          PlaySound(SOUNDS[soundEffect])
     end
end

-- Creates an alphabetically sorted table of sounds.
-- WARNING: This is very taxing; however, it is only called when initially loading the addon (Loading into the game / reloadui), so it does not effect performance while playing.
function AST.GetSounds()
     local sounds = {}
     for key, value in pairs(SOUNDS) do
          sounds[#sounds + 1] = key
          table.sort(sounds)
     end
     return sounds
end

-- Sort function used for creating a table of Olms' mechanics in order of occurance.
local function SortTimers(tbl, sortFunction)
     local keys = {}
     for key in pairs(tbl) do
          table.insert(keys, key)
     end

     table.sort(keys, function(a, b)
          return sortFunction(tbl[a], tbl[b])
     end)
     return keys
end

-- Adjusts Olms' timers to correct for another of his mechanics occuring while the next mechanic is queued to occur
function AST.AdjustTimersOlms()
     if AST.sv.adjust_timers_olms then
          local unsorted_timers = {}
          local durations = { -- The amount of time for Olms to cast the ability and recover to cast his next ability
               trial_by_fire = 8,
               storm_the_heavens = 7,
               scalding_roar = 6,
               exhaustive_charges = 2,
          }

          if AST.timers.storm_the_heavens > 0 and AST.initialStormOccured then unsorted_timers["storm_the_heavens"] = AST.timers.storm_the_heavens end
          if AST.timers.trial_by_fire > 0 then unsorted_timers["trial_by_fire"] = AST.timers.trial_by_fire end
          if AST.timers.exhaustive_charges > 0 then unsorted_timers["exhaustive_charges"] = AST.timers.exhaustive_charges end
          if AST.timers.scalding_roar > 0 then unsorted_timers["scalding_roar"] = AST.timers.scalding_roar end

          local sortFunction = function(a, b) return a < b end
          local sorted_timers = SortTimers(unsorted_timers, sortFunction)

          if #sorted_timers >= 2 then
               for i = 1, #sorted_timers - 1 do
                    local timer1, timer2 = AST.timers[sorted_timers[i]], AST.timers[sorted_timers[i + 1]]
                    local endTime1, endTime2 = AST.endTimes[sorted_timers[i]], AST.endTimes[sorted_timers[i + 1]]
                    local duration1 = durations[sorted_timers[i]]
                    if (timer2 - timer1) < duration1 then
                         if (timer2 - timer1) >= 1 then
                              local old_timeRemaining = timer2
                              local new_timeRemaining = timer2 + (duration1 - (timer2 - timer1))
                              local new_endTime = endTime2 + (duration1 - (endTime2 - endTime1))
                              if zo_abs(new_timeRemaining - old_timeRemaining) > 0.15 then
                                   AST.SetTimer(sorted_timers[i + 1], new_timeRemaining, new_endTime)
                                   AST.dbg("Updated timer for " .. sorted_timers[i + 1] .. " to " .. AST.timers[sorted_timers[i + 1]])
                              end
                         end
                    end
               end
          end
     end
end

-- Adjusts Llothis' Oppressive Bolts timer to correct for his Defiling Blast mechanic occuring first.
function AST.AdjustTimersLlothis()
     if AST.sv.adjust_timers_llothis then
          local db, ob = AST.timers.defiling_blast, AST.timers.oppressive_bolts
          local db_end, ob_end, ec_end = AST.endTimes.defiling_blast, AST.endTimes.oppressive_bolts
          if (ob > db) then
               if (ob - db < 7) and (ob - db >= 2) and (db > 0) then
                    AST.SetTimer("oppressive_bolts", ob + (7 - (ob - db)), ob_end + (7 - (ob_end - db_end)))
                    AST.dbg("[ob > db]: Updated Oppressive Bolts timer to: " .. AST.timers.oppressive_bolts)
               end
          end
     end
end

-- Decreases the timers.
-- EM:RegisterForUpdate(AST.name .. "_updateTimers", AST.refreshRate, AST.UpdateTimers) in EventHandling.lua
function AST.UpdateTimers()
     if AST.isInCombat then
          AST.AdjustTimersOlms()
          AST.AdjustTimersLlothis()
          UpdateMaimedStatus()

          for key, value in pairs(AST.timers) do -- The key is the ability and the value is the endTime for the event
               if AST.timers[key] > 0 then -- If there is a timer for the specified key event
                    AST.timers[key] = (AST.endTimes[key] - GetGameTimeSeconds())
                    if AST.timers[key] < 0 then AST.SetTimer(key, 0) end

                    local timeRemaining = AST.timers[key]
                    AST.dbgtimers(key .. ": " .. round(timeRemaining, 3))

                    if key == "storm_the_heavens" and timeRemaining < 6 and AST.sv.storm_the_heavens then
                         AsylumTrackerStorm:SetHidden(false)
                         if timeRemaining >= 1 then
                              AsylumTrackerStormLabel:SetText(GetString(AST_NOTIF_KITE) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                         else
                              AsylumTrackerStormLabel:SetText(GetString(AST_NOTIF_KITE) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON).. "|r")
                         end

                         if timeRemaining > 0 and not AST.soundPlayed then
                              if AST.sv["sound_enabled"] then
                                   AST.soundPlayed = true
                                   AST.LoopSound(AST.sv.storm_the_heavens_volume, AST.sv.storm_the_heavens_sound)
                                   zo_callLater(function() AST.soundPlayed = false end, 900)
                              end
                         end

                    elseif key == "defiling_blast" and timeRemaining < 6 then
                         if timeRemaining >= 1 then
                              AsylumTrackerBlastLabel:SetText(GetString(AST_NOTIF_BLAST) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                              AsylumTrackerBlast:SetHidden(false)
                         else
                              AsylumTrackerBlastLabel:SetText(GetString(AST_NOTIF_BLAST) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                              AsylumTrackerBlast:SetHidden(false)
                         end

                         if timeRemaining > 0 and not AST.soundPlayed then
                              if AST.sv["sound_enabled"] then
                                   AST.soundPlayed = true
                                   AST.LoopSound(AST.sv.defiling_blast_volume, AST.sv.defiling_blast_sound)
                                   zo_callLater(function() AST.soundPlayed = false end, 900)
                              end
                         end

                    elseif key == "teleport_strike" and timeRemaining < 6 then
                         if timeRemaining >= 1 then
                              AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_NOTIF_JUMP) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                              AsylumTrackerTeleportStrike:SetHidden(false)
                         else
                              AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_NOTIF_JUMP) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                              AsylumTrackerTeleportStrike:SetHidden(false)
                         end

                    elseif key == "oppressive_bolts" then
                         if timeRemaining >= 1 then
                              AsylumTrackerOppressiveBoltsLabel:SetText(GetString(AST_NOTIF_BOLTS) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                         else
                              AsylumTrackerOppressiveBoltsLabel:SetText(GetString(AST_NOTIF_BOLTS) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                         end
                         AsylumTrackerOppressiveBolts:SetHidden(false)

                    elseif key == "exhaustive_charges" and timeRemaining < 6 and AST.sv.exhaustive_charges then
                         if timeRemaining >= 1 then
                              AsylumTrackerChargesLabel:SetText(GetString(AST_NOTIF_CHARGES) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                              AsylumTrackerCharges:SetHidden(false)
                         else
                              AsylumTrackerChargesLabel:SetText(GetString(AST_NOTIF_CHARGES) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                              AsylumTrackerCharges:SetHidden(false)
                         end

                    elseif key == "scalding_roar" and timeRemaining < 6 and AST.sv.scalding_roar then
                         if timeRemaining >= 1 then
                              AsylumTrackerSteamLabel:SetText(GetString(AST_NOTIF_STEAM) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                              AsylumTrackerSteam:SetHidden(false)
                         else
                              AsylumTrackerSteamLabel:SetText(GetString(AST_NOTIF_STEAM) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                              AsylumTrackerSteam:SetHidden(false)
                         end

                    elseif key == "trial_by_fire" and timeRemaining < 6 and AST.sv.trial_by_fire then
                         if timeRemaining >= 1 then
                              AsylumTrackerFireLabel:SetText(GetString(AST_NOTIF_FIRE) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                              AsylumTrackerFire:SetHidden(false)
                         else
                              AsylumTrackerFireLabel:SetText(GetString(AST_NOTIF_FIRE) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. GetString(AST_SETT_SOON) .. "|r")
                              AsylumTrackerFire:SetHidden(false)
                         end
                         AsylumTrackerFire:SetHidden(false)

                    elseif key == "llothis_dormant" then
                         if zo_floor(timeRemaining) == 10 then
                              if AST.sv["llothis_notifications"] and (GetGameTimeSeconds() - AST.LlothisLastNotified > 2.5) then
                                   AST.CreateNotification("|cff9933" .. GetString(AST_NOTIF_LLOTHIS_IN_10) .. "|r", 3000)
                                   AST.LlothisLastNotified = GetGameTimeSeconds()
                              end

                         elseif zo_floor(timeRemaining) == 5 then
                              if AST.sv["llothis_notifications"] and (GetGameTimeSeconds() - AST.LlothisLastNotified > 2.5) then
                                   AST.CreateNotification("|cff9933" .. GetString(AST_NOTIF_LLOTHIS_IN_5) .. "|r", 3000)
                                   AST.LlothisLastNotified = GetGameTimeSeconds()
                              end
                         end

                    elseif key == "felms_dormant" then
                         if zo_floor(timeRemaining) == 10 then
                              if AST.sv["felms_notifications"] and (GetGameTimeSeconds() - AST.FelmsLastNotified > 2.5) then
                                   AST.CreateNotification("|cff9933" .. GetString(AST_NOTIF_FELMS_IN_10) .. "|r", 3000)
                                   AST.FelmsLastNotified = GetGameTimeSeconds()
                              end

                         elseif zo_floor(timeRemaining) == 5 then
                              if AST.sv["felms_notifications"] and (GetGameTimeSeconds() - AST.FelmsLastNotified > 2.5) then
                                   AST.CreateNotification("|cff9933" .. GetString(AST_NOTIF_FELMS_IN_5) .. "|r", 3000)
                                   AST.FelmsLastNotified = GetGameTimeSeconds()
                              end
                         end

                    elseif key == "maim" then
                         if timeRemaining >= 0.5 then
                              if AST.sv["maim"] then
                                   AsylumTrackerMaimLabel:SetText(GetString(AST_NOTIF_MAIM) .. "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3]) .. zo_floor(timeRemaining) .. "|r")
                                   AsylumTrackerMaim:SetHidden(false)
                              else
                                   AsylumTrackerMaim:SetHidden(true)
                              end
                         else
                              AsylumTrackerMaim:SetHidden(true)
                         end
                    end
               end
          end
     else -- If not in Asylum AND in combat, clear any running timers
          for key, value in pairs(AST.timers) do
               AST.SetTimer(key, 0)
          end
     end
end

-- Gets Olms' HP and displays his HP% on screen when close to the 90/75/50/25 Jump Percentages
-- EM:RegisterForUpdate(AST.name .. "_monitorOlmsHP", AST.refreshRate, AST.MonitorOlmsHP) in EventHandling.lua
function AST.MonitorOlmsHP()
     local bossName = zo_strformat("<<C:1>>", GetUnitName("boss1"))
     if bossName ~= "" then -- HP for Boss1 (Since the addon only loads in Asylum, this works for determining if you're in the room with Olms, because if you are not, this function returns an empty string)
          local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
          AST.olmsHealth = tostring(zo_floor(string.format("%.1f", current / max * 100))) -- Format's Olm's health as a percentage
          if not AST.olmsJumping then
               if AST.olmsHealth >= "90" and AST.olmsHealth <= "95" then
                    if AST.olmsHealth >= "92" then
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp[1], AST.sv.color_olms_hp[2], AST.sv.color_olms_hp[3], AST.sv.color_olms_hp[4])
                         AsylumTrackerOlmsHP:SetHidden(false)
                    else
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp2[1], AST.sv.color_olms_hp2[2], AST.sv.color_olms_hp2[3], AST.sv.color_olms_hp2[4])
                    end
               elseif AST.olmsHealth >= "75" and AST.olmsHealth <= "80" then
                    if AST.olmsHealth >= "77" then
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp[1], AST.sv.color_olms_hp[2], AST.sv.color_olms_hp[3], AST.sv.color_olms_hp[4])
                         AsylumTrackerOlmsHP:SetHidden(false)
                    else
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp2[1], AST.sv.color_olms_hp2[2], AST.sv.color_olms_hp2[3], AST.sv.color_olms_hp2[4])
                    end
               elseif AST.olmsHealth >= "50" and AST.olmsHealth <= "55" then
                    if AST.olmsHealth >= "52" then
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp[1], AST.sv.color_olms_hp[2], AST.sv.color_olms_hp[3], AST.sv.color_olms_hp[4])
                         AsylumTrackerOlmsHP:SetHidden(false)
                    else
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp2[1], AST.sv.color_olms_hp2[2], AST.sv.color_olms_hp2[3], AST.sv.color_olms_hp2[4])
                    end
               elseif AST.olmsHealth >= "25" and AST.olmsHealth <= "30" then
                    if AST.olmsHealth >= "27" then
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp[1], AST.sv.color_olms_hp[2], AST.sv.color_olms_hp[3], AST.sv.color_olms_hp[4])
                         AsylumTrackerOlmsHP:SetHidden(false)
                    else
                         AsylumTrackerOlmsHPLabel:SetText(AST.olmsHealth .. "%")
                         AsylumTrackerOlmsHPLabel:SetColor(AST.sv.color_olms_hp2[1], AST.sv.color_olms_hp2[2], AST.sv.color_olms_hp2[3], AST.sv.color_olms_hp2[4])
                    end
               end
          end
     end
end

-- The Sphere and Kite notifications alternate between 2 colors. This swaps between them
-- EM:RegisterForUpdate(AST.name .. "_alternateColors", 1000, AST.AlternateNotificationColors) in EventHandling.lua
function AST.AlternateNotificationColors()
     if AST.sphereIsUp then
          r, g, b, a = AsylumTrackerSphereLabel:GetColor()
          local firstColor = AST.sv["color_sphere"]
          r = string.format("%.2f", r)
          g = string.format("%.2f", g)
          b = string.format("%.2f", b)
          firstColor[1] = string.format("%.2f", firstColor[1])
          firstColor[2] = string.format("%.2f", firstColor[2])
          firstColor[3] = string.format("%.2f", firstColor[3])
          if r == firstColor[1] and g == firstColor[2] and b == firstColor[3] then
               AsylumTrackerSphereLabel:SetColor(AST.sv.color_sphere2[1], AST.sv.color_sphere2[2], AST.sv.color_sphere2[3], AST.sv.color_sphere2[4])
          else
               AsylumTrackerSphereLabel:SetColor(AST.sv.color_sphere[1], AST.sv.color_sphere[2], AST.sv.color_sphere[3], AST.sv.color_sphere[4])
          end
     end
     if AST.stormIsActive then
          r, g, b, a = AsylumTrackerStormLabel:GetColor()
          local firstColor = AST.sv["color_storm"]
          r = string.format("%.2f", r)
          g = string.format("%.2f", g)
          b = string.format("%.2f", b)
          firstColor[1] = string.format("%.2f", firstColor[1])
          firstColor[2] = string.format("%.2f", firstColor[2])
          firstColor[3] = string.format("%.2f", firstColor[3])
          if r == firstColor[1] and g == firstColor[2] and b == firstColor[3] then
               AsylumTrackerStormLabel:SetColor(AST.sv.color_storm2[1], AST.sv.color_storm2[2], AST.sv.color_storm2[3], AST.sv.color_storm2[4])
          else
               AsylumTrackerStormLabel:SetColor(AST.sv.color_storm[1], AST.sv.color_storm[2], AST.sv.color_storm[3], AST.sv.color_storm[4])
          end
     end
end

-- Creates a table containing the members of your group's character names with their display names. This is needed to show display names when a mechanic targets a player
function AST.IndexGroupMembers()
     AST.groupMembers = {}
     local groupSize = GetGroupSize()
     if groupSize == 0 then
          AST.groupMembers[GetUnitName("player")] = GetUnitDisplayName("player")
     else
          for i = 1, GROUP_SIZE_MAX do
               local memberCharacterName = GetUnitName("group" .. i)
               if memberCharacterName ~= nil then
                    local memberDisplayName = GetUnitDisplayName("group" .. i)
                    AST.groupMembers[memberCharacterName] = memberDisplayName
               end
          end
     end
end

function AST.CombatState(event, isInCombat)
     if isInCombat ~= AST.isInCombat then
          AST.isInCombat = isInCombat
          if isInCombat then
               AST.IndexGroupMembers() -- Creates a table of group members character names to display names every time you enter combat.
               AST.unitIds = {}
          else
               -- When you exit combat, this will remove any notifications that were on your screen when you left combat.
               AsylumTrackerOlmsHP:SetHidden(true)
               AsylumTrackerStorm:SetHidden(true)
               AsylumTrackerBlast:SetHidden(true)
               AsylumTrackerOppressiveBolts:SetHidden(true)
               AsylumTrackerSphere:SetHidden(true)
               AsylumTrackerTeleportStrike:SetHidden(true)
               AsylumTrackerFire:SetHidden(true)
               AsylumTrackerSteam:SetHidden(true)
               AsylumTrackerMaim:SetHidden(true)
               AsylumTrackerCharges:SetHidden(true)

               -- Resets Llothis and Felms spawn state for if a group wipes.
               AST.LlothisSpawned = false
               AST.FelmsSpawned = false
               AST.initialStormOccured = false
               AST.dbg("Resetting Llothis and Felms spawn status")

               AST.unitIds = {}
               AST.dbgunits("Leaving Combat. Clearing Units Table")
               AST.spawnTimes = {}
          end
     end
end

-- Initialization function
function AST.Initialize()
     AST.savedVars = ZO_SavedVars:NewCharacterIdSettings("AsylumTrackerVars", AST.variableVersion, nil, AST.defaults) -- Defines saved variables
     AST.sv = AsylumTrackerVars["Default"][GetDisplayName()][GetCurrentCharacterId()]

     AST.lang.en.LoadStrings() -- Always Load English Strings first because the other locale files may not have every string translated
     if not AsylumTracker.sv.languageOverride then
          local locale = GetCVar("language.2")
          if locale ~= "en" then
               AST.lang[locale].LoadStrings()
          end
     else
          AST.lang[AST.sv.chosenLocale].LoadStrings()
     end

     AST.CreateSettingsWindow() -- Creates the addon settings menu
     AST.RegisterUnitIndexing()
     AST.ResetAnchors()

     AST.SetFontSize(AsylumTrackerOlmsHP, AsylumTrackerOlmsHPLabel, AST.sv.font_size_olms_hp)
     AST.SetFontSize(AsylumTrackerStorm, AsylumTrackerStormLabel, AST.sv.font_size_storm)
     AST.SetFontSize(AsylumTrackerBlast, AsylumTrackerBlastLabel, AST.sv.font_size_blast)
     AST.SetFontSize(AsylumTrackerSphere, AsylumTrackerSphereLabel, AST.sv.font_size_sphere)
     AST.SetFontSize(AsylumTrackerTeleportStrike, AsylumTrackerTeleportStrikeLabel, AST.sv.font_size_teleport_strike)
     AST.SetFontSize(AsylumTrackerOppressiveBolts, AsylumTrackerOppressiveBoltsLabel, AST.sv.font_size_oppressive_bolts)
     AST.SetFontSize(AsylumTrackerFire, AsylumTrackerFireLabel, AST.sv.font_size_fire)
     AST.SetFontSize(AsylumTrackerSteam, AsylumTrackerSteamLabel, AST.sv.font_size_scalding_roar)
     AST.SetFontSize(AsylumTrackerMaim, AsylumTrackerMaimLabel, AST.sv.font_size_maim)
     AST.SetFontSize(AsylumTrackerCharges, AsylumTrackerChargesLabel, AST.sv.font_size_exhaustive_charges)

     AST.SetScale(AsylumTrackerOlmsHPLabel, AST.sv["olms_hp_scale"])
     AST.SetScale(AsylumTrackerStormLabel, AST.sv["storm_scale"])
     AST.SetScale(AsylumTrackerBlastLabel, AST.sv["blast_scale"])
     AST.SetScale(AsylumTrackerSphereLabel, AST.sv["sphere_scale"])
     AST.SetScale(AsylumTrackerTeleportStrikeLabel, AST.sv["teleport_strike_scale"])
     AST.SetScale(AsylumTrackerOppressiveBoltsLabel, AST.sv["oppressive_bolts_scale"])
     AST.SetScale(AsylumTrackerFireLabel, AST.sv["fire_scale"])
     AST.SetScale(AsylumTrackerSteamLabel, AST.sv["scalding_roar_scale"])
     AST.SetScale(AsylumTrackerMaimLabel, AST.sv["maim_scale"])
     AST.SetScale(AsylumTrackerChargesLabel, AST.sv["exhaustive_charges_scale"])

     if AST.sv.sphere_message_toggle then
          ZO_CreateStringId("AST_NOTIF_PROTECTOR", AST.sv.sphere_message)
     end

     AST.IndexGroupMembers()

     SLASH_COMMANDS["/astracker"] = AST.SlashCommand
end

function AST.OnAddOnLoaded(event, addonName)
     if AST.name ~= addonName then return end
     EM:RegisterForEvent(AST.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
     AST.Initialize()
     EM:UnregisterForEvent(AST.name, EVENT_ADD_ON_LOADED) -- Unregisters the OnAddOnLoaded Function
end

EM:RegisterForEvent(AST.name, EVENT_ADD_ON_LOADED, AST.OnAddOnLoaded)
