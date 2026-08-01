--[[

Auto Handle Shared Quests
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

local strings = {
    -- Settings
    SI_AHSQ_ACTION_NONE    = "Nichts",
    SI_AHSQ_ACTION_ACCEPT  = "Akzeptieren",
    SI_AHSQ_ACTION_DECLINE = "Ablehnen",
    
    SI_AHSQ_DESC_AVA       = "Aktion im AvA-Gebiet",
    SI_AHSQ_DESC_PVE       = "Aktion im PvE-Gebiet",
    
    SI_AHSQ_TT_AVA         = "Auszuführende Aktion wenn der Spieler sich im Allianz-vs-Allianz-Gebiet befindet",
    SI_AHSQ_TT_PVE         = "Auszuführende Aktion wenn der Spieler sich im Spieler-vs-Umgebung-Gebiet befindet",
    
    -- Other
    SI_AHSQ_MSG_ACCEPTED   = "Quest automatisch akzeptiert: |cFFFFFF<<1>>|r",
    SI_AHSQ_MSG_DECLINED   = "Quest automatisch abgelehnt: |cFFFFFF<<1>>|r",
}
for key, value in pairs(strings) do
   SafeAddString(key, value, 1)
end
