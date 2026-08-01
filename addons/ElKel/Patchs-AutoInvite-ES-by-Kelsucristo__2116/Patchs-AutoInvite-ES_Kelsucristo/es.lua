local strings = {
    --Main Title (not translated)
    SI_AUTO_INVITE = "AutoInvite",
    --Status messages
    SI_AUTO_INVITE_NO_GROUP_MESSAGE = "El grupo está vacío",
    SI_AUTO_INVITE_SEND_TO_USER = "Enviando invitación a <<1>>",
    SI_AUTO_INVITE_KICK = "Expulsando <<1>> (fuera de línea por <<2>>)",
    SI_AUTO_INVITE_GROUP_OPEN_RESTART = "Ahora espacio en grupo. Se reinició la escucha en '<<1>>'",
    SI_AUTO_INVITE_START_ON = "AutoInvite escuchando en cadena '<<1>>'",
    SI_AUTO_INVITE_STOP = "Detener AutoInvite",
    SI_AUTO_INVITE_GROUP_FULL_STOP = "Grupo completo Deshabilitar AutoInvite",
    SI_AUTO_INVITE_OFF = "Deshabilitar AutoInvite",
    --Error messages
    SI_AUTO_INVITE_ERROR_ACCOUNT = "No se pudo encontrar el nombre del jugador para <<1>>. Invita manualmente.",
    SI_AUTO_INVITE_ERROR_ZONE = "Jugador <<1>> no está en Cyrodiil pero en <<2>>",
    SI_AUTO_INVITE_INV_BLOCK = "Bloqueo de invitaciones para evitar bloqueos.",
    SI_AUTO_INVITE_ERROR_INVITE = "Error: no se pudo invitar al canal:",
    SI_AUTO_INVITE_ERROR_KICK_TABLE = "Nadie nombrado <<1>> encontrado en el escaneo grupal. Por favor, Expulsar manualmente.",
    --Menu
    SI_AUTO_INVITE_OPT_ENABLED = "Habilitado",
    SI_AUTO_INVITE_TT_ENABLED = "Ya sea para habilitar AutoInvite",
    SI_AUTO_INVITE_OPT_STRING = "Invitar cadena",
    SI_AUTO_INVITE_TT_STRING = "Texto para revisar los mensajes para auto-invitar a",
    SI_AUTO_INVITE_OPT_MAX_SIZE = "Tamaño máximo del grupo",
    SI_AUTO_INVITE_TT_MAX_SIZE = "Número máximo de jugadores para invitar al grupo",
    SI_AUTO_INVITE_OPT_RESTART = "Reiniciar",
    SI_AUTO_INVITE_TT_RESTART = "Reinicia AutoInvite si caes por debajo del máximo",
    SI_AUTO_INVITE_OPT_CYRCHECK = "Chequeo de Cyrodiil",
    SI_AUTO_INVITE_TT_CYRCHECK = "Solo invite a jugadores que estén en Cyrodiil.\n(Esto solo se ejecuta si usted está en Cyrodiil).",
    SI_AUTO_INVITE_OPT_KICK = "Expulsión automática",
    SI_AUTO_INVITE_TT_KICK = "Expulsar jugadores que se desconectan",
    SI_AUTO_INVITE_OPT_KICK_TIME = "Tiempo antes de expulsar",
    SI_AUTO_INVITE_TT_KICK_TIME = "Número de segundos de espera antes de expulsar a un jugador fuera de línea",
    SI_AUTO_INVITE_OPT_SLASHCMD = "Comandos de barra inclinada",
    SI_AUTO_INVITE_BTN_REFRESH = "Actualizar lista",
    SI_AUTO_INVITE_BTN_REFORM = "Rehacer el grupo",
    SI_AUTO_INVITE_BTN_REINVITE = "Reinvitar grupo",
    -- keybind
    SI_BINDING_NAME_AUTOINVITE_REGROUP = "Rehacer el grupo",
    SI_BINDING_NAME_AUTOINVITE_REINVITE = "Reinvitar grupo",
    --Slash commands
    --Nota: No traducir entre los códigos de color  |C ... |r
    SI_AUTO_INVITE_SLASHCMD_INFO = "AutoInvite - comando |CFFFF00/ai <str>|r. Uso:",
    SI_AUTO_INVITE_SLASHCMD_START = "|CFFFF00/ai foo|r - comienza a escuchar en 'foo'",
    SI_AUTO_INVITE_SLASHCMD_STOP = "|CFFFF00/ai|r - desactivar AutoInvite",
    SI_AUTO_INVITE_SLASHCMD_REGRP = "|CFFFF00/ai regrp|r - Rehacer el grupo",
    SI_AUTO_INVITE_SLASHCMD_HELP = "|CFFFF00/ai help|r - muestra este menú de ayuda"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end