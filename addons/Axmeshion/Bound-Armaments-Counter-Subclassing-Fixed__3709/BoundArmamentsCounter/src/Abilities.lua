-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
-- Fixed by Faint_One July 4 2025
-- Abilities.lua
-- -----------------------------------------------------------------------------

local BAC = BAC

--- @type integer Type of skill
BAC.skillType      = SKILL_TYPE_CLASS

--- @type integer Which class skill line
BAC.skillLineIndex = 2 -- daedric summonning for sorc(2)
-- New
BAC.skillLineIndex1 = 11 -- daedric summonning in subclassing for dk(1), NB(3), plar(6)
BAC.skillLineIndex2 = 14 -- daedric summonning in subclassing for arc(117), necro(5), warden(4)

--- @type integer Skill within the skill line
BAC.skillIndex     = 6 -- Bound Armor and its morph

--- @type table<integer, integer> Ability ID to stack ID mapping
BAC.skills         = {
    [24165] = 203447, -- Bound Armaments
}

