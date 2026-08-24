CombatFPSBooster = CombatFPSBooster or {}
local L = CombatFPSBooster.L or {}

local clientLang = GetCVar("Language.lang")
if clientLang == "de" then
    L.TITLE           = "Combat FPS Booster"
    L.HIDE_COMPASS    = "Kompass im Kampf ausblenden"
    L.HIDE_COMPASS_TT = "Blendet die obere Kompassleiste im Kampf vollständig aus, um die CPU zu entlasten."
    L.HIDE_QUESTS     = "Quest-Tracker im Kampf ausblenden"
    L.HIDE_QUESTS_TT  = "Blendet die aktive Quest-Liste auf der rechten Seite im Kampf aus."
    L.HIDE_ALERTS     = "EP-/Gold-Benachrichtigungen im Kampf ausblenden"
    L.HIDE_ALERTS_TT  = "Blendet Benachrichtigungen über Erfahrung, Gold und Beute im Kampf aus, um Ruckler bei Trash-Packs zu verhindern."
end

CombatFPSBooster.L = L