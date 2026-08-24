--[[

  " ... my only aspiration is that death finds me alive "
                              — Indio Solari · Jan 17, 1949 – Jun 5, 2026

]]

Verdant = Verdant or {}
local Verdant = Verdant

local SLASH_COMMANDS          = SLASH_COMMANDS
local d                       = d
local string_format           = string.format
local string_lower            = string.lower
local string_match            = string.match
local api                     = Verdant.zenimax.api
local GetGameTimeMilliseconds = api.GetGameTimeMilliseconds
local GetString               = api.GetString
local GetWorldName            = api.GetWorldName

local KNOWN_FILTERS = {
  heal=true, shield=true, shield_raw=true, heal_abs=true,
  damage=true, effect=true, effect_self=true,
  cast=true, combat=true, group=true, all=true,
}

local function print_readout()
  local r = Verdant.Metrics.contribution(GetGameTimeMilliseconds())
  local denom_label, denom_val
  if r.mode == "group" then
    denom_label, denom_val = "Dgrp", r.D_group
  else
    denom_label, denom_val = "Oslf", r.O_self
  end
  d("[V] " .. string_format(GetString(VERDANT_READOUT_LINE),
    r.mode, r.eHPS, r.MPS, r.EMS, denom_label, denom_val,
    r.C_self, r.C_heal, r.C_shield))
end

local function on_slash(input)
  local DEBUG = Verdant.Constants.DEBUG
  input = input or ""
  local cmd = string_match(string_lower(input), "^%s*(%S+)") or ""

  if DEBUG then
    if cmd == "on" then
      Verdant.Probe.set_enabled(true)
      d("[V] " .. GetString(VERDANT_PROBE_ON))
      return
    elseif cmd == "off" then
      Verdant.Probe.set_enabled(false)
      d("[V] " .. GetString(VERDANT_PROBE_OFF))
      return
    elseif cmd == "filter" then
      local val = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if KNOWN_FILTERS[val] then
        Verdant.Probe.set_filter(val)
        d("[V] " .. string_format(GetString(VERDANT_FILTER_SET), val))
      else
        d("[V] " .. string_format(GetString(VERDANT_FILTER_UNKNOWN), val))
      end
      return
    elseif cmd == "metric" then
      local val = string_match(input, "^%s*%S+%s+(%S+)") or ""
      if Verdant.Mode.set(val) then
        d("[V] " .. string_format(GetString(VERDANT_METRIC_SET), val))
      else
        d("[V] " .. string_format(GetString(VERDANT_METRIC_UNKNOWN), val))
      end
      return
    elseif cmd == "readout" then
      print_readout() ; return
    elseif cmd == "dump" then
      Verdant.Probe.dump() ; return
    elseif cmd == "stats" then
      Verdant.Probe.print_stats() ; return
    elseif cmd == "context" then
      Verdant.Probe.print_context() ; return
    elseif cmd == "ping" then
      Verdant.Probe.print_ping() ; return
    elseif cmd == "tag" then
      local val = string_match(input, "^%s*%S+%s+(.+)$")
      if val then val = val:gsub("%s+$", "") end
      Verdant.Probe.set_tag(val)
      d("[V] session tag: " .. (val or "(cleared)"))
      return
    elseif cmd == "save" then
      Verdant.Probe.persist_to_savedvars(Verdant.SavedVars)
      d("[V] " .. GetString(VERDANT_DUMP_SAVED))
      return
    elseif cmd == "trace" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "start" then Verdant.Trace.start()
      elseif sub == "stop" then Verdant.Trace.stop()
      elseif sub == "save" then Verdant.Trace.save(Verdant.SavedVars)
      elseif sub == "clear" then Verdant.Trace.clear(Verdant.SavedVars) d("[trace] cleared")
      else d("[trace] " .. Verdant.Trace.status_line() .. "  (subcmd: start | stop | save | clear)")
      end
      return
    elseif cmd == "diag" then
      Verdant.Diagnostics.print_diag() ; return
    elseif cmd == "report" then

      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      Verdant.Diagnostics.full_report(sub == "gc" or sub == "full") ; return
    elseif cmd == "gcprobe" then

      local n = tonumber(string_match(input, "^%s*%S+%s+(%d+)")) or 1000
      Verdant.Diagnostics.gc_probe(n) ; return
    elseif cmd == "prof" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "reset" then Verdant.Profiler.reset(); d("[prof] reset")
      else Verdant.Profiler.dump_to_chat() end
      return
    elseif cmd == "log" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "flush" then
        local n = Verdant.Log.flush()
        d("[log] flushed " .. tostring(n) .. " records to SavedVars.debug.log")
      elseif sub == "show" then
        Verdant.Log.show_recent(20)
      elseif sub == "clear" then
        Verdant.Log.clear(); d("[log] cleared")
      else
        local cur, cap = Verdant.Log.size()
        d("[log] size " .. cur .. "/" .. cap .. "  (subcmd: flush | show | clear)")
      end
      return
    elseif cmd == "validate" then
      Verdant.Validation.dump_to_chat() ; return
    elseif cmd == "copy" then
      local sub = string_match(string_lower(input), "^%s*%S+%s+(%S+)") or ""
      if sub == "clear" then Verdant.CopyBox.clear()
      elseif sub == "hide" then Verdant.CopyBox.hide()
      else Verdant.CopyBox.show("Verdant Copy", "") end
      return
    elseif cmd == "skills" then
      Verdant.SkillColors.print_unknown() ; return
    elseif cmd == "clear" then
      Verdant.Probe.clear()
      Verdant.Metrics.reset()
      Verdant.ShieldRegistry.reset()
      Verdant.Coverage.reset()
      Verdant.GroupSet.reset()
      Verdant.Diagnostics.reset()
      Verdant.Bar.reset_peaks()
      d("[V] " .. GetString(VERDANT_BUFFER_CLEARED))
      return
    end
  end

  if cmd == "graph" then
    Verdant.Graph.toggle() ; return
  end

  if cmd == "lib" then
    Verdant.Library.toggle() ; return
  end

  if cmd == "help" then
    d(GetString(VERDANT_HELP_HEADER))
    d(GetString(VERDANT_HELP_TOGGLE))
    d(GetString(VERDANT_HELP_GRAPH))
    d(GetString(VERDANT_HELP_LIB))
    d(GetString(VERDANT_HELP_HELP))
    return
  end

  Verdant.Bar.toggle()
end

local function on_addon_loaded()
  local C   = Verdant.Constants
  local Log = Verdant.Log.for_module("bootstrap")

  local world = GetWorldName()
  Verdant.SavedVars = Verdant.zenimax.savedvars.new_account_wide(
    C.SV_TABLE, C.SV_VERSION, world,
    { probe = {}, bar = {}, temporal = {}, copybox = {}, settings = {}, skill_overrides = {}, logo = {}, assign = {}, library = {} })

  Verdant.SkillColors.load_persisted(Verdant.SavedVars)

  if Verdant.SavedVars.settings then
    Verdant.SavedVars.settings.font_scale = nil
  end
  Log:info("savedvars opened: world=", world, "version=", C.SV_VERSION)

  if C.DEBUG then Verdant.Probe.init() end
  Verdant.Trace.init()
  Verdant.Triage.init()
  Verdant.SessionStore.init()
  Verdant.GC.init()            -- GC pacing (ported): smooth the incremental collector
  Verdant.Pipeline.init()
  Verdant.Bar.init()
  Verdant.Logo.init()
  Verdant.Settings.init()
  Verdant.Graph.init()
  Verdant.AutoRecord.init()
  Verdant.Assign.init()
  Verdant.Library.init()
  Verdant.Visibility.init()

  SLASH_COMMANDS[C.SLASH_COMMAND] = on_slash

  Log:info("loaded v" .. C.VERSION, "DEBUG=" .. tostring(C.DEBUG))
  d("[V] " .. string_format(GetString(VERDANT_LOADED), C.VERSION, C.SLASH_COMMAND))
  if C.DEBUG then d("[V] build " .. tostring(C.BUILD)) end
end

Verdant.zenimax.events.register_addon_loaded(Verdant.Constants.ADDON_NAME, on_addon_loaded)
