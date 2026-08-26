-- Pure display helpers. No ESO controls. Combat sustain is 100 Ultimate
-- every 10 seconds while transformed (Update 50); out of combat is free.

ValknarrThemeFormat = ValknarrThemeFormat or {}

local Format = ValknarrThemeFormat

Format.THEME_DEFAULT = "default"
Format.THEME_CLEAN = "clean"
Format.THEME_NORDIC = "nordic"
Format.THEME_STEEL = "steel"
Format.THEME_BRONZE = "bronze"
Format.THEME_METAL = "nordic"
Format.THEME_VALKNARR = "clean"

Format.WOLF_VANILLA = "vanilla"
Format.WOLF_CLEAN = "clean"
Format.WOLF_NORDIC = "nordic"
Format.WOLF_STEEL = "steel"
Format.WOLF_BRONZE = "bronze"
Format.WOLF_1 = "nordic"
Format.WOLF_2 = "steel"
Format.WOLF_3 = "bronze"
Format.WOLF_4 = "nordic"
Format.WOLF_METAL = "nordic"

Format.ULTIMATE_TICK = 100
Format.TICK_SECONDS = 10
Format.RING_SEGMENTS = 12

-- Muted fills so the paint reads as iron / steel / bronze, not neon.
Format.FILLS = {
    clean = {
        health = { 0.56, 0.20, 0.18, 0.94 },
        magicka = { 0.24, 0.38, 0.58, 0.94 },
        stamina = { 0.24, 0.46, 0.30, 0.94 },
        fury = { 0.52, 0.16, 0.14, 0.94 },
        ult = { 0.70, 0.56, 0.24, 0.94 },
    },
    nordic = {
        health = { 0.46, 0.16, 0.14, 0.92 },
        magicka = { 0.22, 0.30, 0.42, 0.92 },
        stamina = { 0.22, 0.36, 0.24, 0.92 },
        fury = { 0.52, 0.12, 0.10, 0.94 },
        ult = { 0.64, 0.48, 0.20, 0.92 },
    },
    steel = {
        health = { 0.48, 0.20, 0.22, 0.90 },
        magicka = { 0.28, 0.38, 0.48, 0.90 },
        stamina = { 0.26, 0.40, 0.34, 0.90 },
        fury = { 0.50, 0.12, 0.11, 0.94 },
        ult = { 0.68, 0.64, 0.46, 0.90 },
    },
    bronze = {
        health = { 0.50, 0.22, 0.14, 0.92 },
        magicka = { 0.26, 0.34, 0.40, 0.92 },
        stamina = { 0.32, 0.40, 0.22, 0.92 },
        fury = { 0.52, 0.11, 0.08, 0.94 },
        ult = { 0.66, 0.46, 0.16, 0.92 },
    },
}

-- Gamepad faces only. Book fonts exist on console but are unreadably small,
-- and SetFont succeeds on the first name so they stole the size.
Format.HUD_FONTS = {
    "ZoFontGamepad27",
    "ZoFontGamepad25",
    "ZoFontGameShadow",
}
Format.HUD_FONTS_THIN = {
    "ZoFontGamepad22",
    "ZoFontGamepad25",
    "ZoFontGamepad27",
    "ZoFontGameShadow",
}

function Format.HudFonts(themeId, wellH)
    local id = Format.NormalizeThemeId(themeId)
    local thin = (wellH and wellH < 32) or id == Format.THEME_STEEL or id == Format.THEME_BRONZE
    if thin then
        return Format.HUD_FONTS_THIN
    end
    return Format.HUD_FONTS
end

function Format.Fill(skinId, key)
    local id = "clean"
    if Format.ResourcesMetal(skinId) then
        id = Format.NormalizeThemeId(skinId)
    elseif Format.WolfMetal(skinId) then
        id = Format.NormalizeWolfId(skinId)
    end
    local pack = Format.FILLS[id] or Format.FILLS.clean
    return pack[key] or Format.FILLS.clean[key]
end

function Format.NormalizeThemeId(value)
    if value == "valknarr" or value == Format.THEME_CLEAN then
        return Format.THEME_CLEAN
    end
    if value == "nordic" or value == "metal" or value == "metal1" or value == "a" then
        return Format.THEME_NORDIC
    end
    if value == "steel" or value == "metal2" or value == "b" then
        return Format.THEME_STEEL
    end
    if value == "bronze" or value == "metal3" or value == "metal4" or value == "c" then
        return Format.THEME_BRONZE
    end
    return Format.THEME_DEFAULT
end

function Format.NormalizeWolfId(value)
    if value == "valknarr" or value == Format.WOLF_CLEAN then
        return Format.WOLF_CLEAN
    end
    if value == "nordic" or value == "wolf1" or value == "a" then
        return Format.WOLF_NORDIC
    end
    if value == "steel" or value == "wolf2" or value == "metal2" or value == "b" then
        return Format.WOLF_STEEL
    end
    if value == "bronze" or value == "wolf3" or value == "metal3" or value == "c" then
        return Format.WOLF_BRONZE
    end
    if value == "wolf4" or value == "metal" or value == "metal1" then
        return Format.WOLF_NORDIC
    end
    return Format.WOLF_VANILLA
end

function Format.CurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end
    if type(SCENE_MANAGER.GetCurrentSceneName) == "function" then
        local ok, name = pcall(SCENE_MANAGER.GetCurrentSceneName, SCENE_MANAGER)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    local scene = SCENE_MANAGER.currentScene
    if type(scene) == "table" then
        if type(scene.GetName) == "function" then
            local ok, name = pcall(scene.GetName, scene)
            if ok and type(name) == "string" and name ~= "" then
                return name
            end
        end
        if type(scene.name) == "string" and scene.name ~= "" then
            return scene.name
        end
    end
    return nil
end

function Format.PreviewInSettings()
    local store = _G.ValknarrThemeStore
    if not store or type(store.GetSetting) ~= "function" then
        return true
    end
    return store:GetSetting("previewInSettings") ~= false
end

function Format.IsSettingsScene(name)
    if type(name) ~= "string" or name == "" then
        return false
    end
    local lower = string.lower(name)
    if string.find(lower, "map", 1, true) then
        return false
    end
    return string.find(lower, "option", 1, true) ~= nil
        or string.find(lower, "addon", 1, true) ~= nil
        or string.find(lower, "harven", 1, true) ~= nil
        or string.find(lower, "settings", 1, true) ~= nil
        or string.find(lower, "votan", 1, true) ~= nil
end

-- Follow native attribute bars: visible on hud / hudui and in /uiedit,
-- hidden on map and other UI. Optional preview while Theme settings are open.
function Format.HudSceneVisible()
    local name = Format.CurrentSceneName()
    local preview = Format.PreviewInSettings()
    local settingsOpen = preview and _G.ValknarrThemeSettingsOpen and true or false
    if type(name) == "string" then
        if name == "ValknarrUIEScene" then
            return true
        end
        local lower = string.lower(name)
        if lower == "hud" or lower == "hudui" or lower == "hud_ui" then
            return true
        end
        if string.find(lower, "map", 1, true) then
            return false
        end
        if preview and Format.IsSettingsScene(name) then
            return true
        end
        if settingsOpen and lower == "gamepadgamemenu" then
            return true
        end
        return false
    end
    if settingsOpen then
        return true
    end
    local fragment = _G.PLAYER_ATTRIBUTE_BARS_FRAGMENT or _G.HUD_FRAGMENT or _G.HUD_UI_FRAGMENT
    if fragment and type(fragment.IsShowing) == "function" then
        local ok, showing = pcall(fragment.IsShowing, fragment)
        if ok and showing ~= nil then
            return showing and true or false
        end
    end
    return true
end

function Format.ShowBarText()
    local store = _G.ValknarrThemeStore
    if not store or type(store.GetSetting) ~= "function" then
        return true
    end
    return store:GetSetting("showBarText") ~= false
end

function Format.ResourcesThemed(themeId)
    local id = Format.NormalizeThemeId(themeId)
    return id == Format.THEME_CLEAN or Format.ResourcesMetal(id)
end

function Format.ResourcesMetal(themeId)
    local id = Format.NormalizeThemeId(themeId)
    return id == Format.THEME_NORDIC or id == Format.THEME_STEEL or id == Format.THEME_BRONZE
end

function Format.IsEditorScene()
    if Format.CurrentSceneName() == "ValknarrUIEScene" then
        return true
    end
    local editor = _G.ValknarrUIEEditor
    return type(editor) == "table" and editor.active and not editor.ending or false
end

function Format.WidgetVisible(wolfId, inForm, editorPreview)
    if Format.NormalizeWolfId(wolfId) == Format.WOLF_VANILLA then
        return false
    end
    if inForm or editorPreview then
        return true
    end
    return false
end

function Format.WolfMetal(wolfId)
    local id = Format.NormalizeWolfId(wolfId)
    return id == Format.WOLF_NORDIC or id == Format.WOLF_STEEL or id == Format.WOLF_BRONZE
end

function Format.RingFilled(pct)
    pct = Format.Percent(pct, 100)
    local filled = math.floor((pct / 100) * Format.RING_SEGMENTS + 0.5)
    if filled < 0 then
        return 0
    end
    if filled > Format.RING_SEGMENTS then
        return Format.RING_SEGMENTS
    end
    return filled
end

function Format.Abbreviate(value)
    value = tonumber(value) or 0
    if value < 0 then
        value = 0
    end
    if value >= 10000 then
        return string.format("%.1fk", value / 1000)
    end
    return tostring(math.floor(value + 0.5))
end

function Format.Percent(current, maximum)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then
        return 0
    end
    local pct = math.floor((current / maximum) * 100 + 0.5)
    if pct < 0 then
        return 0
    end
    if pct > 100 then
        return 100
    end
    return pct
end

function Format.ResourceLine(current, maximum)
    local pct = Format.Percent(current, maximum)
    return Format.Abbreviate(current) .. "  " .. tostring(pct) .. "%"
end

function Format.FuryLine(current, maximum)
    return "Fury  " .. tostring(Format.Percent(current, maximum)) .. "%"
end

function Format.SustainIsLow(ultimate, inCombat)
    if not inCombat then
        return false
    end
    return (tonumber(ultimate) or 0) < Format.ULTIMATE_TICK
end

function Format.SustainSeconds(ultimate, inCombat)
    if not inCombat then
        return nil
    end
    local ult = tonumber(ultimate) or 0
    if ult < 0 then
        ult = 0
    end
    return math.floor(ult / Format.ULTIMATE_TICK) * Format.TICK_SECONDS
end

function Format.SustainLine(ultimate, inCombat)
    local ult = math.floor((tonumber(ultimate) or 0) + 0.5)
    if ult < 0 then
        ult = 0
    end
    if not inCombat then
        return "Ult  " .. tostring(ult)
    end
    if Format.SustainIsLow(ult, true) then
        return "Ult  " .. tostring(ult) .. "   too low"
    end
    local seconds = Format.SustainSeconds(ult, true)
    return "Ult  " .. tostring(ult) .. "   ~" .. tostring(seconds) .. "s"
end

return Format
