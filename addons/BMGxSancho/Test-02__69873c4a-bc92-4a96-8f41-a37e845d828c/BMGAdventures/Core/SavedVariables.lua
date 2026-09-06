local BA = BMGAdventures
BA.SavedVariables = BA.SavedVariables or {}

local accountDefaults = {
    schemaVersion = 2,
    registryVersion = "2026.09.003",
    profileRevision = 0,
    adventurerXP = 0,
    adventurerLevel = 1,
    prestigeXP = 0,
    prestigeLevel = 0,
    disciplines = {
        RAID = { xp = 0, level = 1 },
        DUNG = { xp = 0, level = 1 },
        EXPL = { xp = 0, level = 1 },
        QUEST = { xp = 0, level = 1 },
        PVP = { xp = 0, level = 1 },
        MAST = { xp = 0, level = 1 },
    },
    scores = { adventure = 0, RAID = 0, DUNG = 0, EXPL = 0, QUEST = 0, PVP = 0, MAST = 0 },
    challenges = {},
    collections = {},
    unlocks = {},
    presentation = { equippedTitle = nil, featuredBadges = {} },
    legacyImport = { version = 0, completed = false, achievements = {}, mappedIds = {}, stats = {}, mapped = 0 },
}

local settingsDefaults = {
    notifications = true,
    developerMode = true,
    reticleProfiles = true,
    groupSharing = true,
    leaderboardEnabled = false,
    weeklyCategories = { RAID=true, DUNG=true, EXPL=true, QUEST=true, PVP=true, MAST=true },
    autoLegacyImport = true,
}

function BA.SavedVariables:Initialize()
    BA.account = ZO_SavedVars:NewAccountWide("BMGAdventuresAccount", 1, nil, accountDefaults)
    BA.settings = ZO_SavedVars:NewAccountWide("BMGAdventuresSettings", 1, nil, settingsDefaults)
end
