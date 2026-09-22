local ua = UAssistant

ua.Profiles = ua.Profiles or {}

local profiles = ua.Profiles

local PROFILE_SYSTEM_VERSION = 1
local CHARACTER_PROFILE_VERSION = 1
local COPY_DIALOG = "UA_CONFIRM_COPY_PROFILE"
local DELETE_DIALOG = "UA_CONFIRM_DELETE_PROFILE"

local GLOBAL_KEYS = {
    language = true,
    showWelcome = true,
    accountWide = true,
    profileSystemVersion = true,
    characterProfiles = true,
}

local selectedCopyProfileId
local selectedDeleteProfileId

local function L(key)
    return ua.GetString(key)
end

local function GetCurrentCharacterIdString()
    local characterId = GetCurrentCharacterId()

    if Id64ToString then
        return Id64ToString(characterId)
    end

    return tostring(characterId)
end

local function GetCurrentCharacterName()
    local name = GetRawUnitName("player")

    if not name or name == "" then
        name = GetUnitName("player")
    end

    return zo_strformat(SI_UNIT_NAME, name)
end

local function GetStoredWorldSettings()
    local savedRoot = _G["UAssistantSavedVariables"]
    local profileData = savedRoot and savedRoot["Default"]
    local displayData = profileData and profileData[GetDisplayName()]
    local accountData = displayData and displayData["$AccountWide"]

    return accountData and accountData[GetWorldName()]
end

local function ReplaceProfileSettings(target, source)
    local defaults = ua.GetAccountDefaults()

    for key in pairs(target) do
        if not GLOBAL_KEYS[key] then
            target[key] = nil
        end
    end

    for key, defaultValue in pairs(defaults) do
        if not GLOBAL_KEYS[key] then
            local value = source and source[key]

            if value == nil then
                value = defaultValue
            end

            if type(value) == "table" then
                target[key] = ZO_DeepTableCopy(value)
            else
                target[key] = value
            end
        end
    end
end

local function CreateProfileSettings()
    local settings = {}
    ReplaceProfileSettings(settings)
    return settings
end

local function EnsureCurrentCharacterProfile()
    local storage = ua.profileStorage
    local characterId = GetCurrentCharacterIdString()
    local entry = storage.characterProfiles[characterId]

    if type(entry) ~= "table" then
        entry = {
            name = GetCurrentCharacterName(),
            profileVersion = CHARACTER_PROFILE_VERSION,
            settings = CreateProfileSettings(),
        }
        storage.characterProfiles[characterId] = entry
    end

    entry.name = GetCurrentCharacterName()

    if type(entry.settings) ~= "table" or entry.profileVersion ~= CHARACTER_PROFILE_VERSION then
        entry.settings = CreateProfileSettings()
    end

    entry.profileVersion = CHARACTER_PROFILE_VERSION

    return entry
end

local function GetCharacterProfileChoices()
    local choices = {}
    local values = {}
    local entries = {}
    local currentId = GetCurrentCharacterIdString()

    for characterId, entry in pairs(ua.profileStorage.characterProfiles) do
        if
            type(entry) == "table"
            and type(entry.settings) == "table"
            and characterId ~= currentId
        then
            table.insert(entries, {
                id = characterId,
                name = entry.name or characterId,
            })
        end
    end

    table.sort(entries, function(left, right)
        return zo_strlower(left.name) < zo_strlower(right.name)
    end)

    for _, entry in ipairs(entries) do
        table.insert(choices, entry.name)
        table.insert(values, entry.id)
    end

    return choices, values
end

local function GetActiveProfileName()
    if ua.profileStorage.accountWide then
        return L("PROFILE_ACCOUNT_WIDE")
    end

    return GetCurrentCharacterName()
end

local function GetActiveProfileTarget()
    if ua.profileStorage.accountWide then
        return ua.profileStorage
    end

    return EnsureCurrentCharacterProfile().settings
end

local function CopySelectedProfile(profileId)
    local entry = ua.profileStorage.characterProfiles[profileId]

    if not entry or type(entry.settings) ~= "table" then
        return
    end

    ReplaceProfileSettings(GetActiveProfileTarget(), entry.settings)
    ReloadUI()
end

local function DeleteSelectedProfile(profileId)
    if profileId == GetCurrentCharacterIdString() then
        return
    end

    ua.profileStorage.characterProfiles[profileId] = nil
    ReloadUI()
end

local function RegisterDialogs()
    ZO_Dialogs_RegisterCustomDialog(COPY_DIALOG, {
        canQueue = true,
        title = { text = "" },
        mainText = { text = "" },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    CopySelectedProfile(dialog.data.profileId)
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(DELETE_DIALOG, {
        canQueue = true,
        title = { text = "" },
        mainText = { text = "" },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    DeleteSelectedProfile(dialog.data.profileId)
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })
end

local function ShowCopyDialog(profileId)
    local entry = ua.profileStorage.characterProfiles[profileId]

    if not entry then
        return
    end

    local dialog = ESO_Dialogs[COPY_DIALOG]
    dialog.title.text = L("PROFILE_COPY_CONFIRM_TITLE")
    dialog.mainText.text = string.format(
        L("PROFILE_COPY_CONFIRM_TEXT"),
        entry.name,
        GetActiveProfileName(),
        GetActiveProfileName()
    )

    ZO_Dialogs_ShowDialog(COPY_DIALOG, {
        profileId = profileId,
    })
end

local function ShowDeleteDialog(profileId)
    local entry = ua.profileStorage.characterProfiles[profileId]

    if not entry then
        return
    end

    local dialog = ESO_Dialogs[DELETE_DIALOG]
    dialog.title.text = L("PROFILE_DELETE_CONFIRM_TITLE")
    dialog.mainText.text = string.format(L("PROFILE_DELETE_CONFIRM_TEXT"), entry.name)

    ZO_Dialogs_ShowDialog(DELETE_DIALOG, {
        profileId = profileId,
    })
end

function profiles.HasStoredProfileSystem()
    local storedSettings = GetStoredWorldSettings()

    return storedSettings
        and rawget(storedSettings, "profileSystemVersion") == PROFILE_SYSTEM_VERSION
end

function profiles.Initialize(hadProfileSystem)
    local storage = ua.profileStorage

    if type(storage.characterProfiles) ~= "table" then
        storage.characterProfiles = {}
    end

    if not hadProfileSystem then
        storage.accountWide = true
    else
        storage.accountWide = storage.accountWide ~= false
    end

    storage.profileSystemVersion = PROFILE_SYSTEM_VERSION

    if storage.accountWide then
        ua.savedVariables = storage
    else
        ua.savedVariables = EnsureCurrentCharacterProfile().settings
    end

    RegisterDialogs()
end

function profiles.ResetActiveSettings()
    ReplaceProfileSettings(GetActiveProfileTarget(), ua.GetAccountDefaults())
end

function profiles.CreateMenuControl()
    local activeName = GetActiveProfileName()
    local copyChoices, copyValues = GetCharacterProfileChoices()
    local deleteChoices, deleteValues = GetCharacterProfileChoices()

    selectedCopyProfileId = copyValues[1]
    selectedDeleteProfileId = deleteValues[1]

    return {
        type = "submenu",
        name = L("PROFILE_SETTINGS"),
        tooltip = L("PROFILE_SETTINGS_TOOLTIP"),
        controls = {
            {
                type = "checkbox",
                name = L("ACCOUNT_WIDE"),
                tooltip = L("ACCOUNT_WIDE_TOOLTIP"),
                getFunc = function()
                    return ua.profileStorage.accountWide
                end,
                setFunc = function(value)
                    if value == false then
                        EnsureCurrentCharacterProfile()
                    end

                    ua.profileStorage.accountWide = value
                end,
                default = true,
                requiresReload = true,
            },
            { type = "divider" },
            {
                type = "dropdown",
                name = L("ACTIVE_PROFILE"),
                tooltip = L("ACTIVE_PROFILE_TOOLTIP"),
                choices = { activeName },
                choicesValues = { activeName },
                getFunc = function()
                    return activeName
                end,
                setFunc = function() end,
                disabled = function()
                    return ua.profileStorage.accountWide
                end,
            },
            { type = "divider" },
            {
                type = "dropdown",
                name = L("COPY_SETTINGS_FROM"),
                tooltip = L("COPY_SETTINGS_FROM_TOOLTIP"),
                choices = copyChoices,
                choicesValues = copyValues,
                getFunc = function()
                    return selectedCopyProfileId
                end,
                setFunc = function(value)
                    selectedCopyProfileId = value
                end,
                disabled = #copyValues == 0,
                width = "half",
            },
            {
                type = "button",
                name = L("CONFIRM_COPY"),
                tooltip = L("CONFIRM_COPY_TOOLTIP"),
                func = function()
                    ShowCopyDialog(selectedCopyProfileId)
                end,
                disabled = function()
                    return selectedCopyProfileId == nil
                end,
                width = "half",
            },
            { type = "divider" },
            {
                type = "dropdown",
                name = L("DELETE_PROFILE"),
                tooltip = L("DELETE_PROFILE_TOOLTIP"),
                choices = deleteChoices,
                choicesValues = deleteValues,
                getFunc = function()
                    return selectedDeleteProfileId
                end,
                setFunc = function(value)
                    selectedDeleteProfileId = value
                end,
                disabled = #deleteValues == 0,
                width = "half",
            },
            {
                type = "button",
                name = L("CONFIRM_DELETE"),
                tooltip = L("CONFIRM_DELETE_TOOLTIP"),
                func = function()
                    ShowDeleteDialog(selectedDeleteProfileId)
                end,
                disabled = function()
                    return selectedDeleteProfileId == nil
                end,
                width = "half",
            },
        },
    }
end
