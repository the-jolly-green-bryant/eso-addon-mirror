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
    ASSET_WIDTH  = 2048, -- Overall texture width
    ASSET_HEIGHT = 128,  -- Overall texture height
}

--- @type table{ name: string, asset: string, picker: string }[] Supported texture variants
GFC.TEXTURE_VARIANTS = {
    [0] = {
        name   = "Horizontal Dots",
        asset  = "GrimFocusCounter/art/textures/HorizontalDots.dds",
        picker = "GrimFocusCounter/art/textures/Picker-HorizontalDots.dds",
    },
    [1] = {
        name   = "Filled Dots",
        asset  = "GrimFocusCounter/art/textures/FilledDots.dds",
        picker = "GrimFocusCounter/art/textures/Picker-FilledDots.dds",
    },
    [2] = {
        name   = "Dice",
        asset  = "GrimFocusCounter/art/textures/Dice.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Dice.dds",
    },
    [3] = {
        name   = "Numbers",
        asset  = "GrimFocusCounter/art/textures/Numbers.dds",
        picker = "GrimFocusCounter/art/textures/Picker-Numbers.dds",
    },
    [4] = {
        name   = "Numbers (Thick Stroke)",
        asset  = "GrimFocusCounter/art/textures/NumbersThickStroke.dds",
        picker = "GrimFocusCounter/art/textures/Picker-NumbersThickStroke.dds",
    },
    [5] = {
        name   = "Color Squares",
        asset  = "GrimFocusCounter/art/textures/ColorSquares.dds",
        picker = "GrimFocusCounter/art/textures/Picker-ColorSquares.dds",
    },
    [6] = {
        name   = "Mono Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_BW.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_BW.dds",
    },
    [7] = {
        name   = "Red Compass (by Porkjet)",
        asset  = "GrimFocusCounter/art/textures/CH01_red.dds",
        picker = "GrimFocusCounter/art/textures/Picker-CH01_red.dds",
    },
}

--- @type table{ ABS: integer, REL: number }[] Frame coordinates of the texture
GFC.TEXTURE_FRAMES = {
    [0] = { ABS = 0, REL = 0.0 },        -- No stacks
    [1] = { ABS = 128, REL = 0.0625 },   -- Stack #1
    [2] = { ABS = 256, REL = 0.125 },    -- Stack #2
    [3] = { ABS = 384, REL = 0.1875 },   -- Stack #3
    [4] = { ABS = 512, REL = 0.25 },     -- Stack #4
    [5] = { ABS = 640, REL = 0.3125 },   -- Stack #5
    [6] = { ABS = 768, REL = 0.375},     -- Stack #6
    [7] = { ABS = 896, REL = 0.4375 },   -- Stack #7
    [8] = { ABS = 1024, REL = 0.5 },     -- Stack #8
    [9] = { ABS = 1152, REL = 0.5625 },  -- Stack #9
    [10] = { ABS = 1280, REL = 0.625 },  -- Stack #10
    [11] = { ABS = 1408, REL = 0.6875 }, -- Empty stack indicator
    [12] = { ABS = 1536, REL = 0.75 },   -- Dummy Stack #1
    [13] = { ABS = 1664, REL = 0.8125 }, -- Dummy Stack #2
    [14] = { ABS = 1792, REL = 0.875 },  -- Dummy Stack #3
    [15] = { ABS = 1920, REL = 0.9375 }, -- Dummy Stack #4
    [16] = { ABS = 2048, REL = 1.0 },    -- End of texture
}