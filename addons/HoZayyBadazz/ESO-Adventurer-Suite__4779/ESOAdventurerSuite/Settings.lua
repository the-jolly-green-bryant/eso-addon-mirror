-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Settings = EPC.Settings or {}
local S = EPC.Settings

function S:Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "ESOProgressionCoachSettings"
    local challengeNames, challengeValues = { "Adventurer", "Seasoned", "Master", "Vestige" }, { 0, 1, 2, 3 }
    if EPC.OverlandDifficulty and EPC.OverlandDifficulty.GetDifficultyChoices then
        challengeNames, challengeValues = EPC.OverlandDifficulty:GetDifficultyChoices()
    end
    LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = EPC.displayName,
        displayName = "|cE8B347ESO Adventurer Suite|r",
        author = EPC.author,
        version = EPC.version,
        slashCommand = "/esosuite",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local rawOptions = {
        {
            type = "description",
            title = "Gameplay hotkeys",
            text = "Assign 'Open / Close Tamriel Codex' under Controls > Keybindings > General > ESO Adventurer Suite. The same key opens and closes the Tamriel Codex. The old standalone menu has been removed; the Tamriel Codex is the main interface.",
        },
        {
            type = "description",
            title = "Compatibility status",
            text = EPC.Compatibility and (EPC.Compatibility:GetSummary() .. "\n\nThe addon cannot self-download code. If ESO updates, this build probes the current API and keeps compatible modules running where possible. Use /esosuite compat for detailed module diagnostics, then update through ESOUI/Minion when a validated build is released.") or "Compatibility diagnostics unavailable.",
        },
        {
            type = "checkbox", name = "Enable suite systems",
            getFunc = function() return EPC.saved.enabled end,
            setFunc = function(v) EPC:SetEnabled(v, "settings") end,
            default = EPC.defaults.enabled,
        },
        {
            type = "dropdown", name = "Combat role awareness",
            tooltip = "Auto follows your ESO preferred Group Finder role when available. You can override it to Damage, Healer, or Tank so BUILD, GEAR, SKILLS, COMBAT, and the hidden combat HUD use role-specific priorities.",
            choices = { "Auto (Group Finder role)", "Damage", "Healer", "Tank" },
            choicesValues = { "AUTO", "DAMAGE", "HEALER", "TANK" },
            getFunc = function() return EPC.Role and EPC.Role:GetMode() or (EPC.saved.combatRoleMode or "AUTO") end,
            setFunc = function(v)
                if EPC.Role then EPC.Role:SetMode(v) else EPC.saved.combatRoleMode = v EPC:RequestRefresh("role-mode") end
            end,
            default = EPC.defaults.combatRoleMode,
        },
        {
            type = "header", name = "Gameplay & Challenge Difficulty",
        },
        {
            type = "description",
            title = "Automatically control ESO's native Challenge Difficulty",
            text = "Choose a difficulty for overland situations, or enable Leveling Journey to let your character level and the current zone choose it automatically. Difficulty changes wait until combat ends and use ESO's native Challenge Difficulty system.",
        },
        {
            type = "checkbox", name = "Enable automatic Challenge Difficulty",
            getFunc = function() return EPC.saved.overlandDifficultyEnabled == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyEnabled = v == true if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            default = EPC.defaults.overlandDifficultyEnabled,
        },
        {
            type = "checkbox", name = "Leveling Journey",
            tooltip = "Assigns adventure zones levels from 1 to 50 and automatically chooses a Challenge Difficulty based on your character's level. Your custom rules are preserved and return when this is turned off. World Bosses are capped at Master.",
            getFunc = function() return EPC.saved.overlandDifficultyLevelingJourney == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyLevelingJourney = v == true if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RefreshMapLevelLabel() EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyLevelingJourney,
        },
        {
            type = "checkbox", name = "Show zone levels on World Map",
            getFunc = function() return EPC.saved.overlandDifficultyShowZoneLevelsMap ~= false end,
            setFunc = function(v) EPC.saved.overlandDifficultyShowZoneLevelsMap = v == true if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RefreshMapLevelLabel() end end,
            disabled = function() return EPC.saved.overlandDifficultyLevelingJourney ~= true end,
            default = EPC.defaults.overlandDifficultyShowZoneLevelsMap,
            width = "half",
        },
        {
            type = "checkbox", name = "Zone entry difficulty message",
            tooltip = "Shows the zone level and the difficulty icon/name when you enter a zone.",
            getFunc = function() return EPC.saved.overlandDifficultyZoneMessages == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyZoneMessages = v == true end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyZoneMessages,
            width = "half",
        },
        {
            type = "checkbox", name = "Use Companion difficulty rule",
            tooltip = "When a companion is active, temporarily use the Companion difficulty selected below. When the companion is dismissed, the normal zone/activity rule returns.",
            getFunc = function() return EPC.saved.overlandDifficultyCompanionEnabled == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyCompanionEnabled = v == true if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyCompanionEnabled,
            width = "half",
        },
        {
            type = "dropdown", name = "Companion difficulty",
            tooltip = "Challenge Difficulty used while your companion is summoned.",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyCompanion) or 3 end,
            setFunc = function(v) EPC.saved.overlandDifficultyCompanion = tonumber(v) or 3 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyCompanionEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyCompanion,
            width = "half",
        },
        {
            type = "slider", name = "World Boss wave hold", min = 15, max = 120, step = 5,
            tooltip = "Keeps the World Boss difficulty rule active for this many seconds after a World Boss is detected. Prevents multi-wave bosses from reverting to Open World difficulty between waves.",
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyWorldBossHoldSeconds) or 45 end,
            setFunc = function(v) EPC.saved.overlandDifficultyWorldBossHoldSeconds = tonumber(v) or 45 end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyWorldBossHoldSeconds,
        },
        {
            type = "checkbox", name = "Show Challenge Difficulty symbol overlay",
            tooltip = "Displays the currently active Challenge Difficulty symbol as a movable HUD overlay. Move it with the Suite's HUD layout mode and scale it below.",
            getFunc = function() return EPC.saved.overlandDifficultyShowOverlay == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyShowOverlay = v == true if EPC.ChallengeDifficultyOverlay then EPC.ChallengeDifficultyOverlay:Refresh() end end,
            default = EPC.defaults.overlandDifficultyShowOverlay,
            width = "half",
        },
        {
            type = "checkbox", name = "Show Normal/Veteran dungeon symbol",
            tooltip = "While inside a dungeon, replaces the overland Challenge Difficulty symbol with ESO's native Normal or Veteran dungeon difficulty icon. Turn this off to hide the difficulty overlay entirely in dungeons.",
            getFunc = function() return EPC.saved.overlandDifficultyShowDungeonOverlay ~= false end,
            setFunc = function(v) EPC.saved.overlandDifficultyShowDungeonOverlay = v == true if EPC.ChallengeDifficultyOverlay then EPC.ChallengeDifficultyOverlay:Refresh() end end,
            default = EPC.defaults.overlandDifficultyShowDungeonOverlay,
            width = "half",
        },
        {
            type = "slider", name = "Challenge Difficulty symbol size", min = 50, max = 200, step = 5,
            tooltip = "Scales the Challenge Difficulty symbol overlay from 50% to 200%.",
            getFunc = function() return math.floor((tonumber(EPC.saved.overlandDifficultyOverlayScale) or 1.0) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.overlandDifficultyOverlayScale = (tonumber(v) or 100) / 100 if EPC.ChallengeDifficultyOverlay then EPC.ChallengeDifficultyOverlay:Refresh() end end,
            default = (EPC.defaults.overlandDifficultyOverlayScale or 1.0) * 100,
            width = "half",
        },
        {
            type = "button", name = "Reset Challenge Difficulty overlay position", buttonText = "Reset Position",
            func = function() if EPC.ChallengeDifficultyOverlay then EPC.ChallengeDifficultyOverlay:ResetPosition() EPC.ChallengeDifficultyOverlay:Refresh() end end,
            width = "half",
        },
        {
            type = "description",
            text = "To move the Challenge Difficulty symbol, use the Suite's HUD layout mode and drag the icon where you want it.",
            width = "full",
        },
        {
            type = "slider", name = "Nearby activity detection radius", min = 30, max = 200, step = 5,
            tooltip = "Distance in meters used to detect nearby World Boss, World Event, Dragon, and Public Dungeon POIs.",
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyPoiRadius) or 85 end,
            setFunc = function(v) EPC.saved.overlandDifficultyPoiRadius = tonumber(v) or 85 end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyPoiRadius,
        },
        {
            type = "dropdown", name = "Open World difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyOpenWorld) or 0 end,
            setFunc = function(v) EPC.saved.overlandDifficultyOpenWorld = tonumber(v) or 0 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyOpenWorld,
        },
        {
            type = "dropdown", name = "Delve difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyDelve) or 1 end,
            setFunc = function(v) EPC.saved.overlandDifficultyDelve = tonumber(v) or 1 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyDelve,
            width = "half",
        },
        {
            type = "dropdown", name = "Public Dungeon difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyPublicDungeon) or 2 end,
            setFunc = function(v) EPC.saved.overlandDifficultyPublicDungeon = tonumber(v) or 2 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyPublicDungeon,
            width = "half",
        },
        {
            type = "dropdown", name = "World Boss difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyWorldBoss) or 2 end,
            setFunc = function(v) EPC.saved.overlandDifficultyWorldBoss = tonumber(v) or 2 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyWorldBoss,
            width = "half",
        },
        {
            type = "dropdown", name = "World Event difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyWorldEvent) or 2 end,
            setFunc = function(v) EPC.saved.overlandDifficultyWorldEvent = tonumber(v) or 2 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyWorldEvent,
            width = "half",
        },
        {
            type = "dropdown", name = "Dragon difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyDragon) or 2 end,
            setFunc = function(v) EPC.saved.overlandDifficultyDragon = tonumber(v) or 2 if EPC.OverlandDifficulty then EPC.OverlandDifficulty:RequestRefresh(100) end end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyDragon,
            width = "half",
        },
        {
            type = "checkbox", name = "History Bosses (Experimental)",
            tooltip = "When enabled, a boss targeted by your reticle can temporarily use the History Boss difficulty rule. Experimental because not every story boss is exposed consistently by ESO.",
            getFunc = function() return EPC.saved.overlandDifficultyHistoryBosses == true end,
            setFunc = function(v) EPC.saved.overlandDifficultyHistoryBosses = v == true end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true end,
            default = EPC.defaults.overlandDifficultyHistoryBosses,
            width = "half",
        },
        {
            type = "dropdown", name = "History Boss difficulty",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return tonumber(EPC.saved.overlandDifficultyHistoryBoss) or 2 end,
            setFunc = function(v) EPC.saved.overlandDifficultyHistoryBoss = tonumber(v) or 2 end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyHistoryBosses ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyHistoryBoss,
            width = "half",
        },
        {
            type = "dropdown", name = "Current zone override",
            tooltip = "Sets an Open World-only override for the zone you are standing in. Delves, Public Dungeons, bosses, events, and Dragons keep their own rules.",
            choices = challengeNames,
            choicesValues = challengeValues,
            getFunc = function() return EPC.OverlandDifficulty:GetCurrentZoneOverride() or tonumber(EPC.saved.overlandDifficultyOpenWorld) or 0 end,
            setFunc = function(v) EPC.OverlandDifficulty:SetCurrentZoneOverride(v) end,
            disabled = function() return EPC.saved.overlandDifficultyEnabled ~= true or EPC.saved.overlandDifficultyLevelingJourney == true end,
            default = EPC.defaults.overlandDifficultyOpenWorld,
            width = "half",
        },
        {
            type = "button", name = "Clear current zone override", buttonText = "Use Open World Rule",
            func = function() if EPC.OverlandDifficulty then EPC.OverlandDifficulty:SetCurrentZoneOverride(nil) end end,
            disabled = function() return not EPC.OverlandDifficulty or EPC.OverlandDifficulty:GetCurrentZoneOverride() == nil end,
            width = "half",
        },
        {
            type = "header", name = "Live Group Finder",
        },
        {
            type = "checkbox", name = "Hide WTS listings",
            tooltip = "Hides obvious WTS/selling listings from the Group Finder Codex results outside the Custom category.",
            getFunc = function() return EPC.saved.groupFinderWidgetHideWTS ~= false end,
            setFunc = function(v)
                EPC.saved.groupFinderWidgetHideWTS = v == true
                if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("GROUPFINDER") end
            end,
            default = EPC.defaults.groupFinderWidgetHideWTS,
        },
        {
            type = "checkbox", name = "Hide listings above my CP",
            tooltip = "Hide Codex Group Finder listings whose Champion Point requirement is above your current Champion Points.",
            getFunc = function() return EPC.saved.groupFinderWidgetHideHighCP == true end,
            setFunc = function(v)
                EPC.saved.groupFinderWidgetHideHighCP = v == true
                if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("GROUPFINDER") end
            end,
            default = EPC.defaults.groupFinderWidgetHideHighCP,
        },
        {
            type = "checkbox", name = "Last Boss Highlight",
            tooltip = "Makes matching last/final-boss listings in the Tamriel Codex Group Finder pulse through rainbow colors. Detection checks the listing title and description for common last-boss phrases and shorthand.",
            getFunc = function() return EPC.saved.groupFinderWidgetLastBossHighlight == true end,
            setFunc = function(v)
                EPC.saved.groupFinderWidgetLastBossHighlight = v == true
                if EPC.Journal and EPC.Journal.activeTab == "GROUPFINDER" and EPC.Journal.RefreshSuitePage then EPC.Journal:RefreshSuitePage("GROUPFINDER") end
            end,
            default = EPC.defaults.groupFinderWidgetLastBossHighlight,
        },
        {
            type = "checkbox", name = "Show combat HUD",
            tooltip = "Shows the personal combat meter. Use the visibility option below to keep it always available in gameplay or show it only while in combat.",
            getFunc = function() return EPC.saved.showCombatHud ~= false end,
            setFunc = function(v)
                EPC.saved.showCombatHud = v == true
                if EPC.UI and EPC.UI.UpdateCombatHUD and EPC.Combat then EPC.UI:UpdateCombatHUD(EPC.Combat:GetHUDSummary()) end
            end,
            default = EPC.defaults.showCombatHud,
        },
        {
            type = "dropdown", name = "Combat HUD visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.combatHudVisibility or "COMBAT" end,
            setFunc = function(v) EPC.saved.combatHudVisibility = v if EPC.RefreshGameplayOverlays then EPC:RefreshGameplayOverlays() end end,
            default = EPC.defaults.combatHudVisibility,
        },
        {
            type = "button", name = "Move compact combat HUD",
            tooltip = "Shows a combat-HUD preview, releases the mouse, and lets you drag the combat meter independently from the main suite. Use /esosuite hud lock when finished.",
            func = function() if EPC.SetCombatHUDMoveMode then EPC:SetCombatHUDMoveMode(true) end end,
            width = "half",
        },
        {
            type = "button", name = "Lock combat HUD",
            tooltip = "Finish moving the compact combat meter and return it to non-interactive HUD behavior.",
            func = function() if EPC.SetCombatHUDMoveMode then EPC:SetCombatHUDMoveMode(false) end end,
            width = "half",
        },
        {
            type = "button", name = "Reset combat HUD position",
            tooltip = "Moves the compact combat meter back to its default upper-right position.",
            func = function() if EPC.ResetCombatHUDPosition then EPC:ResetCombatHUDPosition() end end,
            width = "half",
        },
        {
            type = "slider", name = "Combat HUD scale", min = 70, max = 140, step = 5,
            getFunc = function() return math.floor((EPC.saved.combatHudScale or 1.0) * 100) end,
            setFunc = function(v)
                EPC.saved.combatHudScale = v / 100
                if EPC.UI and EPC.UI.combatHud then EPC.UI.combatHud:SetScale(EPC.saved.combatHudScale) end
            end,
            default = math.floor((EPC.defaults.combatHudScale or 1.0) * 100),
        },
        {
            type = "slider", name = "Combat HUD opacity", min = 35, max = 100, step = 1,
            getFunc = function() return math.floor((EPC.saved.combatHudAlpha or 0.94) * 100) end,
            setFunc = function(v)
                EPC.saved.combatHudAlpha = v / 100
                if EPC.UI and EPC.UI.combatHud then EPC.UI.combatHud:SetAlpha(EPC.saved.combatHudAlpha) end
            end,
            default = math.floor((EPC.defaults.combatHudAlpha or 0.94) * 100),
        },
        {
            type = "header", name = "Automatic Equipment Maintenance",
        },
        {
            type = "description",
            title = "Recharge and repair on combat transitions",
            text = "The suite can check equipped weapons and armor when combat starts and ends. It uses filled soul gems and repair kits only when an equipped item falls below your configured threshold.",
        },
        {
            type = "checkbox", name = "Enable automatic maintenance",
            getFunc = function() return EPC.saved.autoMaintenance ~= false end,
            setFunc = function(v) EPC.saved.autoMaintenance = v == true end,
            default = EPC.defaults.autoMaintenance,
        },
        {
            type = "checkbox", name = "Auto recharge equipped weapons",
            getFunc = function() return EPC.saved.autoRecharge ~= false end,
            setFunc = function(v) EPC.saved.autoRecharge = v == true end,
            default = EPC.defaults.autoRecharge,
        },
        {
            type = "slider", name = "Recharge below (%)", min = 10, max = 100, step = 5,
            getFunc = function() return tonumber(EPC.saved.autoRechargeThreshold) or 90 end,
            setFunc = function(v) EPC.saved.autoRechargeThreshold = tonumber(v) or 90 end,
            default = EPC.defaults.autoRechargeThreshold,
        },
        {
            type = "checkbox", name = "Auto repair equipped armor",
            getFunc = function() return EPC.saved.autoRepair ~= false end,
            setFunc = function(v) EPC.saved.autoRepair = v == true end,
            default = EPC.defaults.autoRepair,
        },
        {
            type = "slider", name = "Repair below (%)", min = 10, max = 100, step = 5,
            getFunc = function() return tonumber(EPC.saved.autoRepairThreshold) or 90 end,
            setFunc = function(v) EPC.saved.autoRepairThreshold = tonumber(v) or 90 end,
            default = EPC.defaults.autoRepairThreshold,
        },
        {
            type = "checkbox", name = "Check when entering combat",
            getFunc = function() return EPC.saved.autoMaintenanceOnCombatStart ~= false end,
            setFunc = function(v) EPC.saved.autoMaintenanceOnCombatStart = v == true end,
            default = EPC.defaults.autoMaintenanceOnCombatStart,
            width = "half",
        },
        {
            type = "checkbox", name = "Check when leaving combat",
            getFunc = function() return EPC.saved.autoMaintenanceOnCombatEnd ~= false end,
            setFunc = function(v) EPC.saved.autoMaintenanceOnCombatEnd = v == true end,
            default = EPC.defaults.autoMaintenanceOnCombatEnd,
            width = "half",
        },
        {
            type = "checkbox", name = "Never use Crown repair kits",
            tooltip = "Protects premium Crown repair kits from automatic consumption. Ordinary repair kits are used instead.",
            getFunc = function() return EPC.saved.maintenanceNeverUseCrown ~= false end,
            setFunc = function(v) EPC.saved.maintenanceNeverUseCrown = v == true end,
            default = EPC.defaults.maintenanceNeverUseCrown,
        },
        {
            type = "checkbox", name = "Show maintenance chat messages",
            getFunc = function() return EPC.saved.maintenanceMessages ~= false end,
            setFunc = function(v) EPC.saved.maintenanceMessages = v == true end,
            default = EPC.defaults.maintenanceMessages,
        },
        {
            type = "button", name = "Run maintenance now",
            func = function() if EPC.Maintenance then EPC.Maintenance:Run("settings", true) end end,
        },
        {
            type = "header", name = "Repair / Recharge Estimate Overlay",
        },
        {
            type = "description",
            title = "See the cost before spending gold",
            text = "Lists equipped armor/shields with current condition and per-piece vendor repair cost, plus equipped weapon charge. Weapons recharge with soul gems rather than vendor repair gold. The overlay never repairs anything by itself.",
        },
        {
            type = "checkbox", name = "Show repair / recharge estimate",
            getFunc = function() return EPC.saved.showRepairCostOverlay ~= false end,
            setFunc = function(v) EPC.saved.showRepairCostOverlay = v == true if EPC.RepairCostOverlay then EPC.RepairCostOverlay:Refresh() end end,
            default = EPC.defaults.showRepairCostOverlay,
        },
        {
            type = "dropdown", name = "Repair estimate visibility",
            tooltip = "Inventory Only shows the estimate while your Inventory is open and hides it when Inventory closes. Always keeps the estimate visible whenever it is enabled.",
            choices = { "Inventory Only", "Always" }, choicesValues = { "INVENTORY", "ALWAYS" },
            getFunc = function()
                local mode = EPC.saved.repairCostVisibility
                return (mode == "ALWAYS") and "ALWAYS" or "INVENTORY"
            end,
            setFunc = function(v) EPC.saved.repairCostVisibility = v if EPC.RepairCostOverlay then EPC.RepairCostOverlay:Refresh() end end,
            default = EPC.defaults.repairCostVisibility,
        },
        {
            type = "slider", name = "Repair estimate scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.repairCostScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.repairCostScale = v / 100 if EPC.RepairCostOverlay then EPC.RepairCostOverlay:Refresh() end end,
            default = math.floor((EPC.defaults.repairCostScale or 1.0) * 100),
        },
        {
            type = "button", name = "Reset repair estimate position", buttonText = "Reset Repair Estimate",
            func = function() if EPC.RepairCostOverlay then EPC.RepairCostOverlay:ResetPosition() EPC.RepairCostOverlay:Refresh() end end,
        },
        {
            type = "header", name = "Pre-Encounter Reminders",
        },
        {
            type = "description",
            title = "Small text-only readiness reminders",
            text = "Shows no background box. In dungeons, trials, arenas, delves and public dungeons the reminders stay ready while you are out of combat. In overland and quest areas they appear when you aim at an attackable target before the pull.",
        },
        {
            type = "checkbox", name = "Show pre-encounter reminders",
            getFunc = function() return EPC.saved.showEncounterReminders ~= false end,
            setFunc = function(v) EPC.saved.showEncounterReminders = v == true if EPC.EncounterReminders then EPC.EncounterReminders:Refresh() end end,
            default = EPC.defaults.showEncounterReminders,
        },
        {
            type = "checkbox", name = "Armor repair reminder",
            tooltip = "Shows ARMOR NEEDS REPAIR before an encounter when at least one equipped armor piece is below 100% condition.",
            getFunc = function() return EPC.saved.showEncounterRepairReminder ~= false end,
            setFunc = function(v) EPC.saved.showEncounterRepairReminder = v == true if EPC.EncounterReminders then EPC.EncounterReminders:Refresh() end end,
            default = EPC.defaults.showEncounterRepairReminder,
        },
        {
            type = "checkbox", name = "Potion reminder",
            tooltip = "Shows DRINK POTION BEFORE NEXT ENCOUNTER before each new pull, then hides when combat starts.",
            getFunc = function() return EPC.saved.showEncounterPotionReminder ~= false end,
            setFunc = function(v) EPC.saved.showEncounterPotionReminder = v == true if EPC.EncounterReminders then EPC.EncounterReminders:Refresh() end end,
            default = EPC.defaults.showEncounterPotionReminder,
        },
        {
            type = "slider", name = "Armor reminder scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.encounterRepairScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.encounterRepairScale = v / 100 if EPC.EncounterReminders then EPC.EncounterReminders:Refresh() end end,
            default = math.floor((EPC.defaults.encounterRepairScale or 1.0) * 100),
            width = "half",
        },
        {
            type = "slider", name = "Potion reminder scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.encounterPotionScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.encounterPotionScale = v / 100 if EPC.EncounterReminders then EPC.EncounterReminders:Refresh() end end,
            default = math.floor((EPC.defaults.encounterPotionScale or 1.0) * 100),
            width = "half",
        },
        {
            type = "dropdown", name = "Armor reminder position",
            tooltip = "Choose a screen corner, or Custom to place it anywhere with HUD layout mode.",
            choices = { "Custom", "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
            choicesValues = { "CUSTOM", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" },
            getFunc = function() return EPC.saved.encounterRepairPreset or "CUSTOM" end,
            setFunc = function(v) if EPC.EncounterReminders then EPC.EncounterReminders:SetRepairPreset(v) EPC.EncounterReminders:Refresh() else EPC.saved.encounterRepairPreset = v end end,
            default = EPC.defaults.encounterRepairPreset,
            width = "half",
        },
        {
            type = "dropdown", name = "Potion reminder position",
            tooltip = "Choose a screen corner, or Custom to place it anywhere with HUD layout mode.",
            choices = { "Custom", "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
            choicesValues = { "CUSTOM", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" },
            getFunc = function() return EPC.saved.encounterPotionPreset or "CUSTOM" end,
            setFunc = function(v) if EPC.EncounterReminders then EPC.EncounterReminders:SetPotionPreset(v) EPC.EncounterReminders:Refresh() else EPC.saved.encounterPotionPreset = v end end,
            default = EPC.defaults.encounterPotionPreset,
            width = "half",
        },
        {
            type = "button", name = "Reset armor reminder position", buttonText = "Reset Armor",
            func = function() if EPC.EncounterReminders then EPC.EncounterReminders:ResetRepairPosition() EPC.EncounterReminders:Refresh() end end,
            width = "half",
        },
        {
            type = "button", name = "Reset potion reminder position", buttonText = "Reset Potion",
            func = function() if EPC.EncounterReminders then EPC.EncounterReminders:ResetPotionPosition() EPC.EncounterReminders:Refresh() end end,
            width = "half",
        },
        {
            type = "header", name = "Lore Book Locations",
        },
        {
            type = "checkbox", name = "Enable Lore Books & Scrolls",
            tooltip = "Master switch for all Lore Book, Eidetic Memory, and scroll location markers. Turn this off when you are not hunting books to hide the feature everywhere.",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("loreBooksEnabled", v == true) end end,
            default = true,
        },
        {
            type = "description",
            title = "Undiscovered books on map, compass and in the world",
            text = "Use the master switch to hide all Lore Book and scroll hunting markers when you are not looking for them. Lore Books are enabled by default and Eidetic Memory books start disabled. Some locations are quest-gated: the marker can show where the book will be, but ESO may not spawn the book until its related quest has been completed. Right-click a book in Journal > Lore Library to use Show on Map.",
        },
        {
            type = "checkbox", name = "Show undiscovered Lore Books",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:IsPinTypeEnabled(EASLoreLibrary.LOREBOOK) or false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:SetPinTypeEnabled(EASLoreLibrary.LOREBOOK, v == true) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = true,
        },
        {
            type = "checkbox", name = "Show Eidetic Memory books",
            tooltip = "Disabled by default. You can also toggle this from the World Map filter panel.",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:IsPinTypeEnabled(EASLoreLibrary.EIDETICBOOK) or false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:SetPinTypeEnabled(EASLoreLibrary.EIDETICBOOK, v == true) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = false,
        },
        {
            type = "checkbox", name = "Book markers on compass",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("compassPinsEnabled") ~= false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("compassPinsEnabled", v == true) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = true,
            width = "half",
        },
        {
            type = "checkbox", name = "Book markers in 3D world",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("worldPinsEnabled") ~= false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("worldPinsEnabled", v == true) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = true,
            width = "half",
        },
        {
            type = "checkbox", name = "Hide quest-dependent books in 3D",
            tooltip = "Recommended. Suppresses floating 3D icons for known quest-phased books/documents whose physical object may not exist at that location yet. Map and compass guidance remain available.",
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("hideQuestDependentWorldPins") ~= false end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("hideQuestDependentWorldPins", v == true) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = true,
        },
        {
            type = "description",
            text = "Known phased examples include Tava's Bounty Ledger and other quest-linked Eidetic documents. The location stays visible on the map/compass; only the potentially misleading floating 3D icon is hidden.",
        },
        {
            type = "slider", name = "Compass book distance", min = 100, max = 2000, step = 100,
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and (tonumber(EASLoreLibrary.settings:Get("compassPinsDistance")) or 300) or 300 end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("compassPinsDistance", tonumber(v) or 300) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = 300,
            width = "half",
        },
        {
            type = "slider", name = "3D book distance", min = 100, max = 1000, step = 50,
            getFunc = function() return EASLoreLibrary and EASLoreLibrary.settings and (tonumber(EASLoreLibrary.settings:Get("worldPinsDistance")) or 250) or 250 end,
            setFunc = function(v) if EASLoreLibrary and EASLoreLibrary.settings then EASLoreLibrary.settings:Set("worldPinsDistance", tonumber(v) or 250) end end,
            disabled = function() return not (EASLoreLibrary and EASLoreLibrary.settings and EASLoreLibrary.settings:Get("loreBooksEnabled") ~= false) end,
            default = 250,
            width = "half",
        },
        {
            type = "header", name = "World Combat Visibility",
        },
        {
            type = "checkbox", name = "Show outgoing damage numbers",
            tooltip = "Enables ESO scrolling combat text for your direct damage, damage-over-time ticks, and pet damage so hits pop over enemies.",
            getFunc = function() return EPC.saved.showOutgoingDamageNumbers ~= false end,
            setFunc = function(v) EPC.saved.showOutgoingDamageNumbers = v == true if EPC.CombatPresentation then EPC.CombatPresentation:Refresh() end end,
            default = EPC.defaults.showOutgoingDamageNumbers,
        },
        {
            type = "checkbox", name = "Show taunts & combat status effects",
            tooltip = "Enables ESO status-effect combat text and target debuffs so taunts, crowd-control/debuff feedback, interrupts and similar status events are easier to see when ESO exposes them.",
            getFunc = function() return EPC.saved.showCombatStatusEffects ~= false end,
            setFunc = function(v) EPC.saved.showCombatStatusEffects = v == true if EPC.CombatPresentation then EPC.CombatPresentation:Refresh() end end,
            default = EPC.defaults.showCombatStatusEffects,
        },
        {
            type = "header", name = "Persistent HUD & Unit Frames",
        },
        {
            type = "description",
            title = "Player / Target / Group / Raid / Mini Map HUD",
            text = "ESO-style replacement HUD. Player shows Health/Magicka/Stamina without name/level text; Target shows Health only. Player/Target resource fills now extend beneath the ESO end caps so full bars look completely filled. Group and Raid use matching ESO-style framed Health bars; active companions remain a second Health + Level entry. Ability icons (skills 1-5 plus Ultimate) are independently movable. Normal gameplay overlays keep Always / Combat Only modes; the Repair / Recharge Estimate instead offers Always / Tamriel Codex Only.",
        },
        {
            type = "header", name = "Stable Training Timer",
        },
        {
            type = "description",
            title = "Next riding upgrade",
            text = "Shows the character's actual stable riding-training cooldown. When the overlay reaches 0 - READY, you can visit a stable and train Riding Speed, Stamina, or Carry Capacity again.",
        },
        {
            type = "checkbox", name = "Show stable training timer",
            tooltip = "Counts down the ESO riding-training cooldown. 0 - READY means stable training is available now.",
            getFunc = function() return EPC.saved.showStableTimer ~= false end,
            setFunc = function(v) EPC.saved.showStableTimer = v == true if EPC.StableTimer then EPC.StableTimer:Refresh() end end,
            default = EPC.defaults.showStableTimer,
        },
        {
            type = "dropdown", name = "Stable timer visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.stableTimerVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.stableTimerVisibility = v if EPC.StableTimer then EPC.StableTimer:Refresh() end end,
            default = EPC.defaults.stableTimerVisibility,
        },
        {
            type = "button", name = "Reset stable timer position", buttonText = "Reset Stable Timer",
            func = function() if EPC.StableTimer then EPC.StableTimer:ResetPosition() EPC.StableTimer:Refresh() end end,
        },
        {
            type = "header", name = "Clock",
        },
        {
            type = "checkbox", name = "Show clock",
            tooltip = "Shows a simple 12-hour local clock such as 3:50 PM. Use HUD layout mode to drag it anywhere.",
            getFunc = function() return EPC.saved.showClock ~= false end,
            setFunc = function(v) EPC.saved.showClock = v == true if EPC.Clock then EPC.Clock:Refresh() end end,
            default = EPC.defaults.showClock,
        },
        {
            type = "dropdown", name = "Clock visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.clockVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.clockVisibility = v if EPC.Clock then EPC.Clock:Refresh() end end,
            default = EPC.defaults.clockVisibility,
        },
        {
            type = "button", name = "Reset clock position", buttonText = "Reset Clock",
            func = function() if EPC.Clock then EPC.Clock:ResetPosition() EPC.Clock:Refresh() end end,
        },
        {
            type = "header", name = "Quest Tracking",
        },
        {
            type = "dropdown", name = "Quest tracker source",
            tooltip = "Choose the single authoritative quest source used by the Suite tracker and ESO assisted quest/compass. Active Quest follows your selected non-main Suite Quest Finder/journal quest. Golden Pursuits follows the journal quest linked to your selected Golden Pursuit. Main Quest follows the remembered Main Story quest. The selected Suite source takes priority over ESO native tracking; the other two selections are remembered but cannot intervene.",
            choices = { "Active Quest", "Golden Pursuits", "Main Quest" },
            choicesValues = { "ACTIVE_QUEST", "GOLDEN_PURSUITS", "MAIN_QUEST" },
            getFunc = function()
                if EPC.ActiveQuest and EPC.ActiveQuest.GetQuestTrackingSource2513 then
                    return EPC.ActiveQuest:GetQuestTrackingSource2513()
                end
                return EPC.saved.questTrackingSource or "ACTIVE_QUEST"
            end,
            setFunc = function(v)
                if EPC.ActiveQuest and EPC.ActiveQuest.SetQuestTrackingSource2513 then
                    EPC.ActiveQuest:SetQuestTrackingSource2513(v)
                else
                    EPC.saved.questTrackingSource = v
                end
            end,
            default = EPC.defaults.questTrackingSource or "ACTIVE_QUEST",
        },
        {
            type = "header", name = "Active Quest Overlay",
        },
        {
            type = "checkbox", name = "Show active quest overlay",
            tooltip = "Shows your focused/tracked quest and current incomplete objectives as a background-free movable/resizable text overlay. Long quest text wraps to the current width. It updates as objectives advance or you focus a different quest.",
            getFunc = function() return EPC.saved.showActiveQuestOverlay ~= false end,
            setFunc = function(v) EPC.saved.showActiveQuestOverlay = v == true if EPC.ActiveQuest then EPC.ActiveQuest:Refresh() end end,
            default = EPC.defaults.showActiveQuestOverlay,
        },
        {
            type = "dropdown", name = "Active quest visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.activeQuestVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.activeQuestVisibility = v if EPC.ActiveQuest then EPC.ActiveQuest:Refresh() end end,
            default = EPC.defaults.activeQuestVisibility,
        },
        {
            type = "button", name = "Reset active quest position", buttonText = "Reset Active Quest",
            func = function() if EPC.ActiveQuest then EPC.ActiveQuest:ResetPosition() EPC.ActiveQuest:Refresh() end end,
        },
        {
            type = "slider", name = "Active quest width", min = 280, max = 900, step = 10,
            tooltip = "Changes the quest overlay width. Long quest names and objectives wrap inside this width.",
            getFunc = function() return tonumber(EPC.saved.activeQuestWidth) or 420 end,
            setFunc = function(v) EPC.saved.activeQuestWidth = v if EPC.ActiveQuest then EPC.ActiveQuest:SetSize(v, tonumber(EPC.saved.activeQuestHeight) or 160) end end,
            default = EPC.defaults.activeQuestWidth or 420,
        },
        {
            type = "slider", name = "Active quest height", min = 120, max = 520, step = 10,
            tooltip = "Changes how much wrapped objective text can be visible at once.",
            getFunc = function() return tonumber(EPC.saved.activeQuestHeight) or 160 end,
            setFunc = function(v) EPC.saved.activeQuestHeight = v if EPC.ActiveQuest then EPC.ActiveQuest:SetSize(tonumber(EPC.saved.activeQuestWidth) or 420, v) end end,
            default = EPC.defaults.activeQuestHeight or 160,
        },
        {
            type = "button", name = "Reset active quest size", buttonText = "Reset Quest Size",
            func = function() if EPC.ActiveQuest then EPC.ActiveQuest:ResetSize() end end,
        },
        {
            type = "header", name = "Alliance Rank Overlay",
        },
        {
            type = "checkbox", name = "Show Alliance Rank overlay",
            tooltip = "ESO-style PvP rank icon and Alliance Rank progress. It is movable in HUD Layout Mode and independently scalable.",
            getFunc = function() return EPC.saved.showAllianceRank ~= false end,
            setFunc = function(v) EPC.saved.showAllianceRank = v == true if EPC.AllianceRank then EPC.AllianceRank:Refresh() end end,
            default = EPC.defaults.showAllianceRank,
        },
        {
            type = "dropdown", name = "Alliance Rank visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.allianceRankVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.allianceRankVisibility = v if EPC.AllianceRank then EPC.AllianceRank:Refresh() end end,
            default = EPC.defaults.allianceRankVisibility,
        },
        {
            type = "slider", name = "Alliance Rank scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.allianceRankScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.allianceRankScale = v / 100 if EPC.AllianceRank then EPC.AllianceRank:Refresh() end end,
            default = math.floor((EPC.defaults.allianceRankScale or 1.0) * 100),
        },
        {
            type = "button", name = "Reset Alliance Rank position", buttonText = "Reset Alliance Rank",
            func = function() if EPC.AllianceRank then EPC.AllianceRank:ResetPosition() EPC.AllianceRank:Refresh() end end,
        },
        {
            type = "header", name = "Champion Level Overlay",
        },
        {
            type = "checkbox", name = "Show Champion overlay",
            tooltip = "Shows the movable ESO-style Champion/level overlay with Craft, Warfare, and Fitness Champion Point symbols.",
            getFunc = function() return EPC.saved.showChampionOverlay ~= false end,
            setFunc = function(v)
                EPC.saved.showChampionOverlay = v == true
                if EPC.ChampionOverlay then EPC.ChampionOverlay:Refresh() end
            end,
            default = EPC.defaults.showChampionOverlay,
        },
        {
            type = "dropdown", name = "Champion overlay visibility",
            tooltip = "Always On keeps the Champion overlay visible during gameplay. Champion Point Gain Only shows it for 10 seconds whenever any Craft, Warfare, or Fitness Champion Point is earned, then hides it again.",
            choices = { "Always On", "Champion Point Gain Only" },
            choicesValues = { "ALWAYS", "GAIN" },
            getFunc = function()
                return (EPC.saved.championOverlayVisibility == "GAIN") and "GAIN" or "ALWAYS"
            end,
            setFunc = function(v)
                if EPC.ChampionOverlay and EPC.ChampionOverlay.SetVisibilityMode2518 then
                    EPC.ChampionOverlay:SetVisibilityMode2518(v)
                else
                    EPC.saved.championOverlayVisibility = (v == "GAIN") and "GAIN" or "ALWAYS"
                end
            end,
            default = EPC.defaults.championOverlayVisibility or "ALWAYS",
        },
        {
            type = "button", name = "Reset Champion overlay position", buttonText = "Reset Champion",
            func = function() if EPC.ChampionOverlay then EPC.ChampionOverlay:ResetPosition() EPC.ChampionOverlay:Refresh() end end,
        },
        {
            type = "header", name = "Ability Overlays",
        },
        {
            type = "checkbox", name = "Show ability overlays",
            tooltip = "Shows your five normal slotted skills (positions 1-5) plus Ultimate as separate icon overlays. Passive/non-normal slots remain excluded. Each icon can be dragged independently in HUD Layout Mode.",
            getFunc = function() return EPC.saved.showAbilityOverlays ~= false end,
            setFunc = function(v) EPC.saved.showAbilityOverlays = v == true if EPC.AbilityOverlays then EPC.AbilityOverlays:Refresh() end end,
            default = EPC.defaults.showAbilityOverlays,
        },
        {
            type = "dropdown", name = "Ability overlays visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.abilityOverlayVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.abilityOverlayVisibility = v if EPC.AbilityOverlays then EPC.AbilityOverlays:Refresh() end end,
            default = EPC.defaults.abilityOverlayVisibility,
        },
        {
            type = "slider", name = "Ability icon size", min = 40, max = 90, step = 2,
            tooltip = "Changes all custom ability icon sizes while keeping each icon's saved position independent.",
            getFunc = function() return tonumber(EPC.saved.abilityOverlaySize) or 56 end,
            setFunc = function(v) EPC.saved.abilityOverlaySize = v if EPC.AbilityOverlays then EPC.AbilityOverlays:Refresh() end end,
            default = EPC.defaults.abilityOverlaySize or 56,
        },
        {
            type = "slider", name = "Ability overlay scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.abilityOverlayScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.abilityOverlayScale = v / 100 if EPC.AbilityOverlays then EPC.AbilityOverlays:Refresh() end end,
            default = math.floor((EPC.defaults.abilityOverlayScale or 1.0) * 100),
        },
        {
            type = "button", name = "Reset ability positions", buttonText = "Reset Abilities",
            func = function() if EPC.AbilityOverlays then EPC.AbilityOverlays:ResetPositions() EPC.AbilityOverlays:Refresh() end end,
        },
        {
            type = "header", name = "Custom ESO Reticle",
        },
        {
            type = "checkbox", name = "Use custom reticle",
            tooltip = "Replaces only ESO's center crosshair graphic. Interaction prompts, target text, stealth indicators, and normal ESO reticle functionality remain available.",
            getFunc = function() return EPC.saved.customReticleEnabled == true end,
            setFunc = function(v) EPC.saved.customReticleEnabled = v == true if EPC.Reticle then EPC.Reticle:Refresh() end end,
            default = EPC.defaults.customReticleEnabled,
        },
        {
            type = "dropdown", name = "Reticle style",
            choices = { "ESO Default", "Tamriel Rune", "Corner Brackets", "Compass Cross", "Minimal Cross", "Daedric Diamond", "Ayleid Star", "Dragon Eye" },
            choicesValues = { "DEFAULT", "RUNE", "BRACKETS", "COMPASS", "MINIMAL", "DAEDRIC", "AYLEID", "DRAGON" },
            getFunc = function() return EPC.saved.customReticleStyle or "RUNE" end,
            setFunc = function(v) EPC.saved.customReticleStyle = v if EPC.Reticle then EPC.Reticle:Refresh() end end,
            default = EPC.defaults.customReticleStyle,
        },
        {
            type = "dropdown", name = "Reticle color",
            choices = { "ESO Gold", "Ivory", "Crimson", "Arcane Blue", "RGB Rainbow" },
            choicesValues = { "GOLD", "IVORY", "CRIMSON", "BLUE", "RGB" },
            getFunc = function() return EPC.saved.customReticleColor or "GOLD" end,
            setFunc = function(v) EPC.saved.customReticleColor = v if EPC.Reticle then EPC.Reticle:Refresh() end end,
            default = EPC.defaults.customReticleColor,
            disabled = function() return EPC.saved.customReticleStyle == "DEFAULT" end,
        },
        {
            type = "slider", name = "Reticle size", min = 60, max = 180, step = 5,
            tooltip = "Scales the custom reticle while keeping it centered on ESO's aim point.",
            getFunc = function() return tonumber(EPC.saved.customReticleSize) or 100 end,
            setFunc = function(v) EPC.saved.customReticleSize = v if EPC.Reticle then EPC.Reticle:Refresh() end end,
            default = EPC.defaults.customReticleSize,
            disabled = function() return EPC.saved.customReticleStyle == "DEFAULT" end,
        },
        {
            type = "slider", name = "Reticle opacity", min = 25, max = 100, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.customReticleOpacity) or 0.95) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.customReticleOpacity = v / 100 if EPC.Reticle then EPC.Reticle:Refresh() end end,
            default = math.floor((EPC.defaults.customReticleOpacity or 0.95) * 100 + 0.5),
            disabled = function() return EPC.saved.customReticleStyle == "DEFAULT" end,
        },
        {
            type = "header", name = "Tamriel Codex",
        },
        {
            type = "description",
            title = "Tamriel Codex hotkey",
            text = "Assign 'Open / Close Tamriel Codex' under Controls > Keybindings > General > ESO Adventurer Suite. The same hotkey opens and closes the book, including while the Codex has UI focus. The Tamriel Codex is presented as a two-page lore-style book with animated page turns, categorized personal notes with auto-save, Read/Edit modes, named checkpoints, roleplay dice and coin toss, quest/achievement records, game statistics, and crafting reference pages. The Codex uses clear ESO UI fonts instead of the cursive book script for easier reading.",
        },
        {
            type = "button", name = "Open Tamriel Codex", buttonText = "Open Codex",
            func = function() if EPC.Journal then EPC.Journal:Show() end end,
        },
        {
            type = "checkbox", name = "Hide Suite HUD in menus / map",
            tooltip = "Recommended and enabled by default. Hides Player, Target, Group, Raid, Live Stats, Stable Training timer, Clock, Active Quest, Mini Map, Alliance Rank, and combat HUD while Pause, Character, Inventory, the full World Map, Journal, Crafting, Store, Collections, and similar UI scenes are open. Restores them automatically in gameplay.",
            getFunc = function() return EPC.saved.hudHideInMenus ~= false end,
            setFunc = function(v) EPC.saved.hudHideInMenus = v == true if EPC.RefreshGameplayOverlays then EPC:RefreshGameplayOverlays() end end,
            default = EPC.defaults.hudHideInMenus,
        },
        {
            type = "checkbox", name = "Replace ESO default unit frames",
            tooltip = "When enabled, The suite hides ESO's native player resource bars, target frame, group/raid frames, and local companion unit frame using reason-scoped UI hiding. Turn this off to restore the native frames while keeping the suite's frames available.",
            getFunc = function() return EPC.saved.replaceDefaultUnitFrames ~= false end,
            setFunc = function(v) EPC.saved.replaceDefaultUnitFrames = v == true if EPC.UnitFrames then EPC.UnitFrames:ApplyDefaultFrameReplacement() EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.replaceDefaultUnitFrames,
        },
        {
            type = "checkbox", name = "Show player frame",
            tooltip = "ESO-style scalable self frame. Buffs appear above Health, debuffs below Health, with native-style Health, Magicka, and Stamina bars underneath.",
            getFunc = function() return EPC.saved.showPlayerFrame ~= false end,
            setFunc = function(v) EPC.saved.showPlayerFrame = v == true if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.showPlayerFrame,
        },
        {
            type = "dropdown", name = "Player frame visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.playerFrameVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.playerFrameVisibility = v if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.playerFrameVisibility,
        },
        {
            type = "checkbox", name = "Show target frame",
            tooltip = "ESO-style scalable target frame. It shows target identity and Health only, with buffs above Health and debuffs below. No Magicka or Stamina bars are shown for targets.",
            getFunc = function() return EPC.saved.showTargetFrame ~= false end,
            setFunc = function(v) EPC.saved.showTargetFrame = v == true if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.showTargetFrame,
        },
        {
            type = "dropdown", name = "Target frame visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.targetFrameVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.targetFrameVisibility = v if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.targetFrameVisibility,
        },
        {
            type = "checkbox", name = "Show group frame",
            tooltip = "Shows player/member name, level/CP, role/status, Health, and companion name + companion level where ESO exposes it. Also appears for you + your active companion while solo.",
            getFunc = function() return EPC.saved.showGroupFrame ~= false end,
            setFunc = function(v) EPC.saved.showGroupFrame = v == true if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.showGroupFrame,
        },
        {
            type = "dropdown", name = "Group frame visibility", choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.groupFrameVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.groupFrameVisibility = v if EPC.UnitFrames then EPC.UnitFrames:RefreshGroupFrames() end end,
            default = EPC.defaults.groupFrameVisibility,
        },
        {
            type = "checkbox", name = "Show raid frame",
            tooltip = "Shows a compact multi-column raid/trial frame with member name, level/CP, role/status, and Health.",
            getFunc = function() return EPC.saved.showRaidFrame ~= false end,
            setFunc = function(v) EPC.saved.showRaidFrame = v == true if EPC.UnitFrames then EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.showRaidFrame,
        },
        {
            type = "dropdown", name = "Raid frame visibility", choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.raidFrameVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.raidFrameVisibility = v if EPC.UnitFrames then EPC.UnitFrames:RefreshGroupFrames() end end,
            default = EPC.defaults.raidFrameVisibility,
        },
        {
            type = "checkbox", name = "Show live combat stat panel",
            tooltip = "PEN, PWR, Spell Resistance, Physical Resistance, Critical Chance, and Critical Damage. Combat-only visibility is enabled by default so it stays off-screen while idle.",
            getFunc = function() return EPC.saved.showCombatStatsFrame ~= false end,
            setFunc = function(v) EPC.saved.showCombatStatsFrame = v == true if EPC.UnitFrames then EPC.UnitFrames:RefreshStats() end end,
            default = EPC.defaults.showCombatStatsFrame,
        },
        {
            type = "dropdown", name = "Live Combat Stats visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.combatStatsVisibility or "COMBAT" end,
            setFunc = function(v) EPC.saved.combatStatsVisibility = v if EPC.UnitFrames then EPC.UnitFrames:RefreshStats() end end,
            default = EPC.defaults.combatStatsVisibility,
        },
        {
            type = "header", name = "Mini Map",
        },
        {
            type = "checkbox", name = "Show mini map",
            tooltip = "Shows EPC's intelligent north-up navigation minimap. It auto-declutters by mode/context and always hides while ESO's full World Map is open.",
            getFunc = function() return EPC.saved.showMiniMap ~= false end,
            setFunc = function(v) EPC.saved.showMiniMap = v == true if EPC.MiniMap then EPC.MiniMap:Refresh(true) end end,
            default = EPC.defaults.showMiniMap,
        },
        {
            type = "dropdown", name = "Mini map visibility", choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.miniMapVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.miniMapVisibility = v if EPC.MiniMap then EPC.MiniMap:Refresh(true) end end,
            default = EPC.defaults.miniMapVisibility,
        },
        {
            type = "dropdown", name = "Mini map intelligence mode",
            tooltip = "SMART changes visible layers with context. QUEST focuses objectives, EXPLORE emphasizes nearby/unfinished POIs, GROUP prioritizes teammates/rally, MINIMAL shows only essential navigation, and CUSTOM honors all layer toggles.",
            choices = { "Smart", "Quest", "Explore", "Group", "Minimal", "Custom" },
            choicesValues = { "SMART", "QUEST", "EXPLORE", "GROUP", "MINIMAL", "CUSTOM" },
            getFunc = function() return EPC.MiniMap and EPC.MiniMap:GetMode() or (EPC.saved.miniMapMode or "SMART") end,
            setFunc = function(v) if EPC.MiniMap then EPC.MiniMap:SetMode(v) else EPC.saved.miniMapMode = v end end,
            default = EPC.defaults.miniMapMode,
        },
        {
            type = "checkbox", name = "Adaptive zoom",
            tooltip = "Automatically zooms out while mounted and closer in combat, then returns to your base zoom without overwriting it.",
            getFunc = function() return EPC.saved.miniMapAdaptiveZoom ~= false end,
            setFunc = function(v) EPC.saved.miniMapAdaptiveZoom = v == true if EPC.MiniMap then EPC.MiniMap:RebuildMap(true) end end,
            default = EPC.defaults.miniMapAdaptiveZoom,
            width = "half",
        },
        {
            type = "checkbox", name = "Edge guidance",
            tooltip = "Keeps important off-screen quest, waypoint, rally, and group-leader markers clamped to the mini map edge instead of hiding them.",
            getFunc = function() return EPC.saved.miniMapEdgeGuidance ~= false end,
            setFunc = function(v) EPC.saved.miniMapEdgeGuidance = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapEdgeGuidance,
            width = "half",
        },
        {
            type = "slider", name = "Mini map size", min = 180, max = 420, step = 10,
            tooltip = "Physical minimap size in UI units.",
            getFunc = function() return tonumber(EPC.saved.miniMapSize) or 260 end,
            setFunc = function(v) EPC.saved.miniMapSize = math.floor(v) if EPC.MiniMap then EPC.MiniMap:ApplySizeAndStyle() EPC.MiniMap:Refresh(true) end end,
            default = EPC.defaults.miniMapSize,
        },
        {
            type = "slider", name = "Mini map zoom", min = 70, max = 200, step = 5,
            tooltip = "Higher values zoom closer to your character. You can also use /esosuite minimap zoom 1.25 or the mouse wheel while Mini Map Move Mode is active.",
            getFunc = function() return math.floor((tonumber(EPC.saved.miniMapZoom) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.miniMapZoom = v / 100 if EPC.MiniMap then EPC.MiniMap:RebuildMap(true) EPC.MiniMap:Refresh(true) end end,
            default = math.floor((EPC.defaults.miniMapZoom or 1.0) * 100),
        },
        {
            type = "slider", name = "Mini map opacity", min = 35, max = 100, step = 1,
            tooltip = "Opacity of the complete mini map widget.",
            getFunc = function() return math.floor((tonumber(EPC.saved.miniMapAlpha) or 0.92) * 100) end,
            setFunc = function(v) EPC.saved.miniMapAlpha = v / 100 if EPC.MiniMap then EPC.MiniMap:ApplySizeAndStyle() end end,
            default = math.floor((EPC.defaults.miniMapAlpha or 0.92) * 100),
        },
        {
            type = "slider", name = "Map texture opacity", min = 40, max = 100, step = 1,
            tooltip = "Controls the map-art opacity inside the mini map separately from markers.",
            getFunc = function() return math.floor((tonumber(EPC.saved.miniMapMapAlpha) or 0.86) * 100) end,
            setFunc = function(v) EPC.saved.miniMapMapAlpha = v / 100 if EPC.MiniMap then EPC.MiniMap:RebuildMap(true) end end,
            default = math.floor((EPC.defaults.miniMapMapAlpha or 0.86) * 100),
        },
        {
            type = "checkbox", name = "Mini map: focused quest",
            tooltip = "Show the current assisted quest objective when ESO exposes an exact map position.",
            getFunc = function() return EPC.saved.miniMapShowQuest ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowQuest = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowQuest,
        },
        {
            type = "checkbox", name = "Mini map: player waypoint",
            tooltip = "Show your ESO player waypoint when it is on the current map.",
            getFunc = function() return EPC.saved.miniMapShowWaypoint ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowWaypoint = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowWaypoint,
        },
        {
            type = "checkbox", name = "Mini map: discovered wayshrines",
            tooltip = "Show discovered/unlocked wayshrines that ESO reports on the current map.",
            getFunc = function() return EPC.saved.miniMapShowWayshrines ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowWayshrines = v == true if EPC.MiniMap then EPC.MiniMap:RefreshStaticPins() EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowWayshrines,
        },
        {
            type = "checkbox", name = "Mini map: group members",
            tooltip = "Show group members when ESO reports their position on your current map.",
            getFunc = function() return EPC.saved.miniMapShowGroup ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowGroup = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowGroup,
        },
        {
            type = "checkbox", name = "Mini map: companion",
            tooltip = "Show your active companion when ESO reports the companion on your current map.",
            getFunc = function() return EPC.saved.miniMapShowCompanion ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowCompanion = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowCompanion,
        },
        {
            type = "checkbox", name = "Mini map: live POIs",
            tooltip = "Uses ESO's current-map POI API and shows all POIs ESO reports as visible on the current map. Pins are clustered to avoid icon spam.",
            getFunc = function() return EPC.saved.miniMapShowPOIs ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowPOIs = v == true if EPC.MiniMap then EPC.MiniMap:RefreshStaticPins() EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowPOIs,
            width = "half",
        },
        {
            type = "checkbox", name = "Mini map: rally point",
            tooltip = "Shows the active group rally point and keeps it on the map edge when it is outside the visible area.",
            getFunc = function() return EPC.saved.miniMapShowRally ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowRally = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowRally,
            width = "half",
        },
        {
            type = "checkbox", name = "Mini map: movement trail",
            tooltip = "Shows a short fading breadcrumb trail behind your character. SMART hides the trail during combat to reduce clutter.",
            getFunc = function() return EPC.saved.miniMapShowTrail ~= false end,
            setFunc = function(v) EPC.saved.miniMapShowTrail = v == true if EPC.MiniMap then EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapShowTrail,
            width = "half",
        },
        {
            type = "slider", name = "Mini map POI density", min = 24, max = 160, step = 4,
            tooltip = "Maximum number of visible POI pins rendered at once. Towns no longer cluster nearby POIs, so higher values keep service and landmark icons visible.",
            getFunc = function() return tonumber(EPC.saved.miniMapPOIMax) or 120 end,
            setFunc = function(v) EPC.saved.miniMapPOIMax = math.floor(v) if EPC.MiniMap then EPC.MiniMap:RefreshStaticPins() EPC.MiniMap:UpdatePanAndPins(true) end end,
            default = EPC.defaults.miniMapPOIMax,
        },
        {
            type = "button", name = "Mini Map position", buttonText = "Move Mini Map",
            tooltip = "Unlocks only the Mini Map and activates a full-map drag surface so clicks cannot be intercepted by map tiles or pins. Drag anywhere on the map; its position is saved automatically.",
            func = function() if EPC.SetMiniMapMoveMode then EPC:SetMiniMapMoveMode(true) end end,
            width = "half",
        },
        {
            type = "button", name = "Lock Mini Map", buttonText = "Lock Mini Map",
            tooltip = "Ends Mini Map Move Mode and returns the map to non-interactive gameplay behavior.",
            func = function() if EPC.SetMiniMapMoveMode then EPC:SetMiniMapMoveMode(false) end end,
            width = "half",
        },
        {
            type = "button", name = "Reset Mini Map position", buttonText = "Reset Mini Map",
            tooltip = "Restores only the Mini Map to its default upper-right position.",
            func = function() if EPC.ResetMiniMapPosition then EPC:ResetMiniMapPosition() end end,
        },
        {
            type = "button", name = "Clear legacy map icons", buttonText = "Clear Legacy Icons",
            tooltip = "Deletes only the old walk-up/interaction-saved merchant, crafting/service, and remembered POI icons from pre-0.27 minimap builds. Native ESO town icons, checkpoints, routes, and minimap settings are kept. Legacy walk-up icon learning stays disabled so the old duplicates do not return.",
            func = function()
                if EPC.MiniMap and EPC.MiniMap.ClearLegacyMapIcons then
                    EPC.MiniMap:ClearLegacyMapIcons()
                end
            end,
        },
        {
            type = "button", name = "HUD layout mode", buttonText = "Move Frames",
            tooltip = "Releases the mouse and shows Player, Target, Group, Raid, Stats, Mini Map, Stable, Clock, Active Quest, Alliance Rank, Repair Estimate, and every Ability icon so each can be dragged independently. Active Quest can also be resized from its edges/corners.",
            func = function() if EPC.SetUnitFramesMoveMode then EPC:SetUnitFramesMoveMode(true) end end,
            width = "half",
        },
        {
            type = "button", name = "Lock HUD frames", buttonText = "Lock Frames",
            tooltip = "Ends HUD layout mode and returns all persistent frames to non-interactive gameplay behavior.",
            func = function() if EPC.SetUnitFramesMoveMode then EPC:SetUnitFramesMoveMode(false) end end,
            width = "half",
        },
        {
            type = "button", name = "Reset HUD frame positions", buttonText = "Reset Frames",
            tooltip = "Restores default positions for Player, Target, Group, Raid, Live Combat Stats, Mini Map, Stable, Clock, Active Quest, Alliance Rank, Repair Estimate, and every Ability icon.",
            func = function() if EPC.ResetUnitFramePositions then EPC:ResetUnitFramePositions() end end,
        },
        {
            type = "slider", name = "Player frame size", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((EPC.saved.playerFrameScale or EPC.saved.unitFrameScale or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.playerFrameScale = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyScalesAndAlpha() end end,
            default = math.floor((EPC.defaults.playerFrameScale or 1.0) * 100),
        },
        {
            type = "slider", name = "Target frame size", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((EPC.saved.targetFrameScale or EPC.saved.unitFrameScale or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.targetFrameScale = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyScalesAndAlpha() end end,
            default = math.floor((EPC.defaults.targetFrameScale or 1.0) * 100),
        },
        {
            type = "slider", name = "Group / Raid frame scale", min = 65, max = 150, step = 5,
            getFunc = function() return math.floor((EPC.saved.groupFrameScale or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.groupFrameScale = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyScalesAndAlpha() end end,
            default = math.floor((EPC.defaults.groupFrameScale or 1.0) * 100),
        },
        {
            type = "slider", name = "Live stats panel scale", min = 65, max = 150, step = 5,
            getFunc = function() return math.floor((EPC.saved.combatStatsScale or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.combatStatsScale = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyScalesAndAlpha() end end,
            default = math.floor((EPC.defaults.combatStatsScale or 1.0) * 100),
        },
        {
            type = "checkbox", name = "Use stronger HUD panel backgrounds",
            tooltip = "Optional stronger panel style. Leave this off for the compact soft-background look.",
            getFunc = function() return EPC.saved.unitFrameBackgrounds == true end,
            setFunc = function(v) EPC.saved.unitFrameBackgrounds = v == true if EPC.UnitFrames then EPC.UnitFrames:ApplyVisualStyle() end end,
            default = EPC.defaults.unitFrameBackgrounds,
        },
        {
            type = "checkbox", name = "Dark HUD backgrounds",
            tooltip = "On by default. Adds compact dark readable backgrounds behind Player, Target, Group/Raid, aura slots, and Live Combat Stats without increasing their footprint.",
            getFunc = function() return EPC.saved.unitFrameSoftBackground ~= false end,
            setFunc = function(v) EPC.saved.unitFrameSoftBackground = v == true if EPC.UnitFrames then EPC.UnitFrames:ApplyVisualStyle() end end,
            default = EPC.defaults.unitFrameSoftBackground,
        },
        {
            type = "slider", name = "HUD background opacity", min = 45, max = 95, step = 1,
            tooltip = "Controls the dark panel opacity. v0.9.3 defaults to 72% so the world does not wash through the HUD text and bars.",
            getFunc = function() return math.floor((EPC.saved.unitFrameBackgroundAlpha or 0.20) * 100) end,
            setFunc = function(v) EPC.saved.unitFrameBackgroundAlpha = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyVisualStyle() end end,
            default = math.floor((EPC.defaults.unitFrameBackgroundAlpha or 0.20) * 100),
        },
        {
            type = "slider", name = "Floating HUD opacity", min = 35, max = 100, step = 1,
            tooltip = "Adjusts text, bars, icons, and accents. Soft background opacity is controlled separately.",
            getFunc = function() return math.floor((EPC.saved.unitFrameAlpha or 0.94) * 100) end,
            setFunc = function(v) EPC.saved.unitFrameAlpha = v / 100 if EPC.UnitFrames then EPC.UnitFrames:ApplyScalesAndAlpha() end end,
            default = math.floor((EPC.defaults.unitFrameAlpha or 0.94) * 100),
        },
        {
            type = "slider", name = "Target aura icons per type", min = 3, max = 6, step = 1,
            tooltip = "Compact target layout. Shows 3-6 prioritized buff icons and 3-6 prioritized debuff icons side-by-side. Extra effects are summarized as +N instead of expanding the frame.",
            getFunc = function() return math.max(3, math.min(6, tonumber(EPC.saved.targetAuraCount) or 5)) end,
            setFunc = function(v) EPC.saved.targetAuraCount = math.max(3, math.min(6, math.floor(v))) if EPC.UnitFrames then EPC.UnitFrames:RefreshTargetAuras(false) end end,
            default = EPC.defaults.targetAuraCount,
        },
        {
            type = "checkbox", name = "Auto-expand in interaction mode",
            tooltip = "If the suite is minimized, the Interact with Suite hotkey expands it automatically.",
            getFunc = function() return EPC.saved.autoExpandInteract ~= false end,
            setFunc = function(v) EPC.saved.autoExpandInteract = v == true end,
            default = EPC.defaults.autoExpandInteract,
        },
        {
            type = "dropdown", name = "Endgame suite focus",
            tooltip = "At level 50+, BUILD and ACTIVITY adapt to this goal. Auto detects questing, grouped dungeon/trial context, and support-role defaults; manual focus overrides it.",
            choices = { "Auto (context aware)", "DPS", "Gold", "XP / CP", "Gear", "Dungeons", "Trials", "Solo", "Questing" },
            choicesValues = { "AUTO", "DPS", "GOLD", "XP_CP", "GEAR", "DUNGEONS", "TRIALS", "SOLO", "QUESTING" },
            getFunc = function() return EPC.Endgame and EPC.Endgame:GetFocus() or (EPC.saved.coachFocus or "DPS") end,
            setFunc = function(v)
                if EPC.Endgame then EPC.Endgame:SetFocus(v) else EPC.saved.coachFocus = v end
            end,
            default = EPC.defaults.coachFocus,
        },
        {
            type = "checkbox", name = "Intelligent Next Best Move",
            tooltip = "Combines role, build, gear, activities, combat history, and current context into one recommended next action on the BUILD tab.",
            getFunc = function() return EPC.saved.smartCoach ~= false end,
            setFunc = function(v) EPC.saved.smartCoach = v == true EPC:RequestRefresh("smart-coach") end,
            default = EPC.defaults.smartCoach,
        },
        {
            type = "header", name = "Target Build",
        },
        {
            type = "dropdown", name = "Target build profile",
            tooltip = "AUTO follows your current role/context. Manual profiles let the completion tracker judge your character against a stable role target.",
            choices = { "Auto", "Damage", "Healer", "Tank", "Solo" },
            choicesValues = { "AUTO", "DAMAGE", "HEALER", "TANK", "SOLO" },
            getFunc = function() return EPC.TargetBuild and EPC.TargetBuild:GetConfiguredProfile() or (EPC.saved.targetProfile or "AUTO") end,
            setFunc = function(v) if EPC.TargetBuild then EPC.TargetBuild:SetProfile(v) else EPC.saved.targetProfile=v end end,
            default = EPC.defaults.targetProfile,
        },
        {
            type = "editbox", name = "Target set 1",
            tooltip = "Optional exact set name. When filled, BUILD completion tracks how many pieces of this set are currently equipped.",
            getFunc = function() return EPC.saved.targetSet1 or "" end,
            setFunc = function(v) if EPC.TargetBuild then EPC.TargetBuild:SetTargetSet(1,v) else EPC.saved.targetSet1=v end end,
            default = EPC.defaults.targetSet1,
            width = "full",
        },
        {
            type = "editbox", name = "Target set 2",
            tooltip = "Optional second exact set name. Leave target-set fields blank to use generic two-complete-set readiness instead.",
            getFunc = function() return EPC.saved.targetSet2 or "" end,
            setFunc = function(v) if EPC.TargetBuild then EPC.TargetBuild:SetTargetSet(2,v) else EPC.saved.targetSet2=v end end,
            default = EPC.defaults.targetSet2,
            width = "full",
        },
        {
            type = "checkbox", name = "Target-loot alerts",
            tooltip = "When a newly looted backpack item belongs to one of your named target sets, print a TARGET KEEP notice in chat. The addon never locks, destroys, sells, or equips the item for you.",
            getFunc = function() return EPC.saved.targetLootAlerts ~= false end,
            setFunc = function(v) EPC.saved.targetLootAlerts = v == true end,
            default = EPC.defaults.targetLootAlerts,
        },
        {
            type = "header", name = "Utility Command Center",
        },
        {
            type = "dropdown", name = "Default utility view",
            tooltip = "The TOOLS tab combines Inventory, Research, Collections, and Dailies. Overview summarizes the highest-value signals from all four.",
            choices = { "Overview", "Inventory", "Research", "Collections", "Dailies" },
            choicesValues = { "OVERVIEW", "INVENTORY", "RESEARCH", "COLLECTIONS", "DAILIES" },
            getFunc = function() return EPC.UtilitySuite and EPC.UtilitySuite:GetMode() or (EPC.saved.utilityMode or "OVERVIEW") end,
            setFunc = function(v) if EPC.UtilitySuite then EPC.UtilitySuite:SetMode(v) else EPC.saved.utilityMode = v EPC:RequestRefresh("utility-mode") end end,
            default = EPC.defaults.utilityMode,
        },
        {
            type = "checkbox", name = "Smart loot / research / collection alerts",
            tooltip = "For newly looted backpack items, print a notice when the item matches a named Target Set, can teach an unknown trait, or is an uncollected Sticker Book piece. No inventory action is performed automatically.",
            getFunc = function() return EPC.saved.utilityLootAlerts ~= false end,
            setFunc = function(v) EPC.saved.utilityLootAlerts = v == true end,
            default = EPC.defaults.utilityLootAlerts,
        },
        {
            type = "checkbox", name = "Remember account inventory snapshots",
            tooltip = "Stores compact item-name/count snapshots for each character that loads the addon plus the bank when accessible. Use /esosuite find <item name> to locate saved matches across those snapshots.",
            getFunc = function() return EPC.saved.utilityInventoryTracking ~= false end,
            setFunc = function(v) EPC.saved.utilityInventoryTracking = v == true end,
            default = EPC.defaults.utilityInventoryTracking,
        },
        {
            type = "description",
            title = "Inventory search",
            text = "Use /esosuite scan to refresh the current inventory snapshot, then /esosuite find <item name> to search saved character and bank snapshots. Bank results are only as current as the last scan made while bank data was available.",
        },
        {
            type = "dropdown", name = "Session planner mode",
            tooltip = "Continuous never expires. Timed plans organize the selected window, then the suite automatically returns to continuous guidance instead of stopping.",
            choices = { "Continuous", "30 minutes", "60 minutes", "120 minutes", "Custom" },
            choicesValues = { "CONTINUOUS", "30", "60", "120", "CUSTOM" },
            getFunc = function()
                if not EPC.Advisor then return "CONTINUOUS" end
                local mode = EPC.Advisor:GetSessionMode()
                if mode == "CONTINUOUS" or mode == "CUSTOM" then return mode end
                return tostring(EPC.Advisor:GetSessionMinutes())
            end,
            setFunc = function(v)
                if not EPC.Advisor then return end
                if v == "CONTINUOUS" or v == "CUSTOM" then EPC.Advisor:SetSessionMode(v)
                else EPC.Advisor:SetSessionMinutes(tonumber(v) or 60) end
            end,
            default = "CONTINUOUS",
        },
        {
            type = "slider", name = "Custom session length", min = 15, max = 240, step = 5,
            tooltip = "Used by the CUSTOM button in ACTIVITY. Changing it while Custom is active restarts the plan with the new duration.",
            getFunc = function() return EPC.Advisor and EPC.Advisor:GetCustomSessionMinutes() or 90 end,
            setFunc = function(v) if EPC.Advisor then EPC.Advisor:SetCustomSessionMinutes(v) end end,
            default = EPC.defaults.sessionCustomMinutes,
        },
        {
            type = "dropdown", name = "Activity planner goal",
            tooltip = "Choose how the Activity tab ranks visible quests and repeatable activities.",
            choices = { "Balanced", "XP", "Gold" },
            choicesValues = { "BALANCED", "XP", "GOLD" },
            getFunc = function() return EPC.saved.activityGoal or "BALANCED" end,
            setFunc = function(v)
                if EPC.Activities then EPC.Activities:SetGoal(v) else EPC.saved.activityGoal = v end
            end,
            default = EPC.defaults.activityGoal,
        },
        {
            type = "checkbox", name = "Lock window",
            getFunc = function() return EPC.saved.locked end,
            setFunc = function(v) EPC.saved.locked = v EPC.UI:ApplyInteractionState() end,
            default = EPC.defaults.locked,
        },
        {
            type = "checkbox", name = "Show recommendation reasons",
            getFunc = function() return EPC.saved.showReasons end,
            setFunc = function(v) EPC.saved.showReasons = v EPC:RequestRefresh("settings") end,
            default = EPC.defaults.showReasons,
        },
        {
            type = "slider", name = "Window opacity", min = 35, max = 100, step = 1,
            getFunc = function() return math.floor(EPC.saved.alpha * 100) end,
            setFunc = function(v) EPC.saved.alpha = v / 100 EPC.UI.root:SetAlpha(EPC.saved.alpha) end,
            default = math.floor(EPC.defaults.alpha * 100),
        },
        {
            type = "slider", name = "Window scale", min = 70, max = 140, step = 5,
            getFunc = function() return math.floor(EPC.saved.scale * 100) end,
            setFunc = function(v) EPC.saved.scale = v / 100 EPC.UI.root:SetScale(EPC.saved.scale) end,
            default = math.floor(EPC.defaults.scale * 100),
        },
        {
            type = "button", name = "Clear last combat sample", buttonText = "Clear",
            func = function() if EPC.Combat then EPC.Combat:ResetLastFight() end end,
        },
        {
            type = "button", name = "Reset overlay position", buttonText = "Reset",
            func = function() EPC.UI:ResetPosition() end,
        },
    }

    -- v0.27.24: Present the same settings in purpose-based groups.
    -- This only changes organization; every existing getter/setter remains intact.
    local categoryOrder = {
        "GENERAL",
        "CODEX",
        "COMBAT",
        "DIFFICULTY",
        "HUD",
        "FRAMES",
        "MAP",
        "GEAR",
        "ACTIVITIES",
        "UTILITIES",
    }

    local categoryInfo = {
        GENERAL = { name = "General & Getting Started", tooltip = "Core Suite enablement, compatibility information, and basic behavior." },
        CODEX = { name = "Tamriel Codex & Window", tooltip = "Codex access, menu behavior, main Suite window appearance, and interaction controls." },
        COMBAT = { name = "Combat, Role & Builds", tooltip = "Role awareness, combat presentation, endgame guidance, target builds, and combat history controls." },
        DIFFICULTY = { name = "Gameplay & Difficulty", tooltip = "Automatic Challenge Difficulty, Leveling Journey, activity rules, zone overrides, and zone-entry difficulty behavior." },
        HUD = { name = "HUD & Gameplay Overlays", tooltip = "Combat HUD, quest, rank, Champion, ability, clock, stable, repair, and reticle overlays." },
        FRAMES = { name = "Unit Frames & HUD Layout", tooltip = "Player, target, group, raid, live-stat frames, scaling, backgrounds, and move/reset controls." },
        MAP = { name = "Mini Map & Navigation", tooltip = "Mini Map visibility, layers, zoom, sizing, opacity, pins, and position controls." },
        GEAR = { name = "Gear, Maintenance & Loot", tooltip = "Automatic repair/recharge and gear-related maintenance behavior." },
        ACTIVITIES = { name = "Activities & Group Finder", tooltip = "Group Finder filtering, activity planning, and session goals." },
        UTILITIES = { name = "Utilities & Inventory", tooltip = "Utility Command Center, inventory snapshots, research/collection alerts, and search tools." },
    }

    local headerCategory = {
        ["Live Group Finder"] = "ACTIVITIES",
        ["Automatic Equipment Maintenance"] = "GEAR",
        ["Repair / Recharge Estimate Overlay"] = "HUD",
        ["World Combat Visibility"] = "COMBAT",
        ["Persistent HUD & Unit Frames"] = "FRAMES",
        ["Stable Training Timer"] = "HUD",
        ["Clock"] = "HUD",
        ["Quest Tracking"] = "HUD",
        ["Active Quest Overlay"] = "HUD",
        ["Alliance Rank Overlay"] = "HUD",
        ["Champion Level Overlay"] = "HUD",
        ["Ability Overlays"] = "HUD",
        ["Custom ESO Reticle"] = "HUD",
        ["Tamriel Codex"] = "CODEX",
        ["Mini Map"] = "MAP",
        ["Gameplay & Challenge Difficulty"] = "DIFFICULTY",
        ["Target Build"] = "COMBAT",
        ["Utility Command Center"] = "UTILITIES",
    }

    local nameCategory = {
        ["Combat role awareness"] = "COMBAT",
        ["Show combat HUD"] = "HUD",
        ["Combat HUD visibility"] = "HUD",
        ["Move compact combat HUD"] = "HUD",
        ["Lock combat HUD"] = "HUD",
        ["Reset combat HUD position"] = "HUD",
        ["Combat HUD scale"] = "HUD",
        ["Combat HUD opacity"] = "HUD",

        ["Replace ESO default unit frames"] = "FRAMES",
        ["Show player frame"] = "FRAMES",
        ["Player frame visibility"] = "FRAMES",
        ["Show target frame"] = "FRAMES",
        ["Target frame visibility"] = "FRAMES",
        ["Show group frame"] = "FRAMES",
        ["Group frame visibility"] = "FRAMES",
        ["Show raid frame"] = "FRAMES",
        ["Raid frame visibility"] = "FRAMES",
        ["Show live combat stat panel"] = "FRAMES",
        ["Live Combat Stats visibility"] = "FRAMES",
        ["HUD layout mode"] = "FRAMES",
        ["Lock HUD frames"] = "FRAMES",
        ["Reset HUD frame positions"] = "FRAMES",
        ["Player frame size"] = "FRAMES",
        ["Target frame size"] = "FRAMES",
        ["Group / Raid frame scale"] = "FRAMES",
        ["Live stats panel scale"] = "FRAMES",
        ["Use stronger HUD panel backgrounds"] = "FRAMES",
        ["Dark HUD backgrounds"] = "FRAMES",
        ["HUD background opacity"] = "FRAMES",
        ["Floating HUD opacity"] = "FRAMES",
        ["Target aura icons per type"] = "FRAMES",

        ["Endgame suite focus"] = "COMBAT",
        ["Intelligent Next Best Move"] = "COMBAT",
        ["Clear last combat sample"] = "COMBAT",

        ["Session planner mode"] = "ACTIVITIES",
        ["Custom session length"] = "ACTIVITIES",
        ["Activity planner goal"] = "ACTIVITIES",

        ["Auto-expand in interaction mode"] = "CODEX",
        ["Lock window"] = "CODEX",
        ["Show recommendation reasons"] = "CODEX",
        ["Window opacity"] = "CODEX",
        ["Window scale"] = "CODEX",
        ["Reset overlay position"] = "CODEX",
    }

    local grouped = {}
    for _, key in ipairs(categoryOrder) do grouped[key] = {} end

    local currentCategory = "GENERAL"
    for _, control in ipairs(rawOptions) do
        local category = currentCategory
        if control.type == "header" and headerCategory[control.name] then
            category = headerCategory[control.name]
            currentCategory = category
        elseif control.name and nameCategory[control.name] then
            category = nameCategory[control.name]
        elseif control.type == "description" and control.title == "Tamriel Codex hotkey" then
            category = "CODEX"
        elseif control.name == "Open Tamriel Codex" or control.name == "Hide Suite HUD in menus / map" then
            category = "CODEX"
        end
        grouped[category][#grouped[category] + 1] = control
    end

    local organizedOptions = {
        {
            type = "description",
            title = "Organized Settings",
            text = "Settings are grouped by the part of ESO Adventurer Suite they control. Open only the section you want to change; all existing settings and defaults are preserved.",
        },
    }

    for _, key in ipairs(categoryOrder) do
        local controls = grouped[key]
        if controls and #controls > 0 then
            local info = categoryInfo[key]
            organizedOptions[#organizedOptions + 1] = {
                type = "submenu",
                name = info.name,
                tooltip = info.tooltip,
                controls = controls,
            }
        end
    end

    LAM:RegisterOptionControls(panelName, organizedOptions)
end
