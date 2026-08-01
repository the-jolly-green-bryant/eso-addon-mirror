-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local GFC = GFC

--- @type table<string, any> Default settings
local defaults = {
    --- @type debugModes
    debugMode = GFC.debugModes.off,
    --- @type boolean
    showEmptyStacks = false,
    --- @type integer
    selectedTexture = 2,
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
    --- @type table<string, boolean>
    overlay = {
        default  = false,
        inactive = false,
        beforeProc     = false,
        proc     = false,
        cruxReady = true,
        cruxNotReady = true,
    },
    --- @type table<string, { r: integer, g: integer, b: integer, a: integer }>
    colors = {
        default = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        inactive = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        beforeProc = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        proc = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        cruxReady = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
        cruxNotReady = {
            r = 1,
            g = 1,
            b = 1,
            a = 1,
        },
    },
    sounds = {
        cruxGained = {
            enabled = false,
            name    = "ENCHANTING_POTENCY_RUNE_PLACED",
            volume  = 20,
        },
        cruxLost   = {
            enabled = false,
            name    = "ENCHANTING_WEAPON_GLYPH_REMOVED",
            volume  = 20,
        },
        maxCrux    = {
            enabled = true,
            name    = "DEATH_RECAP_KILLING_BLOW_SHOWN",
            volume  = 20,
        }
    },
    --- @type boolean
    fadeInactive = false,
    --- @type integer
    fadeAmount = 90,
    --- @type boolean
    hideOutOfCombat = false,
    --- @type boolean
    alwaysShow = false,

    --- @type boolean
    enableCruxCounter = false,
    --- @type boolean
    enableCruxCounterSounds = false,
}

--- Get the addon defaults
--- @return table defaults Default settings
function GFC:GetDefaults()
    return defaults
end
