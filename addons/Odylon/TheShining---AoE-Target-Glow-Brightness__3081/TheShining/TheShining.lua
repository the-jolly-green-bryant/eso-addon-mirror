local aoeDefault = 50
local aoeFactor  = 10
ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS].maxValue = aoeDefault * aoeFactor
ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS].maxValue = aoeDefault * aoeFactor

local outlineDefault = 100
local outlineFactor  = 20
ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_GLOW_THICKNESS].showValueMax = outlineDefault * outlineFactor
ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_GLOW_THICKNESS].maxValue = outlineFactor
ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY].showValueMax = outlineDefault * outlineFactor
ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY].maxValue = outlineFactor
