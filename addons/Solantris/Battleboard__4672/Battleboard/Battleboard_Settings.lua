-- Battleboard_Settings.lua  (settings panel, main menu, and dialogs)
-- Part of Battleboard. Loaded before Init so bootstrap can register UI chrome.

local BL = Battleboard
local _x = BL.__constants

local LMM = _x.LMM
local LAM = _x.LAM

local DEFAULT_SCENE_HISTORY = _x.DEFAULT_SCENE_HISTORY
local DEFAULT_SCENE_METRICS = _x.DEFAULT_SCENE_METRICS
local DEFAULT_SCENE_OBSERVATORY = _x.DEFAULT_SCENE_OBSERVATORY

local MATCH_HISTORY_ICON = _x.MATCH_HISTORY_ICON
local MATCH_HISTORY_ICON_DOWN = _x.MATCH_HISTORY_ICON_DOWN
local MATCH_HISTORY_ICON_OVER = _x.MATCH_HISTORY_ICON_OVER
local STATS_ICON = _x.STATS_ICON
local STATS_ICON_DOWN = _x.STATS_ICON_DOWN
local STATS_ICON_OVER = _x.STATS_ICON_OVER
local OBSERVATORY_ICON = _x.OBSERVATORY_ICON
local OBSERVATORY_ICON_DOWN = _x.OBSERVATORY_ICON_DOWN
local OBSERVATORY_ICON_OVER = _x.OBSERVATORY_ICON_OVER
local MENU_ICON = _x.MENU_ICON
local MENU_ICON_DOWN = _x.MENU_ICON_DOWN
local MENU_ICON_OVER = _x.MENU_ICON_OVER
local MAX_LOCKED_MATCHES = _x.MAX_LOCKED_MATCHES

function BL.RegisterSettings()
    local panelData = {
        type = "panel",
        name = "Battleboard",
        displayName = "Battleboard",
        author = "Solantris",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    LAM:RegisterAddonPanel("BattleboardSettingsPanel", panelData)

    local optionsData = {
        {
            type = "description",
            text = "Manage Battleboard saved match data.",
        },
        {
            type = "header",
            name = "About",
        },
        {
            type = "description",
            text = "Battleboard saves your battleground match history. Each match is assigned an internal ID and recorded at the end of a match.",
        },
        {
            type = "description",
            text = string.format("Locked matches are protected from cleanup deletion. You can have up to %d locked at a time.", MAX_LOCKED_MATCHES),
        },
        {
            type = "header",
            name = "Display",
        },
        {
            type = "checkbox",
            name = "Show at match end",
            tooltip = "Show the large center-screen scoreboard overlay when a battleground match is saved at match end.",
            getFunc = function() return BL.vars ~= nil and BL.vars.showEndMatchScoreboard == true end,
            setFunc = function(value)
                if BL.vars then BL.vars.showEndMatchScoreboard = value == true end
            end,
        },
        {
            type = "dropdown",
            name = "Default page",
            tooltip = "Choose which Battleboard page opens from the menu or keybind.",
            choices = { "1 (History)", "2 (Metrics)", "3 (Observatory)" },
            choicesValues = { DEFAULT_SCENE_HISTORY, DEFAULT_SCENE_METRICS, DEFAULT_SCENE_OBSERVATORY },
            getFunc = function()
                return BL.GetDefaultBattleboardSceneName()
            end,
            setFunc = function(value)
                if BL.vars then
                    if value == DEFAULT_SCENE_OBSERVATORY then
                        BL.vars.defaultScene = DEFAULT_SCENE_OBSERVATORY
                    elseif value == DEFAULT_SCENE_METRICS then
                        BL.vars.defaultScene = DEFAULT_SCENE_METRICS
                    else
                        BL.vars.defaultScene = DEFAULT_SCENE_HISTORY
                    end
                end
            end,
        },
        {
            type = "header",
            name = "Auto-show sweetroll",
        },
        {
            type = "checkbox",
            name = "History page",
            tooltip = "Automatically show the sweetroll MVP panel for the local team's MVP when viewing a saved match on the History page.",
            getFunc = function() return BL.vars ~= nil and BL.vars.autoShowHistorySweetroll == true end,
            setFunc = function(value)
                if BL.vars then BL.vars.autoShowHistorySweetroll = value == true end
                if BL.activePage == "History" and BL.selectedMatchId then
                    BL.RefreshDetails(BL.GetMatch(BL.selectedMatchId))
                end
            end,
        },
        {
            type = "checkbox",
            name = "End of match screen",
            tooltip = "Automatically show the sweetroll MVP panel for the local team's MVP on the end-of-match scoreboard overlay.",
            getFunc = function() return BL.vars ~= nil and BL.vars.autoShowEndMatchSweetroll == true end,
            setFunc = function(value)
                if BL.vars then BL.vars.autoShowEndMatchSweetroll = value == true end
                if BL.endMatchMatch then
                    BL.RefreshEndMatchScoreboard(BL.endMatchMatch)
                end
            end,
        },
        {
            type = "header",
            name = "Debug",
        },
        {
            type = "checkbox",
            name = "Show debug panel",
            tooltip = "Shows a small left-side panel for temporary testing values.",
            getFunc = function() return BL.vars ~= nil and BL.vars.debugPanel == true end,
            setFunc = function(value)
                if BL.vars then BL.vars.debugPanel = value == true end
                BL.UpdateDebugPanel()
            end,
        },
        {
            type = "header",
            name = "Data",
        },
        {
            type = "slider",
            name = "Max matches saved",

            min = 1000,
            max = 10000,
            step = 1000,
            getFunc = function() return BL.GetMaxMatchesSaved() end,
            setFunc = function(value)
                if BL.vars then BL.vars.maxMatchesSaved = value end
            end,
        },
        {
            type = "description",
            text = " ",
        },
        {
            type = "button",
            name = "Delete Match History",
            tooltip = "Deletes all unlocked Battleboard matches and clears deserter data. Locked matches are kept.",
            warning = "This cannot be undone.",
            func = function()
                BL.ConfirmDeleteAllEntries()
            end,
        },
    }

    LAM:RegisterOptionControls("BattleboardSettingsPanel", optionsData)
end

function BL.RegisterMainMenu()
    ZO_CreateStringId("SI_BATTLEBOARD_CATEGORY_MENU_TITLE", BL.displayName)
    ZO_CreateStringId("SI_BATTLEBOARD_HISTORY_MENU_TITLE", "History")
    ZO_CreateStringId("SI_BATTLEBOARD_METRICS_MENU_TITLE", "Metrics")
    ZO_CreateStringId("SI_BATTLEBOARD_OBSERVATORY_MENU_TITLE", "Observatory")

    local menuIcon = MENU_ICON

    local categoryData = {
        binding = "BATTLEBOARD_TOGGLE",
        categoryName = SI_BATTLEBOARD_CATEGORY_MENU_TITLE,
        normal = menuIcon,
        pressed = MENU_ICON_DOWN,
        highlight = MENU_ICON_OVER,
        callback = function()
            BL.Toggle()
        end,
    }
    BL.menuCategoryData = categoryData

    local fragment = ZO_HUDFadeSceneFragment:New(BattleboardXMLMain, DEFAULT_SCENE_TRANSITION_TIME, 0)
    fragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
            BL.HandleAddonSceneOpening()
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            BL.HandleAddonSceneClosed()
        end
    end)

    local function AddBattleboardScene(sceneName, page)
        -- Standard ESO right-panel menu scene. Page switching is represented as
        -- real scenes in one scene group, matching SuperStar's top-right tab model.
        local scene = ZO_Scene:New(sceneName, SCENE_MANAGER)
        scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
        scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
        scene:AddFragment(RIGHT_BG_FRAGMENT)

        -- Standard ESO menu title placement, matching addons such as SuperStar.
        scene:AddFragment(TITLE_FRAGMENT)
        local titleFragment = ZO_SetTitleFragment:New(SI_BATTLEBOARD_CATEGORY_MENU_TITLE)
        scene:AddFragment(titleFragment)

        scene:AddFragment(TREE_UNDERLAY_FRAGMENT)

        scene:AddFragment(fragment)
        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                BL.activePage = page
                if BL.window then
                    BL.SetActivePage(page)
                end
            end
        end)

        return scene
    end

    AddBattleboardScene("BattleboardHistory", "History")
    AddBattleboardScene("BattleboardMetrics", "Data")
    AddBattleboardScene("BattleboardObservatory", "Observatory")

    -- The shared fragment handles open/close lifecycle. The scene callbacks above
    -- only choose which Battleboard page the active scene represents.

    SCENE_MANAGER:AddSceneGroup("BattleboardSceneGroup", ZO_SceneGroup:New("BattleboardHistory", "BattleboardMetrics", "BattleboardObservatory"))
    BL.menuCategory = LMM:AddCategory(categoryData)
    local sceneData = {
        {
            categoryName = SI_BATTLEBOARD_HISTORY_MENU_TITLE,
            descriptor = "BattleboardHistory",
            normal = MATCH_HISTORY_ICON,
            pressed = MATCH_HISTORY_ICON_DOWN,
            highlight = MATCH_HISTORY_ICON_OVER,
        },
        {
            categoryName = SI_BATTLEBOARD_METRICS_MENU_TITLE,
            descriptor = "BattleboardMetrics",
            normal = STATS_ICON,
            pressed = STATS_ICON_DOWN,
            highlight = STATS_ICON_OVER,
        },
        {
            categoryName = SI_BATTLEBOARD_OBSERVATORY_MENU_TITLE,
            descriptor = "BattleboardObservatory",
            normal = OBSERVATORY_ICON,
            pressed = OBSERVATORY_ICON_DOWN,
            highlight = OBSERVATORY_ICON_OVER,
        },
    }
    BL.menuSceneData = sceneData
    LMM:AddSceneGroup(BL.menuCategory, "BattleboardSceneGroup", sceneData)
    LMM:AddMenuItem("BattleboardSceneGroup", categoryData)

    BL.usesScene = true
end

function BL.RegisterDialogs()
    ZO_Dialogs_RegisterCustomDialog("BATTLEBOARD_LOCKED_LIMIT", {
        title = { text = "Locked Match Limit Reached" },
        mainText = { text = string.format("You can only have %d locked matches. Unlock one before locking another.", MAX_LOCKED_MATCHES) },
        buttons = {
            [1] = { text = SI_DIALOG_CLOSE },
        },
    })

    ZO_Dialogs_RegisterCustomDialog("BATTLEBOARD_CONFIRM_DELETE_ALL", {
        title = { text = "Delete Match History?" },
        mainText = { text = "This deletes all unlocked saved matches and deserter entries. Locked matches are kept. This action cannot be undone. Proceed?" },
        buttons = {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = function()
                    BL.DeleteAllEntries()
                end,
            },
            [2] = { text = SI_DIALOG_CANCEL },
        },
    })
end
