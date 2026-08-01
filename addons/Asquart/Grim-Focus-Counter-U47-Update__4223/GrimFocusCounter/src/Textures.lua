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
    ASSET_WIDTH  = 1664, -- Overall texture width
    ASSET_HEIGHT = 128,  -- Overall texture height
}

--- @type table{ name: string, asset: string, picker: string }[] Supported texture variants
GFC.TEXTURE_VARIANTS = {
    [0] = {
        name   = "Color Squares",
        asset  = "GrimFocusCounter/art/textures/ColorSquares.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/ColorSquares_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-ColorSquares.dds",
    },
    [1] = {
        name   = "DOOM",
        asset  = "GrimFocusCounter/art/textures/Doom.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/Doom_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Doom.dds",
    },
    [2] = {
        name   = "Horizontal Dots",
        asset  = "GrimFocusCounter/art/textures/HorizontalDots.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/HorizontalDots_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-HorizontalDots.dds",
    },
    [3] = {
        name   = "Numbers",
        asset  = "GrimFocusCounter/art/textures/Numbers.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/Numbers.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Numbers.dds",
    },
    [4] = {
        name   = "Dice",
        asset  = "GrimFocusCounter/art/textures/Dice.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/Dice_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Dice.dds",
    },
    [5] = {
        name   = "Play Magsorc",
        asset  = "GrimFocusCounter/art/textures/PlayMagsorc.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/PlayMagsorc_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-PlayMagsorc.dds",
    },
    [6] = {
        name   = "Red Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_red.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/CH01_red_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_red.dds",
    },
    [7] = {
        name   = "Mono Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_BW.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/CH01_BW_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_BW.dds",
    },
    [8] = {
        name   = "Numbers (Thick Stroke)",
        asset  = "GrimFocusCounter/art/textures/NumbersThickStroke.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/NumbersThickStroke.dds",
        picker = "GrimFocusCounter/art/textures/Picker-NumbersThickStroke.dds",
    },
    [9] = {
        name   = "Filled Dots",
        asset  = "GrimFocusCounter/art/textures/FilledDots.dds",
        asset_4stacks  = "GrimFocusCounter/art/textures/FilledDots_4stacks.dds",
        picker = "GrimFocusCounter/art/textures/Picker-FilledDots.dds",
    },
}

--- @type table{ ABS: integer, REL: number }[] Frame coordinates of the texture
GFC.TEXTURE_FRAMES = {
    [0] = { ABS = 0, REL = 0.0 },     -- No stacks
    [1] = { ABS = 128, REL = 0.076923 }, -- Stack #1
    [2] = { ABS = 256, REL = 0.153846 },  -- Stack #2
    [3] = { ABS = 384, REL = 0.230769 }, -- Stack #3
    [4] = { ABS = 512, REL = 0.307692 },   -- Stack #4
    [5] = { ABS = 640, REL = 0.384615 }, -- Stack #5
    [6] = { ABS = 768, REL = 0.461538 },  -- Stack #6
    [7] = { ABS = 896, REL = 0.538461 }, -- Stack #7
    [8] = { ABS = 1024, REL = 0.615384 },  -- Stack #8
    [9] = { ABS = 1152, REL = 0.692307 },  -- Stack #9
    [10] = { ABS = 1280, REL = 0.769230 },  -- Stack #10
    [11] = { ABS = 1408, REL = 0.846153 },  -- Empty stack indicator
    [12] = { ABS = 1536, REL = 0.923076 },  -- Skill active indicator
    [13] = { ABS = 1664, REL = 1.0 },  -- End of texture
}
