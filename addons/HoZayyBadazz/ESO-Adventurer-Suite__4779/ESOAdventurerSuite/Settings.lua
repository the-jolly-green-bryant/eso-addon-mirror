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

    local groupSlotChoices, groupSlotValues = {}, {}
    for i = 1, 12 do
        groupSlotChoices[i] = "Group Member " .. tostring(i)
        groupSlotValues[i] = i
    end

    local function selectedGroupTag()
        local slot = tonumber(EPC.saved.teamVisibilitySelectedGroupSlot) or 1
        slot = zo_clamp(slot, 1, 12)
        return "group" .. tostring(slot)
    end

    local function selectedGroupAvailable()
        local tag = selectedGroupTag()
        if type(DoesUnitExist) ~= "function" or not DoesUnitExist(tag) then return false end
        if type(AreUnitsEqual) == "function" and AreUnitsEqual(tag, "player") then return false end
        return true
    end

    local function selectedGroupOverride(create)
        if not selectedGroupAvailable() or not EPC.TeamVisibility or not EPC.TeamVisibility.GetGroupOverride then return nil end
        return EPC.TeamVisibility:GetGroupOverride(selectedGroupTag(), create == true)
    end

    local function selectedGroupRoleColor()
        if EPC.TeamVisibility and EPC.TeamVisibility.GetBaseRoleColor then
            return EPC.TeamVisibility:GetBaseRoleColor(selectedGroupTag())
        elseif EPC.TeamVisibility and EPC.TeamVisibility.GetRoleColor then
            return EPC.TeamVisibility:GetRoleColor(selectedGroupTag())
        end
        return 0.15, 0.95, 1.00, 1.00
    end

    local challengeNames, challengeValues = { "Adventurer", "Seasoned", "Master", "Vestige" }, { 0, 1, 2, 3 }
    if EPC.OverlandDifficulty and EPC.OverlandDifficulty.GetDifficultyChoices then
        challengeNames, challengeValues = EPC.OverlandDifficulty:GetDifficultyChoices()
    end
    S.panelName = panelName
    S.panelObject = LAM:RegisterAddonPanel(panelName, {
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
            type = "checkbox", name = "Combat Rotation Assistant",
            tooltip = "Shows the safest next-ability recommendation during combat. It never casts abilities, presses keys, or automates gameplay.",
            getFunc = function() return EPC.saved.rotationAssistantEnabled ~= false end,
            setFunc = function(v)
                if EPC.RotationAssistant then EPC.RotationAssistant:SetEnabled(v)
                else EPC.saved.rotationAssistantEnabled = v end
            end,
            default = EPC.defaults.rotationAssistantEnabled,
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
            type = "header", name = "Game Mode Combat Report",
        },
        {
            type = "description",
            title = "Hotkey-only detailed report",
            text = "Assign Open / Close Game Mode Combat Report under Controls > Keybindings > ESO Adventurer Suite. The same key opens and closes the report; it never opens automatically after combat.",
        },
        {
            type = "checkbox", name = "Enable Game Mode Combat Report",
            tooltip = "Enables the hotkey-driven Game Mode Combat Report and keeps up to 30 recent reports. It shares the same fight recorder as Live Combat Stats, keeps player DPS/HPS separate from companions and damaging pets/summons, and records abilities, incoming damage, resources, effects, and effective PEN/PWR/SR/PR/CC/CD.",
            getFunc = function() return EPC.saved.gameModeReportEnabled ~= false end,
            setFunc = function(v)
                EPC.saved.gameModeReportEnabled = v == true
                if EPC.GameModeReport and EPC.GameModeReport.RefreshSettings then EPC.GameModeReport:RefreshSettings() end
            end,
            default = EPC.defaults.gameModeReportEnabled,
        },
        {
            type = "slider", name = "Report opacity", min = 45, max = 100, step = 1,
            getFunc = function() return math.floor((EPC.saved.gameModeReportAlpha or 0.96) * 100) end,
            setFunc = function(v)
                EPC.saved.gameModeReportAlpha = v / 100
                if EPC.GameModeReport and EPC.GameModeReport.RefreshSettings then EPC.GameModeReport:RefreshSettings() end
            end,
            default = math.floor((EPC.defaults.gameModeReportAlpha or 0.96) * 100),
        },
        {
            type = "button", name = "Reset report position and size",
            tooltip = "Returns the report to its centered 1120 x 760 layout.",
            func = function() if EPC.GameModeReport and EPC.GameModeReport.ResetPosition then EPC.GameModeReport:ResetPosition() end end,
            width = "half",
        },
        {
            type = "button", name = "Clear saved combat reports",
            tooltip = "Clears the report history. This does not reset personal bests or the compact combat HUD.",
            func = function() if EPC.GameModeReport and EPC.GameModeReport.ClearHistory then EPC.GameModeReport:ClearHistory() end end,
            width = "half",
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
            tooltip = "Inventory Only keeps the full Repair / Recharge Estimate card exactly as before. Always uses the compact Repair: <gold> gameplay HUD; it is attached to ESO's HUD-fade system, so it disappears and returns with the other HUD overlays without a separate Suite idle timer.",
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
            type = "button", name = "Reset repair overlay positions", buttonText = "Reset Repair Overlays",
            func = function() if EPC.RepairCostOverlay then EPC.RepairCostOverlay:ResetPosition() EPC.RepairCostOverlay:Refresh() end end,
        },
        {
            type = "header", name = "Suite FPS / Latency Overlay",
        },
        {
            type = "description",
            title = "Suite replacement for ESO's performance meter",
            text = "Shows FPS and network latency in a small movable Suite HUD. It is attached directly to ESO's HUD-fade fragment, so it fades with the normal gameplay HUD and does not use a separate Suite idle timer.",
        },
        {
            type = "checkbox", name = "Show Suite FPS / Latency",
            getFunc = function() return EPC.saved.showPerformanceOverlay ~= false end,
            setFunc = function(v) EPC.saved.showPerformanceOverlay = v == true if EPC.PerformanceOverlay then EPC.PerformanceOverlay:Refresh(true) end end,
            default = EPC.defaults.showPerformanceOverlay,
        },
        {
            type = "checkbox", name = "Hide ESO built-in FPS / latency panel",
            tooltip = "When the Suite meter is enabled, suppress ESO's stock performance panel so the two displays do not overlap.",
            getFunc = function() return EPC.saved.suppressNativePerformanceMeters ~= false end,
            setFunc = function(v) EPC.saved.suppressNativePerformanceMeters = v == true if EPC.PerformanceOverlay then EPC.PerformanceOverlay:Refresh(true) end end,
            default = EPC.defaults.suppressNativePerformanceMeters,
        },
        {
            type = "slider", name = "FPS / latency scale", min = 65, max = 180, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.performanceOverlayScale) or 1.0) * 100) end,
            setFunc = function(v) EPC.saved.performanceOverlayScale = v / 100 if EPC.PerformanceOverlay then EPC.PerformanceOverlay:Refresh(true) end end,
            default = math.floor((EPC.defaults.performanceOverlayScale or 1.0) * 100),
        },
        {
            type = "button", name = "Reset FPS / latency position", buttonText = "Reset Performance Overlay",
            func = function() if EPC.PerformanceOverlay then EPC.PerformanceOverlay:ResetPosition() EPC.PerformanceOverlay:Refresh(true) end end,
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
            type = "header", name = "Dungeon / Trial Chest Finder",
        },
        {
            type = "description",
            title = "Chest-centered 3D glow",
            text = "Works only inside supported instanced PvE content such as Group Dungeons, Trials, and Arenas. ESO does not expose the chest model's exact world coordinates, so the Suite estimates the center when your reticle identifies a Chest or Heavy Sack at interaction range. Confirmed objects use one compact glow centered on that learned position until looted. Possible-spawn glows are optional and are automatically suppressed whenever a confirmed chest/Heavy Sack is being shown, preventing multiple glows from surrounding the real chest.",
        },
        {
            type = "checkbox", name = "Enable Dungeon / Trial Chest Finder",
            tooltip = "Enables learned 3D chest/Heavy Sack spawn glows only in supported instanced PvE content.",
            getFunc = function() return EPC.saved.dungeonChestFinderEnabled ~= false end,
            setFunc = function(v) EPC.saved.dungeonChestFinderEnabled = v == true if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            default = EPC.defaults.dungeonChestFinderEnabled,
            width = "full",
        },
        {
            type = "checkbox", name = "Show possible chest spawn locations",
            tooltip = "Shows remembered possible spawn points only when no confirmed chest/Heavy Sack is currently being rendered. Leave this off if you only want the actual detected chest location to glow.",
            getFunc = function() return EPC.saved.dungeonChestShowPossible ~= false end,
            setFunc = function(v) EPC.saved.dungeonChestShowPossible = v == true if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestShowPossible,
            width = "half",
        },
        {
            type = "checkbox", name = "Show Heavy Sack glows",
            getFunc = function() return EPC.saved.dungeonChestShowHeavySacks ~= false end,
            setFunc = function(v) EPC.saved.dungeonChestShowHeavySacks = v == true if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestShowHeavySacks,
            width = "half",
        },
        {
            type = "checkbox", name = "Learn new chest locations",
            tooltip = "Saves a chest/Heavy Sack spawn point when ESO identifies it under your reticle at interaction range. Existing learned locations remain visible if this is turned off.",
            getFunc = function() return EPC.saved.dungeonChestLearnLocations ~= false end,
            setFunc = function(v) EPC.saved.dungeonChestLearnLocations = v == true end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestLearnLocations,
            width = "half",
        },
        {
            type = "checkbox", name = "Chest glows through obstacles",
            tooltip = "When enabled, 3D chest glows ignore the depth buffer so they can remain visible through dungeon geometry where ESO permits it.",
            getFunc = function() return EPC.saved.dungeonChestThroughWalls ~= false end,
            setFunc = function(v) EPC.saved.dungeonChestThroughWalls = v == true if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestThroughWalls,
            width = "half",
        },
        {
            type = "slider", name = "Chest glow distance", min = 25, max = 250, step = 5,
            tooltip = "Maximum distance in meters for learned dungeon/trial chest glows.",
            getFunc = function() return tonumber(EPC.saved.dungeonChestDistance) or 120 end,
            setFunc = function(v) EPC.saved.dungeonChestDistance = tonumber(v) or 120 if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestDistance,
            width = "half",
        },
        {
            type = "slider", name = "Chest glow size", min = 50, max = 200, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.dungeonChestMarkerScale) or 1.0) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.dungeonChestMarkerScale = (tonumber(v) or 100) / 100 if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = math.floor((EPC.defaults.dungeonChestMarkerScale or 1.0) * 100),
            width = "half",
        },
        {
            type = "slider", name = "Chest glow intensity", min = 5, max = 100, step = 5,
            tooltip = "Controls the brightness of chest/Heavy Sack glows. Confirmed spawns stay brighter and pulse until looted.",
            getFunc = function() return math.floor((tonumber(EPC.saved.dungeonChestGlowOpacity) or 0.60) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.dungeonChestGlowOpacity = (tonumber(v) or 60) / 100 if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = math.floor((EPC.defaults.dungeonChestGlowOpacity or 0.60) * 100),
            width = "half",
        },
        {
            type = "colorpicker", name = "Chest glow color",
            getFunc = function() local c = EPC.saved.dungeonChestColor or EPC.defaults.dungeonChestColor return c.r or 1.0, c.g or 0.74, c.b or 0.14, 1 end,
            setFunc = function(r, g, b, a) EPC.saved.dungeonChestColor = { r = r, g = g, b = b } if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false end,
            default = EPC.defaults.dungeonChestColor,
            width = "half",
        },
        {
            type = "colorpicker", name = "Heavy Sack glow color",
            getFunc = function() local c = EPC.saved.dungeonChestSackColor or EPC.defaults.dungeonChestSackColor return c.r or 0.62, c.g or 0.92, c.b or 0.52, 1 end,
            setFunc = function(r, g, b, a) EPC.saved.dungeonChestSackColor = { r = r, g = g, b = b } if EPC.DungeonChestFinder then EPC.DungeonChestFinder:RefreshSettings() end end,
            disabled = function() return EPC.saved.dungeonChestFinderEnabled == false or EPC.saved.dungeonChestShowHeavySacks == false end,
            default = EPC.defaults.dungeonChestSackColor,
            width = "half",
        },
        {
            type = "button", name = "Clear learned dungeon chest locations", buttonText = "Clear Learned Chests",
            tooltip = "Deletes every dungeon/trial Chest and Heavy Sack spawn learned by this feature. This does not affect Lore Books, minimap locations, or other Suite data.",
            func = function() if EPC.DungeonChestFinder then EPC.DungeonChestFinder:ClearLearnedLocations() EPC:Print("Dungeon / Trial Chest Finder learned locations cleared.") end end,
            disabled = function() return not EPC.DungeonChestFinder end,
            width = "full",
        },
        {
            type = "header", name = "Antiquity Assistant",
        },
        {
            type = "description",
            title = "Dig-site navigation + Augur + Bonus Loot helper",
            text = "World-map and Suite-minimap pins show the active Antiquity search area. In the world, ESO's normal Antiquarian's Eye blue mist remains unchanged; once ESO exposes the real Excavate / Dig Site mound, the Suite learns a true 3D shovel position above that mound, saves the spawn, and reuses it the next time the same dig-site spawn becomes active. During Excavation, the Suite caches the Augur tile, recommends information-rich scan tiles, and only calls a main-loot tile guaranteed after ESO reports Green. After the main Antiquity is unearthed, Bonus Loot Search Mode tracks bonus finds separately and gives a best-effort board-coverage route using only information ESO exposes to addons.",
        },
        {
            type = "checkbox", name = "Enable Antiquity Assistant",
            tooltip = "Master switch for Antiquity shovel pins, excavation direction help, and skill-line recommendations.",
            getFunc = function() return EPC.saved.antiquityAssistantEnabled ~= false end,
            setFunc = function(v) EPC.saved.antiquityAssistantEnabled = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            default = EPC.defaults.antiquityAssistantEnabled,
            width = "full",
        },
        {
            type = "checkbox", name = "Shovel icons on world map",
            tooltip = "Marks the center of every active Antiquity search area with the Heavy Shovel skill icon.",
            getFunc = function() return EPC.saved.antiquityShowWorldMap ~= false end,
            setFunc = function(v) EPC.saved.antiquityShowWorldMap = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false end,
            default = EPC.defaults.antiquityShowWorldMap,
            width = "half",
        },
        {
            type = "checkbox", name = "Shovel icons on Suite minimap",
            tooltip = "Shows active Antiquity dig-site centers on the Suite minimap, including edge guidance when the site is off-screen.",
            getFunc = function() return EPC.saved.antiquityShowMiniMap ~= false end,
            setFunc = function(v) EPC.saved.antiquityShowMiniMap = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false end,
            default = EPC.defaults.antiquityShowMiniMap,
            width = "half",
        },
        {
            type = "checkbox", name = "Exact dig-spot shovel in the world",
            tooltip = "Shows a true 3D Heavy Shovel marker above the learned excavation mound. The Suite learns the mound when ESO exposes the actual Excavate / Dig Site interaction target and can reuse that saved spawn later. The old approximate search-area-center 3D marker stays disabled.",
            getFunc = function() return EPC.saved.antiquityShow3D ~= false end,
            setFunc = function(v) EPC.saved.antiquityShow3D = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false end,
            default = EPC.defaults.antiquityShow3D,
            width = "half",
        },
        {
            type = "checkbox", name = "Legacy 3D occlusion setting",
            tooltip = "Kept for saved-variable compatibility. Exact mound markers use ESO's interaction target and do not use approximate through-terrain search-area markers.",
            getFunc = function() return EPC.saved.antiquity3DThroughWalls ~= false end,
            setFunc = function(v) EPC.saved.antiquity3DThroughWalls = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityShow3D == false end,
            default = EPC.defaults.antiquity3DThroughWalls,
            width = "half",
        },
        {
            type = "slider", name = "Known spawn 3D range", min = 200, max = 3000, step = 100,
            tooltip = "Maximum distance in meters for known dig-spawn candidate shovels. The confirmed exact mound still follows ESO's actual interaction target.",
            getFunc = function() return math.floor(tonumber(EPC.saved.antiquity3DRange) or 1200) end,
            setFunc = function(v) EPC.saved.antiquity3DRange = math.floor(tonumber(v) or 1200) if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityShow3D == false end,
            default = EPC.defaults.antiquity3DRange,
            width = "half",
        },
        {
            type = "slider", name = "3D shovel size", min = 60, max = 200, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.antiquity3DScale) or 1.0) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.antiquity3DScale = (tonumber(v) or 100) / 100 if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityShow3D == false end,
            default = math.floor((EPC.defaults.antiquity3DScale or 1.0) * 100),
            width = "half",
        },
        {
            type = "checkbox", name = "Learn & reuse exact dig-spot spawns",
            tooltip = "When ESO exposes the real Excavate / Dig Site mound under your reticle, save that learned 3D spawn in SavedVariables. The next time the same dig-site spawn becomes active, the Suite restores the shovel automatically. Turning this off stops new learning; already learned spots remain available.",
            getFunc = function() return EPC.saved.antiquityLearnExactDigSpots ~= false end,
            setFunc = function(v) EPC.saved.antiquityLearnExactDigSpots = v == true end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityShow3D == false end,
            default = EPC.defaults.antiquityLearnExactDigSpots,
            width = "half",
        },
        {
            type = "checkbox", name = "Known dig-spawn locator assist",
            tooltip = "Uses the integrated known Antiquity dig-spawn reference library to filter possible mound spawns to ESO's active dig-site search area. Confirmed/learned spawns are gold; unconfirmed known possibilities are smaller cyan shovels until ESO exposes the real mound.",
            getFunc = function() return EPC.saved.antiquityKnownSpawnAssist ~= false end,
            setFunc = function(v) EPC.saved.antiquityKnownSpawnAssist = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityShow3D == false end,
            default = EPC.defaults.antiquityKnownSpawnAssist,
            width = "half",
        },
        {
            type = "button", name = "Clear learned exact dig spots", buttonText = "Clear Learned Dig Spots",
            tooltip = "Deletes only the saved exact Antiquity mound spawn locations learned by the Suite. Search-area map/minimap pins and other Suite data are not changed.",
            func = function()
                if EPC.AntiquityAssistant and EPC.AntiquityAssistant.ClearLearnedDigSpots then EPC.AntiquityAssistant:ClearLearnedDigSpots() end
            end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false end,
            width = "half",
        },
        {
            type = "header", name = "Antiquity Lead Finder",
        },
        {
            type = "description",
            title = "Find the lead before you scry it",
            text = "Combines ESO's live Antiquity state with integrated Display Leads source/location reference data. Use it to see leads you can still obtain, leads already in your journal, missing codex entries, recovery counts, expiration timers, find zones, and the best-known source description. Scrying and excavation remain handled by ESO and the Suite Antiquity Assistant.",
        },
        {
            type = "checkbox", name = "Enable Antiquity Lead Finder",
            tooltip = "Enables the Suite lead-source browser. The finder does not change ESO lead drops; it only organizes live lead state and source/location information.",
            getFunc = function() return EPC.saved.antiquityLeadFinderEnabled ~= false end,
            setFunc = function(v) EPC.saved.antiquityLeadFinderEnabled = v == true if EPC.AntiquityLeadFinder then EPC.AntiquityLeadFinder:RefreshSettings() end end,
            default = EPC.defaults.antiquityLeadFinderEnabled,
            width = "half",
        },
        {
            type = "button", name = "Open Antiquity Lead Finder", buttonText = "Open Lead Finder",
            tooltip = "Opens the lead browser. You can also assign its own key under Controls > Keybindings > ESO Adventurer Suite.",
            func = function() if EPC.AntiquityLeadFinder then EPC.AntiquityLeadFinder:Show() end end,
            disabled = function() return EPC.saved.antiquityLeadFinderEnabled == false or not EPC.AntiquityLeadFinder end,
            width = "half",
        },
        {
            type = "button", name = "Reset Lead Finder window", buttonText = "Reset Lead Finder",
            tooltip = "Restores the Lead Finder to its default size and centered screen position.",
            func = function() if EPC.AntiquityLeadFinder then EPC.AntiquityLeadFinder:ResetPosition() end end,
            disabled = function() return not EPC.AntiquityLeadFinder end,
            width = "half",
        },
        {
            type = "description",
            title = "Lead Finder filters",
            text = "Inside the finder use CAN FIND, HAVE LEAD, MISSING CODEX, NEVER DUG, or ALL. CURRENT ZONE narrows source locations to the zone you are presently in. Click any lead row for the detailed source description and its separate find-zone / scry-zone information.",
        },
        {
            type = "checkbox", name = "Excavation Augur direction overlay",
            tooltip = "After each successful Augur use, tap Green, Yellow, Orange, or Red. The Suite caches the clicked board cell using multiple ESO UI fallbacks and recommends the strongest next scan. It never labels a non-green prediction as a guaranteed dig. Both Antiquity overlays can be moved in HUD Layout Mode.",
            getFunc = function() return EPC.saved.antiquityExcavationGuide ~= false end,
            setFunc = function(v) EPC.saved.antiquityExcavationGuide = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false end,
            default = EPC.defaults.antiquityExcavationGuide,
            width = "full",
        },
        {
            type = "checkbox", name = "Bonus Loot Search predictions",
            tooltip = "After ESO reports the main Antiquity unearthed, switches the Augur Guide into a bonus-loot coverage route. It tracks bonus loot separately, watches stability/time/dig power, and recommends the next area to work. Bonus coordinates are not exposed by ESO, so these are search-efficiency predictions rather than guaranteed locations.",
            getFunc = function() return EPC.saved.antiquityBonusLootGuide ~= false end,
            setFunc = function(v) EPC.saved.antiquityBonusLootGuide = v == true if EPC.AntiquityAssistant then EPC.AntiquityAssistant:RefreshSettings() end end,
            disabled = function() return EPC.saved.antiquityAssistantEnabled == false or EPC.saved.antiquityExcavationGuide == false end,
            default = EPC.defaults.antiquityBonusLootGuide,
            width = "full",
        },
        {
            type = "description",
            title = "Movable Excavation overlays",
            text = "Use HUD Layout Mode > Move Frames to drag both the Augur Guide and the 10x10 Augur Tile Selector away from the excavation board. Their positions are saved independently.",
        },
        {
            type = "button", name = "Reset Antiquity overlay positions", buttonText = "Reset Antiquity Overlays",
            tooltip = "Restores the Augur Guide to the top-center and the Augur Tile Selector to the center of the screen.",
            func = function() if EPC.AntiquityAssistant and EPC.AntiquityAssistant.ResetPositions then EPC.AntiquityAssistant:ResetPositions() end end,
        },
        {
            type = "header", name = "Suite Resource Pins",
        },
        {
            type = "description",
            title = "Learned + Suite Community Resource Data",
            text = "Suite Resource Pins combines your personally learned resource locations with 124,625 bundled community resource records. The full current-zone database stays available, but only the nearest capped set receives 3D controls at one time. Personal and community locations share the same temporary depletion system: harvested or already-empty nodes hide for the configured cooldown and then return automatically. As you move, the pool automatically swaps to the next nearby community pins. This avoids the severe FPS loss caused by trying to create thousands of 3D markers simultaneously.",
        },
        {
            type = "checkbox", name = "Enable Suite Resource Pins",
            tooltip = "Turns the Suite resource-node system on or off.",
            getFunc = function() return EPC.saved.resourcePinsEnabled ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsEnabled = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            default = EPC.defaults.resourcePinsEnabled,
            width = "half",
        },
        {
            type = "checkbox", name = "Use Suite Community Resource Data",
            tooltip = "Shows pre-collected resource locations bundled with the Suite. Only the current zone is decoded into the fast 3D spatial cache. Your personally learned pins remain separate and take priority over nearby community records.",
            getFunc = function() return EPC.saved.resourcePinsCommunityEnabled ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsCommunityEnabled = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsCommunityEnabled,
            width = "half",
        },
        {
            type = "checkbox", name = "Learn resources when gathered",
            tooltip = "Optionally records a personal copy of resource locations after you gather them. Temporary depleted-node hiding works even when personal learning is turned off.",
            getFunc = function() return EPC.saved.resourcePinsLearn ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsLearn = v == true end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsLearn,
            width = "half",
        },
        {
            type = "checkbox", name = "Hide temporarily depleted resource pins",
            tooltip = "Hides a resource pin only after ESO confirms that you personally collected loot from that resource interaction. Simply walking up to a community pin never hides it. The pin returns after the cooldown.",
            getFunc = function() return EPC.saved.resourcePinsHideDepleted ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsHideDepleted = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsHideDepleted,
            width = "half",
        },
        {
            type = "slider", name = "Depleted node cooldown (minutes)", min = 1, max = 30, step = 1,
            tooltip = "How long a resource location stays hidden after you personally collect it before it becomes eligible to appear again.",
            getFunc = function() return math.floor(tonumber(EPC.saved.resourcePinsDepletedCooldownMinutes) or 5) end,
            setFunc = function(v) EPC.saved.resourcePinsDepletedCooldownMinutes = math.floor(tonumber(v) or 5) if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsHideDepleted == false end,
            default = EPC.defaults.resourcePinsDepletedCooldownMinutes or 5,
            width = "half",
        },
        {
            type = "button", name = "Temporary depleted resource states", buttonText = "Reset Depleted Pins",
            tooltip = "Immediately makes every resource pin hidden by your own recent collections eligible to show again. Community data itself is never deleted.",
            func = function() if EPC.ResourcePins then EPC.ResourcePins:ClearDepletedLocations() EPC:Print("Temporary depleted resource pins reset.") end end,
            disabled = function() return not EPC.ResourcePins or EPC.saved.resourcePinsEnabled == false end,
            width = "half",
        },
        {
            type = "checkbox", name = "Show resource pins in 3D world",
            getFunc = function() return EPC.saved.resourcePinsShow3D ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShow3D = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsShow3D,
            width = "half",
        },
        {
            type = "checkbox", name = "Resource pins through obstacles",
            tooltip = "Lets Suite learned and community 3D resource markers remain visible through terrain/objects where ESO permits addon 3D controls.",
            getFunc = function() return EPC.saved.resourcePinsThroughWalls ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsThroughWalls = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false end,
            default = EPC.defaults.resourcePinsThroughWalls,
            width = "half",
        },
        {
            type = "slider", name = "Resource pin distance", min = 15, max = 500, step = 5,
            tooltip = "Maximum distance used to select nearby learned and community nodes for the dynamic 3D pool.",
            getFunc = function() return tonumber(EPC.saved.resourcePinsDistance) or 200 end,
            setFunc = function(v) EPC.saved.resourcePinsDistance = tonumber(v) or 200 if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false end,
            default = EPC.defaults.resourcePinsDistance,
            width = "half",
        },
        {
            type = "slider", name = "Maximum visible 3D resource pins", min = 24, max = 120, step = 8,
            tooltip = "Hard performance cap for active 3D resource controls. The full community database remains available; this only limits how many nearest pins are drawn at the same time.",
            getFunc = function() return math.floor(tonumber(EPC.saved.resourcePinsMaxVisible) or 72) end,
            setFunc = function(v) EPC.saved.resourcePinsMaxVisible = math.floor(tonumber(v) or 72) if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false end,
            default = EPC.defaults.resourcePinsMaxVisible or 72,
            width = "half",
        },
        {
            type = "slider", name = "Resource pin size", min = 45, max = 250, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.resourcePinsScale) or 1.0) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.resourcePinsScale = (tonumber(v) or 100) / 100 if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false end,
            default = math.floor((EPC.defaults.resourcePinsScale or 1.0) * 100),
            width = "half",
        },
        {
            type = "slider", name = "Resource pin brightness", min = 15, max = 100, step = 5,
            getFunc = function() return math.floor((tonumber(EPC.saved.resourcePinsOpacity) or 0.72) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.resourcePinsOpacity = (tonumber(v) or 72) / 100 if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false end,
            default = math.floor((EPC.defaults.resourcePinsOpacity or 0.72) * 100),
            width = "half",
        },
        {
            type = "checkbox", name = "Sharper 3D resource icons",
            tooltip = "Uses normalized per-resource sizing and reduced distance growth so all resource symbols stay crisp and visually consistent in the world.",
            getFunc = function() return EPC.saved.resourcePinsSharpIcons ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsSharpIcons = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false or EPC.saved.resourcePinsIconMode == "SUITE_GLOW" end,
            default = EPC.defaults.resourcePinsSharpIcons,
            width = "half",
        },
        {
            type = "checkbox", name = "Glow icons by value / rarity",
            tooltip = "Adds a colored glow behind resource icons. Rarity changes glow color and intensity only; it no longer makes higher-tier icons physically larger.",
            getFunc = function() return EPC.saved.resourcePinsValueGlow ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsValueGlow = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false or EPC.saved.resourcePinsIconMode == "SUITE_GLOW" end,
            default = EPC.defaults.resourcePinsValueGlow,
            width = "half",
        },
        {
            type = "slider", name = "Resource icon glow strength", min = 20, max = 100, step = 5,
            tooltip = "Controls how bright the rune-style value/rarity glow appears behind resource icons.",
            getFunc = function() return math.floor(tonumber(EPC.saved.resourcePinsGlowStrength) or 78) end,
            setFunc = function(v) EPC.saved.resourcePinsGlowStrength = math.floor(tonumber(v) or 78) if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false or EPC.saved.resourcePinsIconMode == "SUITE_GLOW" end,
            default = EPC.defaults.resourcePinsGlowStrength or 78,
            width = "half",
        },
        {
            type = "slider", name = "Resource icon size", min = 70, max = 180, step = 5,
            tooltip = "Changes the physical size of non-Glow resource icons in the 3D world without changing the general resource-pin distance settings.",
            getFunc = function() return math.floor(tonumber(EPC.saved.resourcePinsIconSize) or 100) end,
            setFunc = function(v) EPC.saved.resourcePinsIconSize = math.floor(tonumber(v) or 100) if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false or EPC.saved.resourcePinsIconMode == "SUITE_GLOW" end,
            default = EPC.defaults.resourcePinsIconSize or 100,
            width = "half",
        },
        {
            type = "slider", name = "Resource icon color strength", min = 0, max = 100, step = 5,
            tooltip = "Adds category color to the resource symbol itself. 0 keeps icons white, 100 fully tints them by resource type.",
            getFunc = function() return math.floor(tonumber(EPC.saved.resourcePinsIconTintStrength) or 85) end,
            setFunc = function(v) EPC.saved.resourcePinsIconTintStrength = math.floor(tonumber(v) or 85) if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsShow3D == false or EPC.saved.resourcePinsIconMode == "SUITE_GLOW" end,
            default = EPC.defaults.resourcePinsIconTintStrength or 85,
            width = "half",
        },
        {
            type = "header", name = "Resource Pin Icon Replacer",
        },
        {
            type = "description",
            title = "Choose how Suite resource markers look",
            text = "Suite Glow uses the proven glowing marker. Suite Resource Icons uses distinct ESO-native resource symbols on the same proven 3D control: mining/refining, lumber, clothier, alchemy, enchanting, water, fishing, loot and justice markers. All non-Glow icon styles use a tighter rune-style halo glow, can be resized independently, and can tint the icon itself by resource type. The glow can still shift by value/rarity: common materials use a lighter glow, better materials use blue, valuable containers use purple, and top-value treasure pins use gold. Custom Per Type lets you replace each category independently.",
        },
        {
            type = "dropdown", name = "Resource pin icon style",
            choices = { "Suite Glow", "Suite Resource Icons", "Custom Per Type" },
            choicesValues = { "SUITE_GLOW", "CATEGORY", "CUSTOM" },
            getFunc = function() return EPC.saved.resourcePinsIconMode or "SUITE_GLOW" end,
            setFunc = function(v) EPC.saved.resourcePinsIconMode = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsIconMode,
            width = "full",
        },
        {
            type = "dropdown", name = "Ore / seams icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconOre or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconOre = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconOre,
            width = "half",
        },
        {
            type = "dropdown", name = "Wood icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconWood or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconWood = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconWood,
            width = "half",
        },
        {
            type = "dropdown", name = "Cloth icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconCloth or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconCloth = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconCloth,
            width = "half",
        },
        {
            type = "dropdown", name = "Alchemy icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconAlchemy or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconAlchemy = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconAlchemy,
            width = "half",
        },
        {
            type = "dropdown", name = "Runestone icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconRunes or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconRunes = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconRunes,
            width = "half",
        },
        {
            type = "dropdown", name = "Water / solvent icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconWater or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconWater = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconWater,
            width = "half",
        },
        {
            type = "dropdown", name = "Fishing icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconFishing or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconFishing = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconFishing,
            width = "half",
        },
        {
            type = "dropdown", name = "Special resource icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconSpecial or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconSpecial = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconSpecial,
            width = "half",
        },
        {
            type = "dropdown", name = "Other / unknown icon",
            choices = { "Automatic", "Suite Glow", "Mining", "Wood", "Clothing", "Alchemy", "Enchanting", "Mushroom", "Flower", "Water Plant", "Solvent", "Fishing", "Chest", "Heavy Sack", "Giant Clam", "Trove", "Justice", "Stash" }, choicesValues = { "AUTO", "SUITE_GLOW", "MINING", "WOOD", "CLOTHING", "ALCHEMY", "ENCHANTING", "MUSHROOM", "FLOWER", "WATERPLANT", "SOLVENT", "FISH", "CHEST", "HEAVYSACK", "CLAM", "TROVE", "JUSTICE", "STASH" },
            getFunc = function() return EPC.saved.resourcePinsIconOther or "AUTO" end,
            setFunc = function(v) EPC.saved.resourcePinsIconOther = v if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsIconMode ~= "CUSTOM" end,
            default = EPC.defaults.resourcePinsIconOther,
            width = "half",
        },
        {
            type = "header", name = "Farm Focus",
        },
        {
            type = "description",
            text = "Turn Farm Focus on when you only want to see specific resource types. Your normal Resource Pin Filters below are preserved and automatically return when Farm Focus is turned off.",
        },
        {
            type = "checkbox", name = "Enable Farm Focus",
            tooltip = "When enabled, only the checked Farm Targets below are rendered as resource pins.",
            getFunc = function() return EPC.saved.resourcePinsFarmFocusEnabled == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmFocusEnabled = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end,
            default = EPC.defaults.resourcePinsFarmFocusEnabled or false,
            width = "full",
        },
        {
            type = "checkbox", name = "Farm ore / seams",
            getFunc = function() return EPC.saved.resourcePinsFarmOre == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmOre = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm wood",
            getFunc = function() return EPC.saved.resourcePinsFarmWood == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmWood = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm cloth",
            getFunc = function() return EPC.saved.resourcePinsFarmCloth == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmCloth = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm alchemy plants",
            getFunc = function() return EPC.saved.resourcePinsFarmAlchemy == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmAlchemy = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm runestones",
            getFunc = function() return EPC.saved.resourcePinsFarmRunes == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmRunes = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm water / solvents",
            getFunc = function() return EPC.saved.resourcePinsFarmWater == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmWater = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm fishing holes",
            getFunc = function() return EPC.saved.resourcePinsFarmFishing == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmFishing = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm special resources",
            tooltip = "Chests, Heavy Sacks, Giant Clams, Troves, Justice containers and hidden stashes.",
            getFunc = function() return EPC.saved.resourcePinsFarmSpecial == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmSpecial = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "checkbox", name = "Farm other / unknown",
            getFunc = function() return EPC.saved.resourcePinsFarmOther == true end,
            setFunc = function(v) EPC.saved.resourcePinsFarmOther = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            default = false, width = "half",
        },
        {
            type = "button", name = "Farm targets", buttonText = "Select All",
            func = function() if EPC.ResourcePins then EPC.ResourcePins:SetAllFarmTargets(true) end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            width = "half",
        },
        {
            type = "button", name = "Farm targets", buttonText = "Clear All",
            func = function() if EPC.ResourcePins then EPC.ResourcePins:SetAllFarmTargets(false) end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false or EPC.saved.resourcePinsFarmFocusEnabled ~= true end,
            width = "half",
        },
        {
            type = "header", name = "Normal Resource Pin Filters",
        },
        {
            type = "checkbox", name = "Show ore / seams",
            getFunc = function() return EPC.saved.resourcePinsShowOre ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowOre = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show wood",
            getFunc = function() return EPC.saved.resourcePinsShowWood ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowWood = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show cloth",
            getFunc = function() return EPC.saved.resourcePinsShowCloth ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowCloth = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show alchemy plants",
            getFunc = function() return EPC.saved.resourcePinsShowAlchemy ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowAlchemy = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show runestones",
            getFunc = function() return EPC.saved.resourcePinsShowRunes ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowRunes = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show water / solvents",
            getFunc = function() return EPC.saved.resourcePinsShowWater ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowWater = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show fishing holes",
            getFunc = function() return EPC.saved.resourcePinsShowFishing ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowFishing = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show special resources",
            tooltip = "Shows recognized special resource locations such as Chests, Heavy Sacks, Giant Clams, Troves and hidden stashes from learned and community data.",
            getFunc = function() return EPC.saved.resourcePinsShowSpecial ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowSpecial = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "checkbox", name = "Show other / unknown",
            tooltip = "Shows resource nodes whose type could not be classified.",
            getFunc = function() return EPC.saved.resourcePinsShowOther ~= false end,
            setFunc = function(v) EPC.saved.resourcePinsShowOther = v == true if EPC.ResourcePins then EPC.ResourcePins:RefreshSettings() end end,
            disabled = function() return EPC.saved.resourcePinsEnabled == false end, default = true, width = "half",
        },
        {
            type = "button", name = "Test Suite Resource Pin", buttonText = "Show Test Pin",
            tooltip = "Queues an ore test marker about four meters in front of you. Close Settings to view it; the 10-second preview waits while menus are open. It is not saved.",
            func = function()
                if EPC.ResourcePins and EPC.ResourcePins:StartDebugTestGlow() then EPC:Print("Suite Resource Pins test marker queued about 4m ahead. Close Settings to view it for 10 seconds.")
                else EPC:Print("Suite Resource Pins could not get your current world position.") end
            end,
            disabled = function() return not EPC.ResourcePins or EPC.saved.resourcePinsEnabled == false end, width = "half",
        },
        {
            type = "button", name = "Resource Pin status", buttonText = "Print Status",
            func = function() if EPC.ResourcePins then EPC:Print(EPC.ResourcePins:GetStatusText()) end end,
            disabled = function() return not EPC.ResourcePins end, width = "half",
        },
        {
            type = "button", name = "Clear learned resource locations", buttonText = "Clear Resource Pins",
            tooltip = "Deletes every resource location learned by ESO Adventurer Suite.",
            func = function() if EPC.ResourcePins then EPC.ResourcePins:ClearLearnedLocations() EPC:Print("Suite Resource Pins learned locations cleared.") end end,
            disabled = function() return not EPC.ResourcePins end, width = "full",
        },
        {
            type = "header", name = "Team Visibility",
        },
        {
            type = "description",
            text = "Companions and grouped teammates use the soft 3D visibility glow. Companion settings are independent and default to purple. Group defaults can be overridden per player; overrides are saved by that player's account/name so they follow the player instead of a temporary group slot. Glow intensity can now reach full brightness. Red is reserved for dead grouped players and downed companions, with a separate red brightness control. Their glow slowly pulses until they revive or recover. Type /easteam for renderer status.",
        },
        {
            type = "checkbox", name = "Enable Team Visibility",
            tooltip = "Enables the Suite's enhanced native group markers and teammate visibility system.",
            getFunc = function() return EPC.saved.teamVisibilityEnabled ~= false end,
            setFunc = function(v) EPC.saved.teamVisibilityEnabled = v == true if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            default = EPC.defaults.teamVisibilityEnabled,
            width = "half",
        },
        {
            type = "checkbox", name = "Show teammate glow",
            tooltip = "Shows the visibility glow on companions and group members where ESO allows addon 3D controls.",
            getFunc = function() return EPC.saved.teamVisibilityLightsEnabled ~= false end,
            setFunc = function(v) EPC.saved.teamVisibilityLightsEnabled = v == true if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false end,
            default = EPC.defaults.teamVisibilityLightsEnabled,
            width = "half",
        },
        {
            type = "slider", name = "Downed/dead red glow brightness", min = 20, max = 100, step = 5,
            tooltip = "Controls the brightness of the reserved flashing red glow used when a grouped player dies or the active companion goes down. This setting is independent from their normal glow intensity.",
            getFunc = function() return math.floor((tonumber(EPC.saved.teamVisibilityDeadOpacity) or 1.00) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityDeadOpacity = (tonumber(v) or 100) / 100 if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "header", name = "Companion Glow",
        },
        {
            type = "description",
            text = "The active companion has its own visibility settings. The default companion color is purple. If the companion goes down, the glow temporarily turns red and slowly pulses until recovery.",
        },
        {
            type = "colorpicker", name = "Companion color",
            tooltip = "Sets the active companion's normal glow color. Red is reserved for the downed state and is converted to amber while the companion is active.",
            getFunc = function()
                local c = EPC.saved.teamVisibilityCompanionColor or EPC.defaults.teamVisibilityCompanionColor
                return c.r or 0.72, c.g or 0.38, c.b or 1.00, 1
            end,
            setFunc = function(r, g, b, a)
                if EPC.TeamVisibility and EPC.TeamVisibility.NormalizeAlivePlayerColor then
                    r, g, b = EPC.TeamVisibility:NormalizeAlivePlayerColor(r, g, b)
                end
                EPC.saved.teamVisibilityCompanionColor = { r = r, g = g, b = b }
                if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end
            end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = { r = 0.72, g = 0.38, b = 1.00 },
            width = "full",
        },
        {
            type = "slider", name = "Companion glow width", min = 25, max = 250, step = 5,
            tooltip = "Adjusts the companion glow width independently from group members.",
            getFunc = function() return math.floor(((tonumber(EPC.saved.teamVisibilityCompanionBeamWidth) or 3.55) / 3.55) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityCompanionBeamWidth = 3.55 * ((tonumber(v) or 100) / 100) if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Companion glow height", min = 25, max = 150, step = 5,
            tooltip = "Adjusts the companion glow height independently from group members.",
            getFunc = function() return math.floor(((tonumber(EPC.saved.teamVisibilityCompanionBeamHeight) or 8.20) / 8.20) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityCompanionBeamHeight = 8.20 * ((tonumber(v) or 100) / 100) if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Companion glow intensity", min = 10, max = 100, step = 5,
            tooltip = "Controls how transparent or bright the companion glow appears. Higher values now render at full additive brightness instead of being capped low.",
            getFunc = function() return math.floor((tonumber(EPC.saved.teamVisibilityCompanionOpacity) or 0.24) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityCompanionOpacity = (tonumber(v) or 24) / 100 if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 24,
            width = "half",
        },
        {
            type = "checkbox", name = "Companion glow through obstacles",
            tooltip = "Keeps the companion glow visible through walls, trees, and world geometry where ESO permits it.",
            getFunc = function() return EPC.saved.teamVisibilityCompanionThroughWalls ~= false end,
            setFunc = function(v) EPC.saved.teamVisibilityCompanionThroughWalls = v == true if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = true,
            width = "half",
        },
        {
            type = "button", name = "Reset companion glow", buttonText = "Reset Companion",
            func = function()
                EPC.saved.teamVisibilityCompanionColor = { r = 0.72, g = 0.38, b = 1.00 }
                EPC.saved.teamVisibilityCompanionBeamWidth = 3.55
                EPC.saved.teamVisibilityCompanionBeamHeight = 8.20
                EPC.saved.teamVisibilityCompanionOpacity = 0.24
                EPC.saved.teamVisibilityCompanionThroughWalls = true
                if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end
            end,
            width = "half",
        },
        {
            type = "header", name = "Group Default Glow",
        },
        {
            type = "checkbox", name = "Default group glow through obstacles",
            tooltip = "Default obstacle visibility for group members that do not have a player-specific override.",
            getFunc = function() return EPC.saved.teamVisibilityThroughWalls ~= false end,
            setFunc = function(v) EPC.saved.teamVisibilityThroughWalls = v == true if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = EPC.defaults.teamVisibilityThroughWalls,
            width = "half",
        },
        {
            type = "slider", name = "Default group glow width", min = 25, max = 250, step = 5,
            tooltip = "Default width for group members without a player-specific override.",
            getFunc = function() return math.floor(((tonumber(EPC.saved.teamVisibilityBeamWidth) or 3.55) / 3.55) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityBeamWidth = 3.55 * ((tonumber(v) or 100) / 100) if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Default group glow height", min = 25, max = 150, step = 5,
            tooltip = "Default height for group members without a player-specific override.",
            getFunc = function() return math.floor(((tonumber(EPC.saved.teamVisibilityBeamHeight) or 8.20) / 8.20) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityBeamHeight = 8.20 * ((tonumber(v) or 100) / 100) if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Default group glow intensity", min = 10, max = 100, step = 5,
            tooltip = "Default brightness for group members without a player-specific override. Higher values now render at full additive brightness instead of being capped low.",
            getFunc = function() return math.floor((tonumber(EPC.saved.teamVisibilityOpacity) or 0.24) * 100 + 0.5) end,
            setFunc = function(v) EPC.saved.teamVisibilityOpacity = (tonumber(v) or 24) / 100 if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return EPC.saved.teamVisibilityEnabled == false or EPC.saved.teamVisibilityLightsEnabled == false end,
            default = 24,
            width = "half",
        },
        {
            type = "header", name = "Per-Player Group Glow",
        },
        {
            type = "description",
            text = "Choose a current group slot, then customize that teammate. The override is stored by the player's account/name and follows them if their group slot changes later. If the selected slot is empty or is your own character, the controls are disabled.",
        },
        {
            type = "dropdown", name = "Group member to customize",
            choices = groupSlotChoices,
            choicesValues = groupSlotValues,
            getFunc = function() return tonumber(EPC.saved.teamVisibilitySelectedGroupSlot) or 1 end,
            setFunc = function(v) EPC.saved.teamVisibilitySelectedGroupSlot = tonumber(v) or 1 end,
            default = 1,
            width = "full",
        },
        {
            type = "checkbox", name = "Use custom settings for selected player",
            getFunc = function() local p = selectedGroupOverride(false) return p ~= nil and p.enabled ~= false end,
            setFunc = function(v) local p = selectedGroupOverride(v == true) if p then p.enabled = v == true end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() return not selectedGroupAvailable() end,
            default = false,
            width = "full",
        },
        {
            type = "colorpicker", name = "Selected player color",
            tooltip = "Overrides the normal leader/role color for the selected teammate. Red is reserved for dead players and cannot be used as a living-player glow.",
            getFunc = function()
                local p = selectedGroupOverride(false)
                if p and p.color then return p.color.r or 0.15, p.color.g or 0.95, p.color.b or 1.00, 1 end
                return selectedGroupRoleColor()
            end,
            setFunc = function(r, g, b, a) local p = selectedGroupOverride(true) if p then if EPC.TeamVisibility and EPC.TeamVisibility.NormalizeAlivePlayerColor then r, g, b = EPC.TeamVisibility:NormalizeAlivePlayerColor(r, g, b) end p.enabled = true p.color = { r = r, g = g, b = b } end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() local p = selectedGroupOverride(false) return not selectedGroupAvailable() or not p or p.enabled == false end,
            default = { r = 0.15, g = 0.95, b = 1.00 },
            width = "full",
        },
        {
            type = "slider", name = "Selected player glow width", min = 25, max = 250, step = 5,
            getFunc = function() local p = selectedGroupOverride(false) local width = p and p.width or EPC.saved.teamVisibilityBeamWidth or 3.55 return math.floor((width / 3.55) * 100 + 0.5) end,
            setFunc = function(v) local p = selectedGroupOverride(true) if p then p.enabled = true p.width = 3.55 * ((tonumber(v) or 100) / 100) end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() local p = selectedGroupOverride(false) return not selectedGroupAvailable() or not p or p.enabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Selected player glow height", min = 25, max = 150, step = 5,
            getFunc = function() local p = selectedGroupOverride(false) local height = p and p.height or EPC.saved.teamVisibilityBeamHeight or 8.20 return math.floor((height / 8.20) * 100 + 0.5) end,
            setFunc = function(v) local p = selectedGroupOverride(true) if p then p.enabled = true p.height = 8.20 * ((tonumber(v) or 100) / 100) end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() local p = selectedGroupOverride(false) return not selectedGroupAvailable() or not p or p.enabled == false end,
            default = 100,
            width = "half",
        },
        {
            type = "slider", name = "Selected player glow intensity", min = 10, max = 100, step = 5,
            tooltip = "Controls the selected teammate's normal glow brightness up to full additive brightness. Red remains reserved for the dead/downed state.",
            getFunc = function() local p = selectedGroupOverride(false) return math.floor(((p and p.opacity) or EPC.saved.teamVisibilityOpacity or 0.24) * 100 + 0.5) end,
            setFunc = function(v) local p = selectedGroupOverride(true) if p then p.enabled = true p.opacity = (tonumber(v) or 24) / 100 end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() local p = selectedGroupOverride(false) return not selectedGroupAvailable() or not p or p.enabled == false end,
            default = 24,
            width = "half",
        },
        {
            type = "checkbox", name = "Selected player glow through obstacles",
            getFunc = function() local p = selectedGroupOverride(false) return p and p.throughWalls ~= false or false end,
            setFunc = function(v) local p = selectedGroupOverride(true) if p then p.enabled = true p.throughWalls = v == true end if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
            disabled = function() local p = selectedGroupOverride(false) return not selectedGroupAvailable() or not p or p.enabled == false end,
            default = true,
            width = "half",
        },
        {
            type = "button", name = "Reset selected player override", buttonText = "Reset Player",
            func = function()
                if EPC.TeamVisibility and EPC.TeamVisibility.GetGroupOverride then
                    local _, key = EPC.TeamVisibility:GetGroupOverride(selectedGroupTag(), false)
                    if key and EPC.saved.teamVisibilityPlayerOverrides then EPC.saved.teamVisibilityPlayerOverrides[key] = nil end
                    EPC.TeamVisibility:RefreshSettings()
                end
            end,
            disabled = function() return not selectedGroupAvailable() end,
            width = "half",
        },
        {
            type = "button", name = "Clear all player overrides", buttonText = "Clear All Players",
            func = function() EPC.saved.teamVisibilityPlayerOverrides = {} if EPC.TeamVisibility then EPC.TeamVisibility:RefreshSettings() end end,
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
            tooltip = "Choose the single authoritative quest source used for ESO assisted quest/compass behavior. Active Quest follows your selected non-main Suite Quest Finder/journal quest. Golden Pursuits follows the journal quest linked to your selected Golden Pursuit. Main Quest follows the remembered Main Story quest. Overlay visibility is independent: Active Quest and Golden Pursuits overlays can both be enabled at the same time below.",
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
            type = "slider", name = "Active quest width", min = 180, max = 900, step = 10,
            tooltip = "Changes the quest overlay width. Long quest names and objectives wrap inside this width.",
            getFunc = function() return tonumber(EPC.saved.activeQuestWidth) or 420 end,
            setFunc = function(v) EPC.saved.activeQuestWidth = v if EPC.ActiveQuest then EPC.ActiveQuest:SetSize(v, tonumber(EPC.saved.activeQuestHeight) or 160) end end,
            default = EPC.defaults.activeQuestWidth or 420,
        },
        {
            type = "slider", name = "Active quest height", min = 80, max = 520, step = 10,
            tooltip = "Changes the Active Quest viewport height. Manual sizes are respected; smaller heights simply show less wrapped objective text.",
            getFunc = function() return tonumber(EPC.saved.activeQuestHeight) or 160 end,
            setFunc = function(v) EPC.saved.activeQuestHeight = v if EPC.ActiveQuest then EPC.ActiveQuest:SetSize(tonumber(EPC.saved.activeQuestWidth) or 420, v) end end,
            default = EPC.defaults.activeQuestHeight or 160,
        },
        {
            type = "button", name = "Reset active quest size", buttonText = "Reset Quest Size",
            func = function() if EPC.ActiveQuest then EPC.ActiveQuest:ResetSize() end end,
        },
        {
            type = "header", name = "Golden Pursuits Overlay",
        },
        {
            type = "checkbox", name = "Show Golden Pursuits overlay",
            tooltip = "Shows the selected Golden Pursuit, its linked quest, and live progress. This is independent from Quest Tracker Source, so it can stay visible at the same time as the Active Quest overlay.",
            getFunc = function() return EPC.saved.showGoldenPursuitsOverlay ~= false end,
            setFunc = function(v) EPC.saved.showGoldenPursuitsOverlay = v == true if EPC.GoldenPursuits then EPC.GoldenPursuits:RefreshSelectedQuestPanel2504() end end,
            default = EPC.defaults.showGoldenPursuitsOverlay,
        },
        {
            type = "dropdown", name = "Golden Pursuits visibility",
            choices = { "Always", "Combat Only" }, choicesValues = { "ALWAYS", "COMBAT" },
            getFunc = function() return EPC.saved.goldenPursuitsVisibility or "ALWAYS" end,
            setFunc = function(v) EPC.saved.goldenPursuitsVisibility = v if EPC.GoldenPursuits then EPC.GoldenPursuits:RefreshVisibility2496() end end,
            default = EPC.defaults.goldenPursuitsVisibility or "ALWAYS",
        },
        {
            type = "button", name = "Reset Golden Pursuits position", buttonText = "Reset Golden Pursuits",
            func = function() if EPC.GoldenPursuits then EPC.GoldenPursuits:ResetPosition() EPC.GoldenPursuits:RefreshSelectedQuestPanel2504() end end,
        },
        {
            type = "slider", name = "Golden Pursuits width", min = 180, max = 900, step = 10,
            tooltip = "Changes the Golden Pursuits overlay width.",
            getFunc = function() return tonumber(EPC.saved.goldenPursuitsWidth) or 420 end,
            setFunc = function(v) EPC.saved.goldenPursuitsWidth = v if EPC.GoldenPursuits then EPC.GoldenPursuits:SetSize(v, tonumber(EPC.saved.goldenPursuitsHeight) or 136) end end,
            default = EPC.defaults.goldenPursuitsWidth or 420,
        },
        {
            type = "slider", name = "Golden Pursuits height", min = 90, max = 420, step = 10,
            tooltip = "Changes the Golden Pursuits viewport height. Compact sizes clip extra rows instead of forcing the overlay larger.",
            getFunc = function() return tonumber(EPC.saved.goldenPursuitsHeight) or 136 end,
            setFunc = function(v) EPC.saved.goldenPursuitsHeight = v if EPC.GoldenPursuits then EPC.GoldenPursuits:SetSize(tonumber(EPC.saved.goldenPursuitsWidth) or 420, v) end end,
            default = EPC.defaults.goldenPursuitsHeight or 136,
        },
        {
            type = "button", name = "Reset Golden Pursuits size", buttonText = "Reset Golden Size",
            func = function() if EPC.GoldenPursuits then EPC.GoldenPursuits:ResetSize() EPC.GoldenPursuits:RefreshSelectedQuestPanel2504() end end,
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
            tooltip = "Always keeps the overlay visible during gameplay. Combat Only shows it only in combat. Alliance XP / AP Gain Only keeps it hidden until you earn Alliance Rank progress, then shows it for about 10 seconds.",
            choices = { "Always", "Combat Only", "Alliance XP / AP Gain Only" }, choicesValues = { "ALWAYS", "COMBAT", "GAIN" },
            getFunc = function() return EPC.saved.allianceRankVisibility or "ALWAYS" end,
            setFunc = function(v)
                EPC.saved.allianceRankVisibility = v
                if EPC.AllianceRank then
                    EPC.AllianceRank.gainVisibleUntilMs2960 = 0
                    EPC.AllianceRank:Refresh()
                end
            end,
            default = EPC.defaults.allianceRankVisibility,
        },
        {
            type = "button", name = "Test Alliance Rank gain popup", buttonText = "Test AP Gain Popup",
            tooltip = "Shows the Alliance Rank overlay using the same 10-second popup used by Alliance XP / AP Gain Only mode. Use this to verify the overlay and its position without waiting to earn AP.",
            func = function()
                if EPC.AllianceRank and EPC.AllianceRank.ShowForAllianceGain2960 then
                    EPC.AllianceRank:ShowForAllianceGain2960()
                end
            end,
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
            type = "header", name = "Character Level / Champion Progress Overlay",
        },
        {
            type = "checkbox", name = "Show Level / Champion overlay",
            tooltip = "Levels 1-49: shows character level and live XP progress. At level 50 it automatically switches to the Champion Point overlay with Craft, Warfare, and Fitness totals.",
            getFunc = function() return EPC.saved.showChampionOverlay ~= false end,
            setFunc = function(v)
                EPC.saved.showChampionOverlay = v == true
                if EPC.ChampionOverlay then EPC.ChampionOverlay:Refresh() end
            end,
            default = EPC.defaults.showChampionOverlay,
        },
        {
            type = "dropdown", name = "Champion-stage visibility",
            tooltip = "The Level / XP overlay stays active from levels 1-49. After level 50, Always On keeps the Champion overlay visible; Champion Point Gain Only shows it for 10 seconds when a Champion Point is earned.",
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
            type = "button", name = "Reset progression overlay position", buttonText = "Reset Progress Overlay",
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
            type = "header", name = "Quickslot Overlay",
        },
        {
            type = "checkbox", name = "Show quickslot overlay",
            tooltip = "Master switch for the quickslot overlay. When enabled, the visibility setting below controls when it appears.",
            getFunc = function() return EPC.saved.showQuickslotOverlay ~= false end,
            setFunc = function(v)
                EPC.saved.showQuickslotOverlay = v == true
                if EPC.QuickslotOverlay then EPC.QuickslotOverlay:Refresh() end
            end,
            default = EPC.defaults.showQuickslotOverlay,
        },
        {
            type = "dropdown", name = "When quickslot overlay appears",
            tooltip = "Always = keep the selected quickslot visible during normal gameplay. Before & During Combat = hidden while roaming, appears when you line up an attackable enemy, stays visible during combat, then hides again when combat ends. Before Combat Only = show only while an attackable enemy is targeted before combat. In Combat Only = show only while fighting.",
            choices = { "Always", "Before & During Combat", "Before Combat Only", "In Combat Only" },
            choicesValues = { "ALWAYS", "BEFORE_AND_DURING", "BEFORE_ONLY", "COMBAT" },
            getFunc = function()
                local mode = EPC.saved.quickslotOverlayVisibility or "BEFORE_AND_DURING"
                -- Keep legacy values compatible without remapping the real ALWAYS mode.
                if mode == "BEFORE_COMBAT" then
                    mode = "BEFORE_AND_DURING"
                    EPC.saved.quickslotOverlayVisibility = mode
                elseif mode == "OUT_OF_COMBAT" then
                    mode = "BEFORE_ONLY"
                    EPC.saved.quickslotOverlayVisibility = mode
                end
                return mode
            end,
            setFunc = function(v)
                EPC.saved.quickslotOverlayVisibility = v or "BEFORE_AND_DURING"
                if EPC.QuickslotOverlay then EPC.QuickslotOverlay:Refresh() end
            end,
            default = "BEFORE_AND_DURING",
        },
        {
            type = "description",
            text = "Tip: use HUD Layout Mode to move the quickslot overlay. Its normal visibility rule is ignored while you are positioning it.",
        },
        {
            type = "button", name = "Reset quickslot overlay position", buttonText = "Reset Quickslot",
            func = function()
                if EPC.QuickslotOverlay then
                    EPC.QuickslotOverlay:ResetPosition()
                    EPC.QuickslotOverlay:Refresh()
                end
            end,
        },
        {
            type = "header", name = "Infinite Archive Overlay",
        },
        {
            type = "checkbox", name = "Show Infinite Archive overlay",
            tooltip = "Shows the ESO Adventurer Suite Infinite Archive tracker. ESO's built-in Infinite Archive tracker is suppressed so only the Suite overlay can appear.",
            getFunc = function() return EPC.saved.showInfiniteArchiveOverlay ~= false end,
            setFunc = function(v)
                EPC.saved.showInfiniteArchiveOverlay = v == true
                if EPC.InfiniteArchiveOverlay then EPC.InfiniteArchiveOverlay:Refresh() end
            end,
            default = EPC.defaults.showInfiniteArchiveOverlay,
        },
        {
            type = "slider", name = "Infinite Archive overlay scale", min = 65, max = 180, step = 5,
            tooltip = "Changes the size of the Suite-owned Infinite Archive tracker.",
            getFunc = function() return math.floor((tonumber(EPC.saved.infiniteArchiveOverlayScale) or 1.0) * 100) end,
            setFunc = function(v)
                EPC.saved.infiniteArchiveOverlayScale = v / 100
                if EPC.InfiniteArchiveOverlay then EPC.InfiniteArchiveOverlay:Refresh() end
            end,
            default = math.floor((EPC.defaults.infiniteArchiveOverlayScale or 1.0) * 100),
        },
        {
            type = "description",
            text = "Use HUD Layout Mode to drag the Suite Infinite Archive tracker anywhere. ESO's built-in Infinite Archive tracker stays hidden at all times, including menus and focus changes.",
        },
        {
            type = "button", name = "Move Infinite Archive overlay", buttonText = "Move Infinite Archive",
            tooltip = "Starts HUD Layout Mode and immediately shows the Suite-owned Infinite Archive preview above Settings so you can drag it.",
            func = function()
                if EPC.SetUnitFramesMoveMode then EPC:SetUnitFramesMoveMode(true)
                elseif EPC.InfiniteArchiveOverlay then EPC.InfiniteArchiveOverlay:SetLayoutMode(true) end
            end,
            width = "half",
        },
        {
            type = "button", name = "Reset Infinite Archive overlay position", buttonText = "Reset Infinite Archive",
            width = "half",
            func = function()
                if EPC.InfiniteArchiveOverlay then
                    EPC.InfiniteArchiveOverlay:ResetPosition()
                end
            end,
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
            tooltip = "Recommended and enabled by default. Hides Player, Target, Group, Raid, Live Stats, Stable Training timer, Clock, Active Quest, Golden Pursuits, Mini Map, Alliance Rank, and combat HUD while Pause, Character, Inventory, the full World Map, Journal, Crafting, Store, Collections, and similar UI scenes are open. Restores them automatically in gameplay.",
            getFunc = function() return EPC.saved.hudHideInMenus ~= false end,
            setFunc = function(v) EPC.saved.hudHideInMenus = v == true if EPC.RefreshGameplayOverlays then EPC:RefreshGameplayOverlays() end end,
            default = EPC.defaults.hudHideInMenus,
        },
        {
            type = "header", name = "Unit Frame Designs",
        },
        {
            type = "description",
            title = "Player / Target / Group / Raid designs",
            text = "1 - ESO Classic: traditional ESO-shaped equal-width stacked resources.\n2 - Compact Stack: a tighter equal-width stacked layout.\n3 - Rect Stack: clean rectangular resources stacked vertically.\n4 - Triple Blocks: Health, Magicka, and Stamina arranged as three horizontal blocks.\n5 - Side Meters: wide Health with compact Magicka and Stamina meters at the side.\n6 - Center Core: centered Health with smaller centered Magicka and Stamina underneath.\n7 - Slim Lines: thin, compact resource lines for a minimal HUD.",
        },
        {
            type = "checkbox", name = "Replace ALL ESO unit frames",
            tooltip = "When enabled, the Suite replaces the keyboard player, target, local companion, group, and raid frames. ESO's native boss-health display is left alone. Turn this off to restore the other native ESO frames.",
            getFunc = function() return EPC.saved.replaceDefaultUnitFrames ~= false end,
            setFunc = function(v) EPC.saved.replaceDefaultUnitFrames = v == true if EPC.UnitFrames then EPC.UnitFrames:ApplyDefaultFrameReplacement() EPC.UnitFrames:RefreshAll(true) end end,
            default = EPC.defaults.replaceDefaultUnitFrames,
        },
        {
            type = "dropdown", name = "Unit frame design",
            tooltip = "Changes the actual layout shared by the Suite Player, Target, Group, and Raid frames. The seven distinct designs are numbered 1 through 7 in display order. Saved screen positions and scale are preserved.",
            choices = { "1 - ESO Classic", "2 - Compact Stack", "3 - Rect Stack", "4 - Triple Blocks", "5 - Side Meters", "6 - Center Core", "7 - Slim Lines" },
            choicesValues = { "ESO_CLASSIC", "COMPACT_STACK", "RECT_STACK", "TRIPLE_BLOCKS", "SIDE_METERS", "CENTER_CORE", "SLIM_LINES" },
            getFunc = function()
                local v = EPC.saved.unitFrameVisualStyle or "ESO_CLASSIC"
                if v == "CLEAN_MINIMAL" then return "COMPACT_STACK" end
                -- Removed/similar designs migrate to the closest retained centered style.
                if v == "DARK_GOLD" or v == "ARCANE_BLUE" or v == "HIGH_CONTRAST"
                    or v == "SPLIT_RESOURCES" or v == "WIDE_PLATE" or v == "TACTICAL_GRID" then
                    EPC.saved.unitFrameVisualStyle = "CENTER_CORE"
                    return "CENTER_CORE"
                end
                return v
            end,
            setFunc = function(v)
                EPC.saved.unitFrameVisualStyle = v or "ESO_CLASSIC"
                if EPC.UnitFrames then
                    EPC.UnitFrames:ApplyVisualStyle()
                    EPC.UnitFrames:RefreshAll(true)
                end
            end,
            default = EPC.defaults.unitFrameVisualStyle,
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
            tooltip = "PEN, PWR, Spell Resistance, Physical Resistance, Critical Chance, and Critical Damage. These exact live values now feed Game Combat, where fight-weighted effective values are saved with the same combat sample. Combat-only visibility is enabled by default.",
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
            type = "header", name = "World Map Teleporter",
        },
        {
            type = "description",
            text = "Opens the Suite's full map-side teleporter whenever the World Map opens. Includes all travel views through a compact View menu: Zones, Current Map, Maps/Surveys, Delves, Quests, Group, Friends, Guilds, Wayshrines, Houses, Player Homes, Dungeons, Instances, Antiquity Leads, Favorites, and Blocked. Tools such as sorting, quick travel, discovery routing, favorites/blacklists, and right-click actions remain available without filling the map with buttons. ESO's normal access and travel restrictions still apply.",
        },
        {
            type = "checkbox", name = "Show Map Teleporter with World Map",
            tooltip = "Shows the Suite Map Teleporter automatically every time the full World Map opens.",
            getFunc = function() return EPC.saved.mapTeleporterEnabled ~= false end,
            setFunc = function(v) EPC.saved.mapTeleporterEnabled = v == true if EPC.Travel and EPC.Travel.RefreshMapTeleporterVisibility then EPC.Travel:RefreshMapTeleporterVisibility() end end,
            default = EPC.defaults.mapTeleporterEnabled,
        },
        {
            type = "checkbox", name = "Include owned houses",
            tooltip = "Adds your owned houses and primary residence to All, Zones, Current Map, Houses, and Favorites views.",
            getFunc = function() return EPC.saved.mapTeleporterIncludeHouses ~= false end,
            setFunc = function(v) EPC.saved.mapTeleporterIncludeHouses = v == true if EPC.Travel then EPC.Travel:RefreshMapTeleporter() end end,
            default = EPC.defaults.mapTeleporterIncludeHouses,
        },
        {
            type = "checkbox", name = "Show zones without online players",
            tooltip = "The Zones tab also lists zones reachable through a discovered wayshrine or owned house even when no Group/Friend/Guild member is there.",
            getFunc = function() return EPC.saved.mapTeleporterShowAllZones ~= false end,
            setFunc = function(v) EPC.saved.mapTeleporterShowAllZones = v == true if EPC.Travel then EPC.Travel:RefreshMapTeleporter() end end,
            default = EPC.defaults.mapTeleporterShowAllZones,
        },
        {
            type = "dropdown", name = "Teleporter sorting",
            choices = { "Smart / Favorites First", "Zone", "Source", "Player Count", "Most Used", "Last Used" },
            choicesValues = { "SMART", "ZONE", "SOURCE", "PLAYER_COUNT", "MOST_USED", "LAST_USED" },
            getFunc = function() return EPC.saved.mapTeleporterSortMode or "SMART" end,
            setFunc = function(v) EPC.saved.mapTeleporterSortMode = v if EPC.Travel then EPC.Travel:RefreshMapTeleporter() end end,
            default = EPC.defaults.mapTeleporterSortMode,
        },
        {
            type = "slider", name = "Visible teleporter rows", min = 8, max = 20, step = 1,
            tooltip = "Controls how many destination rows are shown per page. The panel still fills the map's full height.",
            getFunc = function() return EPC.saved.mapTeleporterVisibleRows or 15 end,
            setFunc = function(v) EPC.saved.mapTeleporterVisibleRows = tonumber(v) or 15 if EPC.Travel then EPC.Travel:RefreshMapTeleporter() end end,
            default = EPC.defaults.mapTeleporterVisibleRows,
        },
        {
            type = "checkbox", name = "Show blacklisted destinations",
            tooltip = "Normally blacklisted players/zones are hidden. Enable this to display them in red so they can be unblacklisted from the row context menu.",
            getFunc = function() return EPC.saved.mapTeleporterShowBlacklisted == true end,
            setFunc = function(v) EPC.saved.mapTeleporterShowBlacklisted = v == true if EPC.Travel then EPC.Travel:RefreshMapTeleporter() end end,
            default = EPC.defaults.mapTeleporterShowBlacklisted,
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
            tooltip = "Closes Suite Settings, releases the mouse, and shows every movable HUD overlay. A small HUD Layout bar appears with Save & Exit and Reset Layout, so Settings never blocks the overlays while you position them.",
            func = function() if EPC.SetUnitFramesMoveMode then EPC:SetUnitFramesMoveMode(true) end end,
            width = "half",
        },
        {
            type = "button", name = "HUD layout exit", buttonText = "Use Save & Exit",
            tooltip = "HUD Layout Mode can only be exited with the SAVE & EXIT button on the movable HUD Layout control bar. This prevents ESC, keybinds, or menu changes from accidentally closing layout mode.",
            func = function()
                if EPC.unitFramesMoveMode then
                    if EPC.SetHUDLayoutControlBarVisible then EPC:SetHUDLayoutControlBarVisible(true) end
                    if EPC.RaiseLayoutOverlays then EPC:RaiseLayoutOverlays() end
                    EPC:Print("Use SAVE & EXIT on the HUD Layout bar to return to gameplay.")
                end
            end,
            width = "half",
        },
        {
            type = "button", name = "Reset HUD frame positions", buttonText = "Reset Frames",
            tooltip = "Restores default positions for Player, Target, Group, Raid, Live Combat Stats, Mini Map, Stable, Clock, Active Quest, Alliance Rank, Repair Estimate, Use Synergy, Rotation Assistant, Antiquity Augur Guide, Antiquity Tile Selector, and every Ability icon.",
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
            tooltip = "If the suite is minimized when Suite interaction mode is entered, expand it automatically.",
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
            type = "dropdown", name = "Endgame gear preset",
            tooltip = "Chooses the content profile used by BEST ENDGAME. Current templates cover all seven classes for Damage, Tank, and Healer roles. AUTO uses the selected LFG role, and Combat role awareness can force a role profile.",
            choices = { "Trial / Endgame", "Single Target", "AoE / Trash", "Solo" },
            choicesValues = { "TRIAL", "SINGLE_TARGET", "AOE_TRASH", "SOLO" },
            getFunc = function()
                return EPC.GearOptimizer and select(1, EPC.GearOptimizer:GetPreset()) or (EPC.saved.gearOptimizerPreset or "TRIAL")
            end,
            setFunc = function(v)
                if EPC.GearOptimizer then EPC.GearOptimizer:SetPreset(v) else EPC.saved.gearOptimizerPreset = v end
                EPC:RequestRefresh("gear-endgame-preset")
            end,
            default = EPC.defaults.gearOptimizerPreset or "TRIAL",
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
            type = "header", name = "Built-in Bug Catcher",
        },
        {
            type = "description",
            title = "Suite error log",
            text = "Captures Lua errors, protected-function violations, and low-Lua-memory notices into ESO Adventurer Suite without replacing ESO's own error handler. Repeated identical errors are grouped together. Use /easscan (or /easbugs scan) for a runtime addon health scan, /easbugs to list recent errors, or /easbugs last to print the full latest stack trace to chat for copying/reporting.",
        },
        {
            type = "checkbox", name = "Enable built-in Bug Catcher",
            getFunc = function() return EPC.saved.bugCatcherEnabled ~= false end,
            setFunc = function(v) EPC.saved.bugCatcherEnabled = v == true end,
            default = EPC.defaults.bugCatcherEnabled, width = "half",
        },
        {
            type = "checkbox", name = "Bug Catcher chat notice",
            tooltip = "Prints a short notice when an error is caught. Full stack traces are stored instead of spammed into chat automatically.",
            getFunc = function() return EPC.saved.bugCatcherNotifyChat ~= false end,
            setFunc = function(v) EPC.saved.bugCatcherNotifyChat = v == true end,
            disabled = function() return EPC.saved.bugCatcherEnabled == false end,
            default = EPC.defaults.bugCatcherNotifyChat, width = "half",
        },
        {
            type = "checkbox", name = "Suppress ESO Lua error popup",
            tooltip = "After the Bug Catcher records a live Lua error, ask ESO to close its standard error dialog. The error remains stored in the Suite and can be viewed with /easbugs last.",
            getFunc = function() return EPC.saved.bugCatcherSuppressPopup == true end,
            setFunc = function(v) EPC.saved.bugCatcherSuppressPopup = v == true end,
            disabled = function() return EPC.saved.bugCatcherEnabled == false end,
            default = EPC.defaults.bugCatcherSuppressPopup, width = "full",
        },
        {
            type = "slider", name = "Bug Catcher stored errors", min = 10, max = 100, step = 5,
            tooltip = "Maximum number of unique error records kept in SavedVariables. Duplicate occurrences are counted on the existing record.",
            getFunc = function() return tonumber(EPC.saved.bugCatcherMaxErrors) or 40 end,
            setFunc = function(v) EPC.saved.bugCatcherMaxErrors = tonumber(v) or 40 if EPC.BugCatcher then EPC.BugCatcher:TrimToLimit() end end,
            disabled = function() return EPC.saved.bugCatcherEnabled == false end,
            default = EPC.defaults.bugCatcherMaxErrors, width = "full",
        },
        {
            type = "button", name = "Show last caught error", buttonText = "Print Last Error",
            func = function() if EPC.BugCatcher then EPC.BugCatcher:PrintLast() end end,
            disabled = function() return not EPC.BugCatcher end, width = "half",
        },
        {
            type = "button", name = "Bug Catcher status", buttonText = "Print Bug Status",
            func = function() if EPC.BugCatcher then EPC:Print(EPC.BugCatcher:GetStatusText()) end end,
            disabled = function() return not EPC.BugCatcher end, width = "half",
        },
        {
            type = "button", name = "Clear Bug Catcher log", buttonText = "Clear Error Log",
            func = function() if EPC.BugCatcher then EPC.BugCatcher:Clear() EPC:Print("Bug Catcher log cleared.") end end,
            disabled = function() return not EPC.BugCatcher end, width = "full",
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
        "ANTIQUITIES",
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
        ANTIQUITIES = { name = "Antiquities & Lead Finder", tooltip = "Antiquity dig-site navigation, learned 3D shovel spawns, Augur/bonus-loot assistance, and the Lead Finder source browser." },
        UTILITIES = { name = "Utilities & Inventory", tooltip = "Utility Command Center, inventory snapshots, research/collection alerts, and search tools." },
    }

    local headerCategory = {
        ["Live Group Finder"] = "ACTIVITIES",
        ["Game Mode Combat Report"] = "COMBAT",
        ["Automatic Equipment Maintenance"] = "GEAR",
        ["Repair / Recharge Estimate Overlay"] = "HUD",
        ["World Combat Visibility"] = "COMBAT",
        ["Dungeon / Trial Chest Finder"] = "HUD",
        ["Resource 3D Pins"] = "HUD",
        ["Antiquity Assistant"] = "ANTIQUITIES",
        ["Team Visibility"] = "HUD",
        ["Persistent HUD & Unit Frames"] = "FRAMES",
        ["Unit Frame Designs"] = "FRAMES",
        ["Stable Training Timer"] = "HUD",
        ["Clock"] = "HUD",
        ["Quest Tracking"] = "HUD",
        ["Active Quest Overlay"] = "HUD",
        ["Golden Pursuits Overlay"] = "HUD",
        ["Alliance Rank Overlay"] = "HUD",
        ["Champion Level Overlay"] = "HUD",
        ["Ability Overlays"] = "HUD",
        ["Quickslot Overlay"] = "HUD",
        ["Infinite Archive Overlay"] = "HUD",
        ["Custom ESO Reticle"] = "HUD",
        ["Tamriel Codex"] = "CODEX",
        ["World Map Teleporter"] = "MAP",
        ["Mini Map"] = "MAP",
        ["Gameplay & Challenge Difficulty"] = "DIFFICULTY",
        ["Target Build"] = "COMBAT",
        ["Built-in Bug Catcher"] = "UTILITIES",
        ["Utility Command Center"] = "UTILITIES",
        ["Antiquity Lead Finder"] = "ANTIQUITIES",
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

        ["Enable Game Mode Combat Report"] = "COMBAT",
        ["Enable Antiquity Lead Finder"] = "ANTIQUITIES",
        ["Open Antiquity Lead Finder"] = "ANTIQUITIES",
        ["Reset Lead Finder window"] = "ANTIQUITIES",
        ["Report opacity"] = "COMBAT",
        ["Reset report position and size"] = "COMBAT",
        ["Clear saved combat reports"] = "COMBAT",

        ["Replace ESO default unit frames"] = "FRAMES",
        ["Replace ALL ESO unit frames"] = "FRAMES",
        ["Unit frame design"] = "FRAMES",
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
        ["Show Golden Pursuits overlay"] = "HUD",
        ["Golden Pursuits visibility"] = "HUD",
        ["Reset Golden Pursuits position"] = "HUD",
        ["Golden Pursuits width"] = "HUD",
        ["Golden Pursuits height"] = "HUD",
        ["Reset Golden Pursuits size"] = "HUD",
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
