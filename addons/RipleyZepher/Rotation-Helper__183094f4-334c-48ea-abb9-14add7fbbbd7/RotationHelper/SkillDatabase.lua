-- Skill Database for Rotation Helper
-- Contains skill information including durations, types, and effects

-- Ensure RotationHelper exists (safety check)
RotationHelper = RotationHelper or {}
RotationHelper.SkillDB = {}

-- Skill types
local SKILL_TYPE = {
    INSTANT = 1,      -- Instant cast
    CHANNELED = 2,    -- Channeled ability
    DOT = 3,          -- Damage over time
    BUFF = 4,         -- Buff/self-buff
    GROUND_AOE = 5,   -- Ground-based AOE
}

-- Popular skills database with durations and types
-- Format: [Ability Name] = {duration, cooldown, type, isDOT, isBuff, channelTime}
RotationHelper.SkillDB.Skills = {
    -- === Dragonknight === --
    ["Molten Whip"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Venomous Claw"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Noxious Breath"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Flames of Oblivion"] = {duration = 30000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Engulfing Flames"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Standard of Might"] = {duration = 18000, cooldown = 250000, type = SKILL_TYPE.GROUND_AOE, isDOT = true},

    -- === Sorcerer === --
    ["Crystal Weapon"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Crystal Fragments"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Force Pulse"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Haunting Curse"] = {duration = 12000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Unstable Wall of Elements"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Critical Surge"] = {duration = 33000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Boundless Storm"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Twilight Tormentor"] = {duration = 0, cooldown = 8000, type = SKILL_TYPE.INSTANT},
    ["Greater Storm Atronach"] = {duration = 18000, cooldown = 250000, type = SKILL_TYPE.GROUND_AOE, isDOT = true},

    -- === Nightblade === --
    ["Surprise Attack"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Incapacitating Strike"] = {duration = 6000, cooldown = 120000, type = SKILL_TYPE.DOT, isDOT = true},
    ["Killer's Blade"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Twisting Path"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Siphoning Attacks"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true},
    -- Merciless Resolve: Cast once to activate buff, builds stacks on LA weaving, proc at 5 stacks
    ["Merciless Resolve"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true,
                             requiresStacks = 5, buildsStacks = true, maxStacks = 5, procName = "Assassin's Will"},
    ["Relentless Focus"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true,
                           requiresStacks = 5, buildsStacks = true, maxStacks = 5, procName = "Assassin's Scourge"},
    ["Grim Focus"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true,
                     requiresStacks = 5, buildsStacks = true, maxStacks = 5, procName = "Assassin's Will"},

    -- === Templar === --
    ["Puncturing Sweep"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Radiant Oppression"] = {duration = 2000, cooldown = 0, type = SKILL_TYPE.CHANNELED, channelTime = 2000},
    ["Blazing Spear"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Solar Barrage"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Radiant Glory"] = {duration = 2000, cooldown = 0, type = SKILL_TYPE.CHANNELED, channelTime = 2000},

    -- === Necromancer === --
    ["Blastbones"] = {duration = 0, cooldown = 3000, type = SKILL_TYPE.INSTANT},
    ["Stalking Blastbones"] = {duration = 0, cooldown = 3000, type = SKILL_TYPE.INSTANT},
    ["Boneyard"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Detonating Siphon"] = {duration = 12000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},

    -- === Warden === --
    ["Cutting Dive"] = {duration = 0, cooldown = 3000, type = SKILL_TYPE.INSTANT},
    ["Screaming Cliff Racer"] = {duration = 0, cooldown = 3000, type = SKILL_TYPE.INSTANT},
    ["Fetcher Infection"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Growing Swarm"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Barbed Trap"] = {duration = 18000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},

    -- === Arcanist === --
    ["Fatecarver"] = {duration = 4000, cooldown = 0, type = SKILL_TYPE.CHANNELED, channelTime = 4000},
    ["Pragmatic Fatecarver"] = {duration = 4000, cooldown = 0, type = SKILL_TYPE.CHANNELED, channelTime = 4000},
    ["Tentacular Dread"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Crux Weaver"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},

    -- === Weapon Skills === --
    -- Destruction Staff
    ["Force Shock"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Elemental Weapon"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Wall of Elements"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Unstable Wall"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Blockade of Fire"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},

    -- Bow
    ["Endless Hail"] = {duration = 12000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Arrow Barrage"] = {duration = 12000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Poison Injection"] = {duration = 10000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},

    -- Dual Wield
    ["Twin Slashes"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Rending Slashes"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},

    -- === Guild Skills === --
    ["Barbed Trap"] = {duration = 18000, cooldown = 0, type = SKILL_TYPE.GROUND_AOE, isDOT = true},
    ["Channeled Acceleration"] = {duration = 36000, cooldown = 0, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Degeneration"] = {duration = 20000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},
    ["Elemental Drain"] = {duration = 24000, cooldown = 0, type = SKILL_TYPE.DOT, isDOT = true},

    -- === Psijic Skills (with cast times) === --
    ["Elemental Weapon"] = {duration = 10000, cooldown = 0, castTime = 800, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Crushing Weapon"] = {duration = 10000, cooldown = 0, castTime = 800, type = SKILL_TYPE.BUFF, isBuff = true},
    ["Imbue Weapon"] = {duration = 10000, cooldown = 0, castTime = 800, type = SKILL_TYPE.BUFF, isBuff = true},

    -- === Common Actions === --
    ["Light Attack"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Heavy Attack"] = {duration = 2000, cooldown = 0, type = SKILL_TYPE.CHANNELED, channelTime = 2000},
    ["Bar Swap"] = {duration = 0, cooldown = 0, type = SKILL_TYPE.INSTANT},
    ["Potion"] = {duration = 0, cooldown = 45000, type = SKILL_TYPE.INSTANT},
}

-- Get skill info by name
function RotationHelper.SkillDB:GetSkillInfo(skillName)
    return self.Skills[skillName]
end

-- Check if skill is a DOT
function RotationHelper.SkillDB:IsDOT(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.isDOT or false
end

-- Check if skill is a buff
function RotationHelper.SkillDB:IsBuff(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.isBuff or false
end

-- Check if skill is channeled
function RotationHelper.SkillDB:IsChanneled(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.type == SKILL_TYPE.CHANNELED or false
end

-- Get skill duration
function RotationHelper.SkillDB:GetDuration(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.duration or 0
end

-- Get skill cooldown
function RotationHelper.SkillDB:GetCooldown(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.cooldown or 0
end

-- Get channel time
function RotationHelper.SkillDB:GetChannelTime(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.channelTime or 0
end

-- Check if skill requires stacks
function RotationHelper.SkillDB:RequiresStacks(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.requiresStacks and skill.requiresStacks > 0
end

-- Get required stacks for skill
function RotationHelper.SkillDB:GetRequiredStacks(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.requiresStacks or 0
end

-- Check if skill builds stacks on light attacks
function RotationHelper.SkillDB:BuildsStacks(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.buildsStacks or false
end

-- Get max stacks for skill
function RotationHelper.SkillDB:GetMaxStacks(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.maxStacks or 0
end

-- Get proc name for stack-based skill
function RotationHelper.SkillDB:GetProcName(skillName)
    local skill = self:GetSkillInfo(skillName)
    return skill and skill.procName or nil
end

-- Get list of all available skills (for UI dropdown)
function RotationHelper.SkillDB:GetAllSkillNames()
    local names = {}
    for name, _ in pairs(self.Skills) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- Get skills by class
function RotationHelper.SkillDB:GetSkillsByClass(className)
    -- This would be enhanced to filter by actual class
    -- For now, return all skills
    return self:GetAllSkillNames()
end

-- Export skill type constants
RotationHelper.SkillDB.SKILL_TYPE = SKILL_TYPE
