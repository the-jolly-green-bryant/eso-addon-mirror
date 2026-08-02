local R = Conductor.Registry
local classes = {
    { "DRAGONKNIGHT", "Dragonknight" }, { "SORCERER", "Sorcerer" },
    { "NIGHTBLADE", "Nightblade" }, { "TEMPLAR", "Templar" },
    { "WARDEN", "Warden" }, { "NECROMANCER", "Necromancer" },
    { "ARCANIST", "Arcanist" },
}
for _, entry in ipairs(classes) do R:Register("CLASSES", entry[1], { name = entry[2] }) end
