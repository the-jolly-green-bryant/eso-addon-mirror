local addon = {}
addon.__index = addon

local EVENT_NOTE_EDITED = 1

addon.events = {
    EVENT_NOTE_EDITED = EVENT_NOTE_EDITED,
}

function addon.New()
    local instance = setmetatable({}, addon)

    ImpressiveStatsTributeNotes = ImpressiveStatsTributeNotes or {}
    instance.list = ImpressiveStatsTributeNotes

    instance.callbacks = {
        [EVENT_NOTE_EDITED] = {},
    }

    return instance
end

function addon:GetNote(name)
    return self.list[name]
end

function addon:SaveNote(name, note)
    if note == '' then
        return self:DeleteNote(name)
    end

    self.list[name] = note
    self:FireCallbacks(EVENT_NOTE_EDITED)
end

function addon:DeleteNote(name)
    self.list[name] = nil
    self:FireCallbacks(EVENT_NOTE_EDITED)
end

function addon:ShowEditNoteDialog(name)
    local dialogParams = {
        displayName = name,
        note = self:GetNote(name),
        changedCallback = function(...) self:SaveNote(...) end
    }

    ZO_Dialogs_ShowDialog('EDIT_NOTE', dialogParams)
end

function addon:RegisterCallback(name, event, callback)
    if self.callbacks[event][name] ~= nil then
        error(('Callback with name %s alredy registered'):format(name))
    end

    self.callbacks[event][name] = callback
end

function addon:UnregisterCallback(name, event)
    self.callbacks[event][name] = nil
end

function addon:FireCallbacks(event)
    for _, callback in pairs(self.callbacks[event]) do
        callback()
    end
end

function IMP_STATS_NotesManager_Initialize()
    IMP_STATS_NOTES_MANAGER = addon.New()
end