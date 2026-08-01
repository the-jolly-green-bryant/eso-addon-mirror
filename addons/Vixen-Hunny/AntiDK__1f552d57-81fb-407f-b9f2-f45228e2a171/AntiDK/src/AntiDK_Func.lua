AntiDK = AntiDK or {}

-- Core tracking data structures - initialize empty
AntiDK.ActiveAbilities = AntiDK.ActiveAbilities or {} -- Track active ability instances
AntiDK.Players = AntiDK.Players or {} -- Track DK players we've encountered
AntiDK.LastAbilityTime = AntiDK.LastAbilityTime or {} -- Track when abilities were last cast
AntiDK.TargetablePlayers = AntiDK.TargetablePlayers or {} -- Cache attackable player names we've actually seen
AntiDK.PlayerDebuffs = AntiDK.PlayerDebuffs or {} -- Track Shattering Rocks and Fossilize when they are on the player

local ABILITY_KEY_BY_ID = {
    [34117] = "PowerLash",
    [29474] = "MoltenWhip",
    [32678] = "ShatteringRocks",
    [17878] = "CorrosiveArmor",
    [32685] = "Fossilize",
    [22633] = "Fossilize", -- Legacy ID fallback
}

local ABILITY_KEY_BY_NAME = {
    ["power lash"] = "PowerLash",
    ["molten whip"] = "MoltenWhip",
    ["blessing at the peak"] = "MoltenWhip",
    ["shattering rocks"] = "ShatteringRocks",
    ["corrosive armor"] = "CorrosiveArmor",
    ["fossilize"] = "Fossilize",
}

local PLAYER_RETENTION_SECONDS = 600
local PLAYER_PRUNE_INTERVAL_SECONDS = 10
local TARGETABLE_PLAYER_RETENTION_SECONDS = 120
local PLAYER_ROLL_PROMPT_DELAY_SECONDS = 0.5
local OBSERVED_TARGET_UNIT_TAGS = {
    "reticleover",
    "reticleoverplayer",
    "target",
}

local function SafeZoStrformat(value)
    if type(value) ~= "string" then return nil end
    if type(zo_strformat) == "function" then
        return zo_strformat("<<1>>", value)
    end
    if type(ZO_strformat) == "function" then
        return ZO_strformat("<<1>>", value)
    end
    return value
end

local function NormalizeTrackedName(name)
    if type(name) ~= "string" then return nil end

    local normalized = SafeZoStrformat(name)
    if normalized == "" then return nil end

    return string.lower(normalized)
end

local function BuildPlayerNameSet()
    local names = {}
    local candidateNames = {
        type(GetUnitName) == "function" and GetUnitName("player") or nil,
        type(GetRawUnitName) == "function" and GetRawUnitName("player") or nil,
        type(GetUnitDisplayName) == "function" and GetUnitDisplayName("player") or nil,
    }

    for _, candidateName in ipairs(candidateNames) do
        local normalizedName = NormalizeTrackedName(candidateName)
        if normalizedName then
            names[normalizedName] = true
        end
    end

    return names
end

function AntiDK:RememberTargetablePlayerByName(playerName, unitTag)
    local normalizedName = NormalizeTrackedName(playerName)
    if not normalizedName then return false end

    local now = GetTimeStamp()
    local existingEntry = AntiDK.TargetablePlayers[normalizedName]
    if existingEntry then
        existingEntry.name = playerName
        existingEntry.lastSeen = now
        if unitTag and unitTag ~= "" then
            existingEntry.unitTag = unitTag
        end
    else
        AntiDK.TargetablePlayers[normalizedName] = {
            name = playerName,
            unitTag = unitTag,
            firstSeen = now,
            lastSeen = now,
        }
    end

    return true
end

function AntiDK:RememberTargetablePlayer(unitTag)
    if not unitTag or unitTag == "" then return false end
    if type(DoesUnitExist) == "function" and not DoesUnitExist(unitTag) then return false end
    if type(IsUnitAttackable) == "function" and not IsUnitAttackable(unitTag) then return false end
    if type(IsUnitPlayer) == "function" and not IsUnitPlayer(unitTag) then return false end

    local playerName = GetUnitName(unitTag)
    if not playerName or playerName == "" then return false end

    return AntiDK:RememberTargetablePlayerByName(playerName, unitTag)
end

function AntiDK:RefreshObservedTargetablePlayers()
    local foundAny = false
    for _, unitTag in ipairs(OBSERVED_TARGET_UNIT_TAGS) do
        if AntiDK:RememberTargetablePlayer(unitTag) then
            foundAny = true
        end
    end

    return foundAny
end

function AntiDK:IsTargetablePlayerName(playerName)
    local normalizedName = NormalizeTrackedName(playerName)
    if not normalizedName then return false end

    local targetableEntry = AntiDK.TargetablePlayers[normalizedName]
    if not targetableEntry then return false end

    targetableEntry.lastSeen = GetTimeStamp()
    return true
end

function AntiDK:GetTargetablePlayerUnitTag(playerName, fallbackUnitTag)
    local normalizedName = NormalizeTrackedName(playerName)
    if not normalizedName then return nil end

    if fallbackUnitTag and fallbackUnitTag ~= "" then
        local fallbackName = GetUnitName(fallbackUnitTag)
        if NormalizeTrackedName(fallbackName) == normalizedName then
            AntiDK:RememberTargetablePlayerByName(playerName, fallbackUnitTag)
            return fallbackUnitTag
        end
    end

    local targetableEntry = AntiDK.TargetablePlayers[normalizedName]
    if not targetableEntry or not targetableEntry.unitTag or targetableEntry.unitTag == "" then
        return nil
    end

    if type(DoesUnitExist) == "function" and not DoesUnitExist(targetableEntry.unitTag) then
        targetableEntry.unitTag = nil
        return nil
    end

    if NormalizeTrackedName(GetUnitName(targetableEntry.unitTag)) ~= normalizedName then
        targetableEntry.unitTag = nil
        return nil
    end

    targetableEntry.lastSeen = GetTimeStamp()
    return targetableEntry.unitTag
end

function AntiDK:ResolveEffectTarget(unitTag, unitName)
    if AntiDK.RefreshObservedTargetablePlayers then
        AntiDK:RefreshObservedTargetablePlayers()
    end

    local trackedName = unitName
    if (not trackedName or trackedName == "") and unitTag and unitTag ~= "" then
        trackedName = GetUnitName(unitTag)
    end

    if not trackedName or trackedName == "" then
        return nil, nil
    end

    local playerUnitTag = AntiDK:GetTargetablePlayerUnitTag(trackedName, unitTag)
    return trackedName, playerUnitTag
end

function AntiDK:IsCurrentPlayerName(name)
    local normalizedName = NormalizeTrackedName(name)
    if not normalizedName then return false end

    local playerNames = BuildPlayerNameSet()
    return playerNames[normalizedName] == true
end

function AntiDK:IsCurrentPlayerTarget(unitTag, targetName, targetCharacterName)
    if unitTag == "player" then
        return true
    end

    if targetCharacterName and AntiDK:IsCurrentPlayerName(targetCharacterName) then
        return true
    end

    if targetName and AntiDK:IsCurrentPlayerName(targetName) then
        return true
    end

    return false
end

function AntiDK:ShouldTrackCombatSource(sourceName, sourceCharacterName, sourceType)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        return true
    end

    if sourceCharacterName and sourceCharacterName ~= "" and AntiDK:IsTargetablePlayerName(sourceCharacterName) then
        return true
    end

    if not sourceName or sourceName == "" then return false end
    AntiDK:RefreshObservedTargetablePlayers()
    return AntiDK:IsTargetablePlayerName(sourceName)
end

function AntiDK:ResolveCombatSourceName(sourceName, sourceCharacterName, sourceType)
    AntiDK:RefreshObservedTargetablePlayers()

    local hasCharacterName = sourceCharacterName and sourceCharacterName ~= ""
    local hasSourceName = sourceName and sourceName ~= ""

    if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        if hasCharacterName then
            AntiDK:RememberTargetablePlayerByName(sourceCharacterName)
            if hasSourceName then
                AntiDK:RememberTargetablePlayerByName(sourceName)
            end
            return sourceCharacterName
        end

        if hasSourceName then
            AntiDK:RememberTargetablePlayerByName(sourceName)
            return sourceName
        end
    end

    if hasCharacterName and AntiDK:IsTargetablePlayerName(sourceCharacterName) then
        if hasSourceName then
            AntiDK:RememberTargetablePlayerByName(sourceName)
        end
        return sourceCharacterName
    end

    if hasSourceName and AntiDK:IsTargetablePlayerName(sourceName) then
        if hasCharacterName then
            AntiDK:RememberTargetablePlayerByName(sourceCharacterName)
            return sourceCharacterName
        end
        return sourceName
    end

    return nil
end

function AntiDK:TrackPlayerDebuff(abilityId, sourceName, duration)
    local abilityKey = ABILITY_KEY_BY_ID[abilityId]
    if abilityKey ~= "ShatteringRocks" and abilityKey ~= "Fossilize" then
        return false
    end

    local now = GetGameTimeSeconds()
    local safeDuration = math.max(duration or 1, PLAYER_ROLL_PROMPT_DELAY_SECONDS)
    local debuffName = abilityKey == "ShatteringRocks" and "Shattering Rocks" or "Fossilize"
    local debuffColor = abilityKey == "ShatteringRocks" and "FFAA44" or "FFFF00"

    AntiDK.PlayerDebuffs[abilityKey] = {
        key = abilityKey,
        id = abilityId,
        name = debuffName,
        sourceName = sourceName,
        duration = safeDuration,
        applyTime = now,
        endTime = now + safeDuration,
        rollReadyTime = now + PLAYER_ROLL_PROMPT_DELAY_SECONDS,
        color = debuffColor,
    }

    AntiDK:UpdateUI()
    return true
end

function AntiDK:RemovePlayerDebuffById(abilityId)
    local abilityKey = ABILITY_KEY_BY_ID[abilityId]
    if abilityKey ~= "ShatteringRocks" and abilityKey ~= "Fossilize" then
        return false
    end

    if not AntiDK.PlayerDebuffs[abilityKey] then
        return false
    end

    AntiDK.PlayerDebuffs[abilityKey] = nil
    AntiDK:UpdateUI()
    return true
end

function AntiDK:GetPlayerDebuffCount()
    local count = 0
    for _, debuff in pairs(AntiDK.PlayerDebuffs) do
        if debuff and AntiDK:GetDurationRemaining(debuff) > 0 then
            count = count + 1
        end
    end
    return count
end

function AntiDK:GetRollDodgeNotification()
    if AntiDK.settings and AntiDK.settings.showStunDodge == false then
        return nil
    end

    local now = GetGameTimeSeconds()
    local activePrompts = {}
    local pendingPrompts = {}
    for _, debuff in pairs(AntiDK.PlayerDebuffs) do
        if debuff and debuff.rollReadyTime and now < (debuff.endTime or 0) then
            if now >= debuff.rollReadyTime then
                table.insert(activePrompts, debuff.name)
            else
                table.insert(pendingPrompts, {
                    name = debuff.name,
                    remaining = math.max(0, debuff.rollReadyTime - now),
                })
            end
        end
    end

    if #activePrompts > 0 then
        table.sort(activePrompts)
        return string.format("ROLL NOW: %s", table.concat(activePrompts, " / "))
    end

    if #pendingPrompts == 0 then
        return nil
    end

    table.sort(pendingPrompts, function(a, b)
        if a.remaining == b.remaining then
            return a.name < b.name
        end
        return a.remaining < b.remaining
    end)

    local pendingNames = {}
    for _, prompt in ipairs(pendingPrompts) do
        table.insert(pendingNames, prompt.name)
    end

    return string.format("ROLL IN %.1fs: %s", pendingPrompts[1].remaining, table.concat(pendingNames, " / "))
end

-- Track Power Lash with stacks and duration
function AntiDK:TrackPowerLash(sourceName, stackCount, duration)
    if not AntiDK.ActiveAbilities[sourceName] then
        AntiDK.ActiveAbilities[sourceName] = {}
    end
    
    local now = GetGameTimeSeconds()
    
    -- If Power Lash already exists, increment stacks; otherwise create new
    if AntiDK.ActiveAbilities[sourceName].PowerLash then
        AntiDK.ActiveAbilities[sourceName].PowerLash.stacks = (AntiDK.ActiveAbilities[sourceName].PowerLash.stacks or 1) + 1
        AntiDK.ActiveAbilities[sourceName].PowerLash.endTime = now + (duration or 8)
    else
        AntiDK.ActiveAbilities[sourceName].PowerLash = {
            name = "Power Lash",
            id = 34117,
            stacks = stackCount or 1,
            duration = duration or 8,
            applyTime = now,
            endTime = now + (duration or 8),
            color = "FF6666",
            type = "damage",
        }
    end
    
    AntiDK:RecordPlayer(sourceName)
    AntiDK:UpdateUI()
end

-- Track Molten Whip with stacks and duration
function AntiDK:TrackMoltenWhip(sourceName, stackCount, duration)
    if not AntiDK.ActiveAbilities[sourceName] then
        AntiDK.ActiveAbilities[sourceName] = {}
    end
    
    local now = GetGameTimeSeconds()
    
    -- If Molten Whip already exists, increment stacks; otherwise create new
    if AntiDK.ActiveAbilities[sourceName].MoltenWhip then
        AntiDK.ActiveAbilities[sourceName].MoltenWhip.stacks = (AntiDK.ActiveAbilities[sourceName].MoltenWhip.stacks or 1) + 1
        AntiDK.ActiveAbilities[sourceName].MoltenWhip.endTime = now + (duration or 15)
    else
        AntiDK.ActiveAbilities[sourceName].MoltenWhip = {
            name = "Molten Whip",
            id = 29474,
            stacks = stackCount or 1,
            duration = duration or 15,
            applyTime = now,
            endTime = now + (duration or 15),
            color = "FF8844",
            type = "doT",
        }
    end
    
    AntiDK:RecordPlayer(sourceName)
    AntiDK:UpdateUI()
end

-- Track Shattering Rocks with 1 second delay
function AntiDK:TrackShatteringRocks(sourceName, damage)
    if not AntiDK.ActiveAbilities[sourceName] then
        AntiDK.ActiveAbilities[sourceName] = {}
    end
    
    local now = GetGameTimeSeconds()
    AntiDK.ActiveAbilities[sourceName].ShatteringRocks = {
        name = "Shattering Rocks",
        id = 32678,
        damage = damage or 0,
        delay = 0, -- 1 second delay before damage
        castTime = now,
        damageTime = now + 1.0,
        endTime = now + 5.0,  -- 5 second total duration so it shows on UI
        duration = 5,
        hasFired = false,
        color = "FFAA44",
        type = "damage",
    }
    
    AntiDK:RecordPlayer(sourceName)
    AntiDK:UpdateUI()
end

-- Track Corrosive Armor
function AntiDK:TrackCorrosiveArmor(sourceName, duration)
    if not AntiDK.ActiveAbilities[sourceName] then
        AntiDK.ActiveAbilities[sourceName] = {}
    end
    
    local now = GetGameTimeSeconds()
    
    -- If Corrosive Armor already exists, update duration; otherwise create new
    if AntiDK.ActiveAbilities[sourceName].CorrosiveArmor then
        AntiDK.ActiveAbilities[sourceName].CorrosiveArmor.stacks = (AntiDK.ActiveAbilities[sourceName].CorrosiveArmor.stacks or 1) + 1
        AntiDK.ActiveAbilities[sourceName].CorrosiveArmor.endTime = now + (duration or 20)
    else
        AntiDK.ActiveAbilities[sourceName].CorrosiveArmor = {
            name = "Corrosive Armor",
            id = 17878,
            stacks = 1,
            duration = duration or 20,
            applyTime = now,
            endTime = now + (duration or 20),
            color = "99FF99",
            type = "defense",
        }
    end
    
    AntiDK:RecordPlayer(sourceName)
    AntiDK:UpdateUI()
end

-- Track Fossilize stun
function AntiDK:TrackFossilize(sourceName, duration)
    if not AntiDK.ActiveAbilities[sourceName] then
        AntiDK.ActiveAbilities[sourceName] = {}
    end
    
    local now = GetGameTimeSeconds()
    AntiDK.ActiveAbilities[sourceName].Fossilize = {
        name = "Fossilize",
        id = 32685,
        duration = 1,
        applyTime = now,
        endTime = now + 1,
        color = "FFFF00",
        type = "stun",
    }
    
    AntiDK:RecordPlayer(sourceName)
    AntiDK:UpdateUI()
end

function AntiDK:RemoveAbility(sourceName, abilityKey)
    if not sourceName or sourceName == "" or not abilityKey then return false end
    if not AntiDK.ActiveAbilities[sourceName] then return false end

    if not AntiDK.ActiveAbilities[sourceName][abilityKey] then return false end

    AntiDK.ActiveAbilities[sourceName][abilityKey] = nil

    if next(AntiDK.ActiveAbilities[sourceName]) == nil then
        AntiDK.ActiveAbilities[sourceName] = nil
    end

    AntiDK:UpdateUI()
    return true
end

function AntiDK:RemoveAbilityById(sourceName, abilityId)
    local abilityKey = ABILITY_KEY_BY_ID[abilityId]
    if not abilityKey then return false end

    if AntiDK:RemoveAbility(sourceName, abilityKey) then
        return true
    end

    -- Fallback: some effect callbacks provide slightly different name formatting.
    for playerName in pairs(AntiDK.ActiveAbilities) do
        if string.lower(playerName) == string.lower(sourceName or "") then
            return AntiDK:RemoveAbility(playerName, abilityKey)
        end
    end

    return false
end

function AntiDK:RemoveAbilityByEvent(sourceName, abilityId, effectName, playerUnitTag)
    if playerUnitTag and playerUnitTag ~= "" then
        local resolvedName = GetUnitName(playerUnitTag)
        if resolvedName and resolvedName ~= "" then
            sourceName = resolvedName
        end
    end

    local abilityKey = ABILITY_KEY_BY_ID[abilityId]
    if not abilityKey and effectName then
        abilityKey = ABILITY_KEY_BY_NAME[string.lower(effectName)]
    end

    if not abilityKey then return false end

    if AntiDK:RemoveAbility(sourceName, abilityKey) then
        return true
    end

    local normalizedSourceName = NormalizeTrackedName(sourceName)
    for playerName in pairs(AntiDK.ActiveAbilities) do
        if NormalizeTrackedName(playerName) == normalizedSourceName then
            return AntiDK:RemoveAbility(playerName, abilityKey)
        end
    end

    return false
end

-- Record a DK player we've encountered
function AntiDK:RecordPlayer(sourceName)
    AntiDK:RememberTargetablePlayerByName(sourceName)

    if not AntiDK.Players[sourceName] then
        AntiDK.Players[sourceName] = {
            name = sourceName,
            lastSeen = GetTimeStamp(),
            firstSeen = GetTimeStamp(),
        }
    else
        AntiDK.Players[sourceName].lastSeen = GetTimeStamp()
    end
end

function AntiDK:PruneTargetablePlayers()
    local timeStampNow = GetTimeStamp()
    for normalizedName, playerInfo in pairs(AntiDK.TargetablePlayers) do
        local lastSeen = playerInfo and playerInfo.lastSeen
        if type(lastSeen) ~= "number" then
            lastSeen = 0
        end

        if (timeStampNow - lastSeen) > TARGETABLE_PLAYER_RETENTION_SECONDS then
            AntiDK.TargetablePlayers[normalizedName] = nil
        end
    end
end

function AntiDK:PruneInactivePlayers()
    local now = GetGameTimeSeconds()
    if AntiDK.NextPlayerPruneTime and now < AntiDK.NextPlayerPruneTime then
        return
    end

    AntiDK.NextPlayerPruneTime = now + PLAYER_PRUNE_INTERVAL_SECONDS

    local timeStampNow = GetTimeStamp()
    for playerName, playerInfo in pairs(AntiDK.Players) do
        local lastSeen = playerInfo and playerInfo.lastSeen
        if type(lastSeen) ~= "number" then
            lastSeen = 0
        end

        if not AntiDK.ActiveAbilities[playerName] and (timeStampNow - lastSeen) > PLAYER_RETENTION_SECONDS then
            AntiDK.Players[playerName] = nil
            AntiDK.LastAbilityTime[playerName] = nil
        end
    end
end

-- Clear expired abilities
function AntiDK:UpdateActiveAbilities()
    local now = GetGameTimeSeconds()
    
    for playerName, abilities in pairs(AntiDK.ActiveAbilities) do
        for abilityKey, ability in pairs(abilities) do
            -- Check if duration has expired
            if ability.endTime and now > ability.endTime then
                abilities[abilityKey] = nil
            end
            
            -- For Shattering Rocks, mark when damage fires
            if ability.id == 32678 and not ability.hasFired and now >= ability.damageTime then
                ability.hasFired = true
            end
        end
        
        -- Remove player if no active abilities
        if next(abilities) == nil then
            AntiDK.ActiveAbilities[playerName] = nil
        end
    end

    for abilityKey, debuff in pairs(AntiDK.PlayerDebuffs) do
        if not debuff.endTime or now > debuff.endTime then
            AntiDK.PlayerDebuffs[abilityKey] = nil
        end
    end

    AntiDK:PruneInactivePlayers()
    AntiDK:PruneTargetablePlayers()
end

-- Get duration remaining for an ability (for display)
function AntiDK:GetDurationRemaining(ability)
    if not ability.endTime then return 0 end
    local remaining = ability.endTime - GetGameTimeSeconds()
    return math.max(0, remaining)
end

-- Get Shattering Rocks delay remaining
function AntiDK:GetDelayRemaining(ability)
    if ability.id ~= 32678 then return 0 end
    local remaining = ability.damageTime - GetGameTimeSeconds()
    return math.max(0, remaining)
end
