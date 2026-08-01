local LAM = LibAddonMenu2

local addonName = 'ThankYouForYourService'

ThankYouForYourService       = ZO_Object:Subclass()
local T     = ThankYouForYourService
T.name      = "ThankYouForYourService"
T.version   = "1.0.2"
T.debug     = true
T.UI        = {}

local pending = {}
local inDungeon = false
local DEFAULT_MAIL_MESSAGE = "Below is the invoice for services rendered by @ME ('Your Savior'). A payment plan can be provided should you require one. Please reach out to Your Savior to discuss the details."
local DEFAULT_FOOTER_MESSAGE = "This invoice was generated automatically, and made possible by the 'Thank You For Your Service' Add-On.\n\n      ...You're Welcome!™"
local inCombatNow = false

function T:Print(message, ...)
    if T.debug == false then return end
    d(message:format(...))
end

local savedVariables
local defaults = {
    resValid = {
        type = 3
    },
    groupValid = {
        type = 1
    },
    baseMessage = DEFAULT_MAIL_MESSAGE,
    guildOnly = false,
    minRes = 1,
    dungeonOnly = false,
    tallyDungeon = true
}
local resValidList = {
    [1] = "In Combat",
    [2] = "Out Of Combat",
    [3] = "All",
    [4] = "None"
}
local groupValidList = {
    [1] = "Group Only",
    [2] = "Non-Group Players",
    [3] = "Everyone"
}

local function GenerateMailboxMessage(player, cost)
    local savior = GetUnitName('player')
    local row = "Resurrection        1 Soul Gem\n"
    local total = "--------------------------------------\n               TOTAL:"
    if cost > 9 then
        total = total .. " "
    else
        total = total .. "  "
    end
    total = total .. cost .. " Soul Gem"
    if cost > 1 then
        total = total .. "s"
    end

    local invoice = "DESCRIPTION                COST\n--------------------------------------\n"
    for i=1,cost,1 do
        invoice = invoice .. row
    end
    invoice = invoice .. total

    local customMessage = savedVariables.baseMessage
    customMessage = string.gsub(customMessage, "@ME", savior)
    customMessage = string.gsub(customMessage, "@PLAYER", player)
    customMessage = string.gsub(customMessage, "@TIME", ZO_FormatClockTime())
    return customMessage .. "\n\n" .. invoice .. "\n\n" .. DEFAULT_FOOTER_MESSAGE
end

local function SendResMail(player, cost)
    local message = GenerateMailboxMessage(player, cost)

    if cost == 1 then
        T:Print("Sending invoice to " .. player .. " for " .. tostring(cost) .. " Soul Gem")
    else
        T:Print("Sending invoice to " .. player .. " for " .. tostring(cost) .. " Soul Gems")
    end

    RequestOpenMailbox()
    SendMail("@" .. player, "Your Resurrection Invoice", message)
    CloseMailbox()
end

local function CreateSettingsMenu()
    local panelData = {
       type = "panel",
       name = "Thank You For Your Service",
       displayName = "|cFFFFB0Thank You For Your Service|r",
       author = "@skineh",
       version = T.version,
       registerForRefresh = true,
       registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(T.name, panelData)
 
    local optionsTable = {
       {
          type = "header",
          name = "SETTINGS",
          width = "full",
       },
       {
          type = "dropdown",
          name = "Select Combat Option",
          tooltip = "Choose if resurrections that happen in combat and out of combat trigger an invoice. Choose 'None' to turn off invoices completely.",
          choices = resValidList,
          getFunc = function() return resValidList[savedVariables.resValid.type] end,
          setFunc = function(selected)
                for index, name in ipairs(resValidList) do
                   if name == selected then
                      savedVariables.resValid.type = index
                   end
                end
             end,
          default = resValidList[defaults.resValid.type],
       },
       {
          type = "dropdown",
          name = "Select Group Option",
          tooltip = "Choose if only members of your group receive invoices.",
          choices = groupValidList,
          getFunc = function() return groupValidList[savedVariables.groupValid.type] end,
          setFunc = function(selected)
                for index, name in ipairs(groupValidList) do
                   if name == selected then
                      savedVariables.groupValid.type = index
                   end
                end
             end,
          default = groupValidList[defaults.groupValid.type],
       },
       {
          type = "checkbox",
          name = "Guild Members Only",
          tooltip = "Only people in your guilds will receive an invoice (other settings still apply).",
          getFunc = function() return savedVariables.guildOnly end,
          setFunc = function(value) 
                savedVariables.guildOnly = value 
            end,
          default = defaults.guildOnly
       },
       {
          type = "checkbox",
          name = "Dungeons & Trials Only",
          tooltip = "Invoices will only be sent for resurrections that occur in a Dungeon or Trial.",
          getFunc = function() return savedVariables.dungeonOnly end,
          setFunc = function(value) 
                savedVariables.dungeonOnly = value 
            end,
          default = defaults.dungeonOnly
       },
       {
          type = "checkbox",
          name = "One Invoice For Dungeons/Trials",
          tooltip = "Doesn't send an invoice when combat ends. Instead, it will wait until you leave the dungeon or trial (and are back in Overland). It then sends one invoice for ALL resurrections made over the duration of the dungeon/trial. The 'Min Res Required' setting is applied to the final tally.",
          getFunc = function() return savedVariables.tallyDungeon end,
          setFunc = function(value) 
                savedVariables.tallyDungeon = value 
            end,
          default = defaults.tallyDungeon
       },
       {
          type = "slider",
          name = "Min Res Required",
          tooltip = "Controls how many resurrections are required for an invoice to be triggered.",
          min = 1,
          max = 50,
          step = 1,
          getFunc = function() return savedVariables.minRes end,
          setFunc = function(value) 
                savedVariables.minRes = value
            end,
          default = defaults.minRes
       },
       {
          type = "editbox",
          name = "Custom Message",
          tooltip = "This is the message that will appear before the invoice.",
          getFunc = function() return savedVariables.baseMessage end,
          setFunc = function(text) savedVariables.baseMessage = text end,
          isMultiline = true,
          width = "full",
          default = defaults.baseMessage
       },
       {
           type = "description",
           title = nil,
           text = "Use @PLAYER to insert the name of the person you resurrected.\nUse @ME to insert your character name.\nUse @TIME to insert the time of resurrection.\nReload UI to see changes in the example invoice."
       },
       {
          type = "header",
          name = "EXAMPLE INVOICE",
          width = "full",
       },
       {
           type = "description",
           text = "\n" .. GenerateMailboxMessage("@skineh", 2)
       }
    }
    LAM:RegisterOptionControls(T.name, optionsTable)
end

local function DoesUserShareGuild(displayName)
    for i=1, 5, 1 do
        local guildId = GetGuildId(i)
        local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
        if memberIndex ~= nil and memberIndex > 0 then
            return true
        end
    end
    return false
end

local function AddToTally(displayName)
    if pending[displayName] ~= nil then
        pending[displayName] = pending[displayName] + 1
    else
        pending[displayName] = 1
    end
end

local function OnResurrectResult(eventCode, targetCharacterName, result, targetDisplayName)
    if savedVariables.resValid.type == 4 then
        return
    end

    if savedVariables.dungeonOnly and not inDungeon then
        return
    end

    if savedVariables.guildOnly then
        local inGuild = DoesUserShareGuild("@" .. targetDisplayName)
        if not inGuild then return end
    end

    if savedVariables.groupValid.type ~= 3 then
        local valid = false
        local inGroup = IsUnitGrouped("player")
        if inGroup then
            local targetInGroup = false
            local groupSize = GetGroupSize()
            local charName
            for i=1, groupSize, 1 do
                charName = GetUnitName(GetGroupUnitTagByIndex(i))
                if charName == targetCharacterName then
                    targetInGroup = true
                    break
                end
            end

            if targetInGroup and savedVariables.groupValid.type == 1 then
                valid = true
            elseif not targetInGroup and savedVariables.groupValid.type == 2 then
                valid = true
            end
        elseif savedVariables.groupValid.type == 2 then
            valid = true
        end

        if not valid then
            return
        end
    end

    local combatOkay = savedVariables.resValid.type == 3 or savedVariables.resValid.type == 1
    local noncombatOkay = savedVariables.resValid.type == 3 or savedVariables.resValid.type == 2

    if result == RESURRECT_RESULT_SUCCESS then
        if not inCombatNow and noncombatOkay then
            if savedVariables.tallyDungeon and inDungeon then
                AddToTally(targetDisplayName)
            else
                SendResMail(targetDisplayName, 1)
            end
        elseif inCombatNow and combatOkay then
            AddToTally(targetDisplayName)
        end
    end
end

local function SendPending()
    for k, v in pairs(pending) do
        if v >= savedVariables.minRes then
            SendResMail(k, v)
        end
    end
    pending = {}
end

local function OnScreenLoaded(eventCode, initial)
    if not savedVariables.tallyDungeon then return end

    local dungeon = IsUnitInDungeon("player")

    if not dungeon and inDungeon then
        SendPending()
    end

    inDungeon = dungeon
end

local function OnCombatChanged(eventCode, inCombat)
    inCombatNow = inCombat

    if not inCombat then
        if not savedVariables.tallyDungeon or not inDungeon then
            SendPending()
        end
    end
end

local function Init(event, name)
    if name ~= addonName then return end

    savedVariables = ZO_SavedVars:NewAccountWide("TYFYS_SavedVariables", 1, nil, defaults)

    CreateSettingsMenu()

    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_RESURRECT_RESULT, OnResurrectResult)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_COMBAT_STATE, OnCombatChanged)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnScreenLoaded)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED , Init)