local GuildEvents = _G["GuildEvents"]
local L = {}

-- Create Event
L.eventCreate               = 'Create Event'
L.eventAddIdLabel           = 'Event ID'
L.eventAddTitleLabel        = 'Event title'
L.eventAddDateLabel         = 'Event date'
L.eventAddTimeLabel         = 'Event time'
L.eventAddMaxAttendeesLabel = 'Max. Attendees'
L.eventAddId                = 'Event ID here'
L.eventAddTitle             = 'Event title here'
L.eventAddDate              = 'Event date here'
L.eventAddTime              = 'Event time here'
L.eventAddMaxAttendees      = 'Unlimited'

-- Delete dialog
L.deleteEventLabel      = 'Delete Event'
L.deleteEventTitle      = 'Delete this event?'
L.deleteEventText       = 'Are you sure you want to delete this event?'

-- Sign up dialog
L.signupEventLabel      = 'Event sign up'
L.signupEventTitle      = 'Sign up for this Event'
L.signupEventText       = 'Which role will you choose?'

-- common
L.eventLabel            = '<<1>>: <<2>> at <<3>>'
L.noEvents              = 'No Events'
L.noAttendees           = 'No attendees'
L.noEventsForGuild      = 'No events for <<1>>'
L.roleUndefined         = 'Undefined'
L.roleTank              = 'Tank'
L.roleHealer            = 'Healer'
L.roleDD                = 'Dps'

-- Progress
L.progressText          = 'Update member notes'

-- Invite Attendees
L.noAttendeesToInvite   = 'No attendees to invite ...'
L.noOneElseToInvite     = 'No one else to invite ...'
L.invitedAttendees      = 'Invited <<1>> attendees.'
L.invitedSummary        = 'Invited: <<1>>'


function GuildEvents:GetLocale()
    return L
end
