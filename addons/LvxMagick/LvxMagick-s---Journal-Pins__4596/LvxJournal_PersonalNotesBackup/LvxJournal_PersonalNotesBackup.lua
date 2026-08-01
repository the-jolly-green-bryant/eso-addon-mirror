LvxJournalPersonalNotesBackup = LvxJournalPersonalNotesBackup or {}
LvxJournalPersonalNotesBackup.name = "LvxJournal_PersonalNotesBackup"

local BackupAddon = LvxJournalPersonalNotesBackup

local backupDefaults = {
    journal = {},
}

local function CleanText(value)
    value = tostring(value or "")
    value = value:gsub("\r\n", "\n")
    value = value:gsub("\r", "\n")
    return value
end

local function AddTextLines(lines, text)
    text = CleanText(text)

    if text == "" then
        return
    end

    text = text .. "\n"
    for line in text:gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
end

local function MakeJournalBackup(notes)
    notes = notes or {}

    local lines = {}

    if #notes == 0 then
        lines[#lines + 1] = "No Personal Notes were found."
        return lines
    end

    for i = 1, #notes do
        local note = notes[i] or {}
        local title = CleanText(note.title or "Untitled Entry")
        local body = CleanText(note.body or "")

        lines[#lines + 1] = "============================================================"
        lines[#lines + 1] = title
        lines[#lines + 1] = "------------------------------------------------------------"
        AddTextLines(lines, body)
        lines[#lines + 1] = ""
    end

    return lines
end

local function RemoveOldBackupFields()
    if not BackupAddon.savedVars then
        return
    end

    BackupAddon.savedVars.plainTextBackup = nil
    BackupAddon.savedVars.notes = nil
    BackupAddon.savedVars.structuredNotes = nil
    BackupAddon.savedVars.count = nil
    BackupAddon.savedVars.metadata = nil
    BackupAddon.savedVars.lastExport = nil
    BackupAddon.savedVars.version = nil
end

function BackupAddon.ExportPersonalNotes(notes)
    BackupAddon.savedVars = BackupAddon.savedVars or {}

    -- Clean readable backup only: one journal table, line by line.
    -- ESO still wraps this inside its normal SavedVariables account/server structure.
    BackupAddon.savedVars.journal = MakeJournalBackup(notes)
    RemoveOldBackupFields()
end

function BackupAddon.ClearExport()
    BackupAddon.savedVars = BackupAddon.savedVars or {}
    BackupAddon.savedVars.journal = {}
    RemoveOldBackupFields()
end

function BackupAddon.OnAddOnLoaded(event, addonName)
    if addonName ~= BackupAddon.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BackupAddon.name, EVENT_ADD_ON_LOADED)

    BackupAddon.savedVars = ZO_SavedVars:NewAccountWide("LvxJournal_PersonalNotesBackup", 1, nil, backupDefaults)

    if type(BackupAddon.savedVars.journal) ~= "table" then
        BackupAddon.savedVars.journal = {}
    end

    RemoveOldBackupFields()
end

EVENT_MANAGER:RegisterForEvent(BackupAddon.name, EVENT_ADD_ON_LOADED, BackupAddon.OnAddOnLoaded)
