local GuildEvents = _G["GuildEvents"]
GuildEventsUI = GuildEventsUI or {}
GuildEventsUI.events = {}
GuildEvents.eventList = {}

local ui = GuildEventsUI.events
local wm = WINDOW_MANAGER
local L = GuildEvents.GetLocale()

GuildEvents.roles = {
    [4] = {
        label = L.roleUndefined,
        shortcut = 'U',
        icon = nil
    },
    [1] = {
        label = L.roleTank,
        shortcut = 'T',
        controlName = 'CheckboxRoleTank',
        icon = {
            src = 'esoui/art/lfg/gamepad/lfg_roleicon_tank.dds',
            x = 18,
            y = 18
        }
    },
    [2] = {
        label = L.roleHealer,
        shortcut = 'H',
        controlName = 'CheckboxRoleHealer',
        icon = {
            src = 'esoui/art/lfg/gamepad/lfg_roleicon_healer.dds',
            x = 22,
            y = 22
        }
    },
    [3] = {
        label = L.roleDD,
        shortcut = 'D',
        controlName = 'CheckboxRoleDD',
        icon = {
            src = 'esoui/art/icons/poi/poi_battlefield_complete.dds',
            x = 20,
            y = 20
        }
    },
    [0] = {
        label = L.roleDDR,
        shortcut = 'R',
        controlName = 'CheckboxRoleDDR',
        icon = {
            src = 'esoui/art/lfg/gamepad/lfg_roleicon_dps.dds',
            x = 20,
            y = 20
        }
    },

}

GuildEvents.currentBtnEvent = nil
GuildEvents.currentLblAttending = nil
GuildEvents.currentEventId = nil

------------------------------------------------
--- Utility functions
------------------------------------------------
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00"..msg) end

function string:split( inSplitPattern, outResults )
    if not outResults then
        outResults = { }
    end
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    while theSplitStart do
        table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
    end
    table.insert( outResults, string.sub( self, theStart ) )
    return outResults
end

function trimString( s )
    local newString = string.match(s, "#.*#")
    if newString == nil then
        return nil
    end
    return string.gsub(newString, "#", "")
end

------------------------------------------------
--- Dialog functions
------------------------------------------------

--function that shows dialog for confirmation of deleting an event
local function GuildEventsEventDeleteConfirmationInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")

    ZO_Dialogs_RegisterCustomDialog("GUILDEVENTS_EVENT_DELETE_DIALOG", {
        customControl = control,
        title = { text = L.deleteEventLabel  },
        mainText = { text = L.deleteEventTitle },
        setup = function(dialog, data)
            descLabel:SetText(L.deleteEventText)
        end,
        noChoiceCallback = function(dialog)
            --Simulate the button "cancel" click
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    GuildEventsUI:removeEvent(dialog)
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                end,
            },
        },
    })
end

--Shows event delete confirmation window
local function confirmEventDelete(eventIndex)
    ZO_Dialogs_ShowDialog("GUILDEVENTS_EVENT_DELETE_DIALOG", {event=eventIndex})
end

--function that shows dialog to sign up for event
local function GuildEventsEventSignupInitialize(control)
    local content   = GetControl(control, "Content")
    local acceptBtn = GetControl(control, "Accept")
    local cancelBtn = GetControl(control, "Cancel")
    local descLabel = GetControl(content, "Text")
    local labelRoleTank = GetControl(content, "TextRoleTank")
    local labelRoleHealer = GetControl(content, "TextRoleHealer")
    local labelRoleDD = GetControl(content, "TextRoleDD")
    local labelRoleDDR = GetControl(content, "TextRoleDDR")

    ZO_Dialogs_RegisterCustomDialog("GUILDEVENTS_EVENT_SIGNUP_DIALOG", {
        customControl = control,
        title = { text = L.signupEventLabel  },
        mainText = { text = L.signupEventTitle },
        setup = function(dialog, data)
            descLabel:SetText(L.signupEventText)
            labelRoleTank:SetText("|t26:26:".. GuildEvents.roles[1].icon.src .."|t " .. L.roleTank)
            labelRoleHealer:SetText("|t26:26:".. GuildEvents.roles[2].icon.src .."|t " .. L.roleHealer)
            labelRoleDD:SetText("|t26:26:".. GuildEvents.roles[3].icon.src .."|t " .. L.roleDD)
            labelRoleDDR:SetText("|t26:26:".. GuildEvents.roles[0].icon.src .."|t " .. L.roleDDR)
        end,
        noChoiceCallback = function(dialog)
            --Simulate the button "cancel" click
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog)
                    GuildEventsUI:signUpForEvent(dialog)
                end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    GuildEventsUI:uncheckSelectedRoles()
                end,
            },
        },
    })
end

--Shows event sign up window
local function confirmEventSignup(btnEvent, lblAttending, eventIndex)
    GuildEvents.currentBtnEvent = btnEvent
    GuildEvents.currentLblAttending = lblAttending
    GuildEvents.currentEventId = eventIndex
    ZO_Dialogs_ShowDialog("GUILDEVENTS_EVENT_SIGNUP_DIALOG", {event=eventIndex})
end

--function that shows dialog to sign up for event
local function GuildEventsProgressInitialize(object)
    object:SetDrawLayer(DL_OVERLAY)
    object:GetNamedChild("Text"):SetText(L.progressText)
    object:GetNamedChild("ProgressBar"):SetMinMax(0, 0)
    object:GetNamedChild("ProgressBar"):SetValue(0)
end

--Shows event sign up window
local function showProgressDialog(numMax)
    if GuildEventsProgressDialog ~= nil then
        GuildEventsProgressDialog:SetHidden(false)
        GuildEventsProgressDialog:GetNamedChild("ProgressBar"):SetMinMax(0, numMax)
        GuildEventsProgressDialog:GetNamedChild("ProgressBar"):SetValue(0)
    end
end

local function hideProgressDialog()
    GuildEventsProgressDialog:SetHidden(true)
end

------------------------------------------------
--- Methods
------------------------------------------------
function GuildEventsUI:CreateEvents()

    ui.main = wm:CreateTopLevelWindow("GuildEventsEventsFragment")
    ui.main:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, 0)
    ui.main:SetHidden(true)
    ui.main:SetWidth(600)

    --Event Delete Confirmation Dialog
    GuildEventsEventDeleteConfirmationInitialize(GuildEventsEventDeleteConfirmation)

    -- Event sign up dialog
    GuildEventsEventSignupInitialize(GuildEventsSignupDialog)

    -- Progress dialog
    GuildEventsProgressInitialize(GuildEventsProgressDialog)

    -- Special Font-Attributes for Attending
    local lblAttendingFontPath = "EsoUI/Common/Fonts/univers67.otf"
    local lblAttendingFontSize = 14
    local lblAttendingFontOutline = "soft-shadow-thin"

    -------------------------------------------
    -- standardise the creation of ui elements
    -------------------------------------------
    ui.eventControls = {}

    for i=1,GuildEvents.maxEvents do
        ui.eventControls[i] = {
            btnEvent = wm:CreateControl("GuildEvents_btnEvent" .. i, ui.main, CT_BUTTON),
            btnEventDelete = wm:CreateControl("GuildEvents_btnEventDelete" .. i, ui.main, CT_BUTTON),
            btnEventInvite = wm:CreateControl("GuildEvents_btnEventInvite" .. i, ui.main, CT_BUTTON),
            lblEvent = wm:CreateControl("GuildEvents_lblEvent" .. i, ui.main, CT_LABEL),
            lblAttending = wm:CreateControl("GuildEvents_lblAttending" .. i, ui.main, CT_LABEL)
        }
        local parentAnchor
        local parentTarget = BOTTOMLEFT
        local anchorOffsetY = 20
        local anchorOffsetX = -25
        if i == 1 then
            parentAnchor = ui.main
            anchorOffsetY = 10
            parentTarget = TOPLEFT
            anchorOffsetX = 0
        else
            parentAnchor = ui.eventControls[i-1].lblAttending
        end
        -- btnEvent params
        ui.eventControls[i].btnEvent:SetDimensions(20, 20)
        ui.eventControls[i].btnEvent:SetAnchor(TOPLEFT, parentAnchor, parentTarget, anchorOffsetX, anchorOffsetY)
        ui.eventControls[i].btnEvent:SetAlpha(1)
        ui.eventControls[i].btnEvent:SetDrawLayer(1)
        ui.eventControls[i].btnEvent:SetFont("ZoFontAlert")
        ui.eventControls[i].btnEvent:SetScale(1)
        ui.eventControls[i].btnEvent:SetText("")
        ui.eventControls[i].btnEvent:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
        ui.eventControls[i].btnEvent:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
        ui.eventControls[i].btnEvent:SetHidden(true)
        -- lblEvent params
        ui.eventControls[i].lblEvent:SetColor(1.0, 1.0, 1.0, 1)
        ui.eventControls[i].lblEvent:SetFont("ZoFontAlert")
        ui.eventControls[i].lblEvent:SetScale(1)
        ui.eventControls[i].lblEvent:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        ui.eventControls[i].lblEvent:SetDrawLayer(1)
        ui.eventControls[i].lblEvent:SetAnchor(TOPLEFT, ui.eventControls[i].btnEvent, TOPRIGHT, 5, -4)
        ui.eventControls[i].lblEvent:SetWidth(500)
        -- btnEventInvite params
        ui.eventControls[i].btnEventInvite:SetDimensions(50, 45)
        ui.eventControls[i].btnEventInvite:SetAnchor(TOPLEFT, ui.eventControls[i].lblEvent, TOPRIGHT, 0, -6)
        ui.eventControls[i].btnEventInvite:SetAlpha(1)
        ui.eventControls[i].btnEventInvite:SetDrawLayer(1)
        ui.eventControls[i].btnEventInvite:SetFont("ZoFontAlert")
        ui.eventControls[i].btnEventInvite:SetScale(1)
        ui.eventControls[i].btnEventInvite:SetText("")
        ui.eventControls[i].btnEventInvite:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
        ui.eventControls[i].btnEventInvite:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
        ui.eventControls[i].btnEventInvite:SetHidden(true)
        -- btnEventDelete params
        ui.eventControls[i].btnEventDelete:SetDimensions(25, 25)
        ui.eventControls[i].btnEventDelete:SetAnchor(TOPLEFT, ui.eventControls[i].btnEventInvite, TOPRIGHT, 0, 12)
        ui.eventControls[i].btnEventDelete:SetAlpha(1)
        ui.eventControls[i].btnEventDelete:SetDrawLayer(1)
        ui.eventControls[i].btnEventDelete:SetFont("ZoFontAlert")
        ui.eventControls[i].btnEventDelete:SetScale(1)
        ui.eventControls[i].btnEventDelete:SetText("")
        ui.eventControls[i].btnEventDelete:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
        ui.eventControls[i].btnEventDelete:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
        ui.eventControls[i].btnEventDelete:SetHidden(true)
        ui.eventControls[i].btnEventDelete:SetHandler("OnClicked", function(h)
            -- local i not usable in function call?
            confirmEventDelete(i)
        end)
        -- lblAttending params
        ui.eventControls[i].lblAttending:SetColor(0.8, 0.8, 0.8, 1)
        ui.eventControls[i].lblAttending:SetFont(lblAttendingFontPath .. "|" .. lblAttendingFontSize .. "|" ..  lblAttendingFontOutline)
        ui.eventControls[i].lblAttending:SetScale(1)
        ui.eventControls[i].lblAttending:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        ui.eventControls[i].lblAttending:SetDrawLayer(1)
        ui.eventControls[i].lblAttending:SetAnchor(TOPLEFT, ui.eventControls[i].lblEvent, BOTTOMLEFT, 0, 0)
        ui.eventControls[i].lblAttending:SetWidth(575)
    end

    -- NoEvents Control
    ui.lblNoEvents = wm:CreateControl("GuildEvents_lblNoEvents", ui.main, CT_LABEL)
    ui.lblNoEvents:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblNoEvents:SetFont("ZoFontAlert")
    ui.lblNoEvents:SetScale(1)
    ui.lblNoEvents:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblNoEvents:SetDrawLayer(1)
    ui.lblNoEvents:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 0,38)
    ui.lblNoEvents:SetDimensions(600,20)
    ui.lblNoEvents:SetText(L.noEvents)

    GUILD_EVENTS_EVENTS_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)

    GuildEventsUI.selectedGuildId = 1 --Set to 1 as default
    GuildEventsUI:GetEvents()
end

function GuildEventsUI:GetEvents()
    local memberIsAdmin = DoesPlayerHaveGuildPermission(GuildEventsUI.selectedGuildId, GUILD_PERMISSION_SET_MOTD)

    --Hide event buttons
    for key,control in pairs(ui.eventControls) do
        control.btnEvent:SetHidden(true)
        control.btnEventDelete:SetHidden(true)
        control.btnEventInvite:SetHidden(true)
        control.lblEvent:SetHidden(true)
        control.lblAttending:SetHidden(true)
    end

    ui.events = GuildEventsUI:loadEvents()

    if table.getn(ui.events) > 0 then

        ui.lblNoEvents:SetHidden(true)

        local memberIndex = GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId)

        for i=1, table.getn(ui.events) do

            local eventId, eventTitle, eventDate, eventInfo  = GuildEventsUI:getEvent(ui.events[i])
            local isSignedUp = GuildEventsUI:isSignedUp(memberIndex, eventId)

            ui.eventControls[i].lblEvent:SetText(zo_strformat(L.eventLabel, eventTitle, eventDate, eventInfo))
            ui.eventControls[i].lblEvent:SetHidden(false)
            ui.eventControls[i].btnEvent:SetHidden(false)
            ui.eventControls[i].lblAttending:SetHidden(false)
            ui.eventControls[i].lblAttending:SetText(GuildEventsUI:getAttendingText(eventId))

            if memberIsAdmin then
                ui.eventControls[i].btnEventDelete:SetHidden(false)
                ui.eventControls[i].btnEventInvite:SetHidden(false)
                ui.eventControls[i].btnEventInvite:SetHandler("OnClicked", function(h)
                    GuildEvents:inviteAttendees(eventId)
                end)
            end

            if isSignedUp then
                ui.eventControls[i].btnEvent:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                ui.eventControls[i].btnEvent:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                ui.eventControls[i].btnEvent:SetHandler("OnClicked", function(h)
                    GuildEventsUI:unsignUpForEvent(ui.eventControls[i].btnEvent, ui.eventControls[i].lblAttending, eventId)
                end)
            else
                ui.eventControls[i].btnEvent:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                ui.eventControls[i].btnEvent:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                ui.eventControls[i].btnEvent:SetHandler("OnClicked", function(h)
                    confirmEventSignup(ui.eventControls[i].btnEvent, ui.eventControls[i].lblAttending, eventId)
                end)
            end
        end
    else
        ui.lblNoEvents:SetText(zo_strformat(L.noEventsForGuild, GetGuildName(GuildEventsUI.selectedGuildId)))
        ui.lblNoEvents:SetHidden(false)
    end
end

--loadEvents: Loads the events for selected guild into ui.events
function GuildEventsUI:loadEvents()
    local motd = trimString( GetGuildMotD(GuildEventsUI.selectedGuildId) )
    local events = {}
    local count = 1
    local theStart = 1

    if motd == nil then
        --Do nothing
    else
        if string.find(motd, "\n\n") == nil then
            events[count] = motd
        else
            local theSplitStart, theSplitEnd = string.find( motd, "\n\n", theStart )

            while theSplitStart do
                events[count] =  string.sub( motd, theStart, theSplitStart-1 )
                theStart = theSplitEnd + 1
                theSplitStart, theSplitEnd = string.find( motd, "\n\n", theStart )
                count = count + 1
            end

            events[count] = string.sub( motd, theStart )
        end
    end

    -- table GuildEvents.eventList
    for i, event in pairs(events) do
        local eventId, eventTitle, eventDate, eventInfo  = GuildEventsUI:getEvent(event)
        GuildEvents.eventList[eventId] = {
            id = eventId,
            title = eventTitle,
            date = eventDate,
            info = eventInfo
        }
    end

    return events
end

--getEvent(eventDetails): Returns array of [id],[title],[date],[info]
function GuildEventsUI:getEvent(eventDetails)
    local count = 1
    local theStart = 1
    local theSplitStart, theSplitEnd = string.find( eventDetails, "\n", theStart )
    local event = {}

    while theSplitStart do
        event[count] =  string.sub( eventDetails, theStart, theSplitStart-1 )
        theStart = theSplitEnd + 1
        theSplitStart, theSplitEnd = string.find( eventDetails, "\n", theStart )

        if count == 1 then
            --Split and add event ID and title
            local idAndTitle = event[count]
            local theIDSplitStart, theIDSplitEnd = string.find( idAndTitle, "-", 1 )
            event[count] =  string.sub( idAndTitle, 1, theIDSplitStart-1 )
            count = count + 1
            event[count] =  string.sub( idAndTitle, theIDSplitEnd + 1)
        end

        count = count + 1
    end

    event[count] = string.sub( eventDetails, theStart )

    return event[1],event[2],event[3],event[4]
end

--isSignedUp: Returns true if user is signed up
function GuildEventsUI:isSignedUp(memberIndex, eventId)
    local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, memberIndex)
    local memberEvents = trimString( note )

    if memberEvents == nil then
        return false
    end

    local events = memberEvents:split(";")
    for i = 1, #events do
        local tmp = events[i]:split("/")
        if tmp[1] == eventId then
            return true
        end
    end

    return false
end

--signUpForEvent: Signs the member up for the event
function GuildEventsUI:signUpForEvent()
    --signup format #[eventId];[eventId]#
    local eventId = GuildEvents.currentEventId
    local button = GuildEvents.currentBtnEvent
    local lblAttending = GuildEvents.currentLblAttending
    local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId))
    local memberEvents = trimString( note )
    local newNote = ""

    if memberEvents == nil then
        newNote = note.."\n#"..eventId.."/"..GuildEvents.roleSelected.."#"
    else
        newNote = string.sub(note, 1, string.find(note, "#") - 1)

        if memberEvents == "" then
            newNote = newNote.."#"..eventId.."/"..GuildEvents.roleSelected.."#"
        else
            newNote = newNote.."#"..memberEvents..";"..eventId.."/"..GuildEvents.roleSelected.."#"
        end
    end

    SetGuildMemberNote(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId), newNote)

    button:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
    button:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
    button:SetHandler("OnClicked", function(h)
        GuildEventsUI:unsignUpForEvent(button, lblAttending, eventId)
    end)

    -- uncheck selected role
    GuildEventsUI:uncheckSelectedRoles()

end

--unsignUpForEvent: Removed the player from being signed up from that event
function GuildEventsUI:unsignUpForEvent(button, lblAttending, eventId)
    local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId))
    local memberEvents = trimString( note )
    local newNote = ""

    newNote = string.sub(note, 1, string.find(note, "#") - 1)

    local events = memberEvents:split(";")

    if table.getn(events) > 0 then
        local eventNote = ""
        local count = 0
        for i = 1, #events do
            local tmp = events[i]:split("/")
            if tmp[1] ~= eventId then
                if count == 0 then
                    eventNote = eventNote..events[i]
                else
                    eventNote = eventNote..";"..events[i]
                end
                count = count + 1
            end
        end

        if count > 0 then
            newNote = newNote.."#"..eventNote.."#"
        end
    end

    SetGuildMemberNote(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId), newNote)

    button:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
    button:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
    button:SetHandler("OnClicked", function(h)
        GuildEventsUI:signUpForEvent(button, lblAttending, eventId)
    end)

    --Remove from attending
    local attending = GuildEventsUI:getAttendingText(eventId, name)

    lblAttending:SetText(attending)
end

--getAttending: Returns a list of attendees (account name) for an event
function GuildEventsUI:getAttending(eventId, excludeMember)
    local totalMembers = GetNumGuildMembers(GuildEventsUI.selectedGuildId)
    local attending = {}
    for i = 1, totalMembers do
        local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
        if name ~= excludeMember then
            local signUpInfo = GuildEventsUI:getSignUpInfoForEventId(note, eventId)
            if signUpInfo ~= nil then
                table.insert(attending, name)
            end
        end
    end
    return attending
end

--getAttendingText: Returns a string of attendees with color codes to show if member is already in group (account name) for an event
function GuildEventsUI:getAttendingText(eventId, excludeMember)
    local totalMembers = GetNumGuildMembers(GuildEventsUI.selectedGuildId)
    local count = 0
    local attending = L.noAttendees
    for i = 1, totalMembers do
        local name, note, rankIndex, playerStatus = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
        if name ~= excludeMember then
            local signUpInfo = GuildEventsUI:getSignUpInfoForEventId(note, eventId)
            if signUpInfo ~= nil then
                local groupSize = GetGroupSize()
                local displayName = name

                if signUpInfo[2] ~= nil then
                    local roleId = tonumber(signUpInfo[2])
                    if GuildEvents.roles[roleId].icon ~= nil then
                        displayName = displayName .. "|t"..GuildEvents.roles[roleId].icon.x..":"..GuildEvents.roles[roleId].icon.y..":".. GuildEvents.roles[roleId].icon.src .."|t"
                    end
                end

                --Check if player is in group
                if groupSize > 1 then
                    for z=1,GetGroupSize() do
                        local unitTag = GetGroupUnitTagByIndex(z)
                        local rawUnitName = GetRawUnitName(unitTag)
                        local hasCharacter, characterName = GetGuildMemberCharacterInfo(GuildEventsUI.selectedGuildId, i)

                        if rawUnitName == characterName then

                            if playerStatus ~= 4 then
                                displayName = "|C29C310"..displayName.."|r"
                            else
                                displayName = "|C004601"..displayName.."|r"
                            end

                            break
                        end
                    end
                end

                --Check if player is offline
                if playerStatus == 4 then
                    displayName = "|C636563"..displayName.."|r"
                end

                if count == 0 then
                    attending = displayName
                    count = count + 1
                else
                    attending = attending..", "..displayName
                end
            end
        end
    end
    return attending
end

--removeEvent: Removes event and users from being signed up for event
function GuildEventsUI:removeEvent(dialog)
    if dialog.data.event ~= nil then

        -- disable remove event buttons
        eventRemoveStart()

        --Delete event
        local eventIndex = dialog.data.event
        local motd = trimString(GetGuildMotD(GuildEventsUI.selectedGuildId) )
        local events = {}
        local count = 1
        local theStart = 1
        local id = GuildEventsUI:getEvent(ui.events[eventIndex])
        local eventId = tonumber(id)

        -- remove event from GuildEvents.eventList
        GuildEvents.eventList[id] = nil

        if motd ~= nil then
            if string.find(motd, "\n\n") ~= nil then
                local theSplitStart, theSplitEnd = string.find( motd, "\n\n", theStart )
                for i = 1, #ui.events do
                    if i ~= eventIndex then
                        events[count] =  ui.events[i]
                        count = count + 1
                    end
                end
            end
        end

        ui.events = events

        GuildEventsUI:saveEvents()

        --Remove users from signed up event
        local miliseconds = 0
        local notesForUpdate = {}

        for i = 1, GetNumGuildMembers(GuildEventsUI.selectedGuildId) do
            local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
            local memberEvents = trimString(note)
            local newNote = ""

            --check if member has # at all
            if string.find(note, "#") ~= nil then
                newNote = string.sub(note, 1, string.find(note, "#") - 1)
                local events = {}
                local eventsNote = {}
                if memberEvents ~= nil then
                    events = memberEvents:split(";")
                else
                    d("memberEvents is nil")
                end
                if table.getn(events) > 0 then
                    for i = 1, #events do
                        local tmp = events[i]:split("/");
                        -- if event is still present (can remove events that where deleted but not all notes completely updated)
                        if GuildEvents.eventList[tmp[1]] ~= nil then
                            -- if event is not the one removed (probably not used any more because of GuildEvents.eventList)
                            if tonumber(tmp[1]) ~= tonumber(eventId) then
                                table.insert(eventsNote, events[i])
                            end
                        end
                    end
                end

                if #eventsNote > 0 then
                    newNote = newNote.."#"..table.concat(eventsNote, ";").."#"
                end

                -- if note changed
                if note ~= newNote then
                    table.insert(notesForUpdate, {selectedGuildId=GuildEventsUI.selectedGuildId, i=i, newNote=newNote})
                end
            end
        end

        showProgressDialog(#notesForUpdate)

        -- update notes
        for k, v in pairs(notesForUpdate) do
            zo_callLater(function () GuildEvents:updateGuildMemberNote(v.selectedGuildId, v.i, v.newNote, true) end, miliseconds)
            miliseconds = miliseconds + 10000
        end

        zo_callLater(function () eventRemoveEnd() end, miliseconds)

    end
end

--saveEvents: Saves events to the guild MOTD
function GuildEventsUI:saveEvents()
    --event format #[id]-[title]\n[date]\n[info]\n\n[id]-[title]\n[date]\n[info]#'

    local motd = GetGuildMotD(GuildEventsUI.selectedGuildId)

    if string.find(motd, "#") == nil then
        motd = motd.."\n#"
    end

    motd = string.sub(motd, 1, string.find(motd, "\n#") - 1)

    local newMotd = ""

    if table.getn(ui.events) > 0 then
        newMotd = motd.."\n#"

        for i = 1, #ui.events do
            if i == 1 then
                newMotd = newMotd..ui.events[i]
            else
                newMotd = newMotd.."\n\n"..ui.events[i]
            end
        end

        newMotd = newMotd.."#"
    else
        newMotd = motd
    end

    SetGuildMotD(GuildEventsUI.selectedGuildId, newMotd)
end

--Invite Attendees
function GuildEvents:inviteAttendees(eventId)
    local name = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId))
    local members = GuildEventsUI:getAttending(eventId)
    local membersToInvite = {}
    local count = 0
    local memberToInviteCount = 0

    if next(members) == nil then
        d(L.noAttendeesToInvite)
        return
    end

    --Filter member list to only invite members that are not in group
    for i = 1, #members do
        if members[i] ~= name then

            --Check if player is in group
            local isMemberInGroup = false
            local isMemberOffline = false

            for z=1, GetGroupSize() do
                local unitTag = GetGroupUnitTagByIndex(z)
                local rawUnitName = GetRawUnitName(unitTag)
                local hasCharacter, characterName = GetGuildMemberCharacterInfo(GuildEventsUI.selectedGuildId, i)

                if rawUnitName == characterName then
                    isMemberInGroup = true
                    break
                end
            end

            --Check if player is offline
            for z=1, GetNumGuildMembers(GuildEventsUI.selectedGuildId) do
                local memberName, memberNote, memberRankIndex, memberPlayerStatus  = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, z)

                if memberName == members[i] then
                    if memberPlayerStatus == 4 then
                        isMemberOffline = true
                    end
                    break
                end
            end

            if isMemberInGroup == false and isMemberOffline == false then
                memberToInviteCount = memberToInviteCount + 1
                membersToInvite[memberToInviteCount] = members[i]
            end
        end
    end

    --Invite members that need to be invited
    for i = 1, #membersToInvite do
        if membersToInvite[i] ~= name then
            count = count + 1
            GroupInviteByName(membersToInvite[i])
        end
    end

    if count > 0 then
        local membersInvitedText = ""
        for i = 1, #membersToInvite do
            if i == 1 then
                membersInvitedText = membersToInvite[i]
            else
                membersInvitedText = membersInvitedText..","..membersToInvite[i]
            end

        end
        d(zo_strformat(L.invitedAttendees, count))
        d(zo_strformat(L.invitedSummary, membersInvitedText))
    else
        d(L.noOneElseToInvite)
    end
    --zo_callLater(function() GuildEvents:inviteAttendees() end, 2000)
end

-- toggle Role on event sign up
function GuildEventsUI:toggleRole()
    if self ~= nil then
        local parent = self:GetParent()
        local control
        -- remove selection
        for num,role in pairs(GuildEvents.roles) do
            if role.controlName ~= nil then
                control = GetControl(parent:GetName(), role.controlName)
                if control ~= nil then
                    if control:GetName() ~= self:GetName() then
                        control:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    else
                        control:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                        GuildEvents.roleSelected = num
                    end
                end
            end
        end
    end
end

-- Uncheck all roles in GuildEventsSignupDialog
function GuildEventsUI.uncheckSelectedRoles()
    for num,role in pairs(GuildEvents.roles) do
        if role.controlName ~= nil then
            local control = GetControl('GuildEventsSignupDialogContent', role.controlName)
            if control ~= nil then
                control:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
            end
        end
    end
end

--isSignedUp: Returns true if user is signed up
function GuildEventsUI:getSignUpInfoForEventId(note, eventId)
    local memberEvents = trimString(note)
    if memberEvents ~= nil then
        local events = memberEvents:split(";")
        for i = 1, #events do
            local tmp = events[i]:split("/")
            if tmp[1] == eventId then
                return tmp
            end
        end
    end
    return nil
end

function GuildEvents:updateGuildMemberNote(guildId, i, newNote, progress)
    if progress == true then
        if GuildEventsProgressDialogProgressBar ~= nil then
            local progressValue = GuildEventsProgressDialogProgressBar:GetValue()+1
            GuildEventsProgressDialogProgressBar:SetValue(progressValue)
        end
    end
    SetGuildMemberNote(guildId, i, newNote)
end

function activateEventDeleteButtons()
    for key,control in pairs(ui.eventControls) do
        control.btnEventDelete:SetEnabled(true)
    end
end

function deactivateEventDeleteButtons()
    for key,control in pairs(ui.eventControls) do
        control.btnEventDelete:SetEnabled(false)
    end
end

function eventRemoveStart()
    deactivateEventDeleteButtons()
end

function eventRemoveEnd()
    hideProgressDialog()
    activateEventDeleteButtons()
end













