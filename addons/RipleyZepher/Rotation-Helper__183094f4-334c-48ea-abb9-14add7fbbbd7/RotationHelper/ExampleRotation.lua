--[[
    Example Rotation Configuration

    This file shows how to create custom rotations for the Rotation Helper addon.
    Copy this structure and modify it for your specific build.
]]

-- Example: Magicka Sorcerer Single Target Rotation
local MagSorcSingleTarget = {
    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Crystal Weapon", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Haunting Curse", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Force Pulse", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Force Pulse", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Force Pulse", duration = 1000},

    {type = ACTION_TYPES.BAR_SWAP, duration = 500},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Unstable Wall", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Barbed Trap", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Twilight Tormentor", duration = 1000},

    {type = ACTION_TYPES.BAR_SWAP, duration = 500},
}

-- Example: Stamina Nightblade Single Target Rotation
local StamNBSingleTarget = {
    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Surprise Attack", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Surprise Attack", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Surprise Attack", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Killer's Blade", duration = 1000},

    {type = ACTION_TYPES.BAR_SWAP, duration = 500},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Endless Hail", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Barbed Trap", duration = 1000},

    {type = ACTION_TYPES.POTION, duration = 500},

    {type = ACTION_TYPES.BAR_SWAP, duration = 500},
}

-- Example: Simple LA Weaving Practice
local LAWeavingPractice = {
    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Any Spammable", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Any Spammable", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Any Spammable", duration = 1000},

    {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
    {type = ACTION_TYPES.SKILL, name = "Any Spammable", duration = 1000},
}

--[[
    How to use:

    1. Choose or create a rotation from the examples above
    2. In RotationHelper.lua, find the line:
       local currentRotation = {}
    3. Replace it with your chosen rotation:
       local currentRotation = LAWeavingPractice

    Or create your own rotation following this structure:

    local MyCustomRotation = {
        {type = ACTION_TYPES.LIGHT_ATTACK, duration = 1000},
        {type = ACTION_TYPES.SKILL, name = "Skill Name", duration = 1000},
        {type = ACTION_TYPES.BAR_SWAP, duration = 500},
        {type = ACTION_TYPES.POTION, duration = 500},
    }

    Duration values:
    - Standard GCD skill: 1000ms (1 second)
    - Instant cast (bar swap, potion): 500ms
    - Channeled skills: Adjust based on channel time
    - DoT skills: Use the GCD time, not the duration

    Tips:
    - Light attacks should have 1000ms duration (standard attack speed)
    - Bar swaps are instant but add a short GCD (~500ms)
    - Potions have a long cooldown but instant cast
    - The 'name' field helps identify skills but isn't strictly required for tracking
]]

-- Action type reference (already defined in main addon)
--[[
local ACTION_TYPES = {
    LIGHT_ATTACK = 1,
    SKILL = 2,
    BAR_SWAP = 3,
    POTION = 4
}
]]
