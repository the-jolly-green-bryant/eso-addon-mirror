local GuildEvents = _G["GuildEvents"]
local L = {}

-- Create Event
L.eventCreate               = 'Event erstellen'
L.eventAddIdLabel           = 'Event ID'
L.eventAddTitleLabel        = 'Event Titel'
L.eventAddDateLabel         = 'Event Datum'
L.eventAddTimeLabel         = 'Event Zeit'
L.eventAddMaxAttendeesLabel = 'Max. Teilnehmer'
L.eventAddId                = 'Event ID hier'
L.eventAddTitle             = 'Event Titel hier'
L.eventAddDate              = 'Event Datum hier'
L.eventAddTime              = 'Event Zeit hier'
L.eventAddMaxAttendees      = 'Unbegrenzt'

-- Delete dialog
L.deleteEventLabel      = 'Event löschen'
L.deleteEventTitle      = 'Dieses Event löschen?'
L.deleteEventText       = 'Bist du sicher, dass du dieses Event löschen willst?'

-- Sign up dialog
L.signupEventLabel      = 'Event Anmeldung'
L.signupEventTitle      = 'Melde dich für das Event an'
L.signupEventText       = 'Welche Rolle wirst du übernehmen?'

-- common
L.eventLabel            = '<<1>>: <<2>> um <<3>>'
L.noEvents              = 'Keine Events'
L.noAttendees           = 'Keine Teilnehmer'
L.noEventsForGuild      = 'Keine Events für <<1>>'
L.roleUndefined         = 'Undefiniert'
L.roleTank              = 'Tank'
L.roleHealer            = 'Heiler'
L.roleDD                = 'Dps'

-- Progress
L.progressText          = 'Aktualisiere Notizen der Mitglieder'

-- Invite Attendees
L.noAttendeesToInvite   = 'Keine Teilnehmer zum einladen ...'
L.noOneElseToInvite     = 'Niemand weiteres zum einladen ...'
L.invitedAttendees      = '<<1>> Teilnehmer eingeladen.'

if (GetCVar('language.2') == 'de') then
    for k, v in pairs(GuildEvents:GetLocale()) do
        if (not L[k]) then
            L[k] = v
        end
    end
    function GuildEvents:GetLocale()
        return L
    end
end