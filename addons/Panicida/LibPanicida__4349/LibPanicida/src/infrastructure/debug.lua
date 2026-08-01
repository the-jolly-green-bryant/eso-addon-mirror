-- Localized Globals
local EVENT_MANAGER = EVENT_MANAGER
local GuiRoot = GuiRoot
local zo_callLater = zo_callLater
local GetTimeStamp = GetTimeStamp
local Achievement = Achievement
local GetNumFastTravelNodes = GetNumFastTravelNodes
local GetFastTravelNodeInfo = GetFastTravelNodeInfo
local ITEM_SET_COLLECTIONS_DATA_MANAGER = ITEM_SET_COLLECTIONS_DATA_MANAGER
local GetAchievementInfo = GetAchievementInfo
local ZO_PreHookHandler = ZO_PreHookHandler
local ZO_PreHook = ZO_PreHook
local SLASH_COMMANDS = SLASH_COMMANDS
local EVENT_QUEST_REMOVED = EVENT_QUEST_REMOVED
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local string_format = string.format
local tinsert = table.insert
local d = d

-- Constants
local debugStates = {
    questLogging = false,
    setIdLogging = false,
    achievementLogging = false,
}

-- Store original functions for restoration
local originalAchievementToggle = nil

-- Module Declaration
local Debug = {}

-- Private Functions

--- Safely gets a control by name from global namespace.
--- @param name string The control name to look up
--- @return any|nil The control or nil if not found
local function getControl(name)
    return name and _G[name] or nil
end

-- Public Functions

--- Logs an object to chat after a delay.
--- @param obj any The object to log
--- @param delay? number Optional delay in milliseconds (defaults to 0)
function Debug.LogLater(obj, delay)
    zo_callLater(function() d(obj) end, delay or 0)
end

--- Logs when any top-level control is shown.
--- WARNING: Very performance intensive - use only for debugging!
function Debug.EnableControlShownLogging()
    local numChildren = GuiRoot:GetNumChildren()

    for i = 1, numChildren do
        local child = GuiRoot:GetChild(i)
        if child then
            local childName = child:GetName()
            local control = getControl(childName)

            if control then
                ZO_PreHookHandler(control, "OnEffectivelyShown", function()
                    Debug.LogLater(string_format("%d %s shown", GetTimeStamp(), childName))
                end)
            end
        end
    end

    Debug.LogLater("Control shown logging enabled")
end

--- Logs all children of a control when it is shown.
--- @param parent any The control to inspect
function Debug.LogControlChildren(parent)
    if not parent then return end

    local function logChildren()
        local parentName = parent:GetName()
        local numChildren = parent:GetNumChildren()

        Debug.LogLater(string_format("%s children: %d", parentName, numChildren))

        for i = 1, numChildren do
            local child = parent:GetChild(i)
            if child then
                local childName = child:GetName()
                if childName then
                    Debug.LogLater(string_format(" -> %s", childName))
                end
            end
        end
    end

    ZO_PreHookHandler(parent, "OnEffectivelyShown", logChildren)
end

--- Logs all children text of a control when it is shown.
--- @param parent any The control to inspect
function Debug.LogControlChildrenText(parent)
    if not parent then return end

    local function logChildrenText()
        local parentName = parent:GetName()
        local numChildren = parent:GetNumChildren()

        Debug.LogLater(string_format("%s children: %d", parentName, numChildren))

        for i = 1, numChildren do
            local child = parent:GetChild(i)
            if child then
                local childName = child:GetName()
                local control = getControl(childName)

                if control then
                    if control.GetText then
                        local text = control:GetText() or "nil"
                        Debug.LogLater(string_format("-> %s", text))
                    else
                        Debug.LogLater("-> (no GetText method)")
                    end
                end
            end
        end
    end

    ZO_PreHookHandler(parent, "OnEffectivelyShown", logChildrenText)
end

--- Logs all key-value pairs in a table.
--- @param tbl table The table to log
--- @param name string Optional name for the table
function Debug.LogTable(tbl, name)
    if not tbl then
        Debug.LogLater("LogTable: table is nil")
        return
    end

    if name then
        Debug.LogLater(string_format("=== Table: %s ===", name))
    end

    for key, value in pairs(tbl) do
        Debug.LogLater(string_format("%s: %s", tostring(key), tostring(value)))
    end
end

--- Logs all fast travel node IDs and names.
function Debug.LogFastTravelNodes()
    Debug.LogLater("=== Fast Travel Nodes ===")

    local numNodes = GetNumFastTravelNodes()
    for id = 1, numNodes do
        local _, name = GetFastTravelNodeInfo(id)
        if name and name ~= "" then
            Debug.LogLater(string_format("%d - %s", id, name))
        end
    end

    Debug.LogLater(string_format("Total nodes: %d", numNodes))
end

--- Enables quest completion/removal logging.
--- @return boolean True if enabled, false if already enabled
function Debug.EnableQuestLogging()
    if debugStates.questLogging then
        Debug.LogLater("Quest logging already enabled")
        return false
    end

    Debug.LogLater("Quest logging enabled - complete quests to log IDs")

    local eventName = "LibPanicida_QuestRemoved_Debug"

    local function logQuest(_, isCompleted, _, questName, _, _, questId)
        if questName and questId then
            local status = isCompleted and "completed" or "removed"
            Debug.LogLater(string_format("%s (%s) = %d", questName, status, questId))
        end
    end

    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_QUEST_REMOVED, logQuest)
    debugStates.questLogging = true
    return true
end

--- Disables quest completion/removal logging.
--- @return boolean True if disabled, false if already disabled
function Debug.DisableQuestLogging()
    if not debugStates.questLogging then
        Debug.LogLater("Quest logging already disabled")
        return false
    end

    EVENT_MANAGER:UnregisterForEvent("LibPanicida_QuestRemoved_Debug", EVENT_QUEST_REMOVED)
    debugStates.questLogging = false
    Debug.LogLater("Quest logging disabled")
    return true
end

--- Enables set ID logging when clicking collection set headers.
--- @return boolean True if enabled, false if already enabled
function Debug.EnableSetIdLogging()
    if debugStates.setIdLogging then
        Debug.LogLater("Set ID logging already enabled")
        return false
    end

    Debug.LogLater("Set ID logging enabled - right-click collection set headers")

    local function logSetId(control)
        if not control or not control.dataEntry then return end

        local headerData = control.dataEntry.data.header
        if not headerData then return end

        local setId = headerData:GetId()
        if not setId then return end

        local setCollectionData = ITEM_SET_COLLECTIONS_DATA_MANAGER:GetItemSetCollectionData(setId)
        if setCollectionData then
            local setName = setCollectionData:GetRawName()
            Debug.LogLater(string_format("%s = %d", setName, setId))
        end
    end

    ZO_PreHook("ZO_ItemSetsBook_Entry_Header_Keyboard_OnMouseUp", logSetId)
    debugStates.setIdLogging = true
    return true
end

--- Disables set ID logging (requires UI reload).
--- @return boolean Always returns true
function Debug.DisableSetIdLogging()
    if not debugStates.setIdLogging then
        Debug.LogLater("Set ID logging already disabled")
        return false
    end

    Debug.LogLater("Set ID logging can not be disabled. Reload UI instead.")
    return true
end

--- Enables achievement ID logging when clicking achievements.
--- @return boolean True if enabled, false if already enabled or not available
function Debug.EnableAchievementIdLogging()
    if debugStates.achievementLogging then
        Debug.LogLater("Achievement ID logging already enabled")
        return false
    end

    if not Achievement or not Achievement.ToggleCollapse then
        Debug.LogLater("Error: Achievement.ToggleCollapse not found")
        return false
    end

    Debug.LogLater("Achievement ID logging enabled - click achievements to log")

    -- Store original if not already stored
    if not originalAchievementToggle then
        originalAchievementToggle = Achievement.ToggleCollapse
    end

    Achievement.ToggleCollapse = function(self, button)
        originalAchievementToggle(self, button)

        if self.achievementId then
            local name = GetAchievementInfo(self.achievementId)
            Debug.LogLater(string_format("%s = %d", name or "Unknown", self.achievementId))
        end
    end

    debugStates.achievementLogging = true
    return true
end

--- Disables achievement ID logging.
--- @return boolean True if disabled, false if already disabled
function Debug.DisableAchievementIdLogging()
    if not debugStates.achievementLogging then
        Debug.LogLater("Achievement ID logging already disabled")
        return false
    end

    if originalAchievementToggle and Achievement then
        Achievement.ToggleCollapse = originalAchievementToggle
    end

    debugStates.achievementLogging = false
    Debug.LogLater("Achievement ID logging disabled")
    return true
end

--- Toggles achievement ID logging on or off.
--- @return boolean Result of enable or disable operation
function Debug.ToggleAchievementIdLogging()
    if debugStates.achievementLogging then
        return Debug.DisableAchievementIdLogging()
    else
        return Debug.EnableAchievementIdLogging()
    end
end

--- Gets the current state of all debug features.
--- @return table Table with feature states
function Debug.GetStatus()
    return {
        questLogging = debugStates.questLogging,
        setIdLogging = debugStates.setIdLogging,
        achievementLogging = debugStates.achievementLogging,
    }
end

--- Checks if any debug feature is currently enabled.
--- @return boolean True if any feature is enabled
function Debug.IsAnyEnabled()
    for _, enabled in pairs(debugStates) do
        if enabled then return true end
    end
    return false
end

--- Enables all debug features.
function Debug.EnableAll()
    Debug.EnableQuestLogging()
    Debug.EnableSetIdLogging()
    Debug.EnableAchievementIdLogging()
    Debug.LogLater("All debug features enabled")
end

--- Disables all debug features.
function Debug.DisableAll()
    Debug.DisableQuestLogging()
    Debug.DisableSetIdLogging()
    Debug.DisableAchievementIdLogging()
    Debug.LogLater("All debug features disabled")
end

--- Shows current status of all debug features.
function Debug.ShowStatus()
    Debug.LogLater("=== LibPanicida Debug Status ===")
    local status = Debug.GetStatus()

    local features = {
        { name = "Quest Logging",       key = "questLogging" },
        { name = "Set ID Logging",      key = "setIdLogging" },
        { name = "Achievement Logging", key = "achievementLogging" },
    }

    for _, feature in ipairs(features) do
        local enabled = status[feature.key]
        local state = enabled and "|c00FF00ON|r" or "|cFF0000OFF|r"
        Debug.LogLater(string_format("  %s: %s", feature.name, state))
    end
end

--- Shows help message for slash commands.
function Debug.ShowHelp()
    Debug.LogLater("=== LibPanicida Debug Commands ===")
    Debug.LogLater("/lpd - Show current debug status")
    Debug.LogLater("/lpd help - Show this help")
    Debug.LogLater("/lpd status - Show current debug status")
    Debug.LogLater("")
    Debug.LogLater("Explicit control:")
    Debug.LogLater("  /lpd <feature> on - Enable feature")
    Debug.LogLater("  /lpd <feature> off - Disable feature")
    Debug.LogLater("")
    Debug.LogLater("Utility commands:")
    Debug.LogLater("  /lpd nodes - Log all fast travel nodes")
    Debug.LogLater("  /lpd controls - Enable control shown logging")
    Debug.LogLater("")
    Debug.LogLater("Aliases: quest/quests, set/sets, achieve/achievements")
end

--- Handles enable command for a specific feature.
--- @param feature string The feature to enable
function Debug.HandleEnableCommand(feature)
    if not feature or feature == "all" then
        Debug.EnableAll()
    elseif feature == "quests" or feature == "quest" then
        Debug.EnableQuestLogging()
    elseif feature == "sets" or feature == "set" then
        Debug.EnableSetIdLogging()
    elseif feature == "achievements" or feature == "achieve" or feature == "achievement" then
        Debug.EnableAchievementIdLogging()
    else
        Debug.LogLater("Unknown feature: " .. feature)
        Debug.LogLater("Type '/lpd help' for available features")
    end
end

--- Handles disable command for a specific feature.
--- @param feature string The feature to disable
function Debug.HandleDisableCommand(feature)
    if not feature or feature == "all" then
        Debug.DisableAll()
    elseif feature == "quests" or feature == "quest" then
        Debug.DisableQuestLogging()
    elseif feature == "sets" or feature == "set" then
        Debug.DisableSetIdLogging()
    elseif feature == "achievements" or feature == "achieve" or feature == "achievement" then
        Debug.DisableAchievementIdLogging()
    else
        Debug.LogLater("Unknown feature: " .. feature)
        Debug.LogLater("Type '/lpd help' for available features")
    end
end

--- Main slash command handler for /lpd.
--- @param args string Command arguments
function Debug.HandleSlashCommand(args)
    -- Trim and convert to lowercase
    args = args:gsub("^%s*(.-)%s*$", "%1"):lower()

    -- Split into parts
    local parts = {}
    for word in args:gmatch("%S+") do
        tinsert(parts, word)
    end

    local feature = parts[1]
    local action = parts[2]

    -- No arguments - show status
    if not feature or feature == "" then
        Debug.ShowStatus()
        return
    end

    -- Help command
    if feature == "help" or feature == "?" then
        Debug.ShowHelp()
        return
    end

    -- Status command
    if feature == "status" or feature == "list" then
        Debug.ShowStatus()
        return
    end

    -- Utility commands (no on/off)
    if feature == "nodes" or feature == "node" then
        Debug.LogFastTravelNodes()
        return
    end

    if feature == "controls" or feature == "control" then
        Debug.EnableControlShownLogging()
        return
    end

    -- Feature toggle commands
    local validFeatures = {
        quests = true,
        quest = true,
        sets = true,
        set = true,
        achievements = true,
        achieve = true,
        achievement = true,
        all = true,
    }

    if validFeatures[feature] then
        if not action then
            -- No action specified - enable
            Debug.HandleEnableCommand(feature)
        elseif action == "on" or action == "enable" then
            Debug.HandleEnableCommand(feature)
        elseif action == "off" or action == "disable" then
            Debug.HandleDisableCommand(feature)
        else
            Debug.LogLater("Unknown action: " .. action)
            Debug.LogLater("Use: on, off, or no action to on")
        end
    else
        Debug.LogLater("Unknown command: " .. feature)
        Debug.LogLater("Type '/lpd help' for available commands")
    end
end

-- Module Registration
SLASH_COMMANDS["/lpd"] = function(args)
    Debug.HandleSlashCommand(args)
end

LibPanicida.Debug = Debug
