-- Beltalowda Monster Set Data
-- Database of monster sets with cooldowns and role information

Beltalowda = Beltalowda or {}
Beltalowda.MonsterSets = {}

local MonsterSets = Beltalowda.MonsterSets

--[[
    Monster Set Database
    
    Each entry contains:
    - name: Display name of the set
    - cooldown: Proc cooldown in seconds (0 if no cooldown)
    
    Role classification is handled by SetDatabase for scoring.
]]--

MonsterSets.DATABASE = {
    -- Support Monster Sets
    [163] = { name = "Bloodspawn", cooldown = 6 },
    [166] = { name = "Engine Guardian", cooldown = 8 },
    [164] = { name = "Lord Warden", cooldown = 12 },
    [268] = { name = "Sentinel of Rkugamz", cooldown = 8 },
    [341] = { name = "Earthgore", cooldown = 35 },
    [167] = { name = "Nightflame", cooldown = 15 },
    [278] = { name = "Troll King", cooldown = 10 },
    [436] = { name = "Symphony of Blades", cooldown = 8 },
    
    -- Pull Monster Sets
    [267] = { name = "Swarm Mother", cooldown = 8 },
    
    -- Damage Monster Sets
    [350] = { name = "Zaan", cooldown = 10 },
    [169] = { name = "Valkyn Skoria", cooldown = 8 },
    [266] = { name = "Kra'gh", cooldown = 4 },
    [270] = { name = "Slimecraw", cooldown = 0 },
    [275] = { name = "Stormfist", cooldown = 8 },
    [257] = { name = "Velidreth", cooldown = 8 },
    [349] = { name = "Thurvokun", cooldown = 8 },
    [280] = { name = "Grothdarr", cooldown = 10 },
    [279] = { name = "Selene", cooldown = 4 },
    [170] = { name = "Maw of the Infernal", cooldown = 15 },
    [273] = { name = "Ilambris", cooldown = 8 },
    [272] = { name = "Infernal Guardian", cooldown = 8 },
    [274] = { name = "Iceheart", cooldown = 6 },
}

function MonsterSets.GetSetInfo(setId)
    return MonsterSets.DATABASE[setId]
end

function MonsterSets.IsMonsterSet(setId)
    return MonsterSets.DATABASE[setId] ~= nil
end

function MonsterSets.GetCooldown(setId)
    local setInfo = MonsterSets.DATABASE[setId]
    return setInfo and setInfo.cooldown
end

-- Active cooldowns: cooldowns[unitTag][setId] = { startTime, duration }
MonsterSets.activeCooldowns = {}

function MonsterSets.RegisterCooldown(unitTag, setId)
    local setInfo = MonsterSets.DATABASE[setId]
    if not setInfo or setInfo.cooldown == 0 then
        return
    end
    
    MonsterSets.activeCooldowns[unitTag] = MonsterSets.activeCooldowns[unitTag] or {}
    MonsterSets.activeCooldowns[unitTag][setId] = {
        startTime = GetFrameTimeMilliseconds(),
        duration = setInfo.cooldown * 1000
    }
end

function MonsterSets.GetRemainingCooldown(unitTag, setId)
    if not MonsterSets.activeCooldowns[unitTag] or not MonsterSets.activeCooldowns[unitTag][setId] then
        return 0
    end
    
    local cooldownData = MonsterSets.activeCooldowns[unitTag][setId]
    local currentTime = GetFrameTimeMilliseconds()
    local elapsed = currentTime - cooldownData.startTime
    local remaining = cooldownData.duration - elapsed
    
    if remaining <= 0 then
        MonsterSets.activeCooldowns[unitTag][setId] = nil
        return 0
    end
    
    return remaining / 1000
end

function MonsterSets.ClearCooldowns(unitTag)
    MonsterSets.activeCooldowns[unitTag] = nil
end
