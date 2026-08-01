
Vermilion = Vermilion or {}
Vermilion.lib = Vermilion.lib or {}
Vermilion.lib.mem = Vermilion.lib.mem or {}

local Event = {}
Vermilion.lib.mem.Event = Event

function Event.factory()
  return {
    t              = 0,
    kind           = 0,
    result         = 0,
    amount         = 0,
    damage_type    = 0,
    target_unit_id = 0,
    target_type    = 0,
    ability_id     = 0,
    source_unit_id = 0,
  }
end
