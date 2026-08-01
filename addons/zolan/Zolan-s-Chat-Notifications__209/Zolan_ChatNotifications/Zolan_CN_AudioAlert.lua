--------------------------------------------------------------------------------
--                   Zolan's Chat Notification (Audio Alert)                  --
--------------------------------------------------------------------------------
local ZCN        = Zolan_CN
local AudioAlert = ZCN.AudioAlert

-- ZO
local PlaySound = PlaySound

function AudioAlert.alertForConfKey(confKey)
    ZCN.debug("AudioAlert -> alertForConfKey -> " .. confKey)

    if ZCN.savedVars.audio.enabled and ZCN.savedVars.audio[confKey].enabled  then
        ZCN.debug("+_ AudioAlert: Playing Sound.")
        PlaySound(ZCN.savedVars.audio[confKey].sound)
    end
end
