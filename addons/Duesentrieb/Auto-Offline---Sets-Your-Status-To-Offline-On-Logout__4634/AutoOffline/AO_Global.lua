AutoOffline = {
    NAME = "AutoOffline",
    AUTHOR = "@Duesentrieb",
    VERSION = "20260624-0001",
    CHAT = "|cFF7F00[Auto Offline]|r",

    isLoaded = false,
    isHooked = false,
    isLogin = false,

    default = {
        enableAddon = true,
        enableOnLogout = true,
        delayPromt = 15000,

        promptFrequency = "Once Per Hour On Login",
        lastPromptTime = 0,
        lastPromptDate = "",
    },

    SV = {},
    SVVersion = 1,
    SVName = "AutoOfflineVariables",
}