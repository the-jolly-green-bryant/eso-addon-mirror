
SynergyPriority = SynergyPriority or {}
SynergyPriority.Settings = {}

local WM = WINDOW_MANAGER
local LAM = LibAddonMenu2 or {}
local panelData = {
    type        = "panel",
    name        = "SynergyPriority",
    displayName = "SynergyPriority",
    author      = "Vixen Hunny",
    version     = "1.0.0",
    registerForRefresh  = true,
}
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
local settingsBreakout = {
        SYNERGY = {
            name = "|cCD5031Synergies|r",
            data = {"--- Select a Synergy ---"}
        }
    }

function SynergyPriority:CreateSettings()
    optionsTable = {
        {
            type = "header",
            width = "full",
            name = "Priority list = Lower Priority rating = Higher Priority"
        },
        {
            type = "slider",
            name = "Radiate Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Radiate"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Radiate"].priority = v end,
            default = SynergyPriority.saved.synergies["Radiate"].priority
        },
        {
            type = "slider",
            name = "Blessed Shards Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Blessed Shards"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Blessed Shards"].priority = v end,
            default = SynergyPriority.saved.synergies["Blessed Shards"].priority
        },
        {
            type = "slider",
            name = "Supernova Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Supernova"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Supernova"].priority = v end,
            default = SynergyPriority.saved.synergies["Supernova"].priority
        },
        {
            type = "slider",
            name = "Gravity Crush Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Gravity Crush"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Gravity Crush"].priority = v end,
            default = SynergyPriority.saved.synergies["Gravity Crush"].priority
        },
        {
            type = "slider",
            name = "Shackle Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Shackle"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Shackle"].priority = v end,
            default = SynergyPriority.saved.synergies["Shackle"].priority
        },
        {
            type = "slider",
            name = "Ignite Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Ignite"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Ignite"].priority = v end,
            default = SynergyPriority.saved.synergies["Ignite"].priority

        },
        {
            type = "slider",
            name = "Healing Combustion Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Healing Combustion"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Healing Combustion"].priority = v end,
            default = SynergyPriority.saved.synergies["Healing Combustion"].priority
        },
        {
            type = "slider",
            name = "Blood Funnel Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Blood Funnel"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Blood Funnel"].priority = v end,
            default = SynergyPriority.saved.synergies["Blood Funnel"].priority
        },
        {
            type = "slider",
            name = "Blood Feast Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Blood Feast"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Blood Feast"].priority = v end,
            default = SynergyPriority.saved.synergies["Blood Feast"].priority
        },
        {
            type = "slider",
            name = "Combustion Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Combustion"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Combustion"].priority = v end,
            default = SynergyPriority.saved.synergies["Combustion"].priority
        },
        {
            type = "slider",
            name = "Purify Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Purify"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Purify"].priority = v end,
            default = SynergyPriority.saved.synergies["Purify"].priority
        },
        {
            type = "slider",
            name = "Rune Break Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Rune Break"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Rune Break"].priority = v end,
            default = SynergyPriority.saved.synergies["Rune Break"].priority
        },
        {
            type = "slider",
            name = "Conduit Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Conduit"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Conduit"].priority = v end,
            default = SynergyPriority.saved.synergies["Conduit"].priority
        },
        {
            type = "slider",
            name = "Grave Robber Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Grave Robber"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Grave Robber"].priority = v end,
            default = SynergyPriority.saved.synergies["Grave Robber"].priority
        },
        {
            type = "slider",
            name = "Energy Combustion Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Energy Combustion"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Energy Combustion"].priority = v end,
            default = SynergyPriority.saved.synergies["Energy Combustion"].priority
        },
        {
            type = "slider",
            name = "Harvest Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Harvest"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Harvest"].priority = v end,
            default = SynergyPriority.saved.synergies["Harvest"].priority
        },
        {
            type = "slider",
            name = "Bone Wall Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Bone Wall"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Bone Wall"].priority = v end,
            default = SynergyPriority.saved.synergies["Bone Wall"].priority
        },
        {
            type = "slider",
            name = "Spinal Surge Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Spinal Surge"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Spinal Surge"].priority = v end,
            default = SynergyPriority.saved.synergies["Spinal Surge"].priority
        },
        {
            type = "slider",
            name = "Holy Shards Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Holy Shards"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Holy Shards"].priority = v end,
            default = SynergyPriority.saved.synergies["Holy Shards"].priority
        },
        {
            type = "slider",
            name = "Soul Leech Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Soul Leech"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Soul Leech"].priority = v end,
            default = SynergyPriority.saved.synergies["Soul Leech"].priority
        },
        {
            type = "slider",
            name = "Charged Lightning Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Charged Lightning"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Charged Lightning"].priority = v end,
            default = SynergyPriority.saved.synergies["Charged Lightning"].priority
        },
        {
            type = "slider",
            name = "Hidden Refresh Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Hidden Refresh"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Hidden Refresh"].priority = v end,
            default = SynergyPriority.saved.synergies["Hidden Refresh"].priority
        },
        {
            type = "slider",
            name = "Pure Agony Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Pure Agony"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Pure Agony"].priority = v end,
            default = SynergyPriority.saved.synergies["Pure Agony"].priority
        },
        {
            type = "slider",
            name = "Spawn Broodlings Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Spawn Broodlings"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Spawn Broodlings"].priority = v end,
            default = SynergyPriority.saved.synergies["Spawn Broodlings"].priority
        },
        {
            type = "slider",
            name = "Black Widows Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Black Widows"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Black Widows"].priority = v end,
            default = SynergyPriority.saved.synergies["Black Widows"].priority
        },
        {
            type = "slider",
            name = "Arachnophobia Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Arachnophobia"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Arachnophobia"].priority = v end,
            default = SynergyPriority.saved.synergies["Arachnophobia"].priority
        },
        {
            type = "slider",
            name = "Icy Escape Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Icy Escape"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Icy Escape"].priority = v end,
            default = SynergyPriority.saved.synergies["Icy Escape"].priority
        },
        {
            type = "slider",
            name = "Passage Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Passage"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Passage"].priority = v end,
            default = SynergyPriority.saved.synergies["Passage"].priority
        },
        {
            type = "slider",
            name = "Convergence Release Priority",
            min = 0,
            max = 100,
            step = 1,
            getFunc = function() return SynergyPriority.saved.synergies["Convergence Release"].priority end,
            setFunc = function(v) SynergyPriority.saved.synergies["Convergence Release"].priority = v end,
            default = SynergyPriority.saved.synergies["Convergence Release"].priority
        },


    }
    LAM:RegisterAddonPanel(SynergyPriority.name, panelData)
    LAM:RegisterOptionControls(SynergyPriority.name, optionsTable)
end



