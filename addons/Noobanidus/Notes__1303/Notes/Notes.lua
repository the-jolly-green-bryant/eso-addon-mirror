Notes = {}
 
Notes.name = "Notes"
Notes.SavedVars = {}

NOTES_WINDOW = nil
local SAVEDVARS_NAME = "Notes_SavedVariables"
local SAVEDVARS_VERSION = 1
local DefaultVars = {
    [1] = { channel = nil, message = nil },
    [2] = { channel = nil, message = nil },
    [3] = { channel = nil, message = nil },
    [4] = { channel = nil, message = nil },
    [5] = { channel = nil, message = nil }
}

local CHANNEL_KEYS = {
    ["Party"] = 3,
    ["Zone"] = 31,
    ["Zone - Language 1"] = 32,
    ["Zone - Language 2"] = 33,
    ["Zone - Language 3"] = 34,
    ["Emote"] = 6,
    ["Say"] = 0,
    ["Yell"] = 1,
    ["Whisper (Reply)"] = -1,
    ["Whisper"] = 2,
    ["Current Channel"] = -2
}

local NotesWindow = ZO_Object:Subclass()

local function ChannelToKey (channel)
    for k, v in pairs(CHANNEL_KEYS) do
        if v == channel then return k end
    end

    return nil
end

local function update_interface ()
    local sv = Notes.SavedVars

    -- load up dem saved variables yo
    if sv[1] ~= nil then
        if sv[1]["body"] ~= nil then
            NOTES_WINDOW.body1:SetText(sv[1]["body"])
        end
        if sv[1]["channel"] ~= nil then
            NOTES_WINDOW.channel1:SetSelectedItem(ChannelToKey(sv[1]["channel"]))
        end
    end
    if sv[2] ~= nil then
        if sv[2]["body"] ~= nil then
            NOTES_WINDOW.body2:SetText(sv[2]["body"])
        end
        if sv[2]["channel"] ~= nil then
            NOTES_WINDOW.channel2:SetSelectedItem(ChannelToKey(sv[2]["channel"]))
        end
    end
    if sv[3] ~= nil then
        if sv[3]["body"] ~= nil then
            NOTES_WINDOW.body3:SetText(sv[3]["body"])
        end
        if sv[3]["channel"] ~= nil then
            NOTES_WINDOW.channel3:SetSelectedItem(ChannelToKey(sv[3]["channel"]))
        end
    end
    if sv[4] ~= nil then
        if sv[4]["body"] ~= nil then
            NOTES_WINDOW.body4:SetText(sv[4]["body"])
        end
        if sv[4]["channel"] ~= nil then
            NOTES_WINDOW.channel4:SetSelectedItem(ChannelToKey(sv[4]["channel"]))
        end
    end
    if sv[5] ~= nil then
        if sv[5]["body"] ~= nil then
            NOTES_WINDOW.body5:SetText(sv[5]["body"])
        end
        if sv[5]["channel"] ~= nil then
            NOTES_WINDOW.channel5:SetSelectedItem(ChannelToKey(sv[5]["channel"]))
        end
    end
end

function Notes:Initialize()
	SLASH_COMMANDS["/notes"] = NotesWindowToggle
    SLASH_COMMANDS["/note1"] = NotesSendNote1
    SLASH_COMMANDS["/note2"] = NotesSendNote2
    SLASH_COMMANDS["/note3"] = NotesSendNote3
    SLASH_COMMANDS["/note4"] = NotesSendNote4
    SLASH_COMMANDS["/note5"] = NotesSendNote5

    Notes.SavedVars = ZO_SavedVars:NewAccountWide(SAVEDVARS_NAME, SAVEDVARS_VERSION, nil, DefaultVars)

    zo_callLater(update_interface, 300)
end

local function doMagic (index)
    if Notes.SavedVars[index] ~= nil then
        local channel = Notes.SavedVars[index]["channel"]
        local body = Notes.SavedVars[index]["body"]
        if channel == -1 then
            ChatReplyToLastWhisper()
        elseif channel == -2 then
        else
            CHAT_SYSTEM:SetChannel(channel)
        end
        CHAT_SYSTEM:StartTextEntry(body)
    end
end

function NotesSendNote1 ()
    doMagic(1)
end
function NotesSendNote2 ()
    doMagic(2)
end
function NotesSendNote3 ()
    doMagic(3)
end
function NotesSendNote4 ()
    doMagic(4)
end
function NotesSendNote5 ()
    doMagic(5)
end

function Notes.OnAddOnLoaded(event, addonName)
    if addonName == Notes.name then
        Notes:Initialize()
    end
end

function NotesWindowToggle ()
    NotesWindow:Toggle()
end

-- Notes window class
--
function NotesWindow:Show ()
	if (not NOTES_WINDOW.visible) then
		NOTES_WINDOW.visible = true
		NOTES_WINDOW.control:SetHidden(false)
	end
end

function NotesWindow:Toggle()
    if (NOTES_WINDOW.visible) then
        NOTES_WINDOW:Hide()
    else
        NOTES_WINDOW:Show()
    end
end

function NotesWindow:Hide()
	if (NOTES_WINDOW.visible) then
		NOTES_WINDOW.visible = false
		NOTES_WINDOW.control:SetHidden(true)
		PlaySound(SOUNDS.SYSTEM_WINDOW_CLOSE)
	end
end

function NotesWindow:New(control)
	local manager = ZO_Object.New(self)
	
	manager.control = control
	manager.body1 = GetControl(control, "Body1Field")
	manager.body2 = GetControl(control, "Body2Field")
	manager.body3 = GetControl(control, "Body3Field")
	manager.body4 = GetControl(control, "Body4Field")
	manager.body5 = GetControl(control, "Body5Field")
	manager.visible = false

    manager.channel1 = ZO_ComboBox_ObjectFromContainer(GetControl(control, "Body1Channel"))
    manager.channel2 = ZO_ComboBox_ObjectFromContainer(GetControl(control, "Body2Channel"))
    manager.channel3 = ZO_ComboBox_ObjectFromContainer(GetControl(control, "Body3Channel"))
    manager.channel4 = ZO_ComboBox_ObjectFromContainer(GetControl(control, "Body4Channel"))
    manager.channel5 = ZO_ComboBox_ObjectFromContainer(GetControl(control, "Body5Channel"))

	manager.channel1:SetSortsItems(false)
	manager.channel1:SetSpacing(4)
	manager.channel1:ClearItems()

	manager.channel2:SetSortsItems(false)
	manager.channel2:SetSpacing(4)
	manager.channel2:ClearItems()

	manager.channel3:SetSortsItems(false)
	manager.channel3:SetSpacing(4)
	manager.channel3:ClearItems()

	manager.channel4:SetSortsItems(false)
	manager.channel4:SetSpacing(4)
	manager.channel4:ClearItems()

	manager.channel5:SetSortsItems(false)
	manager.channel5:SetSpacing(4)
	manager.channel5:ClearItems()

    manager.body1:SetMaxInputChars(350)
    manager.body2:SetMaxInputChars(350)
    manager.body3:SetMaxInputChars(350)
    manager.body4:SetMaxInputChars(350)
    manager.body5:SetMaxInputChars(350)

    local function _buildList(control, index)
        local function _onChannelChange (_, name, choice)
            if Notes.SavedVars[index] == nil then
                Notes.SavedVars[index] = {["channel"] = CHANNEL_KEYS[name], ["body"] = ""}
            else
                Notes.SavedVars[index]["channel"] = CHANNEL_KEYS[name]
            end
        end

        for guildIndex = 1, GetNumGuilds() do
            local guildId = GetGuildId(guildIndex)
            local guildName = GetGuildName(guildId)
            CHANNEL_KEYS[guildName] = 11 + guildId
                
            local entry = control:CreateItemEntry(guildName, _onChannelChange) -- Populate guild dropdown box
            control:AddItem(entry)
        end

        for _, v in pairs({"Party", "Zone", "Zone - Language 1", "Zone - Language 2", "Zone - Language 3", "Emote", "Say", "Yell", "Whisper", "Whisper (Reply)", "Current Channel"}) do 
            local entry = control:CreateItemEntry(v, _onChannelChange)
            control:AddItem(entry)
        end
    end

    _buildList(manager.channel1, 1)
    _buildList(manager.channel2, 2)
    _buildList(manager.channel3, 3)
    _buildList(manager.channel4, 4)
    _buildList(manager.channel5, 5)

    return manager
end

function NotesWindow_OnInitialised (self)
    NOTES_WINDOW = NotesWindow:New (self)
end

function NotesWindowCloseButton_OnClicked (self)
    NOTES_WINDOW:Hide()
end

local function saveBody (index, body)
    if Notes.SavedVars[index] == nil then
        Notes.SavedVars[index] = {["channel"] = nil, ["body"] = body}
    else
        Notes.SavedVars[index]["body"] = body
    end
end

function NotesWindowBody1_OnTextChanged (self)
    saveBody(1, NotesWindowBody1Field:GetText())
end

function NotesWindowBody2_OnTextChanged (self)
    saveBody(2, NotesWindowBody2Field:GetText())
end

function NotesWindowBody3_OnTextChanged (self)
    saveBody(3, NotesWindowBody3Field:GetText())
end

function NotesWindowBody4_OnTextChanged (self)
    saveBody(4, NotesWindowBody4Field:GetText())
end

function NotesWindowBody5_OnTextChanged (self)
    saveBody(5, NotesWindowBody5Field:GetText())
end

EVENT_MANAGER:RegisterForEvent(Notes.name, EVENT_ADD_ON_LOADED, Notes.OnAddOnLoaded)
