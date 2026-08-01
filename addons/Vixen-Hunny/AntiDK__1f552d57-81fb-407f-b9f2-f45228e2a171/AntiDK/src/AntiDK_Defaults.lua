AntiDK = AntiDK or {}

AntiDK.Defaults = {
    enabled = true,
    posX = 0,
    posY = -90,
    scale = 1.0,
    opacity = 0.85,
    showWhenInCombat = true,
    showStunDodge = true,
    showBuggyStunDuration = true,
    stunhex = { r = 0.97, g = 0.83, b = 0.24 },
    autoHideEnabled = true,
    autoHideDelay = 0,
    fontSize = 16,
    centerTimerFontSize = 40,
    showBackdrop = false,
    backdropOpacity = 0.6,
}

AntiDK.AbilityDB = {
    PowerLash = {
        id = 34117,
        name = "Power Lash",
        duration = 20,
        trackStacks = true,
        color = "FF6666",
    },
    SoulShred = {
        id = 24369,
        name = "Soul Shred",
        trackStacks = true,
        color = "FF6666",
    },
    ShatteringRocks = {
        id = 32678,
        name = "Shattering Rocks",
        hasDelay = true,
        delayTime = 1.0,
        color = "FFAA44",
    },
    MoltenWhip = {
        id = 29474,
        name = "Blessing at the Peak",
        trackStacks = true,
        color = "FF8844",
    },
    CorrosiveArmor = {
        id = 17878,
        name = "Corrosive Armor",
        isEffect = true,
        color = "99FF99",
    },
    Fossilize = {
        id = 32685,
        name = "Fossilize",
        isStun = true,
        color = "FFFF00",
    },
}