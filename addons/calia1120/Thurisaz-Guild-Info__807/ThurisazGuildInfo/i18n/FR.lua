-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

if (TI.locale == nil) then TI.locale = {} end
if (TI.locale.templates == nil) then TI.locale.templates = {} end
if (TI.locale.settings == nil) then TI.locale.settings = {} end
if (TI.locale.settings.tooltip == nil) then TI.locale.settings.tooltip = {} end

TI.locale["online"]=                                                    "en ligne"
TI.locale["offline"] =                                                  "hors ligne"
TI.locale["away"] =                                                     "un moyen"
TI.locale["dontdisturb"] =                                              "ne pas déranger"
TI.locale["unknown"] =                                                  "ignoré"

TI.locale["CharNameHeader"] =                                           "PERSONNAGE"

TI.locale.templates["status_change"] =                                  "<<1>> <<2>> est maintenant <<3>>"
TI.locale.templates["guild_left"] =                                     "<<1>> a quitté <<2>>"
TI.locale.templates["guild_joined"] =                                   "<<1>> relié <<2>>"
TI.locale.templates["new_level"] =                                      "<<1>> <<2>> atteint level <<3>>"
TI.locale.templates["new_champion"] =                                    "<<1>> <<2>> atteint <<3>> CP"
TI.locale.templates["motd_changed"] =                                   "Message du Jour oour <<1>> a été changé:\r\n<<2>>"
TI.locale.templates["motd_startup"] =                                   "Message du Jour pour <<1>>:\r\n<<2>>"
TI.locale.templates["characterName_tooltip"] =                          "Principal Personnage:"

--[[
--settings strings
 ]]
--[[
-- General
 ]]
TI.locale.settings["ThurisazCtrlP"] =                                   "Thurisaz Guild Info"
TI.locale.settings["TGI_SettingsGuildRosterHeader"] =                   "Liste Guilde"
--Roster General
TI.locale.settings["TGI_SettingsCharNames"] =                           "Afficher les noms des personnages"
TI.locale.settings.tooltip["TGI_SettingsCharNames"] =                   "Afficher les noms des personnages dans roster de guilde"

TI.locale.settings["ReloadWarning"] =                                   "Rechargements UI"
--[[
-- Announces General
 ]]
TI.locale.settings["TGI_SettingsAnnouncementsHeader"] =                 "Annonces"

--ShowAnnouncements
TI.locale.settings["TGI_SettingsAnnounce"] =                            "Affichage Nom du Joueur"
TI.locale.settings.tooltip["TGI_SettingsAnnounce"] =                    "Afficher les messages du système sur les activités de la guilde"

-- Unlock Announcement Window
TI.locale.settings["TGI_SettingsAnnounceDisplayMoveable"] =             "Débloquez fenêtre"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayMoveable"] =     "Débloquez annonce la fenêtre pour permettre le mouvement et l'affichage taille"

-- How to display Announcements
TI.locale.settings["TGI_SettingsAnnounceType"] =                        "Afficher les annonces comme"
TI.locale.settings.tooltip["TGI_SettingsAnnounceType"] =                "Comment afficher Annonces"

-- Use Colored Display Messages?
TI.locale.settings["DisplayColorMode"] =                                "Colored Messages d'affichage"
TI.locale.settings.tooltip["DisplayColorMode"] =                        "Afficher les messages d'affichage en couleur?"

-- AnnounceDisplayAlignment
TI.locale.settings["TGI_SettingsAnnounceDisplayAlign"] =                "Horizontal Alignment"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayAlign"] =        "Alignement Horizontal"

-- Show time on chat announcements
TI.locale.settings["TGI_SettingsShowTimestamp"] =                       "Afficher l'heure sur le chat Annonces"
TI.locale.settings.tooltip["TGI_SettingsShowTimestamp"] =               "Afficher un timestamp comme préfixe de chat annonces"

-- Set how long to show Announcement
TI.locale.settings["TGI_SettingsAnnounceDisplayTime"] =                 "Secondes pour afficher une annonce"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayTime"] =         "Combien de temps Les annonces devraient être affichées?"

-- Announcement Font Settings
TI.locale.settings["TGI_SettingsAnnounceFont"] =                        "Font des annonces"
TI.locale.settings.tooltip["TGI_SettingsAnnounceFont"] =                "Choisissez la police pour afficher Annonces dans HUD"

-- Announcement Display Width
TI.locale.settings["TGI_SettingsAnnounceDisplayWidth"] =                "Largeur de l'annonce"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayWidth"] =        "Largeur Annonces dans HUD"

-- Player Display Name Preferences
TI.locale.settings["TGI_SettingsNameFormat"] =                          "Format des noms"
TI.locale.settings.tooltip["TGI_SettingsNameFormat"] =                  "Les noms de format doivent être affichés dans les annonces"

-- Set Player Name Color
TI.locale.settings["TGI_SettingsPlayerNameColor"] =                     "Couleur des noms des joueurs"
TI.locale.settings.tooltip["TGI_SettingsPlayerNameColor"] =             "Couleur pour afficher les noms des joueurs dans les annonces"


--[[
-- Per Guild Settings
 ]]
TI.locale.settings["TGI_SettingsGuildsHeader"] =                        "Paramètres de Guilde"

-- Show Announcements
TI.locale.settings["TGI_SettingsOverallAnnounceGuild"] =                "Afficher les annonces"
TI.locale.settings.tooltip["TGI_SettingsOverallAnnounceGuild"] =        "Afficher les messages du système sur les activités de la guilde. (Y compris le Message du jour)"

-- Guild Name Abbreviation
TI.locale.settings["TGI_SettingsAbbreviationAnnounceGuild"] =           "Nom Guilde Abréviation"
TI.locale.settings.tooltip["TGI_SettingsAbbreviationAnnounceGuild"] =   "Définir une abréviation de ce nom de la guilde. Laissez vide pour utiliser le nom complet de la guilde"

-- Guild Name Color
TI.locale.settings["TGI_SettingsGuildNameColorGuild"] =                 "Couleur Nom Guilde"
TI.locale.settings.tooltip["TGI_SettingsGuildNameColorGuild"] =         "Couleur pour afficher Nom Guilde dans Annonces"

-- Show roster changes
TI.locale.settings["TGI_SettingsMemberAnnounceGuild"] =                 "Afficher les modifications figurant sur la liste"
TI.locale.settings.tooltip["TGI_SettingsMemberAnnounceGuild"] =         "Montrer les modifications membres"

-- Show online changes
TI.locale.settings["TGI_SettingsStatusAnnounceGuild"] =                 "Afficher les modifications en ligne"
TI.locale.settings.tooltip["TGI_SettingsStatusAnnounceGuild"] =         "Afficher les messages du système sur les changements d'état en ligne des membres de la guilde"

-- Show level changes
TI.locale.settings["TGI_SettingsLevelAnnounceGuild"] =                  "Show level changes"
TI.locale.settings.tooltip["TGI_SettingsLevelAnnounceGuild"] =          "Montrer les modifications de niveau"

--Raid Score Notifications
--TI.locale.settings["TGI_SettingsRaidScoreNotificationsGuild"] =         "Notifications Score Montrer de raid"
--TI.locale.settings.tooltip["TGI_SettingsRaidScoreNotificationsGuild"] = "Afficher les notifications standards sur les nouveaux scores de raid dans notre guilde (EXPERIMENTAL)"
