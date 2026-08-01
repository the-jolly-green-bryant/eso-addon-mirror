-- ThankAHealer.lua
-- Coded by @Tevnar

-- Namespace declaration
TAH = {}

-- Constants
local FOO_BAR = 10
TAH.NAME = "ThankAHealer"
TAH.HEAL_ACTION_RESULTS = {
    ACTION_RESULT_HEAL,
    ACTION_RESULT_CRITICAL_HEAL,
    ACTION_RESULT_HOT_TICK,
    ACTION_RESULT_HOT_TICK_CRITICAL
}
TAH.OTHER_PLAYER_UNIT_TYPES = {COMBAT_UNIT_TYPE_GROUP, COMBAT_UNIT_TYPE_OTHER}
TAH.GROUP_PLAYER_TYPE = COMBAT_UNIT_TYPE_GROUP
TAH.DEFAULT_CHAT_CHANNEL_NAME = "/say"
TAH.MIN_TIME_BETWEEN_COMBATS_MS = 30 * 1000

-- Indexes should match with values in SCOPE_TEXT
TAH.ALL_HEALERS_IDX = 1
TAH.GROUP_HEALERS_IDX = 2
TAH.SCOPE_TEXT = {"All Healers", "Healers in Group Only"}

-- Indexes should match with values in TIME_PERIOD_TEXT and TIME_FRAME_TO_TEXT
TAH.FIGHT_IDX = 1
TAH.SESSION_IDX = 2
TAH.TIME_PERIOD_TEXT = {"Last Fight Only", "All Fights this Session"}
TAH.TIME_FRAME_TO_TEXT_MESSAGE = {"that fight", "for my entire session"}

TAH.SAVED_VARIABLES_TABLE = "ThankAHealer_Data"
TAH.SAVED_VARIABLES_VERSION = 1
TAH.SAVED_VARIABLES_DEFAULTS = {
    defaultNumToDisplay = 1,
    defaultChatChannelName = TAH.DEFAULT_CHAT_CHANNEL_NAME,
    defaultTimeIndex = TAH.FIGHT_IDX,
    defaultScopeIndex = TAH.ALL_HEALERS_IDX,
    showStartCombatMessage = true,
    showEndCombatMessage = true
}

-- Data Fields
TAH.lastCombatEnd_ms = -1000000
-- healer tables is a 2-dim array: healerTables[<scope_idx>][<time_idx]
TAH.healerTables = {{{}, {}}, {{}, {}}}
TAH.savedSettings = {}

TAH.debug = false
TAH.test = false

-- Utility Functions
local nextEventHandleNr = 0
local function RegisterCombatResultEvent(result, callback)
    local eventHandleName = TAH.NAME .. tostring(nextEventHandleNr) -- This is needed in order to generate a new unique eventNameSpace for each filterType added!
    nextEventHandleNr = nextEventHandleNr + 1
    EVENT_MANAGER:RegisterForEvent(eventHandleName, EVENT_COMBAT_EVENT, callback)
    EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result)
    return eventHandleName
end

local function Contains(list, x)
    for _, v in pairs(list) do
        if v == x then
            return true
        end
    end
    return false
end

local function CleanName(name)
    return name:gsub("%^.*", "")
end

-- Fake data for testing/debugging purposes
local function PopulateFakeData()
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX]["WillHealForWhiskey^M"] = 12385
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX]["SirHealsALittle^M"] = 2361
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX]["TammyTemplar"] = 19120

    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX]["WillHealForWhiskey^M"] = 69475
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX]["SirHealsALittle^M"] = 7543
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX]["TammyTemplar"] = 102768
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX]["BosmerHealer"] = 54100

    for k, v in pairs(TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX]) do
        TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.FIGHT_IDX][k] = v
    end
    TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.FIGHT_IDX]["SoloHealer"] = 21302

    for k, v in pairs(TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX]) do
        TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.SESSION_IDX][k] = v
    end
    TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.SESSION_IDX]["SoloHealer"] = 33089
end

local function ClearGroupTables()
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX] = {}
    TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX] = {}
end

local function AddHeal(healTable, healSource, healValue)
    healTable[healSource] = (healTable[healSource] or 0) + healValue
end

-- Returns a tuple of (array of the healers in healTable sorted by heal amount descending, total number of healers
function TAH.GetSortedHealers(healTable)
    local sortTable = {}
    local numberOfHealers = 0
    for k, v in pairs(healTable) do
        table.insert(sortTable, k)
        numberOfHealers = numberOfHealers + 1
    end

    table.sort(
        sortTable,
        function(a, b)
            return (healTable[a] > healTable[b])
        end
    )

    return sortTable, numberOfHealers
end

--
-- Initialization Code
--

function TAH:Initialize()
    self.inCombat = IsUnitInCombat("player")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

    for _, v in pairs(self.HEAL_ACTION_RESULTS) do
        RegisterCombatResultEvent(v, self.OnCombatEvent)
    end

    self.savedSettings =
        ZO_SavedVars:NewCharacterIdSettings("ThankAHealer_Data", 1, nil, TAH.SAVED_VARIABLES_DEFAULTS, GetWorldName())

    self.RegisterMenuSettings();
end

function TAH.OnAddOnLoaded(event, addonName)
    if addonName == TAH.NAME then
        TAH:Initialize()
    end
end

-- Register for the loaded event
EVENT_MANAGER:RegisterForEvent(TAH.NAME, EVENT_ADD_ON_LOADED, TAH.OnAddOnLoaded)

--
-- Core Event Handling Code
--
function TAH.OnPlayerCombatState(event, inCombat)
    if inCombat ~= TAH.inCombat then
        TAH.inCombat = inCombat

        if inCombat then
            local timeSinceLastCombat = GetGameTimeMilliseconds() - TAH.lastCombatEnd_ms
            if (timeSinceLastCombat < TAH.MIN_TIME_BETWEEN_COMBATS_MS) then
                if (TAH.savedSettings.showStartCombatMessage or TAH.debug) then
                    CHAT_SYSTEM:AddMessage(
                        "TAH: Re-entering combat, keeping fight data (only out of combat for " ..
                            string.format("%.1f", timeSinceLastCombat / 1000.0) .. " seconds)."
                    )
                end
            else
                if (TAH.savedSettings.showStartCombatMessage or TAH.debug) then
                    CHAT_SYSTEM:AddMessage("TAH: Entering new combat, resetting fight data")
                end
                TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX] = {}
                TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.FIGHT_IDX] = {}
            end
        else
            TAH.lastCombatEnd_ms = GetGameTimeMilliseconds()

            if (TAH.savedSettings.showEndCombatMessage or TAH.debug) then
                if (TAH.test) then
                    PopulateFakeData()
                end

                local combatEndHealTable = TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.FIGHT_IDX]
                local sortTable, numHealers = TAH.GetSortedHealers(combatEndHealTable)

                if (numHealers > 0) then
                    -- Output all healers from the last fight
                    local outOfCombatMsg = "TAH: Exiting combat, " .. numHealers .. " healer(s):"
                    for i, healer in ipairs(sortTable) do
                      if (i > 1) then
                           outOfCombatMsg = outOfCombatMsg .. ","
                        end
                        outOfCombatMsg =
                            outOfCombatMsg .. " " .. CleanName(healer) .. "(" .. combatEndHealTable[healer] .. ")"
                    end
                    outOfCombatMsg = outOfCombatMsg .. "."
                    CHAT_SYSTEM:AddMessage(outOfCombatMsg)
                else
                    CHAT_SYSTEM:AddMessage("TAH: Exiting combat, no healers")
                end
            end
        end
    end
end

function TAH.OnCombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId)
    -- Ignore errors
    if (isError) then
        return
    end

    -- Bypass 0 value heals
    if (hitValue == 0) then
        return
    end

    -- Ignore any heal not coming from another person
    if (not (Contains(TAH.OTHER_PLAYER_UNIT_TYPES, sourceType))) then
        return
    end

    if TAH.debug then
        d(abilityName .. " Heal for " .. hitValue .. ", Source " .. CleanName(sourceName))
    end

    AddHeal(TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.FIGHT_IDX], sourceName, hitValue)
    AddHeal(TAH.healerTables[TAH.ALL_HEALERS_IDX][TAH.SESSION_IDX], sourceName, hitValue)

    if (sourceType == TAH.GROUP_PLAYER_TYPE) then
        AddHeal(TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.FIGHT_IDX], sourceName, hitValue)
        AddHeal(TAH.healerTables[TAH.GROUP_HEALERS_IDX][TAH.SESSION_IDX], sourceName, hitValue)
    end
end

function TAH.ShowThankYouMessage(healTable, channel, showQty, timeFrameString)
    if TAH.test then
        PopulateFakeData()
    end

    local sortTable, totalNumberOfHealers = TAH.GetSortedHealers(healTable)

    showQty = math.min(showQty, totalNumberOfHealers)

    -- Format output message
    -- TODO: Abstract out specification + formating of output string
    local message = ""
    if (showQty == 1) then
        message =
            CleanName(sortTable[1]) ..
            ", you healed me for " .. healTable[sortTable[1]] .. " " .. timeFrameString .. ". Thank you!"
    elseif (showQty > 1) then
        message = "My top " .. showQty .. " healers " .. timeFrameString .. ":"
        for i = 1, showQty do
            if (i > 1 and (i ~= showQty or i ~= 2)) then
                message = message .. ","
            end
            if (i == showQty) then
                message = message .. " and"
            end

            message = message .. " " .. CleanName(sortTable[i]) .. " for " .. healTable[sortTable[i]]
        end
        message = message .. ". Thank you all!!"
    end

    -- local channel = CHAT_CHANNEL_PARTY
    if message ~= "" then
        CHAT_SYSTEM:StartTextEntry(message, channel, nil)
    else
        d("TAH: No healers to thank, sorry!")
    end
end

--
-- Functions to handle command parsing
--
local function ShowHelpMessage()
    local helpMessages = {
        "/tah takes the following options:",
        "   <number> - thanks the best <number> of healers",
        "   <chat channel> - sends chat to the given channel (ie /say).",
        "   fight - shows heals for the last fight only ",
        "   session - shows heals for your entire session",
        "   all - shows heals from all sources",
        "   group - shows heals from your group members only",
        '   g - shows heals from your group, to the /group chat. (Shortcut for "group /group") ',
        "   help - shows this message",
        "The /tahsettings command allows you to view and/or edit the default values for these options"
    }

    for _, v in ipairs(helpMessages) do
        CHAT_SYSTEM:AddMessage(v)
    end
end

local CHAT_CHANNEL_MAP = {
    ["/s"] = CHAT_CHANNEL_SAY,
    ["/say"] = CHAT_CHANNEL_SAY,
    ["/y"] = CHAT_CHANNEL_YELL,
    ["/yell"] = CHAT_CHANNEL_YELL,
    ["/p"] = CHAT_CHANNEL_PARTY,
    ["/party"] = CHAT_CHANNEL_PARTY,
    ["/g"] = CHAT_CHANNEL_PARTY,
    ["/group"] = CHAT_CHANNEL_PARTY,
    ["/z"] = CHAT_CHANNEL_ZONE,
    ["/zone"] = CHAT_CHANNEL_ZONE,
    ["/g1"] = CHAT_CHANNEL_GUILD_1,
    ["/guild1"] = CHAT_CHANNEL_GUILD_1,
    ["/g2"] = CHAT_CHANNEL_GUILD_2,
    ["/guild2"] = CHAT_CHANNEL_GUILD_2,
    ["/g3"] = CHAT_CHANNEL_GUILD_3,
    ["/guild3"] = CHAT_CHANNEL_GUILD_3,
    ["/g4"] = CHAT_CHANNEL_GUILD_4,
    ["/guild4"] = CHAT_CHANNEL_GUILD_4,
    ["/g5"] = CHAT_CHANNEL_GUILD_5,
    ["/guild5"] = CHAT_CHANNEL_GUILD_5,
    ["/o1"] = CHAT_CHANNEL_OFFICER_1,
    ["/officer1"] = CHAT_CHANNEL_OFFICER_1,
    ["/o2"] = CHAT_CHANNEL_OFFICER_2,
    ["/officer2"] = CHAT_CHANNEL_OFFICER_2,
    ["/o3"] = CHAT_CHANNEL_OFFICER_3,
    ["/officer3"] = CHAT_CHANNEL_OFFICER_3,
    ["/o4"] = CHAT_CHANNEL_OFFICER_4,
    ["/officer4"] = CHAT_CHANNEL_OFFICER_4,
    ["/o5"] = CHAT_CHANNEL_OFFICER_5,
    ["/officer5"] = CHAT_CHANNEL_OFFICER_5
}

SLASH_COMMANDS["/tah"] = function(args)
    local scopeIdx = TAH.savedSettings.defaultScopeIndex
    local timeFrameIdx = TAH.savedSettings.defaultTimeIndex
    local showQty = TAH.savedSettings.defaultNumToDisplay
    local chatChannel = CHAT_CHANNEL_MAP[TAH.savedSettings.defaultChatChannelName] or TAH.DEFAULT_CHAT_CHANNEL_NAME

    for arg in string.gmatch(args, "%S+") do
        local argAsNumber = tonumber(arg)
        if (argAsNumber and argAsNumber > 0) then
            showQty = argAsNumber
        elseif CHAT_CHANNEL_MAP[arg] then
            chatChannel = CHAT_CHANNEL_MAP[arg]
        elseif (arg == "session") then
            timeFrameIdx = TAH.SESSION_IDX
        elseif (arg == "fight") then
            timeFrameIdx = TAH.FIGHT_IDX
        elseif (arg == "all") then
            scopeIdx = TAH.ALL_HEALERS_IDX
        elseif (arg == "group") then
            scopeIdx = TAH.GROUP_HEALERS_IDX
        elseif (arg == "g") then
            scopeIdx = TAH.GROUP_HEALERS_IDX
            chatChannel = CHAT_CHANNEL_PARTY
        elseif (arg == "help") then
            ShowHelpMessage()
            return
        elseif (arg == "debug") then
            TAH.debug = not TAH.debug
            d("Toggling debug to " .. tostring(TAH.debug))
            return
        elseif (arg == "test") then
            TAH.test = not TAH.test
            d("Toggling test to " .. tostring(TAH.test))
            if (not TAH.test) then
                ClearGroupTables()
            end
            return
        end
    end

    TAH.ShowThankYouMessage(
        TAH.healerTables[scopeIdx][timeFrameIdx],
        chatChannel,
        showQty,
        TAH.TIME_FRAME_TO_TEXT_MESSAGE[timeFrameIdx]
    )
end

--
-- LibAddonMenu2 Code
--
function TAH.RegisterMenuSettings()
    local PANEL_NAME = "ThankAHealerPanel"
    local MAX_HEALER_NUM_DISPLAY = 10

    local chatChannels = {
        "/say", "/group", "/yell", "/zone", 
        "/guild1", "/guild2", "/guild3", "/guild4", "/guild5",
        "/officer1", "/officer2", "/officer3", "/officer4", "/officer5"
    }

    local panelData = {
        type = "panel",
        name = "Thank A Healer",
        author = "@Tevnar",
        slashCommand = "/tahsettings"
    }

    local optionsData = {
        {   
            type = "header",
            name = "Default values for /tah commands:"
        },
        {
            type = "slider",
            name = "Default number of healers to thank:",
            tooltip = "The default number of healers to thank, if no number is specified in the /tah command",
            min = 1,
            max = MAX_HEALER_NUM_DISPLAY,
            getFunc = function()
                --return max(min(TAH.savedSettings.defaultNumToDisplay, MAX_HEALER_NUM_DISPLAY), 1)
                return 1
            end,
            setFunc = function(val)
                TAH.savedSettings.defaultNumToDisplay = val
            end
        },
        {
            type = "dropdown",
            name = "Default chat channel:",
            tooltip = "The default chat channel to send your message to, if none is specified in the /tah command",
            choices = chatChannels,
            getFunc = function() return TAH.savedSettings.defaultChatChannelName end,
            setFunc = function(val) TAH.savedSettings.defaultChatChannelName = val end
        },
        {
            type = "dropdown",
            name = "Default healers to include:",
            tooltip = "The default choice between all healers / healers in your group only, if none is specified in the /tah command",
            choices = TAH.SCOPE_TEXT,
            getFunc = function () return TAH.SCOPE_TEXT[TAH.savedSettings.defaultScopeIndex] end,
            setFunc = function (val) 
                if (val == TAH.SCOPE_TEXT[TAH.ALL_HEALERS_IDX]) then 
                    TAH.savedSettings.defaultScopeIndex = TAH.ALL_HEALERS_IDX
                else
                    TAH.savedSettings.defaultScopeIndex = TAH.GROUP_HEALERS_IDX
                end
            end
        },
        {
            type = "dropdown",
            name = "Default time covered:",
            tooltip = "The default choice between heals from the last fight only / heals for your entire session, if none is specified in the /tah command",
            choices = TAH.TIME_PERIOD_TEXT,
            getFunc = function () return TAH.TIME_PERIOD_TEXT[TAH.savedSettings.defaultTimeIndex] end,
            setFunc = function (val) 
                if (val == TAH.TIME_PERIOD_TEXT[TAH.FIGHT_IDX]) then 
                    TAH.savedSettings.defaultTimeIndex = TAH.FIGHT_IDX
                else 
                    TAH.savedSettings.defaultTimeIndex = TAH.SESSION_IDX
                end
            end
        },
        {
            type = "header",
            name = "Status message settings:"
        },
        {
            type = "checkbox",
            name = "Show start of combat messages",
            tooltip = "Controls if Thank A Healer shows info messages when you enter or re-enter combat",
            getFunc = function() return TAH.savedSettings.showStartCombatMessage end,
            setFunc = function(val) TAH.savedSettings.showStartCombatMessage = val end
        },
        {
            type = "checkbox",
            name = "Show end of combat messages",
            tooltip = "Controls if Thank A Healer shows info messages when you exit combat",
            getFunc = function() return TAH.savedSettings.showEndCombatMessage end,
            setFunc = function(val) TAH.savedSettings.showEndCombatMessage = val end
        }
    }

    LibAddonMenu2:RegisterAddonPanel(PANEL_NAME, panelData)
    LibAddonMenu2:RegisterOptionControls(PANEL_NAME, optionsData)
end
