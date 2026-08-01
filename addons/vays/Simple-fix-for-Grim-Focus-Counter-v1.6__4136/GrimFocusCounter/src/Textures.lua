-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Textures.lua
-- -----------------------------------------------------------------------------

local GFC = GFC

--- @type table<string, integer> Texture dimensions
GFC.TEXTURE_SIZE = {
    FRAME_HEIGHT = 128,  -- Height of each texture frame
    FRAME_WIDTH  = 128,  -- Width of each texture frame
    ASSET_WIDTH  = 1024, -- Overall texture width
    ASSET_HEIGHT = 128,  -- Overall texture height
}

--- @type table{ name: string, asset: string, picker: string }[] Supported texture variants
GFC.TEXTURE_VARIANTS = {
    [0] = {
        name   = "Color Squares",
        asset  = "GrimFocusCounter/art/textures/ColorSquares.dds",
        picker = "GrimFocusCounter/art/textures/Picker-ColorSquares.dds",
    },
    [1] = {
        name   = "DOOM",
        asset  = "GrimFocusCounter/art/textures/Doom.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Doom.dds",
    },
    [2] = {
        name   = "Horizontal Dots",
        asset  = "GrimFocusCounter/art/textures/HorizontalDots.dds",
        picker = "GrimFocusCounter/art/textures/Picker-HorizontalDots.dds",
    },
    [3] = {
        name   = "Numbers",
        asset  = "GrimFocusCounter/art/textures/Numbers.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Numbers.dds",
    },
    [4] = {
        name   = "Dice",
        asset  = "GrimFocusCounter/art/textures/Dice.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Dice.dds",
    },
    [5] = {
        name   = "Play Magsorc",
        asset  = "GrimFocusCounter/art/textures/PlayMagsorc.dds",
        picker = "GrimFocusCounter/art/textures/Picker-PlayMagsorc.dds",
    },
    [6] = {
        name   = "Red Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_red.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_red.dds",
    },
    [7] = {
        name   = "Mono Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_BW.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_BW.dds",
    },
    [8] = {
        name   = "Numbers (Thick Stroke)",
        asset  = "GrimFocusCounter/art/textures/NumbersThickStroke.dds",
        picker = "GrimFocusCounter/art/textures/Picker-NumbersThickStroke.dds",
    },
    [9] = {
        name   = "Filled Dots",
        asset  = "GrimFocusCounter/art/textures/FilledDots.dds",
        picker = "GrimFocusCounter/art/textures/Picker-FilledDots.dds",
    },
}

--- @type table{ ABS: integer, REL: number }[] Frame coordinates of the texture
GFC.TEXTURE_FRAMES = {
    [0] = { ABS = 0, REL = 0.0 },     -- No stacks
    [1] = { ABS = 128, REL = 0.125 }, -- Stack #1
    [2] = { ABS = 256, REL = 0.25 },  -- Stack #2
    [3] = { ABS = 384, REL = 0.375 }, -- Stack #3
    [4] = { ABS = 512, REL = 0.5 },   -- Stack #4
    [5] = { ABS = 640, REL = 0.625 }, -- Stack #5
    [6] = { ABS = 768, REL = 0.75 },  -- Empty stack indicator
    [7] = { ABS = 896, REL = 0.875 }, -- Skill active indicator
    [8] = { ABS = 1024, REL = 1.0 },  -- End of texture
}
