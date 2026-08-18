-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t Updated by Geltungsdrang
-- Created: Jan 1, 2018
-- Edited: Geltungsdrang 2026
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

--- @type table<integer, integer> Ability ID to stacks-required-to-fire
GFC.PROC_THRESHOLD = {
    [61902] = 5, -- Grim Focus
    [61927] = 4, -- Relentless Focus
    [61919] = 5, -- Merciless Resolve
}

--- @type integer Fallback when the slotted morph is unknown
GFC.DEFAULT_PROC_THRESHOLD = 5

--- Get the stacks required to fire the bow for the currently tracked morph
--- @return integer threshold Stacks needed to fire
function GFC:GetProcThreshold()
    local abilityId = self.trackedAbilityId

    if abilityId ~= nil and self.PROC_THRESHOLD[abilityId] ~= nil then
        return self.PROC_THRESHOLD[abilityId]
    end

    return self.DEFAULT_PROC_THRESHOLD
end
