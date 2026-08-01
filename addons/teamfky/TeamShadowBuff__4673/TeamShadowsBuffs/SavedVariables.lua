TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs

TSB.name = "TeamShadowsBuffs"
TSB.displayName = "Team Shadows Buffs"
TSB.version = "0.1.0"
TSB.savedVariableName = "TeamShadowsBuffsSavedVariables"
TSB.savedVariableVersion = 1

TSB.defaults = {
    enabled = true,
    debug = false,
    unlocked = false,
    layout = "combined",
    scale = 1.0,
    circleSize = 40,
    frameColor = { r = 0, g = 0, b = 0 },
    frameAlpha = 0.78,
    borderEnabled = true,
    borderColor = { r = 0.86, g = 0.72, b = 0.32 },
    borderAlpha = 0.95,
    borderThickness = 3,
    nameTextColor = { r = 1, g = 1, b = 1 },
    timerTextColor = { r = 1, g = 1, b = 1 },
    acronymTextColor = { r = 1, g = 1, b = 1 },
    badgeAlpha = 0.95,
    barAlpha = 0.95,
    textAlpha = 1.0,
    timerTextScale = 1.0,
    showNames = true,
    showTimers = true,
    showAcronyms = true,
    showBar = true,
    previewEnabled = true,
    combinedX = 220,
    combinedY = 160,
    buffsX = 120,
    buffsY = 260,
    debuffsX = 620,
    debuffsY = 260,
    trackerPositions = {},
    playerOrder = "major_slayer,major_courage,major_force,major_berserk,major_sorcery,major_brutality,major_savagery,major_prophecy,major_resolve,major_heroism,major_expedition",
    bossOrder = "major_vulnerability,major_breach,major_brittle,major_cowardice,major_maim,off_balance",
    effectSettings = {},
    modules = {
        MajorEffects = {
            enabled = true,
            trackPlayerBuffs = true,
            trackBossDebuffs = true,
        },
    },
}
