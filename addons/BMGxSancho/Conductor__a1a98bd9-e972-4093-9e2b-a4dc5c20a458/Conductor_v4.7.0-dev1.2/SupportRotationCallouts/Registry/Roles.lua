local R = Conductor.Registry
local roles = {
    { "TRIAL_LEAD", "Trial Lead" }, { "MAIN_TANK", "Main Tank" },
    { "OFF_TANK", "Off Tank" }, { "HEALER", "Healer" },
    { "SUPPORT_DD", "Support Damage Dealer" }, { "DAMAGE_DEALER", "Damage Dealer" },
}
for _, entry in ipairs(roles) do R:Register("ROLES", entry[1], { name = entry[2] }) end
