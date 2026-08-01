local ET = EasyTravel
local internal = ET.internal
local PlayerList = ET.class.PlayerList
local chat = internal.chat
local gettext = internal.gettext
-- TRANSLATORS: Value used to refer to the primary home in slash commands
local HOME_LABEL = gettext("home")

local SlashCommandHelper = ZO_InitializingObject:Subclass()
ET.class.SlashCommandHelper = SlashCommandHelper

function SlashCommandHelper:Initialize(zoneList, playerList, jumpHelper)
    self.zoneList = zoneList
    self.playerList = playerList
    self.jumpHelper = jumpHelper
    self.resultList = {}
    self.playerLookup = {}
    self.zoneLookup = {}
    self.houseLookup = {}
    self.dirty = true

    playerList:RegisterCallback(PlayerList.SET_DIRTY, function()
        self.dirty = true
    end)

    local LSC = LibSlashCommander
    local this = self

    local EasyTravelAutoCompleteProvider = LSC.AutoCompleteProvider:Subclass()
    function EasyTravelAutoCompleteProvider:New()
        return LSC.AutoCompleteProvider.New(self)
    end

    function EasyTravelAutoCompleteProvider:GetResultList()
        return this:AutoCompleteResultProvider()
    end

    function EasyTravelAutoCompleteProvider:GetResultFromLabel(label)
        return this:AutoCompleteResultLookup(label)
    end

    local function SlashCommandCallback(input)
        return self:SlashCommandCallback(input)
    end
    self.autocompleteResultProvider = EasyTravelAutoCompleteProvider

    -- TRANSLATORS: comma-separated list of slash commands for EasyTravel
    local commands = {zo_strsplit(",", gettext("/tp,/travel,/goto"))}
    -- TRANSLATORS: description of the slash commands in the autocomplete list
    self.command = LSC:Register(commands, SlashCommandCallback, gettext("Travel to the specified target"))
    self.command:SetAutoComplete(EasyTravelAutoCompleteProvider:New())
end

function SlashCommandHelper:SlashCommandCallback(input, isTopResult)
    local zoneList = self.zoneList
    local playerList = self.playerList
    local jumpHelper = self.jumpHelper
    if(not isTopResult) then
        playerList:Rebuild()
    end
    if(input == HOME_LABEL and GetHousingPrimaryHouse() > 0) then
        jumpHelper:JumpToHouse(GetHousingPrimaryHouse())
        return
    elseif(zoneList:HasZone(input)) then
        local zone = zoneList:GetZoneByZoneName(input)
        jumpHelper:JumpTo(zone)
        return
    elseif(zoneList:HasHouse(input)) then
        local house = zoneList:GetHouseByName(input)
        jumpHelper:JumpToHouse(house.houseId)
        return
    elseif(playerList:HasDisplayName(input) or playerList:HasCharacterName(input)) then
        local player = playerList:GetPlayerByDisplayName(input) or playerList:GetPlayerByCharacterName(input)
        jumpHelper:JumpToPlayer(player)
        return
    elseif(input == "") then
        if(IsUnitGrouped("player") and not IsUnitGroupLeader("player")) then
            jumpHelper:JumpToGroupLeader()
        else
            local zone = zoneList:GetCurrentZone()
            if(not zone) then -- TODO: remember last zone we have been in and jump there instead
                self:PrintInvalidTargetMessage()
            else
                jumpHelper:JumpTo(zone)
            end
        end
        return
    elseif(not isTopResult) then
        local results = self.autocompleteResultProvider:GetResultList()
        local matches = GetTopMatchesByLevenshteinSubStringScore(results, input, 1, 1, true)

        if(#matches > 0) then
            local target = self.autocompleteResultProvider:GetResultFromLabel(matches[1])
            return self:SlashCommandCallback(target, true)
        end
    end

    self:PrintInvalidTargetMessage()
end

function SlashCommandHelper:PrintInvalidTargetMessage()
    -- TRANSLATORS: chat message when a target specified via slash command is not valid
    chat:Print(gettext("Target cannot be reached via jump"))
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

function SlashCommandHelper:GetPlayerResults()
    local playerList = {}
    local players = self.playerList:GetPlayerList()
    ZO_ClearTable(self.playerLookup)

    for lower, player in pairs(players) do
        -- TRANSLATORS: template for showing player entries in the slash command auto complete list. <<1>> is the character name, <<2>> the account name and <<3>> the name of the zone they are currently in.
        local label = zo_strformat(gettext("<<1>><<2>> -|caaaaaa <<3>>"), player.characterName, player.displayName, player.zone.name)
        playerList[zo_strlower(player.characterName .. player.displayName)] = label
        self.playerLookup[label] = player.displayName
    end

    return playerList
end

function SlashCommandHelper:GetZoneResults()
    local zoneList = {}
    local zones = self.zoneList:GetZoneList()
    ZO_ClearTable(self.zoneLookup)

    for zoneName, zone in pairs(zones) do
        local count = self.playerList:GetPlayerCountForZone(zone)
        -- TRANSLATORS: template for showing zone entries in the slash command auto complete list. <<1>> is the zone name, <<2>> the number of players currently in the zone.
        local label = zo_strformat(gettext("<<1>> -|caaaaaa <<2[no players/$d player/$d players]>>"), zoneName, count)
        zoneList[zo_strlower(zoneName)] = label
        self.zoneLookup[label] = zoneName
    end

    return zoneList
end

function SlashCommandHelper:GetHouseResults()
    local houseList = {}
    local houses = self.zoneList:GetHouseList()
    ZO_ClearTable(self.houseLookup)

    -- TRANSLATORS: template for showing owned housing entries in the slash command auto complete list. <<1>> is the name of the house, <<2>> the name of the zone the house is found in.
    local UNLOCKED_HOME_TEMPLATE = gettext("<<1>> -|caaaaaa <<2>>")
    -- TRANSLATORS: template for showing unowned housing entries in the slash command auto complete list. <<1>> is the name of the house, <<2>> the name of the zone the house is found in.
    local LOCKED_HOME_TEMPLATE = gettext("<<1>> -|caaaaaa <<2>> (preview)")
    for houseName, house in pairs(houses) do
        local zoneName = house.foundInZoneName

        local template = house.unlocked and UNLOCKED_HOME_TEMPLATE or LOCKED_HOME_TEMPLATE
        local label = zo_strformat(template, houseName, zoneName)
        houseList[zo_strlower(houseName)] = label
        self.houseLookup[label] = houseName
        if(IsPrimaryHouse(house.houseId)) then
            -- TRANSLATORS: template for showing the housing entry of the primary home in the slash command auto complete list. <<1>> is the localized value referring to the primary home in slash commands (e.g. home), <<2>> the name of the house and <<3>> the name of the zone the house is found in.
            local label = zo_strformat(gettext("<<1>> -|caaaaaa <<2>>, <<3>>"), HOME_LABEL, houseName, zoneName)
            houseList[zo_strlower(HOME_LABEL)] = label
            self.houseLookup[label] = HOME_LABEL
        end
    end

    return houseList
end

function SlashCommandHelper:AutoCompleteResultProvider()
    if(self.dirty) then
        ZO_ClearTable(self.resultList)
        ZO_ShallowTableCopy(self:GetPlayerResults(), self.resultList)
        ZO_ShallowTableCopy(self:GetZoneResults(), self.resultList)
        ZO_ShallowTableCopy(self:GetHouseResults(), self.resultList)
        self.dirty = false
    end
    return self.resultList
end

function SlashCommandHelper:AutoCompleteResultLookup(label)
    return self.playerLookup[label] or self.zoneLookup[label] or self.houseLookup[label] or label
end
