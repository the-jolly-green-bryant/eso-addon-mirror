local GuildEvents = _G["GuildEvents"]
local L = {}

-- Create Event
L.eventCreate               = 'Create Event'
L.eventAddIdLabel           = 'Unique ID (0-9)'
L.eventAddTitleLabel        = 'Title (40 chars)'
L.eventAddDateLabel         = 'Date/Time (20 chars)'
L.eventAddInfoLabel         = 'Info (20 chars)'
L.eventAddId                = '-'
L.eventAddTitle             = '-'
L.eventAddDate              = '-'
L.eventAddInfo              = '-'

-- Delete dialog
L.deleteEventLabel      = 'Delete Event'
L.deleteEventTitle      = 'Delete this event?'
L.deleteEventText       = 'Are you sure you want to delete this event?'

-- Sign up dialog
L.signupEventLabel      = 'Event sign up'
L.signupEventTitle      = 'Sign up for this Event'
L.signupEventText       = 'Which role will you choose?'

-- common
L.eventLabel            = '<<2>>: <<1>> (<<3>>)'
L.noEvents              = 'No Events'
L.noAttendees           = 'No attendees'
L.noEventsForGuild      = 'No events for <<1>>'
L.roleUndefined         = 'Undefined'
L.roleTank              = 'Tank'
L.roleHealer            = 'Healer'
L.roleDD                = 'Melee DD'
L.roleDDR              = 'Ranged DD'


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


