-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.name = "ESOAdventurerSuite"
EPC.legacyName = "ESOProgressionCoach"
EPC.displayName = "ESO Adventurer Suite"
EPC.version = "0.29.143"
EPC.author = "HoZayyBadazz"
EPC.savedVersion = 1
EPC.interactionMode = false
EPC.interactionOwned = false
EPC.combatHudMoveMode = false
EPC.combatHudMoveOwned = false
EPC.unitFramesMoveMode = false
EPC.unitFramesMoveOwned = false
EPC.miniMapMoveMode = false
EPC.miniMapMoveOwned = false


-- v0.29.113: The distributed archive always contains one canonical
-- ESOAdventurerSuite folder.  Use that known-good addon-relative texture root
-- directly so UI DDS art does not disappear because a runtime source-path probe
-- returned a temporary or nested extraction name.
EPC.assetRoot = "ESOAdventurerSuite"
EPC.assetArtRoot029125 = "Art029125"
function EPC:AssetPath(relativePath)
    local relative = tostring(relativePath or ""):gsub("^/+", "")
    -- v0.29.125: use a versioned on-disk art folder. ESO can retain stale
    -- addon DDS entries in shader_cache.cooked after an in-place update; a
    -- new resource path forces the current packaged texture to be resolved.
    if string.sub(relative, 1, 4) == "Art/" then
        relative = (self.assetArtRoot029125 or "Art029125") .. "/" .. string.sub(relative, 5)
    end
    return "ESOAdventurerSuite/" .. relative
end

if type(ZO_CreateStringId) == "function" then
    ZO_CreateStringId("SI_BINDING_NAME_ESO_PROGRESSION_COACH_CATEGORY", EPC.displayName)
    ZO_CreateStringId("SI_BINDING_NAME_ESO_PROGRESSION_COACH_TOGGLE", "Open / Close Tamriel Codex")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_JOURNAL", "Open / Close Tamriel Codex")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_GAME_MODE_REPORT", "Open / Close Game Mode Combat Report")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_ANTIQUITIES_CATEGORY", "ESO Adventurer Suite - Antiquities")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_ANTIQUITY_LEAD_FINDER", "Open / Close Antiquity Lead Finder")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_MAP_TELEPORTER_TOGGLE", "Open / Close Map Teleporter")
end

EPC.defaults = {
    enabled = true,
    locked = false,
    minimized = false,
    alpha = 0.96,
    scale = 1.0,
    fontSize = 17,
    left = 760,
    top = 180,
    width = 800,
    activeTab = "BUILD",
    showReasons = true,
    refreshMs = 1200,
    compactThreshold = 3,
    travelMode = "SHRINES",
    travelPage = 1,
    travelBookPage = 1,
    -- Automatically show the integrated travel browser with ESO's World Map.
    mapTeleporterEnabled = true,
    mapTeleporterIncludeHouses = true,
    mapTeleporterShowAllZones = true,
    mapTeleporterShowBlacklisted = false,
    mapTeleporterSortMode = "SMART",
    mapTeleporterVisibleRows = 15,
    mapTeleporterExpanded = false,
    -- Teleporter display mode: MAP = World Map only, ALWAYS = persistent HUD drawer.
    mapTeleporterDisplayMode = "MAP",
    mapTeleporterLeft = -1,
    mapTeleporterTop = -1,
    mapTeleporterFavorites = {},
    mapTeleporterBlacklistPlayers = {},
    mapTeleporterBlacklistZones = {},
    mapTeleporterPortCount = {},
    mapTeleporterLastUsed = {},
    activityGoal = "BALANCED",
    activityHistory = {},
    goldSpendingByCharacter = {},
    dungeonHistory = { runs = {}, importedAchievements = {} },
    dungeonQueueHudLeft = -1,
    dungeonQueueHudTop = -1,
    dungeonQueueHudWidth = 360,
    dungeonQueueHudHeight = 128,
    synergyOverlayCustom2861 = false,
    synergyOverlayOffsetX2861 = 0,
    synergyOverlayOffsetY2861 = 0,
    activityRunHistory = { runs = {}, importedAchievements = {} },
    autoExpandInteract = true,
    coachFocus = "AUTO",
    combatHudWhenHidden = true,
    showCombatHud = true,
    combatHudVisibility = "COMBAT",
    combatHudLeft = -1,
    combatHudTop = -1,
    combatHudScale = 1.0,
    combatHudAlpha = 0.94,
    combatHudLocked = true,

    -- Lightweight Suite replacement for ESO's built-in FPS/latency meter.
    showPerformanceOverlay = true,
    suppressNativePerformanceMeters = true,
    performanceOverlayLeft = -1,
    performanceOverlayTop = -1,
    performanceOverlayScale = 1.0,

    gameModeReportEnabled = true,
    gameModeReportAlpha = 0.96,
    gameModeReportLeft = -1,
    gameModeReportTop = -1,
    gameModeReportWidth = 1120,
    gameModeReportHeight = 760,
    gameModeReports = {},
    -- Position of the temporary Save/Reset strip shown only in HUD Layout Mode.
    hudLayoutBarLeft = -1,
    hudLayoutBarTop = -1,
    combatRoleMode = "AUTO",
    rotationAssistantEnabled = true,
    rotationAssistantLeft = -1,
    rotationAssistantTop = -1,
    rotationAssistantWidth = 330,
    rotationAssistantHeight = 112,
    smartCoach = true,
    sessionMode = "CONTINUOUS",
    sessionMinutes = 60,
    sessionCustomMinutes = 90,
    sessionStartedAt = 0,
    combatPersonalBests = {},
    targetProfile = "AUTO",
    targetSet1 = "",
    targetSet2 = "",
    targetLootAlerts = true,
    lastCompatibilityNoticeApi = 0,
    utilityMode = "OVERVIEW",
    setJournalFilter = "ALL",
    utilityLootAlerts = true,
    utilityInventoryTracking = true,
    inventoryCharacters = {},
    sharedInventory = { items = {} },

    -- Group Finder Codex preferences
    groupFinderWidgetCategory = nil,
    groupFinderWidgetDifficulty = "NORMAL",
    groupFinderWidgetHideWTS = true,
    groupFinderWidgetHideHighCP = false,
    groupFinderWidgetLastBossHighlight = false,
    groupFinderWidgetBlacklist = {},

    -- Persistent HUD / unit frames. These are independent of the large suite window.
    showPlayerFrame = true,
    showTargetFrame = true,
    showGroupFrame = true,
    showRaidFrame = true,
    showCombatStatsFrame = true,
    showEnemyOverheadHealthBars = true,
    showOutgoingDamageNumbers = true,
    showCombatStatusEffects = true,

    -- Team visibility: native group markers plus optional 3D role-colored lights.
    teamVisibilityEnabled = true,
    teamVisibilityLightsEnabled = true,
    teamVisibilityThroughWalls = true,
    teamVisibilityBeamWidth = 3.55,
    teamVisibilityBeamHeight = 8.20,
    teamVisibilityOpacity = 0.24,
    teamVisibilityStyleVersion = 26,
    teamVisibilityCompanionColor = { r = 0.72, g = 0.38, b = 1.00 },
    teamVisibilityCompanionBeamWidth = 3.55,
    teamVisibilityCompanionBeamHeight = 8.20,
    teamVisibilityCompanionOpacity = 0.24,
    teamVisibilityCompanionThroughWalls = true,
    teamVisibilityDeadOpacity = 1.00,
    teamVisibilityPlayerOverrides = {},
    teamVisibilitySelectedGroupSlot = 1,

    -- Dungeon / Trial Chest Finder. Learns chest and Heavy Sack spawn points
    -- while the player encounters them inside supported instanced PvE content.
    dungeonChestFinderEnabled = true,
    dungeonChestShowPossible = false,
    dungeonChestShowHeavySacks = true,
    dungeonChestLearnLocations = true,
    dungeonChestThroughWalls = true,
    dungeonChestDistance = 120,
    dungeonChestMarkerScale = 1.0,
    dungeonChestGlowOpacity = 0.60,
    -- Keep this at 0 in defaults so SavedVars does not mask a missing migration
    -- flag from older builds. DungeonChestFinder upgrades and persists it to 3.
    dungeonChestGlowStyleVersion = 0,
    dungeonChestColor = { r = 1.00, g = 0.74, b = 0.14 },
    dungeonChestSackColor = { r = 0.62, g = 0.92, b = 0.52 },
    dungeonChestLocations = {},

    -- Suite-owned personal learning, bundled community resource data, and configurable 3D resource markers.
    resourcePinsEnabled = true,
    resourcePinsShow3D = true,
    resourcePinsLearn = true,
    resourcePinsCommunityEnabled = true,
    resourcePinsCommunityShowAll = true, -- full bundled database remains available; 3D output is dynamically culled
    resourcePinsThroughWalls = true,
    resourcePinsDistance = 200,
    resourcePinsMaxVisible = 72,
    resourcePinsSafeGlowFallback = false,
    resourcePinsPerformanceVersion = 3,
    resourcePinsScale = 1.0,
    resourcePinsOpacity = 0.72,
    resourcePinsSharpIcons = true,
    resourcePinsValueGlow = true,
    resourcePinsGlowStrength = 78,
    resourcePinsHideDepleted = true,
    resourcePinsDepletedCooldownMinutes = 5,
    resourcePinsDepleted = {},
    resourcePinsIconSize = 100,
    resourcePinsIconTintStrength = 85,
    resourcePinsShowOre = true,
    resourcePinsShowWood = true,
    resourcePinsShowCloth = true,
    resourcePinsShowAlchemy = true,
    resourcePinsShowRunes = true,
    resourcePinsShowWater = true,
    resourcePinsShowFishing = true,
    resourcePinsShowSpecial = true,
    resourcePinsShowOther = true,
    -- Farm Focus is a temporary target-only view. Normal resource filters are
    -- preserved underneath and resume when Farm Focus is disabled.
    resourcePinsFarmFocusEnabled = false,
    resourcePinsFarmOre = false,
    resourcePinsFarmWood = false,
    resourcePinsFarmCloth = false,
    resourcePinsFarmAlchemy = false,
    resourcePinsFarmRunes = false,
    resourcePinsFarmWater = false,
    resourcePinsFarmFishing = false,
    resourcePinsFarmSpecial = false,
    resourcePinsFarmOther = false,

    -- Antiquities: shovel navigation pins, an in-game Augur direction helper,
    -- and skill-line recommendations that account for rank and point costs.
    antiquityAssistantEnabled = true,
    antiquityShowWorldMap = true,
    antiquityShowMiniMap = true,
    antiquityShow3D = true,
    antiquityLearnExactDigSpots = true,
    antiquityKnownSpawnAssist = true,
    antiquityLearnedDigSpots = {},
    antiquity3DThroughWalls = true,
    antiquity3DRange = 1200,
    antiquity3DScale = 1.0,
    antiquityExcavationGuide = true,
    antiquityBonusLootGuide = true,
    -- Lead Finder: live ESO lead state combined with integrated source/location descriptions.
    antiquityLeadFinderEnabled = true,
    antiquityLeadFinderFilter = "CAN_FIND",
    antiquityLeadFinderCurrentZone = false,
    antiquityLeadFinderLeft = -1,
    antiquityLeadFinderTop = -1,
    antiquityLeadFinderWidth = 1180,
    antiquityLeadFinderHeight = 760,
    -- Movable Excavation UI positions. -1 keeps the built-in default anchor.
    antiquityGuideLeft = -1,
    antiquityGuideTop = -1,
    antiquityTilePickerLeft = -1,
    antiquityTilePickerTop = -1,
    resourcePinsIconMode = "SUITE_GLOW",
    resourcePinsIconOre = "AUTO",
    resourcePinsIconWood = "AUTO",
    resourcePinsIconCloth = "AUTO",
    resourcePinsIconAlchemy = "AUTO",
    resourcePinsIconRunes = "AUTO",
    resourcePinsIconWater = "AUTO",
    resourcePinsIconFishing = "AUTO",
    resourcePinsIconSpecial = "AUTO",
    resourcePinsIconOther = "AUTO",
    resourcePinLocations = {},

    -- Built-in error logger. It observes ESO's Lua error event instead of
    -- replacing the global handler, making it safe to run with other addons.
    bugCatcherEnabled = true,
    bugCatcherNotifyChat = true,
    bugCatcherSuppressPopup = false,
    bugCatcherMaxErrors = 40,
    bugCatcherUnread = 0,
    bugCatcherLog = {},
    unitFrameScale = 1.0, -- legacy shared scale
    playerFrameScale = 1.0,
    targetFrameScale = 1.0,
    playerFrameVisibility = "ALWAYS",
    targetFrameVisibility = "ALWAYS",
    groupFrameVisibility = "ALWAYS",
    raidFrameVisibility = "ALWAYS",
    combatStatsVisibility = "COMBAT",
    groupFrameScale = 1.0,
    combatStatsScale = 1.0,
    unitFrameAlpha = 0.94,
    unitFrameVisualStyle = "ESO_CLASSIC",
    unitFrameBackgrounds = false,
    unitFrameSoftBackground = true,
    unitFrameBackgroundAlpha = 0.72,
    hudDarkBackgroundMigrated = false,
    hudOverlayModesMigrated = false,
    playerFrameContextual = true,
    combatStatsCombatOnly = true,
    targetAuraCount = 5,
    playerAuraCount = 4, -- legacy setting retained for saved-variable compatibility; Player now shows all effects.
    hudHideInMenus = true,
    replaceDefaultUnitFrames = true,
    unitFrameReplacementMigrated02972 = false,
    playerFrameLeft = -1,
    playerFrameTop = -1,
    targetFrameLeft = -1,
    targetFrameTop = -1,
    groupFrameLeft = -1,
    groupFrameTop = -1,
    raidFrameLeft = -1,
    raidFrameTop = -1,
    statsFrameLeft = -1,
    statsFrameTop = -1,
    playerEffectsLeft = -1,
    playerEffectsTop = -1,

    -- Stable riding-training cooldown. 0 means the character can train again.
    showStableTimer = true,
    stableTimerVisibility = "ALWAYS",
    stableTimerLeft = -1,
    stableTimerTop = -1,

    -- Simple movable local clock overlay.
    showClock = true,
    clockVisibility = "ALWAYS",
    clockLeft = -1,
    clockTop = -1,

    -- Movable active quest/objective overlay.
    showActiveQuestOverlay = true,
    activeQuestVisibility = "ALWAYS",
    activeQuestLeft = -1,
    activeQuestTop = -1,
    activeQuestWidth = 420,
    activeQuestHeight = 160,
    selectedHudQuestIndex = nil,
    selectedHudQuestId = 0,
    selectedHudQuestName = "",
    selectedHudQuestSource = "",
    questTrackingSource = "ACTIVE_QUEST",
    activeHudQuestIndex = nil,
    activeHudQuestId = 0,
    activeHudQuestName = "",
    goldenHudQuestIndex = nil,
    goldenHudQuestId = 0,
    goldenHudQuestName = "",
    mainHudQuestIndex = nil,
    mainHudQuestId = 0,
    mainHudQuestName = "",

    -- Suite-owned Golden Pursuits HUD tracker. Display is independent from
    -- the authoritative quest-tracking/compass source.
    showGoldenPursuitsOverlay = true,
    goldenPursuitsVisibility = "ALWAYS",
    goldenPursuitsLeft = -1,
    goldenPursuitsTop = -1,
    goldenPursuitsWidth = 420,
    goldenPursuitsHeight = 140,
    goldenPursuitName = "",
    goldenPursuitQuestName = "",

    -- Movable ESO-style Alliance Rank overlay.
    showAllianceRank = true,
    allianceRankVisibility = "ALWAYS",
    allianceRankLeft = -1,
    allianceRankTop = -1,
    allianceRankScale = 1.0,

    -- Movable Character Level / XP overlay that automatically becomes the Champion Point overlay at level 50.
    showChampionOverlay = true,
    championOverlayVisibility = "ALWAYS",
    championOverlayLeft = -1,
    championOverlayTop = -1,

    -- Six independently movable active-hotbar overlays: skills 1-5 plus Ultimate.
    showAbilityOverlays = true,
    abilityOverlayVisibility = "ALWAYS",
    abilityOverlayScale = 1.0,
    abilityOverlaySize = 56,

    -- Movable quickslot item/food/potion overlay.
    showQuickslotOverlay = true,
    quickslotOverlayVisibility = "BEFORE_AND_DURING",
    quickslotOverlayLeft = -1,
    quickslotOverlayTop = -1,

    -- Suite-managed native Infinite Archive tracker (F5/title/progression).
    showInfiniteArchiveOverlay = true,
    infiniteArchiveOverlayLeft = -1,
    infiniteArchiveOverlayTop = -1,
    infiniteArchiveOverlayScale = 1.0,

    -- Optional Suite-owned reticle. DEFAULT restores ESO's native crosshair.
    customReticleEnabled = false,
    customReticleStyle = "RUNE",
    customReticleColor = "GOLD",
    customReticleSize = 100,
    customReticleOpacity = 0.95,

    -- Movable equipment repair/recharge estimate overlay.
    showRepairCostOverlay = true,
    repairCostVisibility = "INVENTORY",
    repairCostScale = 1.0,
    repairCostLeft = -1,
    repairCostTop = -1,
    repairCostCompactLeft = -1,
    repairCostCompactTop = -1,

    -- Small text-only reminders shown before the next combat encounter.
    showEncounterReminders = true,
    showEncounterRepairReminder = true,
    showEncounterPotionReminder = true,
    encounterReminderScale = 1.0, -- legacy migration fallback
    encounterReminderLeft = -1, -- legacy migration fallback
    encounterReminderTop = -1, -- legacy migration fallback
    encounterRepairScale = 1.0,
    encounterRepairLeft = -1,
    encounterRepairTop = -1,
    encounterRepairPreset = "CUSTOM",
    encounterPotionScale = 1.0,
    encounterPotionLeft = -1,
    encounterPotionTop = -1,
    encounterPotionPreset = "CUSTOM",

    -- Lightweight tile-based minimap. It follows the player map without replacing
    -- or skinning ESO's full World Map.
    showMiniMap = true,
    miniMapVisibility = "ALWAYS",
    miniMapLeft = -1,
    miniMapTop = -1,
    miniMapSize = 270,
    miniMapZoom = 0.90,
    miniMapAlpha = 0.92,
    miniMapMapAlpha = 0.86,
    miniMapShowQuest = true,
    miniMapShowWaypoint = true,
    miniMapShowWayshrines = true,
    miniMapShowGroup = true,
    miniMapShowCompanion = true,
    miniMapShowRally = true,
    miniMapShowPOIs = true,
    miniMapShowTrail = true,
    miniMapShowCoordinates = true,
    miniMapAdaptiveZoom = true,
    miniMapEdgeGuidance = true,
    miniMapPOIMax = 120,
    miniMapMode = "SMART",
    miniMapHideInMenus = true,
    gearOptimizerPreset = "TRIAL",
    questDiscoveryTarget = nil,

    -- Automatic equipped-gear maintenance. Consumables are only used below thresholds.
    autoMaintenance = true,
    autoRecharge = true,
    autoRepair = true,
    autoRechargeThreshold = 90,
    autoRepairThreshold = 90,
    autoMaintenanceOnCombatStart = true,
    autoMaintenanceOnCombatEnd = true,
    maintenanceNeverUseCrown = true,
    maintenanceMessages = true,

    -- Automatic Challenge Difficulty. Disabled by default so installing the Suite
    -- never changes ESO's native difficulty until the player opts in.
    overlandDifficultyEnabled = false,
    overlandDifficultyLevelingJourney = false,
    overlandDifficultyShowZoneLevelsMap = true,
    overlandDifficultyZoneMessages = false,
    overlandDifficultyPoiRadius = 85,
    overlandDifficultyOpenWorld = 0,
    overlandDifficultyDelve = 1,
    overlandDifficultyPublicDungeon = 2,
    overlandDifficultyWorldBoss = 2,
    overlandDifficultyWorldEvent = 2,
    overlandDifficultyDragon = 2,
    overlandDifficultyHistoryBoss = 2,
    overlandDifficultyHistoryBosses = false,
    overlandDifficultyCompanionEnabled = false,
    overlandDifficultyCompanion = 3,
    overlandDifficultyWorldBossHoldSeconds = 45,
    overlandDifficultyShowOverlay = true,
    overlandDifficultyShowDungeonOverlay = true,
    overlandDifficultyOverlayScale = 1.0,
    overlandDifficultyOverlayLeft = -1,
    overlandDifficultyOverlayTop = -1,
    overlandDifficultyZoneOverrides = {},
}

function EPC:Print(message)
    d(string.format("|cD9B55A[EAS]|r %s", tostring(message)))
end

function EPC:Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

function EPC:Safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h
end

local HUD_MENU_SCENES = {
    "gameMenuInGame", "inventory", "character", "skills", "championPerks",
    "journal", "collectionsBook", "groupMenu", "contacts", "guildHome",
    "mailInbox", "bank", "store", "tradingHouse", "crafting", "settings",
    "worldMap", "gamepad_worldMap", "gamepad_inventory_root",
    "gamepad_character_root", "gamepad_skills_root", "gamepad_journal_root",
    "gamepad_collections_book", "gamepad_group_root", "gamepad_options_root",
    "gamepad_player_menu", "gamepad_main_menu", "gamepad_championPerks_root",
    "gamepad_store", "gamepad_banking", "gamepad_trading_house",
    "gamepad_mail_manager", "gamepad_guild_hub", "gamepad_contacts_root",
}

local function sceneShowing(scene)
    if scene and type(scene.IsShowing) == "function" then
        local ok, showing = pcall(scene.IsShowing, scene)
        return ok and showing == true
    end
    return false
end

-- Persistent EPC HUD elements are gameplay-only.  Move/layout modes and the
-- addon's own interaction mode are intentionally exempt so users can still
-- position frames and interact with the suite.
function EPC:IsGameplayHudSuppressed()
    -- Real ESO menu scenes own the screen. Check them before EPC-owned mouse
    -- modes so Pause, Character, Inventory, Journal, Settings, and the full Map
    -- always force-hide every EPC gameplay element.
    if sceneShowing(WORLD_MAP_SCENE) or sceneShowing(GAMEPAD_WORLD_MAP_SCENE) then return true end

    if self.saved == nil or self.saved.hudHideInMenus ~= false then
        if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
            for i = 1, #HUD_MENU_SCENES do
                local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, HUD_MENU_SCENES[i])
                if ok and showing == true then return true end
            end
        end
    end

    -- EPC-owned interaction/layout modes are only exempt when no real ESO menu
    -- scene is open. This still allows slash-command dragging during gameplay.
    if self.unitFramesMoveMode or self.miniMapMoveMode or self.combatHudMoveMode or self.interactionMode then
        return false
    end

    if self.saved and self.saved.hudHideInMenus == false then return false end

    if type(IsGameCameraUIModeActive) == "function" then
        local ok, active = pcall(IsGameCameraUIModeActive)
        if ok and active == true then return true end
    end
    return false
end

-- Returns whether persistent Suite HUD readouts may be visible in the current
-- gameplay scene. Idle/automatic HUD fading is intentionally NOT inferred from
-- action-bar alpha: that proved unreliable across UI modes. Readouts that must
-- follow ESO's automatic HUD fade attach a ZO_HUDFadeSceneFragment instead.
function EPC:IsPersistentGameplayHudVisible()
    if self.unitFramesMoveMode or self.miniMapMoveMode or self.combatHudMoveMode then return true end
    if self.IsGameplayHudSuppressed and self:IsGameplayHudSuppressed() == true then return false end
    return true
end

function EPC:CreateHudFadeFragment(control)
    if not control or not ZO_HUDFadeSceneFragment or type(ZO_HUDFadeSceneFragment.New) ~= "function" then return nil end
    local ok, fragment = pcall(function()
        -- The third parameter is explicitly 0; ESOUI's HUD-fade fragment expects
        -- it and this avoids the UI fade errors seen with incomplete arguments.
        return ZO_HUDFadeSceneFragment:New(control, nil, 0)
    end)
    if not ok or not fragment then return nil end
    local added = false
    if HUD_SCENE and type(HUD_SCENE.AddFragment) == "function" then
        pcall(HUD_SCENE.AddFragment, HUD_SCENE, fragment)
        added = true
    end
    if HUD_UI_SCENE and HUD_UI_SCENE ~= HUD_SCENE and type(HUD_UI_SCENE.AddFragment) == "function" then
        pcall(HUD_UI_SCENE.AddFragment, HUD_UI_SCENE, fragment)
        added = true
    end
    return added and fragment or nil
end

function EPC:OverlayModeAllows(modeKey)
    -- Layout modes always preview HUD elements so users can position them even
    -- when a Combat Only overlay would normally be hidden.
    if self.unitFramesMoveMode or self.miniMapMoveMode or self.combatHudMoveMode then return true end
    local mode = self.saved and self.saved[modeKey] or "ALWAYS"
    if mode == "COMBAT" then
        return self:Safe(IsUnitInCombat, false, "player") == true
    elseif mode == "BEFORE_ONLY" or mode == "OUT_OF_COMBAT" then
        -- Before Combat Only: visible while preparing, hidden once combat starts.
        -- OUT_OF_COMBAT is retained as a legacy alias.
        return self:Safe(IsUnitInCombat, false, "player") ~= true
    elseif mode == "BEFORE_AND_DURING" or mode == "BEFORE_COMBAT" then
        -- Keep it visible through the transition into combat. BEFORE_COMBAT is
        -- retained as a legacy value and now follows the requested combined mode.
        return true
    end
    return true
end

function EPC:RefreshGameplayOverlays()
    if self.UnitFrames and self.UnitFrames.RefreshAll then self.UnitFrames:RefreshAll(true) end
    if self.MiniMap and self.MiniMap.Refresh then self.MiniMap:Refresh(true) end
    if self.StableTimer and self.StableTimer.Refresh then self.StableTimer:Refresh() end
    if self.Clock and self.Clock.Refresh then self.Clock:Refresh() end
    if self.ActiveQuest and self.ActiveQuest.Refresh then self.ActiveQuest:Refresh() end
    if self.GoldenPursuits and self.GoldenPursuits.RefreshVisibility2496 then self.GoldenPursuits:RefreshVisibility2496() end
    if self.AllianceRank and self.AllianceRank.Refresh then self.AllianceRank:Refresh() end
    if self.ChampionOverlay and self.ChampionOverlay.Refresh then self.ChampionOverlay:Refresh() end
    if self.AbilityOverlays and self.AbilityOverlays.Refresh then self.AbilityOverlays:Refresh() end
    if self.QuickslotOverlay and self.QuickslotOverlay.Refresh then self.QuickslotOverlay:Refresh() end
    if self.InfiniteArchiveOverlay and self.InfiniteArchiveOverlay.Refresh then self.InfiniteArchiveOverlay:Refresh() end
    if self.RepairCostOverlay and self.RepairCostOverlay.Refresh then self.RepairCostOverlay:Refresh() end
    if self.PerformanceOverlay and self.PerformanceOverlay.Refresh then self.PerformanceOverlay:Refresh(true) end
    if self.EncounterReminders and self.EncounterReminders.Refresh then self.EncounterReminders:Refresh() end
    if self.ChallengeDifficultyOverlay and self.ChallengeDifficultyOverlay.Refresh then self.ChallengeDifficultyOverlay:Refresh() end
    if self.Travel and self.Travel.RefreshMapTeleporterVisibility then self.Travel:RefreshMapTeleporterVisibility() end
    if self.UI and self.UI.UpdateCombatHUD and self.Combat then self.UI:UpdateCombatHUD(self.Combat:GetHUDSummary()) end
end

function EPC:RequestRefresh(reason)
    self.refreshPending = true
    self.refreshReason = reason or "event"
end

function EPC:SetEnabled(enabled, reason)
    if not self.saved or not self.UI then return end
    enabled = enabled == true
    if not enabled and self.interactionMode then
        self:SetInteractionMode(false, "hide")
    end
    self.saved.enabled = enabled
    self.UI:SetVisible(enabled)
    if enabled then self:RefreshNow(reason or "show") end
end

function EPC:ToggleVisibility(reason)
    if not self.saved then return end
    self:SetEnabled(not self.saved.enabled, reason or "toggle")
end

local function setCameraUIMode(active)
    -- Prefer ESO's direct camera UI-mode API so HUD controls reliably receive mouse input.
    if type(SetGameCameraUIMode) == "function" then
        local ok = pcall(SetGameCameraUIMode, active)
        if ok then return true end
    end
    if SCENE_MANAGER and type(SCENE_MANAGER.SetInUIMode) == "function" then
        return pcall(function() SCENE_MANAGER:SetInUIMode(active) end)
    end
    return false
end

function EPC:SetInteractionMode(active, reason)
    if not self.saved or not self.UI then return end
    active = active == true


    if active then
        if not self.saved.enabled then
            self.saved.enabled = true
            self.UI:SetVisible(true)
        end
        if self.saved.autoExpandInteract ~= false and self.saved.minimized then
            self.saved.minimized = false
            self.UI:ApplyMinimizedState()
        end

        local alreadyInUIMode = self:Safe(IsGameCameraUIModeActive, false) == true
        self.interactionOwned = not alreadyInUIMode
        if not alreadyInUIMode then
            setCameraUIMode(true)
        end
        self.interactionMode = true
        self:RefreshNow(reason or "interact-enter")
    else
        self.interactionMode = false
        if self.interactionOwned then
            setCameraUIMode(false)
        end
        self.interactionOwned = false
        if self.UI.ApplyInteractionMode then self.UI:ApplyInteractionMode(false) end
    end
end

function EPC:ToggleInteractionMode()
    if self.combatHudMoveMode then
        self:SetCombatHUDMoveMode(false)
        return
    end
    if self.miniMapMoveMode then
        self:SetMiniMapMoveMode(false)
        return
    end
    if self.unitFramesMoveMode then
        -- Full HUD Layout Mode is intentionally sticky.  The normal Suite
        -- interaction key must never dismiss it; SAVE & EXIT is the sole
        -- in-addon exit path so a stray key press cannot lose the layout.
        self:SetHUDLayoutControlBarVisible(true)
        self:RaiseLayoutOverlays()
        self:Print("HUD Layout Mode is still active. Use SAVE & EXIT when you are finished.")
        return
    end
    self:SetInteractionMode(not self.interactionMode, "interact-keybind")
end

function EPC:SetCombatHUDMoveMode(active)
    if not self.saved or not self.UI or not self.UI.SetCombatHUDMoveMode then return end
    active = active == true

    if active then
        local alreadyInUIMode = self:Safe(IsGameCameraUIModeActive, false) == true
        self.combatHudMoveOwned = not alreadyInUIMode
        if not alreadyInUIMode then setCameraUIMode(true) end
        self.combatHudMoveMode = true
        self.saved.combatHudLocked = false
        self.UI:SetCombatHUDMoveMode(true)
        self:Print("Combat HUD unlocked. Drag it anywhere, then use /esosuite hud lock.")
    else
        self.combatHudMoveMode = false
        self.saved.combatHudLocked = true
        self.UI:SetCombatHUDMoveMode(false)
        if self.combatHudMoveOwned and not self.interactionMode and not self.unitFramesMoveMode and not self.miniMapMoveMode then setCameraUIMode(false) end
        self.combatHudMoveOwned = false
        self:Print("Combat HUD locked.")
    end
end

function EPC:ResetCombatHUDPosition()
    if not self.saved or not self.UI or not self.UI.ResetCombatHUDPosition then return end
    self.saved.combatHudLeft = -1
    self.saved.combatHudTop = -1
    self.UI:ResetCombatHUDPosition()
    self:Print("Combat HUD position reset to the upper-right.")
end

function EPC:RaiseLayoutOverlays()
    if not self.unitFramesMoveMode then return end

    local function raiseLayoutControls(root, seen, depth)
        if type(root) ~= "table" or depth > 2 or seen[root] then return end
        seen[root] = true

        if type(root.RaiseForLayout) == "function" then
            pcall(root.RaiseForLayout, root)
        end

        for _, value in pairs(root) do
            if type(value) == "userdata" then
                pcall(function()
                    -- Only raise actual top-level/root windows here. Child
                    -- labels/backdrops must keep their own draw levels or the
                    -- background can wind up covering the text.
                    local parent = value.GetParent and value:GetParent() or nil
                    local isRootWindow = (parent == nil or parent == GuiRoot)
                    if isRootWindow and value ~= GuiRoot then
                        if value.SetTopLevel then value:SetTopLevel(true) end
                        if value.SetDrawLayer and DL_OVERLAY then value:SetDrawLayer(DL_OVERLAY) end
                        if value.SetDrawTier and DT_HIGH then value:SetDrawTier(DT_HIGH) end
                        if value.SetDrawLevel then value:SetDrawLevel(900) end
                        if value.BringWindowToTop then value:BringWindowToTop() end
                    end
                end)
            elseif type(value) == "table" then
                raiseLayoutControls(value, seen, depth + 1)
            end
        end
    end

    local seen = {}
    for _, module in ipairs({
        self.UnitFrames, self.MiniMap, self.StableTimer, self.Clock,
        self.ActiveQuest, self.GoldenPursuits, self.AllianceRank,
        self.ChampionOverlay, self.AbilityOverlays, self.QuickslotOverlay,
        self.InfiniteArchiveOverlay, self.RepairCostOverlay, self.PerformanceOverlay, self.EncounterReminders,
        self.ChallengeDifficultyOverlay, self.DungeonFinder,
        self.SynergyOverlay, self.RotationAssistant, self.AntiquityAssistant
    }) do
        if module then raiseLayoutControls(module, seen, 0) end
    end
    -- Travel is a large data/service table, so do not recursively scan it every
    -- 250ms during layout mode. Raise only its Teleporter root explicitly.
    if self.Travel and self.Travel.RaiseForLayout then pcall(self.Travel.RaiseForLayout, self.Travel) end
    if self.hudLayoutControlBar and not self.hudLayoutControlBar:IsHidden() then
        self.hudLayoutControlBar:SetDrawTier(DT_HIGH)
        self.hudLayoutControlBar:SetDrawLevel(2000)
    end
end

-- HUD Layout Mode control strip.  It intentionally lives outside LibAddonMenu
-- so Settings can close completely while every movable Suite overlay remains
-- visible and interactive.
function EPC:EnsureHUDLayoutControlBar()
    if self.hudLayoutControlBar then return self.hudLayoutControlBar end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local wm = WINDOW_MANAGER
    local bar = wm:CreateTopLevelWindow("EAS_HUDLayoutControlBar02959")
    bar:SetDimensions(420, 82)
    bar:SetDrawLayer(DL_OVERLAY)
    bar:SetDrawTier(DT_HIGH)
    bar:SetDrawLevel(2000)
    bar:SetClampedToScreen(true)
    bar:SetMouseEnabled(true)
    bar:SetMovable(true)
    bar:SetHidden(true)

    -- Restore the user's preferred position.  A negative coordinate means the
    -- strip has never been moved and should use the safe top-center default.
    local savedLeft = self.saved and tonumber(self.saved.hudLayoutBarLeft) or -1
    local savedTop = self.saved and tonumber(self.saved.hudLayoutBarTop) or -1
    bar:ClearAnchors()
    if savedLeft and savedTop and savedLeft >= 0 and savedTop >= 0 then
        bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedLeft, savedTop)
    else
        bar:SetAnchor(TOP, GuiRoot, TOP, 0, 22)
    end

    -- The entire empty/title area can be dragged. Buttons remain normal click
    -- targets because they sit above the parent and consume their own mouse input.
    bar:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and control.StartMoving then
            control:StartMoving()
        end
    end)
    bar:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and control.StopMoving then
            control:StopMoving()
        end
    end)
    bar:SetHandler("OnMoveStop", function(control)
        if control.StopMoving then control:StopMoving() end
        if EPC and EPC.saved then
            EPC.saved.hudLayoutBarLeft = control:GetLeft()
            EPC.saved.hudLayoutBarTop = control:GetTop()
        end
    end)

    local bg = wm:CreateControl(nil, bar, CT_BACKDROP)
    bg:SetAnchorFill(bar)
    bg:SetCenterColor(0.015, 0.020, 0.028, 0.97)
    bg:SetEdgeColor(0.72, 0.52, 0.12, 0.95)
    if bg.SetEdgeTexture then
        bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 16, 1)
    end

    local title = wm:CreateControl(nil, bar, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetText("HUD LAYOUT MODE  •  DRAG TO MOVE")
    title:SetColor(1.0, 0.82, 0.28, 1.0)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetAnchor(TOPLEFT, bar, TOPLEFT, 12, 7)
    title:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -12, 7)
    title:SetHeight(22)

    -- Dedicated full-width drag handle. The previous build relied on clicks
    -- reaching the top-level parent; child controls could swallow those clicks,
    -- making the Save/Reset overlay appear immovable. This invisible handle sits
    -- over the entire title strip and always moves the parent bar.
    local dragHandle = wm:CreateControl(nil, bar, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(TOPRIGHT, bar, TOPRIGHT, 0, 0)
    dragHandle:SetHeight(34)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and bar.StartMoving then
            bar:StartMoving()
        end
    end)
    dragHandle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and bar.StopMoving then
            bar:StopMoving()
            if EPC and EPC.saved then
                EPC.saved.hudLayoutBarLeft = bar:GetLeft()
                EPC.saved.hudLayoutBarTop = bar:GetTop()
            end
        end
    end)
    bar.dragHandle = dragHandle

    local function makeButton(name, label, left, width, callback)
        local button = wm:CreateControl(name, bar, CT_BUTTON)
        button:SetDimensions(width, 36)
        button:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, left, -10)
        button:SetFont("ZoFontGameBold")
        button:SetText(label)
        button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        button:SetNormalFontColor(0.93, 0.93, 0.93, 1.0)
        button:SetMouseOverFontColor(1.0, 0.84, 0.32, 1.0)
        button:SetPressedFontColor(0.78, 0.62, 0.22, 1.0)

        local buttonBg = wm:CreateControl(nil, button, CT_BACKDROP)
        buttonBg:SetAnchorFill(button)
        buttonBg:SetCenterColor(0.045, 0.060, 0.080, 0.98)
        buttonBg:SetEdgeColor(0.38, 0.48, 0.60, 0.90)
        if buttonBg.SetEdgeTexture then
            buttonBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 16, 1)
        end
        buttonBg:SetMouseEnabled(false)
        button:SetHandler("OnClicked", callback)
        return button
    end

    bar.saveButton = makeButton("EAS_HUDLayoutSaveExit02959", "SAVE & EXIT", 12, 190, function()
        if EPC and EPC.SetUnitFramesMoveMode then EPC:SetUnitFramesMoveMode(false, "save-exit") end
    end)
    bar.resetButton = makeButton("EAS_HUDLayoutReset02959", "RESET LAYOUT", 218, 190, function()
        if EPC and EPC.ResetUnitFramePositions then
            EPC:ResetUnitFramePositions()
            if EPC.RaiseLayoutOverlays then EPC:RaiseLayoutOverlays() end
            if EPC.hudLayoutControlBar then
                EPC.hudLayoutControlBar:SetHidden(false)
                EPC.hudLayoutControlBar:SetDrawTier(DT_HIGH)
                EPC.hudLayoutControlBar:SetDrawLevel(2000)
            end
        end
    end)

    self.hudLayoutControlBar = bar
    return bar
end

function EPC:SetHUDLayoutControlBarVisible(visible)
    local bar = self:EnsureHUDLayoutControlBar()
    if not bar then return end
    bar:SetHidden(visible ~= true)
    if visible == true then
        bar:SetDrawTier(DT_HIGH)
        bar:SetDrawLevel(2000)
    end
end

function EPC:IsSettingsSceneShowingForHUDLayout()
    if not SCENE_MANAGER or type(SCENE_MANAGER.IsShowing) ~= "function" then return false end
    local names = { "settings", "gameMenuInGame", "gameMenu" }
    for i = 1, #names do
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, names[i])
        if ok and showing == true then return true end
    end
    return false
end

function EPC:CloseSettingsSceneForHUDLayout()
    -- Prefer the Suite's existing LibAddonMenu bridge cleanup when available.
    if self.ModernAppUI and self.ModernAppUI.CloseSettingsSceneForSuite02943 then
        local ok, closed = pcall(self.ModernAppUI.CloseSettingsSceneForSuite02943, self.ModernAppUI)
        if ok and closed == true then return true end
    end
    if not SCENE_MANAGER then return false end
    if type(SCENE_MANAGER.HideCurrentScene) == "function" then
        local ok = pcall(SCENE_MANAGER.HideCurrentScene, SCENE_MANAGER)
        if ok then return true end
    end
    if type(SCENE_MANAGER.Hide) == "function" then
        pcall(SCENE_MANAGER.Hide, SCENE_MANAGER, "settings")
        pcall(SCENE_MANAGER.Hide, SCENE_MANAGER, "gameMenuInGame")
        pcall(SCENE_MANAGER.Hide, SCENE_MANAGER, "gameMenu")
        return true
    end
    return false
end

function EPC:SetUnitFramesMoveMode(active, exitReason)
    if not self.saved then return end
    local canFrames = self.UnitFrames and self.UnitFrames.SetLayoutMode
    local canMiniMap = self.MiniMap and self.MiniMap.SetLayoutMode
    local canStableTimer = self.StableTimer and self.StableTimer.SetLayoutMode
    local canClock = self.Clock and self.Clock.SetLayoutMode
    local canActiveQuest = self.ActiveQuest and self.ActiveQuest.SetLayoutMode
    local canGoldenPursuits = self.GoldenPursuits and self.GoldenPursuits.SetLayoutMode
    local canAllianceRank = self.AllianceRank and self.AllianceRank.SetLayoutMode
    local canChampionOverlay = self.ChampionOverlay and self.ChampionOverlay.SetLayoutMode
    local canAbilities = self.AbilityOverlays and self.AbilityOverlays.SetLayoutMode
    local canQuickslot = self.QuickslotOverlay and self.QuickslotOverlay.SetLayoutMode
    local canInfiniteArchive = self.InfiniteArchiveOverlay and self.InfiniteArchiveOverlay.SetLayoutMode
    local canRepairCosts = self.RepairCostOverlay and self.RepairCostOverlay.SetLayoutMode
    local canPerformanceOverlay = self.PerformanceOverlay and self.PerformanceOverlay.SetLayoutMode
    local canEncounterReminders = self.EncounterReminders and self.EncounterReminders.SetLayoutMode
    local canChallengeOverlay = self.ChallengeDifficultyOverlay and self.ChallengeDifficultyOverlay.SetLayoutMode
    local canDungeonQueue = self.DungeonFinder and self.DungeonFinder.SetLayoutMode
    local canSynergy = self.SynergyOverlay and self.SynergyOverlay.SetLayoutMode
    local canRotationAssistant = self.RotationAssistant and self.RotationAssistant.SetLayoutMode
    local canAntiquityAssistant = self.AntiquityAssistant and self.AntiquityAssistant.SetLayoutMode
    local canMapTeleporter = self.Travel and self.Travel.SetLayoutMode
    if not canFrames and not canMiniMap and not canStableTimer and not canClock and not canActiveQuest and not canGoldenPursuits and not canAllianceRank and not canChampionOverlay and not canAbilities and not canQuickslot and not canInfiniteArchive and not canRepairCosts and not canPerformanceOverlay and not canEncounterReminders and not canChallengeOverlay and not canDungeonQueue and not canSynergy and not canRotationAssistant and not canAntiquityAssistant and not canMapTeleporter then return end
    active = active == true

    -- Once full HUD Layout Mode is active, only its SAVE & EXIT button is
    -- allowed to shut it down.  Slash commands, Settings buttons, ESC/UI-mode
    -- changes, and other Suite interaction paths are deliberately ignored.
    if not active and self.unitFramesMoveMode and exitReason ~= "save-exit" then
        self:SetHUDLayoutControlBarVisible(true)
        self:RaiseLayoutOverlays()
        self:Print("HUD Layout Mode remains active. Press SAVE & EXIT to return to gameplay.")
        return false
    end

    -- LibAddonMenu lives inside the game-menu scene. Closing that scene after
    -- layout mode has already started makes ESO leave camera UI mode and can
    -- instantly lock every overlay again. Close Settings first, then start
    -- layout mode after the normal HUD has returned.
    if active and not self.unitFramesMoveMode and not self.hudLayoutStartPending02959 and self:IsSettingsSceneShowingForHUDLayout() then
        self.hudLayoutStartPending02959 = true
        self.hudLayoutCloseAttempts02959 = (tonumber(self.hudLayoutCloseAttempts02959) or 0) + 1
        self:CloseSettingsSceneForHUDLayout()
        local function startAfterSettingsClose()
            if not EPC then return end
            EPC.hudLayoutStartPending02959 = false
            if EPC:IsSettingsSceneShowingForHUDLayout() and (tonumber(EPC.hudLayoutCloseAttempts02959) or 0) < 4 then
                EPC:SetUnitFramesMoveMode(true)
                return
            end
            EPC.hudLayoutCloseAttempts02959 = 0
            -- If ESO is still finishing its scene transition, forcing camera UI
            -- mode here keeps the layout controls interactive.
            EPC:SetUnitFramesMoveMode(true)
        end
        if type(zo_callLater) == "function" then zo_callLater(startAfterSettingsClose, 140) else startAfterSettingsClose() end
        return
    end
    if not active then self.hudLayoutCloseAttempts02959 = 0 end

    if active then
        -- If the Suite's modern settings/page shell is open, hide it as well.
        -- HUD Layout Mode should leave only the movable overlays plus its own
        -- compact Save/Reset control strip on screen.
        if self.ModernAppUI and self.ModernAppUI.window and self.ModernAppUI.Hide then
            local ok, hidden = pcall(self.ModernAppUI.window.IsHidden, self.ModernAppUI.window)
            if ok and hidden == false then pcall(self.ModernAppUI.Hide, self.ModernAppUI) end
        end
        if self.miniMapMoveMode then self:SetMiniMapMoveMode(false) end
        local alreadyInUIMode = self:Safe(IsGameCameraUIModeActive, false) == true
        self.unitFramesMoveOwned = not alreadyInUIMode
        if not alreadyInUIMode then setCameraUIMode(true) end
        self.unitFramesMoveMode = true
        if canFrames then self.UnitFrames:SetLayoutMode(true) end
        if canMiniMap then self.MiniMap:SetLayoutMode(true) end
        if canStableTimer then self.StableTimer:SetLayoutMode(true) end
        if canClock then self.Clock:SetLayoutMode(true) end
        if canActiveQuest then self.ActiveQuest:SetLayoutMode(true) end
        if canGoldenPursuits then self.GoldenPursuits:SetLayoutMode(true) end
        if canAllianceRank then self.AllianceRank:SetLayoutMode(true) end
        if canChampionOverlay then self.ChampionOverlay:SetLayoutMode(true) end
        if canAbilities then self.AbilityOverlays:SetLayoutMode(true) end
        if canQuickslot then self.QuickslotOverlay:SetLayoutMode(true) end
        if canInfiniteArchive then self.InfiniteArchiveOverlay:SetLayoutMode(true) end

        if canRepairCosts then self.RepairCostOverlay:SetLayoutMode(true) end
        if canPerformanceOverlay then self.PerformanceOverlay:SetLayoutMode(true) end
        if canEncounterReminders then self.EncounterReminders:SetLayoutMode(true) end
        if canChallengeOverlay then self.ChallengeDifficultyOverlay:SetLayoutMode(true) end
        if canDungeonQueue then self.DungeonFinder:SetLayoutMode(true) end
        if canSynergy then self.SynergyOverlay:SetLayoutMode(true) end
        if canRotationAssistant then self.RotationAssistant:SetLayoutMode(true) end
        if canAntiquityAssistant then self.AntiquityAssistant:SetLayoutMode(true) end
        if canMapTeleporter then self.Travel:SetLayoutMode(true) end

        self:SetHUDLayoutControlBarVisible(true)

        -- Raise only after every overlay has been unhidden.  LibAddonMenu can
        -- otherwise reclaim z-order when a hidden overlay becomes visible.
        self:RaiseLayoutOverlays()
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "_LayoutOverlayRaiseGuard")
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_LayoutOverlayRaiseGuard", 250, function()
            if EPC.unitFramesMoveMode then
                EPC:RaiseLayoutOverlays()
                -- ESO can re-apply compass visibility during camera UI-mode scene
                -- updates. Keep the stock compass exposed throughout layout mode.
                if EPC.MiniMap and EPC.MiniMap.SyncESOCompassVisibility then
                    EPC.MiniMap:SyncESOCompassVisibility()
                end
            else
                EVENT_MANAGER:UnregisterForUpdate(EPC.name .. "_LayoutOverlayRaiseGuard")
            end
        end)

        self:Print("HUD layout mode enabled. Settings are hidden. Move/resize your overlays, then press SAVE & EXIT at the top of the screen. RESET LAYOUT restores the default HUD positions without leaving layout mode.")
    else
        self.unitFramesMoveMode = false
        self.hudLayoutStartPending02959 = false
        self:SetHUDLayoutControlBarVisible(false)
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "_LayoutOverlayRaiseGuard")
        if canFrames then self.UnitFrames:SetLayoutMode(false) end
        if canMiniMap then self.MiniMap:SetLayoutMode(false) end
        if canStableTimer then self.StableTimer:SetLayoutMode(false) end
        if canClock then self.Clock:SetLayoutMode(false) end
        if canActiveQuest then self.ActiveQuest:SetLayoutMode(false) end
        if canGoldenPursuits then self.GoldenPursuits:SetLayoutMode(false) end
        if canAllianceRank then self.AllianceRank:SetLayoutMode(false) end
        if canChampionOverlay then self.ChampionOverlay:SetLayoutMode(false) end
        if canAbilities then self.AbilityOverlays:SetLayoutMode(false) end
        if canQuickslot then self.QuickslotOverlay:SetLayoutMode(false) end
        if canInfiniteArchive then self.InfiniteArchiveOverlay:SetLayoutMode(false) end
        if canRepairCosts then self.RepairCostOverlay:SetLayoutMode(false) end
        if canPerformanceOverlay then self.PerformanceOverlay:SetLayoutMode(false) end
        if canEncounterReminders then self.EncounterReminders:SetLayoutMode(false) end
        if canChallengeOverlay then self.ChallengeDifficultyOverlay:SetLayoutMode(false) end
        if canDungeonQueue then self.DungeonFinder:SetLayoutMode(false) end
        if canRotationAssistant then self.RotationAssistant:SetLayoutMode(false) end
        if canAntiquityAssistant then self.AntiquityAssistant:SetLayoutMode(false) end
        if canMapTeleporter then self.Travel:SetLayoutMode(false) end
        if self.unitFramesMoveOwned and not self.interactionMode and not self.combatHudMoveMode and not self.miniMapMoveMode then setCameraUIMode(false) end
        if canSynergy then self.SynergyOverlay:SetLayoutMode(false) end
        -- Apply normal compass/menu visibility immediately after leaving layout
        -- preview instead of waiting for the minimap's next periodic refresh.
        if self.MiniMap and self.MiniMap.SyncESOCompassVisibility then
            self.MiniMap:SyncESOCompassVisibility()
        end
        self.unitFramesMoveOwned = false
        self:Print("HUD unit frames locked.")
    end
end

function EPC:SetMiniMapMoveMode(active)
    if not self.saved or not self.MiniMap or not self.MiniMap.SetLayoutMode then return end
    active = active == true

    if active then
        -- Dedicated Mini Map layout mode is unnecessary while the full HUD
        -- layout is active. Keep the sticky full-layout session instead of
        -- allowing this path to end it.
        if self.unitFramesMoveMode then
            self:SetHUDLayoutControlBarVisible(true)
            self:RaiseLayoutOverlays()
            return
        end
        local alreadyInUIMode = self:Safe(IsGameCameraUIModeActive, false) == true
        self.miniMapMoveOwned = not alreadyInUIMode
        if not alreadyInUIMode then setCameraUIMode(true) end
        self.miniMapMoveMode = true
        self.saved.showMiniMap = true
        self.MiniMap:SetLayoutMode(true)
        self:Print("Mini Map unlocked. Drag it anywhere, then use /esosuite minimap lock or press the Interact with Suite keybind.")
    else
        self.miniMapMoveMode = false
        self.MiniMap:SetLayoutMode(false)
        if self.miniMapMoveOwned and not self.interactionMode and not self.combatHudMoveMode and not self.unitFramesMoveMode then
            setCameraUIMode(false)
        end
        self.miniMapMoveOwned = false
        self:Print("Mini Map locked. Position saved.")
    end
end

function EPC:ResetMiniMapPosition()
    if not self.MiniMap or not self.MiniMap.ResetPosition then return end
    self.MiniMap:ResetPosition()
    self.MiniMap:Refresh(true)
    self:Print("Mini Map position reset to the upper-right.")
end

function EPC:ResetUnitFramePositions()
    if self.UnitFrames and self.UnitFrames.ResetPositions then
        self.UnitFrames:ResetPositions()
        self.UnitFrames:RefreshAll(true)
    end
    if self.MiniMap and self.MiniMap.ResetPosition then
        self.MiniMap:ResetPosition()
        self.MiniMap:Refresh(true)
    end
    if self.StableTimer and self.StableTimer.ResetPosition then
        self.StableTimer:ResetPosition()
        self.StableTimer:Refresh()
    end
    if self.Clock and self.Clock.ResetPosition then
        self.Clock:ResetPosition()
        self.Clock:Refresh()
    end
    if self.ChampionOverlay and self.ChampionOverlay.ResetPosition then
        self.ChampionOverlay:ResetPosition()
        self.ChampionOverlay:Refresh()
    end
    if self.ActiveQuest and self.ActiveQuest.ResetPosition then
        self.ActiveQuest:ResetPosition()
        self.ActiveQuest:Refresh()
    end
    if self.GoldenPursuits and self.GoldenPursuits.ResetPosition then
        self.GoldenPursuits:ResetPosition()
    end
    if self.AllianceRank and self.AllianceRank.ResetPosition then
        self.AllianceRank:ResetPosition()
        self.AllianceRank:Refresh()
    end
    if self.AbilityOverlays and self.AbilityOverlays.ResetPositions then
        self.AbilityOverlays:ResetPositions()
        self.AbilityOverlays:Refresh()
    end
    if self.QuickslotOverlay and self.QuickslotOverlay.ResetPosition then
        self.QuickslotOverlay:ResetPosition()
        self.QuickslotOverlay:Refresh()
    end
    if self.InfiniteArchiveOverlay and self.InfiniteArchiveOverlay.ResetPosition then
        self.InfiniteArchiveOverlay:ResetPosition()
    end
    if self.RepairCostOverlay and self.RepairCostOverlay.ResetPosition then
        self.RepairCostOverlay:ResetPosition()
        self.RepairCostOverlay:Refresh()
    end
    if self.PerformanceOverlay and self.PerformanceOverlay.ResetPosition then
        self.PerformanceOverlay:ResetPosition()
        self.PerformanceOverlay:Refresh(true)
    end
    if self.EncounterReminders and self.EncounterReminders.ResetPosition then
        self.EncounterReminders:ResetPosition()
    end
    if self.ChallengeDifficultyOverlay and self.ChallengeDifficultyOverlay.ResetPosition then
        self.ChallengeDifficultyOverlay:ResetPosition()
    end
    if self.SynergyOverlay and self.SynergyOverlay.ResetPosition then
        self.SynergyOverlay:ResetPosition()
    end
    if self.RotationAssistant and self.RotationAssistant.ResetPosition then
        self.RotationAssistant:ResetPosition()
        self.RotationAssistant:Refresh()
    end
    if self.AntiquityAssistant and self.AntiquityAssistant.ResetPositions then
        self.AntiquityAssistant:ResetPositions()
    end
    if self.Travel and self.Travel.ResetMapTeleporterPosition then
        self.Travel:ResetMapTeleporterPosition()
    end
    self:Print("HUD layout reset: Player, Target, Group, Raid, Stats, Mini Map, Stable, Clock, Active Quest, Golden Pursuits, Alliance Rank, Champion, Infinite Archive, Repair Estimate, FPS/Latency, Encounter Reminders, Challenge Difficulty, Use Synergy, Rotation Assistant, Augur Guide, Tile Selector, Map Teleporter, and Ability positions restored.")
end

function ESOProgressionCoach_Toggle()
    if ESOProgressionCoach and ESOProgressionCoach.Journal and ESOProgressionCoach.Journal.Toggle then
        ESOProgressionCoach.Journal:Toggle()
    elseif ESOProgressionCoach and ESOProgressionCoach.ToggleVisibility then
        ESOProgressionCoach:ToggleVisibility("keybind-fallback")
    end
end


function ESOProgressionCoach_Interact()
    if ESOProgressionCoach and ESOProgressionCoach.ToggleInteractionMode then
        ESOProgressionCoach:ToggleInteractionMode()
    end
end

function ESOAdventurerSuite_JournalToggle()
    if ESOProgressionCoach and ESOProgressionCoach.Journal and ESOProgressionCoach.Journal.Toggle then
        ESOProgressionCoach.Journal:Toggle()
    end
end


function EPC:RefreshNow(reason)
    if not self.Engine or not self.UI then return end
    local compat = self.Compatibility
    local snapshot
    if compat then snapshot = compat:Call("ENGINE", self.Engine, "BuildSnapshot", nil)
    else
        local ok, value = pcall(self.Engine.BuildSnapshot, self.Engine)
        if ok then snapshot = value end
    end
    if not snapshot then
        self.refreshPending = false
        return
    end

    local model
    if compat then model = compat:Call("ENGINE", self.Engine, "Evaluate", nil, snapshot)
    else
        local ok, value = pcall(self.Engine.Evaluate, self.Engine, snapshot)
        if ok then model = value end
    end
    if not model then
        self.refreshPending = false
        return
    end

    if self.Travel and self.saved and self.saved.activeTab == "MAP" then
        if compat then model.travel = compat:Call("TRAVEL", self.Travel, "BuildView", nil, snapshot)
        else model.travel = self.Travel:BuildView(snapshot) end
    end
    if self.Activities and self.saved and self.saved.activeTab == "ACTIVITY" then
        if compat then model.activity = compat:Call("ACTIVITIES", self.Activities, "BuildView", nil, snapshot)
        else model.activity = self.Activities:BuildView(snapshot) end
    end
    if self.QuestFinder and self.saved and self.saved.activeTab == "QUESTS" then
        if compat then model.questFinder = compat:Call("QUEST_FINDER", self.QuestFinder, "BuildView", nil)
        else model.questFinder = self.QuestFinder:BuildView() end
    end
    if self.UtilitySuite and self.saved and self.saved.activeTab == "TOOLS" then
        if compat then model.tools = compat:Call("UTILITY_SUITE", self.UtilitySuite, "BuildView", nil, snapshot)
        else model.tools = self.UtilitySuite:BuildView(snapshot) end
    end
    if self.SetJournal and self.saved and self.saved.activeTab == "GEAR" then
        if compat then model.setJournal = compat:Call("SET_JOURNAL", self.SetJournal, "BuildView", nil)
        else model.setJournal = self.SetJournal:BuildView() end
    end
    if model.travel and self.UtilitySuite and self.UtilitySuite.GetMapHint then
        local hint = compat and compat:Call("UTILITY_SUITE", self.UtilitySuite, "GetMapHint", nil, snapshot) or self.UtilitySuite:GetMapHint(snapshot)
        if hint and hint ~= "" then model.travel.explorationHint = hint end
    end
    self.lastSnapshot = snapshot
    self.lastModel = model
    if compat then compat:Call("UI", self.UI, "Render", nil, model)
    else self.UI:Render(model) end
    if self.Journal and self.Journal.window and not self.Journal.window:IsHidden() and self.Journal.RefreshSuitePage then
        pcall(self.Journal.RefreshSuitePage, self.Journal, self.Journal.activeTab)
    end
    self.refreshPending = false
    self.refreshReason = reason or "manual"
end

function EPC:OnUpdate()
    if self.refreshPending then
        self:RefreshNow(self.refreshReason)
    elseif self.Combat and self.Combat.inCombat and self.saved and self.saved.enabled and self.saved.activeTab == "COMBAT" then
        self:RefreshNow("combat-live")
    end
end

function EPC:RegisterEvents()
    local events = {}
    local function addBaseEvent(eventId)
        if eventId then events[#events + 1] = eventId end
    end
    addBaseEvent(EVENT_LEVEL_UPDATE)
    addBaseEvent(EVENT_SKILL_POINTS_CHANGED)
    addBaseEvent(EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    addBaseEvent(EVENT_PLAYER_ACTIVATED)
    addBaseEvent(EVENT_ATTRIBUTE_UPGRADE_UPDATED)
    addBaseEvent(EVENT_ZONE_CHANGED)
    addBaseEvent(EVENT_CHAMPION_POINT_GAINED)
    addBaseEvent(EVENT_CHAMPION_POINT_UPDATE)
    addBaseEvent(EVENT_CHAMPION_PURCHASE_RESULT)
    addBaseEvent(EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    addBaseEvent(EVENT_SKILLS_FULL_UPDATE)

    for i = 1, #events do
        local eventId = events[i]
        EVENT_MANAGER:RegisterForEvent(self.name .. "_" .. tostring(eventId), eventId, function()
            self:RequestRefresh("game-state")
        end)
    end

    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        local inventoryRegistration = self.name .. "_EquipmentChanged"
        EVENT_MANAGER:RegisterForEvent(inventoryRegistration, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if self.UtilitySuite and self.UtilitySuite.Invalidate then self.UtilitySuite:Invalidate("INVENTORY")
            elseif self.UtilitySuite then self.UtilitySuite.inventoryCache = nil end
            self:RequestRefresh("equipment")
        end)
        if REGISTER_FILTER_BAG_ID and BAG_WORN then
            EVENT_MANAGER:AddFilterForEvent(
                inventoryRegistration,
                EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
                REGISTER_FILTER_BAG_ID,
                BAG_WORN
            )
        end
    end

    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE and ((self.UtilitySuite and self.UtilitySuite.OnInventorySlotUpdate) or (self.TargetBuild and self.TargetBuild.OnInventorySlotUpdate)) then
        local lootRegistration = self.name .. "_LootIntelligence"
        EVENT_MANAGER:RegisterForEvent(lootRegistration, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex, isNewItem)
            if self.UtilitySuite and self.UtilitySuite.OnInventorySlotUpdate then
                self.UtilitySuite:OnInventorySlotUpdate(bagId, slotIndex, isNewItem == true)
            elseif self.TargetBuild and self.TargetBuild.OnInventorySlotUpdate then
                self.TargetBuild:OnInventorySlotUpdate(bagId, slotIndex, isNewItem == true)
            end
            if self.saved and self.saved.activeTab == "TOOLS" and self.UtilitySuite and self.UtilitySuite.ScheduleModeRefresh then
                self.UtilitySuite:ScheduleModeRefresh(self.UtilitySuite:GetMode(), 125)
            end
        end)
        if REGISTER_FILTER_BAG_ID and BAG_BACKPACK then
            EVENT_MANAGER:AddFilterForEvent(lootRegistration, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        end
    end

    local travelEvents = {}
    local function addTravelEvent(eventId)
        if eventId then travelEvents[#travelEvents + 1] = eventId end
    end
    addTravelEvent(EVENT_FAST_TRAVEL_NETWORK_UPDATED)
    addTravelEvent(EVENT_FRIEND_ADDED)
    addTravelEvent(EVENT_FRIEND_REMOVED)
    addTravelEvent(EVENT_FRIEND_CHARACTER_UPDATED)
    addTravelEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED)
    addTravelEvent(EVENT_FRIEND_PLAYER_STATUS_CHANGED)
    addTravelEvent(EVENT_GUILD_MEMBER_ADDED)
    addTravelEvent(EVENT_GUILD_MEMBER_REMOVED)
    addTravelEvent(EVENT_GUILD_MEMBER_CHARACTER_UPDATED)
    addTravelEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED)
    addTravelEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED)
    addTravelEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    addTravelEvent(EVENT_GROUP_MEMBER_JOINED)
    addTravelEvent(EVENT_GROUP_MEMBER_LEFT)
    addTravelEvent(EVENT_GROUP_UPDATE)
    addTravelEvent(EVENT_SOCIAL_DATA_LOADED)

    for i = 1, #travelEvents do
        local eventId = travelEvents[i]
        EVENT_MANAGER:RegisterForEvent(self.name .. "_Travel_" .. tostring(eventId), eventId, function()
            if self.saved.activeTab == "MAP" or (self.Endgame and self.Endgame:GetFocus() == "AUTO") then self:RequestRefresh("travel-data") end
        end)
    end

    local questEvents = {}
    local function addQuestEvent(eventId)
        if eventId then questEvents[#questEvents + 1] = eventId end
    end
    addQuestEvent(EVENT_QUEST_ADDED)
    addQuestEvent(EVENT_QUEST_ADVANCED)
    addQuestEvent(EVENT_QUEST_REMOVED)
    addQuestEvent(EVENT_QUEST_LIST_UPDATED)
    addQuestEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED)
    addQuestEvent(EVENT_TRACKING_UPDATE)
    addQuestEvent(EVENT_ZONE_CHANGED)
    addQuestEvent(EVENT_PLAYER_ACTIVATED)

    if EVENT_QUEST_ADDED and self.Activities and self.Activities.OnQuestAdded then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_ActivityQuestAdded", EVENT_QUEST_ADDED, function(_, journalIndex, questName)
            self.Activities:OnQuestAdded(journalIndex, questName)
        end)
    end

    -- Quest-chain continuation: after the player completes a quest, arm a short
    -- continuation window. If ESO immediately offers the next quest while the
    -- player is still in the quest-giver interaction, accept that offered quest
    -- and assist it once it is added to the journal. This intentionally does not
    -- auto-accept arbitrary quests during normal play.
    self.questContinuation = self.questContinuation or { armedUntil = 0, awaitingAdded = false }

    if EVENT_QUEST_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestChainComplete", EVENT_QUEST_COMPLETE, function(_, questName)
            local now = type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
            self.questContinuation.armedUntil = now + 20000
            self.questContinuation.awaitingAdded = false
            self.questContinuation.completedQuestName = tostring(questName or "")

            local function advanceMainQuest()
                if self.QuestFinder and self.QuestFinder.AdvanceMainQuestAfterCompletion2740 then
                    self.QuestFinder:AdvanceMainQuestAfterCompletion2740(questName)
                end
                if self.ActiveQuest and self.ActiveQuest.Refresh then self.ActiveQuest:Refresh() end
            end
            if type(zo_callLater) == "function" then zo_callLater(advanceMainQuest, 250) else advanceMainQuest() end
        end)
    end

    if EVENT_QUEST_OFFERED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestChainOffered", EVENT_QUEST_OFFERED, function()
            local state = self.questContinuation
            local now = type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
            if not state or now > (tonumber(state.armedUntil) or 0) then return end
            if type(AcceptOfferedQuest) ~= "function" then return end

            -- Consume the continuation window before accepting so duplicate offer
            -- events cannot accept more than one quest.
            state.armedUntil = 0
            state.awaitingAdded = true
            zo_callLater(function()
                local ok = pcall(AcceptOfferedQuest)
                if not ok then state.awaitingAdded = false end
            end, 50)
        end)
    end

    if EVENT_QUEST_ADDED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestChainAdded", EVENT_QUEST_ADDED, function(_, journalIndex, questName)
            local state = self.questContinuation
            if not state or state.awaitingAdded ~= true then return end
            state.awaitingAdded = false

            -- Make the newly continued quest the assisted quest so the normal ESO
            -- tracker and Adventurer Suite Active Quest display continue with it.
            if type(SetTracked) == "function" and TRACK_TYPE_QUEST ~= nil then
                pcall(SetTracked, TRACK_TYPE_QUEST, true, journalIndex)
            end
            if type(SetTrackedIsAssisted) == "function" and TRACK_TYPE_QUEST ~= nil then
                pcall(SetTrackedIsAssisted, TRACK_TYPE_QUEST, true, journalIndex)
            end
            if self.RequestRefresh then self:RequestRefresh("quest-chain-continued") end
            if self.Print then self:Print("Continuing quest: " .. tostring(questName or "Next quest")) end
        end)
    end

    for i = 1, #questEvents do
        local eventId = questEvents[i]
        EVENT_MANAGER:RegisterForEvent(self.name .. "_Quest_" .. tostring(eventId), eventId, function(eventCode)
            if self.Travel and self.Travel.InvalidateQuestPositionCache then
                self.Travel:InvalidateQuestPositionCache()
            end
            if self.UtilitySuite and self.UtilitySuite.Invalidate then
                self.UtilitySuite:Invalidate("DAILIES")
                if eventCode == EVENT_ZONE_CHANGED then self.UtilitySuite:Invalidate("ZONE") end
            end

            -- v0.27.40: quest objective/counter/advance events must refresh the
            -- HUD itself, not only Codex Map/Activity pages. ESO can publish an
            -- event just before all journal text has settled, so refresh now and
            -- once more shortly afterward.
            if self.ActiveQuest and self.ActiveQuest.Refresh then
                if self.ActiveQuest.ReconcileMainQuest2744 then
                    self.ActiveQuest:ReconcileMainQuest2744(nil, nil)
                else
                    self.ActiveQuest:Refresh()
                end
                if type(zo_callLater) == "function" then
                    zo_callLater(function()
                        if self.ActiveQuest and self.ActiveQuest.ReconcileMainQuest2744 then
                            self.ActiveQuest:ReconcileMainQuest2744(nil, nil)
                        elseif self.ActiveQuest and self.ActiveQuest.Refresh then
                            self.ActiveQuest:Refresh()
                        end
                        if self.ActiveQuest and self.ActiveQuest.RefreshNativeQuestTracking2522 then
                            self.ActiveQuest:RefreshNativeQuestTracking2522(true)
                        end
                    end, 180)
                    zo_callLater(function()
                        if self.ActiveQuest and self.ActiveQuest.ReconcileMainQuest2744 then
                            self.ActiveQuest:ReconcileMainQuest2744(nil, nil)
                        end
                    end, 600)
                end
            end

            if self.saved.activeTab == "MAP" or self.saved.activeTab == "ACTIVITY" or self.saved.activeTab == "QUESTS" then
                self:RequestRefresh("quest-data")
            end
        end)
    end

    if EVENT_QUEST_POSITION_REQUEST_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_QuestPosition",
            EVENT_QUEST_POSITION_REQUEST_COMPLETE,
            function(_, taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb, teleportNPCId, waypointId, symbolicState, additionalSymbolicLocX, additionalSymbolicLocY)
                if self.Travel and self.Travel.OnQuestPositionRequestComplete then
                    self.Travel:OnQuestPositionRequestComplete(
                        taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld,
                        isBreadcrumb, teleportNPCId, waypointId, symbolicState,
                        additionalSymbolicLocX, additionalSymbolicLocY
                    )
                end
            end
        )
    end

    if EVENT_QUEST_COMPLETE and self.Activities then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_ActivityQuestComplete", EVENT_QUEST_COMPLETE,
            function(_, questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
                self.Activities:OnQuestComplete(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
            end)
    end

    if EVENT_MONEY_UPDATE and self.Activities then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_ActivityMoney", EVENT_MONEY_UPDATE,
            function(_, newMoney, oldMoney, reason, reasonSupplementaryInfo)
                self.Activities:OnMoneyUpdate(newMoney, oldMoney, reason, reasonSupplementaryInfo)
            end)
    end

    if EVENT_PLAYER_COMBAT_STATE and (self.Combat or self.Maintenance) then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            inCombat = inCombat == true
            if self.Combat then self.Combat:OnCombatState(inCombat) end
            if self.Maintenance and self.Maintenance.OnCombatState then self.Maintenance:OnCombatState(inCombat) end
            self:RefreshGameplayOverlays()
        end)
    end

    if EVENT_COMBAT_EVENT and self.Combat then
        -- Filter noisy combat traffic in ESO's event manager (C-side) instead of
        -- classifying every EVENT_COMBAT_EVENT result in Lua. A unique event
        -- namespace is required for each result/source combination because
        -- multiple values of the same filter type are ANDed, not ORed.
        local damageResults = {
            ACTION_RESULT_DAMAGE,
            ACTION_RESULT_CRITICAL_DAMAGE,
            ACTION_RESULT_DOT_TICK,
            ACTION_RESULT_DOT_TICK_CRITICAL,
            ACTION_RESULT_DAMAGE_SHIELDED,
        }
        local healResults = {
            ACTION_RESULT_HEAL,
            ACTION_RESULT_CRITICAL_HEAL,
            ACTION_RESULT_HOT_TICK,
            ACTION_RESULT_HOT_TICK_CRITICAL,
        }
        local incomingDamageResults = {
            ACTION_RESULT_DAMAGE,
            ACTION_RESULT_CRITICAL_DAMAGE,
            ACTION_RESULT_DOT_TICK,
            ACTION_RESULT_DOT_TICK_CRITICAL,
            ACTION_RESULT_DAMAGE_SHIELDED,
            ACTION_RESULT_BLOCKED_DAMAGE,
            ACTION_RESULT_BLOCKED,
        }

        local function combatHandler(eventKind)
            return function(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, returnedSourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                self.Combat:OnCombatEvent(eventKind, result, abilityName, sourceName, returnedSourceType, targetName, targetType, hitValue, abilityId, sourceUnitId)
            end
        end

        local handlers = {
            DAMAGE = combatHandler("DAMAGE"),
            HEAL = combatHandler("HEAL"),
            INCOMING_DAMAGE = combatHandler("INCOMING_DAMAGE"),
        }

        local function addFilters(registration, result, filterType, filterValue)
            if REGISTER_FILTER_COMBAT_RESULT then
                EVENT_MANAGER:AddFilterForEvent(registration, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
            end
            if REGISTER_FILTER_IS_ERROR then
                EVENT_MANAGER:AddFilterForEvent(registration, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
            end
            if filterType and filterValue ~= nil then
                EVENT_MANAGER:AddFilterForEvent(registration, EVENT_COMBAT_EVENT, filterType, filterValue)
            end
        end

        local function registerFiltered(kind, suffix, result, filterType, filterValue)
            if result == nil then return end
            local registration = string.format("%s_Combat_%s_%s_%s", self.name, kind, suffix, tostring(result))
            EVENT_MANAGER:RegisterForEvent(registration, EVENT_COMBAT_EVENT, handlers[kind])
            addFilters(registration, result, filterType, filterValue)
        end

        local sourceTypes = {
            { "Player", COMBAT_UNIT_TYPE_PLAYER },
            { "Pet", COMBAT_UNIT_TYPE_PLAYER_PET },
            { "Companion", COMBAT_UNIT_TYPE_PLAYER_COMPANION },
            { "Group", COMBAT_UNIT_TYPE_GROUP },
        }

        -- All currently supported ESO clients expose these combat filters.
        -- If a future/unsupported client does not, skip combat analytics rather
        -- than fall back to processing the full unfiltered combat-event stream.
        if REGISTER_FILTER_COMBAT_RESULT and REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE then
            for _, source in ipairs(sourceTypes) do
                local suffix, unitType = source[1], source[2]
                if unitType ~= nil then
                    for _, result in ipairs(damageResults) do
                        registerFiltered("DAMAGE", suffix, result, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, unitType)
                    end
                    for _, result in ipairs(healResults) do
                        registerFiltered("HEAL", suffix, result, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, unitType)
                    end
                end
            end

            if REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE and COMBAT_UNIT_TYPE_PLAYER ~= nil then
                for _, result in ipairs(incomingDamageResults) do
                    registerFiltered("INCOMING_DAMAGE", "TargetPlayer", result, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                end
            end
        end
    end

    -- Combat-Metrics-style player effect uptime tracking. Keep the heavy
    -- EVENT_EFFECT_CHANGED stream natively filtered to the local player.
    if EVENT_EFFECT_CHANGED and self.Combat and REGISTER_FILTER_UNIT_TAG then
        local registration = self.name .. "_Combat_PlayerEffects"
        EVENT_MANAGER:RegisterForEvent(registration, EVENT_EFFECT_CHANGED,
            function(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
                self.Combat:OnEffectChanged(changeType, effectName, unitTag, beginTime, endTime, stackCount, iconName, effectType, abilityId)
            end)
        EVENT_MANAGER:AddFilterForEvent(registration, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end

    if EVENT_PLAYER_ACTIVATED and self.UtilitySuite and self.UtilitySuite.ScanInventory then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_UtilityInventorySnapshot", EVENT_PLAYER_ACTIVATED, function()
            local function warmUtilities()
                local ok, err = pcall(self.UtilitySuite.ScanInventory, self.UtilitySuite, true)
                if ok and self.UtilitySuite.Prewarm then
                    pcall(self.UtilitySuite.Prewarm, self.UtilitySuite, self.lastSnapshot or {})
                elseif not ok and self.Compatibility then
                    self.Compatibility:DisableModule("UTILITY_SUITE", err)
                end
            end
            -- Let character activation finish before doing inventory work; additional
            -- utility views are then staggered by UtilitySuite:Prewarm().
            if type(zo_callLater) == "function" then zo_callLater(warmUtilities, 250) else warmUtilities() end
        end)
    end

    -- Research changes invalidate only the research/overview caches instead of forcing
    -- every TOOLS sub-view to rebuild.
    local researchEvents = {}
    local function addResearchEvent(eventId)
        if eventId then researchEvents[#researchEvents + 1] = eventId end
    end
    addResearchEvent(EVENT_SMITHING_TRAIT_RESEARCH_STARTED)
    addResearchEvent(EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED)
    addResearchEvent(EVENT_SMITHING_TRAIT_RESEARCH_CANCELED)
    for i=1,#researchEvents do
        local eventId = researchEvents[i]
        EVENT_MANAGER:RegisterForEvent(self.name .. "_UtilityResearch_" .. tostring(eventId), eventId, function()
            if self.UtilitySuite and self.UtilitySuite.Invalidate then self.UtilitySuite:Invalidate("RESEARCH") end
            if self.saved and self.saved.activeTab == "TOOLS" and self.UtilitySuite and self.UtilitySuite.ScheduleModeRefresh then
                local mode = self.UtilitySuite:GetMode()
                if mode == "RESEARCH" or mode == "OVERVIEW" then self.UtilitySuite:ScheduleModeRefresh(mode, 125) end
            end
        end)
    end

    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_UIModeChanged", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            if self.interactionMode and self:Safe(IsGameCameraUIModeActive, false) ~= true then
                self.interactionMode = false
                self.interactionOwned = false
                if self.UI and self.UI.ApplyInteractionMode then self.UI:ApplyInteractionMode(false) end
            end
            if self.combatHudMoveMode and self:Safe(IsGameCameraUIModeActive, false) ~= true then
                self.combatHudMoveMode = false
                self.combatHudMoveOwned = false
                self.saved.combatHudLocked = true
                if self.UI and self.UI.SetCombatHUDMoveMode then self.UI:SetCombatHUDMoveMode(false) end
            end
            if self.unitFramesMoveMode and self:Safe(IsGameCameraUIModeActive, false) ~= true then
                -- ESC and scene transitions can make ESO drop camera UI mode.
                -- Do not interpret that as leaving HUD Layout Mode. Restore the
                -- cursor/UI state and keep every preview unlocked until the
                -- user explicitly presses SAVE & EXIT.
                local function restoreStickyHUDLayout()
                    if not EPC or not EPC.unitFramesMoveMode then return end
                    if EPC:Safe(IsGameCameraUIModeActive, false) ~= true then
                        setCameraUIMode(true)
                    end
                    EPC.unitFramesMoveOwned = true
                    EPC:SetHUDLayoutControlBarVisible(true)
                    EPC:RaiseLayoutOverlays()
                    if EPC.MiniMap and EPC.MiniMap.SyncESOCompassVisibility then
                        EPC.MiniMap:SyncESOCompassVisibility()
                    end
                end
                if type(zo_callLater) == "function" then
                    zo_callLater(restoreStickyHUDLayout, 30)
                else
                    restoreStickyHUDLayout()
                end
            end
            if self.miniMapMoveMode and self:Safe(IsGameCameraUIModeActive, false) ~= true then
                self.miniMapMoveMode = false
                self.miniMapMoveOwned = false
                if self.MiniMap and self.MiniMap.SetLayoutMode then self.MiniMap:SetLayoutMode(false) end
            end
        end)
    end

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Pulse", self.saved.refreshMs, function()
        self:OnUpdate()
    end)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_CombatHUDPulse", 250, function()
        if self.Combat and self.UI and self.UI.UpdateCombatHUD then
            self.UI:UpdateCombatHUD(self.Combat:GetHUDSummary())
        end
    end)
end

function EPC:Initialize()
    -- Account-wide data includes learned map/services, inventory snapshots,
    -- progression state and other world-specific information. Namespace it by
    -- megaserver so NA, EU and PTS cannot overwrite one another.
    local worldName = (type(GetWorldName) == "function" and GetWorldName()) or "Default"
    local displayName = (type(GetDisplayName) == "function" and GetDisplayName()) or nil
    local rawSaved = rawget(_G, "ESOProgressionCoachSavedVars")
    local legacyData
    local worldDataAlreadyExists = false

    if type(rawSaved) == "table" and displayName then
        local worldTable = rawSaved[worldName]
        worldDataAlreadyExists = type(worldTable) == "table"
            and type(worldTable[displayName]) == "table"
            and type(worldTable[displayName]["$AccountWide"]) == "table"

        local legacyDefault = rawSaved["Default"]
        if type(legacyDefault) == "table"
            and type(legacyDefault[displayName]) == "table"
            and type(legacyDefault[displayName]["$AccountWide"]) == "table" then
            legacyData = legacyDefault[displayName]["$AccountWide"]
        end
    end

    self.saved = ZO_SavedVars:NewAccountWide("ESOProgressionCoachSavedVars", self.savedVersion, worldName, self.defaults)

    -- One-time compatibility migration for users upgrading from the old global
    -- account-wide namespace. Copy plain SavedVariables data into the first
    -- world-specific profile without sharing nested table references.
    if not worldDataAlreadyExists and type(legacyData) == "table" and self.saved.serverSavedVarsMigration02456 ~= true then
        local function copyPlain(value, seen)
            if type(value) ~= "table" then return value end
            seen = seen or {}
            if seen[value] then return nil end
            seen[value] = true
            local out = {}
            for key, child in pairs(value) do
                local copiedKey = copyPlain(key, seen)
                local copiedValue = copyPlain(child, seen)
                if copiedKey ~= nil then out[copiedKey] = copiedValue end
            end
            seen[value] = nil
            return out
        end
        for key, value in pairs(legacyData) do
            self.saved[key] = copyPlain(value)
        end
        self.saved.serverSavedVarsMigration02456 = true
    end

    -- v0.24.46 minimap visual-state migration. Long-running installs can carry
    -- old minimap presentation values from earlier beta builds while a fresh
    -- install receives the current defaults. Normalize only presentation/layer
    -- settings once so every install starts from the same map appearance. Keep
    -- learned merchants/services/POIs and the user's minimap position intact.
    if self.saved.miniMapVisualState02446 ~= true then
        self.saved.showMiniMap = true
        self.saved.miniMapVisibility = "ALWAYS"
        self.saved.miniMapSize = self.defaults.miniMapSize
        self.saved.miniMapZoom = self.defaults.miniMapZoom
        self.saved.miniMapAlpha = self.defaults.miniMapAlpha
        self.saved.miniMapMapAlpha = self.defaults.miniMapMapAlpha
        self.saved.miniMapMode = self.defaults.miniMapMode
        self.saved.miniMapAdaptiveZoom = self.defaults.miniMapAdaptiveZoom
        self.saved.miniMapEdgeGuidance = self.defaults.miniMapEdgeGuidance
        self.saved.miniMapPOIMax = self.defaults.miniMapPOIMax
        self.saved.miniMapShowQuest = true
        self.saved.miniMapShowWaypoint = true
        self.saved.miniMapShowWayshrines = true
        self.saved.miniMapShowGroup = true
        self.saved.miniMapShowCompanion = true
        self.saved.miniMapShowRally = true
        self.saved.miniMapShowPOIs = true
        self.saved.miniMapShowTrail = true
        self.saved.miniMapVisualState02446 = true
    end

    -- v0.9.3 readability migration for installs carrying the old near-transparent
    -- HUD panel setting. Apply once; later user changes are left alone.
    if self.saved.hudDarkBackgroundMigrated ~= true then
        local oldAlpha = tonumber(self.saved.unitFrameBackgroundAlpha) or 0
        if oldAlpha < 0.55 then self.saved.unitFrameBackgroundAlpha = 0.72 end
        self.saved.unitFrameSoftBackground = true
        self.saved.hudDarkBackgroundMigrated = true
    end

    -- v0.20.0: split the old shared unit-frame scale and boolean combat flags
    -- into independent frame scales and reusable Always/Combat Only modes.
    if self.saved.hudOverlayModesMigrated ~= true then
        local oldScale = tonumber(self.saved.unitFrameScale) or 1.0
        self.saved.playerFrameScale = oldScale
        self.saved.targetFrameScale = oldScale
        self.saved.combatStatsVisibility = self.saved.combatStatsCombatOnly == false and "ALWAYS" or "COMBAT"
        self.saved.showCombatHud = self.saved.combatHudWhenHidden ~= false
        self.saved.hudOverlayModesMigrated = true
    end

    -- Repair / Recharge estimate is now intended to appear with Inventory, not
    -- the Tamriel Codex. Existing CODEX/legacy values migrate to Inventory Only.
    if self.saved.repairCostVisibility == "CODEX" or self.saved.repairCostVisibility == "COMBAT" then
        self.saved.repairCostVisibility = "INVENTORY"
    elseif self.saved.repairCostVisibility ~= "ALWAYS" and self.saved.repairCostVisibility ~= "INVENTORY" then
        self.saved.repairCostVisibility = "INVENTORY"
    end

    if self.Compatibility then self.Compatibility:Initialize() end
    local function initModule(name, object)
        if self.Compatibility then return self.Compatibility:InitializeModule(name, object) end
        if object and type(object.Initialize) == "function" then
            local ok = pcall(object.Initialize, object)
            return ok
        end
        return true
    end

    initModule("BUG_CATCHER", self.BugCatcher)
    initModule("ROLE", self.Role)
    initModule("TRAVEL", self.Travel)
    initModule("ACTIVITIES", self.Activities)
    initModule("DUNGEON_FINDER", self.DungeonFinder)
    initModule("DUNGEON_HISTORY", self.DungeonHistory)
    initModule("ACTIVITY_RUN_HISTORY", self.ActivityRunHistory)
    initModule("QUEST_FINDER", self.QuestFinder)
    initModule("SET_JOURNAL", self.SetJournal)
    initModule("ENDGAME", self.Endgame)
    initModule("TARGET_BUILD", self.TargetBuild)
    initModule("GEAR_OPTIMIZER", self.GearOptimizer)
    initModule("COMPANION_OPTIMIZER", self.CompanionOptimizer)
    initModule("GEAR_LOADOUT_OVERLAY", self.GearLoadoutOverlay)
    initModule("LOADOUT_MANAGER", self.LoadoutManager)
    initModule("ADVISOR", self.Advisor)
    initModule("COMBAT_PRESENTATION", self.CombatPresentation)
    initModule("COMBAT", self.Combat)
    initModule("GAME_MODE_REPORT", self.GameModeReport)
    initModule("ROTATION_ASSISTANT", self.RotationAssistant)
    initModule("MAINTENANCE", self.Maintenance)
    initModule("UNIT_FRAMES", self.UnitFrames)
    initModule("TEAM_VISIBILITY", self.TeamVisibility)
    initModule("DUNGEON_CHEST_FINDER", self.DungeonChestFinder)
    initModule("RESOURCE_PINS", self.ResourcePins)
    initModule("ANTIQUITY_ASSISTANT", self.AntiquityAssistant)
    initModule("ANTIQUITY_LEAD_FINDER", self.AntiquityLeadFinder)
    initModule("ALLIANCE_RANK", self.AllianceRank)
    initModule("CHAMPION_OVERLAY", self.ChampionOverlay)
    initModule("ABILITY_OVERLAYS", self.AbilityOverlays)
    initModule("QUICKSLOT_OVERLAY", self.QuickslotOverlay)
    initModule("INFINITE_ARCHIVE_OVERLAY", self.InfiniteArchiveOverlay)
    initModule("SYNERGY_OVERLAY", self.SynergyOverlay)
    initModule("CUSTOM_RETICLE", self.Reticle)
    initModule("REPAIR_COST_OVERLAY", self.RepairCostOverlay)
    initModule("PERFORMANCE_OVERLAY", self.PerformanceOverlay)
    initModule("ENCOUNTER_REMINDERS", self.EncounterReminders)
    initModule("OVERLAND_DIFFICULTY", self.OverlandDifficulty)
    initModule("CHALLENGE_DIFFICULTY_OVERLAY", self.ChallengeDifficultyOverlay)
    initModule("STABLE_TIMER", self.StableTimer)
    initModule("CLOCK", self.Clock)
    initModule("ACTIVE_QUEST", self.ActiveQuest)
    initModule("GOLDEN_PURSUITS", self.GoldenPursuits)
    initModule("JOURNAL", self.Journal)
    initModule("MINI_MAP", self.MiniMap)
    initModule("UTILITY_SUITE", self.UtilitySuite)

    -- Book-location subsystem is namespaced and initialized as part of the Suite.
    if EASLoreLibrary and EASLoreLibrary.Initialize then
        local ok, err = pcall(EASLoreLibrary.Initialize, EASLoreLibrary)
        if not ok then
            self:Print("Book locations could not initialize: " .. tostring(err))
            if self.BugCatcher and self.BugCatcher.ready and self.BugCatcher.Capture then
                self.BugCatcher:Capture("initialize", "ESO Adventurer Suite Lore Books initialize error: " .. tostring(err))
            end
        end
    end

    local uiOk = true
    if self.Compatibility then
        local marker = {}
        uiOk = self.Compatibility:Call("UI", self.UI, "Create", marker) ~= marker
    else
        uiOk = pcall(self.UI.Create, self.UI)
    end
    if not uiOk then
        self:Print("UI could not initialize. Use /esosuite compat for diagnostics.")
        return
    end
    -- v0.18: Tamriel Codex is the primary interface. Keep the legacy window loaded
    -- for compatibility and as a fallback, but do not show it by default.
    if self.UI and self.UI.root then self.UI.root:SetHidden(true) end

    if self.Settings and self.Settings.Initialize then pcall(self.Settings.Initialize, self.Settings) end
    local eventsOk, eventsErr = pcall(self.RegisterEvents, self)
    if not eventsOk and self.Compatibility then self.Compatibility:DisableModule("EVENTS", eventsErr) end

    if self.Compatibility and self.Compatibility.status ~= "TESTED" then
        local currentApi = tonumber(self.Compatibility.currentApi) or 0
        if self.saved.lastCompatibilityNoticeApi ~= currentApi then
            self:Print(self.Compatibility:GetSummary())
            self:Print("This game API has not been validated with this build. Compatible modules will continue; changed modules are isolated where possible. Use /esosuite compat for details.")
            self.saved.lastCompatibilityNoticeApi = currentApi
        end
    end

    local function handleSlash(arg)
        local rawArg = zo_strtrim(arg or "")
        arg = zo_strlower(rawArg)
        local goal = string.match(arg, "^goal%s+(%a+)$")
        local focus = string.match(arg, "^focus%s+([%a_/]+)$")
        local role = string.match(arg, "^role%s+(%a+)$")
        local sessionArg = string.match(arg, "^session%s+(.+)$")
        local targetProfile = string.match(arg, "^target%s+(%a+)$")
        local targetSetIndex, targetSetName = string.match(arg, "^targetset%s+([12])%s+(.+)$")
        local toolMode = string.match(arg, "^tools?%s+(%a+)$")
        local findQuery = string.match(arg, "^find%s+(.+)$")
        local setQuery = string.match(arg, "^set%s+(.+)$")
        local questQuery = string.match(arg, "^quest%s+(.+)$")
        local hudAction = string.match(arg, "^hud%s+(%a+)$")
        local framesAction = string.match(arg, "^frames?%s+(%a+)$")
        local miniMapAction = string.match(arg, "^minimap%s+(%a+)$")
        local miniMapZoom = string.match(arg, "^minimap%s+zoom%s+([%d%.]+)$")
        local miniMapMode = string.match(arg, "^minimap%s+mode%s+(%a+)$")
        local clockAction = string.match(arg, "^clock%s+(%a+)$")
        local checkpointVerb = string.match(arg, "^checkpoints?%s+(%a+)")
        local checkpointTail = ""
        if checkpointVerb then
            local _, tailStart = string.find(rawArg, "^%S+%s+%S+%s*")
            if tailStart then checkpointTail = zo_strtrim(string.sub(rawArg, tailStart + 1)) end
        end
        if (arg == "codex" or arg == "journal" or arg == "notes") and self.Journal then
            self.Journal:Toggle()
        elseif (arg == "checkpoint" or arg == "checkpoints") and self.Journal then
            self.Journal:Show()
            self.Journal:SetTab("PINS")
        elseif checkpointVerb and self.Journal then
            if checkpointVerb == "save" then
                if checkpointTail == "" then self:Print("Usage: /esosuite checkpoint save <name>")
                else self.Journal:SaveCurrentLocation(checkpointTail) end
            elseif checkpointVerb == "go" or checkpointVerb == "waypoint" then
                if checkpointTail == "" then self:Print("Usage: /esosuite checkpoint go <name>")
                else self.Journal:GoToCheckpoint(checkpointTail) end
            elseif checkpointVerb == "delete" or checkpointVerb == "remove" then
                if checkpointTail == "" then self:Print("Usage: /esosuite checkpoint delete <name>")
                else self.Journal:DeleteCheckpointByName(checkpointTail) end
            elseif checkpointVerb == "list" then
                self.Journal:ListCheckpoints()
            elseif checkpointVerb == "open" or checkpointVerb == "show" then
                self.Journal:Show()
                self.Journal:SetTab("PINS")
            else
                self:Print("Checkpoint: save <name>, go <name>, delete <name>, list, open")
            end
        elseif clockAction and self.Clock then
            if clockAction == "show" then
                self.saved.showClock = true
                self.Clock:Refresh()
            elseif clockAction == "hide" then
                self.saved.showClock = false
                self.Clock:Refresh()
            elseif clockAction == "reset" then
                self.Clock:ResetPosition()
                self.Clock:Refresh()
            elseif clockAction == "move" or clockAction == "unlock" then
                self:SetUnitFramesMoveMode(true)
            elseif clockAction == "lock" or clockAction == "done" then
                self:SetUnitFramesMoveMode(false)
            else
                self:Print("Clock: show, hide, move, lock, reset")
            end
        elseif arg == "maintain" and self.Maintenance then
            self.Maintenance:Run("manual", true)
        elseif questQuery and self.QuestFinder then
            self.QuestFinder:SetSearch(questQuery)
            self.QuestFinder:SetFilter("ALL")
            self.saved.activeTab = "QUESTS"
            self:RefreshNow("slash-quest")
            if self.Journal then self.Journal:Show() self.Journal:SetTab("QUESTS") end
        elseif (arg == "groupfinder" or arg == "gf") and self.DungeonFinder then
            self.saved.activeTab = "GROUPFINDER"
            self.DungeonFinder:SetViewMode("LIVE")
            self.DungeonFinder:RefreshLiveListings(true)
            if self.Journal then self.Journal:Show() self.Journal:SetTab("GROUPFINDER") end
        elseif arg == "set" and self.SetJournal then
            self.saved.activeTab = "GEAR"
            self:RefreshNow("slash-set-journal")
            if self.Journal then self.Journal:Show() self.Journal:SetTab("GEAR") end
        elseif arg == "set clear" and self.SetJournal then
            self.saved.activeTab = "GEAR"
            self.SetJournal:ClearSearch()
            if self.Journal then self.Journal:Show() self.Journal:SetTab("GEAR") end
        elseif setQuery and self.SetJournal then
            self.saved.activeTab = "GEAR"
            self.SetJournal:SetSearch(setQuery)
            if self.Journal then self.Journal:Show() self.Journal:SetTab("GEAR") end
        elseif findQuery and self.UtilitySuite then
            local results = self.UtilitySuite:FindItem(findQuery)
            if #results == 0 then
                self:Print("No saved inventory match for: " .. findQuery)
            else
                self:Print(string.format("Inventory matches for '%s':", findQuery))
                for i = 1, math.min(12, #results) do
                    local r = results[i]
                    self:Print(string.format("%s x%d — %s", r.name or "Item", r.count or 0, r.location or "Unknown"))
                end
                if #results > 12 then self:Print(string.format("...and %d more", #results - 12)) end
            end
        elseif toolMode and self.UtilitySuite then
            if self.UtilitySuite:SetMode(toolMode) then
                self.saved.activeTab = "TOOLS"
                self:RefreshNow("slash-tools")
                if self.Journal then self.Journal:Show() self.Journal:SetTab("TOOLS") end
            else
                self:Print("Tools: overview, inventory, research, collections, dailies")
            end
        elseif arg == "scan" and self.UtilitySuite then
            self.UtilitySuite:ScanInventory(true)
            self.saved.activeTab = "TOOLS"
            self:RefreshNow("slash-scan")
            if self.Journal then self.Journal:Show() self.Journal:SetTab("TOOLS") end
            self:Print("Inventory snapshot refreshed.")
        elseif targetSetIndex and targetSetName and self.TargetBuild then
            self.TargetBuild:SetTargetSet(tonumber(targetSetIndex), targetSetName)
            self.saved.activeTab = "BUILD"
            self:RefreshNow("slash-target-set")
            self:Print("Target set " .. targetSetIndex .. ": " .. targetSetName)
        elseif targetProfile and self.TargetBuild then
            if self.TargetBuild:SetProfile(targetProfile) then
                self.saved.activeTab = "BUILD"
                self:RefreshNow("slash-target-profile")
                self:Print("Target build: " .. self.TargetBuild:GetConfiguredProfile())
            else
                self:Print("Target profiles: auto, damage, healer, tank, solo")
            end
        elseif sessionArg and self.Advisor then
            local normalized = string.upper(zo_strtrim(sessionArg))
            if normalized == "CONTINUOUS" or normalized == "CONT" or normalized == "OFF" then
                self.Advisor:SetSessionMode("CONTINUOUS")
                self:Print("Session planner: continuous guidance")
            elseif normalized == "CUSTOM" then
                self.Advisor:SetSessionMode("CUSTOM")
                self:Print("Session planner: custom " .. tostring(self.Advisor:GetSessionMinutes()) .. " minutes")
            else
                local minutes = tonumber(normalized)
                if minutes then
                    self.Advisor:SetSessionMinutes(minutes)
                    self:Print("Session planner: " .. tostring(self.Advisor:GetSessionMinutes()) .. " minutes; guidance continues after the timer")
                else
                    self:Print("Session options: continuous, 30, 60, 120, custom, or any value from 15-240 minutes")
                end
            end
            self.saved.activeTab = "ACTIVITY"
            self:RefreshNow("slash-session")
        elseif role and self.Role then
            self.Role:SetMode(role)
            self:RefreshNow("slash-role")
            self:Print("Combat role mode: " .. tostring(self.Role:GetMode()))
        elseif focus and self.Endgame then
            self.Endgame:SetFocus(focus)
            self.saved.activeTab = "BUILD"
            self:RefreshNow("slash-focus")
        elseif goal and self.Activities then
            self.Activities:SetGoal(string.upper(goal == "mix" and "BALANCED" or goal))
            self.saved.activeTab = "ACTIVITY"
            self:RefreshNow("slash-goal")
        elseif arg == "mapdebug" and self.MiniMap and self.MiniMap.DebugMapState then
            self.MiniMap:DebugMapState()
        elseif miniMapMode and self.MiniMap and self.MiniMap.SetMode then
            if self.MiniMap:SetMode(miniMapMode) then
                self:Print("Mini Map mode: " .. tostring(self.MiniMap:GetMode()))
            else
                self:Print("Mini Map modes: smart, quest, explore, group, minimal, custom")
            end
        elseif miniMapZoom and self.MiniMap then
            local zoom = self:Clamp(tonumber(miniMapZoom) or 0.90, 0.70, 1.35)
            self.saved.miniMapZoom = zoom
            self.MiniMap:RebuildMap(true)
            self.MiniMap:Refresh(true)
            self:Print(string.format("Mini Map zoom: %.2fx", zoom))
        elseif miniMapAction and self.MiniMap then
            if miniMapAction == "show" then
                self.saved.showMiniMap = true
                self.MiniMap:Refresh(true)
            elseif miniMapAction == "hide" then
                if self.miniMapMoveMode then self:SetMiniMapMoveMode(false) end
                self.saved.showMiniMap = false
                self.MiniMap:Refresh(false)
            elseif miniMapAction == "reset" then
                self:ResetMiniMapPosition()
            elseif miniMapAction == "move" or miniMapAction == "unlock" then
                self:SetMiniMapMoveMode(true)
            elseif miniMapAction == "lock" or miniMapAction == "done" then
                self:SetMiniMapMoveMode(false)
            else
                self:Print("Mini Map: show, hide, move, lock, reset, mode smart/quest/explore/group/minimal/custom, zoom <0.70-2.00>")
            end
        elseif framesAction then
            if framesAction == "move" or framesAction == "unlock" or framesAction == "layout" then
                self:SetUnitFramesMoveMode(true)
            elseif framesAction == "lock" or framesAction == "done" then
                self:SetUnitFramesMoveMode(false)
            elseif framesAction == "reset" then
                self:ResetUnitFramePositions()
            elseif framesAction == "show" then
                self.saved.showPlayerFrame = true
                self.saved.showTargetFrame = true
                self.saved.showGroupFrame = true
                self.saved.showRaidFrame = true
                self.saved.showCombatStatsFrame = true
                self.saved.showMiniMap = true
                self.saved.showStableTimer = true
                self.saved.showClock = true
                self.saved.showActiveQuestOverlay = true
                self.saved.showAllianceRank = true
                self.saved.showChampionOverlay = true
                self.saved.showAbilityOverlays = true
                self.saved.showRepairCostOverlay = true
                self.saved.showCombatHud = true
                if self.UnitFrames then self.UnitFrames:RefreshAll(true) end
                if self.MiniMap then self.MiniMap:Refresh(true) end
                if self.StableTimer then self.StableTimer:Refresh() end
                if self.Clock then self.Clock:Refresh() end
                if self.ActiveQuest then self.ActiveQuest:Refresh() end
                if self.AllianceRank then self.AllianceRank:Refresh() end
                if self.ChampionOverlay then self.ChampionOverlay:Refresh() end
                if self.AbilityOverlays then self.AbilityOverlays:Refresh() end
                if self.RepairCostOverlay then self.RepairCostOverlay:Refresh() end
                if self.UI and self.UI.UpdateCombatHUD and self.Combat then self.UI:UpdateCombatHUD(self.Combat:GetHUDSummary()) end
            elseif framesAction == "hide" then
                if self.miniMapMoveMode then self:SetMiniMapMoveMode(false) end
                if self.unitFramesMoveMode then self:SetUnitFramesMoveMode(false) end
                self.saved.showPlayerFrame = false
                self.saved.showTargetFrame = false
                self.saved.showGroupFrame = false
                self.saved.showRaidFrame = false
                self.saved.showCombatStatsFrame = false
                self.saved.showMiniMap = false
                self.saved.showStableTimer = false
                self.saved.showClock = false
                self.saved.showActiveQuestOverlay = false
                self.saved.showAllianceRank = false
                self.saved.showChampionOverlay = false
                self.saved.showAbilityOverlays = false
                self.saved.showRepairCostOverlay = false
                self.saved.showCombatHud = false
                if self.UnitFrames then self.UnitFrames:RefreshAll(true) end
                if self.MiniMap then self.MiniMap:Refresh(false) end
                if self.StableTimer then self.StableTimer:Refresh() end
                if self.Clock then self.Clock:Refresh() end
                if self.ActiveQuest then self.ActiveQuest:Refresh() end
                if self.AllianceRank then self.AllianceRank:Refresh() end
                if self.ChampionOverlay then self.ChampionOverlay:Refresh() end
                if self.AbilityOverlays then self.AbilityOverlays:Refresh() end
                if self.RepairCostOverlay then self.RepairCostOverlay:Refresh() end
                if self.UI and self.UI.UpdateCombatHUD and self.Combat then self.UI:UpdateCombatHUD(self.Combat:GetHUDSummary()) end
            else
                self:Print("HUD frames: frames move, frames lock, frames reset, frames show, frames hide")
            end
        elseif hudAction then
            if hudAction == "move" or hudAction == "unlock" then
                self:SetCombatHUDMoveMode(true)
            elseif hudAction == "lock" or hudAction == "done" then
                self:SetCombatHUDMoveMode(false)
            elseif hudAction == "reset" then
                self:ResetCombatHUDPosition()
            else
                self:Print("Combat HUD: hud move, hud lock, hud reset")
            end
        elseif arg == "leads" or arg == "leadfinder" or arg == "antiquities" then
            if self.AntiquityLeadFinder then
                self.AntiquityLeadFinder:Show()
            else
                self:Print("Antiquity Lead Finder is unavailable.")
            end
        elseif arg == "compat" or arg == "compatibility" then
            if self.Compatibility then
                local lines = self.Compatibility:GetDiagnosticLines()
                for i = 1, #lines do self:Print(lines[i]) end
            else
                self:Print("Compatibility diagnostics are unavailable.")
            end
        elseif arg == "reset" then
            self.UI:ResetPosition()
        elseif arg == "lock" then
            self.saved.locked = true
            self.UI:ApplyInteractionState()
            self:Print("Window locked.")
        elseif arg == "unlock" then
            self.saved.locked = false
            self.UI:ApplyInteractionState()
            self:Print("Window unlocked.")
        elseif arg == "menu" or arg == "legacy" then
            self:Print("The old menu has been removed. Opening Tamriel Codex instead.")
            if self.Journal then self.Journal:Show() end
        elseif arg == "hide" then
            if self.Journal then self.Journal:Hide() end
        elseif arg == "toggle" then
            if self.Journal then self.Journal:Toggle() end
        elseif arg == "interact" then
            self:ToggleInteractionMode()
        elseif arg == "show" or arg == "" then
            if self.Journal then self.Journal:Show() end
        else
            self:Print("Commands: show, hide, toggle, codex, leads, groupfinder, checkpoint save/go/delete/list/open, clock show/hide/move/lock/reset, lock, unlock, reset, quest <name/zone>, maintain, hud move/lock/reset, frames move/lock/reset/show/hide, minimap show/hide/move/lock/reset/mode/zoom <0.70-2.00>, compat, tools overview/inventory/research/collections/dailies, scan, find <item>, set <name>, role auto/damage/healer/tank, focus auto/dps/gold/xp_cp/gear/dungeons/trials/solo/questing, goal xp/gold/balanced, session continuous/30/60/120/custom/<15-240>, target auto/damage/healer/tank/solo, targetset 1/2 <set name>")
        end
    end
    SLASH_COMMANDS["/esosuite"] = handleSlash
    SLASH_COMMANDS["/esocoach"] = handleSlash -- legacy alias retained for existing users/macros

    self:RefreshNow("init")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= EPC.name then return end
    EVENT_MANAGER:UnregisterForEvent(EPC.name, EVENT_ADD_ON_LOADED)
    EPC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(EPC.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
