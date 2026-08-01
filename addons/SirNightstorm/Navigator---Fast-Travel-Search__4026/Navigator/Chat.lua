local Nav = Navigator
local Chat = Nav.Chat or {
    lsc = nil,
    AutoCompleteProvider = nil,
    result = nil
}

function Chat:Init()
    self.lsc = LibSlashCommander
    if not self.lsc then
        return
    end

    local command = self.lsc:Register()
    command:AddAlias(Nav.saved.tpCommand)
    command:SetCallback(function(input) self:Submit(input) end)
    command:SetDescription(GetString(NAVIGATOR_SLASH_DESCRIPTION))

    ---@class Chat.AutoCompleteProvider
    Chat.AutoCompleteProvider = LibSlashCommander.AutoCompleteProvider:Subclass()

    function Chat.AutoCompleteProvider:New()
        return Chat.lsc.AutoCompleteProvider.New(self)
    end

    function Chat.AutoCompleteProvider:GetResultList()
        local zoneList = Nav.Locations:GetZoneList()
        local list = {}
        for i = 1, #zoneList do
            list[zoneList[i].name] = zoneList[i].name
        end
        Nav.log("Chat.AutoCompleteProvider:GetResultList: "..#list)
        return list
    end

    command:SetAutoComplete(self.AutoCompleteProvider:New())

    command.GetAutoCompleteResults = function(_, text)
        if text:sub(1, 1) == "*" then
            Chat.result = nil
            return {}
        end

        local result = Chat:Search(text)

        local results = result and { [result.name] = result.name } or {}

        return results
    end

    self.command = command
end

function Chat:Search(text)
    local searchResult
    local filter
    self.search = text
    self.result = nil

    if text:sub(1, 1) == "@" then
        filter = "players"
        text = text:sub(2)
    end

    if #text >= 1 then
        searchResult = Nav.Search:Run(text, filter)

        if searchResult and #searchResult >= 1 then
            self.result = searchResult[1]
        end
    end

    return self.result
end

function Chat:Submit(text)
    if text == "" then
        LibAddonMenu2:OpenToPanel(Nav.settingsPanel)
        return
    elseif text == "*logon" then
        Nav.saved.loggingEnabled = true
        CHAT_SYSTEM:AddMessage("Logging enabled")
        return
    elseif text == "*logoff" then
        Nav.saved.loggingEnabled = false
        CHAT_SYSTEM:AddMessage("Logging disabled")
        return
    elseif text == "*mapinfo" then
        local mapId = GetCurrentMapId()
        local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
        local zoneId = GetZoneId(zoneIndex)
        CHAT_SYSTEM:AddMessage(string.format("Current Map: mapId %d, zoneIndex %d, zoneId %d type %d", mapId, zoneIndex, zoneId, mapType))
        return
    end

    local result = self.result or self:Search(text)

    if not result then
        CHAT_SYSTEM:AddMessage(GetString(NAVIGATOR_HINT_NORESULTS))
        return
    end

    if result.OnSlash then
        result:OnSlash()
    elseif result.Jump then
        result:Jump()
    elseif result.JumpToPlayer then
        result:JumpToPlayer()
    elseif result.JumpToZone then
        result:JumpToZone()
    else
        CHAT_SYSTEM:AddMessage("Sorry, I wasn't able to process that result")
    end

    self.result = nil -- Forget autocomplete search result
end

Nav.Chat = Chat