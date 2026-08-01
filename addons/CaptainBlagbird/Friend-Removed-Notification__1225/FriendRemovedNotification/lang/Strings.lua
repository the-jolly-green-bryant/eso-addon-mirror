--[[

Friend Removed Notification
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

local strings = {
    SI_FRN_MSG_NOTE    = "Notification by add-on\n\"Friend Removed Notification\"",
    SI_FRN_MSG_MESSAGE = "|cFFFFFF<<1>>|r was removed from your friends list.",
    SI_FRN_MSG_HEADING = "Friend removed",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end
