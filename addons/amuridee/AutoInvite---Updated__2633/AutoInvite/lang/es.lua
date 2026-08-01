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

-- Spanish translation | Traducción al español

--Main Title (not translated)
ZO_CreateStringId("SI_AUTO_INVITE", "AutoInvite")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "El grupo está vacío.")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "Invitación enviada a <<1>>.")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "Expulsando a <<1>> (desconectado desde hace <<2>>).")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "Espacio disponible en el grupo. Escucha reiniciada para '<<1>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "Empezando a escuchar '<<1>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "Detener escucha.")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "Grupo lleno. AutoInvite desactivado.")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "AutoInvite desactivado.")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "No se pudo encontrar al jugador <<1>>. Por favor, invítalo manualmente.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "El jugador <<1>> no está en Cyrodiil, sino en '<<2>>'.")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "Invitación bloqueada para evitar un fallo del juego.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "Error - no se pudo invitar en el canal:")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "No se encontró a ningún jugador llamado '<<1>>' en el escaneo. Expúlsalo manualmente.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_NOT_GROUP_LEADER", "¡No eres el líder del grupo!")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "Activado")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "Para activar o desactivar AutoInvite.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "Texto a buscar")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "El texto que AutoInvite buscará en los mensajes de chat.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "Tamaño máx. del grupo")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "Límite de jugadores a invitar al grupo.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "Reiniciar")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "Reiniciar AutoInvite cuando quede un espacio libre tras haber alcanzado el máximo.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "Verificar Cyrodiil")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "Invitar solo a los jugadores que estén en Cyrodiil. (Solo funciona si tú también estás en Cyrodiil).")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "Expulsión automática")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "Expulsa automáticamente a los jugadores desconectados.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "Tiempo antes de expulsar")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "Número de segundos antes de expulsar a un jugador desconectado.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "Comando de barra")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "Actualizar lista")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "Reorganizar grupo")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REINVITE", "Volver a invitar al grupo")

ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENROLMENT", "Tu mensaje de reclutamiento predefinido")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENROLMENT", "Esto rellenará automáticamente el chat cuando hagas clic en el botón superior para publicar tu mensaje de reclutamiento. Usa las siguientes etiquetas para que AutoInvite las reemplace por:\n++cn el nombre de tu campaña actual de Alianza\n++gs el tamaño de tu grupo\n++rs los espacios restantes en el grupo\n++ro los roles necesarios (configurar abajo)")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_NEEDED", "Roles necesarios en el grupo para el mensaje de reclutamiento (incluyendo el tuyo)")

ZO_CreateStringId("SI_AUTO_INVITE_OTHER_SETTINGS", "Ajustes principales")
ZO_CreateStringId("SI_AUTO_INVITE_CHATS_LISTEN", "Chats a escuchar")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_SETTINGS", "Ajustes de grupo")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "Reorganizar grupo")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "Volver a invitar al grupo")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "AutoInvite - comando |CFFFF00/ai <str>|r. Ejemplo:")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - Empezar a escuchar 'foo'.")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - Desactivar AutoInvite.")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - Disolver y volver a invitar al grupo")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - Mostrar este menú de ayuda.")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))