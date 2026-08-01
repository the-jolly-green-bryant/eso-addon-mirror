AsylumTracker = AsylumTracker or {}
local AST = AsylumTracker
local EM = EVENT_MANAGER

local ASYLUM_SANCTORIUM = 1000

AST.name = "AsylumTracker"
AST.author = "init3 [NA] and justinsane16"
AST.version = "3.0.0"
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
AST.stormIsActive = false
AST.spawnTimes = {}
AST.LlothisSpawned = false
AST.FelmsSpawned = false
AST.LlothisLastNotified = 0
AST.FelmsLastNotified = 0
AST.soundPlayed = false
AST.isRegistered = false
AST.sphereIsUp = false
AST.sphereColorToggle = false
AST.stormColorToggle = false
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
     trial_by_fire = 98582,  -- Fire below 25% HP
     scalding_roar = 98683,  -- Steam Breath
     gusts_of_steam = 98868, -- The jumps at 90/75/50/25% HP
     exhaustive_charges = 95482,
     static_shield = 96010,  -- Shield provided by protectors

     -- Llothis' Mechanics
     defiling_blast = 95545,
     oppressive_bolts = 95585,

     -- Felms' Mechanics
     teleport_strike = 99138,
     maim = 95657,

     -- Felms and Llothis
     dormant = 99990,    -- Whether Felms and Llothis are active or not
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
     olms_hp_offsetX = AST.displayResolution.width / 1.7,
     olms_hp_offsetY = 330,
     storm_offsetX = AST.displayResolution.width / 1.7,
     storm_offsetY = 380,
     blast_offsetX = AST.displayResolution.width / 1.7,
     blast_offsetY = 430,
     sphere_offsetX = AST.displayResolution.width / 1.7,
     sphere_offsetY = 480,
     teleport_strike_offsetX = AST.displayResolution.width / 1.7,
     teleport_strike_offsetY = 530,
     oppressive_bolts_offsetX = AST.displayResolution.width / 1.7,
     oppressive_bolts_offsetY = 580,
     fire_offsetX = AST.displayResolution.width / 1.7,
     fire_offsetY = 630,
     steam_offsetX = AST.displayResolution.width / 1.7,
     steam_offsetY = 680,
     maim_offsetX = AST.displayResolution.width / 1.7,
     maim_offsetY = 730,
     exhaustive_charges_offsetX = AST.displayResolution.width / 1.7,
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

-- A value of 0 means the timer is inactive and will be ignored by UpdateTimers.
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

-- The absolute game time (seconds) at which a mechanic is predicted to fire.
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

function AST.RGBToHex(r, g, b)
     return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function AST.CacheTimerHex()
     AST.cachedTimerHex = "|c" .. AST.RGBToHex(AST.sv.color_timer[1], AST.sv.color_timer[2], AST.sv.color_timer[3])
end

local COLOR_ACCENT = "ff0096"
local COLOR_RED    = "992A18"
local COLOR_BLUE   = "184599"
local COLOR_GREEN  = "02731E"
local COLOR_NOTIF  = "ff9933"

local function dbgMsg(color, text)
     d("|c" .. COLOR_ACCENT .. "AsylumTracker [" .. string.format("%.3f", GetGameTimeSeconds()) .. "] ::|r|c" .. color .. " " .. text .. "|r")
end

-------------------------
-- Debugging functions --
-------------------------
function AST.dbg(text)
     if AST.sv.debug then dbgMsg(COLOR_RED, text) end
end

function AST.dbgability(abilityId, result, hitValue)
     if abilityId and result and hitValue and AST.sv.debug_ability then
          dbgMsg(COLOR_BLUE, GetAbilityName(abilityId) .. " (" .. abilityId .. ") with a result of " .. result .. " and a hit value of " .. hitValue)
     end
end

function AST.dbgtimers(text)
     if AST.sv.debug_timers then dbgMsg(COLOR_GREEN, text) end
end

function AST.dbgunits(text)
     if AST.sv.debug_units then dbgMsg(COLOR_RED, text) end
end

-- Whenever the player loads into a new area, checks if they are in Asylum Sanctorium and (un)registers events accordingly.
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

local timerDefaults = {
     storm_the_heavens = 41,
     defiling_blast = 21,
     teleport_strike = 21,
     oppressive_bolts = 12,
     exhaustive_charges = 12,
     scalding_roar = 28,
     trial_by_fire = 27,
     llothis_dormant = 45,
     felms_dormant = 45,
     maim = 15,
}

function AST.SetTimer(key, timer_override, endtime_override)
     local duration = timer_override or timerDefaults[key] or 0
     AST.timers[key] = duration
     AST.endTimes[key] = endtime_override or (GetGameTimeSeconds() + duration)
end

local function UpdateMaimedStatus()
     if AST.sv.maim then
          for i = 1, 50 do
               local buffName, timeStarted, timeEnding, buffSlot, stackCount, fileName, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
               if abilityId == AST.id.maim then
                    local timeRemaining = timeEnding - GetGameTimeSeconds()
                    if zo_abs(AST.timers.maim - timeRemaining) > 0.15 then
                         AST.SetTimer("maim", timeRemaining, timeEnding)
                         AST.dbg("Updated Maim timer to " .. AST.timers.maim .. " seconds.")
                    end
                    break
               elseif abilityId == nil or abilityId == "" or abilityId == 0 then
                    break
               end
          end
     end
end

-- Creates a notification using Center_Screen_Announce. Called when Llothis/Felms switch between active and dormant.
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

-- Looping a sound effect makes it louder. Used for changing the volume of sound notifications.
function AST.LoopSound(numberOfLoops, soundEffect)
     for i = 1, numberOfLoops do
          PlaySound(SOUNDS[soundEffect])
     end
end

-- Returns an alphabetically sorted list of sound names, cached after the first call.
function AST.GetSounds()
     if AST.cachedSounds then return AST.cachedSounds end
     local sounds = {}
     for key in pairs(SOUNDS) do
          sounds[#sounds + 1] = key
     end
     table.sort(sounds)
     AST.cachedSounds = sounds
     return sounds
end

-- Adjusts Olms' timers to account for overlapping mechanics.
function AST.AdjustTimersOlms()
     if AST.sv.adjust_timers_olms then
          local active = {}
          local durations = { -- cast + recovery time before the next ability can fire
               trial_by_fire = 8,
               storm_the_heavens = 7,
               scalding_roar = 6,
               exhaustive_charges = 2,
          }

          if AST.timers.storm_the_heavens > 0 and AST.initialStormOccured then active.storm_the_heavens = AST.timers.storm_the_heavens end
          if AST.timers.trial_by_fire > 0 then active.trial_by_fire = AST.timers.trial_by_fire end
          if AST.timers.exhaustive_charges > 0 then active.exhaustive_charges = AST.timers.exhaustive_charges end
          if AST.timers.scalding_roar > 0 then active.scalding_roar = AST.timers.scalding_roar end

          local sorted = {}
          for key in pairs(active) do table.insert(sorted, key) end
          table.sort(sorted, function(a, b) return active[a] < active[b] end)

          for i = 1, #sorted - 1 do
               local k1, k2 = sorted[i], sorted[i + 1]
               local t1, t2 = AST.timers[k1], AST.timers[k2]
               local gap = t2 - t1
               local d1 = durations[k1]
               if gap < d1 and gap >= 1 and (d1 - gap) > 0.15 then
                    AST.SetTimer(k2, t1 + d1, AST.endTimes[k1] + d1)
                    AST.dbg("Updated timer for " .. k2 .. " to " .. AST.timers[k2])
               end
          end
     end
end

-- Adjusts Llothis' Oppressive Bolts timer to account for Defiling Blast firing first.
function AST.AdjustTimersLlothis()
     if AST.sv.adjust_timers_llothis then
          local db, ob = AST.timers.defiling_blast, AST.timers.oppressive_bolts
          local db_end, ob_end = AST.endTimes.defiling_blast, AST.endTimes.oppressive_bolts
          if ob > db and (ob - db < 7) and (ob - db >= 2) and db > 0 then
               AST.SetTimer("oppressive_bolts", ob + (7 - (ob - db)), ob_end + (7 - (ob_end - db_end)))
               AST.dbg("[ob > db]: Updated Oppressive Bolts timer to: " .. AST.timers.oppressive_bolts)
          end
     end
end

local function timerText(prefix, t)
     local suffix = t >= 1 and zo_floor(t) or GetString(AST_SETT_SOON)
     return prefix .. AST.cachedTimerHex .. suffix .. "|r"
end

local function playCountdownSound(t, volumeKey, soundKey)
     if t > 0 and not AST.soundPlayed and AST.sv.sound_enabled then
          AST.soundPlayed = true
          AST.LoopSound(AST.sv[volumeKey], AST.sv[soundKey])
          zo_callLater(function() AST.soundPlayed = false end, 900)
     end
end

-- Decreases the timers and updates notification labels.
-- Registered via EM:RegisterForUpdate in EventHandling.lua.
function AST.UpdateTimers()
     if AST.isInCombat then
          local now = GetGameTimeSeconds()
          AST.AdjustTimersOlms()
          AST.AdjustTimersLlothis()
          UpdateMaimedStatus()

          for key in pairs(AST.timers) do
               if AST.timers[key] > 0 then
                    AST.timers[key] = AST.endTimes[key] - now
                    if AST.timers[key] < 0 then AST.SetTimer(key, 0) end

                    local t = AST.timers[key]
                    AST.dbgtimers(key .. ": " .. string.format("%.3f", t))

                    if key == "storm_the_heavens" and t < 6 and AST.sv.storm_the_heavens then
                         AsylumTrackerStorm:SetHidden(false)
                         AsylumTrackerStormLabel:SetText(timerText(GetString(AST_NOTIF_KITE), t))
                         playCountdownSound(t, "storm_the_heavens_volume", "storm_the_heavens_sound")

                    elseif key == "defiling_blast" and t < 6 then
                         AsylumTrackerBlastLabel:SetText(timerText(GetString(AST_NOTIF_BLAST), t))
                         AsylumTrackerBlast:SetHidden(false)
                         playCountdownSound(t, "defiling_blast_volume", "defiling_blast_sound")

                    elseif key == "teleport_strike" and t < 6 then
                         AsylumTrackerTeleportStrikeLabel:SetText(timerText(GetString(AST_NOTIF_JUMP), t))
                         AsylumTrackerTeleportStrike:SetHidden(false)

                    elseif key == "oppressive_bolts" then
                         AsylumTrackerOppressiveBoltsLabel:SetText(timerText(GetString(AST_NOTIF_BOLTS), t))
                         AsylumTrackerOppressiveBolts:SetHidden(false)

                    elseif key == "exhaustive_charges" and t < 6 and AST.sv.exhaustive_charges then
                         AsylumTrackerChargesLabel:SetText(timerText(GetString(AST_NOTIF_CHARGES), t))
                         AsylumTrackerCharges:SetHidden(false)

                    elseif key == "scalding_roar" and t < 6 and AST.sv.scalding_roar then
                         AsylumTrackerSteamLabel:SetText(timerText(GetString(AST_NOTIF_STEAM), t))
                         AsylumTrackerSteam:SetHidden(false)

                    elseif key == "trial_by_fire" and t < 6 and AST.sv.trial_by_fire then
                         AsylumTrackerFireLabel:SetText(timerText(GetString(AST_NOTIF_FIRE), t))
                         AsylumTrackerFire:SetHidden(false)

                    elseif key == "llothis_dormant" then
                         local floor = zo_floor(t)
                         if (floor == 10 or floor == 5) and AST.sv.llothis_notifications and now - AST.LlothisLastNotified > 2.5 then
                              AST.CreateNotification("|c" .. COLOR_NOTIF .. GetString(floor == 10 and AST_NOTIF_LLOTHIS_IN_10 or AST_NOTIF_LLOTHIS_IN_5) .. "|r", 3000)
                              AST.LlothisLastNotified = now
                         end

                    elseif key == "felms_dormant" then
                         local floor = zo_floor(t)
                         if (floor == 10 or floor == 5) and AST.sv.felms_notifications and now - AST.FelmsLastNotified > 2.5 then
                              AST.CreateNotification("|c" .. COLOR_NOTIF .. GetString(floor == 10 and AST_NOTIF_FELMS_IN_10 or AST_NOTIF_FELMS_IN_5) .. "|r", 3000)
                              AST.FelmsLastNotified = now
                         end

                    elseif key == "maim" then
                         if t >= 0.5 and AST.sv.maim then
                              AsylumTrackerMaimLabel:SetText(timerText(GetString(AST_NOTIF_MAIM), t))
                              AsylumTrackerMaim:SetHidden(false)
                         else
                              AsylumTrackerMaim:SetHidden(true)
                         end
                    end
               end
          end
     else
          for key in pairs(AST.timers) do
               AST.timers[key] = 0
               AST.endTimes[key] = 0
          end
     end
end

-- {low, high, warn} — HP ranges near each jump %, and the threshold for switching to alert color
local jumpRanges = {{90, 95, 92}, {75, 80, 77}, {50, 55, 52}, {25, 30, 27}}

-- Displays Olms' HP% when approaching the 90/75/50/25% jump thresholds.
-- Registered via EM:RegisterForUpdate in EventHandling.lua.
function AST.MonitorOlmsHP()
     local bossName = zo_strformat("<<C:1>>", GetUnitName("boss1"))
     if bossName ~= "" then
          local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
          AST.olmsHealth = zo_floor(current / max * 100)
          if not AST.olmsJumping then
               local hp = AST.olmsHealth
               for _, r in ipairs(jumpRanges) do
                    if hp >= r[1] and hp <= r[2] then
                         AsylumTrackerOlmsHPLabel:SetText(hp .. "%")
                         if hp >= r[3] then
                              AsylumTrackerOlmsHPLabel:SetColor(unpack(AST.sv.color_olms_hp))
                              AsylumTrackerOlmsHP:SetHidden(false)
                         else
                              AsylumTrackerOlmsHPLabel:SetColor(unpack(AST.sv.color_olms_hp2))
                         end
                         break
                    end
               end
          end
     end
end

-- Alternates the Sphere and Storm notification labels between their two colors.
-- Registered via EM:RegisterForUpdate in EventHandling.lua.
function AST.AlternateNotificationColors()
     if AST.sphereIsUp then
          AST.sphereColorToggle = not AST.sphereColorToggle
          AsylumTrackerSphereLabel:SetColor(unpack(AST.sphereColorToggle and AST.sv.color_sphere2 or AST.sv.color_sphere))
     end
     if AST.stormIsActive then
          AST.stormColorToggle = not AST.stormColorToggle
          AsylumTrackerStormLabel:SetColor(unpack(AST.stormColorToggle and AST.sv.color_storm2 or AST.sv.color_storm))
     end
end

-- Builds a character name → display name table for all current group members.
function AST.IndexGroupMembers()
     AST.groupMembers = {}
     local groupSize = GetGroupSize()
     if groupSize == 0 then
          AST.groupMembers[GetUnitName("player")] = GetUnitDisplayName("player")
     else
          for i = 1, GROUP_SIZE_MAX do
               local memberCharacterName = GetUnitName("group" .. i)
               if memberCharacterName ~= "" then
                    AST.groupMembers[memberCharacterName] = GetUnitDisplayName("group" .. i)
               end
          end
     end
end

function AST.CombatState(event, isInCombat)
     if isInCombat ~= AST.isInCombat then
          AST.isInCombat = isInCombat
          if isInCombat then
               AST.IndexGroupMembers()
               AST.unitIds = {}
               AST.RegisterUnitIndexing()
          else
               AST.HideAllControls()

               -- Resets Llothis and Felms spawn state in case the group wipes.
               AST.LlothisSpawned = false
               AST.FelmsSpawned = false
               AST.initialStormOccured = false
               AST.dbg("Resetting Llothis and Felms spawn status")

               AST.UnregisterUnitIndexing()
               AST.unitIds = {}
               AST.dbgunits("Leaving Combat. Clearing Units Table")
               AST.spawnTimes = {}
          end
     end
end

-- Initialization function
function AST.Initialize()
     AST.savedVars = ZO_SavedVars:NewCharacterIdSettings("AsylumTrackerVars", AST.variableVersion, nil, AST.defaults)
     AST.sv = AST.savedVars
     AST.CacheTimerHex()

     AST.lang.en.LoadStrings() -- Always load English first; other locales may not have every string translated
     if not AST.sv.languageOverride then
          local locale = GetCVar("language.2")
          if locale ~= "en" then
               AST.lang[locale].LoadStrings()
          end
     else
          AST.lang[AST.sv.chosenLocale].LoadStrings()
     end

     AST.CreateSettingsWindow()
     AST.ResetAnchors()
     AST.InitializeControlSizes()

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
     EM:UnregisterForEvent(AST.name, EVENT_ADD_ON_LOADED)
end

EM:RegisterForEvent(AST.name, EVENT_ADD_ON_LOADED, AST.OnAddOnLoaded)