GroupHistory = {
    NAME = "GroupHistory",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260710-0001",
    CHAT = "[GH]",
    SLASH = "/grouphistory",

    GroupMember = {},
    groupSize = 1,
    OfflineMember = {},

    playSoundCounter = 0,
    wasSoundPlayed = false,

    timeDiffChange = 0,
    TIME_DIFF_CHANGE_MIN = 250,

    Default = {
        isEnabled = true,
        isDebug = false,

        isVeteranDifficulty = false,

        enablePrefix = false,
        enableTimestamp = false,
        enableCharacterName = false,

        enableRoleChange = true,
        enableDifficultyChange = true,
        enableLeaderChange = true,
        enableOffline = true,

        enablePlaySound4 = false,
        enablePlaySound12 = true,

        RoleCol = {
            [0] = "|cFF0000",
            [1] = "|c007FFF",
            [2] = "|cFF7FFF",
            [3] = "|cFFFF00",
            [4] = "|c7FFF7F"
        }
    },

    Col = {
        OG = "|cFF7F00",
        WH = "|cFFFFFF",
        GN = "|c00FF00",
        RD = "|cFF0000",
        BU = "|c7FFFFF",
        End = "|r"
    },

    RoleMap = {
        [0] = "[Offline]",
        [1] = "[DPS]",
        [2] = "[Tank]",
        [3] = "[Unknown]",
        [4] = "[Heal]"
    },

    ReasonMap = {
        GROUP_LEAVE_REASON_MIN_VALUE = 0,
        GROUP_LEAVE_REASON_ITERATION_BEGIN = 0,
        GROUP_LEAVE_REASON_VOLUNTARY = 0,
        GROUP_LEAVE_REASON_KICKED = 1,
        GROUP_LEAVE_REASON_DISBAND = 2,
        GROUP_LEAVE_REASON_DESTROYED = 3,
        GROUP_LEAVE_REASON_LEFT_BATTLEGROUND = 4,
        GROUP_LEAVE_REASON_ITERATION_END = 4,
        GROUP_LEAVE_REASON_MAX_VALUE = 4,
    },

    SV = {},
    SVVersion = 1,
    SVName = "GroupHistoryVariables",

    varAddonPanel = nil,
    isLoaded = false
}