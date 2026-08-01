StealthText = {}

function StealthText.removeText(eventCode, unitTag, stealthState)
    if unitTag == "player" then
        WINDOW_MANAGER:GetControlByName("ZO_ReticleContainerStealthIconStealthText"):SetText("")
    end
end

function StealthText.init(eventCode)
    StealthText.removeText(eventCode, "player", GetUnitStealthState("player"))
end

EVENT_MANAGER:RegisterForEvent("StealthText", EVENT_STEALTH_STATE_CHANGED, StealthText.removeText)
EVENT_MANAGER:RegisterForEvent("StealthText", EVENT_RETICLE_HIDDEN_UPDATE, StealthText.init)
EVENT_MANAGER:RegisterForEvent("StealthText", EVENT_RETICLE_TARGET_CHANGED, StealthText.init)