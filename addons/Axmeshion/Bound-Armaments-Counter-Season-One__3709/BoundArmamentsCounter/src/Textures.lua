-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
-- Fixed by Faint_One Aug 15 2026
-- Textures.lua
-- -----------------------------------------------------------------------------

local BAC = BAC

--- @type table<string, integer> Texture dimensions
BAC.TEXTURE_SIZE = {
    FRAME_HEIGHT = 128,  -- Height of each texture frame
    FRAME_WIDTH  = 128,  -- Width of each texture frame
    ASSET_WIDTH  = 1024, -- Overall texture width
    ASSET_HEIGHT = 128,  -- Overall texture height
}

--- @type table{ name: string, asset: string, picker: string }[] Supported texture variants
BAC.TEXTURE_VARIANTS = {
    [0] = {
        name   = "Color Squares",
        asset  = "BoundArmamentsCounter/art/textures/ColorSquares.dds",
        picker = "BoundArmamentsCounter/art/textures/Picker-ColorSquares.dds",
    },
    [1] = {
        name   = "Numbers",
        asset  = "BoundArmamentsCounter/art/textures/Numbers.dds",
        picker = "BoundArmamentsCounter/art/textures/Picker-Numbers.dds",
    },
    [2] = {
        name   = "Numbers (Thick Stroke)",
        asset  = "BoundArmamentsCounter/art/textures/NumbersThickStroke.dds",
        picker = "BoundArmamentsCounter/art/textures/Picker-NumbersThickStroke.dds",
    },
}

--- @type table{ ABS: integer, REL: number }[] Frame coordinates of the texture
BAC.TEXTURE_FRAMES = {
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
