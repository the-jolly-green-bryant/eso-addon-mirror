-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

--
-- French translation by @Provision | Traduction française par @Provision 
--

--Main Title (not translated) 
ZO_CreateStringId("SI_AUTO_INVITE", "AutoInvite")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "Le groupe est vide.")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "Invitation envoyée à <<1>>.")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "Exclusion de <<1>> (hors-ligne depuis <<2>>).")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "Place disponible dans le groupe. Ecoute relancée sur '<<1>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "Commencer à écouter '<<1>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "Arrêter d'écouter.")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "Groupe complet. AutoInvite désactivé.")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "AutoInvite désactivé.")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "Impossible de trouver le joueur <<1>>. Invitez le manuellement.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "Joueur <<1>> n'est pas à Cyrodiil mais à '<<2>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "Invitation bloquée pour éviter un crash.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "Erreur - vous ne pouvez pas invitez sur le canal :")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "Aucun joueur nommé '<<1>>' à était trouvé par le scan. Quittez le manuellement.")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "Activé")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "Pour activer AutoInvite.") -- ??
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "Texte à chercher")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "Le texte que AutoInvite vas chercher dans les messages.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "Taille max du groupe")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "Limite de joueurs à inviter dans le groupe.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "Relancer")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "Relancer AI lorsqu'une place se libère après avoir atteint le maximum.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "Vérifier Cyrodiil")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "Inviter seulement les joueurs qui sont à Cyrodiil. (Fonctionne uniquement si vous êtes vous même à Cyrodiil).")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "Quitter auto")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "Quitte les joueurs déconnectés.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "Temps avant de quitter")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "Nombre de secondes avant de quitter un joueur déconnecté.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "Commande manuelle")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "Rafraîchir la liste")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "Refaire le groupe")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "Refaire le groupe")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "Re-Invite Group")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "AutoInvite - commande |CFFFF00/ai <str>|r. Exemple :")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - Commencer à écouter 'foo'.")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - Arrêter AutoInvite.")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - Refaire le groupe")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - Afficher cette aide.")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))
