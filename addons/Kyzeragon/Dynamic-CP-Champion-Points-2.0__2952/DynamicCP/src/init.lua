DynamicCP = {
    name = "DynamicCP",
    version = "3.3.0",
    SmartPresets = {},
    PointsStringBuilder = {},
}

local defaultOptions = {
    firstTime = true,
    lastChangelog = 0,

    cp = {
        Red = {},
        Green = {}, -- ["Fisher"] = { ["roles"] = { ["Healer"] = false, ["Dps"] = true, ["Tank"] = false, }, [1] = { [65] = 0, }, ["slotSet"] = "Tank",},
        Blue = {},
    },
    pulldownExpanded = true,
    charData = {}, -- {[123214123] = {green="craft", blue="dps", red="magdps", armoryBuilds={[1]={green="craft", blue="dps", red="magdps"}}}}

    slotGroupsFirstTime = true,
    slotGroups = { -- Key them by ID, so that they're easily renamable
        Red = {}, -- [1] = {["name"] = "DPS", [1] = 12, [2] = 34, [3] = 56, [4] = 78}, ["Tank"] = {["name"] = "Tank", [1] = 12, [2] = 34, [3] = 56, [4] = 78},
        Green = {},
        Blue = {},
    },

-- user options
    hideBackground = false,
    showLabels = true,
    scale = 1.0,
    debug = false,
    showLeaveWarning = true,
    showCooldownWarning = true,
    slotHigherStars = true,
    doubleClick = true,
    showPresetsWithCP = true,
    showPulldownPoints = false,
    showPulldownSlottableSets = true,
    showPointGainedMessage = true,
    presetsBackdropAlpha = 0.5,
    presetsShowClassButtons = true, -- Not settable by user - side presets don't have class buttons
    passiveLabelColor = {1, 1, 0.5},
    passiveLabelSize = 24,
    slottableLabelColor = {1, 1, 1},
    slottableLabelSize = 18,
    clusterLabelColor = {1, 0.7, 1},
    clusterLabelSize = 13,
    showTotalsLabel = true,

    quickstarsFirstTime = true,
    quickstarsX = GuiRoot:GetWidth() / 4, -- Anchor TOPLEFT
    quickstarsY = GuiRoot:GetHeight() / 4,
    quickstarsShowGreen = true, -- quickstars 2.0
    quickstarsShowBlue = false, -- quickstars 2.0
    quickstarsShowRed = false, -- quickstars 2.0
    showQuickstars = true,
    lockQuickstars = false,
    quickstarsWidth = 200,
    quickstarsAlpha = 0.5,
    quickstarsScale = 1.0,
    quickstarsVertical = true,
    quickstarsMirrored = false,
    quickstarsDropdownHideSlotted = false,
    quickstarsShowOnHud = true,
    quickstarsShowOnHudUi = true,
    quickstarsShowOnCpScreen = false,
    quickstarsShowCooldown = true,
    quickstarsCooldownColor = {0.7, 0.7, 0.7},
    quickstarsPlaySound = true,
    quickstarsShowSlotSet = true,

    customRules = {
        playSound = true, -- CHAMPION_POINTS_COMMITTED
        showInChat = true,
        extraChat = true,
        firstTime = true,
        overrideOrder = true,
        autoSlot = false,
        autoDetectStamMag = true,
        promptConflicts = true,
        applyBossOnCombatEnd = true,
        applyOnCooldownEnd = true,
        rules = {}, -- {["rule"] = {stars = {[1] = 123,}}} (see ruleData)
    },

-- Internal
    modelessX = GuiRoot:GetWidth() / 4, -- Anchor center
    modelessY = 0,

    convertedIndices = false, -- Pre-Blackwood to Blackwood indices
    usingSkillId = false, -- Converted from Blackwood indices to saving using skilLId

    -- 1: added quickstarsShowOnHudUi, which should inherit quickstarsShowOnHud
    -- settingsVersion = 1,
}

---------------------------------------------------------------------
local initialOpened = false
local debugFilter

---------------------------------------------------------------------
-- Collect messages for displaying later when addon is not fully loaded
DynamicCP.dbgMessages = {}
function DynamicCP.dbg(msg)
    if (not msg) then return end
    if (not DynamicCP.savedOptions.debug) then return end
    if (debugFilter) then
        debugFilter:AddMessage(tostring(msg))
    elseif (CHAT_ROUTER) then
        d("|c6666FF[DCP]|r " .. tostring(msg))
    else
        DynamicCP.dbgMessages[#DynamicCP.dbgMessages + 1] = msg
    end
end

DynamicCP.messages = {}
function DynamicCP.msg(msg)
    if (not msg) then return end
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage("|c3bdb5e[DynamicCP]|cAAAAAA " .. tostring(msg) .. "|r")
    else
        DynamicCP.messages[#DynamicCP.messages + 1] = msg
    end
end


---------------------------------------------------------------------
-- Post Load (player loaded)
local function OnPlayerActivated(_, initial)
    -- Display all the delayed chat
    for i = 1, #DynamicCP.dbgMessages do
        d("|c6666FF[DCPdelay]|r " .. tostring(DynamicCP.dbgMessages[i]))
    end
    DynamicCP.dbgMessages = {}

    for i = 1, #DynamicCP.messages do
        CHAT_ROUTER:AddSystemMessage("|c3bdb5e[DynamicCP]|cAAAAAA " .. tostring(DynamicCP.messages[i]) .. "|r")
    end
    DynamicCP.messages = {}

    -- Post load init
    DynamicCP.InitQuickstars()
    DynamicCP.InitCustomRules() -- Do this here so we don't do rules on login/reload

    if (DynamicCP.savedOptions.hideBackground) then
        local backgroundOverride = function(line) return "/esoui/art/scrying/backdrop_stars.dds" end
        GetChampionDisciplineZoomedInBackground = backgroundOverride
        GetChampionDisciplineZoomedOutBackground = backgroundOverride
        GetChampionDisciplineSelectedZoomedOutOverlay = backgroundOverride
    end

    -- Hide the pulldown because it's expanded by default
    if (not DynamicCP.savedOptions.pulldownExpanded) then
        DynamicCPPulldownTabArrowExpanded:SetHidden(true)
        DynamicCPPulldownTabArrowHidden:SetHidden(IsConsoleUI())
        DynamicCPPulldown:SetHidden(true)
        DynamicCPPulldownTab:SetAnchor(TOP, ZO_ChampionPerksActionBar, BOTTOM)
    end

    DynamicCPInfoLabel:SetHidden(not DynamicCP.savedOptions.showTotalsLabel)
    DynamicCPInfoLabel:SetFont(DynamicCP.GetStyles().gameBoldFont)

    EVENT_MANAGER:UnregisterForEvent(DynamicCP.name .. "Activated", EVENT_PLAYER_ACTIVATED)
end

local function UpdateAllPoints(result, isArmory)
    DynamicCP.OnPurchased(result, isArmory)
    DynamicCP.ClearCommittedCP() -- Invalidate the cache
    DynamicCP.ClearCommittedSlottables() -- Invalidate the cache
    DynamicCP.OnSlotsChanged()
    DynamicCP.QuickstarsOnPurchased()
    DynamicCPMildWarning:SetHidden(true)
end

---------------------------------------------------------------------
-- Register events
local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "Purchase", EVENT_CHAMPION_PURCHASE_RESULT, function(_, result) UpdateAllPoints(result, false) end)
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "ArmoryEquipped", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(_, result) UpdateAllPoints(result, true) end)

    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "Gained", EVENT_CHAMPION_POINT_GAINED,
        function(_, championPointsDelta)
            -- Show CP gained message
            if (DynamicCP.savedOptions.showPointGainedMessage) then
                CHAT_ROUTER:AddSystemMessage(string.format("|cAAAAAAGained %d champion point%s|r", championPointsDelta, (championPointsDelta > 1) and "s" or ""))
            end

            -- Update totals label
            DynamicCPInfoLabel:SetText(string.format(
                "|cc4c19eTotal:|r |t32:32:esoui/art/champion/champion_icon_32.dds|t %d"
                .. " |t32:32:esoui/art/champion/champion_points_stamina_icon-hud-32.dds|t %d"
                .. " |t32:32:esoui/art/champion/champion_points_magicka_icon-hud-32.dds|t %d"
                .. " |t32:32:esoui/art/champion/champion_points_health_icon-hud-32.dds|t %d",
                GetPlayerChampionPointsEarned(),
                GetNumSpentChampionPoints(3) + GetNumUnspentChampionPoints(3),
                GetNumSpentChampionPoints(1) + GetNumUnspentChampionPoints(1),
                GetNumSpentChampionPoints(2) + GetNumUnspentChampionPoints(2)))
        end)

    -- I guess I have to fix it myself. This prevents the bug with star animation not being initialized
    ZO_PreHook(CHAMPION_PERKS, "OnUpdate", function()
        CHAMPION_PERKS.firstStarConfirm = false
        return false
    end)
end


---------------------------------------------------------------------
-- Initialize
local function Initialize()
    DynamicCP.savedOptions = ZO_SavedVars:NewAccountWide("DynamicCPSavedVariables", 1, "Options", defaultOptions)

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        debugFilter = LibFilteredChatPanel:CreateFilter(DynamicCP.name, "/esoui/art/champion/champion_icon.dds", {0.5, 0.8, 1}, false)
    end

    DynamicCP.dbg("Initializing...")

    DynamicCP.InitializeStyles()

    -- Don't show changelog if it's the first install
    local maybeShowChangelog = true

    -- Populate defaults only on first time, otherwise the keys will be remade even if user deletes
    if (DynamicCP.savedOptions.firstTime) then
        DynamicCP.savedOptions.convertedIndices = true
        DynamicCP.savedOptions.usingSkillId = true
        DynamicCP.savedOptions.firstTime = false
        maybeShowChangelog = false
    end

    -- If this isn't a new Blackwood install, we need to convert the old indices
    -- TODO: change everything to index by ID later
    if (not DynamicCP.savedOptions.convertedIndices) then
        DynamicCP.dbg("CONVERTING TO NEW INDICES")
        for treeName, tree in pairs(DynamicCP.savedOptions.cp) do
            for cpName, cp in pairs(tree) do
                DynamicCP.dbg(cpName)
                for disciplineIndex, data in pairs(cp) do
                    DynamicCP.dbg("disciplineIndex" .. tostring(disciplineIndex))
                    local newData = {}
                    for oldSkillIndex, points in pairs(data) do
                        local converted = type(oldSkillIndex) == "number" and DynamicCP.convertIndex(disciplineIndex, oldSkillIndex) or oldSkillIndex
                        newData[converted] = points
                    end
                    DynamicCP.savedOptions.cp[treeName][cpName][disciplineIndex] = newData
                end
            end
        end
        DynamicCP.savedOptions.convertedIndices = true
    end

    -- If user is still on old data storage method with indices, we should convert them to id instead
    if (not DynamicCP.savedOptions.usingSkillId) then
        DynamicCP.dbg("CONVERTING TO IDS HALP PLZ DON'T BREAK")
        for treeName, tree in pairs(DynamicCP.savedOptions.cp) do
            for cpName, cp in pairs(tree) do
                DynamicCP.dbg(cpName)
                for disciplineIndex, data in pairs(cp) do
                    DynamicCP.dbg("disciplineIndex" .. tostring(disciplineIndex))
                    local newData = {}
                    for oldSkillIndex, points in pairs(data) do
                        local converted = type(oldSkillIndex) == "number" and DynamicCP.convertBlackwoodToId(disciplineIndex, oldSkillIndex) or oldSkillIndex
                        newData[converted] = points
                    end
                    DynamicCP.savedOptions.cp[treeName][cpName][disciplineIndex] = newData
                end
            end
        end
        DynamicCP.savedOptions.usingSkillId = true
    end

    -- Populate with example custom rule
    if (DynamicCP.savedOptions.customRules.firstTime) then
        DynamicCP.savedOptions.customRules.rules = {
            ["Example Trial"] = {
                name = "Example Trial",
                trigger = DynamicCP.TRIGGER_TRIAL,
                priority = 100,
                normal = true,
                veteran = true,
                reeval = false,
                stars = {
                    [1] = 66, -- Steed's Blessing
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
                tank = true,
                healer = true,
                dps = true,
                chars = {},
                param1 = "",
                param2 = "",
            },
            ["Example Trial Dps"] = {
                name = "Example Trial Dps",
                trigger = DynamicCP.TRIGGER_TRIAL,
                priority = 101,
                normal = true,
                veteran = true,
                reeval = false,
                stars = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] =  2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = 56, -- Spirit Mastery
                    ["Blue"] = "Blue1",
                },
                tank = false,
                healer = false,
                dps = true,
                chars = {},
                param1 = "",
                param2 = "",
            },
        }
        DynamicCP.AddOptionsForEachCharacter("Example Trial")
        DynamicCP.AddOptionsForEachCharacter("Example Trial Dps")
        DynamicCP.ShowFirstTimeDialog()
        DynamicCP.savedOptions.customRules.firstTime = false
    end

    -- Populate slottable sets
    if (DynamicCP.savedOptions.slotGroupsFirstTime) then
        DynamicCP.savedOptions.slotGroupsFirstTime = false
        DynamicCP.savedOptions.slotGroups.Blue["Blue1"] = {
            [1] = 23,
            [2] = 277,
            [3] = 8,
            [4] = 264,
            ["name"] = "Example PvE AoE",
        }
        DynamicCP.savedOptions.pulldownExpanded = true -- So it's actually seen...
    end

    -- Migrate settings versions if applicable
    if (not DynamicCP.savedOptions.settingsVersion) then
        DynamicCP.savedOptions.settingsVersion = 0
    end
    if (DynamicCP.savedOptions.settingsVersion < 1) then
        -- Inherit HUD setting for HUD_UI
        DynamicCP.dbg("Inheriting HUD option " .. tostring(DynamicCP.savedOptions.quickstarsShowOnHud))
        DynamicCP.savedOptions.quickstarsShowOnHudUi = DynamicCP.savedOptions.quickstarsShowOnHud
    end
    DynamicCP.savedOptions.settingsVersion = 1

    -- Add names to slottable sets if they already exist (from testing version, which only used names, not IDs)
    for tree, _ in pairs(DynamicCP.savedOptions.slotGroups) do
        for id, data in pairs(DynamicCP.savedOptions.slotGroups[tree]) do
            if (not data.name) then
                DynamicCP.savedOptions.slotGroups[tree][id].name = id
            end
        end
    end

    -- Settings menu
    DynamicCP:CreateSettingsMenu()
    DynamicCP.CreateCustomRulesMenu()

    ZO_CreateStringId("SI_BINDING_NAME_DCP_TOGGLE_MENU", "Toggle CP Preset Window")
    ZO_CreateStringId("SI_BINDING_NAME_DCP_TOGGLE_QUICKSTARS", "Toggle Quickstars Panel")
    ZO_CreateStringId("SI_BINDING_NAME_DCP_CYCLE_QUICKSTARS", "Cycle Quickstars Tab")
    ZO_CreateStringId("SI_BINDING_NAME_DCP_DIALOG_CONFIRM", "Confirm Custom Rules Dialog")
    ZO_CreateStringId("SI_BINDING_NAME_DCP_DIALOG_CANCEL", "Cancel Custom Rules Dialog")

    -- Initialize
    DynamicCP.InitModelessDialog()
    DynamicCP.InitCooldown()
    DynamicCP.SortRuleKeys()

    if (maybeShowChangelog) then
        DynamicCP.MaybeShowChangelog()
    end

    -- Register events
    RegisterEvents()

    DynamicCPSidePresets:SetScale(DynamicCP.savedOptions.scale)
    DynamicCPSidePresetsBackdrop:SetAlpha(DynamicCP.savedOptions.presetsBackdropAlpha)
    DynamicCPSidePresets:SetHidden(false)

    CHAMPION_PERKS_CONSTELLATIONS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if (newState == SCENE_HIDDEN) then
            DynamicCP.OnExitedCPScreen()
            return
        end

        if (newState ~= SCENE_SHOWN) then return end
        DynamicCP.GetSubControl():SetHidden(not DynamicCP.savedOptions.showPresetsWithCP)
        DynamicCP:InitializeDropdowns() -- Call it every time in case LFG role is changed

        -- First time opened calls
        if (not initialOpened) then
            initialOpened = true
            DynamicCP.InitLabels()
            DynamicCP.InitSlottables()
            DynamicCP.InitPulldown()
            if (DynamicCP.savedOptions.showLabels) then
                DynamicCP.RefreshLabels(true)
            end
        end
    end)

    SLASH_COMMANDS["/dcp"] = function(arg)
        if (arg == "quickstar" or arg == "quickstars" or arg == "q" or arg == "qs") then
            DynamicCP.ToggleQuickstars()
        elseif (arg == "rule" or arg == "rules") then
            DynamicCP.OpenCustomRulesMenu()
        elseif (arg == "settings") then
            DynamicCP.OpenSettingsMenu()
        elseif (arg == "eval") then
            DynamicCP.ReEval()
        elseif (arg == "preset" or arg == "presets") then
            DynamicCP.TogglePresetsWindow()
        else
            DynamicCP.msg("Usage: /dcp <presets || quickstar || settings || rules>")
        end
    end
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == DynamicCP.name) then
        EVENT_MANAGER:UnregisterForEvent(DynamicCP.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(DynamicCP.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
