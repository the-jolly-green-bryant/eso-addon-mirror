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

    LAM:RegisterOptionControls(panelName, {
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
            type = "header", name = "World Combat Visibility",
        },
        {
            type = "checkbox", name = "Always show enemy overhead health bars",
            tooltip = "Keeps hostile NPC and hostile-player health bars visible above nearby enemies, not only the current target.",
            getFunc = function() return EPC.saved.showEnemyOverheadHealthBars ~= false end,
            setFunc = function(v) EPC.saved.showEnemyOverheadHealthBars = v == true if EPC.CombatPresentation then EPC.CombatPresentation:Refresh() end end,
            default = EPC.defaults.showEnemyOverheadHealthBars,
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
    })
end
