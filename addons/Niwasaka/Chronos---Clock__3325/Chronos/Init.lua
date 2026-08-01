Chronos = {
    name = "Chronos",
    addonName = "Chronos",
    displayName = "Chronos",
    author = "Niwasaka",
    website = "https://www.esoui.com/downloads/info3325-Chronos-Clock.html",
    slashCommand = "/time",
    version = "1.3.2",
    defaults = {
        showClock = true,
        clockFontSize = 20,
        clockFontOutline = "none",
        clockFontColor = "ffffff",
        clockTextFont = "Univers 67",
        showClockBG = true,
        clockBackground = "ESO Status",
        clockBackgroundColor = "3595de",
        clockBackgroundAlpha = 100,
        clockDst = true,
        showClockUTC = false,
        clockUTCColor = "ffffff",
        clockUTCDelta = 10,
        timeZoneIndex = -1,
        showChangelog = true;
        welcomeVersion = 0,
    },
}

function Chronos:Init()
    self.db = ZO_SavedVars:NewAccountWide("ChronosSavedVars", 1, nil, self.defaults)
    self:InitTimeZone()
    self:InitMenu()
    self:InitClock()

    Chronos.ChangelogScreen()
end

EVENT_MANAGER:RegisterForEvent(Chronos.addonName, EVENT_ADD_ON_LOADED, function(_, addon)
    if addon == Chronos.addonName then
        Chronos:Init()
    end
end)
