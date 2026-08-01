---------------------------------------------------
-- GERMAN LOCALIZATION FOR ENDEAVOR TRACKER --
---------------------------------------------------

-- SafeAddString(SI_TIMEDACTIVITYTYPE0, "Täglich", 0)
-- SafeAddString(SI_TIMEDACTIVITYTYPE1, "Wöchentlich", 1)

ZO_CreateStringId("ENDEAVOR_TRACKER_Misc_HighEndeavorReward", "HOHE BESTREBUNGBELOHNUNG")
ZO_CreateStringId("ENDEAVOR_TRACKER_Misc_Rewards", "Belohnungen")

-- DEFAULTS --
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings1", "Aus")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings2", "Fehlende Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings3", "Nur fehlende Tägliche")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings4", "Nur fehlende Wöchentliche")
ZO_CreateStringId("ENDEAVOR_TRACKER_DefaultsDisplaySettings5", "Immer anzeigen")

-- PANEL --
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsCompleted", "<<Z:1>>E: ABGESCHLOSSEN")
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsInProgress", "<<Z:1>>E: IM GANGE")
ZO_CreateStringId("ENDEAVOR_TRACKER_HeaderEndeavorsNotStarted", "<<Z:1>>E: NICHT ANGEFANGEN")

-- CHAT MESSAGES --
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgEndeavorProgress", "Fortschritt <<c:1>>e Bestrebung")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgEndeavorCompleted", "<<1>>e Bestrebung abgeschlossen")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgNewEndeavorsAvailable", "Neue Bestrebungen sind verfügbar! ")
ZO_CreateStringId("ENDEAVOR_TRACKER_ChatMsgListRefreshed", "Bestrebungsliste aktualisiert!")

-- SETTINGS MENU --
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsTogglePanel", "|cECB8A2/et|r |c7E7E7E- Endeavor Tracker anzeigen/ausblenden|r")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsToggleHistory", "|cECB8A2/ethistory|r |c7E7E7E- Geschichte der Bestrebungen anzeigen|r")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsToggleSettings", "|cECB8A2/ethelp|r |c7E7E7E- Diese Einstellungen Öffnen|r")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFeedbackButton", "Feedback abschicken")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFeedbackTooltip", "Senden Sie mir eine Nachricht mit Fehlerberichten, Kommentaren oder Vorschlägen!")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderDisplayOptions", "Anzeigeoptionen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInCombat", "Während des Kampfes anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInDungeons", "In Verlies und Prüfungen anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayInCyroAndBGs", "In Cyrodiil, Kaiserstadt und Schlachtfelder anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayShortcutIcon", "Verknüpfungssymbol anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayCheckboxes", "Kontrollkästchen anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayTimeRemaining", "Verbleibende Zeit bis zum Zurücksetzen anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHideCompleted", "Abgeschlossene Abschnitte automatisch ein-/ausblenden")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsShowPanel", "Endeavour Tracker Oberfläche anzeigen")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderCustomization", "Anpassungsoptionen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsFontSize", "Schriftgröße ändern")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsDisplayBackground", "Hintergrundtextur anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsBackdropAlpha", "Hintergrundopazität")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorCompleted", "Abgeschlossene Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorInProgress", "Bestrebungen in Bearbeitung")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorNotStartedHeader", "Bestrebungen nicht gestartet (Überschrift)")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsColorNotStartedList", "Bestrebungen nicht gestartet (Liste)")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPanelAnchor", "Ankern Panel von unten")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPanelAnchorTooltip", "Wenn diese Option aktiviert ist, wächst das Endeavour Tracker-Bedienfeld vertikal nach oben statt nach unten.")

ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsHeaderChatOptions", "Chatoptionen")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPostProgressUpdates", "Zeige den Fortschritt im Chat an")
ZO_CreateStringId("ENDEAVOR_TRACKER_SettingsPostCompletionMessage", "Zeige den Abschluss des Bestrebungen im Chat an")

-- TOOLTIPS --
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipRefresh", "Bestrebungsliste aktualisieren")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipHistoryButton", "Geschichte der Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipEndeavorTotal", "Siegel der Bestrebung im Besitz\n(Klicken um den Kronenshop zu öffen)")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipDailyExpandButton", "Tägliche Bestrebungen anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipDailyCollapseButton", "Tägliche Bestrebungen ausblenden")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipWeeklyExpandButton", "Wöchentliche Bestrebungen anzeigen")
ZO_CreateStringId("ENDEAVOR_TRACKER_TooltipWeeklyCollapseButton", "Wöchentliche Bestrebungen ausblenden")

-- BINDINGS --
ZO_CreateStringId("SI_BINDING_NAME_ENDEAVOR_TRACKER_TOGGLE", "Endeavour Tracker anzeigen/ausblenden")

-- HISTORY PANEL
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelDailiesButton", "Tägliche abgeschlossen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelWeekliesButton", "Wöchentliche abgeschlossen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStatsButton", "Statistiken")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelTrackingDate", "|cC5C29EVerfolgung seit:|r ")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelTrackingDateTooltip", "Werte sind Schätzungen und sind möglicherweise nicht genau.")

ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderDate", "Datum")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderName", "Name")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderRewards", "Belohnungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelHeaderMisc", "Sonstig")

ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalDailyCompleted", "Gesamt tägliche Bestrebungen abgeschlossen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalWeeklyCompleted", "Gesamt wöchentliche Bestrebungen abgeschlossen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsDailies", "Gesamt Siegele aus täglichen Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsWeeklies", "Gesamt Siegele aus wöchentlichen Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsDailies", "Durchschnittliche Siegel aus täglichen Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsWeeklies", "Durchschnittliche Siegel aus wöchentlichen Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsDailies", "Die meisten Siegel aus einem einzigen tägliche Bestrebung")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsWeeklies", "Die meisten Siegel aus einem einzigen wöchentlichen Bestrebung")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalLifetimeSeals", "Gesamt Lebenszeit Siegel der Bestrebungen erworben")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsSpent", "Gesamt Siegel der Bestrebungen verbracht")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_CurrentTotalSeals", "Aktuelles Gesamt Siegel der Bestrebungen")
ZO_CreateStringId("ENDEAVOR_TRACKER_HistoryPanelStats_TotalGoldAcquired", "Gesamt Gold durch Bestrebungen erworben")
