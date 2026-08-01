--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2021-04-18
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}

--- Constant table with all settings for Clock
function Clock_TST.CONSTANTS()
    local lang = GetCVar("Language.2")
    local name = "ClockTST"
    return {
        NAME = name,
        DISPLAY = "|cFFD700Clock|r - Tamriel Standard Time",
        AUTHOR = "@Tyx, Phuein & Phinix",
        VERSION = "2.2.5",
        SAVED_NAME = name .. "_Settings",
        Menu = {
            time = {
                -- Possible replace: esoui/fontdefs/keyboard/defaultfontdefs_keyboard.xml
                STYLES = {
                    "normal",
                    "outline",
                    "thick-outline",
                    "shadow",
                    "soft-shadow-thick",
                    "soft-shadow-thin",
                },
                FONTS = {
                    "Consolas",
                    "Futura Condensed",
                    "Futura Condensed Bold",
                    "Futura Condensed Light",
                    "ProseAntique",
                    "Skyrim Handwritten",
                    "Trajan Pro",
                    "Univers 55",
                    "Univers 57",
                    "Univers 67",
                },
                BACKGROUND = {
                    -- "Munge",
                    "Brush",
                    "Phase",
                    "Splash",
                    "Stroke",
                    "EsoUI-Item"
                },
            },
            moon = {
                MASSER = {
                    "Crimson",
                    "Pale",
                },
                SECUNDA = {
                    "Ghost",
                },
                BACKGROUND = {
                    "Brush",
                    "Splash",
                    "Solid",
                },
            },
        },
        UI = {
            STYLES = {
                ["normal"] = "normal",
                ["outline"] = "outline",
                ["thick-outline"] = "thick-outline",
                ["shadow"] = "shadow",
                ["soft-shadow-thick"] = "soft-shadow-thick",
                ["soft-shadow-thin"] = "soft-shadow-thin",
            },
            FONTS = {
                ["Consolas"]                = "EsoUI/Common/Fonts/consola.ttf",
                ["Futura Condensed"]        = "EsoUI/Common/Fonts/FTN57.otf",
                ["Futura Condensed Bold"]   = "EsoUI/Common/Fonts/FTN87.otf",
                ["Futura Condensed Light"]  = "EsoUI/Common/Fonts/FTN47.otf",
                ["ProseAntique"]            = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
                ["Skyrim Handwritten"]      = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
                ["Trajan Pro"]              = "EsoUI/Common/Fonts/trajanpro-regular.otf",
                ["Univers 55"]              = "EsoUI/Common/Fonts/univers55.otf",
                ["Univers 57"]              = "EsoUI/Common/Fonts/univers57.otf",
                ["Univers 67"]              = "EsoUI/Common/Fonts/univers67.otf",
            },
            BACKGROUNDS = {
                time = {
                    ["Brush"] = {
                        path = name .. "\\Asset\\Texture\\Time\\Background\\Brush\\",
                        background = "background.dds",
                    },
                    ["Phase"] = {
                        path = name .. "\\Asset\\Texture\\Time\\Background\\Phase\\",
                        background = "background.dds",
                    },
                    ["Splash"] = {
                        path = name .. "\\Asset\\Texture\\Time\\Background\\Splash\\",
                        background = "background.dds",
                    },
                    ["Stroke"] = {
                        path = name .. "\\Asset\\Texture\\Time\\Background\\Stroke\\",
                        background = "background.dds",
                    },
                    ["EsoUI-Item"] = {
                        path = "EsoUI\\Art\\",
                        background = "Miscellaneous\\listItem_backdrop.dds",
                        hover = "ActionBar\\actionBar_mouseOver.dds"
                    },
                },
                moon = {
                    ["Brush"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Background\\Brush\\",
                        background = "background.dds",
                    },
                    ["Splash"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Background\\Splash\\",
                        background = "background.dds",
                    },
                    ["Solid"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Background\\Solid\\",
                        background = "background.dds",
                    },
                },
            },
            MOONS = {
                masser = {
                    ["Crimson"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Masser\\Crimson\\",
                        waxingCrescent = "masser_one_wax_256x256.dds",
                        firstQuarter = "masser_half_wax_256x256.dds",
                        waxingGibbous = "masser_three_wax_256x256.dds",
                        full = "masser_full_256x256.dds",
                        waningGibbous = "masser_three_wan_256x256.dds",
                        thirdQuarter = "masser_half_wan_256x256.dds",
                        waningCrescent = "masser_one_wan_256x256.dds",
                    },
                    ["Pale"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Masser\\Pale\\",
                        waxingCrescent = "masser_one_wax_256x256.dds",
                        firstQuarter = "masser_half_wax_256x256.dds",
                        waxingGibbous = "masser_three_wax_256x256.dds",
                        full = "masser_full_256x256.dds",
                        waningGibbous = "masser_three_wan_256x256.dds",
                        thirdQuarter = "masser_half_wan_256x256.dds",
                        waningCrescent = "masser_one_wan_256x256.dds",
                    },
                },
                secunda = {
                    ["Ghost"] = {
                        path = name .. "\\Asset\\Texture\\Moon\\Secunda\\Ghost\\",
                        waxingCrescent = "secunda_one_wax_256x256.dds",
                        firstQuarter = "secunda_half_wax_256x256.dds",
                        waxingGibbous = "secunda_three_wax_256x256.dds",
                        full = "secunda_full_256x256.dds",
                        waningGibbous = "secunda_three_wan_256x256.dds",
                        thirdQuarter = "secunda_half_wan_256x256.dds",
                        waningCrescent = "secunda_one_wan_256x256.dds",
                    }
                }
            },
        },
        Settings = {
            account = {
                SAVED_NAME = "account",
                SAVED_VERSION = 1,
                DEFAULTS = {
                    saveAccountWide = true,
                }
            },
            booleans = {
                SAVED_NAME = "booleans",
                SAVED_VERSION = 1,
                DEFAULTS = {
                    core = {
                        timeAndMoonAreLinked = true,
                        hideInGroup = false,
                        hideInFight = true,
                        onlyShowOnMap = false,
                    },
                    time = {
                        isVisible = true,
                        isMovable = true,
                        isMouseEnabled = true,
                        hasBackground = true,
                        hasTooltip = true,
                        scaleWhenHover = false,
                        highlightWhenHover = true,

                        hasUSFormat = lang == "en" or lang == "jp",
                        hasJapFormat = lang == "jp", -- if [hasUSFormat] then 12 am <=> pm
                        addZeroHour = lang ~= "en", -- show 0[0-9] instead of [0-9]
						addZeroMin = lang ~= "en",
						addZeroSec = true,
						addZeroDay = lang ~= "en",
						addZeroMonth = lang ~= "en",
						minAMPM = false,

                        hasLoreDate = true,
                        hasFakeLoreDate = false,
                        hasRealDate = true,
                    },
                    moon = {
                        isVisible = true,
                        isMovable = true,
                        isMouseEnabled = true,
                        hasBackground = true,
                        hasTooltip = true,
                        scaleWhenHover = true,
                        highlightWhenHover = false,
                    },
                },
            },
            styles = {
                SAVED_NAME = "styles",
                SAVED_VERSION = 1,
                DEFAULTS = {
                    time = {
                        background = "Splash",
                        backgroundColour = {
                            r = 0.0823529412,
                            g = 0.0823529412,
                            b = 0.0823529412,
                            a = .5,
                        },
                        backgroundHoverColour = {
                            r = 0.3450980392,
                            g = 0.6470588235,
                            b = 0.7176470588,
                            a = .66,
                        },
                        backgroundOffset = {
                            x = 0,
                            y = 0,
                        },
                        format = "#A, #d #B #Y #X\n%A, %d %B %Y %X", -- "#A, #d #B #Y #X\n%A, %d %B %Y %X"
                        lineCount = 2, -- number of lines in format
                        colour = {
                            r = 0.7725490928,
                            g = 0.7607843876,
                            b = 0.6196078658,
                            a = 1.0,
                        },
                        font = "Univers 67",
                        style = "soft-shadow-thick",
                        size = 20,
                    },
                    moon = {
                        background = "Solid",
                        backgroundColour = {
                            r = .0,
                            g = .0,
                            b = 0.0823529412,
                            a = .5,
                        },
                        backgroundHoverColour = {
                            r = 0.3450980392,
                            g = 0.6470588235,
                            b = 0.7176470588,
                            a = .66,
                        },
                        masser = "Pale",
                        secunda = "Ghost",
                        alpha = 1.0,
                    },
                },
            },
            attributes = {
                SAVED_NAME = "attributes",
                SAVED_VERSION = 1,
                DEFAULTS = {
                    core = {
                        scaleFactor = 1.1,
                    },
                    time = {
                        anchor = {
                            point = 3, -- TOPLEFT
                            relativeTo = "GuiRoot",
                            relativePoint = nil,
                            offsetX = 90,
                            offsetY = 30,
                        },
                        dimension = {
                            width = 375,
                            height = 50,
                        },
                    },
                    moon = {
                        scale = 0.4,
                        anchor = {
                            point = 3, -- TOPLEFT
                            relativeTo = "GuiRoot",
                            relativePoint = nil,
                            offsetX = 34,
                            offsetY = 20,
                        },
                        dimension = {
                            width = 336,
                            height = 336,
                        },
                        masser = {
                            anchor = {
                                point = 3, -- TOPLEFT
                                relativeTo = "Clock_TST_Moon",
                                relativePoint = 3, -- TOPLEFT
                                offsetX = 0,
                                offsetY = 0,
                            },
                            dimension = {
                                width = 256,
                                height = 256,
                            },
                        },
                        secunda = {
                            anchor = {
                                point = 12, -- BOTTOMRIGHT
                                relativeTo = "Clock_TST_Moon",
                                relativePoint = 12, -- BOTTOMRIGHT
                                offsetX = 0,
                                offsetY = 0,
                            },
                            dimension = {
                                width = 160,
                                height = 160,
                            },
                        },
                    },
                },
            },
            presets = {
                SAVED_NAME = "presets",
                SAVED_VERSION = 1,
                DEFAULTS = {
                    saved = {
                        ["Default"] = {},
                        ["Map"] = {
                            booleans = {
                                core = {
                                    onlyShowOnMap = true,
                                    hideInFight = false,
                                },
                                time = {
                                    isMovable = false,
                                    hasFakeLoreDate = true,
                                },
                                moon = {
                                    isMovable = false,
                                    scaleWhenHover = false,
                                    highlightWhenHover = true,
                                },
                            },
                            styles = {
                                time = {
                                    format = "#A, #d #B #Y #H:#M -- %H:%M",
                                    lineCount = 1,
                                    size = 16,
                                },
                                moon = {
                                    background = "Brush",
                                    masser = "Crimson",
                                },
                            },
                            attributes = {
                                time = {
                                    dimension = {
                                        height = 40,
                                        width = 360,
                                    },
                                    anchor = {
                                        offsetY = 949,
                                        offsetX = 506.4999869211,
                                    },
                                },
                                moon = {
                                    scale = 0.3400000000,
                                    anchor = {
                                        offsetY = 910,
                                        offsetX = 469,
                                    },
                                },
                            },
                        },
                        ["Small"] = {
                            styles = {
                                time = {
                                    font = "Futura Condensed",
                                    format = "%H:%M:%S\n#H:#M:#S",
                                    lineCount = 1,
                                    size = 24,
                                    backgroundOffset = {
                                        y = 20,
                                    },
                                    colour =
                                    {
                                        r = 0,
                                        b = 0.9647058845,
                                        a = 0.8823529482,
                                        g = 1,
                                    },
                                },
                                moon = {
                                    backgroundColour = {
                                        a = 0.75,
                                    },
                                },
                            },
                            booleans = {
                                moon = {
                                    isMovable = false,
                                    highlightWhenHover = true,
                                    scaleWhenHover = false,
                                },
                                time = {
                                    highlightWhenHover = false,
                                    hasBackground = false,
                                    isMovable = false,
                                    hasFakeLoreDate = true,
                                    hasUSFormat = false,
                                    addZero = true,
                                },
                                core = {
                                    hideInGroup = true,
                                },
                            },
                            attributes = {
                                time =
                                {
                                    anchor =
                                    {
                                        offsetX = 1776.2143554688,
                                        offsetY = 17,
                                    },
                                    dimension =
                                    {
                                        width = 102.8571428571,
                                        height = 80,
                                    },
                                },
                                moon =
                                {
                                    scale = 0.3800000000,
                                    anchor =
                                    {
                                        offsetX = 1778.4240722656,
                                        offsetY = 8,
                                    },
                                    dimension =
                                    {
                                        height = 331,
                                    },
                                },
                            },
                        },
                    },
                }
            },
        },
    }
end
