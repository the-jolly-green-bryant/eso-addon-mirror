DynamicCP = {
    name = "DynamicCPLite",
    version = "1.0.1",
    SmartPresets = {},
    PointsStringBuilder = {},
}

local defaultOptions = {
    firstTime = true,
    lastChangelog = 0,

    pulldownExpanded = true,

-- user options
    showLabels = true,
    scale = 1.0,
    debug = false,
    showLeaveWarning = true,
    showCooldownWarning = true,
    doubleClick = true,
    showPresetsWithCP = true,
    showPulldownPoints = false,
    showPointGainedMessage = true,
    passiveLabelColor = {1, 1, 0.5},
    passiveLabelSize = 24,
    slottableLabelColor = {1, 1, 1},
    slottableLabelSize = 18,
    clusterLabelColor = {1, 0.7, 1},
    clusterLabelSize = 13,
    showTotalsLabel = true,

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

-- Internal
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
    DynamicCP.savedOptions = ZO_SavedVars:NewAccountWide("DynamicCPLiteSavedVariables", 1, "Options", defaultOptions)

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        debugFilter = LibFilteredChatPanel:CreateFilter(DynamicCP.name, "/esoui/art/champion/champion_icon.dds", {0.5, 0.8, 1}, false)
    end

    DynamicCP.dbg("Initializing...")

    DynamicCP.InitializeStyles()

    -- Settings menu
    DynamicCP:CreateSettingsMenu()

    ZO_CreateStringId("SI_BINDING_NAME_DCP_TOGGLE_QUICKSTARS", "Toggle Quickstars Panel")
    ZO_CreateStringId("SI_BINDING_NAME_DCP_CYCLE_QUICKSTARS", "Cycle Quickstars Tab")

    -- Initialize
    DynamicCP.InitCooldown()

    -- Register events
    RegisterEvents()

    CHAMPION_PERKS_CONSTELLATIONS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if (newState == SCENE_HIDDEN) then
            DynamicCP.OnExitedCPScreen()
            return
        end

        if (newState ~= SCENE_SHOWN) then return end

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
        elseif (arg == "settings") then
            DynamicCP.OpenSettingsMenu()
        else
            DynamicCP.msg("Usage: /dcp <quickstar || settings>")
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
