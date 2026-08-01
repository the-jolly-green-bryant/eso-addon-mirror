
Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Pipeline = Verdant.Pipeline or {}
Verdant.Pipeline.Presentation = {}
local M = Verdant.Pipeline.Presentation

local payload = {
  ts          = 0,
  ehps        = 0,
  mps         = 0,
  ems         = 0,
  ohps        = 0,
  d_group     = 0,
  o_self      = 0,
  c_self      = 0,
  c_heal      = 0,
  c_shield    = 0,
  mode        = "",
}

function M.snapshot(now_ms)
  local r = Verdant.Metrics.contribution(now_ms)
  payload.ts       = now_ms
  payload.ehps     = r.eHPS
  payload.mps      = r.MPS
  payload.ems      = r.EMS
  payload.ohps     = r.OHPS
  payload.d_group  = r.D_group
  payload.o_self   = r.O_self
  payload.c_self   = r.C_self
  payload.c_heal   = r.C_heal
  payload.c_shield = r.C_shield
  payload.mode     = r.mode
  return payload
end

function M.payload()
  return payload
end
