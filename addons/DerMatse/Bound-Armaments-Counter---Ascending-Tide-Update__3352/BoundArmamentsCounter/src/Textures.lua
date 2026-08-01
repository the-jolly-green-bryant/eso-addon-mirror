-- -----------------------------------------------------------------------------
-- Bound Armaments Counter 
-- Author:  g4rr3t/Masel
-- Created: Sep 27, 2019
--
-- Textures.lua
-- -----------------------------------------------------------------------------

BAC.TEXTURE_SIZE = {
    FRAME_HEIGHT    = 128,  -- Height of each texture frame
    FRAME_WIDTH     = 128,  -- Width of each texture frame
    ASSET_WIDTH     = 1024, -- Overall texture width
    ASSET_HEIGHT    = 128,  -- Overall texture height
}

BAC.TEXTURE_VARIANTS = {
    [0] = {
        name    = "Color Squares",
        asset   = "BoundArmamentsCounter/art/textures/ColorSquares.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-ColorSquares.dds",
    },
    [1] = {
        name    = "DOOM",
        asset   = "BoundArmamentsCounter/art/textures/Doom.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-Doom.dds",
    },
    [2] = {
        name    = "Horizontal Dots",
        asset   = "BoundArmamentsCounter/art/textures/HorizontalDots.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-HorizontalDots.dds",
    },
    [3] = {
        name    = "Numbers",
        asset   = "BoundArmamentsCounter/art/textures/Numbers.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-Numbers.dds",
    },
    [4] = {
        name    = "Dice",
        asset   = "BoundArmamentsCounter/art/textures/Dice.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-Dice.dds",
    },
    [5] = {
        name    = "Play Magsorc",
        asset   = "BoundArmamentsCounter/art/textures/PlayMagsorc.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-PlayMagsorc.dds",
    },
    [6] = {
        name    = "Red Compass (by Porkjet)",
        asset   = "BoundArmamentsCounter/art/textures/CH01_red.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-CH01_red.dds",
    },
    [7] = {
        name    = "Mono Compass (by Porkjet)",
        asset   = "BoundArmamentsCounter/art/textures/CH01_BW.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-CH01_BW.dds",
    },
    [8] = {
        name    = "Numbers (Thick Stroke)",
        asset   = "BoundArmamentsCounter/art/textures/NumbersThickStroke.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-NumbersThickStroke.dds",
    },
    [9] = {
        name    = "Filled Dots",
        asset   = "BoundArmamentsCounter/art/textures/FilledDots.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-FilledDots.dds",
    },
    [10] = {
        name    = "Sorc Aim",
        asset   = "BoundArmamentsCounter/art/textures/Sorcaim.dds",
        picker  = "BoundArmamentsCounter/art/textures/Picker-Sorcaim.dds",
    },
}

BAC.TEXTURE_FRAMES = {
    	[0] = { ABS = 0,    REL = 0.0 },	-- No stacks
    	[1] = { ABS = 128,  REL = 0.125 },	-- Stack #1
    	[2] = { ABS = 256,  REL = 0.25 },	-- Stack #2
    	[3] = { ABS = 384,  REL = 0.375 }, 	-- Stack #3
    	[4] = { ABS = 512,  REL = 0.5 },	-- Stack #4
		[5] = { ABS = 640,  REL = 0.625 },	-- Stack #5
		[6] = { ABS = 768,  REL = 0.75 },	-- Empty stack indicator
    	[7] = { ABS = 896,  REL = 0.875 },	-- Skill active indicator
    	[8] = { ABS = 1024, REL = 1.0 },	-- End of texture
}

