local lib = {}
LibSlashCommander = lib
lib.loadedFiles = {}
function lib:AddFile(file, version, callback)
    if (not lib.loadedFiles[file] or version > lib.loadedFiles[file]) then
        callback(lib)
        lib.loadedFiles[file] = version
    end
end

function lib:Register(aliases, callback, description)
    local command = lib.Command:New()
    if (callback) then
        command:SetCallback(callback)
    end
    if (description) then
        command:SetDescription(description)
    end

    if (aliases) then
        if (type(aliases) == "table") then
            for i = 1, #aliases do
                command:AddAlias(aliases[i])
            end
        else
            command:AddAlias(aliases)
        end
    end

    lib.globalCommand:RegisterSubCommand(command)
    return command
end

function lib:Unregister(command)
    lib.globalCommand:UnregisterSubCommand(command)
end

local function RunAutoCompletion(self, command, text)
    self.ignoreTextEntryChangedEvent = true
    lib.currentCommand = command
    self.textEntry:AutoCompleteTarget(text)
    self.ignoreTextEntryChangedEvent = false
end

local function GetCurrentCommandAndToken(command, input)
    local alias, newInput = input:match("(.-)%s+(.-)$")
    if (not alias or not lib.IsCommand(command)) then return command, input end
    local subCommand = command:GetSubCommandByAlias(alias)
    if (not subCommand) then return command, input end
    if (not newInput) then return subCommand, "" end
    return GetCurrentCommandAndToken(subCommand, newInput)
end

local function Sanitize(value)
    return value:gsub("[-*+?^$().[%]%%]", "%%%0") -- escape meta characters
end

local function OnTextEntryChanged(self, text)
    if (self.ignoreTextEntryChangedEvent or not lib.globalCommand:ShouldAutoComplete(text)) then return end
    lib.currentCommand = nil

    local command, token = GetCurrentCommandAndToken(lib.globalCommand, text)
    if (not command or not lib.IsCommand(command)) then return end

    lib.lastInput = text:match(string.format("(.+)%%s+%s$", Sanitize(token)))
    if (command:ShouldAutoComplete(token)) then
        RunAutoCompletion(self, command, token)
        return true
    end
end

local function OnSetChannel(self)
    self.textEntry:CloseAutoComplete()
end

local function StartCommandAtIndex(originalStartCommandAtIndex, self, index)
    originalStartCommandAtIndex(self, index)
    self:CloseAutoComplete()
end

local function AutocompleteOnTextChanged(originalOnTextChanged, self)
    local wasEnabled = self.enabled
    self.enabled = false
    originalOnTextChanged(self)
    self.enabled = wasEnabled
end

local function OnAutoCompleteEntrySelected(self, text)
    local command = lib.hasCustomResults
    if (command) then
        text = command:GetAutoCompleteResultFromDisplayText(text)
        if (lib.lastInput) then
            text = string.format("%s %s", lib.lastInput, text)
            lib.lastInput = nil
        else
            text = string.format("%s ", text)
        end
        lib.SafeStartChatInput(text)
        return true
    end
end

local function GetTopMatches(command, text)
    local results = command:GetAutoCompleteResults(text)
    local topResults = GetTopMatchesByLevenshteinSubStringScore(results, text, 1, lib.maxResults, true)
    if topResults then
        return unpack(topResults)
    end
end

local function GetAutoCompletionResults(original, self, text)
    local command = lib.currentCommand
    if (command) then
        lib.hasCustomResults = command
        return GetTopMatches(command, text)
    else
        lib.hasCustomResults = nil
        return original(self, text)
    end
end

local function GetDescriptionText(alias)
    local description = lib.descriptions[alias]
    if (lib.IsCallable(description)) then
        return description()
    end
    return description
end

function lib:FormatLabel(alias, description, type)
    local color = lib.typeColor[type or lib.COMMAND_TYPE_ADDON] or ""
    if (description) then
        return string.format("%s%s|caaaaaa - %s", color, alias, description)
    end
    return string.format("%s%s", color, alias)
end

function lib:GenerateLabel(alias, description)
    if (not description) then description = GetDescriptionText(alias) end
    return lib:FormatLabel(alias, description, lib.types[alias])
end

function lib.SafeStartChatInput(text, channel, target)
    local isRestrictedCommunicationPermitted = true
    if target ~= nil and IsCommunicationRestricted() then
        isRestrictedCommunicationPermitted = CanCommunicateWith(target)
    end
    if IsChatSystemAvailableForCurrentPlatform() and isRestrictedCommunicationPermitted then
        ZO_GetChatSystem():StartTextEntry(text, channel, target, true)
    end
end

local function SetupChatSystem(chatSystem)
    local textEntry = chatSystem.textEntry
    local targetAutoComplete = textEntry.targetAutoComplete
    local slashCommandAutoComplete = textEntry.slashCommandAutoComplete

    ZO_PreHook(chatSystem, "OnTextEntryChanged", OnTextEntryChanged)
    ZO_PreHook(chatSystem, "SetChannel", OnSetChannel)
    ZO_PreHook(chatSystem, "OnAutoCompleteEntrySelected", OnAutoCompleteEntrySelected)
    lib.WrapFunction(targetAutoComplete, "GetAutoCompletionResults", GetAutoCompletionResults)
    lib.WrapFunction(textEntry, "StartCommandAtIndex", StartCommandAtIndex)
    lib.WrapFunction(slashCommandAutoComplete, "OnTextChanged", AutocompleteOnTextChanged)
end

lib.GetCurrentCommandAndToken = GetCurrentCommandAndToken
lib.Init = function()
    lib.Init = function() end

    if KEYBOARD_CHAT_SYSTEM then SetupChatSystem(KEYBOARD_CHAT_SYSTEM) end
    if GAMEPAD_CHAT_SYSTEM then SetupChatSystem(GAMEPAD_CHAT_SYSTEM) end

    local switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
    lib.globalCommand = lib.Command:New()
    lib.globalCommand.subCommandAliases = setmetatable({}, {
        __index = function(_, key)
            key = zo_strlower(key)
            -- use the globals on the off chance an addon replaces them
            return SLASH_COMMANDS[key] or switchLookup[key]
        end,
        __newindex = function(_, key, value)
            SLASH_COMMANDS[key] = value
        end
    })
    lib.globalCommand:SetAutoComplete(lib.AutoCompleteSlashCommandsProvider:New())
end
