---* Event Pipeline Orchestrator.

---* Motivation: To isolate the core logic from the noise of the raw ZOS API. 
---* Instead of polluting individual pipeline stages with global state, profiling, 
---* or early-exit checks, this module acts as a strict boundary layer. It handles 
---* the raw ingest, performs fast-fail validation (errors, zero-hits, active modes), 
---* updates diagnostic counters, and drives the lifecycle of an event through 
---* its three phases: Acquisition -> Filter -> Processing.
---
--- @module Vermilion.Pipeline
---
--- Entry points:
--- * `M.dispatch_damage_out` - Combat handler for outgoing player damage.
--- * `M.dispatch_shield_out` - Combat handler for player-applied damage shields.
--- * `M.init`                - Bootstraps ZOS subscriptions and API hardware filters.

Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Pipeline = Vermilion.Pipeline or {}
local M = Vermilion.Pipeline

local Acquisition = Vermilion.Pipeline.Acquisition
local Filter      = Vermilion.Pipeline.Filter
local Processing  = Vermilion.Pipeline.Processing

local C = Vermilion.zenimax.constants
local EVENT_COMBAT_EVENT          = C.EVENT_COMBAT_EVENT
local REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE = C.REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE
local REGISTER_FILTER_COMBAT_RESULT           = C.REGISTER_FILTER_COMBAT_RESULT
local REGISTER_FILTER_IS_ERROR                = C.REGISTER_FILTER_IS_ERROR
local COMBAT_UNIT_TYPE_PLAYER     = C.COMBAT_UNIT_TYPE_PLAYER
local ACTION_RESULT_DAMAGE            = C.ACTION_RESULT_DAMAGE
local ACTION_RESULT_DOT_TICK          = C.ACTION_RESULT_DOT_TICK
local ACTION_RESULT_CRITICAL_DAMAGE   = C.ACTION_RESULT_CRITICAL_DAMAGE
local ACTION_RESULT_DOT_TICK_CRITICAL = C.ACTION_RESULT_DOT_TICK_CRITICAL
local ACTION_RESULT_BLOCKED_DAMAGE    = C.ACTION_RESULT_BLOCKED_DAMAGE
local ACTION_RESULT_DAMAGE_SHIELDED   = C.ACTION_RESULT_DAMAGE_SHIELDED

local Log = Vermilion.Log.for_module("pipeline")

local prof_enter = Vermilion.Profiler.enter
local prof_exit  = Vermilion.Profiler.exit

local function bump(key) Vermilion.Diagnostics.bump(key) end

local function release(ev)
  if ev then Vermilion.Metrics.release_event(ev) end
end

local now = Acquisition.now

local function run_stages(ev, accepted_key)
  if not ev then
    bump("engine.pool.exhausted")
    Log:warn("event pool exhausted")
    return
  end
  prof_enter("pipeline.combat_event.filter")
  local allowed = Filter.allow(ev)
  prof_exit("pipeline.combat_event.filter")
  if allowed then
    bump(accepted_key)
    prof_enter("pipeline.combat_event.processing")
    Processing.process(ev)
    prof_exit("pipeline.combat_event.processing")
  else
    release(ev)
  end
end

function M.dispatch_damage_out(result, isError, _name, _g, _slot,
                               _src, _sourceType, _tgt, targetType, hit,
                               _pt, _dt, _log, sourceUnitId, targetUnitId, abilityId)
  prof_enter("pipeline.combat_event")
  bump("engine.damage.in")
  if isError then bump("engine.damage.dropped_error") prof_exit("pipeline.combat_event") return end
  if (hit or 0) <= 0 then bump("engine.damage.dropped_noise") prof_exit("pipeline.combat_event") return end
  if not Vermilion.Mode.uses("damage") then
    bump("engine.damage.dropped_mode") prof_exit("pipeline.combat_event") return
  end

  local t = now()
  prof_enter("pipeline.combat_event.acquisition")
  local ev = Acquisition.acquire_damage_out(t, hit, targetUnitId, targetType, abilityId, result, sourceUnitId, _dt)
  prof_exit("pipeline.combat_event.acquisition")
  run_stages(ev, "engine.damage.accepted")
  prof_exit("pipeline.combat_event")
end

function M.dispatch_shield_out(result, isError, _name, _g, _slot,
                               _src, _sourceType, _tgt, targetType, hit,
                               _pt, _dt, _log, sourceUnitId, targetUnitId, abilityId)
  prof_enter("pipeline.combat_event")
  bump("engine.shield.in")
  if isError then bump("engine.shield.dropped_error") prof_exit("pipeline.combat_event") return end
  if (hit or 0) <= 0 then bump("engine.shield.dropped_noise") prof_exit("pipeline.combat_event") return end
  if not Vermilion.Mode.uses("shield") then
    bump("engine.shield.dropped_mode") prof_exit("pipeline.combat_event") return
  end

  local t = now()
  prof_enter("pipeline.combat_event.acquisition")
  local ev = Acquisition.acquire_shield_out(t, hit, targetUnitId, targetType, abilityId, result, sourceUnitId)
  prof_exit("pipeline.combat_event.acquisition")
  run_stages(ev, "engine.shield.accepted")
  prof_exit("pipeline.combat_event")
end

function M.init()
  local E = Vermilion.zenimax.events

  Vermilion.Diagnostics.init()
  Vermilion.Metrics.init()

  E.register("Vermilion_E_DamageOut", EVENT_COMBAT_EVENT, function(...)
    local r = ...
    if r == ACTION_RESULT_DAMAGE
       or r == ACTION_RESULT_DOT_TICK
       or r == ACTION_RESULT_CRITICAL_DAMAGE
       or r == ACTION_RESULT_DOT_TICK_CRITICAL
       or r == ACTION_RESULT_BLOCKED_DAMAGE then
      M.dispatch_damage_out(...)
    end
  end)
  E.add_filter("Vermilion_E_DamageOut", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  E.add_filter("Vermilion_E_DamageOut", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_IS_ERROR, false)

  E.register("Vermilion_E_ShieldOut", EVENT_COMBAT_EVENT, M.dispatch_shield_out)
  E.add_filter("Vermilion_E_ShieldOut", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE_SHIELDED)
  E.add_filter("Vermilion_E_ShieldOut", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  E.add_filter("Vermilion_E_ShieldOut", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_IS_ERROR, false)

  Log:info("init complete; 2 combat-event handlers registered")
end
