local Addon = LarvalTearMod
local SpSaverModes = Addon.Common.SpSaverModes

-- Order is the UI display order. These strings are also persisted
-- SavedVariables values; do not reorder, rename, or replace them.
SpSaverModes.ActiveModes = {
    "active_priority",
    "skip_skill_changes",
}
SpSaverModes.PassiveModes = {
    "best_effort",
    "all_or_nothing",
    "preserve_current",
}

SpSaverModes.ActiveDefault = "active_priority"
SpSaverModes.PassiveDefault = "best_effort"

local ActiveModeSet = {}
for _, mode in ipairs(SpSaverModes.ActiveModes) do
    ActiveModeSet[mode] = true
end

local PassiveModeSet = {}
for _, mode in ipairs(SpSaverModes.PassiveModes) do
    PassiveModeSet[mode] = true
end

function SpSaverModes:NormalizeActiveMode(mode)
    if ActiveModeSet[mode] then
        return mode
    end

    return self.ActiveDefault
end

function SpSaverModes:NormalizePassiveMode(mode)
    if PassiveModeSet[mode] then
        return mode
    end

    return self.PassiveDefault
end
