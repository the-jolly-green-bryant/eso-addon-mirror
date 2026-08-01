-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker = PvPCooldownTracker or {}
PvPCooldownTracker.Defaults = {}

local function CloneTable(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = CloneTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local defaults = {
    debugMode = 0,
    sets = {},
    customSetData = {},
    unlocked = true,
    snapToGrid = false,
    cooldown_expired = "FFFF00",
    gridSize = 16,
    showOutsideCombat = true,
    lagCompensation = true,
    size = 64,
    set_active = "3CB043",
    labelSize = 1.5,
    labelFont = "$(BOLD_FONT)|18|soft-shadow-thick",
    timerFont = "$(BOLD_FONT)|22|soft-shadow-thick",
    style = {
        labelColor = { 0.96, 0.92, 0.86, 1.0 },
        timerColor = { 1.0, 0.97, 0.91, 1.0 },
        cooldownTint = { 0.68, 0.63, 0.58, 1.0 },
        glowColor = { 0.90, 0.40, 0.20, 0.35 },
        barBackgroundColor = { 0.08, 0.08, 0.08, 0.80 },
        barFillColor = { 0.84, 0.46, 0.20, 0.95 },
        barReadyColor = { 0.42, 0.72, 0.24, 0.95 },
    },
    LabelLocation = {
        x = 600,
        y = 300
    },
    TextureLocation = {
        x = 640,
        y = 300
    
    },
    sounds = {
        onProc = {
            enabled = true,
            sound = 'STATS_PURCHASE',
        },
        onReady = {
            enabled = true,
            sound = 'SKILL_LINE_ADDED',
        },
    },
}

local sets = {}

function PvPCooldownTracker.Defaults:Generate()
    for key, set in pairs(PvPCooldownTracker.Data.Sets) do

        -- Populate Sets
        defaults.sets[key] = {
            x = defaults.TextureLocation.x,
            y = defaults.TextureLocation.y,
            labelx = defaults.LabelLocation.x,
            labely = defaults.LabelLocation.y,
            size = defaults.size,
            sounds = CloneTable(defaults.sounds),
        }
        if set.procType == "set" then
            -- Populate Sets
            sets[key] = true
        else
            -- Unsupported procType
        end

    end
end

-- Account-wide
function PvPCooldownTracker.Defaults.Get()
    return defaults
end

-- Account-wide tracking state
function PvPCooldownTracker.Defaults.GetCharacter()
    return {
		["set"] = sets
	}
end

