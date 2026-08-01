
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Pipeline = Verditer.Pipeline or {}
Verditer.Pipeline.Processing = {}
local M = Verditer.Pipeline.Processing

local AK = Verditer.Constants.ABILITY_KIND
local KIND_DMG_IN = AK.DMG_IN
local KIND_ABS_IN = AK.ABS_IN

function M.process(ev)
  local k = ev.kind
  if k == KIND_DMG_IN then
    Verditer.Metrics.ingest_dmg_in(ev)
  elseif k == KIND_ABS_IN then
    Verditer.Metrics.ingest_abs_in(ev)
  end
end
