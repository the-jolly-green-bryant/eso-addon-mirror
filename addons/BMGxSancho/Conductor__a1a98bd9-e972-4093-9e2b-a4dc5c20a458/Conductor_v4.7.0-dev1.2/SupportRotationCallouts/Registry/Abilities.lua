local R = Conductor.Registry
R:Register("ABILITIES", "WAR_HORN", { name = "War Horn", abilityIds = { 38564 }, category = "ULTIMATE" })
R:Register("ABILITIES", "AGGRESSIVE_HORN", { name = "Aggressive Horn", abilityIds = { 40224 }, category = "ULTIMATE", provides = { "MAJOR_FORCE" } })
R:Register("ABILITIES", "COLOSSUS", { name = "Colossus", abilityIds = {}, category = "ULTIMATE", provides = { "MAJOR_VULNERABILITY" }, needsIdValidation = true })
R:Register("ABILITIES", "BARRIER", { name = "Barrier", abilityIds = {}, category = "ULTIMATE", needsIdValidation = true })
