
--[[
    BlockPooky Combat Visuals Module
    
    This module provides advanced UI controls and logic for customizing combat visuals in ESO:
    - Adjust maximum AOE brightness, outline thickness, and target outline intensity
    - Enable RGB color cycling for AOE indicators (with speed and turbo controls)
    - Integrates with BlockPooky settings and menu system
    - All settings are persistent and applied on startup if enabled
]]

BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky
local EM = GetEventManager()
local format = string.format
local min = math.min
local max = math.max

--[[ combat visuals settings ----------------------------------------------------------------------------------------]]
local aoeDefault = 50
local aoeFactor  = 10
local outlineDefault = 100
local outlineFactor  = 20

---Set the maximum AOE brightness for friendly/enemy monster tells
---@param maxValue number Maximum brightness value to set
function BlockPooky.SetMaxAOEBrightness(maxValue)
    local brightness = maxValue or (aoeDefault * aoeFactor)
    if ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS] then
        ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS].maxValue = brightness
    end
    if ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS] then
        ZO_SharedOptions_SettingsData[SETTING_PANEL_GAMEPLAY][SETTING_TYPE_COMBAT][COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS].maxValue = brightness
    end
end

---Reset AOE brightness to default value
function BlockPooky.ResetMaxAOEBrightness()
    BlockPooky.SetMaxAOEBrightness(aoeDefault * aoeFactor)
end

---Set the maximum outline thickness for nameplate glow
---@param maxValue number Maximum outline thickness value to set
function BlockPooky.SetMaxOutlineThickness(maxValue)
    local thickness = maxValue or outlineDefault * outlineFactor
    if ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_GLOW_THICKNESS] then
        ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_GLOW_THICKNESS].showValueMax = thickness
        ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_GLOW_THICKNESS].maxValue = outlineFactor
    end
end

---Reset outline thickness to default value
function BlockPooky.ResetMaxOutlineThickness()
    BlockPooky.SetMaxOutlineThickness(outlineDefault * outlineFactor)
end

---Set the maximum target outline intensity for nameplate glow
---@param maxValue number Maximum target outline intensity value to set
function BlockPooky.SetMaxTargetOutlineIntensity(maxValue)
    local intensity = maxValue or outlineDefault * outlineFactor
    if ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY] then
        ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY].showValueMax = intensity
        ZO_SharedOptions_SettingsData[SETTING_PANEL_NAMEPLATES][SETTING_TYPE_IN_WORLD][IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY].maxValue = outlineFactor
    end
end

---Reset target outline intensity to default value
function BlockPooky.ResetMaxTargetOutlineIntensity()
    BlockPooky.SetMaxTargetOutlineIntensity(outlineDefault * outlineFactor)
end


-- RGB cycling state
BlockPooky.rgbRed = 255
BlockPooky.rgbGreen = 0
BlockPooky.rgbBlue = 0
BlockPooky.rgbCycleActive = false

---Cycle the AOE color through the RGB spectrum for visual effect
---Uses current turbo and speed settings from config
function BlockPooky.CycleAOEColor()
    local turbo = BlockPooky.config.AOERGBTurbo or 1
    local red = BlockPooky.rgbRed
    local green = BlockPooky.rgbGreen
    local blue = BlockPooky.rgbBlue
    if ( red == 255 ) and ( green < 255) and ( blue == 0 ) then
        green = min((green + (5*turbo)), 255)
    elseif ( red > 0 ) and ( green == 255) and ( blue == 0 ) then
        red = max((red - (5*turbo)), 0)
    elseif ( red == 0 ) and ( green == 255 ) and ( blue < 255 ) then
        blue = min((blue + (5*turbo)), 255)
    elseif ( red == 0 ) and ( green > 0 ) and ( blue == 255 ) then
        green = max((green - (5*turbo)), 0)
    elseif ( red < 255 ) and ( green == 0 ) and ( blue == 255 ) then
        red = min((red + (5*turbo)), 255)
    elseif (red == 255 ) and ( green == 0 ) and ( blue > 0 ) then
        blue = max((blue - (5*turbo)), 0)
    end
    BlockPooky.rgbRed = red
    BlockPooky.rgbGreen = green
    BlockPooky.rgbBlue = blue
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, format("%02x%02x%02x", red, green, blue))
end

---Enable or disable RGB AOE color cycling
---@param state boolean True to enable, false to disable
---@param showMsg boolean True to show chat message on toggle
function BlockPooky.SetAOERGBState(state, showMsg)
    if state then
        if showMsg then d("BlockPooky RGB AOE Enabled") end
        EM:RegisterForUpdate(BlockPooky.name.."AOECycle", BlockPooky.config.AOERGBSpeed or 50, function() BlockPooky.CycleAOEColor() end)
        BlockPooky.rgbCycleActive = true
    else
        if showMsg then d("BlockPooky RGB AOE Disabled") end
        EM:UnregisterForUpdate(BlockPooky.name.."AOECycle")
        BlockPooky.rgbCycleActive = false
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, BlockPooky.config.AOERGBDefaultColor or format("%02x%02x%02x", 255, 0, 0))
    end
end

---Toggle RGB AOE color cycling on/off and update config
function BlockPooky.ToggleAOERGB()
    BlockPooky.config.AOERGBEnabled = not BlockPooky.config.AOERGBEnabled
    BlockPooky.SetAOERGBState(BlockPooky.config.AOERGBEnabled, true)
end


---Register slash command for toggling RGB AOE cycling
SLASH_COMMANDS["/blockpookyrgb"] = function() BlockPooky.ToggleAOERGB() end