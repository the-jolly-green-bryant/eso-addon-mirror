--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-02-11
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}
function Clock_TST.I18N()
    return {
        bindings = {
            nToggle = "Toggle visibility",
            nToggleTime = "Toggle date visibility",
            nToggleMoon = "Toggle moon visibility"
        },
        error = {
            library = "Could not connect to the LibClockTST library."
        },
        menu = {
            core = {
                nHeadTime = "Time and date",
                nHeadMoon = "Moon",
                nHeadGeneral = "General",
                nHeadDebug = "Debug",
            },
            presets = {
                nPreset = "Preset",
                wPreset = "This will replace your current settings with a preset.",
                nSave = "Save",
                wSave = "This will overwrite you current preset.",
                nDelete = "Delete",
                wDelete = "This will delete your current preset.",
                nCurrent = "Current preset",
            },
            account = {
                nAccount = "Synchronize settings",
                tAccount = "Use the same settings for all characters."
            },
            booleans = {
                nSub = "On/Off Settings", -- togOpt
                nTimeVisible = "Show Time", -- sTime
                nMouseEnabled = "Interactable",
                nMovable = "Movable", -- sMove
                tMovable = "Select if the Clock should be movable.", -- tMove
                nTooltip = "Show tooltip when hovering",
                nBackground = "Show background", -- nsBg
                tTimeBackground = "Adds a background behind the Clock.", -- tsBg
                nAddZeroHour = "Add zeros to Hours", -- sNum
                tAddZeroHour = "Pad single digit hours with zero: 1:24 -> 01:24.", -- tNum
                nAddZeroMin = "Add zeros to Minutes", -- sNum
                tAddZeroMin = "Pad single digit minutes with zero: 1:4 -> 1:04.", -- tNum
                nAddZeroSec = "Add zeros to Seconds", -- sNum
                tAddZeroSec = "Pad single digit seconds with zero.", -- tNum
                nAddZeroDay = "Add zeros to Days", -- sNum
                tAddZeroDay = "Pad single digit days with zero.", -- tNum
                nAddZeroMonth = "Add zeros to Months", -- sNum
                tAddZeroMonth = "Pad single digit months with zero.", -- tNum
                nUSFormat = "12h format", -- sFormat,
				nMinAMPM = "A.M./P.M. -> am/pm", -- minAMPM
				tMinAMPM = "Format the standalone clock text to use minimalistic am/pm.", -- minAMPM
                nJapanese = "Show midnight as 0", --sJap
                wAffect = "This only effects custom time format (#/%/$) from above 'Look Options' NOT popup menu date/time.",
                nHoverScale = "Scale when hovering",
                nHoverColour = "Highlight when hovering",
                nMoonVisible = "Show Moon", -- sMoon
                nFight = "Hide in fights",
                nMap = "Only show on map",
                nLink = "Link the movements of the label with the moon",
                nGroup = "Hide in groups",
                nDebug = "Debug mode",
            },
            styles = {
                nSub = "Look Options", -- look
                nFormat = "Write your own format for the floating time and date",
                tFormat = "Enter a symbol (# for lore, % for real and $ for fake lore) followed by a letter listed below. You can enter any other text between pairs to customize strings. Example: #H:#M #p = 3:14 am.",
                dFormat = "%A\t\t full weekday name [Friday]\n"
                        .. "%a\t\t for the abbreviated [Fri]\n"
                        .. "%B\t\t full month name [March]\n"
                        .. "%b\t\t for the abbreviated [Mar]\n"
                        .. "%D\t\t day of the month [12th]\n"
                        .. "%d\t\t day as plain number [12]\n"
                        .. "%H\t\t hour\n"
                        .. "%M\t\t minute\n"
                        .. "%m\t\t month\n"
                        .. "%p\t\t either \"am\" or \"pm\"\n"
                        .. "%S\t\t second\n"
                        .. "%w\t\t weekday [1-7 = Monday-Sunday]\n"
                        .. "%x\t\t date [17.02.20]\n"
                        .. "%X\t\t time [23:48:10 | 11:48 PM]\n"
                        .. "%Y\t\t full year [2020]\n"
                        .. "%y\t\t shortened year [20]",
                nColor = "Color", -- nColPick
                tColor = "Change the color of the Clock.", -- tColPick
                nFont = "Font", -- nFont
                tFont = "Change the font of the Clock.", -- tFont
                nStyle = "Style", -- nStyle
                tStyle = "Change the style of the Clock.", -- tStyle
                nSize = "Size", -- nSize
                tSize = "Change the font-size of the Clock.",
                nBackground = "Background texture",
                nBackgroundColour = "Background colour",
                nBackgroundHoverColour = "Background hover colour",
                nBackgroundOffsetX = "Background width offset",
                tBackgroundOffsetX = "Offset to the calculated width of the background.",
                nBackgroundOffsetY = "Background height offset",
                tBackgroundOffsetY = "Offset to the calculated height of the background.",
                nMasser = "Masser's texture",
                nSecunda = "Secunda's texture",
                nMoonWidth = "Width of the moon distance",
                nMoonHeight = "Height of the moon distance",
                nScale = "Scaling",
                nAlpha = "Visibility",
                nScaleFactor = "Scale factor",
                tScaleFactor = "How much the item should increase when hovering."
            },
            feedback = {
                tFeedback = "If you found a bug, have a request or a suggestion, or simply wish to donate,\n"
                    .. "you are welcome to send me an email.",
                nMail = "In-game Feedback",
                nGitHub = "Report an issue",
                nLessGold = "Small donation",
                nMoreGold = "Larger donation",
                nRealGold = "Real donation"
            }
        },
        view = {
            core = {
                menu = {
                    tooltip = "Show tooltip",
                    background = "Show background",
                    movable = "Is movable",
                    link = "Link the movement of the moon to the time",
                    open = "Open settings menu",
                    scale = "Reset scaling",
                },
            },
            moon = {
                tooltip = {
                    full = "The moon is full right now.\n"
                            .. "It will stay that way for <<1 [less than one hour/one hour/$d hours]>>.\n",
                    isWaxing = "The moon is <<1>>% full and is waxing.\n"
                            .. "He needs <<2 [less than one hour/one hour/$d hours]>>,\n"
                            .. "to reach its full glory.\n",
                    isWaning = "The moon is <<1>>% full and is waning.\n"
                            .. "He needs <<2>> hours again,\n"
                            .. "to reach its full glory.\n",
                    duration = "That is <<1 [less than a day/a day/$d days]>> in Tamriel.",
                }
            },
            time = {
                am = "A.M.",
                pm = "P.M.",
				amM = "am",
				pmM = "pm",
            },
            date = {
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
                    year = "2E",
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
        }
    }
end
