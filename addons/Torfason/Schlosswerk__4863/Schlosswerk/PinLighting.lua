local SW = Schlosswerk
local NORMAL_PIN_TEXTURE = "EsoUI/Art/Lockpicking/pins.dds"

function SW:GetLockpickObject()
    if ZO_LockpickPanel then
        return ZO_LockpickPanel.owner
    end
    return nil
end

function SW:ApplyPinLighting(lockpickObject)
    if not self.db then
        return
    end

    local lockpick = lockpickObject or self:GetLockpickObject()
    if not lockpick or not lockpick.springs then
        return
    end

    local lightsEnabled = self.db.pinLights == true
    for index = 1, NUM_LOCKPICK_CHAMBERS do
        local spring = lockpick.springs[index]
        local pin = spring and spring.pin
        if pin then
            if pin.highlight then
                pin.highlight:SetHidden(not lightsEnabled)
            end
            if not lightsEnabled then
                pin:SetTexture(NORMAL_PIN_TEXTURE)
            end
        end
    end
end

function SW:InstallPinLightingHooks()
    if self.pinHooksInstalled or not ZO_Lockpick or not SecurePostHook then
        return
    end

    self.pinHooksInstalled = true

    SecurePostHook(ZO_Lockpick, "ResetChambers", function(lockpick)
        SW:ApplyPinLighting(lockpick)
    end)

    SecurePostHook(ZO_Lockpick, "UpdatePinAlpha", function(lockpick)
        SW:ApplyPinLighting(lockpick)
    end)

    SecurePostHook(ZO_Lockpick, "EndDepressingPin", function(lockpick)
        SW:ApplyPinLighting(lockpick)
    end)

    SecurePostHook(ZO_Lockpick, "PlayHighlightOnPin", function(lockpick, pin)
        if SW.db and not SW.db.pinLights and pin and pin.highlight then
            pin.highlight:SetHidden(true)
        end
    end)
end
