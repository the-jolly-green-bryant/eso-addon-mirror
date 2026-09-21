-- Rolodex
-- Tracks the last 25 people you've exchanged mail with (sent or received),
-- most-recent first. Pin anyone to a permanent "Saved" list that never rolls
-- off. /rolo opens a browsable list; a keybind does the same.

local ADDON_NAME = "Rolodex"
local MAX_RECENT = 25

local defaults = {
    recent = {},   -- ordered list, most recent first: { name=, lastTs=, lastNote= }
    saved  = {},   -- [name] = { name=, note=, savedTs= }
    debug  = false,
}
local sv

local function Dbg(msg) if sv and sv.debug then d("|c66CCFF[Rolodex]|r " .. msg) end end
local function Msg(msg) d("|c66CCFF[Rolodex]|r " .. msg) end

-- ---------------------------------------------------------------------------
-- Recording contacts
-- ---------------------------------------------------------------------------
local function NormalizeName(name)
    if not name or name == "" then return nil end
    return zo_strformat("<<1>>", name)
end

local function RemoveFromRecent(name)
    for i = #sv.recent, 1, -1 do
        if sv.recent[i].name == name then table.remove(sv.recent, i) end
    end
end

local function RecordContact(name, note)
    name = NormalizeName(name)
    if not name then return end
    if name == GetUnitName("player") then return end  -- ignore mail to/from yourself

    RemoveFromRecent(name)  -- move-to-front instead of duplicating
    table.insert(sv.recent, 1, { name = name, lastTs = GetTimeStamp(), lastNote = note })

    while #sv.recent > MAX_RECENT do
        table.remove(sv.recent)  -- drop oldest
    end

    Dbg("Recorded contact: " .. name .. (note and (" (" .. note .. ")") or ""))
end

-- ---------------------------------------------------------------------------
-- Mail events
-- ---------------------------------------------------------------------------
local function OnMailReadable(_, mailId)
    local senderDisplayName, subject, _, _, _, _, _, _, _, _, _ = GetMailItemInfo(mailId)
    if senderDisplayName and senderDisplayName ~= "" then
        RecordContact(senderDisplayName, subject)
    end
end

-- Sending mail: capture the recipient at the moment it's actually sent.
local function OnMailSendSuccess()
    local recipient = MAIL_SEND_QUEUE_MANAGER and MAIL_SEND_QUEUE_MANAGER.GetLastRecipient
        and MAIL_SEND_QUEUE_MANAGER:GetLastRecipient()
    -- Fallback: read whatever is currently in the compose-to field if the
    -- queue manager accessor above isn't present on this client.
    if not recipient and MAIL_SEND and MAIL_SEND.GetToFieldText then
        recipient = MAIL_SEND:GetToFieldText()
    end
    if recipient and recipient ~= "" then
        RecordContact(recipient, "(sent mail)")
    end
end

-- ---------------------------------------------------------------------------
-- Saved (pinned) contacts
-- ---------------------------------------------------------------------------
local function IsSaved(name) return sv.saved[name] ~= nil end

local function SaveContact(name, note)
    name = NormalizeName(name)
    if not name then return end
    sv.saved[name] = { name = name, note = note, savedTs = GetTimeStamp() }
    Msg("Saved " .. name)
end

local function UnsaveContact(name)
    name = NormalizeName(name)
    if sv.saved[name] then
        sv.saved[name] = nil
        Msg("Removed " .. name .. " from saved contacts")
    end
end

-- ---------------------------------------------------------------------------
-- Gamepad list dialog
-- ---------------------------------------------------------------------------
local function BuildEntries()
    local entries = {}

    -- Saved first (pinned, alphabetical-ish by save order is fine)
    for _, c in pairs(sv.saved) do
        entries[#entries + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            templateData = {
                text = "* " .. c.name .. (c.note and (" - " .. c.note) or ""),
                setup = ZO_SharedGamepadEntry_OnSetup,
                callback = function() UnsaveContact(c.name) end,
            },
        }
    end

    -- Then recent, most-recent first, marking anyone already saved
    for _, c in ipairs(sv.recent) do
        local starred = IsSaved(c.name)
        entries[#entries + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            templateData = {
                text = (starred and "* " or "  ") .. c.name ..
                       (c.lastNote and (" - " .. c.lastNote) or ""),
                setup = ZO_SharedGamepadEntry_OnSetup,
                callback = function()
                    if starred then UnsaveContact(c.name) else SaveContact(c.name, c.lastNote) end
                end,
            },
        }
    end

    if #entries == 0 then
        entries[#entries + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            templateData = {
                text = "No contacts yet - send or receive some mail first.",
                setup = ZO_SharedGamepadEntry_OnSetup,
                callback = function() end,
            },
        }
    end
    return entries
end

local function RegisterDialog()
    ESO_Dialogs["ROLODEX_LIST"] = {
        canQueue = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog) dialog:setupFunc() end,
        title = { text = "Rolodex" },
        mainText = { text = "* = saved. Select a name to save/unsave it." },
        parametricList = BuildEntries(),
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList and dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then targetData.callback() end
                    ZO_Dialogs_ShowGamepadDialog("ROLODEX_LIST")  -- reopen refreshed
                end,
            },
            { keybind = "DIALOG_NEGATIVE", text = SI_DIALOG_CLOSE },
        },
    }
end

function Rolodex_Open()
    ESO_Dialogs["ROLODEX_LIST"].parametricList = BuildEntries()
    ZO_Dialogs_ShowGamepadDialog("ROLODEX_LIST")
end

ZO_CreateStringId("SI_BINDING_NAME_ROLODEX_OPEN", "Open Rolodex")

-- ---------------------------------------------------------------------------
-- Mail UI integration: adds a "Rolodex" keybind (left stick click) to the
-- gamepad mail inbox screen, opening the same list dialog as /rolo.
-- ---------------------------------------------------------------------------
local function InstallMailKeybind()
    if not MAIL_MANAGER_GAMEPAD or not MAIL_MANAGER_GAMEPAD.inbox then
        Msg("Mail UI integration unavailable on this client - use /rolo instead.")
        return
    end

    local inbox = MAIL_MANAGER_GAMEPAD.inbox
    if not inbox.mainKeybindDescriptor then
        Msg("Mail keybind list not ready yet - use /rolo instead.")
        return
    end

    table.insert(inbox.mainKeybindDescriptor, {
        name = "Rolodex",
        keybind = "UI_SHORTCUT_LEFT_STICK",
        callback = function() Rolodex_Open() end,
    })

    -- Refresh the on-screen keybind strip if it's currently showing this list.
    if KEYBIND_STRIP and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(inbox.mainKeybindDescriptor)
    end
    Dbg("Rolodex keybind installed on mail inbox screen.")
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/rolo"] = function(args)
        args = zo_strtrim(args or "")
        if args == "" then Rolodex_Open() return end
        local cmd, rest = args:match("^(%S+)%s*(.*)$")
        cmd = zo_strlower(cmd)

        if cmd == "save" and rest ~= "" then
            SaveContact(rest)
        elseif cmd == "unsave" and rest ~= "" then
            UnsaveContact(rest)
        elseif cmd == "list" then
            Msg("-- Saved --")
            for _, c in pairs(sv.saved) do Msg("  " .. c.name) end
            Msg("-- Recent --")
            for i, c in ipairs(sv.recent) do Msg(string.format("  %d. %s", i, c.name)) end
        elseif cmd == "clear" then
            sv.recent = {}
            Msg("Cleared recent contacts (saved contacts kept).")
        elseif cmd == "debug" then
            sv.debug = not sv.debug
            Msg("debug=" .. tostring(sv.debug))
        else
            Msg("/rolo | save <name> | unsave <name> | list | clear | debug")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("RolodexSV", 1, nil, defaults)
    if type(sv.recent) ~= "table" then sv.recent = {} end
    if type(sv.saved) ~= "table" then sv.saved = {} end

    RegisterDialog()
    RegisterSlash()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_READABLE, OnMailReadable)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_SEND_SUCCESS, OnMailSendSuccess)

    local mailKeybindInstalled = false
    local function TryInstallMailKeybind()
        if mailKeybindInstalled then return end
        if MAIL_MANAGER_GAMEPAD and MAIL_MANAGER_GAMEPAD.inbox and MAIL_MANAGER_GAMEPAD.inbox.mainKeybindDescriptor then
            InstallMailKeybind()
            mailKeybindInstalled = true
        end
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(TryInstallMailKeybind, 2000)
    end)
    if MAIL_MANAGER_GAMEPAD_SCENE then
        MAIL_MANAGER_GAMEPAD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then TryInstallMailKeybind() end
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
