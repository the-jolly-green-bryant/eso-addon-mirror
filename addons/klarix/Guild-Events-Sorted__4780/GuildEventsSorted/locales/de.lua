local GuildEvents = _G["GuildEvents"]
local L = {}

-- Create Event
L.eventCreate               = 'Event erstellen'
L.eventAddIdLabel           = 'Eindeutige ID (0-9)'
L.eventAddTitleLabel        = 'Titel (40 Zeichen)'
L.eventAddDateLabel         = 'Datum/Zeit (20 Zeichen)'
L.eventAddInfoLabel         = 'Info (20 Zeichen)'
L.eventAddId                = '-'
L.eventAddTitle             = '-'
L.eventAddDate              = '-'
L.eventAddInfo              = '-'

-- Delete dialog
L.deleteEventLabel      = 'Event löschen'
L.deleteEventTitle      = 'Dieses Event löschen?'
L.deleteEventText       = 'Bist du sicher, dass du dieses Event löschen willst?'

-- Sign up dialog
L.signupEventLabel      = 'Event Anmeldung'
L.signupEventTitle      = 'Melde dich für das Event an'
L.signupEventText       = 'Welche Rolle wirst du übernehmen?'

-- common
L.eventLabel            = '<<2>>: <<1>> (<<3>>)'
L.noEvents              = 'Keine Events'
L.noAttendees           = 'Keine Teilnehmer'
L.noEventsForGuild      = 'Keine Events für <<1>>'
L.roleUndefined         = 'Undefiniert'
L.roleTank              = 'Tank'
L.roleHealer            = 'Heiler'
L.roleDD                = 'Melee DD'
L.roleDDR                = 'Ranged DD'

-- Progress
L.progressText          = 'Aktualisiere Notizen der Mitglieder'

-- Invite Attendees
L.noAttendeesToInvite   = 'Keine Teilnehmer zum Einladen ...'
L.noOneElseToInvite     = 'Niemand weiteres zum Einladen ...'
L.invitedAttendees      = '<<1>> Teilnehmer eingeladen.'

L.tooltipSave           = "Event speichern"
L.tooltipClear          = "Alle Angemeldeten entfernen"

L.chatResetStarted      = "%d Anmeldungen werden entfernt."

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

