GuildEventsUI = GuildEventsUI or {}
GuildEventsUI.events = {}

local ui = GuildEventsUI.events
local wm = WINDOW_MANAGER

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
        title = { text = "Delete Event"  },
        mainText = { text = "Delete this event?" },
        setup = function(dialog, data)
            --preventerVars.askBeforeEquipDialogRetVal = false
            --Format the dialog text: Show the item's name inside
            --local itemLink = GetItemLink(data.bag, data.slot)
            --local params = {itemLink}
            --local formattedText = GetFormattedDialogText(localizationVars.fcois_loc["options_anti_equip_question"], params)
            descLabel:SetText("Are you sure you want to delete this event?")
        end,
        noChoiceCallback = function(dialog)
            --Simulate the button "cancel" click
            --preventerVars.askBeforeEquipDialogRetVal = false
        end,
        buttons =
        {
            {
                control = acceptBtn,
                text = SI_DIALOG_ACCEPT,
                keybind = "DIALOG_PRIMARY",
                callback = function(dialog) GuildEventsUI:removeEvent(dialog) end,
            },
            {
                control = cancelBtn,
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
                callback = function(dialog)
                    --preventerVars.askBeforeEquipDialogRetVal = false
                end,
            },
        },
    })
end

--Shows event delete confirmation window
local function confirmEventDelete(eventIndex)
    ZO_Dialogs_ShowDialog("GUILDEVENTS_EVENT_DELETE_DIALOG", {event=eventIndex})
end

------------------------------------------------
--- Methods
------------------------------------------------
function GuildEventsUI:CreateEvents()

    ui.main = wm:CreateTopLevelWindow("GuildEventsEventsFragment")
    ui.main:SetAnchor(TOPRIGHT, ZO_GroupList, TOPRIGHT, -40, 60)
    ui.main:SetHidden(true)
    ui.main:SetWidth(600)

    --Event Delete Confirmation Dialog
    GuildEventsEventDeleteConfirmationInitialize(GuildEventsEventDeleteConfirmation)

    --Event Controls
    ui.lblNoEvents = wm:CreateControl("GuildEvents_lblNoEvents", ui.main, CT_LABEL)
    ui.btnEvent1 = wm:CreateControl("GuildEvents_btnEvent1", ui.main, CT_BUTTON)
    ui.btnEvent2 = wm:CreateControl("GuildEvents_btnEvent2", ui.main, CT_BUTTON)
    ui.btnEvent3 = wm:CreateControl("GuildEvents_btnEvent3", ui.main, CT_BUTTON)
    ui.btnEvent4 = wm:CreateControl("GuildEvents_btnEvent4", ui.main, CT_BUTTON)
    ui.btnEvent5 = wm:CreateControl("GuildEvents_btnEvent5", ui.main, CT_BUTTON)
    ui.btnEventDelete1 = wm:CreateControl("GuildEvents_btnEventDelete1", ui.main, CT_BUTTON)
    ui.btnEventDelete2 = wm:CreateControl("GuildEvents_btnEventDelete2", ui.main, CT_BUTTON)
    ui.btnEventDelete3 = wm:CreateControl("GuildEvents_btnEventDelete3", ui.main, CT_BUTTON)
    ui.btnEventDelete4 = wm:CreateControl("GuildEvents_btnEventDelete4", ui.main, CT_BUTTON)
    ui.btnEventDelete5 = wm:CreateControl("GuildEvents_btnEventDelete5", ui.main, CT_BUTTON)
    ui.btnEventInvite1 = wm:CreateControl("GuildEvents_btnEventInvite1", ui.main, CT_BUTTON)
    ui.btnEventInvite2 = wm:CreateControl("GuildEvents_btnEventInvite2", ui.main, CT_BUTTON)
    ui.btnEventInvite3 = wm:CreateControl("GuildEvents_btnEventInvite3", ui.main, CT_BUTTON)
    ui.btnEventInvite4 = wm:CreateControl("GuildEvents_btnEventInvite4", ui.main, CT_BUTTON)
    ui.btnEventInvite5 = wm:CreateControl("GuildEvents_btnEventInvite5", ui.main, CT_BUTTON)
    ui.lblEvent1 = wm:CreateControl("GuildEvents_lblEvent1", ui.main, CT_LABEL)
    ui.lblEvent2 = wm:CreateControl("GuildEvents_lblEvent2", ui.main, CT_LABEL)
    ui.lblEvent3 = wm:CreateControl("GuildEvents_lblEvent3", ui.main, CT_LABEL)
    ui.lblEvent4 = wm:CreateControl("GuildEvents_lblEvent4", ui.main, CT_LABEL)
    ui.lblEvent5 = wm:CreateControl("GuildEvents_lblEvent5", ui.main, CT_LABEL)
    ui.lblAttending1 = wm:CreateControl("GuildEvents_lblAttending1", ui.main, CT_LABEL)
    ui.lblAttending2 = wm:CreateControl("GuildEvents_lblAttending2", ui.main, CT_LABEL)
    ui.lblAttending3 = wm:CreateControl("GuildEvents_lblAttending3", ui.main, CT_LABEL)
    ui.lblAttending4 = wm:CreateControl("GuildEvents_lblAttending4", ui.main, CT_LABEL)
    ui.lblAttending5 = wm:CreateControl("GuildEvents_lblAttending5", ui.main, CT_LABEL)

    --No Events label
    ui.lblNoEvents:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblNoEvents:SetFont("ZoFontAlert")
    ui.lblNoEvents:SetScale(1)
    ui.lblNoEvents:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblNoEvents:SetDrawLayer(1)
    ui.lblNoEvents:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 0,38)
    ui.lblNoEvents:SetDimensions(600,20)
    ui.lblNoEvents:SetText("No Events")

    --Event 1
    ui.btnEvent1:SetDimensions(20,20)
    ui.btnEvent1:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 0,40)
    ui.btnEvent1:SetAlpha(1)
    ui.btnEvent1:SetDrawLayer(1)
    ui.btnEvent1:SetFont("ZoFontAlert")
    ui.btnEvent1:SetScale(1)
    ui.btnEvent1:SetText("")
    ui.btnEvent1:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    ui.btnEvent1:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
    ui.btnEvent1:SetHidden(true)

    ui.btnEventDelete1:SetDimensions(25,25)
    ui.btnEventDelete1:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 580,40)
    ui.btnEventDelete1:SetAlpha(1)
    ui.btnEventDelete1:SetDrawLayer(1)
    ui.btnEventDelete1:SetFont("ZoFontAlert")
    ui.btnEventDelete1:SetScale(1)
    ui.btnEventDelete1:SetText("")
    ui.btnEventDelete1:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    ui.btnEventDelete1:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    ui.btnEventDelete1:SetHidden(true)
    ui.btnEventDelete1:SetHandler("OnClicked", function(h)
        --GuildEventsUI:removeEvent(1)
        confirmEventDelete(1)
    end)

    ui.btnEventInvite1:SetDimensions(50,45)
    ui.btnEventInvite1:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 540,30)
    ui.btnEventInvite1:SetAlpha(1)
    ui.btnEventInvite1:SetDrawLayer(1)
    ui.btnEventInvite1:SetFont("ZoFontAlert")
    ui.btnEventInvite1:SetScale(1)
    ui.btnEventInvite1:SetText("")
    ui.btnEventInvite1:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
    ui.btnEventInvite1:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
    ui.btnEventInvite1:SetHidden(true)

    ui.lblEvent1:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEvent1:SetFont("ZoFontAlert")
    ui.lblEvent1:SetScale(1)
    ui.lblEvent1:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblEvent1:SetDrawLayer(1)
    ui.lblEvent1:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,38)
    ui.lblEvent1:SetDimensions(530,20)

    ui.lblAttending1:SetColor(0.8, 0.8, 0.8, 1)
    ui.lblAttending1:SetFont("ZoFontAlert")
    ui.lblAttending1:SetScale(0.6)
    ui.lblAttending1:SetWrapMode(TEX_MODE_WRAP)
    ui.lblAttending1:SetDrawLayer(1)
    ui.lblAttending1:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,65)
    ui.lblAttending1:SetDimensions(920,80)

    --Event 2
    ui.btnEvent2:SetDimensions(20,20)
    ui.btnEvent2:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 0,100)
    ui.btnEvent2:SetAlpha(1)
    ui.btnEvent2:SetDrawLayer(1)
    ui.btnEvent2:SetFont("ZoFontAlert")
    ui.btnEvent2:SetScale(1)
    ui.btnEvent2:SetText("")
    ui.btnEvent2:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    ui.btnEvent2:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
    ui.btnEvent2:SetHidden(true)

    ui.btnEventDelete2:SetDimensions(25,25)
    ui.btnEventDelete2:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 580,100)
    ui.btnEventDelete2:SetAlpha(1)
    ui.btnEventDelete2:SetDrawLayer(1)
    ui.btnEventDelete2:SetFont("ZoFontAlert")
    ui.btnEventDelete2:SetScale(1)
    ui.btnEventDelete2:SetText("")
    ui.btnEventDelete2:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    ui.btnEventDelete2:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    ui.btnEventDelete2:SetHidden(true)
    ui.btnEventDelete2:SetHandler("OnClicked", function(h)
        --GuildEventsUI:removeEvent(2)
        confirmEventDelete(2)
    end)

    ui.btnEventInvite2:SetDimensions(50,45)
    ui.btnEventInvite2:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 540,90)
    ui.btnEventInvite2:SetAlpha(1)
    ui.btnEventInvite2:SetDrawLayer(1)
    ui.btnEventInvite2:SetFont("ZoFontAlert")
    ui.btnEventInvite2:SetScale(1)
    ui.btnEventInvite2:SetText("")
    ui.btnEventInvite2:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
    ui.btnEventInvite2:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
    ui.btnEventInvite2:SetHidden(true)

    ui.lblEvent2:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEvent2:SetFont("ZoFontAlert")
    ui.lblEvent2:SetScale(1)
    ui.lblEvent2:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblEvent2:SetDrawLayer(1)
    ui.lblEvent2:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,98)
    ui.lblEvent2:SetDimensions(530,20)

    ui.lblAttending2:SetColor(0.8, 0.8, 0.8, 1)
    ui.lblAttending2:SetFont("ZoFontAlert")
    ui.lblAttending2:SetScale(0.6)
    ui.lblAttending2:SetWrapMode(TEX_MODE_WRAP)
    ui.lblAttending2:SetDrawLayer(1)
    ui.lblAttending2:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,125)
    ui.lblAttending2:SetDimensions(920,80)

    --Event 3
    ui.btnEvent3:SetDimensions(20,20)
    ui.btnEvent3:SetAnchor(TOPLEFT, suw, TOPLEFT, 0,160)
    ui.btnEvent3:SetAlpha(1)
    ui.btnEvent3:SetDrawLayer(1)
    ui.btnEvent3:SetFont("ZoFontAlert")
    ui.btnEvent3:SetScale(1)
    ui.btnEvent3:SetText("")
    ui.btnEvent3:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    ui.btnEvent3:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
    ui.btnEvent3:SetHidden(true)

    ui.btnEventDelete3:SetDimensions(25,25)
    ui.btnEventDelete3:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 580,160)
    ui.btnEventDelete3:SetAlpha(1)
    ui.btnEventDelete3:SetDrawLayer(1)
    ui.btnEventDelete3:SetFont("ZoFontAlert")
    ui.btnEventDelete3:SetScale(1)
    ui.btnEventDelete3:SetText("")
    ui.btnEventDelete3:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    ui.btnEventDelete3:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    ui.btnEventDelete3:SetHidden(true)
    ui.btnEventDelete3:SetHandler("OnClicked", function(h)
        --GuildEventsUI:removeEvent(3)
        confirmEventDelete(3)
    end)

    ui.btnEventInvite3:SetDimensions(50,45)
    ui.btnEventInvite3:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 540,150)
    ui.btnEventInvite3:SetAlpha(1)
    ui.btnEventInvite3:SetDrawLayer(1)
    ui.btnEventInvite3:SetFont("ZoFontAlert")
    ui.btnEventInvite3:SetScale(1)
    ui.btnEventInvite3:SetText("")
    ui.btnEventInvite3:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
    ui.btnEventInvite3:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
    ui.btnEventInvite3:SetHidden(true)

    ui.lblEvent3:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEvent3:SetFont("ZoFontAlert")
    ui.lblEvent3:SetScale(1)
    ui.lblEvent3:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblEvent3:SetDrawLayer(1)
    ui.lblEvent3:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,158)
    ui.lblEvent3:SetDimensions(530,20)

    ui.lblAttending3:SetColor(0.8, 0.8, 0.8, 1)
    ui.lblAttending3:SetFont("ZoFontAlert")
    ui.lblAttending3:SetScale(0.6)
    ui.lblAttending3:SetWrapMode(TEX_MODE_WRAP)
    ui.lblAttending3:SetDrawLayer(1)
    ui.lblAttending3:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,185)
    ui.lblAttending3:SetDimensions(920,80)

    --Event 4
    ui.btnEvent4:SetDimensions(20,20)
    ui.btnEvent4:SetAnchor(TOPLEFT, suw, TOPLEFT, 0,220)
    ui.btnEvent4:SetAlpha(1)
    ui.btnEvent4:SetDrawLayer(1)
    ui.btnEvent4:SetFont("ZoFontAlert")
    ui.btnEvent4:SetScale(1)
    ui.btnEvent4:SetText("")
    ui.btnEvent4:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    ui.btnEvent4:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
    ui.btnEvent4:SetHidden(true)

    ui.btnEventDelete4:SetDimensions(25,25)
    ui.btnEventDelete4:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 580,220)
    ui.btnEventDelete4:SetAlpha(1)
    ui.btnEventDelete4:SetDrawLayer(1)
    ui.btnEventDelete4:SetFont("ZoFontAlert")
    ui.btnEventDelete4:SetScale(1)
    ui.btnEventDelete4:SetText("")
    ui.btnEventDelete4:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    ui.btnEventDelete4:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    ui.btnEventDelete4:SetHidden(true)
    ui.btnEventDelete4:SetHandler("OnClicked", function(h)
        --GuildEventsUI:removeEvent(4)
        confirmEventDelete(4)
    end)

    ui.btnEventInvite4:SetDimensions(50,45)
    ui.btnEventInvite4:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 540,210)
    ui.btnEventInvite4:SetAlpha(1)
    ui.btnEventInvite4:SetDrawLayer(1)
    ui.btnEventInvite4:SetFont("ZoFontAlert")
    ui.btnEventInvite4:SetScale(1)
    ui.btnEventInvite4:SetText("")
    ui.btnEventInvite4:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
    ui.btnEventInvite4:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
    ui.btnEventInvite4:SetHidden(true)

    ui.lblEvent4:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEvent4:SetFont("ZoFontAlert")
    ui.lblEvent4:SetScale(1)
    ui.lblEvent4:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblEvent4:SetDrawLayer(1)
    ui.lblEvent4:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,218)
    ui.lblEvent4:SetDimensions(530,20)

    ui.lblAttending4:SetColor(0.8, 0.8, 0.8, 1)
    ui.lblAttending4:SetFont("ZoFontAlert")
    ui.lblAttending4:SetScale(0.6)
    ui.lblAttending4:SetWrapMode(TEX_MODE_WRAP)
    ui.lblAttending4:SetDrawLayer(1)
    ui.lblAttending4:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,245)
    ui.lblAttending4:SetDimensions(920,80)

    --Event 5
    ui.btnEvent5:SetDimensions(20,20)
    ui.btnEvent5:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 0,280)
    ui.btnEvent5:SetAlpha(1)
    ui.btnEvent5:SetDrawLayer(1)
    ui.btnEvent5:SetFont("ZoFontAlert")
    ui.btnEvent5:SetScale(1)
    ui.btnEvent5:SetText("")
    ui.btnEvent5:SetNormalTexture("/esoui/art/buttons/edit_up.dds")
    ui.btnEvent5:SetMouseOverTexture("/esoui/art/buttons/edit_over.dds")
    ui.btnEvent5:SetHidden(true)

    ui.btnEventDelete5:SetDimensions(25,25)
    ui.btnEventDelete5:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 580,280)
    ui.btnEventDelete5:SetAlpha(1)
    ui.btnEventDelete5:SetDrawLayer(1)
    ui.btnEventDelete5:SetFont("ZoFontAlert")
    ui.btnEventDelete5:SetScale(1)
    ui.btnEventDelete5:SetText("")
    ui.btnEventDelete5:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    ui.btnEventDelete5:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    ui.btnEventDelete5:SetHidden(true)
    ui.btnEventDelete5:SetHandler("OnClicked", function(h)
        --GuildEventsUI:removeEvent(5)
        confirmEventDelete(5)
    end)

    ui.btnEventInvite5:SetDimensions(50,45)
    ui.btnEventInvite5:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 540,270)
    ui.btnEventInvite5:SetAlpha(1)
    ui.btnEventInvite5:SetDrawLayer(1)
    ui.btnEventInvite5:SetFont("ZoFontAlert")
    ui.btnEventInvite5:SetScale(1)
    ui.btnEventInvite5:SetText("")
    ui.btnEventInvite5:SetNormalTexture("/esoui/art/hud/radialicon_invitegroup_up.dds")
    ui.btnEventInvite5:SetMouseOverTexture("/esoui/art/hud/radialicon_invitegroup_over.dds")
    ui.btnEventInvite5:SetHidden(true)

    ui.lblEvent5:SetColor(1.0, 1.0, 1.0, 1)
    ui.lblEvent5:SetFont("ZoFontAlert")
    ui.lblEvent5:SetScale(1)
    ui.lblEvent5:SetWrapMode(TEX_MODE_CLAMP)
    ui.lblEvent5:SetDrawLayer(1)
    ui.lblEvent5:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,278)
    ui.lblEvent5:SetDimensions(530,20)

    ui.lblAttending5:SetColor(0.8, 0.8, 0.8, 1)
    ui.lblAttending5:SetFont("ZoFontAlert")
    ui.lblAttending5:SetScale(0.6)
    ui.lblAttending5:SetWrapMode(TEX_MODE_WRAP)
    ui.lblAttending5:SetDrawLayer(1)
    ui.lblAttending5:SetAnchor(TOPLEFT, ui.main, TOPLEFT, 25,305)
    ui.lblAttending5:SetDimensions(920,80)

    GUILD_EVENTS_EVENTS_FRAGMENT = ZO_FadeSceneFragment:New(ui.main)

    GuildEventsUI.selectedGuildId = 1 --Set to 1 as default
    GuildEventsUI:GetEvents()
end

function GuildEventsUI:GetEvents()
    local memberIsAdmin = DoesPlayerHaveGuildPermission(GuildEventsUI.selectedGuildId, 6)

    --Hide event buttons
    ui.btnEvent1:SetHidden(true)
    ui.btnEvent2:SetHidden(true)
    ui.btnEvent3:SetHidden(true)
    ui.btnEvent4:SetHidden(true)
    ui.btnEvent5:SetHidden(true)
    ui.btnEventDelete1:SetHidden(true)
    ui.btnEventDelete2:SetHidden(true)
    ui.btnEventDelete3:SetHidden(true)
    ui.btnEventDelete4:SetHidden(true)
    ui.btnEventDelete5:SetHidden(true)
    ui.btnEventInvite1:SetHidden(true)
    ui.btnEventInvite2:SetHidden(true)
    ui.btnEventInvite3:SetHidden(true)
    ui.btnEventInvite4:SetHidden(true)
    ui.btnEventInvite5:SetHidden(true)
    ui.lblEvent1:SetHidden(true)
    ui.lblEvent2:SetHidden(true)
    ui.lblEvent3:SetHidden(true)
    ui.lblEvent4:SetHidden(true)
    ui.lblEvent5:SetHidden(true)
    ui.lblAttending1:SetHidden(true)
    ui.lblAttending2:SetHidden(true)
    ui.lblAttending3:SetHidden(true)
    ui.lblAttending4:SetHidden(true)
    ui.lblAttending5:SetHidden(true)

    ui.events = GuildEventsUI:loadEvents()

    if table.getn(ui.events) > 0 then

        ui.lblNoEvents:SetHidden(true)

        local memberIndex = GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId)

        for i=1, table.getn(ui.events) do

            local eventId, eventTitle, eventDate, eventTime  = GuildEventsUI:getEvent(ui.events[i])
            local isSignedUp = GuildEventsUI:isSignedUp(memberIndex, eventId)

            if i == 1 then
                ui.lblEvent1:SetText(eventTitle..": "..eventDate.." at "..eventTime)
                ui.lblEvent1:SetHidden(false)
                ui.btnEvent1:SetHidden(false)
                ui.lblAttending1:SetHidden(false)
                ui.lblAttending1:SetText(GuildEventsUI:getAttendingText(eventId))

                if memberIsAdmin then
                    ui.btnEventDelete1:SetHidden(false)
                    ui.btnEventInvite1:SetHidden(false)
                    ui.btnEventInvite1:SetHandler("OnClicked", function(h)
                        GuildEvents:inviteAttendees(eventId)
                    end)
                end

                if isSignedUp then
                    ui.btnEvent1:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                    ui.btnEvent1:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent1:SetHandler("OnClicked", function(h)
                        GuildEventsUI:unsignUpForEvent(ui.btnEvent1, ui.lblAttending1, eventId)
                    end)
                else
                    ui.btnEvent1:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    ui.btnEvent1:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent1:SetHandler("OnClicked", function(h)
                        GuildEventsUI:signUpForEvent(ui.btnEvent1, ui.lblAttending1, eventId)
                    end)
                end

            elseif i == 2 then
                ui.lblEvent2:SetText(eventTitle..": "..eventDate.." at "..eventTime)
                ui.lblEvent2:SetHidden(false)
                ui.btnEvent2:SetHidden(false)
                ui.lblAttending2:SetHidden(false)
                ui.lblAttending2:SetText(GuildEventsUI:getAttendingText(eventId))

                if memberIsAdmin then
                    ui.btnEventDelete2:SetHidden(false)
                    ui.btnEventInvite2:SetHidden(false)
                    ui.btnEventInvite2:SetHandler("OnClicked", function(h)
                        GuildEvents:inviteAttendees(eventId)
                    end)
                end

                if isSignedUp then
                    ui.btnEvent2:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                    ui.btnEvent2:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent2:SetHandler("OnClicked", function(h)
                        GuildEventsUI:unsignUpForEvent(ui.btnEvent2, ui.lblAttending2, eventId)
                    end)
                else
                    ui.btnEvent2:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    ui.btnEvent2:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent2:SetHandler("OnClicked", function(h)
                        GuildEventsUI:signUpForEvent(ui.btnEvent2, ui.lblAttending2, eventId)
                    end)
                end

            elseif i == 3 then
                ui.lblEvent3:SetText(eventTitle..": "..eventDate.." at "..eventTime)
                ui.lblEvent3:SetHidden(false)
                ui.btnEvent3:SetHidden(false)
                ui.lblAttending3:SetHidden(false)
                ui.lblAttending3:SetText(GuildEventsUI:getAttendingText(eventId))

                if memberIsAdmin then
                    ui.btnEventDelete3:SetHidden(false)
                    ui.btnEventInvite3:SetHidden(false)
                    ui.btnEventInvite3:SetHandler("OnClicked", function(h)
                        GuildEvents:inviteAttendees(eventId)
                    end)
                end

                if isSignedUp then
                    ui.btnEvent3:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                    ui.btnEvent3:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent3:SetHandler("OnClicked", function(h)
                        GuildEventsUI:unsignUpForEvent(ui.btnEvent3, ui.lblAttending3, eventId)
                    end)
                else
                    ui.btnEvent3:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    ui.btnEvent3:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent3:SetHandler("OnClicked", function(h)
                        GuildEventsUI:signUpForEvent(ui.btnEvent3, ui.lblAttending3, eventId)
                    end)
                end

            elseif i == 4 then
                ui.lblEvent4:SetText(eventTitle..": "..eventDate.." at "..eventTime)
                ui.lblEvent4:SetHidden(false)
                ui.btnEvent4:SetHidden(false)
                ui.lblAttending4:SetHidden(false)
                ui.lblAttending4:SetText(GuildEventsUI:getAttendingText(eventId))

                if memberIsAdmin then
                    ui.btnEventDelete4:SetHidden(false)
                    ui.btnEventInvite4:SetHidden(false)
                    ui.btnEventInvite4:SetHandler("OnClicked", function(h)
                        GuildEvents:inviteAttendees(eventId)
                    end)
                end

                if isSignedUp then
                    ui.btnEvent4:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                    ui.btnEvent4:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent4:SetHandler("OnClicked", function(h)
                        GuildEventsUI:unsignUpForEvent(ui.btnEvent4, ui.lblAttending4, eventId)
                    end)
                else
                    ui.btnEvent4:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    ui.btnEvent4:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent4:SetHandler("OnClicked", function(h)
                        GuildEventsUI:signUpForEvent(ui.btnEvent4, ui.lblAttending4, eventId)
                    end)
                end

            elseif i == 5 then
                ui.lblEvent5:SetText(eventTitle..": "..eventDate.." at "..eventTime)
                ui.lblEvent5:SetHidden(false)
                ui.btnEvent5:SetHidden(false)
                ui.lblAttending5:SetHidden(false)
                ui.lblAttending5:SetText(GuildEventsUI:getAttendingText(eventId))

                if memberIsAdmin then
                    ui.btnEventDelete5:SetHidden(false)
                    ui.btnEventInvite5:SetHidden(false)
                    ui.btnEventInvite5:SetHandler("OnClicked", function(h)
                        GuildEvents:inviteAttendees(eventId)
                    end)
                end

                if isSignedUp then
                    ui.btnEvent5:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
                    ui.btnEvent5:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent5:SetHandler("OnClicked", function(h)
                        GuildEventsUI:unsignUpForEvent(ui.btnEvent5, ui.lblAttending5, eventId)
                    end)
                else
                    ui.btnEvent5:SetNormalTexture("/esoui/art/buttons/checkbox_unchecked.dds")
                    ui.btnEvent5:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
                    ui.btnEvent5:SetHandler("OnClicked", function(h)
                        GuildEventsUI:signUpForEvent(ui.btnEvent5, ui.lblAttending5, eventId)
                    end)
                end
            end
        end
    else
        ui.lblNoEvents:SetText("No events for "..GetGuildName(GuildEventsUI.selectedGuildId))
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

    return events
end

--getEvent(eventDetails): Returns array of [id],[title],[date],[time]
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
        if events[i] == eventId then
            return true
        end
    end

    return false
end

--signUpForEvent: Signs the member up for the event
function GuildEventsUI:signUpForEvent(button, lblAttending, eventId)
    --signup format #[eventId];[eventId]#

    local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId))
    local memberEvents = trimString( note )
    local newNote = ""

    if memberEvents == nil then
        newNote = note.."\n#"..eventId.."#"
    else
        newNote = string.sub(note, 1, string.find(note, "#") - 1)

        if memberEvents == "" then
            newNote = newNote.."#"..eventId.."#"
        else
            newNote = newNote.."#"..memberEvents..";"..eventId.."#"
        end
    end

    SetGuildMemberNote(GuildEventsUI.selectedGuildId, GetPlayerGuildMemberIndex(GuildEventsUI.selectedGuildId), newNote)

    button:SetNormalTexture("/esoui/art/buttons/checkbox_checked.dds")
    button:SetMouseOverTexture("/esoui/art/buttons/checkbox_mouseover.dds")
    button:SetHandler("OnClicked", function(h)
        GuildEventsUI:unsignUpForEvent(button, lblAttending, eventId)
    end)

    --Add to attending
    --local attending = lblAttending:GetText()
    --if attending == "No attendees" then
    --    lblAttending:SetText(name)
    --else
    --    lblAttending:SetText(attending.."\n"..name)
    --end

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
            if events[i] ~= eventId then
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
    local attending = GuildEventsUI:getAttending(eventId)
    local members = attending:split(",")
    local count = 0
    for i = 1, #members do
        if members[i] ~= name then
            if count == 0 then
                attending = members[i]
                count = count + 1
            else
                attending = attending..","..members[i]
            end
        end
    end

    lblAttending:SetText(attending)
end

--getAttending: Returns a string of attendees (account name) for an event
function GuildEventsUI:getAttending(eventId)
    local totalMembers = GetNumGuildMembers(GuildEventsUI.selectedGuildId)
    local count = 0
    local attending = "No attendees"

    for i = 1, totalMembers do
        local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
        local isAttending = GuildEventsUI:isSignedUp(i, eventId)

        if isAttending then
            if count == 0 then
                attending = name
                count = count + 1
            else
                attending = attending..","..name
            end
        end
    end

    return attending
end

--getAttending: Returns a string of attendees with color codes to show if memver is already in group (account name) for an event
function GuildEventsUI:getAttendingText(eventId)
    local totalMembers = GetNumGuildMembers(GuildEventsUI.selectedGuildId)
    local count = 0
    local attending = "No attendees"

    for i = 1, totalMembers do
        local name, note, rankIndex, playerStatus = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
        local isAttending = GuildEventsUI:isSignedUp(i, eventId)

        if isAttending then
            local groupSize = GetGroupSize()

            --Check if player is in group
            if groupSize > 1 then
                for z=1,GetGroupSize() do
                    local unitTag = GetGroupUnitTagByIndex(z)
                    local rawUnitName = GetRawUnitName(unitTag)
                    local hasCharacter, characterName = GetGuildMemberCharacterInfo(GuildEventsUI.selectedGuildId, i)

                    if rawUnitName == characterName then

                        if playerStatus ~= 4 then
                            name = "|C29C310"..name.."|r"
                        else
                            name = "|C004601"..name.."|r"
                        end

                        break
                    end
                end
            end

            --Check if player is offline
            if playerStatus == 4 then
                name = "|C636563"..name.."|r"
            end

            if count == 0 then
                attending = name
                count = count + 1
            else
                attending = attending..","..name
            end
        end
    end

    return attending
end

--removeEvent: Removes event and users from being signed up for event
function GuildEventsUI:removeEvent(dialog)
    if dialog.data.event ~= nil then
        --Delete event
        local eventIndex = dialog.data.event
        local motd = trimString( GetGuildMotD(GuildEventsUI.selectedGuildId) )
        local events = {}
        local count = 1
        local theStart = 1
        local id = GuildEventsUI:getEvent(ui.events[eventIndex])
        local eventId = tonumber(id)

        if motd == nil then
            --Do nothing
        else
            if string.find(motd, "\n\n") == nil then
                --Do nothing
            else
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
        for i = 1, GetNumGuildMembers(GuildEventsUI.selectedGuildId) do
            local name, note = GetGuildMemberInfo(GuildEventsUI.selectedGuildId, i)
            local memberEvents = trimString( note )
            local newNote = ""

            --check if member has # at all
            if string.find(note, "#") == nil then
                --no changes needed
            else
                newNote = string.sub(note, 1, string.find(note, "#") - 1)

                local events = memberEvents:split(";")
                local count = 0
                local eventsNote = ""

                if table.getn(events) > 0 then
                    for i = 1, #events do
                        local id = tonumber(events[i])

                        if id ~= eventId then
                            if count == 0 then
                                eventsNote = eventsNote..events[i]
                            else
                                eventsNote = eventsNote..";"..events[i]
                            end

                            count = count + 1
                        end
                    end
                end

                if count > 0 then
                    newNote = newNote.."#"..eventsNote.."#"
                end

                local noteCompare = "#"..memberEvents.."#"
                if noteCompare ~= newNote then
                    zo_callLater(function () SetGuildMemberNote(GuildEventsUI.selectedGuildId, i, newNote) end, miliseconds)
                    miliseconds = miliseconds + 10000
                end
            end
        end
    end
end

--saveEvents: Saves events to the guild MOTD
function GuildEventsUI:saveEvents()
    --event format #[id]-[title]\n[date]\n[time]\n\n[id]-[title]\n[date]\n[time]#'

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
    local attending = GuildEventsUI:getAttending(eventId)
    local members = attending:split(",")
    local membersToInvite = {}
    local count = 0
    local memberToInviteCount = 0

    if attending == "No attendees" then
        d("No attendees to invite...")
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
        d("Invited "..count.." members.")
        d("Invited: "..membersInvitedText)
    else
        d("No one else to invite...")
    end
    --zo_callLater(function() GuildEvents:inviteAttendees() end, 2000)
end