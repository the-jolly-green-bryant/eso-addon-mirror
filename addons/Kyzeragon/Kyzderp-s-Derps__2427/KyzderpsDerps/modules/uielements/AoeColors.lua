KyzderpsDerps = KyzderpsDerps or {}

local r, g, b = 0 -- avoid setting the color when not needed

local function SetRGB(red, green, blue)
    if (r ~= red or g ~= green or b ~= blue) then
        r = red
        g = green
        b = blue
        KyzderpsDerps:dbg(string.format("|cAAAAAASetting AOE Color: |c%02x%02x%02x%02x%02x%02x|r", red, green, blue, red, green, blue))
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, string.format("%02x%02x%02x", red, green, blue))
    end
end

local function OnBossesChanged()
    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitName("boss" .. tostring(i))
        if (name == "Lokkestiiz" or name == "洛克提兹" or name == "ロクケスティーズ"
            or name == "Pinnacle Factotum" or name == "巅峰机械人" or name == "ピナクル・ファクトタム" or name == "Perfektioniertes Faktotum") then
            SetRGB(200, 0, 255)
            return
        end
    end
    SetRGB(0, 255, 255)
end

function KyzderpsDerps.InitializeAOE()
    if (KyzderpsDerps.savedOptions.ui.aoeColors) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AoeColors", EVENT_BOSSES_CHANGED, OnBossesChanged)
    else
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AoeColors", EVENT_BOSSES_CHANGED)
    end
end

-- Settings in Reposition.lua
