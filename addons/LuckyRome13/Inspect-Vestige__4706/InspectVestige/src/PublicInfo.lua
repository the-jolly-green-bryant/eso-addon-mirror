-- Inspect Vestige by LuckyRome13
-- PublicInfo.lua -- reads the only data ESO exposes about OTHER players.
--
-- This is the fallback card shown for anyone we can't get a full loadout from
-- (strangers, non-grouped friends, or group members without the addon).
-- These functions accept a unit tag such as "reticleover", "group1".."group12".

local IV = InspectVestige

-- Basic public meta for a live unit tag. Returns a loadout-shaped table whose
-- build sections are empty (gear/skills/attrs are unavailable for other players).
function IV.BuildPublicInfo(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then
        return nil
    end
    if not IsUnitPlayer(unitTag) then
        return nil
    end

    return {
        meta = {
            name      = GetUnitName(unitTag),
            atAccount = GetUnitDisplayName(unitTag),
            class     = GetUnitClass(unitTag),
            race      = GetUnitRace(unitTag),
            alliance  = GetUnitAlliance(unitTag),
            level     = GetUnitLevel(unitTag),
            cp        = GetUnitChampionPoints(unitTag),
            gender    = GetUnitGender(unitTag),
            zone      = GetUnitZone(unitTag),
            source    = "public",
            ts        = GetTimeStamp(),
        },
        gear   = {},
        skills = {},
        attrs  = {},
        mundus = nil,
        cp     = { slotted = {} },
        food   = nil,
    }
end

-- Minimal public card built from just a name/@account when no live unit tag is
-- available (e.g. right-clicking an offline friend). Almost everything is unknown.
function IV.BuildNameOnlyInfo(atAccount, characterName)
    return {
        meta = {
            name      = characterName or "",
            atAccount = atAccount or "",
            source    = "public",
            ts        = GetTimeStamp(),
        },
        gear   = {},
        skills = {},
        attrs  = {},
        mundus = nil,
        cp     = { slotted = {} },
        food   = nil,
    }
end

-- Overlay a decoded build (from a peer/cache payload) onto a loadout that already
-- carries public meta. Keeps meta intact; copies every build section (incl. curse).
function IV.OverlayBuild(loadout, build)
    if not loadout or not build then return loadout end
    loadout.gear   = build.gear or loadout.gear
    loadout.skills = build.skills or loadout.skills
    loadout.attrs  = build.attrs or loadout.attrs
    loadout.stats  = build.stats or loadout.stats
    loadout.cp     = build.cp or loadout.cp
    loadout.mundus = build.mundus   -- nil-able (mortal / no mundus)
    loadout.food   = build.food     -- nil-able
    loadout.curse  = build.curse    -- nil-able
    loadout.potion = build.potion   -- nil-able (no quickslot potion)
    loadout.class  = build.class or loadout.class   -- subclass / class-mastery
    return loadout
end

-- Find the group unit tag ("group1".."group12") for a given @account, or nil if
-- that account is not currently in our group. This is how we route a peer request.
function IV.FindGroupUnitTagByAccount(atAccount)
    if not atAccount or atAccount == "" then
        return nil
    end
    local size = GetGroupSize()
    for i = 1, size do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and DoesUnitExist(tag) and GetUnitDisplayName(tag) == atAccount then
            return tag
        end
    end
    return nil
end
