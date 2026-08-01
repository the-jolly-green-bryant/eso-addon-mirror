--[[

Auto Handle Shared Quests
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

local strings = {
    -- Settings
    SI_AHSQ_ACTION_NONE    = "None",
    SI_AHSQ_ACTION_ACCEPT  = "Accept",
    SI_AHSQ_ACTION_DECLINE = "Decline",
    
    SI_AHSQ_DESC_AVA       = "Action in AvA area",
    SI_AHSQ_DESC_PVE       = "Action in PvE area",
    
    SI_AHSQ_TT_AVA         = "Action to do when player is in alliance vs. alliance area",
    SI_AHSQ_TT_PVE         = "Action to do when player is in player vs. environment area",
    
    -- Other
    SI_AHSQ_MSG_ACCEPTED   = "Quest automatically accepted: |cFFFFFF<<1>>|r",
    SI_AHSQ_MSG_DECLINED   = "Quest automatically declined: |cFFFFFF<<1>>|r",
}

for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end
