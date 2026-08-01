StealthMod = {}

function StealthMod.removeText(eventCode, unitTag, stealthState)
    if unitTag == "player" then
        WINDOW_MANAGER:GetControlByName("ZO_ReticleContainerStealthIconStealthText"):SetText("")
    end
end

function StealthMod.init(eventCode)
    StealthMod.removeText(eventCode, "player", GetUnitStealthState("player"))
end

EVENT_MANAGER:RegisterForEvent("StealthMod", EVENT_STEALTH_STATE_CHANGED, StealthMod.removeText)
EVENT_MANAGER:RegisterForEvent("StealthMod", EVENT_RETICLE_HIDDEN_UPDATE, StealthMod.init)
EVENT_MANAGER:RegisterForEvent("StealthMod", EVENT_RETICLE_TARGET_CHANGED, StealthMod.init)