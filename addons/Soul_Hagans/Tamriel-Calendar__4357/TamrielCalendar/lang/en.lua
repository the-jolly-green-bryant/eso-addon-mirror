TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar

TC.L = {
    days = {"Sundas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"},
    shortDays = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Lo"},
    months = {"Morning Star", "Sun's Dawn", "First Seed", "Rain's Hand", "Second Seed", "Midyear", "Sun's Height", "Last Seed", "Hearthfire", "Frostfall", "Sun's Dusk", "Evening Star"},
    realMonths = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"},
    signs = {"Ritual", "Lover", "Lord", "Mage", "Shadow", "Steed", "Apprentice", "Warrior", "Lady", "Tower", "Atronach", "Thief", "Serpent"},
    moonPhases = {"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"},
    yearSuffix = "year of 2nd Era",
    monthPrefix = "Month of",
    signPrefix = "Sign:",
    stripFormat = "%s, %d %s %d | %s | %02d:%02d",
    titleHoliday = "Holiday (Lore):",
    btnPrev = "Prev",
    btnNext = "Next",
    hNames = {
        nl = "New Life Festival",
        hd = "Heart's Day (Sanguine)",
        aj = "ESO Anniversary",
        jd = "Jester's Day",
        zz = "Zenithar's Day",
        my = "Midyear (Pelinal)",
        wf = "Witches Festival",
        ud = "Warrior's Day",
        ol = "Old Life"
    }
}

ZO_CreateStringId("SI_BINDING_NAME_TC_TOGGLE_UI", "Show/Hide Strip")
ZO_CreateStringId("SI_BINDING_NAME_TC_TOGGLE_WINDOW", "Open Big Calendar")