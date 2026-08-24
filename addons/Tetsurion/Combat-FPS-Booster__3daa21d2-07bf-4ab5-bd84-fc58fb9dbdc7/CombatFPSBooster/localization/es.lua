CombatFPSBooster = CombatFPSBooster or {}
local L = CombatFPSBooster.L or {}

local clientLang = GetCVar("Language.lang")
if clientLang == "es" then
    L.TITLE           = "Combat FPS Booster"
    L.HIDE_COMPASS    = "Ocultar brújula en combate"
    L.HIDE_COMPASS_TT = "Oculta completamente la brújula superior en combate para aliviar la carga de la CPU."
    L.HIDE_QUESTS     = "Ocultar seguimiento de misiones en combate"
    L.HIDE_QUESTS_TT  = "Oculta el registro de misiones activas en el lado derecho durante el combate."
    L.HIDE_ALERTS     = "Ocultar alertas de EXP/Oro en combate"
    L.HIDE_ALERTS_TT  = "Oculta las notificaciones de experiencia, oro y botín durante el combate para evitar tirones."
end

CombatFPSBooster.L = L