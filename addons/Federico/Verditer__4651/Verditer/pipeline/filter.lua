
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Pipeline = Verditer.Pipeline or {}
Verditer.Pipeline.Filter = {}
local M = Verditer.Pipeline.Filter

local bump = Verditer.Diagnostics.bump
local KIND_DMG_IN = Verditer.Constants.ABILITY_KIND.DMG_IN

function M.allow(ev)
  if ev.kind == KIND_DMG_IN and (ev.source_unit_id or 0) <= 0 then
    bump("filter.env_self")
  end
  return true
end
