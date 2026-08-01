-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Defaults.lua
-- -----------------------------------------------------------------------------
--
SFC.Defaults = {}

local defaults = {
    debugMode = 0,
    positionLeft = 400,
    positionTop = 400,
    unlocked = true,
    showFrame = false,
    count = {
        r = 1,
        g = 1,
        b = 1,
        a = 1,
    },
    animation = {
        r = 0.878,
        g = 0.639,
        b = 0.196,
        a = 1,
    },
    frame = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.5,
    },
}

function SFC.Defaults.Get()
    return defaults
end
