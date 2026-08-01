-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t/Masel
-- Created: Sep 27, 2019
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    debugMode = 0,
    showEmptyStacks = true,
    selectedTexture = 10,
    positionLeft = 892,
    positionTop = 472,
    size = 100,
    unlocked = false,
    lockedToReticle = true,
    overlay = {
        default   = false,
        inactive  = false,
        four      = false,
        proc      = false,
    },
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
        four = {
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
    },
    fadeInactive = false,
    fadeAmount = 90,
}

function BAC:GetDefaults()
    return defaults
end
