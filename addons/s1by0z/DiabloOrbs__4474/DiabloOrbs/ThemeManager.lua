-- ThemeManager.lua - Gère l'abstraction des thèmes et des chemins de textures
DiabloOrbs = DiabloOrbs or {}
local ThemeManager = {}
DiabloOrbs.ThemeManager = ThemeManager

-- Thèmes disponibles
ThemeManager.THEMES = {
    legacy = "Legacy",
    d4 = "D4",
}

-- Thème par défaut
ThemeManager.DEFAULT_THEME = "legacy"

-- Thème actuel (sera chargé depuis les settings)
local currentTheme = ThemeManager.DEFAULT_THEME

-- Base path des thèmes
local THEME_BASE_PATH = "DiabloOrbs/Themes/"

local THEME_TEXTURE_ALIASES = {
    legacy = {
        ["Glow.dds"] = "glow.dds",
        ["Border.dds"] = "border.dds",
    },
    d4 = {
        ["Glow.dds"] = "glow.dds",
        ["Border.dds"] = "border.dds",
    },
}

-- Table pour le cache des chemins
local texturePathCache = {}

--- Retourne le thème actuel
function ThemeManager:GetCurrentTheme()
    return currentTheme
end

--- Change le thème actuel
function ThemeManager:SetTheme(themeName)
    if self.THEMES[themeName] then
        currentTheme = themeName
        -- Vider le cache quand on change de thème
        texturePathCache = {}
        return true
    end
    return false
end

--- Retourne le chemin complet pour une texture en fonction du thème
-- Utilise un fallback vers le répertoire Textures/ à la racine si non trouvé dans le thème
function ThemeManager:GetTexturePath(relativePath)
    -- Chemins déjà absolus : pas de mise en cache nécessaire
    if string.find(relativePath, "^DiabloOrbs/Themes/") then
        return relativePath
    end
    if string.find(relativePath, "^[a-zA-Z0-9_]+/") and not string.find(relativePath, "Textures/") and not string.find(relativePath, "^0/") then
        return relativePath
    end

    -- Retourner depuis le cache si disponible (vidé automatiquement lors d'un changement de thème)
    local cached = texturePathCache[relativePath]
    if cached ~= nil then
        return cached
    end

    -- Preserve subpath under Textures/ when provided (ex: "0/Shade.dds")
    local subPath = string.match(relativePath, "Textures/(.+)$")
    if not subPath then
        subPath = relativePath
    end

    local themeAliases = THEME_TEXTURE_ALIASES[currentTheme]
    if themeAliases and themeAliases[subPath] then
        subPath = themeAliases[subPath]
    end

    local result
    if currentTheme == "legacy" then
        result = "DiabloOrbs/Textures/" .. subPath
    else
        result = THEME_BASE_PATH .. self.THEMES[currentTheme] .. "/Textures/" .. subPath
    end

    texturePathCache[relativePath] = result
    return result
end

--- Retourne le chemin complet pour une texture avec fallback
-- Essaie d'abord le thème, puis le répertoire global Textures/ si non trouvé
function ThemeManager:GetTexturePathWithFallback(relativePath)
    local themePath = self:GetTexturePath(relativePath)
    
    -- Extraire le nom de fichier
    local subPath = string.match(relativePath, "Textures/(.+)$")
    if not subPath then
        subPath = relativePath
    end
    
    -- Fallback vers le répertoire Textures/ à la racine
    local fallbackPath = "DiabloOrbs/Textures/" .. subPath
    
    -- En l'absence de vérification de fichier (ESO ne l'expose pas), on retourne le themePath
    -- Si le fichier n'existe pas dans le thème, ESO fallback automatiquement vers le dossier racine
    return themePath
end

--- Retourne la liste des thèmes disponibles
function ThemeManager:GetAvailableThemes()
    local themes = {}
    for key, name in pairs(self.THEMES) do
        table.insert(themes, {key = key, name = name})
    end
    return themes
end
