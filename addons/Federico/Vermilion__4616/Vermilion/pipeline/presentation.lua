--* pipeline/presentation.lua

--* Stage 4 of the pipeline. Read-side: builds a stable RenderPayload from
--* metrics state, mutated in place each tick — zero per-tick allocation
--* (the eos_groups array is pre-grown by Metrics.eos_groups_into).

--* Like Verdant, this is a parallel read path. The graph's sample tick reads
--* core/metrics directly and pushes into core/temporal_buffer that means this payload is
--* the snapshot surface for introspection / future consumers.

Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Pipeline = Vermilion.Pipeline or {}
Vermilion.Pipeline.Presentation = {}
local M = Vermilion.Pipeline.Presentation

local payload = {
  ts         = 0,
  eDPS       = 0,
  ShDPS      = 0,
  EOS        = 0,
  eos_groups = { count = 0 },
  view_idx   = 1,
}

function M.snapshot(now_ms)
  payload.ts    = now_ms
  payload.eDPS  = Vermilion.Metrics.eDPS(now_ms)
  payload.ShDPS = Vermilion.Metrics.ShDPS(now_ms)
  payload.EOS   = payload.eDPS + payload.ShDPS
  Vermilion.Metrics.eos_groups_into(payload.eos_groups, now_ms)
  if Vermilion.Graph and Vermilion.Graph.current_view then
    payload.view_idx = Vermilion.Graph.current_view()
  end
  return payload
end

function M.payload()
  return payload
end
