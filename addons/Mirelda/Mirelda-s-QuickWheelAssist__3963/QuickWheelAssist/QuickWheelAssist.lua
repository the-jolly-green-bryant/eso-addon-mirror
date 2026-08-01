
local addon = { name = "QuickWheelAssist" }

local slotNum = ACTION_BAR_UTILITY_BAR_SIZE + 1
local cancelText = GetString(SI_CANCEL)

local function getPlatformIcon()
    return IsInGamepadPreferredMode() and "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds"
        or "EsoUI/Art/HUD/radialIcon_cancel_up.dds"
end

function addon:Initialize()
    SetCVar("AccessibleQuickwheels", "1")
    
    SecurePostHook(ZO_UtilityWheel_Shared, 'PopulateMenu', function(self)
        local icon = getPlatformIcon()
        self.menu:AddEntry(cancelText, icon, icon, function() end, { slotNum = slotNum })
    end)

    SecurePostHook(ZO_TargetMarkerWheel_Shared, 'PopulateMenu', function(self)
        local iconPath = getPlatformIcon()
        self.menu:AddEntry("", iconPath, iconPath, function() end, #self.menu.entries + 1)
    end)
end

local function OnAddonLoaded(event, addonName)
    if addonName == addon.name then
        addon:Initialize()
        EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
