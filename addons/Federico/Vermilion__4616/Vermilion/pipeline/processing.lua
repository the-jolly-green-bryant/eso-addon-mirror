--* pipeline/processing.lua
--*
--* Stage 3 of the pipeline. Routes a filtered VermilionEvent to the appropriate
--* ingestor in metrics. The event becomes the buffer's owned entry from this
--* point — the caller MUST NOT release it. Buffer trim (on_evict) returns it to
--* the pool when the time window passes.

Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Pipeline = Vermilion.Pipeline or {}
Vermilion.Pipeline.Processing = {}
local M = Vermilion.Pipeline.Processing

local AK = Vermilion.Constants.ABILITY_KIND
local KIND_DAMAGE_OUT = AK.DAMAGE_OUT
local KIND_SHIELD_OUT = AK.SHIELD_OUT

function M.process(ev)
  local k = ev.kind
  if k == KIND_DAMAGE_OUT then
    Vermilion.Metrics.ingest_damage_out(ev)
  elseif k == KIND_SHIELD_OUT then
    Vermilion.Metrics.ingest_shield_out(ev)
  end
end
