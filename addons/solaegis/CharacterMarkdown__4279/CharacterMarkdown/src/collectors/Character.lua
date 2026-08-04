-- CharacterMarkdown - Character Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectCharacterData()
    CM.DebugPrint("COLLECTOR", "Collecting character data...")

    -- Use API layer granular functions (composition at collector level)
    local nameInfo = CM.api.character.GetName()
    local genderInfo = CM.api.character.GetGender()
    local raceInfo = CM.api.character.GetRace()
    local classInfo = CM.api.character.GetClass()
    local allianceInfo = CM.api.character.GetAlliance()
    local levelInfo = CM.api.character.GetLevel()
    local locationInfo = CM.api.character.GetLocation()
    local titleInfo = CM.api.titles.GetCurrentTitle()

    -- Get alliance name using alliance API (cross-domain composition)
    local allianceName = "Unknown"
    if allianceInfo.id then
        local name = CM.SafeCall(GetAllianceName, allianceInfo.id)
        if name then
            allianceName = zo_strformat("<<1>>", name)
        end
    end

    -- Combat API (for attributes)
    local attributes = CM.api.combat.GetAttributes()

    -- Collectibles API (for ESO Plus)
    local esoPlus = CM.api.collectibles.IsESOPlus()

    -- Time API (for timestamp)
    local timestamp = CM.api.time.GetNow()
    local dateStr = CM.api.time.FormatDate(timestamp)

    -- Progression API (for age)
    local secondsPlayed = CM.api.progression.GetAge()

    -- Champion API (for CP)
    local cpPoints = CM.api.champion.GetPoints()

    -- Transform API data to expected format (backward compatibility)
    local data = {}

    -- Basic identity
    data.name = nameInfo.name or "Unknown"
    data.gender = genderInfo.name or "Unknown"
    data.race = raceInfo.name or "Unknown"
    data.class = classInfo.name or "Unknown"
    data.classId = classInfo.id
    data.alliance = allianceName
    data.level = levelInfo.level or 0
    data.title = titleInfo or ""

    -- Subclassing: active class lines with foreign classId vs native
    if CM.api.skills and CM.api.skills.GetSubclassConfiguration then
        data.subclass = CM.api.skills.GetSubclassConfiguration()
    end
    if CM.api.skills and CM.api.skills.GetSubclassingAccess then
        data.subclassingAccess = CM.api.skills.GetSubclassingAccess()
        if data.subclass and data.subclassingAccess then
            data.subclass.accessLabel = data.subclassingAccess.label
            data.subclass.hasAccess = data.subclassingAccess.hasAccess
        end
    end

    -- Server and account
    data.server = locationInfo.world or "Unknown"
    data.account = nameInfo.displayName or "Unknown"

    -- Champion Points (from champion API)
    data.cp = cpPoints.total or 0

    -- ESO Plus (from collectibles API)
    data.esoPlus = esoPlus or false

    -- Attributes (from combat API)
    data.attributes = {
        magicka = attributes.magicka or 0,
        health = attributes.health or 0,
        stamina = attributes.stamina or 0,
    }

    -- Timestamp (from time API)
    data.timestamp = dateStr or ""

    -- Age (from progression API, formatted)
    if secondsPlayed > 0 then
        -- Create short format: "1d 18h 49m" instead of verbose "1 day, 18 hours..."
        local days = math.floor(secondsPlayed / 86400)
        local hours = math.floor((secondsPlayed % 86400) / 3600)
        local minutes = math.floor((secondsPlayed % 3600) / 60)

        local ageParts = {}
        if days > 0 then
            table.insert(ageParts, string.format("%dd", days))
        end
        if hours > 0 or days > 0 then -- Show hours if we have days
            table.insert(ageParts, string.format("%dh", hours))
        end
        if minutes > 0 or (days == 0 and hours == 0) then -- Always show minutes if no days/hours
            table.insert(ageParts, string.format("%dm", minutes))
        end

        local playedTime = table.concat(ageParts, " ")
        data.age = playedTime

        -- Add computed fields for age
        local hoursPlayed = math.floor(secondsPlayed / 3600) -- 3600 seconds per hour
        data.ageMetrics = {
            seconds = secondsPlayed,
            hours = hoursPlayed,
            days = days,
            formatted = playedTime,
        }
    else
        data.age = nil
        data.ageMetrics = nil
    end

    -- Add computed CP efficiency metric (CP per day played)
    if data.ageMetrics and data.ageMetrics.days > 0 and data.cp > 0 then
        data.cpEfficiency = math.floor((data.cp / data.ageMetrics.days) * 10) / 10 -- CP per day, 1 decimal place
    else
        data.cpEfficiency = nil
    end

    CM.DebugPrint("COLLECTOR", "Character data collected:", data.name)
    return data
end

CM.collectors.CollectCharacterData = CollectCharacterData

-- =====================================================
-- LOCATION DATA
-- =====================================================

local function CollectLocationData()
    local locationInfo = CM.api.character.GetLocation()

    return {
        zone = locationInfo.zone or "Unknown",
        subzone = locationInfo.subzone or "",
        world = locationInfo.world or "Unknown",
        zoneIndex = locationInfo.zoneIndex,
        zoneId = locationInfo.zoneId,
    }
end

CM.collectors.CollectLocationData = CollectLocationData

-- =====================================================
-- TITLES DATA
-- =====================================================

local function CollectTitlesData()
    -- Use API layer granular functions (composition at collector level)
    local currentTitle = CM.api.titles.GetCurrentTitle()
    local allTitles = CM.api.titles.GetAllTitles()

    local data = {
        current = currentTitle or "",
        owned = {},
        summary = {
            totalOwned = 0,
            totalAvailable = 0,
        },
    }

    if allTitles then
        for _, title in ipairs(allTitles) do
            if title.owned then
                table.insert(data.owned, {
                    id = title.id,
                    name = title.name or "Unknown",
                    isCurrent = title.isCurrent or false,
                })
            end
        end
        data.summary.totalOwned = #data.owned
        data.summary.totalAvailable = data.summary.totalOwned
    end

    -- Sort owned titles alphabetically
    table.sort(data.owned, function(a, b)
        return (a.name or "") < (b.name or "")
    end)

    return data
end

CM.collectors.CollectTitlesData = CollectTitlesData

-- =====================================================
-- ATTRIBUTES DATA
-- =====================================================

local function CollectAttributesData()
    CM.DebugPrint("COLLECTOR", "Collecting character attributes data...")

    -- Use API layer granular functions (composition at collector level)
    local nameInfo = CM.api.character.GetName()
    local genderInfo = CM.api.character.GetGender()
    local raceInfo = CM.api.character.GetRace()
    local classInfo = CM.api.character.GetClass()
    local allianceInfo = CM.api.character.GetAlliance()
    local levelInfo = CM.api.character.GetLevel()
    local locationInfo = CM.api.character.GetLocation()
    local titleInfo = CM.api.titles.GetCurrentTitle()

    -- Get alliance name using alliance API (cross-domain composition)
    local allianceName = "Unknown"
    if allianceInfo.id then
        local name = CM.SafeCall(GetAllianceName, allianceInfo.id)
        if name then
            allianceName = zo_strformat("<<1>>", name)
        end
    end

    -- Combat API (for attributes)
    local attributes = CM.api.combat.GetAttributes()

    -- Collectibles API (for ESO Plus)
    local esoPlus = CM.api.collectibles.IsESOPlus()

    -- Progression API (for age)
    local secondsPlayed = CM.api.progression.GetAge()

    -- Time API (for age formatting)
    local age = nil
    local ageMetrics = nil
    if secondsPlayed > 0 then
        -- Create short format: "1d 18h 49m" instead of verbose "1 day, 18 hours..."
        local days = math.floor(secondsPlayed / 86400)
        local hours = math.floor((secondsPlayed % 86400) / 3600)
        local minutes = math.floor((secondsPlayed % 3600) / 60)

        local ageParts = {}
        if days > 0 then
            table.insert(ageParts, string.format("%dd", days))
        end
        if hours > 0 or days > 0 then -- Show hours if we have days
            table.insert(ageParts, string.format("%dh", hours))
        end
        if minutes > 0 or (days == 0 and hours == 0) then -- Always show minutes if no days/hours
            table.insert(ageParts, string.format("%dm", minutes))
        end

        age = table.concat(ageParts, " ")

        -- Add computed fields for age
        local hoursPlayed = math.floor(secondsPlayed / 3600) -- 3600 seconds per hour
        ageMetrics = {
            seconds = secondsPlayed,
            hours = hoursPlayed,
            days = days,
            formatted = age,
        }
    end

    -- Champion API (for CP)
    local cpPoints = CM.api.champion.GetPoints()

    -- Skills API (for skill points)
    local skillPoints = CM.api.skills.GetSkillPoints()

    -- Mundus Stone (from Combat collector)
    local mundusData = CM.collectors.CollectMundusData and CM.collectors.CollectMundusData()
        or { active = false, name = nil }

    -- Active Buffs (from Combat collector)
    local buffsData = CM.collectors.CollectActiveBuffs and CM.collectors.CollectActiveBuffs() or {}

    -- Riding Skills (from Progression collector)
    local ridingData = CM.collectors.CollectRidingSkillsData and CM.collectors.CollectRidingSkillsData() or {}

    -- Transform API data to expected format
    local data = {
        -- Basic identity
        level = levelInfo.level or 0,
        gender = genderInfo.name or "Unknown",
        race = raceInfo.name or "Unknown",
        class = classInfo.name or "Unknown",
        alliance = allianceName,
        server = locationInfo.world or "Unknown",
        account = nameInfo.displayName or "Unknown",

        -- Progression
        cp = cpPoints.total or 0,
        skillPoints = skillPoints.unspent or 0,
        attributes = {
            magicka = attributes.magicka or 0,
            health = attributes.health or 0,
            stamina = attributes.stamina or 0,
        },

        -- Character info
        title = titleInfo or "",
        age = age,
        ageMetrics = ageMetrics,
        esoPlus = esoPlus or false,

        -- Location
        location = {
            zone = locationInfo.zone or "Unknown",
            subzone = locationInfo.subzone or "",
            world = locationInfo.world or "Unknown",
        },

        -- Mundus Stone
        mundus = {
            active = mundusData.active or false,
            name = mundusData.name or nil,
        },

        -- Active Buffs
        buffs = {
            food = buffsData.food or nil,
            potion = buffsData.potion or nil,
            other = buffsData.other or {},
        },

        -- Riding Skills
        riding = {
            speed = ridingData.speed or 0,
            stamina = ridingData.stamina or 0,
            capacity = ridingData.capacity or 0,
            maxedOut = ridingData.maxedOut or false,
        },
    }

    CM.DebugPrint("COLLECTOR", "Character attributes data collected")
    return data
end

CM.collectors.CollectAttributesData = CollectAttributesData

-- =====================================================
-- CHARACTER STATS DATA
-- =====================================================

local function CollectCharacterStatsData()
    CM.DebugPrint("COLLECTOR", "Collecting character stats data...")

    -- Use Combat API to get all stats
    local health = CM.api.combat.GetStat(STAT_HEALTH_MAX)
    local magicka = CM.api.combat.GetStat(STAT_MAGICKA_MAX)
    local stamina = CM.api.combat.GetStat(STAT_STAMINA_MAX)
    local powerStats = CM.api.combat.GetPowerStats()
    local regenStats = CM.api.combat.GetRegenStats()

    local math_floor = math.floor

    -- Calculate crit chance percentages (ESO formula: Rating / 219 = % at CP 160+)
    local weaponCritRating = powerStats.physical and powerStats.physical.crit or 0
    local spellCritRating = powerStats.spell and powerStats.spell.crit or 0
    local weaponCritChance = weaponCritRating > 0 and math_floor((weaponCritRating / 219) * 10) / 10 or 0
    local spellCritChance = spellCritRating > 0 and math_floor((spellCritRating / 219) * 10) / 10 or 0

    -- Calculate mitigation percentage (ESO formula: Resist / (Resist + 50 * Level))
    local playerLevel = CM.api.character.GetLevel().level or 50
    local resistDivisor = 50 * playerLevel
    local physicalResist = powerStats.resistance and powerStats.resistance.physical or 0
    local spellResist = powerStats.resistance and powerStats.resistance.spell or 0
    local physicalMitigation = physicalResist > 0
            and math_floor((physicalResist / (physicalResist + resistDivisor)) * 1000) / 10
        or 0
    local spellMitigation = spellResist > 0 and math_floor((spellResist / (spellResist + resistDivisor)) * 1000) / 10
        or 0

    -- Return flat structure for backward compatibility
    local data = {
        -- Resources (flat structure)
        health = health or 0,
        magicka = magicka or 0,
        stamina = stamina or 0,

        -- Power
        weaponPower = powerStats.physical and powerStats.physical.power or 0,
        spellPower = powerStats.spell and powerStats.spell.power or 0,

        -- Critical
        weaponCritRating = weaponCritRating,
        weaponCritChance = weaponCritChance,
        spellCritRating = spellCritRating,
        spellCritChance = spellCritChance,

        -- Penetration
        physicalPenetration = powerStats.physical and powerStats.physical.penetration or 0,
        spellPenetration = powerStats.spell and powerStats.spell.penetration or 0,

        -- Resistance
        physicalResist = physicalResist,
        physicalMitigation = physicalMitigation,
        spellResist = spellResist,
        spellMitigation = spellMitigation,

        -- Recovery
        healthRecovery = regenStats.health or 0,
        magickaRecovery = regenStats.magicka or 0,
        staminaRecovery = regenStats.stamina or 0,
    }

    CM.DebugPrint("COLLECTOR", "Character stats data collected")
    return data
end

CM.collectors.CollectCharacterStatsData = CollectCharacterStatsData

CM.DebugPrint("COLLECTOR", "Character collector module loaded")
