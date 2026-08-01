
LeoGuildManager = LeoGuildManager or {}
LeoGuildManagerUI = LeoGuildManagerUI or {}

LeoGuildManager.name = "LeoGuildManager"
LeoGuildManager.displayName = "Leo's Guild Manager"
LeoGuildManager.version = "1.3.0"
LeoGuildManager.chatPrefix = "|c39B027" .. LeoGuildManager.name .. "|r: "

LeoGuildManager.TAB_PURGE = "Purge"

LeoGuildManager.panelList = {
    LeoGuildManager.TAB_PURGE
}
LeoGuildManager.color = {
    hex = {
        green = '10FF10',
        darkGreen = '21A121',
        white = 'FFFFFF',
        red = 'FF1010',
        darkRed = 'CB110E',
        yellow = 'FFFF00',
        orange = 'FFCC00',
        eso = 'E8DFAF',
    },
    rgba = {
        green = {0,1,0,1},
        white = {1,1,1,1},
        red = {1,0.25,0.12},
        yellow = {1,1,0,1},
        orange = {1,0.8,0,1},
    }
}

LeoGuildManager.MS_IN_MINUTE = 60 * 1000
LeoGuildManager.SECONDS_IN_HOUR = 60 * 60
LeoGuildManager.SECONDS_IN_DAY = LeoGuildManager.SECONDS_IN_HOUR * 24
LeoGuildManager.SECONDS_IN_WEEK = LeoGuildManager.SECONDS_IN_DAY * 7
LeoGuildManager.SECONDS_IN_MONTH = LeoGuildManager.SECONDS_IN_DAY * 30

LeoGuildManager.integrations = {
    "Master Merchant",
    "Arkadiu's Trade Tools",
}

LeoGuildManager.cycleMM = {
    {
        id = 3,
        name = "This week"
    },
    {
        id = 4,
        name = "Last week"
    },
    {
        id = 5,
        name = "Prior week"
    },
    {
        id = 8,
        name = "Last 7 days"
    },
    {
        id = 6,
        name = "Last 10 days"
    },
    {
        id = 7,
        name = "Last 30 days"
    }
}

LeoGuildManager.cycleATT = {
    {
        id = 3,
        name = "This week"
    },
    {
        id = 4,
        name = "Last week"
    },
    {
        id = 5,
        name = "Prior week"
    },
    {
        id = 8,
        name = "Last 7 days"
    },
    {
        id = 6,
        name = "Last 10 days"
    },
    {
        id = 14,
        name = "Last 14 days"
    },
    {
        id = 7,
        name = "Last 30 days"
    }
}
