SamiWorldTimers = {
    name = "SamiWorldTimers",
    version = "1.0.3",
    author = "@samihaize",
}

local SWT = SamiWorldTimers

SWT.settings = {}

SWT.defaults = {
    offsetX = 100,
    offsetY = 200,
    timeoutDuration = 8,
    warningDuration = 60,
    alertDuration = 15,
    warningColour = "FFAA00",
    alertColour = "FF0000",
    defaultTextColour = "FFFFFF",
    wipeOnZoneChange = false,
    debug = false,
    backgroundColor = "000000",
    backgroundOpacity = 0.8,
    showTitle = true,
}

SWT.bossTimes = {}
SWT.blacklist = {
    --Geysers
    "Ruella Many-Claws",
    "Churug of the Abyss",
    "Sheefar of the Depths",
    "Girawell the Erratic",
    "Muustikar Wave-Eater",
    "Reefhammer",
    "Darkstorm the Alluring",
    "Eejoba the Radiant",
    "Tidewrack",
    "Vsskalvor",
    --Vents
    "Flame Hound Alpha",
    "Ashen Spriggan",
    "Fire Behemoth",
    "Molten Destroyer",
    "Fissure Goliath",
    --Mirrormoor Mosaic
    "Shrakkaher",
    "Rrarrvok",
    "Krrazzak"
}
SWT.sortedBosses = {}
SWT.sortedDirty = true
