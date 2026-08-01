local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}

-- returns the current game colors
function AOEHelper.GetGameColors()
    return {
        enemyColor = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR):sub(3,8),
        enemyBrightness = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS),
        friendlyColor = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR):sub(3,8),
        friendlyBrightness = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS),
    }
end

-- apply the colors to the game settings
--[[
    color = {
        enemyColor: string | nil
        enemyBrightness: number | nil
        friendlyColor: string | nil
        friendlyBrightness: number | nil
    }
]]--
function AOEHelper.SetGameColors(colors)
    if type(colors) ~= "table" then d("argument is not a table") return end

    if colors.enemyColor ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, colors.enemyColor)
    end
    if colors.enemyBrightness ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, colors.enemyBrightness)
    end
    if colors.friendlyColor ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, colors.friendlyColor)
    end
    if colors.friendlyBrightness ~= nil then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, colors.friendlyBrightness)
    end
end

function AOEHelper.SetDefaultColors(colors)
    if type(colors) ~= "table" then d("argument is not a table") return end

    if colors.enemyColor ~= nil then
        AOEHelper.savedVariables.defaultColors.enemyColor = colors.enemyColor
    end
    if colors.enemyBrightness ~= nil then
        AOEHelper.savedVariables.defaultColors.enemyBrightness = colors.enemyBrightness
    end
    if colors.friendlyColor ~= nil then
        AOEHelper.savedVariables.defaultColors.friendlyColor = colors.friendlyColor
    end
    if colors.friendlyBrightness ~= nil then
        AOEHelper.savedVariables.defaultColors.friendlyBrightness = colors.friendlyBrightness
    end
end

function AOEHelper.LoadDefaultColors()
    local colors = AOEHelper.savedVariables.defaultColors
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, colors.enemyColor)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, colors.enemyBrightness)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, colors.friendlyColor)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, colors.friendlyBrightness)
end

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)