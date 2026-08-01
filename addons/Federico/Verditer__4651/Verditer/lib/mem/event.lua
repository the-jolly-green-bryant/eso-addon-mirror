
Verditer = Verditer or {}
Verditer.lib = Verditer.lib or {}
Verditer.lib.mem = Verditer.lib.mem or {}

local Event = {}
Verditer.lib.mem.Event = Event

function Event.factory()
  return {
    t              = 0,
    kind           = 0,
    result         = 0,
    amount         = 0,
    damage_type    = 0,
    ability_id     = 0,
    source_unit_id = 0,
    source_name    = "",
    overflow       = 0,
  }
end
