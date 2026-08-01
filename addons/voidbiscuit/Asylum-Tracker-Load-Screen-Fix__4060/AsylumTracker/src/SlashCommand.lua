local AST = AsylumTracker

function AST.SlashCommand(cmd)
     cmd = string.lower(cmd)
     if cmd == "menu" then
          AST.OpenSettingsPanel()
     elseif cmd == "toggle" then
          AST.ToggleMovable()
     elseif cmd == "reset" then
          AST.ResetToDefaults()
     elseif cmd == "debug status" then
          d("|cff0096AsylumTracker ::|r General Debugging:  |cff0096" .. tostring(AST.sv.debug) .. "|r")
          d("|cff0096AsylumTracker ::|r Ability Debugging: |cff0096" .. tostring(AST.sv.debug_ability) .. "|r")
          d("|cff0096AsylumTracker ::|r Timers Debugging: |cff0096" .. tostring(AST.sv.debug_timers) .. "|r")
          d("|cff0096AsylumTracker ::|r Units Debugging: |cff0096" .. tostring(AST.sv.debug_units) .. "|r")
     elseif cmd == "debug general" then
          AST.sv.debug = not AST.sv.debug
          d("|cff0096AsylumTracker ::|r General Debugging:  |cff0096" .. tostring(AST.sv.debug) .. "|r")
     elseif cmd == "debug ability" then
          AST.sv.debug_ability = not AST.sv.debug_ability
          d("|cff0096AsylumTracker ::|r Ability Debugging: |cff0096" .. tostring(AST.sv.debug_ability) .. "|r")
     elseif cmd == "debug timers" then
          AST.sv.debug_timers = not AST.sv.debug_timers
          d("|cff0096AsylumTracker ::|r Timers Debugging: |cff0096" .. tostring(AST.sv.debug_timers) .. "|r")
     elseif cmd == "debug units" then
          AST.sv.debug_units = not AST.sv.debug_units
          d("|cff0096AsylumTracker ::|r Units Debugging: |cff0096" .. tostring(AST.sv.debug_units) .. "|r")
     elseif cmd == "debug all on" then
          AST.sv.debug = true
          d("|cff0096AsylumTracker ::|r General Debugging:  |cff0096" .. tostring(AST.sv.debug) .. "|r")
          AST.sv.debug_ability = true
          d("|cff0096AsylumTracker ::|r Ability Debugging: |cff0096" .. tostring(AST.sv.debug_ability) .. "|r")
          AST.sv.debug_timers = true
          d("|cff0096AsylumTracker ::|r Timers Debugging: |cff0096" .. tostring(AST.sv.debug_timers) .. "|r")
          AST.sv.debug_units = true
          d("|cff0096AsylumTracker ::|r Units Debugging: |cff0096" .. tostring(AST.sv.debug_units) .. "|r")
     elseif cmd == "debug all off" then
          AST.sv.debug = false
          d("|cff0096AsylumTracker ::|r General Debugging:  |cff0096" .. tostring(AST.sv.debug) .. "|r")
          AST.sv.debug_ability = false
          d("|cff0096AsylumTracker ::|r Ability Debugging: |cff0096" .. tostring(AST.sv.debug_ability) .. "|r")
          AST.sv.debug_timers = false
          d("|cff0096AsylumTracker ::|r Timers Debugging: |cff0096" .. tostring(AST.sv.debug_timers) .. "|r")
          AST.sv.debug_units = false
          d("|cff0096AsylumTracker ::|r Units Debugging: |cff0096" .. tostring(AST.sv.debug_units) .. "|r")
     elseif cmd == "storm on" then
          AST.sv.storm_the_heavens = true
          d("|cff0096AsylumTracker ::|r Storm the Heavens:  |cff0096" .. tostring(AST.sv.storm_the_heavens) .. "|r")
     elseif cmd == "storm off" then
          AST.sv.storm_the_heavens = false
          d("|cff0096AsylumTracker ::|r Storm the Heavens:  |cff0096" .. tostring(AST.sv.storm_the_heavens) .. "|r")
     elseif cmd == "blast on" then
          AST.sv.defiling_blast = true
          d("|cff0096AsylumTracker ::|r Defiling Blast:  |cff0096" .. tostring(AST.sv.defiling_blast) .. "|r")
     elseif cmd == "blast off" then
          AST.sv.defiling_blast = false
          d("|cff0096AsylumTracker ::|r Defiling Blast:  |cff0096" .. tostring(AST.sv.defiling_blast) .. "|r")
     elseif cmd == "protector on" then
          AST.sv.static_shield = true
          d("|cff0096AsylumTracker ::|r Protector:  |cff0096" .. tostring(AST.sv.static_shield) .. "|r")
     elseif cmd == "protector off" then
          AST.sv.static_shield = false
          d("|cff0096AsylumTracker ::|r Protector:  |cff0096" .. tostring(AST.sv.static_shield) .. "|r")
     elseif cmd == "teleport on" then
          AST.sv.teleport_strike = true
          d("|cff0096AsylumTracker ::|r Teleport Strike:  |cff0096" .. tostring(AST.sv.teleport_strike) .. "|r")
     elseif cmd == "teleport off" then
          AST.sv.teleport_strike = false
          d("|cff0096AsylumTracker ::|r Teleport Strike:  |cff0096" .. tostring(AST.sv.teleport_strike) .. "|r")
     elseif cmd == "bolts on" then
          AST.sv.oppressive_bolts = true
          d("|cff0096AsylumTracker ::|r Oppressive Bolts:  |cff0096" .. tostring(AST.sv.oppressive_bolts) .. "|r")
     elseif cmd == "bolts off" then
          AST.sv.oppressive_bolts = false
          d("|cff0096AsylumTracker ::|r Oppressive Bolts:  |cff0096" .. tostring(AST.sv.oppressive_bolts) .. "|r")
     elseif cmd == "steam on" then
          AST.sv.scalding_roar = true
          d("|cff0096AsylumTracker ::|r Scalding Roar:  |cff0096" .. tostring(AST.sv.scalding_roar) .. "|r")
     elseif cmd == "steam off" then
          AST.sv.scalding_roar = false
          d("|cff0096AsylumTracker ::|r Scalding Roar:  |cff0096" .. tostring(AST.sv.scalding_roar) .. "|r")
     elseif cmd == "charges on" then
          AST.sv.exhaustive_charges = true
          d("|cff0096AsylumTracker ::|r Exhaustive Charges:  |cff0096" .. tostring(AST.sv.exhaustive_charges) .. "|r")
     elseif cmd == "charges off" then
          AST.sv.exhaustive_charges = false
          d("|cff0096AsylumTracker ::|r Exhaustive Charges:  |cff0096" .. tostring(AST.sv.exhaustive_charges) .. "|r")
     elseif cmd == "fire on" then
          AST.sv.trial_by_fire = true
          d("|cff0096AsylumTracker ::|r Trial by Fire:  |cff0096" .. tostring(AST.sv.trial_by_fire) .. "|r")
     elseif cmd == "fire off" then
          AST.sv.trial_by_fire = false
          d("|cff0096AsylumTracker ::|r Trial by Fire:  |cff0096" .. tostring(AST.sv.trial_by_fire) .. "|r")
     elseif cmd == "maim on" then
          AST.sv.maim = true
          d("|cff0096AsylumTracker ::|r Maim:  |cff0096" .. tostring(AST.sv.maim) .. "|r")
     elseif cmd == "maim off" then
          AST.sv.maim = false
          d("|cff0096AsylumTracker ::|r Maim:  |cff0096" .. tostring(AST.sv.maim) .. "|r")
     elseif cmd == "help" then
          d(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
          d("|cff0096AsylumTracker Commands ::|r")
          d("|cff0096/astracker menu:|r Opens the AsylumTracker Settings panel")
          d("|cff0096/astracker toggle:|r Makes the notifications movable on the screen")
          d("|cff0096/astracker reset:|r Resets notifications to their default positions")
          d(" ")
          d("|cff0096/astracker debug status:|r Shows debugging states")
          d("|cff0096/astracker debug general:|r Toggles general debugging messages")
          d("|cff0096/astracker debug ability:|r Toggles ability debugging messages")
          d("|cff0096/astracker debug timers:|r Toggles timer debugging messages")
          d("|cff0096/astracker debug units:|r Toggles unit debugging messages")
          d("|cff0096/astracker debug all on:|r Enables all debugging messages")
          d("|cff0096/astracker debug all off:|r Disables all debugging messages")
          d(" ")
          d("|cff0096/astracker storm on/off:|r Toggles Storm The Heavens Notification")
          d("|cff0096/astracker blast on/off:|r Toggles Defiling Blast Notification")
          d("|cff0096/astracker protector on/off:|r Toggles Protectors Notification")
          d("|cff0096/astracker teleport on/off:|r Toggles Teleport Strike Notification")
          d("|cff0096/astracker bolts on/off:|r Toggles Oppressive Bolts Notification")
          d("|cff0096/astracker steam on/off:|r Toggles Steam Breath Notification")
          d("|cff0096/astracker charges on/off:|r Toggles Exhaustive Charges Notification")
          d("|cff0096/astracker fire on/off:|r Toggles Trial by Fire Notification")
          d("|cff0096/astracker maim on/off:|r Toggles Maim Notification")
          d(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
     else
          d("|cff0096AsylumTracker ::|r Invalid Command. Type: |cff0096/astracker help|r for usage")
     end
end
