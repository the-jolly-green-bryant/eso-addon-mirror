
Vermilion = Vermilion or {}
Vermilion.zenimax = Vermilion.zenimax or {}
local Vermilion = Vermilion

Vermilion.zenimax.savedvars = {}
local M = Vermilion.zenimax.savedvars

local ZO_SavedVars = ZO_SavedVars

function M.new_account_wide(table_name, version, profile, defaults, migrations)
  local sv = ZO_SavedVars:NewAccountWide(table_name, version, profile, defaults)
  if migrations then
    M.run_migrations(sv, version, migrations)
  end
  return sv
end

function M.run_migrations(sv, target_version, migrations)
  sv.version = sv.version or target_version
  while sv.version < target_version do
    local step = migrations[sv.version]
    if not step then break end
    step(sv)
  end
end
