
Verditer = Verditer or {}
local Verditer = Verditer

local SLASH_COMMANDS          = SLASH_COMMANDS
local d                       = d
local string_format           = string.format
local string_lower            = string.lower
local string_match            = string.match
local api                     = Verditer.zenimax.api
local GetString               = api.GetString
local GetWorldName            = api.GetWorldName

local function on_slash(input)
  local DEBUG = Verditer.Constants.DEBUG
  input = input or ""
  local cmd = string_match(string_lower(input), "^%s*(%S+)") or ""

  if DEBUG then
    if cmd == "probe" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if     sub == "on"    then Verditer.Probe.set_enabled(true)
      elseif sub == "off"   then Verditer.Probe.set_enabled(false)
      elseif sub == "stats" then Verditer.Probe.print_stats()
      elseif sub == "clear" then Verditer.Probe.clear()
      else                       Verditer.Probe.dump() end
      return
    elseif cmd == "report" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      Verditer.Diagnostics.full_report(sub == "gc" or sub == "full") ; return
    elseif cmd == "gcprobe" then
      local n = tonumber(string_match(input, "^%s*%S+%s+(%d+)")) or 1000
      Verditer.Diagnostics.gc_probe(n) ; return
    elseif cmd == "bench" then
      local label = string_match(input, "^%s*%S+%s+(%S+)") or "run"
      local force = string_match(string_lower(input), "%sforce%s*$") ~= nil
      Verditer.Bench.run(label, force) ; return
    elseif cmd == "allocprobe" then
      local n = tonumber(string_match(input, "^%s*%S+%s+(%d+)")) or 1000
      Verditer.Bench.alloc_probe(n) ; return
    elseif cmd == "stress" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      local arg = tonumber(string_match(input, "^%s*%S+%s+%S+%s+(%d+)"))
      if sub == "events" then Verditer.Bench.stress_events(arg)
      else Verditer.Bench.stress_fill(arg) end
      return
    elseif cmd == "prof" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "reset" then Verditer.Profiler.reset(); d("[prof] reset")
      else Verditer.Profiler.dump_to_chat() end
      return
    elseif cmd == "log" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "flush" then
        local n = Verditer.Log.flush()
        d("[log] flushed " .. tostring(n) .. " records to SavedVars.debug.log")
      elseif sub == "show" then
        Verditer.Log.show_recent(20)
      elseif sub == "clear" then
        Verditer.Log.clear(); d("[log] cleared")
      else
        local cur, cap = Verditer.Log.size()
        d("[log] size " .. cur .. "/" .. cap .. "  (subcmd: flush | show | clear)")
      end
      return
    elseif cmd == "recap" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "test" or sub == "sim" then Verditer.DeathRecap.simulate()
      else Verditer.Recap.toggle() end
      return
    elseif cmd == "validate" then
      Verditer.Validation.dump_to_chat() ; return
    elseif cmd == "copy" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "clear" then Verditer.CopyBox.clear()
      elseif sub == "hide" then Verditer.CopyBox.hide()
      else Verditer.CopyBox.show("Verditer Copy", "") end
      return
    elseif cmd == "clear" then
      Verditer.Probe.clear()
      Verditer.Metrics.reset()
      Verditer.Diagnostics.reset()
      d("[Vd] " .. GetString(VERDITER_BUFFER_CLEARED))
      return
    end
  end

  if cmd == "graph" then
    Verditer.Graph.toggle() ; return
  end

  if cmd == "recap" then
    Verditer.Recap.toggle() ; return
  end

  if cmd == "export" then
    Verditer.Export.show_session() ; return
  end

  if cmd == "help" then
    d(GetString(VERDITER_HELP_HEADER))
    d(GetString(VERDITER_HELP_GRAPH))
    d(GetString(VERDITER_HELP_HELP))
    return
  end

  Verditer.Graph.toggle()
end

local function on_addon_loaded()
  local C   = Verditer.Constants
  local Log = Verditer.Log.for_module("bootstrap")

  local world = GetWorldName()
  Verditer.SavedVars = Verditer.zenimax.savedvars.new_account_wide(
    C.SV_TABLE, C.SV_VERSION, world,
    { graph = {}, temporal = {}, settings = {}, logo = {}, recap = {}, copybox = {}, debug = {} })

  Log:info("savedvars opened: world=", world, "version=", C.SV_VERSION)

  if C.DEBUG then Verditer.Probe.init() end
  Verditer.GC.init()
  Verditer.Pipeline.init()
  Verditer.Logo.init()
  Verditer.DeathRecap.init()
  Verditer.Settings.init()
  Verditer.Graph.init()
  Verditer.Recap.init()
  Verditer.Visibility.init()

  SLASH_COMMANDS[C.SLASH_COMMAND] = on_slash

  Log:info("loaded v" .. C.VERSION, "DEBUG=" .. tostring(C.DEBUG))
  d("[Vd] " .. string_format(GetString(VERDITER_LOADED), C.VERSION, C.SLASH_COMMAND))
end

Verditer.zenimax.events.register_addon_loaded(Verditer.Constants.ADDON_NAME, on_addon_loaded)
