-- ============================================================================
--  SquirrelSlayer : Localization
--  Gestion des chaînes de texte multi-langue.
-- ============================================================================

-- Dictionnaire de traductions indexé par code langue ESO.
local STRINGS = {
    fr = {
        pin_tooltip = "%d écureuil(s) tué(s) ici",
        filter_name = "Squirrel Slayer",
        debug_on = "Mode DEBUG activé (logs visibles)",
        debug_off = "Mode DEBUG désactivé (logs masqués)",
        sim_squirrel = "Squirrel simulé à %.3f, %.3f sur carte '%s'",
        no_player_pos = "Impossible d'obtenir la position du joueur.",
        lgps_required = "LibGPS est obligatoire : addon désactivé.",
        libzone_required = "LibZone est obligatoire pour la gestion régions/sous-régions : addon désactivé.",
        addon_loaded = "Addon chargé.",
        stats_title = "Statistiques par région",
        stats_region = "Région",
        stats_kills = "Éliminations",
        stats_close = "Fermer",
        stats_empty = "Aucune région à afficher.",
        stats_page = "Page %d/%d",
        stats_sort_name = "Trier: Nom",
        stats_sort_kills = "Trier: Kills",
        stats_total = "Total",
    },
    en = {
        pin_tooltip = "%d squirrel(s) killed here",
        filter_name = "Squirrel Slayer",
        debug_on = "DEBUG mode enabled (logs visible)",
        debug_off = "DEBUG mode disabled (logs hidden)",
        sim_squirrel = "Simulated squirrel at %.3f, %.3f on map '%s'",
        no_player_pos = "Unable to get player position.",
        lgps_required = "LibGPS is mandatory: addon disabled.",
        libzone_required = "LibZone is mandatory for region/subregion mapping: addon disabled.",
        addon_loaded = "Addon loaded.",
        stats_title = "Region statistics",
        stats_region = "Region",
        stats_kills = "Kills",
        stats_close = "Close",
        stats_empty = "No regions to display.",
        stats_page = "Page %d/%d",
        stats_sort_name = "Sort: Name",
        stats_sort_kills = "Sort: Kills",
        stats_total = "Total",
    },
    de = {
        pin_tooltip = "%d Eichhörnchen hier getötet",
        filter_name = "Eichhörnchen-Jäger",
        debug_on = "DEBUG-Modus aktiviert (Logs sichtbar)",
        debug_off = "DEBUG-Modus deaktiviert (Logs ausgeblendet)",
        sim_squirrel = "Simuliertes Eichhörnchen bei %.3f, %.3f auf Karte '%s'",
        no_player_pos = "Spielposition konnte nicht ermittelt werden.",
        lgps_missing = "LibGPS nicht erkannt => Fusion in Kartenkoordinaten (Fallback).",
        lgps_install = "Installiere LibGPS (vorzugsweise LibGPS3) für präzise Meter-basierte Fusion.",
        addon_loaded = "Addon geladen.",
    },
    es = {
        pin_tooltip = "%d ardilla(s) muerta(s) aquí",
        filter_name = "Cazador de ardillas",
        debug_on = "Modo DEBUG activado (registros visibles)",
        debug_off = "Modo DEBUG desactivado (registros ocultos)",
        sim_squirrel = "Ardilla simulada en %.3f, %.3f en el mapa '%s'",
        no_player_pos = "No se pudo obtener la posición del jugador.",
        lgps_missing = "LibGPS no detectado => fusión en coordenadas del mapa (fallback).",
        lgps_install = "Instala LibGPS (preferiblemente LibGPS3) para una fusión precisa en metros.",
        addon_loaded = "Addon cargado.",
    },
    ru = {
        pin_tooltip = "%d белка(и) убито здесь",
        filter_name = "Охотник на белок",
        debug_on = "Режим ОТЛАДКИ включен (логи видимы)",
        debug_off = "Режим ОТЛАДКИ выключен (логи скрыты)",
        sim_squirrel = "Симулированная белка на карте '%s' в координатах %.3f, %.3f",
        no_player_pos = "Невозможно получить позицию игрока.",
        lgps_missing = "LibGPS не обнаружен => объединение по координатам карты (резервный режим).",
        lgps_install = "Установите LibGPS (предпочтительно LibGPS3) для точного объединения в метрах.",
        addon_loaded = "Аддон загружен.",
    },
    zh = {
        pin_tooltip = "此处击杀了 %d 只松鼠",
        filter_name = "松鼠猎人",
        debug_on = "调试模式已启用（日志可见）",
        debug_off = "调试模式已禁用（日志隐藏）",
        sim_squirrel = "在 '%s' 地图的 %.3f, %.3f 处模拟松鼠",
        no_player_pos = "无法获取玩家位置。",
        lgps_missing = "未检测到 LibGPS => 使用地图坐标合并位置（备用）。",
        lgps_install = "请安装 LibGPS（建议使用 LibGPS3）以获得精确的米制合并。",
        addon_loaded = "插件已加载。",
    },
}

--- Retourne la langue active du client ESO.
--- @return string languageCode
local function GetCurrentLanguage()
    return GetCVar("language.2") or "en"
end

--- Retourne une chaîne localisée pour une clé donnée.
--- @param key string clé de traduction
--- @return string localizedText
local function GetLocalizedString(key)
    local currentLanguage = GetCurrentLanguage()
    return STRINGS[currentLanguage] and STRINGS[currentLanguage][key] or STRINGS.en[key]
end

SquirrelSlayer = SquirrelSlayer or {}
SquirrelSlayer.GetString = GetLocalizedString
