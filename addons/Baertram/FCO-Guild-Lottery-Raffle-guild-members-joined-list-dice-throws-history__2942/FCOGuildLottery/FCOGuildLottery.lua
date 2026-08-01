if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonVars = FCOGuildLottery.addonVars
local addonNamePre = FCOGuildLottery.addonNamePre
local addonName = addonVars.addonName

--Debug messages
local df    = FCOGuildLottery.df
local dfa   = FCOGuildLottery.dfa
local dfe   = FCOGuildLottery.dfe
local dfv   = FCOGuildLottery.dfv
local dfw   = FCOGuildLottery.dfw

local logger = FCOGuildLottery.logger
local checkForLibHistoireReady = FCOGuildLottery.CheckForLibHistoireReady

local em = EVENT_MANAGER

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--EVENTS

local function checkForHistyIsInitialized(isInitialCall)
    local loopsDone = 0
    local uniqueName = addonName .. "_IsHistyReady"
    local function updateCheck()
        loopsDone = loopsDone + 1
        if loopsDone >= 100 then
            em:UnregisterForUpdate(uniqueName)
            dfe(addonNamePre .. "!!!!! \'LibHistoire\' was never initialized properly !!!!!")
        end
        if checkForLibHistoireReady() == true then
            em:UnregisterForUpdate(uniqueName)
            df( ">>>>>>>>>> \'LibHistoire\' was initialized properly >>>>>>>>>>")
            --Get the default sales history time range of all guilds which own a guild store
            --todo 20240422 Enable again after Member joined history processor was changed to LibHistoire API 2.0
            --FCOGuildLottery.GetDefaultSalesHistoryData()

            --Get the default guild member history time range of all guilds
            --todo 20240422 Enable again after Member joined history processor was changed to LibHistoire API 2.0
            --FCOGuildLottery.GetDefaultMemberHistoryData()
        end
    end
    em:UnregisterForUpdate(uniqueName)
    em:RegisterForUpdate(uniqueName, 50, updateCheck)
end

local function buildGuildsData()
    FCOGuildLottery.guildsData = FCOGuildLottery.buildGuildsDropEntries()
end

--Player activated function
local function eventPlayerActivated(eventId, isInitialCall)
    df( "EVENT_PLAYER_ACTIVATED - initial: %s", tostring(isInitialCall))

    checkForHistyIsInitialized(isInitialCall)

    FCOGuildLottery.playerActivatedDone = true
end

local function eventGuildMember(eventId, guildId, displayName)
    --GuildId is the currently selected one at the UI?
    if not FCOGuildLottery.UI or FCOGuildLottery.currentlyUsedDiceRollGuildId == nil or
            guildId ~= FCOGuildLottery.currentlyUsedDiceRollGuildId then
        return
    end
    local guildIndex = FCOGuildLottery.GetGuildIndexById(guildId)
    if not FCOGuildLottery.IsGuildIndexValid(guildIndex) then return end
    --UI is created and shown?
    local isWindowAlreadyShown, _ = FCOGuildLottery.UI.isUICreatedAndShown()
    if not isWindowAlreadyShown then return end
    FCOGuildLottery.UI.updateGuildDiceSidesEditBox(guildIndex)
end

local function eventGuildJoinedOrLeft(eventId, guildServerId, characterName, guildId)
    --Update the guild dropdown box entry base in the addon data
    buildGuildsData()
end

local function addonLoaded(eventName, addon)
    if addon ~= addonName then return end
    em:UnregisterForEvent(eventName)

    --[[LIBRARIES]]
    --LibAddonMenu-2.0
    FCOGuildLottery.LAM = LibAddonMenu2

    --LibHistoire
    checkForLibHistoireReady()
    if FCOGuildLottery.LH == nil then
        df(addonNamePre .. "!!!!! ERROR Mandatory library \'LibHistoire\' is not found !!!!!")
        return
    end

    --Get the SavedVariables
    FCOGuildLottery.getSettings()

    --Get the guilds data for the dropdown boxes
    buildGuildsData()

    --Add the slash commands
    FCOGuildLottery.slashCommands()

    --Build the LAM settings panel
    FCOGuildLottery.buildAddonMenu()

    --Dialogs
    FCOGuildLottery.AskBeforeResetDialogInitialize(FCOGLAskBeforeResetDialogXML, FCOGuildLottery.getDialogName("resetGuildSalesLottery"))
    FCOGuildLottery.AskBeforeResetDialogInitialize(FCOGLAskBeforeResetGuildMemberJoinDateDialogXML, FCOGuildLottery.getDialogName("resetGuildMembersJoinDate"))

    --EVENTS
    --Register for the zone change/player ready event
    em:RegisterForEvent(addonName .. "EVENT_PLAYER_ACTIVATED",      EVENT_PLAYER_ACTIVATED,         eventPlayerActivated)

    em:RegisterForEvent(addonName .. "EVENT_GUILD_MEMBER_ADDED",    EVENT_GUILD_MEMBER_ADDED,       eventGuildMember)
    em:RegisterForEvent(addonName .. "EVENT_GUILD_MEMBER_REMOVED",  EVENT_GUILD_MEMBER_REMOVED,     eventGuildMember)

    em:RegisterForEvent(addonName .. "EVENT_GUILD_JOINED",          EVENT_GUILD_SELF_JOINED_GUILD,  eventGuildJoinedOrLeft)
    em:RegisterForEvent(addonName .. "EVENT_GUILD_LEFT",            EVENT_GUILD_SELF_LEFT_GUILD,    eventGuildJoinedOrLeft)
end

function FCOGuildLottery.initialize()
    em:RegisterForEvent(addonName .. "EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, addonLoaded)
end

--Load the addon
FCOGuildLottery.initialize()
