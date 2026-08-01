AutoLootToggler = {}

local lastDetectedBosses = {}
local lastDetectionTime = 0
local detectionCooldown = 3000

local function NormalizeName(name)
    return name and name:lower():gsub("%^%a+", "") or ""
end

local function DisableAutoLootIfNeeded()
    local current = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
    if current == "1" then
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "0")
        d("[AutoLootToggler] Auto Loot DISABLED due to boss detection.")
    end
end

local function CheckBossName()
    local now = GetGameTimeMilliseconds()
    if now - lastDetectionTime < detectionCooldown then
        return
    end

    lastDetectionTime = now

    for i = 1, 6 do
        local bossTag = "boss" .. i
        if DoesUnitExist(bossTag) then
            local name = GetUnitName(bossTag)
            if name and name ~= "" then
                local normalizedName = NormalizeName(name)
                if not lastDetectedBosses[normalizedName] then
                    -- d(string.format("[AutoLootToggler] Boss Detected: %s (key: %s)", name, normalizedName))
                    lastDetectedBosses[normalizedName] = true
                    DisableAutoLootIfNeeded()
                end
            end
        end
    end
end


local function OnBossesChanged(eventCode)
    CheckBossName()
end

local function ResetBossDetection()
    lastDetectedBosses = {}
    lastDetectionTime = 0
end

local function ToggleAutoLoot()
    local current = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
    local newValue = (current == "1") and "0" or "1"
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, newValue)

    local status = (newValue == "1") and "ENABLED" or "DISABLED"
    d("[AutoLootToggler] Auto Loot is now " .. status)
end

AutoLootToggler.Toggle = ToggleAutoLoot

local function RegisterKeybinds()
    ZO_CreateStringId("SI_BINDING_NAME_AUTOLOOTTOGGLER_KEYBIND", "Toggle Auto Loot")
    ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_AUTOLOOTTOGGLER", "Toggle Auto Loot")
end

local function OnAddonLoaded(event, addonName)
    if addonName == "AutoLootToggler" then
        EVENT_MANAGER:UnregisterForEvent("AutoLootToggler", EVENT_ADD_ON_LOADED)

        EVENT_MANAGER:RegisterForEvent("AutoLootToggler", EVENT_BOSSES_CHANGED, OnBossesChanged)

        EVENT_MANAGER:RegisterForEvent("AutoLootToggler", EVENT_PLAYER_COMBAT_STATE, ResetBossDetection)
        EVENT_MANAGER:RegisterForEvent("AutoLootToggler", EVENT_PLAYER_ACTIVATED, ResetBossDetection)

        RegisterKeybinds()
    end
end

EVENT_MANAGER:RegisterForEvent("AutoLootToggler", EVENT_ADD_ON_LOADED, OnAddonLoaded)
