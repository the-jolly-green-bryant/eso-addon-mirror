SavedChatMessages = SavedChatMessages or {}
local SCM = SavedChatMessages

SCM.name = "SavedChatMessages"

SCM.defaults = {
    namedMessages = {},
}

local function Print(message)
    d(string.format("[%s] %s", SCM.name, message))
end

local function NormalizeKey(key)
    if not key then
        return ""
    end

    return zo_strlower(zo_strtrim(key))
end

local function HasMethod(object, methodName)
    return type(object) == "table" and type(object[methodName]) == "function"
end

local function TrySafeConsoleStartTextEntry(message, channel, target)
    if type(ZO_GetChatSystem) ~= "function" then
        return false
    end

    if type(IsChatSystemAvailableForCurrentPlatform) == "function" and not IsChatSystemAvailableForCurrentPlatform() then
        return false
    end

    local isRestrictedCommunicationPermitted = true
    if target ~= nil and type(IsCommunicationRestricted) == "function" and IsCommunicationRestricted() then
        if type(CanCommunicateWith) == "function" then
            isRestrictedCommunicationPermitted = CanCommunicateWith(target)
        else
            isRestrictedCommunicationPermitted = false
        end
    end

    if not isRestrictedCommunicationPermitted then
        return false
    end

    local chatSystem = ZO_GetChatSystem()
    if not HasMethod(chatSystem, "StartTextEntry") then
        return false
    end

    -- dontShowHUDWindow=true avoids console-private SetSetting() path in gamepad chat.
    local ok, result = pcall(function()
        return chatSystem:StartTextEntry(message, channel, target, true)
    end)

    return ok and result ~= false
end

local function TryGlobalStartChatInput(message)
    if type(StartChatInput) ~= "function" then
        return false
    end

    local ok, result = pcall(function()
        return StartChatInput(message)
    end)

    return ok and result ~= false
end

local function GetSortedKeys(namedMessages)
    local keys = {}
    for key in pairs(namedMessages) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function SCM:EnsureSavedVarsShape()
    self.savedVariables.namedMessages = self.savedVariables.namedMessages or {}
end

function SCM:StoreNamedMessage(key, message)
    local normalizedKey = NormalizeKey(key)
    if normalizedKey == "" then
        Print("Usage: /scm save <name> <message>")
        return false
    end

    if not message or zo_strtrim(message) == "" then
        Print("Message cannot be empty.")
        return false
    end

    self.savedVariables.namedMessages[normalizedKey] = zo_strtrim(message)
    self:SyncRadialEntries()
    self:RefreshAddonSettings(true)
    Print(string.format("Saved message '%s'.", normalizedKey))
    return true
end

function SCM:RenameNamedMessage(oldKey, newKey, suppressSettingsRefresh)
    local normalizedOldKey = NormalizeKey(oldKey)
    local normalizedNewKey = NormalizeKey(newKey)

    if normalizedOldKey == "" or normalizedNewKey == "" then
        Print("Name cannot be empty.")
        return false
    end

    if self.savedVariables.namedMessages[normalizedOldKey] == nil then
        Print(string.format("No saved message found for '%s'.", normalizedOldKey))
        return false
    end

    if normalizedOldKey == normalizedNewKey then
        return true
    end

    if self.savedVariables.namedMessages[normalizedNewKey] ~= nil then
        Print(string.format("Name '%s' already exists.", normalizedNewKey))
        return false
    end

    local message = self.savedVariables.namedMessages[normalizedOldKey]
    self.savedVariables.namedMessages[normalizedNewKey] = message
    self.savedVariables.namedMessages[normalizedOldKey] = nil

    self:SyncRadialEntries()

    if not suppressSettingsRefresh then
        self:RefreshAddonSettings(true)
    end
    Print(string.format("Renamed name '%s' to '%s'.", normalizedOldKey, normalizedNewKey))
    return true
end

function SCM:DeleteNamedMessage(key, suppressSettingsRefresh)
    local normalizedKey = NormalizeKey(key)
    if normalizedKey == "" then
        Print("Usage: /scm delete <name>")
        return false
    end

    if self.savedVariables.namedMessages[normalizedKey] == nil then
        Print(string.format("No saved message found for '%s'.", normalizedKey))
        return false
    end

    self.savedVariables.namedMessages[normalizedKey] = nil

    self:SyncRadialEntries()

    if not suppressSettingsRefresh then
        self:RefreshAddonSettings(true)
    end
    Print(string.format("Deleted message '%s'.", normalizedKey))
    return true
end

function SCM:OpenMessageInChat(message)
    if not message or zo_strtrim(message) == "" then
        Print("Nothing to insert into chat.")
        return
    end

    if TrySafeConsoleStartTextEntry(message) then
        return
    end

    if TryGlobalStartChatInput(message) then
        return
    end

    Print("Unable to open chat input in current UI mode.")
    Print("Chat open was blocked by UI security. Please open chat manually and send.")
end

function SCM:UseNamedMessage(key)
    local normalizedKey = NormalizeKey(key)
    if normalizedKey == "" then
        Print("Usage: /scm use <name>")
        return false
    end

    local message = self.savedVariables.namedMessages[normalizedKey]
    if not message then
        Print(string.format("No saved message found for '%s'.", normalizedKey))
        return false
    end

    self:OpenMessageInChat(message)
    return true
end

function SCM:ListNamedMessages()
    local keys = GetSortedKeys(self.savedVariables.namedMessages)
    if #keys == 0 then
        Print("No named messages saved.")
        return
    end

    Print("Named messages:")
    for _, key in ipairs(keys) do
        local message = self.savedVariables.namedMessages[key] or ""
        Print(string.format(" - %s: %s", key, message))
    end
end

function SCM:PrintHelp()
    Print("Commands:")
    Print(" /scm help")
    Print(" /scm list")
    Print(" /scm save <name> <message>")
    Print(" /scm use <name>")
    Print(" /scm delete <name>")
    Print(" /scm <name> (shortcut for /scm use <name>)")
end

function SCM:HandleSlashCommand(rawInput)
    local input = zo_strtrim(rawInput or "")
    if input == "" then
        self:PrintHelp()
        return
    end

    local command, rest = input:match("^(%S+)%s*(.*)$")
    command = NormalizeKey(command)

    if command == "help" then
        self:PrintHelp()
        return
    end

    if command == "list" then
        self:ListNamedMessages()
        return
    end

    if command == "save" then
        local key, message = rest:match("^(%S+)%s+(.+)$")
        self:StoreNamedMessage(key, message)
        return
    end

    if command == "delete" then
        self:DeleteNamedMessage(rest)
        return
    end

    if command == "use" then
        self:UseNamedMessage(rest)
        return
    end

    -- Treat unknown commands as quick name lookups for convenience.
    self:UseNamedMessage(command)
end

function SCM:RegisterSlashCommands()
    SLASH_COMMANDS["/scm"] = function(text)
        self:HandleSlashCommand(text)
    end
end

function SCM:RegisterRadialEntry(key, forcedEntryId)
    if not self.radialMenu then
        return
    end

    local normalizedKey = NormalizeKey(key)
    if normalizedKey == "" then
        return
    end

    local entryId = forcedEntryId or self.radialKeyToEntryId[normalizedKey] or ("scm:" .. normalizedKey)

    local entryIcon = "/esoui/art/chatwindow/chat_mail_up.dds"
    local entryDescription = string.format("Insert saved message '%s' into chat.", normalizedKey)
    self.radialMenu:RegisterEntry(
        self.name,
        normalizedKey,
        entryId,
        entryIcon,
        function()
            self:UseNamedMessage(normalizedKey)
        end,
        entryDescription
    )

    local previousKey = self.radialEntryIdToKey[entryId]
    if previousKey and previousKey ~= normalizedKey then
        self.radialKeyToEntryId[previousKey] = nil
    end

    self.radialKeyToEntryId[normalizedKey] = entryId
    self.radialEntryIdToKey[entryId] = normalizedKey
    self.radialRegisteredEntries[entryId] = true
end

function SCM:SyncRadialEntries()
    if not self.radialMenu then
        return
    end

    local previousKeyToEntryId = self.radialKeyToEntryId or {}

    -- LibRadialMenu has register APIs but no public remove API.
    -- Re-registering the addon clears its entry table, then we add current entries back.
    self.radialMenu:RegisterAddon(self.name, "Saved Chat Messages")
    self.radialRegisteredEntries = {}
    self.radialKeyToEntryId = {}
    self.radialEntryIdToKey = {}

    local keys = GetSortedKeys(self.savedVariables.namedMessages)
    for _, key in ipairs(keys) do
        local forcedEntryId = previousKeyToEntryId[key]
        self:RegisterRadialEntry(key, forcedEntryId)
    end
end

function SCM:RefreshAddonSettings(forceRebuild)
    if not self.addonSettingsPanel then
        return
    end

    if forceRebuild and self.addonSettingsPanel.selected and HasMethod(self.addonSettingsPanel, "CleanUp") and HasMethod(self.addonSettingsPanel, "CreateControls") then
        self.addonSettingsPanel:CleanUp()
        self.addonSettingsPanel:CreateControls()
        self:EnsureSettingsMessageListControlPatched()

        if HasMethod(self.addonSettingsPanel, "RefreshSelection") then
            self.addonSettingsPanel:RefreshSelection()
        end
        return
    end

    if HasMethod(self.addonSettingsPanel, "RefreshSettings") then
        self.addonSettingsPanel:RefreshSettings()
        self:EnsureSettingsMessageListControlPatched()
        return
    end

    if HasMethod(self.addonSettingsPanel, "RefreshPanel") then
        self.addonSettingsPanel:RefreshPanel()
        self:EnsureSettingsMessageListControlPatched()
    end
end

function SCM:ResetSettingsEditor()
    if not self.ui then
        return
    end

    self.ui.selectedName = self.ui.addNewOptionLabel
    self.ui.editorSourceKey = nil
    self.ui.editorName = ""
    self.ui.editorMessage = ""
end

function SCM:SelectFirstSavedMessageForEditor()
    if not self.ui then
        return
    end

    local keys = GetSortedKeys(self.savedVariables.namedMessages)
    if #keys == 0 then
        self:ResetSettingsEditor()
        return
    end

    self:SetSettingsSelectedName(keys[1])
end

function SCM:SetSettingsSelectedName(name)
    if not self.ui then
        return
    end

    local selectedName = name or self.ui.addNewOptionLabel
    if selectedName == self.ui.addNewOptionLabel then
        self:ResetSettingsEditor()
        return
    end

    local normalizedName = NormalizeKey(selectedName)
    local message = self.savedVariables.namedMessages[normalizedName]
    if message == nil then
        self:ResetSettingsEditor()
        return
    end

    self.ui.selectedName = normalizedName
    self.ui.editorSourceKey = normalizedName
    self.ui.editorName = normalizedName
    self.ui.editorMessage = message
end

function SCM:GetSettingsNameItems()
    local items = {}
    local keys = GetSortedKeys(self.savedVariables.namedMessages)
    for _, key in ipairs(keys) do
        table.insert(items, { name = key })
    end
    table.insert(items, { name = self.ui.addNewOptionLabel })
    return items
end

function SCM:GetSettingsSelectedName()
    if not self.ui then
        return ""
    end

    local selectedName = self.ui.selectedName
    if selectedName == self.ui.addNewOptionLabel then
        return selectedName
    end

    local normalizedName = NormalizeKey(selectedName)
    if normalizedName ~= "" and self.savedVariables.namedMessages[normalizedName] ~= nil then
        return normalizedName
    end

    self:ResetSettingsEditor()
    return self.ui.addNewOptionLabel
end

function SCM:GetSelectedExistingName()
    if not self.ui then
        return nil
    end

    local selectedName = self.ui.selectedName
    if selectedName and selectedName ~= self.ui.addNewOptionLabel then
        local normalizedSelectedName = NormalizeKey(selectedName)
        if normalizedSelectedName ~= "" and self.savedVariables.namedMessages[normalizedSelectedName] ~= nil then
            return normalizedSelectedName
        end
    end

    return nil
end

function SCM:RefreshSettingsEditorControls()
    if not self.ui then
        return
    end

    self:EnsureSettingsMessageListControlPatched()

    if self.settingsNameControl then
        self.settingsNameControl:SetValue(self.ui.editorName or "")
    end

    if self.settingsMessageControl then
        self.settingsMessageControl:SetValue(self.ui.editorMessage or "")
    end

    if self.settingsDeleteControl then
        self.settingsDeleteControl:SetEnabled(not self.settingsDeleteControl:IsDisabled())
    end
end

function SCM:EnsureSettingsMessageListControlPatched()
    local setting = self.settingsMessageListControl
    if not setting or not setting.control or setting.control.scmPatched then
        return
    end

    local control = setting.control
    local originalDeactivate = control.Deactivate

    control.Deactivate = function(controlSelf)
        setting:SetValue(self:GetSettingsSelectedName())
        originalDeactivate(controlSelf)
        setting:SetValue(self:GetSettingsSelectedName())
    end

    control.scmPatched = true
end

function SCM:SaveSettingsEditor()
    if not self.ui then
        return false
    end

    local normalizedName = NormalizeKey(self.ui.editorName)
    local trimmedMessage = zo_strtrim(self.ui.editorMessage or "")
    local normalizedSourceKey = NormalizeKey(self.ui.editorSourceKey)
    local normalizedSelectedName = self:GetSelectedExistingName()
    if normalizedSourceKey == "" then
        normalizedSourceKey = normalizedSelectedName
    end
    if normalizedSourceKey == "" then
        normalizedSourceKey = nil
    end

    if normalizedName == "" then
        Print("Name cannot be empty.")
        return false
    end

    if trimmedMessage == "" then
        Print("Message cannot be empty.")
        return false
    end

    if normalizedSourceKey and normalizedSourceKey ~= normalizedName then
        if not self:RenameNamedMessage(normalizedSourceKey, normalizedName, true) then
            return false
        end
    elseif not normalizedSourceKey and self.savedVariables.namedMessages[normalizedName] ~= nil then
        Print(string.format("Name '%s' already exists.", normalizedName))
        return false
    end

    self.savedVariables.namedMessages[normalizedName] = trimmedMessage
    self:SyncRadialEntries()
    self.ui.selectedName = normalizedName
    self.ui.editorSourceKey = normalizedName
    self.ui.editorName = normalizedName
    self.ui.editorMessage = trimmedMessage
    self:RefreshAddonSettings(true)
    Print(string.format("Saved message '%s'.", normalizedName))
    return true
end

function SCM:DeleteSettingsEditor()
    if not self.ui then
        return false
    end

    local normalizedSourceKey = self:GetSelectedExistingName() or NormalizeKey(self.ui.editorSourceKey)
    if normalizedSourceKey == "" then
        Print("No saved message selected.")
        return false
    end

    if not self:DeleteNamedMessage(normalizedSourceKey, true) then
        return false
    end

    self:ResetSettingsEditor()
    self:RefreshAddonSettings(true)
    return true
end

function SCM:RegisterRadialMenu()
    local radialMenu = LibRadialMenu
    if not radialMenu then
        return
    end

    if type(radialMenu.RegisterAddon) ~= "function" or type(radialMenu.RegisterEntry) ~= "function" then
        Print("LibRadialMenu detected, but API did not match expected functions.")
        return
    end

    self.radialMenu = radialMenu
    self.radialRegisteredEntries = {}
    self.radialKeyToEntryId = {}
    self.radialEntryIdToKey = {}
    self:SyncRadialEntries()
end

function SCM:RegisterAddonMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then
        Print("LibHarvensAddonSettings not found. Settings panel is disabled.")
        return
    end

    self.ui = self.ui or {
        addNewOptionLabel = "Add New Message",
        selectedName = "Add New Message",
        editorSourceKey = nil,
        editorName = "",
        editorMessage = "",
    }

    local panel = LHAS:AddAddon("Saved Chat Messages", {
        allowDefaults = false,
        allowRefresh = true,
    })
    if not panel or type(panel.AddSetting) ~= "function" then
        Print("LibHarvensAddonSettings panel could not be created.")
        return
    end

    self.addonSettingsPanel = panel
    self:SelectFirstSavedMessageForEditor()

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Messages",
    })

    panel:AddSetting({
        type = LHAS.ST_LABEL,
        label = "Select a saved name to edit it, or choose Add New Message.",
    })

    self.settingsMessageListControl = panel:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Messages List",
        items = function()
            return self:GetSettingsNameItems()
        end,
        getFunction = function()
            return self:GetSettingsSelectedName()
        end,
        setFunction = function(_, itemName, itemData)
            local selectedName = itemName
            if itemData and itemData.name then
                selectedName = itemData.name
            end
            self:SetSettingsSelectedName(selectedName)
            self:RefreshSettingsEditorControls()
        end,
    })

    self.settingsNameControl = panel:AddSetting({
        type = LHAS.ST_EDIT,
        label = "Name",
        getFunction = function()
            return self.ui.editorName or ""
        end,
        setFunction = function(value)
            self.ui.editorName = value or ""
        end,
    })

    self.settingsMessageControl = panel:AddSetting({
        type = LHAS.ST_EDIT,
        label = "Message",
        getFunction = function()
            return self.ui.editorMessage or ""
        end,
        setFunction = function(value)
            self.ui.editorMessage = value or ""
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Save",
        buttonText = "Save Message",
        clickHandler = function()
            self:SaveSettingsEditor()
        end,
    })

    self.settingsDeleteControl = panel:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Delete",
        buttonText = "Delete Message",
        disable = function()
            return NormalizeKey(self.ui.editorSourceKey) == ""
        end,
        clickHandler = function()
            self:DeleteSettingsEditor()
        end,
    })
end

function SCM:Initialize()
    self.savedVariables = ZO_SavedVars:NewAccountWide("SavedChatMessagesSavedVariables", 1, nil, self.defaults)
    self:EnsureSavedVarsShape()
    self:RegisterSlashCommands()
    self:RegisterRadialMenu()
    self:RegisterAddonMenu()

    Print("Loaded. Type /scm help for commands.")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= SCM.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(SCM.name, EVENT_ADD_ON_LOADED)
    SCM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(SCM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
