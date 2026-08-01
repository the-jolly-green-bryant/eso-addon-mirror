FCOGC = FCOGC or  {}
local FCOGuildCampaign = FCOGC

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--local speed-up
local EM = EVENT_MANAGER

local tos                                                      = tostring
local ton                                                      = tonumber
local strfor                                                   = string.format
local strsub                                                   = string.sub
local strlen                                                   = string.len
local strgsub                                                  = string.gsub
local tins                                                     = table.insert

local MAX_GMN_LENGTH                                           = 255    --Maximum characters within a guild member note
local MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE             = 30     --Wait at least 30 seconds (1/2 minute) before the next guild member update for the same @displayName will be issued
local MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD = 2      --Wait at least 2 seconds before the next guild member update for the same @displayName at another guildId will be issued

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Addon variables
local addonVars                                                = FCOGuildCampaign.addonVars
local addonName                                                = addonVars.addonName
local addonNameMenuDisplay                                     = addonVars.addonNameMenuDisplay
local addonNameMenuDisplayPrefix                               = "[" .. addonNameMenuDisplay .. "] "

local campaignIdDelimiter                                      = FCOGuildCampaign.campaignIdDelimiter
local campaignIdDelimiterLength = strlen(campaignIdDelimiter)
local campaignIdLength = 3 --normal length of campaign IDs

local campaignTexture = "/esoui/art/tutorial/campaign_tabicon_browser_up.dds"
local maxGuilds = MAX_GUILDS

local myAlliance
local myDisplayName
local enabledGuildIds, enabledGuildsLookup

local wasAutomatedGuildMemberNoteUpdate = false

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--ZOs controls etc.
local GRM = GUILD_ROSTER_MANAGER
local GRK = GUILD_ROSTER_KEYBOARD


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Libraries
local LGR = FCOGuildCampaign.LGR


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---Functions
local function refreshGuildRoster(delay)
    if LGR ~= nil and LGR.Refresh ~= nil then
        if FCOGuildCampaign.doDebug then d(">[FCOGuildCampaign.refreshGuildRoster] Refreshing...") end
        if delay ~= nil then
            zo_callLater(function()
                LGR:Refresh()
            end, delay)
        else
            LGR:Refresh()
        end
    end
end
FCOGuildCampaign.RefreshGuildRoster = refreshGuildRoster

local function isGuildRosterShown(doUpdate, delay)
    if GRK ~= nil and GRK.control ~= nil and GRK.control:IsHidden() == false then
        if FCOGuildCampaign.doDebug then d(">[FCOGuildCampaign.isGuildRosterShown] true") end
        if doUpdate == true then refreshGuildRoster(delay) end
        return true
    end
    if FCOGuildCampaign.doDebug then d("<[FCOGuildCampaign.isGuildRosterShown] false") end
    return false
end
FCOGuildCampaign.IsGuildRosterShown = isGuildRosterShown

local function findCampaignIdDelimiter(stringToSearch, offset)
    --Find the campaignId delimiter ";~" followed by 3digits (campaignId) in the text
    local foundDelimiter, campaignIdOfDisplayName
    foundDelimiter = false

    local foundAtPos = zo_strfind(stringToSearch, campaignIdDelimiter, offset, true)
    if foundAtPos ~= nil then
--d(">found campaign delimiter: " ..tos(foundAtPos))
        local startFrom = (foundAtPos + campaignIdDelimiterLength)
        local endAt = (startFrom + campaignIdLength)
        campaignIdOfDisplayName = strsub(stringToSearch, startFrom, endAt)
--d(">campaignIdOfDisplayName: " ..tos(campaignIdOfDisplayName))
        campaignIdOfDisplayName = ton(campaignIdOfDisplayName)
        if type(campaignIdOfDisplayName) == "number" then
            foundDelimiter = true
        else
            campaignIdOfDisplayName = nil
        end
    end
    return foundDelimiter, foundAtPos, campaignIdOfDisplayName
end


local function getEnabledGuilds()
    if FCOGuildCampaign.settingsVars.settings == nil then return end
    local enabledGuildsAtSettings = FCOGuildCampaign.settingsVars.settings.isGuildEnabled
    enabledGuildIds = {}
    enabledGuildsLookup = {}
    for guildId, isEnabled in pairs(enabledGuildsAtSettings) do
        if isEnabled then
            tins(enabledGuildIds, guildId)
            enabledGuildsLookup[guildId] = true
        end
    end
end
FCOGuildCampaign.GetEnabledGuilds = getEnabledGuilds


function FCOGuildCampaign.GetGuildChatChannel(guildIndex, guildId)
    if guildIndex ~= nil then
        guildIndex = zo_clamp(guildIndex, 1, maxGuilds)
        return _G["CHAT_CHANNEL_GUILD_" .. tostring(guildIndex)]
    end
    if guildId ~= nil and guildIndex == nil then
        for guildIndex = 1, GetNumGuilds(), 1 do
            local guildIdLoop = GetGuildId(guildIndex)
            if guildIdLoop == guildId then
                return _G["CHAT_CHANNEL_GUILD_" .. tostring(guildIndex)]
            end
        end
    end
end
local getGuildChatChannel = FCOGuildCampaign.GetGuildChatChannel


function FCOGuildCampaign.GetSelectedGuildIndexAndId()
    local selectedGuildId = GRM.guildId
    if selectedGuildId ~= nil then
        for guildIndex = 1, GetNumGuilds(), 1 do
            local guildIdLoop = GetGuildId(guildIndex)
            if guildIdLoop == selectedGuildId then
                return guildIndex, selectedGuildId
            end
        end
    end
    return nil, selectedGuildId
end
local getSelectedGuildIndexAndId =  FCOGuildCampaign.GetSelectedGuildIndexAndId


function FCOGuildCampaign.GetCurrentOrAssignedCampaignName()
    local campaignId = GetCurrentCampaignId()
    if campaignId == nil or campaignId == 0 then
        campaignId = GetAssignedCampaignId()
    end
    if campaignId == nil or campaignId == 0 then return "", nil end
    local campaignName = GetCampaignName(campaignId)
    if campaignName == nil then return "", campaignId end
    return campaignName, campaignId
end
local getCurrentOrAssignedCampaignName = FCOGuildCampaign.GetCurrentOrAssignedCampaignName


function FCOGuildCampaign.ShowMyCampaign()
    if not IsInCampaign() then
        d(GetString(FCOGC_NOT_IN_CAMPAIGN))
        return
    end
    local campaignName, campaignId = getCurrentOrAssignedCampaignName()
    if campaignName == nil or campaignName == "" then campaignName = GetString(SI_ALLIANCE0) end --None
    local currentCampaignStr = strfor(GetString(FCOGC_CURRENT_CAMPAIGN) .. ": %q (%s)", tos(campaignName), tos(campaignId))
    d(currentCampaignStr)

    local selectedGuildIndex = getSelectedGuildIndexAndId()
    local guildChatChannel = getGuildChatChannel(selectedGuildIndex, nil)
    StartChatInput(currentCampaignStr, guildChatChannel)
end


function FCOGuildCampaign.DoesHaveGuildMemberNoteChangeRights(guildIndex, guildId)
    if not guildIndex and not guildId then return false end
    guildId = guildId or GetGuildId(guildIndex)
    if not guildId then return false end
    local hasPrivilege = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT)
    hasPrivilege = hasPrivilege or false
    return hasPrivilege
end
local doesHaveGuildMemberNoteChangeRights =  FCOGuildCampaign.DoesHaveGuildMemberNoteChangeRights


function FCOGuildCampaign.GetGuildMemberNote(guildId, displayName)
    if guildId == nil or displayName == nil or displayName == "" then return end
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    if memberIndex == nil then return end
    local _, note = GetGuildMemberInfo(guildId, memberIndex)
    return note
end
local getGuildMemberNote = FCOGuildCampaign.GetGuildMemberNote


function FCOGuildCampaign.GetCampaignIdFromGuildMemberNote(guildId, displayName, guildMemberNote)
    --Campaign Id of the displayName, if written to the guild member note
    local foundDelimiter, foundAtPos, campaignIdOfDisplayName
    if guildMemberNote == nil and ( guildId == nil or displayName == nil) then return nil, nil, nil end
    guildMemberNote = guildMemberNote or getGuildMemberNote(guildId, displayName)
    if guildMemberNote ~= nil and guildMemberNote ~= "" then
        foundDelimiter, foundAtPos, campaignIdOfDisplayName = findCampaignIdDelimiter(guildMemberNote, 1)
    end
    return campaignIdOfDisplayName, foundDelimiter, foundAtPos
end
local getCampaignIdFromGuildMemberNote = FCOGuildCampaign.GetCampaignIdFromGuildMemberNote


--returns number myCampaignId, String myCampaignName,
--  boolean campaignIsSameAsMyCurrentOrAssignedCampaign, number campaignIdOfDisplayName,
--  boolean alliancesAreSame, boolean myCampaignIsNotAssigned, boolean campaignIdOfDisplayNameIsNotInGuildMemeberNote
function FCOGuildCampaign.CompareCampaignIdFromGuildMemberNote(guildId, displayName)
    --d("[FCOGC.GetCampaignNameFromGuildMemberNote]guildId: " ..tos(guildId) .. ", displayName: " ..tos(displayName))

    --Own Campaign
    local myCampaignName, myCampaignId = getCurrentOrAssignedCampaignName()
    if myCampaignId == nil or myCampaignId == 0 then
        --I have no campaign assigned
       return myCampaignId, myCampaignName, nil, nil, nil, true, nil
    end

    --Own fraction
    local otherAlliance, alliancesAreSame, campaignIsSameAsMyCurrentOrAssignedCampaign
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId,displayName)
    if memberIndex == nil then
        return myCampaignId, myCampaignName, nil, nil, nil, nil, nil, nil, nil
    end
    --_Returns:_ *bool* _hasCharacter_, *string* _characterName_, *string* _zoneName_, *integer* _classType_, *[Alliance|#Alliance]* _alliance_, *integer* _level_, *integer* _championRank_, *integer* _zoneId_, *id64* _consoleId_
    local hasCharacter, characterName, zoneName, classType, alliance = GetGuildMemberCharacterInfo(guildId, memberIndex)
    if hasCharacter and alliance ~= nil then
        otherAlliance = alliance
    end
    --otherAlliance = GetFraction
    alliancesAreSame = (otherAlliance ~= nil and myAlliance == otherAlliance) or false

    local campaignIdOfDisplayName = getCampaignIdFromGuildMemberNote(guildId, displayName, nil)
    if campaignIdOfDisplayName == nil then
        return myCampaignId, myCampaignName, nil, nil, alliancesAreSame, false, true
    end

    if myCampaignId == campaignIdOfDisplayName then
        campaignIsSameAsMyCurrentOrAssignedCampaign = true
    else
        campaignIsSameAsMyCurrentOrAssignedCampaign = false
    end
    return myCampaignId, myCampaignName, campaignIsSameAsMyCurrentOrAssignedCampaign, campaignIdOfDisplayName, alliancesAreSame, false, false
end
local compareCampaignIdFromGuildMemberNote = FCOGuildCampaign.CompareCampaignIdFromGuildMemberNote


local function findExistingCampaignIdDelimiterAndReplace(guildMemberNoteText, maxGuildMemberNoteTextUsed, overwriteLast5Chars, guildId, displayName)
    local doDebug = FCOGuildCampaign.doDebug
    local guildMemberNoteTextWasEmpty = false
    local needsUpdate = false
    if guildMemberNoteText == nil or guildMemberNoteText == "" then
        guildMemberNoteTextWasEmpty = true
        guildMemberNoteText = ""
        maxGuildMemberNoteTextUsed = false
    end
    local newGuildMemberNoteText, currentDelimiterOffset, campaignIdAtGuildMemberNote
    local foundDelimiter = false
    if not overwriteLast5Chars then
        --Do not overwrite, just fail if max length is already used
        -->But return true as 2nd param to indicate that an update would be needed (manually then) -> For debug output
        if maxGuildMemberNoteTextUsed == true then return nil, true end
        --Or replace existing delimiter, or add at the end
        -->See below

        --else
        --Do overwrite if max length was used already, or
        --replace existing delimiter, or add at the end
        -->See below
    end
    --Settings are enabled to change the guildMemberNote?
    -->If enabled: Change it
    -->If disabled and delimiter is found: Remove delimiter and <campaignId>
    local isEnabledAtGuildId = enabledGuildsLookup[guildId]
    if doDebug then d(">isEnabledAtGuildId: " ..tos(isEnabledAtGuildId)) end

    --Get the current campaignId
    local _, currentCampaignId = getCurrentOrAssignedCampaignName()
    --If the current campaign is nil or 0: Add ;~0 to the guild member note
    if currentCampaignId == nil then currentCampaignId = 0 end
    if doDebug then d(">currentCampaignId: " ..tos(currentCampaignId)) end

    --Find existing delimiter
    if guildMemberNoteTextWasEmpty == false then
        if doDebug then d(">1") end
        campaignIdAtGuildMemberNote, foundDelimiter, currentDelimiterOffset = getCampaignIdFromGuildMemberNote(guildId, displayName, guildMemberNoteText)
        if foundDelimiter == true and currentDelimiterOffset ~= nil then
            if doDebug then d(">2") end
            --Settings are enabled at the guildId?
            if isEnabledAtGuildId == true then
                if doDebug then d(">3") end
                --Current campaignId at the guild member note text is not the same as the current?
                if ton(campaignIdAtGuildMemberNote) ~= ton(currentCampaignId) then
                    needsUpdate = true
                    if doDebug then d(">4") end
                    --Replace the 3 characters after currentDelimiterOffset with the actual currentCampaignId
                    newGuildMemberNoteText = strgsub(guildMemberNoteText, (campaignIdDelimiter .. tos(campaignIdAtGuildMemberNote)), (campaignIdDelimiter .. tos(currentCampaignId)), 1)
                end
            else
                needsUpdate = true
                if doDebug then d(">5") end
                --Settings are disabled: Remove the deimiter and <campaignId>
                newGuildMemberNoteText = strgsub(guildMemberNoteText, (campaignIdDelimiter .. tos(campaignIdAtGuildMemberNote)), "", 1)
            end
        elseif foundDelimiter == false then
            if doDebug then d(">6") end
            --Settings are enabled at the guildId?
            if isEnabledAtGuildId == true then
                needsUpdate = true
                if doDebug then d(">7") end
                if maxGuildMemberNoteTextUsed == true then
                    if doDebug then d(">8") end
                    --No delimiter found: Overwrite the last 5 chars with the current campaignId and the delimiter
                    newGuildMemberNoteText = strsub(guildMemberNoteText, 1, -1 * (campaignIdDelimiterLength +1)) .. campaignIdDelimiter .. tos(currentCampaignId)
                else
                    if doDebug then d(">9") end
                    --No delimiter found: Add the current campaignId with the delimiter at the end
                    newGuildMemberNoteText = guildMemberNoteText .. campaignIdDelimiter .. tos(currentCampaignId)
                end
            end
        end
    else
        if doDebug then d(">10") end
        --Guild member note text was empty, just set it with the delimiter now
        -->If settings are enabled
        if isEnabledAtGuildId == true then
            needsUpdate = true
            if doDebug then d(">11") end
            newGuildMemberNoteText = campaignIdDelimiter .. tos(currentCampaignId)
        end
    end
    if doDebug then d("<newGuildMemberNoteText: " ..tos(newGuildMemberNoteText)) end
    return newGuildMemberNoteText, needsUpdate
end


local function updateGuildMemberNoteByAPI(guildId, displayName, note)
    if guildId == nil or displayName == nil or note == nil then return false end
    local numGuildMembers = GetNumGuildMembers(guildId)
    for guildMemberIndex = 1, numGuildMembers do
        local currentDisplayName = GetGuildMemberInfo(guildId, guildMemberIndex)
        if currentDisplayName == displayName then
            wasAutomatedGuildMemberNoteUpdate = true
            SetGuildMemberNote(guildId, guildMemberIndex, note)
            wasAutomatedGuildMemberNoteUpdate = false
            return true
        end
    end
    return false
end


--returns nil, nil, true                                if update was not done because last update was tried within x seconds after the last update with the same @displayName or guildId & @displayName was done
--returns true, newGuildMemberNoteText, false           if update was possible and done
--returns false, nilable:newGuildMemberNoteText, false  if update was possible but not done
function FCOGuildCampaign.UpdateGuildMemberNote(guildId, displayName, showChatOutput, reScheduleIfCurrentlyBlocked)
    showChatOutput = showChatOutput or false
    reScheduleIfCurrentlyBlocked = reScheduleIfCurrentlyBlocked or false
    local settings = FCOGuildCampaign.settingsVars.settings
    local lastGuildMemberNoteUpdates = settings.lastGuildMemberNoteUpdates[guildId]
    local lastGuildMemberNoteUpdateByDisplayName = FCOGuildCampaign.lastGuildMemberNoteUpdateByDisplayName

    local doDebug = FCOGuildCampaign.doDebug
    local doChatOutput = showChatOutput or doDebug

    if enabledGuildsLookup == nil or NonContiguousCount(enabledGuildsLookup) <= 0 then
        getEnabledGuilds()
        --[[
        if enabledGuildsLookup == nil or NonContiguousCount(enabledGuildsLookup) <= 0 then
            d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT: No guildId enabled in settings")
            return nil, nil, true
        end
        ]]
    end

    local maxGuildMemberNoteTextUsed = false
    local currentGuildMemberNoteLength = 0
    local guildMemberNoteText = ""
    local newGuildMemberNoteText
    local needsUpdate = false

    local nowTS = GetTimeStamp()
    --d("[FCOGuildCampaign.UpdateGuildMemberNote]guildId: " .. tos(guildId) .. ", displayName: " ..tos(displayName) .. ", now: " ..tos(os.date("%c", nowTS)))

    if guildId == nil or displayName == nil then
        if enabledGuildsLookup[guildId] then
            d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT: No guildId or no displayName")
        end
        return nil, nil, true
    end
    --Check if displayName is a member of the guildId and if he got a character
    local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    if guildMemberIndex == nil or guildMemberIndex == 0 then
        if enabledGuildsLookup[guildId] then
            d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT: displayName is not member of the guild: " ..tos(GetGuildName(guildId)))
        end
        return nil, nil, true
    end
    local hasCharacter = GetGuildMemberCharacterInfo(guildId, guildMemberIndex)
    if not hasCharacter then
        if enabledGuildsLookup[guildId] then
            d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT: displayName got no character in the guild: " ..tos(GetGuildName(guildId)))
        end
        return nil, nil, true
    end

    --User got rights to change the guild member note
    if doesHaveGuildMemberNoteChangeRights(nil, guildId) == false then
        if enabledGuildsLookup[guildId] then
            d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT: No rights to change guildNote, guild: " ..tos(GetGuildName(guildId)))
        end
        return nil, nil, true
    end

    --Check when the last guild member note update was done (if already done)
    if lastGuildMemberNoteUpdates == nil then
        settings.lastGuildMemberNoteUpdates[guildId] = {}
        lastGuildMemberNoteUpdates = settings.lastGuildMemberNoteUpdates[guildId]
    end
    if lastGuildMemberNoteUpdateByDisplayName[displayName] ~= nil then
        local lastUpdateDoneTimestamp = lastGuildMemberNoteUpdateByDisplayName[displayName].lastUpdateDone
        local guildIdOfLastUpdate     = lastGuildMemberNoteUpdateByDisplayName[displayName].guildId
        --Other guildId will be updated, but same displayName?
        local deltaNowToLastUpdate = nowTS - lastUpdateDoneTimestamp
        if guildIdOfLastUpdate ~= guildId and (deltaNowToLastUpdate < MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD) then
            if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT - Last @displayName Update try was at: " ..tos(os.date("%c", lastUpdateDoneTimestamp)).. ", nowMinusLastTrySec/waitSec: " ..tos(nowTS - lastUpdateDoneTimestamp) .. "/" ..tos(MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD)) end
            if reScheduleIfCurrentlyBlocked == true then
                --Automatically try again after min-needed delta time to last update was reached
                local timeInSecondsToWaitFromNow = MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD - deltaNowToLastUpdate
                if timeInSecondsToWaitFromNow ~= nil then
                    if doChatOutput then d(">reScheduled next try in \'" .. tos(timeInSecondsToWaitFromNow) .."\' seconds...") end
                    zo_callLater(function()
                        FCOGuildCampaign.UpdateGuildMemberNote(guildId, displayName, showChatOutput, false)
                    end, timeInSecondsToWaitFromNow * 1000)
                end
            end
            return nil, nil, true
        end
    end
    if lastGuildMemberNoteUpdates[displayName] ~= nil then
        local deltaNowToLastUpdate = nowTS - lastGuildMemberNoteUpdates[displayName]
        if deltaNowToLastUpdate < MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE then
            if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]ABORT - Last guildId & @displayName Update try was at: " ..tos(os.date("%c", lastGuildMemberNoteUpdates[displayName])) .. ", nowMinusLastTrySec/waitSec: " ..tos(nowTS - lastGuildMemberNoteUpdates[displayName]) .. "/" ..tos(MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE)) end
            if reScheduleIfCurrentlyBlocked == true then
                --Automatically try again after min-needed delta time to last update was reached
                local timeInSecondsToWaitFromNow = MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE - deltaNowToLastUpdate
                if timeInSecondsToWaitFromNow ~= nil then
                    if doChatOutput then d(">reScheduled next try in \'" .. tos(timeInSecondsToWaitFromNow) .."\' seconds...") end
                    zo_callLater(function()
                        FCOGuildCampaign.UpdateGuildMemberNote(guildId, displayName, showChatOutput, false)
                    end, timeInSecondsToWaitFromNow * 1000)
                end
            end
            return nil, nil, true
        end
    end

    --Get the current guild member note
    guildMemberNoteText = getGuildMemberNote(guildId, displayName)
    if guildMemberNoteText ~= nil and guildMemberNoteText ~= "" then
        --Check the length
        currentGuildMemberNoteLength = strlen(guildMemberNoteText)
        --Maximum length already used? Max length is 255 chars - delimiter ;~<campaignId> length (5 chars)
        maxGuildMemberNoteTextUsed = (currentGuildMemberNoteLength >= (MAX_GMN_LENGTH - campaignIdDelimiterLength) and true) or false
    end
    if doDebug then d(">guildMemberNoteText: " ..tos(guildMemberNoteText) .. ", maxGuildMemberNoteTextUsed: " ..tos(maxGuildMemberNoteTextUsed) .. ", currentGuildMemberNoteLength: " ..tos(currentGuildMemberNoteLength)) end

    --Always overwrite the last 5 characters of the guild member note? Or not
    newGuildMemberNoteText, needsUpdate = findExistingCampaignIdDelimiterAndReplace(guildMemberNoteText, maxGuildMemberNoteTextUsed, settings.reserveLast5CharsAtGuildMemberNote, guildId, displayName)
    --Update the new guild member note text
    if doDebug then d(">newGuildMemberNoteText: " ..tos(newGuildMemberNoteText) .. ", needsUpdate: " ..tos(needsUpdate)) end
    if needsUpdate == true then
        --Update is needed, but new text is nil (text can be empty ""!)?
        if newGuildMemberNoteText == nil then
            --Is the setting to overwrite the last 5 characters is not enabled?
            if maxGuildMemberNoteTextUsed == true and not settings.reserveLast5CharsAtGuildMemberNote then
                --New guild member note text was not build as it cannot be overwritten due to settings -> Manual update is needed!
                local _, currentCampaignId = getCurrentOrAssignedCampaignName()
                local neededGuildMemberNoteCampaignIdentifier = campaignIdDelimiter .. tos(currentCampaignId)
                if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]Manual update of guild member note is needed! Please add string \'" .. neededGuildMemberNoteCampaignIdentifier .. "\' to the note of guild: " ..tos(GetGuildName(guildId))) end
                return false, newGuildMemberNoteText, false
            else
                --New guild member note text was not build or an error occured
                if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]New guild member note text was not build or an error occured! Guild: " ..tos(GetGuildName(guildId))) end
                return false, newGuildMemberNoteText, false
            end
        end

        --Update the "last time updated" timestamp for the guildId and @displayName so that the next try won't be done within x seconds
        settings.lastGuildMemberNoteUpdates[guildId][displayName] = nowTS
        --Update the "last time updated" timestamp for the @displayName so that the next try for any other guildId (same @displayName) won't be done within x seconds
        FCOGuildCampaign.lastGuildMemberNoteUpdateByDisplayName[displayName] = {
            guildId = guildId,
            lastUpdateDone = nowTS,
        }
        --d(">>set last update try to: now")

        --Set the new guild member note via API  function SetGuildMemberNote
        if updateGuildMemberNoteByAPI(guildId, displayName, newGuildMemberNoteText) == true then
            if doChatOutput then d(">[FCOGuildCampaign.UpdateGuildMemberNote]OK - Guild member note updated to: " ..tos(newGuildMemberNoteText) ..", Guild: " ..tos(GetGuildName(guildId))) end
            return true, newGuildMemberNoteText, false
        else
            if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]ERROR - Guild member note NOT updated! Guild: " ..tos(GetGuildName(guildId))) end
            return false, newGuildMemberNoteText, false
        end
    else
        --No update needed
        if doChatOutput then d("<[FCOGuildCampaign.UpdateGuildMemberNote]OK - Guild member note needs no update! Guild: " ..tos(GetGuildName(guildId))) end
        return false, guildMemberNoteText, false
    end
end
local updateGuildMemberNote = FCOGuildCampaign.UpdateGuildMemberNote


function FCOGuildCampaign.UpdateAllGuildsMemberNote(displayName)
    --Update the enabled guilds
    getEnabledGuilds()

    local numGuilds = GetNumGuilds()
    if numGuilds == 0 then return end
    --Update the guild member notes and add the current campaign
    -->Delay each different guild member note updater by 2.5 seconds (MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD + 0.5)
    local delay = 0
    for guildIndex=1, numGuilds, 1 do
        local guildId = GetGuildId(guildIndex)
        if guildId ~= nil and guildId > 0 then
--d(">delay: " ..tos(delay))
            if delay == 0 then
                local wasUpdated, _, _ = updateGuildMemberNote(guildId, displayName, false, false)
                if wasUpdated == true then
                    delay = delay + MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD
--d(">>delay increase: " ..tos(delay))
                end
            else
                local delayInMS = delay * 1000
                zo_callLater(function()
                    local wasUpdated, _, _ = updateGuildMemberNote(guildId, displayName, false, false)
                    if wasUpdated == true then
                        delay = delay + MIN_WAIT_TIME_SECONDS_BEFORE_NEXT_GMN_UPDATE_OTHER_GUILD
--d(">>zo_callLater delay increase: " ..tos(delay))
                    end
                end, delayInMS)
            end
        end
    end
end
local updateAllGuildsMemberNote = FCOGuildCampaign.UpdateAllGuildsMemberNote


--======================================================================================================================
--Hooks
local wasGuildRosterHooked = false
local guildMemberCampaingColumn
local function hookGuildRoster()
    if not LGR then return end
    --d("[FCOGC]hookGuildRoster")
    if guildMemberCampaingColumn == nil and not wasGuildRosterHooked then
        guildMemberCampaingColumn = LGR:AddColumn({
            key = addonName .. "_CurrentAVACampaignColumn",
            width = 32,
            header = {
                title = GetString(FCOGC_CURRENT_CAMPAIGN_HEADER),
                tooltip = GetString(FCOGC_CURRENT_CAMPAIGN_HEADER_TT)
            },

            row = {
                align = TEXT_ALIGN_LEFT,
                data = function( guildId, data, index )
                    --reset data
                    data.FCOGuildCampaignData = nil
                    --[[
                    {
                        campaignIsSameAsMyCurrentOrAssignedCampaign = nil,
                        campaignIdOfDisplayName = nil,
                        campaignNameOfDisplayName = nil,
                        alliancesAreSame = nil,
                        myCampaignIsNotAssigned = nil,
                        campaignIdOfDisplayNameIsNotInGuildMemeberNote = nil,
                        campaignComparisonStr = nil,
                        campaignComparisonTooltipStr = nil,
                    }
                    ]]

                    local displayName = data.displayName
                    if not displayName or displayName == myDisplayName or not data.hasCharacter then return "" end

                    local campaignNameOfMember, colorStr, tooltipStr

                    --returns number myCampaignId, String myCampaignName,
                    --  boolean campaignIsSameAsMyCurrentOrAssignedCampaign, number campaignIdOfDisplayName,
                    --  boolean alliancesAreSame, boolean myCampaignIsNotAssigned, boolean campaignIdOfDisplayNameIsNotInGuildMemeberNote
                    local myCampaignId, myCampaignName, campaignIsSameAsMyCurrentOrAssignedCampaign, campaignIdOfDisplayName, alliancesAreSame, myCampaignIsNotAssigned, campaignIdOfDisplayNameIsNotInGuildMemeberNote = compareCampaignIdFromGuildMemberNote(guildId, displayName)

                    --update data
                    data.FCOGuildCampaignData = {}
                    local FCOGuildCampaignData = data.FCOGuildCampaignData
                    FCOGuildCampaignData.campaignIsSameAsMyCurrentOrAssignedCampaign = campaignIsSameAsMyCurrentOrAssignedCampaign
                    FCOGuildCampaignData.alliancesAreSame = alliancesAreSame
                    FCOGuildCampaignData.myCampaignIsNotAssigned = myCampaignIsNotAssigned
                    FCOGuildCampaignData.campaignIdOfDisplayNameIsNotInGuildMemeberNote = campaignIdOfDisplayNameIsNotInGuildMemeberNote
                    if campaignIdOfDisplayName ~= nil and campaignIdOfDisplayName > 0 then
                        FCOGuildCampaignData.campaignIdOfDisplayName = campaignIdOfDisplayName
                        campaignNameOfMember = GetCampaignName(campaignIdOfDisplayName)
                        FCOGuildCampaignData.campaignNameOfDisplayName = campaignNameOfMember
                    end

                    --Check if the texture needs to be shown, and what color it must have
                    if alliancesAreSame == true then
                        return ""
                    end
                    --We ourself do not have any current or assigned campaign
                    if myCampaignIsNotAssigned == true then
                        return ""
                    end

                    if campaignIdOfDisplayNameIsNotInGuildMemeberNote == true then
                        colorStr = "|cffff00"
                    end
                    if colorStr == nil then
                        colorStr = (not campaignIsSameAsMyCurrentOrAssignedCampaign and "|cff0000") or "|c00ff00"
                    end

                    local retStr = colorStr .. zo_iconFormatInheritColor(campaignTexture, 28, 28) .. "|r"
                    FCOGuildCampaignData.campaignComparisonStr = retStr

                    tooltipStr = addonNameMenuDisplayPrefix .. retStr
                    if campaignIdOfDisplayName ~= nil then
                        tooltipStr = tooltipStr .. " " .. tos(campaignNameOfMember) .. " (ID: |cADD8E6" ..tos(campaignIdOfDisplayName) .. "|r)"
                    end
                    if campaignIdOfDisplayNameIsNotInGuildMemeberNote == true then
                        tooltipStr = tooltipStr .. "\n" .. GetString(FCOGC_CAMPAIGNID_MISSING_IN_MEMBER_NOTE_TT)
                    else
                        if campaignIsSameAsMyCurrentOrAssignedCampaign == true then
                            tooltipStr = tooltipStr .. "\n" .. GetString(FCOGC_SAME_CAMPAIGN_TT)
                        else
                            tooltipStr = tooltipStr .. "\n" .. GetString(FCOGC_DIFFERENT_CAMPAIGN_TT)
                        end
                    end
                    if myCampaignId ~= nil then
                        tooltipStr = tooltipStr .. "\n" .. GetString(FCOGC_CURRENT_CAMPAIGN) ..": " ..tos(myCampaignName) .. " (ID: |cADD8E6" ..tos(myCampaignId) .. "|r)"
                    end
                    FCOGuildCampaignData.campaignComparisonTooltipStr = tooltipStr

                    -- Return an unformated raw value: String
                    return retStr
                end,
                --[[
                format = function( value ) --value is always a String
                    --return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(tonumber(value)))..' carrots'
                end
                ]]
                mouseEnabled = function(guildId, data, control)
                    local campaignComparisonTooltipStr = (data.FCOGuildCampaignData ~= nil and data.FCOGuildCampaignData.campaignComparisonTooltipStr ~= nil and data.FCOGuildCampaignData.campaignComparisonTooltipStr) or nil
                    return (campaignComparisonTooltipStr ~= nil and campaignComparisonTooltipStr ~= "" and true) or false
                end,
                OnMouseEnter = function(guildId, data, control)
                    local campaignComparisonTooltipStr = (data.FCOGuildCampaignData ~= nil and data.FCOGuildCampaignData.campaignComparisonTooltipStr ~= nil and data.FCOGuildCampaignData.campaignComparisonTooltipStr) or nil
                    if campaignComparisonTooltipStr ~= nil and campaignComparisonTooltipStr ~= "" then
                        ZO_Tooltips_ShowTextTooltip(control, LEFT, campaignComparisonTooltipStr)
                    end
                end,
                OnMouseExit = function(guildId, data, control)
                    ZO_Tooltips_HideTextTooltip()
                end
            }
        })
    end

    if guildMemberCampaingColumn ~= nil then
        --Only enable the new column for specified guildIds from the settings
        getEnabledGuilds()
        if enabledGuildIds ~= nil then
            guildMemberCampaingColumn:SetGuildFilter(enabledGuildIds)
            --Is any guild enabled?
            local numGuilds = GetNumGuilds() --Actual number of guilds, e.g. 5
            local numEnabledGuilds = NonContiguousCount(enabledGuildIds)
            if numEnabledGuilds >= 1 and numEnabledGuilds <= numGuilds then
                wasGuildRosterHooked = true
            else
                wasGuildRosterHooked = false
            end
            --d(">wasGuildRosterHooked: " ..tos(wasGuildRosterHooked))

            --Refresh teh guild roster if currently shown
            isGuildRosterShown(true, 100)
        end
    end

    --Guild Roster was loaded properly
    --[[
    LGR:OnRosterReady(function()
--d("[LGR]OnRosterReady")
        -- Roster has finished rendering
    end)
    ]]
end
FCOGuildCampaign.HookGuildRoster = hookGuildRoster


local function hookGuildMemberNote()
    --After guild member note was changed and the guild roster is currently shown (manual change) update the guild roster!
    SecurePostHook("SetGuildMemberNote", function(guildId, guildMemberIndex, note)
        if wasAutomatedGuildMemberNoteUpdate == false then
            if FCOGuildCampaign.doDebug then d("[FCOGuildCampaign->SecurePostHook: SetGuildMemberNote]wasAutomatedUpdate: " ..tos(wasAutomatedGuildMemberNoteUpdate) ..", guildId: " ..tos(guildId) ..", guildMemberIndex: " ..tos(guildMemberIndex) .. ", note: " ..tos(note)) end
            isGuildRosterShown(true, 100)
        end
    end)
end

--======================================================================================================================
--Player activated function
local playerActivatedEventCalls = 0
function FCOGuildCampaign.OnPlayer_Activated(eventId, wasFirst)
    playerActivatedEventCalls = playerActivatedEventCalls + 1
    myDisplayName = myDisplayName or GetDisplayName()

    --Update the guildMemberNote
    updateAllGuildsMemberNote(myDisplayName)

    --Hook the guild roster again now?
    if playerActivatedEventCalls > 1 and wasGuildRosterHooked == false then
        hookGuildRoster()
    end

    FCOGuildCampaign.playerActivatedDone = true
end

--Campaign events
function FCOGuildCampaign.OnCampaign_Assignment_Result(eventId, assignmentResult)
    if FCOGuildCampaign.doDebug then d("[FCOGuildCampaign.OnCampaign_Assignment_Result]assignError: " ..tos(assignmentResult)) end
    if assignmentResult == CAMPAIGN_REASSIGN_ERROR_NONE then
        --Campaign re-assign should have worked, so rebuild the guild member notes
        updateAllGuildsMemberNote(myDisplayName)
    end
end

function FCOGuildCampaign.OnCampaign_UnAssignment_Result(eventId, unAssignmentResult)
    if FCOGuildCampaign.doDebug then d("[FCOGuildCampaign.OnCampaign_UnAssignment_Result]unAssignResult: " ..tos(unAssignmentResult)) end
    if unAssignmentResult == UNASSIGN_CAMPAIGN_RESULT_SUCCESS then
        --Campaign un-assign should have worked, so rebuild the guild member notes
        updateAllGuildsMemberNote(myDisplayName)
    end
end



function FCOGuildCampaign.addonLoaded(eventName, addon)
    --[[
    if addon == "PerfectPixel" then
        FCOGuildCampaign.otherAddons[addon] = true
    end
    ]]
    if addon ~= addonVars.addonName then return end
    EM:UnregisterForEvent(eventName)

    myAlliance = GetUnitAlliance("player")
    myDisplayName = GetDisplayName()

    --Save original functions

    --Get the SavedVariables
    FCOGuildCampaign.getSettings()

    --Update addon wide tables
    getEnabledGuilds()

    --Libraries
    --LibGuildRoster ???

    --Build the LAM settings panel
    FCOGuildCampaign.buildAddonMenu()

    --Hooks
    hookGuildRoster()
    hookGuildMemberNote()

    --EVENTS
    --Events to update the guild member note:
    --Once at each player_activated
    EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOGuildCampaign.OnPlayer_Activated)

    --todo 2023-02-08
    --Once as a campaign is changed
    EM:RegisterForEvent(addonName, EVENT_CAMPAIGN_ASSIGNMENT_RESULT, FCOGuildCampaign.OnCampaign_Assignment_Result)
    EM:RegisterForEvent(addonName, EVENT_CAMPAIGN_UNASSIGNMENT_RESULT, FCOGuildCampaign.OnCampaign_UnAssignment_Result)



    --Once after ... ???
end


function FCOGuildCampaign.initialize()
    EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCOGuildCampaign.addonLoaded)
end

------------------------------------------------------------------------------------------------------------------------
--Load the addon
FCOGuildCampaign.initialize()
