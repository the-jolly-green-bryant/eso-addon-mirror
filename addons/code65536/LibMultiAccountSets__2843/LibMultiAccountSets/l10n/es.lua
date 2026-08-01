-- Translated by: Cisneros

local Register = LibCodesCommonCode.RegisterString

Register("SI_LMAS_SCAN_STATUS"             , "%d / %d coleccionados (+%d nuevos)")

Register("SI_LMAS_SETTINGS_CHATCOMMAND"    , "El panel de configuración de este addon también se puede acceder mediante el comando de chat |c00CCFF/lmas|r.")

Register("SI_LMAS_SETTINGS_CHAT_SECTION"   , "Notificaciones de chat")
Register("SI_LMAS_SETTINGS_CHAT_UPDATES"   , "Mostrar progreso de tu colección de conjuntos")

Register("SI_LMAS_SETTINGS_SHARE_SECTION"  , "Compartir datos de cuenta")
Register("SI_LMAS_SETTINGS_SHARE_CAPTION"  , "Exportar y copiar, o pegar e importar, para compartir datos")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTC"  , "Exportar Actual")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTCT" , "Exportar datos de la colección de conjuntos de objetos para la cuenta actual")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTA"  , "Exportar Todo")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTAT" , "Exportar datos de la colección de conjuntos de objetos para todas las cuentas guardadas")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTS"  , "Exportar Seleccionados (%d)")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTST" , "Exportar datos de la colección de conjuntos de objetos para las cuentas listadas a continuación")
Register("SI_LMAS_SETTINGS_SHARE_IMPORT"   , "Importar")
Register("SI_LMAS_SETTINGS_SHARE_CLEAR"    , "Limpiar")
Register("SI_LMAS_SETTINGS_SHARE_SELECT"   , "Cuentas Seleccionadas para Exportar")
Register("SI_LMAS_SETTINGS_SHARE_SELECTT"  , "Lista de nombres de cuentas, separados por comas, para \"Exportar Seleccionados\"")

Register("SI_LMAS_SETTINGS_DELETE_SECTION" , "Eliminar Datos de Cuenta")
Register("SI_LMAS_SETTINGS_DELETE_BUTTON"  , "Eliminar")
Register("SI_LMAS_SETTINGS_DELETE_WARNING" , "Esto eliminará todos los datos acumulados para todas las cuentas y recargará la interfaz de usuario.")

Register("SI_LMAS_SETTINGS_NOSAVE_SECTION" , "Cuentas Excluidas")
Register("SI_LMAS_SETTINGS_NOSAVE_CAPTION" , "Lista de nombres de cuentas, separados por comas, para excluir de ser guardadas")

Register("SI_LMAS_SHARE_EXPORT_LIMIT"      , "Omitido [<<1>>/<<2>>]; se alcanzó el límite de datos.")
Register("SI_LMAS_SHARE_IMPORT_STALE"      , "Omitido [<<1>>/<<2>>]; los datos actuales son más recientes.")
Register("SI_LMAS_SHARE_IMPORT_DONE"       , "Importado [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LMAS_SHARE_IMPORT_INVALID"    , "Abortando importación; se encontraron datos corruptos.")
Register("SI_LMAS_SHARE_IMPORT_BADVERSION" , "Los datos importados fueron codificados por una versión incompatible de LibMultiAccountSets; asegúrate de que ambos usuarios tengan la versión más reciente de LibMultiAccountSets.")
Register("SI_LMAS_SHARE_IMPORT_NEWACCOUNT" , "Has importado una o más cuentas nuevas que no existían previamente en la base de datos; |c00CCFF/reloadui|r puede ser necesario para que las cuentas recién añadidas aparezcan en los menús y configuraciones.")
Register("SI_LMAS_SHARE_IMPORT_TALLY"      , "<<1>> cuentas importadas.")