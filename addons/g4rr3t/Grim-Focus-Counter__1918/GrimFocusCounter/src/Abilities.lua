-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 1, 2018
--
-- Abilities.lua
-- -----------------------------------------------------------------------------

local GFC = GFC

--- @type integer Type of skill
GFC.skillType      = SKILL_TYPE_CLASS

--- @type integer Which class skill line
GFC.skillLineIndex = 1 -- Assassination

--- @type integer Skill within the skill line
GFC.skillIndex     = 6 -- Grim Focus, etc

--[[
    NOTE: As of Update 39 Week 1 PTS, the skill and stack IDs
    further below have been replaced by a single ID per skill.

    skillType:      SKILL_TYPE_CLASS
    skillLineIndex: 1 (Assassination)
    skillIndex:     6 (Grim Focus, etc)

    + ------------------- + ------------------- + ----------- + -------------- +
    | Ability Name        | Morph Slot          | Ability ID  | Ability Stack  |
    + ------------------- + ------------------- + ----------- + -------------- +
    | Grim Focus          | MORPH_SLOT_BASE     | 61902       | 122585         |
    | Relentless Focus    | MORPH_SLOT_MORPH_1  | 61927       | 122587         |
    | Merciless Resolve   | MORPH_SLOT_MORPH_2  | 61919       | 122586         |
    + ------------------- + ------------------- + ----------- + -------------- +
]]
--- @type table<integer, integer> Ability ID to stack ID mapping
GFC.skills         = {
    [61902] = 122585, -- Grim Focus
    [61927] = 122587, -- Relentless Focus
    [61919] = 122586, -- Merciless Resolve
}

--[[
    NOTE: Historical out of date information:
    As of Summerset PTS Week 1, all ranks of each morph
    use the Rank I Skill and Stack ID. This means we do not
    need to be concerned with IDs for ranks II-IV anymore.

    Merciless:
        Rank    Skill   Stack   Status
        I:      61919   61920   Confirmed by g4rr3t
        II:     62111   62112   Unconfirmed
        III:    62114   62115   Confirmed by Jae
        IV:     62117   62118   Confirmed by g4rr3t

    Relentless:
        Rank    Skill   Stack   Status
        I:      61927   61928   Confirmed by g4rr3t
        II:     62099   62100   Unconfirmed
        III:    62103   62104   Unconfirmed
        IV:     62107   62108   Confirmed by g4rr3t

    Grim:
        Rank    Skill   Stack   Status
        I:      61902   61905   Confirmed by Phinix
        II:     62090   62091   Unconfirmed
        III:    64176   64177   Confirmed by Seldaris
        IV:     62096   62097   Confirmed by g4rr3t
]]
