
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Pipeline = Verditer.Pipeline or {}
Verditer.Pipeline.Presentation = {}
local M = Verditer.Pipeline.Presentation

local payload = {
  ts          = 0,
  DTPS        = 0,
  ABS         = 0,
  ITP         = 0,
  type_groups = { count = 0 },
  view_idx    = 1,
}

function M.snapshot(now_ms)
  payload.ts   = now_ms
  payload.DTPS = Verditer.Metrics.DTPS(now_ms)
  payload.ABS  = Verditer.Metrics.ABS(now_ms)
  payload.ITP  = payload.DTPS + payload.ABS
  Verditer.Metrics.type_groups_into(payload.type_groups, now_ms)
  if Verditer.Graph and Verditer.Graph.current_view then
    payload.view_idx = Verditer.Graph.current_view()
  end
  return payload
end

function M.payload()
  return payload
end
