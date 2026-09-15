-- ESO Adventurer Suite
-- v0.29.552 - internationalization/localization core.
-- Supported client languages: English, German, French, Russian, Spanish,
-- Simplified Chinese, and Japanese. Missing translations always fall back to English.

local EPC = ESOProgressionCoach
if not EPC then return end

EPC.I18N = EPC.I18N or {}
local I = EPC.I18N

I.supported = {
    en = "English",
    de = "Deutsch",
    fr = "Français",
    ru = "Русский",
    es = "Español",
    zh = "简体中文",
    ja = "日本語",
}

local function normalizeLanguage(code)
    code = string.lower(tostring(code or ""))
    code = code:gsub("[_%-].*$", "")
    if code == "jp" then code = "ja" end
    if code == "cn" or code == "zhcn" or code == "chs" then code = "zh" end
    if not I.supported[code] then code = "en" end
    return code
end

local function esoLanguage()
    if type(GetCVar) == "function" then
        local ok, code = pcall(GetCVar, "language.2")
        if ok and code and code ~= "" then return normalizeLanguage(code) end
    end
    return "en"
end

local EN = {
    LANGUAGE = "Language / Localization",
    INTERFACE_LANGUAGE = "Interface language",
    AUTO_ESO_LANGUAGE = "Follow ESO client language",
    RELOAD_LANGUAGE = "Reload UI to fully apply language changes.",
    HOME = "Home",
    CHARACTER = "Character",
    COMPANIONS = "Companions",
    BUILD = "Build",
    GEAR_SETS = "Gear & Sets",
    SKILLS_CP = "Skills & CP",
    COMBAT = "Combat",
    CHARACTER_STATS = "Character Stats",
    ACHIEVEMENTS = "Achievements",
    QUEST_FINDER = "Quest Finder",
    GOLDEN_PURSUITS = "Golden Pursuits",
    ACTIVITIES = "Activities",
    MAP_TRAVEL = "Map / Travel",
    GROUP_FINDER = "Group Finder",
    ZONE_GUIDE = "Zone Guide",
    DUNGEON_FINDER = "Dungeon Finder",
    BATTLEGROUND_FINDER = "Battleground Finder",
    TALES_TRIBUTE = "Tales of Tribute",
    HOME_TOURS = "Home Tours",
    NOTES = "Notes",
    CHECKPOINTS = "Checkpoints",
    UTILITIES = "Utilities",
    CRAFTING_CODEX = "Crafting Codex",
    DICE_COIN = "Dice & Coin",
    SETTINGS = "Settings",
    CURRENT_CLASS = "CURRENT CLASS",
    CURRENT_COMPANION = "CURRENT COMPANION",
    NO_ACTIVE_COMPANION = "No active companion",
    OPEN = "Open",
    CLOSE = "Close",
    SAVE = "Save",
    RESET = "Reset",
    APPLY = "Apply",
    CANCEL = "Cancel",
    SEARCH = "Search",
    ALL = "All",
    ENABLED = "Enabled",
    DISABLED = "Disabled",
    ALWAYS = "Always",
    NEVER = "Never",
    AUTO = "Auto",
    HIDDEN = "Hidden",
    READY = "Ready",
    MISSING = "Missing",
    WITHDRAW = "Withdraw",
    DEPOSIT = "Deposit",
    WEAPONS = "Weapons",
    ARMOR = "Armor",
    JEWELRY = "Jewelry",
    CONSUMABLES = "Consumables",
    MATERIALS = "Materials",
    CRAFTING = "Crafting",
    FURNISHINGS = "Furnishings",
    MISC = "Misc",
    JUNK = "Junk",
    OTHER = "Other",
    SKIN = "Skin",
    POLYMORPH = "Polymorph",
    APPEARANCE = "Appearance",
    PRIMARY = "Primary",
    BACKUP = "Backup",
    PLAYER = "Player",
    TARGET = "Target",
    GROUP = "Group",
    RAID = "Raid",
    COMPANION = "Companion",
    HEALTH = "Health",
    MAGICKA = "Magicka",
    STAMINA = "Stamina",
    PERFORMANCE = "Performance",
    MINIMAP = "Minimap",
    QUICKSLOT = "Quickslot",
    ACTIVE_QUEST = "Active Quest",
    DAMAGE = "Damage",
    HEALER = "Healer",
    TANK = "Tank",
    AUTO_DETECT = "Auto Detect",
    MAGICKA_DPS = "Magicka DPS",
    STAMINA_DPS = "Stamina DPS",
    HYBRID_DPS = "Hybrid DPS",
    FULL_OVERLAY = "Full Overlay",
    COMPACT_NEXT_SKILL = "Compact Next Skill",
    HIGHLIGHT_ACTION_BAR = "Highlight Action Bar",
    HIDDEN_BACKGROUND = "Hidden / Background",
    CONSERVATIVE = "Conservative",
    NORMAL = "Normal",
    AGGRESSIVE = "Aggressive",
    HUD_LAYOUT_MODE = "HUD Layout Mode",
    SAVE_LAYOUT = "Save Layout",
    RESET_LAYOUT = "Reset Layout",
    GROUP_MEMBER = "Group Member %d",
    NOT_QUEUED = "Not queued",
    QUEUED = "Queued",
    LOADING = "Loading",
    GAMEPLAY_HOTKEYS = "Gameplay hotkeys",
    COMPATIBILITY_STATUS = "Compatibility status",
    ENABLE_SUITE = "Enable suite systems",
    SMART_COMBAT_ADVISOR = "Smart Combat Advisor",
    SMART_ADVISOR_SPECIALIZATION = "Smart Advisor specialization",
    SMART_ADVISOR_DISPLAY = "Smart Advisor display",
    TEST_ACTION_HIGHLIGHT = "Test Action-Bar Highlight",
    SHOW_BLOCK_REACTIONS = "Show BLOCK reactions",
    BLOCK_WARNING_SENSITIVITY = "Block warning sensitivity",
    LEARN_DANGEROUS_ATTACKS = "Learn dangerous attacks",
    COMBAT_ROLE_AWARENESS = "Combat role awareness",
    BOSS_MECHANICS_COACH = "Boss Mechanics Coach",
    ENABLE_BOSS_MECHANICS_COACH = "Enable Boss Mechanics Coach",
    BOSS_MECHANICS_VISIBILITY = "Boss Mechanics visibility",
    SHOW_PREPULL = "Show pre-pull boss briefing",
    ROLE_AWARE_CALLOUTS = "Role-aware boss callouts",
    LEARN_BOSS_MECHANICS = "Learn boss mechanics and timing",
    PREDICT_NEXT_MECHANIC = "Predict likely next mechanic",
    BOSS_COACH_WIDTH = "Boss Coach width",
    BOSS_COACH_HEIGHT = "Boss Coach height",
    BOSS_COACH_SCALE = "Boss Coach overall scale",
}

local DE = {
    LANGUAGE="Sprache / Lokalisierung", INTERFACE_LANGUAGE="Oberflächensprache", AUTO_ESO_LANGUAGE="ESO-Clientsprache verwenden", RELOAD_LANGUAGE="UI neu laden, um Sprachänderungen vollständig anzuwenden.",
    HOME="Start", CHARACTER="Charakter", COMPANIONS="Gefährten", BUILD="Build", GEAR_SETS="Ausrüstung & Sets", SKILLS_CP="Fertigkeiten & CP", COMBAT="Kampf", CHARACTER_STATS="Charakterwerte", ACHIEVEMENTS="Errungenschaften", QUEST_FINDER="Quest-Suche", GOLDEN_PURSUITS="Goldene Bestrebungen", ACTIVITIES="Aktivitäten", MAP_TRAVEL="Karte / Reisen", GROUP_FINDER="Gruppensuche", ZONE_GUIDE="Gebietsleitfaden", DUNGEON_FINDER="Verliessuche", BATTLEGROUND_FINDER="Schlachtfeldsuche", TALES_TRIBUTE="Ruhmesgeschichten", HOME_TOURS="Haustouren", NOTES="Notizen", CHECKPOINTS="Wegpunkte", UTILITIES="Werkzeuge", CRAFTING_CODEX="Handwerkskodex", DICE_COIN="Würfel & Münze", SETTINGS="Einstellungen",
    CURRENT_CLASS="AKTUELLE KLASSE", CURRENT_COMPANION="AKTUELLER GEFÄHRTE", NO_ACTIVE_COMPANION="Kein aktiver Gefährte", OPEN="Öffnen", CLOSE="Schließen", SAVE="Speichern", RESET="Zurücksetzen", APPLY="Anwenden", CANCEL="Abbrechen", SEARCH="Suchen", ALL="Alle", ENABLED="Aktiviert", DISABLED="Deaktiviert", ALWAYS="Immer", NEVER="Nie", AUTO="Automatisch", HIDDEN="Ausgeblendet", READY="Bereit", MISSING="Fehlt", WITHDRAW="Abheben", DEPOSIT="Einlagern", WEAPONS="Waffen", ARMOR="Rüstung", JEWELRY="Schmuck", CONSUMABLES="Verbrauchsgüter", MATERIALS="Materialien", CRAFTING="Handwerk", FURNISHINGS="Einrichtung", MISC="Sonstiges", JUNK="Plunder", OTHER="Andere", SKIN="Erscheinung", POLYMORPH="Verwandlung", APPEARANCE="Aussehen", PRIMARY="Primär", BACKUP="Sekundär", PLAYER="Spieler", TARGET="Ziel", GROUP="Gruppe", RAID="Schlachtzug", COMPANION="Gefährte", HEALTH="Leben", MAGICKA="Magicka", STAMINA="Ausdauer", PERFORMANCE="Leistung", MINIMAP="Minikarte", QUICKSLOT="Schnellzugriff", ACTIVE_QUEST="Aktive Quest", DAMAGE="Schaden", HEALER="Heiler", TANK="Tank", AUTO_DETECT="Automatisch erkennen", MAGICKA_DPS="Magicka-DPS", STAMINA_DPS="Ausdauer-DPS", HYBRID_DPS="Hybrid-DPS", FULL_OVERLAY="Vollständiges Overlay", COMPACT_NEXT_SKILL="Kompakte nächste Fertigkeit", HIGHLIGHT_ACTION_BAR="Aktionsleiste hervorheben", HIDDEN_BACKGROUND="Ausgeblendet / Hintergrund", CONSERVATIVE="Konservativ", NORMAL="Normal", AGGRESSIVE="Aggressiv", HUD_LAYOUT_MODE="HUD-Layoutmodus", SAVE_LAYOUT="Layout speichern", RESET_LAYOUT="Layout zurücksetzen", GROUP_MEMBER="Gruppenmitglied %d", NOT_QUEUED="Nicht eingereiht", QUEUED="Eingereiht", LOADING="Laden",
    GAMEPLAY_HOTKEYS="Gameplay-Tastenkürzel", COMPATIBILITY_STATUS="Kompatibilitätsstatus", ENABLE_SUITE="Suite-Systeme aktivieren", SMART_COMBAT_ADVISOR="Intelligenter Kampfberater", SMART_ADVISOR_SPECIALIZATION="Spezialisierung des Beraters", SMART_ADVISOR_DISPLAY="Anzeige des Beraters", TEST_ACTION_HIGHLIGHT="Aktionsleisten-Hervorhebung testen", SHOW_BLOCK_REACTIONS="BLOCK-Reaktionen anzeigen", BLOCK_WARNING_SENSITIVITY="Empfindlichkeit der Blockwarnung", LEARN_DANGEROUS_ATTACKS="Gefährliche Angriffe lernen", COMBAT_ROLE_AWARENESS="Kampfrollen-Erkennung", BOSS_MECHANICS_COACH="Bossmechanik-Coach", ENABLE_BOSS_MECHANICS_COACH="Bossmechanik-Coach aktivieren", BOSS_MECHANICS_VISIBILITY="Sichtbarkeit der Bossmechanik", SHOW_PREPULL="Boss-Briefing vor Kampfbeginn anzeigen", ROLE_AWARE_CALLOUTS="Rollenspezifische Boss-Hinweise", LEARN_BOSS_MECHANICS="Bossmechaniken und Timing lernen", PREDICT_NEXT_MECHANIC="Nächste Mechanik vorhersagen", BOSS_COACH_WIDTH="Breite des Boss-Coachs", BOSS_COACH_HEIGHT="Höhe des Boss-Coachs", BOSS_COACH_SCALE="Gesamtskalierung des Boss-Coachs",
}

local FR = {
    LANGUAGE="Langue / Localisation", INTERFACE_LANGUAGE="Langue de l’interface", AUTO_ESO_LANGUAGE="Suivre la langue du client ESO", RELOAD_LANGUAGE="Rechargez l’interface pour appliquer entièrement les changements de langue.",
    HOME="Accueil", CHARACTER="Personnage", COMPANIONS="Compagnons", BUILD="Build", GEAR_SETS="Équipement & Ensembles", SKILLS_CP="Compétences & PC", COMBAT="Combat", CHARACTER_STATS="Stats du personnage", ACHIEVEMENTS="Succès", QUEST_FINDER="Recherche de quêtes", GOLDEN_PURSUITS="Poursuites dorées", ACTIVITIES="Activités", MAP_TRAVEL="Carte / Voyage", GROUP_FINDER="Recherche de groupe", ZONE_GUIDE="Guide de zone", DUNGEON_FINDER="Recherche de donjon", BATTLEGROUND_FINDER="Recherche de champ de bataille", TALES_TRIBUTE="Récits de Gloires", HOME_TOURS="Visites de maisons", NOTES="Notes", CHECKPOINTS="Points de contrôle", UTILITIES="Outils", CRAFTING_CODEX="Codex d’artisanat", DICE_COIN="Dé & Pièce", SETTINGS="Paramètres",
    CURRENT_CLASS="CLASSE ACTUELLE", CURRENT_COMPANION="COMPAGNON ACTUEL", NO_ACTIVE_COMPANION="Aucun compagnon actif", OPEN="Ouvrir", CLOSE="Fermer", SAVE="Enregistrer", RESET="Réinitialiser", APPLY="Appliquer", CANCEL="Annuler", SEARCH="Rechercher", ALL="Tout", ENABLED="Activé", DISABLED="Désactivé", ALWAYS="Toujours", NEVER="Jamais", AUTO="Auto", HIDDEN="Masqué", READY="Prêt", MISSING="Manquant", WITHDRAW="Retirer", DEPOSIT="Déposer", WEAPONS="Armes", ARMOR="Armure", JEWELRY="Bijoux", CONSUMABLES="Consommables", MATERIALS="Matériaux", CRAFTING="Artisanat", FURNISHINGS="Mobilier", MISC="Divers", JUNK="Rebut", OTHER="Autre", SKIN="Peau", POLYMORPH="Polymorphe", APPEARANCE="Apparence", PRIMARY="Principal", BACKUP="Secondaire", PLAYER="Joueur", TARGET="Cible", GROUP="Groupe", RAID="Raid", COMPANION="Compagnon", HEALTH="Santé", MAGICKA="Magie", STAMINA="Vigueur", PERFORMANCE="Performances", MINIMAP="Mini-carte", QUICKSLOT="Raccourci", ACTIVE_QUEST="Quête active", DAMAGE="Dégâts", HEALER="Soigneur", TANK="Tank", AUTO_DETECT="Détection auto", MAGICKA_DPS="DPS Magie", STAMINA_DPS="DPS Vigueur", HYBRID_DPS="DPS Hybride", FULL_OVERLAY="Interface complète", COMPACT_NEXT_SKILL="Prochaine compétence compacte", HIGHLIGHT_ACTION_BAR="Surligner la barre d’action", HIDDEN_BACKGROUND="Masqué / Arrière-plan", CONSERVATIVE="Prudent", NORMAL="Normal", AGGRESSIVE="Agressif", HUD_LAYOUT_MODE="Mode disposition HUD", SAVE_LAYOUT="Enregistrer la disposition", RESET_LAYOUT="Réinitialiser la disposition", GROUP_MEMBER="Membre du groupe %d", NOT_QUEUED="Pas en file", QUEUED="En file", LOADING="Chargement",
    GAMEPLAY_HOTKEYS="Raccourcis de jeu", COMPATIBILITY_STATUS="État de compatibilité", ENABLE_SUITE="Activer les systèmes de la suite", SMART_COMBAT_ADVISOR="Conseiller de combat intelligent", SMART_ADVISOR_SPECIALIZATION="Spécialisation du conseiller", SMART_ADVISOR_DISPLAY="Affichage du conseiller", TEST_ACTION_HIGHLIGHT="Tester la surbrillance de la barre d’action", SHOW_BLOCK_REACTIONS="Afficher les réactions de BLOCAGE", BLOCK_WARNING_SENSITIVITY="Sensibilité de l’avertissement de blocage", LEARN_DANGEROUS_ATTACKS="Apprendre les attaques dangereuses", COMBAT_ROLE_AWARENESS="Prise en compte du rôle de combat", BOSS_MECHANICS_COACH="Coach des mécaniques de boss", ENABLE_BOSS_MECHANICS_COACH="Activer le coach des mécaniques de boss", BOSS_MECHANICS_VISIBILITY="Visibilité des mécaniques de boss", SHOW_PREPULL="Afficher le briefing avant le boss", ROLE_AWARE_CALLOUTS="Alertes de boss selon le rôle", LEARN_BOSS_MECHANICS="Apprendre les mécaniques et timings de boss", PREDICT_NEXT_MECHANIC="Prédire la prochaine mécanique", BOSS_COACH_WIDTH="Largeur du coach de boss", BOSS_COACH_HEIGHT="Hauteur du coach de boss", BOSS_COACH_SCALE="Échelle globale du coach de boss",
}

local RU = {
    LANGUAGE="Язык / Локализация", INTERFACE_LANGUAGE="Язык интерфейса", AUTO_ESO_LANGUAGE="Использовать язык клиента ESO", RELOAD_LANGUAGE="Перезагрузите интерфейс, чтобы полностью применить смену языка.",
    HOME="Главная", CHARACTER="Персонаж", COMPANIONS="Спутники", BUILD="Сборка", GEAR_SETS="Снаряжение и комплекты", SKILLS_CP="Навыки и ОГ", COMBAT="Бой", CHARACTER_STATS="Характеристики персонажа", ACHIEVEMENTS="Достижения", QUEST_FINDER="Поиск заданий", GOLDEN_PURSUITS="Золотые стремления", ACTIVITIES="Активности", MAP_TRAVEL="Карта / Путешествия", GROUP_FINDER="Поиск группы", ZONE_GUIDE="Путеводитель по зоне", DUNGEON_FINDER="Поиск подземелий", BATTLEGROUND_FINDER="Поиск полей сражений", TALES_TRIBUTE="Легенды о наградах", HOME_TOURS="Туры по домам", NOTES="Заметки", CHECKPOINTS="Контрольные точки", UTILITIES="Инструменты", CRAFTING_CODEX="Кодекс ремесла", DICE_COIN="Кубик и монета", SETTINGS="Настройки",
    CURRENT_CLASS="ТЕКУЩИЙ КЛАСС", CURRENT_COMPANION="ТЕКУЩИЙ СПУТНИК", NO_ACTIVE_COMPANION="Нет активного спутника", OPEN="Открыть", CLOSE="Закрыть", SAVE="Сохранить", RESET="Сбросить", APPLY="Применить", CANCEL="Отмена", SEARCH="Поиск", ALL="Все", ENABLED="Включено", DISABLED="Выключено", ALWAYS="Всегда", NEVER="Никогда", AUTO="Авто", HIDDEN="Скрыто", READY="Готово", MISSING="Отсутствует", WITHDRAW="Забрать", DEPOSIT="Положить", WEAPONS="Оружие", ARMOR="Доспехи", JEWELRY="Украшения", CONSUMABLES="Расходники", MATERIALS="Материалы", CRAFTING="Ремесло", FURNISHINGS="Мебель", MISC="Разное", JUNK="Хлам", OTHER="Другое", SKIN="Облик", POLYMORPH="Полиморф", APPEARANCE="Внешность", PRIMARY="Основной", BACKUP="Запасной", PLAYER="Игрок", TARGET="Цель", GROUP="Группа", RAID="Рейд", COMPANION="Спутник", HEALTH="Здоровье", MAGICKA="Магия", STAMINA="Запас сил", PERFORMANCE="Производительность", MINIMAP="Мини-карта", QUICKSLOT="Быстрый слот", ACTIVE_QUEST="Активное задание", DAMAGE="Урон", HEALER="Лекарь", TANK="Танк", AUTO_DETECT="Автоопределение", MAGICKA_DPS="Магический ДД", STAMINA_DPS="Стамина ДД", HYBRID_DPS="Гибридный ДД", FULL_OVERLAY="Полный оверлей", COMPACT_NEXT_SKILL="Компактный следующий навык", HIGHLIGHT_ACTION_BAR="Подсвечивать панель навыков", HIDDEN_BACKGROUND="Скрыто / Фон", CONSERVATIVE="Осторожно", NORMAL="Обычно", AGGRESSIVE="Агрессивно", HUD_LAYOUT_MODE="Режим настройки HUD", SAVE_LAYOUT="Сохранить расположение", RESET_LAYOUT="Сбросить расположение", GROUP_MEMBER="Участник группы %d", NOT_QUEUED="Не в очереди", QUEUED="В очереди", LOADING="Загрузка",
    GAMEPLAY_HOTKEYS="Горячие клавиши", COMPATIBILITY_STATUS="Состояние совместимости", ENABLE_SUITE="Включить системы Suite", SMART_COMBAT_ADVISOR="Умный боевой советник", SMART_ADVISOR_SPECIALIZATION="Специализация советника", SMART_ADVISOR_DISPLAY="Отображение советника", TEST_ACTION_HIGHLIGHT="Проверить подсветку панели навыков", SHOW_BLOCK_REACTIONS="Показывать реакции БЛОКА", BLOCK_WARNING_SENSITIVITY="Чувствительность предупреждений блока", LEARN_DANGEROUS_ATTACKS="Запоминать опасные атаки", COMBAT_ROLE_AWARENESS="Учет боевой роли", BOSS_MECHANICS_COACH="Помощник механик босса", ENABLE_BOSS_MECHANICS_COACH="Включить помощник механик босса", BOSS_MECHANICS_VISIBILITY="Видимость механик босса", SHOW_PREPULL="Показывать брифинг перед боссом", ROLE_AWARE_CALLOUTS="Подсказки босса по роли", LEARN_BOSS_MECHANICS="Изучать механики и тайминги босса", PREDICT_NEXT_MECHANIC="Предсказывать следующую механику", BOSS_COACH_WIDTH="Ширина помощника босса", BOSS_COACH_HEIGHT="Высота помощника босса", BOSS_COACH_SCALE="Общий масштаб помощника босса",
}

local ES = {
    LANGUAGE="Idioma / Localización", INTERFACE_LANGUAGE="Idioma de la interfaz", AUTO_ESO_LANGUAGE="Usar el idioma del cliente de ESO", RELOAD_LANGUAGE="Recarga la interfaz para aplicar completamente los cambios de idioma.",
    HOME="Inicio", CHARACTER="Personaje", COMPANIONS="Compañeros", BUILD="Configuración", GEAR_SETS="Equipo y conjuntos", SKILLS_CP="Habilidades y PC", COMBAT="Combate", CHARACTER_STATS="Estadísticas del personaje", ACHIEVEMENTS="Logros", QUEST_FINDER="Buscador de misiones", GOLDEN_PURSUITS="Persecuciones doradas", ACTIVITIES="Actividades", MAP_TRAVEL="Mapa / Viaje", GROUP_FINDER="Buscador de grupo", ZONE_GUIDE="Guía de zona", DUNGEON_FINDER="Buscador de mazmorras", BATTLEGROUND_FINDER="Buscador de campos de batalla", TALES_TRIBUTE="Historias de homenaje", HOME_TOURS="Visitas de casas", NOTES="Notas", CHECKPOINTS="Puntos de control", UTILITIES="Utilidades", CRAFTING_CODEX="Códice de artesanía", DICE_COIN="Dado y moneda", SETTINGS="Ajustes",
    CURRENT_CLASS="CLASE ACTUAL", CURRENT_COMPANION="COMPAÑERO ACTUAL", NO_ACTIVE_COMPANION="Sin compañero activo", OPEN="Abrir", CLOSE="Cerrar", SAVE="Guardar", RESET="Restablecer", APPLY="Aplicar", CANCEL="Cancelar", SEARCH="Buscar", ALL="Todo", ENABLED="Activado", DISABLED="Desactivado", ALWAYS="Siempre", NEVER="Nunca", AUTO="Auto", HIDDEN="Oculto", READY="Listo", MISSING="Falta", WITHDRAW="Retirar", DEPOSIT="Depositar", WEAPONS="Armas", ARMOR="Armadura", JEWELRY="Joyería", CONSUMABLES="Consumibles", MATERIALS="Materiales", CRAFTING="Artesanía", FURNISHINGS="Mobiliario", MISC="Varios", JUNK="Basura", OTHER="Otro", SKIN="Piel", POLYMORPH="Polimorfo", APPEARANCE="Apariencia", PRIMARY="Principal", BACKUP="Secundario", PLAYER="Jugador", TARGET="Objetivo", GROUP="Grupo", RAID="Banda", COMPANION="Compañero", HEALTH="Salud", MAGICKA="Magia", STAMINA="Aguante", PERFORMANCE="Rendimiento", MINIMAP="Minimapa", QUICKSLOT="Acceso rápido", ACTIVE_QUEST="Misión activa", DAMAGE="Daño", HEALER="Sanador", TANK="Tanque", AUTO_DETECT="Detección automática", MAGICKA_DPS="DPS de Magia", STAMINA_DPS="DPS de Aguante", HYBRID_DPS="DPS híbrido", FULL_OVERLAY="Superposición completa", COMPACT_NEXT_SKILL="Próxima habilidad compacta", HIGHLIGHT_ACTION_BAR="Resaltar barra de acción", HIDDEN_BACKGROUND="Oculto / Fondo", CONSERVATIVE="Conservador", NORMAL="Normal", AGGRESSIVE="Agresivo", HUD_LAYOUT_MODE="Modo de diseño del HUD", SAVE_LAYOUT="Guardar diseño", RESET_LAYOUT="Restablecer diseño", GROUP_MEMBER="Miembro del grupo %d", NOT_QUEUED="Fuera de cola", QUEUED="En cola", LOADING="Cargando",
    GAMEPLAY_HOTKEYS="Atajos de juego", COMPATIBILITY_STATUS="Estado de compatibilidad", ENABLE_SUITE="Activar sistemas de la Suite", SMART_COMBAT_ADVISOR="Asesor de combate inteligente", SMART_ADVISOR_SPECIALIZATION="Especialización del asesor", SMART_ADVISOR_DISPLAY="Visualización del asesor", TEST_ACTION_HIGHLIGHT="Probar resaltado de la barra de acción", SHOW_BLOCK_REACTIONS="Mostrar reacciones de BLOQUEO", BLOCK_WARNING_SENSITIVITY="Sensibilidad de aviso de bloqueo", LEARN_DANGEROUS_ATTACKS="Aprender ataques peligrosos", COMBAT_ROLE_AWARENESS="Detección del rol de combate", BOSS_MECHANICS_COACH="Asistente de mecánicas de jefe", ENABLE_BOSS_MECHANICS_COACH="Activar asistente de mecánicas de jefe", BOSS_MECHANICS_VISIBILITY="Visibilidad de mecánicas de jefe", SHOW_PREPULL="Mostrar briefing previo al jefe", ROLE_AWARE_CALLOUTS="Avisos de jefe según el rol", LEARN_BOSS_MECHANICS="Aprender mecánicas y tiempos del jefe", PREDICT_NEXT_MECHANIC="Predecir la siguiente mecánica", BOSS_COACH_WIDTH="Ancho del asistente de jefe", BOSS_COACH_HEIGHT="Alto del asistente de jefe", BOSS_COACH_SCALE="Escala general del asistente de jefe",
}

local ZH = {
    LANGUAGE="语言 / 本地化", INTERFACE_LANGUAGE="界面语言", AUTO_ESO_LANGUAGE="跟随 ESO 客户端语言", RELOAD_LANGUAGE="重新加载界面以完全应用语言更改。",
    HOME="主页", CHARACTER="角色", COMPANIONS="伙伴", BUILD="配装", GEAR_SETS="装备与套装", SKILLS_CP="技能与勇士点", COMBAT="战斗", CHARACTER_STATS="角色属性", ACHIEVEMENTS="成就", QUEST_FINDER="任务查找器", GOLDEN_PURSUITS="黄金追求", ACTIVITIES="活动", MAP_TRAVEL="地图 / 旅行", GROUP_FINDER="组队查找器", ZONE_GUIDE="区域指南", DUNGEON_FINDER="地下城查找器", BATTLEGROUND_FINDER="战场查找器", TALES_TRIBUTE="望族传奇", HOME_TOURS="住宅巡游", NOTES="笔记", CHECKPOINTS="检查点", UTILITIES="工具", CRAFTING_CODEX="制作宝典", DICE_COIN="骰子与硬币", SETTINGS="设置",
    CURRENT_CLASS="当前职业", CURRENT_COMPANION="当前伙伴", NO_ACTIVE_COMPANION="没有激活的伙伴", OPEN="打开", CLOSE="关闭", SAVE="保存", RESET="重置", APPLY="应用", CANCEL="取消", SEARCH="搜索", ALL="全部", ENABLED="已启用", DISABLED="已禁用", ALWAYS="始终", NEVER="从不", AUTO="自动", HIDDEN="隐藏", READY="就绪", MISSING="缺失", WITHDRAW="取出", DEPOSIT="存入", WEAPONS="武器", ARMOR="护甲", JEWELRY="首饰", CONSUMABLES="消耗品", MATERIALS="材料", CRAFTING="制作", FURNISHINGS="家具", MISC="杂项", JUNK="垃圾", OTHER="其他", SKIN="皮肤", POLYMORPH="变形", APPEARANCE="外观", PRIMARY="主手", BACKUP="备用", PLAYER="玩家", TARGET="目标", GROUP="队伍", RAID="团队", COMPANION="伙伴", HEALTH="生命", MAGICKA="魔力", STAMINA="耐力", PERFORMANCE="性能", MINIMAP="小地图", QUICKSLOT="快捷栏", ACTIVE_QUEST="当前任务", DAMAGE="伤害", HEALER="治疗", TANK="坦克", AUTO_DETECT="自动检测", MAGICKA_DPS="魔力输出", STAMINA_DPS="耐力输出", HYBRID_DPS="混合输出", FULL_OVERLAY="完整覆盖层", COMPACT_NEXT_SKILL="紧凑下一技能", HIGHLIGHT_ACTION_BAR="高亮技能栏", HIDDEN_BACKGROUND="隐藏 / 后台", CONSERVATIVE="保守", NORMAL="普通", AGGRESSIVE="激进", HUD_LAYOUT_MODE="HUD 布局模式", SAVE_LAYOUT="保存布局", RESET_LAYOUT="重置布局", GROUP_MEMBER="队伍成员 %d", NOT_QUEUED="未排队", QUEUED="排队中", LOADING="加载中",
    GAMEPLAY_HOTKEYS="游戏快捷键", COMPATIBILITY_STATUS="兼容性状态", ENABLE_SUITE="启用套件系统", SMART_COMBAT_ADVISOR="智能战斗顾问", SMART_ADVISOR_SPECIALIZATION="顾问专精", SMART_ADVISOR_DISPLAY="顾问显示", TEST_ACTION_HIGHLIGHT="测试技能栏高亮", SHOW_BLOCK_REACTIONS="显示格挡反应", BLOCK_WARNING_SENSITIVITY="格挡警告灵敏度", LEARN_DANGEROUS_ATTACKS="学习危险攻击", COMBAT_ROLE_AWARENESS="战斗角色识别", BOSS_MECHANICS_COACH="Boss 机制助手", ENABLE_BOSS_MECHANICS_COACH="启用 Boss 机制助手", BOSS_MECHANICS_VISIBILITY="Boss 机制可见性", SHOW_PREPULL="显示开怪前 Boss 简报", ROLE_AWARE_CALLOUTS="按角色显示 Boss 提示", LEARN_BOSS_MECHANICS="学习 Boss 机制与时间", PREDICT_NEXT_MECHANIC="预测下一机制", BOSS_COACH_WIDTH="Boss 助手宽度", BOSS_COACH_HEIGHT="Boss 助手高度", BOSS_COACH_SCALE="Boss 助手整体缩放",
}

local JA = {
    LANGUAGE="言語 / ローカライズ", INTERFACE_LANGUAGE="インターフェース言語", AUTO_ESO_LANGUAGE="ESOクライアントの言語に従う", RELOAD_LANGUAGE="言語変更を完全に適用するにはUIを再読み込みしてください。",
    HOME="ホーム", CHARACTER="キャラクター", COMPANIONS="コンパニオン", BUILD="ビルド", GEAR_SETS="装備 & セット", SKILLS_CP="スキル & CP", COMBAT="戦闘", CHARACTER_STATS="キャラクターステータス", ACHIEVEMENTS="実績", QUEST_FINDER="クエスト検索", GOLDEN_PURSUITS="ゴールデン・パースート", ACTIVITIES="アクティビティ", MAP_TRAVEL="マップ / 移動", GROUP_FINDER="グループ検索", ZONE_GUIDE="ゾーンガイド", DUNGEON_FINDER="ダンジョン検索", BATTLEGROUND_FINDER="バトルグラウンド検索", TALES_TRIBUTE="テイルズ・オブ・トリビュート", HOME_TOURS="ハウスツアー", NOTES="メモ", CHECKPOINTS="チェックポイント", UTILITIES="ユーティリティ", CRAFTING_CODEX="クラフト・コーデックス", DICE_COIN="ダイス & コイン", SETTINGS="設定",
    CURRENT_CLASS="現在のクラス", CURRENT_COMPANION="現在のコンパニオン", NO_ACTIVE_COMPANION="アクティブなコンパニオンなし", OPEN="開く", CLOSE="閉じる", SAVE="保存", RESET="リセット", APPLY="適用", CANCEL="キャンセル", SEARCH="検索", ALL="すべて", ENABLED="有効", DISABLED="無効", ALWAYS="常時", NEVER="なし", AUTO="自動", HIDDEN="非表示", READY="準備完了", MISSING="不足", WITHDRAW="引き出す", DEPOSIT="預ける", WEAPONS="武器", ARMOR="防具", JEWELRY="アクセサリー", CONSUMABLES="消耗品", MATERIALS="素材", CRAFTING="クラフト", FURNISHINGS="家具", MISC="その他", JUNK="ジャンク", OTHER="その他", SKIN="スキン", POLYMORPH="ポリモーフ", APPEARANCE="外見", PRIMARY="メイン", BACKUP="バックアップ", PLAYER="プレイヤー", TARGET="ターゲット", GROUP="グループ", RAID="レイド", COMPANION="コンパニオン", HEALTH="体力", MAGICKA="マジカ", STAMINA="スタミナ", PERFORMANCE="パフォーマンス", MINIMAP="ミニマップ", QUICKSLOT="クイックスロット", ACTIVE_QUEST="アクティブクエスト", DAMAGE="ダメージ", HEALER="ヒーラー", TANK="タンク", AUTO_DETECT="自動検出", MAGICKA_DPS="マジカDPS", STAMINA_DPS="スタミナDPS", HYBRID_DPS="ハイブリッドDPS", FULL_OVERLAY="フルオーバーレイ", COMPACT_NEXT_SKILL="コンパクト次スキル", HIGHLIGHT_ACTION_BAR="アクションバーを強調", HIDDEN_BACKGROUND="非表示 / バックグラウンド", CONSERVATIVE="控えめ", NORMAL="標準", AGGRESSIVE="積極的", HUD_LAYOUT_MODE="HUDレイアウトモード", SAVE_LAYOUT="レイアウトを保存", RESET_LAYOUT="レイアウトをリセット", GROUP_MEMBER="グループメンバー %d", NOT_QUEUED="キュー外", QUEUED="キュー中", LOADING="読み込み中",
    GAMEPLAY_HOTKEYS="ゲームプレイ用ホットキー", COMPATIBILITY_STATUS="互換性ステータス", ENABLE_SUITE="Suiteシステムを有効化", SMART_COMBAT_ADVISOR="スマート戦闘アドバイザー", SMART_ADVISOR_SPECIALIZATION="アドバイザーの専門化", SMART_ADVISOR_DISPLAY="アドバイザー表示", TEST_ACTION_HIGHLIGHT="アクションバー強調をテスト", SHOW_BLOCK_REACTIONS="ブロック反応を表示", BLOCK_WARNING_SENSITIVITY="ブロック警告の感度", LEARN_DANGEROUS_ATTACKS="危険な攻撃を学習", COMBAT_ROLE_AWARENESS="戦闘ロール認識", BOSS_MECHANICS_COACH="ボスメカニクスコーチ", ENABLE_BOSS_MECHANICS_COACH="ボスメカニクスコーチを有効化", BOSS_MECHANICS_VISIBILITY="ボスメカニクスの表示", SHOW_PREPULL="戦闘前ボス説明を表示", ROLE_AWARE_CALLOUTS="ロール別ボス通知", LEARN_BOSS_MECHANICS="ボスメカニクスとタイミングを学習", PREDICT_NEXT_MECHANIC="次のメカニクスを予測", BOSS_COACH_WIDTH="ボスコーチの幅", BOSS_COACH_HEIGHT="ボスコーチの高さ", BOSS_COACH_SCALE="ボスコーチ全体のスケール",
}

I.keys = { en=EN, de=DE, fr=FR, ru=RU, es=ES, zh=ZH, ja=JA }
I.raw = {}
for lang, locale in pairs(I.keys) do
    I.raw[lang] = {}
    if lang ~= "en" then
        for key, english in pairs(EN) do
            if locale[key] then I.raw[lang][english] = locale[key] end
        end
    end
end

function I:GetLanguage()
    local saved = EPC.saved
    local override = saved and tostring(saved.i18nLanguage029552 or "AUTO") or "AUTO"
    if override ~= "" and override ~= "AUTO" then return normalizeLanguage(override) end
    return esoLanguage()
end

function I:SetLanguage(code)
    code = tostring(code or "AUTO")
    if code ~= "AUTO" then code = normalizeLanguage(code) end
    if EPC.saved then EPC.saved.i18nLanguage029552 = code end
    self.language = self:GetLanguage()
    return self.language
end

function I:T(key, ...)
    key = tostring(key or "")
    local lang = self.language or self:GetLanguage()
    self.language = lang
    local locale = self.keys[lang] or EN
    local text = locale[key] or EN[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, text, ...)
        if ok then return formatted end
    end
    return text
end

local function localizeCompound(self, text, lang)
    local raw = self.raw[lang]
    if not raw then return text end
    local direct = raw[text]
    if direct then return direct end

    -- Category/count labels such as "Weapons (14)".
    local base, count = text:match("^(.-)%s*(%(%d+%))$")
    if base and raw[base] then return raw[base] .. " " .. count end

    -- Preserve dynamic values after a colon while translating the fixed label.
    local left, right = text:match("^([^:]+):%s*(.+)$")
    if left and raw[left] then return raw[left] .. ": " .. right end

    -- Common slash-separated compact labels.
    local a, b = text:match("^([^/]+)/([^/]+)$")
    if a and b then
        a = a:gsub("%s+$", "")
        b = b:gsub("^%s+", "")
        if raw[a] or raw[b] then return (raw[a] or a) .. " / " .. (raw[b] or b) end
    end
    return text
end

function I:Localize(text)
    if type(text) ~= "string" or text == "" then return text end
    local lang = self.language or self:GetLanguage()
    self.language = lang
    if lang == "en" then return text end
    return localizeCompound(self, text, lang)
end

function I:LocalizeOption(option)
    if type(option) ~= "table" then return option end
    for _, field in ipairs({"name", "title", "text", "tooltip", "warning"}) do
        local value = option[field]
        if type(value) == "string" then
            option[field] = self:Localize(value)
        elseif type(value) == "function" and not option["_easI18NWrapped_" .. field] then
            local base = value
            option[field] = function(...)
                local result = base(...)
                if type(result) == "string" then return I:Localize(result) end
                return result
            end
            option["_easI18NWrapped_" .. field] = true
        end
    end
    if type(option.choices) == "table" then
        for i = 1, #option.choices do
            if type(option.choices[i]) == "string" then option.choices[i] = self:Localize(option.choices[i]) end
        end
    end
    return option
end

function I:LocalizeOptions(options)
    if type(options) ~= "table" then return options end
    for i = 1, #options do self:LocalizeOption(options[i]) end
    return options
end

function I:LocalizeControlTree(control, depth)
    if not control then return end
    depth = tonumber(depth) or 0
    if depth > 18 then return end

    if type(control.GetText) == "function" and type(control.SetText) == "function" then
        local ok, text = pcall(control.GetText, control)
        if ok and type(text) == "string" and text ~= "" then
            local localized = self:Localize(text)
            if localized ~= text then pcall(control.SetText, control, localized) end
        end
    end

    if type(control.GetNumChildren) == "function" and type(control.GetChild) == "function" then
        local ok, count = pcall(control.GetNumChildren, control)
        count = ok and tonumber(count) or 0
        for i = 1, count do
            local okChild, child = pcall(control.GetChild, control, i)
            if okChild and child then self:LocalizeControlTree(child, depth + 1) end
        end
    end
end

function I:InjectSettings(options)
    if type(options) ~= "table" or options._easI18NInjected029552 then return options end
    options._easI18NInjected029552 = true
    local choices = { self:T("AUTO_ESO_LANGUAGE"), "English", "Deutsch", "Français", "Русский", "Español", "简体中文", "日本語" }
    local values = { "AUTO", "en", "de", "fr", "ru", "es", "zh", "ja" }
    table.insert(options, 1, {
        type = "dropdown",
        name = self:T("INTERFACE_LANGUAGE"),
        tooltip = self:T("RELOAD_LANGUAGE"),
        choices = choices,
        choicesValues = values,
        getFunc = function() return EPC.saved and (EPC.saved.i18nLanguage029552 or "AUTO") or "AUTO" end,
        setFunc = function(value)
            I:SetLanguage(value)
            if EPC.Print then EPC:Print(I:T("RELOAD_LANGUAGE")) end
        end,
        default = "AUTO",
        width = "full",
    })
    table.insert(options, 1, { type="header", name=self:T("LANGUAGE") })
    return options
end

function I:HookLAM()
    local LAM = rawget(_G, "LibAddonMenu2")
    if type(LAM) ~= "table" or type(LAM.RegisterOptionControls) ~= "function" or LAM._easI18NHook029552 then return end
    local base = LAM.RegisterOptionControls
    function LAM:RegisterOptionControls(panelName, options, ...)
        if panelName == "ESOProgressionCoachSettings" and type(options) == "table" then
            I:InjectSettings(options)
            I:LocalizeOptions(options)
        end
        return base(self, panelName, options, ...)
    end
    LAM._easI18NHook029552 = true
end

I.language = I:GetLanguage()
I:HookLAM()

-- Public helpers for every Suite module. New UI code should use these directly.
function EPC:L(key, ...)
    return I:T(key, ...)
end

function EPC:Localize(text)
    return I:Localize(text)
end
