if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

-------------------------------------------------------------------------
--- Whisper Handler
-------------------------------------------------------------------------

function PUG:whisperHandler(channel, fromName, msg, isCustomerService, name)
    if PUG.SV.confirmWhisper then
        PUG.alertBox.confirm = true
        PUG.alertBox.pause = false
        PUG.alertBox.delay = 0
        PUGmoAlertBoxWindowConfirm:SetHidden(false)

    else
        PUG.alertBox.confirm = false
        PUG.alertBox.pause = true
        PUGmoAlertBoxWindowConfirm:SetHidden(true)

    end
    PUG.data.button = nil
    PUG:markPlayer(name)
    PUG:addAlert("\nWhisper from:\n|cff00ff|l1:1:1:4:5:FFAA33|l" .. name .. "|l|r\n\n" .. msg .. "\n", "/esoui/art/hud/radialicon_whisper_over.dds", PUG.SV.alertTime.whisper)
    --PUG:msgToChat("", CHAT_CHANNEL_WHISPER, name)
end

