-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t Updated by Geltungsdrang
-- Created: Jan 1, 2018
-- Edited: Geltungsdrang 2026
-- Defaults.lua
-- -----------------------------------------------------------------------------

local GFC = GFC

--- @type table<string, any> Default settings
local defaults = {
    --- @type debugModes
    debugMode = GFC.debugModes.off,
    --- @type boolean Show the digit 0 when the skill is slotted but not stacked
    showEmptyStacks = true,
    --- @type number
    positionLeft = 800,
    --- @type number
    positionTop = 600,
    --- @type integer
    size = 100,
    --- @type boolean
    unlocked = true,
    --- @type boolean
    lockedToReticle = false,
    --- @type table<string, { r: number, g: number, b: number, a: number }>
    colors = {
        --- Slotted, below the proc threshold
        normal     = { r = 1, g = 1, b = 1, a = 1 },
        --- Skill is not slotted
        notSlotted = { r = 1, g = 1, b = 1, a = 1 },
        --- One stack below the threshold
        almost     = { r = 1, g = 1, b = 1, a = 1 },
        --- At or above the threshold, bow ready
        ready      = { r = 1, g = 1, b = 1, a = 1 },
    },
    --- @type boolean
    fadeInactive = false,
    --- @type integer
    fadeAmount = 90,
    --- @type boolean
    hideOutOfCombat = false,
    --- @type boolean
    alwaysShow = false,
}

--- Get the addon defaults
--- @return table defaults Default settings
function GFC:GetDefaults()
    return defaults
end
