ShouldIUlt.defaults = {
    trackBerserk = true,
    trackCourage = true,
    trackWarhorn = true,
    trackPA = true,
    trackOffBalance = true,
    trackVulnerability = true,
    trackBrittle = true,
    trackFeedingFrenzy = true,
    trackSlayer = true,
    trackBrutality = false,
    trackSorcery = false,
    trackProphecy = false,
    trackSavagery = false,
    trackResolve = false,
    trackForce = true,
    trackHeroism = false,
    trackProtection = false,
    trackFortitude = false,
    trackEvasion = false,
    showStacks = false,
    trackBreach = false,
    trackPermanentBuffs = false,
    uiVisible = true,
    showOnlyInDungeon = false,
    -- UI settings
    positionX = 720,
    positionY = 420,
    iconSpacing = 5,
    iconSize = 50,

    showTimer = true,
    trackAbyssalInk = false,
    staticContainer = false,
    inactiveBuffOpacity = 0.3,
    timerThreshold = 3.0,

    trackWeaponSpellDamage = false,
    trackWeaponSpellCrit = false,
    enableBossScanning = true,
    maxBuffScanLimit = 50,
    scanUpdateRate = 1000,

    -- Simulate
    simulationMode = false,
    simulateAllTracked = false,
    hidePermanentBuffs = false,
    trackBossDebuffs = true,
    layoutDirection = "horizontal",
    maxIconsPerRow = 7,
    maxIconsPerColumn = 7,

    showOffBalanceImmunity = true,
    -- Should I Ult settings
    enableUltCheck = false,
    ultCheckMode = "any",
    showUltMessage = true,
    ultMessageSize = 2,
    ultMessageColor = { 1, 1, 0, 1 },
    ultMessageSound = true,
    ultCooldown = 6,

    showTimerBar = true,
    timerBarHeight = 4,
    timerBarColor = { 0, 1, 0, 0.8 },
    timerBarPosition = "bottom",

    ultRequiredBuffs = {
        -- Vulnerability
        trackMajorVulnerability = true,
        trackMinorVulnerability = false,
        trackWarhorn = false,
        -- Slayer
        trackMajorSlayer = true,
        trackMinorSlayer = false,

        -- Berserk
        trackMajorBerserk = false,
        trackMinorBerserk = false,

        -- Force
        trackMajorForce = false,
        trackMinorForce = false,

        -- Damage buffs
        trackMajorBrutality = false,
        trackMinorBrutality = false,
        trackMajorSorcery = false,
        trackMinorSorcery = false,

        -- Crit buffs
        trackMajorProphecy = false,
        trackMinorProphecy = false,
        trackMajorSavagery = false,
        trackMinorSavagery = false,

        -- Other buffs
        trackMajorHeroism = false,
        trackMinorHeroism = false,
        trackMajorBrittle = false,
        trackMinorBrittle = false,
        trackOffBalance = false,
        trackPowerfulAssault = false,
        trackAbyssalInk = false,

        -- Courage
        trackMajorCourage = false,
        trackMinorCourage = false
    },
}
