LibSlashCommander:AddFile("descriptions/es.lua", 2, function(lib)
    lib.descriptions = {
        [GetString(SI_SLASH_SCRIPT)] = "Ejecuta el texto especificado como código Lua",
        [GetString(SI_SLASH_CHATLOG)] = "Activa o desactiva el registro de chat",
        [GetString(SI_SLASH_GROUP_INVITE)] = "Invita al nombre especificado al grupo",
        [GetString(SI_SLASH_JUMP_TO_LEADER)] = "Viaja al líder del grupo",
        [GetString(SI_SLASH_JUMP_TO_GROUP_MEMBER)] = "Viaja al miembro del grupo especificado",
        [GetString(SI_SLASH_JUMP_TO_FRIEND)] = "Viaja al amigo especificado",
        [GetString(SI_SLASH_JUMP_TO_GUILD_MEMBER)] = "Viaja al miembro de la guild especificado",
        [GetString(SI_SLASH_RELOADUI)] = "Recarga la interfaz de usuario",
        [GetString(SI_SLASH_PLAYED_TIME)] = "Muestra el tiempo jugado en este personaje",
        [GetString(SI_SLASH_READY_CHECK)] = "Inicia una comprobación de listos mientras estás en grupo",
        [GetString(SI_SLASH_DUEL_INVITE)] = "Desafía al jugador especificado a un duelo",
        [GetString(SI_SLASH_LOGOUT)] = "Regresa a la selección de personajes",
        [GetString(SI_SLASH_CAMP)] = "Regresa a la selección de personajes",
        [GetString(SI_SLASH_QUIT)] = "Cierra el juego",
        [GetString(SI_SLASH_FPS)] = "Activa o desactiva la visualización de FPS",
        [GetString(SI_SLASH_LATENCY)] = "Activa o desactiva la visualización de latencia",
        [GetString(SI_SLASH_STUCK)] = "Abre la pantalla de ayuda para personajes atascados",
        [GetString(SI_SLASH_REPORT_BUG)] = "Abre la pantalla de informe de errores",
        [GetString(SI_SLASH_REPORT_FEEDBACK)] = "Abre la pantalla de informe de retroalimentación",
        [GetString(SI_SLASH_REPORT_HELP)] = "Abre la pantalla de ayuda",
        [GetString(SI_SLASH_REPORT_CHAT)] = "Abre la pantalla de informe de jugador",
        [GetString(SI_SLASH_ENCOUNTER_LOG)] = "Activa o desactiva el registro. '?' muestra opciones",
    }

    -- Las descripciones de emotes y cambio de chat se asignan en types.lua
end)
