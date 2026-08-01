SynergyPriority = SynergyPriority or {}
SynergyPriority.name = "SynergyPriority"
SynergyPriority.defaults = {
    synergies = {
        ["Supernova"] = {priority = 90, name = "Supernova"},
        ["Gravity Crush"] = {priority = 90, name = "Gravity Crush"},
        ["Blood Funnel"] = {priority = 100, name = "Blood Funnel"},
        ["Blood Feast"] = {priority = 100, name = "Blood Feast"},
        ["Shackle"] = {priority = 80, name = "Shackle"},
        ["Rune Break"] = {priority = 70, name = "Rune Break"},
        ["Combustion"] = {priority = 60, name = "Combustion"},
        ["Ignite"] = {priority = 60, name = "Ignite"},
        ["Conduit"] = {priority = 60, name = "Conduit"},
        ["Grave Robber"] = {priority = 60, name = "Grave Robber"},
        ["Energy Combustion"] = {priority = 50, name = "Energy Combustion"},
        ["Harvest"] = {priority = 50, name = "Harvest"},
        ["Bone Wall"] = {priority = 50, name = "Bone Wall"},
        ["Blessed Shards"] = {priority = 50, name = "Blessed Shards"},
        ["Spinal Surge"] = {priority = 50, name = "Spinal Surge"},
        ["Healing Combustion"] = {priority = 50, name = "Healing Combustion"},
        ["Holy Shards"] = {priority = 50, name = "Holy Shards"},
        ["Soul Leech"] = {priority = 40, name = "Soul Leech"},
        ["Radiate"] = {priority = 40, name = "Radiate"},
        ["Feeding Frenzy"] = {priority = 40, name = "Feeding Frenzy"},
        ["Charged Lightning"] = {priority = 40, name = "Charged Lightning"},
        ["Purify"] = {priority = 30, name = "Purify"},
        ["Hidden Refresh"] = {priority = 30, name = "Hidden Refresh"},
        ["Pure Agony"] = {priority = 30, name = "Pure Agony"},
        ["Spawn Broodlings"] = {priority = 30, name = "Spawn Broodlings"},
        ["Black Widows"] = {priority = 30, name = "Black Widows"},
        ["Arachnophobia"] = {priority = 30, name = "Arachnophobia"},
        ["Icy Escape"] = {priority = 20, name = "Icy Escape"},
        ["Passage"] = {priority = 20, name = "Passage"},
        ["Convergence Release"] = {priority = 20, name = "Convergence Release"},

    }
}
function SynergyPriority:Initialize()
    SynergyPriority.saved = ZO_SavedVars:New("SynergyPriorityVars", 2, nil, SynergyPriority.defaults)
    SynergyPriority:CreateSettings()
    EVENT_MANAGER:RegisterForUpdate(SynergyPriority.name.."_Synergy", 200, function() SynergyPriority:TrackSynergy() end)
end
function SynergyPriority:OnAddonLoaded(eventCode, addon_name)
    if addon_name ~= SynergyPriority.name then return end
    SynergyPriority:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SynergyPriority.name.."_Load", EVENT_ADD_ON_LOADED, function (...) SynergyPriority:OnAddonLoaded(...) end)