-------------------------------------------
-- en - english:english
-- Author: Tyx
-------------------------------------------
cl.ln = {
    com = {
        show = "show",
        midnight = "midnight",
        sunrise = "sunrise",
        noon = "noon",
        sunset = "sunset",
        reset = "reset",
        resetTxt = "Clock is now reseted.",
        resetui = "resetUI",
        resetUITxt = "Clock User Interface is now reseted.",
        resettime = "resetTime",
        resetTimeTxt = "Clock time is now reseted.",
        us = "us",
        usOn = "The Time is represented in 12h with am/pm.",
        usOff = "The Time is represented in 24h.",
        num = "num",
        numOn = "Zeros are added.",
        numOff = "Single digits are shown.",
        sec = "sec",
        secOn = "Seconds are shown.",
        secOff = "Seconds are hidden.",
        active = "active",
        activeOn = "Clock - TST is on.",
        activeOff = "Clock - TST is off.",
        move = "move",
        moveOn = "Clock is now moveable.",
        moveOff = "Clock is now fixed.",
        moon = "moon",
        moonOn = "The moon is shown.",
        moonOff = "The moon is hidden.",
        ldate = "gdate",
        ldateOn = "Lore date is shown.",
        ldateOff = "Lore date is hidden.",
        fldate = "fldate",
        fldateOn = "Lore fake date is shown.",
        fldateOff = "Lore fake date is hidden.",
        rt = "rt",
        rtOn = "Real-Time is shown.",
        rtOff = "Real-Time is hidden.",
        date = "date",
        dateOn = "Date is shown.",
        dateOff = "Date is hidden.",
        text = "Welcome to the |cFFD700Clock|r - TST by |c5175ea@Tyx|r [EU] help menu\n"
                .. "To show the current database of the times, write:\n"
                .. "\t\cl show\n"
                .. "To set the current time as Tamriel midnight/sunrise/noon/sunset use the appropriate command:\n"
                .. "\t\cl midnight\n\t\cl sunrise\n\t\cl noon\n\t\cl sunset\n"
                .. "To reset the current database, only the look or time to the default values, write:\n"
                .. "\t\cl reset\n\t\cl resetUI\t\cl resetTime\n"
                .. "You can toggle the displayed time formatt (12h/24h) by writing:\n"
                .. "\t\cl us\n"
                .. "To delete the zeros added before a single digit hour, write:\n"
                .. "\t\cl num\n"
                .. "You can toggle to display seconds with the command:\n"
                .. "\t\cl sec\n"
                .. "For showing the current moon phase, write:\n"
                .. "\t\cl moon\n"
                .. "To display the date (lore/fake lore/real), write:\n"
                .. "\t\cl ldate\n\t\cl fldate\t\cl date\n"
                .. "To stop/start the Clock from being moveable, write:\n"
                .. "\t\cl move\n"
                .. "To deactivate/activate the Clock use.\n"
                .. "\t\cl active\n\n"
                .. "To show the settings menu, write:\n"
                .. "\t\clsettings\n",
    },
    gui = {
        com = "/clsettings",
        -- Language
        lang = "Language",
        langTxt = "Select a language for the Clock Settings and Commands.\n Warning: this will reload the UI.",
        -- Toggle
        togOpt = "On/Off Settings",
        togOptTxt = "Change the way the Clock looks.",
        sClock = "Show Clock",
        sTime = "Show Time",
        sMove = "Movable",
        tMove = "Select if the Clock should be movable.",
        sAHide = "Auto Hide",
        tAHide = "Select if the Clock should be hidden when a menu is open.",
        sFormat = "12h format",
        sAMPM = "Show AM/PM",
        sJap = "Show midnight as 0",
        sNum = "Add zeros",
        tNum = "Add zeros before a single number: 1:24 -> 01:24",
        sSec = "Show Seconds",
        sMoon = "Show Moon",
        tMoon = "Adds a little icon with the current moon phase and the hours until the next phase begins.",
        sLDate = "Show lore Date",
        tLDate = "Adds a line under the Clock with the day, month and year in Tamriel.",
        sFLDate = "Show fake lore Date",
        tFLDate = "Adds a line under the Clock with the day, month and year in Tamriel.",
        sRT = "Show real time",
        tRT = "Adds a line under the Clock with the Time of your Operating System.",
        sDate = "Show real Date",
        tDate = "Adds a line under the Clock with the day, month and year of your Operating System.",
        nsBg = "Show Background",
        tsBg = "Adds a background behind the Clock.",
        -- Look
        look = "Look Options",
        lookTxt = "Various options to change how the Clock looks.",
        nColPick = "Color",
        tColPick = "Change the color of the Clock.",
        nFont = "Font",
        tFont = "Change the font of the Clock.",
        nStyle = "Style",
        tStyle = "Change the style of the Clock.",
        nSize = "Size",
        tSize = "Change the size of the Clock.",
        nMoonStyle = "Moon style",
        tMoonStyle = "Change the style of the moon label.",
        nMoonSize = "Moon size",
        tMoonSize = "Change the size of the displayed time to next moon phase.",
        dMoonSize = "Clock |cFFA4000.7.9|r\nIt is now possible to change the size of the moon phase separately from the size of the time. Check it out in the settings menu (Settings->Addons->Clock).\nThanks for using Clock |cFFA4000.7.9|r :)",
        nMoonOffsetY = "Moon y-offset",
        tMoonOffsetY = "Move the moon in the vertical direction.",
        --real
        nSepLR = "Different Looks",
        tSepLR = "Choose if you want your real date have an other look than your lore date.",
        nRColPick = "Color",
        tRColPick = "Change the color of the Clock.",
        nRFont = "Font",
        tRFont = "Change the font of the Clock.",
        nRStyle = "Style",
        tRStyle = "Change the style of the Clock.",
        nRSize = "Size",
        tRSize = "Change the size of the Clock.",
        nBg = "Background",
        tBg = "Choose a background for the Clock.",
        sHor = "Horizontal",
        tHor = "Show the lore- and real time next to each other.",
        descEditLookY = "Change the format of the Clock: Use '_' before a variable!\n"
                .. "Year/Month/Day",
        descEditLookYTxt = "Year: Y = 582 (14)\tYY = 2E 582 (2014)\n"
                .. "Month: M = 4\tMM = 04\tMMM = First Seed (April)\n"
                .. "Day: D = 4\tDD = 04\tDDD = Fredas (Friday)",
        descEditLookD = "Hour/Minute/Second",
        descEditLookDTxt = "Hour: h = 9\thh = 09\n"
                .. "Minute: m = 9\tmm = 09\n"
                .. "Second: s = 9\tss = 09",
        descEditLookE = "Example",
        descEditLookETxt = "_DDD, _D day of _MMM _YY _hh:_mm:_ss\n"
                .. "Fredas, 4th day of First Seed 2E 582\n"
                .. "Friday, 4th day of April 2014",
        nELore = "Lore-time format",
        tELore = "Write the time format for the lore time in here.",
        nEReal = "Real-time format",
        tEReal = "Wirte the time format for the real time in here.",
        -- Data
        day = "Sync [Day]",
        dayTxt = "Adjust the length of one day to your liking.",
        descDB = "Sync [Midnight/Sunrise/Noon/Sunset]",
        descDBTxt = "Synchronize the time of the Clock.\nE.g. select noon when the sun is right under the South needle of the compass.",
        nMid = "Midnight is now!",
        tMid = "Select this if the Moon is at his highest point. ",
        nRise = "Sunrise is now!",
        tRise = "Deprecated! Sunrise is not really clear. Work with noon!",
        nNoon = "Noon is now!",
        tNoon = "Select this if the sun is right under the south needle of your compass.",
        nSet = "Sunset is now!",
        tSet = "Deprecated! Sunset is not really clear. Work with noon!",
        descDS = "Sync [Daylength]",
        descDSTxt = "Synchronize the daylength of the Clock.",
        nDayH = "Hours",
        tDayH = "How long does one in-game day last in real time hours.",
        nDayM = "Minutes",
        tDayM = "How long does one in-game day last in real time minutes.",
        nDayS = "Seconds",
        tDayS = "How long does one in-game day last in real time seconds.",
        nAplyData = "Calculate",
        tAplyData = "Calculates the current time in Tamriel based on the selected daylength and your synced (or default) start time.",
        -- Moon
        moon = "Sync [Moon]",
        moonTxt = "Adjust the start of this moon phases and the length of one mood phase to your liking.",
        nFull = "Full moon is now!",
        tFull = "Select this at the start of Full moon phase.",
        nNew = "New moon is now!",
        tNew = "Select this at the start of the New moon phast.",
        descMS = "Sync [Moon]",
        descMSTxt = "Synchronize the moon phase of the Clock.\nDo that the very start of one phase.",
        descMoon = "Sync [Phase length]",
        descMoonTxt = "You only need to sync the Clock for either the full- or new moon start and only once.\n"
                .. "A full moon phase is 30 ingame days. The follwing Sliders are here to select the percentage of one phase.",
        nNightF = "Full moon phase percentage",
        tNightF = "Select how long the Full moon phase last.",
        nNightW = "Waning/Waxing moon phase in days",
        tNightW = "Select how long the Waning/Waxing moon phase last.",
        nNightN = "New moon phase in days",
        tNightN = "Select how long the New moon phase last.",
        nAplyMoon = "Calculate",
        tAplyMoon = "Calculates the current moon phase based on the selected lengths and your synced (or default) start time.",
        -- Reset
        reset = "Reset Options",
        resetTxt = "Various option to reset all or just a part of the Clock.",
        nResFull = "Reset all",
        tResFull = "Resets everything to the default values.",
        wResFull = "This will replace all your customized values with the default ones!\nWill reload the UI!",
        nResUI = "Reset the UI",
        tResUI = "Resets the look and place of the Clock to the default values.",
        wResUI = "This will replace all your customizations to the UI with the default values!",
        nResTime = "Reset the Time",
        tResTime = "Resets your customized syncs and lengths of the Clock to the default values.",
        wResTime = "This will replace all your customizations to the Time with the default values!\nWill reload the UI!",
        nDeprecated = "Outdated version ",
        tDeprecated = "This is an outdated version of Clock.\n"
                .. "Most likely it will still work for a very long time, but I will not update it anymore.\n"
                .. "However, I wrote a whole new version from scratch, which is nicer and eats less power.",
    },
    vi = {
        dbTS = {
            [1] = "Next midnight (0:00 TST) is at ",
            [2] = "Next sunrise (4:00 TST) is at ",
            [3] = "Next noon (12:00 TST) is at ",
            [4] = "Next sunset (20:00 TST) is at ",
            [5] = "A day is ",
            [6] = "long\n",
        },
        date = {
            first = "st",
            second = "nd",
            third = "rd",
            allNum = "th",
            lore = {
                week = {
                    [1] = "Morndas",
                    [2] = "Tirdas",
                    [3] = "Middas",
                    [4] = "Turdas",
                    [5] = "Fredas",
                    [6] = "Loredas",
                    [7] = "Sundas",
                },
                months = {
                    [1] = "Mornings Star",
                    [2] = "Sun's Dawn",
                    [3] = "First Seed",
                    [4] = "Rain's Hand",
                    [5] = "Second Seed",
                    [6] = "Midyear",
                    [7] = "Sun's Height",
                    [8] = "Last Seed",
                    [9] = "Hearthfire",
                    [10] = "Frostfall",
                    [11] = "Sun's Dusk",
                    [12] = "Evening Star",
                },
                year = "2E ",
            },
            real = {
                week = {
                    [1] = "Monday",
                    [2] = "Tuesday",
                    [3] = "Wednesday",
                    [4] = "Thursday",
                    [5] = "Friday",
                    [6] = "Saturday",
                    [7] = "Sunday",
                },
                months = {
                    [1] = "January",
                    [2] = "February",
                    [3] = "March",
                    [4] = "April",
                    [5] = "May",
                    [6] = "June",
                    [7] = "July",
                    [8] = "August",
                    [9] = "September",
                    [10] = "October",
                    [11] = "November",
                    [12] = "December",
                },
            },
        },
    },
}
