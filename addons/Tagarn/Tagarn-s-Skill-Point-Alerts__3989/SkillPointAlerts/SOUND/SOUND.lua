SkillPointAlerts = SkillPointAlerts or {}
local SPA = SkillPointAlerts

-- To change the notification sound, replace the TELVAR_GAINED below with the name of a
-- different sound. Some examples include:
--     TELVAR_GAINED
--     CODE_REDEMPTION_SUCCESS
--     EVENT_TICKET_TRANSACT
--     TUTORIAL_INFO_SHOWN
--     CODE_REDEMPTION_SUCCESS
--
-- A list of available sounds can be found at https://github.com/esoui/esoui/blob/master/esoui/libraries/globals/soundids.lua
--
-- The line below must remain exactly as it is, with only the TELVAR_GAINED being changed. 
-- Not doing so will result in no sounds being played, and possibly errors from this add-on.
--
-- This line should look like:
--     SPA.notificationSound = SOUNDS.TELVAR_GAINED


SPA.notificationSound = SOUNDS.TELVAR_GAINED


