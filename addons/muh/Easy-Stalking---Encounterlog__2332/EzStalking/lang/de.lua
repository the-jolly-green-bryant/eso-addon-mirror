if EzStalking == nil then EzStalking = { } end
local EzStalking = _G['EzStalking']
local L = { }

-- [[ Menu ]]
L.menu = { }
L.menu.header                           = "Einstellungen"
local substring_description1            = "Wähle aus ob und wo automatisch Begegnungslogs aktiviert werden soll."
local substring_description2            = "Achtung: Wenn aktiviert, deaktiviert dieses Addon Begegnungslogs außerhalb der ausgewählten Orte."
L.menu.description                      = substring_description1 .. "\n" .. substring_description2 -- do not edit

L.menu.accountwide                      = "Charakterübergreifende Einstellungen"
L.menu.accountwide_tooltip              = "Nutzt die gleichen Einstellungen für alle Charaktere."

L.menu.logging_enabled                  = "Automatisches aufzeichnen"
L.menu.logging_enabled_tooltip          = "Aktiviere automatisches aufzeichnen."

L.menu.normal_difficulty                = "Normale Instanzen Aufzeichnen (Bestätigungsdialog)"
L.menu.normal_difficulty_tooltip        = "Fragt beim betreten jeder normalen Instanz ob aufgezeichnet werden soll."

L.menu.use_dialog                       = "Bestätigungsdialog"
L.menu.use_dialog_tooltip               = "Fragt ob du eine Instanz Aufzeichnen willst anstatt automatisch aufzuzeichnen."

L.menu.remember_zone                    = "Für Instanz-Zone merken"
L.menu.remember_zone_tooltip            = "Fragt nur beim ersten Betreten einer Instanz und merkt sich diese Entscheidung bis eine andere instanziierte Zone betreten wird."

L.menu.location = { }                   -- [[ Location Menu]]
L.menu.location.header                  = "Einsatzorte"
local substring_housing                 = "Spielerhäuser"
L.menu.location.housing_tooltip         = "Aktiviere automatisches aufzeichnen in Spielerhäusern."
L.menu.location.housing                 = substring_housing -- do not edit

local substring_arenas                  = "Arenen"
L.menu.location.arenas_tooltip          = "Aktiviere automatisches aufzeichnen in Solo Arenen."
L.menu.location.arenas                  = substring_arenas -- do not edit

local substring_dungeons                = "Verliese"
L.menu.location.dungeons_tooltip        = "Aktiviere automatisches aufzeichnen in Verliesen."
L.menu.location.dungeons                = substring_dungeons -- do not edit

local substring_endless                 = "Endlos"
L.menu.location.endless_tooltip         = "Aktiviere automatisches aufzeichnen in endlosen Verliesen."
L.menu.location.endless                 = substring_endless -- do not edit

local substring_trials                  = "Prüfungen"
L.menu.location.trials_tooltip          = "Aktiviere automatisches aufzeichnen in Prüfungen."
L.menu.location.trials                  = substring_trials -- do not edit

local substring_battlegrounds           = "Schlachtfelder"
L.menu.location.battlegrounds_tooltip   = "Aktiviere automatisches aufzeichnen in Schlachtfeldern"
L.menu.location.battlegrounds           = substring_battlegrounds -- do not edit

local substring_imperial_city           = "Kaiserstadt"
L.menu.location.imperial_city_tooltip   = "Aktiviere automatisches aufzeichnen in der Kaiserstadt"
L.menu.location.imperial_city           = substring_imperial_city -- do not edit

local substring_cyrodiil                = "Cyrodiil"
L.menu.location.cyrodiil_tooltip        = "Aktiviere automatisches aufzeichnen in Cyrodiil"
L.menu.location.cyrodiil                = substring_cyrodiil -- do not edit

L.menu.indicator = { }                  -- [[ Indicator Menu ]]
L.menu.indicator.header                 = "Indikator"
local substring_enabled                 = "Aktiviert"
L.menu.indicator.enabled_tooltip        = "Zeigt einen kleinen Indikator an, der signalisiert ob Aufzeichnen aktiviert ist oder nicht."
L.menu.indicator.enabled                = substring_enabled -- do not edit

local substring_locked                  = "Position sperren"
L.menu.indicator.locked_tooltip         = "Sperrt die Position des Indikators. Solange der Indikator entsperrt ist, ist die Farbe invertiert."
L.menu.indicator.locked                 = substring_locked -- do not edit

local substring_color                   = "Farbe"
L.menu.indicator.color_tooltip          = "Die Anzeigefarbe des Indikators."
L.menu.indicator.color                  = substring_color -- do not edit

-- [[ Dialog ]]
L.dialog = { }
L.dialog.logging = { }                  -- [[ Logging Dialog ]]
L.dialog.logging.title                  = "Encounterlog"
L.dialog.logging.text                   = "Möchtest du diese Instanz aufzeichnen?"

-- [[ Slash Command Arguments]]
L.slash_command = { }                   -- [[ Slash Command Arguments]]
L.slash_command.lock                    = "sperren"
L.slash_command.unlock                  = "entsperren"
L.slash_command.anonymous               = "anonym"
L.slash_command.named                   = "namentlich"
L.slash_command.combat_only             = "imkampf"

-- [[ Messages ]]
L.message = { }
L.message.logging = { }                 -- [[ Logging Messages ]]
L.message.logging.enabled               = GetString(SI_ENCOUNTER_LOG_ENABLED_ALERT) -- do not edit
L.message.logging.disabled              = GetString(SI_ENCOUNTER_LOG_DISABLED_ALERT) -- do not edit

L.message.anonymity = { }
L.message.anonymity.preamble            = "Du wirst nun"
L.message.anonymity.anonymous           = "als Anonym aufgezeichnet."
L.message.anonymity.named               = "mit deinem Charaketnamen aufgezeichnet."

L.message.indicator = { }               -- [[ Indicator Messages ]]
local substring_warn_unlocked           = "WARNUNG: Bildschirm-Indikator ist entsperrt!"
L.message.indicator.warn_unlocked       = "|cff0000" .. substring_warn_unlocked .. "|r" -- do not edit

local substring_or                      = "oder"
local substring_lock                    = "sperrt den Bildschirm-Indikator"
local substring_unlock                  = "entsperrt den Bildschirm-Indikator"
local substring_anonymous               = "du erscheinst als Anonym in Begegnugslogs."
local substring_named                   = "du erscheinst mit deinem Charakternamen in Begegnungslogs"
local substring_note                    = "ACHTUNG: Bereits laufende Begegnungslogs werden verwenden die Anonymitätseinstellung die beim Start des Logs gewählt war"
local substring_empty                   = "nichts"
local substring_toggle                  = "de-/aktiviere Begegnungslogs."
local substring_combat_only             = "es wird nur aufgezeichnet wenn du im Kampf bist."

L.message.slash_command = { }           -- [[ Slash Command Messages]]
L.message.slash_command.options         = "Optionen sind:"
L.message.slash_command.combat_only_info= "Im Kampf Modus ist: "
--[[
        Do not edit the following lines!
        They will be properly translated if you have translated everything above.
--]]
L.message.slash_command.lock            = "|cab7337" .. L.slash_command.lock .. "|r - " .. substring_lock
L.message.slash_command.unlock          = "|cab7337" .. L.slash_command.unlock .. "|r - " .. substring_unlock
L.message.slash_command.anonymous       = "|cab7337" .. L.slash_command.anonymous .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.anonymous, 1, 1) .. "|r - " .. substring_anonymous
L.message.slash_command.named           = "|cab7337" .. L.slash_command.named .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.named, 1, 1) .. "|r - " .. substring_named
L.message.slash_command.combat_only     = "|cab7337" .. L.slash_command.combat_only .. "|r " .. substring_combat_only
L.message.slash_command.note            = "|cff3737" .. substring_note .. "|r"
L.message.slash_command.toggle          = "|cab7337<" .. substring_empty .. ">|r - " .. substring_toggle
-- [[ continue editing below ]]

-- [[ Keybindings ]]
local kb = { }
kb.SI_BINDING_NAME_EZSTALKING_TOGGLE_LOGGING = "De-/Aktiviere Begegnungslogs"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end

function EzStalking:GetLocale()
    return L
end