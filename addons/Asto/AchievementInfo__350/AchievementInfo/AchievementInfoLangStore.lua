--[[
    AchievementInfo
    @author Asto, @Astarax
]]



LANG_STORE = {}
LANG_STORE.EN = {} -- English version by Asto
LANG_STORE.DE = {} -- German version by Asto (native)
LANG_STORE.FR = {} -- French version open



--[[
    English version
    @author Asto
]]
-- AddOn Output
LANG_STORE.EN.Updated = "Updated"
LANG_STORE.EN.Completed = "Completed"

-- AddOn Settings Header
LANG_STORE.EN.SettingsHeader = {}
LANG_STORE.EN.SettingsHeader.General = "General"

LANG_STORE.EN.SettingsHeader.Categories = "Categories"
LANG_STORE.EN.SettingsHeader.CategoriesDescription = "Here you can setup the notifications per category"

LANG_STORE.EN.SettingsHeader.Development = "Development"

-- AddOn Settings General Options
LANG_STORE.EN.SettingsOption = {}
LANG_STORE.EN.SettingsOption.AddOnEnabled = "AddOn enabled"
LANG_STORE.EN.SettingsOption.AddOnEnabledTooltip = "Enable or disable this AddOn"
LANG_STORE.EN.SettingsOption.AddOnEnabledWarning = "Only the output messages can be disabled here"

LANG_STORE.EN.SettingsOption.AccountWideEnabled = "Use account-wide Settings"
LANG_STORE.EN.SettingsOption.AccountWideEnabledTooltip = "Use and edit the same settings for all characters"

LANG_STORE.EN.SettingsOption.ShowEveryUpdate = "Show every update"
LANG_STORE.EN.SettingsOption.ShowEveryUpdateTooltip = "Shows a message on every status update of an achievement. Otherwise the messages appear only in steps of x%"

LANG_STORE.EN.SettingsOption.ShowUpdateSteps = "Notification steps (%)"
LANG_STORE.EN.SettingsOption.ShowUpdateStepsTooltip = "Defines the step width of notifications, if '" .. LANG_STORE.EN.SettingsOption.ShowEveryUpdate .. "' is disabled"

LANG_STORE.EN.SettingsOption.ShowDetails = "Show details"
LANG_STORE.EN.SettingsOption.ShowDetailsTooltip = "Shows progress details in each update message"

LANG_STORE.EN.SettingsOption.ShowOpenDetailsOnly = "Show incomplete details only"
LANG_STORE.EN.SettingsOption.ShowOpenDetailsOnlyTooltip = "Shows only the incomplete tasks of an achiemevent in the details"

-- pCHat compatibility option
LANG_STORE.EN.SettingsOption.OneElementPerLine = "Output line by line"
LANG_STORE.EN.SettingsOption.OneElementPerLineTooltip = "Shows each part of an achievement in a single line"
LANG_STORE.EN.SettingsOption.OneElementPerLineWarning = "Necessary for pChat compatibility"

-- AddOn Settings Category Options
-- The categories are taken from the game language files
LANG_STORE.EN.SettingsOption.CategoryTooltip = "Show messages for the category"

-- AddOn Settings Development Options
LANG_STORE.EN.SettingsOption.DebugMode = "Debug Mode"
LANG_STORE.EN.SettingsOption.DebugModeTooltip = "Shows hidden messages to check if they are hidden by mistake"
LANG_STORE.EN.SettingsOption.DebugModeWarning = "In most cases you don't need to activate this option"



--[[
    German version
    @author Asto
]]
-- AddOn Output
LANG_STORE.DE.Updated = "Aktualisiert"
LANG_STORE.DE.Completed = "Abgeschlossen"

-- AddOn Settings Header
LANG_STORE.DE.SettingsHeader = {}
LANG_STORE.DE.SettingsHeader.General = "Allgemein"

LANG_STORE.DE.SettingsHeader.Categories = "Kategorien"
LANG_STORE.DE.SettingsHeader.CategoriesDescription = "Hier können die Benachrichtigungen je Kategorie eingestellt werden"

LANG_STORE.DE.SettingsHeader.Development = "Entwicklung"

-- AddOn Settings General Options
LANG_STORE.DE.SettingsOption = {}
LANG_STORE.DE.SettingsOption.AddOnEnabled = "AddOn aktiviert"
LANG_STORE.DE.SettingsOption.AddOnEnabledTooltip = "Aktiviere oder deaktiviere dieses AddOn"
LANG_STORE.DE.SettingsOption.AddOnEnabledWarning = "An dieser Stelle können nur die Ausgaben deaktiviert werden."

LANG_STORE.DE.SettingsOption.AccountWideEnabled = "Accountübergreifende Einstellungen"
LANG_STORE.DE.SettingsOption.AccountWideEnabledTooltip = "Benutze und speichere die Einstellungen für alle Charaktere"

LANG_STORE.DE.SettingsOption.ShowEveryUpdate = "Zeige alle Fortschritte"
LANG_STORE.DE.SettingsOption.ShowEveryUpdateTooltip = "Zeigt bei jeder Aktualisierung eines Erfolgs einen Hinweis. Alternativ wird nur in x% Schritten ein Status ausgegeben"

LANG_STORE.DE.SettingsOption.ShowUpdateSteps = "Benachrichtigungsschritte (%)"
LANG_STORE.DE.SettingsOption.ShowUpdateStepsTooltip = "Definiert die Schrittweite (Häufigkeit) der Benachrichtigungen, wenn '" .. LANG_STORE.DE.SettingsOption.ShowEveryUpdate .. "' deaktiviert ist"

LANG_STORE.DE.SettingsOption.ShowDetails = "Zeige Details"
LANG_STORE.DE.SettingsOption.ShowDetailsTooltip = "Zeigt die Fortschritt-Details des Erfolgs im Hinweis an"

LANG_STORE.DE.SettingsOption.ShowOpenDetailsOnly = "Zeige nur unerledigte Details"
LANG_STORE.DE.SettingsOption.ShowOpenDetailsOnlyTooltip = "Zeigt nur offene Aufgaben in den Fortschritt-Details an"

-- pCHat compatibility option
LANG_STORE.DE.SettingsOption.OneElementPerLine = "Zeilenweise Ausgabe"
LANG_STORE.DE.SettingsOption.OneElementPerLineTooltip = "Zeigt jeden Unterpunkt eines Erfolgs als eigene Zeile im Chat"
LANG_STORE.DE.SettingsOption.OneElementPerLineWarning = "Voraussetzung für eine pChat Kompatibilität"

-- AddOn Settings Category Options
-- The categories are taken from the game language files
LANG_STORE.DE.SettingsOption.CategoryTooltip = "Zeige Nachrichten für die Kategorie"

-- AddOn Settings Development Options
LANG_STORE.DE.SettingsOption.DebugMode = "Debug Modus"
LANG_STORE.DE.SettingsOption.DebugModeTooltip = "Zeigt versteckte Nachrichten, um zu prüfen ob ggf. Nachrichten unrechtmäßig unterdrückt werden"
LANG_STORE.DE.SettingsOption.DebugModeWarning = "In den meißten Fällen muss diese Option nicht aktiviert werden"




--[[
    French version
    @author Llwydd
]]
-- AddOn Output
LANG_STORE.FR.Updated = "Mis à jour"
LANG_STORE.FR.Completed = "Terminé"

-- AddOn Settings Header
LANG_STORE.FR.SettingsHeader = {}
LANG_STORE.FR.SettingsHeader.General = "Général"

LANG_STORE.FR.SettingsHeader.Categories = "Catégories"
LANG_STORE.FR.SettingsHeader.CategoriesDescription = "Ici vous pouvez gérer les notifications par catégories"

LANG_STORE.FR.SettingsHeader.Development = "Développement"

-- AddOn Settings General Options
LANG_STORE.FR.SettingsOption = {}
LANG_STORE.FR.SettingsOption.AddOnEnabled = "Extension activée"
LANG_STORE.FR.SettingsOption.AddOnEnabledTooltip = "Active ou désactive cette extension"
LANG_STORE.FR.SettingsOption.AddOnEnabledWarning = "Seul les messages sortants peuvent être désactivés"

LANG_STORE.FR.SettingsOption.AccountWideEnabled = LANG_STORE.EN.SettingsOption.AccountWideEnabled
LANG_STORE.FR.SettingsOption.AccountWideEnabledTooltip = LANG_STORE.EN.SettingsOption.AccountWideEnabledTooltip

LANG_STORE.FR.SettingsOption.ShowEveryUpdate = "Affichage de chaque mise à jour"
LANG_STORE.FR.SettingsOption.ShowEveryUpdateTooltip = "Affiche un message pour chaque mise à jour d'un succès. Le reste du temps les messages n'apparaissent que sous forme de plage de x%"

LANG_STORE.FR.SettingsOption.ShowUpdateSteps = "Etapes de notification (%)"
LANG_STORE.FR.SettingsOption.ShowUpdateStepsTooltip = "Définie la plage des notifications, si '" .. LANG_STORE.FR.SettingsOption.ShowEveryUpdate .. "' est désactivé"

LANG_STORE.FR.SettingsOption.ShowDetails = "Affichage des détails"
LANG_STORE.FR.SettingsOption.ShowDetailsTooltip = "Affiche les détails de progression de chaque message de mise à jour"

LANG_STORE.FR.SettingsOption.ShowOpenDetailsOnly = "Affichage des détails incomplets"
LANG_STORE.FR.SettingsOption.ShowOpenDetailsOnlyTooltip = "Affiche, dans les détails, uniquement les taches incomplètes d'un succès"

-- pCHat compatibility option
LANG_STORE.FR.SettingsOption.OneElementPerLine = "Sortie ligne par ligne"
LANG_STORE.FR.SettingsOption.OneElementPerLineTooltip = "Affiche chaque partie d'un succès sur une simple ligne"
LANG_STORE.FR.SettingsOption.OneElementPerLineWarning = "Nécessite la compatibilité avec pChat"

-- AddOn Settings Category Options
-- The categories are taken from the game language files
LANG_STORE.FR.SettingsOption.CategoryTooltip = "Affiche les messages pour la catégorie"

-- AddOn Settings Development Options
LANG_STORE.FR.SettingsOption.DebugMode = "Mode de débogage"
LANG_STORE.FR.SettingsOption.DebugModeTooltip = "Affiche les messages cachés pour vérifier s'ils n'ont pas été cachés par erreur"
LANG_STORE.FR.SettingsOption.DebugModeWarning = "Dans la majorité des cas vous n'avez pas besoin d'activer cette option"