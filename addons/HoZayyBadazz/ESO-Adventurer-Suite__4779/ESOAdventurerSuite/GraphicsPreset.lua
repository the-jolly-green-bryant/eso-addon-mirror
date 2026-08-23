-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Native ESO cinematic graphics preset helper.
-- This only changes settings exposed by ESO's own graphics API; it does not
-- install shaders, textures, ray tracing, ReShade, or other external rendering.

local EPC = ESOProgressionCoach
EPC.GraphicsPreset = EPC.GraphicsPreset or {}
local G = EPC.GraphicsPreset

local function graphicSetting(name)
    return _G[name]
end

local function valueOf(...)
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local value = _G[name]
        if value ~= nil then return value end
    end
    return nil
end

-- Explicit maximum-quality overrides layered on top of ESO's Maximum preset.
-- Each entry is guarded so the addon remains compatible if a setting is not
-- available on a particular client/platform.
local SETTING_SPECS = {
    { key = "preset", setting = "GRAPHICS_SETTING_PRESETS", target = function()
        return valueOf("GRAPHICS_PRESETS_MAXIMUM", "GRAPHICS_PRESETS_ULTRA")
    end },
    { key = "textureResolution", setting = "GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS", target = function()
        return valueOf("TEX_RES_CHOICE_HIGH")
    end },
    { key = "subSampling", setting = "GRAPHICS_SETTING_SUB_SAMPLING", target = function()
        return valueOf("SUB_SAMPLING_MODE_NORMAL")
    end },
    { key = "shadows", setting = "GRAPHICS_SETTING_SHADOWS", target = function()
        return valueOf("SHADOWS_CHOICE_ULTRA", "SHADOWS_CHOICE_HIGH")
    end },
    { key = "screenWater", setting = "GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY", target = function()
        return valueOf("SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA", "SCREENSPACE_WATER_REFLECTION_QUALITY_HIGH")
    end },
    { key = "planarWater", setting = "GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY", target = function()
        return valueOf("PLANAR_WATER_REFLECTION_QUALITY_HIGH", "PLANAR_WATER_REFLECTION_QUALITY_MEDIUM")
    end },
    { key = "maxParticles", setting = "GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM", target = function() return "2048" end },
    { key = "particleDistance", setting = "GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE", target = function() return "100" end },
    { key = "viewDistance", setting = "GRAPHICS_SETTING_VIEW_DISTANCE", target = function() return "2.0" end },
    { key = "ambientOcclusion", setting = "GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE", target = function()
        return valueOf("AMBIENT_OCCLUSION_TYPE_SSGI", "AMBIENT_OCCLUSION_TYPE_LSAO", "AMBIENT_OCCLUSION_TYPE_HBAO", "AMBIENT_OCCLUSION_TYPE_SSAO")
    end },
    { key = "clutter", setting = "GRAPHICS_SETTING_CLUTTER_2D_QUALITY", target = function()
        return valueOf("CLUTTER_QUALITY_ULTRA", "CLUTTER_QUALITY_HIGH")
    end },
    { key = "depthOfField", setting = "GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE", target = function()
        return valueOf("DEPTH_OF_FIELD_MODE_CIRCULAR", "DEPTH_OF_FIELD_MODE_SMOOTH")
    end },
    { key = "characterResolution", setting = "GRAPHICS_SETTING_CHARACTER_RESOLUTION", target = function()
        return valueOf("CHARACTER_RESOLUTION_ULTRA", "CHARACTER_RESOLUTION_HIGH")
    end },
    { key = "bloom", setting = "GRAPHICS_SETTING_BLOOM", target = function() return "1" end },
    { key = "distortion", setting = "GRAPHICS_SETTING_DISTORTION", target = function() return "1" end },
    { key = "godRays", setting = "GRAPHICS_SETTING_GOD_RAYS", target = function() return "1" end },
}

local function canUseGraphicsAPI()
    return type(SetSetting) == "function" and type(GetSetting) == "function" and SETTING_TYPE_GRAPHICS ~= nil
end

local function safeGet(settingId)
    if settingId == nil or not canUseGraphicsAPI() then return nil end
    local ok, value = pcall(GetSetting, SETTING_TYPE_GRAPHICS, settingId)
    if ok then return value end
    return nil
end

local function safeSet(settingId, value)
    if settingId == nil or value == nil or not canUseGraphicsAPI() then return false end
    local ok = pcall(SetSetting, SETTING_TYPE_GRAPHICS, settingId, tostring(value))
    return ok == true
end

function G:IsSupported()
    if not canUseGraphicsAPI() then return false end
    if type(ZO_IsPCUI) == "function" and not ZO_IsPCUI() then return false end
    return true
end

function G:CaptureBackup()
    if not EPC.saved then return end
    local current = EPC.saved.cinematicGraphicsBackup
    if type(current) == "table" and next(current) ~= nil then return end

    local backup = {}
    for _, spec in ipairs(SETTING_SPECS) do
        local settingId = graphicSetting(spec.setting)
        local value = safeGet(settingId)
        if value ~= nil then backup[spec.key] = tostring(value) end
    end
    EPC.saved.cinematicGraphicsBackup = backup
end

function G:ApplyCinematicMaximum(showMessage)
    if not EPC.saved then return false end
    if not self:IsSupported() then
        if showMessage ~= false and EPC.Print then EPC:Print("Cinematic graphics is available only when ESO exposes the PC graphics settings API.") end
        return false
    end
    if type(IsMinSpecMachine) == "function" and IsMinSpecMachine() then
        if showMessage ~= false and EPC.Print then EPC:Print("ESO reports this system as minimum-spec, so Cinematic Maximum was not forced.") end
        return false
    end

    self:CaptureBackup()

    local changed = 0
    -- Apply ESO's own Maximum preset first, then make the cinematic overrides explicit.
    for _, spec in ipairs(SETTING_SPECS) do
        local settingId = graphicSetting(spec.setting)
        local target = spec.target and spec.target() or nil
        if settingId ~= nil and target ~= nil and safeSet(settingId, target) then
            changed = changed + 1
        end
    end

    if type(ApplySettings) == "function" then pcall(ApplySettings) end
    EPC.saved.cinematicGraphicsEnabled = changed > 0

    if showMessage ~= false and EPC.Print then
        if changed > 0 then
            EPC:Print("Cinematic Maximum applied using ESO's native graphics settings. This is demanding; some video changes may finish applying after /reloadui or a game restart.")
        else
            EPC:Print("No supported cinematic graphics settings were changed on this client.")
        end
    end
    return changed > 0
end

function G:RestorePrevious(showMessage)
    if not EPC.saved then return false end
    local backup = EPC.saved.cinematicGraphicsBackup
    if type(backup) ~= "table" or next(backup) == nil then
        EPC.saved.cinematicGraphicsEnabled = false
        if showMessage ~= false and EPC.Print then EPC:Print("No pre-cinematic graphics backup is available to restore.") end
        return false
    end

    local restored = 0
    for _, spec in ipairs(SETTING_SPECS) do
        local settingId = graphicSetting(spec.setting)
        local oldValue = backup[spec.key]
        if settingId ~= nil and oldValue ~= nil and safeSet(settingId, oldValue) then
            restored = restored + 1
        end
    end
    if type(ApplySettings) == "function" then pcall(ApplySettings) end

    EPC.saved.cinematicGraphicsEnabled = false
    EPC.saved.cinematicGraphicsBackup = {}

    if showMessage ~= false and EPC.Print then
        EPC:Print(restored > 0 and "Previous ESO graphics settings restored." or "No graphics settings could be restored on this client.")
    end
    return restored > 0
end

function G:SetEnabled(enabled)
    if enabled == true then
        return self:ApplyCinematicMaximum(true)
    end
    return self:RestorePrevious(true)
end
