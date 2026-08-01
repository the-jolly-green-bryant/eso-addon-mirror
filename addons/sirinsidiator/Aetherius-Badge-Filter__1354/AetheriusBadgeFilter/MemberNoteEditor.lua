local ABF = AetheriusBadgeFilter
local internal = ABF.internal
local gettext = internal.gettext

local MemberNoteEditor = ZO_InitializingObject:Subclass()
ABF.class.MemberNoteEditor = MemberNoteEditor

function MemberNoteEditor:Initialize(guilds, saveData, filter, guildRosterScene, filterWindow)
    self.guilds = guilds
    self.saveData = saveData
    self.filter = filter
    self.guildRosterScene = guildRosterScene
    self.filterWindow = filterWindow

    local guildRoster = GUILD_ROSTER_KEYBOARD
    local guildRosterManager = GUILD_ROSTER_MANAGER

    ZO_PreHook(guildRoster, "Note_OnMouseEnter", function(self, control)
        local data = ZO_ScrollList_GetData(control:GetParent())
        if(data and data.note == "") then
            self:EnterRow(control:GetParent())
            return true
        end
    end)

    ZO_PreHook(guildRoster, "ColorRow", function(self, control, data, selected)
        local note = control:GetNamedChild("Note")
        if(not (data and note)) then return end

        if(data.note == "" and DoesPlayerHaveGuildPermission(guildRosterManager.guildId, GUILD_PERMISSION_NOTE_EDIT)) then
            note:SetHidden(not selected)
            note:SetAlpha(0.5)
        else
            note:SetAlpha(1)
        end
    end)

    local dialog = ESO_Dialogs["EDIT_NOTE"]
    local control = dialog.customControl
    self.control = control
    local editBox = GetControl(control, "NoteEdit")
    self.editBox = editBox
    ZO_PreHookHandler(editBox, "OnTextChanged", function()
        local note = editBox:GetText()
        self:UpdateNoteLength(note)
        self:UpdateBadges(note)
    end)

    local box = GetControl(control, "Note")
    self.box = box

    local noteLength = control:CreateControl("AetheriusBadgeFilterMemberEditorNoteLengthLabel", CT_LABEL)
    noteLength:SetAnchor(TOPLEFT, box, BOTTOMLEFT, 5, 5)
    noteLength:SetWidth(100)
    noteLength:SetFont("ZoFontGame")
    noteLength:SetText("0/254")
    noteLength:SetHidden(true)
    self.noteLength = noteLength

    local listContainer = control:CreateControl("AetheriusBadgeFilterMemberEditorBadgeListContainer", CT_CONTROL)
    listContainer:SetAnchor(TOPRIGHT, box, TOPLEFT, -5)
    listContainer:SetAnchor(BOTTOMLEFT, box, BOTTOMLEFT, -255)
    listContainer:SetHidden(true)
    self.listContainer = listContainer

    local previewControl = AetheriusBadgeFilterMemberEditorPreview
    previewControl:SetParent(control)
    previewControl:SetAnchor(TOPLEFT, box, TOPRIGHT, 5)
    previewControl:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, 250)
    previewControl:SetFont("ZoFontGame")
    previewControl:SetMouseEnabled(true)
    previewControl:SetHidden(true)
    previewControl:SetHandler("OnLinkClicked", function(control, linkData, linkText, button)
        local index = tonumber(linkData)
        local badgeData = self.badges[index]
        if(button == MOUSE_BUTTON_INDEX_LEFT) then
            if(IsShiftKeyDown()) then
                self:DecrementBadgeCount(badgeData)
            else
                self:IncrementBadgeCount(badgeData)
            end
        elseif(button == MOUSE_BUTTON_INDEX_RIGHT) then
            ClearMenu()
            if(badgeData.info and (not badgeData.info.limit or badgeData.info.limit > 1)) then
                -- TRANSLATORS: Entry for incrementing a badge value in the badge editor context menu
                AddCustomMenuItem(gettext("Increment"), function()
                    self:IncrementBadgeCount(badgeData)
                end)
                -- TRANSLATORS: Entry for decrementing a badge value in the badge editor context menu
                AddCustomMenuItem(gettext("Decrement"), function()
                    self:DecrementBadgeCount(badgeData)
                end)
            end
            if(badgeData.info and badgeData.info.color and badgeData.info.color ~= badgeData.color) then
                -- TRANSLATORS: Entry for updating a badge color in the badge editor context menu
                AddCustomMenuItem(gettext("Update Color"), function()
                    self:FixBadgeColor(badgeData)
                end)
            end
            -- TRANSLATORS: Entry for updating a badge color in the badge editor context menu
            AddCustomMenuItem(gettext("Remove"), function()
                self:RemoveBadge(badgeData)
            end)
            ShowMenu(control)
        end
    end)
    self.previewControl = previewControl
    self.badges = {}
    self.badgesByName = {}

    ZO_PreHook(dialog, "setup", function(dialog, data)
        if(self:IsBadgeEditorRequired()) then
            self:SetupBadgeEditor(dialog, data)
        end
    end)

    dialog.finishedCallback = function()
        filterWindow:ResetBadgeList()
        filterWindow:SetMemberEditor(nil)
        listContainer:SetHidden(true)
        previewControl:SetHidden(true)
        noteLength:SetHidden(true)
    end
end

function MemberNoteEditor:IsBadgeEditorRequired()
    return self.filter:SupportsBadges() and self.guildRosterScene:IsShowing()
end

function MemberNoteEditor:SetupBadgeEditor(dialog, data)
    self.filterWindow:SetMemberEditor(self)
    local list = self.filterWindow:GetBadgeList()
    list:SetParent(self.listContainer)
    list:ClearAnchors()
    list:SetAnchor(TOPLEFT, nil, TOPLEFT, 5, 0)
    list:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, -5, 0)
    self.filterWindow:HandleResize()

    self.listContainer:SetHidden(false)
    self.previewControl:SetHidden(false)
    self.noteLength:SetHidden(false)
end

local function GetBadgeLineWithChangedCount(badgeData, newCount)
    if(badgeData.comment == "") then
        badgeData.comment = string.format(" x%d", badgeData.count)
    end
    local comment = badgeData.comment:gsub(badgeData.count, newCount)
    return string.format("|c%s%s|r%s\n", badgeData.color, badgeData.badge, comment)
end

function MemberNoteEditor:IncrementBadgeCount(badgeData, increment)
    local newCount = badgeData.count + (increment or 1)
    local badgeInfo = badgeData.info
    if(badgeInfo and badgeInfo.limit and newCount >= badgeInfo.limit) then
        local turnsInto = badgeInfo.turnsInto
        local limit = badgeInfo.limit
        if(turnsInto) then
            local converionsCount = 0
            while(newCount >= limit) do
                newCount = newCount - limit
                converionsCount = converionsCount + 1
            end
            if(not self:HasBadge(turnsInto)) then
                self:AwardBadge(turnsInto, converionsCount)
            else
                self:IncrementBadgeCount(self:GetBadge(turnsInto), converionsCount)
            end
        else
            newCount = limit
        end
    end
    local newBadgeLine = GetBadgeLineWithChangedCount(badgeData, newCount)
    local note = self.note:gsub(badgeData.line, newBadgeLine)
    self:SetNote(note)
end

function MemberNoteEditor:SetNote(note)
    self.editBox:SetText(note:sub(1, -2)) -- need to remove the newline that we add when we read the note
end

function MemberNoteEditor:HasBadge(badgeName)
    return self.badgesByName[badgeName] ~= nil
end

function MemberNoteEditor:GetBadge(badgeName)
    return self.badgesByName[badgeName]
end

function MemberNoteEditor:AwardBadge(badgeName, initialCount, detectedColor)
    local info = self.filter:GetCurrentGuildInfo()
    local badgeData = {
        color = detectedColor or "ffffff",
        badge = badgeName,
        count = initialCount or 1,
        comment = ""
    }
    if(info and info.badges and info.badges[badgeName]) then
        badgeData.info = info.badges[badgeName]
        if(badgeData.info) then
            if(not badgeData.info.limit or badgeData.info.limit > 1) then
                badgeData.comment = string.format(" x%d", badgeData.count)
            end
            if(badgeData.info.color) then
                badgeData.color = badgeData.info.color
            end
        end
    end
    badgeData.line = string.format("|c%s%s|r%s\n", badgeData.color, badgeData.badge, badgeData.comment)
    if(self.isEmpty) then
        self:SetNote(badgeData.line)
    else
        self:SetNote(self.note .. badgeData.line)
    end
end

function MemberNoteEditor:DecrementBadgeCount(badgeData, decrement)
    local newCount = badgeData.count + (decrement or -1)
    if(newCount < 0) then
        newCount = 0
    end
    local newBadgeLine = GetBadgeLineWithChangedCount(badgeData, newCount)
    local note = self.note:gsub(badgeData.line, newBadgeLine)
    self:SetNote(note)
end

function MemberNoteEditor:RemoveBadge(badgeData)
    local note = self.note:gsub(badgeData.line, "")
    self:SetNote(note)
end

function MemberNoteEditor:FixBadgeColor(badgeData)
    local fixedLine = string.format("|c%s%s|r%s\n", badgeData.info.color, badgeData.badge, badgeData.comment)
    local note = self.note:gsub(badgeData.line, fixedLine)
    self:SetNote(note)
end

local MEMBER_NOTE_CHAR_LIMIT = 254
function MemberNoteEditor:UpdateNoteLength(note)
    local count = #note
    note:gsub("|", function() count = count + 1 end)
    local color = (count == MEMBER_NOTE_CHAR_LIMIT) and "ff0000" or "ffffff"
    self.noteLength:SetText(string.format("|c%s%d/%d", color, count, MEMBER_NOTE_CHAR_LIMIT))
end

function MemberNoteEditor:UpdateBadges(note)
    self.isEmpty = (#note == 0)
    note = note .. "\n" -- add one newline so we can match the last line in any case
    self.note = note
    local info = self.filter:GetCurrentGuildInfo()
    local index = 0
    ZO_ClearTable(self.badgesByName)
    note = note:gsub("(|c(......)(.-)|r(.-)\n)", function(line, color, badge, comment)
        local count = comment:gmatch(".-(%d+).-")() or 1
        local badgeData = {
            line = line,
            color = color,
            badge = badge,
            count = count,
            comment = comment,
        }
        if(info and info.badges and info.badges[badge]) then
            badgeData.info = info.badges[badge]
        end
        index = index + 1
        self.badges[index] = badgeData
        self.badgesByName[badge] = badgeData
        return string.format("|c%s|h%d|H%s|H|r%s\n", color, index, badge, comment)
    end)
    self.previewControl:SetText(note)
end
