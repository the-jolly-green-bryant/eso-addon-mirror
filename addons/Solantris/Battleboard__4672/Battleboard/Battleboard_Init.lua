-- Battleboard_Init.lua  (addon bootstrap and load-time wiring)
-- Part of Battleboard. Loaded after feature modules so Initialize can call their methods.

local BL = Battleboard
local _x = BL.__constants

local ALL_CHARACTERS_KEY = _x.ALL_CHARACTERS_KEY
local DEFAULT_SCENE_HISTORY = _x.DEFAULT_SCENE_HISTORY

function BL.Initialize()
    -- Keybind display name. Bind the key in Controls > Keybindings > "Battleboard".
    if SI_BINDING_NAME_BATTLEBOARD_TOGGLE == nil then
        ZO_CreateStringId("SI_BINDING_NAME_BATTLEBOARD_TOGGLE", "Battleboard: Toggle Window")
    end
    local defaults = { matches = {}, characters = {}, deserterEvents = {}, maxMatchesSaved = 1000, replaceScoreboard = false, showEndMatchScoreboard = true, autoShowHistorySweetroll = false, autoShowEndMatchSweetroll = false, defaultScene = DEFAULT_SCENE_HISTORY, debugPanel = false }
    BL.vars = ZO_SavedVars:NewAccountWide(BL.savedVarsName, BL.version, nil, defaults)
    BL.NormalizeSavedVariables(defaults)
    BL.matches = BL.vars.matches
    BL.PrimeDeserterCooldownTracking()

    -- Bug #2 fix: build the O(1) match-id lookup index on first load so GetMatch
    -- is fast from the very first interaction (before any save/delete triggers a rebuild).
    BL.RebuildMatchIndex()
    if #(BL.matches or {}) > 0 then
        BL.RefreshAccountCharacters()
    end
    BL.selectedCharacterKey = ALL_CHARACTERS_KEY
    BL.BuildDebugPanel()
    BL.UpdateDebugPanel()
    BL.BuildUI()
    BL.RegisterMainMenu()
    BL.RegisterSettings()
    BL.RegisterDialogs()

    SecurePostHook(Battleground_Scoreboard_Player_Row, "UpdateRow", function(row)
        if row and row.data and row.data.entryIndex then
            BL.rowDataCache[row.data.entryIndex] = row.data
        end
    end)
    SecurePostHook(Battleground_Scoreboard_Player_Row, "SetupOnAcquire", function(rowObject, panel, poolKey, data)
        if data and data.entryIndex then
            BL.rowDataCache[data.entryIndex] = data
        end
    end)

    -- /bb opens the addon menu. "/bb save" still triggers a manual save.
    SLASH_COMMANDS["/bb"] = function(command)
        command = string.lower(tostring(command or ""))
        if command == "save" then
            BL.SaveCurrentScoreboard("manual")
        elseif command == "debug" then
            if BL.vars then
                BL.vars.debugPanel = not BL.vars.debugPanel
                BL.UpdateDebugPanel()
                d("|cFFD700Battleboard|r debug panel " .. (BL.vars.debugPanel and "on." or "off."))
            end
        else
            BL.Toggle()
        end
    end
    -- /bbs toggles the latest saved match in the end-match scoreboard overlay.
    SLASH_COMMANDS["/bbs"] = function()
        BL.ToggleLatestEndMatchScoreboard()
    end

    EVENT_MANAGER:RegisterForEvent(BL.name, EVENT_PLAYER_ACTIVATED, function() BL.OnPlayerActivated() end)

    BL.RegisterBattlegroundAutoSave()

    -- Initialise chat-link sharing (Battleboard_Share.lua).
    BL.InitShare()
end

function BL.OnAddOnLoaded(event, addonName)
    if addonName ~= BL.name then return end
    EVENT_MANAGER:UnregisterForEvent(BL.name, EVENT_ADD_ON_LOADED)
    BL.Initialize()
end

EVENT_MANAGER:RegisterForEvent(BL.name, EVENT_ADD_ON_LOADED, BL.OnAddOnLoaded)
