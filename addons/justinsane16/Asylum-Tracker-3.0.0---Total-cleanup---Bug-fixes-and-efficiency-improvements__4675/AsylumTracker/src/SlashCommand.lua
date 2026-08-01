local AST = AsylumTracker

local debugFlags = {
     {cmd = "general", key = "debug",         label = "General Debugging"},
     {cmd = "ability", key = "debug_ability", label = "Ability Debugging"},
     {cmd = "timers",  key = "debug_timers",  label = "Timers Debugging"},
     {cmd = "units",   key = "debug_units",   label = "Units Debugging"},
}
local debugFlagMap = {}
for _, v in ipairs(debugFlags) do debugFlagMap[v.cmd] = v end

local toggles = {
     ["storm"]     = {key = "storm_the_heavens",  label = "Storm the Heavens"},
     ["blast"]     = {key = "defiling_blast",     label = "Defiling Blast"},
     ["protector"] = {key = "static_shield",      label = "Protector"},
     ["teleport"]  = {key = "teleport_strike",    label = "Teleport Strike"},
     ["bolts"]     = {key = "oppressive_bolts",   label = "Oppressive Bolts"},
     ["steam"]     = {key = "scalding_roar",      label = "Scalding Roar"},
     ["charges"]   = {key = "exhaustive_charges", label = "Exhaustive Charges"},
     ["fire"]      = {key = "trial_by_fire",      label = "Trial by Fire"},
     ["maim"]      = {key = "maim",               label = "Maim"},
}

local function accent(s) return "|cff0096" .. s .. "|r" end

local function status(label, val)
     d(accent("AsylumTracker ::") .. " " .. label .. ": " .. accent(tostring(val)))
end

function AST.SlashCommand(cmd)
     cmd = string.lower(cmd)

     if cmd == "menu" then
          AST.OpenSettingsPanel()

     elseif cmd == "toggle" then
          AST.ToggleMovable()

     elseif cmd == "reset" then
          AST.ResetToDefaults()

     elseif cmd == "debug status" then
          for _, v in ipairs(debugFlags) do status(v.label, AST.sv[v.key]) end

     elseif cmd == "debug all on" or cmd == "debug all off" then
          local val = cmd == "debug all on"
          for _, v in ipairs(debugFlags) do
               AST.sv[v.key] = val
               status(v.label, val)
          end

     elseif cmd == "help" then
          d(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
          d(accent("AsylumTracker Commands ::"))
          d(accent("/astracker menu:") .. " Opens the AsylumTracker Settings panel")
          d(accent("/astracker toggle:") .. " Makes the notifications movable on the screen")
          d(accent("/astracker reset:") .. " Resets notifications to their default positions")
          d(" ")
          d(accent("/astracker debug status:") .. " Shows debugging states")
          d(accent("/astracker debug general:") .. " Toggles general debugging messages")
          d(accent("/astracker debug ability:") .. " Toggles ability debugging messages")
          d(accent("/astracker debug timers:") .. " Toggles timer debugging messages")
          d(accent("/astracker debug units:") .. " Toggles unit debugging messages")
          d(accent("/astracker debug all on:") .. " Enables all debugging messages")
          d(accent("/astracker debug all off:") .. " Disables all debugging messages")
          d(" ")
          d(accent("/astracker storm on/off:") .. " Toggles Storm The Heavens Notification")
          d(accent("/astracker blast on/off:") .. " Toggles Defiling Blast Notification")
          d(accent("/astracker protector on/off:") .. " Toggles Protectors Notification")
          d(accent("/astracker teleport on/off:") .. " Toggles Teleport Strike Notification")
          d(accent("/astracker bolts on/off:") .. " Toggles Oppressive Bolts Notification")
          d(accent("/astracker steam on/off:") .. " Toggles Steam Breath Notification")
          d(accent("/astracker charges on/off:") .. " Toggles Exhaustive Charges Notification")
          d(accent("/astracker fire on/off:") .. " Toggles Trial by Fire Notification")
          d(accent("/astracker maim on/off:") .. " Toggles Maim Notification")
          d(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")

     else
          local subcmd = cmd:match("^debug (.+)$")
          if subcmd and debugFlagMap[subcmd] then
               local v = debugFlagMap[subcmd]
               AST.sv[v.key] = not AST.sv[v.key]
               status(v.label, AST.sv[v.key])
               return
          end

          local feature, onoff = cmd:match("^(%a+) (on|off)$")
          if feature and toggles[feature] then
               local v = toggles[feature]
               AST.sv[v.key] = (onoff == "on")
               status(v.label, AST.sv[v.key])
               return
          end

          d(accent("AsylumTracker ::") .. " Invalid Command. Type: " .. accent("/astracker help") .. " for usage")
     end
end