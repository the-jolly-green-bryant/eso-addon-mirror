if EzStalking == nil then EzStalking = { } end
local EzStalking = _G['EzStalking']
local L = { }

-- [[ Menu ]]
L.menu = { }
L.menu.header                           = "Réglages"
local substring_description1            = "Sélectionnez si, et où, vous souhaitez que Encounter Logging démarre automatiquement."
local substring_description2            = "Remarque : si activé, il désactive automatiquement l'enregistrement en dehors des lieux spécifiés."
L.menu.description                      = substring_description1 .. "\n" .. substring_description2 -- do not edit

L.menu.accountwide                      = "Paramètres à l'échelle du compte"
L.menu.accountwide_tooltip              = "Partager les paramètres entre tous les personnages."

L.menu.logging_enabled                  = "enregistrement automatique"
L.menu.logging_enabled_tooltip          = "Activer l'enregistrement automatique des rencontres"

L.menu.normal_difficulty                = "enreg diff normal (sans/confirmation)"
L.menu.normal_difficulty_tooltip        = "Vous demande sur chaque instance normale que vous rejoignez si vous souhaitez l'enregistrer."

L.menu.use_dialog                       = "Boîte de dialogue de confirmation"
L.menu.use_dialog_tooltip               = "Vous demande si vous souhaitez enregistrer une instance au lieu de l'enregistrer automatiquement."

L.menu.remember_zone                    = "Se souvenir de la zone"
L.menu.remember_zone_tooltip            = "Rappelez-vous de votre décision pour la zone instanciée, afin qu'elle ne vous le redemande pas tant que vous n'entrez pas dans une autre zone instanciée."

L.menu.location = { }                   -- [[ Location Menu]]
L.menu.location.header                  = "Emplacements"
local substring_housing                 = "Maison du joueur"
L.menu.location.housing_tooltip         = "Activer l'enregistrement automatique dans les maisons des joueurs."
L.menu.location.housing                 = substring_housing -- do not edit

local substring_arenas                  = "Arènes"
L.menu.location.arenas_tooltip          = "Activer l'enregistrement automatique dans les arènes solo et de groupe."
L.menu.location.arenas                  = substring_arenas -- do not edit

local substring_dungeons                = "Donjons"
L.menu.location.dungeons_tooltip        = "Activer l'enregistrement automatique dans les donjons."
L.menu.location.dungeons                = substring_dungeons -- do not edit

local substring_endless                 = "Infinie"
L.menu.location.endless_tooltip         = "Activer l'enregistrement automatique dans les donjons sans fin."
L.menu.location.endless                 = substring_endless -- do not edit

local substring_trials                  = "Raid"
L.menu.location.trials_tooltip          = "Activer l'enregistrement automatique des raids."
L.menu.location.trials                  = substring_trials -- do not edit

local substring_battlegrounds           = "Champs de bataille"
L.menu.location.battlegrounds_tooltip   = "Activer l'enregistrement automatique dans les champs de bataille."
L.menu.location.battlegrounds           = substring_battlegrounds -- do not edit

local substring_imperial_city           = "Cité impériale"
L.menu.location.imperial_city_tooltip   = "Activer l'enregistrement automatique dans la cité impériale"
L.menu.location.imperial_city           = substring_imperial_city -- do not edit

local substring_cyrodiil                = "Cyrodiil"
L.menu.location.cyrodiil_tooltip        = "Activer l'enregistrement automatique dans Cyrodil"
L.menu.location.cyrodiil                = substring_cyrodiil -- do not edit

L.menu.indicator = { }                  -- [[ Indicator Menu ]]
L.menu.indicator.header                 = "Indicateur"
local substring_enabled                 = "Activé"
L.menu.indicator.enabled_tooltip        = "Affiche un petit indicateur à l'écran indiquant si l'enregistrement est actuellement activée ou non."
L.menu.indicator.enabled                = substring_enabled -- do not edit

local substring_locked                  = "Verrouiller"
L.menu.indicator.locked_tooltip         = "Verrouille l'indicateur en place. Lorsqu'il est déverrouillé, la couleur de l'indicateur est inversée."
L.menu.indicator.locked                 = substring_locked -- do not edit

local substring_color                   = "Couleur"
L.menu.indicator.color_tooltip          = "Sélectionnez la couleur de l'indicateur."
L.menu.indicator.color                  = substring_color -- do not edit

-- [[ Dialogs ]]
L.dialog = { }
L.dialog.logging = { }                  -- [[ Logging Dialog ]]
L.dialog.logging.title                  = "Encounterlog"
L.dialog.logging.text                   = "Voulez-vous commencer à enregistrer cette instance ?"

-- [[ Slash Command Arguments ]]
L.slash_command = { }                   -- [[ Slash Command Arguments]]
L.slash_command.lock                    = "lock"
L.slash_command.unlock                  = "unlock"
L.slash_command.anonymous               = "anonymous"
L.slash_command.named                   = "named"

-- [[ Messages ]]
L.message = { }
L.message.logging = { }                 -- [[ Logging Messages ]]
L.message.logging.enabled               = GetString(SI_ENCOUNTER_LOG_ENABLED_ALERT) -- do not edit
L.message.logging.disabled              = GetString(SI_ENCOUNTER_LOG_DISABLED_ALERT) -- do not edit

L.message.anonymity = { }               -- [[ Anonimity Messages ]]
L.message.anonymity.preamble            = "Vous allez maintenant"
L.message.anonymity.anonymous           = "paraître anonyme."
L.message.anonymity.named               = "partagez votre nom de personnage."

L.message.indicator = { }               -- [[ Indicator Messages ]]
local substring_warn_unlocked           = "AVERTISSEMENT : l'indicateur à l'écran est déverrouillé!"
L.message.indicator.warn_unlocked       = "|cff0000" .. substring_warn_unlocked .. "|r" -- do not edit

local substring_or                      = "ou"
local substring_lock                    = "verrouiller l'indicateur à l'écran."
local substring_unlock                  = "déverrouiller l'indicateur à l'écran."
local substring_anonymous               = "définissez-vous pour apparaître anonyme dans les journaux de rencontre"
local substring_named                   = "partagez le nom de votre personnage dans les journaux de rencontre."
local substring_note                    = "REMARQUE : Les journaux en cours ne mettront pas à jour votre paramètre d'anonymat."
local substring_empty                   = "rien"
local substring_toggle                  = "basculer l'enregistrement des rencontres."

L.message.slash_command = { }           -- [[ Slash Command Messages]]
L.message.slash_command.options         = "Les options sont:"
--[[
        Do not edit the following lines!
        They will be properly translated if you have translated everything above.
--]]
L.message.slash_command.lock            = "|cab7337" .. L.slash_command.lock .. "|r - " .. substring_lock
L.message.slash_command.unlock          = "|cab7337" .. L.slash_command.unlock .. "|r - " .. substring_unlock
L.message.slash_command.anonymous       = "|cab7337" .. L.slash_command.anonymous .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.anonymous, 1, 1) .. "|r - " .. substring_anonymous
L.message.slash_command.named           = "|cab7337" .. L.slash_command.named .. "|r " .. substring_or .. " |cab7337" .. zo_strsub(L.slash_command.named, 1, 1) .. "|r - " .. substring_named
L.message.slash_command.note            = "|cff3737" .. substring_note .. "|r"
L.message.slash_command.toggle          = "|cab7337<" .. substring_empty .. ">|r - " .. substring_toggle
-- [[ continue editing below ]]

-- [[ Keybindings ]]
local kb = { }
kb.SI_BINDING_NAME_EZSTALKING_TOGGLE_LOGGING = "Toggle Encounterlog"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end

function EzStalking:GetLocale()
    return L
end