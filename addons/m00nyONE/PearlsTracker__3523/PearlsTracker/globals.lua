PearlsTracker = PearlsTracker or {}
local PT = PearlsTracker
PT.log = {} -- for use wth LibLogger
PT.SV = {}

PT.name = "PearlsTracker"
PT.version = "1.1.0"
PT.author = "|c76c3f4@m00nyONE|r"

PT.PEARLS_PROC_PERCENTAGE = 50
PT.PEARLS_ABILITY_ID = 147462
PT.PEARLS_EQUIP_ID = 147459
PT.PEARLS_ITEM_LINK = "|H0:item:171437:364:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:0:0|h|h"

PT.isEquipped = false
PT.isHidden = true

PT.savedVariableTable = "PearlsTrackerStore"
PT.variableVersion = 1
PT.defaultVariables = {
    enabled = true,
    updateInterval = 500,
    ResetUltiGainOnEnterCombat = true,
    panel = {
        hide = false,
        posX = 500,
        posY = 500,
    },
    icon = {
        hide = false,
        size = 48,
        opacity = 100,
    },
    background = {
        hide = false,
        opacity = 50,
        outline = true,
        outlineWidth = 4,
    },
    resource = {
        hide = false,
        fontSize = 40,
    },
    ultiGain = {
        hide = false,
        fontSize = 30,
    },
    colors	= {
        aboveThreshold = {
            1, 0, 0, 1
        },
        belowThreshold = {
            0, 1, 0, 1
        },
        ultiGain = {
            1, 1, 0, 1
        }
    },
}