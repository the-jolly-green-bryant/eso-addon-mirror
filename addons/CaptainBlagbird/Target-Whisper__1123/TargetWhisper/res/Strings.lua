--[[

Target Whisper
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

local strings = {
    -- General
    TARGETWHISPER_SLASH_CMD = "/targetwhisper",
    -- Bindings
    TARGETWHISPER_BINDING_CATEGORY_TITLE           = "|c70C0DETarget Whisper|r",
    SI_BINDING_NAME_TARGETWHISPER_START_DIRECT     = "Start Chat To Targeted Player |c777777- Only opens chat if a player is targeted.|r",
    SI_BINDING_NAME_TARGETWHISPER_START            = "Start Chat (To Targeted Player) |c777777- As the previous option, but also opens normal chat when no player is targeted.|r",
    SI_BINDING_NAME_TARGETWHISPER_START_LAST       = "Start Chat (To Last Targeted Player) |c777777- Opens chat to last targeted player (or normal chat if no one has been targeted yet).|r",
    SI_BINDING_NAME_TARGETWHISPER_START_LAST_ENEMY = "Start Chat (To Last Targeted Enemy Player) |c777777- As the previous option, but only for enemies.|r",
    -- Messages
    TARGETWHISPER_MSG_INVALID_INPUT = "Invalid input",
    TARGETWHISPER_MSG_USAGE         = "Usage: "..GetString(TARGETWHISPER_SLASH_CMD).." N\nN=0: Timeout off\nN>0: Timeout after N seconds",
    TARGETWHISPER_MSG_CURRENT_TIME  = "Current timeout: ",
    TARGETWHISPER_MSG_SET_TO        = "Timeout set to ",
    TARGETWHISPER_MSG_SECONDS       = " second(s)",
    TARGETWHISPER_MSG_TIME_OFF      = "Timeout off",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end