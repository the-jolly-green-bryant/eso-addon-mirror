-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

PvPCooldownTracker.Defaults = {}

local defaults = {
    debugMode = 0,
    sets = {},
    unlocked = true,
    snapToGrid = false,
    cooldown_expired = "FFFF00",
    gridSize = 16,
    showOutsideCombat = true,
    lagCompensation = true,
    size = 64,
    set_active = "3CB043",
    labelSize = 1.5,
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
            sounds = defaults.sounds,
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

-- Per-character
function PvPCooldownTracker.Defaults.GetCharacter()
    return {
		["set"] = sets
	}
end

