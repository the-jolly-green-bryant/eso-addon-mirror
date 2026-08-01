-- Translated by: Cisneros

local Register = LibCodesCommonCode.RegisterString

Register("SI_LCK_SCAN_START"                , "Analizando la tabla de objetos; esto solo ocurre una vez por cada actualización principal del juego.")
Register("SI_LCK_SCAN_COMPLETE"             , "Análisis terminado.")

Register("SI_LCK_SETTINGS_CHATCOMMAND"      , "Este panel de configuración del complemento también está accesible a través del comando |c00CCFF/lck|r chat.")

Register("SI_LCK_SETTINGS_SERVER"           , "Servidor")

Register("SI_LCK_SETTINGS_USE_DEFAULT"      , "Uso predeterminado")

Register("SI_LCK_SETTINGS_TRACKING1"        , "No hacer seguimiento")
Register("SI_LCK_SETTINGS_TRACKING2"        , "Seguimiento de calidad baja")
Register("SI_LCK_SETTINGS_TRACKING3"        , "Seguimiento de calidad mayor")
Register("SI_LCK_SETTINGS_TRACKING4"        , "Seguimiento de todo")

Register("SI_LCK_SETTINGS_PRIORITY"         , "Rango de prioridad")
Register("SI_LCK_SETTINGS_PRIORITY_HELP"    , "Varios personajes pueden compartir el mismo rango de prioridad; los personajes con el mismo rango de prioridad se clasifican por antigüedad, dando preferencia a los personajes más antiguos sobre los más nuevos.")

Register("SI_LCK_SETTINGS_EXPORT"           , "Seleccionar para la exportación")

Register("SI_LCK_SETTINGS_MAIN_SECTION"     , "Seguimiento y prioridad")
Register("SI_LCK_SETTINGS_RANKING_PREVIEW"  , "Orden de clasificación actual de los personajes")
Register("SI_LCK_SETTINGS_SYSTEM_DEFAULTS"  , "Estos valores predeterminados de los parámetros del sistema se aplicarán a cada personaje, a menos que sean reemplazados a nivel del servidor, la cuenta o el personaje:")
Register("SI_LCK_SETTINGS_SERVER_DEFAULTS"  , "Estos valores predeterminados de los parámetros del servidor se aplicarán a cada personaje de este servidor, a menos que sean reemplazados a nivel de la cuenta o del personaje:")
Register("SI_LCK_SETTINGS_ACCOUNT_DEFAULTS" , "Estos valores predeterminados de los parámetros comunes a la cuenta se aplicarán a cada personaje que pertenezca a esta cuenta, salvo que sean reemplazados a nivel del personaje:")

Register("SI_LCK_SETTINGS_SHARE_SECTION"    , "Compartir datos")
Register("SI_LCK_SETTINGS_SHARE_CAPTION"    , "Exportar y copiar, o pegar e importar, para compartir datos")
Register("SI_LCK_SETTINGS_SHARE_EXPORTC"    , "Exportar actual")
Register("SI_LCK_SETTINGS_SHARE_EXPORTCT"   , "Exportar los datos de conocimiento para el personaje actual")
Register("SI_LCK_SETTINGS_SHARE_EXPORTA"    , "Exportar todo")
Register("SI_LCK_SETTINGS_SHARE_EXPORTAT"   , "Exportar los datos de conocimiento para cada personaje activado")
Register("SI_LCK_SETTINGS_SHARE_EXPORTS"    , "Exportar la selección(%d)")
Register("SI_LCK_SETTINGS_SHARE_EXPORTST"   , "Exportar los datos de conocimiento para los personajes con una \"selección de exportación\" activa")
Register("SI_LCK_SETTINGS_SHARE_IMPORT"     , "Importar")
Register("SI_LCK_SETTINGS_SHARE_CLEAR"      , "Limpiar")

Register("SI_LCK_SETTINGS_RESET_SECTION"    , "Restablecer datos")
Register("SI_LCK_SETTINGS_RESET_WARNING"    , "Restablecerá todos los parámetros, eliminará todos los datos asociados a LibCharacterKnowledge y recargará la interfaz de usuario.")

Register("SI_LCK_SETTINGS_NOSAVE_SECTION"   , "Cuentas excluidas")
Register("SI_LCK_SETTINGS_NOSAVE_CAPTION"   , "Lista de cuentas, separadas por comas, para excluir del registro")

Register("SI_LCK_SHARE_EXPORT_LIMIT"        , "Ignorar  [<<1>>/<<2>>]; límite de datos alcanzado.")
Register("SI_LCK_SHARE_IMPORT_STALE"        , "Ignorar [<<1>>/<<2>>]; los datos actuales mas recientes.")
Register("SI_LCK_SHARE_IMPORT_DONE"         , "Importado [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LCK_SHARE_IMPORT_INVALID"      , "Abandono de la importación; datos corruptos encontrados.")
Register("SI_LCK_SHARE_IMPORT_BADVERSION"   , "Los datos importados han sido codificados por una versión incompatible de LibCharacterKnowledge; por favor asegúrese de que todos los usuarios hayan actualizado a la última versión de LibCharacterKnowledge.")
Register("SI_LCK_SHARE_IMPORT_NEWCHARACTER" , "Ha importado uno o varios nuevos personajes que no existían anteriormente en la base de datos; |c00CCFF/reloadui|r puede ser necesario para que los personajes recién agregados aparezcan en los menús y configuraciones.")
Register("SI_LCK_SHARE_IMPORT_TALLY"        , "<<1>> personajes importados.")
