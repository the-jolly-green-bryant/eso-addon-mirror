TamrielicTongues = TamrielicTongues or {}

local TT = TamrielicTongues

TT.ADDON_NAME = "TamrielicTongues"
TT.DISPLAY_NAME = "Tamrielic Tongues"
TT.VERSION = "1.5.0"
TT.SAVED_VARIABLES_NAME = "TamrielicTonguesSavedVariables"
TT.SAVED_VARIABLES_VERSION = 1
TT.API_VERSION = 101050

TT.LanguageData = TT.LanguageData or {}

function TT:Print(message)
    local prefix = "|cD8B56A" .. self.DISPLAY_NAME .. "|r"
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(string.format("%s: %s", prefix, tostring(message)))
    elseif d then
        d(string.format("%s: %s", self.DISPLAY_NAME, tostring(message)))
    end
end
